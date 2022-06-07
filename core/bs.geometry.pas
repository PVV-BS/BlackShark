{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised June, 2022

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


unit bs.geometry;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , Classes
  , bs.basetypes
  , bs.collections
  , bs.math
  ;

const
  MIN_COUNT_AABB = 2;
  MAX_COUNT_AABB = 8;
type

  PNodeSpaceTree = ^TNodeSpaceTree;
  TBiDiListNodes = TListDual<PNodeSpaceTree>;
  TListNodes = TListVec<PNodeSpaceTree>;
  TNodeSpaceTree = record
  private
    { the var valid only if visible in a tree; if a directive DEBUG_ST off, then
      this var will used only for leaf nodes, containing an user model a data }
    __PosInList: TBiDiListNodes.PListItem;
  public
    Volume: BSFloat;
    { further variables need for support the tree }
    Parent: PNodeSpaceTree;
    { relatively self position in the Parent.Childs }
    Next: PNodeSpaceTree;
    Prev: PNodeSpaceTree;

    Childs: PNodeSpaceTree;
    CountChilds: int32;
    { it is bounding box of the node; besides, it is a container for data of user }
    BB: TBox3d; //record end; //TBoxTmpl3<T>;
  end;

  TOnChangeNode = procedure(Node: PNodeSpaceTree) of object;

  {
    TBlackSharkSpaceTree

    Little a theory:
    - KD-tree - divides the space on cuboids (for 2d - rectangles, that is don't
    take into account one of axes); a boundary of divide one of Dimension selects
    by a special function (algorithm); more suits for contain models in a static
    scene and ray-tracing;
    - R-tree - divides the space on AABB nodes contains inscribed geometry objects;
    AABB nodes can intersect; the tree is balanced; it more suits for contain
    models in a dynamic scene }

  {
    a directive DEBUG_ST defines a debug mode which allows to include set propertes:
      - events on show/hide of service nodes
      - event on changes a size of service nodes
      - event on updates a position of service nodes when change a view port
    What would to have worked the test TBSTestScrollBoxSpaceTree needely to enable
    the directive
    }

  {.$ifdef DEBUG_BS}
    {$define DEBUG_ST}
  {.$endif}

  TBlackSharkSpaceTreeClass = class of TBlackSharkSpaceTree;

  TBlackSharkSpaceTree = class abstract
  private
    CashNodes: PNodeSpaceTree;
    FOnHideUserData: TOnChangeNode;
    FOnShowUserData: TOnChangeNode;
    FOnUpdatePositionUserData: TOnChangeNode;
    TmpList: TListNodes;
    FOnDeleteUserData: TOnChangeNode;
    {$ifdef DEBUG_ST}
    FOnUpdatePositionNoLeafNode: TOnChangeNode;
    FOnShowNoLeafNode: TOnChangeNode;
    FOnHideNoLeafNode: TOnChangeNode;
    FOnChangeSizeNoLeafNode: TOnChangeNode;
    FVisibleNoLeafNodes: TBiDiListNodes;
    ListHidingNoLeafNodes: TBiDiListNodes;
    {$endif}
  protected
    FCount: int32;
    FRoot: PNodeSpaceTree;
    Stack: TListVec<PNodeSpaceTree>;
    ListHidingData: TBiDiListNodes;
    FVisibleData: TBiDiListNodes;
    FViewPort: TBox3d;
    FDimensions: TAxisSet;
    FSelecting: boolean;
    function DoCreateNode: PNodeSpaceTree; inline;
    function CreateNode(Parent: PNodeSpaceTree): PNodeSpaceTree;
    procedure FreeNode(Node: PNodeSpaceTree); inline;
    procedure ToCashNode(Node: PNodeSpaceTree); inline;
    procedure ChangeVisibility(Node: PNodeSpaceTree; Visibility: boolean); {$ifndef DEBUG_ST} inline; {$endif}
    procedure OnChangeSizeNoLeafNodeDo(Node: PNodeSpaceTree); {$ifndef DEBUG_ST}  inline; {$endif}
    procedure RecalcBB(Node: PNodeSpaceTree); {$ifndef DEBUG_ST} inline;  {$endif}
    procedure CheckGrowBB(Node: PNodeSpaceTree; const BB: TBox3d); {$ifndef DEBUG_ST} inline;  {$endif}
    { remove from tree; !!! don't recalc BB parents and don't pushes to cash }
    procedure DoRemoveFromTree(Node: PNodeSpaceTree); inline;
    procedure DoInsertToTree(Parent, Node: PNodeSpaceTree); inline;
    function CheckExtraNode(NoLeafNode: PNodeSpaceTree): boolean; {$ifndef DEBUG_ST} inline; {$endif}
  public
    constructor Create; virtual;
    destructor Destroy; override;
    { sets a position of view port and him size; when invokes this method then
      can happen enents OnHideUserData and OnShowUserData }
    procedure ViewPort(const BB: TBox3d); overload; // virtual;
    procedure ViewPort(X, Y, Width, Height: double); overload;
    procedure ViewPortUpdateSilent(X, Y, Width, Height: double);
    { methods selects a data in any area; in different from ViewPort don't happen enents
      OnHideUserData and OnShowUserData }
    procedure SelectData(X, Y, Width, Height: double; var List: TListNodes); overload;
    procedure SelectData(const BB: TBox3d; var List: TListNodes); overload;
    { additions a Data to spatial tree; Node declared as "out" (not Result function)
      for possibility to assign to him out a value befor invoked events OnShowUserData/OnHideUserData }
    procedure Add(Data: Pointer; const BB: TBox3d; out Node: PNodeSpaceTree); overload; virtual; abstract;
    { wrapper for adding in 2d }
    procedure Add(Data: Pointer; X, Y, Width, Height: double; out Node: PNodeSpaceTree); overload;
    procedure Add(Data: Pointer; const Position, Size: TVec2d; out Node: PNodeSpaceTree); overload;
    { updates position in the spatial tree }
    function UpdatePosition(OldPosition: PNodeSpaceTree; const NewBB: TBox3d): PNodeSpaceTree; overload; virtual; abstract;
    { wrapper for update in 2d }
    function UpdatePosition(OldPosition: PNodeSpaceTree; X, Y, Width, Height: Double): PNodeSpaceTree; overload;
    function UpdatePosition(OldPosition: PNodeSpaceTree; const Position, Size: TVec2d): PNodeSpaceTree; overload;
    { deletes Data from the space tree }
    procedure Remove(Position: PNodeSpaceTree); virtual;
    { Node is contaning a list user's BB? }
    function IsLeaf(Node: PNodeSpaceTree): boolean; inline;
    { !!!DO NOT TESTED!!! Find first Leaf on way Normal from Origin point - pick with Ray(Origin, Normal) }
    function PickNearesLeaf(const Origin: TVec3f; const Normal: TVec3f; out Distance: BSFloat): PNodeSpaceTree; overload;
    { !!!DO NOT TESTED!!! }
    function PickNearesLeaf(const P0, P1, P2, P3: TVec3f; out Distance: BSFloat): PNodeSpaceTree; overload;

    procedure Clear;
    property VisibleData: TBiDiListNodes read FVisibleData;
    { triggers for notify when show/hide BB containing an user data }
    property OnHideUserData: TOnChangeNode read FOnHideUserData write FOnHideUserData;
    property OnShowUserData: TOnChangeNode read FOnShowUserData write FOnShowUserData;
    property OnDeleteUserData: TOnChangeNode read FOnDeleteUserData write FOnDeleteUserData;
    { an event for a visible data when changes viewport and the data already visible;
      for the user data which will be showing invokes only the OnShowUserData
      event }
    property OnUpdatePositionUserData: TOnChangeNode read FOnUpdatePositionUserData write FOnUpdatePositionUserData;
    property Root: PNodeSpaceTree read FRoot;
    property Dimensions: TAxisSet read FDimensions write FDimensions;
    property CurrentViewPort: TBox3d read FViewPort;
    { if it is true then executes of the data selection }
    property Selecting: boolean read FSelecting;
    property Count: int32 read FCount;
    { Debug property }
    {$ifdef DEBUG_ST}
    property OnHideNoLeafNode: TOnChangeNode read FOnHideNoLeafNode write FOnHideNoLeafNode;
    property OnShowNoLeafNode: TOnChangeNode read FOnShowNoLeafNode write FOnShowNoLeafNode;
    property OnUpdatePositionNoLeafNode: TOnChangeNode read FOnUpdatePositionNoLeafNode write FOnUpdatePositionNoLeafNode;
    property OnChangeSizeNoLeafNode: TOnChangeNode read FOnChangeSizeNoLeafNode write FOnChangeSizeNoLeafNode;
    property VisibleNodes: TBiDiListNodes read FVisibleNoLeafNodes;
    {$endif}
  end;

  { The class present R-tree algorithm }

  TBlackSharkRTree = class(TBlackSharkSpaceTree)
  private
    type
      TSide = (sLeft, sRight);
  private
    TmpNodes: TListVec<PNodeSpaceTree>;
    TmpLists: array[TAxis3d, TSide] of TListVec<PNodeSpaceTree>;
    function ChooseNode(const BB: TBox3d): PNodeSpaceTree;
    function SplitNode(Node: PNodeSpaceTree; Data: Pointer; const BB: TBox3d): PNodeSpaceTree; overload;
    procedure SplitNode(Node: PNodeSpaceTree); overload;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Add(Data: Pointer; const BB: TBox3d; out Node: PNodeSpaceTree); override;
    function UpdatePosition(OldPosition: PNodeSpaceTree; const NewBB: TBox3d): PNodeSpaceTree; override;
  end;

  { for 1024 Dimensions }
  TBoxMinMax = array[0..1023] of double;
  PBoxMinMax = ^TBoxMinMax;

  TSplitDimensionNotify = procedure(ADem: int32; AVectorMinMax: PBoxMinMax; ABoundary: double) of object;

  TBlackSharkKDTree = class
  private
  type
    TDimensionItem = record
      ParentDem: int32;
      Dimension: int32;
      Left: int32;
      Right: int32;
      // count items in Data;
      Count: int32;
      Data: array of Pointer;
    end;
    TDimensionItems = array of TDimensionItem;
    TKeys = array of double;
  private
    FDimension: TDimension;
    FDimensionDouble: TDimension;

    CashDimItems: TListVec<int32>;
    FDimensionItems: TDimensionItems;
    { all keys are storing to FKeys because Delphi doesn't support templates, and in depend on
      FDimension are doing a request of memory in an apropriate quantity;
      a position of a key is defined by index of TDimensionItem in FDimensionItems: FKeys[index*FDimensionDouble];
      every key consists of Min and Max for every Dimension; }
    FKeys: TKeys;

    FRoot: int32;
    Stack: TListVec<int32>;
    FMinSize: double;
    FMinSize2x: double;
    FMinSize10x: double;
    FMinSize100x: double;
    FNodes: int32;
    FCount: int32;
    FOnSplitDimension: TSplitDimensionNotify;
    function GetDimensionItemDo(AParentDem: int32; ADimension: int32; AMin, AMax: double): int32; inline;
    function GetDimensionItem(AParentDem: int32; ADimension: int32; AMin, AMax: double): int32; inline;
    procedure SplitNode(ANode: int32; ADimension: int32; ABoundary: double);
    { it is invoked only if AData fits into ANode; that is if ANode has children Dimensions
      then not need to check them, because AData doesn't hit }
    function Insert(ANode: int32; AData: Pointer; AVectorMinMax: PBoxMinMax; OldPosition: int32): int32; inline;
    procedure Init;
    procedure DoDelete(ADem: int32; AData: Pointer); inline;
    function DoAdd(AData: Pointer; AVectorMinMax: PBoxMinMax; OldPosition: int32 = -1): int32; inline;
  public
    constructor Create(AMinSize: double; ADimension: TDimension = TDimension3D); overload;
    constructor Create(ADimension: TDimension = TDimension3D); overload;
    destructor Destroy; override;
    procedure Clear; virtual;
    function AddBB(AData: Pointer; AVectorMinMax: PBoxMinMax): int32; overload;
    { and again; because delphi doesn't support templates (and mathematical operations in them)
      we created overloaded methods for 3d float type }
    function AddBB(AData: Pointer; const AVectorMinMax: TBox3f): int32; overload;
    {$ifdef DEBUG_ST}
    function GetNodeAttributes(ANode: int32; out ABox: PBoxMinMax; out ADimensionSplit: int32; out ABoundarySplit: double;
      out ALeft, ARight: int32): boolean;
    {$endif}
    function UpdatePositionBB(AData: Pointer; VectorMinMax: PBoxMinMax; OldPosition: int32): int32; overload;
    function UpdatePositionBB(AData: Pointer; const AVectorMinMax: TBox3f; OldPosition: int32): int32; overload;
    procedure Remove(APosition: int32; AData: Pointer);
    procedure Select(ABox: PBoxMinMax; AList: TListVec<Pointer>); overload;
    procedure Select(const AVectorMinMax: TBox3f; AList: TListVec<Pointer>); overload;
    { count of Dimensions: 1, 2, 3... }
    property Dimension: TDimension read FDimension;
    property MinSize: double read FMinSize;
    property Nodes: int32 read FNodes;
    property Count: int32 read FCount;
    { for debug only }
    {$ifdef DEBUG_ST}
    property Root: int32 read FRoot;
    property OnSplitDimension: TSplitDimensionNotify read FOnSplitDimension write FOnSplitDimension;
    {$endif}
  end;

  {
    TAreaMarker

    The class allows to mark space with BB; if a some point in space hit into
    BB-marker then it marker is unique in this point, because when you throw
    markers they analysed on intersects and divided on not intersected areas
    with deleting one of two intersected part; it allows uniquely define
    selected data (areas) by way iterating a couple of methods - GetFirstArea,
    GetNextArea }

  TAreaMarker = class
  private
    FSpaceTree: TBlackSharkSpaceTree;
    TmpListNodes: TListNodes;
    TmpListBB: array[boolean] of TListVec<TBox3d>;
    FixedStream: TMemoryStream;

    StepSelectY: BSFloat;
    StepSelectZ: BSFloat;
    GranularitySelY, GranularitySelZ: BSFloat;
    ListNodesSelect: TListVec<TBox3d>;

    { Current selected area }
    CurrentBox: TBox3d;
    CurrentForSelectBox: TBox3d;
    LastSelectedArea: TBox3d;

    procedure BreakNode(Node: PNodeSpaceTree; const Overlap: TBox3d);
    { if BB will be absorbed with other areas then return true }
    function UnionWithAreas(const BB: TBox3d; CancelArea: boolean; ExceptNode: PNodeSpaceTree): boolean;
    procedure SelectNodesInCurrentBox;
  protected
    function SaveArea(ToStream: TStream; Node: PNodeSpaceTree): int32; virtual;
    function LoadArea(FromStream: TStream): int32; virtual;
  public
    constructor Create(ASpaceTree: TBlackSharkSpaceTree);
    destructor Destroy; override;
    procedure Clear;
    { Takes a first marked area; begin to find from minimal value root's BB
      Parameters:
      - StepY, StepZ - it is size your a space grid, that is size of BB for search
        areas; size on Axes X take from x size root's BB, that is all width;
      - GranularityY, GranularityZ - limits of size minimal marked area; depend
        on your system (for example, for marking screen limits 1, 1 appropriately,
        that is equal one pixel);
      - Area - found first area;
      Return true if although one area exists;
      }
    function GetFirstArea({StepX is wide a current area} StepY, StepZ: double;
      GranularityY: double; GranularityZ: double; out Area: TBox3d): boolean;
    { Takes a next marked area }
    function GetNextArea(out Area: TBox3d): boolean;
    { The procedure saving just areas (boxes) to a list }
    procedure Save(List: TListVec<TBox3d>); overload;
    procedure Save(List: TListVec<PNodeSpaceTree>); overload;
    procedure Save(Stream: TStream); overload; virtual;
    procedure Save(const FileName: string); overload;
    { Load marked areas }
    procedure Load(List: TListVec<TBox3d>); overload;
    procedure Load(Stream: TStream); overload;
    procedure Load(const FileName: string); overload;
    { Fixed current marked areas into inner buffer }
    procedure StateFix;
    { Recover state areas fixed early by StateFix }
    procedure StateRecovery;
    procedure Invert(const FullArea: TRectBSd); overload;
    procedure Invert(const FullBB: TBox3d); overload;
    procedure Invert(X, Y, Width, Height: double); overload;
    function AddArea(X, Y, Width, Height: double; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree; overload;
    function AddArea(const Area: TRectBSd; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree; overload;
    function AddArea(const BB: TBox3d; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree; overload;
    function GetAreaWidth(const Position: TVec2d; Width, Height: Double): double;
    function DelArea(const Position: TVec2d; Width, Height: double): boolean;
    property SpaceTree: TBlackSharkSpaceTree read FSpaceTree;
  end;

  function RayIntersectTriangle(const Ray: TRay3f; const Triangle: TTriangle3f; out Distance: BSFloat): boolean; overload; inline;
  function RayIntersectTriangle(const Ray: TRay3f; const A, B, C: TVec3f; out Distance: BSFloat): boolean; overload;  inline;
  function IntersectTriangles(const Triangle1, Triangle2: TTriangle3f; out Dist: BSFloat): boolean; inline; overload;
  function IntersectTriangles(const A1, B1, C1, A2, B2, C2: TVec3f; out Dist: BSFloat): boolean; inline; overload;
  function TriangleIntersectBox(const Triangle: TTriangle3f; const Box: TBox3f; out Dist: BSFloat): boolean; inline;
  // !!! the method works only if Box places into centre XYZ
  function RayIntersectBox(const Ray: TRay3f; Box: PBox3f; out Distance: BSFloat): boolean; inline;
  function PointInsideTriangle(const Triangle: TTriangle3f; const Point: TVec3f): boolean; inline; overload;
  function PointInsideTriangle(const Triangle: TTriangle2f; const Point: TVec2f): boolean; inline; overload;

  function LinesIntersect(const P00, P01, P10, P11: TVec2f; out Point: TVec2f): boolean; overload; inline;
  function LinesIntersectExclude(const P00, P01, P10, P11: TVec2f): boolean; overload; inline;
  function LinesIntersectExclude(const P00, P01, P10, P11: TVec2f; out Point: TVec2f): boolean; overload; inline;
  function PointBetween(const P00, P01, Point: TVec3f): boolean; overload; inline;
  function PointBetween(const P00, P01, Point: TVec2f): boolean; overload; inline;
  // function return point projection to line [LineStart; LineStop]
  function GetProjectionPoint(const LineStart, LineStop: TVec3f; var Point: TVec3f): boolean; overload; inline;
  function GetProjectionPoint(const LineStart, LineStop: TVec2f; var Point: TVec2f): boolean; overload; inline;
  function GetProjectionPoint(const LineStart, LineStop, Point: TVec3f; out Distance: BSFloat): TVec3f; overload; inline;
  function GetProjectionPoint(const RayDir: TVec3f; const Origin: TVec3f; out Distance: BSFloat; const Point: TVec3f): TVec3f; overload; inline;
  function GetDistanceBetweenPointAndLine(const LineStart, LineStop, Point: TVec3f): BSFloat; inline;
  function ConvertTo2D(const PlanePointLeftBottom, PlanePointLeftTop, PlanePointRightTop: TVec3f; const Point: TVec3f): TVec2f; inline;

implementation

uses
    Math
  ;

function PointBetween(const P00, P01, Point: TVec3f): boolean;
var
  max, min: TVec3f;
begin
  if P00.x > P01.x then
  begin
    max.x := P00.x;
    min.x := P01.x;
  end else
  begin
    max.x := P01.x;
    min.x := P00.x;
  end;
  if P00.y > P01.y then
  begin
    max.y := P00.y;
    min.y := P01.y;
  end else
  begin
    max.y := P01.y;
    min.y := P00.y;
  end;
  if P00.z > P01.z then
  begin
    max.z := P00.z;
    min.z := P01.z;
  end else
  begin
    max.z := P01.z;
    min.z := P00.z;
  end;
  Result := (Point.x >= min.x) and (Point.y >= min.y) and (Point.z >= min.z) and
    (Point.x <= max.x) and (Point.y <= max.y) and (Point.z <= max.z);
end;

function PointBetween(const P00, P01, Point: TVec2f): boolean;
var
  max, min: TVec3f;
begin
  if P00.x > P01.x then
  begin
    max.x := P00.x;
    min.x := P01.x;
  end else
  begin
    max.x := P01.x;
    min.x := P00.x;
  end;
  if P00.y > P01.y then
  begin
    max.y := P00.y;
    min.y := P01.y;
  end else
  begin
    max.y := P01.y;
    min.y := P00.y;
  end;
  Result := (Point.x >= min.x) and (Point.y >= min.y) and (Point.x <= max.x) and (Point.y <= max.y);
end;

function GetProjectionPoint(const LineStart, LineStop: TVec3f; var Point: TVec3f): boolean;
var
  v, vn, res: TVec3f;
  a, l: BSFloat;
begin
  v := LineStop - LineStart;
  res := Point - LineStart;
  vn := VecNormalize(v);
  // cos b/w line limits and Point
  a := VecDot(vn, VecNormalize(res));
  //
  if abs(a) > EPSILON then
  begin
    l := VecLen(res)*a;
    res := vn * l;
    //l := VecLen(v);
    //a := VecLen(res);
    if PointBetween(vec3(0.0, 0.0, 0.0), v, res) then
    begin
      Point := res + LineStart;
      Result := true;
    end else
    begin
      Result := false;
    end;
  end else
    Result := false;
end;

function GetProjectionPoint(const RayDir: TVec3f; const Origin: TVec3f; out Distance: BSFloat; const Point: TVec3f): TVec3f;
var
  v: TVec3f;
begin
  v := Origin - Point;
  //res := Point - LineStart;
  //vn := VecNormalize(v);
  Distance := VecDot(RayDir, v);
  //
  Result := Origin + RayDir * Distance;
end;

function GetProjectionPoint(const LineStart, LineStop, Point: TVec3f; out Distance: BSFloat): TVec3f;
{var
  v, vn, res: TVec3f;
  a: BSFloat;  }
begin
  Result := GetProjectionPoint(VecNormalize(LineStart - LineStop), LineStart, Distance, Point);
  {v := LineStop - LineStart;
  res := Point - LineStart;
  vn := VecNormalize(v);
  // cos b/w line limits and Point
  a := VecDot(vn, VecNormalize(res));
  //
  if abs(a) > EPSILON then
    begin
    Distance := VecLen(res)*a;
    res := vn * Distance;
    Result := res + LineStart;
    end else
    begin
    Result := Point;
    Distance := 0.0;
    end;  }
end;

function GetDistanceBetweenPointAndLine(const LineStart, LineStop, Point: TVec3f): BSFloat;
var
  v, vn, res: TVec3f;
  a: BSFloat;
begin
  v := LineStop - LineStart;
  res := Point - LineStart;
  vn := VecNormalize(v);
  // cos b/w line and Point
  a := VecDot(vn, VecNormalize(res));
  //a := VecDot(v, res);
  if abs(a) > EPSILON then
  begin
    Result := VecLen(res) * a;
    v := vn * Result;
    Result := VecLen(res - v);
  end else
  begin
    Result := VecLen(res);
  end;
end;

function ConvertTo2D(const PlanePointLeftBottom, PlanePointLeftTop, PlanePointRightTop: TVec3f;
  const Point: TVec3f): TVec2f;
var
  proj: TVec3f;
  dist: BSFloat;
begin
  proj := PlanePointProjection(Plane(PlanePointLeftBottom, PlanePointLeftTop, PlanePointRightTop), Point, dist);
  Result.x := GetDistanceBetweenPointAndLine(PlanePointLeftTop, PlanePointLeftBottom, proj);
  Result.y := GetDistanceBetweenPointAndLine(PlanePointLeftTop, PlanePointRightTop, proj);
end;

function GetProjectionPoint(const LineStart, LineStop: TVec2f; var Point: TVec2f): boolean;
var
  v: TVec3f;
begin
  v := vec3(Point.x, Point.y, 0.0);
  Result := GetProjectionPoint(vec3(LineStart.x, LineStart.y, 0.0), vec3(LineStop.x, LineStop.y, 0.0), v);
  Point.x := v.x;
  Point.y := v.y;
end;

function LinesIntersect(const P00, P01, P10, P11: TVec2f; out Point: TVec2f): boolean;
var
  A0, B0, A1, B1: BSFloat;
  _p00, _p01, _p10, _p11: TVec2f;
  k0, k1: BSFloat;
  trigger: byte;
begin
  if (
    (((P00.x < P10.x) and (P00.x < P11.x)) and ((P01.x < P10.x) and (P01.x < P11.x))) or
    (((P00.x > P10.x) and (P00.x > P11.x)) and ((P01.x > P10.x) and (P01.x > P11.x))) or
    (((P00.y < P10.y) and (P00.y < P11.y)) and ((P01.y < P10.y) and (P01.y < P11.y))) or
    (((P00.y > P10.y) and (P00.y > P11.y)) and ((P01.y > P10.y) and (P01.y > P11.y)))
    ) then
      exit(false);
  A0 := P01.x - P00.x;
  B0 := P01.y - P00.y;
  A1 := P11.x - P10.x;
  B1 := P11.y - P10.y;
  trigger := 0;
  if A0 <> 0 then
    trigger := 1;
  if B0 <> 0 then
    inc(trigger, 2);
  if A1 <> 0 then
    inc(trigger, 4);
  if B1 <> 0 then
    inc(trigger, 8);
  Point.x := high(int32);
  Point.y := high(int32);
  Result := false;
  case trigger of
    0, 1, 2, 3, 4, 5, 8: begin // 0000
    // two points
    end;
    {1: begin  // 1000
    // one point and one parallel x line
    end;
    2: begin  // 0100
    // one point and one parallel y line
    end;
    3: begin  // 1100
    // one line and one point
    end;
    4: begin  // 0010
    end;
    5: begin  // 1010
    // two parallel (x) lines
    end;}
    6: begin  // 0110
    // first line parallel y, second - x
    Point.x := P00.x;
    Point.y := P10.y;
    Result := true;
    end;
    7: begin  // 1110
    // one (first) line and second parallel x
    k0 := B0/A0;
    Point.y := P11.y;
    Point.x := (Point.y - P00.y)/k0 + P00.x;
    Result := true;
    end;
    {8: begin  // 0001
    // one point and one line parallel y
    end;    }
    9: begin  // 1001
    // first line parallel x and second line parallel y
    Point.x := P10.x;
    Point.y := P00.y;
    Result := true;
    end;
    10: begin // 0101
    // both lines parallel y
    end;
    11: begin // 1101
    // one (first) line and second parallel y
    k0 := B0/A0;
    Point.x := P11.x;
    Point.y := k0*(Point.x-P00.x) + P00.y;
    Result := true;
    end;
    12: begin // 0011
    // one point and one line

    end;
    13: begin // 1011
    // first line parallel x
    k1 := B1/A1;
    Point.y := P00.y;
    Point.x := (Point.y - P10.y)/k1 + P10.x;
    Result := true;
    end;
    14: begin  // 0111
    // first line parallel y
    k1 := B1/A1;
    Point.y := P00.y;
    Point.x := (Point.y - P10.y)/k1 + P10.x;
    Result := true;
    end;
    15: begin  // 1111
    k0 := B0/A0;
    k1 := B1/A1;
    if k0 - k1 <> 0 then
      begin
      Point.x := (k0 * P00.x - P00.y - k1 * P11.x + P11.y) / (k0 - k1);
      Point.y := k1*(Point.x-P10.x) + P10.y;
      Result := true;
      end else
      Result := false;
    end;
  end;

  if Result then
  begin
    _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
    if _p11.y < _p10.y then
      swap(_p10.y, _p11.y);
    if _p11.x < _p10.x then
      swap(_p10.x, _p11.x);
    if _p01.y < _p00.y then
      swap(_p00.y, _p01.y);
    if _p01.x < _p00.x then
      swap(_p00.x, _p01.x);
    if ((_p00.x > Point.x) or (_p01.x < Point.x) or
    (_p00.y > Point.y) or (_p01.y < Point.y) or
    (_p10.x > Point.x) or (_p11.x < Point.x) or
    (_p10.y > Point.y) or (_p11.y < Point.y)) then
      Result := false;
  end;
end;

function LinesIntersectExclude(const P00, P01, P10, P11: TVec2f; out Point: TVec2f): boolean;
var
  A0, B0, A1, B1: double;
  _p00, _p01, _p10, _p11: TVec2f;
  k0, k1: double;
  trigger: byte;
begin
  if (
    (((P00.x <= P10.x) and (P00.x <= P11.x)) and ((P01.x <= P10.x) and (P01.x <= P11.x))) or
    (((P00.x >= P10.x) and (P00.x >= P11.x)) and ((P01.x >= P10.x) and (P01.x >= P11.x))) or
    (((P00.y <= P10.y) and (P00.y <= P11.y)) and ((P01.y <= P10.y) and (P01.y <= P11.y))) or
    (((P00.y >= P10.y) and (P00.y >= P11.y)) and ((P01.y >= P10.y) and (P01.y >= P11.y)))
    ) then
      exit(false);
  A0 := P01.x - P00.x;
  B0 := P01.y - P00.y;
  A1 := P11.x - P10.x;
  B1 := P11.y - P10.y;
  trigger := 0;

  if abs(A0) > 0.001 then
    trigger := 1;
  if abs(B0) > 0.001 then
    inc(trigger, 2);
  if abs(A1) > 0.001 then
    inc(trigger, 4);
  if abs(B1) > 0.001 then
    inc(trigger, 8);


  Point.x := high(int32);
  Point.y := high(int32);
  Result := false;
  case trigger of
    0, 1, 2, 3, 4, 5, 8, 10: begin // 0000
    // two points
    exit;
    end;
    {1: begin  // 1000
    // one point and one parallel x line
    end;
    2: begin  // 0100
    // one point and one parallel y line
    end;
    3: begin  // 1100
    // one line and one point
    end;
    4: begin  // 0010
    end;
    5: begin  // 1010
    end;   }
    6: begin  // 0110
    // first line parallel y, second - x
    Point.x := P00.x;
    Point.y := P10.y;
    Result := true;
    end;
    7: begin  // 1110
    // one (first) line and second parallel x
    k0 := B0/A0;
    Point.y := P11.y;
    Point.x := (Point.y - P00.y)/k0 + P00.x;
    _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
    if _p11.y < _p10.y then
      swap(_p10.y, _p11.y);
    if _p11.x < _p10.x then
      swap(_p10.x, _p11.x);
    if _p01.y < _p00.y then
      swap(_p00.y, _p01.y);
    if _p01.x < _p00.x then
      swap(_p00.x, _p01.x);
    if ((_p00.x < Point.x) and (_p01.x > Point.x) and
      (_p00.y < Point.y) and (_p01.y > Point.y) and
      (_p10.x < Point.x) and (_p11.x > Point.x)) then
        Result := true;
    end;
    {8: begin  // 0001
    // one point and one line parallel y
    end;  }
    9: begin  // 1001
    // first line parallel x and second line parallel y
    Point.x := P00.x;
    Point.y := P10.y;
    Result := true;
    end;
    {10: begin // 0101
    // both lines parallel y
    end; }
    11: begin // 1101
    // one (first) line and second parallel y
    k0 := B0/A0;
    Point.x := P11.x;
    Point.y := k0*(Point.x - P00.x) + P00.y;
    _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
    if _p11.y < _p10.y then
      swap(_p10.y, _p11.y);
    if _p01.y < _p00.y then
      swap(_p00.y, _p01.y);
    if ((_p00.y < Point.y) and (_p01.y > Point.y) and
      (_p10.y < Point.y) and (_p11.y > Point.y)
      ) then
        Result := true;
    exit;
    end;
    {12: begin // 0011
    // one point and one line
    end;}
    13: begin // 1011
    // first line parallel x
    k1 := B1/A1;
    Point.y := P00.y;
    Point.x := (Point.y - P10.y)/k1 + P10.x;
    _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
    if _p11.x < _p10.x then
      swap(_p10.x, _p11.x);
    if _p01.x < _p00.x then
      swap(_p00.x, _p01.x);
    if ((_p00.x < Point.x) and (_p01.x > Point.x) and
      (_p10.x < Point.x) and (_p11.x > Point.x)
      ) then
        Result := true;
    exit;
    end;
    14: begin  // 0111
    // first line parallel y
    k1 := B1/A1;
    Point.x := P00.x;
    Point.y := k1*(Point.x - P10.x) + P10.y;
    _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
    if _p11.y < _p10.y then
      swap(_p10.y, _p11.y);
    if _p01.y < _p00.y then
      swap(_p00.y, _p01.y);
    if (
      (_p00.y < Point.y) and (_p01.y > Point.y) and
      (_p10.y < Point.y) and (_p11.y > Point.y)) then
        Result := true;
    exit;
    end;
    15: begin  // 1111
    k0 := B0/A0;
    k1 := B1/A1;
    if k0 - k1 <> 0 then
      begin
      Point.x := (k0 * P00.x - P00.y - k1 * P11.x + P11.y) / (k0 - k1);
      Point.y := k1*(Point.x-P10.x) + P10.y;
      _p00 := P00; _p01 := P01; _p10 := P10; _p11 := P11;
      if _p11.y < _p10.y then
        swap(_p10.y, _p11.y);
      if _p11.x < _p10.x then
        swap(_p10.x, _p11.x);
      if _p01.y < _p00.y then
        swap(_p00.y, _p01.y);
      if _p01.x < _p00.x then
        swap(_p00.x, _p01.x);
      if (
        (_p00.x < Point.x) and (_p01.x > Point.x) and
        (_p00.y < Point.y) and (_p01.y > Point.y) and
        (_p10.x < Point.x) and (_p11.x > Point.x) and
        (_p10.y < Point.y) and (_p11.y > Point.y)
        ) then
          Result := true;
      end;
    end;
  end;
end;

function LinesIntersectExclude(const P00, P01, P10, P11: TVec2f): boolean; overload; inline;
var
  Point: TVec2f;
begin
  Result := LinesIntersectExclude(P00, P01, P10, P11, Point);
end;

function PointInsideTriangle(const Triangle: TTriangle3f; const Point: TVec3f): boolean;
var
  n1, n2, n3, edg: TVec3f;
  d: BSFloat;
begin
  edg := (Triangle.B - Triangle.A);
  n1 := VecCross(edg, Point - Triangle.A);
  edg := (Triangle.C - Triangle.B);
  n2 := VecCross(edg, Point - Triangle.B);
  d := VecDot(n1, n2);
  if (d < -EPSILON) then
    exit(false);

  edg := (Triangle.A - Triangle.C);
  n3 := VecCross(edg, Point - Triangle.C);
  d := VecDot(n2, n3);
  if (d < -EPSILON) then
    exit(false);

  Result := true;
end;

function PointInsideTriangle(const Triangle: TTriangle2f; const Point: TVec2f): boolean;
var
  edg: TVec3f;
  n: TVec3f;
  //d: BSFloat;
begin
  edg := Triangle.B - Triangle.A;
  n := VecCross(edg, TVec3f(Point - Triangle.A));
  if n.z > 0 then
    exit(false);
  edg := Triangle.C - Triangle.B;
  n := VecCross(edg, TVec3f(Point - Triangle.B));
  if n.z > 0 then
    exit(false);
  //d := VecDot(n1, n2);
  //if (d < -EPSILON) then
  //  exit(false);

  edg := Triangle.A - Triangle.C;
  n := VecCross(edg, TVec3f(Point - Triangle.C));
  if n.z > 0 then
    exit(false);
  //d := VecDot(n2, n3);
  //if (d < -EPSILON) then
  //  exit(false);

  Result := true;
end;

function RayIntersectBox(const Ray: TRay3f; Box: PBox3f; out Distance: BSFloat): boolean;
var
  tMin, tMax, t1, t2, t, d, w: BSFloat;
  axis, delta: TVec3f;
begin
	tMin := -100000.0;
	tMax :=  100000.0;
  //mvp_inv^.V[15] := 1;
  axis := vec3(1.0, 0.0, 0.0);
  //mid := Box3Middle(Box);
  delta := Box^.Middle - Ray.Position;
	d := VecDot(Ray.Direction, axis);
  t := VecDot(axis, delta);
  if (d > EPSILON) or (d < -EPSILON) then
  begin
		t1 := ( t + Box^.x_min - Box^.Middle.x ) / d; // Intersection with the "left" plane
		t2 := ( t + Box^.x_max - Box^.Middle.y ) / d; // Intersection with the "right" plane
		// t1 and t2 now contain distances betwen ray origin and ray-plane intersections
		// We want t1 to represent the nearest intersection,
		// so if it's not the case, invert t1 and t2
		if (t1 > t2)  then
    begin
			w := t1;
      t1 := t2;
      t2 := w; // swap t1 and t2
    end;

		// tMax is the nearest "far" intersection (amongst the X,Y and Z planes pairs)
		// if ( t2 < tMax ) then
			tMax := t2;
		// tMin is the farthest "near" intersection (amongst the X,Y and Z planes pairs)
	  // if ( t1 > tMin ) then
			tMin := t1;

		// And here's the trick :
		// If "far" is closer than "near", then there is NO intersection.
		// See the images in the tutorials for the visual explanation.
		if (tMax < tMin ) then
			exit(false);


  end else
  begin
    // Rare case : the ray is almost parallel to the planes, so they don't have any "intersection"
    if ((-t + Box^.x_min > 0.0) or (-t + Box^.x_max < 0.0)) then
      exit( false );
  end;

  // Test intersection with the 2 planes perpendicular to the OBB's Y axis
  // Exactly the same thing than above.

  axis := vec3(0.0, 1.0, 0.0);
  d := VecDot(Ray.Direction, axis);
  t := VecDot(axis, delta);
  if (d > EPSILON) or (d < -EPSILON) then
  begin
		t1 := ( t + Box^.y_min - Box^.Middle.y ) / d; // Intersection with the "left" plane
		t2 := ( t + Box^.y_max - Box^.Middle.y) / d; // Intersection with the "right" plane

	  if (t1 > t2)  then
    begin
		  w := t1;
      t1 := t2;
      t2 := w; // swap t1 and t2
    end;

  	if ( t2 < tMax ) then
  		tMax := t2;
  	if ( t1 > tMin ) then
  		tMin := t1;
  	if (tMin > tMax) then
  		exit(false);

  end else
  begin
    if ((-t + Box^.y_min > 0.0) or (-t + Box^.y_max < 0.0)) then
  	  exit (false);
  end;

  axis := vec3(0.0, 0.0, -1.0);
  d := VecDot(Ray.Direction, axis);
  t := VecDot(axis, delta);
  if (d > EPSILON) or (d < -EPSILON) then
  begin
		t1 := ( t + Box^.z_min - Box^.Middle.z ) / d; // Intersection with the "left" plane
		t2 := ( t + Box^.z_max - Box^.Middle.z ) / d; // Intersection with the "right" plane
    if (t1 > t2)  then
    begin
	    w := t1;
      t1 := t2;
      t2 := w; // swap t1 and t2
    end;

		if ( t2 < tMax ) then
			tMax := t2;
		if ( t1 > tMin ) then
			tMin := t1;
		if (tMin > tMax) then
			exit(false);
  end else
  begin
    if ((-t + Box^.z_min > 0.0) or (-t + Box^.z_max < 0.0)) then
  	  exit (false);
  end;

  Distance := tMin;
  Result := true;
end;

function RayIntersectTriangle(const Ray: TRay3f; const A, B, C: TVec3f; out Distance: BSFloat): boolean;
var
  n_plane: TVec3f;
  p: TVec3f;
  n1, n2, n3, edg: TVec3f;
  d: BSFloat;
begin
  edg := (B - A);
  n_plane := VecCross(edg, C - A);

  d := VecDot(Ray.Direction, n_plane);

  if (abs(d) < EPSILON) then
    exit(false); // Determine if ray paralle to a plane.

  Distance := -VecDot(n_plane, Ray.Position - A) / d;

  if (Distance < 0) then
    exit(false);

  p := Ray.Position + Ray.Direction*Distance;

  n1 := VecCross(edg, p - A);
  edg := (C - B);
  n2 := VecCross(edg, p - B);
  d := VecDot(n1, n2);
  if (d < 0) then
    exit(false);

  edg := (A - C);
  n3 := VecCross(edg, p - C);
  d := VecDot(n2, n3);
  if (d < 0) then
    exit(false);

  Result := true;
end;

function RayIntersectTriangle(const Ray: TRay3f; const Triangle: TTriangle3f; out Distance: BSFloat): boolean;
var
  n_plane: TVec3f;
  p: TVec3f;
  n1, n2, n3, edg: TVec3f;
  d: BSFloat;
begin
  edg := (Triangle.B - Triangle.A);
  n_plane := VecCross(edg, Triangle.C - Triangle.A);
  d := VecDot(Ray.Direction, n_plane);

  if (abs(d) < EPSILON) then
    exit(false); // Determine if ray paralle to a plane.

  Distance := -VecDot(n_plane, Ray.Position - Triangle.A) / d;

  if (Distance < 0) then
    exit(false);

  p := Ray.Position + Ray.Direction*Distance;

  edg := (Triangle.B - Triangle.A);
  n1 := VecCross(edg, p - Triangle.A);
  edg := (Triangle.C - Triangle.B);
  n2 := VecCross(edg, p - Triangle.B);
  d := VecDot(n1, n2);
  if (d < 0) then
    exit(false);

  edg := (Triangle.A - Triangle.C);
  n3 := VecCross(edg, p - Triangle.C);
  d := VecDot(n2, n3);
  if (d < 0) then
    exit(false);

  Result := true;
end;

function IntersectTriangles(const Triangle1, Triangle2: TTriangle3f; out Dist: BSFloat): boolean;
var
  ray: TRay3f;
begin
  ray.Position := Triangle1.A;
  ray.Direction := Triangle1.B;
  if RayIntersectTriangle(ray, Triangle2, Dist) then
    exit(true);
  ray.Position := Triangle1.B;
  ray.Direction := Triangle1.C;
  if RayIntersectTriangle(ray, Triangle2, Dist) then
    exit(true);
  ray.Position := Triangle1.C;
  ray.Direction := Triangle1.A;
  if RayIntersectTriangle(ray, Triangle2, Dist) then
    exit(true);
  ray.Position := Triangle2.A;
  ray.Direction := Triangle2.B;
  if RayIntersectTriangle(ray, Triangle1, Dist) then
    exit(true);
  ray.Position := Triangle2.B;
  ray.Direction := Triangle2.C;
  if RayIntersectTriangle(ray, Triangle1, Dist) then
    exit(true);
  ray.Position := Triangle2.C;
  ray.Direction := Triangle2.A;
  if RayIntersectTriangle(ray, Triangle1, Dist) then
    exit(true);
  Result := false;
end;

function IntersectTriangles(const A1, B1, C1, A2, B2, C2: TVec3f; out Dist: BSFloat): boolean;
var
  ray: TRay3f;
begin
  ray.Position := A1;
  ray.Direction := B1;
  if RayIntersectTriangle(ray, A2, B2, C2, Dist) then
    exit(true);
  ray.Position := B1;
  ray.Direction := C1;
  if RayIntersectTriangle(ray, A2, B2, C2, Dist) then
    exit(true);
  ray.Position := C1;
  ray.Direction := A1;
  if RayIntersectTriangle(ray, A2, B2, C2, Dist) then
    exit(true);
  ray.Position := A2;
  ray.Direction := B2;
  if RayIntersectTriangle(ray, A1, B1, C1, Dist) then
    exit(true);
  ray.Position := B2;
  ray.Direction := C2;
  if RayIntersectTriangle(ray, A1, B1, C1, Dist) then
    exit(true);
  ray.Position := C2;
  ray.Direction := A2;
  if RayIntersectTriangle(ray, A1, B1, C1, Dist) then
    exit(true);
  Result := false;
end;

function TriangleIntersectBox(const Triangle: TTriangle3f; const Box: TBox3f; out Dist: BSFloat): boolean;
begin
  if Box.x_max = Box.x_min then
  begin
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
  end else
  if Box.y_max = Box.y_min then
  begin
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
  end else
  if Box.z_max = Box.z_min then
  begin
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
  end else
  begin
    // :( - check 12 triangles
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Max, vec3(Box.x_max, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Min, vec3(Box.x_max, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_min, Box.y_min, Box.z_max),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_min, Box.y_min, Box.z_max),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;

    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Max, vec3(Box.x_min, Box.y_min, Box.z_max)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Min, vec3(Box.x_min, Box.y_min, Box.z_max)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_max, Box.z_min),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_max)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_max, Box.z_min),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_max)), Triangle, Dist);
    if Result then
      exit;

    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_min),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_min)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Max, vec3(Box.x_min, Box.y_max, Box.z_max)), Triangle, Dist);
    if Result then
      exit;
    Result := IntersectTriangles(bs.basetypes.Triangle(vec3(Box.x_max, Box.y_min, Box.z_max),
      Box.Min, vec3(Box.x_min, Box.y_max, Box.z_max)), Triangle, Dist);
    if Result then
      exit;
  end;
end;

{ TBlackSharkSpaceTree }

procedure TBlackSharkSpaceTree.Add(Data: Pointer; X, Y, Width, Height: double;
  out Node: PNodeSpaceTree);
begin
  Add(Data, Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)), Node);
end;

procedure TBlackSharkSpaceTree.Add(Data: Pointer; const Position, Size: TVec2d;
  out Node: PNodeSpaceTree);
begin
  Add(Data, Box3(vec3d(Position.X, Position.Y, 0.0), vec3d(Position.X + Size.x, Position.Y + Size.y, 0.0)), Node);
end;

procedure TBlackSharkSpaceTree.ChangeVisibility(Node: PNodeSpaceTree; Visibility: boolean);
begin
  if Visibility then
  begin
    if Node.__PosInList <> nil then
      raise Exception.Create('TBlackSharkSpaceTree.ChangeVisibility: WTF?');
    if (Node.CountChilds = 0) and (Node <> FRoot) then
    begin
      Node.__PosInList := FVisibleData.PushToEnd(Node);
      if Assigned(FOnShowUserData) then
        FOnShowUserData(Node);
    end {$ifdef DEBUG_ST} else
    begin
      Node.__PosInList := FVisibleNoLeafNodes.PushToEnd(Node);
      if Assigned(FOnShowNoLeafNode) then
        FOnShowNoLeafNode(Node);
    end{$endif};
  end else
  begin
    if (Node.CountChilds = 0) and (Node <> FRoot) then
    begin
      if Node.__PosInList <> nil then
        FVisibleData.Remove(Node.__PosInList);
      if Assigned(FOnHideUserData) then
        FOnHideUserData(Node);
    end {$ifdef DEBUG_ST} else
    begin
      if Node.__PosInList <> nil then
        FVisibleNoLeafNodes.Remove(Node.__PosInList);
      if Assigned(FOnHideNoLeafNode) then
        FOnHideNoLeafNode(Node);
    end{$endif};
  end;
end;

procedure TBlackSharkSpaceTree.Clear;
var
  n, p: PNodeSpaceTree;
begin
  if FRoot = nil then
    exit;
  FCount := 0;
  if Assigned(FRoot.__PosInList) then
    ChangeVisibility(FRoot, false);
  if FRoot.CountChilds > 0 then
  begin
    Stack.Count := 0;
    Stack.Add(FRoot.Childs);
    FRoot.Childs := nil;
    FRoot.CountChilds := 0;
    while Stack.Count > 0 do
    begin
      n := Stack.Pop;
      while Assigned(n) do
      begin
        if Assigned(n.Childs) then
          Stack.Add(n.Childs);
        p := n;
        n := n.Next;
        if p.__PosInList <> nil then
          ChangeVisibility(p, false);
        if (p.CountChilds = 0) and Assigned(FOnDeleteUserData) then
          FOnDeleteUserData(p);
        FreeNode(p);
      end;
    end;
  end;
  FVisibleData.Clear;
end;

constructor TBlackSharkSpaceTree.Create;
begin
  inherited Create;
  FDimensions := [AxleX, AxleY, AxleZ];
  Stack := TListVec<PNodeSpaceTree>.Create;
  //FPixelSizeIn3d := APixelSizeIn3d;
  FVisibleData := TBiDiListNodes.Create;
  ListHidingData := TBiDiListNodes.Create;
  TmpList := TListNodes.Create;
  {$ifdef DEBUG_ST}
  FVisibleNoLeafNodes := TBiDiListNodes.Create;
  ListHidingNoLeafNodes := TBiDiListNodes.Create;
  {$endif}
  FRoot := DoCreateNode;
end;

function TBlackSharkSpaceTree.CreateNode(Parent: PNodeSpaceTree): PNodeSpaceTree;
begin
  Result := DoCreateNode;
  Result.Parent := Parent;
  Result.Next := Parent.Childs;
  Result.Prev := nil;
  if Assigned(Parent.Childs) then
    Parent.Childs.Prev := Result;
  Parent.Childs := Result;
  inc(Parent.CountChilds);
end;

destructor TBlackSharkSpaceTree.Destroy;
var
  n: PNodeSpaceTree;
begin
  Clear;
  FreeNode(FRoot);
  Stack.Free;
  ListHidingData.Free;
  FVisibleData.Free;
  TmpList.Free;
  {$ifdef DEBUG_ST}
  FVisibleNoLeafNodes.Free;
  ListHidingNoLeafNodes.Free;
  {$endif}
  while Assigned(CashNodes) do
  begin
    n := CashNodes;
    CashNodes := CashNodes.Next;
    FreeNode(n);
  end;
  inherited;
end;

function TBlackSharkSpaceTree.DoCreateNode: PNodeSpaceTree;
begin
  if Assigned(CashNodes) then
  begin
    Result := CashNodes;
    CashNodes := CashNodes.Next;
  end else
  begin
    new(Result);
  end;
  FillChar(Result^, SizeOf(TNodeSpaceTree), 0);
  Result.BB.IsPoint := true;
end;

procedure TBlackSharkSpaceTree.DoInsertToTree(Parent, Node: PNodeSpaceTree);
begin
  inc(Parent.CountChilds);
  Node.Prev := nil;
  Node.Next := Parent.Childs;
  Node.Parent := Parent;
  if Parent.Childs <> nil then
    Parent.Childs.Prev := Node;
  Parent.Childs := Node;
end;

procedure TBlackSharkSpaceTree.DoRemoveFromTree(Node: PNodeSpaceTree);
begin
  dec(Node.Parent.CountChilds);
  if (Node^.Next <> nil) then
    Node^.Next^.Prev := Node^.Prev;
  if (Node^.Prev <> nil) then
    Node^.Prev^.Next := Node^.Next
  else
    Node.Parent.Childs := Node^.Next;
end;

procedure TBlackSharkSpaceTree.FreeNode(Node: PNodeSpaceTree);
begin
  Dispose(Node);
end;

{$ifdef DEBUG_ST}
{procedure TBlackSharkSpaceTree.InVisibleList(Node: PNodeSpaceTree);
var
  it: TBiDiListNodes.PListItem;
begin
  it := FVisibleNoLeafNodes.ItemListFirst;
  while it <> nil do
    begin
    if it.Item = Node then
      raise Exception.Create('Error Message');
    it := it.Next;
    end;

end; }
{$endif}

function TBlackSharkSpaceTree.IsLeaf(Node: PNodeSpaceTree): boolean;
begin
  Result := (Node <> FRoot) and (Node.Childs = nil); //  or (Node.CountChilds = 0)
end;

procedure TBlackSharkSpaceTree.OnChangeSizeNoLeafNodeDo(Node: PNodeSpaceTree);
begin
  Node.BB.Middle := (Node.BB.Max + Node.BB.Min) * 0.5;
  Node.Volume := Box3Volume(Node.BB);
  {$ifdef DEBUG_ST}
  if (Node.__PosInList = nil) then
    begin
    if Box3Collision(FViewPort, Node.BB) then
      begin
      //InVisibleList(Node);
      Node.__PosInList := FVisibleNoLeafNodes.PushToEnd(Node);
      if Assigned(FOnShowNoLeafNode) then
        FOnShowNoLeafNode(Node);
      end;
    end else
  if Box3Collision(FViewPort, Node.BB) then
    begin
    if Assigned(FOnChangeSizeNoLeafNode) then
      FOnChangeSizeNoLeafNode(Node);
    end else
    begin
    FVisibleNoLeafNodes.Remove(Node.__PosInList);
    if Assigned(FOnHideNoLeafNode) then
      FOnHideNoLeafNode(Node);
    end;
  {$endif}
end;

function TBlackSharkSpaceTree.PickNearesLeaf(const P0, P1, P2, P3: TVec3f;
  out Distance: BSFloat): PNodeSpaceTree;
{var
  tri1, tri2: TTriangle3f;
  b: TBox3d;
  n: PNodeSpaceTree;}
begin
  if FRoot = nil then
    exit(nil);
  {b.Min.x := min(p3.x, min(p0.x, min(p1.x, p2.x)));
  b.Min.y := min(p3.y, min(p0.y, min(p1.y, p2.y)));
  b.Min.z := min(p3.z, min(p0.z, min(p1.z, p2.z)));
  b.Max.x := max(p3.x, max(p0.x, max(p1.x, p2.x)));
  b.Max.y := max(p3.y, max(p0.y, max(p1.y, p2.y)));
  b.Max.z := max(p3.z, max(p0.z, max(p1.z, p2.z)));
  tri1 := Triangle(P0, P1, P2);
  tri2 := Triangle(P1, P2, P3);
  Stack.Add(FRoot);
  while Stack.Count > 0 do
    begin
    n := Stack.Pop;

    if Box3Collision(b, @Result.BB, Distance) or
      TriangleIntersectBox(tri1, Result.BB, Distance) or
        TriangleIntersectBox(tri2, Result.BB, Distance) then
      begin
      if IsLeaf(n) then
        exit(n);
      if n.Childs <> nil then
        Stack.Add(n.Childs);
      end else
      if n.Next <> nil then
        Stack.Add(n.Next);
    end;  }
  Result := nil;
end;

function TBlackSharkSpaceTree.PickNearesLeaf(const Origin,
  Normal: TVec3f; out Distance: BSFloat): PNodeSpaceTree;
//var
//  ray: TRay3f;
//  n: PNodeSpaceTree;
begin
  if (FRoot = nil) then
    exit(nil);
  {ray.Position := Origin;
  ray.Direction := Normal;
  Stack.Add(FRoot);
  while Stack.Count > 0 do
    begin
    n := Stack.Pop;
    if RayIntersectBox(ray, @Result.BB, Distance) then
      begin
      if IsLeaf(n) then
        exit(n);
      if n.Childs <> nil then
        Stack.Add(n.Childs);
      end else
      if n.Next <> nil then
        Stack.Add(n.Next);
    end; }
  Result := nil;
end;

procedure TBlackSharkSpaceTree.RecalcBB(Node: PNodeSpaceTree);
var
  p, ch: PNodeSpaceTree;
  bb: TBox3d;
  data: Pointer;
begin
  p := Node;
  while p <> nil do
    begin
    if p.Childs <> nil then
      begin
      bb := p.Childs.BB;
      ch := p.Childs.Next;
      while ch <> nil do
        begin
        Box3CheckBB(bb, ch.BB.Min);
        Box3CheckBB(bb, ch.BB.Max);
        ch := ch.Next;
        end;
      if (bb.Max <> p.BB.Max) or (bb.Min <> p.BB.Min) then
        begin
        data := p.BB.TagPtr;
        p.BB := bb;
        p.BB.TagPtr := data;
        OnChangeSizeNoLeafNodeDo(p);
        end else
        break;
      end else
  if (p <> FRoot) then
      begin
      {$ifdef DEBUG_ST}
      if p.__PosInList <> nil then
        begin
        if Assigned(FOnHideNoLeafNode) then
          FOnHideNoLeafNode(p);
        FVisibleNoLeafNodes.Remove(p.__PosInList);
        end;
      {$endif}
      ch := p;
      p := p.Parent;
      DoRemoveFromTree(ch);
      ToCashNode(ch);
      if p <> nil then
        begin
        { checks a neighboring node is unnecessary }
        if p.Childs <> nil then
          CheckExtraNode(p.Childs);
        continue;
        end else
        break;
        //OnChangeSizeNoLeafNodeDo(p);
      end;
    p := p.Parent;
    end;
end;

function TBlackSharkSpaceTree.CheckExtraNode(NoLeafNode: PNodeSpaceTree): boolean;
var
  ch, tmp: PNodeSpaceTree;
begin
  { checks and delete an extra node }
  if (NoLeafNode <> FRoot) //and (NoLeafNode.CountChilds > 0) and (NoLeafNode.Childs.CountChilds = 0)
    and (NoLeafNode.Parent.CountChilds = 1) then
    begin
    Result := true;
    {$ifdef DEBUG_ST}
    if NoLeafNode.__PosInList <> nil then
      begin
      if Assigned(FOnHideNoLeafNode) then
        FOnHideNoLeafNode(NoLeafNode);
      FVisibleNoLeafNodes.Remove(NoLeafNode.__PosInList);
      end;
    {$endif}
    DoRemoveFromTree(NoLeafNode);
    ch := NoLeafNode.Childs;
    while ch <> nil do
      begin
      tmp := ch.Next;
      DoInsertToTree(NoLeafNode.Parent, ch);
      ch := tmp;
      end;
    ToCashNode(NoLeafNode);
    end else
    Result := false;
end;

procedure TBlackSharkSpaceTree.CheckGrowBB(Node: PNodeSpaceTree; const BB: TBox3d);
var
  ok: boolean;
  p: PNodeSpaceTree;
begin
  ok := Box3CheckBB(Node.BB, BB.Max);
  if Box3CheckBB(Node.BB, BB.Min) then
    ok := true;
  if ok then
    begin
    OnChangeSizeNoLeafNodeDo(Node);
    p := Node.Parent;
    while p <> nil do
      begin
      ok := not Box3CheckBB(p.BB, BB.Max);
      if not Box3CheckBB(p.BB, BB.Min) then
        begin
        if ok then
          break;
        end;
      OnChangeSizeNoLeafNodeDo(p);
      p := p.Parent;
      end;
    end;
  //Node.BB
end;

procedure TBlackSharkSpaceTree.Remove(Position: PNodeSpaceTree);
begin
  if Position.__PosInList <> nil then
    ChangeVisibility(Position, false);
  if (Position.CountChilds = 0) and Assigned(FOnDeleteUserData) then
    FOnDeleteUserData(Position);
  DoRemoveFromTree(Position);
  RecalcBB(Position.Parent);
  ToCashNode(Position);
  dec(FCount);
end;

procedure TBlackSharkSpaceTree.SelectData(X, Y, Width, Height: double; var List: TListNodes);
begin
  SelectData(Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)), List);
end;

procedure TBlackSharkSpaceTree.SelectData(const BB: TBox3d; var List: TListNodes);
var
  n: PNodeSpaceTree;
begin
  if List = nil then
    begin
    List := TmpList;
    TmpList.Count := 0;
    end;
  if (FRoot.Childs <> nil) and Box3Collision(FRoot.BB, BB) then
    begin
    Stack.Add(FRoot.Childs);
    while Stack.Count > 0 do
      begin
      n := Stack.Pop;
      while n <> nil do
        begin
        if Box3Collision(BB, n.BB) then
          begin
          if (n.CountChilds = 0) then
            List.Add(n);
          if n.Childs <> nil then
            Stack.Add(n.Childs);
          end;
        n := n.Next;
        end;
      end;
    end;
end;

procedure TBlackSharkSpaceTree.ToCashNode(Node: PNodeSpaceTree);
begin
  Node.Next := CashNodes;
  CashNodes := Node;
end;

function TBlackSharkSpaceTree.UpdatePosition(OldPosition: PNodeSpaceTree; const Position, Size: TVec2d): PNodeSpaceTree;
begin
  Result := UpdatePosition(OldPosition, Box3(vec3d(Position.X, Position.Y, 0.0),
    vec3d(Position.X + Size.X, Position.Y + Size.Y, 0.0)));
end;

function TBlackSharkSpaceTree.UpdatePosition(OldPosition: PNodeSpaceTree; X, Y, Width, Height: Double): PNodeSpaceTree;
begin
  Result := UpdatePosition(OldPosition, Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)));
end;

procedure TBlackSharkSpaceTree.ViewPort(const BB: TBox3d);
var
  t: TBiDiListNodes;
  n: PNodeSpaceTree;
  it, t_it: TBiDiListNodes.PListItem;
begin
  //FVisibleData.Clear;
  FSelecting := true;
  try
    t := FVisibleData;
    FVisibleData := ListHidingData;
    ListHidingData := t;
    {$ifdef DEBUG_ST}
    t := FVisibleNoLeafNodes;
    FVisibleNoLeafNodes := ListHidingNoLeafNodes;
    ListHidingNoLeafNodes := t;
    {$endif}
    FViewPort := BB;

    if (FRoot.Childs <> nil) and Box3Collision(FRoot.BB, BB) then
    begin
      {$ifdef DEBUG_ST}
      if FRoot.__PosInList <> nil then
      begin
        //if FRoot.__PosInList.Owner <> ListHidingNoLeafNodes then
        //  FRoot.__PosInList := FRoot.__PosInList;
        ListHidingNoLeafNodes.Remove(FRoot.__PosInList);
        { don't notifyes if a user data already visible }
        FRoot.__PosInList := FVisibleNoLeafNodes.PushToEnd(FRoot);
        { notify about changing a position in a "viewport" }
        if Assigned(FOnUpdatePositionNoLeafNode) then
          FOnUpdatePositionNoLeafNode(FRoot);
      end else
        ChangeVisibility(FRoot, true);
      {$endif}

      Stack.Add(FRoot.Childs);
      { reset the count nodes to zero in temporary lists; select nodes with minimal
        overlaps }
      while Stack.Count > 0 do
      begin
        n := Stack.Pop;
        while n <> nil do
        begin
          if Box3Collision(BB, n.BB) then
          begin
            if (n.CountChilds = 0) then
            begin
              if n.__PosInList <> nil then
              begin
                ListHidingData.Remove(n.__PosInList);
                { don't notify if a user data already visible }
                n.__PosInList := FVisibleData.PushToEnd(n);
                { notify about changing a position in a "viewport" }
                FOnUpdatePositionUserData(n);
              end else
                ChangeVisibility(n, true);
            end
            {$ifdef DEBUG_ST} else
            if n.__PosInList <> nil then
            begin
              ListHidingNoLeafNodes.Remove(n.__PosInList);
              n.__PosInList := FVisibleNoLeafNodes.PushToEnd(n);
              if Assigned(FOnUpdatePositionNoLeafNode) then
                FOnUpdatePositionNoLeafNode(n);
            end else
            begin
              n.__PosInList := FVisibleNoLeafNodes.PushToEnd(n);
              if Assigned(FOnShowNoLeafNode) then
                FOnShowNoLeafNode(n);
            end{$endif};

            if n.Childs <> nil then
              Stack.Add(n.Childs);
          end;
          n := n.Next;
        end;
      end;
    end;

    { hides objects which early was visible }
    it := ListHidingData.ItemListFirst;
    while it <> nil do
    begin
      t_it := it;
      it := it.Next;
      n := t_it.Item;
      ListHidingData.Remove(t_it);
      n.__PosInList := nil;
      ChangeVisibility(n, false);
    end;

    {$ifdef DEBUG_ST}
    it := ListHidingNoLeafNodes.ItemListFirst;
    while it <> nil do
    begin
      t_it := it;
      it := it.Next;
      n := t_it.Item;
      n.__PosInList := nil;
      if Assigned(FOnHideNoLeafNode) then
        FOnHideNoLeafNode(n);
    end;
    ListHidingNoLeafNodes.Clear;
    {$endif}

  finally
    FSelecting := false;
  end;
end;

procedure TBlackSharkSpaceTree.ViewPort(X, Y, Width, Height: double);
begin
  ViewPort(Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)));
end;

procedure TBlackSharkSpaceTree.ViewPortUpdateSilent(X, Y, Width,
  Height: double);
begin
  FViewPort := Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0));
end;

{ TBlackSharkRtree }

procedure TBlackSharkRTree.Add(Data: Pointer; const BB: TBox3d; out Node: PNodeSpaceTree);
var
  parent: PNodeSpaceTree;
begin
  parent := ChooseNode(BB);
  //if (parent.CountChilds > 0) and (parent.Childs.CountChilds > 0) then
  //  raise Exception.Create('WTF?');
  if parent.CountChilds > MAX_COUNT_AABB - 1 then
  begin
    Node := SplitNode(parent, Data, BB);
  end else
  begin
    Node := CreateNode(parent);
    //Node.Data := Data;
    Node.BB := BB;
    Node.BB.TagPtr := Data;
    if parent.CountChilds = 1 then
      RecalcBB(parent)
    else
      CheckGrowBB(parent, BB);
  end;
  if Box3Collision(FViewPort, BB) then
    ChangeVisibility(Node, true);
  inc(FCount);
end;

function TBlackSharkRTree.ChooseNode(const BB: TBox3d): PNodeSpaceTree;
var
  min_overlap, min_overlap_lev, sum_ovrl: BSFloat;
  fl: BSFloat;
  vol, min_vol, min_vol_lev: BSFloat;
  cnt: int8;
  min_orl, min_orl_l, n, sel_min: PNodeSpaceTree;
  _bb: TBox3d;
begin
  {if FRoot.CountChilds = 0 then
    begin
    exit(nil);
    end;}
  if FRoot.CountChilds = 0 then
    exit(FRoot);
  if (FRoot.CountChilds > 0) and (FRoot.Childs.CountChilds > 0) then
    Stack.Add(FRoot.Childs);
  { reset the count nodes to zero in the temporary lists; select nodes with minimal
    overlap }
  TmpNodes.Count := 0;
  min_orl := FRoot;
  min_vol := MaxSingle;
  min_overlap := MaxSingle;
  while Stack.Count > 0 do
  begin
    Result := Stack.Pop;
    n := Result;
    min_vol_lev := MaxSingle;
    min_overlap_lev := MaxSingle;
    min_orl_l := nil;
    while n <> nil do
    begin
      _bb := n.BB;
      Box3CheckBB(_bb, BB);
      vol := Box3Volume(_bb);
      sel_min := Result;
      //max_ovrl := 0;
      sum_ovrl := 0;
      cnt := 0;
      //if min_overlap_lev <> 0 then
        while sel_min <> nil do
        begin
          if sel_min = n then
          begin
            sel_min := sel_min.Next;
            continue;
          end;
          inc(cnt);
          fl := Box3Overlap(sel_min^.BB, _bb);
          sum_ovrl := sum_ovrl + fl;
          sel_min := sel_min.Next;
        end;
      if sum_ovrl <= min_overlap_lev then
      begin
        if cnt > 0 then
          min_overlap_lev := sum_ovrl;
        if min_overlap_lev = 0 then
        begin
          if (vol < min_vol_lev) then
          begin
            min_vol_lev := vol;
            min_orl_l := n;
          end;
        end else
        begin
          min_orl_l := n;
          min_vol_lev := vol;
        end;
      end;
      //fl := Box3Overlap(n^.BB, BB);
      n := n.Next;
    end;
      {  }
    if (min_overlap_lev < min_overlap) or (min_overlap_lev = 0) then
    begin
      if (min_overlap_lev = 0) then
      begin
        if (min_vol_lev < min_vol) then
        begin
          { no a leaf? }
          if (min_orl_l.CountChilds > 0) and (min_orl_l.Childs.CountChilds = 0) then
          begin
            min_vol := min_vol_lev;
            min_orl := min_orl_l;
            min_overlap := min_overlap_lev;
          end;
          if (min_orl_l.CountChilds > 0) and (min_orl_l.Childs.CountChilds > 0) then
            Stack.Add(min_orl_l.Childs);
        end;
      end else
      begin
        if (min_orl_l.CountChilds > 0) and (min_orl_l.Childs.CountChilds = 0) then
        begin
          min_vol := min_vol_lev;
          min_orl := min_orl_l;
          min_overlap := min_overlap_lev;
        end;
        if (min_orl_l.CountChilds > 0) and (min_orl_l.Childs.CountChilds > 0) then
          Stack.Add(min_orl_l.Childs);
      end;
    end;
  end;
  Result := min_orl;
end;

function CmpPtr(const Key1, Key2: Pointer): boolean;
begin
  Result := Key1 = Key2;
end;

constructor TBlackSharkRTree.Create;
var
  //l: TLimit;
  a: TAxis3D;
begin
  inherited;
  //FIs2D := AIs2D;
  TmpNodes := TListVec<PNodeSpaceTree>.Create;
  for a := Low(TAxis3d) to High(TAxis3d) do
  begin
    //for l := Low(TLimit) to High(TLimit) do
    TmpLists[a, sLeft] := TListVec<PNodeSpaceTree>.Create;
    TmpLists[a, sRight] := TListVec<PNodeSpaceTree>.Create;
  end;
end;

destructor TBlackSharkRTree.Destroy;
var
  s: TSide;
  a: TAxis3D;
begin
  for a := Low(TAxis3d) to High(TAxis3d) do
    for s := Low(TSide) to High(TSide) do
      TmpLists[a, s].Free;
  TmpNodes.Free;
  inherited;
end;

procedure TBlackSharkRTree.SplitNode(Node: PNodeSpaceTree);
var
  sz_left, sz_right, overlap: BSFloat;
  tmp_f: BSFloat;
  i: int32;
  n: PNodeSpaceTree;
  boxes: array[TSide] of TVec2f;
  node_l, node_r: PNodeSpaceTree;
  a, selected: TAxis3D;
begin
  { now select optimal division a node volume }
  overlap := -MaxSingle;
  selected := TAxis3D.AxleX;
  for a in FDimensions do
  begin
    TmpLists[a, TSide.sLeft].Count := 0;
    TmpLists[a, TSide.sRight].Count := 0;
    boxes[TSide.sLeft] := vec2(Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, int8(TSide.sLeft)]],
        Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, int8(TSide.sLeft)]]);
    boxes[TSide.sRight] := vec2(Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, int8(TSide.sRight)]],
        Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, int8(TSide.sRight)]]);
    n := Node.Childs;
    while n <> nil do
    begin
      if n.BB.Middle.p[int8(a)] > Node.BB.Middle.p[int8(a)] then
      begin
        TmpLists[a, TSide.sLeft].Add(n);
        if n.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] > boxes[TSide.sLeft].y then
          boxes[TSide.sLeft].y := n.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]];
      end else
      begin
        TmpLists[a, TSide.sRight].Add(n);
        if n.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 0]] < boxes[TSide.sRight].x then
          boxes[TSide.sRight].x := n.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 0]];
      end;
      n := n.Next;
    end;
    sz_left := boxes[TSide.sLeft].y - boxes[TSide.sLeft].x;
    sz_right := boxes[TSide.sRight].y - boxes[TSide.sRight].x;
    if (sz_left > 0) and (sz_right > 0) then
    begin
      { overlap }
      tmp_f := boxes[TSide.sLeft].y - boxes[TSide.sRight].x;
      if tmp_f > overlap then
      begin
        selected := a;
        overlap := tmp_f;
      end;
    end;
  end;

  if (TmpLists[selected, TSide.sLeft].Count = 0) or (TmpLists[selected, TSide.sRight].Count = 0) then
    exit;

  Node.Childs := nil;
  Node.CountChilds := 0;

  { now creates two child nodes and separate b/w them }
  { left node }
  node_l := CreateNode(Node);
  //node_l.Data := nil;

  node_l.BB := TmpLists[selected, TSide.sLeft].Items[0].BB;
  //node_l.BB.TagPtr := nil;
  DoInsertToTree(node_l, TmpLists[selected, TSide.sLeft].Items[0]);
  for i := 1 to TmpLists[selected, TSide.sLeft].Count - 1 do
  begin
    n := TmpLists[selected, TSide.sLeft].Items[i];
    DoInsertToTree(node_l, n);
    Box3CheckBB(node_l.BB, n.BB);
  end;

  { right node }
  node_r := CreateNode(Node);
  node_r.BB := TmpLists[selected, TSide.sRight].Items[0].BB;
  //node_r.BB.TagPtr := nil;
  DoInsertToTree(node_r, TmpLists[selected, TSide.sRight].Items[0]);
  for i := 1 to TmpLists[selected, TSide.sRight].Count - 1 do
  begin
    n := TmpLists[selected, TSide.sRight].Items[i];
    DoInsertToTree(node_r, n);
    Box3CheckBB(node_r.BB, n.BB);
  end;
  //RecalcBB(node_l);
  //RecalcBB(node_r);
  OnChangeSizeNoLeafNodeDo(node_l);
  OnChangeSizeNoLeafNodeDo(node_r);
end;

function TBlackSharkRTree.SplitNode(Node: PNodeSpaceTree; Data: Pointer; const BB: TBox3d): PNodeSpaceTree;
begin
  Result := CreateNode(Node);
  Result.Volume := Box3Volume(BB);
  //Result.Data := Data;
  Result.BB := BB;
  Result.BB.TagPtr := Data;
  CheckGrowBB(Node, BB);
  SplitNode(Node);
end;

function TBlackSharkRTree.UpdatePosition(OldPosition: PNodeSpaceTree; const NewBB: TBox3d): PNodeSpaceTree;
var
  new_pos, parent: PNodeSpaceTree;
  //splitted: boolean;
  data: Pointer;
begin
  if FSelecting then
    raise Exception.Create('You can not update data position because at the time are selecting data by the Viewport method');
  Result := OldPosition;
  Result.Volume := Box3Volume(NewBB);
  data := Result.BB.TagPtr;
  Result.BB := NewBB;
  Result.BB.TagPtr := data;
  parent := Result.Parent;
  DoRemoveFromTree(OldPosition);
  RecalcBB(parent);
  new_pos := ChooseNode(NewBB);
  DoInsertToTree(new_pos, OldPosition);
  RecalcBB(new_pos);
  if new_pos.CountChilds > MAX_COUNT_AABB then
    SplitNode(new_pos);

  if Box3Collision(FViewPort, NewBB) then
  begin
    if (Result.__PosInList = nil) then
      ChangeVisibility(Result, true) else
    if Assigned(FOnUpdatePositionUserData) then
      FOnUpdatePositionUserData(Result);
  end else
  if (Result.__PosInList <> nil) then
    ChangeVisibility(Result, false);
end;

function CompareNode3f(const n1, n2: PNodeSpaceTree): int8;
var
  a: TAxis3D;
begin

  // n1 < n2: 1
  // n1 > n2: -1
  // else 0

  for a := High(TAxis3D) downto Low(TAxis3D) do
  begin
    // n1.max < n2.min
    if n1.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] < n2.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 0]] then
      exit(1); // n1 < n2
    // n2.max < n1.min
    if n2.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] < n1.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 0]] then
      exit(-1); // n2 < n1
    // n2.max < n1.max
    if n2.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] < n1.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] then
      exit(-1); // n2 < n1
    // n1.max < n2.max
    if n1.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] < n2.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[a, 1]] then
      exit(1); // n1 < n2
  end;

  Result := 0;

end;

{ TAreaMarker }

function TAreaMarker.AddArea(const BB: TBox3d; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree;
begin

  if Union then
  begin
    if UnionWithAreas(BB, CancelArea, nil) then
      exit(nil);
  end;

  if not CancelArea then
    FSpaceTree.Add(Data, BB, Result);

end;

procedure TAreaMarker.BreakNode(Node: PNodeSpaceTree; const Overlap: TBox3d);
var
  lim: TAxis3D;
  i: int32;
  bb: TBox3d;
  ovr: TBox3d;
  c_l: boolean;
  n: PNodeSpaceTree;
  b: byte;
begin
  c_l := false;
  TmpListBB[true].Count := 0;
  TmpListBB[false].Count := 0;
  TmpListBB[c_l].Add(Node.BB);
  for lim := low(TAxis3D) to high(TAxis3D) do
  begin
    if (Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] = Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) or
      ((Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] = Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]]) and
        (Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] = Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]])) then
          continue;

    if ((Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] > Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]]) and
        (Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] < Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]])) then
    begin  // break on three
      for i := 0 to TmpListBB[c_l].Count - 1 do
      begin
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]];
        ovr := Box3GetOverlap(bb, Overlap);
        if (ovr.Min <> bb.Min) or (ovr.Max <> bb.Max) then //
        begin
          if ovr.Max = ovr.Min then // do not intersect - do not divide
          begin
            TmpListBB[not c_l].Add(TmpListBB[c_l].Items[i]);
            continue;
          end else
          if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) then
            TmpListBB[not c_l].Add(bb);
        end;
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]];
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) then
          TmpListBB[not c_l].Add(bb);
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]];
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) then
          TmpListBB[not c_l].Add(bb);
      end;
    end else
    if (Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] >= Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]]) then
    begin  // break on two
      if (Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] < Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) then
        b := 0
      else
        b := 1;
      for i := 0 to TmpListBB[c_l].Count - 1 do
      begin
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, b]];
        ovr := Box3GetOverlap(bb, Overlap);
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) and
          ((ovr.Min <> bb.Min) or (ovr.Max <> bb.Max)) then //Box3PointIn(bb, Overlap.Middle)
            TmpListBB[not c_l].Add(bb);
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] := Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, b]];
        ovr := Box3GetOverlap(bb, Overlap);
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]])  and
          ((ovr.Min <> bb.Min) or (ovr.Max <> bb.Max)) then //  not Box3PointIn(bb, Overlap.Middle)
            TmpListBB[not c_l].Add(bb);
      end;
    end else
    begin  // break on two
      if (Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] < Overlap.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) then
        b := 0
      else
        b := 1;
      for i := 0 to TmpListBB[c_l].Count - 1 do
      begin
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] := Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, b]];
        ovr := Box3GetOverlap(bb, Overlap);
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) and
          ((ovr.Min <> bb.Min) or (ovr.Max <> bb.Max)) then
            TmpListBB[not c_l].Add(bb);
        bb := TmpListBB[c_l].Items[i];
        bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]] := Node.BB.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, b]];
        ovr := Box3GetOverlap(bb, Overlap);
        if (bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 1]] <> bb.Named[ADAPTER_AXIS_TO_BB_SEGMENT[lim, 0]]) and
          ((ovr.Min <> bb.Min) or (ovr.Max <> bb.Max)) then
            TmpListBB[not c_l].Add(bb);
      end;
    end;
    TmpListBB[c_l].Count := 0;
    c_l := not c_l;
  end;
  FSpaceTree.Remove(Node);
  for i := 0 to TmpListBB[c_l].Count - 1 do
    FSpaceTree.Add(nil, TmpListBB[c_l].Items[i], n);
end;

function TAreaMarker.AddArea(const Area: TRectBSd; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree;
begin
  Result := AddArea(Box3(Area), Data, Union, CancelArea);
end;

function TAreaMarker.AddArea(X, Y, Width, Height: double; Data: Pointer; Union: boolean; CancelArea: boolean): PNodeSpaceTree;
begin
  Result := AddArea(Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)), Data, Union, CancelArea);
end;

procedure TAreaMarker.Clear;
begin
  FSpaceTree.Clear;
end;

constructor TAreaMarker.Create(ASpaceTree: TBlackSharkSpaceTree);
begin
  FSpaceTree := ASpaceTree;
  TmpListNodes := TListNodes.Create(@CompareVec3);
  TmpListBB[true] := TListVec<TBox3d>.Create;
  TmpListBB[false] := TListVec<TBox3d>.Create;
  FixedStream := TMemoryStream.Create;
  ListNodesSelect := TListVec<TBox3d>.Create(@CompareVec3);
  //ListNodesSelect[false] := TListNodes.Create(@CompareNode3f);
  //ListNodesSelect[true] := TListNodes.Create(@CompareNode3f);
  //TmpBinTree := TBinTreeTemplate<TVec3f, PNodeSpaceTree>.Create(@CompareNode3f);
end;

function TAreaMarker.DelArea(const Position: TVec2d; Width, Height: double): boolean;
var
  ln: TListNodes;
  n: PNodeSpaceTree;
begin
  ln := nil;
  FSpaceTree.SelectData(Box3(vec3d(Position.X, Position.Y, 0.0), vec3d(Position.X + Width, Position.Y + Height, 0.0)), ln);
  Result := ln.Count > 0;
  while ln.Count > 0 do
  begin
    n := ln.Pop;
    FSpaceTree.Remove(n);
  end;
end;

destructor TAreaMarker.Destroy;
begin
  //FSpaceTree.Free;
  TmpListNodes.Free;
  TmpListBB[true].Free;
  TmpListBB[false].Free;
  FixedStream.Free;
  ListNodesSelect.Free;
  //ListNodesSelect[false].Free;
  //ListNodesSelect[true].Free;
  //Areas.Free;
  inherited;
end;

function TAreaMarker.GetAreaWidth(const Position: TVec2d; Width, Height: Double): Double;
var
  ln: TListNodes;
  //n: PNodeSpaceTree;
  //i: Integer;
begin
  ln := nil;
  FSpaceTree.SelectData(Box3(vec3d(Position.X, Position.Y, 0.0), vec3d(Position.X + Width, Position.Y + Height, 0.0)), ln);
  Result := 0;
  //for i := 0 to ln.Count - 1 do
  //begin
    //n := ln.Items[i];
    //n.BB.y_max
  //end;
end;

function TAreaMarker.GetFirstArea({StepX is a wide a current area}
  StepY, StepZ: double; GranularityY, GranularityZ: double; out Area: TBox3d): boolean;
begin
  if FSpaceTree.Root = nil then
    exit(false);
  StepSelectY := StepY;
  StepSelectZ := StepZ;
  GranularitySelY := GranularityY;
  GranularitySelZ := GranularityZ;
  CurrentBox.Min := vec3d(FSpaceTree.Root.BB.Max.x, SpaceTree.Root.BB.Min.y - StepY, FSpaceTree.Root.BB.Min.z);
  CurrentBox.Max := CurrentBox.Min;
  //CurrentBox := Box3(FSpaceTree.Root.BB.Min, FSpaceTree.Root.BB.Min);

  SelectNodesInCurrentBox;

  Result := GetNextArea(Area);
end;

function TAreaMarker.GetNextArea(out Area: TBox3d): boolean;
begin

  if FSpaceTree.Root = nil then
    exit(false);

  if ListNodesSelect.Count = 0 then
  begin
    SelectNodesInCurrentBox;
    if ListNodesSelect.Count = 0 then
      exit(false);
  end;
  Area := ListNodesSelect.Pop;
  LastSelectedArea := Area;
  Result := true;
end;

procedure TAreaMarker.Invert(const FullArea: TRectBSd);
begin
  Invert(Box3(FullArea));
end;

procedure TAreaMarker.Invert(const FullBB: TBox3d);
var
  i: int32;
  l: TListVec<TBox3d>;
begin
  l := TListVec<TBox3d>.Create;
  try
    Save(l);
    Clear;
    AddArea(FullBB, nil, false, false);
    for i := 0 to l.Count - 1 do
      AddArea(l.Items[i], nil, true, true);
  finally
    l.Free;
  end;
end;

procedure TAreaMarker.Invert(X, Y, Width, Height: double);
begin
  Invert(Box3(vec3d(X, Y, 0.0), vec3d(X + Width, Y + Height, 0.0)));
end;

procedure TAreaMarker.Load(const FileName: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    Load(f);
  finally
    f.Free;
  end;
end;

function TAreaMarker.LoadArea(FromStream: TStream): int32;
var
  box: TBox3d;
begin
  Result := FromStream.Read({%H-}box.Min, SizeOf(TVec3d)*2);
  AddArea(box, nil, true, false);
end;

procedure TAreaMarker.Load(Stream: TStream);
var
  eof: int32;
  pos: int32;
begin
  pos := 0;
  eof := Stream.Size;
  while pos < eof do
    inc(pos, LoadArea(Stream));
end;

procedure TAreaMarker.Load(List: TListVec<TBox3d>);
var
  i: int32;
  nst: PNodeSpaceTree;
begin
  for i := 0 to List.Count - 1 do
    FSpaceTree.Add(nil, List.Items[i], nst);
end;

function TAreaMarker.UnionWithAreas(const BB: TBox3d; CancelArea: boolean;
  ExceptNode: PNodeSpaceTree): boolean;
var
  ln: TListNodes;
  n: PNodeSpaceTree;
  ovrl: TBox3d;
begin

  ln := nil;
  FSpaceTree.SelectData(BB, ln);
  TmpListNodes.Count := 0;
  //TmpListNodes.Sort := false;

  while ln.Count > 0 do
  begin
    n := ln.Pop;
    ovrl := Box3GetOverlap(n.BB, BB);

    if (ovrl.x_min > ovrl.x_max) or (ovrl.y_min > ovrl.y_max)
      or (ovrl.z_min > ovrl.z_max) or (ExceptNode = n) then
        continue;

    if (not CancelArea) and ((ovrl.Min = BB.Min) and (ovrl.Max = BB.Max)) then
      exit(true);

    TmpListNodes.Add(n);
  end;

  while TmpListNodes.Count > 0 do
  begin
    n := TmpListNodes.Pop;
    ovrl := Box3GetOverlap(n.BB, BB);
    if ((n.BB.Min = ovrl.Min) and (n.BB.Max = ovrl.Max)) then
      FSpaceTree.Remove(n)
    else
      BreakNode(n, ovrl);
  end;

  Result := false;
end;

procedure TAreaMarker.Save(List: TListVec<TBox3d>);
var
  n: PNodeSpaceTree;
begin
  TmpListNodes.Count := 0;
  //TmpListNodes.Sort := false;
  TmpListNodes.Add(FSpaceTree.Root);
  List.Capacity := FSpaceTree.FCount;
  List.Count := 0;
  if FSpaceTree.Root = nil then
    exit;
  while TmpListNodes.Count > 0 do
  begin
    n := TmpListNodes.Pop;
    if FSpaceTree.IsLeaf(n) then
      List.Add(n.BB);

    n := n.Childs;
    while n <> nil do
    begin
      TmpListNodes.Add(n);
      n := n.Next;
    end;
  end;
end;

procedure TAreaMarker.Save(List: TListVec<PNodeSpaceTree>);
var
  n: PNodeSpaceTree;
begin
  TmpListNodes.Count := 0;
  //TmpListNodes.Sort := false;
  TmpListNodes.Add(FSpaceTree.Root);
  List.Capacity := FSpaceTree.FCount;
  List.Count := 0;
  if FSpaceTree.Root = nil then
    exit;
  while TmpListNodes.Count > 0 do
  begin
    n := TmpListNodes.Pop;
    if FSpaceTree.IsLeaf(n) then
      List.Add(n);

    n := n.Childs;
    while n <> nil do
    begin
      TmpListNodes.Add(n);
      n := n.Next;
    end;
  end;
end;

procedure TAreaMarker.Save(Stream: TStream);
var
  n: PNodeSpaceTree;
begin
  if FSpaceTree.Root = nil then
    exit;
  TmpListNodes.Count := 0;
  //TmpListNodes.Sort := false;
  TmpListNodes.Add(FSpaceTree.Root);
  while TmpListNodes.Count > 0 do
  begin
    n := TmpListNodes.Pop;
    if FSpaceTree.IsLeaf(n) then
      SaveArea(Stream, n);
    n := n.Childs;
    while n <> nil do
    begin
      TmpListNodes.Add(n);
      n := n.Next;
    end;
  end;
end;

procedure TAreaMarker.StateFix;
begin
  FixedStream.Clear;
  Save(FixedStream);
  //Save('d:\areas.dat');
end;

procedure TAreaMarker.StateRecovery;
begin
  Clear;
  FixedStream.Position := 0;
  Load(FixedStream);
end;

procedure TAreaMarker.Save(const FileName: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    Save(f);
  finally
    f.Free;
  end;
end;

function TAreaMarker.SaveArea(ToStream: TStream; Node: PNodeSpaceTree): int32;
begin
  Result := ToStream.Write(Node.BB.Min, SizeOf(Node.BB.Min)*2);
end;

procedure TAreaMarker.SelectNodesInCurrentBox;
var
  i: int32;
  b: TBox3d;
  { current distance b/w current position and current node }
  dist_c: TVec3d;
  dist_min: TVec3d;
  p_last: TVec3d;
  n, res, nearest: PNodeSpaceTree;
begin

  CurrentBox.Min := vec3d(FSpaceTree.Root.BB.Min.x, CurrentBox.Min.y + StepSelectY, FSpaceTree.Root.BB.Max.z);
  CurrentBox.Max := vec3d(FSpaceTree.Root.BB.Max.x, CurrentBox.Min.y + StepSelectY, CurrentBox.Max.z);
  //ListNodesSelect.Count := 0;

  if CurrentBox.Max.y > FSpaceTree.Root.BB.y_max then
  begin
    CurrentBox.Min := vec3d(FSpaceTree.Root.BB.Min.x, FSpaceTree.Root.BB.Min.y, CurrentBox.Max.z + StepSelectZ);
    CurrentBox.Max := vec3d(FSpaceTree.Root.BB.Max.x, CurrentBox.Min.y + StepSelectY,
      CurrentBox.Max.z + StepSelectZ);
    if CurrentBox.Max.z > FSpaceTree.Root.BB.z_max then
      exit;
  end;

  { use redused area for exclude touched area on y axle }
  CurrentForSelectBox.Min := vec3d(CurrentBox.Min.x, CurrentBox.Min.y + GranularitySelY*0.5, CurrentBox.Min.z);
  CurrentForSelectBox.Max := vec3d(CurrentBox.Max.x, CurrentBox.Max.y - GranularitySelY*0.5, CurrentBox.Max.z);

  TmpListNodes.Count := 0;

  FSpaceTree.SelectData(CurrentForSelectBox, TmpListNodes);

  if TmpListNodes.Count = 0 then
  begin
    { find a first nearest area }
    dist_min := vec3d(MaxSingle, MaxSingle, MaxSingle);
    TmpListNodes.Add(FSpaceTree.Root);
    res := nil;
    p_last := vec3d(LastSelectedArea.Max.x, LastSelectedArea.Min.y, LastSelectedArea.Min.z);
    while TmpListNodes.Count > 0 do
    begin
      n := TmpListNodes.Pop;
      nearest := nil;
      while n <> nil do
      begin
        if Box3PointIn(n.BB, p_last) and (not FSpaceTree.IsLeaf(n)) then
        begin
          if (n.Childs <> nil) then
            TmpListNodes.Add(n.Childs);
        end else
        begin
          dist_c := n.BB.Min - p_last;
          if (CompareVec3(n.BB.Min, LastSelectedArea.Max) <= 0) and (CompareVec3(dist_c, dist_min) > 0) then
          begin
            if FSpaceTree.IsLeaf(n) then
            begin
              res := n;
              nearest := n;
              dist_min := dist_c;
              //break;
            end;
          end;
        end;
        n := n.Next;
      end;
      if (nearest <> nil) and (nearest.Childs <> nil) then
        TmpListNodes.Add(nearest.Childs);
    end;

    if res <> nil then
    begin
      CurrentBox.Min := res.BB.Min;
      CurrentBox.Max := vec3d(FSpaceTree.Root.BB.Max.x, res.BB.Min.y + StepSelectY, res.BB.Min.z);
      CurrentForSelectBox.Min := vec3d(CurrentBox.Min.x, CurrentBox.Min.y + GranularitySelY*0.5, CurrentBox.Min.z);
      CurrentForSelectBox.Max := vec3d(CurrentBox.Max.x, CurrentBox.Max.y - GranularitySelY*0.5, CurrentBox.Max.z);
      FSpaceTree.SelectData(CurrentForSelectBox, TmpListNodes);
    end else
      exit;

  end;

  { select only overlap with CurrentBox }
  for i := 0 to TmpListNodes.Count - 1 do
  begin
    b := Box3GetOverlap(TmpListNodes.Items[i].BB, CurrentBox);
    if not (b.Min = b.Max) then
      ListNodesSelect.Add(b);
  end;
  ListNodesSelect.Sort;
end;

{ TBlackSharkKDTree }

function TBlackSharkKDTree.AddBB(AData: Pointer; AVectorMinMax: PBoxMinMax): int32;
begin
  Result := DoAdd(AData, AVectorMinMax);
end;

function TBlackSharkKDTree.AddBB(AData: Pointer; const AVectorMinMax: TBox3f): int32;
var
  min_max: array[0..1] of TVec3d;
begin
  min_max[0] := AVectorMinMax.Min;
  min_max[1] := AVectorMinMax.Max;
  Result := DoAdd(AData, @min_max);
end;

procedure TBlackSharkKDTree.Clear;
var
  i, j: int32;
begin
  if FRoot >= 0 then
    Stack.Add(FRoot);
  while Stack.Count > 0 do
  begin
    i := Stack.Pop;
    if FDimensionItems[i].Left >= 0 then
      Stack.Add(FDimensionItems[i].Left);
    if FDimensionItems[i].Right >= 0 then
      Stack.Add(FDimensionItems[i].Right);
    for j := 0 to FDimensionItems[i].Count - 1 do
      DoDelete(i, FDimensionItems[i].Data[j]);
  end;
  Init;
end;

constructor TBlackSharkKDTree.Create(ADimension: TDimension = TDimension3D);
begin
  Create(1.0, ADimension);
end;

constructor TBlackSharkKDTree.Create(AMinSize: double; ADimension: TDimension = TDimension3D);
var
  i: int32;
begin
  FMinSize := AMinSize;
  FMinSize2x := AMinSize*2;
  FMinSize10x  := FMinSize*10;
  FMinSize100x := FMinSize*100;
  FDimension := ADimension;
  FDimensionDouble := FDimension*2;
  CashDimItems := TListVec<int32>.Create;
  CashDimItems.Count := 100000;
  SetLength(FDimensionItems, CashDimItems.Count);
  for i := CashDimItems.Count - 1 downto 0 do
  begin
    CashDimItems.Items[CashDimItems.Count - 1 - i] := i;
  end;
  SetLength(FKeys, CashDimItems.Count*FDimension*2);
  Stack := TListVec<int32>.Create;
  FRoot := -1;
  Init;
end;

destructor TBlackSharkKDTree.Destroy;
begin
  CashDimItems.Free;
  Stack.Free;
  inherited;
end;

function TBlackSharkKDTree.DoAdd(AData: Pointer; AVectorMinMax: PBoxMinMax; OldPosition: int32): int32;
var
  cur_node: int32;
  mx, mn: double;
begin
  cur_node := FRoot;
  while true do
  begin

    mn := bs.math.Max(FKeys[cur_node*FDimensionDouble+FDimensionItems[cur_node].Dimension],
      AVectorMinMax^[FDimensionItems[cur_node].Dimension]);
    mx := bs.math.Min(FKeys[cur_node*FDimensionDouble+FDimensionItems[cur_node].Dimension+FDimension],
      AVectorMinMax^[FDimensionItems[cur_node].Dimension+FDimension]);

    if (mx = AVectorMinMax^[FDimensionItems[cur_node].Dimension+FDimension]) and (mn = AVectorMinMax^[FDimensionItems[cur_node].Dimension]) then // it doesn't fit into cur_node
    begin // inside
      if (FDimensionItems[cur_node].Left > 0) and (FKeys[FDimensionItems[cur_node].Left*FDimensionDouble+FDimensionItems[FDimensionItems[cur_node].Left].Dimension+FDimension] >
        AVectorMinMax^[FDimensionItems[FDimensionItems[cur_node].Left].Dimension]) then
          cur_node := FDimensionItems[cur_node].Left
      else
      if (FDimensionItems[cur_node].Right > 0) then
        cur_node := FDimensionItems[cur_node].Right
      else
      if OldPosition <> cur_node then
      begin
        Result := Insert(cur_node, AData, AVectorMinMax, OldPosition);
        if (OldPosition >= 0) and (OldPosition <> Result) then
          DoDelete(OldPosition, AData);
        exit;
      end else
        exit(OldPosition);
    end else
    //if (mn >= mx) then // it condition is false for object which interset with boundary
    begin
      if OldPosition <> FDimensionItems[cur_node].ParentDem then
      begin
        Result := Insert(FDimensionItems[cur_node].ParentDem, AData, AVectorMinMax, OldPosition);
        if (OldPosition >= 0) and (OldPosition <> Result) then
          DoDelete(OldPosition, AData);
        exit;
      end else
        exit(OldPosition);
    end;
  end;
  //Result := -1;
end;

procedure TBlackSharkKDTree.DoDelete(ADem: int32; AData: Pointer);
var
  i: int32;
  opposite: int32;
  dem: int32;
  {$ifdef DEBUG}
  found: boolean;
  {$endif}
begin
  {$ifdef DEBUG}
  if FDimensionItems[ADem].Count = 0 then
    raise Exception.Create('A logic error!');
  {$endif}

  {$ifdef DEBUG}
  found := false;
  {$endif}
  for i := 0 to FDimensionItems[ADem].Count - 1 do
  begin
    if FDimensionItems[ADem].Data[i] = AData then
    begin
      {$ifdef DEBUG}
      found := true;
      {$endif}
      if (i < FDimensionItems[ADem].Count - 1) then
        FDimensionItems[ADem].Data[i] := FDimensionItems[ADem].Data[FDimensionItems[ADem].Count - 1];
      break;
    end;
  end;

  dec(FDimensionItems[ADem].Count);
  dec(FCount);

  {$ifdef DEBUG}
  if not found then
    raise Exception.Create('A logic error!');
  {$endif}


  if (FDimensionItems[ADem].Count = 0) then
  begin
    SetLength(FDimensionItems[ADem].Data, 0);
    dem := ADem;
    while (FDimensionItems[dem].ParentDem >= 0) do
    begin
      if (FDimensionItems[FDimensionItems[dem].ParentDem].Left <> dem) then
        opposite := FDimensionItems[FDimensionItems[dem].ParentDem].Left
      else
        opposite := FDimensionItems[FDimensionItems[dem].ParentDem].Right;

      {$ifdef DEBUG}
      if dem = opposite then
        raise Exception.Create('A logic error!');
      {$endif}

      if (FDimensionItems[opposite].Count = 0) and (FDimensionItems[dem].Count = 0) and
        (FDimensionItems[opposite].Left < 0) and (FDimensionItems[opposite].Right < 0) and
        (FDimensionItems[dem].Left < 0) and (FDimensionItems[dem].Right < 0) then
      begin
        FDimensionItems[FDimensionItems[dem].ParentDem].Left := -1;
        FDimensionItems[FDimensionItems[dem].ParentDem].Right := -1;
        CashDimItems.Add(dem);
        CashDimItems.Add(opposite);
        dem := FDimensionItems[dem].ParentDem;
        dec(FNodes, 2);
      end else
        break;
    end;
  end;
end;

function TBlackSharkKDTree.GetDimensionItem(AParentDem: int32; ADimension: int32; AMin, AMax: double): int32;
const
  STEP = 8192;
var
  i: int32;
  old: int32;
begin
  if CashDimItems.Count = 0 then
  begin
    old := length(FDimensionItems);
    SetLength(FDimensionItems, old + STEP);
    SetLength(FKeys, (old + STEP)*FDimension*2);
    CashDimItems.Count := STEP;
    for i := length(FDimensionItems) - 1 downto old do
      CashDimItems.Items[length(FDimensionItems) - 1 - i] := i;
  end;
  Result := GetDimensionItemDo(AParentDem, ADimension, AMin, AMax);
end;

function TBlackSharkKDTree.GetDimensionItemDo(AParentDem, ADimension: int32; AMin, AMax: double): int32;
begin
  Result := CashDimItems.Pop;
  FDimensionItems[Result].ParentDem := AParentDem;
  FDimensionItems[Result].Left := -1;
  FDimensionItems[Result].Right := -1;
  FDimensionItems[Result].Count := 0;
  FDimensionItems[Result].Dimension := ADimension;
  FKeys[Result*FDimensionDouble+ADimension] := AMin;
  FKeys[Result*FDimensionDouble+ADimension+FDimension] := AMax;
  inc(FNodes);
end;

{$ifdef DEBUG_ST}
function TBlackSharkKDTree.GetNodeAttributes(ANode: int32; out ABox: PBoxMinMax; out ADimensionSplit: int32;
  out ABoundarySplit: double; out ALeft, ARight: int32): boolean;
begin
  if ANode < 0 then
    exit(false);
  Result := true;
  ABox := @FKeys[ANode*FDimensionDouble];
  ALeft := FDimensionItems[ANode].Left;
  ARight := FDimensionItems[ANode].Right;
  if (ALeft >= 0) and (ARight >= 0) then
  begin
    ADimensionSplit := FDimensionItems[ARight].Dimension;
    ABoundarySplit := FKeys[ARight*FDimensionDouble + ADimensionSplit];
  end;
end;
{$endif}

procedure TBlackSharkKDTree.Init;
var
  i, j: int32;
  c: int32;
  nodes: array of integer;
  root2: int32;
begin
  // endless root of the world
  FRoot := GetDimensionItemDo(-1, 0, -MaxSingle+1.0, MaxSingle-1.0);
  for i := 1 to FDimension - 1 do
  begin
    FKeys[FRoot*FDimensionDouble+i] := -MaxSingle+1.0;
    FKeys[FRoot*FDimensionDouble+i+FDimension] := MaxSingle-1.0;
  end;

  // select center to FMinSize100x volume
  root2 := GetDimensionItemDo(FRoot, 0, -FMinSize100x, FMinSize100x);
  for i := 1 to FDimension - 1 do
  begin
    FKeys[root2*FDimensionDouble+i] := -FMinSize10x;
    FKeys[root2*FDimensionDouble+i+FDimension] := FMinSize10x;
  end;
  Stack.Count := 0;
  Stack.Add(root2);
  SetLength(nodes, sqr(FDimension));
  for i := 0 to FDimension - 1 do
  begin
    for j := 0 to Stack.Count - 1 do
    begin
      SplitNode(Stack.Items[j], i, 0.0);
      nodes[j shl 1] := FDimensionItems[Stack.Items[j]].Left;
      nodes[(j shl 1) + 1] := FDimensionItems[Stack.Items[j]].Right;
    end;
    c := Stack.Count shl 1;
    Stack.Count := 0;
    for j := 0 to c - 1 do
      Stack.Add(nodes[j]);
  end;
  Stack.Count := 0;
end;

function TBlackSharkKDTree.Insert(ANode: int32; AData: Pointer; AVectorMinMax: PBoxMinMax; OldPosition: int32): int32;
var
  d: int32;
  //mn: double;
  aligned_min: double;
  mx: double;
  aligned_max: double;
  width: double;
  new_boundary: double;
begin
  Result := ANode;
  // try to split the node
  if (FDimensionItems[ANode].Left < 0) or (FDimensionItems[ANode].Right < 0) then
  begin
    for d := 0 to FDimension - 1 do
    begin
      if FMinSize <> 1.0 then
      begin
        aligned_min := floor(AVectorMinMax^[d] / FMinSize) * FMinSize;
        aligned_max := ceil(AVectorMinMax^[d+FDimension] / FMinSize) * FMinSize;
      end else
      begin
        aligned_min := floor(AVectorMinMax^[d]);
        aligned_max := ceil(AVectorMinMax^[d+FDimension]);
      end;

      width := FKeys[Result*FDimensionDouble+FDimension+d] - FKeys[Result*FDimensionDouble+d];
      if (FMinSize10x*2 < width) and (aligned_max - aligned_min <= FMinSize10x) then
      begin
        if FKeys[Result*FDimensionDouble+d] < 0 then
        begin
          new_boundary := FKeys[Result*FDimensionDouble+FDimension+d] - FMinSize10x;
          if aligned_min < new_boundary then
            new_boundary := aligned_min;
          SplitNode(Result, d, new_boundary);
          Result := FDimensionItems[Result].Right;
        end else
        begin
          new_boundary := FKeys[Result*FDimensionDouble+d] + FMinSize10x;
          if aligned_max > new_boundary then
            new_boundary := aligned_max;
          SplitNode(Result, d, new_boundary);
          Result := FDimensionItems[Result].Left;
        end;

      end else
      if (FMinSize100x*2 < width) and (aligned_max - aligned_min <= FMinSize100x) then
      begin
        if FKeys[Result*FDimensionDouble+d] < 0 then
        begin
          new_boundary := FKeys[Result*FDimensionDouble+FDimension+d] - FMinSize100x;
          if aligned_min < new_boundary then
            new_boundary := aligned_min;
          SplitNode(Result, d, new_boundary);
          Result := FDimensionItems[Result].Right;
        end else
        begin
          new_boundary := FKeys[Result*FDimensionDouble+d] + FMinSize100x;
          if aligned_max > new_boundary then
            new_boundary := aligned_max;
          SplitNode(Result, d, new_boundary);
          Result := FDimensionItems[Result].Left;
        end;
        SplitNode(Result, d, new_boundary);
        Result := FDimensionItems[Result].Left;
      end;

      {mn := aligned_min - FKeys[Result*FDimensionDouble+d];
      if mn >= FMinSize2x then
      begin
        SplitNode(Result, d, aligned_min);
        Result := FDimensionItems[Result].Right;
      end;}
      if FKeys[Result*FDimensionDouble+d] < 0 then
      begin
        mx := FKeys[Result*FDimensionDouble+FDimension+d] - aligned_min;
        if mx >= FMinSize2x then
        begin
          SplitNode(Result, d, aligned_min-FMinSize);
          Result := FDimensionItems[Result].Right;
        end;
      end else
      begin
        mx := FKeys[Result*FDimensionDouble+FDimension+d] - aligned_max;
        if mx >= FMinSize2x then
        begin
          SplitNode(Result, d, aligned_max+FMinSize);
          Result := FDimensionItems[Result].Left;
        end;
      end;
    end;
  end;

  if OldPosition = Result then
    exit;

  if FDimensionItems[Result].Count = Length(FDimensionItems[Result].Data) then
    SetLength(FDimensionItems[Result].Data, Length(FDimensionItems[Result].Data)+4);
  FDimensionItems[Result].Data[FDimensionItems[Result].Count] := AData;
  inc(FDimensionItems[Result].Count);
  inc(FCount);
end;

procedure TBlackSharkKDTree.Remove(APosition: int32; AData: Pointer);
begin
  if APosition < 0 then
    exit;
  DoDelete(APosition, AData);
end;

procedure TBlackSharkKDTree.Select(ABox: PBoxMinMax; AList: TListVec<Pointer>);
var
  node: int32;
  mn, mx: double;
  i: Integer;
begin
  Stack.Add(FRoot);
  while Stack.Count > 0 do
  begin
    node := Stack.Pop;
    if node < 0 then
      raise Exception.Create('A logic error!');
    mn := bs.math.Max(FKeys[node*FDimensionDouble+FDimensionItems[node].Dimension],
      ABox^[FDimensionItems[node].Dimension]);
    mx := bs.math.Min(FKeys[node*FDimensionDouble+FDimensionItems[node].Dimension+FDimension],
      ABox^[FDimensionItems[node].Dimension+FDimension]);

    if (mn > mx) or ((mn = mx) and (ABox^[FDimensionItems[node].Dimension] <> ABox^[FDimensionItems[node].Dimension+FDimension])) then
    //if (mn >= ABox^[FDimensionItems[node].Dimension+FDimension]) and (mx < ABox^[FDimensionItems[node].Dimension]) then // it doesn't fit into cur_node
      continue;

    for i := 0 to FDimensionItems[node].Count - 1 do
      AList.Add(FDimensionItems[node].Data[i]);
    if FDimensionItems[node].Left >= 0 then
      Stack.Add(FDimensionItems[node].Left);
    if FDimensionItems[node].Right >= 0 then
      Stack.Add(FDimensionItems[node].Right);
  end;
end;

procedure TBlackSharkKDTree.Select(const AVectorMinMax: TBox3f; AList: TListVec<Pointer>);
var
  min_max: array[0..1] of TVec3d;
begin
  min_max[0] := AVectorMinMax.Min;
  min_max[1] := AVectorMinMax.Max;
  Select(@min_max, AList);
end;

procedure TBlackSharkKDTree.SplitNode(ANode: int32; ADimension: int32; ABoundary: double);
var
  i: int32;
  min, max: double;
begin                                                                // min                                    // max
  FDimensionItems[ANode].Left := GetDimensionItem(ANode, ADimension, FKeys[ANode*FDimensionDouble+ADimension], ABoundary);
                                                                      // min     // max
  FDimensionItems[ANode].Right := GetDimensionItem(ANode, ADimension, ABoundary, FKeys[ANode*FDimensionDouble+FDimension+ADimension]);

  // take from parent other boundaries of Dimensions
  for i := 0 to FDimension - 1 do
  begin
    if i = ADimension then
      continue;
    min := FKeys[ANode*FDimensionDouble+i];
    max := FKeys[ANode*FDimensionDouble+FDimension+i];
    FKeys[FDimensionItems[ANode].Left*FDimensionDouble+i] := min;
    FKeys[FDimensionItems[ANode].Left*FDimensionDouble+FDimension+i] := max;
    FKeys[FDimensionItems[ANode].Right*FDimensionDouble+i] := min;
    FKeys[FDimensionItems[ANode].Right*FDimensionDouble+FDimension+i] := max;
  end;
  {$ifdef DEBUG_ST}
  if Assigned(OnSplitDimension) then
    OnSplitDimension(ADimension, @FKeys[ANode*FDimensionDouble], ABoundary);
  {$endif}
end;

function TBlackSharkKDTree.UpdatePositionBB(AData: Pointer; const AVectorMinMax: TBox3f; OldPosition: int32): int32;
var
  min_max: array[0..1] of TVec3d;
begin
  min_max[0] := AVectorMinMax.Min;
  min_max[1] := AVectorMinMax.Max;
  Result := DoAdd(AData, @min_max, OldPosition);
end;

function TBlackSharkKDTree.UpdatePositionBB(AData: Pointer; VectorMinMax: PBoxMinMax; OldPosition: int32): int32;
begin
  Result := DoAdd(AData, VectorMinMax, OldPosition);
end;

end.

