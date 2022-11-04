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


{ view of a scheme model (see bs.gui.scheme.model) }

unit bs.gui.scheme.view;

{$I BlackSharkCfg.inc}
{$M+}

interface

uses
    bs.events
  , bs.basetypes
  , bs.obj
  , bs.scene
  , bs.renderer
  , bs.canvas
  , bs.gui.scheme.controller
  , bs.gui.scheme.model
  , bs.gui.forms
  , bs.gui.scrollbox
  , bs.collections
  , bs.selectors
  , bs.geometry
  , bs.graphics
  , bs.texture
;

type

  TLinkDirection = class;
  TLinkVisual = class;

  { it is a view of model items (TSchemeShape) containing graphics
    data for display it }

  TSchemeItemVisual = class(ISchemeItemVisual)
  private
    OnBeginDragObsrv: IBDragDropEventObserver;
    OnDropObsrv: IBDragDropEventObserver;
    OnDragObsrv: IBDragDropEventObserver;
    OnMouseDownObsrv: IBMouseEventObserver;
    procedure OnDragScenItem({%H-}const Data: BDragDropData);
    procedure OnDropScenItem({%H-}const Data: BDragDropData);
    procedure OnBeginDrag({%H-}const Data: BDragDropData);
    function GetColorCaption: TGuiColor;
    procedure SetColorCaption(const Value: TGuiColor);
    procedure OnMouseDownEvent(const MData: BMouseData);
  protected
    FBody: TCanvasObject;
    FCaption: TCanvasText;
    Selector: TBlackSharkSelectorBB;
    SelectedBySelector: boolean;
    DblClickSbscr: IBMouseEventObserver;
    FCanvas: TBCanvas;
    FColorCaption: TColor4f;
    procedure DblClick(const Data: BMouseData);
    procedure SetSelected(const Value: boolean); override;
    procedure SetPosition(const Value: TVec2i); override;
    function GetPosition: TVec2i; override;
    procedure SelectColor; override;
    procedure SetCaption(const Value: string); override;
    procedure DragByParent(const NewPosition: TVec2f); override;
    procedure Hide; override;
    procedure Show; override;
    procedure AfterShow; override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    procedure Draw; override;
    procedure BeginDrag; override;
    procedure Drop(NewParent: TSchemeShape); override;
    property Body: TCanvasObject read FBody;
  published
    property ColorCaption: TGuiColor read GetColorCaption write SetColorCaption;
  end;

  TLinkAlign = (laLeft, laRight, laTop, laBottom);

  TLinkDirection = class
  private
    FDirList: TListVec<TLinkVisual>;
    function GetCount: int32;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddLink(Link: TLinkVisual);
    procedure DelLink(Link: TLinkVisual);
    property Count: int32 read GetCount;
  end;

  { a link b/w two TSchemeItemVisualLinked; Parent of the link is an object
    "from" }

  TLinkVisual = class(TSchemeItemVisual)
  private
    FAsSpline: boolean;
    FLinkOpacity: int8;
    FLinkWidth: int8;
    { path, the same Body }
    FPath: TPath;
    { it is invisible path, wider than FPath for more free selection }
    FShadow: TPath;
    Arrow: TTriangle;
    CaptionFrom: TCanvasText;
    CaptionTo: TCanvasText;
    FPositionOnParent: TVec2f;
    FPositionOnToLink: TVec2f;

    FAlignFrom: TLinkAlign;
    FAlignTo: TLinkAlign;
    FOverlap: TRectBSf;
    FDirectionIndex: int32;
    FDirection: TLinkDirection;
    FAddedToInput: boolean;

    procedure SetCaptionsPos;
    procedure ShowCaptions;
    procedure CheckDir;
    { take coord. and pos. of an area To }
    function GetArealTo: boolean;
    { take coord. and pos. of an area From }
    function GetArealFrom: boolean;
    function GetAreaFrom: TSchemeShape;
    function GetAreaTo: TSchemeShape;
    procedure SetLinkOpacity(const Value: int8);
    procedure SetLinkWidth(const Value: int8);
    procedure SetAsSpline(const Value: boolean);
    function GetColor: TGuiColor;
    procedure SetColor(const Value: TGuiColor);
    procedure CreateCaption;
  protected
    FAreaFrom: TSchemeShape;
    FAreaTo: TSchemeShape;
    FColor: TColor4f;
    procedure SetSelected(const Value: boolean); override;
    function GetPosition: TVec2i; override;
    procedure SetParent(const Value: TSchemeShape); override;
    procedure Show; override;
    procedure Hide; override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    destructor Destroy; override;
    procedure Draw; override;
    class function PresentedClass: TSchemeShapeClass; override;
    function SimilarDirect(Link: TSchemeLink): boolean;
    procedure CalcIntersectSide;
    property Path: TPath read FPath;
    property PositionOnParent: TVec2f read FPositionOnParent write FPositionOnParent;
    property PositionOnToLink: TVec2f read FPositionOnToLink write FPositionOnToLink;
    property AlignFrom: TLinkAlign read FAlignFrom;
    property AlignTo: TLinkAlign read FAlignTo;
    property DirectionIndex: int32 read FDirectionIndex;
    property Direction: TLinkDirection read FDirection;
    property AreaFrom: TSchemeShape read GetAreaFrom;
    property AreaTo: TSchemeShape read GetAreaTo;
    { overlap of AreaFrom and AreaTo }
    property Overlap: TRectBSf read FOverlap;
    property AddedToInput: boolean read FAddedToInput;
  published
    property LinkOpacity: int8 read FLinkOpacity write SetLinkOpacity;
    property LinkWidth: int8 read FLinkWidth write SetLinkWidth;
    property AsSpline: boolean read FAsSpline write SetAsSpline;
    property Color: TGuiColor read GetColor write SetColor;
  end;

  { a view of TSchemeLinkedShape }

  TSchemeItemVisualLinked = class(TSchemeItemVisual)
  public
    type
    TSchemeLinkDirProp = record
      CounLinks: int32;
      Sorted: TListVec<ISchemeItemVisual>;
    end;
  private
    LinksSorted: array [TLinkAlign] of TListVec<TLinkVisual>;
    Inputs: TListVec<TSchemeLink>;
    FLinks: TListVec<TSchemeLink>;
    ObsrvEventAfterLoad: IBObserver<BEmpty>;
    procedure BeforUpdateInput(Link: TLinkVisual);
    procedure AfterUpdateInput(Link: TLinkVisual);
    procedure BeforUpdateOutput(Link: TLinkVisual);
    procedure AfterUpdateOutput(Link: TLinkVisual);
    procedure ResetSortedLinks;
    procedure AfterLoad(const Data: BEmpty);
  protected
    { draw all links - inputs and outputs }
    procedure DrawLinks; virtual;
    procedure CalculatePosSortedLinks(Direction: ISchemeItemVisual);
    procedure CalculateLinks;
    procedure DragByParent(const NewPosition: TVec2f); override;
    procedure SetPosition(const Value: TVec2i); override;
    procedure Drag; override;
    { the methods only define which links need to draw }
    procedure AddInput(Link: TLinkVisual); virtual;
    procedure DeleteInput(Link: TSchemeLink); virtual;
    procedure DeleteOutput(Link: TSchemeLink); virtual;
    procedure SetParent(const Value: TSchemeShape); override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    destructor Destroy; override;
    procedure Draw; override;
    procedure Resize(AWidth, AHeight: int32); override;
    procedure Drop(NewParent: TSchemeShape); override;
    procedure DeleteLink(Link: TSchemeLink; FreeLink: boolean);
    { contains all links which visible and need to draw }
    property Links: TListVec<TSchemeLink> read FLinks;
  end;

  { a view of TSchemeProcessor }

  TProcessorVisual = class(TSchemeItemVisualLinked)
  private
    procedure RecreateBody;
    procedure RecreateBorder;
    procedure SetColor1(const Value: TGuiColor);
    procedure SetColor2(const Value: TGuiColor);
    procedure SetGradient(const Value: TGradientType);
    function GetColor1: TGuiColor;
    function GetColor2: TGuiColor;
    procedure SetBorderWidth(const Value: int8);
    procedure SetRadiusRound(const Value: int8);
    function GetColorBorder: TGuiColor;
    procedure SetColorBorder(const Value: TGuiColor);
  protected
    FBorderWidth: int8;
    FRadiusRound: int8;
    Border: TCanvasObjectP;
    FColor2: TColor4f;
    FColor1: TColor4f;
    FColorBorder: TColor4f;
    FGradient: TGradientType;
    procedure SelectColor; override;
    procedure Show; override;
    procedure Hide; override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    procedure AfterConstruction; override;
    procedure Draw; override;
    class function PresentedClass: TSchemeShapeClass; override;
  published
    property BorderWidth: int8 read FBorderWidth write SetBorderWidth;
    property RadiusRound: int8 read FRadiusRound write SetRadiusRound;
    property Color2: TGuiColor read GetColor2 write SetColor2;
    property Color1: TGuiColor read GetColor1 write SetColor1;
    property ColorBorder: TGuiColor read GetColorBorder write SetColorBorder;
    property Gradient: TGradientType read FGradient write SetGradient;
  end;

  { a view of block }

  TBlockVisual = class(TSchemeItemVisualLinked)
  private
    Border: TRectangle;
    Border2: TRectangle;
    AcceptBorder: TRectangle;
    Pic: TPicture;
    FFileTexture: string;
    FFileIco: string;
    FBorderWidth: int8;
    FTextureGL: PTextureArea;
    TxtInt: IBlackSharkTexture;
    FTextureIcoGL: PTextureArea;
    TxtIntIco: IBlackSharkTexture;
    NowBlockTextureIsSimple: boolean;
    FColor2: TColor4f;
    FColor1: TColor4f;
    FColorBorder: TColor4f;
    FColorBorderInside: TColor4f;
    LinksLoaded: boolean;
    procedure CreateBorder2;
    procedure LoadTextures;
    procedure LoadText;
    procedure LoadTextIco;
    procedure SetBorderWidth(const Value: int8);
    procedure SetFileIco(const Value: string);
    procedure SetFileTexture(const Value: string);
    function GetColor1: TGuiColor;
    function GetColor2: TGuiColor;
    procedure SetColor1(const Value: TGuiColor);
    procedure SetColor2(const Value: TGuiColor);
    function GetColorBorder: TGuiColor;
    function GetColorBorderInside: TGuiColor;
    procedure SetColorBorder(const Value: TGuiColor);
    procedure SetColorBorderInside(const Value: TGuiColor);
    procedure LoadLinks;
  protected
    procedure SelectColor; override;
    procedure Show; override;
    procedure Hide; override;
    procedure BeginDragOver; override;
    procedure EndDragOver; override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    destructor Destroy; override;
    procedure Draw; override;
    class function PresentedClass: TSchemeShapeClass; override;
  published
    property BorderWidth: int8 read FBorderWidth write SetBorderWidth;
    property FileTexture: string read FFileTexture write SetFileTexture;
    property FileIco: string read FFileIco write SetFileIco;
    property Color1: TGuiColor read GetColor1 write SetColor1;
    { color2 is used only if FileTexture has not been found }
    property Color2: TGuiColor read GetColor2 write SetColor2;
    property ColorBorder: TGuiColor read GetColorBorder write SetColorBorder;
    property ColorBorderInside: TGuiColor read GetColorBorderInside write SetColorBorderInside;
  end;

  { input/output to/from, has a rectangle around caption }

  TBlockPointVisual = class(TSchemeItemVisualLinked)
  private
    function GetColor: TGuiColor;
    function GetColorBorder: TGuiColor;
    function GetColorBorderInside: TGuiColor;
    procedure SetColor(const Value: TGuiColor);
    procedure SetColorBorder(const Value: TGuiColor);
    procedure SetColorBorderInside(const Value: TGuiColor);
  protected
    Border: TRectangle;
    Border2: TRectangle;
    FColorBorder: TColor4f;
    FColor: TColor4f;
    FColorBorderInside: TColor4f;
    procedure Show; override;
    procedure Hide; override;
  public
    procedure Draw; override;
    property Color: TGuiColor read GetColor write SetColor;
    property ColorBorder: TGuiColor read GetColorBorder write SetColorBorder;
    property ColorBorderInside: TGuiColor read GetColorBorderInside write SetColorBorderInside;
  end;

  { a visual input to block }

  TBlockPointVisualInput = class(TBlockPointVisual)
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    procedure AfterConstruction; override;
    class function PresentedClass: TSchemeShapeClass; override;
  protected
    procedure Show; override;
  published
    property Color;
    property ColorBorder;
    property ColorBorderInside;
  end;

  { a visual output from block }

  TBlockPointVisualOutput = class(TBlockPointVisual)
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    class function PresentedClass: TSchemeShapeClass; override;
  published
    property Color;
    property ColorBorder;
    property ColorBorderInside;
  end;

  { region or group of items }

  TRegionVisual = class(TSchemeItemVisual)
  private
    Border: TRectangle;
    Backgr: TRectangle;
    AcceptBorder: TRectangle;
    procedure SetBackgrOpacity(const Value: BSFloat);
    procedure SetBodyOpacity(const Value: BSFloat);
    procedure SetBodyWidth(const Value: int8);
    procedure SetBorderOpacity(const Value: BSFloat);
    procedure SetBorderWidth(const Value: int8);
    function GetColor: TGuiColor;
    function GetColorBackground: TGuiColor;
    function GetColorInside: TGuiColor;
    procedure SetColor(const Value: TGuiColor);
    procedure SetColorBackground(const Value: TGuiColor);
    procedure SetColorInside(const Value: TGuiColor);
    procedure CreateCaption;
  protected
    FBodyWidth: int8;
    FBorderWidth: int8;
    FBorderOpacity: BSFloat;
    FBodyOpacity: BSFloat;
    FBackgrOpacity: BSFloat;
    FColor: TColor4f;
    FColorInside: TColor4f;
    FColorBackground: TColor4f;
    procedure Drag; override;
    procedure Show; override;
    procedure Hide; override;
    procedure BeginDragOver; override;
    procedure EndDragOver; override;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); override;
    procedure AfterConstruction; override;
    procedure Draw; override;
    procedure BeginDrag; override;
    procedure Drop(NewParent: TSchemeShape); override;
    class function PresentedClass: TSchemeShapeClass; override;
  published
    property BorderWidth: int8 read FBorderWidth write SetBorderWidth;
    property BodyWidth: int8 read FBodyWidth write SetBodyWidth;
    property BorderOpacity: BSFloat read FBorderOpacity write SetBorderOpacity;
    property BodyOpacity: BSFloat read FBodyOpacity write SetBodyOpacity;
    property BackgrOpacity: BSFloat read FBackgrOpacity write SetBackgrOpacity;
    property Color: TGuiColor read GetColor write SetColor;
    property ColorInside: TGuiColor read GetColorInside write SetColorInside;
    property ColorBackground: TGuiColor read GetColorBackground write SetColorBackground;
  end;

  TOnSelectSchemeItem = procedure(Item: TSchemeShape) of object;

  { viewer of a scheme;
    TODO: history of changes;
    TODO: a style editor; }

  { TSchemeView }

  TSchemeView = class(ISchemeRenderer)
  private
    const
      RASTER_FONT_SIZE_DEFAULT = 8;
  private
    FCanvas: TBCanvas;
    FOnSelectProcessor: TOnSelectSchemeItem;
    Selector: TBlackSharkSelectorInstances;
    SelectorsBB: TListVec<TBlackSharkSelectorBB>;
    SelectorsUsed: TBinTreeTemplate<TSchemeItemVisual, TBlackSharkSelectorBB>;
    Grid: TGrid;
    SmallGrid: TGrid;
{$IFDEF debug_scheme}
    _SrvBillboard: TBCanvas;
    _RectBillb: TRectangle;
    _DraggedData: TCanvasText;
    _BSObjects: TCanvasText;
{$ENDIF}
    ObsrvMDownOnSceen: IBMouseEventObserver;
    ObsrvMUpOnSceen: IBMouseEventObserver;
    ObsrvMDownMissOnSceen: IBMouseEventObserver;
    ObsrvMMove: IBMouseEventObserver;
    // LinksFree: TBinTreeTemplate<int32, TLinkVisual>;
    // ListRemoveLink: TListVec<TLinkVisual>;
    function OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
    procedure UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
    procedure OnResizeInstance(Instance: PGraphicInstance; const Scale: TVec3f; const Point: TBBLimitPoint);
    procedure OnDropResize(Instance: PGraphicInstance);
    procedure OnBeginResize(Instance: PGraphicInstance);
    function GetSelector: TBlackSharkSelectorBB;
    procedure MouseDownOnScreen({%H-}const Data: BMouseData);
    // procedure EndDrag({%H-}const Data: BEmpty);
    procedure DblClickMiss({%H-}const Data: BMouseData);
    procedure OnMouseUp({%H-}const Data: BMouseData);
    procedure OnMouseMove({%H-}const Data: BMouseData);
    procedure DoDrawGrid;
    procedure OnChangePosition(Sender: TBScrolledWindowCustom; const NewPosition: TVec2d);
  protected
    FScenarioOwner: TCanvasObject;
    FProcessorOwner: TCanvasObject;
    FScrollBox: TBScrollBox;
    procedure SetViewedBlock(const Value: TSchemeBlock); override;
    procedure OnHideData(Node: PNodeSpaceTree); override;
    procedure OnShowData(Node: PNodeSpaceTree); override;
    procedure SetDrawGrid(const Value: boolean); override;
    { two methods below alocate/free for Item apropriate data need for mark
      selected }
    function DoSelect(Item: TSchemeItemVisual): TBlackSharkSelectorBB;
    procedure DoUnselect(Item: TSchemeItemVisual);
    procedure SetScale(const Value: BSFloat); override;
    procedure SetBanSelect(const Value: boolean); override;
    procedure SelectFontSize; override;
    procedure SetGridStep(const Value: int32); override;
    procedure SetEnabled(const Value: boolean); override;
    procedure SetColorGrid(const Value: TGuiColor); override;
    procedure SetGridOpacity(const Value: int8); override;
    procedure SetColorGrid2(const Value: TGuiColor); override;
    procedure SetColorScrollBar(const Value: TColor4f); override;
    function GetColorScrollBar: TColor4f; override;
    function GetPosition: TVec2f; override;
    procedure SetPosition(const Value: TVec2f); override;
    procedure OnChangeSelectItemDo(Item: ISchemeItemVisual); override;
    function GetColorBackground: TGuiColor; override;
    procedure SetColorBackground(const Value: TGuiColor); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer);
    destructor Destroy; override;
    procedure CheckBoundary; override;
    procedure Resize(Width, Height: BSFloat); override;
    function ClientSize: TVec2f; override;
    function GetViewPortPosition: TVec2f; override;
    procedure SetViewPortPosition(const Value: TVec2f); override;
    procedure BeginDragItems; override;
    procedure DragDropItem(Item: ISchemeItemVisual); override;
    procedure EndDragItems; override;
    property Canvas: TBCanvas read FCanvas;
    { 2d position on viewport of scene }
    property Position: TVec2f read GetPosition write SetPosition;
    property ScrollBox: TBScrollBox read FScrollBox;
    property OnSelectProcessor: TOnSelectSchemeItem read FOnSelectProcessor write FOnSelectProcessor;
  end;

  TSchemeLinkCmp = function(const Item1, Item2: TLinkVisual): int8;

function CmpLinksX(const Item1, Item2: TLinkVisual): int8;
function CmpLinksY(const Item1, Item2: TLinkVisual): int8;

const

  CMP_LINK: array [TLinkAlign] of TSchemeLinkCmp = (CmpLinksY, CmpLinksY, CmpLinksX, CmpLinksX);

implementation

uses
    SysUtils
  , bs.scene.objects
  , bs.utils
  , bs.font
  , bs.thread
  , bs.align
  ;

function CmpLinksX(const Item1, Item2: TLinkVisual): int8;
begin
  if Item1.SchemeData.Center.x < Item2.SchemeData.Center.x then
    Result := -1
  else if Item1.SchemeData.Center.x > Item2.SchemeData.Center.x then
    Result := 1
  else
    Result := 0;
end;

function CmpLinksY(const Item1, Item2: TLinkVisual): int8;
begin
  if Item1.SchemeData.Center.y < Item2.SchemeData.Center.y then
    Result := -1
  else if Item1.SchemeData.Center.y > Item2.SchemeData.Center.y then
    Result := 1
  else
    Result := 0;
end;

{ TLinkDirection }

procedure TLinkDirection.AddLink(Link: TLinkVisual);
begin
  Link.FDirectionIndex := FDirList.Count;
  FDirList.Add(Link);
end;

constructor TLinkDirection.Create;
begin
  FDirList := TListVec<TLinkVisual>.Create;
end;

procedure TLinkDirection.DelLink(Link: TLinkVisual);
var
  i: int32;
begin
  FDirList.Delete(Link.FDirectionIndex);
  for i := 0 to FDirList.Count - 1 do
    FDirList.Items[i].FDirectionIndex := i;
  if FDirList.Count = 0 then
    Free;
end;

destructor TLinkDirection.Destroy;
begin
  FDirList.Free;
  inherited;
end;

function TLinkDirection.GetCount: int32;
begin
  Result := FDirList.Count;
end;

{ TSchemeItemVisualLinked }

constructor TSchemeItemVisualLinked.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  LinksSorted[laLeft] := TListVec<TLinkVisual>.Create(@CmpLinksY);
  LinksSorted[laLeft].TagPtr := Self;
  LinksSorted[laRight] := TListVec<TLinkVisual>.Create(@CmpLinksY);
  LinksSorted[laRight].TagPtr := Self;
  LinksSorted[laTop] := TListVec<TLinkVisual>.Create(@CmpLinksX);
  LinksSorted[laTop].TagPtr := Self;
  LinksSorted[laBottom] := TListVec<TLinkVisual>.Create(@CmpLinksX);
  LinksSorted[laBottom].TagPtr := Self;
  Inputs := TListVec<TSchemeLink>.Create(@PtrCmp);
  FLinks := TListVec<TSchemeLink>.Create(@PtrCmp);
  ObsrvEventAfterLoad := FRenderer.EventAfterLoadLevel.CreateObserver(GUIThread, AfterLoad);
end;

procedure TSchemeItemVisualLinked.DeleteInput(Link: TSchemeLink);
begin
  Inputs.Remove(Link);
  FLinks.Remove(Link);
end;

procedure TSchemeItemVisualLinked.DeleteLink(Link: TSchemeLink; FreeLink: boolean);
begin
  if not FreeLink then
  begin
    if Link.Parent = FSchemeData then
    begin
      DeleteOutput(Link);
      if (Link.View <> nil) and (TLinkVisual(Link.View).FAreaTo <> nil) and (TLinkVisual(Link.View).FAreaTo.View <> nil) then
        TSchemeItemVisualLinked(TLinkVisual(Link.View).FAreaTo.View).DeleteInput(Link);
    end else
    begin
      DeleteInput(Link);
      if (Link.View <> nil) and (TLinkVisual(Link.View).FAreaFrom <> nil) and (TLinkVisual(Link.View).FAreaFrom.View <> nil) then
        TSchemeItemVisualLinked(TLinkVisual(Link.View).FAreaFrom.View).DeleteOutput(Link);
    end;
  end;
  TSchemeLinkedShape(Link.Parent).DeleteOutput(Link, FreeLink);
end;

procedure TSchemeItemVisualLinked.DeleteOutput(Link: TSchemeLink);
begin
  FLinks.Remove(Link);
end;

destructor TSchemeItemVisualLinked.Destroy;
var
  la: TLinkAlign;
  i: int32;
begin
  for i := 0 to Inputs.Count - 1 do
    if Inputs.Items[i].View <> nil then
      TLinkVisual(Inputs.Items[i].View).FAreaTo := nil;
  Inputs.Free;
  FLinks.Free;
  for la := low(TLinkAlign) to high(TLinkAlign) do
    LinksSorted[la].Free;
  inherited;
end;

procedure TSchemeItemVisualLinked.DragByParent(const NewPosition: TVec2f);
begin
  inherited;
  CalculateLinks;
end;

procedure TSchemeItemVisualLinked.Drag;
begin
  inherited;
  CalculateLinks;
  DrawLinks;
end;

procedure TSchemeItemVisualLinked.Draw;
begin
  inherited;
  CalculateLinks;
  DrawLinks;
end;

procedure TSchemeItemVisualLinked.DrawLinks;
var
  i: int32;
  l: TSchemeLink;
begin
  for i := 0 to FLinks.Count - 1 do
  begin
    l := FLinks.Items[i];
    if (l = nil) or (l.View = nil) or (not ISchemeItemVisual(l.View).Visible) then
      continue;
    ISchemeItemVisual(l.View).Draw;
  end;
end;

procedure TSchemeItemVisualLinked.AddInput(Link: TLinkVisual);
begin
  if Link.FAddedToInput then
    exit;
  Link.FAddedToInput := true;
  Inputs.Add(TSchemeLink(Link.FSchemeData));
end;

procedure TSchemeItemVisualLinked.AfterLoad(const Data: BEmpty);
begin
  CalculateLinks;
  DrawLinks;
end;

procedure TSchemeItemVisualLinked.AfterUpdateInput(Link: TLinkVisual);
begin
  LinksSorted[Link.AlignTo].Add(Link);
end;

procedure TSchemeItemVisualLinked.AfterUpdateOutput(Link: TLinkVisual);
begin
  LinksSorted[Link.AlignFrom].Add(Link);
end;

procedure TSchemeItemVisualLinked.BeforUpdateInput(Link: TLinkVisual);
begin
  LinksSorted[Link.AlignTo].Comparator := @PtrCmp; // for remove
  LinksSorted[Link.AlignTo].Remove(Link);
  LinksSorted[Link.AlignTo].Comparator := CMP_LINK[Link.AlignTo]; // for sort
end;

procedure TSchemeItemVisualLinked.BeforUpdateOutput(Link: TLinkVisual);
begin
  LinksSorted[Link.AlignFrom].Comparator := @PtrCmp; // for remove
  LinksSorted[Link.AlignFrom].Remove(Link);
  LinksSorted[Link.AlignFrom].Comparator := CMP_LINK[Link.AlignFrom]; // for sort
end;

procedure TSchemeItemVisualLinked.Drop(NewParent: TSchemeShape);
begin
  inherited;
end;

procedure TSchemeItemVisualLinked.Resize(AWidth, AHeight: int32);
begin
  inherited;
  CalculateLinks;
  DrawLinks;
end;

procedure TSchemeItemVisualLinked.SetParent(const Value: TSchemeShape);
var
  i: int32;
  l: TSchemeLink;
  opposite: TSchemeShape;
begin
  inherited;
  for i := FLinks.Count - 1 downto 0 do
  begin
    l := FLinks.Items[i];
    if (Pointer(TLinkVisual(l.View).FAreaFrom.View) <> Self) then
      opposite := TLinkVisual(l.View).FAreaFrom
    else
      opposite := TLinkVisual(l.View).FAreaTo;
    if ((opposite = nil) or (opposite.View = nil) or (not ISchemeItemVisual(opposite.View).IsDrag)) and (not TSchemeLinkedShape(l.Parent).PossibleOutput(l.ToLink)) then
    begin
      DeleteLink(l, true);
    end;
  end;
end;

procedure TSchemeItemVisualLinked.SetPosition(const Value: TVec2i);
begin
  inherited;
  CalculateLinks;
  DrawLinks;
end;

procedure TSchemeItemVisualLinked.ResetSortedLinks;
begin
  LinksSorted[laLeft].Count := 0;
  LinksSorted[laRight].Count := 0;
  LinksSorted[laTop].Count := 0;
  LinksSorted[laBottom].Count := 0;
end;

procedure TSchemeItemVisualLinked.CalculateLinks;
var
  i: int32;
  l: TSchemeLink;
  lv: TLinkVisual;
begin
  ResetSortedLinks;
  FLinks.Count := 0;
  for i := 0 to TSchemeLinkedShape(FSchemeData).CountOutputs - 1 do
  begin
    l := TSchemeLinkedShape(FSchemeData).Output[i];
    if (l = nil) or (l.View = nil) then
      continue;
    lv := TLinkVisual(l.View);
    if (lv.AreaTo <> nil) and (lv.AreaFrom <> nil) then
      FLinks.Add(l);
  end;
  FLinks.AddList(Inputs);
  for i := 0 to FLinks.Count - 1 do
  begin
    lv := TLinkVisual(FLinks.Items[i].View);
    if (lv.FAreaTo.View = nil) or (lv.FAreaFrom.View = nil) then
      continue;
    if not lv.AddedToInput then
      TSchemeItemVisualLinked(lv.FAreaTo.View).AddInput(lv);
    TSchemeItemVisualLinked(lv.FAreaTo.View).BeforUpdateInput(lv);
    TSchemeItemVisualLinked(lv.FAreaFrom.View).BeforUpdateOutput(lv);
    lv.CalcIntersectSide;
    if (lv.FAreaFrom = nil) or (lv.FAreaFrom.View = nil) or (lv.FAreaTo = nil) or (lv.FAreaTo.View = nil) then
      continue;
    TSchemeItemVisualLinked(lv.FAreaFrom.View).AfterUpdateOutput(lv);
    TSchemeItemVisualLinked(lv.FAreaTo.View).AfterUpdateInput(lv);
  end;
  CalculatePosSortedLinks(nil);
end;

procedure TSchemeItemVisualLinked.CalculatePosSortedLinks(Direction: ISchemeItemVisual);
var
  i: int32;
  h: BSFloat;
  pos: TVec2f;
  l: TLinkVisual;
  la: TLinkAlign;
  ar_link: TSchemeShape;
  ar_inv: TSchemeShape;
begin
  for la := Low(TLinkAlign) to High(TLinkAlign) do
  begin
    for i := 0 to LinksSorted[la].Count - 1 do
    begin
      l := LinksSorted[la].Items[i];
      if (l.Direction = nil) then
      begin
        l.CheckDir;
        if (l.Direction = nil) then
          continue;
      end;

      if (l.AreaFrom = nil) or (l.AreaTo = nil) or (l.FAreaTo.View = nil) or (l.FAreaFrom.View = nil) then
        continue;

      if l.FAreaFrom = l.FAreaTo then
      begin
        pos.x := l.FAreaFrom.Position.x + FRenderer.GridStep;
        pos.y := l.FAreaFrom.Position.y;
        l.FPositionOnToLink := pos;
        pos.y := l.FAreaFrom.Position.y + l.FAreaFrom.Height;
        l.FPositionOnParent := pos;
        FRenderer.UpdateInSpaceTree(l);
        continue;
      end;

      if (l.Parent = FSchemeData) or (l.FAreaFrom = FSchemeData) then // or (Self = ISchemeItemVisual(l.View))
      begin // סגמÿ סגÿחü From
        ar_link := l.FAreaFrom;
        ar_inv := l.FAreaTo;
        // la_inv := l.AlignTo;
      end
      else
      begin
        ar_link := l.FAreaTo;
        ar_inv := l.FAreaFrom;
        // la_inv := l.AlignFrom;
      end;

      if la < laTop then
      begin // left, right
        if l.Overlap.Height > 0 then
        begin
          h := round(l.Overlap.Height) / l.Direction.Count;
          if la <> laLeft then
            pos := vec2(ar_link.Position.x + ar_link.Width, l.Overlap.y + h * l.DirectionIndex + h * 0.5)
          else // right
            pos := vec2(ar_link.Position.x, l.Overlap.y + h * l.DirectionIndex + h * 0.5); // left
        end
        else
        begin
          h := ar_link.Height div LinksSorted[la].Count;
          if (la <> laLeft) then
            pos := vec2(ar_link.Position.x + ar_link.Width, ar_link.Position.y + h * i + h * 0.5)
          else // right
          if (l.Direction.Count = 1) then
            pos := vec2(ar_link.Position.x, ar_link.Position.y + h * i + h * 0.5)
          else // left
            pos := vec2(ar_link.Position.x, ar_link.Position.y + h * (LinksSorted[la].Count - i - 1) + h * 0.5); // left
        end;
      end
      else
      begin // top, bottom
        if l.Overlap.Width > 0 then
        begin
          h := round(l.Overlap.Width) div l.Direction.Count;
          if la <> laTop then
            pos := vec2(l.Overlap.x + h * l.DirectionIndex + h * 0.5, ar_link.Position.y + ar_link.Height)
          else // bottom
            pos := vec2(l.Overlap.x + h * l.DirectionIndex + h * 0.5, ar_link.Position.y); // top
        end
        else
        begin
          h := ar_link.Width div LinksSorted[la].Count;
          if (la <> laTop) then
            pos := vec2(ar_link.Position.x + h * i + h * 0.5, ar_link.Position.y + ar_link.Height)
          else // bottom
          if (l.Direction.Count = 1) then
            pos := vec2(ar_link.Position.x + h * i + h * 0.5, ar_link.Position.y)
          else // top
            pos := vec2(ar_link.Position.x + h * (LinksSorted[la].Count - i - 1) + h * 0.5, ar_link.Position.y); // top
        end;
      end;

      if pos.x > ar_link.Position.x + ar_link.Width then
        pos.x := ar_link.Position.x + ar_link.Width - 3.0;
      if pos.y > ar_link.Position.y + ar_link.Height then
        pos.y := ar_link.Position.y + ar_link.Height - 3.0;

      if FRenderer.DrawGrid and not ISchemeItemVisual(l.AreaFrom.View).IsDrag and not ISchemeItemVisual(l.AreaTo.View).IsDrag then
        pos := FRenderer.GetAlignedOnGridPosition(pos);

      if ar_link = l.AreaFrom then
        l.PositionOnParent := pos
      else
        l.PositionOnToLink := pos;

      if Direction = nil then
        TSchemeItemVisualLinked(ar_inv.View).CalculatePosSortedLinks(ISchemeItemVisual(ar_link.View));

      FRenderer.UpdateInSpaceTree(l);
    end;
  end;

end;

{ TProcessorVisual }

procedure TProcessorVisual.AfterConstruction;
begin
  inherited;
  LoadChildren;
end;

constructor TProcessorVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FGradient := TGradientType.gtVerical;
  FColorBorder := BS_CL_SKY;
  FColor1 := COLOR_NO_LOAD_PROC1;
  FColor2 := COLOR_NO_LOAD_PROC2;
  FColorCaption := BS_CL_WHITE;
  FBorderWidth := 1;
  FRadiusRound := 5;
end;

procedure TProcessorVisual.Draw;
var
  s: TVec2f;
begin

  if FBorderWidth = 0 then
    FreeAndNil(Border);

  s.x := FSchemeData.Width * FRenderer.Scale;
  s.y := FSchemeData.Height * FRenderer.Scale;

  TRoundRectTextured(FBody).Size := s;
  TRoundRectTextured(FBody).RadiusRound := FRadiusRound;
  if FBorderWidth > 0 then
  begin
    if (Border = nil) or not(Border is TRoundRect) then
      RecreateBorder;
    TRoundRect(Border).Size := s;
    TRoundRect(Border).RadiusRound := FRadiusRound;
    TRoundRect(Border).WidthLine := FBorderWidth;
    Border.Color := FColorBorder;
  end;

  FCaption.Color := FColorCaption;
  FCaption.SceneTextData.TxtProcessor.ViewportWidth := s.x;
  FCaption.SceneTextData.BeginChangeProp;
  FCaption.SceneTextData.OutToWidth := s.x - 6;
  FCaption.SceneTextData.OutToHeight := s.y;
  FCaption.SceneTextData.EndChangeProp;
  inherited;
  if FBorderWidth > 0 then
  begin
    Border.Build;
    Border.Position2d := vec2(0.0, 0.0);
  end;
  FCaption.ToParentCenter;
end;

function TProcessorVisual.GetColor1: TGuiColor;
begin
  Result := ColorFloatToByte(FColor1).Value;
end;

function TProcessorVisual.GetColor2: TGuiColor;
begin
  Result := ColorFloatToByte(FColor2).Value;
end;

function TProcessorVisual.GetColorBorder: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBorder).Value;
end;

procedure TProcessorVisual.Hide;
begin
  FreeAndNil(Border);
  inherited;
end;

class function TProcessorVisual.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeProcessor;
end;

procedure TProcessorVisual.RecreateBody;
begin
  if FBody <> nil then
    FreeAndNil(FBody);
  FBody := TRoundRectTextured.Create(FCanvas, TSchemeView(FRenderer).FProcessorOwner);
  TRoundRectTextured(FBody).Fill := true;
  TRoundRectTextured(FBody).RadiusRound := FRadiusRound;
  if FCaption <> nil then
    FCaption.Parent := FBody;
end;

procedure TProcessorVisual.RecreateBorder;
begin
  if Border <> nil then
    FreeAndNil(Border);

  if FBorderWidth > 0 then
  begin
    Border := TRoundRect.Create(FCanvas, FBody);
    TRoundRect(Border).Fill := false;
    TRoundRect(Border).RadiusRound := TRoundRectTextured(FBody).RadiusRound;
    Border.Data.Interactive := false;
  end;
end;

procedure TProcessorVisual.SelectColor;
begin
  inherited;
  if Assigned(FBody) then
    TTexturedVertexes(TRoundRectTextured(FBody).Data).texture := BSTextureManager.GenerateTexture(FColor1, FColor2, FGradient, 32);
end;

procedure TProcessorVisual.SetColor1(const Value: TGuiColor);
begin
  FColor1 := ColorByteToFloat(Value);
  FColor1.a := 1.0;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.SetColor2(const Value: TGuiColor);
begin
  FColor2 := ColorByteToFloat(Value);
  FColor2.a := 1.0;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.SetColorBorder(const Value: TGuiColor);
begin
  FColorBorder := ColorByteToFloat(Value);
  FColorBorder.a := 1.0;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.SetGradient(const Value: TGradientType);
begin
  FGradient := Value;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.SetBorderWidth(const Value: int8);
begin
  FBorderWidth := Value;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.SetRadiusRound(const Value: int8);
begin
  FRadiusRound := Value;
  if Visible then
    Draw;
end;

procedure TProcessorVisual.Show;
begin
  inherited;
  if FBody = nil then
  begin
    RecreateBody;
    RecreateBorder;
    FCaption := TCanvasText.Create(TSchemeView(FRenderer).FCanvas, FBody);
    FCaption.Text := FSchemeData.Caption;
    FCaption.Data.Interactive := false;
    FCaption.Align := TObjectAlign.oaCenter;
    FCaption.ToParentCenter;
    FCaption.Anchors[aLeft] := false;
    FCaption.Anchors[aTop] := false;
    DblClickSbscr := FBody.Data.EventMouseDblClick.CreateObserver(GUIThread, DblClick);
  end;
end;

{ TBlockVisual }

procedure TBlockVisual.LoadLinks;
var
  i: int32;
  li: TSchemeLink;
  cl: ISchemeItemVisualClass;
begin
  LinksLoaded := true;
  for i := 0 to TSchemeBlock(FSchemeData).CountOutputs - 1 do
  begin
    li := TSchemeBlock(FSchemeData).Output[i];
    if li = nil then
      continue;
    cl := FRenderer.GetClassVisualItem(li.ClassName);
    if not Assigned(cl) then
      raise Exception.Create('Error Message');
    FRenderer.UpdateInSpaceTree(cl.Create(FRenderer, li));
  end;
end;

procedure TBlockVisual.LoadText;
var
  full_path: string;
begin
  TxtInt := nil;
  full_path := GetFullFromRelativePath(AppPath, FFileTexture);
  if FileExists(full_path) then
  begin
    FTextureGL := BSTextureManager.LoadTexture(full_path);
    NowBlockTextureIsSimple := false;
    if FTextureGL <> nil then
      TxtInt := FTextureGL.Texture;
  end
  else
  begin
    NowBlockTextureIsSimple := true;
    FTextureGL := BSTextureManager.GenerateTexture(FColor1, FColor2, TGradientType.gtVerical, 32);
  end;
end;

procedure TBlockVisual.LoadTextIco;
var
  full_path: string;
begin
  full_path := GetFullFromRelativePath(AppPath, FFileIco);
  TxtIntIco := nil;
  if FileExists(full_path) then
  begin
    FTextureIcoGL := BSTextureManager.LoadTexture(full_path);
    if FTextureIcoGL <> nil then
      TxtIntIco := FTextureIcoGL.Texture;
  end;
end;

procedure TBlockVisual.LoadTextures;
begin
  LoadText;
  LoadTextIco;
end;

procedure TBlockVisual.BeginDragOver;
begin
  inherited;
  if AcceptBorder = nil then
  begin
    AcceptBorder := TRectangle.Create(FCanvas, Border);
    AcceptBorder.Color := BS_CL_GREEN;
    AcceptBorder.Size := Border.Size + 4;
    AcceptBorder.Fill := false;
    AcceptBorder.WidthLine := 2;
    AcceptBorder.Build;
    AcceptBorder.Position2d := vec2(-2.0, -2.0);
  end;
end;

constructor TBlockVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FFileTexture := '%app%Pictures/Textures/block_text.png';
  FFileIco := '%app%Pictures/Textures/block_pic_32.png';
  FColor1 := COLOR_NO_LOAD_BLOK1;
  FColor2 := COLOR_NO_LOAD_BLOK2;
  FColorBorder := BS_CL_MSVS_BORDER;
  FColorBorderInside := BS_CL_MED_GRAY;
  FColorCaption := BS_CL_BLACK;
  FBorderWidth := 1;
end;

procedure TBlockVisual.CreateBorder2;
begin
  Border2 := TRectangle.Create(TSchemeView(FRenderer).FCanvas, FBody);
  Border2.Fill := false;
  Border2.Data.Interactive := false;
end;

destructor TBlockVisual.Destroy;
begin
  TxtInt := nil;
  TxtIntIco := nil;
  inherited;
end;

procedure TBlockVisual.Draw;
var
  s: TVec2f;
  i: int32;
  l: TSchemeLink;
begin

  for i := 0 to TSchemeLinkedShape(FSchemeData).CountOutputs - 1 do
  begin
    l := TSchemeLinkedShape(FSchemeData).Output[i];
    if (l = nil) or (l.View = nil) then
      continue;
    { output links from block do not have a caption }
    l.Caption := '';
  end;

  if (FBody <> nil) then
    FBody.Color := FColor1;
  if Pic <> nil then
    Pic.Color := FColor1;

  s.x := FSchemeData.Width * FRenderer.Scale;
  s.y := FSchemeData.Height * FRenderer.Scale;
  TPicture(FBody).Size := s;
  TPicture(FBody).Texture := FTextureGL;
  if Pic <> nil then
  begin
    if FTextureIcoGL <> nil then
      Pic.Texture := FTextureIcoGL
    else
      FreeAndNil(Pic);
  end;

  Border.Size := s - 4;
  Border.WidthLine := 1;
  Border.Color := FColorBorderInside;

  if FBorderWidth > 0 then
  begin
    if Border2 = nil then
      CreateBorder2;
    Border2.Size := s;
    Border2.Color := FColorBorder;
  end
  else
    FreeAndNil(Border2);

  FCaption.Color := FColorCaption;

  FCaption.SceneTextData.TxtProcessor.ViewportWidth := Border.Size.x;
  FCaption.SceneTextData.BeginChangeProp;
  FCaption.SceneTextData.OutToWidth := s.x - 10;
  FCaption.SceneTextData.OutToHeight := s.y;
  FCaption.SceneTextData.EndChangeProp;
  inherited;
  Border.Build;
  Border.Position2d := vec2(2.0, 2.0);
  if Border2 <> nil then
  begin
    Border2.WidthLine := FBorderWidth;
    Border2.Build;
    Border2.Position2d := vec2(0.0, 0.0);
  end;
  if Pic <> nil then
    Pic.Position2d := vec2(s.x - Pic.Texture.Rect.Width - 4, 4);
  FCaption.ToParentCenter;
end;

procedure TBlockVisual.EndDragOver;
begin
  inherited;
  if AcceptBorder <> nil then
    FreeAndNil(AcceptBorder);
end;

function TBlockVisual.GetColor1: TGuiColor;
begin
  Result := ColorFloatToByte(FColor1).Value;
end;

function TBlockVisual.GetColor2: TGuiColor;
begin
  Result := ColorFloatToByte(FColor2).Value;
end;

function TBlockVisual.GetColorBorder: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBorder).Value;
end;

function TBlockVisual.GetColorBorderInside: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBorderInside).Value;
end;

procedure TBlockVisual.Hide;
begin
  DblClickSbscr := nil;
  FreeAndNil(Pic);
  FreeAndNil(Border);
  FreeAndNil(Border2);
  inherited;
end;

class function TBlockVisual.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeBlock;
end;

procedure TBlockVisual.SelectColor;
begin
  inherited;
end;

procedure TBlockVisual.SetBorderWidth(const Value: int8);
begin
  FBorderWidth := Value;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetColor1(const Value: TGuiColor);
begin
  FColor1 := ColorByteToFloat(Value);
  FColor1.a := 1.0;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetColor2(const Value: TGuiColor);
begin
  FColor2 := ColorByteToFloat(Value);
  FColor2.a := 1.0;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetColorBorder(const Value: TGuiColor);
begin
  FColorBorder := ColorByteToFloat(Value);
  FColorBorder.a := 1.0;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetColorBorderInside(const Value: TGuiColor);
begin
  FColorBorderInside := ColorByteToFloat(Value);
  FColorBorderInside.a := 1.0;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetFileIco(const Value: string);
begin
  FFileIco := Value;
  LoadTextIco;
  if Visible then
    Draw;
end;

procedure TBlockVisual.SetFileTexture(const Value: string);
begin
  FFileTexture := Value;
  LoadText;
  if Visible then
    Draw;
end;

procedure TBlockVisual.Show;
begin
  inherited;
  if FBody = nil then
  begin

    if FTextureIcoGL = nil then
      LoadTextures;

    FBody := TPicture.Create(TSchemeView(FRenderer).FCanvas, TSchemeView(FRenderer).FProcessorOwner);

    if NowBlockTextureIsSimple then
    begin
      TPicture(FBody).AutoFit := false;
      TPicture(FBody).Wrap := false;
      TPicture(FBody).TrilinearFilter := false;
    end
    else
    begin
      TPicture(FBody).AutoFit := false;
      TPicture(FBody).Wrap := true;
      TPicture(FBody).TrilinearFilter := true;
    end;

    TPicture(FBody).Size := vec2(FSchemeData.Width, FSchemeData.Height);

    if (FTextureIcoGL <> nil) then
    begin
      Pic := TPicture.Create(TSchemeView(FRenderer).FCanvas, FBody);
      Pic.Data.Interactive := false;
      Pic.Texture := FTextureIcoGL;
    end;

    Border := TRectangle.Create(TSchemeView(FRenderer).FCanvas, FBody);
    Border.Fill := false;
    Border.Data.Interactive := false;
    Border.Layer2d := Border.Layer2d + 1;

    if FBorderWidth > 0 then
      CreateBorder2;

    FCaption := TCanvasText.Create(TSchemeView(FRenderer).FCanvas, FBody);
    FCaption.Text := FSchemeData.Caption;
    FCaption.Data.Interactive := false;
    FCaption.ToParentCenter;
    FCaption.Align := TObjectAlign.oaCenter;
    FCaption.Layer2d := FCaption.Layer2d + 2;
    FCaption.Anchors[aLeft] := false;
    FCaption.Anchors[aTop] := false;
    DblClickSbscr := FBody.Data.EventMouseDblClick.CreateObserver(GUIThread, DblClick);
  end;
  if not LinksLoaded then
    LoadLinks;
end;

{ TRegionVisual }

constructor TRegionVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FColor := BS_CL_SILVER;
  FColorInside := BS_CL_SKY;
  FColorBackground := BS_CL_NAVY;
  FBodyWidth := REG_BORDER_WIDTH;
  FBorderWidth := 2;
  FBodyOpacity := 0.3;
  FBorderOpacity := 0.1;
  FBackgrOpacity := 0.1;
end;

procedure TRegionVisual.CreateCaption;
begin
  FCaption := TCanvasText.Create(TSchemeView(FRenderer).FCanvas, FBody);
  FCaption.Data.Interactive := false;
end;

procedure TRegionVisual.AfterConstruction;
begin
  inherited;
  LoadChildren;
end;

procedure TRegionVisual.BeginDrag;
var
  i: int32;
  ch: TSchemeShape;
begin
  inherited;
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    ch := FSchemeData.Children[i];
    if (ch.View = nil) or ISchemeItemVisual(ch.View).Selected or (ISchemeItemVisual(ch.View).AutoDragDrop) then
      continue;
    ISchemeItemVisual(ch.View).BeginDrag;
  end;
end;

procedure TRegionVisual.BeginDragOver;
begin
  inherited;
  if AcceptBorder = nil then
  begin
    AcceptBorder := TRectangle.Create(FCanvas, Border);
    AcceptBorder.Color := BS_CL_GREEN;
    AcceptBorder.Size := Border.Size + 4;
    AcceptBorder.Fill := false;
    AcceptBorder.WidthLine := 2;
    AcceptBorder.Build;
    AcceptBorder.Position2d := vec2(-2.0, -2.0);
  end;
end;

procedure TRegionVisual.Drag;
begin
  DragChilds;
end;

procedure TRegionVisual.Draw;
var
  it: TSchemeShape;
  i: int32;
begin
  TRectangle(FBody).WidthLine := FBodyWidth;
  TRectangle(FBody).Size := vec2(FSchemeData.Width * FRenderer.Scale, FSchemeData.Height * FRenderer.Scale);
  FBody.Data.Opacity := FBodyOpacity;
  FBody.Color := FColorInside;
  inherited;
  Border.Color := FColor;
  Border.Data.Opacity := FBorderOpacity;

  Border.WidthLine := FBorderWidth;
  Border.Size := TRectangle(FBody).Size;
  Border.Build;
  Border.Position2d := vec2(0.0, 0.0);
  Backgr.Size := Border.Size;
  Backgr.Color := FColorBackground;
  Backgr.Data.Opacity := FBackgrOpacity;
  Backgr.Build;
  Backgr.Position2d := vec2(0.0, 0.0);

  if (FCaption = nil) and (FSchemeData.Caption <> '') then
    CreateCaption;

  if FCaption <> nil then
  begin
    FCaption.Text := FSchemeData.Caption;
    FCaption.Position2d := vec2(FBody.Width - FCaption.Width - 5 - FBorderWidth - FBodyWidth, 3 + FBorderWidth + FBodyWidth);
  end;

  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    it := FSchemeData.Children[i];
    if (it.View <> nil) and (ISchemeItemVisual(it.View).Visible) then
      ISchemeItemVisual(it.View).Draw;
  end;
end;

procedure TRegionVisual.Drop(NewParent: TSchemeShape);
var
  i: int32;
  ch: TSchemeShape;
begin
  inherited;
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    ch := FSchemeData.Children[i];
    if (ch.View = nil) or ISchemeItemVisual(ch.View).Selected then
      continue;
    ISchemeItemVisual(ch.View).Drop(ch.Parent);
  end;
end;

procedure TRegionVisual.EndDragOver;
begin
  inherited;
  if AcceptBorder <> nil then
    FreeAndNil(AcceptBorder);
end;

function TRegionVisual.GetColor: TGuiColor;
begin
  Result := ColorFloatToByte(FColor).Value;
end;

function TRegionVisual.GetColorBackground: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBackground).Value;
end;

function TRegionVisual.GetColorInside: TGuiColor;
begin
  Result := ColorFloatToByte(FColorInside).Value;
end;

procedure TRegionVisual.Hide;
begin
  FreeAndNil(Border);
  FreeAndNil(Backgr);
  FreeAndNil(AcceptBorder);
  inherited;
end;

class function TRegionVisual.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeRegion;
end;

procedure TRegionVisual.SetBackgrOpacity(const Value: BSFloat);
begin
  FBackgrOpacity := Value;
end;

procedure TRegionVisual.SetBodyOpacity(const Value: BSFloat);
begin
  FBodyOpacity := Value;
end;

procedure TRegionVisual.SetBodyWidth(const Value: int8);
begin
  FBodyWidth := Value;
end;

procedure TRegionVisual.SetBorderOpacity(const Value: BSFloat);
begin
  FBorderOpacity := Value;
end;

procedure TRegionVisual.SetBorderWidth(const Value: int8);
begin
  FBorderWidth := Value;
end;

procedure TRegionVisual.SetColor(const Value: TGuiColor);
begin
  FColor := ColorByteToFloat(Value);
  FColor.a := 1.0;
end;

procedure TRegionVisual.SetColorBackground(const Value: TGuiColor);
begin
  FColorBackground := ColorByteToFloat(Value);
  FColorBackground.a := 1.0;
end;

procedure TRegionVisual.SetColorInside(const Value: TGuiColor);
begin
  FColorInside := ColorByteToFloat(Value);
  FColorInside.a := 1.0;
end;

procedure TRegionVisual.Show;
begin
  inherited;
  if FBody = nil then
  begin
    FBody := TRectangle.Create(TSchemeView(FRenderer).FCanvas, TSchemeView(FRenderer).FScenarioOwner);
    TRectangle(FBody).Fill := false;
    Border := TRectangle.Create(TSchemeView(FRenderer).FCanvas, FBody);
    Border.Fill := false;
    Border.Data.Interactive := false;
    Backgr := TRectangle.Create(TSchemeView(FRenderer).FCanvas, FBody);
    Backgr.Fill := true;
    Backgr.Data.Interactive := false;
    if FSchemeData.Caption <> '' then
      CreateCaption;
  end;
end;

{ TLinkVisual }

procedure TLinkVisual.CheckDir;
var
  i: int32;
  dir: TLinkDirection;
  l: TSchemeLink;
  p: TSchemeLinkedShape;
begin
  if (Parent = nil) or (TSchemeLink(FSchemeData).ToLink = nil) then
    exit;

  dir := nil;

  if (Parent is TSchemeBlockLink) then
  begin
    // if not (Parent.Parent is TSchemeLinkedShape) then
    // raise Exception.Create('Parent.Parent is not TSchemeLinkedShape!');
    if FRenderer.ViewedBlock <> FSchemeData.ParentLevel then
      p := TSchemeLinkedShape(Parent.Parent)
    else
      p := TSchemeLinkedShape(Parent);
  end
  else
  begin
    // if not (Parent is TSchemeLinkedShape) then
    // raise Exception.Create('Parent is not TSchemeLinkedShape!');
    p := TSchemeLinkedShape(Parent);
  end;

  if p.View = nil then
    exit;

  for i := 0 to TSchemeItemVisualLinked(p.View).Links.Count - 1 do
  begin
    l := TSchemeItemVisualLinked(p.View).Links.Items[i];
    if (l = nil) or (l = FSchemeData) or (l.View = nil) then
      continue;
    if TLinkVisual(l.View).SimilarDirect(TSchemeLink(FSchemeData)) and (TLinkVisual(l.View).FDirection <> nil) then
    begin
      dir := TLinkVisual(l.View).FDirection;
      break;
    end;
  end;
  if dir <> nil then
  begin
    if dir <> FDirection then
    begin
      if FDirection <> nil then
        FDirection.DelLink(Self);
      FDirection := dir;
      FDirection.AddLink(Self);
    end;
  end
  else if FDirection = nil then
  begin
    FDirection := TLinkDirection.Create;
    FDirection.AddLink(Self);
  end;
end;

constructor TLinkVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FColor := BS_CL_ORANGE;
  FColorCaption := FColor;
  FAutoDragDrop := true;
  FLinkWidth := 3;
  FLinkOpacity := 30;
end;

procedure TLinkVisual.CreateCaption;
begin
  if TSchemeLink(FSchemeData).Parent is TSchemeBlockLinkInput then
    exit;
  if FCaption <> nil then
    raise Exception.Create('FCaption <> nil');
  FCaption := TCanvasText.Create(FCanvas, TSchemeView(FRenderer).FProcessorOwner);
  FCaption.Text := IntToStr(TSchemeLink(FSchemeData).NumOut);
  FCaption.Data.Interactive := false;
end;

destructor TLinkVisual.Destroy;
begin
  if (FAreaTo <> nil) and (FAreaTo.View <> nil) then
    TSchemeItemVisualLinked(FAreaTo.View).DeleteInput(TSchemeLink(FSchemeData));
  if (FAreaFrom <> nil) and (FAreaFrom.View <> nil) then
    TSchemeItemVisualLinked(FAreaFrom.View).DeleteOutput(TSchemeLink(FSchemeData));
  FreeAndNil(FDirection);
  inherited;
end;

procedure TLinkVisual.CalcIntersectSide;
var
  rect_fr: TRectBSf;
  rect_to: TRectBSf;
  area: TRectBSf;
  delta_pos: TVec2f;
begin

  if not GetArealFrom or not GetArealTo then
    exit;

  rect_fr := FAreaFrom.GetRect;
  rect_to := FAreaTo.GetRect;

  FOverlap := RectOverlap(rect_fr, rect_to);

  delta_pos := vec2(FRenderer.SpaceTree.Root.BB.x_max * 0.5, FRenderer.SpaceTree.Root.BB.y_max * 0.5);

  if Parent = TSchemeLink(FSchemeData).ToLink then
  begin // feedback
    FAlignFrom := TLinkAlign.laBottom;
    FAlignTo := TLinkAlign.laTop;
  end
  else
  begin

    if (FOverlap.Width > 0) and (FOverlap.Height > 0) then
    begin // objects overlap
      FAlignFrom := TLinkAlign.laBottom;
      FAlignTo := TLinkAlign.laTop;
    end
    else if (FOverlap.Width > 0) then
    begin // overlap only on x
      if (FAreaFrom.Center.y < FAreaTo.Center.y) then
      begin
        FAlignFrom := TLinkAlign.laBottom;
        FAlignTo := TLinkAlign.laTop;
      end
      else
      begin
        FAlignFrom := TLinkAlign.laTop;
        FAlignTo := TLinkAlign.laBottom;
      end;
    end
    else if (FOverlap.Height > 0) then
    begin // overlap only on y
      if (FAreaFrom.Center.x < FAreaTo.Center.x) then
      begin
        FAlignFrom := TLinkAlign.laRight;
        FAlignTo := TLinkAlign.laLeft;
      end
      else
      begin
        FAlignFrom := TLinkAlign.laLeft;
        FAlignTo := TLinkAlign.laRight;
      end;
    end
    else // do not overlap
      if (FAreaFrom.Center.y < FAreaTo.Center.y) then
      begin // AreaFrom is above FAreaTo
        if (FAreaFrom.Center.x < FAreaTo.Center.x) then
        begin // AreaFrom is in the left of FAreaTo
          if ((delta_pos.y > FAreaTo.Center.y) and (delta_pos.y > FAreaFrom.Center.y)) then
          begin
            FAlignFrom := TLinkAlign.laRight;
            FAlignTo := TLinkAlign.laTop;
          end
          else if ((delta_pos.x > FAreaTo.Center.x) or (delta_pos.x > FAreaFrom.Center.x)) then
          begin
            FAlignFrom := TLinkAlign.laBottom;
            FAlignTo := TLinkAlign.laLeft;
          end
          else
          begin
            FAlignFrom := TLinkAlign.laRight;
            FAlignTo := TLinkAlign.laTop;
          end;
        end
        else
        begin // AreaFrom is in the right of FAreaTo
          if (((delta_pos.x > FAreaTo.Center.x) and (delta_pos.x > FAreaFrom.Center.x)) or ((delta_pos.y > FAreaTo.Center.y) and (delta_pos.y > FAreaFrom.Center.y))) then
          begin
            FAlignFrom := TLinkAlign.laLeft;
            FAlignTo := TLinkAlign.laTop;
          end
          else
          begin
            FAlignFrom := TLinkAlign.laBottom;
            FAlignTo := TLinkAlign.laRight;
          end;
        end;
      end
      else // AreaFrom is under of FAreaTo
        if (FAreaFrom.Center.x < FAreaTo.Center.x) then
        begin // AreaFrom is in the left of FAreaTo
          if (delta_pos.x < FAreaTo.Center.x) and (delta_pos.x < FAreaFrom.Center.x) and (FAreaFrom.Center.y > delta_pos.y) then
          begin
            FAlignFrom := TLinkAlign.laTop;
            FAlignTo := TLinkAlign.laLeft;
          end
          else
          begin
            FAlignFrom := TLinkAlign.laRight;
            FAlignTo := TLinkAlign.laBottom;
          end;
        end
        else if (delta_pos.x < FAreaFrom.Center.x) or (delta_pos.y < FAreaFrom.Center.y) then
        begin // AreaFrom is in the right of FAreaTo
          FAlignFrom := TLinkAlign.laTop;
          FAlignTo := TLinkAlign.laRight;
        end
        else
        begin // AreaFrom is in the left of FAreaTo
          FAlignFrom := TLinkAlign.laLeft;
          FAlignTo := TLinkAlign.laBottom;
        end;
  end;

  rect_fr.Width := FAreaFrom.Width shr 1;
  rect_fr.Height := FAreaFrom.Height shr 1;
  rect_fr.x := rect_fr.x + rect_fr.Width;
  rect_fr.y := rect_fr.y + rect_fr.Height;
  rect_to.Width := FAreaTo.Width shr 1;
  rect_to.Height := FAreaTo.Height shr 1;
  rect_to.x := rect_to.x + rect_to.Width;
  rect_to.y := rect_to.y + rect_to.Height;

  area := RectUnion(rect_fr, rect_to);
  if not(area.Position = Position) then
    Position := area.Position;
  if (area.Width <> FSchemeData.Width) or (area.Height <> FSchemeData.Height) then
    Resize(round(area.Width), round(area.Height));
end;

function TLinkVisual.GetAreaFrom: TSchemeShape;
begin
  if FAreaFrom = nil then
    GetArealFrom;
  Result := FAreaFrom;
end;

function TLinkVisual.GetArealFrom: boolean;
var
  fr_it: TSchemeShape;
  tmp: TSchemeBlock;
begin

  if Parent is TSchemeBlockLink then
  begin // item from in block
    tmp := Parent.ParentLevel;
    if Parent is TSchemeBlockLinkInput then // inside?
      fr_it := Parent
    else
      // outside
      fr_it := tmp;
  end
  else
  begin
    fr_it := Parent;
  end;

  if (fr_it = nil) or (fr_it.View = nil) then
    exit(false);

  FAreaFrom := fr_it;
  Result := true;
end;

function TLinkVisual.GetArealTo: boolean;
var
  it: TSchemeShape;
  tmp: TSchemeBlock;
begin

  if TSchemeLink(FSchemeData).ToLink is TSchemeBlockLink then
  begin // item TO in block
    tmp := TSchemeLink(FSchemeData).ToLink.ParentLevel;
    if TSchemeLink(FSchemeData).ToLink is TSchemeBlockLinkInput then
      it := tmp
    else
      it := TSchemeLink(FSchemeData).ToLink;
  end
  else
    it := TSchemeLink(FSchemeData).ToLink;

  if (it = nil) then
    exit(false);

  if FAreaTo = it then
    exit(true);

  FAreaTo := it;
  Result := true;
end;

function TLinkVisual.GetAreaTo: TSchemeShape;
begin
  if FAreaTo = nil then
    GetArealTo;
  Result := FAreaTo;
end;

function TLinkVisual.GetColor: TGuiColor;
begin
  Result := ColorFloatToByte(FColor).Value;
end;

procedure TLinkVisual.Draw;
const
  FB_INDENT = 20.0;
var
  d: TVec2f;
  last_p: TVec2f;
  pos_on_parent: TVec2f;
  half_thick: BSFloat;

  procedure AddPoint(const p: TVec2f);
  var
    c: TCircle;
  begin
    c := FPath.AddPoint(p * FRenderer.Scale);

    if c <> nil then
    begin
      c.Data.SelectResolve := false;
    end;

    FShadow.AddPoint(p * FRenderer.Scale);
  end;

begin

  CheckDir;

  if Selected then
    FPath.Color := BS_CL_RED
  else
    FPath.Color := FColor;

  FPath.Data.Opacity := FLinkOpacity * 0.01;
  FPath.WidthLine := FLinkWidth * FRenderer.Scale;
  Arrow.Color := FPath.Color;
  Arrow.Data.Opacity := FLinkOpacity * 0.01;
  if (FCaption = nil) and (TSchemeLink(FSchemeData).NumOut >= 0) and (FSchemeData.Caption <> '') then
    CreateCaption;

  if FCaption <> nil then
    FCaption.Color := FPath.Color;

  half_thick := (FLinkWidth * 0.5);
  if half_thick < 1 then
    half_thick := 1;

  if (AreaFrom = nil) or (AreaTo = nil) or (FAreaFrom.View = nil) or (FAreaTo.View = nil) then
    exit;

  FPath.Clear;
  FShadow.Clear;

  case AlignFrom of
    laLeft, laRight: pos_on_parent := vec2(PositionOnParent.x, PositionOnParent.y - half_thick);
    laTop, laBottom: pos_on_parent := vec2(PositionOnParent.x - half_thick, PositionOnParent.y);
  end;

  AddPoint(pos_on_parent{%H-});

  case AlignTo of
    laLeft: begin
        last_p := vec2(PositionOnToLink.x - 13, PositionOnToLink.y - half_thick);
        Arrow.A := vec2(last_p.x, PositionOnToLink.y - FLinkWidth - half_thick) * FRenderer.Scale;
        Arrow.B := vec2(PositionOnToLink.x + 1, PositionOnToLink.y) * FRenderer.Scale;
        Arrow.C := vec2(last_p.x, PositionOnToLink.y + FLinkWidth + half_thick) * FRenderer.Scale;
    end;
    laTop: begin
        last_p := vec2(PositionOnToLink.x - half_thick, PositionOnToLink.y - 13);
        Arrow.A := vec2(PositionOnToLink.x - FLinkWidth - half_thick, last_p.y) * FRenderer.Scale;
        Arrow.B := vec2(PositionOnToLink.x, PositionOnToLink.y + 1) * FRenderer.Scale;
        Arrow.C := vec2(PositionOnToLink.x + FLinkWidth + half_thick, last_p.y) * FRenderer.Scale;
    end;
    laRight: begin
        last_p := vec2(PositionOnToLink.x + 13, PositionOnToLink.y - half_thick);
        Arrow.A := vec2(last_p.x, PositionOnToLink.y - FLinkWidth - half_thick) * FRenderer.Scale;
        Arrow.B := vec2(PositionOnToLink.x - 1, PositionOnToLink.y) * FRenderer.Scale;
        Arrow.C := vec2(last_p.x, PositionOnToLink.y + FLinkWidth + half_thick) * FRenderer.Scale;
    end;
    laBottom: begin
        last_p := vec2(PositionOnToLink.x - half_thick, PositionOnToLink.y + 13);
        Arrow.A := vec2(PositionOnToLink.x - FLinkWidth - half_thick, last_p.y) * FRenderer.Scale;
        Arrow.B := vec2(PositionOnToLink.x, PositionOnToLink.y - 1) * FRenderer.Scale;
        Arrow.C := vec2(PositionOnToLink.x + FLinkWidth + half_thick, last_p.y) * FRenderer.Scale;
    end;
  end;

  if FAreaFrom = FAreaTo then
  begin // feedback
    FPath.InterpolateSpline := TInterpolateSpline.isNone;
    FShadow.InterpolateSpline := TInterpolateSpline.isNone;
    AddPoint(vec2(PositionOnParent.x, PositionOnParent.y + FB_INDENT));
    AddPoint(vec2(FAreaFrom.Left - FB_INDENT, PositionOnParent.y + FB_INDENT));
    AddPoint(vec2(FAreaFrom.Left - FB_INDENT, FAreaFrom.Top - FB_INDENT));
    AddPoint(vec2(PositionOnToLink.x, FAreaFrom.Top - FB_INDENT));
    if FCaption <> nil then
      FCaption.Position2d := vec2(PositionOnParent.x - (PositionOnParent.x - FAreaFrom.Left + FB_INDENT) * 0.5 - FCaption.Width * 0.5 - half_thick,
        FAreaFrom.Top + FAreaFrom.Height + FB_INDENT - FCaption.Height - 5) * FRenderer.Scale;
  end
  else if (PositionOnToLink.x = PositionOnParent.x) or (PositionOnToLink.y = PositionOnParent.y) then
  begin
    FPath.InterpolateSpline := TInterpolateSpline.isNone;
    FShadow.InterpolateSpline := TInterpolateSpline.isNone;
    if FCaption <> nil then
    begin
      if (PositionOnToLink.x = PositionOnParent.x) then
        FCaption.Position2d := (PositionOnParent + (PositionOnToLink - PositionOnParent) * 0.5) * FRenderer.Scale - vec2(FCaption.Width + 3 + half_thick, FCaption.Height)
      else
        FCaption.Position2d := (PositionOnParent + (PositionOnToLink - PositionOnParent) * 0.5) * FRenderer.Scale - vec2(0, FCaption.Height + 3 + half_thick);
    end;
  end
  else if FAsSpline then
  begin
    FPath.InterpolateSpline := TInterpolateSpline.isBezier;
    FShadow.InterpolateSpline := TInterpolateSpline.isBezier;
    AddPoint(vec2(PositionOnParent.x, PositionOnToLink.y));
    AddPoint(vec2(PositionOnToLink.x, PositionOnParent.y));
    if FCaption <> nil then
      FCaption.Position2d := (PositionOnParent + (PositionOnParent - PositionOnToLink) * 0.1666) * FRenderer.Scale - vec2(0, FCaption.Height + 3 + half_thick);
  end
  else
  begin
    FPath.InterpolateSpline := TInterpolateSpline.isNone;
    FShadow.InterpolateSpline := TInterpolateSpline.isNone;
    d := last_p - pos_on_parent;
    d := vec2(d.x * 0.5, d.y * 0.5);

    if AlignTo in [laLeft] then
      last_p.x := last_p.x + half_thick
    else
    if AlignTo in [laRight] then
    begin
      if AlignFrom = laBottom then
      begin
        //last_p.x := last_p.x - half_thick;
        last_p.y := last_p.y + half_thick;
      end;
    end else
    if AlignTo in [laBottom] then
    begin
      //last_p.y := last_p.y + half_thick;
      last_p.x := last_p.x + half_thick;
    end else
    if AlignTo in [laTop] then
    begin
      last_p.y := last_p.y - half_thick;
      if AlignFrom = laRight then
        last_p.x := last_p.x + half_thick;
    end;

    if AlignFrom in [laLeft, laRight] then
    begin
      if FCaption <> nil then
        FCaption.Position2d := (pos_on_parent + vec2(d.x, 0.0)) * FRenderer.Scale - vec2(0, FCaption.Height + FRenderer.Scale*(3 + half_thick));
      //last_p.x := last_p.x + half_thick;
      AddPoint(vec2(last_p.x, pos_on_parent.y));
    end
    else
    begin
      if FCaption <> nil then
        FCaption.Position2d := (pos_on_parent + vec2(0.0, d.y)) * FRenderer.Scale - vec2(FCaption.Width + FRenderer.Scale*(3 + half_thick), 0);
      AddPoint(vec2(pos_on_parent.x, last_p.y));
    end;
  end;

  AddPoint(last_p{%H-});

  { for the body separately are adding an area for draw of an arrow }
  FShadow.AddPoint(PositionOnToLink * FRenderer.Scale);
  Arrow.Build;

  FPath.Build;
  inherited;
  { !!! FShadow is not build, so it is build in ancestor as FBody }
  FShadow.Position2d := -vec2(FShadow.Width - FPath.Width, FShadow.Height - FPath.Height) * 0.5 + (PositionOnToLink - last_p) * 0.5;
  SetCaptionsPos;
end;

function TLinkVisual.GetPosition: TVec2i;
begin
  Result := FSchemeData.Position;
end;

procedure TLinkVisual.Hide;
begin
  inherited;
  FShadow := nil;
  FreeAndNil(CaptionFrom);
  FreeAndNil(CaptionTo);
  FreeAndNil(FPath);
  FreeAndNil(Arrow);
end;

class function TLinkVisual.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeLink;
end;

procedure TLinkVisual.SetAsSpline(const Value: boolean);
begin
  FAsSpline := Value;
  if Visible then
    Draw;
end;

procedure TLinkVisual.SetCaptionsPos;
begin
  if CaptionFrom <> nil then
    case AlignFrom of
      laLeft:
        CaptionFrom.Position2d := vec2(PositionOnParent.x * FRenderer.Scale - CaptionFrom.Width - 3, PositionOnParent.y * FRenderer.Scale - CaptionFrom.Height - 3);
      laRight:
        CaptionFrom.Position2d := vec2(PositionOnParent.x * FRenderer.Scale, PositionOnParent.y * FRenderer.Scale - CaptionFrom.Height - 3);
      laTop:
        CaptionFrom.Position2d := vec2(PositionOnParent.x * FRenderer.Scale + 3, PositionOnParent.y * FRenderer.Scale - CaptionFrom.Height - 3);
      laBottom:
        CaptionFrom.Position2d := vec2(PositionOnParent.x * FRenderer.Scale + 3, PositionOnParent.y * FRenderer.Scale + 3);
    end;
  if CaptionTo <> nil then
    case AlignTo of
      laLeft:
        CaptionTo.Position2d := vec2(PositionOnToLink.x * FRenderer.Scale - CaptionTo.Width - 3, PositionOnToLink.y * FRenderer.Scale + 3);
      laRight:
        CaptionTo.Position2d := vec2(PositionOnToLink.x * FRenderer.Scale, PositionOnToLink.y * FRenderer.Scale + 3);
      laTop:
        CaptionTo.Position2d := vec2(PositionOnToLink.x * FRenderer.Scale + 3, PositionOnToLink.y * FRenderer.Scale - CaptionTo.Height - 3);
      laBottom:
        CaptionTo.Position2d := vec2(PositionOnToLink.x * FRenderer.Scale + 3, PositionOnToLink.y * FRenderer.Scale + 3);
    end;
end;

procedure TLinkVisual.SetColor(const Value: TGuiColor);
begin
  FColor := ColorByteToFloat(Value);
  FColor.a := 1.0;
end;

procedure TLinkVisual.SetLinkOpacity(const Value: int8);
begin
  FLinkOpacity := Value;
  if Visible then
    Draw;
end;

procedure TLinkVisual.SetLinkWidth(const Value: int8);
begin
  FLinkWidth := Value;
  if Visible then
    Draw;
end;

procedure TLinkVisual.SetParent(const Value: TSchemeShape);
begin
  inherited;
  CheckDir;
end;

procedure TLinkVisual.SetSelected(const Value: boolean);
begin
  inherited;

  if Assigned(FPath) then
  begin
    if Assigned(FCaption) then
      FCaption.Color := FColorCaption;
    if Value then
      FPath.Color := BS_CL_RED
    else
      FPath.Color := FColor;
    FPath.ColorPoints := FPath.Color;
    Arrow.Color := FPath.Color;
  end;

  if Value then
    ShowCaptions
  else
  begin
    FreeAndNil(CaptionFrom);
    FreeAndNil(CaptionTo);
  end;
end;

procedure TLinkVisual.Show;
begin
  inherited;
  if FPath = nil then
  begin
    FPath := TPath.Create(FCanvas, TSchemeView(FRenderer).FProcessorOwner);
    FPath.Data.Interactive := false;

    FPath.ColorPoints := FPath.Color;
    FPath.Layer2d := 5;
    FPath.InterpolateSpline := isNone;

    { wide transparent link - need for accept an event of a select }
    FShadow := TPath.Create(FCanvas, FPath);
    FShadow.WidthLine := 10;
    FShadow.RadiusPoints := 3;
    FShadow.Data.Opacity := 0.0;
    FShadow.Data.DragResolve := false;
    FShadow.Color := BS_CL_SKY;
    FShadow.InterpolateSpline := isNone;
    FBody := FShadow;
    FBody.Data.TagPtr := Self;
    Arrow := TTriangle.Create(FCanvas, TSchemeView(FRenderer).FProcessorOwner);
    Arrow.Data.Interactive := false;
    Arrow.Fill := true;
    Arrow.Data.Opacity := FPath.Data.Opacity;
    if TSchemeLink(FSchemeData).NumOut >= 0 then
      CreateCaption;
    if Selected then
      ShowCaptions;
  end;
end;

procedure TLinkVisual.ShowCaptions;
begin

  if TSchemeLink(FSchemeData).Parent is TSchemeBlockLinkOutput then
  begin
    CaptionFrom := TCanvasText.Create(TSchemeView(FRenderer).FCanvas, TSchemeView(FRenderer).FScenarioOwner);
    CaptionFrom.Data.Interactive := false;
    CaptionFrom.Layer2d := CaptionFrom.Layer2d + 3;
    CaptionFrom.Color := BS_CL_RED;
    CaptionFrom.Text := TSchemeLink(FSchemeData).Parent.Caption;
  end;

  if TSchemeLink(FSchemeData).ToLink is TSchemeBlockLinkInput then
  begin
    CaptionTo := TCanvasText.Create(TSchemeView(FRenderer).FCanvas, TSchemeView(FRenderer).FScenarioOwner);
    CaptionTo.Data.Interactive := false;
    CaptionTo.Layer2d := CaptionTo.Layer2d + 3;
    CaptionTo.Color := BS_CL_RED;
    CaptionTo.Text := TSchemeLink(FSchemeData).ToLink.Caption;
  end;
  SetCaptionsPos;
end;

function TLinkVisual.SimilarDirect(Link: TSchemeLink): boolean;
var
  self_fr, self_to, l_fr, l_to: TSchemeShape;
begin
  if Link = FSchemeData then
    exit(false);

  if Parent is TSchemeBlockLink then
  begin
    if Parent is TSchemeBlockLinkInput then
      self_fr := Parent
    else
      self_fr := Parent.ParentLevel;
  end
  else
    self_fr := Parent;

  if TSchemeLink(FSchemeData).ToLink is TSchemeBlockLink then
  begin
    if TSchemeLink(FSchemeData).ToLink is TSchemeBlockLinkInput then
      self_to := TSchemeLink(FSchemeData).ToLink.ParentLevel
    else
      self_to := TSchemeLink(FSchemeData).ToLink;
  end
  else
    self_to := TSchemeLink(FSchemeData).ToLink;

  if Link.Parent is TSchemeBlockLink then
  begin
    if Link.Parent is TSchemeBlockLinkInput then
      l_fr := Link.Parent
    else
      l_fr := Link.Parent.ParentLevel;
  end
  else
    l_fr := Link.Parent;

  if Link.ToLink is TSchemeBlockLink then
  begin
    if Link.ToLink is TSchemeBlockLinkInput then
      l_to := Link.ToLink.Parent
    else
      l_to := Link.ToLink;
  end
  else
    l_to := Link.ToLink;

  Result := ((self_fr = l_fr) and (self_to = l_to)) or ((self_fr = l_to) and (self_to = l_fr));
end;

{ TSchemeView }

procedure TSchemeView.BeginDragItems;
begin
  inherited;
end;

procedure TSchemeView.CheckBoundary;
begin
  FScrollBox.CheckScrollingArea;
  if DrawGrid then
    DoDrawGrid;
  inherited;
end;

function TSchemeView.ClientSize: TVec2f;
begin
  Result := vec2(FScrollBox.ClipObject.Width, FScrollBox.ClipObject.Height);
end;

constructor TSchemeView.Create(ARenderer: TBlackSharkRenderer);
begin
  FScrollBox := TBScrollBox.Create(ARenderer);
  inherited Create(FScrollBox.SpaceTree);
{$IFDEF debug_scheme}
  _SrvBillboard := TBlackSharkCanvas.Create(AScrollBox.Scene);
  _SrvBillboard.CreateEmptyCanvasObject;
  _RectBillb := TRectangle.Create(_SrvBillboard, nil);
  _RectBillb.Data.ModalLevel := AScrollBox.Root.Data.ModalLevel;
  _RectBillb.Position2d := vec2(AScrollBox.Scene.ScreenSize.x - 300.0, 100.0);
  _RectBillb.Size := vec2(250, 180);
  _RectBillb.Color := BS_CL_ORANGE;
  _RectBillb.Build;
  _DraggedData := TCanvasText.Create(_SrvBillboard, _RectBillb);
  _DraggedData.Position2d := vec2(10, 10);
  _DraggedData.Text := 'Drag: 0';
  _DraggedData.Data.Interactive := false;
  _BSObjects := TCanvasText.Create(_SrvBillboard, _RectBillb);
  _BSObjects.Position2d := vec2(10, 30);
  _BSObjects.Text := 'Objects: 0';
  _BSObjects.Data.Interactive := false;
{$ENDIF}
  FCanvas := FScrollBox.Canvas;
  FCanvas.Renderer.KeyMultiSelectAllows := $10; // vkShift
  FCanvas.Font.SizeInPixels := RASTER_FONT_SIZE_DEFAULT;
  Selector := TBlackSharkSelectorInstances.Create(FScrollBox.Canvas, FScrollBox.ClipObject);
  Selector.OnSelectInstance := OnSelectInstance;
  Selector.OnUnSelectInstance := UnSelectInstance;

  SelectorsBB := TListVec<TBlackSharkSelectorBB>.Create;
  SelectorsUsed := TBinTreeTemplate<TSchemeItemVisual, TBlackSharkSelectorBB>.Create(@PtrCmp);
  ObsrvMDownOnSceen := ARenderer.EventMouseDown.CreateObserver(GUIThread, MouseDownOnScreen);
  // ObsrvMDragDrop := AScene.EventEndDrag.CreateObserver(GUIThread, EndDrag);
  ObsrvMUpOnSceen := ARenderer.EventMouseUp.CreateObserver(GUIThread, OnMouseUp);
  ObsrvMDownMissOnSceen := ARenderer.EventMouseDblClickInEmptySite.CreateObserver(GUIThread, DblClickMiss);
  ObsrvMMove := ARenderer.EventMouseMove.CreateObserver(GUIThread, OnMouseMove);
  FScrollBox.ClipObject.Data.Interactive := false;
  SmallGrid := TGrid.Create(FScrollBox.Canvas, FScrollBox.OwnerInstances);
  SmallGrid.Closed := true;
  SmallGrid.VertLines := true;
  SmallGrid.HorLines := true;
  SmallGrid.Data.Interactive := false;
  Grid := TGrid.Create(FScrollBox.Canvas, SmallGrid);
  Grid.Closed := true;
  Grid.VertLines := true;
  Grid.HorLines := true;
  Grid.Data.Interactive := false;
  FScenarioOwner := FScrollBox.Canvas.CreateEmptyCanvasObject(FScrollBox.OwnerInstances);
  FScenarioOwner.Layer2d := 2;
  FScenarioOwner.Position2d := vec2(0.0, 0.0);
  FProcessorOwner := FScrollBox.Canvas.CreateEmptyCanvasObject(FScenarioOwner);
  FProcessorOwner.Layer2d := 6;
  FProcessorOwner.Position2d := vec2(0.0, 0.0);
  if Assigned(FScrollBox.ClipObject) then
    FScrollBox.ClipObject.Data.Opacity := 1.0;
  FScrollBox.Color := ColorFloatToByte(vec4(0.1764, 0.1764, 0.1764, 1.0)).Value;
  FScrollBox.OnChangePosition := OnChangePosition;
  if DrawGrid then
  begin
    FScrollBox.ScrollBarHor.Step := GridStep;
    FScrollBox.ScrollBarVert.Step := GridStep;
    DoDrawGrid;
  end;
end;

procedure TSchemeView.DblClickMiss(const Data: BMouseData);
begin
  if (Data.BaseHeader.Instance = nil) and (Selected = nil) then
  begin
    DblClick(nil);
  end;
end;

destructor TSchemeView.Destroy;
var
  i: int32;
begin
  ObsrvMDownOnSceen := nil;
  // ObsrvMDragDrop := nil;
  ObsrvMUpOnSceen := nil;
  ObsrvMDownMissOnSceen := nil;
  ObsrvMMove := nil;
  Selector.ResetSelected;
  for i := 0 to SelectorsBB.Count - 1 do
    SelectorsBB.Items[i].Free;
  inherited;
  Selector.Free;
  SelectorsBB.Free;
  SelectorsUsed.Free;
  Grid.Free;
  FScrollBox.Free;
{$IFDEF debug_scheme}
  _SrvBillboard.Free;
{$ENDIF}
end;

procedure TSchemeView.DoDrawGrid;
var
  s: TVec2i;
begin
  SmallGrid.Data.Color := FGridColor;
  SmallGrid.Data.Opacity := FGridOpacity * 0.01;
  Grid.Data.Color := FGridColor2;
  Grid.Data.Opacity := FGridOpacity * 0.01;
  SmallGrid.StepX := GridStep * Scale;
  SmallGrid.StepY := GridStep * Scale;
  Grid.StepX := SmallGrid.StepX * 10;
  Grid.StepY := SmallGrid.StepY * 10;
  s := vec2(FScrollBox.ScrolledArea.x + FScrollBox.Width, FScrollBox.ScrolledArea.y + FScrollBox.Height);
  if s.x < FScrollBox.Width then
    s.x := round(FScrollBox.Width);
  if s.y < FScrollBox.Height then
    s.y := round(FScrollBox.Height);
  SmallGrid.Size := s;
  Grid.Size := s;
  SmallGrid.Build;
  Grid.Build;
  Grid.Position2d := vec2(0.0, 0.0);
  FScenarioOwner.Position2d := vec2(0.0, 0.0);
end;

function TSchemeView.DoSelect(Item: TSchemeItemVisual): TBlackSharkSelectorBB;
begin
  if Assigned(Item.Body) then
  begin

    if not(Item is TLinkVisual) then
    begin
      Result := GetSelector;
      Result.SelectItem := FCanvas.Renderer.SceneInstanceToRenderInstance(Item.Body.Data.BaseInstance);
      Item.Selector := Result;
      SelectorsUsed.Add(Item, Result);
    end
    else
      Result := nil;

    if not Item.SelectedBySelector then
    begin
      Item.SelectedBySelector := true;
      Selector.Select(FCanvas.Renderer.SceneInstanceToRenderInstance(Item.Body.Data.BaseInstance), Result);
      if Item.IsDrag and not Item.FBody.Data.IsDrag and not(Item.AutoDragDrop) then
      begin
        Item.FBody.Data.IsDrag := true;
      end;
    end;
  end
  else
    Result := nil;
{$IFDEF debug_scheme}
  _BSObjects.Text := 'Objects: ' + IntToStr(g_CountObjects);
{$ENDIF}
end;

procedure TSchemeView.DoUnselect(Item: TSchemeItemVisual);
begin
  if Item.SelectedBySelector then
  begin
    Item.SelectedBySelector := false;
    Selector.UnSelect(true, FCanvas.renderer.SceneInstanceToRenderInstance(Item.FBody.Data.BaseInstance));
  end;
  if Assigned(Item.Selector) then
  begin
    SelectorsUsed.Remove(Item);
    Item.Selector.SelectItem := nil;
    SelectorsBB.Add(Item.Selector);
    Item.Selector := nil;
  end;
{$IFDEF debug_scheme}
  _BSObjects.Text := 'Objects: ' + IntToStr(g_CountObjects);
{$ENDIF}
end;

procedure TSchemeView.DragDropItem(Item: ISchemeItemVisual);
begin
  inherited;
end;

procedure TSchemeView.EndDragItems;
begin
  inherited;
end;

function TSchemeView.GetColorBackground: TGuiColor;
begin
  Result := FScrollBox.Color;
end;

function TSchemeView.GetColorScrollBar: TColor4f;
begin
  Result := ColorByteToFloat(FScrollBox.ScrollBarHor.Color);
end;

function TSchemeView.GetPosition: TVec2f;
begin
  Result := FScrollBox.Position2d;
end;

function TSchemeView.GetSelector: TBlackSharkSelectorBB;
begin
  if SelectorsBB.Count > 0 then
    Result := SelectorsBB.Pop
  else
  begin
    Result := TBlackSharkSelectorBB.Create(FScrollBox.Canvas);
    Result.ShowLines := false;
    Result.OnResizeGraphicObjectInstance := OnResizeInstance;
    Result.OnDropResize := OnDropResize;
    Result.OnBeginResize := OnBeginResize;
  end;
end;

procedure TSchemeView.MouseDownOnScreen(const Data: BMouseData);
var
  d: BSFloat;
begin
  if FScrollBox.canvas.renderer.SelectedItemsCount = 0 then
    ResetSelection;
  if FCanvas.Renderer.HitTestInstance(Data.X, Data.Y, FScrollBox.ClipObject.Data.BaseInstance, d) then
  begin
    if not FScrollBox.Focused then
      FScrollBox.Focused := true;
  end else
  if FScrollBox.Focused then
    FScrollBox.Focused := false;
end;

procedure TSchemeView.OnBeginResize(Instance: PGraphicInstance);
var
  Item: TSchemeItemVisual;
begin
  Item := Instance.Owner.TagPtr;
  if Item <> nil then
    BeginResize(Item);
end;

procedure TSchemeView.OnChangePosition(Sender: TBScrolledWindowCustom; const NewPosition: TVec2d);
begin
  DoChangePosition(NewPosition);
end;

procedure TSchemeView.OnChangeSelectItemDo(Item: ISchemeItemVisual);
begin
  inherited;
  if (Item.Selected) and not(FCanvas.renderer.Keyboard[FCanvas.renderer.KeyMultiSelectAllows]) and Assigned(FCanvas.renderer.MouseDownInstance) then
    ResetSelection(Item);
end;

procedure TSchemeView.OnDropResize(Instance: PGraphicInstance);
var
  Item: TSchemeItemVisual;
begin
  Item := Instance.Owner.TagPtr;
  if Item <> nil then
    EndResize(Item);
end;

procedure TSchemeView.OnHideData(Node: PNodeSpaceTree);
begin
  if ISchemeItemVisual(Node.BB.TagPtr).Selected then
    DoUnselect(TSchemeItemVisual(Node.BB.TagPtr));
  inherited;
{$IFDEF debug_scheme}
  _BSObjects.Text := 'Objects: ' + IntToStr(g_CountObjects);
{$ENDIF}
end;

procedure TSchemeView.OnMouseMove(const Data: BMouseData);
var
  r: TRectBSf;
begin
  r.Width := FScrollBox.ClipObject.Width;
  r.Height := FScrollBox.ClipObject.Height;
  r.Position := FScrollBox.Position2d;
  if RectContains(r, vec2(Data.x, Data.y)) then
    MouseMove(Data.x - round(r.Position.x), Data.y - round(r.Position.y));
end;

procedure TSchemeView.OnMouseUp(const Data: BMouseData);
begin
  MouseUp(Data.x, Data.y);
end;

procedure TSchemeView.OnResizeInstance(Instance: PGraphicInstance; const Scale: TVec3f; const Point: TBBLimitPoint);
begin
  if Instance.Owner.TagPtr = nil then
    exit;
  OnResize(ISchemeItemVisual(Instance.Owner.TagPtr), Scale, Point);
end;

function TSchemeView.OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
begin
  Result := nil;
  if (Instance.Instance.Owner.TagPtr = nil) then
    exit;
  TSchemeItemVisual(Instance.Instance.Owner.TagPtr).SelectedBySelector := true;
  TSchemeItemVisual(Instance.Instance.Owner.TagPtr).Selected := true;
end;

procedure TSchemeView.OnShowData(Node: PNodeSpaceTree);
begin
  inherited;
{$IFDEF debug_scheme}
  _BSObjects.Text := 'Objects: ' + IntToStr(g_CountObjects);
{$ENDIF}
end;

procedure TSchemeView.Resize(Width, Height: BSFloat);
begin
  FScrollBox.Resize(Width, Height);
  if DrawGrid then
    DoDrawGrid;
end;

procedure TSchemeView.SelectFontSize;
begin
  if Scale < 0.25 then
    FCanvas.Font.SizeInPixels := round(RASTER_FONT_SIZE_DEFAULT * 0.5)
  else
  if Scale < 0.6 then
    FCanvas.Font.SizeInPixels := round(RASTER_FONT_SIZE_DEFAULT * 0.75)
  else
  if Scale < 1.0 then
    FCanvas.Font.SizeInPixels := RASTER_FONT_SIZE_DEFAULT
  else
    FCanvas.Font.SizeInPixels := round(RASTER_FONT_SIZE_DEFAULT * Scale);
end;

procedure TSchemeView.SetBanSelect(const Value: boolean);
begin
  inherited;
  Selector.BanSelect := Value;
end;

procedure TSchemeView.SetColorBackground(const Value: TGuiColor);
begin
  FScrollBox.Color := Value;
end;

procedure TSchemeView.SetColorGrid(const Value: TGuiColor);
begin
  inherited;
  if DrawGrid then
    DoDrawGrid;
end;

procedure TSchemeView.SetColorGrid2(const Value: TGuiColor);
begin
  inherited;
  if DrawGrid then
    DoDrawGrid;
end;

procedure TSchemeView.SetColorScrollBar(const Value: TColor4f);
begin
  inherited;
  FScrollBox.ScrollBarHor.Color := ColorFloatToByte(Value).Value;
  FScrollBox.ScrollBarVert.Color := ColorFloatToByte(Value).Value;
end;

procedure TSchemeView.SetDrawGrid(const Value: boolean);
begin
  inherited;
  if DrawGrid then
  begin
    DoDrawGrid;
    SmallGrid.Data.Hidden := false;
    Grid.Data.Hidden := false;
    FScrollBox.ScrollBarHor.Step := GridStep;
    FScrollBox.ScrollBarVert.Step := GridStep;
  end
  else if Grid <> nil then
  begin
    FScrollBox.ScrollBarHor.Step := 1;
    FScrollBox.ScrollBarVert.Step := 1;
    FScenarioOwner.Parent := FScrollBox.OwnerInstances;
    Grid.Data.Hidden := true;
    SmallGrid.Data.Hidden := true;
  end;
end;

procedure TSchemeView.SetEnabled(const Value: boolean);
begin
  inherited;
  Selector.BanSelect := not Value;
end;

procedure TSchemeView.SetGridOpacity(const Value: int8);
begin
  inherited;
  if DrawGrid then
    DoDrawGrid;
end;

procedure TSchemeView.SetGridStep(const Value: int32);
begin
  inherited;
  if DrawGrid then
    DoDrawGrid;
end;

procedure TSchemeView.SetPosition(const Value: TVec2f);
begin
  FScrollBox.Position2d := Value;
end;

procedure TSchemeView.SetScale(const Value: BSFloat);
begin
  inherited;

end;

procedure TSchemeView.SetViewedBlock(const Value: TSchemeBlock);
begin
  inherited;

end;

procedure TSchemeView.SetViewPortPosition(const Value: TVec2f);
begin
  FScrollBox.Position := vec2d(Value.x, Value.y);
end;

procedure TSchemeView.UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
begin
  if (Instance.Instance.Owner.TagPtr = nil) then
    exit;
  TSchemeItemVisual(Instance.Instance.Owner.TagPtr).SelectedBySelector := false;
  TSchemeItemVisual(Instance.Instance.Owner.TagPtr).Selected := false;
end;


// procedure TSchemeView._DecCountDrag;
// begin
// dec(_CountDraggedData);
// if _CountDraggedData = 0 then
// EndDragItems;
// {$ifdef debug_scheme}
// _DraggedData.Text := 'Drag: ' + IntToStr(_CountDraggedData);
// {$endif}
// end;
//
// procedure TSchemeView._IncCountDrag;
// begin
// if _CountDraggedData = 0 then
// BeginDragItems;
// inc(_CountDraggedData);
//
// {$ifdef debug_scheme}
// _DraggedData.Text := 'Drag: ' + IntToStr(_CountDraggedData);
// {$endif}
// end;
//

function TSchemeView.GetViewPortPosition: TVec2f;
begin
  Result := FScrollBox.Position;
end;

{ TSchemeItemVisual }

procedure TSchemeItemVisual.BeginDrag;
begin
  { it is can happen (IsDrag = true) if it was showed twice the object when its is dragged }
  if IsDrag then
    exit;
  inherited;

  // TSchemeView(FRenderer)._IncCountDrag;
end;

procedure TSchemeItemVisual.DblClick(const Data: BMouseData);
begin
  if (Data.BaseHeader.Instance <> nil) then
  begin
    FRenderer.DblClick(ISchemeItemVisual(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.TagPtr));
  end;
end;

procedure TSchemeItemVisual.AfterShow;
begin
  if OnDropObsrv = nil then
  begin
    OnDropObsrv := FBody.Data.EventDrop.CreateObserver(GUIThread, OnDropScenItem);
    OnDragObsrv := FBody.Data.EventDrag.CreateObserver(GUIThread, OnDragScenItem);
    OnBeginDragObsrv := FBody.Data.EventBeginDrag.CreateObserver(GUIThread, OnBeginDrag);
    FBody.Data.TagPtr := Self;
  end;
  if Selected then
  begin
    TSchemeView(FRenderer).DoSelect(Self);
  end;
end;

procedure TSchemeItemVisual.DragByParent(const NewPosition: TVec2f);
begin
  inherited;
  if FBody <> nil then
    FBody.Position2d := NewPosition * FRenderer.Scale
  else
    FRenderer.UpdateInSpaceTree(Self);
end;

procedure TSchemeItemVisual.Draw;
begin
  if FBody = nil then
    exit;
  if Assigned(FCaption) then
    FCaption.Text := FSchemeData.Caption;
  inherited;
  FBody.Build;
  FBody.Position2d := FSchemeData.Position * FRenderer.Scale;
  OnMouseDownObsrv := FBody.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownEvent);
end;

procedure TSchemeItemVisual.Drop(NewParent: TSchemeShape);
begin
  inherited;
  // TSchemeView(FRenderer)._DecCountDrag;
end;

procedure TSchemeItemVisual.OnBeginDrag(const Data: BDragDropData);
begin
  BeginDrag;
end;

procedure TSchemeItemVisual.OnDragScenItem(const Data: BDragDropData);
begin
  FRenderer.DragItem(Self);
end;

procedure TSchemeItemVisual.OnDropScenItem(const Data: BDragDropData);
begin
  FRenderer.DragDropItem(Self);
end;

procedure TSchemeItemVisual.OnMouseDownEvent(const MData: BMouseData);
begin
  OnMouseDown(MData.x, MData.y, MData.ShiftState);
end;

procedure TSchemeItemVisual.SelectColor;
begin

end;

procedure TSchemeItemVisual.SetCaption(const Value: string);
begin
  inherited;
  if FCaption <> nil then
    FCaption.Text := Value;
end;

procedure TSchemeItemVisual.SetColorCaption(const Value: TGuiColor);
begin
  FColorCaption := ColorByteToFloat(Value);
  FColorCaption.a := 1.0;
  if Assigned(FCaption) then
    FCaption.Color := FColorCaption;
end;

procedure TSchemeItemVisual.SetPosition(const Value: TVec2i);
begin
  inherited;
  if FBody <> nil then
    FBody.Position2d := FSchemeData.Position * FRenderer.Scale;
end;

procedure TSchemeItemVisual.SetSelected(const Value: boolean);
begin
  if Selected = Value then
    exit;
  inherited;
  if Selected then
  begin
    // if (Selector = nil) and (FBody <> nil) then // and not (Self is TLinkVisual)
    begin
      { The Selector do not exists, therefor selected of outside (for example,
        when an user drops a new item to scenario) }
      TSchemeView(FRenderer).DoSelect(Self);
    end;
  end
  else
  // if Selector <> nil then
  begin
    // if OnBeginDragHandle <> nil then
    // FBody.Data.EventBeginDrag.UnSubscribe(OnBeginDragHandle);
    { The Selector exists, therefore cancels selection of outside (for example,
      when creates a new scenario) }
    TSchemeView(FRenderer).DoUnselect(Self);
  end;
end;

procedure TSchemeItemVisual.Show;
begin
  inherited;
end;

function TSchemeItemVisual.GetColorCaption: TGuiColor;
begin
  Result := ColorFloatToByte(FColorCaption).Value;
end;

function TSchemeItemVisual.GetPosition: TVec2i;
begin
  if FBody <> nil then
    Result := FBody.Position2d / FRenderer.Scale
  else
    Result := FSchemeData.Position;
end;

procedure TSchemeItemVisual.Hide;
begin
  inherited;
  if FBody <> nil then
  begin
    OnDropObsrv := nil;
    OnDragObsrv := nil;
    OnBeginDragObsrv := nil;
    OnMouseDownObsrv := nil;
    DblClickSbscr := nil;
    FreeAndNil(FCaption);
    FreeAndNil(FBody);
  end;
end;

constructor TSchemeItemVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FCanvas := TSchemeView(ARenderer).Canvas;
end;

{ TBlockPointVisualInput }

procedure TBlockPointVisualInput.AfterConstruction;
begin
  inherited;
  LoadChildren;
end;

constructor TBlockPointVisualInput.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FColorCaption := BS_CL_BLACK;
  FColorBorder := BS_CL_SKY;
  FColor := BS_CL_SILVER;
  FColorBorderInside := BS_CL_BLACK;
end;

class function TBlockPointVisualInput.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeBlockLinkInput;
end;

procedure TBlockPointVisualInput.Show;
begin
  inherited;

end;

{ TBlockPointVisualOutput }

constructor TBlockPointVisualOutput.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  inherited;
  FColorCaption := BS_CL_WHITE;
  FColor := BS_CL_DARK;
  FColorBorder := BS_CL_SILVER;
  FColorBorderInside := BS_CL_WHITE;
end;

class function TBlockPointVisualOutput.PresentedClass: TSchemeShapeClass;
begin
  Result := TSchemeBlockLinkOutput;
end;

{ TBlockPointVisual }

procedure TBlockPointVisual.Draw;
var
  s: TVec2f;
begin
  s.x := FSchemeData.Width * FRenderer.Scale;
  s.y := FSchemeData.Height * FRenderer.Scale;

  TRectangle(FBody).Size := s;
  Border.Size := s;
  Border2.Size := s - 4;

  Border.Color := FColorBorder;
  FBody.Color := FColor;
  Border2.Color := FColorBorderInside;
  FCaption.Color := FColorCaption;

  inherited;
  Border.Build;
  Border.Position2d := vec2(0.0, 0.0);
  Border2.Position2d := vec2(2.0, 2.0);
  Border2.Build;
  FCaption.ToParentCenter;
end;

function TBlockPointVisual.GetColor: TGuiColor;
begin
  Result := ColorFloatToByte(FColor).Value;
end;

function TBlockPointVisual.GetColorBorder: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBorder).Value;
end;

function TBlockPointVisual.GetColorBorderInside: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBorderInside).Value;
end;

procedure TBlockPointVisual.Hide;
begin
  FreeAndNil(Border);
  FreeAndNil(Border2);
  inherited;
end;

procedure TBlockPointVisual.SetColor(const Value: TGuiColor);
begin
  FColor := ColorByteToFloat(Value);
  FColor.a := 1.0;
end;

procedure TBlockPointVisual.SetColorBorder(const Value: TGuiColor);
begin
  FColorBorder := ColorByteToFloat(Value);
  FColorBorder.a := 1.0;
end;

procedure TBlockPointVisual.SetColorBorderInside(const Value: TGuiColor);
begin
  FColorBorderInside := ColorByteToFloat(Value);
  FColorBorderInside.a := 1.0;
end;

procedure TBlockPointVisual.Show;
var
  s: TVec2i;
  need_upd: boolean;
begin
  inherited;
  FBody := TRectangle.Create(FCanvas, TSchemeView(FRenderer).FProcessorOwner);
  TRectangle(FBody).Fill := true;
  Border := TRectangle.Create(FCanvas, FBody);
  Border.Fill := false;
  Border.Data.Interactive := false;
  Border2 := TRectangle.Create(FCanvas, FBody);
  Border2.Fill := false;
  Border2.Data.Interactive := false;
  FCaption := TCanvasText.Create(FCanvas, FBody);
  FCaption.Text := FSchemeData.Caption;
  FCaption.Data.Interactive := false;
  FCaption.ToParentCenter;
  FCaption.Anchors[aLeft] := false;
  FCaption.Anchors[aTop] := false;
  FCaption.Build;

  s.x := FSchemeData.Width;
  s.y := FSchemeData.Height;
  if (FSchemeData.Width < FCaption.Width + 10) then
    s.x := round(FCaption.Width) + 10;

  if FSchemeData.Height < FCaption.Height + 10 then
    s.y := round(FCaption.Height) + 10;

  if FRenderer.DrawGrid then
    s := FRenderer.GetAlignedOnGridSize(s);

  need_upd := false;
  if FSchemeData.Width <> s.x then
  begin
    FSchemeData.Width := s.x;
    need_upd := true;
  end;

  if FSchemeData.Height <> s.y then
  begin
    FSchemeData.Height := s.y;
    need_upd := true;
  end;
  if need_upd then
    FRenderer.UpdateInSpaceTree(Self);
end;

initialization

ISchemeRenderer.RegisterVisualItem(TProcessorVisual);
ISchemeRenderer.RegisterVisualItem(TLinkVisual);
ISchemeRenderer.RegisterVisualItem(TBlockVisual);
ISchemeRenderer.RegisterVisualItem(TBlockPointVisualInput);
ISchemeRenderer.RegisterVisualItem(TBlockPointVisualOutput);
ISchemeRenderer.RegisterVisualItem(TRegionVisual);

end.
