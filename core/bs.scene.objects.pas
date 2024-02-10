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


unit bs.scene.objects;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.align
  , bs.events
  , bs.scene
  , bs.mesh
  , bs.mesh.primitives
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.shader
  , bs.texture
  , bs.font
  , bs.textprocessor
  , bs.collections
  , bs.strings
  ;

type

  {
    TObjectVertexes

    It's the base class for visualisation meshes; vertex consist of position only;
    vertexes and indexes translate through VBO to GPU if switched on StaticObject
    property (more suitable for static objects - no changeable the data vertexes,
    and transforms only through MVP matrix), else every time for draw data vertexes
    translate from RAM to GPU; note, the class marked as "abstract" because means
    about impossibility use him directly, so as in vertex not enough components
    for visualisation, for example, texture coordinates, colors, or appropriate
    uniform in a shader for color; for draw must assign to TGraphicObject.Shader
    property shader TBlackSharkVertexOutShader or him descendants }

  TObjectVertexes = class abstract(TGraphicObject)
  private
    FVAO: GLUint;
    FVBO_Vertexes: GLUint;
    FVBO_Indexes: GLUint;
    OpacityUniform: PShaderParametr;
    MVPUniform: PShaderParametr;

    procedure BeforeDraw({%H-}Item: TGraphicObject); inline;
  protected
    procedure SetShader(const AShader: TBlackSharkShader); override;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    procedure ChangedMesh; override;
    { bind vertexes componets }
    procedure BindVBO; inline;
    procedure DrawVertexs(Instance: PRendererGraphicInstance);
    procedure Clear; override;
    procedure Restore; override;
    property VBO_Vertexes: GLUint read FVBO_Vertexes;
    property VBO_Indexes: GLUint read FVBO_Indexes;
    property VAO: GLUint read FVAO;
  end;

  {
    TTexturedVertexes

    It's textured graphic object; a shape contains vertexes consist of position
    and texture coordinates; if defined new color, then color take as texture from
    manager textures; important a feature this class, in addition use a texture,
    possibility use gradient fill for object generated manager textures;
  }

  TTexturedVertexes = class(TObjectVertexes)
  strict private
    HLS: TVec3f;
    RefTexture: IBlackSharkTexture;
    FReplaceColor: boolean;
    AreaUVUniform: PShaderParametr;
    HLSUniform: PShaderParametr;
    procedure BeforeDrawSetData({%H-}Item: TGraphicObject);
  private
    procedure SetReplaceColor(const Value: boolean);
  protected
    FTexture: PTextureArea;
    procedure SetTexture(const Value: PTextureArea); virtual;
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    procedure SetShader(const AShader: TBlackSharkShader); override;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    destructor Destroy; override;
    class function CreateMesh: TMesh; override;
    property Texture: PTextureArea read FTexture write SetTexture;
    property ReplaceColor: boolean read FReplaceColor write SetReplaceColor;
  end;

  {
    TColoredVertexes

    The class fills a single color; the shape contains vertexes
    consist of points (positions); color translate to shader through uniform;
    vertexes and indexes translate through VBO;
  }

  TColoredVertexes = class(TObjectVertexes)
  strict private
    ColorUniform: PShaderParametr;
    procedure BeforeDrawSetData({%H-}Item: TGraphicObject);
  private
    FColor: TColor4f;
  protected
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    procedure SetShader(const AShader: TBlackSharkShader); override;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
  end;

  {  }

  { TMultiColorVertexes
    the graphic item for every vertex contains its color }

  TMultiColorVertexes = class(TObjectVertexes)
  private
    procedure SetTypePrimitive(const Value: TTypePrimitive);
    function GetTypePrimitive: TTypePrimitive;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    class function CreateMesh: TMesh; override;
    function AddVertex(const APoint: TVec3f; const AColor: TVec3f): int32;
    procedure WriteColor(AIndexVertex: int32; const AColor: TVec3f); overload;
    procedure WriteColor(AIndexVertex: int32; const AColor: TVec4f); overload;
    procedure Build;
    property TypePrimitive: TTypePrimitive read GetTypePrimitive write SetTypePrimitive;
  end;

  { TComplexCurveObject

    The object can draw two models:
      - single color for all mesh vertexes; a vertex consists of point only (mesh type TMeshP);
      - own color for every mesh vertex (mesh type TMeshPCrgba);
  }

  TComplexCurveObject = class(TObjectVertexes)
  private
    FColor: TColor4f;
    FMultiColor: boolean;
    ColorUniform: PShaderParametr;
    StrokeLenUniform: PShaderParametr;
    FStrokeLength: BSFloat;
    procedure BeforeDraw({%H-}Item: TGraphicObject);
    procedure SetMultiColor(const Value: boolean);
    procedure SetStrokeLength(const Value: BSFloat);
  protected
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    procedure SetShader(const AShader: TBlackSharkShader); override;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    class function CreateMesh: TMesh; override;
    function AddVertex(const APoint: TVec3f): int32;
    procedure WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: BSFloat); overload;
    procedure WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec2f); overload;
    procedure WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec3f); overload;
    procedure WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec4f); overload;
    procedure Build;
    property MultiColor: boolean read FMultiColor write SetMultiColor;
    { if it is more 0 then the line has strokes }
    property StrokeLength: BSFloat read FStrokeLength write SetStrokeLength;
  end;

  TLayoutObject = class(TColoredVertexes)
  private
    FDrawOn: boolean;
    FLineThickness: BSFloat;
    FSize: TVec2f;
    FStep: BSfloat;
    FDrawedData: TMesh;
    procedure DrawLayout(Instance: PRendererGraphicInstance);
    procedure SetDrawOn(const Value: boolean);
    procedure SetLineThickness(const Value: BSFloat);
    procedure SetSize(const Value: TVec2f);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    destructor Destroy; override;
    procedure Build(ALoadToGpuAfter: boolean);
    procedure ChangedMesh; override;
    property DrawOn: boolean read FDrawOn write SetDrawOn;
    property LineThickness: BSFloat read FLineThickness write SetLineThickness;
    property Size: TVec2f read FSize write SetSize;
    property Step: BSfloat read FStep write FStep;
  end;

  { TColorPatettePlane }

  TColorPatettePlane = class(TMultiColorVertexes)
  private
    FSize: TVec2f;
    procedure SetSize(const Value: TVec2f);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    procedure Build;
    property Size: TVec2f read FSize write SetSize;
  end;

  { TGraphicObjectAxises }

  TGraphicObjectAxises = class (TGraphicObject)
  private
    FAxelX: TColoredVertexes;
    FAxelY: TColoredVertexes;
    FAxelZ: TColoredVertexes;
    function CreateArrow(const Color: TVec4f): TColoredVertexes;
    function GetSize: BSFloat;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    destructor Destroy; override;
    property Size: BSFloat read GetSize;
    property AxelX: TColoredVertexes read FAxelX;
    property AxelY: TColoredVertexes read FAxelY;
    property AxelZ: TColoredVertexes read FAxelZ;
  end;

  { TGraphicObjectLines }
  { the class draws lines;
    couple points defines one a snippet if thickness more 1 (OpenGL primitive GL_LINES);
   	It draws lines with different thickness by two triangles (quad) }

  TGraphicObjectLines = class(TColoredVertexes)
  private
    FLineWidth: BSFloat;
    FLineWidthHalf: BSFloat;
    UpdateCounter: int32;
    FCountLines: int32;
    FDrawByTriangleOnly: boolean;
    FCurrentPosition: TVec3f;
    procedure SetLineWidth(AValue: BSFloat);
    procedure SetDrawByTriangleOnly(const Value: boolean);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    procedure BeginUpdate;
    procedure EndUpdate(AInCenterAlign: boolean = true);
    procedure MoveTo(const v: TVec3f);
    procedure LineTo(const v: TVec3f);
    procedure Line(const v1, v2: TVec3f);
    procedure Clear; override;
    { Width drawing lines; it works only on desktop OpenGL, because OGL ES
      doesn't support with line > 1 }
    property LineWidth: BSFloat read FLineWidth write SetLineWidth;
    property CountLines: int32 read FCountLines;
    property DrawByTriangleOnly: boolean read FDrawByTriangleOnly write SetDrawByTriangleOnly;
  end;

  { TGraphicObjectBiColoredSolidLines }

  TGraphicObjectBiColoredSolidLines = class(TColoredVertexes)
  private
    FLineWidth: BSFloat;
    FLineWidthHalf: BSFloat;
    FCountLines: int32;
    FLineColor2: TColor4f;
    procedure BeforeDrawMethod({%H-}Item: TGraphicObject);
    procedure SetLineWidth(AValue: BSFloat);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    // draw double colored solid lines
    procedure Draw(AWidth: BSFloat; AHorizontal: boolean; ACount: int32);
    procedure Clear; override;
    class function CreateMesh: TMesh; override;
    { Width drawing lines; it works only on desktop OpenGL, because OGL ES
      doesn't support with line > 1 }
    property LineWidth: BSFloat read FLineWidth write SetLineWidth;
    property LineColor2: TColor4f read FLineColor2 write FLineColor2;
    property CountLines: int32 read FCountLines write FCountLines;
  end;

  { TGraphicObjectText }

  TGraphicObjectText = class(TObjectVertexes)
  private
    ColorUniform: PShaderParametr;
    SettedSize: boolean;
    FText: bs.strings.PString;
    Building: boolean;
    OnChangeFontSbscr: IBEmptyEventObserver;
    FTxtProcessor: TTextProcessor;
    FDiscardBlanks: boolean;
    OwnTextProcessor: boolean;
    OwnTextData: boolean;
    FOutToWidth: BSFloat;
    FOutToHeight: BSFloat;
    FOffsetX: BSFloat;
    FOffsetY: BSFloat;
    CounterChange: int32;
    FFont: IBlackSharkFont;
    FontText: TBlackSharkTexture;
    FontTextI: IBlackSharkTexture;
    FDefaultGlyph: string;
    FLineThickness: int32;
    FStrikethrough: boolean;
    FUnderline: boolean;
    FLines: TGraphicObjectLines;
    FFirstLinePosition: TVec3f;
    FColorLine: TColor4f;
    FAlign: TTextAlign;
    FIndexLastStringInViewport: int32;
    function SelectorKey(Index: int32; out Code: int32): PKeyInfo;
    procedure CalcBlankWidth;
    procedure SetText(const AValue: string);
    procedure CheckShaders;
    procedure CheckTextProcessor;
    procedure BeforeDraw({%H-}Item: TGraphicObject);
    procedure SetFont(const Value: IBlackSharkFont);
    function SelectStartPos(PropLine: PLineProp): BSFloat; inline;
    { select average width blank for oaClient align mode }
    function SelectBlankWidth(PropLine: PLineProp): BSFloat; inline;
    procedure OnChangeFontEvent({%H}const Value: BEmpty);
    procedure SetDiscardBlanks(const Value: boolean);
    procedure SetTxtProcessor(const Value: TTextProcessor);
    function GetText: string;
    procedure SetTextData(const Value: bs.strings.PString);
    function GetTxtProcessor: TTextProcessor;
    procedure SetOffsetX(const Value: BSFloat);
    procedure SetOutToWidth(const Value: BSFloat);
    procedure SetOffsetY(const Value: BSFloat);
    procedure SetOutToHeight(const Value: BSFloat);
    procedure SelectFontData;
    procedure SetStrikethrough(const Value: boolean);
    procedure SetUnderline(const Value: boolean);
    procedure AddLine(const APosition: TVec2f; AWidth: BSFloat); inline;
    procedure CalcLineThickness;
    procedure CreateLines;
    procedure SetColorLine(const Value: TColor4f);
    procedure UpdateTextProcessorLineHeight;
    procedure SetAlign(const Value: TTextAlign);
  protected
    FColor: TColor4f;
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    procedure SetShader(const AShader: TBlackSharkShader); override;
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    destructor Destroy; override;
    class function CreateMesh: TMesh; override;
    { method bulds mesh for out a text data }
    procedure Build;
    procedure BeginChangeProp;
    procedure EndChangeProp;

    property Text: string read GetText write SetText;
    property DefaultGlyph: string read FDefaultGlyph write FDefaultGlyph;
    property TextData: bs.strings.PString read FText write SetTextData;
    { calculator properties of lines and required size of space }
    property TxtProcessor: TTextProcessor read GetTxtProcessor write SetTxtProcessor;
    { drawed a font; assigned only outside }
    property Font: IBlackSharkFont read FFont write SetFont;
    { after build it defines which row from array of strings was showed
      (array of strings see in TxtProcessor property) }
    property IndexLastStringInViewport: int32 read FIndexLastStringInViewport;
    property DiscardBlanks: boolean read FDiscardBlanks write SetDiscardBlanks;
    { offset of vewport over text }
    property OffsetX: BSFloat read FOffsetX write SetOffsetX;
    property OffsetY: BSFloat read FOffsetY write SetOffsetY;
    { a maximal width of window for out text, pixels; default 0 - not limited }
    property OutToWidth: BSFloat read FOutToWidth write SetOutToWidth;
    { a maximal height of window for out text, pixels; default 0 - not limited }
    property OutToHeight: BSFloat read FOutToHeight write SetOutToHeight;
    property Strikethrough: boolean read FStrikethrough write SetStrikethrough;
    property Underline: boolean read FUnderline write SetUnderline;
    { color of Underline and Strikethrough }
    property ColorLine: TColor4f read FColorLine write SetColorLine;
    property Align: TTextAlign read FAlign write SetAlign;
  end;

  { TColoredVertexesOrTextured }

  TColoredVertexesOrTextured = class(TObjectVertexes)
  strict private
    procedure BeforeDrawSetData({%H-}Item: TGraphicObject);
  private
    FColor: TColor4f;
    FTexture: PTextureArea;
    FShaderNameSingleColor: string;
    FShaderNameTextured: string;
    procedure SetTexture(const Value: PTextureArea);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    property Color: TColor4f read FColor write FColor;
    property Texture: PTextureArea read FTexture write SetTexture;
    property ShaderNameSingleColored: string read FShaderNameSingleColor write FShaderNameSingleColor;
    property ShaderNameTextured: string read FShaderNameTextured write FShaderNameTextured;
  end;

  { TBoundingBoxVisualizer

      The class creates TGraphicObjectLines for out a BB contour; some methods accepts
      TGraphicObject for out him the BB contour, and by this is cause you
      must to free first this class, only then owners BB
  }

  TBoundingBoxVisualizer = class
  public
    type
      PPair = ^TPair;
      TPair = record
        BB: TBox3f;
        Lines: TGraphicObjectLines;
      end;
      TContBB = TListDual<PPair>;//TBinTreeTemplate<PBox3f, PPair>;
      TContNode = TContBB.PListItem;
  private
    Container: TContBB;
    FWidthLines: BSFloat;
    procedure Draw(Pair: PPair);
  protected
    FScene: TBScene;
  public
    constructor Create(AScene: TBScene);
    destructor Destroy; override;
    procedure Clear;
    function Add(BB: TGraphicObject; const Color: TColor4f): TContNode; overload;
    function Add(const BB: TBox3f; const Color: TColor4f): TContNode; overload;
    function Add(const BB: TBox3f; const Color: TColor4f; Parent: TGraphicObject): TContNode; overload;
    procedure Update(const BB: TBox3f; ContNode: TContNode); overload;
    procedure Update(BB: TGraphicObject; ContNode: TContNode); overload;
    procedure Remove(ContNode: TContNode);
    property WidthLines: BSFloat read FWidthLines write FWidthLines;
  end;

  TGraphicObjectFog = class(TObjectVertexes)
  strict private
    FStartTime: uint32;
    FSize: TVec2f;
    procedure BeforeDrawFog({%H-}Item: TGraphicObject);
  public
    constructor Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene); override;
    property Size: TVec2f read FSize write FSize;
  end;

 { return size pasted key to shape }

function AddKeyToShape(AKey: PKeyInfo; AMesh: TMesh;
  const APosition: TVec2f; AVectorText: boolean): TVec2f; overload; inline;

function AddKeyToShape(AKey: PKeyInfo; AMesh: TMesh;
  const APosition: TVec3f; AVectorText: boolean): TVec3f; overload; inline;

function AddQuadToShape(Mesh: TMesh; const Position: TVec3f; const SizeHalf: TVec2f): TVec3f; inline;

implementation

uses
  {$ifdef DEBUG_BS}
    bs.log,
  {$endif}
  {$ifndef fpc}
    System.Classes,
  {$endif}
    math
  , SysUtils
  , bs.config
  , bs.utils
  , bs.thread
  , bs.obj
  , bs.graphics
  ;

function AddKeyToShape(AKey: PKeyInfo; AMesh: TMesh; const APosition: TVec2f; AVectorText: boolean): TVec2f;
begin
  Result := TVec2f(AddKeyToShape(AKey, AMesh, vec3(APosition.x, APosition.y, 0.0), AVectorText));
end;

function AddKeyToShape(AKey: PKeyInfo; AMesh: TMesh; const APosition: TVec3f; AVectorText: boolean): TVec3f;
var
  j: int32;
  s_half: TVec2f;
  v, v_mod: TVec3f;
  pos: TVec2f;
begin
  Result := vec3(AKey^.Rect.Width, AKey^.Rect.Height, 0.0);
  s_half := TVec2f(Result * 0.5);
  pos := TVec2f(APosition + s_half);
  if AVectorText then
  begin
    for j := 0 to AKey^.Indexes.Count - 1 do
    begin
      v := AKey^.Glyph^.Points.Items[AKey^.Indexes.Items[j]];
      v.x := (v.x - AKey^.Glyph.xMin) - s_half.x;
      v.y := v.y - s_half.y;
      AMesh.Indexes.Add(AMesh.CountVertex);
      AMesh.AddVertex(vec3(v.x + pos.x, v.y + pos.y, APosition.z));
    end;
  end else
  begin
    for j := 0 to AKey^.Indexes.Count - 1 do
    begin
      v := AKey^.Glyph^.Points.Items[AKey^.Indexes.Items[j]];
      v_mod := v;
      v_mod.x := (v.x - AKey^.Glyph^.xMin) - s_half.x;
      v_mod.y := (v.y - AKey^.Glyph^.yMin) - s_half.y;
      v.x := v.x - s_half.x;

      v.y := v.y - s_half.y;
      AMesh.Indexes.Add(AMesh.CountVertex);
      AMesh.Write(
        AMesh.AddVertex(vec3(v.x + pos.x, v.y + pos.y, APosition.z)), vcTexture1,
          vec2(AKey^.UV.Left + (AKey^.UV.Width * (v_mod.x / Result.x + 0.5)),
               AKey^.UV.Top + AKey^.UV.Height * (0.5 - v_mod.y / Result.y))
          );
    end;
  end;
end;

function AddQuadToShape(Mesh: TMesh; const Position: TVec3f; const SizeHalf: TVec2f): TVec3f;
begin
  Mesh.Indexes.Add(Mesh.CountVertex);
  Mesh.Indexes.Add(Mesh.CountVertex + 1);
  Mesh.Indexes.Add(Mesh.CountVertex + 2);
  Mesh.Indexes.Add(Mesh.CountVertex + 1);
  Mesh.Indexes.Add(Mesh.CountVertex + 2);
  Mesh.Indexes.Add(Mesh.CountVertex + 3);
  Mesh.AddVertex(vec3(Position.x - SizeHalf.x, Position.y + SizeHalf.y, Position.z));
  Mesh.AddVertex(vec3(Position.x + SizeHalf.x, Position.y + SizeHalf.y, Position.z));
  Mesh.AddVertex(vec3(Position.x - SizeHalf.x, Position.y - SizeHalf.y, Position.z));
  Mesh.AddVertex(vec3(Position.x + SizeHalf.x, Position.y - SizeHalf.y, Position.z));
  Result := SizeHalf * 2;
end;

{ TObjectVertexes }

procedure TObjectVertexes.ChangedMesh;
begin
  inherited ChangedMesh;
  if StaticObject then
  begin
    if Assigned(FMesh) then
    begin
      // create VBO for all vertex components
      if (FMesh.CountVertex > 0) then
      begin
        CreateVBO(FVBO_Vertexes, GL_ARRAY_BUFFER, FMesh.VertexesData, FMesh.CountVertex * FMesh.SizeOfVertex);
        {$ifdef DEBUG_BS}
        //BSWriteMsg('TObjectVertexes.ChangedMesh after reload VBO_Vertexes "' + Caption +  '":', IntToStr(FVBO_Vertexes));
        {$endif}
      end;
      // create VBO for indexes
      if (FMesh.Indexes.Count > 0) then
      begin
        CreateVBO(FVBO_Indexes, GL_ELEMENT_ARRAY_BUFFER, FMesh.Indexes.ShiftData[0], FMesh.Indexes.Count * FMesh.Indexes.IndexSizeOf);
        {$ifdef DEBUG_BS}
        //BSWriteMsg('TObjectVertexes.ChangedMesh after reload VBO_Indexes "' + Caption +  '":', IntToStr(FVBO_Indexes));
        {$endif}
      end;

      {$ifndef ultibo}
      if SupportsVAO and (FVBO_Indexes > 0) then
      begin
        if (FVAO = 0) then
        begin
          glGenVertexArrays(1, @FVAO);
          if FVAO = 0 then
            SupportsVAO := false;
        end;

        if (FVAO > 0) then
        begin
          glBindVertexArray(FVAO);
          Shader.UseProgram(true);
          BindVBO;
          glBindVertexArray(0);
        end;
      end;
      {$endif}

      // Automticaly set visibility by depend at position Frustum
      if UpdateCount <= 0 then
        FScene.InstanceTransform(BaseInstance, true);

    end;
  end else
  begin
    if VBO_Vertexes > 0 then
    begin
      {$ifdef DEBUG_BS}
      //BSWriteMsg('TObjectVertexes.BeforeChangedMesh before reload VBO_Vertexes "' + Caption +  '":', IntToStr(FVBO_Vertexes));
      {$endif}
      glDeleteBuffers(1, @FVBO_Vertexes);
      FVBO_Vertexes := 0;
    end;

    if VBO_Indexes > 0 then
    begin
      {$ifdef DEBUG_BS}
      //BSWriteMsg('TObjectVertexes.BeforeChangedMesh before reload VBO_Indexes "' + Caption +  '":', IntToStr(FVBO_Indexes));
      {$endif}
      glDeleteBuffers(1, @FVBO_Indexes);
      FVBO_Indexes := 0;
    end;

    {$ifndef ultibo}
    if FVAO > 0 then
    begin
      glDeleteVertexArrays(1, @FVAO);
      FVAO := 0;
    end;
    {$endif}
  end;
end;

procedure TObjectVertexes.Clear;
begin
  inherited;
  if VBO_Indexes > 0 then
  begin
    glDeleteBuffers(1, @VBO_Indexes);
    FVBO_Indexes := 0;
  end;

  if VBO_Vertexes > 0 then
  begin
    glDeleteBuffers(1, @VBO_Vertexes);
    FVBO_Vertexes := 0;
  end;

  {$ifndef ultibo}
  if FVAO > 0 then
  begin
    glDeleteVertexArrays(1, @FVAO);
    FVAO := 0;
  end;
  {$endif}
end;

constructor TObjectVertexes.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  AddBeforeDrawMethod(BeforeDraw);
  DrawInstance := DrawVertexs;
  FMesh := CreateMesh;
end;

procedure TObjectVertexes.DrawVertexs(Instance: PRendererGraphicInstance);
begin
  if Assigned(MVPUniform) then
    glUniformMatrix4fv(MVPUniform.Location, 1, GL_FALSE, @Instance.LastMVP);

  if StaticObject then
  begin
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, VBO_Indexes );
    glDrawElements(FMesh.DrawingPrimitive, FMesh.Indexes.Count, FMesh.Indexes.Kind, nil);
  end else
  begin
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDrawElements(FMesh.DrawingPrimitive, FMesh.Indexes.Count, FMesh.Indexes.Kind, FMesh.Indexes.ShiftData[0]); 
  end;
end;

procedure TObjectVertexes.Restore;
begin
  inherited;
  FVBO_Vertexes := 0;
  FVBO_Indexes := 0;
  inc(UpdateCount);
  try
    ChangedMesh;
  finally
    dec(UpdateCount);
  end;
end;

procedure TObjectVertexes.SetShader(const AShader: TBlackSharkShader);
begin
  inherited;
  if Assigned(Shader) then
  begin
    OpacityUniform := Shader.Uniform['Opacity'];
    MVPUniform := Shader.Uniform['MVP'];
  end else
  begin
    OpacityUniform := nil;
    MVPUniform := nil;
  end;
end;

procedure TObjectVertexes.BindVBO;
var
  vc: TVertexComponent;
  i: int8;
begin
  if StaticObject then
  begin
    glBindBuffer(GL_ARRAY_BUFFER, VBO_Vertexes);
    for i := 0 to FMesh.ComponentsCount - 1 do
    begin
      vc := FMesh.Components[i];
      if FShader.VertexComponentLocations[vc] >= 0 then
        glVertexAttribPointer(
          FShader.VertexComponentLocations[vc], // attribute. No particular reason for 1, but must match the layout in the shader.
          FMesh.CountVarComponent[vc],          // size : U+V => 2
          FShader.VertexComponentTypes[vc],     // type
          GL_FALSE,                             // normalized?
          FMesh.SizeOFVertex,                   // stride
          {%H-}Pointer(FMesh.OffsetComponent[vc])   // array buffer offset
        );
    end;
  end else
  begin
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    for i := 0 to FMesh.ComponentsCount - 1 do
    begin
      vc := FMesh.Components[i];
      if FShader.VertexComponentLocations[vc] >= 0 then
        glVertexAttribPointer(
          FShader.VertexComponentLocations[vc], // attribute. No particular reason for 1, but must match the layout in the shader.
          FMesh.CountVarComponent[vc],          // size : U+V => 2
          FShader.VertexComponentTypes[vc],     // type
          GL_FALSE,                             // normalized?
          FMesh.SizeOFVertex,                   // stride
          {%H-}Pointer(FMesh.VertexesData + FMesh.OffsetComponent[vc])   // array buffer offset
        );
    end;
  end;
end;

procedure TObjectVertexes.BeforeDraw(Item: TGraphicObject);
begin
  {$ifndef ultibo}
  if FVAO > 0 then
  begin
    glBindVertexArray(FVAO)
  end else
  {$endif}
  begin
    BindVBO;
  end;
  if Assigned(OpacityUniform) then
    glUniform1f(OpacityUniform^.Location, Opacity);
end;

{ TBlackSharkTexturedGraphicItem }

procedure TTexturedVertexes.BeforeDrawSetData(Item: TGraphicObject);
begin
  if Assigned(FTexture) then
  begin
    BSTextureManager.UseTexture(RefTexture);
    {$ifdef DEBUG_BS}
    if CheckErrorGL('TBlackSharkRenderer.SetCurrentRenderingProgrammAndTexture - Texture.UseTexture', TTypeCheckError.tcNone,  -1) then
      exit;
    {$endif}
    //glUniform1i(TBlackSharkTextureOutShader(Shader).TexSampler.Location, 0);
    if Assigned(AreaUVUniform) then
      glUniform4fv(AreaUVUniform.Location, 1, @FTexture^.UV);
    if ReplaceColor and Assigned(HLSUniform) then
      glUniform3fv(HLSUniform^.Location, 1, @HLS);
  end;
end;

constructor TTexturedVertexes.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  AddBeforeDrawMethod(BeforeDrawSetData);
  Shader := BSShaderManager.Load(TBlackSharkTextureOutShader);
end;

class function TTexturedVertexes.CreateMesh: TMesh;
begin
  Result := TMeshPT.Create;
end;

destructor TTexturedVertexes.Destroy;
begin
  { it is single owner the texture - free its }
  RefTexture := nil;
  inherited;
end;

procedure TTexturedVertexes.SetColor(const Value: TColor4f);
begin
  inherited;
  HLS := RGBtoHLS(vec3(Value.x, Value.y, Value.z));
end;

procedure TTexturedVertexes.SetReplaceColor(const Value: boolean);
begin
  if ReplaceColor = Value then
    exit;
  FReplaceColor := Value;
  if FReplaceColor then
    Shader := BSShaderManager.Load('TextureReplaceColor', TBlackSharkTexToColorHLSShader)
  else
    Shader := BSShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader);
end;

procedure TTexturedVertexes.SetShader(const AShader: TBlackSharkShader);
begin
  inherited;
  if Assigned(Shader) then
  begin
    AreaUVUniform := Shader.Uniform['AreaUV'];
    HLSUniform := Shader.Uniform['HLS'];
  end else
  begin
    AreaUVUniform := nil;
    HLSUniform := nil;
  end;
end;

function TTexturedVertexes.GetColor: TColor4f;
begin
  if Assigned(FTexture) then
    Result := ColorByteToFloat(BSTextureManager.Color(FTexture))
  else
    Result := BS_CL_BLACK;
end;

procedure TTexturedVertexes.SetTexture(const Value: PTextureArea);
{var
  ch: TGraphicObject;
  i: int32;    }
begin
  if FTexture = Value then
    exit;

  FTexture := Value;

  if Assigned(FTexture) then
    RefTexture := FTexture.Texture
  else
    RefTexture := nil;

  {for i := 0 to ChildrenCount - 1 do
  begin
    ch := Child[i];
    if (ch is TTexturedVertexes) and (TTexturedVertexes(ch).Texture = nil) then
      TTexturedVertexes(ch).Texture := Value;
  end; }
end;

{ TColoredVertexes }

procedure TColoredVertexes.BeforeDrawSetData(Item: TGraphicObject);
begin
  if Assigned(ColorUniform) then
    glUniform4fv(ColorUniform^.Location, 1, @FColor);
end;

procedure TColoredVertexes.SetShader(const AShader: TBlackSharkShader);
begin
  inherited SetShader(AShader);
  if Assigned(Shader) then
  begin
    ColorUniform := Shader.Uniform['Color'];
  end else
  begin
    ColorUniform := nil;
  end;
end;

constructor TColoredVertexes.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  Shader := BSShaderManager.Load(TBlackSharkVectorToSingleColorShader);
  AddBeforeDrawMethod(BeforeDrawSetData);
  FColor := BS_CL_RED;
end;

function TColoredVertexes.GetColor: TColor4f;
begin
  Result := FColor;
end;

procedure TColoredVertexes.SetColor(const Value: TColor4f);
begin
  FColor := Value;
end;

{ TColoredVertexesOrTextured }

procedure TColoredVertexesOrTextured.BeforeDrawSetData(Item: TGraphicObject);
begin
  if FTexture <> nil then
  begin
    BSTextureManager.UseTexture(FTexture.Texture);
    glUniform4fv( TBlackSharkTextureOutShader(Shader).AreaUV^.Location, 1, @FTexture^.UV );
  end else
    glUniform4fv( TBlackSharkTexToColorShader(Shader).Color^.Location, 1, @FColor );
end;

constructor TColoredVertexesOrTextured.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  FShaderNameSingleColor := 'SingleColor';
  FShaderNameTextured := 'SimpleTexture';
  //FMeshClass := TMeshP;
  AddBeforeDrawMethod(BeforeDrawSetData);
  FColor := BS_CL_RED;
end;

procedure TColoredVertexesOrTextured.SetTexture(const Value: PTextureArea);
begin
  if FTexture = Value then
    exit;
  FTexture := Value;
  if Assigned(FTexture) then
    Shader := BSShaderManager.Load(FShaderNameTextured, TBlackSharkVectorToSingleColorShader)
  else
    Shader := BSShaderManager.Load(FShaderNameSingleColor, TBlackSharkVectorToSingleColorShader);
end;

{ TGraphicObjectLines }

procedure TGraphicObjectLines.BeginUpdate;
begin
  inc(UpdateCounter);
end;

procedure TGraphicObjectLines.SetDrawByTriangleOnly(const Value: boolean);
begin
  FDrawByTriangleOnly := Value;
  if (FLineWidth > 1.0) or FDrawByTriangleOnly then
    FMesh.TypePrimitive := tpTriangles
  else
    FMesh.TypePrimitive := tpLines;
end;

procedure TGraphicObjectLines.SetLineWidth(AValue: BSFloat);
begin
  if FLineWidth = AValue then Exit;
  FLineWidth := AValue;
  if FLineWidth < 1.0 then
    FLineWidth := 1.0;
  FLineWidthHalf := FLineWidth * 0.5;
  if (FLineWidth > 1.0) or FDrawByTriangleOnly then
    FMesh.TypePrimitive := tpTriangles
  else
    FMesh.TypePrimitive := tpLines;
end;

procedure TGraphicObjectLines.Clear;
begin
  inherited;
  FCountLines := 0;
end;

constructor TGraphicObjectLines.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  if FMesh = nil then
    FMesh := TBlackSharkFactoryShapesP.CreateShape;
  FMesh.TypePrimitive := tpLines;
  FLineWidth := 1.0;
  FLineWidthHalf := FLineWidth * 0.5;
end;

procedure TGraphicObjectLines.EndUpdate(AInCenterAlign: boolean = true);
begin
  dec(UpdateCounter);
  if UpdateCounter <= 0 then
  begin
    FMesh.CalcBoundingBox(AInCenterAlign);
    ChangedMesh;
  end;
end;

procedure TGraphicObjectLines.Line(const v1, v2: TVec3f);
begin
  if (FLineWidth > 1.0) or FDrawByTriangleOnly then
  begin
    GenerateLine2d(Mesh, v1, v2, FLineWidth, false, false);
  end else
  begin
    FMesh.Indexes.Add(FMesh.CountVertex);
    FMesh.AddVertex(v1);
    FMesh.Indexes.Add(FMesh.CountVertex);
    FMesh.AddVertex(v2);
  end;
  inc(FCountLines);
  Position := v2;
end;

procedure TGraphicObjectLines.LineTo(const v: TVec3f);
begin
  Line(FCurrentPosition, v);
end;

procedure TGraphicObjectLines.MoveTo(const v: TVec3f);
begin
  FCurrentPosition := v;
end;

{ TGraphicObjectText }

procedure TGraphicObjectText.AddLine(const APosition: TVec2f; AWidth: BSFloat);
begin
//  if FFont.IsVectoral then
//  begin
//    AddQuadToShape(Mesh, vec3(APosition.x + AWidth*0.5, APosition.y, 0.0), vec2(AWidth*0.5, FLineThickness*0.5));
//  end else
  begin
    if FLines.CountLines = 0 then
      FFirstLinePosition := APosition;
    FLines.LineWidth := FLineThickness;
    FLines.Line(vec3(APosition.x, APosition.y, 0.0), vec3((APosition.x + AWidth), APosition.y, 0.0));
  end;
end;

procedure TGraphicObjectText.BeforeDraw(Item: TGraphicObject);
begin
  if not FFont.IsVectoral then
    BSTextureManager.UseTexture(FontText);
  if Assigned(ColorUniform) then
    glUniform4fv( ColorUniform^.Location, 1, @FColor );
end;

constructor TGraphicObjectText.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  Color := BS_CL_BLACK;
  FColorLine := BS_CL_GREEN;
  SettedSize := false;
  FDiscardBlanks := true;
  AddBeforeDrawMethod(BeforeDraw);
  { default shader }
  Shader := BSShaderManager.Load(TTextFromTextureShader);
end;

procedure TGraphicObjectText.CreateLines;
begin
  FLines := TGraphicObjectLines.Create(nil, Self, Scene);
  FLines.ServiceScale := BSConfig.VoxelSize;
  FLines.Interactive := false;
  FLines.Color := FColorLine;
end;

class function TGraphicObjectText.CreateMesh: TMesh;
begin
  { default create textured mesh }
  Result := TMeshPT.Create;
end;

destructor TGraphicObjectText.Destroy;
begin
  FontText := nil;
  FFont := nil;
  OnChangeFontSbscr := nil;
  FLines.Free;
  if OwnTextProcessor then
    FTxtProcessor.Free;
  if Assigned(FText) and OwnTextData then
    dispose(FText);
  inherited;
end;

procedure TGraphicObjectText.EndChangeProp;
begin
  dec(CounterChange);
  if CounterChange = 0 then
    Build;
end;

function TGraphicObjectText.GetColor: TColor4f;
begin
  Result := FColor;
end;

function TGraphicObjectText.GetText: string;
begin
  if FText <> nil then
    Result := FText^
  else
    Result := '';
end;

function TGraphicObjectText.GetTxtProcessor: TTextProcessor;
begin
  if FTxtProcessor = nil then
  begin
    OwnTextProcessor := true;
    FTxtProcessor := TTextProcessor.Create(SelectorKey);
  end;
  Result := FTxtProcessor;
end;

procedure TGraphicObjectText.OnChangeFontEvent({%H}const Value: BEmpty);
begin
  CalcLineThickness;
  SelectFontData;
  CalcBlankWidth;
  Build;
end;

function TGraphicObjectText.SelectBlankWidth(PropLine: PLineProp): BSFloat;
var
  c_b: int32;
begin

  if FDiscardBlanks then
    c_b := PropLine.InsideBlanks
  else
    c_b := PropLine.CountBlanks;

  if c_b = 0 then
    exit(0.0);

  if (FOutToWidth > 0) then
  begin
    if FDiscardBlanks then
      Result := FTxtProcessor.BlankWidth + trunc((FOutToWidth - PropLine.TrimWidth) / c_b)
    else
      Result := FTxtProcessor.BlankWidth + trunc((FOutToWidth - PropLine.Width) / c_b)
  end else
  if FDiscardBlanks then
    Result := FTxtProcessor.BlankWidth + trunc((FTxtProcessor.Width - PropLine.TrimWidth) / c_b)
  else
    Result := FTxtProcessor.BlankWidth + trunc((FTxtProcessor.Width - PropLine.Width) / c_b);

end;

procedure TGraphicObjectText.SelectFontData;
begin
  FontText := nil;

  if FFont = nil then
    exit;

  CheckShaders;

  if Assigned(FTxtProcessor) then
    UpdateTextProcessorLineHeight;

  if FFont.IsVectoral then
  begin
    FontTextI := nil;
  end else
  begin
    FontTextI := FFont.Texture.Texture;
    FontText := FFont.Texture.Texture as TBlackSharkTexture;
  end;
end;

function TGraphicObjectText.SelectorKey(Index: int32; out Code: int32): PKeyInfo;
begin
  if (FFont = nil) or (FText = nil) then
  begin
    Code := 0;
    exit(nil);
  end;
  Code := int32(FText.CharsUnsafeW(Index));
  Result := FFont.Key[Code];
end;

function TGraphicObjectText.SelectStartPos(PropLine: PLineProp): BSFloat;
var
  wl: BSFloat;
begin

  case FAlign of
    TTextAlign.taCenter, TTextAlign.taRight: begin

      if FDiscardBlanks then
        wl := PropLine.Width - (PropLine.CountBlanks - PropLine.InsideBlanks) * FTxtProcessor.BlankWidth
      else
        wl := PropLine.Width;

      if FOutToWidth > FTxtProcessor.Width then
        Result := (FOutToWidth - wl)
      else
        Result := (FTxtProcessor.Width - wl);

      if FAlign = TTextAlign.taCenter then
        Result := Result * 0.5;
    end;
    TTextAlign.taClient: begin
//      if PropLine.IsParagraphBeginning then // remain first blanks if the line is beginning of a paragraph
//        Result := (PropLine.CountBlanks - PropLine.InsideBlanks - PropLine.EndBlanks) * FTxtProcessor.BlankWidth
//      else
        Result := 0.0;
    end else
      Result := 0.0;
  end;
end;

procedure TGraphicObjectText.SetAlign(const Value: TTextAlign);
begin
  if FAlign = Value then
    exit;
  FAlign := Value;
  Build;
end;

procedure TGraphicObjectText.SetColor(const Value: TColor4f);
begin
  inherited;
  FColor := Value;
end;

procedure TGraphicObjectText.SetColorLine(const Value: TColor4f);
begin
  FColorLine := Value;
  if Assigned(FLines) then
    FLines.Color := FColorLine;
end;

procedure TGraphicObjectText.CheckShaders;
begin
  if FFont.IsVectoral then
  begin
    if Shader.Name <> TBlackSharkVectorToSingleColorShader.DefaultName then
    begin
      if Assigned(Mesh) then
        Mesh.Free;
      Mesh := TMeshP.Create;
      Mesh.TypePrimitive := tpTriangles;
      Shader := BSShaderManager.Load(TBlackSharkVectorToSingleColorShader);
    end;
  end else
  if Shader.Name <> TTextFromTextureShader.DefaultName then
  begin
    if Assigned(Mesh) then
      Mesh.Free;
    Mesh := TMeshPT.Create;
    Mesh.TypePrimitive := tpTriangles;
    Shader := BSShaderManager.Load(TTextFromTextureShader);
  end;
end;

procedure TGraphicObjectText.CheckTextProcessor;
begin
  if FTxtProcessor = nil then
  begin
    FTxtProcessor := TTextProcessor.Create(SelectorKey);
    UpdateTextProcessorLineHeight;
    CalcLineThickness;
    OwnTextProcessor := true;
  end;
end;

procedure TGraphicObjectText.SetDiscardBlanks(const Value: boolean);
begin
  FDiscardBlanks := Value;
  Build;
end;

procedure TGraphicObjectText.SetFont(const Value: IBlackSharkFont);
begin
  OnChangeFontSbscr := nil;
  FFont := Value;
  FontText := nil;
  if Assigned(FFont) then
    OnChangeFontSbscr := CreateEmptyObserver(FFont.OnChangeEvent, OnChangeFontEvent);
  SelectFontData;
  CheckTextProcessor;
  CalcBlankWidth;
  Build;
end;

procedure TGraphicObjectText.SetOffsetX(const Value: BSFloat);
begin
  FOffsetX := Value;
  Build;
end;

procedure TGraphicObjectText.SetOffsetY(const Value: BSFloat);
begin
  FOffsetY := Value;
  Build;
end;

procedure TGraphicObjectText.SetOutToHeight(const Value: BSFloat);
begin
  FOutToHeight := Value;
  //FTxtProcessor.ViewportSize := vec2(FTxtProcessor.ViewportSize.Width, Value);
  Build;
end;

procedure TGraphicObjectText.SetOutToWidth(const Value: BSFloat);
begin
  FOutToWidth := Value;
  //FTxtProcessor.ViewportSize := vec2(Value, FTxtProcessor.ViewportSize.Height);
  Build;
end;

procedure TGraphicObjectText.SetShader(const AShader: TBlackSharkShader);
begin
  inherited;
  if Assigned(Shader) then
  begin
    ColorUniform := Shader.Uniform['Color'];
  end else
  begin
    ColorUniform := nil;
  end;
end;

procedure TGraphicObjectText.SetStrikethrough(const Value: boolean);
begin
  if FStrikethrough = Value then
    exit;
  FStrikethrough := Value;
  if FStrikethrough then
  begin
    if not Assigned(FLines) then
      CreateLines;
  end else
  if not FUnderline and Assigned(FLines) then
    FreeAndNil(FLines);
end;

procedure TGraphicObjectText.CalcBlankWidth;
var
  k: PKeyInfo;
begin
  if Assigned(FFont) then
  begin
    k := FFont.Key[$20];
    if Assigned(k) then
      FTxtProcessor.BlankWidth := k.Rect.Width + FTxtProcessor.Delta
    else
      FTxtProcessor.BlankWidth := FFont.AverageWidth * 0.5 + FTxtProcessor.Delta;
  end else
    FTxtProcessor.BlankWidth := 7;
end;

procedure TGraphicObjectText.CalcLineThickness;
begin
  FLineThickness := round(FFont.Size / 8);
  if FLineThickness < 1 then
    FLineThickness := 1;
end;

procedure TGraphicObjectText.BeginChangeProp;
begin
  inc(CounterChange);
end;

procedure TGraphicObjectText.Build;
var
  KeyInfo: PKeyInfo;
  x, y: BSfloat;
  ch: WideChar;
  w_average: BSFloat;
  h_parent: BSFloat;
  w_parent: BSFloat;
  chars: int32;
  len_str: int32;
  char_index: int32;
  LineProp: PLineProp;
  off_left: BSFloat;
  firstCharOffset: BSFloat;
  print_chars: int32;
  countPrintChars: int32;
  start_x: BSFloat;
  offsetItalic: int32;
  firstEmptyStrings: int32;
  fullLineHeight: BSFloat;
  k: int8;
begin

  if CounterChange <> 0 then
    exit;

  FIndexLastStringInViewport := 0;

  Mesh.Clear;
  if Assigned(FLines) then
    FLines.Clear;


  if (FText = nil) or (FText.Len = 0) or (FTxtProcessor = nil) then
  begin
    if not Mesh.FBoundingBox.IsPoint then
    begin
      Mesh.CalcBoundingBox(true);
      ChangedMesh;
    end;
    exit;
  end;

  if Building then
    exit;

  Building := true;

  FTxtProcessor.CountChars := FText.Len;

  FFont.BeginSelectChars;
  try

    off_left := FOffsetX;

    if (FOutToWidth > 0) then
      w_parent := off_left + FOutToWidth
    else
      w_parent := 0; //BSConfig.VoxelSize * FTxtProcessor.Width;

    if (FOutToHeight > 0) then
      h_parent := FOffsetY + FOutToHeight
    else
      h_parent := FTxtProcessor.Height;

    if (FTxtProcessor.Lines.Count = 0) or (h_parent < FTxtProcessor.LineHeight) then
      exit;

    FIndexLastStringInViewport := FTxtProcessor.GetIndexLineFromOffsetY(FOffsetY);
    if FIndexLastStringInViewport < 0 then
      exit;

    fullLineHeight := FTxtProcessor.LineHeight + FTxtProcessor.Interligne;

    y := (FIndexLastStringInViewport + 1) * fullLineHeight;

    LineProp := FTxtProcessor.Lines.ShiftData[FIndexLastStringInViewport];
    x := SelectStartPos(LineProp);

    if (FAlign = TTextAlign.taClient) and (FTxtProcessor.Lines.Count - FIndexLastStringInViewport > 1) then
      w_average := SelectBlankWidth(LineProp)
    else
      w_average := FTxtProcessor.BlankWidth;

    char_index := LineProp.IndexBegin;
    len_str := FText.Len - char_index + 1;
    chars := 0;
    print_chars := 0;
    start_x := 0;
    firstEmptyStrings := 0;
    countPrintChars := 0;

    if Assigned(FLines) then
      FLines.BeginUpdate;

    offsetItalic := round(FFont.SizeInPixels*FFont.ItalicWeight);
    firstCharOffset := 0;

    { an adjusted empty shape for a right align on parent if will be not typed symbols }
    AddQuadToShape(Mesh, vec3(0.0, h_parent, 0.0), vec2(0.0, 0.0));

    while len_str > 0 do
    begin

      inc(chars);
      if (chars > LineProp.CountChars) or ((w_parent > 0) and (x >= w_parent)) then
      begin
        if (print_chars > 0) then
        begin
          print_chars := 0;

          if FStrikethrough then
            AddLine(vec2(start_x + firstCharOffset, Floor(- y - fullLineHeight*0.5)), x - start_x - firstCharOffset);

          if FUnderline then
            AddLine(vec2(start_x + firstCharOffset, Floor(- y - fullLineHeight + FLineThickness)), x - start_x - firstCharOffset);

        end else
        if countPrintChars = 0 then
        begin
          inc(firstEmptyStrings);
        end;

        y := y + fullLineHeight;
        inc(FIndexLastStringInViewport);
        chars := 1;
        firstCharOffset := 0;

        if (FIndexLastStringInViewport >= FTxtProcessor.Lines.Count) or (y > h_parent) then
          break;

        LineProp := FTxtProcessor.Lines.ShiftData[FIndexLastStringInViewport];
        dec(len_str, LineProp.IndexBegin - char_index);
        char_index := LineProp.IndexBegin;
        start_x := SelectStartPos(LineProp);
        x := start_x;
        if (FAlign = TTextAlign.taClient) and (FTxtProcessor.Lines.Count - FIndexLastStringInViewport > 1) then
          w_average := SelectBlankWidth(LineProp)
        else
          w_average := FTxtProcessor.BlankWidth;  // last line
      end;

      ch := FText.CharsUnsafeW(char_index);

      dec(len_str);
      inc(char_index);

      if (ch = #$0d) or (ch = #$0a) then
        continue;

      KeyInfo := FFont.KeyByWideChar[ch];

      if (ch = #$09) or (ch = #$20) or (KeyInfo = nil) or (KeyInfo.Indexes.Count = 0) then
      begin

        if (ch = #$09) then
          k := 2
        else
          k := 1;

        if (print_chars = 0) then
        begin
          if FAlign = TTextAlign.taClient then
          begin
            if FIndexLastStringInViewport = 0 then
              x := x + FTxtProcessor.BlankWidth * k;
            continue;
          end;
        end;
        x := x + w_average * k;
        continue;
      end else
      if (ch = #0) then
        continue;

      if off_left - (x + KeyInfo.Rect.Width) >= 1.0 then
      begin
        x := x + FTxtProcessor.Delta + KeyInfo.Rect.Width;
        continue;
      end;

      if print_chars = 0 then
        firstCharOffset := x - off_left;

      if FFont.Italic then
        x := x + FTxtProcessor.Delta + AddKeyToShape(KeyInfo, Mesh, vec2(x - off_left, h_parent - y), FFont.IsVectoral).x - offsetItalic
      else
        x := x + FTxtProcessor.Delta + AddKeyToShape(KeyInfo, Mesh, vec2(x - off_left, h_parent - y), FFont.IsVectoral).x;

      inc(print_chars);
      inc(countPrintChars);
    end;

    if (print_chars > 0) then
    begin
      if FStrikethrough then
        AddLine(vec2(start_x + firstCharOffset, Floor(- y - fullLineHeight*0.5)), x - start_x - firstCharOffset);

      if FUnderline then
        AddLine(vec2(start_x + firstCharOffset, Floor(- y - fullLineHeight + FLineThickness)), x - start_x - firstCharOffset);  // - FTxtProcessor.LineHeight*0.5
    end;

    if Assigned(FLines) then
    begin
      FLines.EndUpdate(true);
      if FUnderline then
      begin
        if FStrikethrough then
          FLines.Position := vec3(0.0,  (- firstEmptyStrings*fullLineHeight*0.5 - fullLineHeight*0.15 - FLineThickness*2)*BSConfig.VoxelSize, 0.0)
        else
          FLines.Position := vec3(0.0,  ((- firstEmptyStrings*fullLineHeight - fullLineHeight)*0.5 - FLineThickness)*BSConfig.VoxelSize, 0.0);
      end else
        // TODO: y-position set by font metric -(xheight * 0.5)
        FLines.Position := vec3(0.0,   round(-fullLineHeight*0.15)*BSConfig.VoxelSize, 0.0);
    end;

  finally
    { do not change the next strings places to avoid repeated of build }
    FFont.EndSelectChars;
    Building := false;
    Mesh.CalcBoundingBox(true);
    ChangedMesh;
  end;

end;

procedure TGraphicObjectText.SetText(const AValue: string);
begin
  if not Assigned(FText) then
  begin
    OwnTextData := true;
    new(FText);
  end;

  if FText^ = AValue then
    exit;

  CheckTextProcessor;

  FText^ := AValue;
  Build;
end;

procedure TGraphicObjectText.SetTextData(const Value: bs.strings.PString);
begin
  if FText = Value then
    exit;
  FText := Value;
  CheckTextProcessor;
  FTxtProcessor.CountChars := FText.Len;
end;

procedure TGraphicObjectText.SetTxtProcessor(const Value: TTextProcessor);
begin
  if FTxtProcessor = Value then
    exit;

  if OwnTextProcessor then
    FTxtProcessor.Free;

  OwnTextProcessor := false;
  FTxtProcessor := Value;

  if Assigned(FTxtProcessor) then
  begin
    FTxtProcessor.OnQueryKey := SelectorKey;
    UpdateTextProcessorLineHeight;
  end;
end;

procedure TGraphicObjectText.SetUnderline(const Value: boolean);
begin
  if FUnderline = Value then
    exit;
  FUnderline := Value;
  if FUnderline then
  begin
    if not Assigned(FLines) then
      CreateLines;
  end else
  if not FStrikethrough and Assigned(FLines) then
    FreeAndNil(FLines);
end;

procedure TGraphicObjectText.UpdateTextProcessorLineHeight;
begin
  if not Assigned(FFont) then
    exit;
  FTxtProcessor.LineHeight := FFont.SizeInPixels;
  FTxtProcessor.Interligne := round(FFont.SizeInPixels*0.2);
  if FTxtProcessor.Interligne < 1 then
    FTxtProcessor.Interligne := 1;
end;

{ TGraphicObjectAxises }

constructor TGraphicObjectAxises.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  { X }
  FAxelX := CreateArrow(BS_CL_RED);
  FAxelX.Angle := vec3(0.0, 0.0, 90.0);
  { Y }
  FAxelY := CreateArrow(BS_CL_GREEN);
  { Z }
  FAxelZ := CreateArrow(BS_CL_BLUE);
  FAxelZ.Angle := vec3(-90.0, 0.0, 0.0);
end;

function TGraphicObjectAxises.CreateArrow(const Color: TVec4f): TColoredVertexes;
const
  HEIGHT_ARROW = 1000;
  HEIGHT_CON = 36;
var
  con: TColoredVertexes;
begin
  Result := TColoredVertexes.Create(Self, Self, Scene);
  TBlackSharkFactoryShapesP.GenerateCylinder(Result.Mesh, 2, 10, HEIGHT_ARROW, false, false);
  Result.Color := Color;
  Result.Interactive := false;
  //Result.ChangedMesh();
  Result.ServiceScale := BSConfig.VoxelSize;
  con := TColoredVertexes.Create(Self, Result, Scene);
  TBlackSharkFactoryShapesP.GenerateCone(con.Mesh, 10, 6, HEIGHT_CON, false);
  con.Position := vec3(0.0, BSConfig.VoxelSize*(HEIGHT_ARROW + HEIGHT_CON)*0.5, 0.0);
  con.Color := Color;
  con.Interactive := false;
  //con.ChangedMesh;
  con.ServiceScale := BSConfig.VoxelSize;
end;

destructor TGraphicObjectAxises.Destroy;
begin
  { so as it does in a parental destructor, therefor skip release the axises }
  // FAxelX.Free;
  // FAxelY.Free;
  // FAxelZ.Free;
  inherited;
end;

function TGraphicObjectAxises.GetSize: BSFloat;
begin
  Result := FAxelY.FMesh.FBoundingBox.y_max*2;
end;

{ TBoundingBoxVisualizer }

function TBoundingBoxVisualizer.Add(BB: TGraphicObject; const Color: TColor4f): TContNode;
var
  p: PPair;
begin
  new(p);
  p.BB := BB.BaseInstance.BoundingBox;
  p.Lines := TGraphicObjectLines.Create(Self, BB, BB.Scene);
  p.Lines.StaticObject := false;
  p.Lines.LineWidth := FWidthLines;
  p.Lines.Color := Color;
  Result := Container.PushToEnd(p);
  Draw(p);
end;

function TBoundingBoxVisualizer.Add(const BB: TBox3f; const Color: TColor4f): TContNode;
begin
  Result := Add(BB, Color, nil);
end;

function TBoundingBoxVisualizer.Add(const BB: TBox3f; const Color: TColor4f;
  Parent: TGraphicObject): TContNode;
var
  p: PPair;
begin
  new(p);
  p.BB := BB;
  p.Lines := TGraphicObjectLines.Create(Self, Parent, FScene);
  p.Lines.StaticObject := false;
  p.Lines.LineWidth := FWidthLines;
  p.Lines.Color := Color;
  Result := Container.PushToEnd(p);
  Draw(p);
end;

procedure TBoundingBoxVisualizer.Clear;
var
  p: TContBB.PListItem;
begin
  p := Container.ItemListFirst;
  while Assigned(p) do
  begin
    p.Item.Lines.Free;
    dispose(p.Item);
    p := p.Next;
  end;
  Container.Clear;
end;

constructor TBoundingBoxVisualizer.Create(AScene: TBScene);
begin
  Container := TContBB.Create;
  FWidthLines := 1;
  FScene := AScene;
end;

destructor TBoundingBoxVisualizer.Destroy;
begin
  Clear;
  Container.Destroy;
  inherited;
end;

procedure TBoundingBoxVisualizer.Draw(Pair: PPair);
var
  bb: PBox3f;

  procedure FillZ;
  begin
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMin]),
    vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMin]),
    vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMin]),
    vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMin]),
    vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMax]));
  end;

  procedure FillZMax;
  begin
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMax]),
    vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMax]),
    vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMax]),
    vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMax]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMax]),
    vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMax]));
  end;

  procedure FillZMin;
  begin
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMin]),
    vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMin]));
  Pair.Lines.Line(vec3(bb^.Named[xMin], bb^.Named[yMax], bb^.Named[zMin]),
    vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMin]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMax], bb^.Named[zMin]),
    vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMin]));
  Pair.Lines.Line(vec3(bb^.Named[xMax], bb^.Named[yMin], bb^.Named[zMin]),
    vec3(bb^.Named[xMin], bb^.Named[yMin], bb^.Named[zMin]));
  end;

var
  _bb: TBox3f;
begin
  Pair.Lines.Clear;
  Pair.Lines.BeginUpdate;
  _bb.Max := Pair.BB.Max + 1.0;
  _bb.Min := Pair.BB.Min + (-1.0);

  if Pair.BB.z_max - Pair.BB.z_min = 0 then
  begin
    _bb.Max.z := 0.0;
    _bb.Min.z := 0.0;
  end;

  if Pair.BB.y_max - Pair.BB.y_min = 0 then
  begin
    _bb.Max.y := 0.0;
    _bb.Min.y := 0.0;
  end;

  if Pair.BB.x_max - Pair.BB.x_min = 0 then
  begin
    _bb.Max.x := 0.0;
    _bb.Min.x := 0.0;
  end;

  bb := @_bb;
  FillZMax;
  if (Pair.BB.z_max <> 0) then
    FillZMin;
  FillZ;
  Pair.Lines.EndUpdate(true);
  if Pair.Lines.Parent = nil then
    Pair.Lines.Position := Pair.BB.Middle;
  if Pair.Lines.Hidden then
    Pair.Lines.Hidden := false;
end;

procedure TBoundingBoxVisualizer.Remove(ContNode: TContNode);
begin
  ContNode.Item.Lines.Free;
  dispose(ContNode.Item);
  Container.Remove(ContNode);
end;

procedure TBoundingBoxVisualizer.Update(const BB: TBox3f; ContNode: TContNode);
begin
  ContNode.Item.BB := BB;
  Draw(ContNode.Item);
end;

procedure TBoundingBoxVisualizer.Update(BB: TGraphicObject; ContNode: TContNode);
begin
  ContNode.Item.BB := BB.BaseInstance.BoundingBox;
  Draw(ContNode.Item);
end;

{ TGraphicObjectFog }

procedure TGraphicObjectFog.BeforeDrawFog(Item: TGraphicObject);
begin

  glUniform1f( TBlackSharkFogOutShader(Shader).Time^.Location, (TBTimer.CurrentTime.Low - FStartTime)/1000 );
  glUniform2f ( TBlackSharkFogOutShader(FShader).Resolution^.Location, FSize.x, FSize.y);

  { enforce to update the timer in order to off idle of an application }
  TBTimer.UpdateTimer(TTimeProcessEvent.TimeProcessEvent);
end;

constructor TGraphicObjectFog.Create(AOwner: TObject; AParent: TGraphicObject;
  AScene: TBScene);
begin
  inherited;
  FStartTime := TBTimer.CurrentTime.Low;
  AddBeforeDrawMethod(BeforeDrawFog);
  Shader := BSShaderManager.Load(TBlackSharkFogOutShader);
end;

{ TColorPatettePlane }

procedure TColorPatettePlane.Build;
var
  one_part: BSFloat;
  one_third, one_third_half: int32;
  i: int32;
  final_color: TVec3f;
  k, d: BSFloat;
begin
  if FSize.Width < 12 then
    exit;
  one_part := FSize.Width  / FSize.Width;
  one_third := round(FSize.Width / 3);
  one_third_half := one_third shr 1;
  d := 1/one_third_half;
  FMesh.Clear;

  k := 0.0;
  for i := 0 to one_third - 1 do
  begin
    FMesh.AddVertex(vec3(one_part*i, 0.0, 0.0));
    FMesh.AddVertex(vec3(one_part*i, FSize.Height, 0.0));
    if i < one_third_half then
    begin
      final_color := vec3(1.0, k, 0.0);
      k := k + d;
    end else
    begin
      final_color := vec3(k, 1.0, 0.0);
      k := k - d;
    end;


    FMesh.Write(i shl 1, vcColor, final_color);
    FMesh.Write((i shl 1)+1, vcColor, vec3(0.5, 0.5, 0.5));
    FMesh.Indexes.Add(i*2);
    FMesh.Indexes.Add(i*2+1);
  end;

  k := 0.0;
  for i := one_third to one_third shl 1 - 1 do
  begin
    FMesh.AddVertex(vec3(one_part*i, 0.0, 0.0));
    FMesh.AddVertex(vec3(one_part*i, FSize.Height, 0.0));
    if i - one_third < one_third_half then
    begin
      final_color := vec3(0.0, 1.0, k);
      k := k + d;
    end else
    begin
      final_color := vec3(0.0, k, 1.0);
      k := k - d;
    end;

    FMesh.Write(i shl 1, vcColor, final_color);
    FMesh.Write((i shl 1)+1, vcColor, vec3(0.5, 0.5, 0.5));
    FMesh.Indexes.Add(i shl 1);
    FMesh.Indexes.Add((i shl 1)+1);
  end;

  k := 0.0;
  for i := one_third shl 1 to one_third*3 do
  begin
    FMesh.AddVertex(vec3(one_part*i, 0.0, 0.0));
    FMesh.AddVertex(vec3(one_part*i, FSize.Height, 0.0));
    if i - one_third shl 1 < one_third_half then
    begin
      final_color := vec3(k, 0.0, 1.0);
      k := k + d;
    end else
    begin
      final_color := vec3(1.0, 0.0, k);
      k := k - d;
    end;

    FMesh.Write(i shl 1, vcColor, final_color);
    FMesh.Write((i shl 1)+1, vcColor, vec3(0.5, 0.5, 0.5));
    FMesh.Indexes.Add(i shl 1);
    FMesh.Indexes.Add((i shl 1)+1);
  end;

  FMesh.CalcBoundingBox(true);
  ChangedMesh;
end;

constructor TColorPatettePlane.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  Mesh.TypePrimitive := tpTriangleStrip;
end;

procedure TColorPatettePlane.SetSize(const Value: TVec2f);
begin
  FSize := Value;
  Build;
end;

{ TGraphicObjectBiColoredSolidLines }

procedure TGraphicObjectBiColoredSolidLines.BeforeDrawMethod(Item: TGraphicObject);
begin
  glUniform4fv( TBlackSharkVectorToDoubleColorShader(Shader).Color2^.Location, 1, @FLineColor2 );
end;

procedure TGraphicObjectBiColoredSolidLines.Clear;
begin
  inherited;
  FCountLines := 0;
end;

constructor TGraphicObjectBiColoredSolidLines.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  FLineWidth := 1.0;
  FLineWidthHalf := FLineWidth * 0.5;
  FLineColor2 := BS_CL_BLUE;
  FMesh.TypePrimitive := tpLines;
  Shader := BSShaderManager.Load(TBlackSharkVectorToDoubleColorShader);
  AddBeforeDrawMethod(BeforeDrawMethod);
end;

class function TGraphicObjectBiColoredSolidLines.CreateMesh: TMesh;
begin
  Result := TMeshPI.Create;
end;

procedure TGraphicObjectBiColoredSolidLines.Draw(AWidth: BSFloat; AHorizontal: boolean; ACount: int32);
var
  i: Integer;
  v1, v2: TVec3f;
  step_x, step_y: BSFloat;
  col_1: BSFloat;
  h_x, h_y: BSFloat;
begin
  Clear;
  if AHorizontal then
  begin
    v1 := vec3(AWidth, FLineWidthHalf, 0.0);
    v2 := vec3(0.0, FLineWidthHalf, 0.0);
    step_x := 0.0;
    step_y := FLineWidth;
    h_y := FLineWidthHalf;
    h_x := 0.0;
  end else
  begin
    v1 := vec3(FLineWidthHalf, AWidth, 0.0);
    v2 := vec3(FLineWidthHalf, 0.0, 0.0);
    step_x := FLineWidth;
    step_y := 0.0;
    h_x := FLineWidthHalf;
    h_y := 0.0;
  end;

  FCountLines := ACount;
  for i := ACount - 1 downto 0 do
  begin
    col_1 := IfThen(i and 1 > 0, 1.0, 0.0);
    if FLineWidth > 1.0 then
    begin

      FMesh.AddVertex(vec4(v1.x + h_x, v1.y + h_y, 0.0, col_1));  // -4
      FMesh.AddVertex(vec4(v1.x - h_x, v1.y - h_y, 0.0, col_1));  // -3
      FMesh.AddVertex(vec4(v2.x + h_x, v2.y + h_y, 0.0, col_1));  // -2
      FMesh.AddVertex(vec4(v2.x - h_x, v2.y - h_y, 0.0, col_1));  // -1

      FMesh.Indexes.Add(FMesh.CountVertex - 4);
      FMesh.Indexes.Add(FMesh.CountVertex - 3);
      FMesh.Indexes.Add(FMesh.CountVertex - 2);
      FMesh.Indexes.Add(FMesh.CountVertex - 2);
      FMesh.Indexes.Add(FMesh.CountVertex - 3);
      FMesh.Indexes.Add(FMesh.CountVertex - 1);

    end else
    begin

      FMesh.Indexes.Add(FMesh.CountVertex);
      FMesh.AddVertex(vec4(v1, col_1));
      FMesh.Indexes.Add(FMesh.CountVertex);
      FMesh.AddVertex(vec4(v2, col_1));

    end;
    v1 := vec3(v1.x + step_x, v1.y + step_y, 0);
    v2 := vec3(v2.x + step_x, v2.y + step_y, 0);
  end;

  FMesh.CalcBoundingBox(true);
  ChangedMesh;
end;

procedure TGraphicObjectBiColoredSolidLines.SetLineWidth(AValue: BSFloat);
begin
  if FLineWidth = AValue then
    Exit;

  FLineWidth := AValue;
  if FLineWidth < 1.0 then
    FLineWidth := 1.0;

  FLineWidthHalf := FLineWidth * 0.5;

  if FLineWidth > 1.0 then
    FMesh.TypePrimitive := tpTriangles
  else
    FMesh.TypePrimitive := tpLines;
end;

{ TMultiColorVertexes }

function TMultiColorVertexes.AddVertex(const APoint, AColor: TVec3f): int32;
begin
  Result := FMesh.CountVertex;
  FMesh.Indexes.Add(Result);
  FMesh.AddVertex(APoint);
  FMesh.Write(Result, TVertexComponent.vcColor, AColor);
end;

procedure TMultiColorVertexes.Build;
begin
  FMesh.CalcBoundingBox(true);
  ChangedMesh;
end;

constructor TMultiColorVertexes.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  Shader := BSShaderManager.Load(TBlackSharkColorSelectorShader);
end;

class function TMultiColorVertexes.CreateMesh: TMesh;
begin
  Result := TMeshPC.Create;
end;

function TMultiColorVertexes.GetTypePrimitive: TTypePrimitive;
begin
  Result := Mesh.TypePrimitive;
end;

procedure TMultiColorVertexes.SetTypePrimitive(const Value: TTypePrimitive);
begin
  Mesh.TypePrimitive := Value;
  end;

procedure TMultiColorVertexes.WriteColor(AIndexVertex: int32; const AColor: TVec4f);
begin
  Mesh.Write(AIndexVertex, TVertexComponent.vcColor, vec3(AColor.x, AColor.y, AColor.z));
end;

procedure TMultiColorVertexes.WriteColor(AIndexVertex: int32; const AColor: TVec3f);
begin
  Mesh.Write(AIndexVertex, TVertexComponent.vcColor, AColor);
end;

{ TLayoutObject }

procedure TLayoutObject.Build(ALoadToGpuAfter: boolean);
var
  i: int32;
begin
  Mesh.Clear;
  FDrawedData.Clear;
  TBlackSharkFactoryShapesP.GeneratePlane(Mesh, vec2(FSize.Width, FSize.Height));

  for i := 0 to round(FSize.x / FStep) - 1 do
  begin
    if i mod 2 > 0 then
      continue;
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FStep*i, 0.0, 0.0));
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FStep*(i+1), 0.0, 0.0));
  end;

  for i := 0 to round(FSize.y / FStep) - 1 do
  begin
    if i mod 2 > 0 then
      continue;
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FSize.x, FStep*i, 0.0));
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FSize.x, FStep*(i+1), 0.0));
  end;

  for i := 0 to round(FSize.x / FStep) - 1 do
  begin
    if i mod 2 > 0 then
      continue;
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FStep*i, FSize.y, 0.0));
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(FStep*(i+1), FSize.y, 0.0));
  end;

  for i := 0 to round(FSize.y / FStep) - 1 do
  begin
    if i mod 2 > 0 then
      continue;
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(0.0, FStep*i, 0.0));
    FDrawedData.Indexes.Add(FDrawedData.CountVertex);
    FDrawedData.AddVertex(vec3(0.0, FStep*(i+1), 0.0));
  end;

  FDrawedData.CalcBoundingBox(true);
  if StaticObject and ALoadToGpuAfter then
    ChangedMesh
end;

procedure TLayoutObject.ChangedMesh;
begin

  if StaticObject then
  begin
    // create VBO for all vertex components
    if (FDrawedData.CountVertex > 0) then
      CreateVBO(FVBO_Vertexes, GL_ARRAY_BUFFER, FDrawedData.VertexesData, FDrawedData.CountVertex * FDrawedData.SizeOFVertex);
    // create VBO for indexes
    if (FDrawedData.Indexes.Count > 0) then
      CreateVBO(FVBO_Indexes, GL_ELEMENT_ARRAY_BUFFER, FDrawedData.Indexes.ShiftData[0], FDrawedData.Indexes.Count * FDrawedData.Indexes.IndexSizeOf);
    // Automticaly set visibility by depend at position Frustum
    if UpdateCount <= 0 then
      FScene.InstanceTransform(BaseInstance, true);
  end else
  begin
  if VBO_Vertexes > 0 then
  begin
    glDeleteBuffers(1, @FVBO_Vertexes);
    FVBO_Vertexes := 0;
  end;

  if VBO_Indexes > 0 then
  begin
    glDeleteBuffers(1, @FVBO_Indexes);
    FVBO_Indexes := 0;
  end;
  end;
end;

constructor TLayoutObject.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited Create(AOwner, AParent, AScene);
  FDrawedData := TMeshP.Create;

  FLineThickness := 2;
  FStep := 5;
  FDrawOn := true;
  Color := BS_CL_GRAY;
  ClearBeforeDrawListMethods;
  DrawInstance := DrawLayout;
  Shader := BSShaderManager.Load(TBlackSharkLayoutShader);
  FDrawedData.TypePrimitive := tpLines;
end;

destructor TLayoutObject.Destroy;
begin
  FDrawedData.Free;
  inherited;
end;

procedure TLayoutObject.DrawLayout(Instance: PRendererGraphicInstance);
begin
  glUniformMatrix4fv (TBlackSharkLayoutShader(Shader).MVP.Location, 1, GL_FALSE, @Instance.LastMVP );
  glUniform4fv( TBlackSharkLayoutShader(Shader).Color^.Location, 1, @FColor );
  if StaticObject then
  begin
    glBindBuffer ( GL_ARRAY_BUFFER, VBO_Vertexes );
      if FShader.VertexComponentLocations[vcCoordinate] >= 0 then
        glVertexAttribPointer(
          FShader.VertexComponentLocations[vcCoordinate], // attribute. No particular reason for 1, but must match the layout in the shader.
          FDrawedData.CountVarComponent[vcCoordinate],          // size : U+V => 2
          FShader.VertexComponentTypes[vcCoordinate],     // type
          GL_FALSE,                             // normalized?
          FDrawedData.SizeOFVertex,                   // stride
          {%H-}Pointer(FDrawedData.OffsetComponent[vcCoordinate])   // array buffer offset
        );
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, VBO_Indexes);
    glDrawElements(FDrawedData.DrawingPrimitive, FDrawedData.Indexes.Count, FDrawedData.Indexes.Kind, nil);
  end else
  begin
    glBindBuffer ( GL_ARRAY_BUFFER, 0 );
    glVertexAttribPointer(
      FShader.VertexComponentLocations[vcCoordinate], // attribute. No particular reason for 1, but must match the layout in the shader.
      FDrawedData.CountVarComponent[vcCoordinate],          // size : U+V => 2
      FShader.VertexComponentTypes[vcCoordinate],     // type
      GL_FALSE,                             // normalized?
      FDrawedData.SizeOFVertex,                   // stride
      {%H-}Pointer(FMesh.VertexesData + FDrawedData.OffsetComponent[vcCoordinate])   // array buffer offset
    );
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDrawElements(FDrawedData.DrawingPrimitive , FDrawedData.Indexes.Count, FDrawedData.Indexes.Kind, FDrawedData.Indexes.ShiftData[0]);
  end;

  {$ifndef ultibo}
  if VAO > 0 then
    glBindVertexArray(GL_NONE);
  {$endif}
end;

procedure TLayoutObject.SetDrawOn(const Value: boolean);
begin
  if FDrawOn = Value then
    exit;
  FDrawOn := Value;
  if FDrawOn then
    DrawInstance := DrawLayout
  else
    DrawInstance := nil;
end;

procedure TLayoutObject.SetLineThickness(const Value: BSFloat);
begin
  FLineThickness := Value;
end;

procedure TLayoutObject.SetSize(const Value: TVec2f);
begin
  FSize := Value;
end;

{ TComplexCurveObject }

procedure TComplexCurveObject.BeforeDraw(Item: TGraphicObject);
begin
  if Assigned(ColorUniform) then
    glUniform4fv(ColorUniform^.Location, 1, @FColor);
  if Assigned(StrokeLenUniform) then
    glUniform1fv(StrokeLenUniform^.Location, 1, @FStrokeLength);
end;

function TComplexCurveObject.AddVertex(const APoint: TVec3f): int32;
begin
  Result := FMesh.CountVertex;
  FMesh.Indexes.Add(Result);
  FMesh.AddVertex(APoint);
  //FMesh.Write(Result, TVertexComponent.vcColor, AColor);
end;

procedure TComplexCurveObject.Build;
begin
  FMesh.CalcBoundingBox(true);
  ChangedMesh;
end;

constructor TComplexCurveObject.Create(AOwner: TObject; AParent: TGraphicObject; AScene: TBScene);
begin
  inherited;
  Shader := BSShaderManager.Load(TBlackSharkVectorToSingleColorShader);
  AddBeforeDrawMethod(BeforeDraw);
  FColor := BS_CL_RED;
end;

class function TComplexCurveObject.CreateMesh: TMesh;
begin
  Result := TMeshLine.Create;
end;

function TComplexCurveObject.GetColor: TColor4f;
begin
  Result := FColor;
end;

procedure TComplexCurveObject.SetColor(const Value: TColor4f);
begin
  inherited;
  FColor := Value;
end;

procedure TComplexCurveObject.SetMultiColor(const Value: boolean);
var
  m, old: TMesh;
begin
  if FMultiColor = Value then
    exit;

  old := Mesh;

  FMultiColor := Value;

  if FMultiColor then
  begin
    m := TMeshLineMultiColored.Create;
    Shader := BSShaderManager.Load(TBlackSharkStrokeCurveMulticoloredShader);
  end else
  begin
    m := TMeshLine.Create;
    Shader := BSShaderManager.Load(TBlackSharkStrokeCurveSingleColorShader);
  end;

  m.CopyMesh(Mesh);

  Mesh := m;

  old.Free;
end;

procedure TComplexCurveObject.SetShader(const AShader: TBlackSharkShader);
begin
  inherited;
  if Assigned(Shader) then
  begin
    ColorUniform := Shader.Uniform['Color'];
    StrokeLenUniform := Shader.Uniform['StrokeLen'];
  end else
  begin
    ColorUniform := nil;
    StrokeLenUniform := nil;
  end;
end;

procedure TComplexCurveObject.SetStrokeLength(const Value: BSFloat);
begin
  if FStrokeLength = Value then
    exit;
  FStrokeLength := Value;
  MultiColor := Value > 0.0;
end;

procedure TComplexCurveObject.WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec2f);
begin
  Mesh.Write(AIndexVertex, AVertexComponent, AValue);
end;

procedure TComplexCurveObject.WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec3f);
begin
  Mesh.Write(AIndexVertex, AVertexComponent, AValue);
end;

procedure TComplexCurveObject.WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: TVec4f);
begin
  Mesh.Write(AIndexVertex, AVertexComponent, AValue);
end;

procedure TComplexCurveObject.WriteComponent(AIndexVertex: int32; AVertexComponent: TVertexComponent; const AValue: BSFloat);
begin
  Mesh.Write(AIndexVertex, AVertexComponent, AValue);
end;

end.
