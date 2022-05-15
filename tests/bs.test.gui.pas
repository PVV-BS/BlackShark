unit bs.test.gui;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.test
  , bs.basetypes
  , bs.events
  , bs.renderer
  , bs.scene
  , bs.graphics
  , bs.texture
  , bs.canvas
  , bs.font
  , bs.animation
  , bs.selectors
  , bs.mesh.loaders
  , bs.mesh.primitives
  , bs.scene.objects
  , bs.collections
  , bs.gui.base
  , bs.gui.scrollbox
  , bs.gui.chart
  , bs.gui.buttons
  , bs.gui.hint
  , bs.gui.grid
  , bs.gui.memo
  , bs.gui.forms
  , bs.gui.scrollbar
  , bs.gui.edit
  , bs.gui.table
  , bs.gui.combobox
  , bs.gui.checkbox
  , bs.gui.groupbox
  , bs.gui.column.presentor
  , bs.gui.colorbox
  , bs.gui.colordialog
  , bs.gui.trackbar
  , bs.gui.objectinspector
  ;

type

  TBSTestResample = class (TBSTest)
  private
    Pic: TBlackSharkBitMap;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestSimpleAnimation }

  TBSTestSimpleAnimation = class(TBSTest)
  private
    //AniLawScale: TAniValueLawsVec2f;
    Canvas: TBCanvas;
    Obj: TRectangle;
    //SrvTxt: TCanvasText;
    //UpCounter: uint32;
    //TimeStart: int64;
    //Duration: int64;
    //DeltaValue: BSFloat;
    //StartValue: BSFloat;
    ObsrvMouseEnter: IBMouseEventObserver;
    ObsrvMouseLeave: IBMouseEventObserver;
    Anim: IBAnimationLinearFloat;
    AniObserver: IBAnimationLinearFloatObsrv;
    procedure OnMouseEnter(const Data: BMouseData);
    procedure OnMouseLeave(const Data: BMouseData);
    procedure OnProcAni(const Value: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestAnimationByAnimator }

  TBSTestAnimationByAnimator = class(TBSTest)
  private
    AniLawScale: IBAnimationLinearFloat;
    AniObsrv: IBAnimationLinearFloatObsrv;
    ObsrvMouseEnter: IBMouseEventObserver;
    ObsrvMouseLeave: IBMouseEventObserver;
    Canvas: TBCanvas;
    Obj: TRectangle;
    procedure OnMouseEnter(const Data: BMouseData);
    procedure OnMouseLeave(const Data: BMouseData);
    procedure OnUpdateValueScale(const Data: BSFloat);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestAnimationFlame }

  TBSTestAnimationFlame = class(TBSTest)
  private
    AniEmpty: IBEmptyTask;
    AniObsrv: IBEmptyTaskObserver;
    Canvas: TBCanvas;
    Obj: TRectangleTextured;
    Current: int32;
    Texture: IBlackSharkTexture;
    procedure OnUpdateValue(const Data: byte);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestScrollBox }

  TBSTestScrollBox = class(TBSTest)
  private
    Canvas: TBCanvas;
    ScrollBox1: TBScrollBox;
    ScrollBox2: TBScrollBox;
    function CreateScrollBox(X, Y: int32; Scalable: boolean): TBScrollBox;
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestScrollBar = class(TBSTest)
  private
    ScrollBarVert: TBScrollBar;
    ScrollBarHor: TBScrollBar;
    Canvas: TBCanvas;
    LabelPosVert: TCanvasText;
    LabelPosHor: TCanvasText;
    Rectangle: TRectangle;
    ObsrvAfterRealign: TCanvasEventObserver;
    CaptionArea: TCanvasText;
    procedure OnChangeVert(ASender: TBScrollBar);
    procedure OnChangeHor(ASender: TBScrollBar);
    procedure OnAfterRealign(const BData: BData);
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestForm }

  TBSTestForm = class(TBSTest)
  private
    Form: TBForm;
    Form2: TBForm;
    ObsrvClickBtn: IBMouseEventObserver;
    ObsrvClickClose: IBMouseEventObserver;
    procedure OnMouseClickBtn({%H}const Data: BMouseData);
    procedure OnMouseClickCloseBtn({%H}const Data: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestHint }

  TBSTestHint = class(TBSTest)
  private
    Hint: TBlackSharkHint;
    Hint2: TBlackSharkHint;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestButton }

  TBSTestButton = class(TBSTest)
  private
    ObsrvScalClick: IBMouseUpEventObserver;
    Button: TBButton;
    ButtonScal: TBButton;
    ButtonEmo: TBButton;
    Buttons: array of TBButton;
    procedure OnClickScalButton(const AData: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestEdit }

  TBSTestEdit = class(TBSTest)
  private
    //Canvas: TBCanvas;
    Edit1: TBEdit;
    Edit2: TBEdit;
    Edit3: TBSpinEdit;
    Edit4: TBSpinEdit;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestMemo }

  TBSTestMemo = class(TBSTest)
  private
    Memo: TBlackSharkMemo;
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestGrid }

  TBSTestGrid = class(TBSTest)
  private
    Grid: TBGrid;
    Grid2: TBGrid;
    Grid3: TBGrid;
    Grid4: TBGrid;
    Data: TListVec<AnsiString>;
    ChangingPos: boolean;
    function CreateGrid(ClassPresentation: TGridDataPresentationClass;
      const Color: TColor4f; const Position, Size: TVec2f; SetColor: boolean): TBGrid;
    procedure DrawData(Grid: TBGrid);
    procedure OnChangePosGrid(Sender: TBScrolledWindowCustom; const Position: TPosition2d);
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;


  { TBSTestChart }

  TBSTestChart = class(TBSTest)
  private
    Chart: TBChartCurvesInt;
    Curve: TBChartCurvesInt.TDataContainerPairXY;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestFloatChart }

  TBSTestFloatChart = class(TBSTest)
  private
    Chart: TBChartCurvesFloat;
    Curve: TBChartCurvesFloat.TDataContainerPairXY;
    ObsrvResize: IBResizeWindowEventObserver;
    procedure OnResizeWindow({%H-}const Data: BResizeEventData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestDateChart }

  TBSTestDateChart = class(TBSTest)
  private
    Chart: TCurvesQuantityFloatInDate;
    Curve: TCurvesQuantityFloatInDate.TDataContainerPairXY;
    //procedure OnResizeWindow({%H-}Data: PEventBaseRec);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestBadDateChart }

  TBSTestBadDateChart = class(TBSTest)
  private
    Chart: TCurvesQuantityInDate;
    Curve: TCurvesQuantityInDate.TDataContainerPairXY;
    //procedure OnResizeWindow({%H-}Data: PEventBaseRec);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestChartCircular }

  TBSTestChartCircular = class(TBSTest)
  private
    Chart: TBChartCircularStr;
    ColorEnumerator: TColorEnumerator;
    ObsrvResize: IBResizeWindowEventObserver;
    procedure OnResizeWindow({%H-}const Data: BResizeEventData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestChartBar }

  TBSTestChartBar = class(TBSTest)
  private
    Chart: TBChartBarInt;
    Curve: TBChartBarInt.TDataContainerPairXY;
    ObsrvResize: IBResizeWindowEventObserver;
    procedure OnResizeWindow({%H-}const Data: BResizeEventData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestChartBarDate }

  TBSTestChartBarDate = class(TBSTest)
  private
    Chart: TBChartBarDateInt;
    Curve: TBChartBarDateInt.TDataContainerPairXY;
    //procedure OnResizeWindow({%H-}Data: PEventBaseRec);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestSelector }

  TBSTestSelector = class(TBSTest)
  private
    Selector: TBlackSharkSelectorInstances;
    SelectorsBB: TListVec<TBlackSharkSelectorBB>;
    Obj2d: TBCanvas;
    Obj3d: TTexturedVertexes;
    Canvas: TBCanvas;
    TextMin: TCanvasText;
    TextMax: TCanvasText;
    CurrentSelector: TBlackSharkSelectorBB;
    function OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
    procedure UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
    function GetSelector: TBlackSharkSelectorBB;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestRotor }

  TBSTestRotor = class(TBSTest)
  private
    Rotor: TBlackSharkRotor3D;
    Obj2d: TBCanvas;
    Obj3d: TTexturedVertexes;
    Canvas: TBCanvas;
    TextQuat: TCanvasText;
    ObsrDownOnFish: IBMouseEventObserver;
    ObsrDownOnScreen: IBMouseEventObserver;
    ObsrDownOnSnow: IBMouseEventObserver;
    ObsrMove: IBMouseEventObserver;
    procedure MouseDownOnFish({%H-}const Data: BMouseData);
    procedure MouseDownOnScreen({%H-}const Data: BMouseData);
    procedure MouseDownOnSnowflake({%H-}const Data: BMouseData);
    procedure MouseMove({%H-}const Data: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestObjectInspector }

  TBSTestObjectInspector = class(TBSTest)
  private
    Form: TBForm;
    Edit1: TBEdit;
    Edit2: TBSpinEdit;
    Inspector: TObjectInspector;
    OnFocusChangeObsrv: IBFocusEventObserver;
    Canvas: TBCanvas;
    EditSave: TBEdit;
    EditLoad: TBEdit;
    BtnSave: TBButton;
    BtnLoad: TBButton;
    ObsrvSave: IBMouseEventObserver;
    ObsrvLoad: IBMouseEventObserver;
    procedure OnFocusChanged(const Data: BFocusEventData);
    procedure OnSaveClick(const Data: BMouseData);
    procedure OnLoadClick(const Data: BMouseData);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestTable }

  TBSTestTable = class(TBSTest)
  private
    Table: TBTable;
    //Listbox: TBListbox;
    //Data1: TListVec<string>;
    CheckBoxData: TListVec<string>;
    LastIndex: int32;
    function GetNumberData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    function GetStringData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    function GetStringData2(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    function GetCheckBoxData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
    function CreateTable(Scalable: boolean; const Position: TVec2f; const Size: TVec2f; const Caption: string): TBTable;
    procedure OnChangeCheck(ACell: IColumnCellPresentor);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestCheckBox }

  TBSTestCheckBox = class(TBSTest)
  private
    CheckBox: TBCheckBox;
    GroupBox: TBGroupBox;
    MasterCheckbox: TBCheckBox;
    Checkboxes: array[0..5] of TBCheckBox;
    Canvas: TBCanvas;
    CountChecked: int32;
    procedure MasterClick(ASender: TObject);
    procedure SlaveClick(ASender: TObject);
    procedure CreateCheckboxes;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestComboBox }

  TBSTestComboBox = class(TBSTest)
  private
    ComboBox: TBComboBox;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestColorBox }

  TBSTestColorBox = class(TBSTest)
  private
    ColorBox: TBColorBox;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestColorDialog }

  TBSTestColorDialog = class(TBSTest)
  private
    ColorDialog: TBColorDialog;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestTrackBar }

  TBSTestTrackBar = class(TBSTest)
  private
    TrackBar: TBTrackBar;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    bs.config
  , bs.align
  , bs.shader
  , bs.math
  , bs.utils
  , bs.strings
  , bs.thread
  , bs.gl.es
  , bs.log
  ;

{ TBSTestChart }

constructor TBSTestChart.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  Chart := TBChartCurvesInt.Create(ARenderer);
  Chart.InterpolateSpline := isNone;
  Curve := Chart.CreateChart;
  Chart.BeginUpdate;
  Curve.AddPair(40, 88);
  Curve.AddPair(60, 100);
  Chart.EndUpdate;
  {Curve.AddPair(-75, -10);
  Curve.AddPair(-55, 0);
  Curve.AddPair(-30, 40);
  Curve.AddPair(0, 15);
  Curve.AddPair(10, 20);
  Curve.AddPair(30, 50);
  Curve.AddPair(100, 130);
  Curve.AddPair(200, 90); }

  //Curve.AddPair(70, 40);
end;

destructor TBSTestChart.Destroy;
begin
  Chart.Free;
  inherited Destroy;
end;

function TBSTestChart.Run: boolean;
begin
  Result := true;
  //Chart.Resize(600, 500);  //Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7
end;

class function TBSTestChart.TestName: string;
begin
  Result := 'Test Chart';
end;

{ TBSTestScrollBox }

constructor TBSTestScrollBox.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(ARenderer, Self);
  {with TRoundRect.Create(Canvas, nil) do
  begin
    Size := vec2(120, 120);
    Fill := true;
    Build;
    Position2d := vec2(500, 250);
    Data.Color := BS_CL_GREEN;
  end;   }

end;

destructor TBSTestScrollBox.Destroy;
begin
  ScrollBox1.Free;
  ScrollBox2.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestScrollBox.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  //ScrollBox1.Resize(Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7);
end;

function TBSTestScrollBox.CreateScrollBox(X, Y: int32; Scalable: boolean): TBScrollBox;
begin
  Result := TBScrollBox.Create(Renderer);
  Result.Position2d := vec2(X, Y);
  Result.UseSpaceTree := false;
  Result.Scalable := Scalable;
  //Result.ScrolledArea := vec2(int64(1010), int64(1010));
  Result.ClipObject.Data.DragResolve := true;
  Result.AutoResizeScrollingArea := true;

  Result.Resize(200*ToHiDpiScale, 200*ToHiDpiScale);
  with TCircle.Create(Result.Canvas, Result.OwnerInstances) do
  begin
    Radius := 150;
    Fill := true;
    Build;
    Position2d := vec2(300, 300);
    Data.Color := BS_CL_TEAL;
  end;

  with TRoundRect.Create(Result.Canvas, Result.OwnerInstances) do
  begin
    Size := vec2(100, 200);
    Fill := true;
    Build;
    Position2d := vec2(300, 500);
    Data.Color := BS_CL_PURPLE;
  end;

  with TCircle.Create(Result.Canvas, Result.OwnerInstances) do
  begin
    Radius := 40;
    Fill := true;
    Build;
    Position2d := vec2(100, 100);
    Data.Color := BS_CL_RED;
  end;

  with TCanvasText.Create(Result.Canvas, Result.OwnerInstances) do
  begin
    Text := 'A modal level: ' + IntToStr(Result.MainBody.Data.ModalLevel);
    Position2d := vec2(50, 50);
  end;
end;

function TBSTestScrollBox.Run: boolean;
begin
  Result := true;

  if ScrollBox1 = nil then
    ScrollBox1 := CreateScrollBox(10, 10, true);

  if ScrollBox2 = nil then
  begin
    ScrollBox2 := CreateScrollBox(300, 200, false);
    ScrollBox2.BeginUpdate;
    try
      //ScrollBox2.ScrollBarsPaddingLeft := 10;
      //ScrollBox2.ScrollBarsPaddingRight := 10;
      //ScrollBox2.ScrollBarsPaddingBottom := 10;
      //ScrollBox2.ScrollBarsPaddingTop := 10;
    finally
      ScrollBox2.EndUpdate;
    end;
    ScrollBox2.BuildView;
  end;
end;

class function TBSTestScrollBox.TestName: string;
begin
  Result := 'TBScrollBox Test';
end;

{ TBSTestGrid }

constructor TBSTestGrid.Create(ARenderer: TBlackSharkRenderer);
const
  SHOWED_DATA: AnsiString = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  SHOWED_DATA2: AnsiString = '0102030405060708090A0B0C0D0F';
  SHOWED_DATA3: AnsiString = 'Ansi Text: an every letter in a separate cell';
var
  i: int32;
begin
  inherited;
  Renderer.Frustum.OrtogonalProjection := true;
  Data := TListVec<AnsiString>.Create;
  for i := 0 to 10 do
  begin
    Data.Add(SHOWED_DATA);
    Data.Add(SHOWED_DATA2);
    Data.Add(SHOWED_DATA3);
  end;
end;

function TBSTestGrid.CreateGrid(ClassPresentation: TGridDataPresentationClass;
  const Color: TColor4f; const Position, Size: TVec2f; SetColor: boolean): TBGrid;
begin
  Result := TBGrid.Create(Renderer);
  Result.MainBody.Data.DragResolve := false;
  Result.Resize(Size.x, Size.y);
  Result.CurrentPresent := ClassPresentation.Create(Result);
  if SetColor then
    Result.CurrentPresent.Color := Color;
  Result.ClipObject.Data.Opacity := 0.0;
  Result.Position2d := Position;
end;

destructor TBSTestGrid.Destroy;
begin
  { in process testing the some of grids can not create, therefor check  }
  if Grid <> nil then
    Grid.CurrentPresent.Free;
  if Grid2 <> nil then
    Grid2.CurrentPresent.Free;
  if Grid3 <> nil then
    Grid3.CurrentPresent.Free;
  if Grid4 <> nil then
    Grid4.CurrentPresent.Free;
  Grid.Free;
  Grid2.Free;
  Grid3.Free;
  Grid4.Free;
  Data.Free;
  inherited;
end;

procedure TBSTestGrid.DrawData(Grid: TBGrid);
var
  i: int32;
  s: AnsiString;
  pos: TVec2d;
  pos_x: int32;
  pos_y: int32;
begin
  Grid.BeginPresent;
  try
    pos := Grid.PositionFirstCell;
    pos_x := trunc(pos.x);
    pos_y := 0;
    for i := trunc(pos.y) to Data.Count - 1 do
    begin
      s := Data.Items[i];
      if (length(s) > pos_x) then
        Grid.Present(vec2(trunc(pos.x), trunc(pos.y) + pos_y), @s[pos_x+1], (length(s) - pos_x)*8, 0);
      inc(pos_y);
    end;
  finally
    Grid.EndPresent;
  end;
end;

procedure TBSTestGrid.OnChangePosGrid(Sender: TBScrolledWindowCustom; const Position: TVec2d);
var
  norm_pos: TVec2d;
begin
  if ChangingPos then
    exit;
  ChangingPos := true;
  try
    norm_pos := TBGrid(Sender).PositionFirstCell;
      //vec2d(Sender.ScrollBarHor.Position/Sender.ScrollBarHor.Step,
      //Sender.ScrollBarVert.Position/Sender.ScrollBarVert.Step);
    if (Grid <> nil) then
    begin
      if (Sender <> Grid) then
        Grid.Position := vec2d(norm_pos.x * Grid.ScrollBarHor.Step,
          norm_pos.y * Grid.ScrollBarVert.Step);
      DrawData(Grid);
    end;
    if (Grid2 <> nil) then
    begin
      if (Sender <> Grid2) then
        Grid2.Position := vec2d(norm_pos.x * Grid2.ScrollBarHor.Step,
          norm_pos.y * Grid2.ScrollBarVert.Step);
      DrawData(Grid2);
    end;
    if (Grid3 <> nil) then
    begin
      if (Sender <> Grid3) then
        Grid3.Position := vec2d(norm_pos.x * Grid3.ScrollBarHor.Step,
          norm_pos.y * Grid3.ScrollBarVert.Step);
      DrawData(Grid3);
    end;
    if (Grid4 <> nil) then
    begin
      if (Sender <> Grid4) then
        Grid4.Position := vec2d(norm_pos.x * Grid4.ScrollBarHor.Step,
          norm_pos.y * Grid4.ScrollBarVert.Step);
      DrawData(Grid4);
    end;
  finally
    ChangingPos := false;
  end;
end;

procedure TBSTestGrid.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  if Grid <> nil then
  begin
    Grid.Resize(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
    Grid.Position2d := vec2(0.0, 0.0);
  end;

  if Grid2 <> nil then
  begin
    Grid2.Resize(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
    Grid2.Position2d := vec2(Renderer.WindowWidth shr 1, 0.0);
  end;

  if Grid3 <> nil then
  begin
    Grid3.Resize(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
    Grid3.Position2d := vec2(0.0, Renderer.WindowHeight shr 1);
  end;

  if Grid4 <> nil then
  begin
    Grid4.Resize(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
    Grid4.Position2d := vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1);
  end;
end;

function TBSTestGrid.Run: boolean;
begin
  if Grid = nil then
  begin
    Grid := CreateGrid(TGridAnsiDataPresentation, BS_CL_GREEN, vec2(0.0, 0.0),
      vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1), true);
    Grid.OnChangePosition := OnChangePosGrid;
    //Grid.Canvas.Root.Anchors[aLeft] := false;
    //Grid.Canvas.Root.Anchors[aTop] := false;
    DrawData(Grid);
    Grid.SetSizeGrid;
    //Grid.Canvas.Root.AnchorLeft := 0.0;
    //Grid.Canvas.Root.AnchorTop := 0.0;

    Grid2 := CreateGrid(TGridHexDataPresentation, BS_CL_SILVER2, vec2(Renderer.WindowWidth shr 1, 0.0),
      vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1), true);
    Grid2.OnChangePosition := OnChangePosGrid;
    //Grid2.Canvas.Root.Anchors[aLeft] := false;
    //Grid2.Canvas.Root.Anchors[aTop] := false;
    DrawData(Grid2);
    Grid2.SetSizeGrid;
    //Grid2.Canvas.Root.AnchorLeft := 0.0;
    //Grid2.Canvas.Root.AnchorTop := 0.0;


    Grid3 := CreateGrid(TBitsDataPresentation, BS_CL_ORANGE, vec2(0.0, Renderer.WindowHeight shr 1),
      vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1), true);
    Grid3.OnChangePosition := OnChangePosGrid;
    //Grid3.Canvas.Root.Anchors[aLeft] := false;
   // Grid3.Canvas.Root.Anchors[aTop] := false;
    TBitsDataPresentation(Grid3.CurrentPresent).SizeBit := TBitsDataPresentation.MAX_SIZE_BIT;
    DrawData(Grid3);
    Grid3.SetSizeGrid;
    //Grid3.Canvas.Root.AnchorLeft := 0.0;
    //Grid3.Canvas.Root.AnchorTop := 0.0;

    Grid4 := CreateGrid(TBitsDataPresentation, BS_CL_BLACK, vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1),
      vec2(Renderer.WindowWidth shr 1, Renderer.WindowHeight shr 1), false);
    Grid4.OnChangePosition := OnChangePosGrid;
    //Grid4.Canvas.Root.Anchors[aLeft] := false;
    //Grid4.Canvas.Root.Anchors[aTop] := false;
    TBitsDataPresentation(Grid4.CurrentPresent).SizeBit := 1;
    TBitsDataPresentation(Grid4.CurrentPresent).Color1 := BS_CL_ORANGE;
    DrawData(Grid4);
    Grid4.SetSizeGrid;
    //Grid4.Canvas.Root.AnchorLeft := 0.0;
    //Grid4.Canvas.Root.AnchorTop := 0.0;

    end;
  Result := true;

  //Grid.Font.Texture.Texture.Picture.Save('d:\fff.bmp');
end;

class function TBSTestGrid.TestName: string;
begin
  Result := 'Test Grid';
end;

{ TBSTestChartCircular }

constructor TBSTestChartCircular.Create(ARenderer: TBlackSharkRenderer);
//var
  //Curve: TBlackSharkChartCircularStr.TDataContainerPairXY;
begin
  inherited;
  ColorEnumerator := TColorEnumerator.Create([]);
  Chart := TBChartCircularStr.Create(ARenderer);
  Chart.Resize(ARenderer.WindowWidth div 2, ARenderer.WindowHeight div 2);
  Chart.SortOnGrowY := false;
  Chart.BeginUpdate;
  Chart.ShowLegend := true;
  Chart.CreateChart;

  Chart.AddPair('a', 20.0);
  Chart.AddPair('b', 50.0);
  Chart.AddPair('c', 15.0);
  Chart.AddPair('d', 25.0);
  Chart.AddPair('e', 1.0);
  Chart.AddPair('f', 3.0);
  Chart.AddPair('g', 3.0);
  Chart.AddPair('h', 3.0);
  Chart.AddPair('i', 3.0);
  Chart.AddPair('j', 4.0);
  Chart.AddPair('k', 1.0);
  Chart.AddPair('l', 60.0);
  Chart.AddPair('m', 4.0);
  Chart.AddPair('n', 60.0);
  Chart.AddPair('o', 4.0);
  Chart.AddPair('p', 60.0);
  Chart.AddPair('q', 4.0);
  Chart.AddPair('r', 4.0);
  Chart.AddPair('s', 4.0);
  Chart.AddPair('t', 45.0);
  Chart.AddPair('u', 5.0);
  Chart.AddPair('w', 5.0);
  Chart.AddPair('x', 5.0);
  Chart.AddPair('y', 90.0);
  Chart.AddPair('z', 2.0);

  ObsrvResize := Renderer.EventResize.CreateObserver(GUIThread, OnResizeWindow);
  Chart.EndUpdate;
  Chart.MainBody.ToParentCenter;
  //Chart.MainBody.Data.ScaleSimple := 0.5;
  ColorEnumerator.Free;

end;

destructor TBSTestChartCircular.Destroy;
begin
  ObsrvResize := nil;
  Chart.Free;
  inherited;
end;

procedure TBSTestChartCircular.OnResizeWindow({%H-}const Data: BResizeEventData);
begin
  //Chart.Resize(Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7);
  //Chart.Angle := vec3(0.0, 330.0, 0.0);
  //Chart.PositionZ := 1000;
  //v := Chart.Root.Data.Position;
  //Chart.Root.Data.Position := vec3(v.x, v.y, v.z - 0.5);
end;

function TBSTestChartCircular.Run: boolean;
begin
  Result := true;
  //Chart.Resize(300.0, 300.0);
  //Chart.Resize(Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7);
end;

class function TBSTestChartCircular.TestName: string;
begin
  Result := 'Test Chart Circular';
end;

{ TBSTestFloatChart }

constructor TBSTestFloatChart.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Chart := TBChartCurvesFloat.Create(ARenderer);
  //BSWriteMsg('TBSTestFloatChart.Create', 'Chart.Width: ' + IntToStr(Round(Chart.Width)));

//  if Chart.Width > ARenderer.WindowWidth then
//  begin
//  //  BSWriteMsg('TBSTestFloatChart.Create', 'width: ' + IntToStr(ARenderer.WindowWidth));
//    if Chart.Height > ARenderer.WindowHeight then
//      Chart.Resize((ARenderer.WindowWidth div round(Chart.GridStepX))*round(Chart.GridStepX), (ARenderer.WindowHeight div round(Chart.GridStepY))*round(Chart.GridStepY))
//    else
//      Chart.Resize((ARenderer.WindowWidth div round(Chart.GridStepX))*round(Chart.GridStepX), Chart.Height);
//  end else
//  if Chart.Height > ARenderer.WindowHeight then
//    Chart.Resize(Chart.Width, (ARenderer.WindowHeight div round(Chart.GridStepY))*round(Chart.GridStepY));

  Chart.Resize(ARenderer.WindowWidth div 2, ARenderer.WindowHeight div 2);
  Curve := Chart.CreateChart;
  //Chart.InterpolateSpline := isNone;
  Curve.AddPair(-2.7, -1.5);
  Curve.AddPair(0.0, 0.0);
  Curve.AddPair(1.19, 1.27);
  Curve.AddPair(5.0, 4.25);
  Curve.AddPair(7.7, 0.5);
  Curve.AddPair(9.7, 8.5);
  {Curve := Chart.CreateChart;
  //Chart.InterpolateSpline := isNone;
  Curve.AddPair(-5.7, 2.5);
  Curve.AddPair(1.0, 4.0);
  Curve.AddPair(2.19, 5.27);
  Curve.AddPair(4.06, 7.25);  }
  ObsrvResize := Renderer.EventResize.CreateObserver(GUIThread, OnResizeWindow);
end;

destructor TBSTestFloatChart.Destroy;
begin
  ObsrvResize := nil;
  Chart.Free;
  inherited;
end;

procedure TBSTestFloatChart.OnResizeWindow(const Data: BResizeEventData);
begin
  Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;

function TBSTestFloatChart.Run: boolean;
begin
  Result := true;
  Chart.BuildView;
  Chart.MainBody.ToParentCenter;
  //Chart.Resize(487.0, 690.0);
  //Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;

class function TBSTestFloatChart.TestName: string;
begin
  Result := 'Test Float Chart';
end;

{ TBSTestChartBar }

constructor TBSTestChartBar.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Chart := TBChartBarInt.Create(ARenderer);
  Curve := Chart.CreateChart;
  //Curve.AddPair(1, 11);
  //Curve.AddPair(2, 9);
  Curve.AddPair(5, 15);
  Curve.AddPair(10, 20);
  Curve.AddPair(15, 30);
  Curve := Chart.CreateChart;
  Curve.AddPair(5, 12);
  Curve.AddPair(10, 10);
  Curve.AddPair(10, 3);
  Curve.AddPair(15, 35);
  Curve := Chart.CreateChart;
  Curve.AddPair(5, 4);
  Curve.AddPair(10, 3);
  Curve.AddPair(10, 8);
  Curve.AddPair(15, 13);
  ObsrvResize := Renderer.EventResize.CreateObserver(GUIThread, OnResizeWindow);
end;

destructor TBSTestChartBar.Destroy;
begin
  ObsrvResize := nil;
  Chart.Free;
  inherited;
end;

procedure TBSTestChartBar.OnResizeWindow(const Data: BResizeEventData);
begin
  Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;

function TBSTestChartBar.Run: boolean;
begin
  Result := true;
  Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;

class function TBSTestChartBar.TestName: string;
begin
  Result := 'Test integer values Chart Bar';
end;

{ TBSTestChartBarDate }

constructor TBSTestChartBarDate.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Chart := TBChartBarDateInt.Create(ARenderer);
  Curve := Chart.CreateChart;
  Chart.AddDate(Curve, '01.01.2015', 15);
  Chart.AddDate(Curve, '01.01.2016', 20);
  Chart.AddDate(Curve, '01.01.2017', 30);
  Curve := Chart.CreateChart;
  Chart.AddDate(Curve, '01.01.2015', 10);
  Chart.AddDate(Curve, '01.01.2016', 18);
  Chart.AddDate(Curve, '01.01.2017', 25);
  Curve := Chart.CreateChart;
  Chart.AddDate(Curve, '01.01.2015', 5);
  Chart.AddDate(Curve, '01.01.2016', 30);
  Chart.AddDate(Curve, '01.01.2017', 45);
end;

destructor TBSTestChartBarDate.Destroy;
begin
  Chart.Free;
  inherited;
end;

{procedure TBSTestChartBarDate.OnResizeWindow(Data: PEventBaseRec);
begin
  Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;}

function TBSTestChartBarDate.Run: boolean;
begin
  Result := true;
  Chart.Resize(Renderer.WindowWidth * 0.5, Renderer.WindowHeight * 0.5);
end;

class function TBSTestChartBarDate.TestName: string;
begin
  Result := 'Test date values Chart Bar';
end;

{ TBSTestSelector }

constructor TBSTestSelector.Create(ARenderer: TBlackSharkRenderer);
var
  r: TRectangle;
begin
  inherited;
  Canvas := TBCanvas.Create(ARenderer, Self);
  Canvas.Font.Size := 10;
  Selector := TBlackSharkSelectorInstances.Create(Canvas, Canvas.CreateEmptyCanvasObject);
  Selector.OnSelectInstance := OnSelectInstance;
  Selector.OnUnSelectInstance := UnSelectInstance;
  SelectorsBB := TListVec<TBlackSharkSelectorBB>.Create;
  {Obj2d := TBCanvas.Create(ARenderer, false);
  with TPicture.Create(Obj2d, nil) do
    begin
    //LoadFromFile('Pictures\snowflake.png');
    LoadFromFile('Pictures\earth\earthmap1k.png');
    Position2d := vec2(100, 100);
    end;}
  Obj3d := TTexturedVertexes.Create(Self, nil , ARenderer.Scene);
  MeshLoadObj('Models/Obj/aquafish01.obj', Obj3d.Mesh, 0.004);
  Obj3d.Texture := BSTextureManager.LoadTexture('Models/Obj/aquafish01.png');
  Obj3d.Position := vec3(0.0, 0.0, -3.0);
  //Obj3d.Angle := vec3(0.0, 90.0, 0.0);
  Obj3d.DragResolve := true;
  Obj3d.Interactive := true;
  Obj3d.ChangedMesh;
  { let's complicate the task - change angle and position the camera }
  //ARenderer.FFrustum.Angle := vec3(30.0, 15, 0.0);
  //ARenderer.FFrustum.Position := vec3(-0.5, 0.0, 4.0);
  //Selector.Position2d := vec2(0.0, 0.0);
  r := TRectangle.Create(Canvas, nil);
  r.Fill := true;
  r.Size := Renderer.Screen2dCentre / 2;
  r.Build;
  r.Position2d := vec2(10.0, 10.0);//vec2(0, Scene.Screen2dCentre.y - r.Size.y / 2); //Scene.Screen2dCentre - r.Size / 2;// vec2(150, 400);
  //r.Data.Position := vec3(0.0, 0.0, 0.0);
  {TextMax := TCanvasText.Create(Canvas, nil);
  TextMax.Position2d := vec2(200, 20);
  TextMax.Text := 'Max: ' + VecToStr(vec3(0.0, 0.0, 0.0));
  TextMin := TCanvasText.Create(Canvas, nil);
  TextMin.Position2d := vec2(200, 40);
  TextMin.Text := 'Min: ' + VecToStr(vec3(0.0, 0.0, 0.0));
  TextMax.Color := BS_CL_RED;
  TextMin.Color := BS_CL_RED;                          }
end;

destructor TBSTestSelector.Destroy;
var
  i: int32;
begin
  Selector.Free;
  for i := 0 to SelectorsBB.Count - 1 do
    SelectorsBB.Items[i].Free;
  Obj2d.Free;
  SelectorsBB.Free;
  Obj3d.Free;
  Canvas.Free;
  inherited;
end;

function TBSTestSelector.GetSelector: TBlackSharkSelectorBB;
begin
  if SelectorsBB.Count > 0 then
    Result := SelectorsBB.Pop
  else
    Result := TBlackSharkSelectorBB.Create(Canvas);
  //Result.AllowResize := false;
  //Result.ShowMiddlePoints := false;
  //Result.ShowLines := false;
end;

function TBSTestSelector.OnSelectInstance(Instance: PRendererGraphicInstance): Pointer;
begin
  CurrentSelector := GetSelector;
  CurrentSelector.SelectItem := Instance;
  Result := CurrentSelector;
  Instance.Instance.Owner.TagPtr := CurrentSelector;
  exit;
  TextMax.Text := 'Max: ' + VecToStr(CurrentSelector.SelectItem.Instance.Owner.Mesh.FBoundingBox.Max);
  TextMin.Text := 'Min: ' + VecToStr(CurrentSelector.SelectItem.Instance.Owner.Mesh.FBoundingBox.Min);
end;

function TBSTestSelector.Run: boolean;
begin
  Result := true;
end;

class function TBSTestSelector.TestName: string;
begin
  Result := 'Test selector area';
end;

procedure TBSTestSelector.UnSelectInstance(Instance: PRendererGraphicInstance; Associate: Pointer);
var
  sel: TBlackSharkSelectorBB;
begin
  sel := Associate;
  if sel = CurrentSelector then
    CurrentSelector := nil;
  sel.SelectItem := nil;
  SelectorsBB.Add(sel);
end;

{ TBSTestRotor }

constructor TBSTestRotor.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(ARenderer, Self);
  Obj2d := TBCanvas.Create(ARenderer, Self);
  with bs.canvas.TPicture.Create(Obj2d, nil) do
  begin
    LoadFromFile('Pictures/snowflake.png');
    Position2d := vec2(100, 100);
    ObsrDownOnSnow := Data.EventMouseDown.CreateObserver(GUIThread,  MouseDownOnSnowflake);
  end;

  Obj3d := TTexturedVertexes.Create(Self, nil , ARenderer.Scene);
  MeshLoadObj('Models/Obj/aquafish01.obj', Obj3d.Mesh, 0.004);
  Obj3d.Mesh.DrawingPrimitive := GL_TRIANGLES;
  Obj3d.Texture := BSTextureManager.LoadTexture('Models/Obj/aquafish01.png');
  Obj3d.Shader := TBlackSharkTextureOutShader(BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  Obj3d.Position := vec3(0.0, 0.0, -1.0);
  Obj3d.Angle := vec3(0.0, 10.0, 270.0);
  Obj3d.DragResolve := true;
  Obj3d.Interactive := true;
  Obj3d.ChangedMesh;

  { let's complicate the task - change angle and position the camera }
  // ARenderer.FFrustum.Angle := vec3(0.0, 15, 0.0);
  // ARenderer.FFrustum.Position := vec3(-0.5, 0.0, 4.0);

  { create root object }
  Canvas.CreateEmptyCanvasObject.Position2d := vec2(0.0, 0.0);
  Canvas.Font.Size := 14;
  TextQuat := TCanvasText.Create(Canvas, nil);
  TextQuat.Text := 'Quat: ' + VecToStr(vec4(0.0, 0.0, 0.0, 1.0));
  TextQuat.Position2d := vec2(200, 60);
  TextQuat.Color := BS_CL_GREEN;

  Rotor := TBlackSharkRotor3D.Create(Canvas);
  ObsrDownOnFish := Obj3d.EventMouseDown.CreateObserver(GUIThread, MouseDownOnFish);
  ObsrDownOnScreen := ARenderer.EventMouseDown.CreateObserver(GUIThread,  MouseDownOnScreen);
  ObsrMove := ARenderer.EventMouseMove.CreateObserver(GUIThread,  MouseMove);
end;

destructor TBSTestRotor.Destroy;
begin
  ObsrDownOnFish := nil;
  ObsrDownOnScreen := nil;
  ObsrDownOnSnow := nil;
  ObsrMove := nil;
  if Rotor <> nil then
    Rotor.SelectItem := nil;
  Rotor.Free;
  Obj2d.Free;
  Obj3d.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestRotor.MouseDownOnFish(const Data: BMouseData);
begin
  Rotor.SelectItem := Data.BaseHeader.Instance;
  TextQuat.Text := 'Quat: ' + VecToStr(Rotor.SelectItem.Instance.Quaternion);
end;

procedure TBSTestRotor.MouseDownOnScreen(const Data: BMouseData);
begin
  if Renderer.SelectedItemsCount = 0 then
    Rotor.SelectItem := nil;
end;

procedure TBSTestRotor.MouseDownOnSnowflake(const Data: BMouseData);
begin
  Rotor.SelectItem := Data.BaseHeader.Instance;
  TextQuat.Text := 'Quat: ' + VecToStr(Rotor.SelectItem.Instance.Quaternion);
end;

procedure TBSTestRotor.MouseMove(const Data: BMouseData);
begin
  if (Rotor.SelectItem <> nil) then
    TextQuat.Text := 'Quat: ' + VecToStr(Rotor.SelectItem.Instance.Quaternion);
end;

function TBSTestRotor.Run: boolean;
begin
  Result := true;
end;

class function TBSTestRotor.TestName: string;
begin
  Result := 'Test Rotor';
end;

{ TBSTestForm }

constructor TBSTestForm.Create(ARenderer: TBlackSharkRenderer);
//var
//  btn: TBButton;
begin
  inherited;
  Form := TBForm.Create(ARenderer);
  Form.Resize(Renderer.WindowWidth*0.6, Renderer.WindowHeight*0.6);
  Form.Position2d := vec2(50, 50);
  Form.MainBody.Data.AngleZ := 30;
  ObsrvClickClose := Form.ClipObject.Data.EventMouseDown.CreateObserver(OnMouseClickBtn);
  Form.ShowModal;
end;

destructor TBSTestForm.Destroy;
begin
  ObsrvClickBtn := nil;
  ObsrvClickClose := nil;
  Form.Free;
  Form2.Free;
  inherited;
end;

procedure TBSTestForm.OnMouseClickBtn(const Data: BMouseData);
var
  btn: TBButton;
begin
  if Form2 = nil then
  begin
    Form2 := TBForm.Create(Renderer);
    Form2.CaptionHeader := 'Form2';
    Form2.Resize(Renderer.WindowWidth*0.6, Renderer.WindowHeight*0.6);
    btn := TBButton.Create(Renderer);
    Form2.DropControl(btn, Form2.OwnerInstances);
    btn.Position2d := vec2((Form2.Width - btn.Width)*0.5, (Form2.Height - btn.Height)*0.5);
    ObsrvClickBtn := btn.OnClickEvent.CreateObserver(OnMouseClickCloseBtn);
    btn.Caption := 'Close';
  end;
  Form2.ShowModal;
end;

procedure TBSTestForm.OnMouseClickCloseBtn(const Data: BMouseData);
begin
  if Form2 <> nil then
    Form2.Close;
end;

function TBSTestForm.Run: boolean;
begin
  Result := true;
end;

class function TBSTestForm.TestName: string;
begin
  Result := 'Test Form';
end;

{ TBSTestButton }

constructor TBSTestButton.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  { the button scales relative of the size screen }
  ButtonScal := TBButton.Create(ARenderer);
  ButtonScal.Canvas.Font.Size := 7;
  ButtonScal.Scalable := true;
  ButtonScal.RoundRadius := 0.0;
  ButtonScal.Resize(170*ToHiDpiScale, 40*ToHiDpiScale);
  ButtonScal.Position2d := vec2((ARenderer.WindowWidth - ButtonScal.Width) * 0.5, ARenderer.WindowHeight*0.1);
  ButtonScal.Caption := 'Create scalable button';
  ObsrvScalClick := ButtonScal.OnClickEvent.CreateObserver(OnClickScalButton);

  {Button := TBButton.Create(ARenderer);
  //Button.Resize(170, 35);
  Button.Canvas.Font.Size := 8;
  Button.Position2d := vec2(10.0, 10.0);  }
  //Button.Caption := 'Button';

  {$ifdef DEBUG}
  {ButtonS.Border.Data.Caption := 'border';
  ButtonS.MainBody.Data.Caption := 'main';
  ButtonS.Background.Data.Caption := 'background';}
  {$endif}


  //ButtonS.Canvas.Font.Texture.Texture.Picture.Save('d:\ffff.bmp');
  {ButtonEmo := TBButton.Create(ARenderer);
  ButtonEmo.Resize(100, 100);
  ButtonEmo.FontName := 'NotoEmoji-Regular';
  ButtonEmo.Canvas.Font.Size := 48;
  ButtonEmo.Caption := #$231a;
  ButtonEmo.Position2d := vec2(120, 200);
  ButtonEmo.BorderWidth := 5;
  ButtonEmo.Opacity := 0.5;
  ButtonEmo.Color := clGray;
  ButtonEmo.BorderColor := clWhite;
  ButtonEmo.CaptionColor := clLime;  }

  { rotate for testing }
  //Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 10, Renderer.Frustum.Angle.z);
end;

destructor TBSTestButton.Destroy;
var
  i: int32;
begin
  ObsrvScalClick := nil;
  for i := 0 to Length(Buttons) - 1 do
    Buttons[i].Free;
  Button.Free;
  ButtonScal.Free;
  ButtonEmo.Free;
  inherited;
end;

procedure TBSTestButton.OnClickScalButton(const AData: BMouseData);
var
  btn: TBButton;
begin
  btn := TBButton.Create(Renderer);
  btn.Canvas.Font.SizeInPixels := ButtonScal.Canvas.Font.SizeInPixels;
  btn.Scalable := true;
  btn.Caption := 'Scalable button ' + IntToStr(Length(Buttons));
  btn.Resize(ButtonScal.MainBody.Width, ButtonScal.MainBody.Height);
  if Length(Buttons) > 0 then
    btn.Position2d := vec2(Buttons[length(Buttons)-1].Position2d.x, Buttons[length(Buttons)-1].Position2d.y + ButtonScal.MainBody.Height + 10)
  else
    btn.Position2d := vec2(ButtonScal.Position2d.x, ButtonScal.Position2d.y + ButtonScal.MainBody.Height + 10);
  SetLength(Buttons, length(Buttons)+1);
  Buttons[length(Buttons)-1] := btn;
end;

function TBSTestButton.Run: boolean;
begin
  Result := true;
end;

class function TBSTestButton.TestName: string;
begin
  Result := 'Test button';
end;

{ TBSTestSimpleAnimation }

constructor TBSTestSimpleAnimation.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Canvas := TBCanvas.Create(Renderer, Self);
  Obj := TRectangle.Create(Canvas, nil);
  //Obj.A := vec2(150, 0);
  //Obj.B := vec2(150, 150);
  //Obj.C := vec2(0, 150);
  Obj.Size := vec2(200.0, 200.0);
  Obj.Fill := true;
  Obj.Build;
  Obj.Position2d := vec2((Renderer.WindowWidth - Obj.Width) * 0.5, (Renderer.WindowHeight - Obj.Height) * 0.5);
  ObsrvMouseEnter := Obj.Data.EventMouseEnter.CreateObserver(GUIThread, OnMouseEnter);
  ObsrvMouseLeave := Obj.Data.EventMouseLeave.CreateObserver(GUIThread, OnMouseLeave);
  Canvas.Font.Size := 12;
  Anim := CreateAniFloatLinear(NextExecutor);
  Anim.StartValue := 1.0;
  Anim.StopValue := 1.5;
  Anim.Duration := 1000;
  Anim.Loop := true;
  Anim.LoopInverse := true;
  { for max FPC }
  Anim.IntervalUpdate := 0;
  AniObserver := CreateAniFloatLivearObsrv(Anim, OnProcAni);
  //SrvTxt := TCanvasText.Create(Canvas, nil);
  //SrvTxt.Position2d := vec2(100, 100);
  //SrvTxt.Color := BS_CL_WHITE;
end;

destructor TBSTestSimpleAnimation.Destroy;
begin
  ObsrvMouseEnter := nil;
  ObsrvMouseLeave := nil;
  Anim.Stop;
  AniObserver := nil;
  Anim := nil;
  //AnimationScale.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestSimpleAnimation.OnMouseEnter(const Data: BMouseData);
begin
  Anim.Run;
end;

procedure TBSTestSimpleAnimation.OnMouseLeave(const Data: BMouseData);
begin
  Anim.Stop;
  //AnimationScale.Stop;
  Obj.Data.Scale := vec3(1.0, 1.0, 1.0);
  //UpCounter := 0;
  //SrvTxt.Text := 'Up: ' + IntToStr(UpCounter) + '; (1.0; 1.0)';
  //SrvTxt.Position2d := vec2(50.0, 50.0);
end;

procedure TBSTestSimpleAnimation.OnProcAni(const Value: BSFloat);
begin
  //inc(UpCounter);
  Obj.Data.Scale := vec3(Value, Value, 1.0);
end;

function TBSTestSimpleAnimation.Run: boolean;
begin

  Result := true;
end;

class function TBSTestSimpleAnimation.TestName: string;
begin
  Result := 'Simple Test Animation';
end;

{ TBSTestHint }

constructor TBSTestHint.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Hint := TBlackSharkHint.Create(ARenderer);
  Hint.AlignHintText := oaCenter;
  Hint.AllowBrakeWords := false;
  Hint.Text := 'Some a clue; This is Black Shark hint!';

  {Hint2 := TBlackSharkHint.Create(ARenderer);
  Hint2.AlignHintText := oaClient;
  Hint2.AllowBrakeWords := false;
  //Hint2.Text := 'Some a clue 2; This is Black Shark hint!';
  Hint2.Text := 'W';
  Hint2.Position2d := vec2(300, 300);}
end;

destructor TBSTestHint.Destroy;
begin
  Hint.Free;
  Hint2.Free;
  inherited;
end;

function TBSTestHint.Run: boolean;
begin
  Result := true;
end;

class function TBSTestHint.TestName: string;
begin
  Result := 'Test hint';
end;

{ TBSTestDateChart }

constructor TBSTestDateChart.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Chart := TCurvesQuantityFloatInDate.Create(ARenderer);
  Curve := Chart.CreateChart;
  Chart.BeginUpdate;
  Chart.AddDate(Curve, EncodeDate(2017, 8, 14), 30.0);
  Chart.AddDate(Curve, EncodeDate(2017, 8, 16), 25.0);
  Chart.AddDate(Curve, EncodeDate(2017, 8, 17), 40.0);
  Chart.AddDate(Curve, EncodeDate(2017, 8, 25), 15.0);
  Chart.EndUpdate;
end;

destructor TBSTestDateChart.Destroy;
begin
  Chart.Free;
  inherited;
end;

function TBSTestDateChart.Run: boolean;
begin
  Result := true;
end;

class function TBSTestDateChart.TestName: string;
begin
  Result := 'Test a quantity in date curve';
end;

{ TBSTestResample }

constructor TBSTestResample.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Pic := TBlackSharkBitMap.Create;
end;

destructor TBSTestResample.Destroy;
begin
  Pic.Free;
  inherited;
end;

function TBSTestResample.Run: boolean;
begin
  Result := Pic.Open('d:\Trash\pic2.bmp');
  if not Result then
    exit;
  Pic.Canvas.SamplerFilter.InterpolationMode := imLanczos;
  //Pic.Canvas.SamplerFilter.WindowSize := 24;
  Pic.Canvas.Resample(vec2(Pic.Width div 2, Pic.Height div 2), 0);
  Pic.Save('d:\Trash\pic2_lanc.bmp');
end;

class function TBSTestResample.TestName: string;
begin
  Result := 'Resample test';
end;

{ TBSTestMemo }

constructor TBSTestMemo.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 10, Renderer.Frustum.Angle.z);
  Memo := TBlackSharkMemo.Create(ARenderer);
  Memo.ClipObject.Data.DragResolve := true;
  //Memo.AddText('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB BBBBBBBBBB');
  //Memo.AddText('fdsgsdf', 50, 50);
  //Memo.AddRect(10, 30, 50, 50, true);
end;

destructor TBSTestMemo.Destroy;
begin
  Memo.Free;
  inherited;
end;

procedure TBSTestMemo.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  Memo.Resize(Renderer.WindowWidth, Renderer.WindowHeight);
end;

function TBSTestMemo.Run: boolean;
var
  sl: TMemoryStream;
  fn: string;
const
  EOL: word = 0;
begin
  Result := true;
  Memo.Resize(Renderer.WindowWidth, Renderer.WindowHeight);
  fn := GetFilePath('About Black Shark.txt');
  if FileExists(fn) then
  begin
    sl := TMemoryStream.Create;
    sl.LoadFromFile(fn);
    sl.Position := sl.Size;
    sl.Write(EOL, 2);
    Memo.AddText(AnsiToString(AnsiString(PAnsiChar(sl.Memory))));
    sl.Free;
  end;
  //Memo.Load('About Black Shark.txt');
end;

class function TBSTestMemo.TestName: string;
begin
  Result := 'Test memo';
end;

{ TBSTestBadDateChart }

constructor TBSTestBadDateChart.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Chart := TCurvesQuantityInDate.Create(Renderer);
  Curve := Chart.CreateChart;
  Chart.BeginUpdate;
  Chart.AddDate(Curve, EncodeDate(2017, 11, 8), 1);
  Chart.AddDate(Curve, EncodeDate(2017, 11, 9), 3);
  Chart.AddDate(Curve, EncodeDate(2017, 11, 11), 4);
  Chart.AddDate(Curve, EncodeDate(2017, 11, 13), 2);
  Chart.EndUpdate;
end;

destructor TBSTestBadDateChart.Destroy;
begin
  Chart.Free;
  inherited;
end;

function TBSTestBadDateChart.Run: boolean;
begin
  Result := true;
end;

class function TBSTestBadDateChart.TestName: string;
begin
  Result := 'Bad chart the test';
end;

{ TBSTestScrollBar }

constructor TBSTestScrollBar.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  //Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 90, Renderer.Frustum.Angle.z);
  Canvas := TBCanvas.Create(ARenderer, nil);
  Canvas.Scalable := true;
  ObsrvAfterRealign := CreateCanvasEventObserver(Canvas.OnAfterRealgnObjects, OnAfterRealign);
  ScrollBarVert := TBScrollBar.Create(Canvas);
  ScrollBarVert.Scalable := true;
  //ScrollBar.Horizontal := true;
  ScrollBarVert.Resize(ScrollBarVert.Width, 300);
  //ScrollBar.Resize(5, 50);
  //ScrollBar.MainBody.Angle := vec3(0.0, 0.0, 130.0);
  ScrollBarVert.OnChangePosition := OnChangeVert;

  ScrollBarHor := TBScrollBar.Create(Canvas);
  ScrollBarHor.Scalable := true;
  ScrollBarHor.Horizontal := true;
  //ScrollBarHor.Resize(20, 300);
  //ScrollBarHor.Resize(5, 50);
  //ScrollBarHor.MainBody.Angle := vec3(0.0, 0.0, 130.0);
  ScrollBarHor.OnChangePosition := OnChangeHor;

  LabelPosVert := TCanvasText.Create(Canvas, nil);
  LabelPosVert.Text := 'Position: 0';
  LabelPosVert.Layer2d := 3;

  LabelPosHor := TCanvasText.Create(Canvas, nil);
  LabelPosHor.Text := 'Position: 0';
  LabelPosHor.Layer2d := 3;

  Rectangle := TRectangle.Create(Canvas, nil);
  Rectangle.Color := BS_CL_BLUE;
  Rectangle.Data.Opacity := 0.3;
  Rectangle.Fill := true;
  Rectangle.Size := vec2(Renderer.WindowWidth*0.8, Renderer.WindowHeight*0.8);
  Rectangle.Build;
  Rectangle.Data.Interactive := false;

  CaptionArea := TCanvasText.Create(Canvas, Rectangle);
  CaptionArea.Text := 'Scrolled area: ' + IntToStr(round(Rectangle.Size.x)) + 'x' + IntToStr(round(Rectangle.Size.y));
  CaptionArea.ToParentCenter;

  ScrollBarVert.Size := round(Rectangle.Size.y);
  ScrollBarHor.Size := round(Rectangle.Size.x);
  ScrollBarVert.Position2d := vec2(ScrollBarHor.Width + 20, 20.0);
  ScrollBarHor.Position2d := vec2(20.0, ScrollBarVert.Height + 20);

  LabelPosVert.Position2d := vec2(ScrollBarVert.Position2d.x + 20 + ScrollBarVert.Width, ScrollBarVert.Position2d.y + ScrollBarVert.Height * 0.5);
  LabelPosHor.Position2d := vec2(ScrollBarHor.Position2d.x + (ScrollBarHor.Width - LabelPosHor.Width) * 0.5, ScrollBarHor.Position2d.y + 20 + ScrollBarHor.Height);

  Rectangle.Position2d := vec2(ScrollBarHor.Position2d.x, ScrollBarVert.Position2d.y);

end;

destructor TBSTestScrollBar.Destroy;
begin
  ScrollBarVert.Free;
  ScrollBarHor.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestScrollBar.OnAfterRealign(const BData: BData);
begin
  CaptionArea.Text := 'Scrolled area: ' + IntToStr(round(Rectangle.Size.x)) + 'x' + IntToStr(round(Rectangle.Size.y));
  CaptionArea.ToParentCenter;
  ScrollBarHor.Size := round(Rectangle.Width);
  ScrollBarVert.Size := round(Rectangle.Height);
end;

procedure TBSTestScrollBar.OnChangeHor(ASender: TBScrollBar);
begin
  LabelPosHor.Text := 'Position: ' + IntToStr(ASender.Position);
  Rectangle.Position2d := vec2(ScrollBarHor.Position2d.x - ScrollBarHor.Position, ScrollBarVert.Position2d.y - ScrollBarVert.Position);
end;

procedure TBSTestScrollBar.OnChangeVert(ASender: TBScrollBar);
begin
  LabelPosVert.Text := 'Position: ' + IntToStr(ASender.Position);
  Rectangle.Position2d := vec2(ScrollBarHor.Position2d.x - ScrollBarHor.Position, ScrollBarVert.Position2d.y - ScrollBarVert.Position);
end;

procedure TBSTestScrollBar.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
end;

function TBSTestScrollBar.Run: boolean;
begin
  Result := true;
end;

class function TBSTestScrollBar.TestName: string;
begin
  Result := 'Test scroll bar';
end;

{ TBSTestAnimationByAnimator }

constructor TBSTestAnimationByAnimator.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  AniLawScale := CreateAniFloatLinear(GUIThread);
  AniObsrv := AniLawScale.CreateObserver(GUIThread, OnUpdateValueScale);
  AniLawScale.Duration := 500;
  AniLawScale.StartValue := 1.0;
  AniLawScale.StopValue := 1.3;

  Canvas := TBCanvas.Create(Renderer, Self);
  Obj := TRectangle.Create(Canvas, nil);
  Obj.Size := vec2(200.0, 200.0);
  Obj.Fill := true;
  Obj.Build;
  Obj.Position2d := vec2((Renderer.WindowWidth - Obj.Width) * 0.5 ,
    (Renderer.WindowHeight - Obj.Height) * 0.5);
  ObsrvMouseEnter := Obj.Data.EventMouseEnter.CreateObserver(GUIThread, OnMouseEnter);
  ObsrvMouseLeave := Obj.Data.EventMouseLeave.CreateObserver(GUIThread, OnMouseLeave);
end;

destructor TBSTestAnimationByAnimator.Destroy;
begin
  Canvas.Free;
  AniObsrv := nil;
  AniLawScale := nil;
  ObsrvMouseEnter := nil;
  ObsrvMouseLeave := nil;
  inherited;
end;

procedure TBSTestAnimationByAnimator.OnMouseEnter(const Data: BMouseData);
begin
  AniLawScale.Run;
end;

procedure TBSTestAnimationByAnimator.OnMouseLeave(const Data: BMouseData);
begin
  AniLawScale.Stop;
  Obj.Data.Scale := vec3(1.0, 1.0, 1.0);
end;

procedure TBSTestAnimationByAnimator.OnUpdateValueScale(const Data: BSFloat);
begin
  Obj.Data.Scale := vec3(AniLawScale.CurrentValue, AniLawScale.CurrentValue,
    AniLawScale.CurrentValue);
end;

function TBSTestAnimationByAnimator.Run: boolean;
begin
  Result := true;
end;

class function TBSTestAnimationByAnimator.TestName: string;
begin
  Result := 'Animation By Animator (through queue)';
end;

{ TBSTestAnimationFlame }

constructor TBSTestAnimationFlame.Create(ARenderer: TBlackSharkRenderer);
var
  i: Integer;
  j: Integer;
begin
  inherited;
  AniEmpty := CreateEmptyTask;
  AniObsrv := AniEmpty.CreateObserver(GUIThread, OnUpdateValue);
  { 25 frames per second }
  AniEmpty.IntervalUpdate := 40;

  Canvas := TBCanvas.Create(Renderer, Self);
  Obj := TRectangleTextured.Create(Canvas, nil);
  Obj.Size := vec2(320, 320);
  Obj.Fill := true;
  Obj.Build;
  Obj.Position2d := vec2((Renderer.WindowWidth - Obj.Width) * 0.5, (Renderer.WindowHeight - Obj.Height) * 0.5);
  Texture := BSTextureManager.LoadTexture(GetFilePath('flame.png', 'Pictures')).Texture;
  for i := 5 downto 0 do
    for j := 0 to 5 do
      Texture.GenFrameUV(j*320, i*320, 320, 320);
end;

destructor TBSTestAnimationFlame.Destroy;
begin
  if AniEmpty.IsRun then
    AniEmpty.Stop;

  AniObsrv := nil;
  AniEmpty := nil;

  Texture := nil;
  Obj.Texture := nil;
  Canvas.Free;
  //BSTextureManager.AreaFree();
  inherited;
end;

procedure TBSTestAnimationFlame.OnUpdateValue(const Data: byte);
begin
  Obj.Texture := Texture.Frames[Current mod 36];
  inc(Current);
end;

function TBSTestAnimationFlame.Run: boolean;
begin
  Result := true;
  AniEmpty.Run;
end;

class function TBSTestAnimationFlame.TestName: string;
begin
  Result := 'Animation of texture';
end;

{ TBSTestEdit }

constructor TBSTestEdit.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.OrtogonalProjection := true;
  //Viewport.Width := 800;
  //Canvas := TBCanvas.Create(ARenderer, nil);
  //Canvas.Scalable := true;
  Edit1 := TBEdit.Create(ARenderer);
  Edit1.Scalable := true;
  Edit1.Position2d := vec2(100, 250);
  Edit1.Text := 'Shark';
  //Edit1.LeftMargin := 1;

  {Edit2 := TBEdit.Create(ARenderer);
  Edit2.Position2d := vec2(300, 200);
  Edit2.Canvas.Font.SizeInPixels := 20; }

  Edit3 := TBSpinEdit.Create(ARenderer);
  Edit3.Position2d := vec2(Edit1.Position2d.x, Edit1.Position2d.y + Edit1.Height + 50);
  Edit3.Scalable := true;
  Edit4 := TBSpinEdit.Create(ARenderer);
  Edit4.Position2d := vec2(Edit3.Position2d.x + Edit3.Width + 50, Edit3.Position2d.y);
  Edit4.MinValue := -100;
  Edit4.MaxValue := 0;
  Edit4.Scalable := true;
end;

destructor TBSTestEdit.Destroy;
begin
  FreeAndNil(Edit1);
  FreeAndNil(Edit2);
  FreeAndNil(Edit3);
  FreeAndNil(Edit4);
  //Canvas.Free;
  inherited;
end;

function TBSTestEdit.Run: boolean;
begin
  Result := true;
end;

class function TBSTestEdit.TestName: string;
begin
  Result := 'Test of edit';
end;

{ TBSTestObjectInspector }

constructor TBSTestObjectInspector.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.OrtogonalProjection := true;
  Inspector := TObjectInspector.Create(ARenderer);
  Inspector.MainBody.Data.DragResolve := true;
  //Inspector.Position2d := vec2(10.0, 10.0);
  //Inspector.MainBody.PositionZ := 100;
  Canvas := TBCanvas.Create(ARenderer, nil);
  Canvas.ModalLevel := 333;
  Form := TBForm.Create(Canvas);
  Form.ScrolledArea := Vec2d(Form.Width, Form.Height-Form.HeaderHeight);
  Edit1 := TBEdit.Create(Canvas);
  Edit1.Text := 'xxxx';
  Form.DropControl(Edit1, Form.OwnerInstances);
  Edit1.Position2d := vec2(50, 150.0);
  Edit2 := TBSpinEdit.Create(Canvas);
  Form.DropControl(Edit2, Form.OwnerInstances);
  Form.Position2d := vec2(300, 50);
  Edit2.Position2d := vec2(50, 50.0);
  OnFocusChangeObsrv := CreateFocusObserver(TBControl.EventFocusChanged, OnFocusChanged);

  EditSave := TBEdit.Create(Renderer);
  EditSave.Resize(120, EditSave.Height);
  EditSave.Position2d := vec2(20, Inspector.Position2d.y + Inspector.Height + 20);
  EditSave.Text := 'scheme.xml';
  EditLoad := TBEdit.Create(Renderer);
  EditLoad.Resize(120, EditLoad.Height);
  EditLoad.Position2d := vec2(EditSave.Position2d.x, EditSave.Position2d.y + EditSave.Height + 20);
  EditLoad.Text := 'scheme.xml';
  BtnSave := TBButton.Create(Renderer);
  BtnSave.Caption := 'Save';
  BtnSave.Resize(60, EditSave.Height);
  BtnSave.Position2d :=  vec2(EditSave.Position2d.x + EditSave.Width + 10, EditSave.Position2d.y);
  ObsrvSave := BtnSave.OnClickEvent.CreateObserver(GUIThread,  OnSaveClick);
  BtnLoad := TBButton.Create(Renderer);
  BtnLoad.Caption := 'Load';
  BtnLoad.Resize(60, EditLoad.Height);
  BtnLoad.Position2d :=  vec2(EditLoad.Position2d.x + EditLoad.Width + 10, EditLoad.Position2d.y);
  ObsrvLoad := BtnLoad.OnClickEvent.CreateObserver(GUIThread,  OnLoadClick);
end;

destructor TBSTestObjectInspector.Destroy;
begin
  EditSave.Free;
  EditLoad.Free;
  BtnSave.Free;
  BtnLoad.Free;

  OnFocusChangeObsrv := nil;
  Edit1.Free;
  Edit2.Free;
  Form.Free;
  Canvas.Free;
  Inspector.Free;
  inherited;
end;

procedure TBSTestObjectInspector.OnFocusChanged(const Data: BFocusEventData);
begin
  if (Canvas.ModalLevel <> Data.ControlLevel) or (TBControl(Data.Control).ParentControl = Inspector) or
    TBControl(Data.Control).MainBody.HasAncestor(Inspector.MainBody) then
      exit;
  if TBControl(Data.Control).Focused then
    Inspector.InspectedObject := Data.Control
  else
  if Inspector.InspectedObject = Data.Control then
    Inspector.InspectedObject := nil;
end;

procedure TBSTestObjectInspector.OnLoadClick(const Data: BMouseData);
begin
  Inspector.ThemeManager.Load(EditLoad.Text);
  Form.LoadProperties(Inspector.ThemeManager);
  Edit1.LoadProperties(Inspector.ThemeManager);
  Edit2.LoadProperties(Inspector.ThemeManager);
end;

procedure TBSTestObjectInspector.OnSaveClick(const Data: BMouseData);
begin
  Inspector.ThemeManager.Save(EditSave.Text);
end;

function TBSTestObjectInspector.Run: boolean;
begin
  Result := true;
end;

class function TBSTestObjectInspector.TestName: string;
begin
  Result := 'Test of object inspector';
end;

{ TBSTestTable }

constructor TBSTestTable.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.OrtogonalProjection := true;
  CheckBoxData := TListVec<string>.Create;
  LastIndex := -1;
end;

function TBSTestTable.CreateTable(Scalable: boolean; const Position: TVec2f; const Size: TVec2f; const Caption: string): TBTable;
var
  column: IColumnPresentor;
  getter_string: TDataGetter<string>;
begin
  Result := TBTable.Create(Renderer);
  Table := Result;
  Result.Scalable := Scalable;
  Result.Resize(Size.x, Size.y);
  Result.Position2d := Position;
  Result.ShowHeader := true;

  Result.ClipObject.Data.DragResolve := true;
  Result.BeginUpdate;
  try
    //Result.ClipObject.Data.Interactive := false;
    Result.Count := 30;

    getter_string := GetNumberData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, '№');
    column.Width := Result.ClipObject.Width * 0.1 - 1;
    column.Align := oaCenter;
    getter_string := GetCheckBoxData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorCheckbox, Caption + ' 1');
    column.Width := Result.ClipObject.Width * 0.2 - 1;
    column.OnChangeData := OnChangeCheck;
    column.Align := oaCenter;
    getter_string := GetStringData2;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, Caption + ' 2');
    column.Width := Result.ClipObject.Width * 0.3 - 1;
    column.Align := oaRight;
    getter_string := GetStringData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, Caption + ' 3');
    column.Width := Result.ClipObject.Width * 0.3 - 1;
    getter_string := GetStringData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, Caption + ' 4');
    column.Width := Result.ClipObject.Width * 0.3 - 1;
    getter_string := GetStringData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, Caption + ' 5');
    column.Width := Result.ClipObject.Width * 0.3 - 1;
    getter_string := GetStringData;
    column := Result.CreateColumn(TMethod(getter_string), TBColumnPresentorString, Caption + ' 6');
    column.Width := Result.ClipObject.Width * 0.3 - 1;
  finally
    Result.EndUpdate;
  end;
end;

destructor TBSTestTable.Destroy;
begin
  CheckBoxData.Free;
  Table.Free;
  inherited;
end;

function TBSTestTable.GetCheckBoxData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin
  AData := CheckBoxData.Items[AIndex];
  if AData = '' then
  begin
    if AIndex mod 2 = 0 then
      AData := BoolToStr(true) + ';'
    else
      AData := BoolToStr(false) + ';';
  end;

  Result := true;
end;

function TBSTestTable.GetNumberData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin

  LastIndex := AIndex;
  AData := IntToStr(AIndex+1);

  Result := true;
end;

function TBSTestTable.GetStringData(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin
  AData := IntToHex(AIndex, 8);
  Result := true;
end;

function TBSTestTable.GetStringData2(ASender: IColumnPresentor; AIndex: int64; out AData: string): boolean;
begin
  AData := IntToHex(Table.Count - AIndex, 8);
  Result := true;
end;

procedure TBSTestTable.OnChangeCheck(ACell: IColumnCellPresentor);
begin
  CheckBoxData.Items[ACell.Column.Position + ACell.Index] := ACell.DataToString;
end;

function TBSTestTable.Run: boolean;
begin
  CreateTable(true, vec2(0, 0), vec2(round(Renderer.WindowWidth * 0.8), round(Renderer.WindowHeight * 0.8)), 'Column');
  Result := true;
end;

class function TBSTestTable.TestName: string;
begin
  Result := 'Test of TBTable';
end;

{ TBSTestCheckBox }

constructor TBSTestCheckBox.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  CheckBox := TBCheckBox.Create(ARenderer);
  CheckBox.Scalable := true;
  CheckBox.Position2d := vec2(10, 20);
  //CheckBox.Text := '';

  GroupBox := TBGroupBox.Create(ARenderer);
  GroupBox.Resize(200, (length(Checkboxes)+3) * 17 + 10);

  GroupBox.Position2d := vec2(50, 300);

  Canvas := TBCanvas.Create(ARenderer, nil);
  CreateCheckboxes;
end;

procedure TBSTestCheckBox.CreateCheckboxes;
var
  i: int32;
  y: bsfloat;
begin

  MasterCheckbox := TBCheckBox.Create(Renderer);
  MasterCheckbox.ParentControl := GroupBox;
  MasterCheckbox.Position2d := vec2(10, 15);
  MasterCheckbox.Text := 'Master checkbox';
  MasterCheckbox.OnCheck := MasterClick;
  MasterCheckbox.MainBody.Data.DragResolve := false;
  y := MasterCheckbox.Position2d.y + MasterCheckbox.Height + 10;
  for i := 0 to length(Checkboxes) - 1 do
  begin
    Checkboxes[i] := TBCheckBox.Create(Renderer);
    Checkboxes[i].ParentControl := GroupBox;
    Checkboxes[i].Text := 'Checkbox ' + IntToStr(i);
    Checkboxes[i].Position2d := vec2(15, y);
    Checkboxes[i].OnCheck := SlaveClick;
    Checkboxes[i].MainBody.Data.DragResolve := false;
    y := y + Checkboxes[i].Height + 3;
  end;
end;

destructor TBSTestCheckBox.Destroy;
var
  i: int32;
begin
  MasterCheckbox.Free;
  for i := 0 to length(Checkboxes) - 1 do
    Checkboxes[i].Free;
  CheckBox.Free;
  Canvas.Free;
  GroupBox.Free;
  inherited;
end;

procedure TBSTestCheckBox.MasterClick(ASender: TObject);
var
  i: int32;
begin
  for i := 0 to length(Checkboxes) - 1 do
    Checkboxes[i].IsChecked := MasterCheckbox.IsChecked;
  MasterCheckbox.IsHalfChecked := false;
  if MasterCheckbox.IsChecked then
    CountChecked := Length(Checkboxes)
  else
    CountChecked := 0;
end;

function TBSTestCheckBox.Run: boolean;
begin
  Result := true;
end;

procedure TBSTestCheckBox.SlaveClick(ASender: TObject);
begin
  if TBCheckBox(ASender).IsChecked then
    inc(CountChecked)
  else
    dec(CountChecked);
  if CountChecked = Length(Checkboxes) then
    MasterCheckbox.IsChecked := true
  else
  if CountChecked > 0 then
    MasterCheckbox.IsHalfChecked := true
  else
    MasterCheckbox.IsChecked := false;
end;

class function TBSTestCheckBox.TestName: string;
begin
  Result := 'Test of TBCheckBox';
end;

{ TBSTestComboBox }

constructor TBSTestComboBox.Create(ARenderer: TBlackSharkRenderer);
var
  i: int32;
begin
  inherited;
  ComboBox := TBComboBox.Create(ARenderer);
  ComboBox.Resize(120*ToHiDpiScale, ComboBox.Height);
  for i := 0 to 10 do
    ComboBox.AddItem('I ' + IntToStr(i));
  //Renderer.Frustum.Angle := vec3(Renderer.Frustum.Angle.x, Renderer.Frustum.Angle.y + 90, Renderer.Frustum.Angle.z);
end;

destructor TBSTestComboBox.Destroy;
begin
  ComboBox.Free;
  inherited;
end;

function TBSTestComboBox.Run: boolean;
begin
  ComboBox.MainBody.ToParentCenter;
  Result := true;
end;

class function TBSTestComboBox.TestName: string;
begin
  Result := 'Test of TBComboBox';
end;

{ TBSTestColorBox }

constructor TBSTestColorBox.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Renderer.Frustum.OrtogonalProjection := true;
  ColorBox := TBColorBox.Create(ARenderer);
end;

destructor TBSTestColorBox.Destroy;
begin
  ColorBox.Free;
  inherited;
end;

function TBSTestColorBox.Run: boolean;
begin
  Result := True;
  ColorBox.MainBody.ToParentCenter;
end;

class function TBSTestColorBox.TestName: string;
begin
  Result := 'Test of TBColorBox';
end;

{ TBSTestColorDialog }

constructor TBSTestColorDialog.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  ColorDialog := TBColorDialog.Create(ARenderer);
  if ColorDialog.Width > ARenderer.WindowWidth then
    ColorDialog.Resize(ARenderer.WindowWidth, ColorDialog.Height);
  ColorDialog.Position2d := vec2((ARenderer.WindowWidth - ColorDialog.Width)*0.5, 0);
end;

destructor TBSTestColorDialog.Destroy;
begin
  ColorDialog.Free;
  inherited;
end;

function TBSTestColorDialog.Run: boolean;
begin
  Result := True;
  ColorDialog.ShowModal;

end;

class function TBSTestColorDialog.TestName: string;
begin
  Result := 'Test of TBColorDialog';
end;

{ TBSTestTrackBar }

constructor TBSTestTrackBar.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  TrackBar := TBTrackBar.Create(ARenderer);
  TrackBar.Resize(ARenderer.WindowWidth div 2, TrackBar.Height);
  TrackBar.MainBody.ToParentCenter;
  TrackBar.Scalable := true;
end;

destructor TBSTestTrackBar.Destroy;
begin
  TrackBar.Free;
  inherited;
end;

function TBSTestTrackBar.Run: boolean;
begin
  Result := true;
end;

class function TBSTestTrackBar.TestName: string;
begin
  Result := 'Test of TBTrackBar';
end;

end.
