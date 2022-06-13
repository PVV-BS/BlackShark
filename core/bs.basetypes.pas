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


unit bs.basetypes;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , types
  , bs.math
  ;

const
  MEGABYTE = 1024*1024;


type

  BSFloat = single; //double
  PBSFloat = ^BSFloat;
  BSInt = int32;
  BSInt64 = int64;
  BSShort = SmallInt;
  BSByte = byte;

  { TVec2f }

  TVec2f = record
    class operator Add      (const v1, v2: TVec2f): TVec2f; inline;
    class operator Add      (const v: TVec2f; const a: BSFloat): TVec2f; inline;
    class operator Subtract (const v1, v2: TVec2f): TVec2f;  inline;
    class operator Subtract (const v: TVec2f; const a: BSFloat): TVec2f;  inline;
    class operator Negative (const v: TVec2f): TVec2f;  inline;
    class operator Multiply (const v1, v2: TVec2f): TVec2f;  inline;
    class operator Multiply (const v: TVec2f; k: BSFloat): TVec2f;  inline;
    class operator Divide   (const v1, v2: TVec2f): TVec2f;  inline;
    class operator Divide   (const v: TVec2f; k: BSFloat): TVec2f;  inline;
    class operator Equal    (const v1, v2: TVec2f): boolean; inline;
    case byte of
    0: (x, y: BSFloat);
    1: (left, right: BSFloat);
    2: (Width, Height: BSFloat);
    3: (xy: array[boolean] of BSFloat);
  end;

  { TVec2d }

  TVec2d = record
    class operator Add      (const v1, v2: TVec2d): TVec2d; inline;
    class operator Subtract (const v1, v2: TVec2d): TVec2d;  inline;
    class operator Implicit (const v: TVec2f): TVec2d; inline;
    class operator Implicit (const v: TVec2d): TVec2f; inline;
    class operator Equal    (const v1, v2: TVec2d): boolean; inline;
    class operator Multiply (const v: TVec2d; k: double): TVec2d;  inline;
    case byte of
    0: (x, y: double);
    1: (left, right: double);
    2: (Width, Height: double);
    3: (xy: array[boolean] of double);
  end;

  { TVec3i }

  TVec3i = record
    x, y, z: BSInt;
    class operator Add      (const v1, v2: TVec3i): TVec3i;  inline;
    class operator Subtract (const v1, v2: TVec3i): TVec3i;  inline;
    class operator Multiply (const v1, v2: TVec3i): TVec3i;  inline;
    class operator Divide   (const v1, v2: TVec3i): TVec3i;  inline;
  end;

  { TVec3b }

  TVec3b = record
    x, y, z: Byte;
    class operator Add      (const v1, v2: TVec3b): TVec3b;  inline;
    class operator Subtract (const v1, v2: TVec3b): TVec3b;  inline;
    class operator Multiply (const v1, v2: TVec3b): TVec3b;  inline;
    class operator Divide   (const v1, v2: TVec3b): TVec3b;  inline;
  end;

  { TVec4f }

  TVec4f = record
    class operator Add      (const v1, v2: TVec4f): TVec4f;  inline;
    class operator Subtract (const v1, v2: TVec4f): TVec4f;  inline;
    class operator Negative (const v: TVec4f): TVec4f;  inline;
    class operator Multiply (const v1, v2: TVec4f): TVec4f;  inline;
    class operator Multiply (const v: TVec4f; const k: BSFloat): TVec4f; inline;
    class operator Divide   (const v1, v2: TVec4f): TVec4f;  inline;
    class operator Divide   (const v: TVec4f; const k: BSFloat): TVec4f;  inline;
    class operator Divide   (const v: TVec4f; const k: int32): TVec4f;  inline;
    class operator Equal    (const v1, v2: TVec4f): boolean; inline;
    case int8 of
    0: (x, y, z, w: BSFloat);
    2: (v2f1, v2f2: TVec2f);
    3: (rgba: array[0..3] of BSFloat);
    4: (xyz: array[0..2] of BSFloat; alpha: BSFloat);
    5: (xy: TVec2f; zw: TVec2f);
  end;

  { TVec4d }

  TVec4d = record
    class operator Add      (const v1, v2: TVec4d): TVec4d; inline;
    class operator Add      (const v1: TVec4d; const v2: TVec4f): TVec4d; inline;
    class operator Subtract (const v1, v2: TVec4d): TVec4d; inline;
    class operator Negative (const v: TVec4d): TVec4d; inline;
    class operator Multiply (const v1, v2: TVec4d): TVec4d;  inline;
    class operator Multiply (const v: TVec4d; const k: BSFloat): TVec4d; inline;
    class operator Divide   (const v1, v2: TVec4d): TVec4d;  inline;
    class operator Divide   (const v: TVec4d; const k: BSFloat): TVec4d;  inline;
    class operator Divide   (const v: TVec4d; const k: int32): TVec4d;  inline;
    class operator Equal    (const v1, v2: TVec4d): boolean; inline;
    class operator Implicit (const v: TVec4f): TVec4d; inline;
    class operator Implicit (const v: TVec4d): TVec4f; inline;
    case int8 of
    0: (x, y, z, w: double);
    1: (r, g, b, a: double);
    2: (v2f1, v2f2: TVec2d);
  end;

  { TVec4b }

  TVec4b = record
    class operator Add (const v1, v2: TVec4b): TVec4b;  inline;
    class operator Add (const v1: TVec4d; const v2: TVec4b): TVec4d;  inline;
    class operator Subtract (const v1, v2: TVec4b): TVec4b;  inline;
    class operator Multiply (const v1, v2: TVec4b): TVec4b;  inline;
    class operator Multiply (const v: TVec4b; k: BSFloat): TVec4b; inline;
    class operator Multiply (const v: TVec4b; k: BSbyte): TVec4b;  inline;
    class operator Divide   (const v1, v2: TVec4b): TVec4b;  inline;
    class operator Divide   (const v: TVec4b; const k: BSInt): TVec4b;   inline;
    class operator Divide   (const v: TVec4b; const k: BSFloat): TVec4b; inline;
    class operator Equal    (const v1, v2: TVec4b): boolean; inline;
    class operator Implicit (const v: TVec4f): TVec4b; inline;
    class operator Implicit (const v: TVec4d): TVec4b; inline;
    class operator Implicit (const v: TVec4b): TVec4d; inline;
    class operator Implicit (const v: uint32): TVec4b; inline;
    case byte of
    0: (x, y, z, w: byte);
    1: (r, g, b, a: byte);
    2: (value: uint32);
  end;

  { TVec4i }

  TVec4i = record
    class operator Add      (const v1, v2: TVec4i): TVec4i;  inline;
    class operator Add      (const v1: TVec4i; v2: TVec4b): TVec4i;  inline;
    class operator Add      (const v1: TVec4d; const v2: TVec4i): TVec4d;  inline;
    class operator Subtract (const v1, v2: TVec4i): TVec4i;  inline;
    class operator Multiply (const v1, v2: TVec4i): TVec4i;  inline;
    class operator Multiply (const v: TVec4i; k: BSFloat): TVec4f; inline;
    class operator Multiply (const v: TVec4i; k: int32): TVec4i; inline;
    class operator Divide   (const v1, v2: TVec4i): TVec4i;  inline;
    class operator Divide   (const v: TVec4i; const k: BSInt): TVec4i;   inline;
    class operator Divide   (const v: TVec4i; const k: BSFloat): TVec4i; inline;
    class operator Implicit (const v: TVec4i): TVec4b; inline;
    class operator Implicit (const v: TVec4b): TVec4i; inline;
    class operator Implicit (const v: TVec4f): TVec4i; inline;
    case int8 of
    0: (x, y, z, w: BSInt);
    1: (r, g, b, a: BSInt);
  end;

  { TVec2i64 }

  TVec2i64 = record
    x, y: int64;
    class operator Implicit (const v: TVec2i64): TVec2d; inline;
    class operator Implicit (const v: TVec2i64): TVec2f; inline;
    class operator Implicit (const v: TVec2f): TVec2i64; inline;
    class operator Implicit (const v: TVec2d): TVec2i64; inline;
  end;

  { TVec2i }

  TVec2i = record
    class operator Add      (const v1, v2: TVec2i): TVec2i;  inline;
    class operator Add      (const v: TVec2i; const a: BSInt): TVec2i; inline;
    class operator Subtract (const v1, v2: TVec2i): TVec2i;  inline;
    class operator Subtract (const v: TVec2i; const a: BSInt): TVec2i;  inline;
    class operator Multiply (const v1, v2: TVec2i): TVec2i;  inline;
    class operator Multiply (const v: TVec2i; const k: BSFloat): TVec2i;  inline;
    class operator Multiply (const v: TVec2i; const k: int32): TVec2i;  inline;
    class operator Divide   (const v1, v2: TVec2i): TVec2i;  inline;
    class operator Divide   (const v: TVec2i; const k: BSInt): TVec2i;   inline;
    class operator Divide   (const v: TVec2i; const k: BSFloat): TVec2i; inline;
    class operator Equal    (const v1, v2: TVec2i): boolean; inline;
    class operator Implicit (const v: TVec2f): TVec2i; inline;
    class operator Implicit (const v: TVec2i): TVec2f; inline;
    class operator Implicit (const v: TVec2i64): TVec2i; inline;
    case int8 of
    0: (x, y: BSInt);
    1: (Point: TPoint);
  end;

  { TVec2ui }

  TVec2ui = record
    x, y: UInt32;
    class operator Explicit(const v: TVec2ui): TVec2f;
  end;

  { TVec3f }

  TVec3f = record
    class operator Add      (const v1, v2: TVec3f): TVec3f;  inline;
    class operator Add      (const v: TVec3f; k: BSFloat): TVec3f;  inline;
    class operator Subtract (const v1, v2: TVec3f): TVec3f;  inline;
    class operator Negative (const v: TVec3f): TVec3f;  inline;
    class operator Multiply (const v1, v2: TVec3f): TVec3f;  inline;
    class operator Multiply (const v: TVec3f; const k: BSFloat): TVec3f; inline;
    class operator Divide   (const v1, v2: TVec3f): TVec3f;  inline;
    class operator Divide   (const v: TVec3f; const k: BSFloat): TVec3f; inline;
    class operator Equal    (const v1, v2: TVec3f): boolean; inline;
    class operator NotEqual (const v1, v2: TVec3f): boolean; inline;
    class operator Implicit (const v: TVec3f): TVec4f; inline;
    class operator Implicit (const v: TVec2f): TVec3f; inline;
    class operator Explicit (const v: TVec4f): TVec3f; inline;
    class operator Explicit (const v: TVec3f): TVec2f; inline;
    class operator Explicit (const v: TVec3f): TVec3i; inline;
    class operator Explicit (const v: TVec3f): TVec2i; inline;
    case int8 of
    0: (x, y, z: BSFloat);
    1: (p: array[0..2] of BSFloat);
    2: (r, g, b: BSFloat);
    3: (h, l, s: BSFloat);
  end;

  //TVec3<T> = record;

  {$if sizeof(BSFloat) <> sizeof(double)}
  TVec3d = record
    class operator Divide   (const v: TVec3d; const k: double): TVec3d; inline;
    class operator Multiply (const v1, v2: TVec3d): TVec3d;  inline;
    class operator Multiply (const v: TVec3d; const k: double): TVec3d; inline;
    class operator Multiply (const v1: TVec3f; const v2: TVec3d): TVec3d; inline;
    class operator Equal    (const v1, v2: TVec3d): boolean; inline;
    class operator NotEqual (const v1, v2: TVec3d): boolean; inline;
    class operator Add      (const v1, v2: TVec3d): TVec3d; inline;
    class operator Subtract (const v1, v2: TVec3d): TVec3d;  inline;
    class operator Subtract (const v1: TVec3f; const v2: TVec3d): TVec3f;  inline;
    class operator Explicit (const v: TVec3d): TVec2f; inline;
    class operator Implicit (const v: TVec3f): TVec3d; inline;
    class operator Explicit (const v: TVec3d): TVec3f; inline;
    case int8 of
    0: (x, y, z: double);
    1: (p: array[0..2] of double);
  end;
  {$else}
  TVec3d = TVec3f;
  {$endif}

  TPlane = TVec4f;

  PVec2f = ^TVec2f;
  PVec3f = ^TVec3f;
  PVec4f = ^TVec4f;
  PVec2i = ^TVec2i;
  PVec3i = ^TVec3i;
  PVec4i = ^TVec4i;
  PVec3b = ^TVec3b;
  PVec4b = ^TVec4b;

  TArrayVec4b  = array[0..$0FFFFFFF] of TVec4b;
  PArrayVec4b  = ^TArrayVec4b;
  TArrayVec3f  = array[0..$FFFFFF] of TVec3f;
  PArrayVec3f  = ^TArrayVec3f;
  TArrayVec2f  = array[0..$FFFFFF] of TVec2f;
  PArrayVec2f  = ^TArrayVec2f;
  TArrayVec2i  = array[0..$FFFFFF] of TVec2i;
  PArrayVec2i  = ^TArrayVec2i;
  TArrayShorti = array[0..$FFFFFF] of Smallint;
  PArrayShorti = ^TArrayShorti;

  PTriangle3f = ^TTriangle3f;
  TTriangle3f = record
    case int8 of
    0: (A, B, C: TVec3f);
    1: (Points: array[0..2] of TVec3f);
  end;

  PTriangle2f = ^TTriangle2f;
  TTriangle2f = record
    case int8 of
    0: (A, B, C: TVec2f);
    1: (Points: array[0..2] of TVec2f);
  end;

  TRectBSf = record
    case byte of
      0: (U, V, DeltaU, DeltaV: BSFloat);
      1: (X, Y, DeltaX, DeltaY: BSFloat);
      2: (Left, Top, Width, Height: BSFloat);
      3: (Position, Size: TVec2f);
  end;

  TRectBSi = record
    class operator Implicit (const A: TRectBSi): TRectBSf; inline;
    class operator Implicit (const A: TRectBSf): TRectBSi; inline;
    case byte of
      0: (U, V, DeltaU, DeltaV: int32);
      1: (X, Y, DeltaX, DeltaY: int32);
      2: (Left, Top, Width, Height: int32);
      3: (Position: TVec2i; Size: TVec2i);
  end;

  TRectBSi64 = record
    function Contain(const Pos: TVec2i64): boolean; overload;
    function Contain(const PosX, PosY: int64): boolean; overload;
    class operator Implicit (const A: TRectBSi64): TRectBSf; inline;
    class operator Implicit (const A: TRectBSf): TRectBSi64; inline;
    case byte of
      0: (U, V, DeltaU, DeltaV: int64);
      1: (X, Y, DeltaX, DeltaY: int64);
      2: (Left, Top, Width, Height: int64);
      3: (Position: TVec2i64; Size: TVec2i64);
  end;

  TRectBSd = record
    class operator Implicit (const A: TRectBSd): TRectBSf; inline;
    class operator Implicit (const A: TRectBSf): TRectBSd; inline;
    case byte of
      0: (U, V, DeltaU, DeltaV: double);
      1: (X, Y, DeltaX, DeltaY: double);
      2: (Left, Top, Width, Height: double);
      3: (Position, Size: TVec2d);
  end;

  { TMatrix2f }

  TMatrix2f = record
    class operator Multiply(const M: TMatrix2f; const V: TVec2f): TVec2f; inline;
    class operator Multiply(const M: TMatrix2f; const V: TVec3f): TVec3f; inline;
    case byte of
      0: (M: array[0..1, 0..1] of BSFloat);
      1: (V1, V2: TVec2f);
      2: (V: array[0..3] of BSFloat);
  end;

  { TMatrix3f }

  PMatrix3f = ^TMatrix3f;
  TMatrix3f = record
    class operator Multiply(const M: TMatrix3f; const k: BSFloat): TMatrix3f; inline;
    class operator Multiply(const A, B: TMatrix3f): TMatrix3f; inline;
    class operator Multiply(const M: TMatrix3f; const V: TVec3f): TVec3f; inline;
    class operator Multiply(const M: TMatrix3f; const V: TVec2f): TVec2f; inline;
    class operator Multiply (const V: TVec3f; const M: TMatrix3f): TVec3f; inline;
    case byte of
      0: (M: array[0..2, 0..2] of BSFloat);
      1: (M0, M1, M2: TVec3f);
      2: (V: array[0..8] of BSFloat);
      3: (V3: array[0..2] of TVec3f);
  end;

  { TMatrix4f }

  PMatrix4f = ^TMatrix4f;
  TMatrix4f = record
    class operator Add (const A, B: TMatrix4f): TMatrix4f; inline;
    class operator Subtract (const A, B: TMatrix4f): TMatrix4f; inline;
    class operator Multiply (const A: TMatrix4f; const B: TVec3f): TVec3f; inline;
    {$if sizeof(BSFloat) <> sizeof(double)}
    class operator Multiply (const A: TMatrix4f; const B: TVec3d): TVec3d; inline;
    {$endif}
    class operator Multiply (const A: TMatrix4f; const B: TVec4f): TMatrix4f; inline;
    class operator Multiply (const A: TMatrix4f; const k: BSFloat): TMatrix4f; inline;
    class operator Multiply (const A, B: TMatrix4f): TMatrix4f; inline;
    class operator Divide (const A, B: TMatrix4f): TMatrix4f; inline;
    class operator Implicit (const A: TMatrix4f): TMatrix3f; inline;
    class operator Explicit (const A: TMatrix3f): TMatrix4f; inline;
    case byte of
      0: (M: array[0..3, 0..3] of BSFloat);
      1: (M0, M1, M2, M3: TVec4f);
      2: (V: array[0..15] of BSFloat);
      3: (V4: array[0..3] of TVec4f);
  end;

  TMatrix4b = record
    case byte of
      0: (M: array[0..3, 0..3] of BSByte);
  end;

  PBox3f = ^TBox3f;
  PBox3d = ^TBox3d;

  TBBPoints = (
    pXminYminZmax, pXminYmaxZmax, pXmaxYmaxZmax, pXmaxYminZmax,
    pXminYminZmin, pXminYmaxZmin, pXmaxYmaxZmin, pXmaxYminZmin
  );

  TTypePrimitive = (tpTriangles, tpTriangleFan, tpTriangleStrip, tpQuad, tpLines, tpLineStrip);

  TBoxPlanes = (bpNear, bpFar, bpRight, bpLeft, bpBottom, bpTop);

  TBBLimits = (xMin, yMin, zMin, xMax, yMax, zMax, xMid, yMid, zMid);

  TBBLimitPoint = array[0..2] of TBBLimits;

  TAxis3D = (AxleX, AxleY, AxleZ);
  TAxisSet = set of TAxis3D;

  TDimension = Int8;

  TInterpolateSpline = (isNone, isBezier, isCubic, isCubicHermite);

  { TBox3f }

  TBox3f = record // <T>
    IsPoint: boolean;
    TagPtr: Pointer;
    class operator Multiply (const ABox: TBox3f; const k: BSFloat): TBox3f; inline;
    case byte of
    0: (V0, V1, Middle: TVec3f);
    1: (p: array[0..9] of BSFloat);
    2: (p2: array[0..2, 0..2] of BSFloat);
    3: (x_min, y_min, z_min, x_max, y_max, z_max, x_mid, y_mid, z_mid: BSFloat);
    4: (Min, Max, Mid: TVec3f);
    5: (MinMaxMid: array[0..2] of TVec3f);
    6: (Named: array[TBBLimits] of BSFloat);
  end;

  { TBox3d }

  TBox3d = record // <T>
    IsPoint: boolean;
    TagPtr: Pointer;
    class operator Explicit (const B: TBox3d): TBox3f; inline;
    case byte of
    0: (V0, V1, Middle: TVec3d);
    3: (x_min, y_min, z_min, x_max, y_max, z_max, x_mid, y_mid, z_mid: double);
    4: (Min, Max, Mid: TVec3d);
    5: (MinMaxMid: array[0..2] of TVec3d);
    6: (Named: array[TBBLimits] of double);
  end;

  TBox2d = record
    case byte of
    0: (Min, Max, Mid: TVec2d);
  end;

  TCollisionObjects = (coInside, coOutside, coIntersect);


  TFrustum = record
    case byte of
    0: (M: array[TBoxPlanes, 0..3] of BSFloat);
    1: (V: array[0..24] of BSFloat);
    2: (P: array[TBoxPlanes] of TVec4f;);
  end;

  TRay3f = record
    Position: TVec3f;
    Direction: TVec3f;
  end;

  TRay3d = record
    Position: TVec3d;
    Direction: TVec3d;
  end;

  TColor4f = record
    class operator Add      (const AValue: TColor4f; const k: BSFloat): TColor4f; inline;
    class operator Implicit (const AValue: TVec4f): TColor4f; inline;
    class operator Implicit (const AValue: TColor4f): TVec4f; inline;
    class operator Explicit (const AValue: int32): TColor4f; inline;
    class operator Explicit (const AValue: uint32): TColor4f; inline;
    class operator Explicit (const AValue: TColor4f): uint32; inline;
    class operator Explicit (const AValue: TColor4f): TVec3f; inline;
    class operator Explicit (const AValue: TVec3f): TColor4f; inline;
    class operator Equal    (const v1, v2: TColor4f): boolean; inline;
    class operator Multiply (const v: TColor4f; const k: BSFloat): TColor4f; inline;
    case byte of
      0: (r, g, b, a: BSFloat);
      1: (x, y, z, w: BSFloat);
  end;

  TGuiColor = uint32;

  TVertexComponent = (vcCoordinate, vcColor, vcNormal, vcTexture1, vcTexture2, vcBones, vcWeights, vcIndex);
  TVertexComponents = set of TVertexComponent;
  TVertexKind = (vkP, vkPT, vkPTN);

  TVertexP = record
    Position: TVec3f;
  end;

  TVertexPT = record
    Position: TVec3f;
    Texture: TVec2f;
    class operator Implicit (const V: TVertexPT): TVertexP; inline;
  end;

  TVertexPC = record
    Position: TVec3f;
    Color: TVec3f;
  end;

  TVertexPTN = record
    Position: TVec3f;
    Texture: TVec2f;
    Normal: TVec3f;
  end;

  TVertexPTC = record
    Position: TVec3f;
    Texture: TVec2f;
    Color: TColor4f;
  end;

  TVertexPTTN = record
    Position: TVec3f;
    Texture1: TVec2f;
    Texture2: TVec2f;
    Normal: TVec3f;
  end;

  TQuaternion = TVec4f;

  TBSColors = (
    bsBlack,
    bsWhite,
    bsRed,
    bsGreen,
    bsBlue,
    bsGray,
    bsMaroon,
    bsOrange,
    bsYelloy,
    bsOrangeLight,
    bsOlive,
    bsNave,
    bsPurple,
    bsTeal,
    bsSilver,
    bsOrange2,
    bsLime,
    bsAqua,
    bsMoneyGreen,
    bsSkyBlue,
    bsCream,
    bsMedGray,
    bsSilver2,
    bsSky,
    bsDark
  );

  TNamedColorSet = set of TBSColors;

const
  TDimension1D = 1;
  TDimension2D = 2;
  TDimension3D = 3;

  BS_CL_BLACK       : TColor4f = (x:0.0; y:0.0; z:0.0; a:1.0);
  BS_CL_WHITE       : TColor4f = (x:1.0; y:1.0; z:1.0; a:1.0);
  BS_CL_RED         : TColor4f = (x:1.0; y:0.0; z:0.0; a:1.0);
  BS_CL_GREEN       : TColor4f = (x:0.0; y:1.0; z:0.0; a:1.0);
  BS_CL_BLUE        : TColor4f = (x:0.0; y:0.0; z:1.0; a:1.0);
  BS_CL_GRAY        : TColor4f = (x:0.5; y:0.5; z:0.5; a:1.0);
  BS_CL_MAROON      : TColor4f = (x:0.5; y:0.0; z:0.0; a:1.0);
  BS_CL_ORANGE      : TColor4f = (x:1.0; y:0.5; z:0.0; a:1.0);
  BS_CL_YELLOW      : TColor4f = (x:1.0; y:1.0; z:0.0; a:1.0);
  BS_CL_ORANGE_LIGHT: TColor4f = (x:1.0; y:0.8823; z:0.808; a:1.0);
  BS_CL_OLIVE       : TColor4f = (x:0.5; y:0.5; z:0.0; a:1.0);
  BS_CL_NAVY        : TColor4f = (x:0.0; y:0.0; z:0.5; a:1.0);
  BS_CL_PURPLE      : TColor4f = (x:0.5; y:0.0; z:0.5; a:1.0);
  BS_CL_TEAL        : TColor4f = (x:0.0; y:0.5; z:0.5; a:1.0);
  BS_CL_SILVER      : TColor4f = (x:0.752; y:0.752; z:0.752; a:1.0);
  BS_CL_ORANGE_2    : TColor4f = (x:1.0; y:0.5; z:0.153; a:1.0);
  BS_CL_LIME        : TColor4f = (x:0.0; y:0.5; z:0.0; a:1.0);
  BS_CL_AQUA        : TColor4f = (x:0.0; y:1.0; z:1.0; a:1.0);
  BS_CL_MONEY_GREEN : TColor4f = (x:0.752; y:0.863; z:0.752; a:1.0);
  BS_CL_SKY_BLUE    : TColor4f = (x:0.651; y:0.792; z:0.941; a:1.0);
  BS_CL_CREAM       : TColor4f = (x:1.0; y:0.984; z:0.941; a:1.0);
  BS_CL_MED_GRAY    : TColor4f = (x:0.643; y:0.627; z:0.627; a:1.0);
  BS_CL_SILVER2     : TColor4f = (x:0.218; y:0.406; z:0.835; a:1.0);
  BS_CL_SKY         : TColor4f = (x:0.621; y:0.863; z:0.922; a:1.0);
  BS_CL_DARK        : TColor4f = (x:0.1764; y:0.1764; z:0.1764; a:1.0);

  BS_CL_MSVS_EDIT_CURSOR_LINE : TColor4f = (x:15/255; y:15/255; z:15/255; a:1.0);
  BS_CL_MSVS_EDITOR           : TColor4f = (x:30/255; y:30/255; z:30/255; a:1.0);
  BS_CL_MSVS_PANEL            : TColor4f = (x:37/255; y:37/255; z:38/255; a:1.0);
  BS_CL_MSVS_BORDER           : TColor4f = (x:45/255; y:45/255; z:45/255; a:1.0);

  { create array colors for allow enumerating;
    delphi compiler do not alow to fill array defined above constants, therefor
    fills again by digits }
  TBSColorsSet: array[TBSColors] of TColor4f =
   ((x:0.0; y:0.0; z:0.0; a:1.0), // BS_CL_BLACK,
   (x:1.0; y:1.0; z:1.0; a:1.0), // BS_CL_WHITE,
   (x:1.0; y:0.0; z:0.0; a:1.0), // BS_CL_RED,
   (x:0.0; y:1.0; z:0.0; a:1.0), // BS_CL_GREEN,
   (x:0.0; y:0.0; z:1.0; a:1.0), // BS_CL_BLUE,
   (x:0.5; y:0.5; z:0.5; a:1.0), // BS_CL_GRAY,
   (x:0.5; y:0.0; z:0.0; a:1.0), // BS_CL_MAROON,
   (x:1.0; y:0.5; z:0.0; a:1.0), // BS_CL_ORANGE,
   (x:1.0; y:1.0; z:0.0; a:1.0), // BS_CL_YELLOW,
   (x:1.0; y:0.8823; z:0.808; a:1.0), // BS_CL_ORANGE_LIGHT,
   (x:0.5; y:0.5; z:0.0; a:1.0), // BS_CL_OLIVE,
   (x:0.0; y:0.0; z:0.5; a:1.0), // BS_CL_NAVY,
   (x:0.5; y:0.0; z:0.5; a:1.0), // BS_CL_PURPLE,
   (x:0.0; y:0.5; z:0.5; a:1.0), // BS_CL_TEAL,
   (x:0.752; y:0.752; z:0.752; a:1.0), //BS_CL_SILVER,
   (x:1.0; y:0.5; z:0.153; a:1.0), // BS_CL_ORANGE_2,
   (x:0.0; y:0.5; z:0.0; a:1.0), // BS_CL_LIME,
   (x:0.0; y:1.0; z:1.0; a:1.0), // BS_CL_AQUA,
   (x:0.752; y:0.863; z:0.752; a:1.0), // BS_CL_MONEY_GREEN,
   (x:0.651; y:0.792; z:0.941; a:1.0), // BS_CL_SKY_BLUE,
   (x:1.0; y:0.984; z:0.941; a:1.0), // BS_CL_CREAM,
   (x:0.643; y:0.627; z:0.627; a:1.0), // BS_CL_MED_GRAY
   (x:0.218; y:0.406; z:0.835; a:1.0), // BS_CL_SILVER2
   (x:0.621; y:0.863; z:0.922; a:1.0), // BS_CL_SKY
   (x:0.1764; y:0.1764; z:0.1764; a:1.0)  //BS_CL_DARK
  );

  { the associative array allows to enumerate throwgh TBBPoints and to get
  an access in appropriate a corner points BB }

  APROPRIATE_BB_POINTS: array[TBBPoints] of TBBLimitPoint = (
    (xMin, yMin, zMax), (xMin, yMax, zMax), (xMax, yMax, zMax), (xMax, yMin, zMax),
    (xMin, yMin, zMin), (xMin, yMax, zMin), (xMax, yMax, zMin), (xMax, yMin, zMin)
  );

  { the associative array allows to enumerate throwgh TAxis3D and to get
  an access in appropriate an axis line segment }

  ADAPTER_AXIS_TO_BB_SEGMENT: array[TAxis3D, 0..1] of TBBLimits = (
    (xMin, xMax), (yMin, yMax), (zMin, zMax)
  );

  { appropriating coordinates middle points every planes BB }
  APROPRIATE_MID: array[TBoxPlanes] of TBBLimitPoint =
  (
    (xMax, yMid, zMid), // bpRight
    (xMin, yMid, zMid), // bpLeft
    (xMid, yMin, zMid), // bpBottom
    (xMid, yMax, zMid), // bpTop
    (xMid, yMid, zMin), // bpFar
    (xMid, yMid, zMax)  // bpNear
  );
type

  { for simple types operators }

  { so Delphi do not support templates, therefor define methods for math
    operations }

  TComparatorFunc<T> = function (const Value1, Value2: T): int8;
  TAddFunc<T> = function (const Value1, Value2: T): T;
  TSubtractFunc<T> = function (const Value1, Value2: T): T;
  TMultiplyFunc<T> = function (const Value1, Value2: T): T;
  TMultiplyFuncInt<T> = function (const Value1: T; const Value2: int32): T;
  TMultiplyFuncFloat<T> = function (const Value1: T; const Value2: BSFloat): T;
  TDivideFunc<T> = function (const Value1, Value2: T): T;
  TDivideFloatFunc<T> = function (const Value1, Value2: T): BSFloat;
  TDivideIntFunc<T> = function (const Value1: T; const Value2: int32): T;
  TLowHighFunc<T> = function: T;
  TToString<T> = function(const Value: T): string;

  { define as record contains static methods (not virtual, it peforms a bit
    faster than virtual) }

  TOperators<T> = record
    Options: Pointer;
    Comparator: TComparatorFunc<T>;
    Add: TAddFunc<T>;
    Subtract: TSubtractFunc<T>;
    Multiply: TMultiplyFunc<T>;
    MultiplyInt: TMultiplyFuncInt<T>;
    MultiplyFloat: TMultiplyFuncFloat<T>;
    Divide: TDivideFunc<T>;
    DivideFloat: TDivideFloatFunc<T>;
    DivideInt: TDivideIntFunc<T>;
    High: TLowHighFunc<T>;
    Low: TLowHighFunc<T>;
    ToString: TToString<T>;
  end;

  { operators for Integer; and again - the methods NOT VIRTUAL !!! }

  TOperatorsInt = class
  public
    class procedure GetOperators(var Operators: TOperators<int32>);
    class function Comparator(const Value1, Value2: int32): int8; static;
    class function Add(const Value1, Value2: int32): int32; static;
    class function Subtract(const Value1, Value2: int32): int32; static;
    class function Multiply(const Value1, Value2: int32): int32; static;
    class function MultiplyFloat(const Value1: int32; const Value2: BSFloat): int32; static;
    class function Divide(const Value1, Value2: int32): int32; static;
    class function Divide_float(const Value1, Value2: int32): BSFloat; static;
    class function High: int32; static;
    class function Low: int32; static;
    class function ToStringInt(const Value: int32): string; static;
  end;

  TOperatorsFloat = class
  public
    class procedure GetOperators(var Operators: TOperators<BSFloat>);
    class function Comparator(const Value1, Value2: BSFloat): int8; static;
    class function Add(const Value1, Value2: BSFloat): BSFloat; static;
    class function Subtract(const Value1, Value2: BSFloat): BSFloat; static;
    class function Multiply(const Value1, Value2: BSFloat): BSFloat; static;
    class function MultiplyInt(const Value1: BSFloat; const Value2: int32): BSFloat; static;
    class function Divide(const Value1, Value2: BSFloat): BSFloat; static;
    class function DivideInt(const Value1: BSFloat; const Value2: int32): BSFloat; static;
    class function High: BSFloat; static;
    class function Low: BSFloat; static;
    class function ToStringFloat(const Value: BSFloat): string; static;
  end;

  TOperatorsDate = class
  public
    class procedure GetOperators(var Operators: TOperators<TDate>);
    class function Comparator(const Value1, Value2: TDate): int8; static;
    class function Add(const Value1, Value2: TDate): TDate; static;
    class function Subtract(const Value1, Value2: TDate): TDate; static;
    class function Multiply(const Value1, Value2: TDate): TDate; static;
    class function MultiplyInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function MultiplyFloat(const Value1: TDate; const Value2: BSFloat): TDate; static;
    class function Divide(const Value1, Value2: TDate): TDate; static;
    class function Divide_float(const Value1, Value2: TDate): BSFloat; static;
    class function DivideInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function High: TDate; static;
    class function Low: TDate; static;
    class function ToStringInt(const Value: TDate): string; static;
  end;

  { there is not all methods are actural }

  TOperatorsDateTime = class
  public
    class procedure GetOperators(var Operators: TOperators<TDateTime>);
    class function Comparator(const Value1, Value2: TDateTime): int8; static;
    class function Add(const Value1, Value2: TDateTime): TDateTime; static;
    class function Subtract(const Value1, Value2: TDateTime): TDateTime; static;
    class function Multiply(const Value1, Value2: TDateTime): TDateTime; static;
    class function MultiplyInt(const Value1: TDateTime; const Value2: int32): TDateTime; static;
    class function MultiplyFloat(const Value1: TDateTime; const Value2: BSFloat): TDateTime; static;
    class function Divide(const Value1, Value2: TDateTime): TDateTime; static;
    class function Divide_float(const Value1, Value2: TDateTime): BSFloat; static;
    class function DivideInt(const Value1: TDateTime; const Value2: int32): TDateTime; static;
    class function High: TDateTime; static;
    class function Low: TDateTime; static;
    class function ToStringInt(const Value: TDateTime): string; static;
  end;

  TColorEnumerator = class
  private
    FCurrentColor: TColor4f;
    CurrentIndexSet: TBSColors;
    FExceptColors: TNamedColorSet;
    FDefaultColor: TBSColors;
    procedure IncColor;
    function CompareExceptColors: boolean;
  public
    constructor Create(const ExceptCols: TNamedColorSet);
    function GetNextColor: TColor4f;
    function SetToColor(const Color: TBSColors): TColor4f;
    { Set to default color }
    procedure Reset;
    property ExceptColors: TNamedColorSet read FExceptColors write FExceptColors;
    property CurrentColor: TColor4f read FCurrentColor;
    property DefaultColor: TBSColors read FDefaultColor write FDefaultColor;
  end;


  PUInt64 = ^UInt64;
  PInt64  = ^Int64;

  function  MatrixEqual(const A, B: TMatrix4f): Boolean; inline;

  function  MatrixInvert(var Matrix: TMatrix4f): Boolean; overload; inline;
  function  MatrixInvert(var Matrix: TMatrix3f): Boolean; overload; inline;
  function  MatrixDeterminant(const Matrix: TMatrix3f): BSFloat; inline;
  procedure MatrixTranspose(var Matrix: TMatrix4f); overload; inline;
  procedure MatrixTranspose(var Matrix: TMatrix3f); overload; inline;
  procedure MatrixScale(var Matrix: TMatrix4f; X, Y, Z: BSFloat); inline;
  procedure MatrixScaleAt(var Matrix: TMatrix4f; X, Y, Z: BSFloat; const Pivot: TVec3f); inline;
  procedure MatrixTranslate(var Matrix: TMatrix4f; X, Y, Z: BSFloat); inline;
  procedure MatrixTransform(var Matrix: TMatrix4f; const M: TMatrix4f); inline;
  procedure MatrixPerspective(var Matrix: TMatrix4f; fovy, aspect, nearZ, farZ: BSFloat); inline; overload;
  procedure MatrixPerspective(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat); inline; overload;
  procedure MatrixFrustum(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat); inline;
  procedure MatrixOrtho(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat); inline;

  function VecDecisionX(const v: TVec3f): BSFloat; overload; {$ifndef DEBUG_BS} inline; {$endif}
  function VecDecisionX(const v: TVec2i): BSFloat; overload; {$ifndef DEBUG_BS} inline; {$endif}
  function VecDecisionY(const v: TVec3f): BSFloat; overload; {$ifndef DEBUG_BS} inline; {$endif}
  function VecDecisionY(const v: TVec2i): BSFloat; overload; {$ifndef DEBUG_BS} inline; {$endif}
  function VecDecisionZ(const v: TVec3f): BSFloat; {$ifndef DEBUG_BS} inline; {$endif}
  function VecDecision(const v: TVec2f): BSFloat; overload; {$ifndef DEBUG_BS} inline; {$endif}
  function VecLen(const v: TVec2i): BSFloat;  overload; inline;
  function VecLen(const v: TVec3i): BSint;  overload; inline;
  function VecLen(const v: TVec3f): BSFloat; overload; inline;
  function VecLen(const v: TVec2f): BSFloat; overload; inline;
  function VecLen(const v: TVec4i): BSint;  overload; inline;
  function VecLen(const v: TVec4f): BSFloat; overload; inline;
  // Cross product, result = normal to plane in which lie u and v
  function VecCross(const u, v: TVec3f): TVec3f; overload; inline;
  function VecCross(const p0 {common begin point}, p1, p2: TVec3f): TVec3f; overload; inline;
  {$if sizeof(BSFloat) <> sizeof(double)}
  function VecCross(const u, v: TVec3d): TVec3d; overload; inline;
  {$endif}
  { Dot product
    if result > 0 then angle b/w vectors is sharp, otherwise result < 0;
    if u and v are normalized (length = 1), then result is cos between u and v }
  function VecDot(const u, v: TVec2f): BSFloat; overload; inline;
  function VecDot(const u, v: TVec3f): BSFloat; overload; inline;
  {$if sizeof(BSFloat) <> sizeof(double)}
  function VecDot(const u, v: TVec3d): double; overload; inline;
  {$endif}
  function VecDot(const u, v: TVec4f): BSFloat; overload; inline;
  function VecDot(const Plane: TVec4f; const v: TVec3f): BSFloat; overload; inline;
  {$if sizeof(BSFloat) <> sizeof(double)}
  function VecDot(const Plane: TVec4f; const v: TVec3d): double; overload; inline;
  {$endif}
  function VecNormalize(const v: TVec2f):TVec2f; overload; inline;
  function VecNormalize(const v: TVec3f):TVec3f; overload; inline;
  function VecNormalize(const v: TVec4f):TVec4f; overload; inline;
  function VecScale(const v, scale: TVec3f):TVec3f; overload; inline;
  {$if sizeof(BSFloat) <> sizeof(double)}
  function VecScale(const v, scale: TVec3d):TVec3d; overload; inline;
  {$endif}
  function VecRound(const v: TVec4f; Precition: int32): TVec4f; inline;

  function VecLenSqr(const v: TVec3f): BSFloat; overload; inline;
  {$if sizeof(BSFloat) <> sizeof(double)}
  function VecLenSqr(const v: TVec3d): double; overload; inline;
  {$endif}
  function VecLenSqr(const v: TVec3i): BSFloat; overload; inline;
  function VecLenSqr(const v: TVec2f): BSFloat; overload; inline;
  function VecLenSqr(const v: TVec2i): BSint; overload; inline;
  function VecLenSqr(const v: TVec4f): BSFloat; overload; inline;
  function VecLenSqr(const v: TVec4i): BSFloat; overload; inline;

  function VecToStr(const v: TVec2f): string; overload; inline;
  function VecToStr(const v: TVec2i): string; overload; inline;
  function VecToStr(const v: TVec3f): string; overload; inline;
  function VecToStr(const v: TVec4f): string; overload; inline;
  function VecToStr(const v: TVec4f; Precision: int8): string; overload; inline;

  function Plane(const p1, p2, p3: TVec3f): TVec4f; overload; inline;
  function Plane(const Normal, Origin: TVec3f): TVec4f; overload; inline;
  function Plane(const Triangle: TTriangle3f): TVec4f; overload; inline;
  { for calculate discance to plane need normalize }
  function PlaneNormalize(const p1, p2, p3: TVec3f): TVec4f; overload; inline;
  //function PlaneNormalize(const Triangle: PTriangle3f): TVec4f; overload; inline;
  function PlaneCrossProduct(const Plane1, Plane2, Plane3: TVec4f; out Intersect: boolean): TVec3f; overload; inline;
  function PlaneCrossProduct(const Plane: TVec4f; const OriginVector: TVec3f;
    const DirNormal: TVec3f; out Intersect: boolean; out Distance: BSFloat): TVec3f; overload; inline;
  { Calcs a point intersect a vector with a plane; the Plane MUST NOT be normalized }
  function PlaneCrossProduct(const Plane: TVec4f; const OriginVector: TVec3f; const DirNormal: TVec3f; out Distance: BSFloat; out Intersect: boolean): TVec3f; overload; inline;
  { if you want to get exactly Distance you need to give normalized Plane }
  function PlanePointProjection(const Plane: TVec4f; const OriginVector: TVec3f; out Distance: BSFloat): TVec3f; overload; inline;
  function PlaneDotProduct(const Plane: TVec4f; const V: TVec3f): BSFloat; inline;
  function PlaneMinDistanceToBB(const Plane: TVec4f; const BB: PBox3f): BSFloat; inline;
  function PlaneMaxDistanceToBB(const Plane: TVec4f; const BB: PBox3f): BSFloat; inline;

  { defines distance to planes PlaneForX(OriginXYZO, PointOY, PointOZ) and
  	PlaneForY(PointOX, OriginXYZO, PointOZ); the OriginXYZO may be higher left
    corner camera (screen) or a parent bounding box for define a child 2d
    position relative him	}
  procedure Convert3Dto2D(const OriginXYZO, PointOX, PointOY, PointOZ: TVec3f; const Origin: TVec3f; out X, Y: BSFloat); inline;

  function Triangle(A, B, C: TVec3f): TTriangle3f; inline;

  // fast copy big buffers
  procedure FastCopy(S, D: Pointer; Count: NativeInt); inline;

  function Vec2(x, y: BSFloat): TVec2f; overload; inline;
  function Vec2(x, y: BSInt): TVec2i; overload; inline;
  function Vec2(x, y: BSInt64): TVec2i64; overload; inline;
  function Vec2(x, y: UInt32): TVec2ui; overload; inline;
  { define separate function for double because DCC do not see difference b/w
    float and double and always invoke overloaded method with float parameters
    if even to define overloaded method with double parameters and translate to
    it double variable }
  function Vec2d(x, y: double): TVec2d; inline;
  function Vec3(x, y, z: BSFloat): TVec3f; overload; inline;
  function Vec3(x, y, z: BSInt): TVec3i; overload; inline;
  function Vec3(x, y, z: byte): TVec3b; overload; inline;
  { compiler do not see differnt b/w Vec3(x, y, z: BSFloat), therefor define
    an explicit method }
  function Vec3d(x, y, z: double): TVec3d; overload; inline;
  function Vec4(x, y, z, w: BSFloat): TVec4f; overload; inline;
  function Vec4(x, y, z, w: BSInt): TVec4i; overload; inline;
  function Vec4(x, y, z, w: byte): TVec4b; overload; inline;
  function Vec4(v: TVec3f; w: BSFloat): TVec4f; overload; inline;
  function Vec4(v: TVec3b; w: byte): TVec4b; overload; inline;
  function Vec4(const V1, V2: TVec2f): TVec4f; overload; inline;
  { see a describtion above to Vec2d }
  function Vec4d(x, y, z, w: Double): TVec4d; overload; inline;

  function Box2Collision(const Box1, Box2: TBox2d): boolean; overload; inline;
  function Box3(const MinV, MaxV: TVec3f): TBox3f; overload; inline;
  function Box3(const MinV, MaxV: TVec3d): TBox3d; overload; inline;
  function Box3(const Rect: TRectBSf): TBox3f; overload; inline;
  function Box3(const Rect: TRectBSd): TBox3d; overload; inline;
  function Box3Collision(const Box1, Box2: TBox3f): boolean; overload; inline;
  function Box3Collision(const Box1, Box2: TBox3d): boolean; overload; inline;
  function Box3Inside(const Box, BoxInside: TBox3f): boolean; inline; overload;
  function Box3Inside(const Box: TBox3f; const InsideTri: TTriangle3f): boolean; inline; overload;
  function Box3Inside(const Box: TBox3f; const InsideTriA, InsideTriB, InsideTriC: TVec3f): boolean; inline; overload;
  function Box3Middle(const Box: TBox3f): TVec3f; inline;
  function Box3CheckBB(var Box: TBox3f; const v: TVec3f): boolean; overload; inline;
  function Box3CheckBB(var WidedBox: TBox3f; const Box: TBox3f): boolean; overload; inline;
  function Box3CheckBB(var Box: TBox3d; const v: TVec3d): boolean; overload; inline;
  function Box3CheckBB(var WidedBox: TBox3d; const Box: TBox3d): boolean; overload; inline;
  function Box3PointIn(const Box: TBox3f; const Point: TVec3f): boolean; overload; inline;
  function Box3PointIn(const Box: TBox3d; const Point: TVec3d): boolean; overload; inline;
  function Box3Size(const Box: TBox3f): TVec3f; overload; inline;
  function Box3Size(const Box: TBox3d): TVec3d; overload; inline;
  { calculate Volume; if size one of axes equal 0 then will return square }
  function Box3Volume(const Box: TBox3f): BSFloat; overload; inline;
  function Box3Volume(const Box: TBox3d): double; overload; inline;
  { overlapped volume }
  function Box3Overlap(const Box1, Box2: TBox3f): BSFloat; overload; inline;
  function Box3Overlap(const Box1, Box2: TBox3d): double; overload; inline;
  { logical or }
  function Box3Union(const Box1, Box2: TBox3d): TBox3d; overload; inline;
  function Box3Union(const Box1, Box2: TBox3f): TBox3f; overload; inline;
  { logical and }
  function Box3GetOverlap(const Box1, Box2: TBox3f): TBox3f; overload; inline;
  function Box3GetOverlap(const Box1, Box2: TBox3d): TBox3d; overload; inline;
  procedure Box3Recalc(var Box: TBox3f; const Matrix: TMatrix4f); overload; inline;
  procedure Box3Recalc(var Box: TBox3f; const Matrix: TMatrix3f); overload; inline;
  function Box3Recalc(var Box: TBox3f; const Matrix: TMatrix4f; const NearestTo: TVec3f): TVec3f; overload; inline;
  function Box3fMultiply (const B: TBox3f; const M: TMatrix4f): TBox3f; inline;
  function Box3fEqual(const B1, B2: TBox3f): boolean; inline;

  procedure CompareMaxMinAndSwap(var Max, Min: TVec3f); inline;

type
  TRotateSequence = (rsAxelX, rsAxelY, rsAxelZ);
  TRotateSequences = set of TRotateSequence;
  TQuatMethod = function (const Angle: BSFloat): TQuaternion;

  // constructors Quaternion from angles Euler; for evry axis created TQuaternion and multiply as: Qx*Qy*Qz
  function Quaternion(const Angles: TVec3f): TQuaternion; overload; inline;
  function Quaternion(const Angles: TVec3f; First: TRotateSequence;
    Second: TRotateSequence; Third: TRotateSequence): TQuaternion; overload; inline;
  function Quaternion(const AMatrix: TMatrix4f): TQuaternion; overload; inline;
  // constructors Quaternion from angles Euler; for evry axis created TQuaternion and multiply as: Qz*Qy*Qx
  function QuaternionInverse(const Angles: TVec3f): TQuaternion; inline;
  function QuaternionX(const Angle: BSFloat): TQuaternion; inline; // yaw
  function QuaternionY(const Angle: BSFloat): TQuaternion; inline; // pitch
  function QuaternionZ(const Angle: BSFloat): TQuaternion; inline; // roll

	/// Returns a SLERP interpolated quaternion of q1 and q2 according a.
  function QuaternionSLERP(const q1, q2: TQuaternion; a: BSFloat): TQuaternion; inline;
  function QuaternionNLERP(const q1, q2: TQuaternion; a: BSFloat): TQuaternion; inline;

const
  QUATERNION_EULER_METHODS: array[TRotateSequence] of TQuatMethod = (
    QuaternionX,
    QuaternionY,
    QuaternionZ);

  function QuaternionMult(const q1, q2: TQuaternion): TQuaternion; inline;
  procedure QuaternionToMatrix(var Matrix: TMatrix4f; const Quaternion: TQuaternion); overload; inline;
  procedure QuaternionToMatrix(var Matrix: TMatrix3f; const Quaternion: TQuaternion); overload; inline;
  function QuaternionToAngles(const Quaternion: TQuaternion): TVec3f; inline;
  function QuaternionToVec(const Quaternion: TQuaternion): TVec3f;
  { angle rotate around x }
  function QuaternionPitch(Q: TQuaternion): BSFloat; inline;
  { angle rotate around Y }
  function QuaternionYaw(Q: TQuaternion): BSFloat; inline;
  { angle rotate around y }  // (x-axis rotation)
  function QuaternionRoll(Q: TQuaternion): BSFloat; inline;

  //procedure QuaternionToEulerianAngle(const Q: TQuaternion; var Roll, Pitch, Yaw: BSFloat); overload;
  //procedure QuaternionToEulerianAngle(const Q: TQuaternion; var Angles: TVec3f); overload;

  function Ray(const Position: TVec3f; const Direction: TVec3f): TRay3f; inline;

  { return: -1 if p1 > p2, 0 if p1 = p2, 1 if p1 < p2 }
  function CompareVec3(const p1, p2: TVec3f): int8; overload; inline;
  function CompareVec3(const p1, p2: TVec3d): int8; overload; inline;
  { color convertation }
  function ColorFloatToByte(const v: TColor4f): TVec4b; inline;
  function ColorByteToFloat(const v: TVec4b): TColor4f; inline; overload;
  function ColorByteToFloat(const v: TVec3b): TColor4f; inline; overload;
  function ColorByteToFloat(const v: uint32; ResetAlpha: boolean = false): TColor4f; inline; overload;
  function Color4f(r, g, b, a: byte): TColor4f; overload; inline;
  function Color4f(r, g, b, a: BSFloat): TColor4f; overload; inline;

  function RectBS(Left, Top, Width, Height: BSFloat): TRectBSf; overload; inline;
  function RectBSd(Left, Top, Width, Height: double): TRectBSd; inline;
  function RectBS(LeftTop: TVec2f; Width, Height: BSFloat): TRectBSf; overload; inline;
  function RectBS(LeftTop, Size: TVec2f): TRectBSf; overload; inline;
  function RectBS(Left, Top, Width, Height: int64): TRectBSi64; overload; inline;
  function RectBS(Left, Top, Width, Height: int32): TRectBSi;   overload; inline;
  function RectToUV(WidthTexture, HeightTexture: int32; const RectTexture: TRectBSi): TRectBSf; overload; inline;
  function RectToUV(WidthTexture, HeightTexture: int32; const RectTexture: TRectBSf): TRectBSf; overload; inline;
  function RectIntersect(const Rect1, Rect2: TRectBSi): boolean; overload; inline;
  function RectIntersect(const Rect1, Rect2: TRectBSf): boolean; overload; inline;
  function RectIntersect(const Rect1, Rect2: TRectBSi64): boolean; overload; inline;
  function RectIntersect(const Rect1, Rect2: TRectBSd): boolean; overload; inline;
  function RectContains(const RectContainsing, RectContainsed: TRectBSi): boolean; overload; inline;
  function RectContains(const RectContainsing, RectContainsed: TRectBSf): boolean; overload; inline;
  function RectContains(const RectContainsing: TRectBSf; Contained: TVec2f): boolean; overload; inline;
  function RectContains(const RectMin, RectMax: TVec3f; Contained: TVec2f): boolean; overload; inline;
  function RectOverlap(const Rect1, Rect2: TRectBSf): TRectBSf; overload; inline;
  function RectOverlap(const Rect1, Rect2: TRectBSd): TRectBSd; overload; inline;
  function RectOverlap(const Rect1, Rect2: TRectBSi): TRectBSi; overload; inline;
  function RectUnion(const Rect1, Rect2: TRectBSf): TRectBSf; overload; inline;
  procedure RectOffset(var Rect: TRectBSf; const Offset: TVec2f); overload; inline;
  function OverlapLines(const Line1, Line2: TVec2f): BSFloat; inline;

  function AngleEulerClamp3d(const Angle: TVec3f): TVec3f; inline;
  function AngleEulerClamp(Angle: BSFLoat): BSFLoat; inline;

  function htonl(value: uint32): uint32; inline;
  function htons(value: uint16): uint16; inline;

  function ReadInt32(Buf: pByte; var Offset: int32; Flip: boolean = false): int32; inline;
  function ReadInt16(Buf: pByte; var Offset: int32; Flip: boolean = false): int16; inline;
  // read 16-bit fixed point value: [-1.999939; 1.999939]
  function Read2Dot14(Buf: pByte; var Offset: int32; Flip: boolean = false): BSFloat; inline;
  // read 32-bit fixed point number value: 6 bits - a fractal value, 26 - integer
  function Read26Dot6(Buf: pByte; var Offset: int32; Deploy: boolean = false): Double; inline;
  function ReadInt8(Buf: pByte; var Offset: int32): int8; inline;
  function ReadUInt32(Buf: pByte; var Offset: int32; Flip: boolean = false): uint32; inline;
  function ReadUInt16(Buf: pByte; var Offset: int32; Flip: boolean = false): uint16; inline;
  function ReadUInt8(Buf: pByte; var Offset: int32): uint8; inline;

  procedure swap(var a, b: int32); overload; inline;
  procedure swap(var a, b: BSFloat); overload; inline;
  procedure swap(var a, b: double); overload; inline;
  procedure swap(var a, b: TVec2i); overload; inline;
  procedure swap(var a, b: TVec2f); overload; inline;
  procedure swap(var a, b: TVec3f); overload; inline;

  function Vertex(const Point: TVec3f; const UV: TVec2f): TVertexPT; overload; inline;

  { Translate color RGB to HLS: hue, lightness (intensity), saturation;
    тон, €ркость, насыщенность (контраст) }
  function RGBtoHLS(const RGB: TVec3f): TVec3f;
  { Translate color HLS to RGB }
  function HLStoRGB(const HLS: TVec3f): TVec3f;

  function FloatToInt64(AValue: BSFloat): int64; inline;


const
  IDENTITY_MAT: TMatrix4f = (V: (
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1));
  IDENTITY_MAT3F: TMatrix3f = (V: (
    1, 0, 0,
    0, 1, 0,
    0, 0, 1
    ));
  IDENTITY_MAT2F: TMatrix2f = (V: (
    1, 0,
    0, 1
    ));

  IDENTITY_VEC3: TVec3f = (x:1.0; y:1.0; z:1.0);

  ONE_OF_256 = 0.00390625; // 1/256


  VEC3F_ZERO: TVec3f = (x:0; y:0; z:0);

	QUAD_VERTEXES: array[0..3] of TVec3f = (
		(x:-1.0; y:-1.0; z:0.0),
		(x: 1.0; y:-1.0; z:0.0),
		(x:-1.0; y: 1.0; z:0.0),
		(x: 1.0; y: 1.0; z:0.0)
	);

implementation

uses
    Math
  , DateUtils
  ;

function RGBtoHLS(const RGB: TVec3f): TVec3f;
var
  cMax, cMin, d: BSFloat;
  Rdelta, Gdelta, Bdelta: single;
begin
  cMax := Math.max( Math.max(RGB.r, RGB.g), RGB.b);
  cMin := Math.min( Math.min(RGB.r, RGB.g), RGB.b);

  Result.l := (cMax + cMin)/2;
  d := cMax - cMin;
  if (d = 0) then
  begin
    Result.l := 0;
    Result.s := 0;
    Result.h := 1/2;
  end else
  begin
    if (Result.l <= (1/2)) then
      Result.s := d/(Result.l*2)
    else
      Result.s := d/(2-2*Result.l);
    Rdelta := ( ((cMax-RGB.r)*(1/6)) + d/2 ) / d;
    Gdelta := ( ((cMax-RGB.g)*(1/6)) + d/2 ) / d;
    Bdelta := ( ((cMax-RGB.b)*(1/6)) + d/2 ) / d;
    if (RGB.r = cMax) then
      Result.h := Bdelta - Gdelta
    else
    if (RGB.g = cMax) then
      Result.h := (1/3) + Rdelta - Bdelta
    else
      Result.h := (2/3) + Gdelta - Rdelta;
    if (Result.h < 0) then
      Result.h := Result.h + 1.0;
    if (Result.h > 1.0) then
      Result.h := Result.h - 1.0;
  end;
end;

function HLStoRGB(const HLS: TVec3f): TVec3f;
var
  q, p: single;

  function HueToRGB(hue: single): single;
  begin
    if hue < 0 then
      hue := hue + 1.0
    else
    if hue > 1.0 then
      hue := hue - 1.0;
    if hue < 1/6 then
      Result := p + ((q-p)*6*hue)
    else
    if hue < 1/2 then
      Result := q
    else
    if hue < 2/3 then
      Result := p + ((q-p)*6*(2/3-hue))
    else
      Result := p;
  end;

begin
  if (HLS.s = 0) then
  begin
    { gray scale }
    Result.b := HLS.l;
    Result.r := Result.b;
    Result.g := Result.b;
  end else
  begin
    if HLS.l < 0.5 then
      q := (HLS.l*(1.0+HLS.s))
    else
      q := HLS.l + HLS.s - HLS.l*HLS.s;
    p := HLS.l*2.0 - q;
    Result.r := HueToRGB(HLS.h+1/3);
    Result.g := HueToRGB(HLS.h);
    Result.b := HueToRGB(HLS.h-1/3);
  end;
end;

function FloatToInt64(AValue: BSFloat): int64;
begin
  PCardinal(@Result)^ := trunc(AValue);
  PCardinal(PByte(@Result)+4)^ := round(frac(AValue)*MaxInt);
end;

function Vertex(const Point: TVec3f; const UV: TVec2f): TVertexPT; overload; inline;
begin
  Result.Position := Point;
  Result.Texture := UV;
end;

procedure swap(var a, b: int32); overload; inline;
var
  t: int32;
begin
  t := a;
  a := b;
  b := t;
end;

procedure swap(var a, b: BSFloat);
var
  t: BSFloat;
begin
  t := a;
  a := b;
  b := t;
end;

procedure swap(var a, b: double); overload; inline;
var
  t: double;
begin
  t := a;
  a := b;
  b := t;
end;

procedure swap(var a, b: TVec2i);
var
  t: TVec2i;
begin
  t := a;
  a := b;
  b := t;
end;

procedure swap(var a, b: TVec2f);
var
  t: TVec2f;
begin
  t := a;
  a := b;
  b := t;
end;

procedure swap(var a, b: TVec3f);
var
  t: TVec3f;
begin
  t := a;
  a := b;
  b := t;
end;

function Ray(const Position: TVec3f; const Direction: TVec3f): TRay3f;
begin
  Result.Position := Position;
  Result.Direction := Direction;
end;

function CompareVec3(const p1, p2: TVec3f): int8;
begin
  if p1.z > p2.z then
    Result := -1 else
  if p1.z = p2.z then
    begin
    if p1.y > p2.y then
      Result := -1 else
    if p1.y = p2.y then
      begin
      if p1.x > p2.x then
        Result := -1 else
      if p1.x = p2.x then
        Result := 0 else
        Result := 1;
      end else
      Result := 1;
    end else
    Result := 1;
end;

function CompareVec3(const p1, p2: TVec3d): int8;
begin
  if p1.z > p2.z then
    Result := -1
  else
  if p1.z = p2.z then
  begin
    if p1.y > p2.y then
      Result := -1
    else
    if p1.y = p2.y then
    begin
      if p1.x > p2.x then
        Result := -1
      else
      if p1.x = p2.x then
        Result := 0
      else
        Result := 1;
    end else
      Result := 1;
  end else
    Result := 1;
end;

function ColorFloatToByte(const v: TColor4f): TVec4b;
begin
  Result.x := Round(v.r * 255);
  Result.y := Round(v.g * 255);
  Result.z := Round(v.b * 255);
  Result.w := Round(v.a * 255);
end;

function ColorByteToFloat(const v: uint32; ResetAlpha: boolean = false): TColor4f;
var
  tmp: TVec4b;
begin
  tmp.value := v;
  Result.r := tmp.x * ONE_OF_256;
  Result.g := tmp.y * ONE_OF_256;
  Result.b := tmp.z * ONE_OF_256;
  if ResetAlpha then
    Result.a := 1.0
  else
    Result.a := tmp.a * ONE_OF_256;
end;

function ColorByteToFloat(const v: TVec4b): TColor4f;
begin
  Result.r := v.x * ONE_OF_256;
  Result.g := v.y * ONE_OF_256;
  Result.b := v.z * ONE_OF_256;
  Result.a := v.a * ONE_OF_256;
end;

function ColorByteToFloat(const v: TVec3b): TColor4f;
begin
  Result.r := v.x * ONE_OF_256;
  Result.g := v.y * ONE_OF_256;
  Result.b := v.z * ONE_OF_256;
end;

function Color4f(r, g, b, a: byte): TColor4f;
begin
  Result.r := r * ONE_OF_256;
  Result.g := g * ONE_OF_256;
  Result.b := b * ONE_OF_256;
  Result.a := a * ONE_OF_256;
end;

function Color4f(r, g, b, a: BSFloat): TColor4f;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
  Result.a := a;
end;

{ TBox3f }

function Box3fEqual(const B1, B2: TBox3f): boolean;
begin
  Result := (B1.Max = B2.Max) and (B1.Min = B2.Min);
end;

function Box3fMultiply(const B: TBox3f; const M: TMatrix4f): TBox3f;
begin
  Result.Middle := M * B.Middle;
  Result.Min := M * B.Min;
  Result.Max := M * B.Max;
end;

{ TBox3f }

class operator TBox3f.Multiply(const ABox: TBox3f; const k: BSFloat): TBox3f;
begin
  Result.V0 := ABox.V0 * k;
  Result.V1 := ABox.V1 * k;
  Result.Middle := ABox.Middle * k;
end;

{ TVec2f }

class operator TVec2f.Add (const v1, v2: TVec2f): TVec2f;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
end;

class operator TVec2f.Add(const v: TVec2f; const a: BSFloat): TVec2f;
begin
  Result.x := v.x + a;
  Result.y := v.y + a;
end;

class operator TVec2f.Subtract (const v1, v2: TVec2f): TVec2f;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
end;

class operator TVec2f.Multiply (const v1, v2: TVec2f): TVec2f;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
end;

class operator TVec2f.Multiply(const v: TVec2f; k: BSFloat): TVec2f;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
end;

class operator TVec2f.Negative(const v: TVec2f): TVec2f;
begin
  Result.x := -v.x;
  Result.y := -v.y;
end;

class operator TVec2f.Subtract(const v: TVec2f; const a: BSFloat): TVec2f;
begin
  Result.x := v.x - a;
  Result.y := v.y - a;
end;

class operator TVec2f.Divide (const v1, v2: TVec2f): TVec2f;
begin
  Result.x := v1.x / v2.x;
  Result.y := v1.y / v2.y;
end;

class operator TVec2f.Divide(const v: TVec2f; k: BSFloat): TVec2f;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
end;

class operator TVec2f.Equal (const v1, v2: TVec2f): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y);
end;

{ TVec2i }

class operator TVec2i.Add (const v1, v2: TVec2i): TVec2i;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
end;

class operator TVec2i.Subtract (const v1, v2: TVec2i): TVec2i;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
end;

class operator TVec2i.Multiply (const v1, v2: TVec2i): TVec2i;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
end;

class operator TVec2i.Multiply(const v: TVec2i; const k: BSFloat): TVec2i;
begin
  Result.x := round(v.x * k);
  Result.y := round(v.y * k);
end;

class operator TVec2i.Multiply(const v: TVec2i; const k: int32): TVec2i;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
end;

class operator TVec2i.Subtract(const v: TVec2i; const a: BSInt): TVec2i;
begin
  Result.x := v.x - a;
  Result.y := v.y - a;
end;

class operator TVec2i.Divide (const v1, v2: TVec2i): TVec2i;
begin
  Result.x := v1.x div v2.x;
  Result.y := v1.y div v2.y;
end;

class operator TVec2i.Divide(const v: TVec2i; const k: BSInt): TVec2i;
begin
  Result.x := v.x div k;
  Result.y := v.y div k;
end;

class operator TVec2i.Add(const v: TVec2i; const a: BSInt): TVec2i;
begin
  Result.x := v.x + a;
  Result.y := v.y + a;
end;

class operator TVec2i.Divide(const v: TVec2i; const k: BSFloat): TVec2i;
begin
  Result.x := round(v.x / k);
  Result.y := round(v.y / k);
end;

class operator TVec2i.Equal (const v1, v2: TVec2i): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y);
end;

class operator TVec2i.Implicit(const v: TVec2f): TVec2i;
begin
  Result.x := Round(v.x);
  Result.y := Round(v.y);
end;

class operator TVec2i.Implicit(const v: TVec2i): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec2i.Implicit(const v: TVec2i64): TVec2i;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

{ TVec3f }

class operator TVec3f.Add (const v1, v2: TVec3f): TVec3f;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
end;

class operator TVec3f.Subtract (const v1, v2: TVec3f): TVec3f;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
end;

class operator TVec3f.Negative(const v: TVec3f): TVec3f;
begin
  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;
end;

class operator TVec3f.NotEqual(const v1, v2: TVec3f): boolean;
begin
  Result := (v1.x <> v2.x) or (v1.y <> v2.y) or (v1.z <> v2.z);
end;

class operator TVec3f.Multiply (const v1, v2: TVec3f): TVec3f;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
end;

class operator TVec3f.Multiply (const v: TVec3f; const k: BSFloat): TVec3f;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
end;

class operator TVec3f.Divide (const v1, v2: TVec3f): TVec3f;
begin
  Result.x := v1.x / v2.x;
  Result.y := v1.y / v2.y;
  Result.z := v1.z / v2.z;
end;

class operator TVec3f.Add(const v: TVec3f; k: BSFloat): TVec3f;
begin
  Result.x := v.x + k;
  Result.y := v.y + k;
  Result.z := v.z + k;
end;

class operator TVec3f.Divide(const v: TVec3f; const k: BSFloat): TVec3f;
begin
 Result.x := v.x / k;
 Result.y := v.y / k;
 Result.z := v.z / k;
end;

class operator TVec3f.Equal(const v1, v2: TVec3f): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y) and (v1.z = v2.z);
end;

class operator TVec3f.Explicit (const v: TVec4f): TVec3f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
end;

class operator TVec3f.Explicit(const v: TVec3f): TVec2i;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
end;

class operator TVec3f.Explicit (const v: TVec3f): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec3f.Implicit(const v: TVec3f): TVec4f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := 1.0;
end;

class operator TVec3f.Implicit(const v: TVec2f): TVec3f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := 0.0;
end;

class operator TVec3f.Explicit(const v: TVec3f): TVec3i;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
  Result.z := round(v.z);
end;

{$if sizeof(BSFloat) <> sizeof(double)}

{ TVec3d }

class operator TVec3d.Divide(const v: TVec3d; const k: double): TVec3d;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
end;

class operator TVec3d.Multiply (const v1, v2: TVec3d): TVec3d;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
end;

class operator TVec3d.Multiply(const v: TVec3d; const k: double): TVec3d;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
end;

class operator TVec3d.Multiply(const v1: TVec3f; const v2: TVec3d): TVec3d;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
end;

class operator TVec3d.Equal(const v1, v2: TVec3d): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y) and (v1.z = v2.z);
end;

class operator TVec3d.NotEqual(const v1, v2: TVec3d): boolean;
begin
  Result := (v1.x <> v2.x) or (v1.y <> v2.y) or (v1.z <> v2.z);
end;

class operator TVec3d.Add(const v1, v2: TVec3d): TVec3d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
end;

class operator TVec3d.Subtract(const v1, v2: TVec3d): TVec3d;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
end;

class operator TVec3d.Explicit(const v: TVec3d): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec3d.Explicit (const v: TVec3d): TVec3f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
end;

class operator TVec3d.Implicit (const v: TVec3f): TVec3d;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
end;

class operator TVec3d.Subtract(const v1: TVec3f; const v2: TVec3d): TVec3f;
begin
 Result.x := v1.x - v2.x;
 Result.y := v1.y - v2.y;
 Result.z := v1.z - v2.z;
end;

{$endif}

class operator TVec3i.Add (const v1, v2: TVec3i): TVec3i;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
end;

class operator TVec3i.Subtract (const v1, v2: TVec3i): TVec3i;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
end;

class operator TVec3i.Multiply (const v1, v2: TVec3i): TVec3i;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
end;

class operator TVec3i.Divide (const v1, v2: TVec3i): TVec3i;
begin
  Result.x := v1.x div v2.x;
  Result.y := v1.y div v2.y;
  Result.z := v1.z div v2.z;
end;

{
class operator TVec3i.Divide(const v: TVec3i; const k: BSFloat): TVec3f;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
end;
}

{
operator:=(const v: TVec3f): TVec3d;
begin
  Result.x := Round(v.x);
  Result.y := Round(v.y);
  Result.z := Round(v.z);
end;
}

class operator TVec3b.Add (const v1, v2: TVec3b): TVec3b;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
end;

class operator TVec3b.Subtract(const v1, v2: TVec3b): TVec3b;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
end;

class operator TVec3b.Multiply(const v1, v2: TVec3b): TVec3b;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
end;

class operator TVec3b.Divide(const v1, v2: TVec3b): TVec3b;
begin
  Result.x := v1.x div v2.x;
  Result.y := v1.y div v2.y;
  Result.z := v1.z div v2.z;
end;

class operator TVec4f.Add (const v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4f.Subtract (const v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := v1.w - v2.w;
end;

class operator TVec4f.Multiply (const v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
  Result.w := v1.w * v2.w;
end;

class operator TVec4f.Multiply (const v: TVec4f; const k: BSFloat): TVec4f;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
  Result.w := v.w * k;
end;

class operator TVec4f.Negative(const v: TVec4f): TVec4f;
begin
  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;
  Result.w := -v.w;
end;

class operator TVec4f.Divide(const v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x / v2.x;
  Result.y := v1.y / v2.y;
  Result.z := v1.z / v2.z;
  Result.w := v1.w / v2.w;
end;

class operator TVec4f.Divide(const v: TVec4f; const k: BSFloat): TVec4f;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
  Result.w := v.w / k;
end;

class operator TVec4f.Divide(const v: TVec4f; const k: int32): TVec4f;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
  Result.w := v.w / k;
end;

class operator TVec4f.Equal (const v1, v2: TVec4f): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y) and (v1.z = v2.z) and (v1.w = v2.w);
  //Result := CompareMem(@v1, @v2, SizeOf(TVec4f));
end;

class operator TVec4i.Add (const v1, v2: TVec4i): TVec4i;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4i.Add(const v1: TVec4i; v2: TVec4b): TVec4i;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4i.Subtract (const v1, v2: TVec4i): TVec4i;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := v1.w - v2.w;
end;

class operator TVec4i.Multiply (const v1, v2: TVec4i): TVec4i;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
  Result.w := v1.w * v2.w;
end;

class operator TVec4i.Divide (const v1, v2: TVec4i): TVec4i;
begin
  Result.x := v1.x div v2.x;
  Result.y := v1.y div v2.y;
  Result.z := v1.z div v2.z;
  Result.w := v1.w div v2.w;
end;

class operator TVec4i.Divide(const v: TVec4i; const k: BSInt): TVec4i;
begin
  Result.x := v.x div k;
  Result.y := v.y div k;
  Result.z := v.z div k;
  Result.w := v.w div k;
end;

class operator TVec4i.Add(const v1: TVec4d; const v2: TVec4i): TVec4d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4i.Divide(const v: TVec4i; const k: BSFloat): TVec4i;
var
  k_inv: BSFloat;
begin
  k_inv := 1/k;
  Result.x := round(v.x * k_inv);
  Result.y := round(v.y * k_inv);
  Result.z := round(v.z * k_inv);
  Result.w := round(v.w * k_inv);
end;

class operator TVec4i.Implicit(const v: TVec4f): TVec4i;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
  Result.z := round(v.z);
  Result.w := round(v.w);
end;

class operator TVec4i.Implicit(const v: TVec4i): TVec4b;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := v.w;
end;

class operator TVec4i.Implicit(const v: TVec4b): TVec4i;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := v.w;
end;

class operator TVec4i.Multiply(const v: TVec4i; k: BSFloat): TVec4f;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
  Result.w := v.w * k;
end;

class operator TVec4i.Multiply(const v: TVec4i; k: int32): TVec4i;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
  Result.w := v.w * k;
end;

class operator TVec4b.Add(const v1, v2: TVec4b): TVec4b;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4b.Subtract(const v1, v2: TVec4b): TVec4b;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := v1.w - v2.w;
end;

class operator TVec4b.Multiply(const v1, v2: TVec4b): TVec4b;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
  Result.w := v1.w * v2.w;
end;

class operator TVec4b.Multiply(const v: TVec4b; k: BSFloat): TVec4b;
begin
  Result.x := Round(v.x * k);
  Result.y := Round(v.y * k);
  Result.z := Round(v.z * k);
  Result.w := Round(v.w * k);
end;

class operator TVec4b.Multiply(const v: TVec4b; k: BSbyte): TVec4b;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
  Result.w := v.w * k;
end;

class operator TVec4b.Divide(const v1, v2: TVec4b): TVec4b;
begin
  Result.x := v1.x div v2.x;
  Result.y := v1.y div v2.y;
  Result.z := v1.z div v2.z;
  Result.w := v1.w div v2.w;
end;

class operator TVec4b.Divide (const v: TVec4b; const k: BSInt): TVec4b;
begin
  Result.x := v.x div k;
  Result.y := v.y div k;
  Result.z := v.z div k;
  Result.w := v.w div k;
end;

class operator TVec4b.Add(const v1: TVec4d; const v2: TVec4b): TVec4d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4b.Divide (const v: TVec4b; const k: BSFloat): TVec4b;
var
  k_inv: BSFloat;
begin
  k_inv := 1/k;
  Result.x := Round(v.x * k_inv);
  Result.y := Round(v.y * k_inv);
  Result.z := Round(v.z * k_inv);
  Result.w := Round(v.w * k_inv);
end;

class operator TVec4b.Equal (const v1, v2: TVec4b): boolean;
begin
  Result := CompareMem(@v1, @v2, SizeOf(TVec4b));
end;

class operator TVec4b.Implicit(const v: TVec4b): TVec4d;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := v.w;
end;

class operator TVec4b.Implicit(const v: TVec4d): TVec4b;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
  Result.z := round(v.z);
  Result.w := round(v.w);
end;

class operator TVec4b.Implicit(const v: TVec4f): TVec4b;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
  Result.z := round(v.z);
  Result.w := round(v.w);
end;

class operator TVec4b.Implicit(const v: uint32): TVec4b;
begin
  Result.value := v;
end;

function VecLen(const v: TVec4f): BSFloat;
begin
  Result := Sqrt(VecLenSqr(v));
end;

function VecLen(const v: TVec3f): BSFloat;
begin
  Result := Sqrt(VecLenSqr(v));
end;

function VecLen(const v: TVec2f): BSFloat;
begin
  Result := Sqrt(VecLenSqr(v));
end;

function VecDecisionX(const v: TVec3f): BSFloat;
begin
  Result := 360 + arctan2(v.y, v.x) * BS_RAD2DEG;
end;

function VecDecisionX(const v: TVec2i): BSFloat;
begin
  Result := VecDecisionX(vec3(v.x, v.y, 0.0));
end;

function VecDecisionY(const v: TVec3f): BSFloat;
begin
  Result := abs(arctan2(v.y, v.x));
  if v.y > 0.0 then
    Result := Result - BS_PI * 0.5
  else
    Result := BS_PI * 1.5 - Result;
  Result := Result * BS_RAD2DEG;
end;

function VecDecisionY(const v: TVec2i): BSFloat;
begin
  Result := VecDecisionY(vec3(v.x, v.y, 0.0));
end;

function VecDecisionZ(const v: TVec3f): BSFloat;
begin
  Result := abs(arctan2(v.y, v.z));
  if (v.z > 0.0) then
  begin
    if v.y < 0.0 then
      Result := (BS_PI * 0.5 - Result) + BS_PI * 1.5;
  end else
  if v.y > 0.0 then
    Result := (BS_PI * 0.5 - Result) + BS_PI * 0.5
  else
    Result := (BS_PI * 0.5 - Result) + BS_PI;
  Result := Result * BS_RAD2DEG;
end;

function VecDecision(const v: TVec2f): BSFloat;
begin
  if (abs(v.x) < EPSILON) and (abs(v.y) < EPSILON) then
    exit(0.0);
  Result := abs(arctan2(v.y, v.x));
  if v.y < 0 then
  begin
    Result := BS_PI - Result + BS_PI;
  end;
  Result := Result * BS_RAD2DEG;
end;

function VecLen(const v: TVec2i): BSFloat;
begin
  Result := Sqrt(VecLenSqr(v));
end;


function VecLen(const v: TVec4i): BSint;
begin
  Result := Round(Sqrt(VecLenSqr(v)));
end;

{$if sizeof(BSFloat) <> sizeof(double)}
function VecScale(const v, scale: TVec3d): TVec3d;
begin
  Result.x := v.x * scale.x;
  Result.y := v.y * scale.y;
  Result.z := v.z * scale.z;
end;
{$endif}

function VecRound(const v: TVec4f; Precition: int32): TVec4f;
begin
  Result.x := Round(v.x * Precition) / Precition;
  Result.y := Round(v.y * Precition) / Precition;
  Result.z := Round(v.z * Precition) / Precition;
  Result.w := Round(v.w * Precition) / Precition;
end;

// Cross product/векторное произведение
function VecCross(const u, v: TVec3f): TVec3f;
begin
  Result.x := u.y*v.z - u.z*v.y;
  Result.y := u.z*v.x - u.x*v.z;
  Result.z := u.x*v.y - u.y*v.x;
end;

function VecCross(const p0, p1, p2: TVec3f): TVec3f;
begin
  Result := VecCross(p1 - p0, p2 - p0);
end;

{$if sizeof(BSFloat) <> sizeof(double)}
function VecCross(const u, v: TVec3d): TVec3d;
begin
  Result := Vec3(
    u.y*v.z - u.z*v.y,
    u.z*v.x - u.x*v.z,
    u.x*v.y - u.y*v.x
  );
end;
{$endif}

function VecDot(const u, v: TVec2f): BSFloat;
begin
  Result := u.x * v.x + u.y * v.y;
end;

// dot product/скал€рное произведение
function VecDot(const u, v: TVec3f): BSFloat;
begin
  Result := u.x * v.x + u.y * v.y + u.z * v.z;
end;

{$if sizeof(BSFloat) <> sizeof(double)}
function VecDot(const u, v: TVec3d): double;
begin
  Result := u.x * v.x + u.y * v.y + u.z * v.z;
end;
{$endif}

function VecDot(const u, v: TVec4f): BSFloat;
begin
  Result := u.x * v.x + u.y * v.y + u.z * v.z + u.w * v.w;
end;

function VecDot(const Plane: TVec4f; const v: TVec3f): BSFloat;
begin
  Result := Plane.x * v.x + Plane.y * v.y + Plane.z * v.z + Plane.w;
end;

{$if sizeof(BSFloat) <> sizeof(double)}
function VecDot(const Plane: TVec4f; const v: TVec3d): double;
begin
  Result := Plane.x * v.x + Plane.y * v.y + Plane.z * v.z + Plane.w;
end;
{$endif}

function VecNormalize(const v: TVec2f): TVec2f;
var
  mag: extended;
begin
  mag := 1 / VecLen(v);
  Result.x := v.x * mag;
  Result.y := v.y * mag;
end;

function VecNormalize(const v: TVec3f): TVec3f;
var
  mag, l: extended;
begin
  l := VecLen(v);
  if l > EPSILON then
    mag := 1 / l
  else
    mag := 0.0;
  Result.x := v.x * mag;
  Result.y := v.y * mag;
  Result.z := v.z * mag;
end;

function VecNormalize(const v: TVec4f): TVec4f;
var
  mag: extended;
begin
  mag := 1 / VecLen(v);
  Result.x := v.x * mag;
  Result.y := v.y * mag;
  Result.z := v.z * mag;
  Result.w := v.w * mag;
end;

function VecScale(const v, scale: TVec3f): TVec3f;
begin
  Result.x := v.x * scale.x;
  Result.y := v.y * scale.y;
  Result.z := v.z * scale.z;
end;

function VecLenSqr(const v: TVec3f): BSFloat;
begin
  Result := Sqr(v.x) + Sqr(v.y) + Sqr(v.z);
end;

{$if sizeof(BSFloat) <> sizeof(double)}
function VecLenSqr(const v: TVec3d): double;
begin
  Result := Sqr(v.x) + Sqr(v.y) + Sqr(v.z);
end;
{$endif}

function VecLenSqr(const v: TVec3i): BSFloat;
begin
  Result := Sqr(v.x) + Sqr(v.y) + Sqr(v.z);
end;

function VecLenSqr(const v: TVec2f): BSFloat;
begin
  Result := Sqr(v.x) + Sqr(v.y);
end;

function VecLenSqr(const v: TVec2i): BSint;
begin
  Result := Sqr(v.x) + Sqr(v.y);
end;

function VecLenSqr(const v: TVec4f): BSFloat;
begin
  Result := Sqr(v.x) + Sqr(v.y) + Sqr(v.z) + Sqr(v.w);
end;

function VecLenSqr(const v: TVec4i): BSFloat;
begin
  Result := Sqr(v.x) + Sqr(v.y) + Sqr(v.z) + Sqr(v.w);
end;

class operator TMatrix4f.Add (const A, B: TMatrix4f): TMatrix4f;
var
  j: int8;
begin
  for j := 0 to 3 do
    Result.V4[j] := A.V4[j] + B.V4[j];
end;

class operator TMatrix4f.Subtract (const A, B: TMatrix4f): TMatrix4f;
var
  j: int8;
begin
  for j := 0 to 3 do
    Result.V4[j] := A.V4[j] - B.V4[j];
end;

class operator TMatrix4f.Multiply(const A: TMatrix4f; const B: TVec3f): TVec3f;
begin
  Result.X := A.M[0, 0] * B.x + A.M[1, 0] * B.y + A.M[2, 0] * B.z + A.M[3, 0];
  Result.Y := A.M[0, 1] * B.x + A.M[1, 1] * B.y + A.M[2, 1] * B.z + A.M[3, 1];
  Result.Z := A.M[0, 2] * B.x + A.M[1, 2] * B.y + A.M[2, 2] * B.z + A.M[3, 2];
end;

{$if sizeof(BSFloat) <> sizeof(double)}
class operator TMatrix4f.Multiply(const A: TMatrix4f; const B: TVec3d): TVec3d;
begin
  Result.X := A.M[0, 0] * B.x + A.M[1, 0] * B.y + A.M[2, 0] * B.z + A.M[3, 0];
  Result.Y := A.M[0, 1] * B.x + A.M[1, 1] * B.y + A.M[2, 1] * B.z + A.M[3, 1];
  Result.Z := A.M[0, 2] * B.x + A.M[1, 2] * B.y + A.M[2, 2] * B.z + A.M[3, 2];
end;
{$endif}

class operator TMatrix4f.Multiply(const A: TMatrix4f; const B: TVec4f): TMatrix4f;
begin
  Result.M0 := A.M0 * B;
  Result.M1 := A.M1 * B;
  Result.M2 := A.M2 * B;
  Result.M3 := A.M3 * B;
end;

class operator TMatrix4f.Multiply (const A, B: TMatrix4f): TMatrix4f;
begin
  Result.V[ 0] := A.M0.x * B.M0.x + A.M0.y * B.M1.x + A.M0.z * B.M2.x + A.M0.w * B.M3.x;
  Result.V[ 1] := A.M0.x * B.M0.y + A.M0.y * B.M1.y + A.M0.z * B.M2.y + A.M0.w * B.M3.y;
  Result.V[ 2] := A.M0.x * B.M0.z + A.M0.y * B.M1.z + A.M0.z * B.M2.z + A.M0.w * B.M3.z;
  Result.V[ 3] := A.M0.x * B.M0.w + A.M0.y * B.M1.w + A.M0.z * B.M2.w + A.M0.w * B.M3.w;

  Result.V[ 4] := A.M1.x * B.M0.x + A.M1.y * B.M1.x + A.M1.z * B.M2.x + A.M1.w * B.M3.x;
  Result.V[ 5] := A.M1.x * B.M0.y + A.M1.y * B.M1.y + A.M1.z * B.M2.y + A.M1.w * B.M3.y;
  Result.V[ 6] := A.M1.x * B.M0.z + A.M1.y * B.M1.z + A.M1.z * B.M2.z + A.M1.w * B.M3.z;
  Result.V[ 7] := A.M1.x * B.M0.w + A.M1.y * B.M1.w + A.M1.z * B.M2.w + A.M1.w * B.M3.w;

  Result.V[ 8] := A.M2.x * B.M0.x + A.M2.y * B.M1.x + A.M2.z * B.M2.x + A.M2.w * B.M3.x;
  Result.V[ 9] := A.M2.x * B.M0.y + A.M2.y * B.M1.y + A.M2.z * B.M2.y + A.M2.w * B.M3.y;
  Result.V[10] := A.M2.x * B.M0.z + A.M2.y * B.M1.z + A.M2.z * B.M2.z + A.M2.w * B.M3.z;
  Result.V[11] := A.M2.x * B.M0.w + A.M2.y * B.M1.w + A.M2.z * B.M2.w + A.M2.w * B.M3.w;

  Result.V[12] := A.M3.x * B.M0.x + A.M3.y * B.M1.x + A.M3.z * B.M2.x + A.M3.w * B.M3.x;
  Result.V[13] := A.M3.x * B.M0.y + A.M3.y * B.M1.y + A.M3.z * B.M2.y + A.M3.w * B.M3.y;
  Result.V[14] := A.M3.x * B.M0.z + A.M3.y * B.M1.z + A.M3.z * B.M2.z + A.M3.w * B.M3.z;
  Result.V[15] := A.M3.x * B.M0.w + A.M3.y * B.M1.w + A.M3.z * B.M2.w + A.M3.w * B.M3.w;

end;

class operator TMatrix4f.Multiply(const A: TMatrix4f; const k: BSFloat): TMatrix4f;
var
  i: int8;
begin
  for i := 0 to 15 do
    Result.V[i] := A.V[i]*k;
end;

class operator TMatrix4f.Divide (const A, B: TMatrix4f): TMatrix4f;
var
  i, j: int8;
begin
  for j := 0 to 3 do
    for i := 0 to 3 do
      Result.M[i, j] := A.M[0, j] / B.M[i, 0] + A.M[1, j] / B.M[i, 1] + A.M[2, j] /
        B.M[i, 2];
end;

class operator TMatrix4f.Explicit(const A: TMatrix3f): TMatrix4f;
begin
  Result.M0 := A.M0;
  Result.M1 := A.M1;
  Result.M2 := A.M2;
end;

class operator TMatrix4f.Implicit(const A: TMatrix4f): TMatrix3f;
begin
  Result.V3[0] := TVec3f(A.V4[0]);
  Result.V3[1] := TVec3f(A.V4[1]);
  Result.V3[2] := TVec3f(A.V4[2]);
end;

{ TMatrix2f }

class operator TMatrix2f.Multiply(const M: TMatrix2f; const V: TVec2f): TVec2f;
begin
  Result.X := M.M[0, 0] * V.x + M.M[1, 0] * V.y;
  Result.Y := M.M[0, 1] * V.x + M.M[1, 1] * V.y;
end;

class operator TMatrix2f.Multiply(const M: TMatrix2f; const V: TVec3f): TVec3f;
begin
  Result.X := M.M[0, 0] * V.x + M.M[1, 0] * V.y;
  Result.Y := M.M[0, 1] * V.x + M.M[1, 1] * V.y;
  Result.Z := V.z;
end;

{ TMatrix3f }

class operator TMatrix3f.Multiply(const A, B: TMatrix3f): TMatrix3f;
begin
  Result.V[0] := A.V[0]*B.V[0] + A.V[1]*B.V[3] + A.V[2]*B.V[6];
  Result.V[1] := A.V[0]*B.V[1] + A.V[1]*B.V[4] + A.V[2]*B.V[7];
  Result.V[2] := A.V[0]*B.V[2] + A.V[1]*B.V[5] + A.V[2]*B.V[8];
  Result.V[3] := A.V[3]*B.V[0] + A.V[4]*B.V[3] + A.V[5]*B.V[6];
  Result.V[4] := A.V[3]*B.V[1] + A.V[4]*B.V[4] + A.V[5]*B.V[7];
  Result.V[5] := A.V[3]*B.V[2] + A.V[4]*B.V[5] + A.V[5]*B.V[8];
  Result.V[6] := A.V[6]*B.V[0] + A.V[7]*B.V[3] + A.V[8]*B.V[6];
  Result.V[7] := A.V[6]*B.V[1] + A.V[7]*B.V[4] + A.V[8]*B.V[7];
  Result.V[8] := A.V[6]*B.V[2] + A.V[7]*B.V[5] + A.V[8]*B.V[8];
end;

class operator TMatrix3f.Multiply(const M: TMatrix3f; const V: TVec3f): TVec3f;
begin
  Result.X := M.M[0, 0] * V.x + M.M[1, 0] * V.y + M.M[2, 0] * V.z;
  Result.Y := M.M[0, 1] * V.x + M.M[1, 1] * V.y + M.M[2, 1] * V.z;
  Result.Z := M.M[0, 2] * V.x + M.M[1, 2] * V.y + M.M[2, 2] * V.z;
end;

class operator TMatrix3f.Multiply(const V: TVec3f; const M: TMatrix3f): TVec3f;
begin
  Result := M * V;
end;

class operator TMatrix3f.Multiply(const M: TMatrix3f; const V: TVec2f): TVec2f;
begin
  Result.X := M.M[0, 0] * V.x + M.M[1, 0] * V.y + M.M[2, 0];
  Result.Y := M.M[0, 1] * V.x + M.M[1, 1] * V.y + M.M[2, 1];
end;

function VecLen(const v: TVec3i): BSint;
begin
  Result := Round(Sqrt(VecLenSqr(v)));
end;

function Plane(const p1, p2, p3: TVec3f): TVec4f;
var
  n: TVec3f;
begin
  n := VecCross(p2 - p1, p3 - p1);
  Result.w := (n.x*(-p1.x) + n.y*(-p1.y) + n.z*(-p1.z));
  Result.x := n.x;
  Result.y := n.y;
  Result.z := n.z;
end;

function Plane(const Normal, Origin: TVec3f): TVec4f;
begin
  Result.x := Normal.x;
  Result.y := Normal.y;
  Result.z := Normal.z;
  Result.w := (Normal.x*(-Origin.x) + Normal.y*(-Origin.y) + Normal.z*(-Origin.z));
end;

function Plane(const Triangle: TTriangle3f): TVec4f;
begin
  Result := Plane(Triangle.A, Triangle.B, Triangle.C);
end;

function PlaneNormalize(const p1, p2, p3: TVec3f): TVec4f;
var
  n: TVec3f;
begin
  n := VecNormalize(VecCross(p2 - p1, p3 - p1));
  Result.w := n.x*(-p1.x) + n.y*(-p1.y) + n.z*(-p1.z);
  Result.x := n.x;
  Result.y := n.y;
  Result.z := n.z;
end;


function PlaneCrossProduct(const Plane1, Plane2, Plane3: TVec4f; out Intersect: boolean): TVec3f;
var
  m: TMatrix3f;
  B: TVec3f;
begin

  m.M0.x := Plane1.x;
  m.M0.y := Plane1.y;
  m.M0.z := Plane1.z;

  m.M1.x := Plane2.x;
  m.M1.y := Plane2.y;
  m.M1.z := Plane2.z;

  m.M2.x := Plane3.x;
  m.M2.y := Plane3.y;
  m.M2.z := Plane3.z;

  if not MatrixInvert(m) then
  begin
    Intersect := false;
    exit(Vec3(0.0, 0.0, 0.0));
  end;

  B.x := Plane1.w;
  B.y := Plane2.w;
  B.z := Plane3.w;

  Result.x := -VecDot(m.M0, B);
  Result.y := -VecDot(m.M1, B);
  Result.z := -VecDot(m.M2, B);
end;

function PlaneCrossProduct(const Plane: TVec4f; const OriginVector: TVec3f;
  const DirNormal: TVec3f; out Intersect: boolean; out Distance: BSFloat
  ): TVec3f;
var
  v: TVec3f;
  cos, l: BSFloat;
begin
  v := TVec3f(Plane);
  cos := VecDot(v, DirNormal);
  Intersect := abs(cos) > EPSILON;
  if Intersect then
  begin
    Distance := PlaneDotProduct(Plane, OriginVector);
    l := abs(Distance/cos);
    Result := OriginVector + DirNormal * l;
  end else
    Result := Vec3(0.0, 0.0, 0.0);
end;

function PlanePointProjection(const Plane: TVec4f; const OriginVector: TVec3f; out Distance: BSFloat): TVec3f; overload;
begin
  Distance := PlaneDotProduct(Plane, OriginVector);
  Result := OriginVector - TVec3f(Plane) * Distance;
end;

function PlaneCrossProduct(const Plane: TVec4f; const OriginVector: TVec3f;
  const DirNormal: TVec3f; out Distance: BSFloat; out Intersect: boolean): TVec3f;
var
  n: TVec3f;
  c, t: BSFloat;
begin
  // p = org + t * dir
  // t = (-D - (N, org)) / (N, dir)

  Distance := PlaneDotProduct(Plane, OriginVector);
  { The Plane MUST NOT be normalized }
  n := TVec3f(Plane);
  c := VecDot(n, DirNormal);
  if c > EPSILON then
  begin
    if Distance < 0 then
    begin
      Intersect := true;
      t := abs(Distance/c);
      Result := OriginVector + DirNormal * t;
    end else
    begin
      Intersect := false;
      Result := Vec3(0.0, 0.0, 0.0);
    end;
  end else
  if Distance > 0 then
  begin
    Intersect := true;
    t := abs(Distance/c);
    Result := OriginVector - DirNormal * t;
  end else
  begin
    Intersect := false;
    Result := Vec3(0.0, 0.0, 0.0);
  end;
end;

procedure Convert3Dto2D(const OriginXYZO, PointOX, PointOY, PointOZ: TVec3f; const Origin: TVec3f; out X, Y: BSFloat);
var
  pl: TVec4f;
begin
  pl := PlaneNormalize(OriginXYZO, PointOY, PointOZ);
  x := PlaneDotProduct(pl, Origin);
  //PlanePointProjection(pl, Origin, X);
  pl := PlaneNormalize(PointOX, OriginXYZO, PointOZ);
  y := PlaneDotProduct(pl, Origin);
  //PlanePointProjection(pl, Origin, Y);
end;

function PlaneDotProduct(const Plane: TVec4f; const V: TVec3f): BSFloat;
begin
  Result := Plane.x * V.x + Plane.y * V.y + Plane.z * V.z + Plane.w;
end;

function PlaneMinDistanceToBB(const Plane: TVec4f; const BB: PBox3f): BSFloat; inline;
var
  p: TBBPoints;
  d: BSFloat;
  pstv, ngntv: boolean;
begin
  Result := 99999999;
  pstv := false;
  ngntv := false;
  for p := Low(TBBPoints) to High(TBBPoints) do
  begin
    d := PlaneDotProduct(Plane, vec3(BB^.Named[APROPRIATE_BB_POINTS[p, 0]],
      BB^.Named[APROPRIATE_BB_POINTS[p, 1]], BB^.Named[APROPRIATE_BB_POINTS[p, 2]]));
    if d >= 0 then
      pstv := true else
      ngntv := true;
    if d < Result then
      Result := d;
  end;

  if pstv and ngntv then
  begin
    { frustum intersect BB }
    Result := 0.0;
  end;
end;

function PlaneMaxDistanceToBB(const Plane: TVec4f; const BB: PBox3f): BSFloat;
var
  p: TBBPoints;
  d: BSFloat;
begin
  Result := PlaneDotProduct(Plane, vec3(BB^.Named[APROPRIATE_BB_POINTS[pXmaxYminZmin, 0]],
    BB^.Named[APROPRIATE_BB_POINTS[pXmaxYminZmin, 1]], BB^.Named[APROPRIATE_BB_POINTS[pXmaxYminZmin, 2]]));
  for p := Low(TBBPoints) to pXmaxYmaxZmin do
  begin
    d := PlaneDotProduct(Plane, vec3(BB^.Named[APROPRIATE_BB_POINTS[p, 0]],
      BB^.Named[APROPRIATE_BB_POINTS[p, 1]], BB^.Named[APROPRIATE_BB_POINTS[p, 2]]));
    if d > Result then
      Result := d;
  end;
end;

{

function PlaneCrossProduct(const Plane: TVec4f; OriginVector: TVec3d;
  DirNormal: TVec3d; out Intetsect: boolean): TVec3d;
var
  d: double;
begin
  Intetsect := abs(VecDot(Plane, DirNormal)) > EPSILON;
  d := VecDot(Plane, OriginVector);
  if (Intetsect) then
    begin
    if (d > EPSILON) or (d < -EPSILON) then
      begin // calc cross point
      Result := DirNormal * (1 / d);
      end else
      begin // origin vector begin from plane
      Result := OriginVector;
      end;
    end else
    begin
    if (d > EPSILON) or (d < -EPSILON) then
      begin // in parallel
      FillChar(Result, SizeOf(Result), 0);
      end else
      begin // vector in plane
      Intetsect := true;
      Result := OriginVector;
      end;
    end;
end;

function PlaneCrossProduct(const Plane: TVec4f; Ray: TRay3f; out Intetsect: boolean): TVec3f;
begin
  Result := PlaneCrossProduct(Plane, Ray.Position, Ray.Direction, Intetsect);
end;

function PlaneCrossProduct(const PlanePoint1, PlanePoint2, PlanePoint3: TVec3f;
  Ray: TRay3f; out Intetsect: boolean): TVec3f;
begin
  Result := PlaneCrossProduct(PlaneNormalize(PlanePoint1, PlanePoint2, PlanePoint3), Ray.Position, Ray.Direction, Intetsect);
end;

function PlaneCrossProduct(const PlaneTriangle: PTriangle3f; Ray: TRay3f; out Intetsect: boolean): TVec3f;
begin
  Result := PlaneCrossProduct(PlaneNormalize(PlaneTriangle), Ray.Position, Ray.Direction, Intetsect);
end;

function PlaneCrossProduct(const PlaneTriangle: PTriangle3f; Ray: TRay3d; out
  Intetsect: boolean): TVec3d;
begin
  Result := PlaneCrossProduct(PlaneNormalize(PlaneTriangle), Ray.Position, Ray.Direction, Intetsect);
end;  }

function VecToStr(const v: TVec2f): string;
begin
  Result := '(' + FloatToStr(v.x) + '; ' + FloatToStr(v.y) + ')';
end;

function VecToStr(const v: TVec2i): string;
begin
  Result := '(' + IntToStr(v.x) + '; ' + IntToStr(v.y) + ')';
end;

function VecToStr(const v: TVec3f): string;
begin
  Result := '(' + Format('%f', [v.x]) + '; ' + Format('%f', [v.y]) + '; ' + Format('%f', [v.z]) + ')';
end;

function VecToStr(const v: TVec4f): string;
begin
  Result := '(' + Format('%.6f; ', [v.x]) + Format('%.6f; ', [v.y]) + Format('%.6f; ', [v.z]) + Format('%.6f', [v.w]) + ')';
end;

function VecToStr(const v: TVec4f; Precision: int8): string;
begin
  Result := '(' + Format('%.'+ IntToStr(Precision) +'f; ', [v.x]) + Format('%.'+ IntToStr(Precision) +'f; ', [v.y]) + Format('%.'+ IntToStr(Precision) +'f; ', [v.z]) + Format('%.'+ IntToStr(Precision) +'f', [v.w]) + ')';
end;


function Triangle(A, B, C: TVec3f): TTriangle3f;
begin
  Result.A := A;
  Result.B := B;
  Result.C := C;
end;

procedure FastCopy(S, D: Pointer; Count: NativeInt);
type
  pPage8192 = ^TPage8192;
  TPage8192 = record
    page: array[0..8191] of byte;
  end;

  pPage1024 = ^TPage1024;
  TPage1024 = record
    page: array[0..1023] of byte;
  end;
var
	i, m, m2: NativeInt;
  d_l, s_l: pPage8192;
begin

	if (Count <= 0) or (S = D) or (s = nil) or (d = nil) then
  	exit;

  d_l := pPage8192(D);
  s_l := pPage8192(S);
	for i := 0 to (Count div SizeOf(TPage8192)) - 1 do //
  begin  //copy by 8192
    d_l^ := s_l^;
    inc(s_l);
    inc(d_l);
    end;

  m := Count mod SizeOf(TPage8192);
	for i := 0 to m div SizeOf(TPage1024) - 1 do //
  begin  //copy remainder from 8192 by 1024
    pPage1024(d_l)^ := pPage1024(s_l)^;
    inc(pPage1024(s_l));
    inc(pPage1024(d_l));
    end;
  
  m2 := m mod SizeOf(TPage1024);
	for i := 0 to m2 div SizeOf(NativeInt) - 1 do //
  begin //copy reamainder from 1024 by word
    PNativeInt(d_l)^ := PNativeInt(s_l)^;
    inc(PNativeInt(s_l));
    inc(PNativeInt(d_l));
    end;

	for i := 0 to m2 mod SizeOf(NativeInt) - 1 do
  begin //copy remainder from word
    pByte(d_l)^ := pByte(s_l)^;
    inc(pByte(s_l));
    inc(pByte(d_l));
    end;

end;

function Vec2(x, y: BSFloat): TVec2f;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec2(x, y: BSInt): TVec2i;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec2(x, y: BSInt64): TVec2i64;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec2(x, y: UInt32): TVec2ui;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec3(x, y, z: BSFloat): TVec3f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec2d(x, y: double): TVec2d;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec3(x, y, z: BSInt): TVec3i;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec4(x, y, z, w: byte): TVec4b;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.a := w;
end;

function Vec4(v: TVec3f; w: BSFloat): TVec4f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := w;
end;

function Vec4(v: TVec3b; w: byte): TVec4b;
begin
 Result.x := v.x;
 Result.y := v.y;
 Result.z := v.z;
 Result.a := w;
end;

function Vec4(const V1, V2: TVec2f): TVec4f;
begin
  Result.v2f1 := V1;
  Result.v2f2 := V2;
end;

function Vec3(x, y, z: byte): TVec3b;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec3d(x, y, z: double): TVec3d;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec4(x, y, z, w: BSFloat): TVec4f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Vec4d(x, y, z, w: Double): TVec4d; overload; inline;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Vec4(x, y, z, w: BSInt): TVec4i;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function RectBS(Left, Top, Width, Height: BSFloat): TRectBSf;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Width := Width;
  Result.Height := Height;
end;

function RectBSd(Left, Top, Width, Height: double): TRectBSd;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Width := Width;
  Result.Height := Height;
end;

function RectBS(Left, Top, Width, Height: int64): TRectBSi64;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Width := Width;
  Result.Height := Height;
end;

function RectBS(LeftTop: TVec2f; Width, Height: BSFloat): TRectBSf;
begin
  Result.Position := LeftTop;
  Result.Width := Width;
  Result.Height := Height;
end;

function RectBS(LeftTop, Size: TVec2f): TRectBSf;
begin
  Result.Position := LeftTop;
  Result.Size := Size;
end;

function RectBS(Left, Top, Width, Height: int32): TRectBSi;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Width := Width;
  Result.Height := Height;
end;

function RectToUV(WidthTexture, HeightTexture: int32; const RectTexture: TRectBSi
  ): TRectBSf;
begin
  Result := RectBS(RectTexture.X/WidthTexture, RectTexture.Y/HeightTexture,
    RectTexture.Width/WidthTexture, RectTexture.Height/HeightTexture);
end;

function RectToUV(WidthTexture, HeightTexture: int32; const RectTexture: TRectBSf
  ): TRectBSf;
begin
  Result := RectBS(RectTexture.X/WidthTexture, RectTexture.Y/HeightTexture,
    RectTexture.Width/WidthTexture, RectTexture.Height/HeightTexture);
end;

function RectIntersect(const Rect1, Rect2: TRectBSi): boolean;
begin
  Result := (
    ((Rect1.X < Rect2.X + Rect2.Width ) and (Rect1.X >= Rect2.X)  or
     (Rect2.X < Rect1.X + Rect1.Width ) and (Rect2.X >= Rect1.X)) and
    ((Rect1.Y < Rect2.Y + Rect2.Height) and (Rect1.Y >= Rect2.Y)  or
     (Rect2.Y < Rect1.Y + Rect1.Height) and (Rect2.Y >= Rect1.Y))
  );
end;

function RectIntersect(const Rect1, Rect2: TRectBSf): boolean;
begin
  Result := (
    ((Rect1.X < Rect2.X + Rect2.Width ) and (Rect1.X >= Rect2.X)  or
     (Rect2.X < Rect1.X + Rect1.Width ) and (Rect2.X >= Rect1.X)) and
    ((Rect1.Y < Rect2.Y + Rect2.Height) and (Rect1.Y >= Rect2.Y)  or
     (Rect2.Y < Rect1.Y + Rect1.Height) and (Rect2.Y >= Rect1.Y))
  );
end;

function RectIntersect(const Rect1, Rect2: TRectBSi64): boolean;
begin
  Result := (
    ((Rect1.X < Rect2.X + Rect2.Width ) and (Rect1.X >= Rect2.X)  or
     (Rect2.X < Rect1.X + Rect1.Width ) and (Rect2.X >= Rect1.X)) and
    ((Rect1.Y < Rect2.Y + Rect2.Height) and (Rect1.Y >= Rect2.Y)  or
     (Rect2.Y < Rect1.Y + Rect1.Height) and (Rect2.Y >= Rect1.Y))
  );
end;

function RectIntersect(const Rect1, Rect2: TRectBSd): boolean;
begin
  Result :=
    (not ((Rect1.x + Rect1.Width < Rect2.x) or (Rect2.x + Rect2.Width < Rect1.x))) and
    (not ((Rect1.y + Rect1.Height < Rect2.y) or (Rect2.y + Rect2.Height < Rect1.y)));
end;

function RectContains(const RectContainsing, RectContainsed: TRectBSi): boolean;
var
  r: TRectBSi;
begin
  r := RectOverlap(RectContainsing, RectContainsed);
  Result := (r.Width = RectContainsed.Width) and (r.Height = RectContainsed.Height);
end;

function RectContains(const RectContainsing, RectContainsed: TRectBSf): boolean;
var
  r: TRectBSf;
begin
  r := RectOverlap(RectContainsing, RectContainsed);
  Result := (r.Width = RectContainsed.Width) and (r.Height = RectContainsed.Height);
end;

function RectContains(const RectContainsing: TRectBSf; Contained: TVec2f): boolean;
begin
  Result := (Contained.x >= RectContainsing.X) and (Contained.x <= RectContainsing.X + RectContainsing.Width) and
    (Contained.y >= RectContainsing.Y) and (Contained.y <= RectContainsing.Y + RectContainsing.Height);
end;

function RectContains(const RectMin, RectMax: TVec3f; Contained: TVec2f): boolean;
begin
  Result := (Contained.x >= RectMin.X) and (Contained.x <= RectMax.x) and
    (Contained.y >= RectMin.Y) and (Contained.y <= RectMax.y);
end;

function RectOverlap(const Rect1, Rect2: TRectBSf): TRectBSf;
begin
  Result.X := bs.math.Max(Rect1.X, Rect2.X);
  Result.Y := bs.math.Max(Rect1.Y, Rect2.Y);
  Result.Width := bs.math.Min(Rect1.X + Rect1.Width, Rect2.X + Rect2.Width) - Result.X;
  if Result.Width < 0 then
    Result.Width := 0;
  Result.Height := bs.math.Min(Rect1.Y + Rect1.Height, Rect2.Y + Rect2.Height) - Result.Y;
  if Result.Height < 0 then
    Result.Height := 0;
end;

function RectOverlap(const Rect1, Rect2: TRectBSd): TRectBSd;
begin
  Result.X := bs.math.Max(Rect1.X, Rect2.X);
  Result.Y := bs.math.Max(Rect1.Y, Rect2.Y);
  Result.Width := bs.math.Min(Rect1.X + Rect1.Width, Rect2.X + Rect2.Width) - Result.X;
  if Result.Width < 0 then
    Result.Width := 0;
  Result.Height := bs.math.Min(Rect1.Y + Rect1.Height, Rect2.Y + Rect2.Height) - Result.Y;
  if Result.Height < 0 then
    Result.Height := 0;
end;

function RectOverlap(const Rect1, Rect2: TRectBSi): TRectBSi;
begin
  Result.X := bs.math.Max(Rect1.X, Rect2.X);
  Result.Y := bs.math.Max(Rect1.Y, Rect2.Y);
  Result.Width := bs.math.Min(int32(Rect1.X + Rect1.Width), Rect2.X + Rect2.Width) - Result.X;
  if Result.Width < 0 then
    Result.Width := 0;
  Result.Height := bs.math.Min(int32(Rect1.Y + Rect1.Height), Rect2.Y + Rect2.Height) - Result.Y;
  if Result.Height < 0 then
    Result.Height := 0;
end;

function OverlapLines(const Line1, Line2: TVec2f): BSFloat;
begin
  Result := bs.math.Max(Line1.left, Line2.left);
  Result := bs.math.Min(Line1.right, Line2.right) - Result;
end;


function RectUnion(const Rect1, Rect2: TRectBSf): TRectBSf;
begin
  Result.X := bs.math.Min(Rect1.X, Rect2.X);
  Result.Y := bs.math.Min(Rect1.Y, Rect2.Y);
  Result.Width := bs.math.Max(Rect1.X + Rect1.Width, Rect2.X + Rect2.Width) - Result.X;
  Result.Height := bs.math.Max(Rect1.Y + Rect1.Height, Rect2.Y + Rect2.Height) - Result.Y;
end;

procedure RectOffset(var Rect: TRectBSf; const Offset: TVec2f);
begin
  Rect.Position := Rect.Position + Offset;
end;

function AngleEulerClamp(Angle: BSFLoat): BSFLoat;
begin
  Result := abs(Angle);
  if Result > 360 then
    Result := Result - round(Result / 360) * 360 else
    begin
    if Angle < 0 then
      Result := 360 + Angle else
      Result := Angle;
    end;
  if (Result > 359.998) and (Result <= 360.0) then
    Result := 0.0;
end;

function AngleEulerClamp3d(const Angle: TVec3f): TVec3f;
begin
  Result.x := AngleEulerClamp(Angle.x);
  Result.y := AngleEulerClamp(Angle.y);
  Result.z := AngleEulerClamp(Angle.z);
end;

function htonl(value: uint32): uint32;
var
  p1, p2: pByte;
begin
  p1 := pByte(@value);
  p2 := pByte(@Result);
  p2[0] := p1[3];
  p2[1] := p1[2];
  p2[2] := p1[1];
  p2[3] := p1[0];
end;

function htons(value: uint16): uint16;
var
  p1, p2: pByte;
begin
  p1 := pByte(@value);
  p2 := pByte(@Result);
  p2[0] := p1[1];
  p2[1] := p1[0];
end;

function ReadInt32(Buf: pByte; var Offset: int32; Flip: boolean): int32;
begin
  if Flip then
    Result := int32(htonl(PInteger(Buf + Offset)^))
  else
    Result := PInteger(Buf + Offset)^;
  inc(Offset, 4);
end;

function ReadInt16(Buf: pByte; var Offset: int32; Flip: boolean): int16;
begin
  if Flip then
    Result := int16(htons(PWord(Buf + Offset)^))
  else
    Result := int16(PWord(Buf + Offset)^);
  inc(Offset, 2);
end;

function Read2Dot14(Buf: pByte; var Offset: int32; Flip: boolean): BSFloat;
var
  u16: uint16;
  mant: int16;
begin
  u16 := ReadUInt16(Buf, Offset, Flip);
  mant := (u16 and $4000) shr 14;
  Result := mant + (u16 and $3FFF) * 0.00006103515625; {1/16384};
  if u16 and $8000 > 0 then
    Result := -Result;
end;

function Read26Dot6(Buf: pByte; var Offset: int32; Deploy: boolean = false): Double; inline;
var
  u32: uint32;
  mant: uint32;
begin
  u32 := ReadUInt32(Buf, Offset, Deploy);
  mant := (u32 and $FFFFC0) shr 6;
  Result := mant + (u32 and $3F) * 0.015625 {1/64};
end;

function ReadInt8(Buf: pByte; var Offset: int32): int8;
begin
  Result := int8((Buf + Offset)^);
  inc(Offset);
end;

function ReadUInt32(Buf: pByte; var Offset: int32; Flip: boolean): uint32;
begin
  if Flip then
    Result := htonl(PCardinal(Buf + Offset)^)
  else
    Result := PCardinal(Buf + Offset)^;
  inc(Offset, 4);
end;

function ReadUInt16(Buf: pByte; var Offset: int32; Flip: boolean): uint16;
begin
  if Flip then
    Result := htons(PWord(Buf + Offset)^)
  else
    Result := PWord(Buf + Offset)^;
  inc(Offset, 2);
end;

function ReadUInt8(Buf: pByte; var Offset: int32): uint8;
begin
  Result := (Buf + Offset)^;
  inc(Offset);
end;

class operator TMatrix3f.Multiply(const M: TMatrix3f; const k: BSFloat): TMatrix3f;
begin
  Result.V[0] := M.V[0]*k;
  Result.V[1] := M.V[1]*k;
  Result.V[2] := M.V[2]*k;
  Result.V[3] := M.V[3]*k;
  Result.V[4] := M.V[4]*k;
  Result.V[5] := M.V[5]*k;
  Result.V[6] := M.V[6]*k;
  Result.V[7] := M.V[7]*k;
  Result.V[8] := M.V[8]*k;
end;

{ TMatrix4f }

function MatrixEqual(const A, B: TMatrix4f): Boolean;
begin
  Result := CompareMem(@A, @B, SizeOf(TMatrix4f));
end;

procedure Matrix4fRotate(var Matrix: TMatrix4f; Angle: BSFloat; x, y, z: BSFloat); overload; inline;
var
  sinAngle, cosAngle, mag: BSFloat;
  xx, yy, zz, xy, yz, zx, xs, ys, zs: BSFloat;
  oneMinusCos: BSFloat;
  rotMat: TMatrix4f;
begin
  mag := sqrt(x * x + y * y + z * z);
  BS_SinCos(Angle, sinAngle, cosAngle); // * BS_DEG2RAD
  //sinAngle := BS_Sinf(angle);
  //cosAngle := BS_Cosf (angle);
  if ( mag > 0.0 ) then
  begin

     x := x / mag;
     y := y / mag;
     z := z / mag;

     xx := x * x;
     yy := y * y;
     zz := z * z;
     xy := x * y;
     yz := y * z;
     zx := z * x;
     xs := x * sinAngle;
     ys := y * sinAngle;
     zs := z * sinAngle;
     oneMinusCos := 1.0 - cosAngle;

     //rotMat := IDENTITY_MAT;

     rotMat.m[0, 0] := (oneMinusCos * xx) + cosAngle;
     rotMat.m[0, 1] := (oneMinusCos * xy) - zs;
     rotMat.m[0, 2] := (oneMinusCos * zx) + ys;
     rotMat.m[0, 3] := 0.0;

     rotMat.m[1, 0] := (oneMinusCos * xy) + zs;
     rotMat.m[1, 1] := (oneMinusCos * yy) + cosAngle;
     rotMat.m[1, 2] := (oneMinusCos * yz) - xs;
     rotMat.m[1, 3] := 0.0;

     rotMat.m[2, 0] := (oneMinusCos * zx) - ys;
     rotMat.m[2, 1] := (oneMinusCos * yz) + xs;
     rotMat.m[2, 2] := (oneMinusCos * zz) + cosAngle;
     rotMat.m[2, 3] := 0.0;

     rotMat.m[3, 0] := 0.0;
     rotMat.m[3, 1] := 0.0;
     rotMat.m[3, 2] := 0.0;
     rotMat.m[3, 3] := 1.0;
     Matrix := rotMat * Matrix;
  end;
end;

// build atrix rotate
procedure MatrixRotateCreate(var Matrix: TMatrix4f; Angle: TVec3f); overload; inline;
var
  A,B,C,D,E,F,AD,BD: BSFloat;
begin

  BS_SinCos(Angle.x, B, A);
  BS_SinCos(Angle.y, D, C);
  BS_SinCos(Angle.z, F, E);

  AD := A * D;
  BD := B * D;

  Matrix.V[ 0] :=  C * E;           Matrix.V[ 1] := -C * F;           Matrix.V[ 2] := -D;      Matrix.V[ 3] := 0;
  Matrix.V[ 4] := -BD * E + A * F;  Matrix.V[ 5] :=  BD * F + A * E;  Matrix.V[ 6] := -B * C;  Matrix.V[ 7] := 0;
  Matrix.V[ 8] :=  AD * E + B * F;  Matrix.V[ 9] := -AD * F + B * E;  Matrix.V[10] :=  A * C;  Matrix.V[11] := 0;
  Matrix.V[12] :=  0;               Matrix.V[13] :=  0;               Matrix.V[14] :=  0;      Matrix.V[15] := 1;
end;

// translate quaternion to mantrix
procedure QuaternionToMatrix(var Matrix: TMatrix4f; const Quaternion: TQuaternion);
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2: BSFloat;
begin
  x2 := Quaternion.x + Quaternion.x;
  y2 := Quaternion.y + Quaternion.y;
  z2 := Quaternion.z + Quaternion.z;
  xx := Quaternion.x * x2;   xy := Quaternion.x * y2;   xz := Quaternion.x * z2;
  yy := Quaternion.y * y2;   yz := Quaternion.y * z2;   zz := Quaternion.z * z2;
  wx := Quaternion.w * x2;   wy := Quaternion.w * y2;   wz := Quaternion.w * z2;

  Matrix.V[0] := 1.0 - (yy + zz);
  Matrix.V[1] := (xy - wz);
  Matrix.V[2] := (xz + wy);
  Matrix.V[4] := (xy + wz);
  Matrix.V[5] := 1.0 - (xx + zz);
  Matrix.V[6] := (yz - wx);
  Matrix.V[8] := (xz - wy);
  Matrix.V[9] := (yz + wx);
  Matrix.V[10] := 1.0 - (xx + yy);

  Matrix.V[3]  := 0;
  Matrix.V[7]  := 0;
  Matrix.V[11] := 0;
  Matrix.V[12] := 0;
  Matrix.V[13] := 0;
  Matrix.V[14] := 0;
  Matrix.V[15] := 1;
end;

procedure QuaternionToMatrix(var Matrix: TMatrix3f; const Quaternion: TQuaternion);
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2: BSFloat;
begin
  x2 := Quaternion.x + Quaternion.x;
  y2 := Quaternion.y + Quaternion.y;
  z2 := Quaternion.z + Quaternion.z;
  xx := Quaternion.x * x2;   xy := Quaternion.x * y2;   xz := Quaternion.x * z2;
  yy := Quaternion.y * y2;   yz := Quaternion.y * z2;   zz := Quaternion.z * z2;
  wx := Quaternion.w * x2;   wy := Quaternion.w * y2;   wz := Quaternion.w * z2;

  Matrix.V[0] := 1.0 - (yy + zz);
  Matrix.V[1] := (xy - wz);
  Matrix.V[2] := (xz + wy);
  Matrix.V[3] := (xy + wz);
  Matrix.V[4] := 1.0 - (xx + zz);
  Matrix.V[5] := (yz - wx);
  Matrix.V[6] := (xz - wy);
  Matrix.V[7] := (yz + wx);
  Matrix.V[8] := 1.0 - (xx + yy);
end;

function QuaternionToAngles(const Quaternion: TQuaternion): TVec3f;
var
  half_a, sin_ha: Single;
begin
  //angle      := arccos( Quaternion.a ) * BS_RAD2DEG;
  {sin_angle  := sqrt( 1.0 - Quaternion.w * Quaternion.w );

  if ( abs( sin_angle ) < EPSILON ) then
   sin_angle := 1;

  Result.x := (Quaternion.x / sin_angle) * 90.0;
  Result.y := (Quaternion.y / sin_angle) * 90.0;
  Result.z := (Quaternion.z / sin_angle) * 90.0;  }

  half_a := ArcCos(Quaternion.w);

  sin_ha := Sin(half_a);

  if ( abs( sin_ha ) < EPSILON ) then
    sin_ha := 1.0
  else
    sin_ha := 1 / sin_ha;
  Result := vec3(Rad2Deg(Quaternion.x * sin_ha), Rad2Deg(Quaternion.y * sin_ha), Rad2Deg(Quaternion.z * sin_ha));
end;

function QuaternionToVec(const Quaternion: TQuaternion): TVec3f;
var
  t: BSFloat;
begin
  t := 1.0 - Quaternion.w * Quaternion.w;
  if(t < EPSILON) then
    exit(vec3(0.0, 0.0, 1.0));
  t := 1.0 / sqrt(t);
  Result := vec3(Quaternion.x * t, Quaternion.y * t, Quaternion.z * t);
end;


function Quaternion(const Angles: TVec3f): TQuaternion;
var
  cx, cy, cz: BSFloat;
  sx, sy, sz: BSFloat;
begin

  //BS_SinCos( 0.5 * Angles.x, sx, cx );
  //BS_SinCos( 0.5 * Angles.y, sy, cy );
  //BS_SinCos( 0.5 * Angles.z, sz, cz );

  SinCos( BS_DEG2RAD * 0.5 * Angles.x, sx, cx );
  SinCos( BS_DEG2RAD * 0.5 * Angles.y, sy, cy );
  SinCos( BS_DEG2RAD * 0.5 * Angles.z, sz, cz );

  Result.x := sx * cy * cz - cx * sy * sz;
	Result.y := cx * sy * cz + sx * cy * sz;
  Result.z := cx * cy * sz - sx * sy * cz;
	Result.w := cx * cy * cz + sx * sy * sz;
  //Result := VecNormalize(Result);
  //Result := QuaternionMult(QuaternionZ(Angles.z), QuaternionMult(QuaternionY(Angles.y), QuaternionX(Angles.x)));
end;

function Quaternion(const Angles: TVec3f; First: TRotateSequence;
    Second: TRotateSequence; Third: TRotateSequence): TQuaternion;
var
  qs: array[0..2] of TQuaternion;
begin
  qs[0] := QUATERNION_EULER_METHODS[First](Angles.p[int8(First)]);
  qs[1] := QUATERNION_EULER_METHODS[Second](Angles.p[int8(Second)]);
  qs[2] := QUATERNION_EULER_METHODS[Third](Angles.p[int8(Third)]);
  Result := QuaternionMult(qs[0], QuaternionMult(qs[1], qs[2]));
end;

function Quaternion(const AMatrix: TMatrix4f): TQuaternion;
var
  diagonal: BSFloat;
  d4: BSFloat;
begin
  diagonal := AMatrix.M0.x + AMatrix.M1.y + AMatrix.M2.z;
  if (diagonal > 0) then
  begin
    d4 := sqrt(diagonal + 1.0) * 2.0;
    Result.x := (AMatrix.M2.y - AMatrix.M1.z) / d4;
    Result.y := (AMatrix.M0.z - AMatrix.M2.x) / d4;
    Result.z := (AMatrix.M1.x - AMatrix.M0.y) / d4;
    Result.w := d4 / 4.0;
  end else
  if ((AMatrix.M0.x > AMatrix.M1.y) and (AMatrix.M0.x > AMatrix.M2.z)) then
  begin
    d4 := sqrt(1.0 + AMatrix.M0.x - AMatrix.M1.y - AMatrix.M2.z) * 2.0;
    Result.x := d4 / 4.0;
    Result.y := (AMatrix.M0.y + AMatrix.M1.x) / d4;
    Result.z := (AMatrix.M0.z + AMatrix.M2.x) / d4;
    Result.w := (AMatrix.M2.y - AMatrix.M1.z) / d4;
  end else
  if (AMatrix.M1.y > AMatrix.M2.z) then
  begin
    d4 := sqrt(1.0 + AMatrix.M1.y - AMatrix.M0.x - AMatrix.M2.z) * 2.0;
    Result.x := (AMatrix.M0.y + AMatrix.M1.x) / d4;
    Result.y := d4 / 4.0;
    Result.z := (AMatrix.M1.z + AMatrix.M2.y) / d4;
    Result.w := (AMatrix.M0.z - AMatrix.M2.x) / d4;
  end else
  begin
    d4 := sqrt(1.0 + AMatrix.M2.z - AMatrix.M0.x - AMatrix.M1.y) * 2.0;
    Result.x := (AMatrix.M0.z + AMatrix.M2.x) / d4;
    Result.y := (AMatrix.M1.z + AMatrix.M2.y) / d4;
    Result.z := d4 / 4.0;
    Result.w := (AMatrix.M1.x - AMatrix.M0.y) / d4;
  end;
end;

function QuaternionInverse(const Angles: TVec3f): TQuaternion;
begin
  Result := QuaternionMult(QuaternionX(Angles.x), QuaternionMult(QuaternionZ(Angles.z), QuaternionY(Angles.y)));
end;

function QuaternionX(const Angle: BSFloat): TQuaternion;
begin
  BS_SinCos(Angle * 0.5, Result.x, Result.w);
  Result.y := 0;
  Result.z := 0;
end;

function QuaternionY(const Angle: BSFloat): TQuaternion;
begin
  BS_SinCos(Angle * 0.5, Result.y, Result.w);
  Result.x := 0;
  Result.z := 0;
end;

function QuaternionZ(const Angle: BSFloat): TQuaternion;
begin
  BS_SinCos(Angle * 0.5, Result.z, Result.w);
  Result.y := 0;
  Result.x := 0;
end;

function QuaternionMult(const q1, q2: TQuaternion): TQuaternion;
var
  a, b, c, d: BSFloat;
begin
  a := (q1.x + q1.z) * (q2.x + q2.y);
  b := (q1.x - q1.z) * (q2.x - q2.y);
  c := (q1.w + q1.y) * (q2.w - q2.z);
  d := (q1.w - q1.y) * (q2.w + q2.z);

  Result.w :=  ((q1.z - q1.y) * (q2.y - q2.z)) + (-a - b + c + d) * 0.5;
  Result.x :=  ((q1.w + q1.x) * (q2.w + q2.x)) - ( a + b + c + d) * 0.5;
  Result.y := -((q1.x - q1.w) * (q2.y + q2.z)) + ( a - b + c - d) * 0.5;
  Result.z := -((q1.y + q1.z) * (q2.x - q2.w)) + ( a - b - c + d) * 0.5;
  //Result := VecNormalize(Result);

  {Result.a := q1.a * q2.a - q1.X * q2.X - q1.Y * q2.Y - q1.Z * q2.Z;
  Result.X := q1.a * q2.X + q2.a * q1.X + q1.Y * q2.Z - q1.Z * q2.Y;
  Result.Y := q1.a * q2.Y + q2.a * q1.Y + q1.Z * q2.X - q1.X * q2.Z;
  Result.Z := q1.a * q2.Z + q2.a * q1.Z + q1.X * q2.Y - q1.Y * q2.X;  }
end;

function QuaternionInvert(Quaternion: TQuaternion): TQuaternion;
var
  len: BSFloat;
begin
  len := (1.0 / ((Quaternion.x * Quaternion.x) +
                    (Quaternion.y * Quaternion.y) +
                    (Quaternion.z * Quaternion.z) +
                    (Quaternion.w * Quaternion.w)));
  Result := Quaternion * -len;
  Result.w := -Result.w;
end;

function GetArcTan(t0, t1: BSFloat): BSFloat; inline;
const
  EPS = 0.001;
begin
  if abs(t0) < EPS then
  begin
    Result := 0;
  end else
  if abs(t1) < EPS then
  begin
    Result := 0;
  end else
  begin
    Result := ArcTan2(t0, t1);
    if Result < 0 then
      Result := Result + 2*BS_PI;
  end;
  Result := AngleEulerClamp(Rad2Deg(Result));
end;

procedure QuaternionToEulerianAngle(const Q: TQuaternion; var Roll, Pitch, Yaw: BSFloat); overload;
const
  Threshold = (0.5 - 0.0001);
var
  tst: BSFloat;
  t0, t1: BSFloat;
  //xy, zw: BSFloat;
  xz, yy, yw: BSFloat;
begin

  {Roll := Rad2Deg(ArcSin(Q.x));
  Pitch := Rad2Deg(ArcSin(Q.y));
  Yaw := Rad2Deg(ArcSin(Q.z));

  exit;}

  yw := Q.w * Q.y;
  xz := Q.z * Q.x;
  yy := Q.y * Q.y;
  t0 := yw + xz;
  tst := (yw - xz);
	//t0 := 2.0 * (yw - xz);
  if (t0 > Threshold) or (t0 < -Threshold) then // (tst > Threshold) or (tst < -Threshold) or
  begin
    //Pitch := GetArcTan(t0, t1);
    if (t0 < 0) or (tst < 0) then
      Pitch := 270.0 else
      Pitch := 90.0;
    //Roll := AngleEulerClamp(Rad2Deg( 2 * ArcTan2(Q.x * Q.y - Q.w * Q.z, t0))); // (
    {t0 := 2.0 * (Q.w * Q.x + Q.y * Q.z);
    //t1 := 1.0 - 2.0 * (Q.x * Q.y - Q.w * Q.z);
    t1 := 1.0 - 2.0 * (Q.x * Q.x + Q.z * Q.z);
    Roll := GetArcTan(t0, t1);
    //Yaw := 0;
    t0 := 2.0 * (Q.w * Q.z - Q.y * Q.x);
    //t1 := 1.0 - 2.0 * (yy + Q.x * Q.x);
    Yaw := GetArcTan(t0, t1);}
  end else
  begin
    t0 := t0*2.0;
    // pitch (y-axis rotation)
    Pitch := Rad2Deg(ArcSin(t0));
    {if abs(t0) < 0.5 then
      begin
      if t0 < 0 then
        Pitch := abs(Pitch) + 180.0 else
        Pitch := 180.0 - Pitch;
      end else
      begin
      if t0 < 0 then
        Pitch := abs(Pitch) + 180.0 else
        Pitch := 180.0 - Pitch;
      end; }
    //t1 := 1.0 - 2.0 * (Q.x * Q.x + yy);
    //Pitch := GetArcTan(t0, t1);
    // roll (x-axis rotation)
    t0 := 2.0 * (Q.w * Q.x + Q.y * Q.z);
    t1 := 1.0 - 2.0 * (Q.x * Q.x + yy);
    Roll := GetArcTan(t0, t1);
    if Roll <> 0 then
      Roll := Roll;
	  // yaw (z-axis rotation)
    t0 := 2.0 * (Q.w * Q.z + Q.x * Q.y);
    t1 := 1.0 - 2.0 * (yy + Q.z * Q.z);
    Yaw := GetArcTan(t0, t1);
  end;
  {
  yw := Q.w * Q.y;
  xz := Q.z * Q.x;
  yy := Q.y * Q.y;
  t0 := yw + xz;
  tst := (yw - xz);
	//t0 := 2.0 * (yw - xz);
  if (t0 > Threshold) or (tst > Threshold) or (tst < -Threshold) or (t0 < -Threshold) then //
    begin
    //Pitch := GetArcTan(t0, t1);
    if (t0 < 0) or (tst < 0) then
      Pitch := 270.0 else
      Pitch := 90.0;
    //Roll := AngleEulerClamp(Rad2Deg( 2 * ArcTan2(Q.x * Q.y - Q.w * Q.z, t0))); // (
    t0 := 2.0 * (Q.w * Q.x + Q.y * Q.z);
    //t1 := 1.0 - 2.0 * (Q.x * Q.y - Q.w * Q.z);
    t1 := 1.0 - 2.0 * (Q.x * Q.x + Q.z * Q.z);
    Roll := GetArcTan(t0, t1);
    //Yaw := 0;
    t0 := 2.0 * (Q.w * Q.z - Q.y * Q.x);
    //t1 := 1.0 - 2.0 * (yy + Q.x * Q.x);
    Yaw := GetArcTan(t0, t1);
    end else
    begin
    t0 := t0*2.0;
    // pitch (y-axis rotation)
    //Pitch := ArcSin(t0);
    t1 := 1.0 - 2.0 * (Q.x * Q.x + yy);
    Pitch := GetArcTan(t0, t1);
	  //Pitch := AngleEulerClamp(Rad2Deg(Pitch));
    // roll (x-axis rotation)
    t0 := 2.0 * (Q.w * Q.x + Q.y * Q.z);
    //t1 := 1.0 - 2.0 * (Q.x * Q.x + yy);
    Roll := GetArcTan(t0, t1);
    if Roll <> 0 then
      Roll := Roll;
	  // yaw (z-axis rotation)
    t0 := 2.0 * (Q.w * Q.z + Q.x * Q.y);
    t1 := 1.0 - 2.0 * (yy + Q.z * Q.z);
    Yaw := GetArcTan(t0, t1);
    end;
    }

end;

procedure QuaternionToEulerianAngle(const Q: TQuaternion; var Angles: TVec3f);overload;
begin
  QuaternionToEulerianAngle(Q, Angles.x, Angles.y, Angles.z);
end;

function QuaternionYaw(Q: TQuaternion):BSFloat;
begin
  Result := ArcTan2(2.0 * (Q.y * Q.z + Q.w * Q.x), Q.w * Q.w - Q.x * Q.x - Q.y * Q.y + Q.z * Q.z);
  if (Q.y > 0.0) then // (Q.z < 0.0) or
    Result := Result - BS_PI;
  Result := Rad2Deg(Result);
end;

function QuaternionPitch(Q: TQuaternion): BSFloat;
begin
  Result := ArcSin(2.0 * (Q.w * Q.y - Q.x * Q.z));
  if Q.x > 0 then
    begin
    if Q.z < 0 then
      Result := Result + BS_PI / 2;
    end else
  if Q.z < 0 then
    Result := Result + BS_PI else
    Result := Result + 3 * BS_PI/2;
  Result := Rad2Deg(Result);
end;

function QuaternionRoll(Q: TQuaternion): BSFloat;
begin
  Result := ArcTan2(2.0 * (Q.x * Q.y + Q.w * Q.z), Q.w * Q.w + Q.x * Q.x - Q.y * Q.y - Q.z * Q.z);
  //if (Q.y < 0.0) then //(Q.z < 0.0) or
  //  Result := BS_PI - abs(Result);
	Result := Rad2Deg(Result);
end;

function QuaternionSLERP(const q1, q2: TQuaternion; a: BSFloat): TQuaternion;
var
  dot: BSFloat;
  a_inv: BSFloat;
begin
  dot := VecDot(q1, q2);
	a_inv := 1.0 - a;
  if (dot < 0) then
  begin
    Result.w := a_inv * q1.w + a * -q2.w;
    Result.x := a_inv * q1.x + a * -q2.x;
    Result.y := a_inv * q1.y + a * -q2.y;
    Result.z := a_inv * q1.z + a * -q2.z;
  end else
  begin
    Result.w := a_inv * q1.w + a * q2.w;
    Result.x := a_inv * q1.x + a * q2.x;
    Result.y := a_inv * q1.y + a * q2.y;
    Result.z := a_inv * q1.z + a * q2.z;
  end;
end;

function QuaternionNLERP(const q1, q2: TQuaternion; a: BSFloat): TQuaternion;
begin
  Result := VecNormalize(QuaternionSLERP(q1, q2, a));
end;

function QuaternionMultiplyVector(Quaternion: TQuaternion; Vector: TVec3f): TVec3f;
var
  vectorQuat, inverseQuat, resultQuat: TQuaternion;
begin

  vectorQuat.x := Vector.x;
  vectorQuat.y := Vector.y;
  vectorQuat.z := Vector.z;
  vectorQuat.w := 0.0;

  inverseQuat := QuaternionInvert(Quaternion);
  resultQuat := QuaternionMult(vectorQuat, inverseQuat);
  resultQuat := QuaternionMult(Quaternion, resultQuat);
  Result := TVec3f(resultQuat);
end;

procedure MatrixRotateCreate(var Matrix: TMatrix4f; AngleX, AngleY, AngleZ: BSFloat); overload; inline;
begin
  MatrixRotateCreate(Matrix, Vec3(AngleX, AngleY, AngleZ));
end;

function MatrixInvert(var Matrix: TMatrix4f): Boolean;
var
  M: TMatrix4f;
  A0, A1, A2, A3, A4, A5, B0, B1, B2, B3, B4, B5, D: BSFloat;
begin
  A0 := Matrix.V[ 0] * Matrix.V[ 5] - Matrix.V[ 1] * Matrix.V[ 4];
  A1 := Matrix.V[ 0] * Matrix.V[ 6] - Matrix.V[ 2] * Matrix.V[ 4];
  A2 := Matrix.V[ 0] * Matrix.V[ 7] - Matrix.V[ 3] * Matrix.V[ 4];
  A3 := Matrix.V[ 1] * Matrix.V[ 6] - Matrix.V[ 2] * Matrix.V[ 5];
  A4 := Matrix.V[ 1] * Matrix.V[ 7] - Matrix.V[ 3] * Matrix.V[ 5];
  A5 := Matrix.V[ 2] * Matrix.V[ 7] - Matrix.V[ 3] * Matrix.V[ 6];
  B0 := Matrix.V[ 8] * Matrix.V[13] - Matrix.V[ 9] * Matrix.V[12];
  B1 := Matrix.V[ 8] * Matrix.V[14] - Matrix.V[10] * Matrix.V[12];
  B2 := Matrix.V[ 8] * Matrix.V[15] - Matrix.V[11] * Matrix.V[12];
  B3 := Matrix.V[ 9] * Matrix.V[14] - Matrix.V[10] * Matrix.V[13];
  B4 := Matrix.V[ 9] * Matrix.V[15] - Matrix.V[11] * Matrix.V[13];
  B5 := Matrix.V[10] * Matrix.V[15] - Matrix.V[11] * Matrix.V[14];
  D := A0 * B5 - A1 * B4 + A2 * B3 + A3 * B2 - A4 * B1 + A5 * B0;
  if D = 0 then
    Exit(False);
  M := Matrix;
  Matrix.V[ 0] :=  M.V[ 5] * B5 - M.V[ 6] * B4 + M.V[ 7] * B3;
  Matrix.V[ 4] := -M.V[ 4] * B5 + M.V[ 6] * B2 - M.V[ 7] * B1;
  Matrix.V[ 8] :=  M.V[ 4] * B4 - M.V[ 5] * B2 + M.V[ 7] * B0;
  Matrix.V[12] := -M.V[ 4] * B3 + M.V[ 5] * B1 - M.V[ 6] * B0;
  Matrix.V[ 1] := -M.V[ 1] * B5 + M.V[ 2] * B4 - M.V[ 3] * B3;
  Matrix.V[ 5] :=  M.V[ 0] * B5 - M.V[ 2] * B2 + M.V[ 3] * B1;
  Matrix.V[ 9] := -M.V[ 0] * B4 + M.V[ 1] * B2 - M.V[ 3] * B0;
  Matrix.V[13] :=  M.V[ 0] * B3 - M.V[ 1] * B1 + M.V[ 2] * B0;
  Matrix.V[ 2] :=  M.V[13] * A5 - M.V[14] * A4 + M.V[15] * A3;
  Matrix.V[ 6] := -M.V[12] * A5 + M.V[14] * A2 - M.V[15] * A1;
  Matrix.V[10] :=  M.V[12] * A4 - M.V[13] * A2 + M.V[15] * A0;
  Matrix.V[14] := -M.V[12] * A3 + M.V[13] * A1 - M.V[14] * A0;
  Matrix.V[ 3] := -M.V[ 9] * A5 + M.V[10] * A4 - M.V[11] * A3;
  Matrix.V[ 7] :=  M.V[ 8] * A5 - M.V[10] * A2 + M.V[11] * A1;
  Matrix.V[11] := -M.V[ 8] * A4 + M.V[ 9] * A2 - M.V[11] * A0;
  Matrix.V[15] :=  M.V[ 8] * A3 - M.V[ 9] * A1 + M.V[10] * A0;
  D := 1 / D;
  Matrix.V[ 0] := Matrix.V[ 0] * D;
  Matrix.V[ 1] := Matrix.V[ 1] * D;
  Matrix.V[ 2] := Matrix.V[ 2] * D;
  Matrix.V[ 3] := Matrix.V[ 3] * D;
  Matrix.V[ 4] := Matrix.V[ 4] * D;
  Matrix.V[ 5] := Matrix.V[ 5] * D;
  Matrix.V[ 6] := Matrix.V[ 6] * D;
  Matrix.V[ 7] := Matrix.V[ 7] * D;
  Matrix.V[ 8] := Matrix.V[ 8] * D;
  Matrix.V[ 9] := Matrix.V[ 9] * D;
  Matrix.V[10] := Matrix.V[10] * D;
  Matrix.V[11] := Matrix.V[11] * D;
  Matrix.V[12] := Matrix.V[12] * D;
  Matrix.V[13] := Matrix.V[13] * D;
  Matrix.V[14] := Matrix.V[14] * D;
  Matrix.V[15] := Matrix.V[15] * D;
  Result := True;
end;

function MatrixInvert(var Matrix: TMatrix3f): Boolean;
var
  d: BSFloat;
  A: TMatrix3f;
begin
  d := MatrixDeterminant(Matrix);
  if d = 0 then
    exit(false);

  Result := true;

  d := 1/d;

  A.V3[0].x :=  (Matrix.V3[1].y * Matrix.V3[2].z - Matrix.V3[1].z * Matrix.V3[2].y);
  A.V3[0].y := -(Matrix.V3[1].x * Matrix.V3[2].z - Matrix.V3[1].z * Matrix.V3[2].x);
  A.V3[0].z :=  (Matrix.V3[1].x * Matrix.V3[2].y - Matrix.V3[1].y * Matrix.V3[2].x);

  A.V3[1].x := -(Matrix.V3[0].y * Matrix.V3[2].z - Matrix.V3[0].z * Matrix.V3[2].y);
  A.V3[1].y :=  (Matrix.V3[0].x * Matrix.V3[2].z - Matrix.V3[0].z * Matrix.V3[2].x);
  A.V3[1].z := -(Matrix.V3[0].x * Matrix.V3[2].y - Matrix.V3[0].y * Matrix.V3[2].x);

  A.V3[2].x :=  (Matrix.V3[0].y * Matrix.V3[1].z - Matrix.V3[0].z * Matrix.V3[1].y);
  A.V3[2].y := -(Matrix.V3[0].x * Matrix.V3[1].z - Matrix.V3[0].z * Matrix.V3[1].x);
  A.V3[2].z :=  (Matrix.V3[0].x * Matrix.V3[1].y - Matrix.V3[0].y * Matrix.V3[1].x);

  Matrix.V3[0].x := A.V3[0].x * d;
  Matrix.V3[0].y := A.V3[1].x * d;
  Matrix.V3[0].z := A.V3[2].x * d;

  Matrix.V3[1].x := A.V3[0].y * d;
  Matrix.V3[1].y := A.V3[1].y * d;
  Matrix.V3[1].z := A.V3[2].y * d;

  Matrix.V3[2].x := A.V3[0].z * d;
  Matrix.V3[2].y := A.V3[1].z * d;
  Matrix.V3[2].z := A.V3[2].z * d;
end;

function MatrixDeterminant(const Matrix: TMatrix3f): BSFloat;
begin
  Result :=
    (Matrix.V3[0].x * Matrix.V3[1].y * Matrix.V3[2].z) -
    (Matrix.V3[0].x * Matrix.V3[1].z * Matrix.V3[2].y) -
    (Matrix.V3[0].y * Matrix.V3[1].x * Matrix.V3[2].z) +
    (Matrix.V3[0].y * Matrix.V3[1].z * Matrix.V3[2].x) +
    (Matrix.V3[0].z * Matrix.V3[1].x * Matrix.V3[2].y) -
    (Matrix.V3[0].z * Matrix.V3[1].y * Matrix.V3[2].x);
end;

procedure MatrixTranspose(var Matrix: TMatrix4f);
var
  t: BSFloat;
begin
  t := Matrix.M[0, 1]; Matrix.M[0, 1] := Matrix.M[1, 0]; Matrix.M[1, 0] := t;
  t := Matrix.M[0, 2]; Matrix.M[0, 2] := Matrix.M[2, 0]; Matrix.M[2, 0] := t;
  t := Matrix.M[0, 3]; Matrix.M[0, 3] := Matrix.M[3, 0]; Matrix.M[3, 0] := t;
  t := Matrix.M[1, 2]; Matrix.M[1, 2] := Matrix.M[2, 1]; Matrix.M[2, 1] := t;
  t := Matrix.M[1, 3]; Matrix.M[1, 3] := Matrix.M[3, 1]; Matrix.M[3, 1] := t;
  t := Matrix.M[2, 3]; Matrix.M[2, 3] := Matrix.M[3, 2]; Matrix.M[3, 2] := t;
end;

procedure MatrixTranspose(var Matrix: TMatrix3f);
var
  t: BSFloat;
begin
  t := Matrix.M[0, 1]; Matrix.M[0, 1] := Matrix.M[1, 0]; Matrix.M[1, 0] := t;
  t := Matrix.M[0, 2]; Matrix.M[0, 2] := Matrix.M[2, 0]; Matrix.M[2, 0] := t;
  t := Matrix.M[1, 2]; Matrix.M[1, 2] := Matrix.M[2, 1]; Matrix.M[2, 1] := t;
end;

procedure MatrixScale(var Matrix: TMatrix4f; X, Y, Z: BSFloat);
begin
  Matrix.V[ 0] := Matrix.V[ 0] * X;
  Matrix.V[ 1] := Matrix.V[ 1] * Y;
  Matrix.V[ 2] := Matrix.V[ 2] * Z;
  Matrix.V[ 3] := Matrix.V[ 3];
  Matrix.V[ 4] := Matrix.V[ 4] * X;
  Matrix.V[ 5] := Matrix.V[ 5] * Y;
  Matrix.V[ 6] := Matrix.V[ 6] * Z;
  Matrix.V[ 7] := Matrix.V[ 7];
  Matrix.V[ 8] := Matrix.V[ 8] * X;
  Matrix.V[ 9] := Matrix.V[ 9] * Y;
  Matrix.V[10] := Matrix.V[10] * Z;
  Matrix.V[11] := Matrix.V[11];
  Matrix.V[12] := Matrix.V[12] * X;
  Matrix.V[13] := Matrix.V[13] * Y;
  Matrix.V[14] := Matrix.V[14] * Z;
  Matrix.V[15] := Matrix.V[15];
end;

procedure MatrixScaleAt(var Matrix: TMatrix4f; X, Y, Z: BSFloat; const Pivot: TVec3f);
begin
  MatrixTranslate(Matrix, Pivot.X, Pivot.Y, Pivot.Z);
  MatrixScale(Matrix, X, Y, Z);
  MatrixTranslate(Matrix, -Pivot.X, -Pivot.Y, -Pivot.Z);
end;

procedure MatrixTranslate(var Matrix: TMatrix4f; X, Y, Z: BSFloat);
begin
  Matrix.M[3, 0] := X;
  Matrix.M[3, 1] := Y;
  Matrix.M[3, 2] := Z;
end;

procedure MatrixTransform(var Matrix: TMatrix4f; const M: TMatrix4f);
begin
  Matrix := Matrix * M;
end;

procedure MatrixOrtho(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat);
var
  deltaX, deltaY, deltaZ: BSFloat;
begin
  deltaX := right - left;
  deltaY := top - bottom;
  deltaZ := farZ - nearZ;

  if ( (deltaX = 0.0) or (deltaY = 0.0) or (deltaZ = 0.0) ) then
    exit;
  Matrix.m[0, 0] :=  2.0 / deltaX;
  Matrix.m[1, 1] :=  2.0 / deltaY;
  Matrix.m[2, 2] := -2.0 / deltaZ;
  Matrix.m[3, 0] := -(right + left) / deltaX;
  Matrix.m[3, 1] := -(top + bottom) / deltaY;
  Matrix.m[3, 2] := -(nearZ + farZ) / deltaZ;
end;

procedure MatrixOrtho2(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat);
var
  deltaX, deltaY, deltaZ: BSFloat;
  //ortho: TMatrix4f;
begin
  deltaX := right - left;
  deltaY := top - bottom;
  deltaZ := farZ - nearZ;

  if ( (deltaX = 0.0) or (deltaY = 0.0) or (deltaZ = 0.0) ) then
    exit;
  Matrix.m[0, 0] :=  2.0 / deltaX;
  Matrix.m[1, 1] :=  2.0 / deltaY;
  Matrix.m[2, 2] :=  1.0 / deltaZ;
  Matrix.m[3, 3] :=  1.0;
  Matrix.m[2, 3] := - nearZ * Matrix.m[2, 2];
  Matrix.m[3, 0] := -(right + left) / deltaX;
  Matrix.m[3, 1] := -(top + bottom) / deltaY;
  Matrix.m[3, 2] := -(nearZ + farZ) * Matrix.m[2, 2];
end;

procedure MatrixPerspective(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat);
var
  deltaX, deltaY, deltaZ: BSFloat;
begin
  deltaX := right - left;
  deltaY := top 	- bottom;
  deltaZ := farZ 	- nearZ;

  Matrix.m[0, 0] :=  2.0 / deltaX;
  Matrix.m[1, 1] :=  2.0 / deltaY;

  Matrix.m[2, 2] := -(nearZ + farZ) / deltaZ;
  Matrix.m[2, 3] := -1.0;

  Matrix.m[3, 2] := -2.0 * nearZ * farZ / deltaZ;
  Matrix.m[3, 3] := 0.0;
end;

procedure MatrixPerspective(var Matrix: TMatrix4f; fovy, aspect, nearZ, farZ: BSFloat);
var
  deltaZ: BSFloat;
  frustumW, frustumH: BSFloat;
begin
  deltaZ := farZ - nearZ;
  if (deltaZ <= 0.0) then
      exit;
  // calculate half edges
  frustumH := tan( fovy * 0.00872664626 ) * nearZ;   //BS_PI / 360.0
  frustumW := frustumH * aspect;

  Matrix.m[0, 0] := nearZ / frustumW;
  Matrix.m[1, 1] := nearZ / frustumH;

  Matrix.m[2, 2] := -(nearZ + farZ) / deltaZ;
  Matrix.m[2, 3] := -1.0;

  Matrix.m[3, 2] := -2.0 * nearZ * farZ / deltaZ;
  Matrix.m[3, 3] := 0.0;
end;

procedure MatrixFrustum(var Matrix: TMatrix4f; left, right, bottom, top, nearZ, farZ: BSFloat);
var
  deltaX, deltaY, deltaZ: BSFloat;
  frust: TMatrix4f;
begin
  deltaX := right - left;
  deltaY := top - bottom;
  deltaZ := farZ - nearZ;
  if ((nearZ <= 0.0) or (farZ <= 0.0) or
    (deltaX <= 0.0) or (deltaY <= 0.0) or (deltaZ <= 0.0)) then
      exit;

  frust.m[0, 0] := 2.0 * nearZ / deltaX;
  frust.m[0, 1] := 0.0;
  frust.m[0, 2] := 0.0;
  frust.m[0, 3] := 0.0;

  frust.m[1, 1] := 2.0 * nearZ / deltaY;
  frust.m[1, 0] := 0.0;
  frust.m[1, 2] := 0.0;
  frust.m[1, 3] := 0.0;

  frust.m[2, 0] :=  (right + left) / deltaX;
  frust.m[2, 1] :=  (top + bottom) / deltaY;
  frust.m[2, 2] := -(nearZ + farZ) / deltaZ;
  frust.m[2, 3] := -1.0;

  frust.m[3, 2] := -2.0 * nearZ * farZ / deltaZ;
  frust.m[3, 0] := 0.0;
  frust.m[3, 1] := 0.0;
  frust.m[3, 3] := 0.0;
  Matrix := frust * Matrix;
end;

function Box2Collision(const Box1, Box2: TBox2d): boolean;
{var
  _max, _min: double;  }
begin
  {_min := bs.math.Max(Box1.Min.x, Box2.Min.x);
  _max := bs.math.Min(Box1.Max.x, Box2.Max.x);
  if (_min >= _max) then
    exit(false);
  _min := bs.math.Max(Box1.Min.y, Box2.Min.y);
  _max := bs.math.Min(Box1.Max.y, Box2.Max.y);
  if (_min >= _max) then
    exit(false);
  Result := true;  }
  Result :=
    (not ((Box1.Max.x < Box2.Min.x) or (Box2.Max.x < Box1.Min.x))) and
    (not ((Box1.Max.y < Box2.Min.y) or (Box2.Max.y < Box1.Min.y)));
end;

function Box3Collision(const Box1, Box2: TBox3f): boolean;
{var
  _max, _min: double;}
begin
  {_min := bs.math.Max(Box1.Min.x, Box2.Min.x);
  _max := bs.math.Min(Box1.Max.x, Box2.Max.x);
  if (_min >= _max) then
    exit(false);
  _min := bs.math.Max(Box1.Min.y, Box2.Min.y);
  _max := bs.math.Min(Box1.Max.y, Box2.Max.y);
  if (_min >= _max) then
    exit(false);
  _min := bs.math.Max(Box1.Min.z, Box2.Min.z);
  _max := bs.math.Min(Box1.Max.z, Box2.Max.z);
  if (_min >= _max) then
    exit(false);
  Result := true;   }
  Result :=
    (not ((Box1.x_max < Box2.x_min) or (Box2.x_max < Box1.x_min))) and
    (not ((Box1.y_max < Box2.y_min) or (Box2.y_max < Box1.y_min))) and
    (not ((Box1.z_max < Box2.z_min) or (Box2.z_max < Box1.z_min)));
end;

function Box3Collision(const Box1, Box2: TBox3d): boolean;
{var
  _max, _min: double;     }
begin
  {_min := bs.math.Max(Box1.Min.x, Box2.Min.x);
  _max := bs.math.Min(Box1.Max.x, Box2.Max.x);
  if (_min >= _max) then
    exit(false);
  _min := bs.math.Max(Box1.Min.y, Box2.Min.y);
  _max := bs.math.Min(Box1.Max.y, Box2.Max.y);
  if (_min >= _max) then
    exit(false);
  _min := bs.math.Max(Box1.Min.z, Box2.Min.z);
  _max := bs.math.Min(Box1.Max.z, Box2.Max.z);
  if (_min >= _max) then
    exit(false);
  Result := true;  }
  Result :=
    (not ((Box1.x_max < Box2.x_min) or (Box2.x_max < Box1.x_min))) and
    (not ((Box1.y_max < Box2.y_min) or (Box2.y_max < Box1.y_min))) and
    (not ((Box1.z_max < Box2.z_min) or (Box2.z_max < Box1.z_min)));
end;

function Box3Inside(const Box, BoxInside: TBox3f): boolean;
begin
  Result :=
    (BoxInside.x_max < Box.x_max) and
    (BoxInside.y_max < Box.y_max) and
    (BoxInside.z_max < Box.z_max) and
    (BoxInside.x_min > Box.x_min) and
    (BoxInside.y_min > Box.y_min) and
    (BoxInside.z_min > Box.z_min);
end;

function Box3Inside(const Box: TBox3f; const InsideTri: TTriangle3f): boolean;
begin
  Result := Box3PointIn(Box, InsideTri.A) and Box3PointIn(Box, InsideTri.B) and Box3PointIn(Box, InsideTri.C);
end;

function Box3Inside(const Box: TBox3f; const InsideTriA, InsideTriB, InsideTriC: TVec3f): boolean;
begin
  Result := Box3PointIn(Box, InsideTriA) and Box3PointIn(Box, InsideTriB) and Box3PointIn(Box, InsideTriC);
end;

function Box3Middle(const Box: TBox3f): TVec3f;
begin
  Result := vec3((Box.x_min + Box.x_max) * 0.5, (Box.y_min + Box.y_max) * 0.5, (Box.z_min + Box.z_max) * 0.5);
end;

function Box3CheckBB(var Box: TBox3f; const v: TVec3f): boolean;
begin
  Result := false;
  if v.x < Box.x_min then
  begin
    Box.x_min := v.x;
    Result := true;
  end;

  if v.x > Box.x_max then
  begin
    Box.x_max := v.x;
    Result := true;
  end;

  if v.y > Box.y_max then
  begin
    Box.y_max := v.y;
    Result := true;
  end;

  if v.y < Box.y_min then
  begin
    Box.y_min := v.y;
    Result := true;
  end;

  if v.z > Box.z_max then
  begin
    Box.z_max := v.z;
    Result := true;
  end;

  if v.z < Box.z_min then
  begin
    Box.z_min := v.z;
    Result := true;
  end;
end;

function Box3CheckBB(var WidedBox: TBox3f; const Box: TBox3f): boolean;
begin
  Result := Box3CheckBB(WidedBox, Box.Min);
  if Box3CheckBB(WidedBox, Box.Max) then
    Result := true;
end;

function Box3CheckBB(var Box: TBox3d; const v: TVec3d): boolean;
begin
  Result := false;
  if v.x < Box.x_min then
    begin
    Box.x_min := v.x;
    Result := true;
    end;
  if v.x > Box.x_max then
    begin
    Box.x_max := v.x;
    Result := true;
    end;
  if v.y > Box.y_max then
    begin
    Box.y_max := v.y;
    Result := true;
    end;
  if v.y < Box.y_min then
    begin
    Box.y_min := v.y;
    Result := true;
    end;
  if v.z > Box.z_max then
    begin
    Box.z_max := v.z;
    Result := true;
    end;
  if v.z < Box.z_min then
    begin
    Box.z_min := v.z;
    Result := true;
    end;
end;

function Box3CheckBB(var WidedBox: TBox3d; const Box: TBox3d): boolean;
begin
  Result := Box3CheckBB(WidedBox, Box.Min);
  if Box3CheckBB(WidedBox, Box.Max) then
    Result := true;
end;

function Box3PointIn(const Box: TBox3f; const Point: TVec3f): boolean;
begin
  if (Point.x < Box.x_min) or
     (Point.y < Box.y_min) or
     (Point.z < Box.z_min) or
     (Point.x > Box.x_max) or
     (Point.y > Box.y_max) or
     (Point.z > Box.z_max) then exit(false);
  Result := true;
end;

function Box3PointIn(const Box: TBox3d; const Point: TVec3d): boolean;
begin
  if (Point.x < Box.x_min) or
     (Point.y < Box.y_min) or
     (Point.z < Box.z_min) or
     (Point.x > Box.x_max) or
     (Point.y > Box.y_max) or
     (Point.z > Box.z_max) then exit(false);
  Result := true;
end;

function Box3Size(const Box: TBox3f): TVec3f;
begin
  Result.x := Box.x_max - Box.x_min;
  Result.y := Box.y_max - Box.y_min;
  Result.z := Box.z_max - Box.z_min;
end;

function Box3Size(const Box: TBox3d): TVec3d; inline;
begin
  Result.x := Box.x_max - Box.x_min;
  Result.y := Box.y_max - Box.y_min;
  Result.z := Box.z_max - Box.z_min;
end;

function Box3Volume(const Box: TBox3f): BSFloat;
var
  s: TVec3f;
begin
  s := Box3Size(Box);
  if s.x > 0 then
  begin
    if s.y > 0 then
      Result := s.x * s.y
    else
    if s.z > 0 then
      Result := s.x * s.z
    else
      Result := s.x;
  end else
  if s.y > 0 then
  begin
    if s.z > 0 then
      Result := s.y * s.z
    else
      Result := s.y;
  end else
    Result := s.z;
end;

function Box3Volume(const Box: TBox3d): double;
var
  s: TVec3d;
begin
  s := Box3Size(Box);
  if s.x > 0 then
  begin
    if s.y > 0 then
      Result := s.x * s.y
    else
    if s.z > 0 then
      Result := s.x * s.z
    else
      Result := s.x;
  end else
  if s.y > 0 then
  begin
    if s.z > 0 then
      Result := s.y * s.z
    else
      Result := s.y;
  end else
    Result := s.z;
end;

function Box3Overlap(const Box1, Box2: TBox3f): BSFloat;
var
  x, y, z: BSFloat;
begin
  x := bs.math.Min(Box1.x_max, Box2.x_max) - bs.math.Max(Box1.x_min, Box2.x_min);
  if x < 0 then
    exit(0.0);
  y := bs.math.Min(Box1.y_max, Box2.y_max) - bs.math.Max(Box1.y_min, Box2.y_min);
  if y < 0 then
    exit(0.0);
  z := bs.math.Min(Box1.z_max, Box2.z_max) - bs.math.Max(Box1.z_min, Box2.z_min);
  if z < 0 then
    exit(0.0);
  if x > 0 then
  begin
    if y > 0 then
    begin
      if z > 0 then
        Result := x * y * z
      else
        Result := x * y;
    end else
    if z > 0 then
      Result := x * z
    else
      Result := x;
  end else
  if y > 0 then
  begin
    if z > 0 then
      Result := y * z
    else
      Result := y;
  end else
    Result := z;
end;

function Box3Overlap(const Box1, Box2: TBox3d): double;
var
  x, y, z: BSFloat;
begin
  x := bs.math.Min(Box1.x_max, Box2.x_max) - bs.math.Max(Box1.x_min, Box2.x_min);
  if x < 0 then
    exit(0.0);
  y := bs.math.Min(Box1.y_max, Box2.y_max) - bs.math.Max(Box1.y_min, Box2.y_min);
  if y < 0 then
    exit(0.0);
  z := bs.math.Min(Box1.z_max, Box2.z_max) - bs.math.Max(Box1.z_min, Box2.z_min);
  if z < 0 then
    exit(0.0);
  if x > 0 then
  begin
    if y > 0 then
    begin
      if z > 0 then
        Result := x * y * z
      else
        Result := x * y;
    end else
    if z > 0 then
      Result := x * z
    else
      Result := x;
  end else
  if y > 0 then
  begin
    if z > 0 then
      Result := y * z
    else
      Result := y;
  end else
    Result := z;
end;

function Box3Union(const Box1, Box2: TBox3d): TBox3d;
begin
  Result.x_min := bs.math.Min(Box1.x_min, Box2.x_min);
  Result.y_min := bs.math.Min(Box1.y_min, Box2.y_min);
  Result.z_min := bs.math.Min(Box1.z_min, Box2.z_min);
  Result.x_max := bs.math.Max(Box1.x_max, Box2.x_max);
  Result.y_max := bs.math.Max(Box1.y_max, Box2.y_max);
  Result.z_max := bs.math.Max(Box1.z_max, Box2.z_max);
  Result.Middle := (Result.Max + Result.Min) * 0.5;
end;

function Box3Union(const Box1, Box2: TBox3f): TBox3f;
begin
  Result.x_min := bs.math.Min(Box1.x_min, Box2.x_min);
  Result.y_min := bs.math.Min(Box1.y_min, Box2.y_min);
  Result.z_min := bs.math.Min(Box1.z_min, Box2.z_min);
  Result.x_max := bs.math.Max(Box1.x_max, Box2.x_max);
  Result.y_max := bs.math.Max(Box1.y_max, Box2.y_max);
  Result.z_max := bs.math.Max(Box1.z_max, Box2.z_max);
  Result.Middle := (Result.Max + Result.Min) * 0.5;
end;

function Box3GetOverlap(const Box1, Box2: TBox3f): TBox3f;
begin
  Result.x_min := bs.math.Max(Box1.x_min, Box2.x_min);
  Result.x_max := bs.math.Min(Box1.x_max, Box2.x_max);
  Result.y_min := bs.math.Max(Box1.y_min, Box2.y_min);
  Result.y_max := bs.math.Min(Box1.y_max, Box2.y_max);
  Result.z_min := bs.math.Max(Box1.z_min, Box2.z_min);
  Result.z_max := bs.math.Min(Box1.z_max, Box2.z_max);
end;

function Box3GetOverlap(const Box1, Box2: TBox3d): TBox3d; overload; inline;
begin
  Result.x_min := bs.math.Max(Box1.x_min, Box2.x_min);
  Result.x_max := bs.math.Min(Box1.x_max, Box2.x_max);
  Result.y_min := bs.math.Max(Box1.y_min, Box2.y_min);
  Result.y_max := bs.math.Min(Box1.y_max, Box2.y_max);
  Result.z_min := bs.math.Max(Box1.z_min, Box2.z_min);
  Result.z_max := bs.math.Min(Box1.z_max, Box2.z_max);
end;

procedure Box3Recalc(var Box: TBox3f; const Matrix: TMatrix3f);
var
  p: TBBPoints;
  v: TVec3f;
  b: TBox3f;
begin
  b.Max := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 0]],
                         Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 1]],
                         Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 2]]);
  b.Min := b.Max;
  for p := TBBPoints.pXminYmaxZmax to High(TBBPoints) do
  begin
    v := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[p, 0]],
      Box.Named[APROPRIATE_BB_POINTS[p, 1]], Box.Named[APROPRIATE_BB_POINTS[p, 2]]);
    if v.x < b.x_min then
      b.x_min := v.x
    else
    if v.x > b.x_max then
      b.x_max := v.x;
    if v.y > b.y_max then
      b.y_max := v.y
    else
    if v.y < b.y_min then
      b.y_min := v.y;
    if v.z > b.z_max then
      b.z_max := v.z
    else
    if v.z < b.z_min then
      b.z_min := v.z;
  end;

  Box.Min := b.Min;
  Box.Max := b.Max;
  Box.Middle := (Box.Min + Box.Min) * 0.5;
end;

procedure Box3Recalc(var Box: TBox3f; const Matrix: TMatrix4f);
var
  p: TBBPoints;
  v: TVec3f;
  b: TBox3f;
//var
//  bb_max, bb_min: TVec3f;
begin
  b.Max := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 0]],
                         Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 1]],
                         Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 2]]);
  b.Min := b.Max;
  for p := TBBPoints.pXminYmaxZmax to High(TBBPoints) do
  begin
    v := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[p, 0]],
      Box.Named[APROPRIATE_BB_POINTS[p, 1]], Box.Named[APROPRIATE_BB_POINTS[p, 2]]);
    if v.x < b.x_min then
      b.x_min := v.x
    else
    if v.x > b.x_max then
      b.x_max := v.x;
    if v.y > b.y_max then
      b.y_max := v.y
    else
    if v.y < b.y_min then
      b.y_min := v.y;
    if v.z > b.z_max then
      b.z_max := v.z
    else
    if v.z < b.z_min then
      b.z_min := v.z;
  end;

  Box.Min := b.Min;
  Box.Max := b.Max;
  Box.Middle := (Box.Min + Box.Min) * 0.5;
  {bb_max := Matrix * Box.Max;
  bb_min := Matrix * Box.Min;
  if bb_max.x < bb_min.x then
    swap(bb_max.x, bb_min.x);
  if bb_max.y < bb_min.y then
    swap(bb_max.y, bb_min.y);
  if bb_max.z < bb_min.z then
    swap(bb_max.z, bb_min.z);
  Box.Min := bb_min;
  Box.Max := bb_max;
  Box.Middle := (bb_min + bb_max) * 0.5; }
end;

function Box3Recalc(var Box: TBox3f; const Matrix: TMatrix4f; const NearestTo: TVec3f): TVec3f;
var
  p: TBBPoints;
  v: TVec3f;
  b: TBox3f;
  delta: TVec3f;
  d: BSFloat;
begin
  b.Max := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 0]],
    Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 1]], Box.Named[APROPRIATE_BB_POINTS[TBBPoints.pXminYminZmax, 2]]);
  b.Min := b.Max;
  Result := b.Min;
  delta.x := abs(NearestTo.x - Result.x);
  delta.y := abs(NearestTo.y - Result.y);
  delta.z := abs(NearestTo.z - Result.z);
  for p := TBBPoints.pXminYmaxZmax to High(TBBPoints) do
    begin
    v := Matrix * vec3(Box.Named[APROPRIATE_BB_POINTS[p, 0]],
      Box.Named[APROPRIATE_BB_POINTS[p, 1]], Box.Named[APROPRIATE_BB_POINTS[p, 2]]);
    if v.x < b.x_min then
      b.x_min := v.x else
    if v.x > b.x_max then
      b.x_max := v.x;
    if v.y > b.y_max then
      b.y_max := v.y else
    if v.y < b.y_min then
      b.y_min := v.y;
    if v.z > b.z_max then
      b.z_max := v.z else
    if v.z < b.z_min then
      b.z_min := v.z;
    d := abs(v.x - NearestTo.x);
    if delta.x > d then
      begin
      Result.x := v.x;
      delta.x := d;
      end;
    d := abs(v.y - NearestTo.y);
    if delta.y > d then
      begin
      Result.y := v.y;
      delta.y := d;
      end;
    d := abs(v.z - NearestTo.z);
    if delta.z > d then
      begin
      Result.z := v.z;
      delta.z := d;
      end;
    end;
  Box.Min := b.Min;
  Box.Max := b.Max;
  Box.Middle := (b.Max + b.Min) * 0.5;
end;

procedure CompareMaxMinAndSwap(var Max, Min: TVec3f);
begin
  if Min.x > Max.x then
    swap(Min.x, Max.x);
  if Min.y > Max.y then
    swap(Min.y, Max.y);
  if Min.z > Max.z then
    swap(Min.z, Max.z);
end;

function Box3(const MinV, MaxV: TVec3f): TBox3f;
begin
  Result.Min := MinV;
  Result.Max := MaxV;
  Result.Middle := (MaxV + MinV) * 0.5;
end;

function Box3(const MinV, MaxV: TVec3d): TBox3d;
begin
  Result.Min := MinV;
  Result.Max := MaxV;
  Result.Middle := (MaxV + MinV) * 0.5;
end;

function Box3(const Rect: TRectBSf): TBox3f;
begin
  Result := Box3(vec3(Rect.X, Rect.Y, 0.0), vec3(Rect.X + Rect.Width, Rect.Y + Rect.Height, 0.0));
end;

function Box3(const Rect: TRectBSd): TBox3d;
begin
  Result := Box3(vec3d(Rect.X, Rect.Y, 0.0), vec3d(Rect.X + Rect.Width, Rect.Y + Rect.Height, 0.0));
end;

{ TVertexPT }

class operator TVertexPT.Implicit(const V: TVertexPT): TVertexP;
begin
  Result.Position := V.Position;
end;

{ TVec4d }

class operator TVec4d.Add(const v1, v2: TVec4d): TVec4d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4d.Divide(const v: TVec4d; const k: BSFloat): TVec4d;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
  Result.w := v.w / k;
end;

class operator TVec4d.Divide(const v1, v2: TVec4d): TVec4d;
begin
  Result.x := v1.x / v2.x;
  Result.y := v1.y / v2.y;
  Result.z := v1.z / v2.z;
  Result.w := v1.w / v2.w;
end;

class operator TVec4d.Add(const v1: TVec4d; const v2: TVec4f): TVec4d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4d.Divide(const v: TVec4d; const k: int32): TVec4d;
begin
  Result.x := v.x / k;
  Result.y := v.y / k;
  Result.z := v.z / k;
  Result.w := v.w / k;
end;

class operator TVec4d.Equal(const v1, v2: TVec4d): boolean;
begin
  Result := CompareMem(@v1, @v2, SizeOf(TVec4d));
end;

class operator TVec4d.Implicit(const v: TVec4d): TVec4f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := v.w;
end;

class operator TVec4d.Implicit(const v: TVec4f): TVec4d;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
  Result.w := v.w;
end;

class operator TVec4d.Multiply(const v: TVec4d; const k: BSFloat): TVec4d;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
  Result.z := v.z * k;
  Result.w := v.w * k;
end;

class operator TVec4d.Multiply(const v1, v2: TVec4d): TVec4d;
begin
  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
  Result.w := v1.w * v2.w;
end;

class operator TVec4d.Negative(const v: TVec4d): TVec4d;
begin
  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;
  Result.w := -v.w;
end;

class operator TVec4d.Subtract(const v1, v2: TVec4d): TVec4d;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := v1.w - v2.w;
end;

{ TRectBSi }

class operator TRectBSi.Implicit(const A: TRectBSi): TRectBSf;
begin
  Result.Left := A.Left;
  Result.Top := A.Top;
  Result.Width := A.Width;
  Result.Height := A.Height;
end;

class operator TRectBSi.Implicit(const A: TRectBSf): TRectBSi;
begin
  Result.Left := round(A.Left);
  Result.Top := round(A.Top);
  Result.Width := round(A.Width);
  Result.Height := round(A.Height);
end;

{ TRectBSi64 }

class operator TRectBSi64.Implicit(const A: TRectBSi64): TRectBSf;
begin
  Result.Left := A.Left;
  Result.Top := A.Top;
  Result.Width := A.Width;
  Result.Height := A.Height;
end;

function TRectBSi64.Contain(const Pos: TVec2i64): boolean;
begin
  Result := (Pos.x >= X) and (Pos.x < X + Width) and (Pos.y >= Y) and (Pos.y < Y + Height)
end;

function TRectBSi64.Contain(const PosX, PosY: int64): boolean;
begin
  Result := (PosX >= X) and (PosX < X + Width) and (PosY >= Y) and (PosY < Y + Height)
end;

class operator TRectBSi64.Implicit(const A: TRectBSf): TRectBSi64;
begin
  Result.Left := round(A.Left);
  Result.Top := round(A.Top);
  Result.Width := round(A.Width);
  Result.Height := round(A.Height);
end;

{$region 'TComparatorInt'}

{ TComparatorInt }

class function TOperatorsInt.Comparator(const Value1,
  Value2: int32): int8;
begin
  if Value1 < Value2 then
    Result := -1 else
  if Value1 > Value2 then
    Result := 1 else
    Result := 0;
end;

class function TOperatorsInt.Add(const Value1,
  Value2: int32): int32;
begin
  Result := Value1 + Value2;
end;

class function TOperatorsInt.Divide_float(const Value1,
  Value2: int32): bsfloat;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsInt.Divide(const Value1,
  Value2: int32): int32;
begin
  Result := Value1 div Value2;
end;

class procedure TOperatorsInt.GetOperators(var Operators: TOperators<int32>);
begin
  Operators.Add := Add;
  Operators.Comparator := Comparator;
  Operators.Subtract := Subtract;
  Operators.Multiply := Multiply;
  Operators.MultiplyInt := Multiply;
  Operators.MultiplyFloat := MultiplyFloat;
  Operators.Divide := Divide;
  Operators.DivideInt := Divide;
  Operators.DivideFloat := Divide_float;
  Operators.High := High;
  Operators.Low := Low;
  Operators.ToString := ToStringInt;
end;

class function TOperatorsInt.Multiply(const Value1,
  Value2: int32): int32;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsInt.MultiplyFloat(const Value1: int32;
  const Value2: BSFloat): int32;
begin
  Result := Round(Value1 * Value2);
end;

class function TOperatorsInt.Subtract(const Value1,
  Value2: int32): int32;
begin
  Result := Value1 - Value2;
end;

class function TOperatorsInt.ToStringInt(const Value: int32): string;
begin
  Result := IntToStr(Value);
end;

class function TOperatorsInt.High: int32;
begin
  Result := System.high(int32);
end;

class function TOperatorsInt.Low: int32;
begin
  Result := System.low(int32);
end;

{$endregion}

{$region 'TComparatorFloat'}

{ TComparatorFloat }

class function TOperatorsFloat.Add(const Value1,
  Value2: BSFloat): BSFloat;
begin
  Result := Value1 + Value2;
end;

class function TOperatorsFloat.Comparator(const Value1,
  Value2: BSFloat): int8;
begin
  if Value1 > Value2 then
    Result := 1 else
  if Value1 < Value2 then
    Result := -1 else
    Result := 0;
end;

class function TOperatorsFloat.Divide(const Value1,
  Value2: BSFloat): BSFloat;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsFloat.DivideInt(const Value1: BSFloat;
  const Value2: int32): BSFloat;
begin
  Result := Value1 / Value2;
end;

class procedure TOperatorsFloat.GetOperators(
  var Operators: TOperators<BSFloat>);
begin
  Operators.Add := Add;
  Operators.Comparator := Comparator;
  Operators.Subtract := Subtract;
  Operators.Multiply := Multiply;
  Operators.MultiplyInt := MultiplyInt;
  Operators.MultiplyFloat := Multiply;
  Operators.Divide := Divide;
  Operators.DivideFloat := Divide;
  Operators.High := High;
  Operators.Low := Low;
  Operators.ToString := ToStringFloat;
  Operators.DivideInt := DivideInt;
end;

class function TOperatorsFloat.High: BSFloat;
begin
  Result := MaxSingle;
end;

class function TOperatorsFloat.Low: BSFloat;
begin
  Result := MinSingle;
end;

class function TOperatorsFloat.Multiply(const Value1,
  Value2: BSFloat): BSFloat;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsFloat.MultiplyInt(const Value1: BSFloat;
  const Value2: int32): BSFloat;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsFloat.Subtract(const Value1,
  Value2: BSFloat): BSFloat;
begin
  Result := Value1 - Value2;
end;

class function TOperatorsFloat.ToStringFloat(const Value: BSFloat): string;
begin
  Result := Format('%f', [Value]);
end;

{$endregion}

{ TOperatorsDate }

class procedure TOperatorsDate.GetOperators(
  var Operators: TOperators<TDate>);
begin
  Operators.Add := Add;
  Operators.Comparator := Comparator;
  Operators.Subtract := Subtract;
  Operators.Multiply := Multiply;
  Operators.MultiplyInt := MultiplyInt;
  Operators.MultiplyFloat := MultiplyFloat;
  Operators.Divide := Divide;
  Operators.DivideInt := DivideInt;
  Operators.DivideFloat := Divide_float;
  Operators.High := High;
  Operators.Low := Low;
  Operators.ToString := ToStringInt;
end;

class function TOperatorsDate.Add(const Value1, Value2: TDate): TDate;
var
  days: uint32;
begin
  days := DaysBetween(Value2, (0.0));
  Result := IncDay(Value1, days);
  //Result := Value1 + Value2;
end;

class function TOperatorsDate.Comparator(const Value1, Value2: TDate): int8;
begin
  Result := CompareDateTime(Value1, Value2);
end;

class function TOperatorsDate.Divide(const Value1,
  Value2: TDate): TDate;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsDate.DivideInt(const Value1: TDate;
  const Value2: int32): TDate;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsDate.Divide_float(const Value1,
  Value2: TDate): BSFloat;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsDate.High: TDate;
begin
  Result := MaxDateTime;
end;

class function TOperatorsDate.Low: TDate;
begin
  Result := MinDateTime;
end;

class function TOperatorsDate.Multiply(const Value1,
  Value2: TDate): TDate;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsDate.MultiplyFloat(const Value1: TDate;
  const Value2: BSFloat): TDate;
var
  days: uint32;
begin
  days := DaysBetween(Value1, (0.0));
  Result := IncDay((0.0), round(days * Value2));
end;

class function TOperatorsDate.MultiplyInt(const Value1: TDate;
  const Value2: int32): TDate;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsDate.Subtract(const Value1,
  Value2: TDate): TDate;
begin
  Result := Value1 - Value2;
end;

class function TOperatorsDate.ToStringInt(const Value: TDate): string;
begin
  Result := FormatDateTime('dd.MM.yy', Value);
end;

{ TColorEnumerator }

function TColorEnumerator.CompareExceptColors: boolean;
begin
  {Result := (CompareLimit(CurrentColor.r, Scene.Color.r, 0.25) = 0) and
      (CompareLimit(CurrentColor.g, Scene.Color.g, 0.25) = 0) and
      (CompareLimit(CurrentColor.b, Scene.Color.b, 0.25) = 0);}
  Result := CurrentIndexSet in FExceptColors;
end;

function TColorEnumerator.GetNextColor: TColor4f;
begin
  IncColor;
  Result := FCurrentColor;
end;

procedure TColorEnumerator.IncColor;
begin
  inc(CurrentIndexSet);
  if CurrentIndexSet = high(TBSColors) then
    CurrentIndexSet := bsRed;
  FCurrentColor := TBSColorsSet[CurrentIndexSet];
  if (CompareExceptColors) then
    IncColor;
end;

procedure TColorEnumerator.Reset;
begin
  SetToColor(FDefaultColor);
end;

function TColorEnumerator.SetToColor(const Color: TBSColors): TColor4f;
begin
  FCurrentColor := TBSColorsSet[Color];
  CurrentIndexSet := Color;
  Result := FCurrentColor;
end;

constructor TColorEnumerator.Create(const ExceptCols: TNamedColorSet);
begin
  FExceptColors := ExceptCols;
  FDefaultColor := bsBlack;
  SetToColor(FDefaultColor);
end;

{ TOperatorsDateTime }

class function TOperatorsDateTime.Add(const Value1,
  Value2: TDateTime): TDateTime;
begin
  Result := Value1 + Value2;
end;

class function TOperatorsDateTime.Comparator(const Value1,
  Value2: TDateTime): int8;
begin
  Result := CompareDateTime(Value1, Value2);
end;

class function TOperatorsDateTime.Divide(const Value1,
  Value2: TDateTime): TDateTime;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsDateTime.DivideInt(const Value1: TDateTime;
  const Value2: int32): TDateTime;
begin
  Result := Value1 / Value2;
end;

class function TOperatorsDateTime.Divide_float(const Value1,
  Value2: TDateTime): BSFloat;
begin
  Result := Value1 / Value2;
end;

class procedure TOperatorsDateTime.GetOperators(
  var Operators: TOperators<TDateTime>);
begin
  Operators.Add := Add;
  Operators.Comparator := Comparator;
  Operators.Subtract := Subtract;
  Operators.Multiply := Multiply;
  Operators.MultiplyInt := MultiplyInt;
  Operators.MultiplyFloat := MultiplyFloat;
  Operators.Divide := Divide;
  Operators.DivideInt := DivideInt;
  Operators.DivideFloat := Divide_float;
  Operators.High := High;
  Operators.Low := Low;
  Operators.ToString := ToStringInt;
end;

class function TOperatorsDateTime.High: TDateTime;
begin
  Result := MaxDateTime;
end;

class function TOperatorsDateTime.Low: TDateTime;
begin
  Result := MinDateTime;
end;

class function TOperatorsDateTime.Multiply(const Value1,
  Value2: TDateTime): TDateTime;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsDateTime.MultiplyFloat(const Value1: TDateTime;
  const Value2: BSFloat): TDateTime;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsDateTime.MultiplyInt(const Value1: TDateTime;
  const Value2: int32): TDateTime;
begin
  Result := Value1 * Value2;
end;

class function TOperatorsDateTime.Subtract(const Value1,
  Value2: TDateTime): TDateTime;
begin
  Result := Value1 - Value2;
end;

class function TOperatorsDateTime.ToStringInt(const Value: TDateTime): string;
begin
  Result := DateTimeToStr(Value);
end;

{ TVec2d }

class operator TVec2d.Add(const v1, v2: TVec2d): TVec2d;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
end;

class operator TVec2d.Implicit(const v: TVec2f): TVec2d;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec2d.Equal(const v1, v2: TVec2d): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y);
end;

class operator TVec2d.Implicit(const v: TVec2d): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec2d.Multiply(const v: TVec2d; k: double): TVec2d;
begin
  Result.x := v.x * k;
  Result.y := v.y * k;
end;

class operator TVec2d.Subtract(const v1, v2: TVec2d): TVec2d;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
end;

{ TVec2i64 }

class operator TVec2i64.Implicit(const v: TVec2i64): TVec2d;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec2i64.Implicit(const v: TVec2i64): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

class operator TVec2i64.Implicit (const v: TVec2f): TVec2i64;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
end;

class operator TVec2i64.Implicit (const v: TVec2d): TVec2i64;
begin
  Result.x := round(v.x);
  Result.y := round(v.y);
end;

{ TRectBSd }

class operator TRectBSd.Implicit(const A: TRectBSd): TRectBSf;
begin
  Result.X := A.X;
  Result.Y := A.Y;
  Result.Width := A.Width;
  Result.Height := A.Height;
end;

class operator TRectBSd.Implicit(const A: TRectBSf): TRectBSd;
begin
  Result.X := A.X;
  Result.Y := A.Y;
  Result.Width := A.Width;
  Result.Height := A.Height;
end;

{ TBox3d }

class operator TBox3d.Explicit(const B: TBox3d): TBox3f;
begin
  Result.Min := TVec3f(B.Min);
  Result.Max := TVec3f(B.Max);
  Result.Mid := TVec3f(B.Mid);
  Result.IsPoint := B.IsPoint;
end;

{ TColor4f }

class operator TColor4f.Explicit(const AValue: int32): TColor4f;
begin
  Result := ColorByteToFloat(AValue, true);
end;

class operator TColor4f.Explicit(const AValue: uint32): TColor4f;
begin
  Result := ColorByteToFloat(AValue, true);
end;

class operator TColor4f.Explicit(const AValue: TColor4f): uint32;
begin
  Result := ColorFloatToByte(AValue).value;
end;

class operator TColor4f.Implicit(const AValue: TColor4f): TVec4f;
begin
  Result.x := AValue.r;
  Result.y := AValue.g;
  Result.z := AValue.b;
  Result.w := AValue.a;
end;

class operator TColor4f.Multiply(const v: TColor4f; const k: BSFloat): TColor4f;
begin
  Result.r := v.r * k;
  Result.g := v.g * k;
  Result.b := v.b * k;
  Result.w := v.w * k;
end;

class operator TColor4f.Implicit(const AValue: TVec4f): TColor4f;
begin
  Result.r := AValue.x;
  Result.g := AValue.y;
  Result.b := AValue.z;
  Result.a := AValue.w;
end;

class operator TColor4f.Add(const AValue: TColor4f; const k: BSFloat): TColor4f;
begin
  Result.r := AValue.r + k;
  Result.g := AValue.g + k;
  Result.b := AValue.b + k;
  Result.w := AValue.w + k;
end;

class operator TColor4f.Equal(const v1, v2: TColor4f): boolean;
begin
  Result := (v1.x = v2.x) and (v1.y = v2.y) and (v1.z = v2.z) and (v1.w = v2.w);
end;

class operator TColor4f.Explicit(const AValue: TVec3f): TColor4f;
begin
  Result.r := AValue.x;
  Result.g := AValue.y;
  Result.b := AValue.z;
  Result.a := 1.0;
end;

class operator TColor4f.Explicit(const AValue: TColor4f): TVec3f;
begin
  Result.x := AValue.r;
  Result.y := AValue.g;
  Result.z := AValue.b;
end;

{ TVec2ui }

class operator TVec2ui.Explicit(const v: TVec2ui): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;

end.

