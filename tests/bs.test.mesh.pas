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
  , bs.events
  , bs.gui.buttons
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

  { TBSTestEarth }

  TBSTestEarth = class(TBSTest)
  private
    AniLaw: IBAnimationLinearFloat;
    AniLawElipse: IBAnimationElipse;
    ObsrvFloat: IBAnimationLinearFloatObsrv;
    ObsrvElipse: IBAnimationElipseObsrv;
    AniFly: IBAnimationPath3d;
    ObsrvFly: IBAnimationPath3dObsrv;
    Earth: TTexturedVertexes;
    Clouds: TTexturedVertexes;
    CloudsBack: TTexturedVertexes;
    Moon: TTexturedVertexes;
    Empty: TGraphicObject;
    EmptyMoon: TGraphicObject;
    EmptyMoonAngle: TGraphicObject;
    Sky: TTexturedVertexes;
    //Tmp: TColoredVertexes;
    Button: TBButton;
    OnClckObsr: IBMouseDownEventObserver;
    //Path: TGraphicObjectLines;
    procedure OnUpdateValueAngle(const Value: BSFloat);
    procedure OnUpdateValueTrackMoon(const Value: TVec2f);
    procedure OnUpdatePosFly(const Value: TVec3f);
  	procedure OnButtonFlyClick(const AData: BMouseData);
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
  , bs.graphics
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

procedure TBSTestEarth.OnUpdatePosFly(const Value: TVec3f);
begin
  if not AniFly.IsRun then
    exit;
  Renderer.Frustum.BeginUpdate;
  Renderer.Frustum.Position := Value;
	Renderer.Frustum.Angle := vec3(0.0, AniFly.CurrentNormalizedTime*360, 0.0);
  Renderer.Frustum.EndUpdate;
end;

procedure TBSTestEarth.OnButtonFlyClick(const AData: BMouseData);
//var
//  i: int32;
begin
	if AniFly.IsRun then
  begin
    AniFly.Stop;
  end else
  begin
  	AniFly.Run;
    //Path.Clear;
    //Path.BeginUpdate;
    //Path.MoveTo(AniFly.PointsInterpolated.Items[0]);
    //for i := 1 to AniFly.PointsInterpolated.Count - 1 do
    //begin
    //  Path.LineTo(AniFly.PointsInterpolated.Items[i]);
    //end;
    //Path.EndUpdate(false);
  end;
end;

constructor TBSTestEarth.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  AllowMoveCameraByKeyboard := true;
  Renderer.Frustum.Angle := vec3(0.0, 0.0, 0.0);
  Renderer.Frustum.DistanceFarPlane := 500;
  Sky := TTexturedVertexes.Create(Self, nil, Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(Sky.Mesh, 10, Renderer.Frustum.DistanceFarPlane * 0.5, true); //
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
  TBlackSharkFactoryShapesPT.GenerateSphere(Earth.Mesh, 10, Renderer.ScreenSizeToScene(round(500)), true);
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
  TBlackSharkFactoryShapesPT.GenerateSphere(Clouds.Mesh, 10, Renderer.ScreenSizeToScene(round(525)), true);
  Clouds.Texture := BSTextureManager.LoadTexture('Pictures/earth/earthcloudmapcolortrans.png');
  Clouds.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  Clouds.Interactive := false;
  //Clouds.Opacity := 0.6;
  Clouds.Caption := 'C';
  Clouds.ChangedMesh;
  Clouds.DrawSides := dsFront;
  CloudsBack := TTexturedVertexes.Create(Self, Earth , Renderer.Scene);
  TBlackSharkFactoryShapesPT.GenerateSphere(CloudsBack.Mesh, 10, Renderer.ScreenSizeToScene(round(525)), true);
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
  TBlackSharkFactoryShapesPT.GenerateSphere(Moon.Mesh, 10, Renderer.ScreenSizeToScene(round(150)), true);
  Moon.Texture := BSTextureManager.LoadTexture('Pictures/earth/moonmap1k.png');
  Moon.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  //Moon.DragResolve := false;
  //Moon.Interactive := false;
  Moon.DrawSides := dsFront;
  Moon.ChangedMesh;
  //Moon.Hide := true;
  EmptyMoonAngle.Position := vec3(Renderer.ScreenSizeToScene(round(2000)), 0.0, 0.0);

  AniLaw := CreateAniFloatLinear(GUIThread);
  ObsrvFloat := AniLaw.CreateObserver(GUIThread, OnUpdateValueAngle);
  AniLaw.Duration := 20000;
  AniLaw.Loop := true;
  AniLaw.IntervalUpdate := 0;
  //AniLaw.LoopInverse := true;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 360.0;
  AniLawElipse := CreateAniElipse(GUIThread);
  ObsrvElipse := AniLawElipse.CreateObserver(GUIThread, OnUpdateValueTrackMoon);
  AniLawElipse.c := EmptyMoonAngle.Position.x;
  AniLawElipse.Duration := round(AniLaw.Duration*3);
  AniLawElipse.Loop := true;
  AniLawElipse.IntervalUpdate := 0;
  //AniLaw.LoopInverse := true;
  AniLawElipse.StartValue := vec2(EmptyMoonAngle.Position.x, EmptyMoonAngle.Position.y);
  AniLawElipse.StopValue := vec2(EmptyMoonAngle.Position.x, EmptyMoonAngle.Position.y);

  Button := TBButton.Create(ARenderer);
  Button.Caption := 'Fly';
  Button.Canvas.Font.Size := 10;
  OnClckObsr := Button.OnClickEvent.CreateObserver(OnButtonFlyClick);
  Button.Position2d := vec2(20.0, 20.0);

  AniFly := CreateAniPath3d(NextExecutor);
  ObsrvFly := AniFly.CreateObserver(GUIThread, OnUpdatePosFly);
  AniFly.Duration := 10000;
  AniFly.IntervalUpdate := 0;
  AniFly.InterpolateFactor := 0.001;
  AniFly.Loop := false;
  AniFly.InterpolateSpline := TInterpolateSpline.isCubicHermite;
  AniFly.AddPoint(Renderer.Frustum.Position);
  AniFly.AddPoint(vec3(-3, 0.0, -4.0));
  AniFly.AddPoint(vec3(0.0, 0.0, -7));
  AniFly.AddPoint(vec3(3, 0.0, -4.0));
  AniFly.AddPoint(Renderer.Frustum.Position);
  AniFly.StartValue := Renderer.Frustum.Position;
  AniFly.StopValue := Renderer.Frustum.Position;

  //Path := TGraphicObjectLines.Create(nil, nil, Renderer.Scene);
end;

destructor TBSTestEarth.Destroy;
begin
  AniLaw.Stop;
  AniLawElipse.Stop;
  AniFly.Stop;
  ObsrvFly := nil;
  AniFly := nil;
  ObsrvElipse := nil;
  ObsrvFloat := nil;
  AniLaw := nil;
  AniLawElipse := nil;
  //Path.Free;
  Sky.Free;
  Moon.Free;
  Earth.Free;
  Empty.Free;
  Button.Free;
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

