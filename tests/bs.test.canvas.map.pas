unit bs.test.canvas.map;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , bs.basetypes
  , bs.scene
  , bs.renderer
  , bs.test
  , bs.events
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
    FMap: TCanvasObjectsMap;
    //FStencilBackground: TRectangle;
    FBackground: TPicture;
    FModels: TStringList;
    AniLaw: IBAnimationLinearFloat;
    AniLawObsr: IBAnimationLinearFloatObsrv;
    FMethodStencilDraw: TDrawInstanceMethod;
    procedure DrawStancilBack(Instance: PRendererGraphicInstance);
    procedure LoadBackground;
    procedure LoadBook;
    procedure LoadModels;
    procedure OnUpdateValue(const Value: BSFloat);
  protected
    procedure OnMouseWeel(const AData: BMouseData); override;
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
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
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
  Renderer.Frustum.OrthogonalProjection := true;
  FCanvas := TBCanvas.Create(Renderer, nil);
  FMap := TCanvasObjectsMap.Create(FCanvas, nil);
  FModels := TStringList.Create;
  AniLaw := CreateAniFloatLinear(NextExecutor);
  AniLawObsr := AniLaw.CreateObserver(OnUpdateValue);
  AniLaw.Loop := true;
  AniLaw.Duration := 10000;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 1.0;
  LoadModels;
end;

destructor TBSTestStringMap.Destroy;
begin
  AniLaw := nil;
  AniLawObsr := nil;
  FMap.Free;
  FBackground.Free;
  //FStencilBackground.Free;
  FCanvas.Free;
  FModels.Free;
  inherited;
end;

procedure TBSTestStringMap.DrawStancilBack(Instance: PRendererGraphicInstance);
begin
  { fill the shape Back as the stencil for ban draw outside him }
  glClearStencil(0);
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  FMethodStencilDraw(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
  FMethodStencilDraw(Instance);
end;

procedure TBSTestStringMap.LoadBackground;
//var
//  monteCristo: TPicture;
//  caption: TCanvasText;
//  author: TCanvasText;
begin
  // for not full screen application need stencil
//  FStencilBackground := TRectangle.Create(FCanvas, nil);
//  FStencilBackground.Size := vec2(492, 605);
//  FStencilBackground.Fill := true;
//  FStencilBackground.Data.AsStencil := true;
//  FStencilBackground.Data.Opacity := 0.5;
//  FMethodStencilDraw := FStencilBackground.Data.DrawInstance;
//  FStencilBackground.Data.DrawInstance := DrawStancilBack;
//  FStencilBackground.Build;
//  FStencilBackground.Position2d := vec2((Renderer.WindowWidth - FStencilBackground.Size.x)*0.5, Renderer.WindowHeight*0.05);

  FBackground := TPicture.Create(FCanvas, nil);//FStencilBackground
  FBackground.AutoFit := false;
  FBackground.Data.Interactive := false;
  FBackground.Data.Opacity := 0.1;
  //FBackground.Size := vec2(Renderer.WindowWidth, Renderer.WindowHeight*0.9);
  FBackground.Size := vec2(492, 605);//FStencilBackground.Size*1.1;
  FBackground.LoadFromFile('/TestData/StringsMap/background.png');
  FBackground.Position2d := vec2(0.0, 0.0);//-FStencilBackground.Size*0.05;

  FMap.Parent := FBackground;
  //FMap.ViewPortPosition := vec2(FBackground.Size.x*0.5, FBackground.Size.y*0.05);
  FMap.ViewPortSize := FBackground.Size*0.95; //vec2(FBackground.Width*0.925, FBackground.Height*0.925);
  FMap.ViewPortPosition := vec2(FBackground.Width*0.025, FBackground.Height*0.025);
  FMap.TextMapper.TextStyle.Wrap := true;
  FMap.TextMapper.TextStyle.Bold := true;
  FMap.TextMapper.TextStyle.BoldWeightX := 0.1;

//  monteCristo := TPicture.Create(FCanvas, FBackground);
//  monteCristo.AutoFit := false;
//  monteCristo.LoadFromFile('/TestData/StringsMap/MONTE-CRISTO.png');
//  monteCristo.Size := vec2(monteCristo.Image.Width * 0.6, monteCristo.Image.Height*0.6);
//  monteCristo.Position2d := FBackground.Size*0.25 - monteCristo.Size*0.5;
//  monteCristo.Data.Opacity := 0.8;
//  monteCristo.Build;
//
//  caption := TCanvasText.Create(FCanvas, FBackground);
//  caption.CreateCustomFont;
//  //caption.SceneTextData.TxtProcessor.ViewportSize := vec2(monteCristo.Width, 0);
//  caption.TextAlign := TTextAlign.taCenter;
//  caption.Italic := true;
//  caption.Bold := true;
//  caption.Font.Size := 14;
//  caption.TextAlign := TTextAlign.taCenter;
//  caption.Text := 'LE COMTE' + sLineBreak + 'DE MONTE-CRISTO';
//  caption.Color := ColorDec(BS_CL_GRAY, 0.25);
//
//  caption.Position2d := monteCristo.Position2d + vec2((monteCristo.Width - caption.Width) *0.5, monteCristo.Height + 20.0) ;
//
//  author := TCanvasText.Create(FCanvas, FBackground);
//  author.CreateCustomFont;
//  author.Font.Size := 14;
//  //author.Bold := true;
//  author.Text := 'Alexandre Dumas';
//  author.Color :=  ColorDec(BS_CL_GRAY, 0.25);
//
//  author.Position2d := monteCristo.Position2d + vec2((monteCristo.Width - author.Width) *0.5, caption.Position2d.y + caption.Height  + 30.0) ;
end;

procedure TBSTestStringMap.LoadBook;
type
  TMdTags = (None, Header0, Header1, Header2, Header3, Link, Picture);

var
  pathPicture: string;
  text: string;

  function GetMdTag(const AText: string): TMdTags;
  var
    i: int32;
    c: Char;
    pos0, pos1: int32;
  begin
    Result := None;
    for i := 1 to length(AText) do
    begin
      c := AText[i];
      if c = '#' then
      begin
        text := Copy(AText, 1, i-1);
        Result := Header0;
        if (i + 1 <= length(AText)) and (AText[i+1] = '#') then
        begin
          Result := Header1;
          if (i + 2 <= length(AText)) and (AText[i+2] = '#') then
          begin
            Result := Header2;
            if (i + 3 <= length(AText)) and (AText[i+3] = '#') then
            begin
              Result := Header3;
              text := text + Copy(AText, i + 4, length(AText) - i - 3);
            end else
              text := text + Copy(AText, i + 3, length(AText) - i - 2);
          end else
            text := text + Copy(AText, i + 2, length(AText) - i - 1);

        end else
          text := text + Copy(AText, i + 1, length(AText) - i);

        break;
      end else
      if c = '!' then
      begin
        if (i + 1 <= length(AText)) and (AText[i + 1] = '[') then
        begin
          pos0 := pos('](', AText, i + 1);
          if (pos0 > 0) then
          begin
            pos1 := pos(')', AText, pos0 + 2);
            if pos1 > 0 then
            begin
              pathPicture := Copy(AText, pos0 + 2, pos1 - pos0 - 2);
              exit(Picture);
            end;
          end;
        end;
      end else
      if c = '[' then
      begin // todo: link

      end;
    end;
  end;

const
  HEADER_SIZE: array[0..4] of int32 = (10, 18, 16, 14, 12);
  BOOK_PATH = 'TestData/StringsMap/';

var
  i: int32;
  pos: TVec2d;
  size: TVec2f;
  mdTag: TMdTags;
  str: string;
  //pageOrd: int8;
  pageCount: int32;
  pageStartPos: TVec2d;
  padding: BSFloat;
  model: PModelHolder;
begin
  FModels.LoadFromFile(GetFilePath(BOOK_PATH + 'test.txt')); //LE COMTE DE MONTE-CRISTO.md  surrogate2.txt
  FMap.TextMapper.Trim := false;
  FMap.TextMapper.ApplyTextStyle(FMap.TextMapper.TextStyle, FMap.TextMapper.Prototype);
  padding := FMap.ViewPortSize.Width*0.025;
  pos := vec2(padding, FMap.ViewPortSize.Height * 0.5);
  pageStartPos := pos;
  //pageOrd := 0;
  pageCount := 0;
  i := 0;
  while i < FModels.Count do
  begin
    str := trim(FModels.Strings[i]);
    if str <> '' then
    begin
      mdTag := GetMdTag(str);

      case mdTag of
        None: begin
          FMap.TextMapper.TextStyle.Bold := false;
          FMap.TextMapper.TextStyle.Size := HEADER_SIZE[0];
          FMap.DrawText(FModels.Strings[i], RectBSd(pos, vec2d(FMap.ViewPortSize.Width - padding, 0.0)), TTextAlign.taClient); //FMap.ViewPortSize.Height - (pos.y - pageStartPos.y)
          pos.y := pos.y + FMap.TextMapper.Prototype.Height + 2;
//          if FMap.TextMapper.Prototype.IndexLastStringInViewport < FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.Lines.Count - 1 then
//          begin
//
//          end;
        end;
        Header0,
        Header1,
        Header2,
        Header3: begin
          FMap.TextMapper.TextStyle.Bold := true;
          FMap.TextMapper.TextStyle.Size := HEADER_SIZE[int32(mdTag)];
          FMap.DrawText(trim(text), RectBSd(pos, vec2d(FMap.ViewPortSize.Width - padding, 0.0)), TTextAlign.taCenter); //FMap.ViewPortSize.Height - (pos.y - pageStartPos.y)
          pos.y := pos.y + FMap.TextMapper.Prototype.Height + 2;
          //break;
        end;
        Link: ;
        Picture: begin
//          size := vec2(listWidthClient, FBackground.Height*0.5);
//          model := FMap.DrawPicture(GetFilePath(BOOK_PATH + pathPicture), vec2(pos.x, pos.y), size, 0.8);
//          size := PPictureModel(model.Model).Size;
//          FMap.Update(vec2((FBackground.Width - size.Width)*0.5, pos.y), size, model);
//          pos.y := pos.y + size.y;
        end;
      end;

    end else
      pos.y := pos.y + FMap.TextMapper.Prototype.Font.SizeInPixels + FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.Interligne;

    if round(pos.y) >= round((pageCount+ 1)*FMap.ViewPortSize.Height) then
    begin
      inc(pageCount);
//      if pageCount mod 2 > 0 then
//      begin
//        pos.x := listWidth + padding;
//        pos.y := pageStartPos.y;
//      end else
      begin
        pos := vec2(padding, pageCount*FMap.ViewPortSize.Height);
        pageStartPos := pos;
      end;
    end;

    inc(i);
  end;
end;

procedure TBSTestStringMap.LoadModels;
begin
  LoadBackground;
  LoadBook;
end;

procedure TBSTestStringMap.OnMouseWeel(const AData: BMouseData);
begin
  FMap.ViewPortPosition := vec2(FMap.ViewPortPosition.x, FMap.ViewPortPosition.y + AData.DeltaWeel);
end;

procedure TBSTestStringMap.OnUpdateValue(const Value: BSFloat);
begin

end;

function TBSTestStringMap.Run: boolean;
begin
  EventResizeRequest.Send(Self, 540, 700, 0.0, 0.0);

  Result := true;
//  FMap.TextMapper.TextStyle.BeginUpdate;
//  FMap.TextMapper.TextStyle.Size := 10;
//  FMap.TextMapper.Prototype.Color := ColorDec(BS_CL_GRAY, 0.3);
//  FMap.TextMapper.TextStyle.EndUpdate;
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
