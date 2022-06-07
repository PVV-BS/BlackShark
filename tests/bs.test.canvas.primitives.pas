unit bs.test.canvas.primitives;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , bs.test
  , bs.basetypes
  , bs.collections
  , bs.events
  , bs.renderer
  , bs.scene
  , bs.graphics
  , bs.texture
  , bs.canvas
  , bs.font
  , bs.selectors
  ;

type

  TBSTestCanvasPrimitive = class(TBSTest)
  private
    FCanvas: TBCanvas;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    property Canvas: TBCanvas read FCanvas;
  end;

  TBSTestCanvasTriangle = class(TBSTestCanvasPrimitive)
  private
    Triangle: TTriangle;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasLine = class(TBSTestCanvasPrimitive)
  private
    Line: TLine;
    LineStroke: TLine;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasGrid = class(TBSTestCanvasPrimitive)
  private
    Grid: TGrid;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasBiColoredSolidLines = class(TBSTestCanvasPrimitive)
  private
    const
      COUNT_LINES = 2;
      WIDTH_LINE = 10;
  private
    Lines: TBiColoredSolidLines;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasLines = class(TBSTestCanvasPrimitive)
  private
    Lines: TLines;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasLines2 = class(TBSTestCanvasPrimitive)
  private
    Lines: TLines;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasPath = class(TBSTestCanvasPrimitive)
  private
    Path: TPath;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasPathArc = class(TBSTestCanvasPrimitive)
  private
    Path: TPath;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasPathMultiColored = class(TBSTestCanvasPrimitive)
  private
    Path: TPath;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasRoundRect = class(TBSTestCanvasPrimitive)
  private
    RoundRect: TRoundRect;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasRoundRectTextured = class(TBSTestCanvasPrimitive)
  private
    RoundRect: TRoundRectTextured;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasTexuredCircle = class(TBSTestCanvasPrimitive)
  private
    Circle: TCircleTextured;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestCanvasArrow = class(TBSTestCanvasPrimitive)
  private
    Arrow: TArrow;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestArc = class(TBSTestCanvasPrimitive)
  private
    Arc: TArc;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestArcPos = class(TBSTestCanvasPrimitive)
  private
    Arc: TArc;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestBezier = class(TBSTestCanvasPrimitive)
  private
    BezierL: TBezierLine;
    BezierQ: TBezierQuadratic;
    BezierC: TBezierCubic;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestRectangle = class(TBSTestCanvasPrimitive)
  private
    Rectangle: TRectangle;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestRectTextured = class(TBSTestCanvasPrimitive)
  private
    Rectangle: TRectangleTextured;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestPicture = class(TBSTestCanvasPrimitive)
  private
    Picture: TPicture;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestTrapeze = class(TBSTestCanvasPrimitive)
  private
    Trapeze: TTrapeze;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestTrapezeRound = class(TBSTestCanvasPrimitive)
  private
    Trapeze: TRoundTrapeze;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestText = class(TBSTestCanvasPrimitive)
  private
    Text: TCanvasText;
    Text2: TCanvasText;
    ObsrvChangeFont: IBEmptyEventObserver;
    ObsrvChangeFont2: IBEmptyEventObserver;
    procedure OnChangeFontEvent({%H}const Value: BEmpty);
    procedure OnChangeFontEvent2({%H}const Value: BEmpty);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestTextScalable = class(TBSTestCanvasPrimitive)
  private
    Text: TCanvasText;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  TBSTestLayout = class(TBSTestCanvasPrimitive)
  private
    Selector: TBlackSharkSelectorInstances;
    SelectorsBB: TListVec<TBlackSharkSelectorBB>;
    SelectorsBBVisible: TListVec<Pointer>;
    function OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
    procedure UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
    procedure OnResizeObject(Instance: PGraphicInstance; const Scale: TVec3f; const Point: TBBLimitPoint);
    function GetSelector: TBlackSharkSelectorBB;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    class function TestName: string; override;
  end;

  TBSTestFreeShape = class(TBSTestCanvasPrimitive)
  private
    FreeShape: TFreeShape;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestFreeShape2 = class(TBSTestCanvasPrimitive)
  private
    FreeShape: TFreeShape;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    bs.config
  , bs.align
  , bs.utils
  , bs.mesh.primitives
  ;

{ TBSTestCanvasPrimitive }

constructor TBSTestCanvasPrimitive.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Allow3dManipulationByMouse := true;
  //Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 90, Renderer.Frustum.Angle.z);
  FCanvas := TBCanvas.Create(Renderer, Self);
  FCanvas.StickOnScreen := false;
  //FCanvas.Scalable := true;
end;

destructor TBSTestCanvasPrimitive.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

function TBSTestCanvasPrimitive.Run: boolean;
begin
  Result := true;
end;

{ TBSTestCanvasTriangle }

constructor TBSTestCanvasTriangle.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Triangle := TTriangle.Create(Canvas, nil);
  Triangle.Color := BS_CL_SKY;
  Triangle.Fill := True;
  //Triangle.Data.ScaleSimple := 0.5;
  Triangle.C := vec2(0, 300);
  Triangle.B := vec2(150, 0);
  Triangle.A := vec2(300, 300);
  if Canvas.Scalable then
    Triangle.AnchorsReset;
  Triangle.Build;
  //Triangle.Position2d := vec2(Renderer.WindowWidth * 0.1, Renderer.WindowHeight * 0.1);
end;

class function TBSTestCanvasTriangle.TestName: string;
begin
  Result := 'Test Canvas TTriangle';
end;

{ TBSTestCanvasLine }

constructor TBSTestCanvasLine.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  Line := TLine.Create(Canvas, nil);
  Line.A := vec2(10, 30);
  Line.B := vec2(230, 400);
  Line.WidthLine := 3;
  if Canvas.Scalable then
    Line.AnchorsReset;
  Line.Build;
  Line.Position2d := vec2(100, 100);

  LineStroke := TLine.Create(Canvas, nil);
  LineStroke.WidthLine := 5.0;
  LineStroke.StrokeLength := 10.0;
  LineStroke.B := vec2(110.0, 300.0);
  LineStroke.A := vec2(320.0, 60.0);
  LineStroke.Color := BS_CL_ORANGE;
  LineStroke.Build;
  if Canvas.Scalable then
    LineStroke.AnchorsReset;
end;

class function TBSTestCanvasLine.TestName: string;
begin
  Result := 'Test Canvas TLine';
end;

{ TBSTestCanvasGrid }

constructor TBSTestCanvasGrid.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas.Scalable := true;
  Grid := TGrid.Create(Canvas, nil);
  Grid.Size := vec2(300, 300);
  Grid.StepX := 10;
  Grid.StepY := 10;
  Grid.WidthLines := 2;
  Grid.VertLines := true;
  Grid.HorLines := true;
  Grid.Closed := true;
  if Canvas.Scalable then
    Grid.AnchorsReset;
  Grid.Build;
end;

class function TBSTestCanvasGrid.TestName: string;
begin
  Result := 'Test Canvas TGrid';
end;

{ TBSTestCanvasBiColoredSolidLines }

constructor TBSTestCanvasBiColoredSolidLines.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Lines := TBiColoredSolidLines.Create(Canvas, nil);
  Lines.LineWidth := WIDTH_LINE;
  Lines.Draw(200, false, COUNT_LINES);
  if Canvas.Scalable then
    Lines.AnchorsReset;
  Lines.Position2d := vec2(0.0, 0.0);
end;

class function TBSTestCanvasBiColoredSolidLines.TestName: string;
begin
  Result := 'Test Canvas TBiColoredSolidLines';
end;

{ TBSTestCanvasLines }

constructor TBSTestCanvasLines.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas.Scalable := false;
  Lines := TLines.Create(Canvas, nil);
  if Canvas.Scalable then
    Lines.AnchorsReset;
  Lines.BeginUpdate;
  Lines.AddLine(vec2(30.0, 100.0), vec2(150.0, 340.0));
  Lines.AddLine(vec2(380.0, 110.0), vec2(56.0, 240.0));
  Lines.EndUpdate;
end;

class function TBSTestCanvasLines.TestName: string;
begin
  Result := 'Test Canvas TLines';
end;

{ TBSTestCanvasPath }

constructor TBSTestCanvasPath.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Path := TPath.Create(Canvas, nil);
  Path.Closed := true;
  //Path.WidthLine := 3.0;
  Path.ShowPoints := true;
  Path.InterpolateSpline := TInterpolateSpline.isNone;
  Path.AddPoint(vec2(100.0, 200.0));
  Path.AddPoint(vec2(200.0, 200.0));
  Path.AddPoint(vec2(200.0, 300.0));
  //Path.AddPoint(vec2(100.0, 300.0));
  if Canvas.Scalable then
    Path.AnchorsReset;
  Path.Build;
end;

class function TBSTestCanvasPath.TestName: string;
begin
  Result := 'Test Canvas TPath';
end;

{ TBSTestCanvasPathArc }

constructor TBSTestCanvasPathArc.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Allow3dManipulationByMouse := true;
  Renderer.Frustum.DistanceFarPlane := 200;
  Canvas.StickOnScreen := false;
  Path := TPath.Create(Canvas, nil);
  Path.WidthLine := 3.0;
  Path.InterpolateSpline := TInterpolateSpline.isNone;
  //Path.AddPoint(vec2(0.0, 0.0));
  //Path.AddPoint(vec2(150.0, 100.0));
  Path.AddFirstArc(vec2(140.0, 150.0), 70.0, 190.0, 30);
  Path.AddArc(100.0, 30.0);
  Path.AddArc(150.0, -60.0);
  Path.AddArc(70.0, 50.0);
  Path.AddArc(90.0, 160.0);
  Path.AddArc(120.0, 130.0);
  Path.AddArc(100.0, -130.0);
  if Canvas.Scalable then
    Path.AnchorsReset;
  Path.Build;
end;

class function TBSTestCanvasPathArc.TestName: string;
begin
  Result := 'Test Canvas TPath.AddArc';
end;

{ TBSTestCanvasPathMultiColored }

constructor TBSTestCanvasPathMultiColored.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Allow3dManipulationByMouse := true;
  Renderer.Frustum.DistanceFarPlane := 200;
  Canvas.StickOnScreen := false;
  Path := TPath.Create(Canvas, nil);
  Path.InterpolateSpline := TInterpolateSpline.isNone;
  //Path.Data.ScaleSimple := 5.0;
  //Path.ShowPoints := true;
  Path.InterpolateFactor := 0.4;
  Path.WidthLine := 1.0;
  Path.StrokeLength := 10;
  Path.Color := BS_CL_GREEN;
  //Path.AddPoint(vec2(0.0, 0.0));
  //Path.AddPoint(vec2(150.0, 100.0));
  Path.AddFirstArc(vec2(140.0, 150.0), 70.0, 190.0, 30, BS_CL_GREEN);
  Path.AddArc(100.0, 30.0, BS_CL_ORANGE);
  Path.AddArc(150.0, -60.0, BS_CL_YELLOW);
  Path.AddArc(70.0, 50.0, BS_CL_SILVER);
  Path.AddArc(90.0, 160.0, BS_CL_OLIVE);
  Path.AddArc(120.0, 130.0, BS_CL_AQUA);
  Path.AddArc(100.0, -130.0, BS_CL_PURPLE);
  { adding a small snippet; this trick allows to exclude long interpolates colors between segments }
  Path.AddPoint(vec2(200.0, 360.0), TGuiColors.Green);

  Path.AddPoint(vec2(250.0, 360.0), TGuiColors.Yellow);
  Path.AddPoint(vec2(290.0, 200.0));
  {Path.AddPoint(vec2(290.0, 230.0));

  Path.AddPoint(vec2(310.0, 250.0), TGuiColors.Navy);
  Path.AddPoint(vec2(340.0, 260.0));  }

  if Canvas.Scalable then
    Path.AnchorsReset;

  Path.Build;
end;

class function TBSTestCanvasPathMultiColored.TestName: string;
begin
  Result := 'Test bs.canvas.TPathMulticolored';
end;

{ TBSTestCanvasRoundRect }

constructor TBSTestCanvasRoundRect.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas.Scalable := false;
  RoundRect := TRoundRect.Create(Canvas, nil);
  RoundRect.Size := vec2(200.0, 300.0);
  RoundRect.WidthLine := 5.0;
  //RoundRect.Fill := true;
  RoundRect.Position2d := vec2(0.0, 0.0);
  //RoundRect.Data.Opacity := 0.3;
  //RoundRect.RadiusRound := 0;
  if Canvas.Scalable then
    RoundRect.AnchorsReset;
  RoundRect.Build;
end;

class function TBSTestCanvasRoundRect.TestName: string;
begin
  Result := 'Test Canvas TRoundRect';
end;

{ TBSTestCanvasRoundRectTextured }

constructor TBSTestCanvasRoundRectTextured.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  RoundRect := TRoundRectTextured.Create(Canvas, nil);
  RoundRect.Size := vec2(200.0, 300.0);
  RoundRect.Fill := true;
  RoundRect.Position2d := vec2(150.0, 180.0);
  RoundRect.Texture := BSTextureManager.GenerateTexture(BS_CL_BLUE, BS_CL_ORANGE_2, TGradientType.gtRadialSquare, 32);
  if Canvas.Scalable then
    RoundRect.AnchorsReset;
  RoundRect.Build;
end;

class function TBSTestCanvasRoundRectTextured.TestName: string;
begin
  Result := 'Test Canvas TRoundRectTextured';
end;

{ TBSTestCanvasTexuredCircle }

constructor TBSTestCanvasTexuredCircle.Create(ARenderer: TBlackSharkRenderer);
var
  f_tex: string;
begin
  inherited;
  Circle := TCircleTextured.Create(Canvas, nil);
  Circle.Fill := true;
  if Canvas.Scalable then
    Circle.AnchorsReset;
  f_tex := GetFilePath('Pictures\point_red_7x7.png');
  if FileExists(f_tex) then
  begin
    Circle.Texture := BSTextureManager.LoadTexture(f_tex, true, true);
    Circle.Radius := round(Circle.Texture.Rect.Width) shr 1 + 1;
    Circle.Build;
    Circle.Position2d := vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
  end;
end;

class function TBSTestCanvasTexuredCircle.TestName: string;
begin
  Result := 'Test Canvas TCircleTextured';
end;

{ TBSTestCanvasArrow }

constructor TBSTestCanvasArrow.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Arrow := TArrow.Create(Canvas, nil);
  Arrow.A := vec2(100.0, 150.0);
  Arrow.B := vec2(300.0, 350.0);
  Arrow.SizeTip := vec2(10.0, 20.0);
  if Canvas.Scalable then
    Arrow.AnchorsReset;
  Arrow.Build;
end;

class function TBSTestCanvasArrow.TestName: string;
begin
  Result := 'Test Canvas TArrow';
end;

{ TBSTestArc }

constructor TBSTestArc.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Arc := TArc.Create(Canvas, nil);
  Arc.Radius := 200.0;
  Arc.Angle := 120;
  Arc.Fill := true;
  Arc.Color := BS_CL_RED;
  if Canvas.Scalable then
    Arc.AnchorsReset;
  Arc.Build;
  Arc.Position2d := vec2(10.0, 10.0);

  Arc := TArc.Create(Canvas, nil);
  Arc.Radius := 100.0;
  Arc.StartAngle := 150;
  Arc.LineWidth := 5;
  Arc.Angle := 80;
  Arc.Fill := false;
  Arc.Color := BS_CL_GREEN;
  if Canvas.Scalable then
    Arc.AnchorsReset;
  Arc.Build;
  Arc.Position2d := vec2(300.0, 250.0);
end;

class function TBSTestArc.TestName: string;
begin
  Result := 'Test Canvas TArc';
end;

{ TBSTestArcPos }

constructor TBSTestArcPos.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  // TODO: autotest
  Arc := TArc.Create(Canvas, nil);
  Arc.InterpolateFactor := 0.98;
  Arc.Radius := 200.0;
  Arc.Angle := 120;
  Arc.StartAngle := 200;
  Arc.Fill := true;
  Arc.Color := BS_CL_RED;
  if Canvas.Scalable then
    Arc.AnchorsReset;
  Arc.Build;
  Arc.Position2dCenter := vec2(250.0, 160.0);

  Arc := TArc.Create(Canvas, nil);
  Arc.Radius := 200.0;
  Arc.Angle := 120;
  Arc.StartAngle := 200;
  Arc.Fill := false;
  Arc.Color := BS_CL_RED;
  if Canvas.Scalable then
    Arc.AnchorsReset;
  Arc.Build;
  Arc.Layer2d := 2;
  Arc.Color := BS_CL_GREEN;
  Arc.Position2dCenter := vec2(250.0, 160.0);
end;

class function TBSTestArcPos.TestName: string;
begin
  Result := 'Test bs.canvas.TArc.Position2dCenter';
end;

{ TBSTestBezier }

constructor TBSTestBezier.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  BezierL := TBezierLine.Create(Canvas, nil);
  BezierL.A := vec2(100.0, 100.0);
  BezierL.B := vec2(200.0, 200.0);
  BezierL.ShowPoints := true;
  if Canvas.Scalable then
    BezierL.AnchorsReset;
  BezierL.Build;
  BezierL.Data.Caption := 'BezierL';
  BezierL.Position2d := vec2(300, 300);

  BezierQ := TBezierQuadratic.Create(Canvas, nil);
  BezierQ.Color := BS_CL_SKY_BLUE;
  BezierQ.A := vec2(0.0, 300.0);
  BezierQ.B := vec2(200.0, 50.0);
  BezierQ.C := vec2(430.0, 300.0);
  BezierQ.Quality := 0.02;
  BezierQ.ShowPoints := true;
  if Canvas.Scalable then
    BezierQ.AnchorsReset;
  BezierQ.Build;
  BezierQ.Data.Caption := 'BezierQ';

  BezierC := TBezierCubic.Create(Canvas, nil);
  BezierC.Color := BS_CL_MONEY_GREEN;
  BezierC.A := vec2(100.0, 420.0);
  BezierC.B := vec2(420.0, 350.0);
  BezierC.C := vec2(100.0, 100.0);
  BezierC.D := vec2(350.0, 500.0);
  BezierC.Quality := 0.03;
  BezierC.Color := BS_CL_ORANGE_2;
  BezierC.WidthLine := 3.0;
  BezierC.ShowPoints := true;
  if Canvas.Scalable then
    BezierC.AnchorsReset;
  BezierC.Build;
end;

class function TBSTestBezier.TestName: string;
begin
  Result := 'Test Canvas Bezier lines';
end;

{ TBSTestRectTextured }

constructor TBSTestRectTextured.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Rectangle := TRectangleTextured.Create(Canvas, nil);
  Rectangle.Texture := BSTextureManager.LoadTexture(GetFilePath('Pictures\snowflake.png'), true, true);
  Rectangle.Size := Rectangle.Texture.Rect.Size;
  { we can set single color for texture by two properties below }
  Rectangle.ReplaceColor := true;
  Rectangle.Color := BS_CL_ORANGE_2;
  if Canvas.Scalable then
    Rectangle.AnchorsReset;
  Rectangle.Build;
end;

class function TBSTestRectTextured.TestName: string;
begin
  Result := 'Test Canvas TRectangleTextured';
end;

{ TBSTestPicture }

constructor TBSTestPicture.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  //Canvas.Scalable := true;
  Picture := TPicture.Create(Canvas, nil);
  Picture.Size := vec2(300.0, 300.0);
  Picture.AutoFit := false;
  Picture.WrapReapeated := true;
  if Canvas.Scalable then
    Picture.AnchorsReset;
  Picture.LoadFromFile(GetFilePath('Pictures\snowflake.png'));
end;

class function TBSTestPicture.TestName: string;
begin
  Result := 'Test Canvas TPicture';
end;

{ TBSTestTrapeze }

constructor TBSTestTrapeze.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Trapeze := TTrapeze.Create(Canvas, nil);
  Trapeze.Fill := true;
  Trapeze.UpperBase := 200.0;
  Trapeze.LowerBase := 300.0;
  Trapeze.HeightBwBases := 100.0;
  if Canvas.Scalable then
    Trapeze.AnchorsReset;
  Trapeze.Build;
  Trapeze.Position2d := vec2(10.0, 20.0);
end;

class function TBSTestTrapeze.TestName: string;
begin
  Result := 'bs.canvas.TTrapeze test';
end;

{ TBSTestTrapezeRound }

constructor TBSTestTrapezeRound.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Trapeze := TRoundTrapeze.Create(Canvas, nil);
  Trapeze.Fill := true;
  Trapeze.UpperBase := 200.0;
  Trapeze.LowerBase := 300.0;
  Trapeze.HeightBwBases := 100.0;
  if Canvas.Scalable then
    Trapeze.AnchorsReset;
  Trapeze.Build;
  Trapeze.Position2d := vec2(120.0, 120.0);
end;

class function TBSTestTrapezeRound.TestName: string;
begin
  Result := 'bs.canvas.TRoundTrapeze test';
end;

{ TBSTestText }

constructor TBSTestText.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Text := TCanvasText.Create(Canvas, nil);
  Text.CreateCustomFont;
  //Text.Text := chr($D803)+chr($DC0C);
  Text.Text := 'Hello, world!';
  ObsrvChangeFont := CreateEmptyObserver(Text.Font.OnChangeEvent, OnChangeFontEvent);
  Text2 := TCanvasText.Create(Canvas, nil);
  Text2.CreateCustomFont;
  Text2.Text := 'Hi, people!';
  Text2.Position2d := vec2(20, 100);
  ObsrvChangeFont2 := CreateEmptyObserver(Text2.Font.OnChangeEvent, OnChangeFontEvent2);
end;

procedure TBSTestText.OnChangeFontEvent(const Value: BEmpty);
begin
  Text.Text := 'Hello, world! (' + IntToStr(Text.Font.SizeInPixels) + ')';
end;

procedure TBSTestText.OnChangeFontEvent2(const Value: BEmpty);
begin
  Text2.Text := 'Hi, people! (' + IntToStr(Text2.Font.SizeInPixels) + ')';
end;

class function TBSTestText.TestName: string;
begin
  Result := 'bs.canvas.TCanvasText test';
end;

{ TBSTestRectangle }

constructor TBSTestRectangle.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Rectangle := TRectangle.Create(Canvas, nil);
  Rectangle.Fill := false;
  Rectangle.Size := vec2(150.0, 200.0);
  Rectangle.Build;
  Rectangle.Position2d := vec2(100.0, 250.0);
end;

class function TBSTestRectangle.TestName: string;
begin
  Result := 'bs.canvas.TRectangle test';
end;

{ TBSTestTextScalable }

constructor TBSTestTextScalable.Create(ARenderer: TBlackSharkRenderer);
var
  Rectangle: TRectangle;
begin
  inherited;
  Canvas.Scalable := true;

  Rectangle := TRectangle.Create(Canvas, nil);
  Rectangle.Color := BS_CL_BLUE;
  Rectangle.Data.Opacity := 0.3;
  Rectangle.Fill := true;
  Rectangle.Size := vec2(500, 400);
  Rectangle.Build;
  Rectangle.Data.Interactive := true;
  Rectangle.Position2d := vec2(20.0, 20.0);

  Text := TCanvasText.Create(Canvas, Rectangle);
  Text.Text := 'Test TCanvasText in scalable mode';
  Text.Data.Interactive := true;
  //Text.CreateCustomFont;
  Text.Position2d := vec2(40.0, 300.0);
  //Text.ToParentCenter;

end;

class function TBSTestTextScalable.TestName: string;
begin
  Result := 'Test bs.canvas.TCanvasText in scalable mode';
end;

{ TBSTestLayout }

constructor TBSTestLayout.Create(ARenderer: TBlackSharkRenderer);
var
  layout: TCanvasLayout;
  root: TRectangle;
  child: TRectangle;
begin
  inherited;
  Canvas.Scalable := false;
  Selector := TBlackSharkSelectorInstances.Create(Canvas, nil);
  Selector.OnSelectInstance := OnSelectInstance;
  Selector.OnUnSelectInstance := UnSelectInstance;
  SelectorsBB := TListVec<TBlackSharkSelectorBB>.Create;
  SelectorsBBVisible := TListVec<Pointer>.Create(@PtrCmp);

  root := TRectangle.Create(Canvas, nil);
  root.Size := vec2(300.0, 300.0);
  root.Fill := true;
  root.Position2d := vec2(20.0, 20.0);
  root.BanScalableMode := true;
  root.Build;
  //root.Anchors[aRight] := true;
  //root.Anchors[aBottom] := true;

  layout := TCanvasLayout.Create(Canvas, root);
  layout.Size := vec2(120, 150);
  layout.BanScalableMode := true;
  layout.Build;
  layout.Align := TObjectAlign.oaLeft;

  child := TRectangle.Create(Canvas, layout);
  child.Fill := false;
  child.WidthLine := 3;
  child.Color := BS_CL_AQUA;
  child.Size := vec2(30, 30);
  child.Build;
  //child.Position2d := vec2(50, 60);
  child.Align := TObjectAlign.oaTop;

  child := TRectangle.Create(Canvas, layout);
  child.Fill := false;
  child.WidthLine := 3;
  child.Size := vec2(30, 50);
  child.Color := BS_CL_OLIVE;
  child.Build;
  child.MarginTop := 5;
  child.MarginBottom := 15;
  child.Align := TObjectAlign.oaBottom;

  child := TRectangle.Create(Canvas, layout);
  child.Fill := false;
  child.WidthLine := 3;
  child.Size := vec2(30, 50);
  child.Color := BS_CL_OLIVE;
  child.Build;
  child.Align := TObjectAlign.oaBottom;

end;

destructor TBSTestLayout.Destroy;
var
  i: int32;
begin
  Selector.Free;

  for i := SelectorsBBVisible.Count - 1 downto 0 do
    TBlackSharkSelectorBB(SelectorsBBVisible.Items[i]).SelectItem := nil;

  for i := 0 to SelectorsBB.Count - 1 do
    SelectorsBB.Items[i].Free;

  SelectorsBB.Free;
  SelectorsBBVisible.Free;
  inherited;
end;

function TBSTestLayout.GetSelector: TBlackSharkSelectorBB;
begin
  if SelectorsBB.Count > 0 then
    Result := SelectorsBB.Pop
  else
    Result := TBlackSharkSelectorBB.Create(Canvas);
  Result.FixOppositeSideWhenResize := true;
  Result.OnResizeGraphicObjectInstance := OnResizeObject;
end;

procedure TBSTestLayout.OnResizeObject(Instance: PGraphicInstance; const Scale: TVec3f; const Point: TBBLimitPoint);
var
  delta: TVec2f;
  new_s, Pos, pos_old: TVec2i;
  co: TCanvasObject;
  obj_size: TVec2f;
begin
  co := TCanvasObject(Instance.Owner.Owner);
  if Canvas.Scalable and not co.BanScalableMode and not co.BanScalableModeSize then
    obj_size := vec2(co.Width*Canvas.ScaleInv, co.Height*Canvas.ScaleInv)
  else
    obj_size := vec2(co.Width, co.Height);

  new_s := vec2(obj_size.Width * Scale.X, obj_size.Height * Scale.Y);
  delta := new_s - vec2(obj_size.Width, obj_size.Height);
  pos_old := co.Position2d;
  co.Resize(new_s.X, new_s.Y);
  if co.Align = TObjectAlign.oaNone then
  begin
    if ((Point[0] = xMin) or (Point[1] = yMax)) then
    begin
      if (Point[0] = xMid) and (Point[1] = yMax) then { drag to the up }
        Pos := vec2(pos_old.X, pos_old.Y - delta.Y)
      else if (Point[0] = xMin) and (Point[1] = yMid) then { drag to the left }
        Pos := vec2(pos_old.X - delta.X, pos_old.Y)
      else if (Point[0] = xMax) and (Point[1] = yMax) then { drag to the up-right }
        Pos := vec2(pos_old.X, pos_old.Y - delta.Y)
      else if (Point[0] = xMin) and (Point[1] = yMax) then { drag to the up-left }
        Pos := vec2(pos_old.X - delta.X, pos_old.Y - delta.Y)
      else if (Point[0] = xMin) and (Point[1] = yMin) then { drag to the down-left }
        Pos := vec2(pos_old.X - delta.X, pos_old.Y)
      else
        Pos := pos_old;
    end
    else
      Pos := pos_old;

    co.Position2d := pos;
  end;
end;

function TBSTestLayout.OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
var
  res: TBlackSharkSelectorBB;
begin
  res := GetSelector;
  res.SelectItem := Instance;
  SelectorsBBVisible.Add(res);
  Instance.Instance.Owner.TagPtr := res;
  Result := res;
end;

class function TBSTestLayout.TestName: string;
begin
  Result := 'bs.canvas.TCanvasLayout test';
end;

procedure TBSTestLayout.UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
var
  sel: TBlackSharkSelectorBB;
begin
  sel := Associate;
  sel.SelectItem := nil;
  SelectorsBB.Add(sel);
  SelectorsBBVisible.Remove(sel);
end;

{ TBSTestFreeShapeBase }

constructor TBSTestFreeShape.Create(ARenderer: TBlackSharkRenderer);
var
  mouth: TFreeShape;
begin
  inherited;
  Renderer.Color := BS_CL_SKY_BLUE;
  FreeShape := TFreeShape.Create(Canvas, nil);
  FreeShape.Interpolate := TInterpolateSpline.isCubicHermite;
  // body
  FreeShape.BeginContour;

  {
  FreeShape.AddPoint(vec2(60, 180));
  FreeShape.AddPoint(vec2(70, 210));
  FreeShape.AddPoint(vec2(90, 240));
  FreeShape.AddPoint(vec2(100, 250));
  FreeShape.AddPoint(vec2(120, 280));
  FreeShape.AddPoint(vec2(150, 300));
  FreeShape.AddPoint(vec2(170, 310));
  FreeShape.AddPoint(vec2(190, 290));
  FreeShape.AddPoint(vec2(210, 280));
  FreeShape.AddPoint(vec2(240, 260));
  FreeShape.AddPoint(vec2(200, 240));
  FreeShape.AddPoint(vec2(220, 220));
  FreeShape.AddPoint(vec2(240, 200));
  FreeShape.AddPoint(vec2(280, 180));
  FreeShape.AddPoint(vec2(300, 150));
  FreeShape.AddPoint(vec2(250, 120));
  FreeShape.AddPoint(vec2(200, 20));
  FreeShape.AddPoint(vec2(120, 50));
  FreeShape.AddPoint(vec2(50, 80));
  FreeShape.AddPoint(vec2(25, 100));
  }
  FreeShape.AddPoint(vec2(005, 693));
  FreeShape.AddPoint(vec2(157, 600));
  FreeShape.AddPoint(vec2(143, 525));
  FreeShape.AddPoint(vec2(191, 449));
  FreeShape.AddPoint(vec2(277, 353));
  FreeShape.AddPoint(vec2(439, 263));
  FreeShape.AddPoint(vec2(575, 125));
  FreeShape.AddPoint(vec2(605, 277));
  FreeShape.AddPoint(vec2(707, 357));
  FreeShape.AddPoint(vec2(761, 443));
  FreeShape.AddPoint(vec2(770, 455));
  FreeShape.AddPoint(vec2(810, 485));
  FreeShape.AddPoint(vec2(818, 529));
  FreeShape.AddPoint(vec2(821, 581));
  FreeShape.AddPoint(vec2(965, 675));
  FreeShape.AddPoint(vec2(790, 680));
  FreeShape.AddPoint(vec2(475, 785));
  FreeShape.AddPoint(vec2(205, 685));
  //FreeShape.AddPoint(vec2(005, 693));
  FreeShape.EndContour;

  // eyes
  // left
  FreeShape.BeginContour;
  FreeShape.AddPoint(vec2(410, 461));
  FreeShape.AddPoint(vec2(421, 449));
  FreeShape.AddPoint(vec2(397, 400));
  FreeShape.AddPoint(vec2(377, 382));
  FreeShape.AddPoint(vec2(360, 373));
  FreeShape.AddPoint(vec2(344, 376));
  FreeShape.AddPoint(vec2(338, 381));
  FreeShape.AddPoint(vec2(336, 401));
  FreeShape.AddPoint(vec2(340, 427));
  FreeShape.AddPoint(vec2(353, 442));
  FreeShape.AddPoint(vec2(374, 456));
  FreeShape.AddPoint(vec2(397, 459));
  FreeShape.EndContour;

  FreeShape.BeginContour;
  FreeShape.AddPoint(vec2(388, 448));
  FreeShape.AddPoint(vec2(377, 445));
  FreeShape.AddPoint(vec2(374, 429));
  FreeShape.AddPoint(vec2(385, 418));
  FreeShape.AddPoint(vec2(390, 418));
  FreeShape.AddPoint(vec2(401, 426));
  FreeShape.AddPoint(vec2(405, 440));
  FreeShape.AddPoint(vec2(403, 445));
  FreeShape.AddPoint(vec2(397, 447));
  FreeShape.EndContour;

  // right
  FreeShape.BeginContour;
  FreeShape.AddPoint(vec2(583, 480));
  FreeShape.AddPoint(vec2(593, 480));
  FreeShape.AddPoint(vec2(613, 481));
  FreeShape.AddPoint(vec2(630, 477));
  FreeShape.AddPoint(vec2(652, 467));
  FreeShape.AddPoint(vec2(668, 439));
  FreeShape.AddPoint(vec2(669, 414));
  FreeShape.AddPoint(vec2(658, 405));
  FreeShape.AddPoint(vec2(648, 403));
  FreeShape.AddPoint(vec2(624, 412));
  FreeShape.AddPoint(vec2(600, 429));
  FreeShape.AddPoint(vec2(581, 452));
  FreeShape.AddPoint(vec2(575, 463));
  FreeShape.AddPoint(vec2(576, 475));
  FreeShape.EndContour;

  FreeShape.BeginContour;
  FreeShape.AddPoint(vec2(603, 471));
  FreeShape.AddPoint(vec2(593, 465));
  FreeShape.AddPoint(vec2(594, 452));
  FreeShape.AddPoint(vec2(607, 441));
  FreeShape.AddPoint(vec2(620, 445));
  FreeShape.AddPoint(vec2(624, 451));
  FreeShape.AddPoint(vec2(623, 459));
  FreeShape.AddPoint(vec2(619, 470));
  FreeShape.AddPoint(vec2(612, 470));
  FreeShape.EndContour;

  FreeShape.Build;

  FreeShape.Color := BS_CL_BLACK;
  FreeShape.Position2d := vec2(10.0, 10.0);

  mouth := TFreeShape.Create(Canvas, FreeShape);
  mouth.Interpolate := TInterpolateSpline.isCubicHermite;
  mouth.BeginContour;
  mouth.AddPoint(vec2(218, 511));
  mouth.AddPoint(vec2(282, 545));
  mouth.AddPoint(vec2(365, 576));
  mouth.AddPoint(vec2(419, 591));

  mouth.AddPoint(vec2(498, 602));

  mouth.AddPoint(vec2(588, 590));
  mouth.AddPoint(vec2(689, 550));

  mouth.AddPoint(vec2(731, 518));
  mouth.AddPoint(vec2(691, 594));
  mouth.AddPoint(vec2(629, 678));
  mouth.AddPoint(vec2(560, 733));
  mouth.AddPoint(vec2(538, 741));

  mouth.AddPoint(vec2(507, 745));

  mouth.AddPoint(vec2(475, 743));
  mouth.AddPoint(vec2(440, 732));
  mouth.AddPoint(vec2(403, 715));
  mouth.AddPoint(vec2(317, 653));
  mouth.AddPoint(vec2(259, 585));
  mouth.AddPoint(vec2(232, 536));

  mouth.EndContour;
  mouth.Build;
  //mouth.Data.ScaleSimple := 0.5;
  mouth.Color := BS_CL_RED;
  mouth.Position2d := vec2(218-5, 511-125);

  //FreeShape.Data.ScaleSimple := 0.5;

end;

destructor TBSTestFreeShape.Destroy;
begin

  inherited;
end;

function TBSTestFreeShape.Run: boolean;
begin
  Result := true;
end;

class function TBSTestFreeShape.TestName: string;
begin
  Result := 'bs.canvas.TFreeShape test';
end;

{ TBSTestCanvasLines2 }

constructor TBSTestCanvasLines2.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Lines := TLines.Create(Canvas, nil);
  if Canvas.Scalable then
    Lines.AnchorsReset;
  Lines.BeginUpdate;
  //Lines.AddLine(vec2(0.0, 2.0), vec2(5.0, 2.0));
  //Lines.AddLine(vec2(2.0, 0.0), vec2(2.0, 5.0));
  Lines.LinesWidth := 10;
  Lines.AddLine(vec2(0.0, 25.0), vec2(50.0, 25.0));
  Lines.AddLine(vec2(25.0, 0.0), vec2(25.0, 50.0));
  Lines.EndUpdate;
  Lines.Position2d := vec2(10.0, 10.0);
  //Lines.Position2d := vec2(4.0, 7.0);
  //Lines.ToParentCenter;
end;

class function TBSTestCanvasLines2.TestName: string;
begin
  Result := 'bs.canvas.TLines test2';
end;

{ TBSTestFreeShape2 }

constructor TBSTestFreeShape2.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  FreeShape := TFreeShape.Create(Canvas, nil);
  FreeShape.Interpolate := TInterpolateSpline.isNone;
  // body
  FreeShape.BeginContour;

  FreeShape.AddPoint(vec2(0.0, 0.0));
  FreeShape.AddPoint(vec2(10.0, 0.0));
  FreeShape.AddPoint(vec2(10.0, 30.0));
  FreeShape.AddPoint(vec2(12.0, 32.0));
  FreeShape.AddPoint(vec2(18.0, 32.0));
  FreeShape.AddPoint(vec2(20.0, 34.0));
  FreeShape.AddPoint(vec2(20.0, 42.0));
  FreeShape.AddPoint(vec2(18.0, 44.0));
  FreeShape.AddPoint(vec2(12.0, 44.0));
  FreeShape.AddPoint(vec2(10.0, 46.0));
  FreeShape.AddPoint(vec2(10.0, 54.0));
  FreeShape.AddPoint(vec2(12.0, 56.0));
  FreeShape.AddPoint(vec2(18.0, 56.0));
  FreeShape.AddPoint(vec2(20.0, 58.0));
  FreeShape.AddPoint(vec2(20.0, 66.0));
  FreeShape.AddPoint(vec2(18.0, 68.0));
  FreeShape.AddPoint(vec2(12.0, 68.0));
  FreeShape.AddPoint(vec2(10.0, 70.0));
  FreeShape.AddPoint(vec2(10.0, 100.0));
  FreeShape.AddPoint(vec2(0.0, 100.0));

  FreeShape.EndContour;
  FreeShape.Build;
end;

destructor TBSTestFreeShape2.Destroy;
begin
  FreeShape.Free;
  inherited;
end;

function TBSTestFreeShape2.Run: boolean;
begin
  Result := true;
end;

class function TBSTestFreeShape2.TestName: string;
begin
  Result := 'Test number 2 TFreeShape';
end;

initialization
  RegisterTest(TBSTestCanvasTriangle);
  RegisterTest(TBSTestCanvasLine);
  RegisterTest(TBSTestCanvasGrid);
  RegisterTest(TBSTestCanvasBiColoredSolidLines);
  RegisterTest(TBSTestCanvasLines);
  RegisterTest(TBSTestCanvasLines2);
  RegisterTest(TBSTestCanvasPath);
  RegisterTest(TBSTestCanvasPathArc);
  RegisterTest(TBSTestCanvasPathMultiColored);
  RegisterTest(TBSTestRectangle);
  RegisterTest(TBSTestCanvasRoundRect);
  RegisterTest(TBSTestCanvasRoundRectTextured);
  RegisterTest(TBSTestCanvasTexuredCircle);
  RegisterTest(TBSTestCanvasArrow);
  RegisterTest(TBSTestArc);
  RegisterTest(TBSTestArcPos);
  RegisterTest(TBSTestBezier);
  RegisterTest(TBSTestRectTextured);
  RegisterTest(TBSTestPicture);
  RegisterTest(TBSTestTrapeze);
  RegisterTest(TBSTestTrapezeRound);
  RegisterTest(TBSTestText);
  RegisterTest(TBSTestTextScalable);
  RegisterTest(TBSTestLayout);
  RegisterTest(TBSTestFreeShape);
  RegisterTest(TBSTestFreeShape2);

end.


