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

unit bs.gui.memo;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , bs.basetypes
  , bs.events
  , bs.scene
  , bs.collections
  , bs.geometry
  , bs.canvas
  , bs.doc.model
  , bs.doc.view
  , bs.gui.themes
  , bs.gui.base
  , bs.gui.scrollbox
  ;

type

  { TBlackSharkMemo }

  { Presents a data-class TBlackSharkDoc; contains an implementation a viewer
    data and controller for access user to him; that is the TBlackSharkMemo
    implements a MVC-template }

  TBlackSharkMemo = class(TBScrollBox)
  private
    //FAutoFit: boolean;
    FReadOnly: boolean;
    FDoc: TDocViewer;
    ObsrvKeyPress: IBKeyEventObserver;
    function GetText: string;
		procedure OnKeyPress(const Value: BKeyData);
    procedure SetText(const AValue: string);
    function GetCountLines: int32;
    procedure SetLine(index: int32; const Value: string);
    function GetLine(index: int32): string;
    //procedure SetAutoFit(const Value: boolean);
    procedure OnModify(CustomDoc: TBlackSharkCustomDoc);
  protected
    procedure DoAddVisualData(Data: TDocGraphicItem);
    procedure DoChangePos; override;
    procedure ReloadSpaceTree; override;
    procedure SetScrolledArea(const AValue: TVec2i64); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
   	procedure LoadProperties; override;
    procedure Clear; //override;
    procedure Resize(Width, Height: BSFloat); override;
    function AddText(const Text: string): TDocItemText; overload;
    function AddText(const Text: string; X, Y: int32): TDocItemText; overload;
    function AddRect(X, Y, Width, Height: BSFloat; Fill: boolean): TDocItemRectangle;
    property Text: string read GetText write SetText;
    property CountLines: int32 read GetCountLines;
    property Line[index: int32]: string read GetLine write SetLine;
    //property AutoFit: boolean read FAutoFit write SetAutoFit;
    property ReadOnly: boolean read FReadOnly write FReadOnly;
    property Doc: TDocViewer read FDoc;
  end;

implementation

uses
  bs.thread;

{ TBlackSharkMemo }

function TBlackSharkMemo.GetCountLines: int32;
begin
  Result := 0;
end;

function TBlackSharkMemo.GetLine(index: int32): string;
begin
	Result := '';
end;

function TBlackSharkMemo.GetText: string;
begin
  Result := '';
  //Result := FLines.Text;
end;

procedure TBlackSharkMemo.OnKeyPress(const Value: BKeyData);
begin
  if FReadOnly then
    exit;
end;

procedure TBlackSharkMemo.OnModify(CustomDoc: TBlackSharkCustomDoc);
begin
  CheckScrollingArea;
end;

procedure TBlackSharkMemo.ReloadSpaceTree;
type
  TSackNodes = TListVec<TItemDocTree.TListVirtualNodes>;
var
  item_list: TItemDocTree.TListVirtualNodes.PListItem;
  list: TItemDocTree.TListVirtualNodes;
  node: TItemDocTree.PVirtualTreeNode;
  data: TDocGraphicItem;
  base: TDocItem;
  n: PNodeSpaceTree;
  stack: TSackNodes;
begin
  inherited;
  stack := TSackNodes.Create;
  { reload to new the space tree data which exists in a document FDoc }
  stack.Add(FDoc.DocTree.RootNodes);
  while stack.Count > 0 do
  begin
    list := stack.Pop;
    item_list := list.ItemListFirst;
    while item_list <> nil do
    begin
      node := item_list.Item;
      if node.Childs <> nil then
        stack.Add(node.Childs);
      base := TDocItem(node.Data);
      item_list := item_list.Next;
      if base is TDocGraphicItem then
      begin
        data := TDocGraphicItem(base);
        DataAdd(Data, Data.Rect, n);
        Data.NodeInSpaceTree := n;
      end;
    end;
  end;
  stack.Free;
end;

procedure TBlackSharkMemo.Resize(Width, Height: BSFloat);
begin
  inherited;
end;

procedure TBlackSharkMemo.SetLine(index: int32; const Value: string);
begin

end;

procedure TBlackSharkMemo.SetScrolledArea(const AValue: TVec2i64);
begin
  inherited;
  FDoc.DocSize := vec2(AValue.x, AValue.y);
end;

procedure TBlackSharkMemo.SetText(const AValue: string);
begin
  Clear;
  AddText(AValue);
end;

function TBlackSharkMemo.AddRect(X, Y, Width, Height: BSFloat; Fill: boolean): TDocItemRectangle;
begin
  Result := FDoc.AddRect(X, Y, Width, Height, nil);
  DoAddVisualData(Result);
end;

function TBlackSharkMemo.AddText(const Text: string): TDocItemText;
begin
  Result := AddText(Text, 0, 0);
end;

function TBlackSharkMemo.AddText(const Text: string; X, Y: int32
  ): TDocItemText;
begin
  Result := FDoc.AddText(Text, X, Y, nil);
  //if FAutoFit then
  //  Result.TxtProcessor.SetOutRect(ClipObject.Width, 0);
  DoAddVisualData(Result);
end;

procedure TBlackSharkMemo.Clear;
begin
  if FDoc <> nil then
    FDoc.Clear;
  inherited;
end;

constructor TBlackSharkMemo.Create(ACanvas: TBCanvas);
begin
  inherited;
  FAutoResizeScrollingArea := true;
end;

procedure TBlackSharkMemo.LoadProperties;
begin
	inherited;
  if FDoc = nil then
  begin
    FDoc := TDocViewer.Create(SpaceTree, FCanvas, OwnerInstances);
    FDoc.OnModified := OnModify;
  end;
  ObsrvKeyPress := ClipObject.Data.EventKeyPress.CreateObserver(GUIThread, OnKeyPress);
  FDoc.DocSize := vec2(ScrolledArea.x, ScrolledArea.y);
end;

destructor TBlackSharkMemo.Destroy;
begin
  Clear;
  inherited;
  if FDoc <> nil then
    FDoc.Free;
end;

procedure TBlackSharkMemo.DoAddVisualData(Data: TDocGraphicItem);
var
  n: PNodeSpaceTree;
begin
  if Data.NodeInSpaceTree = nil then
  begin
    DataAdd(Data, Data.Rect, n);
    Data.NodeInSpaceTree := n;
  end;
end;

procedure TBlackSharkMemo.DoChangePos;
begin
  inherited DoChangePos;
  //FDoc
end;


initialization

end.

