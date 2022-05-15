unit BSApplicationExample;

{$I BlackSharkCfg.inc}

interface

uses
    bs.test
  , bs.test.switcher
  , bs.window
  , bs.events
  , bs.canvas
  ;

type

  { TBSApplicationExample }

  TBSApplicationExample = class(TBlackSharkApplication)
  private
    TestScene: TBSTest;
    CommandLineParam: string;
    FCanvas: TBCanvas;
    FpsOut: TCanvasText;
  protected
    { Important: initialize graphics objects only here or after it event }
    procedure OnCreateGlContext(AWindow: BSWindow); override;
    procedure OnRemoveWindow(AWindow: BSWindow); override;
    procedure DoUpdateFps; override;
    procedure OnGLContextLost; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
    SysUtils
  , bs.config
  , bs.log
  , bs.basetypes
  , bs.align
  ;

procedure BSApplicationExampleRun;
{$ifndef ANDROID}
var
  app: TBSApplicationExample;
{$endif}
begin
  if not Assigned(Application) then
  begin
    {$ifndef ANDROID}app := {$endif}TBSApplicationExample.Create;
    {$ifndef ANDROID}
    app.Run;
    app.Free;
    {$endif}
  end;
end;

{ TBSApplicationExample }

constructor TBSApplicationExample.Create;
begin
  inherited;
  CommandLineParam := ParamStr(1);
  if CommandLineParam = '' then
    CommandLineParam := 'TBSTestTable';//TBSTestWindows TBSTestSimple TBSTestCollada
end;

destructor TBSApplicationExample.Destroy;
begin
  inherited;
end;

procedure TBSApplicationExample.OnCreateGlContext(AWindow: BSWindow);
var
  i: int32;
  ClassTest: TBSTestClass;
begin
  inherited;
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBSApplicationExample.OnCreateGlContext', 'CommandLineParam = ' + CommandLineParam + ' tests count: ' + IntToStr(TestsCount));
  {$endif}
  if (AWindow = MainWindow) and not Assigned(TestScene) then
  begin
    for i := 0 to TestsCount - 1 do
    begin
      ClassTest := GetClassTest(i);
      if CommandLineParam = ClassTest.ClassName then
      begin
        TestScene := ClassTest.Create(AWindow.Renderer);
        TestScene.Run;
        {$ifdef DEBUG_BS}
        BSWriteMsg('TBSApplicationExample.OnCreateGlContext', 'the test was run');
        {$endif}
        break;
      end;
    end;
    FCanvas := TBCanvas.Create(AWindow.Renderer, nil);
    FCanvas.Font.Size := 10;
    FpsOut := TCanvasText.Create(FCanvas, nil);
    FpsOut.Text := 'FPS: 0';
    FpsOut.Position2d := vec2(AWindow.Width - FpsOut.Width - 20.0, 5.0);
    FpsOut.Anchors[TAnchor.aLeft] := false;
    FpsOut.Anchors[TAnchor.aRight] := true;
  end;
end;

procedure TBSApplicationExample.OnRemoveWindow(AWindow: BSWindow);
begin
  if Assigned(TestScene) and (AWindow.Renderer = TestScene.Renderer) then
  begin
    FreeAndNil(FpsOut);
    FreeAndNil(FCanvas);
    FreeAndNil(TestScene);
  end;
  inherited;
end;

procedure TBSApplicationExample.DoUpdateFps;
begin
  inherited;
  if Assigned(FpsOut) then
  begin
    FpsOut.Text := 'FPS: ' + IntToStr(MainWindow.Renderer.FPS);
  end;
end;

procedure TBSApplicationExample.OnGLContextLost;
begin
  inherited OnGLContextLost;
end;

initialization
  ApplicationRun := @BSApplicationExampleRun;


end.
