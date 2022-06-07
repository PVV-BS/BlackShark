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

unit bs.lang.dictionary;

{$I BlackSharkCfg.inc}

interface

// return translate in current language
function GetSentence(const NameSentence: string): string;

// you can add own dictionaries by AddToExisting = true
function LoadLang(const NameDictionary: string; AddToExisting: boolean = true): boolean;

implementation

uses
    XmlWriter
  , bs.collections
  , bs.utils
  , bs.strings
  ;

var
  g_DictSpell: THashTable<string, string>;

function GetSentence(const NameSentence: string): string;
begin
  if not g_DictSpell.Find(NameSentence, Result) then
    Result := NameSentence;
end;

function LoadLang(const NameDictionary: string; AddToExisting: boolean = true): boolean;
var
  xml: TheXmlWriter;
  node: TheXmlNode;
  ch: TheXmlNode;
  path: string;
  translate: string;
  i: int32;
begin
  if not AddToExisting then
    g_DictSpell.Clear;
  path := GetFilePath(NameDictionary, 'Lang');
  xml := TheXmlWriter.Create(path, true);
  try
    node := xml.FindNode('Sentences', true);
    if not Assigned(node) then
      exit(false);
    for i := 0 to node.CountChilds - 1 do
    begin
      ch := node.Childs[i];
      translate := WideToString(ch.GetAttribute(WideString('t'), WideString('')));
      if translate <> '' then
        g_DictSpell.TryAdd(WideToString(ch.Name), translate);
    end;
  finally
    xml.Free;
  end;

  Result := true;
end;

initialization

  g_DictSpell := THashTable<string, string>.Create(@GetHashBlackSharkS, @StrCmpBool);
  LoadLang('lang.en');

finalization
  g_DictSpell.Free;

end.
