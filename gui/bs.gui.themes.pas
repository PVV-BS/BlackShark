{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised January, 2022

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

unit bs.gui.themes;

{$I BlackSharkCfg.inc}

interface

uses
  Classes,
  typinfo,
  XmlWriter,
  bs.collections
  ;

type


  TBTheme         = class;
  TStyleGroup     = class;
  TStyleItem      = class;
  TStyleItemClass = class of TStyleItem;

  { TStyleItem

    It is a keeper a value of a some property

  }

  TStyleItem = class abstract
  private
    FCaption: AnsiString;
  public
    constructor Create(const ACaption: AnsiString); virtual;
    { value saver to stream of style }
    procedure Save(Node: TheXmlNode); virtual;
    { value loader from stream of style }
    procedure Load(Node: TheXmlNode); virtual; abstract;
    { getter and setter style item value; be careful, because you must use
      strictly apropriate types }
    procedure GetValue(out ValueLocation); virtual; abstract;
    procedure SetValue(const ValueLocation); virtual; abstract;
    { setter to property of control (published) from the style item }
    procedure WriteToProperty(Prop: PPropInfo; Instance: Pointer); virtual; abstract;
    { reads property value to the style item }
    procedure ReadFromProperty(Prop: PPropInfo; Instance: Pointer); virtual; abstract;
    { type name of property }
    class function TypeName: AnsiString; virtual; abstract;
    { presentation value as string (for display) }
    function AsString: string; virtual; abstract;
    { setter value from string (if it possible) }
    procedure FromString(const Value: string); virtual; abstract;
    { size value, bytes }
    function SizeValue: int32; virtual; abstract;
    { name of property }
    property Caption: AnsiString read FCaption;
  end;

  { TODO: indexed properties }

  { TStyleTemplate }

  TStyleTemplate<T> = class(TStyleItem)
  protected
    FValue: T;
  public
    procedure GetValue(out ValueLocation); override;
    procedure SetValue(const ValueLocation); override;
    function SizeValue: int32; override;
    { reads property value to the style item }
    procedure ReadFromProperty(Prop: PPropInfo; Instance: Pointer); override;
    { setter to property of control (published) from the style item }
    procedure WriteToProperty(Prop: PPropInfo; Instance: Pointer); override;
    class function TypeName: AnsiString; override;
    property Value: T read FValue;
  end;

  { TPropValueAccessProvider }

  TPropValueAccessProvider<T> = class
  private
    type
      BPtrOfType   = ^T;
      TBGetProc    = function  :T of object;
      TBIdxGetProc = function  (Index: Integer): T of object;
      TBSetProc    = procedure (const Value: T) of object;
      TBIdxSetProc = procedure (Index: Integer; const Value: T) of object;
  public
    class function GetPropValue(Instance: TObject; PropInfo: PPropInfo; Index: int32 = -1): T;
    class procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo; const Value: T; Index: int32 = -1);
  end;

  { tree for save and load structs of styles }

  TTreeStyles = TheXmlWriter;

  { TStyleGroup }

  TStyleGroup = class
  private
  type
    TStyleItems = TBinTreeTemplate<AnsiString, TStyleItem>;
  private
    FCaption: AnsiString;
    FTheme: TBTheme;
    StyleItems: TStyleItems;
    _NodeInTree: TheXmlNode;
    FURL: AnsiString;
  protected
    procedure Load; virtual;
    procedure Save; virtual;
  public
    constructor Create(const AURL: AnsiString; ATheme: TBTheme); virtual;
    destructor Destroy; override;
    procedure Clear;
    procedure AddStyleItem(StyleItem: TStyleItem); overload;
    function AddStyleItem(StyleItemClass: TStyleItemClass; const PropertyName: AnsiString;
      const DefaultValue): TStyleItem; overload;
    function AddStyleItem(StyleItemClass: TStyleItemClass;
      const PropertyName: AnsiString): TStyleItem; overload;
    function FindStyleItem(const PropertyCaption: AnsiString): TStyleItem;
    { a name of class (a end point of URL) }
    property Caption: AnsiString read FCaption;
    { a path to place in a style }
    property URL: AnsiString read FURL;
    property ThemeOwner: TBTheme read FTheme;
  end;

  TStyleGroups = THashTable<AnsiString, TStyleGroup>;

  TBTheme = class
  private
    type
      TSchemClassesDicLoad = THashTable<int32, TStyleItemClass>;
      TSchemClassesDicSave = THashTable<Pointer, int32>;
  private
    FStyleGroups: TStyleGroups;
    Data: TTreeStyles;
    NodeComponents: TheXmlNode;
    LoadDic: TSchemClassesDicLoad;
    SaveDic: TSchemClassesDicSave;
    function OnSaveGetTypeID(StyleItem: TStyleItemClass): int32;
    function OnLoadGetStyleClass(ID: int32): TStyleItemClass;
    class var RegistredStyleItems: TBinTreeTemplate<AnsiString, TStyleItemClass>;
    class var RegistredStyleItemsByTypeName: TBinTreeTemplate<AnsiString, TStyleItemClass>;
    class constructor Create;
    class destructor Destroy;
  protected
    function DoCreateStyleGroup(const URL: AnsiString; ToNode: TheXmlNode): TStyleGroup;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    { register an element of a style }
    class procedure RegisterStyleItem(StyleItemClass: TStyleItemClass);
    class function FindStyleItemByClassName(const StyleItemClassName: AnsiString):  TStyleItemClass; overload;
    class function FindStyleItemByTypeName(const StyleItemTypeName: AnsiString):  TStyleItemClass; overload;
    function Load(const {%H-}FileName: string): boolean; overload;
    function Save(const FileName: string): boolean;      overload;
    function Load(Stream: TStream): boolean; overload;
    function Save(Stream: TStream): boolean; overload;
    function CreateStyleGroup(const URL: AnsiString): TStyleGroup; overload;
    function CreateStyleGroup(const URL: AnsiString; const ClassGroup: TObject;
      AutoCreatePropList: boolean): TStyleGroup;  overload;
    procedure DeleteGroup(const URL: AnsiString);
    function FindStyleGroup(const URL: AnsiString): TStyleGroup;
    function FindOrCreateStyleGroup(const URL: AnsiString; const ClassGroup: TObject): TStyleGroup; overload;
    function FindOrCreateStyleGroup(const URL: AnsiString): TStyleGroup; overload;
  end;

  { TThemeManager

    Single default theme of an application

    }

  TThemeManager = class(TBTheme)
  private
    class var Instance: TThemeManager;
  public
    class function NewInstance: TObject; override;
  end;


  function IsFieldSetProc(PropInfo: PPropInfo): Boolean; inline;
  function IsFieldGetProc(PropInfo: PPropInfo): Boolean; inline;
  function GetField(Instance: TObject; P: Pointer): Pointer; inline;
  function GetCodePointerGet(Instance: TObject; PropInfo: PPropInfo): Pointer; inline;
  function GetCodePointerSet(Instance: TObject; PropInfo: PPropInfo): Pointer; inline;

  function GetParentFromPath(const Path: AnsiString): AnsiString;
  function GetEndNameFromPath(const Path: AnsiString): AnsiString;

  const
    GROUP_DELIMETER: AnsiChar = '.';

  var
    ThemeManager: TThemeManager;

implementation

uses
    SysUtils
  , bs.strings;

function GetParentFromPath(const Path: AnsiString): AnsiString;
var
  i: int32;
begin

  if length(Path) < 2 then
    exit('');

  for i := length(Path) - 1 downto 2 do
    if Path[i] = GROUP_DELIMETER then
    begin
      SetLength(Result, i-1);
      move(Path[1], Result[1], i-1);
      exit;
    end;
  Result := '';
end;

function GetEndNameFromPath(const Path: AnsiString): AnsiString;
var
  i: int32;
begin

  if length(Path) < 2 then
    exit('');

  for i := length(Path) - 1 downto 2 do
    if Path[i] = GROUP_DELIMETER then
    begin
      SetLength(Result, length(Path) - i);
      move(Path[i+1], Result[1], length(Path) - i);
      exit;
    end;
  Result := Path;
end;

{ TBTheme }

procedure TBTheme.Clear;
var
  bucket: TStyleGroups.TBucket;
begin
  if FStyleGroups.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FStyleGroups.GetNext(bucket);
  FStyleGroups.Clear(true);
  Data.Clear;
end;

constructor TBTheme.Create;
begin
  FStyleGroups := TStyleGroups.Create(@GetHashBlackSharkSA, @StrCmpABool, 64);
  Data := TTreeStyles.Create('');
  Data.Encoding := TTypeChar.tcUTF8;
  Data.InsertLineSeparator := true;
  Data.CreateNode(nil, 'Scheme');
  NodeComponents := Data.CreateNode(Data.Root, 'TreeComponents');
  //Data.OnLoadNode := OnLoad;
  //Data.OnSaveNode := OnSave;
end;

class constructor TBTheme.Create;
begin
  RegistredStyleItems := TBinTreeTemplate<AnsiString, TStyleItemClass>.Create(@StrCmpA);
  RegistredStyleItemsByTypeName := TBinTreeTemplate<AnsiString, TStyleItemClass>.Create(@StrCmpA);
end;

function TBTheme.CreateStyleGroup(const URL: AnsiString): TStyleGroup;
begin
  Result := DoCreateStyleGroup(URL, nil);
end;

function TBTheme.CreateStyleGroup(const URL: AnsiString; const ClassGroup: TObject;
  AutoCreatePropList: boolean): TStyleGroup;
var
  props: PPropList;
  i: int32;
  style_type: TStyleItemClass;
  style_item: TStyleItem;
  prop_astr: AnsiString;
begin
  Result := CreateStyleGroup(URL); // , ClassGroup.ClassType
  if AutoCreatePropList then
    begin
    props := nil;
    i := GetPropList(ClassGroup, props);
    try
      while i > 0 do
        begin
        dec(i);
        if IsPublishedProp(ClassGroup, string(props[i].Name)) then
          begin
          style_type := FindStyleItemByTypeName(StringToAnsi(string(props[i].PropType^.Name)));
          if Assigned(style_type) then
            begin
            prop_astr := StringToAnsi(string(props[i].Name));
            style_item := Result.AddStyleItem(style_type, prop_astr);
            { set property value to style }
            style_item.ReadFromProperty(props[i], ClassGroup);
            end;
          end;
        end;
    finally
      if props <> nil then
        FreeMem(props);
    end;
    end;
end;

class destructor TBTheme.Destroy;
begin
  RegistredStyleItems.Free;
  RegistredStyleItemsByTypeName.Free;
end;

procedure TBTheme.DeleteGroup(const URL: AnsiString);
var
  gr: TStyleGroup;
begin
  if FStyleGroups.Find(URL, gr) then
  begin
    gr._NodeInTree.Delete;
    FStyleGroups.Delete(URL);
    gr.Free;
  end;
end;

destructor TBTheme.Destroy;
begin
  Clear;
  FStyleGroups.Free;
  Data.Free;
  inherited;
end;

function TBTheme.DoCreateStyleGroup(const URL: AnsiString; ToNode: TheXmlNode): TStyleGroup;
var
  parent: TStyleGroup;
  s: AnsiString;
begin
  if FStyleGroups.Find(URL, Result) then
    raise Exception.Create('This group style already exists!');
  Result := TStyleGroup.Create(URL, Self);
  if ToNode = nil then
  begin
    s := GetParentFromPath(URL);
    parent := nil;
    if (s <> '') and (s <> URL) then
    begin
      if not FStyleGroups.Find(s, parent) then
        parent := DoCreateStyleGroup(s, nil);
    end;

    if parent <> nil then
      Result._NodeInTree := Data.CreateNode(parent._NodeInTree, AnsiToWide(Result.Caption))
    else
      Result._NodeInTree := Data.CreateNode(NodeComponents, AnsiToWide(Result.Caption));
    Result._NodeInTree.Data := Result;
  end else
  begin
    Result._NodeInTree := ToNode;
    ToNode.Data := Result;
  end;
  FStyleGroups.Items[URL] := Result;
end;

function TBTheme.FindOrCreateStyleGroup(const URL: AnsiString;
  const ClassGroup: TObject): TStyleGroup;
begin
  Result := FindStyleGroup(URL);
  if Result = nil then
    Result := CreateStyleGroup(URL, ClassGroup, true);
end;

function TBTheme.FindOrCreateStyleGroup(const URL: AnsiString): TStyleGroup;
begin
  Result := FindStyleGroup(URL);
  if Result = nil then
    Result := CreateStyleGroup(URL)
end;

function TBTheme.FindStyleGroup(const URL: AnsiString): TStyleGroup;
var
  s: AnsiString;
begin
  Result := nil;
  if not FStyleGroups.Find(URL, Result) then
  begin
    s := GetEndNameFromPath(URL);
    if (length(s) > 0) and (s <> URL) then
      FStyleGroups.Find(s, Result);
  end;
end;

class function TBTheme.FindStyleItemByClassName(const StyleItemClassName: AnsiString): TStyleItemClass;
begin
  RegistredStyleItems.Find(AnsiUp(StyleItemClassName), Result);
end;

class function TBTheme.FindStyleItemByTypeName(const StyleItemTypeName: AnsiString): TStyleItemClass;
begin
  RegistredStyleItemsByTypeName.Find(AnsiUp(StyleItemTypeName), Result);
end;

function TBTheme.Load(Stream: TStream): boolean;

  procedure LoadNode(Node: TheXmlNode);
  var
    i: int32;
    url: AnsiString;
  begin
    if Node.Name = 'props' then
      exit;
    url := Node.GetAttribute('url', AnsiString(''));
    DoCreateStyleGroup(url, Node);
    TStyleGroup(Node.Data).Load;
    for i := 0 to Node.CountChilds - 1 do
    begin
      LoadNode(Node.Childs[i]);
    end;
  end;

var
  cl_id: int32;
  cl_st: TStyleItemClass;
  n: AnsiString;
  node, child: TheXmlNode;
  i: int32;
begin
  Clear;
  Data.LoadFromStream(Stream);
  node := Data.FindNode('Dic', true);
  if node = nil then
  begin
    Data.CreateNode(nil, 'Scheme');
    NodeComponents := Data.CreateNode(Data.Root, 'TreeComponents');
    exit(false);
  end;
  Result := true;
  LoadDic := TSchemClassesDicLoad.Create(GetHashBlackSharkInt32, Int32CmpBool, 64);
  try

    { load a dictionary of components }
    for i := 0 to node.CountChilds - 1 do
    begin
      child := node.Childs[i];
      { id }
      cl_id := child.GetAttribute('id', -1);
      { name }
      n := child.GetAttribute('name', AnsiString(''));
      cl_st := FindStyleItemByClassName(n);
      if Assigned(cl_st) then
        LoadDic.Items[cl_id] := cl_st;
    end;

    NodeComponents := Data.FindNode('TreeComponents', true);
    if NodeComponents = nil then
    begin
      NodeComponents := Data.CreateNode(Data.Root, 'TreeComponents');
      exit;
    end;

    for i := 0 to NodeComponents.CountChilds - 1 do
    begin
      LoadNode(NodeComponents.Childs[i]);
    end;

  finally
    FreeAndNil(LoadDic);
  end;
end;

function TBTheme.Load(const FileName: string): boolean;
var
  f: TFileStream;
begin
  try
    f := TFileStream.Create(FileName, fmOpenRead);
  except
    exit(false);
  end;
  try
    Result := Load(f);
  finally
    f.Free;
  end;
end;

function TBTheme.OnLoadGetStyleClass(ID: int32): TStyleItemClass;
begin
  LoadDic.Find(ID, Result);
end;

function TBTheme.OnSaveGetTypeID(StyleItem: TStyleItemClass): int32;
begin
  SaveDic.Find(StyleItem, Result);
end;

class procedure TBTheme.RegisterStyleItem(StyleItemClass: TStyleItemClass);
var
  k: AnsiString;
begin
  k := AnsiUp(StyleItemClass.TypeName);
  if (RegistredStyleItemsByTypeName.FindNode(k) = nil) then
  begin
    RegistredStyleItems.Add(AnsiUp(StringToAnsi(StyleItemClass.ClassName)), StyleItemClass);
    RegistredStyleItemsByTypeName.Add(k, StyleItemClass);
  end;
end;

function TBTheme.Save(Stream: TStream): boolean;
var
  id: int32;
  i: int32;
  val: TStyleItemClass;
  node, child: TheXmlNode;
begin
  SaveDic := TSchemClassesDicSave.Create(GetHashBlackSharkPointer, PtrCmpBool, 64);
  try
    node := Data.FindNode('Dic');
    if not Assigned(node) then
      node := Data.CreateNode(Data.Root, 'Dic')
    else
      node.DeleteChilds;
    { save a dictionary of types }
    id := 0;
    if RegistredStyleItems.Iterator.SetToBegin(val) then
    repeat
      SaveDic.Items[val] := id;
      child := node.AddChild('it');
      child.AddAttribute('id', id);
      child.AddAttribute('name', RegistredStyleItems.Iterator.CurrentNode.Key);
      inc(id);
    until not RegistredStyleItems.Iterator.Next(val);

    for i := 0 to NodeComponents.CountChilds - 1 do
    begin
      TStyleGroup(NodeComponents.Childs[i].Data).Save;
    end;

    Data.SaveToStream(Stream);

    Result := true;
  finally
    FreeAndNil(SaveDic);
  end;
end;

function TBTheme.Save(const FileName: string): boolean;
var
  f: TFileStream;
begin
  try
    f := TFileStream.Create(FileName, fmCreate);
  except
    exit(false);
  end;
  try
    Result := Save(f);
  finally
    f.Free;
  end;
end;

{ TThemeManager }

class function TThemeManager.NewInstance: TObject;
begin
  if not Assigned(Instance) then
    Instance := TThemeManager(inherited NewInstance);
  Result := Instance;
end;

{ TStyleGroup }

procedure TStyleGroup.AddStyleItem(StyleItem: TStyleItem);
var
  res: TStyleItem;
begin
  if StyleItems.Find(StyleItem.Caption, res) then
    raise Exception.Create('Such style already exists!');
  StyleItems.Add(StyleItem.Caption, StyleItem);
end;

function TStyleGroup.AddStyleItem(StyleItemClass: TStyleItemClass;
  const PropertyName: AnsiString; const DefaultValue): TStyleItem;
begin
  Result := StyleItemClass.Create(PropertyName);
  Result.SetValue(DefaultValue);
  AddStyleItem(Result);
end;

function TStyleGroup.AddStyleItem(StyleItemClass: TStyleItemClass;
  const PropertyName: AnsiString): TStyleItem;
begin
  Result := StyleItemClass.Create(PropertyName);
  AddStyleItem(Result);
end;

procedure TStyleGroup.Clear;
begin
  if StyleItems.Iterator.SetToBegin then
  repeat
    StyleItems.Iterator.CurrentNode.Value.Free;
  until not StyleItems.Iterator.Next;
  StyleItems.Clear(true);
end;

constructor TStyleGroup.Create(const AURL: AnsiString; ATheme: TBTheme);
begin
  FTheme := ATheme;
  FCaption := GetEndNameFromPath(AURL);
  FURL := AURL;
  StyleItems := TStyleItems.Create(@StrCmpA);
end;

destructor TStyleGroup.Destroy;
begin
  Clear;
  StyleItems.Free;
  inherited;
end;

function TStyleGroup.FindStyleItem(const PropertyCaption: AnsiString): TStyleItem;
begin
  StyleItems.Find(PropertyCaption, Result);
end;

procedure TStyleGroup.Load;
var
  it: TStyleItem;
  it_cl: TStyleItemClass;
  i: int32;
  id: int32;
  name: AnsiString;
  node, child: TheXmlNode;
begin
  node := _NodeInTree.FindChildNode('props');
  if Assigned(node) then
  begin
    for i := 0 to node.CountChilds - 1 do
    begin
      child := node.Childs[i];
      { type name of TStyleItem }
      id := child.GetAttribute('id', -1);
      it_cl := FTheme.OnLoadGetStyleClass(id);
      { name of property }
      name := child.GetAttribute('nm', AnsiString(''));
      { create }
      if Assigned(it_cl) then
      begin
        it := AddStyleItem(it_cl, name);
        { read data of TStyleItem }
        it.Load(child);
      end;
    end;
  end;
end;

procedure TStyleGroup.Save;
var
  it: TStyleItem;
  node, child: TheXmlNode;
  i: int32;
begin
  _NodeInTree.ClearAttributes;
  _NodeInTree.AddAttribute('url', url);
  node := _NodeInTree.FindChildNode('props');
  if not Assigned(node) then
    node := _NodeInTree.AddChild('props')
  else
    node.DeleteChilds;

  if StyleItems.Iterator.SetToBegin(it) then
  repeat
    child := node.AddChild('prop');
    { id }
    child.AddAttribute('id', FTheme.OnSaveGetTypeID(TStyleItemClass(it.ClassType)));
    { name of the property }
    child.AddAttribute('nm', it.FCaption);
    it.Save(child);
  until not StyleItems.Iterator.Next(it);

  for i := 0 to _NodeInTree.CountChilds - 1 do
  begin
    if node = _NodeInTree.Childs[i] then
      continue;

    TStyleGroup(_NodeInTree.Childs[i].Data).Save;
  end;

end;

{ TStyleItem }

constructor TStyleItem.Create(const ACaption: AnsiString);
begin
  FCaption := ACaption;
end;

procedure TStyleItem.Save(Node: TheXmlNode);
begin

end;

function IsFieldGetProc(PropInfo: PPropInfo): Boolean;// inline;
{$ifndef FPC}
const
  MASK = {$ifdef CPUX86} $FF000000 {$else} $FF00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
{$endif}
begin
  {$ifdef FPC}
  Result := ((PropInfo^.PropProcs) and 3 ) = ptField;
  {$else}
  Result := ({%H-}IntPtr(PropInfo^.GetProc) and MASK) = MASK;
  {$endif}
end;

function IsFieldSetProc(PropInfo: PPropInfo): Boolean; inline;
{$ifndef FPC}
const
  MASK = {$ifdef CPUX86} $FF000000 {$else} $FF00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
  //MASK = ($FF shl ((SizeOf(Pointer)*8) - 8));
{$endif}
begin
  {$ifdef FPC}
  Result := ((PropInfo^.PropProcs shr 2) and 3 ) = ptField;
  {$else}
  Result := ({%H-}IntPtr(PropInfo^.SetProc) and MASK) = MASK;
  {$endif}
end;

function GetField(Instance: TObject; P: Pointer): Pointer; inline;
{$ifndef FPC}
const
    MASK = not ($FF shl ((SizeOf(Pointer)*8) - 8));
{$else}
const
   MASK = {$if SizeOf(Pointer) = 4} $FFFFFF {$else} $FFFFFFFFFFFFFF {$endif};
{$endif}
begin
  Result := Pointer(PByte(Instance) + ({%H-}IntPtr(P) and MASK));
end;

function GetCodePointerGet(Instance: TObject; PropInfo: PPropInfo): Pointer; inline;
{$ifndef FPC}
const
  MASK = {$ifdef CPUX86} $FF000000 {$else} $FF00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
  //MASK = ($FF shl ((SizeOf(Pointer)*8) - 8));
  //MASK_VIRTUAL = ($FE shl ((SizeOf(Pointer)*8) - 8));
  MASK_VIRTUAL = {$ifdef CPUX86} $FE000000 {$else} $FE00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
{$endif}
begin
  { Is it Virtual Method? }
  {$ifdef FPC}
  if ((PropInfo^.PropProcs) and 3) = ptVirtual then
    Result := PCodePointer(Pointer(Instance.ClassType)+{%H-}PtrUInt(PropInfo^.GetProc))^
  {$else}
  if ({%H-}IntPtr(PropInfo^.GetProc) and MASK) = MASK_VIRTUAL then
    Result := {%H-}PPointer(PNativeUInt(Instance)^ + ({%H-}UIntPtr(PropInfo^.GetProc) and $FFFF))^
  {$endif}
  else // Static method
    Result := PropInfo^.GetProc;
end;

function GetCodePointerSet(Instance: TObject; PropInfo: PPropInfo): Pointer; inline;
{$ifndef FPC}
const
  MASK = {$ifdef CPUX86} $FF000000 {$else} $FF00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
  //MASK = ($FF shl ((SizeOf(Pointer)*8) - 8));
  //MASK_VIRTUAL = ($FE shl ((SizeOf(Pointer)*8) - 8));
  MASK_VIRTUAL = {$ifdef CPUX86} $FE000000 {$else} $FE00000000000000 {$endif}; // ($FF shl ((SizeOf(Pointer)*8) - 8));
{$endif}
begin
  { Is it Virtual Method? }
  {$ifdef FPC}
  if ((PropInfo^.PropProcs shr 2) and 3) = ptVirtual then
    Result := PCodePointer(Pointer(Instance.ClassType)+{%H-}PtrUInt(PropInfo^.SetProc))^
  {$else}
  if ({%H-}IntPtr(PropInfo^.SetProc) and MASK) = MASK_VIRTUAL then
    Result := {%H-}PPointer(PNativeUInt(Instance)^ + ({%H-}UIntPtr(PropInfo^.SetProc) and $FFFF))^
  {$endif}
  else // Static method
    Result := PropInfo^.SetProc;
end;

{ TPropValueAccessProvider<T> }

class function TPropValueAccessProvider<T>.GetPropValue(Instance: TObject; PropInfo: PPropInfo; Index: int32 = -1): T;
var
  m: TMethod;
begin
  if IsFieldGetProc(PropInfo) then
  begin
    Result := BPtrOfType(GetField(Instance, PropInfo^.GetProc))^;
  end else
  begin
    m.Code := GetCodePointerGet(Instance, PropInfo);
    if Assigned(m.Code) then
    begin
      m.Data := Instance;
      {$ifdef FPC}
      if Index >= 0 then
        Result := Self.TBIdxGetProc(m)(Index)
      else
        Result := Self.TBGetProc(m)();
      {$else}
      if Index < 0 then
        Result := TBGetProc(m)()
      else
        Result := TBIdxGetProc(m)(Index);
      {$endif}
    end else
      FillChar(Result, SizeOf(Result), 0);
  end;
end;

class procedure TPropValueAccessProvider<T>.SetPropValue(Instance: TObject;
    PropInfo: PPropInfo; const Value: T; Index: int32 = -1);
var
  m: TMethod;
begin
  if IsFieldSetProc(PropInfo) then
  begin
    BPtrOfType(GetField(Instance, PropInfo^.SetProc))^ := Value;
  end else
  begin
    m.Code := GetCodePointerSet(Instance, PropInfo);
    if Assigned(m.Code) then
    begin
      m.Data := Instance;
      {$ifdef FPC}
      if Index < 0 then
        TBSetProc(m)(Value)
      else
        TBIdxSetProc(m)(Index, Value);
      {$else}
      if Index < 0 then
        TBSetProc(m)(Value)
      else
        TBIdxSetProc(m)(Index, Value);
      {$endif}
    end;
  end;
end;

{ TStyleTemplate }

{
procedure TStyleTemplate<T>.Save(Node: TheXmlNode);
var
  l: int32;
begin
  l := SizeValue;
  Stream.Write(l, 4);
  Stream.Write(FValue, l);
end;

function TStyleTemplate<T>.Load(Node: TheXmlNode): boolean;
var
  l: int32;
begin
  Stream.Read(l, 4);
  Result := Stream.Read(FValue, l) = l;
end;
}

procedure TStyleTemplate<T>.GetValue(out ValueLocation);
begin
  T(ValueLocation) := FValue;
end;

procedure TStyleTemplate<T>.SetValue(const ValueLocation);
begin
  FValue := T(ValueLocation);
end;

function TStyleTemplate<T>.SizeValue: int32;
begin
  Result := SizeOf(T);
end;

class function TStyleTemplate<T>.TypeName: AnsiString;
var
  ti: PTypeInfo;
begin
  ti := TypeInfo(T);
  Result := ti.Name;
end;

procedure TStyleTemplate<T>.WriteToProperty(Prop: PPropInfo; Instance: Pointer);
begin
  TPropValueAccessProvider<T>.SetPropValue(Instance, Prop, FValue);
end;

procedure TStyleTemplate<T>.ReadFromProperty(Prop: PPropInfo; Instance: Pointer);
begin
  FValue := TPropValueAccessProvider<T>.GetPropValue(Instance, Prop);
end;

initialization

  ThemeManager := TThemeManager.Create;

finalization

  FreeAndNil(ThemeManager);

end.

