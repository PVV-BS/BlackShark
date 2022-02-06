unit bs.test.align;

interface

uses
    DUnitX.TestFramework
  , bs.basetypes
  , bs.align
  ;

type

  [TestFixture]
  TAlignTest = class(TObject)
  private
    Position: BSFloat;
    Size: BSFloat;
    ParentSize: BSFloat;
    ParentPadding: TVec2f;
    PatternRight: TPattenAlign;
    PatternRight2: TPattenAlign;
  public
    constructor Create;
    destructor Destroy; override;
    //[Setup]
    //procedure Setup;
    //[TearDown]
    //procedure TearDown;
    // Sample Methods
    // Simple single Test
    [Test]
    procedure TestAlignRight;
    [Test]
    [TestCase('TestAlignRightTwoObjects','100, 25, 75, 40, 500, 0, 20')]
    procedure TestAlignRightTwoObjects(
      Position: BSFloat;
      Position2: BSFloat;
      Size: BSFloat;
      Size2: BSFloat;
      ParentSize: BSFloat;
      ParentPaddingLeft: BSFloat;
      ParentPaddingRight: BSFloat);
    [Test]
    procedure TestClient;
    [Test]
    procedure TestCenter;
  end;

implementation

uses
    DUnitX.Assert
  ;

constructor TAlignTest.Create;
begin
  PatternRight := TPattenAlignRight.Create;
  TPattenAlignRight(PatternRight).MarginRight := 10;
  PatternRight2 := TPattenAlignRight.Create;
end;

destructor TAlignTest.Destroy;
begin
  PatternRight.Free;
  inherited;
end;

procedure TAlignTest.TestAlignRight;

  procedure Init;
  begin
    Position := 20;
    ParentSize := 100;
    Size := 45;
    ParentPadding.Left := 0;
    ParentPadding.Right := 20;
  end;

begin
  Init;
  PatternRight.Align(Position, Size, ParentSize, ParentPadding);
  Assert.AreEqual(double(25.0), double(Position));
  Assert.AreEqual(double(45.0), double(Size));
  Init;
  PatternRight.AnchorLeft := true;
  PatternRight.Align(Position, Size, ParentSize, ParentPadding);
  Assert.AreEqual(double(20.0), double(Position));
  Assert.AreEqual(double(50.0), double(Size));
end;

procedure TAlignTest.TestAlignRightTwoObjects(Position, Position2, Size, Size2, ParentSize, ParentPaddingLeft, ParentPaddingRight: BSFloat);
begin
  // 100, 75, 500, 0, 20
  ParentPadding.left := ParentPaddingLeft;
  ParentPadding.right := ParentPaddingRight;
  PatternRight.AnchorLeft := false;
  PatternRight.Align(Position, Size, ParentSize, ParentPadding);
  Assert.AreEqual(double(395.0), double(Position));
  Assert.AreEqual(double(75.0), double(Size));
  Assert.AreEqual(double(105.0), double(ParentPadding.right));
  // 25, 40, 500, 0, 105
  PatternRight2.Align(Position2, Size2, ParentSize, ParentPadding);
  Assert.AreEqual(double(355.0), double(Position2));
  Assert.AreEqual(double(40.0), double(Size2));
  Assert.AreEqual(double(145.0), double(ParentPadding.right));
end;

procedure TAlignTest.TestCenter;
begin

end;

procedure TAlignTest.TestClient;
var
  PatternClient: TPattenAlign;
begin
  Position := 30;
  ParentSize := 300;
  Size := 25;
  ParentPadding.Left := 10;
  ParentPadding.Right := 20;
  PatternClient := TPattenAlignClient.Create;
  PatternClient.Align(Position, Size, ParentSize, ParentPadding);
  Assert.AreEqual(double(10.0), double(Position));
  Assert.AreEqual(double(270.0), double(Size));
  //Assert.AreEqual(double(0.0), double(ParentPaddingRight));
end;

initialization
  //TDUnitX.RegisterTestFixture(TAlignTest);
end.
