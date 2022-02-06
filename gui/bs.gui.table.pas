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

unit bs.gui.table;

{$ifdef FPC}
  {$WARN 4080 off : Converting the operands to "$1" before doing the subtract could prevent overflow errors.}
{$endif}

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.collections
  , bs.canvas
  , bs.scene
  , bs.geometry
  , bs.animation
  , bs.strings
  , bs.gui.base
  , bs.gui.scrollbox
  , bs.gui.column.presentor
  ;

type

  TSelectionStrategy = (ssBan, ssSingle, ssMulti);

  { TBCustomTable }

  TBCustomTable = class(TBScrollBox)
  private
    FCountRowsInViewport: int32;
    FMaxCountRowsInViewport: int32;
    FItemsPresentor: TListVec<IColumnPresentor>;
    FSelectionStrategy: TSelectionStrategy;
    FLastCellSelected: TVec2i64;
    FCount: int64;
    Selector: TAreaMarker;
    // x, width - absolute coordinates above columns, pixels
    // y, height - position and height, cells
    FRowHeight: BSFloat;
    FRealRowHeight: BSFloat;
    FHeaderHeight: BSFloat;
    FRealHeaderHeight: BSFloat;
    FRectViewport: TRectBSd;
    WidthColumns: double;
    FOnCellMouseDown: TCellDataMouseNotify;
    FOnCellMouseEnter: TCellDataMouseNotify;
    FOnCellMouseLeave: TCellDataMouseNotify;
    FOnColumnMouseDown: TBControlNotify;
    FOnCellShow: TBControlNotify;
    FLines: TBiColoredSolidLines;
    FColorGrid2: TGuiColor;
    FColorGrid1: TGuiColor;
    FShudderY: BSFloat;
    BottomLine: TLine;
    FVisibleColumnsWidth: BSFloat;
    FShowColumnSplitters: boolean;
    FShowBottomLine: boolean;
    procedure UpdateSizeScrolledArea;
    procedure SetRowHeight(const Value: BSFloat);
    function GetColumn(Index: int32): IColumnPresentor;
    procedure CellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
    procedure CellMouseEnter(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
    procedure CellMouseLeave(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
    procedure ColumnMouseDown(ASender: TObject);
    procedure CellShow(ASender: TObject);
    function GetCountSelected: int32;
    procedure SetCount(const Value: int64);
    procedure SetShowHeader(const Value: boolean);
    function GetColumnsCount: int32;
    procedure SetHeaderHeight(const Value: BSFloat);
    procedure SetShowGrid(const Value: boolean);
    procedure SeTGuiColorGrid1(const Value: TGuiColor);
    procedure SeTGuiColorGrid2(const Value: TGuiColor);
    procedure BuildBottomLine;
    procedure SetShowBottomLine(const Value: boolean);
    procedure SetShowColumnSplitters(const Value: boolean);
    procedure CreateGrid;
    procedure DrawGrid;
    procedure UpdateGridPos;
    procedure UpdateHeaderHeight;
    procedure UpdateColumnsRect;
    procedure UpdateCellHeight;
  protected
    FShowHeader: boolean;
    FShowGrid: boolean;
    procedure DoChangePos; override;
    procedure DoSetViewPort(Y: int64; ShudderY: BSFloat);
    procedure SetScalable(const Value: boolean); override;
    procedure KeyDown({%H-}const Data: BKeyData); override;
    procedure ChangeColumnRect(AColumn: IColumnPresentor; const AOldRect: TRectBSd); virtual;
    procedure OnHideColumn(Node: PNodeSpaceTree);
    procedure OnShowColumn(Node: PNodeSpaceTree);
    procedure OnUpdateColumn(Node: PNodeSpaceTree);
    procedure DoAfterScale; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    procedure Clear;
    procedure ClearSelection;
    function GetSelectedCell(X, Y: int64): boolean;
    function SetSelectedCell(X, Y: int64; AValue: boolean): boolean;
    function GoToCell(X, Y: int64; AlignOnCellViewPort: boolean = false): boolean;
    { delete only visible data in viewport }
    procedure Delete(AIndex: int32);
    procedure DeleteColumn(AIndex: int32);
    procedure EndUpdate; override;
    { TODO: return the generic method with oficial release FPC 3.2.1. }
    //function CreateColumn<T>(ADataGetter: TDataGetter<T>; AColumnClass: IColumnPresentorClass; const AHeaderCaption: string): IColumnPresentor;
    // ADataGetter must be TDataGetter<T>
    function CreateColumn(ADataGetter: TMethod; AColumnClass: IColumnPresentorClass; const AHeaderCaption: string): IColumnPresentor;
    property RowHeight: BSFloat read FRowHeight write SetRowHeight;
    property Count: int64 read FCount write SetCount;
    property CountSelected: int32 read GetCountSelected;
    property CountRowsInViewport: int32 read FCountRowsInViewport;
    property RectViewport: TRectBSd read FRectViewport;

    property Columns[Index: int32]: IColumnPresentor read GetColumn;
    property ColumnsCount: int32 read GetColumnsCount;
    property SelectionStrategy: TSelectionStrategy read FSelectionStrategy;
    property ShowHeader: boolean read FShowHeader write SetShowHeader;
    property HeaderHeight: BSFloat read FHeaderHeight write SetHeaderHeight;
    property ShowGrid: boolean read FShowGrid write SetShowGrid;
    property ShowBottomLine: boolean read FShowBottomLine write SetShowBottomLine;
    property ShowColumnSplitters: boolean read FShowColumnSplitters write SetShowColumnSplitters;
    property OnCellMouseDown: TCellDataMouseNotify read FOnCellMouseDown write FOnCellMouseDown;
    property OnCellMouseEnter: TCellDataMouseNotify read FOnCellMouseEnter write FOnCellMouseEnter;
    property OnCellMouseLeave: TCellDataMouseNotify read FOnCellMouseLeave write FOnCellMouseLeave;
    property OnColumnMouseDown: TBControlNotify read FOnColumnMouseDown write FOnColumnMouseDown;
    property OnCellShow: TBControlNotify read FOnCellShow write FOnCellShow;
    property ColorGrid1: TGuiColor read FColorGrid1 write SeTGuiColorGrid1;
    property ColorGrid2: TGuiColor read FColorGrid2 write SeTGuiColorGrid2;
  end;

  {$M+}

  TBTable = class(TBCustomTable)
  published
    property ShowHeader;
    property HeaderHeight;
    property SelectionStrategy;
    property ShowGrid;
    property ColorGrid1;
    property ColorGrid2;
  end;

implementation

uses
    SysUtils
  , Classes
  , bs.graphics
  , bs.config
  , bs.math
  , bs.events.keyboard
  ;

{ TBCustomTable }

procedure TBCustomTable.ChangeColumnRect(AColumn: IColumnPresentor; const AOldRect: TRectBSd);
var
  i: int32;
  Column: IColumnPresentor;
  delta: BSFloat;
  w: BSFloat;
  has_visible: boolean;
begin
  delta := AColumn.Rect.Width - AOldRect.Width;
  if delta <> 0 then
  begin
    WidthColumns := WidthColumns + Delta;
    w := AColumn.OffsetX + AColumn.Width;
    has_visible := AColumn.Visible;
    for i := AColumn.Index + 1 to FItemsPresentor.Count - 1 do
    begin
      Column := FItemsPresentor.Items[i];
      if Column.Visible then
        has_visible := true;
      Column.Rect := RectBS(Column.Rect.X + delta, 0.0, round(Canvas.Scale*Column.Header.Size.Width), Column.Rect.Height);
      Column.OffsetX := w;
      w := w + Column.Width;
    end;

    if has_visible then
      FVisibleColumnsWidth := FVisibleColumnsWidth + Delta;

    UpdateSizeScrolledArea;
    if (WidthColumns < Width) and ShowGrid then
      DrawGrid;

    if (FCountRowsInViewport < FMaxCountRowsInViewport) and FShowBottomLine then
      BuildBottomLine;
  end;
end;

procedure TBCustomTable.Clear;
var
  i: int32;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    FItemsPresentor.Items[i].Clear;
  end;
end;

procedure TBCustomTable.ClearSelection;
var
  i: int32;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    FItemsPresentor.Items[i].ClearSelection;
  end;
  Selector.Clear;
end;

constructor TBCustomTable.Create(ACanvas: TBCanvas);
begin
  inherited;
  FCount := -1;
  FShowHeader := true;
  FShowGrid := true;
  FShowBottomLine := true;
  FShowColumnSplitters := true;
  FHeaderHeight := round(CELL_HEIGHT_DEFAULT * 1.2);
  FRealHeaderHeight := round(Canvas.Scale*FHeaderHeight);
  FColorGrid1 := $1E1414; //ColorFloatToByte(BS_CL_MSVS_EDITOR*1.5).value; //ColorFloatToByte(ClipObject.Color).value;
  FColorGrid2 := $322323; //ColorFloatToByte(BS_CL_MSVS_EDITOR*1.8).value; //ColorFloatToByte(ClipObject.Color * 0.7).value;
  Color := $322323;
  //Color := clSkyBlue;// ColorFloatToByte(BS_CL_SKY_BLUE) clNavy;
  //FRowHeightPixels := CELL_HEIGHT_DEFAULT;
  FRowHeight := CELL_HEIGHT_DEFAULT;
  FRealRowHeight := round(FRowHeight*Canvas.Scale);
  //FVisibleItems := TListItems.Create;
  //FSelected := TListItems.Create;
  FSelectionStrategy := ssMulti;
  { list presentor }
  FItemsPresentor := TListVec<IColumnPresentor>.Create(@PtrCmp);
  if OwnCanvas then
    FCanvas.Font.SizeInPixels := 8;
  Selector := TAreaMarker.Create(TBlackSharkRTree.Create);
  //ScrollBarsPaddingTop := FHeaderHeight;
  ScrollBarVert.Color := TGuiColors.SkyBlue;
  ScrollBarHor.Color := TGuiColors.SkyBlue;
  //MainBody.Data.Opacity := 0.1;
  SpaceTree.OnShowUserData := OnShowColumn;
  SpaceTree.OnHideUserData := OnHideColumn;
  SpaceTree.OnUpdatePositionUserData := OnUpdateColumn;
  ScrollBarVert.Step := FRealRowHeight;
  if FShowGrid then
    CreateGrid;
  //Selector.SpaceTree.
end;

function TBCustomTable.CreateColumn(ADataGetter: TMethod; AColumnClass: IColumnPresentorClass; const AHeaderCaption: string): IColumnPresentor;
var
  w: double;
begin
  w := WidthColumns;
  Result := AColumnClass.Create(Self, TMethod(ADataGetter), ClipObject);
  Result.Index := FItemsPresentor.Count;
  Result.OnUpdateRect := ChangeColumnRect;
  FItemsPresentor.Add(Result);
  Result.OnCellMouseDown := CellMouseDown;
  Result.OnCellMouseEnter := CellMouseEnter;
  Result.OnCellMouseLeave := CellMouseLeave;
  Result.OnColumnMouseDown := ColumnMouseDown;
  //Result.OnCellKeyDown := OnCellKeyDown;
  Result.OnCellShow := CellShow;
  Result.Header.Visible := FShowHeader;
  Result.Header.Caption := AHeaderCaption;
  Result.CellHeight := FRowHeight;
  Result.Header.Size := vec2(COLUMN_WIDTH_DEFAULT, FRealHeaderHeight);
  Result.OffsetX := w - ScrollBarHor.Position;
  Result.Rect := RectBSd(w, 0.0, Result.Header.Size.Width, ScrolledArea.y);
  Result.ShowSplitter := FShowColumnSplitters;
  if UpdateCounter = 0 then
    DoChangePos;
end;

procedure TBCustomTable.CreateGrid;
begin
  FLines := TBiColoredSolidLines.Create(FCanvas, ClipObject);
  FLines.LineWidth := FRealRowHeight;
  FLines.Data.Interactive := false;
  FLines.BanScalableMode := true;
  FLines.Color := TColor4f(FColorGrid1);
  FLines.Color2 := TColor4f(FColorGrid2);
  FLines.Data.StencilTest := true;
  FLines.Data.StaticObject := false;
end;

procedure TBCustomTable.Delete(AIndex: int32);
var
  i: int32;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    FItemsPresentor.Items[i].DeleteCell(AIndex);
  end;
end;

procedure TBCustomTable.DeleteColumn(AIndex: int32);
var
  column: IColumnPresentor;
  i: int32;
  delta: BSFloat;
begin
  column := FItemsPresentor.Items[AIndex];
  if not Assigned(column) then
    exit;

  if not (TControlState.csReleasing in FControlState) then
  begin
    if column.Index > 0 then
      delta := column.Rect.Width - 1
    else
      delta := column.Rect.Width;

    WidthColumns := WidthColumns - delta;

    FItemsPresentor.Count := FItemsPresentor.Count - 1;
    column.Free;

    for i := AIndex + 1 to FItemsPresentor.Count do
    begin
      column := FItemsPresentor.Items[i];
      column.Index := i - 1;
      FItemsPresentor.Items[column.Index] := column;
      column.Rect := RectBS(column.Rect.X - delta, column.Rect.Y, column.Rect.Width, column.Rect.Height);
    end;
    ClearSelection;
    DoChangePos;
  end else
  begin
    FItemsPresentor.Delete(AIndex);
    column.Free;
  end;
  if (FLastCellSelected.x >= FItemsPresentor.Count) and (FItemsPresentor.Count > 0) then
    FLastCellSelected.x := FItemsPresentor.Count - 1;
end;

destructor TBCustomTable.Destroy;
var
  i: int32;
begin
  Clear;
  for i := FItemsPresentor.Count - 1 downto 0 do
    FItemsPresentor.Items[i].Free;
  Selector.SpaceTree.Free;
  Selector.Free;
  FItemsPresentor.Free;
  inherited;
end;

procedure TBCustomTable.DoChangePos;
var
  shudderY: BSFloat;
  _y: int32;
begin
  inherited DoChangePos;
  if UpdateCounter <> 0 then
    exit;
  _y := trunc(ScrollBarVert.Position / FRealRowHeight);
  shudderY := ScrollBarVert.Position - (FRealRowHeight * _y);
  DoSetViewPort(_y, -shudderY);
end;

procedure TBCustomTable.DoAfterScale;
begin
  inherited;
  FRealHeaderHeight := round(Canvas.Scale*FHeaderHeight);
  FRealRowHeight := round(Canvas.Scale*FRowHeight);
  UpdateSizeScrolledArea;
  UpdateCellHeight;
  UpdateColumnsRect;
  //UpdateHeaderHeight;
  //UpdateSizeScrolledArea;
  if Assigned(BottomLine) then
    BuildBottomLine;
  //DoChangePos;
  if FShowGrid then
    DrawGrid;
end;

procedure TBCustomTable.DoSetViewPort(Y: int64; ShudderY: BSFloat);
var
  column: IColumnPresentor;
  node: TBiDiListNodes.PListItem;
  c: BSFloat;
begin
  if (FItemsPresentor.Count = 0) or (FCount = 0) or (SpaceTree.VisibleData.Count = 0) then
  begin
    if Assigned(BottomLine) then
      FreeAndNil(BottomLine);
    exit;
  end;

  FShudderY := ShudderY;

  if ShowHeader then
    c := (ClipObject.Height - FRealHeaderHeight - ShudderY) / FRealRowHeight
  else
    c := (ClipObject.Height - ShudderY) / FRealRowHeight;

  FCountRowsInViewport := round(c);
  if c - FCountRowsInViewport > 0 then
    inc(FCountRowsInViewport);

  FMaxCountRowsInViewport := FCountRowsInViewport;

  if Y > FCount then
    Y := FCount - 1;

  if Y + FCountRowsInViewport > FCount then
    FCountRowsInViewport := FCount - Y;

  FRectViewport.X := SpaceTree.CurrentViewPort.x_min;
  FRectViewport.Y := Y;
  FRectViewport.Height := FCountRowsInViewport;
  FRectViewport.Width := SpaceTree.CurrentViewPort.x_max - SpaceTree.CurrentViewPort.x_min;

  FVisibleColumnsWidth := 0;
  node := SpaceTree.VisibleData.ItemListFirst;
  while Assigned(node) do
  begin
    column := node.Item.BB.TagPtr;
    node := node.Next;
    column.OffsetX := column.Rect.X - ScrollBarHor.Position;
    column.ShudderY := ShudderY;
    column.UpdateViewpot(Y, FCountRowsInViewport);
    if column.OffsetX < 0 then
    begin
      if column.OffsetX > -column.Width then
        FVisibleColumnsWidth := FVisibleColumnsWidth + column.Width + column.OffsetX;
    end else
      FVisibleColumnsWidth := FVisibleColumnsWidth + column.Width;
  end;

  if FCountRowsInViewport < FMaxCountRowsInViewport then
  begin
    if FShowBottomLine then
      BuildBottomLine;
  end else
    FreeAndNil(BottomLine);

  if FShowGrid then
  begin
    if (FCountRowsInViewport + 1 <> FLines.CountLines) or (FLines.Width <> c) then
      DrawGrid;
  end;

end;

procedure TBCustomTable.DrawGrid;
begin
  FLines.LineWidth := FRealRowHeight;
  if (FRectViewport.Y + FCountRowsInViewport = FCount) and (round(FRectViewport.Y) and 1 = 0) then
    FLines.Draw(FVisibleColumnsWidth, true, FCountRowsInViewport)
  else
    FLines.Draw(FVisibleColumnsWidth, true, FCountRowsInViewport + 1);
  UpdateGridPos;
end;

procedure TBCustomTable.EndUpdate;
begin
  inherited;
  if UpdateCounter = 0 then
  begin
    DoChangePos;
  end;
end;

procedure TBCustomTable.KeyDown(const Data: BKeyData);
begin
  inherited;
  if (FItemsPresentor.Count > 0) and (SpaceTree.VisibleData.Count > 0) and not (FSelectionStrategy = ssBan) then
  begin

    if (FLastCellSelected.x < 0) then
      FLastCellSelected.x := 0
    else
    if (FLastCellSelected.x > FItemsPresentor.Count - 1) then
      FLastCellSelected.x := FItemsPresentor.Count - 1;

    if (FLastCellSelected.y < 0) then
      FLastCellSelected.y := round(FRectViewport.Y)
    else
    if (FLastCellSelected.y - round(FRectViewport.Y) > FCountRowsInViewport) then
      FLastCellSelected.y := round(FRectViewport.Y) + FCountRowsInViewport - 1;

    if Data.Key = VK_BS_UP then
    begin

      if FLastCellSelected.y > 0 then
      begin
        if ((FSelectionStrategy = ssSingle) or not (ssShift in FCanvas.Renderer.ShiftState)) then
          ClearSelection;
        SetSelectedCell(FLastCellSelected.x, FLastCellSelected.y - 1, not GetSelectedCell(FLastCellSelected.x, FLastCellSelected.y - 1));
        GoToCell(FLastCellSelected.x, FLastCellSelected.y);
      end;

    end else
    if Data.Key = VK_BS_DOWN then
    begin

      if FLastCellSelected.y < FCount - 1 then
      begin
        if ((FSelectionStrategy = ssSingle) or not (ssShift in FCanvas.Renderer.ShiftState)) then
          ClearSelection;
        SetSelectedCell(FLastCellSelected.x, FLastCellSelected.y + 1, not GetSelectedCell(FLastCellSelected.x, FLastCellSelected.y + 1));
        GoToCell(FLastCellSelected.x, FLastCellSelected.y);
      end;

    end else
    if Data.Key = VK_BS_LEFT then
    begin

      if (FLastCellSelected.x > 0) then
      begin
        if ((FSelectionStrategy = ssSingle) or not (ssShift in FCanvas.Renderer.ShiftState)) then
          ClearSelection;
        SetSelectedCell(FLastCellSelected.x - 1, FLastCellSelected.y, not GetSelectedCell(FLastCellSelected.x - 1, FLastCellSelected.y));
        GoToCell(FLastCellSelected.x, FLastCellSelected.y);
      end;

    end else
    if Data.Key = VK_BS_RIGHT then
    begin

      if (FLastCellSelected.x < FItemsPresentor.Count - 1) then
      begin
        if ((FSelectionStrategy = ssSingle) or not (ssShift in FCanvas.Renderer.ShiftState)) then
          ClearSelection;
        SetSelectedCell(FLastCellSelected.x + 1, FLastCellSelected.y, not GetSelectedCell(FLastCellSelected.x + 1, FLastCellSelected.y));
        GoToCell(FLastCellSelected.x, FLastCellSelected.y);
      end;

    end;
  end;
end;

procedure TBCustomTable.BuildBottomLine;
begin
  if FCountRowsInViewport = 0 then
  begin
    FreeAndNil(BottomLine);
    exit;
  end;

  if not Assigned(BottomLine) then
  begin
    BottomLine := TLine.Create(Canvas, ClipObject);
    BottomLine.Data.Interactive := false;
    BottomLine.BanScalableMode := true;
    BottomLine.Color := IColumnPresentor(SpaceTree.VisibleData.ItemListFirst.Item.BB.TagPtr).Splitter.Color;
    BottomLine.Layer2d := COLUMN_LAYER;
    BottomLine.WidthLine := 1;
  end;

  if BottomLine.Width <> FVisibleColumnsWidth then
  begin
    BottomLine.B := vec2(FVisibleColumnsWidth, 0.0);
    BottomLine.Build;
  end;

  if ShowHeader then
    BottomLine.Position2d := vec2(0.0, FCountRowsInViewport*FRealRowHeight + FShudderY + FRealHeaderHeight)
  else
    BottomLine.Position2d := vec2(0.0, FCountRowsInViewport*FRealRowHeight + FShudderY);
end;

procedure TBCustomTable.CellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
begin
  if not Focused then
    Focused := true;
  if (FSelectionStrategy <> ssMulti) or not (ssCtrl in FCanvas.Renderer.ShiftState) then
    ClearSelection;

  if FSelectionStrategy <> ssBan then
  begin
    SetSelectedCell(ACell.Column.Index, ACell.Index + round(FRectViewport.Y), not ACell.Selected);
  end;

  if Assigned(FOnCellMouseDown) then
    FOnCellMouseDown(ACell, AMouseData);
end;

procedure TBCustomTable.CellMouseEnter(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
begin
  if Assigned(FOnCellMouseEnter) then
    FOnCellMouseEnter(ACell, AMouseData);
end;

procedure TBCustomTable.CellMouseLeave(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
begin
  if Assigned(FOnCellMouseLeave) then
    FOnCellMouseLeave(ACell, AMouseData);
end;

procedure TBCustomTable.CellShow(ASender: TObject);
begin
  if GetSelectedCell(IColumnCellPresentor(ASender).Column.Index, IColumnCellPresentor(ASender).Index+round(FRectViewport.Y)) then
    IColumnCellPresentor(ASender).Selected := true;
  if Assigned(FOnCellShow) then
    FOnCellShow(ASender);
end;

procedure TBCustomTable.ColumnMouseDown(ASender: TObject);
begin
  if not Focused then
    Focused := true;
  if Assigned(FOnColumnMouseDown) then
    FOnColumnMouseDown(ASender);
end;

//procedure TBCustomTable.OnDeleteColumn(Node: PNodeSpaceTree);
//begin
//end;

procedure TBCustomTable.OnHideColumn(Node: PNodeSpaceTree);
begin
  IColumnPresentor(Node.BB.TagPtr).Hide;
end;

procedure TBCustomTable.OnShowColumn(Node: PNodeSpaceTree);
begin
  IColumnPresentor(Node.BB.TagPtr).Show;
end;

procedure TBCustomTable.OnUpdateColumn(Node: PNodeSpaceTree);
begin
  //if Assigned(IColumnPresentor(Node.BB.TagPtr).FColumnPresentor) then
  //  IColumnPresentor(Node.BB.TagPtr).FColumnPresentor.Create();
end;

function TBCustomTable.GetColumn(Index: int32): IColumnPresentor;
begin
  Result := FItemsPresentor.Items[Index];
end;

function TBCustomTable.GetColumnsCount: int32;
begin
  Result := FItemsPresentor.Count;
end;

function TBCustomTable.GetCountSelected: int32;
begin
  Result := Selector.SpaceTree.Count;
end;

function TBCustomTable.GetSelectedCell(X, Y: int64): boolean;
var
  ln: TListNodes;
begin
  ln := nil;
  Selector.SpaceTree.SelectData(X, Y, 0.0, 0.0, ln);
  Result := (ln <> nil) and (ln.Count > 0);
end;

function TBCustomTable.GoToCell(X, Y: int64; AlignOnCellViewPort: boolean = false): boolean;
var
  hh: BSFloat;
  _x, _y: double;
begin
  if (FItemsPresentor.Count = 0) or (FCount = 0) then
    exit(false);

  Result := true;

  X := Clamp(FItemsPresentor.Count - 1, 0, X);
  Y := Clamp(FCount - 1, 0, Y);
  if ShowHeader then
    hh := FRealHeaderHeight
  else
    hh := 0;

  if ScrollBarHor.Visible then
    hh := hh + ScrollBarHor.Height; // scroll bar return on 90 degree

  if not AlignOnCellViewPort then
  begin
    // if row is not visible
    if not ((Y >= FRectViewport.Y) and (Y < FRectViewport.Y + FCountRowsInViewport)) then
    begin
      if Y > FRectViewport.Y then
      begin
        if ((Y + 1 - round(FRectViewport.Y)) * FRealRowHeight + hh + FShudderY > ClipObject.Height - ScrollBarsPaddingTop - ScrollBarsPaddingBottom) then
          Y := round(FRectViewport.Y) + 2
        else
          Y := round(FRectViewport.Y) + 1;
        Y := Clamp(FCount - 1, 0, Y);
      end;
    end else // y position is visible
    if Y > FRectViewport.Y then
    begin
      if ((Y + 1 - round(FRectViewport.Y)) * FRealRowHeight + hh > ClipObject.Height - ScrollBarsPaddingTop - ScrollBarsPaddingBottom) then
        Y := round(FRectViewport.Y) + 1
      else
        Y := round(FRectViewport.Y);
    end else
    begin
      Y := round(FRectViewport.Y);
      FShudderY := 0;
    end;

    _x := FItemsPresentor.Items[X].Rect.X;
    // if column is not visible
    if not ((_x >= FRectViewport.X) and (_x < FRectViewport.X + FRectViewport.Width)) then
    begin
      if _x > FRectViewport.X then
      begin
        _x := FRectViewport.X + FItemsPresentor.Items[X].Rect.Width;
      end else
      begin
        _x := FRectViewport.X - FItemsPresentor.Items[X].Rect.Width;
      end;
    end else
      _x := FRectViewport.X;

  end else
  begin
    FShudderY := 0;
    _x := FItemsPresentor.Items[X].Rect.X;
  end;

  _y := FRealRowHeight * Y - FShudderY;
  Position := vec2d(_x, _y);
end;

procedure TBCustomTable.Resize(AWidth, AHeight: BSFloat);
var
  i: int32;
  column: IColumnPresentor;
begin
  inherited;
  if Scalable then
  begin
    UpdateColumnsRect;
    if Assigned(BottomLine) then
      BuildBottomLine;
  end else
  begin
    for i := 0 to FItemsPresentor.Count - 1 do
    begin
      column := FItemsPresentor.Items[i];
      column.UpdatePosSplitter;
    end;
  end;
end;

procedure TBCustomTable.SeTGuiColorGrid1(const Value: TGuiColor);
begin
  FColorGrid1 := Value;
end;

procedure TBCustomTable.SeTGuiColorGrid2(const Value: TGuiColor);
begin
  FColorGrid2 := Value;
end;

procedure TBCustomTable.SetCount(const Value: int64);
var
  i: int32;
  presentor: IColumnPresentor;
begin
  if FCount = Value then
    exit;
  FCount := Value;
  if (FRectViewport.Y >= FCount) then
  begin
    Clear;
  end;

  UpdateSizeScrolledArea;

  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    presentor := FItemsPresentor.Items[i];
    presentor.Rect := RectBSd(presentor.Rect.X, presentor.Rect.Y, presentor.Header.Size.Width, ScrolledArea.y);
  end;
  DoChangePos;
end;

procedure TBCustomTable.SetHeaderHeight(const Value: BSFloat);
begin
  if FHeaderHeight = Value then
    exit;
  FHeaderHeight := Value;
  FRealHeaderHeight := round(Value*Canvas.Scale);
  UpdateHeaderHeight;
end;

procedure TBCustomTable.SetShowHeader(const Value: boolean);
var
  i: int32;
  presentor: IColumnPresentor;
begin
  if FShowHeader = Value then
    exit;
  FShowHeader := Value;
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    presentor := FItemsPresentor.Items[i];
    presentor.Header.Visible := Value;
  end;
end;

procedure TBCustomTable.SetRowHeight(const Value: BSFloat);
var
  i: int32;
  presentor: IColumnPresentor;
begin
  FRowHeight := Value;
  FRealRowHeight := round(Value*Canvas.Scale);
  FLines.LineWidth := FRealRowHeight;
  ScrollBarVert.Step := FRealRowHeight;
  UpdateSizeScrolledArea;
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    presentor := FItemsPresentor.Items[i];
    presentor.CellHeight := FRowHeight;
    presentor.Rect := RectBS(presentor.Rect.X, 0.0, presentor.Rect.Width, ScrolledArea.Height);
  end;
  //SetViewPort(round(ScrollBarVert.Position));
end;

procedure TBCustomTable.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

function TBCustomTable.SetSelectedCell(X, Y: int64; AValue: boolean): boolean;
var
  presentor: IColumnPresentor;
  cell: IColumnCellPresentor;
begin
  if (X >= FItemsPresentor.Count) or (Y >= FCount) then
    exit(false);

  Result := true;

  if AValue then
  begin
    FLastCellSelected := Vec2(X, Y);
    Selector.AddArea(X, Y, 0.0, 0.0, nil, true, false);
  end else
  begin
    Selector.DelArea(vec2d(X, Y), 0.0, 0.0);
  end;

  presentor := FItemsPresentor.Items[X];
  cell := presentor.Cell[Y - presentor.Position];
  if Assigned(cell) then
    cell.Selected := AValue;
end;

procedure TBCustomTable.SetShowBottomLine(const Value: boolean);
begin
  if FShowBottomLine = Value then
    exit;
  FShowBottomLine := Value;
  if FShowBottomLine then
    BuildBottomLine
  else
    FreeAndNil(BottomLine);
end;

procedure TBCustomTable.SetShowColumnSplitters(const Value: boolean);
var
  i: int32;
begin
  if FShowColumnSplitters = Value then
    exit;
  FShowColumnSplitters := Value;
  for i := 0 to FItemsPresentor.Count - 1 do
    FItemsPresentor.Items[i].ShowSplitter := FShowColumnSplitters;
end;

procedure TBCustomTable.SetShowGrid(const Value: boolean);
begin
  if FShowGrid = Value then
    exit;

  FShowGrid := Value;
  if FShowGrid then
    CreateGrid
  else
    FreeAndNil(FLines);
end;

procedure TBCustomTable.UpdateCellHeight;
var
  i: int32;
  column: IColumnPresentor;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    column := FItemsPresentor.Items[i];
    column.UpdateCellHeightReal;
  end;
end;

procedure TBCustomTable.UpdateColumnsRect;
var
  i: int32;
  column: IColumnPresentor;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    column := FItemsPresentor.Items[i];
    column.Rect := RectBSd(column.Rect.X, column.Rect.Y, round(Canvas.Scale*column.Header.Size.Width), ScrolledArea.y);
    column.BuildSplitter;
  end;
end;

procedure TBCustomTable.UpdateGridPos;
var
  c: BSFloat;
begin

  if round(FRectViewport.Y) and 1 > 0 then
    c := FRealRowHeight
  else
    c := 0;

  if ShowHeader then
    FLines.Position2d := vec2(0.0, FRealHeaderHeight + FShudderY - c)
  else
    FLines.Position2d := vec2(0.0, FShudderY - c);

end;

procedure TBCustomTable.UpdateHeaderHeight;
var
  i: int32;
  presentor: IColumnPresentor;
begin
  for i := 0 to FItemsPresentor.Count - 1 do
  begin
    presentor := FItemsPresentor.Items[i];
    presentor.Header.Size := vec2(Canvas.ScaleInv*presentor.Rect.Width, FHeaderHeight);
  end;
  if ShowHeader then
    UpdateSizeScrolledArea;
end;

procedure TBCustomTable.UpdateSizeScrolledArea;
begin
  if ShowHeader then
    ScrolledArea := vec2(WidthColumns, FRealRowHeight * FCount + FRealHeaderHeight)
  else
    ScrolledArea := vec2(WidthColumns, FRealRowHeight * FCount);
end;

end.
