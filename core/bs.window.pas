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
unit bs.window;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , types
  , bs.collections
  , bs.basetypes
  , bs.gui.base
  , bs.events
  , bs.obj
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.egl
  {$endif}
  , bs.gl.context
  , bs.renderer
  , bs.canvas
  ;

const
  CLASS_NAME: PWideChar = 'BlackShark Class';
  WINDOW_CAPTION: WideString = 'Black Shark Graphics Engine';
  MOUSE_DOUBLE_CLICK_DELTA = 300;

type
  BSWindow = class;
  TMonitor = class;

  TBlackSharkApplication = class;

  BSWindowClass = class of BSWindow;
  TWindowsTable = THashTable<EGLNativeWindowType, BSWindow>;
  TWindowsList  = TListVec<BSWindow>;
  TMonitorsList = TListVec<TMonitor>;

  { TMonitor }

  TMonitor = class
  private
  public
  end;

  { BSApplicationSystem }

  BSApplicationSystem = class abstract
  private
    FOnRemoveWindowEvent: IBEmptyEvent;
    FCanvasCursor: TBCanvas;
    FCustomCursor: TCanvasObject;
    FLastTimeMouseUp: uint32;
    FTimeMouseDown: uint64;
    FIsDblClick: boolean;
    FLastOpCode: int32;
    GuiEvetnsObserver: IBOpCodeEventObserver;
    FStackNeedActions: TListVec<int32>;
    procedure SetPixelsPerInchX(AValue: int32);
    procedure SetPixelsPerInchY(AValue: int32);
    procedure OnGuiEvent(const AData: BOpCode);

  protected
    const
      ACTION_DOWN  = 0;
      ACTION_UP    = 1;
      ACTION_MOVE  = 2;
      ACTION_WHEEL = 3;

      SHIFT_STATE_SHIFT      = 1;
      SHIFT_STATE_CTRL       = 2;
      SHIFT_STATE_ALT        = 4;
      //SHIFT_STATE_META     = 8; // ???
      //SHIFT_STATE_CAPS     = 16;
      //SHIFT_STATE_NUM      = 32;
      //SHIFT_STATE_LONG     = 64;
      SHIFT_STATE_MIDDLE     = 128;

      //OPCODE_SHOW_KEYBOARD   = 6;
      //OPCODE_HIDE_KEYBOARD   = 7;
      //OPCODE_EXIT            = 8;
      OPCODE_ANIMATION_RUN   = 9;
      OPCODE_ANIMATION_STOP  = 10;
      OPCODE_LIST_ACTIONS    = 11;

      {Ultibo Mouse Data Definitions (Values for TMouseData.Buttons)}
      MOUSE_LEFT_BUTTON    =  $0001; {The Left mouse button is pressed}
      MOUSE_RIGHT_BUTTON   =  $0002; {The Right mouse button is pressed}
      MOUSE_MIDDLE_BUTTON  =  $0004; {The Middle mouse button is pressed}
      MOUSE_SIDE_BUTTON    =  $0008; {The Side mouse button is pressed}
      MOUSE_EXTRA_BUTTON   =  $0010; {The Extra mouse button is pressed}
      MOUSE_TOUCH_BUTTON   =  $0020; {The Touch screen is being touched}
      MOUSE_ABSOLUTE_X     =  $0040; {The OffsetX value is absolute not relative}
      MOUSE_ABSOLUTE_Y     =  $0080; {The OffsetY value is absolute not relative}
      MOUSE_ABSOLUTE_WHEEL =  $0100; {The OffsetWheel value is absolute not relative}
  protected
    FDisplayWidth: int32;
    FDisplayHeight: int32;
    FPixelsPerInchX: int32;
    FPixelsPerInchY: int32;
    FWindows: TWindowsTable;
    FWindowsList: TWindowsList;
    FMainWindow: BSWindow;
    FActiveWindow: BSWindow;
    FMousePos: TVec2i;
    FMonitors: TMonitorsList;
    procedure InitHandlers; virtual; abstract;
    procedure InitMonitors; virtual; abstract;
    procedure AddWindow(AWindow: BSWindow); virtual;
    procedure RemoveWindow(AWindow: BSWindow); virtual;
    function GetWindow(AHandle: EGLNativeWindowType): BSWindow; overload;
    function GetWindow(X, Y: int32): BSWindow; overload;
    function GetShiftState(AShiftState: Int32): TBSShiftState;

    procedure DoShow(AWindow: BSWindow; AInModalMode: boolean); virtual;
    procedure DoClose(AWindow: BSWindow); virtual;
    procedure DoInvalidate(AWindow: BSWindow); virtual; abstract;
    procedure DoResize(AWindow: BSWindow; AWidth, AHeight: int32); virtual; abstract;
    procedure DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32); virtual; abstract;
    procedure DoFullScreen(AWindow: BSWindow); virtual; abstract;
    procedure DoActive(AWindow: BSWindow); virtual;
    procedure DoShowCursor(AWindow: BSWindow); virtual;

    function GetMousePointPos: TVec2i; virtual; abstract;
    { exchange an active window }
    procedure UpdateActiveWindow(AWindow: BSWindow); virtual;
    procedure OnGLContextLost; virtual;
    function BuildCommonResult: int32; inline;
    function GetNextAction: int32;

    property LastTimeMouseUp: uint32 read FLastTimeMouseUp write FLastTimeMouseUp;
    property TimeMouseDown: uint64 read FTimeMouseDown write FTimeMouseDown;
    property IsDblClick: boolean read FIsDblClick write FIsDblClick;
    property LastOpCode: int32 read FLastOpCode write FLastOpCode;
    property StackNeedActions: TListVec<int32> read FStackNeedActions;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    function CreateWindow(AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; virtual; abstract;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; virtual; abstract;
    procedure Update; virtual; abstract;
    procedure UpdateWait; virtual; abstract;

    function OnTouch(ActionID: int32; PointerID: int32; X, Y: int32; Pressure: single): int32;

    property Monitors: TMonitorsList read FMonitors;
    property MousePointPos: TVec2i read GetMousePointPos;
    property Windows: TWindowsTable read FWindows;
    property WindowsList: TWindowsList read FWindowsList;
    property DisplayWidth: int32 read FDisplayWidth write FDisplayWidth;
    property DisplayHeight: int32 read FDisplayHeight write FDisplayHeight;
    property PixelsPerInchX: int32 read FPixelsPerInchX write SetPixelsPerInchX;
    property PixelsPerInchY: int32 read FPixelsPerInchY write SetPixelsPerInchY;
    property OnRemoveWindowEvent: IBEmptyEvent read FOnRemoveWindowEvent;
    property ActiveWindow: BSWindow read FActiveWindow;
    property CustomCursor: TCanvasObject read FCustomCursor write FCustomCursor;
  end;

  { TBlackSharkApplication }

  TBlackSharkApplication = class
  private
    FMainWindow: BSWindow;
    ObserverOnCreateContext: IBEmptyEventObserver;
    ObserverOnRemoveWindow: IBEmptyEventObserver;
    FLastUpdate: uint32;
    FApplicationSystem: BSApplicationSystem;
    FEventOnUpdateActiveWindow: IBEmptyEvent;
    function GetContextCreated: boolean;
    procedure OnCreateContextNotify(const AData: BEmpty);
    procedure OnRemoveContextNotify(const AData: BEmpty);
  protected
    { Important: initialize graphics objects only here or after it event }
    procedure OnCreateGlContext(AWindow: BSWindow); virtual;
    procedure OnGLContextLost; virtual;
    procedure OnRemoveWindow(AWindow: BSWindow); virtual;
    procedure DoUpdateFps; virtual;
    procedure OnUpdateActiveWindow(AWindow: BSWindow); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    { main loop; terminated when MainWindow will be closed }
    procedure Run;
    procedure ProcessMessages;
    function CreateWindow(AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow; overload;
    function CreateWindow(AWindowClass: BSWindowClass; AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow; overload;

    property ApplicationSystem: BSApplicationSystem read FApplicationSystem;
    property MainWindow: BSWindow read FMainWindow;
    property ContextCreated: boolean read GetContextCreated;
    property EventOnUpdateActiveWindow: IBEmptyEvent read FEventOnUpdateActiveWindow;
  end;

  TWindowContext = class
  private
    FWindow: BSWindow;
  protected
    FHandle: EGLNativeWindowType;
    FDC: EGLNativeDisplayType;
    function GetDC: EGLNativeDisplayType; virtual;
    function GetHandle: EGLNativeWindowType; virtual;
    procedure SetDC(const AValue: EGLNativeDisplayType); virtual;
    procedure SetHandle(const AValue: EGLNativeWindowType); virtual;
  public
    property Window: BSWindow read FWindow;
    property DC: EGLNativeDisplayType read GetDC write SetDC;
    property Handle: EGLNativeWindowType read GetHandle write SetHandle;
  end;

  BWindowEventData = record
    Sender: BSWindow;
  end;

  IWindowEvent = interface(IBEvent<BWindowEventData>)
  ['{1A455E0D-2C52-4268-B778-08F520C877D9}']
    procedure Send(ASender: BSWindow);
  end;
  IWindowEventObserver = IBObserver<BWindowEventData>;

  TWindowState = (wsInit, wsShown, wsShownModal, wsClosed, wsMinimazed);

  { BSWindow }

  BSWindow = class
  private
    FCaption: string;
    FGlContext: TBlackSharkContext;
    FLevel: int32;
    FMouseIsDown: boolean;
    ObserverCreateContext: IBEmptyEventObserver;
    FOnCreateContextEvent: IBEmptyEvent;
    FWindowContext: TWindowContext;
    FParent: BSWindow;
    FChildren: TWindowsList;
    FRenderer: TBlackSharkRenderer;
    FOwner: TObject;
    FShowCursor: boolean;
    FFullScreen: boolean;
    FMouseEntered: boolean;
    FIsVisible: boolean;
    FDefaultHandle: EGLNativeWindowType;
    FDefaultDC: EGLNativeDisplayType;

    FOnShow: IWindowEvent;
    FOnResize: IWindowEvent;
    FOnChangePosition: IWindowEvent;
    FOnClose: IWindowEvent;
    FOnDestroy: IWindowEvent;
    FIsEnabled: boolean;
    FClientRect: TRect;
    FRectBeforeFullScreen: TRect;
    FClientRectBeforeFullScreen: TRect;

    procedure CheckSizeRendererWindow;
    procedure AddChild(AChild: BSWindow);
    procedure RemoveChild(AChild: BSWindow);
    function GetFullScreen: boolean;
    procedure OnCreateGlContextEvent(const {%H-}Value: BEmpty);
    procedure SetCaption(const AValue: string);
    procedure SetClientRect(const AValue: TRect);
    function GetOnChangePosition: IWindowEvent;
    function GetOnClose: IWindowEvent;
    function GetOnResize: IWindowEvent;
    function GetOnShow: IWindowEvent;
    function GetOnDestroy: IWindowEvent;
    function DoShow(InModal: boolean): int32;
    procedure SetIsActive(const Value: boolean);
    procedure FreeContext;
  protected
    FFromOSEventChanged: boolean;
    FLeft: int32;
    FTop: int32;
    FWidth: int32;
    FHeight: int32;
    FWindowState: TWindowState;
    FIsActive: boolean;
    function GetDC: EGLNativeDisplayType; virtual;
    function GetHandle: EGLNativeWindowType; virtual;
    procedure SetDC(const AValue: EGLNativeDisplayType); virtual;
    procedure SetHandle(const AValue: EGLNativeWindowType); virtual;
    procedure SetShowCursor(const AValue: boolean); virtual;
    procedure SetIsEnabled(const Value: boolean); virtual;
    procedure DoRender; inline;
    procedure Render; inline;
    procedure SetFullScreen(const AValue: boolean); virtual;
    { Important: initialize graphics objects only here or after it event }
    procedure OnCreateGlContext; virtual;
    procedure OnGLContextLost; virtual;
    function CheckContextIsCreated: boolean;
    property RectBeforeFullScreen: TRect read FRectBeforeFullScreen write FRectBeforeFullScreen;
  public
    constructor Create(AWindowContext: TWindowContext; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32); virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure BegingFromOSChange;
    procedure EndFromOSChange;

    procedure Resize(AWidth, AHeight: int32); virtual;
    procedure SetPosition(ALeft, ATop: int32); virtual;

    procedure MouseClick(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState); virtual;
    procedure MouseDblClick(X, Y: int32); virtual;
    procedure MouseDown(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState); virtual;
    procedure MouseUp(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState); virtual;
    procedure MouseMove(X, Y: int32; Shift: TBSShiftState); virtual;
    procedure MouseEnter(X, Y: int32); virtual;
    procedure MouseLeave; virtual;
    procedure MouseWheel(WheelDelta: int32; X, Y: int32; Shift: TBSShiftState); virtual;

    procedure KeyPress(var Key: WideChar; Shift: TBSShiftState); virtual;
    procedure KeyDown(var Key: Word; Shift: TBSShiftState); virtual;
    procedure KeyUp(var Key: Word; Shift: TBSShiftState); virtual;

    procedure Show; virtual;
    function ShowModal: int32; virtual;
    procedure Draw; virtual;
    procedure Close; virtual;
    function GetShiftStateFromKeyStates: TBSShiftState;

    property WindowContext: TWindowContext read FWindowContext;
    property IsActive: boolean read FIsActive write SetIsActive;
    property ShowCursor: boolean read FShowCursor write SetShowCursor;
    { it property is not used; use on your discretion }
    property Caption: string read FCaption write SetCaption;
    property Width: int32 read FWidth;
    property Height: int32 read FHeight;
    property Left: int32 read FLeft;
    property Top: int32 read FTop;
    property Level: int32 read FLevel;
    property DC: EGLNativeDisplayType read GetDC write SetDC;
    property Handle: EGLNativeWindowType read GetHandle write SetHandle;
    property Parent: BSWindow read FParent;
    property Children: TWindowsList read FChildren;
    property WindowState: TWindowState read FWindowState write FWindowState;
    property OnCreateContextEvent: IBEmptyEvent read FOnCreateContextEvent;
    property Owner: TObject read FOwner write FOwner;
    property Renderer: TBlackSharkRenderer read FRenderer;
    property ClientRect: TRect read FClientRect write SetClientRect;
    property FromOSEventChanged: boolean read FFromOSEventChanged;
    property MouseEntered: boolean read FMouseEntered;
    property MouseIsDown: boolean read FMouseIsDown;
    property IsVisible: boolean read FIsVisible;
    property IsEnabled: boolean read FIsEnabled write SetIsEnabled;
    property FullScreen: boolean read GetFullScreen write SetFullScreen;

    // events
    property OnShow: IWindowEvent read GetOnShow;
    property OnClose: IWindowEvent read GetOnClose;
    property OnResize: IWindowEvent read GetOnResize;
    property OnChangePosition: IWindowEvent read GetOnChangePosition;
    property OnDestroy: IWindowEvent read GetOnDestroy;
  end;

var
  ApplicationRun: procedure;

  Application: TBlackSharkApplication;

implementation

uses
    SysUtils
  , bs.config
  , bs.constants
  , bs.events.keyboard
  , bs.thread
  , bs.math
  , bs.graphics
{$ifdef DEBUG_BS}
  , bs.log
{$endif}
{$ifdef X}
  , bs.window.linux
{$endif}
{$ifdef MSWindows}
  , bs.window.windows
{$endif}
{$ifdef ANDROID}
  , bs.window.android
{$endif}
{$ifdef ultibo}
  , bs.window.ultibo
{$endif}

  ;

type
  TWindowEvent = class(TTemplateBEvent<BWindowEventData>, IWindowEvent)
  private
    type
      TWindowItemQ = TItemQueue<BWindowEventData>;
      TWindowDataQ = TQueueTemplate<TWindowItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(ASender: BSWindow);
  end;

procedure ApplicationRunDefault;
{$ifndef ANDROID}
var
  app: TBlackSharkApplication;
{$endif}
begin
  if not Assigned(Application) then
  begin
    {$ifndef ANDROID}app := {$endif}TBlackSharkApplication.Create;
    {$ifndef ANDROID}
    app.Run;
    app.Free;
    {$endif}
  end;
end;

{ TWindowEvent }

class function TWindowEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TWindowDataQ;
end;

procedure TWindowEvent.Send(ASender: BSWindow);
var
  data: BWindowEventData;
begin
  data.Sender := ASender;
  SendEvent(data);
end;

function CreateWindowEvent: IWindowEvent;
begin
  Result := TWindowEvent.Create(false);
end;

function GetHashHandleWindow(const AHandle: EGLNativeWindowType): uint32;
begin
  Result := GetHashBlackShark(@AHandle, sizeof(AHandle));
end;

function HandleWindowCmpEqual(const Key1, Key2: EGLNativeWindowType): boolean;
begin
  Result := Key1 = Key2;
end;

{ TBlackSharkApplication }

constructor TBlackSharkApplication.Create;
begin
  Assert(Application = nil, 'Application was already created!');
  Application := Self;

  FEventOnUpdateActiveWindow := CreateEmptyEvent;
{$ifdef X}
  FApplicationSystem := BSApplicationLinux.Create;
{$endif}
{$ifdef MSWindows}
  FApplicationSystem := BSApplicationWindows.Create;
{$endif}
{$ifdef ANDROID}
  FApplicationSystem := BSApplicationAndroid.Create;
{$endif}

{$ifdef ultibo}
  FApplicationSystem := BSApplicationUltibo.Create;
{$endif}

{$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.Create', '');
{$endif}

  FMainWindow := CreateWindow(nil, Self, 0, 0, 600, 600);
  ObserverOnCreateContext := FMainWindow.OnCreateContextEvent.CreateObserver(OnCreateContextNotify);
  ObserverOnRemoveWindow := FApplicationSystem.OnRemoveWindowEvent.CreateObserver(OnRemoveContextNotify);
  FLastUpdate := TBTimer.CurrentTime.Low;
end;

function TBlackSharkApplication.CreateWindow(AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow;
begin
  Result := CreateWindow(BSWindow, AParent, AOwner, ALeft, ATop, AWidth, AHeight);
end;

function TBlackSharkApplication.CreateWindow(AWindowClass: BSWindowClass; AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow;
var
  parent: BSWindow;
begin
  if Assigned(AParent) then
    parent := AParent
  else
    parent := FMainWindow;
  Result := FApplicationSystem.CreateWindow(AWindowClass, AOwner, parent, ALeft, ATop, AWidth, AHeight);
end;

destructor TBlackSharkApplication.Destroy;
begin
  FreeAndNil(FMainWindow);
  ObserverOnCreateContext := nil;
  ObserverOnRemoveWindow := nil;
  FreeAndNil(FApplicationSystem);
  inherited;
end;

procedure TBlackSharkApplication.DoUpdateFps;
begin

end;

procedure TBlackSharkApplication.OnCreateContextNotify(const AData: BEmpty);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.OnCreateContextNotify');
  {$endif}
  { vertical synchronization }
  if BSConfig.VerticalSynchronization or not BSConfig.MaxFps then
    eglSwapInterval(TSharedEglContext.SharedDisplay, 1)
  else
    eglSwapInterval(TSharedEglContext.SharedDisplay, 0);
  OnCreateGlContext(BSWindow(AData.Instance));
end;

function TBlackSharkApplication.GetContextCreated: boolean;
begin
  Result := Assigned(Application.MainWindow) and Application.MainWindow.CheckContextIsCreated;
end;

procedure TBlackSharkApplication.OnCreateGlContext(AWindow: BSWindow);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.OnCreateGlContext');
  {$endif}
end;

procedure TBlackSharkApplication.OnGLContextLost;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.OnGLContextLost');
  {$endif}
end;

procedure TBlackSharkApplication.OnRemoveContextNotify(const AData: BEmpty);
begin
  OnRemoveWindow(BSWindow(AData.Instance));
end;

procedure TBlackSharkApplication.OnRemoveWindow(AWindow: BSWindow);
begin
  if FMainWindow = AWindow then
    FMainWindow := nil;
end;

procedure TBlackSharkApplication.OnUpdateActiveWindow(AWindow: BSWindow);
begin
  FEventOnUpdateActiveWindow.Send(AWindow);
end;

procedure TBlackSharkApplication.ProcessMessages;
var
  t, delta: uint32;
begin
  t := TBTimer.CurrentTime.Low;
  if (BSConfig.MaxFps or (TTaskExecutor.CountTasks > 0)) or (t - TTaskExecutor.LastTimeRemoveTask < TIMEOUT_MAX_FPS) then
    FApplicationSystem.Update
  else
    FApplicationSystem.UpdateWait;

  GUIThread.OnIdleApplication;

  delta := t - FLastUpdate;
  if (delta > 999) then
  begin
    FLastUpdate := t;
    DoUpdateFps;
  end;
end;

procedure TBlackSharkApplication.Run;
begin
  FMainWindow.Show;

  while (FApplicationSystem.Windows.Count > 0) and FMainWindow.IsVisible do
  begin
    ProcessMessages;
  end;
  FreeAndNil(FMainWindow);
end;

{ BSApplicationSystem }

procedure BSApplicationSystem.SetPixelsPerInchX(AValue: int32);
begin
  if FPixelsPerInchX = AValue then
    exit;
  FPixelsPerInchX := AValue;
end;

procedure BSApplicationSystem.SetPixelsPerInchY(AValue: int32);
begin
  if FPixelsPerInchY = AValue then Exit;
  FPixelsPerInchY := AValue;
  bs.graphics.PixelsPerInch := FPixelsPerInchY;
  bs.graphics.ToHiDpiScale := bs.graphics.PixelsPerInch/96;
end;

procedure BSApplicationSystem.AddWindow(AWindow: BSWindow);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSApplicationSystem.AddWindow', '');
  {$endif}
  FWindowsList.Add(AWindow);
  {$ifdef SingleWinOnly}
  FWindows.Items[AWindow] := AWindow;
  {$else}
  FWindows.Items[AWindow.Handle] := AWindow;
  {$endif}
  if not Assigned(FMainWindow) then
    FMainWindow := AWindow;
end;

procedure BSApplicationSystem.AfterConstruction;
begin
  inherited;
  InitHandlers;
  InitMonitors;
end;

function BSApplicationSystem.BuildCommonResult: int32;
begin
  if FLastOpCode = 0 then
  begin
    if TTaskExecutor.CountTasks > 0 then
      Result := OPCODE_ANIMATION_RUN
    else
      Result := OPCODE_ANIMATION_STOP;
  end else
  begin
    if TTaskExecutor.CountTasks > 0 then
      FStackNeedActions.Add(OPCODE_ANIMATION_RUN)
    else
      FStackNeedActions.Add(OPCODE_ANIMATION_STOP);

    FStackNeedActions.Add(FLastOpCode);

    Result := OPCODE_LIST_ACTIONS;
  end;
end;

function BSApplicationSystem.CreateWindow(AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
begin
  Result := CreateWindow(BSWindow, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);
end;

constructor BSApplicationSystem.Create;
begin
  FWindows := TWindowsTable.Create(@GetHashHandleWindow, @HandleWindowCmpEqual, 32);
  FWindowsList := TWindowsList.Create(@PtrCmp);
  FOnRemoveWindowEvent := CreateEmptyEvent;
  FMonitors := TMonitorsList.Create;
  GuiEvetnsObserver := CreateOpCodeObserver(bs.gui.base.TBControl.ControlEvents, OnGuiEvent);
  FStackNeedActions := TListVec<int32>.Create;
end;

destructor BSApplicationSystem.Destroy;
var
  i: int32;
begin
  FOnRemoveWindowEvent := nil;
  FWindows.Free;
  FWindowsList.Free;
  for i := 0 to FMonitors.Count - 1 do
    FMonitors.Items[i].Free;
  FMonitors.Free;
  FStackNeedActions.Free;
  inherited;
end;

procedure BSApplicationSystem.DoActive(AWindow: BSWindow);
begin
  UpdateActiveWindow(AWindow);
end;

procedure BSApplicationSystem.DoShowCursor(AWindow: BSWindow);
var
  c: TTriangle;
begin
  if AWindow.ShowCursor then
  begin
  	if not Assigned(FCanvasCursor) then
    begin
      FCanvasCursor := TBCanvas.Create(FMainWindow.Renderer, Self);

      c := TTriangle.Create(FCanvasCursor, nil);
      c.A := vec2(0.0, 0.0);
      c.B := vec2(round( 5.0*ToHiDpiScale), round(10.0*ToHiDpiScale));
      c.C := vec2(round(10.0*ToHiDpiScale), round( 5.0*ToHiDpiScale));
      c.Color := BS_CL_RED;
      c.Fill := true;
      c.Layer2d := trunc(FMainWindow.Renderer.Frustum.MAX_COUNT_LAYERS)-5;
      c.Data.ModalLevel := 1000000;
      c.Build;

      FCustomCursor := c;
      c.Position2d := FMousePos;
    end;
  end else
  begin
    FreeAndNil(FCustomCursor);
    FreeAndNil(FCanvasCursor);
  end;
end;

procedure BSApplicationSystem.DoClose(AWindow: BSWindow);
begin

end;

procedure BSApplicationSystem.DoShow(AWindow: BSWindow; AInModalMode: boolean);
begin
  UpdateActiveWindow(AWindow);
end;

procedure BSApplicationSystem.RemoveWindow(AWindow: BSWindow);
var
  i: int32;
begin
  if FActiveWindow = AWindow then
    FActiveWindow := nil;

  {$ifdef SingleWinOnly}
  FWindows.Delete(AWindow);
  {$else}
  FWindows.Delete(AWindow.Handle);
  {$endif}
  FWindowsList.Remove(AWindow);
  if FMainWindow = AWindow then
  begin
    FMainWindow := nil;
    for i := FWindowsList.Count - 1 downto 0 do
      FWindowsList.Items[i].Free;
  end;
  FOnRemoveWindowEvent.Send(AWindow);
end;

procedure BSApplicationSystem.UpdateActiveWindow(AWindow: BSWindow);
begin
  if Assigned(FActiveWindow) and (FActiveWindow <> AWindow) and (AWindow.IsActive) then
    FActiveWindow.IsActive := false;
  if (AWindow.IsActive) then
    FActiveWindow := AWindow;
  Application.OnUpdateActiveWindow(FActiveWindow);
end;

procedure BSApplicationSystem.OnGLContextLost;
var
  i: int32;
begin
  for i := FWindowsList.Count - 1 downto 0 do
    FWindowsList.Items[i].OnGLContextLost;
  TSharedEglContext.OnContextLost;
  Application.OnGLContextLost;
end;

procedure BSApplicationSystem.OnGuiEvent(const AData: BOpCode);
begin
  FLastOpCode := AData.OpCode;
end;

function BSApplicationSystem.GetNextAction: int32;
begin
  if FStackNeedActions.Count > 0 then
    Result := FStackNeedActions.Pop
  else
    Result := -1;
end;

function BSApplicationSystem.GetShiftState(AShiftState: Int32): TBSShiftState;
begin
  Result := [];

  if AShiftState or SHIFT_STATE_SHIFT > 0 then
    Result := Result + [ssShift];

  if AShiftState or SHIFT_STATE_CTRL > 0 then
    Result := Result + [ssCtrl];

  if AShiftState or SHIFT_STATE_ALT > 0 then
    Result := Result + [ssAlt];
end;

function BSApplicationSystem.OnTouch(ActionID: int32; PointerID: int32; X, Y: int32; Pressure: single): int32;
var
  window: BSWindow;
  ss: TBSShiftState;
  mb: TBSMouseButton;
begin
  FLastOpCode := 0;
  window := GetWindow(X, Y);
  if (window <> ActiveWindow) and (ActionID = ACTION_DOWN) and (ActiveWindow.WindowState <> wsShownModal) and (not ActiveWindow.MouseIsDown) then
    window.IsActive := true;

  FMousePos := vec2(X, Y);
  ss := [];
  mb := mbBsLeft;

  {Check the buttons}

  { for now it covers simplest patterns }
  if (PointerID and MOUSE_LEFT_BUTTON) > 0 then
  begin
    ss := [ssLeft];
    mb := mbBsLeft;
  end;

  if (PointerID and MOUSE_RIGHT_BUTTON) > 0 then
  begin
    ss := ss + [ssRight];
    mb := mbBsRight;
  end;

  if (PointerID and MOUSE_MIDDLE_BUTTON) > 0 then
  begin
    ss := ss + [ssMiddle];
    mb := mbBsMiddle;
  end;

  case ActionID of
    ACTION_DOWN: begin
      if (window = ActiveWindow) then
      begin

        if TBTimer.CurrentTime.Low - LastTimeMouseUp < MOUSE_DOUBLE_CLICK_DELTA then
        begin
          FIsDblClick := true;
          ActiveWindow.MouseDblClick(X, Y);
        end else
          ActiveWindow.MouseDown(mb, X, Y, ss);

        FTimeMouseDown := TBTimer.CurrentTime.Counter;
      end;
    end;

    ACTION_UP: begin
      if Assigned(ActiveWindow.Parent) and ActiveWindow.Parent.MouseIsDown then
      begin
        if FIsDblClick then
          FIsDblClick := false
        else
        begin
          ActiveWindow.Parent.MouseUp(mb, X, Y, ss);
          ActiveWindow.Parent.MouseClick(mb, X, Y, ss);
          ActiveWindow.Parent.MouseLeave;
        end;
      end else
      begin
        if FIsDblClick then
          FIsDblClick := false
        else
        begin
          ActiveWindow.MouseUp(mb, X, Y, ss);
          ActiveWindow.MouseClick(mb, X, Y, ss);
        end;
      end;
      LastTimeMouseUp := TBTimer.CurrentTime.Low;
    end;

    ACTION_MOVE: begin
      if ActiveWindow.MouseIsDown then
        ActiveWindow.MouseMove(X, Y, ss) //
      else
        ActiveWindow.MouseMove(X, Y, []); // userless?
    end;

    ACTION_WHEEL: begin
      ActiveWindow.MouseWheel(round(Pressure), X, Y, ss);
    end;

  end;

  Result := BuildCommonResult;

end;

function BSApplicationSystem.GetWindow(AHandle: EGLNativeWindowType): BSWindow;
begin
  FWindows.Find(AHandle, Result);
end;

function BSApplicationSystem.GetWindow(X, Y: int32): BSWindow;
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

{ BSWindow }

procedure BSWindow.AddChild(AChild: BSWindow);
begin
  FChildren.Add(AChild);
end;

procedure BSWindow.AfterConstruction;
begin
  inherited;
  FOnCreateContextEvent := CreateEmptyEvent;
  {$ifdef SingleWinOnly}
  if Assigned(FParent) and (FParent.Renderer.MouseIsDown) then
    FParent.MouseUp(FParent.Renderer.MouseButtonKeep, FParent.Renderer.MouseLastPos.x, FParent.Renderer.MouseLastPos.y, FParent.Renderer.ShiftState);
  {$endif}
end;

procedure BSWindow.BeforeDestruction;
begin
  inherited;
  while FChildren.Count > 0 do
    FChildren.Items[FChildren.Count - 1].Free;
end;

procedure BSWindow.BegingFromOSChange;
begin
  FFromOSEventChanged := true;
end;

function BSWindow.CheckContextIsCreated: boolean;
{$ifdef SingleWinOnly}
var
  bd: BData;
{$endif}
begin
  if ({%H-}NativeInt(Handle) = 0) or ({%H-}NativeInt(DC) = 0) then
    exit(false);

  if Assigned(FGlContext) and FGlContext.ContextCreated then
    exit(true);

  {$ifdef SingleWinOnly}

  if (Application.MainWindow <> Self) then
  begin
    FGlContext := Application.MainWindow.FGlContext;
  end;

  {$endif}

  if not  Assigned(FGlContext) then
  begin
    FGlContext := TBlackSharkContext.Create(Handle, DC);
    ObserverCreateContext := FGlContext.OnCreateContextEvent.CreateObserver(OnCreateGlContextEvent);
  end;

  if not FGlContext.ContextCreated then
  begin
    FGlContext.CreateContext;
  end;

  CheckSizeRendererWindow;
  Result := FGlContext.ContextCreated;

  if FIsVisible and FIsActive and Result then
    {%H-}DoRender;

  {$ifdef SingleWinOnly}
  if (Application.MainWindow <> Self) and Result then
  begin
    bd.Instance := FGlContext;
    OnCreateGlContextEvent(bd);
  end;
  {$endif}
end;

procedure BSWindow.CheckSizeRendererWindow;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.CheckSizeRendererWindow.' + FCaption, 'begin');
  {$endif}
  if Assigned(FRenderer) and ((FClientRect.Width > 0) and (FClientRect.Height > 0) and ((FRenderer.WindowWidth <> FClientRect.Width) or (FRenderer.WindowHeight <> FClientRect.Height))
     and Assigned(FGlContext) and FGlContext.MakeCurrent) then
  begin
    {$ifdef SingleWinOnly}
    if (Application.MainWindow = Self) then
    {$endif}
    FRenderer.ResizeViewPort(FClientRect.Width, FClientRect.Height);
end;
end;

procedure BSWindow.Close;
begin
  //FreeAndNil(FGlContext);
  if (FWindowState = wsShownModal) and Assigned(FParent) then
    FParent.IsEnabled := true;

  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoClose(Self);
  FWindowState := wsClosed;
  FIsVisible := false;
  IsActive := false;
  if Assigned(FOnClose) then
    FOnClose.Send(Self);
end;

constructor BSWindow.Create(AWindowContext: TWindowContext; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32);
begin
  FWindowContext := AWindowContext;
  FWindowContext.FWindow := Self;
  FOwner := AOwner;
  FParent := AParent;
  FWidth := AWidth;
  FHeight := AHeight;
  FWindowState := wsInit;
  FLeft := APositionX;
  FTop := APositionY;
  FChildren := TWindowsList.Create(@PtrCmp);
  FIsEnabled := true;
  FShowCursor := true;
  if Assigned(FParent) then
  begin
    inc(FLevel, FParent.Level + 1);
    FParent.AddChild(Self);
end;
end;

destructor BSWindow.Destroy;
begin
  Application.ApplicationSystem.RemoveWindow(Self);
  if Assigned(FParent) then
    FParent.RemoveChild(Self);

  FreeAndNil(FChildren);
  {$ifdef SingleWinOnly}
  if (Application.MainWindow = Self) then
  {$endif}
  FreeAndNil(FRenderer);

  FreeContext;
  FreeAndNil(FWindowContext);

  if Assigned(FOnDestroy) then
    FOnDestroy.Send(Self);
  inherited;
end;

procedure BSWindow.DoRender;
begin
  if not Assigned(FGlContext) or not IsVisible then
    exit;
  {$ifndef SingleWinOnly}
  if FGlContext.MakeCurrent then
  {$endif}
  begin
  FRenderer.Render;
    if not FGlContext.Swap and FGlContext.ContextIsLost then
      Application.ApplicationSystem.OnGLContextLost;
  end;
end;

function BSWindow.DoShow(InModal: boolean): int32;
begin
  Result := 0;
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.DoShow', 'begin, InModal: ' + BoolToStr(InModal));
  {$endif}

  if InModal then
    FWindowState := wsShownModal
  else
    FWindowState := wsShown;

  FIsVisible := true;

  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoShow(Self, InModal);

  while not CheckContextIsCreated do
  begin
    Sleep(16);
    Application.ApplicationSystem.Update;
  end;

  FIsActive := true;

  if FullScreen then
    Application.ApplicationSystem.DoFullScreen(Self);

  Application.ApplicationSystem.UpdateActiveWindow(Self);

  Application.ApplicationSystem.DoShowCursor(Self);

  if Assigned(FOnShow) then
    FOnShow.Send(Self);

  Render;

  if InModal then
  begin
    {$ifndef SingleWinOnly}
    while FIsVisible do
      Application.ProcessMessages;
    {$endif}
  end;
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.DoShow', 'end');
  {$endif}
end;

function BSWindow.GetDC: EGLNativeDisplayType;
begin
  if Assigned(FWindowContext) then
    Result := FWindowContext.GetDC
  else
    Result := FDefaultDC;
end;

function BSWindow.GetFullScreen: boolean;
begin
  Result := FFullScreen;
end;

function BSWindow.GetHandle: EGLNativeWindowType;
begin
  if Assigned(FWindowContext) then
    Result := FWindowContext.GetHandle
  else
    Result := FDefaultHandle;
end;

function BSWindow.GetOnChangePosition: IWindowEvent;
begin
  if not Assigned(FOnChangePosition) then
    FOnChangePosition := CreateWindowEvent;
  Result := FOnChangePosition;
end;

function BSWindow.GetOnClose: IWindowEvent;
begin
  if not Assigned(FOnClose) then
    FOnClose := CreateWindowEvent;
  Result := FOnClose;
end;

function BSWindow.GetOnDestroy: IWindowEvent;
begin
  if not Assigned(FOnDestroy) then
    FOnDestroy := CreateWindowEvent;
  Result := FOnDestroy;
end;

function BSWindow.GetOnResize: IWindowEvent;
begin
  if not Assigned(FOnResize) then
    FOnResize := CreateWindowEvent;
  Result := FOnResize;
end;

function BSWindow.GetOnShow: IWindowEvent;
begin
  if not Assigned(FOnShow) then
    FOnShow := CreateWindowEvent;
  Result := FOnShow;
end;

function BSWindow.GetShiftStateFromKeyStates: TBSShiftState;
begin
  Result := [];
  if FRenderer.Keyboard[VK_BS_SHIFT] then
    Include(Result, ssShift);
  if FRenderer.Keyboard[VK_BS_CONTROL] then
    Include(Result, ssShift);
end;

procedure BSWindow.KeyDown(var Key: Word; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.KeyDown(Key, Shift);
  end;
end;

procedure BSWindow.KeyPress(var Key: WideChar; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.KeyPress(Key, Shift);
  end;
end;

procedure BSWindow.KeyUp(var Key: Word; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.KeyUp(Key, Shift);
  end;
end;

procedure BSWindow.MouseClick(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState);
begin
  //FRenderer.KeyDown(Key, Shift);
end;

procedure BSWindow.MouseDblClick(X, Y: int32);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('ActiveWindow.MouseDblClick ' + Caption, 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y));
  {$endif}
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseDblClick(X, Y);
  end;
end;

procedure BSWindow.MouseDown(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState);
begin
  FMouseIsDown := true;
  {$ifdef DEBUG_BS}
  BSWriteMsg('ActiveWindow.MouseDown ' + Caption, 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y));
  {$endif}
  if FIsEnabled and Assigned(FRenderer) then
  begin
    if Assigned(Application.ApplicationSystem.CustomCursor) then
    begin
    	Application.ApplicationSystem.CustomCursor.Position2d := vec2(X, Y);
    end;
    FRenderer.MouseDown(MouseButton, X, Y, Shift);
  end;
end;

procedure BSWindow.MouseEnter(X, Y: int32);
begin
  FMouseEntered := true;
  if Assigned(FRenderer) then
  begin
    if Assigned(Application.ApplicationSystem.CustomCursor) then
    begin
    	Application.ApplicationSystem.CustomCursor.Position2d := vec2(X, Y);
    end;
    FRenderer.MouseEnter(X, Y);
  end;
end;

procedure BSWindow.MouseLeave;
begin
  FMouseEntered := false;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseLeave;
  end;
end;

procedure BSWindow.MouseMove(X, Y: int32; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    {$ifdef DEBUG_BS}
    //BSWriteMsg('ActiveWindow.MouseMove ' + Caption, 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y) + '; MouseIsDown:' + BoolToStr(FMouseIsDown, true));
    {$endif}
    if Assigned(Application.ApplicationSystem.CustomCursor) then
    begin
    	Application.ApplicationSystem.CustomCursor.Position2d := vec2(X, Y);
    end;
    FRenderer.MouseMove(X, Y, Shift);
  end;
end;

procedure BSWindow.MouseUp(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState);
begin
  FMouseIsDown := false;
  {$ifdef DEBUG_BS}
  BSWriteMsg('ActiveWindow.MouseUp ' + Caption, 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y));
  {$endif}
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseUp(MouseButton, X, Y, Shift);
  end;
end;

procedure BSWindow.MouseWheel(WheelDelta: int32; X, Y: int32; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseWheel(WheelDelta, X, Y, Shift);
  end;
end;

procedure BSWindow.OnCreateGlContext;
begin
  //Renderer.Color := BS_CL_BLACK;
end;

procedure BSWindow.OnCreateGlContextEvent(const Value: BEmpty);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.OnCreateGlContextEvent', Caption);
  {$endif}
  if not Assigned(FRenderer) then
  begin
    {$ifdef SingleWinOnly} if Application.MainWindow = Self then {$endif}
    begin
    //if Application.MainWindow <> Self then
    //begin
    //  //FChildPass := FRenderer.AddPass(BSShaderManager.Load('QUAD', TBlackSharkQUADShader), FRenderer.DrawQUAD,
    //  //  FLeft, Application.MainWindow.Height - FTop - FHeight, FClientRect.Width, FClientRect.Height, false);
    //end;
  FRenderer := TBlackSharkRenderer.Create;
  FRenderer.ExactSelectObjects := true;
      FRenderer.Caption := Caption;
    end
    {$ifdef SingleWinOnly}
    else
      FRenderer := Application.MainWindow.Renderer
    {$endif}
    ;

  end else
    FRenderer.Restore;
  CheckSizeRendererWindow;
  OnCreateGlContext;
  FOnCreateContextEvent.Send(Self);
end;

procedure BSWindow.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;

  FCaption := AValue;

  if Assigned(FRenderer) then
    FRenderer.Caption := Caption;
end;

procedure BSWindow.RemoveChild(AChild: BSWindow);
begin
  FChildren.Remove(AChild);
end;

procedure BSWindow.Render;
begin
  if not BSConfig.MaxFps then
    DoRender;
end;

procedure BSWindow.Resize(AWidth, AHeight: int32);
var
  w, h: int32;
  dw, dh: int32;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.Resize ' + Caption, 'AWidth: ' + IntToStr(AWidth) + '; AHeight: ' + IntToStr(AHeight));
  {$endif}
  w := bs.math.clamp(Application.ApplicationSystem.DisplayWidth, 10, AWidth);
  h := bs.math.clamp(Application.ApplicationSystem.DisplayHeight, 10, AHeight);

  dw := AWidth - w;
  dh := AHeight - h;

  FClientRect.Inflate(0, 0, dw, dh);
  FWidth := w;
  FHeight := h;
  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoResize(Self, FWidth, FHeight);
  CheckSizeRendererWindow;
  if Assigned(FOnResize) then
    FOnResize.Send(Self);
  Render;
end;

procedure BSWindow.SetClientRect(const AValue: TRect);
begin
  FClientRect := AValue;
  CheckSizeRendererWindow;
end;

procedure BSWindow.SetDC(const AValue: EGLNativeDisplayType);
begin
  FWindowContext.DC := AValue;
  CheckContextIsCreated;
end;

procedure BSWindow.SetFullScreen(const AValue: boolean);
begin
  if FFullScreen = AValue then
    exit;
  FFullScreen := AValue;
  if FFullScreen then
  begin
    FRectBeforeFullScreen := Rect(FLeft, FTop, FLeft + FWidth, FTop + FHeight);
    FClientRectBeforeFullScreen := FClientRect;
    FLeft := 0;
    FTop := 0;
    FWidth := Application.ApplicationSystem.DisplayWidth;
    FHeight := Application.ApplicationSystem.DisplayHeight;
  end else
  begin
    FLeft := FRectBeforeFullScreen.Left;
    FTop := FRectBeforeFullScreen.Top;
    FWidth := FRectBeforeFullScreen.Width;
    FHeight := FRectBeforeFullScreen.Height;
    FClientRect := FClientRectBeforeFullScreen;
  end;

  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.SetFullScreen ' + FCaption, 'IsVisible: ' + BoolToStr(FIsVisible) + '; FullScreen: ' + BoolToStr(FFullScreen));
  {$endif}

  if not FFromOSEventChanged and FIsVisible then
    Application.ApplicationSystem.DoFullScreen(Self);
end;

procedure BSWindow.OnGLContextLost;
begin
  FreeContext;
end;

procedure BSWindow.SetHandle(const AValue: EGLNativeWindowType);
begin
  if FWindowContext.Handle <> AValue then
    FreeContext;

  FWindowContext.Handle := AValue;
  CheckContextIsCreated;
end;

procedure BSWindow.SetIsActive(const Value: boolean);
begin
  CheckContextIsCreated;
  if FIsActive = Value then
    exit;
  FIsActive := Value;
  if not FFromOSEventChanged and FIsVisible then
    Application.ApplicationSystem.DoActive(Self)
  else
    Application.ApplicationSystem.UpdateActiveWindow(Self);

  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.SetIsActive ' + FCaption, BoolToStr(FIsActive));
  {$endif}
end;

procedure BSWindow.FreeContext;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('FreeContext', '');
  {$endif}

  {$ifdef SingleWinOnly}
  if (Application.MainWindow = Self) then
    FreeAndNil(FGlContext)
  else
    FGlContext := nil;
  {$else}
    FreeAndNil(FGlContext);
  {$endif}
end;

procedure BSWindow.SetIsEnabled(const Value: boolean);
begin
  FIsEnabled := Value;
end;

procedure BSWindow.SetPosition(ALeft, ATop: int32);
begin
  {$ifdef SingleWinOnly}

  if (Application.MainWindow = Self) then
  begin
    FLeft := 0;
    FTop := 0;
  end else
  begin
    FLeft := bs.math.clamp(ALeft - FWidth, 0, ALeft);
    FTop := bs.math.clamp(ATop - FHeight, 0, ATop);
  end;

  {$else}
  FLeft := bs.math.clamp(ALeft - 10, 0, ALeft);
  FTop := bs.math.clamp(ATop - 10, 0, ATop);
  {$endif}
  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoSetPosition(Self, FLeft, FTop);
  if Assigned(FOnChangePosition) then
    FOnChangePosition.Send(Self);
end;

procedure BSWindow.SetShowCursor(const AValue: boolean);
begin
  if FShowCursor = AValue then
    exit;
  FShowCursor := AValue;
  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoShowCursor(Self);
end;

procedure BSWindow.Show;
begin
  DoShow(false);
end;

function BSWindow.ShowModal: int32;
begin
  Result := DoShow(true);
end;

procedure BSWindow.Draw;
begin
  DoRender;
end;

procedure BSWindow.EndFromOSChange;
begin
  FFromOSEventChanged := false;
end;

{ TWindowContext }

function TWindowContext.GetDC: EGLNativeDisplayType;
begin
  Result := FDC;
end;

function TWindowContext.GetHandle: EGLNativeWindowType;
begin
  Result := FHandle;
end;

procedure TWindowContext.SetDC(const AValue: EGLNativeDisplayType);
begin
  FDC := AValue;
end;

procedure TWindowContext.SetHandle(const AValue: EGLNativeWindowType);
begin
  FHandle := AValue;
end;

initialization
  ApplicationRun := ApplicationRunDefault;

end.
