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

unit bs.gui.themes.primitives;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , typinfo
  , XmlWriter
  , bs.strings
  , bs.basetypes
  , bs.gui.themes
  ;

type

  { TStyleFloat }

  TStyleFloat = class(TStyleTemplate<BSFloat>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleTVec4f }

  TStyleTVec4f = class(TStyleItem)
  private
    Value: TVec4f;
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    procedure GetValue(out ValueLocation); override;
    procedure SetValue(const ValueLocation); override;
    function AsString: string; override;
    function SizeValue: int32; override;
    procedure FromString(const Value: string); override;
    class function TypeName: AnsiString; override;
  end;

  { TStyleTVec2f }

  TStyleTVec2f = class(TStyleItem)
  private
    Value: TVec2f;
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    procedure GetValue(out ValueLocation); override;
    procedure SetValue(const ValueLocation); override;
    function AsString: string; override;
    function SizeValue: int32; override;
    procedure FromString(const Value: string); override;
    //class procedure WriteToProperty(Group: TStyleGroup;
    //  Prop: PPropInfo; Instance: Pointer); override;
    class function TypeName: AnsiString; override;
  end;

  { TStyleInt32 }

  TStyleInt32 = class(TStyleTemplate<int32>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleColor }

  {TStyleColor = class(TStyleTemplate<TColor>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;   }

  { TStyleGuiColor }

  TStyleGuiColor = class(TStyleTemplate<TGuiColor>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleInteger }

  TStyleInteger = class(TStyleInt32);

  { TStyleInt8 }

  TStyleInt8 = class(TStyleTemplate<Int8>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleInt16 }

  TStyleInt16 = class(TStyleTemplate<Int16>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleLongInt }

  TStyleLongInt = class(TStyleTemplate<LongInt>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleInt64 }

  TStyleInt64 = class(TStyleTemplate<int64>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleByte }

  TStyleByte = class(TStyleTemplate<Byte>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleBool }

  TStyleBool = class(TStyleTemplate<boolean>)
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    function AsString: string; override;
    procedure FromString(const Value: string); override;
  end;

  { TStyleString }

  TStyleString = class(TStyleItem)
  private
    FValue: string;
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    procedure GetValue(out ValueLocation); override;
    procedure SetValue(const ValueLocation); override;
    function AsString: string; override;
    function SizeValue: int32; override;
    procedure FromString(const Value: string); override;
    { setter to property of control (published) from the style item }
    procedure WriteToProperty(Prop: PPropInfo; Instance: Pointer); override;
    { reads property value to the style item }
    procedure ReadFromProperty(Prop: PPropInfo; Instance: Pointer); override;
    class function TypeName: AnsiString; override;
    property Value: string read FValue;
  end;

  { TStyleAnsiString }

  TStyleAnsiString = class(TStyleItem)
  private
    FValue: AnsiString;
  public
    procedure Save(Node: TheXmlNode); override;
    procedure Load(Node: TheXmlNode); override;
    procedure GetValue(out ValueLocation); override;
    procedure SetValue(const ValueLocation); override;
    function AsString: string; override;
    function SizeValue: int32; override;
    procedure FromString(const Value: string); override;
    { setter to property of control (published) from the style item }
    procedure WriteToProperty(Prop: PPropInfo; Instance: Pointer); override;
    { reads property value to the style item }
    procedure ReadFromProperty(Prop: PPropInfo; Instance: Pointer); override;
    class function TypeName: AnsiString; override;
    property Value: AnsiString read FValue;
  end;

implementation

uses
    SysUtils
  , bs.utils
  ;

{ TStyleAnsiString }

procedure TStyleAnsiString.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

procedure TStyleAnsiString.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', AnsiString(''));
end;

procedure TStyleAnsiString.ReadFromProperty(Prop: PPropInfo; Instance: Pointer);
begin
  FValue := TPropValueAccessProvider<AnsiString>.GetPropValue(Instance, Prop);
end;

procedure TStyleAnsiString.GetValue(out ValueLocation);
begin
  AnsiString(ValueLocation) := FValue;
end;

procedure TStyleAnsiString.SetValue(const ValueLocation);
begin
  FValue := AnsiString(ValueLocation);
end;

function TStyleAnsiString.AsString: string;
begin
  Result := AnsiToString(FValue);
end;

function TStyleAnsiString.SizeValue: int32;
begin
  Result := Length(FValue);
end;

procedure TStyleAnsiString.FromString(const Value: string);
begin
  Self.FValue := StringToAnsi(Value);
end;

class function TStyleAnsiString.TypeName: AnsiString;
begin
  Result := 'AnsiString';
end;

procedure TStyleAnsiString.WriteToProperty(Prop: PPropInfo; Instance: Pointer);
begin
  TPropValueAccessProvider<AnsiString>.SetPropValue(Instance, Prop, Value);
end;

{ TStyleLongInt }

function TStyleLongInt.AsString: string;
begin
  Result := IntToStr(Value);
end;

procedure TStyleLongInt.FromString(const Value: string);
var
  val: Integer;
begin
  if TryStrToInt(Value, val) then
    Self.FValue := LongInt(val);
end;

procedure TStyleLongInt.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleLongInt.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleString }

procedure TStyleString.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

procedure TStyleString.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', String(''));
end;

procedure TStyleString.ReadFromProperty(Prop: PPropInfo; Instance: Pointer);
begin
  FValue := TPropValueAccessProvider<string>.GetPropValue(Instance, Prop);
end;

procedure TStyleString.GetValue(out ValueLocation);
begin
  string(ValueLocation) := FValue;
end;

procedure TStyleString.SetValue(const ValueLocation);
begin
  FValue := string(ValueLocation);
end;

function TStyleString.AsString: string;
begin
  Result := FValue;
end;

function TStyleString.SizeValue: int32;
begin
  Result := StrLengthInBytes(FValue);
end;

procedure TStyleString.FromString(const Value: string);
begin
  Self.FValue := Value;
end;

class function TStyleString.TypeName: AnsiString;
begin
  Result := 'string';
end;

procedure TStyleString.WriteToProperty(Prop: PPropInfo; Instance: Pointer);
begin
  TPropValueAccessProvider<string>.SetPropValue(Instance, Prop, FValue);
end;

{ TStyleFloat }

function TStyleFloat.AsString: string;
begin
  Result := FloatToStr(Value);
end;

procedure TStyleFloat.FromString(const Value: string);
begin
  TryStrToFloat(Value, Self.FValue);
end;

procedure TStyleFloat.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleFloat.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleTVec4f }

function TStyleTVec4f.AsString: string;
begin
  Result := VecToStr(Value);
end;

function TStyleTVec4f.SizeValue: int32;
begin
  Result := SizeOf(TVec4f);
end;

procedure TStyleTVec4f.FromString(const Value: string);
begin
  raise Exception.Create('Do not implement!');
end;

procedure TStyleTVec4f.GetValue(out ValueLocation);
begin
  move(Value, ValueLocation{%H-}, SizeOf(Value));
end;

procedure TStyleTVec4f.Load(Node: TheXmlNode);
begin
  Value.x := Node.GetAttribute('x', Value.x);
  Value.y := Node.GetAttribute('y', Value.y);
  Value.z := Node.GetAttribute('z', Value.x);
  Value.w := Node.GetAttribute('w', Value.w);
end;

procedure TStyleTVec4f.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('x', Value.x);
  Node.AddAttribute('y', Value.y);
  Node.AddAttribute('z', Value.x);
  Node.AddAttribute('w', Value.w);
end;

procedure TStyleTVec4f.SetValue(const ValueLocation);
begin
  move(ValueLocation, Value, SizeOf(Value));
end;

class function TStyleTVec4f.TypeName: AnsiString;
begin
  Result := 'TVec4f';
end;

{ TStyleTVec2f }

function TStyleTVec2f.AsString: string;
begin
  Result := VecToStr(Value);
end;

function TStyleTVec2f.SizeValue: int32;
begin
  Result := SizeOf(TVec2f);
end;

procedure TStyleTVec2f.FromString(const Value: string);
begin
  raise Exception.Create('Do not implement!');
end;

procedure TStyleTVec2f.GetValue(out ValueLocation);
begin
{%H-}  move(Value, ValueLocation{%H-}, SizeOf(Value));
end;

procedure TStyleTVec2f.Load(Node: TheXmlNode);
begin
  Value.x := Node.GetAttribute('x', Value.x);
  Value.y := Node.GetAttribute('y', Value.y);
end;

procedure TStyleTVec2f.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('x', Value.x);
  Node.AddAttribute('y', Value.y);
end;

procedure TStyleTVec2f.SetValue(const ValueLocation);
begin
{%H-}  move(ValueLocation, Value, SizeOf(Value));
end;

class function TStyleTVec2f.TypeName: AnsiString;
begin
  Result := 'TVec2f';
end;

{ TStyleInt32 }

function TStyleInt32.AsString: string;
begin
  Result := IntToStr(FValue);
end;

procedure TStyleInt32.FromString(const Value: string);
begin
  TryStrToInt(Value, Self.FValue);
end;

procedure TStyleInt32.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleInt32.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleInt64 }

function TStyleInt64.AsString: string;
begin
  Result := IntToStr(FValue);
end;

procedure TStyleInt64.FromString(const Value: string);
begin
  TryStrToInt64(Value, Self.FValue);
end;

procedure TStyleInt64.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleInt64.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleColor }

{function TStyleColor.AsString: string;
begin
  Result := IntToHex(FValue, 8);
end;  }

//procedure TStyleColor.FromString(const Value: string);
//{$ifdef FPC}
//var
//  s: AnsiString;
//{$endif}
//begin
//  if Value <> '' then
//  begin
//    {$ifdef FPC}
//    s:= StringToAnsi(Value);
//    HexToBin(PChar(@s[1]), Pointer(@FValue), SizeOf(FValue));
//    {$else}
//    HexToBin(PWideChar(@StringToWide(Value)[1]), Pointer(@FValue), SizeOf(FValue));
//    {$endif}
//  end;
//end;

{procedure TStyleColor.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleColor.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;     }

{ TStyleInt8 }

function TStyleInt8.AsString: string;
begin
  Result := IntToStr(Value);
end;

procedure TStyleInt8.FromString(const Value: string);
var
  i: int32;
begin
  if TryStrToInt(Value, i) then
    Self.FValue := i;
end;

procedure TStyleInt8.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleInt8.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleInt16 }

function TStyleInt16.AsString: string;
begin
  Result := IntToStr(Value);
end;

procedure TStyleInt16.FromString(const Value: string);
var
  i: int32;
begin
  if TryStrToInt(Value, i) then
    Self.FValue := i;
end;

procedure TStyleInt16.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleInt16.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleBool }

function TStyleBool.AsString: string;
begin
  Result := BoolToStr(Value);
end;

procedure TStyleBool.FromString(const Value: string);
begin
  Self.FValue := StrToBoolDef(Value, false);
end;

procedure TStyleBool.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleBool.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleByte }

function TStyleByte.AsString: string;
begin
  Result := IntToStr(Value);
end;

procedure TStyleByte.FromString(const Value: string);
var
  i: int32;
begin
  if TryStrToInt(Value, i) then
    Self.FValue := i;
end;

procedure TStyleByte.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleByte.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

{ TStyleGuiColor }

function TStyleGuiColor.AsString: string;
begin
  Result := IntToHex(FValue, 8);
end;

procedure TStyleGuiColor.FromString(const Value: string);
{$ifdef FPC}
var
  s: AnsiString;
{$endif}
begin
  if Value <> '' then
  begin
    {$ifdef FPC}
    s:= StringToAnsi(Value);
    HexToBin(PChar(@s[1]), Pointer(@FValue), SizeOf(FValue));
    {$else}
    HexToBin(PWideChar(@StringToWide(Value)[1]), Pointer(@FValue), SizeOf(FValue));
    {$endif}
  end;
end;

procedure TStyleGuiColor.Load(Node: TheXmlNode);
begin
  FValue := Node.GetAttribute('v', FValue);
end;

procedure TStyleGuiColor.Save(Node: TheXmlNode);
begin
  Node.AddAttribute('v', FValue);
end;

initialization

  TThemeManager.RegisterStyleItem(TStyleFloat);
  TThemeManager.RegisterStyleItem(TStyleTVec4f);
  TThemeManager.RegisterStyleItem(TStyleInt32);
  TThemeManager.RegisterStyleItem(TStyleInt8);
  TThemeManager.RegisterStyleItem(TStyleInt16);
  TThemeManager.RegisterStyleItem(TStyleBool);
  TThemeManager.RegisterStyleItem(TStyleLongInt);
  TThemeManager.RegisterStyleItem(TStyleInt64);
  TThemeManager.RegisterStyleItem(TStyleInteger);
  TThemeManager.RegisterStyleItem(TStyleString);
  TThemeManager.RegisterStyleItem(TStyleAnsiString);
  //TThemeManager.RegisterStyleItem(TStyleColor);
  TThemeManager.RegisterStyleItem(TStyleGuiColor);

finalization

end.
