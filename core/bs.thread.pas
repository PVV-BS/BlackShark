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


unit bs.thread;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  {$ifdef FMX}
  , FMX.Types
  {$else}
  {$endif}
  , syncobjs
  , bs.collections
  ;


type

  TBThread = class;
  TQueueDispatcher = class;
  TQueueWrapper = class;

  TQueueWrapperClass = class of TQueueWrapper;

  TUntypedRecieveProc = procedure (var Value) of object;
  TGenericRecieveProc<T> = procedure (const Value: T) of object;

  { one thread (owner) asking List is not locking its, any other can add and
    delete items; it is not protected from sequential invoke Add and Del }
  TSafeNotLockedList<T> = class
  private
    //type
    //  TStatusItem = (siNew, siWorking, stDeleting);
  private
    NewItems: TSingleList<T>.TSingleListHead;
    DeletedItems: TSingleList<T>.TSingleListHead;
    List: TSingleList<T>.TSingleListHead;
    CS: TCriticalSection;
    FNeedManage: boolean;
  protected
    { only for owner }
    procedure Manage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Item: T);
    procedure Del(const Item: T);
    property NeedManage: boolean read FNeedManage;
  end;

  TListDQueues = TListDual<TQueueWrapper>;

  TQueueFate = (qfNew, qfWorking, qfDeleting);

  TQueueWrapper = class abstract
  private
    _References: int32;
    Position: TListDQueues.PListItem;
    QueueFate: TQueueFate;
  protected
    FReciever: TUntypedRecieveProc;
    FDispatcher: TQueueDispatcher;
    FHasData: boolean;
    FSrcThr: TBThread;

    procedure Process; virtual; abstract;
    function _Release: int32;
    procedure _AddRef;
  public
    constructor Create(AReciever: TUntypedRecieveProc; ADispatcher: TQueueDispatcher; ASrcThr: TBThread); virtual;
    property SrcThr: TBThread read FSrcThr;
    property Dispatcher: TQueueDispatcher read FDispatcher;
  end;

  TQueueTemplate<T> = class(TQueueWrapper)
  private
    FQueue: TQueueFIFO<T>;
    { invoke from source; ! do not use for ask queues !;
      only for notify about contains of data in queue }
    procedure OnWrite(Source: TQueueFIFO<T>);
  protected
    { the callback invoked by FSrcThr for ask all queues (a recieve of data) }
    procedure Process; override;
  public
    constructor Create(AReciever: TUntypedRecieveProc; ADispatcher: TQueueDispatcher; ASrcThr: TBThread); override;
    destructor Destroy; override;
    property Queue: TQueueFIFO<T> read FQueue;
  end;

  TQueueDispatcher = class
  private
    FThreadOwner: TBThread;
    NewQueues: TListVec<TQueueWrapper>;
    DeletedQueues: TListVec<TQueueWrapper>;
    WorkingQueues: TListDQueues;
    FQueuesHaveData: boolean;
    procedure ManageQueues; inline;
    function GetCountQueues: int32;
  protected
    function ProcessQueues: boolean;
  public
    constructor Create(AThreadOwner: TBThread);
    destructor Destroy; override;
    procedure OnWrite({%H-}Source: TQueueWrapper);
    function GetQueueForWrite(SrcThr: TBThread; QueueClass: TQueueWrapperClass;
      RecieveFunc: TUntypedRecieveProc): TQueueWrapper;
    procedure RemoveQueue(Queue: TQueueWrapper);
    property CountQueues: int32 read GetCountQueues;
    property QueuesHaveData: boolean read FQueuesHaveData;
  end;

  PTimeCounter = ^TTimeCounter;
  TTimeCounter = record
    case boolean of
      false: (Low: uint32; High: uint32);
      true : (Counter: uint64);
  end;

  { TBThread

    Wrapper above TThread; if to constructor to translate AAsFiction = true, then
    TThread doesn't create; it is made for use the class-template for events are
    working only on user side (GUI); all events generated in a some
    TBThread-context broadcast between the contexts

   }

  TBThread = class
  public
    type
      { function must return true if need to next iteration }
      TProcessUpdate = function: boolean of object;
      TListUpdateMethods = TSingleList<TProcessUpdate>;
      THeadListUpdateMethods = TListUpdateMethods.TSingleListHead;
  private
    const
      DEFAULT_PERIOD_UPDATE = 16; // 16 ms = 1/60 second
    type
      TThreadStarter = class(TThread)
      private
        FMaster: TBThread;
      protected
        procedure Execute; override;
      public
        constructor Create(AMaster: TBThread; ACreateSuspended: Boolean = false);
      end;
  private
    { timer for process events, if created with AsTimer = true}
    Thread: TThreadStarter;
    FPeriodUpdate: int32;
    LastTimeSleep: uint64;
    Stoped: boolean;
    StackProcessUpdate: TSafeNotLockedList<TProcessUpdate>;
    FCaption: string;
    FIndex: int32;
    FQueueDispatcher: TQueueDispatcher;
    FAsFiction: boolean;
    CS: syncobjs.TCriticalSection;
    Event: TEvent;
    LastTimeSetEvent: uint64;
    procedure Execute;
    function ProcessEvents: boolean; //inline;
    procedure SetPeriodUpdate(const Value: int32);
    function GetTerminated: boolean;
    function TryLock: boolean;
    procedure DoWaiting(AValue: boolean); inline;
  protected
    function DoExecute: boolean; //inline;
    procedure Stop;
  public
    constructor Create(AAsFiction: boolean = false; ACreateSuspended: Boolean = false);
    destructor Destroy; override;
    procedure AddUpdateMethod(AProcessUpdate: TProcessUpdate);
    procedure RemoveUpdateMethod(AProcessUpdate: TProcessUpdate);
    procedure Lock;
    procedure UnLock;

    { returns true if one or more of queues is not empty yet }
    function Clear: boolean; virtual;
    procedure Terminate;
    procedure ResetWaiting;

    class function GetCPUCount: int32;

    property PeriodUpdate: int32 read FPeriodUpdate write SetPeriodUpdate;
    property AsFiction: boolean read FAsFiction;
    property Caption: string read FCaption write FCaption;
    property Terminated: boolean read GetTerminated;
    property QueueDispatcher: TQueueDispatcher read FQueueDispatcher;
    property Index: int32 read FIndex;
  end;

  { TGUIThread

    a main thread events processing on the side of GUI;
    singleton, raises an exception if try to create more 1; any kind of an
    application must invoke OnIdleApplication with speed able to support
    processing of events on a decent level

    }

  TGUIThread = class(TBThread)
  private

  public
    constructor Create({%H-}AAsFiction: boolean = false; ACreateSuspended: Boolean = false);
    function OnIdleApplication: boolean;
  end;

  { TThreadTimer }

  TBTimer = class
  private
    class var FCurrentTime: TTimeCounter;
    class function GetCurrentTime: TTimeCounter; static;
  public
    class procedure UpdateTimer(var Timer: TTimeCounter); inline;
    class property CurrentTime: TTimeCounter read GetCurrentTime;
  end;

  function NextExecutor: TBThread;
  function CountExecutors: int32;
  function GetExecutor(Index: int32): TBThread;

var
  GUIThread: TGUIThread;

implementation

uses
  {$ifdef MSWindows}
    Windows,
  {$else}

  {$endif}
    bs.config
  ;
var
  g_ThreadIndex: int32 = 0;
  g_CurrentAnimatorIndex: int32 = 0;
  g_CountAnimators: int32 = 0;
  g_Animators: array of TBThread;

function CountExecutors: int32;
begin
  Result := g_CountAnimators;
end;

function GetExecutor(Index: int32): TBThread;
begin
  if Index < g_CountAnimators then
    Result := g_Animators[Index]
  else
    Result := nil;
end;

function NextExecutor: TBThread;
begin
  Result := g_Animators[g_CurrentAnimatorIndex];
  inc(g_CurrentAnimatorIndex);
  g_CurrentAnimatorIndex := g_CurrentAnimatorIndex mod g_CountAnimators;
end;

procedure CreateThreads;
var
  cpu_count: int32;
  i: int32;
begin
  GUIThread := TGUIThread.Create(true);

  if BSConfig.UseTaskExecutersSet then
    cpu_count := TBThread.GetCPUCount
  else
    cpu_count := 1;

  if cpu_count > 1 then
    g_CountAnimators := cpu_count - 1
  else
    g_CountAnimators := 1;

  g_CurrentAnimatorIndex := 0;
  SetLength(g_Animators, g_CountAnimators);

  g_Animators[0] := GUIThread;
  for i := 1 to g_CountAnimators - 1 do
  begin
    g_Animators[i] := TBThread.Create;
    g_Animators[i].Caption := string('Animator №') + IntToStr(i);
  end;
end;

procedure FreeThreads;
var
  ok: boolean;
  i: int32;
begin

  for i := 1 to g_CountAnimators - 1 do
    g_Animators[i].Stop;

  GUIThread.Stop;

  repeat

    ok := true;
    for i := 1 to g_CountAnimators - 1 do
      if g_Animators[i].Clear then
      begin
        ok := false;
        sleep(1);
      end;

    if GUIThread.Clear then
      ok := false;

  until ok;


  for i := 1 to g_CountAnimators - 1 do
    g_Animators[i].Free;

  SetLength(g_Animators, 0);
  g_CountAnimators := 0;

  GUIThread.Free;

end;

function GetNextIndex: int32;
begin
  {$ifdef FPC}
  Result := InterLockedIncrement(g_ThreadIndex);
  {$else}
  Result := AtomicIncrement(g_ThreadIndex);
  {$endif}
end;

{ TBTimer }

class function TBTimer.GetCurrentTime: TTimeCounter;
begin
  UpdateTimer(FCurrentTime);
  Result := FCurrentTime;
end;

class procedure TBTimer.UpdateTimer(var Timer: TTimeCounter);
{$ifndef FPC}
var
  t: uint32;
{$endif}
begin
  {$ifdef FPC}
    Timer.Counter := TThread.GetTickCount64;
  {$else}
    t := TThread.GetTickCount;
    if Timer.Low > t then
      inc(Timer.High);
    Timer.Low := t;
  {$endif}
end;

{ TBThread }

procedure TBThread.Lock;
begin
  CS.Enter;
end;

procedure TBThread.UnLock;
begin
  CS.Leave;
end;

procedure TBThread.AddUpdateMethod(AProcessUpdate: TProcessUpdate);
begin
  StackProcessUpdate.Add(AProcessUpdate);
  if (not Assigned(Thread) and (MainThreadID = TThread.CurrentThread.ThreadID)) or (Assigned(Thread) and (Thread.ThreadID = TThread.CurrentThread.ThreadID)) then
    StackProcessUpdate.Manage
  else
  begin
    while StackProcessUpdate.NeedManage do
      sleep(10);
  end;
end;

procedure TBThread.Execute;
begin
  repeat
    DoExecute;
  until Thread.Terminated;
  Stoped := true;
end;

class function TBThread.GetCPUCount: int32;
{$ifdef MSWindows}
var
  si: TSystemInfo;
begin
  GetSystemInfo(si{%H-});
  Result := si.dwNumberOfProcessors;
end;
{$else}
begin
  Result := TThread.ProcessorCount;
end;
{$endif}

function TBThread.GetTerminated: boolean;
begin
  Result := ((Thread <> nil) and (Thread.Terminated));
end;

function TBThread.ProcessEvents: boolean;
var
  i: int32;
begin
  Result := false;
  { invoke update methods }
  if StackProcessUpdate.FNeedManage then
    StackProcessUpdate.Manage;
  for i := StackProcessUpdate.List.Count - 1 downto 0 do
    if StackProcessUpdate.List.Items[i]() then
      Result := true;
  if FQueueDispatcher.QueuesHaveData then
  begin
    Result := true;
    FQueueDispatcher.ProcessQueues;
  end;
end;

procedure TBThread.RemoveUpdateMethod(AProcessUpdate: TProcessUpdate);
begin
  StackProcessUpdate.Del(AProcessUpdate);
  if (not Assigned(Thread) and (MainThreadID = TThread.CurrentThread.ThreadID)) or (Assigned(Thread) and (Thread.ThreadID = TThread.CurrentThread.ThreadID)) then
    StackProcessUpdate.Manage
  else
    while StackProcessUpdate.NeedManage do
    begin
      ResetWaiting;
      sleep(10);
    end;
end;

procedure TBThread.ResetWaiting;
begin
  if Assigned(Event) then
  begin
    DoWaiting(false);
  end;
end;

procedure TBThread.SetPeriodUpdate(const Value: int32);
begin
  FPeriodUpdate := Value;
end;

constructor TBThread.Create(AAsFiction: boolean; ACreateSuspended: Boolean);
begin
  FIndex := GetNextIndex;
  StackProcessUpdate := TSafeNotLockedList<TProcessUpdate>.Create;
  FQueueDispatcher := TQueueDispatcher.Create(Self);
  FPeriodUpdate := DEFAULT_PERIOD_UPDATE;
  FAsFiction := AAsFiction;
  Stoped := false;
  CS := syncobjs.TCriticalSection.Create;
  if not FAsFiction then
  begin
    Event := TEvent.Create(nil, true, false, '');
    Thread := TThreadStarter.Create(self, false);
  end;
  LastTimeSetEvent := TBTimer.CurrentTime.Counter;
end;

destructor TBThread.Destroy;
begin
  FQueueDispatcher.ManageQueues;
  if Assigned(Thread) then
    Stop;
  Thread.Free;
  Event.Free;
  StackProcessUpdate.Free;
  CS.Free;
  FQueueDispatcher.Free;
  inherited Destroy;
end;

function TBThread.DoExecute: boolean;
begin
  if not ProcessEvents then
  begin  // no events
    Result := false;
    if TBTimer.CurrentTime.Counter - LastTimeSleep > 128 then
    begin
      //Sleep(FPeriodUpdate);
      if not FAsFiction then
        DoWaiting(true);
      LastTimeSleep := TBTimer.CurrentTime.Counter;
    end;
  end else
    Result := true;
end;

procedure TBThread.DoWaiting(AValue: boolean);
begin
  if AValue then
  begin
    if (TBTimer.CurrentTime.Counter - LastTimeSetEvent < FPeriodUpdate) or not TryLock then
      exit;
    Event.ResetEvent;
    UnLock;
    Event.WaitFor(INFINITE);
  end else
  begin
    Lock;
    Event.SetEvent;
    UnLock;
    LastTimeSetEvent := TBTimer.CurrentTime.Counter;
  end;
end;

procedure TBThread.Stop;
begin
  if not FAsFiction and Assigned(Thread) then
  begin
    while not Stoped do
    begin
      DoWaiting(false);
      Thread.Terminate;
    end;
    Thread.WaitFor;
    FreeAndNil(Thread);
  end;
end;

function TBThread.Clear: boolean;
begin
  Result := FQueueDispatcher.QueuesHaveData;
  while ProcessEvents and FQueueDispatcher.QueuesHaveData do;
end;

procedure TBThread.Terminate;
begin
  if Thread <> nil then
    Thread.Terminate;
end;

function TBThread.TryLock: boolean;
begin
  Result := CS.TryEnter;
  //if Result then
  //  Wait;
end;

{ TBThread.TThreadStarter }

constructor TBThread.TThreadStarter.Create(AMaster: TBThread; ACreateSuspended: Boolean);
begin
  inherited Create(ACreateSuspended);
  FMaster := AMaster;
end;

procedure TBThread.TThreadStarter.Execute;
begin
  FMaster.Execute;
end;

{ TQueueDispatcher }

constructor TQueueDispatcher.Create(AThreadOwner: TBThread);
begin
  FThreadOwner := AThreadOwner;
  NewQueues := TListVec<TQueueWrapper>.Create(@PtrCmp);
  DeletedQueues := TListVec<TQueueWrapper>.Create;
  WorkingQueues := TListDQueues.Create;
end;

destructor TQueueDispatcher.Destroy;
begin
  ManageQueues;
  while WorkingQueues.Count > 0 do
    WorkingQueues.Pop.Free;
  NewQueues.Free;
  DeletedQueues.Free;
  WorkingQueues.Free;
  inherited;
end;

function TQueueDispatcher.GetCountQueues: int32;
begin
  Result := WorkingQueues.Count + NewQueues.Count - DeletedQueues.Count;
end;

function TQueueDispatcher.GetQueueForWrite(SrcThr: TBThread;
  QueueClass: TQueueWrapperClass;
  RecieveFunc: TUntypedRecieveProc): TQueueWrapper;
var
  it: TListDQueues.PListItem;
  i: int32;
begin
  FThreadOwner.Lock;
  try
    it := WorkingQueues.ItemListFirst;
    while it <> nil do
    begin
      Result := it.Item;
      if (Result.QueueFate <> qfDeleting) and (Result.FSrcThr = SrcThr) and (Result.ClassType = QueueClass) and
        (@RecieveFunc = @Result.FReciever) then
      begin
          Result._AddRef;
          exit;
      end;
      it := it.Next;
    end;

    for i := 0 to NewQueues.Count - 1 do
    begin
      Result := NewQueues.Items[i];
      if (Result.FSrcThr = SrcThr) and (Result.ClassType = QueueClass) and
        (@RecieveFunc = @Result.FReciever) then
      begin
          Result._AddRef;
          exit;
      end;
    end;

    Result := QueueClass.Create(RecieveFunc, Self, SrcThr);
    NewQueues.Add(Result);
    Result.QueueFate := qfNew;
  finally
    FThreadOwner.UnLock;
  end;
end;

procedure TQueueDispatcher.ManageQueues;
var
  i: int32;
  q: TQueueWrapper;
begin

  for i := 0 to NewQueues.Count - 1 do
  begin
    q := NewQueues.Items[i];
    q.Position := WorkingQueues.PushToEnd(q);
    q.QueueFate := qfWorking;
  end;

  NewQueues.Count := 0;

  for i := 0 to DeletedQueues.Count - 1 do
  begin
    WorkingQueues.Remove(DeletedQueues.Items[i].Position);
    DeletedQueues.Items[i].Free;
  end;

  DeletedQueues.Count := 0;

end;

procedure TQueueDispatcher.OnWrite(Source: TQueueWrapper);
begin
  FQueuesHaveData := true;
end;

function TQueueDispatcher.ProcessQueues: boolean;
var
  it: TListDQueues.PListItem;
begin

  if not FQueuesHaveData then
    exit(false);

  if (NewQueues.Count > 0) or (DeletedQueues.Count > 0) then
  begin
    FThreadOwner.Lock;
    try
      ManageQueues;
    finally
      FThreadOwner.UnLock;
    end;
  end;

  FQueuesHaveData := false;
  Result := true;
  it := WorkingQueues.ItemListFirst;
  while it <> nil do
  begin
    it.Item.Process;
    it := it.Next;
  end;
end;

procedure TQueueDispatcher.RemoveQueue(Queue: TQueueWrapper);
begin
  FThreadOwner.Lock;
  try

    if Queue._Release = 0 then
    begin
      if Queue.QueueFate = qfDeleting then
        exit;

      if Queue.QueueFate = qfNew then
      begin
        NewQueues.Remove(Queue);
        Queue.Free;
        exit;
      end;

      Queue.QueueFate := qfDeleting;
      DeletedQueues.Add(Queue);

    end;

  finally
    FThreadOwner.UnLock;
  end;
end;

{ TQueueWrapper }

constructor TQueueWrapper.Create(AReciever: TUntypedRecieveProc; ADispatcher: TQueueDispatcher; ASrcThr: TBThread);
begin
  FReciever := AReciever;
  FDispatcher := ADispatcher;
  FSrcThr := ASrcThr;
  _References := 1;
end;

procedure TQueueWrapper._AddRef;
begin
  inc(_References);
end;

function TQueueWrapper._Release: int32;
begin
  dec(_References);
  Result := _References;
end;

{ TQueueTemplate<T> }

constructor TQueueTemplate<T>.Create(AReciever: TUntypedRecieveProc; ADispatcher: TQueueDispatcher; ASrcThr: TBThread);
begin
  inherited;
  { do not use async mode, because it leds to dead lock }
  FQueue := TQueueFIFO<T>.Create(ASrcThr);
  FQueue.OnWrite := OnWrite;
end;

destructor TQueueTemplate<T>.Destroy;
begin
  FQueue.Free;
  inherited;
end;

procedure TQueueTemplate<T>.OnWrite(Source: TQueueFIFO<T>);
begin
  FHasData := true;
  FDispatcher.OnWrite(Self);
end;

procedure TQueueTemplate<T>.Process;
var
  val: T;
begin
  FHasData := false;
  while FQueue.Count > 0 do
  begin
    val := FQueue.Pop;
    FReciever(val);
  end;
end;

{ TSafeNotLockedList<T> }

procedure TSafeNotLockedList<T>.Add(const Item: T);
begin
  CS.Enter;
  try
    FNeedManage := true;
    TSingleList<T>.Add(NewItems, T(Item));
  finally
    CS.Leave;
  end;
end;

constructor TSafeNotLockedList<T>.Create;
begin
  CS := syncobjs.TCriticalSection.Create;
end;

procedure TSafeNotLockedList<T>.Del(const Item: T);
begin
  CS.Enter;
  try
    FNeedManage := true;
    TSingleList<T>.Add(DeletedItems, Item);
  finally
    CS.Leave;
  end;
end;

destructor TSafeNotLockedList<T>.Destroy;
begin
  CS.Free;
  inherited;
end;

procedure TSafeNotLockedList<T>.Manage;
var
  i: int32;
begin
  CS.Enter;
  try
    FNeedManage := false;
    for i := 0 to DeletedItems.Count - 1 do
    begin
      TSingleList<T>.Delete(List, DeletedItems.Items[i]);
    end;
    DeletedItems.Count := 0;
    for i := 0 to NewItems.Count - 1 do
    begin
      TSingleList<T>.Add(List, NewItems.Items[i]);
    end;
    NewItems.Count := 0;
  finally
    CS.Leave;
  end;
end;

{ TGUIThread }

constructor TGUIThread.Create(AAsFiction: boolean; ACreateSuspended: Boolean);
begin
  inherited Create(true, ACreateSuspended);
  Assert(GUIThread = nil, 'TGUIThread has already been created!');
end;

function TGUIThread.OnIdleApplication: boolean;
begin
  Result := DoExecute;
end;

initialization
  CreateThreads;

finalization
  FreeThreads;

end.

