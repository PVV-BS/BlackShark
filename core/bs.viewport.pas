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


unit bs.viewport;

{$I BlackSharkCfg.inc}

interface

uses
  {$ifdef MSWindows}
    Windows,
  {$endif}

  {$ifdef X}
    bs.linux,
  {$endif}

  Classes, SysUtils,
  {$ifndef FPC}
    Types,  {$ifdef MSWindows}Messages,{$endif}
  {$endif}

  {$ifdef FMX}
    FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, System.UITypes,
  {$else}
    {$ifdef FPC}
      LCLType,
      ExtCtrls, Controls, Graphics, Forms,
    {$else}
      System.UITypes,
      VCL.ExtCtrls, VCL.Controls, VCL.Graphics, VCL.Forms,
    {$endif}
  {$endif}
    bs.collections
  , bs.gl.context
  , bs.gl.egl
  , bs.events
  , bs.scene
  , bs.renderer
  , bs.thread
  ;

type

  TAfterCreateContextEvent = procedure (Sender: TObject) of object;

  { TBlackSharkViewPort }

  TBlackSharkViewPort = class({$ifdef FMX}TControl{$else}TCustomControl{$endif})
  {$ifdef FMXX}
  private
    class var
      FWindows: THashTable<TWindow, TBlackSharkViewPort>;
    class var
      FDisplay: PDisplay;
    class var
      FScreen: int32;
    class var
      FRootWindow: TWindow;

  {$endif}
  private
  {$ifdef FMXX}
    FWindow: TWindow;
  {$endif}
    FRenderer: TBlackSharkRenderer;
    FOnMouseMove: TMouseMoveEvent;
    FOnPaint: TNotifyEvent;
    Timer: TTimer;
    FOnAfterCreateContext: TAfterCreateContextEvent;
    TimerUpdateAfterResize: TTimer;

    FOnMouseDown: TMouseEvent;
    MouseLastPos: TPoint;
    FOnDblClick: TNotifyEvent;
    FOnMouseUp: TMouseEvent;
    FContext: TBlackSharkContext;
    FLastDeviceContext: EGLNativeDisplayType;
    FCaption: string;
    ObserverCreateContext: IBEmptyEventObserver;
    {$ifndef FPC}
    { a model events in delphi's an apps different from fpc, therefore explicitly
      cast to common behavior by the variable }
    IsMouseDblClick: boolean;
    {$endif}
    FBlackSharkMSAA: boolean;
    procedure SetOnAfterCreateContext(AValue: TAfterCreateContextEvent);
    procedure SetCurrentScene(AValue: TBScene);
    procedure OnUpdateTimerAfterResize(Sender: TObject);
    function CheckSizeRendererWindow: boolean;
    procedure OnTimer(Sender: TObject);
    procedure CheckFPS; inline;
    procedure DoDblClick;
    function GetCurrentScene: TBScene;
    procedure DoOnCreateContext;
    //procedure FreeNativeDeviceContext;
    procedure TryCreateContext;
    procedure OnCreateContextE(const {%H-}Value: BEmpty);
    function GetNativeHandle: EGLNativeWindowType;
    function GetNativeDeviceContext: EGLNativeDisplayType;
    procedure DoDraw; inline;
    procedure SetBlackSharkMSAA(const Value: boolean);
  {$ifdef FMXX}
    class constructor Create;
    class destructor Destroy;
  {$endif}
  protected
    procedure Resize; override;
    {$ifdef FPC}
      procedure MouseEnter; override;
      procedure MouseLeave; override;
    {$else}
      {$ifdef FMX}
        procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
        procedure DoMouseEnter; override;
        procedure DoMouseLeave; override;
      {$else}
        procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
        procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
      {$endif}
    {$endif}

    {$ifndef FMX}
    function DoMouseWheel({%H-}Shift: TShiftState; WheelDelta: Integer; {%H-}MousePos: TPoint): Boolean; override;
    {$endif}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: {$ifdef FMX}single{$else}Integer{$endif}
      ); override;
    procedure MouseMove({%H-}Shift: TShiftState; X, Y: {$ifdef FMX}single{$else}Integer{$endif}); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: {$ifdef FMX}single{$else}Integer{$endif}); override;
    procedure DblClick; override;
    procedure Paint; override;
    {$ifdef FPC}
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    {$else}
      {$ifdef FMX}
      procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
      procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
      {$else}
      procedure KeyPress(var Key: char); override;
      { hook on keys events because KeyDown/Up work not for all keys in Delphi }
      procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
      procedure CNKeyUp(var Message: TWMKeyUp); message CN_KEYUP;
      {$endif}
    {$endif}
    procedure UpdateData; inline;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;

    procedure TestResize(AWidth, AHeight: integer);
    procedure TestMouseDown(X, Y: Integer; Button: TMouseButton; Shift: TShiftState);
    procedure TestMouseMove(X, Y: Integer; {%H-}Button: TMouseButton; Shift: TShiftState);
    procedure TestMouseUp(X, Y: Integer; Button: TMouseButton; Shift: TShiftState);
    procedure TestKeyDown(var Key: Word; var {%H-}KeyChar: WideChar; Shift: TShiftState);
    procedure TestKeyUp(var Key: Word; var {%H-}KeyChar: WideChar; Shift: TShiftState);
    procedure TestKeyPress(var Key: WideChar);

    procedure Draw;
    procedure RestoreContext;
    property CurrentScene: TBScene read GetCurrentScene write SetCurrentScene;
    property Renderer: TBlackSharkRenderer read FRenderer;
    property Caption: string read FCaption write FCaption;
    property Context: TBlackSharkContext read FContext;
    property BlackSharkMSAA: boolean read FBlackSharkMSAA write SetBlackSharkMSAA;
  published
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnAfterCreateContext: TAfterCreateContextEvent read FOnAfterCreateContext write SetOnAfterCreateContext;

    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;

    property OnKeyDown;
    property OnKeyUp;
    property OnClick;
  end;

  procedure Register;

const
  MOUSE_BUTTONS_CONVERTOR: array[TMouseButton] of TBSMouseButton =
  ( TBSMouseButton.mbBsLeft,
    TBSMouseButton.mbBsRight,
    TBSMouseButton.mbBsMiddle
    {$ifdef FPC},
    TBSMouseButton.mbBsExtra1,
    TBSMouseButton.mbBsExtra2
    {$endif}
    );

implementation

uses
  {$ifdef X}
    {$ifdef FPC}
      Gtk2, Gtk2Extra,
    {$endif}
    {$ifdef FMX}
      FMX.Platform.Linux,
    {$endif}
  {$else}
    {$ifdef FMX}
      {$ifdef MSWINDOWS}
        FMX.Platform.Win,
      {$endif}


    {$endif}
  {$endif}

  {$ifdef FMXX}
    bs.gl.es,
  {$endif}

    bs.obj
  , bs.exceptions
  , bs.config
  , bs.utils
  ;

procedure Register;
begin
  RegisterComponents('Black Shark viewport', [TBlackSharkViewPort]);
end;

{ TBlackSharkViewPort }

function TBlackSharkViewPort.GetNativeDeviceContext: EGLNativeDisplayType;
{$ifdef FPC}
  {$ifndef X}
var
  h: EGLNativeWindowType;
  {$endif}
{$endif}
begin
  if {%H-}NativeUInt(FLastDeviceContext) > 0 then
    exit(FLastDeviceContext);
{$ifdef FMX}
  {$ifdef MSWINDOWS}
    Result := GetDC(GetNativeHandle);
  {$else}
    Result := FDisplay; //XOpenDisplay(nil);
  {$endif}
{$else}
  {$ifdef FPC}
    {$ifdef X}
      Result := XOpenDisplay(nil);
    {$else}
      h := GetNativeHandle;
      Result := GetDeviceContext(h);
    {$endif}
  {$else}
    Result := GetDC(GetNativeHandle);
  {$endif}
{$endif}
  FLastDeviceContext := Result;
end;

function TBlackSharkViewPort.GetNativeHandle: EGLNativeWindowType;
{$ifdef X}
  {$ifdef FPC}
var
  Widget: PGtkWidget;
  {$endif}
{$endif}
begin
{$ifdef FMX}
  {$ifdef X}
    Result := 0;
    {$Message error 'For FMXLinux use pure Black Shark application instead it (see example in ".tests\delphi\BSApplication\")'}
  {$else}
    Result := WindowHandleToPlatform(Application.MainForm.Handle).Wnd;
  {$endif}
{$else}
  {$ifdef X}
    {$ifdef FPC}
      Widget := {%H-}PGtkWidget(Handle);
      if Widget^.window = nil then
        exit(0);
      Result := gdk_window_xwindow(Widget^.window);
    {$else}
      Result := Handle;
    {$endif}
  {$else}
    Result := Handle;
  {$endif}
{$endif}
end;

procedure TBlackSharkViewPort.AfterConstruction;
begin
  inherited AfterConstruction;
  {$ifdef FMX}
  CanFocus := true;
  {$endif}
end;

procedure TBlackSharkViewPort.SetBlackSharkMSAA(const Value: boolean);
begin
  if FBlackSharkMSAA = Value then
    exit;
  FBlackSharkMSAA := Value;
  while (FBlackSharkMSAA <> FRenderer.SmoothMSAA) do
  begin
    if not FContext.MakeCurrent then
      continue;
    FRenderer.SmoothMSAA := FBlackSharkMSAA;
  end;
end;

procedure TBlackSharkViewPort.SetCurrentScene(AValue: TBScene);
begin
  FRenderer.Scene := AValue;
end;

procedure TBlackSharkViewPort.Draw;
begin
  if Visible and not Timer.Enabled then
  begin
    DoDraw;
  end;
end;

//procedure TBlackSharkViewPort.FreeNativeDeviceContext;
//begin
//  if NativeInt(FLastDeviceContext) = 0 then
//    exit;
//  {$ifdef MSWIndows}
//    ReleaseDC(GetNativeHandle, FLastDeviceContext);
//  {$endif}
//end;

procedure TBlackSharkViewPort.TryCreateContext;
var
   h: EGLNativeWindowType;
   d: EGLNativeDisplayType;
begin
  h := GetNativeHandle;
  d := GetNativeDeviceContext;
  if (h = 0) or ({%H-}NativeUInt(d) = 0) then
    exit;
  FContext := TBlackSharkContext.Create(h, d);
  ObserverCreateContext := FContext.OnCreateContextEvent.CreateObserver(GUIThread, OnCreateContextE);
end;

function TBlackSharkViewPort.GetCurrentScene: TBScene;
begin
  Result := FRenderer.Scene;
end;

procedure TBlackSharkViewPort.OnUpdateTimerAfterResize(Sender: TObject);
begin
  TimerUpdateAfterResize.Enabled := false;
  Draw;
end;

procedure TBlackSharkViewPort.UpdateData;
begin
  DoDraw;
end;

procedure TBlackSharkViewPort.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: {$ifdef FMX}single{$else}Integer{$endif});
begin
  inherited;
  if Enabled and not {$ifdef FMX}IsFocused{$else}Focused{$endif} then
    SetFocus;

  if Assigned(FRenderer) then
  begin
    FRenderer.MouseDown(MOUSE_BUTTONS_CONVERTOR[Button], Round(X), Round(Y), Shift);
    Draw;
  end;

  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TBlackSharkViewPort.MouseMove(Shift: TShiftState; X, Y: {$ifdef FMX}single{$else}Integer{$endif});
begin
  //inherited;
  if Assigned(FRenderer) then
  begin
    {$ifdef FMX}
    MouseLastPos.X := Round(X);
    MouseLastPos.Y := Round(Y);
    FRenderer.MouseMove(MouseLastPos.X, MouseLastPos.Y, Shift);
    {$else}
    MouseLastPos.X := X;
    MouseLastPos.Y := Y;
    FRenderer.MouseMove(X, Y, Shift);
    {$endif}
    Draw;
  end;
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TBlackSharkViewPort.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: {$ifdef FMX}single{$else}Integer{$endif});
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    {$ifdef FMX}
      FRenderer.MouseUp(MOUSE_BUTTONS_CONVERTOR[Button], Round(X), Round(Y), Shift);
    {$else}
      FRenderer.MouseUp(MOUSE_BUTTONS_CONVERTOR[Button], X, Y, Shift);
    {$endif}
    Draw;
  end;
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
  {$ifndef FPC}
  if IsMouseDblClick then
  begin
    IsMouseDblClick := false;
    DoDblClick;
  end;
  {$endif}
end;

procedure TBlackSharkViewPort.DoOnCreateContext;
var
  renderer: TBlackSharkRenderer;
begin
  if Assigned(FRenderer) then
  begin
    renderer := TBlackSharkRenderer.Create;
    renderer.Scene := FRenderer.Scene;
    renderer.OwnScene := true;
    renderer.ExactSelectObjects := FRenderer.ExactSelectObjects;

    FRenderer.Free;
    FRenderer := renderer;
  end else
  begin
    FRenderer := TBlackSharkRenderer.Create;
    FRenderer.ExactSelectObjects := true;
  end;

  CheckSizeRendererWindow;
  if Assigned(FOnAfterCreateContext) then
    FOnAfterCreateContext(Self);

  CheckFPS;
end;

{$ifdef FPC}

procedure TBlackSharkViewPort.MouseEnter;
var
  p: TPoint;
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    p := Mouse.CursorPos;
    p := ScreenToClient(p);
    FRenderer.MouseEnter(p.X, p.Y);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.MouseLeave;
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseLeave;
    Draw;
  end;
end;

{$else}

{$ifdef FMX}

procedure TBlackSharkViewPort.DoMouseEnter;
var
  p: TPoint;
begin
  inherited;
  {$ifdef MSWINDOWS}
  GetCursorPos(p);
  LocalToScreen(p);
  {$else}
  p := MouseLastPos; 
  {$endif}
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseEnter(p.X, p.Y);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.DoMouseLeave;
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseLeave;
    Draw;
  end;
end;

procedure TBlackSharkViewPort.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseWheel(WheelDelta, MouseLastPos.X, MouseLastPos.Y, Shift);
    Draw;
  end;
end;

{$else}

procedure TBlackSharkViewPort.CMMouseEnter;
var
  p: TPoint;
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    p := Mouse.CursorPos;
    p := ScreenToClient(p);

    FRenderer.MouseEnter(p.X, p.Y);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.CMMouseLeave;
begin
  inherited;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseLeave;
    Draw;
  end;
end;

procedure TBlackSharkViewPort.CNKeyDown(var Message: TWMKeyDown);
begin
  if Assigned(FRenderer) then
  begin
    FRenderer.KeyDown(Message.CharCode, KeyboardStateToShiftState);
    {$ifdef FMX}
    { that is not good }
    KeyPress(KeyChar);
    {$endif}
    Draw;
  end;
end;

procedure TBlackSharkViewPort.CNKeyUp(var Message: TWMKeyUp);
begin
  if Assigned(FContext) then
  begin
    FRenderer.KeyUp(Message.CharCode, KeyboardStateToShiftState);
    Draw;
  end;
end;

{$endif}

{$endif}

procedure TBlackSharkViewPort.DoDblClick;
begin
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseDblClick(MouseLastPos.X, MouseLastPos.Y);
    Draw;
  end;
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TBlackSharkViewPort.DoDraw;
begin
  GUIThread.OnIdleApplication;

  if not Assigned(FContext) then
  begin
    TryCreateContext;
    if not Assigned(FContext) then
       exit;
  end;

  if not FContext.MakeCurrent then
    exit;

  if not Assigned(FRenderer) then
    exit;

  FRenderer.Render;
  FContext.Swap;
  if Assigned(FOnPaint) then
    FOnPaint(Self);

  CheckFPS;
end;

{$ifndef FMX}
function TBlackSharkViewPort.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := true;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseWheel(WheelDelta, MouseLastPos.X, MouseLastPos.Y, Shift);
    Draw;
  end;
end;
{$endif}

procedure TBlackSharkViewPort.Resize;
begin
  inherited;

  if (Width < 5) or (Height < 5) or not Assigned(FContext) or not FContext.ContextCreated or not FContext.MakeCurrent then
      exit;

  {$ifndef FMXX}
  FContext.Swap;
  {$endif}
  if CheckSizeRendererWindow then
    DoDraw;
end;

{$ifdef FPC}

procedure TBlackSharkViewPort.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Assigned(FRenderer) then
  begin
    FRenderer.KeyDown(Key, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if Assigned(FRenderer) then
  begin
    FRenderer.KeyUp(Key, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.UTF8KeyPress(var UTF8Key: TUTF8Char);
var
  w: WideString;
begin
  inherited UTF8KeyPress(UTF8Key);
  if Assigned(FRenderer) then
  begin
    w := UTF8Decode(UTF8Key);
    if (w <> '') then
      FRenderer.KeyPress(w[1], []);
    Draw;
  end;
end;
{$else}
  {$ifdef FMX}

  procedure TBlackSharkViewPort.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  begin
    inherited;
    if Assigned(FRenderer) then
    begin
      FRenderer.KeyDown(Key, Shift);
      FRenderer.KeyPress(KeyChar, Shift);
      Draw;
    end;
  end;

  procedure TBlackSharkViewPort.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  begin
    inherited;
    if Assigned(FRenderer) then
    begin
      FRenderer.KeyUp(Key, Shift);
      Draw;
    end;
  end;

  {$else}
  procedure TBlackSharkViewPort.KeyPress(var Key: char);
  begin
    inherited KeyPress(Key);
    if Assigned(FRenderer) then
    begin
      FRenderer.KeyPress(Key, []);
      Draw;
    end;
  end;
  {$endif}

{$endif}

procedure TBlackSharkViewPort.Paint;
begin
  Draw;
end;

procedure TBlackSharkViewPort.CheckFPS;
begin
  if (TBTimer.CurrentTime.Counter - TTimeProcessEvent.TimeProcessEvent.Counter > 3000) then
  begin
    if Timer.Enabled then
      Timer.Enabled := false;
  end else
  begin
    if not Timer.Enabled and bs.config.BSConfig.MaxFps then
      Timer.Enabled := true;
  end;
end;

function TBlackSharkViewPort.CheckSizeRendererWindow: boolean;
begin
  if Assigned(FRenderer) and ((FRenderer.WindowWidth <> Width) or (FRenderer.WindowHeight <> Height)) then
  begin
    FRenderer.ResizeViewPort(round(Width), round(Height));
    Result := true;
  end else
    Result := false;
end;

{$ifdef FMXX}
class constructor TBlackSharkViewPort.Create;
begin
  FDisplay := XOpenDisplay(nil);

  if not Assigned(FDisplay) then
    raise EBlackShark.Create('[class constructor TBlackSharkViewPort.Create] XOpenDisplay failed');
  // if we have a Display then we should have a Screen too
  FScreen:= XDefaultScreen(FDisplay);
  FRootWindow := XDefaultRootWindow(FDisplay);
  //FLeaderWindow := XCreateSimpleWindow(FDisplay, FRootWindow, 0, 0, 1, 1, 0, 0, 0);
end;
{$endif}

constructor TBlackSharkViewPort.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  {$ifdef FMX}
     if TheOwner.InheritsFrom(TControl) then
       Parent := TControl(TheOwner)
     else
       raise Exception.Create('TheOwner MUST be only TControl or him a descendant');
  {$else}
     if TheOwner.InheritsFrom(TWinControl) then
       Parent := TWinControl(TheOwner)
     else
       raise Exception.Create('TheOwner MUST be only TWinControl or him a descendant');
  {$endif}

  //DoubleBuffered := true;
  TimerUpdateAfterResize := TTimer.Create(Self);
  TimerUpdateAfterResize.Enabled := false;
  TimerUpdateAfterResize.Interval := 1;
  TimerUpdateAfterResize.OnTimer := OnUpdateTimerAfterResize;

  Timer := TTimer.Create(Self);
  Timer.Enabled := false;
  Timer.Interval := 1;
  Timer.OnTimer := OnTimer;
end;

procedure TBlackSharkViewPort.RestoreContext;
begin
  {$ifndef FMXX}
  if not Assigned(FContext) then
    exit;
  FContext.UnInitGLContext;
  FContext.CreateContext;
  if FContext.MakeCurrent then
  {$endif}
    if Assigned(FRenderer) then
      FRenderer.Restore;
end;

procedure TBlackSharkViewPort.DblClick;
begin
  inherited DblClick;
  {$ifdef FPC}
    DoDblClick;
  {$else}
    IsMouseDblClick := true;
  {$endif}
end;

{$ifdef FMXX}
class destructor TBlackSharkViewPort.Destroy;
begin
  XCloseDisplay(FDisplay);
end;
{$endif}

destructor TBlackSharkViewPort.Destroy;
begin
  ObserverCreateContext := nil;
  FRenderer.Free;
  FContext.Free;
  inherited Destroy;
end;

procedure TBlackSharkViewPort.OnCreateContextE(const Value: BEmpty);
begin
  DoOnCreateContext;
end;

procedure TBlackSharkViewPort.OnTimer(Sender: TObject);
begin
  UpdateData;
end;

procedure TBlackSharkViewPort.SetOnAfterCreateContext(AValue: TAfterCreateContextEvent);
begin
  if @FOnAfterCreateContext = @AValue then
      exit;
  FOnAfterCreateContext := AValue;
  if Assigned(FRenderer) and (Assigned(FOnAfterCreateContext)) {$ifndef FMXX} and (FContext.ContextCreated) {$endif} then
    FOnAfterCreateContext(Self);
end;

procedure TBlackSharkViewPort.TestKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.KeyDown(Key, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestKeyPress(var Key: WideChar);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.KeyPress(Key, []);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestKeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.KeyUp(Key, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestMouseDown(X, Y: Integer; Button: TMouseButton; Shift: TShiftState);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.MouseDown(MOUSE_BUTTONS_CONVERTOR[Button], X, Y, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestMouseMove(X, Y: Integer; Button: TMouseButton; Shift: TShiftState);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.MouseMove(X, Y, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestMouseUp(X, Y: Integer; Button: TMouseButton; Shift: TShiftState);
begin
  if FContext.MakeCurrent then
  begin
    FRenderer.MouseUp(MOUSE_BUTTONS_CONVERTOR[Button], X, Y, Shift);
    Draw;
  end;
end;

procedure TBlackSharkViewPort.TestResize(AWidth, AHeight: integer);
var
  old_w, old_h: int32;
begin
  if Assigned(Parent) and Parent.InheritsFrom(TControl) then
  begin
    old_w := round(Width);
    old_h := round(Height);
    if (TControl(Parent).Align = {$ifdef FMX}TAlignLayout.Client{$else}TAlign.alClient{$endif}) and Assigned(Parent.Parent) then
    begin
      TControl(Parent.Parent).Width := TControl(Parent.Parent).Width + AWidth - old_w;
      TControl(Parent.Parent).Height := TControl(Parent.Parent).Height + AHeight - old_h;
    end else
    begin
      TControl(Parent).Width := TControl(Parent).Width + AWidth - Width;
      TControl(Parent).Height := TControl(Parent).Height + AHeight - Height;
    end;

    if Width = old_w then
      Width := AWidth;
    if Height = old_h then
      Height := AHeight;
  end;
end;

initialization
  {$ifdef FMX}
  FMX.Types.GlobalUseGPUCanvas := True;
  {$endif}

  {$ifdef FMX}
  bs.utils.PixelsPerInch := TDeviceDisplayMetrics.Default.PixelsPerInch;
  {$else}
  bs.utils.PixelsPerInch := Screen.PixelsPerInch;
  {$endif}
  bs.utils.ToHiDpiScale := bs.utils.PixelsPerInch/96;


end.
