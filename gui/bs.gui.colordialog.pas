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

unit bs.gui.colordialog;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.canvas
  , bs.scene
  , bs.events
  , bs.gui.forms
  , bs.gui.buttons
  , bs.gui.edit
  , bs.gui.trackbar
  ;

type

  {$M+}

  { TBCustomColorDialog }

  TBCustomColorDialog = class(TBForm)
  private
    const
      COLOR_RECT_HEIGHT = 14.0;
      DEFAULT_WIDTH = 310;
      DEFAULT_HEIGHT = 280;
  private
    ObsrvBtnAcceptClick: IBMouseUpEventObserver;
    ObsrvBtnCancelClick: IBMouseUpEventObserver;
    ColorSquare: TColorSelector;
    BtnAccept: TBButton;
    BtnCancel: TBButton;
    ColorRect: TMultiColoredShape;
    SelectedColorRect: TRectangle;
    FEditRed: TBSpinEdit;
    FTextRed: TCanvasText;
    FEditGreen: TBSpinEdit;
    FTextGreen: TCanvasText;
    FEditBlue: TBSpinEdit;
    FTextBlue: TCanvasText;
    FEditHue: TBSpinEdit;
    FTextHue: TCanvasText;
    FEditSaturation: TBSpinEdit;
    FTextSaturation: TCanvasText;
    FEditLightness: TBSpinEdit;
    FTextLightness: TCanvasText;
    FTrackBarLightness: TBTrackBar;
    ChangingLightness: boolean;
    ChangingHS: boolean;
    ChangingControlValue: boolean;
    procedure OnCancelClick(const AData: BMouseData);
    procedure OnAcceptClick(const AData: BMouseData);
    procedure OnSelectColor(ASender: TObject);
    procedure OnChangeRed(ASender: TObject);
    procedure OnChangeGreen(ASender: TObject);
    procedure OnChangeBlue(ASender: TObject);
    procedure OnChangeTrackLightness(ATrackBar: TBCustomTrackBar);
    procedure OnChangeHue(ASender: TObject);
    procedure OnChangeLightness(ASender: TObject);
    procedure OnChangeSaturation(ASender: TObject);
    procedure UpdateHsl;
    procedure UpdateRgb;
    procedure UpdateColorRect;
    function GetSelectedColor: TGuiColor;
    procedure SetSelectedColor(const Value: TGuiColor);
  protected
    procedure SetVisible(const Value: boolean); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DefaultSize: TVec2f; override;
    procedure Close; override;
    property SelectedColor: TGuiColor read GetSelectedColor write SetSelectedColor;
  end;

  TBColorDialog = class(TBCustomColorDialog)
  end;

implementation

uses
    SysUtils
  , bs.scene.objects
  , bs.constants
  , bs.lang.dictionary
  ;

{ TBCustomColorDialog }

procedure TBCustomColorDialog.AfterConstruction;
var
  def_size: TVec2f;
begin
  BeginUpdate;
  try
    inherited;
    def_size := DefaultSize;
    def_size.Height := def_size.Height - HeaderHeight;
    ScrolledArea := def_size;
  finally
    EndUpdate;
    BuildView;
  end;
  ColorSquare.ColorSelected := BS_CL_ORANGE_2;
  UpdateRgb;
  UpdateHsl;
  UpdateColorRect;
end;

procedure TBCustomColorDialog.BuildView;
begin
  inherited;
  if UpdateCounter <> 0 then
    exit;
  ColorSquare.Size := vec2(Width, Height-100);
  ColorSquare.Build;
  ColorRect.Build;
  SelectedColorRect.Build;
  ColorSquare.Position2d := vec2(0.0, HeaderHeight);

  FTextRed.Position2d := vec2(5, ColorSquare.Position2d.y + ColorSquare.Size.Height + 5 + (FEditRed.Height - FTextRed.Height)*0.5);

  FEditRed.Position2d := vec2(FTextRed.Position2d.x + FTextRed.Width + 2, ColorSquare.Position2d.y + ColorSquare.Size.Height + 5);
  FEditGreen.Position2d := vec2(FEditRed.Position2d.x, FEditRed.Position2d.y + FEditRed.Height + 5);
  FEditBlue.Position2d := vec2(FEditGreen.Position2d.x, FEditGreen.Position2d.y + FEditGreen.Height + 5);

  FTextGreen.Position2d := vec2(FTextRed.Position2d.x, FEditGreen.Position2d.y + (FEditGreen.Height - FTextGreen.Height)*0.5);
  FTextBlue.Position2d := vec2(FTextRed.Position2d.x, FEditBlue.Position2d.y + (FEditBlue.Height - FTextBlue.Height)*0.5);

  FTextLightness.Position2d := vec2(FEditRed.Position2d.x + FEditRed.Width + 5, ColorSquare.Position2d.y + ColorSquare.Size.Height + 5 + (FEditLightness.Height - FTextLightness.Height)*0.5);
  FEditLightness.Position2d := vec2(FTextLightness.Position2d.x + FTextLightness.Width + 2, FEditRed.Position2d.y);
  FEditSaturation.Position2d := vec2(FEditLightness.Position2d.x, FEditGreen.Position2d.y);
  FEditHue.Position2d := vec2(FEditLightness.Position2d.x, FEditBlue.Position2d.y);

  FTextSaturation.Position2d := vec2(FTextLightness.Position2d.x, FEditSaturation.Position2d.y + (FEditSaturation.Height - FTextSaturation.Height)*0.5);
  FTextHue.Position2d := vec2(FTextLightness.Position2d.x, FEditHue.Position2d.y + (FEditHue.Height - FTextHue.Height)*0.5);

  BtnAccept.Position2d := vec2(Width - BtnAccept.Width - 5, Height - BtnAccept.Height - 5);
  BtnCancel.Position2d := vec2(BtnAccept.Position2d.x - BtnCancel.Width - 10, BtnAccept.Position2d.y);

  ColorRect.Position2d := vec2(BtnCancel.Position2d.x, FEditLightness.Position2d.y+4);

  SelectedColorRect.Position2d := vec2(BtnCancel.Position2d.x, FEditSaturation.Position2d.y+4);

  FTrackBarLightness.Position2d := vec2(0.0, (ColorRect.Height - FTrackBarLightness.Height) * 0.5);

end;

procedure TBCustomColorDialog.Close;
begin
  inherited;
end;

constructor TBCustomColorDialog.Create(ACanvas: TBCanvas);
begin
  inherited;
  MainBody.Data.DragResolve := true;
  CaptionHeader := GetSentence(Lang.DLG_COLOR_SELECTION_CAPTION);
  ColorSquare := TColorSelector.Create(ACanvas, FMainBody);
  ColorSquare.Data.DragResolve := false;
  ColorSquare.OnColorChange := OnSelectColor;

  BtnAccept := TBButton.Create(Canvas);
  BtnAccept.RoundRadius := 4.0;
  BtnAccept.ShowBorder := False;
  BtnAccept.Resize(80.0, 20.0);
  BtnAccept.Caption := GetSentence(Lang.ACCEPT);
  BtnAccept.Opacity := 0.8;
  BtnAccept.Color := $FF252525;
  DropControl(BtnAccept, OwnerInstances);

  BtnCancel := TBButton.Create(Canvas);
  BtnCancel.RoundRadius := 4.0;
  BtnCancel.Resize(80.0, 20.0);
  BtnCancel.Caption := GetSentence(Lang.CANCEL);
  BtnCancel.ShowBorder := False;
  BtnCancel.Opacity := 0.8;
  BtnCancel.Color := BtnAccept.Color;
  DropControl(BtnCancel, OwnerInstances);

  ColorRect := TMultiColoredShape.Create(ACanvas, FMainBody);
  ColorRect.AddVertex(vec2(0.0, 0.0), TVec3f(BS_CL_BLACK));
  ColorRect.AddVertex(vec2(0.0, COLOR_RECT_HEIGHT), TVec3f(BS_CL_BLACK));
  ColorRect.AddVertex(vec2(BtnAccept.Width + 10, 0.0));
  ColorRect.AddVertex(vec2(BtnAccept.Width + 10, COLOR_RECT_HEIGHT));
  ColorRect.AddVertex(vec2(BtnAccept.Width*2 + 10, 0.0), TVec3f(BS_CL_WHITE));
  ColorRect.AddVertex(vec2(BtnAccept.Width*2 + 10, COLOR_RECT_HEIGHT), TVec3f(BS_CL_WHITE));
  ColorRect.Data.Interactive := false;
  ColorRect.TypePrimitive := tpTriangleStrip;

  SelectedColorRect := TRectangle.Create(ACanvas, MainBody);
  SelectedColorRect.Fill := true;
  SelectedColorRect.Size := vec2(BtnAccept.Width*2 + 10, COLOR_RECT_HEIGHT);
  SelectedColorRect.Data.Interactive := false;

  FEditRed := TBSpinEdit.Create(ACanvas);
  FEditRed.MaxValue := 255;
  FEditRed.Resize(45, FEditRed.Height);
  FEditRed.OnChange := OnChangeRed;
  DropControl(FEditRed, OwnerInstances);

  FTextRed := TCanvasText.Create(ACanvas, MainBody);
  FTextRed.Text := 'R:';
  FTextRed.Data.Interactive := false;

  FEditGreen := TBSpinEdit.Create(ACanvas);
  FEditGreen.MaxValue := 255;
  FEditGreen.Resize(45, FEditGreen.Height);
  FEditGreen.OnChange := OnChangeGreen;
  DropControl(FEditGreen, OwnerInstances);

  FTextGreen := TCanvasText.Create(ACanvas, MainBody);
  FTextGreen.Text := 'G:';
  FTextGreen.Data.Interactive := false;

  FEditBlue := TBSpinEdit.Create(ACanvas);
  FEditBlue.MaxValue := 255;
  FEditBlue.Resize(45, FEditBlue.Height);
  FEditBlue.OnChange := OnChangeBlue;
  DropControl(FEditBlue, OwnerInstances);

  FTextBlue := TCanvasText.Create(ACanvas, MainBody);
  FTextBlue.Text := 'B:';
  FTextBlue.Data.Interactive := false;

  FEditHue := TBSpinEdit.Create(ACanvas);
  FEditHue.MaxValue := 255;
  FEditHue.Resize(45, FEditHue.Height);
  FEditHue.OnChange := OnChangeHue;
  DropControl(FEditHue, OwnerInstances);

  FTextHue := TCanvasText.Create(ACanvas, MainBody);
  FTextHue.Text := 'H:';
  FTextHue.Data.Interactive := false;

  FEditLightness := TBSpinEdit.Create(ACanvas);
  FEditLightness.MaxValue := 255;
  FEditLightness.Resize(45, FEditLightness.Height);
  FEditLightness.OnChange := OnChangeLightness;
  DropControl(FEditLightness, OwnerInstances);

  FTextLightness := TCanvasText.Create(ACanvas, MainBody);
  FTextLightness.Text := 'L:';
  FTextLightness.Data.Interactive := false;

  FEditSaturation := TBSpinEdit.Create(ACanvas);
  FEditSaturation.MaxValue := 255;
  FEditSaturation.Resize(45, FEditSaturation.Height);
  FEditSaturation.OnChange := OnChangeSaturation;
  DropControl(FEditSaturation, OwnerInstances);

  FTextSaturation := TCanvasText.Create(ACanvas, MainBody);
  FTextSaturation.Text := 'S:';
  FTextSaturation.Data.Interactive := false;

  FTrackBarLightness := TBTrackBar.Create(ACanvas);
  FTrackBarLightness.Horizontal := True;
  FTrackBarLightness.Size := 255;
  FTrackBarLightness.Resize(BtnAccept.Width*2 + 10, COLOR_RECT_HEIGHT);  // ColorRect.Width
  FTrackBarLightness.Position := 127;
  FTrackBarLightness.OnChangePosition := OnChangeTrackLightness;
  DropControl(FTrackBarLightness, OwnerInstances);
  FTrackBarLightness.MainBody.Parent := ColorRect;
  FTrackBarLightness.MainBody.Data.Opacity := 0.0;

  ObsrvBtnAcceptClick := CreateMouseObserver(BtnAccept.OnClickEvent, OnAcceptClick);
  ObsrvBtnCancelClick := CreateMouseObserver(BtnCancel.OnClickEvent, OnCancelClick);
end;

function TBCustomColorDialog.DefaultSize: TVec2f;
begin
  Result := vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
end;

destructor TBCustomColorDialog.Destroy;
begin
  ObsrvBtnAcceptClick := nil;
  ObsrvBtnCancelClick := nil;

  FEditRed.Free;
  FEditGreen.Free;
  FEditBlue.Free;

  FEditHue.Free;
  FEditSaturation.Free;
  FEditLightness.Free;

  FTrackBarLightness.MainBody.Parent := nil;

  FTrackBarLightness.Free;

  FTextRed.Free;
  FTextGreen.Free;
  FTextBlue.Free;
  FTextHue.Free;
  FTextSaturation.Free;
  FTextLightness.Free;

  BtnAccept.Free;
  BtnCancel.Free;

  SelectedColorRect.Free;
  ColorRect.Free;
  ColorSquare.Free;
  inherited;
end;

function TBCustomColorDialog.GetSelectedColor: TGuiColor;
begin
  Result := ColorFloatToByte(ColorSquare.ColorSelected).value;
end;

procedure TBCustomColorDialog.OnAcceptClick(const AData: BMouseData);
begin
  ShowResult := ModalResults.mrOk;
  Close;
end;

procedure TBCustomColorDialog.OnCancelClick(const AData: BMouseData);
begin
  ShowResult := ModalResults.mrCancel;
  Close;
end;

procedure TBCustomColorDialog.OnChangeBlue(ASender: TObject);
begin
  if ChangingControlValue then
    exit;
  ChangingControlValue := true;
  try
    ColorSquare.Blue := FEditBlue.Value / 255;
    UpdateColorRect;
    UpdateHsl;
  finally
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeGreen(ASender: TObject);
begin
  if ChangingControlValue then
    exit;
  ChangingControlValue := true;
  try
    ColorSquare.Green := FEditGreen.Value / 255;
    UpdateColorRect;
    UpdateHsl;
  finally
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeHue(ASender: TObject);
begin
  if ChangingControlValue or ChangingHS then
    exit;
  ChangingControlValue := true;
  ChangingHS := true;
  try
    ColorSquare.Hue := FEditHue.Value / 255;
    UpdateColorRect;
    UpdateRgb;
  finally
    ChangingHS := false;
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeLightness(ASender: TObject);
begin
  if ChangingControlValue then
    exit;

  if ChangingLightness then
    raise Exception.Create('Error Message');

  ChangingControlValue := true;
  try
    ChangingLightness := true;
    try
      ColorSquare.Lightness := FEditLightness.Value / 255;
      FTrackBarLightness.Position := FEditLightness.Value;
      UpdateColorRect;
      UpdateRgb;
    finally
      ChangingLightness := false;
    end;
  finally
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeRed(ASender: TObject);
begin
  if ChangingControlValue then
    exit;
  ChangingControlValue := true;
  try
    ColorSquare.Red := FEditRed.Value / 255;
    UpdateColorRect;
    UpdateHsl;
  finally
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeSaturation(ASender: TObject);
begin
  if ChangingControlValue or ChangingHS then
    exit;
  ChangingControlValue := true;
  ChangingHS := true;
  try
    ColorSquare.Red := FEditRed.Value / 255;
    ColorRect.Color := ColorSquare.ColorSelected;
    UpdateRgb;
  finally
    ChangingControlValue := false;
    ChangingHS := false;
  end;
end;

procedure TBCustomColorDialog.OnChangeTrackLightness(ATrackBar: TBCustomTrackBar);
begin
  FEditLightness.Value := round(ATrackBar.Position);
end;

procedure TBCustomColorDialog.OnSelectColor(ASender: TObject);
begin
  if ChangingControlValue then
    exit;
  ChangingControlValue := true;
  try
    UpdateColorRect;
    UpdateHsl;
    UpdateRgb;
  finally
    ChangingControlValue := false;
  end;
end;

procedure TBCustomColorDialog.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;

end;

procedure TBCustomColorDialog.SetSelectedColor(const Value: TGuiColor);
begin
  ColorSquare.ColorSelected := ColorByteToFloat(Value, true);
  UpdateColorRect;
  UpdateHsl;
  UpdateRgb;
end;

procedure TBCustomColorDialog.SetVisible(const Value: boolean);
begin
  ColorSquare.Data.Hidden := not Value;
  ColorRect.Data.Hidden := not Value;
  SelectedColorRect.Data.Hidden := not Value;
  FTextRed.Data.Hidden := not Value;
  FTextGreen.Data.Hidden := not Value;
  FTextBlue.Data.Hidden := not Value;
  FTextHue.Data.Hidden := not Value;
  FTextSaturation.Data.Hidden := not Value;
  FTextLightness.Data.Hidden := not Value;
  inherited;
end;

procedure TBCustomColorDialog.UpdateColorRect;
begin
  if not ChangingLightness then
  begin
    ColorRect.WriteColor(2, TVec3f(ColorSquare.ColorWithMiddleLightness));
    ColorRect.WriteColor(3, TVec3f(ColorSquare.ColorWithMiddleLightness));
    ColorRect.Build;
  end;
  SelectedColorRect.Color := ColorSquare.ColorSelected;
end;

procedure TBCustomColorDialog.UpdateHsl;
begin
  if not ChangingLightness then
  begin
    FEditHue.Value := round(ColorSquare.Hue*255);
    FEditSaturation.Value := round(ColorSquare.Saturation*255);
    FEditLightness.Value := round(ColorSquare.Lightness*255);
    FTrackBarLightness.Position := FEditLightness.Value;
  end;
end;

procedure TBCustomColorDialog.UpdateRgb;
begin
  FEditRed.Value := round(ColorSquare.Red*255);
  FEditGreen.Value := round(ColorSquare.Green*255);
  FEditBlue.Value := round(ColorSquare.Blue*255);
end;

end.
