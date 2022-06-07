unit bs.test.mesh;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.renderer
  , bs.scene
  , bs.scene.objects
  , bs.test
  , bs.mesh
  , bs.mesh.loaders
  , bs.mesh.primitives
  , bs.shader
  , bs.animation
  ;

type

  { TBSTestMesh }

  TBSTestMesh = class(TBSTest)
  private
    AniLaw: IBAnimationLinearFloat;
    ObsrvFloat: IBAnimationLinearFloatObsrv;
    Obj: TTexturedVertexes;
    procedure OnUpdateValueAngle(const Value: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestMeshCylinder }

  TBSTestMeshCylinder = class(TBSTest)
  private
    Obj: TColoredVertexes;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestEarth = class(TBSTest)
  private
    //Canvas: TBlackSharkCanvas;
    AniLaw: IBAnimationLinearFloat;
    AniLawElipse: IBAnimationElipse;
    ObsrvFloat: IBAnimationLinearFloatObsrv;
    ObsrvElipse: IBAnimationElipseObsrv;
    Earth: TTexturedVertexes;
    Clouds: TTexturedVertexes;
    CloudsBack: TTexturedVertexes;
    Moon: TTexturedVertexes;
    Empty: TGraphicObject;
    EmptyMoon: TGraphicObject;
    EmptyMoonAngle: TGraphicObject;
    Sky: TTexturedVertexes;
    //Tmp: TColoredVertexes;
    procedure OnUpdateValueAngle(const Value: BSFloat);
    procedure OnUpdateValueTrackMoon(const Value: TVec2f);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    //class function TestClass: TBSTestClass; override;
  end;

implementation

uses
  {$ifdef ultibo}
    gles20
  {$else}
    bs.gl.es
  {$endif}
  , bs.thread
  , bs.texture
  ;

{ TBSTestMesh }
procedure TBSTestMesh.OnUpdateValueAngle(const Value: BSFloat);
begin
  if not AniLaw.IsRun then
    exit;
  Obj.Angle := vec3(0.0, AniLaw.CurrentValue, 0.0);
end;

constructor TBSTestMesh.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  Obj := TTexturedVertexes.Create(Self, nil , Renderer.Scene);
  MeshLoadObj('Models/Obj/aquafish01.obj', Obj.Mesh, 0.004);
  Obj.Mesh.TypePrimitive := tpTriangles;
  Obj.Texture := BSTextureManager.LoadTexture('Models/Obj/aquafish01.png');
  //Obj.Texture := Scene.TextureManager.UV(BS_CL_BLUE);
  Obj.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  Obj.Position := Vec3(0.0, 0.0, -1.0);
  Obj.DragResolve := true;
  Obj.Interactive := true;
  Obj.DrawSides := TDrawSide.dsFront;
  Obj.ChangedMesh;
  AniLaw := CreateAniFloatLinear(GUIThread);
  ObsrvFloat := AniLaw.CreateObserver(GUIThread, OnUpdateValueAngle);
  AniLaw.Duration := 2000;
  AniLaw.Loop := true;
  //AniLaw.LoopInverse := true;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 360.0;
  //AniLaw.Run;
end;

destructor TBSTestMesh.Destroy;
begin
  if AniLaw.IsRun then
    AniLaw.Stop;
  ObsrvFloat := nil;
  AniLaw := nil;
  Obj.Free;
  inherited Destroy;
end;

function TBSTestMesh.Run: boolean;
begin
  Result := true;
end;

class function TBSTestMesh.TestName: string;
begin
  Result := 'Test a mesh';
end;

{ TBSTestEarth }

procedure TBSTestEarth.OnUpdateValueAngle(const Value: BSFloat);
begin
  if not AniLaw.IsRun then
    exit;
  Earth.Angle := vec3(0.0, Value, 0.0);
  //Clouds.Angle := Clouds.Angle + vec3(0.0, -0.15, 0.0);
  //CloudsBack.Angle := Clouds.Angle + vec3(0.0, -0.15, 0.0);
end;

procedure TBSTestEarth.OnUpdateValueTrackMoon(const Value: TVec2f);
begin
  if not AniLawElipse.IsRun then
    exit;
  EmptyMoonAngle.Position := vec3(Value.x, 0.0, Value.y);
  Moon.Angle := vec3(0.0, AniLawElipse.Angle, 0.0);
end;

constructor TBSTestEarth.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.Angle := vec3(0.0, 0.0, 0.0);
  Sky := TTexturedVertexes.Create(Self, nil, Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(Sky.Mesh, 10, Renderer.Frustum.DistanceFarPlane - Renderer.Frustum.DEFAULT_POSITION.z, true); //
  Sky.Texture := BSTextureManager.LoadTexture('Pictures/earth/sky.png', false, false);
  Sky.Interactive := false;
  Sky.DrawSides := dsBack;
  Sky.Opacity := 0.3;
  Sky.DrawAsTransparent := true;
  Sky.ChangedMesh;
  //Sky.Position := vec3(0.0, 0.0, -4.0);
  Empty := TGraphicObject.Create(Self, nil, Renderer.Scene);
  EmptyMoon := TGraphicObject.Create(Self, Empty, Renderer.Scene);
  EmptyMoonAngle := TGraphicObject.Create(Self, EmptyMoon, Renderer.Scene);
  Earth := TTexturedVertexes.Create(Self, Empty , Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(Earth.Mesh, 10, Renderer.ScreenSizeToScene(500), true);
  Earth.Texture := BSTextureManager.LoadTexture('Pictures/earth/earthmap1k.png');
  Earth.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  //Earth.Position := vec3(0.0, 0.0, -4.0);
  //Obj.Angle := vec3(0.0, 0.0, 0.0);
  Empty.Position := Vec3(0.0, 0.0, -4.0);
  Earth.DragResolve := true;
  Earth.Interactive := true;
  Earth.ChangedMesh;
  Earth.DrawSides := dsFront;
  //Earth.Hide := true;
  Clouds := TTexturedVertexes.Create(Self, Earth, Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(Clouds.Mesh, 10, Renderer.ScreenSizeToScene(525), true);
  Clouds.Texture := BSTextureManager.LoadTexture('Pictures/earth/earthcloudmapcolortrans.png');
  Clouds.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  Clouds.Interactive := false;
  //Clouds.Opacity := 0.6;
  Clouds.Caption := 'C';
  Clouds.ChangedMesh;
  Clouds.DrawSides := dsFront;
  CloudsBack := TTexturedVertexes.Create(Self, Earth , Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(CloudsBack.Mesh, 10, Renderer.ScreenSizeToScene(525), true);
  CloudsBack.Texture := BSTextureManager.LoadTexture('Pictures/earth/earthcloudmapcolortrans.png');
  //CloudsBack.Texture := Clouds.Texture;
  CloudsBack.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  CloudsBack.DrawAsTransparent := true;
  CloudsBack.Interactive := false;
  //CloudsBack.Opacity := 0.6;
  CloudsBack.ChangedMesh;
  CloudsBack.DrawSides := dsBack;
  EmptyMoon.Angle := vec3(0.0, 0.0, 15.0);
  Moon := TTexturedVertexes.Create(Self, EmptyMoonAngle , Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(Moon.Mesh, 10, Renderer.ScreenSizeToScene(150), true);
  Moon.Texture := BSTextureManager.LoadTexture('Pictures/earth/moonmap1k.png');
  Moon.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  //Moon.DragResolve := false;
  //Moon.Interactive := false;
  Moon.DrawSides := dsFront;
  Moon.ChangedMesh;
  //Moon.Hide := true;
  EmptyMoonAngle.Position := vec3(Renderer.ScreenSizeToScene(2000), 0.0, 0.0);

  AniLaw := CreateAniFloatLinear(GUIThread);
  ObsrvFloat := AniLaw.CreateObserver(GUIThread, OnUpdateValueAngle);
  AniLaw.Duration := 20000;
  AniLaw.Loop := true;
  //AniLaw.LoopInverse := true;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 360.0;
  AniLawElipse := CreateAniElipse(GUIThread);
  ObsrvElipse := AniLawElipse.CreateObserver(GUIThread, OnUpdateValueTrackMoon);
  AniLawElipse.c := EmptyMoonAngle.Position.x;
  AniLawElipse.Duration := round(AniLaw.Duration*3);
  AniLawElipse.Loop := true;
  //AniLaw.LoopInverse := true;
  AniLawElipse.StartValue := vec2(EmptyMoonAngle.Position.x, EmptyMoonAngle.Position.y);
  AniLawElipse.StopValue := vec2(EmptyMoonAngle.Position.x, EmptyMoonAngle.Position.y);
end;

destructor TBSTestEarth.Destroy;
begin
  AniLaw.Stop;
  AniLawElipse.Stop;
  ObsrvElipse := nil;
  ObsrvFloat := nil;
  AniLaw := nil;
  AniLawElipse := nil;
  Sky.Free;
  Moon.Free;
  Earth.Free;
  Empty.Free;
  inherited;
end;

function TBSTestEarth.Run: boolean;
begin
  if (AniLaw <> nil) then
    AniLaw.Run;
  if (AniLawElipse <> nil) then
    AniLawElipse.Run;
  Result := true;
end;

class function TBSTestEarth.TestName: string;
begin
  Result := 'Test Earth Mesh';
end;

{ TBSTestMeshCylinder }

constructor TBSTestMeshCylinder.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Obj := TColoredVertexes.Create(Self, nil, Renderer.Scene);
  Obj.Color := BS_CL_ORANGE;
  Obj.DragResolve := true;
  TBlackSharkFactoryShapesP.GenerateCylinder(Obj.Mesh, 0.1, 20, 0.2);
  Obj.ChangedMesh;
  Obj.Position := vec3(0.5, -1.0, -3.0);
end;

destructor TBSTestMeshCylinder.Destroy;
begin
  Obj.Free;
  inherited;
end;

function TBSTestMeshCylinder.Run: boolean;
begin
  Result := true;
end;

class function TBSTestMeshCylinder.TestName: string;
begin
  Result := 'Test of Cylinder';
end;

end.

