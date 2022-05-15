library blackshark;
  
{$mode delphi}
  
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, bs.config, bs.window.android,
  BSApplicationExample;
  
{$I bsAndroidNativeExports.inc}
  
begin
end.
