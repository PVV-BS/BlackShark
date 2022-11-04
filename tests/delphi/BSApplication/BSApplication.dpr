program BSApplication;

{$R *.res}

uses
  bs.window,
  BSApplicationExample in '..\..\bsApplication\BSApplicationExample.pas',
  bs.test.switcher in '..\..\bs.test.switcher.pas';

begin
  ReportMemoryLeaksOnShutdown := true;
  {$ifndef ANDROID}
  ApplicationRun;
  {$endif}
end.
