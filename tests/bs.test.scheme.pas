
{$I BlackSharkCfg.inc}

unit bs.test.scheme;

interface

uses
    bs.test
  , bs.basetypes
  , bs.scene
  , bs.renderer
  , bs.gui.scheme.controller
  , bs.gui.scheme.view
  ;

type

  { TBSTestSimple }

  TBSTestScheme = class(TBSTest)
  private
    Scheme: TSchemeView;
    procedure CreateScheme;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
  {$ifndef FPC}
    System.UITypes,
  {$endif}
    bs.gui.scheme.model
  , bs.graphics
  ;

{ TBSTestScheme }

constructor TBSTestScheme.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Scheme := TSchemeView.Create(ARenderer);
  Scheme.Resize(500, 500);
  Scheme.Position := vec2(20, 20);
  Scheme.DrawGrid := true;
end;

procedure TBSTestScheme.CreateScheme;
var
  proc1: TSchemeProcessor;
  proc2: TSchemeProcessor;
  proc3: TSchemeProcessor;
  reg: TSchemeRegion;
  block1: TSchemeBlock;
  block2: TSchemeBlock;
  block_point1: TSchemeBlockLinkInput;
  block_point3: TSchemeBlockLinkOutput;
  block_point4: TSchemeBlockLinkOutput;
  ProcessorInBlock: TSchemeProcessor;

  function CreateBlock(const CapProc, Caption: string; const BlockPos: TVec2i): TSchemeBlock;
  begin
  Result := TSchemeBlock.Create(reg);
  Result.Caption := Caption;
  Result.Position := BlockPos;

  block_point1 := TSchemeBlockLinkInput.Create(Result);
  block_point1.Caption := 'Input to the block';
  block_point1.Resize(100, block_point1.Height);
  block_point1.Position := vec2(130.0, 60);

  ProcessorInBlock := TSchemeProcessor.Create(Result);
  ProcessorInBlock.Caption := CapProc;
  ProcessorInBlock.Position := vec2(block_point1.Position.x, block_point1.Position.y + block_point1.Height + 30);

  block_point1.Position := vec2(110.0, 60);

  block_point1.AddOutput(0, ProcessorInBlock);

  block_point3 := TSchemeBlockLinkOutput.Create(Result);
  block_point3.Caption := 'Output 1 from the block';
  block_point3.Position := vec2(200 - 180,
    ProcessorInBlock.Position.y + ProcessorInBlock.Height + 30);

  block_point4 := TSchemeBlockLinkOutput.Create(Result);
  block_point4.Caption := 'Output 2 from the block';

  block_point4.Position := vec2(200 + 10,
    ProcessorInBlock.Position.y + ProcessorInBlock.Height + 30);

  ProcessorInBlock.AddOutput(0, block_point3);
  ProcessorInBlock.AddOutput(1, block_point4);
  end;

const
  EOL = #$000d + #$000a;

begin
  reg := TSchemeRegion.Create(Scheme.Model);
  reg.Caption := 'a group of the scheme items' + EOL +
    '(double-click on block to come in) ' + EOL +
    '(double-click on empty field to come out)';

  reg.Position := vec2(20, 20);
  reg.Resize(round(Scheme.ScrollBox.Width - 150), round(Scheme.ScrollBox.Height - 150));

  proc1 := TSchemeProcessor.Create(reg);
  proc1.Caption := 'Input processor';
  proc1.Position := vec2(100, 80);

  proc2 := TSchemeProcessor.Create(reg);
  proc2.Caption := 'One more processor';
  proc2.Position := vec2(100, proc1.Position.y + proc1.Height + 30);//proc1.Position.x

  proc1.AddOutput(0, proc2);

  block1 := CreateBlock('Processor 4', 'Block 1', proc2.Position + vec2(0, proc2.Height + 30));

  proc2.AddOutput(0, block_point1);

  proc3 := TSchemeProcessor.Create(reg);
  proc3.Caption := 'Sender 1';
  proc3.Position := vec2(block1.Left, block1.Top + block1.Height + 30);

  block_point3.AddOutput(0, proc3);

  block2 := CreateBlock('Processor 5', 'Block 2', proc2.Position + vec2(proc2.Width + 30, -10));

  proc2.AddOutput(1, block_point1);

  Scheme.ViewedBlock := Scheme.Model;

  { now we have visualized an upper level, try to change a view of some shapes;
    that is not right, because it need to do through RTTI; however, let's do it
    for testing }

  assert(proc1.View <> nil, 'The view is not created!');
  assert(proc3.View <> nil, 'The view is not created!');

  TProcessorVisual(proc1.View).Color1 := TGuiColors.Red;
  TProcessorVisual(proc1.View).Color2 := TGuiColors.Yellow;

  TProcessorVisual(proc3.View).Color1 := TGuiColors.Green;
  TProcessorVisual(proc3.View).Color2 := TGuiColors.Olive;

  TBlockVisual(block2.View).BorderWidth := 1;
  TBlockVisual(block2.View).ColorBorder := TGuiColors.White;
  TBlockVisual(block2.View).Color1 := TGuiColors.Red;
  //TBlockVisual(block2.View).Color2 := TColors.Blue;

end;

destructor TBSTestScheme.Destroy;
begin
  Scheme.Free;
  inherited;
end;

function TBSTestScheme.Run: boolean;
begin
  Scheme.Clear;
  Scheme.Scale := 1.3;
  CreateScheme;
  //Scheme.SaveAs('d:\test_scheme.bsh');
  //Scheme.FileScheme := 'd:\test_scheme.bsh';
  Result := true;
end;

class function TBSTestScheme.TestName: string;
begin
  Result := 'Test of scheme viewer';
end;

end.
