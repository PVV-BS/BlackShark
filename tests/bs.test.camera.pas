unit bs.test.camera;

{$I BlackSharkCfg.inc}

interface

uses
    bs.collections
  , bs.basetypes
  , bs.renderer
  , bs.events
  , bs.scene
  , bs.test
  , bs.shader
  , bs.canvas
  , bs.mesh.primitives
  , bs.animation
  , bs.scene.objects
  , bs.gui.buttons
  ;

type

  TBSCamera2dIn3d = class(TBSTest)
  const
    PERIOD = 3;
    GRID_WIDTH = 400.0;
    GRID_HEIGHT = 300.0;
    COUNT_GRIDS = 16;
  private
    FGrids: array[0..COUNT_GRIDS-1] of TGrid;
    FUnionBB: TBox3f;
    FCanvas: TBCanvas;
    RunEncircleByScreen: TBButton;
    ClickObsrv: IBMouseEventObserver;
    FStartPositoin: TVec3f;
    FStopPosition: TVec3f;
    FDelta: TVec3f;
    FAnim: IBAnimationLinearFloat;
    FAnimObsrv: IBAnimationLinearFloatObsrv;
    function CreateGrid(Index: int32): TGrid;
    procedure OnClick(const AData: BMouseData);
    procedure OnChange(const AData: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    sysutils
  , bs.math
  , bs.thread
  ;

constructor TBSCamera2dIn3d.Create(ARenderer: TBlackSharkRenderer);
var
  i: int32;
begin
  inherited;
  Allow3dManipulationByMouse := true;
  FRenderer.Frustum.DistanceFarPlane := 200;

  FCanvas := TBCanvas.Create(ARenderer, nil);
  FCanvas.StickOnScreen := false;

  for i := 0 to length(FGrids) - 1 do
    FGrids[i] := CreateGrid(i);

  RunEncircleByScreen := TBButton.Create(ARenderer);
  RunEncircleByScreen.Position2d := vec2(30.0, 30.0);
  RunEncircleByScreen.Caption := 'To screen';
  { set z-position over grid }
  RunEncircleByScreen.MainBody.Layer2d := 5;

  ClickObsrv := RunEncircleByScreen.OnClickEvent.CreateObserver(OnClick);
  FAnim := CreateAniFloatLinear(GUIThread);
  FAnim.Duration := 1500;
  FAnim.Loop := false;
  FAnim.StartValue := 0.0;
  FAnim.StopValue := 1.0;
  FAnimObsrv := FAnim.CreateObserver(GUIThread, OnChange);

end;

function TBSCamera2dIn3d.CreateGrid(Index: int32): TGrid;
begin
  Result := TGrid.Create(FCanvas, nil);
  Result.Size := vec2(GRID_WIDTH, GRID_HEIGHT);
  Result.StepX := 50;
  Result.Stepy := 50;
  Result.VertLines := true;
  Result.HorLines := true;
  Result.Closed := true;
  Result.WidthLines := 1.0;
  Result.Build;
  Result.Position2d := vec2((GRID_WIDTH + 30) * (Index mod PERIOD), (GRID_HEIGHT + 30) * (Index div PERIOD));
end;

destructor TBSCamera2dIn3d.Destroy;
begin
  ClickObsrv := nil;
  FAnim.Stop;
  FAnim := nil;
  FAnimObsrv := nil;
  RunEncircleByScreen.Free;
  FCanvas.Free;
  inherited;
end;

procedure TBSCamera2dIn3d.OnChange(const AData: BSFloat);
begin
  FRenderer.Frustum.Position := FStartPositoin + FDelta*AData;
end;

procedure TBSCamera2dIn3d.OnClick(const AData: BMouseData);
var
  kx, ky, k, d, z: BSFloat;
  i: int32;
begin
  FUnionBB := FGrids[0].Data.BaseInstance.BoundingBox;
  for i := 1 to length(FGrids) - 1 do
  begin
    FUnionBB := Box3Union(FUnionBB, FGrids[i].Data.BaseInstance.BoundingBox);
  end;

  FStartPositoin := Renderer.Frustum.Position;

  kx := (FUnionBB.x_max - FUnionBB.x_min)/Renderer.Frustum.NearPlaneWidth;
  ky := (FUnionBB.y_max - FUnionBB.y_min)/Renderer.Frustum.NearPlaneHeight;
  if kx > ky then
  begin
    k := Renderer.Frustum.DistanceNearPlane/(Renderer.Frustum.NearPlaneWidth*0.5);
    z := (FUnionBB.x_max - FUnionBB.x_min)*0.5*k;
  end else
  begin
    k := Renderer.Frustum.DistanceNearPlane/(Renderer.Frustum.NearPlaneHeight*0.5);
    z := (FUnionBB.y_max - FUnionBB.y_min)*0.5*k;
  end;

  FStopPosition := PlanePointProjection(Plane(vec3(0.0, 0.0, -1.0), vec3(0.0, 0.0, Renderer.Frustum.DistanceNearPlane)), FUnionBB.Middle, d);
  FStopPosition.z := z + Renderer.Frustum.DISTANCE_2D_SCREEN;
  FDelta := FStopPosition - FStartPositoin;
  FAnim.Run;
end;

function TBSCamera2dIn3d.Run: boolean;
begin
  Result := true;
end;

class function TBSCamera2dIn3d.TestName: string;
begin
  Result := 'Test TBSCamera2dIn3d';
end;

initialization
  RegisterTest(TBSCamera2dIn3d);

end.
