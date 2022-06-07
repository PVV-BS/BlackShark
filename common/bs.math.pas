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


unit bs.math;

interface

type
  // if you want to improve the accuracy then change type single to double
  fmath = single;

function Deg2Rad(Deg: fmath): fmath; inline;
function Rad2Deg(Rad: fmath): fmath; inline;
procedure BS_SinCos(Angle: fmath; out Sin, Cos: fmath);  overload; inline;
procedure BS_SinCos(Angle: Integer; out Sin, Cos: fmath);  overload; inline;
function BS_Cos(Angle: Integer): fmath; inline; overload;
function BS_Sin(Angle: Integer): fmath; inline; overload;
function BS_Cos(Angle: fmath): fmath; inline;  overload;
function BS_Sin(Angle: fmath): fmath; inline;  overload;

function Clamp(max, min, value: single): single; overload; inline;
function Clamp(max, min, value: double): double; overload; inline;
function Clamp(max, min, value: int32): int32; overload; inline;
function Clamp(max, min, value: int64): int64; overload; inline;

function Max(const Value1, Value2: double): double; overload; inline;
function Max(Value1, Value2: single): single; overload; inline;
function Max(Value1, Value2: int32): int32; overload; inline;
function Max(Value1, Value2: int8): int8; overload; inline;
function Max(Value1, Value2: uint8): uint8; overload; inline;

function Min(Value1, Value2: double): double; overload; inline;
function Min(Value1, Value2: single): single; overload; inline;
function Min(Value1, Value2: int32): int32; overload; inline;
function Min(Value1, Value2: int8): int8; overload; inline;
function Min(Value1, Value2: uint8): uint8; overload; inline;

function CompareLimit(a, b, limit: fmath): int8; inline;

function Remainder(Integral: fmath; Frac: fmath): fmath; inline;

// https://en.wikipedia.org/wiki/Sinc_function
function sinc(x: fmath): fmath; inline;

function clean(t: fmath): fmath; inline;

// https://en.wikipedia.org/wiki/Lanczos_resampling
function Lanczos3Interpolation(t: fmath): fmath; inline;
// cubic spline Interpolation
function CubicInterpolation(t: fmath): fmath;

type
  Aligns = class
  public
    class function Align(Value: fmath; Step: fmath): fmath; static;
  end;

const
  BS_RAD2DEG: fmath  = 57.29578049;
  BS_GRAD2DEG: fmath = 63.661978277;   // 90 Deg = 100 Grad; Deg = Rad * BS_GRAD2DEG;
  BS_DEG2RAD: fmath  = 0.017453292;
  BS_PI: fmath       = 3.141592654;
  BS_PI_HALF: fmath  = 1.570796327;
  // precision calculate trigonometric functions
  PRECISION_GRAD = 60; // before one minute
  BS_COUNT_SIN_COS_VALUES = 360 * PRECISION_GRAD;
  EPSILON = 0.0000001;
  PI_DIVIDED_180 = 0.01745329251994329576923690768489;

var
  g_SinTable: array[0..BS_COUNT_SIN_COS_VALUES] of fmath;
  g_CosTable: array[0..BS_COUNT_SIN_COS_VALUES] of fmath;

implementation

function Remainder(Integral: fmath; Frac: fmath): fmath;
begin
  Result := Integral - trunc(Integral / Frac) * Frac;
end;

function CompareLimit(a, b, limit: fmath): int8;
begin
  if a < b then
  begin
    if a + limit >= b then
      Result := 0
    else
      Result := -1;
  end else
  if a > b then
  begin
    if a - limit <= b then
      Result := 0
    else
      Result := 1;
  end else
    Result := 0;
end;

function clean(t: fmath): fmath;
begin
  if (abs(t) < EPSILON) then
    Result := 0.0
  else
    Result := t;
end;

function lanczos3Interpolation(t: fmath): fmath;
begin
  if abs(t) < EPSILON then
    Result := 1
  else
  if t < 3.0 then
  begin
    Result := BS_PI * t;
    Result := 3.0 * sin(Result) * sin(Result * 0.33333333) / (Result * Result);
  end else
    Result := 0;
end;

function CubicInterpolation(t: fmath): fmath;
var
  abt: fmath;
  tt: fmath;
const
  a: fmath = 0.5;
begin
  abt := abs(t);
  if abt > 1.0 then
  begin
    if abt > 2.0 then
      exit(0.0);
    tt := t*t;
    Result := a * (tt * abt - 5 * tt + 8 * abt - 4);
  end else
  begin
    tt := t*t;
    Result := (a + 2) * tt * abt - (a + 3)*tt + 1;
  end;
end;

function sinc(x: fmath): fmath;
begin
  {x := (x * BS_PI);

  if ((x < 0.01) and (x > -0.01)) then
    exit(1.0 + x*x*(-1.0/6.0 + x*x*1.0/120.0));  }

  if abs(x) > 0.0 then
    Result := sin(x) / x
  else
    Result := 1.0;
end;

procedure GenerateSinCos;
var
  i: int32;
  a, step: fmath;
begin
  step := 1 / PRECISION_GRAD;
  for i := 0 to BS_COUNT_SIN_COS_VALUES do
  begin
    a := step * i * BS_DEG2RAD;
    g_SinTable[i] := sin(a);
    g_CosTable[i] := cos(a);
  end;
end;

function Deg2Rad(Deg: fmath): fmath;
begin
  Result := Deg * BS_DEG2RAD;
end;

function Rad2Deg(Rad: fmath): fmath;
begin
  Result := Rad * BS_RAD2DEG;
end;

procedure BS_SinCos(Angle: fmath; out Sin, Cos: fmath);
var
  ai: int32;
begin
  //sincos(Angle*BS_DEG2RAD, Sin, Cos);
  //exit;

  ai := Round(Angle * PRECISION_GRAD);
  if ai < 0 then
    ai := BS_COUNT_SIN_COS_VALUES - abs(ai) mod BS_COUNT_SIN_COS_VALUES;

  if ai > BS_COUNT_SIN_COS_VALUES then
    ai := ai mod BS_COUNT_SIN_COS_VALUES;

  Cos := g_CosTable[ai];
  Sin := g_SinTable[ai];
end;

procedure BS_SinCos(Angle: Integer; out Sin, Cos: fmath);
begin
  if Angle < 0 Then
    Angle := abs(Angle);

  if Angle > 360 then
    Angle := Angle mod 360;

  Angle := Angle * PRECISION_GRAD;

  Cos := g_CosTable[Angle];
  Sin := g_SinTable[Angle];
end;

function BS_Cos(Angle: Integer): fmath;
begin
  if Angle < 0 Then
    Angle := abs(Angle);

  if Angle > 360 then
    Angle := Angle mod 360;

  Angle := Angle * PRECISION_GRAD;

  Result := g_CosTable[Angle];
end;

function BS_Sin(Angle: Integer): fmath;
begin
  if Angle < 0 Then
    Angle := abs(Angle);

  if Angle > 360 then
    Angle := Angle mod 360;

  Angle := Angle * PRECISION_GRAD;

  Result := g_SinTable[Angle];
end;

function BS_Cos(Angle: fmath): fmath;
var
  ai: int32;
begin
  ai := Round(Angle * PRECISION_GRAD);
  if ai < 0 then
    ai := BS_COUNT_SIN_COS_VALUES - abs(ai) mod BS_COUNT_SIN_COS_VALUES;

  if ai > BS_COUNT_SIN_COS_VALUES then
    ai := ai mod BS_COUNT_SIN_COS_VALUES;
  Result := g_CosTable[ai];
end;

function BS_Sin(Angle: fmath): fmath;
var
  ai: int32;
begin
  ai := Round(Angle * PRECISION_GRAD);
  if ai < 0 then
    ai := BS_COUNT_SIN_COS_VALUES - abs(ai) mod BS_COUNT_SIN_COS_VALUES;

  if ai > BS_COUNT_SIN_COS_VALUES then
    ai := ai mod BS_COUNT_SIN_COS_VALUES;
  Result := g_SinTable[ai];
end;

function Clamp(max, min, value: int32): int32;
begin
  if (value < min) then
    Result := min
  else
  if (value > max) then
    Result := max
  else
    Result := value;
end;

function Clamp(max, min, value: int64): int64;
begin
  if (value < min) then
    Result := min
  else
  if (value > max) then
    Result := max
  else
    Result := value;
end;

function Clamp(max, min, value: single): single;
begin
  if (value < min) then
    Result := min
  else
  if (value > max) then
    Result := max
  else
    Result := value;
end;

function Clamp(max, min, value: double): double;
begin
  if (value < min) then
    Result := min
  else
  if (value > max) then
    Result := max
  else
    Result := value;
end;

function Max(const Value1, Value2: double): double;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Max(Value1, Value2: single): single;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Max(Value1, Value2: int32): int32;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Max(Value1, Value2: int8): int8; overload; inline;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Max(Value1, Value2: uint8): uint8; overload; inline;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: double): double; inline;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: single): single; inline;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: int32): int32; inline;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: int8): int8; overload; inline;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: uint8): uint8; overload; inline;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

{ Aligns }

class function Aligns.Align(Value, Step: fmath): fmath;
begin
  Result := round(Value) + round(Value - (round(Value)) / Step)*Step;
end;

initialization
  GenerateSinCos;

end.

