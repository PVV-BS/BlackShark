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
  , bs.collections
  , bs.events
  , bs.align
  , bs.scene
  , bs.canvas
  , bs.instancing
  , bs.texture
  , bs.font
  , bs.strings
  , bs.geometry
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

  TModelsMap<T> = class
  public

    type
      PModelHolder = ^TModelHolder;

      TListNodels = TListDual<PModelHolder>;

      TModelHolder = record
        Model: T;
        Index: Integer;
        IsVisible: Boolean;
      end;

      TModelEventNotify = procedure (AModelHolder: PModelHolder);

  private

    type
      TCanvasObjectsKDTree = TBlackSharkKDTree<PModelHolder>;

  private
    FMap: TCanvasObjectsKDTree;
    FOnShowModel: TModelEventNotify;
    FOnHideModel: TModelEventNotify;
    FViewPortSize: TVec2d;
    FViewPortPosition: TVec2d;
    FViewPortRect: TRectBSd;
    function Box(const ARect: TRectBSd): TBox3d; overload; inline;
    function Box(const APosition, ASize: TVec2f): TBox3d; overload; inline;
    procedure ReloadViewport;
    function IntersectViewport(const ABox: TBox3d): boolean; inline;
    procedure DoUpdate(const ABox: TBox3d; AHolder: PModelHolder); inline;
    function DoAdd(const AModel: T; const ABox: TBox3d): PModelHolder; inline;
    procedure OnDelete(const AHolder: PModelHolder);
  protected
    class function GetComparator: TKeyComparatorEqual<PModelHolder>; virtual;
    procedure DoShow(const AModelHolder: PModelHolder); virtual;
    procedure DoHide(const AModelHolder: PModelHolder); virtual;
    procedure DoDelete(const AModelHolder: PModelHolder); virtual; abstract;
    procedure SetViewPortPosition(const Value: TVec2d); virtual;
    procedure SetViewPortSize(const Value: TVec2d); virtual;
  public
    constructor Create; overload;
    destructor Destroy; override;

    function Add(const AModel: T; const ARect: TRectBSf): PModelHolder; overload;
    function Add(const AModel: T; const APosition, ASize: TVec2d): PModelHolder; overload;
    function Add(const AModel: T; const ARect: TRectBSd): PModelHolder; overload;
    function Add(const AModel: T; const APosition, ASize: TVec2f): PModelHolder; overload;
    procedure Update(const ARect: TRectBSf; AHolder: PModelHolder); overload;
    procedure Update(const APosition, ASize: TVec2f; AHolder: PModelHolder); overload;
    procedure Update(const ARect: TRectBSd; AHolder: PModelHolder); overload;
    procedure Update(const APosition, ASize: TVec2d; AHolder: PModelHolder); overload;
    procedure Delete(AHolder: PModelHolder);
    procedure Clear; virtual;

    property ViewPortSize: TVec2d read FViewPortSize write SetViewPortSize;
    property ViewPortPosition: TVec2d read FViewPortPosition write SetViewPortPosition;

    property OnShowModel: TModelEventNotify read FOnShowModel write FOnShowModel;
    property OnHideModel: TModelEventNotify read FOnHideModel write FOnHideModel;
  end;

  TTextStyle = class;

  TTextStyleChangeEventNotify = procedure (ATextStyle: TTextStyle) of object;

  TTextStyle = class
  private

    FOwner: TObject;
    FName: string;
    FSize: int32;
    FItalic: boolean;
    FBold: boolean;
    FModified: boolean;
    FCountUpdate: int32;
    FFontKey: uint32;
    FUnderline: boolean;
    FStrikeout: boolean;
    FOnChangeStyle: TTextStyleChangeEventNotify;
    FBoldWeightX: BSFloat;
    FBoldWeightY: BSFloat;
    FItalicWeight: BSFloat;
    FStyleKey: uint32;
    FColorLine: TColor4f;
    FColor: TColor4f;
    FWrap: boolean;

    procedure SetBold(const Value: boolean);
    procedure SetItalic(const Value: boolean);
    procedure SetName(const Value: string);
    procedure SetSize(const Value: int32);
    procedure SetStrikeout(const Value: boolean);
    procedure SetUnderline(const Value: boolean);
    procedure SetBoldWeightX(const Value: BSFloat);
    procedure SetBoldWeightY(const Value: BSFloat);
    procedure SetItalicWeight(const Value: BSFloat);
    procedure SetColor(const Value: TColor4f);
    procedure SetColorLine(const Value: TColor4f);
    procedure SetWrap(const Value: boolean);
    procedure BuildKeys;
  protected
    property Modified: boolean read FModified write FModified;
  public
    constructor Create(AOwner: TObject);
    procedure Assigne(ASource: TTextStyle);
    procedure BeginUpdate;
    procedure EndUpdate;
    property Name: string read FName write SetName;
    property Size: int32 read FSize write SetSize;
    property Wrap: boolean read FWrap write SetWrap;
    property Bold: boolean read FBold write SetBold;
    property Italic: boolean read FItalic write SetItalic;
    property Underline: boolean read FUnderline write SetUnderline;
    property Strikeout: boolean read FStrikeout write SetStrikeout;
    property BoldWeightX: BSFloat read FBoldWeightX write SetBoldWeightX;
    property BoldWeightY: BSFloat read FBoldWeightY write SetBoldWeightY;
    property ItalicWeight: BSFloat read FItalicWeight write SetItalicWeight;
    property Color: TColor4f read FColor write SetColor;
    property ColorLine: TColor4f read FColorLine write SetColorLine;

    property StyleKey: uint32 read FStyleKey;
    property FontKey: uint32 read FFontKey;

    property OnChangeStyle: TTextStyleChangeEventNotify read FOnChangeStyle write FOnChangeStyle;
  end;

  PInlineStyle = ^TInlineStyle;
  TInlineStyle = record
    Model: string;
    View: TCanvasText;
    Rect: TRectBSd;
    Align: TTextAlign;
    FontKey: uint32;
    StyleKey: uint32;
  end;

  TCanvasTextMap = class(TModelsMap<PInlineStyle>)
  private
    type
      PFontKeyCounter = ^TFontKeyCounter;
      TFontKeyCounter = record
        CountFontKeyUse: int32;
        Font: IBlackSharkFont;
        Style: TTextStyle;
      end;
      TFontsTable = THashTable<uint32, PFontKeyCounter>;
      TStylesTable = THashTable<uint32, TTextStyle>;
  private
    class function Compare(const Model1, Model2: TCanvasTextMap.PModelHolder): boolean; static;
  private
    FCanvas: TBCanvas;
    FFonts: TFontsTable;
    FFontStyles: TStylesTable;
    FStyles: TStylesTable;
    FTextStyle: TTextStyle;
    FPrototype: TCanvasText;
    FViewPort: TRectangle;
    function GetFont(var AFontKey: uint32): PFontKeyCounter;
    function GetFontStyle(var AStyleKey: uint32): TTextStyle;
    function GetTextStyle(var AStyleKey: uint32): TTextStyle;
    procedure ClearStyles;
    procedure ClearFonts;
    function DoDrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign): PInlineStyle;
    procedure DoApplyStyle(AStyle: TTextStyle; AText: TCanvasText); inline;
    function GetParent: TCanvasObject;
    procedure SetParent(const Value: TCanvasObject);
    procedure DrawViewPort(Instance: PRendererGraphicInstance);
  protected
    class function GetComparator: TKeyComparatorEqual<TCanvasTextMap.PModelHolder>; override;
    procedure OnChangeTextStyle(ATextStyle: TTextStyle); virtual;
    procedure DoShow(const AModelHolder: TCanvasTextMap.PModelHolder); override;
    procedure DoHide(const AModelHolder: TCanvasTextMap.PModelHolder); override;
    procedure DoDelete(const AModelHolder: TCanvasTextMap.PModelHolder); override;
    procedure SetViewPortPosition(const Value: TVec2d); override;
    procedure SetViewPortSize(const Value: TVec2d); override;
  public
    constructor Create(ACanvas: TBCanvas; AParent: TCanvasObject);
    destructor Destroy; override;
    function DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign = TTextAlign.taLeft): PInlineStyle;
    procedure Clear; override;
    procedure ApplyStyle(AStyle: TTextStyle; AText: TCanvasText);

    property Canvas: TBCanvas read FCanvas write FCanvas;
    property TextStyle: TTextStyle read FTextStyle;
    property Parent: TCanvasObject read GetParent write SetParent;
    property Prototype: TCanvasText read FPrototype;
    property ViewPort: TRectangle read FViewPort;
  end;

implementation

uses
    SysUtils
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.thread
  , bs.config
  , bs.scene.objects
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

{ TModelsMap<T> }

constructor TModelsMap<T>.Create;
begin
  FMap := TCanvasObjectsKDTree.Create;
  FMap.ComparatorForEquality := GetComparator();
  FMap.OnDelete := OnDelete;
  ViewPortSize := vec2(600.0, 600.0);
end;

function TModelsMap<T>.Add(const AModel: T; const ARect: TRectBSf): PModelHolder;
begin
  Result := DoAdd(AModel, Box(ARect));
end;

function TModelsMap<T>.Box(const ARect: TRectBSd): TBox3d;
begin
  Result.Min := vec3(ARect.Left, ARect.Top, 0.0);
  Result.Max := vec3(ARect.Left + ARect.Width, ARect.Top + ARect.Height, 0.0);
end;

function TModelsMap<T>.Add(const AModel: T; const APosition, ASize: TVec2f): PModelHolder;
begin
  Result := DoAdd(AModel, Box(APosition, ASize));
end;

function TModelsMap<T>.Add(const AModel: T; const APosition, ASize: TVec2d): PModelHolder;
begin
  Result := DoAdd(AModel, Box(APosition, ASize));
end;

function TModelsMap<T>.Add(const AModel: T; const ARect: TRectBSd): PModelHolder;
begin
  Result := DoAdd(AModel, Box(ARect));
end;

function TModelsMap<T>.Box(const APosition, ASize: TVec2f): TBox3d;
begin
  Result.Min := vec3(APosition.x, APosition.y - ASize.Height, 0.0);
  Result.Max := vec3(APosition.x + ASize.Width, APosition.Y, 0.0);
end;

procedure TModelsMap<T>.Clear;
begin
  FMap.Clear;
end;

destructor TModelsMap<T>.Destroy;
begin
  Clear;
  FMap.Free;
  inherited;
end;

function TModelsMap<T>.DoAdd(const AModel: T; const ABox: TBox3d): PModelHolder;
begin
  new(Result);
  Result.Model := AModel;
  Result.IsVisible := IntersectViewport(ABox);
  Result.Index := FMap.AddBB(Result, ABox);
  if Result.IsVisible then
    DoShow(Result);
end;

procedure TModelsMap<T>.DoHide(const AModelHolder: PModelHolder);
begin
  if Assigned(FOnHideModel) then
    FOnHideModel(AModelHolder);
end;

procedure TModelsMap<T>.DoShow(const AModelHolder: PModelHolder);
begin
  if Assigned(FOnShowModel) then
    FOnShowModel(AModelHolder);
end;

procedure TModelsMap<T>.DoUpdate(const ABox: TBox3d; AHolder: PModelHolder);
var
  isVisible: Boolean;
begin
  AHolder.Index := FMap.UpdatePositionBB(AHolder, ABox, AHolder.Index);
  isVisible := IntersectViewport(ABox);
  if isVisible <> AHolder.IsVisible then
  begin
    AHolder.IsVisible := isVisible;
    if isVisible then
      DoShow(AHolder)
    else
      DoHide(AHolder);
  end;
end;

class function TModelsMap<T>.GetComparator: TKeyComparatorEqual<PModelHolder>;
begin
  Result := nil;
end;

function TModelsMap<T>.IntersectViewport(const ABox: TBox3d): boolean;
begin
  Result := (
    ((FViewPortRect.X < ABox.x_max) and (FViewPortRect.X >= ABox.x_min)  or
     (ABox.x_min < FViewPortRect.X + FViewPortRect.Width ) and (ABox.x_min >= FViewPortRect.X)) and
    ((FViewPortRect.Y < ABox.y_max) and (FViewPortRect.Y >= ABox.y_min)  or
     (ABox.y_min < FViewPortRect.Y + FViewPortRect.Height) and (ABox.y_min >= FViewPortRect.Y))
  );
end;

procedure TModelsMap<T>.OnDelete(const AHolder: PModelHolder);
begin
  if AHolder.IsVisible then
    DoHide(AHolder);
  DoDelete(AHolder);
  Dispose(AHolder);
end;

procedure TModelsMap<T>.ReloadViewport;
begin

end;

procedure TModelsMap<T>.Delete(AHolder: PModelHolder);
begin
  FMap.Remove(AHolder.Index, AHolder);
end;

procedure TModelsMap<T>.SetViewPortPosition(const Value: TVec2d);
begin
  FViewPortPosition := Value;
  FViewPortRect.Position := Value;
  ReloadViewport;
end;

procedure TModelsMap<T>.SetViewPortSize(const Value: TVec2d);
begin
  FViewPortSize := Value;
  FViewPortRect.Size := Value;
  ReloadViewport;
end;

procedure TModelsMap<T>.Update(const ARect: TRectBSd; AHolder: PModelHolder);
begin
  DoUpdate(Box(ARect), AHolder);
end;

procedure TModelsMap<T>.Update(const APosition, ASize: TVec2d; AHolder: PModelHolder);
begin
  DoUpdate(Box(APosition, ASize), AHolder);
end;

procedure TModelsMap<T>.Update(const APosition, ASize: TVec2f; AHolder: PModelHolder);
begin
  DoUpdate(Box(APosition, ASize), AHolder);
end;

procedure TModelsMap<T>.Update(const ARect: TRectBSf; AHolder: PModelHolder);
begin
  DoUpdate(Box(ARect), AHolder);
end;

{ TCanvasTextMap }

procedure TCanvasTextMap.ApplyStyle(AStyle: TTextStyle; AText: TCanvasText);
var
  fontCounter: PFontKeyCounter;
  fontKey: uint32;
begin
  DoApplyStyle(AStyle, AText);
  fontKey := AStyle.FontKey;
  fontCounter := GetFont(fontKey);
  FPrototype.Font := fontCounter.Font;
end;

procedure TCanvasTextMap.Clear;
begin
  inherited;
  ClearFonts;
  ClearStyles;
end;

procedure TCanvasTextMap.ClearFonts;
var
  bucket: TFontsTable.TBucket;
  bucketStyle: TStylesTable.TBucket;
begin

  if FFonts.GetFirst(bucket) then
  repeat
    dispose(bucket.Value);
  until not FFonts.GetNext(bucket);

  FFonts.Clear;

  if FFontStyles.GetFirst(bucketStyle) then
  repeat
    bucketStyle.Value.Free;
  until not FFontStyles.GetNext(bucketStyle);

  FFontStyles.Clear;
end;

procedure TCanvasTextMap.ClearStyles;
var
  bucket: TStylesTable.TBucket;
begin

  if FStyles.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FStyles.GetNext(bucket);

  FStyles.Clear;
end;

class function TCanvasTextMap.Compare(const Model1, Model2: TCanvasTextMap.PModelHolder): boolean;
begin
  Result := Model1.Model.Model = Model2.Model.Model;
end;

constructor TCanvasTextMap.Create(ACanvas: TBCanvas; AParent: TCanvasObject);
begin
  FCanvas := ACanvas;
  FViewPort := TRectangle.Create(ACanvas, AParent);
  FViewPort.Fill := true;
  FViewPort.Data.AsStencil := true;
  FViewPort.Data.DrawInstance := DrawViewPort;
  FViewPort.Data.Opacity := 0.0;
  FViewPort.Data.Interactive := false;
  inherited Create;
  FFonts := TFontsTable.Create(GetHashBlackSharkUInt32, UInt32CmpBool);
  FFontStyles := TStylesTable.Create(GetHashBlackSharkUInt32, UInt32CmpBool);
  FStyles := TStylesTable.Create(GetHashBlackSharkUInt32, UInt32CmpBool);
  FTextStyle := TTextStyle.Create(Self);
  FTextStyle.OnChangeStyle := OnChangeTextStyle;
  FPrototype := TCanvasText.Create(FCanvas, nil);
  FPrototype.Data.Hidden := true;
end;

destructor TCanvasTextMap.Destroy;
begin
  Clear;
  FPrototype.Free;
  FFonts.Free;
  FFontStyles.Free;
  FStyles.Free;
  FTextStyle.Free;
  inherited;
end;

procedure TCanvasTextMap.DoApplyStyle(AStyle: TTextStyle; AText: TCanvasText);
begin
  AText.Strikethrough := AStyle.Strikeout;
  AText.Underline := AStyle.Underline;
  AText.Color := AStyle.Color;
  AText.Wrap := AStyle.Wrap;
  if AStyle.Strikeout or AStyle.Underline then
    AText.ColorLine := AStyle.ColorLine;
end;

procedure TCanvasTextMap.DoDelete(const AModelHolder: TCanvasTextMap.PModelHolder);
begin
  inherited;
  dispose(AModelHolder.Model);
end;

function TCanvasTextMap.DoDrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign): PInlineStyle;
var
  fontCounter: PFontKeyCounter;
  keyFontStyle: uint32;
begin
  FPrototype.SceneTextData.BeginChangeProp;
  if FTextStyle.Modified then
  begin
    FTextStyle.Modified := false;
    keyFontStyle := FTextStyle.FontKey;
    fontCounter := GetFont(keyFontStyle);
    FPrototype.Font := fontCounter.Font;
    DoApplyStyle(fontCounter.Style, FPrototype);
  end;

  FPrototype.TextAlign := AAlign;
  FPrototype.ViewportSize := ARect.Size;
  FPrototype.Text := AText;
  FPrototype.SceneTextData.EndChangeProp;

  new(Result);
  Result.Model := AText;
  Result.View := nil;
  Result.Rect.Position := ARect.Position;
  Result.Rect.Size := vec2d(ARect.Width, FPrototype.Height);
  Result.FontKey := FTextStyle.FontKey;
  Result.StyleKey := FTextStyle.StyleKey;
  Result.Align := AAlign;
  //Result := RectBS(APosition, FPrototype.Width, FPrototype.Height);
  Add(Result, RectBS(ARect.Position, FPrototype.Width, FPrototype.Height));
end;

procedure TCanvasTextMap.DoHide(const AModelHolder: TCanvasTextMap.PModelHolder);
var
  fontKeyCounter: PFontKeyCounter;
begin
  inherited;
  if FFonts.Find(AModelHolder.Model.FontKey, fontKeyCounter) then
  begin
    dec(fontKeyCounter.CountFontKeyUse);
    if fontKeyCounter.CountFontKeyUse = 0 then
    begin
      FFontStyles.Delete(AModelHolder.Model.StyleKey);
      fontKeyCounter.Style.Free;
      FFonts.Delete(AModelHolder.Model.FontKey);
      fontKeyCounter.Font := nil;
      dispose(fontKeyCounter);
    end;
  end;
  FreeAndNil(AModelHolder.Model.View);
end;

procedure TCanvasTextMap.DoShow(const AModelHolder: TCanvasTextMap.PModelHolder);
var
  fontKeyCounter: PFontKeyCounter;
  w, h: BSFloat;
begin
  inherited;
  AModelHolder.Model.View := TCanvasText.Create(Canvas, FViewPort);
  AModelHolder.Model.View.SceneTextData.BeginChangeProp;
  AModelHolder.Model.View.Data.StencilTest := true;

  fontKeyCounter := GetFont(AModelHolder.Model.FontKey);
  inc(fontKeyCounter.CountFontKeyUse);
  AModelHolder.Model.View.Font := fontKeyCounter.Font;
  DoApplyStyle(GetTextStyle(AModelHolder.Model.StyleKey), AModelHolder.Model.View);
  if AModelHolder.Model.Rect.X - ViewPortPosition.x + AModelHolder.Model.Rect.Width > FViewPortSize.Width then
    w := FViewPortSize.Width - (AModelHolder.Model.Rect.X - ViewPortPosition.x)
  else
    w := AModelHolder.Model.Rect.Width;

  if AModelHolder.Model.Rect.Y - ViewPortPosition.y + AModelHolder.Model.Rect.Height > FViewPortSize.Height then
    h := FViewPortSize.Height - (AModelHolder.Model.Rect.Y - ViewPortPosition.y)
  else
    h := AModelHolder.Model.Rect.Height;

  AModelHolder.Model.View.ViewportSize := vec2(w, h);

  //AModelHolder.Model.View.SceneTextData.TxtProcessor.ViewportWidth := AModelHolder.Model.Rect.Width;
  AModelHolder.Model.View.TextAlign := AModelHolder.Model.Align;
  AModelHolder.Model.View.Text := AModelHolder.Model.Model;
  AModelHolder.Model.View.SceneTextData.EndChangeProp;

  AModelHolder.Model.View.Position2d := AModelHolder.Model.Rect.Position;
end;

function TCanvasTextMap.DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign): PInlineStyle;
begin
  Result := DoDrawText(AText, ARect, AAlign);
end;

procedure TCanvasTextMap.DrawViewPort(Instance: PRendererGraphicInstance);
begin
  { fill the shape Back as the stencil for ban draw outside him }
  //glClear ( GL_STENCIL_BUFFER_BIT );
  glClearStencil(0);
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
end;

class function TCanvasTextMap.GetComparator: TKeyComparatorEqual<TCanvasTextMap.PModelHolder>;
begin
  Result := Compare;
end;

function TCanvasTextMap.GetFont(var AFontKey: uint32): PFontKeyCounter;
begin
  if not FFonts.Find(AFontKey, Result) then
  begin
    new(Result);
    Result.CountFontKeyUse := 0;
    Result.Style := GetFontStyle(AFontKey);
    Result.Font := BSFontManager.GetFont(FTextStyle.Name, TTrueTypeRasterFont);
    Result.Font.Bold := Result.Style.Bold;
    Result.Font.BoldWeightX := Result.Style.BoldWeightX;
    Result.Font.BoldWeightY := Result.Style.BoldWeightY;
    Result.Font.Italic := Result.Style.Italic;
    Result.Font.ItalicWeight := Result.Style.ItalicWeight;
    Result.Font.Size := Result.Style.Size;
    FFonts.TryAdd(Result.Style.FontKey, Result);
  end;
end;

function TCanvasTextMap.GetFontStyle(var AStyleKey: uint32): TTextStyle;
begin
  if not FFontStyles.Find(AStyleKey, Result) and not FFontStyles.Find(FTextStyle.StyleKey, Result) then
  begin
    Result := TTextStyle.Create(Self);
    Result.Assigne(FTextStyle);
    FFontStyles.TryAdd(Result.StyleKey, Result);
    AStyleKey := Result.StyleKey;
  end;
end;

function TCanvasTextMap.GetParent: TCanvasObject;
begin
  Result := FViewPort.Parent;
end;

function TCanvasTextMap.GetTextStyle(var AStyleKey: uint32): TTextStyle;
begin
  if not FStyles.Find(AStyleKey, Result) and not FStyles.Find(FTextStyle.StyleKey, Result) then
  begin
    Result := TTextStyle.Create(Self);
    Result.Assigne(FTextStyle);
    FStyles.TryAdd(Result.StyleKey, Result);
    AStyleKey := Result.StyleKey;
  end;
end;

procedure TCanvasTextMap.OnChangeTextStyle(ATextStyle: TTextStyle);
begin
  ApplyStyle(FTextStyle, FPrototype);
end;

procedure TCanvasTextMap.SetParent(const Value: TCanvasObject);
begin
  FViewPort.Parent := Value;
end;

procedure TCanvasTextMap.SetViewPortPosition(const Value: TVec2d);
begin
  inherited;
end;

procedure TCanvasTextMap.SetViewPortSize(const Value: TVec2d);
begin
  inherited;
  FViewPort.Size := Value;
  FViewPort.Build;
end;

{ TTextStyle }

procedure TTextStyle.Assigne(ASource: TTextStyle);
begin
  FOwner := ASource.FOwner;
  FName := ASource.Name;
  FSize := ASource.Size;
  FItalic := ASource.Italic;
  FBold := ASource.Bold;
  FFontKey := ASource.FontKey;
  FUnderline := ASource.Underline;
  FStrikeout := ASource.Strikeout;
  FOnChangeStyle := ASource.OnChangeStyle;
  FBoldWeightX := ASource.BoldWeightX;
  FBoldWeightY := ASource.BoldWeightY;
  FItalicWeight := ASource.ItalicWeight;
  FStyleKey := ASource.StyleKey;
  FWrap := ASource.Wrap;
end;

procedure TTextStyle.BeginUpdate;
begin
  inc(FCountUpdate);
end;

procedure TTextStyle.BuildKeys;
begin

  FFontKey := GetHashBlackSharkS(
      IntToStr(FSize) +
      FName + ':' +
      BoolToStr(FBold) + ':' +
      IntToStr(trunc(FBoldWeightX*100)) + ':' +
      IntToStr(trunc(FBoldWeightY*100)) + ':' +
      BoolToStr(FItalic) + ':' +
      IntToStr(trunc(FItalicWeight*100))
    );

  FStyleKey := GetHashBlackSharkS(
      FName + ':' +
      VecToStr(FColor, 2) + ':' +
      VecToStr(FColorLine, 2) + ':' +
      BoolToStr(FWrap) + ':' +
      BoolToStr(FUnderline) + ':' +
      BoolToStr(FStrikeout) + ':'
    );

end;

constructor TTextStyle.Create(AOwner: TObject);
begin
  FOwner := AOwner;
  FName := BSFontManager.DEFAULT_FONT;
  FBoldWeightX := DEFAULT_BOLD_WEIGHT_X;
  FBoldWeightY := DEFAULT_BOLD_WEIGHT_Y;
  FItalicWeight := DEFAULT_ITALIC_WEIGHT;
  FSize := DEFAULT_SIZE;
  BuildKeys;
end;

procedure TTextStyle.EndUpdate;
begin
  dec(FCountUpdate);
  if (FCountUpdate = 0) and FModified then
  begin
    BuildKeys;
    if Assigned(FOnChangeStyle) then
      FOnChangeStyle(Self);
  end;
end;

procedure TTextStyle.SetBold(const Value: boolean);
begin
  if FBold = Value then
    exit;
  FBold := Value;
  FModified := true;
end;

procedure TTextStyle.SetBoldWeightX(const Value: BSFloat);
begin
  if FBoldWeightX = Value then
    exit;
  FBoldWeightX := Value;
  FModified := true;
end;

procedure TTextStyle.SetBoldWeightY(const Value: BSFloat);
begin
  if FBoldWeightY = Value then
    exit;
  FBoldWeightY := Value;
  FModified := true;
end;

procedure TTextStyle.SetColor(const Value: TColor4f);
begin
  if FColor = Value then
    exit;
  FColor := Value;
  FModified := true;
end;

procedure TTextStyle.SetColorLine(const Value: TColor4f);
begin
  if FColorLine = Value then
    exit;
  FColorLine := Value;
  FModified := true;
end;

procedure TTextStyle.SetItalic(const Value: boolean);
begin
  if FItalic = Value then
    exit;
  FItalic := Value;
  FModified := true;
end;

procedure TTextStyle.SetItalicWeight(const Value: BSFloat);
begin
  if FItalicWeight = Value then
    exit;
  FItalicWeight := Value;
  FModified := true;
end;

procedure TTextStyle.SetName(const Value: string);
begin
  if FName = Value then
    exit;
  FName := Value;
  FModified := true;
end;

procedure TTextStyle.SetSize(const Value: int32);
begin
  if FSize = Value then
    exit;
  FSize := Value;
  FModified := true;
end;

procedure TTextStyle.SetStrikeout(const Value: boolean);
begin
  if FStrikeout = Value then
    exit;
  FStrikeout := Value;
  FModified := true;
end;

procedure TTextStyle.SetUnderline(const Value: boolean);
begin
  if FUnderline = Value then
    exit;
  FUnderline := Value;
  FModified := true;
end;

procedure TTextStyle.SetWrap(const Value: boolean);
begin
  if FWrap = Value then
    exit;
  FWrap := Value;
  FModified := true;
end;

end.
