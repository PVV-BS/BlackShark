unit bs.test.font;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.collections
  , bs.obj
  , bs.events
  , bs.scene
  , bs.test
  , bs.tesselator
  , bs.font
  , bs.canvas
  , bs.gui.buttons
  , bs.thread
  , bs.renderer
  ;

type

  { TBSTestTrueTypeFont }

  TBSTestTrueTypeFont = class(TBSTest)
  private
    const
      TEST_SYMBOLS: array[0..0] of uint16 = (115);//($33b, $57, $AB, $4f, $BC, $2047, $19f, $3a, $40e, $2039, $23A);//
  private
    FFont: IBlackSharkFont;
    FGlyph: PGlyph;
    FKI: PKeyInfo;

    ObsrBtnClick: IBMouseUpEventObserver;
    MEnterGroup: BObserversGroup<BMouseData>;
    MDownGroup: BObserversGroup<BMouseData>;

    Button: TBButton;
    ButtonPause: TBButton;

    CurrentGlyphIndex: int32;
    Canvas: TBCanvas;
    Counter: TCanvasText;
    TextCanvas: TBCanvas;
    Indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
    //CountTessGlyphs: int32;
    TotalTime: int32;
    Timer: TTimeCounter;
    //PauseOn: boolean;

    Point1: TCanvasText;
    Point2: TCanvasText;
    Point3: TCanvasText;
    P1: TRectangle;
    P2: TRectangle;
    P3: TRectangle;

    Triangle: TTriangle;
    kx, ky: BSFloat;
    xMin, yMax, xMax, yMin: BSFloat;
    ErrorEdges: TListVec<bs.tesselator.TBlackSharkTesselator.TEdge>;
    Billboard: TBCanvas;
    Running: boolean;

    procedure FreePoints;
    procedure SetFont(AValue: IBlackSharkFont);
    procedure SetGlyph(AValue: PGlyph);
    procedure OnMouseEnter({%H-}const Data: BMouseData);
    procedure OnMouseDownTri({%H-}const Data: BMouseData);
    function TestSymbol(Code: uint16): boolean;
    procedure OnMouseUpBtn({%H-}const Data: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    property Font: IBlackSharkFont read FFont write SetFont;
    property Glyph: PGlyph read FGlyph write SetGlyph;
  end;

  TBSTestTrueTypeSmiles = class(TBSTest)
  private
    Canvas: TBCanvas;
    Rect: TRectangle;
    Rect2: TRectangle;
    Grid: TGrid;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;




implementation

uses
    Classes
  , SysUtils
  {$ifdef FMX}
  // TODO: clipboard
  //, FMX.Platform
  //, FMX.Clipboard
  {$else}
    {$ifndef FPC}
      {$ifdef MSWINDOWS}
      , Clipbrd
      {$endif}
    {$endif}
  {$endif}
  , bs.scene.objects
  , bs.align
  ;

{ TBSTestTrueTypeFont }

procedure TBSTestTrueTypeFont.SetFont(AValue: IBlackSharkFont);
begin
  if FFont = AValue then
    exit;
  FFont := AValue;
  Canvas.Font := AValue;
end;

procedure TBSTestTrueTypeFont.SetGlyph(AValue: PGlyph);
begin
  if FGlyph = AValue then Exit;
  FGlyph := AValue;
  Run;
end;

procedure TBSTestTrueTypeFont.OnMouseDownTri(const Data: BMouseData);
{$ifndef FMX}
  {$ifndef FPC}
    {$ifdef MSWINDOWS}
var
  t: string;
    {$endif}
  {$endif}
{$endif}
begin
  if Point1 = nil then
    exit;

  {$ifndef FMX}
    {$ifndef FPC}
      {$ifdef MSWINDOWS}
  t := Point1.Text + #$0d + #$0a +
    Point2.Text + #$0d + #$0a +
    Point3.Text + #$0d + #$0a;

      Clipboard.Clear;
      Clipboard.SetTextBuf(@t[1]);
      {$endif}
    {$endif}
  {$endif}
end;

procedure TBSTestTrueTypeFont.OnMouseEnter(const Data: BMouseData);
var
  tri: TTriangle;
begin
  if Running then
    exit;
  tri := TTriangle(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.TagPtr);
  if Point1 <> nil then
    FreePoints;

  Point1 := TCanvasText.Create(Canvas, nil);
  Point1.Layer2d := 3;                // (v0.x - Tesselator.xMin)*kx
  Point1.Text := IntToStr(Indexes.Items[tri.Data.TagInt*3]) + ': ' + IntToStr(round((tri.A.x/kx + xMin))) + #9 + IntToStr(round((yMax - tri.A.y/ky)));
  Point1.Position2d := vec2(500, 20);
  Point1.Color := BS_CL_RED;

  Point2 := TCanvasText.Create(Canvas, nil);
  Point2.Layer2d := 3;                // (v0.x - Tesselator.xMin)*kx
  Point2.Text := IntToStr(Indexes.Items[tri.Data.TagInt*3 + 1]) + ': ' + IntToStr(round((tri.B.x/kx + xMin))) + #9 + IntToStr(round((yMax - tri.B.y/ky)));
  Point2.Position2d := vec2(500, 40);
  Point2.Color := BS_CL_GREEN;

  Point3 := TCanvasText.Create(Canvas, nil);
  Point3.Layer2d := 3;                // (v0.x - Tesselator.xMin)*kx
  Point3.Text := IntToStr(Indexes.Items[tri.Data.TagInt*3 + 2]) + ': ' + IntToStr(round((tri.C.x/kx + xMin))) + #9 + IntToStr(round((yMax - tri.C.y/ky)));
  Point3.Position2d := vec2(500, 60);
  Point3.Color := BS_CL_BLUE;

  Triangle := TTriangle.Create(Canvas, nil);
  Triangle.Data.Interactive := false;
  Triangle.A := tri.A;
  Triangle.B := tri.B;
  Triangle.C := tri.C;
  Triangle.Fill := false;
  Triangle.Color := BS_CL_GREEN;
  Triangle.Position2d := tri.Position2d;
  Triangle.Layer2d := 3;
  Triangle.Build;

  P1 := TRectangle.Create(Canvas, nil);
  P1.Size := vec2(4, 4);
  P1.Fill := true;
  P1.Build;
  P1.Color := Point1.Color;
  P1.Position2d := tri.A - 1;
  P1.Layer2d := 4;
  P1.Data.Interactive := false;

  P2 := TRectangle.Create(Canvas, nil);
  P2.Size := vec2(4, 4);
  P2.Fill := true;
  P2.Build;
  P2.Color := Point2.Color;
  P2.Position2d := tri.B - 1;
  P2.Layer2d := 4;
  P2.Data.Interactive := false;

  P3 := TRectangle.Create(Canvas, nil);
  P3.Size := vec2(4, 4);
  P3.Fill := true;
  P3.Build;
  P3.Color := Point3.Color;
  P3.Position2d := tri.C - 1;
  P3.Layer2d := 4;
  P3.Data.Interactive := false;

  Counter.Text := IntToStr(tri.Data.TagInt);
end;

procedure TBSTestTrueTypeFont.OnMouseUpBtn(const Data: BMouseData);
begin
  FGlyph := nil;
  {repeat
  FKI := FFont.RawData.Key[CurrentGlyphIndex];
  //FGlyph := FFont.Glyph[CurrentGlyphIndex];
  inc(CurrentGlyphIndex);
  CurrentGlyphIndex := CurrentGlyphIndex mod 65536;
  //CurrentGlyphIndex := CurrentGlyphIndex mod Scene.FontManager.DefaultFont.CountGlyphs;
  if (FKI <> nil) and (FKI^.Glyph.Points.Count > 0) and (FKI^.Glyph.Contours.Count > 0) then
    FGlyph := FKI^.Glyph;
  until FGlyph <> nil; }
  Run;
end;

{procedure TBSTestTrueTypeFont.OnMouseUpPause(Data: PEventBaseRec);
begin
  PauseOn := not PauseOn;
end; }

constructor TBSTestTrueTypeFont.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  MEnterGroup := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseEnter);
  MDownGroup := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseDownTri);
  ErrorEdges := TListVec<bs.tesselator.TBlackSharkTesselator.TEdge>.Create;
  TBlackSharkTesselator.TListIndexes.Create(Indexes);

  TextCanvas := TBCanvas.Create(Renderer, Self);


  Canvas := TBCanvas.Create(Renderer, Self);
 { with TRectangle.Create(Canvas, nil) do
  begin
    Fill := true;
    Size := vec2(30, 30);
    Build;
    Position2d := vec2(300, 300);
    Color := BS_CL_RED;
  end;}

  Counter := TCanvasText.Create(TextCanvas, nil);
  Counter.Position2d := vec2(10, 40);
  Counter.Color := BS_CL_WHITE;
  Counter.Text := '0';

  FFont := BSFontManager.GetFont('NotoSerif-Regular.ttf', TTrueTypeFont); //.ttf DejaVuSans   cour
  //FFont.Load(GetFilePath('DejaVuSans.ttf', 'Fonts'));
  //FFont.CodePage := cpUnicode;


  {ButtonPause := TBButton.Create(AScene, 70, 30, false);
  ButtonPause.Caption := 'Pause';
  ButtonPause.Position2d := vec2(10, 10.0);
  ButtonPause.Root.Data.EventMouseUp.Subscribe(OnMouseUpPause, TextCanvas);
  //Button.Font := FFont;
  //Button.Text.Size := 35;      }

  Button := TBButton.Create(ARenderer);
  Button.Caption := 'Run test';
  Button.Position2d := vec2(90.0, 10.0);
  ObsrBtnClick := Button.OnClickEvent.CreateObserver(GUIThread, OnMouseUpBtn);

  //CurrentGlyphIndex := 1000;
  //CurrentGlyphIndex := 64830;
  //CurrentGlyphIndex := 1567;
  //CurrentGlyphIndex := 33;
  //CurrentGlyphIndex := $2021;
  //CurrentGlyphIndex := $410;

  CurrentGlyphIndex := $19f;//AB  57 33b 4f BC 3a; 2047 40e  2039  ord('¨')

  Billboard := TBCanvas.Create(Renderer, Self);
  with TRectangle.Create(Billboard, nil) do
  begin
    Fill := true;
    Size := vec2(340, 200);
    Data.Opacity := 0.3;
    Color := BS_CL_SKY;
    Build;
    Position2d := vec2(int32(Renderer.WindowWidth - 303), int32(Renderer.WindowHeight - 300));
  end;
  {TextCanvas.Pen.Color1 := BS_CL_BLACK;
  Text := TFactoryCanvasObjects.CreateText(TextCanvas, 110, 40, 'Current Glyph Code: ');
  TextTime := TFactoryCanvasObjects.CreateText(TextCanvas, 110, 60, 'Time tesselation, ms: 0');
  TextTimeAverage := TFactoryCanvasObjects.CreateText(TextCanvas, 110, 80, 'Time tesselation average, ms: 0'); }

end;

destructor TBSTestTrueTypeFont.Destroy;
begin
  MEnterGroup.Free;
  MDownGroup.Free;
  TBlackSharkTesselator.TListIndexes.Free(Indexes);
  ErrorEdges.Free;
  Billboard.Free;
  Canvas.Free;
  FFont := nil;
  Button.Free;
  ButtonPause.Free;
  TextCanvas.Free;
  inherited Destroy;
end;

procedure TBSTestTrueTypeFont.FreePoints;
begin
  if Point1 <> nil then
    begin
    FreeAndNil(Point1);
    FreeAndNil(Point2);
    FreeAndNil(Point3);
    FreeAndNil(Triangle);
    FreeAndNil(P1);
    FreeAndNil(P2);
    FreeAndNil(P3);
    end;
end;

function TBSTestTrueTypeFont.Run: boolean;
const
  STEP = 20;
var
  i, j: int32;
  txt: TCanvasText;
  top: int32;
  edg: TBlackSharkTesselator.TEdge;
begin
  //exit;
  Running := true;

  try
    TotalTime := 0;
    FreePoints;
    Billboard.Clear();

    top := 10;

    txt := TCanvasText.Create(Billboard, nil);
    txt.Position2d := vec2(5, top);
    txt.Text := 'Run test...';
    inc(top, STEP);

    for i := 0 to length(TEST_SYMBOLS) - 1 do
      if not TestSymbol(TEST_SYMBOLS[i]) then
        begin
        if (FGlyph <> nil) then
          begin
          txt := TCanvasText.Create(Billboard, nil);
          txt.Position2d := vec2(5, top);
          txt.Text := 'The error of triangulation a symbol $' + IntToHex(TEST_SYMBOLS[i], 4) + ', bad edges: ';
          inc(top, STEP);
          for j := 0 to ErrorEdges.Count - 1 do
            begin
            edg := ErrorEdges.Items[j];
            txt := TCanvasText.Create(Billboard, nil);
            txt.Data.Interactive := false;
            txt.Position2d := vec2(5, top);
            txt.Text := 'Indexes: ' + IntToStr(edg.index0) + ' (' + IntToStr(round(FGlyph.Points.Items[edg.index0].x))
               + ', ' + IntToStr(round(FGlyph.Points.Items[edg.index0].y)) + '), ' +
            IntToStr(edg.index1) + ' (' + IntToStr(round(FGlyph.Points.Items[edg.index1].x))
               + ', ' + IntToStr(round(FGlyph.Points.Items[edg.index1].y)) + ')';
            inc(top, STEP);
            end;
          exit(false);
          end else
          begin
          txt := TCanvasText.Create(Billboard, nil);
          txt.Position2d := vec2(5, top);
          txt.Text := 'A symbol $' + IntToHex(TEST_SYMBOLS[i], 4) + ' do not found...';
          inc(top, STEP);
          end;
        end;

    txt := TCanvasText.Create(Billboard, nil);
    txt.Position2d := vec2(5, top);
    txt.Text := 'Success, the total time: ' + IntToStr(TotalTime) + ' ms';
  finally
    Running := false;
  end;
  Result := true;
end;

class function TBSTestTrueTypeFont.TestName: string;
begin
  Result := 'Test True Type Font';
end;

function TBSTestTrueTypeFont.TestSymbol(Code: uint16): boolean;
var
  i: int32;
  v0, v1, v2: TVec3f;
  t_time: uint32;
  tri: TTriangle;
  //g_raw: PGlyph;
begin
  FKI := FFont.GetRawKey(Code);
  FGlyph := nil;
  if (FKI = nil) or (FKI.Glyph = nil) then
    exit(false);
  FGlyph := FKI.Glyph;
  ErrorEdges.Count := 0;
  TBTimer.UpdateTimer(Timer);
  t_time := Timer.Low;
  i := Tesselator.Triangulate(FGlyph.Points, FGlyph.Contours, Indexes, nil, nil, ErrorEdges); // @g_raw.Points, @g_raw.Contours
  Result := i = 0;
  xMin := Tesselator.xMin;
  yMax := Tesselator.yMax;
  yMin := Tesselator.yMin;
  xMax := Tesselator.xMax;
  TBTimer.UpdateTimer(Timer);
  t_time := Timer.Low - t_time;
  inc(TotalTime, t_time);
  if ((yMax - yMin) = 0) or ((xMax - xMin) = 0) or (Indexes.Count < 3) then
      exit(false);

  // scale to screen
  ky := Renderer.WindowHeight / (yMax - yMin);
  kx := Renderer.WindowWidth / (xMax - xMin);
  if ky > kx then
    ky := kx
  else
    kx := ky;
  Canvas.Clear;
  Canvas.CreateEmptyCanvasObject;
  MEnterGroup.Clear;
  MDownGroup.Clear;
  for i := 0 to Indexes.Count div 3 - 1 do
  begin
    Counter.Text := IntToStr(i);
    v0 := FGlyph.Points.items[Indexes.items[i*3  ]];
    v1 := FGlyph.Points.items[Indexes.items[i*3+1]];
    v2 := FGlyph.Points.items[Indexes.items[i*3+2]];
    tri := TTriangle.Create(Canvas, nil);
    tri.A := vec2((v0.x - xMin)*kx, ky*(yMax - v0.y));
    tri.B := vec2((v1.x - xMin)*kx, ky*(yMax - v1.y));
    tri.C := vec2((v2.x - xMin)*kx, ky*(yMax - v2.y));
    tri.Fill := true;
    tri.Build;
    tri.Data.TagPtr := tri;
    tri.Data.TagInt := i;
    MEnterGroup.CreateObserver(tri.Data.EventMouseEnter);
    MDownGroup.CreateObserver(tri.Data.EventMouseDown);
  end;
  Sleep(100);
  EventRepaintRequest.Send(Self);
  {$ifndef FMX}
  //Application.ProcessMessages;
  {$endif}
end;

{ TBSTestTrueTypeSmiles }

constructor TBSTestTrueTypeSmiles.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(Renderer, Self);
  Canvas.Font := BSFontManager.GetFont('NotoEmoji-Regular.ttf', TTrueTypeRasterFont); //NotoSerif-Regular .ttf WineDate-Regular.ttf Woodcutter Selfportraits.ttf
  Canvas.Font.SizeInPixels := 32;
  //TTrueTypeRasterFont(Canvas.Font).Quality := 0.4;

  Rect2 := TRectangle.Create(Canvas, nil);
  Rect2.Size := Renderer.ScreenSize;
  Rect2.Fill := true;
  Rect2.Data.Opacity := 0.0;
  Rect2.Position2d := vec2(0.0, 0.0);
  Rect := TRectangle.Create(Canvas, Rect2);
  Rect.Size := Renderer.ScreenSize;
  Rect.Fill := false;
  Rect.Color := BS_CL_SKY;
  Rect.Position2d := vec2(0.0, 0.0);
  Grid := TGrid.Create(Canvas, Rect);
  Grid.Color := BS_CL_SKY_BLUE;
end;

destructor TBSTestTrueTypeSmiles.Destroy;
begin
  Canvas.Free;
  inherited;
end;

function TBSTestTrueTypeSmiles.Run: boolean;
var
  i: int32;
  k: PKeyInfo;
  pos: TVec2f;
  txt: TCanvasText;
begin
  Result := true;
  if Canvas.Font.AverageWidth > Canvas.Font.AverageHeight then
    Grid.StepX := Canvas.Font.AverageWidth*1.2
  else
    Grid.StepX := Canvas.Font.AverageHeight*1.2;

  Grid.StepY := Grid.StepX;

  Grid.Size := Rect.Size;
  Grid.Build;
  Rect2.Size := vec2(Grid.Width, Grid.Height);
  Rect2.Build;
  Rect.Size := Rect2.Size;
  Rect.Build;
  Rect.Position2d := vec2(0.0, 0.0);
  Grid.Position2d := vec2(0.0, 0.0);

  // triangulation and rasterisation everyone
  Canvas.Font.BeginSelectChars;
  for i := 32 to Canvas.Font.CountKeys - 1 do
    Canvas.Font.Key[i];
  Canvas.Font.EndSelectChars;

  pos := vec2(0.0, 0.0);
  for i := 32 to Canvas.Font.CountKeys - 1 do
  begin
    //if i = $231A {clock} then //$231B{sand clock}
    //begin
    //  k := k;
    //end;
    k := Canvas.Font.Key[i];
    if (k = nil) or (k.Indexes.Count = 0) then
      continue;
    txt := TCanvasText.Create(Canvas, Rect2);
    txt.Text := char(i);
    txt.Position2d := pos + vec2(Grid.StepX - txt.Width, Grid.StepY - txt.Height)*0.5;
    pos.x := pos.x + Grid.StepX;
    if pos.x > Rect.Size.Width then
    begin
      pos := vec2(0.0, pos.y + Grid.StepY);
      if pos.y > Rect.Size.Height then
        break;
    end;
  end;
end;

class function TBSTestTrueTypeSmiles.TestName: string;
begin
  Result := 'Test True Type Smiles';
end;

end.

