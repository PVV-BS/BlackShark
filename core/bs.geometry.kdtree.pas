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

  {.$define RECURSION_INSERT}
  {$define testTree}

  int = int32;
  TIntervals = array of int;

  { TIntervalsTree }

  TIntervalsTree = class
  protected
    type
      TDir = boolean;
    const
      NODE_LEFT: TDir = false;
      NODE_RIGHT: TDir = true;
      DIR_INC: array[TDir] of int8 = (-1, 1);
    type
      PTreeNode = ^TTreeNode;

      PInterval = ^TInterval;
      TInterval = record
        MinIndex: int;
        MaxIndex: int;
        Value: Pointer;
      end;

      { TTreeNode }

      TTreeNode = record
        Index: int;
        NodeValue: double;
        { -1..1 - a balance of the vertex }
        Balance: int8;
        { it is balanced left and right branches }
        Nodes: array[TDir] of int;
        { references to FCacheSnipets }
        Intervals: TIntervals;
        {$ifdef testTree}
        function toString: string;
        {$endif}
      end;

  private
    FCacheSize: int;
    FRoot: int;
    FValueComparator: TValueComparator<Pointer>;
    FCacheNodes: TListVec<TTreeNode>;
    FCacheNodesPtr: PTreeNode;
    FFreeNodes: TListVec<int>;
    FCacheIntervals: TListVec<TInterval>;
    FFreeIntervals: TListVec<int>;
    FCacheIntervalsPtr: PTreeNode;
    FStack: TListVec<int>;
    FStackSearch: TListVec<int>;
    FCount: int;
    {$ifdef testTree}
    FTestFile: TFileStream;
    FTestFileRoots: TFileStream;
    {$endif}
    procedure GrowCacheNodes(GrowSize: int);
    procedure GrowCacheIntervals(GrowSize: int);
    procedure Balance(var NodeInt: int; Dir: TDir; var NotBalanced: boolean; ConditionZeroIsBalanced: boolean);
    function CreateNode(NodeValue: double; var Interval: int): PTreeNode; inline;
    function CreateInterval: int;
    procedure InsertInterval(Interval: int; Node: PTreeNode); overload; inline;
    procedure InsertInterval(Interval: int; Node: int); overload; inline;
    {$ifdef RECURSION_INSERT}
    // insertion with recursion
    function InsertValue(NodeValue: double; var Node: int; var NotBalanced: boolean; var Interval: int): int;
    {$else}
    // insertion without recursion
    function InsertValue(NodeValue: double; var Interval: int): int;
    {$endif}
    function NodePtr(Node: int): PTreeNode; inline;
    function IntervalPtr(Interval: int): PInterval; inline;
    procedure CheckCache; inline;
    function ContainsValue(Node: int; Value: Pointer): int;
    function Exists(Value: double; Data: Pointer; StackSearch: TListVec<int>): int; overload;
    function Delete(DeletingNode: PTreeNode; Stack: TListVec<int>): boolean; overload;
    procedure RemoveInteval(Node: PTreeNode; Position: int); inline;
  public
    constructor Create(CacheSize: int = 100000);
    destructor Destroy; override;
    function Add(Min, Max: double; Data: Pointer): int;
    function Delete(Min, Max: double; Data: Pointer): boolean; overload;
    function Delete(Interval: int): boolean; overload;
    // return position >= 0 (interval index) if exists, otherwise -1
    function Exists(Min, Max: double; Data: Pointer): int; overload;
    // return node index
    function Find(Value: double): int;
    procedure Select(Min, Max: double; ListResult: TListVec<Pointer>); {$ifdef testTree} overload; {$endif}
    procedure Clear;
    property Count: int read FCount;
    property Root: int read FRoot;
    {$ifdef testTree}
    procedure Select(Interval: int; var Min, Max: double; var Data: Pointer); overload;
    procedure Select(Interval: int; var MinIndex, MaxIndex: int; var Data: Pointer); overload;
    procedure Select(Node: int; var Left, Right: int; var NodeValue: double; var Balance: int8; var Intervals: TIntervals); overload;
    procedure WriteTreeState;
    {$endif}
  end;

implementation

uses
    math
  , bs.exceptions
  ;

{ TIntervalsTree }

constructor TIntervalsTree.Create(CacheSize: int);
begin
  FRoot := -1;
  FCacheSize := Max(int64(CacheSize), int64(4096));
  FValueComparator := PtrCmpBool;
  FCacheNodes := TListVec<TTreeNode>.Create;
  FCacheIntervals := TListVec<TInterval>.Create;
  FFreeNodes := TListVec<int>.Create;
  FFreeIntervals := TListVec<int>.Create;
  FStack := TListVec<int>.Create;
  FStackSearch := TListVec<int>.Create;
  GrowCacheNodes(FCacheSize);
  GrowCacheIntervals(FCacheSize);
  {$ifdef testTree}
  FTestFile := TFileStream.Create('testSamples.txt', fmCreate);
  FTestFileRoots := TFileStream.Create('testSampleRoots.txt', fmCreate);
  //FTestData := TListVec<TVec2i>.Create;
  {$endif}
end;

//procedure TIntervalsTree.BalanceLeft(var NodeInt: int; var NotBalanced: boolean);
//var
//  l1: PTreeNode;
//  l2: PTreeNode;
//  node: PTreeNode;
//begin
//  node := NodePtr(NodeInt);
//  case node.Balance of
//    1:begin
//      node.Balance := 0;
//      NotBalanced := false;
//    end;
//    0:begin
//      node.Balance:= -1;
//    end else
//    begin   // new balancing
//      l1 := NodePtr(node.left);
//      if (l1.Balance = -1) then
//      begin   // single ll rotation
//        node.left := l1.right;
//        l1.right := node.Index;
//        node.Balance := 0;
//        node := l1;
//      end else
//      begin //double lr rotation
//        l2 := NodePtr(l1.right);
//        l1.Right := l2.Left;
//        l2.Left := l1.Index;
//        node.Left := l2^.Right;
//        l2.right := node.Index;
//
//        if l2.Balance < 0 then
//          node.Balance := +1
//        else
//          node.Balance := 0;
//
//        if l2^.Balance > 0 then
//          l1^.Balance := -1
//        else
//          l1^.Balance := 0;
//
//        node := l2;
//      end;
//      node.Balance := 0;
//      NodeInt := node.Index;
//      NotBalanced := false;
//    end; { -1 }
//  end; { case }
//end;
//
//procedure TIntervalsTree.BalanceRight(var NodeInt: int; var NotBalanced: boolean);
//var
//	l1: PTreeNode;
//  l2: PTreeNode;
//  node: PTreeNode;
//begin
//  node := NodePtr(NodeInt);
//  case node.Balance of
//    -1: begin
//       node.Balance := 0;
//       NotBalanced := false;
//    end;
//    0: begin
//       node.Balance := +1;
//    end else
//    begin    // new balancing
//      l1 := NodePtr(node.right);
//      if (l1.Balance = 1) then
//      begin  // single rr rotation
//        node.right := l1^.left;
//        l1.left := node.Index;
//        node.Balance := 0;
//        node := l1;
//      end else
//      begin  // double rl rotation
//        l2 := NodePtr(l1.left);
//        l1.left := l2.right;
//        l2.right := l1.Index;
//        node.right := l2.left;
//        l2.left := node.Index;
//
//        if l2.Balance > 0 then
//          node.Balance := -1
//        else
//          node.Balance := 0;
//
//        if l2.Balance < 0 then
//          l1.Balance := +1
//        else
//          l1.Balance := 0;
//
//        node := l2;
//      end;
//      node.Balance := 0;
//      NodeInt := node.Index;
//      NotBalanced := false;
//    end; {+1: begin}
// 	end;
//end;

procedure TIntervalsTree.Balance(var NodeInt: int; Dir: TDir; var NotBalanced: boolean; ConditionZeroIsBalanced: boolean);
var
  l1: PTreeNode;
  l2: PTreeNode;
  node: PTreeNode;
begin
  node := NodePtr(NodeInt);
  if node.Balance = 0 then
    node.Balance := DIR_INC[Dir]
  else
  if node.Balance = DIR_INC[not Dir] then begin
    node.Balance := 0;
  end
  else
  begin   // new balancing
    l1 := NodePtr(node.Nodes[Dir]);
    if (l1.Balance = DIR_INC[Dir]) then
    begin // single rotation
      node.Nodes[Dir] := l1.Nodes[not Dir];
      l1.Nodes[not Dir] := node.Index;
      node.Balance := 0;
      node := l1;
    end else
    begin // double rotation
      l2 := NodePtr(l1.Nodes[not Dir]);
      l1.Nodes[not Dir] := l2.Nodes[Dir];
      l2.Nodes[Dir] := l1.Index;
      node.Nodes[Dir] := l2^.Nodes[not Dir];
      l2.Nodes[not Dir] := node.Index;

      if l2.Balance = DIR_INC[Dir] then
        node.Balance := DIR_INC[not Dir]
      else
        node.Balance := 0;

      if l2.Balance = DIR_INC[not Dir] then
        l1.Balance := DIR_INC[Dir]
      else
        l1.Balance := 0;

      node := l2;
    end;
    node.Balance := 0;
    NodeInt := node.Index;
  end;

  if ConditionZeroIsBalanced then
    NotBalanced := node.Balance = 0
  else
    NotBalanced := node.Balance <> 0;
end;

{$ifdef testTree}
procedure TIntervalsTree.WriteTreeState;
var
  i: int;
  rec: Ansistring;
  s: TFileStream;
begin
  s := TFileStream.Create('treeState.txt', fmCreate);
  try
    for i := FCacheNodes.Count - 1 downto FCacheNodes.Count - FCount do
    begin
      rec := Ansistring(FCacheNodes.Items[i].toString);
      s.Write(rec[1], length(rec));
    end;
  finally
    s.Free;
  end;
  FreeAndNil(FTestFile);
  //FTestFile := TFileStream.Create('testSamples.txt', fmCreate);
end;
{$endif}

procedure TIntervalsTree.GrowCacheNodes(GrowSize: int);
var
  i: int;
  node: TTreeNode;
begin
  i := FCacheNodes.Count;
  FCacheNodes.Capacity := FCacheNodes.Capacity + GrowSize;
  FFreeNodes.Capacity := FFreeNodes.Capacity + GrowSize;
  FillChar(node{%H-}, sizeof(node), 0);
  node.Nodes[NODE_LEFT] := -1;
  node.Nodes[NODE_RIGHT] := -1;
  for i := i to i + GrowSize - 1 do begin
    node.Index := i;
    FCacheNodes.Add(node);
    FFreeNodes.Add(i);
  end;
  FCacheNodesPtr := FCacheNodes.ShiftData[0];
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
  FCacheNodes.Free;
  FFreeNodes.Free;
  FFreeIntervals.Free;
  FStack.Free;
  FStackSearch.Free;
  {$ifdef testTree}
  FTestFile.Free;
  FTestFileRoots.Free;
  {$endif}
  inherited Destroy;
end;

{$ifdef RECURSION_INSERT}
function TIntervalsTree.InsertValue(NodeValue: double; var Node: int; var NotBalanced: boolean; var Interval: int): int;
var
  l: PTreeNode;
  dir: TDir;
begin
  if Node < 0 then
  begin // the value does not contained in the tree, insert it
   	Node := CreateNode(NodeValue, Interval).Index;
    NotBalanced := true;
    exit(Node);
  end;

  l := NodePtr(Node);
  if NodeValue = l.NodeValue then
    Result := Node
  else
  begin
    if (NodeValue > l.NodeValue) then
      dir := NODE_RIGHT
    else
      dir := NODE_LEFT;
    Result := InsertValue(NodeValue, l.Nodes[dir], NotBalanced, Interval);
   	if NotBalanced then
      Balance(Node, dir, NotBalanced, false);
  end;
end;
{$else}
function TIntervalsTree.InsertValue(NodeValue: double; var Interval: int): int;
var
  {$ifdef testTree}
  i: int;
  {$endif}
  l: PTreeNode;
  node, nodeParent: int;
  notBalanced: boolean;
  dir: TDir;
begin
  if FRoot < 0 then
  begin
    FRoot := CreateNode(NodeValue, Interval).Index;
    exit(FRoot);
  end;

  Result := FRoot;
  FStack.Count := 0;
  notBalanced := false;
  // inserting
  while true do
  begin
    l := NodePtr(Result);
    if NodeValue = l.NodeValue then
      break
    else
    begin

      if (NodeValue > l.NodeValue) then
        dir := NODE_RIGHT
      else
        dir := NODE_LEFT;

      {$ifdef testTree}
      for i := FStack.Count - 2 downto 0 do
        if FStack.Items[i] = Result then
        begin
          WriteTreeState;
          raise EWrongAlgorithm.Create('TIntervalsTree.InsertValue');
        end;
      {$endif}
      FStack.Add(Result);
      if l.Nodes[dir] < 0 then
      begin
        l.Nodes[dir] := CreateNode(NodeValue, Interval).Index;
        FStack.Add(l.Nodes[dir]);
        Result := l.Nodes[dir];
        notBalanced := true;
        break;
      end else
      begin
        Result := l.Nodes[dir];
      end;

    end;
  end;

  // balancing
  if (FStack.Count > 1) and notBalanced then
  begin
    node := FStack.Pop;
    while (FStack.Count > 0) do begin // and notBalanced do
      nodeParent := FStack.Pop;
      l := NodePtr(nodeParent);
      if NodeValue > l.NodeValue then
        dir := NODE_RIGHT
      else
        dir := NODE_LEFT;

      if (l.Nodes[dir] <> node) then
        l.Nodes[dir] := node;

      node := nodeParent;

      // important! allows + 1 iteration after finish balancing
      if not notBalanced then
        break;

      Balance(node, dir, notBalanced, false);
    end;

    if FStack.Count = 0 then
      FRoot := node;
  end;
end;
{$endif}

function TIntervalsTree.CreateNode(NodeValue: double; var Interval: int): PTreeNode;
var
  node: int;
begin
  node := FFreeNodes.Pop;
  Result := NodePtr(node);
  if Interval < 0 then
    Interval := CreateInterval;
  Result.NodeValue := NodeValue;
  InsertInterval(Interval, Result);
  Result.Nodes[NODE_LEFT] := -1;
  Result.Nodes[NODE_RIGHT] := -1;
  Result.Balance := 0;
  inc(FCount);
end;

function TIntervalsTree.CreateInterval: int;
begin
  if FFreeIntervals.Count = 0 then
    GrowCacheIntervals(FCacheIntervals.Count div 4);
  Result := FFreeIntervals.Pop;
end;

procedure TIntervalsTree.InsertInterval(Interval: int; Node: PTreeNode);
begin
  SetLength(Node.Intervals, length(Node.Intervals) + 1);
  Node.Intervals[length(Node.Intervals) - 1] := Interval;
end;

procedure TIntervalsTree.InsertInterval(Interval: int; Node: int);
begin
  InsertInterval(Interval, NodePtr(Node));
end;

function TIntervalsTree.NodePtr(Node: int): PTreeNode;
begin
  if Node < FCacheNodes.Count then
    Result := PTreeNode(PByte(FCacheNodesPtr) + Node * SizeOf(TTreeNode))
  else
    raise EWrongAlgorithm.Create('TIntervalsTree.NodePtr');
end;

function TIntervalsTree.IntervalPtr(Interval: int): PInterval;
begin
  if Interval < FCacheIntervals.Count then
    Result := PInterval(PByte(FCacheIntervalsPtr) + Interval * SizeOf(TInterval))
  else
    raise EWrongAlgorithm.Create('TIntervalsTree.IntervalPtr');
end;

procedure TIntervalsTree.CheckCache;
begin
  if FFreeNodes.Count = 0 then
  begin
    if FCacheNodes.Count > 1024 then
      GrowCacheNodes(FCacheNodes.Count div 4)
    else
      GrowCacheNodes(1024);
  end;
end;

function TIntervalsTree.ContainsValue(Node: int; Value: Pointer): int;
var
  i: int;
  nodeP: PTreeNode;
  interval: PInterval;
begin
  nodeP := NodePtr(Node);
  for i := 0 to length(nodeP.Intervals) - 1 do begin
    interval := IntervalPtr(nodeP.Intervals[i]);
    if interval.Value = Value then
      exit(nodeP.Intervals[i]);
  end;
  Result := -1;
end;

function TIntervalsTree.Add(Min, Max: double; Data: Pointer): int;
var
  left, right: int;
  interval: PInterval;
  {$ifdef testTree}
  rec: Ansistring;
  {$endif}
  {$ifdef RECURSION_INSERT}
  notBalanced: boolean;
  {$endif}
begin
  {$ifdef testTree}
    rec := AnsiString('FIntervalsTree.Add(' + IntToStr(round(Min)) + ', ' + IntToStr(round(Max)) + ', nil);' + sLineBreak);
    FTestFile.Write(rec[1], length(rec));
  {$endif}
  // In order to be sure that the memory block will not be changed if a new node appears
  CheckCache;
  Result := -1;
  {$ifdef RECURSION_INSERT}
  notBalanced := false;
  left := InsertValue(Min, FRoot, notBalanced, Result);
  notBalanced := false;
  right := InsertValue(Max, FRoot, notBalanced, Result);
  {$else}
  left := InsertValue(Min, Result);
  right := InsertValue(Max, Result);
  {$endif}
  if (Result < 0) then begin

    Result := ContainsValue(left, Data);
    if Result >= 0 then
      exit;

    Result := ContainsValue(right, Data);
    if Result >= 0 then
      exit;

    Result := CreateInterval;
    InsertInterval(Result, left);
    InsertInterval(Result, right);
  end;
  interval := IntervalPtr(Result);
  interval.MinIndex := left;
  interval.MaxIndex := right;
  interval.Value := Data;
  {$ifdef testTree}
    rec := AnsiString(IntToStr(FRoot) + sLineBreak);
    FTestFileRoots.Write(rec[1], length(rec));
  {$endif}
end;

function TIntervalsTree.Delete(DeletingNode: PTreeNode; Stack: TListVec<int>): boolean;
var
  parentIdx, childNodeBefore, nodeParent: int;
  parent: PTreeNode;
  predecessorIdx: int;
  predecessor: PTreeNode;
  dir: TDir;
  notBalanced: boolean;
  replacedIndx: int;
  comparedValue: double;
begin
  if Stack.Count > 0 then
    parentIdx := Stack.Items[Stack.Count - 1]
  else
    parentIdx := -1;
  comparedValue := deletingNode.NodeValue;
  // --- Step 1: If both children are present → replace with the predecessor ---
  if (DeletingNode.Nodes[NODE_LEFT] >= 0) and (DeletingNode.Nodes[NODE_RIGHT] >= 0) then
  begin
    replacedIndx := Stack.Count;
    Stack.Add(DeletingNode.Index);
    predecessorIdx := DeletingNode.Nodes[NODE_LEFT];
    predecessor := NodePtr(predecessorIdx);
    while predecessor.Nodes[NODE_RIGHT] >= 0 do begin
      Stack.Add(predecessorIdx);
      predecessor := NodePtr(predecessorIdx);
      predecessorIdx := predecessor.Nodes[NODE_RIGHT];
    end;
    predecessorIdx := Stack.Pop;
    Stack.Items[replacedIndx] := predecessorIdx;
    parent := NodePtr(Stack.Items[Stack.Count - 1]);
    parent.Nodes[NODE_RIGHT] := -1;
    childNodeBefore := -1;
  end
  else
  begin
    if DeletingNode.Nodes[NODE_LEFT] >= 0 then
      predecessorIdx := DeletingNode.Nodes[NODE_LEFT]
    else if DeletingNode.Nodes[NODE_RIGHT] >= 0 then
      predecessorIdx := DeletingNode.Nodes[NODE_RIGHT]
    else
      predecessorIdx := -1;
    childNodeBefore := predecessorIdx;
  end;

  if (predecessorIdx >= 0) then
  begin
    predecessor := NodePtr(predecessorIdx);
    comparedValue := predecessor.NodeValue;
    predecessor.Nodes[NODE_LEFT] := DeletingNode.Nodes[NODE_LEFT];
    predecessor.Nodes[NODE_RIGHT] := DeletingNode.Nodes[NODE_RIGHT];
    if predecessor.Nodes[NODE_LEFT] = predecessor.Index then
      predecessor.Nodes[NODE_LEFT] := -1
    else
    if predecessor.Nodes[NODE_RIGHT] = predecessor.Index then
      predecessor.Nodes[NODE_RIGHT] := -1
    else
      predecessor.Balance := DeletingNode.Balance;

    if (parentIdx >= 0) then
    begin
      parent := NodePtr(parentIdx);
      if DeletingNode.NodeValue > parent.NodeValue then
        parent.Nodes[NODE_RIGHT] := predecessor.Index
      else
        parent.Nodes[NODE_LEFT] := predecessor.Index;
    end;

    if DeletingNode.Index = FRoot then
      FRoot := predecessorIdx;
  end;

  // --- Step 2: Balancing ---
  nodeParent := FRoot;
  if (Stack.Count > 0) then
  begin
    notBalanced := true;
    while (Stack.Count > 0) and notBalanced do begin
      nodeParent := Stack.Pop;
      parent := NodePtr(nodeParent);

      if comparedValue > parent.NodeValue then
        dir := NODE_RIGHT
      else
        dir := NODE_LEFT;

      if parent.Nodes[dir] <> childNodeBefore then
        parent.Nodes[dir] := childNodeBefore;

      parentIdx := nodeParent;
      Balance(nodeParent, not dir, notBalanced, true);

      if parentIdx = FRoot then
        FRoot := nodeParent;

      childNodeBefore := nodeParent;
    end;
  end;

  FFreeNodes.Add(DeletingNode.Index);

  Result := true;
end;

procedure TIntervalsTree.RemoveInteval(Node: PTreeNode; Position: int);
var
  i: int;
begin
  for i := 0 to length(Node.Intervals) - 1 do
  begin
    if (Node.Intervals[i] = Position) then
    begin
      if i < length(Node.Intervals) - 1 then
        move(Node.Intervals[i+1], Node.Intervals[i], length(Node.Intervals) - 1 - i);
      SetLength(Node.Intervals, length(Node.Intervals) - 1);
      break;
    end;
  end;
end;

procedure TIntervalsTree.Select(Interval: int; var MinIndex, MaxIndex: int; var Data: Pointer);
var
  intrvl: PInterval;
begin
  intrvl := IntervalPtr(Interval);
  MinIndex := intrvl.MinIndex;
  MaxIndex := intrvl.MaxIndex;
  Data := intrvl.Value;
end;

procedure TIntervalsTree.Select(Node: int; var Left, Right: int; var NodeValue: double; var Balance: int8; var Intervals: TIntervals);
var
  l: PTreeNode;
begin
  l := NodePtr(Node);
  NodeValue := l.NodeValue;
  Left := l.Nodes[NODE_LEFT];
  Right := l.Nodes[NODE_RIGHT];
  Balance := l.Balance;
  Intervals := l.Intervals;
end;

procedure TIntervalsTree.Select(Interval: int; var Min, Max: double; var Data: Pointer);
var
  intrvl: PInterval;
begin
  intrvl := IntervalPtr(Interval);
  Min := NodePtr(intrvl.MinIndex).NodeValue;
  Max := NodePtr(intrvl.MaxIndex).NodeValue;
  Data := intrvl.Value;
end;

function TIntervalsTree.Delete(Interval: int): boolean;
var
  intrvl: PInterval;
  Min, Max: double;
  Data: Pointer;
begin
  intrvl := IntervalPtr(Interval);
  Min := NodePtr(intrvl.MinIndex).NodeValue;
  Max := NodePtr(intrvl.MaxIndex).NodeValue;
  Data := intrvl.Value;
  Result := Delete(Min, Max, Data);
end;

function TIntervalsTree.Delete(Min, Max: double; Data: Pointer): boolean;
var
  interval: PInterval;
  posMin, posMax: int;
  node: PTreeNode;
begin
  posMin := Exists(Min, Data, FStackSearch);
  Result := posMin >= 0;
  if Result then
  begin
    interval := IntervalPtr(posMin);
    node := NodePtr(interval.MinIndex);
    RemoveInteval(node, posMin);
    if length(node.Intervals) = 0 then
    begin
      Delete(node, FStackSearch);
    end;
  end;

  posMax := Exists(Max, Data, FStack);
  if (Result and (posMax < 0)) or (not Result and (posMax >= 0)) or (posMin <> posMax) then
    raise EWrongAlgorithm.Create('TIntervalsTree.Delete');

  if Result then
  begin
    interval := IntervalPtr(posMax);
    node := NodePtr(interval.MaxIndex);
    RemoveInteval(node, posMax);
    if length(node.Intervals) = 0 then
    begin
      Delete(node, FStack);
    end;
    FFreeIntervals.Add(posMax);
    dec(FCount);
  end;
end;

function TIntervalsTree.Exists(Value: double; Data: Pointer; StackSearch: TListVec<int>): int;
var
  node: PTreeNode;
begin
  Result := -1;
  if (FRoot < 0) then
    exit;
  FStack.Count := 0;
  FStack.Add(FRoot);
  while (FStack.Count > 0) do
  begin
    node := NodePtr(FStack.Pop);
    if (Value > node.NodeValue) then
    begin  // right
      StackSearch.Add(node.Index);
      if node.Nodes[NODE_RIGHT] >= 0 then
        FStack.Add(node.Nodes[NODE_RIGHT]);
    end else
    if (Value < node.NodeValue) then
    begin  // left
      StackSearch.Add(node.Index);
      if node.Nodes[NODE_LEFT] >= 0 then
        FStack.Add(node.Nodes[NODE_LEFT]);
    end else
    if (Value = node.NodeValue) then
    begin  // hit
      Result := ContainsValue(node.Index, Data);
      if Result >= 0 then
        exit;
      if node.Nodes[NODE_LEFT] >= 0 then
        FStack.Add(node.Nodes[NODE_LEFT]);
      if node.Nodes[NODE_RIGHT] >= 0 then
        FStack.Add(node.Nodes[NODE_RIGHT]);
    end;
  end;
end;



function TIntervalsTree.Exists(Min, Max: double; Data: Pointer): int;
begin
  Result := Exists(Min, Max, Data);
end;

function TIntervalsTree.Find(Value: double): int;
var
  node: PTreeNode;
begin
  if (FRoot < 0) then
    exit(-1);
  FStack.Count := 0;
  FStack.Add(FRoot);
  while (FStack.Count > 0) do
  begin
    node := NodePtr(FStack.Pop);
    if (Value > node.NodeValue) then
    begin  // right
      if node.Nodes[NODE_RIGHT] >= 0 then
        FStack.Add(node.Nodes[NODE_RIGHT]);
    end else
    if (Value < node.NodeValue) then
    begin  // left
      if node.Nodes[NODE_LEFT] >= 0 then
        FStack.Add(node.Nodes[NODE_LEFT]);
    end else
    begin  // hit
      Exit(node.Index);
    end;
  end;
  Result := -1;
end;

procedure TIntervalsTree.Select(Min, Max: double; ListResult: TListVec<Pointer>);
var
  i: int;
  node: PTreeNode;
begin
  if (FRoot < 0) then
    exit;
  FStack.Count := 0;
  FStack.Add(FRoot);
  while (FStack.Count > 0) do
  begin
    node := NodePtr(FStack.Pop);
    if (Max > node.NodeValue) then
    begin  // right
      if node.Nodes[NODE_RIGHT] >= 0 then
        FStack.Add(node.Nodes[NODE_RIGHT]);
    end else
    if (Min < node.NodeValue) then
    begin  // left
      if node.Nodes[NODE_LEFT] >= 0 then
        FStack.Add(node.Nodes[NODE_LEFT]);
    end else
    begin  // hit
      if node.Nodes[NODE_LEFT] >= 0 then
        FStack.Add(node.Nodes[NODE_LEFT]);
      if node.Nodes[NODE_RIGHT] >= 0 then
        FStack.Add(node.Nodes[NODE_RIGHT]);
      for i := 0 to length(node.Intervals) - 1 do
        ListResult.Add(IntervalPtr(node.Intervals[i]).Value);
    end;
  end;
end;

procedure TIntervalsTree.Clear;
var
  i: int;
  node: PTreeNode;
begin
  if (FRoot < 0) then
    exit;
  FStack.Count := 0;
  FStack.Add(FRoot);
  while (FStack.Count > 0) do
  begin
    node := NodePtr(FStack.Pop);
    if node.Nodes[NODE_LEFT] >= 0 then
      FStack.Add(node.Nodes[NODE_LEFT]);
    if node.Nodes[NODE_RIGHT] >= 0 then
      FStack.Add(node.Nodes[NODE_RIGHT]);
    for i := 0 to length(node.Intervals) - 1 do
      FFreeIntervals.Add(node.Intervals[i]);
    FFreeNodes.Add(node.Index);
    SetLength(node.Intervals, 0);
  end;
  FRoot := -1;
end;

{$ifdef testTree}
{ TIntervalsTree.TTreeNode }

function TIntervalsTree.TTreeNode.toString: string;
begin
  Result :=
  '{' + sLineBreak +
  '  Index: ' + IntToStr(Index) + ';'  + sLineBreak +
  '  NodeValue: ' + IntToStr(trunc(NodeValue)) + ';'  + sLineBreak +
  '  Balance: ' + IntToStr(Balance) + ';'  + sLineBreak +
  '  Nodes: '  + IntToStr(Nodes[NODE_LEFT]) + ', ' + IntToStr(Nodes[NODE_RIGHT]) + ';' + sLineBreak +
  '},' + sLineBreak;

end;
{$endif}

end.

