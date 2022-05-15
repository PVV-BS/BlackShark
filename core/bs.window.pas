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
unit bs.window;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , types
  , bs.basetypes
  , bs.events
  , bs.obj
  , bs.gl.egl
  , bs.gl.context
  , bs.renderer
  , bs.collections
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
    procedure SetPixelsPerInchX(AValue: int32);
    procedure SetPixelsPerInchY(AValue: int32);
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
    function GetWindow(AHandle: EGLNativeWindowType): BSWindow;

    procedure DoShow(AWindow: BSWindow; AInModalMode: boolean); virtual;
    procedure DoClose(AWindow: BSWindow); virtual;
    procedure DoInvalidate(AWindow: BSWindow); virtual; abstract;
    procedure DoResize(AWindow: BSWindow; AWidth, AHeight: int32); virtual; abstract;
    procedure DoSetPosition(AWindow: BSWindow; ALeft, ATop: int32); virtual; abstract;
    procedure DoFullScreen(AWindow: BSWindow); virtual; abstract;
    procedure DoActive(AWindow: BSWindow); virtual;

    function GetMousePointPos: TVec2i; virtual; abstract;
    //procedure SetShowCursor(const Value: boolean); virtual;
    { exchange an active window }
    procedure UpdateActiveWindow(AWindow: BSWindow); virtual;
    procedure OnGLContextLost; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    function CreateWindow(AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload;
    function CreateWindow(AWindowClass: BSWindowClass; AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow; overload; virtual; abstract;
    function CreateWindow(AWindow: BSWindow): BSWindow; overload; virtual; abstract;
    procedure Update; virtual; abstract;
    procedure UpdateWait; virtual; abstract;

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
    procedure OnCreateContextNorify(const AData: BEmpty);
    procedure OnRemoveContextNorify(const AData: BEmpty);
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
    //Application.MainWindow.Show;

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

{$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.Create', '');
{$endif}

  FMainWindow := CreateWindow(nil, Self, 0, 0, 600, 600);
  ObserverOnCreateContext := FMainWindow.OnCreateContextEvent.CreateObserver(OnCreateContextNorify);
  ObserverOnRemoveWindow := FApplicationSystem.OnRemoveWindowEvent.CreateObserver(OnRemoveContextNorify);
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
  inherited;
end;

procedure TBlackSharkApplication.DoUpdateFps;
begin

end;

procedure TBlackSharkApplication.OnCreateContextNorify(const AData: BEmpty);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.OnCreateContextNorify', '');
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
  BSWriteMsg('TBlackSharkApplication.OnCreateGlContext', '');
  {$endif}
end;

procedure TBlackSharkApplication.OnGLContextLost;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkApplication.OnGLContextLost', '');
  {$endif}
end;

procedure TBlackSharkApplication.OnRemoveContextNorify(const AData: BEmpty);
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
  if not BSConfig.MaxFps and (t - TTimeProcessEvent.TimeProcessEvent.Counter > 3000) then
    FApplicationSystem.UpdateWait
  else
    FApplicationSystem.Update;

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
  {$ifdef ANDROID}
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
  inherited;
end;

procedure BSApplicationSystem.DoActive(AWindow: BSWindow);
begin
  UpdateActiveWindow(AWindow);
end;

procedure BSApplicationSystem.DoClose(AWindow: BSWindow);
begin
  //if FWindows.Count = 1 then
  //AWindow.Handle := 0;
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

  {$ifdef ANDROID}
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

function BSApplicationSystem.GetWindow(AHandle: EGLNativeWindowType): BSWindow;
begin
  FWindows.Find(AHandle, Result);
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
  {$ifdef ANDROID}
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
{$ifdef ANDROID}
var
  bd: BData;
{$endif}
begin
  if ({%H-}NativeInt(Handle) = 0) or ({%H-}NativeInt(DC) = 0) then
    exit(false);

  if Assigned(FGlContext) and FGlContext.ContextCreated then
    exit(true);

  {$ifdef ANDROID}

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

  {$ifdef ANDROID}
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
    {$ifdef ANDROID}
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
  {$ifdef ANDROID}
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

  if FGlContext.MakeCurrent then
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

  if Assigned(FOnShow) then
    FOnShow.Send(Self);

  Render;

  if InModal then
  begin
    {$ifndef ANDROID}
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
    Render;
  end;
end;

procedure BSWindow.KeyPress(var Key: WideChar; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.KeyPress(Key, Shift);
    Render;
  end;
end;

procedure BSWindow.KeyUp(var Key: Word; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.KeyUp(Key, Shift);
    Render;
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
    Render;
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
    FRenderer.MouseDown(MouseButton, X, Y, Shift);
    Render;
  end;
end;

procedure BSWindow.MouseEnter(X, Y: int32);
begin
  FMouseEntered := true;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseEnter(X, Y);
    Render;
  end;
end;

procedure BSWindow.MouseLeave;
begin
  FMouseEntered := false;
  if Assigned(FRenderer) then
  begin
    FRenderer.MouseLeave;
    Render;
  end;
end;

procedure BSWindow.MouseMove(X, Y: int32; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseMove(X, Y, Shift);
    Render;
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
    Render;
  end;
end;

procedure BSWindow.MouseWheel(WheelDelta: int32; X, Y: int32; Shift: TBSShiftState);
begin
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseWheel(WheelDelta, X, Y, Shift);
    Render;
  end;
end;

procedure BSWindow.OnCreateGlContext;
begin
end;

procedure BSWindow.OnCreateGlContextEvent(const Value: BEmpty);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('BSWindow.OnCreateGlContextEvent', Caption);
  {$endif}
  if not Assigned(FRenderer) then
  begin
    {$ifdef ANDROID} if Application.MainWindow = Self then {$endif}
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
    {$ifdef ANDROID}
    else
      FRenderer := Application.MainWindow.Renderer
    {$endif}
    ;

    {$ifdef ANDROID}

    {$endif}

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

  {$ifdef ANDROID}
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
  {$ifdef ANDROID}

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
  FShowCursor := AValue;
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
