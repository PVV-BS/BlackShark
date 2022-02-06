unit bs.test.spacetree;

{$I BlackSharkCfg.inc}

interface

{$define DEBUG_ST}

uses
    bs.test
  , bs.basetypes
  , bs.obj
  , bs.events
  , bs.collections
  , bs.renderer
  , bs.scene
  , bs.canvas
  , bs.scene.objects
  , bs.geometry
  , bs.gui.scrollbox
  , bs.gui.forms
  , bs.gui.buttons
  , bs.gui.checkbox
  , bs.graphics
  , bs.animation
  ;


type

  { TBSTestScrollBoxSpaceTree }

  { the test implements Model-View-Controller template }

  TBSTestScrollBoxSpaceTree = class(TBSTest)
  private
    type
      { the space tree nodes a visualiser }
      PVisualData = ^TVisualData;
      TVisualData = record
        Present: TRectangle;
        LinesBB: TBoundingBoxVisualizer.TContNode;
        OnDropObsr: Pointer;
      end;

      PCustomModelData = ^TCustomModelData;
      TCustomModelData = record
        Rect: TRectBSf;
        Color: TColor4f;
        { used only in time when the data is visual }
        VisualData: PVisualData;
        { a position in space tree; need only for update position in tree when
          the data change position in space }
        NodeInSpaceTree: PNodeSpaceTree;
        { custom an user data }
        SomeData: Pointer;
      end;

      TModel = TListVec<PCustomModelData>;

      { TController }

      TController = class
      private
        { Cache for hided leaf nodes contaning the visualaiser for a user data }
        CacheWithCO: TListVec<PVisualData>;
        { Cache for hided no leaf nodes }
        Cache: TListVec<PVisualData>;
        FViewer: TBScrollBox;
        FModel: TModel;
        VisualizerBB: TBoundingBoxVisualizer;
        Colors: TColorEnumerator;
        { in this container don't need, but when no leaf node is hides, Im don't
          push him to Cache (as must be), that is why Im need take into account
          all created PVisualData for visualise nodes in order to free him }
        AllVisualData: TListVec<PVisualData>;
        OnDropObsrs: BObserversGroup<BDragDropData>;
        function GetVisualData(ForMe: PCustomModelData): PVisualData; overload;
        procedure OnDrop(const data: BDragDropData);
        procedure LoadModel;
        procedure OnHideData(Node: PNodeSpaceTree);
        procedure OnShowData(Node: PNodeSpaceTree);
        procedure OnUpdatePositionUserData(Node: PNodeSpaceTree);
        {$ifdef DEBUG_BS}
        function BB2dTo3d(const Box: TBox3f): TBox3f;
        function GetVisualData(Node: PNodeSpaceTree): PVisualData; overload;
        procedure OnHideNoLeafNode(Node: PNodeSpaceTree);
        procedure OnShowNoLeafNode(Node: PNodeSpaceTree);
        procedure OnUpdatePositionNoLeafNode(Node: PNodeSpaceTree);
        procedure OnChangeSizeNoLeafNode(Node: PNodeSpaceTree);
        {$endif}
      public
        constructor Create(AModel: TModel; AViewer: TBScrollBox);
        destructor Destroy; override;
      end;
    const
      COUNT_ITEM = 10000;
  private
    ScrollBox: TBScrollBox;
    CastomModel: TModel;
    Controller: TController;
    Billboard: TBCanvas;
    CountVisibleItems: TCanvasText;
    CountHideItems: TCanvasText;
    {$ifdef DEBUG_BS}
    CountNodes: TCanvasText;
    {$endif}
    CountAllItems: TCanvasText;
    procedure GenerateModel;
    procedure ClearModel;
    procedure OnScroll(ScrollingWindow: TBScrolledWindowCustom; const NewPos: TVec2d);
    procedure UpdateBillboard;
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  TBSTestSceneKDTree = class(TBSTest)
  private
    const
      //COUNT_OBJECTS = 10;
      //WORLD_BOUNDARY_MAX =  20;
      //WORLD_BOUNDARY_MIN = -20;
      COUNT_OBJECTS = 10000;
      WORLD_BOUNDARY_MAX =  300;
      WORLD_BOUNDARY_MIN = -300;

  private
    Billboard: TBCanvas;
    BillboardPanel: TRectangle;
    CountVisibleItems: TCanvasText;
    CountHideItems: TCanvasText;
    CountNodes: TCanvasText;
    CountAllItems: TCanvasText;
    ViewPortPos: TCanvasText;
    FPS: TCanvasText;
    EventUpdate: IBAnimationLinearFloat;
    EventUpdateObserver: IBAnimationLinearFloatObsrv;
    Proto: TColoredVertexes;
    Axex: TGraphicObjectAxises;
    Lines: TGraphicObjectLines;
    chbDrawLines: TBCheckBox;
    chbMoveObjects: TBCheckBox;
    Directions: TListVec<TVec3f>;
    Velosity: TListVec<BSFloat>;
    LastTime: Cardinal;

    procedure GenerateScene;
    {$ifdef DEBUG_ST}
    procedure DrawAlreadyExistNodes;
    {$endif}
    procedure OnUpdate(const AValue: BSFloat);
    procedure UpdateBillboard;
    procedure OnSplitNode(ADem: int32; AVectorMinMax: PBoxMinMax; ABoundary: double);
    procedure OnMoveObjectsClick(ASender: TObject);
    //procedure OnChangeMVP(const AData: BEmpty);
    procedure OnClickDrawLines(ASender: TObject);
    procedure DrawKDNodes;
    procedure CreateHelpPanel;
  protected
    procedure OnMoveCamera(const Data: BData); override;
    procedure OnResizeViewport(const Data: BResizeEventData); override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    SysUtils
  , math
  , bs.math
  , bs.config
  , bs.thread
  , bs.mesh.primitives
  ;

{ TBSTestScrollBoxSpaceTree }

procedure TBSTestScrollBoxSpaceTree.ClearModel;
var
  i: int32;
begin
  for i := 0 to CastomModel.Count - 1 do
    dispose(CastomModel.Items[i]);
  CastomModel.Count := 0;
end;

constructor TBSTestScrollBoxSpaceTree.Create(ARenderer: TBlackSharkRenderer);
var
  p_txt: TRectangle;
begin
  inherited;
  //ScrollBar := TBlackSharkScrollBar.Create(AScene, nil);
  //ScrollBar.Position2d := vec2(300.0, 500.0);
  ScrollBox := TBScrollBox.Create(Renderer);
  ScrollBox.ScrolledArea := vec2d(5000.0, 5000.0); // vec2d(500.0, 500.0);//
  ScrollBox.OnChangePosition := OnScroll;
  ScrollBox.MainBody.Data.DragResolve := true;
  ScrollBox.Position2d := vec2(10.0, 150.0);
  ScrollBox.ClipObject.Color := BS_CL_WHITE;

  //ScrollBox.AutoResizeScrollingArea := true;
  //ScrollBox.VertexKind := vkPT;
  //ScrollBox.Position2d := Scene.ScreenSize/2;
  //ScrollBox.Align := TCanvasObjectAlign.oaClient;
  CastomModel := TModel.Create;
  Billboard := TBCanvas.Create(Renderer, Self);
  p_txt := TRectangle.Create(Billboard, nil);
  p_txt.Fill := true;
  p_txt.Size := vec2(250, 85);
  p_txt.Color := BS_CL_MSVS_PANEL;
  p_txt.Build;
  p_txt.Position2d := vec2(10, 10);

  p_txt := TRectangle.Create(Billboard, p_txt);
  p_txt.Color := BS_CL_ORANGE_2;
  p_txt.Size := vec2(250, 85);
  p_txt.Build;
  p_txt.Position2d := vec2(0, 0);
  //Billboard.CreateEmptyCanvasObject.Position2d := vec2(0.0, 0.0);

  CountAllItems := TCanvasText.Create(Billboard, p_txt);
  CountAllItems.Text := 'Count all items: 0';
  CountAllItems.Data.Interactive := false;
  CountAllItems.Position2d := vec2(10, 10);
  CountVisibleItems := TCanvasText.Create(Billboard, p_txt);
  CountVisibleItems.Text := 'Count all items: 0';
  CountVisibleItems.Data.Interactive := false;
  CountVisibleItems.Position2d := vec2(10, 27);
  CountHideItems := TCanvasText.Create(Billboard, p_txt);
  CountHideItems.Text := 'Count hide items: 0';
  CountHideItems.Data.Interactive := false;
  CountHideItems.Position2d := vec2(10, 44);
  {$ifdef DEBUG_BS}
  CountNodes := TCanvasText.Create(Billboard, p_txt);
  CountNodes.Text := 'Count visible nodes: 0';
  CountNodes.Data.Interactive := false;
  CountNodes.Position2d := vec2(10, 61);
  {$endif}
end;

destructor TBSTestScrollBoxSpaceTree.Destroy;
begin
  Controller.Free;
  Billboard.Free;
  ClearModel;
  CastomModel.Free;
  inherited;
end;

procedure TBSTestScrollBoxSpaceTree.GenerateModel;
var
  enm_cl: TColorEnumerator;
  i: int32;
  item: PCustomModelData;

  procedure CreateItem(const Pos: TVec2i; const Size: TVec2i; const Color: TColor4f);
  begin
    new(item);
    item.Rect.Size := Size;
    item.Rect.Position := Pos;
    item.Color := Color;
    item.SomeData := nil;
    CastomModel.Add(item);
  end;

begin
  Randomize;
  enm_cl := TColorEnumerator.Create([]);
  //enm_cl.GetNextColor;
  //if enm_cl.CurrentColor = ScrollBox.Root.Color then
  //  enm_cl.GetNextColor;
  {CreateItem(vec2(90, 309), vec2(50, 50), BS_CL_RED);
  CreateItem(vec2(56, 157), vec2(100, 80), BS_CL_SKY_BLUE);
  CreateItem(vec2(111, 139), vec2(40, 90), BS_CL_BLUE);
  CreateItem(vec2(560, 0), vec2(40, 90), BS_CL_MSVS_BORDER);
  //CreateItem(vec2(int32(round(ScrollBox.Height) + 18), 50), vec2(60, 80), BS_CL_YELLOW);
  CreateItem(vec2(int32(300), int32(round(ScrollBox.Height) + 28)), vec2(30, 70), BS_CL_ORANGE);
  //CreateItem(vec2(int32(400), int32(round(ScrollBox.Height) + 378)), vec2(33, 70), BS_CL_MAROON);
  //CreateItem(vec2(int32(330), int32(round(ScrollBox.Height) + 454)), vec2(33, 64), BS_CL_ORANGE_LIGHT);
  //CreateItem(vec2(int32(round(ScrollBox.Width) + 454), int32(round(ScrollBox.Height) + 454)), vec2(120, 64), BS_CL_ORANGE_LIGHT); }
  //CreateItem(vec2(0, 1000), vec2(40, 90), BS_CL_SKY);
  {CreateItem(vec2(1456, 0), vec2(40, 90), BS_CL_ORANGE);
  //CreateItem(vec2(890, 50), vec2(40, 90), BS_CL_TEAL);

  CreateItem(vec2(111, 333), vec2(100, 100), BS_CL_MSVS_BORDER);

  CreateItem(vec2(130, 380), vec2(100, 100), BS_CL_MSVS_BORDER);
  CreateItem(vec2(78, 410), vec2(111, 80), BS_CL_MSVS_BORDER);
  CreateItem(vec2(145, 433), vec2(100, 100), BS_CL_MSVS_BORDER); }
  //CreateItem(vec2(133, 450), vec2(100, 100), BS_CL_MSVS_BORDER);

  for i := 0 to COUNT_ITEM - 1 do // COUNT_ITEM - 1
  begin
    CreateItem(vec2(Int32(Random(round(ScrollBox.ScrolledArea.x))), Int32(Random(round(ScrollBox.ScrolledArea.y)))),
      vec2(100, 100), enm_cl.GetNextColor);      //Random(200), Random(200)
  end;

  enm_cl.Free;
  CountAllItems.Text := 'Count all items: ' + IntToStr(CastomModel.Count);
end;

procedure TBSTestScrollBoxSpaceTree.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  ScrollBox.Resize(Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7);
end;

procedure TBSTestScrollBoxSpaceTree.OnScroll(ScrollingWindow: TBScrolledWindowCustom; const NewPos: TVec2d);
begin
  UpdateBillboard;
end;

function TBSTestScrollBoxSpaceTree.Run: boolean;
{var
  c: TBlackSharkCanvasObject;}
begin
  Result := true;
  //ScrollBox.Resize(300, 300);
  ScrollBox.Resize(Renderer.WindowWidth * 0.7, Renderer.WindowHeight * 0.7);
  //ScrollBox.ScrolledArea := vec2(int64(5000), int64(6000));
  if Controller = nil then
  begin
    GenerateModel;
    Controller := TController.Create(CastomModel, ScrollBox);
    Controller.LoadModel;
  end;
  //ScrollBox.Resize(Scene.WindowWidth-100, Scene.WindowHeight-100);
  //c := ScrollBox.Factory.Rectangle(ScrollBox, 150, 80, 0, 0, true, ScrollBox.ClipObject);
  {c := ScrollBox.Factory.Circle(ScrollBox, 150, vec2(300, 300), true);
  c.Data.StencilTest := true;
  c.Layer2d := 10;
  c.Parent := ScrollBox.OwnerInstances;
  c.Color := BS_CL_TEAL;
  // c.Position2d := vec2(300, 300);
  c := ScrollBox.Factory.RoundRect(ScrollBox, vec2(100, 200), vec2(300, 500), true, ScrollBox.OwnerInstances);
  c.Data.StencilTest := true;
  c.Layer2d := 15;
  c.Parent := ScrollBox.OwnerInstances;
  c.Color := BS_CL_PURPLE;
  c := ScrollBox.Factory.Circle(ScrollBox, 40, vec2(100, 100), true);
  c.Data.StencilTest := true;
  c.Layer2d := 10;
  c.Parent := ScrollBox.OwnerInstances;
  c.Color := BS_CL_RED;  }
  UpdateBillboard;
end;

class function TBSTestScrollBoxSpaceTree.TestName: string;
begin
  Result := 'Test a space tree (by default the RTree)';
end;

procedure TBSTestScrollBoxSpaceTree.UpdateBillboard;
begin
  CountVisibleItems.Text := 'Count visible items: ' +IntToStr(ScrollBox.SpaceTree.VisibleData.Count);
  CountHideItems.Text := 'Count hide items: ' + IntToStr(CastomModel.Count - ScrollBox.SpaceTree.VisibleData.Count);
  {$ifdef DEBUG_BS}
  CountNodes.Text := 'Count visible nodes: ' + IntToStr(ScrollBox.SpaceTree.VisibleNodes.Count);
  {$endif}
end;

{ TBSTestScrollBoxSpaceTree.TController }

constructor TBSTestScrollBoxSpaceTree.TController.Create(AModel: TModel;
  AViewer: TBScrollBox);
begin
  FModel := AModel;
  FViewer := AViewer;
  OnDropObsrs := BObserversGroup<BDragDropData>.Create(GUIThread, OnDrop);
  //FViewer.OnChangePosition := OnScroll;
  Cache := TListVec<PVisualData>.Create;
  CacheWithCO := TListVec<PVisualData>.Create;
  FViewer.SpaceTree.OnShowUserData := OnShowData;
  FViewer.SpaceTree.OnHideUserData := OnHideData;
  FViewer.SpaceTree.OnUpdatePositionUserData := OnUpdatePositionUserData;
  {$ifdef DEBUG_BS}
  FViewer.SpaceTree.OnShowNoLeafNode := OnShowNoLeafNode;
  FViewer.SpaceTree.OnHideNoLeafNode := OnHideNoLeafNode;
  FViewer.SpaceTree.OnUpdatePositionNoLeafNode := OnUpdatePositionNoLeafNode;
  FViewer.SpaceTree.OnChangeSizeNoLeafNode := OnChangeSizeNoLeafNode;
  {$endif}
  VisualizerBB := TBoundingBoxVisualizer.Create(FViewer.Canvas.Renderer.Scene);
  Colors := TColorEnumerator.Create([bsGray]);
  AllVisualData := TListVec<PVisualData>.Create;
end;

destructor TBSTestScrollBoxSpaceTree.TController.Destroy;
var
  i: int32;
begin
  FViewer.SpaceTree.Clear;
  for i := 0 to CacheWithCO.Count - 1 do
    dispose(CacheWithCO.Items[i]);
  CacheWithCO.Free;
  { And again, Im don't push PVisualData to Cache when hides no leaf nodes (as must be)
    in order save a color nodes and to discover the same node, that is why
    Im save all PVisualData in AllVisualData and free all from him (see below)
     }
  //for i := 0 to Cache.Count - 1 do
  //  dispose(Cache.Items[i]);
  for i := 0 to AllVisualData.Count - 1 do
    dispose(AllVisualData.Items[i]);
  { so, VisualizerBB uses FViewer.ClipObject.Data as Parent for present and hold
    no Leaf BB nodes, that is why in begining free him }
  VisualizerBB.Free;
  if OnDropObsrs.CountObservers > 0 then
    raise Exception.Create('OnDropObsrs.CountObservers muse be 0!');
  OnDropObsrs.Free;
  FViewer.Destroy;
  Cache.Free;
  AllVisualData.Free;
  Colors.Free;
  inherited;
end;

function TBSTestScrollBoxSpaceTree.TController.GetVisualData(ForMe: PCustomModelData): PVisualData;
begin
  if CacheWithCO.Count > 0 then
  begin
    Result := CacheWithCO.Pop;
    Result.Present.Data.Hidden := false;
    Result.Present.Position2d := ForMe.Rect.Position; //  - vec2(int32(FViewer.Position.x), int32(FViewer.Position.y))
    //VisualizerBB.Update(ForMe.NodeInSpaceTree.BB, Result.LinesBB);
  end else
  begin
    new(Result);
    Result.Present := TRectangle.Create(FViewer.Canvas, FViewer.OwnerInstances); // - vec2(int32(FViewer.Position.x), int32(FViewer.Position.y))
    Result.Present.Fill := true;
    Result.Present.Data.StaticObject := true;
    Result.Present.Data.StencilTest := true;
    Result.OnDropObsr := nil;
    Result.Present.Layer2d := random(round(FViewer.ScrollBarHor.MainBody.Layer2d - 1));
    //Result.LinesBB := VisualizerBB.Add(ForMe.NodeInSpaceTree.BB, BS_CL_WHITE, Result.Present.Data);
  end;
  Result.OnDropObsr := OnDropObsrs.CreateObserver(Result.Present.Data.EventDrop);
  Result.Present.Size := ForMe.Rect.Size;
  Result.Present.Build;
  Result.Present.Position2d := Forme.Rect.Position;
  Result.Present.Data.TagPtr := ForMe;
  Result.Present.Color := ForMe.Color;
  ForMe.VisualData := Result;
  //Result.TagPtr :=
end;

procedure TBSTestScrollBoxSpaceTree.TController.LoadModel;
var
  i: int32;
  item: PCustomModelData;
  //box: TBox3f;
begin
  for i := 0 to FModel.Count - 1 do
  begin
    item := FModel.Items[i];
    //box := Box3(vec3(item.Rect.X, item.Rect.Y, 0.0), vec3(item.Rect.X + item.Rect.Width, item.Rect.Y + item.Rect.Height, 0.0));
    //box := Box3(FViewer.ClipObject.GetInSelf3d(item.Rect.X, item.Rect.Y),
    //  FViewer.ClipObject.GetInSelf3d(item.Rect.X + item.Rect.Width, item.Rect.Y + item.Rect.Height));
    FViewer.DataAdd(item, item.Rect, item.NodeInSpaceTree);
  end;
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnShowData(Node: PNodeSpaceTree);
begin
  GetVisualData(PCustomModelData(Node.BB.TagPtr));
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnHideData(Node: PNodeSpaceTree);
var
  item: PCustomModelData;
begin
  item := Node.BB.TagPtr;
  OnDropObsrs.RemoveObserver(item.VisualData.OnDropObsr);
  Item.VisualData.Present.Data.Hidden := true;
  //Item.VisualData.LinesBB.Item.Lines.Hide := true;
  CacheWithCO.Add(Item.VisualData);
end;

{$ifdef DEBUG_BS}

function TBSTestScrollBoxSpaceTree.TController.GetVisualData(Node: PNodeSpaceTree): PVisualData;
begin
  if Cache.Count > 0 then
  begin
    Result := Cache.Pop;
    VisualizerBB.Update(BB2dTo3d(TBox3f(Node.BB)), Result.LinesBB);
  end else
  begin
    new(Result);
    Result.LinesBB := VisualizerBB.Add(BB2dTo3d(TBox3f(Node.BB)), BS_CL_RED, FViewer.ClipObject.Data);
    Result.LinesBB.Item.Lines.Color := Colors.GetNextColor;
    Result.OnDropObsr := nil;
    AllVisualData.Add(Result);
  end;
  Result.LinesBB.Item.Lines.Position := FViewer.ClipObject.Get3dPositionInsideSelf(
    (Node.BB.x_mid) - FViewer.Position.x,  // / FViewer.BSConfig.VoxelSize
    (Node.BB.y_mid) - FViewer.Position.y); // / FViewer.BSConfig.VoxelSize
  Node.BB.TagPtr := Result;
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnShowNoLeafNode(Node: PNodeSpaceTree);
begin
  GetVisualData(Node);
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnHideNoLeafNode(
  Node: PNodeSpaceTree);
var
  item: PVisualData;
begin
  item := Node.BB.TagPtr;
  OnDropObsrs.RemoveObserver(item.OnDropObsr);
  Item.LinesBB.Item.Lines.Hidden := true;
  { for MVC template we must that do (append to Cache when a node hides), but Im
    whant to see the same color for every a node, that is why leave PVisualData
    for every no leaf nodes }
  Cache.Add(Item);
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnChangeSizeNoLeafNode(
  Node: PNodeSpaceTree);
var
  item: PVisualData;
begin
  item := Node.BB.TagPtr;
  VisualizerBB.Update(BB2dTo3d(TBox3f(Node.BB)), item.LinesBB);
  item.LinesBB.Item.Lines.Position := FViewer.ClipObject.Get3dPositionInsideSelf(
    (Node.BB.x_mid) - FViewer.Position.x, // /FViewer.BSConfig.VoxelSize
    (Node.BB.y_mid) - FViewer.Position.y); // /FViewer.BSConfig.VoxelSize
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnUpdatePositionNoLeafNode(
  Node: PNodeSpaceTree);
var
  item: PVisualData;
begin
  item := Node.BB.TagPtr;
  item.LinesBB.Item.Lines.Position := FViewer.ClipObject.Get3dPositionInsideSelf(
    (Node.BB.x_mid) - FViewer.Position.x,
    (Node.BB.y_mid) - FViewer.Position.y);
end;

function TBSTestScrollBoxSpaceTree.TController.BB2dTo3d(const Box: TBox3f
  ): TBox3f;
begin
  Result.Max := Box.Max * BSConfig.VoxelSize;
  Result.Min := Box.Min * BSConfig.VoxelSize;
  Result.Mid := Box.Mid * BSConfig.VoxelSize;
end;

{$endif}

procedure TBSTestScrollBoxSpaceTree.TController.OnDrop(const data: BDragDropData);
var
  md: PCustomModelData;
begin
  md := PGraphicInstance(data.BaseHeader.Instance).Owner.TagPtr;
  md.Rect.Position := md.VisualData.Present.Position2d;
  FViewer.DataUpdateRect(md.NodeInSpaceTree, md.Rect);
end;

procedure TBSTestScrollBoxSpaceTree.TController.OnUpdatePositionUserData(Node: PNodeSpaceTree);
var
  item: PCustomModelData;
begin
  item := Node.BB.TagPtr;
  item.VisualData.Present.Position2d := item.Rect.Position; //  - vec2(int32(FViewer.Position.x), int32(FViewer.Position.y))
end;

{ TBSTestSceneKDTree }

constructor TBSTestSceneKDTree.Create(ARenderer: TBlackSharkRenderer);
var
  p_txt: TRectangle;
begin
  inherited;
  Allow3dManipulationByMouse := true;
  AllowMoveCameraByKeyboard := true;
  ARenderer.Frustum.DistanceFarPlane := 90;
  ARenderer.Frustum.Position := vec3(0.0, 0.0, 5.0);
  chbDrawLines := TBCheckBox.Create(ARenderer);
  chbDrawLines.Canvas.Font.SizeInPixels := 12;
  chbDrawLines.OnCheck := OnClickDrawLines;
  chbDrawLines.Text := 'Draw KD-tree';

  EventUpdate := CreateAniFloatLinear(GUIThread);
  EventUpdate.StartValue := 0.0;
  EventUpdate.StopValue := 1.0;
  EventUpdate.Duration := 1000;
  EventUpdate.Loop := true;
  EventUpdate.LoopInverse := true;
  { for max interpolate }
  EventUpdate.IntervalUpdate := 0;
  EventUpdateObserver := CreateAniFloatLivearObsrv(EventUpdate, OnUpdate);

  Axex := TGraphicObjectAxises.Create(Self, nil, Renderer.Scene);
  Axex.AxelX.SceneSpaceTreeClient := true;
  Axex.AxelY.SceneSpaceTreeClient := true;
  Axex.AxelZ.SceneSpaceTreeClient := true;

  Billboard := TBCanvas.Create(Renderer, Self);
  Billboard.Font.SizeInPixels := 10;
  BillboardPanel := TRectangle.Create(Billboard, nil);
  BillboardPanel.Fill := true;
  BillboardPanel.Size := vec2(250, 122);
  BillboardPanel.Color := BS_CL_MSVS_PANEL;
  BillboardPanel.Build;
  BillboardPanel.Position2d := vec2(10, 10);
  BillboardPanel.Data.Caption := 'BillboardPanel';

  {
  Button := TBButton.Create(ARenderer);
  Button.Resize(160, Button.Height);
  Button.BorderColor := TGuiColors.Skyblue;
  Button.Color := TGuiColors.Skyblue;
  Button.Caption := 'Run/Stop a moving';
  Button.Position2d := vec2(BillboardPanel.Position2d.x, BillboardPanel.Position2d.y + BillboardPanel.Height + 10);
  }
  chbMoveObjects := TBCheckBox.Create(ARenderer);
  chbMoveObjects.Canvas.Font.SizeInPixels := 12;
  chbMoveObjects.Text := 'Motion of objects';
  chbMoveObjects.Position2d := vec2(BillboardPanel.Position2d.x, BillboardPanel.Position2d.y + BillboardPanel.Height + 10);
  chbMoveObjects.OnCheck := OnMoveObjectsClick;

  chbDrawLines.Position2d := vec2(chbMoveObjects.Position2d.x, chbMoveObjects.Position2d.y + chbMoveObjects.Height + 5);

  p_txt := TRectangle.Create(Billboard, BillboardPanel);
  p_txt.Color := BS_CL_ORANGE_2;
  p_txt.Size := BillboardPanel.Size;
  p_txt.Build;
  p_txt.Position2d := vec2(0, 0);

  CountAllItems := TCanvasText.Create(Billboard, p_txt);    //
  CountAllItems.Text := 'Count all items: 0';
  CountAllItems.Data.Interactive := false;
  CountAllItems.Position2d := vec2(10, 10);
  CountAllItems.Data.Caption := 'CountAllItems';
  CountVisibleItems := TCanvasText.Create(Billboard, p_txt);
  CountVisibleItems.Text := 'Count visible items: 0';
  CountVisibleItems.Data.Interactive := false;
  CountVisibleItems.Position2d := vec2(10, 27);
  CountHideItems := TCanvasText.Create(Billboard, p_txt);
  CountHideItems.Text := 'Count hide items: 0';
  CountHideItems.Data.Interactive := false;
  CountHideItems.Position2d := vec2(10, 44);
  CountNodes := TCanvasText.Create(Billboard, p_txt);
  CountNodes.Text := 'Count nodes: 0';
  CountNodes.Data.Interactive := false;
  CountNodes.Position2d := vec2(10, 61);
  FPS := TCanvasText.Create(Billboard, p_txt);
  FPS.Text := 'FPS: 0';
  FPS.Data.Interactive := false;
  FPS.Position2d := vec2(10, 78);

  CountAllItems.Layer2d := 3;
  CountVisibleItems.Layer2d := 3;
  CountHideItems.Layer2d := 3;
  CountNodes.Layer2d := 3;
  FPS.Layer2d := 3;

  Lines := TGraphicObjectLines.Create(Self, nil, Renderer.Scene);
  Lines.Caption := 'Lines';
  Lines.SceneSpaceTreeClient := true;
  Lines.Interactive := false;
  Lines.DrawAsTransparent := true;

  ViewPortPos := TCanvasText.Create(Billboard, p_txt);
  ViewPortPos.Text := 'Camera: x:0; y:0; z:0;';
  ViewPortPos.Position2d := vec2(10, 95);
  CreateHelpPanel;

  Directions := TListVec<TVec3f>.Create;
  Velosity := TListVec<BSFloat>.Create;
end;

procedure TBSTestSceneKDTree.CreateHelpPanel;
var
  HelpPanel: TRectangle;

  procedure CreateButton(const Text: string; const Position: TVec2f);
  var
    frame: TRectangle;
    txt: TCanvasText;
  begin
    frame := TRectangle.Create(Billboard, HelpPanel);
    frame.Size := vec2(20.0, 20.0);
    frame.Fill := false;
    frame.Build;
    frame.Position2d := Position;
    frame.Data.Interactive := false;
    txt := TCanvasText.Create(Billboard, frame);
    txt.Text := Text;
    txt.ToParentCenter;
  end;

var
  frame: TRectangle;
  txt: TCanvasText;

begin
  HelpPanel := TRectangle.Create(Billboard, nil);
  HelpPanel.Fill := true;
  HelpPanel.Size := vec2(BillboardPanel.Width, 80.0);
  HelpPanel.Color := BS_CL_BLUE;
  HelpPanel.Data.Opacity := 0.1;
  HelpPanel.Build;
  //HelpPanel.Position2d := vec2(chbDrawLines.Position2d.x, chbDrawLines.Position2d.y+chbDrawLines.Height+10);
  HelpPanel.Position2d := vec2(BillboardPanel.Position2d.x+BillboardPanel.Width+10, BillboardPanel.Position2d.y);
  frame := TRectangle.Create(Billboard, HelpPanel);
  frame.Size := HelpPanel.Size;
  frame.Fill := false;
  frame.Color := BS_CL_SKY_BLUE;
  frame.Build;
  frame.Position2d := vec2(0.0, 0.0);

  CreateButton('A', vec2(20, 45));
  CreateButton('W', vec2(45, 20));
  CreateButton('S', vec2(45, 45));
  CreateButton('D', vec2(70, 45));

  txt := TCanvasText.Create(Billboard, HelpPanel);
  txt.Text := 'Move camera:';
  txt.Position2d := vec2(5.0, 3.0);

  CreateButton('←', vec2(135, 45));
  CreateButton('↑', vec2(160, 20));
  CreateButton('↓', vec2(160, 45));
  CreateButton('→', vec2(185, 45));

  txt := TCanvasText.Create(Billboard, HelpPanel);
  txt.Text := 'Rotate camera:';
  txt.Position2d := vec2(120.0, 3.0);
end;

destructor TBSTestSceneKDTree.Destroy;
begin
  EventUpdate.Stop;
  EventUpdateObserver := nil;
  chbMoveObjects.Free;
  chbDrawLines.Free;
  Billboard.Free;
  Proto.Free;
  Axex.Free;
  Lines.Free;
  Directions.Free;
  Velosity.Free;
  inherited;
end;

{$ifdef DEBUG_ST}
procedure TBSTestSceneKDTree.DrawAlreadyExistNodes;
var
  Stack: TListVec<int32>;
  node, left, right: int32;
  box: PBoxMinMax;
  dimension: int32;
  boundary: double;
begin
  if not chbDrawLines.IsChecked then
    exit;
  Stack := TListVec<int32>.Create;
  Stack.Add(Renderer.Scene.Root);

  while Stack.Count > 0 do
  begin
    node := Stack.Pop;
    Renderer.Scene.GetNodeAttributes(node, box, dimension, boundary, left, right);
    if left >= 0 then
      Stack.Add(left);
    if right >= 0 then
      Stack.Add(right);
    if (left >= 0) and (right >= 0) then
      OnSplitNode(dimension, box, boundary);
  end;

  Stack.Free;
end;
{$endif}

procedure TBSTestSceneKDTree.DrawKDNodes;
begin
  Lines.Clear;
  Lines.BeginUpdate;
  {$ifdef DEBUG_ST}
  DrawAlreadyExistNodes;
  {$endif}
  Lines.EndUpdate(false);
end;

procedure TBSTestSceneKDTree.GenerateScene;
var
  i: int32;
  h: BSFloat;
  delta_boudary: int32;
  dir: TVec3f;
  vel: BSFloat;
begin
  if chbDrawLines.IsChecked then
    Lines.BeginUpdate;
  try
    {$ifdef DEBUG_ST}
    DrawAlreadyExistNodes;
    if chbDrawLines.IsChecked then
      Renderer.Scene.OnSplitDimension := OnSplitNode;
    {$endif}
    Proto := TColoredVertexes.Create(Self, nil, Renderer.Scene);
    Proto.Color := BS_CL_ORANGE;
    Proto.DragResolve := true;
    Proto.SceneSpaceTreeClient := true;
    Proto.Caption := 'Proto';
    //TBlackSharkFactoryShapesP.GenerateSphere(Proto.Mesh, 20, 0.2);
    TBlackSharkFactoryShapesP.GenerateCube(Proto.Mesh, vec3(0.6, 0.6, 0.6));
    //TBlackSharkFactoryShapesP.GenerateCylinder(Proto.Mesh, 0.1, 20, 0.2);
    Proto.ChangedMesh;
    Proto.Position := vec3(1.0, 1.0, -3.0);
    delta_boudary := WORLD_BOUNDARY_MAX - WORLD_BOUNDARY_MIN;
    h := delta_boudary / 2;
    for i := 0 to COUNT_OBJECTS - 2 do
    begin
      Proto.AddInstance(vec3(random(delta_boudary)-h, random(delta_boudary)-h, random(delta_boudary)-h));
      dir := VecNormalize(vec3((Random(1000)/1000 - 0.5)/0.5, (Random(1000)/1000 - 0.5)/0.5, (Random(1000)/1000 - 0.5)/0.5));
      Directions.Add(dir);
      vel := 0;
      while vel = 0 do
        vel := (Random(1000)/1000)*0.2;
      Velosity.Add(vel);
    end;
  finally
    if chbDrawLines.IsChecked then
      Lines.EndUpdate;
    {$ifdef DEBUG_ST}
    Renderer.Scene.OnSplitDimension := nil;
    {$endif}
  end;
end;

procedure TBSTestSceneKDTree.OnMoveObjectsClick(ASender: TObject);
begin
  if chbMoveObjects.IsChecked then
  begin
    if not EventUpdate.IsRun then
      EventUpdate.Run;
  end else
  begin
    if EventUpdate.IsRun then
      EventUpdate.Stop;
  end;
end;

procedure TBSTestSceneKDTree.OnClickDrawLines(ASender: TObject);
begin
  Lines.Clear;
  if chbDrawLines.IsChecked then
    DrawKDNodes;
end;

procedure TBSTestSceneKDTree.OnMoveCamera(const Data: BData);
begin
  inherited;
  UpdateBillboard;
end;

procedure TBSTestSceneKDTree.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited;
  UpdateBillboard;
end;

procedure TBSTestSceneKDTree.OnSplitNode(ADem: int32; AVectorMinMax: PBoxMinMax; ABoundary: double);
var
  min: TVec3f;
  max: TVec3f;
begin
  // we can put only 65536 indexes (32768 lines - one line consist of two vertexes and two indexes)
  // in mesh, because of it are keeping array of TGraphicObjectLines
  {
  it is in past, because of buffer of indexes switch to 32-bit format itself automatically now

  if Lines[CurrentLines].CountLines > 32756 then
  begin
    inc(CurrentLines);
    if CurrentLines = length(Lines) then
      IncCountLineContainers;
  end;  }

  min.x := bs.math.Max(AVectorMinMax^[0], WORLD_BOUNDARY_MIN);
  min.y := bs.math.Max(AVectorMinMax^[1], WORLD_BOUNDARY_MIN);
  min.z := bs.math.Max(AVectorMinMax^[2], WORLD_BOUNDARY_MIN);
  max.x := bs.math.Min(AVectorMinMax^[3], WORLD_BOUNDARY_MAX);
  max.y := bs.math.Min(AVectorMinMax^[4], WORLD_BOUNDARY_MAX);
  max.z := bs.math.Min(AVectorMinMax^[5], WORLD_BOUNDARY_MAX);

  if (max.x - min.x <= EPSILON) and (max.y - min.y <= EPSILON) and (max.z - min.z <= EPSILON) then
    exit;

  case ADem of
    0: begin //x
      Lines.Line(vec3(ABoundary, min.y, max.z), vec3(ABoundary, max.y, max.z));
      Lines.Line(vec3(ABoundary, max.y, max.z), vec3(ABoundary, max.y, min.z));
      Lines.Line(vec3(ABoundary, max.y, min.z), vec3(ABoundary, min.y, min.z));
      Lines.Line(vec3(ABoundary, min.y, min.z), vec3(ABoundary, min.y, max.z));
    end;
    1: begin //y
      Lines.Line(vec3(min.x, ABoundary, max.z), vec3(max.x, ABoundary, max.z));
      Lines.Line(vec3(max.x, ABoundary, max.z), vec3(max.x, ABoundary, min.z));
      Lines.Line(vec3(max.x, ABoundary, min.z), vec3(min.x, ABoundary, min.z));
      Lines.Line(vec3(min.x, ABoundary, min.z), vec3(min.x, ABoundary, max.z));
    end;
    2: begin //z
      Lines.Line(vec3(min.x, max.y, ABoundary), vec3(max.x, max.y, ABoundary));
      Lines.Line(vec3(max.x, max.y, ABoundary), vec3(max.x, min.y, ABoundary));
      Lines.Line(vec3(max.x, min.y, ABoundary), vec3(min.x, min.y, ABoundary));
      Lines.Line(vec3(min.x, min.y, ABoundary), vec3(min.x, max.y, ABoundary));
    end;
  end;
end;

procedure TBSTestSceneKDTree.OnUpdate(const AValue: BSFloat);
var
  pos: TVec3f;
  dir: TVec3f;
  vel: BSFloat;
  i: int32;
  instance: PGraphicInstance;
  changed_dir: boolean;
begin
  // if count instances are 1, then Proto.Instances is not valid, because
  // one instance is contained in Proto.BaseInstance
  if not Assigned(Proto) or not Assigned(Proto.Instances) then
    exit;
  Proto.Instances.Cursor := 0;
  for i := 0 to Proto.CountInstances - 2 do
  begin
    Proto.Instances.Cursor := i;
    instance := Proto.Instances.UnderCursorItem.Item;
    vel := Velosity.Items[i];
    dir := Directions.Items[i];
    pos := vec3(instance.Position.x + (vel * dir.x), instance.Position.y + (vel * dir.y), instance.Position.z + (vel * dir.z));
    changed_dir := false;
    if pos.x < WORLD_BOUNDARY_MIN then
    begin
      pos.x := WORLD_BOUNDARY_MIN;
      dir.x := -dir.x;
      changed_dir := true;
    end else
    if pos.x > WORLD_BOUNDARY_MAX then
    begin
      pos.x := WORLD_BOUNDARY_MAX;
      dir.x := -dir.x;
      changed_dir := true;
    end;

    if pos.y < WORLD_BOUNDARY_MIN then
    begin
      pos.y := WORLD_BOUNDARY_MIN;
      dir.y := -dir.y;
      changed_dir := true;
    end else
    if pos.y > WORLD_BOUNDARY_MAX then
    begin
      pos.y := WORLD_BOUNDARY_MAX;
      dir.y := -dir.y;
      changed_dir := true;
    end;

    if pos.z < WORLD_BOUNDARY_MIN then
    begin
      pos.z := WORLD_BOUNDARY_MIN;
      dir.z := -dir.z;
      changed_dir := true;
    end else
    if pos.z > WORLD_BOUNDARY_MAX then
    begin
      pos.z := WORLD_BOUNDARY_MAX;
      dir.z := -dir.z;
      changed_dir := true;
    end;

    if changed_dir then
      Directions.Items[i] := dir;

    Proto.SetPositionInstance(instance, pos);
  end;
  UpdateBillboard;
end;

function TBSTestSceneKDTree.Run: boolean;
begin
  Result := true;
  GenerateScene;
  UpdateBillboard;
end;

class function TBSTestSceneKDTree.TestName: string;
begin
  Result := 'Test of scene KD-tree';
end;

procedure TBSTestSceneKDTree.UpdateBillboard;
begin
  if ((TBTimer.CurrentTime.Low - LastTime < 1000) and EventUpdate.IsRun) or not Assigned(chbDrawLines) then
    exit;

  if chbDrawLines.IsChecked and EventUpdate.IsRun then
    DrawKDNodes;

  LastTime := TBTimer.CurrentTime.Low;

  if not Assigned(CountAllItems) then
    exit;
  //it := Renderer.Instances.Items[CountAllItems.Data.BaseInstance.Index];
  CountAllItems.Text := 'Count all items: ' + IntToStr(Renderer.Scene.Count);
  CountVisibleItems.Text := 'Count visible items: ' + IntToStr(Renderer.CountVisibleInstancesInSpaceTree);
  CountHideItems.Text := 'Count hide items: ' + IntToStr(Renderer.Scene.Count - Renderer.CountVisibleInstancesInSpaceTree);
  CountNodes.Text := 'Count nodes: ' + IntToStr(Renderer.Scene.Nodes);
  FPS.Text := 'FPS: ' + IntToStr(Renderer.FPS);
  ViewPortPos.Text := 'Viewport pos: x:' + IntToStr(round(Renderer.Frustum.Position.x)) + '; y:' +
    IntToStr(round(Renderer.Frustum.Position.y)) + '; z:' + IntToStr(round(Renderer.Frustum.Position.z)) + ';';
end;

initialization

  RegisterTest(TBSTestScrollBoxSpaceTree);
  RegisterTest(TBSTestSceneKDTree);

end.
