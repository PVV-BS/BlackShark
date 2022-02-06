unit uMain;

{$mode Delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,

  bs.basetypes,
  bs.viewport,
  bs.gl.context,
  bs.canvas;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    PanelScreen: TPanel;
    PnlTools: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    ViewPort: TBlackSharkViewPort;
    BCanvas: TBCanvas;
    procedure AfterCreateContextEvent (Sender: TBlackSharkContext);
  public

  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.lfm}

{ TFrmMain }

procedure TFrmMain.FormShow(Sender: TObject);
begin
  ViewPort := TBlackSharkViewPort.Create(PanelScreen);
  { set position right from PnlTools }
  ViewPort.Left := PnlTools.Left + 1;
  ViewPort.OnAfterCreateContext := AfterCreateContextEvent;
  ViewPort.Align := alClient;
end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  BCanvas.Free;
end;

procedure TFrmMain.AfterCreateContextEvent(Sender: TBlackSharkContext);
var
  txt: TCanvasText;
  arc: TArc;
begin
  BCanvas := TBCanvas.Create(ViewPort.Renderer, Self);
  { text example }
  txt := TCanvasText.Create(BCanvas, nil);
  txt.Text := 'Hello world!';
  txt.Position2d := vec2(70.0, 150.0);
  { arc example }
  arc := TArc.Create(BCanvas, nil);
  arc.Radius := 100;
  arc.Angle := 60;
  arc.Fill := true;
  arc.Color := BS_CL_ORANGE;
  arc.Build;
  arc.Position2d := vec2(250.0, 130.0);
end;

end.

