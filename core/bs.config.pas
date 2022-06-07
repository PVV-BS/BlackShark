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

unit bs.config;

{$I BlackSharkCfg.inc}

interface

uses
    bs.collections
  ;

const
  FILE_PROPERTIES_DEFAULT = 'app.properties';

type

  { BSConfig }

  BSConfig = class
  private
    class var FResolutionWidth: int32;
    class var FResolutionHeight: int32;
    class var FMaxFps: boolean;
    class procedure CalculateVoxelSize;
    class procedure SetMaxFps(AValue: boolean); static;
    class procedure SetResolutionHeight(const Value: int32); static;
    class procedure SetResolutionWidth(const Value: int32); static;
    class function GetFileProperties: string;
    class procedure UpdateCommonAttributes;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Save;
    class procedure Load;
    class property ResolutionWidth: int32 read FResolutionWidth write SetResolutionWidth;
    class property ResolutionHeight: int32 read FResolutionHeight write SetResolutionHeight;
    class var VoxelSize: single;
    class var VoxelSizeInv: single;
    class var MultiSampling: boolean;
    class var MultiSamplingSamples: int32;
    class var VerticalSynchronization: boolean;
    { for save all debug messages to need define DEBUG_BS in BlackSharkCfg.inc }
    class var WriteLog: boolean;
    { switch off if only state of your scene depends on input devices events (keyboard, mouse...) }
    class property MaxFps: boolean read FMaxFps write SetMaxFps;
    { it allows contain pool of threads for execute any task of TTemplateBTask<T>;
      otherwise all tasks accomplish in gui thread; for to get an executer your any task you
      can use method bs.thread.NextExecutor; how use it see an example bs.test.gui.TBSTestSimpleAnimation }
    class var UseTaskExecutersSet: boolean;
    { custom properties; you can add here your any custom properties for your application }
    class var Properties: THashTable<string, string>;
    class function GetProperty(const AName: string; ADefault: int32): int32; overload;
    class function GetProperty(const AName: string; ADefault: string): string; overload;
    class function GetProperty(const AName: string; ADefault: boolean): boolean; overload;
    class function GetProperty(const AName: string; ADefault: uint32): uint32; overload;
  end;

implementation

uses
    IniFiles
  , Classes
  , SysUtils
  {$ifdef DEBUG_BS}
  , bs.log
  {$endif}
  , bs.utils
  ;

{ BSConfig }

class procedure BSConfig.CalculateVoxelSize;
begin
  VoxelSize := 2.0 / (FResolutionWidth + FResolutionHeight);
  VoxelSizeInv := 1 / VoxelSize;
end;

class procedure BSConfig.SetMaxFps(AValue: boolean);
begin
  if FMaxFps = AValue then
    exit;

  FMaxFps := AValue;

  Properties.TryAddOrReplace('MaxFps', BoolToStr(FMaxFps));
end;

class constructor BSConfig.Create;
begin
  FResolutionWidth := 600;
  FResolutionHeight := 600;
  WriteLog := {$ifdef DEBUG_BS} true {$else} false {$endif};
  Properties := THashTable<string, string>.Create(GetHashBlackSharkS, StrCmpBool);
  MultiSampling := true;
  MultiSamplingSamples := 4;
  VerticalSynchronization := true;
  FMaxFps := false;
  UseTaskExecutersSet := false;
  CalculateVoxelSize;
  UpdateCommonAttributes;
end;

class destructor BSConfig.Destroy;
begin
  Save;
  Properties.Free;
end;

class function BSConfig.GetFileProperties: string;
begin
  if AppName = '' then
    Result := AppPath + FILE_PROPERTIES_DEFAULT
  else
    Result := AppPath + AppName + '.properties';
end;

class procedure BSConfig.UpdateCommonAttributes;
begin
  Properties.TryAddOrReplace('MaxFps', BoolToStr(MaxFps));
  Properties.TryAddOrReplace('ResolutionWidth', IntToStr(FResolutionWidth));
  Properties.TryAddOrReplace('ResolutionHeight', IntToStr(FResolutionHeight));
  Properties.TryAddOrReplace('MultiSampling', BoolToStr(MultiSampling));
  Properties.TryAddOrReplace('MultiSamplingSamples', IntToStr(MultiSamplingSamples));
  Properties.TryAddOrReplace('UseTaskExecutersSet', BoolToStr(UseTaskExecutersSet));
  Properties.TryAddOrReplace('VerticalSynchronization', BoolToStr(VerticalSynchronization));
  Properties.TryAddOrReplace('WriteLog', BoolToStr(WriteLog));
end;

class procedure BSConfig.Load;
var
  ini: TIniFile;
  slCustom: TStringList;
  s: string;
  keyVal: TArray<string>;
  fn: string;
begin
  fn := GetFileProperties;

  {$ifdef DEBUG_BS}
  BSWriteMsg('BSConfig.Load', 'Trying to load the application file properties... "' + fn + '"');
  {$endif}

  if not FileExists(fn) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('BSConfig.Load', 'The applicatoin file properties does not found');
    {$endif}
    UpdateCommonAttributes;
    exit;
  end;

  ini := TIniFile.Create(fn);

  {$ifdef FPC}
  ini.BoolTrueStrings := ['-1'];
  ini.BoolFalseStrings := ['0'];
  {$endif}

  FResolutionWidth := ini.ReadInteger('app', 'ResolutionWidth', FResolutionWidth);
  FResolutionHeight := ini.ReadInteger('app', 'ResolutionHeight', FResolutionHeight);
  MultiSampling := ini.ReadBool('app', 'MultiSampling', MultiSampling);
  MultiSamplingSamples := ini.ReadInteger('app', 'MultiSamplingSamples', MultiSamplingSamples);
  UseTaskExecutersSet := ini.ReadBool('app', 'UseTaskExecutersSet', UseTaskExecutersSet);
  MaxFps := ini.ReadBool('app', 'MaxFps', FMaxFps);
  VerticalSynchronization := ini.ReadBool('app', 'VerticalSynchronization', VerticalSynchronization);
  WriteLog := ini.ReadBool('app', 'WriteLog', WriteLog);

  {$ifdef DEBUG_BS}
  BSWriteMsg('BSConfig.Load', 'MaxFps = ' + BoolToStr(MaxFps, true));
  BSWriteMsg('BSConfig.Load', 'ResolutionWidth = ' + IntToStr(ResolutionWidth));
  BSWriteMsg('BSConfig.Load', 'ResolutionHeight = ' + IntToStr(ResolutionHeight));
  BSWriteMsg('BSConfig.Load', 'MultiSampling = ' + BoolToStr(MultiSampling, true));
  BSWriteMsg('BSConfig.Load', 'MultiSamplingSamples = ' + IntToStr(MultiSamplingSamples));
  BSWriteMsg('BSConfig.Load', 'UseTaskExecutersSet = ' + BoolToStr(UseTaskExecutersSet, true));
  BSWriteMsg('BSConfig.Load', 'VerticalSynchronization = ' + BoolToStr(VerticalSynchronization, true));
  {$endif}

  slCustom := TStringList.Create;
  ini.ReadSection('app', slCustom);

  for s in slCustom do
  begin
    keyVal := s.Split(['=']);
    if length(keyVal) = 2 then
      {%H-}Properties.TryAddOrReplace(keyVal[0], keyVal[1]);
  end;

  slCustom.Free;
  ini.Free;
  CalculateVoxelSize;
end;

class function BSConfig.GetProperty(const AName: string; ADefault: int32): int32;
var
  value: string;
begin
  if Properties.Find(AName, value) then
    Result := StrToInt(value)
  else
    Result := ADefault;
end;

class function BSConfig.GetProperty(const AName: string; ADefault: string): string;
begin
  if not Properties.Find(AName, Result) then
    Result := ADefault;
end;

class function BSConfig.GetProperty(const AName: string; ADefault: boolean): boolean;
var
  value: string;
begin
  if Properties.Find(AName, value) then
    Result := StrToBool(value)
  else
    Result := ADefault;
end;

class function BSConfig.GetProperty(const AName: string; ADefault: uint32): uint32;
var
  value: string;
begin
  if Properties.Find(AName, value) then
    Result := StrToInt(value)
  else
    Result := ADefault;
end;

class procedure BSConfig.Save;
var
  ini: TIniFile;
  bucket: THashTable<string, string>.TBucket;
begin
  ini := TIniFile.Create(GetFileProperties);
  {ini.WriteInteger('app', 'ResolutionWidth', FResolutionWidth);
  ini.WriteInteger('app', 'ResolutionHeigth', FResolutionHeight);
  ini.WriteBool('app', 'MultiSampling', MultiSampling);
  ini.WriteInteger('app', 'MultiSamplingSamples', MultiSamplingSamples);
  ini.WriteBool('app', 'UseTaskExecutersSet', UseTaskExecutersSet);
  ini.WriteBool('app', 'MaxFps', MaxFps);
  ini.WriteBool('app', 'VerticalSynchronization', VerticalSynchronization); }
  {$ifdef FPC}
  ini.BoolTrueStrings := ['-1'];
  ini.BoolFalseStrings := ['0'];
  {$endif}

  // custom properties
  if Properties.GetFirst(bucket) then
  repeat
    ini.WriteString('app', bucket.key, bucket.value);
  until not Properties.GetNext(bucket);

  ini.Free;

end;

class procedure BSConfig.SetResolutionHeight(const Value: int32);
begin
  FResolutionHeight := Value;
  CalculateVoxelSize;
end;

class procedure BSConfig.SetResolutionWidth(const Value: int32);
begin
  FResolutionWidth := Value;
  CalculateVoxelSize;
end;

end.
