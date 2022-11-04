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


unit bs.textprocessor;

{$I BlackSharkCfg.inc}

interface

uses
    bs.baseTypes
  , bs.font
  , bs.collections
  ;

type

  PLineProp = ^TLineProp;
  TLineProp = record
    { line width }
    Width: BSFloat;
    Height: BSFloat;
    TrimWidth: BSFloat;
    { count blanks }
    CountBlanks: int32;
    { count chars }
    CountChars: int32;
    { blanks in lines b/w words }
    InsideBlanks: int32;
    IndexBegin: int32;
    Words: int32;
  end;

  TSelectorKey = function (Index: int32; out Code: int32): PKeyInfo of object;
  TQueryAverageWidth = function (Index: int32): BSFloat of object;

  TTextProcessor = class
  private
    FDelta: int8;
    FWidth: BSFloat;
    FInterligne: int16;
    FHeight: BSFloat;
    FillCount: int32;
    FViewportWidth: BSFloat;
    FLines: TListVec<TLineProp>;
    FAllowBreakWords: boolean;
    FOnQueryKey: TSelectorKey;
    FCountChars: int32;
    FLineHeight: int32;
    FBlankWidth: BSFloat;
    procedure SetDelta(const Value: int8);
    procedure SetInterligne(const Value: int16);
    procedure SetAllowBreakWords(const Value: boolean);
    procedure SetCountChars(const Value: int32);
    procedure SetLineHeight(const Value: int32);
    procedure SetViewportWidth(const Value: BSFloat);
  public
    constructor Create(AKeySelector: TSelectorKey);
    destructor Destroy; override;
    procedure Build(PositionBegin: int32 = 1); virtual;
    function GetCharWidth(Key: PKeyInfo): int32;
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
    property AllowBreakWords: boolean read FAllowBreakWords write SetAllowBreakWords;
    property OnQueryKey: TSelectorKey read FOnQueryKey write FOnQueryKey;
    property LineHeight: int32 read FLineHeight write SetLineHeight;
    property Lines: TListVec<TLineProp> read FLines;
    property ViewportWidth: BSFloat read FViewportWidth write SetViewportWidth;
    property BlankWidth: BSFloat read FBlankWidth write FBlankWidth;
  end;

implementation

uses
    SysUtils
  , Math
  , bs.shader
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  ;

{ TTextProcessor }

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
  add: BSFloat;
  KeyInfo: PKeyInfo;
  first_word: boolean;
  word_reads: boolean;
  code: int32;
begin
  if (ViewportWidth > 0) then
    out_width := ViewportWidth
  else
    out_width := MaxSingle;

  prop.Width := 0.0;
  prop.TrimWidth := 0.0;
  prop.Height := 0.0;
  prop.CountChars := 0;
  prop.CountBlanks := 0;
  prop.InsideBlanks := 0;
  prop.IndexBegin := PositionBegin;
  prop.Words := 0;
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
  prop.Width := 0.0;

  for i := PositionBegin to FCountChars do
  begin
    inc(prop.CountChars);
    KeyInfo := FOnQueryKey(i, code);
    if code = $09 then
    begin
      if word_reads then
      begin
        blanks_befor_word := 0;
        word_reads := false;
      end;
      add := FBlankWidth*2;
      inc(prop.CountBlanks, 2);
      inc(blanks_befor_word, 2);
      chars := 0;
      if not first_word then
        prop.TrimWidth := prop.Width + add;
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
      add := FBlankWidth;
      chars := 0;
      if not first_word then
        prop.TrimWidth := prop.Width + add;
    end else
    if (KeyInfo = nil) then
    begin
      continue;
    end else
    if (code <> $0a) or (code <> $0d) then
    begin
      if (not word_reads) then
      begin
        inc(prop.Words);
        if not first_word then
          inc(prop.InsideBlanks, blanks_befor_word);
        //blanks := 0;
        word_width := 0;
        word_reads := true;
      end;
      first_word := false;
      add := KeyInfo^.Rect.Width + FDelta;
      word_width := word_width + add;
      prop.TrimWidth := prop.TrimWidth + add;
      inc(chars);
    end else
      add := 0;

    if (KeyInfo <> nil) and (KeyInfo.Rect.Height > prop.Height) then
      prop.Height := KeyInfo.Rect.Height;

    prop.Width := prop.Width + add;

    if (code = $0a) or (prop.Width + 2 >= out_width) then
    begin
      if FAllowBreakWords or (code = $0a) or (code = $20) or (code = $09) then
      begin
        if prop.Width > FWidth then
          FWidth := prop.Width;

        if FLineHeight = 0 then
          FHeight := FHeight + prop.Height + FInterligne;

        prop.TrimWidth := prop.TrimWidth - blanks_befor_word * FBlankWidth;
        FLines.Add(prop);
        prop.Height := 0.0;
        prop.CountChars := 0;

        prop.IndexBegin := i+1;
        prop.Width := 0;
        prop.TrimWidth := 0.0;
        chars := 0;
        word_width := 0.0;
        word_reads := false;
        first_word := true;
      end else
      //if word_width + add < out_width then
      begin // roll back on one word
        if word_reads then
          dec(prop.Words);

        dec(prop.CountChars, chars);
        prop.Width := prop.Width - word_width;
        prop.TrimWidth := prop.TrimWidth - blanks_befor_word * FBlankWidth - word_width;
        dec(prop.InsideBlanks, blanks_befor_word);
        if prop.Width > FWidth then
          FWidth := prop.Width;

        if FLineHeight = 0 then
          FHeight := FHeight + prop.Height + FInterligne;

        if (prop.CountChars > 0) and (prop.Width > 0) then
          FLines.Add(prop);

        prop.IndexBegin := i - chars + 1;
        prop.Width := word_width;
        prop.TrimWidth := word_width;
        prop.CountChars := chars;
        prop.Words := 1;
        prop.CountBlanks := 0;
        word_reads := true;
       //continue;
      end;
      blanks_befor_word := 0;
      prop.InsideBlanks := 0;
      prop.CountBlanks := blanks_befor_word;
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

constructor TTextProcessor.Create(AKeySelector: TSelectorKey);
begin
  Assert(Assigned(AKeySelector), 'A parameter AKeySelector must be valid!');
  FDelta := 1;
  FInterligne := 3;
  FAllowBreakWords := false;
  FOnQueryKey := AKeySelector;
  FLines := TListVec<TLineProp>.Create;
end;

destructor TTextProcessor.Destroy;
begin
  FLines.Free;
  inherited;
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

procedure TTextProcessor.SetAllowBreakWords(const Value: boolean);
begin
  FAllowBreakWords := Value;
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

procedure TTextProcessor.SetViewportWidth(const Value: BSFloat);
begin
  FViewportWidth := Value;
  if FillCount = 0 then
    Build(1);
end;

end.
