unit bs.test.mesh.skeleton;

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
  , bs.events
  , bs.scene.skeleton
  , bs.canvas
  , bs.gui.checkbox
  , bs.gui.combobox
  , bs.gui.buttons
  ;
type
  TBSTestCollada = class(TBSTest)
  private
    AnimationsCombo: TBComboBox;
    Skeleton: TSkeleton;
    AnimLabel: TCanvasText;
    Canvas: TBCanvas;
    BtnPause: TBButton;
    BtnClickObsrver: IBMouseUpEventObserver;
    ObsrvInstanceSelect: TEventInstanceSelectObserver;
    TxtPosition: TCanvasText;
    TxtPoint: TCanvasText;
    TxtTail: TCanvasText;
    TxtName: TCanvasText;
    Point: TColoredVertexes;
    cbShowBones: TBCheckBox;
    cbHideMesh: TBCheckBox;
    CountGraphicObjectsLoaded: int32;
    procedure OnSelectAnimation(ASender: TBCustomComboBox; AIndex: int32);
    procedure PauseResume(const AData: BMouseData);
    procedure EventInstanceSelect(const AData: BData);
    procedure OnCheckShowBones(ASender: TObject);
    procedure OnCheckHideMesh(ASender: TObject);
    procedure OnEventLoadGraphicObjectProc(AGraphicObject: TGraphicObject);
  protected
    procedure OnMouseMove(const AData: BMouseData); override;
    procedure OnMouseDown(const AData: BMouseData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    bs.texture
  {.$ifndef fpc}
  , SysUtils
  {.$endif}
  , bs.log
  , math
  , bs.config
  , bs.collections
  , bs.thread
  , bs.graphics
  ;

{ TBSTestCollada }

constructor TBSTestCollada.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Allow3dManipulationByMouse := true;
  AllowMoveCameraByKeyboard := true;
  Renderer.Frustum.DistanceFarPlane := 150;
  Renderer.Frustum.Position := vec3(-5.0, 0.0, 12.0);
  //Renderer.Frustum.Position := vec3(7.0, 0.0, 0.0);
  Renderer.Frustum.Angle := vec3(0.0, 20.0, 0.0);
  Canvas := TBCanvas.Create(ARenderer, nil);
  Canvas.Font.Size := 6;
  AnimationsCombo := TBComboBox.Create(Canvas);
  AnimationsCombo.OnSelectComboBoxItem := OnSelectAnimation;
  AnimationsCombo.Resize(100*ToHiDpiScale, 25*ToHiDpiScale);
  AnimationsCombo.Position2d := vec2(10.0*ToHiDpiScale, 20.0*ToHiDpiScale);
  AnimationsCombo.Text := '';
  AnimationsCombo.ReadOnly := true;
  AnimationsCombo.ShowCursor := false;
  BtnPause := TBButton.Create(Canvas);
  BtnPause.Resize(AnimationsCombo.Width, 25*ToHiDpiScale);
  BtnPause.Caption := 'Run';
  // set caption for diagnostic
  BtnPause.Text.Data.Caption := 'Button run/stop of animation';
  BtnPause.Position2d := vec2(AnimationsCombo.Position2d.x + AnimationsCombo.Width + 10*ToHiDpiScale, AnimationsCombo.Position2d.y);
  BtnClickObsrver := BtnPause.OnClickEvent.CreateObserver(PauseResume);
  AnimLabel := TCanvasText.Create(Canvas, nil);
  AnimLabel.Text := 'Animations:';
  AnimLabel.Position2d := vec2(AnimationsCombo.Position2d.x, AnimationsCombo.Position2d.y-AnimLabel.Height-3);
  ARenderer.Frustum.DistanceFarPlane := 500;

  ObsrvInstanceSelect := Renderer.Scene.EventInstanceSelect.CreateObserver(EventInstanceSelect);

  cbShowBones := TBCheckBox.Create(Canvas);
  cbShowBones.Text := 'Show skeleton';
  cbShowBones.OnCheck := OnCheckShowBones;
  cbShowBones.Position2d := vec2(AnimationsCombo.Left, AnimationsCombo.Top + AnimationsCombo.Height + 5.0*ToHiDpiScale);

  cbHideMesh := TBCheckBox.Create(Canvas);
  cbHideMesh.Text := 'Hide mesh';
  cbHideMesh.OnCheck := OnCheckHideMesh;
  cbHideMesh.Position2d := vec2(cbShowBones.Left, cbShowBones.Top + cbShowBones.Height + 5.0*ToHiDpiScale);

  TxtPosition := TCanvasText.Create(Canvas, nil);
  TxtPosition.Position2d := vec2(cbHideMesh.Left, cbHideMesh.Top + cbHideMesh.Height + 5.0*ToHiDpiScale);
  TxtPosition.Text := 'Position: (0.0, 0.0, 0.0)';
  TxtTail := TCanvasText.Create(Canvas, nil);
  TxtTail.Position2d := vec2(TxtPosition.Position2d.x, TxtPosition.Position2d.y + TxtPosition.Height + 5.0*ToHiDpiScale);
  TxtTail.Text := 'Tip: (0.0, 0.0, 0.0)';
  TxtName := TCanvasText.Create(Canvas, nil);
  TxtName.Position2d := vec2(TxtTail.Position2d.x, TxtTail.Position2d.y + TxtTail.Height + 5.0*ToHiDpiScale);
  TxtName.Text := 'Name: ';
  TxtName.Data.Hidden := true;
  TxtPoint := TCanvasText.Create(Canvas, nil);
  TxtPoint.Position2d := TxtName.Position2d;
  TxtPoint.Text := 'Point: (0.0, 0.0, 0.0)';

  Point := TColoredVertexes.Create(nil, nil, Renderer.Scene);
  Point.Hidden := true;
  TBlackSharkFactoryShapesP.GenerateSphere(Point.Mesh, 20, 0.04);
  Point.ChangedMesh;

end;

destructor TBSTestCollada.Destroy;
begin
  Skeleton.Free;
  BtnClickObsrver := nil;
  ObsrvInstanceSelect := nil;
  Point.Free;
  AnimationsCombo.Free;
  BtnPause.Free;
  cbShowBones.Free;
  cbHideMesh.Free;
  Canvas.Free;
  Renderer.Scene.Clear;
  inherited;
end;

procedure TBSTestCollada.EventInstanceSelect(const AData: BData);
begin
  if PGraphicInstance(AData.Instance).Owner.Owner is TBone then
  begin
    TxtPosition.Text := 'Position: ' + VecToStr(TVec3f(TBone(PGraphicInstance(AData.Instance).Owner.Owner).Transform.M3));
    TxtTail.Text := 'Tip: ' + VecToStr(TBone(PGraphicInstance(AData.Instance).Owner.Owner).Tip);
    TxtName.Data.Hidden := false;
    TxtName.Text := 'Name: ' + TBone(PGraphicInstance(AData.Instance).Owner.Owner).Caption;
    TxtPoint.Position2d := vec2(TxtName.Position2d.x, TxtName.Position2d.y + TxtName.Height + 5.0*ToHiDpiScale);
  end else
  if PGraphicInstance(AData.Instance).Owner.Owner is TSkeleton then
  begin
    TxtPosition.Text := 'Skeleton position: ' + VecToStr(TSkeleton(PGraphicInstance(AData.Instance).Owner.Owner).Position);
    TxtName.Data.Hidden := true;
    TxtTail.Text := 'Mesh position: ' + VecToStr(TSkeleton(PGraphicInstance(AData.Instance).Owner.Owner).Skin.Position);
    TxtPoint.Position2d := TxtName.Position2d;
  end;
end;

procedure TBSTestCollada.OnCheckHideMesh(ASender: TObject);
begin
  if not Assigned(Skeleton) or not Assigned(Skeleton.Skin) then
    exit;
  if cbHideMesh.IsChecked then
    Skeleton.Skin.Opacity := 0.0
  else
    Skeleton.Skin.Opacity := 1.0;
end;

procedure TBSTestCollada.OnCheckShowBones(ASender: TObject);
begin
  if not Assigned(Skeleton) then
    exit;
  Skeleton.ShowBones := cbShowBones.IsChecked;
end;

procedure TBSTestCollada.OnEventLoadGraphicObjectProc(AGraphicObject: TGraphicObject);
begin
  inc(CountGraphicObjectsLoaded);
end;

procedure TBSTestCollada.OnMouseDown(const AData: BMouseData);
var
  p: TVec2f;
  i: int32;
  dist, dist_min: BSFloat;
  p_min: TVec3f;
  mesh: TMesh;
  origin: TVec3f;
begin
  inherited;
  if not Assigned(Skeleton) or not Assigned(Skeleton.Skin) then
    exit;

  if Assigned(Skeleton.SkinMeshCopy) then
    mesh := Skeleton.SkinMeshCopy
  else
    mesh := Skeleton.Skin.Mesh;

  dist_min := MaxSingle;
  p_min := vec3(0.0, 0.0, 0.0);
  for i := 0 to mesh.CountVertex - 1 do
  begin
    origin := mesh.ReadPoint(i);

    p := Renderer.ScenePositionToScreenf(Skeleton.Skin.BaseInstance.ProdStackModelMatrix * origin);
    dist := VecLen(vec2(AData.X, AData.Y)-p);
    if dist < dist_min then
    begin
      dist_min := dist;
      p_min := origin;
    end;
  end;

  if dist_min <> MaxSingle then
  begin
    TxtPoint.Text := 'Point: ' + VecToStr(p_min+Skeleton.Skin.Position+Skeleton.SkinCenterOffset);
    Point.Position := p_min;
    Point.Hidden := false;
  end else
  begin
    TxtPoint.Text := 'Point: ' + VecToStr(p_min);
    Point.Hidden := true;
  end;

  {$ifdef DEBUG_BS}
  BSWriteMsg('TBSTestCollada.OnMouseDown, FPS:', IntToStr(Renderer.FPS) + '; Camera position: ' + VecToStr(Renderer.Frustum.Position));
  {$endif}
end;

procedure TBSTestCollada.OnMouseMove(const AData: BMouseData);
begin
  inherited;

end;

procedure TBSTestCollada.OnSelectAnimation(ASender: TBCustomComboBox; AIndex: int32);
begin
  Skeleton.Animation := ASender.Item[0, AIndex];
end;

procedure TBSTestCollada.PauseResume(const AData: BMouseData);
begin
  if not Assigned(Skeleton) or (Skeleton.Animation = '') then
    exit;

  Skeleton.PauseAnimation := not Skeleton.PauseAnimation;

  if Skeleton.PauseAnimation then
    BtnPause.Caption := 'Run'
  else
    BtnPause.Caption := 'Stop';

  {$ifdef DEBUG_BS}
  if Skeleton.PauseAnimation then
    BSWriteMsg('TBSTestCollada.PauseResume', 'Animation is stoped')
  else
    BSWriteMsg('TBSTestCollada.PauseResume', 'Animation is run');
  {$endif}

end;

function TBSTestCollada.Run: boolean;
var
  bucket: THashTable<string, TSkeletonAnimation>.TBucket;
begin
  CountGraphicObjectsLoaded := 0;
  Skeleton := MeshLoadCollada('Models/Collada/Shark.dae', Renderer, OnEventLoadGraphicObjectProc);
  Result := Assigned(Skeleton);
  if Result then
  begin
    //Skeleton.Skin.Opacity := 0.8;
    Skeleton.Skin.Interactive := false;
    //Skeleton.Skin.ScaleSimple := 0.1;
    Skeleton.Position := -Skeleton.SkinCenterOffset; //
    Skeleton.ShowBones := cbShowBones.IsChecked;
    Skeleton.CalculateOnGPU := true;
    if Skeleton.Animations.GetFirst(bucket) then
    repeat
      AnimationsCombo.AddItem(bucket.Key);
    until not Skeleton.Animations.GetNext(bucket);

    if Skeleton.Animations.Count > 0 then
      AnimationsCombo.SelectedIndex := 0;
  end else
    Result := (CountGraphicObjectsLoaded > 0);

end;

class function TBSTestCollada.TestName: string;
begin
  Result := 'Test of Collada';
end;


end.
