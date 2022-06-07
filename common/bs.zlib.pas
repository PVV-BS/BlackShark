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
unit bs.zlib;

{$I BlackSharkCfg.inc}

interface

uses
    classes
  {$ifdef fpc}
  , ZBase
  , ZInflate
  {$else}
  , zlib
  {$endif}
  ;

type

  ZLibDecompressor = class
  private
    FZStream: z_stream;
    FOutBuffer: PByte;
    FOutBufferSize: uint32;
  public
    constructor Create;
    destructor Destroy; override;
    function Decompress(AData: PByte; ASize: int32; AOutStream: TStream): uint32;
  end;

implementation

{ ZLibDecompressor }

constructor ZLibDecompressor.Create;
begin
  InflateInit2(FZStream, 15);
  FOutBufferSize := 1024*1024;
  GetMem(FOutBuffer, FOutBufferSize);
end;

function ZLibDecompressor.Decompress(AData: PByte; ASize: int32; AOutStream: TStream): uint32;
var
  zresult: int32;
  delta: uint32;
begin
  FZStream.next_in := Pointer(AData);
  FZStream.avail_in := ASize;

  zresult := Z_OK;
  Result := 0;

  while (FZStream.avail_in > 0) and (zresult = Z_OK) do
  begin
    FZStream.avail_out := FOutBufferSize;
    FZStream.next_out := Pointer(FOutBuffer);
    zresult := inflate(FZStream, Z_FULL_FLUSH);
    delta := FOutBufferSize - FZStream.avail_out;
    AOutStream.Write(FOutBuffer^, delta);
    inc(Result, delta);
  end;
  FZStream.next_in := AData + ASize - FZStream.avail_in;
  FZStream.total_in := 0;
end;

destructor ZLibDecompressor.Destroy;
begin
  inflateEnd(FZStream);
  FreeMem(FOutBuffer, FOutBufferSize);
  inherited;
end;

end.
