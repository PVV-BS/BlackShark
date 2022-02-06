program TestFM;

uses
  System.StartUpCopy,
  FMX.Types,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  bs.test.switcher in '..\..\bs.test.switcher.pas',
  bs.viewport in '..\..\..\core\bs.viewport.pas';

{$R *.res}

begin
  {$ifdef MSWINDOWS}
  ReportMemoryLeaksOnShutdown := true;
  {$endif}
  {FMX.Types.GlobalUseDirect2D := False;
  FMX.Types.GlobalUseGDIPlusClearType := False;
  FMX.Types.GlobalUseGPUCanvas := False;  }

  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
