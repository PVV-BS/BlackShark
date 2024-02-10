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


unit bs.utils;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  ;

type
  TTypeCheckError =
    (
      tcNone,
      tcShader,
      tcProgramm,
      tcFrameBuffer
    );

function CheckErrorGL(const Caption: string; TypeCheck: TTypeCheckError; ID: GLint): boolean;

function BufToHexA(buf: pByte; size: int32): AnsiString;
function BufToHexS(buf: pByte; size: int32): string;

function GetFileExistsPath(const FileName: string; const Preambule: string = ''): string;
function GetFilePath(const FileName: string; const Preambule: string = ''): string;
function GetRelativeFromFullPath(RootPath, FullPath: string): string;
function GetFullFromRelativePath(RootPath, RelatePath: string): string;

function GetApplicationPath: string;
procedure SetApplicationPath(const APath: string);

var
  AppPath: string;
  AppName: string = 'BlackShark';


implementation

uses
    bs.log
  , bs.strings
  ;

function GetRelativeFromFullPath(RootPath, FullPath: string): string;
var
  S: string;
  l: integer;
begin
  if Length(FullPath) > Length(RootPath) then
  begin
    S := AnsiUpperCase(FullPath);
    l := Length(RootPath);
    SetLength(S, l);
    if (S = AnsiUpperCase(RootPath)) then
      Result := '%app%' + Copy(FullPath, l + 1, Length(FullPath) - l)
    else
      Result := FullPath;
  end else
    Result := FullPath;
end;

function GetFullFromRelativePath(RootPath, RelatePath: string): string;
var
  LengthRelatePath: integer;
begin

  Result := '';
  LengthRelatePath := Length(RelatePath);

  if LengthRelatePath = 0 then
    exit;

  if RelatePath[1] = '%' then
  begin
    if LengthRelatePath < 7 then
      exit;
    Result := ExtractFilePath(RootPath) + PChar(@RelatePath[6]);   //
  end else
    Result := RelatePath;
end;

function GetFromShaderLogMessage(Shader: GLint): AnsiString;
var
  infoLen: GLuint;
begin
  infoLen := 0;
  glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, @infoLen );
  if ( infoLen > 1 ) then
  begin
    SetLength(Result, infoLen);
    glGetShaderInfoLog ( shader, infoLen, nil, @Result[1] );
  end else
    Result := '';
end;

function GetFromProgrammLogMessage(ProgrammID: GLint): AnsiString;
var
  infoLen: GLuint;
begin
  infoLen := 0;
  glGetProgramiv ( ProgrammID, GL_INFO_LOG_LENGTH, @infoLen );
  if ( infoLen > 1 ) then
  begin
    SetLength(Result, infoLen);
    glGetProgramInfoLog ( ProgrammID, infoLen, nil, @Result[1] );
  end else
    Result := '';
end;

function CheckErrorGL(const Caption: string; TypeCheck: TTypeCheckError; ID: GLint): boolean;
var
  err: GLenum;
  msE: string;
begin
  err := glGetError();
  if (err <> GL_NO_ERROR) then
  begin
    Result := true;
    msE := '';
    if ID >= 0 then
    case TypeCheck of
      tcShader: msE := AnsiToString(GetFromShaderLogMessage(ID));
      tcProgramm: msE := AnsiToString(GetFromProgrammLogMessage(ID));
      tcFrameBuffer: msE := AnsiToString(GetFromProgrammLogMessage(ID));//msE := AnsiToString()
        //err := glCheckFramebufferStatus(ID);
    end;

    if msE = '' then
    begin
      case err of
        GL_INVALID_ENUM: BSWriteMsg(Caption, 'INVALID_ENUM');
        GL_INVALID_VALUE: BSWriteMsg(Caption, 'INVALID_VALUE');
        GL_INVALID_OPERATION: BSWriteMsg(Caption, 'INVALID_OPERATION');
        GL_OUT_OF_MEMORY: BSWriteMsg(Caption, 'OUT_OF_MEMORY');
        GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: BSWriteMsg(Caption, 'Framebuffer Incomplete Attachment');
        GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: BSWriteMsg(Caption, 'Framebuffer Incomplete Missing Attachment');
        GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: BSWriteMsg(Caption, 'Framebuffer Incomplete Dimensions');
        GL_FRAMEBUFFER_UNSUPPORTED: BSWriteMsg(Caption, 'Framebuffer Unsupported');
        GL_INVALID_FRAMEBUFFER_OPERATION: BSWriteMsg(Caption, 'Invalid Framebuffer Operation');
        GL_FRAMEBUFFER_COMPLETE: ;
        else
          BSWriteMsg('Uncknown error with code: ', IntToHex(err, 8));
      end;
    end else
      BSWriteMsg(Caption, msE);
  end else
    Result := false;
end;

function GetApplicationPath: string;
begin
  {$ifdef FPC}
  Result := ExtractFilePath(ParamStr(0));
  {$else}
  Result := ExtractFilePath(GetModuleName(0));
  {$endif}
end;

procedure SetApplicationPath(const APath: string);
begin
  AppPath := APath;
  {$ifdef DEBUG_BS}
  BSWriteMsg('SetApplicationPath:', AppPath);
  {$endif}
end;

function BufToHexA(buf: pByte; size: int32): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to size - 1 do
    Result := Result + StringToAnsi(IntToHex(buf[i], 2)) + ' ';
end;

function BufToHexS(buf: pByte; size: int32): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to size - 1 do
    Result := Result + IntToHex(buf[i], 2) + ' ';
end;

function GetFileExistsPath(const FileName: string; const Preambule: string): string;
begin
  if FileExists(FileName) then
    exit(FileName);
  Result := AppPath + FileName;
  if FileExists(Result) then
    exit;
  Result := AppPath + IncludeTrailingPathDelimiter(Preambule) + FileName;
  if FileExists(Result) then
    exit;
  Result := '';
end;

function GetFilePath(const FileName: string; const Preambule: string): string;
var
  tmp_str: string;
begin
  {$IFDEF MSWINDOWS}
    tmp_str := StringReplace(FileName, '/', '\', [rfReplaceAll]);
  {$ELSE}
    {$IFDEF ultibo}
      tmp_str := StringReplace(FileName, '/', '\', [rfReplaceAll]);
    {$ELSE}
      tmp_str := StringReplace(FileName, '\', '/', [rfReplaceAll]);
    {$ENDIF}
  {$ENDIF}

  if FileExists(tmp_str) or (tmp_str[2] = ':') or (tmp_str[2] = '/') or (tmp_str[2] = '\') or (tmp_str[1] = '/') then // contain full path ?
  begin
    Result := tmp_str;
  end else
  begin
    Result := IncludeTrailingPathDelimiter(AppPath + Preambule)  + tmp_str;
  end;
end;

initialization
  {$ifdef FPC}
    AppPath := ExtractFilePath(ParamStr(0));
    AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  {$else}
    AppPath := ExtractFilePath(GetModuleName(0));
    AppName := ChangeFileExt(ExtractFileName(GetModuleName(0)), '');
  {$endif}

end.

