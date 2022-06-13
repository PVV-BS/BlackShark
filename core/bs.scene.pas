{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised June, 2022

  This file is part of "Black Shark Graphics Engine", and may only be
used, modified, and distributed under the terms of the project license 
"License(LGPL).txt". By continuing to use, modify, or distribute this
file you indicate that you have read the license and understand and 
accept it fully.

  "Black Shark Graphics Engine" is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied 
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

-- End License block --
}


{
  Implements 3d scene with base operations:
    - a pick objects;
    - events of show/hide objects;
    - an order draw objects;

}
unit bs.scene;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , math

  , bs.geometry
  , bs.basetypes
  , bs.math
  , bs.events
  , bs.utils
  , bs.mesh
  , bs.collections
  , bs.shader
  ;

type

  { Forward declarations }

  TBScene             = class;
  TGraphicObject      = class;
  TGraphicObjectClass = class of TGraphicObject;
  PGraphicInstance    = ^TGraphicInstance;

  TListGraphicObjects = TListVec<TGraphicObject>;

  TKeySortInstance = record
    Distance: BSFloat;
    DrawOnlyFront: boolean;
    ModalLevel: int8;
  end;

  TListInstances    = TListDual<PGraphicInstance>;
  TListVecInstances = TListVec<PGraphicInstance>;

  { GL_CULL_FACE mode options }
  TDrawSide = (dsAll, dsFront, dsBack);

  { TGraphicInstance
    The record contains the properties instance of a mesh }

  TGraphicInstance = record
  public
    Owner: TGraphicObject;
    { a data of space tree }
    BVHNode: int32;
    { variables below describe current instance conditions }
    { transformations; all transformations to exert influence on children of Owner }
    { position relatively Parent }
    Position: TVec3f;
    Scale: TVec3f;
    ProdParentScale: TVec3f;
    Angle: TVec3f;
    { quaternion for define space orientation }
    Quaternion: TQuaternion;
    /////////////////////
    { BoundingBox = FMesh.FBoundingBox * FProdStackModelMatrix; }
    BoundingBox: TBox3f;
    { autochange when change Position, Scale and Angle }
    ModelMatrix: TMatrix4f;
    { the matrix contains only local Position and orientation (Angle) }
    //ModelMatrixPosAngle: TMatrix4f;
    { counter change ModelMatrix }
    ChangeModelMatrix: int32;
    { product matrixes all parents }
    ProdStackModelMatrix: TMatrix4f;
    { allows to accept mouse and key events }
    Interactive: boolean;
    { allows to drag instance }
    DragResolve: boolean;
    { allows automatically to select instance in scene; default equal true }
    SelectResolve: boolean;
    { if Hidden = true then instance will not visible, even if hit in frustum; for
      set property use TGraphicObject.SetHiddenInstance(instance, true)
      or TGraphicObject.SetHiddenRecursive(true) }
    Hidden: boolean;

    IsSelected: boolean;
    IsDrag: boolean;

    Index: int32;
  private
    { only for internal use }
    _ItemList: TListInstances.PListItem;    // in list instances
  end;

  TBeforeDrawMethod = procedure(Item: TGraphicObject) of object;
  TListBeforeDrawMethods = array of TBeforeDrawMethod;

  PDragInstanceData = ^TDragInstanceData;
  PRendererGraphicInstance = ^TRendererGraphicInstance;

  TListRendererInstances = TListDual<PRendererGraphicInstance>;
  { custom data for an every graphic item used for renderer }
  TRendererGraphicInstance = record
    { if it assigned then the instance can be dragged }
    Drag: PDragInstanceData;
    { if it assigned then the instance is selected }
    Selected: TListRendererInstances.PListItem;

    Instance: PGraphicInstance;

    { data of renderer }

    LastMVP: TMatrix4f;
    ChangeLastMVP: int32;

    { if Visible - READ ONLY property setted automaticaly; if you want to hide
      visible instance, then use TGraphicObject.SetHiddenInstance(instance, true),
      or TGraphicObject.SetHiddenRecursive(true) }
    Visible: boolean;
    _VisibleNode: TListRendererInstances.PListItem;
    { a distance from instance to screen; if set accuracy calculate then
      select nearest point from BB, else from middle BB }
    DistanceToScreen: BSFloat;
  end;

  TDragInstanceData = record
    Instance: PRendererGraphicInstance;
    BeginDragMousePos: TVec2i;
    BeginDragPos: TVec3f;
    BeginDragDistance: BSFloat;
    Ray: TRay3f;
    ParentDrag: boolean;
    _list_item: TListDual<PDragInstanceData>.PListItem;
  end;

  TDrawInstanceMethod = procedure(Instance: PRendererGraphicInstance) of object;

  { TGraphicObject
    The base unit for draw in a scene; contains one or more PGraphicInstance;
    the each instance defines transformations a property Shape (mesh); in fact,
    the object can displayed many times by way generate instances in function
    AddInstance }

  TGraphicObject = class
  public
    type
      TOnFreeGraphicObject = procedure (Item: TGraphicObject) of object;
  private
    FBaseInstance: PGraphicInstance;
    { list containing ancestors draw methods }
    FBeforeDrawMethods: TListBeforeDrawMethods;
    FAsStencil: boolean;
    FModalLevel: int32;
    FOpacity: BSFloat;
    FParent: TGraphicObject;
    FChildren: TListGraphicObjects;
    FStencilParent: TGraphicObject;
    FTagPtr: Pointer;
    FDrawInstance: TDrawInstanceMethod;
    FStaticObject: boolean;
    FDrawAsTransparent: boolean;
    FDrawSides: TDrawSide;
    //FClockWiseCullFace: boolean;
    FTagInt: NativeInt;
    FStencilTest: boolean;
    FDepthTest: boolean;
    FDepthTestFunc: uint16;
    FOwner: TObject;
    FServiceScale: BSFloat;
    FServiceScaleInv: BSFloat;
    FSceneSpaceTreeClient: boolean;
    FPositionLimits: TBox3f;
    FHavePositionLimits: boolean;
    {.$ifdef DEBUG_BS}
    FCaption: string;
    {.$endif}
    FBanDraw: boolean;
    function GetAbsolutePosition: TVec3f;
    procedure GenerateProdStackMatrix(Instance: PGraphicInstance);{$ifndef DEBUG_BS} inline; {$endif}
    procedure GenerateModelMatrixFromAllTransformations(Instance: PGraphicInstance; ASendEvent: boolean); {$ifndef DEBUG_BS} inline; {$endif}
    function GetCountParents: int32;
    function GetIsDrag: boolean;
    procedure SetIsDrag(const {%H-}Value: boolean);
    function GetDragResolve: boolean;
    function GetQuaternion: TQuaternion;
    function GetScaleSimple: BSFloat;
    procedure SetAsSencil(AValue: boolean);
    //function CreateVAO: boolean;
    //procedure FreeVAO;
    procedure SetDragResolve(AValue: boolean);
    procedure SetModalLevel(AValue: int32);
    procedure SetQuaternion(AValue: TQuaternion);
    procedure SetScaleSimple(AValue: BSFloat);
    procedure SetMesh(AValue: TMesh);
    function GetChildrenCount: int32;
    function GetChild(Index: int32): TGraphicObject;
    function GetAngle: TVec3f;
    function GetBoundingBox: TBox3f;
    function GetInteractive: boolean;
    function GetIsSelected: boolean;
    procedure SetInteractive(const Value: boolean);
    procedure SetAngle(AValue: TVec3f);
    procedure SetIsSelected(AValue: boolean);
    procedure RemoveChild(Child: TGraphicObject);
    function GetHidden: boolean;
    procedure SetHidden(const Value: boolean);
    function GetCountInstances: int32;
    procedure SetScene(const Value: TBScene);
    procedure SetStaticObject(const Value: boolean);
    procedure SetDrawAsTransparent(const Value: boolean);
    function GetAngleX: BSFloat;
    function GetAngleY: BSFloat;
    function GetAngleZ: BSFloat;
    procedure SetAngleX(const Value: BSFloat);
    procedure SetAngleY(const Value: BSFloat);
    procedure SetAngleZ(const Value: BSFloat);
    function GetSelectResolve: boolean;
    procedure SetSelectResolve(const Value: boolean);
    procedure SetStensilTest(const Value: boolean);
    procedure SetDrawSides(const Value: TDrawSide);
    procedure CheckChildrenOnStencil(ParentStencil: TGraphicObject);
    function GetEventDrag: IBDragDropEvent;
    function GetEventDrop: IBDragDropEvent;
    function GetEventKeyDown: IBKeyDownEvent;
    function GetEventKeyPress: IBKeyPressEvent;
    function GetEventKeyUp: IBKeyUpEvent;
    function GetEventMouseDown: IBMouseDownEvent;
    function GetEventMouseEnter: IBMouseEnterEvent;
    function GetEventMouseLeave: IBMouseLeaveEvent;
    function GetEventMouseMove: IBMouseMoveEvent;
    function GetEventMouseUp: IBMouseUpEvent;
    function GetEventChangeMVP: IBChangeMVPEvent;
    function GetEventMouseDblClick: IBMouseDblClickEvent;
    function GetProdScaleInstance(AInstance: PGraphicInstance): TVec3f;
    function GetEventDropChildren: IBDragDropEvent;
    function GetHasStencilParent: boolean;
    function GetStencilParent: TGraphicObject;
    function GetScaleProd: TVec3f;
    procedure UpdateProdScaleInstance(AInstance: PGraphicInstance);
    procedure UpdateProdScale;
    procedure SetSceneSpaceTreeClient(const Value: boolean);
    procedure SetPositionLimits(const Value: TBox3f);
    function GetLocalTransform: TMatrix4f;
    procedure SetLocalTransform(const Value: TMatrix4f);
  protected
    FScene: TBScene;
    FShader: TBlackSharkShader;

    FEventMouseDblClick: IBMouseDblClickEvent;
    FEventMouseDown: IBMouseDownEvent;
    FEventMouseUp: IBMouseUpEvent;
    FEventMouseMove: IBMouseMoveEvent;
    FEventMouseEnter: IBMouseEnterEvent;
    FEventMouseLeave: IBMouseLeaveEvent;
    FEventKeyDown: IBKeyDownEvent;
    FEventKeyUp: IBKeyUpEvent;
    FEventKeyPress: IBKeyPressEvent;

    FEventChangeMVP: IBChangeMVPEvent;
    FEventBeginDrag: IBDragDropEvent;
    FEventDrop: IBDragDropEvent;
    FEventDropChildren: IBDragDropEvent;
    FEventDrag: IBDragDropEvent;

    UpdateCount: int32;

    FMesh: TMesh;
    FInstances: TListInstances;
    //VBO_UV: GLUint;
    { do not suppot in GLES20 }
    //VAO: GLUint;


    procedure SetShader(const AValue: TBlackSharkShader); virtual;
    procedure SetOpacity(AValue: BSFloat); virtual;
    procedure SetScale(const AValue: TVec3f); virtual;
    procedure SetPosition(AValue: TVec3f); virtual;
    function GetPosition: TVec3f; virtual;
    function GetScale: TVec3f; virtual;
    procedure SetColor(const {%H-}Value: TColor4f); virtual;
    function GetColor: TColor4f; virtual;
    procedure SetParent(const Value: TGraphicObject); virtual;
    procedure SetOwner(const Value: TObject); virtual;
  public
    { - AOwner - any your object }
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); virtual;
    { Destructor free also all children }
    destructor Destroy; override;
    function AddChild(Child: TGraphicObject): TGraphicObject; overload;
    function AddChild(AOwner: TObject; BaseType: TGraphicObjectClass; SrcMesh: TMesh): TGraphicObject; overload;
    function AddChild(AOwner: TObject; BaseType: TGraphicObjectClass): TGraphicObject; overload;
    procedure Restore; virtual;
    { an every descendant creates own kind of a mesh }
    class function CreateMesh: TMesh; virtual;
    procedure BeginUpdateTransformations;
    procedure EndUpdateTransformations;
    procedure SetParentAllChildren(NewParent: TGraphicObject);
    procedure CalcActualBoundingBox(Instance: PGraphicInstance);
    { an any object or ancestor can to add self a method invoked befor DrawInstance }
    procedure AddBeforeDrawMethod(const BeforeDrawMethod: TBeforeDrawMethod);
    procedure ClearBeforeDrawListMethods;
    procedure DelBeforeDrawMethod(const BeforeDrawMethod: TBeforeDrawMethod);
    { must call after change content of Shape property; the method, if need,
      deletes old VBO, and creates new single VBO for all vertex components
      and one VBO for indexes }
    procedure ChangedMesh; virtual;
    { Adds the same instance }
    function AddInstance(const Pos: TVec3f): PGraphicInstance;
    procedure ClearInstances(Recursive: boolean = false; OnlyChildren: boolean = false);
    { Clears the Shape and VBOs if a static object }
    procedure Clear; virtual;
    procedure DelInstance(Instance: PGraphicInstance);
    procedure DeleteChildren; virtual;
    { Setters property instance }
    procedure SetInteractiveInstance(Instance: PGraphicInstance; const Value: boolean); inline;
    procedure SetInteractiveRecursive(const Value: boolean); inline;
    procedure SetAngleInstance(Instance: PGraphicInstance; const AValue: TVec3f);    inline;
    procedure RotateInstance(Instance: PGraphicInstance; Angle: BSFloat; Axel: TRotateSequence); inline;
    procedure SetQuaternionInstance(Instance: PGraphicInstance; const AValue: TQuaternion); inline;
    { NOT VIRTUAL setter position instance; if you want to intercept in ancestors
      an access this method use AddSetterPositionInstance }
    procedure SetPositionInstance(Instance: PGraphicInstance; const AValue: TVec3f);
    procedure SetDragResolveInstance(Instance: PGraphicInstance; AValue: boolean); {$ifndef DEBUG} inline; {$endif}
    procedure SetDragResolveRecursive(AValue: boolean);
    procedure SetHiddenInstance(Instance: PGraphicInstance; AValue: boolean); virtual;
    procedure SetHiddenRecursive(AValue: boolean);
    procedure SetScaleInstance(AInstance: PGraphicInstance; const AValue: TVec3f); virtual;
    procedure SetSelectResolveInstance(Instance: PGraphicInstance; AValue: boolean); inline;
    procedure SetStensilTestRecursive(AValue: boolean);
    procedure SetServiceScale(AServiceScale: BSFloat); virtual;
    { Getters property instance }
    function GetAbsolutePositionInstance(Instance: PGraphicInstance): TVec3f;
    function IsAncestor(Ancestor: TGraphicObject; SelfInclude: boolean): boolean;
    function Intersects(Instance1, Instance2: PGraphicInstance; Exact: boolean): boolean;

    procedure DoMouseDblClick(const AMouseData: BMouseData);
    procedure DoMouseDown(const AMouseData: BMouseData);
    procedure DoMouseUp(const AMouseData: BMouseData);
    procedure DoMouseMove(const AMouseData: BMouseData);
    procedure DoMouseEnter(const AMouseData: BMouseData);
    procedure DoMouseLeave(const AMouseData: BMouseData);

    procedure DoKeyDown(const AKeyData: BKeyData);
    procedure DoKeyUp(const AKeyData: BKeyData);
    procedure DoKeyPress(const AKeyData: BKeyData);

    procedure DoChangeMVP(AInstance: Pointer; IsMeshShapeTransform: boolean);

    procedure DoBeginDrag(AInstance: PGraphicInstance; CheckDragParent: boolean);
    function DoDrag(AInstance: PGraphicInstance; CheckDragParent: boolean): boolean;
    function DoDrop(AInstance: PGraphicInstance): boolean;
    function DoDropChildren(AInstance: PGraphicInstance): boolean;
    function FindObject(const ACaption: string; SelfInclude: boolean): TGraphicObject;
  public
    { Properties }
    property BaseInstance: PGraphicInstance read FBaseInstance;
    property AbsolutePosition: TVec3f read GetAbsolutePosition;
    property BeforeDrawMethods: TListBeforeDrawMethods read FBeforeDrawMethods;
    { method/property is drawing one instance; you can to assign an any method
      of object }
    property DrawInstance: TDrawInstanceMethod read FDrawInstance write FDrawInstance;
    property Shader: TBlackSharkShader read FShader write SetShader;
    property CountInstances: int32 read GetCountInstances;
    property Instances: TListInstances read FInstances;
    { Transformations relatively a parent }
    property Position: TVec3f read GetPosition write SetPosition;
    property PositionLimits: TBox3f read FPositionLimits write SetPositionLimits;
    { a value of scaling to every axis }
    property Scale: TVec3f read GetScale write SetScale;
    { all accumulated scales, including own }
    property ScaleProd: TVec3f read GetScaleProd;
    { Scale for all axis (proportional scaling); change automatically above property Scale }
    property ScaleSimple: BSFloat read GetScaleSimple write SetScaleSimple;
    { Angle define turn around axis, appropriately:
      x - around x-axle, y - around y-axle and z - around z-axle }
    property Angle: TVec3f read GetAngle write SetAngle;
    property AngleX: BSFloat read GetAngleX write SetAngleX;
    property AngleY: BSFloat read GetAngleY write SetAngleY;
    property AngleZ: BSFloat read GetAngleZ write SetAngleZ;
    { Quaternion, as and property Angle, defines a turn around axis, and calculated
      automatically when you change Angle; quaternion translated to transformation
      matrix and help avoid gimble lock which happened if use Euler angles
      translated to matrix transformation }
    property Quaternion: TQuaternion read GetQuaternion write SetQuaternion;
    { Opacity in border [0..1], where: 0 - not visible, 1 - visible }
    property Opacity: BSFloat read FOpacity write SetOpacity;
    { contains all transformation of the object for BaseInstance;
      Important: the setter doesn't translate in such properties as Position,
      Quaternion and so on, therefore make it yourself if need }
    property LocalTransform: TMatrix4f read GetLocalTransform write SetLocalTransform;
    property Scene: TBScene read FScene write SetScene;
    property TagPtr: Pointer read FTagPtr write FTagPtr;
    property TagInt: NativeInt read FTagInt write FTagInt;
    property IsSelected: boolean read GetIsSelected write SetIsSelected;
    { the property allows to hide/show an object which placed into frustum }
    property Hidden: boolean read GetHidden write SetHidden;
    { resolve to communicate with mouse events }
    property Interactive: boolean read GetInteractive write SetInteractive;
    { resolve to drag by mouse }
    property DragResolve: boolean read GetDragResolve write SetDragResolve;
    property SelectResolve: boolean read GetSelectResolve write SetSelectResolve;
    { is the object now dragging ? }
    property IsDrag: boolean read GetIsDrag write SetIsDrag;
    { bans to draw the object }
    property BanDraw: boolean read FBanDraw write FBanDraw;
    { a drawn mesh (shape) }
    property Mesh: TMesh read FMesh write SetMesh;
    { it determines whether participate all the object instances in space tree of the scene;
      if equal "false" it gives smaller overhead, but when viewport movies visibility
      of instances of the object doesn't calculate, only when instances moving itself;
      for example, it property can be usefull when we know that an object alwas is visible
      and then we don't want to overload scene by space area detection for the object;
      the property default equal "true" }
    property SceneSpaceTreeClient: boolean read FSceneSpaceTreeClient write SetSceneSpaceTreeClient;
    { service scale for internal use }
    property ServiceScale: BSFloat read FServiceScale write SetServiceScale;
    property ServiceScaleInv: BSFloat read FServiceScaleInv;
    property BoundingBox: TBox3f read GetBoundingBox;
    property ChildrenCount: int32 read GetChildrenCount;
    property Child[index: int32]: TGraphicObject read GetChild;
    { if true then object draw after all no transparent, and closly to camera
      draw first in order  }
    property DrawAsTransparent: boolean read FDrawAsTransparent write SetDrawAsTransparent;
    {  }
    property DrawSides: TDrawSide read FDrawSides write SetDrawSides;
    { for glFrontFace setter — define front- and back-facing polygons GL_CW;
      the initial value is GL_CCW; useful for show inside objects (true); for this
      also DrawingSides need set to dsBack }
    // property ClockWiseCullFace: boolean read FClockWiseCullFace write FClockWiseCullFace;
    property Parent: TGraphicObject read FParent write SetParent;
    property Color: TColor4f read GetColor write SetColor;
    { if StaticObject = true, then automaticaly create VBOs for mesh (shape)
      vertexes and indexes; else on evry draw translate to GPU data vertexes and
      indexes; if the property even false, then not need invoke every time call
      ChangedMesh after change mesh throw property TGraphicObject.Shape }
    property StaticObject: boolean read FStaticObject write SetStaticObject;
    property ModalLevel: int32 read FModalLevel write SetModalLevel;
    property StencilTest: boolean read FStencilTest write SetStensilTest;
    property AsStencil: boolean read FAsStencil write SetAsSencil;
    property StencilParent: TGraphicObject read FStencilParent;
    property HasStencilParent: boolean read GetHasStencilParent;
    {
      Depth test switcher;
      A description see on:
      https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glDepthFunc.xml
       }
    property DepthTest: boolean read FDepthTest write FDepthTest;
    { property sets function used for depth test;
      accepted values:
        GL_NEVER = $0200;
        GL_LESS = $0201;
        GL_EQUAL = $0202;
        GL_LEQUAL = $0203;
        GL_GREATER = $0204;
        GL_NOTEQUAL = $0205;
        GL_GEQUAL = $0206;
        GL_ALWAYS = $0207;
     }
    property DepthTestFunc: uint16 read FDepthTestFunc write FDepthTestFunc;
    { returns count parents or a "depth" of encapsulation }
    property CountParents: int32 read GetCountParents;
    property Owner: TObject read FOwner write SetOwner;
    {.$ifdef DEBUG_BS}
    property Caption: string read FCaption write FCaption;
    {.$endif}
  public
    { events }
    { be careful when use the events and Selected property or release objects
      the same time when this events occurred }
    property EventMouseDblClick: IBMouseDblClickEvent read GetEventMouseDblClick;
    property EventMouseDown: IBMouseDownEvent read GetEventMouseDown;
    property EventMouseUp: IBMouseUpEvent read GetEventMouseUp;
    property EventMouseMove: IBMouseMoveEvent read GetEventMouseMove;
    property EventMouseEnter: IBMouseEnterEvent read GetEventMouseEnter;
    property EventMouseLeave: IBMouseLeaveEvent read GetEventMouseLeave;
    property EventKeyDown: IBKeyDownEvent read GetEventKeyDown;
    property EventKeyUp: IBKeyUpEvent read GetEventKeyUp;
    property EventKeyPress: IBKeyPressEvent read GetEventKeyPress;
    property EventChangeMVP: IBChangeMVPEvent read GetEventChangeMVP;
    property EventBeginDrag: IBDragDropEvent read FEventBeginDrag;
    property EventDrag: IBDragDropEvent read GetEventDrag;
    property EventDrop: IBDragDropEvent read GetEventDrop;
    property EventDropChildren: IBDragDropEvent read GetEventDropChildren;
  end;

  THashTableGraphicObjects = THashTable<Pointer, TGraphicObject>;

  TEventInstanceSelect = IBEmptyEvent;
  TEventInstanceCreate = IBEmptyEvent;
  TEventInstanceDelete = IBEmptyEvent;
  TEventInstanceTransform = IBEmptyEvent;
  TEventInstanceBeforeChangeKey = IBEmptyEvent;
  TEventInstanceAfterChangeKey = IBEmptyEvent;
  TEventInstanceBeginDrag = IBDragDropEvent;

  TEventInstanceSelectObserver = IBEmptyEventObserver;
  TEventInstanceCreateObserver = IBEmptyEventObserver;
  TEventInstanceDeleteObserver = IBEmptyEventObserver;
  TEventInstanceTransformObserver = IBEmptyEventObserver;
  TEventInstanceBeforeChangeKeyObserver = IBEmptyEventObserver;
  TEventInstanceAfterChangeKeyObserver = IBEmptyEventObserver;
  TEventInstanceBeginDragObserver = IBEmptyEventObserver;

  { TBScene }

  TBScene = class(TBlackSharkKDTree)
  private
    StackGI: TListVecInstances;
    { all Graphics Items in scene }
    FGraphicObjects: THashTableGraphicObjects;

    FEventObjectChangeOrderDraw: IBEmptyEvent;
    FEventObjectIncStencilUse: IBEmptyEvent;
    FEventObjectDecStencilUse: IBEmptyEvent;

    FEventInstanceCreate: IBEmptyEvent;
    FEventInstanceDelete: IBEmptyEvent;
    FEventInstanceSceneSpaceTreeClientChanged: IBEmptyEvent;
    FEventInstanceTransform: IBEmptyEvent;
    FEventInstanceSelect: TEventInstanceSelect;
    FEventInstanceBeforeChangeKey: IBEmptyEvent;
    FEventInstanceAfterChangeKey: IBEmptyEvent;
    FEventInstanceBeginDrag: IBDragDropEvent;
  protected
    procedure ObjectAdd(AItem: TGraphicObject); overload;
    procedure ObjectDelete(AItem: TGraphicObject);
    procedure ObjectIncStencilUse(AObject: TGraphicObject);
    procedure ObjectDecStencilUse(AObject: TGraphicObject);
    procedure ObjectChangeOrderDraw(AObject: TGraphicObject);
    procedure InstanceCreate(Instance: PGraphicInstance);
    procedure InstanceDelete(Instance: PGraphicInstance);
    procedure InstanceBeforeChangeKey(Instance: PGraphicInstance); {$ifndef DEBUG_BS} inline; {$endif}
    procedure InstanceAfterChangeKey(Instance: PGraphicInstance); {$ifndef DEBUG_BS} inline; {$endif}
    procedure InstanceBeginDrag(Instance: PGraphicInstance; CheckDragParent: boolean);
    procedure InstanceSceneSpaceTreeClientChanged(Instance: PGraphicInstance);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear; override;
    function ObjectAdd(AClassGraphicObject: TGraphicObjectClass; AParent: TGraphicObject; AOwner: TObject): TGraphicObject; overload;
    procedure InstanceSetSelected(Instance: PGraphicInstance; Selected: boolean);
  public
    property GraphicObjects: THashTableGraphicObjects read FGraphicObjects;

    procedure InstanceTransform(Instance: PGraphicInstance; IsMeshShapeTransform: boolean);

    property EventInstanceSelect: TEventInstanceSelect read FEventInstanceSelect;
    property EventInstanceTransform: IBEmptyEvent read FEventInstanceTransform;
    property EventInstanceCreate: IBEmptyEvent read FEventInstanceCreate;
    property EventInstanceDelete: IBEmptyEvent read FEventInstanceDelete;
    property EventInstanceSceneSpaceTreeClientChanged: IBEmptyEvent read FEventInstanceSceneSpaceTreeClientChanged;
    property EventInstanceBeforeChangeKey: IBEmptyEvent read FEventInstanceBeforeChangeKey;
    property EventInstanceAfterChangeKey: IBEmptyEvent read FEventInstanceAfterChangeKey;
    property EventInstanceBeginDrag: IBDragDropEvent read FEventInstanceBeginDrag;

    property EventObjectChangeOrderDraw: IBEmptyEvent read FEventObjectChangeOrderDraw;
    property EventObjectIncStencilUse: IBEmptyEvent read FEventObjectIncStencilUse;
    property EventObjectDecStencilUse: IBEmptyEvent read FEventObjectDecStencilUse;
  end;

implementation

uses
    bs.config
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  ;

type

  { TInstanceManager }

  TInstanceManager = class
  private
    class var FreeIndexes: TListVec<int32>;
    class var FreeInstances: TListVec<PGraphicInstance>;
    class var EngagedIndexes: int32;

    class function GetFreeIndex: int32;
    class constructor Create;
    class destructor Destroy;
  public
    class function  InstanceCreate(Owner: TGraphicObject): PGraphicInstance;
    class procedure InstanceFree(Instance: PGraphicInstance);
  end;

{ TInstanceManager }

class constructor TInstanceManager.Create;
begin
  FreeInstances := TListVec<PGraphicInstance>.Create;
  FreeIndexes := TListVec<int32>.Create;
end;

class function TInstanceManager.InstanceCreate(Owner: TGraphicObject): PGraphicInstance;
begin
  if FreeInstances.Count > 0 then
    Result := FreeInstances.Pop
  else
    new(Result);
  FillChar(Result^, SizeOf(TGraphicInstance), 0);
  Result.BVHNode := -1;
  Result.Owner := Owner;
  Result.Angle := vec3(0.0, 0.0, 0.0);
  Result.Position := vec3(0.0, 0.0, 0.0);
  Result.Scale := IDENTITY_VEC3;
  if Assigned(Owner.Parent) then
    Result.ProdParentScale := Owner.Parent.BaseInstance.ProdParentScale
  else
    Result.ProdParentScale := IDENTITY_VEC3;
  Result.Interactive := true;
  Result.SelectResolve := true;
  Result.DragResolve := true;
  Result.BoundingBox.TagPtr := Result;
  Result.ModelMatrix := IDENTITY_MAT;
  //Result.ModelMatrixPosAngle := IDENTITY_MAT;
  Result.Quaternion := vec4(0.0, 0.0, 0.0, 1.0);
  Result.Index := GetFreeIndex;
end;

class function TInstanceManager.GetFreeIndex: int32;
begin
  if FreeIndexes.Count > 0 then
    Result := FreeIndexes.Pop
  else
  begin
    Result := EngagedIndexes;
    inc(EngagedIndexes);
  end;
end;

class destructor TInstanceManager.Destroy;
var
  i: Integer;
begin
  if Assigned(FreeInstances) then
  begin
    for i := 0 to FreeInstances.Count - 1 do
      dispose(FreeInstances.Items[i]);
    FreeInstances.Free;
  end;
  FreeIndexes.Free;
  inherited;
end;

class procedure TInstanceManager.InstanceFree(Instance: PGraphicInstance);
begin
  FreeInstances.Add(Instance);
end;

{ TGraphicObject }

procedure TGraphicObject.SetInteractive(const Value: boolean);
begin
  SetInteractiveInstance(BaseInstance, Value);
end;

procedure TGraphicObject.SetInteractiveInstance(Instance: PGraphicInstance; const Value: boolean);
begin
  if (Instance^.Interactive = Value) then
    Exit;
  Instance^.Interactive := Value;
end;

procedure TGraphicObject.SetInteractiveRecursive(const Value: boolean);
var
  i: int32;
begin
  SetInteractiveInstance(BaseInstance, Value);
  for i := 0 to ChildrenCount - 1 do
    Child[i].SetInteractiveRecursive(Value);
end;

procedure TGraphicObject.SetIsSelected(AValue: boolean);
begin
  Scene.InstanceSetSelected(BaseInstance, AValue);
end;

procedure TGraphicObject.SetLocalTransform(const Value: TMatrix4f);
begin
  FBaseInstance.ModelMatrix := Value;
  FScene.InstanceTransform(FBaseInstance, true);
end;

procedure TGraphicObject.SetSelectResolve(const Value: boolean);
begin
  SetSelectResolveInstance(BaseInstance, Value);
end;

procedure TGraphicObject.SetSelectResolveInstance(Instance: PGraphicInstance; AValue: boolean);
begin
  if (Instance^.SelectResolve = AValue) then
    exit;
  Instance^.SelectResolve := AValue;
end;

procedure TGraphicObject.SetShader(const AValue: TBlackSharkShader);
var
  ch: TGraphicObject;
  i: int32;
begin
  if FShader = AValue then
    exit;

  for i := 0 to ChildrenCount - 1 do
  begin
    ch := FChildren.Items[i];
    if (ch.Shader = nil) or (ch.Shader = FShader) then
      ch.Shader := AValue;
  end;

  if Assigned(FShader) then
    BSShaderManager.FreeShader(FShader);

  FShader := AValue;
  if Assigned(FShader) then
    FShader._AddRef;
end;

procedure TGraphicObject.SetAngle(AValue: TVec3f);
begin
  SetAngleInstance(BaseInstance, AValue);
end;

procedure TGraphicObject.SetAngleInstance(Instance: PGraphicInstance; const AValue: TVec3f);
begin
  if (Instance.Angle = AValue) then Exit;
  Instance.Angle := AngleEulerClamp3d(AValue);
  Instance.Quaternion := VecNormalize(bs.basetypes.Quaternion(Instance.Angle));
  //Instance.Quaternion := BlackSharkBaseTypes.Quaternion(Instance.Angle, Instance.RotateSequence[0],
  //  Instance.RotateSequence[1], Instance.RotateSequence[2]);
  GenerateModelMatrixFromAllTransformations(Instance, true);
end;

procedure TGraphicObject.SetAngleX(const Value: BSFloat);
begin
  RotateInstance(BaseInstance, Value, rsAxelX);
end;

procedure TGraphicObject.SetAngleY(const Value: BSFloat);
begin
  RotateInstance(BaseInstance, Value, rsAxelY);
end;

procedure TGraphicObject.SetAngleZ(const Value: BSFloat);
begin
  RotateInstance(BaseInstance, Value, rsAxelZ);
end;

function TGraphicObject.GetColor: TColor4f;
begin
  Result := BS_CL_GREEN;
end;

procedure TGraphicObject.SetColor(const Value: TColor4f);
begin

end;

function TGraphicObject.GetCountInstances: int32;
begin
  if Assigned(FInstances) then
    Result := 1 + FInstances.Count
  else
    Result := 1;
end;

procedure TGraphicObject.SetQuaternionInstance(Instance: PGraphicInstance; const AValue: TQuaternion);
begin
  if (Instance.Quaternion = AValue) then
    Exit;
  Instance.Quaternion := AValue;
  Instance.Angle := QuaternionToAngles(AValue);
  GenerateModelMatrixFromAllTransformations(Instance, true);
end;

function TGraphicObject.GetAngle: TVec3f;
begin
  Result := FBaseInstance.Angle;
end;

function TGraphicObject.GetAngleX: BSFloat;
begin
  Result := FBaseInstance.Angle.x;
end;

function TGraphicObject.GetAngleY: BSFloat;
begin
  Result := FBaseInstance.Angle.y;
end;

function TGraphicObject.GetAngleZ: BSFloat;
begin
  Result := FBaseInstance.Angle.z;
end;

function TGraphicObject.GetBoundingBox: TBox3f;
begin
  Result := FBaseInstance.BoundingBox;
end;

function TGraphicObject.GetPosition: TVec3f;
begin
  Result := FBaseInstance.Position;
end;

function TGraphicObject.GetScale: TVec3f;
begin
  Result := FBaseInstance.Scale;
end;

function TGraphicObject.GetScaleProd: TVec3f;
begin
  Result := FBaseInstance.ProdParentScale;
end;

function TGraphicObject.GetInteractive: boolean;
begin
  Result := FBaseInstance.Interactive;
end;

function TGraphicObject.GetIsSelected: boolean;
begin
  Result := FBaseInstance.IsSelected;
end;

function TGraphicObject.GetLocalTransform: TMatrix4f;
begin
  Result := FBaseInstance.ModelMatrix;
end;

function TGraphicObject.GetSelectResolve: boolean;
begin
  Result := FBaseInstance.SelectResolve;
end;

function TGraphicObject.GetStencilParent: TGraphicObject;
begin
  Result := FParent;
  while Assigned(Result) and (not Result.AsStencil) do
    Result := Result.Parent;
end;

function TGraphicObject.Intersects(Instance1, Instance2: PGraphicInstance; Exact: boolean): boolean;
begin
  Result := Box3Collision(Instance1.BoundingBox, Instance2.BoundingBox);
  if Result and Exact then
  begin
    { TODO: to inmplement an exact algorithm define intersect }
  end;
end;

function TGraphicObject.IsAncestor(Ancestor: TGraphicObject; SelfInclude: boolean): boolean;
var
  prnt: TGraphicObject;
begin

  if SelfInclude then
    prnt := Self
  else
    prnt := FParent;

  while Assigned(prnt) do
  begin
    if prnt = Ancestor then
      exit(true);
    prnt := prnt.FParent;
  end;
  Result := false;
end;

procedure TGraphicObject.BeginUpdateTransformations;
begin
  inc(UpdateCount);
end;

function TGraphicObject.GetChild(Index: int32): TGraphicObject;
begin
  Result := FChildren.Items[index];
end;

function TGraphicObject.GetChildrenCount: int32;
begin
  if Assigned(FChildren) then
    Result := FChildren.Count
  else
    Result := 0;
end;

function TGraphicObject.GetAbsolutePosition: TVec3f;
begin
  Result := TVec3f(FBaseInstance.ProdStackModelMatrix.M3);
end;

procedure TGraphicObject.GenerateProdStackMatrix(Instance: PGraphicInstance);
var
  m: TMatrix3f;
begin
  if Assigned(FParent) then
  begin
    if FParent.ServiceScaleInv <> 1.0 then
    begin
      // substract service scale of parent for mesh
      m.V[0 ] := FParent.BaseInstance.ProdStackModelMatrix.V[0 ]*FParent.ServiceScaleInv;
      m.V[1 ] := FParent.BaseInstance.ProdStackModelMatrix.V[1 ]*FParent.ServiceScaleInv;
      m.V[2 ] := FParent.BaseInstance.ProdStackModelMatrix.V[2 ]*FParent.ServiceScaleInv;

      m.V[3 ] := FParent.BaseInstance.ProdStackModelMatrix.V[4 ]*FParent.ServiceScaleInv;
      m.V[4 ] := FParent.BaseInstance.ProdStackModelMatrix.V[5 ]*FParent.ServiceScaleInv;
      m.V[5 ] := FParent.BaseInstance.ProdStackModelMatrix.V[6 ]*FParent.ServiceScaleInv;

      m.V[6 ] := FParent.BaseInstance.ProdStackModelMatrix.V[8 ]*FParent.ServiceScaleInv;
      m.V[7 ] := FParent.BaseInstance.ProdStackModelMatrix.V[9 ]*FParent.ServiceScaleInv;
      m.V[8 ] := FParent.BaseInstance.ProdStackModelMatrix.V[10]*FParent.ServiceScaleInv;

    end else
    begin
      m.V[0 ] := FParent.BaseInstance.ProdStackModelMatrix.V[0 ];
      m.V[1 ] := FParent.BaseInstance.ProdStackModelMatrix.V[1 ];
      m.V[2 ] := FParent.BaseInstance.ProdStackModelMatrix.V[2 ];

      m.V[3 ] := FParent.BaseInstance.ProdStackModelMatrix.V[4 ];
      m.V[4 ] := FParent.BaseInstance.ProdStackModelMatrix.V[5 ];
      m.V[5 ] := FParent.BaseInstance.ProdStackModelMatrix.V[6 ];

      m.V[6 ] := FParent.BaseInstance.ProdStackModelMatrix.V[8 ];
      m.V[7 ] := FParent.BaseInstance.ProdStackModelMatrix.V[9 ];
      m.V[8 ] := FParent.BaseInstance.ProdStackModelMatrix.V[10];
    end;

    Instance.ProdStackModelMatrix.V[0] := Instance.ModelMatrix.V[0]*m.V[0] +
                                          Instance.ModelMatrix.V[1]*m.V[3] +
                                          Instance.ModelMatrix.V[2]*m.V[6];
    Instance.ProdStackModelMatrix.V[1] := Instance.ModelMatrix.V[0]*m.V[1] +
                                          Instance.ModelMatrix.V[1]*m.V[4] +
                                          Instance.ModelMatrix.V[2]*m.V[7];
    Instance.ProdStackModelMatrix.V[2] := Instance.ModelMatrix.V[0]*m.V[2] +
                                          Instance.ModelMatrix.V[1]*m.V[5] +
                                          Instance.ModelMatrix.V[2]*m.V[8];
    Instance.ProdStackModelMatrix.V[3] := 0.0;

    Instance.ProdStackModelMatrix.V[4] := Instance.ModelMatrix.V[4]*m.V[0] +
                                          Instance.ModelMatrix.V[5]*m.V[3] +
                                          Instance.ModelMatrix.V[6]*m.V[6];
    Instance.ProdStackModelMatrix.V[5] := Instance.ModelMatrix.V[4]*m.V[1] +
                                          Instance.ModelMatrix.V[5]*m.V[4] +
                                          Instance.ModelMatrix.V[6]*m.V[7];
    Instance.ProdStackModelMatrix.V[6] := Instance.ModelMatrix.V[4]*m.V[2] +
                                          Instance.ModelMatrix.V[5]*m.V[5] +
                                          Instance.ModelMatrix.V[6]*m.V[8];
    Instance.ProdStackModelMatrix.V[7] := 0.0;

    Instance.ProdStackModelMatrix.V[8] := Instance.ModelMatrix.V[8]*m.V[0] +
                                          Instance.ModelMatrix.V[9]*m.V[3] +
                                          Instance.ModelMatrix.V[10]*m.V[6];
    Instance.ProdStackModelMatrix.V[9] := Instance.ModelMatrix.V[8]*m.V[1] +
                                          Instance.ModelMatrix.V[9]*m.V[4] +
                                          Instance.ModelMatrix.V[10]*m.V[7];
    Instance.ProdStackModelMatrix.V[10]:= Instance.ModelMatrix.V[8]*m.V[2] +
                                          Instance.ModelMatrix.V[9]*m.V[5] +
                                          Instance.ModelMatrix.V[10]*m.V[8];
    Instance.ProdStackModelMatrix.V[11]:= 0.0;

    Instance.ProdStackModelMatrix.V[12] := Instance.ModelMatrix.V[12] * m.V[0] +
                                           Instance.ModelMatrix.V[13] * m.V[3] +
                                           Instance.ModelMatrix.V[14] * m.V[6] + FParent.BaseInstance.ProdStackModelMatrix.M3.x;

    Instance.ProdStackModelMatrix.V[13] := Instance.ModelMatrix.V[12] * m.V[1] +
                                           Instance.ModelMatrix.V[13] * m.V[4] +
                                           Instance.ModelMatrix.V[14] * m.V[7] + FParent.BaseInstance.ProdStackModelMatrix.M3.y;

    Instance.ProdStackModelMatrix.V[14] := Instance.ModelMatrix.V[12] * m.V[2] +
                                           Instance.ModelMatrix.V[13] * m.V[5] +
                                           Instance.ModelMatrix.V[14] * m.V[8] + FParent.BaseInstance.ProdStackModelMatrix.M3.z;

    Instance.ProdStackModelMatrix.M3.w := 1.0;
  end else
   Instance.ProdStackModelMatrix := Instance.ModelMatrix;

  CalcActualBoundingBox(Instance);
end;

procedure TGraphicObject.SetParent(const Value: TGraphicObject);
var
  ml, old_ml: int32;
  it: TListInstances.PListItem;
begin
  if Value = FParent then
    exit;

  if Assigned(FParent) then
    FParent.RemoveChild(Self);

  FParent := Value;
  old_ml := FModalLevel;

  if Assigned(FParent) then
  begin
    FBaseInstance.ProdParentScale := GetProdScaleInstance(FBaseInstance);
    ml := FParent.ModalLevel;
    FParent.AddChild(Self);
  end else
  begin
    ml := FModalLevel;
    FBaseInstance.ProdParentScale := FBaseInstance.Scale;
  end;

  { when a parent changed then can change its position in space; so as a distance to
    screen is included in key for sorts visible items, therefor it remove from drawed
    items list, and to invoke handler InstanceTransform }
  //if FBaseInstance.Visible then
  begin
    FModalLevel := old_ml;
    FScene.InstanceBeforeChangeKey(BaseInstance);
    FModalLevel := ml;
    FScene.InstanceTransform(BaseInstance, false);
  end;

  if Assigned(FInstances) then
  begin
    it := FInstances.ItemListFirst;
    while Assigned(it) do
    begin
      it.Item.ProdParentScale := GetProdScaleInstance(it.Item);
      FModalLevel := old_ml;
      Scene.InstanceBeforeChangeKey(it.Item);
      FModalLevel := ml;
      FScene.InstanceTransform(BaseInstance, false);
      //FScene.OnAfterChangeKeyGI(it.Item);
      it := it.Next;
    end;
  end;

  FModalLevel := ml;
  if Assigned(FParent) then
  begin
    if Assigned(FParent.StencilParent) or Assigned(FStencilParent) then
      FParent.CheckChildrenOnStencil(FParent.StencilParent);
  end;
end;

procedure TGraphicObject.SetParentAllChildren(NewParent: TGraphicObject);
begin
  if (NewParent = Self) then
    exit;
  while Assigned(FChildren) and (FChildren.Count > 0) do
    FChildren.Items[FChildren.Count - 1].Parent := NewParent;
end;

procedure TGraphicObject.SetPosition(AValue: TVec3f);
begin
  SetPositionInstance(BaseInstance, AValue);
end;

procedure TGraphicObject.SetPositionInstance(Instance: PGraphicInstance; const AValue: TVec3f);
begin
  //if (Instance.Position = AValue) then
  //  exit;

  if FHavePositionLimits then
  begin
    if AValue.x < FPositionLimits.x_min then
      Instance.Position.x := FPositionLimits.x_min
    else
    if AValue.x > FPositionLimits.x_max then
      Instance.Position.x := FPositionLimits.x_max
    else
      Instance.Position.x := AValue.x;

    if AValue.y < FPositionLimits.y_min then
      Instance.Position.y := FPositionLimits.y_min
    else
    if AValue.y > FPositionLimits.y_max then
      Instance.Position.y := FPositionLimits.y_max
    else
      Instance.Position.y := AValue.y;

    if AValue.z < FPositionLimits.z_min then
      Instance.Position.z := FPositionLimits.z_min
    else
    if AValue.z > FPositionLimits.z_max then
      Instance.Position.z := FPositionLimits.z_max
    else
      Instance.Position.z := AValue.z;

    Instance.ModelMatrix.M3.x := Instance.Position.x;
    Instance.ModelMatrix.M3.y := Instance.Position.y;
    Instance.ModelMatrix.M3.z := Instance.Position.z;

  end else
  begin
    Instance.ModelMatrix.M3.x := AValue.x;
    Instance.ModelMatrix.M3.y := AValue.y;
    Instance.ModelMatrix.M3.z := AValue.z;
    Instance.Position := AValue;
  end;

  if UpdateCount <= 0 then
    FScene.InstanceTransform(Instance, false);
end;

procedure TGraphicObject.SetPositionLimits(const Value: TBox3f);
begin
  FPositionLimits := Value;
  FHavePositionLimits := true;
end;

procedure TGraphicObject.SetScale(const AValue: TVec3f);
var
  i: int32;
begin
  SetScaleInstance(BaseInstance, AValue);
  if Assigned(FChildren) then
  begin
    for i := 0 to FChildren.Count - 1 do
    begin
      FChildren.Items[i].UpdateProdScale;
    end;
  end;
end;

procedure TGraphicObject.SetScaleInstance(AInstance: PGraphicInstance; const AValue: TVec3f);
begin
  if AInstance.Scale = AValue then
    Exit;
  AInstance.Scale := AValue;
  UpdateProdScaleInstance(AInstance);
  GenerateModelMatrixFromAllTransformations(AInstance, true);
end;

procedure TGraphicObject.UpdateProdScale;
var
  inst: TListInstances.PListItem;
  i: int32;
begin
  UpdateProdScaleInstance(FBaseInstance);
  if Assigned(FInstances) then
  begin
    inst := FInstances.ItemListFirst;
    while Assigned(inst) do
    begin
      UpdateProdScaleInstance(inst.Item);
      inst := inst.Next;
    end;
  end;

  if Assigned(FChildren) then
    for i := 0 to FChildren.Count - 1 do
      FChildren.Items[i].UpdateProdScale;
end;

procedure TGraphicObject.UpdateProdScaleInstance(AInstance: PGraphicInstance);
begin
  if Assigned(Parent) then
    AInstance.ProdParentScale := Parent.BaseInstance.ProdParentScale*AInstance.Scale
  else
    AInstance.ProdParentScale := BaseInstance.Scale;
end;

procedure TGraphicObject.GenerateModelMatrixFromAllTransformations(Instance: PGraphicInstance; ASendEvent: boolean);
begin
  if UpdateCount > 0 then
    exit;
  QuaternionToMatrix(Instance^.ModelMatrix, Instance^.Quaternion);
  //Instance.ModelMatrixPosAngle := Instance^.ModelMatrix;

  if not(Instance^.Scale = IDENTITY_VEC3) then
  begin
    if FServiceScale <> 1.0 then
      MatrixScale(Instance^.ModelMatrix, Instance^.Scale.x*FServiceScale, Instance.Scale.y*FServiceScale, Instance^.Scale.z*FServiceScale)
    else
      MatrixScale(Instance^.ModelMatrix, Instance^.Scale.x, Instance.Scale.y, Instance^.Scale.z);
  end else
  if FServiceScale <> 1.0 then
    MatrixScale(Instance^.ModelMatrix, FServiceScale, FServiceScale, FServiceScale);

  Instance.ModelMatrix.M3.x := Instance^.Position.x;
  Instance.ModelMatrix.M3.y := Instance^.Position.y;
  Instance.ModelMatrix.M3.z := Instance^.Position.z;
  if ASendEvent then
    FScene.InstanceTransform(Instance, true);
end;

procedure TGraphicObject.SetOpacity(AValue: BSFloat);
begin
  if (FOpacity = AValue) then Exit;

  FOpacity := AValue;
  FScene.InstanceTransform(BaseInstance, false);
end;

procedure TGraphicObject.SetOwner(const Value: TObject);
begin
  FOwner := Value;
end;

procedure TGraphicObject.SetDragResolveInstance(Instance: PGraphicInstance; AValue: boolean);
begin
  if (Instance^.DragResolve = AValue) then
    exit;
  Instance^.DragResolve := AValue;
end;

procedure TGraphicObject.SetDragResolveRecursive(AValue: boolean);

  procedure SetGI(GI: TGraphicObject);
  var
    i: TListInstances.PListItem;
    k: int32;
  begin
    SetDragResolveInstance(BaseInstance, AValue);

    if Assigned(GI.Instances) then
      i := GI.Instances.ItemListFirst
    else
      i := nil;

    while Assigned(i) do
    begin
      SetDragResolveInstance(i^.Item, AValue);
      i := i^.Next;
    end;

    for k := 0 to GI.ChildrenCount - 1 do
      SetGI(GI.Child[k]);
  end;

begin
  SetGI(Self);
end;

procedure TGraphicObject.SetDrawAsTransparent(const Value: boolean);
begin
  if FDrawAsTransparent = Value then
    exit;
  FDrawAsTransparent := Value;
  FScene.ObjectChangeOrderDraw(Self);
end;

procedure TGraphicObject.SetDrawSides(const Value: TDrawSide);
var
  ds: TDrawSide;
  it: TListInstances.PListItem;
begin
  if FDrawSides = Value then
    exit;
  ds := FDrawSides;
  FScene.InstanceBeforeChangeKey(BaseInstance);
  if Assigned(FInstances) then
  begin
    it := FInstances.ItemListFirst;
    while Assigned(it) do
    begin
      FDrawSides := ds;
      FScene.InstanceBeforeChangeKey(it.Item);
      FDrawSides := Value;
      FScene.InstanceAfterChangeKey(it.Item);
      it := it.Next;
    end;
  end;
  FDrawSides := Value;
  FScene.InstanceAfterChangeKey(BaseInstance);
end;

procedure TGraphicObject.CheckChildrenOnStencil(ParentStencil: TGraphicObject);
var
  i: int32;
begin
  if Assigned(FChildren) then
    for i := 0 to FChildren.Count - 1 do
    begin
      if Assigned(ParentStencil) and ParentStencil.AsStencil then
        FChildren.Items[i].FStencilParent := ParentStencil
      else
        FChildren.Items[i].FStencilParent := nil;
      if not FChildren.Items[i].AsStencil then
        FChildren.Items[i].CheckChildrenOnStencil(ParentStencil);
    end;
end;

procedure TGraphicObject.SetHidden(const Value: boolean);
var
  li: TListInstances.PListItem;
begin
  SetHiddenInstance(BaseInstance, Value);
  if Assigned(FInstances) then
  begin
    li := FInstances.ItemListFirst;
    while Assigned(li) do
    begin
      SetHiddenInstance(li.Item, Value);
      li := li.Next;
    end;
  end;
end;

procedure TGraphicObject.SetHiddenInstance(Instance: PGraphicInstance; AValue: boolean);
begin
  if (Instance^.Hidden = AValue) then
    exit;
  Instance^.Hidden := AValue;
  FScene.InstanceTransform(Instance, false);
end;

procedure TGraphicObject.SetHiddenRecursive(AValue: boolean);

  procedure SetGI(GI: TGraphicObject);
  var
    i: TListInstances.PListItem;
    k: int32;
  begin
    SetHiddenInstance(GI.BaseInstance, AValue);
    if Assigned(GI.Instances) then
      i := GI.Instances.ItemListFirst
    else
      i := nil;

    while Assigned(i) do
    begin
      SetHiddenInstance(i^.Item, AValue);
      i := i^.Next;
    end;

    for k := 0 to GI.ChildrenCount - 1 do
      SetGI(GI.Child[k]);
  end;

begin
  SetGI(Self);
end;

procedure TGraphicObject.SetIsDrag(const Value: boolean);
begin
  if DragResolve then
  begin

    FScene.InstanceBeginDrag(BaseInstance, true);

  end else
    raise Exception.Create('DragResolve disabled!');
end;

function TGraphicObject.GetAbsolutePositionInstance(Instance: PGraphicInstance): TVec3f;
begin
  Result := TVec3f(Instance^.ProdStackModelMatrix.M3);
end;

procedure TGraphicObject.ChangedMesh;
begin

end;

procedure TGraphicObject.AddBeforeDrawMethod(const BeforeDrawMethod: TBeforeDrawMethod);
begin
  SetLength(FBeforeDrawMethods, Length(FBeforeDrawMethods) + 1);
  FBeforeDrawMethods[Length(FBeforeDrawMethods) - 1] := BeforeDrawMethod;
end;

constructor TGraphicObject.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  Assert(Assigned(AScene), 'Parametr "AScene" is not valid !!!');
  inherited Create;

  FDrawSides := dsAll;

  FPositionLimits.x_min := MinSingle;
  FPositionLimits.y_min := MinSingle;
  FPositionLimits.z_min := MinSingle;
  FPositionLimits.x_max := MaxSingle;
  FPositionLimits.y_max := MaxSingle;
  FPositionLimits.z_max := MaxSingle;

  FOwner := AOwner;
  FStaticObject := true;
  // object will out to screen only if he is closly than previous
  FDepthTestFunc := GL_LEQUAL;
  // default the depth test On
  FDepthTest := true;
  FOpacity := 1.0;
  FServiceScale := 1.0;
  FServiceScaleInv := 1.0;
  FBaseInstance := TInstanceManager.InstanceCreate(Self);
  FBaseInstance.BoundingBox.TagPtr := BaseInstance;
  FEventBeginDrag := CreateDragDropEvent;
  FParent := AParent;
  FScene := AScene;
  FBaseInstance.Owner := Self;
  BeginUpdateTransformations;
  FScene.ObjectAdd(Self);
  if Assigned(FParent) then
  begin
    FModalLevel := FParent.ModalLevel;
    FParent.AddChild(Self);
  end;
  EndUpdateTransformations;
end;

procedure TGraphicObject.DoMouseDblClick(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseDblClick) then
    FEventMouseDblClick.SendEvent(AMouseData);
end;

procedure TGraphicObject.DoMouseDown(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseDown) then
    FEventMouseDown.SendEvent(AMouseData);
end;

procedure TGraphicObject.DoMouseUp(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseUp) then
    FEventMouseUp.SendEvent(AMouseData);
end;

procedure TGraphicObject.DoMouseMove(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseMove) then
    FEventMouseMove.SendEvent(AMouseData);
end;

procedure TGraphicObject.DoMouseEnter(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseEnter) then
    FEventMouseEnter.SendEvent(AMouseData);
end;

procedure TGraphicObject.DoMouseLeave(const AMouseData: BMouseData);
begin
  if Assigned(FEventMouseLeave) then
    FEventMouseLeave.SendEvent(AMouseData);
end;


procedure TGraphicObject.DoKeyDown(const AKeyData: BKeyData);
begin
  if Assigned(FEventKeyDown) then
    FEventKeyDown.SendEvent(AKeyData);
end;

procedure TGraphicObject.DoKeyUp(const AKeyData: BKeyData);
begin
  if Assigned(FEventKeyUp) then
    FEventKeyUp.SendEvent(AKeyData);
end;

procedure TGraphicObject.DoKeyPress(const AKeyData: BKeyData);
begin
  if Assigned(FEventKeyPress) then
    FEventKeyPress.SendEvent(AKeyData);
end;

procedure TGraphicObject.DoChangeMVP(AInstance: Pointer; IsMeshShapeTransform: boolean);
begin
  if Assigned(FEventChangeMVP) then
    FEventChangeMVP.Send(AInstance, IsMeshShapeTransform);
end;

procedure TGraphicObject.DoBeginDrag(AInstance: PGraphicInstance; CheckDragParent: boolean);
begin
  AInstance.IsDrag := true;
  FEventBeginDrag.Send(AInstance, CheckDragParent);
end;

function TGraphicObject.DoDrag(AInstance: PGraphicInstance; CheckDragParent: boolean): boolean;
begin
  Result := Assigned(FEventDrag);
  if Result then
    FEventDrag.Send(AInstance, CheckDragParent);
end;

function TGraphicObject.DoDrop(AInstance: PGraphicInstance): boolean;
begin
  AInstance.IsDrag := false;
  Result := Assigned(FEventDrop);
  if Result then
    FEventDrop.Send(AInstance, false);
  //Instance^.Owner.FEventDrop.Send(Pointer(Instance));
  { after send event above can happen anything, including release owner of
    drch, that is why check that drch is not single reference }
  //if (drch <> nil) then
  //begin
  //  if (drch.References > 1) then
  //    drch.Send(Instance);
  //  drch := nil;
  //end;
end;

function TGraphicObject.DoDropChildren(AInstance: PGraphicInstance): boolean;
begin
  Result := Assigned(FEventDropChildren);
  if Result then
    FEventDropChildren.Send(AInstance, false);
end;

class function TGraphicObject.CreateMesh: TMesh;
begin
  Result := TMeshP.Create;
end;

procedure TGraphicObject.EndUpdateTransformations;
begin
  dec(UpdateCount);
  if UpdateCount <= 0 then
    GenerateModelMatrixFromAllTransformations(BaseInstance, true);
end;

function TGraphicObject.FindObject(const ACaption: string; SelfInclude: boolean): TGraphicObject;
var
  i: Integer;
begin
  if SelfInclude then
  begin
    if Caption = ACaption then
      exit(Self);
  end;

  if Assigned(FChildren) then
  begin
    for i := 0 to FChildren.Count - 1 do
    begin
      Result := FChildren.Items[i].FindObject(ACaption, true);
      if Assigned(Result) then
        exit;
    end;
  end;

  Result := nil;
end;

destructor TGraphicObject.Destroy;
begin

  Clear;

  if StencilTest then
    StencilTest := false;

  Shader := nil;

  ClearInstances;

  while Assigned(FChildren) and (FChildren.Count > 0) do
    FChildren.Items[FChildren.Count-1].Free;

  if Assigned(FParent) then
  begin
    FParent.RemoveChild(Self);
    FParent := nil;
  end;

  FScene.ObjectDelete(Self);

  FreeAndNil(FMesh);

  FEventMouseDblClick := nil;
  FEventMouseDown := nil;
  FEventMouseUp := nil;
  FEventMouseMove := nil;
  FEventMouseEnter := nil;
  FEventMouseLeave := nil;
  FEventKeyDown := nil;
  FEventKeyUp := nil;
  FEventKeyPress := nil;

  FEventChangeMVP := nil;
  FEventBeginDrag := nil;
  FEventDrag := nil;
  FEventDrop := nil;
  FEventDropChildren := nil;
  TInstanceManager.InstanceFree(FBaseInstance);

  inherited Destroy;
end;

function TGraphicObject.AddChild(AOwner: TObject; BaseType: TGraphicObjectClass; SrcMesh: TMesh): TGraphicObject;
begin
  Result := AddChild(AOwner, BaseType);
  Result.Mesh := SrcMesh;
end;

function TGraphicObject.AddChild(AOwner: TObject; BaseType: TGraphicObjectClass): TGraphicObject;
begin
  Result := BaseType.Create(AOwner, Self, FScene);
  { Assign parent shader if he equal nil }
  if (Result.Shader = nil) then
    Result.Shader := Shader;
end;

procedure TGraphicObject.Restore;
begin
end;

procedure TGraphicObject.RotateInstance(Instance: PGraphicInstance; Angle: BSFloat; Axel: TRotateSequence);
var
  delta: BSFloat;
begin
  delta := AngleEulerClamp(Angle - Instance^.Angle.p[int8(Axel)]);
  Instance.Angle.p[int8(Axel)] := Angle;
  Instance.Quaternion := QuaternionMult(bs.basetypes.QUATERNION_EULER_METHODS[Axel](delta), Instance.Quaternion);
  GenerateModelMatrixFromAllTransformations(Instance, true);
end;

procedure TGraphicObject.RemoveChild(Child: TGraphicObject);
begin
  FChildren.Remove(Child, otFromEnd);
  if (FChildren.Count = 0) then
    FreeAndNil(FChildren);
end;

function TGraphicObject.AddInstance(const Pos: TVec3f): PGraphicInstance;
begin
  if FInstances = nil then
    FInstances := TListInstances.Create;
  Result := TInstanceManager.InstanceCreate(Self);
  Result^._ItemList := FInstances.PushToBegin(Result);
  Scene.InstanceCreate(Result);
  GenerateModelMatrixFromAllTransformations(Result, false);
  SetPositionInstance(Result, Pos);
  SetDragResolveInstance(Result, true);
end;

procedure TGraphicObject.ClearBeforeDrawListMethods;
begin
  SetLength(FBeforeDrawMethods, 0);
end;

procedure TGraphicObject.ClearInstances(Recursive: boolean; OnlyChildren: boolean);
var
  i, tmp: TListInstances.PListItem;
  j: Integer;
begin
  if not OnlyChildren then
  begin
    if Assigned(FInstances) then
    begin
      i := FInstances.ItemListFirst;
      // notify about remove all copy instances
      while Assigned(i) do
      begin
        tmp := i^.Next;
        DelInstance(i^.Item);
        i := tmp;
      end;
      FreeAndNil(FInstances);
    end;
  end;

  if Recursive then
    for j := 0 to ChildrenCount - 1 do
      Child[j].ClearInstances(Recursive);
end;

procedure TGraphicObject.Clear;
begin

  if Assigned(FMesh) then
    FMesh.Clear;

end;

procedure TGraphicObject.DelInstance(Instance: PGraphicInstance);
begin
  if Assigned(FInstances) and Assigned(Instance^._ItemList) then
    FInstances.Remove(Instance^._ItemList);
  FScene.InstanceDelete(Instance);
  TInstanceManager.InstanceFree(Instance);
end;

procedure TGraphicObject.DelBeforeDrawMethod(const BeforeDrawMethod: TBeforeDrawMethod);
var
  i, j: int32;
begin
  for i := 0 to Length(FBeforeDrawMethods) - 1 do
    if (@FBeforeDrawMethods[i]) = (@BeforeDrawMethod) then
    begin
      for j := i to Length(FBeforeDrawMethods) - 2 do
        FBeforeDrawMethods[j] := FBeforeDrawMethods[j+1];
      break;
    end;
  SetLength(FBeforeDrawMethods, Length(FBeforeDrawMethods) - 1);
end;

procedure TGraphicObject.DeleteChildren;

  procedure Del(Child: TGraphicObject);
  begin
    Child.DeleteChildren;
    Child.Free;
  end;

begin
  while Assigned(FChildren) do
    Del(FChildren.Items[FChildren.Count - 1]);
end;

procedure TGraphicObject.CalcActualBoundingBox(Instance: PGraphicInstance);
begin
  if Assigned(FMesh) then
  begin
    Instance^.BoundingBox.Max := FMesh.FBoundingBox.Max;
    Instance^.BoundingBox.Min := FMesh.FBoundingBox.Min;
    Box3Recalc(Instance^.BoundingBox, Instance^.ProdStackModelMatrix);
    Instance^.BoundingBox.IsPoint := FMesh.FBoundingBox.IsPoint;
  end else
    Instance^.BoundingBox.IsPoint := true;
end;

function TGraphicObject.GetCountParents: int32;
var
  p: TGraphicObject;
begin
  Result := 0;
  p := FParent;
  while Assigned(p) do
  begin
    inc(Result);
    p := p.Parent;
  end;
end;

function TGraphicObject.GetIsDrag: boolean;
begin
  Result := FBaseInstance.IsDrag;
end;

function TGraphicObject.GetDragResolve: boolean;
begin
  Result := FBaseInstance.DragResolve;
end;

function TGraphicObject.GetEventChangeMVP: IBChangeMVPEvent;
begin
  if FEventChangeMVP = nil then
    FEventChangeMVP := CreateChangeMvpEvent;
  Result := FEventChangeMVP;
end;

function TGraphicObject.GetEventDrag: IBDragDropEvent;
begin
  if FEventDrag = nil then
    FEventDrag := CreateDragDropEvent;
  Result := FEventDrag;
end;

function TGraphicObject.GetEventDrop: IBDragDropEvent;
begin
  if FEventDrop = nil then
    FEventDrop := CreateDragDropEvent;
  Result := FEventDrop;
end;

function TGraphicObject.GetEventDropChildren: IBDragDropEvent;
begin
  if FEventDropChildren = nil then
    FEventDropChildren := CreateDragDropEvent;
  Result := FEventDropChildren;
end;

function TGraphicObject.GetEventKeyDown: IBKeyDownEvent;
begin
  if FEventKeyDown = nil then
    FEventKeyDown := CreateKeyEvent;
  Result := FEventKeyDown;
end;

function TGraphicObject.GetEventKeyPress: IBKeyPressEvent;
begin
  if FEventKeyPress = nil then
    FEventKeyPress := CreateKeyEvent;
  Result := FEventKeyPress;
end;

function TGraphicObject.GetEventKeyUp: IBKeyUpEvent;
begin
  if FEventKeyUp = nil then
    FEventKeyUp := CreateKeyEvent;
  Result := FEventKeyUp;
end;

function TGraphicObject.GetEventMouseDblClick: IBMouseDblClickEvent;
begin
  if FEventMouseDblClick = nil then
    FEventMouseDblClick := CreateMouseEvent;
  Result := FEventMouseDblClick;
end;

function TGraphicObject.GetEventMouseDown: IBMouseDownEvent;
begin
  if FEventMouseDown = nil then
    FEventMouseDown := CreateMouseEvent;
  Result := FEventMouseDown;
end;

function TGraphicObject.GetEventMouseEnter: IBMouseEnterEvent;
begin
  if FEventMouseEnter = nil then
    FEventMouseEnter := CreateMouseEvent;
  Result := FEventMouseEnter;
end;

function TGraphicObject.GetEventMouseLeave: IBMouseLeaveEvent;
begin
  if FEventMouseLeave = nil then
    FEventMouseLeave := CreateMouseEvent;
  Result := FEventMouseLeave;
end;

function TGraphicObject.GetEventMouseMove: IBMouseMoveEvent;
begin
  if FEventMouseMove = nil then
    FEventMouseMove := CreateMouseEvent;
  Result := FEventMouseMove;
end;

function TGraphicObject.GetEventMouseUp: IBMouseUpEvent;
begin
  if FEventMouseUp = nil then
    FEventMouseUp := CreateMouseEvent;
  Result := FEventMouseUp;
end;

function TGraphicObject.GetHasStencilParent: boolean;
begin
  Result := GetStencilParent <> nil;
end;

function TGraphicObject.GetHidden: boolean;
begin
  Result := FBaseInstance.Hidden;
end;

function TGraphicObject.GetQuaternion: TQuaternion;
begin
  Result := FBaseInstance.Quaternion;
end;

function TGraphicObject.GetScaleSimple: BSFloat;
begin
  Result := (FBaseInstance.Scale.x + FBaseInstance.Scale.y + FBaseInstance.Scale.z)/3;
end;

function TGraphicObject.GetProdScaleInstance(AInstance: PGraphicInstance): TVec3f;
var
  p: TGraphicObject;
begin
  Result := AInstance.Scale;
  p := FParent;
  while Assigned(p) do
  begin
    Result := Result * p.BaseInstance.Scale;
    p := p.FParent;
  end;
end;

procedure TGraphicObject.SetAsSencil(AValue: boolean);
begin
  if FAsStencil = AValue then
    Exit;
  FAsStencil := AValue;
  if FAsStencil then
    FScene.ObjectIncStencilUse(Self)
  else
    FScene.ObjectDecStencilUse(Self);
  CheckChildrenOnStencil(Self);
end;

procedure TGraphicObject.SetServiceScale(AServiceScale: BSFloat);
begin
  if FServiceScale = AServiceScale then
    exit;

  FServiceScale := AServiceScale;
  FServiceScaleInv := 1.0/FServiceScale;

  GenerateModelMatrixFromAllTransformations(FBaseInstance, false);
  {if Assigned(FInstances) then
  begin
    item := FInstances.ItemListFirst;
    while Assigned(item) do
    begin
      inst := item.Item;
      item := item.Next;
      GenerateModelMatrixFromAllTransformations(inst);
    end;
  end; }
  ChangedMesh;
end;

{
function TBlackSharkSubGraphicItem.CreateVAO: boolean;
begin
  // Generate VBO Ids and load the VBOs with data
  if (VBO[TVBO.vVertexes] <> 0) then
    FreeVAO;
  glGenBuffers ( int8(high(TVBO))+1, @VBO );
  if (VBO[TVBO.vVertexes] = 0) then
    begin
    BSWriteMsg('TBlackSharkSubGraphicItem.CreateVAO', 'Can not create VBO!');
    exit(false);
    end;
  Result := true;
  glBindBuffer ( GL_ARRAY_BUFFER, VBO[TVBO.vVertexes] );
  glBufferData ( GL_ARRAY_BUFFER,
    FMesh.Vertexes.Count * SizeOf(FMesh.Vertexes.DefaultValue),
    FMesh.Vertexes.Data, GL_STATIC_DRAW);
  glBindBuffer ( GL_ELEMENT_ARRAY_BUFFER , VBO[TVBO.vIndexes]);    // GL_ELEMENT_ARRAY_BUFFER
  glBufferData ( GL_ELEMENT_ARRAY_BUFFER ,
    FMesh.Indexes.Count * SizeOf(FMesh.Indexes.DefaultValue),   // GL_ELEMENT_ARRAY_BUFFER
    FMesh.Indexes.Data, GL_STATIC_DRAW );
  glBindBuffer ( GL_ARRAY_BUFFER , VBO[TVBO.vTexture]);
  glBufferData ( GL_ARRAY_BUFFER , FMesh.UVCoords.Count * SizeOf(FMesh.UVCoords.DefaultValue),  // GL_ELEMENT_ARRAY_BUFFER
                 FMesh.UVCoords.Data, GL_STATIC_DRAW );
}
  // Bind the VAO and then set up the vertex
  // attributes
  {glBindVertexArray ( VAO );
  glBindBuffer(GL_ARRAY_BUFFER, VBO[TVBO.vVertexes]);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, VBO[TVBO.vIndexes]);
  glEnableVertexAttribArray(FOwner.FShader.PosCoordLoc);
  //glEnableVertexAttribArray(VERTEX_COLOR_INDX);
  glVertexAttribPointer ( FOwner.FShader.PosCoordLoc, 3,
    GL_FLOAT, GL_FALSE, SizeOf(TVec3f) , nil );
  }
  //glVertexAttribPointer ( VERTEX_COLOR_INDX, VERTEX_COLOR_SIZE,
  //  GL_FLOAT, GL_FALSE, VERTEX_STRIDE,
  //  (const void*) ( VERTEX_POS_SIZE * sizeof(GLfloat) ) );
//end;

{procedure TBlackSharkSubGraphicItem.FreeVAO;
begin
  if (VBO[vVertexes] > 0) then
    glDeleteBuffers(int8(high(TVBO))+1, @VBO);
  if (VAO > 0) then
    glDeleteVertexArrays(1,  @VAO);
end;
}

procedure TGraphicObject.SetDragResolve(AValue: boolean);
begin
  SetDragResolveInstance(BaseInstance, AValue);
end;

procedure TGraphicObject.SetModalLevel(AValue: int32);
var
	i, l: int32;
  it: TListInstances.PListItem;
begin
  if FModalLevel = AValue then
    exit;
  l := FModalLevel;
  FScene.InstanceBeforeChangeKey(BaseInstance);

  if Assigned(FInstances) then
  begin
    it := FInstances.ItemListFirst;
    while Assigned(it) do
    begin
      FModalLevel := l;
      FScene.InstanceBeforeChangeKey(it.Item);
      FModalLevel := AValue;
      FScene.InstanceAfterChangeKey(it.Item);
      it := it.Next;
    end;
  end;

  FModalLevel := AValue;
  FScene.InstanceAfterChangeKey(BaseInstance);
  if Assigned(FChildren) then
	  for i := 0 to FChildren.Count - 1 do
      FChildren.Items[i].ModalLevel := FModalLevel;
end;

procedure TGraphicObject.SetQuaternion(AValue: TQuaternion);
begin
  SetQuaternionInstance(BaseInstance, AValue);
end;

procedure TGraphicObject.SetScaleSimple(AValue: BSFloat);
begin
  SetScaleInstance(BaseInstance, vec3(AValue, AValue, AValue));
end;

procedure TGraphicObject.SetScene(const Value: TBScene);
var
  i: TListInstances.PListItem;
  j: Integer;
begin
  if Value = nil then
    raise Exception.Create('Property TGraphicObject.Scene can not be nil!');

  if FScene = Value then
    exit;

  if Assigned(FScene) then
  begin
    if Assigned(FInstances) then
    begin
      i := FInstances.ItemListFirst;
      // notify about remove all copy instances
      while Assigned(i) do
      begin
        FScene.InstanceDelete(i^.Item);
        i := i^.Next;
      end;
    end;
    // also notify about remove base instance
    FScene.ObjectDelete(Self);
  end;

  FScene := Value;

  if Assigned(Value) then
  begin
    FScene.ObjectAdd(Self);
    Value.InstanceTransform(BaseInstance, false);
    if Assigned(FInstances) then
    begin
      i := FInstances.ItemListFirst;
      while Assigned(i) do
      begin
        FScene.InstanceCreate(i^.Item);
        Value.InstanceTransform(i^.Item, false);
        i := i^.Next;
      end;
    end;
  end;
  for j := 0 to ChildrenCount - 1 do
    Child[j].Scene := Value;
end;

procedure TGraphicObject.SetSceneSpaceTreeClient(const Value: boolean);
var
  i: TListInstances.PListItem;
  j: Integer;
begin
  if FSceneSpaceTreeClient = Value then
    exit;
  FSceneSpaceTreeClient := Value;
  if FSceneSpaceTreeClient then
  begin
    if Assigned(FInstances) then
    begin
      i := FInstances.ItemListLast;
      while Assigned(i) do
      begin
        Scene.InstanceTransform(i.Item, false);
        Scene.InstanceSceneSpaceTreeClientChanged(i.Item);
        i := i.Prev;
      end;
    end;
    Scene.InstanceTransform(FBaseInstance, false);
    Scene.InstanceSceneSpaceTreeClientChanged(FBaseInstance);
  end else
  begin
    if Assigned(FInstances) then
    begin
      i := FInstances.ItemListLast;
      while Assigned(i) do
      begin
        Scene.Remove(i.Item.BVHNode, i);
        Scene.InstanceSceneSpaceTreeClientChanged(i.Item);
        i := i.Prev;
      end;
    end;
    if FBaseInstance.BVHNode >= 0 then
      Scene.Remove(FBaseInstance.BVHNode, FBaseInstance);
    Scene.InstanceSceneSpaceTreeClientChanged(FBaseInstance);
  end;

  for j := 0 to ChildrenCount - 1 do
  begin
    Child[j].SceneSpaceTreeClient := Value;
  end;
end;

procedure TGraphicObject.SetMesh(AValue: TMesh);
begin
  if FMesh = AValue then
    exit;
  //FMesh.Free;
  FMesh := AValue;
  if Assigned(FMesh) then
    ChangedMesh;
end;

procedure TGraphicObject.SetStaticObject(const Value: boolean);
begin
  if FStaticObject = Value then
    exit;
  FStaticObject := Value;
  if Assigned(FMesh) then
    ChangedMesh;
end;

procedure TGraphicObject.SetStensilTest(const Value: boolean);
begin
  if FStencilTest = Value then
    exit;
  FStencilTest := Value;
  if FStencilTest then
  begin
    FStencilParent := GetStencilParent;
    if FStencilParent = nil then
      raise Exception.Create('Can not used in a stencil test without Parent-stencil!');
  end else
    FStencilParent := nil;
end;

procedure TGraphicObject.SetStensilTestRecursive(AValue: boolean);
var
  i: int32;
begin
  SetStensilTest(AValue);
  for i := 0 to ChildrenCount - 1 do
    Child[i].SetStensilTestRecursive(AValue);
end;

function TGraphicObject.AddChild(Child: TGraphicObject): TGraphicObject;
begin
  if FChildren = nil then
    FChildren := TListGraphicObjects.Create(@PtrCmp);
  FChildren.Add(Child);
  Result := Child;
  Child.ModalLevel := FModalLevel;
end;

{ TBScene }

constructor TBScene.Create;
begin
  inherited Create;
  StackGI := TListVecInstances.Create;
  FGraphicObjects := THashTableGraphicObjects.Create(@GetHashBlackSharkPointer, @PtrCmpBool, 10000);

  FEventInstanceSelect := CreateEmptyEvent;
  FEventInstanceTransform := CreateEmptyEvent;
  FEventInstanceCreate := CreateEmptyEvent;
  FEventInstanceDelete := CreateEmptyEvent;
  FEventInstanceBeforeChangeKey := CreateEmptyEvent;
  FEventInstanceAfterChangeKey := CreateEmptyEvent;
  FEventInstanceBeginDrag := CreateDragDropEvent;
  FEventObjectChangeOrderDraw := CreateEmptyEvent;
  FEventObjectIncStencilUse := CreateEmptyEvent;
  FEventObjectDecStencilUse := CreateEmptyEvent;
  FEventInstanceSceneSpaceTreeClientChanged := CreateEmptyEvent;

end;

procedure TBScene.InstanceBeforeChangeKey(Instance: PGraphicInstance);
begin
  EventInstanceBeforeChangeKey.Send(Instance);
end;

procedure TBScene.InstanceAfterChangeKey(Instance: PGraphicInstance);
begin
  EventInstanceAfterChangeKey.Send(Instance);
end;

procedure TBScene.InstanceBeginDrag(Instance: PGraphicInstance; CheckDragParent: boolean);
begin
  EventInstanceBeginDrag.Send(Instance, CheckDragParent);
end;

procedure TBScene.InstanceCreate(Instance: PGraphicInstance);
begin
  EventInstanceCreate.Send(Instance);
end;

procedure TBScene.InstanceSceneSpaceTreeClientChanged(Instance: PGraphicInstance);
begin
  FEventInstanceSceneSpaceTreeClientChanged.Send(Instance);
end;

procedure TBScene.InstanceSetSelected(Instance: PGraphicInstance; Selected: boolean);
begin
  Instance.IsSelected := Selected;
  EventInstanceSelect.Send(Instance);
end;

procedure TBScene.ObjectIncStencilUse(AObject: TGraphicObject);
begin
  FEventObjectIncStencilUse.Send(AObject);
end;

procedure TBScene.ObjectDecStencilUse(AObject: TGraphicObject);
begin
  FEventObjectDecStencilUse.Send(AObject);
end;

function TBScene.ObjectAdd(AClassGraphicObject: TGraphicObjectClass; AParent: TGraphicObject; AOwner: TObject): TGraphicObject;
begin
  Result := AClassGraphicObject.Create(AOwner, AParent, Self);
end;

procedure TBScene.ObjectChangeOrderDraw(AObject: TGraphicObject);
begin
  FEventObjectChangeOrderDraw.Send(AObject);
end;

destructor TBScene.Destroy;
begin
  Clear;
  StackGI.Free;
  FGraphicObjects.Free;
  inherited Destroy;
end;

procedure TBScene.Clear;
var
  bucket: THashTable<Pointer, TGraphicObject>.TBucket;
begin

  if FGraphicObjects.GetFirst(bucket) then
  repeat
    FreeAndNil(bucket.Value);
  until not FGraphicObjects.GetNext(bucket);

  inherited Clear;
end;

procedure TBScene.ObjectAdd(AItem: TGraphicObject);
begin
  FGraphicObjects.Items[AItem] := AItem;
  InstanceCreate(AItem.BaseInstance);
end;

procedure TBScene.ObjectDelete(AItem: TGraphicObject);
begin
  InstanceDelete(AItem.BaseInstance);
  FGraphicObjects.Delete(AItem);
end;

procedure TBScene.InstanceDelete(Instance: PGraphicInstance);
begin
  Remove(Instance.BVHNode, Instance);
  FEventInstanceDelete.Send(Instance);
end;

procedure TBScene.InstanceTransform(Instance: PGraphicInstance; IsMeshShapeTransform: boolean);
var
  inst: PGraphicInstance;
  i: Integer;
  it: TListInstances.PListItem;
  count_now: int32;
  is_mesh: boolean;
begin
  count_now := 1;
  StackGI.Add(Instance);
  is_mesh := IsMeshShapeTransform;
  while count_now > 0 do
  begin
    inst := StackGI.Pop;
    dec(count_now);
    // change Children if only the inst is the FBaseInstance;
    if (inst.Owner.BaseInstance = inst) then
      for i := 0 to inst.Owner.ChildrenCount - 1 do
      begin
        inc(count_now);
        StackGI.Add(inst.Owner.Child[i].BaseInstance);
        if Assigned(inst.Owner.Child[i].Instances) then
          it := inst^.Owner.Child[i].Instances.ItemListFirst
        else
          it := nil;
        while Assigned(it) do
        begin
          inc(count_now);
          StackGI.Add(it.item);
          it := it.Next;
        end;
      end;
    inst.Owner.GenerateProdStackMatrix(inst);
    inc(inst.ChangeModelMatrix);
    if inst.Owner.SceneSpaceTreeClient then
      inst.BVHNode := UpdatePositionBB(inst, inst.BoundingBox, inst.BVHNode);
    FEventInstanceTransform.Send(inst);
    inst.Owner.DoChangeMVP(inst, is_mesh);
    is_mesh := false;
  end;
end;

end.

