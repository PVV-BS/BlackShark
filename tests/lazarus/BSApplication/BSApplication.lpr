program BSApplication;

{$I BlackSharkCfg.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  { you can add units after this }
  bs.test.switcher,
  BSApplicationExample;


var
  Application: TBSApplicationExample;

{$R *.res}

begin
  Application := TBSApplicationExample.Create;
  Application.Run;
  Application.Free;
end.

