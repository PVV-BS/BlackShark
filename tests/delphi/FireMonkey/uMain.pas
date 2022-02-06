unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Ani, FMX.Controls.Presentation
  , bs.gl.context
  , bs.viewport
  , bs.test;

type
  TfrmMain = class(TForm)
    ScreenPanel: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    ViewPort: TBlackSharkViewPort;
    CurrentTest: TBSTest;
    CommandLineParam: string;
    procedure AfterCreateContextEvent (Sender: TBlackSharkContext);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.AfterCreateContextEvent(Sender: TBlackSharkContext);
var
  i: int32;
  ClassTest: TBSTestClass;
begin
  if TestsCount > 0 then
  begin

    for i := 0 to TestsCount - 1 do
    begin
      ClassTest := GetClassTest(i);
      if ClassTest.ClassName = CommandLineParam then
      begin
        CurrentTest := ClassTest.Create(ViewPort.Renderer);
        break;
      end;
    end;

    if (CurrentTest = nil) then
      CurrentTest := GetClassTest(TestsCount-1).Create(ViewPort.Renderer);

    if Assigned(CurrentTest) then
    begin
      CurrentTest.Run;
    end;

  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(CurrentTest);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CommandLineParam := ParamStr(1);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  ViewPort := TBlackSharkViewPort.Create(ScreenPanel);
  ViewPort.Align := TAlignLayout.Client;
  ViewPort.OnAfterCreateContext := AfterCreateContextEvent;
end;

end.
