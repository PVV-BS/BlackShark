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


unit bs.textprocessor;

{$I BlackSharkCfg.inc}

interface

uses
    bs.baseTypes
  , bs.font
  , bs.collections
  , bs.align
  ;

type

  PLineProp = ^TLineProp;
  TLineProp = record
    { line width }
    Width: BSFloat;
    Height: BSFloat;
    { count blanks }
    CountBlanks: int32;
    { count chars }
    CountChars: int32;
    { blanks in lines b/w words }
    InsideBlanks: int32;
    IndexBegin: int32;
  end;

  TSelectorKey = function (Index: int32; out Code: int32): PKeyInfo of object;
  TQueryAverageWidth = function (Index: int32): BSFloat of object;

  TTextProcessor = class
  private
    FDelta: int8;
    FWidth: BSFloat;
    FInterligne: int16;
    FAlignText: TObjectAlign;
    FHeight: BSFloat;
    FillCount: int32;
    RectSize: TVec2f;
    FLines: TListVec<TLineProp>;
    FAllowBrakeWords: boolean;
    FOnQueryKey: TSelectorKey;
    FCountChars: int32;
    FLineHeight: int32;
    FOnQueryAverageWidthForCurrentPos: TQueryAverageWidth;
    procedure SetAlignText(const Value: TObjectAlign);
    procedure SetDelta(const Value: int8);
    procedure SetInterligne(const Value: int16);
    procedure SetAllowBrakeWords(const Value: boolean);
    procedure SetCountChars(const Value: int32);
    procedure SetLineHeight(const Value: int32);
  public
    constructor Create(AKeySelector: TSelectorKey; AQueryAverageWidth: TQueryAverageWidth);
    destructor Destroy; override;
    procedure Build(PositionBegin: int32 = 1);
    procedure Add;
    procedure BeginFill;
    procedure EndFill;
    function GetCharWidth(Key: PKeyInfo): int32;
    procedure SetOutRect(Width, Height: BSFloat);
    function GetIndexLineFromIndexChar(IndexChar: int32): int32;
    function GetIndexLineFromOffsetY(OffsetY: BSFloat): int32;
    property CountChars: int32 read FCountChars write SetCountChars;
    { size text in pixels }
    property Width: BSFloat read FWidth;
    property Height: BSFloat read FHeight;
    { distance b/w chars }
    property Delta: int8 read FDelta write SetDelta;
    { distance b/w lines }
    property Interligne: int16 read FInterligne write SetInterligne;
    property AlignText: TObjectAlign read FAlignText write SetAlignText;
    property AllowBrakeWords: boolean read FAllowBrakeWords write SetAllowBrakeWords;
    property OnQueryKey: TSelectorKey read FOnQueryKey write FOnQueryKey;
    property OnQueryAverageWidthForCurrentPos: TQueryAverageWidth read FOnQueryAverageWidthForCurrentPos write FOnQueryAverageWidthForCurrentPos;
    property LineHeight: int32 read FLineHeight write SetLineHeight;
    property Lines: TListVec<TLineProp> read FLines;
  end;

implementation

  uses SysUtils, Math, bs.shader, bs.gl.es;

{ TTextProcessor }

procedure TTextProcessor.Add;
begin
  inc(FCountChars);
  if FillCount = 0 then
    Build(FCountChars);
end;

procedure TTextProcessor.BeginFill;
begin
  inc(FillCount);
end;

procedure TTextProcessor.Build(PositionBegin: int32 = 1);
var
  i: int32;
  { chars in current a word }
  chars: int32;
  { blanks befor current the word }
  blanks_befor_word: int32;
  prop: TLineProp;
  word_width: BSFloat;
  out_width: BSFloat;
  sum_width: BSFloat;
  add: BSFloat;
  KeyInfo: PKeyInfo;
  first_word: boolean;
  word_reads: boolean;
  code: int32;
  avr_width_ch: BSFloat;
begin
  if (FAlignText <> TObjectAlign.oaLeft) and (RectSize.x > 0) then
    out_width := RectSize.x
  else
    out_width := MaxSingle;
  prop.Width := 0.0;
  prop.Height := 0.0;
  prop.CountChars := 0;
  prop.CountBlanks := 0;
  prop.InsideBlanks := 0;
  prop.IndexBegin := PositionBegin;
  word_width := 0.0;
  chars := 0;
  blanks_befor_word := 0;
  first_word := true;
  word_reads := false;
  FWidth := 0;
  FHeight := 0;

  if PositionBegin > 1 then
  begin
    for i := 1 to FLines.Count - 1 do
    begin
      if PositionBegin <= FLines.Items[i].IndexBegin then
      begin
        FLines.Count := i - 1;
        if FLines.Count > 0 then
          PositionBegin := FLines.Items[FLines.Count - 1].IndexBegin
        else
          PositionBegin := 0;
        break;
      end;
      if FLines.Items[i].Width > FWidth then
        FWidth := FLines.Items[i].Width;
    end;
  end else
  begin
    FLines.Count := 0;
  end;
  prop.IndexBegin := PositionBegin;
  { it sets var "add" and "sum_width" to avoid warning }
  //add := 0.0;
  //sum_width := 0.0;
  avr_width_ch := FOnQueryAverageWidthForCurrentPos(PositionBegin);
  for i := PositionBegin to FCountChars do
  begin
    inc(prop.CountChars);
    KeyInfo := FOnQueryKey(i, code); //FMap.Items[i];
    if code = $09 then
    begin
      if word_reads then
      begin
        blanks_befor_word := 0;
        word_reads := false;
      end;
      add := avr_width_ch;
      inc(prop.CountBlanks, 2);
      inc(blanks_befor_word, 2);
      //word_width := 0;
      chars := 0;
      sum_width := add;
    end else
    if (code = $20) then
    begin
      if word_reads then
      begin
        blanks_befor_word := 0;
        word_reads := false;
      end;
      inc(prop.CountBlanks);
      inc(blanks_befor_word);
      add := avr_width_ch * 0.5;
      chars := 0;
      sum_width := add;
    end else
    if (KeyInfo = nil) then
    begin
      continue;
    end else
    begin
      if (not word_reads) then
      begin
        if not first_word then
          inc(prop.InsideBlanks, blanks_befor_word);
        //blanks := 0;
        word_width := 0;
        word_reads := true;
      end;
      first_word := false;
      sum_width := KeyInfo^.Rect.Width;
      add := sum_width + FDelta;
      word_width := word_width + add;
      inc(chars);
    end;

    if (KeyInfo <> nil) and (KeyInfo.Rect.Height > prop.Height) then
      prop.Height := KeyInfo.Rect.Height;

    prop.Width := prop.Width + add;

    if (code = $0d) or (prop.Width + sum_width > out_width) then
    begin
      if FAllowBrakeWords or (code = $0d) or (code = $20) or (code = $09) then
      begin
        if prop.Width > FWidth then
          FWidth := prop.Width;
        if FLineHeight = 0 then
          FHeight := FHeight + prop.Height + FInterligne;

        FLines.Add(prop);
        prop.Width := 0.0;
        prop.Height := 0.0;
        prop.CountChars := 1;
        prop.IndexBegin := i;
        chars := 0;
        word_width := 0.0;
        word_reads := false;
      end else
      //if word_width + add < out_width then
      begin // roll back on one word
        dec(prop.CountChars, chars);
        prop.Width := prop.Width - word_width;
        if prop.Width > FWidth then
          FWidth := prop.Width;
        if FLineHeight = 0 then
          FHeight := FHeight + prop.Height + FInterligne;

        if (prop.CountChars > 0) and (prop.Width > 0) then
          FLines.Add(prop);

        prop.IndexBegin := i - chars + 1;
        prop.Width := word_width;
        prop.CountChars := chars;
        word_reads := true;
        //continue;
      end;
      blanks_befor_word := 0;
      prop.InsideBlanks := 0;
      prop.CountBlanks := 0;
    end;
  end;

  if prop.Width > 0 then
  begin
    if prop.Width > FWidth then
      FWidth := prop.Width;
    if FLineHeight = 0 then
      FHeight := FHeight + prop.Height + FInterligne;
    FLines.Add(prop);
  end;

  if FLineHeight > 0 then
    FHeight := FLines.Count * (FLineHeight + FInterligne);

end;

constructor TTextProcessor.Create(AKeySelector: TSelectorKey; AQueryAverageWidth: TQueryAverageWidth);
begin
  Assert(Assigned(AKeySelector), 'A parameter AKeySelector must be valid!');
  FDelta := 1;
  FInterligne := 3;
  FAllowBrakeWords := false;
  FOnQueryKey := AKeySelector;
  FOnQueryAverageWidthForCurrentPos := AQueryAverageWidth;
  FLines := TListVec<TLineProp>.Create;
end;

destructor TTextProcessor.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TTextProcessor.EndFill;
begin
  dec(FillCount);
  if FillCount < 0 then
    FillCount := 0;
  if FillCount = 0 then
    Build(1);
end;

function TTextProcessor.GetCharWidth(Key: PKeyInfo): int32;
begin
  if Key.Code = 9 then
    Result := round(Key.Rect.Width) shl 1 // Tab has double blank
  else
  if Key.Code = 32 then
    Result := round(Key.Rect.Width) // Blank without Delta
  else
    Result := round(Key.Rect.Width) + Delta;
end;

function TTextProcessor.GetIndexLineFromIndexChar(IndexChar: int32): int32;
var
  l: PLineProp;
begin

  for Result := 0 to FLines.Count - 1 do
    begin
    l := FLines.ShiftData[Result];
    if (IndexChar < l.IndexBegin + l.CountChars) then
      exit;
    end;

  if FLines.Count > 0 then
    Result := 0
  else
    Result := -1;
end;

function TTextProcessor.GetIndexLineFromOffsetY(OffsetY: BSFloat): int32;
begin
  if (FInterligne > 0) or (FLineHeight > 0) then
    Result := round(OffsetY) {%H-}div (FLineHeight + FInterligne)
  else
    Result := 0;

  if Result >= FLines.Count then
    Result := -1;
end;

procedure TTextProcessor.SetAlignText(const Value: TObjectAlign);
begin
  FAlignText := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetAllowBrakeWords(const Value: boolean);
begin
  FAllowBrakeWords := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetCountChars(const Value: int32);
begin
  FCountChars := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetDelta(const Value: int8);
begin
  FDelta := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetInterligne(const Value: int16);
begin
  FInterligne := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetLineHeight(const Value: int32);
begin
  FLineHeight := Value;
  if FillCount = 0 then
    Build(1);
end;

procedure TTextProcessor.SetOutRect(Width, Height: BSFloat);
begin
  RectSize.x := Width;
  RectSize.y := Height;
  if FillCount = 0 then
    Build(1);
end;

end.
