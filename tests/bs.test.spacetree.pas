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
  , bs.geometry.kdtree
  , bs.gui.scrollbox
  , bs.gui.forms
  , bs.gui.buttons
  , bs.gui.checkbox
  , bs.gui.hint
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
//      COUNT_OBJECTS = 2;
//      WORLD_BOUNDARY_MAX =  30;
//      WORLD_BOUNDARY_MIN = -30;
      COUNT_OBJECTS = 1000000;
      WORLD_BOUNDARY_MAX =  600;
      WORLD_BOUNDARY_MIN = -600;
//
  private
    Billboard: TBCanvas;
    BillboardPanel: TRectangle;
    CountVisibleItems: TCanvasText;
    CountHideItems: TCanvasText;
    CountNodes: TCanvasText;
    CountAllItems: TCanvasText;
    CountSelectIter: TCanvasText;
    LastCountSelectedByKDTree: TCanvasText;
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
    procedure OnSplitNode(ADem: int32; ABox: PKDMinMax; ABoundary: double);
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

  { TBSTestKDTreeIn2d }

  TBSTestKDTreeIn2d = class(TBSTest)
  private
    const
      csCountPrimitives = 1000;
      csCountStreenInMap = 10;
  private
    Canvas: TBCanvas;
    ViewPort2d: TTrapeze;
    ViewPortAnimRotate: IBAnimationLinearFloat;
    ViewPortAnimRotateObserver: IBAnimationLinearFloatObsrv;
    ViewPortAnimMove: IBAnimationLinearFloat;
    ViewPortAnimMoveObserver: IBAnimationLinearFloatObsrv;
    ViewPortMoveDir: TVec2f;
    RootMapCanvasObject: TRectangle;

    DebugText: TCanvasText;
    procedure GenerateScene;
    procedure GenerateViewport;
    procedure DoSetRenderViewPortPos;
    procedure DoSetCanvasObjecPosition(ACanvasObject: TCanvasObject);
  protected
    procedure OnResizeViewport({%H-}const Data: BResizeEventData); override;
    procedure OnKeyDown({%H-}const Data: BKeyData); override;
    procedure OnKeyUp({%H-}const Data: BKeyData); override;
    procedure OnRotateViewPort(const AValue: BSFloat); virtual;
    procedure OnMoveViewPort(const AValue: BSFloat); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

  { TBSTestKDTreeIn1d }

  TBSTestKDTreeIn1d = class(TBSTest)
  private
    const
      csCountPrimitives = 100;
      csCountScreensInMap = 2;
  private
    Tree1d: TIntervalsTree;
    Canvas: TBCanvas;
    CanvasBillboard: TBCanvas;
    FMap1d: TLine;
    FViewPort1d: TLine;
    ViewPortAnimMove: IBAnimationLinearFloat;
    ViewPortAnimMoveObserver: IBAnimationLinearFloatObsrv;
    ListResult: TListVec<Pointer>;
    OriginalColors: THashTable<Pointer, TColor4f>;
    Hint: TBlackSharkHint;
    HintPosViewport: TBlackSharkHint;
    Selected: TCanvasText;

    btnSelect: TBButton;

    BtnSelectClickObserver: IBMouseEventObserver;
    MObjectEnterGroup: BObserversGroup<BMouseData>;
    MObjectLeaveGroup: BObserversGroup<BMouseData>;

    procedure DoSetRenderViewPortPos;
    function DoSetCanvasObjecPosition: TVec2f;
    procedure OnMoveViewPort(const AValue: BSFloat);
    procedure GenerateObjects;
    procedure SelectObjects;
    procedure UpdateViewportHint;
    procedure OnMouseObjectEnter(const AData: BMouseData);
    procedure OnMouseObjectLeave(const AData: BMouseData);
    procedure OnClickButtonSelect(const AData: BMouseData);
  protected
    procedure OnKeyDown({%H-}const Data: BKeyData); override;
    procedure OnKeyUp({%H-}const Data: BKeyData); override;
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
  , bs.align
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
    CreateItem(vec2(Int32(Random(ScrollBox.ScrolledArea.x)), Int32(Random(ScrollBox.ScrolledArea.y))),
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
  //ARenderer.Frustum.OrthogonalProjection := true;
  Allow3dManipulationByMouse := true;
  AllowMoveCameraByKeyboard := true;
  ARenderer.Frustum.DistanceFarPlane := 50;
  ARenderer.Frustum.Position := vec3(0.0, 0.0, 5.0);
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
  //Axex.AxelX.SceneSpaceTreeClient := true;
  //Axex.AxelY.SceneSpaceTreeClient := true;
  //Axex.AxelZ.SceneSpaceTreeClient := true;

  Billboard := TBCanvas.Create(Renderer, Self);
  Billboard.OrthogonalProjection := true;
  Billboard.Font.SizeInPixels := 10;
  BillboardPanel := TRectangle.Create(Billboard, nil);
  BillboardPanel.Fill := true;
  BillboardPanel.Size := vec2(250.0, 157.0);
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
  chbMoveObjects := TBCheckBox.Create(Billboard);
  chbMoveObjects.Canvas.Font.SizeInPixels := 12;
  chbMoveObjects.Text := 'Motion of objects';
  chbMoveObjects.Position2d := vec2(BillboardPanel.Position2d.x, BillboardPanel.Position2d.y + BillboardPanel.Height + 10);
  chbMoveObjects.OnCheck := OnMoveObjectsClick;

  chbDrawLines := TBCheckBox.Create(Billboard);
  chbDrawLines.Canvas.Font.SizeInPixels := 12;
  chbDrawLines.OnCheck := OnClickDrawLines;
  chbDrawLines.Text := 'Draw KD-tree';
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
  LastCountSelectedByKDTree := TCanvasText.Create(Billboard, p_txt);
  LastCountSelectedByKDTree.Text := 'Count selected by tree: 0';
  LastCountSelectedByKDTree.Data.Interactive := false;
  LastCountSelectedByKDTree.Position2d := vec2(10, 78);
  FPS := TCanvasText.Create(Billboard, p_txt);
  FPS.Text := 'FPS: 0';
  FPS.Data.Interactive := false;
  FPS.Position2d := vec2(10, 95);
  ViewPortPos := TCanvasText.Create(Billboard, p_txt);
  ViewPortPos.Text := 'Camera: x:0; y:0; z:0;';
  ViewPortPos.Position2d := vec2(10, 112);
  CountSelectIter := TCanvasText.Create(Billboard, p_txt);
  CountSelectIter.Text := 'Select iterations: 0';
  CountSelectIter.Data.Interactive := false;
  CountSelectIter.Position2d := vec2(10, 129);


  CountAllItems.Layer2d := 3;
  CountVisibleItems.Layer2d := 3;
  CountHideItems.Layer2d := 3;
  CountNodes.Layer2d := 3;
  FPS.Layer2d := 3;

  Lines := TGraphicObjectLines.Create(Self, nil, Renderer.Scene);
  Lines.Caption := 'Lines';
  //Lines.SceneSpaceTreeClient := true;
  Lines.Interactive := false;
  Lines.DrawAsTransparent := true;

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
  box: PKDMinMax;
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
  Lines.Position := vec3(0.0, 0.0, 0.0);
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

procedure TBSTestSceneKDTree.OnSplitNode(ADem: int32; ABox: PKDMinMax; ABoundary: double);
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


  min.x := bs.math.Max(ABox^[0], WORLD_BOUNDARY_MIN);
  min.y := bs.math.Max(ABox^[1], WORLD_BOUNDARY_MIN);
  min.z := bs.math.Max(ABox^[2], WORLD_BOUNDARY_MIN);
  max.x := bs.math.Min(ABox^[3], WORLD_BOUNDARY_MAX);
  max.y := bs.math.Min(ABox^[4], WORLD_BOUNDARY_MAX);
  max.z := bs.math.Min(ABox^[5], WORLD_BOUNDARY_MAX);
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
//  case ADem of
//    0: begin //x
//      Lines.Line(vec3(ABoundary, bs.math.Max(ABox^[1], WORLD_BOUNDARY_MIN), bs.math.Max(ABox^[2], WORLD_BOUNDARY_MAX)),
//        vec3(ABoundary, bs.math.Min(ABox^[4], WORLD_BOUNDARY_MAX), bs.math.Min(ABox^[5], WORLD_BOUNDARY_MAX)));
//    end;
//    1: begin //y
//      Lines.Line(vec3(bs.math.Max(ABox^[0], WORLD_BOUNDARY_MIN), ABoundary, bs.math.Max(ABox^[2], WORLD_BOUNDARY_MAX)),
//        vec3(bs.math.Min(ABox^[3], WORLD_BOUNDARY_MAX), ABoundary, bs.math.Min(ABox^[5], WORLD_BOUNDARY_MAX)));
//    end;
//    2: begin //z
//      Lines.Line(vec3(bs.math.Max(ABox^[0], WORLD_BOUNDARY_MIN), bs.math.Max(ABox^[2], WORLD_BOUNDARY_MAX), ABoundary),
//        vec3(bs.math.Min(ABox^[3], WORLD_BOUNDARY_MAX), bs.math.Min(ABox^[4], WORLD_BOUNDARY_MAX), ABoundary));
//    end;
//  end;
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
  LastCountSelectedByKDTree.Text := 'Count selected by tree: ' + IntToStr(Renderer.LastCountSelectedByTree);
  FPS.Text := 'FPS: ' + IntToStr(Renderer.FPS);
  ViewPortPos.Text := 'Camera: x:' + IntToStr(round(Renderer.Frustum.Position.x)) + '; y:' +
    IntToStr(round(Renderer.Frustum.Position.y)) + '; z:' + IntToStr(round(Renderer.Frustum.Position.z)) + ';';
  //CountSelectIter.Text := 'Select iterations: ' + IntToStr(Renderer.Scene.SelectIterations);
end;

{ TBSTestKDTreeIn2d }

procedure TBSTestKDTreeIn2d.GenerateScene;

  procedure CreateRectangle(IsFilled: boolean; const Color: TColor4f);
  var
    r: TRectangle;
  begin
    r := TRectangle.Create(Canvas, RootMapCanvasObject);
    r.Size := vec2(max(10.0, random(50)), max(10.0, random(50)));
    r.Fill := IsFilled;
    r.Color := Color;
    DoSetCanvasObjecPosition(r);
    r.Angle := vec3(0.0, 0.0, random(360));
    r.Build;
  end;

  procedure CreateTrapeze(IsFilled: boolean; const Color: TColor4f);
  var
    t: TTrapeze;
  begin
    t := TTrapeze.Create(Canvas, RootMapCanvasObject);
    t.LowerBase := max(30, random(70));
    t.UpperBase := t.LowerBase - 20.0;
    t.HeightBwBases := t.UpperBase;
    t.Fill := IsFilled;
    t.Color := Color;
    DoSetCanvasObjecPosition(t);
    t.Angle := vec3(0.0, 0.0, random(360));
    t.Build;
  end;

  procedure CreateCircule(IsFilled: boolean; const Color: TColor4f);
  var
    c: TCircle;
  begin
    c := TCircle.Create(Canvas, RootMapCanvasObject);
    c.Radius := max(10.0, random(25));
    c.Fill := IsFilled;
    c.Color := Color;
    DoSetCanvasObjecPosition(c);
    c.Build;
  end;

var
  i: Int32;
begin
  RootMapCanvasObject := TRectangle.Create(Canvas, nil);
  RootMapCanvasObject.Fill := True;
  RootMapCanvasObject.Size := vec2(csCountStreenInMap * Canvas.Renderer.WindowWidth, csCountStreenInMap * Canvas.Renderer.WindowHeight);
  RootMapCanvasObject.Color := BS_CL_AQUA;
  RootMapCanvasObject.Data.Opacity := 0.5;
  RootMapCanvasObject.Build;
  RootMapCanvasObject.Position2d := RootMapCanvasObject.Size / -2.0;

  for i := 0 to csCountPrimitives - 1 do
  begin
    case Random(3) of
      0: CreateRectangle(i mod 2 = 0, vec4(random(2), random(2), random(2), 1.0));
      1: CreateTrapeze(i mod 2 = 0, vec4(random(2), random(2), random(2), 1.0));
      2: CreateCircule(i mod 2 = 0, vec4(random(2), random(2), random(2), 1.0));
    end;
  end;
  DebugText := TCanvasText.Create(Canvas, nil);
  DebugText.Position2d := vec2(10, 30);
  DebugText.Text := '0.0';
  DebugText.Color := BS_CL_WHITE;

  GenerateViewport;
  DoSetRenderViewPortPos;
  //Renderer.Render;
end;

procedure TBSTestKDTreeIn2d.GenerateViewport;
begin
  ViewPort2d := TTrapeze.Create(Canvas, RootMapCanvasObject);
  ViewPort2d.LowerBase := 70;
  ViewPort2d.UpperBase := 200;
  ViewPort2d.HeightBwBases := 150;
  ViewPort2d.Fill := false;
  ViewPort2d.WidthLine := 3;
  ViewPort2d.Color := BS_CL_WHITE;
  //ViewPort2d.Angle := vec3(0.0, 0.0, random(360));
  ViewPort2d.Anchors[TAnchor.aTop] := false;
  ViewPort2d.Anchors[TAnchor.aLeft] := false;
  ViewPort2d.Build;
  DoSetCanvasObjecPosition(ViewPort2d);

  ViewPortAnimRotate := CreateAniFloatLinear;
  ViewPortAnimRotate.Duration := 5000;
  ViewPortAnimRotate.Loop := true;
  //ViewPortAnimRotate.LoopInverse := true;
  { for max FPS }
  ViewPortAnimRotate.IntervalUpdate := 0;
  ViewPortAnimRotateObserver := CreateAniFloatLivearObsrv(ViewPortAnimRotate, OnRotateViewPort);

  ViewPortAnimMove := CreateAniFloatLinear;
  ViewPortAnimMove.Duration := 5000;
  ViewPortAnimMove.Loop := true;
  { for max FPS }
  ViewPortAnimMove.IntervalUpdate := 0;
  ViewPortAnimMoveObserver := CreateAniFloatLivearObsrv(ViewPortAnimMove, OnMoveViewPort);

  ViewPortMoveDir := vec2(BS_Sin(ViewPort2d.Angle.z), -BS_Cos(ViewPort2d.Angle.z));

end;

procedure TBSTestKDTreeIn2d.DoSetCanvasObjecPosition(ACanvasObject: TCanvasObject);
begin
  ACanvasObject.Position2d := vec2(random(trunc(RootMapCanvasObject.Width)), random(trunc(RootMapCanvasObject.Height)));
end;

procedure TBSTestKDTreeIn2d.DoSetRenderViewPortPos;
var
  pos: TVec3f;
begin
  pos := ViewPort2d.Data.AbsolutePosition;
  Canvas.Renderer.Frustum.Position := vec3(pos.x, pos.y, Canvas.Renderer.Frustum.Position.z);
end;

procedure TBSTestKDTreeIn2d.OnResizeViewport(const Data: BResizeEventData);
begin
  inherited OnResizeViewport(Data);
end;

procedure TBSTestKDTreeIn2d.OnKeyDown(const Data: BKeyData);
begin
  inherited OnKeyDown(Data);
  if not ViewPortAnimRotate.IsRun then
  begin
    if Data.Key = 37 then
    begin
      ViewPortAnimRotate.StartValue := 360 + ViewPort2d.Angle.z;
      ViewPortAnimRotate.StopValue := ViewPort2d.Angle.z;
      ViewPortAnimRotate.Run;
    end else
    if Data.Key = 39 then
    begin
      ViewPortAnimRotate.StartValue := ViewPort2d.Angle.z;
      ViewPortAnimRotate.StopValue := 360 + ViewPortAnimRotate.StartValue;
      ViewPortAnimRotate.Run;
    end;
  end;
  if not ViewPortAnimMove.IsRun then
  begin
    if Data.Key in [38] then // forward
    begin
      ViewPortAnimMove.StartValue := 1.0;
      ViewPortAnimMove.StopValue := 0;
      ViewPortAnimMove.Run;
    end else
    if Data.Key in [40] then // backward
    begin
      ViewPortAnimMove.StartValue := -1.0;
      ViewPortAnimMove.StopValue := 0;
      ViewPortAnimMove.Run;
    end;
  end;
end;

procedure TBSTestKDTreeIn2d.OnKeyUp(const Data: BKeyData);
begin
  inherited OnKeyUp(Data);
  if (Data.Key in [37, 39]) and ViewPortAnimRotate.IsRun then
    ViewPortAnimRotate.Stop;
  if (Data.Key in [38, 40]) and ViewPortAnimMove.IsRun then
    ViewPortAnimMove.Stop;
end;

procedure TBSTestKDTreeIn2d.OnRotateViewPort(const AValue: BSFloat);
begin
  ViewPort2d.Angle := vec3(0.0, 0.0, AValue);
  ViewPortMoveDir := vec2(BS_Sin(ViewPort2d.Angle.z), -BS_Cos(ViewPort2d.Angle.z));
end;

procedure TBSTestKDTreeIn2d.OnMoveViewPort(const AValue: BSFloat);
const
  SPEED = 10;
begin
  ViewPort2d.Position2d := ViewPort2d.Position2d + ViewPortMoveDir * ViewPortAnimMove.StartValue * SPEED;
  DoSetRenderViewPortPos;
end;

constructor TBSTestKDTreeIn2d.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  Canvas := TBCanvas.Create(Renderer, Self);
  Canvas.StickOnScreen := false;
end;

destructor TBSTestKDTreeIn2d.Destroy;
begin
  Canvas.Free;
  inherited Destroy;
end;

function TBSTestKDTreeIn2d.Run: boolean;
begin
  GenerateScene;
  Result := true;
end;

class function TBSTestKDTreeIn2d.TestName: string;
begin
  Result := 'KDTree test in 2d';
end;

{ TBSTestKDTreeIn1d }

constructor TBSTestKDTreeIn1d.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  Canvas := TBCanvas.Create(Renderer, Self);
  Canvas.StickOnScreen := false;
  CanvasBillboard := TBCanvas.Create(Renderer, Self);
  Tree1d := TIntervalsTree.Create(csCountPrimitives*4);
  ListResult := TListVec<Pointer>.Create;
  OriginalColors := THashTable<Pointer, TColor4f>.Create(GetHashBlackSharkPointer, PtrCmpBool);
  MObjectEnterGroup := BObserversGroup<BMouseData>.Create(OnMouseObjectEnter);
  MObjectLeaveGroup := BObserversGroup<BMouseData>.Create(OnMouseObjectLeave);
  Hint := TBlackSharkHint.Create(Canvas);
  Hint.Text := '';
  HintPosViewport := TBlackSharkHint.Create(CanvasBillboard);
  HintPosViewport.Position2d := vec2(10, 50.0);
  Selected := TCanvasText.Create(CanvasBillboard, nil);
  Selected.Position2d := vec2(10, 100);
  btnSelect := TBButton.Create(CanvasBillboard);
  btnSelect.Position2d := vec2(10, 170);
  btnSelect.Caption := 'Select';
  BtnSelectClickObserver := btnSelect.OnClickEvent.CreateObserver(OnClickButtonSelect);
end;

destructor TBSTestKDTreeIn1d.Destroy;
begin
  MObjectEnterGroup.Free;
  MObjectLeaveGroup.Free;
  Tree1d.Free;
  Canvas.Free;
  CanvasBillboard.Free;
  ListResult.Free;
  OriginalColors.Free;
  inherited Destroy;
end;

function TBSTestKDTreeIn1d.Run: boolean;
begin
  FMap1d := TLine.Create(Canvas, nil);
  FMap1d.Color := BS_CL_AQUA;
  FMap1d.Data.Opacity := 0.0;
  FMap1d.Length := csCountScreensInMap * Canvas.Renderer.WindowHeight;
  FMap1d.WidthLine := 5;
  FMap1d.Build;
  FMap1d.Position2d := vec2(Canvas.Renderer.WindowWidth / 2.0, -(FMap1d.Length - Canvas.Renderer.WindowHeight) / 2.0);
  FViewPort1d := TLine.Create(Canvas, FMap1d);
  FViewPort1d.Length := 200;
  FViewPort1d.WidthLine := 30;
  FViewPort1d.Data.Opacity := 0.2;
  FViewPort1d.Color := BS_CL_RED;
  FViewPort1d.Build;
  FViewPort1d.Position2d := vec2(-(FViewPort1d.WidthLine - FMap1d.WidthLine) / 2.0, (FMap1d.Length - FViewPort1d.Length) / 2.0);

  ViewPortAnimMove := CreateAniFloatLinear;
  ViewPortAnimMove.Duration := 5000;
  ViewPortAnimMove.Loop := true;
  { for max FPS }
  ViewPortAnimMove.IntervalUpdate := 0;
  ViewPortAnimMoveObserver := CreateAniFloatLivearObsrv(ViewPortAnimMove, OnMoveViewPort);

  //ViewPortMoveDir := vec2(BS_Sin(ViewPort2d.Angle.z), -BS_Cos(ViewPort2d.Angle.z));


  //DoSetRenderViewPortPos;
  GenerateObjects;
  SelectObjects;
  UpdateViewportHint;
  Result := true;
end;

procedure TBSTestKDTreeIn1d.DoSetRenderViewPortPos;
var
  pos: TVec3f;
begin
  pos := FViewPort1d.Data.AbsolutePosition;
  Canvas.Renderer.Frustum.Position := vec3(pos.x, pos.y, Canvas.Renderer.Frustum.Position.z);
end;

function TBSTestKDTreeIn1d.DoSetCanvasObjecPosition: TVec2f;
begin
  Result := vec2(0.0, random(trunc(FMap1d.Height)));
end;

procedure TBSTestKDTreeIn1d.OnMoveViewPort(const AValue: BSFloat);
const
  SPEED = 10;
begin

  FViewPort1d.Position2d := FViewPort1d.Position2d + vec2(0.0, ViewPortAnimMove.StartValue * SPEED);
  DoSetRenderViewPortPos;
  SelectObjects;
  UpdateViewportHint;
end;

procedure TBSTestKDTreeIn1d.GenerateObjects;

  procedure CreateLineObject2(len: bsfloat; const Pos: TVec2f; const Color: TColor4f);
  var
    l: TLine;
  begin
    l := TLine.Create(Canvas, FMap1d);
    l.WidthLine := 3.0;
    l.Length := len;
    l.Color := Color;
    l.Build;
    l.Position2d := Pos;//vec2(0.0, random(trunc(FMap1d.Height)));
    MObjectEnterGroup.CreateObserver(l.Data.EventMouseEnter);
    MObjectLeaveGroup.CreateObserver(l.Data.EventMouseLeave);
    l.Data.TagPtr := l;
    l.Data.TagInt := Tree1d.Add(l.Position2d.y, l.Position2d.y + l.Length, l);
    //Tree1d.Add(l.Position2d.y, l.Position2d.y + l.Length, Tree1d);
  end;

  procedure CreateLineObject(const Color: TColor4f);
  begin
    CreateLineObject2(max(10, random(70)), DoSetCanvasObjecPosition, Color);
  end;

//var
//  i: int32;
begin
  Randomize;
  //for i := 0 to csCountPrimitives - 1 do
  //begin
  //  CreateLineObject(vec4(random(2), random(2), random(2), 1.0));
  //end;
  //CreateLineObject2((133.0 - 67.0), vec2(0, 67.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((127.0 - 81), vec2(0, 81.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((515.0 - 470),  vec2(0, 470.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((179.0 - 165),  vec2(0, 165.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((174.0 - 164),  vec2(0, 164.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((107.0 - 62),  vec2(0, 62.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((253.0 - 243),  vec2(0, 243.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((272.0 - 262),  vec2(0, 262.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((550.0 - 493),  vec2(0, 493.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((43.0 - 12),  vec2(0, 12.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((184.0 - 174),  vec2(0, 174.0), vec4(random(2), random(2), random(2), 1.0));
  //CreateLineObject2((397.0 - 373),  vec2(0, 373.0), vec4(random(2), random(2), random(2), 1.0));

  CreateLineObject2(723 - 713, vec2(0, 713), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(795 - 785, vec2(0, 785), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(68 - 31, vec2(0, 31), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(683 - 673, vec2(0, 673), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(689 - 643, vec2(0, 643), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(770 - 726, vec2(0, 726), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(417 - 381, vec2(0, 381), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(73 - 10, vec2(0, 10), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(981 - 936, vec2(0, 936), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(558 - 544, vec2(0, 544), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(632 - 604, vec2(0, 604), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(217 - 182, vec2(0, 182), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(515 - 496, vec2(0, 496), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(716 - 677, vec2(0, 677), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(921 - 911, vec2(0, 911), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1004 - 958, vec2(0, 958), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(397 - 335, vec2(0, 335), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(544 - 482, vec2(0, 482), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(867 - 850, vec2(0, 850), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(260 - 197, vec2(0, 197), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(432 - 386, vec2(0, 386), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(383 - 350, vec2(0, 350), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(317 - 282, vec2(0, 282), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(865 - 806, vec2(0, 806), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1056 - 999, vec2(0, 999), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(459 - 406, vec2(0, 406), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(48 - 26, vec2(0, 26), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(838 - 812, vec2(0, 812), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(951 - 888, vec2(0, 888), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(765 - 755, vec2(0, 755), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(172 - 113, vec2(0, 113), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(804 - 742, vec2(0, 742), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(472 - 451, vec2(0, 451), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(739 - 715, vec2(0, 715), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(967 - 957, vec2(0, 957), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(741 - 676, vec2(0, 676), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(649 - 631, vec2(0, 631), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(81 - 71, vec2(0, 71), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(874 - 820, vec2(0, 820), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(122 - 76, vec2(0, 76), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1009 - 955, vec2(0, 955), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(138 - 111, vec2(0, 111), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(597 - 541, vec2(0, 541), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(581 - 555, vec2(0, 555), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(688 - 652, vec2(0, 652), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(897 - 874, vec2(0, 874), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(981 - 937, vec2(0, 937), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(695 - 654, vec2(0, 654), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(656 - 624, vec2(0, 624), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(751 - 719, vec2(0, 719), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(813 - 803, vec2(0, 803), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(660 - 622, vec2(0, 622), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(958 - 943, vec2(0, 943), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(491 - 436, vec2(0, 436), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(730 - 679, vec2(0, 679), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(753 - 739, vec2(0, 739), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(194 - 184, vec2(0, 184), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(485 - 475, vec2(0, 475), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(169 - 145, vec2(0, 145), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(987 - 926, vec2(0, 926), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(443 - 433, vec2(0, 433), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(520 - 493, vec2(0, 493), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(94 - 58, vec2(0, 58), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(138 - 126, vec2(0, 126), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(814 - 745, vec2(0, 745), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(594 - 554, vec2(0, 554), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(504 - 467, vec2(0, 467), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(760 - 750, vec2(0, 750), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(556 - 531, vec2(0, 531), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(196 - 185, vec2(0, 185), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(693 - 650, vec2(0, 650), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(971 - 936, vec2(0, 936), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(222 - 153, vec2(0, 153), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(87 - 77, vec2(0, 77), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1085 - 1027, vec2(0, 1027), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(609 - 557, vec2(0, 557), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(808 - 798, vec2(0, 798), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(212 - 183, vec2(0, 183), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(210 - 161, vec2(0, 161), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(166 - 156, vec2(0, 156), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(283 - 239, vec2(0, 239), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1020 - 1010, vec2(0, 1010), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(845 - 805, vec2(0, 805), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(480 - 447, vec2(0, 447), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1117 - 1053, vec2(0, 1053), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(703 - 668, vec2(0, 668), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(574 - 544, vec2(0, 544), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(430 - 395, vec2(0, 395), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(1035 - 996, vec2(0, 996), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(268 - 246, vec2(0, 246), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(632 - 622, vec2(0, 622), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(566 - 556, vec2(0, 556), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(81 - 45, vec2(0, 45), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(571 - 557, vec2(0, 557), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(554 - 543, vec2(0, 543), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(966 - 909, vec2(0, 909), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(824 - 814, vec2(0, 814), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(997 - 975, vec2(0, 975), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(496 - 471, vec2(0, 471), vec4(random(2), random(2), random(2), 1.0));
  CreateLineObject2(774 - 764, vec2(0, 764), vec4(random(2), random(2), random(2), 1.0));

  Tree1d.WriteTreeState;
end;

procedure TBSTestKDTreeIn1d.SelectObjects;
var
  i: Integer;
  co: TLine;
begin
  for i := 0 to ListResult.Count - 1 do
  begin
    co := TLine(ListResult.Items[i]);
    co.Color := OriginalColors.Items[co];
  end;
  ListResult.Count := 0;
  OriginalColors.Clear();
  Tree1d.Select(FViewPort1d.Position2d.y, FViewPort1d.Position2d.y + FViewPort1d.Length, ListResult);
  Selected.Text := 'Selected: ' + IntToStr(ListResult.Count);
  for i := 0 to ListResult.Count - 1 do
  begin
    co := TLine(ListResult.Items[i]);
    if (co.Position2d.y = 622) and (co.Length = 10) then
      co := co;
    if not OriginalColors.Exists(co) then
      OriginalColors.Items[co] := co.Color;

    co.Color := BS_CL_ORANGE_2;
  end;
end;

procedure TBSTestKDTreeIn1d.UpdateViewportHint;
begin
  HintPosViewport.Position2d := vec2(10, 50.0);
  HintPosViewport.Text := IntToStr(trunc(FViewPort1d.Position2d.y)) + ', ' + IntToStr(trunc(FViewPort1d.Position2d.y + FViewPort1d.Height));
end;

procedure TBSTestKDTreeIn1d.OnMouseObjectEnter(const AData: BMouseData);
var
  l: TLine;
  data: Pointer;
  LMin, RMax: double;
begin
  l := TLine(PRendererGraphicInstance(AData.BaseHeader.Instance).Instance.Owner.TagPtr);
  LMin := 0;
  RMax := 0;
  data := nil;
  Tree1d.Select(l.Data.TagInt, LMin, RMax, data);
  if (data <> l) or (data = nil) then
  begin
    Hint.Text := 'Error: ';
    Hint.Color := TGuiColors.Red;
  end else
  begin
    Hint.Text := 'min = ' + inttostr(trunc(LMin)) + ', max = ' + inttostr(trunc(RMax));
    Hint.Color := TGuiColors.Green;
  end;
  Hint.Position2d := l.AbsolutePosition2d + vec2(10, 0.0);
  //Hint.Visible := true;
end;

procedure TBSTestKDTreeIn1d.OnMouseObjectLeave(const AData: BMouseData);
begin
  //Hint.Visible := false;
end;

procedure TBSTestKDTreeIn1d.OnClickButtonSelect(const AData: BMouseData);
begin
  SelectObjects;
end;

procedure TBSTestKDTreeIn1d.OnKeyDown(const Data: BKeyData);
begin
  inherited OnKeyDown(Data);
  if not ViewPortAnimMove.IsRun then
  begin
    if Data.Key in [38] then // forward
    begin
      ViewPortAnimMove.StartValue := -1.0;
      ViewPortAnimMove.StopValue := 0;
      ViewPortAnimMove.Run;
    end else
    if Data.Key in [40] then // backward
    begin
      ViewPortAnimMove.StartValue := 1.0;
      ViewPortAnimMove.StopValue := 0;
      ViewPortAnimMove.Run;
    end;
  end;
end;

procedure TBSTestKDTreeIn1d.OnKeyUp(const Data: BKeyData);
begin
  inherited OnKeyUp(Data);
  if (Data.Key in [38, 40]) and ViewPortAnimMove.IsRun then
    ViewPortAnimMove.Stop;
end;

class function TBSTestKDTreeIn1d.TestName: string;
begin
  Result := 'KDTree test in 1d';
end;

initialization

  RegisterTest(TBSTestScrollBoxSpaceTree);
  RegisterTest(TBSTestSceneKDTree);
  RegisterTest(TBSTestKDTreeIn2d);
  RegisterTest(TBSTestKDTreeIn1d);

end.
