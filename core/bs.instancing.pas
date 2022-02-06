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


unit bs.instancing;

{$I BlackSharkCfg.inc}

interface

uses
  {$ifndef fpc}
    math ,
  {$endif}
    bs.basetypes
  , bs.gl.es
  , bs.collections
  , bs.renderer
  , bs.scene
  , bs.scene.objects
  , bs.texture
  , bs.shader
  , bs.mesh
  , bs.mesh.primitives
  , bs.canvas
  ;

type

  TInstance = record
    Scale: BSFloat;
    Opacity: BSFloat;
    Angle: TVec3f;
    Position: TVec3f;
    Color: TColor4f;
    IsVisible: boolean;
  end;
  PInstance = ^TInstance;

  { TBlackSharkInstancing
    The class implements Draw one mesh many times with different Position, Angle,
    and so on... For evry instance invoke glDrawElements, so to fail in try
    used pure instancing in GLES20... may be in future...
  	TODO: implement pure instancing (glDrawElementsInstanced) }

  TBlackSharkInstancing = class
  private
    FRenderer: TBlackSharkRenderer;
    FPrototype: TObjectVertexes;
    FCountInstance: int32;
    Instances: TListVec<TInstance>;
    //{$ifdef GLES20}
    Matrix: TListVec<TMatrix4f>;
    //{$else}
    //mvpVBO: GLuint;
    //{$endif}
    GIMethodDefault: TDrawInstanceMethod;
    UpdateCounter: int32;
    ProtoRendererInstance: PRendererGraphicInstance;
    ColorUniform: PShaderParametr;
    procedure GenMatrix(AIndex: int32); inline;
    procedure UpadateAllMatrix;
    procedure DrawProto(Inst: PRendererGraphicInstance);
    function GetAngle(AIndex: int32): TVec3f;
    function GetOpacity(AIndex: int32): BSFloat;
    function GetPosition(AIndex: int32): TVec3f;
    function GetScale(AIndex: int32): BSFloat;
    procedure SetAngle(AIndex: int32; const Value: TVec3f);
    procedure SetOpacity(AIndex: int32; const Value: BSFloat);
    procedure SetPosition(AIndex: int32; const Value: TVec3f);
    procedure SetScale(AIndex: int32; const Value: BSFloat);
    function GetColor(AIndex: int32): TColor4f;
    procedure SetColor(AIndex: int32; const Value: TColor4f);
  protected
    procedure SetPrototype(const Value: TObjectVertexes); virtual;
    procedure SetCountInstance(const Value: int32); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; APrototype: TObjectVertexes);
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Remove(AIndex: int32);
    property Prototype: TObjectVertexes read FPrototype write SetPrototype;
    property CountInstance: int32 read FCountInstance write SetCountInstance;
    property Opacity[index: int32]: BSFloat read GetOpacity write SetOpacity;
    property Scale[index: int32]: BSFloat read GetScale write SetScale;
    property Angle[index: int32]: TVec3f read GetAngle write SetAngle;
    property Position[index: int32]: TVec3f read GetPosition write SetPosition;
    property Color[index: int32]: TColor4f read GetColor write SetColor;
  end;

  TBlackSharkInstancing2d = class(TBlackSharkInstancing)
  private
    PrototypeCanvasObject: TCanvasObject;
    FPostions2d: TListVec<TVec2f>;
    function GetPosition2d(AIndex: int32): TVec2f;
    procedure SetPosition2d(AIndex: int32; const AValue: TVec2f);
  public
    constructor Create(ARenderer: TBlackSharkRenderer; APrototype: TCanvasObject);
    destructor Destroy; override;
    property Position2d[index: int32]: TVec2f read GetPosition2d write SetPosition2d;
  end;

  TBlackSharkParticleShader = class(TBlackSharkShader)
  private
    { input uniforms }
    FMVP: PShaderParametr;
    //FOpacity: PShaderParametr;
    //FScale: PShaderParametr;
    { input variables }
    FPosition: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input uniforms }
    property MVP: PShaderParametr read FMVP;
    { input variables }
    property Position: PShaderParametr read FPosition;
    //property Opacity: PShaderParametr read FOpacity;
    //property Scale: PShaderParametr read FScale;
  end;

  { The shader out many texture regions with original color }

  TBlackSharkParticleMultiUVTextureShader = class(TBlackSharkParticleShader)
  private
    FUV: PShaderParametr;
    FTexSampler: PShaderParametr;
    FDelta: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input uniforms }
    property TexSampler: PShaderParametr read FTexSampler;
    { input variables }
    property UV: PShaderParametr read FUV;
    property Delta: PShaderParametr read FDelta;
  end;

  { The shader out filed all texture regions by different colors }

  TBlackSharkParticleMultiUVAndColorShader = class(TBlackSharkParticleMultiUVTextureShader)
  private
    FUVColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input variables }
    property Color: PShaderParametr read FUVColor;
  end;

  { The shader out filed all texture regions by single a color }

  TBlackSharkParticleMultiUVAndSingleColorShader = class(TBlackSharkParticleMultiUVTextureShader)
  private
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input variables }
    property Color: PShaderParametr read FColor;
  end;

  { Shader replaces a color texture through HLS (hue, lightness (intensity), saturation) parameters }

  TBlackSharkParticleMultiUVAndReplaceColorShader = class(TBlackSharkParticleMultiUVTextureShader)
  private
    //FUVColor: PShaderParametr;
    FHLS: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input uniforms }
    //property UVColor: PShaderParametr read FUVColor;
    property HLS: PShaderParametr read FHLS;
  end;

  TBlackSharkParticlePointShader = class(TBlackSharkParticleShader)
  private
    { input variable }
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input variable }
    property Color: PShaderParametr read FColor;
  end;

  TBlackSharkParticlePointShaderSingleColor = class(TBlackSharkParticleShader)
  private
    { uniform variable }
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    { input variable }
    property Color: PShaderParametr read FColor;
  end;

  { TODO: GLES 3.0 - Particle System using Transform Feedback }


  { TBlackSharkParticles
  	Implements drawing many textured particles by single call glDrawElements
    for all patricles; the every particle is a quad from a texture if property
    TBlackSharkParticles<T>.IsPoints seted in false, otherwise as points;


  }

  TBlackSharkParticles<T> = class
  public
    type

      PParticle = ^TParticle;
      TParticle = record
        Position: TVec4f;
        {$ifdef GLES30}
        {$else}
        //Position: TVec4f;
        {$endif}
        Data: T;
      end;

      PParticleArray = ^TParticleArray;
      TParticleArray = array[0..$FFFFFF] of TParticle;
      TListParticles = TListVec<TParticle>;

      TDefaultGraphicObject = class (TGraphicObject)
      public
        procedure AfterConstruction; override;
        class function CreateMesh: TMesh; override;
      end;

  private
    const
      // max draw for one time (), in realy, not limited
      MAX_COUNT_PARTICLE = 65536;
      {%H-}MAX_COUNT_PARTICLE_ONE_OF_FOUR = MAX_COUNT_PARTICLE div 4;
    type
      TListDistances = TListVec<BSFloat>;
  private
    FRenderer: TBlackSharkRenderer;
    FCountParticle: int32;
    FParticles: TListParticles;
    FIsPoints: boolean;
    OwnProto: boolean;
    Distances: TListDistances;
    DistancesData: TListDistances.PArrayOfT;
    ParticlesData: TListParticles.PArrayOfT;
    FTexture: PTextureArea;
    FTextureHolder: IBlackSharkTexture;
    procedure SetCapacity(const Value: int32);
    function GetCapacity: int32;
    procedure DoSort(L, R: int32);
    procedure FillBaseQuad;
  protected
    { size a texture in 3d relative center of rect }
    Quad: array[0..3] of TVec3f;
    { uv poitns the texture  }
    UV: array[0..3] of TVec2f;
    FParticlePrototype: TGraphicObject;
    Shader: TBlackSharkParticleShader;
    Indexes: TListVec1s;
    procedure SetCountParticle(const Value: int32); virtual;
    procedure SetParticlePrototype(const Value: TGraphicObject); virtual;
    procedure SetPosition(index: int32; const Value: TVec3f); virtual;
    function GetPosition(AIndex: int32): TVec3f; virtual;
    function CreateShader: TBlackSharkParticleShader; virtual; abstract;
    procedure SetTexture(const Value: PTextureArea); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject); virtual;
    destructor Destroy; override;
    { a sort need for correct draw particles: farther away from a screen - draws
      first }
    procedure Sort;
    procedure Clear; virtual;
    procedure Remove(AIndex: int32); virtual;
    property ParticleBox: TGraphicObject read FParticlePrototype;
    property CountParticle: int32 read FCountParticle write SetCountParticle;
    property Capacity: int32 read GetCapacity write SetCapacity;
    { The source of images for particles; assigned from out ! The calss doesn't
      watch for the time of live ! }
    property Texture: PTextureArea read FTexture write SetTexture;
    { properties every a particle }
    property Position[index: int32]: TVec3f read GetPosition write SetPosition;
  end;


  TEmptyProp = record

  end;

  TParticlesSingleUV = class(TBlackSharkParticles<TEmptyProp>)
  private
    const
      VSH = '// uniforms' + #$0d + #$0a +
            'uniform vec2 uv[4];' + #$0d + #$0a +
            //'uniform vec3 quad[4];' + #$0d + #$0a +
            'uniform mat4 MVP;' + #$0d + #$0a +
            '// input attributes' + #$0d + #$0a +
            'attribute vec4 a_position;' + #$0d + #$0a +
            //'attribute byte a_index;' + #$0d + #$0a +
            '//attribute float a_opacity;' + #$0d + #$0a +
            '//attribute float a_scale;' + #$0d + #$0a +
            '// out parameters' + #$0d + #$0a +
            'varying vec2 v_texCoord;' + #$0d + #$0a +
            '//varying float v_opacity;' + #$0d + #$0a +

            'void main()' + #$0d + #$0a +
            '{' + #$0d + #$0a +
              'int i = int(a_position.a);' + #$0d + #$0a +
	            'gl_Position = MVP*vec4(a_position.xyz, 1.0);// + quad[a_index]' + #$0d + #$0a +
	            'v_texCoord = uv[i];' + #$0d + #$0a +
            '}';

      FSH = 'precision mediump float;' + #$0d + #$0a +
            '// uniforms' + #$0d + #$0a +
            'uniform sampler2D s_texture;' + #$0d + #$0a +
            '// input color variables' + #$0d + #$0a +
            'varying vec2 v_texCoord;' + #$0d + #$0a +
            '//varying float v_opacity;' + #$0d + #$0a +

            'void main()' + #$0d + #$0a +
            '{' + #$0d + #$0a +
	            'gl_FragColor = texture2D( s_texture, v_texCoord );' + #$0d + #$0a +
	            '//gl_FragColor.a = gl_FragColor.a * v_opacity;' + #$0d + #$0a +
            '}';

    type

      { TBlackSharkVertexOutShader }

      TParticleShader = class(TBlackSharkParticleShader)
      private
        { input uniforms }
        FUV: PShaderParametr;
        //FQuad: PShaderParametr;
        FTexSampler: PShaderParametr;
      public
        constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
        { input uniforms }
        property UV: PShaderParametr read FUV;
        //property Quad: PShaderParametr read FQuad;
        property TexSampler: PShaderParametr read FTexSampler;
      end;

  strict private
    procedure DrawProto(Instance: PRendererGraphicInstance);
  protected
    //procedure SetPosition(index: int32; const Value: TVec3f); override;
    function CreateShader: TBlackSharkParticleShader; override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject); override;
    destructor Destroy; override;
    procedure Change({%H-}Index: int32; const Postion: TVec3f);
  end;

  { TParticlesMultiUV
    to attributes vertexes add UV (texture) coordinate,
    that is for every particle may use different texture coordinates; for example,
    usefull for out a text, or 2d scene with many units placed in single texture
    (often called as "atlas"); the colors save original from texture }

  TParticlesMultiUV = class(TBlackSharkParticles<TVec2f>)
  private
    const
      VSH = 'uniform mat4 MVP;' + #$0d + #$0a +
            '// input attributes' + #$0d + #$0a +
            'attribute vec4 a_position;' + #$0d + #$0a +
            'attribute vec2 a_uv_position;' + #$0d + #$0a +
            '// out parameters' + #$0d + #$0a +
            'varying vec2 v_texCoord;' + #$0d + #$0a +

            'void main()' + #$0d + #$0a +
            '{' + #$0d + #$0a +
	            'gl_Position = MVP*vec4(a_position.xyz, 1.0);' + #$0d + #$0a +
	            'v_texCoord = a_uv_position;' + #$0d + #$0a +
            '}';

      FSH = 'precision mediump float;' + #$0d + #$0a +
            '// uniforms' + #$0d + #$0a +
            'uniform sampler2D s_texture;' + #$0d + #$0a +
            '// input color variables' + #$0d + #$0a +
            'varying vec2 v_texCoord;' + #$0d + #$0a +
            '//varying float v_opacity;' + #$0d + #$0a +

            'void main()' + #$0d + #$0a +
            '{' + #$0d + #$0a +
	            'gl_FragColor = texture2D( s_texture, v_texCoord );' + #$0d + #$0a +
	            '//gl_FragColor.a = gl_FragColor.a * v_opacity;' + #$0d + #$0a +
            '}';

    type

      { TParticlesShader }

      TParticlesShader = class(TBlackSharkParticleShader)
      private
        { input uniforms }
        //FUV: PShaderParametr;
        //FQuad: PShaderParametr;
        FTexSampler: PShaderParametr;
        FUVPosition: PShaderParametr;
      public
        constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
        { input uniforms }
        //property UV: PShaderParametr read FUV;
        //property Quad: PShaderParametr read FQuad;
        property TexSampler: PShaderParametr read FTexSampler;
        property UVPosition: PShaderParametr read FUVPosition;
      end;

  strict private
    procedure DrawProto(Instance: PRendererGraphicInstance);
  private
    function GetPositionUV(AIndex: int32): TVec2f;
    procedure SetPositionUV(index: int32; const Value: TVec2f);
    //function GetSizeUV: TVec2f;
    //procedure SetSizeUV(const Value: TVec2f);
    function GetRect(AIndex: int32): TRectBSF;
    procedure SetRect(index: int32; const Value: TRectBSF);
  protected
    function GetPosition(AIndex: int32): TVec3f; override;
    procedure SetPosition(index: int32; const Value: TVec3f); override;
    function CreateShader: TBlackSharkParticleShader; override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject); override;
    destructor Destroy; override;
    procedure Change(Index: int32; const Postion: TVec3f; const Rect: TTextureRect);
    { position UV areas on texture }
    property PositionUV[index: int32]: TVec2f read GetPositionUV write SetPositionUV;
    property Rect[index: int32]: TRectBSF read GetRect write SetRect;
    //property SizeUV: TVec2f read GetSizeUV write SetSizeUV;
  end;

  {
    TParticlesMultiUVSingleColor

    all particles draws a single color; from the texture takes only the alpha }

  TParticlesMultiUVSingleColor = class(TParticlesMultiUV)
  protected
    const
      FSH_Col = 'precision mediump float;' + #$0d + #$0a +
            '// uniforms' + #$0d + #$0a +
            'uniform sampler2D s_texture;' + #$0d + #$0a +
            '// color ' + #$0d + #$0a +
            'uniform vec3 color;' + #$0d + #$0a +
            'varying vec2 v_texCoord;' + #$0d + #$0a +

            'void main()' + #$0d + #$0a +
            '{' + #$0d + #$0a +
	            'vec4 col = texture2D( s_texture, v_texCoord );' + #$0d + #$0a +
	            'gl_FragColor = vec4(color, col.a);' + #$0d + #$0a +
            '}';

    type

      { TParticlesShader }

      TParticlesShader = class(TBlackSharkParticleShader)
      private
        { input uniforms }
        FColor: PShaderParametr;
        //FQuad: PShaderParametr;
        FTexSampler: PShaderParametr;
        FUVPosition: PShaderParametr;
      public
        constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
        { input uniforms }
        property Color: PShaderParametr read FColor;
        //property Quad: PShaderParametr read FQuad;
        property TexSampler: PShaderParametr read FTexSampler;
        property UVPosition: PShaderParametr read FUVPosition;
      end;

  strict private
    procedure DrawProto(Instance: PRendererGraphicInstance);
  private
    FColor: TVec4f;
    HLS: TVec3f;
  protected
    TranslateColorAsHLS: boolean;
    function CreateShader: TBlackSharkParticleShader; override;
    procedure SetColor(const Value: TVec4f); virtual;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject); override;
    property Color: TVec4f read FColor write SetColor;
    { if ReplaceColor = true then texture color replace by help HLS parameters;
      else texture color with alpha > 0 seted from DefaultColor }
    //property ReplaceColor: boolean read FReplaceColor write SetReplaceColor;
  end;

  {
    TParticlesMultiUVSingleColor

    Draws particles a single color but, the color from texture replaces by HLS
    on Color;
    TODO: it doesn't work

    }

  TParticlesMultiUVReplaceSingleColor = class(TParticlesMultiUVSingleColor)
  private
    const
      FSH_COL_REP =
        'precision mediump float;' + #$0d + #$0a +
        'uniform sampler2D s_texture;' + #$0d + #$0a +
        'uniform vec3 color; //HLS ' + #$0d + #$0a +
        'varying vec2 v_texCoord;' + #$0d + #$0a +
        '//varying float v_opacity;' + #$0d + #$0a +

        'const float HLSMAX = 0.9411764;' + #$0d + #$0a +

        'float HueToRGB(float hue, float p, float q)' + #$0d + #$0a +
        '{' + #$0d + #$0a +
        '  float h;' + #$0d + #$0a +
        '  if (hue < 0.0)' + #$0d + #$0a +
        '    h = hue + HLSMAX; else' + #$0d + #$0a +
        '  if (hue > HLSMAX)' + #$0d + #$0a +
        '    h = hue - HLSMAX; else' + #$0d + #$0a +
        '	   h = hue;' + #$0d + #$0a +
        '  if (h < 0.166666*HLSMAX) // 1/6' + #$0d + #$0a +
        '    return (p + ((q-p)*6.0*h*HLSMAX)); else' + #$0d + #$0a +
        '  if (h < 0.5*HLSMAX)' + #$0d + #$0a +
        '    return q; else' + #$0d + #$0a +
        '  if (h < 0.666666*HLSMAX) // 2/3' + #$0d + #$0a +
        '    return (p + ((q-p)*6.0*HLSMAX*(0.666666*HLSMAX-h)));' + #$0d + #$0a +
        '  return p;' + #$0d + #$0a +
        '}' + #$0d + #$0a +

        'vec3 HLStoRGB(vec3 HLS)' + #$0d + #$0a +
        '{' + #$0d + #$0a +
        '  if (HLS.z == 0.0)' + #$0d + #$0a +
        '  {' + #$0d + #$0a +
        '    // gray scale' + #$0d + #$0a +
        '    return vec3(HLS.y, HLS.y, HLS.y);' + #$0d + #$0a +
        '  } else' + #$0d + #$0a +
        '  {' + #$0d + #$0a +
        '	float p, q;' + #$0d + #$0a +
        '    if (HLS.y > 0.5*HLSMAX)' + #$0d + #$0a +
        '      q = (HLS.y + HLS.z - (HLS.y*HLS.z)*HLSMAX); else' + #$0d + #$0a +
        '      q = (HLS.y * (HLSMAX + HLS.z));' + #$0d + #$0a +
        '	p = HLS.y*2.0 - q;' + #$0d + #$0a +
        '    return vec3(HueToRGB(HLS.x+0.333333*HLSMAX, p, q), HueToRGB(HLS.x, p, q), HueToRGB(HLS.x-0.333333*HLSMAX, p, q));' + #$0d + #$0a +
        '  }' + #$0d + #$0a +
        '}' + #$0d + #$0a +


        'void main()' + #$0d + #$0a +
        '{' + #$0d + #$0a +
        ' vec4 c_tex = texture2D( s_texture, v_texCoord );' + #$0d + #$0a +
        '	float cMax = max( max(c_tex.r, c_tex.g), c_tex.b);' + #$0d + #$0a +
        '	float cMin = min( min(c_tex.r, c_tex.g), c_tex.b);' + #$0d + #$0a +
        '	gl_FragColor = vec4(HLStoRGB(vec3(color.x, (cMax+cMin)*0.5, color.z)), c_tex.a); //  * v_opacity' + #$0d + #$0a +
        '}';

  protected
    function CreateShader: TBlackSharkParticleShader; override;
  public
    constructor Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject); override;
  end;


implementation

uses
    SysUtils
  , bs.utils
  , bs.math
  , bs.config
  ;

{ TBlackSharkInstansing }

procedure TBlackSharkInstancing.BeginUpdate;
begin
  inc(UpdateCounter);
end;

constructor TBlackSharkInstancing.Create(ARenderer: TBlackSharkRenderer; APrototype: TObjectVertexes);
const
  INST_DEF_VAL_TRANSF: TInstance = (Scale: 1.0;
    Opacity: 1.0;
    Angle: (x:0.0; y: 0.0; z: 0.0);
    Position: (x:0.0; y: 0.0; z: 0.0);
    Color: (x:1.0; y:0.5; z:0.0; a:1.0);
    IsVisible: (false));
begin
  FRenderer := ARenderer;
  Instances := TListVec<TInstance>.Create;
  Instances.DefaultValue := INST_DEF_VAL_TRANSF;
  //{$if defined(GLES20)}
  Matrix := TListVec<TMatrix4f>.Create;
  Matrix.DefaultValue := IDENTITY_MAT;
  //{$endif}
  Prototype := APrototype;
end;

destructor TBlackSharkInstancing.Destroy;
begin
  //{$if defined(GLES20)}
  Matrix.Free;
  //{$else}
  //if mvpVBO > 0 then
  //  glDeleteBuffers(1, @mvpVBO);
  //{$endif}
  Instances.Free;
  inherited;
end;

procedure TBlackSharkInstancing.DrawProto(Inst: PRendererGraphicInstance);
var
//{$if defined(GLES20)}
  i: int32;
//{$else}
//  mvp_loc: GLint;
//{$endif}
begin
  //{$if defined(GLES20)}

  { software Instansing }

//  if FPrototype.StaticObject then
//    glBindBuffer ( GL_ELEMENT_ARRAY_BUFFER , FPrototype.VBO_Indexes )
//  else
//    glBindBuffer ( GL_ELEMENT_ARRAY_BUFFER , 0 );
//
  for i := 0 to FCountInstance - 1 do
  begin
    if not PInstance(Instances.ShiftData[i]).IsVisible then
      continue;

    Inst.LastMVP := Matrix.Items[i];
    glUniform1f( TBlackSharkVertexOutShader(FPrototype.Shader).Opacity^.Location, Instances.items[i].Opacity*FPrototype.Opacity );
    if Assigned(ColorUniform) then
      glUniform4fv( ColorUniform^.Location, 1, @PInstance(Instances.ShiftData[i]).Color );

    GIMethodDefault(Inst);
    //glUniform1f( TBlackSharkVertexOutShader(FPrototype.Shader).Opacity^.Location, FPrototype.Opacity );

    //glUniformMatrix4fv( TBlackSharkVertexOutShader(FPrototype.Shader).MVP^.Location, 1, GL_FALSE, Matrix.ShiftData[i] );
    //if FPrototype.StaticObject then
    //  glDrawElements (FPrototype.Mesh.DrawingPrimitive , FPrototype.Mesh.Indexes.Count, GL_UNSIGNED_SHORT, nil)
    //else
    //  glDrawElements (FPrototype.Mesh.DrawingPrimitive , FPrototype.Mesh.Indexes.Count, GL_UNSIGNED_SHORT, FPrototype.Mesh.Indexes.ShiftData[0]);

  end;
  (*
  {$else}

  { hardware Instansing }

   // Load the instance MVP buffer

   glBindBuffer ( GL_ARRAY_BUFFER, mvpVBO );
   mvp_loc := 2; //TBlackSharkTextureOutShader(FPrototype.Shader).MVP^.Location;

   glEnableVertexAttribArray ( mvp_loc + 0 );
   glEnableVertexAttribArray ( mvp_loc + 1 );
   glEnableVertexAttribArray ( mvp_loc + 2 );
   glEnableVertexAttribArray ( mvp_loc + 3 );

   // Load each matrix row of the MVP.  Each row gets an increasing attribute location.
   glVertexAttribPointer ( mvp_loc + 0, 4, GL_FLOAT, GL_FALSE, sizeof ( TMatrix4f ), nil );
   glVertexAttribPointer ( mvp_loc + 1, 4, GL_FLOAT, GL_FALSE, sizeof ( TMatrix4f ), Pointer( sizeof ( GLfloat ) * 4 ) );
   glVertexAttribPointer ( mvp_loc + 2, 4, GL_FLOAT, GL_FALSE, sizeof ( TMatrix4f ), Pointer ( sizeof ( GLfloat ) * 8 ) );
   glVertexAttribPointer ( mvp_loc + 3, 4, GL_FLOAT, GL_FALSE, sizeof ( TMatrix4f ), Pointer ( sizeof ( GLfloat ) * 12 ) );

   // One MVP per instance
   glVertexAttribDivisor ( MVP_LOC + 0, 1 );
   glVertexAttribDivisor ( MVP_LOC + 1, 1 );
   glVertexAttribDivisor ( MVP_LOC + 2, 1 );
   glVertexAttribDivisor ( MVP_LOC + 3, 1 );
   glBindBuffer ( GL_ELEMENT_ARRAY_BUFFER , FPrototype.VBO_Indexes );
   glDrawElementsInstanced (FPrototype.Shape.DrawingPrimitive , FPrototype.Shape.Indexes.Count, GL_UNSIGNED_SHORT, nil, FCountInstance);
  {$endif}*)
end;

procedure TBlackSharkInstancing.EndUpdate;
begin
  dec(UpdateCounter);
  if UpdateCounter = 0 then
    UpadateAllMatrix;
end;

procedure TBlackSharkInstancing.GenMatrix(AIndex: int32);
var
  pinst: PInstance;
begin

  if UpdateCounter > 0 then
    exit;

  { forming matrix transformations }
  pinst := Instances.ShiftData[AIndex];
  FPrototype.BeginUpdateTransformations;
  // set orientation
  FPrototype.Angle := pinst.Angle;
  // set scale
  if not(pinst.Scale = 1.0) then
    FPrototype.ScaleSimple := pinst.Scale;
  // set position
  FPrototype.Position := pinst.Position;
  FPrototype.EndUpdateTransformations;
  pinst.IsVisible := ProtoRendererInstance.Visible;
  // take out MVP matrix
  Matrix.Items[AIndex] := ProtoRendererInstance.LastMVP;

end;

function TBlackSharkInstancing.GetAngle(AIndex: int32): TVec3f;
begin
  if AIndex >= FCountInstance then
    exit(vec3(0.0, 0.0, 0.0));
  Result := PInstance(Instances.ShiftData[AIndex])^.Angle;
end;

function TBlackSharkInstancing.GetColor(AIndex: int32): TColor4f;
begin
  if AIndex >= FCountInstance then
    exit(BS_CL_BLACK);
  Result := PInstance(Instances.ShiftData[AIndex])^.Color;
end;

function TBlackSharkInstancing.GetOpacity(AIndex: int32): BSFloat;
begin
  if AIndex >= FCountInstance then
    exit(0.0);
  Result := PInstance(Instances.ShiftData[AIndex])^.Opacity;
end;

function TBlackSharkInstancing.GetPosition(AIndex: int32): TVec3f;
begin
  if AIndex >= FCountInstance then
    exit(vec3(0.0, 0.0, 0.0));
  Result := PInstance(Instances.ShiftData[AIndex])^.Position;
end;

function TBlackSharkInstancing.GetScale(AIndex: int32): BSFloat;
begin
  if AIndex >= FCountInstance then
    exit(0.0);
  Result := PInstance(Instances.ShiftData[AIndex])^.Scale;
end;

procedure TBlackSharkInstancing.Remove(AIndex: int32);
var
//{$ifndef GLES20}
//  m: PMatrix4f;
//{$endif}
  off_end: int32;
begin
  if AIndex >= FCountInstance then
    exit;
  off_end := FCountInstance - 1;
  //{$if defined(GLES20)}
  if (AIndex < off_end) and (FCountInstance > 1) then
  begin
    Instances.Items[AIndex] := Instances.Items[off_end];
    Matrix.Items[AIndex] := Matrix.Items[off_end];
  end;
  (*
  {$else}
  { set last item to index position (in place removed) }
  if (index < off_end) and (FCountInstance > 1) then
    begin
    Instances.Items[index] := Instances.Items[off_end];
    glBindBuffer ( GL_ARRAY_BUFFER, mvpVBO );
    m := PMatrix4f(glMapBufferRange ( GL_ARRAY_BUFFER, 0, sizeof ( TMatrix4f ) * FCountInstance, GL_MAP_WRITE_BIT ));
    PMatrix4f(pByte(m)+ index*sizeof ( TMatrix4f ))^ := PMatrix4f(pByte(m)+ off_end*sizeof ( TMatrix4f ))^;
    glUnmapBuffer ( GL_ARRAY_BUFFER );
    end;

  {$endif} *)
  FCountInstance := off_end;
  Instances.Count := FCountInstance;
end;

procedure TBlackSharkInstancing.SetAngle(AIndex: int32; const Value: TVec3f);
begin
  if AIndex >= FCountInstance then
    exit;
  PInstance(Instances.ShiftData[AIndex]).Angle := AngleEulerClamp3d(Value);
end;

procedure TBlackSharkInstancing.SetColor(AIndex: int32; const Value: TColor4f);
begin
  if AIndex >= FCountInstance then
    exit;
  PInstance(Instances.ShiftData[AIndex]).Color := Value;
end;

procedure TBlackSharkInstancing.SetCountInstance(const Value: int32);
(*
{$ifndef GLES20}
var
  increase: boolean;
{$endif} *)
begin
  if Value = FCountInstance then
    exit;

  //{$ifndef GLES20}
  //increase := Value > FCountInstance;
  //{$endif}

  FCountInstance := Value;
  Instances.Count := Value;

  //{$ifdef GLES20}
  Matrix.Count := Value;
  (*
  {$else}
  if increase or (mvpVBO = 0) then
    begin
    if mvpVBO > 0 then
      begin
      glDeleteBuffers(1, @mvpVBO);
      mvpVBO := 0;
      end;
    mvpVBO := CreateVBO(GL_ARRAY_BUFFER, nil, SizeOf(TMatrix4f)*FCountInstance, GL_DYNAMIC_DRAW);
    end;
  {$endif} *)
end;

procedure TBlackSharkInstancing.SetPrototype(const Value: TObjectVertexes);
begin
  if FPrototype = Value then
    exit;
  { return old draw instanse method }
  if Assigned(FPrototype) then
    FPrototype.DrawInstance := GIMethodDefault;
  FPrototype := Value;
  { remember default draw instanse method }
  if Assigned(FPrototype) then
  begin
    GIMethodDefault := FPrototype.DrawInstance;
    FPrototype.DrawInstance := DrawProto;
    ProtoRendererInstance := FRenderer.SceneInstanceToRenderInstance(FPrototype.BaseInstance);
    ColorUniform := FPrototype.Shader.Uniform['Color'];
  end else
    ColorUniform := nil;

  //{$ifdef GLES30}
  {if (FPrototype.Shader <> nil) then
    begin
    if (FPrototype.Shader.MVPasUniform) then
      begin
      FPrototype.Shader.MVPasUniform := false;
      FPrototype.Shader.LinkLocations;
      end;
    end else }
  //  FPrototype.Shader := FPrototype.Scene.ShaderManager.Load('Instancing', TBlackSharkTextureOutShader, false);
  //{$endif}
end;

procedure TBlackSharkInstancing.SetOpacity(AIndex: int32; const Value: BSFloat);
begin
  if AIndex >= FCountInstance then
    exit;
  PInstance(Instances.ShiftData[AIndex]).Opacity := Value;
  GenMatrix(AIndex)
end;

procedure TBlackSharkInstancing.SetPosition(AIndex: int32; const Value: TVec3f);
begin
  if AIndex >= FCountInstance then
    exit;
  PInstance(Instances.ShiftData[AIndex]).Position := Value;
  GenMatrix(AIndex);
end;

procedure TBlackSharkInstancing.SetScale(AIndex: int32; const Value: BSFloat);
begin
  if AIndex >= FCountInstance then
    exit;
  PInstance(Instances.ShiftData[AIndex]).Scale := Value;
end;


procedure TBlackSharkInstancing.UpadateAllMatrix;
var
  i: int32;
begin
  //{$ifdef GLES20}
  //{$else}
  //glBindBuffer ( GL_ARRAY_BUFFER, mvpVBO );
  //m := PMatrix4f(glMapBufferRange ( GL_ARRAY_BUFFER, 0, sizeof ( TMatrix4f ) * FCountInstance, GL_MAP_WRITE_BIT ));
  //{$endif}

  for i := 0 to FCountInstance - 1 do
    GenMatrix(i);
  //{$ifndef GLES20}
  //glUnmapBuffer ( GL_ARRAY_BUFFER );
  //{$endif}

end;


{ TBlackSharkParticles }

procedure TBlackSharkParticles<T>.Clear;
begin
  CountParticle := 0;
end;

constructor TBlackSharkParticles<T>.Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject);
var
  proto: TGraphicObject;
begin
  FRenderer := ARenderer;
  FParticles := TListParticles.Create;
  Distances := TListDistances.Create;
  Indexes := TListVec1s.Create;
  if AParticleBox <> nil then
  begin
    OwnProto := false;
    AParticleBox.StaticObject := false;
    SetParticlePrototype(AParticleBox);
    FParticlePrototype.ClearBeforeDrawListMethods;
  end else
  begin
    OwnProto := true;
    proto := TDefaultGraphicObject.Create(Self, nil, FRenderer.Scene);
    proto.StaticObject := false;
    TBlackSharkFactoryShapesP.GenerateCube(proto.Mesh, vec3(0.5, 0.5, 0.5));
    proto.ChangedMesh;
    SetParticlePrototype(proto);
  end;
  FParticlePrototype.Opacity := 0.0;
  FParticlePrototype.Color := BS_CL_GREEN;
  FParticlePrototype.Shader := CreateShader;
  FParticlePrototype.Interactive := false;
  Shader := TBlackSharkParticleShader(FParticlePrototype.Shader);
end;

destructor TBlackSharkParticles<T>.Destroy;
begin
  FTextureHolder := nil;
  Indexes.Free;
  Distances.Free;
  if OwnProto then
    FParticlePrototype.Free;
  FParticles.Free;
  inherited;
end;

(*
procedure TBlackSharkParticles<T>.DrawProto(Instance: PGraphicInstance);
begin
  if FCountParticle = 0 then
    exit;
  glBindBuffer ( GL_ARRAY_BUFFER, 0 );
  glUniformMatrix4fv( Shader.MVP^.Location, 1, GL_FALSE, @Instance.LastMVP );
  glVertexAttribPointer(Shader.FPosition.Location, 4, GL_FLOAT, GL_FALSE, SizeOf(TParticle), FParticles.ShiftData[0]);
  glVertexAttribPointer(Shader.FOpacity.Location, 1, GL_FLOAT, GL_FALSE, SizeOf(TParticle), @(PParticle(FParticles.ShiftData[0])^.Opacity));
  glVertexAttribPointer(Shader.FScale.Location, 1, GL_FLOAT, GL_FALSE, SizeOf(TParticle), @(PParticle(FParticles.ShiftData[0])^.Scale));
  //glVertexAttribPointer(Shader.FOpacity.Location, 1, GL_FLOAT, GL_FALSE, SizeOf(TParticle), Pointer(SizeOf(TVec4f)));
  //glVertexAttribPointer(Shader.FScale.Location, 1, GL_FLOAT, GL_FALSE, SizeOf(TParticle), Pointer(SizeOf(TVec4f)+SizeOf(BSFloat)));
  if FIsPoints then
    begin
    { show bitmap by points; very slowly glDrawArrays for GL_POINTS, looking for
     reasons in sources "libGLESv2.dll" ...}
    if FUseMultiColor then
      glVertexAttribPointer(TBlackSharkParticlePointShader(Shader).FColor.Location, 3, GL_FLOAT, GL_FALSE, SizeOf(TVec3f), FColors.ShiftData[0]) else
      glUniform3f(TBlackSharkParticlePointShaderSingleColor(Shader).FColor.Location, FDefaultColor.r, FDefaultColor.g, FDefaultColor.b);
    glDrawArrays(GL_POINTS, 0, FParticles.Count);
    end else
    begin
    { show bitmap from texture areas }
    FParticlePrototype.Scene.UseTexture(FParticlePrototype.Texture^.Texture);
    if FUseUV then
      begin
      glVertexAttribPointer(TBlackSharkParticleMultiUVTextureShader(Shader).UV.Location, 2,
        GL_FLOAT, GL_FALSE, SizeOf(TVec2f), FUVAreas.ShiftData[0]);
      glVertexAttribPointer(TBlackSharkParticleMultiUVTextureShader(Shader).Delta.Location, 2,
        GL_FLOAT, GL_FALSE, SizeOf(TVec2f), FAreas.ShiftData[0]);
      if FUseColor then
        begin
        if FUseMultiColor then
          glVertexAttribPointer(TBlackSharkParticleMultiUVAndColorShader(Shader).FUVColor.Location, 3, GL_FLOAT, GL_FALSE, SizeOf(TVec3f), FColors.ShiftData[0])  else
        if FReplaceColor then
          begin
          //glUniform3f(TBlackSharkParticleMultiUVAndSingleColorShader(Shader).FUVColor.Location, FDefaultColor.r, FDefaultColor.g, FDefaultColor.b);
          glUniform3fv(TBlackSharkParticleMultiUVAndReplaceColorShader(Shader).FHLS.Location, 1, @HLSDefCol);
          end else
          glUniform3fv(TBlackSharkParticleMultiUVAndSingleColorShader(Shader).FColor.Location, 1, @FDefaultColor);
        end;
      end else
      begin
      glUniform2fv( TBlackSharkParticleTextureShader(Shader).FUV^.Location, 4, @UV );
      glUniform3fv( TBlackSharkParticleTextureShader(Shader).FQuad^.Location, 4, Pointer(@Quad[0]) );    // FParticlePrototype.Mesh.VertexesData
      end;
    glDrawArrays(GL_TRIANGLES, 0, FParticles.Count);
    end;
end;

  *)

function TBlackSharkParticles<T>.GetCapacity: int32;
begin
  if FIsPoints then
    Result := FParticles.Capacity
  else
    Result := FParticles.Capacity shr 2;
end;

{function TBlackSharkParticles<T>.GetColor(AIndex: int32): TVec3f;
begin
  if FIsPoints then
    Result := FColors.Items[index] else
    Result := FColors.Items[index*6];
end;

function TBlackSharkParticles<T>.GetOpacity(AIndex: int32): BSFloat;
begin
  if FIsPoints then
    Result := FParticles.Items[index].Opacity else
    Result := FParticles.Items[index*6].Opacity;
end;

function TBlackSharkParticles<T>.GetScale(AIndex: int32): BSFloat;
begin
  if FIsPoints then
    Result := FParticles.Items[index].Scale else
    Result := FParticles.Items[index*6].Scale;
end; }

function TBlackSharkParticles<T>.GetPosition(AIndex: int32): TVec3f;
begin
  if FIsPoints then
    Result := TVec3f(FParticles.Items[AIndex].Position)
  else
    Result := TVec3f((FParticles.Items[AIndex*4 + 1].Position + FParticles.Items[AIndex*4].Position)*0.5);
end;

{class function TBlackSharkParticles<T>.Particle(const Position: TVec4f; Opacity, Scale: BSFloat): TParticle;
begin
  Result.Position := Position;
  Result.Opacity := Opacity;
  Result.Scale := Scale;
end;}

procedure TBlackSharkParticles<T>.Remove(AIndex: int32);
var
  off_end: int32;
  off_start: int32;
begin
  off_end := FCountParticle - 1;
  if (FCountParticle = 0) or (AIndex > off_end) then
    exit;
  if (FCountParticle > 1) and (AIndex < off_end) then
  begin
    FParticles.Items[AIndex] := FParticles.Items[off_end];
    off_end := (off_end) * 6;
    off_start := AIndex * 6;
    Indexes.Items[off_start    ] := Indexes.Items[off_end];
    Indexes.Items[off_start + 1] := Indexes.Items[off_end + 1];
    Indexes.Items[off_start + 2] := Indexes.Items[off_end + 2];
    Indexes.Items[off_start + 3] := Indexes.Items[off_end + 3];
    Indexes.Items[off_start + 4] := Indexes.Items[off_end + 4];
    Indexes.Items[off_start + 5] := Indexes.Items[off_end + 5];
    if FIsPoints then
    begin
      //FColors.Items[index] := FColors.Items[off_end];
      //FColors.Count := off_end;
    end else
    begin
      move(PByte(FParticles.ShiftData[off_end])^, pByte(FParticles.ShiftData[off_end])^, SizeOf(TParticle)*6);
    end;
  end;

  FParticles.Count := off_end;

  dec(FCountParticle);
end;

(*procedure TBlackSharkParticles<T>.SelectShader;
begin
  if FIsPoints then
    begin
    if FUseMultiColor then
      begin
      if FColors = nil then
        begin
        FColors := TListVec<TVec3f>.Create;
        FColors.DefaultValue := vec3(FDefaultColor.x, FDefaultColor.y, FDefaultColor.z);
        end;
      FParticlePrototype.Shader := TBlackSharkParticlePointShader(FParticlePrototype.Scene.ShaderManager.Load(
        'ParticlesPoint', TBlackSharkParticlePointShader));
      end else
      begin
      FParticlePrototype.Shader := TBlackSharkParticlePointShaderSingleColor(FParticlePrototype.Scene.ShaderManager.Load(
        'ParticlesPoint2', TBlackSharkParticlePointShaderSingleColor));
      if FColors <> nil then
        FreeAndNil(FColors);
      end;
    end else
  if FUseUV then
    begin
    { for evry particle self texture coordinates }
    if FUseColor then
      begin
      { for evry particle self color ? }
      if FUseMultiColor then
        begin
        FParticlePrototype.Shader := TBlackSharkParticleMultiUVAndColorShader(FParticlePrototype.Scene.ShaderManager.Load(
          'ParticlesQuad3', TBlackSharkParticleMultiUVAndColorShader));
        if FColors = nil then
          begin
          FColors := TListVec<TVec3f>.Create;
          FColors.DefaultValue := vec3(FDefaultColor.x, FDefaultColor.y, FDefaultColor.z);
          end;
        end else
      if FReplaceColor then
        begin
        FParticlePrototype.Shader := TBlackSharkParticleMultiUVAndSingleColorShader(FParticlePrototype.Scene.ShaderManager.Load(
          'ParticlesQuad4', TBlackSharkParticleMultiUVAndSingleColorShader));
        if FColors <> nil then
          FreeAndNil(FColors);
        end else
        begin
        FParticlePrototype.Shader := TBlackSharkParticleMultiUVAndSingleColorShader(FParticlePrototype.Scene.ShaderManager.Load(
          'ParticlesQuad5', TBlackSharkParticleMultiUVAndSingleColorShader));
        if FColors <> nil then
          FreeAndNil(FColors);
        end;
      end else
      begin
      { evry particle draw only from texture }
      FParticlePrototype.Shader := TBlackSharkParticleTextureShader(FParticlePrototype.Scene.ShaderManager.Load(
        'ParticlesQuad2', TBlackSharkParticleMultiUVTextureShader));
      if FColors <> nil then
        FreeAndNil(FColors);
      end;
    end else
    begin
    { single texture coordinates (as uniform) }
    FParticlePrototype.Shader := TBlackSharkParticleTextureShader(FParticlePrototype.Scene.ShaderManager.Load(
      'ParticlesQuad', TBlackSharkParticleTextureShader));
    if FColors <> nil then
      FreeAndNil(FColors);
    end;
  Shader := TBlackSharkParticleShader(FParticlePrototype.Shader);
end; *)

procedure TBlackSharkParticles<T>.SetCapacity(const Value: int32);
begin
  if FParticles.Capacity = Value then
    exit;
  //FCapacity := Value;
  if FIsPoints then
  begin
    FParticles.Capacity := Value;
    //FColors.Capacity := FParticles.Capacity;
    //FUVAreas.Clear;
    //FAreas.Clear;
  end else
  begin
    FParticles.Capacity := Value shl 2;
    Indexes.Count := Value*6;
    //FUVAreas.Capacity := FParticles.Capacity;
    //FAreas.Capacity := FParticles.Capacity;
  end;
  Distances.Capacity := Value;
end;

{
procedure TBlackSharkParticles<T>.SetColor(index: int32; const Value: TVec3f);
begin
  if not FUseMultiColor then
    exit;
  if index < FCountParticle then
    FColors.Items[index] := Value;
end;  }

procedure TBlackSharkParticles<T>.SetCountParticle(const Value: int32);
var
  ptr: PArrayShorti;
  ind: Smallint;
  i, j: int32;
  was_part: int32;
begin
  if FCountParticle = Value then
    exit;
  was_part := FCountParticle;
  FCountParticle := Value;
  Distances.Count := FCountParticle;
  if FIsPoints then
  begin
    FParticles.Count := FCountParticle;
    {if FColors <> nil then
      begin
      if FParticles.Capacity <> FColors.Capacity then
        FColors.Capacity := FParticles.Capacity;
      FColors.Count := FCountParticle;
      end;
    FUVAreas.Clear;
    FAreas.Clear;  }
    Indexes.Count := FCountParticle;
  end else
  begin
    FParticles.Count := FCountParticle shl 2;// * 6; // evry particle is a quad texture
    Indexes.Count := FCountParticle * 6;
    {FUVAreas.Count := FParticles.Count;
    FAreas.Count := FParticles.Count;
    if FColors <> nil then
      FColors.Count := FParticles.Count;}
    if FCountParticle > was_part then
    begin
      ptr := Indexes.ShiftData[0];
      j := was_part*6;

      { an every particle is described four vertexes and six indexes }

      for i := was_part to FCountParticle - 1 do
      begin
        ind := (i shl 2) mod MAX_COUNT_PARTICLE;
        ptr[j+0] := ind;
        ptr[j+1] := ind+1;
        ptr[j+2] := ind+2;
        ptr[j+3] := ind;
        ptr[j+4] := ind+1;
        ptr[j+5] := ind+3;
        inc(j, 6);
      end;

    end;
  end;
end;

{procedure TBlackSharkParticles<T>.SetDefaultColor(const Value: TColor4f);
begin
  FDefaultColor := Value;
  HLSDefCol := RGBtoHLS(vec3(FDefaultColor.x, FDefaultColor.y, FDefaultColor.z));
  //if FColors <> nil then
  //  FColors.DefaultValue := vec3(FDefaultColor.x, FDefaultColor.y, FDefaultColor.z);
  //BrightnessDefCol := 0.299*FDefaultColor.r + 0.587*FDefaultColor.g + 0.114*FDefaultColor.b;
end;  }

{procedure TBlackSharkParticles<T>.SetOpacity(index: int32; const Value: BSFloat);
var
  off: int32;
begin
  if index >= FCountParticle then
    exit;
  if FIsPoints then
    begin
    PParticle(FParticles.ShiftData[index]).Opacity := Value;
    end else
    begin
    off := index*6;
    //FParticles.Items[index]
    PParticle(FParticles.ShiftData[off+0]).Opacity := Value;
    PParticle(FParticles.ShiftData[off+1]).Opacity := Value;
    PParticle(FParticles.ShiftData[off+2]).Opacity := Value;
    PParticle(FParticles.ShiftData[off+3]).Opacity := Value;
    PParticle(FParticles.ShiftData[off+4]).Opacity := Value;
    PParticle(FParticles.ShiftData[off+5]).Opacity := Value;
    end;
end;  }

procedure TBlackSharkParticles<T>.SetParticlePrototype(const Value: TGraphicObject);
begin
  { return old draw instanse method }
  //if FParticlePrototype <> nil then
  //  FParticlePrototype.DrawInstance := GIDrawDefault;
  FParticlePrototype := Value;
  { remember default draw instanse method }
  {if FParticlePrototype <> nil then
    begin
    GIDrawDefault := FParticlePrototype.DrawInstance;
    end;}
end;

procedure TBlackSharkParticles<T>.SetPosition(index: int32; const Value: TVec3f);
var
  ptr_part: PParticleArray;
  i: int32;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  Distances.Items[index] := PlaneDotProduct(FRenderer.Frustum.Frustum.P[TBoxPlanes.bpNear], Value);
  if FIsPoints then
  begin
    PParticle(FParticles.ShiftData[index]).Position := vec4(Value.x, Value.y, Value.z, 0.0);
  end else
  begin
    i := index shl 2;
    ptr_part := FParticles.ShiftData[i];
    ptr_part[0].Position := vec4(Value.x + Quad[0].x, Value.y + Quad[0].y, Value.z, 0);
    ptr_part[1].Position := vec4(Value.x + Quad[1].x, Value.y + Quad[1].y, Value.z, 1);
    ptr_part[2].Position := vec4(Value.x + Quad[2].x, Value.y + Quad[2].y, Value.z, 2);
    ptr_part[3].Position := vec4(Value.x + Quad[3].x, Value.y + Quad[3].y, Value.z, 3);
  end;
end;

{procedure TBlackSharkParticles<T>.SetScale(index: int32; const Value: BSFloat);
var
  off: int32;
begin
  if index >= FCountParticle then
    CountParticle := index+1;
  if FIsPoints then
    begin
    PParticle(FParticles.ShiftData[index]).Scale := Value;
    end else
    begin
    off := index*6;
    PParticle(FParticles.ShiftData[off+0]).Scale := Value;
    PParticle(FParticles.ShiftData[off+1]).Scale := Value;
    PParticle(FParticles.ShiftData[off+2]).Scale := Value;
    PParticle(FParticles.ShiftData[off+3]).Scale := Value;
    PParticle(FParticles.ShiftData[off+4]).Scale := Value;
    PParticle(FParticles.ShiftData[off+5]).Scale := Value;
    end;
end; }

procedure TBlackSharkParticles<T>.SetTexture(const Value: PTextureArea);
begin
  if Value = FTexture then
    exit;
  FTexture := Value;
  if Assigned(FTexture) then
  begin
    FTextureHolder := Value.Texture;
    FillBaseQuad;
  end else
    FTextureHolder := nil;
end;

{
procedure TBlackSharkParticles<T>.SetupParticleProperties(Index: int32;
  const Position: TVec3f; Opacity, Scale: BSFloat; const Rect: TTextureRect);
var
  off: int32;
  p: TParticle;
  w, h: BSFloat;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  Distances.Items[Index] := PlaneDotProduct(FScene.FFrustum.FFrustum.P[TBoxPlanes.bpNear], Position);
  if FIsPoints then
    begin
    FParticles.Items[index] := Particle(vec4(Position.x, Position.y, Position.z, 0.0), Opacity, Scale);
    end else
    begin
    off := Index * 6;
    w := FParticlePrototype.BSConfig.VoxelSize*(Rect.Rect.Width)*0.5;
    h := FParticlePrototype.BSConfig.VoxelSize*(Rect.Rect.Height)*0.5;
    p.Opacity  := Opacity;
    p.Scale := Scale;
    p.Position := vec4(Position.x, Position.y, Position.z, 0.0);
    FAreas.Items[off + 0] := vec2(-w, -h);
    FAreas.Items[off + 1] := vec2( w,  h);
    FAreas.Items[off + 2] := vec2(-w,  h);
    FAreas.Items[off + 3] := vec2(-w, -h);
    FAreas.Items[off + 4] := vec2( w,  h);
    FAreas.Items[off + 5] := vec2( w, -h);
    FParticles.Items[off + 0] := p;
    FParticles.Items[off + 1] := p;
    FParticles.Items[off + 2] := p;
    FParticles.Items[off + 3] := p;
    FParticles.Items[off + 4] := p;
    FParticles.Items[off + 5] := p;
    if FUseUV then
      begin
      FUVAreas.Items[off + 0] := vec2(Rect.UV.U, Rect.UV.V + Rect.UV.Height);
      FUVAreas.Items[off + 1] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V);
      FUVAreas.Items[off + 2] := Rect.UV.Position;
      FUVAreas.Items[off + 3] := vec2(Rect.UV.U, Rect.UV.V + Rect.UV.Height);
      FUVAreas.Items[off + 4] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V);
      FUVAreas.Items[off + 5] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V + Rect.UV.Height);
      end;
    end;
end;

procedure TBlackSharkParticles<T>.SetupParticleProperties(Index: int32;
  const Position: TVec3f; Opacity, Scale: BSFloat);
var
  off: int32;
  p: TParticle;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  Distances.Items[Index] := PlaneDotProduct(FScene.FFrustum.FFrustum.P[TBoxPlanes.bpNear], Position);
  if FIsPoints then
    begin
    FParticles.Items[index] := Particle(vec4(Position.x, Position.y, Position.z, 0.0), Opacity, Scale);
    end else
    begin
    p := Particle(vec4(Position.x, Position.y, Position.z, 0.0), Opacity, Scale);
    off := Index*6;
    FParticles.Items[off+0] := p;
    p.Position.a := 1.0;
    FParticles.Items[off+1] := p;
    p.Position.a := 2.0;
    FParticles.Items[off+2] := p;
    p.Position.a := 0.0;
    FParticles.Items[off+3] := p;
    p.Position.a := 1.0;
    FParticles.Items[off+4] := p;
    p.Position.a := 3.0;
    FParticles.Items[off+5] := p;
    end;
end;  }

procedure TBlackSharkParticles<T>.DoSort(L, R: int32);
var
  i, j, mul_i, mul_j: int32;
  P, Q: BSFloat;
  pat: TParticle;
  k: int8;
begin

  repeat
    i := L;
    j := R;
    P := DistancesData^[ ((L + R) shr 1) ];

    repeat

      while P < DistancesData^[i] do
       inc(i);

      while P > DistancesData^[j] do
       dec(j);

      if i <= j then
      begin
        Q := DistancesData^[i];
        DistancesData^[i] := DistancesData^[j];
        DistancesData^[j] := Q;
        if FIsPoints then
        begin
          pat := ParticlesData^[i];
          ParticlesData^[i] := ParticlesData^[j];
          ParticlesData^[j] := pat;
          //Indexes.Exchange(i, j);
        end else
        begin
          mul_i := i*6;
          mul_j := j*6;
          {for k := 0 to 5 do
            Indexes.Exchange(mul_i + k, mul_j + k);}
          mul_i := i shl 2;
          mul_j := j shl 2;
          for k := 0 to 3 do
          begin
            pat := ParticlesData^[mul_i + k];
            ParticlesData^[mul_i + k] := ParticlesData^[mul_j + k];
            ParticlesData^[mul_j + k] := pat;
          end;
        end;
        inc(i);
        dec(j);
      end;

    until i > j;

    // sort the smaller range recursively
    // sort the bigger range via the loop
    // Reasons: memory usage is O(log(n)) instead of O(n) and loop is faster than recursion
    if j - L < R - i then
    begin
      if L < j then
        DoSort(L, j);
      L := i;
    end else
    begin
      if i < R then
        DoSort(i, R);
      R := j;
    end;
  until L >= R;

end;


procedure TBlackSharkParticles<T>.FillBaseQuad;
var
  w, h: BSFloat;
begin
  if (FTexture = nil) then
    exit;
  w := BSConfig.VoxelSize * FTexture.Rect.Width * 0.5;
  h := BSConfig.VoxelSize * FTexture.Rect.Height * 0.5;
  Quad[0] := vec3(-w, -h, 0.0);
  Quad[1] := vec3( w,  h, 0.0);
  Quad[2] := vec3(-w,  h, 0.0);
  Quad[3] := vec3( w, -h, 0.0);
  UV[0] := vec2(FTexture.UV.U, FTexture.UV.V);
  UV[1] := vec2(FTexture.UV.U + FTexture.UV.Width, FTexture.UV.V + FTexture.UV.Height);
  UV[2] := vec2(FTexture.UV.U,  FTexture.UV.V + FTexture.UV.Height);
  UV[3] := vec2(FTexture.UV.U + FTexture.UV.Width, FTexture.UV.V);
end;

procedure TBlackSharkParticles<T>.Sort;
begin
  DistancesData := Distances.Data;
  ParticlesData := FParticles.Data;
  DoSort(0, Distances.Count - 1);
end;

{ TBlackSharkParticleShader }

constructor TBlackSharkParticleShader.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FMVP := AddUniform('MVP', stMat4, tsVertex);
  FPosition := AddAttribute('a_position', stVec3, tsVertex);
  //FOpacity := AddAttribute('a_opacity', stFloat, tsVertex);
  //FScale := AddAttribute('a_scale', stFloat, tsVertex);
end;

{ TBlackSharkParticlePointShader }

constructor TBlackSharkParticlePointShader.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddAttribute('a_color', stVec3, tsVertex);
end;

{ TBlackSharkParticleMultiUVTextureShader }

constructor TBlackSharkParticleMultiUVTextureShader.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FUV := AddAttribute('a_uv', stVec2, tsVertex);
  FDelta := AddAttribute('a_delta', stVec3, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
end;

{ TBlackSharkParticleMultiUVAndSingleColorShader }

constructor TBlackSharkParticleMultiUVAndReplaceColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  //FUVColor := AddUniform('color', stVec3, tsFragment);
  FHLS := AddUniform('HLS', stVec3, tsFragment);
end;

{ TBlackSharkParticleMultiUVAndSingleColorShader }

constructor TBlackSharkParticleMultiUVAndSingleColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddUniform('color', stVec3, tsFragment);
end;

{ TBlackSharkParticleMultiUVAndColorShader }

constructor TBlackSharkParticleMultiUVAndColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FUVColor := AddAttribute('a_color', stVec3, tsVertex);
end;

{ TBlackSharkParticlePointShaderSingleColor }

constructor TBlackSharkParticlePointShaderSingleColor.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddUniform('color', stVec3, tsFragment);
end;

{ TParticlesSingleUV.TParticleShader }

constructor TParticlesSingleUV.TParticleShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FUV := AddUniform('uv', stVec2, tsVertex);
  //FPosition := AddAttribute('a_index', stInt, tsVertex);
  //FQuad := AddUniform('quad', stVec3, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
end;

{ TParticlesSingleUV }

procedure TParticlesSingleUV.Change(Index: int32; const Postion: TVec3f);
begin


end;

constructor TParticlesSingleUV.Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject);
begin
  inherited;
  FParticlePrototype.DrawInstance := DrawProto;
end;

function TParticlesSingleUV.CreateShader: TBlackSharkParticleShader;
begin
  Result := TParticleShader(BSShaderManager.Load(ClassName,
    AnsiString(VSH), AnsiString(FSH), TParticleShader));
end;

destructor TParticlesSingleUV.Destroy;
begin

  inherited;
end;

procedure TParticlesSingleUV.DrawProto(Instance: PRendererGraphicInstance);
var
  i, pos_ar, pos_ind: int32;
  step: int32;
begin
  if FCountParticle = 0 then
    exit;
  //glBindBuffer ( GL_ARRAY_BUFFER, 0 );
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); // define draw method by indexes
  glUniformMatrix4fv( Shader.MVP^.Location, 1, GL_FALSE, @Instance.LastMVP );
  { show bitmap from texture areas }
  BSTextureManager.UseTexture(FTexture^.Texture);
  glUniform2fv( TParticleShader(Shader).FUV^.Location, 4, @UV );
  //glUniform3fv( TBlackSharkParticleTextureShader(Shader).FQuad^.Location, 4, Pointer(@Quad[0]) );    // FParticlePrototype.Mesh.VertexesData
  //glVertexAttrib1f
  i := 0;
  pos_ar := 0;
  pos_ind := 0;
  while i < FCountParticle do
  begin
    if i + TParticlesSingleUV.MAX_COUNT_PARTICLE_ONE_OF_FOUR > FCountParticle then
      step := FCountParticle - i
    else
      step := TParticlesSingleUV.MAX_COUNT_PARTICLE_ONE_OF_FOUR;
    glVertexAttribPointer(Shader.FPosition.Location, 4, GL_FLOAT, GL_FALSE, SizeOf(TParticle), FParticles.ShiftData[pos_ar]);
    if FIsPoints then
    begin
      { show bitmap by points; very slowly glDrawArrays for GL_POINTS, look for
       reasons in sources "libGLESv2.dll" ...}
      //if FUseMultiColor then
      //  glVertexAttribPointer(TBlackSharkParticlePointShader(Shader).FColor.Location, 3, GL_FLOAT, GL_FALSE, SizeOf(TVec3f), FColors.ShiftData[0]) else
      //  glUniform3f(TBlackSharkParticlePointShaderSingleColor(Shader).FColor.Location, FDefaultColor.r, FDefaultColor.g, FDefaultColor.b);
      glDrawArrays(GL_POINTS, 0, FParticles.Count);
    end else
    begin
      glDrawElements (GL_TRIANGLES, step*6, GL_UNSIGNED_SHORT, Indexes.ShiftData[pos_ind]);
    end;
    inc(pos_ind, step * 6);
    inc(pos_ar, step shl 2);
    inc(i, step);
  end;
end;

{ TParticlesMultiUVConstSize.TParticlesShader }

constructor TParticlesMultiUV.TParticlesShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  //FUV := AddUniform('uv', stVec2, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
  FUVPosition := AddAttribute('a_uv_position', stVec2, tsVertex);
end;

{ TParticlesMultiUVConstSize }

constructor TParticlesMultiUV.Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject);
begin
  inherited;
  FParticlePrototype.DrawInstance := DrawProto;
end;

function TParticlesMultiUV.CreateShader: TBlackSharkParticleShader;
begin
  Result := TParticlesMultiUV.TParticlesShader(BSShaderManager.Load(ClassName,
      AnsiString(VSH), AnsiString(FSH), TParticlesMultiUV.TParticlesShader));
end;

destructor TParticlesMultiUV.Destroy;
begin

  inherited;
end;

procedure TParticlesMultiUV.DrawProto(Instance: PRendererGraphicInstance);
var
  i, pos_ar, pos_ind: int32;
  step: int32;
begin
  if FCountParticle = 0 then
    exit;
  // define draw method by indexes
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glUniformMatrix4fv( Shader.MVP^.Location, 1, GL_FALSE, @Instance.LastMVP );
  { show bitmap from texture areas }
  BSTextureManager.UseTexture(FTexture^.Texture);
  //glUniform2fv( TParticlesMultiUVConstSize.TParticlesShader(Shader).FUV^.Location, 4, @UV );
  i := 0;
  pos_ar := 0;
  pos_ind := 0;
  while i < FCountParticle do
  begin
    if i + MAX_COUNT_PARTICLE_ONE_OF_FOUR > FCountParticle then
      step := FCountParticle - i
    else
      step := MAX_COUNT_PARTICLE_ONE_OF_FOUR;
    glVertexAttribPointer(Shader.FPosition.Location, 4, GL_FLOAT, GL_FALSE, SizeOf(TParticle), FParticles.ShiftData[pos_ar]);
    glVertexAttribPointer(TParticlesMultiUV.TParticlesShader(Shader).FUVPosition.Location, 2,
      GL_FLOAT, GL_FALSE, SizeOf(TParticle), @(PParticle(FParticles.ShiftData[pos_ar])^.Data));

    if FIsPoints then
    begin
      { TODO: draw points }
      { show bitmap by points; very slowly glDrawArrays for GL_POINTS, look for
       reasons in sources "libGLESv2.dll" ...}
      //if FUseMultiColor then
      //  glVertexAttribPointer(TBlackSharkParticlePointShader(Shader).FColor.Location, 3, GL_FLOAT, GL_FALSE, SizeOf(TVec3f), FColors.ShiftData[0]) else
      //  glUniform3f(TBlackSharkParticlePointShaderSingleColor(Shader).FColor.Location, FDefaultColor.r, FDefaultColor.g, FDefaultColor.b);
      //glDrawArrays(GL_POINTS, 0, FParticles.Count);
    end else
    begin
      glDrawElements (GL_TRIANGLES, step*6, GL_UNSIGNED_SHORT, Indexes.ShiftData[pos_ind]);
    end;
    inc(pos_ind, step*6);
    inc(pos_ar, step shl 2);
    inc(i, step);
  end;
end;

{function TParticlesMultiUV.GetSizeUV: TVec2f;
begin
  Result := UV[1]*2.0;
end;}

function TParticlesMultiUV.GetPosition(AIndex: int32): TVec3f;
begin
  Result := TVec3f(FParticles.Items[AIndex*4].Position + FParticles.Items[AIndex*4 + 1].Position) * 0.5;
end;

function TParticlesMultiUV.GetPositionUV(AIndex: int32): TVec2f;
begin
  Result := FParticles.Items[AIndex*4].Data;
end;

function TParticlesMultiUV.GetRect(AIndex: int32): TRectBSF;
var
  ptr_part: PParticleArray;
begin
  ptr_part := PParticleArray(FParticles.ShiftData[AIndex*4]);
  Result.Position := ptr_part[0].Data;
  Result.Size := ptr_part[1].Data - Result.Position;
end;

procedure TParticlesMultiUV.SetPosition(index: int32; const Value: TVec3f);
var
  h: TVec2f;
  ptr_part: PParticleArray;
begin
  ptr_part := FParticles.ShiftData[index shl 2];
  h := (ptr_part[1].Position.xy - ptr_part[0].Position.xy)*0.5;
  ptr_part[0].Position := vec4(Value.x - h.x, Value.y - h.y, Value.z, 0);
  ptr_part[1].Position := vec4(Value.x + h.x, Value.y + h.y, Value.z, 1);
  ptr_part[2].Position := vec4(Value.x - h.x, Value.y + h.y, Value.z, 2);
  ptr_part[3].Position := vec4(Value.x + h.x, Value.y - h.y, Value.z, 3);
end;

procedure TParticlesMultiUV.SetPositionUV(index: int32; const Value: TVec2f);
var
  ptr_part: PParticleArray;
  size: TVec2f;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  ptr_part := PParticleArray(FParticles.ShiftData[index*4]);
  size := ptr_part[1].Position.xy - ptr_part[0].Position.xy;
  ptr_part[0].Data := Value;
  ptr_part[1].Data := Value + size;
  ptr_part[2].Data := vec2(Value.x + size.x, Value.y);
  ptr_part[3].Data := vec2(Value.x, Value.y + size.y);
end;

procedure TParticlesMultiUV.Change(Index: int32; const Postion: TVec3f;
  const Rect: TTextureRect);
var
  ptr_part: PParticleArray;
  i: int32;
  h: TVec2f;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  i := index shl 2; // * 4

  h := Rect.Rect.Size * 0.5;
  ptr_part := FParticles.ShiftData[i];
  ptr_part[0].Position := vec4(Postion.x - h.x, Postion.y - h.y, Postion.z, 0);
  ptr_part[1].Position := vec4(Postion.x + h.x, Postion.y + h.y, Postion.z, 1);
  ptr_part[2].Position := vec4(Postion.x - h.x, Postion.y + h.y, Postion.z, 2);
  ptr_part[3].Position := vec4(Postion.x + h.x, Postion.y - h.y, Postion.z, 3);
  ptr_part[0].Data := vec2(Rect.UV.U, Rect.UV.V + Rect.UV.Height);
  ptr_part[1].Data := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V);
  ptr_part[2].Data := Rect.UV.Position;
  ptr_part[3].Data := Rect.UV.Position + Rect.UV.Size;
end;

procedure TParticlesMultiUV.SetRect(index: int32; const Value: TRectBSF);
var
  ptr_part: PParticleArray;
  //pos: TVec3f;
begin
  if index >= FCountParticle then
    CountParticle := index + 1;
  //pos := GetPosition(index);
  ptr_part := PParticleArray(FParticles.ShiftData[index*4]);
  {ptr_part[0].Data := Value.Position;
  ptr_part[1].Data := Value.Position + Value.Size;
  ptr_part[2].Data := vec2(Value.Position.x + Value.x, Value.Position.y);
  ptr_part[3].Data := vec2(Value.Position.x, Value.Position.y + Value.y);}
  ptr_part[0].Data := vec2(Value.Position.x, Value.Position.y + Value.y);
  ptr_part[1].Data := vec2(Value.Position.x + Value.x, Value.Position.y);
  ptr_part[2].Data := Value.Position;
  ptr_part[3].Data := Value.Position + Value.Size;
      {
      FUVAreas.Items[off + 0] := vec2(Rect.UV.U, Rect.UV.V + Rect.UV.Height);
      FUVAreas.Items[off + 1] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V);
      FUVAreas.Items[off + 2] := Rect.UV.Position;
      FUVAreas.Items[off + 3] := vec2(Rect.UV.U, Rect.UV.V + Rect.UV.Height);
      FUVAreas.Items[off + 4] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V);
      FUVAreas.Items[off + 5] := vec2(Rect.UV.U + Rect.UV.Width, Rect.UV.V + Rect.UV.Height);
      }
end;

{ TParticlesMultiUVSingleColor.TParticlesShader }

constructor TParticlesMultiUVSingleColor.TParticlesShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FUVPosition := AddAttribute('a_uv_position', stVec2, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
  FColor := AddUniform('color', stVec3, tsFragment);
end;

{ TParticlesMultiUVSingleColor }

constructor TParticlesMultiUVSingleColor.Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject);
begin
  inherited;
  FParticlePrototype.DrawInstance := DrawProto;
  HLS := RGBtoHLS(vec3(FColor.x, FColor.y, FColor.z));
end;

function TParticlesMultiUVSingleColor.CreateShader: TBlackSharkParticleShader;
begin
  Result := TParticlesMultiUVSingleColor.TParticlesShader(BSShaderManager.Load(ClassName,
      AnsiString(TParticlesMultiUV.VSH), AnsiString(TParticlesMultiUVSingleColor.FSH_Col), TParticlesMultiUVSingleColor.TParticlesShader));
end;

procedure TParticlesMultiUVSingleColor.DrawProto(Instance: PRendererGraphicInstance);
var
  i, pos_ar, pos_ind: int32;
  step: int32;
begin
  if FCountParticle = 0 then
    exit;

  // define draw method by indexes
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  glUniformMatrix4fv( Shader.MVP^.Location, 1, GL_FALSE, @Instance.LastMVP );
  if TranslateColorAsHLS then
    glUniform3fv( TParticlesMultiUVSingleColor.TParticlesShader(Shader).FColor^.Location, 1, @ HLS)    //FColor
  else
    glUniform3fv( TParticlesMultiUVSingleColor.TParticlesShader(Shader).FColor^.Location, 1, @ FColor);
  { show bitmap from texture areas }
  BSTextureManager.UseTexture(FTexture^.Texture);
  i := 0;
  pos_ar := 0;
  pos_ind := 0;
  while i < FCountParticle do
  begin
    if i + MAX_COUNT_PARTICLE_ONE_OF_FOUR > FCountParticle then
      step := FCountParticle - i
    else
      step := MAX_COUNT_PARTICLE_ONE_OF_FOUR;
    glVertexAttribPointer(Shader.FPosition.Location, 4, GL_FLOAT, GL_FALSE, SizeOf(TParticle), FParticles.ShiftData[pos_ar]);
    glVertexAttribPointer(TParticlesMultiUVSingleColor.TParticlesShader(Shader).FUVPosition.Location, 2,
      GL_FLOAT, GL_FALSE, SizeOf(TParticle), @(PParticle(FParticles.ShiftData[pos_ar])^.Data));


    if FIsPoints then
    begin
      { TODO: draw points }
      { show bitmap by points; very slowly glDrawArrays for GL_POINTS, look for
       reasons in sources "libGLESv2.dll" ...}
      //  glUniform3f(TBlackSharkParticlePointShaderSingleColor(Shader).FColor.Location, FDefaultColor.r, FDefaultColor.g, FDefaultColor.b);
      glDrawArrays(GL_POINTS, 0, FParticles.Count);
    end else
    begin
      glDrawElements (GL_TRIANGLES, step * 6, GL_UNSIGNED_SHORT, Indexes.ShiftData[pos_ind]);
    end;
    inc(pos_ar, step shl 2);
    inc(pos_ind, step * 6);
    inc(i, step);
  end;
end;

procedure TParticlesMultiUVSingleColor.SetColor(const Value: TVec4f);
begin
  FColor := Value;
  HLS := RGBtoHLS(vec3(FColor.x, FColor.y, FColor.z));
end;

{ TBlackSharkParticles<T>.TDefaultGraphicObject }

procedure TBlackSharkParticles<T>.TDefaultGraphicObject.AfterConstruction;
begin
  inherited;
  if FMesh = nil then
    Mesh := CreateMesh;
end;

class function TBlackSharkParticles<T>.TDefaultGraphicObject.CreateMesh: TMesh;
begin
  Result := TMeshP.Create;
end;

{ TParticlesMultiUVReplaceSingleColor }

constructor TParticlesMultiUVReplaceSingleColor.Create(ARenderer: TBlackSharkRenderer; AParticleBox: TGraphicObject);
begin
  inherited;
  TranslateColorAsHLS := true;
end;

function TParticlesMultiUVReplaceSingleColor.CreateShader: TBlackSharkParticleShader;
begin
  Result := TBlackSharkParticleShader(BSShaderManager.Load(ClassName,
      AnsiString(TParticlesMultiUV.VSH), AnsiString(TParticlesMultiUVReplaceSingleColor.FSH_COL_REP),
      TParticlesMultiUVSingleColor.TParticlesShader));
end;

{ TBlackSharkInstancing2d }

constructor TBlackSharkInstancing2d.Create(ARenderer: TBlackSharkRenderer; APrototype: TCanvasObject);
begin
  Assert(APrototype.Data.InheritsFrom(TObjectVertexes));
  inherited Create(ARenderer, TObjectVertexes(APrototype.Data));
  PrototypeCanvasObject := APrototype;
  FPostions2d := TListVec<TVec2f>.Create;
end;

destructor TBlackSharkInstancing2d.Destroy;
begin
  FPostions2d.Free;
  inherited;
end;

function TBlackSharkInstancing2d.GetPosition2d(AIndex: int32): TVec2f;
begin
  Result := FPostions2d.Items[AIndex];
end;

procedure TBlackSharkInstancing2d.SetPosition2d(AIndex: int32; const AValue: TVec2f);
begin
  FPostions2d.Items[AIndex] := AValue;
  PrototypeCanvasObject.Position2d := AValue;
  Position[AIndex] := PrototypeCanvasObject.Data.Position;
end;

end.
