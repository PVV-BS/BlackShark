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


unit bs.mesh;

{$I BlackSharkCfg.inc}

interface

uses
  {$ifndef fpc}
    math ,
  {$endif}
    bs.basetypes
  , bs.collections
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  ;

type

  TMesh      = class;
  TMeshClass = class of TMesh;

  TListVec1i = TListVec<BSInt>;
  TListVec1s = TListVec<GLshort>;
  TListVec2f = TListVec<TVec2f>;
  TListVec3f = TListVec<TVec3f>;
  TListVec4f = TListVec<TVec4f>;
  TListVec4b = TListVec<TVec4b>;

  //TMeshType = (mtMeshP, mtMeshPC, mtMeshPT, mtMeshPCrgba, mtMeshPTN);

  TListIndexes = class
  private
    FIndexes: TListVec<Byte>;
    FKindUnsignedInt: boolean;
    FKind: Cardinal;
    FIndexSizeOf: int8;
    procedure SetKindUnsignedInt(const Value: boolean);
    function GetCount: int32;
    function GetShiftData(AIndex: int32): Pointer;
    function GetCapacity: int32;
    procedure SetCapacity(const Value: int32);
    function GetItems(AIndex: int32): uint32;
    procedure SetCount(const Value: int32);
    procedure RebuildToUnsignedInt;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AValue: uint32); overload;
    procedure Add(const AValues: TArray<byte>); overload;
    function Copy: TArray<byte>;
    procedure Clear;
    property Items[AIndex: int32]: uint32 read GetItems;
    { for high-polygonal models need to set KindUnsignedInt in true }
    property KindUnsignedInt: boolean read FKindUnsignedInt write SetKindUnsignedInt;
    { GL_UNSIGNED_SHORT or GL_UNSIGNED_INT }
    property Kind: Cardinal read FKind;
    property Count: int32 read GetCount write SetCount;
    property Capacity: int32 read GetCapacity write SetCapacity;
    property ShiftData[AIndex: int32]: Pointer read GetShiftData;
    property IndexSizeOf: int8 read FIndexSizeOf;
  end;

  { TMesh }

  TMesh = class
  private
    FVertexes: TListVec<Byte>;
    FIndexes: TListIndexes;
    FCountVertex: int32;
    FMinSize: TVec3f;
    FDrawingPrimitive: GLint;
    FTypePrimitive: TTypePrimitive;
    function GetVertexesData: pByte;
    procedure SetCountVertex(const Value: int32); inline;
    function GetCapacityVertex: int32;
    procedure SetCapacityVertex(const Value: int32);
    procedure SetTypePrimitive(const Value: TTypePrimitive);
  public
    FBoundingBox: TBox3f;
    Components: array of TVertexComponent;
    ComponentsCount: int8;
    OffsetComponent: array[TVertexComponent] of int8;
    // size every component in bytes; forexmp, vcCoordinate = TVec3f = 12 bytes (SizeOf(TVec3f))
    SizeOfComponent: array[TVertexComponent] of int8;
    // quantity variables in every component; forexmp, vcCoordinate = TVec3f = 3 variables: x, y, z
    CountVarComponent: array[TVertexComponent] of int8;
    SizeOfVertex: int8;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function HasComponent(Component: TVertexComponent): boolean;
    procedure AddComponent(AComponent: TVertexComponent; ASizeOf: int8; ACountVar: int8);
    procedure DeleteComponent(AComponent: TVertexComponent);
    { calculate Axis Aligned Bounding Box; if CentreAlign = true then all coordinates
      will be correct for align center to (0.0, 0.0, 0.0)
     !!! Need to invoke every time after change the shape }
    function CalcBoundingBox(CentreAlign: boolean = false; CalcUV: boolean = false): TVec3f;
    procedure CalcTextureUV; overload;
    procedure CalcTextureUV(Area: TRectBSf); overload;
    function ReadPoint(index: int32): TVec3f;
    procedure WritePoint(index: int32; const Point: TVec3f);
    { adds new vertex and returns him index }
    function AddVertex(const Point: TVec3f): int32; overload;
    { use only if the mesh contains vcIndex component and consists of only vcVertex and vcIndex }
    function AddVertex(const Point: TVec4f): int32; overload;

    procedure Read(Index: int32; Component: TVertexComponent; out Result: BSFloat);  overload;
    procedure Read(Index: int32; Component: TVertexComponent; out Result: TVec2f);  overload;
    procedure Read(Index: int32; Component: TVertexComponent; out Result: TVec3f);  overload;
    procedure Read(Index: int32; Component: TVertexComponent; out Result: TVec4f);  overload;
    procedure Read(Index: int32; Component: TVertexComponent; out Result: Pointer);  overload;

    procedure Write(Index: int32; Component: TVertexComponent; const Value: BSFloat);overload;
    procedure Write(Index: int32; Component: TVertexComponent; const Value: TVec2f);overload;
    procedure Write(Index: int32; Component: TVertexComponent; const Value: TVec3f);overload;
    procedure Write(Index: int32; Component: TVertexComponent; const Value: TVec4f);overload;
    procedure Write(Index: int32; Component: TVertexComponent; const Value: Pointer);overload;

    procedure Delete(Index: int32; Count: int32);
    { beware use this methods, so BlackSharkGeometry.RayIntersectBox
      works only whith centered BB }
    function Transform(const Matrix: TMatrix4f; CalculateNewBoundingBox: boolean = true): TVec3f; overload;
    function Transform(const Matrix: TMatrix3f; CalculateNewBoundingBox: boolean = true): TVec3f; overload;
    function Transform(const Position: TVec3f; CalculateNewBoundingBox: boolean = false): TVec3f; overload;
    function Transform(RotateAxisX: BSFloat; RotateAxisY: BSFloat; RotateAxisZ: BSFloat; CalculateNewBoundingBox: boolean = true): TVec3f; overload;
    { change size BB on values DeltaX, DeltaY, DeltaZ }
    procedure TransformScale(DeltaX, DeltaY, DeltaZ: BSFloat; CalculateNewBoundingBox: boolean = true); overload;
    { change size shape by multiply values Scale on coordinate all vertexes }
    procedure TransformScale(Scale: TVec3f; CalculateNewBoundingBox: boolean = true); overload;
    procedure AddMesh(Mesh: TMesh; Transform: boolean = false; MatrixTransform: PMatrix4f = nil);
    procedure Assign(SourceMesh: TMesh; Transform: boolean = false; MatrixTransform: PMatrix4f = nil);
    procedure Clear;
    procedure Fill(const APoint: TVec3f);
    function Copy: TMesh;
    procedure CopyVertexes(ASource: TMesh);
    procedure CopyMesh(ASource: TMesh);
  public
    property Indexes: TListIndexes read FIndexes;
    property TypePrimitive: TTypePrimitive read FTypePrimitive write SetTypePrimitive;
    { a type of a drawn primitive (GL_TRIANGLES, GL_TRIANGLES_STRIP, GL_LINES...) }
    property DrawingPrimitive: GLint read FDrawingPrimitive;
    property VertexesData: pByte read GetVertexesData;
    property CountVertex: int32 read FCountVertex write SetCountVertex;
    property CapacityVertex: int32 read GetCapacityVertex write SetCapacityVertex;
    { minimal limits of size the shape; take into account in time invoke TransformScale }
    property MinSize: TVec3f read FMinSize write FMinSize;
  end;

  { TMeshP
    The shape contains vertexes consists only of cooridnates (points) }

  TMeshP = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshPI
    The shape contains vertexes consists of cooridnates (points) and some index }

  TMeshPI = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshPT
    The shape contains vertexes consists of cooridnates (points) and texture
    coordinates }

  TMeshPT = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshPT
    The shape contains vertexes consists of cooridnates (points) and color (rgb)
    }

  TMeshPC = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshLine
    The shape contains vertexes consists of cooridnates (points) and distance
    }

  TMeshLine = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshLineMultiColored
    The shape contains vertexes consists of cooridnates (points), color (rgba) and distance
    }

  TMeshLineMultiColored = class(TMesh)
  public
    constructor Create; override;
  end;

  { TMeshPT
    The shape contains vertexes consists of cooridnates (points), texture
    coordinates and normals }

  TMeshPTN = class(TMesh)
  public
    constructor Create; override;
  end;

const
  COMPONENTS_SIZE_OF: array[TVertexComponent] of int32 = (
    SizeOf(TVec3f), // vcCoordinate
    SizeOf(TVec4f), // vcColor
    SizeOf(TVec3f), // vcNormal
    SizeOf(TVec2f), // vcTexture1
    SizeOf(TVec2f), // vcTexture2
    SizeOf(TVec3f), // vcBones
    SizeOf(TVec3f), // vcWeights
    SizeOf(BSFloat) // vcIndex
  );

  COMPONENTS_VARS: array[TVertexComponent] of int32 = (
    3, // vcCoordinate
    4, // vcColor
    3, // vcNormal
    2, // vcTexture1
    2, // vcTexture2
    3, // vcBones
    3, // vcWeights
    1  // vcIndex
  );

implementation

uses
    SysUtils
  , bs.math
  , bs.exceptions
  ;

{ TMesh }

procedure TMesh.Read(Index: int32; Component: TVertexComponent; out Result: TVec4f);
begin
  if Index < FCountVertex then
    Result := PVec4f(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^
  else
    Result := Vec4(0.0, 0.0, 0.0, 0.0);
end;

procedure TMesh.Read(Index: int32; Component: TVertexComponent;
  out Result: TVec2f);
begin
  if Index < FCountVertex then
    Result := PVec2f(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^
  else
    Result := Vec2(0.0, 0.0);
end;

procedure TMesh.Read(Index: int32; Component: TVertexComponent; out Result: TVec3f);
begin
  if Index < FCountVertex then
    Result := PVec3f(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^
  else
    Result := Vec3(0.0, 0.0, 0.0);
end;

function TMesh.ReadPoint(Index: int32): TVec3f;
begin
  if index < FCountVertex then
    Result := TVec3f(PVec3f(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[vcCoordinate]])^)
  else
    Result := vec3(0.0, 0.0, 0.0);
end;

procedure TMesh.SetCapacityVertex(const Value: int32);
var
  val: int32;
begin
  if Value < 0 then
    val := 0
  else
    val := Value;

  if FCountVertex > val then
    CountVertex := val
  else
    FVertexes.Capacity := val * SizeOfVertex;
end;

procedure TMesh.SetCountVertex(const Value: int32);
begin
  FVertexes.Count := Value * SizeOfVertex;
  FCountVertex := Value;
end;

procedure TMesh.SetTypePrimitive(const Value: TTypePrimitive);
begin
  if FTypePrimitive = Value then
    exit;
  FTypePrimitive := Value;
  case FTypePrimitive of
    tpTriangles, tpQuad: FDrawingPrimitive := GL_TRIANGLES;
    tpTriangleFan: FDrawingPrimitive := GL_TRIANGLE_FAN;
    tpTriangleStrip: FDrawingPrimitive := GL_TRIANGLE_STRIP;
    tpLines: FDrawingPrimitive := GL_LINES;
    tpLineStrip: FDrawingPrimitive := GL_LINE_STRIP;
  end;
end;

procedure TMesh.Write(Index: int32; Component: TVertexComponent; const Value: TVec4f);
begin
  if Index >= FCountVertex then
    CountVertex := Index + 1;
  PVec4f(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^ := Value;
end;

procedure TMesh.Write(Index: int32; Component: TVertexComponent; const Value: TVec2f);
begin
  if Index >= FCountVertex then
    CountVertex := Index + 1;
  PVec2f(@FVertexes.Data^[index * SizeOfVertex + OffsetComponent[Component]])^ := Value;
end;

procedure TMesh.Write(Index: int32; Component: TVertexComponent; const Value: TVec3f);
begin
  if Index >= FCountVertex then
    CountVertex := Index + 1;
  PVec3f(@FVertexes.Data^[index * SizeOfVertex + OffsetComponent[Component]])^ := Value;
end;

procedure TMesh.Write(Index: int32; Component: TVertexComponent; const Value: BSFloat);
begin
  if Index >= FCountVertex then
    CountVertex := Index + 1;
  PBSFloat(@FVertexes.Data^[index * SizeOfVertex + OffsetComponent[Component]])^ := Value;
end;

procedure TMesh.WritePoint(Index: int32; const Point: TVec3f);
begin
  if Index >= FCountVertex then
    CountVertex := index + 1;
  PVec3f(@FVertexes.Data^[index * SizeOfVertex + OffsetComponent[vcCoordinate]])^ := Point;
end;

function TMesh.CalcBoundingBox(CentreAlign: boolean; CalcUV: boolean): TVec3f;
var
  i: int32;
  v, size: TVec3f;
begin
  //if FIndexes.Count > 65536 then
  //  raise Exception.Create('The number of indexes can not be greather than 65535!!!');
  FillChar(FBoundingBox, SizeOf(TBox3f), 0);
  if FCountVertex > 0 then
  begin
    FBoundingBox.Min := ReadPoint(0);
    FBoundingBox.Max := FBoundingBox.Min;
    for i := 1 to FCountVertex - 1 do
    begin
      v := ReadPoint(i);
      Box3CheckBB(FBoundingBox, v);
    end;
  end;
  FBoundingBox.IsPoint := FBoundingBox.Min = FBoundingBox.Max;
  FBoundingBox.Middle := Box3Middle(FBoundingBox);
  Result := FBoundingBox.Middle;
  // align at centre
  if CentreAlign then
  begin
    if CalcUV then
    begin
      size := FBoundingBox.Max - FBoundingBox.Middle;
      if (size.x > 0) and (size.y > 0) then
        for i := 0 to FCountVertex - 1 do
        begin
          v := ReadPoint(i) - FBoundingBox.Middle;
          WritePoint(i, v);
          Write(i, vcTexture1, vec2(0.5 + 0.5 * v.x/size.x, 0.5 - 0.5 * v.y/size.y));
        end;
    end else
    for i := 0 to FCountVertex - 1 do
      WritePoint(i, ReadPoint(i) - FBoundingBox.Middle);

    FBoundingBox.Min := FBoundingBox.Min - FBoundingBox.Middle;
    FBoundingBox.Max := FBoundingBox.Max - FBoundingBox.Middle;
    FBoundingBox.Middle := vec3(0.0, 0.0, 0.0);
  end else
  if CalcUV then
    CalcTextureUV;
end;

procedure TMesh.CalcTextureUV(Area: TRectBSf);
var
  i: int32;
  uv: TVec2f;
  v, size: TVec3f;
begin
  size := FBoundingBox.Max - FBoundingBox.Middle;
  for i := 0 to CountVertex - 1 do
  begin
    v := ReadPoint(i) - FBoundingBox.Middle;
    // for local area coordinates
    uv := vec2(0.5 + 0.5 * v.x/size.x, 0.5 - 0.5 * v.y/size.y);
    // convert from local area into texture coordinates
    uv :=  uv * Area.Size + Area.Position;
    Write(i, vcTexture1, uv);
  end;
end;

procedure TMesh.CalcTextureUV;
var
  i: int32;
  v, size: TVec3f;
begin
  size := FBoundingBox.Max - FBoundingBox.Middle;
  for i := 0 to FCountVertex - 1 do
  begin
    v := ReadPoint(i) - FBoundingBox.Middle;
    Write(i, vcTexture1, vec2(0.5 + 0.5 * v.x/size.x, 0.5 - 0.5 * v.y/size.y));
  end;
end;

procedure TMesh.AddComponent(AComponent: TVertexComponent; ASizeOf, ACountVar: int8);
var
  vertexes: TListVec<Byte>;
  i: int32;
  newSizeOf: int32;
begin
  if HasComponent(AComponent) then
    exit;
  newSizeOf := SizeOfVertex + ASizeOf;
  vertexes := TListVec<Byte>.Create;
  vertexes.Count := newSizeOf*CountVertex;
  for i := 0 to CountVertex - 1 do
  begin
    move(pByte(FVertexes.ShiftData[i*SizeOfVertex])^, pByte(vertexes.ShiftData[i*newSizeOf])^, SizeOfVertex);
  end;
  OffsetComponent[AComponent] := SizeOfVertex;
  SizeOfVertex := newSizeOf;
  SizeOfComponent[AComponent] := ASizeOf;
  CountVarComponent[AComponent] := ACountVar;
  inc(ComponentsCount);
  SetLength(Components, ComponentsCount);
  Components[ComponentsCount-1] := AComponent;
  FVertexes.Free;
  FVertexes := vertexes;
end;

procedure TMesh.AddMesh(Mesh: TMesh; Transform: boolean; MatrixTransform: PMatrix4f);
var
  i: int32;
  cv: uint32;
begin
  if (Mesh.CountVertex = 0) then
    exit;
  cv := CountVertex;
  for i := 0 to Mesh.FIndexes.Count - 1 do
    FIndexes.Add(Mesh.FIndexes.Items[i] + cv);

  if Transform then
  begin
    for i := 0 to Mesh.CountVertex - 1 do
    begin
      WritePoint(i, MatrixTransform^ * Mesh.ReadPoint(i));
    end;
  end else
  for i := 0 to Mesh.CountVertex - 1 do
    WritePoint(i, Mesh.ReadPoint(i));

  CalcBoundingBox;
end;

function TMesh.AddVertex(const Point: TVec4f): int32;
begin
  {$ifdef DEBUG_BS}
  if (ComponentsCount < 2) or (Components[1] <> vcIndex) then
    raise EComponentIsNotValid.Create('This method may use only if second vertex component is vcIndex');
  {$endif}
  Result := FCountVertex;
  FVertexes.Count := FVertexes.Count + SizeOfVertex;
  PVec4f(@FVertexes.Data^[Result * SizeOfVertex + OffsetComponent[vcCoordinate]])^ := Point;
  inc(FCountVertex);
end;

function TMesh.AddVertex(const Point: TVec3f): int32;
begin
  Result := FCountVertex;
  FVertexes.Count := FVertexes.Count + SizeOfVertex;
  //PVec3f(pByte(@FVertexes.Data^[Result*SizeOfVertex]) + OffsetComponent[vcCoordinate])^ := Point;
  PVec3f(@FVertexes.Data^[Result * SizeOfVertex + OffsetComponent[vcCoordinate]])^ := Point;
  inc(FCountVertex);
  //move(Point, (pByte(FVertexes.ShiftData[Result*SizeOfVertex]) + OffsetComponent[vcCoordinate])^, SizeOf(TVec3f));
end;

procedure TMesh.Assign(SourceMesh: TMesh;
  Transform: boolean; MatrixTransform: PMatrix4f);
begin
  Clear;
  AddMesh(SourceMesh, Transform, MatrixTransform);
end;

function TMesh.Transform(const Matrix: TMatrix4f; CalculateNewBoundingBox: boolean): TVec3f;
var
  i: int32;
  has_norm: boolean;
  n: TVec3f;
  m: TMatrix3f;
begin
  has_norm := HasComponent(vcNormal);
  m := Matrix;
  for i := 0 to CountVertex - 1 do
  begin
    WritePoint(i, Matrix*ReadPoint(i));
    if has_norm then
    begin
      Read(i, vcNormal, n);
      Write(i, vcNormal, m*n);
    end;
  end;

  if CalculateNewBoundingBox then
    Result := CalcBoundingBox(true)
  else
    Result := vec3(0.0, 0.0, 0.0);
end;

function TMesh.Transform(const Matrix: TMatrix3f; CalculateNewBoundingBox: boolean): TVec3f;
var
  i: int32;
  has_norm: boolean;
  n: TVec3f;
begin
  has_norm := HasComponent(vcNormal);
  for i := 0 to CountVertex - 1 do
  begin
    WritePoint(i, Matrix*ReadPoint(i));
    if has_norm then
    begin
      Read(i, vcNormal, n);
      Write(i, vcNormal, Matrix*n);
    end;
  end;

  if CalculateNewBoundingBox then
    Result := CalcBoundingBox(true)
  else
    Result := vec3(0.0, 0.0, 0.0);
end;

function TMesh.Transform(const Position: TVec3f; CalculateNewBoundingBox: boolean = false): TVec3f;
var
  i: int32;
begin
  for i := 0 to CountVertex - 1 do
    WritePoint(i, ReadPoint(i) + Position );

  if CalculateNewBoundingBox then
    Result := CalcBoundingBox(true)
  else
    Result := vec3(0.0, 0.0, 0.0);
end;

function TMesh.Transform(RotateAxisX: BSFloat; RotateAxisY: BSFloat; RotateAxisZ: BSFloat; CalculateNewBoundingBox: boolean): TVec3f;
var
  m: TMatrix4f;
  q: TQuaternion;
begin
  q := Quaternion(vec3(AngleEulerClamp(RotateAxisX), AngleEulerClamp(RotateAxisY), AngleEulerClamp(RotateAxisZ)));
  QuaternionToMatrix(m, q);
  Result := Transform(m, CalculateNewBoundingBox);
end;

procedure TMesh.TransformScale(DeltaX, DeltaY, DeltaZ: BSFloat; CalculateNewBoundingBox: boolean);
var
  s: TVec3f;
begin
  if FBoundingBox.x_max > EPSILON then
    s.x := abs((FBoundingBox.x_max + DeltaX*0.5) / FBoundingBox.x_max)
  else
    s.x := 1.0;
  if FBoundingBox.y_max > EPSILON then
    s.y := abs((FBoundingBox.y_max + DeltaY*0.5) / FBoundingBox.y_max)
  else
    s.y := 1.0;
  if FBoundingBox.z_max > EPSILON then
    s.z := abs((FBoundingBox.z_max + DeltaZ*0.5) / FBoundingBox.z_max)
  else
    s.z := 1.0;
  TransformScale(s, CalculateNewBoundingBox);
end;

procedure TMesh.TransformScale(Scale: TVec3f; CalculateNewBoundingBox: boolean);
var
  i: int32;
begin
  if ((Scale.z * FBoundingBox.x_max > EPSILON) and (Scale.x * FBoundingBox.x_max * 2 < FMinSize.x)) or
     ((Scale.z * FBoundingBox.y_max > EPSILON) and (Scale.y * FBoundingBox.y_max * 2 < FMinSize.y)) or
     ((Scale.z * FBoundingBox.z_max > EPSILON) and (Scale.z * FBoundingBox.z_max * 2 < FMinSize.z)) then
        exit;
  for i := 0 to CountVertex - 1 do
    WritePoint(i, Scale *  ReadPoint(i));

  if CalculateNewBoundingBox then
    CalcBoundingBox;
end;

procedure TMesh.Clear;
begin
  FVertexes.Count := 0;
  FIndexes.Count := 0;
  FCountVertex := 0;
end;

function TMesh.Copy: TMesh;
var
  i: int8;
begin
  Result := TMesh(TMeshClass(ClassType).Create);
  Result.MinSize := MinSize;
  Result.TypePrimitive := TypePrimitive;
  for i := 0 to ComponentsCount - 1 do
    Result.AddComponent(Components[i], SizeOfComponent[Components[i]], CountVarComponent[Components[i]]);
  Result.FCountVertex := FCountVertex;
  Result.Indexes.Add(FIndexes.Copy);
  Result.FVertexes.Add(FVertexes.Copy);
end;

procedure TMesh.CopyMesh(ASource: TMesh);
var
  i, j: int32;
  components: array of TVertexComponent;
  comp: TVertexComponent;
  compVal: Pointer;
begin
  for comp := Low(TVertexComponent) to High(TVertexComponent) do
  begin
    if ASource.HasComponent(comp) and (HasComponent(comp)) then
    begin
      SetLength(components, Length(components) + 1);
      components[Length(components) - 1] := comp;
    end;
  end;

  if Length(components) > 0 then
    for i := 0 to ASource.CountVertex - 1 do
    begin
      for j := 0 to Length(components) - 1 do
      begin
        ASource.Read(i, components[j], compVal);
        if Assigned(compVal) then
          Write(i, components[j], compVal);
      end;
    end;

  Indexes.Add(ASource.Indexes.Copy);
end;

procedure TMesh.CopyVertexes(ASource: TMesh);
begin
  FVertexes.Count := SizeOfVertex*CountVertex;
  move(ASource.VertexesData^, VertexesData^, FVertexes.Count);
end;

constructor TMesh.Create;
begin
  FDrawingPrimitive := GL_TRIANGLES;
  FVertexes := TListVec<byte>.Create;
  FIndexes := TListIndexes.Create;
  FBoundingBox.IsPoint := true;
  FMinSize := vec3(EPSILON * 10, EPSILON * 10, EPSILON * 10);
end;

procedure TMesh.Delete(Index, Count: int32);
var
  c: int32;
begin
  if (Index < FCountVertex) and (Index >= 0) then
  begin
    if Index + Count > FCountVertex then
      c := FCountVertex - Index
    else
      c := Count;
    Move(pByte(FVertexes.ShiftData[(index + c)*SizeOfVertex])^, pByte(FVertexes.ShiftData[index*SizeOfVertex])^, c*SizeOfVertex);
  end;
end;

procedure TMesh.DeleteComponent(AComponent: TVertexComponent);
var
  vertexes: TListVec<Byte>;
  i, j: int32;
  newSizeOf: int32;
  comp: TVertexComponent;
  ptrSrc, ptrDst: PByte;
begin
  if not HasComponent(AComponent) then
    exit;
  newSizeOf := (SizeOfVertex - SizeOfComponent[AComponent]);
  vertexes := TListVec<Byte>.Create;
  vertexes.Count := newSizeOf*CountVertex;
  ptrSrc := FVertexes.ShiftData[0];
  ptrDst := vertexes.ShiftData[0];

  if (OffsetComponent[AComponent] > 0) and (CountVertex > 0) then
    move(ptrSrc^, ptrDst^, OffsetComponent[AComponent]);

  for i := 0 to CountVertex - 2 do
  begin
    move(ptrSrc[i*SizeOfVertex + OffsetComponent[AComponent] + SizeOfComponent[AComponent]],
      ptrDst[i*newSizeOf + OffsetComponent[AComponent]], newSizeOf);
  end;

  // remainder in last vertex
  if (CountVertex > 0) and (Components[ComponentsCount-1] <> AComponent) then
    move(ptrSrc[(CountVertex-1)*SizeOfVertex + OffsetComponent[AComponent] + SizeOfComponent[AComponent]],
      ptrDst[(CountVertex-1)*newSizeOf+OffsetComponent[AComponent]], SizeOfVertex-OffsetComponent[AComponent]-SizeOfComponent[AComponent]);

  SizeOfVertex := newSizeOf;

  for i := 0 to ComponentsCount - 2 do
  begin
    if Components[ComponentsCount] = AComponent then
    begin

      for j := i+1 to ComponentsCount - 1 do
      begin
        Components[j-1] := Components[j];
      end;

      break;
    end;
  end;

  for comp := Low(TVertexComponent) to High(TVertexComponent) do
  begin
    if comp > AComponent then
      OffsetComponent[comp] := OffsetComponent[comp] - SizeOfComponent[AComponent];
  end;

  dec(ComponentsCount);
  SetLength(Components, ComponentsCount);
  FVertexes.Free;
  FVertexes := vertexes;
end;

destructor TMesh.Destroy;
begin
  if FVertexes = nil then
    raise Exception.Create('Error Message');
  FreeAndNil(FVertexes);
  FreeAndNil(FIndexes);
  inherited;
end;

procedure TMesh.Fill(const APoint: TVec3f);
var
  i: int32;
begin
  for i := 0 to CountVertex - 1 do
    WritePoint(i, APoint);
end;

function TMesh.GetCapacityVertex: int32;
begin
  if SizeOfVertex = 0 then
    exit(0);
  Result := FVertexes.Capacity div SizeOfVertex;
end;

function TMesh.GetVertexesData: pByte;
begin
  Result := FVertexes.ShiftData[0];
end;

function TMesh.HasComponent(Component: TVertexComponent): boolean;
var
  i: int8;
begin
  for i := 0 to ComponentsCount - 1 do
    if Components[i] = Component then
      exit(true);
  Result := false;
end;

procedure TMesh.Read(Index: int32; Component: TVertexComponent; out Result: Pointer);
begin
  if Index < FCountVertex then
    Result := @FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]]
  else
    Result := nil;
end;

procedure TMesh.Read(Index: int32; Component: TVertexComponent; out Result: BSFloat);
begin
  if Index < FCountVertex then
    Result := PBSFloat(@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^
  else
    Result := 0.0;
end;

procedure TMesh.Write(Index: int32; Component: TVertexComponent; const Value: Pointer);
begin
  if Index >= FCountVertex then
    CountVertex := index + 1;
  move(PByte(Value)^, (@FVertexes.Data^[Index * SizeOfVertex + OffsetComponent[Component]])^, SizeOfComponent[Component]);
end;

{ TListIndexes }

procedure TListIndexes.Add(AValue: uint32);
begin
  if (not FKindUnsignedInt) and (FIndexes.Count div FIndexSizeOf = 65536) then
    KindUnsignedInt := true;
  FIndexes.Count := FIndexes.Count + FIndexSizeOf;
  move(AValue, PByte(FIndexes.ShiftData[FIndexes.Count - FIndexSizeOf])^, FIndexSizeOf);
end;

procedure TListIndexes.Add(const AValues: TArray<byte>);
var
  c: int32;
begin
  if length(AValues) = 0 then
    exit;
  if (not FKindUnsignedInt) and (length(AValues) shr 1 > 65536) then
    KindUnsignedInt := true;
  c := FIndexes.Count;
  FIndexes.Count := c + length(AValues);
  move(AValues[0], PByte(FIndexes.ShiftData[c])^, length(AValues));
end;

procedure TListIndexes.Clear;
begin
  FIndexes.Clear;
end;

function TListIndexes.Copy: TArray<byte>;
begin
  if FIndexes.Count > 0 then
  begin
    SetLength(Result{%H-}, FIndexes.Count);
    move(PByte(FIndexes.ShiftData[0])^, Result[0], FIndexes.Count);
  end else
  begin
    Result := nil;
  end;
end;

constructor TListIndexes.Create;
begin
  FIndexSizeOf := 2;
  FKind := GL_UNSIGNED_SHORT;
  FIndexes := TListVec<Byte>.Create;
end;

destructor TListIndexes.Destroy;
begin
  FIndexes.Free;
  inherited;
end;

function TListIndexes.GetCapacity: int32;
begin
  Result := FIndexes.Capacity div FIndexSizeOf;
end;

function TListIndexes.GetCount: int32;
begin
  Result := FIndexes.Count div FIndexSizeOf;
end;

function TListIndexes.GetItems(AIndex: int32): uint32;
begin
  Result := 0;
  move(PByte(FIndexes.ShiftData[AIndex*FIndexSizeOf])^, Result, FIndexSizeOf);
end;

function TListIndexes.GetShiftData(AIndex: int32): Pointer;
begin
  Result := FIndexes.ShiftData[AIndex*FIndexSizeOf];
end;

procedure TListIndexes.RebuildToUnsignedInt;
var
  c: TArray<byte>;
  i: int32;
  pw: PWord;
  pc: PCardinal;
begin
  if FIndexes.Count < 2 then
    exit;
  c := Self.Copy;
  FIndexes.Count := length(c)*2;
  pw := @c[0];
  pc := FIndexes.ShiftData[0];
  for i := 0 to (length(c) shr 1) - 1 do
  begin
    pc^ := Cardinal(pw^);
    inc(pw);
    inc(pc);
  end;
end;

procedure TListIndexes.SetCapacity(const Value: int32);
begin
  FIndexes.Capacity := Value * FIndexSizeOf;
end;

procedure TListIndexes.SetCount(const Value: int32);
begin
  if (Value > 65536) and (not FKindUnsignedInt) then
    KindUnsignedInt := true;
  FIndexes.Count := Value*FIndexSizeOf;
end;

procedure TListIndexes.SetKindUnsignedInt(const Value: boolean);
begin
  FKindUnsignedInt := Value;
  if FKindUnsignedInt then
  begin
    FIndexSizeOf := 4;
    FKind := GL_UNSIGNED_INT;
    RebuildToUnsignedInt;
  end else
  begin
    FIndexSizeOf := 2;
    FKind := GL_UNSIGNED_SHORT;
  end;
end;

{ TMeshP }

constructor TMeshP.Create;
begin
  inherited;
  ComponentsCount := 1;
  SetLength(Components, 1);
  Components[0] := vcCoordinate;
  OffsetComponent[vcCoordinate] := 0;
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfVertex := SizeOf(TVertexP);
  CountVarComponent[vcCoordinate] := 3;
end;

{ TMeshPI }

constructor TMeshPI.Create;
begin
  inherited;
  ComponentsCount := 2;
  SetLength(Components, 2);
  Components[0] := vcCoordinate;
  Components[1] := vcIndex;
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcIndex] := SizeOf(TVec3f);
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcIndex] := SizeOf(BSFloat);
  SizeOfVertex := SizeOfComponent[vcCoordinate] + SizeOfComponent[vcIndex];
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcIndex] := 1;
end;

{ TMeshPT }

constructor TMeshPT.Create;
begin
  inherited;
  ComponentsCount := 2;
  SetLength(Components, 2);
  Components[0] := vcCoordinate;
  Components[1] := vcTexture1;
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcTexture1] := SizeOf(TVec3f);
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcTexture1] := SizeOf(TVec2f);
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcTexture1] := 2;
  SizeOfVertex := SizeOf(TVertexPT);
end;

{ TMeshPTN }

constructor TMeshPTN.Create;
begin
  inherited;
  ComponentsCount := 3;
  SetLength(Components, 3);
  Components[0] := vcCoordinate;
  Components[1] := vcNormal;
  Components[2] := vcTexture1;
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcNormal] := SizeOf(TVec3f);
  OffsetComponent[vcTexture1] := SizeOf(TVec3f)*2;
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcNormal] := SizeOf(TVec3f);
  SizeOfComponent[vcTexture1] := SizeOf(TVec2f);
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcNormal] := 3;
  CountVarComponent[vcTexture1] := 2;
  SizeOfVertex := SizeOf(TVertexPTN);
end;


{ TMeshPC }

constructor TMeshPC.Create;
begin
  inherited;
  ComponentsCount := 2;
  SetLength(Components, 2);
  Components[0] := vcCoordinate;
  Components[1] := vcColor;
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcColor] := SizeOf(TVec3f);
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcColor] := SizeOf(TVec3f);
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcColor] := 3;
  SizeOfVertex := SizeOf(TVertexPC);
end;

{ TMeshLine }

constructor TMeshLine.Create;
var
  i: int32;
begin
  inherited;
  ComponentsCount := 2;
  SetLength(Components, 2);
  Components[0] := vcCoordinate;
  Components[1] := vcIndex;
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcIndex] := SizeOf(TVec3f);
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcIndex] := SizeOf(BSFloat);
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcIndex] := 1;
  SizeOfVertex := 0;
  for i := 0 to ComponentsCount - 1 do
    SizeOfVertex := SizeOfVertex + SizeOfComponent[Components[i]];
end;

{ TMeshLineMultiColored }

constructor TMeshLineMultiColored.Create;
var
  i: int32;
begin
  inherited;
  ComponentsCount := 3;
  SetLength(Components, 3);
  Components[0] := vcCoordinate;
  Components[1] := vcColor;
  Components[2] := vcIndex;
  SizeOfComponent[vcCoordinate] := SizeOf(TVec3f);
  SizeOfComponent[vcColor] := SizeOf(TVec4f);
  SizeOfComponent[vcIndex] := SizeOf(BSFloat);
  OffsetComponent[vcCoordinate] := 0;
  OffsetComponent[vcColor] := SizeOfComponent[vcCoordinate];
  OffsetComponent[vcIndex] := OffsetComponent[vcColor] + SizeOfComponent[vcColor];
  CountVarComponent[vcCoordinate] := 3;
  CountVarComponent[vcColor] := 4;
  CountVarComponent[vcIndex] := 1;
  SizeOfVertex := 0;
  for i := 0 to ComponentsCount - 1 do
    SizeOfVertex := SizeOfVertex + SizeOfComponent[Components[i]];
end;

end.
