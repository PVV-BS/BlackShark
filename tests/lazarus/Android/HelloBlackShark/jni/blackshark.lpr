library blackshark;
  
{$mode delphi}
  
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, bs.config, bs.window,
  {$ifdef ANDROID}
  bs.window.android,
  {$endif}
  BSApplicationExample;

{$ifdef ANDROID}
{$I bsAndroidNativeExports.inc}
{$endif}
  
begin
	ApplicationRun;
end.
