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


unit bs.gui.trackbar;

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
  TBCustomTrackBar = class;

  TChangeTrackBarPosition = procedure(TrackBar: TBCustomTrackBar) of object;

  TBCustomTrackBar = class(TBControl)
  private
    const
      DEFAULT_WIDTH = 300;
      DEFAULT_HEIGHT = 18;
      MIN_SIZE_SLIDER  = 5;
  private
    FSlider: TRectangle;
    FSize: double;
    ObsrvSliderChMVP: IBChangeMVPEventObserver;
    ObsrvSliderMU: IBMouseDownEventObserver;
    ObsrvSliderMD: IBMouseDownEventObserver;
    FOnChangePosition: TChangeTrackBarPosition;
    FPosition: double;
    FIsMouseDownOnSlider: boolean;
    FHorizontal: boolean;
    SliderMvpChanging: boolean;
    procedure SetSize(const Value: double);
    procedure SetPosition(const Value: double);
    procedure UpdateSliderPosition;
    procedure OnDragSlider({%H-}const Data: BTransformData);
    procedure OnSliderMouseDown({%H-}const Data: BMouseData);
    procedure OnSliderMouseUp({%H-}const Data: BMouseData);
    procedure SetHorizontal(const Value: boolean);
  protected
    function GetHeight: BSFloat; override;
    function GetWidth: BSFloat; override;
    procedure DoChangePosition; virtual;
    procedure SetVisible(const Value: boolean); override;
    procedure DoAfterScale; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure BuildView; override;
    procedure UpdateSliderPositionLimits;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DefaultSize: TVec2f; override;
    property Size: double read FSize write SetSize;
    property Position: double read FPosition write SetPosition;
    property Horizontal: boolean read FHorizontal write SetHorizontal;
    property Slider: TRectangle read FSlider;
    property OnChangePosition: TChangeTrackBarPosition read FOnChangePosition write FOnChangePosition;
  end;

  TBTrackBar = class(TBCustomTrackBar)
  published

  end;

implementation

uses
    bs.config
  , bs.thread
  , bs.math
  , bs.geometry
  ;

{ TBCustomTrackBar }

procedure TBCustomTrackBar.DoAfterScale;
begin
  inherited DoAfterScale;
  UpdateSliderPositionLimits;
end;

procedure TBCustomTrackBar.BuildView;
begin
  MainBody.Build;
  FSlider.Build;
  UpdateSliderPositionLimits;
  UpdateSliderPosition;
end;

constructor TBCustomTrackBar.Create(ACanvas: TBCanvas);
begin
  inherited;
  FSize := 100.0;
  FHorizontal := true;
  FMainBody := TRectangle.Create(Canvas, nil);
  TRectangle(MainBody).Fill := true;
  TRectangle(MainBody).Size := vec2(DEFAULT_WIDTH, (DEFAULT_HEIGHT shr 1));
  TRectangle(MainBody).Color := BS_CL_MSVS_PANEL;
  TRectangle(MainBody).Data.Interactive := false;
  FSlider := TRectangle.Create(Canvas, MainBody);
  FSlider.Fill := true;
  FSlider.Size := vec2(MIN_SIZE_SLIDER, DEFAULT_HEIGHT);
  FSlider.Color := BS_CL_MSVS_EDIT_CURSOR_LINE;

  ObsrvSliderChMVP := FSlider.Data.EventChangeMVP.CreateObserver(GUIThread, OnDragSlider);
  ObsrvSliderMD := FSlider.Data.EventMouseDown.CreateObserver(GUIThread, OnSliderMouseDown);
  ObsrvSliderMU := FSlider.Data.EventMouseUp.CreateObserver(GUIThread, OnSliderMouseUp);
end;

function TBCustomTrackBar.DefaultSize: TVec2f;
begin
  Result := vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
end;

procedure TBCustomTrackBar.DoChangePosition;
begin
  if Assigned(FOnChangePosition) then
    FOnChangePosition(Self);
end;

function TBCustomTrackBar.GetHeight: BSFloat;
begin
  Result := TRectangle(MainBody).Size.Height;
end;

function TBCustomTrackBar.GetWidth: BSFloat;
begin
  Result := TRectangle(MainBody).Size.Width;
end;

procedure TBCustomTrackBar.OnDragSlider(const Data: BTransformData);
var
  w: BSFloat;
  ms: BSFloat;
begin
  if SliderMvpChanging then
    exit;
  SliderMvpChanging := true;
  try
    if FIsMouseDownOnSlider then
    begin
      { calc a new position over a data }
      ms := MIN_SIZE_SLIDER;
      if abs(FSlider.Size.Width - ms) < EPSILON then
      begin
        w := TRectangle(MainBody).Size.Width - FSlider.Size.Width;
      end else
      begin
        w := TRectangle(MainBody).Size.Width;
      end;
      FPosition := Round((FSlider.Position2d.x / w) * FSize);
      FPosition := clamp(FSize, 0.0, FPosition);
      DoChangePosition;
    end;
  finally
    SliderMvpChanging := false;
  end;
end;

procedure TBCustomTrackBar.OnSliderMouseDown(const Data: BMouseData);
begin
  FIsMouseDownOnSlider := true;
end;

procedure TBCustomTrackBar.OnSliderMouseUp(const Data: BMouseData);
begin
  FIsMouseDownOnSlider := false;
end;

procedure TBCustomTrackBar.Resize(AWidth, AHeight: BSFloat);
begin
  TRectangle(MainBody).Size := vec2(AWidth, AHeight);
  inherited;
end;

procedure TBCustomTrackBar.SetHorizontal(const Value: boolean);
begin
  if FHorizontal = Value then
    exit;
  FHorizontal := Value;
  if FHorizontal then
    MainBody.Data.Angle := vec3(0.0, 0.0, 0.0)
  else
    MainBody.Data.Angle := vec3(0.0, 0.0, -90.0);
end;

procedure TBCustomTrackBar.SetPosition(const Value: double);
var
  pos: double;
begin
  if FPosition = Value then
    exit;
  pos := Clamp(FSize, 0.0, Value);
  if pos = FPosition then
    exit;
  FPosition := pos;
  UpdateSliderPosition;
  DoChangePosition;
end;

procedure TBCustomTrackBar.SetSize(const Value: double);
begin
  FSize := Value;
end;

procedure TBCustomTrackBar.SetVisible(const Value: boolean);
begin
  inherited;
  FSlider.Data.Hidden := not Value;
  FSlider.Data.Interactive := Value;
end;

procedure TBCustomTrackBar.UpdateSliderPosition;
begin
  FSlider.Position2d := vec2((FPosition/FSize*TRectangle(MainBody).Size.Width), -(FSlider.Height -  TRectangle(MainBody).Size.Height) * 0.5);
end;

procedure TBCustomTrackBar.UpdateSliderPositionLimits;
begin
  FSlider.Data.PositionLimits := Box3(
    vec3(MainBody.Data.ServiceScale*MainBody.Data.Mesh.FBoundingBox.x_min+FSlider.Data.ServiceScale*FSlider.Data.Mesh.FBoundingBox.x_max, 0.0, 0.0),
    vec3(MainBody.Data.ServiceScale*MainBody.Data.Mesh.FBoundingBox.x_max-FSlider.Data.ServiceScale*FSlider.Data.Mesh.FBoundingBox.x_max, 0.0, 0.0)
  );
end;

initialization
  TBControl.ControlRegister('GUI', TBTrackBar);

end.
