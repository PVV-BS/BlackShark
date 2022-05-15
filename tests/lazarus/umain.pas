unit uMain;

{$mode Delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,

  bs.basetypes,
  bs.viewport,
  bs.gl.context,
  bs.test
  ;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    cbAvailableTests: TComboBox;
    Label1: TLabel;
    PanelScreen: TPanel;
    PnlTools: TPanel;
    procedure cbAvailableTestsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    ViewPort: TBlackSharkViewPort;
    CurrentTest: TBSTest;
    CommandLineParam: string;
    procedure AfterCreateContextEvent(Sender: TObject);
    procedure RunTest(TestClass: TBSTestClass);
  public

  end;

var
  FrmMain: TFrmMain;

implementation

uses
    bs.config
  ;

{$R *.lfm}

{ TFrmMain }

procedure TFrmMain.FormShow(Sender: TObject);
begin
  bs.config.BSConfig.MaxFps := true;
  ViewPort := TBlackSharkViewPort.Create(PanelScreen);
  { set position right from PnlTools }
  ViewPort.Left := PnlTools.Left + 1;
  ViewPort.OnAfterCreateContext := AfterCreateContextEvent;
  ViewPort.Align := alClient;
  CommandLineParam := ParamStr(1);
end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(CurrentTest);
end;

procedure TFrmMain.cbAvailableTestsChange(Sender: TObject);
begin
  if cbAvailableTests.ItemIndex < 0 then
    exit;
  if Assigned(CurrentTest) then
    FreeAndNil(CurrentTest);
  RunTest(TBSTestClass(cbAvailableTests.Items.Objects[cbAvailableTests.ItemIndex]));
end;

procedure TFrmMain.AfterCreateContextEvent(Sender: TObject);
var
  i: int32;
  ClassTest: TBSTestClass;
begin
  //ViewPort.CurrentScene.SmoothSharkSSAA := cbSSAA.Checked;
  //ViewPort.CurrentScene.SmoothMSAA := cbMSAA.Checked;
  for i := 0 to TestsCount - 1 do
  begin
    ClassTest := GetClassTest(i);
    cbAvailableTests.Items.AddObject(ClassTest.TestName, Pointer(ClassTest));
  end;

  if TestsCount > 0 then
  begin
    if CommandLineParam <> '' then
      for i := 0 to cbAvailableTests.Items.Count - 1 do
      begin
        ClassTest := TBSTestClass(cbAvailableTests.Items.Objects[i]);
        if ClassTest.ClassName = CommandLineParam then
        begin
          cbAvailableTests.ItemIndex := i;
          cbAvailableTestsChange(Self);
          break;
        end;
      end;

    if (CurrentTest = nil) then
    begin
      if cbAvailableTests.Items.Count > 0 then
      begin
        cbAvailableTests.ItemIndex := cbAvailableTests.Items.Count - 1;
        cbAvailableTestsChange(Self);
      end;
    end;

  end;

end;

procedure TFrmMain.RunTest(TestClass: TBSTestClass);
begin
  CurrentTest := TestClass.Create(ViewPort.Renderer);
  CurrentTest.Run;
  Caption := 'Black Shark Graphics Engine: ' + CurrentTest.TestName;
end;

end.

