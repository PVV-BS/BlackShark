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


unit bs.gl.context;

{$I BlackSharkCfg.inc}

interface

uses
    bs.events
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  , bs.gl.egl
  {$endif}
  ;

const
  /// RGB color buffer
  ES_WINDOW_RGB = 0;
  /// ALPHA color buffer
  ES_WINDOW_ALPHA = 1;
  /// depth buffer
  ES_WINDOW_DEPTH = 2;
  /// stencil buffer
  ES_WINDOW_STENCIL = 4;
  /// multi-sample buffer
  ES_WINDOW_MULTISAMPLE = 8;

type

  TBlackSharkContext = class;

  TMakeCurrentFunc = function (Context: Pointer): boolean;

  { TBlackSharkContext }

  TBlackSharkContext = class
  private
    FWnd: EGLNativeWindowType;
    FDC: EGLNativeDisplayType;
    /// EGL display
    eglDisplay: EGLDisplay;
    /// EGL context
    eglContext: EGLContext;
    /// EGL surface
    eglSurface: EGLSurface;
    //EGLWindow: PEGLWindow;
    FContextIsLost: boolean;
    //GLContextES: PESContext;
    {FGreenBits: Cardinal;
    FDepthBits: Cardinal;
    FRedBits: Cardinal;
    FAlphaBits: Cardinal;
    FStencilBits: Cardinal;
    FRGBA: boolean;
    FBlueBits: Cardinal;}
    FContextCreated: boolean;
    FOnCreateContextEvent: IBEmptyEvent;
  public
    constructor Create(AWindowHandle: EGLNativeWindowType; AWindowDeviceContext: EGLNativeDisplayType);
    destructor Destroy; override;
    function CreateContext: boolean;
    function MakeCurrent: boolean;
    function Swap: boolean;
    procedure UnInitGLContext;
    {property RGBA: boolean read FRGBA write SetRGBA default true;
    property RedBits: Cardinal read FRedBits write SetRedBits default 8;
    property GreenBits: Cardinal read FGreenBits write SetGreenBits default 8;
    property BlueBits: Cardinal read FBlueBits write SetBlueBits default 8;
    property AlphaBits: Cardinal read FAlphaBits write SetAlphaBits default 8;
    property DepthBits: Cardinal read FDepthBits write SetDepthBits default 8;
    property StencilBits: Cardinal read FStencilBits write SetStencilBits default 8;}
    property ContextCreated: boolean read FContextCreated;
    property ContextIsLost: boolean read FContextIsLost;
    property OnCreateContextEvent: IBEmptyEvent read FOnCreateContextEvent;
  end;

  TContextAttributes = array of EGLint;

  { TSharedEglContext }

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
    class procedure OnContextLost;
  end;

implementation

uses
  	SysUtils
  ,	bs.config
	{$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  ;

procedure DeleteEglAttribute(AAttribute: GLInt; var AAttribs: TContextAttributes);
var
  i, j: int32;
  ind: int32;
begin
  for i := 0 to length(AAttribs) div 2 - 1 do
  begin
    if AAttribs[i shl 1] = AAttribute then
    begin
      {$ifdef DEBUG_BS}
      writeln('DeleteEglAttribute: ', AAttribute);
      {$endif}
      for j := i to length(AAttribs) div 2 - 2 do
      begin
        ind := i shl 1;
        AAttribs[ind] := AAttribs[ind + 2];
        AAttribs[ind+1] := AAttribs[ind + 3];
      end;
      break;
    end;
  end;
end;

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

  AddAttrib(EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT);
  AddAttrib(EGL_SURFACE_TYPE, EGL_WINDOW_BIT);
  //AddAttrib(EGL_SURFACE_TYPE, EGL_PBUFFER_BIT);

  if (Flags and ES_WINDOW_MULTISAMPLE) > 0 then
  begin
    AddAttrib(EGL_SAMPLE_BUFFERS, 1);
    AddAttrib(EGL_SAMPLES, BSConfig.MultiSamplingSamples);
  end;

  AddAttrib(EGL_NONE, EGL_NONE);
end;

{ TSharedEglContext }

class procedure TSharedEglContext.CreateSharedContext;
var
  numConfigs: EGLint;
  majorVersion: EGLint;
  minorVersion: EGLint;
  attribValue: EGLint;
  contextAttribs: array[0..4] of EGLint;
  attributes: TContextAttributes;
  i, j: int32;
begin

  if Assigned(FSharedContext) then
    exit;

  {$ifndef ultibo}
  if GLESLib = 0 then
    exit;

  SharedConfigSelected := nil;
  if not Assigned(eglGetDisplay) then
  begin
    InitEGL;
    if not Assigned(eglGetDisplay) then
      exit;
  end;
  {$endif}

  eglBindAPI(EGL_OPENGL_ES_API);

  FSharedDisplay := eglGetDisplay(EGL_DEFAULT_DISPLAY);

  if eglInitialize(FSharedDisplay, @majorVersion, @minorVersion) = 0 then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TSharedEglContext.CreateSharedContext', 'Could not to initialize egl');
    {$endif}
    exit;
  end;

  CreateEglAttributes(GetEglFlags(BSConfig.MultiSampling), SharedAttrib);

  attributes := nil;
  SetLength(attributes, length(SharedAttrib));
  move(SharedAttrib[0], attributes[0], SizeOf(EGLint)*length(SharedAttrib));

  numConfigs := 0;

  if (eglGetConfigs(FSharedDisplay, nil, 0, @numConfigs) = EGL_FALSE) or (numConfigs = 0) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TSharedEglContext.CreateSharedContext.eglGetConfigs', 'Could not to initialize egl');
    {$endif}
    exit;
  end;

  SetLength(SharedConfig, numConfigs);
  if (eglGetConfigs(FSharedDisplay, @SharedConfig[0], numConfigs, @numConfigs) = EGL_FALSE) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TSharedEglContext.CreateSharedContext.eglGetConfigs', 'Could not to initialize egl');
    {$endif}
    exit;
  end;

  SharedConfigSelected := SharedConfig[0];
  for i := 0 to numConfigs - 1 do
  begin
    j := 0;
    SharedConfigSelected := SharedConfig[i];
    while attributes[j] <> EGL_NONE do
    begin
       if eglGetConfigAttrib(FSharedDisplay, SharedConfigSelected, attributes[j], @attribValue) = EGL_FALSE then
       begin
        {$ifdef DEBUG_BS}
         BSWriteMsg('TSharedEglContext.CreateSharedContext', ' - eglGetConfigAttrib = EGL_FALSE, attribute: ' + IntToStr(attributes[j]));
        {$endif}
        DeleteEglAttribute(attributes[j], attributes);
        continue;
       end;
       inc(j, 2);
    end;

    if (attributes[0] = EGL_NONE) then
    begin
      SharedConfigSelected := nil;
      //move(SharedAttrib[0], attributes[0], SizeOf(EGLint)*length(SharedAttrib));
    end else
      break;
  end;

  if not Assigned(SharedConfigSelected) then
     exit;

  if (eglChooseConfig(FSharedDisplay, @attributes[0], @SharedConfigSelected, 1, @numConfigs) = EGL_FALSE) then
  begin
    if BSConfig.MultiSampling then
    begin
      {$ifdef DEBUG_BS}
      BSWriteMsg('TSharedEglContext.CreateSharedContext', 'trying to remove an option of multisampling');
      {$endif}
      DeleteEglAttribute(EGL_SAMPLES, attributes);
      DeleteEglAttribute(EGL_SAMPLE_BUFFERS, attributes);
      if (eglChooseConfig(FSharedDisplay, @attributes[0], @SharedConfigSelected, 1, @numConfigs) = EGL_FALSE) then
        exit;
      {$ifdef DEBUG_BS}
      BSWriteMsg('TSharedEglContext.CreateSharedContext', 'AFTER remove the multisampling option - SUCSESS');
      {$endif}
    end else
      exit;
  end;

  contextAttribs[0] := EGL_CONTEXT_CLIENT_VERSION;
  contextAttribs[1] := 2;
  contextAttribs[2] := EGL_NONE;
  FSharedContext := eglCreateContext(FSharedDisplay, SharedConfigSelected, EGL_NO_CONTEXT, @contextAttribs[0]);
  if FSharedContext = EGL_NO_CONTEXT then
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

  {$ifdef DEBUG_BS}
  BSWriteMsg('TSharedEglContext.CreateSharedContext', 'SUCSESS!!!');
  {$endif}
end;

class function TSharedEglContext.GetEglFlags(MultiSample: Boolean): int32;
begin
  Result := ES_WINDOW_RGB or ES_WINDOW_ALPHA or ES_WINDOW_DEPTH or ES_WINDOW_STENCIL;
  if MultiSample then
    Result := Result or ES_WINDOW_MULTISAMPLE;
end;

class procedure TSharedEglContext.OnContextLost;
begin
  eglMakeCurrent(FSharedDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  eglDestroySurface(FSharedDisplay, SharedSurface);
  eglDestroyContext(FSharedDisplay, FSharedContext);
  eglTerminate(FSharedDisplay);
  FillChar(FSharedDisplay, SizeOf(FSharedDisplay), 0);
  FillChar(FSharedContext, SizeOf(FSharedContext), 0);
  FillChar(SharedSurface, SizeOf(SharedSurface), 0);
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
  OnContextLost;
end;

{ TBlackSharkContext }

constructor TBlackSharkContext.Create(AWindowHandle: EGLNativeWindowType; AWindowDeviceContext: EGLNativeDisplayType);
begin
  inherited Create;
  {FRGBA := true;
  FRedBits := 8;
  FGreenBits := 8;
  FBlueBits := 8;
  FDepthBits := 8;
  FAlphaBits := 8;
  FStencilBits := 8;}
  FOnCreateContextEvent := CreateEmptyEvent;
  FWnd := AWindowHandle;
  FDC := AWindowDeviceContext;
end;

function TBlackSharkContext.CreateContext: boolean;
var
   contextAttribs: array[0..3] of EGLint;
begin

  if FContextCreated then
    exit(true);

  if not Assigned(TSharedEglContext.SharedContext) then
    exit(false);

  contextAttribs[0] := EGL_CONTEXT_CLIENT_VERSION;
  contextAttribs[1] := 2;
  contextAttribs[2] := EGL_NONE;
  contextAttribs[3] := EGL_NONE;

  // Create a surface
  eglSurface := eglCreateWindowSurface(TSharedEglContext.SharedDisplay, TSharedEglContext.SharedConfigSelected, FWnd, nil); // @TSharedEglContext.SharedAttrib[0]
  if (eglSurface = EGL_NO_SURFACE) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg(' TBlackSharkContext.CreateContext', 'eglCreateWindowSurface FAILED!!!');
    {$endif}
    exit(false);
  end;

  eglContext := eglCreateContext(TSharedEglContext.SharedDisplay, TSharedEglContext.SharedConfigSelected, TSharedEglContext.SharedContext, @contextAttribs[0] );

  if (eglContext = EGL_NO_CONTEXT) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TBlackSharkContext.CreateContext', 'eglContext FAILED!!!');
    {$endif}
    exit(false);
end;

  //eglSurfaceAttrib(TSharedEglContext.SharedDisplay, eglSurface, EGL_SWAP_BEHAVIOR, EGL_BUFFER_PRESERVED);

  // Make the context current
  if (eglMakeCurrent(TSharedEglContext.SharedDisplay, eglSurface, eglSurface, eglContext) = EGL_FALSE) then
begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('TBlackSharkContext.CreateContext', 'eglMakeCurrent FAILED!!!');
    {$endif}
    exit(false);
end;

  eglDisplay := TSharedEglContext.SharedDisplay;
  {$ifdef DEBUG_BS}
  BSWriteMsg('CreateEGLContext', 'SUCSESS!!!');
  {$endif}

  FContextCreated := true;

  Result := FContextCreated;
  FContextIsLost := false;

  if FContextCreated then
begin
    { send event about create context }
    FOnCreateContextEvent.Send(Self);
end;

end;

destructor TBlackSharkContext.Destroy;
begin
  UnInitGLContext;
  inherited;
end;

function TBlackSharkContext.MakeCurrent: boolean;
begin
  if not FContextCreated and not CreateContext then
    exit(false);
  Result := eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext) = EGL_TRUE;
end;

function TBlackSharkContext.Swap: boolean;
begin
  if Assigned(eglContext) then
begin
    if eglSwapBuffers(eglDisplay, eglSurface) = EGL_FALSE then
  begin
      Result := false;
      if eglGetError = EGL_CONTEXT_LOST then
        FContextIsLost := true;
    end else
      Result := true;
  end else
    Result := false;
end;

procedure TBlackSharkContext.UnInitGLContext;
begin
  FContextCreated := false;
  eglMakeCurrent(eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  if Assigned(eglContext) then
  begin
  	eglDestroySurface(eglDisplay, eglSurface);
  	eglDestroyContext(eglDisplay, eglContext);
    FillChar(eglDisplay, SizeOf(eglDisplay), 0);
    FillChar(eglSurface, SizeOf(eglSurface), 0);
    FillChar(eglContext, SizeOf(eglContext), 0);
  end;
end;

end.
