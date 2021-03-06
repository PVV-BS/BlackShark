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

unit bs.gui.buttons;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.canvas
  , bs.scene
  , bs.gui.base
  , bs.gui.themes
  , bs.gui.themes.primitives
  , bs.texture
  , bs.animation
  ;

type

  {$M+}

  { TBButton }

  TBButton = class(TBControl)
  private
    const
      DEFAULT_WIDTH = 120;
      DEFAULT_HEIGHT = 35;
  private
    {$ifndef ANDROID}
    AniLawScale: IBAnimationLinearFloat;
    AniLawTransparent: IBAnimationLinearFloat;
    ObsrvScale: IBAnimationLinearFloatObsrv;
    ObsrvTransparent: IBAnimationLinearFloatObsrv;
    {$endif}

    InvisibleBody: TRectangle;
    FCaption: TCanvasText;

    ObsrvMD: IBMouseDownEventObserver;
    ObsrvMU: IBMouseUpEventObserver;
    ObsrvMDbl: IBMouseUpEventObserver;
    {$ifndef ANDROID}
    ObsrvME: IBMouseEnterEventObserver;
    {$endif}
    ObsrvML: IBMouseLeaveEventObserver;

    FOnClickEvent: IBMouseUpEvent;
    FBackground: TRoundRect;
    FBorder: TRoundRect;
    FHolderGUI: TCanvasObject;
    FRoundRadius: BSFloat;
    FWidthBorder: BSFloat;
    FShowBorder: Boolean;
    FOpacity: BSFloat;
    FBorderColor: TGuiColor;
    FCaptionColor: TGuiColor;
    FMouseDataDblClick: BMouseData;

    function GetCaption: string;

    {$ifndef ANDROID}
    procedure OnChangeValueScale(const Value: BSFloat);
    procedure OnChangeValueTransparent(const Value: BSFloat);
    {$endif}

    procedure SetCaption(AValue: string);
    procedure SetOpacity(const Value: BSFloat);
    procedure SetWidthBorder(const Value: BSFloat);
    function GetSize: TVec2f;
    procedure SetSize(const Value: TVec2f);
    procedure SetBorderColor(const Value: TGuiColor);
    procedure SetCaptionColor(const Value: TGuiColor);
    procedure SetRoundRadius(const Value: BSFloat);
    procedure CreateBorder;
    procedure SetShowBorder(const Value: Boolean);
    procedure AwaitDblClick(AData: Pointer);
  protected
    procedure OnMouseDown(const {%H-}Value: BMouseData); virtual;
    procedure OnMouseUp(const {%H-}Value: BMouseData); virtual;
    procedure OnMouseDblClick(const {%H-}Value: BMouseData); virtual;
    {$ifndef ANDROID}
    procedure OnMouseEnter(const {%H-}Value: BMouseData); virtual;
    {$endif}
    procedure OnMouseLeave(const {%H-}Value: BMouseData); virtual;

    procedure SetColor(const Value: TGuiColor); override;
    function GetWidth: BSFloat; override;
    function GetHeight: BSFloat; override;
    procedure SetScalable(const Value: boolean); override;
    procedure SetVisible(const Value: boolean); override;
    procedure SetPosition2d(const Value: TVec2f); override;
    procedure DoAfterScale; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    function DefaultSize: TVec2f; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property Size: TVec2f read GetSize write SetSize;
    property Border: TRoundRect read FBorder;
    property Text: TCanvasText read FCaption;
    property OnClickEvent: IBMouseUpEvent read FOnClickEvent;
  published
    property Caption: string read GetCaption write SetCaption;
    property Opacity: BSFloat read FOpacity write SetOpacity;
    property BorderWidth: BSFloat read FWidthBorder write SetWidthBorder;
    property BorderColor: TGuiColor read FBorderColor write SetBorderColor;
    property CaptionColor: TGuiColor read FCaptionColor write SetCaptionColor;
    property RoundRadius: BSFloat read FRoundRadius write SetRoundRadius;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder;
    property Background: TRoundRect read FBackground;
    property Color;
    property Width;
    property Height;
  end;

implementation

uses
    SysUtils
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  , bs.thread
  , bs.graphics
  , bs.math
  , bs.config
  , bs.align
  {$ifndef fpc}
  , bs.mesh // for support inline TCanvasObject.Width/Height in Delphi
  {$endif}
  ;

  { TBButton }

{$ifndef ANDROID}
procedure TBButton.OnChangeValueScale(const Value: BSFloat);
begin
  if not AniLawScale.IsRun then
    exit;
  FHolderGUI.Data.Scale := vec3(Value, Value, 1.0);
  FHolderGUI.Position2d := vec2(-FBackground.Size.x*(Value - 1.0)*0.5, -FBackground.Size.y*(Value - 1)*0.5);
end;

procedure TBButton.OnChangeValueTransparent(const Value: BSFloat);
begin
  if not AniLawTransparent.IsRun then
    exit;
  FBackground.Data.Opacity := Value;
end;
{$endif}

procedure TBButton.Resize(AWidth, AHeight: BSFloat);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBButton.Resize', 'AWidth, AHeight: ' + IntToStr(round(AWidth)) + ', ' + IntToStr(round(AHeight)));
  {$endif}
  InvisibleBody.Size := vec2(AWidth, AHeight);
  if Assigned(FBorder) then
  begin
    FBorder.Size := InvisibleBody.Size;
  end;
  FBackGround.Size := vec2(AWidth, AHeight);
  inherited;
end;

function TBButton.GetCaption: string;
begin
  Result := FCaption.Text;
end;

function TBButton.GetHeight: BSFloat;
begin
  if Assigned(InvisibleBody) then
    Result := InvisibleBody.Size.Height
  else
    Result := DefaultSize.Height;
end;

function TBButton.GetSize: TVec2f;
begin
  Result := vec2(InvisibleBody.Width, InvisibleBody.Height);
end;

function TBButton.GetWidth: BSFloat;
begin
  if Assigned(InvisibleBody) then
    Result := InvisibleBody.Size.Width
  else
    Result := DefaultSize.Width;
end;

procedure TBButton.OnMouseDblClick(const Value: BMouseData);
begin
  FMouseDataDblClick := Value;
  OnMouseDown(Value);
  TTaskExecutor.AwaitExecuteTask(AwaitDblClick, @FMouseDataDblClick);
end;

procedure TBButton.OnMouseDown(const Value: BMouseData);
begin
  FHolderGUI.Position2d := FHolderGUI.Position2d + vec2(1.0, 1.0);
  FCaption.Position2d := FCaption.Position2d + 1.0;
  {$ifdef DEBUG_BS }
  BSWriteMsg('TBButton.OnMouseDown', Caption);
  {$endif}
end;

procedure TBButton.OnMouseUp(const Value: BMouseData);
begin
  FHolderGUI.Position2d := FHolderGUI.Position2d - vec2(1.0, 1.0);
  FCaption.ToParentCenter;
  FOnClickEvent.SendEvent(Value);
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBButton.OnMouseUp', Caption);
  {$endif}
end;

{$ifndef ANDROID}
procedure TBButton.OnMouseEnter(const Value: BMouseData);
begin
  if AniLawScale.IsRun then
  begin
    AniLawScale.Stop;
    InvisibleBody.Data.ScaleSimple := 1.0;
  end;
  AniLawScale.StartValue := 1.0;
  AniLawScale.StopValue := AniLawScale.StartValue + 0.07;
  if FOpacity < 1.0 then
  begin
    AniLawTransparent.StartValue := FOpacity;
    AniLawTransparent.StopValue := 1.0;
    AniLawTransparent.Run;
  end;
  AniLawScale.Run;
end;
{$endif}

procedure TBButton.OnMouseLeave(const Value: BMouseData);
begin
  {$ifndef ANDROID}
  if FOpacity < 1.0 then
  begin
    AniLawTransparent.StartValue := FBackground.Data.Opacity;
    AniLawTransparent.StopValue := FOpacity;
    AniLawTransparent.Run;
  end;
  AniLawScale.Stop;
  {$endif ANDROID}
  FHolderGUI.Data.Scale := vec3(1.0, 1.0, 1.0);
  FHolderGUI.Position2d := vec2(0.0, 0.0);
end;

procedure TBButton.SetBorderColor(const Value: TGuiColor);
begin
  FBorderColor := Value;
  if Assigned(FBorder) then
    FBorder.Color := ColorByteToFloat(Value, true);
end;

procedure TBButton.SetCaption(AValue: string);
begin
  FCaption.Text := AValue;
  FCaption.ToParentCenter;
end;

procedure TBButton.SetCaptionColor(const Value: TGuiColor);
begin
  FCaptionColor := Value;
  FCaption.Color := ColorByteToFloat(Value, true);
end;

procedure TBButton.SetColor(const Value: TGuiColor);
begin
  inherited SetColor(Value);
  FBackground.Color := ColorByteToFloat(Value, true);
end;

procedure TBButton.SetVisible(const Value: boolean);
begin
  inherited;
  InvisibleBody.Data.Interactive := Value;
  FBackground.Data.Hidden := not Value;
  if Assigned(FBorder) then
    FBorder.Data.Hidden := not Value;
  FCaption.Data.Hidden := not Value;
end;

procedure TBButton.SetOpacity(const Value: BSFloat);
begin
  FOpacity := clamp(1.0, 0.0, Value);
  FBackground.Data.Opacity := FOpacity;
end;

procedure TBButton.SetPosition2d(const Value: TVec2f);
begin
  InvisibleBody.Position2d := Value;
end;

procedure TBButton.SetRoundRadius(const Value: BSFloat);
begin
  FRoundRadius := Value;
  if Assigned(FBorder) then
    FBorder.RadiusRound := FRoundRadius;
  BuildView;
end;

procedure TBButton.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

procedure TBButton.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder = Value then
    exit;
  FShowBorder := Value;
  if FShowBorder then
  begin
    CreateBorder;
    FBorder.Build;
  end else
    FreeAndNil(FBorder);
end;

procedure TBButton.SetSize(const Value: TVec2f);
begin
  Resize(Value.x, Value.y);
end;

procedure TBButton.SetWidthBorder(const Value: BSFloat);
begin
  if FWidthBorder = Value then
    exit;

  FWidthBorder := Value;
  if Assigned(FBorder) then
  begin
    FBorder.WidthLine := round(FWidthBorder*ToHiDpiScale);
    FBorder.Build;
  end;
end;

constructor TBButton.Create(ACanvas: TBCanvas);
begin
  inherited Create(ACanvas);
  if OwnCanvas then
    FCanvas.Font.Size := 8;
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBButton.Create', 'FCanvas.Font.SizeInPixels: ' + IntToStr(FCanvas.Font.SizeInPixels));
  {$endif}
  FShowBorder := true;
  FOpacity := 0.5;
  FBorderColor := $FF00FF00;
  { create a root object }
  InvisibleBody := TRectangle.Create(FCanvas, nil);
  InvisibleBody.Fill := true;
  //InvisibleBody.TakeIntoAccountScaleInPosition2D := true;
  InvisibleBody.Size := DefaultSize;
  FMainBody := InvisibleBody;

  FHolderGUI := FCanvas.CreateEmptyCanvasObject(InvisibleBody);

  FBackground := TRoundRect.Create(FCanvas, FHolderGUI);
  FBackground.Fill := true;
  FBackground.Data.Interactive := false;
  FBackground.Size := InvisibleBody.Size;
  //FMainBody := FBackground;

  FOnClickEvent := CreateMouseEvent;

  InvisibleBody.Data.DrawAsTransparent := false;
  InvisibleBody.Data.Interactive := true;
  InvisibleBody.Data.DragResolve := false;
  InvisibleBody.Data.SelectResolve := false;
  InvisibleBody.Data.Opacity := 0.0;

  ObsrvMD := CreateMouseObserver(InvisibleBody.Data.EventMouseDown, OnMouseDown);
  ObsrvMU := CreateMouseObserver(InvisibleBody.Data.EventMouseUp, OnMouseUp);
  ObsrvMDbl := CreateMouseObserver(InvisibleBody.Data.EventMouseDblClick, OnMouseDblClick);
  {$ifndef ANDROID}
  ObsrvME := CreateMouseObserver(InvisibleBody.Data.EventMouseEnter, OnMouseEnter);
  {$endif}
  ObsrvML := CreateMouseObserver(InvisibleBody.Data.EventMouseLeave, OnMouseLeave);

  FRoundRadius := 8;
  FWidthBorder := 1.0;
  if FShowBorder then
    CreateBorder;

  FCaption := TCanvasText.Create(FCanvas, InvisibleBody);
  FCaption.Data.Interactive := false;
  FCaption.Layer2d := 3;
  //FCaption.Align := TObjectAlign.oaCenter;
  FCaption.Text := 'Button';
  FCaption.Anchors[aLeft] := false;
  FCaption.Anchors[aTop] := false;

  {$ifndef ANDROID}
  AniLawScale := CreateAniFloatLinear(GUIThread);
  ObsrvScale := CreateAniFloatLivearObsrv(AniLawScale, OnChangeValueScale, GUIThread);
  AniLawScale.Duration := 150;

  AniLawTransparent := CreateAniFloatLinear(GUIThread);
  ObsrvTransparent := CreateAniFloatLivearObsrv(AniLawTransparent, OnChangeValueTransparent, GUIThread);
  AniLawTransparent.Duration := 200;
  {$endif}

  FMainBody.Data.SetDragResolveRecursive(false);

  FBackGround.Data.Opacity := FOpacity;

  FCaption.Data.Color := BS_CL_WHITE;
  FBackGround.Color := BS_CL_ORANGE_2;
end;

procedure TBButton.CreateBorder;
begin
  FBorder := TRoundRect.Create(FCanvas, FBackGround);
  FBorder.Fill := false;
  FBorder.Data.Interactive := false;
  FBorder.Layer2d := 5;
  FBorder.WidthLine := round(FWidthBorder*ToHiDpiScale);
  FBorder.Size := FBackground.Size;
  FBorder.RadiusRound := FRoundRadius;
  FBorder.Color := ColorByteToFloat(FBorderColor, true);
end;

function TBButton.DefaultSize: TVec2f;
begin
  Result.x := round(DEFAULT_WIDTH*ToHiDpiScale);
  Result.y := round(DEFAULT_HEIGHT*ToHiDpiScale);
end;

destructor TBButton.Destroy;
begin
  ObsrvMD := nil;
  ObsrvMU := nil;
  ObsrvML := nil;
  {$ifndef ANDROID}
  ObsrvME := nil;
  ObsrvScale := nil;
  ObsrvTransparent := nil;
  AniLawScale := nil;
  AniLawTransparent := nil;
  {$endif}
  inherited;
end;

procedure TBButton.DoAfterScale;
begin
  inherited DoAfterScale;
  FCaption.ToParentCenter;
end;

procedure TBButton.AwaitDblClick(AData: Pointer);
begin
  OnMouseUp(PMouseData(AData)^);
end;

procedure TBButton.BuildView;
begin

  InvisibleBody.Build;

  FBackGround.RadiusRound := FRoundRadius;
  FHolderGUI.Position2d := vec2(0.0, 0.0);

  FBackGround.Build;
  FBackGround.Position2d := vec2(0.0, 0.0);
  if Assigned(FBorder) then
  begin
    FBorder.WidthLine := round(FWidthBorder*ToHiDpiScale);
    FBorder.Build;
    FBorder.Position2d := vec2(0.0, 0.0);
  end;

  FCaption.ToParentCenter;
end;

initialization

  TBControl.ControlRegister('GUI', TBButton);

finalization

end.

