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

unit bs.gui.combobox;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.collections
  , bs.events
  , bs.canvas
  , bs.scene
  , bs.strings
  , bs.gui.base
  , bs.gui.edit
  , bs.gui.table
  , bs.animation
  , bs.gui.column.presentor
  ;

type

  {$M+}

  TBCustomComboBox = class;

  TSelectComboBoxItemNotify = procedure (ASender: TBCustomComboBox; AIndex: int32) of object;

  { TBCustomComboBox }

  TBCustomComboBox = class(TBCustomEdit)
  private
    const
      DEFAULT_LIST_HEIGHT = CELL_HEIGHT_DEFAULT * 7;
    type
      TListStrings = TListVec<string>;
      TListPointers = TListVec<Pointer>;
  private
    ButtonRight: TRectangle;
    BtnTri: TTriangle;
    ObsrvOnMouseDownBtnRight: IBMouseEventObserver;
    TriAnimator: IBAnimationLinearFloat;
    ObsrvTriAnimation: IBAnimationLinearFloatObsrv;
    FSelectComboBoxItem: TSelectComboBoxItemNotify;

    ShowHideListAnimator: IBAnimationLinearFloat;
    ObsrvShowHideListAnimation: IBAnimationLinearFloatObsrv;
    Curtain: TRectangle;

    FListHeight: BSFloat;
    ListHiding: boolean;
    FSelectedIndex: int32;

    procedure UpdateTextOutWidth;
    procedure OnMouseDownBtnRight(const Data: BMouseData);
    procedure OnTriAnimate(const Data: BSFloat);
    procedure OnShowHideListAnimate(const Data: BSFloat);
    function GetCountColumns: int32;
    procedure SetCountColumns(const Value: int32);
    procedure SetRowsCount(const Value: int32);
    function GetData(IndexColumn, IndexItem: int32): Pointer;
    procedure SetData(IndexColumn, IndexItem: int32; const Value: Pointer);
    procedure SetItem(IndexColumn, IndexItem: int32; const Value: string);
    function GetItem(IndexColumn, IndexItem: int32): string;
    procedure CreateGrid;
    function GetRowsCount: int32;
    function GetItemData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    procedure SetSelectedIndex(const Value: int32);
    procedure ShowGrid;
    procedure HideGrid;
  protected
    FItems: TListVec<TListStrings>;
    FData: TListVec<TListPointers>;
    FGrid: TBCustomTable;
    procedure SetColor(const AValue: TGuiColor); override;
    procedure DoSelect(Index: int32); virtual;
    procedure SetScalable(const Value: boolean); override;
    procedure SetFocused(Value: boolean); override;
    function CreateColumn(Index: int32): IColumnPresentor; virtual;
    procedure OnMouseDown(const Data: BMouseData); override;
    procedure SetVisible(const Value: boolean); override;
    procedure OnCellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData); virtual;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    procedure Clear; virtual;
    procedure AddItem(const AItem: string; AData: Pointer = nil; AColumnIndex: int32 = 0);
    property Item[IndexColumn, IndexItem: int32]: string read GetItem write SetItem;
    property Data[IndexColumn, IndexItem: int32]: Pointer read GetData write SetData;
    property OnSelectComboBoxItem: TSelectComboBoxItemNotify read FSelectComboBoxItem write FSelectComboBoxItem;
    property CountColumns: int32 read GetCountColumns write SetCountColumns;
    property RowsCount: int32 read GetRowsCount write SetRowsCount;
    property ListHeight: BSFloat read FListHeight write FListHeight;
    property SelectedIndex: int32 read FSelectedIndex write SetSelectedIndex;
  end;

  TBComboBox = class(TBCustomCombobox)
  published
    property Text;
    property FontName;
    property Color;
    property ParentColor;
    property ColorText;
    property ColorCursor;
    property ColorFrame;
  end;

implementation

uses
    SysUtils
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.graphics
  , bs.config
  , bs.thread
  , bs.scene.objects
  ;

{ TBCustomComboBox }

procedure TBCustomComboBox.AddItem(const AItem: string; AData: Pointer; AColumnIndex: int32);
begin
  if AColumnIndex > CountColumns - 1 then
    CountColumns := AColumnIndex;
  FItems.Items[AColumnIndex].Add(AItem);
  FData.Items[AColumnIndex].Add(AData);
end;

procedure TBCustomComboBox.BuildView;
begin
  inherited;
  ButtonRight.Build;
  ButtonRight.Position2d := vec2(Width - ButtonRight.Size.Width - Frame.WidthLine, Frame.WidthLine);
  BtnTri.Build;
  BtnTri.Position2d := vec2((ButtonRight.Size.Width - BtnTri.C.x)*0.5, (ButtonRight.Size.Height - BtnTri.B.y)*0.5);
end;

procedure TBCustomComboBox.Clear;
var
  i: int32;
begin
  for i := 0 to CountColumns - 1 do
  begin
    if Assigned(FItems.Items[i]) then
      FItems.Items[i].Count := 0;
    if Assigned(FData.Items[i]) then
      FData.Items[i].Count := 0;
  end;
end;

constructor TBCustomComboBox.Create(ACanvas: TBCanvas);
begin
  inherited;

  FItems := TListVec<TListStrings>.Create;
  FData := TListVec<TListPointers>.Create;

  ButtonRight := TRectangle.Create(Canvas, MainBody);
  ButtonRight.Size := vec2(DefaultSize.Height - Frame.WidthLine*2, DefaultSize.Height - Frame.WidthLine*2);
  ButtonRight.Color := MainBody.Color;
  ButtonRight.Fill := true;
  ButtonRight.Data.DragResolve := false;
  ObsrvOnMouseDownBtnRight := ButtonRight.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownBtnRight);
  BtnTri := TTriangle.Create(Canvas, ButtonRight);
  BtnTri.A := vec2(0.0, 0.0);
  BtnTri.B := vec2(round(5.0*ToHiDpiScale), round(5.0*ToHiDpiScale));
  BtnTri.C := vec2(round(10.0*ToHiDpiScale), 0.0);
  BtnTri.Fill := true;
  BtnTri.Color := BS_CL_WHITE;
  BtnTri.Data.Interactive := false;
  TriAnimator := CreateAniFloatLinear(GUIThread);
  TriAnimator.Duration := 200;
  ObsrvTriAnimation := CreateAniFloatLivearObsrv(TriAnimator, OnTriAnimate, GUIThread);
  FListHeight := round(DEFAULT_LIST_HEIGHT*ToHiDpiScale);
  UpdateTextOutWidth;

  ShowHideListAnimator := CreateAniFloatLinear(GUIThread);
  ShowHideListAnimator.Duration := TriAnimator.Duration;
  ObsrvShowHideListAnimation := CreateAniFloatLivearObsrv(ShowHideListAnimator, OnShowHideListAnimate, GUIThread);
end;

function TBCustomComboBox.CreateColumn(Index: int32): IColumnPresentor;
var
  method: TDataGetter<string>;
begin
  method := GetItemData;
  Result := FGrid.CreateColumn(TMethod(method), TBColumnPresentorString, '');
  Result.Width := FGrid.Width;
  TBColumnPresentorString(Result).ColorText := ColorText;
end;

procedure TBCustomComboBox.CreateGrid;
var
  i: int32;
  w: BSFloat;
begin
  if Assigned(FGrid) or (RowsCount = 0) then
    exit;

  FGrid := TBCustomTable.Create(Canvas);
  FGrid.ShowHeader := false;
  FGrid.ShowGrid := false;
  FGrid.ShowBottomLine := false;
  FGrid.ShowColumnSplitters := false;
  //FGrid.Canvas.ModalLevel := Canvas.ModalLevel;

  Curtain := TRectangle.Create(FGrid.Canvas, MainBody);
  Curtain.Data.Opacity := 0.0;
  Curtain.Data.Interactive := false;
  Curtain.Color := BS_CL_RED;
  Curtain.Fill := true;
  Curtain.Data.DrawInstance := FGrid.DrawClipArea;
  Curtain.Data.AsStencil := true;
  Curtain.Layer2d := 5; // over caption and cursor
  {$ifdef DEBUG_BS}
  Curtain.Data.Caption := 'Curtain';
  {$endif}
  //Curtain.Parent := nil;

  FGrid.MainBody.Parent := Curtain;
  FGrid.ClipObject.Data.DrawInstance := TObjectVertexes(FGrid.ClipObject.Data).DrawVertexs;
  FGrid.MainBody.Data.SetStensilTestRecursive(true);
  //FGrid.ScrollBarVert.MainBody.Data.SetStensilTestRecursive(true);
  //FGrid.ScrollBarHor.MainBody.Data.SetStensilTestRecursive(true);

  if Assigned(FGrid.Border) then
    FGrid.Border.Data.StencilTest := true;

  w := RowsCount * FGrid.RowHeight;
  if w > FListHeight then
    w := FListHeight;

  FGrid.Resize(Width-FGrid.Border.WidthLine*2, w);
  //w := FGrid.Width / CountColumns;
  for i := 0 to CountColumns - 1 do
    CreateColumn(i);

  FGrid.Position2d := vec2(0.0, 0.0);
  FGrid.OnCellMouseDown := OnCellMouseDown;
  FGrid.Color := Color;
  FGrid.Count := RowsCount;
  Curtain.Size := vec2(FGrid.Width+FGrid.Border.WidthLine*2, FGrid.Height+FGrid.Border.WidthLine*2);
  Curtain.Build;
  Curtain.Position2d := vec2(0.0, Height);
  FGrid.Position2d := vec2(0.0, -FGrid.Height);
  FGrid.MainBody.Data.AsStencil := false;
  //FGrid.MainBody.Data.StencilTest := true;

  if FGrid.ScrollBarVert.Visible then
  begin
    if FSelectedIndex > RowsCount - FGrid.CountRowsInViewport then
      FGrid.GoToCell(0, RowsCount - FGrid.CountRowsInViewport, true)
    else
      FGrid.GoToCell(0, FSelectedIndex, true);
  end;
  FGrid.Focused := true;
end;

destructor TBCustomComboBox.Destroy;
var
  i: int32;
begin
  Clear;
  for i := 0 to CountColumns - 1 do
  begin
    if Assigned(FItems.Items[i]) then
      FItems.Items[i].Free;
    if Assigned(FData.Items[i]) then
      FData.Items[i].Free;
  end;
  FGrid.Free;
  Curtain.Free;
  FItems.Free;
  FData.Free;
  inherited;
end;

procedure TBCustomComboBox.DoSelect(Index: int32);
var
  s: string;
  i: int32;
begin
  FSelectedIndex := Index;
  s := '';
  for i := 0 to CountColumns - 1 do
    if Assigned(FItems.Items[i]) then
      if s <> '' then
        s := s + ' ' + FItems.Items[i].Items[Index]
      else
        s := FItems.Items[i].Items[Index];
  Text := s;
  if Assigned(FSelectComboBoxItem) then
    FSelectComboBoxItem(Self, Index);
end;

function TBCustomComboBox.GetCountColumns: int32;
begin
  Result := FItems.Count;
end;

function TBCustomComboBox.GetData(IndexColumn, IndexItem: int32): Pointer;
begin
  Result := FData.Items[IndexColumn].Items[IndexItem];
end;

function TBCustomComboBox.GetItem(IndexColumn, IndexItem: int32): string;
begin
  Result := FItems.Items[IndexColumn].Items[IndexItem];
end;

function TBCustomComboBox.GetItemData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin
  AData := FItems.Items[ASender.Index].Items[AIndex];
  Result := true;
end;

function TBCustomComboBox.GetRowsCount: int32;
begin
  if Assigned(FItems.Items[0]) then
    Result := FItems.Items[0].Count
  else
    Result := 0;
end;

procedure TBCustomComboBox.HideGrid;
begin
  ListHiding := true;
  Curtain.Data.SetInteractiveRecursive(false);
  ShowHideListAnimator.StartValue := FGrid.Height;
  ShowHideListAnimator.StopValue := 0.0;
  ShowHideListAnimator.Run;
  TriAnimator.StartValue := BtnTri.Data.AngleZ;
  TriAnimator.StopValue := 0.0;
  TriAnimator.Run;
end;

procedure TBCustomComboBox.OnCellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
begin
  DoSelect(ACell.Index + Round(FGrid.RectViewport.Y));
  HideGrid;
end;

procedure TBCustomComboBox.OnMouseDown(const Data: BMouseData);
begin
  inherited;
  if ReadOnly then
  begin
    if Assigned(FGrid) then
      HideGrid
    else
      ShowGrid;
  end;
end;

procedure TBCustomComboBox.OnMouseDownBtnRight(const Data: BMouseData);
begin
  if Assigned(FGrid) then
    HideGrid
  else
    ShowGrid;
end;

procedure TBCustomComboBox.OnShowHideListAnimate(const Data: BSFloat);
begin
  if not Assigned(FGrid) then
    exit;
  if ListHiding and (Data = 0.0) then
  begin
    FreeAndNil(FGrid);
    FreeAndNil(Curtain);
    Focused := true;
  end else
  begin
    //Curtain.Size := vec2(Width, Data + FGrid.Border.WidthLine);
    //Curtain.Build;
    //Curtain.Position2d := vec2(Position2d.x, Position2d.y + Height);
    FGrid.ClipObject.Position2d := vec2(FGrid.Border.WidthLine, Data - FGrid.Height);
  end;
end;

procedure TBCustomComboBox.OnTriAnimate(const Data: BSFloat);
begin
  BtnTri.Data.AngleZ := Data;
end;

procedure TBCustomComboBox.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  ButtonRight.Size := vec2(Height - 2, Height - 2);
  UpdateTextOutWidth;
end;

procedure TBCustomComboBox.SetColor(const AValue: TGuiColor);
var
  cl: TColor4f;
begin
  inherited;
  cl := MainBody.Color;
  ButtonRight.Color := MainBody.Color;
  if (cl.a > 0.5) and (cl.r + cl.g + cl.b > 0.5) then
    BtnTri.Color := BS_CL_BLACK
  else
    BtnTri.Color := BS_CL_WHITE;
end;

procedure TBCustomComboBox.SetCountColumns(const Value: int32);
var
  i: int32;
  count: int32;
begin

  if Value < 1 then
    count := 1
  else
    count := Value;

  if count > FItems.Count then
  begin
    for i := FItems.Count to count - 1 do
    begin
      FItems.Items[i] := TListVec<string>.Create;
      FData.Items[i] := TListVec<Pointer>.Create;;
    end;
  end else
  if count < FItems.Count then
  begin
    for i := FItems.Count - 1 downto count - 1 do
    begin
      FItems.Items[i].Free;
      FData.Items[i].Free;
    end;
    FItems.Count := Count;
    FData.Count := Count;
  end;
end;

procedure TBCustomComboBox.SetData(IndexColumn, IndexItem: int32; const Value: Pointer);
begin
  if IndexColumn > CountColumns - 1 then
    CountColumns := IndexColumn;
  if IndexItem < FData.Count then
    FData.Items[IndexColumn].Items[IndexItem] := Value
  else
    AddItem('', Value, IndexColumn);
end;

procedure TBCustomComboBox.SetFocused(Value: boolean);
begin
  inherited;
  //if not Value and Assigned(FGrid) and not FGrid.Focused then
  //  FreeAndNil(FGrid);
end;

procedure TBCustomComboBox.SetItem(IndexColumn, IndexItem: int32; const Value: string);
begin
  if IndexColumn > CountColumns - 1 then
    CountColumns := IndexColumn;
  if IndexItem < FData.Count then
    FItems.Items[IndexColumn].Items[IndexItem] := Value
  else
    AddItem(Value, nil, IndexColumn);
end;

procedure TBCustomComboBox.SetRowsCount(const Value: int32);
var
  i: int32;
begin
  for i := 0 to CountColumns - 1 do
  begin
    FItems.Items[i].Count := Value;
    FData.Items[i].Count := Value;
  end;
end;

procedure TBCustomComboBox.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

procedure TBCustomComboBox.SetSelectedIndex(const Value: int32);
begin
  DoSelect(Value);
end;

procedure TBCustomComboBox.SetVisible(const Value: boolean);
begin
  inherited;
  // TODO: SetVisible
end;

procedure TBCustomComboBox.ShowGrid;
begin
  CreateGrid;
  if not Assigned(FGrid) then
    exit;
  ListHiding := false;
  //Focused := true;
  TriAnimator.StartValue := 0.0;
  TriAnimator.StopValue := -180.0;
  ShowHideListAnimator.StartValue := 0;
  ShowHideListAnimator.StopValue := FGrid.Height;
  ShowHideListAnimator.Run;
  TriAnimator.Run;
end;

procedure TBCustomComboBox.UpdateTextOutWidth;
begin
  TextoutWidth := Width - ButtonRight.Size.Width - 1.0 - LeftMargin - Canvas.Font.AverageWidth;
end;

end.
