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


unit bs.texture;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.graphics
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.basetypes
  , bs.geometry
  , bs.collections
  ;

const
  PIXEL_FORMAT_TO_GL: array[TBSPixelFormat] of integer =
  (
    0, 0, 0, GL_ALPHA, 2, 2, GL_RGBA, GL_RGBA, 0
  );
type

  TTextureRect = record
    Rect: TRectBSf; // absolute texture coordinates
    UV: TRectBSf;   // normal texture coordinates
  end;

  PTextureArea = ^TTextureArea;

  { IBlackSharkTexture }

  IBlackSharkTexture = interface
    function CopyRect(Source: TBlackSharkRasterCanvas; const Pos: TVec2i;
      const SourceRect: TRectBSi; FillBorder: boolean): PTextureArea; stdcall;
    { Uses a texture, loaded earlier to GPU; ID is number a texture in a fragment
    	shader and allows bind and use several textures }
    procedure UseTexture(ID: int32); stdcall;
    function GetFramesCount: int32; stdcall;
    function GetFrame(index: int32): PTextureArea; stdcall;
    function GetPicture: TBlackSharkPicture; stdcall;
    procedure SetPicture(const Value: TBlackSharkPicture); stdcall;
    procedure BeginUpdate; stdcall;
    procedure EndUpdate(ReloadIfNeed: boolean); stdcall;
    function Color(UV: PTextureArea): TVec4b; stdcall;
    function GetTrilinearFilter: boolean; stdcall;
    procedure SetTrilinearFilter(const Value: boolean); stdcall;
    function GetName: string; stdcall;
    function GetWrapOptions: GLint; stdcall;
    procedure SetWrapOptions(AValue: GLint); stdcall;
    function GetTextureArea: PTextureArea; stdcall;
    function GetInternalFormat: GLint; stdcall;
    procedure ClearAreas; stdcall;
    function GenFrameUV(const X, Y, AreaWidth, AreaHeight: int32): PTextureArea; stdcall;
    property FramesCount: int32 read GetFramesCount;
    property Frames[index: int32]: PTextureArea read GetFrame;
    { picture contain raw texture data; assigning Picture not load data to GPU,
      there for you must manually call LoadToGPU for this }
    property Picture: TBlackSharkPicture read GetPicture write SetPicture;
    property TrilinearFilter: boolean read GetTrilinearFilter write SetTrilinearFilter;
    property Name: string read GetName;
    { WrapOptions define behavior when texture coordinate exceed 1.0 bound;
      available values:
        - GL_CLAMP_TO_EDGE - absent wrap - default value;
        - GL_REPEAT - repeat texture;
        - GL_MIRRORED_REPEAT - mirrored image on evry natural number texture coordinate;
      }
    property WrapOptions: GLint read GetWrapOptions write SetWrapOptions;
    property SelfArea: PTextureArea read GetTextureArea;
    property InternalFormat: GLint read GetInternalFormat;
  end;

  { Output texture rectangle area }

  TTextureArea = record
    Name: string;
    Texture: IBlackSharkTexture;
    //RefCount: int32;
    case byte of
    0: (
      Rect: TRectBSf; // absolute texture coordinates
      UV: TRectBSf    // normal texture coordinates
      );
    1: (TextureRect: TTextureRect);
  end;

  { TBlackSharkTexture }

  TBlackSharkTexture = class;
  TBlackSharkTextureClass = class of TBlackSharkTexture;

  TBlackSharkTexture = class(TObject, IBlackSharkTexture)
  private
  type
    TOnFreeTextureNotify = procedure (const Texture: TBlackSharkTexture) of object;
  private
    FMipMap: boolean;
    FRefCounter: int32;
    FProgramID: GLuint;
	  FInternalFormat: GLint;
    FWrapOptions: GLint;
    FTrilinearFilter: boolean;
    { self texture area describer }
    TextureArea: TTextureArea;
    OnFreeTexture: TOnFreeTextureNotify;
    FName: string;
    FPicture: TBlackSharkPicture;
    UpdateCount: int32;
    FTagPtr: Pointer;
    procedure SetMipMap(AValue: boolean);
    procedure CalcArea; inline;
  protected
    ListFrames: TListVec<PTextureArea>;
    {$ifdef FPC}
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} iid : tguid;out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    {$else}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    {$endif}
    function GetFramesCount: int32; stdcall;
    function GetFrame(index: int32): PTextureArea; stdcall;
    function GetPicture: TBlackSharkPicture; stdcall;
    procedure SetPicture(const Value: TBlackSharkPicture); virtual; stdcall;
    function GetTrilinearFilter: boolean; stdcall;
    procedure SetTrilinearFilter(const Value: boolean); stdcall;
    function GetName: string; stdcall;
    function GetWrapOptions: GLint; stdcall;
    procedure SetWrapOptions(AValue: GLint); stdcall;
    function GetTextureArea: PTextureArea; stdcall;
    function GetInternalFormat: GLint; stdcall;
  public
    constructor Create(AWidth, AHeight: int32; const AName: string;
      ATrilinearFilter: boolean = true; AInternalFormat: GLint = GL_RGBA); virtual;
    destructor Destroy; override;
    procedure Change; virtual;
    procedure Reset;
    procedure BeginUpdate; stdcall;
    procedure EndUpdate(ReloadIfNeed: boolean); stdcall;
    procedure ClearAreas; virtual; stdcall;
    { return UV coordinate color into texture }
    function GenFrameUV(const Rect: TRectBSi): PTextureArea; overload;
    function GenFrameUV(const X, Y, AreaWidth, AreaHeight: int32): PTextureArea; overload; stdcall;
    function Open(const FileName: string): boolean; overload;
    function Open(const Srteam: TStream): boolean; overload;
    function Open(const Pict: TBlackSharkPicture): boolean; overload;
    function CopyRect(Source: TBlackSharkPicture; const Pos: TVec2i;
      const SourceRect: TRectBSi; FillBorder: boolean = true): PTextureArea; overload;
    function CopyRect(Source: TBlackSharkRasterCanvas; const Pos: TVec2i;
      const SourceRect: TRectBSi; FillBorder: boolean): PTextureArea; overload; stdcall;
    function CopyRect(Source: TBlackSharkTexture; const SourceRect: TRectBSi;
      FillBorder: boolean = true): PTextureArea; overload;
    { it allow to copy Rect from FBO; that is befor you must create FBO, setup
    	glBindFramebuffer, and draw scene in texture FBO; for drawing in FBO you
      can use existing pass which contain FBO through TBlackSharkScene.Renderer(
      TBlackSharkScene.Renderers.Items[0]); if TBlackSharkScene.Renderers.Count > 0 then
      first pass always contain FBO for translate result draw geometry to next
      passes as texture; if TBlackSharkScene.Renderers.Count = 1 then first
      pass don't contains FBO and need create new pass by TBlackSharkScene.AddRenderer;
      for easy copy screenshort use TBlackSharkScene.Screenshort(...) }
    procedure CopyFromGPU(const Rect: TRectBSi);
    { Load texture to GPU memory with current set properties: filtering and wrapping }
    procedure LoadToGPU(FreeRawData: boolean = false); virtual;
    { Uses a texture, loaded earlier to GPU; ID is number a texture in a fragment
    	shader and allows bind and use several textures; default value is 0 }
    procedure UseTexture(ID: int32); virtual; stdcall;
    function Color(UV: PTextureArea): TVec4b; stdcall;
    procedure FreeRaw;
    function RemoveArea(Area: PTextureArea): boolean;
    property ProgramID: GLuint read FProgramID;
    property TrilinearFilter: boolean read GetTrilinearFilter write SetTrilinearFilter;
    property FramesCount: int32 read GetFramesCount;
    property Frames[index: int32]: PTextureArea read GetFrame;
    property SelfArea: PTextureArea read GetTextureArea;
    property Name: string read GetName;
    { picture contain raw texture data; assigning Picture not load data to GPU,
      there for you must manually call LoadToGPU for this }
    property Picture: TBlackSharkPicture read GetPicture write SetPicture;
    { WrapOptions define behavior when texture coordinate exceed 1.0 bound;
      available values:
        - GL_CLAMP_TO_EDGE - absent wrap - default value;
        - GL_REPEAT - repeat texture;
        - GL_MIRRORED_REPEAT - mirrored image on evry natural number texture coordinate;
      }
    property WrapOptions: GLint read GetWrapOptions write SetWrapOptions;
    property MipMap: boolean read FMipMap write SetMipMap;
    property InternalFormat: GLint read GetInternalFormat;
    property TagPtr: Pointer read FTagPtr write FTagPtr;
    property References: int32 read FRefCounter;
  end;

  { TBlackSharkTextureGradient }

  TBlackSharkTextureGradient = class(TBlackSharkTexture)
  private
    FGradientType: TGradientType;
    FTransparent: GLfloat;
    FColor0: TVec4f;
    FColor1: TVec4f;
    procedure SetColor0(const Value: TVec4f);
    procedure SetColor1(const Value: TVec4f);
    procedure SetTransparent(const Value: GLfloat);
    //FSmooth: boolean;
    //FBlendResolution: int8;
  public
    constructor Create(AWidth, AHeight: int32; const AName: string;
      ATrilinearFilter: boolean = true; AInternalFormat: GLint = GL_RGBA); override;
    procedure DoGradient;
    property GradientType: TGradientType read FGradientType write FGradientType;
    property Color0: TVec4f read FColor0 write SetColor0;
    property Color1: TVec4f read FColor1 write SetColor1;
    property Transparent: GLfloat read FTransparent write SetTransparent;
    //property BlendResolution: int8 read FBlendResolution write FBlendResolution;
  end;

  { TBlackSharkTextureMap }

  TBlackSharkTextureMap = class(TBlackSharkTexture)
  private
    FreeSquare: int32;
    FBorderWidth: int8;
    DoubleBorder: int8;
    SpaceTree: TBlackSharkRTree;
    FEasyModeInsert: boolean;
    LastInserted: PTextureArea;
    function IsInserting(X, Y, W, H: int32): int32;
    procedure SetBorderWidth(const Value: int8);
  protected
    procedure SetPicture(const Value: TBlackSharkPicture); override;
  public
    constructor Create(AWidth, AHeight: int32; const AName: string;
      ATrilinearFilter: boolean = true; AInternalFormat: GLint = GL_RGBA); override;
    destructor Destroy; override;
    procedure Change; override;
    procedure ClearAreas; override;
    // in: SizePos - contain size area
    // out: SizePos - contain founded free position
    function FindArea(var SizePos: TVec2i): boolean;
    // addition texture; return UV coordinates
    //function CreateArea(const SizeArea: TVec2i): PTextureArea;
    function InsertToMap(Source: TBlackSharkRasterCanvas; const SourceRect: TRectBSi): PTextureArea;
    //function InsertToMap(const Rect: TRectBSi): PTextureArea; overload;
    property BorderWidth: int8 read FBorderWidth write SetBorderWidth;
    property EasyModeInsert: boolean read FEasyModeInsert write FEasyModeInsert;
   end;

  { TBlackSharkTexturePalette }

  {TBlackSharkTexturePalette = class(TBlackSharkTexture)
  private
    function UV(const Color: TVec4b): PTextureArea;
  public
    constructor Create(AWidth, AHeight: int32; const AName: string;
      ATrilinearFilter: boolean = true; AInternalFormat: GLint = GL_RGBA); override;
    procedure ClearAreas; override;
  end; }

  PMaterial = ^TMaterial;
  TMaterial = record
    Ambient: TVec4f;    // Perception background illumination /
    Diffuse: TVec4f;    // Perception disperse illumination
    Specular: TVec4f;   // Perception reflected illumination
    Emission: TVec4f;   // Self lighting
    Shininess: BSFloat; // Factor shine
  end;

  { BSTextureManager

    To outside gives only PTextureArea or IBlackSharkTexture with auto
    reference counting;

   }

  BSTextureManager = class
  private
    type
      TMapConstructor = function(TrilinearFilter: boolean): TBlackSharkTextureMap of object;
  private
    class var AllTextures: THashTable<Pointer, Pointer>;
    { All created named areas PTextureArea }
    class var FTexturesName: THashTable<string, PTextureArea>;
    { Autogenerating map gradient colors with trilinear filtering }
    class var FGradientMaps: TListVec<Pointer>;
    { Autogenerating map for simple single colors }
    //class var FColorMaps: TListVec<Pointer>;
    class var FSingleTextures: TListVec<Pointer>;

    //class var FCurrentPalette: TBlackSharkTexturePalette;

    { Autogenerating map pictures without filtering }
    { TODO: Autogenerating map for smooth pictures }
    class var FPictureMaps: TListVec<Pointer>;

    class var FUseTextureMaps: boolean;
    class var IDTextureMap: int32;
    class var FHeightTextuteMap: int32;
    class var FWidthTextuteMap: int32;
    //class var FColors: THashTable<uint32, PTextureArea>;

    class var LastTexture: IBlackSharkTexture;

    class function CreatePictureMap(ATrilinearFilter: boolean): TBlackSharkTextureMap;
    class function CreateGragientMap(ATrilinearFilter: boolean): TBlackSharkTextureMap;
    //class function CreateColorMap: TBlackSharkTexturePalette;
    class procedure AddSingleTexture(const Texture: TBlackSharkTexture; LoadToGPU: boolean = true);

    class function GetTextureByName(const Name: string): IBlackSharkTexture; static;
    class procedure OnCreateTexture(const Texture: TBlackSharkTexture);
    class procedure DelTextureByName(const AName: string);

    class procedure OnDelTexture(const Texture: TBlackSharkTexture);
    class procedure OnFreeSingleTexture(const Texture: TBlackSharkTexture);
    //class procedure OnFreeColorMap(const Texture: TBlackSharkTexture);
    class procedure OnFreePicture(const Texture: TBlackSharkTexture);
    class procedure OnFreeGradientMap(const Texture: TBlackSharkTexture);


    class function InsertToMap(const Name: string; Maps: TListVec<Pointer>;
      var Source: TBlackSharkTexture; MapConstructor: TMapConstructor;
      { used map with Trilinear Filter }
      ATrilinearFilter: boolean = true
      ): PTextureArea;

    class function DoCreateTexture(const PrefixName: string;
      ClassTexture: TBlackSharkTextureClass; DefaultWidth: int32 = 1024;
      DefaultHeight: int32 = 1024): TBlackSharkTexture;

    //class procedure RemoveColor(AColor: uint32; AFreeMem: boolean = false);
    class function GetCountTextures: int32; static;
    class function GetTexturesSize: int32; static;

    class constructor Create;
    class destructor Destroy;
  public

    class function CreateTexture(const PrefixName: string;
      ClassTexture: TBlackSharkTextureClass; DefaultWidth: int32 = 1024;
      DefaultHeight: int32 = 1024): IBlackSharkTexture;

    class function GenerateTexture(Color0, Color1: TVec3f;
      Gradient: TGradientType = gtHorizontal;
      Transparent: GLfloat = 1.0; { 0..1 }
      Size: int32 = 2;
      Smooth: boolean = false;
      const Name: string = 'GradientFillRect'): PTextureArea; overload;

    class function GenerateTexture(const Color0, Color1: TVec4f;
      Gradient: TGradientType = gtHorizontal;
      Size: int32 = 2;
      Smooth: boolean = false;
      const Name: string = 'GradientFillRect4f'): PTextureArea; overload;

    class function GenerateTexture(const Color: TVec4f; Width, Height: int32; Smooth: boolean = true;
      const Name: string = 'SmoothTexture'): PTextureArea; overload;


    class function GenerateTexture(Color: TVec4b; const Name: string = 'FillRect'): PTextureArea; overload;

    class function GenerateTexture(const Color: TVec4f; const Name: string = 'FillRect'): PTextureArea; overload;

    // return UV coordinate color into texture
    //class function UV(const Color: TVec4f; Smooth: boolean = false): PTextureArea; overload;
    //class function UV(const Color: TVec4b; Smooth: boolean = false): PTextureArea; overload;
    class function Color(UV: PTextureArea): TVec4b;

    class function LoadTexture(const FileName: string; InsertTexToMap: boolean = false;
      ATrilinearFilter: boolean = true;
      LoadToGPU: boolean = true): PTextureArea; overload;

    class function LoadTexture(const Stream: TStream; const Name: string;
      InsertTexToMap: boolean = false; ATrilinearFilter: boolean = true;
        LoadToGPU: boolean = true): PTextureArea; overload;

    class function LoadTexture(const Stream: TStream; const Name: string;
      ClassText: TBlackSharkTextureClass; InsertTexToMap: boolean;
      ATrilinearFilter: boolean; LoadToGPU: boolean): PTextureArea; overload;

    class function LoadTexture(const Picture: TBlackSharkPicture; const Name: string;
      InsertTexToMap: boolean = false; ATrilinearFilter: boolean = true;
      LoadToGPU: boolean = true): PTextureArea; overload;

    { TODO : Load Normal Map }
    class function LoadTexture(const {%H-}FileName, {%H-}FileNameNormals: string;
      {%H-}ATrilinearFilter: boolean = true): PTextureArea; overload;

    class function FindTexture(const AName: string): PTextureArea;

    class procedure Restore;

    class procedure UseTexture(const ATexture: IBlackSharkTexture; ID: int32 = 0);
    class procedure AreaFree(var Area: PTextureArea);
    //procedure AreaExchange(const AreaNew: PTextureArea; var AreaOld: PTextureArea);

    class property UseTextureMaps: boolean read FUseTextureMaps write FUseTextureMaps;
    class property TextureByName[const Name: string]: IBlackSharkTexture read GetTextureByName;
    class property WidthTextuteMap: int32 read FWidthTextuteMap write FWidthTextuteMap;
    class property HeightTextuteMap: int32 read FHeightTextuteMap write FHeightTextuteMap;
    class property CountTextures: int32 read GetCountTextures;
    class property TexturesSize: int32 read GetTexturesSize;
  end;

implementation

uses
    bs.log
  , bs.utils
  , bs.math
  , bs.strings
  ;

procedure OverturnColor(data: pByte; Width, Height: int32; Boundary, Step: int8);
var
  i, j, pos_r, pos_w: int32;
  r, ord: byte;
begin
  if (Width*Step) mod Boundary > 0 then
    ord := Boundary - (Width*Step) mod Boundary  else
    ord := 0;
  pos_r := 0;
  pos_w := 0;
  for i := 0 to Height - 1 do
  begin
    for j := 0 to Width - 1 do
    begin
      r := data[pos_r];
      data[pos_w] := data[pos_r+2];
      data[pos_w+1] := data[pos_r+1];
      data[pos_w+2] := r;
      if Step = 4 then
        data[pos_w+3] := data[pos_r+3];

      inc(pos_w, Step);
      inc(pos_r, Step);
    end;
    inc(pos_r, ord);
  end;
end;

procedure FillRectColor(Data: PArrayVec4b; Rect: TRectBSi; const Color: TVec4b);
var
  i, j: int32;
begin
  for j := Rect.Top to Rect.Top + Rect.Height - 1 do
    for i := Rect.Left to Rect.Left + Rect.Width - 1 do
      Data[j*Rect.Width + i] := Color;
end;

procedure FillBuf(Buf: PArrayVec4b; Count: int32; const Color: TVec4b); overload;
var
  i: int32;
begin
  for i := 0 to Count - 1 do
    Buf^[i] := Color;
end;

procedure FillBuf(Buf: pByte; Size: int32; const Color: TVec4b);  overload;
begin
  FillBuf(PArrayVec4b(Buf), Size div SizeOf(TVec4b), Color);
end;

procedure SmoothBuf(Buf: PArrayVec4b; Width: int32; const SmothRect: TRectBSi);
const
  SIZE_BORDER = 2;
var
  alpha: array[0..SIZE_BORDER - 1] of byte;
  i, j, p: int32;
begin
  for i := 0 to SIZE_BORDER - 1 do
    alpha[i] := 200 - round(255*(i/SIZE_BORDER));
  for i := SmothRect.Top to SmothRect.Top + SmothRect.Height - 1 do
  begin
    p := i*Width;
    for j := 0 to SIZE_BORDER - 1 do
    begin
      Buf^[p + SmothRect.Left].a := alpha[SIZE_BORDER - j - 1];
      Buf^[p + SmothRect.Left + SmothRect.Width - j].a := alpha[SIZE_BORDER - j - 1];
    end;
  end;
end;

{ TBlackSharkTexturePalette }


(*
procedure TBlackSharkTexturePalette.ClearAreas;
var
  i: int32;
begin
  if Assigned(ListFrames) then
    for i := 0 to ListFrames.Count - 1 do
      BSTextureManager.RemoveColor(ListFrames.Items[i].Name, false);
  { further parent class free areas }
  inherited ClearAreas;
end;

constructor TBlackSharkTexturePalette.Create(AWidth, AHeight: int32;
  const AName: string; ATrilinearFilter: boolean; AInternalFormat: GLint);
begin
  inherited;
  FTrilinearFilter := false;
end;

function TBlackSharkTexturePalette.UV(const Color: TVec4b): PTextureArea;
var
  pos: int32;
  pos_f: int64;
  i, j: int8;
begin
  pos_f := FPicture.Canvas.Raw.Position;
  if pos_f + int64(SizeOf(TVec4b)) * 3 * int64(FPicture.Width) > FPicture.Canvas.Raw.Size then
    exit(nil);
  new(Result);
  pos := pos_f div SizeOf(TVec4b);
  if pos > FPicture.Width - 3 then
  begin
    inc(pos_f, int64(FPicture.Width) * 3 + (int64(FPicture.Width) - 3) * int64(SizeOf(TVec4b)));
    FPicture.Canvas.Raw.Position := pos_f;
    inc(pos, FPicture.Width - 3);
  end;

  for i := 0 to 2 do
  begin
    FPicture.Canvas.Raw.Position := pos_f + int64(i * int64(SizeOf(TVec4b))) * int64(FPicture.Width);
    for j := 0 to 2 do
    begin
      FPicture.Canvas.Raw.WriteBuffer(Color, SizeOf(TVec4b));
      //inc(pos_f);
    end;
  end;
  Result^.Rect := RectBS(pos mod FPicture.Width + 1, pos div FPicture.Width + 1, 1, 1);
  inc(pos_f, 3 * SizeOf(TVec4b));
  FPicture.Canvas.Raw.Position := pos_f;

  Result^.UV := RectToUV(FPicture.Width, FPicture.Height, Result^.Rect);
  Result^.Texture := Self;
  if ListFrames = nil then
    ListFrames := TListVec<PTextureArea>.Create;
  ListFrames.Add(Result);
  LoadToGPU;
end; *)

{ TBlackSharkTexture }

constructor TBlackSharkTexture.Create(AWidth, AHeight: int32; const AName: string; ATrilinearFilter: boolean; AInternalFormat: GLint);
begin
  TextureArea.Name := AName;
  TextureArea.Texture := Self;
  // return counter to zero
  FRefCounter := 0;
  FInternalFormat := GL_RGBA;
  FName := AName;
  FTrilinearFilter := ATrilinearFilter;
  FWrapOptions := GL_CLAMP_TO_EDGE;
  if (AWidth > 0) and (AHeight > 0) then
  begin
    FPicture := TBlackSharkBitMap.Create;
    FPicture.SetSize(AWidth, AHeight);
    CalcArea;
  end;
  BSTextureManager.OnCreateTexture(Self);
end;

destructor TBlackSharkTexture.Destroy;
begin
  Pointer(TextureArea.Texture) := nil;
  if Assigned(OnFreeTexture) then
    OnFreeTexture(Self);

  ClearAreas;

  if FProgramID > 0 then
    glDeleteTextures(1, @FProgramID);

  FreeRaw;
  BSTextureManager.OnDelTexture(Self);
  inherited;
end;

procedure TBlackSharkTexture.BeginUpdate;
begin
  inc(UpdateCount);
end;

procedure TBlackSharkTexture.EndUpdate(ReloadIfNeed: boolean);
begin
  dec(UpdateCount);
  if UpdateCount < 0 then
    UpdateCount := 0;
  if ReloadIfNeed and ((FPicture <> nil) and (UpdateCount = 0) and ((FProgramID = 0) or (FPicture.Canvas.Changed))) then
    LoadToGPU;
end;

procedure TBlackSharkTexture.ClearAreas;
var
  i: int32;
  ta: TListVec<PTextureArea>.TArrayOfT;
begin
  if ListFrames = nil then
    exit;
  if FProgramID > 0 then
  begin
    glDeleteTextures(1, @FProgramID);
    FProgramID := 0;
  end;
  { because count references reduce when delete area ClearAreas can invoke
    recurrently }
  ta := ListFrames.Copy;
  FreeAndNil(ListFrames);
  for i := length(ta) - 1 downto 0 do
    dispose(ta[i]);
end;

procedure TBlackSharkTexture.FreeRaw;
begin
  FreeAndNil(FPicture);
end;

function TBlackSharkTexture.RemoveArea(Area: PTextureArea): boolean;
var
  c: TVec4b;
begin
  if Area = SelfArea then
    exit(false);
  { on a some event keeping interface }
  Area.Texture := nil;
  BeginUpdate;
  try
    if (FPicture <> nil) then
    begin
      c := Vec4(0, 0, 0, 0);
      FPicture.Canvas.Fill(c, Area^.TextureRect.Rect);
    end;
    Result := ListFrames.Remove(Area);
    dispose(Area);
  finally
    EndUpdate(true);
  end;
end;

procedure TBlackSharkTexture.LoadToGPU(FreeRawData: boolean = false);
begin
  if FPicture = nil then
    exit;
  if TextureArea.Rect.Height = 0 then
    CalcArea;
  FPicture.Canvas.Changed := false;
  if FProgramID > 0 then
    glDeleteTextures(1, @FProgramID);
	// request in OpenGL free rexture index
	glGenTextures(1, @FProgramID);
  if (FProgramID = 0) then
    raise Exception.Create('Can not load texture to GPU!');
    //exit;
  // "Bind" the newly created texture : all future texture functions will modify this texture
	glBindTexture(GL_TEXTURE_2D, FProgramID);
	// load data about color to current texture
  {if FPicture.FlipColor then
    begin
    glTexImage2D(GL_TEXTURE_2D, 0, GL_BGRA, FPicture.Width, FPicture.Height, 0, GL_BGRA,
			GL_UNSIGNED_BYTE, FPicture.Canvas.Raw.Memory);
  	end else  }
	glTexImage2D(GL_TEXTURE_2D, 0, PIXEL_FORMAT_TO_GL[FPicture.PixelFormat], FPicture.Width,
    FPicture.Height, 0, PIXEL_FORMAT_TO_GL[FPicture.PixelFormat],	GL_UNSIGNED_BYTE, FPicture.Canvas.Raw.Memory);
 	// set pаrametr wrap texture - absent wrap if WrapOptions = GL_CLAMP_TO_EDGE
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, FWrapOptions); // x // GL_CLAMP_TO_EDGE
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, FWrapOptions); // y   // GL_CLAMP_TO_EDGE
  if TrilinearFilter then
  begin
    // ... nice trilinear filtering.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if FMipMap then
    	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    else
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  end else
  begin
    // Poor filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  end;

  if FMipMap then
  	glGenerateMipmap(GL_TEXTURE_2D);

  if FreeRawData then
    FreeRaw;
  {$ifdef DEBUG_BS}
    CheckErrorGL('TBlackSharkTexture.LoadToGPU', TTypeCheckError.tcNone, -1);
  {$endif}
end;

function TBlackSharkTexture.Open(const Pict: TBlackSharkPicture): boolean;
begin
  //if FPicture <> nil then
  //  FreeAndNil(FPicture);
  FPicture := Pict;
  Result := FPicture <> nil;
end;

{$ifdef FPC}
function TBlackSharkTexture.QueryInterface(
  {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID : TGuid; out Obj):
    longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
{$else}
function TBlackSharkTexture.QueryInterface(const IID: TGuid; out Obj) : HResult;
{$endif}
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TBlackSharkTexture.Open(const FileName: string): boolean;
var
  f: TFileStream;
begin
  Result := false;
  if FileExists(FileName) then
    begin
    try
      f := TFileStream.Create(FileName, fmOpenRead);
    except
      exit;
    end;
    try
      Result := Open(f);
    finally
      f.free;
    end;
    end else
  if (FileName <> '') then
    BSWriteMsg('BSTextureManager.LoadTexture', 'File not found: ' + FileName);
end;

function TBlackSharkTexture.Open(const Srteam: TStream): boolean;
begin
  Result := Open(TPicCodecManager.Open(Srteam, StringToAnsi(ExtractFileExt(Name))));
end;

function TBlackSharkTexture.CopyRect(Source: TBlackSharkTexture;
  const SourceRect: TRectBSi; FillBorder: boolean = true): PTextureArea;
begin
  Result := CopyRect(Source.Picture, vec2(0, 0), SourceRect, FillBorder);
end;

procedure TBlackSharkTexture.CopyFromGPU(const Rect: TRectBSi);
begin
  if FPicture = nil then
    FPicture := TBlackSharkBitMap.Create;
  FPicture.SetSize(Rect.Width, Rect.Height);
  glReadPixels(Rect.X, Rect.Y, Rect.Width, Rect.Height, GL_RGBA, GL_UNSIGNED_BYTE, FPicture.Canvas.Raw.Memory);
  if (FProgramID > 0) and (UpdateCount = 0) then
    LoadToGPU;
end;

function TBlackSharkTexture.CopyRect(Source: TBlackSharkRasterCanvas;
  const Pos: TVec2i; const SourceRect: TRectBSi; FillBorder: boolean): PTextureArea;
var
  i, h: int32;
  dst, src: pByte;
begin
  BeginUpdate;
  Result := GenFrameUV(Pos.x, Pos.y, SourceRect.Width, SourceRect.Height);
  // copy texture
  FPicture.Canvas.CopyRect(Source, Pos, SourceRect);
  if FillBorder then
  begin
    h := FPicture.Canvas.Height-1;
    // for coorect blend copy part texture as border to gap
    // border right and left
    if (Pos.x > 0) then
    begin
      for i := 0 to SourceRect.Height - 1 do
      begin
        src := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y-i);
        dst := FPicture.Canvas.PtrOnColor(Pos.x - 1, h-Pos.y-i);
        move(src^, dst^, FPicture.Canvas.SizeColor);
        src := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width - 1, h-Pos.y-i);
        dst := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width, h-Pos.y-i);
        move(src^, dst^, FPicture.Canvas.SizeColor);
      end;
    end;
    // border top and bottom
    if (Pos.y > 0) then
    begin
      src := FPicture.Canvas.PtrOnColor(Pos.x - 1, h-Pos.y);
      dst := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y+1);
      move(src^, dst^, SourceRect.Width * FPicture.Canvas.SizeColor);
      src := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y-SourceRect.Height+1);
      dst := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y-SourceRect.Height);
      move(src^, dst^, SourceRect.Width * FPicture.Canvas.SizeColor);
      // copy to angle gap
      src := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y);
      dst := FPicture.Canvas.PtrOnColor(Pos.x - 1, h-Pos.y+1);
      move(src^, dst^, FPicture.Canvas.SizeColor);
      src := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width-1, h-Pos.y);
      dst := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width, h-Pos.y+1);
      move(src^, dst^, FPicture.Canvas.SizeColor);
      src := FPicture.Canvas.PtrOnColor(Pos.x, h-Pos.y-SourceRect.Height+1);
      dst := FPicture.Canvas.PtrOnColor(Pos.x - 1, h-Pos.y-SourceRect.Height);
      move(src^, dst^, FPicture.Canvas.SizeColor);
      src := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width - 1, h-Pos.y-SourceRect.Height+1);
      dst := FPicture.Canvas.PtrOnColor(Pos.x + SourceRect.Width, h-Pos.y-SourceRect.Height);
      move(src^, dst^, FPicture.Canvas.SizeColor);
    end;
  end;
  FPicture.Canvas.Changed := true;
  //FPicture.Save('d:\map.bmp');
  EndUpdate(true);
end;

function TBlackSharkTexture.CopyRect(Source: TBlackSharkPicture;
  const Pos: TVec2i; const SourceRect: TRectBSi; FillBorder: boolean = true): PTextureArea;
begin
  Result := CopyRect(Source.Canvas, pos, SourceRect, FillBorder);
end;

procedure TBlackSharkTexture.SetPicture(const Value: TBlackSharkPicture);
begin
  ClearAreas;
  if FPicture <> nil then
    FPicture.Free;
  FPicture := Value;
  if (FProgramID > 0) and (UpdateCount = 0) then
    LoadToGPU;
end;

procedure TBlackSharkTexture.SetTrilinearFilter(const Value: boolean);
begin
  if FTrilinearFilter = Value then
    exit;
  FTrilinearFilter := Value;
  if (FProgramID > 0) and (UpdateCount = 0) then
    LoadToGPU;
end;

procedure TBlackSharkTexture.CalcArea;
begin
  TextureArea.Rect := RectBS(0, 0, FPicture.Width, FPicture.Height);
  TextureArea.UV := RectBS(0.0, 0.0, 1.0, 1.0);
end;

procedure TBlackSharkTexture.SetWrapOptions(AValue: GLint);
begin
  if FWrapOptions = AValue then Exit;
  FWrapOptions := AValue;
  if (FProgramID <> 0) and (UpdateCount = 0) then
  begin
    glBindTexture(GL_TEXTURE_2D, FProgramID);
   	// set pаrametr wrap texture - absent wrap if WrapOptions = GL_CLAMP_TO_EDGE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, FWrapOptions); // x   // GL_CLAMP_TO_EDGE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, FWrapOptions); // y   // GL_CLAMP_TO_EDGE
    //LoadToGPU;
  end;
end;

procedure TBlackSharkTexture.Change;
begin
  if (FPicture <> nil) and (FPicture.Canvas <> nil) then
    FPicture.Canvas.Changed := true;
end;

procedure TBlackSharkTexture.Reset;
begin
  FProgramID := 0;
  //glDeleteTextures(1, @FProgramID);
end;

function TBlackSharkTexture.GetFrame(index: int32): PTextureArea;
begin
  if Assigned(ListFrames) and (index < ListFrames.Count) then
    Result := ListFrames.Items[index]
  else
    Result := @TextureArea;
end;

function TBlackSharkTexture.GetFramesCount: int32;
begin
  if Assigned(ListFrames) and (ListFrames.Count > 0) then
    Result := ListFrames.Count
  else
    Result := 1;
end;

function TBlackSharkTexture.GetInternalFormat: GLint;
begin
  Result := FInternalFormat;
end;

function TBlackSharkTexture.GetName: string;
begin
  Result := FName;
end;

function TBlackSharkTexture.GetPicture: TBlackSharkPicture;
begin
  Result := FPicture;
end;

function TBlackSharkTexture.GetTextureArea: PTextureArea;
begin
  Result := @TextureArea;
end;

function TBlackSharkTexture.GetTrilinearFilter: boolean;
begin
  Result := FTrilinearFilter;
end;

function TBlackSharkTexture.GetWrapOptions: GLint;
begin
  Result := FWrapOptions;
end;

procedure TBlackSharkTexture.SetMipMap(AValue: boolean);
begin
  if FMipMap = AValue then Exit;
  FMipMap := AValue;
  if FMipMap and (FProgramID <> 0) and (UpdateCount = 0) then
  begin
    glBindTexture(GL_TEXTURE_2D, FProgramID);
    glGenerateMipmap(GL_TEXTURE_2D);
  end;
end;

procedure TBlackSharkTexture.UseTexture(ID: int32);
begin
  // Bind the texture
  glActiveTexture ( GL_TEXTURE0 + ID );
  glBindTexture ( GL_TEXTURE_2D, FProgramID );
end;

function TBlackSharkTexture._AddRef: int32;
begin
  {$ifdef FPC}
  Result := InterLockedIncrement(FRefCounter);
  {$else}
  Result := AtomicIncrement(FRefCounter);
  {$endif}
end;

function TBlackSharkTexture._Release: int32;
begin
  {$ifdef FPC}
  Result := InterLockedDecrement(FRefCounter);
  {$else}
  Result := AtomicDecrement(FRefCounter);
  {$endif}
  if FRefCounter <= 0 then
    Destroy;
end;

function TBlackSharkTexture.Color(UV: PTextureArea): TVec4b;
begin
  if Assigned(FPicture.Canvas.Raw) then
    Result := PArrayVec4b(FPicture.Canvas.Raw.Memory)[round(UV^.Rect.Top * FPicture.Width + uv^.Rect.Left)]
  else
    Result := vec4(byte(0), byte(0), byte(0), byte(255));
end;

function TBlackSharkTexture.GenFrameUV(const Rect: TRectBSi): PTextureArea;
begin
  Result := GenFrameUV(Rect.x, Rect.y, Rect.Width, Rect.Height);
end;

function TBlackSharkTexture.GenFrameUV(const X, Y, AreaWidth, AreaHeight: int32): PTextureArea;
begin
  if ListFrames = nil then
    ListFrames := TListVec<PTextureArea>.Create;
  new(Result);
  Result^.Rect := RectBS(X, Y, AreaWidth, AreaHeight);
  Result^.UV := RectBS(X/FPicture.Width, Y/FPicture.Height, AreaWidth/FPicture.Width, AreaHeight/FPicture.Height);
  Result^.Texture := Self;
  ListFrames.Add(Result);
end;

{ BSTextureManager }

class function BSTextureManager.GetCountTextures: int32;
begin
  Result := AllTextures.Count;
end;

class function BSTextureManager.GetTextureByName(const Name: string): IBlackSharkTexture;
var
  tex: PTextureArea;
begin
  if FTexturesName.Find(Name, tex) then
    Result := tex^.Texture
  else
    Result := nil;
end;

class function BSTextureManager.GetTexturesSize: int32;
var
  t: TBlackSharkTexture;
  bucket: THashTable<Pointer, Pointer>.TBucket;
begin
  Result := 0;
  if AllTextures.GetFirst(bucket) then
  repeat
    t := bucket.Key;
    if Assigned(t.Picture) then
      inc(Result, t.Picture.Canvas.Raw.CarrentCapacity);
  until not AllTextures.GetNext(bucket);
end;

class function BSTextureManager.InsertToMap(const Name: string;
  Maps: TListVec<Pointer>; var Source: TBlackSharkTexture;
  MapConstructor: TMapConstructor; ATrilinearFilter: boolean = true): PTextureArea;
var
  i: int32;
  pos: TVec2i;
  tex: TBlackSharkTextureMap;
begin

  if (Source.InternalFormat <> GL_RGBA) then
    raise Exception.Create('Format raw data must be GL_RGBA!');

  if (Source.Picture.Canvas.Square > HeightTextuteMap * WidthTextuteMap) then
    raise Exception.Create('Adding square more then square of texture map! Try to use a smaler size or texture, or reduce properties ' +
      ' BSTextureManager.HeightTextuteMap and BSTextureManager.WidthTextuteMap.');

  if not FUseTextureMaps or (Source.Picture is TBlackSharkDDS) then
  begin
    Result := Source.SelfArea;
    { when add to texture manager do not count references }
    AddSingleTexture(Source);
  end else
  begin

    tex := nil;
    for i := 0 to Maps.Count - 1 do
    begin
      pos := vec2(Source.Picture.Width, Source.Picture.Height);
      tex := TBlackSharkTextureMap(Maps.Items[i]);
      if (tex.FreeSquare >= Source.Picture.Canvas.Square) and
        (ATrilinearFilter = tex.TrilinearFilter) and tex.FindArea(pos) then
          break;
    end;

    if tex = nil then
    begin
      tex := MapConstructor(ATrilinearFilter);
      pos := vec2(tex.BorderWidth, tex.BorderWidth);
    end;

    Result := tex.InsertToMap(Source.Picture.Canvas, RectBS(0, 0, Source.Picture.Width, Source.Picture.Height));
    Result^.Name := Name;
    Source.Free;
    FTexturesName.Items[Result^.Name] := Result;
  end;
end;

class procedure BSTextureManager.DelTextureByName(const AName: string);
begin
  FTexturesName.Delete(AName);
end;

class procedure BSTextureManager.OnFreeSingleTexture(const Texture: TBlackSharkTexture);
begin
  FSingleTextures.Remove(Texture, otFromEnd);
  FTexturesName.Delete(Texture.Name);
end;

class procedure BSTextureManager.OnFreeGradientMap(const Texture: TBlackSharkTexture);
begin
  FGradientMaps.Remove(Texture, otFromEnd);
  //FSingleTextures.Remove(Texture, otFromEnd);
end;

class procedure BSTextureManager.OnCreateTexture(const Texture: TBlackSharkTexture);
begin
  AllTextures.Items[Texture] := Texture;
end;

class procedure BSTextureManager.OnDelTexture(const Texture: TBlackSharkTexture);
begin
  AllTextures.Delete(Texture);
  DelTextureByName(Texture.Name);
end;

{class procedure BSTextureManager.OnFreeColorMap(const Texture: TBlackSharkTexture);
begin
  FColorMaps.Remove(Texture, otFromEnd);
end;}

class procedure BSTextureManager.OnFreePicture(const Texture: TBlackSharkTexture);
begin
  FPictureMaps.Remove(Texture, otFromEnd);
end;

class procedure BSTextureManager.AddSingleTexture(const Texture: TBlackSharkTexture; LoadToGPU: boolean);
begin
  if LoadToGPU then
    Texture.LoadToGPU;
  Texture.OnFreeTexture := OnFreeSingleTexture;
  FTexturesName.Items[Texture.Name] := @Texture.TextureArea;
  FSingleTextures.Add(Pointer(Texture));
end;

class function BSTextureManager.GenerateTexture(Color0, Color1: TVec3f;
  Gradient: TGradientType; Transparent: GLfloat; Size: int32; Smooth: boolean;
  const Name: string): PTextureArea;
var
  n: string;
  text: TBlackSharkTextureGradient;
begin

  if Smooth then
    n := name + 'Sm' + BufToHexS(@Color0, SizeOf(TVec3f)) + BufToHexS(@Color1, SizeOf(TVec3f)) + inttostr(int8(Gradient))
  else
    n := name + BufToHexS(@Color0, SizeOf(TVec3f)) + BufToHexS(@Color1, SizeOf(TVec3f)) + inttostr(int8(Gradient));

  if FTexturesName.Find(n, Result) then
    exit;

  text := TBlackSharkTextureGradient.Create(Size, Size, n);
  text.Color0 := Color0;
  text.Color1 := Color1;
  text.Transparent := Transparent;
  text.GradientType := Gradient;
  text.DoGradient;
  Result := InsertToMap(n, FGradientMaps, TBlackSharkTexture(text), CreateGragientMap);
  if Smooth then
    SmoothBuf(Result^.Texture.Picture.Canvas.Raw.Memory, Result^.Texture.Picture.Width, Result^.Rect);
end;

class function BSTextureManager.GenerateTexture(const Color: TVec4f; Width, Height: int32; Smooth: boolean; const Name: string): PTextureArea;
var
  n: string;
  text: TBlackSharkTextureGradient;
begin

  if Smooth then
  begin
    if (Width < 4) or (Height < 4) then
      raise Exception.Create('For smooth color Height or Width textute can not be smaler 4!');
    n := name + 'Sm' + BufToHexS(@Color, SizeOf(TVec4f));
  end else
    n := name + BufToHexS(@Color, SizeOf(TVec4f));

  if FTexturesName.Find(n, Result) then
    exit;

  text := TBlackSharkTextureGradient.Create(Width, Height, n);
  text.Color0 := Color;
  text.GradientType := TGradientType.gtNone;
  text.DoGradient;
  Result := InsertToMap(n, FGradientMaps, TBlackSharkTexture(text), CreateGragientMap);
  if Smooth then
    SmoothBuf(Result^.Texture.Picture.Canvas.Raw.Memory, Result^.Texture.Picture.Width, Result^.Rect);
end;

class function BSTextureManager.GenerateTexture(const Color: TVec4f; const Name: string): PTextureArea;
begin
  Result := GenerateTexture(Vec4(byte(Round(Color.x*255)), Round(Color.y*255), Round(Color.z*255), Round(Color.w*255)), Name);
end;

class function BSTextureManager.GenerateTexture(const Color0, Color1: TVec4f;
  Gradient: TGradientType; Size: int32; Smooth: boolean;
  const Name: string): PTextureArea;
var
  n: string;
  text: TBlackSharkTextureGradient;
begin

  if Smooth then
    n := name + 'Sm' + BufToHexS(@Color0, SizeOf(TVec4f)) + BufToHexS(@Color1, SizeOf(TVec4f)) + inttostr(int8(Gradient))
  else
    n := name + BufToHexS(@Color0, SizeOf(TVec4f)) + BufToHexS(@Color1, SizeOf(TVec4f)) + inttostr(int8(Gradient));

  if FTexturesName.Find(n, Result) then
    exit;

  text := TBlackSharkTextureGradient.Create(Size, Size, '');
  text.Color0 := Color0;
  text.Color1 := Color1;
  text.GradientType := Gradient;
  text.DoGradient;
  //text.Picture.Save('d:\grad.bmp');
  Result := InsertToMap(n, FGradientMaps, TBlackSharkTexture(text), CreateGragientMap);
  //text.Free;
  if Smooth then
    SmoothBuf(Result^.Texture.Picture.Canvas.Raw.Memory, Result^.Texture.Picture.Width, Result^.Rect);
end;

class procedure BSTextureManager.UseTexture(const ATexture: IBlackSharkTexture; ID: int32 = 0);
begin
  if LastTexture <> ATexture then
  begin
    LastTexture := ATexture;
    if Assigned(LastTexture) then
      LastTexture.UseTexture(ID);
  end;
end;

class procedure BSTextureManager.AreaFree(var Area: PTextureArea);
begin
  if Area = nil then
    exit;
  if (Area = Area.Texture.SelfArea) then
    Area.Texture := nil;
  Area := nil;
end;

class function BSTextureManager.Color(UV: PTextureArea): TVec4b;
begin
  Result := UV^.Texture.Color(UV);
end;

class function BSTextureManager.GenerateTexture(Color: TVec4b; const Name: string): PTextureArea;
var
  n: string;
  text: TBlackSharkTextureGradient;
begin
  n := name + BufToHexS(@Color, SizeOf(TVec3f)) + '0';
  if FTexturesName.Find(n, Result) then
    exit;
  text := TBlackSharkTextureGradient.Create(2, 2, n);
  text.Color0 := ColorByteToFloat(Color);
  text.Transparent := 1.0;
  text.GradientType := TGradientType.gtNone;
  text.DoGradient;
  Result := InsertToMap(n, FGradientMaps, TBlackSharkTexture(text), CreateGragientMap);
end;

class function BSTextureManager.LoadTexture(const FileName: string;
  InsertTexToMap: boolean; ATrilinearFilter: boolean; LoadToGPU: boolean): PTextureArea;
var
  Name: string;
  fn: string;
  f: TFileStream;
begin
  fn := GetFilePath(FileName);
  if not FileExists(fn) then
    raise Exception.Create('BSTextureManager.LoadTexture: File not found: ' + FileName);
  Name := ExtractFileName(FileName);
  if FTexturesName.Find(Name, Result) then
    exit;
  try
    f := TFileStream.Create(fn, fmOpenRead);
  except
    raise Exception.Create('BSTextureManager.LoadTexture: Can not open file: ' + FileName);
  end;
  try
    Result := LoadTexture(f, Name, InsertTexToMap, ATrilinearFilter, LoadToGPU);
  finally
    f.Free;
  end;
end;

class function BSTextureManager.LoadTexture(const Stream: TStream; const Name: string;
  ClassText: TBlackSharkTextureClass; InsertTexToMap: boolean;
  ATrilinearFilter: boolean; LoadToGPU: boolean): PTextureArea;
var
  text: TBlackSharkTexture;
begin
  if FTexturesName.Find(Name, Result) then
    exit;
  text := TBlackSharkTexture.Create(0, 0, Name, ATrilinearFilter);
  if not text.Open(Stream) then
  begin
    text.Free;
    raise Exception.Create('BSTextureManager.LoadTexture: Can not open texture: ' + Name);
  end;
  if InsertTexToMap then
  begin
    Result := InsertToMap(Name, FPictureMaps, text, CreatePictureMap);
  end else
  begin
    AddSingleTexture(text, LoadToGPU);
    Result := text.SelfArea;
  end;
end;

class function BSTextureManager.LoadTexture(const Stream: TStream;
  const Name: string; InsertTexToMap: boolean; ATrilinearFilter: boolean;
  LoadToGPU: boolean): PTextureArea;
begin
	Result := LoadTexture(Stream, Name, TBlackSharkTexture, InsertTexToMap, ATrilinearFilter, LoadToGPU);
end;

class function BSTextureManager.LoadTexture(const Picture: TBlackSharkPicture; const Name: string;
  InsertTexToMap: boolean; ATrilinearFilter: boolean; LoadToGPU: boolean): PTextureArea;
var
  text: TBlackSharkTexture;
begin
  if FTexturesName.Find(Name, Result) then
    exit;
  text := TBlackSharkTexture.Create(0, 0, Name, ATrilinearFilter);
  if not text.Open(Picture) then
  begin
    text.Free;
    raise Exception.Create('BSTextureManager.LoadTexture: Can not open texture: ' + Name);
  end;

  if InsertTexToMap then
  begin
    Result := InsertToMap(Name, FPictureMaps, text, CreatePictureMap,
      ATrilinearFilter);
    text.Picture := nil;
    text.Free;
  end else
  begin
    AddSingleTexture(Pointer(text), LoadToGPU);
    Result := @text.TextureArea;
  end;
end;

class function BSTextureManager.LoadTexture(const FileName, FileNameNormals: string; ATrilinearFilter: boolean): PTextureArea;
//var
//  height, width, height_n, width_n: int32;
begin
  // png, bmp, jpg
  exit(nil);
{  if not LoadImage(FileName, height, width, BufForTex, SizeBuf, Overturn) then
    exit(nil);

  if not LoadImage(FileNameNormals, height_n, width_n, BufForNormTex, SizeNormBuf, Overturn) then
    exit(nil);

  if (height_n <> height) or (width <> width_n) then
    raise Exception.Create('Size texture and normal map not equal!');

  // glue together


  Result := TBlackSharkTexture.Create(width, height * 2, '');
  // Create one OpenGL texture
  glGenTextures(1, @Result.FProgramID);

  // "Bind" the newly created texture : all future texture functions will modify this texture
  glBindTexture(GL_TEXTURE_2D, Result.FProgramID);
  CheckBuf(BufForTex, SizeBuf, height * width * 8);
  move(BufForNormTex^, (BufForTex + height*width*4)^, height*width*4);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height*2, 0, GL_RGBA, GL_UNSIGNED_BYTE, BufForTex);

  // Poor filtering, or ...
  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  // ... nice trilinear filtering.
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glGenerateMipmap(GL_TEXTURE_2D);     }
end;


{class procedure BSTextureManager.RemoveColor(AColor: uint32; AFreeMem: boolean);
var
  a: PTextureArea;
begin
  if AFreeMem then
  begin
    if FColors.Find(AColor, a) then
    begin
      FColors.Delete(AColor);
      Dispose(a);
    end;
  end else
    FColors.Delete(AColor);
end;    }

class procedure BSTextureManager.Restore;
var
  tex: Pointer;
  bucket: THashTable<Pointer, Pointer>.TBucket;
begin
  if AllTextures.GetFirst(bucket) then
  repeat
    tex := bucket.Key;
    TBlackSharkTexture(tex).Reset;
    TBlackSharkTexture(tex).LoadToGPU;
  until not AllTextures.GetNext(bucket);
end;

class constructor BSTextureManager.Create;
begin
  FUseTextureMaps := true;
  FHeightTextuteMap := 1024;
  FWidthTextuteMap := 1024;

  FTexturesName := THashTable<string, PTextureArea>.Create(GetHashBlackSharkS, StrCmpBool, 1024);
  //FColors := THashTable<uint32, PTextureArea>.Create(GetHashBlackSharkUInt32, UInt32CmpBool, 1024);

  FPictureMaps := TListVec<Pointer>.Create(@PtrCmp);
  //FColorMaps := TListVec<Pointer>.Create(@PtrCmp);
  FGradientMaps := TListVec<Pointer>.Create(@PtrCmp);
  FSingleTextures := TListVec<Pointer>.Create(@PtrCmp);

  AllTextures := THashTable<Pointer, Pointer>.Create(@GetHashBlackSharkPointer, PtrCmpBool);

end;

class function BSTextureManager.CreateGragientMap(ATrilinearFilter: boolean): TBlackSharkTextureMap;
begin
  Result := TBlackSharkTextureMap(DoCreateTexture('TextureMap' + IntToStr(IDTextureMap),
    TBlackSharkTextureMap, WidthTextuteMap, HeightTextuteMap));
  inc(IDTextureMap);
  Result.TrilinearFilter := ATrilinearFilter;
  Result.OnFreeTexture := OnFreeGradientMap;
  FGradientMaps.Add(Pointer(Result));
end;

{class function BSTextureManager.CreateColorMap: TBlackSharkTexturePalette;
begin
  Result := TBlackSharkTexturePalette.Create(512, 512, 'Palette' + inttostr(IDTextureMap));
  Result.TrilinearFilter := false;
  inc(IDTextureMap);
  FColorMaps.Add(Pointer(Result));
  Result.OnFreeTexture := OnFreeColorMap;
end; }

class function BSTextureManager.CreatePictureMap(ATrilinearFilter: boolean): TBlackSharkTextureMap;
begin
  Result := TBlackSharkTextureMap(DoCreateTexture('TextureMap' + IntToStr(IDTextureMap),
    TBlackSharkTextureMap, WidthTextuteMap, HeightTextuteMap));
  Result.TrilinearFilter := ATrilinearFilter;
  Result.OnFreeTexture := OnFreePicture;
  inc(IDTextureMap);
  FPictureMaps.Add(Pointer(Result));
end;

class function BSTextureManager.CreateTexture(const PrefixName: string;
  ClassTexture: TBlackSharkTextureClass; DefaultWidth: int32;
  DefaultHeight: int32): IBlackSharkTexture;
begin
  Result := DoCreateTexture(PrefixName, ClassTexture, DefaultWidth, DefaultHeight);
  AddSingleTexture(Result as TBlackSharkTexture, true);
end;

class destructor BSTextureManager.Destroy;
var
  text: TBlackSharkTexture;
  bucket: THashTable<Pointer, Pointer>.TBucket;
begin
  LastTexture := nil;

  if AllTextures.GetFirst(bucket) then
  repeat
    text := bucket.Key;
    text.ClearAreas;
  until not AllTextures.GetNext(bucket);

  Assert(AllTextures.Count = 0, 'Not all textures have been deleted!');

  AllTextures.Free;
  FTexturesName.Free;
  //FColors.Free;
  //FColorMaps.Free;
  FGradientMaps.Free;
  FPictureMaps.Free;
  FSingleTextures.Free;
end;

class function BSTextureManager.DoCreateTexture(const PrefixName: string;
  ClassTexture: TBlackSharkTextureClass; DefaultWidth,
  DefaultHeight: int32): TBlackSharkTexture;
var
  nn: string;
  id: int32;
  tex: PTextureArea;
  ctex: TBlackSharkTexture;
begin
  nn := PrefixName;
  id := 0;
  while FTexturesName.Find(nn, tex) do
  begin
    nn := IntToStr(id)+PrefixName;
    inc(id);
  end;
  ctex := ClassTexture.Create(DefaultWidth, DefaultHeight, nn);
  Result := ctex;
end;

class function BSTextureManager.FindTexture(const AName: string): PTextureArea;
begin
  Result := nil;
  FTexturesName.Find(AName, Result);
end;

{ TBlackSharkTextureMap }

function TBlackSharkTextureMap.InsertToMap(Source: TBlackSharkRasterCanvas; const SourceRect: TRectBSi): PTextureArea;
var
  res, w: int32;
  i: int32;
  h: int32;
  n: PNodeSpaceTree;
begin

  //if FProgramID > 0 then
  //  raise Exception.Create('It is not allowed to added the Texture Map after load into GPU memory!');
  if SourceRect.Width * SourceRect.Height  > FreeSquare then
  begin
    if SourceRect.Width * SourceRect.Height > FPicture.Canvas.Square then
      raise Exception.Create('Not enough a square for insert the texture!');
    exit(nil);
  end;

  if FEasyModeInsert and (LastInserted <> nil) then
  begin
    w := round(LastInserted.Rect.Position.x + FBorderWidth shl 1 + LastInserted.Rect.Width);
    h := round(LastInserted.Rect.Position.y);
  end else
  begin
    w := FBorderWidth;
    h := FBorderWidth;
  end;

  for i := h to FPicture.Height - 1 do
  begin
    while w < FPicture.Width do
    begin
      res := IsInserting(w, i, SourceRect.Width, SourceRect.Height);
      if res = 0 then
      begin
        dec(FreeSquare, (SourceRect.Width + FBorderWidth shl 1) * (SourceRect.Height + BorderWidth shl 1));
        Result := CopyRect(Source, vec2(w, i), SourceRect, FBorderWidth > 0);
        LastInserted := Result;
        SpaceTree.Add(Result, Result.TextureRect.Rect.X - FBorderWidth,
          Result.TextureRect.Rect.Y - FBorderWidth,
          Result.TextureRect.Rect.Width + FBorderWidth,
          Result.TextureRect.Rect.Height + FBorderWidth, n);
        //FPicture.Save('d:\bbbb.bmp');
        exit;
      end;
      inc(w, res);
    end;
    w := FBorderWidth;
  end;
  //Result := nil;
  //FPicture.Save('d:\aaa.bmp');
  raise Exception.Create('Not found place for insert the texture!');
end;

procedure TBlackSharkTextureMap.Change;
begin
  inherited;
  if Picture <> nil then
    FreeSquare := Picture.Canvas.Square;
end;

procedure TBlackSharkTextureMap.ClearAreas;
var
  i: Integer;
  text: PTextureArea;
begin
  if Assigned(Picture) then
    FreeSquare := Picture.Canvas.Square;
  if Assigned(SpaceTree) then
    SpaceTree.Clear;
  LastInserted := nil;
  if Assigned(ListFrames) then
    for i := 0 to ListFrames.Count - 1 do
    begin
      text := ListFrames.Items[i];
      if text.Name <> '' then
        BSTextureManager.DelTextureByName(text.Name);
    end;
  inherited ClearAreas;
end;

constructor TBlackSharkTextureMap.Create(AWidth, AHeight: int32; const AName: string; ATrilinearFilter: boolean; AInternalFormat: GLint);
begin
  inherited;
  SpaceTree := TBlackSharkRTree.Create;
  FTrilinearFilter := true;
  if Assigned(Picture) then
    FreeSquare := Picture.Canvas.Square;
  BorderWidth := 1;
  FEasyModeInsert := true;
end;

destructor TBlackSharkTextureMap.Destroy;
begin
  FreeAndNil(SpaceTree);
  inherited;
end;

function TBlackSharkTextureMap.FindArea(var SizePos: TVec2i): boolean;
var
  res, w: int32;
  i: Integer;
begin
  for i := 0 to FPicture.Height - 1 do
  begin
    w := 0;
    while w < FPicture.Width do
    begin
      res := IsInserting(w, i, SizePos.x, SizePos.y);
      if res = 0 then
      begin
        SizePos.x := w + FBorderWidth;
        SizePos.y := i + FBorderWidth;
        exit(true);
      end;
      inc(w, res);
    end;
  end;
  Result := false;
end;

function TBlackSharkTextureMap.IsInserting(X, Y, W, H: int32): int32;
var
  {i: int32;
  r, ra: TRectBSi;
  area: PTextureArea; }
  n: TListNodes;
begin
  if (X + W > FPicture.Width) then
    exit(FPicture.Width - X);
  if (ListFrames = nil) then
    exit(0);
  //r := RectBS(X, Y, W + DoubleBorder, H + DoubleBorder); // reserve four pixels for border; this alow remove blend artefacts

  n := nil;
  SpaceTree.SelectData(X, Y, W, H, n);

  {for i := 0 to ListFrames.Count - 1 do
    begin
    area := ListFrames.Items[i];
    ra := RectBS(area^.Rect.X, area^.Rect.Y, area^.Rect.Width + FBorderWidth, area^.Rect.Height + FBorderWidth);
    if RectIntersect(ra, r) then
      begin
      Result :=
        (ra.x - X) + ra.Width + FBorderWidth;
      if Result + w + FBorderWidth > FPicture.Width then
        inc(Result, FPicture.Width - Result);
      exit;
      end;

    end;}
  if Assigned(n) then
  begin
    if n.Count > 0 then
      Result := round(PTextureArea(n.Items[0].BB.TagPtr).Rect.Width) + FBorderWidth
    else
      Result := 0;
  end else
    Result := 0;
end;

procedure TBlackSharkTextureMap.SetBorderWidth(const Value: int8);
begin
  FBorderWidth := Value;
  DoubleBorder := FBorderWidth * 2;
end;

procedure TBlackSharkTextureMap.SetPicture(const Value: TBlackSharkPicture);
begin
  inherited;
  if Assigned(Picture) then
  begin
    if Picture.Canvas = nil then
      Picture.CreateCanvas;
    FreeSquare := Picture.Canvas.Square;
  end;
end;

{ TBlackSharkTextureGradient }

constructor TBlackSharkTextureGradient.Create(AWidth, AHeight: int32; const AName: string;
  ATrilinearFilter: boolean; AInternalFormat: GLint);
begin
  inherited;
  FTransparent := 1.0;
end;

procedure TBlackSharkTextureGradient.DoGradient;
var
  color_b0: TVec4b;
  ptr: PArrayVec4b;
  i, j, k, hh, hw, x, y, n: int32;
  delta: TVec4f;
  l, d, a, r: BSFloat;
begin
  ptr := PArrayVec4b(Picture.Canvas.Raw.Memory);
  case FGradientType of
    gtHorizontal: begin
      delta := (FColor1 - FColor0) / int32(Picture.Width - 1);
      for i := 0 to Picture.Width - 1 do
      begin
        color_b0 := ColorFloatToByte(FColor0+delta*i);
        for j := 0 to Picture.Height - 1 do
          ptr^[j * Picture.Width + i] := color_b0;
      end;
      end;
    gtVerical: begin
      delta := (FColor1 - FColor0) / int32(Picture.Height - 1);
      for i := 0 to Picture.Height - 1 do
        FillBuf(PArrayVec4b(@ptr^[i * Picture.Width]), Picture.Width, ColorFloatToByte(FColor0+delta*i));
      end;
    gtRadialCircle: begin
      hh := Picture.Height div 2;
      hw := Picture.Width div 2;
      if Picture.Height > Picture.Width then
        r := Picture.Height / 2 else
        r := Picture.Width / 2;
      delta := (FColor1 - FColor0) / (r+2);
      // fill all square Color1
      //FillBuf(FRaw.Memory, FHeight * FWidth * SizeOf(TVec4b), ColorFloatToByte(Vec4(FColor1, Transparent)));
      for i := -hh to hh - 1 do
      begin
        for j := -hw to hw - 1 do
        begin
          l := sqrt(i*i + j*j);
          ptr^[(i + hh) * Picture.Width + j + hw] := ColorFloatToByte(FColor0 + delta * l);
        end;
      end;
      ptr^[hh * Picture.Width + hw] := ColorFloatToByte(FColor0);
    end;
    gtRadialSquareHorizonral: begin
      hh := Picture.Height div 2;
      hw := Picture.Width div 2;
      delta := (FColor1 - FColor0) / hw;
      for i := -hw to hw - 1 do
      begin
        color_b0 := ColorFloatToByte(FColor0 + delta * abs(i));
        for j := -hh to hh - 1 do
          ptr^[(j + hh) * Picture.Width + i + hw] := color_b0;
      end;
    end;
    gtRadialSquareVertical: begin
      hh := Picture.Height div 2;
      delta := (FColor1 - FColor0) / hh;
      for i := -hh to hh - 1 do
        begin
        FillBuf(PArrayVec4b(@ptr^[(i + hh) * Picture.Width]), Picture.Width,
          ColorFloatToByte(FColor0 + delta * abs(i)));
        end;
    end;
    gtRadialSquare: begin
      hh := Picture.Height div 2;
      hw := Picture.Width div 2;
      r := sqrt(hh*hh + hw*hw);
      delta := (FColor1 - FColor0) / (r+1);
      for i := -hh to hh - 1 do
      begin
        for j := -hw to hw - 1 do
        begin
          l := sqrt(i*i + j*j);
          ptr^[(i + hh) * Picture.Width + j + hw] := ColorFloatToByte(FColor0 + delta * l);
        end;
      end;
      //ptr^[hh * FHeight + hw] := ColorFloatToByte(Vec4(FColor0, Transparent));
  end;
  gtDiagonalRight: begin
    r := sqrt(Picture.Width*Picture.Width + Picture.Height*Picture.Height);
    if Picture.Height > Picture.Width then
      delta := (FColor1 - FColor0) / (r * 2 - 1) else
      delta := (FColor1 - FColor0) / (r * 2 - 1);
    a := Picture.Width/r;
    d := Picture.Height/r;
    for i := 0 to round(r*2) - 1 do
    begin
      color_b0 := ColorFloatToByte(FColor0 + delta * i);
      hw := round(a * i);
      hh := round(d * i);
      l := sqrt(sqr(hw) + sqr(hh));
      for j := 0 to round(l) - 1 do
      begin
        y := hh - round(j*d);
        x := round(j*a);
        // fill area around point
        for n := -1 to 1 do
          for k := -1 to 1 do
            if (x + n < 0) or (x + n >= Picture.Width) or (y + k < 0) or (y + k >= Picture.Height) then
              continue else
              ptr^[(y + k)*Picture.Width + x + n] := color_b0;
      end;
    end;
  end;
  gtDiagonalLeft: begin
    r := sqrt(Picture.Width * Picture.Width + Picture.Height * Picture.Height);
    if Picture.Height > Picture.Width then
      delta := (FColor1 - FColor0) / (r * 2 - 1) else
      delta := (FColor1 - FColor0) / (r * 2 - 1);
    a := Picture.Width / r;
    d := Picture.Height / r;
    for i := 0 to round(r*2) - 1 do
    begin
      color_b0 := ColorFloatToByte(FColor0 + delta * i);
      hw := round(a * i);
      hh := round(d * i);
      l := sqrt(sqr(hw) + sqr(hh));
      for j := 0 to round(l) - 1 do
      begin
        y := hh - round(j * d);
        x := Picture.Width - round(j * a);
        // fill area around point
        for n := -1 to 1 do
          for k := -1 to 1 do
            if (x + n < 0) or (x + n >= Picture.Width) or (y + k < 0) or (y + k >= Picture.Height) then
              continue else
              ptr^[(y + k)*Picture.Width + x + n] := color_b0;
      end;
    end;
  end else
  begin
    FillBuf(PArrayVec4b(Picture.Canvas.Raw.Memory), Picture.Canvas.Square, ColorFloatToByte(FColor0));
  end;
  end;
end;

procedure TBlackSharkTextureGradient.SetColor0(const Value: TVec4f);
begin
  FColor0 := Value;
  FColor0.w := FColor0.w * FTransparent;
end;

procedure TBlackSharkTextureGradient.SetColor1(const Value: TVec4f);
begin
  FColor1 := Value;
  FColor1.w := FColor1.w * FTransparent;
end;

procedure TBlackSharkTextureGradient.SetTransparent(const Value: GLfloat);
begin
  FTransparent := Value;
  FColor0.w := FColor0.w * FTransparent;
  FColor1.w := FColor1.w * FTransparent;
end;

end.

