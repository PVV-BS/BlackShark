unit TestGeometry;

interface

uses
    DUnitX.TestFramework
  , bs.geometry
  , bs.basetypes
  , bs.collections
  ;

type

  PSomeData = ^TSomeData;
  TSomeData = record
    Box: TBox2d;
    Index: int32;
  end;

  [TestFixture]
  TGeometryKDTreeTest = class(TObject)
  private
    FData: TListVec<PSomeData>;
    FKDTree: TBlackSharkKDTree;
    procedure GenData;
    procedure GenRandom(ACount: int32);
    procedure ClearData;
    procedure MainTest(WorldSize: int32; ViewportWidth: int32);
  public
    constructor Create;
    destructor Destroy; override;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    //[Test]
    [TestCase('TestA','100000')]
    procedure Test2(const ACount: Integer);
  end;

implementation

uses
    System.SysUtils
  , System.Classes
  ;

procedure TGeometryKDTreeTest.ClearData;
var
  i: int32;
  d: PSomeData;
begin
  for i := 0 to FData.Count - 1 do
  begin
    d := FData.Items[i];
    dispose(d);
  end;
  FData.Count := 0;
end;

constructor TGeometryKDTreeTest.Create;
begin
  FData := TListVec<PSomeData>.Create;
  FKDTree := TBlackSharkKDTree.Create(TDimension2D);
  Randomize;
end;

destructor TGeometryKDTreeTest.Destroy;
begin
  ClearData;
  FKDTree.Free;
  FData.Free;
  inherited;
end;

procedure TGeometryKDTreeTest.GenData;
var
  d: PSomeData;
begin
  new(d);
  d.Box.Min := vec2(-5.0, 4.0);
  d.Box.Max := vec2(-3.0, 8.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  {
  new(d);
  d.Box.Min := vec2(3.0, 4.0);
  d.Box.Max := vec2(3.0, 8.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(10.0, 7.0);
  d.Box.Max := vec2(15.0, 11.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(14.0, 17.0);
  d.Box.Max := vec2(15.0, 21.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(11.0, 6.0);
  d.Box.Max := vec2(17.0, 13.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(9.0, 3.0);
  d.Box.Max := vec2(16.0, 6.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(1.0, 3.0);
  d.Box.Max := vec2(5.0, 5.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);  }

end;

procedure TGeometryKDTreeTest.GenRandom(ACount: int32);
var
  d: PSomeData;
  i: int32;
begin
  for i := 0 to ACount - 1 do
  begin
    new(d);
    d.Box.Min.x := Random(ACount);
    d.Box.Min.y := Random(ACount);
    d.Box.Max.x := d.Box.Min.x + Random(10);
    d.Box.Max.y := d.Box.Min.y + Random(10);
    FData.Add(d);
    d.Index := FKDTree.AddBB(d, @d.Box);
  end;
end;

procedure TGeometryKDTreeTest.MainTest(WorldSize: int32; ViewportWidth: int32);
var
  i, j: int32;
  Selected: TListVec<Pointer>;
  MustSelected: TListVec<Pointer>;
  d: PSomeData;
  found: boolean;
  start_time: uint32;
  real_count: int32;
  viewport: TBox2d;
begin
  Selected := TListVec<Pointer>.Create;
  start_time := TThread.GetTickCount;
  for i := 0 to FData.Count - 1 do
  begin
    d := FData.Items[i];
    FKDTree.Select(@d.Box, Selected);
    if Selected.Count = 0 then
    begin
      Assert.Fail('Doesn''t find a box!');
      break;
    end else
    begin
      found := false;
      for j := 0 to Selected.Count - 1 do
        if Selected.Items[j] = d then
        begin
          found := true;
          break;
        end;
      Selected.Count := 0;
      if not found then
      begin
        Assert.Fail('Doesn''t not find a box!');
        break;
      end;
    end;
  end;
  System.WriteLn('Spend time for select all objects: ' + IntToStr(TThread.GetTickCount - start_time) + ', ms...');

  viewport.Min.x := WorldSize div 2 - ViewportWidth div 2;
  viewport.Min.y := viewport.Min.x;
  viewport.Max.x := viewport.Min.x + ViewportWidth;
  viewport.Max.y := viewport.Max.x;
  System.WriteLn('Select space to viewport: x_min = ' + IntToStr(trunc(viewport.Min.x)) + ', y_min = ' +
    IntToStr(trunc(viewport.Min.y)) + ', x_max = ' + IntToStr(trunc(viewport.Max.x)) + ', y_max = ' + IntToStr(trunc(viewport.Max.y)));

  MustSelected := TListVec<Pointer>.Create;
  for i := 0 to FData.Count - 1 do
  begin
    d := FData.Items[i];
    if Box2Collision(d.Box, viewport) then
      MustSelected.Add(d);
  end;
  System.WriteLn('Must intersect viewport ' + IntToStr(MustSelected.Count) + ' objects');

  Selected.Count := 0;
  start_time := TThread.GetTickCount;
  // select objects which contain areas intersected with viewport
  FKDTree.Select(@viewport, Selected);
  start_time := TThread.GetTickCount - start_time;
  // calculate objects intersects with viewport
  real_count := 0;
  for i := 0 to Selected.Count - 1 do
  begin
    d := Selected.Items[i];
    if Box2Collision(d.Box, viewport) then
      inc(real_count);
  end;
  System.WriteLn('Spend time for select to viewport: ' + IntToStr(start_time) + ', ms, selected ' +
   IntToStr(Selected.Count) + ' objects, really intersect viewport ' + IntToStr(real_count) + ' objects');

  if real_count <> MustSelected.Count then
  begin
    for i := 0 to MustSelected.Count - 1 do
    begin
      d := MustSelected.Items[i];
      System.WriteLn('Box: x_min = ' + IntToStr(trunc(d.Box.Min.x)) + ', y_min = ' +
        IntToStr(trunc(d.Box.Min.y)) + ', x_max = ' + IntToStr(trunc(d.Box.Max.x)) + ', y_max = ' + IntToStr(trunc(d.Box.Max.y)));
    end;
  end;

  Assert.IsTrue(real_count = MustSelected.Count, 'Count selected and must selected count don''t equal!');

  MustSelected.Free;
  Selected.Free;
end;

procedure TGeometryKDTreeTest.Setup;
begin
end;

procedure TGeometryKDTreeTest.TearDown;
begin
  ClearData;
end;

procedure TGeometryKDTreeTest.Test1;
begin
  GenData;
  MainTest(-10, 2);
end;

procedure TGeometryKDTreeTest.Test2(const ACount: Integer);
begin
  GenRandom(ACount);
  //GenData;
  System.WriteLn('Generated ' + IntToStr(FData.Count) + ' objects...');
  //MainTest(20);
  MainTest(ACount, 100);
end;

initialization
  TDUnitX.RegisterTestFixture(TGeometryKDTreeTest);


end.
