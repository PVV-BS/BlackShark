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


unit bs.graphics;

{
  The unit implements a rasterizator that allows to draw primitives.
  The rasterizator was developed with the help these articles:
    - http://habrahabr.ru/post/248159/
    - https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
}

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  {$ifdef FMX}
  , FMX.Graphics
  , FMX.Types
  {$endif}

  {$ifndef FPC}
   , System.UITypes
  {$endif}

  , bs.math
  , bs.collections
  , bs.stream
  , bs.baseTypes
  ;

type

  TBSPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);

  TGradientType = (
    gtNone,
    gtHorizontal,
    gtVerical,
    gtDiagonalRight,
    gtDiagonalLeft,
    gtRadialSquare,
    gtRadialCircle,
    gtRadialSquareHorizonral,
    gtRadialSquareVertical
  );

  TBMPFileHdr = packed record
    bfType      : uint16;
    bfSize      : int32;
    bfReserved  : uint32;
    bfOffBits   : uint32;
  end;

  TBMPInfoHeader = packed record
    biSize          : uint32;
    biWidth         : int32;
    biHeight        : int32;
    biplanes        : uint16;
    biBitCount      : uint16;
    biCompression   : uint32;
    biSizeImage     : uint32;
    biXPelsPerMeter : int32;
    biYPelsPerMeter : int32;
    biClrUsed       : uint32;
    biClrImportant  : uint32;
  end;

  TInterpolationMode = (imNone, imLinear, imCubic , imLanczos);

  TSamplerFunc = function (t: fmath) : fmath;

  TBlackSharkRasterCanvas = class;

  { TSamplerFilter }

  TSamplerFilter = class
  private
    FFilter: TSamplerFunc;
    FWindowSize: int8;
    FCanvas: TBlackSharkRasterCanvas;
    FInterpolationMode: TInterpolationMode;
    procedure Map(MapContainer: TListVec<BSFloat>; Scale: BSFloat; FilterWidth: BSFloat);
    procedure SetWindowSize(const Value: int8);
    procedure SetInterpolationMode(const Value: TInterpolationMode);
  protected
    buf: TWidenBuffer;
    MapX: TListVec<BSFloat>;
    MapY: TListVec<BSFloat>;
    CarrentFilterWidth: TVec2f;
    CarrentScale: TVec2f;
    FilterAssigned: boolean;
    CurrentResampleSize: TVec2i;
    NewPadding: int8;
    procedure BeginPrepareSample; virtual; abstract;
    { selection samples for horizontal and vertical lines different, becouse
      for select hor samples in first pass uses a source data - FCanvas,
      but for select vert samples in second pass uses prepared from first pass
      buf (see above var TWidenBuffer)
      }
    procedure PrepareSampleHor(x, y: int32; w: BSFloat); virtual; abstract;
    procedure PrepareSampleVert(x, y: int32; w: BSFloat); virtual; abstract;
    procedure EndPreparedSample(x, y: int32); virtual; abstract;
    function SizeOfSample: uint8; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    { TODO: resample on grow }
    procedure Resample(const NewSize: TVec2i; const BorderSize: int32 = 1); overload;
    procedure Resample(const NewSizeX, NewSizeY: int32; const BorderSize: int32 = 1); overload;
    property FilterFunc: TSamplerFunc read FFilter;
    property WindowSize: int8 read FWindowSize write SetWindowSize;
    property Canvas: TBlackSharkRasterCanvas read FCanvas write FCanvas;
    property InterpolationMode: TInterpolationMode read FInterpolationMode write SetInterpolationMode;
  end;

  { TBlackSharkRasterCanvas }

  TBlackSharkRasterCanvas = class abstract
  private
    FChanged: boolean;
    procedure SetHeight(AValue: int32);
    procedure SetWidth(AValue: int32);
    procedure SetSamplerFilter(const Value: TSamplerFilter);
    function GetSamplerFilter: TSamplerFilter;
  protected
    FRaw: TWidenBuffer;
    FHeight: int32;
    FWidth: int32;
    FSquare: int32;
    FSamplerFilter: TSamplerFilter;
    class function CreateDefaultSampler: TSamplerFilter; virtual; abstract;
    function DoGetPointer(X, Y: Int32): PByte; inline;
  public
    Padding: int8;
    SizeColor: int8;
  public
    constructor Create(AWidth: int32 = 512; AHeight: int32 = 512); virtual;
    destructor Destroy; override;
    class function SizeOfColor: int8; virtual; abstract;
    procedure Assign({%H-}Source: TBlackSharkRasterCanvas); virtual;
    procedure Fill(const AColor); overload; virtual; abstract;
    procedure Fill(const AColor; const Rect: TRectBSi); overload; virtual; abstract;
    procedure ReplaceColor(const AColor); virtual; abstract;
    procedure Clear;
    procedure CopyRect(Source: TBlackSharkRasterCanvas; const Pos: TVec2i;
      const SourceRect: TRectBSi);
    procedure Resample(const DestSize: TVec2i; const BorderSize: int32 = 1);
    procedure DrawLine(X0, Y0, X1, Y1: int32); overload; virtual; abstract;
    procedure DrawLine(V0, V1: TVec2i); overload;
    procedure DrawPixel(X, Y: int32); overload; virtual; abstract;
    procedure DrawTriangle(V0, V1, V2: TVec2i; Fill: boolean = false); virtual; abstract;
    function GetPixel(X, Y: int32; out OutColor): boolean; virtual; abstract;
    procedure DrawCircle(X, Y, Radius: int32); virtual; abstract;
    procedure SetSize(AWidth, AHeight: int32);
    function PtrOnColor(X, Y: int32): PByte;
    property Width: int32 read FWidth write SetWidth;
    property Height: int32 read FHeight write SetHeight;
    property Raw: TWidenBuffer read FRaw;
    property Square: int32 read FSquare;
    property SamplerFilter: TSamplerFilter read GetSamplerFilter write SetSamplerFilter;
    property Changed: boolean read FChanged write FChanged;
  end;

  TBlackSharkRasterizatorClass = class of TBlackSharkRasterCanvas;

  { Generic type for any a format pixels }

  { TBlackSharkRasterizator }

  TBlackSharkRasterizator<T> = class(TBlackSharkRasterCanvas)
  protected
  type
    PointerOfT = ^T;
  private
    FColor: T;
  public
    constructor Create(AWidth: int32 = 512; AHeight: int32 = 512); override;
    class function SizeOfColor: int8; override;
    procedure Fill(const AColor); overload; override;
    procedure Fill(const AColor; const Rect: TRectBSi); overload; override;
    { Bresenham's line algorithm: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm }
    procedure DrawLine(X0, Y0, X1, Y1: int32); overload; override;
    procedure DrawPixel(X, Y: int32); override;
    procedure DrawTriangle(V0, V1, V2: TVec2i; Fill: boolean = false); override;
    function GetPixel(X, Y: int32; out OutColor): boolean; override;
    procedure DrawCircle(X, Y, Radius: int32); override;
    property Color: T read FColor write FColor;
  end;

  TSamplerFilterRGBA = class(TSamplerFilter)
  private
    Pixel_f: TVec4d;
    CountSamples: int32;
  protected
    procedure BeginPrepareSample; override;
    procedure PrepareSampleHor(x, y: int32; w: BSFloat); override;
    procedure PrepareSampleVert(x, y: int32; w: BSFloat); override;
    procedure EndPreparedSample(x, y: int32); override;
    function SizeOfSample: uint8; override;
  public
    constructor Create;
  end;

  TSamplerFilterRGB = class(TSamplerFilter)
  private
    Pixel_f: TVec3d;
    CountSamples: int32;
  protected
    procedure BeginPrepareSample; override;
    procedure PrepareSampleHor(x, y: int32; w: BSFloat); override;
    procedure PrepareSampleVert(x, y: int32; w: BSFloat); override;
    procedure EndPreparedSample(x, y: int32); override;
    function SizeOfSample: uint8; override;
  public
    constructor Create;
  end;

  TSamplerFilterAlpha = class(TSamplerFilter)
  private
    Alpha: int32;
    CountSamples: int32;
  protected
    procedure BeginPrepareSample; override;
    procedure PrepareSampleHor(x, y: int32; w: BSFloat); override;
    procedure PrepareSampleVert(x, y: int32; w: BSFloat); override;
    procedure EndPreparedSample(x, y: int32); override;
    function SizeOfSample: uint8; override;
  end;

  { TBlackSharkRasterizatorRGBA }

  TBlackSharkRasterizatorRGBA = class(TBlackSharkRasterizator<TVec4b>)
  protected
    class function CreateDefaultSampler: TSamplerFilter; override;
  public
    procedure ReplaceColor(const AColor); override;
  end;

  { TBlackSharkRasterizatorAlpha }

  TBlackSharkRasterizatorAlpha = class(TBlackSharkRasterizator<byte>)
  protected
    class function CreateDefaultSampler: TSamplerFilter; override;
  public
    procedure ReplaceColor(const AColor); override;
  end;

  { TBlackSharkRasterizatorRGB }

  TBlackSharkRasterizatorRGB = class(TBlackSharkRasterizator<TVec3b>)
  protected
    class function CreateDefaultSampler: TSamplerFilter; override;
  public
    procedure ReplaceColor(const AColor); override;
  end;

  { Below presents the decoders several graphical formats }

  TBlackSharkPictureClass = class of TBlackSharkPicture;

  { TBlackSharkPicture }

  TBlackSharkPicture = class
  private
    procedure SetHeight(const Value: int32);
    procedure SetWidth(const Value: int32);
    procedure SetPixelFormat(const Value: TBSPixelFormat);
    function GetHeight: int32;
    function GetWidth: int32;
  protected
    FCaption: string;
    FPixelFormat: TBSPixelFormat;
    FCanvas: TBlackSharkRasterCanvas;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Picture: TBlackSharkPicture); virtual;
    procedure CreateCanvas;
    function Open(const FileName: string): boolean; overload;
    function Open(Stream: TStream): boolean; overload; virtual;
    function Save(const FileName: string): boolean; overload;
    function Save(Stream: TStream): boolean; overload; virtual; abstract;

    procedure SetSize(AWidth, AHeight: int32);
    property Width: int32 read GetWidth write SetWidth;
    property Height: int32 read GetHeight write SetHeight;
    property Canvas: TBlackSharkRasterCanvas read FCanvas write FCanvas;
    property PixelFormat: TBSPixelFormat read FPixelFormat write SetPixelFormat;
    property Caption: string read FCaption;
  end;

  TPicCodecManager = class
  private
    type
      PCodecRec = ^TCodecRec;
      TCodecRec = record
        Codec: TBlackSharkPictureClass;
        SignatureBoundaryBegin: int32;
        SignatureBoundaryEnd: int32;
      end;
  strict private
    class var
      FWidenBuf: TWidenBuffer;
  private
    class var
      Codecs: TListVec<PCodecRec>;
    class var
      Signatures: TBinTree<PCodecRec>;
    class var
      Extentions: TBinTree<PCodecRec>;
    class function GetWidenBuf: TWidenBuffer; static;
    class destructor Destroy;
  public
    { registres class a decoding picture; length Signature may be 0 if only
      by Extention detected; }
    class procedure RegisterCodec(Codec: TBlackSharkPictureClass; const Extention:
      array of AnsiString; const Signature: array of byte;
      SignatureBoundaryBegin: int32 = 0; SignatureBoundaryEnd: int32 = 0);
    class function Open(const FileName: string): TBlackSharkPicture; overload;
    class function Open(Stream: TStream; const Ext: AnsiString = ''): TBlackSharkPicture;  overload;
    class property WidenBuf: TWidenBuffer read GetWidenBuf;
  end;

  { TBlackSharkBitMap }

  TBlackSharkBitMap = class(TBlackSharkPicture)
  public
    function Open(Stream: TStream): boolean; override;
    { save as TPixelFormat.pf32bit }
    function Save(Stream: TStream): boolean; override;
  end;

  { TODO: DDS, JPEG }

  { TBlackSharkTGA }

  TBlackSharkTGA = class(TBlackSharkPicture)
  public
    function Open(Stream: TStream): boolean; override;
    function Save(Stream: TStream): boolean; override;
  end;

  { TBlackSharkDDS }

  TBlackSharkDDS = class(TBlackSharkPicture)
  public
    function Open({%H-}Stream: TStream): boolean; override;
    function Save(Stream: TStream): boolean; override;
  end;

  { TBlackSharkPng }

  TBlackSharkPng = class(TBlackSharkPicture)
  private
  type
    TPNGChunk = record
      Size: int32;
      Name: uint32;
    end;

    TPNGHeader = packed record
      Base              : TPNGChunk;
      Width             : int32;
      Height            : int32;
      BitDepth          : byte;
      ColorType         : byte;
      CompressionMethod : byte;
      FilterMethod      : byte;
      InterlaceMethod   : byte;
    end;

  private
    procedure MoveRgba(ASource, ADest: PByte; ARowWidth: int32);
    procedure RgbToRgba(ASource, ADest: PByte; AWidth: int32);
    procedure GrayscaleAlphaToRgba(ASource, ADest: PByte; AWidth: int32);
    procedure PaletteToRgba(ASource, ADest: PByte; AWidth: int32);
    procedure GrayscaleToRgba(ASource, ADest: PByte; AWidth: int32);
  public
    function Open(Stream: TStream): boolean; override;
    { save as TPixelFormat.pf32bit }
    function Save(Stream: TStream): boolean; override;
  end;

  { kernels for full screen effect; used for multi-sampling;
    source: http://setosa.io/ev/image-kernels/ }
  TSamplingKernel = (skIdentity, skBlur, skBottomSobel, skEmboss, skLeftSobel,
    skOutLine, skRightSobel, skSharpen, skTopSobel, skEdgeDetect, skEdgeEnhance);

  TGuiColors = record
  const
    Black   = $000000;
    White   = $FFFFFF;
    Red     = $0000FF;
    Green   = $008000;
    Blue    = $FF0000;
    Purple  = $800080;
    Olive   = $008080;
    Maroon  = $000080;
    Navy    = $800000;
    Teal    = $808000;
    Gray    = $808080;
    Silver  = $C0C0C0;
    Lime    = $00FF00;
    Yellow  = $00FFFF;
    Fuchsia = $FF00FF;
    Aqua    = $FFFF00;

    MoneyGreen = $C0DCC0;
    Cream      = $F0FBFF;
    MedGray    = $A4A0A0;
    Skyblue    = $EBCE87;

    Count = 20;
  end;

  function ColorToString(AColor: TGuiColor): AnsiString;
  function StringToColor(AColor: AnsiString): TGuiColor;

var
  { This variables is setted from platform-dependency units }
  PixelsPerInch: single = 96;
  ToHiDpiScale: single = 1.0;

const
  SAMPLING_KERNELS_SET: array[TSamplingKernel] of TMatrix3f = (
    (V: (         // skIdentity
      0.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 0.0
    )),
    (V: (         // skSubscription
      0.0625, 0.125, 0.0625,
      0.1250, 0.250, 0.1250,
      0.0625, 0.125, 0.0625
    )),
    (V: (         // skBottomSobel
      -1.0, -2.0, -1.0,
       0.0,  0.0,  0.0,
       1.0,  2.0,  1.0
    )),
    (V: (         // skEmboss
      -2.0, -1.0, 0.0,
      -1.0,  1.0, 1.0,
       0.0,  1.0, 2.0
    )),
    (V: (         // skLeftSobel
      1.0, 0.0, -1.0,
      2.0, 0.0, -2.0,
      1.0, 0.0, -1.0
    )),
    (V: (         // skOutLine
      -1.0, -1.0, -1.0,
      -1.0,  8.0, -1.0,
      -1.0, -1.0, -1.0
    )),
    (V: (         // skRightSobel
      -1.0, 0.0, 1.0,
      -2.0, 0.0, 2.0,
      -1.0, 0.0, 1.0
    )),
    (V: (         // skSharpen
      0.0,  -1.0, 0.0,
     -1.0,  5.0, -1.0,
      0.0,  -1.0, 0.0
    )),
    (V: (         // skTopSobel
      1.0, 2.0, 1.0,
      0.0, 0.0, 0.0,
     -1.0, -2.0, -1.0
    )),
    (V: (         // skEdgeDetect
      0.0, 1.0, 0.0,
      1.0, -4.0, 1.0,
      0.0, 1.0, 0.0
    )),
    (V: (         // skEdgeEnhance
      0.0, 0.0, 0.0,
      -1.0, 1.0, 0.0,
      0.0, 0.0, 0.0
    ))
  );

implementation

uses
    math
  , bs.zlib
  , bs.strings
  , bs.exceptions
  ;

const
  BYTES_PER_PIXEL: array[TBSPixelFormat] of integer =
  (
    0, 0, 0, 1, 2, 2, 3, 4, 0
  );

type
  TColorMapRec = record
    Color: TGuiColor;
    Name: AnsiString;
    class function ColorMapRec(AColor: TGuiColor; const AName: AnsiString): TColorMapRec; static;
  end;


var
  ColorMap: TListVec<TColorMapRec>;

function ColorToString(AColor: TGuiColor): AnsiString;
var
  i: int32;
begin
  for i := 0 to TGuiColors.Count - 1 do
    if ColorMap.Items[i].Color = AColor then
      exit(ColorMap.Items[i].Name);
  Result := StringToAnsi(IntToHex(AColor, 8));
end;

function StringToColor(AColor: AnsiString): TGuiColor;
var
  i: int32;
begin
  if (AColor = '') then
    exit(0);

  if AColor[1] = '$' then
    exit(StrToInt(AnsiToString(AColor)));

  for i := 0 to TGuiColors.Count - 1 do
    if ColorMap.Items[i].Name = AColor then
      exit(ColorMap.Items[i].Color);

  Result := 0;
end;

{ TSamplerFilter }

constructor TSamplerFilter.Create;
begin
  MapX := TListVec<BSFloat>.Create;
  MapY := TListVec<BSFloat>.Create;
  buf := TWidenBuffer.Create;
end;

destructor TSamplerFilter.Destroy;
begin
  MapX.Free;
  MapY.Free;
  buf.Free;
  inherited;
end;

procedure TSamplerFilter.Map(MapContainer: TListVec<BSFloat>; Scale: BSFloat; FilterWidth: BSFloat);
var
  left, right: int32;
  j: int32;
  weight: Single;
begin
  if Scale < 1 then
    begin
    MapContainer.Count := Ceil(FilterWidth*2);
    left  :=  Floor(-FilterWidth);
    right :=  Ceil(FilterWidth);
    for j := Left to Right do
      begin
      weight := FFilter((j shl 1) * Scale);
      if weight <> 0 then
        MapContainer.Items[round(j+FilterWidth)] := weight;
      end;
    end else // scale > 1
    begin
    MapContainer.Count := FWindowSize;
    { TODO: resample to increase }
    {for i := 0 to ClipW - 1 do
      begin
      Center := SrcLo + (I - DstLo + ClipLo) * Scale;
      left := Floor(Center - FWindowSize);
      right := Ceil(Center + FWindowSize);
      for j := left to right do
        begin
        weight := FFilter(Center - j);
        if weight <> 0 then
          begin
          k := Length(Result[I]);
          SetLength(Result[I], k + 1);
          Result[I][K].Pos := Constrain(j, SrcLo, SrcHi - 1);
          Result[I][K].Weight := weight;
          end;
        end;
      end;}
    end;
end;

procedure TSamplerFilter.Resample(const NewSize: TVec2i;
  const BorderSize: int32);
var
  i, j, px, py: int32;
  wx, wy: int16; // scan window position
  pxf, pyf: BSFloat;
  fs_rounded, tmp: TVec2i;
  border_double: int32;
  scale_inv: TVec2f;
  sample_size: int8;
begin
  if (NewSize.x = 0) or (NewSize.y = 0) or (FCanvas.Width = 0) or (FCanvas.Height = 0) then
    exit;
  tmp := NewSize;
  repeat
    CarrentScale.x := tmp.x / FCanvas.Width;
    scale_inv.x := 1/CarrentScale.x;
    CarrentFilterWidth.x := (FWindowSize / CarrentScale.x) * 0.25;
    fs_rounded.x := Ceil(CarrentFilterWidth.x);
    dec(tmp.x);
  until not ((tmp.x > 1) and (Ceil((NewSize.x-1) * scale_inv.x) < FCanvas.Width));

  repeat
    CarrentScale.y := tmp.y /  FCanvas.Height;
    scale_inv.y := 1/CarrentScale.y;
    CarrentFilterWidth.y := (FWindowSize / CarrentScale.y) * 0.25;
    fs_rounded.y := Ceil(CarrentFilterWidth.y);
    dec(tmp.y);
  until not ((tmp.y > 1) and (Ceil((NewSize.y-1) * scale_inv.y) < FCanvas.Height));

  if FilterAssigned then
    begin
    Map(MapX, CarrentScale.x, CarrentFilterWidth.x);
    Map(MapY, CarrentScale.y, CarrentFilterWidth.y);
    end;
  border_double := BorderSize*2;
  CurrentResampleSize := vec2(int32(NewSize.x + border_double), int32(NewSize.y + border_double));
  sample_size := SizeOfSample;
  NewPadding := 4 - ((NewSize.x + border_double)*sample_size) mod 4;
  if NewPadding = 4 then
    NewPadding := 0;
  //buf.Size {%H-}:= (NewSize.x + border_double) * (NewSize.x + border_double) * sample_size;

  if NewSize.x > FCanvas.Height then
    buf.Size {%H-}:= ((NewSize.x + border_double) * sample_size + NewPadding) * (NewSize.x + border_double)
  else
    buf.Size {%H-}:= ((NewSize.x + border_double) * sample_size + NewPadding) * (FCanvas.Height + border_double);
  FillChar(pByte(buf.Memory)^, buf.Size, 0);
  for i := 0 to FCanvas.Height - 1 do
  begin
    for j := 0 to NewSize.x - 1 do
    begin
      BeginPrepareSample;
      pxf := j * scale_inv.x;
      for wx := -fs_rounded.x to fs_rounded.x do
      begin
        px := Round(pxf + wx);
        if (px < 0) or (px >= FCanvas.Width) then
          continue;
        if FilterAssigned then
          PrepareSampleHor(px, i, MapX.Items[wx + fs_rounded.x]) else
          PrepareSampleHor(px, i, 1.0);
      end;
      EndPreparedSample(j + BorderSize, i + BorderSize);
    end;
  end;
  for i := 0 to NewSize.y - 1 do
  begin
    pyf := i * scale_inv.y;
    for j := 0 to NewSize.x - 1 do
    begin
      BeginPrepareSample;
      for wy := -fs_rounded.y to fs_rounded.y do
      begin
        py := Round(pyf + wy);
        if (py < 0) or (py >= FCanvas.Height) then
          continue;
        if FilterAssigned then
          PrepareSampleVert(j + BorderSize, py + BorderSize, MapY.Items[wy + fs_rounded.y]) else
          PrepareSampleVert(j + BorderSize, py + BorderSize, 1.0);
      end;
      EndPreparedSample(j + BorderSize, i + BorderSize);
    end;
  end;
  FCanvas.SetSize(NewSize.x + border_double, NewSize.y + border_double);
  move(pByte(buf.Memory)^, pByte(FCanvas.Raw.Memory)^, FCanvas.Raw.Size);
  // fill bottom border
  if BorderSize > 0 then
    FillChar((pByte(FCanvas.Raw.Memory) + (NewSize.y + BorderSize)*((NewSize.x + border_double) * sample_size + NewPadding))^,
      ((NewSize.x + border_double)*BorderSize) * sample_size, 0);
end;

procedure TSamplerFilter.Resample(const NewSizeX, NewSizeY: int32; const BorderSize: int32);
begin
  Resample(vec2(NewSizeX, NewSizeY), BorderSize);
end;

procedure TSamplerFilter.SetInterpolationMode(const Value: TInterpolationMode);
begin
  FInterpolationMode := Value;
  FFilter := nil;
  case FInterpolationMode of
    imNone: FWindowSize := 1;
    imLinear: begin
      FWindowSize := 2;
      //FFilter := LinearInterpolation;
      end;
    imCubic: begin
      { TODO: cubic sampler }
      FWindowSize := 2;
      FFilter := CubicInterpolation;
      end;
    imLanczos: begin
    { for Lanczos filter size window set default 6 }
    FWindowSize := 6;
    FFilter := Lanczos3Interpolation;
    end;
  end;
  FilterAssigned := Assigned(FFilter);
end;

procedure TSamplerFilter.SetWindowSize(const Value: int8);
begin
  if (FWindowSize = Value) then
    exit;
  FWindowSize := Value;
  if FWindowSize < 2 then
    FWindowSize := 2;
end;

{ TBlackSharkRasterCanvas }

procedure TBlackSharkRasterCanvas.Clear;
begin
  FillChar(pByte(FRaw.Memory)^, FRaw.Size, 0);
end;

procedure TBlackSharkRasterCanvas.CopyRect(Source: TBlackSharkRasterCanvas;
  const Pos: TVec2i; const SourceRect: TRectBSi);
var
  i, t, ty, h_clip: int32;
  so: int8;
begin
  so := SizeOfColor;
  if Pos.y + SourceRect.Height > FHeight then
    h_clip := FHeight - Pos.y
  else
    h_clip := SourceRect.Height;
  t := Pos.y - SourceRect.Top;
  ty := SourceRect.Y + h_clip;
  for i := SourceRect.Y to ty - 1 do
    begin
    move(
      (pByte(Source.Raw.Memory) + ((Source.Width * so + Source.Padding) * i + SourceRect.X * so))^,
      (pByte(FRaw.Memory) + ((t + i) * (FWidth * so + Padding) + Pos.x * so))^,
      SourceRect.Width * so);
    end;
end;

constructor TBlackSharkRasterCanvas.Create(AWidth: int32; AHeight: int32);
begin
  SetSize(AWidth, AHeight);
  SizeColor := SizeOfColor;
end;

destructor TBlackSharkRasterCanvas.Destroy;
begin
  FRaw.Free;
  FSamplerFilter.Free;
  inherited;
end;

function TBlackSharkRasterCanvas.DoGetPointer(X, Y: Int32): PByte;
begin
  Result := pByte(FRaw.Memory) + (FHeight - y - 1) * (FWidth * SizeColor + Padding) + x * SizeColor;
            //pByte(FRaw.Memory) + (FHeight - y - 1) * (FWidth * SizeOf(T) + Padding) + x * SizeOf(T)
end;

procedure TBlackSharkRasterCanvas.DrawLine(V0, V1: TVec2i);
begin
  DrawLine(V0.x, V0.y, V1.x, V1.y);
end;

procedure TBlackSharkRasterCanvas.Assign(Source: TBlackSharkRasterCanvas);
begin
  if Source.Raw = nil then
  begin
    FreeAndNil(FRaw);
    FWidth := 0;
    FHeight := 0;
    exit;
  end;
  SetSize(Source.Width, Source.Height);
end;

function TBlackSharkRasterCanvas.GetSamplerFilter: TSamplerFilter;
begin
  if FSamplerFilter = nil then
  begin
    FSamplerFilter := CreateDefaultSampler;
    FSamplerFilter.Canvas := Self;
  end;
  Result := FSamplerFilter;
end;

function TBlackSharkRasterCanvas.PtrOnColor(X, Y: int32): PByte;
begin
  if (FRaw = nil) or (X > FWidth) or (Y > FHeight) then
    exit(nil);
  Result := DoGetPointer(X, Y);
end;

procedure TBlackSharkRasterCanvas.Resample(const DestSize: TVec2i; const BorderSize: int32 = 1);
begin

  if FSamplerFilter = nil then
  begin
    FSamplerFilter := CreateDefaultSampler;
    FSamplerFilter.Canvas := Self;
  end;

  FSamplerFilter.Resample(DestSize, BorderSize);
  FWidth := DestSize.x + BorderSize * 2;
  FHeight := DestSize.y + BorderSize * 2;
end;

procedure TBlackSharkRasterCanvas.SetHeight(AValue: int32);
begin
  SetSize(FWidth, AValue);
end;

procedure TBlackSharkRasterCanvas.SetSamplerFilter(const Value: TSamplerFilter);
begin
  if FSamplerFilter = Value then
    exit;
  FSamplerFilter.Free;
  FSamplerFilter := Value;
  if FSamplerFilter <> nil then
    FSamplerFilter.Canvas := Self;
end;

procedure TBlackSharkRasterCanvas.SetSize(AWidth, AHeight: int32);
begin
  if (AWidth = FWidth) and (AHeight = FHeight) then
    exit;
  FChanged := true;
  FWidth := AWidth;
  FHeight := AHeight;
  FSquare := FHeight * FWidth;
  Padding := 4 - ((FWidth * SizeOfColor) mod 4);

  if (Padding = 4) then
    Padding := 0;

  if ((AWidth = 0) or (AHeight = 0)) then
  begin
    FreeAndNil(FRaw);
    exit;
  end;

  if FRaw = nil then
    FRaw := TWidenBuffer.Create;

  FRaw.Size := int64(FWidth * int64(SizeOfColor) + Padding) * int64(FHeight);
  FillChar(pByte(FRaw.Memory)^, FRaw.Size, 0);
end;

procedure TBlackSharkRasterCanvas.SetWidth(AValue: int32);
begin
  SetSize(AValue, FHeight);
end;

  { TBlackSharkRasterizator }

procedure TBlackSharkRasterizator<T>.DrawLine(X0, Y0, X1, Y1: int32);
var
  steep: boolean;
  dx, dy, derror2, error2: int32;
  x, y: int32;
  dx2: int32;
  incy: int8;
begin
  FChanged := true;
  if (abs(X0 - X1) < abs(Y0 - Y1)) then
    begin
    swap(X0, Y0);
    swap(X1, Y1);
    steep := true;
    end else
    steep := false;

  if (X0 > X1) then
    begin
    swap(X0, X1);
    swap(Y0, Y1);
    end;
  dx := X1 - X0;
  dy := Y1 - Y0;
  derror2 := abs(dy) shl 1;
  error2 := 0;
  y := Y0;
  if (Y1 > Y0) then
    incy := 1 else
    incy := -1;
  dx2 := dx shl 1;
  for x := X0 to X1 do
    begin
    if (steep) then
      DrawPixel(y, x) else
      DrawPixel(x, y);
    inc(error2, derror2);
    if (error2 > dx) then
      begin
      inc(y, incy);
      dec(error2, dx2);
      end;
    end;
end;

procedure TBlackSharkRasterizator<T>.DrawPixel(X, Y: int32);
begin
  if (x < 0) or (x >= FWidth) or (y < 0) or (y >= FHeight) then
    exit;
  FChanged := true;
  PointerOfT(DoGetPointer(X, Y))^ := FColor;
end;

procedure TBlackSharkRasterizator<T>.DrawTriangle(V0, V1, V2: TVec2i;
  Fill: boolean);
var
  total_height: int32;
  i, j: int32;
  second_half: boolean;
  segment_height: int32;
  alpha, beta: BSFloat;
  A, B: TVec2i;
begin
  FChanged := true;
  if Fill then
  begin
    if (V0.y = V1.y) and (V0.y = V2.y) then
      exit; // i dont care about degenerate triangles
    // sort the vertices, t0, t1, t2 lower-to-upper (bubblesort yay!)
    if (V0.y > V1.y) then swap(V0, V1);
    if (V0.y > V2.y) then swap(V0, V2);
    if (V1.y > V2.y) then swap(V1, V2);
    total_height := V2.y - V0.y;
    for i := 0 to total_height - 1 do
    begin
      second_half := (i > (V1.y - V0.y)) or (V1.y = V0.y);
      alpha := i / total_height;
      A := V0 + (V2 - V0) * alpha;
      if second_half then
      begin
        segment_height := V2.y - V1.y;
        beta := (i-(V1.y - V0.y)) / segment_height; // be careful: with above conditions no division by zero here
        B := V1 + (V2 - V1)*beta;
      end else
      begin
        segment_height := V1.y - V0.y;
        beta := i / segment_height;
        B := V0 + (V1 - V0)*beta;
      end;
      if (A.x > B.x) then swap(A, B);
      for j := A.x to B.x do
        DrawPixel(j, V0.y + i); // attention, due to int casts t0.y+i != A.y
    end;
  end else
  begin
    DrawLine(V0, V1);
    DrawLine(V1, V2);
    DrawLine(V2, V0);
  end;
end;

procedure TBlackSharkRasterizator<T>.Fill(const AColor);
var
  x, y: int32;
  ptr: pByte;
begin
  ptr := FRaw.Memory;
  for y := 0 to FHeight - 1 do
  begin
    for x := 0 to FWidth - 1 do
    begin
      move(AColor, ptr^, SizeOf(T));
      inc(ptr, SizeOf(T));
    end;
    inc(ptr, Padding);
  end;
end;

procedure TBlackSharkRasterizator<T>.Fill(const AColor; const Rect: TRectBSi);
var
  x, x_start, x_stop, y, y_start, y_stop: int32;
  ptr: pByte;
begin
  if (Rect.X >= FWidth) then
    exit;

  if Rect.X + Rect.Width > FWidth then
    x_stop := FWidth
  else
    x_stop := Rect.X + Rect.Width;

  if Rect.X < 0 then
    x_start := 0
  else
    x_start := Rect.X;

  if Rect.Y + Rect.Height > FHeight then
    y_stop := FHeight
  else
    y_stop := Rect.Y + Rect.Height;

  if Rect.Y < 0 then
    y_start := 0
  else
    y_start := Rect.Y;

  for y := y_start to y_stop - 1 do
  begin
    ptr := DoGetPointer(x_start, Y);
    if not Assigned(ptr) then
      break;
    for x := x_start to x_stop - 1 do
    begin
      move(AColor, ptr^, SizeOf(T));
      inc(ptr, SizeOf(T));
    end;
  end;
end;

function TBlackSharkRasterizator<T>.GetPixel(X, Y: int32; out OutColor): boolean;
begin
  if (x < 0) or (x >= FWidth) or (y < 0) or (y >= FHeight) then
    exit(false);
  move(PointerOfT(DoGetPointer(X, Y))^, {%H-}OutColor, SizeOf(T));
  Result := true;
end;

class function TBlackSharkRasterizator<T>.SizeOfColor: int8;
begin
  Result := SizeOf(T);
end;

constructor TBlackSharkRasterizator<T>.Create(AWidth, AHeight: int32);
begin
  inherited;
  FillChar(FColor, SizeOf(T), $FF);
end;

procedure TBlackSharkRasterizator<T>.DrawCircle(X, Y, Radius: int32);
var
  j: int32;
  angleStep, c, s: BSFloat;
  v0, v1: TVec2i;
  NumSlices: int32;
begin
  FChanged := true;
  NumSlices := Round(2 * BS_PI * Radius) + 1;
  angleStep := 360 / numSlices;
  v0 := vec2(int32(Radius + X), Y);
  for j := 1 to NumSlices do
    begin
    BS_SinCos(angleStep * j, s, c);
    v1 := vec2(
      int32(round(Radius * c)+X),
      int32(round(Radius * s)+Y)
    );
    if (v0.x <> v1.x) or (v0.y <> v1.y) then
      DrawLine(v0.x, v0.y, v1.x, v1.y) else
      DrawPixel(v0.x, v0.y);
    v0 := v1;
    end;
end;

{ TBlackSharkRasterizatorRGBA }

procedure TBlackSharkRasterizatorRGBA.ReplaceColor(const AColor);
var
  i: int32;
  ptr: PVec4b;
  hls_src, hls_dst: TVec3f;
  cl: TVec4b;
begin
  ptr := FRaw.Memory;
  move(AColor, cl{%H-}, SizeOf(cl));
  hls_src := RGBtoHLS(TVec3f(TVec4f(ColorByteToFloat(cl))));
  for i := 0 to FHeight * FWidth - 1 do
  begin
    hls_dst := RGBtoHLS(TVec3f(TVec4f(ColorByteToFloat(ptr^))));
    hls_src.l := hls_dst.l;
    cl := ColorFloatToByte(TColor4f(HLStoRGB(hls_src)));
    cl.a := ptr^.a;
    ptr^ := cl;
    inc(ptr);
  end;
end;

class function TBlackSharkRasterizatorRGBA.CreateDefaultSampler: TSamplerFilter;
begin
  Result := TSamplerFilterRGBA.Create;
end;

{ TSamplerFilterRGBA }

procedure TSamplerFilterRGBA.BeginPrepareSample;
begin
  CountSamples := 0;
  Pixel_f := vec4d(0.0, 0.0, 0.0, 0.0);
end;

procedure TSamplerFilterRGBA.PrepareSampleHor(x, y: int32; w: BSFloat);
var
  a: BSFloat;
  pixel: TVec4b;
begin
  pixel := PVec4b(PByte(FCanvas.Raw.Memory) + (y * (FCanvas.FWidth * SizeOf(TVec4b) + FCanvas.Padding) + x * SizeOf(TVec4b)))^;
  if w <> 1.0 then
  begin
    a := pixel.a/255 * w;
    Pixel_f := (Pixel_f + vec4(pixel.x * a, pixel.y * a, pixel.z * a, 255*a));
  end else
  begin
    Pixel_f := Pixel_f + pixel;
  end;
  inc(CountSamples);
end;

procedure TSamplerFilterRGBA.PrepareSampleVert(x, y: int32; w: BSFloat);
var
  a: BSFloat;
  pixel: TVec4b;
begin
  pixel := PVec4b(PByte(buf.Memory) + (y * (CurrentResampleSize.x * SizeOf(TVec4b) + NewPadding) + x * SizeOf(TVec4b)))^;
  if w <> 1.0 then
  begin
    a := pixel.a/255 * w;
    pixel_f := (pixel_f + vec4(pixel.x * a, pixel.y * a, pixel.z * a, 255*a));
  end else
  begin
    pixel_f := (pixel_f + pixel);
  end;
  inc(CountSamples);
end;

procedure TSamplerFilterRGBA.EndPreparedSample(x, y: int32);
begin
  if FilterAssigned then
    begin
    if Pixel_f.a <> 0 then
      Pixel_f := vec4(clamp(255, 0, pixel_f.x), clamp(255, 0, pixel_f.y),
        clamp(255, 0, pixel_f.z), clamp(255, 0, pixel_f.a)) else
      Pixel_f := vec4(0.0, 0.0, 0.0, 0.0);
      //pixel_f := vec4(clamp(255, 0, pixel_f.x/pixel_f.a), clamp(255, 0, pixel_f.y/pixel_f.a),
      //  clamp(255, 0, pixel_f.z/pixel_f.a), clamp(255, 0, pixel_f.a));
    end else
  if CountSamples > 0 then
    Pixel_f := Pixel_f / CountSamples;

  PVec4b(PByte(buf.Memory)+(y*(CurrentResampleSize.x*SizeOf(TVec4b) + NewPadding) + x*SizeOf(TVec4b)))^ := Pixel_f;
end;

constructor TSamplerFilterRGBA.Create;
begin
  inherited;
  { default bilinear filter }
  InterpolationMode := imLanczos;
end;

function TSamplerFilterRGBA.SizeOfSample: uint8;
begin
  Result := SizeOf(TVec4b);
end;

{ TSamplerFilterAlpha }

procedure TSamplerFilterAlpha.BeginPrepareSample;
begin
  Alpha := 0;
  CountSamples := 0;
end;

procedure TSamplerFilterAlpha.EndPreparedSample(x, y: int32);
begin
  if FilterAssigned then
    begin
    if Alpha <> 0 then
      Alpha := clamp(255, 0, Alpha);
    end else
  if CountSamples > 0 then
    Alpha := Alpha div CountSamples;

  (PByte(buf.Memory) + (y * (CurrentResampleSize.x + NewPadding) + x))^ := byte(Alpha);
end;

procedure TSamplerFilterAlpha.PrepareSampleHor(x, y: int32; w: BSFloat);
var
  pixel: byte;
begin
  pixel := (PByte(FCanvas.Raw.Memory) + (y * (FCanvas.Width + FCanvas.Padding) + x))^;
  if w <> 1.0 then
    Alpha := Alpha + round(pixel * w) else
    Alpha := Alpha + pixel;
  inc(CountSamples);
end;

procedure TSamplerFilterAlpha.PrepareSampleVert(x, y: int32; w: BSFloat);
var
  pixel: byte;
begin
  pixel := PByte(PByte(buf.Memory) + (y * (CurrentResampleSize.x + NewPadding) + x))^;
  if w <> 1.0 then
    Alpha := Alpha + round(pixel * w) else
    Alpha := Alpha + pixel;
  inc(CountSamples);
end;

function TSamplerFilterAlpha.SizeOfSample: uint8;
begin
  Result := SizeOf(byte);
end;

{ flipped picture (RGB or RGBA only!) by read from down to up lines and write as RGBA colors;
  !!! Always exchange red and blue colors }
procedure CopyBmp(DataOffset: int32; Source: TStream; Dest: pByte; Width, Height: int32;
  Boundary, Step: int8; Flipped: boolean = true);
var
  i, j, pos_r, pos_w, w: int32;
  ord: byte;
  S: pByte;
begin
  if (Width*Step) mod Boundary > 0 then
    ord := Boundary - (Width*Step) mod Boundary
  else
    ord := 0;
  w := Width * Step + ord;
  pos_w := 0;
  TPicCodecManager.WidenBuf.Position := 0;
  TPicCodecManager.WidenBuf.Size := w;
  for i := 0 to Height - 1 do
  begin
    pos_r := 0;
    s := TPicCodecManager.WidenBuf.Memory;
    if Flipped then
      Source.Position := int64(DataOffset + (Height - 1 - i) * w) {%H-}
    else
      Source.Position := int64(DataOffset + (i) * w){%H-};
    Source.Read(s^, w);
    for j := 0 to Width - 1 do
    begin
      Dest[pos_w]   := s[pos_r+2];
      Dest[pos_w+1] := s[pos_r+1];
      Dest[pos_w+2] := s[pos_r];
      if Step = 4 then
        Dest[pos_w+3] := s[pos_r+3]
      else    //
        Dest[pos_w+3] := 255;
      inc(pos_w, 4);
      inc(pos_r, Step);
    end;
    //dec(pos_r, (ord + Step * Width) * 2);
  end;
end;

{ TPicCodecManager }

class function TPicCodecManager.Open(const FileName: string): TBlackSharkPicture;
var
  ext: string;
  f: TMemoryStream;
begin
  ext := ExtractFileExt(FileName);
  f := TMemoryStream.Create;
  f.LoadFromFile(FileName);
  try
    Result := Open(f, StringToAnsi(ext));
  finally
    f.Free;
  end;
  if Assigned(Result) then
    Result.FCaption := ExtractFileName(FileName);
end;

class destructor TPicCodecManager.Destroy;
var
  i: Integer;
begin
  if (Codecs <> nil) then
  begin
    for i := 0 to Codecs.Count - 1 do
      dispose(Codecs.Items[i]);
    Codecs.Free;
    Signatures.Free;
    Extentions.Free;
  end;
  FreeAndNil(FWidenBuf);
end;

class function TPicCodecManager.GetWidenBuf: TWidenBuffer;
begin
  if FWidenBuf = nil then
    FWidenBuf := TWidenBuffer.Create;
  Result := FWidenBuf;
end;

class function TPicCodecManager.Open(Stream: TStream; const Ext: AnsiString = ''): TBlackSharkPicture;
var
  buf: array[0..127] of byte;
  i, j: Integer;
  decoder: PCodecRec;
  upExt: AnsiString;
begin
  Stream.Position := 0;
  for i := 0 to 7 do
  begin
    Stream.Read({%H-}buf[0], SizeOf(buf));
    for j := 0 to SizeOf(buf) - 1 do
    begin
      Signatures.FindSoft(@buf[j], SizeOf(buf) - j, decoder);
      if Assigned(decoder) and (decoder^.SignatureBoundaryBegin >= j) and
        (decoder^.SignatureBoundaryEnd <= j) then
      begin
        Result := decoder^.Codec.Create;
        Stream.Position := 0;
        if Result.Open(Stream) then
          exit
        else
          FreeAndNil(Result);
      end;
    end;
  end;

  if Ext <> '' then
  begin
    upExt := AnsiUp(Ext);
    Extentions.FindSoft(@upExt[1], Length(upExt), decoder);
    if Assigned(decoder) then
    begin
      Result := decoder^.Codec.Create;
      Stream.Position := 0;
      if Result.Open(Stream) then
        exit
      else
        FreeAndNil(Result);
    end;
  end;
  Result := nil;
  raise Exception.Create('Cannot find a codec for this picture!');
end;

class procedure TPicCodecManager.RegisterCodec(Codec: TBlackSharkPictureClass;
  const Extention: array of AnsiString; const Signature: array of byte;
  SignatureBoundaryBegin: int32 = 0; SignatureBoundaryEnd: int32 = 0);
var
  CodecRec: PCodecRec;
  i: int32;
begin
  if Codecs = nil then
  begin
    Codecs := TListVec<PCodecRec>.Create;
    Signatures := TBinTree<PCodecRec>.Create;
    Extentions := TBinTree<PCodecRec>.Create;
  end;
  new(CodecRec);
  CodecRec^.Codec := Codec;
  CodecRec^.SignatureBoundaryBegin := SignatureBoundaryBegin;
  CodecRec^.SignatureBoundaryEnd := SignatureBoundaryEnd;
  for i := 0 to length(Extention) - 1 do
    Extentions.Add(AnsiUp(Extention[i]), CodecRec);
  i := length(Signature);
  if i > 0 then
    Signatures.Add(@Signature[0], i, CodecRec);
  Codecs.Add(CodecRec);
end;

{ TBlackSharkPicture }

procedure TBlackSharkPicture.Assign(Picture: TBlackSharkPicture);
begin
  FPixelFormat := Picture.FPixelFormat;
  FCaption := Picture.FCaption;
  if Picture.FCanvas <> nil then
  begin
    SetSize(Picture.FCanvas.Width, Picture.FCanvas.Height);
    if FCanvas <> nil then
      FCanvas.Assign(Picture.FCanvas);
  end;
end;

constructor TBlackSharkPicture.Create;
begin
  inherited;
  FPixelFormat := TBSPixelFormat.pf32bit;
end;

procedure TBlackSharkPicture.CreateCanvas;
begin
  FreeAndNil(FCanvas);
  case FPixelFormat of
    pf8bit: FCanvas := TBlackSharkRasterizatorAlpha.Create(Width, Height);
    pf16bit: ;
    pf24bit: FCanvas := TBlackSharkRasterizatorRGB.Create(Width, Height);
    pf32bit: FCanvas := TBlackSharkRasterizatorRGBA.Create(Width, Height);
  end;
  if FCanvas = nil then
    raise Exception.Create('Do not create raster canvas - uncknown pixel format');
end;

destructor TBlackSharkPicture.Destroy;
begin
  FreeAndNil(FCanvas);
  inherited;
end;

function TBlackSharkPicture.GetHeight: int32;
begin
  if FCanvas = nil then
    Result := 0
  else
    Result := FCanvas.Height;
end;

function TBlackSharkPicture.GetWidth: int32;
begin
  if FCanvas = nil then
    Result := 0
  else
    Result := FCanvas.Width;
end;

function TBlackSharkPicture.Open(const FileName: string): boolean;
var
  f: TFileStream;
begin
  FCaption := ExtractFileName(FCaption);
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := Open(f);
  finally
    f.Free;
  end;
end;

function TBlackSharkPicture.Open(Stream: TStream): boolean;
begin
  Result := true;
  CreateCanvas;
  FCanvas.Raw.LoadFromStream(Stream);
end;

function TBlackSharkPicture.Save(const FileName: string): boolean;
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    Result := Save(f);
  finally
    f.Free;
  end;
end;

procedure TBlackSharkPicture.SetHeight(const Value: int32);
begin
  SetSize(Width, Value);
end;

procedure TBlackSharkPicture.SetPixelFormat(const Value: TBSPixelFormat);
begin
  if FPixelFormat = Value then
    exit;
  FPixelFormat := Value;
  CreateCanvas;
end;

procedure TBlackSharkPicture.SetSize(AWidth, AHeight: int32);
begin
  if FCanvas = nil then
    CreateCanvas;
  FCanvas.SetSize(AWidth, AHeight); //:= int64(FSquare * BYTES_PER_PIXEL[FPixelFormat]){%H-};
end;

procedure TBlackSharkPicture.SetWidth(const Value: int32);
begin
  SetSize(Value, Height);
end;

function OpenBitMap(SourceStream: TStream; DestPic: TBlackSharkPicture; Flipped: boolean = false): boolean;
type
  TBaseBMPHeader = packed record
    bfType      : uint16;
    bfSize      : int32;
    bfReserved  : uint32;
    bfOffBits   : uint32;
  end;
  TBaseInfoHeader = packed record
    biSize          : uint32;
    biWidth         : int32;
    biHeight        : int32;
    biplanes        : uint16;
    biBitCount      : uint16;
    biCompression   : uint32;
    biSizeImage     : uint32;
    biXPelsPerMeter : int32;
    biYPelsPerMeter : int32;
    biClrUsed       : uint32;
    biClrImportant  : uint32;
  end;

var
  hdr: TBaseBMPHeader;
  hdr_info: TBaseInfoHeader;
  dataPos: int32;
begin
  //TWidenBuffer(Stream).SaveToFile('d:\TBlackSharkTextureRaster.LoadFrom.Bmp');
  SourceStream.Position := 0;
  if SourceStream.Size < 58 then
    exit(false);
  SourceStream.Read(hdr{%H-}, SizeOf(TBaseBMPHeader));
  SourceStream.Read(hdr_info{%H-}, SizeOf(TBaseInfoHeader));
  case hdr_info.biBitCount of
     1: DestPic.FPixelFormat := pf1Bit;
     4: DestPic.FPixelFormat := pf4Bit;
     8: DestPic.FPixelFormat := pf8Bit;
    15: DestPic.FPixelFormat := pf15Bit;
    16: DestPic.FPixelFormat := pf16Bit;
    24: DestPic.FPixelFormat := pf24Bit;
    32: DestPic.FPixelFormat := pf32Bit;
  end;
  //FWidth        := hdr_info.biWidth; // PInteger(@hdr[$12])^;
  //FHeight       := hdr_info.biHeight; // PInteger(@hdr[$16])^;
  DestPic.SetSize(hdr_info.biWidth, hdr_info.biHeight);
  dataPos       := hdr.bfOffBits; // PInteger(@hdr[$0A])^;
  DestPic.Canvas.Raw.Position := 0;
  if (DestPic.Height = 0) or (DestPic.Width = 0) then
    exit(false);
  if (dataPos = 0) then
    dataPos := 54;
  //RawData := pByte(FRaw.Memory) + dataPos;
  //SourceStream.Position := dataPos;
  //SourceStream.Read(pByte(DestPic.Canvas.Raw.Memory)^, hdr_info.biWidth * hdr_info.biHeight * BYTES_PER_PIXEL[DestPic.FPixelFormat]);
  //move(RawData^, pByte(FRaw.Memory)^, FWidth * FHeight * BYTES_PER_PIXEL[Bmp.PixelFormat] ); //
  CopyBmp(dataPos, SourceStream, DestPic.Canvas.Raw.Memory, DestPic.Width, DestPic.Height, 4, BYTES_PER_PIXEL[DestPic.FPixelFormat], Flipped);
  Result := true;
end;

{ TBlackSharkBitMap }

function TBlackSharkBitMap.Open(Stream: TStream): boolean;
begin
  //FFlipColor := true;
  Result := OpenBitMap(Stream, Self, true);
end;

function TBlackSharkBitMap.Save(Stream: TStream): boolean;
var
  bh: TBMPInfoHeader;
  fh: TBMPFileHdr;
  i: int32;
  //pb: PByte;
  cl: PVec4b;
  cl_flip: TVec4b;
begin
  if (FCanvas.FRaw.Size = 0) then
    exit(false);
  FillChar(fh{%H-}, SizeOf(fh), 0);
  FillChar(bh{%H-}, SizeOf(bh), 0);
  fh.bfSize := Width * Height * BYTES_PER_PIXEL[FPixelFormat] + SizeOf(fh) + SizeOf(bh);
  fh.bfType := $4d42;
  bh.biSize := SizeOf(bh);
  bh.biWidth := Width;
  bh.biHeight := Height;
  bh.biPlanes := 1;
  bh.biBitCount := BYTES_PER_PIXEL[FPixelFormat]*8;
  bh.biSizeImage := Width * Height * BYTES_PER_PIXEL[FPixelFormat];
  //s.Write(pByte(FRaw.Memory)^, FRaw.Size);
  case BYTES_PER_PIXEL[FPixelFormat] of
  1: begin
    bh.biClrUsed := 2;
    fh.bfOffBits := SizeOf(fh) + SizeOf(bh) + SizeOf(cl_flip)*bh.biClrUsed;
    Stream.Write(fh, SizeOf(fh));
    Stream.Write(bh, SizeOf(bh));
    cl_flip := vec4(255, 255, 255, 255);
    Stream.Write(cl_flip, SizeOf(cl_flip));
    cl_flip := vec4(128, 128, 128, 128);
    Stream.Write(cl_flip, SizeOf(cl_flip));
    Stream.Write(FCanvas.FRaw.Memory^, FCanvas.FRaw.Size);
    {if FCanvas.Padding = 0 then
      Stream.Write(FCanvas.FRaw.Memory^, Height*Width) else
      begin
      for i := 0 to Height - 1 do
        begin
        cl_flip := vec4(cl^.b, cl^.g, cl^.r, cl^.a);
        Stream.Write(cl_flip, SizeOf(cl_flip));
        inc(cl);
        end;
      end; }
    end;
  4: begin
    fh.bfOffBits := SizeOf(fh) + SizeOf(bh);
    Stream.Write(fh, SizeOf(fh));
    Stream.Write(bh, SizeOf(bh));
    cl := PVec4b(FCanvas.FRaw.Memory);
    for i := 0 to Height*Width - 1 do
      begin
      cl_flip := vec4(cl^.b, cl^.g, cl^.r, cl^.a);
      Stream.Write(cl_flip, SizeOf(cl_flip));
      inc(cl);
      end;
    end else
    begin
      raise Exception.Create('For current pixel format the method (TBlackSharkBitMap.Save) don''t implemented!');
    end;
  end;
  Result := true;
end;

{ TBlackSharkPng }

procedure TBlackSharkPng.GrayscaleAlphaToRgba(ASource, ADest: PByte; AWidth: int32);
var
  i: int32;
begin
  for i := 0 to AWidth - 1 do
  begin
    ADest^ := ASource^; inc(ADest);
    ADest^ := ASource^; inc(ADest);
    ADest^ := ASource^; inc(ADest); inc(ASource);
    ADest^ := ASource^; inc(ADest); inc(ASource);
  end;
end;

procedure TBlackSharkPng.GrayscaleToRgba(ASource, ADest: PByte; AWidth: int32);
var
  i: int32;
begin
  for i := 0 to AWidth - 1 do
  begin
    ADest^ := ASource^; inc(ADest);
    ADest^ := ASource^; inc(ADest);
    ADest^ := ASource^; inc(ADest); inc(ASource);
    ADest^ := $FF;      inc(ADest);
  end;
end;

procedure TBlackSharkPng.MoveRgba(ASource: PByte; ADest: PByte; ARowWidth: int32);
begin
  move(ASource^, ADest^, ARowWidth*4);
end;

procedure TBlackSharkPng.RgbToRgba(ASource, ADest: PByte; AWidth: int32);
var
  i: int32;
begin
  for i := 0 to AWidth - 1 do
  begin
    move(ASource^, ADest^, 3);
    inc(ASource, 3);
    inc(ADest, 3);
    ADest^ := $FF;
    inc(ADest);
  end;
end;

function TBlackSharkPng.Open(Stream: TStream): boolean;
const
  PNG_SIGN = $474E5089;
  PNG_IHDR = $52444849;
  PNG_IEND = $444E4549;
  PNG_IDAT = $54414449;
const
  PNG_PF_GRAYSCALE       = 0;
  PNG_PF_RGB             = 2;
  PNG_PF_PALETTE         = 3;
  PNG_PF_GRAYSCALE_ALPHA = 4;
  PNG_PF_RGBA            = 6;

var
  i: int32;
  hdr: TPNGHeader;
  chank: TPNGChunk;
  value32: int32;
  sizeSource: int32;
  notFirstRow: boolean;
  pixelSize: int32;
  widthBytes: int32;
  widthBytesDest: int32;
  rowPosition: int32;
  decompressor: ZLibDecompressor;
  chank_buf: array of byte;
  prevRow: array of byte;
  outStream: TWidenBuffer;
  copyRowMethod: procedure (ASource: PByte; ADest: PByte; ARowWidth: int32) of object;

  procedure FilterRow(ARow: PByte; ARowPrev: PByte);

    function PaethPredictor(a, b, c : int32) : int32;
      var
        p, pa, pb, pc: int32;
    begin
      p  := a + b - c;
      pa := abs(p - a);
      pb := abs(p - b);
      pc := abs(p - c);
      if (pa <= pb) and (pa <= pc) Then
        Result := a
      else
      if pb <= pc Then
        Result := b
      else
        Result := c;
    end;

    const
      PNG_FILTER_NONE    = 0;
      PNG_FILTER_SUB     = 1;
      PNG_FILTER_UP      = 2;
      PNG_FILTER_AVERAGE = 3;
      PNG_FILTER_PAETH   = 4;

    var
      i: int32;
      Paeth: int32;
      PP: int32;
      Left: int32;
      Above: int32;
      AboveLeft: int32;

  begin
    case ARow[ 0 ] of
      PNG_FILTER_NONE:;

      PNG_FILTER_SUB:
        for i := pixelSize + 1 to widthBytes do
          ARow[i] := (ARow[i] + ARow[i-pixelSize]) and $FF;

      PNG_FILTER_UP:
        for i := 1 to widthBytes do
          ARow[i] := (ARow[i] + ARowPrev[i-1]) and $FF;

      PNG_FILTER_AVERAGE:
        for i := 1 to widthBytes do
        begin
          Above := ARowPrev[i-1];
          if i - 1 < pixelSize Then
            Left := 0
          else
            Left := ARow[i - pixelSize];

          ARow[i] := (ARow[i] + (Left + Above) shr 1) and $FF;
        end;

      PNG_FILTER_PAETH:
        begin
          Left      := 0;
          AboveLeft := 0;
          for i := 1 to widthBytes do
          begin
            if i - 1 >= pixelSize Then
            begin
              Left      := ARow[i - pixelSize];
              AboveLeft := ARowPrev[i - pixelSize - 1];
            end;

            Above := ARowPrev[i - 1];
            if AboveLeft > 0 then
              AboveLeft := AboveLeft;

            Paeth := ARow[i];
            PP := PaethPredictor(Left, Above, AboveLeft);

            ARow[i] := (Paeth + PP) and $FF;
          end;
        end;
    end;
  end;


begin
  sizeSource := Stream.Size;
  if sizeSource < 32 then
    exit(false);
  Stream.Read(value32, 4);
  if value32 <> PNG_SIGN then
    exit(false);

  Stream.Position := 8;
  Stream.Read(hdr, SizeOf(hdr));

  if hdr.Base.Name <> PNG_IHDR then
    exit(false);

  hdr.Width := htonl(hdr.Width);
  hdr.Height := htonl(hdr.Height);

  case hdr.ColorType of
    PNG_PF_RGB:
    begin
      PixelFormat := TBSPixelFormat.pf32bit;
      widthBytes := (hdr.Width * hdr.BitDepth * 3) shr 3;
      pixelSize := 3 * hdr.BitDepth div 8;
      copyRowMethod := RgbToRgba;
    end;
    PNG_PF_RGBA:
    begin
      PixelFormat := TBSPixelFormat.pf32bit;
      widthBytes := (hdr.Width * hdr.BitDepth * 4) shr 3;
      pixelSize := 4 * hdr.BitDepth div 8;
      copyRowMethod := MoveRgba;
    end;
    PNG_PF_PALETTE:
    begin
      widthBytes := (hdr.Width * hdr.BitDepth + 7) shr 3;
      pixelSize := 1;
      copyRowMethod := PaletteToRgba;
      raise ETODO.Create('TODO: now it doesn''t support yet');
    end;
    PNG_PF_GRAYSCALE:
    begin
      PixelFormat := TBSPixelFormat.pf32bit;
      widthBytes := (hdr.Width * hdr.BitDepth + 7) shr 3;
      pixelSize := hdr.BitDepth div 8;
      copyRowMethod := GrayscaleToRgba;
    end;
    PNG_PF_GRAYSCALE_ALPHA:
    begin
      PixelFormat := TBSPixelFormat.pf32bit;
      widthBytes := (hdr.Width * hdr.BitDepth * 2) shr 3;
      pixelSize := 2 * hdr.BitDepth div 8;
      copyRowMethod := GrayscaleAlphaToRgba;
    end
    else
      exit(false);
  end;

  widthBytesDest := BYTES_PER_PIXEL[PixelFormat]*hdr.Width;
  hdr.Base.Size := htonl(hdr.Base.Size);
  SetSize(hdr.Width, hdr.Height);
  FCanvas.Raw.Position := 0;
  // + 4 - skip CRC
  Stream.Position := Stream.Position + 4;
  rowPosition := FCanvas.Raw.Size - widthBytesDest - FCanvas.Padding;
  notFirstRow := false;

  decompressor := ZLibDecompressor.Create;

  SetLength(prevRow, widthBytes);
  outStream := TPicCodecManager.WidenBuf; // TWidenBuffer.Create;

  while (sizeSource > Stream.Position) and (rowPosition >= 0) do
  begin
    Stream.Read(chank, SizeOf(chank));
    chank.Size := htonl(chank.Size);

    if chank.Name = PNG_IDAT then
    begin
      if length({%H-}chank_buf) < chank.Size + 1 then
        SetLength(chank_buf, chank.Size + 1);

      Stream.Read(chank_buf[0], chank.Size);

      decompressor.Decompress(@chank_buf[0], chank.Size, outStream);
      for i := 0 to outStream.Position div (widthBytes+1) - 1 do
      begin
        value32 := i*(widthBytes+1);
        if notFirstRow then
        begin
          FilterRow(@(PByte(outStream.Memory)[value32]), @prevRow[0]);
        end else
          notFirstRow := true;

        move(PByte(outStream.Memory)[value32+1], prevRow[0], widthBytes);
        copyRowMethod(@(PByte(outStream.Memory)[value32+1]), @(PByte(FCanvas.Raw.Memory)[rowPosition]), hdr.Width);
        dec(rowPosition, widthBytesDest + FCanvas.Padding);
      end;

      // remainder
      value32 := outStream.Position mod (widthBytes+1);
      if value32 > 0 then
        move(pByte(outStream.Memory)[outStream.Position - value32], pByte(outStream.Memory)^, value32);
      //f.Position := f.Position - value32;
      outStream.Position := value32;

      // skip CRC
      Stream.Position := Stream.Position + 4;
    end else
    if chank.Name = PNG_IEND then
      break
    else
      Stream.Position := Stream.Position + chank.Size + 4;
  end;
  SetLength(chank_buf, 0);
  SetLength(prevRow, 0);
  decompressor.Free;

  Result := true;
end;

procedure TBlackSharkPng.PaletteToRgba(ASource, ADest: PByte; AWidth: int32);
begin
  raise ETODO.Create('PaletteToRgba');
end;

function TBlackSharkPng.Save(Stream: TStream): boolean;
begin
  {$ifdef FPC}
  Result := true;
  {$endif}
  raise ETODO.Create('This feature doesn''t implemented yet! Please, write to shark.engl@gmail.com if you very need it');
end;


(*
constructor TBlackSharkTextureDDS.Create(AWidth, AHeight: int32;
  AName: string);
begin
  inherited;
end;

procedure TBlackSharkTextureDDS.LoadToGPU(FreeRawData: boolean = true);
const
  FOURCC_DXT1 = $31545844; // Equivalent to "DXT1" in ASCII
  FOURCC_DXT3 = $33545844; // Equivalent to "DXT3" in ASCII
  FOURCC_DXT5 = $35545844; // Equivalent to "DXT5" in ASCII
var
  mipMapCount: int32;
  fourCC: int32;
  //components: int32;
  format: int32;
  level: int32;
  size: int32;
  offset, w, h: int32;
  blockSize: int8;
begin
	// verify the type of file
  if not CompareMem(FRaw.Memory, @AnsiString('DDS ')[1], 4) then
    begin
    BSWriteMsg('TBlackSharkTextureDDS.LoadToGPU', 'Fail to load DDS file: ' + string(FName));
    exit;
    end;

	// get the surface desc
	FHeight     := PInteger(@pByte(FRaw.Memory)[12 ])^;
	FWidth	    := PInteger(@pByte(FRaw.Memory)[16])^;
	//linearSize	:= PInteger(@BufForTex[20])^;
	mipMapCount := PInteger(@pByte(FRaw.Memory)[28])^;
	fourCC      := PInteger(@pByte(FRaw.Memory)[84])^;
  {if (fourCC = FOURCC_DXT1) then
	  components := 3 else components := 4; }
	case (fourCC) of
	FOURCC_DXT1:
		format := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
  FOURCC_DXT3:
		format := GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
  FOURCC_DXT5:
		format := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT else
    begin
    BSWriteMsg('TBlackSharkTextureDDS.LoadToGPU', 'Fail to load DDS file (uncknown type or error format): ' + string(FName));
    exit;
    end;

  end;

	// Create one OpenGL texture
	glGenTextures(1, @FProgramID);

	// "Bind" the newly created texture : all future texture functions will modify this texture
	glBindTexture(GL_TEXTURE_2D, FProgramID);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  if (format = FOURCC_DXT1) then
	  blockSize := 8 else
    blockSize := 16;

  offset := 128;
  w := FWidth;
  h := FHeight;
	// load the mipmaps
	for level := 0 to mipMapCount - 1 do
	  begin
		size := ((w + 3) div 4) * ((h + 3) div 4) * blockSize;
		if int64(offset) + int64(size) > FRaw.Size then
      break;
		glCompressedTexImage2D(GL_TEXTURE_2D, level, format, w, h,
			0, size, pByte(FRaw.Memory) + offset);

		inc(offset, size);
		w  := w div 2;
		h := h div 2;

		if(w = 0) or (h = 0) then
      break;
	  end;
  if FreeRawData then
    FreeRaw;
end;


{ TBlackSharkTextureTGA }

function TBlackSharkTextureTGA.LoadToRAM(SourceFileName: string): boolean;
type
  // формат заголовка TGA-файла
  PTGAHeader = ^TTGAHeader;
  TTGAHeader = packed record
	  idlength: uint8;
	  colormap: uint8;
	  datatype: uint8;
	  colormapinfo: array [0..4] of uint8;
	  xorigin: uint16;
	  yorigin: uint16;
	  width: uint16;
	  height: uint16;
	  bitperpel: uint8;
	  description: uint8;
  end;
var
	TGAHeader: PTGAHeader;
begin
  inherited;
	if (FRaw.Size <= sizeof(TGAHeader)) then
    begin
    BSWriteMsg('BlackSharkTexture.LoadTGA', 'Fail to load TGA texture: ' + FName);
    exit(false);
    end;

	TGAHeader := PTGAHeader(FRaw.Memory);

	// check format TGA - uncompress RGB or RGBA picture
	if (((TGAHeader^.bitperpel <> 24) and (TGAHeader^.bitperpel <> 32))) then  //(TGAHeader^.datatype <> 2) or
	  begin
    BSWriteMsg('BlackSharkTexture.LoadTGA', 'Fail to load TGA texture: ' + FName);
    exit(false);
	  end;

	// get format
  if (TGAHeader^.bitperpel = 24) then
    begin
    Format := GL_RGB;
    InternalFormat := GL_RGB;
    end else
    begin
    Format := GL_RGBA;
    InternalFormat := GL_RGBA;
    end;
  FWidth := TGAHeader^.width;
  FHeight := TGAHeader^.height;
  FRaw.Position := 0;
  FRaw.WriteBuffer(pByte(FRaw.Memory)[sizeof(TTGAHeader) + TGAHeader^.idlength], FRaw.Size - sizeof(TTGAHeader) + TGAHeader^.idlength);
  Result := true;
end;

{ TBlackSharkTextureRaster }

function TBlackSharkTextureRaster.LoadFromBmp(Bmp: TBitMap): boolean;
var
  hdr, RawData: PByte;
  dataPos: int32;
begin
  // reserve capacity
  FRaw.Size := int64(FWidth) * int64(FHeight) * int64(SizeOf(TVec4b));
  FRaw.Position := 0;
  bmp.SaveToStream(FRaw);
  //FRaw.SaveToFile('d:\TBlackSharkTextureRaster.LoadFrom.Bmp');
  if FRaw.Size < 58 then
    exit(false);
  hdr        := FRaw.Memory;
  dataPos    := PInteger(@hdr[$0A])^;
  FWidth     := PInteger(@hdr[$12])^;
  FHeight    := PInteger(@hdr[$16])^;
  if (FHeight = 0) or (FWidth = 0) then
    exit(false);
  if (dataPos = 0) then
    dataPos := 54;
  RawData := pByte(FRaw.Memory) + dataPos;
  //move(RawData^, pByte(FRaw.Memory)^, FWidth * FHeight * 4);
  OverturnPicture(RawData, FRaw.Memory, FWidth, FHeight, 4, BYTES_PER_PIXEL[Bmp.PixelFormat]);
  Result := true;
end;

function TBlackSharkTextureRaster.LoadToRAM(SourceFileName: string): boolean;
var
  {$ifndef FMX}
    Picture: TPicture;
  {$endif}
  bmp: TBitmap;
  PixelFormat: TPixelFormat;
  {$ifdef usejpeg}
  jp: TJPEGImage;
  ext: WideString;
  {$endif}
begin
  inherited;
  {$ifndef FMX}
    Picture := TPicture.Create;
  {$endif}
  bmp := TBitmap.Create;
  {$ifdef usejpeg}
  jp := nil;
  {$endif}
  try
    try
      {$ifdef usejpeg}
      ext := AnsiUpperCase(ExtractFileExt(string(FName)));
      if (ext = '.JPG') then
        begin
        jp := TJPEGImage.Create;
        jp.LoadFromStream(FRaw);
        Picture.Graphic := jp;
        end else
      {$endif}
      {$ifdef FMX}
      bmp.LoadFromStream(FRaw);
      //bmp.
      {$else}
      { TODO: for VCL LoadFromStream method absent :( What do ??? }
      //Picture.LoadFromFile(string(SourceFileName));
      Picture.LoadFromStream(FRaw);
      if (Picture.Height = 0) then
        exit(false);
      bmp.Assign(Picture.Graphic);
      {$endif}
      PixelFormat := bmp.PixelFormat;
      if (BYTES_PER_PIXEL[PixelFormat] < 3) then
        begin
        if BYTES_PER_PIXEL[PixelFormat] = 0 then
          begin
          if bmp.Width mod 4 = 0 then
            begin
            {$ifdef FMX}
            PixelFormat := TPixelFormat.RGBA;
            {$else}
            PixelFormat := TPixelFormat.pf32bit;
            {$endif}
            end else
            exit(false);
          end else
          exit(false);
        end;

      FHeight := bmp.Height;
      FWidth := bmp.Width;
      Result := LoadFromBmp(bmp);
      InternalFormat := GL_RGBA;
      Format := GL_RGBA;
      if not Result then
        exit;
    except
      BSWriteMsg('BlackSharkTexture.LoadImage', 'Fail to load: ' + FName);
      exit(false);
    end;
  finally
    {$ifndef FMX}
      Picture.Free;
    {$endif}
    bmp.Free;
    //str.free;
    {$ifdef usejpeg}
    if jp <> nil then
      jp.Free;
    {$endif}
  end;
end;  *)

{ TBlackSharkDDS }

function TBlackSharkDDS.Open(Stream: TStream): boolean;
begin
  Result := false;
end;

function TBlackSharkDDS.Save(Stream: TStream): boolean;
begin
  {$ifdef FPC}
  Result := false;
  {$endif}
  raise Exception.Create('TBlackSharkDDS.Save is not implemeted!');
end;

{ TBlackSharkTGA }

function TBlackSharkTGA.Open(Stream: TStream): boolean;
type
  // формат заголовка TGA-файла
  TTGAHeader = packed record
	  idlength: uint8;
	  colormap: uint8;
	  datatype: uint8;
	  colormapinfo: array [0..4] of uint8;
	  xorigin: uint16;
	  yorigin: uint16;
	  width: uint16;
	  height: uint16;
	  bitperpel: uint8;
	  description: uint8;
  end;
var
	TGAHeader: TTGAHeader;
  rawSize: int32;
begin
	if (Stream.Size <= sizeof(TGAHeader)) then
    exit(false);

  FillChar(TGAHeader, SizeOf(TGAHeader), 0);
  Stream.Position := 0;
	Stream.ReadBuffer(TGAHeader{%H-}, SizeOf(TTGAHeader));

	// check format TGA - uncompress RGB or RGBA picture
	if (((TGAHeader.bitperpel <> 24) and (TGAHeader.bitperpel <> 32))) then  //(TGAHeader^.datatype <> 2) or
    exit(false);

	// get format
  if (TGAHeader.bitperpel = 24) then
  begin
    FPixelFormat := TBSPixelFormat.pf24bit;
  end else
  begin
    FPixelFormat := TBSPixelFormat.pf32bit;
  end;
  SetSize(TGAHeader.width, TGAHeader.height);
  FCanvas.Raw.Position := 0;
  rawSize := Stream.Size - sizeof(TTGAHeader) + TGAHeader.idlength;
  if rawSize > Width*Height*BYTES_PER_PIXEL[FPixelFormat] then
    rawSize := Width*Height*BYTES_PER_PIXEL[FPixelFormat];
  Stream.Read(pByte(FCanvas.Raw.Memory)^, rawSize);
  Result := true;
end;

function TBlackSharkTGA.Save(Stream: TStream): boolean;
begin
  {$ifdef FPC}
  Result := false;
  {$endif}
  raise Exception.Create('TBlackSharkTGA.Save is not implemeted!');
end;

{ TBlackSharkRasterizatorAlpha }

class function TBlackSharkRasterizatorAlpha.CreateDefaultSampler: TSamplerFilter;
begin
  Result := TSamplerFilterAlpha.Create;
end;

procedure TBlackSharkRasterizatorAlpha.ReplaceColor(const AColor);
var
  i: int32;
  ptr: PByte;
  cl: byte;
begin
  ptr := FRaw.Memory;
  move(AColor, cl{%H-}, SizeOf(cl));
  for i := 0 to FHeight * FWidth - 1 do
  begin
    ptr^ := cl;
    inc(ptr);
  end;
end;

procedure RegisterBaseCodecs;
begin
  TPicCodecManager.RegisterCodec(TBlackSharkBitMap, ['.BMP'], [$42, $4D]);
  TPicCodecManager.RegisterCodec(TBlackSharkPng, ['.PNG'], [$89, $50, $4E, $47]);
  TPicCodecManager.RegisterCodec(TBlackSharkTGA, ['.TGA'], []);
  TPicCodecManager.RegisterCodec(TBlackSharkDDS, ['.DDS'], [$44, $44, $53]);
end;

procedure InitColorMap;
begin
  ColorMap := TListVec<TColorMapRec>.Create;
  ColorMap.Count := TGuiColors.Count;
  ColorMap.Items[0] := TColorMapRec.ColorMapRec(TGuiColors.Black, 'Black');
  ColorMap.Items[1] := TColorMapRec.ColorMapRec(TGuiColors.White, 'White');
  ColorMap.Items[2] := TColorMapRec.ColorMapRec(TGuiColors.Red, 'Red');
  ColorMap.Items[3] := TColorMapRec.ColorMapRec(TGuiColors.Green, 'Green');
  ColorMap.Items[4] := TColorMapRec.ColorMapRec(TGuiColors.Blue, 'Blue');
  ColorMap.Items[5] := TColorMapRec.ColorMapRec(TGuiColors.Purple, 'Purple');
  ColorMap.Items[6] := TColorMapRec.ColorMapRec(TGuiColors.Olive, 'Olive');
  ColorMap.Items[7] := TColorMapRec.ColorMapRec(TGuiColors.Maroon, 'Maroon');
  ColorMap.Items[8] := TColorMapRec.ColorMapRec(TGuiColors.Navy, 'Navy');
  ColorMap.Items[9] := TColorMapRec.ColorMapRec(TGuiColors.Teal, 'Teal');
  ColorMap.Items[10] := TColorMapRec.ColorMapRec(TGuiColors.Gray, 'Gray');
  ColorMap.Items[11] := TColorMapRec.ColorMapRec(TGuiColors.Silver, 'Silver');
  ColorMap.Items[12] := TColorMapRec.ColorMapRec(TGuiColors.Lime, 'Lime');
  ColorMap.Items[13] := TColorMapRec.ColorMapRec(TGuiColors.Yellow, 'Yellow');
  ColorMap.Items[14] := TColorMapRec.ColorMapRec(TGuiColors.Fuchsia, 'Fuchsia');
  ColorMap.Items[15] := TColorMapRec.ColorMapRec(TGuiColors.Aqua, 'Aqua');
  ColorMap.Items[16] := TColorMapRec.ColorMapRec(TGuiColors.MoneyGreen, 'MoneyGreen');
  ColorMap.Items[17] := TColorMapRec.ColorMapRec(TGuiColors.Cream, 'Cream');
  ColorMap.Items[18] := TColorMapRec.ColorMapRec(TGuiColors.MedGray, 'MedGray');
  ColorMap.Items[19] := TColorMapRec.ColorMapRec(TGuiColors.Skyblue, 'Skyblue');
end;

procedure UnInitColorMap;
begin
  ColorMap.Free;
end;

{ TColorMapRec }

class function TColorMapRec.ColorMapRec(AColor: TGuiColor; const AName: AnsiString): TColorMapRec;
begin
  Result.Color := AColor;
  Result.Name := AName;
end;

{ TBlackSharkRasterizatorRGB }

class function TBlackSharkRasterizatorRGB.CreateDefaultSampler: TSamplerFilter;
begin
  Result := TSamplerFilterRGB.Create;
end;

procedure TBlackSharkRasterizatorRGB.ReplaceColor(const AColor);
var
  i: int32;
  ptr: PVec3b;
  hls_src, hls_dst: TVec3f;
  cl: TVec4b;
begin
  ptr := FRaw.Memory;
  move(AColor, cl{%H-}, SizeOf(cl));
  hls_src := RGBtoHLS(TVec3f(TVec4f(ColorByteToFloat(cl))));
  for i := 0 to FHeight * FWidth - 1 do
  begin
    hls_dst := RGBtoHLS(TVec3f(TVec3f(ColorByteToFloat(ptr^))));
    hls_src.l := hls_dst.l;
    cl := ColorFloatToByte(TColor4f(HLStoRGB(hls_src)));
    ptr^ := vec3(cl.x, cl.y, cl.z);
    inc(ptr);
  end;
end;

{ TSamplerFilterRGB }

procedure TSamplerFilterRGB.BeginPrepareSample;
begin
  CountSamples := 0;
  Pixel_f := vec3d(0.0, 0.0, 0.0);
end;

constructor TSamplerFilterRGB.Create;
begin
  { default bilinear filter }
  InterpolationMode := imLanczos;
end;

procedure TSamplerFilterRGB.EndPreparedSample(x, y: int32);
var
  res: TVec3b;
begin
  if FilterAssigned then
      Pixel_f := vec3(clamp(255, 0, pixel_f.x), clamp(255, 0, pixel_f.y), clamp(255, 0, pixel_f.z))
  else
  if CountSamples > 0 then
    Pixel_f := Pixel_f / CountSamples;

  res.x := round(Pixel_f.x);
  res.y := round(Pixel_f.y);
  res.z := round(Pixel_f.z);
  PVec3b(PByte(buf.Memory)+(y*(CurrentResampleSize.x*SizeOf(TVec3b) + NewPadding) + x*SizeOf(TVec3b)))^ := res;
end;

procedure TSamplerFilterRGB.PrepareSampleHor(x, y: int32; w: BSFloat);
var
  pixel: TVec3b;
begin
  pixel := PVec3b(PByte(FCanvas.Raw.Memory) + (y * (FCanvas.FWidth * SizeOf(TVec3b) + FCanvas.Padding) + x * SizeOf(TVec3b)))^;
  if w <> 1.0 then
  begin
    Pixel_f := Pixel_f + vec3(pixel.x * w, pixel.y * w, pixel.z * w);
  end else
  begin
    Pixel_f := vec3(Pixel_f.x + pixel.x, Pixel_f.y + pixel.y, Pixel_f.z + pixel.z);
  end;
  inc(CountSamples);
end;

procedure TSamplerFilterRGB.PrepareSampleVert(x, y: int32; w: BSFloat);
var
  pixel: TVec3b;
begin
  pixel := PVec3b(PByte(buf.Memory) + (y * (CurrentResampleSize.x * SizeOf(TVec3b) + NewPadding) + x * SizeOf(TVec3b)))^;
  if w <> 1.0 then
  begin
    pixel_f := (pixel_f + vec3(pixel.x * w, pixel.y * w, pixel.z * w));
  end else
  begin
    Pixel_f := vec3(Pixel_f.x + pixel.x, Pixel_f.y + pixel.y, Pixel_f.z + pixel.z);
  end;
  inc(CountSamples);
end;

function TSamplerFilterRGB.SizeOfSample: uint8;
begin
  Result := SizeOf(TVec3b);
end;

initialization
  RegisterBaseCodecs;
  InitColorMap;

finalization
  UnInitColorMap;

end.
