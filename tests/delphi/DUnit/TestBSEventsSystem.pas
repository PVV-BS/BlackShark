unit TestBSEventsSystem;

interface

uses
  DUnitX.ConsoleWriter.Base,
  DUnitX.TestFramework,
  DUnitX.IoC,
  Generics.Collections,
  Classes,
  WinApi.messages,
  bs.collections,
  bs.thread,
  bs.animation,
  bs.obj,
  bs.events;

type

  [TestFixture]
  TEventsSystemTest = class(TObject)
  private
    const
      COUNT_EVENTS = 32;
    type

      TClientServer = class
      private
        FTest: TEventsSystemTest;
        FTh: TBThread;
        _CUpd: int32;
        Events: TListVec<IBEmptyEvent>;
        Observers: TListVec<IBEmptyEventObserver>;
        EventsMsg: TListVec<IBMessageEvent>;
        ObserversMsg: TListVec<IBMessageEventObserver>;
        FirstUpdate: boolean;
        LastTimeSentMsg: uint32;
        HaveMessage: boolean;
        FLstMessage: BMessage;
        function ProcessEvents: boolean;
        procedure GenericRecieveFunc(const Value: BEmpty);
        procedure GenericRecieveFuncMsg(const Value: BMessage);
        function GetLastMessage: string;
      public
        constructor Create(Test: TEventsSystemTest; Th: TBThread);
        destructor Destroy; override;
        function Clean: boolean;
        procedure BeginUpdate;
        procedure EndUpdate;
        procedure AddEvent(const BEvent: IBEmptyEvent); overload;
        procedure AddObserver(const Observer: IBEmptyEventObserver); overload;
        procedure AddEvent(const BEvent: IBMessageEvent); overload;
        procedure AddObserver(const Observer: IBMessageEventObserver); overload;
        property Th: TBThread read FTh;
        property LastMessage: string read GetLastMessage;
      end;

  private
    CountThreadSafeCon: int32;
    Generators: TListVec<TClientServer>;
    FCountSendBlocks: int32;
    FCountSendData: int32;
    FCountRecieveBlocks: int32;
    FCountRecieveData: int32;
    ConsoleWriter : IDUnitXConsoleWriter;
    procedure FillEvetns;
  public
    constructor Create;
    destructor Destroy; override;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Sample Methods
    // Simple single Test
    [Test]
    procedure Test1;
  end;

implementation

uses
  SysUtils,
  math,
  Windows;

var
 g_Break: boolean;

procedure WriteLine(consoleWriter : IDUnitXConsoleWriter; const value : string);
begin
  if consoleWriter <> nil then
    consoleWriter.WriteLn(value)
  else
    System.Writeln(value);
end;

{ TEventsSystemTest }

constructor TEventsSystemTest.Create;
begin
  ConsoleWriter := TDUnitXIoC.DefaultContainer.Resolve<IDUnitXConsoleWriter>;
  Generators := TListVec<TClientServer>.Create;
end;

destructor TEventsSystemTest.Destroy;
var
  i: int32;
  //cleaned: boolean;
begin
  ConsoleWriter := nil;

  {repeat
  cleaned := true;
  for i := 0 to Generators.Count - 1 do
    begin
    if not Generators.Items[i].Clean then
      cleaned := false;
    end;
  until cleaned; }
  for i := 0 to Generators.Count - 1 do
    Generators.Items[i].Th.RemoveUpdateMethod(Generators.Items[i].ProcessEvents);

  for i := 0 to Generators.Count - 1 do
  begin
    Generators.Items[i].Free;
  end;
  Generators.Free;
  inherited;
end;

procedure TEventsSystemTest.FillEvetns;
var
  cth: int32;
  i: int32;
  ind_ev, ind_obs: int32;
  event: IBEmptyEvent;
  obsrv: IBEmptyEventObserver;
  gen: TClientServer;
  event_m: IBMessageEvent;
  obsrv_m: IBMessageEventObserver;
begin
  cth := CountExecutors;
  for i := 0 to cth - 1 do
  begin
    gen := TClientServer.Create(Self, GetExecutor(i));
    Generators.Add(gen);
    gen.BeginUpdate;
  end;

  CountThreadSafeCon := 0;
  Randomize;
  for i := 0 to COUNT_EVENTS - 1 do
  begin
    ind_ev := Random(cth);
    gen := Generators.Items[ind_ev];
    ind_obs := Random(cth);
    event := CreateEmptyEvent(gen.FTh, ind_ev <> ind_obs);
    if ind_ev <> ind_obs then
      inc(CountThreadSafeCon);
    gen.AddEvent(event);
    gen := Generators.Items[ind_obs];
    obsrv := CreateEmptyObserver(event, gen.GenericRecieveFunc, gen.FTh);
    gen.AddObserver(obsrv);
  end;

  for i := 0 to cth - 1 do
  begin
    gen := Generators.Items[i];
    ind_obs := cth - i - 1;
    event_m := CreateMessageEvent(gen.FTh, i <> ind_obs);
    if i <> ind_obs then
      inc(CountThreadSafeCon);
    gen.AddEvent(event_m);
    gen := Generators.Items[ind_obs];
    obsrv_m := CreateMessageObserver(event_m, gen.GenericRecieveFuncMsg, gen.FTh);
    gen.AddObserver(obsrv_m);

    {ind_ev := Random(cth);
    gen := Generators.Items[ind_ev];
    event_m := CreateMessageEvent(gen.FTh, ind_ev <> ind_obs);

    if ind_ev <> ind_obs then
      inc(CountThreadSafeCon);
    gen.AddEvent(event_m);  }

  end;

  for i := 0 to cth - 1 do
  begin
    Generators.Items[i].EndUpdate;
    System.WriteLn('Thread ', Generators.Items[i].FTh.Index, ' has ',
      Generators.Items[i].FTh.QueueDispatcher.CountQueues, ' queues');
  end;

end;

procedure TEventsSystemTest.Setup;
begin
  ConsoleWriter := TDUnitXIoC.DefaultContainer.Resolve<IDUnitXConsoleWriter>;
  ConsoleWriter.SetColour(ccBrightGreen);
  FillEvetns;

  System.WriteLn('Create ' + IntToStr(COUNT_EVENTS) + ' events and the same number observers...');
  System.WriteLn(IntToStr(CountThreadSafeCon) + ' pairs are divided and located into different threads... ');

  System.WriteLn('Running testing system of events...press Esc for complete..');

  System.WriteLn;

end;

procedure TEventsSystemTest.TearDown;
begin

end;

procedure TEventsSystemTest.Test1;
var
  t: uint32;
  t_now: uint32;
  t_start: uint32;
  consoleWriter : IDUnitXConsoleWriter;
  num: DWORD;
  num_r: DWORD;
  ir: TInputRecord;
  ci: THandle;
  i: Integer;
begin
  t := GetTickCount;
  t_start := t;
  ConsoleWriter := TDUnitXIoC.DefaultContainer.Resolve<IDUnitXConsoleWriter>;
  ConsoleWriter.SetColour(ccBrightAqua);
  ci := GetStdHandle(STD_INPUT_HANDLE);

  g_Break := false;

  repeat
    GUIThread.OnIdleApplication;
    t_now := GetTickCount;
    if t_now - t > 1000 then
    begin
      if t_now - t_start > 5000 then
        break;

      GetNumberOfConsoleInputEvents(ci, num);
      while (num > 0) do
      begin
        if ReadConsoleInput(ci, ir, 1, num_r) then
        begin
            case ir.Event.KeyEvent.wVirtualKeyCode of
              ord('Q')  : WriteLn('Press key "Q"');
              VK_ESCAPE : begin
                g_Break := true;
                break;
              end;
            end;
        end else
          break;

        if num_r = 0 then
          break;

        dec(num, num_r);
      end;
      t := GetTickCount;
      WriteLine(consoleWriter, 'Sent blocks: ' + IntToStr(FCountSendBlocks) +
        '; Recieved: ' + IntToStr(FCountRecieveBlocks));
       for i := 0 to Generators.Count - 1 do
       begin
        if Generators.Items[i].HaveMessage then
          WriteLine(consoleWriter, Generators.Items[i].LastMessage);
       end;
    end;
  until g_Break;
  System.Assert(FCountRecieveBlocks <> 0, 'Fail events system');
end;

{ TEventsSystemTest.TGeneratorData }

procedure TEventsSystemTest.TClientServer.AddEvent(const BEvent: IBEmptyEvent);
begin
  Events.Add(BEvent);
end;

procedure TEventsSystemTest.TClientServer.AddObserver(const Observer: IBEmptyEventObserver);
begin
  Observers.Add(Observer);
end;

procedure TEventsSystemTest.TClientServer.AddEvent(const BEvent: IBMessageEvent);
begin
  EventsMsg.Add(BEvent);
end;

procedure TEventsSystemTest.TClientServer.AddObserver(const Observer: IBMessageEventObserver);
begin
  ObserversMsg.Add(Observer);
end;

procedure TEventsSystemTest.TClientServer.BeginUpdate;
begin
  if _Cupd = 0 then
    FTh.Lock;
  inc(_Cupd);
end;

function TEventsSystemTest.TClientServer.Clean: boolean;
begin
  if not FirstUpdate then
  begin
    FirstUpdate := true;
    FTh.RemoveUpdateMethod(ProcessEvents);
  end;
  Result := not FTh.Clear;
end;

constructor TEventsSystemTest.TClientServer.Create(Test: TEventsSystemTest; Th: TBThread);
begin
  FTest := Test;
  FTh := Th;
  Events := TListVec<IBEmptyEvent>.Create;
  Observers := TListVec<IBEmptyEventObserver>.Create;
  EventsMsg := TListVec<IBMessageEvent>.Create;
  ObserversMsg := TListVec<IBMessageEventObserver>.Create;
  FirstUpdate := true;
  LastTimeSentMsg := TBTimer.CurrentTime.Low;
end;

destructor TEventsSystemTest.TClientServer.Destroy;
var
  i: int32;
begin
  FTh.RemoveUpdateMethod(ProcessEvents);
  for i := 0 to Observers.Count - 1 do
    Observers.Items[i] := nil;
  for i := 0 to Events.Count - 1 do
    Events.Items[i] := nil;
  for i := 0 to ObserversMsg.Count - 1 do
    ObserversMsg.Items[i] := nil;
  for i := 0 to EventsMsg.Count - 1 do
    EventsMsg.Items[i] := nil;

  EventsMsg.Free;
  ObserversMsg.Free;
  Events.Free;
  Observers.Free;
  inherited;
end;

procedure TEventsSystemTest.TClientServer.EndUpdate;
begin
  dec(_Cupd);
  if _Cupd = 0 then
  begin
    FTh.UnLock;
    if FirstUpdate then
    begin
      { so update functions invoke without lock/unlock, therefor add it method
        after prepare test data which work into ProcessEvents; otherwise can
        appear collisions and hence exceptions }
      FirstUpdate := false;
      FTh.AddUpdateMethod(ProcessEvents);
    end;
  end;
end;

procedure TEventsSystemTest.TClientServer.GenericRecieveFunc(const Value: BEmpty);
begin
  AtomicIncrement(FTest.FCountRecieveBlocks);
  AtomicIncrement(FTest.FCountRecieveData, SizeOf(Value));
end;

procedure TEventsSystemTest.TClientServer.GenericRecieveFuncMsg(const Value: BMessage);
begin
  HaveMessage := true;
  FLstMessage := Value;
end;

function TEventsSystemTest.TClientServer.GetLastMessage: string;
begin
  HaveMessage := false;
  Result := FLstMessage.Msg;
end;

function TEventsSystemTest.TClientServer.ProcessEvents: boolean;
var
  i: int32;
  ed: BEmpty;
  edm: BMessage;
begin
  Result := true;
  ed.Instance := nil;
  for i := 0 to Events.Count - 1 do
    Events.Items[i].SendEvent(ed);

  AtomicIncrement(FTest.FCountSendBlocks, Events.Count);
  AtomicIncrement(FTest.FCountSendData, Events.Count * SizeOf(ed));

  if TBTimer.CurrentTime.Low - LastTimeSentMsg > 5000 then
  begin

    LastTimeSentMsg := TBTimer.CurrentTime.Low;

    edm.Msg := 'Thread ' + IntToStr(FTh.Index) + ' has already sent ' + IntToStr(FTest.FCountSendData) + ' bytes';

    for i := 0 to EventsMsg.Count - 1 do
      EventsMsg.Items[i].SendEvent(edm);

  end;

end;

end.
