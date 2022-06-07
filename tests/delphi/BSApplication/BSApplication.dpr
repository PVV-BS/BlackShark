program BSApplication;

{$R *.res}

uses
  bs.window,
  BSApplicationExample in '..\..\bsApplication\BSApplicationExample.pas',
  bs.test.switcher in '..\..\bs.test.switcher.pas';

begin
  {$ifndef ANDROID}
  ApplicationRun;
  {$endif}
end.
