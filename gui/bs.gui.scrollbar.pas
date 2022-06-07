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


{
  Represents scroll bar; be careful, so in root object property
  Independent2dSizeFromMVP set to true, that is if scroll bar rotate
  then TBScrollBar.Postion2d will work, but not the same as
  expected;
  Independent2dSizeFromMVP set to true allow correctly use scroll bar with
  any orientation;
}

{$ifdef fpc}
  {$WARN 5024 off : Parameter "$1" not used}
{$endif}

{$I BlackSharkCfg.inc}

unit bs.gui.scrollbar;

interface

uses
    bs.basetypes
  , bs.events
  , bs.graphics
  , bs.gui.base
  , bs.canvas
  , bs.scene
  , bs.animation
  ;

type

  TBScrollBar = class;

  TChangeScrollBarPosition = procedure(ScrollBar: TBScrollBar) of object;

  { TBScrollBar }

  {$M+}
  TBScrollBar = class(TBControl)
  private
    const
      DEFAULT_WIDTH   = 11;
      DEFAULT_HEIGHT  = 140;
      MIN_SIZE_SLIDER  = 8;
  private
    FBody: TRectangle;
    FHorizontal: boolean;
    FPosition: Int64;
    FSize: Int64;
    //FCountScrolledPixels: int64;

    FOnMouseEnterLeaveBody: TOnMouseColorExchanger;
    FOnMouseEnterLeaveLeftUpBtn: TOnMouseMoveAndClickColorExchanger;
    FOnMouseEnterLeaveRightDownBtn: TOnMouseMoveAndClickColorExchanger;
    FOnMouseEnterLeaveSlider: TOnMouseMoveAndClickColorExchanger;

    FStep: Int32;
    FOnChangePosition: TChangeScrollBarPosition;
    TriUp: TTriangle;
    TriDown: TTriangle;
    StateInteractive: boolean;
    FIsMouseDownOnSlider: boolean;
    SliderMvpChanging: boolean;

    ObsrvBodyMD: IBMouseDownEventObserver;
    ObsrvBtnUpLeftMD: IBMouseDownEventObserver;
    ObsrvBtnDwnRgtMD: IBMouseDownEventObserver;
    ObsrvBtnUpLeftMU: IBMouseDownEventObserver;
    ObsrvBtnDwnRgtMU: IBMouseDownEventObserver;

    ObsrvSliderMU: IBMouseDownEventObserver;
    ObsrvSliderMD: IBMouseDownEventObserver;
    ObsrvSliderChMVP: IBChangeMVPEventObserver;

    TimeDown: uint32;
    WaitTimer: IBAnimationLinearFloat;
    WaitTimerObsrv: IBAnimationLinearFloatObsrv;
    WaitTimerUp: boolean;

    procedure SetHorizontal(const Value: boolean);

    procedure BtnUpLeftMouseDown({%H-}const Data: BMouseData);
    procedure BtnDownRightMouseDown({%H-}const Data: BMouseData);
    procedure BtnUpLeftMouseUp({%H-}const Data: BMouseData);
    procedure BtnDownRightMouseUp({%H-}const Data: BMouseData);
    procedure BodyMouseDown({%H-}const Data: BMouseData);

    procedure OnChangeMVP({%H-}const Data: BTransformData);
    procedure OnSliderMouseDown({%H-}const Data: BMouseData);
    procedure OnSliderMouseUp({%H-}const Data: BMouseData);

    procedure SetPosition(const Value: Int64);
    procedure SetSize(const Value: Int64);
    function GetSliderIsHide: boolean;

    procedure SetStep(const Value: Int32);
    procedure CheckSizeSlider;
    procedure SetPositionSlider;
    procedure FillColors;
    procedure UpdatePostion;
    procedure OnWaitTime(const AValue: BSFloat);
    procedure DoChangePosition; inline;
  protected
    BtnUpLeft: TRectangle;
    BtnDownRight: TRectangle;
    Slider: TRectangle;
    procedure SetEnabled(const Value: boolean); override;
    procedure SetColor(const Value: TGuiColor); override;
    procedure SetScalable(const Value: boolean); override;
    procedure SetVisible(const Value: boolean); override;
    procedure DoAfterScale; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BuildView; override;
    function DefaultSize: TVec2f; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property SliderIsHide: boolean read GetSliderIsHide;
    property Horizontal: boolean read FHorizontal write SetHorizontal;
    { position }
    property Position: Int64 read FPosition write SetPosition;
    { max scrolling area, pixels if Scalable = true otherwise points }
    property Size: Int64 read FSize write SetSize;
    { step scroll; like Size if Scalable, then Step measured in points, otherwise pixels }
    property Step: Int32 read FStep write SetStep;
    property OnChangePosition: TChangeScrollBarPosition read FOnChangePosition write FOnChangePosition;
  published
    property Color;
  end;

implementation

uses
    bs.geometry
  , bs.math
  , bs.thread
  , bs.config
  ;

{ TBScrollBar }

procedure TBScrollBar.OnChangeMVP(const Data: BTransformData);
begin
  if SliderMvpChanging then
    exit;
  SliderMvpChanging := true;
  try
    if FIsMouseDownOnSlider then
    begin
      //SliderPositionCorrect;
      UpdatePostion;
    end;
  finally
    SliderMvpChanging := false;
  end;
end;

procedure TBScrollBar.DoAfterScale;
begin
  inherited;
  CheckSizeSlider;
end;

procedure TBScrollBar.OnSliderMouseDown(const Data: BMouseData);
begin
  FIsMouseDownOnSlider := true;
  FCanvas.Renderer.BanResetSelected := true;
end;

procedure TBScrollBar.OnSliderMouseUp(const Data: BMouseData);
begin
  FIsMouseDownOnSlider := false;
  FCanvas.Renderer.BanResetSelected := false;
  FCanvas.Renderer.Scene.InstanceSetSelected(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance, false);
end;

procedure TBScrollBar.OnWaitTime(const AValue: BSFloat);
begin
  if TBTimer.CurrentTime.Low - TimeDown < 1000 then
    exit;
  if WaitTimerUp then
  begin
    if not Slider.Data.Hidden and (FPosition + 1 + Slider.Height < FSize) then
      Position := FPosition + FStep
    else
      WaitTimer.Stop;
  end else
  begin
    if not Slider.Data.Hidden and (FPosition - FStep >= 0) then
      Position := FPosition - FStep
    else
      WaitTimer.Stop;
  end;
end;

procedure TBScrollBar.BodyMouseDown(const Data: BMouseData);
var
  page_size: int32;
  abs_pos: TVec3f;
  p_inters: TVec3f;
begin
  if (FStep = 0) or (Slider.Data.Hidden) then
    exit;
  page_size := round(FBody.Height / FStep)*round(FStep);
  Canvas.Renderer.HitTestInstance(Data.x, Data.y, PRendererGraphicInstance(Data.BaseHeader.Instance).Instance, p_inters);
  abs_pos := TVec3f(Slider.Data.BaseInstance.ProdStackModelMatrix.M3 - BtnUpLeft.Data.BaseInstance.ProdStackModelMatrix.M3);
  if VecLen(abs_pos) < VecLen(p_inters - BtnUpLeft.Data.BaseInstance.ProdStackModelMatrix.M3) then
    Position := FPosition + page_size
  else
    Position := FPosition - page_size;
end;

procedure TBScrollBar.BtnDownRightMouseDown(const Data: BMouseData);
begin
  if not Slider.Data.Hidden and (FPosition + 1 + Slider.Height < FSize) then
  begin
    Position := FPosition + FStep;
    WaitTimerUp := true;
    WaitTimer.Run;
    TimeDown := TBTimer.CurrentTime.Low;
  end;
end;

procedure TBScrollBar.BtnDownRightMouseUp(const Data: BMouseData);
begin
  WaitTimer.Stop;
end;

procedure TBScrollBar.BtnUpLeftMouseDown(const Data: BMouseData);
begin
  if not Slider.Data.Hidden and (FPosition > 0) then
  begin
    Position := FPosition - FStep;
    WaitTimerUp := true;
    WaitTimer.Run;
    TimeDown := TBTimer.CurrentTime.Low;
  end;
end;

procedure TBScrollBar.BtnUpLeftMouseUp(const Data: BMouseData);
begin
  WaitTimer.Stop;
end;

procedure TBScrollBar.CheckSizeSlider;
var
  s, w, k: double;
begin
  if (Width = 0) or (FBody.Height = 0) then
    exit;
  // max size slider
  {if Canvas.Scalable then
    w := FBody.Height*Canvas.ScaleInv
  else }
    w := FBody.Height;

  if w = 0 then
    w := 1.0;

  k := FSize / w;

  if w >= FSize then
  begin
    Slider.Data.Hidden := true;
  end else
  if Slider.Data.Hidden then
  begin
    Slider.Data.Hidden := false;
  end;

  if not Slider.Data.Hidden then
  begin
    w := w - FBody.Width*2;
    s := round(w/k);
    if s < MIN_SIZE_SLIDER then
      s := MIN_SIZE_SLIDER;
    Slider.Size := vec2(FBody.Width, s);
    Slider.Build;
    //w_btn_up_down := BtnUpLeft.Data.Mesh.FBoundingBox.y_max*2;
    // self size
    //Len := Slider.Data.Mesh.FBoundingBox.y_max;
    // define position limits
    s := FBody.Data.ServiceScale*FBody.Data.Mesh.FBoundingBox.y_max - BtnUpLeft.Data.ServiceScale*BtnUpLeft.Data.Mesh.FBoundingBox.y_max*2 -
      Slider.Data.Mesh.FBoundingBox.y_max*Slider.Data.ServiceScale;
    Slider.Data.PositionLimits := box3(vec3(0.0, -s, 0.0),  vec3(0.0, s, 0.0));
    SetPositionSlider;
  end;

end;

constructor TBScrollBar.Create(ACanvas: TBCanvas);
var
  scaledFour: BSFloat;
begin
  inherited Create(ACanvas);

  FStep := 1;
  FSize := 1000;

  FMainBody := TRectangle.Create(FCanvas, nil);
  FMainBody.Data.Hidden := true;
  TRectangle(FMainBody).Fill := true;
  TRectangle(FMainBody).Size := DefaultSize;
  FMainBody.Data.SelectResolve := false;
  FMainBody.Data.Opacity := 0.0;
  FMainBody.Data.Interactive := false;

  FBody := TRectangle.Create(Canvas, FMainBody);
  FBody.Data.Interactive := false;
  FBody.Fill := true;
  FBody.Size := DefaultSize;
  FBody.Data.SelectResolve := false;
  FBody.Color := vec4(0.843, 0.827, 0.827, 1.0);
  FMainBody.Color := FBody.Color;

  FOnMouseEnterLeaveBody := TOnMouseColorExchanger.Create(FBody);
  ObsrvBodyMD := FBody.Data.EventMouseDown.CreateObserver(GUIThread, BodyMouseDown);

  // create button Up/Left
  BtnUpLeft := TRectangle.Create(FCanvas, FBody);
  BtnUpLeft.Fill := true;
  BtnUpLeft.Data.DragResolve := false;
  BtnUpLeft.Data.SelectResolve := false;
  BtnUpLeft.Size := vec2(FBody.Size.Width, FBody.Size.Width);
  ObsrvBtnUpLeftMD := BtnUpLeft.Data.EventMouseDown.CreateObserver(GUIThread, BtnUpLeftMouseDown);
  ObsrvBtnUpLeftMU := BtnUpLeft.Data.EventMouseUp.CreateObserver(GUIThread, BtnUpLeftMouseUp);
  FOnMouseEnterLeaveLeftUpBtn := TOnMouseMoveAndClickColorExchanger.Create(BtnUpLeft);

  // create button Right/Down
  BtnDownRight := TRectangle.Create(FCanvas, FBody);
  BtnDownRight.Fill := true;
  BtnDownRight.Data.DragResolve := false;
  BtnDownRight.Data.SelectResolve := false;
  BtnDownRight.Size := BtnUpLeft.Size;
  ObsrvBtnDwnRgtMD := BtnDownRight.Data.EventMouseDown.CreateObserver(GUIThread, BtnDownRightMouseDown);
  ObsrvBtnDwnRgtMU := BtnDownRight.Data.EventMouseUp.CreateObserver(GUIThread, BtnDownRightMouseUp);
  FOnMouseEnterLeaveRightDownBtn := TOnMouseMoveAndClickColorExchanger.Create(BtnDownRight);

  // create triangle inside buttons
  TriUp := TTriangle.Create(FCanvas, BtnUpLeft);
  TriUp.Fill := true;
  TriUp.Data.SelectResolve := false;
  TriUp.Data.Interactive := false;

  TriDown := TTriangle.Create(FCanvas, BtnDownRight);
  TriDown.Fill := true;
  TriDown.Data.SelectResolve := false;
  TriDown.Data.Interactive := false;

  // create slider
  Slider := TRectangle.Create(FCanvas, FBody);
  Slider.Fill := true;
  Slider.Data.DragResolve := true;
  Slider.Data.SelectResolve := false;
  Slider.BanScalableMode := true;
  Slider.Layer2d := Slider.Layer2d + 3;

  scaledFour := round(4*ToHiDpiScale);

  TriUp.A := vec2(0.0, scaledFour);
  TriUp.B := vec2(scaledFour, 0.0);
  TriUp.C := vec2(scaledFour*2, scaledFour);
  TriDown.A := vec2(0.0, 0.0);
  TriDown.B := vec2(scaledFour*2, 0.0);
  TriDown.C := vec2(scaledFour, scaledFour);
  TriUp.Build;
  TriDown.Build;

  ObsrvSliderChMVP := Slider.Data.EventChangeMVP.CreateObserver(GUIThread, OnChangeMVP);
  ObsrvSliderMD := Slider.Data.EventMouseDown.CreateObserver(GUIThread, OnSliderMouseDown);
  ObsrvSliderMU := Slider.Data.EventMouseUp.CreateObserver(GUIThread, OnSliderMouseUp);

  FOnMouseEnterLeaveSlider := TOnMouseMoveAndClickColorExchanger.Create(Slider);

  FillColors;

  WaitTimer := CreateAniFloatLinear(GUIThread);
  WaitTimer.Duration := 10000;
  WaitTimer.IntervalUpdate := 50;
  WaitTimer.Loop := true;
  WaitTimerObsrv := CreateAniFloatLivearObsrv(WaitTimer, OnWaitTime);
end;

function TBScrollBar.DefaultSize: TVec2f;
begin
  Result.x := round(DEFAULT_WIDTH*ToHiDpiScale);
  Result.y := round(DEFAULT_HEIGHT*ToHiDpiScale);
end;

destructor TBScrollBar.Destroy;
begin
  ObsrvBodyMD := nil;
  ObsrvBtnUpLeftMU := nil;
  ObsrvBtnDwnRgtMU := nil;
  ObsrvSliderMU := nil;
  ObsrvSliderMD := nil;
  ObsrvSliderChMVP := nil;

  FOnMouseEnterLeaveSlider.Free;
  FOnMouseEnterLeaveRightDownBtn.Free;
  FOnMouseEnterLeaveLeftUpBtn.Free;
  FOnMouseEnterLeaveBody.Free;
  inherited;
end;

procedure TBScrollBar.DoChangePosition;
begin
  if Assigned(FOnChangePosition) then
    FOnChangePosition(Self);
end;

procedure TBScrollBar.BuildView;
begin
  inherited;

  if FHorizontal then
    FMainBody.Data.Angle := vec3(0.0, 0.0, -90);

  FMainBody.Build;
  FBody.Build;
  FBody.Position2d := vec2(0.0, 0.0);

  BtnUpLeft.Build;
  BtnUpLeft.Position2d := vec2(0, 0);

  BtnDownRight.Build;
  BtnDownRight.Position2d := vec2(0, FBody.Height - BtnUpLeft.Height);

  TriUp.ToParentCenter;
  TriDown.ToParentCenter;

  CheckSizeSlider;
end;

procedure TBScrollBar.FillColors;
var
  cl: TColor4f;
begin
  cl := FBody.Color;
  BtnUpLeft.Color := Color4f(cl.r*0.949, cl.g*0.931, cl.b*0.907, 1.0);
  BtnDownRight.Color := BtnUpLeft.Color;

  FOnMouseEnterLeaveBody.Color := cl;
  FOnMouseEnterLeaveBody.ColorMouseEnter := Color4f(cl.r*0.881, cl.g*0.879, cl.b*0.879, 1.0);
  FOnMouseEnterLeaveLeftUpBtn.Color := BtnUpLeft.Color;
  FOnMouseEnterLeaveLeftUpBtn.ColorMouseEnter := Color4f(cl.r*0.644, cl.g*0.637, cl.b*0.637, 1.0);
  FOnMouseEnterLeaveLeftUpBtn.ColorMouseDown := Color4f(cl.r*0.525, cl.g*0.516, cl.b*0.516, 1.0);
  FOnMouseEnterLeaveRightDownBtn.Color := BtnUpLeft.Color;
  FOnMouseEnterLeaveRightDownBtn.ColorMouseEnter := FOnMouseEnterLeaveLeftUpBtn.ColorMouseEnter;
  FOnMouseEnterLeaveRightDownBtn.ColorMouseDown := FOnMouseEnterLeaveLeftUpBtn.ColorMouseDown;

  TriUp.Color := Color4f(cl.r*0.407, cl.g*0.395, cl.b*0.395, 1.0);
  TriDown.Color := TriUp.Color;

  Slider.Color := FOnMouseEnterLeaveLeftUpBtn.ColorMouseEnter;

  FOnMouseEnterLeaveSlider.Color := Slider.Color;
  FOnMouseEnterLeaveSlider.ColorMouseEnter := Color4f(cl.r*0.172, cl.g*0.154, cl.b*0.154, 1.0);
  FOnMouseEnterLeaveSlider.ColorMouseDown := Color4f(cl.r*0.209, cl.g*0.213, cl.b*0.213, 1.0);
end;

function TBScrollBar.GetSliderIsHide: boolean;
begin
  Result := Slider.Data.Hidden;
end;

procedure TBScrollBar.Resize(AWidth, AHeight: BSFloat);
begin
  TRectangle(FMainBody).Size := vec2(AWidth, AHeight);
  FBody.Size := vec2(AWidth, AHeight);
  BtnUpLeft.Size := vec2(AWidth, AWidth);
  BtnDownRight.Size := BtnUpLeft.Size;
  inherited;
end;

procedure TBScrollBar.SetColor(const Value: TGuiColor);
begin
  inherited SetColor(Value);
  FBody.Color := FMainBody.Color;
  FillColors;
end;

procedure TBScrollBar.SetEnabled(const Value: boolean);
begin
  if Assigned(FBody) then
    StateInteractive := FBody.Data.Interactive;
  inherited SetEnabled(Value);
  { the behavior is expected? }
  if Assigned(FBody) and (StateInteractive = FBody.Data.Interactive) then
  begin
    if FBody.Data.Interactive <> Value then
    begin
      FBody.Data.Interactive := Value;
      BtnUpLeft.Data.Interactive := Value;
      BtnDownRight.Data.Interactive := Value;
      Slider.Data.Interactive := Value;
    end;
  end;
end;

procedure TBScrollBar.SetVisible(const Value: boolean);
begin
  inherited;
  Slider.Data.Interactive := Value;
  BtnDownRight.Data.Interactive := Value;
  BtnUpLeft.Data.Interactive := Value;

  if Value then
    CheckSizeSlider
  else
    Slider.Data.Hidden := true;

  FBody.Data.Hidden := not Value;
  BtnDownRight.Data.Hidden := not Value;
  BtnUpLeft.Data.Hidden := not Value;
  TriUp.Data.Hidden := not Value;
  TriDown.Data.Hidden := not Value;
end;

procedure TBScrollBar.SetHorizontal(const Value: boolean);
begin
  if FHorizontal = Value then
    exit;
  FHorizontal := Value;
  if FHorizontal then
    FMainBody.Data.Angle := vec3(0.0, 0.0, -90.0)
  else
    FMainBody.Data.Angle := vec3(0.0, 0.0, 0);

  FBody.Position2d := vec2(0.0, 0.0);
end;

procedure TBScrollBar.SetPosition(const Value: Int64);
var
  pos: Int64;
begin
  if (FPosition = Value) then
    exit;

  pos := Clamp(FSize - round(FBody.Height), 0, Value);

  if pos < 0 then
    pos := 0;

  if pos = FPosition then
    exit;

  FPosition := pos;

  SetPositionSlider;
  DoChangePosition;
end;

procedure TBScrollBar.SetPositionSlider;
var
  pos: TVec2f;
  delta: BSFloat;
begin
  delta := FSize - FBody.Height;
  if delta < 1 then
    delta := 1;
  //if FSize > FBody.Size.Height then
    pos := vec2(0.0, FBody.Width + (FPosition/(delta)*(FBody.Height - FBody.Width*2 - Slider.Height)))
  {else
    pos := vec2(0.0, FBody.Width + (FPosition/FSize*(FBody.Height - FBody.Width*2)))};

  if pos.y + Slider.Height > BtnDownRight.Position2d.y then
    pos.y := BtnDownRight.Position2d.y - Slider.Height;

  Slider.Position2d := pos;
end;

procedure TBScrollBar.SetScalable(const Value: boolean);
begin

  if OwnCanvas then
    inherited;
end;

procedure TBScrollBar.SetSize(const Value: Int64);
begin
  if FSize = Value then
    exit;
  FSize := Value;
  if FSize <= 0 then
    FSize := 1;

  CheckSizeSlider;

  if FPosition > Value then
  begin
    if Slider.Data.Hidden then
      FPosition := 0
    else
      FPosition := Value - 1;
    SetPositionSlider;
  end;

end;

procedure TBScrollBar.SetStep(const Value: Int32);
begin
  if FStep = Value then
    exit;
  FStep := Value;
  CheckSizeSlider;
end;

procedure TBScrollBar.UpdatePostion;
var
  w: BSFloat;
begin
  { calc a new position over a data }
  if abs(Slider.Height - MIN_SIZE_SLIDER) < EPSILON then
  begin
    w := FBody.Height - FBody.Width*2 - Slider.Height;
  end else
  begin
    w := FBody.Height - FBody.Width*2;
  end;
  FPosition := Round(((Slider.Position2d.y - FBody.Width) / w) * FSize);
  FPosition := clamp(FSize, 0, FPosition);
  DoChangePosition;
end;

initialization
  TBControl.ControlRegister('GUI', TBScrollBar);

end.
