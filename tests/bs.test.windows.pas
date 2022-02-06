unit bs.test.windows;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.test
  , bs.collections
  , bs.basetypes
  , bs.renderer
  , bs.thread
  , bs.window
  , bs.events
  , bs.canvas
  , bs.instancing
  , bs.animation
  , bs.gui.scrollbox
  , bs.gui.buttons
  ;


type

  TWindowScrollable = class(BSWindow)
  private
    const
      COUNT_INSTANCES = 200;
    type
      TPrimitiveConstructor = function: TCanvasObject of object;
      TParticle = record
        Velocity: single;
        Direction: TVec2f;
      end;
  private
    FInstances: TBlackSharkInstancing2d;
    FParticles: TListVec<TParticle>;
    FScrollBox: TBScrollBox;
    FPrimitiveConstructors: TListVec<TPrimitiveConstructor>;
    AniLaw: IBAnimationLinearFloat;
    AniLawObsr: IBAnimationLinearFloatObsrv;
    LastTime: TTimeCounter;
    function CreateCircle: TCanvasObject;
    function CreateSquare: TCanvasObject;
    function CreateTriangle: TCanvasObject;
    function CreateFreeShape: TCanvasObject;
    procedure OnUpdateValue(const Value: BSFloat);
  protected
    procedure OnCreateGlContext; override;
  public
    //constructor Create;
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure Resize(AWidth, AHeight: int32); override;
    procedure Show; override;
    property ScrollBox: TBScrollBox read FScrollBox;
  end;

  TWindowFullScreen = class(TWindowScrollable)
  private
    CloseButton: TBButton;
    ButtonClickObsrv: IBMouseEventObserver;
    procedure OnButtonCloseClick(const AData: BMouseData);
  protected
    procedure OnCreateGlContext; override;
  public
    destructor Destroy; override;
    procedure Show; override;
  end;

  TBSTestWindows = class;

  TWindowEventObservers = TListVec<IWindowEventObserver>;
  TWindowWrapper = class
  private
    FWindowEventObservers: TWindowEventObservers;
    FWindow: BSWindow;
    FOwner: TBSTestWindows;
    FIconRectangle: TRectangle;
  public
    constructor Create(AWindow: BSWindow; AOwner: TBSTestWindows);
    destructor Destroy; override;

    property WindowEventObservers: TWindowEventObservers read FWindowEventObservers;
    property IconRectangle: TRectangle read FIconRectangle write FIconRectangle;
  end;

  TBSTestWindows = class(TBSTest)
  private
    const
      ICON_WIN_SIZE = 30.0;
  private
    Button: TBButton;
    ButtonClickObsrv: IBMouseEventObserver;
    ButtonHideShow: TBButton;
    ButtonHideShowClickObsrv: IBMouseEventObserver;
    ButtonHideShowModal: TBButton;
    ButtonHideShowModalClickObsrv: IBMouseEventObserver;
    ButtonCreateFullScreenW: TBButton;
    ButtonCreateFullScreenWObsrv: IBMouseEventObserver;
    OnUpdateActiveWindowObsrv: IBEmptyEventObserver;
    IconClickObsrvs: TListVec<IBMouseEventObserver>;
    WindowFullScreen: TWindowFullScreen;
    Windows: TListVec<TRectangle>;
    IconSelection: TRectangle;
    OnIconClickNow: boolean;
    procedure OnButtonClick(const AData: BMouseData);
    procedure OnButtonHideShowClick(const AData: BMouseData);
    procedure OnButtonHideShowModalClick(const AData: BMouseData);
    procedure OnButtonCreateFullScreenClick(const AData: BMouseData);
    procedure OnIconClick(const AData: BMouseData);
    procedure OnUpdateActiveWindow(const AData: BEmpty);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    procedure OnCloseWindow(const AData: BWindowEventData);
    procedure OnDestroyWindow(const AData: BWindowEventData);
  end;

implementation

uses
    bs.align
  , bs.scene
  ;

{ TBSTestWindows }

constructor TBSTestWindows.Create(ARenderer: TBlackSharkRenderer);
var
  wrapperMainWindow: TWindowWrapper;
begin
  inherited;
  Assert(Application <> nil, 'For this test need to create pure Black Shark application (see example "BSApplication")');

  wrapperMainWindow := TWindowWrapper.Create(Application.MainWindow, Self);
  Application.MainWindow.Owner := wrapperMainWindow;
  Application.MainWindow.Renderer.Frustum.OrtogonalProjection := true;

  Button := TBButton.Create(ARenderer);
  Button.Caption := 'Create scrollable window';
  Button.Width := Button.Text.Width + 220;
  Button.Canvas.Font.Size := 10;
  //Button.Position2d := vec2(200, 280);
  //Button.Position2d := vec2(100.0, 100.0);
  Button.Position2d := vec2((ARenderer.WindowWidth - Button.Width) * 0.5 - 30.0, (ARenderer.WindowHeight - Button.Height) * 0.5 - (Button.Height+10)*3);
  ButtonClickObsrv := Button.OnClickEvent.CreateObserver(OnButtonClick);

  ButtonHideShow := TBButton.Create(Button.Canvas);
  ButtonHideShow.Caption := 'Hide/Show selected window';
  ButtonHideShow.Width := Button.Width;
  ButtonHideShow.Position2d := vec2(Button.Position2d.left, Button.Position2d.y + Button.Height + 10);
  ButtonHideShowClickObsrv := ButtonHideShow.OnClickEvent.CreateObserver(OnButtonHideShowClick);

  ButtonHideShowModal := TBButton.Create(Button.Canvas);
  ButtonHideShowModal.Caption := 'Hide/ShowModal selected window';
  ButtonHideShowModal.Width := Button.Width;
  ButtonHideShowModal.Position2d := vec2(Button.Position2d.left, ButtonHideShow.Position2d.y + ButtonHideShow.Height + 10);
  ButtonHideShowModalClickObsrv := ButtonHideShowModal.OnClickEvent.CreateObserver(OnButtonHideShowModalClick);

  ButtonCreateFullScreenW := TBButton.Create(Button.Canvas);
  ButtonCreateFullScreenW.Caption := 'Create/Show on full screen window';
  ButtonCreateFullScreenW.Width := Button.Width;
  ButtonCreateFullScreenW.Position2d := vec2(ButtonHideShowModal.Position2d.left, ButtonHideShowModal.Position2d.y + ButtonHideShowModal.Height + 10);
  ButtonCreateFullScreenWObsrv := ButtonCreateFullScreenW.OnClickEvent.CreateObserver(OnButtonCreateFullScreenClick);

  Windows := TListVec<TRectangle>.Create;

  IconSelection := TRectangle.Create(Button.Canvas, nil);
  IconSelection.Size := vec2(ICON_WIN_SIZE + 4.0, ICON_WIN_SIZE + 4.0);
  IconSelection.Fill := false;
  IconSelection.WidthLine := 1;
  IconSelection.Color := BS_CL_RED;
  IconSelection.Build;
  IconSelection.Data.Hidden := true;

  IconClickObsrvs := TListVec<IBMouseEventObserver>.Create;

  OnUpdateActiveWindowObsrv := Application.EventOnUdateActiveWindow.CreateObserver(OnUpdateActiveWindow);
end;

destructor TBSTestWindows.Destroy;
begin
  IconClickObsrvs.Free;
  Windows.Free;
  ButtonHideShow.Free;
  ButtonHideShowModal.Free;
  ButtonCreateFullScreenW.Free;
  Button.Free;
  inherited;
end;

procedure TBSTestWindows.OnButtonClick(const AData: BMouseData);
var
  window: TWindowScrollable;
  wrapper: TWindowWrapper;
  r: TRectangle;
  t: TCanvasText;
begin

  window := TWindowScrollable(Application.CreateWindow(TWindowScrollable, nil, self, 400, 400, 300, 300));
  wrapper := TWindowWrapper.Create(window, Self);
  window.Owner := wrapper;

  r := TRectangle.Create(Button.Canvas, nil);
  r.Size := vec2(ICON_WIN_SIZE, ICON_WIN_SIZE);
  r.Fill := true;
  r.Build;
  r.Position2d := vec2(Button.Position2d.x + Button.Width + 30.0, Windows.Count * (r.Size.y + 10.0) + 30.0);
  r.Data.TagPtr := window;
  r.Color := BS_CL_BLUE;

  wrapper.IconRectangle := r;

  t := TCanvasText.Create(Button.Canvas, r);
  t.Text := IntToStr(Windows.Count);
  t.ToParentCenter;

  IconClickObsrvs.Add(r.Data.EventMouseDown.CreateObserver(OnIconClick));
  Windows.Add(r);
  IconSelection.Data.Hidden := false;
  IconSelection.Position2d := r.Position2d - 2.0;
  IconSelection.Data.TagPtr := r;

  window.Show;
end;

procedure TBSTestWindows.OnButtonCreateFullScreenClick(const AData: BMouseData);
var
  wrapper: TWindowWrapper;
begin
  if not Assigned(WindowFullScreen) then
  begin
    WindowFullScreen := TWindowFullScreen(Application.CreateWindow(TWindowFullScreen, nil, self, 400, 400, 300, 300));
    wrapper := TWindowWrapper.Create(WindowFullScreen, Self);
    WindowFullScreen.Owner := wrapper;
    WindowFullScreen.FullScreen := true;
  end;
  WindowFullScreen.Show;
end;

procedure TBSTestWindows.OnButtonHideShowClick(const AData: BMouseData);
var
  window: TWindowScrollable;
begin
  if Assigned(IconSelection.Data.TagPtr) then
  begin
    window := TWindowScrollable(TRectangle(IconSelection.Data.TagPtr).Data.TagPtr);
    if window.IsVisible then
      window.Close
    else
      window.Show;
  end;
end;

procedure TBSTestWindows.OnButtonHideShowModalClick(const AData: BMouseData);
var
  window: TWindowScrollable;
begin
  if Assigned(IconSelection.Data.TagPtr) then
  begin
    window := TWindowScrollable(TRectangle(IconSelection.Data.TagPtr).Data.TagPtr);
    if window.IsVisible then
      window.Close
    else
      window.ShowModal;
  end;
end;

procedure TBSTestWindows.OnCloseWindow(const AData: BWindowEventData);
begin
  //TWindowWrapper(AData.Sender.Owner).Free;
end;

procedure TBSTestWindows.OnDestroyWindow(const AData: BWindowEventData);
begin

end;

procedure TBSTestWindows.OnIconClick(const AData: BMouseData);
var
  r: TRectangle;
  window: TWindowScrollable;
begin
  r := TRectangle(PRendererGraphicInstance(AData.BaseHeader.Instance).Instance.Owner.Owner);
  IconSelection.Data.TagPtr := r;
  IconSelection.Position2d := r.Position2d - 2.0;
  window := TWindowScrollable(r.Data.TagPtr);
  OnIconClickNow := true;
  try
    if window.IsVisible then
      window.IsActive := true;
  finally
    OnIconClickNow := false;
  end;
end;

procedure TBSTestWindows.OnUpdateActiveWindow(const AData: BEmpty);
var
  r: TRectangle;
begin
  if OnIconClickNow or (AData.Instance = Application.MainWindow) or (AData.Instance = WindowFullScreen) then
    exit;
  r := TWindowWrapper(BSWindow(AData.Instance).Owner).IconRectangle;
  IconSelection.Data.TagPtr := r;
  IconSelection.Position2d := r.Position2d - 2.0;
end;

function TBSTestWindows.Run: boolean;
begin
  Result := true;
end;

class function TBSTestWindows.TestName: string;
begin
  Result := 'Test of Black Shark window system';
end;

{ TWindowScrollable }

var
  IndexPrimitiveConstructor: int32 = 0;


procedure TWindowScrollable.AfterConstruction;
begin
  inherited;
  FPrimitiveConstructors := TListVec<TPrimitiveConstructor>.Create;
  FPrimitiveConstructors.Items[0] := CreateCircle;
  FPrimitiveConstructors.Items[1] := CreateSquare;
  FPrimitiveConstructors.Items[2] := CreateTriangle;
  FPrimitiveConstructors.Items[3] := CreateFreeShape;
  FParticles := TListVec<TParticle>.Create;
  AniLaw := CreateAniFloatLinear(GUIThread);
  AniLawObsr := AniLaw.CreateObserver(GUIThread, OnUpdateValue);
  AniLaw.Loop := true;
  AniLaw.Duration := 10000;
  AniLaw.StartValue := 0.0;
  AniLaw.StopValue := 1.0;
end;

function TWindowScrollable.CreateCircle: TCanvasObject;
var
  circle: TCircle;
begin
  circle := TCircle.Create(FScrollBox.Canvas, FScrollBox.ClipObject);
  circle.Fill := true;
  circle.Radius := 30;
  circle.Build;
  Result := circle;
end;

function TWindowScrollable.CreateFreeShape: TCanvasObject;
var
  shape: TFreeShape;
begin
  shape := TFreeShape.Create(FScrollBox.Canvas, FScrollBox.ClipObject);
  shape.BeginContour;
  shape.AddPoint(vec2(00.0, 69.0));
  shape.AddPoint(vec2(15.0, 60.0));
  shape.AddPoint(vec2(14.0, 52.0));
  shape.AddPoint(vec2(19.0, 44.0));
  shape.AddPoint(vec2(27.0, 35.0));
  shape.AddPoint(vec2(43.0, 26.0));
  shape.AddPoint(vec2(57.0, 12.0));
  shape.AddPoint(vec2(60.0, 27.0));
  shape.AddPoint(vec2(70.0, 35.0));
  shape.AddPoint(vec2(76.0, 44.0));
  shape.AddPoint(vec2(77.0, 45.0));
  shape.AddPoint(vec2(81.0, 48.0));
  shape.AddPoint(vec2(81.0, 52.0));
  shape.AddPoint(vec2(82.0, 58.0));
  shape.AddPoint(vec2(96.0, 67.0));
  shape.AddPoint(vec2(79.0, 68.0));
  shape.AddPoint(vec2(47.0, 78.0));
  shape.AddPoint(vec2(20.0, 68.0));
  shape.EndContour;
  shape.Build;
  Result := shape;
end;

function TWindowScrollable.CreateSquare: TCanvasObject;
var
  square: TRectangle;
begin
  square := TRectangle.Create(FScrollBox.Canvas, FScrollBox.ClipObject);
  square.Size := vec2(40.0, 40.0);
  square.Fill := false;
  square.WidthLine := 3;
  square.Build;
  Result := square;
end;

function TWindowScrollable.CreateTriangle: TCanvasObject;
var
  tri: TTriangle;
begin
  tri := TTriangle.Create(FScrollBox.Canvas, FScrollBox.ClipObject);
  tri.A := vec2(0.0, 60.0);
  tri.B := vec2(30.0, 0.0);
  tri.C := vec2(60.0, 60.0);
  tri.WidthLine := 3;
  tri.Fill := false;
  tri.Build;
  Result := tri;
end;

destructor TWindowScrollable.Destroy;
begin
  AniLaw.Stop;
  AniLaw := nil;
  FScrollBox.Free;
  FPrimitiveConstructors.Free;
  FParticles.Free;
  inherited;
end;

procedure TWindowScrollable.OnCreateGlContext;
var
  co: TCanvasObject;
  colorEnumerator: TColorEnumerator;
  i: Integer;
  p: TParticle;
  s: BSFloat;
  pos: TVec2f;
begin
  inherited;
  FScrollBox := TBScrollBox.Create(Renderer);
  FScrollBox.Focused := true;
  //FScrollBox.MainBody.Data.Opacity := 0.0;
  co := FPrimitiveConstructors.Items[IndexPrimitiveConstructor]();
  inc(IndexPrimitiveConstructor);
  IndexPrimitiveConstructor := IndexPrimitiveConstructor mod FPrimitiveConstructors.Count;
  FInstances := TBlackSharkInstancing2d.Create(Renderer, co);
  FInstances.CountInstance := COUNT_INSTANCES;
  FParticles.Count := FInstances.CountInstance;

  colorEnumerator := TColorEnumerator.Create([]);
  for i := 0 to FInstances.CountInstance - 1 do
  begin
    p.Direction := VecNormalize(vec2((Random(1000)/1000 - 0.5)/0.5, (Random(1000)/1000 - 0.5)/0.5));
    p.Velocity := 0;
    while p.Velocity = 0 do
      p.Velocity := Random(6);
    FParticles.Items[i] := p;
    pos.x := Random(round(Renderer.WindowWidth-co.Width));
    pos.y := Random(round(Renderer.WindowHeight-co.Height));
    FInstances.Position2d[i] := pos;
    FInstances.Angle[i] := vec3(0.0, 0.0, random(360));
    s := random(100);
    if s < 20.0 then
      s := 20.0;
    FInstances.Scale[i] := s/100;
    FInstances.Color[i] := colorEnumerator.GetNextColor;
  end;
  colorEnumerator.Free;
  //FScrollBox.Resize(ClientRect.Width, ClientRect.Height);
end;

procedure TWindowScrollable.OnUpdateValue(const Value: BSFloat);
var
  i: int32;
  pos: TVec2f;
  p: TParticle;
begin
  if LastTime.Counter - TBTimer.CurrentTime.Counter < 16 then
    exit;
  LastTime := TBTimer.CurrentTime;
  for i := 0 to FParticles.Count - 1 do
  begin
    pos := FInstances.Position2d[i];
    p := FParticles.Items[i];
    pos := vec2(pos.x + (p.Velocity * p.Direction.x), pos.y + (p.Velocity * p.Direction.y));
    if (pos.x > FScrollBox.Width-TCanvasObject(FInstances.Prototype.Owner).Width) or
      (pos.y > FScrollBox.Height - TCanvasObject(FInstances.Prototype.Owner).Height) or
      (pos.x < 0) or (pos.y < 0) then
    begin
      if (pos.x > FScrollBox.Width-TCanvasObject(FInstances.Prototype.Owner).Width) or (pos.x < 0) then
      begin
        p.Direction.x := -p.Direction.x;
        if pos.x < 0 then
          pos.x := 0.0
        else
          pos.x := Renderer.WindowWidth - TCanvasObject(FInstances.Prototype.Owner).Width;
      end else
      begin
        p.Direction.y := -p.Direction.y;
        if pos.y < 0 then
          pos.y := 0.0
        else
          pos.y := Renderer.WindowHeight - TCanvasObject(FInstances.Prototype.Owner).Height;
      end;
      FParticles.Items[i] := p;
    end;
    FInstances.Position2d[i] := pos;
  end;
end;

procedure TWindowScrollable.Resize(AWidth, AHeight: int32);
begin
  inherited;
  if Assigned(FScrollBox) then
    FScrollBox.Resize(ClientRect.Width, ClientRect.Height);
end;

procedure TWindowScrollable.Show;
begin
  inherited;
  FScrollBox.Resize(ClientRect.Width, ClientRect.Height);
  if not AniLaw.IsRun then
    AniLaw.Run;
end;

{ TWindowWrapper }

constructor TWindowWrapper.Create(AWindow: BSWindow; AOwner: TBSTestWindows);
begin
  FWindowEventObservers := TWindowEventObservers.Create;
  FWindow := AWindow;
  FOwner := AOwner;
  FWindowEventObservers.Add(FWindow.OnClose.CreateObserver(FOwner.OnCloseWindow));
  FWindowEventObservers.Add(FWindow.OnDestroy.CreateObserver(FOwner.OnDestroyWindow));
end;

destructor TWindowWrapper.Destroy;
begin
  FWindowEventObservers.Free;
  FWindow.Free;
  inherited;
end;

{ TWindowFullScreen }

destructor TWindowFullScreen.Destroy;
begin
  CloseButton.Free;
  inherited;
end;

procedure TWindowFullScreen.OnButtonCloseClick(const AData: BMouseData);
begin
  Close;
end;

procedure TWindowFullScreen.OnCreateGlContext;
begin
  inherited;
  CloseButton := TBButton.Create(Renderer);
  CloseButton.Caption := 'Close';
  ScrollBox.DropControl(CloseButton, nil);
  //CloseButton.MainBody.ToParentCenter;
  ButtonClickObsrv := CloseButton.OnClickEvent.CreateObserver(OnButtonCloseClick);
end;

procedure TWindowFullScreen.Show;
begin
  inherited;
  CloseButton.MainBody.ToParentCenter;
end;

end.
