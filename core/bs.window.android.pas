unit bs.window.android;

{$ifdef FPC}
  {$WARN 5024 off : Parameter "$1" not used}
  {$WARN 5026 off : Value parameter "$1" is assigned but never used}
{$endif}

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.window
  , bs.gui.base
  , bs.gl.egl
  , bs.android.jni
  , bs.events
  , bs.collections
  ;

const
  SCREEN_ORIENTATION_LANDSCAPE: int32 = 0;
  SCREEN_ORIENTATION_PORTRAIT: int32 = 1;

type

  { TWindowContextAndroid }

  TWindowContextAndroid = class(TWindowContext)
  protected
    function GetDC: EGLNativeDisplayType; override;
    function GetHandle: EGLNativeWindowType; override;
  end;

  { BSApplicationAndroid }

  BSApplicationAndroid = class(BSApplicationSystem)
  private
    const
      //OPCODE_SHOW_KEYBOARD   = 6;
      //OPCODE_HIDE_KEYBOARD   = 7;
      //OPCODE_EXIT            = 8;
      OPCODE_ANIMATION_RUN   = 9;
      OPCODE_ANIMATION_STOP  = 10;
      OPCODE_LIST_ACTIONS    = 11;
  private
    LastTimeMouseUp: uint32;
    FTimeMouseDown: uint64;
    GuiEvetnsObserver: IBOpCodeEventObserver;
    FLastOpCode: int32;
    FStackNeedActions: TListVec<int32>;
    function GetShiftState(JShiftState: JInt): TBSShiftState;
    procedure OnGuiEvent(const AData: BOpCode);
    procedure UpdateClientRect(AWindow: BSWindow);
    function BuildCommonResult: int32;
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
    function GetMousePointPos: TVec2i; override;
    procedure ChangeDisplayResolution(NewWidth, NewHeight: int32); // overload;
  public
    constructor Create;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; override;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; override;
    destructor Destroy; override;
    procedure Update; override;
    procedure UpdateWait; override;

    function OnTouch(ActionID: int32; PointerID: int32; X, Y: int32; Pressure: single): int32;
    function ProcsessOnKey(IsDown: boolean; keyChar: JChar; keyCode: JInt; shiftState: JInt): int32;
    function GetWindow(X, Y: int32): BSWindow;
    function GetNextAction: int32;
  end;

{ exported interface of the engine }
function JNI_OnLoad(VM: PJavaVM; {%H-}reserved: pointer): JInt; cdecl;
procedure JNI_OnUnload(VM: PJavaVM; {%H-}reserved: pointer); cdecl;
function bsNativeInit({%H-}PEnv: PJNIEnv; this: JObject; AAppDir, AFilesDir: jstring): JInt; cdecl;
procedure bsNativeOnViewCreated(PEnv: PJNIEnv; this: JObject; nativeHandle: JObject; displayWidthPixels: jfloat; displayHeightPixels: jfloat; dpiX: jfloat; dpiY: jfloat); cdecl;
procedure bsNativeOnViewChanged(PEnv: PJNIEnv; this: JObject; Width, Height: JInt); cdecl;
procedure bsNativeOnDraw(PEnv: PJNIEnv; this: JObject); cdecl;
procedure bsNativeOnChangeFocus(PEnv: PJNIEnv; this: JObject; nativeHandle: JObject; IsFocused: JBoolean);  cdecl;
function bsNativeOnTouch(PEnv: PJNIEnv; this: jobject; ActionID: int32; PointerID: jint; X, Y, Pressure: jfloat): JInt; cdecl;
function bsNativeOnKeyDown(PEnv: PJNIEnv; this: JObject; keyChar: JChar; keyCode: JInt; shiftState: JInt): JInt; cdecl;
function bsNativeOnKeyUp(PEnv: PJNIEnv; this: JObject; keyChar: JChar; keyCode: JInt; shiftState: JInt): JInt; cdecl;
function bsNativeOnBackPressed(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
function bsNativeNextAction(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
function bsNativeGetIntAttribute(PEnv: PJNIEnv; this: jobject; AName: jstring; ADefault: JInt): JInt; cdecl;
function bsNativeGetBoolAttribute(PEnv: PJNIEnv; this: jobject; AName: jstring; ADefault: jboolean): jboolean; cdecl;
procedure bsNativeOnViewDestroy(PEnv: PJNIEnv; this: JObject); cdecl;

var
  ApplicationAndroid: BSApplicationAndroid;
  g_NativeHandleView: JObject = nil;

const
  ANDROID_CLASS_NAME: PAnsiChar = 'org/bshark/blackshark/BlackSharkApplication';

implementation

uses
    SysUtils
  , Classes
  , types
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  , bs.gl.es
  , bs.utils
  , bs.thread
  , bs.config
  , bs.events.keyboard
  {$ifndef FPC}
  , FMX.Platform.Android
  //,  fmx.Platform.Android
  {$endif}

  ;

{ BSApplicationAndroid }

procedure BSApplicationAndroid.ChangeDisplayResolution(NewWidth, NewHeight: int32);
begin

end;

constructor BSApplicationAndroid.Create;
begin
  inherited;
  ApplicationAndroid := Self;
  GuiEvetnsObserver := CreateOpCodeObserver(bs.gui.base.TBControl.ControlEvents, OnGuiEvent);
  FStackNeedActions := TListVec<int32>.Create;
end;

function BSApplicationAndroid.CreateWindow(AWindow: BSWindow): BSWindow;
begin
  Result := AWindow;
end;

function BSApplicationAndroid.CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
begin
  Result := AWindowClass.Create(TWindowContextAndroid.Create, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);
  Result.ClientRect := Rect(0, 0, AWidth, AHeight);
  AddWindow(Result);
end;

destructor BSApplicationAndroid.Destroy;
begin
  FStackNeedActions.Free;
  inherited;
end;

procedure BSApplicationAndroid.DoActive(AWindow: BSWindow);
begin
  inherited;
  ApplicationRun;
end;

procedure BSApplicationAndroid.DoClose(AWindow: BSWindow);
begin
  inherited;

end;

procedure BSApplicationAndroid.DoFullScreen(AWindow: BSWindow);
begin
  inherited{%H-};
end;

procedure BSApplicationAndroid.DoInvalidate(AWindow: BSWindow);
begin
  inherited{%H-};

end;

procedure BSApplicationAndroid.DoResize(AWindow: BSWindow; AWidth, AHeight: int32);
begin
  inherited{%H-};
  UpdateClientRect(AWindow);
end;

procedure BSApplicationAndroid.DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32);
begin
  inherited{%H-};
  UpdateClientRect(AWindow);
end;

procedure BSApplicationAndroid.DoShow(AWindow: BSWindow; AInModalMode: boolean);
begin
  inherited;

end;

function BSApplicationAndroid.GetMousePointPos: TVec2i;
begin
  Result := vec2(0, 0);
end;

function BSApplicationAndroid.GetShiftState(JShiftState: JInt): TBSShiftState;
const
  SHIFT_STATE_SHIFT      = 1;
  SHIFT_STATE_CTRL       = 2;
  SHIFT_STATE_ALT        = 4;
  //SHIFT_STATE_META       = 8; // ???
  //SHIFT_STATE_CAPS       = 16;
  //SHIFT_STATE_NUM        = 32;
  //SHIFT_STATE_LONG       = 64;
begin
  Result := [];

  if JShiftState or SHIFT_STATE_SHIFT > 0 then
    Result := Result + [ssShift];

  if JShiftState or SHIFT_STATE_CTRL > 0 then
    Result := Result + [ssCtrl];

  if JShiftState or SHIFT_STATE_ALT > 0 then
    Result := Result + [ssAlt];
end;

function BSApplicationAndroid.OnTouch(ActionID: int32; PointerID: int32; X, Y: int32; Pressure: single): int32;
const
  ACTION_DOWN = 0;
  ACTION_UP   = 1;
  ACTION_MOVE = 2;
var
  window: BSWindow;
begin
  FLastOpCode := 0;
  Result := 0;
  window := GetWindow(X, Y);
  if window <> ActiveWindow then
    window.IsActive := true;

  FMousePos := vec2(X, Y);

  if (ActionID = ACTION_DOWN) Then
  begin
    ActiveWindow.MouseDown(TBSMouseButton.mbBsLeft, X, Y, [ssLeft]);
    FTimeMouseDown := TBTimer.CurrentTime.Counter;
  end else
  if (ActionID = ACTION_UP) Then
  begin
    if Assigned(ActiveWindow.Parent) and ActiveWindow.Parent.MouseIsDown then
    begin
      ActiveWindow.Parent.MouseUp(TBSMouseButton.mbBsLeft, X, Y, [ssLeft]);
      ActiveWindow.Parent.MouseClick(TBSMouseButton.mbBsLeft, X, Y, [ssLeft]);
      if TBTimer.CurrentTime.Low - LastTimeMouseUp < MOUSE_DOUBLE_CLICK_DELTA then
        ActiveWindow.Parent.MouseDblClick(X, Y);
      ActiveWindow.Parent.MouseLeave;
    end else
    begin
      ActiveWindow.MouseUp(TBSMouseButton.mbBsLeft, X, Y, [ssLeft]);
      ActiveWindow.MouseClick(TBSMouseButton.mbBsLeft, X, Y, [ssLeft]);
      if TBTimer.CurrentTime.Low - LastTimeMouseUp < MOUSE_DOUBLE_CLICK_DELTA then
        ActiveWindow.MouseDblClick(X, Y);
    end;
    LastTimeMouseUp := TBTimer.CurrentTime.Low;
  end else
  if (ActionID = ACTION_MOVE) Then
  begin
    {$ifdef DEBUG_BS}
    //BSWriteMsg('ActiveWindow.MouseMove', 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y));
    {$endif}
    if ActiveWindow.MouseIsDown then
      ActiveWindow.MouseMove(X, Y, [ssLeft]) //
    else
      ActiveWindow.MouseMove(X, Y, []); // userless?
  end;

  Result := BuildCommonResult;

end;

function BSApplicationAndroid.ProcsessOnKey(IsDown: boolean; keyChar: JChar; keyCode: JInt; shiftState: JInt): int32;
var
  code: word;
  ch: WideChar;
  ss: TBSShiftState;
begin
  FLastOpCode := 0;
  Result := 0;

  ss := GetShiftState(shiftState);

  case keyCode of
    67: code := VK_BS_Back;
    else
      code := word(keyCode);
  end;

  {$ifdef DEBUG_BS}
  //BSWriteMsg('BSApplicationAndroid.ProcsessOnKey', 'BSApplicationAndroid.ProcsessOnKey');
  {$endif}

  if IsDown then
  begin
    ch := WideChar(keyChar);

    ActiveWindow.KeyDown(code, ss);
    //for i := 1 to length(s) do
    if keyChar > 0 then
    begin
      ActiveWindow.KeyPress(ch, ss);
    end;

  end else
  begin
    ActiveWindow.KeyUp(code, ss);
  end;

  Result := BuildCommonResult;
end;

procedure BSApplicationAndroid.UpdateClientRect(AWindow: BSWindow);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationAndroid.UpdateClientRect', 'begin');
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
  BSWriteMsg('BSApplicationAndroid.UpdateClientRect end: ', 'Left: ' + IntToStr(AWindow.ClientRect.Left) + '; Top: ' + IntToStr(AWindow.ClientRect.Top) +
    '; Width: ' + IntToStr(AWindow.ClientRect.Width) + '; Height: ' + IntToStr(AWindow.ClientRect.Height));
  {$endif}
end;

function BSApplicationAndroid.BuildCommonResult: int32;
begin
  if FLastOpCode = 0 then
  begin
    if TTaskExecutor.HasTasks then
      Result := OPCODE_ANIMATION_RUN
    else
      Result := OPCODE_ANIMATION_STOP;
  end else
  begin
    if TTaskExecutor.HasTasks then
      FStackNeedActions.Add(OPCODE_ANIMATION_RUN)
    else
      FStackNeedActions.Add(OPCODE_ANIMATION_STOP);

    FStackNeedActions.Add(FLastOpCode);

    Result := OPCODE_LIST_ACTIONS;
  end;
end;

function BSApplicationAndroid.GetWindow(X, Y: int32): BSWindow;
var
  i: int32;
  w: BSWindow;
  modalW: BSWindow;
  showW: BSWindow;
begin
  modalW := nil;
  showW := nil;
  for i := 0 to WindowsList.Count - 1 do
  begin
    w := WindowsList.Items[i];
    if not w.IsVisible then
      continue;
    if not ((X >= w.Left) and (Y >= w.Top) and (X < w.Left + w.Width) and (Y < w.Top + w.Height)) then
      continue;
    if (w.WindowState = TWindowState.wsShown) then
    begin
      if not Assigned(showW) or (showW.Level < w.Level) then
        showW := w;
    end else
    if not Assigned(modalW) or (modalW.Level < w.Level) then
      modalW := w;
  end;

  if Assigned(showW) then
  begin
    if Assigned(modalW) and (modalW.Level > showW.Level) then
      Result := modalW
    else
      Result := showW;
  end else
    Result := modalW;
end;

function BSApplicationAndroid.GetNextAction: int32;
begin
  if FStackNeedActions.Count > 0 then
    Result := FStackNeedActions.Pop
  else
    Result := -1;
end;

procedure BSApplicationAndroid.OnGuiEvent(const AData: BOpCode);
begin
  FLastOpCode := AData.OpCode;
end;

procedure BSApplicationAndroid.InitHandlers;
begin
  inherited{%H-};

end;

procedure BSApplicationAndroid.InitMonitors;
begin
  inherited{%H-};

end;

procedure BSApplicationAndroid.Update;
begin
  inherited{%H-};
  Application.MainWindow.Draw;
end;

procedure BSApplicationAndroid.UpdateWait;
begin
  inherited{%H-};
  Application.MainWindow.Draw;
end;

{.$ifdef FPC}

function bsNativeInit(PEnv: PJNIEnv; this: JObject; AAppDir, AFilesDir: jstring): JInt; cdecl;
const
  //SCREEN_ORIENTATION_LANDSCAPE = 0;
  SCREEN_ORIENTATION_PORTRAIT = 1;
var
  s: string;
begin
  s := string(g_CurrentEnv^.GetStringUTFChars(g_CurrentEnv, AFilesDir, nil));
  if AnsiUpperCase(ExtractFileExt(s)) = '.APK' then
    s := ExtractFileDir(s);

  SetApplicationPath(IncludeTrailingPathDelimiter(s));

  BSConfig.Load;
  Result := BSConfig.GetProperty('ScreenOrientation', SCREEN_ORIENTATION_PORTRAIT);
end;

procedure bsNativeOnViewCreated(PEnv: PJNIEnv; this: JObject; nativeHandle: JObject; displayWidthPixels: jfloat; displayHeightPixels: jfloat; dpiX: jfloat; dpiY: jfloat); cdecl;
begin

  g_NativeHandleView := ANativeWindow_fromSurface(g_CurrentEnv, nativeHandle);

  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeOnViewCreated', ' nativeHandle: ' + IntToHex({%H-}NativeInt(nativeHandle)) + '; NativeWindowHandle: ' + IntToHex({%H-}NativeInt(g_NativeHandleView)));
  {$endif}

  if not Assigned(Application) then
    ApplicationRun;

  Application.ApplicationSystem.DisplayWidth := round(displayWidthPixels);
  Application.ApplicationSystem.DisplayHeight := round(displayHeightPixels);
  Application.ApplicationSystem.PixelsPerInchX := round(dpiX);
  Application.ApplicationSystem.PixelsPerInchY := round(dpiY);

  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeInit', ' DisplayWidth: ' + IntToStr(round(displayWidthPixels)) + '; DisplayHeight: ' + IntToStr(round(displayHeightPixels)) + '; DpiX: '
    + IntToStr(round(dpiX)) + '; DpiY: ' + IntToStr(round(DpiY)));
  {$endif}

end;

procedure bsNativeOnViewChanged(PEnv: PJNIEnv; this: JObject; Width, Height: JInt); cdecl;
begin
  if not Assigned(g_NativeHandleView) or not Assigned(Application) then
    exit;
  Application.MainWindow.Resize(Width, Height);
  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeOnViewChanged', 'New size: width = ' + IntToStr(Width) + '; height = ' + IntToStr(Height));
  {$endif}
  Application.MainWindow.Show;
end;

procedure bsNativeOnViewDestroy(PEnv: PJNIEnv; this: JObject); cdecl;
begin
  if not Assigned(Application) then
    exit;
  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeOnViewDestroy', '');
  {$endif}
  Application.MainWindow.Close;
end;

function bsNativeOnBackPressed(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
begin
  Result := -1;
end;

function bsNativeOnRotate(PEnv: PJNIEnv; this: JObject; rotate: JInt): JInt; cdecl;
begin
  Result := 0;
end;

procedure bsNativeOnConfigurationChanged(PEnv: PJNIEnv; this: JObject); cdecl;
begin
end;

procedure bsNativeOnActivityResult(PEnv: PJNIEnv; this: JObject; requestCode: JInt; resultCode: JInt; data: JObject); cdecl;
begin
end;

procedure bsNativeOnDraw(PEnv: PJNIEnv; this: JObject); cdecl;
begin
  Application.ProcessMessages;
end;

procedure bsNativeOnChangeFocus(PEnv: PJNIEnv; this: JObject; nativeHandle: JObject; IsFocused: JBoolean); cdecl;
var
  old: JObject;
begin
  if IsFocused <> 0 then
  begin
    {$ifdef DEBUG_BS}
    old := g_NativeHandleView;
    BSWriteMsg('bsNativeOnChangeFocus', '');
    {$endif}
    g_NativeHandleView := ANativeWindow_fromSurface(g_CurrentEnv, nativeHandle);
    {$ifdef DEBUG_BS}
    if old <> g_NativeHandleView then
      BSWriteMsg('bsNativeOnChangeFocus', 'Native handle has been changed');
    {$endif}
    ApplicationAndroid.ActiveWindow.BegingFromOSChange;
    try
      ApplicationAndroid.ActiveWindow.IsActive := true;
    finally
      ApplicationAndroid.ActiveWindow.EndFromOSChange;
    end;
  end;
end;

function bsNativeOnTouch(PEnv: PJNIEnv; this: jobject; ActionID: int32; PointerID: jint; X, Y, Pressure: jfloat): JInt; cdecl;
begin
  Result := ApplicationAndroid.OnTouch(ActionID, PointerID, round(X), round(Y), Pressure);
end;

function bsNativeNextAction(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
begin
  Result := ApplicationAndroid.GetNextAction;
end;

function bsNativeGetIntAttribute(PEnv: PJNIEnv; this: jobject; AName: jstring; ADefault: JInt): JInt; cdecl;
var
  s: string;
begin
  s := string(g_CurrentEnv^.GetStringUTFChars(g_CurrentEnv, AName, nil));
  Result := BSConfig.GetProperty(s, ADefault); //SCREEN_ORIENTATION_PORTRAIT
  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeGetIntAttribute', s + ' = ' + IntToStr(Result));
  {$endif}
end;

function bsNativeGetBoolAttribute(PEnv: PJNIEnv; this: jobject; AName: jstring; ADefault: jboolean): jboolean; cdecl;
var
  s: string;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeGetIntAttribute', 'ADefault = ' + IntToStr(ADefault));
  {$endif}
  s := string(g_CurrentEnv^.GetStringUTFChars(g_CurrentEnv, AName, nil));
  if BSConfig.GetProperty(s, ADefault > 0) then
    Result := 1
  else
    Result := 0;
  {$ifdef DEBUG_BS}
  BSWriteMsg('bsNativeGetBoolAttribute', s + ' = ' + BoolToStr(Result > 0, true));
  {$endif}
end;

function bsNativeOnKeyDown(PEnv: PJNIEnv; this: JObject; keyChar: JChar; keyCode: JInt; shiftState: JInt): JInt; cdecl;
begin
  Result := ApplicationAndroid.ProcsessOnKey(true, keyChar, keyCode, shiftState);
end;

function bsNativeOnKeyUp(PEnv: PJNIEnv; this: JObject; keyChar: JChar; keyCode: JInt; shiftState: JInt): JInt; cdecl;
begin
  Result := ApplicationAndroid.ProcsessOnKey(false, keyChar, keyCode, shiftState);
end;

procedure bsNativeOnDown(PEnv: PJNIEnv; this: JObject); cdecl;
begin
end;

procedure bsNativeOnUp(PEnv: PJNIEnv; this: JObject); cdecl;
begin
end;

procedure bsNativeOnClick(PEnv: PJNIEnv; this: JObject; value: JInt); cdecl;
begin
end;

procedure bsNativeOnLongClick(PEnv: PJNIEnv; this: JObject); cdecl;
begin
end;

procedure bsNativeOnDoubleClick(PEnv: PJNIEnv; this: JObject); cdecl;
begin
  Application.MainWindow.MouseDblClick(Application.ApplicationSystem.MousePointPos.x, Application.ApplicationSystem.MousePointPos.y);
end;

procedure bsNativeOnChanged(PEnv: PJNIEnv; this: JObject; txt: JString; count: JInt); cdecl;
begin
end;

procedure bsNativeOnEnter(PEnv: PJNIEnv; this: JObject); cdecl;
begin
end;

procedure bsNativeOnClose(PEnv: PJNIEnv; this: JObject); cdecl;
begin
  Application.MainWindow.Close;
end;

procedure bsNativeOnViewClick(PEnv: PJNIEnv; this: JObject; view: JObject; id: JInt); cdecl;
begin
end;

procedure bsNativeOnFlingGestureDetected(PEnv: PJNIEnv; this: JObject; direction: JInt); cdecl;
begin
end;

procedure bsNativeOnPinchZoomGestureDetected(PEnv: PJNIEnv; this: JObject; scaleFactor: JFloat; state: JInt); cdecl;
begin
end;

function JNI_OnLoad(VM: PJavaVM; {%H-}reserved: pointer): JInt; cdecl;
var
  env: PPointer;
begin
  env:= nil;
  Result:= JNI_VERSION_1_6;

  VM^.GetEnv(VM, @env, Result);
  if Assigned(env) then
     g_CurrentEnv := PJNIEnv(env);

  g_JavaVM := VM;

  {$ifdef DEBUG_BS}
  BSWriteMsg('JNI_OnLoad', '');
  {$endif}
end;

procedure JNI_OnUnload(VM: PJavaVM; {%H-}reserved: pointer); cdecl;
var
  PEnv: PPointer;
  curEnv: PJNIEnv;
  gjClass: jClass;
begin
  Application.MainWindow.Close;
  FreeAndNil(Application);
  PEnv:= nil;
  VM^.GetEnv(VM, @PEnv, JNI_VERSION_1_6);
  if Assigned(PEnv) then
  begin
    curEnv:= PJNIEnv(PEnv);
    gjClass:= jClass(curEnv^.FindClass(curEnv, ANDROID_CLASS_NAME));
    //if gjClass <> nil then gjClass := env^.NewGlobalRef(env, gjClass); //needed for Appi > 13
    (curEnv^).DeleteGlobalRef(curEnv, gjClass);
  end;
  g_JavaVM := nil;
end;

{%endregion}


{.$endif}

{ TWindowContextAndroid }

function TWindowContextAndroid.GetDC: EGLNativeDisplayType;
begin
  Result := TSharedEglContext.SharedDisplay;
end;

function TWindowContextAndroid.GetHandle: EGLNativeWindowType;
begin
  Result := g_NativeHandleView;
end;

initialization
  {$ifndef FPC}
  //RegisterCorePlatformServices;
  bs.gl.es.InitGLES(bs.gl.egl.GetPathGL);
  {$endif}

finalization
  {$ifndef FPC}
  //UnregisterCorePlatformServices;
  {$endif}

end.
