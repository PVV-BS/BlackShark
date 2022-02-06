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
  unint contains advanced streams
}

unit bs.stream;

interface

uses
    Classes
  ;

type

  { TWidenBuffer }
  { Memory stream-buffer working only on grow Capacity }

  TWidenBuffer = class(TMemoryStream)
  public
    type
      TLawAlign = (
        laNone,    //< not grow
        laMod,     //< grow multiply CapacityAlign
        laPowerTwo //< grow multiply degree two
        );
  private
    SelfOwnerMemory: boolean;
    FCarrentCapacity: uint32;
    FCapacityAlign: int32;
    FLawAlign: TWidenBuffer.TLawAlign;
    procedure FreeMemory; inline;
  protected
    function Realloc(var NewCapacity: {$ifdef FPC} PtrInt {$else}
                     {$if CompilerVersion > 34.0} NativeInt {$else} LongInt {$endif} {$endif}): Pointer; override;
  public
    constructor Create(const ASize: uint32 = 0; ALawAlign: TWidenBuffer.TLawAlign = laMod;
      ACapacityAlign: int32 = 65536); overload;
    // this constructor allow (if CopyMemory = false) assigned self pointer, but in this case not allow widening
    constructor Create(const AMemory: Pointer; const Count: uint32; CopyMemory: boolean = false;
      ALawAlign: TWidenBuffer.TLawAlign = laMod; ACapacityAlign: int32 = 65536); overload;
    destructor Destroy; override;
    procedure SetMemory(AMemory: Pointer; ACount: uint32);
    property CarrentCapacity: uint32 read FCarrentCapacity;
    property CapacityAlign: int32 read FCapacityAlign write FCapacityAlign;
    property LawAlign: TWidenBuffer.TLawAlign read FLawAlign write FLawAlign;
  end;

 implementation

  uses
      SysUtils
    , math
    ;

{ TWidenBuffer }

constructor TWidenBuffer.Create(const ASize: uint32 = 0;
  ALawAlign: TWidenBuffer.TLawAlign = laMod;
  ACapacityAlign: int32 = 65536);
begin
  inherited Create;
  FCapacityAlign := ACapacityAlign;
  FLawAlign := ALawAlign;
  SelfOwnerMemory := true;
  Size := ASize;
end;

constructor TWidenBuffer.Create(const AMemory: Pointer; const Count: uint32;
  CopyMemory: boolean = false; ALawAlign: TWidenBuffer.TLawAlign = laMod;
  ACapacityAlign: int32 = 65536);
begin
  FCapacityAlign := ACapacityAlign;
  FLawAlign := ALawAlign;
  FCarrentCapacity := Count;
  if CopyMemory then
    begin
    Create(Count, ALawAlign, ACapacityAlign);
    move(pByte(AMemory)^, pByte(Memory)^, Count);
    end else
    begin
    inherited Create;
    SelfOwnerMemory := false;
    SetPointer(AMemory, Count);
    end;
end;

destructor TWidenBuffer.Destroy;
begin
  FreeMemory;
  inherited Destroy;
end;

procedure TWidenBuffer.FreeMemory;
begin
  if SelfOwnerMemory and (Memory <> nil) and (Capacity > 0) then
    begin
    FreeMem(Memory, Capacity);
    SetPointer(nil, 0);
    end;
end;

function TWidenBuffer.Realloc(var NewCapacity: {$ifdef FPC} PtrInt {$else}
             {$if CompilerVersion > 34.0} NativeInt {$else} LongInt {$endif} {$endif}): Pointer;
var
  rate_two: int32;
begin
  if (NewCapacity <= Capacity) then
  begin
    NewCapacity := Capacity;
    exit(Memory);
  end;

  if SelfOwnerMemory then
  begin
    case FLawAlign of
      laNone: ;
      laMod: NewCapacity := ((NewCapacity div FCapacityAlign) + 1) * FCapacityAlign;
      laPowerTwo: begin
        rate_two := Ceil(Log2(NewCapacity/FCapacityAlign));
        NewCapacity := round(power(2, rate_two))*FCapacityAlign;
      end;
    end;
    FCarrentCapacity := NewCapacity;
    Result := inherited Realloc(NewCapacity);
  end else
    raise Exception.Create('Can not realloc assigned memory');
end;

procedure TWidenBuffer.SetMemory(AMemory: Pointer; ACount: uint32);
begin
  FreeMemory;
  SelfOwnerMemory := false;
  SetPointer(AMemory, ACount);
  if (AMemory = nil) then
    SelfOwnerMemory := true;
  Position := 0;
end;

end.
