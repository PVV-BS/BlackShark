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


unit bs.mesh.primitives;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.basetypes
  , bs.mesh
  , bs.collections
  , bs.gl.es
  ;

type

  TSplineInterpolateFunction = procedure (SplinePoints: PArrayVec3f; Count: int32; OutShape: TMesh) of object;

  { the namespace of the generating vertexes of meshes, consisting of point }

  TBlackSharkFactoryShapesP = class
  public
    class function CreateShape: TMesh;
    { Plane }
    class procedure GeneratePlane(Shape: TMesh; const SizePlane: TVec2f); overload;
    class procedure GeneratePlane(Shape: TMesh; const P1, P2, P3, P4: TVec3f); overload;
    { Rectangle not fill }
    class procedure GenerateRectangle(Shape: TMesh; WidthLile: BSFloat; Width, Height: BSFloat); overload;
    { Round Rect }
    class procedure GenerateRoundRect(Shape: TMesh; WidthLine: BSFloat;
      NumSlices: int32; Radius: BSFloat; Width, Height: BSFloat); overload;
    // create filled round rect
    class procedure GenerateRoundRect(Shape: TMesh; NumSlices: int32; Radius: BSFloat; Width,
      Height: BSFloat); overload;
    { Lines }

    // plane line
    class procedure GenerateLine2d(Shape: TMesh; ALength: BSFloat; Width: BSFloat);
    { Cylinder }
    class procedure GenerateCylinder(Shape: TMesh; Radius: BSFloat;
      NumSlices: int32; Height: BSFloat;
      TextureTop: boolean = true; TextureBottom: boolean = true
      );

    class procedure GenerateTrancatedCylinder(Shape: TMesh; Radius: BSFloat; NumSlices: int32;
      HeightHigh, HeightLow: BSFloat; TextureBottom: boolean = false;
      TextureTop: boolean = false);

    { Arrow }
    class procedure GenerateArrow2d(Shape: TMesh; ALength: BSFloat;
      Width: BSFloat; LenTip: BSFloat; WidthTip: BSFloat
      ); overload;

    { Grid }
    class procedure GenerateGrid(Shape: TMesh; const Size: TVec2f;
      StepX, StepY: BSFloat; HorizontalLines, VerticalLines, Closed, Triangles: boolean;
      Width: BSFloat);
    { AngleArc; returns position of center }
    class function GenerateAngleArc(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; StartAngle, Angle: BSFloat): TVec3f; overload;
    class function GenerateAngleArc(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; StartAngle, Angle: BSFloat; WidthLine: BSFloat): TVec3f; overload;
    { Ellipse }
    class procedure GenerateEllipse(Shape: TMesh; NumSlices: int32;
      a, b: BSFloat);
    { Bezier Spline }
    { Generate Bezier 2d curve }
    class procedure GenerateBezierLinear(Shape: TMesh; const P0, P1: TVec3f;
      AWidth: BSFloat; STEP: BSFloat = 0.3; CalcBB: boolean = true); overload;
    class procedure GenerateBezierQuadratic(Shape: TMesh;
      const P0, P1, P2: TVec3f; AWidth: BSFloat; STEP: BSFloat = 0.2; CalcBB: boolean = true); overload;
    class procedure GenerateBezierCubic(Shape: TMesh;
      const P0, P1, P2, P3: TVec3f; AWidth: BSFloat; STEP: BSFloat = 0.2; CalcBB: boolean = true); overload;
    { Cone }
    class procedure GenerateCone(Shape: TMesh; NumSlices: int32; Radius: BSFloat;
      Height: BSFloat; TextureBottom: boolean);
    { Truncated Cone }
    class procedure GenerateTruncatedCone(Shape: TMesh; RadiusTop,
      RadiusBottom: BSFloat; NumSlices: int32; Height: BSFloat;
      TextureTop: boolean; TextureBottom: boolean);
    { Circle }
    class procedure GenerateCircle(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat); overload;
    class procedure GenerateCircle(Shape: TMesh; WidthLine: BSFloat;
      NumSlices: int32; Radius: BSFloat); overload;
    { Half Circle }
    class procedure GenerateHalfCircle(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat);
    { Sphere }
    class procedure GenerateSphere(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; PrimitiveTriangleStrip: boolean = true);
    { Cube }
    class procedure GenerateCube(Shape: TMesh; const Size: TVec3f);
    { Trapeze }
    class procedure GenerateTrapeze(Shape: TMesh; UpperBase, LowerBase, Height:
      BSFloat; WidthLine: BSFloat; Fill: boolean);
    { Round Trapeze }
    class procedure GenerateTrapezeRound(Shape: TMesh; UpperBase, LowerBase,
      Height: BSFloat; WidthLine: BSFloat; Radius: BSFloat; NumSlices: int32; Fill: boolean);
  end;

  { the namespace of the generating vertexes of meshes, consisting of point
    and texture }

  TBlackSharkFactoryShapesPT = class
  public
    class function CreateShape: TMesh;
    { Plane }
    class procedure GeneratePlane(Shape: TMesh; const SizePlane: TVec2f);
    { Rectangle }
    class procedure GenerateRectangle(Shape: TMesh; WidthLile: BSFloat; Width, Height: BSFloat); overload;
    { Round Rect }
    class procedure GenerateRoundRect(Shape: TMesh; WidthLine: BSFloat;
      NumSlices: int32; Radius: BSFloat; Width, Height: BSFloat); overload;
    // create filled round rect
    class procedure GenerateRoundRect(Shape: TMesh; NumSlices: int32; Radius: BSFloat; Width, Height: BSFloat); overload;
    { Lines }

    // plane line
    class procedure GenerateLine2d(Shape: TMesh; ALength: BSFloat; Width: BSFloat);

    class function GeneratePath2d(Shape: TMesh; Points: PArrayVec3f;
      Count: int32; VerticalWidth: BSFloat; Closed: boolean;
      CalcBB: boolean): TVec3f;

    class procedure GenerateBezierCubic(Shape: TMesh; const P0, P1, P2, P3: TVec3f;
      AWidth, STEP: BSFloat; CalcBB: boolean);

    class procedure GenerateBezierLinear(Shape: TMesh; const P0, P1: TVec3f;
      AWidth, STEP: BSFloat; CalcBB: boolean);

    class procedure GenerateBezierQuadratic(Shape: TMesh; const P0, P1, P2: TVec3f;
      AWidth, STEP: BSFloat; CalcBB: boolean);

    { Cylinder }
    class procedure GenerateCylinder(Shape: TMesh; Radius: BSFloat;
      NumSlices: int32; Height: BSFloat;
      TextureTop: boolean = true; TextureBottom: boolean = true
      );
    class procedure GenerateTrancatedCylinder(Shape: TMesh; Radius: BSFloat; NumSlices: int32;
      HeightHigh, HeightLow: BSFloat; TextureBottom: boolean = false;
      TextureTop: boolean = false);
    { Arrow }
    class procedure GenerateArrow2d(Shape: TMesh; ALength: BSFloat;
      Width: BSFloat; LenTip: BSFloat; WidthTip: BSFloat
      ); overload;
    class procedure GenerateGrid(Shape: TMesh; const Size: TVec2f;
      StepX, StepY: BSFloat; HorizontalLines, VerticalLines, Closed, Triangles: boolean;
      Width: BSFloat);
    { AngleArc }
    class function GenerateAngleArc(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; StartAngle, Angle: BSFloat): TVec3f; overload;
    class function GenerateAngleArc(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; StartAngle, Angle: BSFloat; WidthLine: BSFloat): TVec3f; overload;
    { Ellipse }
    class procedure GenerateEllipse(Shape: TMesh; NumSlices: int32;
      DeltaF: BSFloat); overload;
    class procedure GenerateEllipse(Shape: TMesh; NumSlices: int32;
      a, b: BSFloat); overload;
    { Cone }
    class procedure GenerateCone(Shape: TMesh; NumSlices: int32; Radius: BSFloat;
      Height: BSFloat; TextureBottom: boolean);
    { Truncated Cone }
    class procedure GenerateTruncatedCone(Shape: TMesh; RadiusTop,
      RadiusBottom: BSFloat; NumSlices: int32; Height: BSFloat;
      TextureTop: boolean; TextureBottom: boolean);
    { Circle }
    class procedure GenerateCircle(Shape: TMesh; NumSlices: int32; Radius: BSFloat); overload;
    class procedure GenerateCircle(Shape: TMesh; WidthLine: BSFloat; NumSlices: int32; Radius: BSFloat); overload;
    { Half Circle }
    class procedure GenerateHalfCircle(Shape: TMesh; NumSlices: int32; Radius: BSFloat);
    { Sphere }
    class procedure GenerateSphere(Shape: TMesh; NumSlices: int32;
      Radius: BSFloat; PrimitiveTriangleStrip: boolean = true);
    { Cube }
    class procedure GenerateCube(Shape: TMesh; const Size: TVec3f; const TexRect: TRectBSf);
    { Trapeze }
    class procedure GenerateTrapeze(Shape: TMesh; UpperBase, LowerBase, Height:
      BSFloat; WidthLine: BSFloat; Fill: boolean);
  end;

function GeneratePath2d(Shape: TMesh; Points: PArrayVec3f; Count: int32;
  VerticalWidth: BSFloat; Closed: boolean = false; CalcBB: boolean = false; IsLines: boolean = false): TVec3f;

function GenerateLine2d(Shape: TMesh; const Point1, Point2: TVec3f; VerticalWidth: BSFloat; CalcBB: boolean; AsStrip: boolean): TVec3f;

function GenerateClosedShape(Shape: TMesh; Points: PArrayVec3f; Count: int32): TVec3f;

procedure GenerateArrow2d(Shape: TMesh; ALength, Width: BSFloat);

{ Bezier Spline }
{ Generate Bezier 2d curve }

procedure GenerateBezierLinear(const P0, P1: TVec3f; var OutSplineVertexes: TListVec3f; STEP: BSFloat);

procedure GenerateBezierQuadratic(const P0, P1, P2: TVec3f; var OutSplineVertexes: TListVec3f; STEP: BSFloat);

procedure GenerateBezierCubic(const P0, P1, P2, P3: TVec3f; var OutSplineVertexes: TListVec3f; STEP: BSFloat = 0.2);

procedure GenerateBezierSpline(InBaseVertexes: PArrayVec3f; CountVertexes: int32; var OutSplineVertexes: TListVec3f; STEP: BSFloat);

procedure GenerateCubicHermiteSpline(InBaseVertexes: PArrayVec3f; CountBaseVertexes: int32; var OutSplineVertexes: TListVec3f; SmoothingFactor: BSFloat; Closed: boolean);

procedure GenerateCubicSpline(InBaseVertexes: PArrayVec3f; CountBaseVertexes: int32; var OutSplineVertexes: TListVec3f; SmoothingFactor: BSFloat);

procedure CreateBorder(SourceShape, DestinationShape: TMesh; Width: BSFloat; Closed: boolean = true);

implementation

  uses
    {$ifdef DEBUG}
      bs.thread,
    {$endif}
      bs.math
    , Math
    ;

function GeneratePath2d(Shape: TMesh; Points: PArrayVec3f; Count: int32; VerticalWidth: BSFloat; Closed: boolean; CalcBB: boolean; IsLines: boolean): TVec3f;
const
  eps = EPSILON * 10;
var
  i,j, _count: int32;
  a, a_befor, d, s, c, a_closed: BSFloat;
  edg: TVec3f;
  edg_path, last_edg_path: TVec3f;
  p1, p2: TVec3f;
  a_bw_edg: BSFloat;
  widthHalf: BSFloat;
begin
  if Count < 2 then
    exit(vec3(0.0, 0.0, 0.0));

  widthHalf := VerticalWidth*0.5;
  Shape.FBoundingBox.Max := Points^[0];
  Shape.FBoundingBox.Min := Points^[0];
  _count := Count - 1;
  if IsLines then
  begin
    Shape.TypePrimitive := tpLineStrip;
    for i := 0 to _count do
    begin
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(Points^[i]);
      Box3CheckBB(Shape.FBoundingBox, Points^[i]);
    end;
  end else
  begin
    Shape.TypePrimitive := tpTriangleStrip;
    if Closed then
    begin
      last_edg_path := Points^[0] - Points^[_count];
    end else
    begin
      i := 0;
      while (i < _count - 1) and (Points^[i] = Points^[i+1]) do
        inc(i);

      last_edg_path := Points^[i+1] - Points^[i];
    end;
    a_befor := -VecDecisionX(last_edg_path);
    a_closed := a_befor;
    for i := 0 to _count do
    begin
      if i < _count then
      begin
        j := i;
        //while (j < _count - 1) and (Points^[j] = Points^[j+1]) do
        //  inc(j);
        edg_path := Points^[j+1] - Points^[j];
        if edg_path = vec3(0.0, 0.0, 0.0) then
          edg_path := last_edg_path;
        a := -VecDecisionX(edg_path);
      end else
      begin
        edg_path := Points^[0] - Points^[_count];
        if Closed then
          a := a_closed
        else
          a := a_befor;
      end;

      a_bw_edg := abs(a - a_befor);
      c := BS_Cos(a_bw_edg*0.5);
      if abs(c) > eps then
        d := widthHalf/c
      else
        d := widthHalf;

      BS_SinCos(abs(a + a_befor)*0.5 - 90, s, c);

      edg := vec3(d*c, d*s, 0.0);

      last_edg_path := edg_path;

      p1 := Points^[i] + edg;
      p2 := Points^[i] - edg;
 

      Shape.AddVertex(p1);
      Shape.AddVertex(p2);

      Shape.Indexes.Add(Shape.CountVertex - 2);
      Shape.Indexes.Add(Shape.CountVertex - 1);

      Box3CheckBB(Shape.FBoundingBox, p1);
      Box3CheckBB(Shape.FBoundingBox, p2);
      a_befor := a;
    end;
  end;

  if Closed then
  begin
    Shape.Indexes.Add(0);
    if not IsLines then
      Shape.Indexes.Add(1);
  end;

  Result := (Shape.FBoundingBox.Max + Shape.FBoundingBox.Min)*0.5;
  if CalcBB then
    Shape.CalcBoundingBox(true);
end;

function GenerateLine2d(Shape: TMesh; const Point1, Point2: TVec3f; VerticalWidth: BSFloat; CalcBB: boolean; AsStrip: boolean): TVec3f;
const
  eps = EPSILON * 10;
var
  a, a_befor, d, s, c: BSFloat;
  edg: TVec3f;
  edg_path: TVec3f;
  p1, p2: TVec3f;
  crs: TVec3f;
  crs_befor: BSFloat;
begin

  //Shape.FBoundingBox.Max := Point1;
  //Shape.FBoundingBox.Min := Point1;
  edg_path := Point2 - Point1;
  crs_befor := 1.0;
  a_befor := - VecDecisionX(edg_path);
  a := a_befor;

  d := VerticalWidth*0.5;

  BS_SinCos(abs(a + a_befor)*0.5 - 90, s, c);
  edg := vec3( d*c, d*s, 0.0);

  crs := VecCross(edg_path, edg_path + edg);
  if crs.z < -eps then
    crs.z := -1
  else
    crs.z := 1;

  if (crs.z = crs_befor) then
  begin
    crs.z := -crs.z;
    edg.x := -edg.x;
    edg.y := -edg.y;
  end;

  p1 := Point1 + edg;
  p2 := Point1 - edg;


  Shape.AddVertex(p1);
  Shape.AddVertex(p2);

  Shape.FBoundingBox.Min := p1;
  Shape.FBoundingBox.Max := p1;
  Box3CheckBB(Shape.FBoundingBox, p2);

  p1 := Point2 + edg;
  p2 := Point2 - edg;


  Shape.AddVertex(p1);
  Shape.AddVertex(p2);

  Box3CheckBB(Shape.FBoundingBox, p1);
  Box3CheckBB(Shape.FBoundingBox, p2);

  if AsStrip then
  begin
    Shape.TypePrimitive := tpTriangleStrip;
    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
  end else
  begin
    Shape.TypePrimitive := tpTriangles;
    Shape.Indexes.Add(Shape.CountVertex-4);
    Shape.Indexes.Add(Shape.CountVertex-3);
    Shape.Indexes.Add(Shape.CountVertex-2);
    Shape.Indexes.Add(Shape.CountVertex-2);
    Shape.Indexes.Add(Shape.CountVertex-3);
    Shape.Indexes.Add(Shape.CountVertex-1);
  end;

  Result := (Shape.FBoundingBox.Max + Shape.FBoundingBox.Min)*0.5;
  if CalcBB then
    Shape.CalcBoundingBox(true);
end;

function GenerateClosedShape(Shape: TMesh; Points: PArrayVec3f; Count: int32): TVec3f;
var
  i: int32;
begin
  if Count < 2 then
    exit(vec3(0.0, 0.0, 0.0));
  Shape.FBoundingBox.Max := Points^[0];
  Shape.FBoundingBox.Min := Points^[0];
  Shape.TypePrimitive := tpTriangleFan;
  Shape.AddVertex(Vec3(0.0, 0.0, 0.0));
  Shape.Indexes.Add(0);
  for i := 0 to Count - 1 do
  begin
    Box3CheckBB(Shape.FBoundingBox, Points[i]);
    Shape.AddVertex(Points[i]);
    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;
  Result := (Shape.FBoundingBox.Max + Shape.FBoundingBox.Min)*0.5;
  Shape.WritePoint(0, Result);
  Shape.AddVertex(Points[0]);
  Shape.Indexes.Add(Shape.Indexes.Count);
  Shape.CalcBoundingBox(true);
end;

procedure GenerateImage(Shape: TMesh;
  const Size: TVec2f; const TexRect: TRectBSf);
begin
  TBlackSharkFactoryShapesP.GeneratePlane(Shape, Size);
  Shape.Write(0, TVertexComponent.vcTexture1, vec2(TexRect.Left, TexRect.Top + TexRect.Height));
  Shape.Write(1, TVertexComponent.vcTexture1, TexRect.Position);
  Shape.Write(2, TVertexComponent.vcTexture1, vec2(TexRect.Left + TexRect.Width, TexRect.Top));
  Shape.Write(3, TVertexComponent.vcTexture1, vec2(TexRect.Left + TexRect.Width, TexRect.Top + TexRect.Height));
end;

procedure ConvertToLines(SourceShape,
  DestinationShape: TMesh);
type
  TEdge = record
    case boolean of
    true:
    (index1: int32;
      index2: int32);
    false: (indexes: array[0..1] of int32);
  end;

var
  edges: TBinTree<int32>;
  val: int32;

  procedure AddEdg(const edg: TEdge);
  var
    edge_inv: TEdge;
  begin
  edge_inv.index1 := edg.index2;
  edge_inv.index2 := edg.index1;
  if edges.Find(@edg, SizeOf(TEdge), val) then
    begin
    edges.Remove(@edg, SizeOf(TEdge));
    edges.Remove(@edge_inv, SizeOf(TEdge));
    exit;
    end;
  edges.Add(@edg, SizeOf(TEdge), edg.index1+1);
  edges.Add(@edge_inv, SizeOf(TEdge), edg.index2+1);
  end;

  procedure AddVrtex(const edg: TEdge);
  begin
  DestinationShape.Indexes.Add(DestinationShape.CountVertex);
  DestinationShape.AddVertex(SourceShape.ReadPoint(edg.index1));
  DestinationShape.Indexes.Add(DestinationShape.CountVertex);
  DestinationShape.AddVertex(SourceShape.ReadPoint(edg.index2));
  end;

var
  i,k: int32;
  n: byte;
  edge: TEdge;
begin
  edges := TBinTree<int32>.Create;
  if SourceShape.DrawingPrimitive = GL_TRIANGLES then
    begin
    for i := 0 to SourceShape.Indexes.Count div 3 - 1 do
      begin
      k := i*3;
      edge.index1 := SourceShape.Indexes.Items[k];
      edge.index2 := SourceShape.Indexes.Items[k+1];
      AddEdg(edge);
      edge.index1 := edge.index2;
      edge.index2 := SourceShape.Indexes.Items[k+2];
      AddEdg(edge);
      edge.index1 := edge.index2;
      edge.index2 := SourceShape.Indexes.Items[k];
      AddEdg(edge);
      end;
    n := 0;
    for i := 0 to SourceShape.Indexes.Count - 1 do
      begin
      edge.indexes[n] := SourceShape.Indexes.Items[i];
      if n = 1 then
        begin
        if edges.Find(@edge, SizeOf(TEdge), val) then
          begin
          DestinationShape.Indexes.Add(DestinationShape.CountVertex);
          DestinationShape.AddVertex(SourceShape.ReadPoint(edge.index1));
          DestinationShape.Indexes.Add(DestinationShape.CountVertex);
          DestinationShape.AddVertex(SourceShape.ReadPoint(edge.index2));
          edge.index1 := edge.index2;
          n := 1;
          end else
          continue;
        end else
        inc(n);
      end;
    end else
  if SourceShape.DrawingPrimitive = GL_TRIANGLE_STRIP then
    begin
    edge.index1 := SourceShape.Indexes.Items[0];
    edge.index2 := SourceShape.Indexes.Items[1];
    AddVrtex(edge);
    edge.index1 := SourceShape.Indexes.Items[2];
    edge.index2 := SourceShape.Indexes.Items[0];
    AddVrtex(edge);
    for i := 1 to SourceShape.Indexes.Count - 3 do
      begin
      edge.index1 := SourceShape.Indexes.Items[i];
      edge.index2 := SourceShape.Indexes.Items[i+2];
      AddVrtex(edge);
      end;
    edge.index1 := SourceShape.Indexes.Items[SourceShape.Indexes.Count - 2];
    edge.index2 := SourceShape.Indexes.Items[SourceShape.Indexes.Count - 1];
    AddVrtex(edge);
    end else
  if SourceShape.DrawingPrimitive = GL_TRIANGLE_FAN then
    begin
    for i := 1 to SourceShape.Indexes.Count - 2 do
      begin
      edge.index1 := SourceShape.Indexes.Items[i];
      edge.index2 := SourceShape.Indexes.Items[i+1];
      AddVrtex(edge);
      end;
    if SourceShape.Indexes.Items[1] <> SourceShape.Indexes.Items[SourceShape.Indexes.Count - 1] then
      begin
      edge.index1 := SourceShape.Indexes.Items[0];
      edge.index2 := SourceShape.Indexes.Items[1];
      AddVrtex(edge);
      edge.index1 := SourceShape.Indexes.Items[0];
      edge.index2 := SourceShape.Indexes.Items[SourceShape.Indexes.Count - 1];
      AddVrtex(edge);
      end;

    end;
  edges.Free;
  DestinationShape.CalcBoundingBox(true);
end;

type
  TEdge = record
    normal: TVec3f;
    case int8 of
    0:
    (index1: int32;
      index2: int32);
    1: (indexes: array[0..1] of int32);
    2: (key: int64);
  end;

procedure CreateBorder(SourceShape,
  DestinationShape: TMesh; Width: BSFloat; Closed: boolean = true);

var
  edges: TBinTree<TEdge>;
  edges_index: TBinTree<TEdge>;
  path: TListVec3f;
  val: TEdge;
  edge, edge2: TEdge;
  n, v1, v2, v3: TVec3f;
  k, i: int32;
  ok: boolean;

  procedure AddEdg(const edg: TEdge);
  var
    edge_inv: TEdge;
  begin
  edge_inv.index1 := edg.index2;
  edge_inv.index2 := edg.index1;
  edge_inv.normal := edg.normal;
  if (edges.Find(@edg, SizeOf(TEdge), val)) or (edges.Find(@edge_inv, SizeOf(TEdge), val)) then
    exit;
  edges.Add(@edg, SizeOf(TEdge), edg);
  edges_index.Add(edg.index1, edg);
  edges_index.Add(edg.index2, edg);
  end;

begin
  edges := TBinTree<TEdge>.Create;
  edges_index := TBinTree<TEdge>.Create(nil);
  path := TListVec3f.Create;
  if SourceShape.DrawingPrimitive = GL_TRIANGLES then
  begin
    for i := 0 to SourceShape.Indexes.Count div 3 - 1 do
    begin
      k := i*3;
      v1 := SourceShape.ReadPoint(k);
      v2 := SourceShape.ReadPoint(k+1);
      v3 := SourceShape.ReadPoint(k+2);
      n := VecNormalize(VecCross(v2-v1, v3-v1));
      n.x := abs(n.x);
      n.y := abs(n.y);
      n.z := abs(n.z);
      edge.normal := n;
      edge.index1 := SourceShape.Indexes.Items[k];
      edge.index2 := SourceShape.Indexes.Items[k+1];
      AddEdg(edge);
      edge.index1 := edge.index2;
      edge.index2 := SourceShape.Indexes.Items[k+2];
      AddEdg(edge);
      edge.index1 := edge.index2;
      edge.index2 := SourceShape.Indexes.Items[k];
      AddEdg(edge);
    end;

    edge := edges.Root.Value;
    edges.Remove(@edges, SizeOf(TEdge));
    while edges.Count > 0 do
    begin
      ok := false;
      while edges_index.Find(edge.index2, edge2) do
      begin
        edges_index.Remove(edge.index2);
        if (edge2.index1 = edge.index1) and (edge2.index2 = edge.index1) then
          continue else
        begin
          ok := true;
          break;
        end;
      end;
      if not ok then
      begin
        while edges_index.Find(edge.index1, edge2) do
        begin
          edges_index.Remove(edge.index1);
          if (edge2.index1 = edge.index1) and (edge2.index2 = edge.index1) then
            continue else
          begin
            ok := true;
            break;
          end;
        end;
      end;
      path.Add(SourceShape.ReadPoint(edge.index1));
      path.Add(SourceShape.ReadPoint(edge.index2));
      edges.Remove(@edges, SizeOf(TEdge));
      if not ok then
      begin
        GeneratePath2d(DestinationShape, path.ShiftData[0], path.Count, Width, Closed, true);
        path.Count := 0;
        edge := edges.Root.Value;
      end else
      begin
        edge := edge2;
      end;
    end;
  end else
  if SourceShape.DrawingPrimitive = GL_TRIANGLE_STRIP then
  begin
    i := SourceShape.Indexes.Count - 1;
    while i > 0 do
    begin
      path.Add(SourceShape.ReadPoint(i));
      dec(i, 2);
    end;
    i := 0;
    while i < SourceShape.Indexes.Count - 1 do
    begin
      path.Add(SourceShape.ReadPoint(i));
      inc(i, 2);
    end;
    GeneratePath2d(DestinationShape, path.ShiftData[0], path.Count, Width, Closed, true);
  end else
  if SourceShape.DrawingPrimitive = GL_TRIANGLE_FAN then
  begin
    for i := 1 to SourceShape.Indexes.Count - 1 do
      path.Add(SourceShape.ReadPoint(i));
    path.Add(SourceShape.ReadPoint(1));
    GeneratePath2d(DestinationShape, path.ShiftData[0], path.Count, Width, Closed);
  end;
  path.Free;
  edges.Free;
  edges_index.Free;
  //DestinationShape.CalcBoundingBox(true);
end;

class procedure TBlackSharkFactoryShapesP.GenerateArrow2d(
  Shape: TMesh; ALength, Width, LenTip, WidthTip: BSFloat);
var
  half_len, half_w: BSFloat;
  i: int8;
begin
  //w_arrow := Width*3;
  half_len := ALength/2;
  half_w := Width / 2;
  //h_arrow := w_arrow*2;
  //border := (WidthTip - Width) / 2;
  Shape.TypePrimitive := tpTriangles;
  // two triangles
  // 1:
  Shape.AddVertex(vec3(-half_w, -half_len, 0));
  Shape.AddVertex(vec3( half_w, -half_len, 0));
  Shape.AddVertex(vec3(-half_w, half_len-LenTip, 0));
  // 2:
  Shape.AddVertex(vec3(-half_w, half_len-LenTip, 0));
  Shape.AddVertex(vec3( half_w, half_len-LenTip, 0));
  Shape.AddVertex(vec3( half_w, -half_len, 0));
  // arrow
  Shape.AddVertex(vec3(-WidthTip/2, half_len-LenTip, 0));
  Shape.AddVertex(vec3( 0.0, half_len, 0));
  Shape.AddVertex(vec3( WidthTip/2, half_len-LenTip, 0));

  for i := 0 to 8 do
    Shape.Indexes.Add(i);

  Shape.CalcBoundingBox;
end;

procedure GenerateArrow2d(Shape: TMesh; ALength, Width: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateArrow2d(Shape, ALength, Width, Width*6, Width*2);
end;

procedure GenerateBezierCubic(const P0, P1, P2, P3: TVec3f; var OutSplineVertexes:
  TListVec3f; STEP: BSFloat = 0.2);
var
  t, t1: BSFloat;
  v: TVec3f;
begin
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec3f.Create;
  // cubic spline:
  // B(t) = (1-t)^3*P0 + 3t(1-t)^2*P1 + 3t^2(1-t)P2 + t^3*P3

  t := STEP;
  OutSplineVertexes.Add(P0);
  while t < 1 do
  begin
    t1 := 1 - t;
    v :=
      P0*(t1*t1*t1) +
      P1*(3*t*t1*t1) +
      P2*(3*t*t*t1) +
      P3*(t*t*t);
    OutSplineVertexes.Add(v);
    t := t + STEP;
  end;
  if t >= 1 then
    OutSplineVertexes.Add(P3);
end;

procedure GenerateBezierLinear(const P0, P1: TVec3f; var OutSplineVertexes: TListVec3f;
  STEP: BSFloat);
var
  t: BSFloat;
  v, delta: TVec3f;
begin
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec3f.Create;
  // linear spline:
  // B(t) = P0 + t(P1-P0)
  delta := P1 - P0;
  t := STEP;
  OutSplineVertexes.Add(P0);
  while t < 1 do
  begin
    v := P0 + delta*t;
    OutSplineVertexes.Add(v);
    t :=  t + STEP;
  end;
  if t >= 1 then
    OutSplineVertexes.Add(P1);
end;

procedure GenerateBezierQuadratic(const P0, P1, P2: TVec3f; var OutSplineVertexes: TListVec3f; STEP: BSFloat);
var
  t, t1: BSFloat;
  v: TVec3f;
begin
  // quadratic spline:
  // B(t) = (1-t)^2*P0 + 2t(1-t)*P1 + t^2*P2
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec3f.Create;
  t := STEP;
  OutSplineVertexes.Add(P0);
  while t < 1 do
  begin
    t1 := 1 - t;
    v :=
      P0*(t1*t1) +
      P1*(2*t*t1) +
      P2*(t*t);
    OutSplineVertexes.Add(v);
    t := t + STEP;
  end;
  if t >= 1 then
    OutSplineVertexes.Add(P2);
end;

procedure GenerateCubicSpline(InBaseVertexes: PArrayVec3f; CountBaseVertexes: int32; var OutSplineVertexes: TListVec3f; SmoothingFactor: BSFloat);
type
  TPointTuple = record
    a, b, c, d, x: bsfloat;
  end;
var
  splines: array of TPointTuple;
  real_count: int32;
  min_x, max_x: bsfloat;
  i: int32;
  alpha, beta: array of bsfloat;
  hi, hi1, A, B, C, F, z: bsfloat;
  dx: bsfloat;
  step: bsfloat;
  pos, arg_y: bsfloat;
begin
  if CountBaseVertexes = 0 then
    exit;
  // building spline:
  // x - arguments, must be ordered from low to high, repeates exclude
  // y - value of the function in arguments
  // CountBaseVertexes - count arguments

  splines := nil;
  // initialize
  SetLength(splines, CountBaseVertexes);
  real_count := 0;
  min_x := InBaseVertexes^[0].x;
  max_x := InBaseVertexes^[0].x;
  for i := 0 to CountBaseVertexes - 1 do
  begin
    if real_count > 0 then
      if splines[real_count].x = InBaseVertexes^[i].x then
        continue;
    splines[real_count].x := InBaseVertexes^[i].x;
    splines[real_count].a := InBaseVertexes^[i].y;
    if min_x > splines[real_count].x then
      min_x := splines[real_count].x;
    if max_x < splines[real_count].x then
      max_x := splines[real_count].x;
    inc(real_count);
  end;

  if (real_count = 0) then
    exit;

  splines[0].c := 0.0; splines[real_count - 1].c := 0.0;

  // To decision system of linear equations relative factors splines c[i]
  // by tridiagonal matrix

  // calc factors - direct path
  alpha := nil;
  beta := nil;
  SetLength( alpha, real_count - 1 );
  SetLength( beta, real_count - 1 );
  alpha[0] := 0.0; beta[0] := 0.0;
  for i := 1 to real_count - 2 do
  begin
    hi  := InBaseVertexes^[i].x - InBaseVertexes^[i - 1].x;
    hi1 := InBaseVertexes^[i + 1].x - InBaseVertexes^[i].x;
    A := hi;
    C := 2.0 * (hi + hi1);
    B := hi1;
    F := 6.0 * ((InBaseVertexes^[i + 1].y - InBaseVertexes^[i].y) / hi1 - (InBaseVertexes^[i].y - InBaseVertexes^[i - 1].y) / hi);
    z := (A * alpha[i - 1] + C);
    alpha[i] := -B / z;
    beta[i] := (F - A * beta[i - 1]) / z;
  end;

  // To found decision - back path
  for i := real_count - 2 downto 1 do
    splines[i].c := alpha[i] * splines[i + 1].c + beta[i];

  // by help c[i] found b[i] è d[i]
  for i := real_count - 1 downto 1 do
  begin
    hi := InBaseVertexes^[i].x - InBaseVertexes^[i - 1].x;
    splines[i].d := (splines[i].c - splines[i - 1].c) / hi;
    splines[i].b := hi * (2.0 * splines[i].c + splines[i - 1].c) / 6.0 + (InBaseVertexes^[i].y - InBaseVertexes^[i - 1].y) / hi;
  end;
  SetLength( alpha, 0 );
  SetLength( beta, 0 );

  // calc function values
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec<TVec3f>.Create;
  for i := 0 to real_count - 2 do
  begin
    pos := splines[i].x;
    step := (splines[i+1].x - splines[i].x) * SmoothingFactor;
    while pos <= splines[i + 1].x do
    begin
      dx := pos - splines[i + 1].x;
      // calc value by the Horner scheme
      arg_y := splines[i + 1].a + (splines[i + 1].b + (splines[i + 1].c / 2.0 + splines[i + 1].d * dx / 6.0) * dx) * dx;
      OutSplineVertexes.Add(vec3(pos, arg_y, 0.0));
      pos := pos + step;
    end;
  end;
  SetLength(splines, 0);
end;

procedure GenerateCubicHermiteSpline(InBaseVertexes: PArrayVec3f; CountBaseVertexes: int32;
  var OutSplineVertexes: TListVec3f; SmoothingFactor: BSFloat; Closed: boolean);
const
  TENSION = 0.5;
var
  tmp_values: TListVec<TVec3f>;
  ptr: PVec3f;
  i: int32;
  x, y: bsfloat;			// our x,y coords
  t1x, t2x, t1y, t2y: bsfloat;	// tension vectors
  c1, c2, c3, c4: bsfloat;		  // cardinal points
  st, st2, st3: bsfloat;		    // steps based on num. of segments
begin
  tmp_values := TListVec<TVec3f>.Create;
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec<TVec3f>.Create;
  // clone array so we don't change the original
  //

  // The algorithm require a previous and next point to the actual point array.
  // Check if we will draw closed or open curve.
  // If closed, copy end points to beginning and first points to end
  // If open, duplicate first points to befinning, end points to end
  if (Closed) then
  begin
    tmp_values.Count := CountBaseVertexes + 3;
    ptr := tmp_values.ShiftData[2];
    Move(InBaseVertexes^[0], ptr^, CountBaseVertexes*SizeOf(TVec3f));
    tmp_values.Items[0] := InBaseVertexes^[CountBaseVertexes - 1];
    tmp_values.Items[1] := InBaseVertexes^[CountBaseVertexes - 1];
    tmp_values.Items[tmp_values.Count - 1] := InBaseVertexes^[0];
  end else
  begin
    tmp_values.Count := CountBaseVertexes + 2;
    ptr := tmp_values.ShiftData[1];
    Move(InBaseVertexes^[0], ptr^, CountBaseVertexes*SizeOf(TVec3f));
    tmp_values.Items[0] := InBaseVertexes^[0];
    tmp_values.Items[tmp_values.Count - 1] := InBaseVertexes^[CountBaseVertexes - 1];
  end;

  // ok, lets start..

  // 1. loop goes through point array
  // 2. loop goes through each segment between the 2 pts + 1e point before and after
  for i := 1 to tmp_values.Count - 3 do
  begin
    st := 0;
    while st < 1 do
    begin
      // calc tension vectors
      t1x := (tmp_values.Items[i+1].x - tmp_values.Items[i-1].x) * tension;
      t2x := (tmp_values.Items[i+2].x - tmp_values.Items[i].x) * tension;

      t1y := (tmp_values.Items[i+1].y - tmp_values.Items[i-1].y) * tension;
      t2y := (tmp_values.Items[i+2].y - tmp_values.Items[i].y) * tension;

      st2 := st * st;
      st3 := st2 * st;
      // calc cardinals
      c1 :=   2 * st3  - 3 * st2 + 1;
      c2 := -(2 * st3) + 3 * st2;
      c3 := 	st3	- 2 * st2 + st;
      c4 := 	st3	- st2;

      st := st + SmoothingFactor;
      if st > 1.0 then
       st := 1.0;

      // calc x and y cords with common control vectors
      x := c1 * tmp_values.Items[i].x	+ c2 * tmp_values.Items[i+1].x + c3 * t1x + c4 * t2x;
      y := c1 * tmp_values.Items[i].y	+ c2 * tmp_values.Items[i+1].y + c3 * t1y + c4 * t2y;

      //store points in array
      OutSplineVertexes.Add(vec3(x, y, 0.0));
    end;
  end;
  tmp_values.Free;
end;

procedure GenerateBezierSpline(InBaseVertexes: PArrayVec3f; CountVertexes: int32; var OutSplineVertexes: TListVec3f; STEP: BSFloat);
var
  c: int8;
  i: int32;
  v4: array[0..3] of TVec3f;
begin
  c := 0;
  if OutSplineVertexes = nil then
    OutSplineVertexes := TListVec3f.Create;
  for i := 0 to CountVertexes - 1 do
  begin
    v4[c] := InBaseVertexes^[i];
    inc(c);
    if c = 3 then
    begin
      if i + 2 = CountVertexes then
        continue;
      GenerateBezierQuadratic(v4[0], v4[1], v4[2], OutSplineVertexes, STEP);
      c := 1;
      v4[0] := v4[2];
    end else
    if c = 4 then
    begin
      GenerateBezierCubic(v4[0], v4[1], v4[2], v4[3], OutSplineVertexes, STEP);
      c := 1;
      v4[0] := v4[3];
    end;
  end;
end;

{ TBlackSharkFactoryShapesP }

class function TBlackSharkFactoryShapesP.CreateShape: TMesh;
begin
  Result := TMeshP.Create;
end;

class function TBlackSharkFactoryShapesP.GenerateAngleArc(Shape: TMesh; NumSlices: int32; Radius, StartAngle, Angle: BSFloat): TVec3f;
var
  j: int32;
  angleStep, c, s: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleFan;
  angleStep := Angle / numSlices;
  Shape.AddVertex(vec3(0.0, 0.0, 0.0));
  Shape.Indexes.Add(0);
  for j := 0 to NumSlices do
  begin
    BS_SinCos(StartAngle + angleStep * j, s, c);
    v := Vec3(
      Radius * c,
      Radius * s,
      0
    );
    Shape.AddVertex(v);
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;
  Result := -Shape.CalcBoundingBox(true);
end;

class function TBlackSharkFactoryShapesP.GenerateAngleArc(Shape: TMesh; NumSlices: int32; Radius, StartAngle, Angle, WidthLine: BSFloat): TVec3f;
var
  j: int32;
  angleStep, s, c, r2: BSFloat;
  v: TVec3f;
  //bb: TBox3f;
begin
  angleStep := Angle / numSlices;
  Shape.TypePrimitive := tpTriangleStrip;
  r2 := Radius - WidthLine;
  //bb.Min := vec3(0.0, 0.0, 0.0);
  //bb.Max := vec3(0.0, 0.0, 0.0);
  for j := 0 to NumSlices do
  begin
    BS_SinCos(StartAngle + angleStep * j, s, c);
    v := vec3(
      Radius * c,
      Radius * s,
      0
    );
    //Box3CheckBB(bb, v);
    Shape.AddVertex(v);
    v := vec3(
      r2 * c,
      r2 * s,
      0
    );
    Shape.AddVertex(v);
    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;

  //bb.Middle := Box3Middle(bb);
  Result := -Shape.CalcBoundingBox(true);
end;

class procedure TBlackSharkFactoryShapesP.GenerateBezierCubic(Shape: TMesh; const P0, P1, P2, P3: TVec3f; AWidth, STEP: BSFloat; CalcBB: boolean);
var
  Vertexes: TListVec3f;
begin
  Vertexes := nil;
  bs.mesh.primitives.GenerateBezierCubic(P0, P1, P2, P3, Vertexes, STEP);
  bs.mesh.primitives.GeneratePath2d(Shape, Vertexes.ShiftData[0], Vertexes.Count, AWidth, false, CalcBB, AWidth = 1.0);
  Vertexes.Free;
end;

class procedure TBlackSharkFactoryShapesP.GenerateBezierLinear(Shape: TMesh; const P0, P1: TVec3f; AWidth, STEP: BSFloat; CalcBB: boolean);
var
  Vertexes: TListVec3f;
begin
  Vertexes := nil;
  bs.mesh.primitives.GenerateBezierLinear(P0, P1, Vertexes, STEP);
  GeneratePath2d(Shape, Vertexes.ShiftData[0], Vertexes.Count, AWidth, false, CalcBB, AWidth = 1.0);
  Vertexes.Free;
end;

class procedure TBlackSharkFactoryShapesP.GenerateBezierQuadratic(Shape: TMesh; const P0, P1, P2: TVec3f; AWidth, STEP: BSFloat; CalcBB: boolean);
var
  Vertexes: TListVec3f;
begin
  Vertexes := nil;
  bs.mesh.primitives.GenerateBezierQuadratic(P0, P1, P2, Vertexes, STEP);
  GeneratePath2d(Shape, Vertexes.ShiftData[0], Vertexes.Count, AWidth, false, CalcBB, AWidth = 1.0);
  Vertexes.Free;
end;

class procedure TBlackSharkFactoryShapesP.GenerateCircle(Shape: TMesh; NumSlices: int32; Radius: BSFloat);
var
  j: int32;
  angleStep, c, s: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleFan;
  angleStep := 360 / numSlices;
  Shape.AddVertex(Vec3(0.0, 0.0, 0.0));
  Shape.Indexes.Add(0);
  for j := 0 to NumSlices do
  begin
    BS_SinCos(angleStep * j, s, c);
    v := Vec3(
      Radius * c,
      Radius * s,
      0
    );
    Shape.AddVertex(v);
    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateCircle(Shape: TMesh; WidthLine: BSFloat; NumSlices: int32;
  Radius: BSFloat);
var
  j: int32;
  angleStep, s, c, r2: BSFloat;
  v: TVec3f;
begin
  angleStep := 360 / numSlices;
  //Result.FVertexes.Add(Vec3(0.0, 0.0, 0.0));
  //Result.FUVCoords.Add(Vec2(0.5, 0.5));
  Shape.TypePrimitive := tpTriangleStrip;
  r2 := Radius-WidthLine;
  for j := 0 to NumSlices do
  begin
    BS_SinCos(angleStep * j, s, c);
    v := Vec3(
      Radius * c,
      Radius * s,
      0
    );
    Shape.AddVertex(v);
    //Result.Normals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    v := Vec3(
      r2 * c,
      r2 * s,
      0
    );
    Shape.AddVertex(v);

    //Shape.Normals.Add(Vec3(v.x / r2, v.y / r2, v.z / r2));

    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateCone(Shape: TMesh; NumSlices: int32; Radius, Height: BSFloat; TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  h_half    := Height * 0.5;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.AddVertex(v0_top);
  Shape.AddVertex(v0_bottom);
  for j := 0 to NumSlices + 1 do
  begin
    v1 := Vec3(
      radius * BS_Sin ( angleStep * j ),
      -h_half,
      radius * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      0,
      h_half,
      0
    );

    Shape.AddVertex(v1);
    Shape.AddVertex(v2);

    //Shape.FNormals.Add(Vec3(v1.x / Radius, v1.y / Radius, v1.z / Radius));
    //Shape.FNormals.Add(Vec3(v2.x / Radius, v2.y / Radius, v2.z / Radius));
  end;

  for j := 0 to NumSlices - 1 do
  begin
    Shape.Indexes.Add(j*2+2);
    Shape.Indexes.Add(j*2+3);
    Shape.Indexes.Add(j*2+4);
  end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
    begin
      Shape.Indexes.Add(j*2+2);
      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(1);
    end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateCube(Shape: TMesh; const Size: TVec3f);
var
  s_half: TVec3f;
  i: int32;
begin
  Shape.TypePrimitive := tpTriangles;
  s_half := Size * 0.5;
  // set Cube to center
  // face
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y, s_half.z));
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y, s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y, s_half.z));
  Shape.AddVertex(Vec3( s_half.x, -s_half.y, s_half.z));
  // left
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y, s_half.z));
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y, s_half.z));
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y, -s_half.z));
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y, -s_half.z));
  // back
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y, -s_half.z));
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y, -s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y, -s_half.z));
  Shape.AddVertex(Vec3( s_half.x, -s_half.y, -s_half.z));
  // right
  Shape.AddVertex(Vec3( s_half.x, -s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y, -s_half.z));
  Shape.AddVertex(Vec3( s_half.x, -s_half.y, -s_half.z));
  // top
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y, -s_half.z));
  Shape.AddVertex(Vec3(-s_half.x,  s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x,  s_half.y, -s_half.z));
  // bottom
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y, -s_half.z));
  Shape.AddVertex(Vec3(-s_half.x, -s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x, -s_half.y,  s_half.z));
  Shape.AddVertex(Vec3( s_half.x, -s_half.y, -s_half.z));

  // (two triangles for evry side = 6 indexes) * 6 sides
  Shape.Indexes.Capacity := 36;
  for i := 0 to 5 do
  begin
    Shape.Indexes.Add(i*4);
    Shape.Indexes.Add(i*4+1);
    Shape.Indexes.Add(i*4+2);
    Shape.Indexes.Add(i*4);
    Shape.Indexes.Add(i*4+2);
    Shape.Indexes.Add(i*4+3);
  end;

  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateCylinder(Shape: TMesh; Radius: BSFloat; NumSlices: int32; Height: BSFloat;
  TextureTop, TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  //FRoot.UpdateBegin;
  h_half    := Height * 0.5;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.AddVertex(v0_top);
  Shape.AddVertex(v0_bottom);
  for j := 0 to NumSlices + 1 do
  begin
    v1 := Vec3(
      radius * BS_Sin ( angleStep * j ),
      h_half,
      radius * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      v1.x,
      -h_half,
      v1.z
    );

    Shape.AddVertex(v1);
    Shape.AddVertex(v2);

    // Shape.FNormals.Add(Vec3(v1.x / Radius, v1.y / Radius, v1.z / Radius));
    // Shape.FNormals.Add(Vec3(v2.x / Radius, v2.y / Radius, v2.z / Radius));

    if TextureTop and (j < NumSlices) then
    begin
      Shape.Indexes.Add(j*2+2);
      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(0);
    end;
  end;

  for j := 0 to NumSlices do
  begin
    Shape.Indexes.Add(j*2+2);
    Shape.Indexes.Add(j*2+3);

    if j <> NumSlices then
    begin
      Shape.Indexes.Add(j*2+4);

      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
    end else
    begin
      Shape.Indexes.Add(2);

      Shape.Indexes.Add(2);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(3);
    end;
  end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
    begin
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
      Shape.Indexes.Add(1);
    end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateEllipse(Shape: TMesh; NumSlices: int32; a, b: BSFloat);
var
  j: int32;
  angleStep: BSFloat;
  v: TVec3f;
  //v2: TVec2f;
begin
  { TODO: GL_TRIANGLE_FAN }
  angleStep := 360 / NumSlices;
  Shape.AddVertex(vec3(0.0, 0.0, 0.0));
  for j := 0 to NumSlices do
  begin
    v := Vec3(
      a * BS_Cos ( angleStep * j ),
      b * BS_Sin ( angleStep * j ),
      0
    );
    //v2 := Vec2((a + v.x) / (a*2),  0.5 - BS_Sin ( angleStep * j ) * 0.5);
    Shape.AddVertex(v);

    //Shape.Normals.Add(Vec3(v.x / a, v.y / b, 0));

    Shape.Indexes.Add(j);
    if j = NumSlices then
      Shape.Indexes.Add(1)
    else
      Shape.Indexes.Add(j+1);

    Shape.Indexes.Add(0);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateGrid(Shape: TMesh;
  const Size: TVec2f; StepX, StepY: BSFloat; HorizontalLines, VerticalLines, Closed,
  Triangles: boolean; Width: BSFloat);
var
  zx, mid_h, mid_w: BSFloat;
  aligned_size: TVec2f;
  cx, cy, i: int32;
  cv: int32;
  a: BSFloat;
  w_half: BSFloat;
  //path: TListVec3f;
begin
  a := Size.x / StepX;
  cx := round(a);
  if a - cx > 0.001 then
    inc(cx);
  aligned_size.x := (cx * StepX);
  a := Size.y / StepY;
  cy := round(a);
  if a - cy > 0.001 then
    inc(cy);
  aligned_size.y := (cy * StepY);
  mid_h := aligned_size.y * 0.5;
  mid_w := aligned_size.x * 0.5;
  w_half := Width * 0.5;
  if Triangles then
    Shape.TypePrimitive := tpTriangles
  else
    Shape.TypePrimitive := tpLines;

  if VerticalLines then
  begin
    if Closed then
      zx := - mid_w
    else
    begin
      zx := - mid_w + StepX;
      dec(cx, 2);
    end;

    for i := 0 to cx do
    begin
      if Triangles then
      begin
        cv := Shape.CountVertex;
        Shape.AddVertex(vec3(zx - w_half,  mid_h, 0));
        Shape.AddVertex(vec3(zx + w_half,  mid_h, 0));
        Shape.AddVertex(vec3(zx - w_half, -mid_h, 0));
        Shape.AddVertex(vec3(zx + w_half, -mid_h, 0));
        Shape.Indexes.Add(cv);
        Shape.Indexes.Add(cv+1);
        Shape.Indexes.Add(cv+2);
        Shape.Indexes.Add(cv+1);
        Shape.Indexes.Add(cv+2);
        Shape.Indexes.Add(cv+3);
      end else
      begin
        Shape.AddVertex(vec3(zx,  mid_h, 0));
        Shape.AddVertex(vec3(zx, -mid_h, 0));
        Shape.Indexes.Add(Shape.Indexes.Count);
        Shape.Indexes.Add(Shape.Indexes.Count);
      end;
      zx := zx + StepX;
    end;
  end;

  if HorizontalLines then
  begin
    if Closed then
      zx := - mid_h
    else
    begin
      zx := - mid_h + StepY;
      dec(cy, 2);
    end;

    for i := 0 to cy do
    begin
      if Triangles then
      begin
        cv := Shape.CountVertex;
        Shape.AddVertex(vec3( mid_w, zx - w_half, 0));
        Shape.AddVertex(vec3( mid_w, zx + w_half, 0));
        Shape.AddVertex(vec3(-mid_w, zx - w_half, 0));
        Shape.AddVertex(vec3(-mid_w, zx + w_half, 0));
        Shape.Indexes.Add(cv);
        Shape.Indexes.Add(cv+1);
        Shape.Indexes.Add(cv+2);
        Shape.Indexes.Add(cv+1);
        Shape.Indexes.Add(cv+2);
        Shape.Indexes.Add(cv+3);
      end else
      begin
        Shape.AddVertex(vec3( mid_w, zx, 0));
        Shape.AddVertex(vec3(-mid_w, zx, 0));
        Shape.Indexes.Add(Shape.Indexes.Count);
        Shape.Indexes.Add(Shape.Indexes.Count);
      end;
      zx := zx + StepY;
    end;
  end;
  Shape.CalcBoundingBox(true);
end;

class procedure TBlackSharkFactoryShapesP.GenerateHalfCircle(Shape: TMesh; NumSlices: int32; Radius: BSFloat);
{var
  j: int32;
  angleStep: BSFloat;
  v: TVec3f;  }
begin
{  angleStep := 180 / numSlices;
  for j := 0 to NumSlices + 1 do
    begin
    v := Vec3(
      Radius * BS_Cos ( angleStep * j ),
      Radius * BS_Sin ( angleStep * j ),
      0
    );

    Shape.AddVertex(v);
    Shape.AddVertex(Vec3(0.0, 0.0, 0.0));

    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));

    if j < NumSlices then
      begin
      Shape.Indexes.Add(j*2);
      Shape.Indexes.Add(j*2+1);
      Shape.Indexes.Add(j*2+2);
      end;
    end;
  Shape.CalcBoundingBox;   }
end;

class procedure TBlackSharkFactoryShapesP.GenerateLine2d(Shape: TMesh; ALength, Width: BSFloat);
const
  NUM_SLICES = 1;
var
  i: int32;
  delta, y, x, half_len: BSFloat;
begin
  Shape.Clear;
  delta := ALength / NUM_SLICES;
  half_len := ALength * 0.5;
  y := -half_len;
  x := Width * 0.5;
  Shape.TypePrimitive := tpTriangleStrip;
  for i := 0 to NUM_SLICES do
  begin
    //v := (ALength-(y+half_len))/ALength;
    Shape.AddVertex(vec3(-x, y, 0));
    Shape.AddVertex(vec3( x, y, 0));
    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
    y := y + delta;
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GeneratePlane(Shape: TMesh; const P1, P2, P3, P4: TVec3f);
begin
  Shape.TypePrimitive := tpTriangleStrip;
  Shape.FBoundingBox.Max := vec3(bs.math.Max(bs.math.Max(bs.math.Max(P1.x, P2.x), P3.x), P4.x),
    bs.math.Max(bs.math.Max(bs.math.Max(P1.y, P2.y), P3.y), P4.y), bs.math.Max(bs.math.Max(bs.math.Max(P1.z, P2.z), P3.z), P4.z));
  Shape.FBoundingBox.Min := vec3(bs.math.Min(bs.math.Min(bs.math.Min(P1.x, P2.x), P3.x), P4.x),
    bs.math.Min(bs.math.Min(bs.math.Min(P1.y, P2.y), P3.y), P4.y), bs.math.Min(bs.math.Min(bs.math.Min(P1.z, P2.z), P3.z), P4.z));
  Shape.FBoundingBox.Middle := (Shape.FBoundingBox.Min + Shape.FBoundingBox.Max)*0.5;
  Shape.FBoundingBox.IsPoint := Shape.FBoundingBox.Min = Shape.FBoundingBox.Max;
  // set Image to center
  // face
  Shape.AddVertex(P1);
  Shape.AddVertex(P2);
  Shape.AddVertex(P3);
  Shape.AddVertex(P4);
  // face
  Shape.Indexes.Add(0);
  Shape.Indexes.Add(1);
  Shape.Indexes.Add(2);
  Shape.Indexes.Add(3);
end;

class procedure TBlackSharkFactoryShapesP.GeneratePlane(Shape: TMesh; const SizePlane: TVec2f);
var
  s_half: TVec2f;
begin
  Shape.TypePrimitive := tpTriangleStrip;
  s_half.x := SizePlane.x * 0.5;
  s_half.y := SizePlane.y * 0.5;
  // set Image to center
  // face
  Shape.AddVertex(vec3(-s_half.x,  s_half.y, 0));
  Shape.AddVertex(vec3(-s_half.x, -s_half.y, 0));
  Shape.AddVertex(vec3( s_half.x,  s_half.y, 0));
  Shape.AddVertex(vec3( s_half.x, -s_half.y, 0));
  // face
  Shape.Indexes.Add(0);
  Shape.Indexes.Add(1);
  Shape.Indexes.Add(2);
  Shape.Indexes.Add(3);
  Shape.FBoundingBox.Max := vec3( s_half.x,   s_half.y, 0);
  Shape.FBoundingBox.Min := vec3(-s_half.x,  -s_half.y, 0);
  Shape.FBoundingBox.Middle := vec3(0.0, 0.0, 0.0);
  Shape.FBoundingBox.IsPoint := Shape.FBoundingBox.Min = Shape.FBoundingBox.Max;
  //Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateRectangle(Shape: TMesh; WidthLile, Width, Height: BSFloat);
var
  s_half: TVec2f;
  s,c: BSFloat;
begin
  Shape.TypePrimitive := tpTriangleStrip;
  s_half.x := Width / 2;
  s_half.y := Height / 2;
  s := WidthLile;
  c := WidthLile;
  Shape.AddVertex(vec3( s_half.x,     s_half.y,   0));
  Shape.AddVertex(vec3( s_half.x-s,   s_half.y-c, 0));
  Shape.AddVertex(vec3(-s_half.x,     s_half.y,   0));
  Shape.AddVertex(vec3(-s_half.x+s,   s_half.y-c, 0));
  Shape.AddVertex(vec3(-s_half.x,    -s_half.y,   0));
  Shape.AddVertex(vec3(-s_half.x+s,  -s_half.y+c, 0));
  Shape.AddVertex(vec3( s_half.x,    -s_half.y,   0));
  Shape.AddVertex(vec3( s_half.x-s,  -s_half.y+c, 0));
  // repeat first vertex for optimization ray tracing for GL_TRIANGLE_STRIP objects
  Shape.AddVertex(vec3( s_half.x,     s_half.y,   0));
  Shape.AddVertex(vec3( s_half.x-s,   s_half.y-c, 0));

  Shape.Indexes.Add(0);
  Shape.Indexes.Add(1);
  Shape.Indexes.Add(2);
  Shape.Indexes.Add(3);
  Shape.Indexes.Add(4);
  Shape.Indexes.Add(5);
  Shape.Indexes.Add(6);
  Shape.Indexes.Add(7);
  Shape.Indexes.Add(8);
  Shape.Indexes.Add(9);

  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateRoundRect(
  Shape: TMesh; WidthLine: BSFloat; NumSlices: int32; Radius, Width,
  Height: BSFloat);
const
  QUARTER_COORD: array[0..3] of TVec2i = ((x:1; y:1), (x:-1; y:1), (x:-1; y:-1), (x:1; y:-1));
var
  i, j, count: int32;
  angleStep, s, c, wh, hh, w, h: BSFloat;  // r2,
  v: TVec3f;
  points: array of TVec3f;
begin
  if (Radius = 0) or (NumSlices = 0) then
  begin
    if WidthLine = 0 then
      GeneratePlane(Shape, vec2(Width, Height))
    else
      GenerateRectangle(Shape, WidthLine, Width, Height);
    exit;
  end;
  angleStep := 90 / NumSlices;
  wh := (Width - Radius*2 - WidthLine) * 0.5;
  hh := (Height - Radius*2 - WidthLine) * 0.5;
  {Shape.DrawingPrimitive := GL_TRIANGLE_STRIP;
  r2 := Radius - WidthLine;
  for i := 0 to 3 do
  begin
    w := QUARTER_COORD[i].x * wh;
    h := QUARTER_COORD[i].y * hh;
    for j := 0 to NumSlices do
    begin
      BS_SinCos(i*90 + angleStep * j, s, c);
      v := Vec3(
        w + Radius * c,
        h + Radius * s,
        0
      );
      Shape.AddVertex(v);
      v := Vec3(
        w + r2 * c,
        h + r2 * s,
        0
      );
      Shape.AddVertex(v);

      Shape.Indexes.Add(Shape.Indexes.Count);
      Shape.Indexes.Add(Shape.Indexes.Count);
    end;
  end;
  }
  points := nil;
  SetLength(points, 4 * (NumSlices+1));
  count := 0;
  for i := 0 to 3 do
  begin
    w := QUARTER_COORD[i].x * wh;
    h := QUARTER_COORD[i].y * hh;
    for j := 0 to NumSlices do
    begin
      BS_SinCos(i*90 + angleStep * j, s, c);
      v := Vec3(
        w + Radius * c,
        h + Radius * s,
        0
      );
      points[count] := v;
      inc(count);
    end;
  end;
  GeneratePath2d(Shape, @points[0], length(points), WidthLine, true, true);
  // for link end to begin add first vertex
  {Shape.AddVertex(Shape.ReadPoint(0));
  Shape.AddVertex(Shape.ReadPoint(1));
  Shape.Indexes.Add(Shape.Indexes.Count);
  Shape.Indexes.Add(Shape.Indexes.Count);
  Shape.FBoundingBox.Max := vec3(wh+WidthLine+r2, hh+WidthLine+r2, 0);
  Shape.FBoundingBox.Min := -Shape.FBoundingBox.Max;}
  //Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateRoundRect(Shape: TMesh; NumSlices: int32; Radius, Width, Height: BSFloat);
const
  QUARTER_COORD: array[0..3] of TVec2i =
    ((x:1; y:1),(x:-1; y:1), (x:-1; y:-1), (x:1; y:-1));
var
  i, j: int32;
  angleStep, s, c, wh, hh, w, h: BSFloat;
  v: TVec3f;
begin
  if (Width = 0) or (Height = 0) then
    exit;

  Shape.TypePrimitive := tpTriangleFan;

  if numSlices > 0 then
    angleStep := 90 / numSlices
  else
    angleStep := 0.0;

  Shape.AddVertex(Vec3(0.0, 0.0, 0.0));
  wh := (Width - Radius*2)*0.5;
  hh := (Height - Radius*2)*0.5;
  for i := 0 to 3 do
  begin
    w := QUARTER_COORD[i].x*wh;
    h := QUARTER_COORD[i].y*hh;
    for j := 0 to NumSlices do
    begin
      BS_SinCos(i*90 + angleStep * j, s, c);
      v := vec3(w+Radius*c, h+Radius*s, 0.0);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
    end;
  end;

  wh := wh + Radius;
  hh := hh + Radius;
  Shape.FBoundingBox.Middle := vec3(0.0, 0.0, 0.0);
  Shape.FBoundingBox.Min := vec3(-wh, -hh, 0);
  Shape.FBoundingBox.Max := vec3( wh,  hh, 0);
  Shape.FBoundingBox.IsPoint := false;
end;

class procedure TBlackSharkFactoryShapesP.GenerateSphere(
  Shape: TMesh; NumSlices: int32; Radius: BSFloat;
  PrimitiveTriangleStrip: boolean);
const
  space = 20;
var
  a, b: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleStrip;
  b := 0;
  while b < 181 do
    begin
    a := 0;
    while a < 361 do
      begin
      v := vec3(
        Radius * BS_Sin(a) * BS_Sin(b),
        Radius * BS_Cos(a) * BS_Sin(b),
        Radius * BS_Cos(b)
      );
      // V = (2 * b) / 360;
      // U = (a) / 360;
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);

      v := vec3(
        Radius * BS_Sin(a) * BS_Sin(b + space),
        Radius * BS_Cos(a) * BS_Sin(b + space),
        Radius * BS_Cos(b + space)
      );
      //V = (2 * (b + space)) / 360;
      //U = (a) / 360;      inc(a, space);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);

      v := vec3(
        Radius * BS_Sin(a + space) * BS_Sin(b),
        Radius * BS_Cos(a + space) * BS_Sin(b),
        Radius * BS_Cos(b)
      );
      //V = (2 * b) / 360;
      //U = (a + space) / 360;      inc(a, space);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);

      v := vec3(
        Radius * BS_Sin(a + space) * BS_Sin(b + space),
        Radius * BS_Cos(a + space) * BS_Sin(b + space),
        Radius * BS_Cos(b + space)
      );
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
      //V = (2 * (b + space)) / 360;
      //U = (a + space) / 360;      end;
      a := a + space;
      end;
    b := b + space;
    end;
  Shape.FBoundingBox.Middle := vec3(0.0, 0.0, 0.0);
  Shape.FBoundingBox.Min := vec3(-Radius, -Radius, -Radius);
  Shape.FBoundingBox.Max := vec3( Radius,  Radius,  Radius);
end;

class procedure TBlackSharkFactoryShapesP.GenerateTrancatedCylinder(
  Shape: TMesh; Radius: BSFloat; NumSlices: int32; HeightHigh,
  HeightLow: BSFloat; TextureBottom, TextureTop: boolean);
begin

end;

class procedure TBlackSharkFactoryShapesP.GenerateTrapeze(Shape: TMesh;
  UpperBase, LowerBase, Height: BSFloat; WidthLine: BSFloat; Fill: boolean);
var
  lbh, ubh, hh: BSFloat;
  alpha: BSFloat;
  c, d1,d2: BSFloat;
  i: Integer;
begin

  lbh := LowerBase * 0.5;
  ubh := UpperBase * 0.5;
  hh := Height * 0.5;
  if Fill then
  begin
    Shape.TypePrimitive := tpTriangleFan;
    Shape.AddVertex(vec3(0.0, 0.0, 0.0));
    Shape.AddVertex(vec3(-ubh, hh, 0.0));
    Shape.AddVertex(vec3(-lbh, -hh, 0.0));
    Shape.AddVertex(vec3(lbh, -hh, 0.0));
    Shape.AddVertex(vec3(ubh, hh, 0.0));
    Shape.Indexes.Add(0);
    Shape.Indexes.Add(1);
    Shape.Indexes.Add(2);
    Shape.Indexes.Add(3);
    Shape.Indexes.Add(4);
    Shape.Indexes.Add(1);
  end else
  begin
    Shape.TypePrimitive := tpTriangleStrip;
    c := lbh - ubh;
    //a := sqrt(sqr(c) + sqr(Height));
    alpha := ArcTan2(c, Height);
    //wl := WidthLine * 0.5;
    d1 := (1 - alpha) * WidthLine;
    d2 := (1 + alpha) * WidthLine;

    Shape.AddVertex(vec3(-ubh, hh, 0.0));
    Shape.AddVertex(vec3(-ubh + d1, hh - WidthLine, 0.0));

    Shape.AddVertex(vec3(-lbh, -hh, 0.0));
    Shape.AddVertex(vec3(-lbh + d2, -hh + WidthLine, 0.0));

    Shape.AddVertex(vec3(lbh, -hh, 0.0));
    Shape.AddVertex(vec3(lbh - d2, -hh + WidthLine, 0.0));

    Shape.AddVertex(vec3(ubh, hh, 0.0));
    Shape.AddVertex(vec3(ubh - d1, hh - WidthLine, 0.0));

    for i := 0 to 7 do
      Shape.Indexes.Add(Shape.Indexes.Count);

    { close path }
    Shape.Indexes.Add(0);
    Shape.Indexes.Add(1);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateTrapezeRound(Shape: TMesh;
  UpperBase, LowerBase, Height, WidthLine: BSFloat; Radius: BSFloat; NumSlices: int32; Fill: boolean);
var
  lbh, ubh, hh: BSFloat;
  wh_top, wh_bot: BSFloat;
  s, c, angleStep: BSFloat;
  i: int32;
  v: TVec3f;
  a_top, a_bottom, a: BSFloat;
begin
  if Fill then
  begin
    if numSlices = 0 then
    begin
      GenerateTrapeze(Shape, UpperBase, LowerBase, Height, WidthLine, Fill);
      exit;
    end;

    Shape.TypePrimitive := tpTriangleFan;

    Shape.AddVertex(Vec3(0.0, 0.0, 0.0));
    wh_top := (UpperBase - Radius*2)*0.5;
    wh_bot := (LowerBase - Radius*2)*0.5;
    hh := (Height - Radius*2)*0.5;
    a_bottom := BS_RAD2DEG*ArcTan2(Height, abs(0.5*(LowerBase-UpperBase)));
    a_top := (90-a_bottom);
      //w := QUARTER_COORD[i].x*wh;
      //h := QUARTER_COORD[i].y*hh;
    angleStep := (90-a_top) / numSlices;
    a := a_top;
    for i := 0 to NumSlices do
    begin
      BS_SinCos(a, s, c);
      a := a + angleStep;
      v := vec3(wh_top+Radius*c, hh+Radius*s, 0.0);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
    end;
    a := 90;
    for i := 0 to NumSlices do
    begin
      BS_SinCos(a, s, c);
      a := a + angleStep;
      v := vec3(-wh_top+Radius*c, hh+Radius*s, 0.0);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
    end;
    a := 180 - a_top;
    angleStep := (90+(180-a)) / numSlices;
    for i := 0 to NumSlices do
    begin
      BS_SinCos(a, s, c);
      a := a + angleStep;
      v := vec3(-wh_bot+Radius*c, -hh+Radius*s, 0.0);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
    end;
    a := 270;
    for i := 0 to NumSlices do
    begin
      BS_SinCos(a, s, c);
      a := a + angleStep;
      v := vec3(wh_bot+Radius*c, -hh+Radius*s, 0.0);
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
    end;
  end else
  begin
    lbh := LowerBase * 0.5;
    ubh := UpperBase * 0.5;
    hh := Height * 0.5;
    c := (lbh - ubh) * 0.5;
    GenerateBezierCubic(Shape, vec3(- ubh, hh, 0.0), vec3(- ubh - c, hh, 0.0), vec3(- ubh - c, - hh, 0.0),
      vec3(-lbh, - hh, 0.0), WidthLine, 0.1, false);
    GenerateBezierCubic(Shape, vec3(lbh, - hh, 0.0), vec3( ubh + c, - hh, 0.0), vec3( ubh + c, hh, 0.0),
      vec3( ubh, hh, 0.0), WidthLine, 0.1, false);
    Shape.TypePrimitive := tpTriangleStrip;
    { close path }
    Shape.Indexes.Add(0);
    Shape.Indexes.Add(1);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesP.GenerateTruncatedCone(
  Shape: TMesh; RadiusTop, RadiusBottom: BSFloat; NumSlices: int32;
  Height: BSFloat; TextureTop, TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  h_half    := Height / 2;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.AddVertex(v0_top);
  Shape.AddVertex(v0_bottom);
  for j := 0 to NumSlices + 1 do
    begin
    v1 := Vec3(
      RadiusTop * BS_Sin ( angleStep * j ),
      h_half,
      RadiusTop * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      RadiusBottom * BS_Sin ( angleStep * j ),
      -h_half,
      RadiusBottom * BS_Cos ( angleStep * j )
    );

    Shape.AddVertex(v1);
    Shape.AddVertex(v2);

    //Result.FNormals.Add(Vec3(v1.x / RadiusTop, v1.y / RadiusBottom, v1.z / RadiusBottom));
    //Result.FNormals.Add(Vec3(v2.x / RadiusBottom, v2.y / RadiusBottom, v2.z / RadiusBottom));

    //Result.FUVCoords.Add();
    //Result.FUVCoords.Add();
    if TextureTop and (j < NumSlices) then
      begin
      Shape.Indexes.Add(j*2 + 2);
      Shape.Indexes.Add(j*2 + 4);
      Shape.Indexes.Add(0);
      end;
   end;

  for j := 0 to NumSlices - 1 do
    begin
    Shape.Indexes.Add(j*2 + 2);
    Shape.Indexes.Add(j*2 + 3);
    Shape.Indexes.Add(j*2 + 4);

    Shape.Indexes.Add(j*2 + 4);
    Shape.Indexes.Add(j*2 + 3);
    Shape.Indexes.Add(j*2 + 5);
    end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
      begin
      Shape.Indexes.Add(j*2 + 3);
      Shape.Indexes.Add(j*2 + 5);
      Shape.Indexes.Add(1);
      end;
  Shape.CalcBoundingBox;
end;

{ TBlackSharkFactoryShapesPT }

class procedure TBlackSharkFactoryShapesPT.GeneratePlane(Shape: TMesh;
  const SizePlane: TVec2f);
begin
  TBlackSharkFactoryShapesP.GeneratePlane(Shape, SizePlane);
  // add texture components
  Shape.Write(0, TVertexComponent.vcTexture1, vec2(0.0, 1.0));
  Shape.Write(1, TVertexComponent.vcTexture1, vec2(0.0, 0.0));
  Shape.Write(2, TVertexComponent.vcTexture1, vec2(1.0, 1.0));
  Shape.Write(3, TVertexComponent.vcTexture1, vec2(1.0, 0.0));
end;

class procedure TBlackSharkFactoryShapesPT.GenerateRectangle(Shape: TMesh; WidthLile, Width, Height: BSFloat);
var
  s_half: TVec2f;
  s,c: BSFloat;
begin
  Shape.TypePrimitive := tpTriangleStrip;
  s_half.x := Width / 2;
  s_half.y := Height / 2;
  s := WidthLile;
  c := WidthLile;
  Shape.Write(Shape.AddVertex(vec3( s_half.x,     s_half.y,   0)), vcTexture1, Vec2(1.0, 0.0));
  Shape.Write(Shape.AddVertex(vec3( s_half.x-s,   s_half.y-c, 0)), vcTexture1, Vec2((s_half.x-s)/s_half.x, c/s_half.y));
  Shape.Write(Shape.AddVertex(vec3(-s_half.x,     s_half.y,   0)), vcTexture1, Vec2(0.0, 0));
  Shape.Write(Shape.AddVertex(vec3(-s_half.x+s,   s_half.y-c, 0)), vcTexture1, Vec2(s/s_half.x, c/s_half.y));
  Shape.Write(Shape.AddVertex(vec3(-s_half.x,    -s_half.y,   0)), vcTexture1, Vec2(0.0, 1.0));
  Shape.Write(Shape.AddVertex(vec3(-s_half.x+s,  -s_half.y+c, 0)), vcTexture1, Vec2(s/s_half.x, (s_half.y-c)/s_half.y));
  Shape.Write(Shape.AddVertex(vec3( s_half.x,    -s_half.y,   0)), vcTexture1, Vec2(1.0, 1.0));
  Shape.Write(Shape.AddVertex(vec3( s_half.x-s,  -s_half.y+c, 0)), vcTexture1, Vec2((s_half.x-s)/s_half.x, (s_half.y-c)/s_half.y));
  // repeat first vertex for optimization ray tracing for GL_TRIANGLE_STRIP objects
  Shape.Write(Shape.AddVertex(vec3( s_half.x,     s_half.y,   0)), vcTexture1, Vec2(1.0, 0.0));
  Shape.Write(Shape.AddVertex(vec3( s_half.x-s,   s_half.y-c, 0)), vcTexture1, Vec2((s_half.x-s)/s_half.x, c/s_half.y));

  Shape.Indexes.Add(0);
  Shape.Indexes.Add(1);
  Shape.Indexes.Add(2);
  Shape.Indexes.Add(3);
  Shape.Indexes.Add(4);
  Shape.Indexes.Add(5);
  Shape.Indexes.Add(6);
  Shape.Indexes.Add(7);
  Shape.Indexes.Add(8);
  Shape.Indexes.Add(9);

  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateRoundRect(Shape: TMesh;
  WidthLine: BSFloat; NumSlices: int32; Radius, Width, Height: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateRoundRect(Shape, WidthLine, NumSlices, Radius, Width, Height);
  Shape.CalcBoundingBox(false, true);
end;

class procedure TBlackSharkFactoryShapesPT.GenerateRoundRect(Shape: TMesh; NumSlices: int32; Radius, Width, Height: BSFloat);
const
  QUARTER_COORD: array[0..3] of TVec2i =
    ((x:1; y:1),(x:-1; y:1), (x:-1; y:-1), (x:1; y:-1));
var
  i, j: int32;
  angleStep, s, c, wh, hh, w, h: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleFan;
  angleStep := 90 / numSlices;
  Shape.Write(Shape.AddVertex(Vec3(0.0, 0.0, 0.0)), vcTexture1, Vec2(0.5, 0.5));
  wh := (Width - Radius * 2) / 2;
  hh := (Height - Radius * 2) / 2;
  for i := 0 to 3 do
    begin
    w := QUARTER_COORD[i].x * wh;
    h := QUARTER_COORD[i].y * hh;
    for j := 0 to NumSlices do
      begin
      BS_SinCos(i*90 + angleStep * j, s, c);
      v := Vec3(
        w + Radius * c,
        h + Radius * s,
        0
      );
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.Write(Shape.AddVertex(v), vcTexture1, vec2(0.5 + v.x/Width, 0.5 - v.y/Height));
      end;
    end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateSphere(Shape: TMesh; NumSlices: int32; Radius: BSFloat; PrimitiveTriangleStrip: boolean);
const
  space = 10;
var
  a, b: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleStrip;
  b := 0;
  while b < 180 do
  begin
    a := 0;
    while a < 360 do
    begin
      v := vec3(
        Radius * BS_Sin(a) * BS_Sin(b),
        Radius * BS_Cos(b),
        Radius * BS_Cos(a) * BS_Sin(b)
      );
      // V = (2 * b) / 360;
      // U = (a) / 360;
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
      //Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2((2 * b) / 360, a / 360));
      Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2(a / 360, 1 - (2 * b) / 360));
      v := vec3(
        Radius * BS_Sin(a) * BS_Sin(b + space),
        Radius * BS_Cos(b + space),
        Radius * BS_Cos(a) * BS_Sin(b + space)
      );
      //V = (2 * (b + space)) / 360;
      //U = (a) / 360;
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
      //Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2(2 * (b + space) / 360, a / 360));
      Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2(a / 360, 1 - 2 * (b + space) / 360));

      v := vec3(
        Radius * BS_Sin(a + space) * BS_Sin(b),
        Radius * BS_Cos(b),
        Radius * BS_Cos(a + space) * BS_Sin(b)
      );
      //V = (2 * b) / 360;
      //U = (a + space) / 360;
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
      //Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2((2 * b) / 360, (a + space) / 360));
      Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2((a + space) / 360, 1 - (2 * b) / 360));

      v := vec3(
        Radius * BS_Sin(a + space) * BS_Sin(b + space),
        Radius * BS_Cos(b + space),
        Radius * BS_Cos(a + space) * BS_Sin(b + space)
      );
      Shape.Indexes.Add(Shape.CountVertex);
      Shape.AddVertex(v);
      //V = (2 * (b + space)) / 360;
      //U = (a + space) / 360;
      //Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2((2 * (b + space)) / 360, (a + space) / 360));
      Shape.Write(Shape.CountVertex - 1, vcTexture1, vec2((a + space) / 360, 1 - (2 * (b + space)) / 360));
      a := a + space;
    end;
    b := b + space;
  end;
  Shape.FBoundingBox.Middle := vec3(0.0, 0.0, 0.0);
  Shape.FBoundingBox.Min := vec3(-Radius, -Radius, -Radius);
  Shape.FBoundingBox.Max := vec3( Radius,  Radius,  Radius);
end;

class procedure TBlackSharkFactoryShapesPT.GenerateLine2d(Shape: TMesh;
  ALength, Width: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateLine2d(Shape, ALength, Width);
  Shape.CalcTextureUV;
end;

class function TBlackSharkFactoryShapesPT.GeneratePath2d(Shape: TMesh;
  Points: PArrayVec3f; Count: int32; VerticalWidth: BSFloat; Closed: boolean;
  CalcBB: boolean): TVec3f;
begin
  Result := bs.mesh.primitives.GeneratePath2d(Shape, Points, Count, VerticalWidth, Closed, CalcBB);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateCylinder(Shape: TMesh;
  Radius: BSFloat; NumSlices: int32; Height: BSFloat; TextureTop,
  TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  //FRoot.UpdateBegin;
  h_half    := Height / 2;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.Write(Shape.AddVertex(v0_top), vcTexture1,  vec2(0.0, 0.0));
  Shape.Write(Shape.AddVertex(v0_bottom), vcTexture1, vec2(0.0, 0.0));
  for j := 0 to NumSlices + 1 do
    begin
    v1 := Vec3(
      radius * BS_Sin ( angleStep * j ),
      h_half,
      radius * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      v1.x,
      -h_half,
      v1.z
    );

    Shape.Write(Shape.AddVertex(v1), vcTexture1, vec2(j / (NumSlices+1), 1.0));
    Shape.Write(Shape.AddVertex(v2), vcTexture1, vec2(j / (NumSlices+1), 0.0));

    // Shape.FNormals.Add(Vec3(v1.x / Radius, v1.y / Radius, v1.z / Radius));
    // Shape.FNormals.Add(Vec3(v2.x / Radius, v2.y / Radius, v2.z / Radius));

    if TextureTop and (j < NumSlices) then
      begin
      Shape.Indexes.Add(j*2+2);
      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(0);
      end;
   end;

  for j := 0 to NumSlices do
    begin
    Shape.Indexes.Add(j*2+2);
    Shape.Indexes.Add(j*2+3);

    if j <> NumSlices then
      begin
      Shape.Indexes.Add(j*2+4);

      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
      end else
      begin
      Shape.Indexes.Add(2);

      Shape.Indexes.Add(2);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(3);
      end;
    end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
      begin
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
      Shape.Indexes.Add(1);
      end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateTrancatedCylinder(
  Shape: TMesh; Radius: BSFloat; NumSlices: int32; HeightHigh,
  HeightLow: BSFloat; TextureBottom, TextureTop: boolean);
var
  j: int32;
  angleStep, cos_trancat: BSFloat;
  v1, v2: TVec3f;
  h_half, delta_height, c: BSFloat;
begin
  delta_height  := HeightHigh - HeightLow;
  h_half        := HeightLow + delta_height / 2;
  cos_trancat   := sqrt(sqr(delta_height) + sqr(Radius*2))/delta_height;
  angleStep     := 360 / NumSlices;
  // top centre
  Shape.Write(Shape.AddVertex(Vec3(0.0,  h_half - delta_height / 2, 0)), vcTexture1, vec2(0.0, 0.0)); // ????????
  // bottom centre
  Shape.Write(Shape.AddVertex(Vec3(0.0, -h_half, 0)), vcTexture1, vec2(0.0, 0.0)); // ????????
  for j := 0 to NumSlices + 1 do
    begin
    c  := BS_Cos ( angleStep * j );
    v1 := Vec3(
      Radius * BS_Sin ( angleStep * j ),
      HeightLow + (Radius * c) / cos_trancat,
      Radius * c
      );
    v2 := Vec3(
      v1.x,
      -h_half,
      v1.z
    );
    Shape.Write(Shape.AddVertex(v1), vcTexture1, Vec2(j / (NumSlices+1), 1.0));
    Shape.Write(Shape.AddVertex(v2), vcTexture1, Vec2(j / (NumSlices+1), 0.0));

    //Shape.FNormals.Add(Vec3(v1.x / Radius, v1.y / Radius, v1.z / Radius));
    //Shape.FNormals.Add(Vec3(v2.x / Radius, v2.y / Radius, v2.z / Radius));

    if TextureTop and (j < NumSlices) then
      begin
      Shape.Indexes.Add(j*2+2);
      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(0);
      end;
   end;

  for j := 0 to NumSlices do
    begin
    Shape.Indexes.Add(j*2+2);
    Shape.Indexes.Add(j*2+3);

    if j <> NumSlices then
      begin
      Shape.Indexes.Add(j*2+4);

      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
      end else
      begin
      Shape.Indexes.Add(2);  // ??????????

      Shape.Indexes.Add(2);
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(3);
      end;
    end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
      begin
      Shape.Indexes.Add(j*2+3);
      Shape.Indexes.Add(j*2+5);
      Shape.Indexes.Add(1);
      end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateTrapeze(Shape: TMesh;
  UpperBase, LowerBase, Height: BSFloat; WidthLine: BSFloat; Fill: boolean);
begin
  TBlackSharkFactoryShapesP.GenerateTrapeze(Shape, UpperBase, LowerBase, Height,
    WidthLine, Fill);
  Shape.CalcBoundingBox(true, true);
end;

class function TBlackSharkFactoryShapesPT.GenerateAngleArc(
  Shape: TMesh; NumSlices: int32; Radius, StartAngle, Angle,
  WidthLine: BSFloat): TVec3f;
begin
  Result := TBlackSharkFactoryShapesP.GenerateAngleArc(Shape, NumSlices, Radius, StartAngle, Angle, WidthLine);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateArrow2d(Shape: TMesh;
  ALength, Width, LenTip, WidthTip: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateArrow2d(Shape, ALength, Width, LenTip, WidthTip);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateBezierCubic(
  Shape: TMesh; const P0, P1, P2, P3: TVec3f; AWidth,
  STEP: BSFloat; CalcBB: boolean);
begin
  TBlackSharkFactoryShapesP.GenerateBezierCubic(Shape, P0, P1, P2, P3, AWidth, STEP, CalcBB);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateBezierLinear(Shape: TMesh;
  const P0, P1: TVec3f;  AWidth, STEP: BSFloat; CalcBB: boolean);
begin
  TBlackSharkFactoryShapesP.GenerateBezierLinear(Shape, P0, P1, AWidth, STEP, CalcBB);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateBezierQuadratic(Shape: TMesh;
  const P0, P1, P2: TVec3f; AWidth, STEP: BSFloat; CalcBB: boolean);
begin
  TBlackSharkFactoryShapesP.GenerateBezierQuadratic(Shape, P0, P1, P2, AWidth, STEP, CalcBB);
  Shape.CalcTextureUV;
end;

class function TBlackSharkFactoryShapesPT.CreateShape: TMesh;
begin
  Result := TMeshPT.Create;
end;

class function TBlackSharkFactoryShapesPT.GenerateAngleArc(Shape: TMesh;
  NumSlices: int32; Radius, StartAngle, Angle: BSFloat): TVec3f;
begin
  Result := TBlackSharkFactoryShapesP.GenerateAngleArc(Shape, NumSlices, Radius, StartAngle, Angle);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateEllipse(Shape: TMesh;
  NumSlices: int32; DeltaF: BSFloat);
var
  a, b: BSFloat;
begin
  // calc Ellipse by condition: c = DeltaF / 2 = b = R. Then:
  // a = c / sqwr(2);
  b := DeltaF / 2;
  a := (DeltaF / sqrt(2));
  TBlackSharkFactoryShapesP.GenerateEllipse(Shape, NumSlices, a, b);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateEllipse(Shape: TMesh;
  NumSlices: int32; a, b: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateEllipse(Shape, NumSlices, a, b);
  Shape.CalcTextureUV;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateGrid(Shape: TMesh;
  const Size: TVec2f; StepX, StepY: BSFloat; HorizontalLines, VerticalLines, Closed,
  Triangles: boolean; Width: BSFloat);
begin
  TBlackSharkFactoryShapesP.GenerateGrid(Shape, Size, StepX, StepY, HorizontalLines,
    VerticalLines, Closed, Triangles, Width);
  Shape.CalcTextureUV;
end;

{ Truncated Cone }

class procedure TBlackSharkFactoryShapesPT.GenerateTruncatedCone(Shape: TMesh;
  RadiusTop, RadiusBottom: BSFloat; NumSlices: int32; Height: BSFloat;
  TextureTop: boolean; TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  h_half    := Height / 2;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.Write(Shape.AddVertex(v0_top), vcTexture1, vec2(0.0, 0.0));
  Shape.Write(Shape.AddVertex(v0_bottom), vcTexture1, vec2(0.0, 0.0));
  for j := 0 to NumSlices + 1 do
    begin
    v1 := Vec3(
      RadiusTop * BS_Sin ( angleStep * j ),
      h_half,
      RadiusTop * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      RadiusBottom * BS_Sin ( angleStep * j ),
      -h_half,
      RadiusBottom * BS_Cos ( angleStep * j )
    );

    Shape.Write(Shape.AddVertex(v1), vcTexture1, Vec2(j / (NumSlices+1), 1.0));
    Shape.Write(Shape.AddVertex(v2), vcTexture1, Vec2(j / (NumSlices+1), 0.0));

    //Result.FNormals.Add(Vec3(v1.x / RadiusTop, v1.y / RadiusBottom, v1.z / RadiusBottom));
    //Result.FNormals.Add(Vec3(v2.x / RadiusBottom, v2.y / RadiusBottom, v2.z / RadiusBottom));

    //Result.FUVCoords.Add();
    //Result.FUVCoords.Add();
    if TextureTop and (j < NumSlices) then
      begin
      Shape.Indexes.Add(j*2 + 2);
      Shape.Indexes.Add(j*2 + 4);
      Shape.Indexes.Add(0);
      end;
   end;

  for j := 0 to NumSlices - 1 do
    begin
    Shape.Indexes.Add(j*2 + 2);
    Shape.Indexes.Add(j*2 + 3);
    Shape.Indexes.Add(j*2 + 4);

    Shape.Indexes.Add(j*2 + 4);
    Shape.Indexes.Add(j*2 + 3);
    Shape.Indexes.Add(j*2 + 5);
    end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
      begin
      Shape.Indexes.Add(j*2 + 3);
      Shape.Indexes.Add(j*2 + 5);
      Shape.Indexes.Add(1);
      end;
  Shape.CalcBoundingBox;
end;

{ Cone }

class procedure TBlackSharkFactoryShapesPT.GenerateCone(Shape: TMesh;
  NumSlices: int32; Radius: BSFloat; Height: BSFloat; TextureBottom: boolean);
var
  j: int32;
  angleStep: BSFloat;
  v0_top, v0_bottom, v1, v2: TVec3f;
  h_half: BSFloat;
begin
  h_half    := Height / 2;
  angleStep := 360 / numSlices;
  v0_top    := Vec3(0.0,  h_half, 0);
  v0_bottom := Vec3(0.0, -h_half, 0);
  Shape.Write(Shape.AddVertex(v0_top), vcTexture1, vec2(0.0, 0.0));
  Shape.Write(Shape.AddVertex(v0_bottom), vcTexture1, vec2(0.0, 0.0));
  for j := 0 to NumSlices + 1 do
    begin
    v1 := Vec3(
      radius * BS_Sin ( angleStep * j ),
      -h_half,
      radius * BS_Cos ( angleStep * j )
    );
    v2 := Vec3(
      0,
      h_half,
      0
    );

    Shape.Write(Shape.AddVertex(v1), vcTexture1, Vec2(j / (NumSlices+1), 1.0));
    Shape.Write(Shape.AddVertex(v2), vcTexture1, Vec2(j / (NumSlices+1), 0.0));

    //Shape.FNormals.Add(Vec3(v1.x / Radius, v1.y / Radius, v1.z / Radius));
    //Shape.FNormals.Add(Vec3(v2.x / Radius, v2.y / Radius, v2.z / Radius));
    end;

  for j := 0 to NumSlices - 1 do
    begin
    Shape.Indexes.Add(j*2+2);
    Shape.Indexes.Add(j*2+3);
    Shape.Indexes.Add(j*2+4);
    end;

  if TextureBottom then
    for j := 0 to NumSlices - 1 do
      begin
      Shape.Indexes.Add(j*2+2);
      Shape.Indexes.Add(j*2+4);
      Shape.Indexes.Add(1);
      end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateCube(Shape: TMesh;
  const Size: TVec3f; const TexRect: TRectBSf);
var
  i: int8;
begin
  TBlackSharkFactoryShapesP.GenerateCube(Shape, Size);
  for i := 0 to 5 do
    begin
    Shape.Write(i*4, vcTexture1, Vec2(TexRect.x, TexRect.y + TexRect.Height));
    Shape.Write(i*4, vcTexture1, Vec2(TexRect.x, TexRect.y));
    Shape.Write(i*4, vcTexture1, Vec2(TexRect.x + TexRect.Width, TexRect.y));
    Shape.Write(i*4, vcTexture1, Vec2(TexRect.x + TexRect.Width, TexRect.y + TexRect.Height));
    end;
end;

{ Half Circle }

class procedure TBlackSharkFactoryShapesPT.GenerateHalfCircle(Shape: TMesh;
  NumSlices: int32; Radius: BSFloat);
var
  j: int32;
  angleStep: BSFloat;
  v: TVec3f;
begin
  angleStep := 180 / numSlices;
  for j := 0 to NumSlices + 1 do
    begin
    v := Vec3(
      Radius * BS_Cos ( angleStep * j ),
      Radius * BS_Sin ( angleStep * j ),
      0
    );

    Shape.Write(Shape.AddVertex(v), vcTexture1, Vec2(j / NumSlices, 1));
    Shape.Write(Shape.AddVertex(Vec3(0.0, 0.0, 0.0)), vcTexture1, Vec2(j / NumSlices, 0));

    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));

    if j < NumSlices then
      begin
      Shape.Indexes.Add(j*2);
      Shape.Indexes.Add(j*2+1);
      Shape.Indexes.Add(j*2+2);
      end;
    end;
  Shape.CalcBoundingBox;
end;

{ Circle }

class procedure TBlackSharkFactoryShapesPT.GenerateCircle(Shape: TMesh;
  NumSlices: int32; Radius: BSFloat);
var
  j: int32;
  angleStep, c, s: BSFloat;
  v: TVec3f;
begin
  Shape.TypePrimitive := tpTriangleFan;
  angleStep := 360 / numSlices;
  Shape.Write(Shape.AddVertex(Vec3(0.0, 0.0, 0.0)), vcTexture1, Vec2(0.5, 0.5));
  Shape.Indexes.Add(0);
  for j := 0 to NumSlices do
  begin
    BS_SinCos(angleStep * j, s, c);
    v := Vec3(
      Radius * c,
      Radius * s,
      0
    );
    Shape.Write(Shape.AddVertex(v), vcTexture1, Vec2(0.5 + c * 0.5,  0.5 + s * 0.5));
    //Shape.FNormals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    Shape.Indexes.Add(Shape.Indexes.Count);
  end;
  Shape.CalcBoundingBox;
end;

class procedure TBlackSharkFactoryShapesPT.GenerateCircle(Shape: TMesh; WidthLine: BSFloat; NumSlices: int32; Radius: BSFloat);
var
  j: int32;
  angleStep, s, c, r2: BSFloat;
  v: TVec3f;
begin
  angleStep := 360 / numSlices;
  //Result.FVertexes.Add(Vec3(0.0, 0.0, 0.0));
  //Result.FUVCoords.Add(Vec2(0.5, 0.5));
  Shape.TypePrimitive := tpTriangleStrip;
  r2 := Radius-WidthLine;
  for j := 0 to NumSlices do
    begin
    BS_SinCos(angleStep * j, s, c);
    v := Vec3(
      Radius * c,
      Radius * s,
      0
    );
    Shape.Write(Shape.AddVertex(v), vcTexture1, Vec2(0.0,  0.0));
    //Result.Normals.Add(Vec3(v.x / Radius, v.y / Radius, v.z / Radius));
    v := Vec3(
      r2 * c,
      r2 * s,
      0
    );
    Shape.Write(Shape.AddVertex(v), vcTexture1, Vec2(0.0, 1.0));

    //Shape.Normals.Add(Vec3(v.x / r2, v.y / r2, v.z / r2));

    Shape.Indexes.Add(Shape.Indexes.Count);
    Shape.Indexes.Add(Shape.Indexes.Count);
    end;
  Shape.CalcBoundingBox;
end;

end.

