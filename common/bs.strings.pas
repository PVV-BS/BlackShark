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

unit bs.strings;

{$I BlackSharkCfg.inc}

interface

type

  { be careful to use TString: mandatory need to initialize by TString.Create }

  { TString }

  TString = record
  private
    FText: WideString;
  public
    procedure Create;
    procedure Free;
    procedure Clear;

    procedure Insert(Index: int32; Value: Char); overload;
    procedure Insert(Index: int32; const Value: string); overload;
    procedure Delete(Index: int32; Count: int32 = 1);

    function CharsW(Index: int32): WideChar; inline;
    function CharsUnsafeW(Index: int32): WideChar; inline;
    procedure SetText(const Value: string);
    function GetText: string;
    function Len: int32; //inline;
  public
    class operator Implicit (const v: string): TString; inline;
    //class operator Implicit (const v: AnsiString): TString; inline;
    class operator Implicit (const v: TString): string; inline;
    class operator Equal (const v1: TString; const v2: string): boolean; inline;
    class operator Add (const v1, v2: TString): TString; inline;
    class operator Add (const v1: string; const v2: TString): TString; inline;
    class operator Add (const v1: TString; const v2: string): TString; inline;
  end;
  PString = ^TString;

{ converts strings regardless of a compiler kind }
function AnsiToWide(const Ansi: AnsiString): WideString; inline;
function AnsiToString(const Ansi: AnsiString): string; inline;
function StringToAnsi(const Str: string): AnsiString; inline;
function WideToAnsi(const Unicode: WideString): AnsiString; inline;
function WideToString(const Unicode: WideString): string; inline;
function StringToWide(const Str: string): WideString; inline;
{ length of string, bytes }
function StrLengthInBytes(Value: PChar): int32; inline; overload;
function StrLengthInBytes(const Value: string): int32; inline; overload;
function AnsiUp(const Ansi: AnsiString): AnsiString; inline;

var
  g_UpChars: array[AnsiChar] of AnsiChar;

implementation

uses
  {$ifdef FPC}
    {$ifndef ultibo}
      LazUTF8,
    {$endif}
  {$endif}
    SysUtils
  ;


procedure FillUpChars;
var
  ch: AnsiChar;
begin
  for ch := Low(AnsiChar) to High(AnsiChar) do
    g_UpChars[ch] := StringToAnsi(AnsiUpperCase(string(ch)))[1];
end;

function AnsiUp(const Ansi: AnsiString): AnsiString; inline;
var
  i: int32;
begin
  SetLength(Result, Length(Ansi));
  for i := 1 to Length(Ansi) do
    Result[i] := g_UpChars[Ansi[i]];
end;

function StrLengthInBytes(Value: PChar): int32;
begin
  {$ifdef FPC}
  Result := Length(Value);
  {$else}
  Result := Length(Value) * SizeOf(Char);
  {$endif}
end;

function StrLengthInBytes(const Value: string): int32;
begin
  {$ifdef FPC}
  Result := Length(Value);
  {$else}
  Result := Length(Value) * SizeOf(Char);
  {$endif}
end;

function WideToAnsi(const Unicode: WideString): AnsiString;
begin
  {$ifdef FPC}
  Result := UTF8Encode(Unicode);
  {$else}
  Result := AnsiString(Unicode);
  {$endif}
end;

function WideToString(const Unicode: WideString): string;
begin
  {$ifdef FPC}
  Result := UTF8Encode(Unicode);
  {$else}
  Result := Unicode;
  {$endif}
end;

function StringToWide(const Str: string): WideString; inline;
begin
  {$ifdef FPC}
  Result := UTF8Decode(Str);
  {$else}
  Result := Str;
  {$endif}
end;

function AnsiToWide(const Ansi: AnsiString): WideString;
begin
  {$ifdef FPC}
  Result := UTF8Decode(Ansi);
  {$else}
  Result := WideString(Ansi);
  {$endif}
end;

function AnsiToString(const Ansi: AnsiString): string; inline;
begin
  {$ifdef FPC}
  Result := AnsiToUtf8(Ansi);
  {$else}
  Result := string(Ansi);
  {$endif}
end;

function StringToAnsi(const Str: string): AnsiString; inline;
begin
  {$ifdef FPC}
  Result := UTF8Encode(Str);
  {$else}
  Result := AnsiString(Str);
  {$endif}
end;

{ TString }

class operator TString.Add(const v1, v2: TString): TString;
begin
  Result.FText := v1.FText + v2.FText;
end;

procedure TString.Clear;
begin
  SetLength(FText, 0);
end;

procedure TString.Create;
begin
  Initialize(Self);
end;

procedure TString.Delete(Index: int32; Count: int32);
var
  l: int32;
begin
  if (Index > Length(FText)) or (Index < 1) or (Count <= 0) then
    exit;
  if Index + Count - 1 > Length(FText) then
    l := Length(FText) - Index + 1 else
    begin
    l := Count;
    if Length(FText) <> l then
      Move(FText[Index + l], FText[Index], (Length(FText) - Index - l + 1) * SizeOf(WideChar));
    end;
  SetLength(FText, Length(FText) - l);
end;

procedure TString.Free;
begin
  Finalize(Self);
end;

class operator TString.Add(const v1: string; const v2: TString): TString;
begin
  Result.FText := StringToWide(v1) + v2.FText;
end;

class operator TString.Add(const v1: TString; const v2: string): TString;
begin
  Result.FText := v1.FText + StringToWide(v2);
end;

function TString.CharsUnsafeW(Index: int32): WideChar;
begin
  Result := FText[Index];
end;

function TString.CharsW(Index: int32): WideChar;
begin
  if (Index > 0) and (Index <= Len) then
    Result := FText[Index]
  else
    Result := #0;
end;

function TString.GetText: string;
begin
  Result := WideToString(FText);
end;

procedure TString.Insert(Index: int32; Value: Char);
begin
  if Index < 1 then
    Index := 1;
  if Index > Len - 1 then
    Index := Len;
  SetLength(FText, Len + 1);
  if Index <= Len then
    Move(FText[Index], FText[Index + 1], (Len - Index + 1) * SizeOf(WideChar));
  FText[Index] := WideChar(Value);
end;

class operator TString.Implicit (const v: string): TString;
begin
  Result.FText := StringToWide(v);
end;

class operator TString.Implicit(
  const v: TString): string;
begin
  Result := WideToString(v.FText);
end;

procedure TString.Insert(Index: int32; const Value: string);
var
  ch_count: int32;
  w_str: WideString;
begin
  if Value = '' then
    exit;
  if Index < 1 then
    Index := 1;
  if Index - 1 > Len then
    Index := Len;

  w_str := StringToWide(Value);
  ch_count := Length(w_str);
  SetLength(FText, Len + ch_count);
  if Index <= Len then
    Move(FText[Index], FText[Index + ch_count], (Len - Index + 1) * SizeOf(WideChar));
  move(w_str[1], FText[Index], ch_count * SizeOf(WideChar));
end;

function TString.Len: int32;
begin
  Result := Length(FText);
end;

class operator TString.Equal(const v1: TString; const v2: string): boolean;
begin
  Result := v1.FText = StringToWide(v2);
end;

procedure TString.SetText(const Value: string);
begin
  FText := StringToWide(Value);
end;

initialization

  FillUpChars;

finalization


end.

