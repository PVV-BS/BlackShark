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


unit bs.frustum;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.basetypes
  , bs.collections
  , bs.mesh
  ;

type


  // L - Left, R - Right, F - Far, T - Top, B - Bottom, N - Near,
  TPointsFrustum = (pfLTF, pfRTF, pfLBF, pfRBF, pfLTN, pfRTN, pfLBN, pfRBN);

  { TBlackSharkFrustum }

  TOnChangeFrustumNotify = procedure({no need parametrs, as, in every scene to creating self frustum}) of object;

  TBlackSharkFrustum = class
  private
    FQuaternion: TQuaternion;
    FOnChangeFrustum: TOnChangeFrustumNotify;
    FOnMoveFrustum: TOnChangeFrustumNotify;
    FScaleRatio: TVec2f;
    RealSize: TVec2f;
    RealSizeHalf: TVec2f;
    FOrthogonalProjection: boolean;
    UpdateCount: int32;
    FAngle: TVec3f;
    // Matrixes transformations
    // shape frustum
    FProjectionMatrix: TMatrix4f;
    FOrthoProjectionMatrix: TMatrix4f;
    // orientation frustum
    FRotateMatrix: TMatrix4f;
    FRotateMatrixInv: TMatrix4f;
    // position
    FTranslateMatrix: TMatrix4f;
    FPosition: TVec3f;
    { View Matrix = FTranslateMatrix * FRotateMatrix }
    FViewMatrix: TMatrix4f;
    FViewMatrixInv: TMatrix4f;
    { ending frustum matrix using for model projection into near side frustum;
      equal FTranslateMatrix * FRotateMatrix * FProjectionMatrix }
    FLastProjViewMat: TMatrix4f;
    { FViewMatrix * FProjectionMatrix; need for calculate ending MVP matrix for
      all models }
    FLastViewProjMat: TMatrix4f;
    FLastOrthoViewProjMat: TMatrix4f;
    FDirection: TVec3f;
    FDistanceFarPlane: BSFloat;
    FDistanceFarPlaneHalf: BSFloat;
    FDistanceNearPlane: BSFloat;
    FDistanceNearPlaneHalf: BSFloat;

    FFrustum: TFrustum;
    FCentreNearPlane: TVec3f;
    FBB: TBox3f;
    FNearPlaneWidth: BSFloat;
    FNearPlaneHeight: BSFloat;
    FNearPlaneHalfHeight: BSFloat;
    FNearPlaneHalfWidth: BSFloat;
    FFarPlaneWidth: BSFloat;
    FFarPlaneHeight: BSFloat;
    FEdgeNearTopNormalize: TVec3f;
    FEdgeNearLeftNormalize: TVec3f;
    FUp: TVec3f;
    FRight: TVec3f;
    FOnAdjustFrustum: TOnChangeFrustumNotify;
    //FNearPlaneNormalized: TPlane;
    procedure GenPerspective;
    procedure GenRotateMatrix;
    procedure GenViewMatrix;
    //procedure NormalizePlanes; inline;
    procedure SetScaleRatio(AValue: TVec2f);
    procedure SetDistanceFarPlane(AValue: BSFloat);
    procedure SetDistanceNearPlane(AValue: BSFloat);
    procedure SetAngle(AValue: TVec3f);
    procedure SetPosition(AValue: TVec3f);
    procedure SetOrthogonalProjection(const Value: boolean);
    procedure SetQuaternion(const Value: TQuaternion);
  public
    const
      // distance from projection plane to fake screen
      DISTANCE_2D_SCREEN      = 0.01;
      // distance between 2 layers on fake 2d screen
      DISTANCE_2D_BW_LAYERS   = 0.0001;
      MAX_COUNT_LAYERS = DISTANCE_2D_SCREEN / DISTANCE_2D_BW_LAYERS;
      FOV_DEFAULT = 30.0;

      {$ifdef DEBUG_BS}
      { for debug mode does abnormal position and orientation for possibility
        to see a bags }
      DEFAULT_POSITION: TVec3f = (x: 0.0; y: 0.0; z: 1.0);
      DEFAULT_DIRECT_ANGLE: TVec3f = (x: 0.0; y: 0.0; z: 0.0);
      {$else}
      DEFAULT_POSITION: TVec3f = (x: 0.0; y: 0.0; z: 1.0);
      DEFAULT_DIRECT_ANGLE: TVec3f = (x: 0.0; y: 0.0; z: 0.0);
      {$endif}
      DEFAULT_NEAR_PLANE: TVec4f = (x: 0.0; y: 0.0; z: 1.0; w: -1.0);
  public
    FPoints: array [TPointsFrustum] of TVec3f;
  public
    constructor Create;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GenerateFrustum;
    function PointInFrustum( const Point: TVec3f ): boolean; overload; inline;
    function PointInFrustum( const Point: TVec3f; out DistanceNearPlane: BSFloat ): boolean; overload; inline;
    function SphereInFrustum( const PointCenter: TVec3f; Radius: BSFloat): boolean;
    function PolygonInFrustum( Points: TListVec<TVec3f> ): boolean;
    function MeshInFrustum( Mesh: TMesh; const ModelMatr: TMatrix4f; out DistanceNearPlane: BSFloat): TCollisionObjects; overload;
    function MeshInFrustum( Mesh: TMesh; const ModelMatr: TMatrix4f; const
      BoxRealInSpace: TBox3f; out DistanceNearPlane: BSFloat): TCollisionObjects; overload;
    function BoxInFrustum( const Box: TBox3f ): boolean;
    { defines a kind intersection Frustum with Box }
    function BoxCollision( const Box: TBox3f ): TCollisionObjects; overload;
    { defines a kind intersection Frustum with Box }
    function BoxCollision( const BoxRealInSpace: TBox3f; Mesh: TMesh; const ModelMatr: TMatrix4f;
      out DistanceNearPlane: BSFloat ): TCollisionObjects; overload;
    { return to DistanceNearPlane minimal a distance to BB }
    function BoxCollisionMin( const Box: TBox3f; out DistanceNearPlane: BSFloat ): TCollisionObjects; inline;
    { return to DistanceNearPlane maximal a distance to BB }
    function BoxCollisionMax( const Box: TBox3f; out DistanceNearPlane: BSFloat ): TCollisionObjects; inline;
    {  }
    property ProjectionMatrix: TMatrix4f read FProjectionMatrix;
    // Frustum arrtibutes
    // Near clipping plane. Keep as big as possible, or you'll get precision issues.
    property DistanceNearPlane: BSFloat read FDistanceNearPlane write SetDistanceNearPlane;
    // Far clipping plane. Keep as little as possible.
    property DistanceFarPlane: BSFloat read FDistanceFarPlane write SetDistanceFarPlane;
    property ScaleRatio: TVec2f read FScaleRatio write SetScaleRatio;
    property ViewMatrix: TMatrix4f read FViewMatrix;
    property ViewMatrixInv: TMatrix4f read FViewMatrixInv;
    property LastViewProjMat: TMatrix4f read FLastViewProjMat;
    property LastOrthoViewProjMat: TMatrix4f read FLastOrthoViewProjMat;
    property RotateMatrixInv: TMatrix4f read FRotateMatrixInv;
    property RotateMatrix: TMatrix4f read FRotateMatrix;

    property BB: TBox3f read FBB;
    property Frustum: TFrustum read FFrustum;
    property Position: TVec3f read FPosition write SetPosition;
    // frustum rotate in direct as clock arrow; if set negative argument - to back
    property Angle: TVec3f read FAngle write SetAngle;
    property Quaternion: TQuaternion read FQuaternion write SetQuaternion;
    property Direction: TVec3f read FDirection;
    property EdgeNearTopNormalize: TVec3f read FEdgeNearTopNormalize;
    property EdgeNearLeftNormalize: TVec3f read FEdgeNearLeftNormalize;
    property CentreNearPlane: TVec3f read FCentreNearPlane;
    { Up direction }
    property Up: TVec3f read FUp;
    { Right direction }
    property Right: TVec3f read FRight;
    property NearPlaneWidth: BSFloat read FNearPlaneWidth;
    property NearPlaneHeight: BSFloat read FNearPlaneHeight;
    property NearPlaneHalfWidth: BSFloat read FNearPlaneHalfWidth;
    property NearPlaneHalfHeight: BSFloat read FNearPlaneHalfHeight;
    property FarPlaneWidth: BSFloat read FFarPlaneWidth;
    property FarPlaneHeight: BSFloat read FFarPlaneHeight;
    { if you have only 2d scene, then better set it true, otherwise can be visible little distortions }
    property OrthogonalProjection: boolean read FOrthogonalProjection write SetOrthogonalProjection;
    // event for optimization to find all objects hit into frustum
    property OnChangeFrustum: TOnChangeFrustumNotify read FOnChangeFrustum write FOnChangeFrustum;
    property OnMoveFrustum: TOnChangeFrustumNotify read FOnMoveFrustum write FOnMoveFrustum;
    property OnAdjustFrustum: TOnChangeFrustumNotify read FOnAdjustFrustum write FOnAdjustFrustum;
  end;


implementation

uses
    bs.math
  , math
  ;

{ TBlackSharkFrustum }

procedure TBlackSharkFrustum.GenViewMatrix;
begin
  FTranslateMatrix.M0 := vec4(1.0, 0.0, 0.0, 0.0);
  FTranslateMatrix.M1 := vec4(0.0, 1.0, 0.0, 0.0);
  FTranslateMatrix.M2 := vec4(0.0, 0.0, 1.0, 0.0);
  //FTranslateMatrix.M3 := vec4(FPosition.x, FPosition.y, FPosition.z, 1.0);
  //FViewMatrixInv := FTranslateMatrix * FRotateMatrixInv;
  FTranslateMatrix.M3 := vec4(-FPosition.x, -FPosition.y, -FPosition.z, 1.0);
  FViewMatrix := FTranslateMatrix * FRotateMatrix;
  FViewMatrixInv := FViewMatrix;
  MatrixInvert(FViewMatrixInv);
end;

function TBlackSharkFrustum.MeshInFrustum(Mesh: TMesh; const ModelMatr: TMatrix4f; const BoxRealInSpace: TBox3f; out DistanceNearPlane: BSFloat): TCollisionObjects;
begin
  Result := MeshInFrustum(Mesh, ModelMatr, DistanceNearPlane);
  if Result = coOutside then
  begin
    if Box3Collision(BoxRealInSpace, FBB) or Box3Inside(BoxRealInSpace, FBB) or PointInFrustum(BoxRealInSpace.Middle) then
      Result := coIntersect;
  end;
end;

function TBlackSharkFrustum.MeshInFrustum(Mesh: TMesh; const ModelMatr: TMatrix4f; out DistanceNearPlane: BSFloat): TCollisionObjects;
var
  v: TVec3f;
  j, c: int32;
  d: BSFloat;
begin
  c := 0;
  DistanceNearPlane := MaxSingle;
  for j := 0 to Mesh.CountVertex - 1 do
  begin
    v := ModelMatr * Mesh.ReadPoint(j);
    if PointInFrustum(v, d) then
      inc(c);
    if d < DistanceNearPlane then
      DistanceNearPlane := d;
  end;
  if c = Mesh.CountVertex then
    Result := coInside
  else
  if c = 0 then
    Result := coOutside
  else
    Result := coIntersect;
end;

procedure TBlackSharkFrustum.GenRotateMatrix;
begin
  if FAngle <> VEC3F_ZERO then
  begin
    FQuaternion := BS.BaseTypes.Quaternion(-FAngle);
    QuaternionToMatrix(FRotateMatrix, FQuaternion);
    QuaternionToMatrix(FRotateMatrixInv, BS.BaseTypes.Quaternion(FAngle));
  end else
  begin
    FQuaternion := vec4(0.0, 0.0, 0.0, 1.0);
    FRotateMatrix := IDENTITY_MAT;
    FRotateMatrixInv := IDENTITY_MAT;
  end;
end;

procedure TBlackSharkFrustum.SetAngle(AValue: TVec3f);
begin
  //if FAngle = AValue then Exit;
  FAngle := AngleEulerClamp3d(AValue);
  GenRotateMatrix;
  GenViewMatrix;
  if UpdateCount = 0 then
  begin
    GenerateFrustum;
    if Assigned(FOnMoveFrustum) then
      FOnMoveFrustum;
  end;
end;

procedure TBlackSharkFrustum.SetPosition(AValue: TVec3f);
begin
  if FPosition = AValue then Exit;
  FPosition := AValue;
  GenViewMatrix;
  if UpdateCount = 0 then
  begin
    GenerateFrustum;
    if Assigned(FOnMoveFrustum) then
      FOnMoveFrustum;
  end;
end;

procedure TBlackSharkFrustum.SetQuaternion(const Value: TQuaternion);
begin
  FQuaternion := Value;
  QuaternionToMatrix(FRotateMatrix, FQuaternion);
  FAngle := QuaternionToAngles(FQuaternion); // ???
  QuaternionToMatrix(FRotateMatrixInv, vec4(-FQuaternion.x, -FQuaternion.y, -FQuaternion.z, FQuaternion.w)); // ???
  GenViewMatrix;
  if UpdateCount = 0 then
  begin
    GenerateFrustum;
    if Assigned(FOnMoveFrustum) then
      FOnMoveFrustum;
  end;
end;

procedure TBlackSharkFrustum.SetScaleRatio(AValue: TVec2f);
begin
  if FScaleRatio = AValue then Exit;
  FScaleRatio := AValue;
  GenPerspective;
  if UpdateCount = 0 then
    GenerateFrustum;
  if Assigned(FOnAdjustFrustum) then
    FOnAdjustFrustum();
end;

procedure TBlackSharkFrustum.SetDistanceFarPlane(AValue: BSFloat);
begin
  if FDistanceFarPlane = AValue then Exit;
  FDistanceFarPlane := AValue;
  FDistanceFarPlaneHalf := FDistanceFarPlane*0.5;
  GenPerspective;
  if UpdateCount = 0 then
    GenerateFrustum;
  if Assigned(FOnAdjustFrustum) then
    FOnAdjustFrustum();
end;

procedure TBlackSharkFrustum.SetDistanceNearPlane(AValue: BSFloat);
begin
  if FDistanceNearPlane = AValue then Exit;
  FDistanceNearPlane := AValue;
  GenPerspective;
  if UpdateCount = 0 then
    GenerateFrustum;
  if Assigned(FOnAdjustFrustum) then
    FOnAdjustFrustum();
end;

procedure TBlackSharkFrustum.SetOrthogonalProjection(const Value: boolean);
begin
  FOrthogonalProjection := Value;
  GenPerspective;
  if UpdateCount = 0 then
    GenerateFrustum;
end;

{procedure TBlackSharkFrustum.SetFOV(AValue: BSFloat);
begin
  if FFOV = AValue then Exit;
  FFOV := AValue;
  GenPerspective;
  GenerateFrustum;
end;}

procedure TBlackSharkFrustum.GenPerspective;
begin
  FProjectionMatrix := IDENTITY_MAT;
  FOrthoProjectionMatrix := IDENTITY_MAT;
  RealSize := vec2(1.0, 1.0) * FScaleRatio;
  RealSizeHalf := RealSize*0.5;
  if FOrthogonalProjection then
  begin
    MatrixOrtho(FProjectionMatrix, -RealSizeHalf.x, RealSizeHalf.x, -RealSizeHalf.y, RealSizeHalf.y, FDistanceNearPlane, FDistanceFarPlane);
    FOrthoProjectionMatrix := FProjectionMatrix;
  end else
  begin
    MatrixOrtho(FOrthoProjectionMatrix, -RealSizeHalf.x, RealSizeHalf.x, -RealSizeHalf.y, RealSizeHalf.y, FDistanceNearPlane, FDistanceFarPlane);
    MatrixPerspective(FProjectionMatrix, -RealSizeHalf.x, RealSizeHalf.x, -RealSizeHalf.y, RealSizeHalf.y, FDistanceNearPlane, FDistanceFarPlane);
  end;
end;

{procedure TBlackSharkFrustum.NormalizePlanes;
var
  d: BSFloat;
  p: TBoxPlanes;
begin
  for p := low(TBoxPlanes) to high(TBoxPlanes) do
  begin
    d := 1 / sqrt( sqr(FFrustum.M[p, 0]) + sqr(FFrustum.M[p, 1]) + sqr(FFrustum.M[p, 2]));
    FFrustum.P[p] := FFrustum.P[p] * d;
  end;
end; }

constructor TBlackSharkFrustum.Create;
begin
  FPosition := DEFAULT_POSITION;
  FDistanceNearPlane:= 1.0;
  FDistanceNearPlaneHalf := FDistanceNearPlane*0.5;
  FScaleRatio := vec2(1.0, 1.0);
  FDistanceFarPlane := 11.0;
  FDistanceFarPlaneHalf := FDistanceFarPlane*0.5;
  FQuaternion := vec4(0.0, 0.0, 0.0, 1.0);
  FRotateMatrix := IDENTITY_MAT;
  FAngle := DEFAULT_DIRECT_ANGLE;
  //FOrtogonalProjection := true;
  GenRotateMatrix;
  GenPerspective;
  GenViewMatrix;
  GenerateFrustum;
end;

procedure TBlackSharkFrustum.EndUpdate;
begin
  dec(UpdateCount);
  if UpdateCount = 0 then
    GenerateFrustum;
end;

procedure TBlackSharkFrustum.GenerateFrustum;
var
  p: TPointsFrustum;
begin
  FLastProjViewMat :=  FTranslateMatrix * FRotateMatrix * FProjectionMatrix;
  FLastViewProjMat := FViewMatrix * FProjectionMatrix;
  if FOrthogonalProjection then
    FLastOrthoViewProjMat := FLastViewProjMat
  else
    FLastOrthoViewProjMat := FViewMatrix * FOrthoProjectionMatrix;
  // Find A, B, C, D for Right Plane
  FFrustum.M[bpRight,  0] := FLastProjViewMat.V[ 3] - FLastProjViewMat.V[ 0];
  FFrustum.M[bpRight,  1] := FLastProjViewMat.V[ 7] - FLastProjViewMat.V[ 4];
  FFrustum.M[bpRight,  2] := FLastProjViewMat.V[11] - FLastProjViewMat.V[ 8];
  FFrustum.M[bpRight,  3] := FLastProjViewMat.V[15] - FLastProjViewMat.V[12];
  // Find A, B, C, D for Left Plane
  FFrustum.M[bpLeft,   0] := FLastProjViewMat.V[ 3] + FLastProjViewMat.V[ 0];
  FFrustum.M[bpLeft,   1] := FLastProjViewMat.V[ 7] + FLastProjViewMat.V[ 4];
  FFrustum.M[bpLeft,   2] := FLastProjViewMat.V[11] + FLastProjViewMat.V[ 8];
  FFrustum.M[bpLeft,   3] := FLastProjViewMat.V[15] + FLastProjViewMat.V[12];
  // Find A, B, C, D for Bottom Plane
  FFrustum.M[bpBottom, 0] := FLastProjViewMat.V[ 3] + FLastProjViewMat.V[ 1];
  FFrustum.M[bpBottom, 1] := FLastProjViewMat.V[ 7] + FLastProjViewMat.V[ 5];
  FFrustum.M[bpBottom, 2] := FLastProjViewMat.V[11] + FLastProjViewMat.V[ 9];
  FFrustum.M[bpBottom, 3] := FLastProjViewMat.V[15] + FLastProjViewMat.V[13];
  // Top Plane
  FFrustum.M[bpTop,    0] := FLastProjViewMat.V[ 3] - FLastProjViewMat.V[ 1];
  FFrustum.M[bpTop,    1] := FLastProjViewMat.V[ 7] - FLastProjViewMat.V[ 5];
  FFrustum.M[bpTop,    2] := FLastProjViewMat.V[11] - FLastProjViewMat.V[ 9];
  FFrustum.M[bpTop,    3] := FLastProjViewMat.V[15] - FLastProjViewMat.V[13];
  // Far Plane
  FFrustum.M[bpFar,    0] := FLastProjViewMat.V[ 3] - FLastProjViewMat.V[ 2];
  FFrustum.M[bpFar,    1] := FLastProjViewMat.V[ 7] - FLastProjViewMat.V[ 6];
  FFrustum.M[bpFar,    2] := FLastProjViewMat.V[11] - FLastProjViewMat.V[10];
  FFrustum.M[bpFar,    3] := FLastProjViewMat.V[15] - FLastProjViewMat.V[14];
  // Near Plane
  FFrustum.M[bpNear,   0] := FLastProjViewMat.V[ 3] + FLastProjViewMat.V[ 2];
  FFrustum.M[bpNear,   1] := FLastProjViewMat.V[ 7] + FLastProjViewMat.V[ 6];
  FFrustum.M[bpNear,   2] := FLastProjViewMat.V[11] + FLastProjViewMat.V[10];
  FFrustum.M[bpNear,   3] := FLastProjViewMat.V[15] + FLastProjViewMat.V[14];

  //NormalazePlanes;

  //FLastProjViewMat :=  FViewMatrix * FRotateMatrix * FProjectionMatrix; //FViewMatrix
  //FLastProjViewMat := FViewMatrix * FProjectionMatrix;

  FPoints[pfLTF] := FViewMatrixInv*vec3(-FDistanceFarPlaneHalf*FScaleRatio.x,  FDistanceFarPlaneHalf*FScaleRatio.y, -FDistanceFarPlane); //PlaneCrossProduct(FFrustum.P[bpLeft ], FFrustum.P[bpTop   ], FFrustum.P[bpFar ], b);
  FPoints[pfRTF] := FViewMatrixInv*vec3( FDistanceFarPlaneHalf*FScaleRatio.x,  FDistanceFarPlaneHalf*FScaleRatio.y, -FDistanceFarPlane);
  FPoints[pfLBF] := FViewMatrixInv*vec3(-FDistanceFarPlaneHalf*FScaleRatio.x, -FDistanceFarPlaneHalf*FScaleRatio.y, -FDistanceFarPlane);
  FPoints[pfRBF] := FViewMatrixInv*vec3( FDistanceFarPlaneHalf*FScaleRatio.x, -FDistanceFarPlaneHalf*FScaleRatio.y, -FDistanceFarPlane);

  FPoints[pfLTN] := FViewMatrixInv*vec3(-FDistanceNearPlaneHalf*FScaleRatio.x,  FDistanceNearPlaneHalf*FScaleRatio.y, -FDistanceNearPlane); //PlaneCrossProduct(FFrustum.P[bpLeft ], FFrustum.P[bpTop   ], FFrustum.P[bpNear], b);
  FPoints[pfRTN] := FViewMatrixInv*vec3( FDistanceNearPlaneHalf*FScaleRatio.x,  FDistanceNearPlaneHalf*FScaleRatio.y, -FDistanceNearPlane);
  FPoints[pfLBN] := FViewMatrixInv*vec3(-FDistanceNearPlaneHalf*FScaleRatio.x, -FDistanceNearPlaneHalf*FScaleRatio.y, -FDistanceNearPlane);
  FPoints[pfRBN] := FViewMatrixInv*vec3( FDistanceNearPlaneHalf*FScaleRatio.x, -FDistanceNearPlaneHalf*FScaleRatio.y, -FDistanceNearPlane);

  FDirection := VecNormalize(vec3(FFrustum.M[bpNear, 0], FFrustum.M[bpNear, 1], FFrustum.M[bpNear, 2])); //

  FNearPlaneWidth      := FDistanceNearPlane*FScaleRatio.x;
  FNearPlaneHeight     := FDistanceNearPlane*FScaleRatio.y;
  FNearPlaneHalfWidth  := FNearPlaneWidth *0.5;
  FNearPlaneHalfHeight := FNearPlaneHeight*0.5;
  FFarPlaneWidth       := FDistanceFarPlane*FScaleRatio.x;
  FFarPlaneHeight      := FDistanceFarPlane*FScaleRatio.y;

  FEdgeNearTopNormalize := VecNormalize(FPoints[TPointsFrustum.pfRTN] - FPoints[TPointsFrustum.pfLTN]);
  FEdgeNearLeftNormalize := VecNormalize(FPoints[TPointsFrustum.pfLTN] - FPoints[TPointsFrustum.pfLBN]);
  FUp := FEdgeNearLeftNormalize;
  FRight := FEdgeNearTopNormalize;
  //FDistanceBetweenNearAndFar := VectorLen(FPoints[pfRTF] - FPoints[pfRBN]);

  FCentreNearPlane := (FPoints[pfRBN] + FPoints[pfLTN]) * 0.5;
  //FCentreNearPlane.z := FCentreNearPlane.z - DISTANCE_2D_SCREEN;
  FBB.Min := FPoints[low(p)];
  FBB.Max := FBB.Min;

  for p := TPointsFrustum(int8(low(p))+1) to high(p) do
  begin
    if FPoints[p].x < FBB.Min.x then
      FBB.Min.x := FPoints[p].x;
    if FPoints[p].y < FBB.Min.y then
      FBB.Min.y := FPoints[p].y;
    if FPoints[p].z < FBB.Min.z then
      FBB.Min.z := FPoints[p].z;

    if FPoints[p].x > FBB.Max.x then
      FBB.Max.x := FPoints[p].x;
    if FPoints[p].y > FBB.Max.y then
      FBB.Max.y := FPoints[p].y;
    if FPoints[p].z > FBB.Max.z then
      FBB.Max.z := FPoints[p].z;
  end;
  FBB.Middle := Box3Middle(FBB);  //  FViewMatrix *
  if Assigned(FOnChangeFrustum) then
    FOnChangeFrustum;
end;

function TBlackSharkFrustum.PointInFrustum(const Point: TVec3f): boolean;
var
  p: TBoxPlanes;
begin
  for p := low(TBoxPlanes) to high(TBoxPlanes) do
    if (FFrustum.M[p, 0] * Point.x + FFrustum.M[p, 1] * Point.y + FFrustum.M[p, 2] * Point.z + FFrustum.M[p, 3] < 0) then
      exit(false);
  Result := true;
end;

function TBlackSharkFrustum.PointInFrustum(const Point: TVec3f; out DistanceNearPlane: BSFloat): boolean;
var
  p: TBoxPlanes;
begin
  DistanceNearPlane :=
  	FFrustum.M[TBoxPlanes.bpNear, 0] * Point.x +
  	FFrustum.M[TBoxPlanes.bpNear, 1] * Point.y +
    FFrustum.M[TBoxPlanes.bpNear, 2] * Point.z +
    FFrustum.M[TBoxPlanes.bpNear, 3];
  if DistanceNearPlane < 0 then
    exit(false);
  for p := TBoxPlanes.bpFar to high(TBoxPlanes) do
    if (FFrustum.M[p, 0] * Point.x + FFrustum.M[p, 1] * Point.y + FFrustum.M[p, 2] * Point.z + FFrustum.M[p, 3] < 0) then
      exit(false);
  Result := true;
end;

function TBlackSharkFrustum.SphereInFrustum(const PointCenter: TVec3f; Radius: BSFloat): boolean;
var
  p: TBoxPlanes;
begin
  for p := low(TBoxPlanes) to high(TBoxPlanes) do
    if (FFrustum.M[p, 0] * PointCenter.x + FFrustum.M[p, 1] * PointCenter.y + FFrustum.M[p, 2] * PointCenter.z + FFrustum.M[p, 3] <= Radius) then
      exit(false);
  Result := true;
end;

function TBlackSharkFrustum.PolygonInFrustum(Points: TListVec<TVec3f>): boolean;
var
  p: TBoxPlanes;
  i: int8;
  v: TVec3f;
  b: boolean;
begin
  for p := low(TBoxPlanes) to high(TBoxPlanes) do
  begin
    b := true;
    for i := 0 to Points.Count - 1 do
    begin
      v := Points.Items[i];
      if( FFrustum.M[p, 0] * v.x + FFrustum.M[p, 1] * v.y + FFrustum.M[p, 2] * v.z + FFrustum.M[p, 3] > 0 ) then
      begin
        b := false;
        break;
      end;
    end;
    if b then
      exit(false);
  end;
  Result := true;
end;

function TBlackSharkFrustum.BoxInFrustum(const Box: TBox3f): boolean;
var
  p: TBoxPlanes;
begin
  for p := low(TBoxPlanes) to high(TBoxPlanes) do
  begin
    if (FFrustum.M[p, 0] * Box.MinMaxMid[int8(FFrustum.M[p, 0] >= 0)].x +
        FFrustum.M[p, 1] * Box.MinMaxMid[int8(FFrustum.M[p, 1] >= 0)].y +
        FFrustum.M[p, 2] * Box.MinMaxMid[int8(FFrustum.M[p, 2] >= 0)].z + FFrustum.M[p, 3] < 0) then
      exit(false);
  end;
  Result := true;
end;

procedure TBlackSharkFrustum.BeginUpdate;
begin
  inc(UpdateCount);
end;

function TBlackSharkFrustum.BoxCollision(const Box: TBox3f): TCollisionObjects;
var
  c: int8;
begin
  c := 0;
  if PointInFrustum(Box.Min) then
    inc(c);
  if PointInFrustum(Box.Max) then
    inc(c);
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Min.z)) then
    inc(c);
  if PointInFrustum(Vec3(Box.Min.x, Box.Min.y, Box.Max.z)) then
    inc(c);
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Max.z)) then
    inc(c);
  if PointInFrustum(Vec3(Box.Max.x, Box.Max.y, Box.Min.z)) then
    inc(c);
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Max.z)) then
    inc(c);
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Min.z)) then
    inc(c);
  if c = 8 then
    Result := coInside
  else
  if c = 0 then
  begin
    if Box3Collision(Box, FBB) or Box3Inside(Box, FBB) or PointInFrustum(Box.Middle) then
    {if Box3Collision(Box, @FBB) then
      Result := coIntersect else
    if Box3Inside(Box, @FBB) then
      Result := coIntersect else
    if PointInFrustum(Box^.Middle) then}
      Result := coIntersect
    else
      Result := coOutside;
  end else
    Result := coIntersect;
end;

function TBlackSharkFrustum.BoxCollisionMin(const Box: TBox3f; out DistanceNearPlane: BSFloat): TCollisionObjects;
var
  c: int8;
  d: BSFloat;
begin
  c := 0;

  if PointInFrustum(Box.Min, DistanceNearPlane) then
    inc(c);
  if PointInFrustum(Box.Max, d) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Min.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Min.y, Box.Max.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Max.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Max.y, Box.Min.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Max.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Min.z)) then
    inc(c);
  if abs(DistanceNearPlane) > abs(d) then
    DistanceNearPlane := d;
//  if (DistanceNearPlane > FDistanceFarPlane) then
//    Result := coOutside
//  else
  if c = 8 then
    Result := coInside
  else
  if c = 0 then
  begin
    if Box3Collision(Box, FBB) or Box3Inside(Box, FBB) or PointInFrustum(Box.Middle) then
      Result := coIntersect
    else
      Result := coOutside;
  end else
    Result := coIntersect;
end;

function TBlackSharkFrustum.BoxCollision(const BoxRealInSpace: TBox3f; Mesh: TMesh; const ModelMatr: TMatrix4f; out DistanceNearPlane: BSFloat): TCollisionObjects;
var
  c: int8;
  d: BSFloat;
begin
  c := 0;
  // check if shape is plane
  if Mesh.FBoundingBox.x_max = 0 then
  begin
    if PointInFrustum(ModelMatr*vec3(0.0, Mesh.FBoundingBox.y_min, Mesh.FBoundingBox.z_min), DistanceNearPlane) then
      inc(c);
    if PointInFrustum(ModelMatr*vec3(0.0, Mesh.FBoundingBox.y_max, Mesh.FBoundingBox.z_min), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(0.0, Mesh.FBoundingBox.y_max, Mesh.FBoundingBox.z_max), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(0.0, Mesh.FBoundingBox.y_min, Mesh.FBoundingBox.z_max), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
//    if (DistanceNearPlane > FDistanceFarPlane) then
//      Result := coOutside
//    else
    if c = 4 then
      Result := coInside else
    if c = 0 then
    begin
      if Box3Collision(BoxRealInSpace, FBB) or Box3Inside(BoxRealInSpace, FBB) or PointInFrustum(BoxRealInSpace.Middle) then
        Result := coIntersect
      else
        Result := coOutside;
    end else
      Result := coIntersect;
  end else
  if Mesh.FBoundingBox.y_max = 0 then
  begin
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_min, 0.0, Mesh.FBoundingBox.z_min), DistanceNearPlane) then
      inc(c);
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_max, 0.0, Mesh.FBoundingBox.z_min), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_max, 0.0, Mesh.FBoundingBox.z_max), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_min, 0.0, Mesh.FBoundingBox.z_max), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
//    if (DistanceNearPlane > FDistanceFarPlane) then
//      Result := coOutside
//    else
    if c = 4 then
      Result := coInside
    else
    if c = 0 then
    begin
      if Box3Collision(BoxRealInSpace, FBB) or Box3Inside(BoxRealInSpace, FBB) or PointInFrustum(BoxRealInSpace.Middle) then
        Result := coIntersect
      else
        Result := coOutside;
    end else
      Result := coIntersect;
  end else
  if Mesh.FBoundingBox.z_max = 0 then
  begin
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_min, Mesh.FBoundingBox.y_min, 0.0), DistanceNearPlane) then
      inc(c);
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_max, Mesh.FBoundingBox.y_min, 0.0), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_max, Mesh.FBoundingBox.y_max, 0.0), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
    if PointInFrustum(ModelMatr*vec3(Mesh.FBoundingBox.x_min, Mesh.FBoundingBox.y_max, 0.0), d) then
      inc(c);
    if abs(DistanceNearPlane) > abs(d) then
      DistanceNearPlane := d;
//    if (DistanceNearPlane > FDistanceFarPlane) then
//      Result := coOutside
//    else
    if c = 4 then
      Result := coInside
    else
    if c = 0 then
    begin
      if Box3Collision(BoxRealInSpace, FBB) or Box3Inside(BoxRealInSpace, FBB) or PointInFrustum(BoxRealInSpace.Middle) then
        Result := coIntersect
      else
        Result := coOutside;
    end else
      Result := coIntersect;
  end else
  begin
    Result := BoxCollisionMin(BoxRealInSpace, DistanceNearPlane);
  end;
end;

function TBlackSharkFrustum.BoxCollisionMax(const Box: TBox3f; out DistanceNearPlane: BSFloat): TCollisionObjects;
var
  c: int8;
  d: BSFloat;
begin
  c := 0;
  if PointInFrustum(Box.Min, DistanceNearPlane) then
    inc(c);
  if PointInFrustum(Box.Max, d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Min.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Min.y, Box.Max.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Min.y, Box.Max.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Max.x, Box.Max.y, Box.Min.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Max.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if PointInFrustum(Vec3(Box.Min.x, Box.Max.y, Box.Min.z), d) then
    inc(c);
  if DistanceNearPlane < d then
    DistanceNearPlane := d;
  if c = 8 then
    Result := coInside
  else
  if c = 0 then
  begin
    if Box3Collision(Box, FBB) or Box3Inside(Box, FBB) or PointInFrustum(Box.Middle) then
      Result := coIntersect
    else
      Result := coOutside;
  end else
    Result := coIntersect;
end;

end.

