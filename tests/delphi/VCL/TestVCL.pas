unit TestVCL;

{$I BlackSharkCfg.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ActnList, Vcl.Buttons, uSecondContext, System.Actions,
  bs.viewport, bs.test, bs.gl.context, bs.events
  ;

type
  TfrmMain = class(TForm)
    PanelInfo: TPanel;
    PanelScreen: TPanel;
    Label1: TLabel;
    cbAvailableTests: TComboBox;
    LblX: TLabel;
    LblY: TLabel;
    cbMaxFPS: TCheckBox;
    cbMSAAByKernel: TCheckBox;
    cbMSAA: TCheckBox;
    ActionList: TActionList;
    ActnEsc: TAction;
    cbFXAA: TCheckBox;
    GroupBox1: TGroupBox;
    cbKernels: TComboBox;
    lblKernel: TLabel;
    GroupBox2: TGroupBox;
    lblSizeInstance: TLabel;
    lblPos3d: TLabel;
    lblPos2d: TLabel;
    vblSize2d: TLabel;
    lblPos2dLU: TLabel;
    Timer: TTimer;
    btnStart: TBitBtn;
    cbPSSAA: TCheckBox;
    MemoEvents: TMemo;
    BtnOutEvents: TBitBtn;
    Splitter1: TSplitter;
    LblDistance: TLabel;
    lblFontTextures: TLabel;
    TimerUpdate: TTimer;
    SbScreenShort: TSpeedButton;
    SaveAsPic: TSaveDialog;
    LblAllTextures: TLabel;
    LblSizeTextures: TLabel;
    btnCreateNewContext: TButton;
    procedure FormShow(Sender: TObject);
    procedure PanelScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure cbAvailableTestsChange(Sender: TObject);
    procedure cbMaxFPSClick(Sender: TObject);
    procedure cbMSAAClick(Sender: TObject);
    procedure cbMSAAByKernelClick(Sender: TObject);
    procedure ActnEscExecute(Sender: TObject);
    procedure cbFXAAClick(Sender: TObject);
    procedure cbKernelsChange(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure cbPSSAAClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOutEventsClick(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure PanelInfoClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SbScreenShortClick(Sender: TObject);
    procedure btnCreateNewContextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    ViewPort: TBlackSharkViewPort;
    CurrentTest: TBSTest;
    CommandLineParam: string;
    ObsrvResizeRequest: IBResizeWindowEventObserver;
    ObsrvRepaintRequest: IBEmptyEventObserver;
    ObsrvMouseDownRequest: IBMouseEventObserver;
    procedure AfterCreateContextEvent (Sender: TObject);
    procedure CheckLeaks;
    procedure RunTest(ATestClass: TBSTestClass);
    procedure OnPaintMainViewport(Sender: TObject);
    procedure OnSecondFormShow(Sender: TObject);
    procedure OnResizeRequest(const AData: BResizeEventData);
    procedure OnRepaintRequest(const AData: BEmpty);
    procedure OnMouseDownRequest(const AData: BMouseData);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
    RTTI
  , bs.config
  , bs.renderer
  , bs.scene
  , bs.texture
  , bs.font
  , bs.BaseTypes
  , bs.graphics
  ;

{$R *.dfm}

procedure TfrmMain.ActnEscExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.AfterCreateContextEvent(Sender: TObject);
var
  i: int32;
  ClassTest: TBSTestClass;
begin
  //ViewPort.MaxFPS := cbMaxFPS.Checked;
  //ViewPort.Renderer.SmoothByKernelMSAA := cbMSAAByKernel.Checked;
  //ViewPort.Renderer.SmoothMSAA := cbMSAA.Checked;
  for i := 0 to TestsCount - 1 do
  begin
    ClassTest := GetClassTest(i);
    cbAvailableTests.Items.AddObject(ClassTest.TestName, Pointer(ClassTest));
  end;

  if not CommandLineParam.IsEmpty then
  begin
    for i := 0 to cbAvailableTests.Items.Count - 1 do
    begin
      if TBSTestClass(cbAvailableTests.Items.Objects[i]).ClassName = CommandLineParam then
      begin
        cbAvailableTests.ItemIndex := i;
        cbAvailableTestsChange(Self);
        break;
      end;
    end;
  end;

  if cbAvailableTests.ItemIndex < 0 then
  begin
    cbAvailableTests.ItemIndex := cbAvailableTests.Items.Count - 1;
    cbAvailableTestsChange(Self);
  end;
end;

procedure TfrmMain.btnCreateNewContextClick(Sender: TObject);
begin
  FrmSecondContext.Show;
end;

procedure TfrmMain.BtnOutEventsClick(Sender: TObject);
var
  s: string;
begin
  if ViewPort = nil then
    exit;

  //s := ViewPort.CurrentScene.EventsManager.GetListRegisteredEvents +
  //  #$0d + #$0a + #$0d + #$0a + 'Animator:' + #$0d + #$0a +
  //  ViewPort.CurrentScene.Animator.GetListRegisteredEvents;
  MemoEvents.Lines.Text := s;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  Timer.Enabled := not Timer.Enabled;
end;

procedure TfrmMain.cbAvailableTestsChange(Sender: TObject);
begin
  if cbAvailableTests.ItemIndex < 0 then
    exit;
  if CurrentTest <> nil then
  begin
    FreeAndNil(CurrentTest);
    CheckLeaks;
  end;
  if Visible and Active then
  begin
    RunTest(TBSTestClass(cbAvailableTests.Items.Objects[cbAvailableTests.ItemIndex]));
  end;
end;

procedure TfrmMain.cbFXAAClick(Sender: TObject);
begin
//  ViewPort.Renderer.SmoothFXAA := cbFXAA.Checked;
end;

procedure TfrmMain.cbKernelsChange(Sender: TObject);
begin
  ViewPort.Renderer.KernelSSAA := TSamplingKernel(cbKernels.ItemIndex);
end;

procedure TfrmMain.cbMaxFPSClick(Sender: TObject);
begin
  //ViewPort.MaxFPS := cbMaxFPS.Checked;
end;

procedure TfrmMain.cbMSAAClick(Sender: TObject);
begin
  ViewPort.Renderer.SmoothMSAA := cbMSAA.Checked;
end;

procedure TfrmMain.cbPSSAAClick(Sender: TObject);
begin
//  ViewPort.Renderer.SmoothSharkSSAA := cbPSSAA.Checked;
end;

procedure TfrmMain.cbMSAAByKernelClick(Sender: TObject);
begin
//  ViewPort.Renderer.SmoothByKernelMSAA := cbMSAAByKernel.Checked;
  lblKernel.Enabled := cbMSAAByKernel.Checked;
  cbKernels.Enabled := cbMSAAByKernel.Checked;
end;

procedure TfrmMain.CheckLeaks;
{$ifdef DEBUG_BS}
//var
//  s: string;
//  box: PBox3f;
{$endif}
begin
  //if (ViewPort <> nil) and (ViewPort.CurrentScene <> nil) and (((ViewPort.ShowServiceInfo) and (ViewPort.CurrentScene.BVH.CountObjects > 1)) or
  //  ((not ViewPort.ShowServiceInfo) and (ViewPort.CurrentScene.BVH.CountObjects > 0))) then
  if Assigned(ViewPort) and Assigned(ViewPort.Renderer) and (ViewPort.Renderer.Scene.Count > 0) then
  begin
    {$ifdef DEBUG_BS}
      {box := ViewPort.Renderer.BVH.GetFirst;
      while box <> nil do
      begin
        if Assigned(PGraphicInstance(box.TagPtr).Owner.Owner) then
        begin
          if s <> '' then
            s := s + ', ' + PGraphicInstance(box.TagPtr).Owner.Owner.ClassName
          else
            s := PGraphicInstance(box.TagPtr).Owner.Owner.ClassName;
        end;
        box := ViewPort.Renderer.BVH.GetNext;
      end;  }
      //raise Exception.Create('Not all objects were released: ' + s);
    {$else}
    {$endif}
    raise Exception.Create('Not all objects released!');
  end;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
var
  i: int32;
begin
  if Showing and (ViewPort <> nil) and not Assigned(CurrentTest) then
  begin
    if not CommandLineParam.IsEmpty then
    begin
      for i := 0 to cbAvailableTests.Items.Count - 1 do
      begin
        if TBSTestClass(cbAvailableTests.Items.Objects[i]).ClassName = CommandLineParam then
        begin
          RunTest(TBSTestClass(cbAvailableTests.Items.Objects[i]));
          exit;
        end;
      end;
    end;

    if (cbAvailableTests.ItemIndex >= 0) then
      RunTest(TBSTestClass(cbAvailableTests.Items.Objects[cbAvailableTests.ItemIndex]));

  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ObsrvResizeRequest := nil;
  ObsrvRepaintRequest := nil;
  ObsrvMouseDownRequest := nil;
  FreeAndNil(CurrentTest);
  CheckLeaks;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CommandLineParam := ParamStr(1);
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  sk: TSamplingKernel;
begin
  BSConfig.MaxFps := true;
  ViewPort := TBlackSharkViewPort.Create(PanelScreen);
  ViewPort.OnAfterCreateContext := AfterCreateContextEvent;
  ViewPort.OnMouseMove := PanelScreenMouseMove;
  ViewPort.Align := alClient;
  ViewPort.OnPaint := OnPaintMainViewport;
  FrmSecondContext.OnShow := OnSecondFormShow;
  if Assigned(ViewPort.Renderer) then
  begin
    //ViewPort.Renderer.SmoothByKernelMSAA := cbMSAAByKernel.Checked;
    //ViewPort.Renderer.SmoothMSAA := cbMSAA.Checked;
  end;
  for sk := Low(TSamplingKernel) to High(TSamplingKernel) do
    cbKernels.Items.Add(TRttiEnumerationType.GetName(sk));
  if Assigned(ViewPort.Renderer) then
    cbKernels.ItemIndex := int32(ViewPort.Renderer.KernelSSAA);
end;

procedure TfrmMain.OnMouseDownRequest(const AData: BMouseData);
begin
  if TBSMouseButton.mbBsLeft in AData.Button then
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbLeft, AData.ShiftState)
  else
  if TBSMouseButton.mbBsRight in AData.Button then
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbRight, AData.ShiftState)
  else
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbMiddle, AData.ShiftState);
end;

procedure TfrmMain.OnPaintMainViewport(Sender: TObject);
begin
  if FrmSecondContext.Visible and Assigned(FrmSecondContext.ViewPort) then
    FrmSecondContext.ViewPort.Draw;
end;

procedure TfrmMain.OnRepaintRequest(const AData: BEmpty);
begin
  ViewPort.Repaint;
end;

procedure TfrmMain.OnResizeRequest(const AData: BResizeEventData);
begin
  ViewPort.TestResize(AData.NewWidth, AData.NewHeight);
end;

procedure TfrmMain.OnSecondFormShow(Sender: TObject);
begin
//  if Assigned(FrmSecondContext) and Assigned(FrmSecondContext.ViewPort) then
//    FrmSecondContext.ViewPort.CurrentScene := ViewPort.CurrentScene;
end;

procedure TfrmMain.PanelInfoClick(Sender: TObject);
begin
  { viewport to 300x300 }
  Height := 341;
  Width := 546;
  { viewport to 600x600 }
  //Height := 641;
  //Width := 846;
end;

procedure TfrmMain.PanelScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  inst: PRendererGraphicInstance;
  size_inst: TVec3f;
  size_2d: TVec2f;
  pos_3d: TVec3f;
  pos: TVec2i;
begin
  if not Assigned(ViewPort) or not Assigned(ViewPort.Renderer) then
    exit;
  pos_3d := ViewPort.Renderer.ScreenPositionToScene(vec2(X, Y))*BSConfig.VoxelSize;
  LblX.Caption := 'X: ' + IntToStr(X) + ' (' + Format('%f', [pos_3d.x]) + ')';
  LblY.Caption := 'Y: ' + IntToStr(Y) + ' (' + Format('%f', [pos_3d.y]) + ')';
  inst := ViewPort.Renderer.CurrentUnderMouseInstance;
  if Assigned(inst) then
  begin
    size_inst.x := inst.Instance.Owner.ServiceScale*inst.Instance.Owner.Mesh.FBoundingBox.x_max*2;
    size_inst.y := inst.Instance.Owner.ServiceScale*inst.Instance.Owner.Mesh.FBoundingBox.y_max*2;
    size_inst.z := inst.Instance.Owner.ServiceScale*inst.Instance.Owner.Mesh.FBoundingBox.z_max*2;
    pos_3d := TVec3f(inst.Instance.ProdStackModelMatrix.M3)*inst.Instance.Owner.ServiceScale;
    lblSizeInstance.Caption := 'Size 3d: (' + Format('%f; %f; %f)', [size_inst.x, size_inst.y, size_inst.z]);
    size_2d := ViewPort.Renderer.SceneSizeToScreen(vec2(size_inst.x, size_inst.y));
    vblSize2d.Caption := 'Size 2d: (' + Format('%d; %d)', [round(size_2d.x), round(size_2d.y)]);
    lblPos3d.Caption := 'Position 3d: (' + Format('%f; %f; %f)', [pos_3d.x, pos_3d.y, pos_3d.z]);
    pos := ViewPort.Renderer.ScenePositionToScreenf(pos_3d);
    lblPos2d.Caption := 'Position 2d (center): (' + Format('%d; %d)', [pos.x, pos.y]);
    lblPos2dLU.Caption := 'Position 2d (left,up): (' + Format('%d; %d)', [pos.x - round(size_2d.x/2), pos.y - round(size_2d.y/2)]);
    LblDistance.Caption := 'Distance to camera: ' + FloatToStr(inst.DistanceToScreen);
  end else
  begin
    lblSizeInstance.Caption := 'Size 3d: (0; 0)';
    vblSize2d.Caption := 'Size 2d: (0; 0)';
    lblPos3d.Caption := 'Position 3d: (0; 0; 0)';
    lblPos2d.Caption := 'Position 2d (center): (0; 0)';
    lblPos2dLU.Caption := 'Position 2d (left,up): (0; 0)';
  end;
end;

procedure TfrmMain.RunTest(ATestClass: TBSTestClass);
var
  t: Cardinal;
begin
  CurrentTest := ATestClass.Create(ViewPort.Renderer);
  ObsrvResizeRequest := CurrentTest.EventResizeRequest.CreateObserver(OnResizeRequest);
  ObsrvRepaintRequest := CurrentTest.EventRepaintRequest.CreateObserver(OnRepaintRequest);
  ObsrvMouseDownRequest := CurrentTest.EventMuseDownRequest.CreateObserver(OnMouseDownRequest);
  t := GetTickCount;
  CurrentTest.Run;
  MemoEvents.Lines.Add('Start of "' + CurrentTest.TestName + '" has taken ' + IntToStr(GetTickCount - t) + ' ms');
  if Assigned(FrmSecondContext) then
    FrmSecondContext.CurrentScene := ViewPort.CurrentScene;
end;

procedure TfrmMain.SbScreenShortClick(Sender: TObject);
var
  bmp: TBlackSharkBitMap;
begin
  bmp := TBlackSharkBitMap.Create;
  try
    bmp.Width := ViewPort.Width;
    bmp.Height := ViewPort.Height;
    if not ViewPort.Context.MakeCurrent then
      exit;
    ViewPort.Renderer.Screenshot(0, 0, ViewPort.Width, ViewPort.Height, bmp.Canvas.Raw.Memory);
    //if not SaveAsPic.Execute then
    //  exit;
    bmp.Save('d:\screenShot.bmp');
  finally
    bmp.Free;
  end;
end;

procedure TfrmMain.TimerTimer(Sender: TObject);
begin
  if (ViewPort = nil) or (ViewPort.CurrentScene = nil) then
    exit;
  ViewPort.Renderer.Frustum.Angle := vec3(
    ViewPort.Renderer.Frustum.Angle.x,
    ViewPort.Renderer.Frustum.Angle.y + 5,
    ViewPort.Renderer.Frustum.Angle.z);
end;

procedure TfrmMain.TimerUpdateTimer(Sender: TObject);
begin
  if not Assigned(ViewPort) or not Assigned(ViewPort.Renderer) then
    exit;
  lblFontTextures.Caption := 'Font textures: ' + IntToStr(BSFontManager.CountFontTextures);
  lblAllTextures.Caption := 'All textures: ' + IntToStr(BSTextureManager.CountTextures);
  lblSizeTextures.Caption := 'Size textures, reserved bytes: ' + IntToStr(BSTextureManager.TexturesSize);
end;

end.
