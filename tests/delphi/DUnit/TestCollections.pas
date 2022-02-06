unit TestCollections;

interface

uses
  DUnitX.TestFramework, DUnitX.DUnitCompatibility, Classes, SysUtils,
  bs.collections, generics.collections, System.Hash;

type

  TestBase = class (TTestCase)
  protected
  public
    procedure SetUp; override;
    procedure TearDown; override;
    [Test]
    procedure Test;
    procedure TestAdd; virtual; abstract;
    procedure TestFind; virtual; abstract;
    procedure TestRemove; virtual; abstract;
  end;

  // Test methods for class TBinTreeTemplate

  [TestFixture]
  TestTBinTreeTemplate = class(TestBase)
  strict private
    FBinTreeTemplate: TBinTreeTemplate<AnsiString, Pointer>;
  public
    [Setup]
    procedure SetUp; override;
    [TearDown]
    procedure TearDown; override;
    procedure TestAdd; override;
    procedure TestFind; override;
    procedure TestRemove; override;
  end;

  // Test methods for class TDictionary

  [TestFixture]
  TestDictionary = class(TestBase)
  strict private
    FHashTable: TDictionary<AnsiString, Pointer>;
  public
    [Setup]
    procedure SetUp; override;
    [TearDown]
    procedure TearDown; override;
    procedure TestAdd; override;
    procedure TestFind; override;
    procedure TestRemove; override;
  end;

  [TestFixture]
  TestTHashTable = class(TestBase)
  strict private
    FHashTable: THashTable<AnsiString, Pointer>;
  public
    [Setup]
    procedure SetUp; override;
    [TearDown]
    procedure TearDown; override;
    procedure TestAdd; override;
    procedure TestFind; override;
    procedure TestRemove; override;
  end;

  // Test methods for class TAhoCorasickFSA

  [TestFixture]
  TestTAhoCorasickFSA = class(TestBase)
  strict private
    FAhoCorasickFSA: TAhoCorasickFSA<Pointer>;
  public
    [Setup]
    procedure SetUp; override;
    [TearDown]
    procedure TearDown; override;
    procedure TestAdd; override;
    procedure TestFind; override;
    procedure TestRemove; override;
  end;

implementation

var
  Data: TListVec<AnsiString>;
  AllData: TMemoryStream;

procedure LoadDictionary;
var
  i, sz, beg: int32;
  pt: PByte;
  val: AnsiString;
  tmp_dic: TDictionary<Ansistring, int32>;
begin
  Data := TListVec<AnsiString>.Create(StrCmpA);
  AllData := TMemoryStream.Create;
  AllData.LoadFromFile('Lopatin.txt');
  pt := AllData.Memory;
  sz := AllData.Size;
  beg := 0;
  i := 0;
  tmp_dic := TDictionary<Ansistring, int32>.create;
  try
    while i < sz do
    begin
      if pt[i] = $0d then
      begin
        if i > beg then
        begin
          SetLength(val, i - beg);
          move(pt[beg], val[1], i - beg);
          Data.Add(val);
          tmp_dic.Add(val, 0);
        end;
        inc(i);
        if (i < sz) and (pt[i] = $0a) then
          inc(i);
        beg := i;
        continue;
      end;
      inc(i);
    end;

    if i > beg then
    begin
      SetLength(val, i - beg);
      move(pt[beg], val[1], i - beg);
      Data.Add(val);
      tmp_dic.Add(val, 0);
    end;

    for i := 0 to 1000000 do
    begin
      repeat
        sz := random(32);
      until sz > 0;

      val := '';
      while sz > 0 do
      begin
        repeat
          beg := random(256);
        until beg > 31;
        val := val + Ansichar(beg);
        dec(sz);
      end;
      if not tmp_dic.ContainsKey(val) then
      begin
        tmp_dic.Add(val, 0);
        Data.Add(val);
      end;
    end;
    Data.Sort;
  finally
    tmp_dic.Free;
  end;
end;

{ TestBase }

procedure TestBase.SetUp;
begin
  inherited;
  if not Assigned(Data) then
    LoadDictionary;
end;

procedure TestBase.TearDown;
begin
  inherited;
end;

procedure TestBase.Test;
begin
  TestAdd;
  TestFind;
  TestRemove;
end;

procedure TestTBinTreeTemplate.SetUp;
begin
  inherited;
  FBinTreeTemplate := TBinTreeTemplate<AnsiString, Pointer>.Create(@StrCmpA);

end;

procedure TestTBinTreeTemplate.TearDown;
begin
  FreeAndNil(FBinTreeTemplate);
  inherited;
end;

procedure TestTBinTreeTemplate.TestAdd;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('filling a binary tree...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  for i := 0 to Data.Count - 1 do
  begin
    if not FBinTreeTemplate.Add(Data.Items[i], nil) then
    begin
      ReturnValue := false;
      break;
    end;
  end;
  if ReturnValue then
  begin
    System.WriteLn('The adding of the keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms (added ' + IntToStr(Data.Count) + '  words from dictionary)');
  end else
    Assert.Fail('Could not add all keys!');
  System.WriteLn;
end;

procedure TestTBinTreeTemplate.TestFind;
var
  ReturnValue: Boolean;
  Value: Pointer;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('finding the keys in the binary tree...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  for i := 0 to Data.Count - 1 do
  begin
    if not FBinTreeTemplate.Find(Data.Items[i], Value) then
    begin
      ReturnValue := false;
      break;
    end;
  end;

  if ReturnValue then
  begin
    System.WriteLn('The finding all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('Could not find all keys!');
  System.WriteLn;
end;

procedure TestTBinTreeTemplate.TestRemove;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('deleting the keys from the binary tree...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  for i := 0 to Data.Count - 1 do
  begin
    if not FBinTreeTemplate.Remove(Data.Items[i]) then
    begin
      ReturnValue := false;
      break;
    end;
  end;

  if ReturnValue then
  begin
    System.WriteLn('The deleting all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('Could not add all keys!');
  System.WriteLn;
end;

procedure TestDictionary.SetUp;
begin
  inherited;
  FHashTable := TDictionary<AnsiString, Pointer>.Create(Data.Count shl 1);
end;

procedure TestDictionary.TearDown;
begin
  FreeAndNil(FHashTable);
  inherited;
end;

procedure TestDictionary.TestAdd;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('filling a hash-table TDictionary<K, V>...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  for i := 0 to Data.Count - 1 do
    FHashTable.Add(Data.Items[i], Pointer(1));

  if ReturnValue then
  begin
    System.WriteLn('The adding of the keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms (added ' + IntToStr(Data.Count) + '  words from dictionary)');
  end else
    Assert.Fail('Could not add all keys!');
  System.WriteLn;
end;

procedure TestDictionary.TestFind;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('finding the keys in the hash-table...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  for i := 0 to Data.Count - 1 do
  begin
    if not FHashTable.ContainsKey(Data.Items[i]) then
    begin
      ReturnValue := false;
      break;
    end;
  end;
  if ReturnValue then
  begin
    System.WriteLn('The finding all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('Could not find all keys!');
  System.WriteLn;
end;

procedure TestDictionary.TestRemove;
var
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('deleting the keys from the hash-table...');
  cnt_time := TThread.GetTickCount;

  for i := 0 to Data.Count - 1 do
  begin
    FHashTable.Remove(Data.Items[i]);
  end;

  if FHashTable.Count = 0 then
  begin
    System.WriteLn('The deleting all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('it doesn''t deleted all keys!');
  System.WriteLn;
end;

procedure TestTAhoCorasickFSA.SetUp;
begin
  inherited;
  FAhoCorasickFSA := TAhoCorasickFSA<Pointer>.Create;
end;

procedure TestTAhoCorasickFSA.TearDown;
begin
  FreeAndNil(FAhoCorasickFSA);
  inherited;
end;

procedure TestTAhoCorasickFSA.TestAdd;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('filling the Aho-Corasick finite-state automaton...');
  cnt_time := TThread.GetTickCount;
  ReturnValue := true;
  FAhoCorasickFSA.BeginUpdate;
  try
    for i := 0 to Data.Count - 1 do
    begin
      if not FAhoCorasickFSA.Add(Data.Items[i], Pointer(1)) then
      begin
        ReturnValue := false;
        break;
      end;
    end;
  finally
    FAhoCorasickFSA.EndUpdate;
  end;
  if ReturnValue then
  begin
    System.WriteLn('The adding of the keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms (added ' + IntToStr(Data.Count) + ' words from dictionary)');
  end else
    Assert.Fail('it doesn''t deleted all keys!');
  System.WriteLn;
end;

procedure TestTAhoCorasickFSA.TestFind;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
  c: int32;
begin
  ReturnValue := true;
  c := 0;
  FAhoCorasickFSA.OnFoundProc := (procedure (const data: Pointer; Key: pByte; LenKey: int32)
  begin
    inc(c);
  end);
  System.WriteLn('finding the keys in the Aho-Corasick finite-state automaton...');
  cnt_time := TThread.GetTickCount;
  for i := 0 to Data.Count - 1 do
  begin
    c := 0;
    FAhoCorasickFSA.Find(Data.Items[i]);
    if c = 0 then
    begin
      ReturnValue := false;
      break;
    end;
  end;
  if ReturnValue then
  begin
    System.WriteLn('The finding all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('Could not find all keys!');
  c := 0;
  System.WriteLn('finding the keys in buffer with the Aho-Corasick finite-state automaton...');
  cnt_time := TThread.GetTickCount;
  FAhoCorasickFSA.Find(PByte(AllData.Memory), AllData.Size);
  if c >= Data.Count then
  begin
    System.WriteLn('The finding all keys in single buffer took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('it doesn''t deleted all keys!');
  // TODO: Validate method results
  System.WriteLn;
end;

procedure TestTAhoCorasickFSA.TestRemove;
begin

end;

function AnsiStringComparator(const Value1, Value2: AnsiString): boolean;
begin
  Result := Value1 = Value2;
end;

function GetHash(const Key: AnsiString): uint32; inline;
begin
  Result := THashBobJenkins.GetHashValue(Key[1], Length(Key));
end;

{ TestTHashTable }

procedure TestTHashTable.SetUp;
begin
  inherited;
  FHashTable := THashTable<AnsiString, Pointer>.Create(GetHashBlackSharkSA, AnsiStringComparator, Data.Count shl 2); //GetHashSedgwickSA GetHash
end;

procedure TestTHashTable.TearDown;
begin
  inherited;
  FreeAndNil(FHashTable);
end;

procedure TestTHashTable.TestAdd;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('filling a hash-table bs.collections...');
  ReturnValue := true;

  cnt_time := TThread.GetTickCount;
  for i := 0 to Data.Count - 1 do
  begin
    //if i = 2862 then
    //  cnt_time := cnt_time;\
    //if Data.Items[i] = '' then
    //  Data.Items[i] := '';
    FHashTable.Items[Data.Items[i]] := Pointer(1);
  end;
  cnt_time := TThread.GetTickCount - cnt_time;

  if ReturnValue then
  begin
    System.WriteLn('The adding of the keys has took ' + IntToStr(cnt_time) + ' ms (added ' + IntToStr(Data.Count) + '  words from dictionary)');
  end else
    Assert.Fail('Could not add all keys in bs.collections.THashTable<K, V>!');

  System.WriteLn;
end;

procedure TestTHashTable.TestFind;
var
  ReturnValue: Boolean;
  i: int32;
  cnt_time: uint32;
  //item: THashTable<AnsiString, Pointer>.TBucketItem;
  //stream: TMemoryStream;
begin
  ReturnValue := true;
  System.WriteLn('finding the keys in the bs.collections.THashTable<K, V>...');
  //stream := TMemoryStream.Create;
  cnt_time := TThread.GetTickCount;
  for i := 0 to Data.Count - 1 do
  begin
    if not FHashTable.Exists(Data.Items[i]) then
    begin
      ReturnValue := false;
      break;
    end;
    //stream.Write(item.Hash, 4);
  end;
  if ReturnValue then
  begin
    System.WriteLn('The finding all keys in the bs.collections.THashTable<K, V> has took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('Could not find all keys in bs.collections.THashTable<K, V>!');
  //stream.SaveToFile('d:\hashes.bin');
  System.WriteLn;
end;

procedure TestTHashTable.TestRemove;
var
  i: int32;
  cnt_time: uint32;
begin
  System.WriteLn('deleting the keys from the bs.collections.THashTable<K, V>...');
  cnt_time := TThread.GetTickCount;
  for i := 0 to Data.Count - 1 do
  begin
    FHashTable.Delete(Data.Items[i]);
  end;
  if FHashTable.Count = 0 then
  begin
    System.WriteLn('The deleting all keys took ' + IntToStr(TThread.GetTickCount - cnt_time) + ' ms');
  end else
    Assert.Fail('it doesn''t deleted all keys!');
  System.WriteLn;
end;

initialization

finalization

  Data.Free;
  AllData.Free;

  // Register any test cases with the test runner
  //TDUnitX.RegisterTestFixture(TestTBinTreeTemplate);
  //TDUnitX.RegisterTestFixture(TestDictionary);
  //TDUnitX.RegisterTestFixture(TestTAhoCorasickFSA);
  //TDUnitX.RegisterTestFixture(TestTHashTable);
end.

