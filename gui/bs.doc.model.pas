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

unit bs.doc.model;

{$I BlackSharkCfg.inc}

interface

uses
  classes,
  bs.basetypes,
  bs.collections,
  bs.geometry;

type

  { Forward declarations }

  TDocItem                    = class;
  TDocGraphicItem             = class;
  TBlackSharkCustomDoc        = class;
  TDocItemClass               = class of TDocItem;
  TBlackSharkCustomDocClass   = class of TBlackSharkCustomDoc;
  TItemDocTree                = TVirtualTree<TDocItem>;
  PItemDocTreeNode            = TItemDocTree.PVirtualTreeNode;
  TDocItemList                = TListVec<TDocGraphicItem>;
  TItemEvent                  = procedure (Item: TDocItem) of object;

  TSpaceTestDir = (tdLeft, tdRight, tdUp, tdDown);

  { A basic object for any item of TBlackSharkCustomDoc; contains a data of the
    document, and that is why they may be in many quantity; not mandatory visual,
    can contain impacting properties on child items in hierarchy }

  TDocItem = class abstract
  private
    FText: WideString;
  protected
    FDoc: TBlackSharkCustomDoc;
    Node: PItemDocTreeNode;
    FVisible: boolean;
    procedure Build; virtual;
    procedure AfterAddChildResource(Child: TDocItem); virtual;
    procedure BeforDelChildResource(Child: TDocItem); virtual;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc; Owner: TDocItem); virtual;
    destructor Destroy; override;
    function GetParentSize: TVec2f;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Load(const {%H-}FromStream: TStream; const {%H-}SizeData: int32); virtual;
    procedure Save(const {%H-}ToStream: TStream); virtual;
    function ParentClassExists(ParentClass: TDocItemClass): boolean;
    function ParentClass(ParentClass: TDocItemClass): TDocItem;
  public
    { retuns self a pointer on a visual data which presents the ItemData in viewport }
    function Show(const ViewPort: TRectBSf): Pointer; virtual;
    procedure Hide; virtual;
    procedure UpdatePosition(const ViewPort: TRectBSf); virtual; abstract;
    property Doc: TBlackSharkCustomDoc read FDoc;
    property Text: WideString read FText write FText;
    property Visible: boolean read FVisible;
  end;

  { TSheetStyles }

  TSheetStyles = class(TDocItem)
  private
    type
      PUsedKindDescr = ^TUsedKindDescr;
      TUsedKindDescr = record
        id: uint32;
        UsesInDoc: uint32;
        DocItemClass: TDocItemClass;
      end;
  private
    CurrentStyles: TListVec<PUsedKindDescr>;
  protected
    procedure AfterAddChildResource(Child: TDocItem); override;
    procedure BeforDelChildResource(Child: TDocItem); override;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc; Owner: TDocItem); override;
    destructor Destroy; override;
    procedure Load(const {%H-}FromStream: TStream; const {%H-}SizeData: int32); override;
    procedure Save(const {%H-}ToStream: TStream); override;
    procedure UpdatePosition(const ViewPort: TRectBSf); override;
    function GetStyleUsed(ID: int32): TDocItemClass;
    procedure ClearStyles;
  end;

  { A common representative visual parts data of document }

  { TDocGraphicItem }

  TDocGraphicItem = class(TDocItem)
  private
    FBanIntersectsChilds: boolean;
    FLimitPosX: TVec2f;
    FLimitPosY: TVec2f;
    FLimitHeight: TVec2f;
    FLimitWidth: TVec2f;
    FFixed: boolean;
    function GetPosition: TVec2f;
    function GetSize: TVec2f;
    procedure SetPosition(const Value: TVec2f);
    procedure SetSize(const Value: TVec2f);
    procedure SetBanIntersectsChilds(const Value: boolean);
    procedure SetLimitPosX(const Value: TVec2f);
    procedure SetLimitPosY(const Value: TVec2f);
    procedure SetLimitHeight(const Value: TVec2f);
    procedure SetLimitWidth(const Value: TVec2f);
  protected
    FNodeInSpaceTree: PNodeSpaceTree;
    procedure SetRect(const Value: TRectBSf); virtual;
    procedure Build; override;
  public
    { a visual data self for every descendants }
    _VisualData: Pointer;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc; Parent: TDocItem); override;
    procedure UpdatePosition(const ViewPort: TRectBSf); override;
    function PositionTest(var Delta: TVec2f; StrictTest: boolean = true): boolean;
    function ResizeTest(var Delta: TVec2f; StrictTest: boolean = true): boolean;
  public
    FRect: TRectBSf;
  public
    property Fixed: boolean read FFixed write FFixed;
    property NodeInSpaceTree: PNodeSpaceTree read FNodeInSpaceTree write FNodeInSpaceTree;
    property Position: TVec2f read GetPosition write SetPosition;
    property Size: TVec2f read GetSize write SetSize;
    property Rect: TRectBSf read FRect write SetRect;
    property LimitPosX: TVec2f read FLimitPosX write SetLimitPosX;
    property LimitPosY: TVec2f read FLimitPosY write SetLimitPosY;
    property LimitWidth: TVec2f read FLimitWidth write SetLimitWidth;
    property LimitHeight: TVec2f read FLimitHeight write SetLimitHeight;
    property BanIntersectsChilds: boolean read FBanIntersectsChilds write SetBanIntersectsChilds;
  end;

  TOnDocEvent = procedure (CustomDoc: TBlackSharkCustomDoc) of object;
  { TBlackSharkCustomDoc

      TODO:
   }

  TBlackSharkCustomDoc = class
  private
    type
      TForce = TVec2f;
      TContItemBase = TBinTreeTemplate<TDocItem, TForce>;
      PKindItemDescr = ^TKindItemDescr;
      TKindItemDescr = record
        ID: int32;
        ItemClass: TDocItemClass;
      end;
  strict private
    CounterChange: int32;
    class var DocItemNames: THashMap<AnsiString, PKindItemDescr>;
    class var DocItemClasses: TBinTreeTemplate<TDocItemClass, PKindItemDescr>;
    class var DocItemClassesList: TListVec<PKindItemDescr>;
  private
    FDocTree: TItemDocTree;
    FMaxWidth: BSFloat;
    FHeight: BSFloat;
    ContItem: TContItemBase;
    StackList: TDocItemList;
    StackListDelta: TListVec<TVec2f>;
    LoadEasyMode: boolean;
    FOnModified: TOnDocEvent;
    FModified: boolean;
    FOnDeleteItem: TItemEvent;
    FOnCreateItem: TItemEvent;
    Head: TSheetStyles;
    FDocSize: TVec2f;
    procedure OnLoadNode (Node: PItemDocTreeNode; Stream: TStream; SizeData: int32);
    procedure OnSaveNode (Node: PItemDocTreeNode; Stream: TStream);
    procedure OnDeleteNode (Node: PItemDocTreeNode);
    procedure OnCreateNode ({%H-}Node: PItemDocTreeNode);
    procedure SetMaxWidth(const Value: BSFloat);
    procedure ApplyChanges;
    procedure SetModified(const Value: boolean);
    { happens when a data hits in the "viewport" (area TBlackSharkMemo.ClipObject) }
    procedure OnHideData(Node: PNodeSpaceTree);
    { happens when a data leaves the "viewport" (area TBlackSharkMemo.ClipObject) }
    procedure OnShowData(Node: PNodeSpaceTree);
    { happens when scrolls the "viewport" above scrolled area }
    procedure OnUpdatePositionUserData(Node: PNodeSpaceTree);
    function GetClientSize: TVec2f;
  protected
    FSpaceTree: TBlackSharkSpaceTree;
    procedure SetDocSize(const Value: TVec2f); virtual;
    class procedure Init; virtual;
    class procedure Uninit; virtual;
  public
    { the constructor accept outside space tree }
    constructor Create(ASpaceTree: TBlackSharkSpaceTree);
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure BeginChangeRect;
    procedure EndChangeRect;

    class function RegisterDocItemClass(DocItemClass: TDocItemClass): boolean;
    class function GetDocItemClass(ClassName: AnsiString): TDocItemClass;
    class function GetDocItemClassID(DocItemClass: TDocItemClass): uint32;

    function CreateDocItem(Owner: TDocItem; ItemClass: TDocItemClass; LinkedNode: PItemDocTreeNode): TDocItem; overload;
    function CreateDocItem(Owner: TDocItem; const ItemClassName: AnsiString; LinkedNode: PItemDocTreeNode): TDocItem; overload;
    procedure DeleteDocItem(DocItem: TDocItem);

    function LoadResources(const FileName: string; EasyMode: boolean = true): boolean; overload;
    function LoadResources(Stream: TStream; EasyMode: boolean = true): boolean; overload;
    function SaveResources(const FileName: string): boolean; overload;
    function SaveResources(Stream: TStream): boolean; overload;

    function CanInsert(ToItem: TDocGraphicItem; const Position: TVec2f; const Size: TVec2f;
      CheckChild: boolean = true): boolean;
    function CanExtend(WidingItem: TDocGraphicItem; const Delta: TVec2f; out Barrier: TDocGraphicItem): boolean; overload;
    function CanExtend(const Rect: TRectBSf; const Delta: TVec2f; out Barrier: TDocGraphicItem): boolean; overload;
    function CanMove(Item: TDocGraphicItem; const Delta: TVec2f; MoveNow: boolean = true): boolean;
    function CanResize(Item: TDocGraphicItem; var SizeDelta: TVec2f): boolean;
    function CanFlowAround(Item: TDocGraphicItem; const Rect: TRectBSf): boolean;
    procedure UpdateInSpaceTree(Item: TDocGraphicItem); //virtual;
  public
    property MaxWidth: BSFloat read FMaxWidth write SetMaxWidth;
    property Height: BSFloat read FHeight;
    { The tree hierarchy a data of the document }
    property DocTree: TItemDocTree read FDocTree write FDocTree;
    { The tree hierarchy a data for spatial access in 2d }
    property SpaceTree: TBlackSharkSpaceTree read FSpaceTree;
    property Modified: boolean read FModified write SetModified;
    property OnModified: TOnDocEvent read FOnModified write FOnModified;
    property OnCreateItem: TItemEvent read FOnCreateItem write FOnCreateItem;
    property OnDeleteItem: TItemEvent read FOnDeleteItem write FOnDeleteItem;
    property ClientSize: TVec2f read GetClientSize;
    property DocSize: TVec2f read FDocSize write SetDocSize;
  end;

implementation

  uses math, bs.math, SysUtils, bs.strings;

{ translates the space tree box to 2d rect; note, we used for memo 2d, that is
  why the Box contains 2d props }

function BoxToRect(const Box: TBox3f): TRectBSf; inline;
begin
  Result.X := Box.Min.x;
  Result.Y := Box.Min.y;
  Result.Width := Box.Max.x - Box.Min.x;
  Result.Height := Box.Max.y - Box.Min.y;;
end;

{ TDocItem }

procedure TDocItem.AfterAddChildResource(Child: TDocItem);
begin
  if Node.Parent <> nil then
    Node.Parent.Data.AfterAddChildResource(Child);
end;

procedure TDocItem.AfterConstruction;
begin
  inherited;
end;

procedure TDocItem.BeforDelChildResource(Child: TDocItem);
begin
  if Node.Parent <> nil then
    Node.Parent.Data.BeforDelChildResource(Child);
end;

procedure TDocItem.BeforeDestruction;
begin
  inherited;

end;

procedure TDocItem.Build;
begin
  if Node.Parent <> nil then
    Node.Parent.Data.Build;

end;

constructor TDocItem.Create(ADoc: TBlackSharkCustomDoc; Owner: TDocItem);
begin
  FDoc := ADoc;
  //if Owner <> nil then
  //  Node := FDoc.FDocTree.CreateNode(Owner.Node, Self) else
  //  Node := FDoc.FDocTree.CreateNode(nil, Self);
end;

destructor TDocItem.Destroy;
begin
  if Node <> nil then
    FDoc.FDocTree.DeleteNode(Node, false, true);
  inherited;
end;

function TDocItem.GetParentSize: TVec2f;
var
  n: PItemDocTreeNode;
  h: TDocItem;
begin
  n := Node.Parent;
  Result := vec2(0.0, 0.0);
  while n <> nil do
    begin
    h := n.Data;
    if h is TDocGraphicItem then
      begin
      Result := TDocGraphicItem(h).Size;
      if (Result.x > 0) and (Result.y > 0) then
        break;
      end;
    n := Node.Parent;
    end;
end;

procedure TDocItem.Hide;
begin
  FVisible := false;
end;

procedure TDocItem.Load(const FromStream: TStream; const SizeData: int32);
begin
  //LoadBase(FromStream);
end;

function TDocItem.ParentClass(ParentClass: TDocItemClass): TDocItem;
var
  n: PItemDocTreeNode;
begin
  n := Node.Parent;
  while (n <> nil) do
    begin
    if n.Data is ParentClass then
      exit(n.Data);
    n := n.Parent;
    end;
  Result := nil;
end;

function TDocItem.ParentClassExists(ParentClass: TDocItemClass): boolean;
var
  n: PItemDocTreeNode;
begin
  n := Node.Parent;
  while (n <> nil) do
    begin
    if n.Data is ParentClass then
      exit(true);
    n := n.Parent;
    end;
  Result := false;
end;

procedure TDocItem.Save(const ToStream: TStream);
begin

end;

function TDocItem.Show(const ViewPort: TRectBSf): Pointer;
begin
  Result := nil;
  FVisible := true;
end;

{ TBlackSharkCustomDoc }

procedure TBlackSharkCustomDoc.Clear;
begin
  FSpaceTree.Clear;
  FDocTree.Clear;
end;

constructor TBlackSharkCustomDoc.Create(ASpaceTree: TBlackSharkSpaceTree);
begin
  Assert(ASpaceTree <> nil, 'The parameter ASpaceTree MUST be valid!');
  FDocTree := TItemDocTree.Create;
  FDocTree.OnSaveNode := OnSaveNode;
  FDocTree.OnLoadNode := OnLoadNode;
  FDocTree.OnDeleteNode := OnDeleteNode;
  FDocTree.OnCreateNode := OnCreateNode;
  FSpaceTree := ASpaceTree;
  FSpaceTree.OnShowUserData := OnShowData;
  FSpaceTree.OnHideUserData := OnHideData;
  FSpaceTree.OnUpdatePositionUserData := OnUpdatePositionUserData;
  StackList := TDocItemList.Create;
  ContItem := TContItemBase.Create(@PtrCmp);
  // Controllers := TContControllers.Create(@StrCmp);
  StackListDelta := TListVec<TVec2f>.Create;
end;

function TBlackSharkCustomDoc.CreateDocItem(Owner: TDocItem;
  const ItemClassName: AnsiString; LinkedNode: PItemDocTreeNode): TDocItem;
var
  it: PKindItemDescr;
begin
  it := DocItemNames.Find(ItemClassName);
  if (it <> nil) then
    Result := CreateDocItem(Owner, it.ItemClass, LinkedNode) else
    Result := nil;
end;

function TBlackSharkCustomDoc.CreateDocItem(Owner: TDocItem;
  ItemClass: TDocItemClass; LinkedNode: PItemDocTreeNode): TDocItem;
begin
  if Head = nil then
    begin
    Head := TSheetStyles.Create(Self, nil);
    Head.Node := FDocTree.CreateNode(nil, Head);
    end;

  if Owner <> nil then
    begin
    Result := ItemClass.Create(Self, Owner);
    if LinkedNode <> nil then
      Result.Node := LinkedNode else
      Result.Node := FDocTree.CreateNode(Owner.Node, Result);
    end else
    begin
    Result := ItemClass.Create(Self, Head);
    if LinkedNode <> nil then
      Result.Node := LinkedNode else
      Result.Node := FDocTree.CreateNode(Head.Node, Result);
    end;
end;

procedure TBlackSharkCustomDoc.DeleteDocItem(DocItem: TDocItem);
begin
  FDocTree.DeleteNode(DocItem.Node);
  DocItem.Node := nil;
end;

destructor TBlackSharkCustomDoc.Destroy;
begin
  Clear;
  FDocTree.Free;
  StackList.Free;
  ContItem.Free;
  {Controllers.Iterator.SetToBegin(c);
  while c <> nil do
    begin
    c.Free;
    Controllers.Iterator.Next(c);
    end;
  Controllers.Free;}
  StackListDelta.Free;
  inherited;
end;

procedure TBlackSharkCustomDoc.ApplyChanges;
begin

  ContItem.Clear;
end;

procedure TBlackSharkCustomDoc.BeginChangeRect;
begin
  inc(CounterChange);
end;

procedure TBlackSharkCustomDoc.EndChangeRect;
begin
  dec(CounterChange);
  if CounterChange < 0 then
    raise Exception.Create('The wrong sequence of actions!');
  if CounterChange = 0 then
    ApplyChanges;
end;

function TBlackSharkCustomDoc.GetClientSize: TVec2f;
begin
  Result := vec2(FSpaceTree.CurrentViewPort.x_max - FSpaceTree.CurrentViewPort.x_min,
    FSpaceTree.CurrentViewPort.y_max - FSpaceTree.CurrentViewPort.y_min);
end;

class function TBlackSharkCustomDoc.GetDocItemClass(ClassName: AnsiString): TDocItemClass;
var
  it: PKindItemDescr;
begin
  it := DocItemNames.Find(ClassName);
  if it <> nil then
    Result := it.ItemClass else
    Result := nil;
end;

class function TBlackSharkCustomDoc.GetDocItemClassID(DocItemClass: TDocItemClass): uint32;
var
  it: PKindItemDescr;
begin
  {$ifdef FPC}
  Result := 0;
  {$endif}
  DocItemClasses.Find(DocItemClass, it);
  if it <> nil then
    Result := it.ID else
    raise Exception.Create('Class is not registered!');
end;

class procedure TBlackSharkCustomDoc.Init;
begin
  DocItemNames := THashMap<AnsiString, PKindItemDescr>.Create(@GetHashSedgwickSA, @StrCmpBool);
  DocItemClasses := TBinTreeTemplate<TDocItemClass, PKindItemDescr>.Create(@PtrCmp);
  DocItemClassesList := TListVec<PKindItemDescr>.Create;
end;

function TBlackSharkCustomDoc.LoadResources(const FileName: string;
  EasyMode: boolean): boolean;
begin
  LoadEasyMode := EasyMode;
  Result := FDocTree.LoadFrom(FileName);
  FDocTree.Name := StringToWide(FileName);
end;

function TBlackSharkCustomDoc.LoadResources(Stream: TStream; EasyMode: boolean
  ): boolean;
begin
  LoadEasyMode := EasyMode;
  Result := FDocTree.LoadFrom(Stream);
end;

function TBlackSharkCustomDoc.SaveResources(const FileName: string): boolean;
begin
  FDocTree.Name := StringToWide(FileName);
  Result := FDocTree.SaveTo(FileName);
  FModified := false;
end;

function TBlackSharkCustomDoc.SaveResources(Stream: TStream): boolean;
begin
  Result := FDocTree.SaveTo(Stream);
end;

{
function TBlackSharkCustomDoc.GetController(ForItem: TDocItemClass): TControllerDoc;
begin
  Controllers.Find(ForItem.ControllerClass.ClassName, Result);
  if Result = nil then
    begin
    Result := ForItem.ControllerClass.Create(Self);
    Controllers.Add(ForItem.ControllerClass.ClassName, Result);
    end;
end;
}

procedure TBlackSharkCustomDoc.OnSaveNode(Node: PItemDocTreeNode;
  Stream: TStream);
var
  i: uint32;
  //t: int8;
begin
  i := GetDocItemClassID(TDocItemClass(Node.Data.ClassType));
  TValueEncoder.Write(Stream, i);
  i := length(Node.Data.FText);
  TValueEncoder.Write(Stream, i);
  if i > 0 then
    Stream.Write(Node.Data.FText[1], i*2);
  Node.Data.Save(Stream);
end;

procedure TBlackSharkCustomDoc.OnHideData(Node: PNodeSpaceTree);
begin
  TDocGraphicItem(Node.BB.TagPtr).Hide;
end;

procedure TBlackSharkCustomDoc.OnShowData(Node: PNodeSpaceTree);
var
  hr: TDocGraphicItem;
begin
  hr := Node.BB.TagPtr;
  hr._VisualData := hr.Show(BoxToRect(TBox3f(SpaceTree.CurrentViewPort)));
  hr.Build;
end;

procedure TBlackSharkCustomDoc.OnUpdatePositionUserData(Node: PNodeSpaceTree);
var
  hr: TDocGraphicItem;
begin
  hr := Node.BB.TagPtr;
  hr.UpdatePosition(BoxToRect(TBox3f(SpaceTree.CurrentViewPort)));
end;

procedure TBlackSharkCustomDoc.OnLoadNode(Node: PItemDocTreeNode;
  Stream: TStream; SizeData: int32);
var
  i: int32;
  //name: AnsiString;
  cit: TDocItemClass;
  it: TDocItem;
begin
  { read a kind resource }
  i := TValueDecoder.Read(Stream);
  if (Head <> nil) then
    cit := Head.GetStyleUsed(i) else
  if i <> 0 then
    raise Exception.Create('TODO') else
    cit := TSheetStyles;
  if Node.Parent <> nil then
    it := CreateDocItem(Node.Parent.Data, cit, Node) else
    it := CreateDocItem(nil, cit, Node);
  if (i = 0) then
    begin
    if Head <> nil then
      raise Exception.Create('TODO') else
      Head := TSheetStyles(it);
    end;
  i := TValueDecoder.Read(Stream);
  if i > 1 then
    begin
    SetLength(it.FText, i div 2);
    Stream.Read(it.FText[1], i);
    end;
  Node.Data := it;
  { to remember position resource in stream }
  //r.Position := Stream.Position - 5;
  //r.ID := id;
  //r.SizeData := SizeData;
  it.Load(Stream, SizeData);
  if Assigned(FOnCreateItem) then
    FOnCreateItem(it);
end;

class function TBlackSharkCustomDoc.RegisterDocItemClass(
  DocItemClass: TDocItemClass): boolean;
var
  it: PKindItemDescr;
begin
  if not DocItemClasses.Find(DocItemClass, it) then
    begin
    Result := true;
    new(it);
    it.ID := DocItemClassesList.Count;
    it.ItemClass := DocItemClass;
    DocItemNames.Add(StringToAnsi(DocItemClass.ClassName), it);
    DocItemClasses.Add(DocItemClass, it);
    DocItemClassesList.Add(it);
    end else
    Result := false;
end;

procedure TBlackSharkCustomDoc.OnDeleteNode(Node: PItemDocTreeNode);
begin
  if Assigned(FOnDeleteItem) then
    FOnDeleteItem(Node^.Data);
  if Node.Data = Head then
    Head := nil;
  Node.Data.Node := nil;
  Node.Data.Free;
end;

procedure TBlackSharkCustomDoc.OnCreateNode(Node: PItemDocTreeNode);
begin
  if Assigned(FOnCreateItem) then
    FOnCreateItem(Node^.Data);
  //if (FSelected = Node.Data) then
  //  FSelected := nil;
end;

procedure TBlackSharkCustomDoc.SetDocSize(const Value: TVec2f);
begin
  FDocSize := Value;
end;

procedure TBlackSharkCustomDoc.SetMaxWidth(const Value: BSFloat);
begin
  FMaxWidth := Value;
end;

procedure TBlackSharkCustomDoc.SetModified(const Value: boolean);
begin
  if FModified = Value then
    exit;
  FModified := Value;
  if Assigned(FOnModified) then
    FOnModified(Self);
end;

procedure TBlackSharkCustomDoc.UpdateInSpaceTree(Item: TDocGraphicItem);
begin
  if Item.FNodeInSpaceTree <> nil then
    Item.FNodeInSpaceTree := FSpaceTree.UpdatePosition(Item.FNodeInSpaceTree, Item.FRect.Position, Item.FRect.Size) else
    FSpaceTree.Add(Item, Item.FRect.Position, Item.FRect.Size, Item.FNodeInSpaceTree);
  FModified := true;
  if Assigned(FOnModified) then
    FOnModified(Self);
end;

function TBlackSharkCustomDoc.CanMove(Item: TDocGraphicItem;
  const Delta: TVec2f; MoveNow: boolean = true): boolean;
var
  r: TRectBSf;
  it: TDocGraphicItem;
  l: TListNodes;
  i: int32;
  val, dir: TVec2f;
  b: boolean;
begin
  ContItem.Clear;
  StackList.Count := 0;
  StackListDelta.Count := 0;
  StackList.Add(Item);
  StackListDelta.Add(Delta);
  while StackList.Count > 0 do
    begin
    it := StackList.Pop;
    dir := StackListDelta.Pop;
    r := it.FRect;
    //RectOffset(r, dir);
    { Check defined limits }
    if it.Fixed or not it.PositionTest(dir, false) then
      continue;
    if not ContItem.Find(it, val) then
      ContItem.Add(it, dir);
    for b := Low(boolean) to High(boolean) do
      begin
      if dir.xy[b] = 0.0 then
        continue;
      if b then
        begin
        r.Size := vec2(it.FRect.Width, abs(dir.Y));
        if dir.y < 0 then
          r.Position := vec2(it.FRect.X, it.FRect.Y + dir.y) else
          r.Position := vec2(it.FRect.X, it.FRect.Y + it.FRect.Height);
        end else
        begin
        r.Size := vec2(abs(dir.X), it.FRect.Height);
        if dir.X < 0 then
          r.Position := vec2(it.FRect.X + dir.X, it.FRect.Y);
          r.Position := vec2(it.FRect.X + it.FRect.Width, it.FRect.Y);
        end;
      l := nil;
      FSpaceTree.SelectData(r.X, r.Y, r.Width, r.Height, l);
      for i := 0 to l.Count - 1 do
        begin
        it := l.Items[i].BB.TagPtr;
        StackList.Add(it);
        dir := r.Position - it.FRect.Position;
        end;
      end;
    //delta.
    end;
  {if (abs(Delta.x) > abs(dir.x)) then
    Delta.x := dir.x;
  if (abs(Delta.y) > abs(dir.y)) then
    Delta.y := dir.y;}
  Result := true;
end;

function TBlackSharkCustomDoc.CanResize(Item: TDocGraphicItem;
  var SizeDelta: TVec2f): boolean;
begin
  { Check defined limits }
  if not Item.ResizeTest(SizeDelta) then
    exit(false);

  Result := true;
end;

function TBlackSharkCustomDoc.CanFlowAround(Item: TDocGraphicItem;
  const Rect: TRectBSf): boolean;
var
  ovr: TRectBSf;
  delta: TVec2f;
begin
  ovr := RectOverlap(Rect, Item.FRect);
  if ovr.Width < ovr.Height then
    delta := vec2(ovr.Width, 0.0) else
    delta := vec2(0.0, ovr.Width);
  if not CanMove(Item, delta) then
    exit(false);
  Result := true;
end;

class procedure TBlackSharkCustomDoc.Uninit;
var
  i: int32;
begin
  for i := 0 to DocItemClassesList.Count - 1 do
    dispose(DocItemClassesList.Items[i]);
  DocItemNames.Free;
  DocItemClasses.Free;
  DocItemClassesList.Free;
end;

function TBlackSharkCustomDoc.CanInsert(ToItem: TDocGraphicItem; const Position: TVec2f; const Size: TVec2f;
  CheckChild: boolean = true): boolean;
var
  r, ovr: TRectBSf;
  inside: boolean;
  l: TListNodes;
  i: int32;
  d: TDocGraphicItem;
  delta: TVec2f;
begin

  { prepare the rect for insert to inside of the Item }
  r.Size := Size;
  r.Position := Position;

  { check an overlap }
  ovr := RectOverlap(ToItem.FRect, r);

  { is r entirely ingested by Item (inside)? }
  inside := (ovr.Width = r.Width) and (ovr.Height = r.Height);
  if not CheckChild and inside then
    exit(true);

  if inside then
    begin
    { check overlap with other neighboring childs ToItem.Node.Parent }
    l := nil;
    FSpaceTree.SelectData(r.X, r.Y, r.Width, r.Height, l);
    for i := 0 to l.Count - 1 do
      begin
      d := l.Items[i].BB.TagPtr;
      if (d = ToItem) then // or (d.Node.Parent <> ToItem.Node.Parent)
        continue;
      if not CanMove(d, Position - d.FRect.Position) then
        begin
        exit(false);
        end;
      end;
    end else
    begin
    { check ToItem on a possibility to change a position or size }
    delta := Position - ToItem.FRect.Position;
    if (delta.x < 0) or (delta.y < 0) then
      begin
      delta.x := bs.math.min(0, delta.x);
      delta.y := bs.math.min(0, delta.y);
      if not CanMove(ToItem, delta) then
        exit(false);
      end;
    delta := Position + Size - ToItem.FRect.Size;
    if (delta.x > 0) or (delta.y > 0) then
      begin
      delta.x := bs.math.Max(0, delta.x);
      delta.y := bs.math.Max(0, delta.y);
      if not ToItem.ResizeTest(delta) then
        exit(false);
      end;
    FSpaceTree.SelectData(r.X, r.Y, r.Width, r.Height, l);
    for i := 0 to l.Count - 1 do
      begin
      d := l.Items[i].BB.TagPtr;
      if d = ToItem then
        continue;
      if not CanMove(d, size) then
        begin
        exit(false);
        end;
      end;
    end;
  Result := true;
end;

function TBlackSharkCustomDoc.CanExtend(WidingItem: TDocGraphicItem; const Delta: TVec2f;
  out Barrier: TDocGraphicItem): boolean;
begin
  Result := CanExtend(WidingItem.Rect, Delta, Barrier);
end;

function TBlackSharkCustomDoc.CanExtend(const Rect: TRectBSf;
  const Delta: TVec2f; out Barrier: TDocGraphicItem): boolean;
var
  r: TRectBSf;
  l: TListNodes;
  i: int32;
  j: boolean;
  d: TDocGraphicItem;
begin
  Barrier := nil;
  if FSpaceTree.Root = nil then
    exit(true);
  for j := low(boolean) to high(boolean) do
    begin
    if Delta.xy[j] = 0.0 then
      continue;
    { prepare the rect for to select hitting items }
    if j then
      begin
      r.Size := vec2(Rect.Width, abs(Delta.Y));
      if Delta.y < 0 then
        r.Position := vec2(Rect.X, Rect.Y + Delta.y) else
        r.Position := vec2(Rect.X, Rect.Y + Rect.Height);
      end else
      begin
      r.Size := vec2(abs(Delta.X), Rect.Height);
      if Delta.X < 0 then
        r.Position := vec2(Rect.X + Delta.X, Rect.Y);
        r.Position := vec2(Rect.X + Rect.Width, Rect.Y);
      end;
    { checks an overlap with other neighboring childs ToItem.Node.Parent }
    l := nil;
    FSpaceTree.SelectData(r.X, r.Y, r.Width, r.Height, l);
    for i := 0 to l.Count - 1 do
      begin
      d := l.Items[i].BB.TagPtr;
      if d.Fixed or not CanMove(d, r.Size, false) then
        begin
        Barrier := d;
        exit(false);
        end;
      end;
    end;
  Result := true;
end;

{ TDocGraphicItem }

procedure TDocGraphicItem.Build;
begin
  inherited;
  //FDoc.UpdateInSpaceTree(Self);
end;

constructor TDocGraphicItem.Create(ADoc: TBlackSharkCustomDoc;
  Parent: TDocItem);
begin
  inherited;
  FLimitWidth := vec2(1, MaxSingle);
  FLimitHeight := vec2(1, MaxSingle);
  FLimitPosX := vec2(0, MaxSingle);
  FLimitPosY := vec2(0, MaxSingle);
end;

procedure TDocGraphicItem.UpdatePosition(const ViewPort: TRectBSf);
begin

end;

function TDocGraphicItem.GetPosition: TVec2f;
begin
  Result := FRect.Position;
end;

function TDocGraphicItem.GetSize: TVec2f;
begin
  Result := FRect.Size;
end;

function TDocGraphicItem.PositionTest(var Delta: TVec2f; StrictTest: boolean = true): boolean;
var
  new_pos: TVec2f;
begin
  new_pos := FRect.Position + Delta;
  if StrictTest or FFixed then
    begin
    Result := (FLimitPosX.left <= new_pos.x) and (FLimitPosX.right >= new_pos.x) and
      (FLimitPosY.left <= new_pos.y) and (FLimitPosY.right >= new_pos.y);
    end else
    begin
    if new_pos.x < FLimitPosX.left then
      begin
      Delta.x := FRect.X - FLimitPosX.left;
      new_pos.x := FLimitPosX.left;
      end else
    if new_pos.x > FLimitPosX.right then
      begin
      Delta.x := FLimitPosX.right - FRect.X;
      new_pos.x := FLimitPosX.right;
      end;

    if new_pos.y < FLimitPosY.left then
      begin
      Delta.y := FRect.Y - FLimitPosY.left;
      new_pos.y := FLimitPosY.left;
      end else
    if new_pos.y > FLimitPosY.right then
      begin
      Delta.y := FLimitPosY.right - FRect.Y;
      new_pos.y := FLimitPosY.right;
      end;
    Result := not (new_pos = FRect.Position);
    end;
end;

function TDocGraphicItem.ResizeTest(var Delta: TVec2f; StrictTest: boolean = true): boolean;
var
  new_size: TVec2f;
begin
  new_size := FRect.Size + Delta;
  if StrictTest then
    begin
    Result := (FLimitWidth.left <= new_size.x) and (FLimitWidth.right >= new_size.x) and
      (FLimitHeight.left <= new_size.y) and (FLimitHeight.right >= new_size.y);
    end else
    begin
    if new_size.x < FLimitWidth.left then
      begin
      Delta.x := FRect.Width - FLimitWidth.left;
      new_size.x := FLimitWidth.left;
      end else
    if new_size.x > FLimitWidth.right then
      begin
      Delta.x := FLimitWidth.right - FRect.Width;
      new_size.x := FLimitWidth.right;
      end;

    if new_size.y < FLimitHeight.left then
      begin
      Delta.y := FRect.Height - FLimitHeight.left;
      new_size.y := FLimitHeight.left;
      end else
    if new_size.y > FLimitHeight.right then
      begin
      Delta.y := FLimitHeight.right - FRect.Height;
      new_size.y := FLimitHeight.right;
      end;
    Result := not (new_size = FRect.Size);
    end;
end;

procedure TDocGraphicItem.SetBanIntersectsChilds(const Value: boolean);
begin
  if FBanIntersectsChilds = Value then
    exit;
  FBanIntersectsChilds := Value;
end;

procedure TDocGraphicItem.SetLimitHeight(const Value: TVec2f);
begin
  if FLimitHeight = Value then
    exit;
  FLimitHeight := Value;
end;

procedure TDocGraphicItem.SetLimitPosX(const Value: TVec2f);
begin
  if FLimitPosX = Value then
    exit;
  FLimitPosX := Value;
end;

procedure TDocGraphicItem.SetLimitPosY(const Value: TVec2f);
begin
  if FLimitPosY = Value then
    exit;
  FLimitPosY := Value;
end;

procedure TDocGraphicItem.SetLimitWidth(const Value: TVec2f);
begin
  if FLimitWidth = Value then
    exit;
  FLimitWidth := Value;
end;

procedure TDocGraphicItem.SetPosition(const Value: TVec2f);
begin
  FRect.Position := Value;
  FDoc.UpdateInSpaceTree(Self);
  UpdatePosition(BoxToRect(TBox3f(FDoc.SpaceTree.CurrentViewPort)));
end;

procedure TDocGraphicItem.SetRect(const Value: TRectBSf);
begin
  FRect := Value;
  FDoc.UpdateInSpaceTree(Self);
  UpdatePosition(BoxToRect(TBox3f(FDoc.SpaceTree.CurrentViewPort)));
  //Build;
end;

procedure TDocGraphicItem.SetSize(const Value: TVec2f);
begin
  FRect.Size := Value;
  FDoc.UpdateInSpaceTree(Self);
  if Visible then
    Build;
end;

{ TSheetStyles }

procedure TSheetStyles.AfterAddChildResource(Child: TDocItem);
var
  id: uint32;
  kind: PUsedKindDescr;
begin
  inherited;
  id := FDoc.GetDocItemClassID(TDocItemClass(Child.ClassType));
  kind := CurrentStyles.Items[id];
  if kind = nil then
    begin
    new(kind);
    kind.id := id;
    kind.UsesInDoc := 1;
    kind.DocItemClass := TDocItemClass(Child.ClassType);
    CurrentStyles.Items[id] := kind;
    end else
    inc(kind.UsesInDoc);
end;

procedure TSheetStyles.BeforDelChildResource(Child: TDocItem);
var
  id: uint32;
  kind: PUsedKindDescr;
begin
  inherited;
  id := FDoc.GetDocItemClassID(TDocItemClass(Child.ClassType));
  kind := CurrentStyles.Items[id];
  if kind <> nil then
    begin
    dec(kind.UsesInDoc);
    if kind.UsesInDoc = 0 then
      begin
      CurrentStyles.Items[kind.id] := nil;
      dispose(kind);
      end;
    end;
end;

procedure TSheetStyles.ClearStyles;
var
  i: int32;
begin
  for i := 0 to CurrentStyles.Count - 1 do
    dispose(CurrentStyles.Items[i]);
  CurrentStyles.Count := 0;
end;

constructor TSheetStyles.Create(ADoc: TBlackSharkCustomDoc; Owner: TDocItem);
begin
  inherited;
  CurrentStyles := TListVec<PUsedKindDescr>.Create;
end;

destructor TSheetStyles.Destroy;
begin
  ClearStyles;
  CurrentStyles.Free;
  inherited;
end;

function TSheetStyles.GetStyleUsed(ID: int32): TDocItemClass;
var
  p: PUsedKindDescr;
begin
  p := CurrentStyles.Items[ID];
  if p <> nil then
    Result := p^.DocItemClass else
    Result := nil;
end;

procedure TSheetStyles.Load(const FromStream: TStream; const SizeData: int32);
begin
  inherited;

end;

procedure TSheetStyles.Save(const ToStream: TStream);
begin
  inherited;

end;

procedure TSheetStyles.UpdatePosition(const ViewPort: TRectBSf);
begin

end;

initialization
  TBlackSharkCustomDoc.Init;

finalization
  TBlackSharkCustomDoc.Uninit;

end.

