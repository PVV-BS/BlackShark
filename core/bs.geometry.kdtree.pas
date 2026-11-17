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

unit bs.geometry.kdtree;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , Classes
  , bs.basetypes
  , bs.collections
  , bs.math
  ;

type

  {.$define RECURSION_INSERT}
  {$define testTree}

  { TKDTree<T> }

  TKDTree<T> = class
  private
    type
      PCounters = ^TCounters;
      TCounters = record
        SelectIteration: int32;
        DimHits: uint8;
        Dimensions: uint8;
        MaskStoredDim: uint8;
        Opposite: PCounters;
      end;

      TValueHolder = record
        Value: T;
        Counters: PCounters;
        constructor ValueHolder(const AValue: T; Dimensions: int8);
        class operator Equal(const v1, v2: TValueHolder): boolean; inline;
      end;
      TAvlMultiTreeDouble = TAvlMultiTree<double, TValueHolder>;

  private
    FDimensions: uint8;
    FMaskDimensions: uint8;
    FListSelection: TListVec<T>;
    FSelectionConsumer: TValueConsumer<TValueHolder>;
    FFreeSelectors: TListVec<PInteger>;
    FOnDeleteValue: TOnDeleteValue<T>;
    FCustomValueConsumer: TValueConsumer<T>;
    FUpdating: boolean;
    FCurrentSelectedDim: uint8;
  private
    class function KeyCmp(const Key1, Key2: double): int8; static;
    class function ValueCmp(const Value1, Value2: TValueHolder): boolean; static;
  private
    {$ifdef debug}
    function GetSelectIteration: int32;
    {$endif}

    function GetCount: int32;
    procedure SelectionConsumer(const Value: TValueHolder);
    procedure DoSelect(AViewport: PKDMinMax); inline;
    procedure OnValueDelete(const Value: TValueHolder);
  protected
    FAvlTree: array of TAvlMultiTreeDouble;
    FSelectIteration: int32;
    FCount: int32;
  public
    constructor Create(Dimensions: uint8);
    destructor Destroy; override;
    procedure Add(const AData: T; AVectorMinMax: PKDMinMax); overload;
    procedure Update(const AData: T; AOldMinMax, ANewMinMax: PKDMinMax); overload;
    procedure Delete(const AData: T; AVectorMinMax: PKDMinMax); overload;
    function Select(AViewport: PKDMinMax): TListVec<T>; overload;
    procedure Select(AViewport: PKDMinMax; AConsumer: TValueConsumer<T>); overload;
    procedure Clear; virtual;
    property Count: int32 read GetCount;
    property OnDeleteValue: TOnDeleteValue<T> read FOnDeleteValue write FOnDeleteValue;
    {$ifdef debug}
    property SelectIteration: int32 read GetSelectIteration;
    {$endif}
  end;

  T1DTree<T> = class (TKDTree<T>)
  public
    constructor Create;
    procedure Add(const AData: T; APoint: Double); overload;
    function Select(AViewportMin, AViewportMax: double): TListVec<T>; overload;
  end;

  T2DTree<T> = class (TKDTree<T>)
  public
    constructor Create;
    procedure Add(const AData: T; APoint: TVec2f); overload;
    procedure Add(const AData: T; const ABox: TBox2d); overload;
    procedure Delete(const AData: T; const ABox: TBox2d); overload;
    function Select(const AViewport: TBox2d): TListVec<T>; overload;
  end;

  T3DTree<T> = class (TKDTree<T>)
  public
    constructor Create;
    procedure Add(const AData: T; const APoint: TVec3f); overload;
    procedure Add(const AData: T; const ABox: TBox3d); overload;
    procedure Add(const AData: T; const ABox: TBox3f); overload;
    procedure Update(const AData: T; const AOldBox, ANewBox: TBox3d); overload;
    procedure Delete(const AData: T; const ABox: TBox3f); overload;
    procedure Delete(const AData: T; const ABox: TBox3d); overload;
    function Select(const AViewport: TBox3d): TListVec<T>; overload;
    procedure Select(const AViewport: TBox3d; AConsumer: TValueConsumer<T>); overload;
  end;

const
  DIMENSIONS_FLAGS: array[0..7] of uint8 = (1, 2, 4, 8, 16, 32, 64, 128);

implementation

uses
    math
  , bs.exceptions
  ;

{ TKDTree<T> }

class function TKDTree<T>.KeyCmp(const Key1, Key2: double): int8;
begin
  if Key1 < Key2 then
    exit(1)
  else
  if Key1 > Key2 then
    exit(-1);
  Result := 0;
end;

procedure TKDTree<T>.OnValueDelete(const Value: TValueHolder);
var
  lastCounter: boolean;
begin
  dec(Value.Counters^.Dimensions);
   if Value.Counters^.Dimensions = 0 then
  begin
    if Assigned(Value.Counters.Opposite) then
    begin
      Value.Counters.Opposite.Opposite := nil;
      lastCounter := false;
    end else
      lastCounter := true;
    dispose(Value.Counters);
    if lastCounter then
    begin
      dec(FCount);
      if not FUpdating and Assigned(OnDeleteValue) then
        OnDeleteValue(Value.Value);
    end;
  end;
end;

constructor TKDTree<T>.Create(Dimensions: uint8);
var
  i: Integer;
begin
  assert(Dimensions > 0);
  FDimensions := Dimensions;
  FMaskDimensions := trunc(Power(2, FDimensions)) - 1;
  SetLength(FAvlTree, FDimensions);
  for i := 0 to FDimensions - 1 do
  begin
    FAvlTree[i] := TAvlMultiTreeDouble.Create(KeyCmp, @ValueCmp);
    FAvlTree[i].OnDeleteValue := OnValueDelete;
  end;
  FListSelection := TListVec<T>.Create;
  FSelectionConsumer := SelectionConsumer;
  FFreeSelectors := TListVec<PInteger>.Create;
end;

function TKDTree<T>.GetCount: int32;
begin
  Result := FCount;
end;

{$ifdef debug}
function TKDTree<T>.GetSelectIteration: int32;
begin
  Result := FAvlTree[0].SelectIteration;
end;
{$endif}

procedure TKDTree<T>.Delete(const AData: T; AVectorMinMax: PKDMinMax);
var
  i: int8;
  holder: TValueHolder;
begin
  holder.Value := AData;
  for i := 0 to FDimensions - 1 do
  begin
    FAvlTree[i].Delete(AVectorMinMax[i], holder);
    if AVectorMinMax[i] <> AVectorMinMax[FDimensions+i] then
      FAvlTree[i].Delete(AVectorMinMax[FDimensions+i], holder);
  end;
end;

destructor TKDTree<T>.Destroy;
var
  i: int8;
begin
  Clear;
  for i := 0 to FDimensions - 1 do
  begin
    FAvlTree[i].Free;
  end;
  FListSelection.Free;
  FFreeSelectors.Free;
  inherited Destroy;
end;

procedure TKDTree<T>.DoSelect(AViewport: PKDMinMax);
var
  i: int16;
begin
  FCurrentSelectedDim := 0;;
  for i := 0 to FDimensions - 1 do
  begin
    FAvlTree[i].Select(AViewport[i], AViewport[FDimensions + i], FSelectionConsumer);
    inc(FCurrentSelectedDim);
  end;
  inc(FSelectIteration);
end;

function TKDTree<T>.Select(AViewport: PKDMinMax): TListVec<T>;
begin
  FListSelection.Count := 0;
  DoSelect(AViewport);
  Result := FListSelection;
end;

procedure TKDTree<T>.Select(AViewport: PKDMinMax; AConsumer: TValueConsumer<T>);
begin
  FCustomValueConsumer := AConsumer;
  try
    DoSelect(AViewport);
  finally
    FCustomValueConsumer := nil;
  end;
end;

procedure TKDTree<T>.SelectionConsumer(const Value: TValueHolder);
const
  SELECTED = 255;
var
  hit: boolean;
  notMask: uint8;
begin
  if Value.Counters^.SelectIteration <> FSelectIteration then
  begin
    Value.Counters^.SelectIteration := FSelectIteration;
    Value.Counters^.DimHits := 0;
  end;
  Value.Counters^.DimHits := Value.Counters^.DimHits or DIMENSIONS_FLAGS[FCurrentSelectedDim];
  if (Value.Counters^.DimHits = Value.Counters^.MaskStoredDim) then
  begin
    // when some dimensions Min = Max, for example plane in 3d, then for Max Value.Counters^.Dimensions <> FDimensions
    hit := Value.Counters^.Dimensions = FDimensions;
    if not hit then  // if hit = false then next case is always true -> and Assigned(Value.Counters.Opposite)
    begin
      if (Value.Counters.Opposite.SelectIteration = FSelectIteration) and (Value.Counters.Opposite.DimHits <> SELECTED) then
      begin
        notMask := (not Value.Counters^.MaskStoredDim) and FMaskDimensions;
        hit := (Value.Counters^.Opposite.DimHits and notMask = notMask);
      end;
    end
    else
    // check that the opposite side has not reported a hit
    if Assigned(Value.Counters.Opposite) and (Value.Counters.Opposite.SelectIteration = FSelectIteration) then
      hit := (Value.Counters.Opposite.DimHits <> SELECTED);

    if hit then
      begin
        Value.Counters^.DimHits := SELECTED;
        if Assigned(FCustomValueConsumer) then
          FCustomValueConsumer(Value.Value)
        else
          FListSelection.Add(Value.Value);
      end;
  end;
end;

procedure TKDTree<T>.Update(const AData: T; AOldMinMax, ANewMinMax: PKDMinMax);
begin
  FUpdating := true;
  try
    Delete(AData, AOldMinMax);
    Add(AData, ANewMinMax);
  finally
    FUpdating := false;
  end;
end;

class function TKDTree<T>.ValueCmp(const Value1, Value2: TValueHolder): boolean;
begin
  Result := (Value1.Value = Value2.Value);
end;

procedure TKDTree<T>.Add(const AData: T; AVectorMinMax: PKDMinMax);
var
  i: int8;
  holderMin: TValueHolder;
  holderMax: TValueHolder;
begin
  inc(FCount);
  holderMin := TValueHolder.ValueHolder(AData, FDimensions);
  holderMin.Counters^.SelectIteration := FSelectIteration-1;
  holderMin.Counters.MaskStoredDim := FMaskDimensions;
  holderMax := TValueHolder.ValueHolder(AData, FDimensions);
  holderMax.Counters^.SelectIteration := FSelectIteration-1;

  holderMin.Counters.Opposite := holderMax.Counters;
  holderMax.Counters.Opposite := holderMin.Counters;

  for i := 0 to FDimensions - 1 do
  begin
    FAvlTree[i].Add(AVectorMinMax[i], holderMin);
    if AVectorMinMax[i] <> AVectorMinMax[FDimensions + i] then
    begin
      holderMax.Counters.MaskStoredDim := holderMax.Counters.MaskStoredDim or DIMENSIONS_FLAGS[i];
      FAvlTree[i].Add(AVectorMinMax[FDimensions + i], holderMax);
    end else
    begin
      dec(holderMax.Counters.Dimensions);
    end;
  end;

  if holderMax.Counters.Dimensions = 0 then
  begin
     dispose(holderMax.Counters);
     holderMin.Counters.Opposite := nil;
  end;
end;

procedure TKDTree<T>.Clear;
var
  i: int8;
begin
  for i := 0 to FDimensions - 1 do
    FAvlTree[i].Clear;
end;

{ T1DTree<T> }

procedure T1DTree<T>.Add(const AData: T; APoint: Double);
var
  holder: TValueHolder;
begin
  inc(FCount);
  holder := TValueHolder.ValueHolder(AData, FDimensions);
  holder.Counters^.SelectIteration := FSelectIteration-1;
  FAvlTree[0].Add(APoint, holder);
end;

constructor T1DTree<T>.Create;
begin
  inherited Create(1);
end;

function T1DTree<T>.Select(AViewportMin, AViewportMax: double): TListVec<T>;
var
  vp: TVec2d;
begin
  vp := vec2d(AViewportMin, AViewportMax);
  Result := Select(@vp);
end;

{ T2DTree<T> }

procedure T2DTree<T>.Add(const AData: T; APoint: TVec2f);
var
  holder: TValueHolder;
begin
  inc(FCount);
  holder := TValueHolder.ValueHolder(AData, FDimensions);
  holder.Counters^.SelectIteration := FSelectIteration-1;
  FAvlTree[0].Add(APoint.x, holder);
  FAvlTree[1].Add(APoint.y, holder);
end;

procedure T2DTree<T>.Add(const AData: T; const ABox: TBox2d);
begin
  Add(AData, @ABox.Min);
end;

constructor T2DTree<T>.Create;
begin
  inherited Create(2);
end;

procedure T2DTree<T>.Delete(const AData: T; const ABox: TBox2d);
begin
  Delete(AData, @ABox.Min);
end;

function T2DTree<T>.Select(const AViewport: TBox2d): TListVec<T>;
begin
  Result := Select(@AViewport);
end;

{ T3DTree<T> }

procedure T3DTree<T>.Add(const AData: T; const APoint: TVec3f);
var
  holder: TValueHolder;
begin
  inc(FCount);
  holder := TValueHolder.ValueHolder(AData, FDimensions);
  holder.Counters^.SelectIteration := FSelectIteration-1;
  FAvlTree[0].Add(APoint.x, holder);
  FAvlTree[1].Add(APoint.y, holder);
  FAvlTree[2].Add(APoint.z, holder);
end;

procedure T3DTree<T>.Add(const AData: T; const ABox: TBox3d);
begin
  Add(AData, @ABox.Min);
end;

procedure T3DTree<T>.Add(const AData: T; const ABox: TBox3f);
var
  box: TBox3d;
begin
  box := ABox;
  Add(AData, @box.Min);
end;

constructor T3DTree<T>.Create;
begin
  inherited Create(3);
end;

procedure T3DTree<T>.Delete(const AData: T; const ABox: TBox3d);
var
  holder: TValueHolder;
begin
  holder.Value := AData;
  FAvlTree[0].Delete(ABox.x_min, holder);
  if ABox.x_min <> ABox.x_max then
    FAvlTree[0].Delete(ABox.x_max, holder);
  FAvlTree[1].Delete(ABox.y_min, holder);
  if ABox.y_min <> ABox.y_max then
    FAvlTree[1].Delete(ABox.y_max, holder);
  FAvlTree[2].Delete(ABox.z_min, holder);
  if ABox.x_min <> ABox.z_max then
    FAvlTree[2].Delete(ABox.z_max, holder);
end;

procedure T3DTree<T>.Delete(const AData: T; const ABox: TBox3f);
var
  holder: TValueHolder;
begin
  holder.Value := AData;
  FAvlTree[0].Delete(ABox.x_min, holder);
  if ABox.x_min <> ABox.x_max then
    FAvlTree[0].Delete(ABox.x_max, holder);
  FAvlTree[1].Delete(ABox.y_min, holder);
  if ABox.y_min <> ABox.y_max then
    FAvlTree[1].Delete(ABox.y_max, holder);
  FAvlTree[2].Delete(ABox.z_min, holder);
  if ABox.x_min <> ABox.z_max then
    FAvlTree[2].Delete(ABox.z_max, holder);
end;

procedure T3DTree<T>.Select(const AViewport: TBox3d; AConsumer: TValueConsumer<T>);
begin
  Select(@AViewport.Min, AConsumer);
end;

function T3DTree<T>.Select(const AViewport: TBox3d): TListVec<T>;
begin
  Result := Select(@AViewport.Min);
end;

procedure T3DTree<T>.Update(const AData: T; const AOldBox, ANewBox: TBox3d);
begin
  Update(AData, @AOldBox.Min, @ANewBox.Min);
end;

{ TKDTree<T>.TValueHolder }

class operator TKDTree<T>.TValueHolder.Equal(const v1, v2: TValueHolder): boolean;
begin
  Result := (v1.Value = v2.Value);
end;

constructor TKDTree<T>.TValueHolder.ValueHolder(const AValue: T; Dimensions: int8);
begin
  Value := AValue;
  new(Counters);
  Counters^.SelectIteration := -1;
  Counters^.Dimensions := Dimensions;
  Counters^.Opposite := nil;
  Counters^.MaskStoredDim := 0;
end;

end.

