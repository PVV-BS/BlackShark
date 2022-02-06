{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised January, 2022

  This file is part of "Black Shark Graphics Engine", and may only be
used, modified, and distributed under the terms of the project license 
"License(LGPL).txt". By continuing to use, modify, or distribute this
file you indicate that you have read the license and understand and 
accept it fully.

  "Black Shark Graphics Engine" is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied 
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

-- End License block --
}

unit bs.selectors;

{$I BlackSharkCfg.inc}

interface

uses
    math
  , bs.basetypes
  , bs.obj
  , bs.events
  , bs.renderer
  , bs.scene
  , bs.canvas
  , bs.scene.objects
  , bs.gui.menu
  , bs.gui.buttons
  , bs.collections
  ;

type

  { TBlackSharkSelectorInstances }

  TTreeGraphicItems =  TBinTreeTemplate<PRendererGraphicInstance, Pointer>;
  { can return any user association (Pointer) with instance; when coming a event deselect this
    association will send as parameter in TBlackSharkSelectorInstances.OnUnSelectObjectProc }
  TOnSelectObjectProc = function (Instance: PRendererGraphicInstance): Pointer of object;
  TOnUnSelectObjectProc = procedure (Instance: PRendererGraphicInstance; Associate: Pointer) of object;

  TBlackSharkSelectorInstances = class
  private
    const
      FIRST_SIZE = 1;
  private
    ObsrvScnMD: IBMouseDownEventObserver;
    ObsrvScnMU: IBMouseUpEventObserver;
    ObsrvScnMM: IBMouseMoveEventObserver;
    Canvas: TBCanvas;
    IsMouseDown: boolean;
    Rect: TRectangle;
    Border: TRectangle;
    StartPos: TVec2i;
    FSelectedTree: TTreeGraphicItems;
    FOnSelectInstance: TOnSelectObjectProc;
    FOnUnSelectInstance: TOnUnSelectObjectProc;
    FExactSelect: boolean;
    FBanSelect: boolean;
    FMouseButton: TBSMouseButton;

    procedure MouseDown({%H-}const Data: BMouseData);
    procedure MouseUp({%H-}const {%H-}Data: BMouseData);
    procedure MouseMove({%H-}const Data: BMouseData);

    procedure RecreateShapes(const Delta: TVec2i);
    procedure CheckHitToRect;
  public
    constructor Create(ACanvas: TBCanvas; SelectorOwner: TCanvasObject);
    destructor Destroy; override;

    procedure ResetSelected(Silent: boolean = false);
    { again invoked OnUnSelectInstance and OnSelectInstance  }
    procedure ReselectAll;
    { if in the scene occured reset selected instances (by any reasons) then you
      can recovery them again by this method }
    procedure RecoverySelected;
    { delete from selected a list without invoke OnUnSelectInstance if Silent = true }
    procedure UnSelect(Silent: boolean; Instance: PRendererGraphicInstance);
    procedure Select(Instance: PRendererGraphicInstance; Associate: Pointer);
    function InstanceIsSelected(Instance: PRendererGraphicInstance): boolean;
    property OnSelectInstance: TOnSelectObjectProc read FOnSelectInstance write FOnSelectInstance;
    property OnUnSelectInstance: TOnUnSelectObjectProc read FOnUnSelectInstance write FOnUnSelectInstance;
    property Selected: TTreeGraphicItems read FSelectedTree;
    { to use an exact algorithm? }
    property ExactSelect: boolean read FExactSelect write FExactSelect;
    property BanSelect: boolean read FBanSelect write FBanSelect;
    { a mouse button for select }
    property MouseButton: TBSMouseButton read FMouseButton write FMouseButton;
  end;

  { TBlackSharkSelector }

  TBlackSharkSelector = class
  private
    ObsrvChngMVP: IBChangeMVPEventObserver;
    procedure OnChangeMVP({%H-}const {%H-}Value: BTransformData);
  protected
    FSelectItem: PRendererGraphicInstance;
    BBDefault: TBox3f;
    LimitsShape: TVec3f;
    FRoot: TCanvasObject;
    FCanvas: TBCanvas;
    procedure SetSelectItem(AValue: PRendererGraphicInstance); virtual;
    procedure OnChangeMVPDo; virtual; abstract;
  public
    constructor Create(ACanvas: TBCanvas);
    destructor Destroy; override;
    property SelectItem: PRendererGraphicInstance read FSelectItem write SetSelectItem;
    property Canvas: TBCanvas read FCanvas;
    property Root: TCanvasObject read FRoot;
  end;

  TOnResizeGraphicObjectInstance = procedure (Instance: PGraphicInstance;
    const Scale: TVec3f; const Point: TBBLimitPoint) of object;

  TOnDropResize = procedure (Instance: PGraphicInstance) of object;

  { TBlackSharkSelectorBB }

  TBlackSharkSelectorBB = class(TBlackSharkSelector)
  private
    const
      RADIUS_POINTS = 5;
      SIGN: array[boolean] of BSFloat = (-1.0, 1.0);
  private

    ObsrvScnMD: IBMouseDownEventObserver;
    ObsrvScnMU: IBMouseUpEventObserver;
    ObsrvScnMM: IBMouseMoveEventObserver;

    GroupME: BObserversGroup<BMouseData>;
    GroupML: BObserversGroup<BMouseData>;
    GroupMD: BObserversGroup<BMouseData>;

    GroupMidMD: BObserversGroup<BMouseData>;

    FAllowResize: boolean;
    FAllowDrag: boolean;
    FShowPoints: boolean;
    SelectedPoint: TCanvasObject;
    SelectedMidPoint: TCanvasObject;
    //DragArea: TCanvasObject;
    LastDistance: BSFloat;
    OriginPos: TVec3f;
    //LastOriginPos: TVec3f;
    StartOriginPos: TVec3f;
    Direction: TVec3f;
    BBMiddle: TVec3f;
    { for convert transformations from world to local coordinates }
    ProdStackInv: TMatrix3f;
    { points for BB  }
    FPointsBB: array[TBBPoints] of TCanvasObject;
    { middle points for every plane }
    FPointsMid: array[TBoxPlanes] of TCanvasObject;
    FStretching: boolean;
    FShowMiddlePoints: boolean;
    FShowLines: boolean;
    Lines: TGraphicObjectLines;
    DragResolve: boolean;
    OverPoint: boolean;
    FOnResizeGraphicObjectInstance: TOnResizeGraphicObjectInstance;
    FOnDropResize: TOnDropResize;
    FMinimalSize: TVec3f;
    FOnBeginResize: TOnDropResize;
    BeginResizeSend: boolean;
    FFixOppositeSideWhenResize: boolean;
    function SelectPlane(X, Y: int32): TVec4f;
    procedure FillLines;
    procedure ShowPointsDo;
    procedure ShowMiddlePointsDo;
    procedure HidePoints;
    procedure HideMiddlePoints;
    procedure ShowDragArea;
    procedure HideDragArea;
    procedure DragStretchPoint(X, Y: int32);
    procedure Transform(var Delta: TVec3f; NewDistance: BSFloat; const Point: TBBLimitPoint);
    procedure DragStretchPointMid(X, Y: int32);
    procedure SetShowPoints(AValue: boolean);
    procedure SetShowLines(const Value: boolean);
    procedure OnMouseDownOnPoint({%H-}const Data: BMouseData);
    procedure OnMouseDownOnMiddlePoint({%H-}const Data: BMouseData);
    procedure OnMouseMove({%H-}const Data: BMouseData);
    procedure OnMouseUp({%H-}const Data: BMouseData);
    procedure OnMouseDown({%H-}const {%H-}Data: BMouseData);
    procedure OnMouseEnter({%H-}const Data: BMouseData);
    procedure OnMouseLeave({%H-}const Data: BMouseData);
    procedure SetShowMiddlePoints(const Value: boolean);
    procedure SetMinimalSize(const Value: TVec3f);
    procedure SetAllowDrag(const Value: boolean);
  protected
    procedure OnChangeMVPDo; override;
    procedure SetSelectItem(AValue: PRendererGraphicInstance); override;
  public
    constructor Create(ACanvas: TBCanvas);
    destructor Destroy; override;
    property Stretching: boolean read FStretching;
    property ShowPoints: boolean read FShowPoints write SetShowPoints;
    property ShowMiddlePoints: boolean read FShowMiddlePoints write SetShowMiddlePoints;
    property ShowLines: boolean read FShowLines write SetShowLines;
    property AllowResize: boolean read FAllowResize write FAllowResize;
    property FixOppositeSideWhenResize: boolean read FFixOppositeSideWhenResize write FFixOppositeSideWhenResize;
    property MinimalSize: TVec3f read FMinimalSize write SetMinimalSize;
    property AllowDrag: boolean read FAllowDrag write SetAllowDrag;
    { you can to assign the property for himself to change a size instance; otherwise,
      the mesh of instance will be changed by scale a position vertexses the mesh }
    property OnResizeGraphicObjectInstance: TOnResizeGraphicObjectInstance read FOnResizeGraphicObjectInstance write FOnResizeGraphicObjectInstance;
    property OnBeginResize: TOnDropResize read FOnBeginResize write FOnBeginResize;
    property OnDropResize: TOnDropResize read FOnDropResize write FOnDropResize;
  end;

  { TBlackSharkRotor3D }

  TBlackSharkRotor3D = class(TBlackSharkSelector)
  private
    RotorX: TBRadialSlider;
    RotorY: TBRadialSlider;
    RotorZ: TBRadialSlider;
    Reset: TBButton;
    Rotating: boolean;
    FReduceOpacity: boolean;
    StartOpacity: BSFloat;
    StartAngle: TVec3f;
    Axises: TGraphicObjectAxises;
    FShowAxis: boolean;
    ObsrvOnResetClick: IBMouseUpEventObserver;

    ObsrvOnRotXClick: IBMouseUpEventObserver;
    ObsrvOnRotYClick: IBMouseUpEventObserver;
    ObsrvOnRotZClick: IBMouseUpEventObserver;

    procedure OnChangeDegreeX (Sender: TBRadialSlider);
    procedure OnChangeDegreeY (Sender: TBRadialSlider);
    procedure OnChangeDegreeZ (Sender: TBRadialSlider);
    procedure OnMouseDownOnReset({%H-}const {%H-}Data: BMouseData);
    procedure OnMouseDownOnRotor({%H-}const {%H-}Data: BMouseData);
    procedure SetReduceOpacity(const Value: boolean);
    procedure SetShowAxis(const Value: boolean);
    procedure CreateAxis;
    procedure ShowAxisDo;
  protected
    procedure OnChangeMVPDo; override;
    procedure SetSelectItem(AValue: PRendererGraphicInstance); override;
    //procedure SetVisible(const AValue: boolean); override;
  public
    constructor Create(ACanvas: TBCanvas);
    destructor Destroy; override;
    procedure Clear;
    property ReduceOpacity: boolean read FReduceOpacity write SetReduceOpacity;
    property ShowAxis: boolean read FShowAxis write SetShowAxis;
  end;

  TBlackSharkSelectorMesh = class(TBlackSharkSelector)

  end;

implementation

uses
    SysUtils
  , Classes
  , bs.math
  , bs.texture
  , bs.utils
  , bs.thread
  , bs.config
  ;

{ TBlackSharkSelectorInstances }

procedure TBlackSharkSelectorInstances.MouseDown(const Data: BMouseData);
var
  associate: Pointer;
begin
  if FBanSelect then
    exit;
	if not (FMouseButton in Data.Button) then
  	exit;
  if (Canvas.Renderer.SelectedItemsCount > 0) then
  begin
    if (Data.BaseHeader.Instance <> nil) and
       	(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Interactive)
          and PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.SelectResolve then
      if not FSelectedTree.Find(Data.BaseHeader.Instance, associate) then
      begin
        if (FSelectedTree.Count > 0) and not (Canvas.Renderer.Keyboard[Canvas.Renderer.KeyMultiSelectAllows]) then
          ResetSelected;
        if Assigned(FOnUnSelectInstance) then
        begin
          associate := FOnSelectInstance(Data.BaseHeader.Instance);
          FSelectedTree.Add(Data.BaseHeader.Instance, associate);
        end;
      end else
      if (Canvas.Renderer.Keyboard[Canvas.Renderer.KeyMultiSelectAllows]) then
      begin
        UnSelect(false, Data.BaseHeader.Instance);
      end;
  end else
  begin
    if Assigned(Rect.Parent) then
      StartPos := vec2(Data.X, Data.Y) - Rect.Parent.AbsolutePosition2d
    else
      StartPos := vec2(Data.X, Data.Y);

    Rect.Size := vec2(FIRST_SIZE, FIRST_SIZE);
    Rect.Data.Mesh.Clear;
    Border.Size := vec2(FIRST_SIZE + 2.0, FIRST_SIZE + 2.0);
    Rect.Position2d := StartPos;
    Border.Position2d := vec2(-1, -1);
    Border.Data.Mesh.Clear;
    Rect.Data.Hidden := false;
    Border.Data.Hidden := false;
    IsMouseDown := true;
    ResetSelected;
  end;
end;

procedure TBlackSharkSelectorInstances.MouseUp(const Data: BMouseData);
begin
	IsMouseDown := false;
  Rect.Data.Hidden := true;
  Border.Data.Hidden := true;
  if (Canvas.Renderer.SelectedItemsCount <> FSelectedTree.Count) and (FSelectedTree.Count > 0) then
    RecoverySelected;
end;

procedure TBlackSharkSelectorInstances.RecoverySelected;
var
  associate: Pointer;
  no_eof: boolean;
begin
  no_eof := FSelectedTree.Iterator.SetToBegin(associate);
  while no_eof do
  begin
    Canvas.Renderer.Scene.InstanceSetSelected(FSelectedTree.Iterator.CurrentNode.Key.Instance, true);
    no_eof := FSelectedTree.Iterator.Next(associate);
  end;
end;

procedure TBlackSharkSelectorInstances.RecreateShapes(const Delta: TVec2i);
var
  pos: TVec2i;
  change_pos: boolean;
  d: TVec2f;
begin

  //Canvas.Root.Position2d := vec2(0.0, 0.0);
  if Delta.x = 0 then
    d.x := 1
  else
    d.x := abs(Delta.x);

  if Delta.y = 0 then
    d.y := 1
  else
    d.y := abs(Delta.y);

  pos := Rect.Position2d;
 	Rect.Size := vec2(d.x, d.y);
  Rect.Build;
  { the border generate again, because scale gives wrong effect }
  Border.Size := Rect.Size + 2;
  Border.Build;
  change_pos := false;

  if (delta.x < 0) then
  begin
    change_pos := true;
    pos.x := StartPos.x + delta.x;
  end;

  if (delta.y < 0) then
  begin
    change_pos := true;
    pos.y := StartPos.y + delta.y;
  end;

  if change_pos then
    Rect.Position2d := pos
  else
    Rect.Position2d := StartPos;

  Border.Position2d := vec2(-1.0, -1.0);
end;

procedure TBlackSharkSelectorInstances.ResetSelected(Silent: boolean);
var
  associate: Pointer;
  no_eof: boolean;
begin
  no_eof := FSelectedTree.Iterator.SetToBegin(associate);
  while no_eof do
  begin
    Canvas.Renderer.Scene.InstanceSetSelected(FSelectedTree.Iterator.CurrentNode.Key.Instance, false);
    if not Silent and Assigned(FOnUnSelectInstance) then
      FOnUnSelectInstance(FSelectedTree.Iterator.CurrentNode.Key, associate);
    no_eof := FSelectedTree.Iterator.Next(associate);
  end;
  FSelectedTree.Clear;
end;

procedure TBlackSharkSelectorInstances.Select(Instance: PRendererGraphicInstance; Associate: Pointer);
var
  tmp: Pointer;
begin
  if FSelectedTree.Find(Instance, tmp) then
    exit;
  FSelectedTree.Add(Instance, Associate);
  Canvas.Renderer.Scene.InstanceSetSelected(Instance.Instance, true);
end;

procedure TBlackSharkSelectorInstances.UnSelect(Silent: boolean; Instance: PRendererGraphicInstance);
var
  tmp: Pointer;
begin
  if not Silent and Assigned(FOnUnSelectInstance) then
  begin
    if FSelectedTree.Find(Instance, tmp) then
    begin
      FOnUnSelectInstance(Instance, tmp);
    end;
  end;
  FSelectedTree.Remove(Instance);
  Canvas.Renderer.Scene.InstanceSetSelected(Instance.Instance, false);
end;

procedure TBlackSharkSelectorInstances.ReselectAll;
var
  associate: Pointer;
  no_eof: boolean;
begin
  no_eof := FSelectedTree.Iterator.SetToBegin(associate);
  while no_eof do
  begin
    if Assigned(FOnUnSelectInstance) then
      FOnUnSelectInstance(FSelectedTree.Iterator.CurrentNode.Key, associate);
    if Assigned(FOnSelectInstance) then
      FSelectedTree.Iterator.CurrentNode.Value := FOnSelectInstance(FSelectedTree.Iterator.CurrentNode.Key);
    no_eof := FSelectedTree.Iterator.Next(associate);
  end;
end;

procedure TBlackSharkSelectorInstances.MouseMove(const Data: BMouseData);
var
  delta: TVec2i;
begin
	if (not IsMouseDown) or FBanSelect then
  	exit;
  if Assigned(Rect.Parent) then
	  delta := vec2(Data.X, Data.Y) - Rect.Parent.AbsolutePosition2d - StartPos
  else
    delta := vec2(Data.X, Data.Y) - StartPos;
  RecreateShapes(delta);
  CheckHitToRect;
end;

procedure TBlackSharkSelectorInstances.CheckHitToRect;
var
  it: TListRendererInstances.PListItem;
  gi: PRendererGraphicInstance;
  tmp: Pointer;
  hit: boolean;
  r: TRectBSf;
begin

  r.Position := Rect.AbsolutePosition2d;
  r.Size := vec2(Rect.Width, Rect.Height);

  it := Canvas.Renderer.VisibleGI.ItemListLast;

  while Assigned(it) do
  begin

    gi := it.Item;
    it := it.Prev;

    if (not gi.Instance.SelectResolve) or not (gi.Instance.Interactive) then
      continue;

    hit := Canvas.Renderer.Intersects(gi.Instance, r, true);
    if (not hit) then
    begin
      if Assigned(FOnUnSelectInstance) then
      begin
        if FSelectedTree.Find(gi, tmp) then
        begin
          FSelectedTree.Remove(gi);
          FOnUnSelectInstance(gi, tmp);
        end;
      end;
      continue;
    end;

    if FSelectedTree.Find(gi, tmp) then
      continue;

    if Assigned(FOnSelectInstance) then
      tmp := FOnSelectInstance(gi)
    else
      tmp := nil;

    //if not FSelectedTree.Find(gi, tmp) then
    begin
      FSelectedTree.Add(gi, tmp);
      Canvas.Renderer.Scene.InstanceSetSelected(gi.Instance, true);
    end;

  end;
end;

constructor TBlackSharkSelectorInstances.Create(ACanvas: TBCanvas; SelectorOwner: TCanvasObject);
begin
  Canvas := ACanvas;
  Rect := TRectangle.Create(Canvas, SelectorOwner);
  Rect.Size := vec2(FIRST_SIZE, FIRST_SIZE);
  Rect.Fill := true;
  //Rect.Build;
  Rect.Position2d := vec2(0, 0);

  if Assigned(SelectorOwner) then
    Rect.Layer2d := Round(Canvas.Renderer.Frustum.DISTANCE_2D_SCREEN / Canvas.Renderer.Frustum.DISTANCE_2D_BW_LAYERS) - SelectorOwner.Layer2dAbsolute - 11
  else
    Rect.Layer2d := Round(Canvas.Renderer.Frustum.DISTANCE_2D_SCREEN / Canvas.Renderer.Frustum.DISTANCE_2D_BW_LAYERS) - 11;

  Rect.Data.Opacity := 0.3;
  Rect.Data.Hidden := true;
  Rect.Data.Color := BS_CL_SKY_BLUE;
  Rect.Data.DragResolve := false;
  Rect.MinWidth := 4.0;
  Rect.MinHeight := 4.0;
  Rect.Data.Interactive := false;
  Rect.BanScalableMode := true;
  //Rect.Data.DrawAsTransparent := true;
  { I think that for four vertexes to create VBO too expensive; that is why switch
    off this property }
  Rect.Data.StaticObject := false;
  Border := TRectangle.Create(Canvas, Rect);
  Border.Size := vec2(FIRST_SIZE + 2, FIRST_SIZE + 2);
  Border.Position2d := vec2(-1, -1);
  //Border.Data.DrawAsTransparent := true;
  Border.Data.DragResolve := false;
  Border.Data.Opacity := 0.3;
  Border.Data.Hidden := true;
  Border.Data.Color := BS_CL_AQUA;
  Border.MinWidth := 6.0;
  Border.MinHeight := 6.0;
  Border.Data.StaticObject := false;
  Border.Data.Interactive := false;
  Border.Layer2d := 0;
  Border.BanScalableMode := true;
  if Border.Data.HasStencilParent then
    Border.Data.StencilTest := true;

  ObsrvScnMD := Canvas.Renderer.EventMouseDown.CreateObserver(GUIThread, MouseDown);
  ObsrvScnMM := Canvas.Renderer.EventMouseMove.CreateObserver(GUIThread, MouseMove);
  ObsrvScnMU := Canvas.Renderer.EventMouseUp.CreateObserver(GUIThread, MouseUp);

  FSelectedTree := TTreeGraphicItems.Create(@PtrCmp);
end;

destructor TBlackSharkSelectorInstances.Destroy;
begin
  ObsrvScnMD := nil;
  ObsrvScnMM := nil;
  ObsrvScnMU := nil;
  ResetSelected;
  FSelectedTree.Free;
  //Canvas.Root.Parent := nil;
  //Canvas.Free;
  inherited Destroy;
end;

function TBlackSharkSelectorInstances.InstanceIsSelected(Instance: PRendererGraphicInstance): boolean;
var
  tmp: Pointer;
begin
  Result := FSelectedTree.Find(Instance, tmp);
end;

{ TBlackSharkSelector }

procedure TBlackSharkSelector.SetSelectItem(AValue: PRendererGraphicInstance);
begin
  if AValue = FSelectItem then
    exit;
  if Assigned(FSelectItem) then
  begin
    ObsrvChngMVP := nil;
    FSelectItem.Instance.Owner.Mesh.MinSize := LimitsShape;
  end;
  FSelectItem := AValue;
  if Assigned(FSelectItem) then
  begin
    LimitsShape := FSelectItem.Instance.Owner.Mesh.MinSize;
    ObsrvChngMVP := FSelectItem.Instance.Owner.EventChangeMVP.CreateObserver(GUIThread, OnChangeMVP);
    BBDefault := FSelectItem.Instance.Owner.Mesh.FBoundingBox;
    FRoot.Data.ModalLevel := FSelectItem.Instance.Owner.ModalLevel;
  end else
    FillChar(BBDefault, SizeOf(TBox3f), 0);
end;

constructor TBlackSharkSelector.Create(ACanvas: TBCanvas);
begin
  FCanvas := ACanvas;
  { create root object }
  FRoot := FCanvas.CreateEmptyCanvasObject;
  FRoot.Position2d := vec2(0.0, 0.0);
end;

destructor TBlackSharkSelector.Destroy;
begin
  ObsrvChngMVP := nil;
  inherited;
end;

procedure TBlackSharkSelector.OnChangeMVP(const Value: BTransformData);
begin
  OnChangeMVPDo;
end;

{ TBlackSharkSelectorBB }

constructor TBlackSharkSelectorBB.Create(ACanvas: TBCanvas);
var
  p: TBBPoints;
  pl: TBoxPlanes;
  texture: PTextureArea;
  f_tex: string;

  function CreatePoint(GroupMDown: BObserversGroup<BMouseData>; TagInt: NativeInt): TCanvasObject;
  begin
    if Assigned(texture) then
    begin
      Result := TCircleTextured.Create(Canvas, nil);
      TCircleTextured(Result).Fill := true;
      TCircleTextured(Result).Radius := RADIUS_POINTS;
      TTexturedVertexes(Result.Data).Texture := texture;
    end else
    begin
      Result := TCircle.Create(Canvas, nil);
      TCircle(Result).Fill := true;
      TCircle(Result).Radius := RADIUS_POINTS;
    end;
    Result.Build;
    Result.Data.SelectResolve := false;
    Result.Data.DragResolve := false;
    Result.Data.Hidden := true;
    GroupMDown.CreateObserver(Result.Data.EventMouseDown);
    GroupME.CreateObserver(Result.Data.EventMouseEnter);
    GroupML.CreateObserver(Result.Data.EventMouseLeave);
    Result.Data.TagInt := TagInt;
    Result.Layer2d := 3;
  end;

begin
  inherited Create(ACanvas);
  GroupME := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseEnter);
  GroupML := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseLeave);
  GroupMD := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseDownOnPoint);
  GroupMidMD := BObserversGroup<BMouseData>.Create(GUIThread, OnMouseDownOnMiddlePoint);

  FShowMiddlePoints := true;
  FShowLines := true;
  FAllowResize := true;
  Lines := TGraphicObjectLines.Create(Self, nil, Canvas.Renderer.Scene);
  Lines.Color := BS_CL_SKY;
  Lines.Opacity := 0.2;
  Lines.Interactive := false;
  FMinimalSize := vec3(BSConfig.VoxelSize*10, BSConfig.VoxelSize*10, BSConfig.VoxelSize*10);
  { for avoid exeption in beginnig check exists a file for texture }
  f_tex := GetFilePath('Pictures/sel_point.png');
  if FileExists(f_tex) then
    texture := BSTextureManager.LoadTexture(f_tex, true, true)
  else
    texture := nil;

  for p := low(TBBPoints) to high(TBBPoints) do  // pXminYmaxZmax  high(TBBPoints)
    FPointsBB[p] := CreatePoint(GroupMD, NativeInt(p));

  f_tex := GetFilePath('Pictures/sel_point_mid.png');
  if FileExists(f_tex) then
    texture := BSTextureManager.LoadTexture(f_tex, true, true)
  else
    texture := nil;

  for pl := Low(TBoxPlanes) to High(TBoxPlanes) do
    FPointsMid[pl] := CreatePoint(GroupMidMD, NativeInt(pl));

  ObsrvScnMD := Canvas.Renderer.EventMouseDown.CreateObserver(GUIThread, OnMouseDown);
  ObsrvScnMM := Canvas.Renderer.EventMouseMove.CreateObserver(GUIThread, OnMouseMove);
  ObsrvScnMU := Canvas.Renderer.EventMouseUp.CreateObserver(GUIThread, OnMouseUp);

  FAllowDrag := true;

  if FAllowDrag then
    ShowDragArea;

end;

destructor TBlackSharkSelectorBB.Destroy;
var
  p: TBBPoints;
  pl: TBoxPlanes;
begin
  GroupME.Free;
  GroupML.Free;
  GroupMD.Free;
  GroupMidMD.Free;
  ObsrvScnMD := nil;
  ObsrvScnMM := nil;
  ObsrvScnMU := nil;
  HideDragArea;
  Lines.Parent := nil;
  Lines.Free;
  for p := low(TBBPoints) to high(TBBPoints) do  //pXminYmaxZmax high(TBBPoints)
    FPointsBB[p].Free;
  for pl := Low(TBoxPlanes) to High(TBoxPlanes) do
    FPointsMid[pl].Free;
  inherited;
end;

procedure TBlackSharkSelectorBB.DragStretchPoint(X, Y: int32);
var
  pl: TVec4f;
  proj: TVec3f;
  delta: TVec3f;
  d: BSFloat;
  p: TBBPoints;
  bb: PBox3f;
  intersect: boolean;
begin
  { generates a plane for intercept a ray directed from center selected the object
    to dragged the point }
  pl := SelectPlane(X, Y);
  { take point cross the ray and the plane }
  proj := PlaneCrossProduct(pl, BBMiddle, Direction, d, intersect);
  if not intersect then
    exit;

  bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
  p := TBBPoints(SelectedPoint.Data.TagInt);
  OriginPos := FSelectItem.Instance.ProdStackModelMatrix * vec3(
    bb^.Named[APROPRIATE_BB_POINTS[p, 0]],
    bb^.Named[APROPRIATE_BB_POINTS[p, 1]],
    bb^.Named[APROPRIATE_BB_POINTS[p, 2]]);
  { translates delta from world to local coordinates }
  delta := ProdStackInv*(proj - OriginPos);
  delta := delta * Direction;

  d := VecLen(BBMiddle - proj);
  if abs(d - LastDistance) < EPSILON then
    exit;
  Transform(delta, d, APROPRIATE_BB_POINTS[p]);
end;

procedure TBlackSharkSelectorBB.DragStretchPointMid(X, Y: int32);
var
  pl: TVec4f;
  proj: TVec3f;
  delta: TVec3f;
  d: BSFloat;
  p: TBoxPlanes;
  bb: PBox3f;
  intersect: boolean;
begin
  { generates a plane for intercept a ray directed from center selected the object
    to dragged the point }
  pl := SelectPlane(X, Y);
  { take point cross the ray and the plane }
  proj := PlaneCrossProduct(pl, BBMiddle, Direction, d, intersect);
  if not intersect then
    exit;
  bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
  p := TBoxPlanes(SelectedMidPoint.Data.TagInt);
  OriginPos := FSelectItem.Instance.ProdStackModelMatrix * vec3(
    bb^.Named[APROPRIATE_MID[p, 0]],
      bb^.Named[APROPRIATE_MID[p, 1]],
        bb^.Named[APROPRIATE_MID[p, 2]]);
  { converts delta from world to local coordinates }
  delta := ProdStackInv*(proj - OriginPos);
  delta := delta * Direction;
  d := VecLen(proj - BBMiddle)*2.0;
  if (d < FMinimalSize.x) then
    exit;
  d := VecLen(delta);
  if abs(d) < EPSILON then
    exit;
  Transform(delta, d, APROPRIATE_MID[p]);
end;

procedure TBlackSharkSelectorBB.FillLines;
var
  bb: TBox3f;

  procedure FillZ;
  begin
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMin]),
      vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMin]),
      vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMin]),
      vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMin]),
      vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMax]));
  end;

  procedure FillZMax;
  begin
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMax]),
      vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMax]),
      vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMax]),
      vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMax]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMax]),
      vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMax]));
  end;

  procedure FillZMin;
  begin
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMin]),
      vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMin]));
    Lines.Line(vec3(bb.Named[xMin], bb.Named[yMax], bb.Named[zMin]),
      vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMin]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMax], bb.Named[zMin]),
      vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMin]));
    Lines.Line(vec3(bb.Named[xMax], bb.Named[yMin], bb.Named[zMin]),
      vec3(bb.Named[xMin], bb.Named[yMin], bb.Named[zMin]));
  end;

begin
  Lines.Clear;
  Lines.BeginUpdate;
  bb.Max := FSelectItem.Instance.Owner.Mesh.FBoundingBox.Max +   BSConfig.VoxelSize;
  bb.Min := FSelectItem.Instance.Owner.Mesh.FBoundingBox.Min + (-BSConfig.VoxelSize);

  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max = 0 then
  begin
    bb.Max.z := 0.0;
    bb.Min.z := 0.0;
  end;

  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max = 0 then
  begin
    bb.Max.y := 0.0;
    bb.Min.y := 0.0;
  end;

  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max = 0 then
  begin
    bb.Max.x := 0.0;
    bb.Min.x := 0.0;
  end;

  FillZMax;
  if (bb.z_max <> 0) then
    FillZMin;
  FillZ;
  Lines.EndUpdate;
end;

procedure TBlackSharkSelectorBB.HideDragArea;
begin

end;

procedure TBlackSharkSelectorBB.HideMiddlePoints;
var
  pl: TBoxPlanes;
begin
  for pl := Low(TBoxPlanes) to High(TBoxPlanes) do
    FPointsMid[pl].Data.Hidden := true;
end;

procedure TBlackSharkSelectorBB.HidePoints;
var
  p: TBBPoints;
begin
  for p := low(TBBPoints) to high(TBBPoints) do //pXminYmaxZmax high(TBBPoints)
    FPointsBB[p].Data.Hidden := true;

  if Lines <> nil then
  begin
    Lines.Parent := nil;
    Lines.Hidden := true;
  end;

  if FShowMiddlePoints then
    HideMiddlePoints;
end;

procedure TBlackSharkSelectorBB.OnChangeMVPDo;
var
  p: TBBPoints;
  pl: TBoxPlanes;
  bb: PBox3f;
begin
  if FShowLines then
    FillLines;
  bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
  for p := low(TBBPoints) to high(TBBPoints) do //pXminYmaxZmax high(TBBPoints)
  begin
    if FPointsBB[p].Data.BaseInstance.IsDrag or
       ((bb^.x_min = 0) and (APROPRIATE_BB_POINTS[p, 0] = xMin)) or
       ((bb^.y_min = 0) and (APROPRIATE_BB_POINTS[p, 1] = yMin)) or
       ((bb^.z_min = 0) and (APROPRIATE_BB_POINTS[p, 2] = zMin)) then
          continue;
    FPointsBB[p].Position2d := Canvas.Renderer.ScenePositionToScreenf(
      FSelectItem.Instance.ProdStackModelMatrix * vec3(  //
      bb^.Named[APROPRIATE_BB_POINTS[p, 0]],
      bb^.Named[APROPRIATE_BB_POINTS[p, 1]],
      bb^.Named[APROPRIATE_BB_POINTS[p, 2]])
      ) + vec2(-RADIUS_POINTS, RADIUS_POINTS*SIGN[APROPRIATE_BB_POINTS[p, 0] = yMin]);
  end;

  if FShowMiddlePoints then
    for pl := Low(TBoxPlanes) to High(TBoxPlanes) do
    begin
      if FPointsMid[pl].Data.BaseInstance.IsDrag or
         ((bb^.x_min = 0) and ((APROPRIATE_MID[pl, 0] = xMin) or (APROPRIATE_MID[pl, 0] = xMax))) or
         ((bb^.y_min = 0) and ((APROPRIATE_MID[pl, 1] = yMin) or (APROPRIATE_MID[pl, 1] = yMax))) or
         ((bb^.z_min = 0) and ((APROPRIATE_MID[pl, 2] = zMin) or (APROPRIATE_MID[pl, 2] = zMax))) then
            continue;
      FPointsMid[pl].Position2d := Canvas.Renderer.ScenePositionToScreenf(
        FSelectItem.Instance.ProdStackModelMatrix * vec3( //
        bb^.Named[APROPRIATE_MID[pl, 0]],
        bb^.Named[APROPRIATE_MID[pl, 1]],
        bb^.Named[APROPRIATE_MID[pl, 2]])
        ) + vec2(-RADIUS_POINTS, RADIUS_POINTS*SIGN[APROPRIATE_MID[pl, 0] = yMin]);
    end;
end;

procedure TBlackSharkSelectorBB.OnMouseDownOnMiddlePoint(const Data: BMouseData);
var
  pl: TBoxPlanes;
  bb: PBox3f;
begin
  if not FAllowResize then
  	exit;
  BeginResizeSend := false;
  SelectedMidPoint := TCanvasObject(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.Owner);
  if Assigned(SelectedMidPoint) then
  begin
    if FSelectItem.Instance.IsDrag then
      Canvas.Renderer.DropDragInstance(FSelectItem);
    DragResolve := FSelectItem.Instance.DragResolve;
    FSelectItem.Instance.DragResolve := false;
    bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
    pl := TBoxPlanes(SelectedMidPoint.Data.TagInt);
    BBMiddle := TVec3f(FSelectItem.Instance.ProdStackModelMatrix.M3);
    OriginPos := FSelectItem.Instance.ProdStackModelMatrix * vec3(
      bb^.Named[APROPRIATE_MID[pl, 0]],
        bb^.Named[APROPRIATE_MID[pl, 1]],
          bb^.Named[APROPRIATE_MID[pl, 2]]);
    StartOriginPos := OriginPos;
    Direction := VecNormalize(OriginPos - BBMiddle);
    LastDistance := VecLen(OriginPos - BBMiddle);
    FStretching := true;
    ProdStackInv := FSelectItem.Instance.ProdStackModelMatrix;
    MatrixInvert(ProdStackInv);
  end;
end;

procedure TBlackSharkSelectorBB.OnMouseDownOnPoint(const Data: BMouseData);
var
  p: TBBPoints;
  bb: PBox3f;
  //pln: TPlane;
begin
  if not FAllowResize then
  	exit;
  BeginResizeSend := false;
  SelectedPoint := TCanvasObject(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.Owner);
  if Assigned(SelectedPoint) then
  begin
    if Assigned(FSelectItem.Drag) then
      Canvas.Renderer.DropDragInstance(FSelectItem);
    DragResolve := FSelectItem.Instance.DragResolve;
    FSelectItem.Instance.DragResolve := false;
    bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
    p := TBBPoints(SelectedPoint.Data.TagInt);
    BBMiddle := TVec3f(FSelectItem.Instance.ProdStackModelMatrix.M3); // * bb^.Middle;
    OriginPos := FSelectItem.Instance.ProdStackModelMatrix * vec3(
      bb^.Named[APROPRIATE_BB_POINTS[p, 0]],
        bb^.Named[APROPRIATE_BB_POINTS[p, 1]],
          bb^.Named[APROPRIATE_BB_POINTS[p, 2]]);
    StartOriginPos := OriginPos;
    Direction := VecNormalize(OriginPos - BBMiddle);
    LastDistance := VecLen(OriginPos - BBMiddle);
    FStretching := true;
    ProdStackInv := FSelectItem.Instance.ProdStackModelMatrix;
    MatrixInvert(ProdStackInv);
  end;
end;

procedure TBlackSharkSelectorBB.OnMouseMove(const Data: BMouseData);
begin
  if FSelectItem = nil then
    exit;
  if Assigned(SelectedPoint) then
    DragStretchPoint(Data.X, Data.Y) else
  if Assigned(SelectedMidPoint) then
    DragStretchPointMid(Data.X, Data.Y);
end;

procedure TBlackSharkSelectorBB.OnMouseUp(const Data: BMouseData);
begin
  Canvas.Renderer.BanResetSelected := false;
  if Data.BaseHeader.Instance = nil then
    exit;
  if Assigned(FSelectItem) then
    FSelectItem.Instance.DragResolve := DragResolve;
  if (Assigned(SelectedPoint) or Assigned(SelectedMidPoint)) then
  begin
    if not OverPoint then
      PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.ScaleSimple := 1.0;
    if Assigned(FSelectItem) and Assigned(FOnDropResize) then
      FOnDropResize(FSelectItem.Instance);
    if Assigned(SelectedPoint) and (SelectedPoint.Data.IsSelected) then
      SelectedPoint.Data.IsSelected := false;
    if Assigned(SelectedMidPoint) and (SelectedMidPoint.Data.IsSelected) then
      SelectedMidPoint.Data.IsSelected := false;
  end;
  SelectedPoint := nil;
  SelectedMidPoint := nil;
  FStretching := false;
end;

procedure TBlackSharkSelectorBB.OnMouseDown(const Data: BMouseData);
begin
  if (FSelectItem <> nil) and not FStretching then
    DragResolve := FSelectItem.Instance.DragResolve;
end;

procedure TBlackSharkSelectorBB.OnMouseEnter(const Data: BMouseData);
begin
  if not FAllowResize then
  	exit;
  PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.ScaleSimple := 1.2;
  OverPoint := true;
end;

procedure TBlackSharkSelectorBB.OnMouseLeave(const Data: BMouseData);
begin
  if not FAllowResize then
  	exit;
  if (SelectedPoint = nil) and (SelectedMidPoint = nil) then
    PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.ScaleSimple := 1.0;
  OverPoint := false;
end;

function TBlackSharkSelectorBB.SelectPlane(X, Y: int32): TVec4f;
var
  ori_s, up, right: TVec3f;
  p3: TVec2f;
  d : BSFloat;
  n1: TVec3f;
  //_x, _y: int32;
begin
  up := vec3(abs(Canvas.Renderer.Frustum.Up.x) + abs(Direction.x), abs(Canvas.Renderer.Frustum.Up.y) + abs(Direction.y), abs(Canvas.Renderer.Frustum.Up.z) + abs(Direction.z));
  right := vec3(abs(Canvas.Renderer.Frustum.Right.x) + abs(Direction.x), abs(Canvas.Renderer.Frustum.Right.y) + abs(Direction.y), abs(Canvas.Renderer.Frustum.Right.z) + abs(Direction.z));
  if VecLenSqr(up) > VecLenSqr(right) then
  begin
    if X > 0 then
      p3 := vec2(0, Y)
    else
      p3 := vec2(Canvas.Renderer.WindowWidth, Y);
  end else
  begin
    if Y > 0 then
      p3 := vec2(X, 0)
    else
      p3 := vec2(X, Canvas.Renderer.WindowHeight);
  end;


  ori_s := Canvas.Renderer.ScreenPositionToScene(X, Y, 0)*BSConfig.VoxelSize;
  Result := Plane(Canvas.Renderer.Frustum.Position, ori_s, Canvas.Renderer.ScreenPositionToScene(p3.x, p3.y, 0)*BSConfig.VoxelSize);
  n1 := TVec3f(Result);
  d := VecDot(n1, Direction);
  if d < 0 then
    Result := - Result;

  {if (Direction.y > 0) or (Direction.x > 0) or (Direction.z > 0) then
    Result := Plane(Renderer.Frustum.Position, ori_s, FScene.ScreenPositionToScene(p3.x, p3.y, 0)) else
    Result := Plane(Renderer.Frustum.Position, FScene.ScreenPositionToScene(p3.x, p3.y, 0), ori_s); }
  //Result := VecNormalize(Result);
end;

procedure TBlackSharkSelectorBB.SetAllowDrag(const Value: boolean);
begin
  FAllowDrag := Value;
end;

procedure TBlackSharkSelectorBB.SetMinimalSize(const Value: TVec3f);
var
  s: BSFloat;
begin
  FMinimalSize := Value;
  s := BSConfig.VoxelSize*10;
  if FMinimalSize.x < s then
    FMinimalSize.x := s;
  if FMinimalSize.y < s then
    FMinimalSize.y := s;
  if FMinimalSize.z < s then
    FMinimalSize.z := s;
end;

procedure TBlackSharkSelectorBB.SetSelectItem(AValue: PRendererGraphicInstance);
begin
  if FSelectItem = AValue then
    exit;
  if Assigned(FSelectItem) then
  begin
    FSelectItem.Instance.DragResolve := DragResolve;
    HidePoints;
  end;
  inherited;
  if Assigned(FSelectItem) then
  begin
    DragResolve := FSelectItem.Instance.DragResolve;
    ShowPointsDo;
  end;
end;

procedure TBlackSharkSelectorBB.SetShowLines(const Value: boolean);
begin
  if FShowLines = Value then
    exit;
  FShowLines := Value;
  if FShowLines then
  begin
    if Assigned(FSelectItem) then
    begin
    	FillLines;
      Lines.Parent := FSelectItem.Instance.Owner;
    end;
  end else
    Lines.Parent := nil;
  Lines.Hidden := not FShowLines;
end;

procedure TBlackSharkSelectorBB.SetShowMiddlePoints(const Value: boolean);
begin
  FShowMiddlePoints := Value;
  if FShowMiddlePoints then
    ShowMiddlePointsDo
  else
    HideMiddlePoints;
end;

procedure TBlackSharkSelectorBB.ShowDragArea;
begin

end;

procedure TBlackSharkSelectorBB.ShowMiddlePointsDo;
var
  pl: TBoxPlanes;
  bb: PBox3f;
begin
  if FSelectItem = nil then
    exit;
  bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;// ;
  for pl := Low(TBoxPlanes) to High(TBoxPlanes) do
  begin
    if FPointsMid[pl].Data.BaseInstance.IsDrag or
       ((bb^.x_min = 0) and ((APROPRIATE_MID[pl, 0] = xMin) or (APROPRIATE_MID[pl, 0] = xMax))) or
       ((bb^.y_min = 0) and ((APROPRIATE_MID[pl, 1] = yMin) or (APROPRIATE_MID[pl, 1] = yMax))) or
       ((bb^.z_min = 0) and ((APROPRIATE_MID[pl, 2] = zMin) or (APROPRIATE_MID[pl, 2] = zMax))) then
          continue;
    FPointsMid[pl].Layer2d := FSelectItem.Instance.Owner.CountParents + 10;
    FPointsMid[pl].Position2d := Canvas.Renderer.ScenePositionToScreenf(
      FSelectItem.Instance.ProdStackModelMatrix * vec3( //
      bb^.Named[APROPRIATE_MID[pl, 0]],
      bb^.Named[APROPRIATE_MID[pl, 1]],
      bb^.Named[APROPRIATE_MID[pl, 2]])
      ) + vec2(-RADIUS_POINTS, RADIUS_POINTS*SIGN[APROPRIATE_MID[pl, 0] = yMin]);
      FPointsMid[pl].Data.Hidden := false;
  end;
end;

procedure TBlackSharkSelectorBB.ShowPointsDo;
var
  p: TBBPoints;
  bb: PBox3f;
begin
  if FSelectItem = nil then
    exit;
  bb := @FSelectItem.Instance.Owner.Mesh.FBoundingBox;
  for p := low(TBBPoints) to high(TBBPoints) do //pXminYmaxZmax
  begin
    if (bb^.x_min = 0) and (APROPRIATE_BB_POINTS[p, 0] = xMin) or
       (bb^.y_min = 0) and (APROPRIATE_BB_POINTS[p, 1] = yMin) or
       (bb^.z_min = 0) and (APROPRIATE_BB_POINTS[p, 2] = zMin) then
          continue;
    FPointsBB[p].Layer2d := FSelectItem.Instance.Owner.CountParents + 10;
    FPointsBB[p].Position2d := Canvas.Renderer.ScenePositionToScreenf(
      FSelectItem.Instance.ProdStackModelMatrix * vec3(  //
      bb^.Named[APROPRIATE_BB_POINTS[p, 0]],
      bb^.Named[APROPRIATE_BB_POINTS[p, 1]],
      bb^.Named[APROPRIATE_BB_POINTS[p, 2]])) +
      vec2(-RADIUS_POINTS, RADIUS_POINTS*SIGN[APROPRIATE_BB_POINTS[p, 0] = yMin]);
    FPointsBB[p].Data.Hidden := false;
  end;

  if FShowLines then
  begin
    FillLines;
    Lines.Parent := FSelectItem.Instance.Owner;
    Lines.Hidden := false;
  end;
  if FShowMiddlePoints then
    ShowMiddlePointsDo;
end;

procedure TBlackSharkSelectorBB.SetShowPoints(AValue: boolean);
begin
  if FShowPoints = AValue then
    Exit;
  FShowPoints := AValue;
	if FShowPoints then
  begin
    if FShowMiddlePoints then
      ShowMiddlePointsDo
    else
      ShowPointsDo;
  end else
  begin
    HidePoints;
  end;
end;

procedure TBlackSharkSelectorBB.Transform(var Delta: TVec3f; NewDistance: BSFloat; const Point: TBBLimitPoint);
var
  s: TVec3f;
  d: BSFloat;
  delta_size: TVec3f;
begin

  if not BeginResizeSend then
  begin
    BeginResizeSend := true;
    if Assigned(FOnBeginResize) then
      FOnBeginResize(FSelectItem.Instance);
  end;

  d := 0.5;

  if (Delta.X < 0.0) and (abs(Delta.X) * d > FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max) then
    Delta.X := 0;
  if (Delta.Y < 0.0) and (abs(Delta.Y) * d > FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max) then
    Delta.Y := 0;
  if (Delta.Z < 0.0) and (abs(Delta.Z) * d > FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max) then
    Delta.Z := 0;

  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max > EPSILON then
    s.x := abs((FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max + Delta.X*d) / FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max)
  else
    s.x := 1.0;
  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max > EPSILON then
    s.y := abs((FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max + Delta.Y*d) / FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max)
  else
    s.y := 1.0;
  if FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max > EPSILON then
    s.z := abs((FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max + Delta.Z*d) / FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max)
  else
    s.z := 1.0;

  //if Reduce then
  begin
    if FSelectItem.Instance.Owner.Mesh.FBoundingBox.x_max * s.x < FMinimalSize.x then
    begin
      s.x := 1.0;
      Delta.x := 0.0;
    end;
    if FSelectItem.Instance.Owner.Mesh.FBoundingBox.y_max * s.y < FMinimalSize.y then
    begin
      s.y := 1.0;
      Delta.y := 0.0;
    end;
    if FSelectItem.Instance.Owner.Mesh.FBoundingBox.z_max * s.z < FMinimalSize.z then
    begin
      s.z := 1.0;
      Delta.z := 0.0;
    end;
  end;

  if Assigned(FOnResizeGraphicObjectInstance) then
  begin
    FOnResizeGraphicObjectInstance(FSelectItem.Instance, vec3(abs(s.x), abs(s.y), abs(s.z)), Point);
  end else
  begin
    if FFixOppositeSideWhenResize then
    begin
      s := vec3(abs(s.x), abs(s.y), abs(s.z));
      s := vec3(1.0, 1.0, 1.0) + (vec3(abs(s.x), abs(s.y), abs(s.z))-vec3(1.0, 1.0, 1.0))*0.5;
      delta_size := FSelectItem.Instance.BoundingBox.Max - FSelectItem.Instance.BoundingBox.Min;
      FSelectItem.Instance.Owner.Mesh.TransformScale(s);
      FSelectItem.Instance.Owner.ChangedMesh;
      delta_size := (FSelectItem.Instance.BoundingBox.Max - FSelectItem.Instance.BoundingBox.Min) - delta_size;
      delta_size.x := -delta_size.x;
      FSelectItem.Instance.Owner.Position := FSelectItem.Instance.Owner.Position - delta_size*0.5;
    end else
    begin
      FSelectItem.Instance.Owner.Mesh.TransformScale(Delta.x, Delta.y, Delta.z);
      FSelectItem.Instance.Owner.ChangedMesh;
    end;

  end;
  FillLines;
  LastDistance := NewDistance;
  BBMiddle := TVec3f(FSelectItem.Instance.ProdStackModelMatrix.M3);
end;

{ TBlackSharkRotor3D }

procedure TBlackSharkRotor3D.Clear;
begin
  if Assigned(RotorX) then
  begin
    ObsrvOnResetClick := nil;
    RotorX.MainBody.Parent := nil;
    RotorY.MainBody.Parent := nil;
    RotorZ.MainBody.Parent := nil;
    Reset.MainBody.Parent := nil;
    FreeAndNil(RotorX);
    FreeAndNil(RotorY);
    FreeAndNil(RotorZ);
    FreeAndNil(Reset);
  end;
  Canvas.Clear();
end;

constructor TBlackSharkRotor3D.Create(ACanvas: TBCanvas);
begin
  inherited Create(ACanvas);
  FReduceOpacity := false;
  FShowAxis := true;
  CreateAxis;
  RotorX := TBRadialSlider.Create(Canvas);
  RotorX.Caption := 'X';
  RotorX.OnChangeDegree := OnChangeDegreeX;
  RotorX.CaptionColor := BS_CL_RED;
  RotorX.ResetPositionEveryTime := true;
  RotorX.MainBody.Parent := Root;
  RotorY := TBRadialSlider.Create(Canvas);
  RotorY.Caption := 'Y';
  RotorY.OnChangeDegree := OnChangeDegreeY;
  RotorY.CaptionColor := BS_CL_GREEN;
  RotorY.ResetPositionEveryTime := true;
	RotorY.MainBody.Parent := Root;
  RotorZ := TBRadialSlider.Create(Canvas);
  RotorZ.Caption := 'Z';
  RotorZ.OnChangeDegree := OnChangeDegreeZ;
  RotorZ.CaptionColor := BS_CL_BLUE;
  RotorZ.ResetPositionEveryTime := true;
  RotorZ.MainBody.Parent := Root;
  Reset := TBButton.Create(Canvas);
  Reset.Resize(RotorX.Width*0.75, RotorX.Height*0.35);
  Reset.Canvas.Font.Size := 8;
  Reset.Caption := 'Reset';
  Reset.Visible := false;
  Reset.MainBody.Parent := Root;

  ObsrvOnResetClick := Reset.OnClickEvent.CreateObserver(GUIThread, OnMouseDownOnReset);
  ObsrvOnRotXClick := RotorX.BodyObject.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownOnRotor);
  ObsrvOnRotYClick := RotorY.BodyObject.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownOnRotor);
  ObsrvOnRotZClick := RotorZ.BodyObject.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownOnRotor);
end;

procedure TBlackSharkRotor3D.CreateAxis;
begin
  if Axises <> nil then
    exit;
  Axises := TGraphicObjectAxises.Create(Self, nil, Canvas.Renderer.Scene);
  if FSelectItem <> nil then
    ShowAxisDo
  else
    Axises.SetHiddenRecursive(true);
end;

destructor TBlackSharkRotor3D.Destroy;
begin
  ObsrvOnResetClick := nil;

  ObsrvOnRotXClick := nil;
  ObsrvOnRotYClick := nil;
  ObsrvOnRotZClick := nil;

  RotorX.MainBody.Parent := nil;
  RotorX.Free;
  RotorY.MainBody.Parent := nil;
  RotorY.Free;
  RotorZ.MainBody.Parent := nil;
  RotorZ.Free;
  Reset.MainBody.Parent := nil;
  Reset.Free;
  if Assigned(Axises) then
  begin
    Axises.Parent := nil;
    Axises.Free;
  end;
  inherited;
end;

procedure TBlackSharkRotor3D.OnChangeDegreeX(Sender: TBRadialSlider);
begin
  Rotating := true;
  try
    FSelectItem.Instance.Owner.AngleX := StartAngle.x - Sender.Degree;
  finally
    Rotating := false;
  end;
end;

procedure TBlackSharkRotor3D.OnChangeDegreeY(Sender: TBRadialSlider);
begin
  Rotating := true;
  try
    FSelectItem.Instance.Owner.AngleY := StartAngle.y - Sender.Degree;
  finally
    Rotating := false;
  end;
end;

procedure TBlackSharkRotor3D.OnChangeDegreeZ(Sender: TBRadialSlider);
begin
  Rotating := true;
  try
    FSelectItem.Instance.Owner.AngleZ := StartAngle.z - Sender.Degree;
  finally
    Rotating := false;
  end;
end;

procedure TBlackSharkRotor3D.OnChangeMVPDo;
var
  bb: PBox3f;
  pos: TVec2f;
  h: BSFloat;
begin
  if Rotating then
    exit;
  bb := @FSelectItem.Instance.BoundingBox;
  pos := Canvas.Renderer.ScenePositionToScreenf(vec3(
      bb^.Named[xMax],
      bb^.Named[yMin],
      bb^.Named[zMid]));
  h := RotorX.Border.Height;
  Root.Position2d := pos;
  RotorY.Position2d := vec2(h*0.5 + 15, -h*0.5);
  RotorZ.Position2d := vec2(10, -h*0.5 + h + 24);
  RotorX.Position2d := vec2(h + 20, -h*0.5 + h + 24);
  Reset.Position2d := vec2(h - 5, -h*0.5 + h + 4);
end;

procedure TBlackSharkRotor3D.OnMouseDownOnReset(const Data: BMouseData);
begin
  if FSelectItem <> nil then
    begin
    Rotating := true;
    try
      FSelectItem.Instance.Owner.SetAngleInstance(FSelectItem.Instance, vec3(0.0, 0.0, 0.0));
      RotorX.Degree := 0.0;
      RotorY.Degree := 0.0;
      RotorZ.Degree := 0.0;
    finally
      Rotating := false;
    end;
    end;
end;

procedure TBlackSharkRotor3D.OnMouseDownOnRotor(const Data: BMouseData);
begin
  StartAngle := FSelectItem.Instance.Angle;
end;

procedure TBlackSharkRotor3D.SetReduceOpacity(const Value: boolean);
begin
  FReduceOpacity := Value;
  if FSelectItem <> nil then
    begin
    if FReduceOpacity then
      FSelectItem.Instance.Owner.Opacity := 0.3 else
      FSelectItem.Instance.Owner.Opacity := StartOpacity;
    end;
end;

procedure TBlackSharkRotor3D.SetSelectItem(AValue: PRendererGraphicInstance);
begin
  if Assigned(FSelectItem) then
    FSelectItem.Instance.Owner.Opacity := StartOpacity;
  inherited;
  RotorX.Visible := Assigned(FSelectItem);
  RotorY.Visible := Assigned(FSelectItem);
  RotorZ.Visible := Assigned(FSelectItem);
  Reset.Visible := Assigned(FSelectItem);
  if Assigned(FSelectItem) then
  begin
    if FShowAxis then
      ShowAxisDo;
    StartOpacity := FSelectItem.Instance.Owner.Opacity;
    if FReduceOpacity then
      FSelectItem.Instance.Owner.Opacity := 0.3;
    RotorX.MainBody.Layer2d := FSelectItem.Instance.Owner.CountParents + 2;
    RotorY.MainBody.Layer2d := FSelectItem.Instance.Owner.CountParents + 2;
    RotorZ.MainBody.Layer2d := FSelectItem.Instance.Owner.CountParents + 2;
    Reset.MainBody.Layer2d := FSelectItem.Instance.Owner.CountParents + 2;
    OnChangeMVPDo;
  end else
  if Axises <> nil then
  begin
    Axises.Parent := nil;
    Axises.SetHiddenRecursive(true);
  end;
end;

procedure TBlackSharkRotor3D.SetShowAxis(const Value: boolean);
begin
  if FShowAxis = Value then
    exit;
  FShowAxis := Value;
  if FShowAxis then
  begin
    CreateAxis;
  end else
  begin
    FreeAndNil(Axises);
  end;
end;

procedure TBlackSharkRotor3D.ShowAxisDo;
var
  s: TVec3f;
  shape_size: TVec3f;
  w: BSFloat;
  max_s: BSFloat;
begin
  w := Axises.Size;
  if w = 0 then
    exit;
  shape_size := FSelectItem.Instance.Owner.Mesh.FBoundingBox.Max*2;
  s := shape_size / vec3(w, w, w) + 0.1;
  if shape_size.x = 0 then
  begin
    if shape_size.y <> 0 then
      s.x := s.y
    else
      s.x := s.z;
  end;
  if shape_size.y = 0 then
  begin
    if shape_size.z <> 0 then
      s.y := s.z
    else
      s.y := s.x;
  end;
  if shape_size.z = 0 then
  begin
    if shape_size.x <> 0 then
      s.z := s.x
    else
      s.z := s.y;
  end;
  max_s := bs.math.max(s.x, bs.math.max(s.y, s.z));
  Axises.SetHiddenRecursive(false);
  Axises.Parent := FSelectItem.Instance.Owner;
  Axises.AxelX.Scale := vec3(s.x, max_s, max_s);
  Axises.AxelY.Scale := vec3(max_s, s.y, max_s);
  Axises.AxelZ.Scale := vec3(max_s, max_s, s.z);
end;

end.

