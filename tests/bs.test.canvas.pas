unit bs.test.canvas;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , bs.basetypes
  , bs.events
  , bs.renderer
  , bs.test
  , bs.canvas
  , bs.font
  , bs.mesh.primitives
  , bs.gui.buttons
  , bs.thread
  , bs.graphics
  ;

type

  { TBSTestSimple }

  TBSTestSimple = class(TBSTest)
  private
    Canvas: TBCanvas;
    Triangle: TTriangle;
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestCanvas }

  TBSTestCanvas = class(TBSTest)
  private
    Canvas: TBCanvas;
    CanvasVectorial: TBCanvas;
    OnClickObsrvIn: IBMouseUpEventObserver;
    OnClickObsrvOut: IBMouseUpEventObserver;
    ButtonScaleIn: TBButton;
    ButtonScaleOut: TBButton;
    VecText: TCanvasText;
    VecText2: TCanvasText;
    VecText3: TCanvasText;
    VecText4: TCanvasText;
    RastText: TCanvasText;
    procedure OnMouseUpScaleIn({%H-}const Data: BMouseData);
    procedure OnMouseUpScaleOut({%H-}const Data: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestCanvasPrimitives = class(TBSTest)
  private
    Canvas: TBCanvas;
    Line: TLine;
    Arc: TArc;
    Path: TPath;
    Trapeze: TTrapeze;
    RoundTrapeze: TRoundTrapeze;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    //class function TestClass: TBSTestClass; override;
  end;

  TBSTestCanvasImages = class(TBSTest)
  private
    Canvas: TBCanvas;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    //class function TestClass: TBSTestClass; override;
  end;

  TBSTestCanvasAlign = class(TBSTest)
  private
    Canvas: TBCanvas;
    Root: TRectangle;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestCanvasFonts = class(TBSTest)
  private
    Canvas: TBCanvas;
    Canvas2: TBCanvas;
    RastText: TCanvasText;
    RastText2: TCanvasText;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    //class function TestClass: TBSTestClass; override;
  end;

  { TBSTestCanvasScalableMode }

  TBSTestCanvasScalableMode = class(TBSTest)
  private
    const
      START_WIDTH = 700;
      START_HEIGHT = 600;
      COLOR_MAIN_OBJECT: TGuiColor = $FF007FFF;
      COLOR_CHILD_OBJECT: TGuiColor = $FF0000FF;
  private
    Canvas: TBCanvas;
    Rectangle: TRectangle;
    RectSmall: TRectangle;
    Image: TBlackSharkBitMap;
    procedure PrepareData(const AMinParent, AMaxParent, AMinChild, AMaxChild: TVec2f);
    function CheckMetrics(const AMinParent, AMaxParent, AMinChild, AMaxChild: TVec2i): boolean;
    function CheckColor(const APostoin: TVec2i; AMust: TGuiColor): boolean;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    SysUtils
  , bs.scene.objects
  , bs.strings
  , bs.texture
  , bs.align
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  ;

{ TBSTestSimple }

constructor TBSTestSimple.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  //Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 90, Renderer.Frustum.Angle.z);
  Canvas := TBCanvas.Create(Renderer, Self);
  //Canvas.Scalable := true;

  //ARenderer.Frustum.Angle := vec3(0.0, -90.0, 0.0);
  //ARenderer.Frustum.Position := vec3(0.0, 0.0, -1.0);

  {with TArc.Create(Canvas, nil) do
  begin
    Radius := 100;
    Angle := 60;
    Fill := true;
    Color := BS_CL_ORANGE;
    Build;
    Position2d := vec2(250, 130);
  end;   }

  //ServiceTxt := TCanvasText.Create(Canvas, nil);
  //ServiceTxt.Position2d := vec2(50.0, 5.0);
    //Anchors[aRight] := true;
  //Canvas.Pen.Width := 5;

  Triangle := TTriangle.Create(Canvas, nil);
  Triangle.C := vec2(0.0, 300.0);
  Triangle.B := vec2(150.0, 0.0);
  Triangle.A := vec2(300.0, 300.0);
  Triangle.Fill := True;
  Triangle.Color := BS_CL_SKY;
  //Triangle.Data.ScaleSimple := 0.5;
  Triangle.Build;
  Triangle.Position2d := vec2(10, 10);
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBSTestSimple.Create');
  {$endif}

    //Data.Position := vec3(Data.Position.x, Data.Position.y, Data.Position.z - 5);
  {
  with TCanvasText.Create(Canvas, nil) do
  begin
    Text := 'Hello, world!';
    Position2d := vec2(10, 10);
  end;
  }
  {Canvas.Font.SizeInPixels := 10;
  with TCanvasText.Create(Canvas, nil) do
  begin
    Text := 'од';
    Position2d := vec2(10, 10);
  end; }
end;

destructor TBSTestSimple.Destroy;
begin
  Canvas.Free;
  inherited;
end;

procedure TBSTestSimple.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  if Canvas.Scalable then
  begin
    {if Assigned(Rectangle) then
    begin
      //Rectangle.Size := vec2(Rectangle.Width, Rectangle.Height);
      //Rectangle.Build;
      if Assigned(ServiceTxt) then
        ServiceTxt.Text := Format('%.3f; %.3f;', [Rectangle.Width, Rectangle.Height]);
    end; }
    //if Assigned(Triangle) then
    //  Triangle.Position2d := vec2(10.0, 10.0);
  end;
end;

function TBSTestSimple.Run: boolean;
begin
  Result := true;
end;

class function TBSTestSimple.TestName: string;
begin
  Result := 'Simple Canvas Test';
end;

{ TBSTestCanvas }

procedure TBSTestCanvas.OnMouseUpScaleIn(const Data: BMouseData);
begin
  if CanvasVectorial <> nil then
    CanvasVectorial.Font.Size := CanvasVectorial.Font.Size + 1;
  if Canvas <> nil then
  begin
    Canvas.Font.Size := Canvas.Font.Size + 1;
    //if Canvas.Font.Texture <> nil then
    //  Canvas.Font.Texture.Texture.Picture.Save('d:\font_texture.bmp');
  end;
end;

procedure TBSTestCanvas.OnMouseUpScaleOut(const Data: BMouseData);
begin
  if CanvasVectorial <> nil then
    CanvasVectorial.Font.Size := CanvasVectorial.Font.Size - 1;

  if Canvas <> nil then
  begin
    Canvas.Font.Size := Canvas.Font.Size - 1;
    //if Canvas.Font.Texture <> nil then
    //  Canvas.Font.Texture.Texture.Picture.Save('d:\font_texture.bmp');
  end;
end;

constructor TBSTestCanvas.Create(ARenderer: TBlackSharkRenderer);
const
  CountPoints = 6;
  Path: array[0..CountPoints-1] of TVec2i = (
    (x:20; y:30), (x: 70; y: 120), (x: 200; y: 378),
    (x:180; y:460), (x: 270; y: 520), (x: 640; y: 230)
  );

var
  r, r2: TRectangle;
  i: int32;

begin
  inherited;

  Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 30, Renderer.Frustum.Angle.z);

  Canvas := TBCanvas.Create(Renderer, Self);
  with TTriangle.Create(Canvas, nil) do
  begin
    A := vec2(0.0, 500.0);
    B := vec2(250.0, 0.0);
    C := vec2(500.0, 500.0);
    WidthLine := 7;
    Fill := false;
    Build;
  end;
  r := TRectangle.Create(Canvas, nil);
  r.Size := vec2(180.0, 180.0);
  r.WidthLine := 10;
  r.Build;
  r.Position2d := vec2(0, 0);
  r2 := TRectangle.Create(Canvas, r);
  r2.Size := vec2(100.0, 100.0);
  r2.Fill := true;
  r2.Build;
  r2.Position2d := vec2(40.0, 40.0);
  { are loading vectoral font and convert to raster by TTrueTypeRasterFont class;
    default size TTrueTypeRasterFont smaler TTrueTypeRasterFont.MAX_RASTER_SIZE_DEFAULT,
    therefor font will automaticaly convert after create and load from vectoral
    to raster; }


  Canvas.Font := BSFontManager.GetFont('NotoSerif-Regular.ttf', TTrueTypeRasterFont);   //DejaVuSans
  // Canvas.Font := ARenderer.Scene.FontManager.AddFont('Base.bsf', TBlackSharkRasterFont);
  // now create raster text
  RastText := TCanvasText.Create(Canvas, nil);
  RastText.Position2d := vec2(Renderer.WindowWidth shr 1, int32(Renderer.WindowHeight shr 1));
  RastText.Text := 'It is an adaptive raster True Type text';
  RastText.Color := BS_CL_WHITE;

  CanvasVectorial := TBCanvas.Create(Renderer, Self);
  CanvasVectorial.Font := BSFontManager.GetFont('NotoSerif-Regular.ttf', TTrueTypeFont);

  with TTriangle.Create(CanvasVectorial, nil) do
  begin
    A := vec2(0.0, 433.0);
    B := vec2(250.0, 0.0);
    C := vec2(500.0, 433.0);
    WidthLine := 10;
    Build;
  end;

  with TLine.Create(CanvasVectorial, nil) do
  begin
    A := vec2(100.0, 100.0);
    B := vec2(300.0, 100.0);
    ShowPoints := true;
    WidthLine := 10;
    Build;
  end;

  with TArrow.Create(CanvasVectorial, nil) do
  begin
    A := vec2(250.0, 0.0);
    B := vec2(500.0, 433.0);
    LineWidth := 10;
    SizeTip := vec2(LineWidth*4, LineWidth*8);
    Build;
  end;


  with TCircle.Create(CanvasVectorial, nil) do
  begin
    Radius := 50.0;
    Fill := true;
    Build;
    Position2d := vec2(100.0, 100.0);
  end;

  with TRectangle.Create(CanvasVectorial, nil) do
  begin
    Size :=  vec2(300.0, 300.0);
    Fill := true;
    Build;
    Position2d := vec2(int32(Renderer.WindowWidth shr 1 - 150), int32(Renderer.WindowHeight shr 1 - 150));
    Data.Opacity := 0.2;
  end;

  with TRectangle.Create(CanvasVectorial, nil) do
  begin
    Size := vec2(200.0, 300.0);
    Fill := true;
    Position2d := vec2(200.0, 300.0);
    Data.Opacity := 0.2;
    Build;
  end;

  with TRoundRect.Create(CanvasVectorial, nil) do
  begin
    Size := vec2(500.0, 300.0);
    Fill := true;
    Position2d := vec2(750.0, 580.0);
    Data.Opacity := 0.3;
    Build;
  end;

  with TBezierLine.Create(CanvasVectorial, nil) do
  begin
    A := vec2(100.0, 600.0);
    B := vec2(600.0, 350.0);
    Data.Opacity := 0.5;
    ShowPoints := true;
    Color := BS_CL_BLUE;
    Build;
  end;

  with TBezierCubic.Create(CanvasVectorial, nil) do
  begin
    A := vec2(100.0, 600.0);
    B := vec2(600.0, 350.0);
    C := vec2(100.0, 100.0);
    D := vec2(350.0, 600.0);
    Color := BS_CL_ORANGE_2;
    Quality := 0.03;
    ShowPoints := true;
    Build;
  end;

  with TBezierQuadratic.Create(CanvasVectorial, nil) do
  begin
    A := vec2(0.0, 500.0);
    B := vec2(250.0, 0.0);
    C := vec2(700.0, 500.0);
    WidthLine := 3.0;
    Color := BS_CL_BLUE;
    Quality := 0.02;
    ShowPoints := true;
    Build;
  end;

  with TPath.Create(CanvasVectorial, nil) do
  begin
    for i := 0 to CountPoints - 1 do
      AddPoint(Path[i]);
    Closed := true;
    WidthLine := 3.0;
    Color := BS_CL_GREEN;
    InterpolateSpline := TInterpolateSpline.isNone;
    Build;
  end;

  with TPath.Create(CanvasVectorial, nil) do
  begin
    AddPoint(vec2(88.0, 188.0));
    AddPoint(vec2(188.0, 188.0));
    AddPoint(vec2(188.0, 288.0));
    AddPoint(vec2(88.0, 288.0));
    Closed := true;
    WidthLine := 3;
    InterpolateSpline := TInterpolateSpline.isNone;
    Build;
  end;

  // create text with position relative (Left, Top)

  VecText := TCanvasText.Create(CanvasVectorial, nil);
  VecText.Text := 'This is a vectorial text';
  //VecText.Text := 'T';
  VecText.Position2d := vec2(400.0, 120.0);
  VecText.Data.Color := BS_CL_RED;
  //VecText.Size := 32;

  VecText2 := TCanvasText.Create(CanvasVectorial, nil);
  VecText2.Text := 'Hello! It''s me ;)';
  VecText2.Position2d := vec2(350.0, 580.0);
  VecText2.Data.Color := BS_CL_GREEN;
  //VecText2.Size := 72;

  VecText3 := TCanvasText.Create(CanvasVectorial, nil);
  VecText3.Text := 'Привет от Чёрной Акулы !!!';
  VecText3.Position2d := vec2(300.0, 200.0);
  //VecText.Transparent := 0.3;
  VecText3.Data.Color := BS_CL_RED;
  //VecText3.Size := 89;
  VecText3.Data.Angle := vec3(0.0, 0.0, 45.0);

  VecText4 := TCanvasText.Create(CanvasVectorial, nil);
  VecText4.Text := 'Hej världen!';
  VecText4.Position2d := vec2(230.0, 180.0);
  //VecText.Transparent := 0.3;
  VecText4.Data.Color := BS_CL_RED;

  VecText4 := TCanvasText.Create(Canvas, nil);
  VecText4.Text := 'Hallo Welt Des schwarzen Hai!';
  VecText4.Position2d := vec2(180.0, 255.0);
  VecText4.Color := BS_CL_AQUA;

  ButtonScaleOut := TBButton.Create(ARenderer);
  ButtonScaleOut.Caption := 'Zoom text out';
  ButtonScaleOut.Size := vec2(ButtonScaleOut.Text.Width + 20*ToHiDpiScale, ButtonScaleOut.Text.Height + 20*ToHiDpiScale);
  OnClickObsrvOut := ButtonScaleOut.OnClickEvent.CreateObserver(GUIThread, OnMouseUpScaleOut);

  ButtonScaleIn := TBButton.Create(ARenderer);
  ButtonScaleIn.Size := ButtonScaleOut.Size;
  ButtonScaleIn.Caption := 'Zoom text in';
  ButtonScaleIn.Position2d := vec2(50.0, 450.0);
  ButtonScaleOut.Position2d := vec2(50.0, ButtonScaleIn.Height + ButtonScaleIn.Position2d.Y + 20*ToHiDpiScale);
  OnClickObsrvIn := ButtonScaleIn.OnClickEvent.CreateObserver(GUIThread, OnMouseUpScaleIn);

end;

destructor TBSTestCanvas.Destroy;
begin
  OnClickObsrvOut := nil;
  OnClickObsrvIn := nil;
  Canvas.Free;
  CanvasVectorial.Free;
  ButtonScaleIn.Free;
  ButtonScaleOut.Free;
  inherited Destroy;
end;

function TBSTestCanvas.Run: boolean;
begin
  Result := true;
end;

class function TBSTestCanvas.TestName: string;
begin
  Result := 'Test Canvas';
end;

{ TBSTestCanvasImages }

constructor TBSTestCanvasImages.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(Renderer, Self);
end;

destructor TBSTestCanvasImages.Destroy;
begin
  Canvas.Free;
  inherited;
end;

function TBSTestCanvasImages.Run: boolean;
var
  pic: TPicture;
begin
  pic := TPicture.Create(Canvas, nil);
  pic.LoadFromFile('Pictures/snowflake.png');
  pic.Wrap := true;
  pic.WrapReapeated := true;
  pic.AutoFit := false;
  pic.Size := vec2(pic.Image.Width * 1.5, pic.Image.Height * 1.5);
  pic.Build;

  {with TCircleTextured.Create(Canvas, nil) do
  begin
    Radius := 100;
    Fill := true;
    Build;
    Position2d := vec2(200, 260);
    TTexturedVertexes(Data).Texture := BSTextureManager.LoadTexture('Pictures/earth/earth.png');
  end; }
  //pic.Data.SubscribeOnEvent(BS_EVENT_MOUSE_ENTER, Canvas.LevelTransformations.PipeEvents, OnMouseUpScaleIn);
  //pic.Data.SubscribeOnEvent(BS_EVENT_MOUSE_LEAVE, Canvas.LevelTransformations.PipeEvents, OnMouseUpScaleOut);
  Result := true;
end;

class function TBSTestCanvasImages.TestName: string;
begin
  Result := 'Draw Images';
end;

{ TBSTestCanvasPrimitives }

constructor TBSTestCanvasPrimitives.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(ARenderer, Self);
  Canvas.CreateEmptyCanvasObject;
  Line := TLine.Create(Canvas, nil);
  Line.A := vec2(120.0, 340.0);
  Line.B := vec2(430.0, 609.0);
  Line.Build;
  Arc := TArc.Create(Canvas, nil);
  Arc.Radius := 150;
  Arc.StartAngle := 45;
  Arc.Angle := 80;
  Arc.Fill := true;
  Arc.Build;
  Arc.Position2d := vec2(460, 200);
  Path := TPath.Create(Canvas, nil);
  Path.ShowPoints := true;
  Path.WidthLine := 3;
  Path.AddPoint(vec2(79.0, 100.0));
  Path.AddPoint(vec2(240.0, 190.0));
  Path.AddPoint(vec2(180.0, 320.0));
  Path.AddPoint(vec2(150.0, 350.0));
  Path.InterpolateSpline := TInterpolateSpline.isNone;
  Path.Closed := true;
  Path.Build;
  Trapeze := TTrapeze.Create(Canvas, nil);
  Trapeze.Fill := true;
  Trapeze.WidthLine := 6;
  Trapeze.Build;
  Trapeze.Position2d := vec2(245, 380);

  RoundTrapeze := TRoundTrapeze.Create(Canvas, nil);
  RoundTrapeze.Fill := false;
  RoundTrapeze.WidthLine := 3;
  RoundTrapeze.Build;
  RoundTrapeze.Position2d := vec2(180.0, 250.0);
end;

destructor TBSTestCanvasPrimitives.Destroy;
begin
  Canvas.Free;
  inherited;
end;

function TBSTestCanvasPrimitives.Run: boolean;
begin
  Result := true;
end;

class function TBSTestCanvasPrimitives.TestName: string;
begin
  Result := 'Test primitives the canvas';
end;

{ TBSTestCanvasAlign }

constructor TBSTestCanvasAlign.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(FRenderer, Self);
  //Canvas.Scalable := true;
end;

destructor TBSTestCanvasAlign.Destroy;
begin
  Canvas.Free;
  inherited;
end;

function TBSTestCanvasAlign.Run: boolean;
var
  obj: TCanvasText;
  rect: TRectangle;
  rect_client: TRectangle;
  arrow: bs.canvas.TArrow;
begin

  Root := TRectangle.Create(Canvas, nil);
  Root.Fill := true;
  Root.Size := vec2(300.0, 200.0);
  Root.Position2d := vec2(250.0, 250.0);
  //Root.Data.Caption := 'Rectangle';
  Root.Build;
  Root.Anchors[aRight] := true;
  Root.Anchors[aBottom] := true;
  Root.PaddingTop := 5;
  Root.PaddingLeft := 10;
  Root.PaddingRight := 10;

  arrow := bs.canvas.TArrow.Create(Canvas, Root);
  arrow.LineWidth := 1.0;

  arrow.A := vec2(-200.0, Root.Size.Height*0.35);
  arrow.B := vec2(0.0, Root.Size.Height*0.35);
  arrow.Build;
  arrow.Position2d := arrow.A;
  obj := TCanvasText.Create(Canvas, arrow);
  obj.Text := 'Orange obj padding';
  obj.Color := BS_CL_WHITE;
  obj.Position2d := vec2(0.0, - obj.Height - 1);

  arrow := bs.canvas.TArrow.Create(Canvas, Root);
  arrow.LineWidth := 1.0;
  arrow.A := vec2(Root.PaddingLeft + 40.0, Root.Size.Height*0.35);
  arrow.B := vec2(Root.PaddingLeft, Root.Size.Height*0.35);
  arrow.Layer2d := 5;
  arrow.Build;
  arrow.Position2d := arrow.B;


  rect := TRectangle.Create(Canvas, Root);
  rect.Fill := true;
  rect.Color := BS_CL_GREEN;
  rect.Size := vec2(10.0, 30.0);
  rect.Build;
  rect.Align := TObjectAlign.oaTop;

  obj := TCanvasText.Create(Canvas, rect);
  obj.Text := 'Top align';
  obj.Align := oaCenter;
  obj.Color := BS_CL_BLACK;

  rect := TRectangle.Create(Canvas, Root);
  rect.Fill := true;
  rect.Color := BS_CL_BLUE;
  rect.Size := vec2(10.0, 10.0);
  rect.MarginBottom := 5;
  rect.Build;
  rect.Align := TObjectAlign.oaTop;

  arrow := bs.canvas.TArrow.Create(Canvas, Root);
  arrow.LineWidth := 1.0;
  arrow.A := vec2(Root.Size.Width*0.25, -250.0);
  arrow.B := vec2(arrow.A.x, Root.PaddingTop + 40);
  arrow.Layer2d := 5;
  arrow.Build;
  arrow.Position2d := arrow.A;
  obj := TCanvasText.Create(Canvas, arrow);
  obj.Text := 'Blue obj bottom marging';
  obj.Color := BS_CL_WHITE;
  obj.Data.AngleZ := -90;
  obj.Position2d := vec2(-obj.Width-1, 5);
  arrow := bs.canvas.TArrow.Create(Canvas, Root);
  arrow.LineWidth := 1.0;
  arrow.A := vec2(Root.Size.Width*0.25, 90);
  arrow.B := vec2(Root.Size.Width*0.25, Root.PaddingTop + 40 + 5);
  arrow.Layer2d := 5;
  arrow.Build;
  arrow.Position2d := arrow.B;

  rect_client := TRectangle.Create(Canvas, Root);
  rect_client.Fill := true;
  rect_client.Align := TObjectAlign.oaClient;
  rect_client.PaddingLeft := 1;
  rect_client.PaddingTop := 1;
  rect_client.PaddingBottom := 1;
  rect_client.Color := BS_CL_OLIVE;
  rect_client.Size := vec2(10.0, 10.0);
  rect_client.Build;

  obj := TCanvasText.Create(Canvas, rect_client);
  obj.Text := 'Client align';
  obj.Align := oaCenter;
  obj.Color := BS_CL_BLACK;

  rect := TRectangle.Create(Canvas, rect_client);
  rect.Fill := true;
  rect.Color := BS_CL_TEAL;
  rect.Size := vec2(30.0, 10.0);
  rect.Build;
  rect.Align := TObjectAlign.oaLeft;

  obj := TCanvasText.Create(Canvas, rect);
  obj.Text := 'Left align';
  obj.Align := oaCenter;
  obj.Color := BS_CL_BLACK;
  obj.Data.AngleZ := -90;

  rect := TRectangle.Create(Canvas, rect_client);
  rect.Fill := true;
  rect.Color := BS_CL_TEAL;
  rect.Size := vec2(30.0, 10.0);
  rect.Build;
  rect.Align := TObjectAlign.oaRight;

  obj := TCanvasText.Create(Canvas, rect);
  obj.Text := 'Right align';
  obj.Align := oaCenter;
  obj.Color := BS_CL_BLACK;
  obj.Data.AngleZ := 90;

  rect := TRectangle.Create(Canvas, rect_client);
  rect.Fill := true;
  rect.Color := BS_CL_SILVER;
  rect.Size := vec2(10.0, 30.0);
  rect.Build;
  rect.Align := TObjectAlign.oaBottom;

  obj := TCanvasText.Create(Canvas, rect);
  obj.Text := 'Bottom align';
  obj.Align := oaCenter;
  obj.Color := BS_CL_BLACK;

  { align on center }
  {with TTriangle.Create(Canvas, Root) do
  begin
    Fill := true;
    // triangle 40x40
    A := vec2(20, 0);
    B := vec2(40, 40);
    C := vec2(0, 40);
    //Position2d := vec2(400 - 40.0, 400 - 40.0);
    Color := BS_CL_RED;
    //Data.Caption := 'Rectangle';
    Build;
    Anchors[aLeft] := false;
    Anchors[aTop] := false;
    ToParentCenter;
  end;

  with TRoundRect.Create(Canvas, Root) do
  begin
    Size := vec2(50, 50);
    Fill := false;
    WidthLine := 3;
    Color := BS_CL_GREEN;
    Build;
    Position2d := vec2(0, 175);
    Anchors[aLeft] := true;
    Anchors[aTop] := true;
  end; }

  Result := true;
end;

class function TBSTestCanvasAlign.TestName: string;
begin
  Result := 'Align canvas objects';
end;

{ TBSTestCanvasFonts }

constructor TBSTestCanvasFonts.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(Renderer, Self);
  Canvas.Font := BSFontManager.GetFont('NotoSerif-Regular.ttf', TTrueTypeRasterFont);   //DejaVuSans   NotoSerif-Regular

  // now create raster text
  RastText := TCanvasText.Create(Canvas, nil);
  RastText.Color := BS_CL_WHITE;
  Canvas.Font.SizeInPixels := 10;
  //RastText.ViewportSize := vec2(250, 0);
  //RastText.TextAlign := TTextAlign.taClient;
  //RastText.Wrap := true;

  RastText.Text := 'It is The Black Shark Graphics Engine''s an Adaptive Raster True Type Text';
  RastText.Position2d := vec2(Renderer.WindowWidth shr 1 - RastText.Width * 0.5, int32(Renderer.WindowHeight shr 1));

  Canvas2 := TBCanvas.Create(Renderer, Self);
  Canvas2.Font := BSFontManager.GetFont('NotoSerif-Regular.ttf', TTrueTypeRasterFont);   // DejaVuSans
  Canvas2.Font.Size := 12;

  RastText2 := TCanvasText.Create(Canvas2, nil);
  RastText2.Position2d := vec2(Renderer.WindowWidth shr 1, int32(Renderer.WindowHeight shr 1) shr 1);
  RastText2.Text := 'Hello, world!!!';
  RastText2.Color := BS_CL_WHITE;
end;

destructor TBSTestCanvasFonts.Destroy;
begin
  Canvas.Free;
  Canvas2.Free;
  inherited;
end;

function TBSTestCanvasFonts.Run: boolean;
begin

  Result := true;
end;

class function TBSTestCanvasFonts.TestName: string;
begin
  Result := 'Test right separate the usage resourses of font';
end;

{ TBSTestCanvasScalableMode }

function TBSTestCanvasScalableMode.CheckColor(const APostoin: TVec2i; AMust: TGuiColor): boolean;
var
  color: TGuiColor;
  col_delta: TVec4i;
begin
  Result := Image.Canvas.GetPixel(APostoin.x, APostoin.y, color);
  if not Result then
    exit;

  col_delta := vec4(TVec4b(color).x - TVec4b(AMust).x, TVec4b(color).y - TVec4b(AMust).y, TVec4b(color).z - TVec4b(AMust).z, $FF);
  Result := (abs(col_delta.r) < 2) and (abs(col_delta.g) < 2) and (abs(col_delta.b) < 2);
end;

function TBSTestCanvasScalableMode.CheckMetrics(const AMinParent, AMaxParent, AMinChild, AMaxChild: TVec2i): boolean;
begin
  Image.SetSize(round(Renderer.WindowWidth), round(Renderer.WindowHeight));
  Renderer.Screenshot(0, 0, round(Renderer.WindowWidth), round(Renderer.WindowHeight), Pointer(Image.Canvas.Raw.Memory));
  Result := CheckColor(vec2(AMinParent.x - 2, AMinParent.y - 2), TGuiColor(Renderer.Color));
  if not Result then
    exit;

  Result := CheckColor(vec2(AMinParent.x + 2, AMinParent.y + 2), COLOR_MAIN_OBJECT);
  if not Result then
    exit;

  Result := CheckColor(vec2(AMaxParent.x + 2, AMinParent.y - 2), TGuiColor(Renderer.Color));
  if not Result then
    exit;

  Result := CheckColor(vec2(AMaxParent.x + 2, AMaxParent.y + 2), TGuiColor(Renderer.Color));
  if not Result then
    exit;

  Result := CheckColor(vec2(AMaxParent.x - 2, AMaxParent.y - 2), COLOR_CHILD_OBJECT);
  if not Result then
    exit;

  Result := CheckColor(vec2((AMaxParent.x + AMinParent.x) div 2 - 2, (AMaxParent.y + AMinParent.y) div 2 - 2), COLOR_MAIN_OBJECT);
  if not Result then
    exit;

  Result := CheckColor(vec2((AMaxParent.x + AMinParent.x) div 2 + 2, (AMaxParent.y + AMinParent.y) div 2 + 2), COLOR_CHILD_OBJECT);
  if not Result then
    exit;

end;

constructor TBSTestCanvasScalableMode.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(Renderer, Self);
  Renderer.Color := vec4(0.0, 0.0, 0.0, 1.0);
  Image := TBlackSharkBitMap.Create;
end;

destructor TBSTestCanvasScalableMode.Destroy;
begin
  Canvas.Free;
  Image.Free;
  inherited;
end;

procedure TBSTestCanvasScalableMode.PrepareData(const AMinParent, AMaxParent, AMinChild, AMaxChild: TVec2f);
begin
  Canvas.Scalable := true;
  Rectangle := TRectangle.Create(Canvas, nil);
  Rectangle.Fill := true;
  Rectangle.Size := AMaxParent - AMinParent;
  Rectangle.Anchors[aLeft] := false;
  Rectangle.Anchors[aTop]  := false;
  Rectangle.Color := TColor4f(COLOR_MAIN_OBJECT);
  //Rectangle.Data.Opacity := 0.2;
  //Rectangle.TakeIntoAccountScaleInPosition2D := true;
  Rectangle.Build;
  //Rectangle.Data.AngleZ := 45;
  //Rectangle.PositionZ := 3;
  Rectangle.Position2d := AMinParent;//vec2(Renderer.WindowWidth shr 1 - 100.0, Renderer.WindowHeight shr 1 - 100.0);

  RectSmall := TRectangle.Create(Canvas, Rectangle);
  RectSmall.Fill := true;
  RectSmall.Size := AMaxChild - AMinChild;
  RectSmall.Anchors[aLeft] := false;
  RectSmall.Anchors[aTop]  := false;
  //Rectangle.Data.Opacity := 0.2;
  RectSmall.Build;
  //RectSmall.ToParentCenter;
  RectSmall.Position2d := AMinChild;
  RectSmall.Color := TColor4f(COLOR_CHILD_OBJECT);

  {$ifdef DEBUG}
  Rectangle.Data.Caption := 'Rectangle';
  //RectSmall.Data.Caption := 'RectSmall';
  {$endif}

  //Canvas.Scalable := false;
  EventRepaintRequest.Send(Self);

end;

function TBSTestCanvasScalableMode.Run: boolean;
var
  min_parent, max_parent: TVec2f;
  min_child, max_child: TVec2f;
begin
  EventResizeRequest.Send(Self, START_WIDTH, START_HEIGHT, 0.0, 0.0);

  min_parent := vec2(100.0, 200.0);
  max_parent := vec2(400.0, 500.0);
  min_child := vec2(150.0, 150.0);
  max_child := vec2(300.0, 300.0);
  PrepareData(min_parent, max_parent, min_child, max_child);
  //Image.SetSize(Viewport.Width, Viewport.Height);
  //Renderer.Screenshot(0, 0, Viewport.Width, Viewport.Height, Image.Canvas.Raw.Memory);
  //Image.Save('d:\out_image.bmp');
  //exit(true);
  //Viewport.TestResize(Viewport.Width + 200, Viewport.Height + 150);
  Result := CheckMetrics(min_parent, max_parent, min_child, max_child);
  if not Result then
    exit;

  EventResizeRequest.Send(Self, START_WIDTH + 250, START_HEIGHT + 100, 0.0, 0.0);
  EventRepaintRequest.Send(Self);

  Result := CheckMetrics(min_parent*Canvas.Scale, max_parent*Canvas.Scale, min_child*Canvas.Scale, max_child*Canvas.Scale);
end;

class function TBSTestCanvasScalableMode.TestName: string;
begin
  Result := 'Test Scalable mode of Canvas';
end;

initialization

  //RegisterTest(TBSTestCanvasScalableMode);

end.

