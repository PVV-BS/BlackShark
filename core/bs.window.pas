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

type
  BSWindow = class;
  TMonitor = class;

  TBlackSharkApplication = class;

  BSWindowClass = class of BSWindow;
  TWindowsTable = THashTable<EGLNativeWindowType, BSWindow>;
  TWindowsList  = TListVec<BSWindow>;
  TMonitorsList = TListVec<TMonitor>;

  { TMonitor - todo }

  TMonitor = class
  private
  public
  end;

  BSApplicationSystem = class abstract
  private
    FOnRemoveWindowEvent: IBEmptyEvent;
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
    procedure UpdateActiveWindow(AWindow: BSWindow); virtual;
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
    property DisplayWidth: int32 read FDisplayWidth;
    property DisplayHeight: int32 read FDisplayHeight;
    property PixelsPerInchX: int32 read FPixelsPerInchX;
    property PixelsPerInchY: int32 read FPixelsPerInchY;
    property OnRemoveWindowEvent: IBEmptyEvent read FOnRemoveWindowEvent;
    property ActiveWindow: BSWindow read FActiveWindow;
  end;

  TBlackSharkApplication = class
  private
    FMainWindow: BSWindow;
    ObserverOnCreateContext: IBEmptyEventObserver;
    ObserverOnRemoveWindow: IBEmptyEventObserver;
    FContextCreated: boolean;
    FLastUpdate: uint32;
    FApplicationSystem: BSApplicationSystem;
    FEventOnUdateActiveWindow: IBEmptyEvent;
    procedure OnCreateContextNorify(const AData: BEmpty);
    procedure OnRemoveContextNorify(const AData: BEmpty);
  protected
    procedure OnCreateGlContext(AWindow: BSWindow); virtual;
    procedure OnRemoveWindow(AWindow: BSWindow); virtual;
    procedure DoUpdateFps; virtual;
    procedure OnUpdateActiveWindow(AWindow: BSWindow); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
    procedure ProcessMessages;
    function CreateWindow(AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow; overload;
    function CreateWindow(AWindowClass: BSWindowClass; AParent: BSWindow; AOwner: TObject; ALeft, ATop, AWidth, AHeight: int32): BSWindow; overload;

    property ApplicationSystem: BSApplicationSystem read FApplicationSystem;
    property MainWindow: BSWindow read FMainWindow;
    property ContextCreated: boolean read FContextCreated;
    property EventOnUdateActiveWindow: IBEmptyEvent read FEventOnUdateActiveWindow;
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

  BSWindow = class
  private
    FGlContext: TBlackSharkContext;
    FWindowContext: TWindowContext;
    FParent: BSWindow;
    FChildren: TWindowsList;
    FRenderer: TBlackSharkRenderer;
    ObserverCreateContext: IBEmptyEventObserver;
    FOnCreateContextEvent: IBEmptyEvent;
    FOwner: TObject;
    FShowCursor: boolean;
    FFullScreen: boolean;
    FMouseEntered: boolean;
    FIsVisible: boolean;
    FClientRect: TRect;
    FDefaultHandle: EGLNativeWindowType;
    FDefaultDC: EGLNativeDisplayType;

    FOnShow: IWindowEvent;
    FOnResize: IWindowEvent;
    FOnChangePosition: IWindowEvent;
    FOnClose: IWindowEvent;
    FOnDestroy: IWindowEvent;
    FIsEnabled: boolean;

    procedure CheckSizeRendererWindow;
    procedure AddChild(AChild: BSWindow);
    procedure RemoveChild(AChild: BSWindow);
    function GetFullScreen: boolean;
    function CheckContextIsCreated: boolean;
    procedure OnCreateGlContextEvent(const {%H-}Value: BEmpty);
    procedure SetClientRect(const AValue: TRect);
    function GetOnChangePosition: IWindowEvent;
    function GetOnClose: IWindowEvent;
    function GetOnResize: IWindowEvent;
    function GetOnShow: IWindowEvent;
    function GetOnDestroy: IWindowEvent;
    function DoShow(InModal: boolean): int32;
    procedure SetIsActive(const Value: boolean);
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
    procedure OnCreateGlContext; virtual;
    procedure Render; inline;
    // todo
    procedure SetFullScreen(const AValue: boolean); virtual;
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
    property Width: int32 read FWidth;
    property Height: int32 read FHeight;
    property Left: int32 read FLeft;
    property Top: int32 read FTop;
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
    property IsVisible: boolean read FIsVisible;
    property IsEnabled: boolean read FIsEnabled write SetIsEnabled;
    // todo
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
{$ifdef X}
  , bs.window.linux
{$else MSWindows}
  , bs.window.windows
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
var
  app: TBlackSharkApplication;
begin
  if not Assigned(Application) then
  begin
    app := TBlackSharkApplication.Create;
    app.Run;
    app.Free;
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
  FEventOnUdateActiveWindow := CreateEmptyEvent;
{$ifdef X}
  FApplicationSystem := BSApplicationLinux.Create;
{$else MSWindows}
  FApplicationSystem := BSApplicationWindows.Create;
{$endif}
  FMainWindow := CreateWindow(nil, Self, 0, 0, 600, 600);
  ObserverOnCreateContext := FMainWindow.OnCreateContextEvent.CreateObserver(OnCreateContextNorify);
  ObserverOnRemoveWindow := FApplicationSystem.OnRemoveWindowEvent.CreateObserver(OnRemoveContextNorify);
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
  { vertical synchronization }
  if BSConfig.VerticalSynchronization or not BSConfig.MaxFps then
    eglSwapInterval(TSharedEglContext.SharedDisplay, 1)
  else
    eglSwapInterval(TSharedEglContext.SharedDisplay, 0);
  FContextCreated := true;
  OnCreateGlContext(BSWindow(AData.Instance));
end;

procedure TBlackSharkApplication.OnCreateGlContext(AWindow: BSWindow);
begin

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
  FEventOnUdateActiveWindow.Send(AWindow);
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
  FLastUpdate := TBTimer.CurrentTime.Low;

  while (FApplicationSystem.Windows.Count > 0) and FMainWindow.IsVisible do
  begin
    ProcessMessages;
  end;
  FreeAndNil(FMainWindow);
end;

{ BSApplicationSystem }

procedure BSApplicationSystem.AddWindow(AWindow: BSWindow);
begin
  FWindowsList.Add(AWindow);
  FWindows.Items[AWindow.Handle] := AWindow;
  if not Assigned(FMainWindow) then
    FMainWindow := AWindow;
end;

procedure BSApplicationSystem.AfterConstruction;
begin
  inherited;
  InitHandlers;
  InitMonitors;
end;

constructor BSApplicationSystem.Create;
begin
  FWindows := TWindowsTable.Create(@GetHashHandleWindow, @HandleWindowCmpEqual, 32);
  FWindowsList := TWindowsList.Create(@PtrCmp);
  FOnRemoveWindowEvent := CreateEmptyEvent;
  FMonitors := TMonitorsList.Create;
end;

function BSApplicationSystem.CreateWindow(AOwner: TObject; AParent: BSWindow; APositionX, APositionY, AWidth, AHeight: int32): BSWindow;
begin
  Result := CreateWindow(BSWindow, AOwner, AParent, APositionX, APositionY, AWidth, AHeight);
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

  FWindows.Delete(AWindow.Handle);
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
begin
  if (NativeInt(Handle) = 0) or (NativeInt(DC) = 0) then
    exit(false);

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
end;

procedure BSWindow.CheckSizeRendererWindow;
begin
  if Assigned(FRenderer) and (FClientRect.Width > 0) and (FClientRect.Height > 0) and ((FRenderer.WindowWidth <> FClientRect.Width) or (FRenderer.WindowHeight <> FClientRect.Height)) and Assigned(FGlContext) and FGlContext.MakeCurrent then
    FRenderer.ResizeViewPort(FClientRect.Width, FClientRect.Height);
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
    FParent.AddChild(Self);
end;

destructor BSWindow.Destroy;
begin
  Application.ApplicationSystem.RemoveWindow(Self);
  if Assigned(FParent) then
    FParent.RemoveChild(Self);

  FreeAndNil(FChildren);
  FreeAndNil(FRenderer);
  FreeAndNil(FGlContext);
  FreeAndNil(FWindowContext);

  if Assigned(FOnDestroy) then
    FOnDestroy.Send(Self);
  inherited;
end;

procedure BSWindow.DoRender;
begin
  if not Assigned(FGlContext) or not FGlContext.MakeCurrent or not IsVisible then
    exit;
  FRenderer.Render;
  FGlContext.Swap;
end;

function BSWindow.DoShow(InModal: boolean): int32;
begin
  Result := 0;

  if InModal then
    FWindowState := wsShownModal
  else
    FWindowState := wsShown;

  FIsVisible := true;

  //if InModal and Assigned(FParent) then
  //  FParent.IsEnabled := false;

  if not FFromOSEventChanged then
    Application.ApplicationSystem.DoShow(Self, InModal);

  if FullScreen then
    Application.ApplicationSystem.DoFullScreen(Self);

  while not CheckContextIsCreated do
  begin
    Sleep(16);
    Application.ApplicationSystem.Update;
  end;

  FIsActive := true;
  Application.ApplicationSystem.UpdateActiveWindow(Self);

  if Assigned(FOnShow) then
    FOnShow.Send(Self);

  if InModal then
  begin
    while FIsVisible do
      Application.ProcessMessages;
  end;
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
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseDblClick(X, Y);
    Render;
  end;
end;

procedure BSWindow.MouseDown(MouseButton: TBSMouseButton; X, Y: int32; Shift: TBSShiftState);
begin
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
  if FIsEnabled and Assigned(FRenderer) then
  begin
    FRenderer.MouseUp(MouseButton, X, Y, Shift);
    Render;
  end;
end;

procedure BSWindow.MouseWheel(WheelDelta, X, Y: int32; Shift: TBSShiftState);
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
  FRenderer := TBlackSharkRenderer.Create;
  FRenderer.ExactSelectObjects := true;
  CheckSizeRendererWindow;
  FOnCreateContextEvent.Send(Self);
  OnCreateGlContext;
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
begin
  FWidth := AWidth;
  FHeight := AHeight;
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
  FFullScreen := AValue;
  if not FFromOSEventChanged and FIsVisible then
    Application.ApplicationSystem.DoFullScreen(Self);
end;

procedure BSWindow.SetHandle(const AValue: EGLNativeWindowType);
begin
  if FWindowContext.Handle <> AValue then
    FreeAndNil(FGlContext);
  FWindowContext.Handle := AValue;
  CheckContextIsCreated;
end;

procedure BSWindow.SetIsActive(const Value: boolean);
begin
  if FIsActive = Value then
    exit;
  FIsActive := Value;
  if not FFromOSEventChanged and FIsVisible then
    Application.ApplicationSystem.DoActive(Self)
  else
    Application.ApplicationSystem.UpdateActiveWindow(Self);
end;

procedure BSWindow.SetIsEnabled(const Value: boolean);
begin
  FIsEnabled := Value;
end;

procedure BSWindow.SetPosition(ALeft, ATop: int32);
begin
  FLeft := ALeft;
  FTop := ATop;
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
