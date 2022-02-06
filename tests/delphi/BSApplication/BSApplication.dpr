program BSApplication;

{$R *.res}

uses
  BSApplicationExample in '..\..\bsApplication\BSApplicationExample.pas',
  bs.test.switcher in '..\..\bs.test.switcher.pas';

var
  Application: TBSApplicationExample;
begin
  Application := TBSApplicationExample.Create;
  Application.Run;
  Application.Free;
end.
