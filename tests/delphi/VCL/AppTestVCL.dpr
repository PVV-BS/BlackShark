program AppTestVCL;

{$DEFINE DEBUG_ST}

uses
  Vcl.Forms,
  TestVCL in 'TestVCL.pas' {frmMain},
  bs.test.switcher in '..\..\bs.test.switcher.pas',
  uSecondContext in 'uSecondContext.pas' {FrmSecondContext}
  ;

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TFrmSecondContext, FrmSecondContext);
  Application.Run;
end.
