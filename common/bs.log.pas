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


unit bs.log;

{$I BlackSharkCfg.inc}

interface

procedure BSWriteMsg(const Source: string; const Msg: string; Unical: boolean = false); overload;
procedure BSWriteMsg(const Source: string; Msg: int32; Unical: boolean = false); overload;
procedure BSWriteMsg(const Source: string; Unical: boolean = false); overload;

type
  TLogEventNotify = procedure (Source: string; Msg: string);

const
    MESSAGE_INFO  = 0;
    MESSAGE_WARN  = 1;
    MESSAGE_ERROR = 2;

var
  // if true - begin new log every time after run
  g_RewriteLog: boolean = false;
  LogEventNotify: TLogEventNotify = nil;

implementation

uses
    Classes
  , SysUtils
  , bs.strings
  , bs.collections
  , bs.utils
  , bs.config
  ;

var
  Log: TFileStream = nil;
  UnicMsg: THashTable<string, int32>;

procedure InitLog;
begin

  {$ifndef DBG_IO}
  SetCurrentDir(GetApplicationPath);
  if g_RewriteLog or not FileExists('BlackSharkLog.txt') then
    Log := TFileStream.Create('BlackSharkLog.txt', fmCreate)
  else
    Log := TFileStream.Create('BlackSharkLog.txt', fmOpenWrite);
  {$endif}

  UnicMsg := THashTable<string, int32>.Create(@GetHashBlackSharkS, @StrCmpBool);
end;

procedure WriteToLog(Data: pByte; Len: int32);
begin
  if not BSConfig.WriteLog then
    exit;
  Log.WriteBuffer(Data^, Len);
end;

function CheckUnic(const Msg: string): boolean;
begin
  Result := UnicMsg.TryAdd(Msg, 0);
end;

procedure BSWriteMsg(const Source: string; const Msg: string; Unical: boolean = false);
{$ifndef DBG_IO}
var
  add_m: AnsiString;
{$endif}
begin
  if not BSConfig.WriteLog then
    exit;

  if not Assigned(Log) then
    InitLog;

  if (Unical and not CheckUnic(Msg)) then
    exit;

  if Assigned(LogEventNotify) then
    LogEventNotify(Source, Msg);
  {$ifdef DBG_IO}
  writeln(Source, ' ', Msg);
  {$else}
  add_m := StringToAnsi((FormatDateTime('dd.MM.yy hh:mm:ss', now)) + #$09 + Source + #$09 + Msg + #$0d+#$0a);
  WriteToLog(@(add_m)[1], length(add_m));
  {$endif}
end;

procedure BSWriteMsg(const Source: string; Msg: int32; Unical: boolean = false);
begin
  case Msg of
      MESSAGE_INFO: BSWriteMsg(Source, 'Info', Unical);
      MESSAGE_WARN: BSWriteMsg(Source, 'Warr', Unical);
      MESSAGE_ERROR: BSWriteMsg(Source, 'Error', Unical)
    else
      BSWriteMsg(Source, IntToStr(Msg), Unical);
  end;
end;

procedure BSWriteMsg(const Source: string; Unical: boolean);
begin
  BSWriteMsg(Source, 'Info', Unical);
end;


initialization


finalization
    Log.Free;
    UnicMsg.Free;

end.

