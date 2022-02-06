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

unit bs.gui.menu;

{$I BlackSharkCfg.inc}

interface

uses
  {$ifndef FPC}
    System.Math,
  {$endif}
    bs.basetypes
  , bs.events
  , bs.scene
  , bs.canvas
  , bs.scene.objects
  , bs.gui.base
  , bs.gui.themes
  ;

type
  TBRadialSlider = class;

  TOnChangeDegree = procedure (Sender: TBRadialSlider) of object;

  TBRadialSlider = class(TBControl)
  private
    FCaption: TCanvasText;
    FDegreeText: TCanvasText;
    ObsrvMDBody: IBMouseDownEventObserver;
    ObsrvMDPoint: IBMouseDownEventObserver;
    ObsrvScnMM: IBMouseDownEventObserver;
    ObsrvScnMU: IBMouseDownEventObserver;
    FBorder: TCircle;
    Arc: TArc;
    RadiusF: BSFloat;
    RadiusF5: BSFloat;
    FDegree: BSFloat;
    DragBody: TCircle;
    Lines: TGraphicObjectLines;
    DraggingPoint: boolean;
    CenterPos: TVec2f;
    FOnChangeDegree: TOnChangeDegree;
    FShowArrow: boolean;
    FArrowDegree: BSFloat;
    FResetPositionEveryTime: boolean;
    FDragPoint: TCanvasObject;
    procedure SetCaption(const Value: string);
    function GetCaption: string;
    procedure SetRadius(const Value: BSFloat);
    procedure SetDegree(const Value: BSFloat);

    procedure OnMouseDownOnPoint({%H-}const {%H-}Data: BMouseData);
    procedure OnMouseMove({%H-}const Data: BMouseData);
    procedure OnMouseUp({%H-}const {%H-}Data: BMouseData);

    procedure SetShowArrow(const Value: boolean);
    procedure SetArrowDegree(const Value: BSFloat);
    function GetCaptionColor: TColor4f;
    procedure SetCaptionColor(const Value: TColor4f);
    function GetRadius: BSFloat;
  protected
    procedure SetVisible(const Value: boolean); override;
    function GetHeight: BSFloat; override;
    function GetWidth: BSFloat; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    function DefaultSize: TVec2f; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property OnChangeDegree: TOnChangeDegree read FOnChangeDegree write FOnChangeDegree;
    property Caption: string read GetCaption write SetCaption;
    property CaptionColor: TColor4f read GetCaptionColor write SetCaptionColor;
    property Radius: BSFloat read GetRadius write SetRadius;
    property Degree: BSFloat read FDegree write SetDegree;
    property Border: TCircle read FBorder;
    property DragPoint: TCanvasObject read FDragPoint;
    property ShowArrow: boolean read FShowArrow write SetShowArrow;
    property ArrowDegree: BSFloat read FArrowDegree write SetArrowDegree;
    property ResetPositionEveryTime: boolean read FResetPositionEveryTime write FResetPositionEveryTime;
    property Rotating: boolean read DraggingPoint;
    { property for subscribe on events }
    property BodyObject: TCircle read DragBody;
  end;

implementation

uses
    SysUtils
  , bs.math
  , bs.config
  , bs.texture
  , bs.utils
  , bs.thread
  ;

{ TBRadialSlider }

procedure TBRadialSlider.BuildView;
var
  v: TVec3f;
  s, c: BSFloat;
  z: BSFloat;
begin
  DragBody.Build;
  //DragBody.Position2d := vec2(0.0, 0.0);
  FBorder.Build;
  //FBorder.Position2d := vec2(0.0, 0.0); // -FRadius
  FDragPoint.Build;
  //FDragPoint.Position2d := vec2(0.0, 0.0);

  FDegreeText.Text := Format('%f°', [FDegree]);
  FDegreeText.Position2d := vec2((DragBody.Width - FDegreeText.Width)*0.5, (DragBody.Height - FDegreeText.Height)*0.5);
  BS_SinCos(90 + FDegree, s, c);
  v := vec3(RadiusF5*c, RadiusF5*s, FDragPoint.Layer2d * FCanvas.Renderer.Frustum.DISTANCE_2D_BW_LAYERS);
  z := FCanvas.Renderer.Frustum.DISTANCE_2D_BW_LAYERS;
  Lines.Clear;
  Lines.BeginUpdate;
  Lines.Line(vec3(-RadiusF, 0.0, z), vec3(RadiusF, 0.0, z));
  Lines.Line(vec3(0.0, RadiusF, z), vec3(0.0, -RadiusF, z));
  Lines.Line(vec3(-RadiusF, 0.0, z), vec3(RadiusF, 0.0, z));
  Lines.Line(vec3(0.0, 0.0, z), vec3(v.x, v.y, z));

  if FShowArrow then
  begin
    { TODO: ShowArrow }
  end;

  Lines.EndUpdate(true);

  FDragPoint.Data.Position := v;
  Arc.Angle := FDegree;
  Arc.Build;
  if FDegree < 90 then
    Arc.Position2d := vec2(Arc.Radius - abs(Arc.Radius*c), 0.0)
  else
    Arc.Position2d := vec2(0.0, 0.0);
end;

constructor TBRadialSlider.Create(ACanvas: TBCanvas);
var
  f_tex: string;
  texture: PTextureArea;
  s_def: TVec2f;
begin
  inherited;
  ObsrvScnMM := FCanvas.Renderer.EventMouseMove.CreateObserver(GUIThread, OnMouseMove);
  ObsrvScnMU := FCanvas.Renderer.EventMouseUp.CreateObserver(GUIThread, OnMouseUp);
  s_def := DefaultSize;
  RadiusF := BSConfig.VoxelSize * s_def.Width;

  RadiusF5 := RadiusF - RadiusF * 0.2;
  FCanvas.Font.SizeInPixels := 10;
  DragBody := TCircle.Create(FCanvas, nil);
  DragBody.Radius := s_def.Width;
  DragBody.Fill := true;
  DragBody.Color := BS_CL_BLUE;
  DragBody.Data.DragResolve := false;
  FMainBody := DragBody;
  ObsrvMDBody := DragBody.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownOnPoint);
  DragBody.Data.Opacity := 0.2;
  FBorder := TCircle.Create(FCanvas, DragBody);
  FBorder.Radius := s_def.Width;
  FBorder.Data.Interactive := false;
  FBorder.Color := BS_CL_ORANGE_2;
  FCaption := TCanvasText.Create(FCanvas, FBorder);
  FCaption.Data.Interactive := false;
  FCaption.Color := BS_CL_WHITE;

  FCaption.Layer2d := 3;
  FDegreeText := TCanvasText.Create(FCanvas, FBorder);
  FDegreeText.Text := '0.0°';
  FDegreeText.Position2d := vec2(s_def.Width - FDegreeText.Width*0.5, s_def.Width - FDegreeText.Height*0.5);
  FDegreeText.Data.Interactive := false;
  FDegreeText.Layer2d := 3;
  FDegreeText.Color := BS_CL_WHITE;
  Lines := TGraphicObjectLines.Create(nil, DragBody.Data, FCanvas.Renderer.Scene);
  Lines.Interactive := false;
  Lines.Color := BS_CL_SILVER;
  Lines.Opacity := 0.1;
  { for avoid exeption first check exists whether a file for texture }
  f_tex := GetFilePath('Pictures/rot_point.png');
  if FileExists(f_tex) then
    texture := BSTextureManager.LoadTexture(f_tex, true, true)
  else
    texture := nil;

  { select simple factory and GraphicItemClass if not found texture for points }
  if texture = nil then
  begin
    FDragPoint := TCircle.Create(FCanvas, FBorder);
    TCircle(FDragPoint).Radius := (s_def.Width - 1) * 0.2;
    TCircle(FDragPoint).Fill := true;
  end else
  begin
    FDragPoint := TCircleTextured.Create(FCanvas, FBorder);
    TCircleTextured(FDragPoint).Radius := (s_def.Width - 1) * 0.2;
    TCircleTextured(FDragPoint).Fill := true;
    TTexturedVertexes(FDragPoint.Data).Texture := texture;
  end;

  FDragPoint.Data.DragResolve := false;
  FDragPoint.Data.SelectResolve := false;
  ObsrvMDPoint := FDragPoint.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownOnPoint);
  FDragPoint.Layer2d := 4;
  FDragPoint.Data.Interactive := false;
  Arc := TArc.Create(FCanvas, DragBody);
  { every time when a user rotate, changes a mesh this object, therefor a property
    below set to off }
  Arc.Data.StaticObject := false;
  Arc.Color := BS_CL_GREEN;
  Arc.Radius := DragBody.Radius;
  Arc.Fill := true;
  Arc.StartAngle := 90;
  Arc.Data.Opacity := 0.3;
  Arc.Data.Interactive := false;
  Visible := false;
end;

function TBRadialSlider.DefaultSize: TVec2f;
begin
  { return radius as size }
  if FCanvas.Scalable then
  begin
    Result := vec2(6, 6);
  end else
  begin
    Result := vec2(30, 30);
  end;
end;

destructor TBRadialSlider.Destroy;
begin
  ObsrvMDBody := nil;
  ObsrvMDPoint := nil;
  ObsrvScnMM := nil;
  ObsrvScnMU := nil;
  inherited;
end;

function TBRadialSlider.GetCaption: string;
begin
  Result := FCaption.Text;
end;

function TBRadialSlider.GetCaptionColor: TColor4f;
begin
  Result := FCaption.Color;
end;

function TBRadialSlider.GetHeight: BSFloat;
begin
  Result := DragBody.Radius * 2;
end;

function TBRadialSlider.GetRadius: BSFloat;
begin
  Result := Width;
end;

function TBRadialSlider.GetWidth: BSFloat;
begin
  Result := DragBody.Radius * 2;
end;

procedure TBRadialSlider.OnMouseDownOnPoint(const Data: BMouseData);
begin
  DraggingPoint := true;
  CenterPos := FBorder.AbsolutePosition2d + FBorder.Radius;
end;

procedure TBRadialSlider.OnMouseMove(const Data: BMouseData);
var
  p: TVec2i;
begin
  if not DraggingPoint then
    exit;
  p := (vec2(Data.X - CenterPos.x, CenterPos.y - Data.Y));
  FDegree := AngleEulerClamp(VecDecisionY(p));
  BuildView;
  FOnChangeDegree(Self);
end;

procedure TBRadialSlider.OnMouseUp(const Data: BMouseData);
begin
  DraggingPoint := false;
  if FResetPositionEveryTime then
  begin
    FDegree := 0.0;
    BuildView;
  end;
end;

procedure TBRadialSlider.Resize(AWidth, AHeight: BSFloat);
begin
  RadiusF := BSConfig.VoxelSize * AWidth;
  RadiusF5 := BSConfig.VoxelSize * (AWidth * 0.1 - 1);
  inherited;
end;

procedure TBRadialSlider.SetArrowDegree(const Value: BSFloat);
begin
  FArrowDegree := Value;
  BuildView;
end;

procedure TBRadialSlider.SetCaption(const Value: string);
begin
  FCaption.Text := Value;
  FCaption.Position2d := vec2(FBorder.Radius, -(FCaption.Height + 3));
end;

procedure TBRadialSlider.SetCaptionColor(const Value: TColor4f);
begin
  FCaption.Color := Value;
end;

procedure TBRadialSlider.SetDegree(const Value: BSFloat);
begin
  FDegree := Value;
  BuildView;
end;

procedure TBRadialSlider.SetVisible(const Value: boolean);
begin
  inherited;
  Lines.Hidden := not Value;
  DragBody.Data.Hidden := not Value;
  FBorder.Data.Hidden := not Value;
  FDegreeText.Data.Hidden := not Value;
  FCaption.Data.Hidden := not Value;
  FDragPoint.Data.Hidden := not Value;

  DragBody.Data.Interactive := Value;
  //FBorder.Data.Hidden := not Value;
end;

procedure TBRadialSlider.SetRadius(const Value: BSFloat);
begin
  Resize(Value, Value);
end;

procedure TBRadialSlider.SetShowArrow(const Value: boolean);
begin
  FShowArrow := Value;
  BuildView;
end;

end.
