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


{
  <summary>

  It implementaions of a builder and a parser of SIMPLE XML struct

  </summary>
}
unit XmlWriter;

interface

uses
    Classes
  , SysUtils
  ;

const
  XML_HDR_UNICODE: UnicodeString = '<?xml version="1.0" encoding="unicode"?>';
  XML_HDR_UTF8: AnsiString = '<?xml version="1.0" encoding="UTF-8"?>';
  HDR_LE_UNICODE: array [0 .. 1] of byte = ($FF, $FE);
  HDR_BE_UNICODE: array [0 .. 1] of byte = ($FE, $FF);
  LINE_SEPARATOR: WideString = #$0A;

type

  TheXmlNode = class;
  TheXmlWriter = class;

  TTypeChar = (tcUnicodeBE, tcUnicodeLE, tcUTF8, tcANSI);

  PAttrSign = ^TAttrSign;

  TAttrSign = record
    Name: WideString;
    NameUp: WideString;
    Value: WideString;
  end;

  TOnNodeNotify = procedure(Node: TheXmlNode) of object;

  { TheXmlNode }

  TheXmlNode = class
  private
    FParent: TheXmlNode;
    FChilds: TList;
    FAttributes: TList;
    FName: WideString;
    FData: Pointer;
    BufAttrib: array of byte;
    // string inside node, for example <it>string</it>
    FStrData: WideString;
    function GetChild(index: int32): TheXmlNode;
    function GetCountChilds: int32;
    // function GetTextWithChild: UnicodeString;
    function GetTextWithChildAnsi: AnsiString;
    function GetTextWithChildUTF8: UTF8String;
    function GetTextWithChildBE: WideString;
    function GetTextWithChildLE: WideString;
    function RemoveChild(Child: TheXmlNode): boolean;
    function GetAttributes(index: int32): PAttrSign;
    function GetCountAttributes: int32;
  protected
    FTree: TheXmlWriter;
  public
    constructor Create(AParent: TheXmlNode; const AName: WideString);
    destructor Destroy; override;
    function AddChild(const AName: WideString): TheXmlNode;
    procedure ClearAttributes;
    procedure AddAttribute(const Name: WideString; const Value: WideString); overload;
    procedure AddAttribute(const Name: WideString; const Value: AnsiString); overload;
    procedure AddAttribute(const Name: WideString; Value: boolean); overload;
    procedure AddAttribute(const Name: WideString; Value: int32); overload;
    procedure AddAttribute(const Name: WideString; Value: int64); overload;
    procedure AddAttribute(const Name: WideString; Value: Double); overload;
    procedure AddAttribute(const Name: WideString; Value: Pointer; CountBytes: int32); overload;

    function GetAttribute(const Name: WideString; const DefaultValue: WideString): WideString; overload;
    function GetAttribute(const Name: WideString; const DefaultValue: AnsiString): AnsiString; overload;
    function GetAttribute(const Name: WideString; DefaultValue: boolean): boolean; overload;
    function GetAttribute(const Name: WideString; DefaultValue: int32): int32; overload;
    function GetAttribute(const Name: WideString; DefaultValue: int64): int64; overload;
    function GetAttribute(const Name: WideString; DefaultValue: Double): Double; overload;
    function GetAttribute(const Name: WideString): PAttrSign; overload;
    function GetAttribute(const Name: WideString; var SignOut: Pointer; var CountBytes: int32): boolean; overload;
    function AttributeExists(const Name: WideString): boolean;

    function FindChildNode(const Name: WideString; Recurcive: boolean = false): TheXmlNode;
    function FindChildNodeWhithAttribSign(const NameAttrib: WideString; const NeedSignAttrib: WideString; Recurcive: boolean = false): TheXmlNode;

    procedure Delete;
    procedure DeleteChilds;

    property TextWithChildBE: WideString read GetTextWithChildBE;
    property TextWithChildLE: WideString read GetTextWithChildLE;
    property TextWithChildAnsi: AnsiString read GetTextWithChildAnsi;
    property TextWithChildW: WideString read GetTextWithChildLE;
    property CountChilds: int32 read GetCountChilds;
    property Childs[index: int32]: TheXmlNode read GetChild;
    property Name: WideString read FName write FName;
    property Data: Pointer read FData write FData;
    // string inside node, for example <it>string</it>
    property StrData: WideString read FStrData write FStrData;
    property Attributes[index: int32]: PAttrSign read GetAttributes;
    property CountAttributes: int32 read GetCountAttributes;
    property Parent: TheXmlNode read FParent;

  end;

  { TheXmlWriter }

  TheXmlWriter = class
  private
    FEncoding: TTypeChar;
    FRoot: TheXmlNode;
    FURL: string;
    /// /////////////
    SizeChar: uint8; // for only service chars, that is, if FEncoding = tcUTF8, then SizeChar = 1.
    S_BLANK: uint16;
    S_MORE_BRACKET: uint16;
    S_SMALER_BRACKET: uint16;
    S_QUOTE: uint16;
    S_SLASH: uint16;
    S_EQUAL: uint16;
    FOnDeleteNode: TOnNodeNotify;
    FOnAddNode: TOnNodeNotify;
    FInsertLineSeparator: boolean;
    procedure GenerateServiceChars;
    procedure SetEncoding(AValue: TTypeChar);
    procedure SetURL(AValue: string);
    procedure OnDeleteNodeNotify(Node: TheXmlNode);
    function FindFirstEntryNameNodeFromPath(Parent: TheXmlNode; Path: WideString): TheXmlNode;
    // return last valid node included to Path
    function FindLastEntryNameNodeFromPath(Path: WideString): TheXmlNode;
  public
    constructor Create(const AURL: string; Load: boolean = false);
    destructor Destroy; override;
    procedure SaveChanges;
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromURL(const AURL: string);
    procedure LoadFromText(Text: PAnsiChar; LenInBytes: int32); overload;
    procedure LoadFromText(Text: PWideChar; LenInBytes: int32); overload;
    procedure LoadFromBuf(Ptr: pByte; SizeBuf: int32);
    procedure LoadFromStream(Stream: TStream);
    procedure Clear;
    function CreateNode(AParent: TheXmlNode; const AName: WideString): TheXmlNode;
    function DelNodeFromPath(const Path: WideString): boolean;
    function DelNodeFromPathByAttrib(const Path: WideString; const AttribName: WideString;
      // true - значение искомого каждого следующего уровня сложено из значений предыдущих, т.е. из строки 1a\2a\3a\4a\
      // на первом уровне будет выполнятся поиск атрибута со значением 1a, на втором 1a\2a, на третьем 1a\2a\3a и т.д.
      // false - для каждого уровня значения разделяются, т.е. выполнится поиск значения 1a на первом уровне, 2a - на втором, 3a - на третьем, и т.д.
      SignLenInc: boolean): boolean;
    // находит узел по пути соединённых имён узлов через слэш
    function FindNodeFromPath(const Path: WideString): TheXmlNode;
    // находит узел по пути соединённых значений атрибутов через слэш
    function FindNodeFromPathArrtib(const Path: WideString; const AttribName: WideString;
      // true - значение искомого каждого следующего уровня сложено из значений предыдущих, т.е. из строки 1a\2a\3a\4a\
      // на первом уровне будет выполнятся поиск атрибута со значением 1a, на втором 1a\2a, на третьем 1a\2a\3a и т.д.
      // false - для каждого уровня значения разделяются, т.е. выполнится поиск значения 1a на первом уровне, 2a - на втором, 3a - на третьем, и т.д.
      SignLenInc: boolean): TheXmlNode;
    function FindNode(const Name: WideString; AllChilds: boolean = false): TheXmlNode;
    function ForceAddNodeFromPath(const Path: WideString): TheXmlNode;

    property Root: TheXmlNode read FRoot;
    // you can change Encoding befor save
    property Encoding: TTypeChar read FEncoding write SetEncoding;
    property InsertLineSeparator: boolean read FInsertLineSeparator write FInsertLineSeparator;
    property URL: string read FURL write SetURL;
    property OnDeleteNode: TOnNodeNotify read FOnDeleteNode write FOnDeleteNode;
    property OnAddNode: TOnNodeNotify read FOnAddNode write FOnAddNode;
  end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: Pointer; SizeSign: int32): int32; overload; inline;
function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: byte): int32; overload; inline;

function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of AnsiChar): int32; overload;
function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of WideChar): int32; overload;
function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of uint16): int32; overload;
function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of uint16; SizeItem: uint8): int32; overload;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: uint16; SizeItem: uint8): int32; overload; inline;
function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: AnsiChar): int32; overload; inline;
function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: WideChar): int32; overload; inline;

procedure TheCopyStr(var s_dest: WideString; Src: Pointer; SizeRegion: int32; tc_source: TTypeChar); overload; inline;
procedure TheCopyStr(var s_dest: AnsiString; Src: Pointer; SizeRegion: int32; tc_source: TTypeChar); overload; inline;
function LE_to_BE(LE: WideString): WideString;
function XMLUTF8Encode(const WS: string): UTF8String; inline;
function XMLUTF8Decode(const S: UTF8String): UnicodeString; inline;
function AnsiToWide(const Ansi: AnsiString): WideString; inline;
function WideToAnsi(const Unicode: WideString): AnsiString; inline;
function WideToString(const Unicode: WideString): string; inline;
function StringToWide(const Str: string): WideString; inline;

implementation

uses
{$IFDEF MSWindows}
  Windows,
{$ENDIF}
  Types;

var
  CurrentCP: uint32;

function XMLUTF8Encode(const WS: string): UTF8String; inline;
begin
{$IFDEF fpc}
  Result := UTF8Encode(WS);
{$ELSE}
  Result := UTF8String(WS);
{$ENDIF}
end;

function XMLUTF8Decode(const S: UTF8String): UnicodeString; inline;
begin
{$IFDEF fpc}
  Result := UTF8Decode(S);
{$ELSE}
  Result := String(S);
{$ENDIF}
end;

function WideToAnsi(const Unicode: WideString): AnsiString;
begin
{$IFDEF FPC}
  Result := UTF8Encode(Unicode);
{$ELSE}
  Result := AnsiString(Unicode);
{$ENDIF}
  // UnicodeToUtf8();
end;

function AnsiToWide(const Ansi: AnsiString): WideString;
begin
{$IFDEF FPC}
  Result := UTF8Decode(Ansi);
{$ELSE}
  Result := WideString(Ansi);
{$ENDIF}
end;

function WideToString(const Unicode: WideString): string;
begin
{$IFDEF FPC}
  Result := UTF8Encode(Unicode);
{$ELSE}
  Result := Unicode;
{$ENDIF}
end;

function StringToWide(const Str: string): WideString; inline;
begin
{$IFDEF FPC}
  Result := UTF8Decode(Str);
{$ELSE}
  Result := Str;
{$ENDIF}
end;

procedure TheCopyStr(var s_dest: WideString; Src: Pointer; SizeRegion: int32; tc_source: TTypeChar); overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
var
  i: int32;
  Ptr: pByte;
  ts: UTF8String;
  ts_a: AnsiString;
begin
  if tc_source = TTypeChar.tcUnicodeBE then
  begin
    SetLength(s_dest, SizeRegion div SizeOf(WideChar));
    Ptr := Src;
    i := 1;
    while i * 2 <= SizeRegion do
    begin
      s_dest[i] := WideChar(Ptr^ shl 8 + (Ptr + 1)^);
      inc(Ptr, 2);
      inc(i);
    end;
  end
  else if tc_source = TTypeChar.tcUTF8 then
  begin
    ts := '';
    SetLength(ts, SizeRegion);
    move(Src^, ts[1], SizeRegion);
    s_dest := XMLUTF8Decode(ts);
  end
  else if tc_source = TTypeChar.tcANSI then
  begin
    ts_a := '';
    SetLength(ts_a, SizeRegion);
    move(Src^, ts_a[1], SizeRegion);
    s_dest := WideString(ts_a);
  end
  else
  begin
    SetLength(s_dest, SizeRegion div SizeOf(WideChar));
    move(Src^, s_dest[1], SizeRegion)
  end;
end;

procedure TheCopyStr(var s_dest: AnsiString; Src: Pointer; SizeRegion: int32; tc_source: TTypeChar); overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
var
  ts: WideString;
begin
  TheCopyStr(ts{%H-}, Src, SizeRegion, tc_source);
  s_dest := AnsiString(ts);
end;

function LE_to_BE(LE: WideString): WideString;
var
  i, l: int32;
begin
  i := 1;
  l := Length(LE);
  SetLength(Result, l);
  while i <= l do
  begin
    Result[i] := WideChar((uint16(LE[i]) and $FF) shl 8 + (uint16(LE[i]) and $FF00) shr 8);
    inc(i);
  end;
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: Pointer; SizeSign: int32): int32;
var
  i: int32;
  Ptr: pByte;
begin
  Ptr := PtrSource;
  for i := 0 to SourceLen - SizeSign - 1 do
  begin
    if CompareMem(Ptr, Sign, SizeSign) then
      exit(i);
    inc(Ptr);
  end;
  Result := -1;
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: byte): int32; overload;
begin
  Result := FindMem(PtrSource, SourceLen, @Sign, SizeOf(Sign));
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of WideChar): int32;
var
  i, j: int32;
  Ptr: pByte;
begin
  Ptr := PtrSource;
  for i := 0 to SourceLen - SizeOf(WideChar) - 1 do
  begin
    for j := 0 to Length(Sign) - 1 do
      if CompareMem(Ptr, @Sign[j], SizeOf(WideChar)) then
        exit(i);
    inc(Ptr);
  end;
  Result := -1;
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of uint16): int32;
var
  i, j: int32;
  Ptr: pByte;
begin
  Ptr := PtrSource;
  for i := 0 to SourceLen - SizeOf(uint16) - 1 do
  begin
    for j := 0 to Length(Sign) - 1 do
      if CompareMem(Ptr, @Sign[j], SizeOf(uint16)) then
        exit(i);
    inc(Ptr);
  end;
  Result := -1;
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of uint16; SizeItem: uint8): int32;
var
  i, j: int32;
  Ptr: pByte;
begin
  Ptr := PtrSource;
  for i := 0 to SourceLen - SizeItem - 1 do
  begin
    for j := 0 to Length(Sign) - 1 do
      if CompareMem(Ptr, @Sign[j], SizeItem) then
        exit(i);
    inc(Ptr);
  end;
  Result := -1;
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: uint16; SizeItem: uint8): int32;
begin
  Result := FindMem(PtrSource, SourceLen, @Sign, SizeItem);
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: AnsiChar): int32; overload;
begin
  Result := FindMem(PtrSource, SourceLen, @Sign, SizeOf(Sign));
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; Sign: WideChar): int32; overload;
begin
  Result := FindMem(PtrSource, SourceLen, @Sign, SizeOf(Sign));
end;

function FindMem(PtrSource: Pointer; SourceLen: int32; const Sign: array of AnsiChar): int32; overload;
var
  i, j: int32;
  Ptr: pByte;
begin
  Ptr := PtrSource;
  for i := 0 to SourceLen - SizeOf(AnsiChar) - 1 do
  begin
    for j := 0 to Length(Sign) - 1 do
      if CompareMem(Ptr, @Sign[j], SizeOf(AnsiChar)) then
        exit(i);
    inc(Ptr);
  end;
  Result := -1;
end;

{ procedure Clamp(var a: Int64;    const vBegin, vEnd: Int64);
  begin
  if a < vBegin then a := vBegin else
  if a > vEnd then a := vEnd;
  end;

  procedure Clamp(var a: integer;  const vBegin, vEnd: integer);
  begin
  if a < vBegin then a := vBegin else
  if a > vEnd then a := vEnd;
  end;

  procedure Clamp(var a: cardinal; const vBegin, vEnd: cardinal);
  begin
  if a < vBegin then a := vBegin else
  if a > vEnd then a := vEnd;
  end;

  procedure Clamp(var a: Single;   const vBegin, vEnd: Single);
  begin
  if a < vBegin then a := vBegin else
  if a > vEnd then a := vEnd;
  end;

  procedure Clamp(var a: Double;   const vBegin, vEnd: Double);
  begin
  if a < vBegin then a := vBegin else
  if a > vEnd then a := vEnd;
  end;
}
{ TheXmlNode }

function TheXmlNode.GetTextWithChildLE: WideString;
var
  tag_close: WideString;
  // s: string;
  attr: PAttrSign;
  cl, need_cl: boolean;
  i: int32;
begin
  if (FStrData <> '') or (FChilds.Count > 0) then
  begin
    need_cl := true;
    tag_close := '</' + FName + '>';
  end
  else
  begin
    need_cl := false;
    tag_close := '/>';
  end;
  if FTree.InsertLineSeparator then
    tag_close := tag_close + LINE_SEPARATOR;
  Result := '<' + FName;
  cl := false;
  for i := 0 to FAttributes.Count - 1 do
  begin
    attr := FAttributes.Items[i];
    Result := Result + ' ' + (attr^.Name) + '="' + attr^.Value + '"';
  end;
  if (FStrData <> '') then
  begin
    cl := true;
    Result := Result + '>' + FStrData;
  end;
  if (FChilds.Count > 0) then
  begin
    if not cl then
    begin
      Result := Result + '>';
      if FTree.InsertLineSeparator then
        Result := Result + LINE_SEPARATOR;
      cl := true;
    end;
    for i := 0 to FChilds.Count - 1 do
      Result := Result + TheXmlNode(FChilds.Items[i]).GetTextWithChildLE;
  end;
  if need_cl or not cl then
    Result := Result + tag_close;
end;

function TheXmlNode.GetTextWithChildUTF8: UTF8String;
begin
  Result := UTF8String(GetTextWithChildLE);
end;

function TheXmlNode.RemoveChild(Child: TheXmlNode): boolean;
begin
  Result := FChilds.Remove(Child) >= 0;
end;

function TheXmlNode.GetTextWithChildAnsi: AnsiString;
begin
  Result := AnsiString(GetTextWithChildLE);
end;

function TheXmlNode.GetTextWithChildBE: WideString;
begin
  Result := LE_to_BE(GetTextWithChildLE);
end;

function TheXmlNode.GetCountAttributes: int32;
begin
  Result := FAttributes.Count;
end;

function TheXmlNode.GetCountChilds: int32;
begin
  Result := FChilds.Count;
end;

function TheXmlNode.GetChild(index: int32): TheXmlNode;
begin
  Result := TheXmlNode(FChilds.Items[index]);
end;

procedure TheXmlNode.AddAttribute(const Name: WideString; Value: int64);
begin
  AddAttribute(Name, IntToStr(Value));
end;

procedure TheXmlNode.ClearAttributes;
var
  i: int32;
begin
  for i := 0 to FAttributes.Count - 1 do
    dispose(PAttrSign(FAttributes.Items[i]));
  FAttributes.Count := 0;
end;

constructor TheXmlNode.Create(AParent: TheXmlNode; const AName: WideString);
begin
  FName := AName;
  FData := nil;
  FChilds := TList.Create;
  FParent := AParent;
  if FParent <> nil then
    FParent.FChilds.Add(Self);
  FAttributes := TList.Create;
  FTree := nil;
end;

procedure TheXmlNode.Delete;
begin
  if Self <> nil then
    Free;
end;

procedure TheXmlNode.DeleteChilds;
var
  i: int32;
begin
  for i := FChilds.Count - 1 downto 0 do
    TheXmlNode(FChilds.Items[i]).Free;
end;

destructor TheXmlNode.Destroy;
begin
  FTree.OnDeleteNodeNotify(Self);
  if FParent <> nil then
    FParent.RemoveChild(Self);
  DeleteChilds;
  ClearAttributes;
  FAttributes.Free;
  FChilds.Free;
  inherited Destroy;
end;

procedure TheXmlNode.AddAttribute(const Name: WideString; const Value: WideString);
var
  attr: PAttrSign;
  i: int32;
  nu: WideString;
begin
  nu := WideUpperCase(Name);
  attr := nil;
  for i := 0 to FAttributes.Count - 1 do
    if PAttrSign(FAttributes.Items[i])^.NameUp = nu then
    begin
      attr := FAttributes.Items[i];
      break;
    end;
  if attr = nil then
  begin
    new(attr);
    attr^.Name := Name;
    attr^.NameUp := WideUpperCase(nu);
    FAttributes.Add(attr);
  end;
  attr^.Value := Value;
end;

// {$ifndef fpc}
procedure TheXmlNode.AddAttribute(const Name: WideString; const Value: AnsiString);
begin
  AddAttribute(Name, AnsiToWide(Value));
end;
// {$endif}

procedure TheXmlNode.AddAttribute(const Name: WideString; Value: boolean);
begin
  AddAttribute(Name, BoolToStr(Value));
end;

procedure TheXmlNode.AddAttribute(const Name: WideString; Value: int32);
begin
  AddAttribute(Name, IntToStr(Value));
end;

function TheXmlNode.GetAttribute(const Name: WideString; const DefaultValue: WideString): WideString;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := attr^.Value
  else
    Result := DefaultValue;
end;

// {$ifndef fpc}
function TheXmlNode.GetAttribute(const Name: WideString; const DefaultValue: AnsiString): AnsiString;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := AnsiString(attr^.Value)
  else
    Result := DefaultValue;
end;
// {$endif}

function TheXmlNode.GetAttribute(const Name: WideString; DefaultValue: boolean): boolean;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := StrToBool(WideToString(attr^.Value))
  else
    Result := DefaultValue;
end;

function TheXmlNode.GetAttribute(const Name: WideString; DefaultValue: int32): int32;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := StrToInt64(WideToString(attr^.Value))
  else
    Result := DefaultValue;
end;

function TheXmlNode.GetAttribute(const Name: WideString): PAttrSign;
var
  i: Integer;
  nUp: WideString;
begin
  nUp := WideUpperCase(Name);
  for i := 0 to FAttributes.Count - 1 do
  begin
    Result := FAttributes.Items[i];
    if Result^.NameUp = nUp then
      exit;
  end;
  Result := nil;
  // Result := FAttributes.Find(PByte(@AnsiUpperCase(Name)[1]), Length(Name)*SizeOf(WideChar));
end;

function TheXmlNode.GetAttribute(const Name: WideString; DefaultValue: Double): Double;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := StrToFloat(WideToString(attr^.Value))
  else
    Result := DefaultValue;
end;

function TheXmlNode.GetAttribute(const Name: WideString; DefaultValue: int64): int64;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  if attr <> nil then
    Result := StrToInt64(WideToString(attr^.Value))
  else
    Result := DefaultValue;
end;

function TheXmlNode.FindChildNode(const Name: WideString; Recurcive: boolean = false): TheXmlNode;
var
  i: int32;
  nUp: WideString;
begin
  nUp := WideUpperCase(Name);
  for i := 0 to FChilds.Count - 1 do
  begin
    if nUp = WideUpperCase(TheXmlNode(FChilds.Items[i]).FName) then
      exit(TheXmlNode(FChilds.Items[i]));
  end;

  if Recurcive then
  begin
    for i := 0 to FChilds.Count - 1 do
    begin
      Result := TheXmlNode(FChilds.Items[i]).FindChildNode(Name, true);
      if Result <> nil then
        exit;
    end;
  end;
  Result := nil;
end;

function TheXmlNode.FindChildNodeWhithAttribSign(const NameAttrib, NeedSignAttrib: WideString; Recurcive: boolean): TheXmlNode;
var
  i: int32;
  nUp, S, NeedSignAttribUp: WideString;
begin
  nUp := WideUpperCase(NameAttrib);
  NeedSignAttribUp := WideUpperCase(NeedSignAttrib);
  for i := 0 to FChilds.Count - 1 do
  begin
    S := WideUpperCase(TheXmlNode(FChilds.Items[i]).GetAttribute(nUp, WideString('')));
    if (NeedSignAttribUp = S) then
      exit(TheXmlNode(FChilds.Items[i]));
  end;

  if Recurcive then
  begin
    for i := 0 to FChilds.Count - 1 do
    begin
      Result := TheXmlNode(FChilds.Items[i]).FindChildNodeWhithAttribSign(NameAttrib, NeedSignAttrib, true);
      if Result <> nil then
        exit;
    end;
  end;
  Result := nil;
end;

procedure TheXmlNode.AddAttribute(const Name: WideString; Value: Double);
begin
  AddAttribute(Name, FloatToStr(Value));
end;

procedure TheXmlNode.AddAttribute(const Name: WideString; Value: Pointer; CountBytes: int32);
var
  attr: PAttrSign;
  i: Integer;
  nu: WideString;
begin
  attr := nil;
  nu := WideUpperCase(Name);
  for i := 0 to FAttributes.Count - 1 do
    if PAttrSign(FAttributes.Items[i])^.NameUp = nu then
    begin
      attr := FAttributes.Items[i];
      break;
    end;

  if attr = nil then
  begin
    new(attr);
    FAttributes.Add(attr);
    attr^.NameUp := nu;
    attr^.Name := Name;
  end;
  SetLength(attr^.Value, CountBytes * 2);
  BinToHex(PChar(Value), PChar(@attr^.Value[1]), CountBytes);
end;

function TheXmlNode.AddChild(const AName: WideString): TheXmlNode;
begin
  Result := FTree.CreateNode(Self, AName);
end;

function TheXmlNode.AttributeExists(const Name: WideString): boolean;
var
  attr: PAttrSign;
begin
  attr := GetAttribute(Name);
  Result := attr <> nil;
end;

function TheXmlNode.GetAttribute(const Name: WideString; var SignOut: Pointer; var CountBytes: int32): boolean;
var
  attr: PAttrSign;
begin
  CountBytes := 0;
  attr := GetAttribute(Name);
  if attr <> nil then
  begin
    CountBytes := Length(attr^.Value) div 2;
    if Length(BufAttrib) < CountBytes + 2 then
      SetLength(BufAttrib, CountBytes + 2);
    if CountBytes > 0 then
    begin
      SignOut := @BufAttrib[0];
      HexToBin(PChar(@attr^.Value[1]), SignOut, CountBytes);
      BufAttrib[CountBytes] := 0;
      BufAttrib[CountBytes + 1] := 0;
      Result := true;
    end
    else
      Result := false;
  end
  else
    Result := false;
end;

function TheXmlNode.GetAttributes(index: int32): PAttrSign;
begin
  if (index < FAttributes.Count) and (FAttributes.Count > 0) then
    Result := FAttributes.Items[index]
  else
    Result := nil;
end;

{ TheXmlWriter }

procedure TheXmlWriter.GenerateServiceChars;

  function GetCode(Ch: AnsiChar): uint16;
  begin
    case FEncoding of
      tcUnicodeBE:
        Result := byte(Ch) shl 8;
      tcUnicodeLE:
        Result := byte(Ch);
      tcUTF8:
        Result := byte(Ch)
    else
      Result := byte(Ch);
    end;
  end;

begin
  S_BLANK := GetCode(' ');
  S_MORE_BRACKET := GetCode('>');
  S_SMALER_BRACKET := GetCode('<');
  S_QUOTE := GetCode('"');
  S_SLASH := GetCode('/');
  S_EQUAL := GetCode('=');
end;

procedure TheXmlWriter.SetEncoding(AValue: TTypeChar);
begin
  if (FEncoding = AValue) then
    exit;
  FEncoding := AValue;
  case FEncoding of
    tcUnicodeBE:
      SizeChar := 2;
    tcUnicodeLE:
      SizeChar := 2;
    tcUTF8:
      SizeChar := 1;
    tcANSI:
      SizeChar := 1;
  end;
  GenerateServiceChars;
end;

procedure TheXmlWriter.LoadFromBuf(Ptr: pByte; SizeBuf: int32);
var
  pos, tmp, e: int32;
  enc_ch_w: WideString;

  procedure CheckPos;
  begin
    if (pos < 0) or (pos >= SizeBuf) then
      raise Exception.Create('Can not load XML document!');
  end;

  function GetPtrData(c_p: int32): word;
  begin
    if SizeChar < 2 then
      Result := Ptr[c_p]
    else
      Result := PWord(@Ptr[c_p])^;
  end;

  function LoadNode(Parent: TheXmlNode): TheXmlNode;
  var
    open_pos: int32;
    Name, Sign: WideString;
    sign_under_ptr_data: word;
    open_atr, read_node_hdr: boolean;
  begin
    open_pos := pos;
    inc(pos, FindMem(@Ptr[pos], SizeBuf - pos, [S_BLANK, S_SLASH, S_MORE_BRACKET], SizeChar));
    // read node name
    TheCopyStr(Name{%H-}, @Ptr[open_pos], (pos - open_pos), FEncoding);
    {if Name = 'init_from' then
      Name := Name;  }
    // create new node
    Result := CreateNode(Parent, Name);
    open_atr := false;
    read_node_hdr := true;
    open_pos := pos;
    while pos < SizeBuf - 1 do
    begin
      sign_under_ptr_data := GetPtrData(pos);
      if (sign_under_ptr_data = S_BLANK) then
      begin
        if not open_atr then
        begin
          Name := '';
          Sign := '';
          if read_node_hdr then
            open_pos := pos + SizeChar;
        end;
      end
      else if (sign_under_ptr_data = S_EQUAL) then
      begin
        if not open_atr then
        begin
          TheCopyStr(Name, @Ptr[open_pos], (pos - open_pos), FEncoding);
          open_pos := pos + SizeChar;
          if GetPtrData(open_pos) = S_QUOTE then
          begin
            open_atr := true;
            Sign := '';
            inc(pos, SizeChar);
            open_pos := pos + SizeChar;
          end;
        end;
      end
      else if (sign_under_ptr_data = S_QUOTE) then
      begin
        if open_atr then
        begin
          TheCopyStr(Sign, @Ptr[open_pos], (pos - open_pos), FEncoding);
          Result.AddAttribute(Name, Sign);
          open_atr := false;
        end else
        begin
          open_atr := true;
          Sign := '';
          open_pos := pos + SizeChar;
        end;
      end
      else if not open_atr then
      begin // not reading attribute
        if (sign_under_ptr_data = S_SLASH) and read_node_hdr then
        begin // close node
          inc(pos, FindMem(@Ptr[pos], SizeBuf - pos, S_MORE_BRACKET, SizeChar) + SizeChar);
          exit;
        end
        else if (sign_under_ptr_data = S_MORE_BRACKET) then
        begin // close node or opening childs nodes if open_childs = true
          read_node_hdr := false;
          open_pos := pos + SizeChar;
        end
        else if (sign_under_ptr_data = S_SMALER_BRACKET) then
        begin
          if pos - open_pos > 0 then
            TheCopyStr(Result.FStrData, @Ptr[open_pos], pos - open_pos, FEncoding);
          if CompareMem(@Ptr[pos + SizeChar], @S_SLASH, SizeChar) then
          begin // check end node
            inc(pos, FindMem(@Ptr[pos], SizeBuf - pos, S_MORE_BRACKET, SizeChar) + SizeChar);
            exit;
          end else
          begin // read childs nodes
            inc(pos, SizeChar);
            LoadNode(Result);
            open_pos := pos;
            continue;
          end;
        end;
      end;
      inc(pos, SizeChar);
    end;
  end;

var
  offset: int8;

begin
  Clear;

  if SizeBuf < 24 then
    exit;

  FEncoding := tcUTF8;
  SizeChar := 1;
  offset := 1;
  if (PWord(Ptr)^ = $FFFE) then
  begin
    SizeChar := 2;
    offset := 2;
    FEncoding := tcUnicodeBE;
  end
  else if (PWord(Ptr)^ = $FEFF) then
  begin
    SizeChar := 2;
    offset := 2;
    FEncoding := tcUnicodeLE;
  end
  else if (PWord(Ptr)^ = $BBEF) or (PWord(Ptr)^ = $EFBB) then
  begin
    FEncoding := tcUTF8;
    SizeChar := 1;
    offset := 2;
  end
  else
  begin
    if (pByte(Ptr)^ = $3C) then // <
    begin
      if (pByte(Ptr)[1] = $00) then // Little Endian
      begin
        SizeChar := 2;
        FEncoding := tcUnicodeLE;
      end
      else
      begin
        // SizeChar := 1;
        // FEncoding := tcANSI;
      end;
    end
    else if (pByte(Ptr)^ = $00) then // $00
    begin
      if (pByte(Ptr)[1] = $3C) then // <  Big Endian
      begin
        SizeChar := 2;
        FEncoding := tcUnicodeBE;
      end
      else
      begin // wtf?
        // SizeChar := 1;
        // FEncoding := tcANSI;
      end;
    end;
  end;

  GenerateServiceChars;

  pos := offset;

  if FindMem(@Ptr[pos], 4, $3F, 1) >= 0 then
  begin // XML-header
    // shift pos via header
    inc(pos, FindMem(Ptr, SizeBuf, S_MORE_BRACKET, SizeChar));
    CheckPos;
    // read encoding seted in header
    tmp := FindMem(Ptr, pos, PAnsiChar('g="'), 3);
    if tmp < 0 then
    begin
      tmp := FindMem(Ptr, pos, PAnsiChar('G="'), 3);
      if tmp < 0 then
      begin
        tmp := FindMem(Ptr, pos, PWideChar('g="'), 6);
        if tmp < 0 then
        begin
          tmp := FindMem(Ptr, pos, PAnsiChar('G="'), 6);
          if tmp >= 0 then
            inc(tmp, 6);
        end
        else
          inc(tmp, 6);
      end
      else
        inc(tmp, 3);
    end
    else
      inc(tmp, 3);
    if tmp > 0 then
    begin // find - read sign
      // inc(pos, tmp);
      e := FindMem(@Ptr[tmp], pos - tmp, S_QUOTE, SizeChar);
      TheCopyStr(enc_ch_w{%H-}, Pointer(@Ptr[tmp]), e, FEncoding);
      enc_ch_w := WideUpperCase(enc_ch_w);
      if ((enc_ch_w = 'UNICODE') or (enc_ch_w = 'UTF-16')) and (FEncoding <> tcUnicodeLE) and (FEncoding <> tcUnicodeBE) then
      begin
        SizeChar := 2;
        FEncoding := tcUnicodeLE;
        GenerateServiceChars;
      end
      else if (FindMem(@enc_ch_w[1], Length(enc_ch_w) * 2, PWideChar('WINDOWS'), 14) >= 0) and (FEncoding <> tcANSI) then
      begin
        SizeChar := 1;
        FEncoding := tcANSI;
        GenerateServiceChars;
      end
      else if (enc_ch_w = 'UTF-8') and (FEncoding <> tcUTF8) then
      begin
        SizeChar := 1; // only for service chars
        FEncoding := tcUTF8;
        GenerateServiceChars;
      end;
    end;
    // find first node
    inc(pos, FindMem(@Ptr[pos], SizeBuf - pos, S_SMALER_BRACKET, SizeChar));
    CheckPos;
    inc(pos, SizeChar);
  end;
  FRoot := LoadNode(nil);
end;

procedure TheXmlWriter.SetURL(AValue: string);
begin
  if FURL = AValue then
    exit;
  LoadFromURL(AValue);
end;

constructor TheXmlWriter.Create(const AURL: string; Load: boolean = false);
begin
  FEncoding := TTypeChar.tcUnicodeLE;
  FRoot := nil;
  FOnDeleteNode := nil;
  FOnAddNode := nil;
  FURL := AURL;
  if Load and FileExists(AURL) then
    LoadFromURL(FURL);
end;

function TheXmlWriter.DelNodeFromPath(const Path: WideString): boolean;
var
  sn: WideString;
  cn, prnt: TheXmlNode;
begin
  cn := FindNodeFromPath(Path);
  if cn = nil then
    exit(false);
  Result := true;
  prnt := cn.FParent;
  sn := cn.Name;
  cn.Delete;
  if prnt <> nil then
  begin
    cn := prnt.FindChildNode(sn);
    while cn <> nil do
    begin
      cn.Delete;
      cn := prnt.FindChildNode(sn);
    end;
  end;
end;

function TheXmlWriter.DelNodeFromPathByAttrib(const Path, AttribName: WideString;
  // true - значение искомого каждого следующего уровня сложено из значений предыдущих, т.е. из строки 1a\2a\3a\4a\
  // на первом уровне будет выполнятся поиск атрибута со значением 1a, на втором 1a\2a, на третьем 1a\2a\3a и т.д.
  // false - для каждого уровня значения разделяются, т.е. выполнится поиск значения 1a на первом уровне, 2a - на втором, 3a - на третьем, и т.д.
  SignLenInc: boolean): boolean;
var
  cn: TheXmlNode;
begin
  cn := FindNodeFromPathArrtib(Path, AttribName, SignLenInc);
  if cn = nil then
    exit(false);
  Result := true;
  cn.Delete;
end;

destructor TheXmlWriter.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TheXmlWriter.FindFirstEntryNameNodeFromPath(Parent: TheXmlNode; Path: WideString): TheXmlNode;
var
  i: Integer;
  sn, new_p: WideString;
  Ch: WideChar;
begin
  Result := nil;
  if FRoot = nil then
    exit;
  if Path[Length(Path)] <> '\' then
    new_p := Path + '\'
  else
    new_p := Path;
  for i := 1 to Length(new_p) do
  begin
    Ch := new_p[i];
    if (Ch = '\') or (Ch = '/') then
    begin
      if (0 < i - 1) then
      begin
        sn := Copy(new_p, 1, i - 1);
        if Parent <> nil then
        begin
          Result := Parent.FindChildNode(sn);
          if Result <> nil then
            exit;
        end
        else if WideUpperCase(FRoot.Name) = WideUpperCase(sn) then
          exit(FRoot);
      end;
    end;
  end;
end;

function TheXmlWriter.FindLastEntryNameNodeFromPath(Path: WideString): TheXmlNode;

var
  sl_all: array of WideString;

  function ParceStr(Str: WideString): int32;
  var
    new_p: WideString;
    l, j: int32;
  begin
    if Str[Length(Str)] <> '\' then
      new_p := Str + '\'
    else
      new_p := Str;
    l := Length(new_p);
    SetLength(sl_all, 0);
    Result := 0;
    for j := 1 to l do
    begin
      if (new_p[j] = '\') or (new_p[j] = '/') then
      begin
        inc(Result);
        SetLength(sl_all, Result);
        SetLength(sl_all[Result - 1], j);
        move(new_p[1], sl_all[Result - 1][1], j);
        // := Copy(new_p, 1, j);
        // sl_l.Add(Copy(new_p, 1, j));
      end;
    end;
  end;

var
  level: int32;
  prnt: TheXmlNode;
  S: WideString;
  Count: int32;

begin
  // sl_all := TStringList.Create;
  Count := ParceStr(Path);
  prnt := nil;
  level := 0;
  while level < Count do
  begin
    Result := FindFirstEntryNameNodeFromPath(prnt, ({%H-}sl_all[level]));
    if Result <> nil then
    begin
      prnt := Result;
      if level + 1 >= Count then
        break;
      S := sl_all[Count - 1];
      Count := ParceStr(PChar(@S[Length(sl_all[level]) + 1]));
      level := 0;
      continue;
    end;
    inc(level);
  end;
  SetLength(sl_all, 0);
  Result := prnt;
end;

function TheXmlWriter.FindNode(const Name: WideString; AllChilds: boolean): TheXmlNode;
begin
  Result := nil;
  if (FRoot <> nil) then
  begin
    if WideUpperCase(FRoot.Name) = WideUpperCase(Name) then
      Result := FRoot
    else
      Result := FRoot.FindChildNode(Name, AllChilds);
  end;
end;

function TheXmlWriter.FindNodeFromPath(const Path: WideString): TheXmlNode;
var
  i, st_pos, l: Integer;
  sn, new_p: WideString;
  Ch: WideChar;
  Last: TheXmlNode;
begin
  Result := nil;
  Last := nil;
  if FRoot = nil then
    exit;
  st_pos := 1;
  new_p := IncludeTrailingPathDelimiter(Path);
  l := Length(new_p);
  for i := 1 to l do
  begin
    Ch := new_p[i];
    if (Ch = '\') or (Ch = '/') then
    begin
      if (st_pos < i - 1) then
      begin
        sn := WideUpperCase(Copy(new_p, st_pos, i - st_pos));
        if Last <> nil then
        begin
          Result := Last.FindChildNode(sn);
          if Result <> nil then
          begin
            st_pos := i + 1;
            Last := Result;
            if i <> l then
              Result := nil;
          end;
        end
        else if WideUpperCase(FRoot.Name) = sn then
        begin
          Last := FRoot;
          if i = l then
            Result := FRoot;
          st_pos := i + 1;
        end;
      end;
    end;
  end;
end;

function TheXmlWriter.FindNodeFromPathArrtib(const Path, AttribName: WideString; SignLenInc: boolean): TheXmlNode;
var
  i, st_pos, l: Integer;
  sn, new_p: WideString;
  Ch: WideChar;
  Last: TheXmlNode;
begin
  Result := nil;
  Last := nil;
  if FRoot = nil then
    exit;
  st_pos := 1;
  new_p := IncludeTrailingPathDelimiter(UnicodeString(Path));
  l := Length(new_p);
  for i := 1 to l do
  begin
    Ch := new_p[i];
    if (Ch = '\') or (Ch = '/') then
    begin
      if (st_pos < i - 1) then
      begin
        if SignLenInc then
          sn := Copy(new_p, 1, i - 1)
        else
          sn := Copy(new_p, st_pos, i - st_pos);
        if Last <> nil then
        begin
          Result := Last.FindChildNodeWhithAttribSign(AttribName, sn, false);
          if Result <> nil then
          begin
            st_pos := i + 1;
            Last := Result;
            if i <> l then
              Result := nil;
          end;
        end
        else
        begin
          Last := FRoot.FindChildNodeWhithAttribSign(AttribName, sn, false);
          if Last <> nil then
          begin
            if i = l then
              Result := Last;
            st_pos := i + 1;
          end;

        end;
      end;
    end;
  end;
end;

{ function TheXmlWriter.ForceAddNodeFromAttributePath(ParentNode: TheXmlNode; AttribName: string;
  AttribPath: string): TheXmlNode;
  var
  sign: string;
  l, len_p: int32;
  i: Integer;
  NewPrnt: TheXmlNode;
  begin
  len_p := length(AttribPath);
  NewPrnt := ParentNode;
  if ParentNode <> nil then
  begin
  for i := 0 to ParentNode.CountChilds - 1 do
  begin
  sign := ParentNode.Childs[i].GetAttribute(AttribName, '');
  l := Length(sign);
  if (l > 0) and (len_p >= l) and (CompareMem(sign[1], AttribPath[1], l*2)) then
  begin
  if l + 1 = len_p then
  exit(ParentNode.Childs[i]);
  Result := ForceAddNodeFromAttributePath(ParentNode.Childs[i], AttribName, @AttribPath[l+1]);
  end;

  end;
  end;
  end; }

function TheXmlWriter.ForceAddNodeFromPath(const Path: WideString): TheXmlNode;
var
  i, st_pos, l: Integer;
  new_p, sn: WideString;
  prnt: TheXmlNode;
begin

  Result := FindLastEntryNameNodeFromPath(Path);
  if Result <> nil then
  begin
    prnt := Result;
    i := 0;
    while prnt <> nil do
    begin
      inc(i, Length(prnt.FName) + 1);
      prnt := prnt.FParent;
    end;
  end
  else
    i := 1;

  prnt := Result;
  if Path[Length(Path)] <> '\' then
    new_p := Path + '\'
  else
    new_p := Path;
  if (new_p[i] = '\') or (new_p[i] = '/') then
    inc(i);
  l := Length(new_p);
  st_pos := i;
  for i := i to l do
  begin
    if (new_p[i] = '\') or (new_p[i] = '/') then
    begin
      if (st_pos < i - 1) then
      begin
        sn := Copy(new_p, st_pos, i - st_pos);
        if prnt = nil then
        begin
          if (FRoot <> nil) then
          begin
            if WideUpperCase(FRoot.Name) <> WideUpperCase(sn) then
              raise Exception.Create('Can not create node with AParent <> nil in empty xml document!')
            else
              Result := FRoot;
          end
          else
            Result := CreateNode(nil, sn);
        end
        else
        begin
          Result := prnt.FindChildNode(sn);
          if Result = nil then
            Result := CreateNode(prnt, sn);
        end;
        prnt := Result;
      end;
      st_pos := i + 1;
    end;
  end;
end;

procedure TheXmlWriter.SaveChanges;
begin
  SaveToFile(FURL);
end;

procedure TheXmlWriter.SaveToFile(const FileName: string);
var
  f: TFileStream;
begin
  if FRoot = nil then
    raise Exception.Create('Can not save empty xml document!');
  f := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(f);
  finally
    f.Free;
  end;
end;

procedure TheXmlWriter.SaveToStream(Stream: TStream);
var
  bufW: WideString;
  bufA: AnsiString;
  bufUTF8: UTF8String;
begin
  Stream.Size := 0;
  case FEncoding of
    TTypeChar.tcUnicodeBE:
      begin
        Stream.WriteBuffer(HDR_BE_UNICODE, SizeOf(HDR_BE_UNICODE));
        Stream.WriteBuffer(LE_to_BE(XML_HDR_UNICODE)[1], Length(XML_HDR_UNICODE) * 2);
        if FInsertLineSeparator then
          Stream.WriteBuffer(LINE_SEPARATOR, 1);
        bufW := FRoot.GetTextWithChildBE;
        Stream.WriteBuffer(bufW[1], Length(bufW) * 2);
      end;
    TTypeChar.tcUnicodeLE:
      begin
        Stream.WriteBuffer(HDR_LE_UNICODE, SizeOf(HDR_LE_UNICODE));
        Stream.WriteBuffer(XML_HDR_UNICODE[1], Length(XML_HDR_UNICODE) * 2);
        if FInsertLineSeparator then
          Stream.WriteBuffer(LINE_SEPARATOR, 1);
        bufW := FRoot.GetTextWithChildLE;
        Stream.WriteBuffer(bufW[1], Length(bufW) * 2);
      end;
    TTypeChar.tcUTF8:
      begin
        Stream.WriteBuffer(XML_HDR_UTF8[1], Length(XML_HDR_UTF8));
        if FInsertLineSeparator then
          Stream.WriteBuffer(LINE_SEPARATOR, 1);
        bufUTF8 := FRoot.GetTextWithChildUTF8;
        Stream.WriteBuffer(bufUTF8[1], Length(bufUTF8));
      end;
    TTypeChar.tcANSI:
      begin
        bufA := '<?xml version="1.0" encoding="Windows-' + AnsiString(IntToStr(CurrentCP)) + '"?>';
        Stream.WriteBuffer(bufA[1], Length(bufA));
        if FInsertLineSeparator then
          Stream.WriteBuffer(LINE_SEPARATOR, 1);
        bufA := FRoot.GetTextWithChildAnsi;
        Stream.WriteBuffer(bufA[1], Length(bufA));
      end;
  end;
end;

procedure TheXmlWriter.LoadFromURL(const AURL: string);
var
  f: TMemoryStream;
begin
  FURL := AURL;
  if not FileExists(FURL) then
  begin
    Clear;
    exit;
  end;
  f := TMemoryStream.Create;
  try
    f.LoadFromFile(FURL);
    LoadFromBuf(f.Memory, f.Size);
  finally
    f.Free;
  end;
end;

procedure TheXmlWriter.OnDeleteNodeNotify(Node: TheXmlNode);
begin
  if Assigned(FOnDeleteNode) then
    FOnDeleteNode(Node);
end;

procedure TheXmlWriter.LoadFromText(Text: PAnsiChar; LenInBytes: int32);
begin
  LoadFromBuf(pByte(Text), LenInBytes);
end;

procedure TheXmlWriter.LoadFromText(Text: PWideChar; LenInBytes: int32);
begin
  LoadFromBuf(pByte(Text), LenInBytes);
end;

procedure TheXmlWriter.LoadFromStream(Stream: TStream);
var
  f: TMemoryStream;
begin
  f := TMemoryStream.Create;
  try
    f.LoadFromStream(Stream);
    LoadFromBuf(f.Memory, f.Size);
  finally
    f.Free;
  end;
end;

procedure TheXmlWriter.Clear;
begin
  FreeAndNil(FRoot);
end;

function TheXmlWriter.CreateNode(AParent: TheXmlNode; const AName: WideString): TheXmlNode;
begin
  if Assigned(AParent) then
    Result := TheXmlNode.Create(AParent, AName)
  else
    Result := TheXmlNode.Create(FRoot, AName);

  if FRoot = nil then
    FRoot := Result;

  Result.FTree := Self;
  if Assigned(FOnAddNode) then
    FOnAddNode(Result);
end;

initialization

{$IFDEF MSWindows}
  CurrentCP := GetACP;
{$ELSE}
  CurrentCP := CP_UTF8;
{$ENDIF}

end.
