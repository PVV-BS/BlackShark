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
    procedure UpdateClientRect(AWindow: BSWindow);
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
    procedure ChangeDisplayResolution(NewWidth, NewHeight: int32); // overload;
  public
    constructor Create;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; override;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; override;
    destructor Destroy; override;
    procedure Update; override;
    procedure UpdateWait; override;

    function ProcsessOnKey(IsDown: boolean; keyChar: JChar; keyCode: JInt; shiftState: JInt): int32;
    function Draw: int32;
  end;

{ exported interface of the engine }
function JNI_OnLoad(VM: PJavaVM; {%H-}reserved: pointer): JInt; cdecl;
procedure JNI_OnUnload(VM: PJavaVM; {%H-}reserved: pointer); cdecl;
function bsNativeInit({%H-}PEnv: PJNIEnv; this: JObject; AAppDir, AFilesDir: jstring): JInt; cdecl;
procedure bsNativeOnViewCreated(PEnv: PJNIEnv; this: JObject; nativeHandle: JObject; displayWidthPixels: jfloat; displayHeightPixels: jfloat; dpiX: jfloat; dpiY: jfloat); cdecl;
procedure bsNativeOnViewChanged(PEnv: PJNIEnv; this: JObject; Width, Height: JInt); cdecl;
function bsNativeOnDraw(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
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
  , bs.gl.context
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
  inherited;
end;

procedure BSApplicationAndroid.DoActive(AWindow: BSWindow);
begin
  inherited;
  ApplicationRun;
end;

procedure BSApplicationAndroid.DoShowCursor(AWindow: BSWindow);
begin

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

function BSApplicationAndroid.ProcsessOnKey(IsDown: boolean; keyChar: JChar; keyCode: JInt; shiftState: JInt): int32;
var
  code: word;
  ch: WideChar;
  ss: TBSShiftState;
begin
  LastOpCode := 0;
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

function BSApplicationAndroid.Draw: int32;
begin
  Application.ProcessMessages;
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

function bsNativeOnDraw(PEnv: PJNIEnv; this: JObject): JInt; cdecl;
begin
  Result := ApplicationAndroid.Draw;
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
