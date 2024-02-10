unit bs.test.canvas.map;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , bs.basetypes
  , bs.scene
  , bs.renderer
  , bs.test
  , bs.canvas
  , bs.canvas.map
  , bs.font
  , bs.animation
  , bs.collections
  , bs.gui.buttons
  , bs.thread
  ;

type

  TBSTestCanvasMap = class(TBSTest)
  private

    const
    COUNT_CHARS = 1000;
  private
    Canvas: TBCanvas;
    Canvas2: TBCanvas;
    CharsMap: TCanvasMapChars;
    AniLaw: IBAnimationLinearFloat;
    AniLawObsr: IBAnimationLinearFloatObsrv;
    Directions: TListVec<TVec2f>;
    Velosity: TListVec<BSFloat>;
    LastTime: TTimeCounter;
    procedure OnUpdateValue(const Value: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestStringMap = class(TBSTest)
  private
    FCanvas: TBCanvas;
    FMap: TCanvasTextMap;
    FBackground: TPicture;
    FModels: TStringList;
    AniLaw: IBAnimationLinearFloat;
    AniLawObsr: IBAnimationLinearFloatObsrv;
    procedure LoadBackground;
    procedure LoadBook;
    procedure LoadModels;
    procedure OnUpdateValue(const Value: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    SysUtils
  , bs.config
  , bs.align
  , bs.utils
  ;

{ TBSTestCanvasMap }

constructor TBSTestCanvasMap.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  TBTimer.UpdateTimer(LastTime);
  Directions := TListVec<TVec2f>.Create;
  Velosity := TListVec<BSFloat>.Create;
  Canvas := TBCanvas.Create(ARenderer, Self);
  // Canvas.CreateEmptyCanvasObject;
  // Canvas.Position2d := vec2(0.0, 0.0);
  CharsMap := TCanvasMapChars.Create(Canvas, nil);
  AniLaw := CreateAniFloatLinear(NextExecutor);
  AniLawObsr := AniLaw.CreateObserver(GUIThread, OnUpdateValue);
  AniLaw.Loop := true;
  AniLaw.Duration := 10000;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 1.0;
  Canvas2 := TBCanvas.Create(ARenderer, Self);
end;

destructor TBSTestCanvasMap.Destroy;
begin
  if AniLaw.IsRun then
    AniLaw.Stop;
  AniLawObsr := nil;
  AniLaw := nil;
  Velosity.Free;
  Directions.Free;
  Canvas.Free;
  Canvas2.Free;
  inherited;
end;

procedure TBSTestCanvasMap.OnUpdateValue(const Value: BSFloat);
var
  i: int32;
  pos: TVec3f;
  vel: BSFloat;
  dir: TVec2f;
  size_screen_half: TVec2f;
  // sf: BSFloat;
begin
  // exit;
  if LastTime.Counter - TBTimer.CurrentTime.Counter < 16 then
    exit;
  size_screen_half := vec2(Renderer.WindowWidth*0.5, Renderer.WindowHeight*0.5);
  LastTime := TBTimer.CurrentTime;
  for i := 0 to CharsMap.Particles.CountParticle - 1 do
  begin
    pos := CharsMap.Particles.Position[i];
    vel := Velosity.Items[i];
    dir := Directions.Items[i];
    pos := vec3(pos.x + (vel * dir.x), pos.y + (vel * dir.y), 0.0);
    // CharsMap.Particles.Position[i] := pos;
    // pos_abs := CharsMap.Data.AbsolutePosition;
    if (abs(pos.x - size_screen_half.x) > size_screen_half.x) or (abs(pos.y + size_screen_half.y) > size_screen_half.y) then
    begin
      if (abs(pos.x - size_screen_half.x) > size_screen_half.x) then
      begin
        dir.x := -dir.x;
        if pos.x < 0 then
          pos.x := 0.0
        else
          pos.x := Renderer.WindowWidth;
      end else
      begin
        dir.y := -dir.y;
        if pos.y < 0 then
          pos.y := -Renderer.WindowHeight
        else
          pos.y := 0.0;
      end;
      Directions.Items[i] := dir; // vec2(-dir.x, -dir.y);
      // while (abs(pos.x - size_screen_half.x) >= size_screen_half.x) or (abs(pos.y + size_screen_half.y) >= size_screen_half.y) do
      // pos := vec3(pos.x + BSConfig.VoxelSize*(vel * dir.x), pos.y + BSConfig.VoxelSize*(vel * dir.y), 0.0);
    end;
    CharsMap.Particles.Position[i] := pos;
  end;
end;

function TBSTestCanvasMap.Run: boolean;
var
  i: int32;
  ck: int32;
  ki: int32;
  key: PKeyInfo;
  count: int32;
  vec: TVec2f;
  pos: TVec2i;
  vel: BSFloat;
  // s: TString;
begin
  { with TTriangle.Create(Canvas2, nil) do begin
    A := vec2(234, 145);
    B := vec2(455, 243);
    C := vec2(134, 300);
    Color := BS_CL_BLUE;
    Fill := true;
    Build;
    Data.Opacity := 0.3;
    end; }
  CharsMap.Clear;
  Randomize;
  count := 0;
  Canvas.Font.BeginSelectChars;
  try
    ck := Canvas.Font.CountKeys;
    for i := 0 to COUNT_CHARS - 1 do
    begin
      key := nil;
      while key = nil do
      begin
        ki := Random(ck);
        key := Canvas.Font.Key[ki];
        // key := Canvas.Font.KeyByWideChar['d'];
      end;
      vec := VecNormalize(vec2((Random(1000)/1000 - 0.5)/0.5, (Random(1000)/1000 - 0.5)/0.5));
      pos := vec2(Random(Renderer.WindowWidth), Random(Renderer.WindowHeight));
      CharsMap.AddChar(pos.x, pos.y, widechar(key.Code));
      Directions.Add(vec);

      vel := 0;
      while vel = 0 do
        vel := Random(6);

      // vel := vel/100;

      Velosity.Add(vel);
      inc(count);

      // break;
    end;
    { ki := 0;
      for i := 0 to 10 do
      begin
      s := IntToStr(i);
      for ck := 1 to s.Len do
      begin
      key := CharsMap.AddChar(ki, 20, s.CharsUnsafeW(ck));
      inc(ki, round(key.Rect.Width));
      end;
      inc(ki, 5);
      end; }
  finally
    Canvas.Font.EndSelectChars;
  end;
  { Result := CharsMap.AddChar(100, 200, 'A') <> nil;
    CharsMap.AddChar(100, 100, 'b');
    CharsMap.AddChar(50, 50, 'c'); }
  // CharsMap.Build;
  if not AniLaw.IsRun then
    AniLaw.Run;
  Result := Count > 0;
  // CharsMap.Position2d :=  vec2(-CharsMap.Width * 0.5, -CharsMap.Height * 0.5); //vec2(0.0, 0.0);// Canvas.Position2d +
end;

class function TBSTestCanvasMap.TestName: string;
begin
  Result := 'The test Map Chars';
end;

{ TBSTestStringMap }

constructor TBSTestStringMap.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  FCanvas := TBCanvas.Create(ARenderer, nil);
  FMap := TCanvasTextMap.Create(FCanvas, nil);
  FModels := TStringList.Create;
  AniLaw := CreateAniFloatLinear(NextExecutor);
  AniLawObsr := AniLaw.CreateObserver(OnUpdateValue);
  AniLaw.Loop := true;
  AniLaw.Duration := 10000;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 1.0;
  ARenderer.Frustum.OrthogonalProjection := true;
end;

destructor TBSTestStringMap.Destroy;
begin
  AniLaw := nil;
  AniLawObsr := nil;
  FMap.Free;
  FBackground.Free;
  FCanvas.Free;
  FModels.Free;
  inherited;
end;

procedure TBSTestStringMap.LoadBackground;
var
  monteCristo: TPicture;
  caption: TCanvasText;
  author: TCanvasText;
begin
  FBackground := TPicture.Create(FCanvas, nil);
  FBackground.AutoFit := false;
  FBackground.Size := vec2(Renderer.WindowWidth, Renderer.WindowHeight*0.9);
  FBackground.LoadFromFile('/TestData/StringsMap/background.png');
  FBackground.Position2d := vec2(0.0, Renderer.WindowHeight*0.05);
  //FBackground.Data.AsStencil := true;

  FMap.Parent := FBackground;
  //FMap.ViewPortPosition := vec2(FBackground.Size.x*0.5, FBackground.Size.y*0.05);
  FMap.ViewPortSize := vec2(FBackground.Size.x*0.45, FBackground.Size.y*0.9);
  FMap.ViewPort.Position2d := vec2(FBackground.Size.x*0.5, FBackground.Size.y*0.05);
  FMap.TextStyle.Wrap := true;
  FMap.TextStyle.Bold := true;
  FMap.TextStyle.BoldWeightX := 0.1;

  monteCristo := TPicture.Create(FCanvas, FBackground);
  monteCristo.AutoFit := false;
  monteCristo.LoadFromFile('/TestData/StringsMap/MONTE-CRISTO.png');
  monteCristo.Size := vec2(monteCristo.Image.Width * 0.6, monteCristo.Image.Height*0.6);
  monteCristo.Position2d := FBackground.Size*0.25 - monteCristo.Size*0.5;
  monteCristo.Data.Opacity := 0.8;
  monteCristo.Build;

  caption := TCanvasText.Create(FCanvas, FBackground);
  caption.CreateCustomFont;
  //caption.SceneTextData.TxtProcessor.ViewportSize := vec2(monteCristo.Width, 0);
  caption.TextAlign := TTextAlign.taCenter;
  caption.Italic := true;
  caption.Bold := true;
  caption.Font.Size := 14;
  caption.TextAlign := TTextAlign.taCenter;
  caption.Text := 'LE COMTE' + sLineBreak + 'DE MONTE-CRISTO';
  caption.Color := ColorDec(BS_CL_GRAY, 0.25);

  caption.Position2d := monteCristo.Position2d + vec2((monteCristo.Width - caption.Width) *0.5, monteCristo.Height + 20.0) ;

  author := TCanvasText.Create(FCanvas, FBackground);
  author.CreateCustomFont;
  author.Font.Size := 14;
  //author.Bold := true;
  author.Text := 'Alexandre Dumas';
  author.Color :=  ColorDec(BS_CL_GRAY, 0.25);

  author.Position2d := monteCristo.Position2d + vec2((monteCristo.Width - author.Width) *0.5, caption.Position2d.y + caption.Height  + 30.0) ;
end;

procedure TBSTestStringMap.LoadBook;
var
  i: int32;
  pos: TVec2d;
  inlineData: PInlineStyle;
begin
  FModels.LoadFromFile(GetFilePath('/TestData/StringsMap/LE COMTE DE MONTE-CRISTO.md')); // test.txt surrogate2.txt
  FMap.ApplyStyle(FMap.TextStyle, FMap.Prototype);
  pos := FMap.ViewPortPosition;
  for i := 0 to FModels.Count - 1 do
  begin
    if FModels.Strings[i] <> '' then
    begin
      inlineData := FMap.DrawText(FModels.Strings[i], RectBSd(pos, vec2d(FMap.ViewPortSize.Width, 0)), TTextAlign.taClient);
      pos.y := pos.y + inlineData.Rect.Height + 2;
    end else
      pos.y := pos.y + FMap.Prototype.Font.SizeInPixels + FMap.Prototype.SceneTextData.TxtProcessor.Interligne;
  end;
end;

procedure TBSTestStringMap.LoadModels;
begin
  LoadBackground;
  LoadBook;
end;

procedure TBSTestStringMap.OnUpdateValue(const Value: BSFloat);
begin

end;

function TBSTestStringMap.Run: boolean;
begin
  LoadModels;
  Result := true;
  FMap.TextStyle.BeginUpdate;
  FMap.TextStyle.Size := 10;
  FMap.TextStyle.Color := ColorDec(BS_CL_GRAY, 0.3);
  FMap.TextStyle.EndUpdate;
  //FMap.DrawText('ABCDEF', vec2(100.0, 200.0));

//  FMap.TextStyle.BeginUpdate;
//  FMap.TextStyle.Name := 'NotoSerif-Regular';
//  FMap.TextStyle.EndUpdate;
//  FMap.DrawText('ABCDF', vec2(100.0, 220.0));
end;

class function TBSTestStringMap.TestName: string;
begin
  Result := 'Strings Map';
end;

end.
