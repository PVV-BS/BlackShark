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

unit bs.shader;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.basetypes
  , bs.log
  , bs.collections
  , bs.strings
  ;

type

  TTypeShader = (tsVertex, tsFragment);
  TShaderTypeLocations = (slNone, slUniform, slAttribute, slVarying);

  TShaderBaseTypes = (stNone,
    stVoid, stBool, stInt, stUInt, stFloat, stDouble,
    stVec2, stVec3, stVec4,
    stDVec2, stDVec3, stDVec4,
    stIVec2, stIVec3, stIVec4,
    stUVec2, stUVec3, stUVec4,
    stBVec2, stBVec3, stBVec4,
    stMat2, stMat3, stMat4,
    stMat2x3, stMat2x4,
    stMat3x2, stMat3x4,
    stMat4x2, stMat4x3,
    stDMat2, stDMat3, stDMat4,
    stDMat2x3, stDMat2x4,
    stDMat3x2, stDMat3x4,
    stDMat4x2, stDMat4x3,
    stSampler2D,
    stStruct,
    stArray
    );
const
  // TODO: Check Syntax accoding specification
  ShaderBaseTypesSyntax: array[TShaderBaseTypes] of AnsiString = ( 'NAN',
    'void', 'bool', 'int', 'uint', 'float', 'double',
    'vec2', 'vec3', 'vec4',
    'dvec2', 'dvec3', 'dvec4',
    'ivec2', 'ivec3', 'ivec4',
    'uvec2', 'uvec3', 'uvec4',
    'bvec2', 'bvec3', 'bvec4',
    'mat2', 'mat3', 'mat4',
    'mat2x3', 'mat2x4',
    'mat3x2', 'mat3x4',
    'mat4x2', 'mat4x3',
    'dmat2', 'dmat3', 'dmat4',
    'dmat2x3', 'dmat2x4',
    'dmat3x2', 'dmat3x4',
    'dmat4x2', 'dmat4x3',
    'sampler2D',
    'struct',
    'array'
  );

type
  TBlackSharkShader = class;
  PShaderParametr = ^TShaderParametr;
  TShaderParametr = record
    Name: AnsiString;
    Location: GLInt;
    DataTypeGL: GLUint;
    ParametrType: TShaderBaseTypes;
    MicroProgramm: AnsiString;
    AutoLink: boolean;
    class operator Add(a, b: TShaderParametr): TShaderParametr;
    class operator Subtract(a, b: TShaderParametr): TShaderParametr;
    class operator Multiply(a, b: TShaderParametr): TShaderParametr;
    class operator Divide(a, b: TShaderParametr): TShaderParametr;
    class operator Implicit(a: TShaderParametr): AnsiString;
  end;

  TListShaderParametrs = TListVec<PShaderParametr>;
  // Handler state automat;
  TOnFindFild = function (Ptr: PAnsiChar): int32 of object;
  POnFindFild = ^TOnFindFild;

  { TShaderParser }

  TShaderParser = class
  private
    type
      PFildHandler = ^TFildHandler;
      TFildHandler = record
        Handler: TOnFindFild;
      end;

  private
    /////////////////////// parser methods and varables ////////////////////////
    FParser: TBinTree<PFildHandler>;
    FShader: TBlackSharkShader;
    NowReadLocations: TShaderTypeLocations;
    NowReadType: TShaderBaseTypes;
    ReadedNameLocations: AnsiString;
    LevelFunction: int32;
    CarrentPosParser: int32;
    MainBodyPosBegin: int32;
    MainBodyPosEnd: int32;
    HeaderEnd: int32;
    FTypeShader: TTypeShader;
    function ReadFildName(PtrBegin: PAnsiChar): AnsiString;
    procedure CheckReadedLocations;
    procedure AddFildHandler(Signature: AnsiString; Handler: TOnFindFild);
    // handlers automat "FParser" states
    function OnUniformFind({%H-}Ptr: PAnsiChar): int32;   // "uniform"
    function OnAttributeFind({%H-}Ptr: PAnsiChar): int32; // "attribute"
    function OnVariableFind({%H-}Ptr: PAnsiChar): int32;  // "varying"
    function OnCommentFind(Ptr: PAnsiChar): int32;   // comment: //
    function OnComment2Find(Ptr: PAnsiChar): int32;  // comment: /*  */
    function OnEOLFind({%H-}Ptr: PAnsiChar): int32;       // 0x0A0D
    function OnTypeVoidFind({%H-}Ptr: PAnsiChar): int32;  // "void"
    function OnTypeBoolFind({%H-}Ptr: PAnsiChar): int32;  // "bool"
    function OnTypeFloatFind({%H-}Ptr: PAnsiChar): int32;  // "float"
    function OnTypeDoubleFind({%H-}Ptr: PAnsiChar): int32;  // "double"
    function OnTypeIntFind({%H-}Ptr: PAnsiChar): int32;   // "int"
    function OnTypeUIntFind({%H-}Ptr: PAnsiChar): int32;  // "uint"
    function OnTypeSampler2DFind(Ptr: PAnsiChar): int32;   // "sampler2D"
    function OnTypeMatFind(Ptr: PAnsiChar): int32;   // "mat"
    function OnTypeDMatFind(Ptr: PAnsiChar): int32;  // "dmat"
    function OnTypeVecFind(Ptr: PAnsiChar): int32;   // "vec"
    function OnTypeDVecFind(Ptr: PAnsiChar): int32;   // "dvec"
    function OnMainFind(Ptr: PAnsiChar): int32;      // " main()"
    function OnBeginBlockFind({%H-}Ptr: PAnsiChar): int32;// "{"
    function OnEndBlockFind({%H-}Ptr: PAnsiChar): int32;  // "}"
    function OnFuncNameFind({%H-}Ptr: PAnsiChar): int32;  // "("
    procedure InitParser;
    ////////////////////////////////////////////////////////////////////////////
  public
    constructor Create(AShader: TBlackSharkShader);
    procedure ParseShader(const Shader: pAnsiChar; TypeShader: TTypeShader);
    destructor Destroy; override;
  end;

  TTableParams = THashTable<AnsiString, PShaderParametr>;

  { TBlackSharkShader }

  TBlackSharkShader = class abstract
  strict private
    FName: string;
    // container for all shader locations; need for quick access to shader locations by name
    Params: TTableParams;
    function GetAttribute(const NameAttribute: AnsiString): PShaderParametr;
    function GetUniform(const NameUniform: AnsiString): PShaderParametr;
    function LinkUniformLocation(const UniformName: AnsiString): Glint; inline;
    function LinkAttribLocation(const AttribName: AnsiString): Glint; inline;
  private
    _Counter: int32;
    FProgramID: GLint;
    FShader: array[TTypeShader] of AnsiString;
    FMVPasUniform: boolean;
    function GetShader(index: TTypeShader): AnsiString;
  protected
    FUniforms: array[TTypeShader] of TListShaderParametrs;
    FAttributes: array[TTypeShader] of TListShaderParametrs;
    FVariables: array[TTypeShader] of TListShaderParametrs;
  public
    VertexComponentLocations: array[TVertexComponent] of GLInt;
    VertexComponentTypes: array[TVertexComponent] of GLUInt;
    constructor Create(const AName: string; const ADataVertex, ADataFragment: PAnsiChar); virtual;
    destructor Destroy; override;
    class function DefaultName: string; virtual;
    function LoadShader: boolean;
    procedure Unload;
    procedure Reset;
    function LinkLocations: boolean; virtual;
    function _AddRef: int32;
    function AddUniform(const NameUniform: AnsiString; TypeUniform: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr; virtual;
    function AddAttribute(const NameAttribute: AnsiString; TypeAttribute: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr; virtual;
    function AddVariable(const NameVariable: AnsiString; TypeVariable: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr; virtual;
    // methods to linking uniforms and attributes; call after compiled shader programm;
    // LinkLocations allow a descendants bind specific parameters by specific names
    // engage the vertex or fragment program; call befor draw with first using this shader
    procedure UseProgram(AEnableAttrib: boolean); virtual;
    property Name: string read FName;
    property ProgramID: GLint read FProgramID;
    property Uniform[const NameUniform: AnsiString]: PShaderParametr read GetUniform;
    property Attribute[const NameAttribute: AnsiString]: PShaderParametr read GetAttribute;
    property Shader[index: TTypeShader]: AnsiString read GetShader;
    property MVPasUniform: boolean read FMVPasUniform write FMVPasUniform;
  end;

  TBlackSharkShaderClass = class of TBlackSharkShader;

  {
    TBlackSharkVertexOutShader
  }

  TBlackSharkVertexOutShader = class abstract (TBlackSharkShader)
  private
    { input uniforms }
    FMVP: PShaderParametr;

    FOpacity: PShaderParametr;
    { input variables }
    FPosCoord: PShaderParametr;
  public
    function LinkLocations: boolean; override;
    { input uniforms }
    property Opacity: PShaderParametr read FOpacity;
    property MVP: PShaderParametr read FMVP;
    { input variables }
    property PosCoord: PShaderParametr read FPosCoord;
  end;

  { TBlackSharkVertexOutShader }

  TBlackSharkLayoutShader = class(TBlackSharkShader)
  private
    { base input }
    { input uniforms }
    FMVP: PShaderParametr;
    { input variables }
    FPosCoord: PShaderParametr;
    { color uniform }
    FColor: PShaderParametr;
  public
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { input variables }
    property PosCoord: PShaderParametr read FPosCoord;
    { input uniforms }
    property MVP: PShaderParametr read FMVP;
    { color uniform }
    property Color: PShaderParametr read FColor;
  end;

  TBlackSharkFogOutShader = class(TBlackSharkVertexOutShader)
  private
    { base input }
    { input uniforms }
    FTime: PShaderParametr;
    FResolution: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    { base input }
    { input uniforms }
    property Time: PShaderParametr read FTime;
    property Resolution: PShaderParametr read FResolution;
  end;

  TBlackSharkColoredVertexesShader = class(TBlackSharkVertexOutShader)
  private
    { input variable }
    FColors: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { input variable }
    property Colors: PShaderParametr read FColors;
  end;

  TBlackSharkColorSelectorShader = TBlackSharkColoredVertexesShader;

  TBlackSharkColoredRGBAVertexesShader = class(TBlackSharkVertexOutShader)
  private
    { input variable }
    FColors: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { input variable }
    property Colors: PShaderParametr read FColors;
  end;

  TBlackSharkStrokeCurveShader = class(TBlackSharkVertexOutShader)
  private
    { input uniform }
    FStrokeLen: PShaderParametr;
    { input variable }
    FDistance: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    function LinkLocations: boolean; override;
    { input uniform }
    property StrokeLen: PShaderParametr read FStrokeLen;
    { input variable }
    property Distance: PShaderParametr read FDistance;
  end;

  TBlackSharkStrokeCurveSingleColorShader = class(TBlackSharkStrokeCurveShader)
  private
    { input variable }
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { color uniform }
    property Color: PShaderParametr read FColor;
  end;

  TBlackSharkStrokeCurveMulticoloredShader = class(TBlackSharkStrokeCurveShader)
  private
    { input variable }
    FColors: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { input variable }
    property Colors: PShaderParametr read FColors;
  end;

  { TSimpleTextureOutShader }

  TSimpleTextureOutShader = class abstract(TBlackSharkVertexOutShader)
  private
    { base input }
    FTexSampler: PShaderParametr;
    { input variables }
    FTexCoord: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    function LinkLocations: boolean; override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    { input uniforms }
    property TexSampler: PShaderParametr read FTexSampler;
    { input variables }
    property TexCoord: PShaderParametr read FTexCoord;
  end;

  {
    TBlackSharkTextureOutShader

    The shader for output textures from atlas
  }

  TBlackSharkTextureOutShader = class(TBlackSharkVertexOutShader)
  private
    { base input }
    { input uniforms }
    FAreaUV: PShaderParametr;
    { input variables }
    FTexCoord: PShaderParametr;
    FTexSampler: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    { input uniforms }
    property AreaUV: PShaderParametr read FAreaUV;
    property TexSampler: PShaderParametr read FTexSampler;
    { input variables }
    property TexCoord: PShaderParametr read FTexCoord;
  end;

  { TBlackSharkTexToColorShader }

  { Shader fills vertexes single color, but transparent each a texel gets from a texture  }

  TBlackSharkTexToColorShader = class(TBlackSharkTextureOutShader)
  private
    { color uniform }
    FColor: PShaderParametr;
  public
    function LinkLocations: boolean; override;
    { color uniform }
    property Color: PShaderParametr read FColor;
  end;

  { Shader replaces a color texture through HLS (hue, lightness/intensity, saturation) parameters }

  TBlackSharkTexToColorHLSShader = class(TBlackSharkTextureOutShader)
  private
    { color uniform }
    FHLS: PShaderParametr;
  public
    function LinkLocations: boolean; override;
    { HLS uniform }
    property HLS: PShaderParametr read FHLS;
  end;

  TTextFromTextureShader = class(TSimpleTextureOutShader)
  private
    { color uniform }
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    { color uniform }
    property Color: PShaderParametr read FColor;
  end;

  { The shader fills all vertexes a single color }

  TBlackSharkVectorToSingleColorShader = class(TBlackSharkVertexOutShader)
  private
    { color uniform }
    FColor: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    { color uniform }
    property Color: PShaderParametr read FColor;
  end;

  TBlackSharkVectorToDoubleColorShader = class(TBlackSharkVectorToSingleColorShader)
  private
    { color uniform }
    FColor2: PShaderParametr;
    FColorIndex: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { color uniform }
    property Color2: PShaderParametr read FColor2;
    { input variables }
    property ColorIndex: PShaderParametr read FColorIndex;
  end;

  { TBlackSharkSkeletonShader }

  TBlackSharkSkeletonShader = class abstract(TBlackSharkVertexOutShader)
  public
    const
      // when will change it value here, change it in the file SkeletonTextured.MAX_COUNT_BONES too!
      MAX_COUNT_BONES = 32;
  private
    FBones: PShaderParametr;
    FWeights: PShaderParametr;
    FCurrentTransforms: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    { input uniforms }
    property CurrentTransforms: PShaderParametr read FCurrentTransforms;
    { input variables }
    property Bones: PShaderParametr read FBones;
    property Weights: PShaderParametr read FWeights;
  end;

  { TBlackSharkSingleColorAniShader }
  // TODO
  TBlackSharkSingleColorAniShader = class(TBlackSharkSkeletonShader)

  end;

  TBlackSharkSkeletonTexturedShader = class(TBlackSharkSkeletonShader)
  private
    FTexSampler: PShaderParametr;
    FAreaUV: PShaderParametr;
    { input variables }
    FTexCoord: PShaderParametr;
  public
    constructor Create(const AName: string; const ADataVertex, ADataFragment: PAnsiChar); override;
    class function DefaultName: string; override;
    function LinkLocations: boolean; override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    { input uniforms }
    property AreaUV: PShaderParametr read FAreaUV;
    property TexSampler: PShaderParametr read FTexSampler;
    { input variables }
    property TexCoord: PShaderParametr read FTexCoord;
  end;

  { TBlackSharkTextureAniShader }

  TBlackSharkTextureAniShader = class(TBlackSharkTextureOutShader)
  private
    FTexSampler2: PShaderParametr;
    FTime: PShaderParametr;

  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    { input uniforms }
    property Time: PShaderParametr read FTime;
    property TexSampler2: PShaderParametr read FTexSampler2;
  end;

  TBlackSharkAutoParseShader = class abstract(TBlackSharkShader)
  private
    procedure ParceShader(const DataVertex, DataFragment: PAnsiChar);
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
  end;

  TBlackSharkAutoBuildShader = class abstract (TBlackSharkShader)
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    // build shader text; in case success return true, else Send error message to Log File
    // evry descendant must do self operation for main function shader and place to TShaderParametr.Microprogramm
    function Build: boolean; virtual;
    function SaveToFile(FileName: WideString): boolean;
  end;

  TBlackSharkQUADShader = class(TBlackSharkShader)
  private
    FTexSampler: PShaderParametr;
    FPosition: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    property TexSampler: PShaderParametr read FTexSampler;
    property Position: PShaderParametr read FPosition;
  end;

  TBlackSharkSmoothMSAA = class(TBlackSharkQUADShader)
  private
    FRatioResolutions: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    property RatioResolutions: PShaderParametr read FRatioResolutions;
  end;

  TBlackSharkSmoothByKernelMSAA = class(TBlackSharkSmoothMSAA)
  private
    FKernel: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    property Kernel: PShaderParametr read FKernel;
  end;

  TBlackSharkSmoothFXAA = class(TBlackSharkQUADShader)
  private
    FResolution: PShaderParametr;
    FResolutionInv: PShaderParametr;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    property Resolution: PShaderParametr read FResolution;
    property ResolutionInv: PShaderParametr read FResolutionInv;
  end;

  { TBlackSharkColorOutShader }

  TBlackSharkColorOutShader = class(TBlackSharkAutoParseShader)
  private
    FColorLocName: AnsiString;
    FColorLoc: PShaderParametr;
    FPosCoordName: AnsiString;
    FPosCoord: PShaderParametr;
    FMVP: PShaderParametr;
    FMVPName: AnsiString;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    destructor Destroy; override;
    procedure UseProgram(AEnableAttrib: boolean); override;
    property ColorLoc: PShaderParametr read FColorLoc;
    property ColorLocName: AnsiString read FColorLocName write FColorLocName;
    property PosCoord: PShaderParametr read FPosCoord;
    property PosCoordName: AnsiString read FPosCoordName write FPosCoordName;
    property MVP: PShaderParametr read FMVP;
    property MVPName: AnsiString read FMVPName write FMVPName;
  end;

  { TBlackSharkSingleColorOutShader }

  TBlackSharkSingleColorOutShader = class(TBlackSharkAutoParseShader)
  private
    FColorLocName: AnsiString;
    FColorLoc: PShaderParametr;
    FPosCoordName: AnsiString;
    FPosCoord: PShaderParametr;
    FMVP: PShaderParametr;
    FMVPName: AnsiString;
  public
    constructor Create(const AName: string; const DataVertex, DataFragment: PAnsiChar); override;
    destructor Destroy; override;
    property ColorLoc: PShaderParametr read FColorLoc;
    property ColorLocName: AnsiString read FColorLocName write FColorLocName;
    property PosCoord: PShaderParametr read FPosCoord;
    property PosCoordName: AnsiString read FPosCoordName write FPosCoordName;
    property MVP: PShaderParametr read FMVP;
    property MVPName: AnsiString read FMVPName write FMVPName;
  end;

  TShaderKind = (skSingleColor, skTextured, skSingleColorAndAnimated, skTexturedAndAnimated);

  { BSShaderManager }

  BSShaderManager = class
  private
    class var FShadersName: THashTable<string, TBlackSharkShader>;
    class var FLastUsedShader: TBlackSharkShader;
    class var FLastUsedShaderAttrEnabled: boolean;
    class procedure Add(BSShader: TBlackSharkShader);
    class function GetShaderByName(const Name: string; MvpAsUniform: boolean): TBlackSharkShader;
    class constructor Create;
    class destructor Destroy;
  public
    class function Load(const AFileNameVertex, AFileNameFragment: string;
      AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader; overload;
    class function Load(const AName: string;const ADataVertex, ADataFragment: AnsiString;
      AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader; overload;
    class function Load(const AName: string; const ADataVertex, ADataFragment: PAnsiChar;
      AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader; overload;
    class function Load(const AName: string; AShaderClass: TBlackSharkShaderClass;
      AMVPasUniform: boolean = true): TBlackSharkShader; overload;
    class function Load(AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader; overload;
    class procedure Restore;
    class procedure UseShader(AShader: TBlackSharkShader; AEnableAttrib: boolean);
    class procedure FreeShader(Shader: TBlackSharkShader);
    class var property ShaderByName[const Name: string; MvpAsUniform: Boolean]: TBlackSharkShader read GetShaderByName;
  end;

  procedure CreateVBO(var VBO: GlUInt; Taget { GL_ARRAY_BUFFER ...}: GLInt; Data: Pointer; SizeData: int32; ModeDraw: GLEnum = GL_STATIC_DRAW); //inline;

const
  SHADER_TYPE_TO_GL: array[TShaderBaseTypes] of GLUint =
  (
    GL_UNSIGNED_INT,
    GL_UNSIGNED_INT, // ??? stVoid,
    GL_BOOL,
    GL_INT, GL_UNSIGNED_INT, GL_FLOAT,
    GL_FLOAT, // ??? stDouble,
    GL_FLOAT, GL_FLOAT, GL_FLOAT, // 'vec2', 'vec3', 'vec4'
    GL_FLOAT, GL_FLOAT, GL_FLOAT, // ??? 'dvec2', 'dvec3', 'dvec4'
    GL_INT, GL_INT, GL_INT, // 'ivec2', 'ivec3', 'ivec4'
    GL_UNSIGNED_INT, GL_UNSIGNED_INT, GL_UNSIGNED_INT, //stUVec2, stUVec3, stUVec4,
    GL_BYTE, GL_BYTE, GL_BYTE, //stBVec2, stBVec3, stBVec4,
    GL_FLOAT, GL_FLOAT, GL_FLOAT, //stMat2, stMat3, stMat4,
    GL_FLOAT, GL_FLOAT, //stMat2x3, stMat2x4,
    GL_FLOAT, GL_FLOAT, //stMat3x2, stMat3x4,
    GL_FLOAT, GL_FLOAT, //stMat4x2, stMat4x3,
    GL_FLOAT, GL_FLOAT, GL_FLOAT, // ??? stDMat2, stDMat3, stDMat4,
    GL_FLOAT, GL_FLOAT, // ??? stDMat2x3, stDMat2x4,
    GL_FLOAT, GL_FLOAT, // ??? stDMat3x2, stDMat3x4,
    GL_FLOAT, GL_FLOAT, // ??? stDMat4x2, stDMat4x3,
    GL_UNSIGNED_INT,    // ??? stSampler2D,
    GL_UNSIGNED_INT,    // ??? stStruct,
    GL_UNSIGNED_INT     // ??? stArray,
  );

implementation

uses
    bs.utils
  ;

procedure CreateVBO(var VBO: GlUInt; Taget: GLInt; Data: Pointer; SizeData: int32; ModeDraw: GLEnum = GL_STATIC_DRAW);
begin
  if VBO = 0 then
    glGenBuffers(1, @VBO);
  if (VBO = 0) then
  begin
    BSWriteMsg('BlackSharkSubGraphicItem.CreateVBO', 'Cannot create VBO!');
    exit;
  end;
  if (SizeData > 0) then
  begin
    glBindBuffer(Taget, VBO);
    glBufferData(Taget, SizeData, Data, ModeDraw);
  end;
end;

{ TBlackSharkVertexOutShader }

function TBlackSharkVertexOutShader.LinkLocations: boolean;
begin
  if FMVPasUniform then
    FMVP := AddUniform('MVP', stMat4, tsVertex)
  else
    FMVP := AddAttribute('MVP', stMat4, tsVertex);

  FPosCoord := AddAttribute('a_position', stVec3, tsVertex);
  FOpacity := AddUniform('Opacity', stFloat, tsFragment);
  Result := inherited LinkLocations;
  VertexComponentLocations[vcCoordinate] := FPosCoord^.Location;
  VertexComponentTypes[vcCoordinate] := FPosCoord^.DataTypeGL;
end;

{ TBlackSharkTexToColorShader }

function TBlackSharkTexToColorShader.LinkLocations: boolean;
begin
  FColor := AddUniform('Color', stVec4, tsFragment);
  Result := inherited;
end;

{ BSShaderManager }

class procedure BSShaderManager.Add(BSShader: TBlackSharkShader);
begin
  if not FShadersName.TryAdd(BSShader.Name + BoolToStr(BSShader.MVPasUniform), BSShader) then
  begin
    BSWriteMsg(String('BSShaderManager.Add'), String('Filed adding the shader, because Name = ') + String(BSShader.Name) + String(' alredy exists!'));
    exit;
  end;
end;

class function BSShaderManager.GetShaderByName(const Name: string; MvpAsUniform: boolean): TBlackSharkShader;
begin
  FShadersName.Find(Name + BoolToStr(MvpAsUniform), Result);
end;

class function BSShaderManager.Load(AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean): TBlackSharkShader;
begin
  Result := Load(AShaderClass.DefaultName, AShaderClass, AMVPasUniform);
end;

class function BSShaderManager.Load(const AName: string; AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader;
var
  name: string;
begin
  if AName = '' then
    name := AShaderClass.DefaultName
  else
    name := AName;

  Result := Load(AppPath + 'Shaders' + PathDelim + name + '.vsh', AppPath + 'Shaders' + PathDelim + name + '.fsh', AShaderClass, AMVPasUniform);
end;

class procedure BSShaderManager.Restore;
var
  bucket: THashTable<string, TBlackSharkShader>.TBucket;
  begin
  if FShadersName.GetFirst(bucket) then
  repeat
    bucket.Value.Reset;
    bucket.Value.LoadShader;
  until not FShadersName.GetNext(bucket);
end;

class procedure BSShaderManager.UseShader(AShader: TBlackSharkShader; AEnableAttrib: boolean);
begin
  if (AShader <> FLastUsedShader) or (FLastUsedShaderAttrEnabled <> AEnableAttrib) then
  begin
    FLastUsedShader := AShader;
    FLastUsedShaderAttrEnabled := AEnableAttrib;
    if Assigned(FLastUsedShader) then
      FLastUsedShader.UseProgram(AEnableAttrib)
    else
      glUseProgram(0);
  end;
end;

class constructor BSShaderManager.Create;
begin
  FShadersName := THashTable<string, TBlackSharkShader>.Create(@GetHashBlackSharkS, @StrCmpBool);
end;

class destructor BSShaderManager.Destroy;
var
  bucket: THashTable<string, TBlackSharkShader>.TBucket;
begin
  if FShadersName.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FShadersName.GetNext(bucket);

  FShadersName.Free;
  inherited;
end;

class function BSShaderManager.Load(const AFileNameVertex, AFileNameFragment: string;
  AShaderClass: TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader;
var
  msfs: TMemoryStream;
  msvs: TMemoryStream;
  nu8: string;
  w: uint16;
begin

  nu8 := ChangeFileExt(ExtractFileName(AFileNameFragment), '');

  if FShadersName.Find(nu8 + BoolToStr(AMVPasUniform), Result) then
    exit;

  {$ifdef DEBUG_BS}
  BSWriteMsg('BSShaderManager.Load: shader name', '"' + nu8 + '"');
  {$endif}

  {$ifdef DEBUG_BS}
  if not FileExists(AFileNameVertex) then
    BSWriteMsg('BSShaderManager.Load: ', 'The file "' + AFileNameVertex + '" does not exists');
  {$endif}

  {$ifdef DEBUG_BS}
  if not FileExists(AFileNameFragment) then
    BSWriteMsg('BSShaderManager.Load: ', 'The file "' + AFileNameFragment + '" does not exists');
  {$endif}

  msfs := TMemoryStream.Create;
  msvs := TMemoryStream.Create;
  try
    w := 0;
    msvs.LoadFromFile(AFileNameVertex);
    msvs.Position := msvs.Size;
    msvs.WriteBuffer(w, SizeOf(w));
    msfs.LoadFromFile(AFileNameFragment);
    msfs.Position := msfs.Size;
    msfs.WriteBuffer(w, SizeOf(w));
    Result := Load(nu8, PAnsiChar(msvs.Memory), PAnsiChar(msfs.Memory), AShaderClass, AMVPasUniform);
  finally
    msfs.Free;
    msvs.Free;
  end;
end;

class function BSShaderManager.Load(const AName: string; const ADataVertex,
  ADataFragment: AnsiString; AShaderClass :TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader;
begin
  Result := Load(AName, PAnsiChar(@ADataVertex[1]), PAnsiChar(@ADataFragment[1]), AShaderClass, AMVPasUniform);
end;

class function BSShaderManager.Load(const AName: string; const ADataVertex,
  ADataFragment: PAnsiChar; AShaderClass :TBlackSharkShaderClass; AMVPasUniform: boolean = true): TBlackSharkShader;
var
  name: string;
begin

  if AName = '' then
    name := AShaderClass.DefaultName
  else
    name := AName;

  if FShadersName.Find(AName + BoolToStr(AMVPasUniform), Result) then
    exit;

  UseShader(nil, false);

  Result := AShaderClass.Create(name, ADataVertex, ADataFragment);
  Result.MVPasUniform := AMVPasUniform;
  Result.LinkLocations;
  Add(Result);
end;

class procedure BSShaderManager.FreeShader(Shader: TBlackSharkShader);
begin
  if (Shader = nil) then
    exit;
  dec(Shader._Counter);
  if Shader._Counter <= 0 then
  begin
    //FShadersID.Remove(Shader.ProgramID);
    FShadersName.Delete(Shader.Name + BoolToStr(Shader.MVPasUniform));
    Shader.Free;
  end;
end;

{ TShaderParser }

function TShaderParser.ReadFildName(PtrBegin: PAnsiChar): AnsiString;
var
  pos_name, pos_end: int32;
begin
  pos_name := 0; // lenght("uniform ")
  while PtrBegin[pos_name] = ' ' do
    inc(pos_name);
  pos_end := pos_name;
  while (PtrBegin[pos_end] <> ' ') and (PtrBegin[pos_end] <> ';') do
    inc(pos_end);
  SetLength(Result, pos_end - pos_name);
  move(PtrBegin[pos_name], Result[1], pos_end - pos_name);
end;

procedure TShaderParser.CheckReadedLocations;
begin
  case NowReadLocations of
    slUniform: FShader.AddUniform(ReadedNameLocations, NowReadType, FTypeShader);
    slAttribute: FShader.AddAttribute(ReadedNameLocations, NowReadType, FTypeShader);
    slVarying: FShader.AddVariable(ReadedNameLocations, NowReadType, FTypeShader);
  end;
  ReadedNameLocations := '';
  NowReadType := stNone;
  NowReadLocations := slNone;
end;

procedure TShaderParser.AddFildHandler(Signature: AnsiString;
  Handler: TOnFindFild);
var
  h: PFildHandler;
begin
  new(h);
  h^.Handler := Handler;
  FParser.Add(Signature, h);
end;

function TShaderParser.OnUniformFind(Ptr: PAnsiChar): int32;
begin
  Result := 8; // lenght("uniform ")
  NowReadLocations := TShaderTypeLocations.slUniform;
end;

function TShaderParser.OnAttributeFind(Ptr: PAnsiChar): int32;
begin
  Result := 10; // lenght("attribute ")
  NowReadLocations := TShaderTypeLocations.slAttribute;
  //ReadedNameLocations := ReadFildName(@Ptr[Result]);
  //inc(Result, Length(ReadedNameLocations));
end;

function TShaderParser.OnVariableFind(Ptr: PAnsiChar): int32;
begin
  Result := 8; // lenght("varying ")
  NowReadLocations := TShaderTypeLocations.slVarying;
  //ReadedNameLocations := ReadFildName(@Ptr[Result]);
  //inc(Result, Length(ReadedNameLocations));
end;

function TShaderParser.OnCommentFind(Ptr: PAnsiChar): int32;
begin
  Result := 2;
  while (byte(Ptr[Result]) <> $0D) do
    inc(Result);
  inc(Result);
end;

function TShaderParser.OnComment2Find(Ptr: PAnsiChar): int32;
begin
  Result := 0;
  while (Ptr[Result] <> '*') and (Ptr[Result+1] <> '/') do
    inc(Result);
  inc(Result);
end;

function TShaderParser.OnEOLFind(Ptr: PAnsiChar): int32;
begin
  NowReadLocations := TShaderTypeLocations.slNone;
  ReadedNameLocations := '';
  NowReadType := stNone;
  Result := 2;
end;

function TShaderParser.OnTypeVoidFind(Ptr: PAnsiChar): int32;
begin
  Result := 5;
  NowReadType := stVoid;
end;

function TShaderParser.OnTypeBoolFind(Ptr: PAnsiChar): int32;
begin
  Result := 5;
  NowReadType := stBool;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeFloatFind(Ptr: PAnsiChar): int32;
begin
  Result := 6;
  NowReadType := stFloat;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeDoubleFind(Ptr: PAnsiChar): int32;
begin
  Result := 7;
  NowReadType := stDouble;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeIntFind(Ptr: PAnsiChar): int32;
begin
  Result := 4;
  NowReadType := stInt;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeUIntFind(Ptr: PAnsiChar): int32;
begin
  Result := 5;
  NowReadType := stUInt;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeSampler2DFind(Ptr: PAnsiChar): int32;
begin
  Result := 10;
  NowReadType := stSampler2D;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeMatFind(Ptr: PAnsiChar): int32;
begin
  if Ptr[3] = 'x' then
    begin
    Result := 7;
    case Ptr[3] of
      '2':
        case Ptr[5] of
          '2': NowReadType := stMat2;
          '3': NowReadType := stMat2x3;
          '4': NowReadType := stMat2x4;
        end;
      '3':
        case Ptr[5] of
          '2': NowReadType := stMat3x2;
          '3': NowReadType := stMat3;
          '4': NowReadType := stMat3x4;
        end;
      '4':
        case Ptr[5] of
          '2': NowReadType := stMat4x2;
          '3': NowReadType := stMat4x3;
          '4': NowReadType := stMat4;
        end;
    end;
    end else
    begin
    Result := 5;
    case Ptr[3] of
      '2': NowReadType := stMat2;
      '3': NowReadType := stMat3;
      '4': NowReadType := stMat4;
    end;
    end;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeDMatFind(Ptr: PAnsiChar): int32;
begin
  if Ptr[3] = 'x' then
    begin
    Result := 8;
    case Ptr[3] of
      '2':
        case Ptr[5] of
          '2': NowReadType := stDMat2;
          '3': NowReadType := stDMat2x3;
          '4': NowReadType := stDMat2x4;
        end;
      '3':
        case Ptr[5] of
          '2': NowReadType := stDMat3x2;
          '3': NowReadType := stDMat3;
          '4': NowReadType := stDMat3x4;
        end;
      '4':
        case Ptr[5] of
          '2': NowReadType := stDMat4x2;
          '3': NowReadType := stDMat4x3;
          '4': NowReadType := stDMat4;
        end;
    end;
    end else
    begin
    Result := 6;
    case Ptr[3] of
      '2': NowReadType := stDMat2;
      '3': NowReadType := stDMat3;
      '4': NowReadType := stDMat4;
    end;
    end;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeVecFind(Ptr: PAnsiChar): int32;
begin
  Result := 5;
  case Ptr[3] of
  '2': NowReadType := stVec2;
  '3': NowReadType := stVec3;
  '4': NowReadType := stVec4 else
    NowReadType := stNone;
  end;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnTypeDVecFind(Ptr: PAnsiChar): int32;
begin
  Result := 5;
  case Ptr[4] of
  '2': NowReadType := stDVec2;
  '3': NowReadType := stDVec3;
  '4': NowReadType := stDVec4 else
    NowReadType := stNone;
  end;
  ReadedNameLocations := ReadFildName(@Ptr[Result]);
  inc(Result, Length(ReadedNameLocations));
  CheckReadedLocations;
end;

function TShaderParser.OnMainFind(Ptr: PAnsiChar): int32;
begin
  HeaderEnd := CarrentPosParser;
  while (byte(Ptr[HeaderEnd]) <> $0d) do
    dec(HeaderEnd);
  Result := 7;
  while (byte(Ptr[Result]) <> $0a) do
    inc(Result);
  inc(Result);
  MainBodyPosBegin := CarrentPosParser + Result;
end;

function TShaderParser.OnBeginBlockFind(Ptr: PAnsiChar): int32;
begin
  Result := 1;
  if (LevelFunction = 0) and (MainBodyPosBegin > 0) then
    MainBodyPosBegin := CarrentPosParser + Result;
  inc(LevelFunction);
end;

function TShaderParser.OnEndBlockFind(Ptr: PAnsiChar): int32;
begin
  Result := 1;
  dec(LevelFunction);
  if (LevelFunction = 0) and (MainBodyPosBegin > 0) then
    MainBodyPosEnd := CarrentPosParser - 1;
end;

function TShaderParser.OnFuncNameFind(Ptr: PAnsiChar): int32;
begin
  Result := 1;
end;

procedure TShaderParser.ParseShader(const Shader: pAnsiChar; TypeShader: TTypeShader);
var
  len: int32;
  ptr_handler: PFildHandler;
begin
  MainBodyPosBegin := 0;
  MainBodyPosEnd := 0;
  CarrentPosParser := 0;
  HeaderEnd := 0;
  len := Length(Shader);
  FTypeShader := TypeShader;
  while (CarrentPosParser < len) do
    begin
    FParser.Find(@Shader[CarrentPosParser], len - CarrentPosParser, ptr_handler);
    if (ptr_handler <> nil) then
      begin
      inc(CarrentPosParser, ptr_handler^.Handler(@Shader[CarrentPosParser]));
      end else
      inc(CarrentPosParser);
    end;
end;

destructor TShaderParser.Destroy;
var
  h: PFildHandler;
begin
  FParser.Iterator.SetToBegin(h);
  while h <> nil do
    begin
    dispose(h);
    FParser.Iterator.Next(h);
    end;
  FParser.Free;
  inherited Destroy;
end;

procedure TShaderParser.InitParser;
begin
  FParser := TBinTree<PFildHandler>.Create;
  NowReadLocations := TShaderTypeLocations.slNone;
  NowReadType := TShaderBaseTypes.stNone;
  LevelFunction := 0;
  AddFildHandler('uniform', OnUniformFind);
  AddFildHandler('attribute', OnAttributeFind);
  AddFildHandler('varying', OnVariableFind);
  AddFildHandler('//', OnCommentFind);
  AddFildHandler('/*', OnComment2Find);
  AddFildHandler(#$0d + #$0a, OnEOLFind);
  AddFildHandler('void', OnTypeVoidFind);
  AddFildHandler('bool', OnTypeBoolFind);
  AddFildHandler('float', OnTypeFloatFind);
  AddFildHandler('double', OnTypeDoubleFind);
  AddFildHandler('int', OnTypeIntFind);
  AddFildHandler('uint', OnTypeUIntFind);
  AddFildHandler('vec', OnTypeVecFind);
  AddFildHandler('dvec', OnTypeDVecFind);
  AddFildHandler('mat', OnTypeMatFind);
  AddFildHandler('dmat', OnTypeDMatFind);
  AddFildHandler('sampler2D', OnTypeSampler2DFind);
  AddFildHandler(' main()', OnMainFind);
  AddFildHandler('{', OnBeginBlockFind);
  AddFildHandler('}', OnEndBlockFind);
  AddFildHandler('(', OnFuncNameFind);
end;

constructor TShaderParser.Create(AShader: TBlackSharkShader);
begin
  FShader := AShader;
  InitParser;
end;

  { TBlackSharkShader }

function TBlackSharkShader.LoadShader: boolean;
var
  VertexShaderID: GLuint;
  FragmentShaderID: GLuint;
  ps: PAnsiChar;
  len: GLInt;
begin

  // Create the shaders
  VertexShaderID := glCreateShader(GL_VERTEX_SHADER);
  if (VertexShaderID = 0) then
    exit(false);

  FragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER);
  if (FragmentShaderID = 0) then
  begin
    glDeleteShader(VertexShaderID);
    exit(false);
  end;

  try
    // Compile Vertex Shader
    ps := PAnsiChar(FShader[TTypeShader.tsVertex]);
    len := length(FShader[TTypeShader.tsVertex]);
    glShaderSource(VertexShaderID, 1, PPAnsiChar(@ps), @len);
  	glCompileShader(VertexShaderID);

  	// Check Vertex Shader
    if (CheckErrorGL('Compile Vertex Shader: ' + Name, tcShader, VertexShaderID)) then
      exit(false);

    // Compile Fragment Shader
    ps := PAnsiChar(FShader[TTypeShader.tsFragment]);
    len := length(FShader[TTypeShader.tsFragment]);
    glShaderSource(FragmentShaderID, 1, PPAnsiChar(@ps), @len);
  	glCompileShader(FragmentShaderID);

    // Check Fragment Shader
    if (CheckErrorGL('Compile Fragment Shader: ' + Name, tcShader, FragmentShaderID)) then
      exit(false);

    // Link the program
    if FProgramID <> 0 then
      glDeleteProgram(FProgramID);

    FProgramID := glCreateProgram;
    glAttachShader(FProgramID, VertexShaderID);
    glAttachShader(FProgramID, FragmentShaderID);
    glLinkProgram(FProgramID);

  	// Check the program
    if (CheckErrorGL('glLinkProgram: ', tcProgramm, FProgramID)) then
      exit(false);

  finally
    glDeleteShader(FragmentShaderID);
    glDeleteShader(VertexShaderID);
  end;

  glValidateProgram(FProgramID);
  if (CheckErrorGL('glLinkProgram: ', tcProgramm, FProgramID)) then
    exit(false);
  Result := true;
end;

procedure TBlackSharkShader.Reset;
begin
	FProgramID := 0;
end;

procedure TBlackSharkShader.Unload;
begin
  if FProgramID > 0 then
  begin
    glDeleteProgram(FProgramID);
    FProgramID := 0;
  end;
end;

function TBlackSharkShader.GetAttribute(const NameAttribute: AnsiString): PShaderParametr;
begin
  Params.Find(NameAttribute, Result);
end;

function TBlackSharkShader.GetUniform(const NameUniform: AnsiString): PShaderParametr;
begin
  Params.Find(NameUniform, Result);
end;

function TBlackSharkShader.LinkUniformLocation(const UniformName: AnsiString): Glint;
begin
  if (UniformName = '') then
  begin
    BSWriteMsg('TBlackSharkShader.LinkUniformLocation', 'UniformName = ''');
    exit(-1);
  end;
  Result := glGetUniformLocation(FProgramID, @UniformName[1]);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkShader.LinkUniformLocation, UniformName = ' + AnsiToString(UniformName), tcProgramm, FProgramID);
  {$endif}
end;

function TBlackSharkShader.LinkAttribLocation(const AttribName: AnsiString): Glint;
begin
  if (AttribName = '') then
  begin
    BSWriteMsg('TBlackSharkShader.LinkAttribLocations', 'AttribName = ''');
    exit(-1);
  end;
  Result := glGetAttribLocation(FProgramID, @AttribName[1]);
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkShader.LinkAttribLocations, AttribName = ' + AnsiToString(AttribName), tcProgramm, FProgramID);
  {$endif}
end;

function TBlackSharkShader.GetShader(index: TTypeShader): AnsiString;
begin
  Result := FShader[index];
end;

constructor TBlackSharkShader.Create(const AName: string; const ADataVertex, ADataFragment: PAnsiChar);
var
  ts: TTypeShader;
begin
  inherited Create;
  Params := TTableParams.Create(@GetHashBlackSharkSA, @StrCmpABool);
  for ts := Low(ts) to High(ts) do
  begin
    FUniforms[ts] := TListShaderParametrs.Create;
    FAttributes[ts] := TListShaderParametrs.Create;
    FVariables[ts] := TListShaderParametrs.Create;
  end;
  _Counter := 0;
  FName := AName;
  FShader[TTypeShader.tsVertex] := ADataVertex;
  FShader[TTypeShader.tsFragment] := ADataFragment;
  if (FShader[TTypeShader.tsVertex] <> '') and (FShader[TTypeShader.tsFragment] <> '') then
    LoadShader;
end;

class function TBlackSharkShader.DefaultName: string;
begin
  Result := '';
end;

destructor TBlackSharkShader.Destroy;
var
  i: int32;
  ts: TTypeShader;
begin
  for ts := Low(ts) to High(ts) do
  begin
    for i := 0 to FUniforms[ts].Count - 1 do
      dispose(FUniforms[ts].Items[i]);
    for i := 0 to FAttributes[ts].Count - 1 do
      dispose(FAttributes[ts].Items[i]);
    for i := 0 to FVariables[ts].Count - 1 do
      dispose(FVariables[ts].Items[i]);
    FVariables[ts].Free;
    FAttributes[ts].Free;
    FUniforms[ts].Free;
  end;
  Params.Free;
  Unload;
  {$ifdef DEBUG_BS}
  BSWriteMsg('TBlackSharkShader.Destroy', Name);
  {$endif}
  inherited;
end;

function TBlackSharkShader.AddUniform(const NameUniform: AnsiString; TypeUniform: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr;
begin
  if Params.Find(NameUniform, Result) then
    exit;
  new(Result);
  Result^.Location := -1;
  Result^.Name := NameUniform;
  Result^.ParametrType := TypeUniform;
  Result^.DataTypeGL := SHADER_TYPE_TO_GL[TypeUniform];
  FUniforms[TypeShader].Add(Result);
  Params.Items[NameUniform] := Result;
end;

function TBlackSharkShader.AddAttribute(const NameAttribute: AnsiString; TypeAttribute: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr;
begin
  if Params.Find(NameAttribute, Result) then
    exit;
  new(Result);
  Result^.Location := -1;
  Result^.Name := NameAttribute;
  Result^.ParametrType := TypeAttribute;
  Result^.DataTypeGL := SHADER_TYPE_TO_GL[TypeAttribute];
  FAttributes[TypeShader].Add(Result);
  Params.Items[NameAttribute] := Result;
end;

function TBlackSharkShader.AddVariable(const NameVariable: AnsiString;
  TypeVariable: TShaderBaseTypes; TypeShader: TTypeShader): PShaderParametr;
begin
  if Params.Find(NameVariable, Result) then
    exit;
  new(Result);
  Result^.Location := -1;
  Result^.Name := NameVariable;
  Result^.ParametrType := TypeVariable;
  Result^.DataTypeGL := SHADER_TYPE_TO_GL[TypeVariable];
  FVariables[TypeShader].Add(Result);
  Params.Items[NameVariable] := Result;
end;

function TBlackSharkShader.LinkLocations: boolean;
var
  i: int32;
  ts: TTypeShader;
  vc: TVertexComponent;
begin

  Result := true;
  for vc := low(TVertexComponent) to high(TVertexComponent) do
  begin
    VertexComponentLocations[vc] := -1;
    VertexComponentTypes[vc] := 0;
  end;

  // Get the attribute locations
  for ts := Low(ts) to High(ts) do
  begin

    for i := 0 to FUniforms[ts].Count - 1 do
    begin
      FUniforms[ts].Items[i].Location := LinkUniformLocation(FUniforms[ts].Items[i].Name);
      if FUniforms[ts].Items[i].Location < 0 then
      begin
        BSWriteMsg(AnsiString('TBlackSharkShader.LinkLocations'), 'Uniform location "' + AnsiToString(FUniforms[ts].Items[i].Name) + '" not found ');
        Result := false;
      end;
    end;

    for i := 0 to FAttributes[ts].Count - 1 do
    begin
      FAttributes[ts].Items[i].Location := LinkAttribLocation(FAttributes[ts].Items[i].Name);
      if FAttributes[ts].Items[i].Location < 0 then
      begin
        BSWriteMsg(AnsiString('TBlackSharkShader.LinkLocations'), 'Attribute location "' + AnsiToString(FAttributes[ts].Items[i].Name) + '" not found ');
        Result := false;
      end;
    end;

  end;

  {$ifdef DEBUG_BS}
  // Check the program
  if Result then
    Result := not CheckErrorGL('TBlackSharkShader.LinkLocations: ', tcProgramm, FProgramID);
  {$endif}

end;

procedure TBlackSharkShader.UseProgram(AEnableAttrib: boolean);
var
  i: int32;
  ts: TTypeShader;
begin
  glUseProgram(FProgramID);
  if AEnableAttrib then
  begin
    for ts := Low(ts) to High(ts) do
      for i := 0 to FAttributes[ts].Count - 1 do
        if FAttributes[ts].Items[i].Location >= 0 then
        begin
          glEnableVertexAttribArray( FAttributes[ts].Items[i].Location );
        end;
  end;
end;

function TBlackSharkShader._AddRef: int32;
begin
  inc(_Counter);
  Result := _Counter;
end;

{ TBlackSharkSingleColorOutShader }

constructor TBlackSharkSingleColorOutShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColorLoc := AddUniform('Color', stVec4, tsVertex);
  FPosCoord := AddAttribute('a_position', stVec4, tsVertex);
  FMVP := AddUniform('MVP', stMat4, tsVertex);
  {$ifdef DEBUG_BS}
  // Check the program
  CheckErrorGL('TBlackSharkSingleColorOutShader.Create: ', tcProgramm, FProgramID);
  {$endif}
end;

destructor TBlackSharkSingleColorOutShader.Destroy;
begin
  inherited Destroy;
end;

{ TBlackSharkColorOutShader }

constructor TBlackSharkColorOutShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColorLoc := AddAttribute('a_color', stVec4, tsVertex);
  FPosCoord := AddAttribute('a_position', stVec4, tsVertex);
  FMVP := AddUniform('MVP', stMat4, tsVertex);
end;

destructor TBlackSharkColorOutShader.Destroy;
begin
  inherited Destroy;
end;

procedure TBlackSharkColorOutShader.UseProgram;
begin
  inherited;
  //glEnableVertexAttribArray ( FColorLoc );
end;

{ TBlackSharkAutoBuildShader }

function TBlackSharkAutoBuildShader.Build: boolean;
var
  i: int32;
  ts: TTypeShader;
  main: array[TTypeShader] of AnsiString;
begin

  for ts := Low(ts) to High(ts) do
  begin
    FShader[ts] := '';
    if ts = TTypeShader.tsFragment then
      FShader[ts] := 'precision mediump float;' + #$0d + #$0a;

    FShader[ts] := FShader[ts] + '// uniforms ' + #$0d + #$0a;

    main[ts] := #$0d + #$0a + 'void main()  ' + #$0d + #$0a + '{' + #$0d + #$0a;
    // geherate header programms
    for i := 0 to FUniforms[ts].Count - 1 do
    begin
      FShader[ts] := FShader[ts] + 'uniform ' + ShaderBaseTypesSyntax[FUniforms[ts].Items[i].ParametrType] +
        ' ' + FUniforms[ts].Items[i].Name + ';' + #$0d + #$0a;
      if FUniforms[ts].Items[i].MicroProgramm <> '' then
        main[ts] := main[ts] + #$09 + FUniforms[ts].Items[i].MicroProgramm + ';' + #$0d + #$0a;
    end;

    FShader[ts] := FShader[ts] + '// attributes ' + #$0d + #$0a;
    for i := 0 to FAttributes[ts].Count - 1 do
    begin
      FShader[ts] := FShader[ts] + 'attribute ' + ShaderBaseTypesSyntax[FAttributes[ts].Items[i].ParametrType] +
        ' ' + FAttributes[ts].Items[i].Name + ';' + #$0d + #$0a;
      if FAttributes[ts].Items[i].MicroProgramm <> '' then
        main[ts] := main[ts] + #$09 + FAttributes[ts].Items[i].MicroProgramm + ';' + #$0d + #$0a;
    end;

    FShader[ts] := FShader[ts] + '// variables  ' + #$0d + #$0a;
    for i := 0 to FVariables[ts].Count - 1 do
    begin
      FShader[ts] := FShader[ts] + 'varying ' + ShaderBaseTypesSyntax[FVariables[ts].Items[i].ParametrType] +
        ' ' + FVariables[ts].Items[i].Name + ';' + #$0d + #$0a;
      if FVariables[ts].Items[i].MicroProgramm <> '' then
        main[ts] := main[ts] + #$09 + FVariables[ts].Items[i].MicroProgramm + ';' + #$0d + #$0a;
    end;

    main[ts] := main[ts] + '}' + #$0d + #$0a;
    FShader[ts] := FShader[ts] + main[ts];
  end;

  Result := true;
end;

constructor TBlackSharkAutoBuildShader.Create(const AName: string; const DataVertex,
  DataFragment: PAnsiChar);
begin
  inherited;
  Build;
  LoadShader;
end;

function TBlackSharkAutoBuildShader.SaveToFile(FileName: WideString): boolean;
var
  f: TFileStream;
begin
  if FileExists(FileName) then
    exit(false);
  if FShader[tsVertex] <> '' then
    begin
    try
      f := TFileStream.Create(string(FileName + '.vsh'), fmCreate);
      try
        f.WriteBuffer(FShader[tsVertex][1], Length(FShader[tsVertex]));
      finally
        f.Free;
      end;
    except
      exit(false);
    end;
    end;
  if FShader[tsFragment] <> '' then
    begin
    try
      f := TFileStream.Create(string(FileName + '.fsh'), fmCreate);
      try
        f.WriteBuffer(FShader[tsFragment][1], Length(FShader[tsFragment]));
      finally
        f.Free;
      end;
    except
      exit(false);
    end;
    end;
  Result := true;
end;

{ TSimpleTextureOutShader }

constructor TSimpleTextureOutShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FTexCoord := AddAttribute('a_texCoord', stVec2, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
end;

function TSimpleTextureOutShader.LinkLocations: boolean;
begin
  Result := inherited;
  VertexComponentLocations[vcTexture1] := FTexCoord^.Location;
  VertexComponentTypes[vcTexture1] := FTexCoord^.DataTypeGL;
end;

procedure TSimpleTextureOutShader.UseProgram;
begin
  inherited;
  // Set the sampler texture unit to 0
  glUniform1i ( FTexSampler^.Location, 0 );
end;

{ TTextFromTextureShader }

constructor TTextFromTextureShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddUniform('Color', stVec4, tsFragment);
end;

class function TTextFromTextureShader.DefaultName: string;
begin
  Result := 'TextFromTexture';
end;

{ TBlackSharkTextureOutShader }

constructor TBlackSharkTextureOutShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited Create (AName, DataVertex, DataFragment);
end;

class function TBlackSharkTextureOutShader.DefaultName: string;
begin
  Result := 'SimpleTexture';
end;

function TBlackSharkTextureOutShader.LinkLocations: boolean;
begin
  FTexCoord := AddAttribute('a_texCoord', stVec2, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
  FAreaUV := AddUniform('AreaUV', stVec4, tsFragment);
  Result := inherited;
  VertexComponentLocations[vcTexture1] := FTexCoord^.Location;
  VertexComponentTypes[vcTexture1] := FTexCoord^.DataTypeGL;
end;

procedure TBlackSharkTextureOutShader.UseProgram;
begin
  inherited;
  // Set the sampler texture unit to 0
  glUniform1i ( FTexSampler^.Location, 0 );
end;

{ TBlackSharkTextureAniShader }

constructor TBlackSharkTextureAniShader.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FTexSampler2 := AddUniform('s_texture2', stSampler2D, tsFragment);
  FTime := AddUniform('Time', stFloat, tsFragment);
end;

procedure TBlackSharkTextureAniShader.UseProgram;
begin
  inherited UseProgram(AEnableAttrib);
  // Set the sampler second texture unit to 1
  glUniform1i ( FTexSampler2^.Location, 1 );
end;

{ TBlackSharkAutoParseShader }

constructor TBlackSharkAutoParseShader.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  if (DataVertex <> '') and (DataFragment <> '') then
    ParceShader(DataVertex, DataFragment);
end;

procedure TBlackSharkAutoParseShader.ParceShader(const DataVertex,
  DataFragment: PAnsiChar);
var
  Parser: TShaderParser;
begin
  Parser := TShaderParser.Create(Self);
  try
    Parser.ParseShader(DataVertex, tsVertex);
    {HeaderVSH := DataVertex;
    SetLength(HeaderVSH, Parser.HeaderEnd);
    FunctionMainVSH := PAnsiChar(@DataVertex[Parser.MainBodyPosBegin]);
    SetLength(FunctionMainVSH, Parser.MainBodyPosEnd - Parser.MainBodyPosBegin);}
    Parser.ParseShader(DataFragment, tsFragment);
    {HeaderFSH := DataFragment;
    SetLength(HeaderFSH, Parser.HeaderEnd);
    FunctionMainFSH := PAnsiChar(@DataFragment[Parser.MainBodyPosBegin]);
    SetLength(FunctionMainFSH, Parser.MainBodyPosEnd - Parser.MainBodyPosBegin);}
  finally
    Parser.Free;
  end;
end;

{ TBlackSharkTextureOutShaderAP }

{constructor TBlackSharkTextureOutShaderAP.Create(const AName: AnsiString;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;

end;

destructor TBlackSharkTextureOutShaderAP.Destroy;
begin

  inherited;
end;

function TBlackSharkTextureOutShaderAP.LinkLocations: boolean;
begin
  inherited;
  FMVP := Uniform['MVP'];
  FPosCoord := Attribute['a_position'];
  FTexCoord := Attribute['a_texCoord'];
  // fragment shader
  FTexSampler := Uniform['s_texture'];
  Result := true;
end;   }

{ TShaderParametr }

function BuildBinaryOperator(a, b: TShaderParametr; Oper: AnsiString): TShaderParametr; inline;
begin
  Result.ParametrType := a.ParametrType;
  if (a.MicroProgramm <> '') then
    begin
    if (b.MicroProgramm <> '') then
      Result.MicroProgramm := '(' + a.MicroProgramm + Oper + b.MicroProgramm + ')' else
      Result.MicroProgramm := '(' + a.MicroProgramm + Oper + b.Name + ')';
    end else
  if (b.MicroProgramm <> '') then
    begin
    Result.MicroProgramm := '(' + a.Name + Oper + b.MicroProgramm + ')';
    end else
  Result.MicroProgramm := '(' + a.Name + Oper + b.Name + ')';
end;

class operator TShaderParametr.Add(a, b: TShaderParametr): TShaderParametr;
begin
  Result := BuildBinaryOperator(a, b, ' + ');
  //Result.Name := '(' + a.Name + 'Add' + b.Name + ')';
end;

class operator TShaderParametr.Divide(a, b: TShaderParametr): TShaderParametr;
begin
  Result := BuildBinaryOperator(a, b, ' / ');
end;

class operator TShaderParametr.Implicit(a: TShaderParametr): AnsiString;
begin
  if a.MicroProgramm <> '' then
    Result := a.MicroProgramm
  else
    Result := a.Name;
end;

class operator TShaderParametr.Multiply(a, b: TShaderParametr): TShaderParametr;
begin
  Result := BuildBinaryOperator(a, b, ' * ');
end;

class operator TShaderParametr.Subtract(a, b: TShaderParametr): TShaderParametr;
begin
  Result := BuildBinaryOperator(a, b, ' - ');
end;

{ TBlackSharkVectorToColorShader }

constructor TBlackSharkVectorToSingleColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddUniform('Color', stVec4, tsFragment);
end;

class function TBlackSharkVectorToSingleColorShader.DefaultName: string;
begin
  Result := 'SingleColor';
end;

{ TBlackSharkQUADShader }

constructor TBlackSharkQUADShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FTexSampler := AddUniform('Texture', stSampler2D, tsFragment);
  FPosition := AddAttribute('Position', stVec3, tsVertex);
end;

procedure TBlackSharkQUADShader.UseProgram;
begin
  inherited;
  glUniform1i(FTexSampler^.Location, 0);
end;

{ TBlackSharkSmoothMSAA }

constructor TBlackSharkSmoothMSAA.Create(const AName: string;
  const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FRatioResolutions := AddUniform('RatioResol', stVec2, tsVertex);
end;

{ TBlackSharkSmoothByKernelMSAA }

constructor TBlackSharkSmoothByKernelMSAA.Create(const AName: string; const DataVertex,
  DataFragment: PAnsiChar);
begin
  inherited;
  FKernel := AddUniform('Kernel', stMat3, tsFragment)
end;

{ TBlackSharkSmoothFXAA }

constructor TBlackSharkSmoothFXAA.Create(const AName: string; const DataVertex,
  DataFragment: PAnsiChar);
begin
  inherited;
  FResolution := AddUniform('Resolution', stVec2, tsVertex);
  FResolutionInv := AddUniform('InvResolution', stVec2, tsVertex);
end;

{ TBlackSharkTexToColorHLSShader }

function TBlackSharkTexToColorHLSShader.LinkLocations: boolean;
begin
  FHLS := AddUniform('HLS', stVec3, tsFragment);
  Result := inherited;
end;

{ TBlackSharkVectorToDoubleColorShader }

constructor TBlackSharkVectorToDoubleColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor2 := AddUniform('Color2', stVec4, tsFragment);
  FColorIndex := AddAttribute('a_index_color', stFloat, tsVertex);
end;

class function TBlackSharkVectorToDoubleColorShader.DefaultName: string;
begin
  Result := 'DoubleColor';
end;

function TBlackSharkVectorToDoubleColorShader.LinkLocations: boolean;
begin
  Result := inherited;
  VertexComponentLocations[vcIndex] := FColorIndex^.Location;
  VertexComponentTypes[vcIndex] := FColorIndex^.DataTypeGL;
end;

{ TBlackSharkFogOutShader }

constructor TBlackSharkFogOutShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FTime := AddUniform('Time', stFloat, tsFragment);
  FResolution := AddUniform('Resolution', stVec2, tsFragment);
end;

class function TBlackSharkFogOutShader.DefaultName: string;
begin
  Result := 'Fog';
end;

{ TBlackSharkColoredVertexesShader }

constructor TBlackSharkColoredVertexesShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColors := AddAttribute('a_color', stVec3, tsVertex);
end;

class function TBlackSharkColoredVertexesShader.DefaultName: string;
begin
  Result := 'ColoredVertexes';
end;

function TBlackSharkColoredVertexesShader.LinkLocations: boolean;
begin
  Result := inherited;
  VertexComponentLocations[vcColor] := FColors^.Location;
  VertexComponentTypes[vcColor] := FColors^.DataTypeGL;
end;

{ TBlackSharkLayoutShader }

class function TBlackSharkLayoutShader.DefaultName: string;
begin
  Result := 'Layout';
end;

function TBlackSharkLayoutShader.LinkLocations: boolean;
begin
  if FMVPasUniform then
    FMVP := AddUniform('MVP', stMat4, tsVertex)
  else
    FMVP := AddAttribute('MVP', stMat4, tsVertex);

  FPosCoord := AddAttribute('a_position', stVec3, tsVertex);
  FColor := AddUniform('Color', stVec3, tsFragment);
  Result := inherited LinkLocations;
  VertexComponentLocations[vcCoordinate] := FPosCoord^.Location;
  VertexComponentTypes[vcCoordinate] := FPosCoord^.DataTypeGL;
end;

{ TBlackSharkSkeletonShader }

constructor TBlackSharkSkeletonShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  //FBonesAndWeights := AddAttribute('a_bones_and_weights', stVec2, tsVertex);
end;

class function TBlackSharkSkeletonShader.DefaultName: string;
begin
  Result := 'SingleColorAni';
end;

function TBlackSharkSkeletonShader.LinkLocations: boolean;
begin
  FCurrentTransforms := AddUniform('CurrentTransforms', stMat4, tsVertex);
  FBones := AddAttribute('a_bones', stVec3, tsVertex);
  FWeights := AddAttribute('a_weights', stVec3, tsVertex);
  Result := inherited;
  VertexComponentLocations[vcBones] := FBones^.Location;
  VertexComponentTypes[vcBones] := FBones^.DataTypeGL;
  VertexComponentLocations[vcWeights] := FWeights^.Location;
  VertexComponentTypes[vcWeights] := FWeights^.DataTypeGL;
end;

{ TBlackSharkSkeletonTexturedShader }

constructor TBlackSharkSkeletonTexturedShader.Create(const AName: string;const ADataVertex, ADataFragment: PAnsiChar);
begin
  inherited;

end;

class function TBlackSharkSkeletonTexturedShader.DefaultName: string;
begin
  Result := 'SkeletonTextured';
end;

function TBlackSharkSkeletonTexturedShader.LinkLocations: boolean;
begin
  FAreaUV := AddUniform('AreaUV', stVec4, tsFragment);
  FTexCoord := AddAttribute('a_texCoord', stVec2, tsVertex);
  FTexSampler := AddUniform('s_texture', stSampler2D, tsFragment);
  Result := inherited;
  VertexComponentLocations[vcTexture1] := FTexCoord^.Location;
  VertexComponentTypes[vcTexture1] := FTexCoord^.DataTypeGL;
end;

procedure TBlackSharkSkeletonTexturedShader.UseProgram;
begin
  inherited;
  // Set the sampler texture unit to 0
  glUniform1i ( FTexSampler^.Location, 0 );
end;

{ TBlackSharkColoredRGBAVertexesShader }

constructor TBlackSharkColoredRGBAVertexesShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColors := AddAttribute('a_color', stVec4, tsVertex);
end;

class function TBlackSharkColoredRGBAVertexesShader.DefaultName: string;
begin
  Result := 'ColoredRGBAVertexes';
end;

function TBlackSharkColoredRGBAVertexesShader.LinkLocations: boolean;
begin
  Result := inherited LinkLocations;
  VertexComponentLocations[vcColor] := FColors^.Location;
  VertexComponentTypes[vcColor] := FColors^.DataTypeGL;
end;

{ TBlackSharkStrokeCurveShader }

constructor TBlackSharkStrokeCurveShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FStrokeLen := AddUniform('StrokeLen', stFloat, tsFragment);
  FDistance := AddAttribute('a_distance', stFloat, tsVertex);
end;

function TBlackSharkStrokeCurveShader.LinkLocations: boolean;
begin
  Result := inherited;
  VertexComponentLocations[vcIndex] := FDistance^.Location;
  VertexComponentTypes[vcIndex] := FDistance^.DataTypeGL;
end;

{ TBlackSharkStrokeCurveSingleColorShader }

constructor TBlackSharkStrokeCurveSingleColorShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColor := AddUniform('Color', stVec3, tsFragment);
end;

class function TBlackSharkStrokeCurveSingleColorShader.DefaultName: string;
begin
  Result := 'StrokeCurve';
end;

function TBlackSharkStrokeCurveSingleColorShader.LinkLocations: boolean;
begin
  Result := inherited;
end;

{ TBlackSharkStrokeCurveMulticoloredShader }

constructor TBlackSharkStrokeCurveMulticoloredShader.Create(const AName: string; const DataVertex, DataFragment: PAnsiChar);
begin
  inherited;
  FColors := AddAttribute('a_color', stVec4, tsVertex);
end;

class function TBlackSharkStrokeCurveMulticoloredShader.DefaultName: string;
begin
  Result := 'StrokeCurveMulticolored';
end;

function TBlackSharkStrokeCurveMulticoloredShader.LinkLocations: boolean;
begin
  Result := inherited;
  VertexComponentLocations[vcColor] := FColors^.Location;
  VertexComponentTypes[vcColor] := FColors^.DataTypeGL;
end;

end.

