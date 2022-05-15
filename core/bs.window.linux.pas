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
unit bs.window.linux;

{$I BlackSharkCfg.inc}

interface

uses
    bs.collections
  , bs.basetypes
  , bs.events
  , bs.gl.egl
  , bs.linux
  , bs.window
  {$ifndef FPC}  // for inlining in Delphi
  , bs.config
  , bs.gl.context
  , bs.renderer
  {$endif}
  ;

type

  TEventHandler = procedure(AWindow: BSWindow; const AEvent: TXEvent) of object;

  TListHandlers = TListVec<TEventHandler>;

  { TWindowContextLinux }

  TWindowContextLinux = class(TWindowContext)
  private
  protected
    function UpdateWmProperties: TXSizeHints;
    function GetDC: EGLNativeDisplayType; override;
    procedure SetDC(const AValue: EGLNativeDisplayType); override;
    procedure SetHandle(const AValue: EGLNativeWindowType); override;
  public
    ExposeEvent: TXEvent;
    constructor Create;
    destructor Destroy; override;
    function GetSizeHints: TXSizeHints;
  end;

  { BSApplicationLinux }

  BSApplicationLinux = class(BSApplicationSystem)
  private
    FHandlers: TListHandlers;
    LastTimeMouseUp: uint32;
    CurrentShiftState: TBSShiftState;
    FTimeMouseDown: uint64;
    FDisplayName: AnsiString;
    FDisplay: PDisplay;
    FDisplayHeightMM: int32;
    FDisplayWidthMM: int32;
    FColorDepth: int32;

    FScreen: int32;
    // Visual from X11
    FVisual: PVisual;
    FRootWindow: TWindow;

    LeaderWindow: TWindow;
    ClientLeaderAtom: TAtom;

    //FWMProtocols: TAtom;	  // Atom for "WM_PROTOCOLS"
    FWMDeleteWindow: TAtom;	// Atom for "WM_DELETE_WINDOW"
    FWMHints: TAtom;		    // Atom for "_MOTIF_WM_HINTS"
    FWMTransientFor: TAtom;		    // Atom for "WM_TRANSIENT_FOR"
    //FWMPaint: TAtom;		  // Atom for "WM_PAINT"
    FWMModalState: TAtom;		    // Atom for "_NET_WM_STATE_MODAL"
    FWMState: TAtom;		    // Atom for "_NET_WM_STATE"
    FWMStateAbove: TAtom;		    // Atom for "_NET_WM_STATE_ABOVE"
    FWMStateFullScreen: TAtom;		    // Atom for "_NET_WM_STATE_FULLSCREEN"
    FWMActiveState: TAtom;		    // Atom for "NET_ACTIVE_WINDOW"
    // For composing character events
    ComposeBuffer: UTF8String;
    ComposeStatus: TStatus;
    InputMethod: PXIM;
    InputContext: PXIC;

    // XConnections list
    FConnections: TListVec<cint>;

    procedure ProcessEvent(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerKeyPress(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerKeyUp(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerPaint(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerClientMessage(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerMouseEnter(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerMouseMove(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerMouseLeave(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerMouseDown(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerMouseUp(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerConfigureNotify(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerResizeRequest(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerUnmapNotify(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerDestroyNotify(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerFocusIn(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerFocusOut(AWindow: BSWindow; const AEvent: TXEvent);
    procedure HandlerUnknownEvent(AWindow: BSWindow; const AEvent: TXEvent);

    procedure CreateHandle(AWindow: BSWindow);
    procedure UpdateClientRect(AWindow: BSWindow);
    function StartComposing(const Event: TXKeyEvent): TKeySym;
  protected
    procedure InitMonitors; override;
    procedure InitHandlers; override;
    function GetMousePointPos: TVec2i; override;
    //procedure SetShowCursor(const Value: boolean); override;
    procedure DoShow(AWindow: BSWindow; AInModalMode: boolean); override;
    procedure DoClose(AWindow: BSWindow); override;
    procedure DoInvalidate(AWindow: BSWindow); override;
    procedure DoResize(AWindow: BSWindow; AWidth, AHeight: int32); override;
    procedure DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32); override;
    procedure DoFullScreen(AWindow: BSWindow); override;
    procedure DoActive(AWindow: BSWindow); override;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; override;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; override;
    procedure AddConnection(AConnection: cint);
    procedure RemoveConnection(AConnection: cint);
    procedure Update; override;
    procedure UpdateWait; override;
    property Display: PDisplay read FDisplay;
    property RootWindow: TWindow read FRootWindow;
    property Visual: PVisual read FVisual;
    property DisplayName: AnsiString read FDisplayName write FDisplayName;
    property DisplayWidthMM: int32 read FDisplayWidthMM;
    property DisplayHeightMM: int32 read FDisplayHeightMM;
    property ColorDepth: int32 read FColorDepth;
  end;

implementation

uses
    Classes
  {$ifdef FPC}
  , Math
  {$endif}
  , SysUtils
  , Types
  , bs.exceptions
  , bs.strings
  , bs.thread
  ;

var
  ApplicationLinux: BSApplicationLinux;

function XStateToBSState(XKeyState: cuint): TShiftState;
begin
  Result:= [];
  if (XKeyState and bs.linux.ShiftMask) <> 0 then
    Include(Result,ssShift);
  if (XKeyState and bs.linux.ControlMask) <> 0 then
    Include(Result,ssCtrl);
  if (XKeyState and bs.linux.Mod1Mask) <> 0 then
    Include(Result,ssAlt);
  //if (XKeyState and bs.linux.Mod5Mask) <> 0 then
  //  Include(Result, ssAltGr);
end;

function ComparatorConnectons(const Item1, Item2: cint): int8;
begin
  Result := Item2 - Item1;
end;

procedure BSConnectionWatchProc(display: PDisplay; client_data: TXPointer; fd: cint; opening: TBool; watch_data: PXPointer); cdecl;
begin
  if opening <> 0 then
    ApplicationLinux.AddConnection(fd)
  else
    ApplicationLinux.RemoveConnection(fd);
end;

{ BSApplicationLinux }

constructor BSApplicationLinux.Create;
var
  classHint: PXClassHint;
begin
  inherited;
  ApplicationLinux := Self;
  FConnections := TListVec<cint>.Create;
  FHandlers := TListHandlers.Create;

  if FDisplayName = '' then
    FDisplayName := XDisplayName(nil);

  FDisplay := XOpenDisplay(nil);

  if not Assigned(FDisplay) then
    raise EBlackShark.Create('[class constructor BSApplicationLinux.Create] XOpenDisplay failed');

  // if we have a Display then we should have a Screen too
  FScreen:= XDefaultScreen(FDisplay);

  FRootWindow := XDefaultRootWindow(FDisplay);

  // keyboard input
  InputMethod := XOpenIM(FDisplay, nil, nil, nil);
  if InputMethod <> nil then
    InputContext := XCreateIC(InputMethod, @XNInputStyle[1], XIMPreeditNothing or XIMStatusNothing, 0);

  // Initialize ScreenInfo

  // Screen Metrics
  DisplayWidth := XDisplayWidth(FDisplay, FScreen);
  FDisplayWidthMM := XDisplayWidthMM(FDisplay, FScreen);
  PixelsPerInchX := round(FDisplayWidth / (FDisplayWidthMM / 25.4));
  DisplayHeight := XDisplayHeight(FDisplay, FScreen);
  FDisplayHeightMM := XDisplayHeightMM(FDisplay,FScreen);
  PixelsPerInchY:= round(FDisplayHeight / (FDisplayHeightMM / 25.4));
  // Color Depth
  FColorDepth := XDefaultDepth(FDisplay, FScreen);

  // Screen Pixmap Format
  // ScreenFormat is just a hint to tell controls to use the screen format
  // because using the same format as the screen increases the speed of canvas copy operations
  FVisual := XDefaultVisual(FDisplay, FScreen);
  {ScreenFormat := clfARGB32; // Standard value with alpha blending support if we don't find a enum which matches the screen format
  if (ScreenInfo.ColorDepth = 16) then
    ScreenFormat:= clfRGB16_R5G6B5
  else if (ScreenInfo.ColorDepth = 24) then
  begin
    if (FVisual.blue_mask = $FF) and
      (FVisual.green_mask = $FF00) and
      (FVisual.red_mask = $FF0000) then
      ScreenFormat:= clfBGR24
    else if (FVisual.red_mask = $FF) and
      (FVisual.green_mask = $FF00) and
      (FVisual.blue_mask = $FF0000) then
    ScreenFormat:= clfRGB24;
  end
  else if (ScreenInfo.ColorDepth = 32) then begin
    if (FVisual.blue_mask = $FF) and
      (FVisual.green_mask = $FF00) and
      (FVisual.red_mask = $FF0000) then
    ScreenFormat:= clfBGRA32
    else if (FVisual.red_mask = $FF) and
      (FVisual.green_mask = $FF00) and
      (FVisual.blue_mask = $FF0000) then
    ScreenFormat:= clfRGBA32
    else if (FVisual.red_mask = $FF00) and
      (FVisual.green_mask = $FF0000) and
      (FVisual.blue_mask = $FF000000) then
    ScreenFormat:= clfARGB32;
  end;}

  LeaderWindow := XCreateSimpleWindow(FDisplay, FRootWindow, 0, 0, 1, 1, 0, 0, 0);

  classHint := XAllocClassHint;
  classHint^.res_name := 'BlackShark';
  classHint^.res_class := 'BlackShark class';
  XFree(classHint);

  ClientLeaderAtom := XInternAtom(FDisplay, 'WM_CLIENT_LEADER', ord(False));

  //FWMProtocols := XInternAtom(Display, 'WM_PROTOCOLS', Ord(False));
  // We want to get a Client Message when the user tries to close this window
  FWMState := XInternAtom(Display, '_NET_WM_STATE', Ord(True));
  FWMModalState := XInternAtom(Display, '_NET_WM_STATE_MODAL', Ord(True));
  FWMStateAbove := XInternAtom(Display, '_NET_WM_STATE_ABOVE', Ord(True));
  FWMActiveState := XInternAtom(Display, '_NET_ACTIVE_WINDOW', Ord(false));
  FWMStateFullScreen := XInternAtom(Display, '_NET_WM_STATE_FULLSCREEN', Ord(True));
  FWMDeleteWindow := XInternAtom(Display, 'WM_DELETE_WINDOW', Ord(False));
  FWMHints := XInternAtom(Display, '_MOTIF_WM_HINTS', Ord(False));
  FWMTransientFor := XInternAtom(Display, 'WM_TRANSIENT_FOR', Ord(False));
  //if FWMPaint = 0 then
  //  FWMPaint := XInternAtom(ApplicationLinux.Display, 'WM_PAINT', Ord(False));

  // Add watches to the XConnection
  XAddConnectionWatch(FDisplay, @BSConnectionWatchProc, nil);

end;

procedure BSApplicationLinux.CreateHandle(AWindow: BSWindow);
var
  colorMap: TColormap;
  sizeHints: TXSizeHints;
  attr: TXSetWindowAttributes;
  mask: longword;
  windowHints: TXWMHints;
  title: TXTextProperty;
  str: UTF8String;
  pstr: PAnsiChar;
begin
  colorMap := XCreateColormap(Display, RootWindow, Visual, AllocNone);
  FillChar(attr, SizeOf(attr), 0);
  attr.Colormap := Colormap;
  attr.Override_Redirect := 0;
  attr.event_mask := KeyPressMask or KeyReleaseMask
    or ButtonPressMask or ButtonReleaseMask
    or EnterWindowMask or LeaveWindowMask
    or ButtonMotionMask or PointerMotionMask
    or ExposureMask
    or FocusChangeMask
    or StructureNotifyMask
 // or PropertyChangeMask
    ;

  sizeHints := TWindowContextLinux(AWindow.WindowContext).GetSizeHints;

  mask := CWColormap;// or CWEventMask or CWOverrideRedirect or CWBorderPixel or CWBackPixel;

  AWindow.Handle := XCreateWindow(
    Display,
    XDefaultRootWindow(Display),        // parent
    SizeHints.x, SizeHints.x,           // position (top, left)
    SizeHints.width, SizeHints.height,  // default size (width, height)
    0,                                  // border size
    ColorDepth,                         // CopyFromParent, depth
    bs.linux.InputOutput,               // class
    XDefaultVisual(Display, XDefaultScreen(Display)),  // visual
    mask,
    @attr);

  if AWindow.Handle = 0 then
    raise Exception.Create('[BSApplicationLinux.CreateWindow] Window creation failed');

  FillChar(windowHints, SizeOf(windowHints), 0);
  windowHints.flags := StateHint OR WindowGroupHint OR InputHint;//WindowGroupHint; //InputHint or StateHint or
  windowHints.input := 1;
  windowHints.initial_state := bs.linux.NormalState;
  windowHints.window_group := LeaderWindow;
  XSetWMHints(FDisplay, AWindow.Handle, @windowHints);

  XSelectInput(Display, AWindow.Handle, attr.event_mask);
  XSetWMProtocols(Display, AWindow.Handle, @FWMDeleteWindow, 1);

  str := UTF8String(WINDOW_CAPTION);
  pstr := @str[1];
  Xutf8TextListToTextProperty(Display, @pstr, 1, XUTF8StringStyle, @title);
  XSetWMName(Display, AWindow.Handle, @title);
  XSetWMIconName(Display, AWindow.Handle, @title);
  XFree(title.value);

  //XSetStandardProperties(ApplicationLinux.Display, FHandle, nil, nil, 0, nil, 0, @SizeHints);

  //XSetWMNormalHints(ApplicationLinux.Display, FHandle, @SizeHints);

  //WindowHints.flags := WindowGroupHint;
  //WindowHints.window_group := CDWidgetSet.LeaderWindow;
  //XSetWMHints(ApplicationLinux.Display, FHandle, @WindowHints);

  XChangeProperty(FDisplay, AWindow.Handle, ClientLeaderAtom, 33, 32, PropModeReplace, @LeaderWindow, 1);

  TWindowContextLinux(AWindow.WindowContext).UpdateWmProperties;
  {
  XSetClassHint(ApplicationLinux.Display, FHandle, @winClass); }
end;

function BSApplicationLinux.CreateWindow(AWindow: BSWindow): BSWindow;
begin
  //TWindowContextLinux(AWindow.WindowContext).UpdateWmProperties;
  Result := AWindow;
  UpdateClientRect(Result);
end;

function BSApplicationLinux.CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
begin
  Result := AWindowClass.Create(TWindowContextLinux.Create, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);
  Result.DC := Display;
  CreateHandle(Result);
  UpdateClientRect(Result);
  AddWindow(Result);
end;

destructor BSApplicationLinux.Destroy;
begin
  XDestroyIC(InputContext);
  XCloseIM(InputMethod);
  XCloseDisplay(FDisplay);
  FConnections.Free;
  FHandlers.Free;
  inherited;
end;

procedure BSApplicationLinux.DoActive(AWindow: BSWindow);
var
  event: TXClientMessageEvent;
begin
  inherited;
  if AWindow.IsActive then
  begin
    FillChar(event, SizeOf(TXClientMessageEvent), 0);
    event._type := ClientMessage;
    event.send_event := Ord(true);
    event.window := AWindow.Handle;
    event.display := Display;
    event.message_type := FWMActiveState;
    event.format := 32;
    XSendEvent(Display, FRootWindow, Ord(false), SubstructureRedirectMask or SubstructureNotifyMask, @event);
  end;
end;

procedure BSApplicationLinux.DoClose(AWindow: BSWindow);
begin
  XUnmapWindow(Display, AWindow.Handle);
  inherited;
end;

procedure BSApplicationLinux.DoFullScreen(AWindow: BSWindow);
var
  event: TXClientMessageEvent;
  sizeHint: TXSizeHints;
begin
  inherited;

  XSync(Display, Ord(true));
  sizeHint := TWindowContextLinux(AWindow.WindowContext).UpdateWmProperties;

  if AWindow.FullScreen then
  begin
    AWindow.BegingFromOSChange;
    try
      AWindow.SetPosition(0, 0);
      AWindow.Resize(sizeHint.width, sizeHint.height);
    finally
      AWindow.EndFromOSChange;
    end;

    FillChar(event, SizeOf(TXClientMessageEvent), 0);
    event._type := ClientMessage;
    event.send_event := Ord(true);
    event.window := AWindow.Handle;
    event.display := Display;
    event.message_type := FWMState;
    event.format := 32;
    event.data.l[0] := _NET_WM_STATE_ADD;
    event.data.l[1] := FWMStateFullScreen;
    XSendEvent(Display, FRootWindow, Ord(false), SubstructureRedirectMask or SubstructureNotifyMask, @event );
  end else
  begin

  end;

  UpdateClientRect(AWindow);
end;

procedure BSApplicationLinux.DoInvalidate(AWindow: BSWindow);
begin
  inherited;

end;

procedure BSApplicationLinux.DoResize(AWindow: BSWindow; AWidth, AHeight: int32);
var
  mask: Cardinal;
  changes: TXWindowChanges;
begin
  mask := 0;
  if AWidth <> AWindow.Width then
    mask := CWWidth;
  if AHeight <> AWindow.Height then
    mask := mask or CWHeight;

  inherited;

  if mask <> 0 then
  begin
    FillChar(Changes, SizeOf(Changes), 0);
    Changes.Width := AWidth;
    Changes.Height := AHeight;
    XConfigureWindow(FDisplay, AWindow.Handle, mask, @Changes);
  end;

  UpdateClientRect(AWindow);
end;

procedure BSApplicationLinux.DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32);
var
  Supplied: NativeInt;
  SizeHints: TXSizeHints;
begin
  inherited;
  XGetWMNormalHints(FDisplay, AWindow.Handle, @SizeHints, @Supplied);
  SizeHints.flags := SizeHints.flags or PPosition;
  SizeHints.x := ALeft;
  SizeHints.y := ATop;
  XSetWMNormalHints(FDisplay, AWindow.Handle, @SizeHints);
  XMoveWindow(FDisplay, AWindow.Handle, ALeft, ATop);
end;

procedure BSApplicationLinux.DoShow(AWindow: BSWindow; AInModalMode: boolean);
var
  event: TXClientMessageEvent;
begin
  inherited;
  XMapRaised(Display, AWindow.Handle);
  if Assigned(AWindow.Parent) then
  begin
    if AInModalMode then
    begin
      XSetTransientForHint(Display, AWindow.Handle, AWindow.Parent.Handle);
      FillChar(event, sizeOf(event), 0);
      event._type := bs.linux.ClientMessage;
      event.message_type := FWMState;
      event.window := AWindow.Handle;
      event.display := Display;
      event.format := 32;
      event.data.l[0] := _NET_WM_STATE_ADD;
      event.data.l[1] := FWMModalState;
      XSendEvent(Display, FRootWindow, Ord(false), SubstructureRedirectMask or SubstructureNotifyMask, @event);
      XFlush(Display);
    end;
  end;
end;

function BSApplicationLinux.GetMousePointPos: TVec2i;
var
  root_return: TWindow;
  child_return: TWindow;
  root_x_return: Integer;
  root_y_return: Integer;
  mask_return: LongWord;
begin
  XQueryPointer(Display, 0, @root_return, @child_return, @root_x_return, @root_y_return, @Result.x, @Result.y, @mask_return);
end;

procedure BSApplicationLinux.HandlerClientMessage(AWindow: BSWindow; const AEvent: TXEvent);
var
  w: BSWindow;
  i: int32;
begin
  if TAtom(AEvent.xclient.Data.l[0]) = FWMDeleteWindow then
  begin
    // checks whether contains visible child in modal mode
    // if it is then ban close
    for i := 0 to AWindow.Children.Count - 1 do
    begin
      w := AWindow.Children.Items[i];
      if w.WindowState = wsShownModal then
        exit;
    end;

    AWindow.BegingFromOSChange;
    try
      AWindow.Close;
      XUnmapWindow(Display, AWindow.Handle);
    finally
      AWindow.EndFromOSChange;
    end;
  end;
end;

procedure BSApplicationLinux.HandlerConfigureNotify(AWindow: BSWindow; const AEvent: TXEvent);
var
  event: TXConfigureEvent;
  modified: boolean;
begin
  modified := false;
  event := AEvent.xconfigure;
  while XCheckTypedWindowEvent(Display, AEvent.xconfigure.window, bs.linux.NotifyPointer, @event) do;
  if (event.x <> AWindow.Left) or (event.y <> AWindow.Top) then
  begin
    AWindow.BegingFromOSChange;
    try
      modified := true;
      AWindow.SetPosition(event.x, event.y);
    finally
      AWindow.EndFromOSChange;
    end;
  end;
  if (event.width <> AWindow.Width) or (event.height <> AWindow.Height) then
  begin
    AWindow.BegingFromOSChange;
    try
      modified := true;
      AWindow.ClientRect := Rect(0, 0, event.width, event.height);
      AWindow.Resize(event.width, event.height);
    finally
      AWindow.EndFromOSChange;
    end;
  end;

  if modified then
    TWindowContextLinux(AWindow.WindowContext).UpdateWmProperties;
end;

procedure BSApplicationLinux.HandlerDestroyNotify(AWindow: BSWindow; const AEvent: TXEvent);
begin
  XDestroyWindow(Display, AWindow.Handle);
  XSync(Display, Ord(FALSE));
  AWindow.Handle := 0;
end;

procedure BSApplicationLinux.HandlerFocusIn(AWindow: BSWindow; const AEvent: TXEvent);
begin
  AWindow.BegingFromOSChange;
  try
    AWindow.IsActive := true;
  finally
    AWindow.EndFromOSChange;
  end;
end;

procedure BSApplicationLinux.HandlerFocusOut(AWindow: BSWindow; const AEvent: TXEvent);
begin
  AWindow.BegingFromOSChange;
  try
    AWindow.IsActive := false;
  finally
    AWindow.EndFromOSChange;
  end;
end;

procedure BSApplicationLinux.HandlerUnknownEvent(AWindow: BSWindow; const AEvent: TXEvent);
begin

end;

function BSApplicationLinux.StartComposing(const Event: TXKeyEvent): TKeySym;
var
  len: int32;
begin
  SetLength(ComposeBuffer, 64);
  // Xutf8LookupString returns the size of FComposeBuffer in bytes.
  len := Xutf8LookupString(InputContext, @Event, @ComposeBuffer[1],
      Length(ComposeBuffer), @Result, @ComposeStatus);

  SetLength(ComposeBuffer, len);

  // if overflow occured, then previous SetLength() would have fixed the buffer
  // size, so run Xutf8LookupString again to read correct value.
  if ComposeStatus = XBufferOverflow then
    Xutf8LookupString(InputContext, @Event, @ComposeBuffer[1],
      Length(ComposeBuffer), @Result, @ComposeStatus);
end;

procedure BSApplicationLinux.HandlerKeyPress(AWindow: BSWindow; const AEvent: TXEvent);
var
  key: word;
  ss: TBSShiftState;
  keySym: TKeySym;
  endComposing: boolean;
  i: Integer;
  s: WideString;
begin
  //xkey := XLookupKeysym(@AEvent.xkey, 0);
  keySym := StartComposing(AEvent.xkey);
  ss := XStateToBSState(AEvent.xkey.state);
  key := XKeyToBSKey(keySym, AEvent.xkey.keycode);
  AWindow.KeyDown(key, ss);
  // EndComposing embedded here
  endComposing := (ComposeStatus <> XLookupNone) and ((AEvent.xkey.state and (ControlMask or Mod1Mask)) = 0);
  if endComposing then
  begin
    {$ifdef FPC}
    s := UTF8ToString(ComposeBuffer);
    {$else}
    s := UTF8ToWideString(ComposeBuffer);
    {$endif}
    for i := 1 to length(s) do
      AWindow.KeyPress(s[i], ss);
  end;
end;

procedure BSApplicationLinux.HandlerKeyUp(AWindow: BSWindow; const AEvent: TXEvent);
var
  xkey: TKeySym;
  key: word;
  ss: TBSShiftState;
begin
  xkey := XLookupKeysym(@AEvent.xkey, 0);
  key := XKeyToBSKey(xkey, AEvent.xkey.keycode);
  ss := XStateToBSState(AEvent.xkey.state);
  AWindow.KeyUp(key, ss);
end;

procedure BSApplicationLinux.HandlerMouseDown(AWindow: BSWindow; const AEvent: TXEvent);
var
  ss: TBSShiftState;
  mb: TBSMouseButton;
begin
  FTimeMouseDown := TBTimer.CurrentTime.Counter;
  ss := XStateToBSState(AEvent.xbutton.state);
  case AEvent.xbutton.button of
    2: begin
      mb := TBSMouseButton.mbBsMiddle;
      CurrentShiftState := CurrentShiftState + [ssMiddle];
    end;
    3: begin
      mb := TBSMouseButton.mbBsRight;
      CurrentShiftState := CurrentShiftState + [ssRight];
    end else
    begin
      mb := TBSMouseButton.mbBsLeft;
      CurrentShiftState := CurrentShiftState + [ssLeft];
    end;
  end;
  ss := ss + CurrentShiftState;
  AWindow.MouseDown(mb, AEvent.xbutton.x, AEvent.xbutton.y, ss);
end;

procedure BSApplicationLinux.HandlerMouseEnter(AWindow: BSWindow; const AEvent: TXEvent);
begin
  AWindow.MouseEnter(AEvent.xmotion.x, AEvent.xmotion.y);
end;

procedure BSApplicationLinux.HandlerMouseLeave(AWindow: BSWindow; const AEvent: TXEvent);
begin
  AWindow.MouseLeave;
end;

procedure BSApplicationLinux.HandlerMouseMove(AWindow: BSWindow; const AEvent: TXEvent);
var
  event: TXEvent;
  ss: TBSShiftState;
begin
  while XCheckTypedWindowEvent(Display, AEvent.xmotion.window, bs.linux.MotionNotify, @event) do;
  ss := XStateToBSState(AEvent.xmotion.state) + CurrentShiftState;
  AWindow.MouseMove(AEvent.xmotion.x, AEvent.xmotion.y, ss);
end;

procedure BSApplicationLinux.HandlerMouseUp(AWindow: BSWindow; const AEvent: TXEvent);
var
  ss: TBSShiftState;
  mb: TBSMouseButton;
begin
  ss := XStateToBSState(AEvent.xbutton.state);
  case AEvent.xbutton.button of
    2: begin
      mb := TBSMouseButton.mbBsMiddle;
      CurrentShiftState := CurrentShiftState - [ssMiddle];
    end;
    3: begin
      mb := TBSMouseButton.mbBsRight;
      CurrentShiftState := CurrentShiftState - [ssRight];
    end else
    begin
      mb := TBSMouseButton.mbBsLeft;
      CurrentShiftState := CurrentShiftState - [ssLeft];
    end;
  end;
  ss := ss + CurrentShiftState;
  if AEvent.xbutton.button = 4 then
    AWindow.MouseWheel(4*(TBTimer.CurrentTime.Counter - FTimeMouseDown), AEvent.xbutton.x, AEvent.xbutton.y, ss)
  else
  if AEvent.xbutton.button = 5 then
    AWindow.MouseWheel(-4*Integer((TBTimer.CurrentTime.Counter - FTimeMouseDown)), AEvent.xbutton.x, AEvent.xbutton.y, ss)
  else
  begin
    AWindow.MouseUp(mb, AEvent.xbutton.x, AEvent.xbutton.y, ss);
    if TBTimer.CurrentTime.Low - LastTimeMouseUp < MOUSE_DOUBLE_CLICK_DELTA then
      AWindow.MouseDblClick(AEvent.xbutton.x, AEvent.xbutton.y);
  end;
  LastTimeMouseUp := TBTimer.CurrentTime.Low;
end;

procedure BSApplicationLinux.HandlerPaint(AWindow: BSWindow; const AEvent: TXEvent);
var
  event: TXEvent;
begin
  // This repeat really helps speeding up when maximized for example
  while XCheckTypedWindowEvent(Display, AEvent.xexpose.window, bs.linux.Expose, @event) do;
  AWindow.Draw;
end;

procedure BSApplicationLinux.HandlerResizeRequest(AWindow: BSWindow; const AEvent: TXEvent);
var
  changed: boolean;
begin
  changed := (AWindow.Width <> AEvent.xresizerequest.width) or (AWindow.Height <> AEvent.xresizerequest.height);
  if changed then
  begin
    //???
    //AWindow.Resize(AEvent.xresizerequest.width, AEvent.xresizerequest.height);
    //TWindowContextLinux(AWindow.WindowContext).UpdateWmProperties;
  end;
end;

procedure BSApplicationLinux.HandlerUnmapNotify(AWindow: BSWindow; const AEvent: TXEvent);
begin
  {AWindow.BegingFromOSChange;
  try
    AWindow.Close;
  finally
    AWindow.EndFromOSChange;
  end;    }
end;

procedure BSApplicationLinux.InitHandlers;
begin
  FHandlers.Items[bs.linux.KeyPress] := HandlerKeyPress;
  FHandlers.Items[bs.linux.KeyRelease] := HandlerKeyUp;
  FHandlers.Items[bs.linux.Expose] := HandlerPaint;
  FHandlers.Items[bs.linux.ClientMessage] := HandlerClientMessage;
  FHandlers.Items[bs.linux.EnterNotify] := HandlerMouseEnter;
  FHandlers.Items[bs.linux.MotionNotify] := HandlerMouseMove;
  FHandlers.Items[bs.linux.LeaveNotify] := HandlerMouseLeave;
  FHandlers.Items[bs.linux.ButtonPress] := HandlerMouseDown;
  FHandlers.Items[bs.linux.ButtonRelease] := HandlerMouseUp;
  FHandlers.Items[bs.linux.ConfigureNotify] := HandlerConfigureNotify;
  FHandlers.Items[bs.linux.ResizeRequest] := HandlerResizeRequest;
  FHandlers.Items[bs.linux.UnmapNotify] := HandlerUnmapNotify;
  FHandlers.Items[bs.linux.DestroyNotify] := HandlerDestroyNotify;
  FHandlers.Items[bs.linux.FocusIn] := HandlerFocusIn;
  FHandlers.Items[bs.linux.FocusOut] := HandlerFocusOut;
end;

procedure BSApplicationLinux.InitMonitors;
begin
  inherited;

end;

procedure BSApplicationLinux.ProcessEvent(AWindow: BSWindow; const AEvent: TXEvent);
var
  handler: TEventHandler;
begin
  handler := FHandlers.Items[AEvent._type];
  if Assigned(handler) then
    handler(AWindow, AEvent)
  else
    HandlerUnknownEvent(AWindow, AEvent);

    {
    bs.linux.FocusIn:
    begin
    end;

    bs.linux.FocusOut:
    begin
    end;

    bs.linux.ReparentNotify:
    begin
    end;
    }

end;

procedure BSApplicationLinux.Update;
var
  event: TXEvent;
  window: BSWindow;
  i: int32;
begin
  if FWindows.Count = 0 then
    exit;

  if XPending(Display) > 0 then
  begin
    XNextEvent(Display, @event);
    if FWindows.Count > 1 then
    begin
      if FWindows.Find(event.xany.window, window) then
      begin
        ProcessEvent(window, event);
        for i := 0 to window.Children.Count - 1 do
          window.Children.Items[i].Draw;
      end;
    end else
    begin
      ProcessEvent(FMainWindow, event);
    end;
  end else
  begin
    // send redraw event
    XSendEvent(Display, FMainWindow.Handle, ord(False), bs.linux.ExposureMask, @TWindowContextLinux(FMainWindow.WindowContext).ExposeEvent);
    for i := 0 to FMainWindow.Children.Count - 1 do
      FMainWindow.Children.Items[i].Draw;
  end;

  inherited;
end;

procedure BSApplicationLinux.UpdateClientRect(AWindow: BSWindow);
begin
  AWindow.ClientRect := Rect(0, 0, AWindow.Width, AWindow.Height);
end;

procedure BSApplicationLinux.UpdateWait;
var
  event: TXEvent;
  window: BSWindow;
begin
  if FWindows.Count = 0 then
    exit;
  XPeekEvent(Display, @event);
  XNextEvent(Display, @event);
  if FWindows.Count > 1 then
  begin
    if FWindows.Find(event.xany.window, window) then
      ProcessEvent(window, event);
  end else
    ProcessEvent(FMainWindow, event);

  inherited;
end;

procedure BSApplicationLinux.AddConnection(AConnection: cint);
begin
  FConnections.Add(AConnection);
end;

procedure BSApplicationLinux.RemoveConnection(AConnection: cint);
begin
  FConnections.Remove(AConnection);
end;

{ TWindowContextLinux }

constructor TWindowContextLinux.Create;
begin
  ExposeEvent._type := bs.linux.Expose;
end;

destructor TWindowContextLinux.Destroy;
begin
  if Window.Handle > 0 then
  begin
    XDestroyWindow(ApplicationLinux.Display, Window.Handle);
    XSync(ApplicationLinux.Display, Ord(FALSE));
  end;
  inherited;
end;

function TWindowContextLinux.GetDC: EGLNativeDisplayType;
begin
  Result := ApplicationLinux.Display;
end;

function TWindowContextLinux.GetSizeHints: TXSizeHints;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.max_width  := ApplicationLinux.DisplayWidth;
  Result.max_height := ApplicationLinux.DisplayHeight;
  Result.min_width  := 10;
  Result.min_height := 10;
  if Window.FullScreen or ((Window.Width >= ApplicationLinux.DisplayWidth) and (Window.Height >= ApplicationLinux.DisplayHeight)) then
  begin
    Result.flags    := bs.linux.PBaseSize or bs.linux.PWinGravity;
    Result.x        := 0;
    Result.y        := 0;
    Result.width    := ApplicationLinux.DisplayWidth;
    Result.height   := ApplicationLinux.DisplayHeight;
  end else
  begin
    Result.flags    := bs.linux.PPosition or bs.linux.PSize or bs.linux.PMinSize or bs.linux.PMaxSize;
    Result.x        := Window.Left;
    Result.y        := Window.Top;
    Result.width    := Window.Width;
    Result.height   := Window.Height;
  end;
end;

procedure TWindowContextLinux.SetDC(const AValue: EGLNativeDisplayType);
begin
  inherited;
  ExposeEvent.xexpose.display := AValue;
end;

procedure TWindowContextLinux.SetHandle(const AValue: EGLNativeWindowType);
begin
  inherited;
  ExposeEvent.xexpose.window := AValue;
end;

function TWindowContextLinux.UpdateWmProperties: TXSizeHints;
begin
  //XGetWindowProperty(ApplicationLinux.Display, FHandle,
  //  ApplicationLinux.FWMHints, 0, 5, Ord(False), bs.linux.AnyPropertyType, @PropType,
  //  @PropFormat, @PropItemCount, @PropBytesAfter, @Hints);

  if not Window.IsVisible then
    exit;

  Result := GetSizeHints;

  XSetWMNormalHints(ApplicationLinux.Display, Handle, @Result);

  //winClass.res_name  := 'BlackShark';
  ///winClass.res_class := 'BlackShark class';
  //XSetWMProperties(ApplicationLinux.Display, Handle, nil, nil, nil, 0, @SizeHints, @WindowHints, nil);//@winClass
end;

end.
