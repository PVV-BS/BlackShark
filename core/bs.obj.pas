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


{
<summary>
  The unit implements events system based on observer pattern:
  https://en.wikipedia.org/wiki/Observer_pattern
</summary>
}

{$I BlackSharkCfg.inc}

unit bs.obj;

interface

uses
    syncobjs
  , bs.collections
  , bs.thread
  ;

type

  IBObserver<T> = interface
    ['{2796F25B-26F6-4212-89F0-C7F2DA47BDD2}']
    { its context in which it recieves data }
    function ThreadContext: TBThread;
    { it setter reciever into descendant }
    procedure SetOnRecieveData(GenericReciever: TGenericRecieveProc<T>);
    function GetOnRecieveData: TGenericRecieveProc<T>;
    property OnRecieveData: TGenericRecieveProc<T> read GetOnRecieveData write SetOnRecieveData;
  end;

  IBConnection<T> = interface
    ['{498860E3-35C6-4D93-AD37-3537FE85B71F}']
    { send event from side IBEvent to all IBObserver }
    procedure SendEvent(const Value: T);
    { untyped reciever on side IBObserver }
    procedure Recieve(var Value);
    { is observer alive? }
    function  RefExists: boolean;
    function  RefObserver: IBObserver<T>;
    { remove ref to observer; invoke only observer when its released }
    procedure RefDel;
  end;

  IBEvent<T> = interface
    ['{99A468DD-656B-404A-BABE-F1F3139C26C8}']
    { generator an event of the object }
    procedure SendEvent(const Value: T);
    { subscribe for accepting events the object into Observer.AcceptEvent }
    function  Connect(const Observer: IBObserver<T>): IBConnection<T>;
    { create a simple observer and connect its to the event }
    function  CreateObserver(ThreadCntx: TBThread; OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;
    function  CreateObserver(OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;
    function  ThreadContext: TBThread;
    function  References: int32;
  end;

  TItemConnection<T> = record
    Connection: IBConnection<T>;
  end;

  TItemQueue<T> = record
    { ! Importantly ! do not swap with Value; the trick allows to translate data
      from untyped to generic }
    Connection: TItemConnection<T>;
    Value: T;
  end;

  { BObserver<T>
    is a thread-safe reciever events from IBEvent<T> belonging any thread }

  BObserver<T> = class (TInterfacedObject, IBObserver<T>)
  private
    Connection: IBConnection<T>;
    FThreadContext: TBThread;
  protected
    FReciever: TGenericRecieveProc<T>;
    //procedure Recieve(const Value: T);
 public
    constructor Create(AEvent: IBEvent<T>; AThreadContext: TBThread = nil);
    destructor Destroy; override;
    function ThreadContext: TBThread;
    function GetOnRecieveData: TGenericRecieveProc<T>;
    procedure SetOnRecieveData(GenericReciever: TGenericRecieveProc<T>);
  end;

  { TTemplateBEvent<T>
    is source of T data, or events }

  TTemplateBEvent<T> = class(TInterfacedObject, IBEvent<T>)
  public
    type

      TConnection = class;
      TArrayConnections = array of IBConnection<T>;

      TListConnections = class(TListDual<TConnection>)
      private
        CS: TCriticalSection;
        _Owners: int32;
        { this method is invoked only by owner (TTemplateBEvent<T>); the object
          (TListConnections) do not dispose while (Count > 0 or live owner) }
        procedure _DecOwners;
        function ArrConDo: TArrayConnections; inline;
      public
        constructor Create(ThreadSafe: boolean);
        destructor Destroy; override;
        procedure Lock;
        procedure Add(Connection: TConnection);
        procedure Delete(Connection: TConnection);
        procedure Unlock;
        function ArrCon: TArrayConnections;
      end;

      TListItem = TListConnections.PListItem;

      { b/w an observer (IBObserver<T>) and some object (IBEvent<T>)
        async connection; sync connection leds to dead locks }
      TConnection = class(TInterfacedObject, IBConnection<T>)
      public
        type
          TItemQ = TItemQueue<T>;
          TQueue = TQueueTemplate<TItemQ>;
      private
        Observer: BObserver<T>;
        Owner: TListConnections;
        Pos: TListItem;
        Queue: TQueue;
        FThreadSafe: boolean;
      protected
        procedure Recieve(var Value);
      public
        constructor Create(const AObserver: BObserver<T>;
          AOwner: TListConnections; ThreadSource: TBThread;
          QueueClass: TQueueWrapperClass);
        destructor Destroy; override;
        procedure  SendEvent(const Value: T);
        function   RefExists: boolean;
        function   RefObserver: IBObserver<T>;
        procedure  RefDel;
        property   ThreadSafe: boolean read FThreadSafe;
      end;

  private
    Observers: TListConnections;
    FThreadContext: TBThread;
  protected
    { generator an event of the object }
    procedure SendEvent(const Value: T);
    class function GetQueueClass: TQueueWrapperClass; virtual; abstract;
  public
    constructor Create(ThreadSafe: boolean; ThreadContext: TBThread = nil);
    destructor Destroy; override;
    { subscribe for accepting events the object into Observer.AcceptEvent }
    function Connect(const Observer: IBObserver<T>): IBConnection<T>;
    { create a simple observer and connect its to the event }
    function CreateObserver(ThreadCntx: TBThread; OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;
    function CreateObserver(OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;
    function ThreadContext: TBThread;
    function References: int32;
  end;

  { BObserversGroup

    The group allows to have one reciever for set of events; of course, type of
    reciever and events must be the same; the time of observing determined by the
    life time of the group or life time of Handle is accepting by CreateObserver
  }

  BObserversGroup<T> = class
  private
  type
    BObserverGrouped = class;

    TBObserver = IBObserver<T>;
    TListGoupedObsrv = TListDual<TBObserver>;

    BObserverGrouped = class(BObserver<T>)
    private
      Postn: TListGoupedObsrv.PListItem;
      FGroup: BObserversGroup<T>;
    public
      constructor Create(AEvent: IBEvent<T>; AGroup: BObserversGroup<T>);
      destructor Destroy; override;
    end;

  private
    Observers: TListGoupedObsrv;
    Reciever: TGenericRecieveProc<T>;
    Thread: TBThread;
    function Add(const Observer: IBObserver<T>): TListGoupedObsrv.PListItem;
    procedure Remove(Position: TListGoupedObsrv.PListItem);
    function GetCountObservers: int32;
  public
    constructor Create(ATheadContext: TBThread; AReciever: TGenericRecieveProc<T>); overload;
    constructor Create(AReciever: TGenericRecieveProc<T>); overload;
    destructor Destroy; override;
    { unnecessarily remember result; if you want dynamically to create and to
      remove observers then you need to remember result; for deleting observer
      you need to use RemoveObserver (see below) }
    function CreateObserver(Event: IBEvent<T>): Pointer;
    { removes an observer; Handle is a value given by CreateObserver }
    procedure RemoveObserver(var Handle: Pointer);
    { removes all observers }
    procedure Clear;
    property CountObservers: int32 read GetCountObservers;
  end;

  TTimeProcessEvent = class
  private
    class constructor Create;
  public
    class var TimeProcessEvent: TTimeCounter;
  end;

function GetReciever(Thread: TBThread): TUntypedRecieveProc;

implementation

uses
    SysUtils
  , Classes
  ;

type
  TThreadReciever = class
  private
    FThread: TBThread;
    procedure OnRecieve(var Value);
  public
    constructor Create(AThread: TBThread);
    destructor Destroy; override;
  end;

var
  g_Recievers: TListVec<TThreadReciever>;

function GetReciever(Thread: TBThread): TUntypedRecieveProc;
var
  res: TThreadReciever;
begin
  res := g_Recievers.Items[Thread.Index];
  if res = nil then
  begin
    res := TThreadReciever.Create(Thread);
    g_Recievers.Items[Thread.Index] := res;
  end;

  Result := res.OnRecieve;
end;

procedure FreeRecievers;
var
  i: int32;
begin
  for i := 0 to g_Recievers.Count - 1 do
    g_Recievers.Items[i].Free;
  g_Recievers.Count := 0;
end;

{ TTemplateBEvent<T>.TConnection }

constructor TTemplateBEvent<T>.TConnection.Create(const AObserver: BObserver<T>;
  AOwner: TListConnections; ThreadSource: TBThread;
  QueueClass: TQueueWrapperClass);
begin
  Owner := AOwner;
  Observer := AObserver;
  Owner.Add(Self);
  if ThreadSource <> AObserver.ThreadContext then
  begin
    FThreadSafe := true;
    Queue := TQueue(AObserver.ThreadContext.QueueDispatcher.GetQueueForWrite(
      ThreadSource, QueueClass, GetReciever(AObserver.ThreadContext)));
  end;
end;

destructor TTemplateBEvent<T>.TConnection.Destroy;
begin
  Observer := nil;
  if Assigned(Queue) then
    Queue.Dispatcher.RemoveQueue(Queue);
  Owner.Delete(Self);
  inherited;
end;

procedure TTemplateBEvent<T>.TConnection.Recieve(var Value);
begin
  if Assigned(Observer) then
    Observer.FReciever(TItemQueue<T>(Value).Value);
  TItemQueue<T>(Value).Connection.Connection := nil;
end;

procedure TTemplateBEvent<T>.TConnection.RefDel;
begin
  Observer := nil;
end;

function TTemplateBEvent<T>.TConnection.RefExists: boolean;
begin
  Result := Assigned(Observer);
end;

function TTemplateBEvent<T>.TConnection.RefObserver: IBObserver<T>;
begin
  Result := IBObserver<T>(Observer);
end;

procedure TTemplateBEvent<T>.TConnection.SendEvent(const Value: T);
var
  val: TItemQueue<T>;
begin
  if Assigned(Queue) then
  begin
    val.Value := Value;
    val.Connection.Connection := Self;
    Queue.Queue.Push(val);
  end else
  if Assigned(Observer) then
    Observer.FReciever(Value);
end;

{ TTemplateBEvent<T> }

function TTemplateBEvent<T>.Connect(const Observer: IBObserver<T>): IBConnection<T>;
var
  con: TConnection;
begin
  con := TConnection.Create(Pointer(Observer as TObject), Observers, FThreadContext, GetQueueClass);
  Result := con as IBConnection<T>;
end;

constructor TTemplateBEvent<T>.Create(ThreadSafe: boolean; ThreadContext: TBThread = nil);
begin
  if Assigned(ThreadContext) then
    FThreadContext := ThreadContext
  else
    FThreadContext := GUIThread;
  Observers := TListConnections.Create(ThreadSafe);
end;

function TTemplateBEvent<T>.CreateObserver(OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>;
begin
  Result := CreateObserver(GUIThread, OnRsvProc);
end;

function TTemplateBEvent<T>.CreateObserver(ThreadCntx: TBThread; OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>;
begin
  Result := BObserver<T>.Create(Self, ThreadCntx);
  Result.OnRecieveData := OnRsvProc;
end;

destructor TTemplateBEvent<T>.Destroy;
begin
  Observers._DecOwners;
  inherited;
end;

function TTemplateBEvent<T>.References: int32;
begin
  Result := RefCount;
end;

procedure TTemplateBEvent<T>.SendEvent(const Value: T);
var
  arr: TArrayConnections;
  i: int32;
begin
  arr := Observers.ArrCon;
  for i := 0 to Length(arr) - 1 do
  begin
    arr[i].SendEvent(Value);
    arr[i] := nil;
  end;
  if Length(arr) > 0 then
    TBTimer.UpdateTimer(TTimeProcessEvent.TimeProcessEvent);
  FThreadContext.ResetWaiting;
end;

function TTemplateBEvent<T>.ThreadContext: TBThread;
begin
  Result := FThreadContext;
end;

{ TTemplateBEvent<T>.TListConnections }

procedure TTemplateBEvent<T>.TListConnections.Add(Connection: TConnection);
begin
  if Assigned(CS) then
  begin
    CS.Enter;
    try
      Connection.Pos := Pointer(PushToEnd(Connection));
      inc(_Owners);
    finally
      CS.Leave;
    end;
  end else
  begin
    Connection.Pos := Pointer(PushToEnd(Connection));
    inc(_Owners);
  end;
end;

function TTemplateBEvent<T>.TListConnections.ArrCon: TArrayConnections;
begin
  if Assigned(CS) then
  begin
    CS.Enter;
    try
      Result := ArrConDo;
    finally
      CS.Leave;
    end;
  end else
    Result := ArrConDo;
end;

function TTemplateBEvent<T>.TListConnections.ArrConDo: TArrayConnections;
var
  it: TListDual<TConnection>.PListItem;
  i: int32;
begin
  Result := nil;
  SetLength(Result, Count);
  i := 0;
  it := ItemListFirst;
  while Assigned(it) do
  begin
    Result[i] := it.Item;
    it := it.Next;
    inc(i);
  end;
end;

constructor TTemplateBEvent<T>.TListConnections.Create(ThreadSafe: boolean);
begin
  inherited Create;
  if ThreadSafe then
    CS := TCriticalSection.Create;
  _Owners := 1;
end;

destructor TTemplateBEvent<T>.TListConnections.Destroy;
begin
  CS.Free;
  inherited;
end;

procedure TTemplateBEvent<T>.TListConnections.Lock;
begin
  if Assigned(CS) then
    CS.Enter;
end;

procedure TTemplateBEvent<T>.TListConnections.Delete(Connection: TConnection);
begin
  if Assigned(CS) then
  begin
    CS.Enter;
    try
      Remove(TListDual<TConnection>.PListItem(Connection.Pos));
      dec(_Owners);
    finally
      CS.Leave;
    end;
  end else
  begin
    Remove(TListDual<TConnection>.PListItem(Connection.Pos));
    dec(_Owners);
  end;

  if _Owners = 0 then
    Destroy;
end;

procedure TTemplateBEvent<T>.TListConnections.Unlock;
begin
  if Assigned(CS) then
    CS.Leave;
end;

procedure TTemplateBEvent<T>.TListConnections._DecOwners;
begin
  Lock;
  try
    dec(_Owners);
  finally
    Unlock;
  end;
  { must not be collisions because use interfaces }
  if _Owners = 0 then
    Destroy;
end;

{ BObserver<T> }

constructor BObserver<T>.Create(AEvent: IBEvent<T>; AThreadContext: TBThread = nil);
begin
  FThreadContext := AThreadContext;
  if FThreadContext = nil then
    FThreadContext := GUIThread;
  Connection := AEvent.Connect(Self);
end;

destructor BObserver<T>.Destroy;
begin
  if Assigned(Connection) then
    Connection.RefDel;
  Connection := nil;
  inherited;
end;

function BObserver<T>.GetOnRecieveData: TGenericRecieveProc<T>;
begin
  Result := FReciever;
end;

procedure BObserver<T>.SetOnRecieveData(GenericReciever: TGenericRecieveProc<T>);
begin
  FReciever := GenericReciever;
end;

function BObserver<T>.ThreadContext: TBThread;
begin
  Result := FThreadContext;
end;

{ TThreadReciever }

constructor TThreadReciever.Create(AThread: TBThread);
begin
  FThread := AThread;
end;

destructor TThreadReciever.Destroy;
begin

  inherited;
end;

procedure TThreadReciever.OnRecieve(var Value);
type
  TEmtyData = record end;
  TItem = TItemConnection<TEmtyData>;
begin
  TItem(Value).Connection.Recieve(Value);
end;

{ BObserversGroup<T> }

function BObserversGroup<T>.Add(const Observer: IBObserver<T>):
  TListGoupedObsrv.PListItem;
begin
  Result := Observers.PushToEnd(Observer);
end;

procedure BObserversGroup<T>.Clear;
begin
  while Observers.Count > 0 do
    Observers.ItemListLast.Item := nil;
end;

constructor BObserversGroup<T>.Create(ATheadContext: TBThread; AReciever: TGenericRecieveProc<T>);
begin
  Observers := TListGoupedObsrv.Create;
  Reciever := AReciever;
  Thread := ATheadContext;
end;

constructor BObserversGroup<T>.Create(AReciever: TGenericRecieveProc<T>);
begin
  Create(GuiThread, AReciever);
end;

function BObserversGroup<T>.CreateObserver(Event: IBEvent<T>): Pointer;
var
  res: BObserverGrouped;
begin
  res := BObserverGrouped.Create(Event, Self);
  res.FReciever := Reciever;
  Result := res.Postn;
end;

destructor BObserversGroup<T>.Destroy;
begin
  Clear;
  Observers.Free;
  inherited;
end;

function BObserversGroup<T>.GetCountObservers: int32;
begin
  Result := Observers.Count;
end;

procedure BObserversGroup<T>.Remove(Position: TListGoupedObsrv.PListItem);
begin
  Observers.Remove(Position);
end;

procedure BObserversGroup<T>.RemoveObserver(var Handle: Pointer);
begin
  if Handle = nil then
    exit;
  TListGoupedObsrv.PListItem(Handle).Item := nil;
  Handle := nil;
end;

{ BObserversGroup<T>.BObserverGrouped<T> }

constructor BObserversGroup<T>.BObserverGrouped.Create(AEvent: IBEvent<T>;
  AGroup: BObserversGroup<T>);
begin
  FGroup := AGroup;
  inherited Create(AEvent, AGroup.Thread);
  Postn := FGroup.Add(Self);
end;

destructor BObserversGroup<T>.BObserverGrouped.Destroy;
begin
  FGroup.Remove(Postn);
  inherited;
end;

{ TTimeProcessEvent }

class constructor TTimeProcessEvent.Create;
begin
  TBTimer.UpdateTimer(TimeProcessEvent);
end;

initialization
  g_Recievers := TListVec<TThreadReciever>.Create;

finalization
  FreeRecievers;
  g_Recievers.Free;

end.
