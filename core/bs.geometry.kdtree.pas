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
  , bs.collections
  , bs.math
  ;

type

  int = int32;

  { TIntervalsTree }

  TIntervalsTree = class
  protected
    type
      PInterval = ^TInterval;
      TInterval = record
        Selected: int8;
        MinIndex: int;
        MaxIndex: int;
        Value: Pointer;
      end;

      PTreeLeaf = ^TTreeLeaf;
      TTreeLeaf = record
        Index: int;
        LeafValue: double;
        { -1..1 - a balance of the vertex }
        Balance: int8;
        { it are balanced left and right branches }
        Left: int;
        Right: int;
        { references to FCacheSnipets }
        Intervals: array of int;
      end;

  private
    FCacheSize: int;
    FRoot: int;
    FValueComparator: TValueComparator<Pointer>;
    FCacheLeafs: TListVec<TTreeLeaf>;
    FCacheLeafsPtr: PTreeLeaf;
    FFreeLeafs: TListVec<int>;
    FCacheIntervals: TListVec<TInterval>;
    FFreeIntervals: TListVec<int>;
    FCacheIntervalsPtr: PTreeLeaf;
    FStack: TListVec<int>;
    FStackLeafsPtr: TListVec<PTreeLeaf>;
    procedure GrowCacheLeafs(GrowSize: int);
    procedure GrowCacheIntervals(GrowSize: int);
    procedure BalanceLeft(var LeafInt: int; var NotBalanced: boolean);
    procedure BalanceRight(var LeafInt: int; var NotBalanced: boolean);
    function InsertValue(LeafValue: double; var Leaf: int; var Added, NotBalanced: boolean; var Interval: int): int;
    function CreateLeaf(LeafValue: double; var Interval: int): PTreeLeaf;
    function CreateInterval: int;
    function LeafPtr(Leaf: int): PTreeLeaf; inline;
    function IntervalPtr(Interval: int): PInterval; inline;
    procedure CheckCache; inline;
  public
    constructor Create(CacheSize: int = 100000);
    destructor Destroy; override;
    function Add(Min, Max: double; Data: Pointer): int;
    procedure Select(Min, Max: double; ListResult: TListVec<Pointer>);
  end;

implementation

uses
    math
  ;

{ TIntervalsTree }

constructor TIntervalsTree.Create(CacheSize: int);
begin
  FRoot := -1;
  FCacheSize := Max(CacheSize, 4096);
  FValueComparator := PtrCmpBool;
  FCacheLeafs := TListVec<TTreeLeaf>.Create;
  FCacheIntervals := TListVec<TInterval>.Create;
  FFreeLeafs := TListVec<int>.Create;
  FFreeIntervals := TListVec<int>.Create;
  FStack := TListVec<int>.Create;
  FStackLeafsPtr := TListVec<PTreeLeaf>.Create;
  GrowCacheLeafs(FCacheSize);
  GrowCacheIntervals(FCacheSize);
end;

procedure TIntervalsTree.BalanceLeft(var LeafInt: int; var NotBalanced: boolean);
var
	l1: PTreeLeaf;
  l2: PTreeLeaf;
  leaf: PTreeLeaf;
begin
  leaf := LeafPtr(LeafInt);
  case leaf.Balance of
    1:begin
      leaf.Balance := 0;
      NotBalanced := false;
    end;
    0:begin
      leaf.Balance:= -1;
    end else
    begin   // new balancing
      l1 := LeafPtr(leaf.left);
      if (l1.Balance = -1) then
      begin   // single ll rotation
        leaf.left := l1.right;
        l1.right := leaf.Index;
        leaf.Balance := 0;
        leaf := l1;
      end else
      begin //double lr rotation
        l2 := LeafPtr(l1.right);
        l1.Right := l2.Left;
        l2.Left := l1.Index;
        leaf.Left := l2^.Right;
        l2.right := leaf.Index;

        if l2.Balance < 0 then
          leaf.Balance := +1
        else
          leaf.Balance := 0;

        if l2^.Balance > 0 then
          l1^.Balance := -1
        else
          l1^.Balance := 0;

        leaf := l2;
      end;
      leaf.Balance := 0;
      LeafInt := leaf.Index;
      NotBalanced := false;
    end; { -1 }
  end; { case }
end;

procedure TIntervalsTree.BalanceRight(var LeafInt: int; var NotBalanced: boolean);
var
	l1: PTreeLeaf;
  l2: PTreeLeaf;
  leaf: PTreeLeaf;
begin
  leaf := LeafPtr(LeafInt);
  case leaf.Balance of
    -1: begin
       leaf.Balance := 0;
       NotBalanced := false;
    end;
    0: begin
       leaf.Balance := +1;
    end else
    begin    // new balancing
      l1 := LeafPtr(leaf.right);
      if (l1.Balance = 1) then
      begin  // single rr rotation
        leaf.right := l1^.left;
        l1.left := leaf.Index;
        leaf.Balance := 0;
        leaf := l1;
      end else
      begin  // double rl rotation
        l2 := LeafPtr(l1.left);
        l1.left := l2.right;
        l2.right := l1.Index;
        leaf.right := l2.left;
        l2.left := leaf.Index;

        if l2.Balance > 0 then
          leaf.Balance := -1
        else
          leaf.Balance := 0;

        if l2.Balance < 0 then
          l1.Balance := +1
        else
          l1.Balance := 0;

        leaf := l2;
      end;
      leaf.Balance := 0;
      LeafInt := leaf.Index;
      NotBalanced := false;
    end; {+1: begin}
 	end;
end;

procedure TIntervalsTree.GrowCacheLeafs(GrowSize: int);
var
  i: int;
  leaf: TTreeLeaf;
begin
  i := FCacheLeafs.Count;
  FCacheLeafs.Capacity := FCacheLeafs.Capacity + GrowSize;
  FFreeLeafs.Capacity := FFreeLeafs.Capacity + GrowSize;
  FillChar(leaf{%H-}, sizeof(leaf), 0);
  leaf.Left := -1;
  leaf.Right := -1;
  for i := i to GrowSize - 1 do begin
    leaf.Index := i;
    FCacheLeafs.Add(leaf);
    FFreeLeafs.Add(i);
  end;
  FCacheLeafsPtr := FCacheLeafs.ShiftData[0];
end;

procedure TIntervalsTree.GrowCacheIntervals(GrowSize: int);
var
  i: int;
begin
  i := FCacheIntervals.Count;
  FFreeIntervals.Capacity := FFreeIntervals.Capacity + GrowSize;
  FCacheIntervals.Count := FCacheIntervals.Count + GrowSize;
  for i := i to FCacheIntervals.Count - 1 do begin
    FFreeIntervals.Add(i);
  end;
  FCacheIntervalsPtr := FCacheIntervals.ShiftData[0];
end;

destructor TIntervalsTree.Destroy;
begin
  FCacheIntervals.Free;
  FCacheLeafs.Free;
  FFreeLeafs.Free;
  FFreeIntervals.Free;
  FStack.Free;
  FStackLeafsPtr.Free;
  inherited Destroy;
end;

function TIntervalsTree.InsertValue(LeafValue: double; var Leaf: int; var Added, NotBalanced: boolean; var Interval: int): int;
var
  l: PTreeLeaf;
begin
  if Leaf < 0 then
  begin        // the value do not contained in tree, insert it
   	Leaf := CreateLeaf(LeafValue, Interval).Index;
   	Added := true;
    NotBalanced := true;
    exit(Leaf);
  end;

  l := LeafPtr(Leaf);
  if (LeafValue > l.LeafValue) then
  begin
    Result := InsertValue(LeafValue, l.left, Added, NotBalanced, Interval);
   	if Added and NotBalanced then
        BalanceLeft(Leaf, NotBalanced);
  end else
  if (LeafValue < l.LeafValue) then
  begin
    Result := InsertValue(LeafValue, l.Right, Added, NotBalanced, Interval);
   	if Added and NotBalanced then
      BalanceRight(Leaf, NotBalanced);
  end else
  begin
    Added := false;
    Result := Leaf;
  end;
end;

//function TIntervalsTree.InsertValue(LeafValue: double; var LeafRoot, Interval: int): int;
//var
//  l: PTreeLeaf;
//  leaf: int;
//  notBalanced: boolean;
//begin
//  if FRoot < 0 then
//  begin
//    FRoot := CreateLeaf(LeafValue, Interval).Index;
//    exit(FRoot);
//  end;
//
//  FStackLeafsPtr.Count := 0;
//  //FStack.Add(FRoot);
//  Result := FRoot;
//  notBalanced := false;
//  while true do
//  begin
//    l := LeafPtr(Result);
//    if (LeafValue > l.LeafValue) then
//    begin
//      if l.Left < 0 then
//      begin
//        l.Left := CreateLeaf(LeafValue, Interval).Index;
//        //leaf := Result;
//        Result := l.Left;
//        notBalanced := true;
//        //BalanceLeft(l.Left, notBalanced);
//        break;
//      end else
//      begin
//        Result := l.Left;
//        FStackLeafsPtr.Add(l);
//      end;
//    end else
//    if (LeafValue < l.LeafValue) then
//    begin
//      if l.Right < 0 then
//      begin
//        l.Right := CreateLeaf(LeafValue, Interval).Index;
//        //leaf := Result;
//        Result := l.Right;
//        notBalanced := true;
//        //BalanceRight(l.Right, notBalanced);
//        break;
//      end else
//      begin
//        Result := l.Right;
//        FStackLeafsPtr.Add(l);
//      end;
//    end else
//      break;
//  end;
//
//  while notBalanced and (FStackLeafsPtr.Count > 2) do begin
//    l := FStackLeafsPtr.Pop;
//    //leaf := l.Index;
//    if LeafValue < l.LeafValue then
//      BalanceRight(l.Right, notBalanced)
//    else
//      BalanceLeft(l.Left, notBalanced);
//  end;
//end;

function TIntervalsTree.CreateLeaf(LeafValue: double; var Interval: int): PTreeLeaf;
var
  leaf: int;
begin
  leaf := FFreeLeafs.Pop;
  Result := LeafPtr(leaf);
  if Interval < 0 then
    Interval := CreateInterval;
  Result.LeafValue := LeafValue;
  SetLength(Result.Intervals, length(Result.Intervals) + 1);
  Result.Intervals[length(Result.Intervals) - 1] := Interval;
  Result.Left := -1;
  Result.Right := -1;
  Result.Balance := 0;
end;

function TIntervalsTree.CreateInterval: int;
begin
  if FFreeIntervals.Count = 0 then
    GrowCacheIntervals(FCacheIntervals.Count div 4);
  Result := FFreeIntervals.Pop;
end;

function TIntervalsTree.LeafPtr(Leaf: int): PTreeLeaf;
begin
  Result := PTreeLeaf(PByte(FCacheLeafsPtr) + Leaf * SizeOf(TTreeLeaf));
end;

function TIntervalsTree.IntervalPtr(Interval: int): PInterval;
begin
  Result := PInterval(PByte(FCacheIntervalsPtr) + Interval * SizeOf(TInterval));
end;

procedure TIntervalsTree.CheckCache;
begin
  if FFreeLeafs.Count = 0 then
  begin
    if FCacheLeafs.Count > 1024 then
      GrowCacheLeafs(FCacheLeafs.Count div 4)
    else
      GrowCacheLeafs(1024);
  end;
end;

function TIntervalsTree.Add(Min, Max: double; Data: Pointer): int;
var
  i: int;
  left, right: int;
  leafP: PTreeLeaf;
  interval: PInterval;
  added, notBalanced: boolean;
begin
  // In order to be sure that the memory block will not be changed if a new leaf appears
  CheckCache;
  Result := -1;
  added := false;
  notBalanced := false;
  left := InsertValue(Min, FRoot, added, notBalanced, Result);
  added := false;
  notBalanced := false;
  right := InsertValue(Max, FRoot, added, notBalanced, Result);
  if (Result < 0) then begin

    leafP := LeafPtr(left);
    for i := 0 to length(leafP.Intervals) - 1 do begin
      interval := IntervalPtr(leafP.Intervals[i]);
      if interval.Value = Data then
        exit(leafP.Intervals[i]);
    end;

    leafP := LeafPtr(right);
    for i := 0 to length(leafP.Intervals) - 1 do begin
      interval := IntervalPtr(leafP.Intervals[i]);
      if interval.Value = Data then
        exit(leafP.Intervals[i]);
    end;

    Result := CreateInterval;
  end;
  interval := IntervalPtr(Result);
  interval.MinIndex := left;
  interval.MaxIndex := right;
  interval.Value := Data;
end;

procedure TIntervalsTree.Select(Min, Max: double; ListResult: TListVec<Pointer>);
var
  i: int;
  leaf: PTreeLeaf;
  interval: PInterval;
begin
  if (FRoot < 0) then
    exit;
  FStack.Add(FRoot);
  while (FStack.Count > 0) do
  begin
    leaf := LeafPtr(FStack.Pop);
    if (Max < leaf.LeafValue) then
    begin  // right
      if leaf.Right >= 0 then
        FStack.Add(leaf.Right);
    end else
    if (Min > leaf.LeafValue) then
    begin  // left
      if leaf.Left >= 0 then
        FStack.Add(leaf.Left);
    end else
    begin  // hit
      if leaf.Left >= 0 then
        FStack.Add(leaf.Left);
      if leaf.Right >= 0 then
        FStack.Add(leaf.Right);
      for i := 0 to length(leaf.Intervals) - 1 do
        ListResult.Add(IntervalPtr(leaf.Intervals[i]).Value);
    end;
  end;
end;

end.

