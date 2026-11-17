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
  , bs.renderer
  , bs.strings
  , bs.geometry.kdtree
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
    function AddParticle(X, Y: BSFloat; const SrcRect: TRectBSF): int32; overload;
    function AddParticle(X, Y: BSFloat; const SrcRect: TTextureRect): int32; overload;
    procedure DeleteParticle(AIndex: int32);
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

  TObjectModelMapper = class;

  PModelHolder = ^TModelHolder;

  TListDualModels = TListDual<PModelHolder>;

  TModelHolder = record
    Mapper: TObjectModelMapper;
    Rect: TRectBSd;
    Layer: int32;
    Model: Pointer;
    Angle: TVec3f;
    ListPos: TListDualModels.PListItem;
    View: TCanvasObject;
  end;

  TModelEventNotify = procedure(AModelHolder: PModelHolder) of object;

  TModelsMap = class
  private
    type
      TCanvasObjects2DTree = T2DTree<PModelHolder>;
      THashTableModels = THashTable<Integer, PModelHolder>;
      TListModels = TListVec<PModelHolder>;

  private
    FMap: TCanvasObjects2DTree;
    FOnShowModel: TModelEventNotify;
    FOnHideModel: TModelEventNotify;
    FViewPort: TBox2d;
    FViewPortRect: TRectBSd;
    FVisibleModels: array[boolean] of TListDualModels;
    FListIndex: boolean;
    FUpdating: boolean;
    FContentPadding: int32;
    procedure SetContentPadding(const Value: int32);
    function Vec4d(const ARect: TRectBSd): TBox2d; overload; inline;
    //function Box(const APosition, ASize: TVec2f): TBox3d; overload; inline;
    procedure ReloadViewport;
    //function IntersectViewport(const ABox: TBox3d): boolean; inline;
    function DoAdd(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; ALayer: int32; const AAngle: TVec3f): PModelHolder; inline;
    procedure OnDelete(const AHolder: PModelHolder);
    function GetViewPortPosition: TVec2d;
    function GetViewPortSize: TVec2d;
    procedure CheckVisibility(AHolder: PModelHolder);
  protected
    class function GetComparator: TKeyComparatorEqual<PModelHolder>; virtual;
    procedure DoUpdate(const ARect: TRectBSd; AHolder: PModelHolder); virtual;
    procedure DoShow(const AModelHolder: PModelHolder); virtual;
    procedure DoHide(const AModelHolder: PModelHolder); virtual;
    procedure DoDelete(const AModelHolder: PModelHolder); virtual;
    procedure SetViewPortPosition(const Value: TVec2d); virtual;
    procedure SetViewPortSize(const Value: TVec2d); virtual;
    property ViewPort: TBox2d read FViewPort;
  public
    constructor Create; overload;
    destructor Destroy; override;

    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSf; ALayer: int32): PModelHolder; overload;
    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2d; ALayer: int32): PModelHolder; overload;
    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2d; const AAngle: TVec3f; ALayer: int32): PModelHolder; overload;
    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; ALayer: int32): PModelHolder; overload;
    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2f; ALayer: int32): PModelHolder; overload;
    function Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; const AAngle: TVec3f; ALayer: int32): PModelHolder; overload;
    procedure Update(const ARect: TRectBSf; AHolder: PModelHolder); overload;
    procedure Update(const APosition, ASize: TVec2f; AHolder: PModelHolder); overload;
    procedure Update(const ARect: TRectBSd; AHolder: PModelHolder); overload;
    procedure Update(const APosition, ASize: TVec2d; AHolder: PModelHolder); overload;
    procedure Delete(AHolder: PModelHolder);
    procedure Clear; virtual;

    property ViewPortSize: TVec2d read GetViewPortSize write SetViewPortSize;
    property ViewPortPosition: TVec2d read GetViewPortPosition write SetViewPortPosition;
    property ContentPadding: int32 read FContentPadding write SetContentPadding;

    property OnShowModel: TModelEventNotify read FOnShowModel write FOnShowModel;
    property OnHideModel: TModelEventNotify read FOnHideModel write FOnHideModel;
  end;

  TTextStyle = class;

  TTextStyleChangeEventNotify = procedure (ATextStyle: TTextStyle) of object;

  TTextStyle = class
  private

    FOwner: TObject;
    FFontName: string;
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
    procedure SetFontName(const Value: string);
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
    procedure SetModified(const Value: boolean);
  protected
    property Modified: boolean read FModified write SetModified;
  public
    constructor Create(AOwner: TObject);
    procedure Assigne(ASource: TTextStyle);
    procedure BeginUpdate;
    procedure EndUpdate;
    property FontName: string read FFontName write SetFontName;
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

  PTextModel = ^TTextModel;
  TTextModel = record
    Text: string;
    //Rect: TRectBSd;
    Align: TTextAlign;
    StyleKey: uint32;
  end;

  TCanvasObjectsMap = class;

  TObjectModelMapper = class
  private
    FMap: TCanvasObjectsMap;
  public
    constructor Create(AMap: TCanvasObjectsMap);
    destructor Destroy; override;

    procedure Hide(AModelHolder: PModelHolder); virtual; abstract;
    procedure Show(AModelHolder: PModelHolder); virtual; abstract;
    procedure Update(AModelHolder: PModelHolder); virtual; abstract;
    procedure Delete(AModelHolder: PModelHolder); virtual; abstract;
    procedure Clear; virtual; abstract;

    property Map: TCanvasObjectsMap read FMap;
  end;

  TCanvasTextMapper = class(TObjectModelMapper)
  private
    type
      PFontKeyCounter = ^TFontKeyCounter;
      TFontKeyCounter = record
        CountFontKeyUse: int32;
        Font: IBlackSharkFont;
      end;
      TFontsTable = THashTable<uint32, PFontKeyCounter>;
      TStylesTable = THashTable<uint32, TTextStyle>;
  private
    FFonts: TFontsTable;
    FStyles: TStylesTable;
    FTextStyle: TTextStyle;
    FPrototype: TCanvasText;
    FTrim: boolean;
    function GetFont(AFontKey: uint32): PFontKeyCounter;
    function GetTextStyle: TTextStyle;
    procedure ClearStyles;
    procedure ClearFonts;
    procedure DoApplyTextStyle(AStyle: TTextStyle; AText: TCanvasText); inline;
  protected
    procedure OnChangeTextStyle(ATextStyle: TTextStyle); virtual;
  public
    constructor Create(AOwner: TCanvasObjectsMap);
    destructor Destroy; override;
    function DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign = TTextAlign.taLeft): PTextModel;
    procedure ApplyTextStyle(AStyle: TTextStyle; AText: TCanvasText);
    procedure Clear; override;
    procedure Show(AModelHolder: PModelHolder); override;
    procedure Hide(AModelHolder: PModelHolder); override;
    procedure Update(AModelHolder: PModelHolder); override;
    procedure Delete(AModelHolder: PModelHolder); override;

    property TextStyle: TTextStyle read FTextStyle;
    property Prototype: TCanvasText read FPrototype;
    property Trim: boolean read FTrim write FTrim;
  end;

  PPictureModel = ^TPictureModel;
  TPictureModel = record
    FileName: string;
    Instancer: TBlackSharkInstancing2d;
    Index: int32;
    IsParticle: boolean;
    Size: TVec2f;
    Opacity: BSFloat;
  end;

  TCanvasPictureMapper = class(TObjectModelMapper)
  private
    type
      TParticleMaps = THashTable<string, TCanvasMap>;
      TPictureMaps = THashTable<string, TBlackSharkInstancing2d>;
  private
    FParticleMaps: TParticleMaps;
    FPictureMaps: TPictureMaps;
  public
    constructor Create(AOwner: TCanvasObjectsMap);
    destructor Destroy; override;
    procedure Clear; override;
    procedure Show(AModelHolder: PModelHolder); override;
    procedure Hide(AModelHolder: PModelHolder); override;
    procedure Update(AModelHolder: PModelHolder); override;
    procedure Delete(AModelHolder: PModelHolder); override;
    function DrawInstancedPicture(const AFileName: string; const ASize: TVec2f; AOpacity: BSFloat = 1.0): PPictureModel; overload;
    function Draw(const AFileName: string; const ASize: TVec2f; AOpacity: BSFloat = 1.0): PPictureModel; overload;
    function DrawParticle(const AFileName: string; const ASrcRect: TTextureRect): PPictureModel; overload;
  end;

  TCanvasObjectsMap = class(TModelsMap)
  private
    class function Compare(const Model1, Model2: PModelHolder): boolean; static;
  private
    ObsrvResizeVP: IBResizeWindowEventObserver;
    FCanvasRoot: TCanvasObject;
    FObjectsHolder: TRectangle;
    FTextMapper: TCanvasTextMapper;
    FPictureMapper: TCanvasPictureMapper;
    FCanvas: TBCanvas;
    FStencilBackground: TRectangle;
    FMethodStencilDraw: TDrawInstanceMethod;
    FBackground: TPicture;
    procedure OnChangeBackground(ASender: TObject);
    procedure OnResizeViewport({%H-}const Data: BResizeEventData);
    procedure UpdateViewCameraPosition;
  protected
    class function GetComparator: TKeyComparatorEqual<PModelHolder>; override;
    procedure DoUpdate(const ARect: TRectBSd; AHolder: PModelHolder); override;
    procedure DoShow(const AModelHolder: PModelHolder); override;
    procedure DoHide(const AModelHolder: PModelHolder); override;
    procedure DoDelete(const AModelHolder: PModelHolder); override;
    procedure SetViewPortPosition(const Value: TVec2d); override;
    procedure SetViewPortSize(const Value: TVec2d); override;
    procedure DrawStancilBack(Instance: PRendererGraphicInstance);
  public
    constructor Create(ARenderer: TBlackSharkRenderer); overload;
    destructor Destroy; override;
    procedure Clear; override;
    function DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign = TTextAlign.taLeft; ALayer: int32 = 0): PModelHolder; overload;
    function DrawText(const AText: string; const APosition: TVec2d; ALayer: int32 = 0): PModelHolder; overload;
    function DrawText(const AText: string; const APosition: TVec2d; AAlign: TTextAlign; ALayer: int32 = 0): PModelHolder; overload;
    function DrawPicture(const AFileName: string; const ARelativeViewPortPosition: TVec2f; const ASize: TVec2f; AOpacity: BSFloat = 1.0; ALayer: int32 = 0): PModelHolder; overload;
    function DrawPicture(const AFileName: string; const ARelativeViewPortPosition: TVec2f; const ASize: TVec2f; const AAngle: TVec3f; AOpacity: BSFloat = 1.0; ALayer: int32 = 0): PModelHolder; overload;
    function DrawInstancedPicture(const AFileName: string; const ARelativeViewPortPosition: TVec2f; const ASize: TVec2f; AOpacity: BSFloat = 1.0; ALayer: int32 = 0): PModelHolder;

    property Canvas: TBCanvas read FCanvas write FCanvas;
    property TextMapper: TCanvasTextMapper read FTextMapper;
    property Background: TPicture read FBackground;
    property StencilBackground: TRectangle read FStencilBackground;
    property ObjectsHolder: TRectangle read FObjectsHolder;
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

function TCanvasMap.AddParticle(X, Y: BSFloat; const SrcRect: TRectBSF): int32;
var
  text_r: TTextureRect;
begin
  text_r.UV := RectToUV(FParticles.Texture.Texture.Picture.Width, FParticles.Texture.Texture.Picture.Height, SrcRect);
  Result := AddParticle(X, Y, text_r);
end;

function TCanvasMap.AddParticle(X, Y: BSFloat; const SrcRect: TTextureRect): int32;
begin
  Result := FParticles.CountParticle;
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
  { Don't sort! }
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

procedure TCanvasMap.DeleteParticle(AIndex: int32);
begin
  FParticles.Remove(AIndex);
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

{ TModelsMap }

constructor TModelsMap.Create;
begin
  FMap := TCanvasObjects2DTree.Create;
  FMap.OnDeleteValue := OnDelete;
  FVisibleModels[false] := TListDualModels.Create;
  FVisibleModels[true ] := TListDualModels.Create; //(GetHashBlackSharkInt32, Int32CmpBool)
  //ViewPortSize := vec2(600.0, 600.0);
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSf; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, ARect, ALayer, vec3(0.0, 0.0, 0.0));
end;

function TModelsMap.Vec4d(const ARect: TRectBSd): TBox2d;
begin
  Result.Min := ARect.Position;
  Result.Max := ARect.Position + ARect.Size;
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2f; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, RectBSd(APosition, ASize), ALayer, vec3(0.0, 0.0, 0.0));
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2d; const AAngle: TVec3f; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, RectBSd(APosition, ASize), ALayer, AAngle);
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; const AAngle: TVec3f; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, ARect, ALayer, AAngle);
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const APosition, ASize: TVec2d; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, RectBSd(APosition, ASize), ALayer, vec3(0.0, 0.0, 0.0));
end;

function TModelsMap.Add(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; ALayer: int32): PModelHolder;
begin
  Result := DoAdd(AMapper, AModel, ARect, ALayer, vec3(0.0, 0.0, 0.0));
end;

procedure TModelsMap.CheckVisibility(AHolder: PModelHolder);
var
  isVisible: boolean;
begin
  isVisible := RectIntersect(FViewPortRect, AHolder.Rect);

  if isVisible <> Assigned(AHolder.ListPos) then
  begin
    if isVisible then
      DoShow(AHolder)
    else
      DoHide(AHolder);
  end;
end;

procedure TModelsMap.Clear;
begin
  FMap.Clear;
end;

destructor TModelsMap.Destroy;
begin
  Clear;
  FMap.Free;
  FVisibleModels[false].Free;
  FVisibleModels[true ].Free;
  inherited;
end;

function TModelsMap.DoAdd(AMapper: TObjectModelMapper; const AModel: Pointer; const ARect: TRectBSd; ALayer: int32; const AAngle: TVec3f): PModelHolder;
var
  box2d: TBox2d;
begin
  new(Result);
  FillChar(Result^, SizeOf(TModelHolder), 0);
  Result.Model := AModel;
  Result.Mapper := AMapper;
  Result.Rect := ARect;
  Result.Layer := ALayer;
  Result.Angle := AAngle;
  box2d := Vec4d(ARect);
  FMap.Add(Result, box2d);
  CheckVisibility(Result);
end;

procedure TModelsMap.DoDelete(const AModelHolder: PModelHolder);
begin
  if not FUpdating then
  begin
    if Assigned(AModelHolder.ListPos) then
      DoHide(AModelHolder);
    AModelHolder.Mapper.Delete(AModelHolder);
    Dispose(AModelHolder);
  end;
end;

procedure TModelsMap.DoHide(const AModelHolder: PModelHolder);
begin
  FVisibleModels[FListIndex].Remove(AModelHolder.ListPos);
  AModelHolder.ListPos := nil;
  if Assigned(FOnHideModel) then
    FOnHideModel(AModelHolder);
end;

procedure TModelsMap.DoShow(const AModelHolder: PModelHolder);
begin
  AModelHolder.ListPos := FVisibleModels[FListIndex].PushToEnd(AModelHolder);
  if Assigned(FOnShowModel) then
    FOnShowModel(AModelHolder);
end;

procedure TModelsMap.DoUpdate(const ARect: TRectBSd; AHolder: PModelHolder);
var
  box2d: TBox2d;
  box2dOld: TBox2d;
begin
  box2d := Vec4d(ARect);
  box2dOld := Vec4d(AHolder.Rect);
  FUpdating := true;
  try
    FMap.Update(AHolder, PKDMinMax(@box2d), PKDMinMax(@box2dOld));
    AHolder.Rect := ARect;
  finally
    FUpdating := false;
  end;
  CheckVisibility(AHolder);
end;

class function TModelsMap.GetComparator: TKeyComparatorEqual<PModelHolder>;
begin
  Result := nil;
end;

function TModelsMap.GetViewPortPosition: TVec2d;
begin
  Result := FViewPortRect.Position;
end;

function TModelsMap.GetViewPortSize: TVec2d;
begin
  Result := FViewPortRect.Size;
end;

//function TModelsMap.IntersectViewport(const ABox: TBox3d): boolean;
//begin
//  Result :=
//    (not ((FViewPortRect.x + FViewPortRect.Width < ABox.x_min) or (ABox.x_max < FViewPortRect.x))) and
//    (not ((-FViewPortRect.y < ABox.y_min) or (ABox.y_max < -FViewPortRect.y - FViewPortRect.Height)));
//end;

procedure TModelsMap.OnDelete(const AHolder: PModelHolder);
begin
  DoDelete(AHolder);
end;

procedure TModelsMap.ReloadViewport;
var
  i: int32;
  holder: PModelHolder;
  selected: TListModels;
begin
  selected := FMap.Select(FViewPort);
  FListIndex := not FListIndex;
  for i := 0 to selected.Count - 1 do
  begin
    holder := selected.Items[i];
    if Assigned(holder.ListPos) then
    begin
      FVisibleModels[not FListIndex].Remove(holder.ListPos);
      holder.ListPos := FVisibleModels[FListIndex].PushToEnd(holder);
      holder.Mapper.Update(holder);
    end else
      DoShow(holder);
      {CheckVisibility(holder)};
  end;

  while FVisibleModels[not FListIndex].Count > 0 do
  begin
    holder := FVisibleModels[not FListIndex].Pop;
    holder.ListPos := FVisibleModels[FListIndex].PushToEnd(holder);
    DoHide(holder);
  end;
end;

procedure TModelsMap.Delete(AHolder: PModelHolder);
begin
  FMap.Delete(AHolder, Vec4d(AHolder.Rect));
end;

procedure TModelsMap.SetContentPadding(const Value: int32);
begin
  FContentPadding := Value;
  ReloadViewport;
end;

procedure TModelsMap.SetViewPortPosition(const Value: TVec2d);
begin
  FViewPortRect.Position := Value;
  FViewPort.Min := Value;
  FViewPort.Max := Value + FViewPortRect.Size;
  ReloadViewport;
end;

procedure TModelsMap.SetViewPortSize(const Value: TVec2d);
begin
  FViewPortRect.Size := Value;
  FViewPort.Max := FViewPort.Min + Value;
  ReloadViewport;
end;

procedure TModelsMap.Update(const ARect: TRectBSd; AHolder: PModelHolder);
begin
  DoUpdate(ARect, AHolder);
end;

procedure TModelsMap.Update(const APosition, ASize: TVec2d; AHolder: PModelHolder);
begin
  DoUpdate(RectBSd(APosition, ASize), AHolder);
end;

procedure TModelsMap.Update(const APosition, ASize: TVec2f; AHolder: PModelHolder);
begin
  DoUpdate(RectBSd(APosition, ASize), AHolder);
end;

procedure TModelsMap.Update(const ARect: TRectBSf; AHolder: PModelHolder);
begin
  DoUpdate(ARect, AHolder);
end;

{ TCanvasTextMapper }

procedure TCanvasTextMapper.ApplyTextStyle(AStyle: TTextStyle; AText: TCanvasText);
var
  fontCounter: PFontKeyCounter;
  fontKey: uint32;
begin
  DoApplyTextStyle(AStyle, AText);
  fontKey := AStyle.FontKey;
  fontCounter := GetFont(fontKey);
  FPrototype.Font := fontCounter.Font;
end;

procedure TCanvasTextMapper.ClearFonts;
var
  bucket: TFontsTable.TBucket;
begin

  if FFonts.GetFirst(bucket) then
  repeat
    dispose(bucket.Value);
  until not FFonts.GetNext(bucket);

  FFonts.Clear;

//  if FFontStyles.GetFirst(bucketStyle) then
//  repeat
//    bucketStyle.Value.Free;
//  until not FFontStyles.GetNext(bucketStyle);

//  FFontStyles.Clear;
end;

procedure TCanvasTextMapper.ClearStyles;
var
  bucket: TStylesTable.TBucket;
begin

  if FStyles.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FStyles.GetNext(bucket);

  FStyles.Clear;
end;

constructor TCanvasTextMapper.Create(AOwner: TCanvasObjectsMap);
begin
  inherited;
  FFonts := TFontsTable.Create;
  FStyles := TStylesTable.Create;
  FTextStyle := TTextStyle.Create(Self);
  FTextStyle.OnChangeStyle := OnChangeTextStyle;
  FPrototype := TCanvasText.Create(Map.Canvas, nil);
  FPrototype.Data.Hidden := true;
end;

procedure TCanvasTextMapper.Clear;
begin
  ClearFonts;
  ClearStyles;
end;

procedure TCanvasTextMapper.Delete(AModelHolder: PModelHolder);
var
  style: TTextStyle;
  model: PTextModel;
  fontKeyCounter: PFontKeyCounter;
begin
  model := AModelHolder.Model;
  if FStyles.Find(model.StyleKey, style) and FFonts.Find(style.FontKey, fontKeyCounter) then
  begin
    dec(fontKeyCounter.CountFontKeyUse);
    if fontKeyCounter.CountFontKeyUse = 0 then
    begin
      FFonts.Delete(style.FontKey);
      FStyles.Delete(model.StyleKey);
      style.Free;
      fontKeyCounter.Font := nil;
      dispose(fontKeyCounter);
    end;
  end;
  dispose(PTextModel(AModelHolder.Model));
  AModelHolder.Model := nil;
end;

destructor TCanvasTextMapper.Destroy;
begin
  Clear;
  FPrototype.Free;
  FFonts.Free;
  FStyles.Free;
  FTextStyle.Free;
  inherited;
end;

procedure TCanvasTextMapper.DoApplyTextStyle(AStyle: TTextStyle; AText: TCanvasText);
begin
  AText.Strikethrough := AStyle.Strikeout;
  AText.Underline := AStyle.Underline;
  AText.Color := AStyle.Color;
  AText.Wrap := AStyle.Wrap;
  if AStyle.Strikeout or AStyle.Underline then
    AText.ColorLine := AStyle.ColorLine;
end;

function TCanvasTextMapper.DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign): PTextModel;
var
  style: TTextStyle;
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
    style := GetTextStyle;
    fontCounter.Font.Bold := style.Bold;
    fontCounter.Font.BoldWeightX := style.BoldWeightX;
    fontCounter.Font.BoldWeightY := style.BoldWeightY;
    fontCounter.Font.Italic := style.Italic;
    fontCounter.Font.ItalicWeight := style.ItalicWeight;
    fontCounter.Font.Size := style.Size;
    DoApplyTextStyle(style, FPrototype);
  end;
  FPrototype.SceneTextData.DiscardBlanks := FTrim;
  FPrototype.TextAlign := AAlign;
  FPrototype.ViewportSize := ARect.Size;
  FPrototype.Text := AText;
  FPrototype.SceneTextData.EndChangeProp;

  new(Result);
  Result.Text := AText;
  Result.StyleKey := FTextStyle.StyleKey;
  Result.Align := AAlign;
end;

function TCanvasTextMapper.GetFont(AFontKey: uint32): PFontKeyCounter;
begin
  if not FFonts.Find(AFontKey, Result) then
  begin
    new(Result);
    Result.CountFontKeyUse := 0;
    Result.Font := BSFontManager.GetFont(FTextStyle.FontName, TTrueTypeRasterFont);
    FFonts.Items[AFontKey] := Result;
  end;
end;

function TCanvasTextMapper.GetTextStyle: TTextStyle;
begin
  if not FStyles.Find(FTextStyle.StyleKey, Result) then
  begin
    Result := TTextStyle.Create(Self);
    Result.Assigne(FTextStyle);
    FStyles.TryAdd(Result.StyleKey, Result);
  end;
end;

procedure TCanvasTextMapper.Hide(AModelHolder: PModelHolder);
begin
  FreeAndNil(AModelHolder.View);
end;

procedure TCanvasTextMapper.Show(AModelHolder: PModelHolder);
var
  style: TTextStyle;
  model: PTextModel;
  fontKeyCounter: PFontKeyCounter;
  view: TCanvasText;
begin
  model := AModelHolder.Model;
  view := TCanvasText.Create(Map.Canvas, Map.ObjectsHolder);
  AModelHolder.View := view;
  view.Data.StencilParent := Map.StencilBackground.Data;
  view.Data.StencilTest := true;
  view.Layer2d := AModelHolder.Layer;
  style := FStyles.Items[model.StyleKey];
  fontKeyCounter := GetFont(style.FontKey);
  inc(fontKeyCounter.CountFontKeyUse);
  view.Font := fontKeyCounter.Font;
  view.SceneTextData.BeginChangeProp;
  view.SceneTextData.DiscardBlanks := FTrim;
  DoApplyTextStyle(style, view);
  view.TextAlign := model.Align;

  //UpdateViewportSize(AModelHolder);
  view.ViewportSize := AModelHolder.Rect.Size;
  view.Text := model.Text;
  view.SceneTextData.EndChangeProp;

  // TODO: remove
  view.Data.Interactive := true;
  view.Data.Caption := model.Text;

  view.Position2d := AModelHolder.Rect.Position;
end;

procedure TCanvasTextMapper.Update(AModelHolder: PModelHolder);
begin
  if not Assigned(AModelHolder.View) then
    exit;
  //UpdateViewportSize(AModelHolder);
  if (AModelHolder.View.Position2d.x <> AModelHolder.Rect.Position.x) or (AModelHolder.View.Position2d.y <> AModelHolder.Rect.Position.y) then
    AModelHolder.View.Position2d := AModelHolder.Rect.Position;
end;

procedure TCanvasTextMapper.OnChangeTextStyle(ATextStyle: TTextStyle);
begin
  ApplyTextStyle(FTextStyle, FPrototype);
end;

{ TTextStyle }

procedure TTextStyle.Assigne(ASource: TTextStyle);
begin
  FOwner := ASource.FOwner;
  FFontName := ASource.FontName;
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
      FFontName + ':' +
      BoolToStr(FBold) + ':' +
      IntToStr(trunc(FBoldWeightX*100)) + ':' +
      IntToStr(trunc(FBoldWeightY*100)) + ':' +
      BoolToStr(FItalic) + ':' +
      IntToStr(trunc(FItalicWeight*100))
    );

  FStyleKey := FFontKey or GetHashBlackSharkS(
      FFontName + ':' +
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
  FFontName := BSFontManager.DEFAULT_FONT;
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

procedure TTextStyle.SetModified(const Value: boolean);
begin
  if FModified = Value then
    exit;
  FModified := Value;
  if not FModified then
    BuildKeys;
end;

procedure TTextStyle.SetFontName(const Value: string);
begin
  if FFontName = Value then
    exit;
  FFontName := Value;
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

{ TCanvasObjectsMap }

procedure TCanvasObjectsMap.Clear;
begin
  inherited;
  FTextMapper.Clear;
  FPictureMapper.Clear;
end;

constructor TCanvasObjectsMap.Create(ARenderer: TBlackSharkRenderer);
begin
  ObsrvResizeVP := CreateResizeWindowObserver(ARenderer.EventResize, OnResizeViewport);
  FCanvas := TBCanvas.Create(ARenderer, nil);
  FCanvas.StickOnScreen := false;
  FCanvasRoot := FCanvas.CreateEmptyCanvasObject;
//  FCanvasRoot.Data.SceneSpaceTreeClient := true;
//  FCanvasRoot.Size := ARenderer.ScreenSize;
//  FCanvasRoot.Fill := true;
//  FCanvasRoot.Data.Interactive := false;
//  FCanvasRoot.Data.Opacity := 0.2;
//  FCanvasRoot.Build;
  FCanvasRoot.Data.Caption := 'CanvasObjectsMapRoot';
  // for not full screen application need stencil
  FStencilBackground := TRectangle.Create(FCanvas, FCanvasRoot);
  FStencilBackground.Fill := true;
  FStencilBackground.Data.AsStencil := true;
  FStencilBackground.Data.Opacity := 0.0;
  FStencilBackground.Data.Caption := 'StencilBackground';
  FStencilBackground.Color := BS_CL_RED;
  FStencilBackground.Data.SceneSpaceTreeClient := true;
  FStencilBackground.Data.Interactive := false;
  FMethodStencilDraw := FStencilBackground.Data.DrawInstance;
  FStencilBackground.Data.DrawInstance := DrawStancilBack;

  FBackground := TPicture.Create(FCanvas, FStencilBackground);
  FBackground.AutoFit := false;
  FBackground.Data.Interactive := false;
  //FBackground.Data.DragResolve := false;
  FBackground.Size := FStencilBackground.Size;
  FBackground.Position2d := vec2(0.0, 0.0);
  FBackground.OnChangeNotify := OnChangeBackground;
  FBackground.Data.Caption := 'Background';
  FBackground.Data.SceneSpaceTreeClient := true;

  FObjectsHolder := TRectangle.Create(FCanvas, nil);
  FObjectsHolder.Fill := true;
  FObjectsHolder.Data.Interactive := false;
  FObjectsHolder.Data.Opacity := 0.5;
  //FObjectsHolder := FCanvas.CreateEmptyCanvasObject(FCanvasRoot);
  FObjectsHolder.Layer2d := 5;
  FObjectsHolder.Data.Caption := 'CanvasObjectsMapObjectsHolder';
  FObjectsHolder.Data.SceneSpaceTreeClient := true;
  inherited Create;
  FTextMapper := TCanvasTextMapper.Create(Self);
  FPictureMapper := TCanvasPictureMapper.Create(Self);
end;

destructor TCanvasObjectsMap.Destroy;
begin
  inherited;
  FTextMapper.Free;
  FPictureMapper.Free;
  FCanvas.Free;
end;

procedure TCanvasObjectsMap.DoDelete(const AModelHolder: PModelHolder);
begin
  inherited;
end;

procedure TCanvasObjectsMap.DoHide(const AModelHolder: PModelHolder);
begin
  inherited;
  AModelHolder.Mapper.Hide(AModelHolder);
end;

procedure TCanvasObjectsMap.DoShow(const AModelHolder: PModelHolder);
begin
  inherited;
  AModelHolder.Mapper.Show(AModelHolder);
end;

procedure TCanvasObjectsMap.DoUpdate(const ARect: TRectBSd; AHolder: PModelHolder);
begin
  inherited;
  AHolder.Mapper.Update(AHolder);
end;

function TCanvasObjectsMap.DrawInstancedPicture(const AFileName: string; const ARelativeViewPortPosition, ASize: TVec2f; AOpacity: BSFloat; ALayer: int32): PModelHolder;
var
  model: PPictureModel;
begin
  model := FPictureMapper.DrawInstancedPicture(AFileName, ASize, AOpacity);
  Result := Add(FPictureMapper, model, RectBS(ViewPortPosition + ARelativeViewPortPosition, model.Size.Width, model.Size.Height), ALayer);
end;

function TCanvasObjectsMap.DrawPicture(const AFileName: string; const ARelativeViewPortPosition, ASize: TVec2f; const AAngle: TVec3f; AOpacity: BSFloat;
  ALayer: int32): PModelHolder;
var
  model: PPictureModel;
begin
  model := FPictureMapper.Draw(AFileName, ASize, AOpacity);
  Result := Add(FPictureMapper, model, RectBS(ViewPortPosition + ARelativeViewPortPosition, model.Size.Width, model.Size.Height), AAngle, ALayer);
end;

function TCanvasObjectsMap.DrawPicture(const AFileName: string; const ARelativeViewPortPosition: TVec2f; const ASize: TVec2f; AOpacity: BSFloat = 1.0; ALayer: int32 = 0): PModelHolder;
var
  model: PPictureModel;
begin
  model := FPictureMapper.Draw(AFileName, ASize, AOpacity);
  Result := Add(FPictureMapper, model, RectBS(ViewPortPosition + ARelativeViewPortPosition, model.Size.Width, model.Size.Height), ALayer);
end;

procedure TCanvasObjectsMap.DrawStancilBack(Instance: PRendererGraphicInstance);
begin
  { fill the shape Back as the stencil for ban draw outside him }
  glClearStencil(0);
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  FMethodStencilDraw(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
  FMethodStencilDraw(Instance);
end;

function TCanvasObjectsMap.DrawText(const AText: string; const APosition: TVec2d; ALayer: int32): PModelHolder;
begin
  Result := DrawText(AText, RectBSd(APosition, vec2d(ViewPortSize.Width, 0)));
end;

function TCanvasObjectsMap.DrawText(const AText: string; const ARect: TRectBSd; AAlign: TTextAlign; ALayer: int32): PModelHolder;
var
  model: PTextModel;
begin
  model := FTextMapper.DrawText(AText, ARect, AAlign);
  Result := Add(FTextMapper, model, RectBS(ARect.Position, ARect.Width, FTextMapper.Prototype.Height), ALayer);
end;

function TCanvasObjectsMap.DrawText(const AText: string; const APosition: TVec2d; AAlign: TTextAlign; ALayer: int32): PModelHolder;
var
  model: PTextModel;
begin
  model := FTextMapper.DrawText(AText, RectBSd(APosition, vec2d(ViewPortSize.Width, 0)), AAlign);
  Result := Add(FTextMapper, model, RectBS(APosition, FTextMapper.Prototype.Width, FTextMapper.Prototype.Height), ALayer);
end;

class function TCanvasObjectsMap.Compare(const Model1, Model2: PModelHolder): boolean;
begin
  Result := Model1.Model = Model2.Model;
end;

class function TCanvasObjectsMap.GetComparator: TKeyComparatorEqual<PModelHolder>;
begin
  Result := Compare;
end;

procedure TCanvasObjectsMap.OnChangeBackground(ASender: TObject);
begin
  FBackground.Position2d := vec2(0.0, 0.0);
end;

procedure TCanvasObjectsMap.OnResizeViewport(const Data: BResizeEventData);
begin
  UpdateViewCameraPosition;
end;

procedure TCanvasObjectsMap.SetViewPortPosition(const Value: TVec2d);
begin
  FStencilBackground.Position2d := Value;
  UpdateViewCameraPosition;
  inherited;
end;

procedure TCanvasObjectsMap.SetViewPortSize(const Value: TVec2d);
begin
  inherited;
  FStencilBackground.Size := Value;
  FStencilBackground.Build;
  FStencilBackground.Position2d := ViewPortPosition;
  FBackground.Size := Value;
  FBackground.Build;
  UpdateViewCameraPosition;
end;

procedure TCanvasObjectsMap.UpdateViewCameraPosition;
var
  pos: TVec3f;
begin
  pos := FStencilBackground.Data.AbsolutePosition;
  Canvas.Renderer.Frustum.Position := vec3(pos.x, pos.y, Canvas.Renderer.Frustum.Position.z);
end;

{ TObjectModelMapper }

constructor TObjectModelMapper.Create(AMap: TCanvasObjectsMap);
begin
  FMap := AMap;
end;

destructor TObjectModelMapper.Destroy;
begin
  Clear;
  inherited;
end;

{ TCanvasPictureMapper }

procedure TCanvasPictureMapper.Clear;
var
  bucket: TParticleMaps.TBucket;
  bucketPic: TPictureMaps.TBucket;
begin
  if FParticleMaps.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FParticleMaps.GetNext(bucket);
  FParticleMaps.Clear();

  if FPictureMaps.GetFirst(bucketPic) then
  repeat
    bucketPic.Value.Free;
  until not FPictureMaps.GetNext(bucketPic);
  FPictureMaps.Clear();
end;

constructor TCanvasPictureMapper.Create(AOwner: TCanvasObjectsMap);
begin
  inherited Create(AOwner);
  FParticleMaps := TParticleMaps.Create(GetHashBlackSharkS, StrCmpBool);
  FPictureMaps := TPictureMaps.Create(GetHashBlackSharkS, StrCmpBool);
end;

procedure TCanvasPictureMapper.Delete(AModelHolder: PModelHolder);
var
  model: PPictureModel;
  proto: TCanvasObject;
begin
  model := AModelHolder.Model;
  AModelHolder.Model := nil;
  if Assigned(model.Instancer) and (model.Instancer.CountInstance = 0) then
  begin
    proto := model.Instancer.PrototypeCanvasObject;
    model.Instancer.Prototype := nil;
    proto.Free;
    FPictureMaps.Delete(model.FileName);
    model.Instancer.Free;
  end;
  dispose(model);
end;

destructor TCanvasPictureMapper.Destroy;
begin
  inherited;
  FParticleMaps.Free;
  FPictureMaps.Free;
end;

function TCanvasPictureMapper.DrawInstancedPicture(const AFileName: string; const ASize: TVec2f; AOpacity: BSFloat = 1.0): PPictureModel;
var
  proto: TPicture;
begin
  new(Result);
  Result.FileName := AFileName;
  Result.IsParticle := false;
  Result.Index := -1;
  Result.Opacity := AOpacity;

  if not FPictureMaps.Find(AFileName, Result.Instancer) then
  begin
    proto := TPicture.Create(Map.Canvas, Map.ObjectsHolder);
    proto.Size := ASize;
    //proto.Layer2d := ALayer;
    proto.AutoFit := false;
    proto.Data.Interactive := false;
    proto.LoadFromFile(AFileName);
    proto.Data.StencilParent := Map.StencilBackground.Data;
    proto.Data.StencilTest := true;
    //proto.Align := TObjectAlign.oaTop;
    //proto.PaddingTop := 100;
    Result.Instancer := TBlackSharkInstancing2d.Create(Map.Canvas.Renderer, proto);
    FPictureMaps.Items[AFileName] := Result.Instancer;
  end;

  Result.Size := vec2(Result.Instancer.PrototypeCanvasObject.Width, Result.Instancer.PrototypeCanvasObject.Height);
end;

function TCanvasPictureMapper.DrawParticle(const AFileName: string; const ASrcRect: TTextureRect): PPictureModel;
begin
  new(Result);
  Result.FileName := AFileName;
  Result.IsParticle := true;
  Result.Index := -1;
  Result.Instancer := nil;
end;

function TCanvasPictureMapper.Draw(const AFileName: string; const ASize: TVec2f; AOpacity: BSFloat): PPictureModel;
begin
  new(Result);
  Result.FileName := AFileName;
  Result.IsParticle := false;
  Result.Index := -1;
  Result.Size := ASize;
  Result.Opacity := AOpacity;
  Result.Instancer := nil;
end;

procedure TCanvasPictureMapper.Hide(AModelHolder: PModelHolder);
var
  model: PPictureModel;
begin
  model := AModelHolder.Model;
  if model.IsParticle then
  begin

  end else
  if Assigned(model.Instancer) then
  begin
    // TODO: it's wrong
    //model.Instancer.Remove(model.Index);
    //model.Index := -1;
  end else
  if Assigned(AModelHolder.View) then
  begin
    FreeAndNil(AModelHolder.View);
  end;
end;

procedure TCanvasPictureMapper.Show(AModelHolder: PModelHolder);
var
  model: PPictureModel;
  scale: TVec2f;
  view: TPicture;
begin
  model := AModelHolder.Model;
  if model.IsParticle then
  begin
    // todo
  end else
  if Assigned(model.Instancer) then
  begin
    model.Index := model.Instancer.CountInstance;
    model.Instancer.CountInstance := model.Instancer.CountInstance + 1;
    model.Instancer.BeginUpdate(model.Index);
    try
      scale := model.Size / vec2(model.Instancer.PrototypeCanvasObject.Width, model.Instancer.PrototypeCanvasObject.Height);
      if scale.x < scale.y then
        model.Instancer.Scale[model.Index] := scale.x
      else
        model.Instancer.Scale[model.Index] := scale.y;
      model.Instancer.Position2d[model.Index] := AModelHolder.Rect.Position;
      model.Instancer.Opacity[model.Index] := model.Opacity;
    finally
      model.Instancer.EndUpdate;
    end;
    AModelHolder.View := model.Instancer.PrototypeCanvasObject;
  end else
  begin
    view := TPicture.Create(Map.Canvas, Map.ObjectsHolder);
    view.Size := model.Size;
    view.Layer2d := AModelHolder.Layer;
    view.AutoFit := false;
    //view.Data.Interactive := false;
    view.Data.StencilParent := Map.StencilBackground.Data;
    view.Data.StencilTest := true;
    view.Data.Opacity := model.Opacity;
    view.LoadFromFile(model.FileName);
    view.Data.Angle := AModelHolder.Angle;
    view.Position2d := AModelHolder.Rect.Position;
    AModelHolder.View := view;
  end;

end;

procedure TCanvasPictureMapper.Update(AModelHolder: PModelHolder);
var
  pos: TVec2d;
  model: PPictureModel;
begin
  model := AModelHolder.Model;
  if Assigned(model.Instancer) and (model.Index >= 0) then
  begin
    pos := model.Instancer.Position2d[model.Index];
    model.Instancer.BeginUpdate(model.Index);
    try
      if (pos.x <> AModelHolder.Rect.Position.x) or (pos.y <> AModelHolder.Rect.Position.y) then
        model.Instancer.Position2d[model.Index] := AModelHolder.Rect.Position
    finally
      model.Instancer.EndUpdate;
    end;
  end;
end;

end.
