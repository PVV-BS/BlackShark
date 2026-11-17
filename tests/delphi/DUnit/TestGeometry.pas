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

  [TestFixture]
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
    [Test]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    [TestCase('TestA','1000000')]
    procedure Test2(const ACount: Integer);
    [Test]
    procedure Test3;
  end;

  [TestFixture]
  T1DTreeTest = class
  private
    FVecs: TListVec<TVec2d>;
    F1dTree: T1DTree<Pointer>;
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

  [TestFixture]
  T2DTreeTest = class
  private
    type
      PBox2d = ^TBox2d;
  private
    Rects: TListVec<PBox2d>;
    Tree2d: T2DTree<PBox2d>;
    procedure FillData;
    procedure OnDeleteBox(const Value: PBox2d);
    procedure FillData2;
    function Box(X, Y, Width, Height: int32): PBox2d;
    procedure SetBoxPosition(var viewport: TBox2d; X, Y: double);
    procedure SetBoxSize(var viewport: TBox2d; Width, Height: double);
  public
    constructor Create;
    destructor Destroy; override;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test1;
    [Test]
    procedure Test2;
  end;

  [TestFixture]
  T3DTreeTest = class
  private
    type
      PBox3d = ^TBox3d;
  private
    Boxes: TListVec<PBox3d>;
    Tree3d: T3DTree<PBox3d>;
    procedure OnDeleteBox(const Value: PBox3d);
    function Box(X, Y, Z, Width, Height, Deep: Double): PBox3d;
    procedure SetBoxPosition(var Box: TBox3d; X, Y, Z: double);
    procedure SetBoxSize(var Box: TBox3d; Width, Height, Deep: double);
  public
    constructor Create;
    destructor Destroy; override;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestUpdateAndDelete;
    [Test]
    procedure TestDeleteNext;
    [Test]
    procedure TestSelectNext;
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

constructor T1DTreeTest.Create;
begin
  F1dTree := T1DTree<Pointer>.Create;
  FVecs := TListVec<TVec2d>.Create;
end;

destructor T1DTreeTest.Destroy;
begin
  F1dTree.Free;
  FVecs.Free;
  inherited;
end;

procedure T1DTreeTest.FillData;
begin
  FVecs.Add(vec2d(67, 133));
  FVecs.Add(vec2d(81, 127));
  F1dTree.Add(Pointer($1), FVecs.ShiftData[0]);
  F1dTree.Add(Pointer($2), FVecs.ShiftData[1]);
end;

procedure T1DTreeTest.Setup;
begin
  FillData;
end;

procedure T1DTreeTest.TearDown;
begin
  FVecs.Clear;
  F1dTree.Clear;
end;

procedure T1DTreeTest.Test1;
var
  viewport: TVec2d;
  selected: TListVec<Pointer>;
begin
    viewport := vec2d(10.0, 60.0);
    selected := F1dTree.Select(@viewport);
    System.Assert(selected.Count = 0);

    viewport := vec2d(50.0, 69.0);
    selected := F1dTree.Select(@viewport);
    System.Assert(selected.Count = 1);

    viewport := vec2d(50.0, 90.0);
    selected := F1dTree.Select(@viewport);
    System.Assert(selected.Count = 2);

    viewport := vec2d(128.0, 150.0);
    selected := F1dTree.Select(@viewport);
    System.Assert(selected.Count = 1);

    viewport := vec2d(135.0, 150.0);
    selected := F1dTree.Select(@viewport);
    System.Assert(selected.Count = 0);

end;

{ TTest2DTree }

constructor T2DTreeTest.Create;
begin
  Tree2d := T2DTree<PBox2d>.Create;
  Tree2d.OnDeleteValue := OnDeleteBox;
  Rects := TListVec<PBox2d>.Create;
end;

destructor T2DTreeTest.Destroy;
begin
  Rects.Free;
  Tree2d.Free;
  inherited;
end;

function T2DTreeTest.Box(X, Y, Width, Height: int32): PBox2d;
begin
  new(Result);
  Result^ := Box2(X, Y, X + Width, Y + Height);
  Rects.Add(Result);
  Tree2d.Add(Result, PKDMinMax(Result));
end;

procedure T2DTreeTest.FillData;
begin
  Box(100, 150, 300, 350);
  Box(10000, 15000, 30000, 35000);
  Box(10, 15, 30, 35);
  Box(1000, 1500, 3000, 3500);
end;

procedure T2DTreeTest.FillData2;
begin
  Box(226, 1399, 17, 28);
end;

procedure T2DTreeTest.OnDeleteBox(const Value: PBox2d);
begin
  dispose(Value);
end;

procedure T2DTreeTest.Setup;
begin
end;

procedure T2DTreeTest.TearDown;
begin
  Rects.Clear;
  Tree2d.Clear;
  System.Assert(Tree2d.Count = 0);
end;

procedure T2DTreeTest.SetBoxPosition(var viewport: TBox2d; X, Y: double);
var
  size: TVec2d;
begin
  size := viewport.Max - viewport.Min;
  viewport.Min := vec2(X, Y);
  viewport.Max := viewport.Min + size;
end;

procedure T2DTreeTest.SetBoxSize(var viewport: TBox2d; Width, Height: double);
begin
  viewport.Max := viewport.Min + vec2d(Width, Height);
end;

procedure T2DTreeTest.Test1;
var
  viewport: TBox2d;
  selected: TListVec<PBox2d>;
begin
  FillData;
  viewport.Min := vec2(11.0, 12.0);
  viewport.Max := vec2(21.0, 22.0);

  selected := Tree2d.Select(@viewport);
  System.Assert(selected.Count = 0);

  SetBoxPosition(viewport, 10, 10);
  selected := Tree2d.Select(@viewport);
  System.Assert(selected.Count = 1);
  System.Assert(selected.Items[0] = Rects.Items[2]);

  SetBoxPosition(viewport, 40, 51);
  selected := Tree2d.Select(@viewport);
  System.Assert(selected.Count = 0);

  SetBoxSize(viewport, 50000, 50000);
  SetBoxPosition(viewport, 10, 50);
  selected := Tree2d.Select(@viewport);
  System.Assert(selected.Count = 4);

//  SetBoxPosition(viewport, 1000, 1000);
//  selected := Tree2d.Select(@viewport);
//  System.Assert(selected.Count = 2);
end;

procedure T2DTreeTest.Test2;
var
  viewport: TBox2d;
  selected: TListVec<PBox2d>;
begin
  FillData2;
  viewport.Min := vec2(218.0, 3915.0);
  viewport.Max := vec2(418.0, 4065.0);
  selected := Tree2d.Select(@viewport);
  System.Assert(selected.Count = 0);
end;

{ T3DTreeTest }

function T3DTreeTest.Box(X, Y, Z, Width, Height, Deep: Double): PBox3d;
begin
  new(Result);
  Result^ := Box3(vec3(X, Y, Z), vec3(X + Width, Y + Height, Z + Deep));
  Boxes.Add(Result);
  Tree3d.Add(Result, Result^);
end;

constructor T3DTreeTest.Create;
begin
  Boxes := TListVec<PBox3d>.Create;
  Tree3d := T3DTree<PBox3d>.Create;
  Tree3d.OnDeleteValue := OnDeleteBox;
end;

destructor T3DTreeTest.Destroy;
begin
  Boxes.Free;
  Tree3d.Free;
  inherited;
end;

procedure T3DTreeTest.OnDeleteBox(const Value: PBox3d);
begin
  dispose(Value);
end;

procedure T3DTreeTest.SetBoxPosition(var Box: TBox3d; X, Y, Z: double);
var
  size: TVec3d;
begin
  size := Box.Max - Box.Min;
  Box.Min := vec3(X, Y, Z);
  Box.Max := Box.Min + size;
end;

procedure T3DTreeTest.SetBoxSize(var Box: TBox3d; Width, Height, Deep: double);
begin
  Box.Max := Box.Min + vec3d(Width, Height, Deep);
end;

procedure T3DTreeTest.TearDown;
begin
  Boxes.Clear;
  Tree3d.Clear;
end;

procedure T3DTreeTest.TestDeleteNext;
var
  b, next: PBox3d;
begin
  b := Box(10.0, 10.0, 10.0, 100.0, 100.0, 100.0);
  next := Box(0.0, 10.0, 0.0, 100.0, 100.0, 110.0);
  System.Assert(Tree3d.Count = 2);
  Tree3d.Delete(next, next^);
  System.Assert(Tree3d.Count = 1);
end;

procedure T3DTreeTest.TestSelectNext;
var
  next: PBox3d;
  selected: TListVec<PBox3d>;
begin
  //b := Box(10.0, 10.0, 10.0, 100.0, 100.0, 100.0);
  next := Box(50.0, 10.0, 50.0, 150.0, 0.0, 150.0);
  selected := Tree3d.Select(Box3(vec3d(100, 100, 100), vec3d(250, 250, 250)));
  System.Assert(selected.Count = 0);
  selected := Tree3d.Select(Box3(vec3d(100, 5, 100), vec3d(250, 15, 250)));
  System.Assert(selected.Count = 1);
  selected := Tree3d.Select(Box3(vec3d(40, 5, 40), vec3d(60, 15, 60)));
  System.Assert(selected.Count = 1);
  selected := Tree3d.Select(Box3(vec3d(40, 5, 40), vec3d(250, 250, 250)));
  System.Assert(selected.Count = 1);
end;

procedure T3DTreeTest.TestUpdateAndDelete;
var
  b, next: PBox3d;
  oldB: TBox3d;
begin
  b := Box(10.0, 10.0, 10.0, 100.0, 100.0, 100.0);
  oldB := b^;
  SetBoxPosition(b^, 20.0, 20.0, 20.0);
  Tree3d.Update(b, oldB, b^);
  System.Assert(Tree3d.Count = 1);
  Tree3d.Delete(b, b^);
  System.Assert(Tree3d.Count = 0);
end;

end.
