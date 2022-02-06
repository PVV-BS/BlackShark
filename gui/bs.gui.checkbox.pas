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



unit bs.gui.checkbox;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.canvas
  , bs.scene
  , bs.gui.base
  ;

type

  TBCheckBoxCustom = class(TBControl)
  private
    FText: TCanvasText;
    UncheckedRect: TRectangle;
    CheckedRect: TRectangle;
    OnBodyMouseUpObsrv: IBMouseEventObserver;
    FOnCheck: TBControlNotify;
    FColorChecked: TGuiColor;
    FIsHalfChecked: boolean;
    FIsChecked: boolean;
    procedure BuildIsChecked;
    procedure BuildBody;
    procedure OnBodyMouseUp(const Data: BMouseData);
    procedure SetIsChecked(const Value: boolean);
    procedure SetIsHalfChecked(const Value: boolean);
    procedure SetColorChecked(const AValue: TGuiColor);
    function GetText: string;
    procedure SetText(const Value: string);
    procedure UpdateTextPostion;
    function GetCheckedRectSize: BSFloat;
  protected
    procedure DoAfterScale; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DefaultSize: TVec2f; override;
    property IsChecked: boolean read FIsChecked write SetIsChecked;
    property IsHalfChecked: boolean read FIsHalfChecked write SetIsHalfChecked;
    property OnCheck: TBControlNotify read FOnCheck write FOnCheck;
    property ColorChecked: TGuiColor read FColorChecked write SetColorChecked;
    property Text: string read GetText write SetText;
  end;

  TBCheckBox = class(TBCheckBoxCustom)
  published
    property IsChecked;
    property IsHalfChecked;
    property ColorChecked;
    property Text;
  end;

implementation

uses
    SysUtils
  , bs.config
  , bs.thread
  , bs.math
  ;

{ TBCheckBoxCustom }

constructor TBCheckBoxCustom.Create(ACanvas: TBCanvas);
var
  body: TRectangle;
begin
  inherited;
  FColorChecked := $3095F4;
  if not Assigned(ACanvas) then
    Canvas.Font.SizeInPixels := 10;
  body := TRectangle.Create(FCanvas, nil);
  FMainBody := body;
  body.Data.Opacity := 0.0;
  body.Fill := true;
  body.Data.DragResolve := false;
  //body.BanScalableMode := true;
  UncheckedRect := TRectangle.Create(FCanvas, body);
  UncheckedRect.Fill := false;
  UncheckedRect.Size := DefaultSize;
  UncheckedRect.Color := TColor4f($DDDDDD);
  UncheckedRect.Data.Interactive := false;
  FText := TCanvasText.Create(FCanvas, body);
  FText.Text := 'Checkbox';
  FText.Data.Interactive := false;
  OnBodyMouseUpObsrv := body.Data.EventMouseUp.CreateObserver(GuiThread, OnBodyMouseUp);
  {$ifdef DEBUG_BS}
  body.Data.Caption := 'MainBody';
  UncheckedRect.Data.Caption := 'UncheckedRect';
  {$endif}
end;

procedure TBCheckBoxCustom.BuildBody;
begin
  if FText.Height > UncheckedRect.Height then
    TRectangle(FMainBody).Size := vec2(round(Canvas.ScaleInv*FText.Width) + UncheckedRect.Size.Width, round(Canvas.ScaleInv*FText.Height))
  else
    TRectangle(FMainBody).Size := vec2(round(Canvas.ScaleInv*FText.Width) + UncheckedRect.Size.Width, UncheckedRect.Size.Height);

  FMainBody.Build;
  UncheckedRect.Position2d := vec2(0.0, 0.0);
end;

procedure TBCheckBoxCustom.BuildIsChecked;
var
  s: BSFloat;
begin
  if not FIsHalfChecked and not FIsChecked then
  begin
    FreeAndNil(CheckedRect);
    exit;
  end;

  if not Assigned(CheckedRect) then
  begin
    CheckedRect := TRectangle.Create(FCanvas, UncheckedRect);
    CheckedRect.Data.Interactive := false;
    //CheckedRect.WidthLine := s * 0.5;
    CheckedRect.Color := TColor4f(FColorChecked);
    CheckedRect.BanScalableMode := true;
  end;

  s := GetCheckedRectSize;
  CheckedRect.Size := vec2(s, s);
  CheckedRect.Fill := not FIsHalfChecked;
  CheckedRect.Build;
  CheckedRect.ToParentCenter;
end;

procedure TBCheckBoxCustom.BuildView;
begin
  inherited;
  UncheckedRect.Build;
  BuildBody;
  BuildIsChecked;
  UpdateTextPostion;
end;

function TBCheckBoxCustom.DefaultSize: TVec2f;
begin
  Result := vec2(14, 14);
end;

procedure TBCheckBoxCustom.DoAfterScale;
var
  s: BSFloat;
begin
  inherited;
  //BuildBody;
  //UncheckedRect.Position2d := vec2(0.0, 0.0);
  //UpdateTextPostion;
  if Assigned(CheckedRect) then
  begin
    // align size of CheckedRect
    s := GetCheckedRectSize;
    CheckedRect.Size := vec2(s, s);
    CheckedRect.Build;
    CheckedRect.ToParentCenter;
  end;
end;

function TBCheckBoxCustom.GetCheckedRectSize: BSFloat;
begin
  Result := round(UncheckedRect.Height * 0.6);
  if (round(UncheckedRect.Height) mod 2 = 0) then
  begin
    if (round(Result) mod 2 <> 0) then
      Result := Result + 1;
  end else
  if (round(Result) mod 2 = 0) then
    Result := Result + 1;

  Result := bs.math.clamp(UncheckedRect.Height, 1, Result);
end;

function TBCheckBoxCustom.GetText: string;
begin
  Result := FText.Text;
end;

procedure TBCheckBoxCustom.OnBodyMouseUp(const Data: BMouseData);
var
  dist: BSFloat;
begin
  if FCanvas.Renderer.HitTestInstance(Data.X, Data.Y, FMainBody.Data.BaseInstance, dist) then
    IsChecked := not IsChecked;
end;

procedure TBCheckBoxCustom.Resize(AWidth, AHeight: BSFloat);
begin
  UncheckedRect.WidthLine := 1.0;
  UncheckedRect.Size := vec2(AHeight, AHeight);
  inherited;
end;

procedure TBCheckBoxCustom.SetColorChecked(const AValue: TGuiColor);
begin
  FColorChecked := AValue;
  if Assigned(CheckedRect) then
    CheckedRect.Color := TColor4f(AValue);
end;

procedure TBCheckBoxCustom.SetIsChecked(const Value: boolean);
begin
  if Value and IsHalfChecked then
    IsHalfChecked := false;

  if Value = FIsChecked then
    exit;
  FIsChecked := Value;
  if FIsHalfChecked and not FIsChecked then
    FIsHalfChecked := false;
  BuildIsChecked;
  if Assigned(FOnCheck) then
    FOnCheck(Self);
end;

procedure TBCheckBoxCustom.SetIsHalfChecked(const Value: boolean);
begin
  if Value = FIsHalfChecked then
    exit;
  FIsHalfChecked := Value;
  BuildIsChecked;
end;

procedure TBCheckBoxCustom.SetText(const Value: string);
begin
  FText.Text := Value;
  BuildBody;
  UpdateTextPostion;
end;

procedure TBCheckBoxCustom.UpdateTextPostion;
begin
  { a position of the text mesuared in pixels }
  FText.Position2d := vec2(UncheckedRect.Width + 5, (UncheckedRect.Height - FText.Height)*0.5);
end;

end.
