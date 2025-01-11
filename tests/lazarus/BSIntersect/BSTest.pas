program BSTest;

{$ifdef Linux}
  {$DEFINE UNIX}
  {$DEFINE UseCThreads}
{$endif}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, cmem,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainWin;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainW, MainW);
  Application.Run;
end.

