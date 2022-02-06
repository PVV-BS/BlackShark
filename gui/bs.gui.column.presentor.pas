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

unit bs.gui.column.presentor;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.align
  , bs.events
  , bs.collections
  , bs.geometry
  , bs.canvas
  , bs.scene
  , bs.animation
  , bs.strings
  , bs.gui.base
  , bs.gui.forms
  , bs.gui.themes
  , bs.gui.themes.primitives
  , bs.gui.checkbox
  ;

const
  CELL_HEIGHT_DEFAULT = 16;
  COLUMN_WIDTH_DEFAULT = 50;
  LEFT_OFFCET_DEFAULT = 3;
  COLUMN_LAYER = 30;

type

  IColumnPresentor = class;
  IColumnPresentorClass = class of IColumnPresentor;

  IColumnCellPresentor = class abstract
  private
    type
      TCellState = (csNone, csMouseOver, csSelected, csMouseOverAndSelected);
  private
    FBody: TRectangle;
    FBorder: TRectangle;
    MouseEnterEventObserver: IBMouseEnterEventObserver;
    MouseLeaveEventObserver: IBMouseLeaveEventObserver;
    MouseDownEventObserver: IBMouseDownEventObserver;
    //KeyDownEventObserver: IBKeyEventObserver;
    AnimationEnter: IBAnimationLinearFloat;
    AniObserverEnter: IBAnimationLinearFloatObsrv;
    FSelected: boolean;
    //FOnKeyDown: TKeyEventNotify;
    FOnMouseDown: TMouseEventNotify;
    FIndex: int32;
    FColumn: IColumnPresentor;
    CellState: TCellState;
    FOnMouseEnter: TMouseEventNotify;
    FOnMouseLeave: TMouseEventNotify;
    FIsMouseOver: boolean;
    procedure OnAnimateOpacity(const Value: BSFloat);
  protected
    procedure MouseEnter(const AData: BMouseData); virtual;
    procedure MouseLeave(const AData: BMouseData); virtual;
    procedure MouseDown(const AData: BMouseData); virtual;
    //procedure KeyDown(const AData: BKeyData); virtual;
    procedure SetSelected(const Value: boolean); virtual;
    procedure DoChangeData; virtual;
    procedure Align; virtual; abstract;
  public
    constructor Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    procedure Resize(AWidth, AHeight: BSFloat); virtual;
    function DataToString: string; virtual; abstract;
    procedure DataFromString(const AValue: string); virtual; abstract;
    property Body: TRectangle read FBody;
    property Selected: boolean read FSelected write SetSelected;
    property IsMouseOver: boolean read FIsMouseOver;
    property Column: IColumnPresentor read FColumn;
    { index in viewport only }
    property Index: int32 read FIndex write FIndex;
    property OnMouseDown: TMouseEventNotify read FOnMouseDown write FOnMouseDown;
    property OnMouseEnter: TMouseEventNotify read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TMouseEventNotify read FOnMouseLeave write FOnMouseLeave;
    //property OnKeyDown: TKeyEventNotify read FOnKeyDown write FOnKeyDown;
  end;

  { TBColumnCellPresentor<T>
    Column item presentor; it need to create when shown;
  }

  TBColumnCellPresentor<T> = class abstract(IColumnCellPresentor)
  protected
    function GetData: T; virtual; abstract;
    procedure SetData(const AValue: T); virtual;
  public
    constructor Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor); virtual;
    property Data: T read GetData write SetData;
  end;

  {$M+}
  TColumnHeader = class(TGUIProperties)
  private
    FOwner: IColumnPresentor;
    FParent: TCanvasObject;
    FCaptionColor: TGuiColor;
    FColor: TGuiColor;
    FFontName: string;
    FCaption: string;
    FVisible: boolean;
    FHeader: TRectangle;
    FHeaderCaption: TCanvasText;
    FBottomLine: TLine;
    FSize: TVec2f;
    FOnChangeVisibleEvent: IBEmptyEvent;
    FOnMouseDown: TMouseEventNotify;
    MouseDownEventObserver: IBMouseDownEventObserver;
    procedure SetVisible(AValue: boolean);
    procedure SetCaption(const Value: string);
    procedure SetGuiColor(const Value: TGuiColor);
    procedure SetFontName(const Value: string);
    procedure SetCaptionColor(const Value: TGuiColor);
    procedure UpdateCaptionPosition;
    procedure CreateHeader;
    procedure BuildLine;
    procedure FreeHeader;
    procedure SetSize(const Value: TVec2f);
    property OnMouseDown: TMouseEventNotify read FOnMouseDown write FOnMouseDown;
  protected
    function GetOwner: TGUIProperties; override;
    procedure MouseDown(const AData: BMouseData); virtual;
    // it is assigned if Visible is true only
  public
    constructor Create(AOwner: IColumnPresentor; AParent: TCanvasObject);
    destructor Destroy; override;
    procedure Hide;
    procedure Show;
    property OnChangeVisibleEvent: IBEmptyEvent read FOnChangeVisibleEvent;
    property Size: TVec2f read FSize write SetSize;
    property Header: TRectangle read FHeader;
  published
    property Visible: boolean read FVisible write SetVisible;
    property Caption: string read FCaption write SetCaption;
    property Color: TGuiColor read FColor write SeTGuiColor;
    property CaptionColor: TGuiColor read FCaptionColor write SetCaptionColor;
    property FontName: string read FFontName write SetFontName;
  end;
  {$M-}

  TCellDataChangeNotify = procedure (ACell: IColumnCellPresentor) of object;
  TCellDataMouseNotify = procedure (ACell: IColumnCellPresentor; const AMouseData: BMouseData) of object;
  TCellDataKeyNotify = procedure (ACell: IColumnCellPresentor; const AKeyData: BKeyData) of object;
  TControllerUpdateRectColumnNotify = procedure (AColumn: IColumnPresentor; const OldRect: TRectBSd) of object;

  IColumnPresentor = class abstract
  private
    _Node: PNodeSpaceTree;
    FOffsetX: BSFloat;
    FRect: TRectBSd;
    FIndex: int32;
    FOnUpdateRect: TControllerUpdateRectColumnNotify;
    FShowBodyCells: boolean;
    FOnCellMouseEnter: TCellDataMouseNotify;
    FOnCellMouseLeave: TCellDataMouseNotify;
    FOnCellShow: TBControlNotify;
    FSplitter: TLine;
    FSplitterInvisible: TLine;
    SplitterMouseEnterObsrv: IBMouseDownEventObserver;
    SplitterMouseLeaveObsrv: IBMouseDownEventObserver;
    SplitterMouseDownObsrv: IBMouseDownEventObserver;
    MouseMoveAfterSplitterDownObsrv: IBMouseDownEventObserver;
    SplitterMouseUpObsrv: IBMouseDownEventObserver;
    MouseDownPos: TVec2f;
    FVisible: boolean;
    FOnChangeData: TCellDataChangeNotify;
    FAlign: TObjectAlign;
    FShowSplitter: boolean;
    FLastCellsHeight: BSFloat;
    function GetCell(Index: int32): IColumnCellPresentor;
    procedure SetShudderY(AValue: BSFloat);
    procedure SetCellHeight(AValue: BSFloat);
    procedure CellMouseDown(ACell: TObject; const AMouseData: BMouseData);
    procedure CellMouseEnter(ACell: TObject; const AMouseData: BMouseData);
    procedure CellMouseLeave(ACell: TObject; const AMouseData: BMouseData);
    //procedure CellKeyDown(ACell: TObject; const AKeyData: BKeyData);
    procedure ColumnMouseDown(AColumn: TObject; const AMouseData: BMouseData);
    function GetCountCell: int32;
    procedure SetOffsetX(const Value: BSFloat);
    procedure SetRect(const Value: TRectBSd);
    function GetWidth: BSFloat;
    procedure SetWidth(const Value: BSFloat);
    procedure SetShowBodyCells(const Value: boolean);
    procedure OnSplitterMouseDown(const AData: BMouseData);
    procedure OnSplitterMouseMoveAfterDown(const AData: BMouseData);
    procedure OnSplitterMouseUp(const AData: BMouseData);
    procedure OnSplitterMouseEnter(const AData: BMouseData);
    procedure OnSplitterMouseLeave(const AData: BMouseData);
    procedure CreateSplitter;
    procedure FreeSplitter;
    procedure SetAlign(const Value: TObjectAlign);
    procedure SetShowSplitter(const Value: boolean);
  protected
    FPosition: int64;
    FLastCount: int32;
    FShudderY: BSFloat;
    FHeader: TColumnHeader;
    FCellHeight: BSFloat;
    FCellHeightReal: BSFloat;
    FCellLeftOffset: BSFloat;
    FOnCellMouseDown: TCellDataMouseNotify;
    FOnColumnMouseDown: TBControlNotify;
    FOwner: TBScrolledWindow;
    FParent: TCanvasObject;
    ListCells: TListVec<IColumnCellPresentor>;
    procedure SetCellLeftOffset(AValue: BSFloat);
    procedure DoResizeCells;
    procedure DoUpdateAlignCells;
    function CellCreate(AIndex: int32): IColumnCellPresentor; virtual; abstract;
    function DoCreateCell(AIndex: int32): IColumnCellPresentor;
    procedure UpdatePosition(ACell: IColumnCellPresentor; AIndex: int32); overload; //inline;
    procedure UpdatePosition(AIndex: int32); overload; //inline;
  public
    constructor Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject); virtual;
    destructor Destroy; override;
    procedure UpdatePosSplitter;
    procedure UpdateCellHeightReal;
    procedure BuildSplitter;
    procedure UpdateViewpot(APosition: int64; ACount: int32); overload;
    procedure UpdateViewpot; overload;
    { update data of all cells }
    procedure Refresh; virtual; abstract;
    procedure Clear;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure DeleteCell(var Cell: IColumnCellPresentor); overload;
    procedure DeleteCell(AIndex: int32); overload;
    procedure ClearSelection;
    property Cell[Index: int32]: IColumnCellPresentor read GetCell;
    property Owner: TBScrolledWindow read FOwner;
    property Header: TColumnHeader read FHeader;
    property Splitter: TLine read FSplitter;
    //property Body: TRectangle read FBody;
    property CellHeight: BSFloat read FCellHeight write SetCellHeight;
    property CellLeftOffset: BSFloat read FCellLeftOffset write SetCellLeftOffset;
    property Width: BSFloat read GetWidth write SetWidth;
    { the absolute column area over data }
    property Rect: TRectBSd read FRect write SetRect;
    { position a view part in viewport }
    property OffsetX: BSFloat read FOffsetX write SetOffsetX;
    property ShudderY: BSFloat read FShudderY write SetShudderY;
    property Visible: boolean read FVisible;
    property Align: TObjectAlign read FAlign write SetAlign;

    property ColumnHeader: TColumnHeader read FHeader;
    property OnCellMouseDown: TCellDataMouseNotify read FOnCellMouseDown write FOnCellMouseDown;
    property OnCellMouseEnter: TCellDataMouseNotify read FOnCellMouseEnter write FOnCellMouseEnter;
    property OnCellMouseLeave: TCellDataMouseNotify read FOnCellMouseLeave write FOnCellMouseLeave;
    property OnColumnMouseDown: TBControlNotify read FOnColumnMouseDown write FOnColumnMouseDown;
    //property OnCellKeyDown: TCellDataKeyNotify read FOnCellKeyDown write FOnCellKeyDown;
    property OnCellShow: TBControlNotify read FOnCellShow write FOnCellShow;
    property OnUpdateRect: TControllerUpdateRectColumnNotify read FOnUpdateRect write FOnUpdateRect;
    property OnChangeData: TCellDataChangeNotify read FOnChangeData write FOnChangeData;
    { count visible cells in viewport }
    property CountCell: int32 read GetCountCell;
    { position of viewport over list of cells (index)  }
    property Position: int64 read FPosition;
    { index of the column }
    property Index: int32 read FIndex write FIndex;
    property ShowBodyCells: boolean read FShowBodyCells write SetShowBodyCells;
    property ShowSplitter: boolean read FShowSplitter write SetShowSplitter;
  end;

  // getter data for visualization
  TDataGetter<T> = function (Sender: IColumnPresentor; ACellIndex: int64; out AData: T): boolean of object;

  { TBColumnPresentor<T>
    A presentor of T; add cell only for visual data; we need to do the class for
    generic type (not direct in IColumnPresentor<T>) because fpc cann't create right nested
    generics: https://bugs.freepascal.org/view.php?id=25678
   }

  TBColumnPresentor<T> = class abstract(IColumnPresentor)
  public
    type
      TBCellPresentor = TBColumnCellPresentor<T>;
  protected
    FDataGetter: TDataGetter<T>;
  public
    constructor Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject); override;
    procedure Refresh; override;
  end;

  { TBCellPresentorString }

  TBCellPresentorString = class(TBColumnCellPresentor<string>)
  private
    FText: TCanvasText;
  protected
    function GetData: string; override;
    procedure SetData(const AValue: string); override;
    procedure Align; override;
  public
    constructor Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor); override;
    destructor Destroy; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DataToString: string; override;
    procedure DataFromString(const AValue: string); override;
  end;

  { TBCellPresentorCheckbox }

  TBCellPresentorCheckbox = class(TBColumnCellPresentor<string>)
  private
    FCheckBox: TBCheckBoxCustom;
    procedure OnChangeCheck(ASender: TObject);
  protected
    function GetData: string; override;
    procedure SetData(const AValue: string); override;
    procedure Align; override;
  public
    constructor Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor); override;
    destructor Destroy; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DataToString: string; override;
    procedure DataFromString(const AValue: string); override;
  end;

  { TBCellPresentorColor }

  TBCellPresentorColor = class(TBColumnCellPresentor<TGuiColor>)
  private
    const
      DEFAULT_TEXT_INDENT = 5;
  private
    ColorRect: TRectangle;
    //Text: TCanvasText;
  protected
    function GetData: TGuiColor; override;
    procedure SetData(const AValue: TGuiColor); override;
    procedure Align; override;
  public
    constructor Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor); override;
    destructor Destroy; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DataToString: string; override;
    procedure DataFromString(const AValue: string); override;
  end;

  { TBColumnPresentorString }

  TBColumnPresentorString = class(TBColumnPresentor<string>)
  private
    FColorText: TGuiColor;
  protected
    function CellCreate(AIndex: int32): IColumnCellPresentor; override;
  public
    constructor Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject); override;
    property ColorText: TGuiColor read FColorText write FColorText;
  end;

  { TBColumnPresentorCheckbox}

  TBColumnPresentorCheckbox = class(TBColumnPresentor<string>)
  protected
    function CellCreate(AIndex: int32): IColumnCellPresentor; override;
  end;

  { TBColumnPresentorColor }

  TBColumnPresentorColor = class(TBColumnPresentor<TGuiColor>)
  protected
    function CellCreate(AIndex: int32): IColumnCellPresentor; override;
  end;

implementation

uses
    SysUtils
  , bs.graphics
  , bs.config
  , bs.thread
  ;

{ IColumnPresentor }

procedure IColumnPresentor.BuildSplitter;
var
  h: BSFloat;
begin
  if not Visible then
    exit;

  if not FShowSplitter then
  begin
    if Assigned(FSplitter) then
      FreeSplitter;
    exit;
  end;

  if FLastCount > 0 then
  begin
    if not Assigned(FSplitter) then
      CreateSplitter;

    if FHeader.Visible then
      h := FHeader.Header.Height + FCellHeightReal * FLastCount
    else
      h := FCellHeightReal * FLastCount;

    if h < FOwner.ClipObject.Height then
      h := h + FShudderY;

    FSplitter.B := vec2(0.0, h);
  end else
  if FHeader.Visible then
  begin
    if not Assigned(FSplitter) then
      CreateSplitter;
    FSplitter.B := vec2(0.0, FHeader.Header.Height);
  end else
  begin
    FreeSplitter;
    exit;
  end;

  FSplitter.A := vec2(0.0, 0.0);

  FSplitter.Build;

  FSplitterInvisible.A := FSplitter.A;
  FSplitterInvisible.B := FSplitter.B;
  FSplitterInvisible.Build;
  UpdatePosSplitter;
end;

procedure IColumnPresentor.CellMouseDown(ACell: TObject; const AMouseData: BMouseData);
begin
  if Assigned(FOnCellMouseDown) then
    FOnCellMouseDown(IColumnCellPresentor(ACell), AMouseData);
end;

procedure IColumnPresentor.CellMouseEnter(ACell: TObject; const AMouseData: BMouseData);
begin
  if Assigned(FOnCellMouseEnter) then
    FOnCellMouseEnter(IColumnCellPresentor(ACell), AMouseData);
end;

procedure IColumnPresentor.CellMouseLeave(ACell: TObject; const AMouseData: BMouseData);
begin
  if Assigned(FOnCellMouseLeave) then
    FOnCellMouseLeave(IColumnCellPresentor(ACell), AMouseData);
end;

procedure IColumnPresentor.Clear;
var
  i: int32;
begin
  for i := 0 to ListCells.Count - 1 do
  begin
    DeleteCell(i);
  end;
  ListCells.Count := 0;
  FLastCount := 0;
end;

procedure IColumnPresentor.ClearSelection;
var
  cell: IColumnCellPresentor;
  i: int32;
begin
  for i := 0 to ListCells.Count - 1 do
  begin
    cell := ListCells.Items[i];
    if Assigned(cell) then
      cell.Selected := false;
  end;
end;

procedure IColumnPresentor.ColumnMouseDown(AColumn: TObject; const AMouseData: BMouseData);
begin
  if Assigned(FOnColumnMouseDown) then
    FOnColumnMouseDown(AColumn);
end;

constructor IColumnPresentor.Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject);
begin
  FShowSplitter := true;
  FOwner := AOwner;
  ListCells := TListVec<IColumnCellPresentor>.Create;
  FCellHeight := CELL_HEIGHT_DEFAULT;
  FCellHeightReal := round(FCellHeight * FOwner.Canvas.Scale);
  FCellLeftOffset := LEFT_OFFCET_DEFAULT;
  FParent := AParent;
  {FBody := TRectangle.Create(AParent.Canvas, AParent);
  FBody.Fill := true;
  FBody.Size := vec2(AParent.Width, AParent.Height);
  FBody.Data.Interactive := false;
  FBody.Data.Opacity := 0.4;
  FParent := FBody;   }
  FHeader := TColumnHeader.Create(Self, AParent);
  FHeader.OnMouseDown := ColumnMouseDown;
end;

procedure IColumnPresentor.CreateSplitter;
var
  cl: TColor4f;
begin
  cl := ColorByteToFloat(FHeader.Color, true)*1.3;
  cl.w := 1;
  FSplitter := TLine.Create(FParent.Canvas, FParent);
  FSplitter.WidthLine := 1.0;
  FSplitter.Color := cl;
  FSplitter.Data.Interactive := false;
  FSplitter.Layer2d := COLUMN_LAYER + 3;
  FSplitter.BanScalableMode := true;

  FSplitterInvisible := TLine.Create(FParent.Canvas, FSplitter);
  FSplitterInvisible.WidthLine := 6;
  FSplitterInvisible.Data.DragResolve := false;
  FSplitterInvisible.Data.Opacity := 0.0;
  FSplitterInvisible.BanScalableMode := true;

  SplitterMouseEnterObsrv := FSplitterInvisible.Data.EventMouseEnter.CreateObserver(GUIThread, OnSplitterMouseEnter);
  SplitterMouseLeaveObsrv := FSplitterInvisible.Data.EventMouseLeave.CreateObserver(GUIThread, OnSplitterMouseLeave);
  SplitterMouseDownObsrv := FSplitterInvisible.Data.EventMouseDown.CreateObserver(GUIThread, OnSplitterMouseDown);
  SplitterMouseUpObsrv := FSplitterInvisible.Data.EventMouseUp.CreateObserver(GUIThread, OnSplitterMouseUp);
end;

function IColumnPresentor.DoCreateCell(AIndex: int32): IColumnCellPresentor;
begin
  Result := CellCreate(AIndex);
  Result.Resize(FHeader.Size.Width - 1.0, FCellHeight);  //  - FCellLeftOffset*2
  Result.OnMouseDown := CellMouseDown;
  Result.OnMouseEnter := CellMouseEnter;
  Result.OnMouseLeave := CellMouseLeave;
  //Result.OnKeyDown := CellKeyDown;
  UpdatePosition(Result, AIndex);
  if Assigned(FOnCellShow) then
    FOnCellShow(Result);
end;

{procedure IColumnPresentor.DeleteCell(var Cell: IColumnCellPresentor; RecalcPosUnder: boolean);
var
  next: TListColumnCells.PListItem;
begin
  if RecalcPosUnder then
  begin
    next := TListColumnCells.PListItem(Cell._Position).Next;
    while Assigned(next) do
    begin
      UpdatePosition(next.Item, ListCells.Count - 1);
      next := next.Next;
    end;
  end;
  DeleteCell(Cell);
end;  }

procedure IColumnPresentor.DeleteCell(var Cell: IColumnCellPresentor);
begin
  ListCells.Items[Cell.Index] := nil;
  FreeAndNil(Cell);
end;

destructor IColumnPresentor.Destroy;
begin
  Clear;
  FreeSplitter;
  FOwner.SpaceTree.Remove(_Node);
  FHeader.Free;
  ListCells.Free;
  inherited;
end;

function IColumnPresentor.GetCell(Index: int32): IColumnCellPresentor;
begin
  Result := ListCells.Items[Index];
end;

function IColumnPresentor.GetCountCell: int32;
begin
  Result := ListCells.Count;
end;

function IColumnPresentor.GetWidth: BSFloat;
begin
  if FHeader.Visible and Assigned(FHeader.Header) then
    Result := FHeader.Header.Width
  else
    Result := FHeader.Size.Width;
end;

procedure IColumnPresentor.Hide;
begin
  FVisible := false;
  Clear;
  FreeAndNil(FSplitterInvisible);
  FreeAndNil(FSplitter);
  FHeader.Hide;
end;

procedure IColumnPresentor.OnSplitterMouseMoveAfterDown(const AData: BMouseData);
var
  delta: BSFloat;
begin
  delta := (AData.X - MouseDownPos.x);
  MouseDownPos := vec2(AData.X, AData.Y);
  if delta <> 0 then
  begin
    Rect := RectBSd(Rect.X, Rect.Y, Rect.Width + delta, Rect.Height);
  end;
end;

procedure IColumnPresentor.OnSplitterMouseDown(const AData: BMouseData);
var
  cl: TColor4f;
begin
  MouseMoveAfterSplitterDownObsrv := FSplitter.Canvas.Renderer.EventMouseMove.CreateObserver(GUIThread, OnSplitterMouseMoveAfterDown);
  MouseDownPos := vec2(AData.X, AData.Y);
  cl := ColorByteToFloat(FHeader.Color, true)*0.5;
  cl.w := 1;
  FSplitter.Color := cl;
end;

procedure IColumnPresentor.OnSplitterMouseEnter(const AData: BMouseData);
var
  cl: TColor4f;
begin
  if not Assigned(MouseMoveAfterSplitterDownObsrv) then
  begin
    cl := ColorByteToFloat(FHeader.Color, true)*0.5;
    cl.w := 1;
    FSplitter.Color := cl;
  end;
end;

procedure IColumnPresentor.OnSplitterMouseLeave(const AData: BMouseData);
var
  cl: TColor4f;
begin
  if not Assigned(MouseMoveAfterSplitterDownObsrv) then
  begin
    cl := ColorByteToFloat(FHeader.Color, true)*1.3;
    cl.w := 1;
    FSplitter.Color := cl;
  end;
end;

procedure IColumnPresentor.OnSplitterMouseUp(const AData: BMouseData);
var
  delta: BSFloat;
  cl: TColor4f;
begin
  if Assigned(MouseMoveAfterSplitterDownObsrv) then
  begin
    cl := ColorByteToFloat(FHeader.Color, true)*1.3;
    cl.w := 1;
    FSplitter.Color := cl;
    MouseMoveAfterSplitterDownObsrv := nil;
  end;
  delta := AData.X - MouseDownPos.x;
  MouseDownPos := vec2(AData.X, AData.Y);
  if delta <> 0 then
  begin
    Rect := RectBSd(Rect.X, Rect.Y, Rect.Width + delta, Rect.Height);
  end;
end;

procedure IColumnPresentor.DoResizeCells;
var
  i: int32;
  //w: BSFloat;
  cell: IColumnCellPresentor;
begin
  //w := FHeader.Size.Width - FCellLeftOffset*2;
  for i := 0 to ListCells.Count - 1 do
  begin
    cell := ListCells.Items[i];
    if Assigned(cell) then
    begin
      cell.Resize(FHeader.Size.Width - 1.0, FCellHeight);
      UpdatePosition(cell, i);
    end
    else
    begin
      ListCells.Count := i + 1;
      break;
    end;
  end;
end;

procedure IColumnPresentor.DoUpdateAlignCells;
var
  i: int32;
  cell: IColumnCellPresentor;
begin
  for i := 0 to ListCells.Count - 1 do
  begin
    cell := ListCells.Items[i];
    if Assigned(cell) then
      cell.Align
    else
      break;
  end;
end;

procedure IColumnPresentor.FreeSplitter;
begin
  FreeAndNil(FSplitterInvisible);
  FreeAndNil(FSplitter);
  SplitterMouseEnterObsrv := nil;
  SplitterMouseLeaveObsrv := nil;
  SplitterMouseDownObsrv := nil;
  SplitterMouseUpObsrv := nil;
end;

procedure IColumnPresentor.SetAlign(const Value: TObjectAlign);
begin
  if FAlign = Value then
    exit;
  FAlign := Value;
  DoUpdateAlignCells;
end;

procedure IColumnPresentor.SetCellHeight(AValue: BSFloat);
begin
  FCellHeight := AValue;
  UpdateCellHeightReal;
  if ShowSplitter then
    BuildSplitter;
  DoResizeCells;
end;

procedure IColumnPresentor.SetCellLeftOffset(AValue: BSFloat);
var
  i: int32;
begin
  FCellLeftOffset := AValue;
  for i := 0 to ListCells.Count - 1 do
  begin
    UpdatePosition(ListCells.Items[i], i);
  end;
end;

procedure IColumnPresentor.SetOffsetX(const Value: BSFloat);
begin
  FOffsetX := Value;
  if FHeader.Visible and Assigned(FHeader.Header) then
    FHeader.Header.Position2d := vec2(OffsetX, 0.0);

  UpdatePosSplitter;
end;

procedure IColumnPresentor.SetRect(const Value: TRectBSd);
var
  old: TRectBSd;
begin
  old := FRect;
  FRect := Value;
  FHeader.Size := vec2(round(FParent.Canvas.ScaleInv*Value.Width), FHeader.Size.Height);
  DoResizeCells;
  UpdatePosSplitter;

  if Assigned(_Node) then
    _Node := Owner.SpaceTree.UpdatePosition(_Node, FRect.Position, FRect.Size)
  else
    Owner.SpaceTree.Add(Self, FRect.Position, FRect.Size, _Node);

  if Assigned(FOnUpdateRect) then
    FOnUpdateRect(Self, old);
end;

procedure IColumnPresentor.SetShowBodyCells(const Value: boolean);
begin
  if FShowBodyCells = Value then
    exit;
  FShowBodyCells := Value;
end;

procedure IColumnPresentor.SetShowSplitter(const Value: boolean);
begin
  if FShowSplitter = Value then
    exit;

  FShowSplitter := Value;
  if FShowSplitter then
  begin
    if FVisible then
    begin
      CreateSplitter;
      BuildSplitter;
    end;
  end else
    FreeSplitter;
end;

procedure IColumnPresentor.SetShudderY(AValue: BSFloat);
{var
  it: TListColumnCells.PListItem;
  i: int32; }
begin
  if FShudderY = AValue then
    exit;
  FShudderY := AValue;
  {it := ListCells.ItemListFirst;
  i := 0;
  while Assigned(it) do
  begin
    it.Item.Body.Position2d := vec2(FCellLeftOffset, i * FCellHeight + FShudderY + HeaderYHeight);
    it := it.Next;
    inc(i);
  end;  }
end;

procedure IColumnPresentor.SetWidth(const Value: BSFloat);
begin
  Rect := RectBSd(FRect.X, FRect.Y, Value, FRect.Height);
  DoResizeCells;
end;

procedure IColumnPresentor.Show;
begin
  FVisible := true;
  FHeader.Show;
  UpdateViewpot(FPosition, FLastCount);
end;

procedure IColumnPresentor.UpdatePosition(ACell: IColumnCellPresentor; AIndex: int32);
begin
  ListCells.Items[AIndex] := ACell;
  if FHeader.Visible then
    ACell.Body.Position2d := vec2(OffsetX, FShudderY + AIndex * FCellHeightReal + FHeader.Header.Height)
  else
    ACell.Body.Position2d := vec2(OffsetX, FShudderY + AIndex * FCellHeightReal);
  ACell.FIndex := AIndex;
end;

procedure IColumnPresentor.UpdateViewpot(APosition: int64; ACount: int32);
var
  i: int32;
  cell: IColumnCellPresentor;
  offcet: int64;
  index: int32;
  step: int8;
  new_pos: int64;
  cells_height: BSFloat;
begin

  offcet := APosition - FPosition;
  if offcet >= 0 then
  begin
    index := 0;
    step := 1;
  end else
  begin
    index := ACount - 1;
    step := -1;
  end;

  for i := ACount to FLastCount - 1 do
    DeleteCell(i);

  FPosition := APosition;

  for i := 0 to ACount - 1 do
  begin
    cell := ListCells.Items[index];
    if (offcet <> 0) then
    begin

      if Assigned(cell) then
      begin
        new_pos := index - offcet;
        // does the cell hit into a new viewport?
        if (new_pos > -1) and (new_pos < ACount) then
          ListCells.Items[index] := nil
        else
          DeleteCell(cell);
      end;

      new_pos := index + offcet;
      cell := ListCells.Items[new_pos];
      if Assigned(cell) then
      begin
        ListCells.Items[new_pos] := nil;
        UpdatePosition(cell, index);
      end else
        DoCreateCell(index);

    end else
    if Assigned(cell) then
      UpdatePosition(cell, index) // update position on case of horizontal scrolling
    else
      DoCreateCell(index);

    inc(index, step);
  end;


  FLastCount := ACount;
  cells_height := ACount*FCellHeightReal + FShudderY;

  if cells_height <> FLastCellsHeight then
  begin
    FLastCellsHeight := cells_height;
    BuildSplitter;
  end;

end;

procedure IColumnPresentor.UpdateCellHeightReal;
begin
  FCellHeightReal := round(FOwner.Canvas.Scale*FCellHeight);
end;

procedure IColumnPresentor.UpdatePosition(AIndex: int32);
begin
  UpdatePosition(ListCells.Items[AIndex], AIndex);
end;

procedure IColumnPresentor.UpdatePosSplitter;
begin
  if Assigned(FSplitter) then
  begin
    if FHeader.Visible then
      FSplitter.Position2d := vec2(OffsetX + round(FHeader.Header.Width) - 1.0, 0)
    else
      FSplitter.Position2d := vec2(OffsetX + round(FOwner.Canvas.Scale*FHeader.Size.x) - 1.0, 0);
    FSplitterInvisible.Position2d := vec2(-3, 0);
  end;
end;

procedure IColumnPresentor.UpdateViewpot;
begin
  UpdateViewpot(FPosition, FLastCount);
end;

procedure IColumnPresentor.DeleteCell(AIndex: int32);
var
  cell: IColumnCellPresentor;
begin
  cell := ListCells.Items[AIndex];
  if Assigned(cell) then
    DeleteCell(cell);
end;

{ TBColumnPresentorString }

function TBColumnPresentorString.CellCreate(AIndex: int32): IColumnCellPresentor;
var
  data: string;
begin
  if FDataGetter(Self, Position + AIndex, data) then
  begin
    Result := TBCellPresentorString.Create(FParent, Self);
    TBCellPresentorString(Result).Data := data;
  end else
    Result := nil;
end;

constructor TBColumnPresentorString.Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject);
begin
  inherited;
  FColorText := TGuiColors.White;
end;

{ TBCellPresentorString }

procedure TBCellPresentorString.Align;
begin
  inherited;
  if Column.Align = oaCenter then
    FText.ToParentCenter
  else if Column.Align = oaRight then
    FText.Position2d := vec2((FColumn.Width - FText.Width - FColumn.CellLeftOffset), (FBody.Height - FText.Height)*0.5)
  else
    FText.Position2d := vec2(FColumn.CellLeftOffset, (FBody.Height - FText.Height)*0.5);
end;

constructor TBCellPresentorString.Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
begin
  inherited;

  FText := TCanvasText.Create(AParentObject.Canvas, FBody);
  FText.Data.Interactive := false;
  FText.SceneTextData.TxtProcessor.Interligne := 0;
  FText.Position2d := vec2(FColumn.CellLeftOffset, (FBody.Height - FText.Height)*0.5);
  // reserve for service levels
  FText.Layer2d := 3;
  FText.Color := ColorByteToFloat(TBColumnPresentorString(AColumn).ColorText, true);
end;

destructor TBCellPresentorString.Destroy;
begin
  FreeAndNil(FText);
  inherited;
end;

function TBCellPresentorString.GetData: string;
begin
  Result := FText.Text;
end;

procedure TBCellPresentorString.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  Align;
end;

procedure TBCellPresentorString.SetData(const AValue: string);
begin
  FText.Text := AValue;
  inherited;
end;

procedure TBCellPresentorString.DataFromString(const AValue: string);
begin
  SetData(AValue);
end;

function TBCellPresentorString.DataToString: string;
begin
  Result := GetData;
end;

{ TBColumnPresentor<P: TBCellPresentor<T>, constructor, T> }

constructor TBColumnPresentor<T>.Create(AOwner: TBScrolledWindow; ADataGetter: TMethod; AParent: TCanvasObject);
begin
  inherited;
  FDataGetter := TDataGetter<T>(ADataGetter);
end;

{ TBColumnCellPresentor<T> }

constructor TBColumnCellPresentor<T>.Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
begin
  inherited Create(AParentObject, AColumn);
end;

procedure TBColumnCellPresentor<T>.SetData(const AValue: T);
begin
  Align;
end;

{ TColumnHeader }

procedure TColumnHeader.BuildLine;
begin
  FBottomLine.A := vec2(0.0, 0.0);
  FBottomLine.B := vec2(FHeader.Size.Width, 0.0);
  FBottomLine.WidthLine := 1.0;
  FBottomLine.Build;
  FBottomLine.Position2d := vec2(0.0, FHeader.Height - 1.0);
end;

constructor TColumnHeader.Create(AOwner: IColumnPresentor; AParent: TCanvasObject);
begin
  FOwner := AOwner;
  FParent := AParent;
  FSize := vec2(AParent.Width, round(CELL_HEIGHT_DEFAULT * 1.2));

  FCaption := 'Header caption';
  FColor := $756743; // ColorFloatToByte(FParent.Color*0.5).value;
  FCaptionColor := TGuiColors.White;
  FOnChangeVisibleEvent := CreateEmptyEvent(GUIThread);
end;

destructor TColumnHeader.Destroy;
begin
  if Assigned(FHeader) then
    FreeHeader;
  inherited;
end;

procedure TColumnHeader.UpdateCaptionPosition;
begin
  FHeaderCaption.Position2d := vec2((FHeader.Width - FHeaderCaption.Width)*0.5, (FHeader.Height - FHeaderCaption.Height)*0.5);
  FHeaderCaption.SceneTextData.OutToWidth := FHeader.Width - FHeaderCaption.Font.AverageWidth*2;
end;

procedure TColumnHeader.CreateHeader;
var
  cl: TColor4f;
begin
  if Assigned(FHeader) or not FOwner.Visible then
    exit;
  FHeader := TRectangle.Create(FParent.Canvas, FParent);
  FHeader.Fill := true;
  FHeader.Data.Interactive := false;
  FHeader.Size := vec2(FSize.x - 1.0, FSize.y);
  FHeader.Layer2d := COLUMN_LAYER; // make the header to be above items
  FHeader.Color := ColorByteToFloat(FColor, true);
  FHeader.Build;
  FHeader.Position2d := vec2(FOwner.OffsetX, 0.0);
  MouseDownEventObserver := FHeader.Data.EventMouseDown.CreateObserver(GUIThread, MouseDown);
  FHeaderCaption := TCanvasText.Create(FParent.Canvas, FHeader);
  //FHeaderCaption.CreatCustomFont;
  //FHeaderCaption.Font.SizeInPixels := 10;
  FHeaderCaption.Text := FCaption;
  FHeaderCaption.Color := ColorByteToFloat(FCaptionColor, true);
  FHeaderCaption.Data.Interactive := false;
  //FHeaderCaption.SceneTextData.TxtProcessor.Delta := 1;
  FBottomLine := TLine.Create(FParent.Canvas, FHeader);
  cl := ColorByteToFloat(FColor, true)*0.7;
  cl.w := 1.0;
  FBottomLine.Color := cl;
  FBottomLine.Data.Interactive := false;
  BuildLine;
  UpdateCaptionPosition;
end;

procedure TColumnHeader.FreeHeader;
begin
  MouseDownEventObserver := nil;
  FreeAndNil(FBottomLine);
  FreeAndNil(FHeaderCaption);
  FreeAndNil(FHeader);
end;

function TColumnHeader.GetOwner: TGUIProperties;
begin
  Result := FOwner.Owner;
end;

procedure TColumnHeader.Hide;
begin
  FreeHeader;
end;

procedure TColumnHeader.MouseDown(const AData: BMouseData);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, AData);
end;

procedure TColumnHeader.SetCaption(const Value: string);
begin
  FCaption := Value;
  if Assigned(FHeaderCaption) then
  begin
    FHeaderCaption.Text := Value;
    UpdateCaptionPosition;
  end;
end;

procedure TColumnHeader.SetGuiColor(const Value: TGuiColor);
begin
  FColor := Value;
  if Assigned(FHeader) then
    FHeader.Color := ColorByteToFloat(FColor, true);
end;

procedure TColumnHeader.SetFontName(const Value: string);
begin
  FFontName := Value;
end;

procedure TColumnHeader.SetSize(const Value: TVec2f);
begin
  FSize := Value;
  if Assigned(FHeader) then
  begin
    FHeader.Size := FSize;
    FHeader.Build;
    FHeader.Position2d := vec2(FOwner.OffsetX, 0.0);
    BuildLine;
    UpdateCaptionPosition;
  end;
end;

procedure TColumnHeader.SetCaptionColor(const Value: TGuiColor);
begin
  FCaptionColor := Value;
  if Assigned(FHeaderCaption) then
    FHeaderCaption.Color := ColorByteToFloat(Value, true);
end;

procedure TColumnHeader.SetVisible(AValue: boolean);
begin
  if FVisible = AValue then
    exit;
  FVisible := AValue;
  if FVisible then
    CreateHeader
  else
    FreeHeader;

  FOnChangeVisibleEvent.Send(Self);
end;

procedure TColumnHeader.Show;
begin
  if FVisible then
    CreateHeader;
end;

{ IColumnCellPresentor }

procedure IColumnCellPresentor.BeforeDestruction;
begin
  AniObserverEnter := nil;
  if Assigned(AnimationEnter) then
  begin
    AnimationEnter.Stop;
    AnimationEnter := nil;
  end;
  inherited;
end;

constructor IColumnCellPresentor.Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
begin
  FColumn := AColumn;
  FBody := TRectangle.Create(AParentObject.Canvas, AParentObject);
  FBody.Fill := true;
  FBody.Data.DragResolve := false;
  FBody.Data.SelectResolve := false;
  FBody.Data.Opacity := 0.0;
  // set over grid
  FBody.Layer2d := 2;
  FIndex := -1;
  FBody.Color := vec4(79/255, 167/255, 1.0, 1.0);// vec4(FBody.Parent.Color.x - 0.3,  FBody.Parent.Color.y - 0.3, FBody.Parent.Color.z - 0.3, 1.0);
  MouseEnterEventObserver := FBody.Data.EventMouseEnter.CreateObserver(GUIThread, MouseEnter);
  MouseLeaveEventObserver := FBody.Data.EventMouseLeave.CreateObserver(GUIThread, MouseLeave);
  MouseDownEventObserver := FBody.Data.EventMouseDown.CreateObserver(GUIThread, MouseDown);
  //KeyDownEventObserver := FBody.Data.EventKeyDown.CreateObserver(GUIThread, KeyDown);
  AnimationEnter := CreateAniFloatLinear(GUIThread);
  AniObserverEnter := CreateAniFloatLivearObsrv(AnimationEnter, OnAnimateOpacity);
  AnimationEnter.Duration := 200;
end;

destructor IColumnCellPresentor.Destroy;
begin
  FBorder.Free;
  FBody.Free;
  inherited;
end;

procedure IColumnCellPresentor.DoChangeData;
begin
  if Assigned(FColumn.OnChangeData) then
    FColumn.OnChangeData(Self);
end;

{procedure IColumnCellPresentor.KeyDown(const AData: BKeyData);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, AData);
end;  }

procedure IColumnCellPresentor.MouseDown(const AData: BMouseData);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, AData);
end;

procedure IColumnCellPresentor.MouseEnter(const AData: BMouseData);
begin
  FIsMouseOver := true;
  if FSelected then
    CellState := csMouseOverAndSelected
  else
    CellState := csMouseOver;

  AnimationEnter.Stop;
  AnimationEnter.StartValue := FBody.Data.Opacity;
  AnimationEnter.StopValue := int32(CellState)*0.2;

  //ChangeAniStopValues(false);
  AnimationEnter.Run;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self, AData);
end;

procedure IColumnCellPresentor.MouseLeave(const AData: BMouseData);
begin
  FIsMouseOver := false;
  if FSelected then
    CellState := csSelected
  else
    CellState := csNone;

  AnimationEnter.Stop;
  AnimationEnter.StartValue := FBody.Data.Opacity;
  AnimationEnter.StopValue := int32(CellState)*0.2;
  AnimationEnter.Run;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self, AData);
end;

procedure IColumnCellPresentor.OnAnimateOpacity(const Value: BSFloat);
begin
  if (IsMouseOver and (FBody.Data.Opacity < Value)) or (not IsMouseOver and (FBody.Data.Opacity > Value)) then
    FBody.Data.Opacity := Value;
end;

procedure IColumnCellPresentor.Resize(AWidth, AHeight: BSFloat);
begin
  FBody.Size := vec2(AWidth, AHeight);
  FBody.Build;
  if Assigned(FBorder) then
  begin
    FBorder.Size := vec2(AWidth, AHeight);
    FBorder.Build;
    FBorder.Position2d := vec2(0.0, 0.0);
  end;
end;

procedure IColumnCellPresentor.SetSelected(const Value: boolean);
begin
  if FSelected = Value then
    exit;

  FSelected := Value;
  if FSelected then
  begin
    if IsMouseOver then
      CellState := csMouseOverAndSelected
    else
      CellState := csSelected;

    FBorder := TRectangle.Create(FBody.Canvas, FBody);
    FBorder.Fill := false;
    FBorder.WidthLine := 1.0;
    FBorder.Size := vec2(FBody.Size.Width, FBody.Size.Height);
    FBorder.Color := FBody.Color;
    FBorder.Data.Interactive := false;
    FBorder.Build;
    FBorder.Position2d := vec2(0.0, 0.0);
  end else
  begin
    if IsMouseOver then
      CellState := csMouseOver
    else
      CellState := csNone;
    FreeAndNil(FBorder);
  end;
  //if FBody.Data.Selected <> Value then
  //  FBody.Canvas.Scene.SetSelectedInstance(FBody.Data.FBaseInstance, Value);
  AnimationEnter.Stop;
  AnimationEnter.StopValue := int32(CellState)*0.2;
  FBody.Data.Opacity := AnimationEnter.StopValue;
end;

procedure TBColumnPresentor<T>.Refresh;
var
  i: int32;
  cell: TBColumnCellPresentor<T>;
  data: T;
begin
  for i := 0 to FLastCount - 1 do
  begin
    cell := TBColumnCellPresentor<T>(ListCells.Items[i]);
    if FDataGetter(Self, Position + i, data) then
      cell.Data := data
    else
      break;
  end;
end;

{ TBColumnPresentorCheckbox }

function TBColumnPresentorCheckbox.CellCreate(AIndex: int32): IColumnCellPresentor;
var
  data: string;
begin
  if FDataGetter(Self, Position + AIndex, data) then
  begin
    Result := TBCellPresentorCheckbox.Create(FParent, Self);
    TBCellPresentorCheckbox(Result).Data := data;
  end else
    Result := nil;
end;

{ TBCellPresentorCheckbox }

procedure TBCellPresentorCheckbox.Align;
begin
  inherited;
  if Column.Align = oaCenter then
    FCheckBox.MainBody.ToParentCenter
  else if Column.Align = oaRight then
    FCheckBox.Position2d := vec2((FColumn.Width - FCheckBox.Width - FColumn.CellLeftOffset), (FBody.Height - FCheckBox.Height)*0.5)
  else
    FCheckBox.Position2d := vec2(FColumn.CellLeftOffset, (FBody.Height - FCheckBox.Height)*0.5);
end;

constructor TBCellPresentorCheckbox.Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
begin
  inherited;
  FCheckBox := TBCheckBoxCustom.Create(AColumn.Owner.Canvas);
  FCheckBox.MainBody.Parent := FBody;
  FCheckBox.OnCheck := OnChangeCheck;
  FCheckBox.MainBody.Data.SetStensilTestRecursive(True);
end;

procedure TBCellPresentorCheckbox.DataFromString(const AValue: string);
begin
  inherited;
  SetData(AValue);
end;

function TBCellPresentorCheckbox.DataToString: string;
begin
  Result := GetData;
end;

destructor TBCellPresentorCheckbox.Destroy;
begin
  FCheckBox.Free;
  inherited;
end;

function TBCellPresentorCheckbox.GetData: string;
begin
  Result := BoolToStr(FCheckBox.IsChecked) + ';' + FCheckBox.Text;
end;

procedure TBCellPresentorCheckbox.OnChangeCheck(ASender: TObject);
begin
  DoChangeData;
end;

procedure TBCellPresentorCheckbox.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  //FCheckBox.BuildView;
  Align;
end;

procedure TBCellPresentorCheckbox.SetData(const AValue: string);
var
  i: int32;
  val: boolean;
  found: boolean;
begin
  found := false;
  for i := 1 to length(AValue) do
    if AValue[i] = ';' then
    begin
      if TryStrToBool(copy(AValue, 1, i-1), val) then
      begin
        found := true;
        FCheckBox.OnCheck := nil;
        FCheckBox.IsChecked := val;
        FCheckBox.Text := copy(AValue, i+1, length(AValue) - i - 1);
        FCheckBox.OnCheck := OnChangeCheck;
      end;
      break;
    end;
  if not found then
    FCheckBox.Text := AValue;
  inherited;
end;

{ TBColumnPresentorColor }

function TBColumnPresentorColor.CellCreate(AIndex: int32): IColumnCellPresentor;
var
  data: TGuiColor;
begin
  if FDataGetter(Self, Position + AIndex, data) then
  begin
    Result := TBCellPresentorColor.Create(FParent, Self);
    TBCellPresentorColor(Result).Data := data;
  end else
    Result := nil;
end;

{ TBCellPresentorColor }

procedure TBCellPresentorColor.Align;
var
  w: BSFloat;
begin
  inherited;
  w := FColumn.Width - (ColorRect.Width + DEFAULT_TEXT_INDENT);
  if w < 0 then
    w := 0.0;
  if Column.Align = oaCenter then
    ColorRect.ToParentCenter
  else if Column.Align = oaRight then
    ColorRect.Position2d := vec2((FColumn.Width - w - FColumn.CellLeftOffset), (FBody.Height - ColorRect.Height)*0.5)
  else
    ColorRect.Position2d := vec2(FColumn.CellLeftOffset, (FBody.Height - ColorRect.Height)*0.5);
end;

constructor TBCellPresentorColor.Create(AParentObject: TCanvasObject; AColumn: IColumnPresentor);
begin
  inherited;
  ColorRect := TRectangle.Create(AParentObject.Canvas, FBody);
  ColorRect.Size := vec2(FBody.Height - 2, FBody.Height - 2);
  ColorRect.Fill := true;
  ColorRect.Data.Interactive := false;
end;

procedure TBCellPresentorColor.DataFromString(const AValue: string);
begin
  inherited;
  ColorRect.Color := TColor4f(StringToColor(StringToAnsi(AValue)));
end;

function TBCellPresentorColor.DataToString: string;
begin
  Result := AnsiToString(ColorToString(TGuiColor(uint32(ColorRect.Color))));
end;

destructor TBCellPresentorColor.Destroy;
begin
  ColorRect.Free;
  inherited;
end;

function TBCellPresentorColor.GetData: TGuiColor;
begin
  Result := TGuiColor(uint32(ColorRect.Color));
end;

procedure TBCellPresentorColor.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  ColorRect.Size := vec2(FBody.Height - 2, FBody.Height - 2);
  ColorRect.Build;
  Align;
end;

procedure TBCellPresentorColor.SetData(const AValue: TGuiColor);
begin
  inherited;
  ColorRect.Color := TColor4f(AValue);
end;

end.
