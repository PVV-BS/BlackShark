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

type
  TLogEventNotify = procedure (Source: string; Msg: string);

var
  // if true - begin new log evry time after run
  g_RewriteLog: boolean = false;
  LogEventNotify: TLogEventNotify = nil;

implementation

uses
    Classes
  , bs.strings
  , bs.collections
  , bs.utils
  , SysUtils
  ;

var
  g_WriteToLog: boolean = {$ifdef DEBUG_BS} true {$else} false {$endif};
  Log: TFileStream = nil;
  UnicMsg: TBinTree<Pointer>;

procedure InitLog;
begin
  if not g_WriteToLog then
    exit;

  SetCurrentDir(GetApplicationPath);
  if g_RewriteLog or not FileExists('BlackSharkLog.txt') then
    Log := TFileStream.Create('BlackSharkLog.txt', fmCreate)
  else
    Log := TFileStream.Create('BlackSharkLog.txt', fmOpenWrite);
  UnicMsg := TBinTree<Pointer>.Create;
end;

procedure WriteToLog(Data: pByte; Len: int32);
begin
  if not g_WriteToLog then
    exit;
  Log.WriteBuffer(Data^, Len);
end;

function CheckUnic(Msg: pByte; Len: int32): boolean;
var
  v: Pointer;
begin
  if UnicMsg.Find(Msg, Len, v) then
    exit(false)
  else
    UnicMsg.Add(Msg, Len, Pointer($FFFFFFFF));
  Result := true;
end;

procedure BSWriteMsg(const Source: string; const Msg: string; Unical: boolean = false);
var
  add_m: AnsiString;
begin
  if not (g_WriteToLog) or Unical and not CheckUnic(@Msg[1], Length(Msg)) then
    exit;
  if Assigned(LogEventNotify) then
    LogEventNotify(Source, Msg);
  add_m := StringToAnsi((FormatDateTime('dd.MM.yy hh:mm:ss', now)) + #$09 + Source + #$09 + Msg + #$0d+#$0a);
  WriteToLog(@(add_m)[1], length(add_m));
end;

procedure BSWriteMsg(const Source: string; Msg: int32; Unical: boolean = false);
begin
  BSWriteMsg(Source, IntToStr(Msg), Unical);
end;


initialization
  {$ifdef DEBUG}
    InitLog();
  {$endif}

finalization
  if Assigned(Log) then
  begin
    Log.Free;
    UnicMsg.Free;
  end;
end.

