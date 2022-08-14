unit bs.test.instancing;

{$I BlackSharkCfg.inc}

interface

uses

    bs.basetypes
  , bs.test
  , bs.events
  , bs.renderer
  , bs.scene
  , bs.instancing
  , bs.scene.objects
  , bs.animation
  , bs.canvas
  , bs.collections
  ;

type

  TBSTestInstancing = class(TBSTest)
  private
    Proto: TColoredVertexes;
    Instansing: TBlackSharkInstancing;
    //Animation: TAnimation;
    //AniLaw: TAniValueLawsFloat;
    //procedure OnUpdateValue(Data: PEventBaseRec);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;


  TBSTestInstancing2d = class(TBSTest)
  private
    const
      COUNT_INSTANCES = 1000;
  private
    Instancing: TBlackSharkInstancing2d;
    Canvas: TBCanvas;
    TimeOut: TCanvasText;
    Proto: TArc;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestParticles = class(TBSTest)
  private
    { canvas-wrapper arround Instances (TBlackSharkParticles) }
    //CanvasObjectMap: TCanvasObject;
    Canvas: TBCanvas;
    Particles: TParticlesSingleUV;
    Task: IBEmptyTask;
    TaskTrapResult: IBEmptyTaskObserver;
    Deep: BSFloat;
    //BB: TBox3f;
    procedure OnUpdateValue(const Value: byte);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestFog }

  TBSTestFog = class(TBSTest)
  private
    Canvas: TBCanvas;
    Fog: TFog;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    SysUtils
  , bs.shader
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.config
  , bs.mesh.primitives
  , bs.math
  , bs.thread
  , bs.texture
  , bs.frustum
  ;

{ TBSTestInstancing }

constructor TBSTestInstancing.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  //Renderer.Frustum.Angle := vec3(0.0, 0.0, 0.0);
  Proto := TColoredVertexes.Create(Self, nil, Renderer.Scene);
  Proto.Color := BS_CL_ORANGE;
  Proto.DragResolve := true;
  TBlackSharkFactoryShapesP.GenerateCylinder(Proto.Mesh, 0.04, 20, 0.08);
  Proto.ChangedMesh;
  Instansing := TBlackSharkInstancing.Create(ARenderer, Proto);
end;

destructor TBSTestInstancing.Destroy;
begin
  Proto.Destroy;
  Instansing.Free;
  inherited;
end;

function TBSTestInstancing.Run: boolean;
var
  i: int32;
begin
  Allow3dManipulationByMouse := true;
  AllowMoveCameraByKeyboard := true;
  //Proto.Position := vec3(0.0, 0.0, -3.0);
  Instansing.CountInstance := 5000;
  Instansing.BeginUpdate;
  Instansing.Position[0] := vec3(0.0, 0.0, -3.0);
  for i := 1 to Instansing.CountInstance - 1 do
  begin
    Instansing.Position[i] := vec3(Random(2000)/1000-1.0, Random(2000)/1000-1.0, -Random(round(Renderer.Frustum.DistanceFarPlane)-1)); //
    Instansing.Angle[i] := vec3(Random(360)/1.0, Random(360)/1.0, Random(360)/1.0);
    Instansing.Opacity[i] := Random(1000)/1000;
  end;
  Instansing.EndUpdate;
  Result := true;
end;

class function TBSTestInstancing.TestName: string;
begin
  Result := 'Test Instansing';
end;

{ TBSTestParticles }

constructor TBSTestParticles.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Randomize;
  Canvas := TBCanvas.Create(ARenderer, Self);
  Particles := TParticlesSingleUV.Create(ARenderer, nil);
  Particles.Texture := BSTextureManager.LoadTexture('Pictures\snowflake.png');
  Particles.ParticleBox.Angle := vec3(0.0, 0.0, 0.0);
  Deep := ARenderer.Frustum.DistanceFarPlane - ARenderer.Frustum.DistanceNearPlane;
  ARenderer.Frustum.Angle := vec3(0.0, 0.0, 0.0);
  Task := CreateEmptyTask(GUIThread);
  TaskTrapResult := Task.CreateObserver(GUIThread, OnUpdateValue);
end;

destructor TBSTestParticles.Destroy;
begin
  Task := nil;
  TaskTrapResult := nil;
  { cut from canvas, otherwise happen exception }
  //CanvasObjectMap.Data := nil;
  Particles.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestParticles.OnUpdateValue(const Value: byte);
var
  i: int32;
  pos: TVec3f;
  r: int32;
begin
  for i := 0 to Particles.CountParticle - 1 do
  begin
    pos := Particles.Position[i];
    r := Random(100000);
    if r < 50000 then
    begin
      pos.x := pos.x + Random(3)/10000;
      //pos.z := pos.z - Random(5)/1000;
    end else
    begin
      pos.x := pos.x - Random(3)/10000;
      //pos.z := pos.z + Random(5)/1000;
    end;

    pos.y := pos.y - Random(3)/5000;

    if Renderer.Frustum.PointInFrustum(pos) or (pos.y > 0.0) or Renderer.Frustum.PointInFrustum(
      vec3(pos.x, pos.y + Particles.Texture.Rect.Height*BSConfig.VoxelSize, pos.z)) then
    begin
      {op := Particles.Opacity[i];
      if op < 0.8 then
        begin
        op := op + 0.001;
        Particles.Opacity[i] := op;
        end; }
    end else
    begin     // Inv *
      pos := vec3(
         Random(high(int32))/high(int32) * Renderer.Frustum.NearPlaneWidth - Renderer.Frustum.NearPlaneWidth*0.5,
         Renderer.Frustum.NearPlaneHeight + (Particles.Texture.Rect.Height)*BSConfig.VoxelSize,
        -Random(high(int32))/high(int32) * Deep);
      if pos.x < 0 then
        pos.x := pos.x - (Renderer.Frustum.FarPlaneWidth * abs(pos.z)/Deep)
      else
        pos.x := pos.x + (Renderer.Frustum.FarPlaneWidth * abs(pos.z)/Deep);
      pos.y := pos.y + (Renderer.Frustum.FarPlaneHeight * abs(pos.z)/Deep);
    end;
    Particles.Position[i] := pos;
  end;
  Particles.Sort;
end;

function TBSTestParticles.Run: boolean;
var
  i: int32;
  pos: TVec3f;
begin
  Particles.CountParticle := 1000;
  for i := 0 to Particles.CountParticle - 1 do
  begin
    pos := vec3(
      Random(high(int32))/high(int32) * Renderer.Frustum.NearPlaneWidth - Renderer.Frustum.NearPlaneWidth*0.5,
      Random(high(int32))/high(int32) * Renderer.Frustum.NearPlaneHeight - Renderer.Frustum.NearPlaneHeight*0.5,
      -Random(high(int32))/high(int32) * Deep);  //
    if pos.x < 0 then
      pos.x := pos.x - (Renderer.Frustum.FarPlaneWidth * abs(pos.z)/Deep)
    else
      pos.x := pos.x + (Renderer.Frustum.FarPlaneWidth * abs(pos.z)/Deep);
    if pos.y < 0 then
      pos.y := pos.y - (Renderer.Frustum.FarPlaneHeight * abs(pos.z)/Deep)
    else
      pos.y := pos.y + (Renderer.Frustum.FarPlaneHeight * abs(pos.z)/Deep);
    Particles.Position[i] := pos;
    //Particles.Color[i] := vec3(random(1000)/1000, random(1000)/1000, random(1000)/1000);
  end;
  Particles.Sort;
  Result := true;
  Task.Run;
end;

class function TBSTestParticles.TestName: string;
begin
  Result := 'Test Particle System';
end;

{ TBSTestFog }

constructor TBSTestFog.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(ARenderer, nil);
  GUIThread.PeriodUpdate := 0;
  Fog := TFog.Create(Canvas, nil);
  Fog.Fill := true;
  Fog.Size := Renderer.ScreenSize;
  Fog.Build;
  //Fog.Data.Position := vec3(0.0, 0.0, -5.0);
  //Fog.Data.AngleY := 20;
end;

destructor TBSTestFog.Destroy;
begin
  Canvas.Free;
  inherited;
end;

function TBSTestFog.Run: boolean;
begin
  Result := true;
end;

class function TBSTestFog.TestName: string;
begin
  Result := 'Test of a fog';
end;

{ TBSTestInstancing2d }

constructor TBSTestInstancing2d.Create(ARenderer: TBlackSharkRenderer);
var
  i: int32;
  start: Cardinal;
  colorEnumerator: TColorEnumerator;
begin
  inherited;
  colorEnumerator := TColorEnumerator.Create([]);
  Canvas := TBCanvas.Create(ARenderer, nil);
  TimeOut := TCanvasText.Create(Canvas, nil);
  Proto := TArc.Create(Canvas, nil);
  Proto.Color := BS_CL_ORANGE;
  Proto.Radius := 20;
  Proto.Fill := false;
  Proto.Build;
  Instancing := TBlackSharkInstancing2d.Create(ARenderer, Proto);
  start := TBTimer.CurrentTime.Low;
  Instancing.CountInstance := COUNT_INSTANCES;
  Instancing.BeginUpdate;
  for i := 0 to COUNT_INSTANCES - 1 do
  begin
    Instancing.Position2d[i] := TVec2f(vec2(int32(random(Renderer.WindowWidth)), int32(random(Renderer.WindowHeight - 50))));
    Instancing.Angle[i] := vec3(0.0, 0.0, random(360));
    Instancing.Color[i] := colorEnumerator.GetNextColor;
  end;
  Instancing.EndUpdate;
  TimeOut.Text := 'Building of ' + IntToStr(COUNT_INSTANCES) + ' instances took ' + IntToStr(TBTimer.CurrentTime.Low - start) + ' ms..';
  TimeOut.Color := BS_CL_GREEN;
  TimeOut.Position2d := TVec2f(vec2(50.0, Renderer.WindowHeight - 20.0));
  colorEnumerator.Free;
end;

destructor TBSTestInstancing2d.Destroy;
begin
  Instancing.Free;
  TimeOut.Free;
  Canvas.Free;
  inherited;
end;

function TBSTestInstancing2d.Run: boolean;
begin
  Result := true;
end;

class function TBSTestInstancing2d.TestName: string;
begin
  Result := 'Test of 2d instansing';
end;

end.
