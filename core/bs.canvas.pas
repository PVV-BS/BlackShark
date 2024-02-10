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


unit bs.canvas;

{$ifdef fpc}
{$WARN 5024 off : Parameter "$1" not used}
{$endif}
{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , math
  , SysUtils
  , bs.obj
  , bs.basetypes
  , bs.align
  , bs.events
  , bs.collections
  , bs.graphics
  , bs.scene
  , bs.scene.objects
  , bs.renderer
  , bs.shader
  , bs.texture
  , bs.font
  , bs.mesh
  , bs.mesh.primitives
  , bs.thread
  , bs.tesselator
  ;

type


  TBCanvas = class;
  TCanvasObject = class;
  TCanvasObjectClass = class of TCanvasObject;

  TListVecCanvasObjects = TListVec<TCanvasObject>;

  { TCanvasObject
    It is a wrapper over TGraphicObject (property Data); in fact, presents 2d
    objects; default is bound at Position2d (a left-up corner) by anchors; type
    of the Data defined by descendats into method CreateGraphicObject; descendats
    creating TGraphicObject (for property Data) into CreateGraphicObject MUST
    translate to constructor TGraphicObject itself as parameter AOwner }

  TCanvasObject = class abstract
  private
    FCanvas: TBCanvas;
    FData: TGraphicObject;

    Setting2dPos: boolean;
    FLayer2d: int32;
    FPositionZ: BSFloat;
    { the bounding box given model matrix: FData.BaseInstance.ModelMatrix }
    FModelBB: TBox3f;
    FTopLeft: TVec3f;
    FIndependent2dSizeFromMVP: boolean;

    DropObsrv: IBDragDropEventObserver;
    HandleCMVP: IBChangeMVPEventObserver;

    {$region 'scale mode supporting'}
    FBanScalableMode: boolean;
    FBanScalableModeSize: boolean;
    FBanScalableModePos: boolean;
    FStartScalePos: TVec2f;
    {$endregion 'scale mode supporting'}

    FCountAnchors: int8;

    FAlign: TObjectAlign;
    FPaddingTop: BSFloat;
    FPaddingLeft: BSFloat;
    FPaddingRight: BSFloat;
    FPaddingBottom: BSFloat;

    function GetIsVisible: boolean;
    procedure SetLayer2d(const Value: int32);
    procedure SetMinHeight(const Value: BSFloat);
    procedure SetMinWidth(const Value: BSFloat);
    procedure SetPositionZ(const Value: BSFloat);
    function GetAngle: TVec3f;
    procedure SetAngle(const Value: TVec3f);
    function GetAbsolutePosition2d: TVec2f;
    procedure SetIndependent2dSizeFromMVP(const Value: boolean);
    function GetLayer2dAbsolute: int32;

    function GetAnchor(Index: TAnchor): boolean;
    procedure SetAnchor(Index: TAnchor; const Value: boolean);

    procedure SetDefaultSizeRightBottomAnchors; inline;
    procedure SetDefaultSizeLeftTopAnchors; inline;
    function GetParent: TCanvasObject; inline;

    { setter PGraphicInstance a position to 2d dimention; !!! CanvasObjectInstance
      MUST belong to self (TCanvasObject) !!! }
    procedure SetCanvasObjectPosition(X, Y: BSFloat; CanvasObjectInstance: PGraphicInstance); overload;
    procedure CalcBB;
    procedure SetMarginBottom(const Value: BSFloat);
    procedure SetMarginLeft(const Value: BSFloat);
    procedure SetMarginRight(const Value: BSFloat);
    procedure SetMarginTop(const Value: BSFloat);
    procedure SetPaddingBottom(const Value: BSFloat);
    procedure SetPaddingLeft(const Value: BSFloat);
    procedure SetPaddingRight(const Value: BSFloat);
    procedure SetPaddingTop(const Value: BSFloat);
    procedure Reload; inline;
    procedure ReloadAnchorsAlign; inline;
    function GetMinHeight: BSFloat;
    function GetMinWidth: BSFloat;
    function GetMarginBottom: BSFloat;
    function GetMarginLeft: BSFloat;
    function GetMarginRight: BSFloat;
    function GetMarginTop: BSFloat;
  protected
    FWidth: BSFloat;
    FHeight: BSFloat;
    FPosition2d: TVec2f;
    FIsBuilding: boolean;
    FIsAligning: boolean;
    FPatternAlignVert: TPattenAlign;
    FPatternAlignHor: TPattenAlign;
    procedure SubscribeMvpChangeEvent; inline;
    procedure TryRealign; inline;
    procedure Drop({%H-}const Value: BDragDropData); virtual;
    procedure SetParent(const AValue: TCanvasObject); virtual;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; virtual; abstract;
    procedure SetColor(const Value: TColor4f); virtual;
    procedure SetPosition2d(const AValue: TVec2f); virtual;
    procedure AfterScaleModeChange; virtual;
    function ToScene(Value: BSFloat): BSFloat; overload; inline;
    function ToScene(const Value: TVec2f): TVec2f; overload; inline;
    function GetColor: TColor4f; virtual;
    procedure SetBanScalableMode(const Value: boolean); virtual;
    procedure CalcPercentPos;
    procedure DoBuild; virtual;
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); virtual;
    procedure RealignChildren;
    procedure SetAlign(const Value: TObjectAlign); virtual;
    procedure DoResize(AWidth, AHeight: BSFloat); virtual;
    procedure OnChangeMVP({%H}const Value: BTransformData); virtual;
    procedure SetHeight(const Value: BSFloat); virtual;
    procedure SetWidth(const Value: BSFloat); virtual;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Build; virtual;
    function RoundWidth(AWidth: BSFloat): BSFloat;
    procedure DeleteChildren;
    { change size of an object in pixels by scaling of a shape;
      be careful, because if all vertices are folded to a zero point,
      you will not be able to return them from the zero position; after it
      occurred, you need to build the shape again; you can define minimal size
      of shape through properties  MinWidth and MinHeight;
      TODO: redefine the method (where it need) in inheritors }
    procedure Resize(AWidth, AHeight: BSFloat); virtual;
    function Get3dPositionInsideSelf(X, Y: BSFloat): TVec3f;
    function Get2dPositionInsideSelf(ScreenX, ScreenY: int32): TVec2f; overload;
    function Get2dPositionInsideSelf(ScreenX, ScreenY: int32; out IsHit: boolean): TVec2f; overload;
    { place child with combine 2d point on self (ToPosition) and on a child (OnChildPosition) }
    procedure ConnectChild(const ToPosition, OnChildPosition: TVec2f; Child: TCanvasObject);
    { it returns size of a nearest parent; if parent is nil, then return size viewport renderer }
    function GetParentSize: TVec2f; inline;
    function HasAncestor(Ancestor: TCanvasObject): boolean;
    procedure ToParentCenter;
    procedure AdjustAnchorsForClientAlign;
    { all anchors reset to false }
    procedure AnchorsReset;
    function Center: TVec2f;
    procedure Hide(AReleaseGraphicsData: boolean);
    procedure Show;

    { a some object of Scene }
    property Data: TGraphicObject read FData;
    property Canvas: TBCanvas read FCanvas;
    property IsBuilding: boolean read FIsBuilding;
    { Size in pixels; note, Width and Height are taken from 2d projection of
      shape on the viewport }
    property Width: BSFloat read FWidth write SetWidth;
    property Height: BSFloat read FHeight write SetHeight;
    property MinWidth: BSFloat read GetMinWidth write SetMinWidth;
    property MinHeight: BSFloat read GetMinHeight write SetMinHeight;
    { position on screen relative left-up angle parent BB (only x, y, of course) or screen }
    property Position2d: TVec2f read FPosition2d write SetPosition2d;
    property AbsolutePosition2d: TVec2f read GetAbsolutePosition2d;
    { Z-position; than more, than further from parent object }
    property PositionZ: BSFloat read FPositionZ write SetPositionZ;
    { this property define distance above Parent object, that is level relative
      Parent; if Parent = nil then b/w screen and this object; also it is a
      correction for PositionZ property }
    property Layer2d: int32 read FLayer2d write SetLayer2d;
    { absolute layer relative screen }
    property Layer2dAbsolute: int32 read GetLayer2dAbsolute;
    { property-wrapper over Data.Color }
    property Color: TColor4f read GetColor write SetColor;
    { Parent object MUST have property Data.Parent = Parent.Data }
    property Parent: TCanvasObject read GetParent write SetParent;
    { wraper above TCanvasObject.Data.Angle }
    property Angle: TVec3f read GetAngle write SetAngle;
    { if Independent2dSizeFromMVP equal true then sizes takes
      directly from TCanvasObject.Data.Mesh.FBoundingBox }
    property Independent2dSizeFromMVP: boolean read FIndependent2dSizeFromMVP write SetIndependent2dSizeFromMVP;
    { Anchors allow align the object relative parent layout; if parent absent,
      then size and position align relative viewport; default on left and top
      anchors; for align on center need to set off all anchors and to place 
      object into center parent client area }
    property Anchors[Index: TAnchor]: boolean read GetAnchor write SetAnchor;
    property CountAnchors: int8 read FCountAnchors;

    property PaddingLeft: BSFloat read FPaddingLeft write SetPaddingLeft;
    property PaddingRight: BSFloat read FPaddingRight write SetPaddingRight;
    property PaddingTop: BSFloat read FPaddingTop write SetPaddingTop;
    property PaddingBottom: BSFloat read FPaddingBottom write SetPaddingBottom;

    property MarginLeft: BSFloat read GetMarginLeft write SetMarginLeft;
    property MarginRight: BSFloat read GetMarginRight write SetMarginRight;
    property MarginTop: BSFloat read GetMarginTop write SetMarginTop;
    property MarginBottom: BSFloat read GetMarginBottom write SetMarginBottom;

    property ModelBB: TBox3f read FModelBB;
    { object align; take into account own margins and a parent paddings;
      ! note, not need to set before invoke method Build }
    property Align: TObjectAlign read FAlign write SetAlign;
    { a full ban of the scalable mode }
    property BanScalableMode: boolean read FBanScalableMode write SetBanScalableMode;
    { a partial ban of the scalable mode - if true then size is not scalable, only position }
    property BanScalableModeSize: boolean read FBanScalableModeSize write FBanScalableModeSize;
    { a partial ban of the scalable mode - if true then position is not scalable, only size }
    property BanScalableModePos: boolean read FBanScalableModePos write FBanScalableModePos;
    property IsVisible: boolean read GetIsVisible;
  end;

  TCanvasObjectEmpty = class(TCanvasObject)
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
  end;

  { TCanvasObjectP
    This is an object whose vertices contain only points/vectors }

  TCanvasObjectP = class(TCanvasObject)
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
  end;

  { TCanvasObjectPT
    This is an object whose vertices contain points and texture coordinates }

  TCanvasObjectPT = class(TCanvasObject)
  private
    function GetTexture: PTextureArea;
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure SetTexture(const Value: PTextureArea); virtual;
  public
    property Texture: PTextureArea read GetTexture write SetTexture;
  end;

  { TCanvasLayout }

  TCanvasLayout = class(TCanvasObjectEmpty)
  private
    function GetSize: TVec2f;
    procedure SetIsVisible(const Value: boolean);
    procedure SetSize(const Value: TVec2f);
    function GetIsVisible: boolean;
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
    procedure DoResize(AWidth, AHeight: BSFloat); override;
    procedure SetHeight(const Value: BSFloat); override;
    procedure SetWidth(const Value: BSFloat); override;
  public
    property Size: TVec2f read GetSize write SetSize;
    property IsVisible: boolean read GetIsVisible write SetIsVisible;
  end;

  { TBlackSharkText

    Wrapper over TGraphicObjectText, that is property Data is have the TGraphicObjectText;
    uses the default font of the TBCanvas
  }

  TCanvasText = class(TCanvasObject)
  private
    ObsrvReplace: IBEmptyEventObserver;
    ObsrvResizeVP: IBResizeWindowEventObserver;
    ObsrvChangeFont: IBEmptyEventObserver;
    SizeFontFixed: BSFloat;
    ScalingFont: boolean;
    FScalableModeToFontSize: boolean;
    FWrap: boolean;
    function GetText: string;
    procedure SetText(const AValue: string);
    function GetSceneTextData: TGraphicObjectText;
    function GetFont: IBlackSharkFont;
    function GetFontName: string;
    procedure SetFont(const Value: IBlackSharkFont);
    procedure SetFontName(const Value: string);
    procedure OnChangeFontEvent({%H}const Value: BEmpty);
    procedure OnReplaceFont(const Value: BEmpty);
    procedure OnResizeViewport(const Value: BResizeEventData);
    procedure UpdateObservices;
    function GetBold: boolean;
    function GetBoldWeightX: BSFloat;
    function GetBoldWeightY: BSFloat;
    function GetItalic: boolean;
    procedure SetBold(const Value: boolean);
    procedure SetBoldWeightX(const Value: BSFloat);
    procedure SetBoldWeightY(const Value: BSFloat);
    procedure SetItalic(const Value: boolean);
    function GetItalicWeight: BSFloat;
    procedure SetItalicWeight(const Value: BSFloat);
    function GetStrikethrough: boolean;
    function GetUnderline: boolean;
    procedure SetStrikethrough(const Value: boolean);
    procedure SetUnderline(const Value: boolean);
    function GetColorLine: TColor4f;
    procedure SetColorLine(const Value: TColor4f);
    function GetViewportPosition: TVec2f;
    function GetViewportSize: TVec2f;
    procedure SetViewportPosition(const Value: TVec2f);
    procedure SetViewportSize(const Value: TVec2f);
    function GetTextAlign: TTextAlign;
    procedure SetTextAlign(const Value: TTextAlign);
    procedure SetWrap(const Value: Boolean);
    procedure UpdateWrapping;
    function GetIndexLastStringInViewport: int32;
  protected
    procedure DoResize(AWidth, AHeight: BSFloat); override;
    procedure SetBanScalableMode(const Value: boolean); override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure AfterScaleModeChange; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    function CreateCustomFont: IBlackSharkFont;
    property Text: string read GetText write SetText;
    property SceneTextData: TGraphicObjectText read GetSceneTextData;
    property ScalableModeToFontSize: boolean read FScalableModeToFontSize write FScalableModeToFontSize;
    // takes the default font of canvas, but you can change it
    property FontName: string read GetFontName write SetFontName;
    property Font: IBlackSharkFont read GetFont write SetFont;
    { wrapper of TGraphicObjectText.IndexLastStringInViewport }
    property IndexLastStringInViewport: int32 read GetIndexLastStringInViewport;
    property ViewportSize: TVec2f read GetViewportSize write SetViewportSize;
    property ViewportPosition: TVec2f read GetViewportPosition write SetViewportPosition;
    { wrap text into an window with width ViewportSize.Width   }
    property Wrap: Boolean read FWrap write SetWrap;
    property TextAlign: TTextAlign read GetTextAlign write SetTextAlign;
    property Bold: boolean read GetBold write SetBold;
    property BoldWeightX: BSFloat read GetBoldWeightX write SetBoldWeightX;
    property BoldWeightY: BSFloat read GetBoldWeightY write SetBoldWeightY;
    property Italic: boolean read GetItalic write SetItalic;
    property ItalicWeight: BSFloat read GetItalicWeight write SetItalicWeight;
    property Strikethrough: boolean read GetStrikethrough write SetStrikethrough;
    property Underline: boolean read GetUnderline write SetUnderline;
    { color of Underline and Strikethrough }
    property ColorLine: TColor4f read GetColorLine write SetColorLine;
  end;

  TCanvasTextMap = class(TCanvasObject)
  end;

  TCircle = class(TCanvasObject)
  protected
    FFill: boolean;
    FRadius: BSFloat;
    FWidthLine: BSFloat;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Fill: boolean read FFill write FFill;
    property Radius: BSFloat read FRadius write FRadius;
    property WidthLine: BSFloat read FWidthLine write FWidthLine;
  end;

  TCircleTextured = class(TCircle)
  private
    function GetTexture: PTextureArea;
    procedure SetTexture(const Value: PTextureArea);
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    destructor Destroy; override;
    property Texture: PTextureArea read GetTexture write SetTexture;
  end;

  { Set of arbitrary lines }

  TLines = class(TCanvasObject)
  private
    Offset: TVec2f;
    RealPos: TVec2f;
    Points: TListVec4f;
    function GetLinesWidth: BSFloat;
    procedure SetLinesWidth(const Value: BSFloat);
    function GetCountLines: int32;
    function GetDrawByTriangleOnly: boolean;
    procedure SetDrawByTriangleOnly(const Value: boolean);
  protected
    procedure SetPosition2d(const AValue: TVec2f); override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure AddLine(const Point1, Point2: TVec2f); overload;
    procedure AddLine(X1, Y1, X2, Y2: BSFloat); overload;
    procedure Clear;

    // the properties are for drawing double colored solid lines
    property LinesWidth: BSFloat read GetLinesWidth write SetLinesWidth;
    property CountLines: int32 read GetCountLines;
    property DrawByTriangleOnly: boolean read GetDrawByTriangleOnly write SetDrawByTriangleOnly;
  end;

  { Set of parallel solid lines }

  TBiColoredSolidLines = class(TCanvasObject)
  private
    FHorizontal: boolean;
    function GetLineWidth: BSFloat;
    procedure SetLineWidth(const Value: BSFloat);
    function GetCountLines: int32;
    procedure SetLineColor2(const Value: TColor4f);
    function GetLineColor2: TColor4f;
  protected
    procedure SetPosition2d(const AValue: TVec2f); override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    // draw double colored solid lines
    procedure Draw(AWidth: BSFloat; AHorizontal: boolean; ACount: int32);
    property LineWidth: BSFloat read GetLineWidth write SetLineWidth;
    property Color2: TColor4f read GetLineColor2 write SetLineColor2;
    property CountLines: int32 read GetCountLines;
  end;

  TMultiColoredShape = class(TCanvasObject)
  private
    type
      TVertMultiColor = record
        Point: TVec2f;
        Color: TVec3f;
      end;
  private
    FColor: TColor4f;
    Vertexes: TListVec<TVertMultiColor>;
    function GetTypePrimitive: TTypePrimitive;
    procedure SetTypePrimitive(const Value: TTypePrimitive);
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    function GetColor: TColor4f; override;
    procedure SetColor(const Value: TColor4f); override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure Clear;
    function AddVertex(const APoint: TVec2f; const AColor: TVec3f): int32; overload;
    function AddVertex(const APoint: TVec2f): Int32; overload;
    procedure WriteColor(AVertexIndex: int32; const AColor: TVec3f);
    property TypePrimitive: TTypePrimitive read GetTypePrimitive write SetTypePrimitive;
  end;

  { A base for sequentially linked points }

  { TLinesSequence }

  TLinesSequence = class abstract(TCanvasObject)
  private
    FDirectionY: int8;
    FShowPoints: boolean;
    FColorPoints: TColor4f;
    FWidthLine: BSFloat;
    FRadiusPoints: BSFloat;
    TexturePoint: PTextureArea;
    ObsrvOnBeforeCanvasClear: IBEmptyEventObserver;
    Obsers: array of IBDragDropEventObserver;
    FOriginPosition: TVec2f;
    FPointsG: TListVec<TCircle>;
    FOriginPos: TVec2f;
    procedure OnDrag(const Value: BDragDropData);
    procedure SetDirectionY(AValue: int8);
    procedure SetShowPoints(const Value: boolean);
    function GetPointG(Index: int32): TCircle;
    procedure OnBeforeCanvasClear(const AData: BEmpty);
    procedure UpdatePointsPos;
    procedure ClearPointsG;
    function GetPoint(Index: int32): TVec2f;
    function GetCountPoint: int32;
    procedure CreateGPoints;
    function CreatePoint(Index: int32): TCircle;
    procedure CalcOriginPos;
    procedure SetColorPoints(const Value: TColor4f);
  protected
    FOrigins: TListVec2f;
    FPoints: TListVec3f;
    FPointsInterpolated: TListVec3f;
    FOriginSize: TVec2f;
    FOriginMiddle: TVec2f;
    FCurrentLength: double;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); override;
    { return TCircle (TODO: remove it) if a property ShowPoints is enabled }
    function DoAddPoint(const Point: TVec2f): TCircle; virtual;
    procedure SetPosition2d(const AValue: TVec2f); override;
    procedure SetColor(const Value: TColor4f); override;
    procedure SetWidthLine(const Value: BSFloat); virtual;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure Build; override;
    procedure Clear; virtual;
    property ShowPoints: boolean read FShowPoints write SetShowPoints;
    property ColorPoints: TColor4f read FColorPoints write SetColorPoints;
    property WidthLine: BSFloat read FWidthLine write SetWidthLine;
    property PointsG[Index: int32]: TCircle read GetPointG;
    property RadiusPoints: BSFloat read FRadiusPoints write FRadiusPoints;
    property CountPoints: int32 read GetCountPoint;
    property Points[Index: int32]: TVec2f read GetPoint;
    property CurrentLength: double read FCurrentLength;
    { minimal 2d origin point }
    property OriginPosition: TVec2f read FOriginPosition;
    { direction of Y = [-1; 1] }
    property DirectionY: int8 read FDirectionY write SetDirectionY;
  end;

  TBaseLine = class(TLinesSequence)
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override; deprecated 'Use TLinesSequence instead TBaseLine';
  end;

  { TLinesSequenceStroke }

  TLinesSequenceStroke = class abstract(TLinesSequence)
  private
    LastOrigin: TVec2f;
    SumRemainder: BSFloat;
    StartStroke: TVec2f;
    function GetColorsCount: int32;
    procedure SetStrokeLength(const Value: BSFloat);
    function GetColors(Index: int32): TColor4f;
    function GetStrokeLength: BSFloat;
  protected
    FColors: TListVec<TColor4f>;
    FColorDistances: TListVec<Double>;
    function DoAddPoint(const Point: TVec2f): TCircle; override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
    procedure SetColor(const Value: TColor4f); override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure Build; override;
    procedure Clear; override;
    procedure WriteColorToPoint(AIndexPoint: int32; const AValue: TColor4f);
    { if it is more 0 then the line has strokes }
    property StrokeLength: BSFloat read GetStrokeLength write SetStrokeLength;
    property Colors[Index: int32]: TColor4f read GetColors;
    property ColorsCount: int32 read GetColorsCount;
  end;

  TLine = class(TLinesSequenceStroke)
  private
    FB: TVec2f;
    FA: TVec2f;
    function GetLength: BSFloat;
    procedure SetLength(const Value: BSFloat);
    //procedure SetA(const Value: TVec2f);
    //procedure SetB(const Value: TVec2f);
  protected
    procedure DoBuild; override;
    procedure SetPoint(Index: int32; const Value: TVec2f);
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure Build; override;
    property A: TVec2f read FA write FA;
    property B: TVec2f read FB write FB;
    { you can define Size of the line drive direction by the point B }
    property Length: BSFloat read GetLength write SetLength;
  end;

  { TPath }

  TPath = class(TLinesSequenceStroke)
  private type
    TIntrpFunc = procedure of object;
  private
    FClosed: boolean;
    FuncIntrp: array [TInterpolateSpline] of TIntrpFunc;
    FInterpolateSpline: TInterpolateSpline;
    FInterpolateFactor: BSFloat;
    procedure SplineInterpolateBezier;
    procedure SplineInterpolateCubic;
    // https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Cardinal_spline
    procedure SplineInterpolateCubicHermite;

    procedure DoAddArc(const APositionCenter: TVec2f; ARadius: BSFloat; AAngle, AStartAngle: BSFloat);
    procedure SetInterpolateFactor(const Value: BSFloat);
    procedure AddColor(const AColor: TColor4f);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure Build; override;
    function AddPoint(const Point: TVec2f): TCircle; overload;
    function AddPoint(X, Y: BSFloat): TCircle; overload;
    function AddPoint(const APoint: TVec2f; const AColor: TColor4f): TCircle; overload;
    function AddPoint(const APoint: TVec2f; const AColor: TGuiColor): TCircle; overload;
    function AddPoint(X, Y: BSFloat; const AColor: TColor4f): TCircle; overload;
    function AddPoint(X, Y: BSFloat; const AColor: TGuiColor): TCircle; overload;
    { create a new curve with arc patern; smoothing depend on InterpolateFactor - the less, the better }
    procedure AddFirstArc(const APositionCenter: TVec2f; ARadius: BSFloat; AAngle, AStartAngle: BSFloat); overload;
    procedure AddFirstArc(const APositionCenter: TVec2f; ARadius: BSFloat; AAngle, AStartAngle: BSFloat; const AColor: TColor4f); overload;
    procedure AddFirstArc(const APositionCenter: TVec2f; ARadius: BSFloat; AAngle, AStartAngle: BSFloat; const AColor: TGuiColor); overload;
    { adds an arc to the end of the curve; smoothing depend on InterpolateFactor - the less, the better }
    procedure AddArc(ARadius: BSFloat; AAngle: BSFloat); overload;
    procedure AddArc(ARadius: BSFloat; AAngle: BSFloat; const AColor: TColor4f); overload;
    procedure AddArc(ARadius: BSFloat; AAngle: BSFloat; const AColor: TGuiColor); overload;
    property Closed: boolean read FClosed write FClosed;
    property InterpolateSpline: TInterpolateSpline read FInterpolateSpline write FInterpolateSpline;
    property InterpolateFactor: BSFloat read FInterpolateFactor write SetInterpolateFactor;
  end;

  { TPathMultiColored

    The path in which can set itself color for an every point.
    WARNING: property InterpolateSpline need to switch off because after build
    interpolated curve quantity points and colors will be different
  }

  TPathMultiColored = class(TPath)
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override; deprecated 'Use TPath instead TPathMultiColored';
  end;

  TBezierLine = class(TLinesSequence)
  private
    function GetA: TVec2f;
    function GetB: TVec2f;
    procedure SetA(const Value: TVec2f);
    procedure SetB(const Value: TVec2f);
  protected
    procedure DoBuild; override;
    procedure SetPoint(Index: int32; const Value: TVec2f);
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    property A: TVec2f read GetA write SetA;
    property B: TVec2f read GetB write SetB;
  end;

  TBezierQuadratic = class(TBezierLine)
  private
    FQuality: BSFloat;
    procedure SetQuality(const Value: BSFloat);
    function GetC: TVec2f;
    procedure SetC(const Value: TVec2f);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure Build; override;
    property C: TVec2f read GetC write SetC;
    property Quality: BSFloat read FQuality write SetQuality;
  end;

  TBezierCubic = class(TBezierQuadratic)
  private
    function GetD: TVec2f;
    procedure SetD(const Value: TVec2f);
  protected
    procedure DoBuild; override;
  public
    property D: TVec2f read GetD write SetD;
  end;

  { TTriangle }

  TTriangle = class(TCanvasObjectP)
  private
    FA: TVec2f;
    FB: TVec2f;
    FC: TVec2f;
    FFill: boolean;
    FWidthLine: BSFloat;
    procedure SetWidthLine(AValue: BSFloat);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure Build; override;
    property A: TVec2f read FA write FA;
    property B: TVec2f read FB write FB;
    property C: TVec2f read FC write FC;
    property Fill: boolean read FFill write FFill;
    property WidthLine: BSFloat read FWidthLine write SetWidthLine;
  end;

  TTriangleTextured = class(TTriangle)
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  end;

  { TArrow }

  TArrow = class(TCanvasObjectP)
  private
    FB: TVec2f;
    FA: TVec2f;
    FSizeTip: TVec2f;
    FLineWidth: BSFloat;
    procedure SetLineWidth(AValue: BSFloat);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property A: TVec2f read FA write FA;
    property B: TVec2f read FB write FB;
    property SizeTip: TVec2f read FSizeTip write FSizeTip;
    property LineWidth: BSFloat read FLineWidth write SetLineWidth;
  end;

  { TArc }

  TArc = class(TCanvasObject)
  private
    FRadius: BSFloat;
    FAngle: BSFloat;
    FStartAngle: BSFloat;
    FFill: boolean;
    FLineWidth: BSFloat;
    FPosition2dCenter: TVec2f;
    FInterpolateFactor: BSFloat;
    procedure SetLineWidth(AValue: BSFloat);
    procedure SetPosition2dCenter(const Value: TVec2f);
    procedure SetInterpolateFactor(const Value: BSFloat);
  protected
    LocalPosition2dCenter: TVec2f;
    procedure SetPosition2d(const AValue: TVec2f); override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Radius: BSFloat read FRadius write FRadius;
    property StartAngle: BSFloat read FStartAngle write FStartAngle;
    property Angle: BSFloat read FAngle write FAngle;
    property Fill: boolean read FFill write FFill;
    property LineWidth: BSFloat read FLineWidth write SetLineWidth;
    property Position2dCenter: TVec2f read FPosition2dCenter write SetPosition2dCenter;
    { smoothing depend on InterpolateFactor - the less, the better }
    property InterpolateFactor: BSFloat read FInterpolateFactor write SetInterpolateFactor;
  end;

  TArcTextured = class(TArc)
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  end;

  TRectangle = class(TCanvasObjectP)
  private
    FFill: boolean;
    FWidthLine: BSFloat;
    FSize: TVec2f;
    procedure SetSize(const Value: TVec2f);
  protected
    procedure DoBuild; override;
    procedure DoResize(AWidth, AHeight: BSFloat); override;
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); override;
    procedure SetHeight(const Value: BSFloat); override;
    procedure SetWidth(const Value: BSFloat); override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Size: TVec2f read FSize write SetSize;
    property Fill: boolean read FFill write FFill;
    { <summary> Width of line. Actual only when Fill = false </summury> }
    property WidthLine: BSFloat read FWidthLine write FWidthLine;
  end;

  TColorSelector = class(TCanvasObjectP)
  private
    ObsrvMouseDown: IBMouseDownEventObserver;
    ObsrvMouseMove: IBMouseMoveEventObserver;
    ObsrvMouseUp: IBMouseUpEventObserver;
    FOnColorChange: TNotifyEvent;
    Rect: TRectangle;
    Cross: TLines;
    IsMouseDown: boolean;
    FGreen: BSFloat;
    FSaturation: BSFloat;
    FHue: BSFloat;
    FRed: BSFloat;
    FBlue: BSFloat;
    FLightness: BSFloat;
    procedure SetSize(const Value: TVec2f);
    procedure OnMouseDown(const AData: BMouseData);
    procedure OnMouseUp(const AData: BMouseData);
    procedure OnMouseMove(const AData: BMouseData);
    function GetSize: TVec2f;
    procedure UpdateColorAndCross(const AData: BMouseData);
    procedure SetColorSelected(const Value: TColor4f);
    procedure SetBlue(const Value: BSFloat);
    procedure SetGreen(const Value: BSFloat);
    procedure SetHue(const Value: BSFloat);
    procedure SetRed(const Value: BSFloat);
    procedure SetSaturation(const Value: BSFloat);
    procedure SetLightness(const Value: BSFloat);
    procedure HlsToColor;
    procedure ColorToHls;
    function GetColorSelected: TColor4f;
    function GetColorWithMiddleLightness: TColor4f;
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    property Size: TVec2f read GetSize write SetSize;
    property ColorSelected: TColor4f read GetColorSelected write SetColorSelected;
    property ColorWithMiddleLightness: TColor4f read GetColorWithMiddleLightness;
    property Red: BSFloat read FRed write SetRed;
    property Green: BSFloat read FGreen write SetGreen;
    property Blue: BSFloat read FBlue write SetBlue;
    property Hue: BSFloat read FHue write SetHue;
    property Saturation: BSFloat read FSaturation write SetSaturation;
    property Lightness: BSFloat read FLightness write SetLightness;
    property OnColorChange: TNotifyEvent read FOnColorChange write FOnColorChange;
  end;

  TFog = class(TRectangle)
  protected
    procedure DoBuild; override;
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
  end;

  TCanvasRect = class(TCanvasObjectP)
  private
    FBorder: TCanvasObjectP;
    FSize: TVec2f;
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Build; override;
    procedure Hide;
    procedure Show;
    property Size: TVec2f read FSize write FSize;
  end;

  TRectangleTextured = class(TRectangle)
  private
    function GetTexture: PTextureArea;
    procedure SetTexture(const Value: PTextureArea);
    procedure SetReplaceColor(const Value: boolean);
    function GetReplaceColor: boolean;
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Texture: PTextureArea read GetTexture write SetTexture;
    property ReplaceColor: boolean read GetReplaceColor write SetReplaceColor;
  end;

  TPicture = class(TCanvasObjectPT)
  private
    FTrilinearFilter: boolean;
    FAutoFit: boolean;
    FSize: TVec2f;
    FAsPartMap: boolean;
    FWrap: boolean;
    FWrapReapeated: boolean;
    procedure SetWrap(const Value: boolean);
    function GetImage: TBlackSharkPicture;
    procedure SetImage(const Value: TBlackSharkPicture);
    procedure SetWrapReapeated(const Value: boolean);
    procedure SetWrapOtions;
  protected
    procedure SetTexture(const Value: PTextureArea); override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure LoadFromFile(const FileName: string; AInsertToMap: boolean = false; TrilinearFilter: boolean = false);
    procedure LoadFromStream(Stream: TStream; const Name: string; AInsertToMap: boolean = false; TrilinearFilter: boolean = false);
    property AutoFit: boolean read FAutoFit write FAutoFit;
    property Size: TVec2f read FSize write FSize;
    property AsPartMap: boolean read FAsPartMap;
    property Image: TBlackSharkPicture read GetImage write SetImage;
    { sets an option wrap to the GL_REPEAT }
    property Wrap: boolean read FWrap write SetWrap;
    { if true then used the option wrap as the GL_REPEAT, else GL_MIRRORED_REPEAT }
    property WrapReapeated: boolean read FWrapReapeated write SetWrapReapeated;
    property TrilinearFilter: boolean read FTrilinearFilter write FTrilinearFilter;
  end;

  TGrid = class(TCanvasObjectP)
  private
    FSize: TVec2f;
    FStepY: BSFloat;
    FHorLines: boolean;
    FVertLines: boolean;
    FStepX: BSFloat;
    FClosed: boolean;
    FWidthLines: BSFloat;
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Size: TVec2f read FSize write FSize;
    property StepX: BSFloat read FStepX write FStepX;
    property StepY: BSFloat read FStepY write FStepY;
    property VertLines: boolean read FVertLines write FVertLines;
    property HorLines: boolean read FHorLines write FHorLines;
    property Closed: boolean read FClosed write FClosed;
    property WidthLines: BSFloat read FWidthLines write FWidthLines;
  end;

  TRoundRect = class(TCanvasObjectP)
  private
    FFill: boolean;
    FSize: TVec2f;
    FRadiusRound: BSFloat;
    FWidthLine: BSFloat;
    procedure SetRadiusRound(const Value: BSFloat);
    procedure SetSize(const Value: TVec2f);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); override;
    property Fill: boolean read FFill write FFill;
    property Size: TVec2f read FSize write SetSize;
    property RadiusRound: BSFloat read FRadiusRound write SetRadiusRound;
    { <summary> Width of line. Actual only when Fill = false </summury> }
    property WidthLine: BSFloat read FWidthLine write FWidthLine;
  end;

  TRoundRectTextured = class(TRoundRect)
  private
    function GetTexture: PTextureArea;
    procedure SetTexture(const Value: PTextureArea);
  protected
    function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property Texture: PTextureArea read GetTexture write SetTexture;
  end;

  TTrapezeTemplate = class(TCanvasObjectP)
  private
    FLowerBase: BSFloat;
    FUpperBase: BSFloat;
    FFill: boolean;
    FWidthLine: BSFloat;
    FHeightBwBases: BSFloat;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    property UpperBase: BSFloat read FUpperBase write FUpperBase;
    property LowerBase: BSFloat read FLowerBase write FLowerBase;
    property HeightBwBases: BSFloat read FHeightBwBases write FHeightBwBases;
    property Fill: boolean read FFill write FFill;
    { <summary> Width of line. Actual only when Fill = false </summury> }
    property WidthLine: BSFloat read FWidthLine write FWidthLine;
  end;

  TTrapeze = class(TTrapezeTemplate)
  protected
    procedure DoBuild; override;
  public
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); override;
  end;

  TRoundTrapeze = class(TTrapezeTemplate)
  private
    FRadiusRound: BSFloat;
    procedure SetRadiusRound(const Value: BSFloat);
  protected
    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f); override;
    property RadiusRound: BSFloat read FRadiusRound write SetRadiusRound;
  end;

  { TFreeShape }

  TFreeShape = class(TCanvasObjectP)
  private
    type
      TPoints    = TBlackSharkTesselator.TListPoints.TSingleListHead;
      TContours  = TBlackSharkTesselator.TListContours.TSingleListHead;
      TIntrpFunc = procedure of object;
  private
    FPoints: TPoints;
    FContours: TContours;
    FInterpolateSpline: TInterpolateSpline;
    FuncIntrp: array [TInterpolateSpline] of TIntrpFunc;
    FQualityInterpolate: BSFloat;
    procedure SplineInterpolateBezier;
    procedure SplineInterpolateCubic;
    procedure SplineInterpolateCubicHermite;
    procedure SplineNoInterpolate;
  protected

    procedure DoBuild; override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    procedure AddContour(const AContour: array of TVec2f); overload;
    procedure AddContour(const AContour: TListVec<TVec2f>); overload;
    procedure AddContour(const AContour: array of TVec3f); overload;
    procedure BeginContour;
    procedure AddPoint(const APoint: TVec2f);
    procedure EndContour;
    procedure Clear;
    procedure Save(const FileName: string);
    property Interpolate: TInterpolateSpline read FInterpolateSpline write FInterpolateSpline;
    property QualityInterpolate: BSFloat read FQualityInterpolate write FQualityInterpolate;
  end;

  TCanvasEvent = IBEmptyEvent;
  TCanvasEventObserver = IBEmptyEventObserver;

  { TBCanvas }

  { The class is a simple group 2d objects. An every contained 2d object is
    TCanvasObject, but, it can contain any other child objects, including 3d }

  TBCanvas = class
  private
    FStickOnScreen: boolean;
    FFont: IBlackSharkFont;
    SizeFontFixed: BSFloat;
    ScalingFont: boolean;
    ObsrvrMoveFrustum: IBEmptyEventObserver;
    ObsrvrResizeVP: IBResizeWindowEventObserver;

    FOnReplaceFont: TCanvasEvent;
    FOnAfterRealgnObjects: TCanvasEvent;
    FOnAfterScale: TCanvasEvent;
    FOnCreateObject: TCanvasEvent;
    FOnFreeObject: TCanvasEvent;
    FOnChangeFont: TCanvasEvent;
    FOnBeforeCanvasClear: TCanvasEvent;

    ChangeFontObsrv: IBEmptyEventObserver;

    FOwner: TObject;
    FUpdatingOfOrientation: boolean;

    FScale: BSFloat;
    FScaleInv: BSFloat;
    FScreenPerimeterScaleStartInv: BSFloat;

    procedure MoveFrustumEvent({%H-}const Data: BEmpty);
    procedure OnResizeViewport({%H-}const Data: BResizeEventData);
    procedure SetStickOnScreen(AValue: boolean);
    function GetFont: IBlackSharkFont;
    function GetModalLevel: int32;
    procedure SetModalLevel(const Value: int32);
    //function GetTopLayer: int32;
    procedure OnChangeFontEvent({%H}const Value: BEmpty);
    procedure SetScalable(const Value: boolean);
    function GetOnAfterRealgnObjects: TCanvasEvent;
    function GetOnCreateObject: TCanvasEvent;
    function GetOnFreeObject: TCanvasEvent;
    function GetOnAfterScale: TCanvasEvent;
    function GetOnBeforeCanvasClear: TCanvasEvent;
  protected
    FRenderer: TBlackSharkRenderer;
    FScalable: boolean;
    { an internal object to have possibility to freeze a position and orientation
      (for it a property StickOnScreen must be true) if change a Frustum
      transformations }
    FRootObject: TGraphicObject;
    { to stick the canvas at viewport }
    procedure DoOrientation;
    procedure OnCreateCanvasObject(CanvasObject: TCanvasObject); virtual;
    procedure OnFreeCanvasObject(CanvasObject: TCanvasObject); virtual;
    procedure SetFont(const AValue: IBlackSharkFont); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AOwner: TObject);
    destructor Destroy; override;
    { delete all TCanvasObject are belonging the canvas }
    procedure Clear; virtual;
    { creates empty canvas object type CanvasObjectClass }
    function CreateEmptyCanvasObject: TCanvasObject; overload;
    function CreateEmptyCanvasObject(Parent: TCanvasObject): TCanvasObject; overload;
    procedure RealignObjects;
    property Owner: TObject read FOwner;
    property RootObject: TGraphicObject read FRootObject;
    { if StickOnScreen = true, independly from camera (Renderer.Frustum) position canvas
      will "on screen" (follow to camera); but you not ban change MVP any containing
      TCanvasObject; I couldn't figure it out myself how MUST be behavior right :) }
    property StickOnScreen: boolean read FStickOnScreen write SetStickOnScreen;
    property Font: IBlackSharkFont read GetFont write SetFont;
    property Renderer: TBlackSharkRenderer read FRenderer;
    { scalable mode switcher }
    property Scalable: boolean read FScalable write SetScalable;
    property Scale: BSFloat read FScale;
    property ScaleInv: BSFloat read FScaleInv;
    { event set new font }
    property ModalLevel: int32 read GetModalLevel write SetModalLevel;
    property UpdatingOfOrientation: boolean read FUpdatingOfOrientation;
    { event of create canvas object (TCanvasObject) }
    property OnCreateObject: TCanvasEvent read GetOnCreateObject;
    property OnFreeObject: TCanvasEvent read GetOnFreeObject;
    property OnChangeFont: TCanvasEvent read FOnChangeFont;
    property OnAfterRealgnObjects: TCanvasEvent read GetOnAfterRealgnObjects;
    property OnAfterScale: TCanvasEvent read GetOnAfterScale;
    property OnReplaceFont: TCanvasEvent read FOnReplaceFont;
    property OnBeforeCanvasClear: TCanvasEvent read GetOnBeforeCanvasClear;
  end;

function CreateCanvasEventObserver(const ACanvasEvent: TCanvasEvent; ObserverProc: TGenericRecieveProc<BEmpty>): TCanvasEventObserver;

implementation

uses
  {$ifdef ultibo}
    gles20
  {$else}
    bs.gl.es
  {$endif}
  , bs.exceptions
  , bs.config
  , bs.math
  , bs.frustum
  , bs.utils
  , bs.strings
  ;

function CreateCanvasEventObserver(const ACanvasEvent: TCanvasEvent; ObserverProc: TGenericRecieveProc<BEmpty>): TCanvasEventObserver;
begin
  Result := CreateEmptyObserver(ACanvasEvent, ObserverProc);
end;

{ TCanvasObject }

procedure TCanvasObject.AdjustAnchorsForClientAlign;
begin
  Anchors[aLeft] := false;
  Anchors[aTop] := false;
  Anchors[aRight] := false;
  Anchors[aBottom] := false;
  Align := TObjectAlign.oaClient;
end;

procedure TCanvasObject.AfterConstruction;
begin
  inherited;
  FData.DragResolve := true;
  FData.DepthTest := false;
  CalcBB;
  FCanvas.OnCreateCanvasObject(Self);
end;

procedure TCanvasObject.AfterScaleModeChange;
var
  i: int32;
  ch: TObject;
begin

  if FBanScalableMode then
  begin
    for i := FData.ChildrenCount - 1 downto 0 do
    begin
      ch := FData.Child[i].Owner;
      if not Assigned(ch) then
        continue;
      {$ifdef DEBUG_BS}
      if ch is TCanvasObject then
      {$endif}
        TCanvasObject(ch).AfterScaleModeChange
      {$ifdef DEBUG_BS}
      else
        raise Exception.Create('Error Message')
      {$endif};
    end;
  end else
  begin

    CalcPercentPos;


    for i := FData.ChildrenCount - 1 downto 0 do
    begin
      ch := FData.Child[i].Owner;
      if not Assigned(ch) then
        continue;
      {$ifdef DEBUG_BS}
      if ch is TCanvasObject then
      {$endif}
        TCanvasObject(ch).AfterScaleModeChange
      {$ifdef DEBUG_BS}
      else
        raise Exception.Create('Error Message')
      {$endif};
    end;

  end;

end;

procedure TCanvasObject.AnchorsReset;
begin
  FPatternAlignVert.AnchorLeft := false;
  FPatternAlignVert.AnchorRight := false;
  FPatternAlignHor.AnchorLeft := false;
  FPatternAlignHor.AnchorLeft := false;
  FCountAnchors := 0;
end;

procedure TCanvasObject.BeforeDestruction;
begin
  FCanvas.OnFreeCanvasObject(Self);
  inherited;
end;

procedure TCanvasObject.Build;
var
  pos: TVec2f;
  prnt: TCanvasObject;
begin
  if FIsBuilding then
    exit;

  FIsBuilding := true;
  try
    HandleCMVP := nil;
    pos := FPosition2d;
    SetDefaultSizeLeftTopAnchors;
    FData.Mesh.Clear;
    if Canvas.Scalable and not FBanScalableMode then
      FData.ServiceScale := BSConfig.VoxelSize*Canvas.Scale
    else
      FData.ServiceScale := BSConfig.VoxelSize;

    SubscribeMvpChangeEvent;

    DoBuild;

    Reload;

    if FPatternAlignHor.AnchorRight or FPatternAlignVert.AnchorRight or (FAlign <> TObjectAlign.oaNone) then
    begin
      prnt := Parent;
      if Assigned(prnt) then
        prnt.RealignChildren
      else
        Canvas.RealignObjects;
    end else
      SetCanvasObjectPosition(pos.X, pos.Y, FData.BaseInstance);

  finally
    FIsBuilding := false;
  end;

end;

function TCanvasObject.GetAbsolutePosition2d: TVec2f;
var
  prnt: TCanvasObject;
begin
  Result := Position2d;
  prnt := Parent;
  while Assigned(prnt) and (prnt.FCanvas = FCanvas) do
  begin
    Result := Result + prnt.Position2d;
    prnt := prnt.Parent;
  end;
end;

function TCanvasObject.GetAnchor(Index: TAnchor): boolean;
begin
  Result := false;
  case Index of
    aLeft: Result := FPatternAlignHor.AnchorLeft;
    aRight: Result := FPatternAlignHor.AnchorRight;
    aTop: Result := FPatternAlignVert.AnchorLeft;
    aBottom: Result := FPatternAlignVert.AnchorRight;
  end;
end;

function TCanvasObject.GetAngle: TVec3f;
begin
  Result := Data.Angle;
end;

function TCanvasObject.GetColor: TColor4f;
begin
  Result := FData.Color;
end;

function TCanvasObject.GetLayer2dAbsolute: int32;
var
  p: TCanvasObject;
begin
  p := Parent;
  Result := FLayer2d;
  while Assigned(p) do
  begin
    inc(Result, p.FLayer2d);
    p := p.Parent;
  end;
end;

function TCanvasObject.GetMarginBottom: BSFloat;
begin
  Result := FPatternAlignVert.MarginRight;
end;

function TCanvasObject.GetMarginLeft: BSFloat;
begin
  Result := FPatternAlignHor.MarginLeft;
end;

function TCanvasObject.GetMarginRight: BSFloat;
begin
  Result := FPatternAlignHor.MarginRight;
end;

function TCanvasObject.GetMarginTop: BSFloat;
begin
  Result := FPatternAlignVert.MarginLeft;
end;

function TCanvasObject.GetMinHeight: BSFloat;
begin
  Result := FPatternAlignVert.MinSize;
end;

function TCanvasObject.GetMinWidth: BSFloat;
begin
  Result := FPatternAlignHor.MinSize;
end;

function TCanvasObject.Get3dPositionInsideSelf(X, Y: BSFloat): TVec3f;
begin
  // calculate a 3d position relatively self space
  Result.X := (X - FData.Mesh.FBoundingBox.x_max);
  Result.Y := (FData.Mesh.FBoundingBox.y_max - Y);
  Result.z := -FPositionZ + (FLayer2d + 1) * FCanvas.FRenderer.Frustum.DISTANCE_2D_BW_LAYERS;
end;

function TCanvasObject.Get2dPositionInsideSelf(ScreenX, ScreenY: int32): TVec2f;
var
  isHit: boolean;
begin
  Result := Get2dPositionInsideSelf(ScreenX, ScreenY, isHit);
end;

function TCanvasObject.Get2dPositionInsideSelf(ScreenX, ScreenY: int32; out IsHit: boolean): TVec2f;
var
  point: TVec3f;
  point2d: TVec2f;
  absPos2d: TVec2f;
begin
  Result := vec2(0.0, 0.0);
  if FCanvas.Renderer.HitTestInstance(ScreenX, ScreenY, FData.BaseInstance, point) then
  begin
    IsHit := true;
    point2d := FCanvas.Renderer.ScenePositionToScreenf(point);
    absPos2d := AbsolutePosition2d;
    Result := vec2(point2d.x - absPos2d.x, point2d.y - absPos2d.y);
  end else
    IsHit := false;
end;

function TCanvasObject.GetParent: TCanvasObject;
begin
  if Assigned(FData.Parent) and (FData.Parent <> FCanvas.FRootObject) then
    Result := TCanvasObject(FData.Parent.Owner)
  else
    Result := nil;
end;

function TCanvasObject.GetParentSize: TVec2f;
var
  k: BSfloat;
begin
  if Assigned(FData.Parent) and (FData.Parent <> FCanvas.FRootObject) then
  begin
    if Assigned(FData.Parent.Mesh) then
    begin
      k := FData.Parent.ServiceScale*BSConfig.VoxelSizeInv;
      Result.x := k*(FData.Parent.Mesh.FBoundingBox.x_max - FData.Parent.Mesh.FBoundingBox.x_min);
      Result.y := k*(FData.Parent.Mesh.FBoundingBox.y_max - FData.Parent.Mesh.FBoundingBox.y_min);
    end else
      Result := vec2(0.0, 0.0);
  end else
    Result := vec2(FCanvas.Renderer.WindowWidth, FCanvas.Renderer.WindowHeight);
end;

function TCanvasObject.HasAncestor(Ancestor: TCanvasObject): boolean;
var
  p: TCanvasObject;
begin
  p := Parent;
  while Assigned(p) do
  begin
    if p = Ancestor then
      exit(true);
    p := p.Parent;
  end;
  Result := false;
end;

procedure TCanvasObject.Hide(AReleaseGraphicsData: boolean);
begin
  if AReleaseGraphicsData then
    FData.Clear
  else
    FData.Hidden := true;
end;

procedure TCanvasObject.CalcBB;
var
  m: TMatrix4f;
begin
  if Assigned(FData.Mesh) then
  begin
    { calculate BB in local coordinates }
    if FIndependent2dSizeFromMVP then
    begin
      FModelBB := FData.Mesh.FBoundingBox*Canvas.Scale;
    end else
    begin
      FModelBB := FData.Mesh.FBoundingBox*BSConfig.VoxelSizeInv;
      m := FData.BaseInstance.ModelMatrix;
      m.M3 := m.M3*BSConfig.VoxelSizeInv;
      if Canvas.StickOnScreen or Assigned(Parent) then
      begin
        Box3Recalc(FModelBB, m);
      end else
      begin
        //FModelBB := FData.BaseInstance.BoundingBox*BSConfig.VoxelSizeInv;
        // to zero position relative frustum; that is allow see real projection BB
        // (with all distortions) on frustum plane in zero position: (0.0, 0.0, 1.0);
        // on the way we can calculate left/top position relative renderer's viewport (screen)
        Box3Recalc(FModelBB, m*FCanvas.Renderer.Frustum.ViewMatrix);
      end;
    end;
    // left/top position relative renderer's viewport in scene
    FTopLeft := vec3(FModelBB.x_min, FModelBB.y_max, FModelBB.z_max);
    FModelBB.IsPoint := FData.Mesh.FBoundingBox.IsPoint;
    FWidth := round(FModelBB.x_max - FModelBB.x_min);
    FHeight := round(FModelBB.y_max - FModelBB.y_min);

  end else
  begin
    FModelBB.Max := TVec3f(FData.BaseInstance.ModelMatrix.M3);
    FModelBB.Min := FModelBB.Max;
    FModelBB.IsPoint := true;
    FTopLeft := FModelBB.Min;
    FWidth := 0;
    FHeight := 0;
  end;
end;

procedure TCanvasObject.CalcPercentPos;
begin
  if Canvas.Scalable and not BanScalableMode and not BanScalableModePos then
    FStartScalePos := FPosition2d*Canvas.ScaleInv
  else
    FStartScalePos := FPosition2d;
end;

function TCanvasObject.Center: TVec2f;
begin
  Result := vec2(FWidth*0.5, FHeight*0.5);
end;

procedure TCanvasObject.OnChangeMVP(const Value: BTransformData);
var
  vp: TVec3f;
  d: BSFloat;
  ps: TVec2f;
begin

  if FCanvas.UpdatingOfOrientation then
    exit;

  CalcBB;

  if Setting2dPos or (Assigned(Parent) and Parent.Setting2dPos)then
    exit;

  // translate 3d-position (center) of the object to 2d in viewport of renderer;
  vp := PlanePointProjection(FCanvas.Renderer.Frustum.DEFAULT_NEAR_PLANE,
    vec3(FTopLeft.x, FTopLeft.y, FCanvas.Renderer.Frustum.DEFAULT_POSITION.z - FCanvas.Renderer.Frustum.DistanceNearPlane), d);

  if Assigned(Parent) then
  begin
    ps := GetParentSize;
    FPosition2d.x := round(ps.Width  * 0.5 + vp.x);
    FPosition2d.y := round(ps.Height * 0.5 - vp.y);
    //FPositionZ := Parent.PositionZ-(vp.z+d)*BSConfig.VoxelSizeInv;
  end else
  begin
    FPosition2d.x := round(FCanvas.Renderer.WindowWidth  * 0.5 + vp.x);
    FPosition2d.y := round(FCanvas.Renderer.WindowHeight * 0.5 - vp.y);
    //FPositionZ := (vp.z+d)*BSConfig.VoxelSizeInv;
  end;

  if not FIsBuilding and (FAlign <> TObjectAlign.oaNone) then
  begin
    TryRealign;
  end;

end;

procedure TCanvasObject.ConnectChild(const ToPosition, OnChildPosition: TVec2f; Child: TCanvasObject);
var
  pos: TVec2f;
begin
  pos := ToPosition - OnChildPosition;
  Child.Position2d := pos;
end;

procedure TCanvasObject.SetAlign(const Value: TObjectAlign);
begin
  FAlign := Value;
  ReloadAnchorsAlign;
  TryRealign;
end;

procedure TCanvasObject.SetAnchor(Index: TAnchor; const Value: boolean);
begin

  case Index of
    aLeft: begin
      if FPatternAlignHor.AnchorLeft = Value then
        exit;
      FPatternAlignHor.AnchorLeft := Value;
    end;
    aRight: begin
      if FPatternAlignHor.AnchorRight = Value then
        exit;
      FPatternAlignHor.AnchorRight := Value;
    end;
    aTop: begin
      if FPatternAlignVert.AnchorLeft = Value then
        exit;
      FPatternAlignVert.AnchorLeft := Value;
    end;
    aBottom: begin
      if FPatternAlignVert.AnchorRight = Value then
        exit;
      FPatternAlignVert.AnchorRight := Value;
    end;
  end;

  if Value then
    inc(FCountAnchors)
  else
    dec(FCountAnchors);

  SetDefaultSizeRightBottomAnchors;
  SetDefaultSizeLeftTopAnchors;

  TryRealign;

end;

procedure TCanvasObject.SetAngle(const Value: TVec3f);
begin
  FData.Angle := Value;
end;

procedure TCanvasObject.SetBanScalableMode(const Value: boolean);
begin
  if FBanScalableMode = Value then
    exit;
  FBanScalableMode := Value;
  Data.ServiceScale := BSConfig.VoxelSize;
  AfterScaleModeChange;
end;

procedure TCanvasObject.SetColor(const Value: TColor4f);
begin
  FData.Color := Value;
end;

procedure TCanvasObject.SetDefaultSizeLeftTopAnchors;
begin
  if FPatternAlignHor.AnchorLeft then
    FPatternAlignHor.MarginLeft := FPosition2d.X;
  if FPatternAlignVert.AnchorLeft then
    FPatternAlignVert.MarginLeft := FPosition2d.Y;
end;

procedure TCanvasObject.SetDefaultSizeRightBottomAnchors;
var
  ps: TVec2f;
begin
  ps := GetParentSize;
  if FPatternAlignHor.AnchorRight then
    FPatternAlignHor.MarginRight := ps.X - FPosition2d.X - Width;
  if FPatternAlignVert.AnchorRight then
    FPatternAlignVert.MarginRight := ps.Y - FPosition2d.Y - Height;
end;

procedure TCanvasObject.SetHeight(const Value: BSFloat);
begin
  FHeight := Value;
end;

procedure TCanvasObject.SetLayer2d(const Value: int32);
begin
  if FLayer2d = Value then
    exit;
  FLayer2d := Value;
  if Assigned(FData) then
    SetCanvasObjectPosition(FPosition2d.X, FPosition2d.Y, FData.BaseInstance);
end;

function TCanvasObject.GetIsVisible: boolean;
begin
  Result := Assigned(FData) and FCanvas.Renderer.SceneInstanceToRenderInstance(FData.BaseInstance).Visible;
end;

procedure TCanvasObject.SetMarginBottom(const Value: BSFloat);
begin
  FPatternAlignVert.MarginRight := Value;
  TryRealign;
end;

procedure TCanvasObject.SetMarginLeft(const Value: BSFloat);
begin
  FPatternAlignHor.MarginLeft := Value;
  TryRealign;
end;

procedure TCanvasObject.SetMarginRight(const Value: BSFloat);
begin
  FPatternAlignHor.MarginRight := Value;
  TryRealign;
end;

procedure TCanvasObject.SetMarginTop(const Value: BSFloat);
begin
  FPatternAlignVert.MarginLeft := Value;
  TryRealign;
end;

procedure TCanvasObject.SetMinHeight(const Value: BSFloat);
begin
  FPatternAlignVert.MinSize := Value;
  if (Value > Height) then
    Resize(Width, Value);
end;

procedure TCanvasObject.SetMinWidth(const Value: BSFloat);
begin
  FPatternAlignHor.MinSize := Value;
  if (Value > Width) then
    Resize(Value, Height);
end;

procedure TCanvasObject.SetIndependent2dSizeFromMVP(const Value: boolean);
begin
  if FIndependent2dSizeFromMVP = Value then
    exit;
  FIndependent2dSizeFromMVP := Value;
  CalcBB;
  Position2d := FPosition2d;
end;

procedure TCanvasObject.SetCanvasObjectPosition(X, Y: BSFloat; CanvasObjectInstance: PGraphicInstance);
var
  z: BSFloat;
  p: TVec3f;
  s_half: TVec2f;
  sp_half: TVec2f;
  parent_size: TVec2f;
begin
  if Setting2dPos then
    exit;
  Setting2dPos := true;
  try

    s_half := vec2(BSConfig.VoxelSize*FWidth*0.5, BSConfig.VoxelSize*FHeight*0.5);
    z := (-FPositionZ*BSConfig.VoxelSize + FLayer2d*Canvas.Renderer.Frustum.DISTANCE_2D_BW_LAYERS);

    // calculate 3d position
    if Assigned(Data.Parent) and (Data.Parent <> FCanvas.FRootObject) then
    begin
      parent_size := GetParentSize;
      sp_half := vec2(BSConfig.VoxelSize*parent_size.Width*0.5, BSConfig.VoxelSize*parent_size.Height*0.5);
    end else
      sp_half := vec2(FCanvas.Renderer.Frustum.NearPlaneHalfWidth, FCanvas.Renderer.Frustum.NearPlaneHalfHeight);

    p := vec3(s_half.x + (X*BSConfig.VoxelSize - sp_half.x), -s_half.y - (Y*BSConfig.VoxelSize - sp_half.y), z);

    FData.SetPositionInstance(CanvasObjectInstance, p);
    FPosition2d := vec2(X, Y);

  finally
    Setting2dPos := false;
  end;
end;

procedure TCanvasObject.SetPaddingBottom(const Value: BSFloat);
begin
  FPaddingBottom := Value;
  RealignChildren;
end;

procedure TCanvasObject.SetPaddingLeft(const Value: BSFloat);
begin
  FPaddingLeft := Value;
  RealignChildren;
end;

procedure TCanvasObject.SetPaddingRight(const Value: BSFloat);
begin
  FPaddingRight := Value;
  RealignChildren;
end;

procedure TCanvasObject.SetPaddingTop(const Value: BSFloat);
begin
  FPaddingTop := Value;
  RealignChildren;
end;

procedure TCanvasObject.SetParent(const AValue: TCanvasObject);
begin
  if Parent = AValue then
    exit;
  Setting2dPos := true;
  try
    if Assigned(AValue) then
    begin
      FData.Parent := AValue.Data;
    end else
    begin
      FData.Parent := FCanvas.FRootObject;
    end;
  finally
    Setting2dPos := false;
  end;
end;

procedure TCanvasObject.SetPosition2d(const AValue: TVec2f);
begin

  SetCanvasObjectPosition(AValue.X, AValue.Y, FData.BaseInstance);

  SetDefaultSizeLeftTopAnchors;

  //if (FCountAnchors = 0) or (not FAnchors[aBottom] and not FAnchors[aTop]) or (not FAnchors[aRight] and not FAnchors[aLeft]) then
    CalcPercentPos;

end;

procedure TCanvasObject.SetPositionZ(const Value: BSFloat);
begin
  FPositionZ := Value;
  SetCanvasObjectPosition(FPosition2d.X, FPosition2d.Y, FData.BaseInstance);
end;

procedure TCanvasObject.SetWidth(const Value: BSFloat);
begin
  FWidth := Value;
end;

procedure TCanvasObject.Show;
begin
  FData.Hidden := false;
  if Assigned(FData.Mesh) and (FData.Mesh.CountVertex = 0) then
    Build;
end;

procedure TCanvasObject.SubscribeMvpChangeEvent;
begin
  HandleCMVP := CreateChangeMvpObserver(FData.EventChangeMVP, OnChangeMVP);
end;

procedure TCanvasObject.ToParentCenter;
var
  sp: TVec2f;
begin
  sp := GetParentSize;
  Position2d := vec2((sp.Width - Width) * 0.5, (sp.Height - Height) * 0.5);
end;

function TCanvasObject.ToScene(const Value: TVec2f): TVec2f;
begin
  Result.x := BSConfig.VoxelSize * round(Value.x);
  Result.y := BSConfig.VoxelSize * round(Value.y);
end;

procedure TCanvasObject.TryRealign;
var
  prnt: TCanvasObject;
begin
  if not FIsBuilding then
  begin
    prnt := Parent;
    if Assigned(prnt) then
      prnt.RealignChildren
    else
      Canvas.RealignObjects;
  end;
end;

function TCanvasObject.ToScene(Value: BSFloat): BSFloat;
begin
  Result := BSConfig.VoxelSize * round(Value);
end;

procedure TCanvasObject.RealignChildren;
var
  ClientSize: TVec2f;
  PaddingHor: TVec2f;
  PaddingVert: TVec2f;
  i: int32;
  go: TGraphicObject;
begin
  ClientSize := vec2(FWidth, FHeight);
  PaddingHor.left := PaddingLeft;
  PaddingHor.right := PaddingRight;
  PaddingVert.left := PaddingTop;
  PaddingVert.right := PaddingBottom;
  for i := 0 to FData.ChildrenCount - 1 do
  begin
    go := FData.Child[i];
    if go.Owner is TCanvasObject then
    begin
      TCanvasObject(go.Owner).DoAlign(ClientSize, PaddingHor, PaddingVert);
    end;
  end;
end;

procedure TCanvasObject.Reload;
begin
  FData.ChangedMesh;
  //if FData.StaticObject then
  //	FData.ChangedMesh
  //else
  //  CalcBB;
end;

procedure TCanvasObject.ReloadAnchorsAlign;
var
  old_hor: TPattenAlign;
  old_ver: TPattenAlign;
begin
  old_hor := FPatternAlignHor;
  old_ver := FPatternAlignVert;
  FPatternAlignVert := GetPatternAlign(FAlign, false);
  FPatternAlignHor := GetPatternAlign(FAlign, true);
  FPatternAlignVert.Assign(old_ver);
  FPatternAlignHor.Assign(old_hor);
  old_hor.Free;
  old_ver.Free;
end;

procedure TCanvasObject.Resize(AWidth, AHeight: BSFloat);
begin
  Width := AWidth;
  Height := AHeight;
  //if FAlign <> TObjectAlign.oaNone then
  //  ReloadAnchorsAlign;
  SetDefaultSizeRightBottomAnchors;
  Build;
end;

function TCanvasObject.RoundWidth(AWidth: BSFloat): BSFloat;
begin
  if Canvas.Scalable and not BanScalableMode and not BanScalableModeSize then
  begin
    Result := round(Canvas.Scale*AWidth);
    if Result = 0 then
      Result := 1;
    Result := Canvas.ScaleInv*Result;
  end else
    Result := AWidth;
end;

constructor TCanvasObject.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  FCanvas := ACanvas;
  FPosition2d := vec2(0.0, 0.0);
  FPatternAlignHor := GetPatternAlign(FAlign, true);
  FPatternAlignVert := GetPatternAlign(FAlign, false);

  { set default Layer2d }
  FLayer2d := 1;

  if Assigned(AParent) then
    FData := CreateGraphicObject(AParent.Data)
  else
    FData := CreateGraphicObject(FCanvas.RootObject);

  FData.ServiceScale := BSConfig.VoxelSize;

  DropObsrv := Data.EventDrop.CreateObserver(GUIThread, Drop);
  if ACanvas.Scalable then
    AfterScaleModeChange;
end;

procedure TCanvasObject.DeleteChildren;
var
  i: int32;
  ch: TObject;
begin
  for i := FData.ChildrenCount - 1 downto 0 do
  begin
    //TCanvasObject(FData.Child[i].Owner).DeleteChildren;
    ch := FData.Child[i].Owner;
    if not Assigned(ch) then
      continue;
    {$ifdef DEBUG_BS}
    if ch is TCanvasObject then
    {$endif}
      ch.Free
    {$ifdef DEBUG_BS}
    else
      raise Exception.Create('Error Message')
    {$endif};
  end;
end;

destructor TCanvasObject.Destroy;
begin
  FPatternAlignVert.Free;
  FPatternAlignHor.Free;
  HandleCMVP := nil;
  DropObsrv := nil;
  DeleteChildren;
  FData.Free;
  inherited;
end;

procedure TCanvasObject.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
var
  new_ps: TVec2f;
  new_sz: TVec2f;
begin
  if FIsAligning then
    exit;

  FIsAligning := true;
  try

    if Canvas.Scalable and not FBanScalableMode then
    begin
      if not FBanScalableModeSize then
      begin
        Setting2dPos := true;
        try
          Data.ServiceScale := BSConfig.VoxelSize*Canvas.Scale;
        finally
          Setting2dPos := false;
        end;
      end;

      if FBanScalableModePos then
      begin
        new_ps := FPosition2d;
      end else
      begin
        new_ps.X := Round(FStartScalePos.x*Canvas.Scale);
        new_ps.Y := Round(FStartScalePos.y*Canvas.Scale);
      end;

      SetCanvasObjectPosition(new_ps.X, new_ps.Y, FData.BaseInstance);

    end else  { if Canvas.Scalable and not FBanScalableMode then }
    begin

      new_sz := vec2(Width, Height);
      new_ps := FPosition2d;

      if FAlign = TObjectAlign.oaClient then
      begin
        new_sz.x := ParentClientAreaSize.x - MarginLeft - MarginRight - ParentPaddingHor.x - ParentPaddingHor.y;
        new_sz.y := ParentClientAreaSize.y - MarginTop - MarginBottom - ParentPaddingVert.x - ParentPaddingVert.y;
        new_ps := vec2(ParentPaddingHor.left + MarginLeft, ParentPaddingVert.left + MarginTop);
      end else
      if FAlign = TObjectAlign.oaCenter then
      begin
        ToParentCenter;
        exit;
      end else
      begin
        FPatternAlignHor.Align(new_ps.x, new_sz.Width, ParentClientAreaSize.Width, ParentPaddingHor);
        FPatternAlignVert.Align(new_ps.y, new_sz.Height, ParentClientAreaSize.Height, ParentPaddingVert);
      end;

      if (abs(new_sz.X - Width) >= 1.0) or (abs(new_sz.Y - Height) >= 1.0) then
      begin
        DoResize(new_sz.X, new_sz.Y);
        Reload;
      end;

      //if (abs(new_ps.X - FPosition2d.X) > EPSILON) or (abs(new_ps.Y - FPosition2d.Y) > EPSILON) then
        SetCanvasObjectPosition(new_ps.X, new_ps.Y, FData.BaseInstance);
    end;

    RealignChildren;

  finally
    FIsAligning := false;
  end;

end;

procedure TCanvasObject.DoBuild;
begin

end;

procedure TCanvasObject.DoResize(AWidth, AHeight: BSFloat);
var
  w, h: BSFloat;
begin
  if (FData.Mesh = nil) then
    exit;
  if (AWidth < FPatternAlignHor.MinSize) then
    w := FPatternAlignHor.MinSize
  else
    w := round(AWidth);
  if (AHeight < FPatternAlignVert.MinSize) then
    h := FPatternAlignVert.MinSize
  else
    h := round(AHeight);

  if (w = Width) and (h = Height) then
    exit;

  FData.Mesh.TransformScale(w - Width, h - Height, 0);

  if not FIsBuilding then
  begin
    Reload;

    if FAlign <> TObjectAlign.oaNone then
      TryRealign;
  end;

end;

procedure TCanvasObject.Drop(const Value: BDragDropData);
//var
//  TransformData: BTransformData;
begin
  //TransformData.BaseHeader := Value.BaseHeader;
  //TransformData.MeshTransformed := false;
  //OnChangeMVP(TransformData);
  CalcPercentPos;
  if FAlign = TObjectAlign.oaNone then
  begin
    SetDefaultSizeLeftTopAnchors;
    SetDefaultSizeRightBottomAnchors;
  end;
end;

{ TCanvasText }

procedure TCanvasText.AfterScaleModeChange;
begin
  inherited AfterScaleModeChange;
  UpdateObservices;
end;

constructor TCanvasText.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  Data.Color := BS_CL_WHITE;
  Data.Interactive := false;
  ObsrvReplace := CreateEmptyObserver(FCanvas.OnReplaceFont, OnReplaceFont);
  FScalableModeToFontSize := true;
  FBanScalableModeSize := true;
  Font := FCanvas.Font;
  SubscribeMvpChangeEvent;
end;

function TCanvasText.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TGraphicObjectText.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

function TCanvasText.CreateCustomFont: IBlackSharkFont;
begin
  Result := BSFontManager.GetFont(FCanvas.Font.Name, TTrueTypeRasterFont);
  Font := Result;
end;

destructor TCanvasText.Destroy;
begin
  ObsrvReplace := nil;
  inherited;
end;

procedure TCanvasText.DoBuild;
begin
  inherited;
  TGraphicObjectText(Data).Build;
end;

procedure TCanvasText.DoResize(AWidth, AHeight: BSFloat);
begin
  //inherited DoResize(AWidth, AHeight);

end;

function TCanvasText.GetBold: boolean;
begin
  Result := Font.Bold;
end;

function TCanvasText.GetBoldWeightX: BSFloat;
begin
  Result := Font.BoldWeightX;
end;

function TCanvasText.GetBoldWeightY: BSFloat;
begin
  Result := Font.BoldWeightY;
end;

function TCanvasText.GetColorLine: TColor4f;
begin
  Result := TGraphicObjectText(Data).ColorLine;
end;

function TCanvasText.GetFont: IBlackSharkFont;
begin
  Result := TGraphicObjectText(Data).Font;
end;

function TCanvasText.GetFontName: string;
begin
  Result := TGraphicObjectText(Data).Font.Name
end;

function TCanvasText.GetIndexLastStringInViewport: int32;
begin
  Result := TGraphicObjectText(Data).IndexLastStringInViewport;
end;

function TCanvasText.GetItalic: boolean;
begin
  Result := Font.Italic;
end;

function TCanvasText.GetItalicWeight: BSFloat;
begin
  Result := Font.ItalicWeight;
end;

function TCanvasText.GetSceneTextData: TGraphicObjectText;
begin
  Result := TGraphicObjectText(Data);
end;

function TCanvasText.GetStrikethrough: boolean;
begin
  Result := TGraphicObjectText(Data).Strikethrough;
end;

function TCanvasText.GetText: string;
begin
  Result := TGraphicObjectText(Data).Text;
end;

function TCanvasText.GetTextAlign: TTextAlign;
begin
  Result := TGraphicObjectText(Data).Align;
end;

function TCanvasText.GetUnderline: boolean;
begin
  Result := TGraphicObjectText(Data).Underline;
end;

function TCanvasText.GetViewportPosition: TVec2f;
begin
  Result := vec2(TGraphicObjectText(Data).OffsetX, TGraphicObjectText(Data).OffsetY);
end;

function TCanvasText.GetViewportSize: TVec2f;
begin
  Result := vec2(TGraphicObjectText(Data).OutToWidth, TGraphicObjectText(Data).OutToHeight);
end;

procedure TCanvasText.OnChangeFontEvent(const Value: BEmpty);
begin
  if ScalingFont then
    exit;
  SizeFontFixed := TGraphicObjectText(Data).Font.SizeInPixels;
end;

procedure TCanvasText.OnReplaceFont(const Value: BEmpty);
begin
  Font := FCanvas.Font;
end;

procedure TCanvasText.OnResizeViewport(const Value: BResizeEventData);
var
  new_s: int32;
begin
  if Canvas.Scalable and not FBanScalableMode and FScalableModeToFontSize then
  begin
    ScalingFont := true;
    try
      //new_s := round((Canvas.Renderer.ScalePerimeterScreen/FScaleScreenPerimStart) * SizeFontFixed);
      new_s := round(Canvas.Scale*SizeFontFixed);
      if new_s <> TGraphicObjectText(Data).Font.SizeInPixels then
      begin
        TGraphicObjectText(Data).Font.SizeInPixels := new_s;
      end;
    finally
      ScalingFont := false;
    end;
  end;
end;

procedure TCanvasText.SetBanScalableMode(const Value: boolean);
begin
  if FBanScalableMode = Value then
    exit;
  inherited SetBanScalableMode(Value);
  UpdateObservices;
end;

procedure TCanvasText.SetBold(const Value: boolean);
begin
  Font.Bold := Value;
end;

procedure TCanvasText.SetBoldWeightX(const Value: BSFloat);
begin
  Font.BoldWeightX := Value;
end;

procedure TCanvasText.SetBoldWeightY(const Value: BSFloat);
begin
  Font.BoldWeightY := Value;
end;

procedure TCanvasText.SetColorLine(const Value: TColor4f);
begin
  TGraphicObjectText(Data).ColorLine := Value;
end;

procedure TCanvasText.SetFont(const Value: IBlackSharkFont);
begin
  TGraphicObjectText(Data).Font := Value;
  SizeFontFixed := TGraphicObjectText(Data).Font.SizeInPixels;
  UpdateObservices;
end;

procedure TCanvasText.SetFontName(const Value: string);
begin
  if Value = TGraphicObjectText(Data).Font.Name then
    exit;
  Font := BSFontManager.GetFont(Value, TTrueTypeRasterFont);
  UpdateObservices;
end;

procedure TCanvasText.SetItalic(const Value: boolean);
begin
  Font.Italic := Value;
end;

procedure TCanvasText.SetItalicWeight(const Value: BSFloat);
begin
  Font.ItalicWeight := Value;
end;

procedure TCanvasText.SetStrikethrough(const Value: boolean);
begin
  TGraphicObjectText(Data).Strikethrough := Value;
end;

procedure TCanvasText.SetText(const AValue: string);
var
  pos: TVec2f;
begin
  pos := FPosition2d;
  TGraphicObjectText(Data).Text := AValue;
  if Anchors[aRight] or Anchors[aBottom] then
    TryRealign
  else
    SetCanvasObjectPosition(pos.X, pos.Y, Data.BaseInstance);
end;

procedure TCanvasText.SetTextAlign(const Value: TTextAlign);
begin
  TGraphicObjectText(Data).Align := Value;
end;

procedure TCanvasText.SetUnderline(const Value: boolean);
begin
  TGraphicObjectText(Data).Underline := Value;
end;

procedure TCanvasText.SetViewportPosition(const Value: TVec2f);
begin
  TGraphicObjectText(Data).BeginChangeProp;
  TGraphicObjectText(Data).OffsetX := Value.x;
  TGraphicObjectText(Data).OffsetY := Value.y;
  TGraphicObjectText(Data).EndChangeProp;
end;

procedure TCanvasText.SetViewportSize(const Value: TVec2f);
begin
  TGraphicObjectText(Data).BeginChangeProp;
  TGraphicObjectText(Data).OutToWidth := Value.x;
  TGraphicObjectText(Data).OutToHeight := Value.y;
  TGraphicObjectText(Data).EndChangeProp;
  UpdateWrapping;
end;

procedure TCanvasText.SetWrap(const Value: Boolean);
begin
  FWrap := Value;
  UpdateWrapping;
end;

procedure TCanvasText.UpdateObservices;
begin
  if (TGraphicObjectText(FData).Font <> Canvas.Font) then
  begin
    ObsrvReplace := nil;
  end else
  begin
    ObsrvReplace := CreateCanvasEventObserver(FCanvas.OnReplaceFont, OnReplaceFont);
  end;

  if Canvas.Scalable and not FBanScalableMode and (TGraphicObjectText(FData).Font <> Canvas.Font) then
  begin
    ObsrvResizeVP := CreateResizeWindowObserver(Canvas.Renderer.EventResize, OnResizeViewport);
    if Assigned(TGraphicObjectText(FData).Font) then
      ObsrvChangeFont := CreateEmptyObserver(TGraphicObjectText(FData).Font.OnChangeEvent, OnChangeFontEvent);
  end else
  begin
    ObsrvResizeVP := nil;
    ObsrvChangeFont := nil;
  end;
end;

procedure TCanvasText.UpdateWrapping;
begin
  if FWrap then
    TGraphicObjectText(Data).TxtProcessor.ViewportWidth := TGraphicObjectText(Data).OutToWidth
  else
    TGraphicObjectText(Data).TxtProcessor.ViewportWidth := 0;
end;

{ TCanvasObjectEmpty }

function TCanvasObjectEmpty.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TGraphicObject.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TBCanvas }

constructor TBCanvas.Create(ARenderer: TBlackSharkRenderer; AOwner: TObject);
begin
  inherited Create;
  FScale := 1.0;
  FScaleInv := 1.0;
  FOwner := AOwner;
  FRenderer := ARenderer;
  FStickOnScreen := true;
  FRootObject := TGraphicObject.Create(nil, nil, ARenderer.Scene);
  FOnReplaceFont := CreateEmptyEvent;
  FOnChangeFont := CreateEmptyEvent;

  DoOrientation;

  if FStickOnScreen then
    ObsrvrMoveFrustum := CreateEmptyObserver(Renderer.EventMoveFrustum, MoveFrustumEvent);

  ObsrvrResizeVP := CreateResizeWindowObserver(FRenderer.EventResize, OnResizeViewport);
end;

function TBCanvas.CreateEmptyCanvasObject(Parent: TCanvasObject): TCanvasObject;
begin
  Result := TCanvasObjectEmpty.Create(Self, Parent);
  Result.Position2d := vec2(0.0, 0.0);
  Result.Data.Interactive := false;
end;

function TBCanvas.CreateEmptyCanvasObject: TCanvasObject;
begin
  Result := TCanvasObjectEmpty.Create(Self, nil);
  Result.Position2d := vec2(0.0, 0.0);
  Result.Data.Interactive := false;
end;

destructor TBCanvas.Destroy;
begin
  Clear;
  ChangeFontObsrv := nil;
  FRootObject.Free;
  FFont := nil;
  inherited;
end;

procedure TBCanvas.Clear;
var
  obj: TObject;
  i: int32;
begin
  if Assigned(FOnBeforeCanvasClear) then
    FOnBeforeCanvasClear.Send(Self);
  for i := FRootObject.ChildrenCount - 1 downto 0 do
  begin
    obj := FRootObject.Child[i].Owner;
    if obj is TCanvasObject then
      TCanvasObject(obj).Free
    else
      raise Exception.Create('Error Message');
  end;
end;

function TBCanvas.GetFont: IBlackSharkFont;
begin
  if FFont = nil then
    Font := BSFontManager.CreateDefaultFont;
  Result := FFont;
end;

function TBCanvas.GetModalLevel: int32;
begin
  Result := FRootObject.ModalLevel;
end;

function TBCanvas.GetOnAfterRealgnObjects: TCanvasEvent;
begin
  if not Assigned(FOnAfterRealgnObjects) then
    FOnAfterRealgnObjects := CreateEmptyEvent;
  Result := FOnAfterRealgnObjects;
end;

function TBCanvas.GetOnAfterScale: TCanvasEvent;
begin
  if not Assigned(FOnAfterScale) then
    FOnAfterScale := CreateEmptyEvent;
  Result := FOnAfterScale;
end;

function TBCanvas.GetOnBeforeCanvasClear: TCanvasEvent;
begin
  if not Assigned(FOnBeforeCanvasClear) then
    FOnBeforeCanvasClear := CreateEmptyEvent;
  Result := FOnBeforeCanvasClear;
end;

function TBCanvas.GetOnCreateObject: TCanvasEvent;
begin
  if not Assigned(FOnCreateObject) then
    FOnCreateObject := CreateEmptyEvent;
  Result := FOnCreateObject;
end;

function TBCanvas.GetOnFreeObject: TCanvasEvent;
begin
  if not Assigned(FOnFreeObject) then
    FOnFreeObject := CreateEmptyEvent;
  Result := FOnFreeObject;
end;

procedure TBCanvas.MoveFrustumEvent(const Data: BEmpty);
begin
  if FStickOnScreen then
    DoOrientation;
end;

procedure TBCanvas.DoOrientation;
var
  q1: TVec4f;
begin
  FUpdatingOfOrientation := true;
  try
    q1 := vec4(-FRenderer.Frustum.Quaternion.x, -FRenderer.Frustum.Quaternion.y, -FRenderer.Frustum.Quaternion.z, FRenderer.Frustum.Quaternion.w);
    FRootObject.BeginUpdateTransformations;
    FRootObject.Quaternion := q1;
    FRootObject.Position := FRenderer.ScreenPosition;
    FRootObject.EndUpdateTransformations;
  finally
    FUpdatingOfOrientation := false;
  end;
end;

procedure TBCanvas.SetFont(const AValue: IBlackSharkFont);
var
  old: IBlackSharkFont;
begin
  if FFont = AValue then
    exit;

  old := FFont;
  FFont := AValue;

  if Assigned(FFont) then
  begin
    if Scalable then
      SizeFontFixed := round(FFont.SizeInPixels*FScaleInv);
    ChangeFontObsrv := CreateEmptyObserver(FFont.OnChangeEvent, OnChangeFontEvent);
  end;

  if Assigned(old) then
  begin
    OnReplaceFont.Send(Pointer(old));
    old := nil;
  end;

  FOnChangeFont.Send(Self);
end;

procedure TBCanvas.SetModalLevel(const Value: int32);
begin
  FRootObject.ModalLevel := Value;
end;

procedure TBCanvas.SetScalable(const Value: boolean);
var
  obj: TObject;
  i: int32;
begin
  if FScalable = Value then
    exit;

  FScalable := Value;
  FScale := 1.0;
  FScaleInv := 1.0;
  FScreenPerimeterScaleStartInv := Renderer.ScalePerimeterScreenInv;
  if Assigned(FFont) then
    SizeFontFixed := FFont.SizeInPixels;

  for i := 0 to FRootObject.ChildrenCount - 1 do
  begin
    obj := FRootObject.Child[i].Owner;
    if obj is TCanvasObject then
    begin
      TCanvasObject(obj).AfterScaleModeChange;
      //TCanvasObject(obj).Data.GenerateModelMatrixFromAllTransformations(TCanvasObject(obj).Data.BaseInstance);
      //TCanvasObject(obj).Build;
    end else
      raise Exception.Create('Error Message');
  end;
end;

procedure TBCanvas.SetStickOnScreen(AValue: boolean);
var
  obj: TObject;
  i: int32;
begin
  if FStickOnScreen = AValue then
    exit;
  FStickOnScreen := AValue;
  if FStickOnScreen then
  begin
    ObsrvrMoveFrustum := CreateEmptyObserver(Renderer.EventMoveFrustum, MoveFrustumEvent);
    if FStickOnScreen then
      DoOrientation;
    for i := 0 to FRootObject.ChildrenCount - 1 do
    begin
      obj := FRootObject.Child[i].Owner;
      if obj is TCanvasObject then
        TCanvasObject(obj).Position2d := TCanvasObject(obj).Position2d
      else
        raise Exception.Create('Error Message');
    end;
  end else
  begin
    ObsrvrMoveFrustum := nil;
    FRootObject.Scale := IDENTITY_VEC3;
    FRootObject.Angle := vec3(0.0, 0.0, 0.0);
  end;
end;

procedure TBCanvas.OnChangeFontEvent(const Value: BEmpty);
begin
  if not ScalingFont then
    SizeFontFixed := Font.SizeInPixels;
  FOnChangeFont.Send(Self);
end;

procedure TBCanvas.OnCreateCanvasObject(CanvasObject: TCanvasObject);
begin
  if FStickOnScreen and not Assigned(ObsrvrMoveFrustum) then
    ObsrvrMoveFrustum := CreateEmptyObserver(Renderer.EventMoveFrustum, MoveFrustumEvent);
  if Assigned(FOnCreateObject) then
    FOnCreateObject.Send(CanvasObject);
end;

procedure TBCanvas.OnFreeCanvasObject(CanvasObject: TCanvasObject);
begin
  if not Assigned(CanvasObject) then
    exit;
  if (FRootObject.ChildrenCount = 1) and (FRootObject.Child[0].Owner = CanvasObject) then
    ObsrvrMoveFrustum := nil;
  if Assigned(FOnFreeObject) then
    FOnFreeObject.Send(CanvasObject);
end;

procedure TBCanvas.OnResizeViewport(const Data: BResizeEventData);
begin
  if Scalable then
  begin
    FScale := Renderer.ScalePerimeterScreen*FScreenPerimeterScaleStartInv;
    FScaleInv := 1/FScale;
    ScalingFont := true;
    try
      Font.SizeInPixels := round(FScale*SizeFontFixed);
    finally
      ScalingFont := false;
    end;
  end;
  RealignObjects;
  if Assigned(FOnAfterScale) and Scalable then
    FOnAfterScale.Send(Self);
end;

procedure TBCanvas.RealignObjects;
var
  i: int32;
  go: TGraphicObject;
  ps: TVec2f;
  PaddingHor: TVec2f;
  PaddingVert: TVec2f;
begin
  ps := vec2(Renderer.WindowWidth, Renderer.WindowHeight);
  PaddingHor.left := 0.0;
  PaddingHor.right := 0.0;
  PaddingVert.left := 0.0;
  PaddingVert.right := 0.0;

  for i := FRootObject.ChildrenCount - 1 downto 0 do
  begin
    go := FRootObject.Child[i];
    if go.Owner is TCanvasObject then
      TCanvasObject(go.Owner).DoAlign(ps, PaddingHor, PaddingVert);
  end;

  if Assigned(FOnAfterRealgnObjects) then
    FOnAfterRealgnObjects.Send(Self);
end;

{ TLine }

procedure TLine.DoBuild;
begin
  inherited DoBuild;
  if FPoints.Count = 2 then
    GenerateLine2d(Data.Mesh, FPoints.Items[0], FPoints.Items[1], RoundWidth(FWidthLine), true, true)
  else
    GeneratePath2d(Data.Mesh, PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, FWidthLine, false, true, FWidthLine = 1.0);
end;

procedure TLine.Build;
begin
  Clear;
  DoAddPoint(FA);
  DoAddPoint(FB);
  inherited Build;
end;

constructor TLine.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  Data.Mesh.TypePrimitive := tpTriangleStrip;
  { merely define direction of the line }
  FB := vec2(0.0, 1.0);
end;

function TLine.GetLength: BSFloat;
begin
  Result := VecLen(FB - FA);
end;

{procedure TLine.SetA(const Value: TVec2f);
begin
  SetPoint(0, Value);
end;

procedure TLine.SetB(const Value: TVec2f);
begin
  SetPoint(1, Value);
end; }

procedure TLine.SetLength(const Value: BSFloat);
var
  v: TVec2f;
begin
  if (FB = FA) then
    v := vec2(0.0, 1.0)
  else
    v := VecNormalize(FB - FA);
  FB := FA + v * Value;
end;

procedure TLine.SetPoint(Index: int32; const Value: TVec2f);
var
  orig: TListVec<TVec2f>;
  points_g: TListVec<TCircle>;
  i: Integer;
begin
  if Index < FOrigins.Count then
  begin

    orig := TListVec<TVec2f>.Create;
    orig.AddList(FOrigins);
    orig.Items[Index] := Value;

    points_g := nil;
    if Assigned(FPointsG) and (FPointsG.Count > 0) then
    begin
      points_g := TListVec<TCircle>.Create;
      points_g.AddList(FPointsG);
      FPointsG.Count := 0;
    end;

    Clear;

    if Assigned(FPointsG) and Assigned(points_g) then
    begin
      FPointsG.AddList(points_g);
      points_g.Free;
    end;

    for i := 0 to orig.Count - 1 do
      DoAddPoint(orig.Items[i]);

    orig.Free;

  end else
    DoAddPoint(Value);
end;

{ TCanvasObjectP }

function TCanvasObjectP.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TColoredVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TCanvasObjectPT }

function TCanvasObjectPT.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

procedure TCanvasObjectPT.SetTexture(const Value: PTextureArea);
begin
  TTexturedVertexes(Data).Texture := Value;
end;

function TCanvasObjectPT.GetTexture: PTextureArea;
begin
  Result := TTexturedVertexes(Data).Texture;
end;

{ TBezierLine }

constructor TBezierLine.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
end;

destructor TBezierLine.Destroy;
begin
  ClearPointsG;
  inherited;
end;

procedure TBezierLine.DoBuild;
begin
  GeneratePath2d(Data.Mesh, PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, RoundWidth(FWidthLine), false, true, RoundWidth(FWidthLine) = 1.0);
end;

function TBezierLine.GetA: TVec2f;
begin
  Result := FOrigins.Items[0];
end;

function TBezierLine.GetB: TVec2f;
begin
  Result := FOrigins.Items[1];
end;

procedure TBezierLine.SetA(const Value: TVec2f);
begin
  SetPoint(0, Value);
end;

procedure TBezierLine.SetB(const Value: TVec2f);
begin
  SetPoint(1, Value);
end;

procedure TBezierLine.SetPoint(Index: int32; const Value: TVec2f);
var
  orig: TListVec<TVec2f>;
  points_g: TListVec<TCircle>;
  i: Integer;
begin
  if Index < FOrigins.Count then
  begin

    orig := TListVec<TVec2f>.Create;
    orig.AddList(FOrigins);
    orig.Items[Index] := Value;

    if Assigned(FPointsG) and (FPointsG.Count > 0) then
    begin
      points_g := TListVec<TCircle>.Create;
      points_g.AddList(FPointsG);
      FPointsG.Count := 0;
    end;

    Clear;

    points_g := nil;
    if Assigned(FPointsG) and Assigned(points_g) then
    begin
      FPointsG.AddList(points_g);
      points_g.Free;
    end;

    for i := 0 to orig.Count - 1 do
      DoAddPoint(orig.Items[i]);

    orig.Free;

  end else
    DoAddPoint(Value);
end;

{ TBezierQuadratic }

procedure TBezierQuadratic.Build;
var
  _p0: TVec3f;
begin
  inherited;
  FIsBuilding := true;
  { so GL_TRIANGLE_STRIP therefore take a middle between two first points }
  _p0 := (Data.Mesh.ReadPoint(0) + Data.Mesh.ReadPoint(1)) * 0.5;
  _p0 := _p0 + vec3(Data.Mesh.FBoundingBox.x_max, -Data.Mesh.FBoundingBox.y_max, 0.0);
  _p0.Y := abs(_p0.Y);
  ConnectChild(Points[0]*Canvas.Scale, TVec2f(_p0)*Canvas.Scale, Self);
  FIsBuilding := false;
end;

procedure TBezierQuadratic.DoBuild;
begin
  TBlackSharkFactoryShapesP.GenerateBezierQuadratic(Data.Mesh, FPoints.Items[0], FPoints.Items[1], FPoints.Items[2], RoundWidth(WidthLine), FQuality);
end;

constructor TBezierQuadratic.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FQuality := 0.1;
end;

function TBezierQuadratic.GetC: TVec2f;
begin
  Result := Points[2];
end;

procedure TBezierQuadratic.SetC(const Value: TVec2f);
begin
  SetPoint(2, Value);
end;

procedure TBezierQuadratic.SetQuality(const Value: BSFloat);
begin
  FQuality := Value;
end;

{ TBezierCubic }

procedure TBezierCubic.DoBuild;
begin
  TBlackSharkFactoryShapesP.GenerateBezierCubic(Data.Mesh, FPoints.Items[0], FPoints.Items[1],
    FPoints.Items[2], FPoints.Items[3], RoundWidth(WidthLine), FQuality);
end;

function TBezierCubic.GetD: TVec2f;
begin
  Result := FOrigins.Items[3];
end;

procedure TBezierCubic.SetD(const Value: TVec2f);
begin
  SetPoint(3, Value);
end;

{ TLinesSequence }

destructor TLinesSequence.Destroy;
begin
  ClearPointsG;
  FPointsG.Free;
  FPoints.Free;
  FOrigins.Free;
  FPointsInterpolated.Free;
  ObsrvOnBeforeCanvasClear := nil;
  inherited;
end;

procedure TLinesSequence.Build;
begin
  CalcOriginPos;

  if Canvas.Scalable and (not BanScalableMode and not BanScalableModeSize) then
    FPosition2d := FOriginPos*Canvas.Scale
  else
    FPosition2d := FOriginPos;

  if (FOriginSize.x < 1) and (FOriginSize.y < 1) then
    exit;

  inherited Build;

  if ShowPoints then
    UpdatePointsPos;
end;

procedure TLinesSequence.SetShowPoints(const Value: boolean);
begin
  if FShowPoints = Value then
    exit;
  FShowPoints := Value;
  if FShowPoints then
  begin
    ObsrvOnBeforeCanvasClear := CreateEmptyObserver(Canvas.OnBeforeCanvasClear, OnBeforeCanvasClear);
    //if Canvas.Scalable and not FBanScalableMode then
    //  ObsrvrResizeVP := CreateResizeWindowObserver(Canvas.Renderer.EventResize, OnResizeViewport);
    if FPointsG = nil then
      FPointsG := TListVec<TCircle>.Create;
    CreateGPoints;
  end else
  begin
    ObsrvOnBeforeCanvasClear := nil;
    TexturePoint := nil;
    //ObsrvrResizeVP := nil;
    ClearPointsG;
  end;
end;

procedure TLinesSequence.ClearPointsG;
var
  i: int32;
begin
  SetLength(Obsers, 0);
  if not Assigned(FPointsG) then
    exit;
  for i := FPointsG.Count - 1 downto 0 do
    FPointsG.Items[i].Free;
  FPointsG.Count := 0;
end;

function TLinesSequence.DoAddPoint(const Point: TVec2f): TCircle;
begin

  if FOrigins.Count > 0 then
    FCurrentLength := FCurrentLength + VecLen(FOrigins.Items[FOrigins.Count - 1] - Point);

  FOrigins.Add(Point);

  FOriginPosition.x := bs.math.Min(FOriginPosition.x, Point.x);
  FOriginPosition.y := bs.math.Min(FOriginPosition.y, Point.y);

  FPosition2d := FOriginPosition;

  CalcPercentPos;

  if FShowPoints then
    Result := CreatePoint(FOrigins.Count - 1)
  else
    Result := nil;
end;

procedure TLinesSequence.OnDrag(const Value: BDragDropData);
var
  p: TCircle;
  i: int32;
begin
  p := TCircle(PGraphicInstance(Value.BaseHeader.Instance).Owner.Owner);
  if not p.Data.IsDrag or IsBuilding then
    exit;
  if Canvas.Scalable and not FBanScalableMode then
  begin
    for i := 0 to CountPoints - 1 do
      FOrigins.Items[i] := FPointsG.Items[i].Position2d*Canvas.ScaleInv;
  end else
    FOrigins.Items[p.Data.TagInt] := p.Position2d;
  Build;
end;

procedure TLinesSequence.SetDirectionY(AValue: int8);
begin
  if FDirectionY = AValue then 
    exit;

  if AValue < 0 then
    FDirectionY := -1
  else
    FDirectionY := 1;
end;

function TLinesSequence.GetPoint(Index: int32): TVec2f;
begin
  Result := FOrigins.Items[Index];
end;

procedure TLinesSequence.SetColor(const Value: TColor4f);
var
  i: Integer;
begin
  if FColorPoints = Color then
  begin
    FColorPoints := Value;
    if ShowPoints then
    begin
      for i := 0 to FPointsG.Count - 1 do
      begin
        FPointsG.Items[i].Color := FColorPoints;
      end;
    end;
  end;
  inherited;
end;

procedure TLinesSequence.SetColorPoints(const Value: TColor4f);
begin
  FColorPoints := Value;
end;

function TLinesSequence.GetPointG(Index: int32): TCircle;
begin
  if FPointsG <> nil then
    Result := FPointsG.Items[Index]
  else
    Result := nil;
end;

procedure TLinesSequence.OnBeforeCanvasClear(const AData: BEmpty);
begin
  if ShowPoints then
    ClearPointsG;
end;

procedure TLinesSequence.UpdatePointsPos;
var
  i: int32;
begin
  if not Assigned(FPointsG) then
    exit;

  for i := 0 to FPointsG.Count - 1 do
    FPointsG.Items[i].Position2d := FOrigins.Items[i]*Canvas.Scale;
end;

constructor TLinesSequence.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FPoints := TListVec3f.Create;
  FOrigins := TListVec2f.Create;
  FDirectionY 	:= 1;
  FWidthLine    := 1;
  FRadiusPoints := 5;
  FOriginPosition.x := 65535.0;
  FOriginPosition.y := 65535.0;
  FColorPoints := Color;
end;

procedure TLinesSequence.CreateGPoints;
var
  i: int32;
begin
  for i := 0 to FOrigins.Count - 1 do
    CreatePoint(i);
end;

function TLinesSequence.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TColoredVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

function TLinesSequence.CreatePoint(Index: int32): TCircle;
begin
  Result := FPointsG.Items[Index];
  if Assigned(Result) then
    exit;

  if Assigned(TexturePoint) then
  begin
    Result := TCircleTextured.Create(Canvas, Parent);
    TCircleTextured(Result).Texture := TexturePoint;
    Result.Radius := round(TexturePoint.Rect.Width) shr 1 + 1;
    TTexturedVertexes(Result.Data).ReplaceColor := true;
  end else
  begin
    Result := TCircle.Create(Canvas, Parent);
    Result.Radius := FRadiusPoints;
  end;
  FPointsG.Items[Index] := Result;
  Result.Data.DragResolve := true;
  Result.Fill := true;
  Result.Color := FColorPoints;
  Result.Layer2d := Layer2dAbsolute + 2;
  Result.BanScalableMode := true;
  Result.Data.TagInt := Index;
  Result.Build;
  SetLength(Obsers, FPointsG.Count);
  Obsers[Index] := Result.Data.EventDrag.CreateObserver(GUIThread, OnDrag);
end;

function TLinesSequence.GetCountPoint: int32;
begin
  Result := FOrigins.Count;
end;

procedure TLinesSequence.SetWidthLine(const Value: BSFloat);
begin
  if FWidthLine = Value then
    exit;
  FWidthLine := round(Value);
  if FWidthLine < 1 then
    FWidthLine := 1;
  FRadiusPoints := FWidthLine * 2;
end;

procedure TLinesSequence.SetPosition2d(const AValue: TVec2f);
var
  i: int32;
  delta: TVec2f;
begin

  if not IsBuilding then
  begin
    delta := FOriginPosition - AValue;
    for i := 0 to FOrigins.Count - 1 do
      FOrigins.Items[i] := FOrigins.Items[i] - delta;

    FOriginPosition := AValue;
    CalcOriginPos;
  end;

  if (FOriginSize.x < 1) and (FOriginSize.y < 1) then
    exit;

  inherited;

  if not IsBuilding then
    UpdatePointsPos;
end;

procedure TLinesSequence.Clear;
begin
  FPoints.Count := 0;
  FOrigins.Count := 0;
  FOriginPosition.x := 65535.0;
  FOriginPosition.y := 65535.0;
  FCurrentLength := 0.0;
  FreeAndNil(FPointsInterpolated);
  Data.Clear;
  ClearPointsG;
end;

procedure TLinesSequence.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
begin
  inherited;
  UpdatePointsPos;
end;

procedure TLinesSequence.CalcOriginPos;
var
  i: int32;
  max_pos: TVec2f;
  par_size: TVec2f;
  origin: TVec2f;
begin
  FOriginPos := vec2(65535.0, 65535.0);
  max_pos := vec2(-65535.0, -65535.0);
  par_size := GetParentSize;
  FPoints.Clear;
  for i := 0 to FOrigins.Count - 1 do
  begin
    origin := FOrigins.Items[i];
    if FDirectionY > 0 then
    	FPoints.Items[i] := vec3(origin.x, par_size.y - origin.y, 0.0)
    else
    	FPoints.Items[i] := vec3(origin.x, origin.y - par_size.y, 0.0);
    FOriginPos.x := bs.math.Min(FOriginPos.x, origin.x);
    FOriginPos.y := bs.math.Min(FOriginPos.y, origin.y);
    max_pos.x := bs.math.Max(max_pos.x, origin.x);
    max_pos.y := bs.math.Max(max_pos.y, origin.y);
  end;
  FOriginSize := max_pos - FOriginPos;
  FOriginMiddle := (FOriginPos + max_pos) * 0.5;
end;

{ TLinesSequenceStroke }

constructor TLinesSequenceStroke.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FColors := TListVec<TColor4f>.Create;
  FColorDistances := TListVec<Double>.Create;
end;

procedure TLinesSequenceStroke.Build;
var
  i, indexColor: int32;
  src: TListVec3f;
  distance, len: double;
  currentColor: TColor4f;
  p, prev_p: TVec2f;
  isLineGL: boolean;
begin
  inherited;

  { distributes colors on all vertexes from control points
    if the object has mesh which contains color in every vertex }

  if TComplexCurveObject(Data).MultiColor then
  begin
    if Assigned(FPointsInterpolated) and (FPointsInterpolated.Count > 0) then
      src := FPointsInterpolated
    else
      src := FPoints;

    distance := 0.0;
    isLineGL := Data.Mesh.TypePrimitive in [TTypePrimitive.tpLines, TTypePrimitive.tpLineStrip];

    indexColor := 0;
    if FColors.Count > 0 then
      currentColor := FColors.Items[0]
    else
      currentColor := Color;

    prev_p := TVec2f(src.Items[0]);

    for i := 0 to src.Count - 1 do
    begin

      p := TVec2f(src.Items[i]);
      len := VecLen(p - prev_p);
      distance := distance + len;
      if (indexColor < FColors.Count - 1) then
      begin
        if (len < EPSILON) and (distance >= FColorDistances.Items[indexColor+1]) then
          inc(indexColor);
      end;

      prev_p := p;
      currentColor := FColors.Items[indexColor];

      if isLineGL then
      begin
        Data.Mesh.Write(i, vcColor, currentColor);
        Data.Mesh.Write(i, vcIndex, distance);
      end else
      begin
        Data.Mesh.Write(i shl 1, vcColor, currentColor);
        Data.Mesh.Write((i shl 1)+1, vcColor, currentColor);
        Data.Mesh.Write(i shl 1, vcIndex, distance);
        Data.Mesh.Write((i shl 1)+1, vcIndex, distance);
      end;
    end;

    Data.ChangedMesh;
  end;
end;

procedure TLinesSequenceStroke.Clear;
begin
  inherited;
  SumRemainder := 0.0;
  FColors.Clear;
  FColorDistances.Clear;
end;

procedure TLinesSequenceStroke.WriteColorToPoint(AIndexPoint: int32; const AValue: TColor4f);
begin
  if Data.Mesh.TypePrimitive in [TTypePrimitive.tpLines, TTypePrimitive.tpLineStrip] then
  begin
    Data.Mesh.Write(AIndexPoint, vcColor, AValue);
    Data.Mesh.Write(AIndexPoint+1, vcColor, AValue);
  end else
  begin
    Data.Mesh.Write(AIndexPoint shl 1, vcColor, AValue);
    Data.Mesh.Write((AIndexPoint shl 1)+1, vcColor, AValue);
    Data.Mesh.Write((AIndexPoint + 1) shl 1, vcColor, AValue);
    Data.Mesh.Write(((AIndexPoint + 1) shl 1)+1, vcColor, AValue);
  end;
end;

function TLinesSequenceStroke.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TComplexCurveObject.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

destructor TLinesSequenceStroke.Destroy;
begin
  FColors.Free;
  FColorDistances.Free;
  inherited;
end;

function TLinesSequenceStroke.DoAddPoint(const Point: TVec2f): TCircle;
var
  l: BSFloat;
  count: int32;
  i: int32;
  step: TVec2f;
  p: TVec2f;
begin

  if (StrokeLength > 0.0) then
  begin

    if not ((FOrigins.Count = 0) or (LastOrigin = Point)) then
    begin
      step := Point - LastOrigin;
      l := VecLen(step) + SumRemainder;
      if l > StrokeLength then
      begin
        count := Trunc(l / StrokeLength);
        SumRemainder := l - count*StrokeLength;
        if SumRemainder = 0 then
          dec(count);
        if count > 1 then
        begin
          step := step / count;
          p := LastOrigin;
          for i:= 0 to count - 2 do
          begin
            p := p + step;
            FOrigins.Add(p);
            FPoints.Add(Canvas.Renderer.ScreenPositionToScene(p));
          end;
        end;
        //FCurrentLength := FCurrentLength + l - SumRemainder;
        FCurrentLength := FCurrentLength + VecLen(FOrigins.Items[FOrigins.Count - 1] - LastOrigin);
      end else
      if l = StrokeLength then
      begin
        SumRemainder := 0.0;
      end;

    end else
      StartStroke := Point;
    //LastOrigin
  end;
  LastOrigin := Point;
  Result := inherited;
end;

procedure TLinesSequenceStroke.DoBuild;
begin
  inherited DoBuild;
end;

function TLinesSequenceStroke.GetColors(Index: int32): TColor4f;
begin
  Result := FColors.Items[Index];
end;

function TLinesSequenceStroke.GetStrokeLength: BSFloat;
begin
  Result := TComplexCurveObject(Data).StrokeLength;
end;

procedure TLinesSequenceStroke.SetColor(const Value: TColor4f);
begin
  inherited;
  FColors.DefaultValue := Value;
end;

procedure TLinesSequenceStroke.SetStrokeLength(const Value: BSFloat);
begin
  TComplexCurveObject(Data).StrokeLength := Value;
end;

function TLinesSequenceStroke.GetColorsCount: int32;
begin
  Result := FColors.Count;
end;

{ TPath }

procedure TPath.AddArc(ARadius, AAngle: BSFloat);
var
  p0, p1: TVec2f;
  v: TVec2f;
  startAngle: BSFloat;
  center: TVec2f;
  s, c: BSFloat;
  i: int32;
begin
  if FOrigins.Count > 1 then
  begin
    i := FOrigins.Count-1;
    repeat
      p0 := FOrigins.Items[i-1];
      p1 := FOrigins.Items[i];
      dec(i);
    until (i = 0) or not(p0 = p1);
  end else
  if FOrigins.Count > 0 then
  begin
    p1 := FOrigins.Items[0];
    p0 := vec2(p1.x - ARadius, p1.y);
  end else
  begin
    p1 := vec2(Canvas.Renderer.WindowWidth * 0.5, Canvas.Renderer.WindowHeight * 0.5);
    p0 := vec2(p1.x - ARadius, p1.y);
  end;

  if AAngle < 0 then
  begin
    v := vec2(P1.x - p0.x, P1.y - p0.y);
    startAngle := AngleEulerClamp(BS_RAD2DEG*ArcTan2(v.x, v.y));
    BS_SinCos(startAngle, s, c);
    center := P1 + vec2(-ARadius*c, ARadius*s);
  end else
  begin
    v := vec2(P0.x - p1.x, P0.y - p1.y);
    startAngle := AngleEulerClamp(BS_RAD2DEG*ArcTan2(v.x, v.y) + 360);
    BS_SinCos(startAngle, s, c);
    center := P1 + vec2(-ARadius*c, ARadius*s);
  end;

  DoAddArc(center, ARadius, AAngle, startAngle);
end;

function TPath.AddPoint(const Point: TVec2f): TCircle;
begin
  Result := DoAddPoint(Point);
end;

procedure TPath.DoAddArc(const APositionCenter: TVec2f; ARadius, AAngle, AStartAngle: BSFloat);
var
  ns: int32;
  angleStep: BSFloat;
  s, c: BSFloat;
  i, start_i: int32;
  l: BSFloat;
begin

  // take into account interpolate factor
  l := abs(PI_DIVIDED_180*ARadius*AAngle*0.5);
  ns := round(l - l*InterpolateFactor);
  if ns < 1 then
    ns := 1;

  angleStep := AAngle / ns;

  if FPoints.Count > 0 then
    start_i := 1
  else
    start_i := 0;

  for i := start_i to ns do
  begin
    BS_SinCos(AStartAngle + angleStep * i, s, c);
    DoAddPoint(vec2(APositionCenter.x + ARadius * c, APositionCenter.y - ARadius * s));
  end;
end;

procedure TPath.DoBuild;
begin
  inherited DoBuild;
  if (FInterpolateSpline <> isNone) and Assigned(FPointsInterpolated) and (FPointsInterpolated.Count > 0) then
    GeneratePath2d(Data.Mesh, PArrayVec3f(FPointsInterpolated.ShiftData[0]), FPointsInterpolated.Count, FWidthLine, FClosed, true, FWidthLine = 1.0)
  else
    GeneratePath2d(Data.Mesh, PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, FWidthLine, FClosed, true, FWidthLine = 1.0);
end;

procedure TPath.AddFirstArc(const APositionCenter: TVec2f; ARadius, AAngle, AStartAngle: BSFloat);
begin
  if FPoints.Count > 0 then
    raise EBlackShark.Create('The path already contains points!');
  DoAddArc(APositionCenter, ARadius, AAngle, AStartAngle)
end;

function TPath.AddPoint(X, Y: BSFloat): TCircle;
begin
  Result := DoAddPoint(vec2(X, Y));
end;

procedure TPath.Build;
begin
  // if necessary, prepares interpolated path
  if (FInterpolateSpline <> isNone) and (FPoints.Count > 1) then
    FuncIntrp[FInterpolateSpline]();
  inherited;
end;

constructor TPath.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FInterpolateSpline := isCubicHermite;
  FInterpolateFactor := 0.02;
  FuncIntrp[isBezier      ] := SplineInterpolateBezier;
  FuncIntrp[isCubic       ] := SplineInterpolateCubic;
  FuncIntrp[isCubicHermite] := SplineInterpolateCubicHermite;
end;

procedure TPath.SetInterpolateFactor(const Value: BSFloat);
begin
  FInterpolateFactor := clamp(1.0, 0.01, Value);
end;

procedure TPath.SplineInterpolateBezier;
begin
  FreeAndNil(FPointsInterpolated);
  GenerateBezierSpline(PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, FPointsInterpolated, FInterpolateFactor);
end;

procedure TPath.SplineInterpolateCubic;
begin
  FreeAndNil(FPointsInterpolated);
  GenerateCubicSpline(PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, FPointsInterpolated, FInterpolateFactor);
end;

procedure TPath.SplineInterpolateCubicHermite;
begin
  FreeAndNil(FPointsInterpolated);
  GenerateCubicHermiteSpline(PArrayVec3f(FPoints.ShiftData[0]), FPoints.Count, FPointsInterpolated, FInterpolateFactor, FClosed);
end;

procedure TPath.AddArc(ARadius, AAngle: BSFloat; const AColor: TColor4f);
begin
  AddColor(AColor);
  AddArc(ARadius, AAngle);
  AddColor(AColor);
end;

procedure TPath.AddArc(ARadius, AAngle: BSFloat; const AColor: TGuiColor);
begin
  AddArc(ARadius, AAngle, TColor4f(AColor));
end;

procedure TPath.AddColor(const AColor: TColor4f);
begin
  FColorDistances.Add(FCurrentLength);
  if FOrigins.Count > 0 then
    AddPoint(FOrigins.Items[FOrigins.Count - 1]);
  if not TComplexCurveObject(Data).MultiColor then
    TComplexCurveObject(Data).MultiColor := true;
  FColors.Add(AColor);
end;

procedure TPath.AddFirstArc(const APositionCenter: TVec2f; ARadius, AAngle, AStartAngle: BSFloat; const AColor: TGuiColor);
begin
  AddFirstArc(APositionCenter, ARadius, AAngle, AStartAngle, TColor4f(AColor));
end;

procedure TPath.AddFirstArc(const APositionCenter: TVec2f; ARadius, AAngle, AStartAngle: BSFloat; const AColor: TColor4f);
begin
  AddColor(AColor);
  AddFirstArc(APositionCenter, ARadius, AAngle, AStartAngle);
  AddColor(AColor);
end;

function TPath.AddPoint(const APoint: TVec2f; const AColor: TColor4f): TCircle;
begin
  Result := AddPoint(APoint);
  AddColor(AColor);
end;

function TPath.AddPoint(X, Y: BSFloat; const AColor: TColor4f): TCircle;
begin
  Result := AddPoint(vec2(X, Y), AColor);
end;

function TPath.AddPoint(const APoint: TVec2f; const AColor: TGuiColor): TCircle;
begin
  Result := AddPoint(APoint, TColor4f(AColor));
end;

function TPath.AddPoint(X, Y: BSFloat; const AColor: TGuiColor): TCircle;
begin
  Result := AddPoint(vec2(X, Y), TColor4f(AColor));
end;

{ TPathMultiColored }

constructor TPathMultiColored.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
end;

{ TTriangle }

procedure TTriangle.SetWidthLine(AValue: BSFloat);
begin
  if FWidthLine = AValue then Exit;
  FWidthLine := round(AValue);
  if FWidthLine < 1.0 then
    FWidthLine := 1.0;
end;

procedure TTriangle.DoBuild;
var
  vert: array [0 .. 2] of TVec3f;
begin
  inherited;
  if FFill then
  begin
    { for correct ray test BB MUST aligned to center Scene, therefor subtract middle current shape }
    Data.Mesh.AddVertex(vec3(round(FA.x), round(FCanvas.Renderer.WindowHeight-FA.y), 0.0));
    Data.Mesh.AddVertex(vec3(round(FB.x), round(FCanvas.Renderer.WindowHeight-FB.y), 0.0));
    Data.Mesh.AddVertex(vec3(round(FC.x), round(FCanvas.Renderer.WindowHeight-FC.y), 0.0));
    Data.Mesh.Indexes.Add(0);
    Data.Mesh.Indexes.Add(1);
    Data.Mesh.Indexes.Add(2);
    Data.Mesh.CalcBoundingBox(true);
  end else
  begin
    vert[0] := vec3(round(FA.x), round(FCanvas.Renderer.WindowHeight-FA.y), 0.0);
    vert[1] := vec3(round(FB.x), round(FCanvas.Renderer.WindowHeight-FB.y), 0.0);
    vert[2] := vec3(round(FC.x), round(FCanvas.Renderer.WindowHeight-FC.y), 0.0);
    GeneratePath2d(Data.Mesh, @vert[0], 3, FWidthLine, true, true);
  end;
end;

procedure TTriangle.Build;
begin
  FPosition2d := vec2(bs.math.Min(FA.x, bs.math.Min(FB.x, FC.x)), bs.math.Min(FA.y, bs.math.Min(FB.y, FC.y)));
  inherited;
end;

constructor TTriangle.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  Data.Mesh.TypePrimitive := tpTriangles;
  FWidthLine := 1.0;
end;

{ TTriangleTextured }

procedure TTriangleTextured.DoBuild;
begin
  inherited;
  Data.Mesh.Write(0, vcTexture1, vec2(0.0, 1.0));
  Data.Mesh.Write(1, vcTexture1, vec2(0.5, 0.0));
  Data.Mesh.Write(2, vcTexture1, vec2(1.0, 1.0));
end;

function TTriangleTextured.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TArrow }

procedure TArrow.SetLineWidth(AValue: BSFloat);
begin
  if FLineWidth = AValue then Exit;
  FLineWidth := round(AValue);
  if FLineWidth < 1.0 then
    FLineWidth := 1.0;
end;

procedure TArrow.DoBuild;
var
  v: TVec2f;
  l: BSFloat;
begin
  inherited;
  FPosition2d := vec2(bs.math.min(B.x, A.x), bs.math.min(B.y, A.y));
  v := B - A;
  l := VecLen(v);
  if l < EPSILON then
    exit;
  TBlackSharkFactoryShapesP.GenerateArrow2d(Data.Mesh, l, FLineWidth, SizeTip.Y, SizeTip.X);
  // so axis z direct from screen to us, there for change sign
  Data.Mesh.Transform(0.0, 0.0, (VecDecisionX(vec3(v.x, v.y, 0.0)) + 90));
end;

constructor TArrow.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FLineWidth := 4;
  FSizeTip := vec2(5.0, 10.0);
end;

{ TCircle }

procedure TCircle.DoBuild;
var
  ns: int32;
begin
  inherited;
  ns := round(BS_PI * FRadius);
  if ns < 3 then
    ns := 3;
  if Fill then
    TBlackSharkFactoryShapesP.GenerateCircle(Data.Mesh, ns, Radius)
  else
    TBlackSharkFactoryShapesP.GenerateCircle(Data.Mesh, FWidthLine, ns, Radius);
end;

{ TCircleTxtrued }

procedure TCircleTextured.DoBuild;
var
  ns: int32;
begin
  ns := round(BS_PI * FRadius);
  if ns < 3 then
    ns := 3;

  if FFill then
    TBlackSharkFactoryShapesPT.GenerateCircle(Data.Mesh, ns, FRadius)
  else
    TBlackSharkFactoryShapesPT.GenerateCircle(Data.Mesh, FWidthLine, ns, FRadius);
end;

constructor TCircle.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FWidthLine := 1.0;
end;

function TCircle.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TColoredVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TCircleTextured }

function TCircleTextured.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

destructor TCircleTextured.Destroy;
begin
  inherited;
end;

function TCircleTextured.GetTexture: PTextureArea;
begin
  Result := TTexturedVertexes(FData).Texture;
end;

procedure TCircleTextured.SetTexture(const Value: PTextureArea);
begin
  TTexturedVertexes(FData).Texture := Value;
end;

{ TArc }

procedure TArc.DoBuild;
var
  ns: int32;
  l: BSFloat;
begin
  inherited;

  // take into account interpolate factor
  l := abs(PI_DIVIDED_180*Radius*Angle*0.5);
  ns := round(l*(1.0 - InterpolateFactor));
  if ns < 1 then
    ns := 1;

  if FFill then
    LocalPosition2dCenter := TVec2f(TBlackSharkFactoryShapesP.GenerateAngleArc(Data.Mesh, ns, FRadius, StartAngle, Angle))
  else
    LocalPosition2dCenter := TVec2f(TBlackSharkFactoryShapesP.GenerateAngleArc(Data.Mesh, ns, FRadius, StartAngle, Angle, FLineWidth));

end;

procedure TArc.SetInterpolateFactor(const Value: BSFloat);
begin
  FInterpolateFactor := clamp(1.0, 0.02, Value);
end;

procedure TArc.SetPosition2d(const AValue: TVec2f);
begin
  inherited;
  FPosition2dCenter := Position2d + vec2(Data.Mesh.FBoundingBox.x_max + LocalPosition2dCenter.x, Data.Mesh.FBoundingBox.y_max - LocalPosition2dCenter.y);
end;

procedure TArc.SetPosition2dCenter(const Value: TVec2f);
begin
  FPosition2dCenter := Value;
  ConnectChild(FPosition2dCenter, vec2(Data.Mesh.FBoundingBox.x_max + LocalPosition2dCenter.x, Data.Mesh.FBoundingBox.y_max - LocalPosition2dCenter.y), Self);
end;

procedure TArc.SetLineWidth(AValue: BSFloat);
begin
  if FLineWidth = AValue then
    exit;

  FLineWidth := round(AValue);
  if FLineWidth < 1.0 then
    FLineWidth := 1.0;
end;

constructor TArc.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FLineWidth := 1.0;
  FAngle := 90;
  // good quality
  FInterpolateFactor := 0.9;
end;

function TArc.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TColoredVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TArcTextured }

procedure TArcTextured.DoBuild;
var
  ns: int32;
  l: BSFloat;
begin
  inherited;
  // take into account interpolate factor
  l := abs(PI_DIVIDED_180*Radius*Angle*0.5);
  ns := round(l*(1.0 - InterpolateFactor));
  if ns < 1 then
    ns := 1;

  if FFill then
    LocalPosition2dCenter := TVec2f(TBlackSharkFactoryShapesPT.GenerateAngleArc(Data.Mesh, ns, Radius, StartAngle, Angle))
  else
    LocalPosition2dCenter := TVec2f(TBlackSharkFactoryShapesPT.GenerateAngleArc(Data.Mesh, ns, Radius, StartAngle, Angle, LineWidth));

end;

function TArcTextured.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

{ TRectangle }

constructor TRectangle.Create;
begin
  inherited;
  FWidthLine := 1.0;
  Data.Color := BS_CL_ORANGE_2;
end;

procedure TRectangle.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
begin
  if (Canvas.Scalable and not BanScalableMode) then
  begin
    Data.Mesh.Clear;
    DoBuild;
  end;
  inherited;
end;

procedure TRectangle.DoBuild;
begin
  if FFill then
    TBlackSharkFactoryShapesP.GeneratePlane(Data.Mesh, vec2(RoundWidth(FSize.Width), RoundWidth(FSize.Height)))
  else
    TBlackSharkFactoryShapesP.GenerateRectangle(Data.Mesh, RoundWidth(WidthLine), RoundWidth(FSize.Width), RoundWidth(FSize.Height));
end;

procedure TRectangle.DoResize(AWidth, AHeight: BSFloat);
begin
  Size := vec2(AWidth, AHeight);
  Data.Mesh.Clear;
  DoBuild;
end;

procedure TRectangle.SetHeight(const Value: BSFloat);
begin
  inherited;
  FSize.Height := Value;
end;

procedure TRectangle.SetSize(const Value: TVec2f);
begin
  FSize := Value;
  FWidth := Value.x;
  FHeight := Value.y;
end;

procedure TRectangle.SetWidth(const Value: BSFloat);
begin
  inherited;
  FSize.Width := Value;
end;

{ TRectangleTextured }

procedure TRectangleTextured.DoBuild;
begin
  if FFill then
    TBlackSharkFactoryShapesPT.GeneratePlane(Data.Mesh, vec2(FSize.Width, FSize.Height))
  else
    TBlackSharkFactoryShapesPT.GenerateRectangle(Data.Mesh, RoundWidth(WidthLine), RoundWidth(FSize.Width), RoundWidth(FSize.Height));
end;

constructor TRectangleTextured.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FFill := true;
end;

function TRectangleTextured.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

function TRectangleTextured.GetReplaceColor: boolean;
begin
  Result := TTexturedVertexes(Data).ReplaceColor;
end;

function TRectangleTextured.GetTexture: PTextureArea;
begin
  Result := TTexturedVertexes(Data).Texture;
end;

procedure TRectangleTextured.SetReplaceColor(const Value: boolean);
begin
  TTexturedVertexes(Data).ReplaceColor := Value;
end;

procedure TRectangleTextured.SetTexture(const Value: PTextureArea);
begin
  TTexturedVertexes(Data).Texture := Value;
end;

{ TPicture }

procedure TPicture.DoBuild;
var
  pos, s_pix: TVec2f;
begin
  inherited;
  if not Assigned(TTexturedVertexes(Data).Texture) then
    exit;

  if FAutoFit or (Size.X = 0) or (Size.Y = 0) then
  begin
    s_pix := TTexturedVertexes(Data).Texture.Rect.Size;
  end else
  begin
    s_pix := Size;
  end;

  TBlackSharkFactoryShapesPT.GeneratePlane(Data.Mesh, s_pix);

  if FWrap then
  begin
    Data.Mesh.Read(0, TVertexComponent.vcTexture1, pos);
    pos.Y := s_pix.Y / TTexturedVertexes(Data).Texture.Rect.Height;
    Data.Mesh.Write(0, TVertexComponent.vcTexture1, pos);

    // Data.Mesh.Read(2, TVertexComponent.vcTexture1, pos);
    pos.X := s_pix.X / TTexturedVertexes(Data).Texture.Rect.Width;
    pos.Y := s_pix.Y / TTexturedVertexes(Data).Texture.Rect.Height;
    Data.Mesh.Write(2, TVertexComponent.vcTexture1, pos);

    Data.Mesh.Read(3, TVertexComponent.vcTexture1, pos);
    pos.X := s_pix.X / TTexturedVertexes(Data).Texture.Rect.Width;
    // pos.y := s_pix.y / FTexture.Rect.Height;
    Data.Mesh.Write(3, TVertexComponent.vcTexture1, pos);
  end;

end;

constructor TPicture.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FAutoFit := true;
end;

function TPicture.GetImage: TBlackSharkPicture;
begin
  if TTexturedVertexes(Data).Texture <> nil then
    Result := TTexturedVertexes(Data).Texture.Texture.Picture
  else
    Result := nil;
end;

procedure TPicture.LoadFromFile(const FileName: string; AInsertToMap: boolean = false; TrilinearFilter: boolean = false);
begin
  TTexturedVertexes(Data).Texture := BSTextureManager.LoadTexture(FileName, FAsPartMap, TrilinearFilter);
  FAsPartMap := AInsertToMap;
  Build;
end;

procedure TPicture.LoadFromStream(Stream: TStream; const Name: string; AInsertToMap: boolean = false; TrilinearFilter: boolean = false);
begin
  TTexturedVertexes(Data).Texture := BSTextureManager.LoadTexture(Stream, Name, FAsPartMap, TrilinearFilter);
  FAsPartMap := AInsertToMap;
  Build;
end;

procedure TPicture.SetImage(const Value: TBlackSharkPicture);
begin
  TTexturedVertexes(Data).Texture := BSTextureManager.LoadTexture(Value, Value.Caption, FAsPartMap, FTrilinearFilter);
  SetWrapOtions;
  Build;
end;

procedure TPicture.SetTexture(const Value: PTextureArea);
begin
  inherited;
  SetWrapOtions;
  Build;
end;

procedure TPicture.SetWrap(const Value: boolean);
begin
  FWrap := Value;
  SetWrapOtions;
  Build;
end;

procedure TPicture.SetWrapOtions;
begin
  if TTexturedVertexes(Data).Texture = nil then
    exit;
  if FWrap then
  begin
    if FWrapReapeated then
      TTexturedVertexes(Data).Texture.Texture.WrapOptions := GL_REPEAT
    else
      TTexturedVertexes(Data).Texture.Texture.WrapOptions := GL_MIRRORED_REPEAT;
  end
  else
    TTexturedVertexes(Data).Texture.Texture.WrapOptions := GL_CLAMP_TO_EDGE;
end;

procedure TPicture.SetWrapReapeated(const Value: boolean);
begin
  FWrapReapeated := Value;
  SetWrapOtions;
  // Build;
end;

{ TGrid }

procedure TGrid.DoBuild;
var
  by_triang: boolean;
begin
  inherited;

  by_triang := abs(FWidthLines - 1.0) > EPSILON;

  if Data.ServiceScale*FWidthLines < BSConfig.VoxelSize then
    TBlackSharkFactoryShapesP.GenerateGrid(Data.Mesh, FSize, FStepX, FStepY, FHorLines, FVertLines, FClosed, by_triang, Data.ServiceScaleInv*BSConfig.VoxelSize)
  else
    TBlackSharkFactoryShapesP.GenerateGrid(Data.Mesh, FSize, FStepX, FStepY, FHorLines, FVertLines, FClosed, by_triang, FWidthLines);

end;

constructor TGrid.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FWidthLines := 1.0;
  FHorLines := true;
  FVertLines := true;
end;

{ TRoundRect }

constructor TRoundRect.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FRadiusRound := 10.0;
  FWidthLine := 1.0;
end;

procedure TRoundRect.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
begin
  if Canvas.Scalable and not BanScalableMode then  //not Fill and
  begin
    Data.Mesh.Clear;
    DoBuild;
  end;
  inherited;
end;

procedure TRoundRect.DoBuild;
var
  ns: int32;
begin

  ns := round(BS_PI * FRadiusRound) div 4;
  if ns = 0 then
    ns := 1;

  if FFill then
    TBlackSharkFactoryShapesP.GenerateRoundRect(Data.Mesh, ns, FRadiusRound, RoundWidth(FSize.X), RoundWidth(FSize.Y))
  else
    TBlackSharkFactoryShapesP.GenerateRoundRect(Data.Mesh, RoundWidth(WidthLine), ns, FRadiusRound, RoundWidth(FSize.X), RoundWidth(FSize.Y));

end;

procedure TRoundRect.SetRadiusRound(const Value: BSFloat);
begin
  FRadiusRound := Value;
end;

procedure TRoundRect.SetSize(const Value: TVec2f);
begin
  FSize := Value;
  FWidth := Value.x;
  FHeight := Value.y;
end;

{ TRoundRectTextured }

procedure TRoundRectTextured.DoBuild;
var
  ns: int32;
begin
  ns := round(BS_PI * FRadiusRound) div 4;
  if ns < 3 then
    ns := 3;

  if FFill then
    TBlackSharkFactoryShapesPT.GenerateRoundRect(Data.Mesh, ns, FRadiusRound, FSize.X, FSize.Y)
  else
    TBlackSharkFactoryShapesPT.GenerateRoundRect(Data.Mesh, RoundWidth(WidthLine), ns, FRadiusRound, FSize.X, FSize.Y);
end;

constructor TRoundRectTextured.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FFill := true;
end;

function TRoundRectTextured.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TTexturedVertexes.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

function TRoundRectTextured.GetTexture: PTextureArea;
begin
  Result := TTexturedVertexes(Data).Texture;
end;

procedure TRoundRectTextured.SetTexture(const Value: PTextureArea);
begin
  TTexturedVertexes(Data).Texture := Value;
end;

{ TLines }

procedure TLines.AddLine(X1, Y1, X2, Y2: BSFloat);
begin
  AddLine(vec2(X1, Y1), vec2(X2, Y2));
end;

procedure TLines.AddLine(const Point1, Point2: TVec2f);
begin

  if Offset.X > Point1.X then
    Offset.X := Point1.X;

  if Offset.X > Point2.X then
    Offset.X := Point2.X;

  if Offset.Y > Point1.Y then
    Offset.Y := Point1.Y;

  if Offset.Y > Point2.Y then
    Offset.Y := Point2.Y;

  Points.Add(vec4(Point1, Point2));

end;

procedure TLines.BeginUpdate;
begin
  TGraphicObjectLines(FData).BeginUpdate;
end;

destructor TLines.Destroy;
begin
  Points.Free;
  inherited;
end;

procedure TLines.DoBuild;
begin
  EndUpdate;
end;

procedure TLines.Clear;
begin
  Points.Clear;
  RealPos := FPosition2d;
  Offset.X := 65535;
  Offset.Y := 65535;
  TGraphicObjectLines(FData).Clear;
end;

constructor TLines.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  Offset.X := 65535;
  Offset.Y := 65535;
  Points := TListVec4f.Create;
end;

function TLines.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TGraphicObjectLines.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

procedure TLines.EndUpdate;
var
  i: int32;
  line: TVec4f;
begin
  for i := 0 to Points.Count - 1 do
  begin
    line := Points.Items[i];
    TGraphicObjectLines(FData).Line(vec3(line.v2f1.x, FCanvas.Renderer.WindowHeight-line.v2f1.y, 0.0),
      vec3(line.v2f2.x, FCanvas.Renderer.WindowHeight-line.v2f2.y, 0.0));
  end;

  TGraphicObjectLines(FData).EndUpdate(true);
  Data.Mesh.FBoundingBox.z_min := 0;
  Data.Mesh.FBoundingBox.z_max := 0;
  CalcBB;
  if Data.Mesh.CountVertex = 0 then
    Position2d := RealPos
  else
    Position2d := Offset;
end;

function TLines.GetCountLines: int32;
begin
  Result := TGraphicObjectLines(FData).CountLines;
end;

function TLines.GetDrawByTriangleOnly: boolean;
begin
  Result := TGraphicObjectLines(Data).DrawByTriangleOnly;
end;

function TLines.GetLinesWidth: BSFloat;
begin
  Result := TGraphicObjectLines(FData).LineWidth;
end;

procedure TLines.SetDrawByTriangleOnly(const Value: boolean);
begin
  TGraphicObjectLines(Data).DrawByTriangleOnly := Value;
end;

procedure TLines.SetLinesWidth(const Value: BSFloat);
begin
  TGraphicObjectLines(FData).LineWidth := Value;
end;

procedure TLines.SetPosition2d(const AValue: TVec2f);
begin
  RealPos := AValue;
  inherited;
end;

{ TCanvasRect }

procedure TCanvasRect.AfterConstruction;
begin
  inherited;
  FBorder := TCanvasObjectP.Create(Self.Canvas, Self);
  FBorder.Data.DrawAsTransparent := true;
  FBorder.Data.DragResolve := false;
  FBorder.Data.Opacity := 0.3;
  FBorder.Data.Hidden := true;
  FBorder.Data.Color := BS_CL_AQUA;
  FBorder.MinWidth := 5.0;
  FBorder.MinHeight := 5.0;
  FBorder.Data.StaticObject := false;
  FBorder.Data.Interactive := false;
end;

procedure TCanvasRect.DoBuild;
var
  wb, hb: BSFloat;
begin
  inherited;
  wb := FSize.x + 2;
  hb := FSize.y + 2;
  FBorder.Data.Mesh.Clear;
  TBlackSharkFactoryShapesP.GeneratePlane(Data.Mesh, FSize);
  TBlackSharkFactoryShapesP.GenerateRectangle(FBorder.Data.Mesh, 1.0, wb, hb);
end;

procedure TCanvasRect.Build;
begin
  inherited;
  FBorder.Position2d := vec2(-1.0, -1.0);
end;

constructor TCanvasRect.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  Data.Opacity := 0.3;
  Data.Hidden := true;
  Data.Color := BS_CL_BLUE;
  Data.DragResolve := false;
  Data.Interactive := false;
  Data.DrawAsTransparent := true;
  Data.StaticObject := false;
  FPatternAlignHor.MinSize := 3.0;
  FPatternAlignVert.MinSize := 3.0;
end;

destructor TCanvasRect.Destroy;
begin
  { TODO: if clean canvas, then Border can be already removed; what to do??? }
  // Border.Free;
  inherited;
end;

procedure TCanvasRect.Hide;
begin
  Data.Hidden := true;
  FBorder.Data.Hidden := true;
end;

procedure TCanvasRect.Show;
begin
  Build;
  if Data.Hidden then
    Data.Hidden := false;
  if FBorder.Data.Hidden then
    FBorder.Data.Hidden := false;
end;

{ TTrapezeTemplate }

constructor TTrapezeTemplate.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FUpperBase := 100;
  FLowerBase := 350;
  FHeightBwBases := 100;
  FWidthLine := 1.0;
end;

{ TTrapeze }

procedure TTrapeze.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
begin
  if not Fill and Canvas.Scalable and not BanScalableMode then
  begin
    Data.Mesh.Clear;
    DoBuild;
  end;
  inherited;
end;

procedure TTrapeze.DoBuild;
var
  c: int32;
begin
  c := round(Data.ServiceScale*WidthLine*BSConfig.VoxelSizeInv);
  if c = 0 then
    c := 1;
  TBlackSharkFactoryShapesP.GenerateTrapeze(Data.Mesh, FUpperBase, FLowerBase, FHeightBwBases, Data.ServiceScaleInv*BSConfig.VoxelSize*c, FFill);
end;

{ TRoundTrapeze }

constructor TRoundTrapeze.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FRadiusRound := 10;
end;

procedure TRoundTrapeze.DoAlign(var ParentClientAreaSize, ParentPaddingHor, ParentPaddingVert: TVec2f);
begin
  if not Fill and Canvas.Scalable and not BanScalableMode then
  begin
    Data.Mesh.Clear;
    DoBuild;
  end;
  inherited;
end;

procedure TRoundTrapeze.DoBuild;
var
  ns: int32;
  c: int32;
begin

  ns := round(BS_PI * FRadiusRound) div 4;

  if ns < 3 then
    ns := 3;

  c := round(Data.ServiceScale*WidthLine*BSConfig.VoxelSizeInv);
  if c = 0 then
    c := 1;

  TBlackSharkFactoryShapesP.GenerateTrapezeRound(Data.Mesh, FUpperBase, FLowerBase,
    FHeightBwBases, Data.ServiceScaleInv*BSConfig.VoxelSize*c, FRadiusRound, ns, FFill);

end;

procedure TRoundTrapeze.SetRadiusRound(const Value: BSFloat);
begin
  FRadiusRound := Value;
end;

{ TFog }

function TFog.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TGraphicObjectFog.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

procedure TFog.DoBuild;
begin
  inherited;
  TGraphicObjectFog(Data).Size := FSize;
end;

{ TColorSelector }

procedure TColorSelector.ColorToHls;
var
  pos: TVec2f;
  hls: TVec3f;
begin
  hls := RGBtoHLS(TVec3f(ColorSelected));
  FHue := hls.h;
  FSaturation := hls.s;
  //FLightness := hls.l;

  pos.x := hls.h*Rect.Size.Width;
  pos.y := hls.s*Rect.Size.Height;

  Cross.Position2d := vec2(pos.x - round(Cross.Width*0.5), pos.y - round(Cross.Height*0.5));
end;

constructor TColorSelector.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FLightness := 0.5;
  Data.Interactive := false;
  Rect := TRectangle.Create(ACanvas, Self);
  Rect.Data.Opacity := 0.0;
  Rect.Data.DragResolve := false;
  Rect.Fill := true;
  Cross := TLines.Create(ACanvas, Rect);
  Cross.Data.Interactive := false;
  Cross.BeginUpdate;
  Cross.LinesWidth := round(2.0*ToHiDpiScale);
  Cross.AddLine(round(5.0*ToHiDpiScale), 0.0, round(5.0*ToHiDpiScale), round(4.0*ToHiDpiScale));
  Cross.AddLine(0.0, round(5.0*ToHiDpiScale), round(4.0*ToHiDpiScale), 5.0*ToHiDpiScale);
  Cross.AddLine(round(6.0*ToHiDpiScale), round(5.0*ToHiDpiScale), round(10.0*ToHiDpiScale), round(5.0*ToHiDpiScale));
  Cross.AddLine(round(5.0*ToHiDpiScale), round(6.0*ToHiDpiScale), round(5.0*ToHiDpiScale), round(10.0*ToHiDpiScale));
  Cross.EndUpdate;
  Cross.Color := BS_CL_BLACK;
  ObsrvMouseDown := CreateMouseObserver(Rect.Data.EventMouseDown, OnMouseDown);
  ObsrvMouseMove := CreateMouseObserver(Rect.Data.EventMouseMove, OnMouseMove);
  ObsrvMouseUp := CreateMouseObserver(Rect.Data.EventMouseUp, OnMouseUp);
  Cross.Data.StencilTest := true;
end;

function TColorSelector.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TColorPatettePlane.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

destructor TColorSelector.Destroy;
begin
  ObsrvMouseDown := nil;
  ObsrvMouseMove := nil;
  ObsrvMouseUp := nil;
  inherited;
end;

procedure TColorSelector.DoBuild;
begin
  inherited;
  TColorPatettePlane(Data).Size := Rect.Size;
  Rect.Build;
  Rect.Position2d := vec2(0.0, 0.0);
end;

function TColorSelector.GetColorSelected: TColor4f;
begin
  Result := vec4(FRed, FGreen, FBlue, 1.0);
end;

function TColorSelector.GetColorWithMiddleLightness: TColor4f;
begin
  Result := TVec4f(HlsToRgb(vec3(FHue, 0.5, FSaturation)));
end;

function TColorSelector.GetSize: TVec2f;
begin
  Result := Rect.Size;
end;

procedure TColorSelector.HlsToColor;
var
  pos: TVec2f;
  clr: TVec3f;
begin
  clr := HLStoRGB(vec3(FHue, FLightness, FSaturation));
  FRed := clr.r;
  FGreen := clr.g;
  FBlue := clr.b;

  pos.x := FHue*Rect.Size.Width;
  pos.y := FSaturation*Rect.Size.Height;

  Cross.Position2d := vec2(pos.x - round(Cross.Width*0.5), pos.y - round(Cross.Height*0.5));
end;

procedure TColorSelector.OnMouseDown(const AData: BMouseData);
begin
  IsMouseDown := true;
  UpdateColorAndCross(AData);
end;

procedure TColorSelector.OnMouseMove(const AData: BMouseData);
begin
  if IsMouseDown then
    UpdateColorAndCross(AData);
end;

procedure TColorSelector.OnMouseUp(const AData: BMouseData);
begin
  IsMouseDown := false;
end;

procedure TColorSelector.SetBlue(const Value: BSFloat);
begin
  FBlue := Value;
  ColorToHls;
end;

procedure TColorSelector.SetColorSelected(const Value: TColor4f);
begin

  FRed := Value.r;
  FGreen := Value.g;
  FBlue := Value.b;

  ColorToHls;

  if Assigned(FOnColorChange) then
    FOnColorChange(Self);
end;

procedure TColorSelector.SetGreen(const Value: BSFloat);
begin
  FGreen := Value;
  ColorToHls;
end;

procedure TColorSelector.SetHue(const Value: BSFloat);
begin
  FHue := Value;
  HlsToColor;
end;

procedure TColorSelector.SetLightness(const Value: BSFloat);
begin
  FLightness := Value;
  HlsToColor;
end;

procedure TColorSelector.SetRed(const Value: BSFloat);
begin
  FRed := Value;
  ColorToHls;
end;

procedure TColorSelector.SetSaturation(const Value: BSFloat);
begin
  FSaturation := Value;
  HlsToColor;
end;

procedure TColorSelector.SetSize(const Value: TVec2f);
begin
  Rect.Size := Value;
end;

procedure TColorSelector.UpdateColorAndCross(const AData: BMouseData);
var
  pos: TVec2f;
begin
  pos := AbsolutePosition2d;

  pos.x := AData.X - pos.x;
  pos.y := AData.Y - pos.y;

  Cross.Position2d := vec2(pos.x - round(Cross.Width*0.5), pos.y - round(Cross.Height*0.5));

  FHue := pos.x / Rect.Size.Width;
  FSaturation := pos.y / Rect.Size.Height;

  with HlsToRgb(vec3(FHue, FLightness, FSaturation)) do
  begin
    FRed := r;
    FGreen := g;
    FBlue := b;
  end;

  if Assigned(FOnColorChange) then
    FOnColorChange(Self);
end;

{ TBiColoredSolidLines }

function TBiColoredSolidLines.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TGraphicObjectBiColoredSolidLines.Create(Self, AParent, Canvas.Renderer.Scene);
end;

procedure TBiColoredSolidLines.DoBuild;
begin
  inherited;
  TGraphicObjectBiColoredSolidLines(FData).Draw(FWidth, FHorizontal, TGraphicObjectBiColoredSolidLines(FData).CountLines);
end;

procedure TBiColoredSolidLines.Draw(AWidth: BSFloat; AHorizontal: boolean; ACount: int32);
begin
  TGraphicObjectBiColoredSolidLines(FData).CountLines := ACount;
  FWidth := AWidth;
  FHorizontal := AHorizontal;
  Build;
end;

function TBiColoredSolidLines.GetCountLines: int32;
begin
  Result := TGraphicObjectBiColoredSolidLines(FData).CountLines;
end;

function TBiColoredSolidLines.GetLineColor2: TColor4f;
begin
  Result := TGraphicObjectBiColoredSolidLines(FData).LineColor2;
end;

function TBiColoredSolidLines.GetLineWidth: BSFloat;
begin
  Result := TGraphicObjectLines(FData).LineWidth;
end;

procedure TBiColoredSolidLines.SetLineColor2(const Value: TColor4f);
begin
  TGraphicObjectBiColoredSolidLines(FData).LineColor2 := Value;
end;

procedure TBiColoredSolidLines.SetLineWidth(const Value: BSFloat);
begin
  TGraphicObjectBiColoredSolidLines(FData).LineWidth := Value;
end;

procedure TBiColoredSolidLines.SetPosition2d(const AValue: TVec2f);
begin
  inherited;

end;

{ TMultiColoredShape }

function TMultiColoredShape.AddVertex(const APoint: TVec2f; const AColor: TVec3f): int32;
var
  v: TVertMultiColor;
begin
  Result := Vertexes.Count;
  v.Point := APoint;
  v.Color := AColor;
  Vertexes.Add(v);
end;

function TMultiColoredShape.AddVertex(const APoint: TVec2f): Int32;
begin
  Result := AddVertex(APoint, TVec3f(FColor));
end;

destructor TMultiColoredShape.Destroy;
begin
  Vertexes.Free;
  inherited;
end;

procedure TMultiColoredShape.DoBuild;
var
  i: int32;
begin
  for i := 0 to Vertexes.Count - 1 do
  begin
    TMultiColorVertexes(Data).AddVertex(Vertexes.Items[i].Point, Vertexes.Items[i].Color);
  end;
  TMultiColorVertexes(Data).Build;
end;

procedure TMultiColoredShape.Clear;
begin
  TMultiColorVertexes(Data).Clear;
  Vertexes.Clear;
end;

constructor TMultiColoredShape.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FColor := BS_CL_RED;
  Vertexes := TListVec<TVertMultiColor>.Create;
end;

function TMultiColoredShape.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TMultiColorVertexes.Create(Self, AParent, Canvas.Renderer.Scene);
end;

function TMultiColoredShape.GetColor: TColor4f;
begin
  Result := FColor;
end;

function TMultiColoredShape.GetTypePrimitive: TTypePrimitive;
begin
  Result := TMultiColorVertexes(Data).TypePrimitive;
end;

procedure TMultiColoredShape.SetColor(const Value: TColor4f);
begin
  FColor := Value;
end;

procedure TMultiColoredShape.SetTypePrimitive(const Value: TTypePrimitive);
begin
  TMultiColorVertexes(Data).TypePrimitive := Value;
end;

procedure TMultiColoredShape.WriteColor(AVertexIndex: int32; const AColor: TVec3f);
var
  v: TVertMultiColor;
begin
  v := Vertexes.Items[AVertexIndex];
  v.Color := AColor;
  Vertexes.Items[AVertexIndex] := v;
end;

{ TCanvasLayout }

function TCanvasLayout.CreateGraphicObject(AParent: TGraphicObject): TGraphicObject;
begin
  Result := TLayoutObject.Create(Self, AParent, FCanvas.Renderer.Scene);
end;

procedure TCanvasLayout.DoBuild;
begin
  TLayoutObject(Data).Build(false);
end;

procedure TCanvasLayout.DoResize(AWidth, AHeight: BSFloat);
begin
  Size := vec2(AWidth, AHeight);
  TLayoutObject(Data).Build(true);
end;

function TCanvasLayout.GetIsVisible: boolean;
begin
  Result := TLayoutObject(Data).DrawOn;
end;

function TCanvasLayout.GetSize: TVec2f;
begin
  Result := TLayoutObject(Data).Size;
end;

procedure TCanvasLayout.SetHeight(const Value: BSFloat);
begin
  inherited;
  Size := vec2(Width, Value);
end;

procedure TCanvasLayout.SetIsVisible(const Value: boolean);
begin
  TLayoutObject(Data).DrawOn := Value;
end;

procedure TCanvasLayout.SetSize(const Value: TVec2f);
begin
  TLayoutObject(Data).Size := Value;
end;

procedure TCanvasLayout.SetWidth(const Value: BSFloat);
begin
  inherited;
  TLayoutObject(Data).Size := vec2(Value, Height);
end;

{ TFreeShape }

procedure TFreeShape.AddContour(const AContour: array of TVec2f);
begin
  TBlackSharkTesselator.TListContours.CheckCapacity(FContours, Length(FContours.Items)+1);
end;

procedure TFreeShape.AddContour(const AContour: TListVec<TVec2f>);
var
  i: int32;
begin
  BeginContour;
  for i := 0 to AContour.Count - 1 do
    AddPoint(AContour.Items[i]);
  EndContour;
end;

procedure TFreeShape.AddContour(const AContour: array of TVec3f);
var
  i: int32;
begin
  BeginContour;
  for i := 0 to Length(AContour) - 1 do
    AddPoint(TVec2f(AContour[i]));
  EndContour;
end;

procedure TFreeShape.AddPoint(const APoint: TVec2f);
begin
  TBlackSharkTesselator.TListPoints.Add(FPoints, Canvas.Renderer.ScreenPositionToScene(APoint, 0));
  if APoint.x < FPosition2d.x then
    FPosition2d.x := APoint.x;
  if APoint.y < FPosition2d.y then
    FPosition2d.y := APoint.y;
end;

procedure TFreeShape.BeginContour;
var
  contour: TContour;
begin
  FillChar(contour, SizeOf(contour), 0);
  contour.PointIndexBegin := FPoints.Count;
  TBlackSharkTesselator.TListContours.Add(FContours, contour);
end;

procedure TFreeShape.Clear;
begin
  FContours.Count := 0;
  FPoints.Count := 0;
  FPosition2d := vec2(65535.0, 65535.0);
end;

constructor TFreeShape.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  FPosition2d := vec2(65535.0, 65535.0);
  FQualityInterpolate := 0.2;
  TBlackSharkTesselator.TListPoints.Create(FPoints, 32);
  TBlackSharkTesselator.TListContours.Create(FContours, 4);
  FuncIntrp[isNone        ] := SplineNoInterpolate;
  FuncIntrp[isBezier      ] := SplineInterpolateBezier;
  FuncIntrp[isCubic       ] := SplineInterpolateCubic;
  FuncIntrp[isCubicHermite] := SplineInterpolateCubicHermite;
end;

procedure TFreeShape.DoBuild;
begin
  if FPoints.Count > 1 then
    FuncIntrp[FInterpolateSpline]();
  Data.Mesh.CalcBoundingBox(true);
end;

procedure TFreeShape.EndContour;
begin
  FContours.Items[FContours.Count-1].CountPoints := FPoints.Count - FContours.Items[FContours.Count-1].PointIndexBegin;
end;

procedure TFreeShape.Save(const FileName: string);
var
  f: TFileStream;
  i: Integer;
  v: Ansistring;
  p: TVec3f;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    for i := 0 to FPoints.Count - 1 do
    begin
      p := FPoints.Items[i];
      v := StringToAnsi(VecToStr(vec3(Canvas.Renderer.WindowWidth*0.5+p.x, Canvas.Renderer.WindowHeight*0.5-p.y, p.z)) + sLineBreak);
      f.Write(v[1], length(v));
    end;
  finally
    f.Free;
  end;
end;

procedure TFreeShape.SplineInterpolateBezier;
var
  out_values: TListVec<TVec3f>;
  i, j: int32;
  out_points: TPoints;
  out_contours: TContours;
  indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
  contour: TContour;
begin
  out_values := nil;
  out_points.Items := nil;
  out_contours.Items := nil;
  TBlackSharkTesselator.TListPoints.Create(out_points, 64);
  TBlackSharkTesselator.TListContours.Create(out_contours, FContours.Count);
  for i := 0 to FContours.Count - 1 do
  begin
    contour.PointIndexBegin := out_points.Count;
    GenerateBezierSpline(PArrayVec3f(@FPoints.Items[FContours.Items[i].PointIndexBegin]), FContours.Items[i].CountPoints, out_values, FQualityInterpolate);
    for j := 0 to out_values.Count - 1 do
      TBlackSharkTesselator.TListPoints.Add(out_points, out_values.Items[j]);

    contour.CountPoints := out_values.Count;
    TBlackSharkTesselator.TListContours.Add(out_contours, contour);
    out_values.Count := 0;
  end;
  out_values.Free;
  indexes.Items := nil;
  TBlackSharkTesselator.TListIndexes.Create(indexes, 64);
  Tesselator.Triangulate(out_points, out_contours, indexes);
  for i := 0 to out_points.Count - 1 do
  begin
    Data.Mesh.AddVertex(out_points.Items[i]);
  end;
  for i := 0 to indexes.Count - 1 do
  begin
    Data.Mesh.Indexes.Add(indexes.Items[i]);
  end;
end;

procedure TFreeShape.SplineInterpolateCubic;
var
  out_values: TListVec<TVec3f>;
  i, j: int32;
  out_points: TPoints;
  out_contours: TContours;
  indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
  contour: TContour;
begin
  out_values := nil;
  out_points.Items := nil;
  out_contours.Items := nil;
  TBlackSharkTesselator.TListPoints.Create(out_points, 64);
  TBlackSharkTesselator.TListContours.Create(out_contours, FContours.Count);
  for i := 0 to FContours.Count - 1 do
  begin
    contour.PointIndexBegin := out_points.Count;
    GenerateCubicSpline(PArrayVec3f(@FPoints.Items[FContours.Items[i].PointIndexBegin]), FContours.Items[i].CountPoints, out_values, FQualityInterpolate);
    for j := 0 to out_values.Count - 1 do
      TBlackSharkTesselator.TListPoints.Add(out_points, out_values.Items[j]);

    contour.CountPoints := out_values.Count;
    TBlackSharkTesselator.TListContours.Add(out_contours, contour);
    out_values.Count := 0;
  end;
  out_values.Free;
  indexes.Items := nil;
  TBlackSharkTesselator.TListIndexes.Create(indexes, 64);
  Tesselator.Triangulate(out_points, out_contours, indexes);
  for i := 0 to out_points.Count - 1 do
  begin
    Data.Mesh.AddVertex(out_points.Items[i]);
  end;
  for i := 0 to indexes.Count - 1 do
  begin
    Data.Mesh.Indexes.Add(indexes.Items[i]);
  end;
end;

procedure TFreeShape.SplineInterpolateCubicHermite;
var
  out_values: TListVec<TVec3f>;
  i, j: int32;
  out_points: TPoints;
  out_contours: TContours;
  indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
  contour: TContour;
begin
  out_values := nil;
  TBlackSharkTesselator.TListPoints.Create(out_points{%H-}, 64);
  TBlackSharkTesselator.TListContours.Create(out_contours{%H-}, FContours.Count);
  for i := 0 to FContours.Count - 1 do
  begin
    contour.PointIndexBegin := out_points.Count;
    GenerateCubicHermiteSpline(PArrayVec3f(@FPoints.Items[FContours.Items[i].PointIndexBegin]), FContours.Items[i].CountPoints, out_values, FQualityInterpolate, true);
    for j := 0 to out_values.Count - 1 do
      TBlackSharkTesselator.TListPoints.Add(out_points, out_values.Items[j]);

    contour.CountPoints := out_values.Count;
    TBlackSharkTesselator.TListContours.Add(out_contours, contour);
    out_values.Count := 0;
  end;
  out_values.Free;
  TBlackSharkTesselator.TListIndexes.Create(indexes{%H-}, 64);
  Tesselator.Triangulate(out_points, out_contours, indexes);
  for i := 0 to out_points.Count - 1 do
  begin
    Data.Mesh.AddVertex(out_points.Items[i]);
  end;
  for i := 0 to indexes.Count - 1 do
  begin
    Data.Mesh.Indexes.Add(indexes.Items[i]);
  end;
end;

procedure TFreeShape.SplineNoInterpolate;
var
  i: int32;
  indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
begin
  indexes.Items := nil;
  TBlackSharkTesselator.TListIndexes.Create(indexes, 64);
  Tesselator.Triangulate(FPoints, FContours, indexes);
  for i := 0 to FPoints.Count - 1 do
  begin
    Data.Mesh.AddVertex(FPoints.Items[i]);
  end;
  for i := 0 to indexes.Count - 1 do
  begin
    Data.Mesh.Indexes.Add(indexes.Items[i]);
  end;
end;

{ TBaseLine }

constructor TBaseLine.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
end;

end.
