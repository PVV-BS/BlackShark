unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.ComCtrls, Vcl.ExtCtrls

  , bs.viewport
  , bs.gl.context
  , bs.test
  , bs.events
  ;

type
  TMainForm = class(TForm)
    Log: TListView;
    ImageList: TImageList;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    ViewPort: TBlackSharkViewPort;
    TestCommandLine: string;
    CurrentTest: TBSTest;
    ObsrvResizeRequest: IBResizeWindowEventObserver;
    ObsrvRepaintRequest: IBEmptyEventObserver;
    ObsrvMouseDownRequest: IBMouseEventObserver;
    procedure AfterCreateContextEvent (Sender: TBlackSharkContext);
    procedure RunTests;
    procedure RunTest(AClassTest: TBSTestClass);
    procedure OnResizeRequest(const AData: BResizeEventData);
    procedure OnRepaintRequest(const AData: BEmpty);
    procedure OnMouseDownRequest(const AData: BMouseData);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
    bs.config
  ;

{$R *.dfm}

procedure TMainForm.AfterCreateContextEvent(Sender: TBlackSharkContext);
begin
  Timer.Enabled := true;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ObsrvResizeRequest := nil;
  ObsrvRepaintRequest := nil;
  ObsrvMouseDownRequest := nil;
  FreeAndNil(CurrentTest);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TestCommandLine := ParamStr(1);
  { !!! not uses multisampling when tests, because need accuracy }
  BSConfig.MultiSampling := false;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ViewPort := TBlackSharkViewPort.Create(Self);
  ViewPort.OnAfterCreateContext := AfterCreateContextEvent;
  ViewPort.Align := TAlign.alClient;
end;

procedure TMainForm.OnMouseDownRequest(const AData: BMouseData);
begin
  if TBSMouseButton.mbBsLeft in AData.Button then
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbLeft, AData.ShiftState)
  else
  if TBSMouseButton.mbBsRight in AData.Button then
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbRight, AData.ShiftState)
  else
    ViewPort.TestMouseDown(AData.X, AData.Y, TMouseButton.mbMiddle, AData.ShiftState);
end;

procedure TMainForm.OnRepaintRequest(const AData: BEmpty);
begin
  ViewPort.Repaint;
end;

procedure TMainForm.OnResizeRequest(const AData: BResizeEventData);
begin
  ViewPort.TestResize(AData.NewWidth, AData.NewHeight);
end;

procedure TMainForm.RunTest(AClassTest: TBSTestClass);
var
  //t: Cardinal;
  result: boolean;
  item: TListItem;
begin
  ObsrvResizeRequest := nil;
  ObsrvRepaintRequest := nil;
  ObsrvMouseDownRequest := nil;
  FreeAndNil(CurrentTest);
  CurrentTest := AClassTest.Create(ViewPort.Renderer);
  ObsrvResizeRequest := CurrentTest.EventResizeRequest.CreateObserver(OnResizeRequest);
  ObsrvRepaintRequest := CurrentTest.EventRepaintRequest.CreateObserver(OnRepaintRequest);
  ObsrvMouseDownRequest := CurrentTest.EventMuseDownRequest.CreateObserver(OnMouseDownRequest);
  //t := GetTickCount;
  result := CurrentTest.Run;
  //test.Free;
  if result then
  begin
    item := log.Items.Add;
    item.Caption := 'The test "' + AClassTest.TestName + '" has been executed successfully...';
    item.Data := TObject(AClassTest);
    item.ImageIndex := 0;
  end else
  begin
    item := log.Items.Add;
    item.Caption := 'The test "' + AClassTest.TestName + '" has been failed...';
    item.Data := TObject(AClassTest);
    item.ImageIndex := 2;
  end;
end;

procedure TMainForm.RunTests;
var
  i: int32;
  ClassTest: TBSTestClass;
begin
  if TestCommandLine.IsEmpty then
  begin
    for i := 0 to TestsCount - 1 do
    begin
      ClassTest := GetClassTest(i);
      RunTest(ClassTest);
    end;
  end else
  begin
    for i := 0 to TestsCount - 1 do
    begin
      ClassTest := GetClassTest(i);
      if ClassTest.ClassName = TestCommandLine then
      begin
        RunTest(ClassTest);
        break;
      end;
    end;
  end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := false;
  RunTests;
end;

end.
