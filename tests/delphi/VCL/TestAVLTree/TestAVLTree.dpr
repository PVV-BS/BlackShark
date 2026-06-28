program TestAVLTree;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {AVLTreeViewer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAVLTreeViewer, AVLTreeViewer);
  Application.Run;
end.
