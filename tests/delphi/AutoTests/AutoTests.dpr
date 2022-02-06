program AutoTests;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {MainForm},
  bs.autotest.switcher in '..\..\bs.autotest.switcher.pas',
  bs.test.auto.edit in '..\..\bs.test.auto.edit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
