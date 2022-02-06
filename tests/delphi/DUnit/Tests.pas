unit Tests;

interface

uses
  DUnitX.TestFramework,
  Generics.Collections,
  Classes,
  bs.collections;

type

  { It is test of Finite State Machine built by the Aho–Corasick
    algorithm }

  [TestFixture]
  TCollectionsTest = class(TObject)
  private
    const
      DIC: array[0..2] of AnsiString =
        ('sty', 'ty', 'y');
      DIC2: array[0..8] of AnsiString =
        ('asdfstydasf', 'yjhtstydasf', 'yjhtyj', 'dghtyhdt' , 'opyhj', 'rthewrthdsafwedfew', 'asdfg', 'asf', 'dght'); //
  private
    type
      PKeyDescr = ^TKeyDescr;
      TKeyDescr = record
        key: AnsiString;
        counter: int32;
        index: int32;
      end;
  private
    StateMashine: TAhoCorasickFSA<Pointer>;
    Found: TListVec<AnsiString>;
    AllKeys: TStringList;
    Buff: TMemoryStream;
    Counter: int32;

    DicRnd: TDictionary<AnsiString, PKeyDescr>;
    ClearUnicKeys: int32;

    procedure OnFind(const Data: Pointer; Key: pByte; KeyLen: int32);
    procedure PrepareTest1;
    procedure PrepareTest2;
    procedure PrepareTest3;
    procedure ClearDic;
    procedure SaveDic;
    function LoadDic: boolean;
    procedure AllKeysToDic;
    procedure SaveNoFind;
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
    [Test]
    procedure Test2;
    [Test]
    procedure Test3;
  end;

implementation

  uses SysUtils;

procedure TCollectionsTest.AllKeysToDic;
var
  i: int32;
  k: PKeyDescr;
begin
  for i := 0 to AllKeys.Count - 1 do
  begin
    new(k);
    k.key := AnsiString(AllKeys.Strings[i]);
    k.counter := 0;
    k.index := i;
    Buff.Write(k.key[1], length(k.key));
    DicRnd.Add(k.key, k);
    AllKeys.Objects[i] := TObject(k);
  end;
end;

procedure TCollectionsTest.ClearDic;
var
  enm: TDictionary<AnsiString, PKeyDescr>.TPairEnumerator;
begin
  enm := DicRnd.GetEnumerator;
  while enm.MoveNext do
  begin
    dispose(enm.Current.Value);
  end;
  enm.Free;
  DicRnd.Clear;
end;

constructor TCollectionsTest.Create;
begin
  Found := TListVec<AnsiString>.Create(StrCmpA);
  StateMashine := TAhoCorasickFSA<Pointer>.Create;
  StateMashine.OnFoundProc := OnFind;
  //DicRnd := TListVec<AnsiString>.Create;
  DicRnd := TDictionary<AnsiString, PKeyDescr>.Create;
  AllKeys := TStringList.Create;
  Buff := TMemoryStream.Create;
  Randomize;
end;

destructor TCollectionsTest.Destroy;
begin
  ClearDic;
  StateMashine.Free;
  Found.Free;
  DicRnd.Free;
  AllKeys.Free;
  Buff.Free;
  inherited;
end;

function TCollectionsTest.LoadDic: boolean;
var
  i: int32;
  //j: int32;
begin
  if not FileExists('dic.dic') then
    exit(false);
  try
    AllKeys.LoadFromFile('dic.dic');
  except
    exit(false);
  end;
  StateMashine.BeginUpdate;
  try
    for i := 0 to AllKeys.Count - 1 do
    begin
      //if i = 238 then
      //  j := j;
      StateMashine.Add(AnsiString(AllKeys.Strings[i]), nil);
    end;
  finally
    StateMashine.EndUpdate;
  end;
  Result := AllKeys.Count > 0;
end;

procedure TCollectionsTest.OnFind(const Data: Pointer; Key: pByte; KeyLen: int32);
var
  s: AnsiString;
  k: PKeyDescr;
begin
  SetLength(s, KeyLen);
  move(Key^, s[1], KeyLen);
  Found.Add(s);
  if DicRnd.TryGetValue(s, k) then
  begin
    if k.counter = 0 then
    begin
      inc(ClearUnicKeys);
      {if k.index = 238 then
        k.index := 238;
      if k.index = 729 then
        k.index := 729; }
      //if ClearUnicKeys = 113 then
      //  ClearUnicKeys := ClearUnicKeys;
    end;
    inc(k.counter);
  end else
  begin
    SaveDic;
    Assert.Fail('The key did not find!');
    //ClearUnicKeys := ClearUnicKeys;
  end;
end;

procedure TCollectionsTest.PrepareTest1;
var
  i: int32;
begin
  //exit;
  StateMashine.BeginUpdate;
  try
    for i := 0 to Length(DIC) - 1 do
    begin
      AllKeys.Add(string(DIC[i]));
      StateMashine.Add(DIC[i], nil);
    end;
  finally
    StateMashine.EndUpdate;
  end;
  AllKeysToDic;
end;

procedure TCollectionsTest.PrepareTest2;
var
  i: int32;
  inst: AnsiString;
  cnt_time: uint32;
begin
  //exit;
  System.WriteLn('Start building...');
  cnt_time := TThread.GetTickCount;
  StateMashine.BeginUpdate;
  try
    for i := 0 to Length(DIC2) - 1 do
    begin
      inst := DIC2[i];
      if not StateMashine.WordExists(inst) then
      begin
        AllKeys.Add(string(inst));
        StateMashine.Add(inst, nil);
      end;
    end;
  finally
    StateMashine.EndUpdate;
    System.WriteLn('The time building of the finite-state automaton is ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms (added ' + IntToStr(AllKeys.Count) + ' random states)');
  end;
  AllKeysToDic;
end;

procedure TCollectionsTest.PrepareTest3;
var
  i: int32;
  len: int8;
  j: int32;
  inst: AnsiString;
  cnt_time: uint32;
begin
  //exit;
  { fill in random keys }
  System.WriteLn;
  System.WriteLn('Start building test3...');
  cnt_time := TThread.GetTickCount;
  if not LoadDic then
  begin
    StateMashine.BeginUpdate;
    try
      for i := 1 to 10000 do
      begin
        len := Random(30);
        inst := '';
        if len = 0 then
          continue;
        for j := 0 to len do
        begin
          inst := inst + AnsiChar(Byte(AnsiChar('a')) + Random(26));
        end;
        if not StateMashine.WordExists(inst) then
        begin
          AllKeys.Add(string(inst));
          StateMashine.Add(inst, nil);
        end;
      end;
    finally
      StateMashine.EndUpdate;
    end;
  end;

  System.WriteLn('The time building of the finite-state automaton is ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms (added ' + IntToStr(AllKeys.Count) + ' random unique states)');

  AllKeysToDic;
end;

procedure TCollectionsTest.SaveDic;
begin
  AllKeys.SaveToFile('dic.dic');
end;

procedure TCollectionsTest.SaveNoFind;
var
  i: int32;
  sl: TStringList;
  k: PKeyDescr;
begin
  sl := TStringList.Create;
  try
    for i := 0 to AllKeys.Count - 1 do
    begin
      k := PKeyDescr(AllKeys.Objects[i]);
      if k.counter = 0 then
        sl.Add(string(k.key));
    end;
    if sl.Count > 0 then
      sl.SaveToFile('not_found.txt');
  finally
    sl.Free;
  end;
end;

procedure TCollectionsTest.Setup;
begin
  StateMashine.Clear;
  Found.Clear;
  Buff.Clear;
  AllKeys.Clear;
  ClearDic;
  ClearUnicKeys := 0;
  { the first test ? }
  case Counter of
    0: PrepareTest1;
    1: PrepareTest2;
    2: PrepareTest3;
  end;
  inc(Counter);
end;

procedure TCollectionsTest.TearDown;
begin
end;

procedure TCollectionsTest.Test1;
var
  i: int32;
begin
  //exit;
  Found.Count := 0;
  StateMashine.Find(AnsiString('prstyf'));
  if Length(DIC) <> Found.Count then
    Assert.Fail('Did not find all instances of strings!')
  else
    for i := 0 to Length(DIC) - 1 do
    begin
      if Found.IndexOf(DIC[i]) < 0 then
        Assert.Fail('Did not find an instance: ' + string(DIC[i]));
    end;
end;

procedure TCollectionsTest.Test2;
var
  cnt_time: uint32;
  i: int32;
begin
  //if Counter = 2 then
  //  exit;
  System.WriteLn;
  System.WriteLn('It starts enumeration all keys for a search in automate...');
  cnt_time := TThread.GetTickCount;
  //while enm.MoveNext do
  for i := 0 to AllKeys.Count - 1 do
  begin
    if not StateMashine.WordExists(AnsiString(AllKeys.Strings[i])) then //  enm.Current.Key
    begin
      SaveDic;
      Assert.Fail('Did not find instance of string!');
      exit;
    end;
  end;
  System.WriteLn('The time of search all keys in the finite-state automaton is ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  System.WriteLn;
  Found.Count := 0;
  cnt_time := TThread.GetTickCount;
  System.WriteLn('It is starting an search of all keys in a binary buffer (' + IntToStr(Buff.Size) + ' bytes) ...');
  StateMashine.Find(pByte(Buff.Memory), Buff.Size);
  System.WriteLn('The time of search all keys in the binary buffer is ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  if ClearUnicKeys <> DicRnd.Count then
  begin
    SaveDic;
    SaveNoFind;
    Assert.Fail('Not all keys (states) detected!');
  end else
  begin
    System.WriteLn('All states detected and additionally found ' + IntToStr(Found.Count - DicRnd.Count) + ' overlapping states...');
    System.WriteLn('In the binary buffer total detected ' + IntToStr(Found.Count) + ' states');
  end;
end;

procedure TCollectionsTest.Test3;
begin
  //exit;
  { A dictionary is another but test's algorithm the same, therefor invoke Test2 }
  Test2;
end;

initialization
  //TDUnitX.RegisterTestFixture(TCollectionsTest);
end.
