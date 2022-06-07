program BSApplication;

{$I BlackSharkCfg.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  { you can add units after this }
  bs.test.switcher,
  bs.window,
  BSApplicationExample;


{$R *.res}

begin
  ApplicationRun;
end.

