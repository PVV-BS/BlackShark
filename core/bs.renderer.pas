{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised January, 2022

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

unit bs.renderer;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , Math
  , bs.basetypes
  , bs.math
  , bs.collections
  , bs.events
  , bs.scene
  , bs.gl.es
  , bs.frustum
  , bs.fbo
  , bs.shader
  , bs.texture
  , bs.graphics
  ;

type

  PRenderPass = ^TRenderPass;

  TRendererFunc = procedure (Pass: PRenderPass) of object;

  TRenderPass = record
    // if even nil then direct out to screen
    FrameBuffer: TBlackSharkFBO;
    SelfFrameFuffer: boolean;
    Shader: TBlackSharkShader;
    Renderer: TRendererFunc;
    Attachments: TAttachmentsFBO;
  end;

  TListRendererPasses = TSingleList<PRenderPass>;
  TListRendererPassesHead = TListRendererPasses.TSingleListHead;
  TFrameBufferKind = (fbFront, fbBack);

  TVBO = (vVertexes, vIndexes, vTexture);

  TKeySortInstance = record
    Distance: BSFloat;
    DrawOnlyFront: boolean;
    ModalLevel: int8;
  end;

  TMultiTreeGI = class(TBinTreeMultiValue<TKeySortInstance, PRendererGraphicInstance>)
  protected
    class function ComparatorValue(const V1, V2: PRendererGraphicInstance): boolean; static; inline;
  end;

  TMultiTreeGIFarToNear = class(TMultiTreeGI)
  protected
    class function ComparatorKey(const V1, V2: TKeySortInstance): int8; static; inline;
  public
    constructor Create;
  end;

  TMultiTreeGINearToFar = class(TMultiTreeGI)
  protected
    class function ComparatorKey(const V1, V2: TKeySortInstance): int8; static;
  public
    constructor Create;
  end;

  { It is mode blending }

  TBlendMode = (
    { without blend }
    bmNone,
    { result = texture.color * texture.color.alpha + buffer.color * (1 - texture.color.alpha),
      that is glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) }
    bmAlpha,
    { result = texture.color + buffer.color, that is glBlendFunc(GL_ONE, GL_ONE) }
    bmAdd,
    { result = texture.color + buffer.color * (1 - texture.color.alpha),
      that is glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); this is mode allow
      draw clear texture color without blend with a background  }
    bmAddAndBlend
  );

  TBlackSharkRenderer = class
  private
    FScene: TBScene;
    FOwnScene: boolean;

    FMouseLastPos: TVec2i;
    FMouseNowPos: TVec2i;
    FMouseBeginDragPos: TVec2i;
    FMouseButtonKeep: TBSMouseButton;
    FSmoothMSAA: boolean;
    FSmoothByKernelMSAA: boolean;
    FSmoothFXAA: boolean;
    FSmoothSharkSSAA: boolean;
    PassMSAA: PRenderPass;
    PassSSAA: PRenderPass;
    PassSharkSSAA: PRenderPass;
    PassFXAA: PRenderPass;
    { swaped frame buffers for draw to texture, for example - draw smooth pass }
    FrameBuffers: TListVec<TBlackSharkFBO>;
    CurrentFrameBuffer: int8;
    //FColorShader: TBlackSharkSingleColorToStencil;
    { B-tree Graphics Instances hitted into Frustum; the tree auto-ordered }
    FListGIinFrustum: array[boolean] of TMultiTreeGI;
    FWindowWidth: int32;
    FWindowHeight: int32;
    FPercentHeightInv: BSFloat;
    FPercentWidthInv: BSFloat;
    FVisibleGI: TListRendererInstances;
    LastDrawGI: TGraphicObject;
    LastCullFaceOption: TDrawSide;
    FCurrentUnderMouseInstance: PRendererGraphicInstance;
    FSelectedInstances: TListRendererInstances;
    FDragInstances: TListDual<PDragInstanceData>;
    FCountFRenderers: int8;
    FRenderers: TListRendererPassesHead;
    FScaleScreen: TVec2f;
    FScalePerimeterScreen: BSFloat;
    FScalePerimeterScreenInv: BSFloat;
    FScaleScreenLastDelta: TVec2f;
    FScreenRatio: BSFloat;
    FirstSize: TVec2f;
    FColor: TColor4f;
    FExactSelectObjects: boolean;
    FInstances: TListVec<PRendererGraphicInstance>;
    { for FPS count }
    FFPS: uint16;
    FLastUpdate: uint32;
    FCountFrame: uint16;

    {$region scene observers}
    ObsrvInstanceTransform: TEventInstanceTransformObserver;
    ObsrvInstanceSelect: TEventInstanceSelectObserver;
    ObsrvInstanceBeforChangeKey: TEventInstanceBeforeChangeKeyObserver;
    ObsrvInstanceAfterChangeKey: TEventInstanceAfterChangeKeyObserver;
    ObsrvInstanceCreate: TEventInstanceCreateObserver;
    ObsrvInstanceDelete: TEventInstanceDeleteObserver;
    ObsrvObjectChangeOrderDraw: IBEmptyEventObserver;
    ObsrvObjectIncStencilUse: IBEmptyEventObserver;
    ObsrvObjectDecStencilUse: IBEmptyEventObserver;
    ObsrvInstanceSceneSpaceTreeClientChanged: IBEmptyEventObserver;
    {$endregion}
  private
    { self events }
    FEventEventFocus: IBEmptyEvent;
    FEventResize: IBResizeWindowEvent;
    FEventMoveFrustum: IBEmptyEvent;
    { this mouse events to happen when the mouse cursor not hit to any of
    	PGraphicInstance, else call event for item under cursor }
    FEventMouseDown: IBMouseDownEvent;
    FEventMouseUp: IBMouseUpEvent;
    FEventMouseDblClick: IBMouseDblClickEvent;
    FEventMouseDblClickInEmptySite: IBMouseDblClickEvent;
    FEventMouseMove: IBMouseMoveEvent;
    FEventMouseWeel: IBMouseWeelEvent;

    FEventKeyDown: IBKeyDownEvent;
    FEventKeyUp: IBKeyUpEvent;
    FEventKeyPress: IBKeyPressEvent;

    FEventBeginDrag: IBDragDropEvent;
    FEventEndDrag: IBDragDropEvent;

    FMouseIsDown: boolean;
    FDragsObjects: boolean;
    FMouseDownInstance: PRendererGraphicInstance;
    //ScreenShortRenderer: PRenderPass;
    FModalLevel: int32;
    StensilTestOn: boolean;
    DepthTestOn: boolean;
    DepthTestFunc: uint16;
    FCountStencilUse: int32;
    FLastRayTrans: TRay3f;
    LastRayHit: TRay3f;

    FAutoSelect: boolean;
    FBlendMode: TBlendMode;
    FKernelSSAA: TSamplingKernel;
    FExactMesureDistanceToBB: boolean;
    { Scene does realeases }
    FReleases: boolean;
    FBanResetSelected: boolean;
    FKeyMultiSelectAllows: byte;
    BBSelectList: TListVec<Pointer>;
    FCountVisibleInstancesInSpaceTree: int32;
    procedure DoEventInstanceBeforeKeyChange(Instance: PRendererGraphicInstance); inline;
    procedure DoEventInstanceAfterKeyChange(Instance: PRendererGraphicInstance); inline;
    function DoEventInstanceCreate(Instance: PGraphicInstance): PRendererGraphicInstance;
    procedure DoEventInstanceTransform(AData: PRendererGraphicInstance); inline;

    {$region scene events }
    procedure EventInstanceTransform(const AData: BData);
    procedure EventInstanceSelect(const AData: BData);
    procedure EventInstanceBeforChangeKey(const AData: BData);
    procedure EventInstanceAfterChangeKey(const AData: BData);
    procedure EventInstanceCreate(const AData: BData);
    procedure EventInstanceDelete(const AData: BData);
    procedure EventInstanceSceneSpaceTreeClientChanged(const AData: BData);
    procedure EventObjectChangeOrderDraw(const AData: BData);
    procedure EventObjectIncStencilUse(const AData: BData);
    procedure EventObjectDecStencilUse(const AData: BData);
    procedure LinkSceneEvents;
    {$endregion scene events}
    procedure UpdateLastMVP(AInstance: PRendererGraphicInstance); inline;
    procedure UpdateAllLastMVP;
    procedure CalcFPS; inline;
  private
    { common method for a pass rendering; invoke from public method
    	TBlackSharkRenderer.Render }
    procedure DrawAnyPass(Pass: PRenderPass); inline;
    { draw all visible in scene geometry through DrawAllInstances }
    procedure DrawScene({%H-}Pass: PRenderPass); {$ifndef DEBUG_BS} inline; {$endif}
    { passes for Full Screen Anti Aliasing }
    procedure DrawPassMSAA(Pass: PRenderPass); {$ifndef DEBUG_BS} inline; {$endif}
    procedure DrawPassFXAA(Pass: PRenderPass); {$ifndef DEBUG_BS} inline; {$endif}
    procedure DrawPassSSAA(Pass: PRenderPass); {$ifndef DEBUG_BS} inline; {$endif}
    { draw a geometry single an instance TGraphicObject }
    procedure DrawInstance(Instance: PRendererGraphicInstance); {$ifndef DEBUG_BS} inline; {$endif}
    procedure DoBlendMode;
  private
    function GetSelectedItemsCount: uint32;
    function GetScreenSize: TVec2i;
    function GetCountVisibleGI: int32;
    function GetScreen2dCentre: TVec2i;
    { enumerator graphic items on change frustum }
    procedure EnumSingleVisibleObjectsByBVH (AInstance: PGraphicInstance; Distance: BSFloat); {$ifndef DEBUG_BS} inline; {$endif}
    procedure SetVisibleInstance(Instance: PRendererGraphicInstance; AValue: boolean); {$ifndef DEBUG_BS} inline; {$endif}
    procedure OnChangeFrustum;
    procedure SetBlendMode(AValue: TBlendMode); // inline;
    procedure SetSmoothByKernelMSAA(const Value: boolean);
    procedure SetSmoothMSAA(const AValue: boolean);
    procedure SetSmoothFXAA(const Value: boolean); // inline;
    procedure RecreateFrameBuffer;
    procedure SetSmoothSharkSSAA(const Value: boolean);
    procedure CreateFBOSharkSSAA;
    function GetNextFBO(Width, Height: int32; Attachments: TAttachmentsFBO; ColorFormat: int32): TBlackSharkFBO;
    procedure DecUsersFBO(FBO: TBlackSharkFBO);
    procedure DoMouseMove(X, Y: int32; Shift: TShiftState; SendEvent: boolean);
    procedure SetSelectedInstance(Instance: PRendererGraphicInstance; AValue: boolean);
  protected
    { Frustum, also called virtual Camera; you can change a position and an orientation
      in scene through apropriate properties this variable }
    FFrustum: TBlackSharkFrustum;
    { draw all instances hit into frustum; may used descendants for ralized self
      render pass }
    procedure DrawAllInstances;
    procedure SetScene(const AScene: TBScene); virtual;
    procedure RendererInit; virtual;
  public

    Keyboard: array[byte] of boolean;
    ShiftState: TShiftState;

    { can used any a render pass for draw a quad }
    procedure DrawQUAD(Pass: PRenderPass);
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    { render scene; call all added to list draw methods; draw all graphic items
      scene hit into frustum; NOT VIRTUAL, therefore ancestors need use AddRenderer for
      adding self method draw }
    procedure Render; overload;
    procedure Render(Pass: PRenderPass); overload;
    procedure RenderBefore(Pass: PRenderPass);

    procedure ModalLevelInc;
    procedure ModalLevelDec;

    procedure ResizeViewPort(NewWidth, NewHeight: int32); virtual;
    procedure MouseDblClick(X, Y: int32); virtual;
    procedure MouseDown({%H-}MouseButton: TBSMouseButton; X, Y: int32; Shift: TShiftState); virtual;
    procedure MouseUp({%H-}MouseButton: TBSMouseButton; X, Y: int32; Shift: TShiftState); virtual;
    procedure MouseMove(X, Y: int32; Shift: TShiftState); virtual;
    procedure MouseEnter({%H-}X, {%H-}Y: int32); virtual;
    procedure MouseLeave; virtual;
    procedure MouseWheel(WheelDelta: int32; X, Y: int32; {%H-}Shift: TShiftState); virtual;
    procedure KeyPress(var Key: WideChar; Shift: TShiftState); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState); virtual;

    function AddRenderer(
      Shader: TBlackSharkShader;
      Renderer: TRendererFunc;
      ViewPortWidth, ViewPortHeight: int32;
      FrameBuffer: TBlackSharkFBO = nil; UseFrameBuffer: boolean = false;
      Attachments: TAttachmentsFBO = [atColor, atDepth];
      ColorFormat: int32 = GL_RGBA): PRenderPass;

    procedure DelRenderer(Renderer: PRenderPass);

    function CheckInstanceHitIntoFrustum(Instance: PRendererGraphicInstance): boolean; {$ifndef DEBUG_BS} inline; {$endif}

    function GetObject(X, Y: int32): PRendererGraphicInstance; overload;
    function GetObject(const Ray: TRay3f; out Distance: BSFloat): PRendererGraphicInstance; overload;
    function HitTestInstance(const Ray: TRay3f; Instance: PGraphicInstance; out Distance: BSFloat): boolean; overload;
    function HitTestInstance(X, Y: int32; Instance: PGraphicInstance; out Distance: BSFloat): boolean; overload;
    function HitTestInstance(X, Y: int32; Instance: PGraphicInstance; out Point: TVec3f): boolean; overload;
    procedure ResetSelected(Exclude: PGraphicInstance = nil);
    procedure Restore; virtual;
    function Intersects(Instance: PGraphicInstance; const ScreenRect: TRectBSf; Exact: boolean): boolean;

    procedure BeginDragInstance(X, Y: int32; Instance: PRendererGraphicInstance; CheckDragParent: boolean);
    procedure DragSelected(const NewMousePos: TVec2i);
    procedure DropDragInstance(Instance: PRendererGraphicInstance);

    function IsVisible(Instance: PGraphicInstance): boolean; overload;
    function IsVisible(GraphicObject: TGraphicObject): boolean; overload;
    function SceneInstanceToRenderInstance(Instance: PGraphicInstance): PRendererGraphicInstance;
    { Create Ray at "ZERO" camera position to near frustum plane projection }
    function MakeRay(X, Y: int32): TRay3f; inline;
    { Resolution converters; although you can use TBlackSharkRenderer.SizePixelIn3D
    	for convert from 2D dimention to 3D }
    function SceneSizeToScreen(const Size: TVec2f): TVec2f;  overload;
    function SceneSizeToScreen(const Size: TVec3f): TVec2f;  overload;
    function SceneSizeToScreen(Size: BSFloat): BSFloat;  overload;

    function ScreenSizeToScene(const Size: TVec2i): TVec2f; overload;
    function ScreenSizeToScene(const Size: TVec2f): TVec2f; overload;
    function ScreenSizeToScene(Size: BSInt): BSFloat; overload;
    { converter 2d position to 3d with take into account position Frustum }
    function ScreenPositionToScene(const Pos: TVec2i; Layer: int32 = 0): TVec3f; overload;
    function ScreenPositionToScene(const Pos: TVec2f; Layer: int32 = 0): TVec3f; overload;
    function ScreenPositionToScene(X, Y: BSFloat; Layer: int32 = 0): TVec3f; overload;
    { return a point projection on screen }
    function ScenePositionToScreenf(const V: TVec3f): TVec2f; overload;
    function ScenePositionToScreenf(const AInstance: PGraphicInstance): TVec2f; overload;
    { return a point projection on screen in 3d }
    function ScenePositionToScreen3D(const v: TVec3f): TVec3f;
    { screen position (Near Plane Frustum) to dependency frustum position }
    function ScreenPosition: TVec3f; overload;
    { screen position (Near Plane Frustum) to dependency frustum position;
      layer allow set "distance over screen" }
    function ScreenPosition(Layer: int32): TVec3f; overload;
    { read screen picture in area Rect and RGBA format; result write to Buffer;
      Buffer must contains enough amount memory for write Rect.Width * Rect.Height * 4
      bytes; X, Y - higher left corner }
    procedure Screenshot(const Rect: TRectBSi; const Buffer: Pointer); overload;
    procedure Screenshot(const X, Y, Width, Height: int32; const Buffer: Pointer); overload;

    property Frustum: TBlackSharkFrustum read FFrustum;
    { if Renderers.Count > 0 then first pass always contains FBO
    	for translate result draw geometry to next passes as texture;
    	if Renderers.Count = 1 then first pass don't contains
    	FBO and need create new pass by TBlackSharkRenderer.AddRenderer if you
      want draw to texture }
    property Renderers: TListRendererPassesHead read FRenderers;

    property Scene: TBScene read FScene write SetScene;
    property OwnScene: boolean read FOwnScene write FOwnScene;

    property CountVisibleGI: int32 read GetCountVisibleGI;
    property CountVisibleInstancesInSpaceTree: int32 read FCountVisibleInstancesInSpaceTree;

    property SelectedItemsCount: uint32 read GetSelectedItemsCount;
    { after change Frustum will be empty until a new pass of the rendering;
      it is required for find out which objects don't hit into Frustum }
    property VisibleGI: TListRendererInstances read FVisibleGI;
    { if set true then select objects use strict geometric approach, else only hit to bounding box }
    property ExactSelectObjects: boolean read FExactSelectObjects write FExactSelectObjects;
    { method calculate distance from near the plane frustum to AABB objects;
      if setted in true then for evry point limited object calculate distance and
      select least value; else calculate distance only to middle AABB }
    property ExactMesureDistanceToBB: boolean read FExactMesureDistanceToBB write FExactMesureDistanceToBB;
    { change properties by call public procedure Resize() }
    property WindowWidth: int32 read FWindowWidth;
    property WindowHeight: int32 read FWindowHeight;
    property PercentWidthInv: BSFloat read FPercentWidthInv;
    property PercentHeightInv: BSFloat read FPercentHeightInv;
    property ScreenSize: TVec2i read GetScreenSize;
    property Screen2dCentre: TVec2i read GetScreen2dCentre;
    property ScalePerimeterScreen: BSFloat read FScalePerimeterScreen;
    property ScalePerimeterScreenInv: BSFloat read FScalePerimeterScreenInv;
    property ScaleScreen: TVec2f read FScaleScreen;
    //property ScaleScreenLastDelta: TVec2f read FScaleScreenLastDelta;
    //property ScreenRatio: BSFloat read FScreenRatio;
    property SmoothByKernelMSAA: boolean read FSmoothByKernelMSAA write SetSmoothByKernelMSAA;
    property KernelSSAA: TSamplingKernel read FKernelSSAA write FKernelSSAA;
    { multi sampling anti aliasing smooth }
    property SmoothMSAA: boolean read FSmoothMSAA write SetSmoothMSAA;
    property SmoothFXAA: boolean read FSmoothFXAA write SetSmoothFXAA;
    { smooth by draw to big Frame Buffer (more on 50 percent) and out to viewport size }
    property SmoothSharkSSAA: boolean read FSmoothSharkSSAA write SetSmoothSharkSSAA;
    property MouseLastPos: TVec2i read FMouseLastPos;
    property MouseNowPos: TVec2i read FMouseNowPos;
    property MouseBeginDragPos: TVec2i read FMouseBeginDragPos;
    property MouseButtonKeep: TBSMouseButton read FMouseButtonKeep;
    property MouseIsDown: boolean read FMouseIsDown;
    //property DrawToColorBuffer: boolean read FDrawToColorBuffer write SetDrawToColorBuffer;

    { background color }
    property Color: TColor4f read FColor write FColor;
    property CurrentUnderMouseInstance: PRendererGraphicInstance read FCurrentUnderMouseInstance;

    { Automatical select and drag/drop graphic object }
    property AutoSelect: boolean read FAutoSelect write FAutoSelect;
    property BlendMode: TBlendMode read FBlendMode write SetBlendMode;
    property ModalLevel: int32 read FModalLevel;
    property BanResetSelected: boolean read FBanResetSelected write FBanResetSelected;
    property KeyMultiSelectAllows: byte read FKeyMultiSelectAllows write FKeyMultiSelectAllows;
    property MouseDownInstance: PRendererGraphicInstance read FMouseDownInstance;
    property Instances: TListVec<PRendererGraphicInstance> read FInstances;
    ////////////////////////////////////////////////////////////////////////////
    ///  events
    property EventEventFocus: IBEmptyEvent read FEventEventFocus;
    property EventResize: IBResizeWindowEvent read FEventResize;
    property EventMoveFrustum: IBEmptyEvent read FEventMoveFrustum;
    { this mouse events to happen when the mouse cursor no hit to any of
    	PGraphicInstance, else call event for item under cursor }
    property EventMouseDblClick: IBMouseDblClickEvent read FEventMouseDblClick;
    property EventMouseDblClickInEmptySite: IBMouseDblClickEvent read FEventMouseDblClickInEmptySite;
    property EventMouseDown: IBMouseDownEvent read FEventMouseDown;
    property EventMouseUp: IBMouseUpEvent read FEventMouseUp;
    property EventMouseMove: IBMouseMoveEvent read FEventMouseMove;
    property EventMouseWeel: IBMouseWeelEvent read FEventMouseWeel;

    property EventKeyDown: IBKeyDownEvent read FEventKeyDown;
    property EventKeyUp: IBKeyUpEvent read FEventKeyUp;
    property EventKeyPress: IBKeyPressEvent read FEventKeyPress;

    property EventBeginDrag: IBDragDropEvent read FEventBeginDrag;
    property EventEndDrag: IBDragDropEvent read FEventEndDrag;
    property FPS: uint16 read FFPS;

  end;

implementation

uses
    SysUtils
  , bs.events.keyboard
  , bs.thread
  , bs.utils
  , bs.config
  , bs.geometry
  , bs.mesh
  {$ifdef DEBUG_BS}
  , bs.exceptions
  {$endif}
  ;

function InstanceKey(Instance: PRendererGraphicInstance): TKeySortInstance; inline;
begin
  Result.Distance := Instance.DistanceToScreen;
  Result.DrawOnlyFront := Instance.Instance.Owner.DrawSides = TDrawSide.dsFront;
  Result.ModalLevel := Instance.Instance.Owner.ModalLevel;
end;

{ TMultiTreeGI }

class function TMultiTreeGI.ComparatorValue(const V1, V2: PRendererGraphicInstance): boolean;
begin
  Result := V1 = V2;
end;

{ TMultiTreeGINearToFar }

class function TMultiTreeGINearToFar.ComparatorKey(const V1, V2: TKeySortInstance): int8;
begin
  if V1.ModalLevel = V2.ModalLevel then
  begin
    if V1.DrawOnlyFront <> V2.DrawOnlyFront then
    begin
      if V1.DrawOnlyFront then
        Result := 1
      else
        Result := -1;
    end else
    begin
      if V1.Distance > V2.Distance then
        Result := 1
    else
    if V1.Distance < V2.Distance then
      Result := -1
    else
      Result :=  0;
    end;
  end else
  if V1.ModalLevel > V2.ModalLevel then
    Result := -1
  else
    Result := 1;
end;

constructor TMultiTreeGINearToFar.Create;
begin
  inherited Create(ComparatorKey, ComparatorValue);
end;

{ TMultiTreeGIFarToNear }

class function TMultiTreeGIFarToNear.ComparatorKey(const V1, V2: TKeySortInstance): int8;
begin
  if V1.ModalLevel = V2.ModalLevel then
  begin
    if V1.DrawOnlyFront <> V2.DrawOnlyFront then
    begin
      if V1.DrawOnlyFront then
        Result := -1
      else
        Result := 1;
    end else
    begin
      if V1.Distance > V2.Distance then
        Result := -1
      else
      if V1.Distance < V2.Distance then
        Result := 1
      else
        Result := 0;
    end;
  end else
  if V1.ModalLevel > V2.ModalLevel then
    Result := 1
  else
    Result := -1;
end;

constructor TMultiTreeGIFarToNear.Create;
begin
  inherited Create(ComparatorKey, ComparatorValue);
end;

{ TBlackSharkRenderer }

constructor TBlackSharkRenderer.Create;
begin
  FLastUpdate := TBTimer.CurrentTime.Low;
  FInstances := TListVec<PRendererGraphicInstance>.Create;
  BBSelectList := TListVec<Pointer>.Create;
  FExactMesureDistanceToBB := false;
  FAutoSelect := true;
  FKeyMultiSelectAllows := VK_BS_CONTROL;
  LastCullFaceOption := dsAll;
  FrameBuffers := TListVec<TBlackSharkFBO>.Create;
  FScaleScreen := vec2(1.0, 1.0);
  FScalePerimeterScreen := 1.0;
  FScalePerimeterScreenInv := 1.0;
  FirstSize := vec2(BSConfig.ResolutionWidth, BSConfig.ResolutionHeight);
  TListRendererPasses.Create(FRenderers);
  FListGIinFrustum[false]  := TMultiTreeGIFarToNear.Create;
  FListGIinFrustum[true ]  := TMultiTreeGINearToFar.Create;
  FSelectedInstances       := TListRendererInstances.Create;
  FDragInstances           := TListDual<PDragInstanceData>.Create;
  FVisibleGI               := TListRendererInstances.Create;
  FFrustum                 := TBlackSharkFrustum.Create;
  FFrustum.OnChangeFrustum := OnChangeFrustum;

  FEventEventFocus    := CreateEmptyEvent;

  FEventMoveFrustum   := CreateEmptyEvent;
  FEventResize        := CreateResizeWindowEvent;

  FEventMouseDblClick := CreateMouseEvent;
  FEventMouseDown     := CreateMouseEvent;
  FEventMouseUp       := CreateMouseEvent;
  FEventMouseMove     := CreateMouseEvent;
  FEventMouseWeel     := CreateMouseEvent;
  FEventMouseDblClickInEmptySite := CreateMouseEvent;

  FEventKeyDown       := CreateKeyEvent;
  FEventKeyUp         := CreateKeyEvent;
  FEventKeyPress      := CreateKeyEvent;

  FEventBeginDrag     := CreateDragDropEvent;
  FEventEndDrag       := CreateDragDropEvent;

  //FEventBeforRender := CreateEmptyEvent;

  FColor := vec4(0.1764, 0.1764, 0.1764, 0.598);
  FKernelSSAA := skOutLine;
  FBlendMode := bmAlpha;
  FScene := TBScene.Create;
  FOwnScene := True;
  LinkSceneEvents;
  RendererInit;
end;

procedure TBlackSharkRenderer.CreateFBOSharkSSAA;
begin
  if FRenderers.Count = 1 then
  begin
    PassSharkSSAA := AddRenderer(BSShaderManager.Load('QUAD', TBlackSharkQUADShader),
      DrawQUAD, FWindowWidth*2, FWindowHeight*2, nil, false, [atColor, atDepth], GL_RGB);
  end;

  if FRenderers.Items[0].FrameBuffer = nil then
  begin
    FRenderers.Items[0].FrameBuffer := GetNextFBO(round(FWindowWidth)*2, round(FWindowHeight)*2, FRenderers.Items[0].Attachments, GL_RGBA);
  end else
  begin
    FRenderers.Items[0].FrameBuffer.ReCreate(round(FWindowWidth)*2, round(FWindowHeight)*2, FRenderers.Items[0].Attachments, GL_RGBA);
  end;
end;

destructor TBlackSharkRenderer.Destroy;
var
  i: int32;
begin
  FReleases := true;
  FEventEventFocus := nil;

  FEventMoveFrustum := nil;
  FEventResize := nil;

  FEventMouseDblClick := nil;
  FEventMouseDblClickInEmptySite := nil;
  FEventMouseDown := nil;
  FEventMouseUp := nil;
  FEventMouseMove := nil;
  FEventMouseWeel := nil;

  FEventKeyDown := nil;
  FEventKeyUp := nil;
  FEventKeyPress := nil;

  FSmoothSharkSSAA := false;

  if FOwnScene then
    FScene.Free;

  while (FRenderers.Count > 0) do
    DelRenderer(FRenderers.Items[FRenderers.Count - 1]);

  TListRendererPasses.Free(FRenderers);

  for i := 0 to FrameBuffers.Count - 1 do
    FrameBuffers.Items[i].Free;
  FrameBuffers.Free;
  FFrustum.Free;
  BBSelectList.Free;
  FListGIinFrustum[false].Free;
  FListGIinFrustum[true].Free;
  FVisibleGI.Free;
  FSelectedInstances.Free;
  while FDragInstances.Count > 0 do
    Dispose(FDragInstances.Pop);
  FDragInstances.Free;
  FInstances.Free;
  inherited;
end;

procedure TBlackSharkRenderer.DragSelected(const NewMousePos: TVec2i);
var
  inst: PGraphicInstance;
  v01, v02, delta, pos: TVec3f;
  d: BSFloat;
  dd: PDragInstanceData;
  r: TRay3f;
  pln: TVec4f;
  m3parent: TMatrix3f;
  intersect: boolean;
  m: TMatrix3f;
  cur: int32;
begin
  if NewMousePos = FMouseLastPos then
    exit;
  r := MakeRay(NewMousePos.x, NewMousePos.y);
  m := FFrustum.ViewMatrixInv;
  r.Position := FFrustum.ViewMatrixInv * r.Position;
  r.Direction := m * r.Direction;
  cur := 0;
  { so, FDragInstances.Cursor never position >= FDragInstances.Count - 1 do it
    through var cur }
  while (cur < FDragInstances.Count) do
  begin
    FDragInstances.Cursor := cur;
    dd := FDragInstances.UnderCursorItem.Item;
    inc(cur);

    if dd^.ParentDrag then
      continue;

    inst := dd^.Instance.Instance;
    pln := FFrustum.Frustum.P[TBoxPlanes.bpNear];
    pln.w := pln.w - dd^.BeginDragDistance;
    v01 := PlaneCrossProduct(pln, dd^.Ray.Position, dd^.Ray.Direction, d, intersect);
    v02 := PlaneCrossProduct(pln, r.Position, r.Direction, d, intersect);

    //if inst^.DragResolve then
    begin
      delta := v02 - v01;
      if delta = vec3(0.0, 0.0, 0.0) then
        continue;

      if Assigned(inst.Owner.Parent) then
      begin

        if (inst^.Owner.Parent.ServiceScaleInv <> 1.0) then
        begin
          m3parent := TMatrix3f(inst^.Owner.Parent.BaseInstance.ProdStackModelMatrix)*inst^.Owner.Parent.ServiceScaleInv;
          //m3parent.M[0, 0] := m3parent.M[0, 0]*inst^.Owner.Parent.MeshSizeScaleInv;
          //m3parent.M[1, 1] := m3parent.M[1, 1]*inst^.Owner.Parent.MeshSizeScaleInv;
          //m3parent.M[2, 2] := m3parent.M[2, 2]*inst^.Owner.Parent.MeshSizeScaleInv;
        end else
          m3parent := inst^.Owner.Parent.BaseInstance.ProdStackModelMatrix;

        MatrixInvert(m3parent);
         { if multiply back into "delta" then in FPC accept bad value (bag inline operators),
           therefor write to v01 }
        v01 := m3parent * delta;
      end else
        v01 := delta;

      pos := dd^.BeginDragPos + v01;
      inst^.Owner.SetPositionInstance(inst, pos);
      inst^.Owner.DoDrag(inst, false);
    end;
  end;
end;

procedure TBlackSharkRenderer.DoBlendMode;
begin
  case FBlendMode of
    { without blend }
    bmNone: begin
      glDisable(GL_BLEND);
    end;
    { result = texture.color * texture.color.alpha + buffer.color * (1 - texture.color.alpha),
      that is glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) }
    bmAlpha: begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end;
    { result = texture.color + buffer.color, that is glBlendFunc(GL_ONE, GL_ONE) }
    bmAdd: begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_ONE, GL_ONE);
    end;
    { result = texture.color + buffer.color * (1 - texture.color.alpha),
      that is glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); this is mode allow
      draw texture  }
    bmAddAndBlend: begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    end;
  end;
  //glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  //!!!glBlendFunc(GL_ONE, GL_ZERO);

  //glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendFuncSeparate(GL_ONE, GL_DST_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  // !!!glBlendFuncSeparate(GL_SRC_COLOR, GL_DST_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  //glBlendEquation(GL_FUNC_ADD);
end;

procedure TBlackSharkRenderer.DoEventInstanceAfterKeyChange(Instance: PRendererGraphicInstance);
begin
  if Instance.Visible then
    FListGIinFrustum[Instance.Instance.Owner.DrawAsTransparent].Add(InstanceKey(Instance), Instance);
end;

procedure TBlackSharkRenderer.DoEventInstanceBeforeKeyChange(Instance: PRendererGraphicInstance);
begin
  FListGIinFrustum[Instance.Instance.Owner.DrawAsTransparent].Remove(InstanceKey(Instance), Instance);
end;

function TBlackSharkRenderer.DoEventInstanceCreate(Instance: PGraphicInstance): PRendererGraphicInstance;
begin
  {$ifdef DEBUG_BS}
    if Assigned(FInstances.Items[Instance.Index]) then
      raise ERendererDebugError.Create('An instance with index ' + IntToStr(Instance.Index) + ' already exists!');
  {$endif}
  new(Result);
  FillChar(Result^, SizeOf(TRendererGraphicInstance), 0);
  Result.Instance := Instance;
  FInstances.Items[Instance.Index] := Result;
end;

procedure TBlackSharkRenderer.DoEventInstanceTransform(AData: PRendererGraphicInstance);
begin
  //if data.ChangeLastMVP = data.Instance.ChangeModelMatrix then
  //  exit;

  AData.ChangeLastMVP := AData.Instance.ChangeModelMatrix;

  UpdateLastMVP(AData);

  CheckInstanceHitIntoFrustum(AData);
end;

procedure TBlackSharkRenderer.DoMouseMove(X, Y: int32; Shift: TShiftState; SendEvent: boolean);
var
  inst: PRendererGraphicInstance;
  dd: PDragInstanceData;
  prnt: TGraphicObject;
  it: TListDual<PDragInstanceData>.PListItem;
  m_btns: TBSMouseButtons;
  item, next: TListRendererInstances.PListItem;
begin

  if ssLeft in Shift then
    m_btns := [TBSMouseButton.mbBsLeft]
  else
    m_btns := [];

  if ssRight in Shift then
    m_btns := m_btns + [TBSMouseButton.mbBsRight];

  if ssMiddle in Shift then
    m_btns := m_btns + [TBSMouseButton.mbBsMiddle];

  if (m_btns = []) and (FMouseIsDown) then
    MouseUp(FMouseButtonKeep, X, Y, Shift);

  FMouseNowPos := vec2(X, Y);
  ShiftState := Shift;
  //if not FEnabled then
  //  exit;
  if FMouseIsDown and not FDragsObjects and (FSelectedInstances.Count > 0) and
    Assigned(MouseDownInstance) and (FMouseButtonKeep = TBSMouseButton.mbBsLeft) and
      not (FMouseNowPos = FMouseLastPos) then
  begin
    FDragsObjects := true;
    if FAutoSelect then
    begin
      FMouseBeginDragPos := vec2(X, Y);
      item := FSelectedInstances.ItemListFirst;
      while Assigned(item) do
      begin
        next := item.Next;
        if item.Item.Instance.DragResolve then
          BeginDragInstance(X, Y, item.Item, false);
        item := next;
      end;

      { defines, dragged whether a parent }
      it := FDragInstances.ItemListFirst;
      while Assigned(it) do
      begin
        dd := it.Item;
        it := it.Next;
        prnt := dd.Instance.Instance.Owner.Parent;
        while Assigned(prnt) do
        begin
          if prnt.BaseInstance.IsDrag then
          begin
            dd^.ParentDrag := true;
            break;
          end;
          prnt := prnt.Parent;
        end;
      end;
    end;
    FEventBeginDrag.Send(nil, false);
  end;
  inst := GetObject(x, y);
  if FCurrentUnderMouseInstance <> inst then
  begin
    if Assigned(FCurrentUnderMouseInstance) then
      FCurrentUnderMouseInstance.Instance.Owner.DoMouseLeave(MouseData(FCurrentUnderMouseInstance, X, Y, 0, m_btns, Shift));

    if Assigned(inst) then
      inst.Instance.Owner.DoMouseEnter(MouseData(inst, X, Y, 0, m_btns, Shift));

    FCurrentUnderMouseInstance := inst;
  end;

  if SendEvent then
  begin
    if Assigned(inst) then
      inst.Instance.Owner.DoMouseMove(MouseData(inst, X, Y, 0, m_btns, Shift));
    EventMouseMove.Send(inst, X, Y, 0, m_btns, Shift);
  end;

  if FMouseIsDown and (FDragInstances.Count > 0) then
    DragSelected(vec2(X, Y));
  FMouseLastPos := vec2(X, Y);
end;

function TBlackSharkRenderer.GetCountVisibleGI: int32;
begin
  Result := FListGIinFrustum[false].MultiTree.Count + FListGIinFrustum[true].MultiTree.Count;
end;

function TBlackSharkRenderer.GetNextFBO(Width, Height: int32; Attachments: TAttachmentsFBO; ColorFormat: int32): TBlackSharkFBO;
var
  fbo: TBlackSharkFBO;
  i: int32;
begin
  Result := nil;
  i := CurrentFrameBuffer;
  if not (atStencil in Attachments) and (FCountStencilUse > 0) then
    Attachments := Attachments + [atStencil];

  if FrameBuffers.Count > 0 then
  repeat
    fbo := FrameBuffers.items[i];
    if (fbo.Width = Width) and (fbo.Height = Height)
      and (Attachments = fbo.Attachments) and (ColorFormat = fbo.Format) and
        ((FRenderers.Count < 2) or (FRenderers.Items[FRenderers.Count - 2].FrameBuffer <> fbo)) then
    begin
      Result := fbo;
      break;
    end;
    inc(i);
    i := i mod FrameBuffers.Count;
  until (i = CurrentFrameBuffer);

  if FrameBuffers.Count > 0 then
    CurrentFrameBuffer := (i + 1) mod FrameBuffers.Count;

  if Result = nil then
  begin
    Result := TBlackSharkFBO.Create(Width, Height, Attachments, ColorFormat);
    FrameBuffers.Add(Result);
  end;
  Result.IncUsers;
end;

function TBlackSharkRenderer.GetScreen2dCentre: TVec2i;
begin
  Result := vec2(FWindowWidth shr 1, FWindowHeight shr 1);
end;

function TBlackSharkRenderer.GetSelectedItemsCount: uint32;
begin
  Result := FSelectedInstances.Count;
end;

function TBlackSharkRenderer.GetScreenSize: TVec2i;
begin
  Result := vec2(WindowWidth, WindowHeight);
end;

procedure TBlackSharkRenderer.SetScene(const AScene: TBScene);
var
  bucket: THashTableGraphicObjects.TBucket;
  inst: TListInstances.PListItem;
begin
  if FScene = AScene then
    exit;
  if Assigned(FScene) and FOwnScene then
    FScene.Free;

  FOwnScene := false;
  FScene := AScene;

  if Assigned(FScene) then
    LinkSceneEvents;
  if FScene.GraphicObjects.GetFirst(bucket) then
  repeat
    DoEventInstanceTransform(DoEventInstanceCreate(bucket.Value.BaseInstance));
    if Assigned(bucket.Value.Instances) then
    begin
      inst := bucket.Value.Instances.ItemListFirst;
      while Assigned(inst) do
      begin
        DoEventInstanceTransform(DoEventInstanceCreate(inst.Item));
        inst := inst.Next;
      end;
    end;
  until not FScene.GraphicObjects.GetNext(bucket);
end;

function TBlackSharkRenderer.SceneInstanceToRenderInstance(Instance: PGraphicInstance): PRendererGraphicInstance;
begin
  Result := FInstances.Items[Instance.Index];
end;

procedure TBlackSharkRenderer.SetBlendMode(AValue: TBlendMode);
begin
  //if FBlendMode = AValue then Exit;
  FBlendMode := AValue;
  DoBlendMode;
end;

procedure TBlackSharkRenderer.SetSmoothFXAA(const Value: boolean);
var
  at: TAttachmentsFBO;
begin
  if FSmoothFXAA = Value then
    exit;
  FSmoothFXAA := Value;
  if FSmoothFXAA then
  begin
    if FRenderers.Count = 1 then
      at := [atColor, atDepth]
    else
      at := [atColor];
    PassFXAA := AddRenderer(BSShaderManager.Load('SmoothFXAA2', TBlackSharkSmoothFXAA),
      DrawPassFXAA, FWindowWidth, FWindowHeight, nil, true, at, GL_RGB);
  end else
  begin
    DelRenderer(PassFXAA);
    //CheckOrderSwapBuffers;
  end;
end;

procedure TBlackSharkRenderer.SetSmoothMSAA(const AValue: boolean);
var
  at: TAttachmentsFBO;
begin
  if FSmoothMSAA = AValue then
    exit;
  FSmoothMSAA := AValue;
  if FSmoothMSAA then
  begin
    if FRenderers.Count = 1 then
      at := [atColor, atDepth]
    else
      at := [atColor];
    PassMSAA := AddRenderer(BSShaderManager.Load('SmoothMSAA', TBlackSharkSmoothMSAA),
      DrawPassMSAA, FWindowWidth, FWindowHeight, nil, true, at, GL_RGB);
  end else
  begin
    DelRenderer(PassMSAA);
    //CheckOrderSwapBuffers;
  end;
end;

procedure TBlackSharkRenderer.SetSmoothSharkSSAA(const Value: boolean);
begin
  if FSmoothSharkSSAA = Value then
    exit;
  FSmoothSharkSSAA := Value;
  if FSmoothSharkSSAA then
  begin
    CreateFBOSharkSSAA;
  end else
  if PassSharkSSAA <> nil then
  begin
    DelRenderer(PassSharkSSAA);
    PassSharkSSAA := nil;
    if (FRenderers.Count > 1) and (FRenderers.Items[0].FrameBuffer <> nil) then
      FRenderers.Items[0].FrameBuffer.ReCreate(round(FWindowWidth), round(FWindowHeight),
        FRenderers.Items[0].Attachments, FRenderers.Items[0].FrameBuffer.Format) else
    //CheckOrderSwapBuffers;
  end else
  if (FRenderers.Items[0].FrameBuffer <> nil) then
  begin
    if FRenderers.Count > 1 then
      FRenderers.Items[0].FrameBuffer.ReCreate(round(FWindowWidth), round(FWindowHeight),
        FRenderers.Items[0].Attachments, FRenderers.Items[0].FrameBuffer.Format) else
    begin
      DecUsersFBO(FRenderers.Items[0].FrameBuffer);
      FRenderers.Items[0].FrameBuffer := nil;
    end;
    //CheckOrderSwapBuffers;
  end;
end;

procedure TBlackSharkRenderer.SetSmoothByKernelMSAA(const Value: boolean);
var
  at: TAttachmentsFBO;
begin
  if FSmoothByKernelMSAA = Value then
    exit;
  FSmoothByKernelMSAA := Value;
  if FSmoothByKernelMSAA then
  begin
    if FRenderers.Count = 1 then
      at := [atColor, atDepth]
    else
      at := [atColor];
    PassSSAA := AddRenderer(BSShaderManager.Load('SmoothByKernelMSAA', TBlackSharkSmoothByKernelMSAA),
      DrawPassSSAA, FWindowWidth, FWindowHeight, nil, true, at, GL_RGB);
  end else
  begin
    DelRenderer(PassSSAA);
    //CheckOrderSwapBuffers;
  end;
end;

procedure TBlackSharkRenderer.EventInstanceTransform(const AData: BData);
begin
  DoEventInstanceTransform(FInstances.Items[PGraphicInstance(AData.Instance).Index]);
end;

procedure TBlackSharkRenderer.EventInstanceSceneSpaceTreeClientChanged(const AData: BData);
begin
end;

procedure TBlackSharkRenderer.EventInstanceSelect(const AData: BData);
begin
  SetSelectedInstance(FInstances.Items[PGraphicInstance(AData.Instance).Index], PGraphicInstance(AData.Instance).IsSelected);
end;

procedure TBlackSharkRenderer.EventInstanceCreate(const AData: BData);
begin
  DoEventInstanceCreate(PGraphicInstance(AData.Instance));
end;

procedure TBlackSharkRenderer.EventInstanceBeforChangeKey(const AData: BData);
begin
  DoEventInstanceBeforeKeyChange(FInstances.Items[PGraphicInstance(AData.Instance).Index]);
end;

procedure TBlackSharkRenderer.EventInstanceAfterChangeKey(const AData: BData);
begin
  DoEventInstanceAfterKeyChange(FInstances.Items[PGraphicInstance(AData.Instance).Index]);
end;

procedure TBlackSharkRenderer.EventInstanceDelete(const AData: BData);
var
  data: PRendererGraphicInstance;
begin

  data := FInstances.Items[PGraphicInstance(AData.Instance).Index];

  if (FCurrentUnderMouseInstance = data) then
    FCurrentUnderMouseInstance := nil;

  if FMouseDownInstance = data then
    FMouseDownInstance := nil;

  if Assigned(data.Selected) then
    Scene.InstanceSetSelected(PGraphicInstance(AData.Instance), false);

  if Assigned(data.Drag) then
    DropDragInstance(data);

  if data.Visible then
    SetVisibleInstance(data, false);

  FInstances.Items[PGraphicInstance(AData.Instance).Index] := nil;
  dispose(data);

end;

procedure TBlackSharkRenderer.EventObjectChangeOrderDraw(const AData: BData);
var
  it: TListInstances.PListItem;
  k: TKeySortInstance;
  GraphicObject: TGraphicObject;
  data: PRendererGraphicInstance;
begin
  GraphicObject := AData.Instance;
  if Assigned(GraphicObject.Instances) then
  begin
    it := GraphicObject.Instances.ItemListFirst;
    while Assigned(it) do
    begin
      data := FInstances.Items[it.Item.Index];
      k := InstanceKey(data);
      FListGIinFrustum[not GraphicObject.DrawAsTransparent].Remove(k, data);
      FListGIinFrustum[GraphicObject.DrawAsTransparent].Add(k, data);
      it := it.Next;
    end;
  end;
  data := FInstances.Items[GraphicObject.BaseInstance.Index];
  FListGIinFrustum[not GraphicObject.DrawAsTransparent].Remove(InstanceKey(data), data);
  if data.Visible then
    FListGIinFrustum[GraphicObject.DrawAsTransparent].Add(InstanceKey(data), data);
end;

procedure TBlackSharkRenderer.Render;
var
  i: int32;
begin
  CalcFPS;
  //if Drawing then
  //  raise Exception.Create('called twice BlackSharkScene.Render !');

  BSShaderManager.UseShader(nil);
  BSTextureManager.UseTexture(nil);
  LastDrawGI := nil;
  for i := 0 to FRenderers.Count - 1 do
    DrawAnyPass(FRenderers.Items[i]);

end;

procedure TBlackSharkRenderer.Render(Pass: PRenderPass);
begin
  LastDrawGI := nil;
	DrawAnyPass(Pass);
end;

procedure TBlackSharkRenderer.RenderBefore(Pass: PRenderPass);
var
  render: PRenderPass;
  i: int32;
begin
  LastDrawGI := nil;
  for i := 0 to FRenderers.Count - 1 do
  begin
    render := FRenderers.Items[i];
    if render = Pass then
      break;
    DrawAnyPass(render);
  end;
end;

procedure TBlackSharkRenderer.RendererInit;
begin
  if FRenderers.Count = 0 then
    AddRenderer(nil, DrawScene, FWindowWidth, FWindowHeight, nil, false);
  RecreateFrameBuffer;
  DoBlendMode;
end;

procedure TBlackSharkRenderer.ModalLevelInc;
begin
  inc(FModalLevel);
end;

procedure TBlackSharkRenderer.ModalLevelDec;
begin
  dec(FModalLevel);
end;

procedure TBlackSharkRenderer.ResizeViewPort(NewWidth, NewHeight: int32);
var
  s: TVec2d;
begin
  if ((NewWidth < 5) or (NewHeight < 5)) then
    exit;
  //EventsManager.SendMessage('TBlackSharkRenderer.ResizeWindow', 'Width: '+IntToStr(NewWidth)+'; Height: ' + IntToStr(NewHeight));
  s.x := NewWidth / FirstSize.x;
  s.y := NewHeight / FirstSize.y;
  FScaleScreenLastDelta := s - FScaleScreen;
  FScaleScreen := s;
  FScreenRatio := NewWidth / NewHeight;
  FWindowWidth := NewWidth;
  FWindowHeight := NewHeight;
  FPercentWidthInv := 100/FWindowWidth;
  FPercentHeightInv := 100/FWindowHeight;
  FFrustum.BeginUpdate;
  FFrustum.ScaleRatio := FScaleScreen;
  FFrustum.EndUpdate;
  FScalePerimeterScreen := (FWindowWidth+FWindowHeight) / (FirstSize.x+FirstSize.y);
  FScalePerimeterScreenInv := 1/FScalePerimeterScreen;
  RendererInit;
  UpdateAllLastMVP;
  FEventResize.Send(Self, FWindowWidth, FWindowHeight, s.x, s.y);
end;

procedure TBlackSharkRenderer.RecreateFrameBuffer;
var
  i: int32;
begin

  if FRenderers.Items[0].FrameBuffer <> nil then
  begin
    if FSmoothSharkSSAA then
      FRenderers.Items[0].FrameBuffer.ReCreate(round(FWindowWidth)*2, round(FWindowHeight)*2, FRenderers.Items[0].FrameBuffer.Attachments)
    else
      FRenderers.Items[0].FrameBuffer.ReCreate(round(FWindowWidth), round(FWindowHeight), FRenderers.Items[0].FrameBuffer.Attachments);
  end;

  for i := 0 to FrameBuffers.Count - 1 do
    if FrameBuffers.Items[i] <> FRenderers.Items[0].FrameBuffer then
      FrameBuffers.Items[i].ReCreate(round(FWindowWidth), round(FWindowHeight), FrameBuffers.Items[i].Attachments);
end;

procedure TBlackSharkRenderer.CalcFPS;
var
  delta, t: uint32;
begin
  inc(FCountFrame);
  t := TBTimer.CurrentTime.Low;
  delta := t - FLastUpdate;
  if (delta > 999) then
  begin
    DivMod(FCountFrame, (delta div 1000), FFPS, FCountFrame);
    FLastUpdate := t;
  end;
end;

function TBlackSharkRenderer.CheckInstanceHitIntoFrustum(Instance: PRendererGraphicInstance): boolean;
begin
  if Assigned(Instance.Instance.Owner.Mesh) then
  begin
    if Instance.Visible then
      DoEventInstanceBeforeKeyChange(Instance);
    // check intersect with frustum
    if (Instance.Instance.Hidden) or (FFrustum.BoxCollision(Instance.Instance.BoundingBox, Instance.Instance.Owner.Mesh,
      Instance.Instance.ProdStackModelMatrix, Instance.DistanceToScreen) = coOutside) then
    begin
      Result := false;
      if Instance.Visible then
        SetVisibleInstance(Instance, false);
    end else
    begin
      Result := true;
      if Instance.Visible then
        DoEventInstanceAfterKeyChange(Instance)
      else
        SetVisibleInstance(Instance, true);
    end;
    if IsNan(Instance^.DistanceToScreen) then
      raise Exception.Create('Instance.DistanceToScreen is equal NAN! Check algorithm for calculate an object position!');
  end else
    Result := false;
end;

function TBlackSharkRenderer.AddRenderer(Shader: TBlackSharkShader;
  Renderer: TRendererFunc; ViewPortWidth, ViewPortHeight: int32;
  FrameBuffer: TBlackSharkFBO; UseFrameBuffer: boolean;
  Attachments: TAttachmentsFBO; ColorFormat: int32): PRenderPass;
var
  fbo: TBlackSharkFBO;
begin
  new(Result);
  Result^.FrameBuffer := FrameBuffer;
  if FrameBuffer = nil then
  begin
    Result^.SelfFrameFuffer := false;
    if UseFrameBuffer then
    begin
      if (FRenderers.Count > 0) and (FRenderers.Items[FRenderers.Count - 1].FrameBuffer = nil) then
      begin
        fbo := GetNextFBO(ViewPortWidth, ViewPortHeight, Attachments, ColorFormat);
        FRenderers.Items[FRenderers.Count - 1].FrameBuffer := fbo;
      end;
    end;
  end else
    Result^.SelfFrameFuffer := true;

  Result^.Shader := Shader;

  if Assigned(Shader) then
  	Shader._AddRef;

  Result^.Renderer := Renderer;
  Result^.Attachments := Attachments;
  TListRendererPasses.Add(FRenderers, Result);
  inc(FCountFRenderers);
  if Assigned(Result.FrameBuffer) then
    Result.FrameBuffer.Bind
  else
  begin
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, ViewPortWidth, ViewPortHeight);
  end;
end;

procedure TBlackSharkRenderer.EventObjectDecStencilUse;
var
  main_pass: PRenderPass;
begin
  if FReleases then
    exit;
  dec(FCountStencilUse);
  if (FCountStencilUse <= 0) then
  begin
    main_pass := FRenderers.Items[0];
    if Assigned(main_pass.FrameBuffer) and (atStencil in main_pass.FrameBuffer.Attachments) then
      main_pass.FrameBuffer.Attachments := main_pass.FrameBuffer.Attachments - [atStencil];
  end;
end;

procedure TBlackSharkRenderer.DecUsersFBO(FBO: TBlackSharkFBO);
var
  i: int32;
begin
  if FBO.DecUsers() = 0 then
  begin
    for i := 0 to FRenderers.Count - 1 do
      if FRenderers.Items[i].FrameBuffer = FBO then
      begin
        FRenderers.Items[i].FrameBuffer := nil;
      end;
    for i := 0 to FrameBuffers.Count - 1 do
      if FrameBuffers.Items[i] = FBO then
      begin
        FrameBuffers.Delete(i);
        if (CurrentFrameBuffer >= i) and (FrameBuffers.Count > 0) then
          CurrentFrameBuffer := CurrentFrameBuffer mod FrameBuffers.Count;
      end;
  end;
end;

procedure TBlackSharkRenderer.DelRenderer(Renderer: PRenderPass);
begin
  dec(FCountFRenderers);
  TListRendererPasses.Delete(FRenderers, Renderer);
  if Assigned(Renderer^.FrameBuffer) and (not Renderer^.SelfFrameFuffer) then
    DecUsersFBO(Renderer^.FrameBuffer);
  if Assigned(Renderer^.Shader) then
    BSShaderManager.FreeShader(Renderer^.Shader);
  dispose(Renderer);
  // set last render to draw direct to screen
  if (FRenderers.Count > 0) and (not FRenderers.Items[FRenderers.Count - 1]^.SelfFrameFuffer) and (FRenderers.Items[FRenderers.Count - 1]^.FrameBuffer <> nil) then
  begin
    DecUsersFBO(FRenderers.Items[FRenderers.Count - 1]^.FrameBuffer);
    if FSmoothSharkSSAA and (FRenderers.Count = 1) then
      CreateFBOSharkSSAA;
  end;
end;

procedure TBlackSharkRenderer.MouseDblClick(X, Y: int32);
var
  emp: boolean;
begin
  //if not FEnabled then
  //  exit;
  //FMouseIsDown := false;
  { so, FCurrentUnderMouseInstance can to become equal nil after send event below }
  emp := FCurrentUnderMouseInstance = nil;
  if (not emp) then
    FCurrentUnderMouseInstance.Instance.Owner.DoMouseDblClick(MouseData(FCurrentUnderMouseInstance, X, Y, 0, [FMouseButtonKeep], ShiftState));
  { now, if clicked on an empty point on the screen we send such event }
  if emp then
    FEventMouseDblClickInEmptySite.Send(FCurrentUnderMouseInstance, X, Y, 0, [FMouseButtonKeep], ShiftState);
  { and do not forget to send the common event about the double click }
  FEventMouseDblClick.Send(FCurrentUnderMouseInstance, X, Y, 0, [FMouseButtonKeep], ShiftState);
end;

procedure TBlackSharkRenderer.MouseDown(MouseButton: TBSMouseButton; X, Y: int32; Shift: TShiftState);
var
  inst: PRendererGraphicInstance;
begin
  ShiftState := Shift;
  FMouseNowPos := vec2(X, Y);
  if FMouseIsDown then
    MouseUp(MouseButton, X, Y, Shift);
  FMouseButtonKeep := MouseButton;
  FMouseIsDown := true;
  inst := GetObject(x, y);
  if (inst <> nil) then
  begin
    if (inst.Instance.Interactive) and FAutoSelect then
    begin
      if not Assigned(inst^.Selected) then //  and inst^.SelectResolve
      begin
        if not FBanResetSelected and not (Keyboard[FKeyMultiSelectAllows]) then
          ResetSelected;
        Scene.InstanceSetSelected(inst.Instance, true);
      end;
    end;
    FMouseDownInstance := inst;
    inst.Instance.Owner.DoMouseDown(MouseData(inst, X, Y, 0, [MouseButton], Shift));
    FEventMouseDown.Send(inst, X, Y, 0, [MouseButton], Shift);
  end else
  begin
    if not FBanResetSelected then
      ResetSelected;
    FEventMouseDown.Send(nil, X, Y, 0, [MouseButton], Shift);
  end;
  FMouseLastPos := vec2(X, Y);
end;

procedure TBlackSharkRenderer.MouseEnter(X, Y: int32);
begin
end;

procedure TBlackSharkRenderer.MouseLeave;
begin
  if Assigned(FCurrentUnderMouseInstance) then
  begin
    FCurrentUnderMouseInstance.Instance.Owner.DoMouseLeave(MouseData(FCurrentUnderMouseInstance, FMouseNowPos.X, FMouseNowPos.Y, 0, [], ShiftState));
    FCurrentUnderMouseInstance := nil;
  end;
end;

procedure TBlackSharkRenderer.MouseUp(MouseButton: TBSMouseButton; X, Y: int32; Shift: TShiftState);
begin
  ShiftState := Shift;
  FMouseIsDown := false;
  FMouseNowPos := vec2(X, Y);

  if Assigned(MouseDownInstance) then
  begin
    MouseDownInstance.Instance.Owner.DoMouseUp(MouseData(MouseDownInstance, X, Y, 0, [MouseButton], Shift));
    EventMouseUp.Send(MouseDownInstance, X, Y, 0, [MouseButton], Shift);
    FMouseDownInstance := nil;
  end else
    EventMouseUp.Send(nil, X, Y, 0, [MouseButton], Shift);

  FMouseLastPos := vec2(X, Y);
  FMouseButtonKeep := TBSMouseButton.mbBsLeft;
  if FDragsObjects then
  begin
    FDragsObjects := false;
    while FDragInstances.Count > 0 do
      DropDragInstance(FDragInstances.ItemListFirst^.Item.Instance);
    FEventEndDrag.Send(nil, false);
  end;
end;

procedure TBlackSharkRenderer.MouseWheel(WheelDelta: int32; X, Y: int32; {%H-}Shift: TShiftState);
begin
  EventMouseWeel.Send(nil, X, Y, WheelDelta, [], Shift);
  DoMouseMove(X, Y, Shift, false);
end;

procedure TBlackSharkRenderer.MouseMove(X, Y: int32; Shift: TShiftState);
begin
  DoMouseMove(X, Y, Shift, true);
end;

procedure TBlackSharkRenderer.KeyPress(var Key: WideChar; Shift: TShiftState);
var
  item, next: TListRendererInstances.PListItem;
begin
  ShiftState := Shift;
  if FSelectedInstances.Count > 0 then
  begin
    item := FSelectedInstances.ItemListFirst;
    while Assigned(item) do
    begin
      next := item.Next;
      if (item.Item.Instance.Interactive) then
        item.Item.Instance.Owner.DoKeyPress(KeyData(item.Item, word(Key), Shift));
      item := next;
    end;
  end;
  EventKeyPress.Send(nil, word(Key), Shift);
end;

procedure TBlackSharkRenderer.KeyDown(var Key: Word; Shift: TShiftState);
var
  item, next: TListRendererInstances.PListItem;
begin
  //if not FEnabled then
  //  exit;
  ShiftState := Shift;
  if Key < 256 then
    Keyboard[byte(Key)] := true;
  if FSelectedInstances.Count > 0 then
  begin
    item := FSelectedInstances.ItemListFirst;
    while Assigned(item) do
    begin
      next := item.Next;
      if (item.Item.Instance.Interactive) then
        item.Item.Instance.Owner.DoKeyDown(KeyData(item.Item, Key, Shift));
      item := next;
    end;
  end;
  EventKeyDown.Send(nil, Key, Shift);
end;

procedure TBlackSharkRenderer.KeyUp(var Key: Word; Shift: TShiftState);
var
  item, next: TListRendererInstances.PListItem;
begin
  //if not FEnabled then
  //  exit;
  ShiftState := Shift;
  if Key < 256 then
    Keyboard[byte(Key)] := false;
  if FSelectedInstances.Count > 0 then
  begin
    item := FSelectedInstances.ItemListFirst;
    while Assigned(item) do
    begin
      next := item.Next;
      if (item.Item.Instance.Interactive) then
        item.Item.Instance.Owner.DoKeyUp(KeyData(item.Item, Key, Shift));
      item := next;
    end;
  end;
  EventKeyUp.Send(nil, Key, Shift);
end;

procedure TBlackSharkRenderer.LinkSceneEvents;
begin
  ObsrvInstanceTransform := FScene.EventInstanceTransform.CreateObserver(GuiThread, EventInstanceTransform);
  ObsrvInstanceSelect := FScene.EventInstanceSelect.CreateObserver(GuiThread, EventInstanceSelect);
  ObsrvInstanceBeforChangeKey := FScene.EventInstanceBeforeChangeKey.CreateObserver(GuiThread, EventInstanceBeforChangeKey);
  ObsrvInstanceAfterChangeKey := FScene.EventInstanceAfterChangeKey.CreateObserver(GuiThread, EventInstanceAfterChangeKey);
  ObsrvInstanceCreate := FScene.EventInstanceCreate.CreateObserver(GuiThread, EventInstanceCreate);
  ObsrvInstanceDelete := FScene.EventInstanceDelete.CreateObserver(GuiThread, EventInstanceDelete);
  ObsrvInstanceSceneSpaceTreeClientChanged := FScene.EventInstanceSceneSpaceTreeClientChanged.CreateObserver(GuiThread, EventInstanceSceneSpaceTreeClientChanged);

  ObsrvObjectChangeOrderDraw := FScene.EventObjectChangeOrderDraw.CreateObserver(GuiThread, EventObjectChangeOrderDraw);
  ObsrvObjectIncStencilUse := FScene.EventObjectIncStencilUse.CreateObserver(GuiThread, EventObjectIncStencilUse);
  ObsrvObjectDecStencilUse := FScene.EventObjectDecStencilUse.CreateObserver(GuiThread, EventObjectDecStencilUse);
end;

function TBlackSharkRenderer.GetObject(X, Y: int32): PRendererGraphicInstance;
var
  Ray: TRay3f;
  Distance: BSFloat;
begin
  Ray := MakeRay(X, Y);
  Result := GetObject(Ray, Distance);
end;

function TBlackSharkRenderer.GetObject(const Ray: TRay3f; out Distance: BSFloat): PRendererGraphicInstance;
var
  min_dist: BSFloat;
  modal_lev: int32;
  Selected: PRendererGraphicInstance;
  it: TListRendererInstances.PListItem;
  tmp_dst: BSFloat;
begin
  min_dist := MaxSingle;
  modal_lev := 0;
  Selected := nil;
  it := FVisibleGI.ItemListLast;
  while Assigned(it) do
  begin
    Result := it.Item;
    it := it.Prev;
    if not Result.Instance.Interactive or (Result.Instance.Owner.ModalLevel < FModalLevel) then
      continue;
    if HitTestInstance(Ray, Result.Instance, Distance) and (min_dist > Distance) and (modal_lev <= Result.Instance.Owner.ModalLevel) then
    begin
      if Result.Instance.Owner.StencilTest and (Result.Instance.Owner.StencilParent <> nil) then
      begin
        { check a hit to box area }
        if not HitTestInstance(Ray, Result.Instance.Owner.StencilParent.BaseInstance, tmp_dst) then
        begin
          if Assigned(Result.Drag) then
            DropDragInstance(Result);
          if Assigned(Result.Selected) then
            Scene.InstanceSetSelected(Result.Instance, false);
          continue;
        end;
      end;
      min_dist := Distance;
      Selected := Result;
      modal_lev := Result.Instance.Owner.ModalLevel;
    end;
  end;
  Result := Selected;
end;

function TBlackSharkRenderer.HitTestInstance(X, Y: int32; Instance: PGraphicInstance; out Distance: BSFloat): boolean;
var
  Ray: TRay3f;
begin
  Ray := MakeRay(X, Y);
  Result := HitTestInstance(Ray, Instance, Distance);
end;

procedure TBlackSharkRenderer.EventObjectIncStencilUse;
var
  main_pass: PRenderPass;
begin
  if FReleases then
    exit;
  if (FCountStencilUse = 0) then
  begin
    main_pass := FRenderers.Items[0];
    if (main_pass.FrameBuffer <> nil) and not (atStencil in main_pass.FrameBuffer.Attachments) then
      main_pass.FrameBuffer.Attachments := main_pass.FrameBuffer.Attachments + [atStencil];
  end;
  inc(FCountStencilUse);
end;

function TBlackSharkRenderer.HitTestInstance(const Ray: TRay3f; Instance: PGraphicInstance; out Distance: BSFloat): boolean;
var
  k: int32;
  mvp: TMatrix4f;
  Shape: TMesh;
  Indexes: TListIndexes;
  v: TVec3f;
begin                             //Frustum.DISTANCE_2D_SCREEN
  Indexes := Instance^.Owner.Mesh.Indexes;
  if (Indexes.Count < 3) then
    exit(false);
  {if (Instance.Owner.ServiceScale <> 1.0) and (FScalePerimeterScreen <> 1.0) then
  begin
    s := IDENTITY_MAT;
    s.M[0, 0] := FScalePerimeterScreen;
    s.M[1, 1] := FScalePerimeterScreen;
    s.M[2, 2] := FScalePerimeterScreen;
    mvp := s * Instance.ProdStackModelMatrix;
    mvp := mvp * FFrustum.ViewMatrix;
  end else }
    mvp := Instance.ProdStackModelMatrix * FFrustum.ViewMatrix;
  // mvp := FFrustum.FTranslateMatrix * FFrustum.FRotateMatrix * Result.ProdStackModelMatrix;
  MatrixInvert(mvp);
  //
  mvp.V[15] := 1.0;
  FLastRayTrans.Position := mvp * Ray.Position;
  mvp.V4[3] := vec4(0.0, 0, 0, 0);
  FLastRayTrans.Direction := mvp * Ray.Direction;
  LastRayHit := Ray;
  // hit into the BB object
  if not RayIntersectBox(FLastRayTrans, @Instance^.Owner.Mesh.FBoundingBox, Distance) then
    exit(false);

  Shape := Instance^.Owner.Mesh;

  if not FExactSelectObjects or (Shape.DrawingPrimitive = GL_LINES) then
    exit(true);

  k := 0;
  //ptr := Shape.ShiftData[0];
  if Shape.DrawingPrimitive = GL_TRIANGLES then
  begin
    while k < Indexes.Count - 2 do
    begin
      if RayIntersectTriangle(FLastRayTrans, Shape.ReadPoint(Indexes.Items[k]),
        Shape.ReadPoint(Indexes.Items[k+1]), Shape.ReadPoint(Indexes.Items[k+2]), Distance) then
          exit(true);
      inc(k, 3);
    end;
  end else
  if Instance^.Owner.Mesh.DrawingPrimitive = GL_TRIANGLE_STRIP then
  begin
    for k := 0 to Indexes.Count - 3 do
    begin
      if RayIntersectTriangle(FLastRayTrans, Shape.ReadPoint(Indexes.Items[k]),
        Shape.ReadPoint(Indexes.Items[k+1]), Shape.ReadPoint(Indexes.Items[k+2]), Distance) then
          exit(true);
    end;
  end else
  begin  // GL_TRIANGLE_FAN
    v := Shape.ReadPoint(Indexes.Items[0]);
    for k := 1 to Indexes.Count - 2 do
    begin
      if RayIntersectTriangle(FLastRayTrans, v, Shape.ReadPoint(Indexes.Items[k]),
        Shape.ReadPoint(Indexes.Items[k+1]), Distance) then
          exit(true);
    end;
  end;
  { TODO: LINES }
  Result := false;
end;

function TBlackSharkRenderer.HitTestInstance(X, Y: int32; Instance: PGraphicInstance; out Point: TVec3f): boolean;
var
  dist: BSFloat;
begin
  Result := HitTestInstance(X, Y, Instance, dist);
  if Result then
    Point := FFrustum.Position + FFrustum.RotateMatrixInv * (LastRayHit.Direction*dist);
end;

function TBlackSharkRenderer.MakeRay(X, Y: int32): TRay3f;
begin
  Result.Direction := VecNormalize( TVec3f(vec3(
    (FFrustum.NearPlaneWidth * ( (x / FWindowWidth) - 0.5 )),
    (FFrustum.NearPlaneHeight * ( 0.5 - (y / FWindowHeight))),
    -FFrustum.DistanceNearPlane)) );
  Result.Position := vec3(0.0, 0.0, 0.0);
end;

procedure TBlackSharkRenderer.ResetSelected(Exclude: PGraphicInstance = nil);
var
  data: PRendererGraphicInstance;
begin

  if Assigned(Exclude) then
  begin
    data := FInstances.Items[Exclude.Index];
    FSelectedInstances.Remove(data.Selected);
  end else
    data := nil;

  while Assigned(FSelectedInstances.ItemListLast) do
  begin
    if Assigned(FSelectedInstances.ItemListLast.Item.Drag) then
      DropDragInstance(FSelectedInstances.ItemListLast.Item);

    Scene.InstanceSetSelected(FSelectedInstances.ItemListLast.Item.Instance, false);
  end;
  if Assigned(Exclude) then
    data.Selected := FSelectedInstances.PushToEnd(data);
end;

procedure TBlackSharkRenderer.Restore;
var
  it: TGraphicObject;
  bucket: THashTable<Pointer, TGraphicObject>.TBucket;
begin
  BSShaderManager.Restore;
  BSTextureManager.Restore;
  if FScene.GraphicObjects.GetFirst(bucket) then
  begin
    it := bucket.Value;
    while Assigned(it) do
    begin
      it.Restore;
      if FScene.GraphicObjects.GetNext(bucket) then
        it := bucket.Value
      else
        break;
    end;
  end;
end;

{
procedure TBlackSharkRenderer.SetDrawToColorBuffer(const Value: boolean);
begin
  FDrawToColorBuffer := Value;
  if FDrawToColorBuffer then
    begin
    if FColorShader = nil then
      FColorShader := TBlackSharkSingleColorToStencil(FShaderManager.Load('OSingleColor', TBlackSharkSingleColorToStencil));
    //if FColorBuffer = nil then
    //  FColorBuffer := CreateFrameBuffer(FWindowWidth, FWindowHeight);
    end else
    begin
    FShaderManager.FreeShader(FColorShader);
    FColorShader := nil;
    //FreeFrameBuffer(FColorBuffer);
    end;
end;}

procedure TBlackSharkRenderer.SetSelectedInstance(Instance: PRendererGraphicInstance; AValue: boolean);
begin
  if Assigned(Instance^.Selected) = AValue then
    exit;
  if AValue then
    Instance.Selected := FSelectedInstances.PushToEnd(Instance)
  else
    FSelectedInstances.Remove(Instance.Selected);
end;

procedure TBlackSharkRenderer.BeforeDestruction;
begin
  inherited;

end;

procedure TBlackSharkRenderer.BeginDragInstance(X, Y: int32; Instance: PRendererGraphicInstance; CheckDragParent: boolean);
var
  prnt: TGraphicObject;
  m: TMatrix3f;
begin
  if not Instance.Instance.DragResolve or Assigned(Instance^.Drag) then
    exit;

  if (not Assigned(Instance.Selected)) then
  begin
    if not Instance.Instance.SelectResolve then
      raise Exception.Create('SelectResolve disabled!');
    Scene.InstanceSetSelected(Instance.Instance, true);
  end;

  new(Instance^.Drag);
  Instance^.Drag^.Instance := Instance;
  Instance^.Drag^.BeginDragPos := Instance.Instance.Position;
  Instance^.Drag^.BeginDragMousePos := vec2(X, Y);
  PlanePointProjection(FFrustum.Frustum.P[TBoxPlanes.bpNear], TVec3f(Instance.Instance.ProdStackModelMatrix.M3), Instance^.Drag^.BeginDragDistance);
  Instance^.Drag^._list_item := FDragInstances.PushToEnd(Instance^.Drag);
  Instance^.Drag^.ParentDrag := false;
  Instance^.Drag^.Ray := MakeRay(Instance^.Drag^.BeginDragMousePos.x, Instance^.Drag^.BeginDragMousePos.y);
  Instance^.Drag^.Ray.Position := FFrustum.ViewMatrixInv * Instance^.Drag^.Ray.Position;
  { for define a direction take 3x3 matrix }
  m := FFrustum.ViewMatrixInv;
  Instance^.Drag^.Ray.Direction := m * Instance^.Drag^.Ray.Direction;
  { defines, dragged whether a parent }
  if CheckDragParent then
  begin
    prnt := Instance.Instance.Owner.Parent;
    while prnt <> nil do
    begin
      if Assigned(FInstances.Items[prnt.BaseInstance.Index].Drag) then
      begin
        Instance^.Drag^.ParentDrag := true;
        break;
      end;
      prnt := prnt.Parent;
    end;
  end;

  Instance.Instance.Owner.DoBeginDrag(Instance.Instance, false);

end;

procedure TBlackSharkRenderer.DropDragInstance(Instance: PRendererGraphicInstance);
var
  drag_parent: boolean;
  go: TGraphicObject;
begin
  if not Assigned(Instance.Drag) then
    exit;
  FDragInstances.Remove(Instance^.Drag^._list_item);
  drag_parent := Instance^.Drag.ParentDrag;
  dispose(Instance^.Drag);
  Instance.Drag := nil;
  if Instance.Instance.Owner.DoDrop(Instance.Instance) and (not drag_parent) then
  begin
    go := Instance.Instance.Owner.Parent;
    while go <> nil do
    begin
      if go.DoDropChildren(Instance.Instance) then
        break;
      go := go.Parent;
    end;
  end;
end;

procedure TBlackSharkRenderer.SetVisibleInstance(Instance: PRendererGraphicInstance; AValue: boolean);
begin
  if (Instance.Visible = AValue) then // or (Instance.Instance.Owner.Mesh = nil)
    exit;
  Instance.Visible := AValue;
  if AValue then
  begin
    FListGIinFrustum[Instance.Instance.Owner.DrawAsTransparent].Add(InstanceKey(Instance), Instance);
    if Instance.Instance.Owner.SceneSpaceTreeClient then
      inc(FCountVisibleInstancesInSpaceTree);
  end else
  begin
    FListGIinFrustum[Instance.Instance.Owner.DrawAsTransparent].Remove(InstanceKey(Instance), Instance);
    FVisibleGI.Remove(Instance._VisibleNode);
    if Instance.Instance.Owner.SceneSpaceTreeClient then
      dec(FCountVisibleInstancesInSpaceTree);
  end;
end;

procedure TBlackSharkRenderer.UpdateAllLastMVP;
var
  i: int32;
  inst: PRendererGraphicInstance;
begin
  for i := 0 to FInstances.Count - 1 do
  begin
    inst := FInstances.Items[i];
    if Assigned(inst) then
    begin
      inc(inst.ChangeLastMVP);
      UpdateLastMVP(inst);
    end;
  end;
end;

procedure TBlackSharkRenderer.UpdateLastMVP(AInstance: PRendererGraphicInstance);
{var
  mvp: TMatrix4f;     }
begin
  {if (FScalePerimeterScreen <> 1.0) and (AInstance.Instance.Owner.ServiceScale <> 1.0) then
  begin
    mvp.V[0] := AInstance.Instance.ProdStackModelMatrix.V[0]*FScalePerimeterScreen;
    mvp.V[1] := AInstance.Instance.ProdStackModelMatrix.V[1]*FScalePerimeterScreen;
    mvp.V[2] := AInstance.Instance.ProdStackModelMatrix.V[2]*FScalePerimeterScreen;
    mvp.V[3] := AInstance.Instance.ProdStackModelMatrix.V[3];

    mvp.V[4] := AInstance.Instance.ProdStackModelMatrix.V[4]*FScalePerimeterScreen;
    mvp.V[5] := AInstance.Instance.ProdStackModelMatrix.V[5]*FScalePerimeterScreen;
    mvp.V[6] := AInstance.Instance.ProdStackModelMatrix.V[6]*FScalePerimeterScreen;
    mvp.V[7] := AInstance.Instance.ProdStackModelMatrix.V[7];

    mvp.V[8] := AInstance.Instance.ProdStackModelMatrix.V[8]*FScalePerimeterScreen;
    mvp.V[9] := AInstance.Instance.ProdStackModelMatrix.V[9]*FScalePerimeterScreen;
    mvp.V[10] := AInstance.Instance.ProdStackModelMatrix.V[10]*FScalePerimeterScreen;
    mvp.V[11] := AInstance.Instance.ProdStackModelMatrix.V[11];
    mvp.M3 := AInstance.Instance.ProdStackModelMatrix.M3;
    AInstance.LastMVP := mvp * FFrustum.LastViewProjMat;
  end else  }
    AInstance.LastMVP := AInstance.Instance.ProdStackModelMatrix * FFrustum.LastViewProjMat;
end;

function TBlackSharkRenderer.Intersects(Instance: PGraphicInstance; const ScreenRect: TRectBSf; Exact: boolean): boolean;
var
  p: TBBPoints;
  v: TVec2f;
  right, bottom: BSFloat;
  k: int32;
  Indexes: TListIndexes;
  pos_max, pos_min: TVec2f;
  a, b, c, d: TVec2f;
  tri: TTriangle2f;
begin
  right := ScreenRect.X + ScreenRect.Width;
  bottom := ScreenRect.Y + ScreenRect.Height;
  Result := false;

  for p := Low(TBBPoints) to High(TBBPoints) do
  begin

    v := ScenePositionToScreenf(
      Instance.ProdStackModelMatrix * vec3(
        Instance.Owner.Mesh.FBoundingBox.Named[APROPRIATE_BB_POINTS[p, 0]],
        Instance.Owner.Mesh.FBoundingBox.Named[APROPRIATE_BB_POINTS[p, 1]],
        Instance.Owner.Mesh.FBoundingBox.Named[APROPRIATE_BB_POINTS[p, 2]]));

    if (v.x > ScreenRect.X) and (v.x < right) and (v.y > ScreenRect.Y) and (v.y < bottom) then
    begin
      Result := true;
      break;
    end;

    if p = Low(TBBPoints) then
    begin
      pos_max.x := v.x;
      pos_max.y := v.y;
      pos_min.x := v.x;
      pos_min.y := v.y;
    end else
    begin
      if pos_max.x < v.x then
        pos_max.x := v.x;
      if pos_max.y < v.y then
        pos_max.y := v.y;
      if pos_min.x > v.x then
        pos_min.x := v.x;
      if pos_min.y > v.y then
        pos_min.y := v.y;
    end;
  end;

  a := ScreenRect.Position;
  b := vec2(right, a.y);
  c := vec2(right, bottom);
  d := vec2(a.x, bottom);

  if not Result then
  begin
    Result :=
      LinesIntersectExclude(pos_min, vec2(pos_max.x, pos_min.y), a, b) or
      LinesIntersectExclude(pos_min, vec2(pos_max.x, pos_min.y), b, c) or
      LinesIntersectExclude(pos_min, vec2(pos_max.x, pos_min.y), c, d) or
      LinesIntersectExclude(pos_min, vec2(pos_max.x, pos_min.y), d, a) or

      LinesIntersectExclude(vec2(pos_max.x, pos_min.y), pos_max, a, b) or
      LinesIntersectExclude(vec2(pos_max.x, pos_min.y), pos_max, b, c) or
      LinesIntersectExclude(vec2(pos_max.x, pos_min.y), pos_max, c, d) or
      LinesIntersectExclude(vec2(pos_max.x, pos_min.y), pos_max, d, a) or

      LinesIntersectExclude(vec2(pos_min.x, pos_max.y), pos_max, d, a) or
      LinesIntersectExclude(vec2(pos_min.x, pos_max.y), pos_max, b, c) or
      LinesIntersectExclude(vec2(pos_min.x, pos_max.y), pos_max, c, d) or
      LinesIntersectExclude(vec2(pos_min.x, pos_max.y), pos_max, d, a) or

      LinesIntersectExclude(pos_min, vec2(pos_min.x, pos_max.y), a, b) or
      LinesIntersectExclude(pos_min, vec2(pos_min.x, pos_max.y), b, c) or
      LinesIntersectExclude(pos_min, vec2(pos_min.x, pos_max.y), c, d) or
      LinesIntersectExclude(pos_min, vec2(pos_min.x, pos_max.y), d, a)

      or

      RectContains(pos_min, pos_max, ScreenRect.Position) or
      RectContains(pos_min, pos_max, vec2(right, bottom)) or
      RectContains(pos_min, pos_max, vec2(right, ScreenRect.Position.y)) or
      RectContains(pos_min, pos_max, vec2(ScreenRect.Position.x, bottom));
  end;


  Indexes := Instance.Owner.Mesh.Indexes;
  if Result and Exact and (Indexes.Count > 2) then
  begin
    Result := false;
    k := 0;
    case Instance.Owner.Mesh.DrawingPrimitive of

      GL_TRIANGLES:
      while k < Indexes.Count - 2 do
      begin
        tri.A := ScenePositionToScreenf(Instance.ProdStackModelMatrix * Instance.Owner.Mesh.ReadPoint(Indexes.Items[k]));
        tri.B := ScenePositionToScreenf(Instance.ProdStackModelMatrix * Instance.Owner.Mesh.ReadPoint(Indexes.Items[k+1]));
        tri.C := ScenePositionToScreenf(Instance.ProdStackModelMatrix * Instance.Owner.Mesh.ReadPoint(Indexes.Items[k+2]));

        { the any triangle point inside the ScreenRect? }
        if ((tri.A.x > ScreenRect.X) and (tri.A.x < right) and (tri.A.y > ScreenRect.Y) and (tri.A.y < bottom)) or
            ((tri.B.x > ScreenRect.X) and (tri.B.x < right) and (tri.B.y > ScreenRect.Y) and (tri.B.y < bottom)) or
            ((tri.C.x > ScreenRect.X) and (tri.C.x < right) and (tri.C.y > ScreenRect.Y) and (tri.C.y < bottom)) then
              exit(true);

        { the any ScreenRect point inside the triangle? }
        if PointInsideTriangle(tri, a) or PointInsideTriangle(tri, b) or PointInsideTriangle(tri, c) or PointInsideTriangle(tri, d) then
          exit(true);

        { edges intersects? }
        if LinesIntersectExclude(tri.A, tri.B, a, b) or LinesIntersectExclude(tri.B, tri.C, a, b) or
           LinesIntersectExclude(tri.A, tri.B, b, c) or LinesIntersectExclude(tri.B, tri.C, b, c) or
           LinesIntersectExclude(tri.A, tri.B, c, d) or LinesIntersectExclude(tri.B, tri.C, c, d) or
           LinesIntersectExclude(tri.A, tri.B, d, a) or LinesIntersectExclude(tri.B, tri.C, d, a) then
              exit(true);

        inc(k, 3);
      end;

      GL_TRIANGLE_STRIP:
      while k < Indexes.Count do
      begin
        tri.A := tri.B;
        tri.B := tri.C;
        tri.C := ScenePositionToScreenf(Instance.ProdStackModelMatrix * Instance.Owner.Mesh.ReadPoint(Indexes.Items[k]));
        { the triangle of point C inside the ScreenRect? }
        if ((tri.C.x > ScreenRect.X) and (tri.C.x < right) and (tri.C.y > ScreenRect.Y) and (tri.C.y < bottom)) then
          exit(true);
        if k < 1 then
        begin
          inc(k);
          continue;
        end;

        { edges intersects? }
        if LinesIntersectExclude(tri.B, tri.C, a, b) or
           LinesIntersectExclude(tri.B, tri.C, b, c) or
           LinesIntersectExclude(tri.B, tri.C, c, d) or
           LinesIntersectExclude(tri.B, tri.C, d, a) then
            exit(true);

        if k < 2 then
        begin
          inc(k);
          continue;
        end;
        { the any ScreenRect point inside the triangle? }
        if PointInsideTriangle(tri, a) or PointInsideTriangle(tri, b) or PointInsideTriangle(tri, c) or PointInsideTriangle(tri, d) then
          exit(true);
        inc(k);
      end;

      GL_LINES, GL_LINE_STRIP, GL_LINE_LOOP: begin

        raise Exception.Create('TODO: TGraphicObject.Intersects - GL_LINES!!!');

        while k < Indexes.Count - 1 do
        begin

          inc(k, 2);
        end;

      end else
      begin // GL_TRIANGLE_FAN
        tri.A := ScenePositionToScreenf(Instance.ProdStackModelMatrix*Instance.Owner.Mesh.ReadPoint(Indexes.Items[0]));
        tri.B := ScenePositionToScreenf(Instance.ProdStackModelMatrix*Instance.Owner.Mesh.ReadPoint(Indexes.Items[1]));
        if ((tri.A.x > ScreenRect.X) and (tri.A.x < right) and (tri.A.y > ScreenRect.Y) and (tri.A.y < bottom)) or
            ((tri.B.x > ScreenRect.X) and (tri.B.x < right) and (tri.B.y > ScreenRect.Y) and (tri.B.y < bottom)) then
          exit(true);

        { edges intersects? }
        if LinesIntersectExclude(tri.A, tri.B, a, b) or
           LinesIntersectExclude(tri.A, tri.B, b, c) or
           LinesIntersectExclude(tri.A, tri.B, c, d) or
           LinesIntersectExclude(tri.A, tri.B, d, a) then
            exit(true);

        k := 2;
        while k < Indexes.Count - 1 do
        begin
          tri.B := tri.C;
          tri.C := ScenePositionToScreenf(Instance.ProdStackModelMatrix*Instance.Owner.Mesh.ReadPoint(Indexes.Items[k]));
          { the any triangle point inside the ScreenRect? }
          if ((tri.C.x > ScreenRect.X) and (tri.C.x < right) and (tri.C.y > ScreenRect.Y) and (tri.C.y < bottom)) then
            exit(true);
          { edges intersects? }
          if
             LinesIntersectExclude(tri.B, tri.C, a, b) or LinesIntersectExclude(tri.B, tri.C, b, c) or
             LinesIntersectExclude(tri.B, tri.C, c, d) or LinesIntersectExclude(tri.B, tri.C, d, a) or
             LinesIntersectExclude(tri.A, tri.C, a, b) or LinesIntersectExclude(tri.A, tri.C, b, c) or
             LinesIntersectExclude(tri.A, tri.C, c, d) or LinesIntersectExclude(tri.A, tri.C, d, a) then
            exit(true);
          { the any ScreenRect point inside the triangle? }
          if PointInsideTriangle(tri, a) or PointInsideTriangle(tri, b) or PointInsideTriangle(tri, c) or PointInsideTriangle(tri, d) then
            exit(true);
          inc(k);
        end;
      end;
      { TODO: LINES }
      //GL_LINES
    end;
  end;
end;

function TBlackSharkRenderer.IsVisible(GraphicObject: TGraphicObject): boolean;
begin
  Result := FInstances.Items[GraphicObject.BaseInstance.Index].Visible;
end;

function TBlackSharkRenderer.IsVisible(Instance: PGraphicInstance): boolean;
begin
  Result := FInstances.Items[Instance.Index].Visible;
end;

procedure TBlackSharkRenderer.EnumSingleVisibleObjectsByBVH(AInstance: PGraphicInstance; Distance: BSFloat);
var
  inst: PRendererGraphicInstance;
begin
  //if Drawing then
  //  raise Exception.Create('TBlackSharkRenderer.EnumSingleVisibleObjectsByBVH!');
  //if IsNan(Distance) then
  //  raise Exception.Create('Instance.DistanceToScreen to equal NAN! Check self an algorithm for calculate an object position!');
  inst := FInstances.Items[AInstance.Index];
  if inst^.Visible then
  begin
    DoEventInstanceBeforeKeyChange(inst);
    inst.DistanceToScreen := Distance;
    DoEventInstanceAfterKeyChange(inst);
  end else
    inst.DistanceToScreen := Distance;
  // update ProdStackModelMatrix and LastMVP
  UpdateLastMVP(inst);
  inc(inst^.ChangeLastMVP);
  if inst^.Visible then
  begin // old visible object
    // remove from FVisibleGI container; need for detect Hidden objects
    FVisibleGI.Remove(inst^._VisibleNode);
    exit;
  end;
  // new visible unit
  if not inst.Instance.Hidden then
    SetVisibleInstance(inst, true);
end;

procedure TBlackSharkRenderer.DrawAllInstances;
var
  it: TMultiTreeGI.TMultiValue;
  z, ok: boolean;
  i: int32;
begin
  for z := High(boolean) downto Low(boolean) do
  begin
    ok := FListGIinFrustum[z].MultiTree.Iterator.SetToBegin(it);
    while ok do
    begin
      for i := 0 to Length(it.Values) - 1 do
        DrawInstance(it.Values[i]);
      ok := FListGIinFrustum[z].MultiTree.Iterator.Next(it);
    end;
  end;
end;

procedure TBlackSharkRenderer.DrawInstance(Instance: PRendererGraphicInstance);
var
  i: int32;
begin
  if (Instance.Instance.Owner.Mesh = nil) or not Assigned(Instance.Instance.Owner.DrawInstance)
  	or (Instance.Instance.Owner.Mesh.Indexes.Count = 0) or (Instance.Instance.Owner.Shader = nil)
      then
    	  exit;

  if not Assigned(Instance^._VisibleNode) then
    Instance^._VisibleNode := FVisibleGI.PushToEnd(Instance);

  BSShaderManager.UseShader(Instance.Instance.Owner.Shader);
  if LastDrawGI <> Instance.Instance.Owner then
  begin
    if LastCullFaceOption <> Instance.Instance.Owner.DrawSides then
    begin
      LastCullFaceOption := Instance.Instance.Owner.DrawSides;
      case Instance.Instance.Owner.DrawSides of
        dsAll: begin
          glDisable(GL_CULL_FACE);
        end;

        dsFront: begin
          //glDisable(GL_DEPTH_TEST);
          glEnable(GL_CULL_FACE);
          glCullFace(GL_BACK);
          {if Instance^.Owner.FClockWiseCullFace then
            glFrontFace(GL_CW) else
            glFrontFace(GL_CCW);}
          //glCullFace(GL_FRONT_AND_BACK);
        end;

        dsBack: begin
          //glDisable(GL_DEPTH_TEST);
          glEnable(GL_CULL_FACE);
          glCullFace(GL_FRONT);
          {if Instance^.Owner.FClockWiseCullFace then
            glFrontFace(GL_CW) else
            glFrontFace(GL_CCW);}
          //glFrontFace(GL_CW);
          //glCullFace(GL_FRONT_AND_BACK);
        end;
      end;
    end;

    LastDrawGI := Instance.Instance.Owner;
    if LastDrawGI.AsStencil or LastDrawGI.StencilTest then
    begin
      // Enable the stencil tests
      if not StensilTestOn then
      begin
        glEnable( GL_STENCIL_TEST );
        //glClearStencil ( 0 );
        StensilTestOn := true;
      end;
    end else
    if StensilTestOn then
    begin
      StensilTestOn := false;
      glDisable( GL_STENCIL_TEST );
    end;

    if LastDrawGI.DepthTest then
    begin
      if not DepthTestOn then
      begin
        DepthTestOn := true;
        // On depth test
        glEnable(GL_DEPTH_TEST);
      end;

      if LastDrawGI.DepthTestFunc <> DepthTestFunc then
      begin
        glDepthFunc(LastDrawGI.DepthTestFunc);
        DepthTestFunc := LastDrawGI.DepthTestFunc;
      end;
    end else
    if DepthTestOn then
    begin
      DepthTestOn := false;
      // Off depth test
      glDisable(GL_DEPTH_TEST);
    end;

    for i := Length(LastDrawGI.BeforeDrawMethods) - 1 downto 0 do
      LastDrawGI.BeforeDrawMethods[i](LastDrawGI);

  end;

  LastDrawGI.DrawInstance(Instance);

  {$ifdef DEBUG_BS}
    CheckErrorGL('TBlackSharkRenderer.DrawInstance - Programm.UseProgram', TTypeCheckError.tcProgramm,
      Instance.Instance.Owner.Shader.ProgramID);
  {$endif}
end;

procedure TBlackSharkRenderer.DrawAnyPass(Pass: PRenderPass);
begin
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  if StensilTestOn then
  begin
    glDisable( GL_STENCIL_TEST );
    StensilTestOn := false;
  end;

  if Pass^.FrameBuffer = nil then
  begin
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, FWindowWidth, FWindowHeight);
    Pass^.Renderer(Pass);
  end else
  begin
    // out from texture to screen
    Pass^.FrameBuffer.Bind;
    Pass^.Renderer(Pass);
    // bind texture for next render pass
    if (Pass^.FrameBuffer.Texture > 0) then
    begin
      glActiveTexture(GL_TEXTURE0);
      glBindTexture(GL_TEXTURE_2D, Pass^.FrameBuffer.Texture);
    end;
  end;
end;

procedure TBlackSharkRenderer.DrawScene(Pass: PRenderPass);
begin
  //glEnable(GL_BLEND);
  //glBlendFunc(GL_ONE, GL_ONE);
  glClearColor(FColor.r, FColor.g, FColor.b, 0.0);
  //glClearColor(0.0, 0.0, 0.0, 0.0);
  if FCountStencilUse > 0 then
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
  else
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  DrawAllInstances;
end;



(*procedure TBlackSharkRenderer.DrawToColorBufferDo;
{var
  inst: PGraphicInstance;
  i: int32;
  guid_parent: TVec4f;}
begin
  LastUsedShader := nil;
  //glBindFramebuffer( GL_FRAMEBUFFER, FColorBuffer^.FrameBufferName );

  //glViewport(0, 0, FColorBuffer^.Width, FColorBuffer^.Height);
  glEnable(GL_STENCIL_TEST);
  glStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
  glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
  glClear( GL_STENCIL_BUFFER_BIT );
	//glClearColor( FColor.r, FColor.g, FColor.b, FColor.a );

  //glDisable( GL_BLEND );
  //glDisable( GL_TEXTURE_2D );

	//FColorShader.UseProgram;
  //{$ifdef DEBUG_BS}
  //if CheckErrorGL('TBlackSharkRenderer.DrawToColorBufferDo - FColorShader.UseProgram', TTypeCheckError.tcProgramm,  FColorShader.ProgramID) then
  //  exit;
  //{$endif}
  {
  for i := 0 to FListGIinFrustum[odFarToNear].Count - 1 do
    begin
    inst := FListGIinFrustum[odFarToNear].Items[i];
    if (inst^.Owner.Parent = nil) or (inst^.Owner.Parent.Shape = nil) or (inst^.Owner.Parent.Shape.FBoundingBox.IsPoint) then
      begin
      guid_parent.a := 0;
      end else
      guid_parent := inst^.Owner.Parent.FGUID;

    glUniform4fv(FColorShader.ColorParent^.Location, 1, @guid_parent );
    glUniform4fv(FColorShader.Color^.Location, 1, @inst^.Owner.FGUID );
    inst^.Owner.DrawInstance(inst);
    end;
  for i := 0 to FListGIinFrustum[odNearToFar].Count - 1 do
    begin
    inst := FListGIinFrustum[odNearToFar].Items[i];
    if (inst^.Owner.Parent = nil) or (inst^.Owner.Parent.Shape = nil) or (inst^.Owner.Parent.Shape.FBoundingBox.IsPoint) then
      begin
      guid_parent.a := 0;
      end else
      guid_parent := inst^.Owner.Parent.FGUID;

    glUniform4fv(FColorShader.ColorParent^.Location, 1, @guid_parent );
    glUniform4fv(FColorShader.Color^.Location, 1, @inst^.Owner.FGUID );
    inst^.Owner.DrawInstance(inst);
    end;
    }
end;*)

procedure TBlackSharkRenderer.DrawPassMSAA(Pass: PRenderPass);
var
  bm: TBlendMode;
begin
  bm := FBlendMode;
  SetBlendMode(TBlendMode.bmNone);
  glDisable(GL_DEPTH_TEST);
  DepthTestOn := false;
  Pass^.Shader.UseProgram;
  glUniform1fv(TBlackSharkSmoothMSAA(Pass^.Shader).RatioResolutions^.Location, 1, @BSConfig.VoxelSize);
  glVertexAttribPointer(
    TBlackSharkSmoothMSAA(Pass^.Shader).Position^.Location,     // attribute. No particular reason for 1, but must match the layout in the shader.
    3,                                    // size
    GL_FLOAT,                             // type
    GLboolean(GL_FALSE),                  // normalized?
    sizeof(TVec3f), // stride
    @QUAD_VERTEXES[0]                  // array buffer offset
  );
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  //glDrawElements(GL_TRIANGLES, 0, GL_UNSIGNED_SHORT, @QUAD_INDEXES[0]);
  glDisableVertexAttribArray(0);
  SetBlendMode(bm);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkRenderer.DrawPassMSAA', TTypeCheckError.tcNone, -1);
  {$endif}
end;

procedure TBlackSharkRenderer.DrawQUAD(Pass: PRenderPass);
var
  bm: TBlendMode;
begin
  //glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDisable(GL_DEPTH_TEST);
  DepthTestOn := false;
  bm := FBlendMode;
  if FBlendMode <> TBlendMode.bmNone then
    SetBlendMode(TBlendMode.bmNone);
  glDisable(GL_BLEND);
  glDisable( GL_STENCIL_TEST );
  StensilTestOn := false;
  //glClearColor(FColor.r, FColor.g, FColor.b, 0.0);
  //glClearColor(0.0, 0.0, 0.0, 0.0);
  glClear(GL_COLOR_BUFFER_BIT);
  BSShaderManager.UseShader(Pass^.Shader);
  glVertexAttribPointer(
    TBlackSharkQUADShader(Pass^.Shader).Position^.Location,     // attribute. No particular reason for 1, but must match the layout in the shader.
    3,                                    // size
    GL_FLOAT,                             // type
    GLboolean(GL_FALSE),                  // normalized?
    sizeof(TVec3f),
    @QUAD_VERTEXES[0]
  );
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glDisableVertexAttribArray(0);
  if bm <> TBlendMode.bmNone then
    SetBlendMode(bm);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkRenderer.DrawQUAD', TTypeCheckError.tcNone, -1);
  {$endif}
end;

procedure TBlackSharkRenderer.DrawPassFXAA(Pass: PRenderPass);
var
  bm: TBlendMode;
begin
  bm := FBlendMode;
  SetBlendMode(TBlendMode.bmNone);
  glDisable(GL_DEPTH_TEST);
  DepthTestOn := false;
  //glClear(GL_COLOR_BUFFER_BIT);
  Pass^.Shader.UseProgram;
  glUniform2f(TBlackSharkSmoothFXAA(Pass^.Shader).Resolution^.Location, FWindowWidth, FWindowHeight);
  glUniform2f(TBlackSharkSmoothFXAA(Pass^.Shader).ResolutionInv^.Location, 1/FWindowWidth, 1/FWindowHeight);
  glVertexAttribPointer(
    TBlackSharkSmoothFXAA(Pass^.Shader).Position^.Location,     // attribute. No particular reason for 1, but must match the layout in the shader.
    3,                                    // size
    GL_FLOAT,                             // type
    GLboolean(GL_FALSE),                  // normalized?
    sizeof(TVec3f), // stride
    @QUAD_VERTEXES[0]                  // array buffer offset
  );
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glDisableVertexAttribArray(0);
  SetBlendMode(bm);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkRenderer.DrawPassFXAA', TTypeCheckError.tcNone, -1);
  {$endif}
end;

procedure TBlackSharkRenderer.DrawPassSSAA(Pass: PRenderPass);
var
  sx: BSFloat;
  bm: TBlendMode;
begin
  bm := FBlendMode;
  SetBlendMode(TBlendMode.bmNone);
  glDisable(GL_DEPTH_TEST);
  DepthTestOn := false;
  //glClear(GL_COLOR_BUFFER_BIT);
  sx := BSConfig.VoxelSize/3;
  Pass^.Shader.UseProgram;
  glUniform1fv(TBlackSharkSmoothByKernelMSAA(Pass^.Shader).Kernel^.Location, 9, @SAMPLING_KERNELS_SET[FKernelSSAA]);
  glUniform1fv(TBlackSharkSmoothByKernelMSAA(Pass^.Shader).RatioResolutions^.Location, 1, @sx);
  glVertexAttribPointer(
    TBlackSharkSmoothByKernelMSAA(Pass^.Shader).Position^.Location,     // attribute. No particular reason for 1, but must match the layout in the shader.
    3,                                    // size
    GL_FLOAT,                             // type
    GLboolean(GL_FALSE),                  // normalized?
    sizeof(TVec3f),         // stride
    @QUAD_VERTEXES[0]                  // array buffer offset
  );
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glDisableVertexAttribArray(0);
  SetBlendMode(bm);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkRenderer.DrawPassSSAA', TTypeCheckError.tcNone, -1);
  {$endif}
end;

procedure TBlackSharkRenderer.OnChangeFrustum;
var
  i: Integer;
  inst: PGraphicInstance;
  d: BSFloat;
begin
  //if Drawing then
  //  raise Exception.Create('Call OnChangeFrustum and Draw simultaneously');

  { query all objects to hited into frustum; when generated event EnumListVisibleObjectsByOctTree or
    EnumSingleVisibleObjectsByOctTree, already visible objects remove from FVisibleGI }

  BBSelectList.Count := 0;
  FScene.Select(Frustum.BB, BBSelectList);
  for i := 0 to BBSelectList.Count - 1 do
  begin
    inst := PGraphicInstance(BBSelectList.Items[i]);
    if not FFrustum.BoxInFrustum(inst.BoundingBox) then
      continue;
    if FExactMesureDistanceToBB then
      { more exact }
      d := PlaneMaxDistanceToBB(FFrustum.Frustum.P[TBoxPlanes.bpNear], @inst.BoundingBox)
    else
      d := PlaneDotProduct(FFrustum.Frustum.P[TBoxPlanes.bpNear], TVec3f(inst.BoundingBox.Middle));
    EnumSingleVisibleObjectsByBVH(inst, d);
  end;

  { now remain only objects which not hit into Frustum and to have property Visible = true;
    set Visible = false }
  while FVisibleGI.Count > 0 do
  begin
    if FVisibleGI.ItemListFirst.Item.Instance.Owner.SceneSpaceTreeClient then
    begin
      SetVisibleInstance(FVisibleGI.ItemListFirst.Item, false);
    end else
    begin
      UpdateLastMVP(FVisibleGI.ItemListFirst.Item);
      inc(FVisibleGI.ItemListFirst.Item.ChangeLastMVP);
      FVisibleGI.Remove(FVisibleGI.ItemListFirst.Item._VisibleNode);
    end;
  end;

  FEventMoveFrustum.Send(Self);
end;

function TBlackSharkRenderer.ScenePositionToScreen3D(const v: TVec3f): TVec3f;
var
  dir: TVec3f;
  b: boolean;
  d: BSFloat;
begin
  dir := VecNormalize(v - FFrustum.Position);
  Result := PlaneCrossProduct(FFrustum.Frustum.P[TBoxPlanes.bpNear], FFrustum.Position, dir, b, d);   // ,
end;

function TBlackSharkRenderer.ScenePositionToScreenf(const AInstance: PGraphicInstance): TVec2f;
var
  bb: TBox3f;
  vp: TVec3f;
  d: BSFloat;
begin
  bb := AInstance.BoundingBox;
  Box3Recalc(bb, Frustum.ViewMatrix);
  vp := PlanePointProjection(FFrustum.DEFAULT_NEAR_PLANE, vec3(bb.x_min, bb.y_max, FFrustum.DEFAULT_POSITION.z - FFrustum.DistanceNearPlane), d);
  Result.x := round(((0.5*FScaleScreen.x + vp.x) / FFrustum.NearPlaneWidth)*FWindowWidth);
  Result.y := round(((0.5*FScaleScreen.y - vp.y) / FFrustum.NearPlaneHeight)*FWindowHeight);
end;

function TBlackSharkRenderer.ScenePositionToScreenf(const V: TVec3f): TVec2f;
var
  vp, dir: TVec3f;
  b: boolean;
  d: BSFloat;
begin
  //vp := PlaneCrossProduct(FFrustum.FFrustum.P[TFrustumPlane.fpNear], v, FFrustum.Direction, b, d);
  dir := VecNormalize(v - FFrustum.Position);
  //vp := PlaneCrossProduct(FFrustum.FFrustum.P[TFrustumPlane.fpNear], v,  FFrustum.Direction, b, d);   // ,
  vp := PlaneCrossProduct(FFrustum.Frustum.P[TBoxPlanes.bpNear], Frustum.Position, dir, b, d);   // ,
  if b then
  begin
    //GetProjectionPoint(FFrustum.FPoints[TPointsFrustum.pfLTN],
    //pr := vp;
    GetProjectionPoint(FFrustum.EdgeNearTopNormalize, FFrustum.FPoints[TPointsFrustum.pfRTN], d, vp);
    //d := VecLen(pr - vp);
    Result.x := (1.0 - d / FFrustum.NearPlaneWidth) * FWindowWidth;
    //pr := vp;
    //d := VecLen(pr - vp);
    GetProjectionPoint(FFrustum.EdgeNearLeftNormalize, FFrustum.FPoints[TPointsFrustum.pfLTN], d, vp);
    Result.y := (d / FFrustum.NearPlaneHeight) * FWindowHeight;
  end else
  begin
    Result := vec2(0.0, 0.0);
  end;
  //PlaneCrossProduct(FFrustum.FFrustum.P[TFrustumPlane.fpNear], v, FFrustum.Direction, b, d);
end;

function TBlackSharkRenderer.ScreenPosition: TVec3f;
begin
  Result := FFrustum.CentreNearPlane + FFrustum.Direction * FFrustum.DISTANCE_2D_SCREEN;
end;

function TBlackSharkRenderer.ScreenPosition(Layer: int32): TVec3f;
var
  d: BSFloat;
begin
  if Layer > 0 then
  begin
    d := FFrustum.DISTANCE_2D_SCREEN + Layer*FFrustum.DISTANCE_2D_BW_LAYERS;
    Result := FFrustum.CentreNearPlane + FFrustum.Direction * vec3(d, d, d);
  end else
    Result := FFrustum.CentreNearPlane + FFrustum.Direction * vec3(FFrustum.DISTANCE_2D_SCREEN, FFrustum.DISTANCE_2D_SCREEN, FFrustum.DISTANCE_2D_SCREEN);
end;

procedure TBlackSharkRenderer.Screenshot(const Rect: TRectBSi; const Buffer: Pointer);
//var
//  bm: TBlendMode;
//  cl: TColor4f;
begin
  //BSShaderManager.UseShader(nil);
  //BSTextureManager.UseTexture(nil);
  //bm := FBlendMode;
  //cl := FColor;
  { reset background color }
  //FColor := vec4(0.0, 0.0, 0.0, 0.0);
  { select blending mode for copy without change original color and alpha showed
    textures }
  //BlendMode := bmAddAndBlend;
  { add renderer if do't exists rendering to texture }
  //if FRenderers.Count = 1 then
  begin
    //if ScreenShortRenderer = nil then
    //  ScreenShortRenderer := AddRenderer(BSShaderManager.Load('QUAD', TBlackSharkQUADShader),
    //  	DrawQUAD, FWindowWidth, FWindowHeight, nil, true, [atColor], GL_RGBA); //, [atColor, atDepth]
    //RenderBefore(ScreenShortRenderer);
    //Render(FRenderers.Items[0]);
    glReadPixels(Rect.X, Rect.Y, Rect.Width, Rect.Height, GL_RGBA, GL_UNSIGNED_BYTE, Buffer);
    //DelRenderer(ScreenShortRenderer);
  end;
  //FColor := cl;
  //BlendMode := bm;
end;

procedure TBlackSharkRenderer.Screenshot(const X, Y, Width, Height: int32; const Buffer: Pointer);
var
  rect: TRectBSi;
begin
  rect := RectBS(X, int32(FWindowHeight - Y - Height), Width, Height);
  Screenshot(rect, Buffer);
end;

function TBlackSharkRenderer.ScreenSizeToScene(const Size: TVec2f): TVec2f;
begin
  Result := vec2(BSConfig.VoxelSize * Size.x*FScaleScreen.x, BSConfig.VoxelSize * Size.y);
end;

function TBlackSharkRenderer.ScreenPositionToScene(const Pos: TVec2i; Layer: int32): TVec3f;
var
  p: TVec2f;
begin
  p.x := Pos.x;
  p.y := Pos.y;
  Result := ScreenPositionToScene(p, Layer);
end;

function TBlackSharkRenderer.ScreenPositionToScene(const Pos: TVec2f; Layer: int32): TVec3f;
begin
  Result := ScreenPositionToScene(Pos.x, Pos.y, Layer);
end;

function TBlackSharkRenderer.ScreenPositionToScene(X, Y: BSFloat; Layer: int32): TVec3f;
begin
  Result.x := - FWindowWidth * 0.5 + X;
  Result.y :=   FWindowHeight * 0.5 - Y;
  {if Layer > 0 then
  begin }
    Result.z := 0; //FFrustum.DISTANCE_2D_BW_LAYERS;
  {end else
  begin
    Result.z := - FFrustum.DistanceNearPlane;// - FFrustum.DISTANCE_2D_SCREEN
    Result := FFrustum.ViewMatrixInv * Result;
  end;  }
end;

{function TBlackSharkRenderer.ScreenPositionToSceneAbsolute(const Pos: TVec2i): TVec3f;
begin
  Result.x := FFrustum.FNearPlaneWidth * (Pos.x / FWindowWidth - 0.5);
  Result.y := FFrustum.FNearPlaneHeight * (0.5 - Pos.y / FWindowHeight);
  Result.z := FFrustum.DISTANCE_2D_BW_LAYERS;
end;

function TBlackSharkRenderer.ScreenPositionToSceneAbsolute(const Pos: TVec2f): TVec3f;
begin
  Result.x := FFrustum.FNearPlaneWidth * (Pos.x / FWindowWidth - 0.5);
  Result.y := FFrustum.FNearPlaneHeight * (0.5 - Pos.y / FWindowHeight);
  Result.z := FFrustum.DISTANCE_2D_BW_LAYERS;
end;   }

function TBlackSharkRenderer.ScreenSizeToScene(const Size: TVec2i): TVec2f;
begin
  Result := vec2(Size.x * BSConfig.VoxelSize, Size.y * BSConfig.VoxelSize);

end;

function TBlackSharkRenderer.ScreenSizeToScene(Size: BSInt): BSFloat;
begin
  Result := (Size * BSConfig.VoxelSize);
end;

function TBlackSharkRenderer.SceneSizeToScreen(const Size: TVec2f): TVec2f;
begin
  Result := Size * BSConfig.VoxelSizeInv;
end;

function TBlackSharkRenderer.SceneSizeToScreen(const Size: TVec3f): TVec2f;
begin
  Result := TVec2f(Size * BSConfig.VoxelSizeInv);
end;

function TBlackSharkRenderer.SceneSizeToScreen(Size: BSFloat): BSFloat;
begin
  Result := Size * BSConfig.VoxelSizeInv;
end;

end.
