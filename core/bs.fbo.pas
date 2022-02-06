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


{
  Contains Frame Buffer Object (FBO) of an implementation (TBlackSharkFBO).
  A FBO is a temporary storage for result rendering pass.
}

unit bs.fbo;

{$I BlackSharkCfg.inc}

interface

uses
    bs.gl.es
  ;

type

  TAttachmentFBO = (atColor, atDepth, atStencil);
  TAttachmentsFBO = set of TAttachmentFBO;

  { TBlackSharkFBO }

  TBlackSharkFBO = class
  private
    FID: GLint;
    RenderBufferID: GLint;
    FTexture: GLint;
    FDepthSten: GLint;
    FWidth: int32;
    FHeight: int32;
    FAttachments: TAttachmentsFBO;
    FUsers: int8;
    FFormat: int32;
    procedure Clear;
    procedure SetAttachments(const Value: TAttachmentsFBO);
  public
    constructor Create(AWidth, AHeight: int32; AAttachments: TAttachmentsFBO = [atColor, atDepth];
      AFormat: int32 = GL_RGBA);
    procedure ReCreate(AWidth, AHeight: int32; AAttachments: TAttachmentsFBO = [atColor, atDepth];
      AFormat: int32 = GL_RGBA);
    destructor Destroy; override;
    procedure Bind;
    procedure Unbind;
    function IncUsers: int32;
    { if count users stated to zero then class will released }
    function DecUsers: int32;
    property Texture: GLint read FTexture;
    property Width: int32 read FWidth;
    property Height: int32 read FHeight;
    property Attachments: TAttachmentsFBO read FAttachments write SetAttachments;
    property Users: int8 read FUsers;
    property Format: int32 read FFormat;
    property ID: GLint read FID;
  end;

implementation

  uses
      bs.utils
    , SysUtils
    ;

{ TBlackSharkFBO }

procedure TBlackSharkFBO.Clear;
begin

  if (FTexture >= 0) then
  begin
	  glDeleteTextures(1, @FTexture);
    FTexture := -1;
  end;

  if FDepthSten >= 0 then
  begin
    glDeleteTextures(1, @FDepthSten);
    FDepthSten := -1;
  end;

  if (RenderBufferID >= 0) then
  begin
    glDeleteRenderbuffers(1, @RenderBufferID);
    RenderBufferID := -1;
  end;

  if (ID >= 0) then
  begin
	  glDeleteFramebuffers(1, @FID);
    FID := -1;
  end;

end;

constructor TBlackSharkFBO.Create(AWidth, AHeight: int32;
  AAttachments: TAttachmentsFBO; AFormat: int32);
begin
  FTexture := -1;
  RenderBufferID := -1;
  FID := -1;
  FDepthSten := -1;
  FFormat := AFormat;
  ReCreate(AWidth, AHeight, AAttachments, AFormat);
end;

function TBlackSharkFBO.DecUsers: int32;
begin
  dec(FUsers);
  if FUsers < 0 then
    FUsers := 0;
  Result := FUsers;
  if FUsers = 0 then
    Free;
end;

destructor TBlackSharkFBO.Destroy;
begin
  Clear;
  inherited;
end;

function TBlackSharkFBO.IncUsers: int32;
begin
  inc(FUsers);
  Result := FUsers;
end;

procedure TBlackSharkFBO.ReCreate(AWidth, AHeight: int32;
  AAttachments: TAttachmentsFBO; AFormat: int32);
var
  err: int32;
begin
  Clear;
  FAttachments := AAttachments; // [atColor];
  FWidth := AWidth;
  FHeight := AHeight;
  {FWidth := trunc(power(trunc(sqrt(AWidth)), 2.0));
  if FWidth < AWidth then
    FWidth := trunc(power(trunc(sqrt(AWidth)) + 1, 2.0));
  FHeight := trunc(power(trunc(sqrt(AHeight)), 2.0));
  if FHeight < AHeight then
    FHeight := trunc(power(trunc(sqrt(AHeight)) + 1, 2.0));}
  FFormat := AFormat;
  // create a framebuffer
  glGenFramebuffers(1, @FID);
  FTexture := -1;
  RenderBufferID := -1;
  if (FAttachments <> []) then
  begin
    // bind the framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, FID);
    // create render buffer
    glGenRenderbuffers(1, @RenderBufferID);
    // bind render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, RenderBufferID);
    if (atDepth in FAttachments) then
    begin
      if (atStencil in FAttachments) then
      begin
        { generate texture for stencil and depth attachments }
        glGenTextures(1, @FDepthSten);
        // Setup depth_stencil texture (not mipmap)
        glBindTexture(GL_TEXTURE_2D, FDepthSten);
        // Set the filtering mode
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_STENCIL_OES, FWidth,  FHeight, 0,
          GL_DEPTH_STENCIL_OES, GL_UNSIGNED_INT_24_8_OES, nil);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_TEXTURE_2D, FDepthSten, 0);
        // specify depth_renderbufer as depth attachment
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, FDepthSten, 0);
      end else
      begin
        glRenderbufferStorage (GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, FWidth, FHeight);
        // specify depth_renderbufer as depth attachment
        glFramebufferRenderbuffer (GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, RenderBufferID);
      end;
      //glRenderbufferStorage (GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, AWidth, AHeight);
      //glFramebufferRenderbuffer (GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, RenderBufferID);
    end else
    if (atStencil in FAttachments) then
    begin
      glRenderbufferStorage (GL_RENDERBUFFER, GL_STENCIL_INDEX8, FWidth, FHeight);
      // specify depth_renderbufer as depth attachment
      glFramebufferRenderbuffer (GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, RenderBufferID);
    end;

    if (atColor in FAttachments) then
    begin
      //glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, AWidth, AHeight);
      glGenTextures(1, @FTexture);
      glBindTexture(GL_TEXTURE_2D, FTexture);
      glTexImage2D ( GL_TEXTURE_2D, 0, FFormat, FWidth, FHeight, 0, FFormat, GL_UNSIGNED_BYTE, nil );  //  GL_FLOAT
      //glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST );
      //glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST );
      glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR );
      glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_LINEAR );

      // set perametr wrap texture - absent wrap
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
      // ... nice trilinear filtering.
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

      // specify texture as color attachment
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, FTexture, 0);
    end;
  end;
  err := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  case err of
    GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: raise Exception.Create('Can not create FBO: GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT');
    GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: raise Exception.Create('Can not create FBO: GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS');
    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: raise Exception.Create('Can not create FBO: GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT');
    GL_FRAMEBUFFER_UNSUPPORTED: raise Exception.Create('Can not create FBO: GL_FRAMEBUFFER_UNSUPPORTED');
    GL_FRAMEBUFFER_COMPLETE:  else
      raise Exception.Create('Can not create FBO, an unknown error occurred: $' + IntToHex(err, 4));
  end;
  {$ifdef DEBUG_BS}
  CheckErrorGL('TBlackSharkFBO.ReCreate', TTypeCheckError.tcFrameBuffer,  ID);
  {$endif}
end;

procedure TBlackSharkFBO.SetAttachments(const Value: TAttachmentsFBO);
begin
  ReCreate(FWidth, FHeight, Value, FFormat);
end;

procedure TBlackSharkFBO.Bind;
begin
  glBindFramebuffer(GL_FRAMEBUFFER, ID);
  glViewport(0, 0, FWidth, FHeight);
end;

procedure TBlackSharkFBO.Unbind;
begin
  glBindFramebuffer (GL_FRAMEBUFFER, 0);
end;

end.
