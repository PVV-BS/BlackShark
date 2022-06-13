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

unit bs.gui.colorbox;

{$ifdef FPC}
  {$WARN 4055 off : Conversion between ordinals and pointers is not portable}
{$endif}

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.canvas
  , bs.events
  , bs.gui.base
  , bs.gui.column.presentor
  , bs.gui.combobox
  , bs.gui.colordialog
  ;

type

  {$M+}

  { TBCustomColorBox }

  TBCustomColorBox = class(TBCustomComboBox)
  private
    ColorRect: TRectangle;
    FColorDialog: TBColorDialog;
    FSelectedColor: TGuiColor;
    function GetColorData(ASender: IColumnPresentor; AIndex: int64; out AData: TGuiColor): boolean;
    function GetStringData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    procedure OnCloseColorDialogSelector(ASender: TObject);
    procedure SetSelectedColor(const Value: TGuiColor);
  protected
    function CreateColumn(Index: int32): IColumnPresentor; override;
    procedure DoSelect(Index: int32); override;
    procedure SetVisible(const Value: boolean); override;
    procedure SetScalable(const Value: boolean); override;
    procedure OnCellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData); override;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure BuildView; override;
    function DefaultSize: TVec2f; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property SelectedColor: TGuiColor read FSelectedColor write SetSelectedColor;
  end;

  TBColorBox = class(TBCustomColorBox)
    property Text;
    property FontName;
    property Color;
    property ParentColor;
    property ColorText;
    property ColorCursor;
    property ColorFrame;
    property SelectedColor;
  end;

implementation

uses
    SysUtils
  , bs.graphics
  , bs.constants
  , bs.strings
  , bs.lang.dictionary
  ;

{ TBCustomColorBox }

function TBCustomColorBox.CreateColumn(Index: int32): IColumnPresentor;
var
  getter_c: TDataGetter<TGuiColor>;
  getter_s: TDataGetter<string>;
begin
  if Index = 0 then
  begin
    getter_c := GetColorData;
    Result := FGrid.CreateColumn(TMethod(getter_c), TBColumnPresentorColor, '');
    Result.Width := Height - Frame.WidthLine;
  end else
  begin
    getter_s := GetStringData;
    Result := FGrid.CreateColumn(TMethod(getter_s), TBColumnPresentorString, '');
    Result.Width := Width - Height - Frame.WidthLine;
    TBColumnPresentorString(Result).ColorText := ColorText;
  end;
end;

procedure TBCustomColorBox.AfterConstruction;
type
  TColorValueName = record
    Value: TGuiColor;
    Name: String;
  end;

const
  MAIN_COLORS: array[0..18] of TColorValueName = (
    (Value: TGuiColors.Black; Name: 'clBlack'),
    (Value: TGuiColors.Maroon; Name: 'clMaroon'),
    (Value: TGuiColors.Green; Name: 'clGreen'),
    (Value: TGuiColors.Olive; Name: 'clOlive'),
    (Value: TGuiColors.Navy; Name: 'clNavy'),
    (Value: TGuiColors.Purple; Name: 'clPurple'),
    (Value: TGuiColors.Teal; Name: 'clTeal'),
    (Value: TGuiColors.Gray; Name: 'clGray'),
    (Value: TGuiColors.Silver; Name: 'clSilver'),
    (Value: TGuiColors.Red; Name: 'clRed'),
    (Value: TGuiColors.Lime; Name: 'clLime'),
    (Value: TGuiColors.Yellow; Name: 'clYellow'),
    (Value: TGuiColors.Blue; Name: 'clBlue'),
    (Value: TGuiColors.Fuchsia; Name: 'clFuchsia'),
    (Value: TGuiColors.Aqua; Name: 'clAqua'),
    (Value: TGuiColors.White; Name: 'clWhite'),

    (Value: TGuiColors.MoneyGreen; Name: 'clMoneyGreen'),
    (Value: TGuiColors.Cream; Name: 'clCream'),
    (Value: TGuiColors.MedGray; Name: 'clMedGray'));
var
  i: int32;
begin
  ColorRect := TRectangle.Create(Canvas, MainBody);
  ColorRect.Fill := true;
  ColorRect.Data.Interactive := false;
  inherited;
  ReadOnly := true;
  ShowCursor := false;
  LeftMargin := Height;
  CountColumns := 2;

  AddItem(GetSentence(Lang.CUSTOM_COLOR_ITEM), Pointer($FFFFFFFF));

  for i := low(MAIN_COLORS) to high(MAIN_COLORS) do
    AddItem(MAIN_COLORS[i].Name, {%H-}Pointer(MAIN_COLORS[i].Value));
  DoSelect(0);
end;

procedure TBCustomColorBox.BuildView;
begin
  inherited;
  ColorRect.Size := vec2(Height - 4*ToHiDpiScale, Height - 4*ToHiDpiScale);
  ColorRect.Build;
  ColorRect.Position2d := vec2(2.0*ToHiDpiScale, 2.0*ToHiDpiScale);
end;

function TBCustomColorBox.DefaultSize: TVec2f;
begin
  Result := inherited;
  Result:= vec2(Result.x + Result.Height + 30*ToHiDpiScale, Result.y)
end;

destructor TBCustomColorBox.Destroy;
begin
  FreeAndNil(FColorDialog);
  ColorRect.Free;
  inherited;
end;

procedure TBCustomColorBox.DoSelect(Index: int32);
begin
  FSelectedColor := {%H-}uint32(Data[0, Index]);
  ColorRect.Color := TColor4f(FSelectedColor);
  inherited;
end;

function TBCustomColorBox.GetColorData(ASender: IColumnPresentor; AIndex: int64; out AData: TGuiColor): boolean;
begin
  AData := {%H-}uint32(Data[0, AIndex]);
  Result := true;
end;

function TBCustomColorBox.GetStringData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin
  AData := Item[0, AIndex];
  Result := true;
end;

procedure TBCustomColorBox.OnCellMouseDown(ACell: IColumnCellPresentor; const AMouseData: BMouseData);
var
  pos: TVec2f;
begin
  inherited;
  if (ACell.Column.Position + ACell.Index = 0) then
  begin
    FColorDialog := TBColorDialog.Create(Canvas.Renderer);
    FColorDialog.OnClose := OnCloseColorDialogSelector;
    FColorDialog.SelectedColor := {%H-}TGuiColor(Data[0, 0]);
    FColorDialog.ShowModal;
    pos := Position2d - vec2((FColorDialog.Width - Width)*0.5, (FColorDialog.Height - Height)*0.5);
    if pos.x < 0 then
      pos.x := 0;
    if pos.y < 0 then
      pos.y := 0;
    FColorDialog.Position2d := pos;
  end;
end;

procedure TBCustomColorBox.OnCloseColorDialogSelector(ASender: TObject);
begin
  if FColorDialog.ShowResult = ModalResults.mrOk then
  begin
    Data[0, 0] := {%H-}Pointer(FColorDialog.SelectedColor);
    FSelectedColor := {%H-}TGuiColor(Data[0, 0]);
    ColorRect.Color := TColor4f(FColorDialog.SelectedColor);
    if Assigned(OnChange) then
      OnChange(Self);
  end;
  FreeAndNil(FColorDialog);
end;

procedure TBCustomColorBox.Resize(AWidth, AHeight: BSFloat);
begin
  LeftMargin := round(AHeight + 4*ToHiDpiScale);
  inherited;
end;

procedure TBCustomColorBox.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

procedure TBCustomColorBox.SetSelectedColor(const Value: TGuiColor);
var
  i, index: int32;
begin
  index := -1;
  for i := 1 to RowsCount - 1 do
    if ({%H-}UInt32(Data[0, i]) and $FFFFFF) = Value then
    begin
      index := i;
      break;
    end;
  if index < 0 then
  begin
    Data[0, 0] := {%H-}Pointer(Value);
    Item[1, 0] := AnsiToString(ColorToString(Value and $FFFFFF));
    SelectedIndex := 0;
  end else
    SelectedIndex := index;
end;

procedure TBCustomColorBox.SetVisible(const Value: boolean);
begin
  inherited;
  ColorRect.Data.Hidden := not Value;
end;

end.
