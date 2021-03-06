unit uSecondContext;

interface

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , bs.viewport
  , bs.gl.context
  , bs.test
  , bs.scene
  ;

type
  TFrmSecondContext = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FViewPort: TBlackSharkViewPort;
    FCurrentTest: TBSTest;
    FCurrentTestClass: TBSTestClass;
    FOwnTest: boolean;
    FCurrentScene: TBScene;
    procedure AfterCreateContextEvent (Sender: TObject);
    procedure SetCurrentTest(const Value: TBSTest);
    function GetCurrentTest: TBSTest;
    function GetCurrentTestClass: TBSTestClass;
    procedure SetCurrentTestClass(const Value: TBSTestClass);
    function GetCurrentScene: TBScene;

    procedure SetCurrentScene(const Value: TBScene);  public
    { Public declarations }
    property CurrentTestClass: TBSTestClass read GetCurrentTestClass write SetCurrentTestClass;
    property CurrentTest: TBSTest read GetCurrentTest write SetCurrentTest;
    property CurrentScene: TBScene read GetCurrentScene write SetCurrentScene;
    property ViewPort: TBlackSharkViewPort read FViewPort;
  end;

var
  FrmSecondContext: TFrmSecondContext;

implementation

uses
    bs.basetypes
  ;

{$R *.dfm}

procedure TFrmSecondContext.AfterCreateContextEvent(Sender: TObject);
begin
  if Assigned(FCurrentScene) then
  begin
    FViewPort.CurrentScene := FCurrentScene;
  end else
  if Assigned(ViewPort) and Assigned(ViewPort.Renderer) and Assigned(FCurrentTestClass) and not Assigned(FCurrentTest) then
  begin
    FOwnTest := true;
    FCurrentTest := FCurrentTestClass.Create(ViewPort.Renderer);
  end;
  //FViewPort.Renderer.Frustum.Angle := vec3(0.0, -30, 0.0);
end;

procedure TFrmSecondContext.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FOwnTest then
    FreeAndNil(FCurrentTest);
end;

procedure TFrmSecondContext.FormCreate(Sender: TObject);
begin
  FViewPort := TBlackSharkViewPort.Create(Self);
  FViewPort.OnAfterCreateContext := AfterCreateContextEvent;
  FViewPort.Align := alClient;
end;

procedure TFrmSecondContext.FormShow(Sender: TObject);
begin
  if Assigned(FCurrentScene) then
  begin
    FViewPort.CurrentScene := FCurrentScene;
  end;
end;

function TFrmSecondContext.GetCurrentScene: TBScene;
begin
  Result := FCurrentScene;
end;

function TFrmSecondContext.GetCurrentTest: TBSTest;
begin
  Result := FCurrentTest;
end;

function TFrmSecondContext.GetCurrentTestClass: TBSTestClass;
begin
  Result := FCurrentTestClass;
end;

procedure TFrmSecondContext.SetCurrentScene(const Value: TBScene);
begin
  FCurrentScene := Value;
  if Assigned(FViewPort) then
    FViewPort.CurrentScene := FCurrentScene;
end;

procedure TFrmSecondContext.SetCurrentTest(const Value: TBSTest);
begin
  if FOwnTest then
    FreeAndNil(FCurrentTest);
  FCurrentTest := Value;
  FOwnTest := false;
  if Assigned(ViewPort) and Assigned(ViewPort.Renderer) then
    FCurrentTest := Value.Create(ViewPort.Renderer);
end;

procedure TFrmSecondContext.SetCurrentTestClass(const Value: TBSTestClass);
begin
  if FOwnTest then
    FreeAndNil(FCurrentTest);
  FCurrentTestClass := Value;
  if Assigned(ViewPort) and Assigned(ViewPort.Renderer) and Assigned(Value) then
  begin
    FOwnTest := true;
    FCurrentTest := Value.Create(ViewPort.Renderer);
  end;
end;

end.
