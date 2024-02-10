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


unit bs.gui.scheme.model;

{ container for data of a model }

{$I BlackSharkCfg.inc}

interface

uses
  classes,
  bs.basetypes,
  bs.events,
  bs.collections;

type

  TSchemeShape      = class;
  TSchemeLink       = class;
  TSchemeBlock      = class;
  TSchemeModel      = class;
  TSchemeShapeClass = class of TSchemeShape;

  TSchemeParser     = TVirtualTree<TSchemeShape>;
  TSchemeParserNode = TSchemeParser.PVirtualTreeNode;
  TListSchemeItems  = TListDual<TSchemeShape>;
  TMapSchemeItems   = TBinTreeTemplate<int32, TSchemeShape>;

  TSchemeShape = class
  private
    FParentLevel: TSchemeBlock;
    FWidth: int32;
    FID: int32;
    FView: TObject;
    FNumberLevel: UInt32;
    FCenter: TVec2i;
    FHeight: int32;
    FPosition: TVec2i;
    _PosInList: TListSchemeItems.PListItem;
    FTag: Pointer;
    function GetChildren(index: int32): TSchemeShape;
    function GetChildrenCount: int32;
    function GetLeft: int32;
    function GetParent: TSchemeShape;
    function GetTop: int32;
    procedure SetHeight(const Value: int32);
    procedure SetID(const Value: int32);
    procedure SetLeft(const Value: int32);
    procedure SetPosition(const Value: TVec2i);
    procedure SetTop(const Value: int32);
    procedure SetWidth(const Value: int32);
  protected
    FCaption: string;
    FNode: TSchemeParserNode;
    FSchemeModel: TSchemeModel;
    procedure Save(Stream: TStream); virtual;
    procedure Load(Stream: TStream; var SizeData: int32); virtual;
    procedure SetParent(const Value: TSchemeShape); virtual;
    procedure SetCaption(const Value: string); virtual;
    procedure CalcParentLevel;
    { only for load of shapes }
    {%H-}constructor Create(ToNode: TSchemeParserNode); overload;
  public
    { contains id of copied/coping shapes }
    CopyedItemID: int32;
  public
    constructor Create(AParent: TSchemeShape); overload; virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); virtual;
    procedure Resize(AWidth, AHeight: int32); overload;
    procedure Resize(NewSize: TVec2f); overload;
    class function FindParentLevel(Shape: TSchemeShape): TSchemeShape;
    class function GetDefaultSize: TVec2i; virtual; abstract;
    class function IsContainer: boolean; virtual;
    { reset CopyedItemID to -1 (useful, for example, for find out if a shape
      was copied from a source, so when shape is copied, to CopyedItemID writes
      id of copied/coping shapes }
    procedure ResetCopyedItemID;
    function IsAncestor(Ancestor: TSchemeShape): boolean;
    function GetRect: TRectBSi;

    property Parent: TSchemeShape read GetParent write SetParent;
    property ChildrenCount: int32 read GetChildrenCount;
    property Children[index: int32]: TSchemeShape read GetChildren;
    property Position: TVec2i read FPosition write SetPosition;
    property Width: int32 read FWidth write SetWidth;
    property Height: int32 read FHeight write SetHeight;
    property Left: int32 read GetLeft write SetLeft;
    property Top: int32 read GetTop write SetTop;
    property Caption: string read FCaption write SetCaption;
    property ParentLevel: TSchemeBlock read FParentLevel;
    property NumberLevel: UInt32 read FNumberLevel;
    property Center: TVec2i read FCenter;
    property SchemeModel: TSchemeModel read FSchemeModel;
    property ID: int32 read FID write SetID;
    property Tag: Pointer read FTag write FTag;
    property View: TObject read FView write FView;
  end;

  TSchemeLinkedShape = class;

  { Link b/w two shapes of type TSchemeLinkedShape; its Parent is shape "from" }

  TSchemeLink = class(TSchemeShape)
  private
    IDFrom: int32;
    IDTo: int32;
    FToLink: TSchemeLinkedShape;
    FNumOut: int32;

    procedure SetToLink(const Value: TSchemeLinkedShape);
    procedure SetNumOut(const Value: int32);
    function GetToLink: TSchemeLinkedShape;
  protected
    procedure SetParent(const Value: TSchemeShape); override;
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    destructor Destroy; override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    class function GetDefaultSize: TVec2i; override;
    property NumOut: integer read FNumOut write SetNumOut;
    property ToLink: TSchemeLinkedShape read GetToLink write SetToLink;
  end;

  { group of shapes }

  TSchemeRegion = class(TSchemeShape)
  protected
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    class function GetDefaultSize: TVec2i; override;
    class function IsContainer: boolean; override;
  end;

  { is base class for linked shapes }

  TSchemeLinkedShape = class(TSchemeShape)
  private
    function GetCountOutputs: int32;
    function GetOutput(Index: Int32): TSchemeLink;
  protected
    { links }
    FOutputs: TListVec<TSchemeLink>;
    procedure SetParent(const Value: TSchemeShape); override;
  public
    destructor Destroy; override;

    { create link (output) to ToItem }
    function AddOutput(Num: integer; ToItem: TSchemeLinkedShape): TSchemeLink; overload;
    procedure AddOutput(Link: TSchemeLink); overload; virtual;
    { delete link }
    procedure DeleteOutput(Link: TSchemeLink; FreeLink: boolean); virtual;
    function PossibleOutput(ToLink: TSchemeLinkedShape): boolean; virtual;
    function PossibleInput(FromLink: TSchemeLinkedShape): boolean; virtual;
    {
      !!! not all index may contain link, that is why need to check on nil; it
          was done intentionally, so Index pointing on link equal TSchemeLink.NumOut }
    property Output[Index: Int32]: TSchemeLink read GetOutput;
    { count of output links
      !!! the property points count of outputs but on reasons mentioned above
          it is not exact  }
    property CountOutputs: int32 read GetCountOutputs;
  end;

  { A some processor, a work horse }

  TSchemeProcessor = class(TSchemeLinkedShape)
  private
    FName: string;
  protected
    procedure SetParent(const Value: TSchemeShape); override;
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    destructor Destroy; override;
    function PossibleOutput(ToLink: TSchemeLinkedShape): boolean; override;
    class function GetDefaultSize: TVec2i; override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    property Name: string read FName write FName;
  end;

  TSchemeBlockLink = class(TSchemeLinkedShape)
  private
  public
    class function GetDefaultSize: TVec2i; override;
  end;

  { block's an input pin/leg }

  { TSchemeBlockLinkInput }

  TSchemeBlockLinkInput = class(TSchemeBlockLink)
  protected
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    destructor Destroy; override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    function PossibleOutput(ToLink: TSchemeLinkedShape): boolean; override;
    function PossibleInput(FromLink: TSchemeLinkedShape): boolean; override;
  end;

  { block's an output pin/leg }

  { TSchemeBlockLinkOutput }

  TSchemeBlockLinkOutput = class(TSchemeBlockLink)
  protected
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    procedure DeleteOutput(Link: TSchemeLink; FreeLink: boolean); override;
    procedure AddOutput(Link: TSchemeLink); override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    function PossibleOutput(ToLink: TSchemeLinkedShape): boolean; override;
    function PossibleInput(FromLink: TSchemeLinkedShape): boolean; override;
  end;

  { presents a level of scheme }

  TSchemeBlock = class(TSchemeLinkedShape)
  private
    procedure GetPath;
    function GetBlockLevel: int32;
  protected
    FPath: string;
    procedure DeleteOutLink(Link: TSchemeLink; FreeLink: boolean); virtual;
    procedure AddOutLink(Link: TSchemeLink); virtual;
    procedure SetCaption(const Value: string); override;
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
    procedure SetParent(const Value: TSchemeShape); override;
  public
    constructor Create(AParent: TSchemeShape); override;
    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    class function GetDefaultSize: TVec2i; override;
    class function IsContainer: boolean; override;
    property BlockLevel: int32 read GetBlockLevel;
    property Path: string read FPath;
  end;

  TModelState = (msNone, msLoading, msSaving, msRelease);

  TOnCreateShape = procedure(Shape: TSchemeShape) of object;
  TOnDeleteShape = TOnCreateShape;

  TSchemeModel = class(TSchemeBlock)
  private
    type
      TSchemClasses        = THashTable<AnsiString, TSchemeShapeClass>;
      TSchemClassesDicLoad = TBinTreeTemplate<int32, TSchemeShapeClass>;
      TSchemClassesDicSave = TBinTreeTemplate<TSchemeShapeClass, int32>;
  private
    FTree: TSchemeParser;
    FFileScheme: string;
    FModified: boolean;
    { dictionary of all shapes }
    FItems: TMapSchemeItems;
    FListItems: TListSchemeItems;
    Loading: boolean;

    LoadDic: TSchemClassesDicLoad;
    SaveDic: TSchemClassesDicSave;
    FOnDeleteShape: TOnDeleteShape;
    FOnCreateShape: TOnCreateShape;
    FAfterLoad: IBEmptyEvent;
    procedure SetModified(const Value: boolean);

    function GetCurrentID: int32;

    procedure OnNodeSave(Node: TSchemeParser.PVirtualTreeNode; Stream: TStream);
    procedure OnNodeLoad(Node: TSchemeParser.PVirtualTreeNode; Stream: TStream;
      SizeData: int32);
    procedure OnFreeNode(Node: TSchemeParser.PVirtualTreeNode);
    procedure FillDicSave;
    function Open(Stream: TStream): boolean; overload;
  private
    class var RegistredSchemeClasses: TSchemClasses;
    class constructor Create;
    class destructor Destroy;
  protected
    FModelState: TModelState;
    procedure OnDeleteSchemeItem(Shape: TSchemeShape; ListItem: TListSchemeItems.PListItem); virtual;
    function OnCreateSchemeItem(Shape: TSchemeShape): TListSchemeItems.PListItem; virtual;
    procedure OnChangeID(Shape: TSchemeShape; NewID: int32);
    procedure Save(Stream: TStream); override;
    procedure Load(Stream: TStream; var SizeData: int32); override;
  public
    constructor Create(AParent: TSchemeShape); overload; override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    class procedure RegisterSchemeClass(SchemeClass: TSchemeShapeClass);
    class function FindSchemeClass(const ClassName: Ansistring): TSchemeShapeClass;

    procedure Clear; virtual;

    { find shape by ID }
    function GetSchemeItemFromID(ID: int32): TSchemeShape;
    { delete Item from model }
    procedure DeleteSchemeItem(Item: TSchemeShape);
    { only for history - remove from scheme, but not Item;
      TODO: remove with children }
    procedure Remove(Item: TSchemeShape);

    function OpenScheme(const FileName: string): boolean; overload;
    function OpenScheme(Stream: TStream): boolean; overload;

    function SaveScheme(const FileName: string): boolean; overload;
    function SaveScheme(Stream: TStream): boolean; overload;

    procedure CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape); override;
    { insert scheme; return first inserted item }
    function PasteScheme(Source: TSchemeModel; const Position: TVec2i;
      Destination: TSchemeShape; ListAdded: TListVec<TSchemeShape>): TSchemeShape;

    function FindItem(InSource: TSchemeShape; ClassItem: TSchemeShapeClass;
      ExceptItem: TSchemeShape; const Rect: TRectBSf): TSchemeShape;

    function FindParentRegion(SchemeShape: TSchemeShape): TSchemeRegion;

    procedure DeleteEmptyChildSchemeRegions(SchemeShape: TSchemeShape;
      Exptn: TSchemeShape);

    { set all id to CopyedItemID, that is to source }
    procedure IdToSource;

    property Modified : boolean read FModified write SetModified;

    property CurrentID: int32 read GetCurrentID;
    property ListItems: TListSchemeItems read FListItems;
    property FileScheme: string read FFileScheme;
    property OnCreateShape: TOnCreateShape read FOnCreateShape write FOnCreateShape;
    property OnDeleteShape: TOnDeleteShape read FOnDeleteShape write FOnDeleteShape;
    property ModelState: TModelState read FModelState;
    property AfterLoad: IBEmptyEvent read FAfterLoad;
  end;

const
  SCHEME_VERSION = 0;
  // default size of processor
  DEF_PROCESSOR_WIDTH  = 100;
  DEF_PROCESSOR_HEIGHT = 40;
  MIN_SIZE_PROCESSOR   = 20;

  // default size of block
  DEF_BLOCK_WIDTH      = 100;
  DEF_BLOCK_HEIGHT     = 60;

  POINT_WIDTH          = 50;
  POINT_HEIGHT         = 20;

  REG_BORDER_WIDTH     = 10;


implementation

  uses SysUtils, bs.strings;

{ TSchemeShape }

procedure TSchemeShape.AfterConstruction;
begin
  inherited;
  if FSchemeModel <> nil then
    _PosInList := FSchemeModel.OnCreateSchemeItem(Self);
end;

procedure TSchemeShape.CalcParentLevel;
var
  i: int32;
begin
  FParentLevel := TSchemeBlock(FindParentLevel(Parent));
  for i := 0 to ChildrenCount - 1 do
    Children[i].CalcParentLevel;
end;

procedure TSchemeShape.CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape);
var
  i: int32;
  ch: TSchemeShape;
begin
  Result.FCaption := FCaption;
  Result.FHeight := FHeight;
  Result.FWidth := FWidth;
  Result.FPosition := FPosition;
  Result.FCenter := FCenter;
  if Prnt <> nil then
    Result.ID := Prnt.SchemeModel.CurrentID;
  Result.CopyedItemID := FID;
  CopyedItemID := Result.ID;
  for i := 0 to ChildrenCount - 1 do
    begin
    ch := nil;
    Children[i].CopyShape(ch, Result);
    end;
end;

constructor TSchemeShape.Create(ToNode: TSchemeParserNode);
begin
  FNode := ToNode;
  if (FNode <> nil) and (FNode.Parent <> nil) then
    Create(FNode.Parent.Data) else
    Create(TSchemeShape(nil));
end;

constructor TSchemeShape.Create(AParent: TSchemeShape);
begin
  FWidth := GetDefaultSize.x;
  FHeight := GetDefaultSize.y;
  FID := -1;
  CopyedItemID := -1;
  if AParent <> nil then
    begin
    FSchemeModel := AParent.FSchemeModel;
    if (FNode = nil) then
      FNode := FSchemeModel.FTree.CreateNode(AParent.FNode, Self);
    Parent := AParent;
    end;
end;

destructor TSchemeShape.Destroy;
begin
  if (FSchemeModel <> nil) and (_PosInList <> nil) then
    FSchemeModel.OnDeleteSchemeItem(Self, _PosInList);
end;

class function TSchemeShape.FindParentLevel(Shape: TSchemeShape): TSchemeShape;
begin
  Result := Shape;
  while Result <> nil do
    begin
    if (Result is TSchemeBlock) then
      exit;
    Result := Result.Parent;
    end;
end;

function TSchemeShape.GetChildren(index: int32): TSchemeShape;
begin
  if (FNode <> nil) and (FNode.Childs <> nil) then
    begin
    FNode.Childs.Cursor := index;
    if FNode.Childs.UnderCursorItem <> nil then
      Result := FNode.Childs.UnderCursorItem.Item.Data else
      Result := nil;
    end else
    Result := nil;
end;

function TSchemeShape.GetChildrenCount: int32;
begin
  if (FNode <> nil) and (FNode.Childs <> nil) then
    Result := FNode.Childs.Count else
    Result := 0;
end;

function TSchemeShape.GetLeft: int32;
begin
  Result := FPosition.X;
end;

function TSchemeShape.GetParent: TSchemeShape;
begin
  if (FNode <> nil) and (FNode.Parent <> nil) then
    Result := FNode.Parent.Data else
    Result := nil;
end;

function TSchemeShape.GetRect: TRectBSi;
begin
  Result.Left := FPosition.X;
  Result.Top := FPosition.Y;
  Result.Width := FWidth;
  Result.Height := FHeight;
end;

function TSchemeShape.GetTop: int32;
begin
  Result := FPosition.Y;
end;

function TSchemeShape.IsAncestor(Ancestor: TSchemeShape): boolean;
var
  prnt: TSchemeShape;
begin
  prnt := Parent;
  while (prnt <> nil) do
    begin
    if prnt = Ancestor then
      exit(true);
    prnt := prnt.Parent;
    end;
  Result := false;
end;

class function TSchemeShape.IsContainer: boolean;
begin
  Result := false;
end;

procedure TSchemeShape.Load(Stream: TStream; var SizeData: int32);
var
  l: int32;
  s: WideString;
  _id: int32;
begin
  Stream.Read(l{%H-}, 4);
  if l > 0 then
  begin
    s := '';
    SetLength(s, l shr 1);
    if Stream.Read(s[1], l) = l then
      FCaption := WideToString(s);
  end;
  Stream.Read(_id{%H-}, 4);
  Stream.Read(FWidth, 4);
  Stream.Read(FHeight, 4);
  Stream.Read(FPosition, SizeOf(FPosition));
  FCenter := vec2(FPosition.x + FWidth shr 1, FPosition.y + FHeight shr 1);
  ID := _id;
end;

procedure TSchemeShape.ResetCopyedItemID;
var
  i: int32;
begin
  CopyedItemID := -1;
  for i := 0 to ChildrenCount - 1 do
    Children[i].ResetCopyedItemID;
end;

procedure TSchemeShape.Resize(NewSize: TVec2f);
begin
  Resize(round(NewSize.x), round(NewSize.y));
end;

procedure TSchemeShape.Resize(AWidth, AHeight: int32);
begin
  if (AWidth = 0) or (AHeight = 0) then
    raise Exception.Create('Error Message');
  FWidth := AWidth;
  FHeight := AHeight;
  FCenter := vec2(FPosition.x + FWidth shr 1, FPosition.y + FHeight shr 1);
end;

procedure TSchemeShape.Save(Stream: TStream);
var
  l: int32;
  s: WideString;
begin
  s := StringToWide(FCaption);
  l := Length(s) shl 1;
  Stream.Write(l, 4);
  if l > 0 then
    Stream.Write(s[1], l);
  Stream.Write(FID, 4);
  Stream.Write(FWidth, 4);
  Stream.Write(FHeight, 4);
  Stream.Write(FPosition, SizeOf(FPosition));
end;

procedure TSchemeShape.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TSchemeShape.SetHeight(const Value: int32);
begin
  FHeight := Value;
end;

procedure TSchemeShape.SetID(const Value: int32);
begin
  FSchemeModel.OnChangeID(Self, Value);
  FID := Value;
end;

procedure TSchemeShape.SetLeft(const Value: int32);
begin
  Position := vec2(Value, FPosition.y);
end;

procedure TSchemeShape.SetParent(const Value: TSchemeShape);
begin
  FParentLevel := nil;
  if Value <> nil then
    begin
    FSchemeModel.FTree.SetNodeParent(FNode, Value.FNode);
    CalcParentLevel;
    end else
  if FSchemeModel <> nil then
    FSchemeModel.FTree.SetNodeParent(FNode, nil);
end;

procedure TSchemeShape.SetPosition(const Value: TVec2i);
begin
  FPosition := Value;
  FCenter := vec2(FPosition.x + FWidth shr 1, FPosition.y + FHeight shr 1);
end;

procedure TSchemeShape.SetTop(const Value: int32);
begin
  Position := vec2(FPosition.x, Value);
end;

procedure TSchemeShape.SetWidth(const Value: int32);
begin
  FWidth := Value;
end;

{ TSchemeLinkedShape }

function TSchemeLinkedShape.AddOutput(Num: integer; ToItem: TSchemeLinkedShape): TSchemeLink;
begin
  Result := TSchemeLink.Create(Self);
  Result.NumOut := Num;
  Result.ToLink := ToItem;
  AddOutput(Result);
end;

procedure TSchemeLinkedShape.AddOutput(Link: TSchemeLink);
begin
  if (FOutputs <> nil) and (FOutputs.Items[Link.NumOut] <> nil) then
    DeleteOutPut(FOutputs.Items[Link.NumOut], true);

  if FOutputs = nil then
    FOutputs := TListVec<TSchemeLink>.Create(@PtrCmp);

  FOutputs.Items[Link.NumOut] := Link;
end;

procedure TSchemeLinkedShape.DeleteOutput(Link: TSchemeLink; FreeLink: boolean);
begin
  if (FOutPuts <> nil) then
    begin
    if FOutPuts.Items[Link.NumOut] <> Link then
      FOutPuts.Remove(Link) else
      FOutPuts.Items[Link.NumOut] := nil;
    { remove all empty links in end }
    while (FOutPuts.Count > 0) and (FOutPuts.Items[FOutPuts.Count - 1] = nil) do
      FOutPuts.Pop;
    if FOutPuts.Count = 0 then
      FreeAndNil(FOutPuts);
    if FreeLink then
      Link.Free;
    end;
end;

destructor TSchemeLinkedShape.Destroy;
begin
  FreeAndNil(FOutPuts);
  inherited;
end;

function TSchemeLinkedShape.GetCountOutputs: int32;
begin
  if (FOutPuts <> nil) then
    Result := FOutPuts.Count else
    Result := 0;
end;

function TSchemeLinkedShape.GetOutput(Index: Int32): TSchemeLink;
begin
  if (FOutPuts <> nil) then
    Result := FOutPuts.Items[Index] else
    Result := nil;
end;

function TSchemeLinkedShape.PossibleInput(FromLink: TSchemeLinkedShape): boolean;
begin
  Result := (ParentLevel = FromLink.ParentLevel);
end;

function TSchemeLinkedShape.PossibleOutput(ToLink: TSchemeLinkedShape): boolean;
begin
  Result := (ParentLevel = ToLink.ParentLevel);
end;

procedure TSchemeLinkedShape.SetParent(const Value: TSchemeShape);
begin
  inherited;
end;

{ TSchemeModel }

procedure TSchemeModel.AfterConstruction;
begin
  inherited;
  FSchemeModel := Self;
end;

procedure TSchemeModel.Clear;
begin
  FTree.ClearNodeChilds(FNode);
  FFileScheme := '';
end;

procedure TSchemeModel.CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeModel.Create(Prnt);
  inherited;
end;

constructor TSchemeModel.Create(AParent: TSchemeShape);
begin
  inherited Create(TSchemeShape(nil));
  FAfterLoad := CreateEmptyEvent(nil);
  FItems := TMapSchemeItems.Create(@Int32cmp);
  FListItems := TListSchemeItems.Create;
  Caption := 'Scheme';
  FTree := TSchemeParser.Create;
  FTree.Version := SCHEME_VERSION;
  FTree.OnSaveNode := OnNodeSave;
  FTree.OnLoadNode := OnNodeLoad;
  FTree.OnDeleteNode := OnFreeNode;
  FNode := FTree.CreateNode(nil, Self);
end;

class constructor TSchemeModel.Create;
begin
  RegistredSchemeClasses := TSchemClasses.Create(@GetHashBlackSharkS, @StrCmpBool);
end;

procedure TSchemeModel.DeleteEmptyChildSchemeRegions(SchemeShape: TSchemeShape;
  Exptn: TSchemeShape);
var
  it, next: TSchemeParser.TListVirtualNodes.PListItem;
begin
  if SchemeShape.FNode.Childs <> nil then
    begin
    it := SchemeShape.FNode.Childs.ItemListFirst;
    while it <> nil do
      begin
      next := it.Next;
      if (Exptn <> it.Item.Data) and (it.Item.Data is TSchemeRegion) and (it.Item.Data.ChildrenCount = 0) then
        it.Item.Data.Free;
      it := next;
      end;
    end;
end;

procedure TSchemeModel.DeleteSchemeItem(Item: TSchemeShape);
begin
  Item.Free;
end;

class destructor TSchemeModel.Destroy;
begin
  RegistredSchemeClasses.Free;
end;

destructor TSchemeModel.Destroy;
begin
  FModelState := msRelease;
  FTree.Free;
  FAfterLoad := nil;
  inherited;
  FItems.Free;
  FListItems.Destroy;
end;

procedure TSchemeModel.FillDicSave;
var
  cl_id: int32;
  cl_sh: TSchemClasses.TBucket;
begin
  { fill dictionary classes; 0 is always TSchemeModel }
  SaveDic.Add(TSchemeModel, 0);
  cl_id := 1;
  if RegistredSchemeClasses.GetFirst(cl_sh) then
  repeat
    SaveDic.Add(cl_sh.Value, cl_id);
    inc(cl_id);
  until not RegistredSchemeClasses.GetNext(cl_sh);
end;

function TSchemeModel.FindItem(InSource: TSchemeShape;
  ClassItem: TSchemeShapeClass; ExceptItem: TSchemeShape;
  const Rect: TRectBSf): TSchemeShape;
var
  i: int32;
  it: TSchemeShape;
begin
  for i := 0 to InSource.ChildrenCount - 1 do
    begin
    it := InSource.Children[i];
    if not (it is ClassItem) or (ExceptItem = it) then
      continue;
    if (it.Position.x <= Rect.x) and (it.Position.y <= Rect.y) and
      (it.Position.x + it.Width <= Rect.x + Rect.Width) and
        (it.Position.y + it.Height <= Rect.y + Rect.Height) then
          exit(it);
    end;
  Result := nil;
end;

function TSchemeModel.FindParentRegion(SchemeShape: TSchemeShape): TSchemeRegion;
var
  it: TSchemeShape;
begin
  it := SchemeShape.Parent;
  while it <> nil do
    begin
    if it is TSchemeRegion then
      exit(TSchemeRegion(it));
    it := it.Parent;
    end;
  Result := nil;
end;

class function TSchemeModel.FindSchemeClass(
  const ClassName: Ansistring): TSchemeShapeClass;
begin
  RegistredSchemeClasses.Find(ClassName, Result);
end;

function TSchemeModel.GetCurrentID: int32;
var
  it: TSchemeShape;
begin
  Result := FItems.Count;
  while FItems.Find(Result, it) do
    inc(Result);
end;

function TSchemeModel.GetSchemeItemFromID(ID: int32): TSchemeShape;
begin
  FItems.Find(ID, Result);
end;

procedure TSchemeModel.IdToSource;

  procedure IDToSrc(Item: TSchemeShape);
  var
    i: int32;
    it: TSchemeShape;
  begin
  for i := 0 to Item.ChildrenCount - 1 do
    begin
    it := Item.Children[i];
    if it.CopyedItemID >= 0 then
      begin
      it.ID := it.CopyedItemID;
      end;
    IDToSrc(it);
    end;
  end;

  procedure IDAss(Item: TSchemeShape);
  var
    i: int32;
    it: TSchemeShape;
  begin
  for i := 0 to Item.ChildrenCount - 1 do
    begin
    it := Item.Children[i];
    if it.CopyedItemID < 0 then
      it.ID := CurrentID;
    IDToSrc(it);
    end;
  end;

begin
  FItems.Clear;
  { take ID a source }
  IDToSrc(Self);
  { assign ID where it has not }
  IDAss(Self);
end;

procedure TSchemeModel.Load(Stream: TStream; var SizeData: int32);
var
  count: int32;
  cl_id: int32;
  cl_sh: TSchemeShapeClass;
  l: int32;
  n: Ansistring;
begin
  Stream.Read(count{%H-}, 4);
  dec(SizeData, 4);
  while (count > 0) and (SizeData > 0) do
  begin
    dec(count);
    { id }
    Stream.Read(cl_id{%H-}, 4);
    { len name }
    Stream.Read(l{%H-}, 4);
    { name }
    n := '';
    SetLength(n, l);
    Stream.Read(n[1], l);
    dec(SizeData, l + 8);
    if RegistredSchemeClasses.Find(n, cl_sh) then
      LoadDic.Add(cl_id, cl_sh);
  end;
  inherited Load(Stream, SizeData);
end;

procedure TSchemeModel.OnChangeID(Shape: TSchemeShape; NewID: int32);
var
  i: TSchemeShape;
begin
  if (NewID < 0) or FItems.Find(NewID, i) then
    exit;
  if FItems.Find(Shape.ID, i) and (Shape = i) then
    FItems.Remove(Shape.ID);
  FItems.Add(NewID, Shape);
end;

function TSchemeModel.OnCreateSchemeItem(
  Shape: TSchemeShape): TListSchemeItems.PListItem;
begin
  if Shape <> Self then
    begin
    Result := FListItems.PushToEnd(Shape);
    if not (Loading) then
      begin
      Shape.ID := CurrentID;
      end;
    if Assigned(FOnCreateShape) then
      FOnCreateShape(Shape);
    end else
    Result := nil;
end;

procedure TSchemeModel.OnDeleteSchemeItem(Shape: TSchemeShape;
  ListItem: TListSchemeItems.PListItem);
var
  n: TSchemeParserNode;
begin
  FListItems.Remove(ListItem);
  FItems.Remove(Shape.ID);
  if Shape.FNode <> nil then
    begin
    n := Shape.FNode;
    Shape.FNode := nil;
    FTree.DeleteNode(n, true, false);
    end;

  if (Shape <> Self) and Assigned(FOnDeleteShape) then
    FOnDeleteShape(Shape);
end;

procedure TSchemeModel.OnFreeNode(Node: TSchemeParser.PVirtualTreeNode);
begin
  if Node.Data = Self then
    exit;
  { the Node is free by FTree.Clear, otherewise outside by user }
  if Node.Data.FNode <> nil then
    begin
    Node.Data.FNode := nil;
    FreeAndNil(Node.Data);
    end;
end;

procedure TSchemeModel.OnNodeLoad(Node: TSchemeParser.PVirtualTreeNode;
  Stream: TStream; SizeData: int32);
var
  id: int32;
  cl_sh: TSchemeShapeClass;
  sh: TSchemeShape;
  sz: int32;
begin
  Stream.Read(id{%H-}, 4);
  sz := SizeData - 4;
  if id > 0 then
    begin
    if LoadDic.Find(id, cl_sh) then
      begin
      sh := cl_sh.Create(Node);
      Node.Data := sh;
      sh.Load(Stream, sz);
      end else
      begin
      { TODO: empty shape, or exception??? }
      end;
    end else { load root }
    begin
    FNode := Node;
    FNode.Data := Self;
    Load(Stream, sz);
    end;
end;

procedure TSchemeModel.OnNodeSave(Node: TSchemeParser.PVirtualTreeNode;
  Stream: TStream);
var
  cl_id: int32;
begin
  if SaveDic.Find(TSchemeShapeClass(Node.Data.ClassType), cl_id) then
    begin
    Stream.Write(cl_id, 4);
    Node.Data.Save(Stream);
    end else
    raise Exception.Create('Have not found class of the shape!');
end;

function TSchemeModel.OpenScheme(const FileName: string): boolean;
var
  f: TFileStream;
begin
  try
    f := TFileStream.Create(FileName, fmOpenRead);
    try
      Result := Open(f);
    finally
      f.Free;
    end;
  except
    exit(false);
  end;
  FCaption := ChangeFileExt(ExtractFileName(FileName), '');
  FFileScheme := FileName;
end;

function TSchemeModel.Open(Stream: TStream): boolean;
begin
  FModelState := msLoading;
  try
    Clear;
    LoadDic := TSchemClassesDicLoad.Create(Int32cmp);
    Loading := true;
    try
      Result := FTree.LoadFrom(Stream);
    finally
      Loading := false;
      FreeAndNil(LoadDic);
    end;
  finally
    FModelState := msNone;
  end;
end;

function TSchemeModel.OpenScheme(Stream: TStream): boolean;
begin
  Result := Open(Stream);
end;

function TSchemeModel.PasteScheme(Source: TSchemeModel; const Position: TVec2i;
  Destination: TSchemeShape; ListAdded: TListVec<TSchemeShape>): TSchemeShape;
var
  i: int32;
  it: TSchemeShape;
begin

  if (Source.ChildrenCount = 0) then
    exit(nil);

  Result := nil;

  // TODO: have not tested
  for i := 0 to Source.ChildrenCount - 1 do
  begin
    it := Source.Children[i];
    Result := nil;

    it.CopyShape(Result, Destination);

    ListAdded.Add(Result);

    Result.Left := Position.X + (it.Left - Source.Left);
    Result.Top := Position.Y + (it.Top - Source.Top);
  end;

end;

class procedure TSchemeModel.RegisterSchemeClass(SchemeClass: TSchemeShapeClass);
var
  n: AnsiString;
begin
  n := StringToAnsi(SchemeClass.ClassName);
  if not RegistredSchemeClasses.Exists(n) then
    RegistredSchemeClasses.Items[n] := SchemeClass;
end;

procedure TSchemeModel.Remove(Item: TSchemeShape);
begin
  OnDeleteSchemeItem(Item, Item._PosInList);
end;

procedure TSchemeModel.Save(Stream: TStream);
var
  cl_id: int32;
  l: int32;
  cl_name: AnsiString;
begin
  { save dictionary of shape classes }
  l := SaveDic.Count;
  Stream.Write(l, 4);
  if SaveDic.Iterator.SetToBegin(cl_id) then
    repeat
    { id }
    Stream.Write(cl_id, 4);
    cl_name := StringToAnsi(SaveDic.Iterator.CurrentNode.Key.ClassName);
    l := length(cl_name);
    { len name }
    Stream.Write(l, 4);
    { name }
    Stream.Write(cl_name[1], l);
    until not SaveDic.Iterator.Next(cl_id);
  inherited;
end;

function TSchemeModel.SaveScheme(Stream: TStream): boolean;
begin
  FModelState := msSaving;
  try
    SaveDic := TSchemClassesDicSave.Create(@ptrCmp);
    try
      FillDicSave;
      Result := FTree.SaveTo(Stream);
    finally
      FreeAndNil(SaveDic);
    end;
  finally
    FModelState := msNone;
  end;
end;

function TSchemeModel.SaveScheme(const FileName: string): boolean;
begin
  FModelState := msSaving;
  try
    FFileScheme := FileName;
    SaveDic := TSchemClassesDicSave.Create(@ptrCmp);
    try
      FillDicSave;
      Result := FTree.SaveTo(FileName);
    finally
      FreeAndNil(SaveDic);
    end;
  finally
    FModelState := msNone;
  end;
end;

procedure TSchemeModel.SetModified(const Value: boolean);
begin
  FModified := Value;
end;

{ TSchemeLink }

procedure TSchemeLink.CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeLink.Create(Prnt);
  TSchemeLink(Result).Parent := Parent;
  TSchemeLink(Result).IDFrom := IDFrom;
  TSchemeLink(Result).IDTo := IDTo;
  TSchemeLink(Result).NumOut := FNumOut;
  inherited;
end;

constructor TSchemeLink.Create(AParent: TSchemeShape);
begin
  inherited;
  IDFrom := -1;
  IDTo := -1;
  FNumOut := -1;
  if AParent <> nil then
    IDFrom := AParent.ID;
end;

destructor TSchemeLink.Destroy;
begin
  //TSchemeLinkedShape(Parent).DeleteOutput(Self, false);
  inherited;
end;

class function TSchemeLink.GetDefaultSize: TVec2i;
begin
  Result := vec2(10, 10);
end;

function TSchemeLink.GetToLink: TSchemeLinkedShape;
var
  sh: TSchemeShape;
begin
  if FToLink = nil then
    begin
    if IDTo < 0 then
      exit(nil);
    sh := FSchemeModel.GetSchemeItemFromID(IDTo);
    if not (sh is TSchemeLinkedShape) then
      raise Exception.Create('TSchemeLinkedShape has not found! (ID = ' + IntToStr(IDTo) + ')');
    FToLink := TSchemeLinkedShape(sh);
    if FToLink = nil then
      exit(nil);
    end;
  Result := FToLink;
end;

procedure TSchemeLink.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;
  Stream.Read(IDFrom, 4);
  Stream.Read(IDTo, 4);
  Stream.Read(FNumOut, 4);
  if FNumOut < 0 then
    FCaption := '' else
    FCaption := IntToStr(FNumOut);
  TSchemeLinkedShape(Parent).AddOutput(Self);
end;

procedure TSchemeLink.Save(Stream: TStream);
begin
  inherited;
  Stream.Write(IDFrom, 4);
  Stream.Write(IDTo, 4);
  Stream.Write(FNumOut, 4);
end;

procedure TSchemeLink.SetNumOut(const Value: int32);
begin
  FNumOut := Value;
  if FNumOut < 0 then
    FCaption := '' else
    FCaption := IntToStr(FNumOut);
end;

procedure TSchemeLink.SetParent(const Value: TSchemeShape);
begin
  inherited;
  if Value <> nil then
    IDFrom := Value.ID else
    raise Exception.Create('Error Message');
end;

procedure TSchemeLink.SetToLink(const Value: TSchemeLinkedShape);
begin
  FToLink := Value;
  if FToLink <> nil then
    IDTo := FToLink.ID else
    IDTo := -1;
end;

{ TSchemeRegion }

procedure TSchemeRegion.CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeRegion.Create(Prnt);
  inherited;
end;

constructor TSchemeRegion.Create(AParent: TSchemeShape);
begin
  inherited;
  FCaption := 'Group';
end;

class function TSchemeRegion.GetDefaultSize: TVec2i;
begin
  Result := vec2(BSInt(DEF_BLOCK_WIDTH shl 1), BSInt(DEF_BLOCK_WIDTH shl 1));
end;

class function TSchemeRegion.IsContainer: boolean;
begin
  Result := true;
end;

procedure TSchemeRegion.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;

end;

procedure TSchemeRegion.Save(Stream: TStream);
begin
  inherited;

end;

{ TSchemeBlockLinkOutput }

procedure TSchemeBlockLinkOutput.AddOutput(Link: TSchemeLink);
begin
  inherited;
  ParentLevel.AddOutLink(Link);
end;

procedure TSchemeBlockLinkOutput.CopyShape(var Result: TSchemeShape;
  Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeBlockLinkOutput.Create(Prnt);
  inherited;
end;

procedure TSchemeBlockLinkOutput.DeleteOutput(Link: TSchemeLink; FreeLink: boolean);
begin
  if Link <> nil then
    ParentLevel.DeleteOutLink(Link, FreeLink);
  inherited;
end;

procedure TSchemeBlockLinkOutput.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;

end;

constructor TSchemeBlockLinkOutput.Create(AParent: TSchemeShape);
begin
  inherited Create(AParent);
  FCaption := 'Output from the block';
end;

function TSchemeBlockLinkOutput.PossibleInput(FromLink: TSchemeLinkedShape): boolean;
begin
  Result := inherited PossibleInput(FromLink);
  if not Result then
    begin
    if (FromLink is TSchemeBlockLinkOutput) then
      Result := FParentLevel = FromLink.ParentLevel.ParentLevel;
    end;
end;

function TSchemeBlockLinkOutput.PossibleOutput(ToLink: TSchemeLinkedShape): boolean;
begin
  Result := not inherited;
  if Result then
    begin
    { from the output block A to a input (ToLink) block B which is on the same level ??? }
    Result := (ToLink is TSchemeBlockLinkInput) and (FParentLevel.ParentLevel = ToLink.ParentLevel.ParentLevel);
    if not Result then
      begin
      Result := FParentLevel.ParentLevel = ToLink.ParentLevel;
      end;
    end;
end;

procedure TSchemeBlockLinkOutput.Save(Stream: TStream);
begin
  inherited;

end;

{ TSchemeBlockLinkInput }

procedure TSchemeBlockLinkInput.CopyShape(var Result: TSchemeShape;
  Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeBlockLinkInput.Create(Prnt);
  inherited;
end;

destructor TSchemeBlockLinkInput.Destroy;
begin

  inherited;
end;

procedure TSchemeBlockLinkInput.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;

end;

constructor TSchemeBlockLinkInput.Create(AParent: TSchemeShape);
begin
  inherited Create(AParent);
  FCaption := 'Input to the block';
end;

function TSchemeBlockLinkInput.PossibleInput(
  FromLink: TSchemeLinkedShape): boolean;
begin
  Result := not inherited;
  if Result then
    begin
    Result := (FParentLevel.ParentLevel = FromLink.ParentLevel);
    if not Result then
      Result := (FromLink is TSchemeBlockLinkOutput) and (FParentLevel.ParentLevel = FromLink.ParentLevel.ParentLevel);
    end;
end;

function TSchemeBlockLinkInput.PossibleOutput(ToLink: TSchemeLinkedShape): boolean;
begin
  Result := inherited;
  if not Result then
    begin
    { from the output block A to a input (ToLink) block B which is on the same level ??? }
    Result := (ToLink is TSchemeBlockLinkInput) and (FParentLevel = ToLink.ParentLevel.ParentLevel);
    end;
end;

procedure TSchemeBlockLinkInput.Save(Stream: TStream);
begin
  inherited;

end;

{ TSchemeBlockLink }

class function TSchemeBlockLink.GetDefaultSize: TVec2i;
begin
  Result := vec2(POINT_WIDTH, POINT_HEIGHT);
end;

{ TSchemeProcessor }

procedure TSchemeProcessor.CopyShape(var Result: TSchemeShape;
  Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeProcessor.Create(Prnt);
  inherited;

end;

constructor TSchemeProcessor.Create(AParent: TSchemeShape);
begin
  inherited;
  FCaption := 'Processor';
end;

destructor TSchemeProcessor.Destroy;
begin

  inherited;
end;

class function TSchemeProcessor.GetDefaultSize: TVec2i;
begin
  Result := vec2(DEF_PROCESSOR_WIDTH, DEF_PROCESSOR_HEIGHT);
end;

procedure TSchemeProcessor.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;

end;

function TSchemeProcessor.PossibleOutput(ToLink: TSchemeLinkedShape): boolean;
begin
  Result := ToLink.PossibleInput(Self);
end;

procedure TSchemeProcessor.Save(Stream: TStream);
begin
  inherited;

end;

procedure TSchemeProcessor.SetParent(const Value: TSchemeShape);
{var
  i: int32;
  l: TSchemeLink; }
begin
  inherited;
  {for i := CountOutputs - 1 downto 0 do
    begin
    l := Output[i];
    if l = nil then
      continue;
    if (l.ToLink <> nil) and (l.ToLink.ParentLevel <> ParentLevel) then
      DeleteOutput(l);
    end; }
end;

{ TSchemeBlock }

procedure TSchemeBlock.AddOutLink(Link: TSchemeLink);
begin
  if FOutPuts = nil then
    FOutPuts := TListVec<TSchemeLink>.Create(@PtrCmp);
  FOutPuts.Add(Link);
end;

procedure TSchemeBlock.CopyShape(var Result: TSchemeShape; Prnt: TSchemeShape);
begin
  if Result = nil then
    Result := TSchemeBlock.Create(Prnt);
  inherited;
end;

constructor TSchemeBlock.Create(AParent: TSchemeShape);
begin
  inherited;
  FCaption := 'Block';
end;

procedure TSchemeBlock.DeleteOutLink(Link: TSchemeLink; FreeLink: boolean);
begin
  if FOutPuts <> nil then
    begin
    FOutPuts.Remove(Link);
    if FOutPuts.Count = 0 then
      FreeAndNil(FOutPuts);
    end;
end;

function TSchemeBlock.GetBlockLevel: int32;
var
  bl: TSchemeBlock;
begin
  Result := 0;
  bl := FParentLevel;
  while bl <> nil do
    begin
    inc(Result);
    bl := bl.FParentLevel;
    end;
end;

class function TSchemeBlock.GetDefaultSize: TVec2i;
begin
  Result := vec2(DEF_BLOCK_WIDTH, DEF_BLOCK_HEIGHT);
end;

procedure TSchemeBlock.GetPath;
var
  pr: TSchemeShape;
begin
  pr := ParentLevel;
  FPath := FCaption;
  while pr <> nil do
    begin
    FPath := pr.Caption + '/' + FPath;
    pr := pr.ParentLevel;
    end;
end;

class function TSchemeBlock.IsContainer: boolean;
begin
  Result := true;
end;

procedure TSchemeBlock.Load(Stream: TStream; var SizeData: int32);
begin
  inherited;

end;

procedure TSchemeBlock.Save(Stream: TStream);
begin
  inherited;

end;

procedure TSchemeBlock.SetCaption(const Value: string);
begin
  inherited;
  GetPath;
end;

procedure TSchemeBlock.SetParent(const Value: TSchemeShape);
begin
  inherited;
  GetPath;
end;

initialization
  TSchemeModel.RegisterSchemeClass(TSchemeLink);
  TSchemeModel.RegisterSchemeClass(TSchemeRegion);
  TSchemeModel.RegisterSchemeClass(TSchemeProcessor);
  TSchemeModel.RegisterSchemeClass(TSchemeBlockLinkInput);
  TSchemeModel.RegisterSchemeClass(TSchemeBlockLinkOutput);
  TSchemeModel.RegisterSchemeClass(TSchemeBlock);


finalization


end.
