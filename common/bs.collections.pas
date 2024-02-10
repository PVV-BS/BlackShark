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


{$ifdef FPC}
  {$mode delphi}
{$endif}

unit bs.collections;

{$R-,T-,X+,H+,B-}
interface

uses
  Classes,
  SysUtils
  ;

type

{ order iterate for find item in container by a value }
TOrderIterType = (otFromBegin, otFromEnd);

{ TListVec

}

TListVec<T> = class
public
  type
    TListComparatorItems = function (const Item1, Item2: T): int8;
    TArrayOfT = array of T;
    PArrayOfT = ^TArrayOfT;
    TPointerOfT = ^T;
private
  FCapacity: int32;
  FCount: int32;
  fDefault: T;
  FComparator: TListComparatorItems;
  FTagPtr: Pointer;
  function GetItem(index: int32): T;
  function GetShiftData(index: int32): Pointer;
  procedure SetCapacity(AValue: int32); inline;
  procedure SetCount(AValue: int32);
  procedure SetItem(index: int32; AValue: T);
  //procedure SetSort(const Value: boolean);
  procedure SetDefault(const Value: T);
  //procedure Insert(Item: T; Index: int32);
protected
  FData: TArrayOfT;
  FPtrOfData: PArrayOfT;
  procedure SortList(L, R: Longint);
public
  { The overloaded constructors allow to translate in the list a comparator used
    for sort values }
  constructor Create(AComparator: TListComparatorItems); overload;
  constructor Create; overload;
  destructor Destroy; override;
  procedure Add(const Item: T); overload;
  procedure Add(const Items: array of T); overload;
  procedure Add(Items: TPointerOfT; CountItems: int32); overload;
  procedure AddList(List: TListVec<T>);
  procedure Insert(const Item: T; Position: int32);
  procedure SetList(List: TListVec<T>);
  function Pop: T;
  procedure Delete(Index: int32); overload;
  procedure Delete(Index: int32; CountItem: int32); overload;
  { this couple of methods work with use Comparator, that's why you must use
    an apropriate constructor for translate comparator if you feel like to further
    to use this methods }
  function Remove(const Item: T; OrderIteration: TOrderIterType = TOrderIterType.otFromBegin): boolean;
  function IndexOf(const Item: T; OrderIteration: TOrderIterType = TOrderIterType.otFromBegin): int32;
  function Copy: TArrayOfT;
  procedure Fill(const Value: T); overload;
  procedure Fill(const Value: T; Start, Count: int32); overload;
  procedure Exchange(Index1, Index2: int32);
  procedure Clear;
  procedure Sort;
  property Capacity: int32 read FCapacity write SetCapacity;
  property Count: int32 read FCount write SetCount;
  property Items[index: int32]: T read GetItem write SetItem;
  property Data: PArrayOfT read FPtrOfData;
  property ShiftData[index: int32]: Pointer read GetShiftData;
  property DefaultValue: T read fDefault write SetDefault;
  property Comparator: TListComparatorItems read FComparator write FComparator;
  property TagPtr: Pointer read FTagPtr write FTagPtr;
end;

{ TListDual<T> }

{ It is a bidirectional list:
  - represents the template for quick insert and delete
    values in any positions relative another;
  - allows to get access with index as usual list with property TListDual<T>.Cursor and
    TListDual<T>.UnderCursorItem;
  - quickly clearing of all items by TListDual<T>.Clear;
}

TListDual<T> = class
public
  type
    PListItem = ^TListItem;
    TListItem = record
      Item: T;
      Next: PListItem;
      Prev: PListItem;
    end;
private
  FCount: int32;
  FFirst: TListItem;
  FLast: PListItem;
  FreeItems: PListItem;
  fDefault: T;
  FCursor: int32;
  CursorItem: PListItem;
  function GetFreeItem: PListItem; inline;
  function GetItemListFirst: PListItem;
  function GetItemListLast: PListItem;
  procedure SetCursor(const Value: int32);
    function GetItem(Index: int32): T;
    procedure SetItem(Index: int32; const Value: T);
public
  destructor Destroy; override;
  procedure Clear;
  function PushToBegin(const Item: T): PListItem;
  function PushToEnd(const Item: T): PListItem;
  function InsertAfter(const Item: T; After: PListItem): PListItem;
  function InsertBefor(const Item: T; Befor: PListItem): PListItem;
  function Remove(var Item: PListItem; FreeItem: boolean = true): PListItem; //overload;
  function Pop: T;
  function PopBegin: T;
  { Reads a value from current position cursor }
  function Read: PListItem;
  { Wirtes a value to current position cursor }
  function Write(const Item: T): PListItem;
  { Count items in container }
  property Count: int32 read FCount;
  { A current position for read/write; allows to get access to data as in
    a homogeneous array by index; it's slowly, but sometimes very useful }
  property Cursor: int32 read FCursor write SetCursor;
  property UnderCursorItem: PListItem read CursorItem;
  { A urapper for access by Cursor }
  property Item[Index: int32]: T read GetItem write SetItem;
  property DefaultT: T read fDefault;
  property ItemListFirst: PListItem read GetItemListFirst;
  property ItemListLast: PListItem read GetItemListLast;
end;

TKeyComparator<K> = function (const Key1, Key2: K): int8;
TKeyComparatorEqual<K> = function (const Key1, Key2: K): boolean;

{ TBinTreeTemplate<K, V> }

{   A tempalate balanced tree:
    - after balancing (in case of adding or deleting) a node linked in key saved;
    - for collect own values you MUST define and set a value comparator
      (sorry, that pascal do not supports full paradigm a template as in C++);
    - for enumeration items use an iterator: TBinTreeTemplate<K, V>.Iterator
    - a highlight property this tree: the iterator gives automatically ordered
      by key values;

  TODO: parent node for quick delete by node }

TBinTreeTemplate<K, V> = class
public
  type
    PBinTreeItem = ^TBinTreeItem;
    TBinTreeItem = record
    private
      parent_iter: PBinTreeItem;  // for iteration
      in_right_iter: boolean;     // for iteration
    public
      bal: int8; // -1..1
      left, right: PBinTreeItem;
      Key: K;
      Value: V;
    end;
public
  type

    { TBinTreeIterator }

    {
      to iterate of values you approximately need to do so:

      var
        mydata: V;
        ok: boolean;
      begin
      ok := BinTree.Iterator.SetToBegin(mydata);
      while ok do
        begin
        // do something with a value (mydata)

        // it is taking the next value
        ok := BinTree.Iterator.Next(mydata);
        end;
      end;

      or so

      if BinTree.Iterator.SetToBegin(mydata) then
        repeat
          // do something with a value (mydata)

        until not BinTree.Iterator.Next(mydata);

      TODO: deleting values in during an iteration (like in stl::map C++);

    }
    TBinTreeIterator = class
    private
      FTree: TBinTreeTemplate<K, V>;
      procedure MoveDown(var StartNode: PBinTreeItem); inline;
    public
      CurrentNode: PBinTreeItem;
      IterateNow: boolean;
    public
      constructor Create(ATree: TBinTreeTemplate<K, V>);
      // in success return Value
      function SetToBegin(out Value: V): boolean; overload;
      function SetToBegin: boolean; overload; inline;
      // in success return Value
      function Next(out Value: V): boolean; overload;
      function Next: boolean; overload; inline;
      { TODO: TBinTreeIterator.DeleteCurrent }
      // delete current and return next Value or Node
      // function DeleteCurrent(out Value: T): boolean; override;
      // function DeleteCurrent: PBinTreeItem; override;
    end;

private
  FreeNodes: TList;
  FIterator: TBinTreeIterator;
  FName: WideString;
  FRoot: PBinTreeItem;
  FTagInt: NativeInt;
  function CreateNode(const Key: K; const Value: V): PBinTreeItem; inline;
  procedure Del(var r: PBinTreeItem; var p: PBinTreeItem; deleting: PBinTreeItem; var h: boolean);
  function Delete(Key: PBinTreeItem; var p: PBinTreeItem; var h: boolean
    ): boolean;
  function DeleteByKey(Key: K; var p: PBinTreeItem; var h: boolean): boolean;
  procedure BalLeftAfterDel(var p : PBinTreeItem; var h : boolean); inline;
  procedure BalRightAfterDel(var p : PBinTreeItem; var h : boolean); inline;
  procedure BalanceLeft(var p: PBinTreeItem; var h: boolean);  inline;
  procedure BalanceRight(var p: PBinTreeItem; var h: boolean); inline;
  procedure ChBal(Node: PBinTreeItem; var Depth: int32; var Res: PBinTreeItem);
protected
  StackNodes: TList;
  FKeyComparator: TKeyComparator<K>;
  FDefaultValue: V;
  FDepth, FMinLen: uint32;
  FItemCount: uint32;
  function SearchAndInsertKey(const Key: K; const Value: V; var p: PBinTreeItem; var Added: boolean;
    var H: boolean): PBinTreeItem; inline;
  procedure DoDeleteNode(Node: PBinTreeItem); virtual;
  function DoFind(StartNode: PBinTreeItem; const Key: K): PBinTreeItem;
public
  constructor Create(AKeyComparator: TKeyComparator<K>); overload; virtual;
  constructor Create; overload;
  destructor Destroy; override;
  procedure Clear(FreeMemory: boolean = false);
  { it adds key/data to the tree; on success returns true }
  function Add(const Key: K; const Value: V): boolean; overload; virtual;
  procedure AddOrReplaceValue(const Key: K; const Value: V);
  function AddNode(const Key: K; const Value: V): TBinTreeTemplate<K, V>.PBinTreeItem; overload; virtual;
  { find user data by key; in success return result to Value;
      }
  function Find(const Key: K; out Value: V): boolean; overload; virtual;
  {  }
  function Exists(const Key: K): boolean;
  // find node tree by key; in success return tree node
  function FindNode(const Key: K): PBinTreeItem; overload; virtual;
  // find path
  function FindPath(const Key: K): TList; virtual;
  // Delete key/data from tree;
  function Remove(const Key: K): boolean;
  function RemoveNode(Key: PBinTreeItem): boolean;
  function DebugCheckBalance: PBinTreeItem;
  property Iterator: TBinTreeIterator read FIterator;
  property Count: uint32 read FItemCount;
  property Name: WideString read FName write FName;
  property TagInt: NativeInt read FTagInt Write FTagInt;
  // max size key; actual only for static (widening) tree
  property Depth: uint32 read FDepth;
  // min size key;
  property MinLen: uint32 read FMinLen;
  property Root: PBinTreeItem read FRoot;
  property DefaultValue: V read FDefaultValue write FDefaultValue;
end;

TValueBin = record
  Data: pByte;
  LenData: uint32;
end;


{ The binary tree is allowing to contain values with different binary length keys;
  use TBinTree<V>.FindSoft/FindSoftAll/FindNodeSoft for find keys in binary buffer;
  Notifyes about all found keys throw OnFindNode trigger }

TBinTree<V> = class(TBinTreeTemplate<TValueBin, V>)
public
  type
    TBinTreeNode = TBinTreeTemplate<TValueBin, V>.PBinTreeItem;
    TOnFindNodeBinTree = procedure (Position: int32; Node: TBinTreeNode) of object;
private
  FOnFindNode: TOnFindNodeBinTree;
  class function CompareKeys(const Key1, Key2: TValueBin): int8; static;
  class function CompareSoft(const InBuffer, Key: TValueBin): int8; static;
protected
  CurrentPosition: int32;
  FKeyComparatorSoft: TKeyComparator<TValueBin>;
  procedure DoDeleteNode(Node: TBinTreeNode); override;
  procedure CheckChildsAndNotify(Node: TBinTreeNode; const Key: TValueBin);
public
  { despate translate a comparator as parameter, inside uses private
    comparator for compare binary buffers }
  constructor Create(AKeyComparator: TKeyComparator<TValueBin>); overload; override;
  { adding a new key; note, for compare used a private comparator (see constructor
    below) }
  function Add(const Key: pByte; const LenKey: uint32; const Value: V): boolean; overload; virtual;
  function Add(const Key: WideString; const Value: V): boolean; overload;
  function Add(const Key: AnsiString; const Value: V): boolean; overload;
  function Add(const Key: int32; const Value: V): boolean; overload;
  function Add(const Key: int64; const Value: V): boolean; overload;
  { finds the first key in the first position Data }
  function FindSoft(const Data: pByte; const LenData: uint32; out Value: V): boolean; virtual;
  { finds all keys in Data; the method need for search keys in a big buffer;
    returns result by OnFindNode }
  procedure FindSoftAll(const Data: pByte; const LenData: uint32); virtual;
  { find a user data by key;
    on success return pointer to the user data }
  function Find(const Key: pByte; const LenKey: uint32; out Value: V): boolean; overload; virtual;
  function Find(const Key: WideString; out Value: V): boolean; overload;
  function Find(const Key: AnsiString; out Value: V): boolean; overload;
  function Find(const Key: int32; out Value: V): boolean; overload;
  function Find(const Key: int64; out Value: V): boolean; overload;
  { find node tree by key; in success return tree node }
  function FindNode(const Key: pByte; const LenKey: int32): TBinTreeNode;
  { find (as and FindSoft) node with adapted LenKey to Node.Key.LenData if
    LenKey more; use method for find keys in big buffer }
  function FindNodeSoft(const Data: pByte; const LenData: uint32; StartNode: TBinTreeNode = nil): TBinTreeNode;
  { a deleting a key }
  function Remove(const Key: pByte; const LenKey: uint32): boolean; overload;
  function Remove(const Key: WideString): boolean; overload;
  function Remove(const Key: AnsiString): boolean; overload;
  function Remove(const Key: int32): boolean; overload;
  function Remove(const Key: int64): boolean; overload;
  property OnFindNode: TOnFindNodeBinTree read FOnFindNode write FOnFindNode;
end;

{ TBinTreeNotSensitive<V> }

{ It is not sensitive to register a tree; usefull for collect and search ansi strings
  TODO: to consider addition of keys in different code pages (with translating to unicode)
  and present input data for the finding as unicode }

TBinTreeNotSensitive<V> = class(TBinTree<V>)
private
  BufForTranslate: array of byte;
  SizeBuf: int32;
  g_TableTranslateToUp: array[byte] of byte;
  procedure ToUp(Src: pByte; Len: int32);
public
  constructor Create(AKeyComparator: TKeyComparator<TValueBin>); overload; override;
  destructor Destroy; override;
  { Addition Key with adaptation to single register }
  function Add(const Key: pByte; const LenKey: uint32; const Value: V): boolean; overload; override;
  { Find a value not sensitive to register (that is the Key translates to up)
    IDENTICAL the Key }
  function Find(const Key: pByte; const LenKey: uint32; out Value: V): boolean; overload; override;
  { Find a value IDENTICAL the KeyUp; unlike from Find do not translate to up }
  function FindUp(const KeyUp: pByte; const LenKey: uint32; out Value: V): boolean;
  { Not sensitive to register method search; return result through event TBinTree<V>.OnFindNode }
  procedure FindSoftAll(const Key: pByte; const LenKey: uint32); override;
  { Find TBinTreeTemplate<K, V>.PBinTreeItem.Key in buffer Key }
  function FindSoft(const Key: pByte; const LenKey: uint32; out Value: V): boolean; override;
end;

TValueComparator<V> = function (const V1, V2: V): boolean;

{ TBinTreeMultiValue<K, V> }

TBinTreeMultiValue<K, V> = class
public
  type
    TMultiValue = record
      Values: array of V;
      //Count: int32;
    end;
    TBinTreeMultiValueNode = TBinTreeTemplate<K, TMultiValue>.PBinTreeItem;
private
  FValueComparator: TValueComparator<V>;
  FMultiTree: TBinTreeTemplate<K, TMultiValue>;
  FDefaultValue: V;
public
  constructor Create(AKeyComparator: TKeyComparator<K>; AValueComparator: TValueComparator<V>);
  destructor Destroy; override;
  function Add(const Key: K; const Value: V): TBinTreeMultiValueNode;
  function Remove(const Key: K; const Value: V): boolean; overload;
  function Remove(const Node: TBinTreeMultiValueNode; const Value: V): boolean; overload;
  function FindNode(const Key: K): TBinTreeTemplate<K, TMultiValue>.PBinTreeItem;
  function Find(const Key: K): V;
  procedure Clear;
  property ValueComparator: TValueComparator<V> read FValueComparator write FValueComparator;
  property MultiTree: TBinTreeTemplate<K, TMultiValue> read FMultiTree;
  property DefaultValue: V read FDefaultValue write FDefaultValue;
end;

THashFunction<K> = function (const Key: K): uint32;

{ THashMap<K, V>

  wraps multi tree for resolve keys collisions }

THashMap<K, V> = class
public
  type
    TMultiTree = TBinTreeMultiValue<uint32, V>;
    TMultiTreeNode = TMultiTree.TBinTreeMultiValueNode;
private
  FMultiTree: TMultiTree;
  HashFunction: THashFunction<K>;
public
  constructor Create(AHashFunction: THashFunction<K>; AValueComparator: TValueComparator<V>);
  destructor Destroy; override;
  function Add(const Key: K; const Value: V): TMultiTreeNode;
  function Remove(const Key: K; const Value: V): boolean; overload;
  function Remove(const Node: TMultiTreeNode; const Value: V): boolean; overload;
  function FindNode(const Key: K): TMultiTreeNode;
  function Find(const Key: K): V;

  procedure Clear;
  property MultiTree: TMultiTree read FMultiTree;
end;

{ TQueueFIFO<T> }
{
  The class implements a thread-safe queue for pair threads: one are writing,
  the other thread are reading. The class realises queue as template FIFO: First
  In First Out
}

TQueueFIFO<T> = class
public
type
  TQueueEventNotify = procedure(Queue: TQueueFIFO<T>) of object;
  TProcessEventNotify = procedure(Event: T) of object;
private
  type
    PQueueItem = ^TQueueItem;
    TQueueItem = record
      Item: T;
      Next: PQueueItem;
    end;
private
  FCountWrite: int64;
  FCountRead: int64;
  FFixedCapacity: boolean;
  QRead: PQueueItem;
  QWrite: PQueueItem;
  FCapacity: int32;
  fDefault: T;
  FOnWrite: TQueueEventNotify;
  FSourceThread: Pointer;
  FTagProcedure: TProcessEventNotify;
  FTagPtr: Pointer;
  FSync: boolean;
  function GetCount: int32; inline;
  { setter a capacity; invokes when creates, or places (procedure push) value <T>
    to the queue a written thread }
  procedure SetCapacity(const Value: int32);
public
  constructor Create(ASourceThread: Pointer = nil; ACapacity: int32 = 65536;
    ASync: boolean = false);
  destructor Destroy; override;
  { clear queue  !!! the method is not thread-safe }
  procedure Clear;
  { places into an end queue; returns "false" if queue full and property
    FixedCapacity equal "true"; to invoke only from a writing thread !!! }
  function Push(const Item: T): boolean;
  { returns to Item saved the data from begin queue; if "true" - return one item
    queue to invoke only from a reading thread !!! }
  function Pop(out Item: T): boolean; overload; inline;
  { returns saved a data from begin queue; useful, for example, for pointers,
    that is, for that returning a data, a sign which you can validate }
  function Pop: T; overload;
  { count values in queue }
  property Count: int32 read GetCount;
  { the capacity queue }
  property Capacity: int32 read FCapacity write SetCapacity;
  { if FixedCapacity equally "false" then the capacity expands automaticaly,
    when not enough the capacity for place a value }
  property FixedCapacity: boolean read FFixedCapacity write FFixedCapacity;
  { a pointer-tag for external use }
  property TagPtr: Pointer read FTagPtr write FTagPtr;
  { for external use; you can set TagProcedure for processing through incoming
    items }
  property TagProcedure: TProcessEventNotify read FTagProcedure write FTagProcedure;
  { for external use; the event is invoked only in a writing thread context }
  property OnWrite: TQueueEventNotify read FOnWrite write FOnWrite;
  { for external use; initialazed in constructor }
  property SourceThread: Pointer read FSourceThread write FSourceThread;
  { if it is true then a writing thread wait while a reading thread do not
    take away a new pushed item; the property sets through constructor }
  property Sync: boolean read FSync;
end;

{ TSingleList }

{ It is a simple homogeneous list, wrapper above array of T }

TSingleList<T> = class
public
  type
    PSingleListHead = ^TSingleListHead;
    TSingleListHead = record
      Items: array of T;
      Count: int32;
    end;
    TPointerT = ^T;
public
  class procedure Create(var Head: TSingleListHead; Capacity: int32 = 4); static; inline;
  class procedure Free(var Head: TSingleListHead); static; inline;
  class procedure CheckCapacity(var Head: TSingleListHead); overload; static; inline;
  class procedure CheckCapacity(var Head: TSingleListHead; NewCap: int32); overload; static; inline;
  class procedure SetCapacity(var Head: TSingleListHead; Capacity: int32); static; inline;
  class procedure Add(var Head: TSingleListHead; const Item: T); overload; static; inline;
  class procedure Copy(var Head: TSingleListHead; const Source: TSingleListHead); overload; static; inline;
  { it is not safe function; uses memory comparition for find position of Item;
    it work well for any simple types, including any pointers, but, for managed
    types, for example, strings, it works wrong, because in ideal need a
    comparator; for these occasions I recommend to use TListVec<T>;
    therefor, use the method on you discretion without warranty of success }
  class function Delete(var Head: TSingleListHead; const Item: T): boolean; static; inline;
end;

{
  TVirtualTree<T>
  Implementation a virtual hierarchical data struct;
}

TVirtualTree<T> = class
public
  type
    PVirtualTreeNode = ^TVirtualTreeNode;
    TListVirtualNodes = TListDual<PVirtualTreeNode>;
    TNodeEventNotifyer = procedure (Node: PVirtualTreeNode) of object;
    { The saver an user data (T) belonging this node; developer define this method
      for save tne self data to Stream in current position (don't change current
      position in stream!) }
    TNodeSaver = procedure (Node: PVirtualTreeNode; Stream: TStream) of object;
    { The loader an user data (T) belonging to this node; developer define this method for load self
      data from Stream in current position a size equal the SizeData }
    TNodeLoader = procedure (Node: PVirtualTreeNode; Stream: TStream; SizeData: int32) of object;
    TVirtualTreeNode = record
    private
      _ItemList: TListVirtualNodes.PListItem;
    public
      Parent: PVirtualTreeNode;
      Childs: TListVirtualNodes;
    	//Level: int32;
      Data: T;
    end;
private
  type
    TNodeRec = record
      Size: int32;
      UserDataSize: int32;
      Childs: int32;
    end;
private
  FName: WideString;
  FOnCreateNode: TNodeEventNotifyer;
  FOnDeleteNode: TNodeEventNotifyer;
  FOnLoadNode: TNodeLoader;
  FOnSaveNode: TNodeSaver;
  FRootNodes: TListVirtualNodes;
  FTag: NativeInt;
  FVersion: int32;
  FSignature: AnsiString;
  FDefaultValue: T;
  FData: TStream;
  procedure SaveNode(Node: PVirtualTreeNode; Stream: TStream);
  function LoadNode(Parent: PVirtualTreeNode; Stream: TStream): PVirtualTreeNode;
public
  constructor Create;
  destructor Destroy; override;
  function CreateNode(Parent: PVirtualTreeNode): PVirtualTreeNode; overload;
  function CreateNode(Parent: PVirtualTreeNode; const Data: T): PVirtualTreeNode; overload;
  { if DeleteChilds = false then for all childs assigned deleted node Parent }
  procedure DeleteNode(Node: PVirtualTreeNode; DeleteChilds: boolean = true; Silent: boolean = false);
  { Set new parent for Node }
  procedure SetNodeParent(Node, Parent: PVirtualTreeNode);
  procedure ClearNodeChilds(Node: PVirtualTreeNode);
  procedure Clear;
  function SaveTo(const FileName: string): boolean; overload;
  function SaveTo(Stream: TStream): boolean; overload;
  function LoadFrom(const FileName: string): boolean; overload;
  function LoadFrom(Stream: TStream): boolean; overload;
  property OnSaveNode: TNodeSaver read FOnSaveNode write FOnSaveNode;
  property OnLoadNode: TNodeLoader read FOnLoadNode write FOnLoadNode;
  property OnCreateNode: TNodeEventNotifyer read FOnCreateNode write FOnCreateNode;
  property OnDeleteNode: TNodeEventNotifyer read FOnDeleteNode write FOnDeleteNode;
  property DefaultValue: T read FDefaultValue write FDefaultValue;
  property Signature: AnsiString read FSignature write FSignature;
  { Set Version befor SaveTo; when called LoadFrom Version loaded from data;
    in dependly from Version you may call variable methods for load data
    belonging to a node }
  property Version: int32 read FVersion write FVersion;
  property Tag: NativeInt read FTag write FTag;
  property Name: WideString read FName write FName;
  property Data: TStream read FData;
  property RootNodes: TListVirtualNodes read FRootNodes;
end;

{
  TAhoCorasickFSA<T> is the Finite-state automaton (machine) built by the
  Aho–Corasick algorithm: https://en.wikipedia.org/wiki/Aho–Corasick_algorithm.
  For a right work need calculate all suffexes of words, therefor need invoke
  BeginUpdate befor adding, and EndUpdate after adding all words; the container
  suits for saving static data.
  You also can use the container for safe pairs word(the same key-value), and
  farther to find values by word(key) through WordExists. Beside, for this
  you unnecessary calculute suffixes (invoke BeginUpdate, EndUpdate)
}

TAhoCorasickFSA<T> = class
public
  type

    TUserData = record
      UserData: T;
    end;
    PUserData = ^TUserData;

    PVertex = ^TVertex;
    TVertex = record
      { value of vertex }
      Ch: byte;
      //IsFinite: boolean;
      Suffix: PVertex;
      { a current depth (index of byte in ) => max length of key is 65536 }
      Level: uint16;
      { reference the nexl level (child) - binary balanced tree }
      Subtree: PVertex;
      { -1..1 - a balance of the vertex }
      Balance: int8;
      { it are balanced left and right branches }
      Left: PVertex;
      Right: PVertex;
      { for saving user data to finite vertex define a separate dynamic var;
        that is why we consider vertex as finite if UserData <> nil }
      UserData: PUserData;
    end;

    {$ifdef FPC}
    TOnFoundProc = procedure (const Data: T; Key: pByte; KeyLen: int32) of object;
    {$else}
    TOnFoundProc = reference to procedure (const Data: T; Key: pByte; KeyLen: int32);
    {$endif}

private
  FRootVertex: PVertex;
  FCountVertexes: int32;
  FOnFoundProc: TOnFoundProc;
  _CountUpd: int32;
  StackData: array[1..65536] of byte;
  FDefault: T;
  FCount: int32;
  function CreateNode(Key: byte): PVertex; inline;
  procedure BalanceLeft(var Vert: PVertex; var H: boolean);  inline;
  procedure BalanceRight(var Vert: PVertex; var H: boolean); inline;
  function InsertKey(Key: byte; var Vert: PVertex; var Added, H: boolean): PVertex;
  function FindVert(Key: byte; Root: PVertex): PVertex; inline;
  { finds all suffixes for vert and its children it is a recurcive method,
    therefor need invoke only with root vert }
  procedure GetSuffix(vert: PVertex);
  procedure FindAllSuffixes;
public
  destructor Destroy; override;
  procedure Clear;
  procedure BeginUpdate;
  procedure EndUpdate;
  { adds a new value (state) to the automaton; note, for a right work need
    calculate all suffexes, therefor need invoke BeginUpdate befor adding,
    and EndUpdate after you have already added all words; by all means,
    WordExists available for using at any time }
  function Add(AWord: pByte; LenWord: int32; const Data: T): boolean; overload;
  function Add(const AWord: WideString; const Data: T): boolean; overload;
  function Add(const AWord: AnsiString; const Data: T): boolean; overload;
  { it finds all final vertexes and results returns through OnFoundProc }
  procedure Find(Buffer: pByte; LenBuffer: int32); overload;
  procedure Find(const Buffer: WideString); overload;
  procedure Find(const Buffer: AnsiString); overload;
  { finds only the first Vector }
  function Find(Buffer: pByte; LenBuffer: int32; out Data: T): boolean; overload;
  { check if exists a value AWord in the automaton }
  function WordExists(AWord: pByte; LenWord: int32): boolean; overload;
  function WordExists(AWord: pByte; LenWord: int32; out Data: T): boolean; overload;
  function WordExists(const AWord: WideString): boolean; overload;
  function WordExists(const AWord: WideString; out Data: T): boolean; overload;
  function WordExists(const AWord: AnsiString): boolean; overload;
  function WordExists(const AWord: AnsiString; out Data: T): boolean; overload;
  { count of nodes }
  property CountVertexes: int32 read FCountVertexes;
  { method return of result when find all words in Buffer by Find(...) }
  property OnFoundProc: TOnFoundProc read FOnFoundProc write FOnFoundProc;
  property RootVertex: PVertex read FRootVertex;
  { count of keys }
  property Count: int32 read FCount;
  property DefaultValue: T read FDefault write FDefault;
end;

TValueEncoder = class
public
  class procedure Write(ToStream: TStream; Value: uint32); overload;
end;

TValueDecoder = class
public
  class function Read(FromStream: TStream): uint32; overload;
end;

{ THashTable<K, V> }

THashTable<K, V> = class
public
  type
    TBucket = record
      Key: K;
      Value: V;
      Hash: int32;
    end;
    TBuckets = array of TBucket;
private
  FHashFunction: THashFunction<K>;
  FKeyComparator: TKeyComparatorEqual<K>;
  FItems: TBuckets;
  IteratedBucket: int32;
  EmptyItem: TBucket;
  FThresholdRehash: int32;
  FMaskCapacity: uint32;
  FMaskBytes: byte;
  FCount: int32;
  FDefaultValue: V;
  procedure GrowAndRehash(ANewCapacity: int32);
  procedure Grow(var AItems: TBuckets; ANewCapacity: int32);
  function GetValue(const Key: K): V;
  procedure SetValue(const Key: K; const Value: V);
  function GetBucketIndex(Hash: int32): int32; inline;
  function DoFind(var BucketIndex: int32; const Key: K): boolean; inline;
  procedure DoSetValue(const Key: K; const Value: V); overload; inline;
  procedure DoSetValue(Index, Hash: int32; const Key: K; const Value: V); overload; inline;
public
  constructor Create(AHashFunction: THashFunction<K>; AKeyComparator: TKeyComparatorEqual<K>; ACapacity: int32 = 32);
  destructor Destroy; override;
  procedure Clear(FreeMemory: boolean = false);
  procedure Delete(const Key: K);
  function Exists(const Key: K): boolean;
  function Find(const Key: K; out Value: V): boolean; overload;
  function TryAdd(const Key: K; const Value: V): boolean; inline;
  procedure TryAddOrReplace(const Key: K; const Value: V); inline;
  procedure UpdateValue(const Key: K; const Value: V);
  function GetFirst(out Bucket: TBucket): boolean;
  function GetNext(out Bucket: TBucket): boolean;
  property Items[const Key: K]: V read GetValue write SetValue;
  property Count: int32 read FCount;
end;

function GetHashSedgwick(Data: pByte; Len: int32; Capacity: uint32): uint32; overload; inline;
function GetHashSedgwick(Data: pByte; Len: int32): uint32; overload; inline;
function GetHashSedgwickS(const Key: string): uint32; inline;
function GetHashSedgwickSA(const Key: AnsiString): uint32; inline;
function GetHashBlackSharkS(const Key: string): uint32; inline;
function GetHashBlackSharkSA(const Key: AnsiString): uint32; inline;
function GetHashBlackSharkInt64(const Key: int64): uint32; inline;
function GetHashBlackSharkUInt32(const Key: uint32): uint32; inline;
function GetHashBlackSharkInt32(const Key: int32): uint32; inline;
function GetHashBlackSharkPointer(const Key: Pointer): uint32; inline;
function GetHashBlackShark(Key: PByte; Len: int32): uint32; inline;
{ Default comparators }
function Int32cmp(const Key1, Key2: int32): int8; inline;
function Singlecmp(const Key1, Key2: Single): int8; inline;
function SinglecmpInv(const Key1, Key2: Single): int8; inline;
function UInt32cmp(const Key1, Key2: uint32): int8; inline;
function Int64cmp(const Key1, Key2: int64): int8; inline;
function Int64cmpEqual(const Key1, Key2: int64): boolean; inline;
function PtrCmp(const Key1, Key2: Pointer): int8; inline;
function StrCmp(const Key1, Key2: string): int8; inline;
function StrCmpBool(const Value1, Value2: string): boolean; inline;
function StrCmpABool(const Value1, Value2: AnsiString): boolean; inline;
function PtrCmpBool(const Value1, Value2: Pointer): boolean; inline;
function UInt32CmpBool(const Value1, Value2: uint32): boolean; inline;
function Int32CmpBool(const Value1, Value2: int32): boolean; inline;
function StrCmpA(const Key1, Key2: AnsiString): int8; inline;

{ Comparator two memory blocks }
function CompareBinKeys(
  Key: pByte; LenKey: uint8;// input data
  Key2: pByte; LenKey2:     // data binary tree
  uint8): int8; inline;

implementation

uses
  Math
  ;

function Int64cmp(const Key1, Key2: int64): int8;
begin
  if Key1 > Key2 then
    Result := -1
  else
  if Key1 < Key2 then
    Result := 1
  else
    Result := 0;
end;

function Int64cmpEqual(const Key1, Key2: int64): boolean;
begin
  Result := Key1 = Key2;
end;

function Int32cmp(const Key1, Key2: int32): int8;
begin
  if Key1 > Key2 then
    Result := -1
  else
  if Key1 < Key2 then
    Result := 1
  else
    Result := 0;
end;

function Singlecmp(const Key1, Key2: Single): int8;
begin
  if Key1 > Key2 then
    Result := -1
  else
  if Key1 < Key2 then
    Result :=  1
  else
    Result :=  0;
end;

function SinglecmpInv(const Key1, Key2: Single): int8;
begin
  if Key1 > Key2 then
    Result :=  1 else
  if Key1 < Key2 then
    Result := -1 else
    Result :=  0;
end;

function UInt32cmp(const Key1, Key2: uint32): int8;
begin
  if Key1 > Key2 then
    Result := -1 else
  if Key1 < Key2 then
    Result :=  1 else
    Result :=  0;
end;

function CompareBinKeys(
  Key: pByte; LenKey: uint8;
  Key2: pByte; LenKey2:
  uint8): int8;
var
	i: int32;
begin
	if LenKey = LenKey2 then
  	begin
      for i := 0 to LenKey - 1 do
        if Key[i] > Key2[i] then
          exit(-1) else
        if Key[i] < Key2[i] then
          exit(1);
      exit(0); // equal
    end else
	if LenKey > LenKey2 then
  	begin
      for i := 0 to LenKey2 - 1 do
        if Key[i] > Key2[i] then
          exit(-1) else
        if Key[i] < Key2[i] then
          exit(1);

      exit(1); //Key2 found in Key

    end else { if LenSign > a.LenSign then }
    begin
      for i := 0 to LenKey - 1 do
        if Key[i] > Key2[i] then
          exit(-1) else
        if Key[i] < Key2[i] then
          exit(1);

      exit(-1); //Key found in Key2
    end;
end;

function StrCmp(const Key1, Key2: string): int8;
var
  l1, l2: int32;
begin
  {$ifdef FPC}
  l1 := length(Key1);
  l2 := length(Key2);
  {$else}
  l1 := length(Key1) shl 1;
  l2 := length(Key2) shl 1;
  {$endif}
  Result := CompareBinKeys(@Key1[1], l1, @Key2[1], l2);
end;

function StrCmpBool(const Value1, Value2: string): boolean;
begin
  Result := Value1 = Value2;
end;

function StrCmpABool(const Value1, Value2: AnsiString): boolean;
begin
  Result := Value1 = Value2;
end;

function PtrCmpBool(const Value1, Value2: Pointer): boolean;
begin
  Result := Value1 = Value2;
end;

function UInt32CmpBool(const Value1, Value2: uint32): boolean; inline;
begin
  Result := Value1 = Value2;
end;

function Int32CmpBool(const Value1, Value2: int32): boolean; inline;
begin
  Result := Value1 = Value2;
end;

function StrCmpA(const Key1, Key2: AnsiString): int8;
begin
  Result := CompareBinKeys(@Key1[1], length(Key1), @Key2[1], length(Key2));
end;

function PtrCmp(const Key1, Key2: Pointer): int8;
var
  res: NativeInt;
begin
  {$ifdef FPC}
  res := NativeInt(Key2 - Key1);
  {$else}
  res := NativeInt(Key2) - NativeInt(Key1);
  {$endif}
  if res > 0 then
    Result := 1
  else
  if res < 0 then
    Result := -1
  else
    Result := 0;
end;

//=================================================================

{ TListVec }

procedure TListVec<T>.SetCapacity(AValue: int32);
var
  i: int32;
  new_cap: int32;
begin
  if (AValue > FCapacity) then
  begin
    new_cap := FCapacity shr 1 + (AValue shr 3) shl 3 + 8;
    SetLength(FData, new_cap);
    for i := FCapacity to new_cap - 1 do
      FData[i] := fDefault;
    FCapacity := new_cap;
  end;
end;

procedure TListVec<T>.SetCount(AValue: int32);
var
  i: int32;
begin
  if FCount = AValue then
    exit;
  if (AValue > FCount) then
  begin
    if (AValue > FCapacity) then
      SetCapacity(AValue)
    else
      for i := FCount to AValue - 1 do
        FData[i] := fDefault;
  end;
  FCount := AValue;
  if (FCount < 0) then
    FCount := 0;
end;

procedure TListVec<T>.SetDefault(const Value: T);
var
  i: int32;
begin
  fDefault := Value;
  { reserved space fill default value }
  for i := FCount to FCapacity - 1 do
    FData[i] := fDefault;
end;

function TListVec<T>.GetItem(index: int32): T;
begin
  if (FCount > index) and (index >= 0) then
    Result := FData[index]
  else
    //raise Exception.Create('Index out of bounds!');
    Result := fDefault;
end;

function TListVec<T>.GetShiftData(index: int32): Pointer;
begin
  if (FCount > 0) and (index < FCount) then
    Result := @FData[index]
  else
    raise Exception.Create('Index out of bounds!');
    //Result := nil;
end;

procedure TListVec<T>.SetItem(index: int32; AValue: T);
var
  i: int32;
begin
  if index < 0 then
    exit;
  SetCapacity(index + 1);
  if index + 1 > FCount then
  begin
    for i := FCount to index do
      FData[i] := fDefault;
    FCount := index + 1;
  end;
  FData[index] := AValue;
end;

{
procedure TListVec.Insert(Item: T; Index: int32);
begin
  SetCapacity(FCount+1);
  if Index < FCount - 1 then
    begin
    move(FData[Index], FData[Index+1], (FCount - Index - 1)*SizeOf(T));
    end;
  FData[FCount] := Item;
  inc(FCount);
end;
}

constructor TListVec<T>.Create;
begin
  Create(nil);
end;

constructor TListVec<T>.Create(AComparator: TListComparatorItems);
begin
  FComparator := AComparator;
  FPtrOfData := @FData;
  //if Assigned(FComparator) then
  //  FSort := true;
end;

destructor TListVec<T>.Destroy;
begin
  SetLength(FData, 0);
  inherited Destroy;
end;

procedure TListVec<T>.Add(const Item: T);
//var
//  index: int32;
begin
  SetCapacity(FCount+1);
  {if FSort and (FCount > 0) then
    begin
    index := FCount - 1;
    while (index >= 0) and (FComparator(Item, FData[index]) < 0) do
      begin
      FData[index+1] := FData[index];
      dec(index);
      end;

    FData[index+1] := Item;
    end else
    begin    }
    FData[FCount] := Item;
    //end;
  inc(FCount);
end;

procedure TListVec<T>.Add(const Items: array of T);
var
  len: int32;
begin
  len := Length(Items);
  if (len = 0) then
    exit;
  Add(@Items[0], len);
end;

function TListVec<T>.Pop: T;
begin
  if (FCount = 0) then
    exit(fDefault);
  Result := FData[FCount-1];
  dec(FCount);
end;

procedure TListVec<T>.Delete(Index: int32);
begin
  if (FCount = 0) or (Index >= FCount) or (Index < 0) then
    exit;
  dec(FCount);
  if Index < FCount then
  begin
    //if FSort then
    //  System.Move(FData[Index+1], FData[Index], (FCount - Index)*SizeOf(T)) else
    if (FCount > 0) then
      FData[Index] := FData[FCount];
  end;
end;

procedure TListVec<T>.Delete(Index: int32; CountItem: int32);
var
  c: int32;
begin
  if (FCount = 0) or (Index >= FCount) or (Index < 0) then
    exit;
  if Index + CountItem > FCount then
    c := FCount - Index - 1
  else
    c := CountItem;
  if Index + c < FCount - 1 then
    move(FData[Index+c], FData[Index], c*SizeOf(T));
  dec(FCount, c);
end;

function TListVec<T>.Remove(const Item: T; OrderIteration: TOrderIterType = TOrderIterType.otFromBegin): boolean;
var
  i: int32;
begin
  if OrderIteration = otFromBegin then
  begin
    for i := 0 to FCount - 1 do
    begin
      //if (CompareMem(@Item, @FData[i], SizeOf(T))) then
      if FComparator(Item, FData[i]) = 0 then
      begin
        Delete(i);
        exit(true);
      end;
    end;
  end else
  begin
    for i := FCount - 1 downto 0 do
    begin
      //if (CompareMem(@Item, @FData[i], SizeOf(T))) then
      if FComparator(Item, FData[i]) = 0 then
      begin
        Delete(i);
        exit(true);
      end;
    end;
  end;
  Result := false;
end;

function TListVec<T>.IndexOf(const Item: T; OrderIteration: TOrderIterType = TOrderIterType.otFromBegin): int32;
begin
  if OrderIteration = otFromBegin then
  begin
    for Result := 0 to FCount - 1 do
      if FComparator(Item, FData[Result]) = 0 then
      //if (CompareMem(@Item, @FData[Result], SizeOf(T))) then
        exit;
  end else
  begin
    for Result := FCount - 1 downto 0 do
      if FComparator(Item, FData[Result]) = 0 then
      //if (CompareMem(@Item, @FData[Result], SizeOf(T))) then
        exit;
  end;
  Result := -1;
end;

procedure TListVec<T>.Insert(const Item: T; Position: int32);
begin
  if Position >= Count then
  begin
    Count := Position + 1;
  end else
  begin
    Count := FCount + 1;
    move(FData[Position], FData[Position+1], (Count - Position - 1)*SizeOf(T));
  end;
  FData[Position] := Item;
end;

procedure TListVec<T>.Add(Items: TPointerOfT; CountItems: int32);
begin
  if CountItems = 0 then
    exit;
  SetCapacity(FCount+CountItems);
  move(items^, FData[FCount], CountItems*SizeOf(T));
  inc(FCount, CountItems);
  //if FSort then
  //  SortList(0, FCount - 1);
end;

procedure TListVec<T>.AddList(List: TListVec<T>);
begin
  if List.Count = 0 then
    exit;
  SetCapacity(List.Count + FCount);
  move(List.FData[0], FData[FCount], List.Count*SizeOf(T));
  inc(FCount, List.Count);
  //if FSort then
  //  SortList(0, FCount - 1);
end;

procedure TListVec<T>.SetList(List: TListVec<T>);
begin
  if List.Count = 0 then
    exit;
  SetCapacity(List.Count);
  move(List.FData[0], FData[0], List.Count*SizeOf(T));
  FCount := List.Count;
  //if FSort then
  //  SortList(0, FCount - 1);
end;

{procedure TListVec<T>.SetSort(const Value: boolean);
begin
  FSort := Value;
  if FSort and (FCount > 1) then
    SortList(0, FCount - 1);
end;  }

procedure TListVec<T>.Fill(const Value: T);
var
  i: int32;
begin
  for i := 0 to FCapacity - 1 do
    FData[i] := Value;
end;

procedure TListVec<T>.Clear;
begin
  FCount := 0;
  FCapacity := 0;
  SetLength(FData, 0);
end;

function TListVec<T>.Copy: TArrayOfT;
begin
  if FCount > 0 then
  begin
    SetLength(Result{%H-}, FCount);
    move(FData[0], Result[0], FCount*SizeOf(T));
  end else
  begin
    Result := nil;
  end;
end;

procedure TListVec<T>.Sort;
begin
  if FCount > 1 then
    SortList(0, FCount - 1);
end;


procedure TListVec<T>.Exchange(Index1, Index2: int32);
var
  v: T;
begin
  if (Index1 > FCount - 1) or (Index2 > FCount - 1) or (Index1 = Index2) then
    exit;
  v := FData[Index1];
  FData[Index1] := FData[Index2];
  FData[Index2] := v;
end;

procedure TListVec<T>.Fill(const Value: T; Start, Count: int32);
var
  i: int32;
begin
  for i := Start to Start + Count - 1 do
    FData[i] := Value;
end;

procedure TListVec<T>.SortList(L, R : Longint);
var
  i, j : Longint;
  p, q : T;
begin
  repeat

    i := L;
    j := R;
    p := FData[ (L + R) div 2 ];

    repeat
      while FComparator(p, FData[i]) > 0 do
        inc(i);
      while FComparator(p, FData[j]) < 0 do
        dec(j);
      if i <= j then
      begin
        q := FData[i];
        FData[i] := FData[j];
        FData[j] := q;
        inc(i);
        dec(j);
      end;
    until i > j;

    if j - L < R - i then
    begin
      if L < j then
        SortList(L, j);
      L := i;
    end else
    begin
      if i < R then
        SortList(i, R);
      R := j;
    end;

  until L >= R;
end;

//
// Robert Sedgwick's "Algorithms in C" hash function
//
function GetHashSedgwick(Data: pByte; Len: int32; Capacity: uint32): uint32;
Begin
  Result := GetHashSedgwick(Data, Len);
  while (Result >= Capacity) do
    Result := Result shr 1;
end;

function GetHashSedgwick(Data: pByte; Len: int32): uint32;
var
  a: uint32;
  i: int32;
Begin
  if Len < 2 then
    Result := Data^
  else
    Result := 0;
  a := 63689;
  for i := 0 to Len shr 1 - 1 do
  begin
    Result := (uint64(Result * a) + PWordArray(Data)[i]) and $FFFFFFFF;
    a := uint64(a * 378551) and $FFFFFFFF;
  end;
end;

function GetHashSedgwickS(const Key: string): uint32;
var
  l: int32;
begin
  {$ifdef FPC}
  l := length(Key);
  {$else}
  l := length(Key)*2;
  {$endif}
  if l = 0 then
    exit(0);
  Result := GetHashSedgwick(@Key[1], l);
end;

function GetHashSedgwickSA(const Key: AnsiString): uint32;
var
  l: int32;
begin
  l := length(Key);
  if l = 0 then
    exit(0);
  Result := GetHashSedgwick(@Key[1], l);
end;

function GetHashBlackShark(Key: PByte; Len: int32): uint32;
var
  i: int32;
begin
  Result := $55555555;
  for i := 0 to Len - 1 do
    Result := ((Result + Key[i]) shl 8) + (Result shr 24 xor Key[i]);
end;

function GetHashBlackSharkInt64(const Key: int64): uint32;
begin
  Result := GetHashBlackShark(@Key, sizeof(Key));
end;

function GetHashBlackSharkUInt32(const Key: uint32): uint32; inline;
begin
  Result := GetHashBlackShark(@Key, sizeof(Key));
end;

function GetHashBlackSharkInt32(const Key: int32): uint32; inline;
begin
  Result := GetHashBlackShark(@Key, sizeof(Key));
end;

function GetHashBlackSharkPointer(const Key: Pointer): uint32;
begin
  Result := GetHashBlackShark(@Key, sizeof(Key));
end;

function GetHashBlackSharkS(const Key: string): uint32;
begin
  Result := GetHashBlackShark(@Key[1], length(Key)*SizeOf(Char));
end;

function GetHashBlackSharkSA(const Key: AnsiString): uint32;
begin
  Result := GetHashBlackShark(@Key[1], length(Key));
end;

{ TQueueFIFO<T> }

procedure TQueueFIFO<T>.Clear;
var
  tmp: PQueueItem;
begin
  while (QRead <> nil) and (FCapacity > 0) do
  begin
    tmp := QRead.Next;
    dispose(QRead);
    QRead := tmp;
    dec(FCapacity);
  end;
  QRead := nil;
  QWrite := nil;
end;

constructor TQueueFIFO<T>.Create(ASourceThread: Pointer; ACapacity: int32;
  ASync: boolean);
begin
  FSourceThread := ASourceThread;
  FFixedCapacity := false;
  FSync := ASync;
  FillChar(fDefault, SizeOf(T), 0);
  Capacity := ACapacity;
end;

destructor TQueueFIFO<T>.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TQueueFIFO<T>.Push(const Item: T): boolean;
begin
  if (QWrite^.Next = QRead) then
  begin
    if not FFixedCapacity then
      Capacity := FCapacity * 2 else
      exit(false);
    //raise Exception.Create('Not enough capacity queue!');
  end;
  QWrite.Item := Item;
  QWrite := QWrite.Next;
  inc(FCountWrite);
  Result := true;
  if Assigned(FOnWrite) then
    FOnWrite(Self);
  if FSync then
  begin
    while FCountWrite <> FCountRead do
      sleep(1);
  end;
end;

procedure TQueueFIFO<T>.SetCapacity(const Value: int32);
var
  i, a: int32;
  tmp, l, next: PQueueItem;
begin
  if FCapacity = Value then
    exit;
  if (Value > 0) and (Value < 3) then
    raise Exception.Create('A value the capacity cannot be smaler 3!');
  if Value > FCapacity then
  begin
    if FCapacity = 0 then
    begin
      new(QRead);
      {  }
      //FillChar(QRead^, SizeOf(TQueueItem), 0);
      QWrite := QRead;
      QRead^.Next := QWrite;
      a := 1;
    end else
      a := 0;
    l := QWrite;
    next := QWrite^.Next;
    for i := FCapacity + a to Value - 1 do
    begin
      new(tmp);
      //FillChar(tmp^, SizeOf(TQueueItem), 0);
      l.Next := tmp;
      l := tmp;
    end;
    l.Next := next;
  end else
  begin
    if Value = 0 then
      Clear else
    begin
      while FCapacity > Value do
      begin
        tmp := QWrite.Next.Next;
        if QWrite.Next = QRead then
          QRead := tmp;
        dispose(QWrite.Next);
        QWrite.Next := tmp;
        dec(FCapacity);
      end;
    end;
  end;
  FCapacity := Value;
end;

function TQueueFIFO<T>.GetCount: int32;
begin
  Result := FCountWrite - FCountRead;
end;

function TQueueFIFO<T>.Pop(out Item: T): boolean;
begin
  if (FCountRead <> FCountWrite) and (QWrite <> QRead) then
  begin
    Item := QRead.Item;
    { for managed types }
    QRead.Item := fDefault;
    QRead := QRead.Next;
    Result := true;
    inc(FCountRead);
  end else
  begin
    Item := fDefault;
    exit(false);
  end;
end;

function TQueueFIFO<T>.Pop: T;
begin
  Pop(Result);
end;

{ TSingleList<T> }

class procedure TSingleList<T>.Copy(var Head: TSingleListHead; const Source: TSingleListHead);
begin
  if Source.Count > 0 then
  begin
    CheckCapacity(Head, Head.Count + Source.Count);
    move(Source.Items[0], Head.Items[Head.Count], Source.Count * SizeOf(T));
    Head.Count := Head.Count + Source.Count;
  end;
end;

class procedure TSingleList<T>.CheckCapacity(var Head: TSingleListHead;
  NewCap: int32);
begin
  if NewCap > Length(Head.Items) then
    SetLength(Head.Items, NewCap);
end;

class function TSingleList<T>.Delete(var Head: TSingleListHead; const Item: T): boolean;
var
  i: int32;
begin
  for i := 0 to Head.Count - 1 do
  begin
    if CompareMem(@Head.Items[i], @Item, SizeOf(T)) then
    begin
      dec(Head.Count);
      System.Move(Head.Items[i+1], Head.Items[i], (Head.Count - i)*SizeOf(T));
      //SetLength(Head.Items, length(Head.Items) - 1);
      exit(true);
    end;
  end;
  Result := false;
end;

class procedure TSingleList<T>.CheckCapacity(var Head: TSingleListHead);
begin
  if Head.Count = Length(Head.Items) then
  begin
    if (Length(Head.Items) > 0) then
      SetLength(Head.Items, Length(Head.Items) shl 1)
    else
      SetLength(Head.Items, 4);
  end;
end;

class procedure TSingleList<T>.Create(var Head: TSingleListHead; Capacity: int32 = 4);
begin
  Head.Count := 0;
  if Capacity > 0 then
    SetLength(Head.Items, Capacity);
end;

class procedure TSingleList<T>.SetCapacity(var Head: TSingleListHead; Capacity: int32);
begin
  SetLength(Head.Items, Capacity);
end;

class procedure TSingleList<T>.Add(var Head: TSingleListHead; const Item: T);
begin
  CheckCapacity(Head);
  Head.Items[Head.Count] := Item;
  inc(Head.Count);
end;

class procedure TSingleList<T>.Free(var Head: TSingleListHead);
begin
  SetLength(Head.Items, 0);
end;

{ TVirtualTree }

constructor TVirtualTree<T>.Create;
begin
  FRootNodes := TListVirtualNodes.Create;
  { default signature - Black Shark Virtual Tree }
  FSignature := 'BSVT';
  FVersion := 1;
end;

function TVirtualTree<T>.CreateNode(Parent: PVirtualTreeNode): PVirtualTreeNode;
begin
  new(Result);
  Result.Childs := nil;
  Result.Parent := nil;
  Result.Data := FDefaultValue;
  SetNodeParent(Result, Parent);
end;

destructor TVirtualTree<T>.Destroy;
begin
  Clear;
  FRootNodes.Free;
  inherited Destroy;
end;

function TVirtualTree<T>.CreateNode(Parent: PVirtualTreeNode; const Data: T): PVirtualTreeNode;
begin
  Result := CreateNode(Parent);
  Result.Data := Data;
end;

procedure TVirtualTree<T>.DeleteNode(Node: PVirtualTreeNode; DeleteChilds: boolean = true; Silent: boolean = false);
var
  it: TListVirtualNodes.PListItem;
  n: PVirtualTreeNode;
begin

  if DeleteChilds then
  begin
    while (Node^.Childs <> nil) and (Node^.Childs.Count > 0) do
      DeleteNode(Node^.Childs.ItemListFirst^.Item, true);
  end else
  if Node^.Childs <> nil then
  begin
    it := Node^.Childs.ItemListFirst;
    while it <> nil do
    begin
      n := it^.Item;
      it := it.Next;
      SetNodeParent(n, Node^.Parent);
    end;
    //Node^.Childs.Free;
  end;

  if not Silent and Assigned(FOnDeleteNode) then
    FOnDeleteNode(Node);

  if (Node^.Parent <> nil) then
  begin
    Node^.Parent^.Childs.Remove(Node^._ItemList);
    if Node^.Parent^.Childs.Count = 0 then
      FreeAndNil(Node^.Parent^.Childs);
  end else
    FRootNodes.Remove(Node^._ItemList);

  Dispose(Node);
end;

procedure TVirtualTree<T>.SetNodeParent(Node, Parent: PVirtualTreeNode);
begin
  if Node = Parent then
    exit;

  if Assigned(Node^.Parent) then
  begin
    Node^.Parent^.Childs.Remove(Node^._ItemList);
    if Node^.Parent^.Childs.Count = 0 then
       FreeAndNil(Node^.Parent^.Childs);
  end;

  Node^.Parent := Parent;
  if Assigned(Parent) then
  begin
    //Node^.Level := Parent^.Level + 1;
    if not Assigned(Parent^.Childs) then
      Parent^.Childs := TListVirtualNodes.Create;
    Node^._ItemList := Parent^.Childs.PushToEnd(Node);
  end else
  begin
    //Node^.Level := 0;
    Node^._ItemList := FRootNodes.PushToEnd(Node);
  end;
end;

procedure TVirtualTree<T>.ClearNodeChilds(Node: PVirtualTreeNode);
begin
  while (Node^.Childs <> nil) and (Node^.Childs.Count > 0) do
    DeleteNode(Node^.Childs.ItemListFirst^.Item, true);
end;

procedure TVirtualTree<T>.Clear;
var
  n: PVirtualTreeNode;
begin
  while FRootNodes.ItemListFirst <> nil do
    begin
    n := FRootNodes.ItemListFirst^.Item;
    DeleteNode(n, true);
    end;
end;

function TVirtualTree<T>.SaveTo(const FileName: string): boolean;
var
  f: TFileStream;
begin
  Result := true;
  try
    f := TFileStream.Create(FileName, fmCreate);
    try
      Result := SaveTo(f);
    finally
      f.Free;
    end;
  except
    Result := false;
  end;
end;

procedure TVirtualTree<T>.SaveNode(Node: PVirtualTreeNode; Stream: TStream);
var
  r: TNodeRec;
  it: TListVirtualNodes.PListItem;
  pos: int64;
  //size_node: int32;
begin
  pos := Stream.Position;
  Stream.Size := pos + SizeOf(TNodeRec);
  Stream.Position := pos + SizeOf(TNodeRec);
  if Assigned(FOnSaveNode) then
    begin
    FOnSaveNode(Node, Stream);
    r.UserDataSize := Stream.Size - pos - SizeOf(TNodeRec);
    end else
    r.UserDataSize := 0;

  if Node.Childs <> nil then
    begin
    it := Node.Childs.ItemListFirst;
    while it <> nil do
      begin
      SaveNode(it^.Item, Stream);
      it := it.Next;
      end;
    r.Childs := Node.Childs.Count;
    end else
    r.Childs := 0;

  r.Size := uint32(Stream.Position) - uint32(pos) - SizeOf(TNodeRec);
  Stream.Position := pos;
  Stream.Write(r, sizeOf(TNodeRec));
  Stream.Position := Stream.Size;
end;

function TVirtualTree<T>.SaveTo(Stream: TStream): boolean;
var
  it: TListVirtualNodes.PListItem;
  l: int8;
begin
  l := length(FSignature);
  Stream.Write(l, 1);
  if l > 0 then
    Stream.Write(FSignature[1], l);
  { write version }
  Stream.Write(FVersion, SizeOf(FVersion));
  { count root nodes }
  Stream.Write(FRootNodes.Count, SizeOf(FRootNodes.Count));
  it := FRootNodes.ItemListFirst;
  while it <> nil do
    begin
    SaveNode(it^.Item, Stream);
    it := it.Next;
    end;
  FData := Stream;
  Result := true;
end;

function TVirtualTree<T>.LoadFrom(const FileName: string): boolean;
var
  f: TFileStream;
begin
  //Result := true;
  try
    f := TFileStream.Create(FileName, fmOpenRead);
    try
      Result := LoadFrom(f);
    finally
      f.Free;
    end;
  except
    Result := false;
  end;
end;

function TVirtualTree<T>.LoadNode(Parent: PVirtualTreeNode; Stream: TStream): PVirtualTreeNode;
var
  r: TNodeRec;
  pos: int64;
begin
  Result := CreateNode(Parent);
  pos := Stream.Position;
  Stream.Read(r{%H-}, SizeOf(TNodeRec));
  if Assigned(FOnLoadNode) then
    FOnLoadNode(Result, Stream, r.UserDataSize);
  Stream.Position := pos + r.UserDataSize + SizeOf(TNodeRec);
  while r.Childs > 0 do
    begin
    dec(r.Childs);
    LoadNode(Result, Stream);
    end;
  Stream.Position := pos + r.Size + SizeOf(TNodeRec);
end;

function TVirtualTree<T>.LoadFrom(Stream: TStream): boolean;
var
  l: int8;
  cr: int32;
  sig: AnsiString;
begin
  if Stream.Position = Stream.Size then
    raise Exception.Create('Data position is the end of file!');
  Stream.Read(l{%H-}, 1);
  if l > 0 then
  begin
    sig := '';
    SetLength(sig, l);
    Stream.Read(sig[1], l);
    if sig <> FSignature then
      raise Exception.Create('Uncknown file type!');
  end;
  { read Version }
  Stream.Read(FVersion, SizeOf(FVersion));
  { read count root nodes }
  Stream.Read(cr{%H-}, SizeOf(cr));
  while cr > 0 do
  begin
    LoadNode(nil, Stream);
    dec(cr);
  end;
  FData := Stream;
  Result := true;
end;

//=================================================================
{ TBinTreeIterator }

constructor TBinTreeTemplate<K, V>.TBinTreeIterator.Create(ATree: TBinTreeTemplate<K, V>);
begin
  FTree := ATree;
end;

procedure TBinTreeTemplate<K, V>.TBinTreeIterator.MoveDown(
  var StartNode: PBinTreeItem);
begin
  if StartNode^.right <> nil then
    begin
    while StartNode^.right <> nil do
      begin
      if StartNode.left <> nil then
        begin
        StartNode^.left^.in_right_iter := false;
        StartNode^.left^.parent_iter := StartNode;
        end;
      StartNode^.right^.in_right_iter := false;
      StartNode^.right^.parent_iter := StartNode;
      StartNode := StartNode^.right;
      end;
    end;
  if StartNode.left <> nil then
    begin
    StartNode^.left^.in_right_iter := false;
    StartNode^.left^.parent_iter := StartNode;
    end;
end;

function TBinTreeTemplate<K, V>.TBinTreeIterator.SetToBegin: boolean;
begin
  CurrentNode := FTree.FRoot;
  if (CurrentNode <> nil) then
    begin
    Result := true;
    IterateNow := true;
    CurrentNode.in_right_iter := false;
    CurrentNode.parent_iter := nil;
    MoveDown(CurrentNode);
    end else
    begin
    Result := false;
    end;
end;

function TBinTreeTemplate<K, V>.TBinTreeIterator.SetToBegin(out Value: V): boolean;
begin
  Result := SetToBegin;
  if Result then
    Value := CurrentNode^.Value else
    Value := FTree.FDefaultValue;
end;

function TBinTreeTemplate<K, V>.TBinTreeIterator.Next: boolean;
begin
  if (CurrentNode = nil) then
    exit(false);
  CurrentNode^.in_right_iter := true;
  while (CurrentNode <> nil) do
  begin
    if CurrentNode^.in_right_iter then
    begin
      if (CurrentNode^.left <> nil) and (not CurrentNode^.left^.in_right_iter) then
      begin
        CurrentNode^.left^.parent_iter := CurrentNode;
        CurrentNode := CurrentNode^.left;
        MoveDown(CurrentNode);
        break;
      end;
      CurrentNode := CurrentNode^.parent_iter;
    end else
      break;
  end;
  if CurrentNode <> nil then
  begin
    Result := true;
  end else
  begin
    IterateNow := false;
    Result := false;
  end;
end;

function TBinTreeTemplate<K, V>.TBinTreeIterator.Next(out Value: V): boolean;
begin
  Result := Next;
  if Result then
    Value := CurrentNode^.Value
  else
    Value := FTree.FDefaultValue;
end;

//=================================================================

{ TBinTreeTemplate<K, V> }

constructor TBinTreeTemplate<K, V>.Create;
begin
  Create(nil);
end;

constructor TBinTreeTemplate<K, V>.Create(AKeyComparator: TKeyComparator<K>);
begin
  inherited create;
  StackNodes := TList.Create;
  FTagInt := 0;
  FreeNodes := TList.Create;
  FIterator := TBinTreeIterator.Create(Self);
  FillChar(FRoot, SizeOf(FRoot), 0);
  FItemCount := 0;
  FDepth := 0;
  FMinLen := high(int32);
  //FillChar(FDefaultValue, SizeOf(V), 0);
  FKeyComparator := AKeyComparator;
end;

function TBinTreeTemplate<K, V>.CreateNode(const Key: K; const Value: V): PBinTreeItem;
begin
  if (FreeNodes.Count > 0) then
    begin
    Result := FreeNodes.Items[FreeNodes.Count - 1];
    FreeNodes.Delete(FreeNodes.Count - 1);
    Result^.parent_iter := nil;
    Result^.bal := 0;
    Result^.left := nil;
    Result^.right := nil;
    Result^.Value := FDefaultValue;
    Result^.in_right_iter := false;
    end else
    begin
	  new(Result);
    FillChar(Result^, SizeOF(TBinTreeItem), #0);
    end;
  Result^.Key := Key;
  Result^.Value := Value;
  inc(FItemCount);
end;


destructor TBinTreeTemplate<K, V>.Destroy;
begin
	Clear(true);
  FIterator.Free;
  StackNodes.Free;
  FreeNodes.Free;
  inherited;
end;

procedure TBinTreeTemplate<K, V>.DoDeleteNode(Node: PBinTreeItem);
begin
  FreeNodes.Add(node);

end;

function TBinTreeTemplate<K, V>.DoFind(StartNode: PBinTreeItem; const Key: K): PBinTreeItem;
var
	res: int8;
begin
  Result := StartNode;
  while Assigned(Result) do
  begin
    res := FKeyComparator(Key, Result^.Key);
    case res of
      0: exit;
      1: Result := Result^.left;
      -1: Result := Result^.right;
    end;
  end;
end;

function TBinTreeTemplate<K, V>.Exists(const Key: K): boolean;
begin
	Result := DoFind(FRoot, Key) <> nil;
end;

function TBinTreeTemplate<K, V>.SearchAndInsertKey(const Key: K; const Value: V;
  var p: PBinTreeItem; var Added: boolean; var H: boolean): PBinTreeItem;
var
	res: int8;
begin
  if p = nil then
  begin        // word not in tree, insert it
   	p := CreateNode(Key, Value);
   	Added := true;
    H := true;
    exit(p);
  end;

  res := FKeyComparator(Key, p^.Key);
  if (res > 0) then
  begin
   	Result := SearchAndInsertKey(Key, Value, p^.left, Added, H);
   	if Added and H then
      BalanceLeft(p, H);
  end else
  if (res < 0) then
  begin
    Result := SearchAndInsertKey(Key, Value, p^.right, Added, H);
   	if Added and H then
      BalanceRight(p, H);
  end else
    raise Exception.Create('TBinTreeTemplate<K, V>.SearchAndInsertKey: the key already exists!');
end;

function TBinTreeTemplate<K, V>.Find(const Key: K; out Value: V): boolean;
var
	node: TBinTreeTemplate<K, V>.PBinTreeItem;
begin
	node := DoFind(FRoot, Key);
  if Assigned(node) then
  begin
    Value := node^.Value;
    Result := true;
  end else
  begin
    Value := FDefaultValue;
    Result := false;
  end;
end;

function TBinTreeTemplate<K, V>.FindNode(const Key: K): PBinTreeItem;
begin
  Result := DoFind(FRoot, Key);
end;

function TBinTreeTemplate<K, V>.FindPath(const Key: K): TList;
var
	res: int8;
  n: PBinTreeItem;
begin
  n := FRoot;
  Result := StackNodes;
  StackNodes.Count := 0;
  while Assigned(n) do
  begin
    StackNodes.Add(n);
    res := FKeyComparator(Key, n^.Key);
    case res of
      0: exit;
      1: n := n^.left;
      -1: n := n^.right;
    end;
  end;
end;

procedure TBinTreeTemplate<K, V>.BalanceRight(var p: PBinTreeItem; var h: boolean);
var
	p1, p2: PBinTreeItem;
begin
  case p^.bal of
  -1:begin
     p^.bal := 0;
     h := false;
     end;
  0: begin
     p^.bal := +1;
     end;
  +1: begin    // new balancing
    p1 := p^.right;
    if (p1^.bal = 1) then
    begin  // single rr rotation
      p^.right := p1^.left;
      p1^.left := p;
      p^.bal := 0;
      p := p1;
    end else
    begin  // double rl rotation
      p2 := p1^.left;
      p1^.left := p2^.right;
      p2^.right := p1;
      p^.right := p2^.left;
      p2^.left := p;

      if p2^.bal > 0 then
        p^.bal := -1
      else
        p^.bal := 0;

      if p2^.bal < 0 then
        p1^.bal := +1
      else
        p1^.bal := 0;

      p := p2;
    end;
    h := false;
    p^.bal := 0;
  end; {+1: begin}
 	end;
end;

function TBinTreeTemplate<K, V>.Add(const Key: K; const Value: V): boolean;
var
	h: boolean;
begin
  h := false;
  Result := false;
	SearchAndInsertKey(Key, Value, FRoot, Result, h);
end;

function TBinTreeTemplate<K, V>.AddNode(const Key: K; const Value: V): TBinTreeTemplate<K, V>.PBinTreeItem;
var
	h, added: boolean;
begin
  h := false;
  added := false;
	Result := SearchAndInsertKey(Key, Value, FRoot, added, h);
end;

procedure TBinTreeTemplate<K, V>.AddOrReplaceValue(const Key: K;
  const Value: V);
var
  n: PBinTreeItem;
begin
  n := FindNode(Key);
  if n = nil then
    Add(Key, Value)
  else
    n.Value := Value;
end;

procedure TBinTreeTemplate<K, V>.BalanceLeft(var p: PBinTreeItem; var h: boolean); //; var h: boolean; dl: boolean
var
	p1, p2: PBinTreeItem;
begin
  case p^.bal of
  1: begin
   	p^.bal := 0;
    h := false;
    end;
  0: begin
  	p^.bal:= -1;
  end;
  -1: begin   // new balancing
    p1 := p^.left;
    if (p1^.bal = -1) then
    begin   // single ll rotation
      p^.left := p1^.right;
      p1^.right := p;
      p^.bal := 0;
      p := p1;
    end else
    begin //double lr rotation
     	p2 := p1^.right;
      p1^.Right := p2^.left;
      p2^.left := p1;
      p^.left := p2^.right;
      p2^.right := p;

      if p2^.bal < 0 then
        p^.bal := +1
      else
        p^.bal := 0;

      if p2^.bal > 0 then
        p1^.bal := -1
      else
        p1^.bal := 0;

      p := p2;
    end;
    h := false;
    p^.bal := 0;
  end; { -1 }
  end; { case }
end;

procedure TBinTreeTemplate<K, V>.Clear(FreeMemory: boolean = false);
var
  i: Integer;
  it: PBinTreeItem;
  ok: boolean;
begin
  FDepth := 0;
  FMinLen := high(int32);
  { clears tree without a balansing }
  ok := FIterator.SetToBegin;
  while ok do
  begin
    DoDeleteNode(FIterator.CurrentNode);
    ok := FIterator.Next;
  end;

  FRoot := nil;
  FItemCount := 0;
  if FreeMemory then
  begin
    for i := 0 to FreeNodes.Count - 1 do
    begin
      it := PBinTreeItem(FreeNodes.Items[i]);
      Dispose(it);
    end;
    FreeNodes.Count := 0;
  end;
end;

procedure TBinTreeTemplate<K, V>.BalLeftAfterDel(var p : PBinTreeItem; var h : boolean);
var
	p1, p2 : PBinTreeItem;
begin
  if p^.bal = -1 then
    p^.bal := 0
  else
  if p^.bal = 0 then
  begin
    p^.bal := 1;
    h := false;
  end else
  begin
    p1 := p^.right;
    if p1^.bal >= 0 then (* single RR rotation *)
    begin
      p^.right := p1^.left;
      p1^.left := p;
      if p1^.bal = 0 then
      begin
        p^.bal := 1;
        p1^.bal := -1;
        h := false;
      end else
      begin
        p^.bal := 0;
        p1^.bal := 0;
      end;
      p := p1;
    end else
    begin
      p2 := p1^.left;
      p1^.left := p2^.right;
      p2^.right := p1;
      p^.right := p2^.left;
      p2^.left := p;

      if p2^.bal > 0 then
        p^.bal := -1
      else
        p^.bal := 0;

      if p2^.bal < 0 then
        p1^.bal := +1
      else
        p1^.bal := 0;

      p := p2;
      p2^.bal := 0
    end
  end
end;

procedure TBinTreeTemplate<K, V>.BalRightAfterDel(var p : PBinTreeItem; var h : boolean);
var
	p1, p2 : PBinTreeItem;
begin
  if p^.bal = 1 then
    p^.bal := 0
  else
  if p^.bal = 0 then
  begin
    p^.bal := -1;
    h := false;
  end else
  begin
    p1 := p^.left;
    if p1^.bal <= 0 then (* single LL rotation *)
    begin
      p^.left := p1^.right;
      p1^.right := p;
      if p1^.bal = 0 then
      begin
        p^.bal := -1;
        p1^.bal := 1;
        h := false;
      end else
      begin
        p^.bal := 0;
        p1^.bal := 0
      end;
      p := p1;
    end else
    begin
      p2 := p1^.right;
      p1^.right := p2^.left;
      p2^.left := p1;
      p^.left := p2^.right;
      p2^.right := p;

      if p2^.bal < 0 then
        p^.bal := +1
      else
        p^.bal := 0;

      if p2^.bal > 0 then
        p1^.bal := -1
      else
        p1^.bal := 0;

      p := p2;
      p2^.bal := 0
    end
  end
end;

procedure TBinTreeTemplate<K, V>.ChBal(Node: PBinTreeItem; var Depth: int32; var Res: PBinTreeItem);
var
  Lb, Rb: int32;
begin
  if Assigned(Res) then
    exit;

  Lb := 0;
  Rb := 0;

  if Assigned(Node^.right) then
  begin
    inc(Rb);
    ChBal(Node^.right, Rb, Res);
  end;

  if Assigned(Node^.left) then
  begin
    inc(Lb);
    ChBal(Node^.left, Lb, Res);
  end;

  if (Rb - Lb) <> Node^.bal then
    Res := Node;

  if Lb > Rb then
    Depth := Depth + Lb
  else
    Depth := Depth + Rb;
end;

function TBinTreeTemplate<K, V>.DebugCheckBalance: PBinTreeItem;
var
	root_dep: int32;
begin
	Result := nil;
  root_dep := 0;
  if FRoot <> nil then
    ChBal(FRoot, root_dep, Result);
end;

function TBinTreeTemplate<K, V>.Delete(Key: PBinTreeItem; var p: PBinTreeItem; var h: boolean): boolean;
var
	q, tmp_it: PBinTreeItem;
  res: int8;
begin { main of delete }

 	if (p = nil) then
  begin
   	Result := false;
   	h := false;
    exit;
  end;
  res := FKeyComparator(Key.Key, p^.Key);
  if (res < 0){(x > p^.key)}then
  begin
    Result := delete(Key, p^.right, h);
    if h then
    	BalRightAfterDel(p, h);  //
  end else
  if (res > 0){(x < p^.key)} then
  begin
    Result := delete(Key, p^.left, h);
    if h then
    	BalLeftAfterDel(p, h); //
  end else
  begin // remove q
    Result := true;
    q := p;
    if (q^.right = nil) then
    begin
      p := q^.left;
      h := true;
    end else
    if (q^.left = nil) then
    begin
      p := q^.right;
      h := true;
    end else
    begin
      // important - p will be change !!!
      tmp_it := p^.left; // therefore rememder to tmp_it
      Del(tmp_it, p, q, h);
      p^.left := tmp_it;
      if h then
      	BalLeftAfterDel(p, h);
    end;
    dec(FItemCount);
    DoDeleteNode(q);
  end;
end; { delete }

procedure TBinTreeTemplate<K, V>.Del(var r: PBinTreeItem; var p: PBinTreeItem; deleting: PBinTreeItem; var h: boolean);
begin
  if r^.right <> nil then
    begin
    Del(r^.right, p, deleting, h);
    if h then
    	BalRightAfterDel(r, h);
    end else
    begin
    h := true;
    {tmp := q.key;
		q.key := r.key;
    r.key := tmp;
    q := r;
    r := r^.left;}
    // меняем местами удаляемого (q) с его левым->самым правым крайним (LR)

    p := r;         	//подменяем удаляемый узел на правого крайнего (LR)
    r := r^.left;
    // указываем новых потомков
    p^.left := deleting^.left;
    p^.right := deleting^.right;
    // запоминаем балансировку
    p^.bal := deleting^.bal;

    end;
end;

function TBinTreeTemplate<K, V>.DeleteByKey(Key: K; var p: PBinTreeItem; var h: boolean): boolean;
var
	q, tmp_it: PBinTreeItem;
  res: int8;

begin { main of delete }

 	if (p = nil) then
		begin
   	Result := false;
   	h := false;
    exit;
  	end;

  res := FKeyComparator(Key, p^.Key);
  if (res > 0){(x < p^.key)} then
   	begin
    Result := DeleteByKey(Key, p^.left, h);
    if h then
    	BalLeftAfterDel(p, h);
   	end else
  if (res < 0){(x > p^.key)}then
   	begin
    Result := DeleteByKey(Key, p^.right, h);
    if h then
    	BalRightAfterDel(p, h);
    end else
    begin // remove q
    Result := true;
    q := p;
    if (q^.right = nil) then
      begin
      p := q^.left;
      h := true;
      end else
    if (q^.left = nil) then
    	begin
      p := q^.right;
      h := true;
      end else
      begin
      // important - p will be change !!!
      tmp_it := p^.left; // therefore rememder to tmp_it
      Del(tmp_it, p, q, h);
      p^.left := tmp_it;
      if h then
      	BalLeftAfterDel(p, h);
      end;
    dec(FItemCount);
    DoDeleteNode(q);
    end;
end;

function TBinTreeTemplate<K, V>.RemoveNode(Key: PBinTreeItem): boolean;
var
	h: boolean;
begin
	h := false;
	Result := Delete(Key, FRoot, h);
end;

function TBinTreeTemplate<K, V>.Remove(const Key: K): boolean;
var
	h: boolean;
begin
	h := false;
	Result := DeleteByKey(Key, FRoot, h);
end;

{ TBinTree<V> }

function TBinTree<V>.Add(const Key: pByte; const LenKey: uint32; const Value: V): boolean;
var
  k: TValueBin;
begin
  Result := false;
  if LenKey = 0 then
    exit;

  GetMem(k.Data, LenKey);
  k.LenData := LenKey;
  if LenKey > FDepth then
    FDepth := LenKey;
  if LenKey < FMinLen then
    FMinLen := LenKey;
  move(Key^, k.Data^, LenKey);
  Result := Add(k, Value);
end;

function TBinTree<V>.Add(const Key: WideString; const Value: V): boolean;
begin
  if (length(Key) = 0) then
    exit(false);
  Result := Add(pByte(@Key[1]), length(key)*2, Value);
end;

function TBinTree<V>.Add(const Key: AnsiString; const Value: V): boolean;
begin
  if (length(Key) = 0) then
    exit(false);
  Result := Add(pByte(@Key[1]), length(key), Value);
end;

function TBinTree<V>.Add(const Key: int32; const Value: V): boolean;
begin
  Result := Add(pByte(@Key), sizeof(key), Value);
end;

function TBinTree<V>.Add(const Key: int64; const Value: V): boolean;
begin
  Result := Add(pByte(@Key), sizeof(key), Value);
end;

procedure TBinTree<V>.CheckChildsAndNotify(Node: TBinTreeNode; const Key: TValueBin);
var
  n: TBinTreeNode;
  res: int8;
begin
  StackNodes.Count := 0;
  if Assigned(Node.left) then
    StackNodes.Add(Node.left);
  if Assigned(Node.right) then
    StackNodes.Add(Node.right);
  while StackNodes.Count > 0 do
  begin
    n := StackNodes.Items[StackNodes.Count - 1];
    StackNodes.Delete(StackNodes.Count - 1);
    res := FKeyComparatorSoft(Key, n.Key);
    case res of
      0: begin
        if Assigned(FOnFindNode) then
          FOnFindNode(CurrentPosition, n);
        if Assigned(n.left) then
          StackNodes.Add(n.left);
        if Assigned(n.right) then
          StackNodes.Add(n.right);
      end;
      1: begin
        if Assigned(n.left) then
          StackNodes.Add(n.left);
      end;
      -1: begin
        if Assigned(n.right) then
        StackNodes.Add(n.right);
      end;
    end;
  end;
end;

class function TBinTree<V>.CompareKeys(const Key1, Key2: TValueBin): int8;
var
	i: int32;
begin
	if Key1.LenData > Key2.LenData then
  begin
    for i := 0 to Key2.LenData - 1 do
      if Key1.Data[i] > Key2.Data[i] then
        exit(-1)
      else
      if Key1.Data[i] < Key2.Data[i] then
        exit(1);
    exit(-1);
  end else {if LenSign > a.LenSign then}
	if Key1.LenData < Key2.LenData then
  begin
    for i := 0 to Key1.LenData - 1 do
      if Key1.Data[i] > Key2.Data[i] then
        exit(-1)
      else
      if Key1.Data[i] < Key2.Data[i] then
        exit(1);
    exit(1);
  end else
  begin
    for i := 0 to Key2.LenData - 1 do
      if Key1.Data[i] > Key2.Data[i] then
        exit(-1)
      else
      if Key1.Data[i] < Key2.Data[i] then
        exit(1);
      exit(0); //равны
  end;
end;

class function TBinTree<V>.CompareSoft(const InBuffer, Key: TValueBin): int8;
var
	i: int32;
begin
	if InBuffer.LenData > Key.LenData then
  begin
    for i := 0 to Key.LenData - 1 do
      if InBuffer.Data[i] > Key.Data[i] then
        exit(-1) else
      if InBuffer.Data[i] < Key.Data[i] then
        exit(1);
    exit(0); // equal
  end else // lengths is different
	if InBuffer.LenData < Key.LenData then
  begin
    for i := 0 to InBuffer.LenData - 1 do
      if InBuffer.Data[i] > Key.Data[i] then
        exit(-1) else
      if InBuffer.Data[i] < Key.Data[i] then
        exit(1);
    exit(2); //  InBuffer found in Key
  end else // lengths is different
  begin
    for i := 0 to InBuffer.LenData - 1 do
      if Key.Data[i] > InBuffer.Data[i] then
        exit(1) else
      if Key.Data[i] < InBuffer.Data[i] then
        exit(-1);
    exit(0); //  equal
  end;
end;

constructor TBinTree<V>.Create(AKeyComparator: TKeyComparator<TValueBin>);
begin
  inherited;
  FKeyComparator := CompareKeys;
  FKeyComparatorSoft := CompareSoft;
end;

function TBinTree<V>.Remove(const Key: pByte; const LenKey: uint32): boolean;
var
	h: boolean;
  k: TValueBin;
begin
	h := false;
  k.Data := Key;
  k.LenData := LenKey;
	Result := DeleteByKey(k, FRoot, h);
end;

function TBinTree<V>.Remove(const Key: AnsiString): boolean;
begin
  Result := Remove(@Key[1], Length(Key)*SizeOf(AnsiChar));
end;

function TBinTree<V>.Remove(const Key: int32): boolean;
begin
  Result := Remove(@Key, SizeOf(Key));
end;

function TBinTree<V>.Remove(const Key: int64): boolean;
begin
  Result := Remove(@Key, SizeOf(Key));
end;

function TBinTree<V>.Remove(const Key: WideString): boolean;
begin
  Result := Remove(@Key[1], Length(Key)*SizeOf(WideChar));
end;

function TBinTree<V>.Find(const Key: AnsiString; out Value: V): boolean;
begin
  Result := Find(@Key[1], Length(Key)*SizeOf(AnsiChar), Value);
end;

function TBinTree<V>.Find(const Key: WideString; out Value: V): boolean;
begin
  Result := Find(@Key[1], Length(Key)*SizeOf(WideChar), Value);
end;

function TBinTree<V>.Find(const Key: pByte; const LenKey: uint32;
  out Value: V): boolean;
var
  k: TValueBin;
begin
  k.Data := Key;
  k.LenData := LenKey;
  Result := Find(k, Value);
end;

function TBinTree<V>.Find(const Key: int64; out Value: V): boolean;
begin
  Result := Find(@Key, SizeOf(Key), Value);
end;

function TBinTree<V>.FindSoft(const Data: pByte; const LenData: uint32; out Value: V): boolean;
var
  n: TBinTreeTemplate<TValueBin, V>.PBinTreeItem;
begin
  n := FindNodeSoft(Data, LenData);
  if n <> nil then
  begin
    Result := true;
    Value := n^.Value;
  end else
  begin
    Value := FDefaultValue;
    Result := false;
  end;
end;

procedure TBinTree<V>.FindSoftAll(const Data: pByte; const LenData: uint32);
var
  i: int32;
begin
  for i := 0 to LenData - FMinLen do
  begin
    CurrentPosition := i;
    FindNodeSoft(@Data[i], LenData - uint32(i));
  end;
end;

function TBinTree<V>.FindNode(const Key: pByte; const LenKey: int32): TBinTreeNode;
var
  k: TValueBin;
begin
  k.Data := Key;
  k.LenData := LenKey;
  Result := inherited FindNode(k);
end;

function TBinTree<V>.FindNodeSoft(const Data: pByte; const LenData: uint32; StartNode: TBinTreeNode = nil): TBinTreeNode;
var
	res: int8;
  i: int32;
  k: TValueBin;
  part: TBinTreeNode;
  n_fnd: TBinTreeNode;
begin

  part := nil;
  n_fnd := nil;
  k.Data := Data;

  if StartNode <> nil then
    Result := StartNode
  else
    Result := FRoot;

  for i := 1 to LenData do
  begin

    if Assigned(part) then
    begin
      Result := part;
      part := nil;
    end else
    if Result = nil then
      break;

    k.LenData := i;

    while Result <> nil do
    begin
      res := FKeyComparatorSoft(k, Result^.Key);
      case res of
        -1: begin
          Result := Result^.right;
        end;
        0: begin
          n_fnd := Result;
          if Assigned(FOnFindNode) then
            FOnFindNode(CurrentPosition, Result);
          break;
        end;
        1: begin
          Result := Result^.left;
        end;
        2: begin  // key contains preffix such k
          if part = nil then
            part := Result;
          Result := Result^.left;
        end;
      end;
    end;
  end;
  Result := n_fnd;
end;

function TBinTree<V>.Find(const Key: int32; out Value: V): boolean;
begin
  Result := Find(@Key, SizeOf(Key), Value);
end;

procedure TBinTree<V>.DoDeleteNode(Node: TBinTreeNode);
begin
  if (Node.Key.LenData > 0) and Assigned(Node.Key.Data) then
  begin
    FreeMem(Node.Key.Data, Node.Key.LenData);
    Node.Key.Data := nil;
    Node.Key.LenData := 0;
  end;
  inherited;
end;

{ TBinTreeMultiValue<K, V> }

procedure TBinTreeMultiValue<K, V>.Clear;
begin
  FMultiTree.Clear;
end;

constructor TBinTreeMultiValue<K, V>.Create(AKeyComparator: TKeyComparator<K>; AValueComparator: TValueComparator<V>);
begin
  FMultiTree := TBinTreeTemplate<K, TMultiValue>.Create(AKeyComparator);
  FValueComparator := AValueComparator;
end;

destructor TBinTreeMultiValue<K, V>.Destroy;
begin
  FMultiTree.Clear;
  FMultiTree.Free;
  inherited;
end;

function TBinTreeMultiValue<K, V>.Add(const Key: K; const Value: V): TBinTreeMultiValueNode;
var
  vl: TMultiValue;
  i: int32;
begin
  Result := FMultiTree.FindNode(Key);
  if Assigned(Result) then
  begin
    { the value exists? }
    for i := 0 to Length(Result.Value.Values) - 1 do
      if FValueComparator(Result.Value.Values[i], Value) then
        exit;
    inc(FMultiTree.FItemCount);
  end else
    Result := FMultiTree.AddNode(Key, vl{%H-});

  SetLength(Result.Value.Values, Length(Result.Value.Values) + 1);
  Result.Value.Values[Length(Result.Value.Values) - 1] := Value;
end;

function TBinTreeMultiValue<K, V>.Remove(const Key: K; const Value: V): boolean;
var
  n: TBinTreeTemplate<K, TMultiValue>.PBinTreeItem;
begin
  n := FMultiTree.FindNode(Key);
  if n = nil then
    exit(false);
  Result := Remove(n, Value);
end;

function TBinTreeMultiValue<K, V>.Remove(const Node: TBinTreeMultiValueNode; const Value: V): boolean;
var
  i, j: int32;
begin
  if FMultiTree.Iterator.IterateNow then
    raise Exception.Create('The binary tree don''t support delete in time iterating :( This is future request...');
  { slowly, but Im hope you will dont use multitree with many equal keys :) }
  Result := false;
  for i := 0 to Length(Node.Value.Values) - 1 do
  begin
    if FValueComparator(Node.Value.Values[i], Value) then
    begin
      for j := i to Length(Node.Value.Values) - 2 do
        Node.Value.Values[j] := Node.Value.Values[j+1];
      Result := true;
      break;
    end;
  end;

  if not Result then
    exit;

  SetLength(Node.Value.Values, Length(Node.Value.Values)-1);

  if Length(Node.Value.Values) = 0 then
    FMultiTree.RemoveNode(Node)
  else
    dec(FMultiTree.FItemCount);
  Result := true;
end;

function TBinTreeMultiValue<K, V>.Find(const Key: K): V;
var
  n: TBinTreeMultiValueNode;
begin
  n := FMultiTree.FindNode(Key);
  if Assigned(n) then
    Result := n.Value.Values[0]
  else
    Result := FDefaultValue;
end;

function TBinTreeMultiValue<K, V>.FindNode(const Key: K): TBinTreeMultiValueNode;
begin
  Result := FMultiTree.FindNode(Key);
end;

{ TListDual<T> }

destructor TListDual<T>.Destroy;
var
  it: PListItem;
begin
  Clear;
  while FreeItems <> nil do
  begin
    it := FreeItems.Next;
    dispose(PListItem(FreeItems));
    FreeItems := it;
  end;
  inherited;
end;

procedure TListDual<T>.Clear;
begin
  if FFirst.Next <> nil then
  begin
    FLast.Next := FreeItems;
    FreeItems := FFirst.Next;
    FCount := 0;
    FCursor := -1;
    CursorItem := nil;
    FLast := nil;
    FFirst.Next := nil;
  end;
end;

function TListDual<T>.GetFreeItem: PListItem;
begin
  if FreeItems <> nil then
  begin
    Result := FreeItems;
    FreeItems := FreeItems.Next;
  end else
  begin
    new(Result);
    //Result.Owner := self;
  end;
end;

function TListDual<T>.GetItem(Index: int32): T;
begin
  Cursor := Index;
  if Assigned(UnderCursorItem) then
    Result := UnderCursorItem.Item
  else
    Result := fDefault;
end;

function TListDual<T>.GetItemListFirst: PListItem;
begin
  Result := FFirst.Next;
end;

function TListDual<T>.GetItemListLast: PListItem;
begin
  Result := FLast;
end;

function TListDual<T>.InsertAfter(const Item: T; After: PListItem): PListItem;
begin
  //FComparator
  if After <> nil then
  begin
    Result := GetFreeItem;
    Result^.Item := Item;
    Result^.Next := After^.Next;
    Result^.Prev := After;
    if After^.Next <> nil then
      After^.Next^.Prev := Result
    else
      FLast := Result;
    After^.Next := Result;
    inc(FCount);
    CursorItem := nil;
  end else
  begin
    Result := PushToEnd(Item);
  end;
end;

function TListDual<T>.InsertBefor(const Item: T; Befor: PListItem): PListItem;
begin
  if Befor <> nil then
  begin
    Result := GetFreeItem;
    Result^.Item := Item;
    Result^.Next := Befor;
    Result^.Prev := Befor^.Prev;
    if Befor^.Prev <> nil then
      Befor^.Prev^.Next := Result else
      FFirst.Next := Result;
    Befor^.Prev := Result;
    inc(FCount);
    CursorItem := nil;
  end else
  begin
    Result := PushToBegin(Item);
  end;
end;

function TListDual<T>.PushToBegin(const Item: T): PListItem;
begin
  Result := GetFreeItem;
  Result.Item := Item;
  if FFirst.Next <> nil then
    FFirst.Next^.Prev := Result else
    FLast := Result;
  Result^.Next := FFirst.Next;
  Result^.Prev := nil;
  FFirst.Next := Result;
  inc(FCount);
  inc(FCursor);
end;

function TListDual<T>.PushToEnd(const Item: T): PListItem;
begin
  Result := GetFreeItem;
  Result^.Item := Item;
  Result^.Next := nil;
  if FLast <> nil then
    FLast^.Next := Result
  else
    FFirst.Next := Result;
  Result^.Prev := FLast;
  FLast := Result;
  inc(FCount);
end;

function TListDual<T>.Read: PListItem;
begin
  Result := CursorItem;
  if CursorItem <> nil then
  begin
    inc(FCursor);
    CursorItem := CursorItem.Next;
  end;
end;

function TListDual<T>.Remove(var Item: PListItem; FreeItem: boolean): PListItem;
begin
  if (Item = nil) or (FCount = 0) then
    exit(nil);
  //if Item.Owner <> self then
  //  raise Exception.Create('Do not remove item from other list!');
  dec(FCount);
  Result := Item.Next;
  if (Item^.Next <> nil) then
    Item^.Next^.Prev := Item^.Prev
  else
    FLast := Item^.Prev;

  if (Item^.Prev <> nil) then
    Item^.Prev^.Next := Item^.Next
  else
    FFirst.Next := Item^.Next;

  CursorItem := nil;
  { useful if save managed types }
  Item.Item := DefaultT;

  if FreeItem then
  begin
    Item.Next := FreeItems;
    FreeItems := Item;
  end;

  Item := nil;
end;

procedure TListDual<T>.SetCursor(const Value: int32);
begin
  if (FCursor = Value) and (CursorItem <> nil) then
    exit;
  //FCursor := Value;
  if CursorItem = nil then
  begin
    if Value > (FCount shr 1) then
    begin
      FCursor := FCount - 1;
      CursorItem := FLast;
    end else
    begin
      FCursor := 0;
      CursorItem := FFirst.Next;
    end;
  end;

  if Value < FCount then
  begin
    if FCursor > Value then
    begin
      while (FCursor <> Value) do // and (CursorItem <> nil)
      begin
        dec(FCursor);
        CursorItem := CursorItem.Prev;
      end;
    end else
    begin
      while FCursor <> Value do
      begin
        inc(FCursor);
        CursorItem := CursorItem.Next;
      end;
    end;
  end else
  begin
    FCursor := FCount;
    CursorItem := nil;
  end;
end;

procedure TListDual<T>.SetItem(Index: int32; const Value: T);
begin
  if Index >= FCount then
    PushToEnd(Value)
  else
  begin
    Cursor := Index;
    InsertBefor(Value, UnderCursorItem);
  end;
end;

function TListDual<T>.Write(const Item: T): PListItem;
begin
  Result := InsertAfter(Item, CursorItem);
  CursorItem := Result;
  inc(FCursor);
end;

function TListDual<T>.Pop: T;
var
  it: PListItem;
begin
  if Assigned(FLast) then
  begin
    dec(FCount);
    if FCount < 0 then
      FCount := FCount;
    it := FLast;
    Result := FLast^.Item;
    CursorItem := nil;
    FLast := FLast.Prev;
    if Assigned(FLast) then
      FLast.Next := nil
    else
      FFirst.Next := nil;
    { put to free items list }
    it.Next := FreeItems;
    FreeItems := it;
  end else
    Result := fDefault;
end;

function TListDual<T>.PopBegin: T;
var
  it: PListItem;
begin
  if Assigned(FFirst.Next) then
  begin
    dec(FCount);
    it := FFirst.Next;
    Result := FFirst.Next^.Item;
    CursorItem := nil;
    FFirst.Next := FFirst.Next^.Next;
    if FFirst.Next <> nil then
      FFirst.Next^.Prev := nil
    else
      FLast := nil;
    { put to free items list }
    it.Next := FreeItems;
    FreeItems := it;
  end else
    Result := fDefault;
end;

{ TBinTreeNotSensitive<V> }

function TBinTreeNotSensitive<V>.Add(const Key: pByte; const LenKey: uint32; const Value: V): boolean;
begin
  Result := false;
  if LenKey = 0 then
    exit;
  ToUp(Key, LenKey);
  Result := inherited Add(@BufForTranslate[0], LenKey, Value);
end;

constructor TBinTreeNotSensitive<V>.Create(AKeyComparator: TKeyComparator<TValueBin>);
var
  c: AnsiChar;
begin
  inherited;
  SizeBuf := 65536;
  SetLength(BufForTranslate, SizeBuf);
  for c := #0 to #255 do
  begin
    g_TableTranslateToUp[Byte(c)] := byte(AnsiString(AnsiUpperCase(string(c)))[1]);
    if g_TableTranslateToUp[Byte(c)] = 63 then
      g_TableTranslateToUp[Byte(c)] := Ord(c);
  end;
end;

destructor TBinTreeNotSensitive<V>.Destroy;
begin
  inherited;
end;

procedure TBinTreeNotSensitive<V>.ToUp(Src: pByte; Len: int32);
var
  i: int32;
begin
  if SizeBuf < Len then
  begin
    SizeBuf := Len;
    SetLength(BufForTranslate, SizeBuf);
  end;
  for i := 0 to Len - 1 do
    BufForTranslate[i] := g_TableTranslateToUp[(Src+i)^];
end;

procedure TBinTreeNotSensitive<V>.FindSoftAll(const Key: pByte; const LenKey: uint32);
var
  i, pos_end_const, pos_end, pos_begin: int32;
  len: int32;
begin
  if LenKey > FDepth then
    pos_end_const := FDepth
  else
    pos_end_const := LenKey;
  pos_end := pos_end_const - 1;
  ToUp(Key, pos_end_const);
  pos_begin := 0;
  len := LenKey;
  for i := 0 to LenKey - FMinLen do
  begin
    CurrentPosition := i;
    FindNodeSoft(@BufForTranslate[pos_begin], pos_end_const);
    inc(pos_end);
    inc(pos_begin);
    dec(len);

    if len < pos_end_const then
      pos_end_const := len;

    if pos_end = SizeBuf then
    begin
      pos_begin := 0;
      pos_end := pos_end_const - 1;
      if len > 0 then
        ToUp(@Key[i + 1], pos_end_const);
    end else
      BufForTranslate[pos_end] := g_TableTranslateToUp[Key[i + pos_end_const]];
  end;
end;

function TBinTreeNotSensitive<V>.FindUp(const KeyUp: pByte; const LenKey: uint32; out Value: V): boolean;
begin
  Result := inherited Find(KeyUp, LenKey, Value);
end;

function TBinTreeNotSensitive<V>.Find(const Key: pByte; const LenKey: uint32; out Value: V): boolean;
begin
  ToUp(Key, LenKey);
  CurrentPosition := 0;
  Result := inherited Find(@BufForTranslate[0], LenKey, Value);
end;

function TBinTreeNotSensitive<V>.FindSoft(const Key: pByte; const LenKey: uint32; out Value: V): boolean;
var
  pos_end_const: int32;
begin
  if LenKey > FDepth then
    pos_end_const := FDepth
  else
    pos_end_const := LenKey;
  ToUp(Key, pos_end_const);
  CurrentPosition := 0;
  Result := inherited FindSoft(@BufForTranslate[0], pos_end_const, Value);
end;

{ THashMap<K, V> }

function THashMap<K, V>.Add(const Key: K; const Value: V): TMultiTreeNode;
begin
  Result := FMultiTree.Add(HashFunction(Key), Value);
end;

procedure THashMap<K, V>.Clear;
begin
  FMultiTree.Clear;
end;

constructor THashMap<K, V>.Create(AHashFunction: THashFunction<K>; AValueComparator: TValueComparator<V>);
begin
  inherited Create;
  HashFunction := AHashFunction;
  FMultiTree := TMultiTree.Create(@UInt32cmp, AValueComparator);
end;

destructor THashMap<K, V>.Destroy;
begin
  Clear;
  FMultiTree.Free;
  inherited;
end;

function THashMap<K, V>.Find(const Key: K): V;
begin
  Result := FMultiTree.Find(HashFunction(Key));
end;

function THashMap<K, V>.FindNode(const Key: K): TMultiTreeNode;
begin
  Result := FMultiTree.FindNode(HashFunction(Key));
end;

function THashMap<K, V>.Remove(const Node: TMultiTreeNode;
  const Value: V): boolean;
begin
  Result := FMultiTree.Remove(Node, Value);
end;

function THashMap<K, V>.Remove(const Key: K; const Value: V): boolean;
begin
  Result := FMultiTree.Remove(HashFunction(Key), Value);
end;

{ TValueEncoder }

class procedure TValueEncoder.Write(ToStream: TStream; Value: uint32);
const
  BITS_LEN_SIZE = $C0;
var
  big: uint32;
begin
  if Value < BITS_LEN_SIZE then
  begin
    { 2 high bits equal zero = only one byte is used for encode the uint32; the most
      likely case }
    ToStream.Write(Value, 1);
  end else
  begin
    { encode ClassType to variable number bytes, in depend from value }
    big := Value shr 6;
    if Value < $FFFF - BITS_LEN_SIZE then
    begin
      { make 2 high bits equal 1 = used two bytes for encode ID ClassType }
      Value := Value xor $40;
      ToStream.Write(Value, 1);
      ToStream.Write(big, 1);
    end else
    if Value < $FFFFFF - BITS_LEN_SIZE then
    begin
      { make 2 high bits equal 2 = used three bytes for encode ID ClassType }
      Value := Value xor $80;
      ToStream.Write(Value, 1);
      ToStream.Write(big, 2);
    end else
    begin
      { make 2 high bits equal 3 = used three bytes for encode ID ClassType }
      Value := Value xor $C0;
      ToStream.Write(Value, 1);
      ToStream.Write(big, 3);
    end;
  end;
end;

{ TValueDecoder }

class function TValueDecoder.Read(FromStream: TStream): uint32;
var
  lo: byte;
  hi: uint32;
begin
  FromStream.Read(lo{%H-}, 1);
  case (lo and $C0) of
    0: begin
      Result := lo;
    end;
    $40: begin
      Result := lo and $3F;
      FromStream.Read(lo, 1);
      Result := Result + ((word(lo) shl 6) and $FFC0);
    end;
    $80: begin
      Result := lo and $3F;
      FromStream.Read(hi{%H-}, 2);
      Result := Result + ((hi shl 6) and $3FFFC0);
    end else
    begin
      Result := lo and $3F;
      FromStream.Read(hi, 3);
      Result := Result + ((hi shl 6) and $3FFFC000);
    end;
  end;
end;

{ TAhoCorasickFSA<T> }

function TAhoCorasickFSA<T>.Add(AWord: pByte; LenWord: int32; const Data: T): boolean;
var
  v: PVertex;
  i, l: int32;
  added, h: boolean;
  vrt: TVertex;
begin
  if LenWord < 1 then
    exit(false);

  l := LenWord - 1;
  added := false;
  vrt.Subtree := FRootVertex;
  v := @vrt;
  for i := 0 to l do
  begin
    added := false;
    h := false;
    v := InsertKey(AWord[i], v.Subtree, added, h);
    v.Level := i;
  end;

  if Assigned(v.UserData) then
  begin
    if not added then
      raise Exception.Create('The Key already exists!');
  end else
    new(v.UserData);

  FRootVertex := vrt.Subtree;
  v.UserData.UserData := Data;
  inc(FCount);
  Result := true;
end;

function TAhoCorasickFSA<T>.Add(const AWord: WideString; const Data: T): boolean;
begin
  if Length(AWord) > 0 then
    Result := Add(@AWord[1], Length(AWord)*2, Data)
  else
    Result := false;
end;

function TAhoCorasickFSA<T>.Add(const AWord: AnsiString; const Data: T): boolean;
begin
  if Length(AWord) > 0 then
    Result := Add(@AWord[1], Length(AWord), Data)
  else
    Result := false;
end;

procedure TAhoCorasickFSA<T>.BalanceLeft(var Vert: PVertex; var H: boolean);
var
	v1, v2: PVertex;
begin
  case Vert^.Balance of
    1:begin
      Vert^.Balance := 0;
      H := false;
    end;
    0:begin
      Vert^.Balance:= -1;
    end;
    -1: begin   // new balancing
      v1 := Vert^.left;
      if (v1^.Balance = -1) then
      begin   // single ll rotation
        Vert^.left := v1^.right;
        v1^.right := Vert;
        Vert^.Balance := 0;
        Vert := v1;
      end else
      begin //double lr rotation
        v2 := v1^.right;
        v1^.Right := v2^.left;
        v2^.left := v1;
        Vert^.left := v2^.right;
        v2^.right := Vert;

        if v2^.Balance < 0 then
          Vert^.Balance := +1
        else
          Vert^.Balance := 0;

        if v2^.Balance > 0 then
          v1^.Balance := -1
        else
          v1^.Balance := 0;

        Vert := v2;
      end;
      Vert^.Balance := 0;
      H := false;
    end; { -1 }
  end; { case }
end;

procedure TAhoCorasickFSA<T>.BalanceRight(var Vert: PVertex; var H: boolean);
var
	v1, v2: PVertex;
Begin
  case Vert^.Balance of
    -1:begin
       Vert^.Balance := 0;
       H := false;
    end;
    0: begin
       Vert^.Balance := +1;
    end;
    +1: begin    // new balancing
      v1 := Vert^.right;
      if (v1^.Balance = 1) then
      begin  // single rr rotation
        Vert^.right := v1^.left;
        v1^.left := Vert;
        Vert^.Balance := 0;
        Vert := v1;
      end else
      begin  // double rl rotation
        v2 := v1^.left;
        v1^.left := v2^.right;
        v2^.right := v1;
        Vert^.right := v2^.left;
        v2^.left := Vert;

        if v2^.Balance > 0 then
          Vert^.Balance := -1
        else
          Vert^.Balance := 0;

        if v2^.Balance < 0 then
          v1^.Balance := +1
        else
          v1^.Balance := 0;

        Vert := v2;
      end;
      Vert^.Balance := 0;
      H := false;
    end; {+1: begin}
 	end;
end;

procedure TAhoCorasickFSA<T>.BeginUpdate;
begin
  inc(_CountUpd);
end;

procedure TAhoCorasickFSA<T>.Clear;
var
  List: TListVec<PVertex>;
  v: PVertex;
begin
  if FRootVertex = nil then
    exit;
  List := TListVec<PVertex>.Create;
  try
    List.Add(FRootVertex);
    FRootVertex := nil;
    FCountVertexes := 0;
    while List.Count > 0 do
    begin
      v := List.Pop;
      if Assigned(v.Left) then
        List.Add(v.Left);
      if Assigned(v.Right) then
        List.Add(v.Right);
      if Assigned(v.Subtree) then
        List.Add(v.Subtree);
      if Assigned(v.UserData) then
        dispose(v.UserData);
      dispose(v);
    end;
  finally
    List.Free;
  end;
end;

function TAhoCorasickFSA<T>.CreateNode(Key: byte): PVertex;
begin
  new(Result);
  FillChar(Result^, SizeOf(TVertex), 0);
  Result^.Ch := Key;
  inc(FCountVertexes);
end;

destructor TAhoCorasickFSA<T>.Destroy;
begin
  Clear;
  inherited;
end;

procedure TAhoCorasickFSA<T>.EndUpdate;
begin
  dec(_CountUpd);
  if (_CountUpd = 0) then
    FindAllSuffixes;
end;

procedure TAhoCorasickFSA<T>.Find(Buffer: pByte; LenBuffer: int32);
var
  i: int32;
  vrt, res: PVertex;
  parent: PVertex;
begin
  vrt := FRootVertex;
  parent := FRootVertex;
  for i := 0 to LenBuffer - 1 do
  begin
    { bellow are two main parts:
      1 - vertex found on a current level, try move deepper if the vertex
        contains subtree, otherwise find next level in suffexes simultaneously
        sending containded user data;
      2 - vertex did not find - move by suffexes, along the way check
        if exist the subtree for move forward it and user data for sending

      Despite many incapsulated cycles, algorithm work enough quickly, because
      every cycle contains one-two iterations, besides, every time compares only
      one byte, in contrast TBinTreeTemplate where compares whoule keys
    }
    res := FindVert(Buffer[i], vrt);
    { found in subtree vrt? }
    if Assigned(res) then
    begin

      if Assigned(res.UserData) then
        FOnFoundProc(res.UserData.UserData, @Buffer[i-res.Level], res.Level + 1);

      if Assigned(res.Subtree) then
      begin  { move forward }
        parent := res;
        vrt := res.Subtree;
      end else
      begin
        parent := nil;
        vrt := nil;
      end;

      { send all suffixes with data and find next level }
      while Assigned(res.Suffix) do
      begin

        res := res.Suffix;

        if Assigned(res.Subtree) and not Assigned(parent) then
        begin
          parent := res;
          vrt := res.Subtree;
        end;

        if Assigned(res.UserData) then
          FOnFoundProc(res.UserData.UserData, @Buffer[i-res.Level], res.Level + 1);

      end;

    end else { if res <> nil then }
    begin
      res := parent;
      parent := nil;
      if vrt.Level > 0 then
      begin
        vrt := nil;

        { find suffix that contains Buffer[i] in its subtree }
        while Assigned(res.Suffix) do
        begin
          res := res.Suffix;
          if Assigned(res.Subtree) then
          begin

            vrt := FindVert(Buffer[i], res.Subtree);

            if Assigned(vrt) then
            begin

              if Assigned(vrt.UserData) then
                FOnFoundProc(vrt.UserData.UserData, @Buffer[i-vrt.Level], vrt.Level + 1);

              res := vrt;
              vrt := nil;

              { ok, found new subtree in one of suffexes for current Buffer[i], now
                send a user data from all upper suffixes }

              repeat
                if not Assigned(vrt) and Assigned(res.Subtree) then
                begin
                  parent := res;
                  vrt := res.Subtree;
                end;
                if Assigned(res.Suffix) then
                begin
                  res := res.Suffix;
                  if Assigned(res.UserData) then
                    FOnFoundProc(res.UserData.UserData, @Buffer[i-res.Level], res.Level + 1);
                end else
                  break;
              until (res.Level = 0);

              break;
            end;
          end;
        end; { while res.Suffix <> nil do }

        if not Assigned(vrt) then //and ((res.Level = 0) or (res.Suffix = nil))
        begin
          { it finds in root }
          vrt := FindVert(Buffer[i], FRootVertex);
          if Assigned(vrt) then
          begin

            if Assigned(vrt.UserData) then
              FOnFoundProc(vrt.UserData.UserData, @Buffer[i-vrt.Level], vrt.Level + 1);

            if Assigned(vrt.Subtree) then
            begin
              parent := vrt;
              vrt := vrt.Subtree;
            end;

          end;
        end;
      end;

    end;

    if not Assigned(parent) then
    begin
      parent := FRootVertex;
      vrt := FRootVertex;
    end;

  end;
end;

procedure TAhoCorasickFSA<T>.Find(const Buffer: WideString);
begin
  if Length(Buffer) > 0 then
    Find(@Buffer[1], Length(Buffer)*2);
end;

procedure TAhoCorasickFSA<T>.Find(const Buffer: AnsiString);
begin
  if Length(Buffer) > 0 then
    Find(@Buffer[1], Length(Buffer));
end;

procedure TAhoCorasickFSA<T>.GetSuffix(vert: PVertex);
var
  i, j: int32;
  v: PVertex;
begin

  if vert.Level > 0 then
  begin
    StackData[vert.Level] := vert.Ch;
    for j := 1 to vert.Level do
    begin
      v := FRootVertex;
      for i := j to vert.Level do
      begin
        v := FindVert(StackData[i], v);
        if Assigned(v) then
        begin
          if i = vert.Level then
          begin
            vert.Suffix := v;
            //if (v.Level = 1) and (v.Ch = $62) then
            //  v.Level := v.Level;
            break;
          end;
          v := v.Subtree;
        end else
          break;
      end;
      { take the max suffix which is the first hit from a level (j) = 1 to vert.Level }
      if Assigned(vert.Suffix) and (vert.Suffix.Level > 0) then
        break;
    end;
  end;

  if Assigned(vert.Subtree) then
    GetSuffix(vert.Subtree);

  if Assigned(vert.Left) then
    GetSuffix(vert.Left);

  if Assigned(vert.Right) then
    GetSuffix(vert.Right);

end;

procedure TAhoCorasickFSA<T>.FindAllSuffixes;
begin
  if not Assigned(FRootVertex) then
    exit;
  GetSuffix(FRootVertex);
end;

function TAhoCorasickFSA<T>.InsertKey(Key: byte; var Vert: PVertex; var Added, H: boolean): PVertex;
begin
  if not Assigned(Vert) then
  begin        // the vertex do not contained in tree, insert it
   	Vert := CreateNode(Key);
   	Added := true;
    H := true;
    exit(Vert);
  end;

  if (Key > Vert^.Ch) then
  begin
   	Result := InsertKey(Key, Vert^.left, Added, H);
   	if Added and H then
      BalanceLeft(Vert, H);
  end else
  if (Key < Vert.Ch) then
  begin
    Result := InsertKey(Key, Vert^.right, Added, H);
   	if Added and H then
      BalanceRight(Vert, H);
  end else
  begin
    Added := false;
    Result := Vert;
  end;
end;

function TAhoCorasickFSA<T>.WordExists(AWord: pByte; LenWord: int32; out Data: T): boolean;
var
  i: int32;
  vrt, res: PVertex;
begin
  vrt := FRootVertex;
  res := nil;
  { walk on all vector till end }
  for i := 0 to LenWord - 1 do
  begin
    res := FindVert(AWord[i], vrt);
    if Assigned(res) then
    begin
      if res.Subtree <> nil then
        vrt := res.Subtree;
    end else
      break;
  end;
  { exists? }
  if Assigned(res) and Assigned(res.UserData) then
  begin
    Result := true;
    Data := res.UserData.UserData;
  end else
  begin
    Result := false;
    Data := FDefault;
  end;
end;

function TAhoCorasickFSA<T>.Find(Buffer: pByte; LenBuffer: int32; out Data: T): boolean;
var
  i: int32;
  vrt, res: PVertex;
begin
  vrt := FRootVertex;
  for i := 0 to LenBuffer - 1 do
  begin
    res := FindVert(Buffer[i], vrt);
    if Assigned(res) then
    begin
      if Assigned(res.UserData) then
      begin
        Data := res.UserData.UserData;
        exit(true);
      end;
      if Assigned(res.Subtree) then
        vrt := res.Subtree;
    end else
      break;
  end;
  Data := FDefault;
  Result := false;
end;

function TAhoCorasickFSA<T>.WordExists(AWord: pByte; LenWord: int32): boolean;
var
  data: T;
begin
  Result := WordExists(AWord, LenWord, data);
end;

function TAhoCorasickFSA<T>.WordExists(const AWord: WideString; out Data: T): boolean;
begin
  if Length(AWord) > 0 then
    Result := WordExists(@AWord[1], Length(AWord)*2, data)
  else
    Result := false;
end;

function TAhoCorasickFSA<T>.WordExists(const AWord: WideString): boolean;
begin
  if Length(AWord) > 0 then
    Result := WordExists(@AWord[1], Length(AWord)*2)
  else
    Result := false;
end;

function TAhoCorasickFSA<T>.FindVert(Key: byte; Root: PVertex): PVertex;
begin
  Result := Root;
  while Result <> nil do
  begin
    if Key > Result.Ch then
      Result := Result.Left
    else
    if Key < Result.Ch then
      Result := Result.Right
    else
      exit;
  end;
end;

function TAhoCorasickFSA<T>.WordExists(const AWord: AnsiString): boolean;
begin
  if Length(AWord) > 0 then
    Result := WordExists(@AWord[1], Length(AWord))
  else
    Result := false;
end;

function TAhoCorasickFSA<T>.WordExists(const AWord: AnsiString; out Data: T): boolean;
begin
  if Length(AWord) > 0 then
    Result := WordExists(@AWord[1], Length(AWord), data)
  else
    Result := false;
end;

{ THashTable<K, V> }

function THashTable<K, V>.TryAdd(const Key: K; const Value: V): boolean;
var
  index, hash: int32;
begin
  if FCount > 0 then
  begin
    index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
    hash := index;
    if DoFind(index, Key) then
      exit(false);
  end else
  begin
    index := -1;
  end;

  if (FCount = FThresholdRehash) or (Length(FItems) = 0) then
  begin
    if Length(FItems) = 0 then
      Grow(FItems, 32)
    else
      GrowAndRehash(Length(FItems) shl 1);
    DoSetValue(Key, Value);
  end else
  if index < 0 then
    DoSetValue(Key, Value)
  else
    DoSetValue(index, hash{%H-}, Key, Value);

  Result := true;
end;

procedure THashTable<K, V>.TryAddOrReplace(const Key: K; const Value: V);
begin
  if not TryAdd(Key, Value) then
    UpdateValue(Key, Value);
end;

procedure THashTable<K, V>.UpdateValue(const Key: K; const Value: V);
var
  index: int32;
begin
  if FCount > 0 then
  begin
    index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
    if not DoFind(index, Key) then
      raise Exception.Create('The Key doesn''t exist!');

    FItems[index].Value := Value;
  end else
    raise Exception.Create('The Key doesn''t exist!');
end;

procedure THashTable<K, V>.Clear(FreeMemory: boolean = false);
var
  i: int32;
begin
  if FreeMemory then
    SetLength(FItems, 0)
  else
  for i := 0 to length(FItems) - 1 do
    FItems[i] := EmptyItem;

  FCount := 0;
end;

constructor THashTable<K, V>.Create(AHashFunction: THashFunction<K>; AKeyComparator: TKeyComparatorEqual<K>; ACapacity: int32 = 32);
var
  i: int32;
begin
  FHashFunction := AHashFunction;
  FKeyComparator := AKeyComparator;
  EmptyItem.Hash := -1;
  IteratedBucket := -1;
  if ACapacity > 0 then
  begin
    Grow(FItems, ACapacity);
    { grow does not define to empty buckets, therefore do it here }
    for i := 0 to length(FItems) - 1 do
      FItems[i].Hash := -1;
  end;
end;

procedure THashTable<K, V>.Delete(const Key: K);
var
  index: int32;
  min_hash_index: int32;
begin
  if FCount = 0 then
    exit;

  index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
  repeat

    if (FItems[index].Hash < 0) then
      break;

    if FKeyComparator(FItems[index].Key, Key) then
    begin
      { returns IteratedBucket on step back, because if in the place was collision
        then when an item was deleted to the place has been placed the next item }
      if IteratedBucket = FItems[index].Hash then
        dec(IteratedBucket);
      dec(FCount);
      FItems[index].Hash := -1;
      min_hash_index := index;

      repeat
        Inc(index);
        if index = Length(FItems) then
          index := 0;

        if (FItems[index].Hash < 0) then
          break;

        if (FItems[index].Hash <= min_hash_index) then
        begin
          FItems[min_hash_index] := FItems[index];
          FItems[index] := EmptyItem;
          min_hash_index := index;
        end;

      until false;

      break;
    end;

    inc(index);
    if index = Length(FItems) then
      index := 0;
  until false;

end;

destructor THashTable<K, V>.Destroy;
begin
  Clear;
  inherited;
end;

procedure THashTable<K, V>.DoSetValue(const Key: K; const Value: V);
var
  index, hash: int32;
begin
  index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
  hash := index;
  while FItems[index].Hash >= 0 do
  begin
    inc(index);
    if index = Length(FItems) then
      index := 0;
  end;
  DoSetValue(index, hash, Key, Value);
end;

procedure THashTable<K, V>.DoSetValue(Index, Hash: int32; const Key: K; const Value: V);
begin
  FItems[Index].Key := Key;
  FItems[Index].Value := Value;
  FItems[Index].Hash := Hash;
  inc(FCount);
end;

function THashTable<K, V>.Exists(const Key: K): boolean;
var
  index: int32;
begin
  index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
  Result := DoFind(index, Key);
end;

{function THashTable<K, V>.FindBucket(const Key: K; out Item: TBucket): boolean;
var
  index: int32;
begin
  if FCount = 0 then
    exit(false);
  index := GetBucketIndex(FHashFunction(Key) and not ($80000000));
  Result := DoFind(index, Key);
  if Result then
    Item := FItems[index];
end;   }

function THashTable<K, V>.DoFind(var BucketIndex: int32; const Key: K): boolean;
begin
  repeat
    if FItems[BucketIndex].Hash < 0 then
      exit(false);

    if FKeyComparator(FItems[BucketIndex].Key, Key) then
      exit(true);

    inc(BucketIndex);
    if BucketIndex = Length(FItems) then
      BucketIndex := 0;
  until false;
  Result := false;
end;

function THashTable<K, V>.Find(const Key: K; out Value: V): boolean;
var
  index: int32;
begin
  if FCount = 0 then
  begin
    Value := FDefaultValue;
    exit(false);
  end;
  index := GetBucketIndex(FHashFunction(Key) and not ($80000000){%H-});
  Result := DoFind(index, Key);
  if Result then
    Value := FItems[index].Value
  else
    Value := FDefaultValue;
end;

function THashTable<K, V>.GetBucketIndex(Hash: int32): int32;
var
  m: uint32;
begin
  if FMaskBytes > 3 then
    Result := Hash and FMaskCapacity
  else
  if FMaskBytes > 2 then
    Result := (Hash xor (Hash shr 24)) and FMaskCapacity
  else
  if FMaskBytes > 1 then
    Result := (Hash xor (Hash shr 16)) and FMaskCapacity
  else
    Result := (PByte(@Hash)^ xor (PByte(@Hash)+1)^ xor (PByte(@Hash)+2)^ xor (PByte(@Hash)+3)^) and FMaskCapacity;

  if (Result >= Length(FItems)) then
  begin
    m := FMaskCapacity shr 1;
    Result := Result and m;
    while (Result >= Length(FItems)) do
    begin
      m := m shr 1;
      Result := Result and m;
    end;
  end;
end;

function THashTable<K, V>.GetFirst(out Bucket: TBucket): boolean;
begin
  IteratedBucket := 0;
  while IteratedBucket < Length(FItems) do
  begin
    if (FItems[IteratedBucket].Hash >= 0) then
    begin
      Bucket := FItems[IteratedBucket];
      exit(true);
    end;
    inc(IteratedBucket);
  end;
  Result := false;
end;

function THashTable<K, V>.GetNext(out Bucket: TBucket): boolean;
begin
  inc(IteratedBucket);
  while IteratedBucket < Length(FItems) do
  begin
    if (FItems[IteratedBucket].Hash >= 0) then
    begin
      Bucket := FItems[IteratedBucket];
      exit(true);
    end;
    inc(IteratedBucket);
  end;
  Result := false;
end;

function THashTable<K, V>.GetValue(const Key: K): V;
begin
  if not Find(Key, Result) then
    raise Exception.Create('The Key doesn''t exist!');
end;

procedure THashTable<K, V>.Grow(var AItems: TBuckets; ANewCapacity: int32);
var
  count_bits: int32;
  i: int32;
begin

  SetLength(AItems, ANewCapacity);

  FThresholdRehash := trunc(ANewCapacity * 0.75);

  count_bits := 0;
  FMaskCapacity := 0;
  dec(ANewCapacity);
  while ANewCapacity > 0 do
  begin
    inc(count_bits);
    if ANewCapacity and 1 > 0 then
      FMaskCapacity := FMaskCapacity or (round(power(2, count_bits)) - 1);
    ANewCapacity := ANewCapacity shr 1;
  end;
  if FMaskCapacity > $FFFFFF then
    FMaskBytes := 4
  else
  if FMaskCapacity > $FFFF then
    FMaskBytes := 3
  else
  if FMaskCapacity > $FF then
    FMaskBytes := 2
  else
    FMaskBytes := 1;

  for i := 0 to length(AItems) - 1 do
    AItems[i].Hash := -1;
end;

procedure THashTable<K, V>.GrowAndRehash(ANewCapacity: int32);
var
  old_buckets, new_buckets: TBuckets;
  i: int32;
begin
  Grow(new_buckets{%H-}, ANewCapacity);
  old_buckets := FItems;
  FItems := new_buckets;
  FCount := 0;

  for i := 0 to length(old_buckets) - 1 do
  begin
    if old_buckets[i].Hash >= 0 then
      DoSetValue(old_buckets[i].Key, old_buckets[i].Value);
  end;
  SetLength(old_buckets, 0);
end;

procedure THashTable<K, V>.SetValue(const Key: K; const Value: V);
begin
  if not TryAdd(Key, Value) then
    raise Exception.Create('The Key already exists!');
end;

end.

