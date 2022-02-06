unit BSApplicationExample;

{$I BlackSharkCfg.inc}

interface

uses
    bs.test
  , bs.window
  , bs.events
  , bs.canvas
  ;

type
  TBSApplicationExample = class(TBlackSharkApplication)
  private
    TestScene: TBSTest;
    CommandLineParam: string;
    FCanvas: TBCanvas;
    FpsOut: TCanvasText;
  protected
    procedure OnCreateGlContext(AWindow: BSWindow); override;
    procedure OnRemoveWindow(AWindow: BSWindow); override;
    procedure DoUpdateFps; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
    SysUtils
  , bs.config
  ;

procedure BSApplicationExampleRun;
var
  Application: TBSApplicationExample;
begin
  Application := TBSApplicationExample.Create;
  Application.Run;
  Application.Free;
end;

{ TBSApplicationExample }

constructor TBSApplicationExample.Create;
begin
  inherited;
  CommandLineParam := ParamStr(1);
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
  if AWindow = MainWindow then
  begin
    for i := 0 to TestsCount - 1 do
    begin
      ClassTest := GetClassTest(i);
      if CommandLineParam = ClassTest.ClassName then
      begin
        TestScene := ClassTest.Create(AWindow.Renderer);
        TestScene.Run;
        break;
      end;
    end;
    {FCanvas := TBCanvas.Create(AWindow.Renderer, nil);
    FCanvas.Font.Size := 8;
    FpsOut := TCanvasText.Create(FCanvas, nil);
    FpsOut.Text := 'FPS: 0';
    FpsOut.Position2d := vec2(AWindow.Width - FpsOut.Width - 20.0, 5.0);
    FpsOut.Anchors[TAnchor.aLeft] := false;
    FpsOut.Anchors[TAnchor.aRight] := true; }
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
    //FpsOut.Text := 'FPS: ' + IntToStr(MainWindow.Renderer.FPS);
  end;
end;

initialization
  ApplicationRun := @BSApplicationExampleRun;


end.
