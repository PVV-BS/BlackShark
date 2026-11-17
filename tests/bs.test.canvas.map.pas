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
    Velocity: TListVec<BSFloat>;
    LastTime: TTimeCounter;
    procedure OnUpdateValue(const Value: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTest2dMap = class(TBSTest)
  private
    FMap: TCanvasObjectsMap;
    FModels: TStringList;
    AniLaw: IBAnimationLinearFloat;
    AniLawObsr: IBAnimationLinearFloatObsrv;
    LastHolder: PModelHolder;
    procedure LoadBackground;
    procedure LoadBook;
    procedure LoadModels;
    procedure OnUpdateValue(const Value: BSFloat);
  protected
    procedure OnMouseWeel(const AData: BMouseData); override;
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
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
  Velocity := TListVec<BSFloat>.Create;
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
  Velocity.Free;
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
    vel := Velocity.Items[i];
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

      Velocity.Add(vel);
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

{ TBSTest2dMap }

constructor TBSTest2dMap.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  ARenderer.Frustum.OrthogonalProjection := true;
  FMap := TCanvasObjectsMap.Create(Renderer);
  FModels := TStringList.Create;
  AniLaw := CreateAniFloatLinear(NextExecutor);
  AniLawObsr := AniLaw.CreateObserver(OnUpdateValue);
  AniLaw.Loop := true;
  AniLaw.Duration := 10000;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 1.0;
end;

destructor TBSTest2dMap.Destroy;
begin
  AniLaw := nil;
  AniLawObsr := nil;
  FMap.Free;
  FModels.Free;
  inherited;
end;

procedure TBSTest2dMap.LoadBackground;
const
  SCALE_MC_PIC = 0.6;
  SCALE_SHIP_PIC = 0.5;
  SCALE_ORNAMENT_PIC = 0.25;
begin
  FMap.DrawPicture('./TestData/StringsMap/background2.png', vec2(0.0, 0.0), FMap.ViewPortSize, 1.0);
  LastHolder := FMap.DrawPicture('./TestData/StringsMap/face.png', vec2(0.0, 0.0), FMap.ViewPortSize, 0.8, 1);
  FMap.TextMapper.TextStyle.Wrap := true;
  FMap.TextMapper.TextStyle.Bold := true;
  FMap.TextMapper.TextStyle.Italic := false;
  FMap.TextMapper.TextStyle.Size := 14;
  FMap.TextMapper.TextStyle.BoldWeightX := 0.2;
  FMap.TextMapper.TextStyle.Color := BS_CL_GREEN;
  LastHolder := FMap.DrawText('Alexandre Dumas', RectBS(0, 100.0, FMap.ViewPortSize.x, 0.0), TTextAlign.taCenter, 1);

  LastHolder := FMap.DrawPicture('./TestData/StringsMap/ornament4.png', vec2((FMap.ViewPortSize.x - 1161*SCALE_ORNAMENT_PIC)*0.5, LastHolder.Rect.Y + LastHolder.Rect.Height + 15),
    vec2(1161, 186)*SCALE_ORNAMENT_PIC, 1.0, 1);

  FMap.TextMapper.TextStyle.Italic := true;
  FMap.TextMapper.TextStyle.Size := 12;
  FMap.TextMapper.TextStyle.BoldWeightX := 0.1;
  LastHolder := FMap.DrawText('LE COMTE' + sLineBreak + 'DE MONTE-CRISTO', RectBS(0, (LastHolder.Rect.Y + LastHolder.Rect.Height + 20.0), FMap.ViewPortSize.x, 0.0), TTextAlign.taCenter, 1);

  LastHolder := FMap.DrawPicture('./TestData/StringsMap/MONTE-CRISTO5.png', vec2((FMap.ViewPortSize.x - 140*SCALE_MC_PIC)*0.5, LastHolder.Rect.Y + LastHolder.Rect.Height + 20), vec2(140.0, 156.0)*SCALE_MC_PIC, 0.7, 5);
  LastHolder := FMap.DrawPicture('./TestData/StringsMap/ship2.png', vec2((FMap.ViewPortSize.x - 365*SCALE_SHIP_PIC)*0.5, LastHolder.Rect.Y + LastHolder.Rect.Height + 15), vec2(365.0, 250.0)*SCALE_SHIP_PIC, 0.7, 5);
end;

procedure TBSTest2dMap.LoadBook;
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
  h: BSFloat;
  mdTag: TMdTags;
  str, remainder: string;
  pageCount: int32;
  pageEndPos: BSFloat;
  padding: BSFloat;

  procedure AddPage;
  var
    cornerSize: TVec2f;
  begin
    LastHolder := FMap.DrawPicture('./TestData/StringsMap/background2.png', vec2(0.0, pageEndPos + 10), FMap.ViewPortSize, 1.0);
    cornerSize := vec2(350, 362)*0.28;
    FMap.DrawPicture('./TestData/StringsMap/CornerRight.png', vec2(FMap.ViewPortSize.x - cornerSize.x - 2, pageEndPos + 12), cornerSize, 1.0, 1);
    FMap.DrawPicture('./TestData/StringsMap/CornerLeft.png', vec2(2, pageEndPos + 10 + FMap.ViewPortSize.y - cornerSize.y - 2), cornerSize, 1.0, 1);
    FMap.DrawPicture('./TestData/StringsMap/CornerRight.png', vec2(2, pageEndPos + 12), cornerSize, vec3(0.0, 180, 0.0), 1.0, 1);
    FMap.DrawPicture('./TestData/StringsMap/CornerLeft.png', vec2(FMap.ViewPortSize.x - cornerSize.x - 2, pageEndPos + 10 + FMap.ViewPortSize.y - cornerSize.y - 2), cornerSize, vec3(0.0, 180, 0.0), 1.0, 1);
    pageEndPos := LastHolder.Rect.Y + FMap.ViewPortSize.Height;
    pos := vec2(padding, LastHolder.Rect.Y + padding);
    inc(pageCount);
  end;

begin
  FModels.LoadFromFile(GetFilePath(BOOK_PATH + 'LE COMTE DE MONTE-CRISTO.md')); //LE COMTE DE MONTE-CRISTO.md  surrogate2.txt
  FMap.TextMapper.Trim := false;
  FMap.TextMapper.TextStyle.Italic := false;
  FMap.TextMapper.TextStyle.Size := 12;
  FMap.TextMapper.ApplyTextStyle(FMap.TextMapper.TextStyle, FMap.TextMapper.Prototype);
  padding := FMap.ViewPortSize.Width*0.08;
  pageEndPos := FMap.ViewPortSize.Height;
  pageCount := 0;
  AddPage;
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
          remainder := '';
          while str <> '' do
          begin
            LastHolder := FMap.DrawText(str, RectBSd(pos, vec2d(FMap.ViewPortSize.Width - padding*2, 0.0)), TTextAlign.taClient, 1);
            if pos.y + LastHolder.Rect.Height > pageEndPos - padding then
            begin
              h := LastHolder.Rect.Height;
              while (pos.y + h > pageEndPos - padding) and (FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines > 1) do
              begin
                FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines := FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines - 1;
                remainder := FMap.TextMapper.Prototype.SceneTextData.TextLine[FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines] + remainder;
                FMap.TextMapper.Prototype.Build;
                h := FMap.TextMapper.Prototype.Height;
              end;


              if (pos.y + h > pageEndPos - padding) then
              begin
                FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines := 0;
                FMap.Delete(LastHolder);
                AddPage;
                continue;
              end;

              str := FMap.TextMapper.Prototype.SceneTextData.GetTextLines(0, FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines - 1);
              FMap.TextMapper.Prototype.SceneTextData.TxtProcessor.AllowedLines := 0;
              FMap.Delete(LastHolder);
              LastHolder := FMap.DrawText(str, RectBSd(pos, vec2d(FMap.ViewPortSize.Width - padding*2, 0.0)), TTextAlign.taClient, 1);
              str := remainder;
              AddPage;
            end else
              break;
          end;
          pos.y := pos.y + LastHolder.Rect.Height + 2;
        end;
        Header0,
        Header1,
        Header2,
        Header3: begin
          FMap.TextMapper.TextStyle.Bold := true;
          FMap.TextMapper.TextStyle.Size := HEADER_SIZE[int32(mdTag)];
          LastHolder := FMap.DrawText(trim(text), RectBSd(pos, vec2d(FMap.ViewPortSize.Width - padding*2, 0.0)), TTextAlign.taCenter, 1); //FMap.ViewPortSize.Height - (pos.y - pageStartPos.y)
          pos.y := pos.y + LastHolder.Rect.Height + 2;
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

    if pos.y >= pageEndPos - padding then
    begin
      AddPage;
    end;

    inc(i);
  end;
end;

procedure TBSTest2dMap.LoadModels;
begin
  LoadBackground;
  LoadBook;
end;

procedure TBSTest2dMap.OnMouseWeel(const AData: BMouseData);
begin
  FMap.ViewPortPosition := vec2(FMap.ViewPortPosition.x, FMap.ViewPortPosition.y - AData.DeltaWeel div 2);
  Renderer.Render; // it not need do for apps with max fps
end;

procedure TBSTest2dMap.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  //FMap.ViewPortPosition := FMap.ViewPortPosition (Renderer.ScreenSize - FMap.ViewPortSize) * 0.5;
end;

procedure TBSTest2dMap.OnUpdateValue(const Value: BSFloat);
begin

end;

function TBSTest2dMap.Run: boolean;
//var
//  pos: TVec2f;
begin
  //EventResizeRequest.Send(Self, 540, 700, 0.0, 0.0);
  FMap.ViewPortSize := vec2d(480, 580);
  LoadModels;
  //pos := (Renderer.ScreenSize - vec2d(380, 480)) * 0.5;
  //FMap.ViewPortPosition := pos;
  //FMap.UpdateViewCameraPosition;
  Result := true;
end;

class function TBSTest2dMap.TestName: string;
begin
  Result := 'Strings Map';
end;

end.
