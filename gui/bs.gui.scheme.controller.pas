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

unit bs.gui.scheme.controller;

{ controller of model contains logic for view }

{$I BlackSharkCfg.inc}
{$M+}

interface

uses
    Types
  , Classes
  , bs.basetypes
  , bs.geometry
  , bs.collections
  , bs.gui.base
  , bs.gui.scheme.model
  , bs.gui.themes
  , bs.events
  ;

type

  ISchemeRenderer = class;
  ISchemeItemVisual = class;
  ISchemeItemVisualClass = class of ISchemeItemVisual;
  TListItemDual = TListDual<ISchemeItemVisual>;

  { TODO: history of changes }
  TCodeChange = (ccPosition, ccResize, ccCaption, ccCreate, ccDelete);

  PChangeData = ^TChangeData;

  TChangeData = record
    Shape: TSchemeShape;
    CodeChange: TCodeChange;
    { for group of changes }
    Next: PChangeData;
  end;

  PChangeCaptionData = ^TChangeCaptionData;

  TChangeCaptionData = record
    BaseData: TChangeData;
    OldCaption: string;
  end;

  PChangeSizeData = ^TChangeSizeData;

  TChangeSizeData = record
    BaseData: TChangeData;
    OldSize: TVec2i;
  end;

  PChangePosData = ^TChangePosData;

  TChangePosData = record
    BaseData: TChangeData;
    OldPos: TVec2f;
  end;

  PChangeDelData = ^PChangeData;

  TChangeOutputData = record
    BaseData: TChangeData;
    Link: TSchemeShape;
  end;

  PChangeOutputData = ^TChangeOutputData;

  TSchemeItemVisualEvent = procedure(Item: ISchemeItemVisual) of object;

  { visual wrapper TSchemeShape }

  { ISchemeItemVisual }

  ISchemeItemVisual = class abstract(TGUIProperties)
  private
    { pos in list selected }
    _SelData: TListItemDual.PListItem;
    { pos in list selected but if it is invisible }
    _SelDataNoVis: TListItemDual.PListItem;
    NodeSpaceTree: PNodeSpaceTree;
    FSelected: boolean;
    FVisible: boolean;
    FBeginDragPos: TVec2f;
    FIsDrag: boolean;
    FTag: Pointer;
    function GetParent: TSchemeShape;
    function GetAlignedOnGridSize: TPoint;
    function GetCaption: string;
    function GetParentIsSelected: boolean;
    function GetHeight: int32;
    function GetLeft: int32;
    function GetWidth: int32;
    procedure SetHeight(const Value: int32);
    procedure SetLeft(const Value: int32);
    procedure SetWidth(const Value: int32);
    function GetTop: int32;
    procedure SetTop(const Value: int32);
    function GetUrl: AnsiString;
  protected
    FSchemeData: TSchemeShape;
    FRenderer: ISchemeRenderer;
    FAutoDragDrop: boolean;
    { load view of all children }
    procedure LoadChildren;
    procedure SetSelected(const Value: boolean); virtual;
    procedure SetPosition(const Value: TVec2i); virtual;
    function GetPosition: TVec2i; virtual;
    procedure SetParent(const Value: TSchemeShape); virtual;
    procedure SelectColor; virtual; abstract;
    procedure SetCaption(const Value: string); virtual;
    { invoked for child shapes when a parent drags and its child also is visible }
    procedure DragByParent(const NewPosition: TVec2f); virtual;
    procedure DoDraw;
    procedure DragChilds;
    procedure Show; virtual;
    procedure AfterShow; virtual; abstract;
    procedure Hide; virtual;
    { invoked only for selected items }
    procedure Drag; virtual;
    procedure BeginDragOver; virtual;
    procedure EndDragOver; virtual;
    { change itself or its child }
    procedure OnChange(ChangeData: PChangeData); virtual;
    procedure OnMouseDown(X, Y: BSFloat; ShiftState: TShiftState); virtual;
  public
    constructor Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape); virtual;
    procedure BeforeDestruction; override;
    destructor Destroy; override;
    { wrapper SaveProperties }
    procedure SaveSchemeProperties;
    procedure LoadSchemeProperties;
    class function PresentedClass: TSchemeShapeClass; virtual; abstract;
    procedure Resize(AWidth, AHeight: int32); virtual;
    procedure Draw; virtual;
    procedure BeginDrag; virtual;
    procedure MoveTo(DeltaX, DeltaY: int32);
    procedure OnDblClick; virtual;
    function OneOfParentsIsSelected: boolean;
    procedure UpdatePosChilds;
    procedure BeginResize; virtual;
    procedure EndResize; virtual;
    { invoked for all selected items and them visible children
      (for those are not selected) }
    procedure Drop(NewParent: TSchemeShape); virtual;
    property SchemeData: TSchemeShape read FSchemeData;
    property Selected: boolean read FSelected write SetSelected;
    property Visible: boolean read FVisible;
    property Position: TVec2i read GetPosition write SetPosition;
    property Parent: TSchemeShape read GetParent write SetParent;
    property ParentIsSelected: boolean read GetParentIsSelected;
    property IsDrag: boolean read FIsDrag;
    property AutoDragDrop: boolean read FAutoDragDrop;
    property Tag: Pointer read FTag write FTag;
    { define an unique style (ID) in a theme }
    property URL: AnsiString read GetUrl;
  published
    property Left: int32 read GetLeft write SetLeft;
    property Top: int32 read GetTop write SetTop;
    property Width: int32 read GetWidth write SetWidth;
    property Height: int32 read GetHeight write SetHeight;
    property Caption: string read GetCaption write SetCaption;
  end;

  TRendererNotify = procedure(Renderer: ISchemeRenderer) of object;

  { a logic of renderer;
    TODO: copy/paste; }

  { ISchemeRenderer }

  ISchemeRenderer = class abstract(TGUIProperties)
  private
    FSpaceTree: TBlackSharkSpaceTree;
    FListSelected: TListItemDual;
    FListSelectedNoVisual: TListItemDual;
    DropedToSchemeRegion: ISchemeItemVisual;
    AcceptingSchemeRegions: TBinTreeTemplate<ISchemeItemVisual, ISchemeItemVisual>;
    FOnSelectChangeSchemeItem: TSchemeItemVisualEvent;
    FSelected: ISchemeItemVisual;
    FIsResizing: boolean;
    DragFirst: ISchemeItemVisual;
    FSelectedProcessor: ISchemeItemVisual;
    FSelectedBlock: ISchemeItemVisual;
    FSelectedSchemeRegion: ISchemeItemVisual;
    FSelectedLink: ISchemeItemVisual;
    FBanSelect: boolean;
    FBanDragDrop: boolean;
    FOnBeforDraw: TSchemeItemVisualEvent;
    FEnabled: boolean;
    FOnDeleteItem: TSchemeItemVisualEvent;
    FOnChangeSelectItem: TSchemeItemVisualEvent;
    FOnEnterToBlock: TRendererNotify;
    FOnModified: TRendererNotify;
    FHistory: TListDual<PChangeData>;
    FScale: BSFloat;
    FDrawGrid: boolean;
    FNeedUpdate: TListVec<ISchemeItemVisual>;
    FViewportPositions: TBinTreeTemplate<TSchemeBlock, TVec2f>;
    FEventAfterLoadLevel: IBEmptyEvent;
  private
    class var VisualClasses: TBinTreeTemplate<uint32, ISchemeItemVisualClass>;
    class var FListVisualClasses: TListVec<ISchemeItemVisualClass>;
    class constructor Create;
    class destructor Destroy;
  private
    function GetModified: boolean;
    procedure SetModified(const Value: boolean);
    function GetCountSelected: int32;
    procedure MoveSchemeRegionChilds(SchemeRegion: ISchemeItemVisual);
    procedure CheckListPos(Item: ISchemeItemVisual);
    function GetSelectedOnlyLinks: boolean;
    function GetCountSchemeShapes: int32;
    function GetColorGrid: TGuiColor;
    function GetColorGrid2: TGuiColor;
    function GetFileScheme: string;
    procedure ClearHistory;
    procedure DoUpdateInSpaceTree(Item: ISchemeItemVisual); inline;
    procedure OnCreateShape(Shape: TSchemeShape);
    procedure OnDeleteShape(Shape: TSchemeShape);
    procedure SaveThemeCurrentBlock;
  protected
    FModel: TSchemeModel;
    Loading: boolean;
    FViewedBlock: TSchemeBlock;
    ToRendererDblClick: boolean;
    FIsDragItems: boolean;

    FGridColor: TColor4f;
    FGridColor2: TColor4f;
    FGridOpacity: int8;
    FGridStep: int32;
    FGridStepScaled: int32;
    FDragOver: ISchemeItemVisual;

    { storage of published properties for an every view of a shape }
    FTheme: TBTheme;

    procedure SetViewedBlock(const Value: TSchemeBlock); virtual;
    procedure SetFileScheme(const Value: string); virtual;
    procedure DoLoadBlock; virtual;
    { }
    procedure OnHideData(Node: PNodeSpaceTree); virtual;
    { }
    procedure OnShowData(Node: PNodeSpaceTree); virtual;
    { }
    procedure OnUpdatePositionUserData(Node: PNodeSpaceTree); virtual;
    { remove from space tree; happened when changing a viewed block or closing
      the renderer }
    procedure OnDeleteData(Node: PNodeSpaceTree); virtual;
    procedure SetDrawGrid(const Value: boolean); virtual;
    procedure BeginResize(Item: ISchemeItemVisual); virtual;
    procedure OnResize(Item: ISchemeItemVisual; const Scale: TVec3f; const Point: TBBLimitPoint); virtual;
    procedure EndResize(Item: ISchemeItemVisual); virtual;
    procedure SetScale(const Value: BSFloat); virtual;
    procedure SetBanSelect(const Value: boolean); virtual;
    procedure SetBanDragDrop(const Value: boolean); virtual;
    procedure SetBlockTexture(const Value: string); virtual;
    procedure SetBlockTextureIco(const Value: string); virtual;
    procedure SelectFontSize; virtual; abstract;
    procedure SetGridStep(const Value: int32); virtual;
    procedure SetEnabled(const Value: boolean); virtual;
    procedure SetColorGrid(const Value: TGuiColor); virtual;
    procedure SetGridOpacity(const Value: int8); virtual;
    procedure SetColorGrid2(const Value: TGuiColor); virtual;
    procedure SetColorScrollBar(const Value: TColor4f); virtual;
    function GetColorScrollBar: TColor4f; virtual;
    function GetColorBackground: TGuiColor; virtual; abstract;
    procedure SetColorBackground(const Value: TGuiColor); virtual; abstract;
    procedure OnChangeItem(ChangeData: PChangeData); virtual;
    procedure DoChangePosition(const NewPosition: TVec2d); virtual;
    function GetPosition: TVec2f; virtual; abstract;
    procedure SetPosition(const Value: TVec2f); virtual; abstract;
    { mouse events; X, Y - position relative left-up corner veiwport }
    procedure MouseUp(X, Y: int32); virtual;
    procedure MouseMove(X, Y: int32); virtual;
    procedure OnChangeSelectItemDo(Item: ISchemeItemVisual); virtual;
  public
    class procedure RegisterVisualItem(VisualClass: ISchemeItemVisualClass);
    class function GetClassVisualItem(const ClassNameSchemItem: string): ISchemeItemVisualClass;
    class function CountClasses: int32;
    class function GetClass(Index: int32): ISchemeItemVisualClass;
  public
    constructor Create(ASpaceTree: TBlackSharkSpaceTree);
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure CheckBoundary; virtual;
    procedure Clear; virtual;
    procedure DblClick(Item: ISchemeItemVisual); virtual;
    procedure ResetSelection(ExeptionItem: ISchemeItemVisual = nil); virtual;
    procedure Undo; virtual;
    procedure Redo; virtual;
    function HasUndo: boolean;
    function HasRedo: boolean;
    procedure BeginDragItems; virtual;
    procedure DragItem(Item: ISchemeItemVisual); virtual;
    procedure DragDropItem(Item: ISchemeItemVisual); virtual;
    procedure EndDragItems; virtual;
    { in cases when a some shape change parent need to hide item but not delete
      from a model }
    procedure RemoveFromSpaceTree(Item: ISchemeItemVisual);
    { remove from view all children of Ancestor }
    procedure HideChildrenOfItem(Ancestor: TSchemeShape);
    procedure Resize(Width, Height: BSFloat); virtual; abstract;
    function GetViewPortPosition: TVec2f; virtual; abstract;
    function DoesTheLinkNeedDraw(Link: TSchemeLink): boolean;
    procedure SetViewPortPosition(const Value: TVec2f); virtual; abstract;
    { TODO: CopySelected
      copy selected items to Destination (is cleared before) }
    procedure CopySelected(Destination: TSchemeModel; ParentBlock: TSchemeBlock; AutoAssignSchemeRegion: boolean; CopyRegions: boolean);
    procedure PasteScheme(scheme: TSchemeModel; const Position: TVec2f);
    function FindInRect(X, Y, Width, Height: BSFloat; ClassSchemItem: TSchemeShapeClass; ExceptItem: ISchemeItemVisual; ExceptSchemeLinks: boolean = false;
      ExceptDragged: boolean = false): ISchemeItemVisual;
    { find a visual shape in rect that has IsContainer = true }
    function FindRectContainer(X, Y, Width, Height: BSFloat; ClassContainer: TSchemeShapeClass; ExceptItem: ISchemeItemVisual): ISchemeItemVisual;
    procedure SetDefaultSizeInAllProcessors;
    procedure SetDefaultSizeInAllBlocks;
    procedure MoveToSelected(DeltaX, DeltaY: int32);
    procedure ResizeSelected(DeltaX, DeltaY: int32);
    function SaveAs(const FileName: string): boolean;
    function GetBlockOrSchemeRegion(X, Y: BSFloat; ParentSchemeRegionMandatory: boolean; const ClientSize: TVec2f): TSchemeShape;
    function GetItem(X, Y: BSFloat; ExcepTSchemeLink: boolean): ISchemeItemVisual; overload;
    function GetVisItem(ID: int32): ISchemeItemVisual;
    function GetSchemeShape(ID: int32): TSchemeShape;
    function FindClassItem(ClassSchemItem: TSchemeShapeClass): TSchemeShape;
    { after create need to set a position for located it to space tree,
      here it do not do, therefor you need to do it yourself }
    function CreateSchemeItem(const Parent: TSchemeShape; const SchemeClass: TSchemeShapeClass; const Caption: string): ISchemeItemVisual; overload; virtual;
    function CreateSchemeItem(const Parent: ISchemeItemVisual; const SchemeClass: TSchemeShapeClass; const Caption: string): ISchemeItemVisual; overload;
    function CreateLink(NumberOut: int32; FromItem: TSchemeLinkedShape; ToItem: TSchemeLinkedShape): ISchemeItemVisual; overload;
    function CreateViewOfShape(Shape: TSchemeShape): ISchemeItemVisual; virtual;
    procedure DeleteSchemeItem(const SchemarioItem: ISchemeItemVisual); virtual;
    procedure DeleteSelected; virtual;
    procedure UpdateInSpaceTree(Item: ISchemeItemVisual);
    function ClientSize: TVec2f; virtual; abstract;
    function GetAlignedOnGridSize(const Point: TPoint): TPoint; overload;
    function GetAlignedOnGridPosition(const Point: TPoint): TPoint; overload;
    function GetAlignedOnGridSize(const Size: TVec2i): TVec2i; overload;
    function GetAlignedOnGridPosition(const Pos: TVec2f): TVec2f; overload;
    procedure RecoveryDefaultSizeInSelected;
    procedure SelectNextUp;
    procedure SelectNextDown;
    procedure SelectNextRight;
    procedure SelectNextLeft;
    procedure Redraw;
  public
    property SpaceTree: TBlackSharkSpaceTree read FSpaceTree;
    property FileScheme: string read GetFileScheme write SetFileScheme;
    { storage of published properties for an every view of a shape }
    property Theme: TBTheme read FTheme;
    property ViewedBlock: TSchemeBlock read FViewedBlock write SetViewedBlock;
    property Modified: boolean read GetModified write SetModified;
    property OnModified: TRendererNotify read FOnModified write FOnModified;
    property CountSelected: int32 read GetCountSelected;
    property GridStep: int32 read FGridStep write SetGridStep;
    property GridStepScaled: int32 read FGridStepScaled;
    property OnSelectChangeSchemeItem: TSchemeItemVisualEvent read FOnSelectChangeSchemeItem write FOnSelectChangeSchemeItem;
    property OnChangeSelectItem: TSchemeItemVisualEvent read FOnChangeSelectItem write FOnChangeSelectItem;
    property OnDeleteItem: TSchemeItemVisualEvent read FOnDeleteItem write FOnDeleteItem;
    property OnEnterToBlock: TRendererNotify read FOnEnterToBlock write FOnEnterToBlock;
    property Selected: ISchemeItemVisual read FSelected;
    property SelectedProcessor: ISchemeItemVisual read FSelectedProcessor;
    property SelectedBlock: ISchemeItemVisual read FSelectedBlock;
    property SelectedSchemeRegion: ISchemeItemVisual read FSelectedSchemeRegion;
    property SelectedLink: ISchemeItemVisual read FSelectedLink;
    { true - selected only links }
    property SelectedOnlyLinks: boolean read GetSelectedOnlyLinks;
    property BanSelect: boolean read FBanSelect write SetBanSelect;
    property BanDragDrop: boolean read FBanDragDrop write SetBanDragDrop;
    property IsDragItems: boolean read FIsDragItems;
    property ListSelected: TListItemDual read FListSelected;
    { true - changing size }
    property IsResizing: boolean read FIsResizing;
    // property MaxRight: BSFloat read FMaxRight;
    // property MaxBottom: BSFloat read FMaxBottom;
    property OnBeforDraw: TSchemeItemVisualEvent read FOnBeforDraw write FOnBeforDraw;
    property Enabled: boolean read FEnabled write SetEnabled;
    property CounSchemeShapes: int32 read GetCountSchemeShapes;
    property Model: TSchemeModel read FModel;
    property Position: TVec2f read GetPosition write SetPosition;
    property EventAfterLoadLevel: IBEmptyEvent read FEventAfterLoadLevel;
  published
    property Scale: BSFloat read FScale write SetScale;
    property DrawGrid: boolean read FDrawGrid write SetDrawGrid;
    { 0..100 }
    property GridOpacity: int8 read FGridOpacity write SetGridOpacity;
    property GridColor: TGuiColor read GetColorGrid write SetColorGrid;
    property GridColor2: TGuiColor read GetColorGrid2 write SetColorGrid2;
    property ColorBackground: TGuiColor read GetColorBackground write SetColorBackground;
  end;

const
  COLOR_NO_LOAD_BLOK1: TColor4f = (X: 0.4; Y: 0.4; z: 0.4; a: 1.0);
  COLOR_NO_LOAD_BLOK2: TColor4f = (X: 0.2; Y: 0.2; z: 0.2; a: 1.0);

  COLOR_NO_LOAD_PROC1: TColor4f = (X: 35 / 255; Y: 35 / 255; z: 35 / 255; a: 1.0);
  COLOR_NO_LOAD_PROC2: TColor4f = (X: 0.35; Y: 0.35; z: 0.35; a: 1.0);

implementation

uses
    SysUtils
  , math
  , bs.obj
  , bs.utils
  , bs.strings
  , bs.thread
  , bs.math
  ;

{ ISchemeItemVisual }

procedure ISchemeItemVisual.BeforeDestruction;
begin
  inherited;
  if FSelected then
    Selected := false;
end;

procedure ISchemeItemVisual.BeginDrag;
begin
  if FIsDrag then
    exit;
  FIsDrag := true;
  FBeginDragPos := Position;
  if not FRenderer.IsDragItems then
    FRenderer.BeginDragItems;
end;

procedure ISchemeItemVisual.BeginDragOver;
begin

end;

procedure ISchemeItemVisual.BeginResize;
begin

end;

constructor ISchemeItemVisual.Create(ARenderer: ISchemeRenderer; ASchemeData: TSchemeShape);
begin
  FRenderer := ARenderer;
  FSchemeData := ASchemeData;
  FSchemeData.View := Self;
end;

destructor ISchemeItemVisual.Destroy;
begin
  FSchemeData.View := nil;
  inherited;
end;

procedure ISchemeItemVisual.DoDraw;
begin
  if Assigned(FRenderer.FOnBeforDraw) then
    FRenderer.FOnBeforDraw(nil);
  Draw;
end;

procedure ISchemeItemVisual.Drag;
var
  Pos: TVec2f;
begin
  FIsDrag := true;
  Pos := Position;
  if Pos.X < 0 then
    Pos.X := 0;
  if Pos.Y < 0 then
    Pos.Y := 0;
  { change position }
  Position := Pos;
end;

procedure ISchemeItemVisual.DragByParent(const NewPosition: TVec2f);
begin
  FIsDrag := true;
  FSchemeData.Position := NewPosition;
end;

procedure ISchemeItemVisual.DragChilds;
var
  i: int32;
  ch: TSchemeShape;
  delta: TVec2f;
begin
  delta := Position - FBeginDragPos;
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    ch := FSchemeData.Children[i];
    if (ch.View = nil) or (ISchemeItemVisual(ch.View).AutoDragDrop) then
      continue;
    if (ISchemeItemVisual(ch.View).Visible) then
    begin
      { object is visible; if is not selected - update position, otherwise, its position
        will be update auto by drag }
      if not ISchemeItemVisual(ch.View).Selected then
        ISchemeItemVisual(ch.View).DragByParent(ISchemeItemVisual(ch.View).FBeginDragPos + delta);
    end
    else
    begin
      { object is not visible - anyway change position }
      ISchemeItemVisual(ch.View).DragByParent(ISchemeItemVisual(ch.View).FBeginDragPos + delta);
      { update for case appear of the object }
      FRenderer.UpdateInSpaceTree(ISchemeItemVisual(ch.View));
    end;
    if ch is TSchemeRegion then
      ISchemeItemVisual(ch.View).DragChilds;
  end;
end;

procedure ISchemeItemVisual.Draw;
begin
  SelectColor;
end;

procedure ISchemeItemVisual.Drop(NewParent: TSchemeShape);
begin
  FIsDrag := false;
  Position := Position;
  if NewParent <> Parent then
    Parent := NewParent;
end;

procedure ISchemeItemVisual.EndDragOver;
begin

end;

procedure ISchemeItemVisual.EndResize;
var
  pi: TPoint;
  rect, rect_ch: TRectBSf;
  it: ISchemeItemVisual;
  scen_it: TSchemeShape;
  i: int32;
  cont: ISchemeItemVisual;
begin
  if FRenderer.DrawGrid then
  begin
    Position := FRenderer.GetAlignedOnGridPosition(Position);
    pi := GetAlignedOnGridSize;
    Resize(pi.X, pi.Y);
  end;

  if FSchemeData.IsContainer then
  begin
    rect := FSchemeData.GetRect;
    for i := FSchemeData.ChildrenCount - 1 downto 0 do
    begin
      scen_it := FSchemeData.Children[i];
      it := ISchemeItemVisual(scen_it.View);
      if it = nil then
        continue;
      rect_ch := scen_it.GetRect;
      if RectIntersect(rect, rect_ch) then
        continue;
      cont := FRenderer.FindRectContainer(rect_ch.X * FRenderer.Scale, rect_ch.Y * FRenderer.Scale, rect_ch.Width * FRenderer.Scale,
        rect_ch.Height * FRenderer.Scale, nil, it);
      if cont <> nil then
      begin
        it.Parent := cont.FSchemeData;
      end
      else
        it.Parent := FRenderer.FViewedBlock;
    end;

    { find items that it can take away }
    for i := FSchemeData.ParentLevel.ChildrenCount - 1 downto 0 do
    begin
      scen_it := FSchemeData.ParentLevel.Children[i];
      if (scen_it.View = nil) or (FSchemeData = scen_it) then
        continue;
      rect_ch := scen_it.GetRect;
      if not RectContains(rect, rect_ch) then
        continue;

      scen_it.Parent := FSchemeData;
    end;

  end;
end;

function ISchemeItemVisual.GetAlignedOnGridSize: TPoint;
begin
  Result := FRenderer.GetAlignedOnGridSize(Point(FSchemeData.Width, FSchemeData.Height));
  if Result.X = 0 then
    Result.X := FRenderer.GridStep;
  if Result.Y = 0 then
    Result.Y := FRenderer.GridStep;
end;

function ISchemeItemVisual.GetCaption: string;
begin
  Result := FSchemeData.Caption;
end;

function ISchemeItemVisual.GetHeight: int32;
begin
  Result := FSchemeData.Height;
end;

function ISchemeItemVisual.GetLeft: int32;
begin
  Result := FSchemeData.Left;
end;

function ISchemeItemVisual.GetParent: TSchemeShape;
begin
  Result := FSchemeData.Parent;
end;

function ISchemeItemVisual.GetParentIsSelected: boolean;
var
  pr: ISchemeItemVisual;
begin
  if FSchemeData.Parent <> nil then
  begin
    pr := ISchemeItemVisual(FSchemeData.Parent.View);
    while pr <> nil do
    begin
      if pr.Selected then
        exit(true);
      if pr.FSchemeData.Parent <> nil then
        pr := ISchemeItemVisual(pr.FSchemeData.Parent.View)
      else
        break;
    end;
  end;
  Result := false;
end;

function ISchemeItemVisual.GetPosition: TVec2i;
begin
  Result := FSchemeData.Position;
end;

function ISchemeItemVisual.GetTop: int32;
begin
  Result := FSchemeData.Top;
end;

function ISchemeItemVisual.GetUrl: AnsiString;
begin
  Result := bs.strings.StringToAnsi(IntToStr(FSchemeData.ID));
end;

function ISchemeItemVisual.GetWidth: int32;
begin
  Result := FSchemeData.Width;
end;

procedure ISchemeItemVisual.Hide;
begin
  FVisible := false;
end;

procedure ISchemeItemVisual.MoveTo(DeltaX, DeltaY: int32);
begin
  Position := vec2(Position.X + DeltaX, Position.Y + DeltaY);
end;

procedure ISchemeItemVisual.OnChange(ChangeData: PChangeData);
var
  p: TSchemeShape;
begin
  p := Parent;
  if (p <> nil) then
  begin
    if (p.View <> nil) then
      ISchemeItemVisual(p.View).OnChange(ChangeData)
    else
      FRenderer.OnChangeItem(ChangeData);
  end;
end;

procedure ISchemeItemVisual.OnDblClick;
begin

end;

function ISchemeItemVisual.OneOfParentsIsSelected: boolean;
var
  prnt: TSchemeShape;
begin
  prnt := FSchemeData.Parent;
  while prnt <> nil do
  begin
    if prnt.View = nil then
      break;
    if ISchemeItemVisual(prnt.View).Selected then
      exit(true);
    prnt := prnt.Parent;
  end;
  Result := false;
end;

procedure ISchemeItemVisual.OnMouseDown(X, Y: BSFloat; ShiftState: TShiftState);
begin

end;

procedure ISchemeItemVisual.Show;
begin
  FVisible := true;
end;

procedure ISchemeItemVisual.LoadChildren;
var
  i: int32;
  sch: TSchemeShape;
begin
  inherited;
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    sch := FSchemeData.Children[i];
    if sch.View <> nil then
      continue;
    FRenderer.CreateViewOfShape(sch);
  end;
end;

procedure ISchemeItemVisual.UpdatePosChilds;
var
  i: int32;
  ch: TSchemeShape;
begin
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    ch := FSchemeData.Children[i];
    if ch.View = nil then
      continue;
    ISchemeItemVisual(ch.View).Position := vec2(ch.Position.X, ch.Position.Y);
  end;
end;

procedure ISchemeItemVisual.Resize(AWidth, AHeight: int32);
var
  data: TChangeSizeData;
begin
  data.OldSize := vec2(FSchemeData.Width, FSchemeData.Height);
  data.BaseData.Shape := FSchemeData;
  data.BaseData.CodeChange := TCodeChange.ccResize;
  FSchemeData.Resize(round(AWidth), round(AHeight));
  FRenderer.UpdateInSpaceTree(Self);
  if FVisible then
    DoDraw;
  OnChange(@data);
end;

procedure ISchemeItemVisual.SaveSchemeProperties;
var
  i: int32;
  ch: TSchemeShape;
begin
  SaveProperties(URL, FRenderer.Theme, true);
  for i := 0 to FSchemeData.ChildrenCount - 1 do
  begin
    ch := FSchemeData.Children[i];
    if ch.View = nil then
      continue;
    ISchemeItemVisual(ch.View).SaveSchemeProperties;
  end;
end;

procedure ISchemeItemVisual.LoadSchemeProperties;
var
  gr: TStyleGroup;
  _url: AnsiString;
begin
  _url := URL;
  gr := FRenderer.Theme.FindStyleGroup(_url);
  if gr = nil then
  begin
    gr := FRenderer.Theme.CreateStyleGroup(_url, Self, true);
    SaveProperties(gr);
  end
  else
    LoadProperties(gr);
end;

procedure ISchemeItemVisual.SetCaption(const Value: string);
var
  data: TChangeCaptionData;
begin
  if FSchemeData.Caption = Value then
    exit;
  data.BaseData.Shape := FSchemeData;
  data.BaseData.CodeChange := ccCaption;
  data.OldCaption := FSchemeData.Caption;
  FSchemeData.Caption := Value;
  OnChange(@data);
end;

procedure ISchemeItemVisual.SetHeight(const Value: int32);
begin
  Resize(FSchemeData.Width, Value);
end;

procedure ISchemeItemVisual.SetLeft(const Value: int32);
begin
  Position := vec2(Value, FSchemeData.Top);
end;

procedure ISchemeItemVisual.SetParent(const Value: TSchemeShape);
begin
  FSchemeData.Parent := Value;
end;

{ procedure ISchemeItemVisual.SetPos(const Value: TVec2i);
  var
  data: TChangePosData;
  begin
  data.OldPos := FSchemeData.Position;
  FSchemeData.Position := Value;
  data.BaseData.Shape := FSchemeData;
  data.BaseData.CodeChange := TCodeChange.ccPosition;
  OnChange(@data);
  end; }

procedure ISchemeItemVisual.SetPosition(const Value: TVec2i);
var
  p: TVec2i;
  o: TVec2i;
begin
  p := Value;
  { align position if grid is drawed and the object is not stretched by user }
  if FRenderer.FDrawGrid and not FRenderer.IsResizing and not FIsDrag then
  begin
    { position and size }
    o := vec2(p.X mod FRenderer.GridStep, p.Y mod FRenderer.GridStep);
    if (o.X > 0) then
    begin
      if o.X > FRenderer.GridStep div 2 then
        p.X := ((p.X div FRenderer.GridStep) + 1) * FRenderer.GridStep
      else
        p.X := (p.X div FRenderer.GridStep) * FRenderer.GridStep;
    end;
    if (o.Y > 0) then
    begin
      if o.Y > FRenderer.GridStep div 2 then
        p.Y := ((p.Y div FRenderer.GridStep) + 1) * FRenderer.GridStep
      else
        p.Y := (p.Y div FRenderer.GridStep) * FRenderer.GridStep;
    end;
  end;
  FSchemeData.Position := vec2(p.X, p.Y);
  FRenderer.UpdateInSpaceTree(Self);
end;

procedure ISchemeItemVisual.SetSelected(const Value: boolean);
begin
  if FSelected = Value then
    exit;
  FSelected := Value;
  FRenderer.OnChangeSelectItemDo(Self);
end;

procedure ISchemeItemVisual.SetTop(const Value: int32);
begin
  Position := vec2(FSchemeData.Left, Value);
end;

procedure ISchemeItemVisual.SetWidth(const Value: int32);
begin
  Resize(Value, FSchemeData.Height);
end;

{ ISchemeRenderer }

procedure ISchemeRenderer.AfterConstruction;
begin
  inherited;
  SelectFontSize;
end;

procedure ISchemeRenderer.BeginDragItems;
var
  it: TListItemDual.PListItem;
begin
  FIsDragItems := true;
  DragFirst := nil;
  it := FListSelectedNoVisual.ItemListFirst;
  while it <> nil do
  begin
    if not(it.Item.AutoDragDrop) then
      it.Item.BeginDrag;
    it := it.Next;
  end;
end;

procedure ISchemeRenderer.BeginResize(Item: ISchemeItemVisual);
begin
  FIsResizing := true;
  Item.BeginResize;
end;

procedure ISchemeRenderer.CheckBoundary;
begin
end;

procedure ISchemeRenderer.CheckListPos(Item: ISchemeItemVisual);
begin
  if Item.Selected then
  begin
    if Item.FVisible then
    begin
      if (Item._SelDataNoVis <> nil) and (not Item.IsDrag) then
        FListSelectedNoVisual.Remove(Item._SelDataNoVis);
    end
    else if (Item._SelDataNoVis = nil) then
    begin
      Item._SelDataNoVis := FListSelectedNoVisual.PushToEnd(Item);
    end;
  end
  else
  begin
    if (Item._SelDataNoVis <> nil) then
      FListSelectedNoVisual.Remove(Item._SelDataNoVis);
  end;
end;

procedure ISchemeRenderer.Clear;
begin
  ResetSelection;
  FModel.Clear;
  FViewedBlock := FModel;
  Modified := false;
end;

procedure ISchemeRenderer.ClearHistory;
begin
  while FHistory.Count > 0 do
    dispose(FHistory.Pop);
end;

procedure ISchemeRenderer.CopySelected(Destination: TSchemeModel; ParentBlock: TSchemeBlock; AutoAssignSchemeRegion: boolean; CopyRegions: boolean);
var
  it, prnt: TSchemeShape;
  sel_it: TListItemDual.PListItem;
begin
  if ParentBlock = nil then
    raise Exception.Create('Parameter ParentBlock must be valid!');

  { Reset copyedID to -1 for it can learn which items are copyed (they have
    CopyedID >= 0) }
  FModel.ResetCopyedItemID;
  Destination.ResetCopyedItemID;

  if AutoAssignSchemeRegion then
    prnt := ParentBlock.SchemeModel.FindParentRegion(ParentBlock)
  else
    prnt := ParentBlock;

  sel_it := FListSelected.ItemListFirst;
  while sel_it <> nil do
  begin
    it := nil;
    if // not (sel_it.Item.FSchemeData is TSchemeLink) and
      (CopyRegions or not(sel_it.Item.FSchemeData is TSchemeRegion)) then
    begin
      if AutoAssignSchemeRegion and (prnt = nil) then
      begin
        prnt := Destination.FindItem(ParentBlock, TSchemeRegion, nil, RectBS(sel_it.Item.Position.X, sel_it.Item.Position.Y, sel_it.Item.FSchemeData.Width,
          sel_it.Item.FSchemeData.Height));
        if prnt = nil then
        begin
          { create region }
          prnt := TSchemeRegion.Create(ParentBlock);
        end;
      end;
      sel_it.Item.FSchemeData.CopyShape(it, prnt);
    end;
    sel_it := sel_it.Next;
  end;

  { }

  { sel_it := FListSelected.ItemListFirst;
    while sel_it <> nil do
    begin
    it := sel_it.Item.FSchemeData;
    sel_it := sel_it.Next;

    for i := 0 to it.CountOutPuts - 1 do
    begin
    li := it.OutPut[i];
    if li = nil then
    continue;

    fr := Destination.GetSchemeItemFromID(li.Parent.CopyedItemID);

    to_:= Destination.GetSchemeItemFromID(li.ToLink.CopyedItemID);

    if (fr = nil) or (to_ = nil) then
    continue;

    fr.AddOutPut(li.NumOut, to_, li.ID);
    end;
    end; }

  { }

  Destination.IdToSource;

end;

class function ISchemeRenderer.CountClasses: int32;
begin
  Result := FListVisualClasses.Count;
end;

constructor ISchemeRenderer.Create(ASpaceTree: TBlackSharkSpaceTree);
begin
  FTheme := TBTheme.Create;
  FNeedUpdate := TListVec<ISchemeItemVisual>.Create;
  FHistory := TListDual<PChangeData>.Create;
  FSpaceTree := ASpaceTree;
  FSpaceTree.OnShowUserData := OnShowData;
  FSpaceTree.OnHideUserData := OnHideData;
  FSpaceTree.OnUpdatePositionUserData := OnUpdatePositionUserData;
  FSpaceTree.OnDeleteUserData := OnDeleteData;
  FModel := TSchemeModel.Create(nil);
  FModel.OnDeleteShape := OnDeleteShape;
  FModel.OnCreateShape := OnCreateShape;
  FViewedBlock := FModel;
  FListSelected := TListItemDual.Create;
  FListSelectedNoVisual := TListItemDual.Create;
  AcceptingSchemeRegions := TBinTreeTemplate<ISchemeItemVisual, ISchemeItemVisual>.Create(@PtrCmp);
  FScale := 1.0;
  FDrawGrid := true;
  FGridStep := 10;
  FGridStepScaled := round(FGridStep * FScale);
  FGridColor := BS_CL_GRAY;
  FGridColor2 := BS_CL_GREEN;
  FGridOpacity := 10;
  FViewportPositions := TBinTreeTemplate<TSchemeBlock, TVec2f>.Create(@PtrCmp);
  FEventAfterLoadLevel := CreateEmptyEvent;
end;

function ISchemeRenderer.CreateLink(NumberOut: int32; FromItem: TSchemeLinkedShape; ToItem: TSchemeLinkedShape): ISchemeItemVisual;
begin
  Result := GetClassVisualItem(TSchemeLink.ClassName).Create(Self, FromItem.AddOutPut(NumberOut, ToItem));
end;

function ISchemeRenderer.CreateSchemeItem(const Parent: ISchemeItemVisual; const SchemeClass: TSchemeShapeClass; const Caption: string): ISchemeItemVisual;
begin
  if Parent <> nil then
    Result := CreateSchemeItem(Parent.FSchemeData, SchemeClass, Caption)
  else
    Result := CreateSchemeItem(TSchemeShape(nil), SchemeClass, Caption);
end;

function ISchemeRenderer.CreateViewOfShape(Shape: TSchemeShape): ISchemeItemVisual;
var
  cl: ISchemeItemVisualClass;
begin
  cl := GetClassVisualItem(Shape.ClassName);
  if not Assigned(cl) then
    raise Exception.Create('A view for the shape ' + Shape.ClassName + ' did not find!');
  Result := cl.Create(Self, Shape);
  Result.LoadSchemeProperties;
  UpdateInSpaceTree(Result);
end;

function ISchemeRenderer.CreateSchemeItem(const Parent: TSchemeShape; const SchemeClass: TSchemeShapeClass; const Caption: string): ISchemeItemVisual;
var
  Item: TSchemeShape;
  ChangeData: TChangeData;
begin
  if Parent = nil then
    Item := SchemeClass.Create(FModel)
  else
    Item := SchemeClass.Create(Parent);

  Result := ISchemeItemVisual(Item.View);
  Result.Caption := Caption;

  { after create need set position for located it to space tree, therfor here
    we do not do it }
  // UpdateInSpaceTree(Result);
  Modified := true;
  ChangeData.Shape := Item;
  ChangeData.CodeChange := TCodeChange.ccCreate;
  OnChangeItem(@ChangeData);
end;

procedure ISchemeRenderer.OnChangeItem(ChangeData: PChangeData);
begin
  if (ChangeData.Shape.View <> nil) then
  begin
    if (ChangeData.CodeChange = ccResize) or (ChangeData.CodeChange = ccPosition) then
    begin
      UpdateInSpaceTree(ISchemeItemVisual(ChangeData.Shape.View));
    end;
    if not FIsResizing and not FIsDragItems and ISchemeItemVisual(ChangeData.Shape.View).Visible then
      ISchemeItemVisual(ChangeData.Shape.View).Draw;
  end;
  Modified := true;
end;

procedure ISchemeRenderer.OnChangeSelectItemDo(Item: ISchemeItemVisual);
var
  it: TListItemDual.PListItem;
begin
  if Item.Selected then
  begin
    if (Item._SelData = nil) then
      Item._SelData := FListSelected.PushToEnd(Item);
    FSelected := Item;
  end
  else
  begin
    if (Item._SelData <> nil) then
      FListSelected.Remove(Item._SelData);
    if (Item = FSelected) then
    begin
      if FListSelected.Count > 0 then
        FSelected := FListSelected.ItemListFirst.Item
      else
        FSelected := nil;
    end;
    Item.SaveSchemeProperties;
  end;
  FSelectedProcessor := nil;
  FSelectedLink := nil;
  FSelectedBlock := nil;
  FSelectedSchemeRegion := nil;
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    if it.Item.FSchemeData is TSchemeProcessor then
    begin
      if FSelectedProcessor = nil then
        FSelectedProcessor := it.Item;
    end
    else if it.Item.FSchemeData is TSchemeLink then
    begin
      if FSelectedLink = nil then
        FSelectedLink := it.Item;
    end
    else if it.Item.FSchemeData is TSchemeBlock then
    begin
      if FSelectedBlock = nil then
        FSelectedBlock := it.Item;
    end
    else if it.Item.FSchemeData is TSchemeRegion then
    begin
      if FSelectedSchemeRegion = nil then
        FSelectedSchemeRegion := it.Item;
    end;
    it := it.Next;
  end;
  CheckListPos(Item);
  if Assigned(FOnSelectChangeSchemeItem) then
    FOnSelectChangeSchemeItem(Item);
end;

procedure ISchemeRenderer.DblClick(Item: ISchemeItemVisual);
begin
  ToRendererDblClick := true;
  BanSelect := true;
  if Item <> nil then
  begin
    if (Item.FSchemeData is TSchemeBlock) then
      ViewedBlock := TSchemeBlock(Item.FSchemeData);
  end
  else if FViewedBlock.ParentLevel <> nil then
    ViewedBlock := FViewedBlock.ParentLevel;
end;

procedure ISchemeRenderer.OnDeleteData(Node: PNodeSpaceTree);
begin
  if Node.BB.TagPtr = FDragOver then
    FDragOver := nil;

  ISchemeItemVisual(Node.BB.TagPtr).SaveProperties(ISchemeItemVisual(Node.BB.TagPtr).URL, Theme, false);
  if ISchemeItemVisual(Node.BB.TagPtr).Visible then
    ISchemeItemVisual(Node.BB.TagPtr).Hide;
  ISchemeItemVisual(Node.BB.TagPtr).Free;
end;

procedure ISchemeRenderer.OnDeleteShape(Shape: TSchemeShape);
var
  url: AnsiString;
begin
  url := StringToAnsi(IntToStr(Shape.ID));
  try
    if Shape is TSchemeBlock then
      FViewportPositions.Remove(TSchemeBlock(Shape));
    if Assigned(FOnDeleteItem) and (Shape.View <> nil) then
      FOnDeleteItem(ISchemeItemVisual(Shape.View));
  finally
    if Shape.View <> nil then
      FSpaceTree.Remove(ISchemeItemVisual(Shape.View).NodeSpaceTree);
  end;
  Theme.DeleteGroup(url);
end;

procedure ISchemeRenderer.OnCreateShape(Shape: TSchemeShape);
begin

  if (Shape.ParentLevel <> FViewedBlock) or (FModel.ModelState <> TModelState.msNone) then
    exit;

  CreateViewOfShape(Shape);
end;

procedure ISchemeRenderer.OnHideData(Node: PNodeSpaceTree);
begin
  ISchemeItemVisual(Node.BB.TagPtr).Hide;
  CheckListPos(Node.BB.TagPtr);
end;

procedure ISchemeRenderer.OnResize(Item: ISchemeItemVisual; const Scale: TVec3f; const Point: TBBLimitPoint);
var
  delta: TVec2f;
  new_s, Pos, pos_old: TVec2i;
begin
  new_s := vec2(Item.FSchemeData.Width * Scale.X, Item.FSchemeData.Height * Scale.Y);
  delta := new_s - vec2(Item.FSchemeData.Width, Item.FSchemeData.Height);
  pos_old := Item.Position;
  Item.Resize(new_s.X, new_s.Y);
  if ((Point[0] = xMin) or (Point[1] = yMax)) then
  begin
    if (Point[0] = xMid) and (Point[1] = yMax) then { drag to up? }
      Pos := vec2(pos_old.X, pos_old.Y - delta.Y)
    else if (Point[0] = xMin) and (Point[1] = yMid) then { drag to the left? }
      Pos := vec2(pos_old.X - delta.X, pos_old.Y)
    else if (Point[0] = xMax) and (Point[1] = yMax) then { drag to the up-right? }
      Pos := vec2(pos_old.X, pos_old.Y - delta.Y)
    else if (Point[0] = xMin) and (Point[1] = yMax) then { drag to the up-left? }
      Pos := vec2(pos_old.X - delta.X, pos_old.Y - delta.Y)
    else if (Point[0] = xMin) and (Point[1] = yMin) then { drag to the down-left? }
      Pos := vec2(pos_old.X - delta.X, pos_old.Y)
    else
      Pos := pos_old;
  end
  else
    Pos := pos_old;

  Item.Position := Pos;
end;

procedure ISchemeRenderer.OnShowData(Node: PNodeSpaceTree);
begin
  if Assigned(FOnBeforDraw) then
    FOnBeforDraw(ISchemeItemVisual(Node.BB.TagPtr));
  ISchemeItemVisual(Node.BB.TagPtr).Show;
  ISchemeItemVisual(Node.BB.TagPtr).Draw;
  CheckListPos(ISchemeItemVisual(Node.BB.TagPtr));
  ISchemeItemVisual(Node.BB.TagPtr).AfterShow;
end;

procedure ISchemeRenderer.OnUpdatePositionUserData(Node: PNodeSpaceTree);
begin

end;

procedure ISchemeRenderer.PasteScheme(scheme: TSchemeModel; const Position: TVec2f);

// var
// cl_link: ISchemeItemVisualClass;

  procedure InsIt(it: TSchemeShape);
  var
    j: int32;
    vi: ISchemeItemVisual;
  begin
    if it.View = nil then
    begin
      vi := GetClassVisualItem(it.ClassName).Create(Self, it);
      UpdateInSpaceTree(vi);
      vi.Selected := true;
    end;

    if it is TSchemeRegion then
      for j := 0 to it.ChildrenCount - 1 do
        InsIt(it.Children[j]);
  end;

{ procedure CalcLinks(it: TSchemeShape);
  var
  j: int32;
  vi: ISchemeItemVisual;
  li: TSchemeLink;
  begin
  if it is TSchemeRegion then
  for j := 0 to it.ChildrenCount - 1 do
  CalcLinks(it.Children[j]);

  for j := 0 to it.CountOutPuts - 1 do
  begin
  li := it.OutPut[j];
  if (li = nil) or (li.View <> nil) then
  continue;
  li.CalcIntersectSide;
  vi := cl_link.Create(Self, li);
  UpdateInSpaceTree(vi);
  if (li.View = nil) or (li.AreaFrom = nil) or (li.AreaFrom.View = nil) then
  continue;
  ISchemeItemVisual(li.AreaFrom.View).CalculateOutputs;
  end;
  end; }

var
  list: TListVec<TSchemeShape>;
  // vi: ISchemeItemVisual;
  i: int32;

begin
  list := TListVec<TSchemeShape>.Create;
  FModel.PasteScheme(scheme, Position, ViewedBlock, list);
  // cl_link := GetClassVisualItem(TSchemeLink.ClassName);
  for i := 0 to list.Count - 1 do
    InsIt(list.Items[i]);
  // for i := 0 to list.Count - 1 do
  // CalcLinks(list.Items[i]);
  list.Free;
  if list.Count > 0 then
    Modified := true;
  CheckBoundary;
end;

procedure ISchemeRenderer.RecoveryDefaultSizeInSelected;
var
  it: TListItemDual.PListItem;
begin
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    it.Item.FSchemeData.Resize(it.Item.FSchemeData.GetDefaultSize);
    UpdateInSpaceTree(it.Item);
    it.Item.Draw;
    it.Item.UpdatePosChilds;
    it := it.Next;
  end;
end;

procedure ISchemeRenderer.Redo;
begin

end;

procedure ISchemeRenderer.Redraw;
var
  i: int32;
  it: TSchemeShape;
begin
  for i := 0 to FViewedBlock.ChildrenCount - 1 do
  begin
    it := FViewedBlock.Children[i];
    if (it.View <> nil) and (ISchemeItemVisual(it.View).Visible) then
      ISchemeItemVisual(it.View).Draw;
  end;
end;

class procedure ISchemeRenderer.RegisterVisualItem(VisualClass: ISchemeItemVisualClass);
var
  h: uint32;
begin
  { }
  h := GetHashSedgwickS(VisualClass.PresentedClass.ClassName);
  VisualClasses.Add(h, VisualClass);
  FListVisualClasses.Add(VisualClass);
end;

procedure ISchemeRenderer.RemoveFromSpaceTree(Item: ISchemeItemVisual);
begin
  FSpaceTree.Remove(Item.NodeSpaceTree);
end;

procedure ISchemeRenderer.ResetSelection(ExeptionItem: ISchemeItemVisual);
var
  it: TListItemDual.PListItem;
  it_g: ISchemeItemVisual;
begin
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    it_g := it.Item;
    it := it.Next;
    if it_g <> ExeptionItem then
      it_g.Selected := false;
  end;
  // FListSelected.Clear;
end;

procedure ISchemeRenderer.ResizeSelected(DeltaX, DeltaY: int32);
var
  it: TListItemDual.PListItem;
  s: TVec2i;
begin
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    if FDrawGrid then
    begin
      s := GetAlignedOnGridSize(vec2(it.Item.FSchemeData.Width + DeltaX, it.Item.FSchemeData.Height + DeltaY));
    end
    else
    begin
      s := vec2(it.Item.FSchemeData.Width + DeltaX, it.Item.FSchemeData.Height + DeltaY);
    end;
    if s.X <= 0 then
      s.X := it.Item.FSchemeData.Width;
    if s.Y <= 0 then
      s.Y := it.Item.FSchemeData.Height;
    s := vec2(s.X - it.Item.FSchemeData.Width, s.Y - it.Item.FSchemeData.Height);
    it.Item.Resize(it.Item.FSchemeData.Width + s.X, it.Item.FSchemeData.Height + s.Y);
    it.Item.EndResize;
    it := it.Next;
  end;
end;

function ISchemeRenderer.SaveAs(const FileName: string): boolean;
begin
  { save visual state }
  SaveThemeCurrentBlock;
  SaveProperties(StringToAnsi(IntToStr(FModel.ID)), FTheme, true);
  Theme.Save(FileName + '.thm');
  Result := FModel.SaveScheme(FileName);
end;

procedure ISchemeRenderer.SaveThemeCurrentBlock;
var
  i: int32;
  sch: TSchemeShape;
begin
  for i := 0 to FViewedBlock.ChildrenCount - 1 do
  begin
    sch := FViewedBlock.Children[i];
    if sch.View = nil then
      continue;
    ISchemeItemVisual(sch.View).SaveProperties(ISchemeItemVisual(sch.View).URL, Theme, true);
  end;
end;

procedure ISchemeRenderer.SelectNextDown;
var
  l: TListNodes;
  Pos: TVec2f;
  i: int32;
  d: BSFloat;
  dist: BSFloat;
  sel, find: ISchemeItemVisual;
  ovrl: TRectBSf;
begin
  if FSelected = nil then
    exit;
  Pos := (FSelected.Position + 1) * FScale;
  l := nil;
  FSpaceTree.SelectData(0, Pos.Y + FSelected.FSchemeData.Height * FScale, FSpaceTree.Root.BB.x_max, FSpaceTree.Root.BB.y_max - Pos.Y, l);
  d := MaxSingle;
  find := nil;
  for i := 0 to l.Count - 1 do
  begin
    sel := l.Items[i].BB.TagPtr;
    if sel.Selected or (FSelected.Parent = sel.FSchemeData) or (sel.FSchemeData is TSchemeLink) or
      (sel.FSchemeData.Position.Y + sel.FSchemeData.Height = FSelected.FSchemeData.Position.Y + FSelected.FSchemeData.Height) then
      continue;
    ovrl := RectOverlap(FSelected.FSchemeData.GetRect, sel.FSchemeData.GetRect);
    if ovrl.Height > 0 then
      continue;
    Pos := FSelected.FSchemeData.Center - sel.FSchemeData.Center;
    dist := VecLen(Pos);
    if dist < d then
    begin
      find := sel;
      d := dist;
    end;
  end;
  if find <> nil then
  begin
    FSelected.Selected := false;
    find.Selected := true;
  end;
end;

procedure ISchemeRenderer.SelectNextLeft;
var
  l: TListNodes;
  Pos: TVec2f;
  i: int32;
  d: BSFloat;
  dist: BSFloat;
  sel, find: ISchemeItemVisual;
  ovrl: TRectBSf;
begin
  if FSelected = nil then
    exit;
  Pos := (FSelected.Position - 1) * FScale;
  l := nil;
  FSpaceTree.SelectData(0, 0, Pos.X, FSpaceTree.Root.BB.y_max, l); // FMaxBottom * FScale
  d := MaxSingle;
  find := nil;
  for i := 0 to l.Count - 1 do
  begin
    sel := l.Items[i].BB.TagPtr;
    if sel.Selected or (FSelected.Parent = sel.FSchemeData) or (sel.FSchemeData is TSchemeLink) or (sel.FSchemeData.Position.X = FSelected.FSchemeData.Position.X) then
      continue;
    ovrl := RectOverlap(FSelected.FSchemeData.GetRect, sel.FSchemeData.GetRect);
    if ovrl.Width > 0 then
      continue;
    Pos := FSelected.FSchemeData.Center - sel.FSchemeData.Center;
    dist := VecLen(Pos);
    if dist < d then
    begin
      find := sel;
      d := dist;
    end;
  end;
  if find <> nil then
  begin
    FSelected.Selected := false;
    find.Selected := true;
  end;
end;

procedure ISchemeRenderer.SelectNextRight;
var
  l: TListNodes;
  Pos: TVec2f;
  i: int32;
  d: BSFloat;
  dist: BSFloat;
  sel, find: ISchemeItemVisual;
  ovrl: TRectBSf;
begin
  if FSelected = nil then
    exit;
  Pos := (FSelected.Position + 1) * FScale;
  l := nil;
  Pos.X := Pos.X + FSelected.FSchemeData.Width * FScale;
  FSpaceTree.SelectData(Pos.X, 0, FSpaceTree.Root.BB.x_max - Pos.X, FSpaceTree.Root.BB.y_max, l); // FMaxRight * FScale   FMaxBottom * FScale
  d := MaxSingle;
  find := nil;
  for i := 0 to l.Count - 1 do
  begin
    sel := l.Items[i].BB.TagPtr;
    if sel.Selected or (FSelected.Parent = sel.FSchemeData) or (sel.FSchemeData is TSchemeLink) or
      (sel.FSchemeData.Position.X + sel.FSchemeData.Width = FSelected.FSchemeData.Position.X + FSelected.FSchemeData.Width) then
      continue;

    ovrl := RectOverlap(FSelected.FSchemeData.GetRect, sel.FSchemeData.GetRect);
    if ovrl.Width > 0 then
      continue;
    Pos := FSelected.FSchemeData.Center - sel.FSchemeData.Center;
    dist := VecLen(Pos);
    if dist < d then
    begin
      find := sel;
      d := dist;
    end;
  end;
  if find <> nil then
  begin
    FSelected.Selected := false;
    find.Selected := true;
  end;
end;

procedure ISchemeRenderer.SelectNextUp;
var
  l: TListNodes;
  Pos: TVec2f;
  i: int32;
  d: BSFloat;
  dist: BSFloat;
  sel, find: ISchemeItemVisual;
  ovrl: TRectBSf;
begin
  if FSelected = nil then
    exit;
  Pos := (FSelected.Position + 1) * FScale;
  l := nil;
  FSpaceTree.SelectData(0, 0, FSpaceTree.Root.BB.x_max, Pos.Y, l); // FMaxRight * FScale
  d := MaxSingle;
  find := nil;
  for i := 0 to l.Count - 1 do
  begin
    sel := l.Items[i].BB.TagPtr;
    if sel.Selected or (FSelected.Parent = sel.FSchemeData) or (sel.FSchemeData is TSchemeLink) or (sel.FSchemeData.Position.Y = FSelected.FSchemeData.Position.Y) then
      continue;
    ovrl := RectOverlap(FSelected.FSchemeData.GetRect, sel.FSchemeData.GetRect);
    if ovrl.Height > 0 then
      continue;
    Pos := FSelected.FSchemeData.Center - sel.FSchemeData.Center;
    dist := VecLen(Pos);
    if dist < d then
    begin
      find := sel;
      d := dist;
    end;
  end;
  if find <> nil then
  begin
    FSelected.Selected := false;
    find.Selected := true;
  end;
end;

procedure ISchemeRenderer.SetBanDragDrop(const Value: boolean);
begin
  FBanDragDrop := Value;
end;

procedure ISchemeRenderer.SetBanSelect(const Value: boolean);
begin
  FBanSelect := Value;
end;

procedure ISchemeRenderer.SetBlockTexture(const Value: string);
begin

end;

procedure ISchemeRenderer.SetBlockTextureIco(const Value: string);
begin

end;

procedure ISchemeRenderer.SetColorGrid(const Value: TGuiColor);
begin
  FGridColor := ColorByteToFloat(Value);
end;

procedure ISchemeRenderer.SetColorGrid2(const Value: TGuiColor);
begin
  FGridColor2 := ColorByteToFloat(Value);
end;

procedure ISchemeRenderer.SetColorScrollBar(const Value: TColor4f);
begin

end;

procedure ISchemeRenderer.SetDefaultSizeInAllBlocks;

  procedure SetSizeInBlock(Item: TSchemeShape; IsBlock: boolean);
  var
    i: int32;
    s_it: TSchemeShape;
  begin
    if IsBlock then
    begin
      Item.Resize(Item.GetDefaultSize);
    end;
    for i := 0 to Item.ChildrenCount - 1 do
    begin
      s_it := Item.Children[i];
      if s_it is TSchemeBlock then
        SetSizeInBlock(s_it, true)
      else if s_it is TSchemeRegion then
        SetSizeInBlock(s_it, false);
    end;
  end;

  procedure CalcLinks(Item: TSchemeShape);
  var
    i: int32;
    s_it: TSchemeShape;
  begin
    for i := 0 to Item.ChildrenCount - 1 do
    begin
      s_it := Item.Children[i];
      if (s_it is TSchemeRegion) then
        CalcLinks(s_it)
      else if (s_it is TSchemeBlock) and (s_it.View <> nil) then
      begin
        // ISchemeItemVisual(s_it.View).CalculateOutputs;
        ISchemeItemVisual(s_it.View).Draw;
      end;
    end;
  end;

begin
  SetSizeInBlock(FModel, false);
  CalcLinks(FModel);
  if Assigned(FOnModified) then
    FOnModified(Self);
end;

procedure ISchemeRenderer.SetDefaultSizeInAllProcessors;

  procedure SetSizeInBlock(Item: TSchemeShape);
  var
    i: int32;
    s_it: TSchemeShape;
  begin
    for i := 0 to Item.ChildrenCount - 1 do
    begin
      s_it := Item.Children[i];
      if (s_it is TSchemeBlock) or (s_it is TSchemeRegion) then
        SetSizeInBlock(s_it)
      else if s_it is TSchemeProcessor then
      begin
        s_it.Resize(s_it.GetDefaultSize);
      end;
    end;
  end;

  procedure CalcLinks(Item: TSchemeShape);
  var
    i: int32;
    s_it: TSchemeShape;
  begin
    for i := 0 to Item.ChildrenCount - 1 do
    begin
      s_it := Item.Children[i];
      if (s_it is TSchemeRegion) then
        CalcLinks(s_it)
      else if (s_it is TSchemeLinkedShape) and (s_it.View <> nil) then
      begin
        ISchemeItemVisual(s_it.View).Draw;
      end;
    end;
  end;

begin
  SetSizeInBlock(FModel);
  CalcLinks(FModel);
  if Assigned(FOnModified) then
    FOnModified(Self);
end;

procedure ISchemeRenderer.SetDrawGrid(const Value: boolean);
begin

end;

procedure ISchemeRenderer.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
end;

procedure ISchemeRenderer.SetGridOpacity(const Value: int8);
begin
  FGridOpacity := bs.math.Max(0, bs.math.Min(100, Value));
end;

procedure ISchemeRenderer.SetGridStep(const Value: int32);
begin
  FGridStep := Value;
  FGridStepScaled := round(FGridStep * FScale);
end;

procedure ISchemeRenderer.SetModified(const Value: boolean);
begin
  FModel.Modified := Value;
  if Assigned(FOnModified) then
    FOnModified(Self);
end;

procedure ISchemeRenderer.SetScale(const Value: BSFloat);

  procedure ChangeScale(Item: TSchemeShape);
  var
    i: int32;
    ch: TSchemeShape;
  begin
    if (Item.View <> nil) then
    begin
      if (ISchemeItemVisual(Item.View).Visible) then
        ISchemeItemVisual(Item.View).Draw;
      UpdateInSpaceTree(ISchemeItemVisual(Item.View));
    end;

    for i := 0 to Item.ChildrenCount - 1 do
    begin
      ch := Item.Children[i];
      ChangeScale(ch);
    end;
  end;

begin
  FScale := bs.math.Clamp(3.0, 0.1, Value);

  FGridStepScaled := round(FGridStep * FScale);
  SelectFontSize;
  ChangeScale(FViewedBlock);
  CheckBoundary;
end;

procedure ISchemeRenderer.SetFileScheme(const Value: string);
begin
  Clear;
  Theme.Load(Value + '.thm');
  FViewedBlock := FModel;
  FModel.OpenScheme(Value);
  DoLoadBlock;
  LoadProperties(FTheme.FindStyleGroup(StringToAnsi(IntToStr(FModel.ID))));
end;

procedure ISchemeRenderer.SetViewedBlock(const Value: TSchemeBlock);
var
  old_pos: TVec2f;
begin
  if FViewedBlock <> nil then
    FViewportPositions.AddOrReplaceValue(FViewedBlock, GetViewPortPosition);
  if FViewedBlock <> Value then
    SaveThemeCurrentBlock;
  FViewedBlock := Value;
  DoLoadBlock;
  if Assigned(FOnEnterToBlock) then
    FOnEnterToBlock(Self);
  if FViewportPositions.find(FViewedBlock, old_pos) then
    SetViewPortPosition(old_pos);
  FEventAfterLoadLevel.Send(FViewedBlock);
end;

class destructor ISchemeRenderer.Destroy;
begin
  FreeAndNil(VisualClasses);
  FreeAndNil(FListVisualClasses);
end;

procedure ISchemeRenderer.Undo;
begin

end;

procedure ISchemeRenderer.UpdateInSpaceTree(Item: ISchemeItemVisual);
begin
  if FSpaceTree.Selecting then
    FNeedUpdate.Add(Item)
  else
    DoUpdateInSpaceTree(Item);
end;

procedure ISchemeRenderer.DeleteSchemeItem(const SchemarioItem: ISchemeItemVisual);
var
  ChangeData: TChangeData;
begin
  ChangeData.Shape := SchemarioItem.FSchemeData;
  ChangeData.CodeChange := TCodeChange.ccDelete;
  OnChangeItem(@ChangeData);
  { TODO: history; !!! not must merely remove from model, need to do recurcieve if
    we will be save history }
  SchemarioItem.FSchemeData.Free;
  // FModel.Remove(SchemarioItem.FSchemeData);
  Theme.DeleteGroup(SchemarioItem.URL);
  Modified := true;
end;

procedure ISchemeRenderer.DeleteSelected;
var
  it_gr: ISchemeItemVisual;
  mdf: boolean;
begin
  mdf := FListSelected.Count > 0;
  while Assigned(FListSelected.ItemListFirst) do
  begin
    it_gr := FListSelected.ItemListFirst.Item;
    FModel.DeleteSchemeItem(it_gr.FSchemeData);
  end;
  if mdf then
    Modified := true;
end;

destructor ISchemeRenderer.Destroy;
begin
  ClearHistory;
  FModel.Free;
  FNeedUpdate.Free;
  FHistory.Free;
  FListSelected.Free;
  FListSelectedNoVisual.Free;
  AcceptingSchemeRegions.Free;
  Theme.Free;
  FViewportPositions.Free;
  FEventAfterLoadLevel := nil;
  inherited;
end;

procedure ISchemeRenderer.DoChangePosition(const NewPosition: TVec2d);
begin
  while FNeedUpdate.Count > 0 do
    DoUpdateInSpaceTree(FNeedUpdate.Pop);
end;

procedure ISchemeRenderer.DoLoadBlock;
var
  i: int32;
begin
  Loading := true;
  try
    ResetSelection;
    FSpaceTree.Clear;
    SetViewPortPosition(vec2(0.0, 0.0));
    for i := 0 to FViewedBlock.ChildrenCount - 1 do
      CreateViewOfShape(FViewedBlock.Children[i]);
    CheckBoundary;
  finally
    Loading := false;
  end;
end;

procedure ISchemeRenderer.DoUpdateInSpaceTree(Item: ISchemeItemVisual);
var
  Pos: TVec2f;
  s: TVec2f;
begin
  { in space tree all positions are absolute for the current view block }

  { was changed Item.Position on Item.FSchemeData.Position }
  Pos := Item.FSchemeData.Position * FScale;
  s.X := Item.FSchemeData.Width * FScale;
  s.Y := Item.FSchemeData.Height * FScale;
  { update data in the space tree }
  if Item.NodeSpaceTree <> nil then
    FSpaceTree.UpdatePosition(Item.NodeSpaceTree, Pos.X, Pos.Y, s.X, s.Y)
  else
    FSpaceTree.Add(Item, Pos.X, Pos.Y, s.X, s.Y, Item.NodeSpaceTree);
end;

procedure ISchemeRenderer.DragDropItem(Item: ISchemeItemVisual);
var
  it: TListItemDual.PListItem;
begin
  if (FDragOver <> nil) and (FDragOver.FSchemeData.IsContainer) then
    Item.Drop(FDragOver.FSchemeData)
  else if (Item.Parent.View <> nil) and ISchemeItemVisual(Item.Parent.View).Selected then
    Item.Drop(Item.Parent)
  else
    Item.Drop(FViewedBlock);

  { hide and free if a parent level was changed }
  if Item.FSchemeData.ParentLevel <> FViewedBlock then
  begin
    HideChildrenOfItem(Item.FSchemeData);
    FSpaceTree.Remove(Item.NodeSpaceTree);
  end;

  if FIsDragItems then
  begin
    it := FListSelected.ItemListFirst;
    while it <> nil do
    begin
      if it.Item.IsDrag and it.Item.Visible then
        break;
      it := it.Next;
    end;

    { was it found a visible item? }
    if it = nil then
      EndDragItems;
  end;
end;

procedure ISchemeRenderer.DragItem(Item: ISchemeItemVisual);
var
  it: TListItemDual.PListItem;
  it_v: ISchemeItemVisual;
  delta: TVec2f;
begin
  Item.Drag;
  if DragFirst = nil then
    DragFirst := Item
  else if DragFirst = Item then
  begin
    delta := Item.Position - Item.FBeginDragPos;
    DragFirst := nil;
    it := FListSelectedNoVisual.ItemListLast;
    while Assigned(it) do
    begin
      it_v := it.Item;
      it := it.Prev;
      if it_v.IsDrag then
      begin
        it_v.Position := (it_v.FBeginDragPos + delta); //
        it_v.Drag;
      end;
    end;
  end;
end;

procedure ISchemeRenderer.EndDragItems;
var
  p: TVec2i;
  s: TPoint;
  it: TListItemDual.PListItem;
  vi: ISchemeItemVisual;
begin

  if not FIsDragItems then
    exit;

  FIsDragItems := false;

  if Assigned(FDragOver) then
  begin
    FDragOver.EndDragOver;
    FDragOver := nil;
  end;

  it := FListSelectedNoVisual.ItemListLast;
  while Assigned(it) do
  begin
    vi := it.Item;
    it := it.Prev;
    CheckListPos(vi);
    { in the time EndDragItems can be invoked again, that is why here is
      protection }
    if vi.IsDrag then
      DragDropItem(vi);
  end;

  while AcceptingSchemeRegions.Count > 0 do
  begin
    DropedToSchemeRegion := AcceptingSchemeRegions.Root.Key;
    AcceptingSchemeRegions.Remove(DropedToSchemeRegion);
    if FDrawGrid then
    begin
      { align on grid }
      s := DropedToSchemeRegion.GetAlignedOnGridSize;
      DropedToSchemeRegion.Resize(s.X, s.Y);
      p := GetAlignedOnGridSize(DropedToSchemeRegion.Position);
      DropedToSchemeRegion.Position := p;
    end
    else
    begin
      { update in the space tree accepting region }
      UpdateInSpaceTree(DropedToSchemeRegion);
      { redraw }
      DropedToSchemeRegion.Draw;
    end;
    if (DropedToSchemeRegion.Position.X < 0) then
      DropedToSchemeRegion.Position := vec2(0, DropedToSchemeRegion.Position.Y);
    if (DropedToSchemeRegion.Position.Y < 0) then
      DropedToSchemeRegion.Position := vec2(DropedToSchemeRegion.Position.X, 0);
  end;

  DropedToSchemeRegion := nil;
  CheckBoundary;
  Modified := true;
end;

procedure ISchemeRenderer.EndResize(Item: ISchemeItemVisual);
begin
  FIsResizing := false;
  Item.EndResize;
  Modified := true;
end;

function ISchemeRenderer.FindClassItem(ClassSchemItem: TSchemeShapeClass): TSchemeShape;
var
  it: TListSchemeItems.PListItem;
begin
  it := FModel.ListItems.ItemListFirst;
  while Assigned(it) do
  begin
    if it.Item is ClassSchemItem then
      exit(it.Item);
    it := it.Next;
  end;
  Result := nil;
end;

function ISchemeRenderer.FindInRect(X, Y, Width, Height: BSFloat; ClassSchemItem: TSchemeShapeClass; ExceptItem: ISchemeItemVisual; ExceptSchemeLinks: boolean;
  ExceptDragged: boolean): ISchemeItemVisual;
var
  l: TListNodes;
  i: int32;
  Pos: TVec2f;
  rect, ovrl, c_rect: TRectBSf;
  square_rect: BSFloat;
  ovrl_s: BSFloat;
  Selected: ISchemeItemVisual;
begin
  l := nil;
  rect := RectBS(X, Y, Width, Height);
  FSpaceTree.SelectData(X, Y, Width, Height, l);
  square_rect := 0;
  Result := nil;
  for i := 0 to l.Count - 1 do
  begin
    Selected := (l.Items[i].BB.TagPtr);
    if ((ClassSchemItem <> nil) and not(Selected.FSchemeData is ClassSchemItem)) or (Selected = ExceptItem) or (ExceptSchemeLinks and (Selected.SchemeData is TSchemeLink)
      ) or (ExceptDragged and Selected.IsDrag) then
      continue;
    Pos := Selected.FSchemeData.Position * FScale;
    c_rect := RectBS(Pos.X, Pos.Y, Selected.FSchemeData.Width * FScale, Selected.FSchemeData.Height * FScale);
    ovrl := RectOverlap(rect, c_rect);
    ovrl_s := ovrl.Width * ovrl.Height;
    if (ovrl_s > square_rect) or ((ovrl_s = square_rect) and (Result <> nil) and (Selected.FSchemeData.IsAncestor(Result.FSchemeData))) then
    begin
      square_rect := ovrl_s;
      Result := Selected;
    end;
  end;
end;

function ISchemeRenderer.FindRectContainer(X, Y, Width, Height: BSFloat; ClassContainer: TSchemeShapeClass; ExceptItem: ISchemeItemVisual): ISchemeItemVisual;
var
  l: TListNodes;
  i: int32;
  Pos: TVec2f;
  rect, ovrl, c_rect: TRectBSf;
  square_rect: BSFloat;
  ovrl_s: BSFloat;
  Selected: ISchemeItemVisual;
begin
  l := nil;
  rect := RectBS(X, Y, Width, Height);
  FSpaceTree.SelectData(X, Y, Width, Height, l);
  square_rect := 0;
  Result := nil;
  for i := 0 to l.Count - 1 do
  begin
    Selected := (l.Items[i].BB.TagPtr);
    if (Selected = ExceptItem) or (not Selected.FSchemeData.IsContainer) or ((ClassContainer <> nil) and not(Selected.FSchemeData is ClassContainer)) then
      continue;
    Pos := Selected.FSchemeData.Position * FScale;
    c_rect := RectBS(Pos.X, Pos.Y, Selected.FSchemeData.Width * FScale, Selected.FSchemeData.Height * FScale);
    ovrl := RectOverlap(rect, c_rect);
    ovrl_s := ovrl.Width * ovrl.Height;
    if (ovrl_s > square_rect) or ((ovrl_s = square_rect) and (Result <> nil) and (Selected.FSchemeData.IsAncestor(Result.FSchemeData))) then
    begin
      square_rect := ovrl_s;
      Result := Selected;
    end;
  end;
end;

function ISchemeRenderer.GetAlignedOnGridPosition(const Point: TPoint): TPoint;
var
  m: TPoint;
begin
  m.X := Point.X mod FGridStep;
  m.Y := Point.Y mod FGridStep;
  if m.X >= FGridStep shr 1 then
    Result.X := ((Point.X div FGridStep) + 1) * FGridStep
  else
    Result.X := (Point.X div FGridStep) * FGridStep;
  if m.Y >= FGridStep shr 1 then
    Result.Y := ((Point.Y div FGridStep) + 1) * FGridStep
  else
    Result.Y := (Point.Y div FGridStep) * FGridStep;
end;

function ISchemeRenderer.GetAlignedOnGridSize(const Point: TPoint): TPoint;
var
  m: TPoint;
begin
  m.X := Point.X mod FGridStep;
  m.Y := Point.Y mod FGridStep;
  if m.X > FGridStep shr 1 then
    Result.X := ((Point.X div FGridStep) + 1) * FGridStep
  else
    Result.X := (Point.X div FGridStep) * FGridStep;
  if m.Y > FGridStep shr 1 then
    Result.Y := ((Point.Y div FGridStep) + 1) * FGridStep
  else
    Result.Y := (Point.Y div FGridStep) * FGridStep;
end;

function ISchemeRenderer.GetAlignedOnGridPosition(const Pos: TVec2f): TVec2f;
var
  p: TPoint;
begin
  p := GetAlignedOnGridPosition(Point(round(Pos.X), round(Pos.Y)));
  Result := vec2(p.X, p.Y);
end;

function ISchemeRenderer.GetAlignedOnGridSize(const Size: TVec2i): TVec2i;
var
  p: TPoint;
begin
  p := GetAlignedOnGridSize(Point(Size.X, Size.Y));
  Result := vec2(p.X, p.Y);
end;

function ISchemeRenderer.GetBlockOrSchemeRegion(X, Y: BSFloat; ParentSchemeRegionMandatory: boolean; const ClientSize: TVec2f): TSchemeShape;
var
  it: ISchemeItemVisual;
begin
  it := FindInRect(FScale * X, FScale * Y, FScale * ClientSize.X, FScale * ClientSize.Y, TSchemeRegion, nil);
  if (it = nil) then
  begin
    if (ParentSchemeRegionMandatory) and (FModel.FindParentRegion(ViewedBlock) = nil) then
    begin
      it := CreateSchemeItem(ViewedBlock, TSchemeRegion, '');
      it.Resize(round(ClientSize.X) + REG_BORDER_WIDTH * 4, round(ClientSize.Y) + REG_BORDER_WIDTH * 4);
      it.Position := vec2(X - REG_BORDER_WIDTH * 2 - ClientSize.X * 0.5, Y - REG_BORDER_WIDTH * 2 - ClientSize.Y * 0.5);
      Result := it.SchemeData;
    end
    else
    begin
      Result := ViewedBlock;
    end;
  end
  else if (ParentSchemeRegionMandatory) and (not(it.FSchemeData is TSchemeRegion) and (FModel.FindParentRegion(it.FSchemeData) = nil)) then
  begin
    it := CreateSchemeItem(it.FSchemeData.ParentLevel, TSchemeRegion, '');
    it.Resize(round(ClientSize.X) + REG_BORDER_WIDTH * 4, round(ClientSize.Y) + REG_BORDER_WIDTH * 4);
    it.Position := vec2(X - REG_BORDER_WIDTH * 2 - ClientSize.X * 0.5, Y - REG_BORDER_WIDTH * 2 - ClientSize.Y * 0.5);
    Result := it.SchemeData;
  end
  else
    Result := it.SchemeData;
end;

class function ISchemeRenderer.GetClass(Index: int32): ISchemeItemVisualClass;
begin
  Result := FListVisualClasses.Items[Index];
end;

class function ISchemeRenderer.GetClassVisualItem(const ClassNameSchemItem: string): ISchemeItemVisualClass;
var
  h: uint32;
begin
  h := GetHashSedgwickS(ClassNameSchemItem);
  VisualClasses.find(h, Result);
end;

function ISchemeRenderer.GetColorGrid: TGuiColor;
begin
  Result := ColorFloatToByte(FGridColor).Value;
end;

function ISchemeRenderer.GetColorGrid2: TGuiColor;
begin
  Result := ColorFloatToByte(FGridColor2).Value;
end;

function ISchemeRenderer.GetColorScrollBar: TColor4f;
begin
  Result := BS_CL_GRAY;
end;

function ISchemeRenderer.GetCountSchemeShapes: int32;
begin
  Result := FModel.ListItems.Count;
end;

function ISchemeRenderer.GetCountSelected: int32;
begin
  Result := FListSelected.Count;
end;

function ISchemeRenderer.GetFileScheme: string;
begin
  Result := FModel.FileScheme;
end;

function ISchemeRenderer.GetVisItem(ID: int32): ISchemeItemVisual;
var
  si: TSchemeShape;
begin
  si := FModel.GetSchemeItemFromID(ID);
  if Assigned(si) and Assigned(si.View) then
    Result := ISchemeItemVisual(si.View)
  else
    Result := nil;
end;

function ISchemeRenderer.HasRedo: boolean;
begin
  Result := false;
end;

function ISchemeRenderer.HasUndo: boolean;
begin
  Result := false;
end;

procedure ISchemeRenderer.HideChildrenOfItem(Ancestor: TSchemeShape);
var
  i: int32;
  sch: TSchemeShape;
begin
  for i := 0 to Ancestor.ChildrenCount - 1 do
  begin
    sch := Ancestor.Children[i];
    if sch.View = nil then
      continue;
    FSpaceTree.Remove(ISchemeItemVisual(sch.View).NodeSpaceTree);
  end;
end;

function ISchemeRenderer.GetItem(X, Y: BSFloat; ExcepTSchemeLink: boolean): ISchemeItemVisual;
begin
  Result := FindInRect(X, Y, 1, 1, TSchemeShape, nil, ExcepTSchemeLink);
end;

function ISchemeRenderer.GetModified: boolean;
begin
  Result := FModel.Modified;
end;

function ISchemeRenderer.GetSchemeShape(ID: int32): TSchemeShape;
begin
  Result := FModel.GetSchemeItemFromID(ID);
end;

function ISchemeRenderer.GetSelectedOnlyLinks: boolean;
var
  it: TListItemDual.PListItem;
begin
  it := FListSelected.ItemListFirst;
  while Assigned(it) do
  begin
    if not(it.Item.FSchemeData is TSchemeLink) then
      exit(false);
    it := it.Next;
  end;
  Result := FListSelected.Count > 0;
end;

class constructor ISchemeRenderer.Create;
begin
  VisualClasses := TBinTreeTemplate<uint32, ISchemeItemVisualClass>.Create(@Uint32Cmp);
  FListVisualClasses := TListVec<ISchemeItemVisualClass>.Create;
end;

function ISchemeRenderer.DoesTheLinkNeedDraw(Link: TSchemeLink): boolean;
begin
  { are in one block? }
  if Link.Parent.ParentLevel = Link.ToLink.ParentLevel then
    exit(Link.ToLink.ParentLevel = FViewedBlock);
  { different blocks }
  if Link.Parent.Parent.ParentLevel = FViewedBlock then
  begin
    Result := (Link.ToLink.ParentLevel = FViewedBlock) or (Link.ToLink.Parent.ParentLevel = FViewedBlock);
  end
  else if Link.Parent.ParentLevel = FViewedBlock then
  begin
    Result := (Link.ToLink.ParentLevel = FViewedBlock) or (Link.ToLink.Parent.ParentLevel = FViewedBlock);
  end
  else
    Result := false;
end;

procedure ISchemeRenderer.MouseMove(X, Y: int32);
var
  it: ISchemeItemVisual;
begin
  if FIsDragItems then
  begin
    it := FindInRect(FSpaceTree.CurrentViewPort.x_min + X, FSpaceTree.CurrentViewPort.y_min + Y, 1, 1, nil, nil, true, true);
    if Assigned(it) then
    begin
      if Assigned(FDragOver) and (it <> FDragOver) then
      begin
        FDragOver.EndDragOver;
        FDragOver := nil;
      end;
      if FDragOver = nil then
      begin
        FDragOver := it;
        FDragOver.BeginDragOver;
      end;
    end
    else if FDragOver <> nil then
    begin
      FDragOver.EndDragOver;
      FDragOver := nil;
    end;
  end;
end;

procedure ISchemeRenderer.MouseUp(X, Y: int32);
var
  it: TListItemDual.PListItem;
begin
  if ToRendererDblClick then
  begin
    ToRendererDblClick := false;
    BanSelect := false;
  end;

  if FIsDragItems then
  begin
    // EndDragItems;
    { check if all selected items hided then we will not accept an event about
      drop from view because of do not have any visual part for generate the
      appropriate event; }
    it := FListSelected.ItemListFirst;
    while Assigned(it) do
    begin
      if it.Item.Visible then
        break;
      it := it.Next;
    end;
    { was it found a visible item? }
    if it = nil then
      EndDragItems;
  end;
end;

procedure ISchemeRenderer.MoveSchemeRegionChilds(SchemeRegion: ISchemeItemVisual);
var
  i: int32;
  ch: TSchemeShape;
  delta: TVec2f;
begin
  delta := SchemeRegion.Position - SchemeRegion.FBeginDragPos;
  for i := 0 to SchemeRegion.FSchemeData.ChildrenCount - 1 do
  begin
    ch := SchemeRegion.FSchemeData.Children[i];
    if (ch.View = nil) or ISchemeItemVisual(ch.View).Selected then
      continue;
    ISchemeItemVisual(ch.View).Position := ISchemeItemVisual(ch.View).FBeginDragPos + delta;
    ISchemeItemVisual(ch.View).Drag;
    if ch is TSchemeRegion then
      MoveSchemeRegionChilds(ISchemeItemVisual(ch.View));
  end;
end;

procedure ISchemeRenderer.MoveToSelected(DeltaX, DeltaY: int32);
var
  it: TListItemDual.PListItem;
  reg, eng: ISchemeItemVisual;
begin
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    it.Item.BeginDrag;
    if (it.Item.Parent.View <> nil) and (it.Item.Parent is TSchemeRegion) and not(AcceptingSchemeRegions.find(ISchemeItemVisual(it.Item.Parent.View), eng)) then
    begin
      AcceptingSchemeRegions.Add(ISchemeItemVisual(it.Item.Parent.View), ISchemeItemVisual(it.Item.Parent.View));
    end
    else if (it.Item.FSchemeData.View <> nil) and (it.Item.FSchemeData is TSchemeRegion) and not(AcceptingSchemeRegions.find(it.Item, reg)) then
    begin
      AcceptingSchemeRegions.Add(it.Item, it.Item);
    end;
    it.Item.MoveTo(DeltaX, DeltaY);
    DragItem(it.Item);
    it := it.Next;
  end;
  it := FListSelected.ItemListFirst;
  while it <> nil do
  begin
    it.Item.Drop(it.Item.Parent);
    it := it.Next;
  end;
end;

end.
