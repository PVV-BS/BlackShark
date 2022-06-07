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


unit bs.canvas.map;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.scene
  , bs.canvas
  , bs.instancing
  , bs.texture
  , bs.font
  , bs.strings
  ;

type
  TCanvasMap = class (TRectangle)
  private
    FParticles: TParticlesMultiUVSingleColor;
    function GetTexture: PTextureArea;
    function GetPosition(Index: int32): TVec2f;
    procedure SetPosition(Index: int32; const Value: TVec2f);
  protected
    //function CreateGraphicObject(AParent: TGraphicObject): TGraphicObject; override;
    procedure SetTexture(const Value: PTextureArea); virtual;
    procedure SetColor(const Value: TColor4f); override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Clear;
    procedure AddParticle(X, Y: BSFloat; const SrcRect: TRectBSF); overload;
    procedure AddParticle(X, Y: BSFloat; const SrcRect: TTextureRect); overload;
    procedure Build; override;
    property Position[Index: int32]: TVec2f read GetPosition write SetPosition;
    property Particles: TParticlesMultiUVSingleColor read FParticles;
    property Texture: PTextureArea read GetTexture write SetTexture;
  end;

  TCanvasMapChars = class (TCanvasMap)
  private
    ObsrvChangeFont: IBEmptyEventObserver;
    ObsrvReplaceFont: IBEmptyEventObserver;
    procedure AssignFontTexture;
    procedure OnChangeFont(const Value: BEmpty);
    procedure OnReplaceFont(const Value: BEmpty);
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    function AddChar(X, Y: BSFloat; Char: WideChar): PKeyInfo;
    { it returns a size added }
    function AddWords(X, Y: BSFloat; const Words: string): TVec2f; overload;
    function AddWords(X, Y: BSFloat; const Words: TString): TVec2f; overload;
  end;

implementation

uses
    SysUtils
  , bs.thread
  , bs.config
  ;

{ TCanvasMap }

procedure TCanvasMap.AddParticle(X, Y: BSFloat; const SrcRect: TRectBSF);
var
  text_r: TTextureRect;
begin
  text_r.UV := RectToUV(FParticles.Texture.Texture.Picture.Width, FParticles.Texture.Texture.Picture.Height, SrcRect);
  AddParticle(X, Y, text_r);
end;

procedure TCanvasMap.AddParticle(X, Y: BSFloat; const SrcRect: TTextureRect);
  begin
  FParticles.Change(FParticles.CountParticle, vec3(X, -Y, 0.0), SrcRect);
end;

procedure TCanvasMap.AfterConstruction;
begin
  inherited;
  { so, we do not use Data for draw (a method for draw replases on a method for
    draw the particles), therefor do not use VBO }
  Data.StaticObject := false;
  Size := vec2(Canvas.Renderer.WindowWidth, Canvas.Renderer.WindowHeight);
  Build;
  FParticles := TParticlesMultiUVSingleColor.Create(Canvas.Renderer, Data);
  //FParticles.UseUV := true;
end;

procedure TCanvasMap.Build;
begin
  inherited;
  Position2d := -Size*0.5;
  { Do not do sort! }
  //FParticles.Sort;
  //Position2d := Offset;
end;

procedure TCanvasMap.Clear;
begin
  //Offset := vec2(MaxSingle, MaxSingle);
  FParticles.CountParticle := 0;
end;

constructor TCanvasMap.Create(ACanvas: TBCanvas;
  AParent: TCanvasObject);
begin
  inherited;
end;

destructor TCanvasMap.Destroy;
begin
  FParticles.Texture := nil;
  FParticles.Free;
  inherited;
end;

function TCanvasMap.GetPosition(Index: int32): TVec2f;
var
  v: TVec3f;
begin
  v := FParticles.Position[Index];
    Result.x :=  BSConfig.VoxelSizeInv * v.X;
    Result.y := -BSConfig.VoxelSizeInv * v.Y;
  end;

function TCanvasMap.GetTexture: PTextureArea;
begin
  Result := FParticles.Texture;
end;

procedure TCanvasMap.SetColor(const Value: TColor4f);
begin
  inherited;
  FParticles.Color := Value;
end;

procedure TCanvasMap.SetPosition(Index: int32; const Value: TVec2f);
  begin
  FParticles.Position[Index] := vec3(BSConfig.VoxelSize * Value.X, -BSConfig.VoxelSize * Value.Y, 0.0);
end;

procedure TCanvasMap.SetTexture(const Value: PTextureArea);
begin
  FParticles.Texture := Value;
end;

{ TCanvasMapChars }

function TCanvasMapChars.AddChar(X, Y: BSFloat; Char: WideChar): PKeyInfo;
begin
  if Canvas.Font.IsVectoral then
    raise Exception.Create('Can not use a vectoral font!');
  Result := Canvas.Font.KeyByWideChar[Char];
  if Result = nil then
    exit;
  AddParticle(X + Result.Rect.Width*0.5, Y + Result.Rect.Height*0.5, Result.TextureRect);
end;

function TCanvasMapChars.AddWords(X, Y: BSFloat; const Words: string): TVec2f;
begin
  Result := AddWords(X, Y, TString(Words));
end;

function TCanvasMapChars.AddWords(X, Y: BSFloat; const Words: TString): TVec2f;
var
  i: int32;
  k: PKeyInfo;
begin
  Result.x := 0.0;
  Result.y := 0.0;
  if Canvas.Font.IsVectoral then
    raise Exception.Create('Can not use a vectoral font!');
  for i := 1 to Words.Len do
  begin
    k := Canvas.Font.KeyByWideChar[Words.CharsUnsafeW(i)];
    AddChar(X + Result.x, Y - k.Rect.Height + Canvas.Font.SizeInPixels, Words.CharsUnsafeW(i));
    if k <> nil then
    begin
      //AddParticle(X + Result.Rect.Width*0.5, Y + Result.Rect.Height*0.5, Result.TextureRect);
      Result.x := Result.x + k.Rect.Width + 1.0;
      if k.Rect.Height > Result.y then
        Result.y := k.Rect.Height;
    end;
  end;
end;

procedure TCanvasMapChars.AfterConstruction;
begin
  inherited;
  if Canvas.Font <> nil then
    ObsrvChangeFont := Canvas.Font.OnChangeEvent.CreateObserver(GUIThread, OnChangeFont);
  FParticles.Color := BS_CL_ORANGE_2;
  AssignFontTexture;
end;

procedure TCanvasMapChars.AssignFontTexture;
begin
  if Canvas.Font.IsVectoral then
    raise Exception.Create('Can not use a vectoral font!');
  // enforce generate texture
  //if FCanvas.Font.Texture = nil then
  //  FCanvas.Font.CreateTexture;
  Texture := Canvas.Font.Texture.Texture.SelfArea;
end;

constructor TCanvasMapChars.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  inherited;
  ObsrvReplaceFont := Canvas.OnReplaceFont.CreateObserver(GUIThread, OnReplaceFont);
end;

destructor TCanvasMapChars.Destroy;
begin
  ObsrvChangeFont := nil;
  ObsrvReplaceFont := nil;
  inherited;
end;

procedure TCanvasMapChars.OnChangeFont(const Value: BEmpty);
begin
  AssignFontTexture;
end;

procedure TCanvasMapChars.OnReplaceFont(const Value: BEmpty);
begin
  if Canvas.Font <> nil then
    ObsrvReplaceFont := Canvas.OnReplaceFont.CreateObserver(GUIThread, OnReplaceFont)
  else
    ObsrvReplaceFont := nil;
  AssignFontTexture;
end;

end.
