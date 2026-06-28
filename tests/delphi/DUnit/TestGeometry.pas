unit TestGeometry;

interface

uses
    DUnitX.TestFramework
  , bs.geometry
  , bs.geometry.kdtree
  , bs.basetypes
  , bs.collections
  ;

type

  PSomeData = ^TSomeData;
  TSomeData = record
    Box: TBox2d;
    Index: int32;
  end;

  //[TestFixture]
  TGeometryKDTreeTest = class(TObject)
  private
    FData: TListVec<PSomeData>;
    FKDTree: TBlackSharkKDTree;
    procedure GenData;
    procedure GenData2;
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
    //[Test]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    [TestCase('TestA','1000000')]
    procedure Test2(const ACount: Integer);
    //[Test]
    procedure Test3;
  end;

  [TestFixture]
  TTestIntervalsTree = class
  private
    FIntervalsTree: TIntervalsTree;
    procedure FillData;
  public
    constructor Create;
    destructor Destroy; override;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test1;
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
  FKDTree := TBlackSharkKDTree.Create(10000, TDimension2D, 10000000);
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
//  new(d);
//  d.Box.Min := vec2(4.0, 4.0);
//  d.Box.Max := vec2(5.0, 5.0);
//  FData.Add(d);
//  d.Index := FKDTree.AddBB(d, @d.Box);

  new(d);
  d.Box.Min := vec2(5.0, 8.0);
  d.Box.Max := vec2(7.0, 15.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(2.0, 3.0);
  d.Box.Max := vec2(5.0, 3.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(1.0, 5.0);
  d.Box.Max := vec2(8.0, 8.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(0.0, 7.0);
  d.Box.Max := vec2(2.0, 9.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(3.0, 7.0);
  d.Box.Max := vec2(4.0, 13.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);

  new(d);
  d.Box.Min := vec2(5.0, 8.0);
  d.Box.Max := vec2(5.0, 12.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(5.0, 7.0);
  d.Box.Max := vec2(10.0, 10.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(3.0, 2.0);
  d.Box.Max := vec2(4.0, 4.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(7.0, 1.0);
  d.Box.Max := vec2(10.0, 7.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box.Min := vec2(3.0, 3.0);
  d.Box.Max := vec2(12.0, 3.0);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
end;

procedure TGeometryKDTreeTest.GenData2;
var
  d: PSomeData;
begin
  new(d);
  d.Box := Box2(0, 4, 1, 12);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(4, 3, 7, 3);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(9, 1, 10, 9);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(0, 9, 8, 15);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(3, 3, 9, 4);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(0, 1, 1, 2);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(6, 9, 9, 13);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(5, 5, 7, 9);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(8, 0, 14, 3);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
  new(d);
  d.Box := Box2(9, 2, 9, 3);
  FData.Add(d);
  d.Index := FKDTree.AddBB(d, @d.Box);
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
  nodeMinMax: PKDMinMax;
  dem: Integer;
  boundary: Double;
  left, right: Integer;
begin
  System.WriteLn('KD-Tree MainTest has run...');
  Selected := TListVec<Pointer>.Create;
  start_time := TThread.GetTickCount;
  for i := 0 to FData.Count - 1 do
  begin
    d := FData.Items[i];
    FKDTree.Select(PKDMinMax(@d.Box), Selected);
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
    FKDTree.GetNodeAttributes(d.Index, nodeMinMax, dem, boundary, left, right);
    Assert.IsTrue(nodeMinMax[0] < nodeMinMax[2]);
    Assert.IsTrue(nodeMinMax[1] < nodeMinMax[3]);
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
  FKDTree.Select(PKDMinMax(@viewport), Selected);
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

  System.WriteLn('Select iterations, boundary errors: ' + IntToStr(FKDTree.SelectIterations) + ', ' + IntToStr(FKDTree.BoundaryErrors));
  if real_count <> MustSelected.Count then
  begin
    System.WriteLn('Must selected: ');
    for i := 0 to MustSelected.Count - 1 do
    begin
      d := MustSelected.Items[i];
      System.WriteLn('d.Box := Box2(' + IntToStr(trunc(d.Box.Min.x)) + ', ' +
        IntToStr(trunc(d.Box.Min.y)) + ', ' + IntToStr(trunc(d.Box.Max.x)) + ', ' + IntToStr(trunc(d.Box.Max.y)) + ');');
    end;
    System.WriteLn('Really selected: ');
    for i := 0 to Selected.Count - 1 do
    begin
      d := Selected.Items[i];
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
  //MainTest(ACount div 5, trunc(FKDTree.ViewPortSize));
end;

procedure TGeometryKDTreeTest.Test3;
begin
  GenData2;
  //MainTest(10, trunc(FKDTree.ViewPortSize));
end;

{ TTestIntervalsTree }

constructor TTestIntervalsTree.Create;
begin
  FIntervalsTree := TIntervalsTree.Create(100);
end;

destructor TTestIntervalsTree.Destroy;
begin
  FIntervalsTree.Free;
  inherited;
end;

procedure TTestIntervalsTree.FillData;
begin

//FIntervalsTree.Add(67, 133, nil);
//FIntervalsTree.Add(81, 127, nil);
//FIntervalsTree.Add(470, 515, nil);
//FIntervalsTree.Add(165, 179, nil);
//FIntervalsTree.Add(164, 174, nil);
//FIntervalsTree.Add(62, 107, nil);
//FIntervalsTree.Add(243, 253, nil);
//FIntervalsTree.Add(262, 272, nil);
//FIntervalsTree.Add(493, 550, nil);
//FIntervalsTree.Add(12, 43, nil);
//FIntervalsTree.Add(174, 184, nil);
//FIntervalsTree.Add(373, 397, nil);


FIntervalsTree.Add(753, 773, nil);
FIntervalsTree.Add(131, 177, nil);
FIntervalsTree.Add(1004, 1029, nil);
FIntervalsTree.Add(265, 288, nil);
FIntervalsTree.Add(473, 483, nil);
FIntervalsTree.Add(136, 152, nil);
FIntervalsTree.Add(103, 146, nil);
FIntervalsTree.Add(625, 672, nil);
FIntervalsTree.Add(385, 415, nil);
FIntervalsTree.Add(351, 361, nil);
FIntervalsTree.Add(635, 645, nil);
FIntervalsTree.Add(180, 190, nil);
FIntervalsTree.Add(917, 931, nil);
FIntervalsTree.Add(43, 107, nil);
FIntervalsTree.Add(1025, 1035, nil);
FIntervalsTree.Add(520, 572, nil);
FIntervalsTree.Add(804, 814, nil);
FIntervalsTree.Add(780, 790, nil);
FIntervalsTree.Add(666, 676, nil);
FIntervalsTree.Add(942, 960, nil);
FIntervalsTree.Add(133, 171, nil);
FIntervalsTree.Add(514, 562, nil);
FIntervalsTree.Add(1068, 1124, nil);
FIntervalsTree.Add(321, 385, nil);
FIntervalsTree.Add(906, 926, nil);
FIntervalsTree.Add(976, 1018, nil);
FIntervalsTree.Add(237, 247, nil);
FIntervalsTree.Add(415, 425, nil);
FIntervalsTree.Add(267, 318, nil);
FIntervalsTree.Add(984, 994, nil);
FIntervalsTree.Add(335, 398, nil);
FIntervalsTree.Add(634, 645, nil);
FIntervalsTree.Add(45, 82, nil);
FIntervalsTree.Add(195, 250, nil);
FIntervalsTree.Add(808, 840, nil);
FIntervalsTree.Add(1057, 1067, nil);
FIntervalsTree.Add(930, 940, nil);
FIntervalsTree.Add(330, 383, nil);
FIntervalsTree.Add(381, 435, nil);
FIntervalsTree.Add(1087, 1120, nil);
FIntervalsTree.Add(578, 612, nil);
FIntervalsTree.Add(435, 475, nil);
FIntervalsTree.Add(213, 282, nil);
FIntervalsTree.Add(423, 441, nil);
FIntervalsTree.Add(148, 209, nil);
FIntervalsTree.Add(235, 258, nil);
FIntervalsTree.Add(27, 56, nil);
FIntervalsTree.Add(676, 711, nil);
FIntervalsTree.Add(676, 722, nil);
FIntervalsTree.Add(611, 624, nil);
FIntervalsTree.Add(1017, 1045, nil);
FIntervalsTree.Add(1103, 1125, nil);
FIntervalsTree.Add(936, 965, nil);
FIntervalsTree.Add(895, 921, nil);
FIntervalsTree.Add(433, 498, nil);
FIntervalsTree.Add(38, 70, nil);
FIntervalsTree.Add(694, 704, nil);
FIntervalsTree.Add(1090, 1155, nil);
FIntervalsTree.Add(678, 688, nil);
FIntervalsTree.Add(223, 233, nil);
FIntervalsTree.Add(272, 330, nil);
FIntervalsTree.Add(562, 614, nil);
FIntervalsTree.Add(285, 296, nil);
FIntervalsTree.Add(116, 161, nil);
FIntervalsTree.Add(632, 700, nil);
FIntervalsTree.Add(294, 304, nil);
FIntervalsTree.Add(228, 269, nil);
FIntervalsTree.Add(968, 1001, nil);
FIntervalsTree.Add(701, 747, nil);
FIntervalsTree.Add(563, 598, nil);
FIntervalsTree.Add(1106, 1131, nil);
FIntervalsTree.Add(463, 500, nil);
FIntervalsTree.Add(554, 605, nil);
FIntervalsTree.Add(677, 705, nil);
FIntervalsTree.Add(373, 390, nil);
FIntervalsTree.Add(1081, 1095, nil);
FIntervalsTree.Add(411, 469, nil);
FIntervalsTree.Add(873, 883, nil);
FIntervalsTree.Add(725, 785, nil);
FIntervalsTree.Add(686, 748, nil);
FIntervalsTree.Add(499, 550, nil);
FIntervalsTree.Add(488, 498, nil);
FIntervalsTree.Add(35, 57, nil);
FIntervalsTree.Add(656, 695, nil);
FIntervalsTree.Add(838, 865, nil);
FIntervalsTree.Add(307, 359, nil);
FIntervalsTree.Add(597, 607, nil);
FIntervalsTree.Add(43, 101, nil);
FIntervalsTree.Add(864, 906, nil);
FIntervalsTree.Add(161, 191, nil);
FIntervalsTree.Add(883, 893, nil);
FIntervalsTree.Add(547, 586, nil);
FIntervalsTree.Add(207, 261, nil);
FIntervalsTree.Add(288, 298, nil);
FIntervalsTree.Add(519, 573, nil);
FIntervalsTree.Add(403, 413, nil);
FIntervalsTree.Add(615, 649, nil);
FIntervalsTree.Add(79, 141, nil);
FIntervalsTree.Add(91, 131, nil);
FIntervalsTree.Add(1012, 1022, nil);

FIntervalsTree.WriteTreeState;
end;

procedure TTestIntervalsTree.Setup;
begin

end;

procedure TTestIntervalsTree.TearDown;
begin

end;

procedure TTestIntervalsTree.Test1;
begin
  FillData;
end;

initialization
  TDUnitX.RegisterTestFixture(TGeometryKDTreeTest);


end.
