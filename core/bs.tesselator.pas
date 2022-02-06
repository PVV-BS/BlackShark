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


unit bs.tesselator;

{$I BlackSharkCfg.inc}

interface

uses
    bs.collections
  , bs.basetypes
  , bs.geometry
  ;

type

  TContour = record
    PointIndexBegin: int32;
    CountPoints: int32;
    AsClockArr: boolean;
    { if a glyph is composite then Group defines set of all contours }
    Group: int8;
    { if NeedScale = true then need multiple all Points on ScaleTransformations }
    NeedScale: boolean;
    ScaleTransformations: TMatrix2f;
    { Points offset; apply after multiple ScaleTransformations (if need) }
    TranslateX: int32;
    TranslateY: int32;
  end;

  { TBlackSharkTesselator }

  TBlackSharkTesselator = class
  public
    type
      TListPoints = TSingleList<TVec3f>;
      PListPoints = TListPoints.PSingleListHead;
      TListContours = TSingleList<TContour>;
      PListContours = TListContours.PSingleListHead;
      TListIndexes = TSingleList<BSShort>;
      PListIndexes = TListIndexes.PSingleListHead;
  public
    type

      TSortListIndexes = TListDual<int32>;
      TListItem = TSortListIndexes.PListItem;
      PEdge = ^TEdge;
      TEdge = record
        case boolean of
        true: (
          index0,
          index1: int32);
        false:(key: int64);
      end;
      //Created Triangles, vv# are the vertex indexes
      TTriangle = record
        Complite: boolean;
        index: int32;
        case byte of
        0: (vv0, vv1, vv2: int32);
        1: (vv: array[0..2] of int32);
        2: (Edge0: TEdge; v3: int32);
        3: (v0: int32; Edge1: TEdge);
      end;

      TListGlyphTri = TListVec<TTriangle>;

      TListEdges = TListDual<TEdge>;
  private
    SortedPoints: TSortListIndexes;
    Triangles: TListGlyphTri;
    Edges: TListEdges;
    Edges2: TListVec<TEdge>;
    ActiveEdges: THashTable<int64, Pointer>;
    DeathEdges: THashTable<int64, Pointer>;
    SelectedEdges: TListVec<TEdge>;
    { save from Indexes offset pointers to index }
    Points: THashTable<TVec2f, PInteger>;
    Indexes: TListVec<int32>;
    IndexToCont: TListVec<int32>;
    PointsIntersect: TListVec<TVec2f>;

    CurrentPoints: PListPoints;
    CurrentContours: PListContours;
    CurrentOutIndexes: PListIndexes;
    CurrentRarePoints: PListPoints;
    CurrentRareContours: PListContours;

    procedure CheckEdg(const ed: TEdge); inline;
    function EdgeIntersectEdges(const ed: TEdge; ContGr: int8): boolean; inline;
    function IntersectCurrentContours(const p0, p1: TVec2f; Group: int8): int8; inline;
    procedure FillListPoints; inline;
    procedure FillSortedListPoints; inline;
  public
    xMax, yMax, xMin, yMin: BSFloat;

    constructor Create;
    destructor Destroy; override;
    class function Edge(i0, i1: int32): TEdge; static; inline;
    class function Contour(PointIndexBegin: int32; CountPoints: int32): TContour; static; inline;
    { triangulate a contor by Delaunay algorithm; do not support holes }
    procedure TriangulateDelaunay(
      var ListPoints: TBlackSharkTesselator.TListPoints.TSingleListHead;
      var ListContours: TBlackSharkTesselator.TListContours.TSingleListHead;
      var OutListIndexes: TBlackSharkTesselator.TListIndexes.TSingleListHead);
    function Triangulate(
      var ListPoints: TBlackSharkTesselator.TListPoints.TSingleListHead;
      var ListContours: TBlackSharkTesselator.TListContours.TSingleListHead;
      var OutListIndexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
      RareListPoints: PListPoints = nil; RareListContours: PListContours = nil;
      ErrorEdges: TListVec<TEdge> = nil): int32;
  end;

function Tesselator: TBlackSharkTesselator;

implementation

  uses bs.math;

var
  BSTesselator: TBlackSharkTesselator = nil;

function Tesselator: TBlackSharkTesselator;
begin
  if BSTesselator = nil then
    BSTesselator := TBlackSharkTesselator.Create;
  Result := BSTesselator;
end;

////////////////////////////////////////////////////////////////////////
// CircumCircle() :
//   Return true if a point (xp,yp) is inside the circumcircle made up
//   of the points (x1,y1), (x2,y2), (x3,y3)
//   The circumcircle centre is returned in (xc,yc) and the radius r
//   Note : A point on the edge is inside the circumcircle
////////////////////////////////////////////////////////////////////////
function CircumCircle(const p, p1, p2, p3: TVec2f; out c: TVec2f; out r: BSFloat): boolean; inline;
const
  ONEOFTHREE = 1/3;
var
  m1, m2: BSFloat;
  md1, md2, d: TVec2f;
  rsqr, drsqr: BSFloat;
begin

// Check for coincident points
if (abs(p1.y - p2.y) < EPSILON) and (abs(p2.y - p3.y) < EPSILON) then
  exit(false);

if (abs(p2.y - p1.y) < EPSILON) then
  begin
  m2 := - (p3.x - p2.x) / (p3.y - p2.y);
  md2 := (p2 + p3) * 0.5;
  c.x := (p2.x + p1.x) * 0.5;
  c.y := m2 * (c.x - md2.x) + md2.y;
  end else
if (abs(p3.y - p2.y) < EPSILON) then
  begin
  m1 := - (p2.x - p1.x) / (p2.y - p1.y);
  md1 := (p1 + p2) * 0.5;
  c.x := (p3.x + p2.x) * 0.5;
  c.y := m1 * (c.x - md1.x) + md1.y;
  end else
  begin
  m1 := - (p2.x - p1.x) / (p2.y - p1.y);
  m2 := - (p3.x - p2.x) / (p3.y - p2.y);
  md1 := (p1 + p2) * 0.5;
  md2 := (p2 + p3) * 0.5;

  if (m1 - m2) <> 0 then  //se
    begin
    c.x := (m1 * md1.x - m2 * md2.x + md2.y - md1.y) / (m1 - m2);
    c.y := m1 * (c.x - md1.x) + md1.y;
    end else
    begin
    c := (p1 + p2 + p3) * ONEOFTHREE;
    end;
  end;
  d := p2 - c;
  rsqr := d.x * d.x + d.y * d.y;
  r := sqrt(rsqr);
  d := p - c;
  drsqr := d.x * d.x + d.y * d.y;
  Result := (drsqr <= rsqr);
end;

class function TBlackSharkTesselator.Edge(i0, i1: int32): TEdge;
begin
  Result.index0 := i0;
  Result.index1 := i1;
end;

class function TBlackSharkTesselator.Contour(PointIndexBegin: int32; CountPoints: int32): TContour;
begin
  FillChar(Result{%H-}, SizeOf(Result), 0);
  Result.PointIndexBegin := PointIndexBegin;
  Result.CountPoints := CountPoints;
end;

function TBlackSharkTesselator.IntersectCurrentContours(const p0, p1: TVec2f; Group: int8): int8;
var
  j, i: int32;
  lim: int32;
  p10, p11, Point: TVec2f;
  bef_ind: int32;
  ind1, ind2, ind: int32;
begin
  Result := 0;
  bef_ind := -1;
  for j := 0 to CurrentRareContours.Count - 1 do
  begin
    if CurrentRareContours.items[j].Group <> Group then
      continue;
    lim := CurrentRareContours.items[j].PointIndexBegin + CurrentRareContours.items[j].CountPoints - 1;
    for i := CurrentRareContours.items[j].PointIndexBegin to lim do
    begin

      ind1 := i;
      if i < lim then
        ind2 := i+1
      else
        ind2 := CurrentRareContours.items[j].PointIndexBegin;

      p10.x := CurrentRarePoints.items[ind1].x;
      p10.y := CurrentRarePoints.items[ind1].y;
      p11.x := CurrentRarePoints.items[ind2].x;
      p11.y := CurrentRarePoints.items[ind2].y;

      if p10 = p11 then
        continue;

      if LinesIntersect(p0, p1, p10, p11, Point) then
      begin

        // first, are calculates that point is not tangent;

        if (Point.y = p10.y) then
        begin
          if (i > 0) then
            ind := i - 1 else
            ind := lim;

          if (bef_ind <> ind1) and ((CurrentRarePoints.items[ind].y < Point.y) and (p11.y > Point.y)) or //
            ((CurrentRarePoints.items[ind].y > Point.y) and (p11.y > Point.y)) then
              inc(Result);

          bef_ind := ind1;

        end else
        if (Point.y = p11.y) then
        begin
          if (j < lim - 1) then
            ind := i + 2 else
            ind := CurrentRareContours.items[j].PointIndexBegin;

          if (bef_ind <> ind2) and ((CurrentRarePoints.items[ind].y < Point.y) and (p10.y > Point.y)) or//
            ((CurrentRarePoints.items[ind].y > Point.y) and (p10.y < Point.y)) then
              inc(Result);

          bef_ind := ind2;
        end else
        begin
          inc(Result);
          bef_ind := -1;
        end;
      end;
    end;
  end;
end;

function Vec2fcmp(const Key1, Key2: TVec2f): int8;
begin
  if (Key1.y > Key2.y) then
    Result := 1 else
  if Key1.y < Key2.y then
    Result := -1 else
  if Key1.x > Key2.x then
    Result := 1 else
  if Key1.x < Key2.x then
    Result := -1 else
    Result := 0;
end;

function Vec2fcmpEqual(const Key1, Key2: TVec2f): boolean; inline;
begin
  Result := Key1 = Key2;
end;

function GetHashBlackSharkVec2f(const Key: TVec2f): uint32; inline;
begin
  Result := GetHashBlackShark(@Key, sizeof(Key));
end;


procedure TBlackSharkTesselator.FillListPoints;
var
  v: TVec3f;
  v2: TVec2f;
  i, j, bef: int32;
  edge: TEdge;
  ind: NativeInt;
  ptr: Pointer;
  it: Pointer;
begin
  xMin :=  MaxInt;
  yMin :=  MaxInt;
  xMax := -MaxInt;
  yMax := -MaxInt;
  Edges.Clear;
  edge.index0 := 0;
  edge.index1 := 1;
  edge.index0 := 1;
  edge.index1 := 0;
  Points.Clear;
  Indexes.Count := 0;
  SelectedEdges.Count := 0;
  CurrentOutIndexes.Count := 0;
  ActiveEdges.Clear;
  { reserves the capacity for reserve unchageable memory region on time fill
    Points, so as uses pointers Indexes.ShiftData[i] }
  Indexes.Capacity := CurrentPoints.Count;
  for j := 0 to CurrentContours.Count - 1 do
  begin
    bef := -1;
    for i := CurrentContours.items[j].PointIndexBegin to CurrentContours.items[j].PointIndexBegin + CurrentContours.items[j].CountPoints - 1 do
    begin
      v := CurrentPoints.items[i];
      v2 := vec2(v.x, v.y);
      if Points.Find(v2, PInteger(ptr)) then
      begin
        ind := PInteger(ptr)^;
        Indexes.Items[i] := -1;
      end else
      begin
        ind := i;
        Indexes.Items[i] := i;
        Points.Items[v2] := Indexes.ShiftData[i];
      end;

      IndexToCont.Items[i] := j;

      if (bef < 0) or (ind = bef) then //
      begin
        bef := ind;
        continue;
      end;

      if v.x < xMin then
        xMin := v.x;
      if v.y < yMin then
        yMin := v.y;
      if xMax < v.x then
        xMax := v.x;
      if yMax < v.y then
        yMax := v.y;

      edge.index0 := bef;
      edge.index1 := ind;
      if ActiveEdges.Find(edge.key, it) then
      begin
        continue;
      end;
      SelectedEdges.Add(edge);
      ActiveEdges.Items[edge.key] := Edges.PushToBegin(edge);
      bef := ind;
    end;

    if (bef < 0) or (CurrentContours.items[j].PointIndexBegin = bef) then
    begin
      continue;
    end;

    edge.index0 := bef;
    edge.index1 := CurrentContours.items[j].PointIndexBegin;
    if ActiveEdges.Find(edge.key, it) then
      continue;
    ActiveEdges.Items[edge.key] := Edges.PushToEnd(edge);
    SelectedEdges.Add(edge);
  end;
end;

procedure TBlackSharkTesselator.FillSortedListPoints;
var
  item: TListItem;
  v: TVec3f;
  i, j: int32;
begin
  xMin :=  MaxInt;
  yMin :=  MaxInt;
  xMax := -MaxInt;
  yMax := -MaxInt;
  SortedPoints.Clear;
  for j := 0 to CurrentContours.Count - 1 do
    begin
    for i := CurrentContours.items[j].PointIndexBegin to CurrentContours.items[j].PointIndexBegin + CurrentContours.items[j].CountPoints - 1 do
      begin
      v := CurrentPoints.items[i];
      item := SortedPoints.ItemListLast;
      while (item <> nil) and (v.x < CurrentPoints.items[item.Item].x) do
        item := item.Prev;
      if v.x < xMin then
        xMin := v.x;
      if v.y < yMin then
        yMin := v.y;
      if xMax < v.x then
        xMax := v.x;
      if yMax < v.y then
        yMax := v.y;
      if item = nil then
        SortedPoints.PushToBegin(i) else
        SortedPoints.InsertAfter(i, item);
      end;
    end;
end;

constructor TBlackSharkTesselator.Create;
begin
  SortedPoints := TSortListIndexes.Create;
  Triangles := TListGlyphTri.Create();
  Triangles.Capacity := 256;
  Edges := TListEdges.Create;
  Edges2 := TListVec<TEdge>.Create;
  ActiveEdges := THashTable<int64, Pointer>.Create(@GetHashBlackSharkInt64, @Int64cmpEqual);
  DeathEdges := THashTable<int64, Pointer>.Create(@GetHashBlackSharkInt64, @Int64cmpEqual);
  SelectedEdges := TListVec<TEdge>.Create;
  Points := THashTable<TVec2f, PInteger>.Create(@GetHashBlackSharkVec2f, @Vec2fcmpEqual);
  PointsIntersect := TListVec<TVec2f>.Create;
  Indexes := TListVec<int32>.Create;
  Indexes.DefaultValue := -1;
  IndexToCont := TListVec<int32>.Create;
end;

destructor TBlackSharkTesselator.Destroy;
begin
  IndexToCont.Free;
  SortedPoints.Free;
  PointsIntersect.Free;
  Triangles.Free;
  Edges2.Free;
  ActiveEdges.Free;
  DeathEdges.Free;
  SelectedEdges.Free;
  Points.Free;
  Indexes.Free;
  Edges.Free;
  inherited Destroy;
end;

procedure TBlackSharkTesselator.TriangulateDelaunay(
  var ListPoints: TBlackSharkTesselator.TListPoints.TSingleListHead;
  var ListContours: TBlackSharkTesselator.TListContours.TSingleListHead;
  var OutListIndexes: TBlackSharkTesselator.TListIndexes.TSingleListHead);
var
  item: TListItem;
  ed, ed1: TListEdges.PListItem;
  Triangle: TTriangle;

  //For Super Triangle
  xmid: Double;
  ymid: Double;
  dmax: Double;

  //General Variables
  i, j: int32;
  inside: boolean;
  //cou_vert: int32;
  r: BSFloat;
  p0, p1, p2, c, p: TVec2f;

begin

  CurrentPoints := @ListPoints;
  CurrentContours :=  @ListContours;
  CurrentOutIndexes := @OutListIndexes;
  if (CurrentPoints^.Count < 3) then
    exit;
  CurrentOutIndexes.Count := 0;
  Triangles.Count := 0;
  // sort all points by x
  FillSortedListPoints;
  xmid := Trunc(xMax + xMin) shr 1;
  ymid := Trunc(yMax + yMin) shr 1;
  p.x := xMax - xMin;
  p.y := yMax - yMin;
  if p.x > p.y then
    dmax := p.x
  else
    dmax := p.y;

  { Set up the supertriangle
    This is a triangle which encompasses all the sample points.
    The supertriangle coordinates are added to the end of the
    vertex list. The supertriangle is the first triangle in
    the triangle list.  }

  TListPoints.Add(CurrentPoints^, vec3(xmid - 2 * dmax, ymid - dmax, 0.0));
  TListPoints.Add(CurrentPoints^, vec3(xmid, ymid + 2 * dmax, 0.0));
  TListPoints.Add(CurrentPoints^, vec3(xmid + 2 * dmax, ymid - dmax, 0.0));
  Triangle.Complite := false;
  Triangle.vv0 := CurrentPoints.Count - 3;
  Triangle.vv1 := CurrentPoints.Count - 2;
  Triangle.vv2 := CurrentPoints.Count - 1;
  Triangles.Add(Triangle);

  //cou_vert := 0;
  //Include each point one at a time into the existing mesh
  item := SortedPoints.ItemListFirst;
  while item <> nil do
  begin
    Edges.Clear;
    //inc(cou_vert);
    //   Include each point one at a time into the existing mesh
    i := item.item;
    p := vec2(CurrentPoints.items[i].x, CurrentPoints.items[i].y);
    item := item.next;
    {
         Set up the edge buffer.
         If the point (xp,yp) lies inside the circumcircle then the
         three edges of that triangle are added to the edge buffer
         and that triangle is removed.
    }
    j := 0;
    while j < Triangles.Count do
    begin
      if(Triangles.items[j].Complite) then
      begin
        inc(j);
        continue;
      end;
      if (i = Triangles.items[j].vv0) or
         (i = Triangles.items[j].vv1) or
         (i = Triangles.items[j].vv2) then
      begin
        inc(j);
        continue;
      end;
      p0 := vec2(CurrentPoints.items[Triangles.items[j].vv0].x, CurrentPoints.items[Triangles.items[j].vv0].y);
      p1 := vec2(CurrentPoints.items[Triangles.items[j].vv1].x, CurrentPoints.items[Triangles.items[j].vv1].y);
      p2 := vec2(CurrentPoints.items[Triangles.items[j].vv2].x, CurrentPoints.items[Triangles.items[j].vv2].y);
      inside := CircumCircle(p, p0, p1, p2, c, r);
      if (inside) then
      begin
        Edges.PushToEnd(Edge(Triangles.Data^[j].vv0, Triangles.Data^[j].vv1));
        Edges.PushToEnd(Edge(Triangles.Data^[j].vv1, Triangles.Data^[j].vv2));
        Edges.PushToEnd(Edge(Triangles.Data^[j].vv2, Triangles.Data^[j].vv0));
        if Triangles.Count > 1 then
          Triangles.items[j] := Triangles.items[Triangles.Count - 1];
        Triangles.Count := Triangles.Count - 1;
        continue;
      end else
      if (c.x + r < p.x) then
        Triangles.Data^[j].Complite := true;
      inc(j);
    end;
    {
      Tag multiple edges
      Note: if all triangles are specified anticlockwise then all
      interior edges are opposite pointing in direction.
    }
    ed := Edges.ItemListFirst;
    while ed <> nil do
    begin
      ed1 := ed.next;
      while ed1 <> nil do
        begin
        if((ed.item.index0 = ed1.item.index1) and (ed.item.index1 = ed1.item.index0)) then
        begin
          Edges.Remove(ed1);
          ed.item.index0 := -1;
          break;
        end;
         // Shouldn't need the following, see note above
        if((ed.item.index0 = ed1.item.index0) and (ed.item.index1 = ed1.item.index1)) then
        begin
          Edges.Remove(ed1);
          ed.item.index0 := -1;
          break;
        end;
        ed1 := ed1.next;
      end;
      {
           Form new triangles for the current point
           Skipping over any tagged edges.
           All edges are arranged in clockwise order.
      }

      if (ed.item.index0 < 0) then //or (IntersectCurrentContours(Glyph, ed.item.index0, ed.item.index1) > 2)
      begin
        ed1 := ed.next;
        Edges.Remove(ed);
        ed := ed1;
        continue;
      end;
      //p0 := vec2(CurrentPoints.items[ed.item.index0].x, CurrentPoints.items[ed.item.index0].y);
      //p1 := vec2(CurrentPoints.items[ed.item.index1].x, CurrentPoints.items[ed.item.index1].y);
      //p0 := (p0 + p1 + p) / 3;
      //if (IntersectCurrentContours(p0, p1) = 0)
      //  and (IntersectCurrentContours(p1, p2) = 0)
      //  and (IntersectCurrentContours(p2, p0) = 0) then
      begin
        Triangle.vv0 := ed.item.index0;
        Triangle.vv1 := ed.item.index1;
        Triangle.vv2 := i;
        Triangle.Complite := false;
        Triangles.Add(Triangle);
      end;
      ed := ed.next;
    end;
  end;

  {
        Remove triangles with supertriangle vertices
        These are triangles which have a vertex number greater than SortedPoints.Count
  }

  for i := Triangles.Count - 1 downto 0 do
    begin
    if
      (Triangles.Data^[i].vv0 >= SortedPoints.Count) or
      (Triangles.Data^[i].vv1 >= SortedPoints.Count) or
      (Triangles.Data^[i].vv2 >= SortedPoints.Count) then
      begin
      Triangles.Data^[i] := Triangles.Data^[Triangles.Count - 1];
      Triangles.Count := Triangles.Count - 1;
      end;
    Triangles.Data^[i].Complite := false;
    Triangles.Data^[i].index := i;
    end;

  { Remove triangles intersecting contours }

  //RemoveExceedTriangles;

  for i := 0 to Triangles.Count - 1 do
    begin
    TListIndexes.Add(CurrentOutIndexes^, Triangles.Items[i].vv0);
    TListIndexes.Add(CurrentOutIndexes^, Triangles.Items[i].vv1);
    TListIndexes.Add(CurrentOutIndexes^, Triangles.Items[i].vv2);
    end;

  // remove 3 last points - vertexes supertriangle
  CurrentPoints.Count := CurrentPoints^.Count - 3;
end;

procedure TBlackSharkTesselator.CheckEdg(const ed: TEdge);
var
  EdgIt: TListEdges.PListItem;
  edg_inv: TEdge;
begin
  if (ActiveEdges.Find(ed.key, Pointer(EdgIt))) then
  begin
    ActiveEdges.Delete(ed.key);
    Edges.Remove(EdgIt);
    DeathEdges.Items[ed.key] := Pointer($FFFFFFFF);
    edg_inv := Edge(ed.index1, ed.index0);
    DeathEdges.Items[edg_inv.key] := Pointer($FFFFFFFF);
  end else
  begin
    edg_inv := Edge(ed.index1, ed.index0);
    if (ActiveEdges.Find(edg_inv.key, Pointer(EdgIt))) then
    begin
      ActiveEdges.Delete(edg_inv.key);
      Edges.Remove(EdgIt);
      DeathEdges.Items[ed.key] := Pointer($FFFFFFFF);
      DeathEdges.Items[edg_inv.key] := Pointer($FFFFFFFF);
    end else
    begin
      ActiveEdges.Items[ed.key] := Edges.PushToEnd(ed);
      SelectedEdges.Add(ed);
    end;
  end;
end;

function TBlackSharkTesselator.EdgeIntersectEdges(const ed: TEdge; ContGr: int8): boolean;
var
  j: int32;
  p00, p01, p10, p11: TVec2f;
  edg: TEdge;
begin
  p00 := vec2(CurrentPoints.items[ed.index0].x, CurrentPoints.items[ed.index0].y);
  p01 := vec2(CurrentPoints.items[ed.index1].x, CurrentPoints.items[ed.index1].y);
  for j := 0 to SelectedEdges.Count - 1 do
    begin
    edg := SelectedEdges.Data^[j];
    if (edg.index0 = ed.index0) or (edg.index1 = ed.index1) or
      (edg.index0 = ed.index1) or (edg.index1 = ed.index0) or
      (CurrentContours.Items[IndexToCont.Items[edg.index0]].Group <> ContGr)
       then
        continue;
    p10.x := CurrentPoints.items[edg.index0].x;
    p10.y := CurrentPoints.items[edg.index0].y;
    p11.x := CurrentPoints.items[edg.index1].x;
    p11.y := CurrentPoints.items[edg.index1].y;
    {if (
      (((P00.x <= P10.x) and (P00.x <= P11.x)) and ((P01.x <= P10.x) and (P01.x <= P11.x))) or
      (((P00.x >= P10.x) and (P00.x >= P11.x)) and ((P01.x >= P10.x) and (P01.x >= P11.x))) or
      (((P00.y <= P10.y) and (P00.y <= P11.y)) and ((P01.y <= P10.y) and (P01.y <= P11.y))) or
      (((P00.y >= P10.y) and (P00.y >= P11.y)) and ((P01.y >= P10.y) and (P01.y >= P11.y)))
      ) then
        continue;   }
    if LinesIntersectExclude(p00, p01, p10, p11) then
      exit(true);
    end;
  Result := false;
end;

function TBlackSharkTesselator.Triangulate(
  var ListPoints: TBlackSharkTesselator.TListPoints.TSingleListHead;
  var ListContours: TBlackSharkTesselator.TListContours.TSingleListHead;
  var OutListIndexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
  RareListPoints: PListPoints = nil; RareListContours: PListContours = nil;
  ErrorEdges: TListVec<TEdge> = nil): int32;
const
  THIRD = 1/3.0;
var
  i: int32;
  r: BSFloat;
  edg, edg_inv: TEdge;
  selected: int32;
  p, p0, p1, cntr, v0, v1, sel, c: TVec2f;
  v30, v31: TVec3f;
  cont_gr: int8;
begin
  Result := 0;
  if ListPoints.Count < 3 then
    exit;

  CurrentPoints := @ListPoints;
  CurrentContours :=  @ListContours;
  CurrentOutIndexes := @OutListIndexes;


  if (RareListPoints <> nil) and (RareListPoints.Count > 0) and (RareListContours <> nil) and (RareListContours.Count > 0) then
  begin
    CurrentRarePoints := RareListPoints;
    CurrentRareContours := RareListContours;
  end else
  begin
    CurrentRarePoints := @ListPoints;
    CurrentRareContours := @ListContours;
  end;

  FillListPoints;

  DeathEdges.Clear;
  sel := vec2(0.0, 0.0);
  while Edges.Count > 0 do
  begin
    edg := Edges.Pop;
    ActiveEdges.Delete(edg.key);
    p0 := vec2(CurrentPoints.items[edg.index0].x, CurrentPoints.items[edg.index0].y);
    p1 := vec2(CurrentPoints.items[edg.index1].x, CurrentPoints.items[edg.index1].y);
    cont_gr := CurrentContours.Items[IndexToCont.Items[edg.index0]].Group;
    //if ((p0.x = 794) or (p1.x = 794)) and ((p0.x = 1092)or (p1.x = 1092)) then
    //  p0.x := p0.x;
    //if ((edg.index0 = 46) or (edg.index1 = 46)) then // and ((edg.index1 = 84) or (edg.index1 = 98))
    //  edg.index0 := edg.index0;
    selected := -1;
    for i := 0 to CurrentPoints.Count - 1 do
    begin

      if (Indexes.Items[i] < 0) or (i = edg.index0) or (i = edg.index1) then
        continue;

      if cont_gr <> CurrentContours.Items[IndexToCont.Items[i]].Group then
      begin
        //cont_gr := cont_gr;
        continue;
      end;

      {delta := abs(i - edg.index0);
      if (delta > 1) and (delta <> CurrentContours.Items[IndexToCont.Items[i]].CountPoints) then
      begin
        delta := abs(i - edg.index1);
        if (delta > 1) and (delta <> CurrentContours.Items[IndexToCont.Items[i]].CountPoints) then
        begin
          delta := abs(edg.index1 - edg.index0);
          if (delta > 1) and (delta <> CurrentContours.Items[IndexToCont.Items[i]].CountPoints) then
            continue;
        end;
      end;  }

      p := vec2(CurrentPoints.items[i].x, CurrentPoints.items[i].y);
      //if (i = 110) then
      //  edg.index0 := edg.index0;
      v0 := p - p0;
      v1 := p1 - p0;
      v30 := vec3(v1.x, v1.y, 0.0);
      v31 := vec3(v0.x, v0.y, 0.0);
      // detect only clockwise
      v30 := VecCross(v30, v31);
      if (v30.z >= 0) then
        continue;

      //v1 := p - p1;
      //if (VecLenSqr(v0) > l) or (VecLenSqr(v1) > l) then
      //  continue;

      if selected >= 0 then
      begin
        if not CircumCircle(p, p0, p1, sel, c, r) then
          continue;
      end;

      edg_inv := Edge(i, edg.index0);

      if DeathEdges.Exists(edg_inv.key) then
        continue;

      edg_inv := Edge(i, edg.index1);
      if DeathEdges.Exists(edg_inv.key) then
        continue;

      {if IntersectCurrentContoursExclude(p, p0) then
        continue;
      if IntersectCurrentContoursExclude(p, p1) then
        continue;  }

      if EdgeIntersectEdges(edge(edg.index0, i), cont_gr) or EdgeIntersectEdges(edge(edg.index1, i), cont_gr) then
        continue;

      cntr := (p0 + p1 + p) * THIRD;

      if (IntersectCurrentContours(cntr, vec2(65536, cntr.y), cont_gr) mod 2 = 0) then
        continue;

      selected := i;
      sel := p;
    end;

    if selected < 0 then
    begin
      selected := abs(edg.index1 - edg.index0);
      //CurrentContours.items[j].CountPoints

      if (IndexToCont.Items[edg.index0] = IndexToCont.Items[edg.index1]) and
        ((selected = 1) or (CurrentContours.Items[IndexToCont.Items[edg.index0]].CountPoints = selected)) then
        begin
          if ErrorEdges <> nil then
            ErrorEdges.Add(edg);
          inc(Result);
        end;
      continue;
    end;


    TListIndexes.Add(OutListIndexes, edg.index0);
    TListIndexes.Add(OutListIndexes, edg.index1);
    TListIndexes.Add(OutListIndexes, selected);
    //if CurrentOutIndexes.Count div 3 = 93 then
    //  CurrentOutIndexes.Count := CurrentOutIndexes.Count;
    DeathEdges.TryAdd(edg.key, Pointer($FFFFFFFF));
    //DeathEdges.Items[edg.key] := Pointer($FFFFFFFF);
    edg_inv.index0 := edg.index1; edg_inv.index1 := edg.index0;
    DeathEdges.TryAdd(edg_inv.key, Pointer($FFFFFFFF));
    //DeathEdges.Items[edg_inv.key] := Pointer($FFFFFFFF);

    {if CurrentOutIndexes.Count div 3 = 9 then
      begin
      CurrentOutIndexes.Count := CurrentOutIndexes.Count;
      //break;
      end;  }
    {if (selected = 63) then
      selected := selected;}

    // add edges so new triangle will left
    CheckEdg(Edge(edg.index0, selected));
    CheckEdg(Edge(selected, edg.index1));
  end;
end;

initialization

finalization
  if BSTesselator <> nil then
    BSTesselator.Free;

end.


