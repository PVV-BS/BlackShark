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


unit bs.gl.egl;

{$I BlackSharkCfg.inc}

interface

uses
  {$ifdef MSWINDOWS}
    Windows,
  {$endif}
  {$ifdef X}
    bs.linux,
  {$endif}
    bs.gl.es
  ;

const
  /// esCreateWindow flag - RGB color buffer
  ES_WINDOW_RGB = 0;
  /// esCreateWindow flag - ALPHA color buffer
  ES_WINDOW_ALPHA = 1;
  /// esCreateWindow flag - depth buffer
  ES_WINDOW_DEPTH = 2;
  /// esCreateWindow flag - stencil buffer
  ES_WINDOW_STENCIL = 4;
  /// esCreateWindow flat - multi-sample buffer
  ES_WINDOW_MULTISAMPLE = 8;

type


  ///
  // Types
  //

  {$IFDEF FPC}
    {$PACKRECORDS C}
  {$ENDIF}

    PEGLConfig  = ^EGLConfig;
    PEGLint  = ^EGLint;
    EGLint = integer;

    EGLConfig = pointer;

    { EGL Types  }
    { EGLint is defined in eglplatform.h  }

type

{$ifdef X}
     EGLNativeDisplayType = PDisplay;

     EGLNativeWindowType = TWindow;

     EGLNativePixmapType = TPixmap;
{$else X}
{$ifdef MSWINDOWS}
     EGLNativeDisplayType = HDC;

     EGLNativeWindowType = HWND;

     EGLNativePixmapType = HBITMAP;
{$else MSWINDOWS}
     TNativeDisplayType = record
     { Opaque }
     end;

     PNativeDisplayType = ^TNativeDisplayType;

     EGLNativeDisplayType = PNativeDisplayType;

     EGLNativeWindowType = pointer;

     EGLNativePixmapType = pointer;
{$endif MSWINDOWS}
{$endif X}

     EGLBoolean = Cardinal;

     EGLenum = Cardinal;


     EGLContext = pointer;

     EGLDisplay = pointer;

     EGLSurface = pointer;

     EGLClientBuffer = pointer;

  { EGL Versioning  }

  const
     EGL_VERSION_1_0 = 1;
     EGL_VERSION_1_1 = 1;
     EGL_VERSION_1_2 = 1;
     EGL_VERSION_1_3 = 1;
     EGL_VERSION_1_4 = 1;
  { EGL Enumerants. Bitmasks and other exceptional cases aside, most
   * enums are assigned unique values starting at 0x3000.
    }
  { EGL aliases  }
     EGL_FALSE = 0;
     EGL_TRUE = 1;
  { Out-of-band handle values  }
  { was #define dname def_expr }
  function EGL_DEFAULT_DISPLAY : EGLNativeDisplayType;

  { was #define dname def_expr }
  function EGL_NO_CONTEXT : EGLContext;

  { was #define dname def_expr }
  function EGL_NO_DISPLAY : EGLDisplay;

  { was #define dname def_expr }
  function EGL_NO_SURFACE : EGLSurface;

  { Out-of-band attribute value  }
  { was #define dname def_expr }
  function EGL_DONT_CARE : EGLint;

  { Errors / GetError return values  }

  const
     EGL_SUCCESS = $3000;
     EGL_NOT_INITIALIZED = $3001;
     EGL_BAD_ACCESS = $3002;
     EGL_BAD_ALLOC = $3003;
     EGL_BAD_ATTRIBUTE = $3004;
     EGL_BAD_CONFIG = $3005;
     EGL_BAD_CONTEXT = $3006;
     EGL_BAD_CURRENT_SURFACE = $3007;
     EGL_BAD_DISPLAY = $3008;
     EGL_BAD_MATCH = $3009;
     EGL_BAD_NATIVE_PIXMAP = $300A;
     EGL_BAD_NATIVE_WINDOW = $300B;
     EGL_BAD_PARAMETER = $300C;
     EGL_BAD_SURFACE = $300D;
  { EGL 1.1 - IMG_power_management  }
     EGL_CONTEXT_LOST = $300E;
  { Reserved 0x300F-0x301F for additional errors  }
  { Config attributes  }
     EGL_BUFFER_SIZE = $3020;
     EGL_ALPHA_SIZE = $3021;
     EGL_BLUE_SIZE = $3022;
     EGL_GREEN_SIZE = $3023;
     EGL_RED_SIZE = $3024;
     EGL_DEPTH_SIZE = $3025;
     EGL_STENCIL_SIZE = $3026;
     EGL_CONFIG_CAVEAT = $3027;
     EGL_CONFIG_ID = $3028;
     EGL_LEVEL = $3029;
     EGL_MAX_PBUFFER_HEIGHT = $302A;
     EGL_MAX_PBUFFER_PIXELS = $302B;
     EGL_MAX_PBUFFER_WIDTH = $302C;
     EGL_NATIVE_RENDERABLE = $302D;
     EGL_NATIVE_VISUAL_ID = $302E;
     EGL_NATIVE_VISUAL_TYPE = $302F;
     EGL_PRESERVED_RESOURCES = $3030;
     EGL_SAMPLES = $3031;
     EGL_SAMPLE_BUFFERS = $3032;
     EGL_SURFACE_TYPE = $3033;
     EGL_TRANSPARENT_TYPE = $3034;
     EGL_TRANSPARENT_BLUE_VALUE = $3035;
     EGL_TRANSPARENT_GREEN_VALUE = $3036;
     EGL_TRANSPARENT_RED_VALUE = $3037;
  { Attrib list terminator  }
     EGL_NONE = $3038;
     EGL_BIND_TO_TEXTURE_RGB = $3039;
     EGL_BIND_TO_TEXTURE_RGBA = $303A;
     EGL_MIN_SWAP_INTERVAL = $303B;
     EGL_MAX_SWAP_INTERVAL = $303C;
     EGL_LUMINANCE_SIZE = $303D;
     EGL_ALPHA_MASK_SIZE = $303E;
     EGL_COLOR_BUFFER_TYPE = $303F;
     EGL_RENDERABLE_TYPE = $3040;
  { Pseudo-attribute (not queryable)  }
     EGL_MATCH_NATIVE_PIXMAP = $3041;
     EGL_CONFORMANT = $3042;
  { Reserved 0x3041-0x304F for additional config attributes  }
  { Config attribute values  }
  { EGL_CONFIG_CAVEAT value  }
     EGL_SLOW_CONFIG = $3050;
  { EGL_CONFIG_CAVEAT value  }
     EGL_NON_CONFORMANT_CONFIG = $3051;
  { EGL_TRANSPARENT_TYPE value  }
     EGL_TRANSPARENT_RGB = $3052;
  { EGL_COLOR_BUFFER_TYPE value  }
     EGL_RGB_BUFFER = $308E;
  { EGL_COLOR_BUFFER_TYPE value  }
     EGL_LUMINANCE_BUFFER = $308F;
  { More config attribute values, for EGL_TEXTURE_FORMAT  }
     EGL_NO_TEXTURE = $305C;
     EGL_TEXTURE_RGB = $305D;
     EGL_TEXTURE_RGBA = $305E;
     EGL_TEXTURE_2D = $305F;
  { Config attribute mask bits  }
  { EGL_SURFACE_TYPE mask bits  }
     EGL_PBUFFER_BIT = $0001;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_PIXMAP_BIT = $0002;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_WINDOW_BIT = $0004;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_VG_COLORSPACE_LINEAR_BIT = $0020;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_VG_ALPHA_FORMAT_PRE_BIT = $0040;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_MULTISAMPLE_RESOLVE_BOX_BIT = $0200;
  { EGL_SURFACE_TYPE mask bits  }
     EGL_SWAP_BEHAVIOR_PRESERVED_BIT = $0400;
  { EGL_RENDERABLE_TYPE mask bits  }
     EGL_OPENGL_ES_BIT = $0001;
  { EGL_RENDERABLE_TYPE mask bits  }
     EGL_OPENVG_BIT = $0002;
  { EGL_RENDERABLE_TYPE mask bits  }
     EGL_OPENGL_ES2_BIT = $0004;
  { EGL_RENDERABLE_TYPE mask bits  }
     EGL_OPENGL_BIT = $0008;
  { QueryString targets  }
     EGL_VENDOR = $3053;
     EGL_VERSION = $3054;
     EGL_EXTENSIONS = $3055;
     EGL_CLIENT_APIS = $308D;
  { QuerySurface / SurfaceAttrib / CreatePbufferSurface targets  }
     EGL_HEIGHT = $3056;
     EGL_WIDTH = $3057;
     EGL_LARGEST_PBUFFER = $3058;
     EGL_TEXTURE_FORMAT = $3080;
     EGL_TEXTURE_TARGET = $3081;
     EGL_MIPMAP_TEXTURE = $3082;
     EGL_MIPMAP_LEVEL = $3083;
     EGL_RENDER_BUFFER = $3086;
     EGL_VG_COLORSPACE = $3087;
     EGL_VG_ALPHA_FORMAT = $3088;
     EGL_HORIZONTAL_RESOLUTION = $3090;
     EGL_VERTICAL_RESOLUTION = $3091;
     EGL_PIXEL_ASPECT_RATIO = $3092;
     EGL_SWAP_BEHAVIOR = $3093;
     EGL_MULTISAMPLE_RESOLVE = $3099;
  { EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets  }
     EGL_BACK_BUFFER = $3084;
     EGL_SINGLE_BUFFER = $3085;
  { OpenVG color spaces  }
  { EGL_VG_COLORSPACE value  }
     EGL_VG_COLORSPACE_sRGB = $3089;
  { EGL_VG_COLORSPACE value  }
     EGL_VG_COLORSPACE_LINEAR = $308A;
  { OpenVG alpha formats  }
  { EGL_ALPHA_FORMAT value  }
     EGL_VG_ALPHA_FORMAT_NONPRE = $308B;
  { EGL_ALPHA_FORMAT value  }
     EGL_VG_ALPHA_FORMAT_PRE = $308C;
  { Constant scale factor by which fractional display resolutions &
   * aspect ratio are scaled when queried as integer values.
    }
     EGL_DISPLAY_SCALING = 10000;
  { Unknown display resolution/aspect ratio  }
  { was #define dname def_expr }
  function EGL_UNKNOWN : EGLint;

  { Back buffer swap behaviors  }
  { EGL_SWAP_BEHAVIOR value  }

  const
     EGL_BUFFER_PRESERVED = $3094;
  { EGL_SWAP_BEHAVIOR value  }
     EGL_BUFFER_DESTROYED = $3095;
  { CreatePbufferFromClientBuffer buffer types  }
     EGL_OPENVG_IMAGE = $3096;
  { QueryContext targets  }
     EGL_CONTEXT_CLIENT_TYPE = $3097;
  { CreateContext attributes  }
     EGL_CONTEXT_CLIENT_VERSION = $3098;
  { Multisample resolution behaviors  }
  { EGL_MULTISAMPLE_RESOLVE value  }
     EGL_MULTISAMPLE_RESOLVE_DEFAULT = $309A;
  { EGL_MULTISAMPLE_RESOLVE value  }
     EGL_MULTISAMPLE_RESOLVE_BOX = $309B;
  { BindAPI/QueryAPI targets  }
     EGL_OPENGL_ES_API = $30A0;
     EGL_OPENVG_API = $30A1;
     EGL_OPENGL_API = $30A2;
  { GetCurrentSurface targets  }
     EGL_DRAW = $3059;
     EGL_READ = $305A;
  { WaitNative engines  }
     EGL_CORE_NATIVE_ENGINE = $305B;
  { EGL 1.2 tokens renamed for consistency in EGL 1.3  }
     EGL_COLORSPACE = EGL_VG_COLORSPACE;
     EGL_ALPHA_FORMAT = EGL_VG_ALPHA_FORMAT;
     EGL_COLORSPACE_sRGB = EGL_VG_COLORSPACE_sRGB;
     EGL_COLORSPACE_LINEAR = EGL_VG_COLORSPACE_LINEAR;
     EGL_ALPHA_FORMAT_NONPRE = EGL_VG_ALPHA_FORMAT_NONPRE;
     EGL_ALPHA_FORMAT_PRE = EGL_VG_ALPHA_FORMAT_PRE;
  { EGL extensions must request enum blocks from the Khronos
   * API Registrar, who maintains the enumerant registry. Submit
   * a bug in Khronos Bugzilla against task "Registry".
    }
  { EGL Functions  }

  var
    eglGetError : function:EGLint;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetDisplay : function(display_id:EGLNativeDisplayType):EGLDisplay;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglInitialize : function(dpy:EGLDisplay; major:pEGLint; minor:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglTerminate : function(dpy:EGLDisplay):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglQueryString : function(dpy:EGLDisplay; name:EGLint):pchar;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetConfigs : function(dpy:EGLDisplay; configs:pEGLConfig; config_size:EGLint; num_config:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglChooseConfig : function(dpy:EGLDisplay; attrib_list:pEGLint; configs:pEGLConfig; config_size:EGLint; num_config:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetConfigAttrib : function(dpy:EGLDisplay; config:EGLConfig; attribute:EGLint; value:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglCreateWindowSurface : function(dpy:EGLDisplay; config:EGLConfig; win:EGLNativeWindowType; attrib_list:pEGLint):EGLSurface;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglCreatePbufferSurface : function(dpy:EGLDisplay; config:EGLConfig; attrib_list:pEGLint):EGLSurface;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglCreatePixmapSurface : function(dpy:EGLDisplay; config:EGLConfig; pixmap:EGLNativePixmapType; attrib_list:pEGLint):EGLSurface;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglDestroySurface : function(dpy:EGLDisplay; surface:EGLSurface):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglQuerySurface : function(dpy:EGLDisplay; surface:EGLSurface; attribute:EGLint; value:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglBindAPI : function(api:EGLenum):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglQueryAPI : function:EGLenum;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglWaitClient : function:EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglReleaseThread : function:EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglCreatePbufferFromClientBuffer : function(dpy:EGLDisplay; buftype:EGLenum; buffer:EGLClientBuffer; config:EGLConfig; attrib_list:pEGLint):EGLSurface;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglSurfaceAttrib : function(dpy:EGLDisplay; surface:EGLSurface; attribute:EGLint; value:EGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglBindTexImage : function(dpy:EGLDisplay; surface:EGLSurface; buffer:EGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglReleaseTexImage : function(dpy:EGLDisplay; surface:EGLSurface; buffer:EGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglSwapInterval : function(dpy:EGLDisplay; interval:EGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
(* Const before type ignored *)
    eglCreateContext : function(dpy:EGLDisplay; config:EGLConfig; share_context:EGLContext; attrib_list:pEGLint):EGLContext;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglDestroyContext : function(dpy:EGLDisplay; ctx:EGLContext):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglMakeCurrent : function(dpy:EGLDisplay; draw:EGLSurface; read:EGLSurface; ctx:EGLContext):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetCurrentContext : function:EGLContext;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetCurrentSurface : function(readdraw:EGLint):EGLSurface;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglGetCurrentDisplay : function:EGLDisplay;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglQueryContext : function(dpy:EGLDisplay; ctx:EGLContext; attribute:EGLint; value:pEGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglWaitGL : function:EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglWaitNative : function(engine:EGLint):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglSwapBuffers : function(dpy:EGLDisplay; surface:EGLSurface):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
    eglCopyBuffers : function(dpy:EGLDisplay; surface:EGLSurface; target:EGLNativePixmapType):EGLBoolean;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}


    eglGetPlatformDisplay: function(platform: EGLenum; native_display: Pointer; attrib_list: PEGLint): EGLDisplay; {$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}

    { This is a generic function pointer type, whose name indicates it must
   * be cast to the proper type *and calling convention* before use.
    }

  type

     __eglMustCastToProperFunctionPointerType = procedure (_para1:pointer);{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  { Now, define eglGetProcAddress using the generic function ptr. type  }
(* Const before type ignored *)

  var
    eglGetProcAddress : function(procname: PAnsiChar):Pointer;{$ifdef MSWINDOWS}stdcall;{$else}cdecl;{$endif}
  { Header file version number  }
  { Current version at http://www.khronos.org/registry/egl/  }

  const
     EGL_EGLEXT_VERSION = 3;
     EGL_KHR_config_attribs = 1;
  { EGLConfig attribute  }
     EGL_CONFORMANT_KHR = $3042;
  { EGL_SURFACE_TYPE bitfield  }
     EGL_VG_COLORSPACE_LINEAR_BIT_KHR = $0020;
  { EGL_SURFACE_TYPE bitfield  }
     EGL_VG_ALPHA_FORMAT_PRE_BIT_KHR = $0040;
     EGL_KHR_lock_surface = 1;
  { EGL_LOCK_USAGE_HINT_KHR bitfield  }
     EGL_READ_SURFACE_BIT_KHR = $0001;
  { EGL_LOCK_USAGE_HINT_KHR bitfield  }
     EGL_WRITE_SURFACE_BIT_KHR = $0002;
  { EGL_SURFACE_TYPE bitfield  }
     EGL_LOCK_SURFACE_BIT_KHR = $0080;
  { EGL_SURFACE_TYPE bitfield  }
     EGL_OPTIMAL_FORMAT_BIT_KHR = $0100;
  { EGLConfig attribute  }
     EGL_MATCH_FORMAT_KHR = $3043;
  { EGL_MATCH_FORMAT_KHR value  }
     EGL_FORMAT_RGB_565_EXACT_KHR = $30C0;
  { EGL_MATCH_FORMAT_KHR value  }
     EGL_FORMAT_RGB_565_KHR = $30C1;
  { EGL_MATCH_FORMAT_KHR value  }
     EGL_FORMAT_RGBA_8888_EXACT_KHR = $30C2;
  { EGL_MATCH_FORMAT_KHR value  }
     EGL_FORMAT_RGBA_8888_KHR = $30C3;
  { eglLockSurfaceKHR attribute  }
     EGL_MAP_PRESERVE_PIXELS_KHR = $30C4;
  { eglLockSurfaceKHR attribute  }
     EGL_LOCK_USAGE_HINT_KHR = $30C5;
  { eglQuerySurface attribute  }
     EGL_BITMAP_POINTER_KHR = $30C6;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PITCH_KHR = $30C7;
  { eglQuerySurface attribute  }
     EGL_BITMAP_ORIGIN_KHR = $30C8;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PIXEL_RED_OFFSET_KHR = $30C9;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PIXEL_GREEN_OFFSET_KHR = $30CA;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PIXEL_BLUE_OFFSET_KHR = $30CB;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PIXEL_ALPHA_OFFSET_KHR = $30CC;
  { eglQuerySurface attribute  }
     EGL_BITMAP_PIXEL_LUMINANCE_OFFSET_KHR = $30CD;
  { EGL_BITMAP_ORIGIN_KHR value  }
     EGL_LOWER_LEFT_KHR = $30CE;
  { EGL_BITMAP_ORIGIN_KHR value  }
     EGL_UPPER_LEFT_KHR = $30CF;
(* Const before type ignored *)

  const
     EGL_KHR_image = 1;
  { eglCreateImageKHR target  }
     EGL_NATIVE_PIXMAP_KHR = $30B0;

type
     EGLImageKHR = pointer;
  { was #define dname def_expr }
  function EGL_NO_IMAGE_KHR : EGLImageKHR;

(* Const before type ignored *)

  const
     EGL_KHR_vg_parent_image = 1;
  { eglCreateImageKHR target  }
     EGL_VG_PARENT_IMAGE_KHR = $30BA;
     EGL_KHR_gl_texture_2D_image = 1;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_2D_KHR = $30B1;
  { eglCreateImageKHR attribute  }
     EGL_GL_TEXTURE_LEVEL_KHR = $30BC;
     EGL_KHR_gl_texture_cubemap_image = 1;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_X_KHR = $30B3;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_X_KHR = $30B4;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Y_KHR = $30B5;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_KHR = $30B6;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Z_KHR = $30B7;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_KHR = $30B8;
     EGL_KHR_gl_texture_3D_image = 1;
  { eglCreateImageKHR target  }
     EGL_GL_TEXTURE_3D_KHR = $30B2;
  { eglCreateImageKHR attribute  }
     EGL_GL_TEXTURE_ZOFFSET_KHR = $30BD;
     EGL_KHR_gl_renderbuffer_image = 1;
  { eglCreateImageKHR target  }
     EGL_GL_RENDERBUFFER_KHR = $30B9;
     EGL_KHR_image_base = 1;
  { Most interfaces defined by EGL_KHR_image_pixmap above  }
  { eglCreateImageKHR attribute  }
     EGL_IMAGE_PRESERVED_KHR = $30D2;
     EGL_KHR_image_pixmap = 1;
  { Interfaces defined by EGL_KHR_image above  }


    EGL_PLATFORM_ANGLE_ANGLE          = $3202;
    EGL_PLATFORM_ANGLE_TYPE_ANGLE     = $3203;
    EGL_PLATFORM_ANGLE_MAX_VERSION_MAJOR_ANGLE = $3204;
    EGL_PLATFORM_ANGLE_MAX_VERSION_MINOR_ANGLE = $3205;
    EGL_PLATFORM_ANGLE_TYPE_DEFAULT_ANGLE = $3206;
    EGL_PLATFORM_ANGLE_DEBUG_LAYERS_ENABLED_ANGLE = $3451;
    EGL_PLATFORM_ANGLE_DEVICE_TYPE_ANGLE = $3209;
    EGL_PLATFORM_ANGLE_DEVICE_TYPE_HARDWARE_ANGLE = $320A;
    EGL_PLATFORM_ANGLE_DEVICE_TYPE_NULL_ANGLE = $345E;

type
  ESMatrix = record
    m: array[0..3, 0..3] of GLfloat;
  end;

  PESContext = ^TESContext;

  TEGLDrawFunc = procedure (ESContext: PESContext);
  TEGLKeyFunc = procedure (ESContext: PESContext; Key: PAnsiChar; int1: int32; int2: int32);
  TEGLUpdateFunc = procedure (ESContext: PESContext; deltaTime: GLfloat);

  PEGLWindow = ^TEGLWindow;
  TEGLWindow = record
    window: int32;

    /// Window width
    width: GLint;

    /// Window height
    height: GLint;

    /// Window handle
    hWnd: EGLNativeWindowType;
    DC: EGLNativeDisplayType;
  end;

  TESContext = record
     /// Put your user data here...
     userData: Pointer;

     eglWindow: PEGLWindow;

     /// EGL display
     eglDisplay: EGLDisplay;

     /// EGL context
     eglContext: EGLContext;

     /// EGL surface
     eglSurface: EGLSurface;

     /// Callbacks
     EGLDrawFunc: TEGLDrawFunc;
     EGLKeyFunc: TEGLKeyFunc;
     EGLUpdateFunc: TEGLUpdateFunc;
  end;

  TContextAttributes = array of EGLint;

  TSharedEglContext = class
  private
    class var FSharedContext: EGLContext;
    class var FSharedDisplay: EGLDisplay;
    class procedure CreateSharedContext;
    class function GetSharedContext: EGLContext; static;
    class function GetSharedDisplay: EGLDisplay; static;
    class destructor Destroy;
  public
    class var SharedSurface: EGLSurface;
    class var SharedAttrib: TContextAttributes;
    class var SharedConfig: array of EGLConfig;
    class var SharedConfigSelected: EGLConfig;
    class property SharedDisplay: EGLDisplay read GetSharedDisplay;
    class property SharedContext: EGLContext read GetSharedContext;
    class function GetEglFlags(MultiSample: Boolean): int32;
  end;

procedure InitEGL;

function CreateWindowES (DC: EGLNativeDisplayType; hWnd: EGLNativeWindowType): PEGLWindow;


procedure CreateEglAttributes(Flags: GLuint; var AAttribs: TContextAttributes);
// Creates an EGL rendering context and all associated elements
function CreateEGLContext (EGLWindow: PEGLWindow): PESContext;

function GLMakeCurrent(Context: Pointer): boolean;
function GetPathGL: string;

procedure FreeEGLContext(var ESContext: PESContext; FreeWindow: boolean = true);
procedure FreeEGLSurface(ESContext: PESContext);
procedure FreeEGLWindow(var EGLWindow: PEGLWindow);

implementation

uses
    SysUtils
  , bs.strings
  , bs.config
  ;

class procedure TSharedEglContext.CreateSharedContext;
var
  numConfigs: EGLint;
  majorVersion: EGLint;
  minorVersion: EGLint;
  attribValue: EGLint;
  contextAttribs: array[0..4] of EGLint;
  attributes: TContextAttributes;
  i, j, k: int32;
begin

  if not Assigned(FSharedContext) then
  begin
    if GLESLib = 0 then
      bs.gl.es.InitGLES(bs.gl.egl.GetPathGL);

    if GLESLib = 0 then
      exit;

    SharedConfigSelected := nil;
    eglBindAPI(EGL_OPENGL_ES_API);
    FSharedDisplay := eglGetDisplay(EGL_DEFAULT_DISPLAY);

    if eglInitialize(FSharedDisplay, @majorVersion, @minorVersion) = 0 then
      exit;

    CreateEglAttributes(GetEglFlags(BSConfig.MultiSampling), SharedAttrib);

    attributes := nil;
    SetLength(attributes, length(SharedAttrib));
    move(SharedAttrib[0], attributes[0], SizeOf(EGLint)*length(SharedAttrib));

    numConfigs := 0;

    if (eglGetConfigs(FSharedDisplay, nil, 0, @numConfigs) = EGL_FALSE) or (numConfigs = 0) then
      exit;

    SetLength(SharedConfig, numConfigs);
    if (eglGetConfigs(FSharedDisplay, @SharedConfig[0], numConfigs, @numConfigs) = EGL_FALSE) then
      exit;
    SharedConfigSelected := SharedConfig[0];
    for i := 0 to numConfigs - 1 do
    begin
      j := 0;
      SharedConfigSelected := SharedConfig[i];
      while attributes[j] <> EGL_NONE do
      begin
         if eglGetConfigAttrib(FSharedDisplay, SharedConfigSelected, attributes[j], @attribValue) = EGL_FALSE then
         begin
           k := j;
           while attributes[j] <> EGL_NONE do
           begin
              attributes[j] := attributes[j+2];
              attributes[j+1] := attributes[j+3];
              inc(j, 2);
           end;
           j := k;
           continue;
         end;
         //attributes[j+1] := attribValue;
         inc(j, 2);
      end;

      if (attributes[0] = EGL_NONE) then
      begin
        SharedConfigSelected := nil;
        move(SharedAttrib[0], attributes[0], SizeOf(EGLint)*length(SharedAttrib));
      end else
        break;
    end;

    if not Assigned(SharedConfigSelected) then
       exit;

    //if ( eglChooseConfig(SharedDisplay, @SharedAttrib[0], nil, 1, @numConfigs) = EGL_FALSE ) then
    //  exit;

    if (eglChooseConfig(FSharedDisplay, @attributes[0], @SharedConfigSelected, 1, @numConfigs) = EGL_FALSE) then
      exit;

    contextAttribs[0] := EGL_CONTEXT_CLIENT_VERSION;
    contextAttribs[1] := 2;
    contextAttribs[2] := EGL_NONE;
    FSharedContext := eglCreateContext(FSharedDisplay, SharedConfigSelected, EGL_NO_CONTEXT, @contextAttribs[0]);
    if SharedContext = EGL_NO_CONTEXT then
      raise Exception.Create('eglCreateContext:' + IntToStr(eglGetError()));

    move(attributes[0], SharedAttrib[0], SizeOf(EGLint)*length(SharedAttrib));

    {contextAttribs[0] := EGL_WIDTH;
    contextAttribs[1] := 1;
    contextAttribs[2] := EGL_HEIGHT;
    contextAttribs[3] := 1;
    contextAttribs[4] := EGL_NONE;
    SharedSurface := eglCreatePbufferSurface(SharedDisplay, SharedConfigSelected, @contextAttribs[0]);
    if SharedSurface = EGL_NO_SURFACE then
      raise Exception.Create('eglCreatePbufferSurface:' + IntToStr(eglGetError()));

    if eglMakeCurrent(SharedDisplay, SharedSurface, SharedSurface, SharedContext) = 0 then
    begin
      eglDestroyContext(SharedDisplay, SharedContext);
      eglDestroySurface(SharedDisplay, SharedSurface);
      raise Exception.Create('eglMakeCurrent:' + IntToStr(eglGetError()));
    end;  }

  end;
end;

class function TSharedEglContext.GetEglFlags(MultiSample: Boolean): int32;
begin
  Result := ES_WINDOW_RGB or ES_WINDOW_ALPHA or ES_WINDOW_DEPTH or ES_WINDOW_STENCIL;
  if MultiSample then
    Result := Result or ES_WINDOW_MULTISAMPLE;
end;

class function TSharedEglContext.GetSharedContext: EGLContext;
begin
  if not Assigned(FSharedContext) then
    CreateSharedContext;
  Result := FSharedContext;
end;

class function TSharedEglContext.GetSharedDisplay: EGLDisplay;
begin
  if not Assigned(FSharedContext) then
    CreateSharedContext;
  Result := FSharedDisplay;
end;

class destructor TSharedEglContext.Destroy;
begin
  eglDestroySurface(SharedDisplay, SharedSurface);
  eglDestroyContext(SharedDisplay, SharedContext);
end;

function GetPathGL: string;
begin
    {$ifdef MSWINDOWS}
      {$ifdef Win32}
        Result := 'Win32\libGLESv2.dll';
      {$else}
        Result := 'Win64\libGLESv2.dll';
      {$endif}

    {$else MSWINDOWS}
      { TODO: embedded platforms }
      {$ifdef darwin}
        Result := '/System/Library/Frameworks/OpenGLES.framework/OpenGLES';
      {$else darwin}
        Result := 'libGLESv2.so';
      {$endif darwin}
    {$endif MSWINDOWS}
end;

{ was #define dname def_expr }
function EGL_DEFAULT_DISPLAY : EGLNativeDisplayType;
begin
   EGL_DEFAULT_DISPLAY:=EGLNativeDisplayType(0);
end;

{ was #define dname def_expr }
function EGL_NO_CONTEXT : EGLContext;
begin
   EGL_NO_CONTEXT:=EGLContext(0);
end;

{ was #define dname def_expr }
function EGL_NO_DISPLAY : EGLDisplay;
begin
   EGL_NO_DISPLAY:=EGLDisplay(0);
end;

{ was #define dname def_expr }
function EGL_NO_SURFACE : EGLSurface;
begin
   EGL_NO_SURFACE:=EGLSurface(0);
end;

{ was #define dname def_expr }
function EGL_DONT_CARE : EGLint;
begin
   EGL_DONT_CARE:=EGLint(-(1));
end;

{ was #define dname def_expr }
function EGL_UNKNOWN : EGLint;
begin
   EGL_UNKNOWN:=EGLint(-(1));
end;

{ was #define dname def_expr }
function EGL_NO_IMAGE_KHR : EGLImageKHR;
begin
   EGL_NO_IMAGE_KHR:=EGLImageKHR(0);
end;


var
  {$ifdef FPC}
  EGLLib: TLibHandle = 0;
  {$else}
  EGLLib: System.THandle = 0;
  {$endif}


procedure FreeEGL;
begin
  if EGLLib <> 0 then
    FreeLibrary(EGLLib);

  eglGetError := nil;
  eglGetDisplay := nil;
  eglInitialize := nil;
  eglTerminate := nil;
  eglQueryString := nil;
  eglGetConfigs := nil;
  eglChooseConfig := nil;
  eglGetConfigAttrib := nil;
  eglCreateWindowSurface := nil;
  eglCreatePbufferSurface := nil;
  eglCreatePixmapSurface := nil;
  eglDestroySurface := nil;
  eglQuerySurface := nil;
  eglBindAPI := nil;
  eglQueryAPI := nil;
  eglWaitClient := nil;
  eglReleaseThread := nil;
  eglCreatePbufferFromClientBuffer := nil;
  eglSurfaceAttrib := nil;
  eglBindTexImage := nil;
  eglReleaseTexImage := nil;
  eglSwapInterval := nil;
  eglCreateContext := nil;
  eglDestroyContext := nil;
  eglMakeCurrent := nil;
  eglGetCurrentContext := nil;
  eglGetCurrentSurface := nil;
  eglGetCurrentDisplay := nil;
  eglQueryContext := nil;
  eglWaitGL := nil;
  eglWaitNative := nil;
  eglSwapBuffers := nil;
  eglCopyBuffers := nil;
  eglGetProcAddress := nil;
end;

procedure LoadEGL(const lib: string);
begin
  FreeEGL;
  EGLLib := LoadLibrary(PChar(lib));
  if EGLLib = 0 then
    raise Exception.Create(format('Could not load library: %s',[lib]));

  eglGetProcAddress := GetProcAddress(EGLLib,'eglGetProcAddress');

  eglGetError := glGetProcAddress(EGLLib,'eglGetError');
  if not Assigned(eglGetError) then
    exit;

  eglGetDisplay := glGetProcAddress(EGLLib,'eglGetDisplay');
  eglGetPlatformDisplay := glGetProcAddress(EGLLib,'eglGetPlatformDisplay');
  eglInitialize := glGetProcAddress(EGLLib,'eglInitialize');
  eglTerminate := glGetProcAddress(EGLLib,'eglTerminate');
  eglQueryString := glGetProcAddress(EGLLib,'eglQueryString');
  eglGetConfigs := glGetProcAddress(EGLLib,'eglGetConfigs');
  eglChooseConfig := glGetProcAddress(EGLLib,'eglChooseConfig');
  eglGetConfigAttrib := glGetProcAddress(EGLLib,'eglGetConfigAttrib');
  eglCreateWindowSurface := glGetProcAddress(EGLLib,'eglCreateWindowSurface');
  eglCreatePbufferSurface := glGetProcAddress(EGLLib,'eglCreatePbufferSurface');
  eglCreatePixmapSurface := glGetProcAddress(EGLLib,'eglCreatePixmapSurface');
  eglDestroySurface := glGetProcAddress(EGLLib,'eglDestroySurface');
  eglQuerySurface := glGetProcAddress(EGLLib,'eglQuerySurface');
  eglBindAPI := glGetProcAddress(EGLLib,'eglBindAPI');
  eglQueryAPI := glGetProcAddress(EGLLib,'eglQueryAPI');
  eglWaitClient := glGetProcAddress(EGLLib,'eglWaitClient');
  eglReleaseThread := glGetProcAddress(EGLLib,'eglReleaseThread');
  eglCreatePbufferFromClientBuffer := glGetProcAddress(EGLLib,'eglCreatePbufferFromClientBuffer');
  eglSurfaceAttrib := glGetProcAddress(EGLLib,'eglSurfaceAttrib');
  eglBindTexImage := glGetProcAddress(EGLLib,'eglBindTexImage');
  eglReleaseTexImage := glGetProcAddress(EGLLib,'eglReleaseTexImage');
  eglSwapInterval := glGetProcAddress(EGLLib,'eglSwapInterval');
  eglCreateContext := glGetProcAddress(EGLLib,'eglCreateContext');
  eglDestroyContext := glGetProcAddress(EGLLib,'eglDestroyContext');
  eglMakeCurrent := glGetProcAddress(EGLLib,'eglMakeCurrent');
  eglGetCurrentContext := glGetProcAddress(EGLLib,'eglGetCurrentContext');
  eglGetCurrentSurface := glGetProcAddress(EGLLib,'eglGetCurrentSurface');
  eglGetCurrentDisplay := glGetProcAddress(EGLLib,'eglGetCurrentDisplay');
  eglQueryContext := glGetProcAddress(EGLLib,'eglQueryContext');
  eglWaitGL := glGetProcAddress(EGLLib,'eglWaitGL');
  eglWaitNative := glGetProcAddress(EGLLib,'eglWaitNative');
  eglSwapBuffers := glGetProcAddress(EGLLib,'eglSwapBuffers');
  eglCopyBuffers := glGetProcAddress(EGLLib,'eglCopyBuffers');

  glEGLImageTargetTexture2DOES := glGetProcAddress(GLESLib,'glEGLImageTargetTexture2DOES');
  glEGLImageTargetRenderbufferStorageOES := glGetProcAddress(GLESLib,'glEGLImageTargetRenderbufferStorageOES');
  glGetProgramBinaryOES := glGetProcAddress(GLESLib,'glGetProgramBinaryOES');
  glProgramBinaryOES := glGetProcAddress(GLESLib,'glProgramBinaryOES');
  glMapBufferOES := glGetProcAddress(GLESLib,'glMapBufferOES');
  glUnmapBufferOES := glGetProcAddress(GLESLib,'glUnmapBufferOES');
  glGetBufferPointervOES := glGetProcAddress(GLESLib,'glGetBufferPointervOES');
  glTexImage3DOES := glGetProcAddress(GLESLib,'glTexImage3DOES');
  glTexSubImage3DOES := glGetProcAddress(GLESLib,'glTexSubImage3DOES');
  glCopyTexSubImage3DOES := glGetProcAddress(GLESLib,'glCopyTexSubImage3DOES');
  glCompressedTexImage3DOES := glGetProcAddress(GLESLib,'glCompressedTexImage3DOES');
  glCompressedTexSubImage3DOES := glGetProcAddress(GLESLib,'glCompressedTexSubImage3DOES');
  glFramebufferTexture3DOES := glGetProcAddress(GLESLib,'glFramebufferTexture3DOES');
end;

function CreateWindowES(DC: EGLNativeDisplayType; hWnd: EGLNativeWindowType): PEGLWindow;
begin
  new(Result);
  Result^.window := 0;
  Result^.hWnd := hWnd;
  Result^.DC := DC;

  Result^.width := 0;
  Result^.height := 0;
end;

//    Creates an EGL rendering context and all associated elements
//
//      flags  - bitwise or of window creation flags
//          ES_WINDOW_ALPHA       - specifies that the framebuffer should have alpha
//          ES_WINDOW_DEPTH       - specifies that a depth buffer should be created
//          ES_WINDOW_STENCIL     - specifies that a stencil buffer should be created
//          ES_WINDOW_MULTISAMPLE - specifies that a multi-sample buffer should be created
//

procedure CreateEglAttributes(Flags: GLuint; var AAttribs: TContextAttributes);

  procedure AddAttrib(AType: GLInt; AValue: GLInt);
  begin
    SetLength(AAttribs, Length(AAttribs)+2);
    AAttribs[Length(AAttribs)-2] := AType;
    AAttribs[Length(AAttribs)-1] := AValue;
  end;

begin
  //AddAttrib(EGL_COLOR_BUFFER_TYPE, EGL_RGB_BUFFER);
  AddAttrib(EGL_RED_SIZE, 8);
  AddAttrib(EGL_GREEN_SIZE, 8);
  AddAttrib(EGL_BLUE_SIZE, 8);

  if (Flags and ES_WINDOW_ALPHA) > 0 then
    AddAttrib(EGL_ALPHA_SIZE, 8)
  else
    AddAttrib(EGL_ALPHA_SIZE, EGL_DONT_CARE);

  if (Flags and ES_WINDOW_DEPTH) > 0 then
    AddAttrib(EGL_DEPTH_SIZE, 8)
  else
    AddAttrib(EGL_DEPTH_SIZE, EGL_DONT_CARE);

  if (Flags and ES_WINDOW_STENCIL) > 0 then
    AddAttrib(EGL_STENCIL_SIZE, 8)
  else
    AddAttrib(EGL_STENCIL_SIZE, EGL_DONT_CARE);

  //AddAttrib(EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT);
  //AddAttrib(EGL_SURFACE_TYPE, EGL_WINDOW_BIT);
  //AddAttrib(EGL_SURFACE_TYPE, EGL_PBUFFER_BIT);

  if (Flags and ES_WINDOW_MULTISAMPLE) > 0 then
  begin
    AddAttrib(EGL_SAMPLE_BUFFERS, 1);
    AddAttrib(EGL_SAMPLES, BSConfig.MultiSamplingSamples);
  end;

  AddAttrib(EGL_NONE, EGL_NONE);
end;

//
// CreateEGLContext()
//
function CreateEGLContext(EGLWindow: PEGLWindow): PESContext;
var
   context: EGLContext;
   surface: EGLSurface;
   contextAttribs: array[0..3] of EGLint;
begin

  contextAttribs[0] := EGL_CONTEXT_CLIENT_VERSION;
  contextAttribs[1] := 2;
  contextAttribs[2] := EGL_NONE;
  contextAttribs[3] := EGL_NONE;

  {// Get Display
  display := eglGetDisplay(EGL_DEFAULT_DISPLAY); //
  if ( display = EGL_NO_DISPLAY ) then
    exit(nil);

  // Initialize EGL
  if (eglInitialize(display, @majorVersion, @minorVersion) = EGL_FALSE ) then
    exit(nil);

  if ( eglChooseConfig(display, @attribList[0], nil, 1, @numConfigs) = EGL_FALSE ) then
    exit(nil);
  // Choose config
  if ( eglChooseConfig(display, @attribList[0], @config, 1, @numConfigs) = EGL_FALSE ) then
    exit(nil);   }

  // Create a surface
  surface := eglCreateWindowSurface(TSharedEglContext.SharedDisplay, TSharedEglContext.SharedConfigSelected, EGLWindow^.hWnd, nil); //@TSharedEglContext.SharedAttrib[0]
  if ( surface = EGL_NO_SURFACE ) then
    exit(nil);


  //if BSConfig.MultiSampling then
  //  if (eglSurfaceAttrib(TSharedEglContext.SharedDisplay, surface, EGL_MULTISAMPLE_RESOLVE, EGL_MULTISAMPLE_RESOLVE_DEFAULT) = EGL_FALSE) then
  //    exit(nil);
  // Create a GL context
  //if gl_SharedContext <> nil then
  //  context := eglCreateContext(display, config, gl_SharedContext, @contextAttribs[0] ) else
  context := eglCreateContext(TSharedEglContext.SharedDisplay, TSharedEglContext.SharedConfigSelected, TSharedEglContext.SharedContext, @contextAttribs[0] );

  if ( context = EGL_NO_CONTEXT ) then
    exit(nil);

  // Make the context current
  if ( eglMakeCurrent(TSharedEglContext.SharedDisplay, surface, surface, context) = EGL_FALSE ) then
    exit(nil);

  new(Result);
  Result^.eglDisplay := TSharedEglContext.SharedDisplay;
  Result^.eglSurface := surface;
  Result^.eglContext := context;
  Result^.eglWindow := EGLWindow;
end;

function GLMakeCurrent(Context: Pointer): boolean;
begin
  Result := eglMakeCurrent(PESContext(Context)^.eglDisplay, PESContext(Context)^.eglSurface,
    PESContext(Context)^.eglSurface, PESContext(Context)^.eglContext) = EGL_TRUE;
end;

procedure FreeEGLSurface(ESContext: PESContext);
begin
  eglDestroySurface(ESContext^.eglDisplay, ESContext^.eglSurface);
  ESContext^.eglSurface := nil;
end;

procedure FreeEGLContext(var ESContext: PESContext; FreeWindow: boolean);
begin
  //dec(gl_CountContexts);
  if FreeWindow then
    FreeEGLWindow(ESContext^.eglWindow);
  dispose(ESContext);
  ESContext := nil;
end;


procedure FreeEGLWindow(var EGLWindow: PEGLWindow);
begin
  //if (EGLWindow^.window <> 0) then
  //  glutDestroyWindow(EGLWindow^.window);
  dispose(EGLWindow);
  EGLWindow := nil;
end;

procedure InitEGL;
begin
  LoadEGL(
  {$ifdef MSWINDOWS}
    {$ifdef Win32}
      'Win32\libEGL.dll'
    {$else}
      'Win64\libEGL.dll'
    {$endif}
  {$else}
    'libEGL.so'
  {$endif});
end;

initialization

  InitEGL;

end.

