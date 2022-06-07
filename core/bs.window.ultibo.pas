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
unit bs.window.ultibo;

{$ifdef FPC}
  {$WARN 5024 off : Parameter "$1" not used}
  {$WARN 5026 off : Value parameter "$1" is assigned but never used}
{$endif}

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , Classes
  , RaspberryPi2 {Include RaspberryPi2 to make sure all standard functions are included}
  , GlobalConst
  , GlobalTypes
  , Platform
  , Threads
  , Console
  , Framebuffer
  //, BCM2837
  //, BCM2710
  , Mouse        {Mouse uses USB so that will be included automatically}
  , DWCOTG       {We need to include the USB host driver for the Raspberry Pi}
  , Keyboard     {Keyboard uses USB so that will be included automatically}
  , GPIO
  , DispmanX
  , VC4          {Include the VC4 unit to enable access to the GPU}
  , gles20

  , bs.collections
  , bs.basetypes
  , bs.window
  , bs.gui.base
  , bs.events
  ;

const
  SCREEN_ORIENTATION_LANDSCAPE: int32 = 0;
  SCREEN_ORIENTATION_PORTRAIT: int32 = 1;

type

  { TInputListener }

  TInputListener = class(TThread)
  protected
    procedure Listen; virtual; abstract;
    procedure Execute; override;
  public
    constructor Create;
    function GetEvetns: boolean; virtual; abstract;
  end;

  { TInputListener<T> }

  TInputListener<T> = class(TInputListener)
  public
    type
      TEventHandler = procedure(const AEvene: T) of object;
  private
    FQueue: TQueueFIFO<T>;
    FEventHandler: TEventHandler;
  protected
    procedure Send(const AInput: T);
  public
    constructor Create;
    destructor Destroy; override;
    function GetEvetns: boolean; override;
    property Queue: TQueueFIFO<T> read FQueue;
    property EventHandler: TEventHandler read FEventHandler write FEventHandler;
  end;

  { TMouseInputListener }

  TMouseInputListener = class(TInputListener<TMouseData>)
  protected
    procedure Listen; override;
  end;

  { TKeyboardInputListener }

  TKeyboardInputListener = class(TInputListener<TKeyboardData>)
  protected
    procedure Listen; override;
  end;

  { TGPIOInputListener: TODO }

  TGPIOInputListener = class(TInputListener<TGPIOEvent>)
  protected
    procedure Listen; override;
  end;

  { TWindowContextUltibo }

  TWindowContextUltibo = class(TWindowContext)
  protected
    function GetDC: EGLNativeDisplayType; override;
    function GetHandle: EGLNativeWindowType; override;
  end;

  { BSApplicationUltibo }

  BSApplicationUltibo = class(BSApplicationSystem)
  private
    MouseButtonsBefore: int32;
    {DispmanX window}
    FDispmanDisplay: DISPMANX_DISPLAY_HANDLE_T;
    FDispmanElement: DISPMANX_ELEMENT_HANDLE_T;

    FAlpha: VC_DISPMANX_ALPHA_T;
    FNativeWindow: EGL_DISPMANX_WINDOW_T;
    ConsoleWindowHandle: TWindowHandle;
    FListeners: TListVec<TInputListener>;
    FEvent: TEventHandle;

    procedure UpdateClientRect(AWindow: BSWindow);
    function GetNativeWindow: PEGL_DISPMANX_WINDOW_T;
    procedure InitApplication;
    function ProcessKeyBoardEvent: boolean;
    function ProcessMouseEvent: boolean;
    function ProcessEvents: boolean;
  protected
    procedure InitHandlers; override;
    procedure InitMonitors; override;
    procedure DoShow(AWindow: BSWindow; AInModalMode: boolean); override;
    procedure DoClose(AWindow: BSWindow); override;
    procedure DoInvalidate(AWindow: BSWindow); override;
    procedure DoResize(AWindow: BSWindow; AWidth, AHeight: int32); override;
    procedure DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32); override;
    procedure DoFullScreen(AWindow: BSWindow); override;
    procedure DoActive(AWindow: BSWindow); override;
    procedure DoShowCursor(AWindow: BSWindow); override;
    function GetMousePointPos: TVec2i; override;
    procedure ChangeDisplayResolution(NewWidth, NewHeight: int32);
    procedure DoMouseInput(const AInput: TMouseData);
    procedure DoKeyboardInput(const AInput: TKeyboardData);
  public
    constructor Create;
    destructor Destroy; override;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; override;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; override;
    procedure Update; override;
    procedure UpdateWait; override;
    { you can add an own listener }
    procedure AddListener(AInputListener: TInputListener);
    function BeginListenKeyboard: TKeyboardInputListener;
    function BeginListenMouse: TMouseInputListener;
    procedure WriteEventToQueueNotify;

    property NativeWindow: PEGL_DISPMANX_WINDOW_T read GetNativeWindow;
  end;

var
  ApplicationUltibo: BSApplicationUltibo;


implementation

uses
    types
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  , GlobalConfig
  , bs.utils
  , bs.thread
  , bs.config
  , bs.gl.context
  , bs.events.keyboard
  , bs.math
  ;

constructor TInputListener.Create;
begin
  inherited Create(false);
end;

procedure TInputListener.Execute;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TInputListener.Execute', 'begin: ' + ClassName);
  {$endif}
  repeat
    Listen;
  until Terminated;
  {$ifdef DEBUG_BS}
  BSWriteMsg('TInputListener.Listen', 'end: ' + ClassName);
  {$endif}
end;

{  TInputListener<T> }

constructor TInputListener<T>.Create;
begin
  inherited;
  FQueue := TQueueFIFO<T>.Create;
end;

destructor TInputListener<T>.Destroy;
begin
  FQueue.Free;
end;

procedure TInputListener<T>.Send(const AInput: T);
begin
  FQueue.Push(AInput);
  ApplicationUltibo.WriteEventToQueueNotify;
end;

function TInputListener<T>.GetEvetns: boolean;
var
  e: T;
  count: int32;
begin
  count := 0;
  while FQueue.Pop(e) do
  begin
    inc(count);
    EventHandler(e);
  end;
  Result := count > 0;
end;

{ TKeyboardInputListener }

procedure TKeyboardInputListener.Listen;
var
  keyboardData: TKeyBoardData;
  count: LongWord;
begin
  count := 0;
  while KeyboardRead(@keyboardData, SizeOf(TKeyBoardData), count) = ERROR_SUCCESS do
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TKeyboardInputListener.Listen');
    {$endif}
    Send(keyboardData);
  end;
end;

{ TMouseInputListener }

procedure TMouseInputListener.Listen;
var
  mouseData: TMouseData;
  count: LongWord;
begin
  count := 0;
  while MouseRead(@mouseData, SizeOf(TMouseData), count) = ERROR_SUCCESS do
  begin
    Send(mouseData);
  end;
end;

{ TGPIOInputListener }

procedure TGPIOInputListener.Listen;
begin
  // TODO
end;

{ BSApplicationUltibo }

procedure BSApplicationUltibo.ChangeDisplayResolution(NewWidth, NewHeight: int32);
begin

end;

procedure BSApplicationUltibo.DoMouseInput(const AInput: TMouseData);
begin
  FMousePos.x := bs.math.clamp(DisplayWidth - 1, 0, FMousePos.x + AInput.OffsetX);
  FMousePos.y := bs.math.clamp(DisplayHeight - 1,  0, FMousePos.y + AInput.OffsetY);

  if (MouseButtonsBefore <> AInput.Buttons) then
  begin
    if MouseButtonsBefore < AInput.Buttons then
      Self.OnTouch(ACTION_DOWN, AInput.Buttons, FMousePos.x, FMousePos.y, 0)
    else
      Self.OnTouch(ACTION_UP, AInput.Buttons, FMousePos.x, FMousePos.y, 0);
  end else
  // TODO: How to get mouse wheel delta???
  //if (AInput.OffsetWheel <> 0) and ((AInput.Buttons and MOUSE_MIDDLE_BUTTON) > 0) then
  //begin
  //  Self.OnTouch(ACTION_WHEEL, AInput.Buttons, FMousePos.x, FMousePos.y, AInput.OffsetWheel);
  //end else
  begin
    Self.OnTouch(ACTION_MOVE, AInput.Buttons, FMousePos.x, FMousePos.y, 0);
  end;
  MouseButtonsBefore := AInput.Buttons;
  { it doesn't need to handle required actions, reset them }
  StackNeedActions.Count := 0;
end;

procedure BSApplicationUltibo.DoKeyboardInput(const AInput: TKeyboardData);
var
  key: Word;
  character: WideChar;
  ss: TShiftState;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationUltibo.DoKeyboardInput.AInput.KeyCode', IntToStr(AInput.KeyCode));
  {$endif}

  {Check for Key Up and Dead Key events}
  if ((AInput.Modifiers and KEYBOARD_DEADKEY) = 0) then
  begin
    ss := [];
    key := AInput.KeyCode;
    if (AInput.Modifiers and KEYBOARD_KEYUP = 0) then
      ActiveWindow.KeyDown(key, ss)
    else
      ActiveWindow.KeyUp(key, ss);

    {Exclude Key Up and Dead Key events}
    if (AInput.CharUnicode <> #0) and ((AInput.Modifiers and KEYBOARD_KEYUP) = 0) then
    begin
      {Get Char Unicode}
      character := AInput.CharUnicode;

      {Check Ctrl Keys}
      if (AInput.Modifiers and (KEYBOARD_LEFT_CTRL or KEYBOARD_RIGHT_CTRL)) <> 0 then
      begin
        {Remap Ctrl Code}
        character:= WideChar(KeyboardRemapCtrlCode(AInput.KeyCode, Word(character)));
      end;

      {$ifdef DEBUG_BS}
      BSWriteMsg('BSApplicationUltibo.DoKeyboardInput', string(character));
      {$endif}
      ActiveWindow.KeyPress(character, ss);
    end;
  end;
end;

constructor BSApplicationUltibo.Create;
begin
  inherited;
  ApplicationUltibo := Self;
  FListeners := TListVec<TInputListener>.Create;
  InitApplication;
end;

function BSApplicationUltibo.CreateWindow(AWindow: BSWindow): BSWindow;
begin
  Result := AWindow;
end;

function BSApplicationUltibo.CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
begin
  if Application.MainWindow = nil then
    Result := AWindowClass.Create(TWindowContextUltibo.Create, AOwner, AParent, APositionX, APositionY, DisplayWidth, DisplayHeight)
  else
    Result := AWindowClass.Create(TWindowContextUltibo.Create, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);
  Result.ClientRect := Rect(0, 0, Result.Width, Result.Height);
  AddWindow(Result);
end;

destructor BSApplicationUltibo.Destroy;
var
  i: int32;
begin
  inherited;
  for i := 0 to FListeners.Count - 1 do
  begin
    FListeners.Items[i].Terminate;
    FListeners.Items[i].WaitFor;
    FListeners.Items[i].Free;
  end;

  FListeners.Free;

  if FDispmanDisplay <> DISPMANX_NO_HANDLE then
    vc_dispmanx_display_close(FDispmanDisplay);
  {Deinitialize the VC4}
  BCMHostDeinit;
  EventDestroy(FEvent);
  //ConsoleWindowWriteLn(ConsoleWindowHandle, 'Completed BSApplication');
  {Halt the main thread here}
  ThreadHalt(0);
end;

procedure BSApplicationUltibo.DoActive(AWindow: BSWindow);
begin
  inherited;
  ApplicationRun;
end;

procedure BSApplicationUltibo.DoShowCursor(AWindow: BSWindow);
begin
  inherited DoShowCursor(AWindow);

  if AWindow.ShowCursor then
  begin
    //SysConsoleShowMouse(DisplayWidth div 2, DisplayHeight div 2, nil);
    //CursorSetState(true, FMousePos.x, FMousePos.y, False);
  end else
  begin
    //CursorSetState(false, FMousePos.x, FMousePos.y, False);
    //SysConsoleHideMouse(nil);
  end;

end;

procedure BSApplicationUltibo.DoClose(AWindow: BSWindow);
begin
  inherited;

end;

procedure BSApplicationUltibo.DoFullScreen(AWindow: BSWindow);
begin
  inherited{%H-};
end;

procedure BSApplicationUltibo.DoInvalidate(AWindow: BSWindow);
begin
  inherited{%H-};

end;

procedure BSApplicationUltibo.DoResize(AWindow: BSWindow; AWidth, AHeight: int32);
begin
  inherited{%H-};
  UpdateClientRect(AWindow);
end;

procedure BSApplicationUltibo.DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32);
begin
  inherited{%H-};
  UpdateClientRect(AWindow);
end;

procedure BSApplicationUltibo.DoShow(AWindow: BSWindow; AInModalMode: boolean);
begin
  inherited;

end;

function BSApplicationUltibo.GetMousePointPos: TVec2i;
begin
  Result := vec2(0, 0);
end;

procedure BSApplicationUltibo.UpdateClientRect(AWindow: BSWindow);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationUltibo.UpdateClientRect', 'begin');
  {$endif}
  if Application.MainWindow <> AWindow then
  begin
    if AWindow.FullScreen then
    begin
      AWindow.ClientRect := Rect(0, 0, Application.ApplicationSystem.DisplayWidth, Application.ApplicationSystem.DisplayHeight);
    end else
    begin
      AWindow.ClientRect := Rect(AWindow.Left, AWindow.Top, AWindow.Left + AWindow.Width, AWindow.Top + AWindow.Height);
    end;
  end else
    AWindow.ClientRect := Rect(0, 0, AWindow.Width, AWindow.Height);
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationUltibo.UpdateClientRect end: ', 'Left: ' + IntToStr(AWindow.ClientRect.Left) + '; Top: ' + IntToStr(AWindow.ClientRect.Top) +
    '; Width: ' + IntToStr(AWindow.ClientRect.Width) + '; Height: ' + IntToStr(AWindow.ClientRect.Height));
  {$endif}
end;

function BSApplicationUltibo.GetNativeWindow: PEGL_DISPMANX_WINDOW_T;
begin
  Result := @FNativeWindow;
end;

procedure BSApplicationUltibo.InitApplication;
var
  screenWidth: uint32;
  screenHeight: uint32;
  destRect: VC_RECT_T;
  sourceRect: VC_RECT_T;
  dispmanUpdate: DISPMANX_UPDATE_HANDLE_T;
  framebufferDevice: PFramebufferDevice;
begin
  {$ifdef DEBUG_BS}
  {Create a console window as usual}
  ConsoleWindowHandle := ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULL,True);
  {Wait a couple of seconds for C:\ drive to be ready}
  ConsoleWindowWriteLn(ConsoleWindowHandle,'Waiting for drive C:\');
  {$endif}

  while not DirectoryExists('C:\') do
  begin
    {Sleep for a moment}
    Sleep(100);
  end;

  SetApplicationPath('C:\');

  { All applications using the VideoCore IV must call BCMHostInit before doing any other
    operations. This will initialize all of the supporting libraries and start the VCHIQ
    communication service. Applications should also call BCMHostDeinit when they no longer
    require any VC4 services}

  BCMHostInit;

  screenWidth := 0;
  screenHeight := 0;

  framebufferDevice := {%H-}FramebufferDeviceGetDefault;
  //FramebufferDeviceSetCursor(FramebufferDevice, 0, 0, 0, 0, nil ,0);
  //FramebufferDeviceUpdateCursor(framebufferDevice, True, CursorX, CursorY, False);
  if Assigned(framebufferDevice) then
  begin
    FramebufferDeviceRelease(framebufferDevice);
    {$ifdef DEBUG_BS}
    BSWriteMsg('BSApplicationUltibo.InitApplication', 'FramebufferDeviceRelease');
    {$endif}
  end;

  {Create an EGL window surface}
  if BCMHostGraphicsGetDisplaySize(DISPMANX_ID_MAIN_LCD, screenWidth, screenHeight) < 0 then
    exit;

  DisplayWidth := screenWidth;
  DisplayHeight := screenHeight;

  // ???
  PixelsPerInchX := 96;
  PixelsPerInchY := 96;

  FAlpha.flags := DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS;
  //FAlpha.flags := DISPMANX_FLAGS_ALPHA_FROM_SOURCE;
  FAlpha.opacity := 255;
  FAlpha.mask := 0;

  {Setup the DispmanX source and destination rectangles}
  vc_dispmanx_rect_set(@destRect, 0, 0, screenWidth, screenHeight);
  vc_dispmanx_rect_set(@sourceRect, 0, 0, screenWidth, screenHeight);

  {Open the DispmanX display}
  FDispmanDisplay := vc_dispmanx_display_open(DISPMANX_ID_MAIN_LCD);
  if FDispmanDisplay = DISPMANX_NO_HANDLE then
    Exit;

  {Start a DispmanX update}
  dispmanUpdate := vc_dispmanx_update_start(0);
  if dispmanUpdate = DISPMANX_NO_HANDLE then
    Exit;

  {Add a DispmanX element for our display}
  FDispmanElement := vc_dispmanx_element_add(dispmanUpdate, FDispmanDisplay,0 {Layer},@destRect,0 {Source}, @sourceRect, DISPMANX_PROTECTION_NONE, @FAlpha, nil {Clamp}, DISPMANX_NO_ROTATE {Transform});
  if FDispmanElement = DISPMANX_NO_HANDLE then
    Exit;

  {Define an EGL DispmanX native window structure}
  FNativeWindow.Element:= FDispmanElement;
  FNativeWindow.Width:= screenWidth;
  FNativeWindow.Height:= screenHeight;

  {Submit the DispmanX update}
  vc_dispmanx_update_submit_sync(dispmanUpdate);

  FMousePos.x := screenWidth div 2;
  FMousePos.y := screenHeight div 2;

  FEvent := EventCreate(true, false);

  BeginListenKeyboard;
  BeginListenMouse;
end;

function BSApplicationUltibo.ProcessKeyBoardEvent: boolean;
var
  count: LongWord;
  data: TKeyboardData;
begin
  if KeyboardPeek <> ERROR_SUCCESS then
    exit(false);
  count := 0;
  if (KeyboardReadEx(@data, SizeOf(TKeyboardData), KEYBOARD_FLAG_NONE, count) = ERROR_SUCCESS) and (data.Modifiers and KEYBOARD_DEADKEY = 0) then
  begin
    Result := true;
    DoKeyboardInput(data);
  end else
    Result := false;
end;

function BSApplicationUltibo.ProcessMouseEvent: boolean;
var
  mouseData: TMouseData;
  count: LongWord;
begin

  Result := false;
  count := 0;
  while MouseReadEx(@mouseData, SizeOf(TMouseData), MOUSE_FLAG_NON_BLOCK, count) = ERROR_SUCCESS do
  begin
    Result := true;

    DoMouseInput(mouseData);

  end;
end;

function BSApplicationUltibo.ProcessEvents: boolean;
var
  i: int32;
begin
  Result := false;
  for i := 0 to FListeners.Count - 1 do
  begin
    if FListeners.Items[i].GetEvetns then
      Result := true;
  end;

  // an old approach
  //Result := ProcessKeyBoardEvent;
  //if ProcessMouseEvent then
  //  Result := true;
end;

procedure BSApplicationUltibo.WriteEventToQueueNotify;
begin
  EventSet(FEvent);
end;

procedure BSApplicationUltibo.InitHandlers;
begin
  inherited{%H-};

end;

procedure BSApplicationUltibo.InitMonitors;
begin
  inherited{%H-};

end;

procedure BSApplicationUltibo.Update;
begin
  inherited{%H-};
  ProcessEvents;
  ActiveWindow.Draw;
end;

procedure BSApplicationUltibo.UpdateWait;
begin
  inherited{%H-};
  EventReset(FEvent);
  EventWait(FEvent);
  ProcessEvents;
  ActiveWindow.Draw;
end;

procedure BSApplicationUltibo.AddListener(AInputListener: TInputListener);
begin
  FListeners.Add(AInputListener);
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationUltibo.AddListener', AInputListener.ClassName + '; Handle: ' + IntToHex(AInputListener.ThreadID, SizeOf(NativeInt)*2));
  {$endif}
end;

function BSApplicationUltibo.BeginListenKeyboard: TKeyboardInputListener;
begin
  Result := TKeyboardInputListener.Create;
  Result.EventHandler := DoKeyBoardInput;
  AddListener(Result);
end;

function BSApplicationUltibo.BeginListenMouse: TMouseInputListener;
begin
  Result := TMouseInputListener.Create;
  Result.EventHandler := DoMouseInput;
  AddListener(Result);
end;

{ TWindowContextUltibo }

function TWindowContextUltibo.GetDC: EGLNativeDisplayType;
begin
  Result := TSharedEglContext.SharedDisplay;
end;

function TWindowContextUltibo.GetHandle: EGLNativeWindowType;
begin
  Result := ApplicationUltibo.NativeWindow;
end;

initialization
  {.$ifndef DEBUG_BS}
  FRAMEBUFFER_CONSOLE_AUTOCREATE := false;
  {.$endif}


end.
