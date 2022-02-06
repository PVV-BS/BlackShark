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


unit bs.gl.context;

{$I BlackSharkCfg.inc}

interface

uses
    bs.events
  , bs.gl.es
  , bs.gl.egl
  ;

type

  TBlackSharkContext = class;

  TAfterCreateContextEvent = procedure (Sender: TBlackSharkContext) of object;
  TMakeCurrentFunc = function (Context: Pointer): boolean;

  TBlackSharkContext = class
  private
    EGLWindow: PEGLWindow;
    GLContextES: PESContext;
    FGreenBits: Cardinal;
    FDepthBits: Cardinal;
    FRedBits: Cardinal;
    FAlphaBits: Cardinal;
    FStencilBits: Cardinal;
    FRGBA: boolean;
    FBlueBits: Cardinal;
    FContextCreated: boolean;
    FOnCreateContextEvent: IBEmptyEvent;
    FMultiSample: Boolean;
    procedure SetAlphaBits(const Value: Cardinal);
    procedure SetBlueBits(const Value: Cardinal);
    procedure SetDepthBits(const Value: Cardinal);
    procedure SetGreenBits(const Value: Cardinal);
    procedure SetRedBits(const Value: Cardinal);
    procedure SetRGBA(const Value: boolean);
    procedure SetStencilBits(const Value: Cardinal);
  public
    constructor Create(AWindowHandle: EGLNativeWindowType; AWindowDeviceContext: EGLNativeDisplayType);
    destructor Destroy; override;
    function CreateContext: boolean;
    function MakeCurrent: boolean;
    procedure Swap;
    procedure Render;
    procedure UnInitGLContext;
    property RGBA: boolean read FRGBA write SetRGBA default true;
    property RedBits: Cardinal read FRedBits write SetRedBits default 8;
    property GreenBits: Cardinal read FGreenBits write SetGreenBits default 8;
    property BlueBits: Cardinal read FBlueBits write SetBlueBits default 8;
    property AlphaBits: Cardinal read FAlphaBits write SetAlphaBits default 8;
    property DepthBits: Cardinal read FDepthBits write SetDepthBits default 8;
    property StencilBits: Cardinal read FStencilBits write SetStencilBits default 8;
    property MultiSample: Boolean read FMultiSample write FMultiSample;
    property ContextCreated: boolean read FContextCreated;
    property OnCreateContextEvent: IBEmptyEvent read FOnCreateContextEvent;
  end;


implementation

{ TBlackSharkContext }

constructor TBlackSharkContext.Create(AWindowHandle: EGLNativeWindowType; AWindowDeviceContext: EGLNativeDisplayType);
begin
  inherited Create;
  FRGBA := true;
  FRedBits := 8;
  FGreenBits := 8;
  FBlueBits := 8;
  FDepthBits := 8;
  FAlphaBits := 8;
  FStencilBits := 8;
  FOnCreateContextEvent := CreateEmptyEvent;
  EGLWindow := CreateWindowES(AWindowDeviceContext, AWindowHandle);
end;

function TBlackSharkContext.CreateContext: boolean;
begin

  if FContextCreated then
    exit(true);

  if not Assigned(TSharedEglContext.SharedContext) then
    exit(false);

  if Assigned(GLContextES) then
    FreeEGLContext(GLContextES, false);

  GLContextES := CreateEGLContext(EGLWindow);
  FContextCreated := Assigned(GLContextES);

  Result := FContextCreated;

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
  Result := bs.gl.egl.GLMakeCurrent(GLContextES);
end;

procedure TBlackSharkContext.Render;
begin
end;

procedure TBlackSharkContext.SetAlphaBits(const Value: Cardinal);
begin
  FAlphaBits := Value;
end;

procedure TBlackSharkContext.SetBlueBits(const Value: Cardinal);
begin
  FBlueBits := Value;
end;

procedure TBlackSharkContext.SetDepthBits(const Value: Cardinal);
begin
  FDepthBits := Value;
end;

procedure TBlackSharkContext.SetGreenBits(const Value: Cardinal);
begin
  FGreenBits := Value;
end;

procedure TBlackSharkContext.SetRedBits(const Value: Cardinal);
begin
  FRedBits := Value;
end;

procedure TBlackSharkContext.SetRGBA(const Value: boolean);
begin
  FRGBA := Value;
end;

procedure TBlackSharkContext.SetStencilBits(const Value: Cardinal);
begin
  FStencilBits := Value;
end;

procedure TBlackSharkContext.Swap;
begin
  if Assigned(GLContextES) then
  begin
    eglSwapBuffers(GLContextES^.eglDisplay, GLContextES^.eglSurface);
  end;
end;

procedure TBlackSharkContext.UnInitGLContext;
begin
  FContextCreated := false;
  if EGLWindow <> nil then
    FreeEGLWindow(EGLWindow);

  if Assigned(GLContextES) then
  begin
    GLContextES.eglWindow := nil;
    FreeEGLContext(GLContextES, false);
    EGLWindow := nil;
  end;
end;

end.
