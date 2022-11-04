unit bs.test;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.renderer
  , bs.log
  , bs.collections
  , bs.events
  , bs.animation
  ;

type

  TBSTest = class;
  TBSTestClass = class of TBSTest;

  { TBSTest }

  TBSTest = class abstract
  private
    ObsrvRsize: IBResizeWindowEventObserver;
    ObsrvMoveCamera: IBEmptyEventObserver;
    ObsrvKeyDown: IBKeyEventObserver;
    ObsrvKeyUp: IBKeyEventObserver;
    ObsrvMouseWeel: IBMouseEventObserver;
    ObsrvMouseDown: IBMouseEventObserver;
    ObsrvMouseMove: IBMouseEventObserver;
    ObsrvMouseUp: IBMouseEventObserver;
    Anim: IBAnimationLinearFloat;
    AniObserver: IBAnimationLinearFloatObsrv;
    MouseStartPos: TVec2f;
    FrustumStartPos: TVec3f;
    FrustumStartAngle: TVec3f;
    QuaternionStart: TQuaternion;
    FAllow3dManipulationByMouse: boolean;
    FEventRepaintRequest: IBEmptyEvent;
    FEventResizeRequest: IBResizeWindowEvent;
    FEventMuseDownRequest: IBMouseEvent;
    FAllowMoveCameraByKeyboard: boolean;
    FPressed: boolean;
    FCount: int32;
  protected
    FRenderer: TBlackSharkRenderer;
    //FViewport: TBlackSharkViewport;
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); virtual;
    procedure OnMoveCamera({%H-}const Data: BData); virtual;
    procedure OnKeyDown({%H-}const Data: BKeyData); virtual;
    procedure OnKeyUp({%H-}const Data: BKeyData); virtual;
    procedure OnMove(const AValue: BSFloat); virtual;
    procedure OnMouseWeel(const AData: BMouseData); virtual;
    procedure OnMouseDown(const AData: BMouseData); virtual;
    procedure OnMouseMove(const AData: BMouseData); virtual;
    procedure OnMouseUp(const AData: BMouseData); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); virtual;
    destructor Destroy; override;
    function Run: boolean; virtual; abstract;
    class procedure SendMessage(const Source, Message: string);
    class function TestName: string; virtual; abstract;
    //property Viewport: TBlackSharkViewport read FViewport write FViewport;
    property Renderer: TBlackSharkRenderer read FRenderer;
    property Allow3dManipulationByMouse: boolean read FAllow3dManipulationByMouse write FAllow3dManipulationByMouse;
    property AllowMoveCameraByKeyboard: boolean read FAllowMoveCameraByKeyboard write FAllowMoveCameraByKeyboard;
    property EventResizeRequest: IBResizeWindowEvent read FEventResizeRequest;
    property EventRepaintRequest: IBEmptyEvent read FEventRepaintRequest;
    property EventMuseDownRequest: IBMouseEvent read FEventMuseDownRequest;
  end;

  function TestsCount: int32;
  function GetClassTest(index: int32): TBSTestClass;
  procedure RegisterTest(TestClass: TBSTestClass);

implementation

uses
    math
  , bs.thread
  , bs.math
  , bs.config
  ;
var
  ListTests: TListVec<TBSTestClass>;

function TestsCount: int32;
begin
  Result := ListTests.Count;
end;

function GetClassTest(index: int32): TBSTestClass;
begin
  Result := ListTests.Items[index];
end;

procedure RegisterTest(TestClass: TBSTestClass);
var
  i: int32;
begin
  for i := 0 to ListTests.Count - 1 do
    if ListTests.Items[i].TestName = TestClass.TestName then
      exit;
  ListTests.Add(TestClass);
end;

{ TBSTest }

constructor TBSTest.Create(ARenderer: TBlackSharkRenderer);
begin
  FRenderer := ARenderer;
  FEventRepaintRequest := CreateEmptyEvent;
  FEventResizeRequest := CreateResizeWindowEvent;
  FEventMuseDownRequest := CreateMouseEvent;

  Renderer.Frustum.BeginUpdate;
  Renderer.Frustum.OrtogonalProjection := false;
  Renderer.Frustum.Angle := Renderer.Frustum.DEFAULT_DIRECT_ANGLE;
  Renderer.Frustum.Position := Renderer.Frustum.DEFAULT_POSITION;
  Renderer.Frustum.EndUpdate;
  Renderer.Color := vec4(0.1764, 0.1764, 0.1764, 0.598);
  ObsrvRsize := ARenderer.EventResize.CreateObserver(GUIThread, OnResizeViewport);
  ObsrvMoveCamera := ARenderer.EventMoveFrustum.CreateObserver(GUIThread, OnMoveCamera);
  ObsrvKeyDown := ARenderer.EventKeyDown.CreateObserver(GUIThread, OnKeyDown);
  ObsrvKeyUp := ARenderer.EventKeyUp.CreateObserver(GUIThread, OnKeyUp);
  ObsrvMouseWeel := ARenderer.EventMouseWeel.CreateObserver(GUIThread, OnMouseWeel);
  ObsrvMouseDown := ARenderer.EventMouseDown.CreateObserver(GUIThread, OnMouseDown);
  ObsrvMouseMove := ARenderer.EventMouseMove.CreateObserver(GUIThread, OnMouseMove);
  ObsrvMouseUp := ARenderer.EventMouseUp.CreateObserver(GUIThread, OnMouseUp);
  Anim := CreateAniFloatLinear(GUIThread);
  Anim.StartValue := 0.0;
  Anim.StopValue := 1.0;
  Anim.Duration := 100;
  Anim.Loop := true;
  Anim.LoopInverse := true;
  { for max FPC }
  Anim.IntervalUpdate := 0;
  AniObserver := CreateAniFloatLivearObsrv(Anim, OnMove);
end;

destructor TBSTest.Destroy;
begin
  Anim.Stop;
  AniObserver := nil;
  Anim := nil;
  ObsrvRsize := nil;
  ObsrvMoveCamera := nil;
  ObsrvKeyDown := nil;
  ObsrvKeyUp := nil;
  ObsrvMouseWeel := nil;
  ObsrvMouseDown := nil;
  ObsrvMouseUp := nil;
  ObsrvMouseMove := nil;
  inherited;
end;

procedure TBSTest.OnKeyDown(const Data: BKeyData);
begin
  if (FCount > 0) and not FPressed then
    FCount := 0;
  FPressed := true;
  inc(FCount);
  if FAllowMoveCameraByKeyboard and (Data.Key in [37, 38, 39, 40, 87, 83, 65, 68]) then
    Anim.Run;
end;

procedure TBSTest.OnKeyUp(const Data: BKeyData);
begin
  FPressed := false;
  if not Renderer.Keyboard[87] and not Renderer.Keyboard[83] and not Renderer.Keyboard[65] and not Renderer.Keyboard[68]
   and not Renderer.Keyboard[37] and not Renderer.Keyboard[38] and not Renderer.Keyboard[39] and not Renderer.Keyboard[40] then
    Anim.Stop;
end;

procedure TBSTest.OnMouseDown(const AData: BMouseData);
begin
  FrustumStartPos := Renderer.Frustum.Position;
  FrustumStartAngle := Renderer.Frustum.Angle;
  QuaternionStart := Renderer.Frustum.Quaternion;
  MouseStartPos := vec2(AData.X, AData.Y);
end;

procedure TBSTest.OnMouseMove(const AData: BMouseData);
var
  delta: TVec3f;
  a: TVec3f;
begin
  if Renderer.MouseIsDown then
  begin
    if FAllow3dManipulationByMouse then
    begin
      if Renderer.MouseButtonKeep = TBSMouseButton.mbBsLeft then
      begin
        if (Renderer.SelectedItemsCount = 0) then
        begin
          delta := Renderer.Frustum.RotateMatrixInv*Renderer.ScreenSizeToScene(Renderer.MouseNowPos - MouseStartPos);
          Renderer.Frustum.Position := FrustumStartPos + delta*2;
        end;
      end else
      if Renderer.MouseButtonKeep = TBSMouseButton.mbBsMiddle then
      begin
        a.y := BS_RAD2DEG*arctan2((MouseStartPos.x-AData.X)*BSConfig.VoxelSize, Renderer.Frustum.DistanceNearPlane);
        a.x := BS_RAD2DEG*arctan2((MouseStartPos.y-AData.y)*BSConfig.VoxelSize, Renderer.Frustum.DistanceNearPlane);
        a.z := 0;
        if (abs(a.x) < EPSILON) and (abs(a.y) < EPSILON) then
          exit;
        Renderer.Frustum.Quaternion := QuaternionMult(QuaternionStart, Quaternion(a));
      end;
    end;
  end;
end;

procedure TBSTest.OnMouseUp(const AData: BMouseData);
begin

end;

procedure TBSTest.OnMouseWeel(const AData: BMouseData);
begin
  Renderer.Frustum.Position := Renderer.Frustum.Position + Renderer.Frustum.Direction*AData.DeltaWeel*0.01;
end;

procedure TBSTest.OnMove(const AValue: BSFloat);
var
  s: BSFloat;
begin
  if not Anim.IsRun then
    exit;
  // TODO: speed of move
  Renderer.Frustum.BeginUpdate;
  if Renderer.Keyboard[87] then  //w
    Renderer.Frustum.Position := Renderer.Frustum.Position + Renderer.Frustum.Direction*0.5
  else
  if Renderer.Keyboard[83] then  //s
    Renderer.Frustum.Position := Renderer.Frustum.Position - Renderer.Frustum.Direction*0.5;
  s := IfThen(Renderer.Keyboard[87] or Renderer.Keyboard[83], 0.5, 0.5);
  if Renderer.Keyboard[65] then  //a
    Renderer.Frustum.Position := Renderer.Frustum.Position - Renderer.Frustum.Right * s
  else
  if Renderer.Keyboard[68] then  //d
    Renderer.Frustum.Position := Renderer.Frustum.Position + Renderer.Frustum.Right * s;
  if Renderer.Keyboard[38] then  //up
    Renderer.Frustum.Quaternion := VecNormalize(QuaternionMult(Renderer.Frustum.Quaternion, Quaternion(vec3(-0.5, 0.0, 0.0))))
  else
  if Renderer.Keyboard[40] then  //down
    Renderer.Frustum.Quaternion := VecNormalize(QuaternionMult(Renderer.Frustum.Quaternion, Quaternion(vec3(0.5, 0.0, 0.0))));
  if Renderer.Keyboard[37] then  //left
    Renderer.Frustum.Quaternion := VecNormalize(QuaternionMult(Renderer.Frustum.Quaternion, Quaternion(vec3(0.0, 0.5, 0.0))))
  else
  if Renderer.Keyboard[39] then  //right
    Renderer.Frustum.Quaternion := VecNormalize(QuaternionMult(Renderer.Frustum.Quaternion, Quaternion(vec3(0.0, -0.5, 0.0))));
  Renderer.Frustum.EndUpdate;
end;

procedure TBSTest.OnMoveCamera(const Data: BData);
begin

end;

procedure TBSTest.OnResizeViewport(const Data: BResizeEventData);
begin

end;

class procedure TBSTest.SendMessage(const Source, Message: string);
begin
  BSWriteMsg(Source, Message);
end;


initialization
  ListTests := TListVec<TBSTestClass>.Create;
finalization
  ListTests.Free;

end.
