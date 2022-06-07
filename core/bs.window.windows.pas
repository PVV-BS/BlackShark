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
unit bs.window.windows;

{$I BlackSharkCfg.inc}

interface

uses
    Windows
  , bs.basetypes
  , bs.window
  , bs.gl.egl
  , bs.collections
  , bs.events
  {$ifndef FPC}
  , bs.gl.context
  , bs.config
  , bs.renderer
  {$endif}
  ;

type

  TEventWindowsHandler = procedure(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM) of object;

  TWindowContextWindows = class(TWindowContext)
  private
  protected
    function GetDC: EGLNativeDisplayType; override;
    procedure SetHandle(const AValue: EGLNativeWindowType); override;
  public
    destructor Destroy; override;
  end;

  { BSApplicationWindows }

  BSApplicationWindows = class(BSApplicationSystem)
  private
    FHandlers: TListVec<TEventWindowsHandler>;

    procedure HandlerActivate(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerClose(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerDestroy(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerQuit(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerPaint(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerSize(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerDrag(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerSetCursor(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerLBMouseClick(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerLBMouseDblClick(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerLBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerMBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerRBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerLBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerMBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerRBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerMouseMove(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerMouseLeave(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerMouseWheel(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerKeyDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerKeyUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
    procedure HandlerKeyPress(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);

    function GetShiftState(AWindow: BSWindow; lParam: LPARAM): TBSShiftState;
    function CreateHandle(AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): EGLNativeWindowType;
    procedure UpdateClientRect(AWindow: BSWindow);
    function DefaultSizableStyle: uint32;
    function FullScreenStyle: uint32;
  protected
    procedure InitHandlers; override;
    procedure InitMonitors; override;
    function ProcessMessage(AWindow: BSWindow; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
    procedure DoShow(AWindow: BSWindow; AInModalMode: boolean); override;
    procedure DoClose(AWindow: BSWindow); override;
    procedure DoInvalidate(AWindow: BSWindow); override;
    procedure DoResize(AWindow: BSWindow; AWidth, AHeight: int32); override;
    procedure DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32); override;
    procedure DoFullScreen(AWindow: BSWindow); override;
    procedure DoActive(AWindow: BSWindow); override;
    procedure DoShowCursor(AWindow: BSWindow); override;
    function GetMousePointPos: TVec2i; override;
    procedure ChangeDisplayResolution(NewWidth, NewHeight: int32); // overload;
  public
    constructor Create;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; override;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; override;
    destructor Destroy; override;
    procedure Update; override;
    procedure UpdateWait; override;
  end;

var
    ApplicationWindows: BSApplicationWindows;

const
    CLASS_NAME: WideString = 'BlackShark';

implementation

uses
    Classes
  , messages
  , bs.exceptions
  , bs.math
  , bs.strings
  ;

var
  RegistredClass: TWndClassExW;


function ApplicationProcessMessages(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  window: BSWindow;
begin
  window := Pointer(GetWindowLongPtr(hWnd, GWL_USERDATA));
  if Assigned(window) then
  begin
    if (window.WindowState = wsInit) or (window.Handle <> hWnd) then
      Result := DefWindowProc(hWnd, Msg, wParam, lParam)
    else
      Result := ApplicationWindows.ProcessMessage(window, Msg, wParam, lParam)
  end else
    Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;

function ParamToShiftState(wParam: WPARAM): TBSShiftState;
begin
  Result := [];
  if wParam and MK_LBUTTON <> 0 then
    Include(Result, ssLeft);
  if wParam and MK_MBUTTON <> 0 then
    Include(Result, ssMiddle);
  if wParam and MK_RBUTTON <> 0 then
    Include(Result, ssRight);
  if wParam and MK_SHIFT <> 0 then
    Include(Result, ssShift);
  if wParam and MK_CONTROL <> 0 then
    Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then
    Include(Result, ssAlt);
end;

function ParamToXPos(lParam: LPARAM): int32;
begin
  Result := lParam and $FFFF;
end;

function ParamToYPos(lParam: LPARAM): int32;
begin
  Result := (lParam shr 16) and $FFFF;
end;

function ParamToWheelDelta(wParam: WPARAM): int32;
begin
  Result := int16(wParam shr 16);
end;

destructor TWindowContextWindows.Destroy;
begin
  if Handle > 0 then
  begin
    DestroyWindow(Handle);
    if FDC > 0 then
      ReleaseDC(Handle, FDC);
  end;
  inherited;
end;

function TWindowContextWindows.GetDC: EGLNativeDisplayType;
begin
  if FDC > 0 then
    ReleaseDC(Handle, FDC);
  FDC := Windows.GetDC(Handle);
  Result := FDC;
end;

procedure TWindowContextWindows.SetHandle(const AValue: EGLNativeWindowType);
begin
  if FHandle > 0 then
  begin
    DestroyWindow(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

{ BSApplicationWindows }

procedure BSApplicationWindows.DoActive(AWindow: BSWindow);
begin
  inherited;
  if AWindow.IsActive then
    SetActiveWindow(AWindow.Handle);
end;

procedure BSApplicationWindows.DoClose(AWindow: BSWindow);
begin
  inherited;
  //SendMessage(AWindow.Handle, WM_CLOSE, 0, 0);
  ShowWindow(AWindow.Handle, SW_HIDE);
  if Assigned(AWindow.Parent) then
  begin
    if (AWindow.WindowState = wsShownModal) then
      EnableWindow(AWindow.Parent.Handle, TRUE);

    BringWindowToTop(AWindow.Parent.Handle);
  end;
end;

procedure BSApplicationWindows.DoFullScreen(AWindow: BSWindow);
var
  style: uint32;
begin
  inherited;
  if AWindow.FullScreen then
    style := FullScreenStyle
  else
    style := DefaultSizableStyle;
  SetWindowLongW(AWindow.Handle, GWL_STYLE, style);
  SetWindowLongW(AWindow.Handle, GWL_EXSTYLE, WS_EX_APPWINDOW or WS_EX_TOPMOST * byte(AWindow.FullScreen));
  if AWindow.FullScreen then
  begin
    DoSetPosition(AWindow, 0, 0);
    DoResize(AWindow, DisplayWidth, DisplayHeight);
  end;
end;

procedure BSApplicationWindows.ChangeDisplayResolution(NewWidth, NewHeight: int32);
var
  dm: _devicemodeW;
begin
  FillChar(dm, sizeof(dm), 0);
  dm.dmSize := sizeof(dm);
  dm.dmPelsWidth := NewWidth;
  dm.dmPelsHeight := NewHeight;
  dm.dmBitsPerPel := 32;
  dm.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
  ChangeDisplaySettingsW(dm, CDS_FULLSCREEN);
end;

constructor BSApplicationWindows.Create;
var
  h: HDC;
begin
  inherited;
  ApplicationWindows := Self;
  FHandlers := TListVec<TEventWindowsHandler>.Create;
  DisplayWidth := GetSystemMetrics(SM_CXSCREEN);
  DisplayHeight := GetSystemMetrics(SM_CYSCREEN);
  h := GetDC(0);
  PixelsPerInchX := GetDeviceCaps(h, LOGPIXELSX);
  PixelsPerInchY := GetDeviceCaps(h, LOGPIXELSY);
  ReleaseDC(0, h);
end;

function BSApplicationWindows.CreateHandle(AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): EGLNativeWindowType;
var
  style: LongWord;
  parentHandle: EGLNativeWindowType;
  w, h: int32;
begin

  if Assigned(AParent) then
    parentHandle := AParent.Handle
  else
    parentHandle := 0;

  w := clamp(DisplayWidth, 32, AWidth);
  h := clamp(DisplayHeight, 32, AHeight);

  style := DefaultSizableStyle;

  Result := CreateWindowExW(WS_EX_APPWINDOW, @CLASS_NAME[1], @WINDOW_CAPTION[1], //WS_EX_WINDOWEDGE or WS_EX_DLGMODALFRAME WS_EX_APPWINDOW  WS_EX_APPWINDOW or WS_EX_TOPMOST
                              style, APositionX, APositionY, w, h, parentHandle, 0, RegistredClass.hInstance, nil);
  {$ifdef FPC}
  if style and WS_CAPTION > 0 then
    SetWindowTextW(Result, @WideToAnsi(WINDOW_CAPTION)[1]);
  {$endif}
end;

function BSApplicationWindows.CreateWindow(AWindow: BSWindow): BSWindow;
begin
  Result := AWindow;
  AWindow.Handle := CreateHandle(AWindow.Parent, AWindow.Left, AWindow.Top, AWindow.Width, AWindow.Height);
  SetWindowLongPtr(AWindow.Handle, GWL_USERDATA, NativeInt(Result));
  UpdateClientRect(AWindow);
end;

function BSApplicationWindows.CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
var
  windowContext: TWindowContextWindows;
  handle: EGLNativeWindowType;
begin

  handle := CreateHandle(AParent, APositionX, APositionY, AWidth, AHeight);

  if (handle = 0) Then
    exit(nil);

  //SetWindowLong(handle, GWL_STYLE, WS_BORDER);

  windowContext := TWindowContextWindows.Create;
  windowContext.Handle := handle;

  Result := AWindowClass.Create(windowContext, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);

  SetWindowLongPtr(windowContext.Handle, GWL_USERDATA, NativeInt(Result));
  AddWindow(Result);
  UpdateClientRect(Result);
end;

function BSApplicationWindows.GetMousePointPos: TVec2i;
begin
  if not GetCursorPos(Result.Point) then
    Result := vec2(0, 0);
end;

function BSApplicationWindows.GetShiftState(AWindow: BSWindow; lParam: LPARAM): TBSShiftState;
const
  ALT_FLAG = $20000000;
begin
  Result := AWindow.GetShiftStateFromKeyStates;
  if lParam and ALT_FLAG <> 0 then
    Include(Result, ssAlt);
end;

procedure BSApplicationWindows.HandlerActivate(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.BegingFromOSChange;
  try
    AWindow.IsActive := true;
  finally
    AWindow.EndFromOSChange;
  end;
  // todo
  //AWindow.WindowState := wsShown;
  //SetActiveWindow(AWindow.Handle);
end;

procedure BSApplicationWindows.HandlerClose(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.Close;
end;

procedure BSApplicationWindows.HandlerDestroy(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin

end;

procedure BSApplicationWindows.HandlerDrag(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  x, y: int32;
begin
  AWindow.BegingFromOSChange;
  try
    x := ParamToXPos(lParam);
    y := ParamToYPos(lParam) - AWindow.ClientRect.Top;
    AWindow.SetPosition(x, y);
  finally
    AWindow.EndFromOSChange;
  end;
end;

procedure BSApplicationWindows.HandlerKeyDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  key: Word;
begin
  key := Word(wParam);
  AWindow.KeyDown(key, GetShiftState(AWindow, lParam));
end;

procedure BSApplicationWindows.HandlerKeyPress(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  ch: Widechar;
begin
  ch := Widechar(wParam);
  AWindow.KeyPress(ch, GetShiftState(AWindow, lParam));
end;

procedure BSApplicationWindows.HandlerKeyUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  key: Word;
begin
  key := Word(wParam);
  AWindow.KeyUp(key, GetShiftState(AWindow, lParam));
end;

procedure BSApplicationWindows.HandlerLBMouseClick(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  //MouseClick(
end;

procedure BSApplicationWindows.HandlerLBMouseDblClick(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseDblClick(ParamToXPos(lParam), ParamToYPos(lParam));
end;

procedure BSApplicationWindows.HandlerLBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseDown(TBSMouseButton.mbBsLeft, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerLBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseUp(TBSMouseButton.mbBsLeft, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerMBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseDown(TBSMouseButton.mbBsMiddle, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerMBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseUp(TBSMouseButton.mbBsMiddle, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerMouseLeave(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseLeave;
end;

procedure BSApplicationWindows.HandlerMouseMove(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  LMouseEvent: TTrackMouseEvent;
  x, y: int32;
begin
  x := ParamToXPos(lParam);
  y := ParamToYPos(lParam);
  if not AWindow.MouseEntered then
  begin
    AWindow.MouseEnter(x, y);
    LMouseEvent.dwFlags := TME_LEAVE;
    LMouseEvent.hwndTrack := AWindow.Handle;
    LMouseEvent.dwHoverTime := HOVER_DEFAULT;
    LMouseEvent.cbSize := SizeOf(LMouseEvent);
    TrackMouseEvent(LMouseEvent);
  end;
  AWindow.MouseMove(x, y, ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerMouseWheel(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  x, y: int32;
begin
  x := ParamToXPos(lParam) - AWindow.Left;
  y := ParamToYPos(lParam) - AWindow.Top;
  AWindow.MouseWheel(ParamToWheelDelta(wParam), x, y, ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerPaint(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.Draw;
  ValidateRect(AWindow.Handle, nil);
end;

procedure BSApplicationWindows.HandlerQuit(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin

end;

procedure BSApplicationWindows.HandlerRBMouseDown(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseDown(TBSMouseButton.mbBsRight, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerRBMouseUp(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  AWindow.MouseUp(TBSMouseButton.mbBsRight, ParamToXPos(lParam), ParamToYPos(lParam), ParamToShiftState(wParam));
end;

procedure BSApplicationWindows.HandlerSetCursor(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
begin
  if AWindow.IsActive and not AWindow.ShowCursor and (LOWORD(lparam) = HTCLIENT) then
    SetCursor(0)
  else
    SetCursor(LoadCursor(0, IDC_ARROW));
end;

procedure BSApplicationWindows.HandlerSize(AWindow: BSWindow; wParam: WPARAM; lParam: LPARAM);
var
  rect: TRect;
begin
  AWindow.BegingFromOSChange;
  try
    if (wParam = SIZE_MINIMIZED) Then
    begin
      SendMessage(AWindow.Handle, WM_ACTIVATEAPP, 0, 0 );
      AWindow.WindowState := wsMinimazed;
    end;
    if (wParam = SIZE_MAXIMIZED) or (wParam = SIZE_RESTORED) Then
    begin
      UpdateClientRect(AWindow);
      GetWindowRect(AWindow.Handle, rect);
      if (AWindow.Left <> rect.Left) or (AWindow.Top <> rect.Top) then
        AWindow.SetPosition(rect.Left, rect.Top);
      if (AWindow.Width <> rect.Width) or (AWindow.Height <> rect.Height) then
        AWindow.Resize(rect.Width, rect.Height);

      SendMessage(AWindow.Handle, WM_ACTIVATEAPP, 1, 0 );
    end;
  finally
    AWindow.EndFromOSChange;
  end;
end;

procedure BSApplicationWindows.InitHandlers;
begin
  inherited;
  FHandlers.Items[WM_CLOSE] := HandlerClose;
  FHandlers.Items[WM_DESTROY] := HandlerDestroy;
  FHandlers.Items[WM_QUIT] := HandlerQuit;
  FHandlers.Items[WM_PAINT] := HandlerPaint;
  FHandlers.Items[WA_CLICKACTIVE] := HandlerActivate;
  FHandlers.Items[WM_ACTIVATE] := HandlerActivate;
  FHandlers.Items[WM_SIZE] := HandlerSize;
  FHandlers.Items[WM_MOVE] := HandlerDrag;
  FHandlers.Items[WM_SETCURSOR] := HandlerSetCursor;
  FHandlers.Items[WM_LBUTTONDOWN] := HandlerLBMouseClick;
  FHandlers.Items[WM_LBUTTONDBLCLK] := HandlerLBMouseDblClick;
  FHandlers.Items[WM_MBUTTONDBLCLK] := HandlerLBMouseDblClick;
  FHandlers.Items[WM_RBUTTONDBLCLK] := HandlerLBMouseDblClick;
  FHandlers.Items[WM_LBUTTONDOWN] := HandlerLBMouseDown;
  FHandlers.Items[WM_LBUTTONUP] := HandlerLBMouseUp;
  FHandlers.Items[WM_MBUTTONDOWN] := HandlerMBMouseDown;
  FHandlers.Items[WM_MBUTTONUP] := HandlerMBMouseUp;
  FHandlers.Items[WM_RBUTTONDOWN] := HandlerRBMouseDown;
  FHandlers.Items[WM_RBUTTONUP] := HandlerRBMouseUp;
  FHandlers.Items[WM_MOUSEWHEEL] := HandlerMouseWheel;
  FHandlers.Items[WM_MOUSEMOVE] := HandlerMouseMove;
  FHandlers.Items[WM_MOUSELEAVE] := HandlerMouseLeave;
  FHandlers.Items[WM_KEYDOWN] := HandlerKeyDown;
  FHandlers.Items[WM_KEYUP] := HandlerKeyUp;
  FHandlers.Items[WM_CHAR] := HandlerKeyPress;
end;

procedure BSApplicationWindows.InitMonitors;
var
  count, i: int32;
  monitor: TMonitor;
begin
  inherited;
  count := GetSystemMetrics(SM_CMONITORS);
  for i := 0 to count - 1 do
  begin
    monitor := TMonitor.Create;
    FMonitors.Add(monitor);
  end;
end;

procedure BSApplicationWindows.DoInvalidate(AWindow: BSWindow);
begin
  inherited;
  SendMessage(AWindow.Handle, WM_PAINT, 0, 0);
end;

function BSApplicationWindows.DefaultSizableStyle: uint32;
begin
  Result := WS_CAPTION or WS_SYSMENU or WS_VISIBLE or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX;
end;

destructor BSApplicationWindows.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

function BSApplicationWindows.ProcessMessage(AWindow: BSWindow; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  handler: TEventWindowsHandler;
begin
  Result := 0;

  handler := FHandlers.Items[Msg];
  if Assigned(handler) then
    handler(AWindow, wParam, lParam)
  else
    Result := DefWindowProc(AWindow.Handle, Msg, wParam, lParam);

end;

procedure BSApplicationWindows.DoShow(AWindow: BSWindow; AInModalMode: boolean);
begin
  inherited;
  if AWindow.Handle = 0 then
    CreateWindow(AWindow);
  ShowWindow(AWindow.Handle, SW_SHOW);
  UpdateWindow(AWindow.Handle);
  if AInModalMode and Assigned(AWindow.Parent) then
    EnableWindow(AWindow.Parent.Handle, FALSE);
end;

procedure BSApplicationWindows.DoShowCursor(AWindow: BSWindow);
begin
  // todo
end;

function BSApplicationWindows.FullScreenStyle: uint32;
begin
  Result := WS_POPUP or WS_VISIBLE or WS_SYSMENU;
end;

procedure BSApplicationWindows.DoResize(AWindow: BSWindow; AWidth, AHeight: int32);
begin
  inherited;
  if AWindow.FullScreen then
    SetWindowPos(AWindow.Handle, HWND_TOPMOST, 0, 0, AWidth, AHeight, SWP_NOACTIVATE)
  else
    SetWindowPos(AWindow.Handle, HWND_NOTOPMOST, AWindow.Left, AWindow.Top, AWidth, AHeight, SWP_NOACTIVATE);
end;

procedure BSApplicationWindows.DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32);
begin
  inherited;
  if AWindow.FullScreen then
    SetWindowPos(AWindow.Handle, HWND_TOPMOST, 0, 0, AWindow.Width, AWindow.Height, SWP_NOACTIVATE)
  else
    SetWindowPos(AWindow.Handle, HWND_NOTOPMOST, ALeft, ATop, AWindow.Width, AWindow.Height, SWP_NOACTIVATE);
end;

{procedure BSApplicationWindows.DoSetShowCursor(AWindow: BSWindow; const Value: boolean);
begin
  inherited;
  AWindow.ShowCursor := Value;
  if AWindow.ShowCursor then
    SendMessage(AWindow.Handle, WM_SETCURSOR, 0, 0)
  else
    SendMessage(AWindow.Handle, WM_SETCURSOR, 0, HTCLIENT);
end;  }

procedure BSApplicationWindows.Update;
var
  msg: tagMSG;
  i: int32;
begin
  if FWindowsList.Count = 0 then
    exit;

  if PeekMessageW(msg, 0, 0, 0, PM_REMOVE) then
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;

  for i := 0 to FWindowsList.Count - 1 do
  begin
    FWindowsList.Items[i].Draw;
  end;

  inherited;
end;

procedure BSApplicationWindows.UpdateClientRect(AWindow: BSWindow);
var
  rect: TRect;
begin
  GetClientRect(AWindow.Handle, rect);
  AWindow.ClientRect := rect;
end;

procedure BSApplicationWindows.UpdateWait;
var
  msg: tagMSG;
  i: int32;
begin
  if FWindowsList.Count = 0 then
    exit;
  //message any window
  if (GetMessage(msg, 0, 0, 0)) then
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
  for i := 0 to FWindowsList.Count - 1 do
  begin
    FWindowsList.Items[i].Draw;
  end;
  inherited;
end;

procedure RegisterClassWindow;
begin
  FillChar(RegistredClass, SizeOf(RegistredClass), 0);
  RegistredClass.cbSize        := SizeOf( TWndClassExW );
  RegistredClass.style         := CS_DBLCLKS or CS_OWNDC;
  //RegistredClass.style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC or CS_DBLCLKS;
  RegistredClass.lpfnWndProc   := @ApplicationProcessMessages;
  RegistredClass.hInstance     := GetModuleHandle(nil);
  RegistredClass.hIcon         := LoadIconW  ( RegistredClass.hInstance, 'MAINICON' );
  RegistredClass.hCursor       := LoadCursorW( RegistredClass.hInstance, PWideChar( IDC_ARROW ) );
  RegistredClass.hbrBackGround := GetStockObject( BLACK_BRUSH );
  RegistredClass.lpszClassName := @CLASS_NAME[1];
  if RegisterClassExW(RegistredClass) = 0 then
    raise EBlackShark.Create('The class already registred!');
end;

initialization
  RegisterClassWindow;

finalization
  UnRegisterClassW(@CLASS_NAME[1], RegistredClass.hInstance);

end.
