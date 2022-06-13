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


{
  The unit contains some kinds events (classes), which are their sources;
}

unit bs.events;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , syncobjs
  , bs.basetypes
  , bs.obj
  , bs.thread
  , bs.collections
  ;

type

  BData = record
    Instance: Pointer; // it is usually a source of event (PGraphicInstance, PRendererGraphicInstance, TGraphicObject...)
  end;

  TBSShiftState = TShiftState;

  TBSMouseButton = (mbBsLeft, mbBsRight, mbBsMiddle, mbBsExtra1, mbBsExtra2);
  TBSMouseButtons = set of TBSMouseButton;

  PMouseData = ^BMouseData;
  BMouseData = record
    BaseHeader: BData;
    X, Y, DeltaWeel: int32;
    Button: TBSMouseButtons;
    ShiftState: TBSShiftState;
  end;

  IBMouseEventTemplate<T> = interface(IBEvent<T>)
  ['{AE3C328E-6E5E-4C9B-81E4-3F28E53BA128}']
    procedure Send(Instance: Pointer; X, Y, DeltaWeel: int32; Button: TBSMouseButtons; ShiftState: TBSShiftState);
  end;

  IBMouseEvent = IBMouseEventTemplate<BMouseData>;
  IBMouseEventObserver = IBObserver<BMouseData>;

  BEmpty = BData;

  IBEmptyEvent = interface(IBEvent<BEmpty>)
  ['{6D8AF214-6477-46C2-A087-CBABA6333120}']
    procedure Send(Instance: Pointer);
  end;
  IBEmptyEventObserver = IBObserver<BEmpty>;

  BOpCode = record
    BaseHeader: BEmpty;
    OpCode: int32;
    Data: NativeInt;
    Data2: NativeInt;
  end;

  IBOpCodeEvent = interface(IBEvent<BOpCode>)
  ['{D6A7B32D-31C9-48AC-A9F3-F108D56618A3}']
    procedure Send(Instance: Pointer; OpCode: int32; Data: NativeInt = -1; Data2: NativeInt = -1);
  end;
  IBOpCodeEventObserver = IBObserver<BOpCode>;

  BMessage = record Msg: string; end;
  IBMessageEvent = IBEvent<BMessage>;
  IBMessageEventObserver = IBObserver<BMessage>;

  IBMouseDblClickEvent = IBMouseEvent;
  IBMouseDblClickEventObserver = IBMouseEventObserver;

  IBMouseMoveEvent = IBMouseEvent;
  IBMouseMoveEventObserver = IBMouseEventObserver;

  IBMouseDownEvent = IBMouseEvent;
  IBMouseDownEventObserver = IBMouseEventObserver;

  IBMouseUpEvent = IBMouseEvent;
  IBMouseUpEventObserver = IBMouseEventObserver;

  IBMouseWeelEvent = IBMouseEvent;
  IBMouseWeelEventObserver = IBMouseEventObserver;

  IBMouseEnterEvent = IBMouseEvent;
  IBMouseEnterEventObserver = IBMouseEventObserver;

  IBMouseLeaveEvent = IBMouseEvent;
  IBMouseLeaveEventObserver = IBMouseEventObserver;


  BTransformData = record
    BaseHeader: BData;
    MeshTransformed: Boolean;
  end;

  IBChangeMVPEvent = interface(IBEvent<BTransformData>)
  ['{AB036C51-DA26-4E55-B898-12F87C9C66FF}']
    procedure Send(Instance: Pointer; MeshTransformd: boolean);
  end;
  IBChangeMVPEventObserver = IBObserver<BTransformData>;


  BDragDropData = record
    BaseHeader: BData;
    CheckDragParent: Boolean;
  end;

  IBDragDropEvent = interface(IBEvent<BDragDropData>)
  ['{AB036C51-DA26-4E55-B898-12F87C9C66FF}']
    procedure Send(Instance: Pointer; CheckDragParent: boolean);
  end;
  IBDragDropEventObserver = IBObserver<BDragDropData>;

  BKeyData = record
    BaseHeader: BData;
    Key: Word;
    Shift: TBSShiftState;
  end;

  { TKeyEvent }

  { IBKeyObjectTemplate }

  IBKeyObjectTemplate<T> = interface(IBEvent<T>)
  ['{AE87C0D1-8D0F-41B5-8693-4DCFFD1203BD}']
    procedure Send(Instance: Pointer; Key: Word; Shift: TBSShiftState);
  end;

  IBKeyObject = IBKeyObjectTemplate<BKeyData>;

  IBKeyEventObserver = IBObserver<BKeyData>;

  IBKeyDownEvent = IBKeyObject;

  IBKeyUpEvent = IBKeyObject;

  IBKeyPressEvent = IBKeyObject;

  BResizeEventData = record
    BaseHeader: BData;
    NewWidth: int32;
    NewHeight: int32;
    PercentWidthChange: BSFloat;
    PercentHeightChange: BSFloat;
  end;

  { TResizeWindowEvent }

  IBResizeWindowEvent = interface(IBEvent<BResizeEventData>)
    ['{13F9624A-61F1-4AC8-81C5-564A4E98993F}']
    procedure Send(Instance: Pointer; NewWidth, NewHeight: int32; PercentWidthChange, PercentHeightChange: BSFloat);
  end;
  IBResizeWindowEventObserver = IBObserver<BResizeEventData>;

  BFocusEventData = record
    BaseHeader: BData;
    { try do not use it }
    Control: Pointer;
    Focus: boolean;
    ControlLevel: int32;
  end;

  IBFocusEvent = interface(IBEvent<BFocusEventData>)
    ['{13F9624A-61F1-4AC8-81C5-564A4E98993F}']
    procedure Send(Instance: Pointer; Control: Pointer; Focused: boolean; ControlLevel: int32);
  end;
  IBFocusEventObserver = IBObserver<BFocusEventData>;

  TEventRealign = IBEmptyEvent;

  function MouseData(Instance: Pointer; X, Y, DeltaWeel: int32; Button: TBSMouseButtons; ShiftState: TBSShiftState): BMouseData; inline;
  function KeyData(Instance: Pointer; Key: Word; Shift: TBSShiftState): BKeyData; inline;

const
    { task's opcodes }
    TASK_UPDATE               = 0;
    TASK_START                = 1;
    TASK_STOP                 = 2;
    TASK_AUTO_STOP            = 3;

    { gui events }
    GUI_FOCUS_ACCEPTED        = 4;
    GUI_FOCUS_LOST            = 5;
    GUI_SHOW_KEYBOARD         = 6;
    GUI_HIDE_KEYBOARD         = 7;

type

  TUpdateTaskProc = procedure of object;

  PRecTask = ^TRecTask;
  TListTasks = TListDual<PRecTask>;
  TRecTask = record
    Task: Pointer; //IUnknown;
    Proc: TUpdateTaskProc;
    Pos: TListTasks.PListItem;
    Deleted: boolean;
  end;

  { IBTask<T>
    is calculator of a value; calculating may accomplish in any thread context,
    including GUIThread;
   }

  IBTask = interface
    ['{6D76F0B0-8D0F-473B-98FD-5312175E4CD9}']
    { implementation of a task; executor side method }
    procedure Update;
    { the method can be invoked only during executing Update, that is in context
      of executor; the conditions for stopping the task each defines itself }
    procedure AutoStop;
    { gui side of methods }
    procedure Run;
    procedure Stop;
    function GetIsRun: boolean;
    function GetIntervalUpdate: int32;
    procedure SetIntervalUpdate(Value: int32);
    //property Runned: boolean read GetRunned;
    property IsRun: boolean read GetIsRun;
    property IntervalUpdate: int32 read GetIntervalUpdate write SetIntervalUpdate;
  end;

  IBTaskObservable<T> = interface(IBTask)
    function  CreateObserver(ThreadCntx: TBThread; OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>;
  end;

  TAwaitTaskProc = procedure(AData: Pointer) of object;

  TTaskExecutor = class
  private
    type
      PAwaitTask = ^TAwaitTask;
      TListAwaitTasks = TListDual<PAwaitTask>;
      TAwaitTask = record
        Position: TListAwaitTasks.PListItem;
        TimeAwait: Cardinal;
        TimeStart: Cardinal;
        TaskProc: TAwaitTaskProc;
        Data: Pointer;
      end;
  private
    class var FCountTasks: int32;
    class var FLastTimeRemoveTask: int64;
  private
    FTasks: TListTasks;
    FAwaitTasks: TListAwaitTasks;
    FThreadContext: TBThread;
    function ProcessEvents: boolean;
    function Add(const Task: IUnknown; TaskUpdateProc: TUpdateTaskProc): PRecTask; inline;
    procedure AddAwaitTask(AAwaitTaskProc: TAwaitTaskProc; ATimeAwait: Cardinal;  AData: Pointer); inline;
    procedure Remove(var TaskPos: PRecTask); inline;
    procedure ClearFromTasks;
    class function GetExecuter(AContext: TBThread): TTaskExecutor;
  private
    class var Executors: TListVec<TTaskExecutor>;
    class var CS: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    constructor Create(AThreadContext: TBThread);
    destructor Destroy; override;
    class function AddTask(const ATask: IUnknown; ATaskUpdateProc: TUpdateTaskProc; AContext: TBThread): PRecTask;
    class procedure AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; ATimeAwait: Cardinal; AContext: TBThread; AData: Pointer); overload;
    class procedure AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; AData: Pointer; ATimeAwait: Cardinal); overload;
    class procedure AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; AData: Pointer); overload;
    class procedure AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc); overload;
    class procedure RemoveTask(var TaskPos: PRecTask; Context: TBThread);
  public
    property ThreadContext: TBThread read FThreadContext;
    class property CountTasks: int32 read FCountTasks;
    class property LastTimeRemoveTask: int64 read FLastTimeRemoveTask;
  end;

  { the task also as IBEvent<T> for work result return demands observers }

  TTemplateBTask<T> = class(TTemplateBEvent<T>, IBTaskObservable<T>)
  private
    AutoStopTrap: IBEmptyEvent;
    StartStopEvent: IBOpCodeEvent;
    ObserverAutoStop: IBEmptyEventObserver;
    ObserverStartStop: IBOpCodeEventObserver;
    Postn: PRecTask;
    //FTrapValue: TTaskTrapResult<T>;
    FIsRun: boolean;
    procedure OnAutoStop(const Value: BEmpty);
    procedure StartStop(const Value: BOpCode);
  protected
    FIntervalUpdate: int32;
    { here you need to prepare a new value T and send it by SendEvent(T) }
    procedure Update; virtual; abstract;
    { }
    procedure AutoStop;
    //function GetRunned: boolean; deprecated 'Use IsRun';
    function GetIsRun: boolean;
    function GetIntervalUpdate: int32;
    procedure SetIntervalUpdate(Value: int32);
  public
    constructor Create(ThreadContext: TBThread);
    { when task destroy it checks if is it runnded and stop if so,
      how but despite you must youself stop task in your threadcontext }
    destructor Destroy; override;
    procedure Run; virtual;
    procedure Stop; virtual;
    property IsRun: boolean read GetIsRun;
    property IntervalUpdate: int32 read GetIntervalUpdate write SetIntervalUpdate;
  end;

  IBEmptyTask = IBTaskObservable<byte>;
  IBEmptyTaskObserver = IBObserver<byte>;

  //TTemplateBSyncTask<T> = class(TTemplateBTask<T>)

  function CreateEmptyEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBEmptyEvent;
  function CreateEmptyObserver(const EmptyEvent: IBEmptyEvent;
    OnRsvProc: TGenericRecieveProc<BEmpty>;
    ThreadContext: TBThread = nil): IBEmptyEventObserver;

  function CreateMouseEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBMouseEvent;
  function CreateMouseObserver(const MouseEvent: IBMouseEvent;
    OnRsvProc: TGenericRecieveProc<BMouseData>;
    ThreadContext: TBThread = nil): IBMouseEventObserver;

  function CreateMessageEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBMessageEvent;
  function CreateMessageObserver(const MessageEvent: IBMessageEvent;
    OnRsvProc: TGenericRecieveProc<BMessage>;
    ThreadContext: TBThread = nil): IBMessageEventObserver;

  function CreateKeyEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBKeyObject;
  function CreateKeyObserver(const KeyEvent: IBKeyObject;
    OnRsvProc: TGenericRecieveProc<BKeyData>;
    ThreadContext: TBThread = nil): IBKeyEventObserver;

  function CreateOpCodeEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBOpCodeEvent;
  function CreateOpCodeObserver(const OpCodeEvent: IBOpCodeEvent;
    OnRsvProc: TGenericRecieveProc<BOpCode>;
    ThreadContext: TBThread = nil): IBOpCodeEventObserver;

  function CreateResizeWindowEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBResizeWindowEvent;
  function CreateResizeWindowObserver(const ResizeWindowEvent: IBResizeWindowEvent;
    OnRsvProc: TGenericRecieveProc<BResizeEventData>;
    ThreadContext: TBThread = nil): IBResizeWindowEventObserver;

  function CreateEmptyTask(ThreadContext: TBThread = nil): IBEmptyTask;
  function CreateEmptyTaskObserver(const Task: IBEmptyTask; OnRsvProc: TGenericRecieveProc<byte>;
    ThreadContext: TBThread = nil): IBEmptyTaskObserver;

  function CreateFocusEvent(ThreadContext: TBThread = nil; ThreadSafe:
    boolean = false): IBFocusEvent;
  function CreateFocusObserver(const EmptyEvent: IBFocusEvent;
    OnRsvProc: TGenericRecieveProc<BFocusEventData>;
    ThreadContext: TBThread = nil): IBFocusEventObserver;

  function CreateDragDropEvent(ThreadContext: TBThread = nil; ThreadSafe:
    boolean = false): IBDragDropEvent;
  function CreateDragDropObserver(const DragDropEvent: IBDragDropEvent;
    OnRsvProc: TGenericRecieveProc<BDragDropData>;
    ThreadContext: TBThread = nil): IBDragDropEventObserver;

  function CreateChangeMvpEvent(ThreadContext: TBThread = nil; ThreadSafe:
    boolean = false): IBChangeMVPEvent;
  function CreateChangeMvpObserver(const ChangeMVPEvent: IBChangeMVPEvent;
    OnRsvProc: TGenericRecieveProc<BTransformData>;
    ThreadContext: TBThread = nil): IBChangeMVPEventObserver;


implementation

uses
  SysUtils
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  ;

type

  TBMouseEvent = class(TTemplateBEvent<BMouseData>, IBMouseEvent)
  private
    type
      TMouseItemQ = TItemQueue<BMouseData>;
      TMouseDataQ = TQueueTemplate<TMouseItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; X, Y, DeltaWeel: int32; Button: TBSMouseButtons; ShiftState: TBSShiftState);
  end;

  { TBKeyEvent }

  TBKeyEvent = class(TTemplateBEvent<BKeyData>, IBKeyObject)
  private
    type
      TKeyItemQ = TItemQueue<BKeyData>;
      TKeyDataQ = TQueueTemplate<TKeyItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; Key: Word; ShiftState: TBSShiftState);
  end;

  { TBWindowResizeEvent }

  TBWindowResizeEvent = class(TTemplateBEvent<BResizeEventData>, IBResizeWindowEvent)
  private
    type
      TWindResizeItemQ = TItemQueue<BResizeEventData>;
      TWindResizeDataQ = TQueueTemplate<TWindResizeItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Send(Instance: Pointer; NewWidth, NewHeight: int32;
      PercentWidthChange, PercentHeightChange: BSFloat);
  end;

  { TBEmptyEvent }

  TBEmptyEvent = class(TTemplateBEvent<BEmpty>, IBEmptyEvent)
  private
    type
      TEmptyItemQ = TItemQueue<BEmpty>;
      TEmptyDataQ = TQueueTemplate<TEmptyItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer);
  end;

  { TBMessageEvent }

  TBMessageEvent = class(TTemplateBEvent<BMessage>)
  private
    type
      TMsgItemQ = TItemQueue<BMessage>;
      TMsgDataQ = TQueueTemplate<TMsgItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
  end;

  { TBOpCodeEvent }

  TBOpCodeEvent = class(TTemplateBEvent<BOpCode>, IBOpCodeEvent)
  private
    type
      TOpCodeItemQ = TItemQueue<BOpCode>;
      TOpCodeDataQ = TQueueTemplate<TOpCodeItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; OpCode: int32; Data: NativeInt = -1; Data2: NativeInt = -1);
  end;

  { TEmptyTask }

  TEmptyTask = class(TTemplateBTask<byte>)
  private
    type
      TEmptyItemQ = TItemQueue<byte>;
      TEmptyDataQ = TQueueTemplate<TEmptyItemQ>;
  private
    LastTime: uint64;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Update; override;
  end;

  { TBFocusEvent }

  TBFocusEvent = class(TTemplateBEvent<BFocusEventData>, IBFocusEvent)
  private
    type
      TFocusItemQ = TItemQueue<BFocusEventData>;
      TFocusDataQ = TQueueTemplate<TFocusItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; Control: Pointer; Focused: boolean; ControlLevel: int32);
  end;

  { TBDragDropEvent }

  TBDragDropEvent = class(TTemplateBEvent<BDragDropData>, IBDragDropEvent)
  private
    type
      TDragDropItemQ = TItemQueue<BDragDropData>;
      TDragDropDataQ = TQueueTemplate<TDragDropItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; CheckDragParent: boolean);
  end;

  { TBChangeMvpEvent }

  TBChangeMvpEvent = class(TTemplateBEvent<BTransformData>, IBChangeMVPEvent)
  private
    type
      TTransformItemQ = TItemQueue<BTransformData>;
      TTransformDataQ = TQueueTemplate<TTransformItemQ>;
  protected
    class function GetQueueClass: TQueueWrapperClass; override;
    procedure Send(Instance: Pointer; MeshTransformed: boolean);
  end;

function MouseData(Instance: Pointer; X, Y, DeltaWeel: int32; Button: TBSMouseButtons; ShiftState: TBSShiftState): BMouseData;
begin
  Result.BaseHeader.Instance := Instance;
  Result.X := X;
  Result.Y := Y;
  Result.DeltaWeel := DeltaWeel;
  Result.Button := Button;
  Result.ShiftState := ShiftState;
end;

function KeyData(Instance: Pointer; Key: Word; Shift: TBSShiftState): BKeyData;
begin
  Result.BaseHeader.Instance := Instance;
  Result.Key := Key;
  Result.Shift := Shift;
end;

function CreateEmptyTask(ThreadContext: TBThread = nil): IBEmptyTask;
begin
  Result := TEmptyTask.Create(ThreadContext);
end;

function CreateEmptyTaskObserver(const Task: IBEmptyTask; OnRsvProc: TGenericRecieveProc<byte>;
  ThreadContext: TBThread = nil): IBEmptyTaskObserver;
begin
  Result := BObserver<byte>.Create(Task as IBEvent<byte>, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;


function CreateResizeWindowEvent(ThreadContext: TBThread = nil; ThreadSafe:
  boolean = false): IBResizeWindowEvent;
begin
  Result := TBWindowResizeEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateResizeWindowObserver(const ResizeWindowEvent: IBResizeWindowEvent;
  OnRsvProc: TGenericRecieveProc<BResizeEventData>;
  ThreadContext: TBThread = nil): IBResizeWindowEventObserver;
begin
  Result := BObserver<BResizeEventData>.Create(ResizeWindowEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateMouseEvent(ThreadContext: TBThread = nil; ThreadSafe:
  boolean = false): IBMouseEvent;
begin
  Result := TBMouseEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateMouseObserver(const MouseEvent: IBMouseEvent;
  OnRsvProc: TGenericRecieveProc<BMouseData>;
  ThreadContext: TBThread = nil): IBMouseEventObserver;
begin
  Result := BObserver<BMouseData>.Create(MouseEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateEmptyEvent(ThreadContext: TBThread = nil; ThreadSafe:
  boolean = false): IBEmptyEvent;
begin
  Result := TBEmptyEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateEmptyObserver(const EmptyEvent: IBEmptyEvent;
  OnRsvProc: TGenericRecieveProc<BEmpty>;
  ThreadContext: TBThread = nil): IBEmptyEventObserver;
begin
  Result := BObserver<BEmpty>.Create(EmptyEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateMessageEvent(ThreadContext: TBThread = nil; ThreadSafe:
    boolean = false): IBMessageEvent;
begin
  Result := TBMessageEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateMessageObserver(const MessageEvent: IBMessageEvent;
  OnRsvProc: TGenericRecieveProc<BMessage>;
  ThreadContext: TBThread = nil): IBMessageEventObserver;
begin
  Result := BObserver<BMessage>.Create(MessageEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateKeyEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBKeyObject;
begin
  Result := TBKeyEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateKeyObserver(const KeyEvent: IBKeyObject;
  OnRsvProc: TGenericRecieveProc<BKeyData>;
  ThreadContext: TBThread = nil): IBKeyEventObserver;
begin
  Result := BObserver<BKeyData>.Create(KeyEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateOpCodeEvent(ThreadContext: TBThread = nil; ThreadSafe:
  boolean = false): IBOpCodeEvent;
begin
  Result := TBOpCodeEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateOpCodeObserver(const OpCodeEvent: IBOpCodeEvent;
  OnRsvProc: TGenericRecieveProc<BOpCode>;
  ThreadContext: TBThread = nil): IBOpCodeEventObserver;
begin
  Result := BObserver<BOpCode>.Create(OpCodeEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateFocusEvent(ThreadContext: TBThread = nil; ThreadSafe:
  boolean = false): IBFocusEvent;
begin
  Result := TBFocusEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateFocusObserver(const EmptyEvent: IBFocusEvent;
  OnRsvProc: TGenericRecieveProc<BFocusEventData>;
  ThreadContext: TBThread = nil): IBFocusEventObserver;
begin
  Result := BObserver<BFocusEventData>.Create(EmptyEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateDragDropEvent(ThreadContext: TBThread; ThreadSafe: boolean): IBDragDropEvent;
begin
  Result := TBDragDropEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateDragDropObserver(const DragDropEvent: IBDragDropEvent; OnRsvProc: TGenericRecieveProc<BDragDropData>;
  ThreadContext: TBThread): IBDragDropEventObserver;
begin
  Result := BObserver<BDragDropData>.Create(DragDropEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateChangeMvpEvent(ThreadContext: TBThread = nil; ThreadSafe: boolean = false): IBChangeMVPEvent;
begin
  Result := TBChangeMvpEvent.Create(ThreadSafe, ThreadContext);
end;

function CreateChangeMvpObserver(const ChangeMVPEvent: IBChangeMVPEvent; OnRsvProc: TGenericRecieveProc<BTransformData>;
  ThreadContext: TBThread = nil): IBChangeMVPEventObserver;
begin
  Result := BObserver<BTransformData>.Create(ChangeMVPEvent, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;


{ TTemplateBTask<T> }

procedure TTemplateBTask<T>.AutoStop;
begin
  /// here is the executor side
  FIsRun := false;
  if Postn <> nil then
    TTaskExecutor.RemoveTask(Postn, ThreadContext);
  AutoStopTrap.Send(Self);
end;

constructor TTemplateBTask<T>.Create(ThreadContext: TBThread);
begin
  if ThreadContext = nil then
    inherited Create(true, NextExecutor)
  else
    inherited Create(true, ThreadContext);
  StartStopEvent := CreateOpCodeEvent(GUIThread, true);
  AutoStopTrap := CreateEmptyEvent(ThreadContext, true);
  ObserverStartStop := CreateOpCodeObserver(StartStopEvent, StartStop, ThreadContext);
  ObserverAutoStop := CreateEmptyObserver(AutoStopTrap, OnAutoStop, GUIThread);
end;

destructor TTemplateBTask<T>.Destroy;
begin
  //if FIsRun then
  //  Stop;
  if Postn <> nil then
  begin
    //raise Exception.Create('TTemplateBTask<T>.Destroy: task is running!');
    StartStopEvent.Send(Self, TASK_STOP);
    while Postn <> nil do
      sleep(16);
  end;
  ObserverStartStop := nil;
  ObserverAutoStop := nil;
  AutoStopTrap := nil;
  StartStopEvent := nil;
  inherited;
end;

function TTemplateBTask<T>.GetIntervalUpdate: int32;
begin
  Result := FIntervalUpdate;
end;

function TTemplateBTask<T>.GetIsRun: boolean;
begin
  Result := FIsRun;
end;

procedure TTemplateBTask<T>.OnAutoStop(const Value: BEmpty);
begin
  /// here is the GUI side
end;

procedure TTemplateBTask<T>.Run;
begin
  /// here is the GUI side
  if FIsRun then
    exit;
  StartStopEvent.Send(Self, TASK_START);
  if GUIThread <> ThreadContext then
  begin
    ThreadContext.ResetWaiting;
    while not FIsRun do
      sleep(16);
  end;
end;

procedure TTemplateBTask<T>.SetIntervalUpdate(Value: int32);
begin
  FIntervalUpdate := Value;
end;

procedure TTemplateBTask<T>.StartStop(const Value: BOpCode);
var
  p: PRecTask;
begin
  /// here is the executer side
  if Value.OpCode = TASK_START then
  begin
    FIsRun := true;
    if Postn <> nil then
      exit;
    Postn := TTaskExecutor.AddTask(Self as IUnknown, Update, ThreadContext);
  end else
  if Value.OpCode = TASK_STOP then
  begin
    FIsRun := false;
    if Postn = nil then
      exit;
    p := Postn;
    Postn := nil;
    TTaskExecutor.RemoveTask(p, ThreadContext);
  end;
end;

procedure TTemplateBTask<T>.Stop;
begin
  if not FIsRun then
    exit;
  /// here is the GUI side
  StartStopEvent.Send(Self, TASK_STOP);
  if GUIThread <> ThreadContext then
  begin
    ThreadContext.ResetWaiting;
    while FIsRun do
      sleep(16);
  end;
end;

{ TBMouseEvent }

class function TBMouseEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TMouseDataQ;
end;

procedure TBMouseEvent.Send(Instance: Pointer; X, Y, DeltaWeel: int32; Button: TBSMouseButtons; ShiftState: TBSShiftState);
var
  data: BMouseData;
begin
  data.BaseHeader.Instance := Instance;
  data.X := X;
  data.Y := Y;
  data.DeltaWeel := DeltaWeel;
  data.Button := Button;
  data.ShiftState := ShiftState;
  SendEvent(data);
end;

{ TBEmptyEvent }

class function TBEmptyEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TEmptyDataQ;
end;

procedure TBEmptyEvent.Send(Instance: Pointer);
var
  data: BData;
begin
  data.Instance := Instance;
  SendEvent(data);
end;

{ TBMessageEvent }

class function TBMessageEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TMsgDataQ;
end;

{ TBWindowResizeEvent }

class function TBWindowResizeEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TWindResizeDataQ;
end;

procedure TBWindowResizeEvent.Send(Instance: Pointer; NewWidth, NewHeight: int32; PercentWidthChange, PercentHeightChange: BSFloat);
var
  data: BResizeEventData;
begin
  data.BaseHeader.Instance := Instance;
  data.NewWidth := NewWidth;
  data.NewHeight := NewHeight;
  data.PercentWidthChange := PercentWidthChange;
  data.PercentHeightChange := PercentHeightChange;
  SendEvent(data);
end;

{ TBKeyEvent }

class function TBKeyEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TKeyDataQ;
end;

procedure TBKeyEvent.Send(Instance: Pointer; Key: Word; ShiftState: TBSShiftState);
var
  data: BKeyData;
begin
  data.BaseHeader.Instance := Instance;
  data.Key := Key;
  data.Shift := ShiftState;
  SendEvent(data);
end;

{ TBOpCodeEvent }

class function TBOpCodeEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TOpCodeDataQ;
end;

procedure TBOpCodeEvent.Send(Instance: Pointer; OpCode: int32; Data: NativeInt; Data2: NativeInt);
var
  d: BOpCode;
begin
  d.BaseHeader.Instance := Instance;
  d.OpCode := OpCode;
  d.Data := Data;
  d.Data2 := Data2;
  SendEvent(d);
end;

{ TTaskExecutor }

function TTaskExecutor.Add(const Task: IUnknown; TaskUpdateProc: TUpdateTaskProc): PRecTask;
begin
  new(Result);
  Result.Task := Pointer(Task);
  Result.Proc := TaskUpdateProc;
  Result.Pos := FTasks.PushToEnd(Result);
  Result.Deleted := false;
end;

procedure TTaskExecutor.AddAwaitTask(AAwaitTaskProc: TAwaitTaskProc; ATimeAwait: Cardinal; AData: Pointer);
var
  awaitTask: PAwaitTask;
begin
  new(awaitTask);
  awaitTask.Position := FAwaitTasks.PushToEnd(awaitTask);
  awaitTask.TimeAwait := ATimeAwait;
  awaitTask.TaskProc := AAwaitTaskProc;
  awaitTask.Data := AData;
  awaitTask.TimeStart := TBTimer.CurrentTime.Low;
end;

class function TTaskExecutor.AddTask(const ATask: IUnknown; ATaskUpdateProc: TUpdateTaskProc; AContext: TBThread): PRecTask;
var
  exec: TTaskExecutor;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TTaskExecutor.AddTask', (ATask as TObject).ClassName);
  {$endif}
  CS.Enter;
  try
    inc(FCountTasks);
    exec := GetExecuter(AContext);
    Result := exec.Add(ATask, ATaskUpdateProc);
  finally
    CS.Leave;
  end;
end;

class procedure TTaskExecutor.AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; AData: Pointer; ATimeAwait: Cardinal);
begin
  AwaitExecuteTask(AAwaitTaskProc, ATimeAwait, GUIThread, AData);
end;

class procedure TTaskExecutor.AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; AData: Pointer);
begin
  AwaitExecuteTask(AAwaitTaskProc, 0, GUIThread, AData);
end;

class procedure TTaskExecutor.AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc);
begin
  AwaitExecuteTask(AAwaitTaskProc, 0, GUIThread, nil);
end;

class procedure TTaskExecutor.AwaitExecuteTask(AAwaitTaskProc: TAwaitTaskProc; ATimeAwait: Cardinal; AContext: TBThread; AData: Pointer);
var
  exec: TTaskExecutor;
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TTaskExecutor.AwaitExecuteTask', '');
  {$endif}
  CS.Enter;
  try
    inc(FCountTasks);
    exec := GetExecuter(AContext);
    exec.AddAwaitTask(AAwaitTaskProc, ATimeAwait, AData);
  finally
    CS.Leave;
  end;
end;

class constructor TTaskExecutor.Create;
begin
  Executors := TListVec<TTaskExecutor>.Create;
  CS := TCriticalSection.Create;
end;

procedure TTaskExecutor.ClearFromTasks;
var
  it: PRecTask;
  awaitTask: PAwaitTask;
begin
  while FTasks.Count > 0 do
  begin
    it := FTasks.Pop;
    dispose(it);
  end;

  while FAwaitTasks.Count > 0 do
  begin
    awaitTask := FAwaitTasks.Pop;
    dispose(awaitTask);
  end;
end;

constructor TTaskExecutor.Create(AThreadContext: TBThread);
begin
  FThreadContext := AThreadContext;
  Executors.Items[AThreadContext.Index] := Self;
  AThreadContext.AddUpdateMethod(ProcessEvents);
  FTasks := TListTasks.Create;
  FAwaitTasks := TListAwaitTasks.Create;
end;

destructor TTaskExecutor.Destroy;
begin
  ClearFromTasks;
  FThreadContext.RemoveUpdateMethod(ProcessEvents);
  Executors.Items[FThreadContext.Index] := nil;
  FTasks.Free;
  FAwaitTasks.Free;
end;

class function TTaskExecutor.GetExecuter(AContext: TBThread): TTaskExecutor;
var
  context: TBThread;
begin
  if Assigned(AContext) then
    context := AContext
  else
    context := GUIThread;

  Result := Executors.Items[context.Index];
  if not Assigned(Result) then
    Result := TTaskExecutor.Create(context);
end;

class destructor TTaskExecutor.Destroy;
var
  i: int32;
begin
  for i := 0 to Executors.Count - 1 do
    if Assigned(Executors.Items[i]) then
      Executors.Items[i].Free;
  Executors.Free;
  CS.Free;
end;

function TTaskExecutor.ProcessEvents: boolean;
var
  it: TListTasks.PListItem;
  pit: PRecTask;
  awaitTaskIt: TListAwaitTasks.PListItem;
  awaitTask: PAwaitTask;
begin
  Result := FTasks.Count > 0;
  it := FTasks.ItemListFirst;
  while Assigned(it) do
  begin
    pit := it.Item;
    it := it.Next;
    if pit.Deleted then
    begin
      FTasks.Remove(pit.Pos);
      dispose(pit);
    end else
      pit.Proc();
  end;

  if not Result then
    Result := FAwaitTasks.Count > 0;

  awaitTaskIt := FAwaitTasks.ItemListFirst;
  while Assigned(awaitTaskIt) do
  begin
    awaitTask := awaitTaskIt.Item;
    awaitTaskIt := awaitTaskIt.Next;
    if TBTimer.CurrentTime.Low - awaitTask.TimeStart >= awaitTask.TimeAwait then
    begin
      FAwaitTasks.Remove(awaitTask.Position);
      awaitTask.TaskProc(awaitTask.Data);
      dispose(awaitTask);
    end;
  end;
end;

procedure TTaskExecutor.Remove(var TaskPos: PRecTask);
begin
  TaskPos.Deleted := true;
  TaskPos := nil;
end;

class procedure TTaskExecutor.RemoveTask(var TaskPos: PRecTask; Context: TBThread);
begin
  {$ifdef DEBUG_BS}
  BSWriteMsg('TTaskExecutor.RemoveTask', (IUnknown(TaskPos.Task) as TObject).ClassName);
  {$endif}
  CS.Enter;
  try
    dec(FCountTasks);
    Executors.Items[Context.Index].Remove(TaskPos);
  finally
    CS.Leave;
  end;
  FLastTimeRemoveTask := TBTimer.CurrentTime.Counter;
end;

{ TEmptyTask }

class function TEmptyTask.GetQueueClass: TQueueWrapperClass;
begin
  Result := TEmptyDataQ;
end;

procedure TEmptyTask.Update;
var
  t: uint64;
begin
  t := TBTimer.CurrentTime.Counter;
  if (not IsRun) or (FIntervalUpdate > t - LastTime) then
  	exit;
  LastTime := t;
  SendEvent(0);
end;

{ TBFocusEvent }

class function TBFocusEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TFocusDataQ;
end;

procedure TBFocusEvent.Send(Instance: Pointer; Control: Pointer; Focused: boolean; ControlLevel: int32);
var
  data: BFocusEventData;
begin
  data.BaseHeader.Instance := Instance;
  data.Control := Control;
  data.Focus := Focused;
  data.ControlLevel := ControlLevel;
  SendEvent(data);
end;

{ TBDragDropEvent }

class function TBDragDropEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TDragDropDataQ;
end;

procedure TBDragDropEvent.Send(Instance: Pointer; CheckDragParent: boolean);
var
  data: BDragDropData;
begin
  data.BaseHeader.Instance := Instance;
  data.CheckDragParent := CheckDragParent;
  SendEvent(data);
end;

{ TBChangeMvpEvent }

class function TBChangeMvpEvent.GetQueueClass: TQueueWrapperClass;
begin
  Result := TTransformDataQ;
end;

procedure TBChangeMvpEvent.Send(Instance: Pointer; MeshTransformed: boolean);
var
  data: BTransformData;
begin
  data.BaseHeader.Instance := Instance;
  data.MeshTransformed := MeshTransformed;
  SendEvent(data);
end;

end.
