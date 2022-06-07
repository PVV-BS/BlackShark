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


{

 OpenGL ES 2.0 headers
 Header was taken from gles20.pas

}

unit bs.gl.es;


{$I BlackSharkCfg.inc}

interface

uses
  {$ifdef MSWINDOWS}
    Windows,
  {$endif}
  {$ifdef X}
    {$ifdef FPC}
      dynlibs,
    {$endif}
    bs.linux,
  {$endif}
    SysUtils
  ;


const
  GL_COMPRESSED_RGB_S3TC_DXT1_EXT = $83F0;
  GL_COMPRESSED_RGBA_S3TC_DXT1_EXT = $83F1;
  GL_COMPRESSED_RGBA_S3TC_DXT3_EXT = $83F2;
  GL_COMPRESSED_RGBA_S3TC_DXT5_EXT = $83F3;

  // error code
  //GL_INVALID_FRAMEBUFFER_OPERATION = $0506; // Invalid Framebuffer Operation

type
  {$ifdef FPC}
  {$else}
    longint = Integer;
  {$endif}
  PGLubyte = ^GLubyte;
  PGLboolean  = ^GLboolean;
  PGLenum  = ^GLenum;
  PGLfloat  = ^GLfloat;
  PGLint  = ^GLint;
  PGLsizei  = ^GLsizei;
  PGLuint  = ^GLuint;

  {-------------------------------------------------------------------------
   * Data type definitions
   *----------------------------------------------------------------------- }

     GLvoid = Pointer;
     PGLvoid = Pointer;
     PPGLvoid = ^PGLvoid;

     TGLvoid = GLvoid;

     GLenum = Cardinal;
     TGLenum = GLenum;

     GLboolean = byte;
     TGLboolean = GLboolean;

     GLbitfield = Cardinal;
     TGLbitfield = GLbitfield;

     GLbyte = shortint;
     TGLbyte = GLbyte;

     GLshort = smallint;
     TGLshort = GLshort;

     GLint = longint;
     TGLint = GLint;

     GLsizei = longint;
     TGLsizei = GLsizei;

     GLubyte = byte;
     TGLubyte = GLubyte;

     GLushort = word;
     TGLushort = GLushort;

     GLuint = longword;
     TGLuint = GLuint;

     GLfloat = single;
     TGLfloat = GLfloat;

     GLclampf = single;
     TGLclampf = GLclampf;

     GLfixed = longint;
     TGLfixed = GLfixed;
  { GL types for handling large vertex buffer objects  }

     GLintptr = NativeInt;

     GLsizeiptr = NativeInt;
  { OpenGL ES core versions  }

  const
     GL_ES_VERSION_2_0 = 1;
  { ClearBufferMask  }
     GL_DEPTH_BUFFER_BIT = $00000100;
     GL_STENCIL_BUFFER_BIT = $00000400;
     GL_COLOR_BUFFER_BIT = $00004000;
  { Boolean  }
     GL_FALSE = 0;
     GL_TRUE = 1;
  { BeginMode  }
     GL_POINTS = $0000;
     GL_LINES = $0001;
     GL_LINE_LOOP = $0002;
     GL_LINE_STRIP = $0003;
     GL_TRIANGLES = $0004;
     GL_TRIANGLE_STRIP = $0005;
     GL_TRIANGLE_FAN = $0006;
  { AlphaFunction (not supported in ES20)  }
  {      GL_NEVER  }
  {      GL_LESS  }
  {      GL_EQUAL  }
  {      GL_LEQUAL  }
  {      GL_GREATER  }
  {      GL_NOTEQUAL  }
  {      GL_GEQUAL  }
  {      GL_ALWAYS  }
  { BlendingFactorDest  }
     GL_ZERO = 0;
     GL_ONE = 1;
     GL_SRC_COLOR = $0300;
     GL_ONE_MINUS_SRC_COLOR = $0301;
     GL_SRC_ALPHA = $0302;
     GL_ONE_MINUS_SRC_ALPHA = $0303;
     GL_DST_ALPHA = $0304;
     GL_ONE_MINUS_DST_ALPHA = $0305;
  { BlendingFactorSrc  }
  {      GL_ZERO  }
  {      GL_ONE  }
     GL_DST_COLOR = $0306;
     GL_ONE_MINUS_DST_COLOR = $0307;
     GL_SRC_ALPHA_SATURATE = $0308;
  {      GL_SRC_ALPHA  }
  {      GL_ONE_MINUS_SRC_ALPHA  }
  {      GL_DST_ALPHA  }
  {      GL_ONE_MINUS_DST_ALPHA  }
  { BlendEquationSeparate  }
     GL_FUNC_ADD = $8006;
     GL_BLEND_EQUATION = $8009;
  { same as BLEND_EQUATION  }
     GL_BLEND_EQUATION_RGB = $8009;
     GL_BLEND_EQUATION_ALPHA = $883D;
  { BlendSubtract  }
     GL_FUNC_SUBTRACT = $800A;
     GL_FUNC_REVERSE_SUBTRACT = $800B;
  { Separate Blend Functions  }
     GL_BLEND_DST_RGB = $80C8;
     GL_BLEND_SRC_RGB = $80C9;
     GL_BLEND_DST_ALPHA = $80CA;
     GL_BLEND_SRC_ALPHA = $80CB;
     GL_CONSTANT_COLOR = $8001;
     GL_ONE_MINUS_CONSTANT_COLOR = $8002;
     GL_CONSTANT_ALPHA = $8003;
     GL_ONE_MINUS_CONSTANT_ALPHA = $8004;
     GL_BLEND_COLOR = $8005;
  { Buffer Objects  }
     GL_ARRAY_BUFFER = $8892;
     GL_ELEMENT_ARRAY_BUFFER = $8893;
     GL_ARRAY_BUFFER_BINDING = $8894;
     GL_ELEMENT_ARRAY_BUFFER_BINDING = $8895;
     GL_STREAM_DRAW = $88E0;
     GL_STATIC_DRAW = $88E4;
     GL_DYNAMIC_DRAW = $88E8;
     GL_BUFFER_SIZE = $8764;
     GL_BUFFER_USAGE = $8765;
     GL_CURRENT_VERTEX_ATTRIB = $8626;
  { CullFaceMode  }
     GL_FRONT = $0404;
     GL_BACK = $0405;
     GL_FRONT_AND_BACK = $0408;
  { DepthFunction  }
  {      GL_NEVER  }
  {      GL_LESS  }
  {      GL_EQUAL  }
  {      GL_LEQUAL  }
  {      GL_GREATER  }
  {      GL_NOTEQUAL  }
  {      GL_GEQUAL  }
  {      GL_ALWAYS  }
  { EnableCap  }
     GL_TEXTURE_2D = $0DE1;
     GL_CULL_FACE = $0B44;
     GL_BLEND = $0BE2;
     GL_DITHER = $0BD0;
     GL_STENCIL_TEST = $0B90;
     GL_DEPTH_TEST = $0B71;
     GL_SCISSOR_TEST = $0C11;
     GL_POLYGON_OFFSET_FILL = $8037;
     GL_SAMPLE_ALPHA_TO_COVERAGE = $809E;
     GL_SAMPLE_COVERAGE = $80A0;
  { ErrorCode  }
     GL_NO_ERROR = 0;
     GL_INVALID_ENUM = $0500;
     GL_INVALID_VALUE = $0501;
     GL_INVALID_OPERATION = $0502;
     GL_OUT_OF_MEMORY = $0505;
  { FrontFaceDirection  }
     GL_CW = $0900;
     GL_CCW = $0901;
  { GetPName  }
     GL_LINE_WIDTH = $0B21;
     GL_ALIASED_POINT_SIZE_RANGE = $846D;
     GL_ALIASED_LINE_WIDTH_RANGE = $846E;
     GL_CULL_FACE_MODE = $0B45;
     GL_FRONT_FACE = $0B46;
     GL_DEPTH_RANGE = $0B70;
     GL_DEPTH_WRITEMASK = $0B72;
     GL_DEPTH_CLEAR_VALUE = $0B73;
     GL_DEPTH_FUNC = $0B74;
     GL_STENCIL_CLEAR_VALUE = $0B91;
     GL_STENCIL_FUNC = $0B92;
     GL_STENCIL_FAIL = $0B94;
     GL_STENCIL_PASS_DEPTH_FAIL = $0B95;
     GL_STENCIL_PASS_DEPTH_PASS = $0B96;
     GL_STENCIL_REF = $0B97;
     GL_STENCIL_VALUE_MASK = $0B93;
     GL_STENCIL_WRITEMASK = $0B98;
     GL_STENCIL_BACK_FUNC = $8800;
     GL_STENCIL_BACK_FAIL = $8801;
     GL_STENCIL_BACK_PASS_DEPTH_FAIL = $8802;
     GL_STENCIL_BACK_PASS_DEPTH_PASS = $8803;
     GL_STENCIL_BACK_REF = $8CA3;
     GL_STENCIL_BACK_VALUE_MASK = $8CA4;
     GL_STENCIL_BACK_WRITEMASK = $8CA5;
     GL_VIEWPORT = $0BA2;
     GL_SCISSOR_BOX = $0C10;
  {      GL_SCISSOR_TEST  }
     GL_COLOR_CLEAR_VALUE = $0C22;
     GL_COLOR_WRITEMASK = $0C23;
     GL_UNPACK_ALIGNMENT = $0CF5;
     GL_PACK_ALIGNMENT = $0D05;
     GL_MAX_TEXTURE_SIZE = $0D33;
     GL_MAX_VIEWPORT_DIMS = $0D3A;
     GL_SUBPIXEL_BITS = $0D50;
     GL_RED_BITS = $0D52;
     GL_GREEN_BITS = $0D53;
     GL_BLUE_BITS = $0D54;
     GL_ALPHA_BITS = $0D55;
     GL_DEPTH_BITS = $0D56;
     GL_STENCIL_BITS = $0D57;
     GL_POLYGON_OFFSET_UNITS = $2A00;
  {      GL_POLYGON_OFFSET_FILL  }
     GL_POLYGON_OFFSET_FACTOR = $8038;
     GL_TEXTURE_BINDING_2D = $8069;
     GL_SAMPLE_BUFFERS = $80A8;
     GL_SAMPLES = $80A9;
     GL_SAMPLE_COVERAGE_VALUE = $80AA;
     GL_SAMPLE_COVERAGE_INVERT = $80AB;
  { GetTextureParameter  }
  {      GL_TEXTURE_MAG_FILTER  }
  {      GL_TEXTURE_MIN_FILTER  }
  {      GL_TEXTURE_WRAP_S  }
  {      GL_TEXTURE_WRAP_T  }
     GL_NUM_COMPRESSED_TEXTURE_FORMATS = $86A2;
     GL_COMPRESSED_TEXTURE_FORMATS = $86A3;
  { HintMode  }
     GL_DONT_CARE = $1100;
     GL_FASTEST = $1101;
     GL_NICEST = $1102;
  { HintTarget  }
     GL_GENERATE_MIPMAP_HINT = $8192;
  { DataType  }
     GL_BYTE = $1400;
     GL_UNSIGNED_BYTE = $1401;
     GL_SHORT = $1402;
     GL_UNSIGNED_SHORT = $1403;
     GL_INT = $1404;
     GL_UNSIGNED_INT = $1405;
     GL_FLOAT = $1406;
     HALF_FLOAT_OES = $8D61;
     GL_FIXED = $140C;
  { PixelFormat  }
     GL_DEPTH_COMPONENT = $1902;
     GL_ALPHA = $1906;
     GL_RGB = $1907;
     GL_RGBA = $1908;
     GL_LUMINANCE = $1909;
     GL_LUMINANCE_ALPHA = $190A;
  { PixelType  }
  {      GL_UNSIGNED_BYTE  }
     GL_UNSIGNED_SHORT_4_4_4_4 = $8033;
     GL_UNSIGNED_SHORT_5_5_5_1 = $8034;
     GL_UNSIGNED_SHORT_5_6_5 = $8363;
  { Shaders  }
     GL_FRAGMENT_SHADER = $8B30;
     GL_VERTEX_SHADER = $8B31;
     GL_MAX_VERTEX_ATTRIBS = $8869;
     GL_MAX_VERTEX_UNIFORM_VECTORS = $8DFB;
     GL_MAX_VARYING_VECTORS = $8DFC;
     GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = $8B4D;
     GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = $8B4C;
     GL_MAX_TEXTURE_IMAGE_UNITS = $8872;
     GL_MAX_FRAGMENT_UNIFORM_VECTORS = $8DFD;
     GL_SHADER_TYPE = $8B4F;
     GL_DELETE_STATUS = $8B80;
     GL_LINK_STATUS = $8B82;
     GL_VALIDATE_STATUS = $8B83;
     GL_ATTACHED_SHADERS = $8B85;
     GL_ACTIVE_UNIFORMS = $8B86;
     GL_ACTIVE_UNIFORM_MAX_LENGTH = $8B87;
     GL_ACTIVE_ATTRIBUTES = $8B89;
     GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = $8B8A;
     GL_SHADING_LANGUAGE_VERSION = $8B8C;
     GL_CURRENT_PROGRAM = $8B8D;
  { StencilFunction  }
     GL_NEVER = $0200;
     GL_LESS = $0201;
     GL_EQUAL = $0202;
     GL_LEQUAL = $0203;
     GL_GREATER = $0204;
     GL_NOTEQUAL = $0205;
     GL_GEQUAL = $0206;
     GL_ALWAYS = $0207;
  { StencilOp  }
  {      GL_ZERO  }
     GL_KEEP = $1E00;
     GL_REPLACE = $1E01;
     GL_INCR = $1E02;
     GL_DECR = $1E03;
     GL_INVERT = $150A;
     GL_INCR_WRAP = $8507;
     GL_DECR_WRAP = $8508;
  { StringName  }
     GL_VENDOR = $1F00;
     GL_RENDERER = $1F01;
     GL_VERSION = $1F02;
     GL_EXTENSIONS = $1F03;
  { TextureMagFilter  }
     GL_NEAREST = $2600;
     GL_LINEAR = $2601;
  { TextureMinFilter  }
  {      GL_NEAREST  }
  {      GL_LINEAR  }
     GL_NEAREST_MIPMAP_NEAREST = $2700;
     GL_LINEAR_MIPMAP_NEAREST = $2701;
     GL_NEAREST_MIPMAP_LINEAR = $2702;
     GL_LINEAR_MIPMAP_LINEAR = $2703;
  { TextureParameterName  }
     GL_TEXTURE_MAG_FILTER = $2800;
     GL_TEXTURE_MIN_FILTER = $2801;
     GL_TEXTURE_WRAP_S = $2802;
     GL_TEXTURE_WRAP_T = $2803;
  { TextureTarget  }
  {      GL_TEXTURE_2D  }
     GL_TEXTURE = $1702;
     GL_TEXTURE_CUBE_MAP = $8513;
     GL_TEXTURE_BINDING_CUBE_MAP = $8514;
     GL_TEXTURE_CUBE_MAP_POSITIVE_X = $8515;
     GL_TEXTURE_CUBE_MAP_NEGATIVE_X = $8516;
     GL_TEXTURE_CUBE_MAP_POSITIVE_Y = $8517;
     GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = $8518;
     GL_TEXTURE_CUBE_MAP_POSITIVE_Z = $8519;
     GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = $851A;
     GL_MAX_CUBE_MAP_TEXTURE_SIZE = $851C;
  { TextureUnit  }
     GL_TEXTURE0 = $84C0;
     GL_TEXTURE1 = $84C1;
     GL_TEXTURE2 = $84C2;
     GL_TEXTURE3 = $84C3;
     GL_TEXTURE4 = $84C4;
     GL_TEXTURE5 = $84C5;
     GL_TEXTURE6 = $84C6;
     GL_TEXTURE7 = $84C7;
     GL_TEXTURE8 = $84C8;
     GL_TEXTURE9 = $84C9;
     GL_TEXTURE10 = $84CA;
     GL_TEXTURE11 = $84CB;
     GL_TEXTURE12 = $84CC;
     GL_TEXTURE13 = $84CD;
     GL_TEXTURE14 = $84CE;
     GL_TEXTURE15 = $84CF;
     GL_TEXTURE16 = $84D0;
     GL_TEXTURE17 = $84D1;
     GL_TEXTURE18 = $84D2;
     GL_TEXTURE19 = $84D3;
     GL_TEXTURE20 = $84D4;
     GL_TEXTURE21 = $84D5;
     GL_TEXTURE22 = $84D6;
     GL_TEXTURE23 = $84D7;
     GL_TEXTURE24 = $84D8;
     GL_TEXTURE25 = $84D9;
     GL_TEXTURE26 = $84DA;
     GL_TEXTURE27 = $84DB;
     GL_TEXTURE28 = $84DC;
     GL_TEXTURE29 = $84DD;
     GL_TEXTURE30 = $84DE;
     GL_TEXTURE31 = $84DF;
     GL_ACTIVE_TEXTURE = $84E0;
  { TextureWrapMode  }
     GL_REPEAT = $2901;
     GL_CLAMP_TO_EDGE = $812F;
     GL_MIRRORED_REPEAT = $8370;
  { Uniform Types  }
     GL_FLOAT_VEC2 = $8B50;
     GL_FLOAT_VEC3 = $8B51;
     GL_FLOAT_VEC4 = $8B52;
     GL_INT_VEC2 = $8B53;
     GL_INT_VEC3 = $8B54;
     GL_INT_VEC4 = $8B55;
     GL_BOOL = $8B56;
     GL_BOOL_VEC2 = $8B57;
     GL_BOOL_VEC3 = $8B58;
     GL_BOOL_VEC4 = $8B59;
     GL_FLOAT_MAT2 = $8B5A;
     GL_FLOAT_MAT3 = $8B5B;
     GL_FLOAT_MAT4 = $8B5C;
     GL_SAMPLER_2D = $8B5E;
     GL_SAMPLER_CUBE = $8B60;
  { Vertex Arrays  }
     GL_VERTEX_ATTRIB_ARRAY_ENABLED = $8622;
     GL_VERTEX_ATTRIB_ARRAY_SIZE = $8623;
     GL_VERTEX_ATTRIB_ARRAY_STRIDE = $8624;
     GL_VERTEX_ATTRIB_ARRAY_TYPE = $8625;
     GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = $886A;
     GL_VERTEX_ATTRIB_ARRAY_POINTER = $8645;
     GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = $889F;
  { Read Format  }
     GL_IMPLEMENTATION_COLOR_READ_TYPE = $8B9A;
     GL_IMPLEMENTATION_COLOR_READ_FORMAT = $8B9B;
  { Shader Source  }
     GL_COMPILE_STATUS = $8B81;
     GL_INFO_LOG_LENGTH = $8B84;
     GL_SHADER_SOURCE_LENGTH = $8B88;
     GL_SHADER_COMPILER = $8DFA;
  { Shader Binary  }
     GL_SHADER_BINARY_FORMATS = $8DF8;
     GL_NUM_SHADER_BINARY_FORMATS = $8DF9;
  { Shader Precision-Specified Types  }
     GL_LOW_FLOAT = $8DF0;
     GL_MEDIUM_FLOAT = $8DF1;
     GL_HIGH_FLOAT = $8DF2;
     GL_LOW_INT = $8DF3;
     GL_MEDIUM_INT = $8DF4;
     GL_HIGH_INT = $8DF5;
  { Framebuffer Object.  }
     GL_FRAMEBUFFER = $8D40;
     GL_RENDERBUFFER = $8D41;
     GL_RGBA4 = $8056;
     GL_RGB5_A1 = $8057;
     GL_RGB565 = $8D62;
     GL_DEPTH_COMPONENT16 = $81A5;
     GL_STENCIL_INDEX = $1901;
     GL_STENCIL_INDEX8 = $8D48;
     GL_RENDERBUFFER_WIDTH = $8D42;
     GL_RENDERBUFFER_HEIGHT = $8D43;
     GL_RENDERBUFFER_INTERNAL_FORMAT = $8D44;
     GL_RENDERBUFFER_RED_SIZE = $8D50;
     GL_RENDERBUFFER_GREEN_SIZE = $8D51;
     GL_RENDERBUFFER_BLUE_SIZE = $8D52;
     GL_RENDERBUFFER_ALPHA_SIZE = $8D53;
     GL_RENDERBUFFER_DEPTH_SIZE = $8D54;
     GL_RENDERBUFFER_STENCIL_SIZE = $8D55;
     GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = $8CD0;
     GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = $8CD1;
     GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = $8CD2;
     GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = $8CD3;
     GL_COLOR_ATTACHMENT0 = $8CE0;
     GL_DEPTH_ATTACHMENT = $8D00;
     GL_STENCIL_ATTACHMENT = $8D20;
     GL_NONE = 0;
     GL_FRAMEBUFFER_COMPLETE = $8CD5;
     GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = $8CD6;
     GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = $8CD7;
     GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS = $8CD9;
     GL_FRAMEBUFFER_UNSUPPORTED = $8CDD;
     GL_FRAMEBUFFER_BINDING = $8CA6;
     GL_RENDERBUFFER_BINDING = $8CA7;
     GL_MAX_RENDERBUFFER_SIZE = $84E8;
     GL_INVALID_FRAMEBUFFER_OPERATION = $0506;
  {-------------------------------------------------------------------------
   * GL core functions.
   *----------------------------------------------------------------------- }

  var
    glActiveTexture : procedure(texture:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glAttachShader : procedure(_program:GLuint; shader:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glBindAttribLocation : procedure(_program:GLuint; index:GLuint; name:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBindBuffer : procedure(target:GLenum; buffer:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBindFramebuffer : procedure(target:GLenum; framebuffer:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBindRenderbuffer : procedure(target:GLenum; renderbuffer:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBindTexture : procedure(target:GLenum; texture:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBlendColor : procedure(red:GLclampf; green:GLclampf; blue:GLclampf; alpha:GLclampf);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBlendEquation : procedure(mode:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBlendEquationSeparate : procedure(modeRGB:GLenum; modeAlpha:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBlendFunc : procedure(sfactor:GLenum; dfactor:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBlendFuncSeparate : procedure(srcRGB:GLenum; dstRGB:GLenum; srcAlpha:GLenum; dstAlpha:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glBufferData : procedure(target:GLenum; size:GLsizeiptr; data:pointer; usage:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glBufferSubData : procedure(target:GLenum; offset:GLintptr; size:GLsizeiptr; data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCheckFramebufferStatus : function(target:GLenum):GLenum;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glClear : procedure(mask:GLbitfield);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glClearColor : procedure(red:GLclampf; green:GLclampf; blue:GLclampf; alpha:GLclampf);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glClearDepthf : procedure(depth:GLclampf);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glClearStencil : procedure(s:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glColorMask : procedure(red:GLboolean; green:GLboolean; blue:GLboolean; alpha:GLboolean);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCompileShader : procedure(shader:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glCompressedTexImage2D : procedure(target:GLenum; level:GLint; internalformat:GLenum; width:GLsizei; height:GLsizei;
      border:GLint; imageSize:GLsizei; data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glCompressedTexSubImage2D : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; width:GLsizei;
      height:GLsizei; format:GLenum; imageSize:GLsizei; data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCopyTexImage2D : procedure(target:GLenum; level:GLint; internalformat:GLenum; x:GLint; y:GLint;
      width:GLsizei; height:GLsizei; border:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCopyTexSubImage2D : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; x:GLint;
      y:GLint; width:GLsizei; height:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCreateProgram : function:GLuint;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCreateShader : function(_type:GLenum):GLuint;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCullFace : procedure(mode:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glDeleteBuffers : procedure(n:GLsizei; buffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glDeleteFramebuffers : procedure(n:GLsizei; framebuffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDeleteProgram : procedure(_program:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glDeleteRenderbuffers : procedure(n:GLsizei; renderbuffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDeleteShader : procedure(shader:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glDeleteTextures : procedure(n:GLsizei; textures:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDepthFunc : procedure(func:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDepthMask : procedure(flag:GLboolean);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDepthRangef : procedure(zNear:GLclampf; zFar:GLclampf);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDetachShader : procedure(_program:GLuint; shader:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDisable : procedure(cap:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDisableVertexAttribArray : procedure(index:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDrawArrays : procedure(mode:GLenum; first:GLint; count:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glDrawElements : procedure(mode:GLenum; count:GLsizei; _type:GLenum; indices:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glEnable : procedure(cap:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glEnableVertexAttribArray : procedure(index:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFinish : procedure;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFlush : procedure;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFramebufferRenderbuffer : procedure(target:GLenum; attachment:GLenum; renderbuffertarget:GLenum; renderbuffer:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFramebufferTexture2D : procedure(target:GLenum; attachment:GLenum; textarget:GLenum; texture:GLuint; level:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFrontFace : procedure(mode:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenBuffers : procedure(n:GLsizei; buffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenerateMipmap : procedure(target:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenFramebuffers : procedure(n:GLsizei; framebuffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenRenderbuffers : procedure(n:GLsizei; renderbuffers:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenTextures : procedure(n:GLsizei; textures:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetActiveAttrib : procedure(_program:GLuint; index:GLuint; bufsize:GLsizei; length:pGLsizei; size:pGLint;
      _type:pGLenum; name:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetActiveUniform : procedure(_program:GLuint; index:GLuint; bufsize:GLsizei; length:pGLsizei; size:pGLint;
      _type:pGLenum; name:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetAttachedShaders : procedure(_program:GLuint; maxcount:GLsizei; count:pGLsizei; shaders:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glGetAttribLocation : function(_program:GLuint; name:PAnsiChar):longint;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetBooleanv : procedure(pname:GLenum; params:pGLboolean);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetBufferParameteriv : procedure(target:GLenum; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetError : function:GLenum;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetFloatv : procedure(pname:GLenum; params:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetFramebufferAttachmentParameteriv : procedure(target:GLenum; attachment:GLenum; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetIntegerv : procedure(pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetProgramiv : procedure(_program:GLuint; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetProgramInfoLog : procedure(_program:GLuint; bufsize:GLsizei; length:pGLsizei; infolog:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetRenderbufferParameteriv : procedure(target:GLenum; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetShaderiv : procedure(shader:GLuint; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetShaderInfoLog : procedure(shader:GLuint; bufsize:GLsizei; length:pGLsizei; infolog:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetShaderPrecisionFormat : procedure(shadertype:GLenum; precisiontype:GLenum; range:pGLint; precision:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetShaderSource : procedure(shader:GLuint; bufsize:GLsizei; length:pGLsizei; source:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glGetString : function(name:GLenum):PGLubyte;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetTexParameterfv : procedure(target:GLenum; pname:GLenum; params:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetTexParameteriv : procedure(target:GLenum; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetUniformfv : procedure(_program:GLuint; location:GLint; params:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetUniformiv : procedure(_program:GLuint; location:GLint; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glGetUniformLocation : function(_program:GLuint; name:PAnsiChar):longint;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetVertexAttribfv : procedure(index:GLuint; pname:GLenum; params:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetVertexAttribiv : procedure(index:GLuint; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetVertexAttribPointerv : procedure(index:GLuint; pname:GLenum; pointer:Ppointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glHint : procedure(target:GLenum; mode:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsBuffer : function(buffer:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsEnabled : function(cap:GLenum):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsFramebuffer : function(framebuffer:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsProgram : function(_program:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsRenderbuffer : function(renderbuffer:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsShader : function(shader:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glIsTexture : function(texture:GLuint):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glLineWidth : procedure(width:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glLinkProgram : procedure(_program:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glPixelStorei : procedure(pname:GLenum; param:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glPolygonOffset : procedure(factor:GLfloat; units:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glReadPixels : procedure(x:GLint; y:GLint; width:GLsizei; height:GLsizei; format:GLenum;
      _type:GLenum; pixels:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glReleaseShaderCompiler : procedure;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glRenderbufferStorage : procedure(target:GLenum; internalformat:GLenum; width:GLsizei; height:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glSampleCoverage : procedure(value:GLclampf; invert:GLboolean);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glScissor : procedure(x:GLint; y:GLint; width:GLsizei; height:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
(* Const before type ignored *)
    glShaderBinary : procedure(n:GLsizei; shaders:pGLuint; binaryformat:GLenum; binary:pointer; length:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
(* Const before type ignored *)
    glShaderSource : procedure(shader:GLuint; count:GLsizei; _string:PPAnsiChar; length:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilFunc : procedure(func:GLenum; ref:GLint; mask:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilFuncSeparate : procedure(face:GLenum; func:GLenum; ref:GLint; mask:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilMask : procedure(mask:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilMaskSeparate : procedure(face:GLenum; mask:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilOp : procedure(fail:GLenum; zfail:GLenum; zpass:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glStencilOpSeparate : procedure(face:GLenum; fail:GLenum; zfail:GLenum; zpass:GLenum);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glTexImage2D : procedure(target:GLenum; level:GLint; internalformat:GLenum; width:GLsizei; height:GLsizei;
      border:GLint; format:GLenum; _type:GLenum; pixels:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glTexParameterf : procedure(target:GLenum; pname:GLenum; param:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glTexParameterfv : procedure(target:GLenum; pname:GLenum; params:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glTexParameteri : procedure(target:GLenum; pname:GLenum; param:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glTexParameteriv : procedure(target:GLenum; pname:GLenum; params:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glTexSubImage2D : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; width:GLsizei;
      height:GLsizei; format:GLenum; _type:GLenum; pixels:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform1f : procedure(location:GLint; x:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform1fv : procedure(location:GLint; count:GLsizei; v:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform1i : procedure(location:GLint; x:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform1iv : procedure(location:GLint; count:GLsizei; v:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform2f : procedure(location:GLint; x:GLfloat; y:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform2fv : procedure(location:GLint; count:GLsizei; v:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform2i : procedure(location:GLint; x:GLint; y:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform2iv : procedure(location:GLint; count:GLsizei; v:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform3f : procedure(location:GLint; x:GLfloat; y:GLfloat; z:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform3fv : procedure(location:GLint; count:GLsizei; v:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform3i : procedure(location:GLint; x:GLint; y:GLint; z:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform3iv : procedure(location:GLint; count:GLsizei; v:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform4f : procedure(location:GLint; x:GLfloat; y:GLfloat; z:GLfloat; w:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform4fv : procedure(location:GLint; count:GLsizei; v:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUniform4i : procedure(location:GLint; x:GLint; y:GLint; z:GLint; w:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniform4iv : procedure(location:GLint; count:GLsizei; v:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniformMatrix2fv : procedure(location:GLint; count:GLsizei; transpose:GLboolean; value:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniformMatrix3fv : procedure(location:GLint; count:GLsizei; transpose:GLboolean; value:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glUniformMatrix4fv : procedure(location:GLint; count:GLsizei; transpose:GLboolean; value:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUseProgram : procedure(_program:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glValidateProgram : procedure(_program:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glVertexAttrib1f : procedure(indx:GLuint; x:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glVertexAttrib1fv : procedure(indx:GLuint; values:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glVertexAttrib2f : procedure(indx:GLuint; x:GLfloat; y:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glVertexAttrib2fv : procedure(indx:GLuint; values:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glVertexAttrib3f : procedure(indx:GLuint; x:GLfloat; y:GLfloat; z:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glVertexAttrib3fv : procedure(indx:GLuint; values:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glVertexAttrib4f : procedure(indx:GLuint; x:GLfloat; y:GLfloat; z:GLfloat; w:GLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glVertexAttrib4fv : procedure(indx:GLuint; values:pGLfloat);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glVertexAttribPointer : procedure(indx:GLuint; size:GLint; _type:GLenum; normalized:GLboolean; stride:GLsizei;
      ptr:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glViewport : procedure(x:GLint; y:GLint; width:GLsizei; height:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  {------------------------------------------------------------------------*
   * IMG extension tokens
   *------------------------------------------------------------------------ }
  { GL_IMG_binary_shader  }

  const
     GL_SGX_BINARY_IMG = $8C0A;
  { GL_IMG_texture_compression_pvrtc  }
     GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG = $8C00;
     GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG = $8C01;
     GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG = $8C02;
     GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG = $8C03;
     GL_BGRA = $80E1;
  {------------------------------------------------------------------------*
   * IMG extension functions
   *------------------------------------------------------------------------ }
  { GL_IMG_binary_shader  }
     GL_IMG_binary_shader = 1;
  { GL_IMG_texture_compression_pvrtc  }
     GL_IMG_texture_compression_pvrtc = 1;
  {
   * This document is licensed under the SGI Free Software B License Version
   * 2.0. For details, see http://oss.sgi.com/projects/FreeB/ .
    }
  {------------------------------------------------------------------------*
   * OES extension tokens
   *------------------------------------------------------------------------ }
  { GL_OES_compressed_ETC1_RGB8_texture  }
     GL_ETC1_RGB8_OES = $8D64;
  { GL_OES_compressed_paletted_texture  }
     GL_PALETTE4_RGB8_OES = $8B90;
     GL_PALETTE4_RGBA8_OES = $8B91;
     GL_PALETTE4_R5_G6_B5_OES = $8B92;
     GL_PALETTE4_RGBA4_OES = $8B93;
     GL_PALETTE4_RGB5_A1_OES = $8B94;
     GL_PALETTE8_RGB8_OES = $8B95;
     GL_PALETTE8_RGBA8_OES = $8B96;
     GL_PALETTE8_R5_G6_B5_OES = $8B97;
     GL_PALETTE8_RGBA4_OES = $8B98;
     GL_PALETTE8_RGB5_A1_OES = $8B99;
  { GL_OES_depth24  }
     GL_DEPTH_COMPONENT24_OES = $81A6;
  { GL_OES_depth32  }
     GL_DEPTH_COMPONENT32_OES = $81A7;
  { GL_OES_depth_texture  }
  { No new tokens introduced by this extension.  }
  { GL_OES_EGL_image  }

  type

     GLeglImageOES = pointer;
  { GL_OES_get_program_binary  }

  const
     GL_PROGRAM_BINARY_LENGTH_OES = $8741;
     GL_NUM_PROGRAM_BINARY_FORMATS_OES = $87FE;
     GL_PROGRAM_BINARY_FORMATS_OES = $87FF;
  { GL_OES_mapbuffer  }
     GL_WRITE_ONLY_OES = $88B9;
     GL_BUFFER_ACCESS_OES = $88BB;
     GL_BUFFER_MAPPED_OES = $88BC;
     GL_BUFFER_MAP_POINTER_OES = $88BD;
  { GL_OES_packed_depth_stencil  }
     GL_DEPTH_STENCIL_OES = $84F9;
     GL_UNSIGNED_INT_24_8_OES = $84FA;
     GL_DEPTH24_STENCIL8_OES = $88F0;
     { the const fetch from desktop OpenGL }
     GL_DEPTH_STENCIL_ATTACHMENT = $821A;
     //GL_DEPTH24_STENCIL8 = $88F0;
     //GL_DEPTH_STENCIL = $84F9;
     //GL_UNSIGNED_INT_24_8 = $84FA;
  { GL_OES_rgb8_rgba8  }
     GL_RGB8_OES = $8051;
     GL_RGBA8_OES = $8058;
  { GL_OES_standard_derivatives  }
     GL_FRAGMENT_SHADER_DERIVATIVE_HINT_OES = $8B8B;
  { GL_OES_stencil1  }
     GL_STENCIL_INDEX1_OES = $8D46;
  { GL_OES_stencil4  }
     GL_STENCIL_INDEX4_OES = $8D47;
  { GL_OES_texture3D  }
     GL_TEXTURE_WRAP_R_OES = $8072;
     GL_TEXTURE_3D_OES = $806F;
     GL_TEXTURE_BINDING_3D_OES = $806A;
     GL_MAX_3D_TEXTURE_SIZE_OES = $8073;
     GL_SAMPLER_3D_OES = $8B5F;
     GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_OES = $8CD4;
  { GL_OES_texture_half_float  }
     GL_HALF_FLOAT_OES = $8D61;
  { GL_OES_vertex_half_float  }
  { GL_HALF_FLOAT_OES defined in GL_OES_texture_half_float already.  }
  { GL_OES_vertex_type_10_10_10_2  }
     GL_UNSIGNED_INT_10_10_10_2_OES = $8DF6;
     GL_INT_10_10_10_2_OES = $8DF7;
  {------------------------------------------------------------------------*
   * AMD extension tokens
   *------------------------------------------------------------------------ }
  { GL_AMD_compressed_3DC_texture  }
     GL_3DC_X_AMD = $87F9;
     GL_3DC_XY_AMD = $87FA;
  { GL_AMD_compressed_ATC_texture  }
     GL_ATC_RGB_AMD = $8C92;
     GL_ATC_RGBA_EXPLICIT_ALPHA_AMD = $8C93;
     GL_ATC_RGBA_INTERPOLATED_ALPHA_AMD = $87EE;
  { GL_AMD_program_binary_Z400  }
     GL_Z400_BINARY_AMD = $8740;
  { GL_AMD_performance_monitor  }
{$define GL_AMD_performance_monitor}
     GL_COUNTER_TYPE_AMD = $8BC0;
     GL_COUNTER_RANGE_AMD = $8BC1;
     GL_UNSIGNED_INT64_AMD = $8BC2;
     GL_PERCENTAGE_AMD = $8BC3;
     GL_PERFMON_RESULT_AVAILABLE_AMD = $8BC4;
     GL_PERFMON_RESULT_SIZE_AMD = $8BC5;
     GL_PERFMON_RESULT_AMD = $8BC6;
  {------------------------------------------------------------------------*
   * EXT extension tokens
   *------------------------------------------------------------------------ }
  { GL_EXT_texture_filter_anisotropic  }
     GL_TEXTURE_MAX_ANISOTROPY_EXT = $84FE;
     GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT = $84FF;
  { GL_EXT_texture_type_2_10_10_10_REV  }
     GL_UNSIGNED_INT_2_10_10_10_REV_EXT = $8368;
  {------------------------------------------------------------------------*
   * OES extension functions
   *------------------------------------------------------------------------ }
  { GL_OES_compressed_ETC1_RGB8_texture  }
     GL_OES_compressed_ETC1_RGB8_texture = 1;
  { GL_OES_compressed_paletted_texture  }
     GL_OES_compressed_paletted_texture = 1;
  { GL_OES_EGL_image  }

  { GL_OES_depth24  }

  const
     GL_OES_depth24 = 1;
  { GL_OES_depth32  }
     GL_OES_depth32 = 1;
  { GL_OES_depth_texture  }
     GL_OES_depth_texture = 1;
  { GL_OES_element_index_uint  }
     GL_OES_element_index_uint = 1;
  { GL_OES_fbo_render_mipmap  }
     GL_OES_fbo_render_mipmap = 1;
  { GL_OES_fragment_precision_high  }
     GL_OES_fragment_precision_high = 1;
  { GL_OES_get_program_binary  }

  var
    glGetProgramBinaryOES : procedure(_program:GLuint; bufSize:GLsizei; length:pGLsizei; binaryFormat:pGLenum; binary:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glProgramBinaryOES : procedure(_program:GLuint; binaryFormat:GLenum; binary:pointer; length:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

(* Const before type ignored *)
  { GL_OES_mapbuffer  }

  const
     GL_OES_mapbuffer = 1;

  var
    glMapBufferOES : function(target:GLenum; access:GLenum):pointer;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glUnmapBufferOES : function(target:GLenum):GLboolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetBufferPointervOES : procedure(target:GLenum; pname:GLenum; params:Ppointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  var
    glEGLImageTargetTexture2DOES : procedure(target:GLenum; image:GLeglImageOES);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glEGLImageTargetRenderbufferStorageOES : procedure(target:GLenum; image:GLeglImageOES);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  type

     PFNGLMAPBUFFEROESPROC = pointer;
  { GL_OES_packed_depth_stencil  }

  const
     GL_OES_packed_depth_stencil = 1;
  { GL_OES_rgb8_rgba8  }
     GL_OES_rgb8_rgba8 = 1;
  { GL_OES_standard_derivatives  }
     GL_OES_standard_derivatives = 1;
  { GL_OES_stencil1  }
     GL_OES_stencil1 = 1;
  { GL_OES_stencil4  }
     GL_OES_stencil4 = 1;
  { GL_OES_texture_3D  }
     GL_OES_texture_3D = 1;
(* Const before type ignored *)

  var
    glTexImage3DOES : procedure(target:GLenum; level:GLint; internalformat:GLenum; width:GLsizei; height:GLsizei;
      depth:GLsizei; border:GLint; format:GLenum; _type:GLenum; pixels:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glTexSubImage3DOES : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; zoffset:GLint;
      width:GLsizei; height:GLsizei; depth:GLsizei; format:GLenum; _type:GLenum;
      pixels:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glCopyTexSubImage3DOES : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; zoffset:GLint;
      x:GLint; y:GLint; width:GLsizei; height:GLsizei);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glCompressedTexImage3DOES : procedure(target:GLenum; level:GLint; internalformat:GLenum; width:GLsizei; height:GLsizei;
      depth:GLsizei; border:GLint; imageSize:GLsizei; data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    glCompressedTexSubImage3DOES : procedure(target:GLenum; level:GLint; xoffset:GLint; yoffset:GLint; zoffset:GLint;
      width:GLsizei; height:GLsizei; depth:GLsizei; format:GLenum; imageSize:GLsizei;
      data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glFramebufferTexture3DOES : procedure(target:GLenum; attachment:GLenum; textarget:GLenum; texture:GLuint; level:GLint;
      zoffset:GLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)

(* Const before type ignored *)
(* Const before type ignored *)
(* Const before type ignored *)
  { GL_OES_texture_float_linear  }

  const
     GL_OES_texture_float_linear = 1;
  { GL_OES_texture_half_float_linear  }
     GL_OES_texture_half_float_linear = 1;
  { GL_OES_texture_float  }
     GL_OES_texture_float = 1;
  { GL_OES_texture_half_float  }
     GL_OES_texture_half_float = 1;
  { GL_OES_texture_npot  }
     GL_OES_texture_npot = 1;
  { GL_OES_vertex_half_float  }
     GL_OES_vertex_half_float = 1;
  { GL_OES_vertex_type_10_10_10_2  }
     GL_OES_vertex_type_10_10_10_2 = 1;
  {------------------------------------------------------------------------*
   * AMD extension functions
   *------------------------------------------------------------------------ }
  { GL_AMD_compressed_3DC_texture  }
     GL_AMD_compressed_3DC_texture = 1;
  { GL_AMD_compressed_ATC_texture  }
     GL_AMD_compressed_ATC_texture = 1;
  { GL_AMD_program_binary_Z400  }
     GL_AMD_program_binary_Z400 = 1;
  { AMD_performance_monitor  }
     GL_AMD_performance_monitor = 1;

  var
    glGetPerfMonitorGroupsAMD : procedure(numGroups:pGLint; groupsSize:GLsizei; groups:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetPerfMonitorCountersAMD : procedure(group:GLuint; numCounters:pGLint; maxActiveCounters:pGLint; counterSize:GLsizei; counters:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetPerfMonitorGroupStringAMD : procedure(group:GLuint; bufSize:GLsizei; length:pGLsizei; groupString:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetPerfMonitorCounterStringAMD : procedure(group:GLuint; counter:GLuint; bufSize:GLsizei; length:pGLsizei; counterString:PAnsiChar);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetPerfMonitorCounterInfoAMD : procedure(group:GLuint; counter:GLuint; pname:GLenum; data:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGenPerfMonitorsAMD : procedure(n:GLsizei; monitors:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glDeletePerfMonitorsAMD : procedure(n:GLsizei; monitors:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glSelectPerfMonitorCountersAMD : procedure(monitor:GLuint; enable:GLboolean; group:GLuint; numCounters:GLint; countersList:pGLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glBeginPerfMonitorAMD : procedure(monitor:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glEndPerfMonitorAMD : procedure(monitor:GLuint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    glGetPerfMonitorCounterDataAMD : procedure(monitor:GLuint; pname:GLenum; dataSize:GLsizei; data:pGLuint; bytesWritten:pGLint);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  {------------------------------------------------------------------------*
   * EXT extension functions
   *------------------------------------------------------------------------ }
  { GL_EXT_texture_filter_anisotropic  }

  const
     GL_EXT_texture_filter_anisotropic = 1;
  { GL_EXT_texture_type_2_10_10_10_REV  }
     GL_EXT_texture_type_2_10_10_10_REV = 1;

  //----------------------------- OpenGL ES 3.0 ------------------------------//

  {$ifdef GLES30}

  // GL_ARB_map_buffer_range
  GL_MAP_READ_BIT = $0001;
  GL_MAP_WRITE_BIT = $0002;
  GL_MAP_INVALIDATE_RANGE_BIT = $0004;
  GL_MAP_INVALIDATE_BUFFER_BIT = $0008;
  GL_MAP_FLUSH_EXPLICIT_BIT = $0010;
  GL_MAP_UNSYNCHRONIZED_BIT = $0020;

var
  // 3.0
  glGenVertexArrays: procedure(Count: GLsizei;   VAO_ArraysID: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glDeleteVertexArrays: procedure(n: GLsizei;  arrays: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glBindVertexArray: procedure(VAO_ID: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glDrawArraysInstanced: procedure(mode: GLenum; first: GLint;
  count: GLsizei; instanceCount: GLsizei); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  glDrawElementsInstanced: procedure(mode: GLenum; count: GLsizei; type_: GLenum;
    indices: Pointer; instanceCount: GLsizei); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glMapBufferRange: function(target: GLenum; offset: GLintptr; length: GLsizeiptr; access: GLbitfield): PGLvoid; {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glUnmapBuffer: function(target: GLenum): GLboolean; {$ifdef MSWINDOWS}stdcall; {$else}cdecl; {$endif}
  glVertexAttribDivisor: procedure(index: GLuint; divisor: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  //glDrawArraysInstancedBaseInstanceEXT: procedure (mode: GLenum; first: GLint; count: GLsizei;
    //  instancecount: GLsizei; baseinstance: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  //glDrawArraysInstancedEXT: procedure (mode: GLenum; start: GLint; count: GLsizei; primcount: GLsizei); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

  {$endif} // {$ifdef GLES30}
  //-------------------------------------------------------------------------//

  // OpenGL Extension ARB framebuffer

var
  glFramebufferTextureLayer: procedure(target: GLenum; attachment: GLenum; texture: GLuint; level: GLint; layer: GLint);  {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glRenderbufferStorageMultisample: procedure(target: GLenum; samples: GLsizei; internalformat: GLenum; width, height: GLsizei); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glBlitFramebuffer: procedure (srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1: GLint; mask: GLbitfield; filter: GLenum); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glGenerateMipmap: procedure(target: GLenum); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glGetFramebufferAttachmentParameteriv: procedure (target, attachment, pname: GLenum; params: PGLint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glFramebufferRenderbuffer: procedure (target, attachment, renderbuffertarget: GLenum; renderbuffer: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glFramebufferTexture3D: procedure (target, attachment, textarget: GLenum; texture: GLuint; level, zoffset: GLint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glFramebufferTexture2D: procedure (target, attachment, textarget: GLenum; texture: GLuint; level: GLint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  glFramebufferTexture1D: procedure (target, attachment, textarget: GLenum; texture: GLuint; level: GLint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glCheckFramebufferStatus: function (target: GLenum): GLenum; {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glGenFramebuffers: procedure (n: GLsizei; framebuffers: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glDeleteFramebuffers: procedure (n: GLsizei; framebuffers: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glBindFramebuffer: procedure (target: GLenum; framebuffer: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glIsFramebuffer: function (framebuffer: GLuint): GLboolean; {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glGetRenderbufferParameteriv: procedure (target: GLenum; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glRenderbufferStorage: procedure (target, internalformat: GLenum; width, height: GLsizei); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glGenRenderbuffers: procedure (n: GLsizei; framebuffers: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glDeleteRenderbuffers: procedure (n: GLsizei; framebuffers: PGLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glBindRenderbuffer: procedure (target: GLenum; renderbuffer: GLuint); {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  //glIsRenderbuffer: function (renderbuffer: GLuint): GLboolean; {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}


  { Accept GLES API   }
  function InitGLES(const PathGL: string): boolean;

  {$ifdef FPC}
  function glGetProcAddress(ahlib: TLibHandle; ProcName: PAnsiChar; CountParamBytes: int8 = 0): Pointer;
  {$else}
  function glGetProcAddress(ahlib: System.THandle; ProcName: PWideChar; CountParamBytes: int8 = 0): Pointer;
  {$endif}

var
  {$ifdef FPC}
  GLESLib: TLibHandle = 0;
  {$else}
  GLESLib: System.THandle = 0;
  {$endif}

implementation

{$ifdef DEBUG_BS}
uses
    bs.log
  ;
{$endif}


{$ifdef FPC}
function glGetProcAddress(ahlib: TLibHandle; ProcName: PAnsiChar; CountParamBytes: int8 = 0): Pointer;
var
  n: AnsiString;
begin
  Result := GetProcAddress(ahlib, ProcName);
  if not Assigned(Result) then
  begin
    n := '_' + ProcName + '@' + AnsiString(IntToStr(CountParamBytes));
    Result := GetProcAddress(ahlib, PAnsiChar(n));
  end;
end;
{$else}
function glGetProcAddress(ahlib: System.THandle; ProcName: PWideChar; CountParamBytes: int8 = 0): Pointer;
var
  n: string;
begin
  Result := GetProcAddress(ahlib, ProcName);
  if not Assigned(Result) then
  begin
    n := '_' + ProcName + '@' + IntToStr(CountParamBytes);
    Result := GetProcAddress(ahlib, PChar(n));
  end;
end;
{$endif}

procedure FreeGLESv2;
begin
  if GLESLib <> 0 then
    FreeLibrary(GLESLib);

  glActiveTexture := nil;
  glAttachShader := nil;
  glBindAttribLocation := nil;
  glBindBuffer := nil;
  glBindFramebuffer := nil;
  glBindRenderbuffer := nil;
  glBindTexture := nil;
  glBlendColor := nil;
  glBlendEquation := nil;
  glBlendEquationSeparate := nil;
  glBlendFunc := nil;
  glBlendFuncSeparate := nil;
  glBufferData := nil;
  glBufferSubData := nil;
  glCheckFramebufferStatus := nil;
  glClear := nil;
  glClearColor := nil;
  glClearDepthf := nil;
  glClearStencil := nil;
  glColorMask := nil;
  glCompileShader := nil;
  glCompressedTexImage2D := nil;
  glCompressedTexSubImage2D := nil;
  glCopyTexImage2D := nil;
  glCopyTexSubImage2D := nil;
  glCreateProgram := nil;
  glCreateShader := nil;
  glCullFace := nil;
  glDeleteBuffers := nil;
  glDeleteFramebuffers := nil;
  glDeleteProgram := nil;
  glDeleteRenderbuffers := nil;
  glDeleteShader := nil;
  glDeleteTextures := nil;
  glDepthFunc := nil;
  glDepthMask := nil;
  glDepthRangef := nil;
  glDetachShader := nil;
  glDisable := nil;
  glDisableVertexAttribArray := nil;
  glDrawArrays := nil;
  glDrawElements := nil;
  glEnable := nil;
  glEnableVertexAttribArray := nil;
  glFinish := nil;
  glFlush := nil;
  glFramebufferRenderbuffer := nil;
  glFramebufferTexture2D := nil;
  glFrontFace := nil;
  glGenBuffers := nil;
  glGenerateMipmap := nil;
  glGenFramebuffers := nil;
  glGenRenderbuffers := nil;
  glGenTextures := nil;
  glGetActiveAttrib := nil;
  glGetActiveUniform := nil;
  glGetAttachedShaders := nil;
  glGetAttribLocation := nil;
  glGetBooleanv := nil;
  glGetBufferParameteriv := nil;
  glGetError := nil;
  glGetFloatv := nil;
  glGetFramebufferAttachmentParameteriv := nil;
  glGetIntegerv := nil;
  glGetProgramiv := nil;
  glGetProgramInfoLog := nil;
  glGetRenderbufferParameteriv := nil;
  glGetShaderiv := nil;
  glGetShaderInfoLog := nil;
  glGetShaderPrecisionFormat := nil;
  glGetShaderSource := nil;
  glGetString := nil;
  glGetTexParameterfv := nil;
  glGetTexParameteriv := nil;
  glGetUniformfv := nil;
  glGetUniformiv := nil;
  glGetUniformLocation := nil;
  glGetVertexAttribfv := nil;
  glGetVertexAttribiv := nil;
  glGetVertexAttribPointerv := nil;
  glHint := nil;
  glIsBuffer := nil;
  glIsEnabled := nil;
  glIsFramebuffer := nil;
  glIsProgram := nil;
  glIsRenderbuffer := nil;
  glIsShader := nil;
  glIsTexture := nil;
  glLineWidth := nil;
  glLinkProgram := nil;
  glPixelStorei := nil;
  glPolygonOffset := nil;
  glReadPixels := nil;
  glReleaseShaderCompiler := nil;
  glRenderbufferStorage := nil;
  glSampleCoverage := nil;
  glScissor := nil;
  glShaderBinary := nil;
  glShaderSource := nil;
  glStencilFunc := nil;
  glStencilFuncSeparate := nil;
  glStencilMask := nil;
  glStencilMaskSeparate := nil;
  glStencilOp := nil;
  glStencilOpSeparate := nil;
  glTexImage2D := nil;
  glTexParameterf := nil;
  glTexParameterfv := nil;
  glTexParameteri := nil;
  glTexParameteriv := nil;
  glTexSubImage2D := nil;
  glUniform1f := nil;
  glUniform1fv := nil;
  glUniform1i := nil;
  glUniform1iv := nil;
  glUniform2f := nil;
  glUniform2fv := nil;
  glUniform2i := nil;
  glUniform2iv := nil;
  glUniform3f := nil;
  glUniform3fv := nil;
  glUniform3i := nil;
  glUniform3iv := nil;
  glUniform4f := nil;
  glUniform4fv := nil;
  glUniform4i := nil;
  glUniform4iv := nil;
  glUniformMatrix2fv := nil;
  glUniformMatrix3fv := nil;
  glUniformMatrix4fv := nil;
  glUseProgram := nil;
  glValidateProgram := nil;
  glVertexAttrib1f := nil;
  glVertexAttrib1fv := nil;
  glVertexAttrib2f := nil;
  glVertexAttrib2fv := nil;
  glVertexAttrib3f := nil;
  glVertexAttrib3fv := nil;
  glVertexAttrib4f := nil;
  glVertexAttrib4fv := nil;
  glVertexAttribPointer := nil;
  glViewport := nil;
  glEGLImageTargetTexture2DOES := nil;
  glEGLImageTargetRenderbufferStorageOES := nil;
  glGetProgramBinaryOES := nil;
  glProgramBinaryOES := nil;
  glMapBufferOES := nil;
  glUnmapBufferOES := nil;
  glGetBufferPointervOES := nil;
  glTexImage3DOES := nil;
  glTexSubImage3DOES := nil;
  glCopyTexSubImage3DOES := nil;
  glCompressedTexImage3DOES := nil;
  glCompressedTexSubImage3DOES := nil;
  glFramebufferTexture3DOES := nil;
  glGetPerfMonitorGroupsAMD := nil;
  glGetPerfMonitorCountersAMD := nil;
  glGetPerfMonitorGroupStringAMD := nil;
  glGetPerfMonitorCounterStringAMD := nil;
  glGetPerfMonitorCounterInfoAMD := nil;
  glGenPerfMonitorsAMD := nil;
  glDeletePerfMonitorsAMD := nil;
  glSelectPerfMonitorCountersAMD := nil;
  glBeginPerfMonitorAMD := nil;
  glEndPerfMonitorAMD := nil;
  glGetPerfMonitorCounterDataAMD := nil;
end;

function LoadGLESv2(lib: PChar): boolean;
begin
  if GLESLib <> 0 then
    FreeGLESv2;
  GLESLib := LoadLibrary(lib);
  if (GLESLib = 0) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('LoadGLESv2', 'Could not load library ' + lib);
    {$endif}
    exit(false);
  end;


  glActiveTexture := glGetProcAddress(GLESLib, 'glActiveTexture', 4);
  glAttachShader := glGetProcAddress(GLESLib, 'glAttachShader', 8);
  glBindAttribLocation := glGetProcAddress(GLESLib,'glBindAttribLocation', 12);
  glBindBuffer := glGetProcAddress(GLESLib,'glBindBuffer', 8);
  glBindFramebuffer := glGetProcAddress(GLESLib,'glBindFramebuffer', 8);
  glBindRenderbuffer := glGetProcAddress(GLESLib,'glBindRenderbuffer', 8);
  glBindTexture := glGetProcAddress(GLESLib,'glBindTexture');
  glBlendColor := glGetProcAddress(GLESLib,'glBlendColor', 16);
  glBlendEquation := glGetProcAddress(GLESLib,'glBlendEquation', 4);
  glBlendEquationSeparate := glGetProcAddress(GLESLib,'glBlendEquationSeparate', 8);
  glBlendFunc := glGetProcAddress(GLESLib,'glBlendFunc');
  glBlendFuncSeparate := glGetProcAddress(GLESLib,'glBlendFuncSeparate', 16);
  glBufferData := glGetProcAddress(GLESLib,'glBufferData', 16);
  glBufferSubData := glGetProcAddress(GLESLib,'glBufferSubData', 16);
  glCheckFramebufferStatus := glGetProcAddress(GLESLib,'glCheckFramebufferStatus', 4);
  glClear := glGetProcAddress(GLESLib,'glClear');
  glClearColor := glGetProcAddress(GLESLib,'glClearColor');
  glClearDepthf := glGetProcAddress(GLESLib,'glClearDepthf', 4);
  glClearStencil := glGetProcAddress(GLESLib,'glClearStencil');
  glColorMask := glGetProcAddress(GLESLib,'glColorMask');
  glCompileShader := glGetProcAddress(GLESLib,'glCompileShader', 4);
  glCompressedTexImage2D := glGetProcAddress(GLESLib,'glCompressedTexImage2D', 32);
  glCompressedTexSubImage2D := glGetProcAddress(GLESLib,'glCompressedTexSubImage2D', 36);
  glCopyTexImage2D := glGetProcAddress(GLESLib,'glCopyTexImage2D');
  glCopyTexSubImage2D := glGetProcAddress(GLESLib,'glCopyTexSubImage2D');
  glCreateProgram := glGetProcAddress(GLESLib,'glCreateProgram');
  glCreateShader := glGetProcAddress(GLESLib,'glCreateShader', 4);
  glCullFace := glGetProcAddress(GLESLib,'glCullFace');
  glDeleteBuffers := glGetProcAddress(GLESLib,'glDeleteBuffers', 8);
  glDeleteFramebuffers := glGetProcAddress(GLESLib,'glDeleteFramebuffers', 8);
  glDeleteProgram := glGetProcAddress(GLESLib, 'glDeleteProgram', 4);
  glDeleteRenderbuffers := glGetProcAddress(GLESLib,'glDeleteRenderbuffers', 8);
  glDeleteShader := glGetProcAddress(GLESLib, 'glDeleteShader', 4);
  glDeleteTextures := glGetProcAddress(GLESLib,'glDeleteTextures');
  glDepthFunc := glGetProcAddress(GLESLib,'glDepthFunc');
  glDepthMask := glGetProcAddress(GLESLib,'glDepthMask');
  glDepthRangef := glGetProcAddress(GLESLib,'glDepthRangef', 8);
  glDetachShader := glGetProcAddress(GLESLib,'glDetachShader', 8);
  glDisable := glGetProcAddress(GLESLib,'glDisable');
  glDisableVertexAttribArray := glGetProcAddress(GLESLib,'glDisableVertexAttribArray', 4);
  glDrawArrays := glGetProcAddress(GLESLib,'glDrawArrays');
  glDrawElements := glGetProcAddress(GLESLib,'glDrawElements');
  glEnable := glGetProcAddress(GLESLib,'glEnable');
  glEnableVertexAttribArray := glGetProcAddress(GLESLib,'glEnableVertexAttribArray', 4);
  glFinish := glGetProcAddress(GLESLib,'glFinish');
  glFlush := glGetProcAddress(GLESLib,'glFlush');
  glFramebufferRenderbuffer := glGetProcAddress(GLESLib,'glFramebufferRenderbuffer', 16);
  glFramebufferTexture2D := glGetProcAddress(GLESLib,'glFramebufferTexture2D', 20);
  glFrontFace := glGetProcAddress(GLESLib,'glFrontFace');
  glGenBuffers := glGetProcAddress(GLESLib,'glGenBuffers', 8);
  glGenerateMipmap := glGetProcAddress(GLESLib,'glGenerateMipmap', 4);
  glGenFramebuffers := glGetProcAddress(GLESLib,'glGenFramebuffers', 8);
  glGenRenderbuffers := glGetProcAddress(GLESLib,'glGenRenderbuffers', 8);
  glGenTextures := glGetProcAddress(GLESLib,'glGenTextures');
  glGetActiveAttrib := glGetProcAddress(GLESLib,'glGetActiveAttrib', 28);
  glGetActiveUniform := glGetProcAddress(GLESLib,'glGetActiveUniform', 28);
  glGetAttachedShaders := glGetProcAddress(GLESLib,'glGetAttachedShaders', 16);
  glGetAttribLocation := glGetProcAddress(GLESLib,'glGetAttribLocation', 8);
  glGetBooleanv := glGetProcAddress(GLESLib,'glGetBooleanv');
  glGetBufferParameteriv := glGetProcAddress(GLESLib,'glGetBufferParameteriv', 12);
  glGetError := glGetProcAddress(GLESLib,'glGetError');
  glGetFloatv := glGetProcAddress(GLESLib,'glGetFloatv');
  glGetFramebufferAttachmentParameteriv := glGetProcAddress(GLESLib,'glGetFramebufferAttachmentParameteriv', 16);
  glGetIntegerv := glGetProcAddress(GLESLib,'glGetIntegerv');
  glGetProgramiv := glGetProcAddress(GLESLib,'glGetProgramiv', 12);
  glGetProgramInfoLog := glGetProcAddress(GLESLib,'glGetProgramInfoLog', 16);
  glGetRenderbufferParameteriv := glGetProcAddress(GLESLib,'glGetRenderbufferParameteriv', 12);
  glGetShaderiv := glGetProcAddress(GLESLib,'glGetShaderiv', 12);
  glGetShaderInfoLog := glGetProcAddress(GLESLib,'glGetShaderInfoLog', 16);
  glGetShaderPrecisionFormat := glGetProcAddress(GLESLib,'glGetShaderPrecisionFormat', 16);
  glGetShaderSource := glGetProcAddress(GLESLib,'glGetShaderSource', 16);
  glGetString := glGetProcAddress(GLESLib,'glGetString');
  glGetTexParameterfv := glGetProcAddress(GLESLib,'glGetTexParameterfv');
  glGetTexParameteriv := glGetProcAddress(GLESLib,'glGetTexParameteriv');
  glGetUniformfv := glGetProcAddress(GLESLib,'glGetUniformfv', 12);
  glGetUniformiv := glGetProcAddress(GLESLib,'glGetUniformiv');
  glGetUniformLocation := glGetProcAddress(GLESLib,'glGetUniformLocation', 8);
  glGetVertexAttribfv := glGetProcAddress(GLESLib,'glGetVertexAttribfv', 12);
  glGetVertexAttribiv := glGetProcAddress(GLESLib,'glGetVertexAttribiv', 12);
  glGetVertexAttribPointerv := glGetProcAddress(GLESLib,'glGetVertexAttribPointerv', 12);
  glHint := glGetProcAddress(GLESLib,'glHint');
  glIsBuffer := glGetProcAddress(GLESLib,'glIsBuffer', 4);
  glIsEnabled := glGetProcAddress(GLESLib,'glIsEnabled');
  glIsFramebuffer := glGetProcAddress(GLESLib,'glIsFramebuffer', 4);
  glIsProgram := glGetProcAddress(GLESLib,'glIsProgram', 4);
  glIsRenderbuffer := glGetProcAddress(GLESLib,'glIsRenderbuffer', 4);
  glIsShader := glGetProcAddress(GLESLib,'glIsShader', 4);
  glIsTexture := glGetProcAddress(GLESLib,'glIsTexture');
  glLineWidth := glGetProcAddress(GLESLib,'glLineWidth');
  glLinkProgram := glGetProcAddress(GLESLib,'glLinkProgram', 4);
  glPixelStorei := glGetProcAddress(GLESLib,'glPixelStorei');
  glPolygonOffset := glGetProcAddress(GLESLib,'glPolygonOffset');
  glReadPixels := glGetProcAddress(GLESLib,'glReadPixels');
  glReleaseShaderCompiler := glGetProcAddress(GLESLib,'glReleaseShaderCompiler');
  glRenderbufferStorage := glGetProcAddress(GLESLib,'glRenderbufferStorage', 16);
  glSampleCoverage := glGetProcAddress(GLESLib,'glSampleCoverage', 8);
  glScissor := glGetProcAddress(GLESLib,'glScissor');
  glShaderBinary := glGetProcAddress(GLESLib,'glShaderBinary', 20);
  glShaderSource := glGetProcAddress(GLESLib,'glShaderSource', 16);
  glStencilFunc := glGetProcAddress(GLESLib,'glStencilFunc');
  glStencilFuncSeparate := glGetProcAddress(GLESLib,'glStencilFuncSeparate', 16);
  glStencilMask := glGetProcAddress(GLESLib,'glStencilMask');
  glStencilMaskSeparate := glGetProcAddress(GLESLib,'glStencilMaskSeparate', 8);
  glStencilOp := glGetProcAddress(GLESLib,'glStencilOp');
  glStencilOpSeparate := glGetProcAddress(GLESLib,'glStencilOpSeparate', 16);
  glTexImage2D := glGetProcAddress(GLESLib,'glTexImage2D');
  glTexParameterf := glGetProcAddress(GLESLib,'glTexParameterf');
  glTexParameterfv := glGetProcAddress(GLESLib,'glTexParameterfv');
  glTexParameteri := glGetProcAddress(GLESLib,'glTexParameteri');
  glTexParameteriv := glGetProcAddress(GLESLib,'glTexParameteriv');
  glTexSubImage2D := glGetProcAddress(GLESLib,'glTexSubImage2D');
  glUniform1f := glGetProcAddress(GLESLib,'glUniform1f', 8);
  glUniform1fv := glGetProcAddress(GLESLib,'glUniform1fv', 12);
  glUniform1i := glGetProcAddress(GLESLib,'glUniform1i', 8);
  glUniform1iv := glGetProcAddress(GLESLib,'glUniform1iv', 12);
  glUniform2f := glGetProcAddress(GLESLib,'glUniform2f', 12);
  glUniform2fv := glGetProcAddress(GLESLib,'glUniform2fv', 12);
  glUniform2i := glGetProcAddress(GLESLib,'glUniform2i', 12);
  glUniform2iv := glGetProcAddress(GLESLib,'glUniform2iv', 12);
  glUniform3f := glGetProcAddress(GLESLib,'glUniform3f', 16);
  glUniform3fv := glGetProcAddress(GLESLib,'glUniform3fv', 12);
  glUniform3i := glGetProcAddress(GLESLib,'glUniform3i', 16);
  glUniform3iv := glGetProcAddress(GLESLib,'glUniform3iv', 12);
  glUniform4f := glGetProcAddress(GLESLib,'glUniform4f', 20);
  glUniform4fv := glGetProcAddress(GLESLib,'glUniform4fv', 12);
  glUniform4i := glGetProcAddress(GLESLib,'glUniform4i', 20);
  glUniform4iv := glGetProcAddress(GLESLib,'glUniform4iv', 12);
  glUniformMatrix2fv := glGetProcAddress(GLESLib,'glUniformMatrix2fv', 16);
  glUniformMatrix3fv := glGetProcAddress(GLESLib,'glUniformMatrix3fv', 16);
  glUniformMatrix4fv := glGetProcAddress(GLESLib,'glUniformMatrix4fv', 16);
  glUseProgram := glGetProcAddress(GLESLib,'glUseProgram', 4);
  glValidateProgram := glGetProcAddress(GLESLib,'glValidateProgram', 4);
  glVertexAttrib1f := glGetProcAddress(GLESLib,'glVertexAttrib1f', 8);
  glVertexAttrib1fv := glGetProcAddress(GLESLib,'glVertexAttrib1fv', 8);
  glVertexAttrib2f := glGetProcAddress(GLESLib,'glVertexAttrib2f', 12);
  glVertexAttrib2fv := glGetProcAddress(GLESLib,'glVertexAttrib2fv', 8);
  glVertexAttrib3f := glGetProcAddress(GLESLib,'glVertexAttrib3f', 16);
  glVertexAttrib3fv := glGetProcAddress(GLESLib,'glVertexAttrib3fv', 8);
  glVertexAttrib4f := glGetProcAddress(GLESLib,'glVertexAttrib4f', 20);
  glVertexAttrib4fv := glGetProcAddress(GLESLib,'glVertexAttrib4fv', 8);
  glVertexAttribPointer := glGetProcAddress(GLESLib,'glVertexAttribPointer', 24);
  glViewport := glGetProcAddress(GLESLib,'glViewport');
  glGetPerfMonitorGroupsAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorGroupsAMD', 12);
  glGetPerfMonitorCountersAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorCountersAMD', 20);
  glGetPerfMonitorGroupStringAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorGroupStringAMD', 16);
  glGetPerfMonitorCounterStringAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorCounterStringAMD', 20);
  glGetPerfMonitorCounterInfoAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorCounterInfoAMD', 16);
  glGenPerfMonitorsAMD := glGetProcAddress(GLESLib,'glGenPerfMonitorsAMD', 8);
  glDeletePerfMonitorsAMD := glGetProcAddress(GLESLib,'glDeletePerfMonitorsAMD', 8);
  glSelectPerfMonitorCountersAMD := glGetProcAddress(GLESLib,'glSelectPerfMonitorCountersAMD', 20);
  glBeginPerfMonitorAMD := glGetProcAddress(GLESLib,'glBeginPerfMonitorAMD', 4);
  glEndPerfMonitorAMD := glGetProcAddress(GLESLib,'glEndPerfMonitorAMD', 4);
  glGetPerfMonitorCounterDataAMD := glGetProcAddress(GLESLib,'glGetPerfMonitorCounterDataAMD', 20);
  Result := Assigned(glActiveTexture);

  {$ifdef DEBUG_BS}
  if Result then
    BSWriteMsg('LoadGLESv2', 'GLES2 initialized successfully')
  else
    BSWriteMsg('LoadGLESv2', 'Could not initialize GLES2: ' + lib)
  {$endif}

end;

{$ifdef GLES30}
procedure LoadGLESv3;
begin
  glGenVertexArrays := glGetProcAddress(GLESLib, 'glGenVertexArrays', 8);
  glDeleteVertexArrays := glGetProcAddress(GLESLib, 'glDeleteVertexArrays', 8);
  glBindVertexArray := glGetProcAddress(GLESLib, 'glBindVertexArray', 4);
  glDrawArraysInstanced := glGetProcAddress(GLESLib, 'glDrawArraysInstanced', 16);
  glDrawElementsInstanced := glGetProcAddress(GLESLib, 'glDrawElementsInstanced', 20);
  glVertexAttribDivisor := glGetProcAddress(GLESLib, 'glVertexAttribDivisor', 8);
  glMapBufferRange := glGetProcAddress(GLESLib, 'glMapBufferRange', 16);
  glUnmapBuffer := glGetProcAddress(GLESLib, 'glUnmapBuffer', 4);

  glFramebufferTextureLayer := glGetProcAddress(GLESLib, 'glFramebufferTextureLayer', 20);
  glRenderbufferStorageMultisample := glGetProcAddress(GLESLib, 'glRenderbufferStorageMultisample', 20);
  glBlitFramebuffer := glGetProcAddress(GLESLib, 'glBlitFramebuffer', 40);
  // glGenerateMipmap:
  // glGetFramebufferAttachmentParameteriv:
  // glFramebufferRenderbuffer:
  glFramebufferTexture3D := glGetProcAddress(GLESLib, 'glFramebufferTexture3D', 24);
  //glFramebufferTexture2D:
  glFramebufferTexture1D := glGetProcAddress(GLESLib, 'glFramebufferTexture1D', 20);
end;
{$endif}

function InitGLES(const PathGL: string): boolean;
begin
  Result := LoadGLESv2(@PathGL[1]);
  {$ifdef GLES30}
  LoadGLESv3;
  {$endif}
end;

initialization

  //InitGLES;


end.

