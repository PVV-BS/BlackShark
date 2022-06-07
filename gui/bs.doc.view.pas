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

unit bs.doc.view;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , bs.basetypes
  , bs.events
  , bs.doc.model
  , bs.strings
  , bs.texture
  , bs.geometry
  , bs.canvas
  , bs.textprocessor
  , bs.scene.objects
  , bs.font
  ;


type

  { TDocItemRectangle }

  TDocItemRectangle = class(TDocGraphicItem)
  private
    FBorderWidth: BSFloat;
  protected
    procedure Build; override;
  public
    function Show(const ViewPort: TRectBSf): Pointer; override;
    procedure Hide; override;
    procedure UpdatePosition(const ViewPort: TRectBSf); override;
    property BorderWidth: BSFloat read FBorderWidth write FBorderWidth;
  end;

  { TCustomTextStyle }

  TCustomTextStyle = class(TDocItem)
  private
    procedure SetFont(const Value: IBlackSharkFont);
  protected
    FFont: IBlackSharkFont;
  public
    destructor Destroy; override;
    property Font: IBlackSharkFont read FFont write SetFont;
  end;

  TTextStyleDefault = class (TCustomTextStyle)
  private
  public
    constructor Create(ADoc: TBlackSharkCustomDoc; Parent: TDocItem); override;
    destructor Destroy; override;
    procedure UpdatePosition(const {%H-}ViewPort: TRectBSf); override;
    //function SelectKey(Index: int32; const CurentPos: TVec2f): PKeyInfo; override;
  end;

  { TDocItemText }

  TDocItemText = class(TDocGraphicItem)
  private
    FDiscardBlanks: boolean;
    FTextObject: TCanvasText;
    FText: TString;
    FTxtProcessor: TTextProcessor;
    FStyle: TCustomTextStyle;
    HitAll: boolean;
    function SelectorKey(Index: int32; out Code: int32): PKeyInfo;
    function SelectorAverageWidth(Index: int32): BSFloat;
    function GetText: string;
    procedure SetText(const Value: string);
    procedure SetDiscardBlanks(const Value: boolean);
    {procedure SelectPositionY(const ViewPortPositionVert: BSFloat); inline;
    function SelectPositionX(Renderer: TTextManager; LineProp: PLineProp; ViewPortPositionHor,
      ViewPortWidth: BSFloat): boolean; // inline;   }
    procedure ShowRect(const R: TRectBSf; Force: boolean);
    procedure CheckStyle;
  protected
    procedure Build; override;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc; Parent: TDocItem); override;
    destructor Destroy; override;
    function Show(const ViewPort: TRectBSf): Pointer; override;
    procedure Hide; override;
    procedure UpdatePosition(const ViewPort: TRectBSf); override;
    property Text: string read GetText write SetText;
    property DiscardBlanks: boolean read FDiscardBlanks write SetDiscardBlanks;
    property TxtProcessor: TTextProcessor read FTxtProcessor;
  end;

  TDocItemPicture = class;

  { TDocItemPicture }

  TDocItemPicture = class(TDocGraphicItem)
  protected
    FFileName: string;
    FArea: PTextureArea;
    procedure SetArea(AValue: PTextureArea); virtual;
    procedure SetFileName(const AValue: string); virtual;
    //procedure OpenPicture; virtual;
  public
    //constructor Create(AResManager: TBSCustomResManager; ANode: TProjectTreeNode); override;
    destructor Destroy; override;
    function Show(const ViewPort: TRectBSf): Pointer; override;
    procedure Hide; override;
    procedure Load(const FromStream: TStream; const SizeData: int32); override;
    procedure Save(const ToStream: TStream); override;
    property Area: PTextureArea read FArea write SetArea;
    property FileName: string read FFileName write SetFileName;
  end;

  { TDocViewer }

  TDocViewer = class (TBlackSharkCustomDoc)
  strict private
    CacheRectangles: TListVecCanvasObjects;
    FTextStyleDefault: TTextStyleDefault;
    ObsrvDropRect: IBDragDropEventObserver;
    SelfDocOwner: boolean;
  private
    function GetTextStyleDefault: TTextStyleDefault;
  protected
    FCanvas: TBCanvas;
    FDocOwner: TCanvasObject;
    procedure OnDropRectangle(const Value: BDragDropData);
    function GetRectangle(const Size: TVec2f; const Position: TVec2f): TRectangle;
    procedure FreeRectangle(Rectangle: TRectangle);
    procedure SetDocSize(const Value: TVec2f); override;
  public
    constructor Create(ASpaceTree: TBlackSharkSpaceTree; ACanvas: TBCanvas; ADocOwner: TCanvasObject);
    destructor Destroy; override;
    function AddText(const Text: string; Owner: TDocItem = nil): TDocItemText; overload;
    function AddText(const Text: string; X, Y: BSFloat; Owner: TDocItem = nil): TDocItemText; overload;
    function AddRect(X: BSFloat; Y: BSFloat; Width: BSFloat; Height: BSFloat; Owner: TDocItem = nil): TDocItemRectangle; overload;
    function AddRect(const Rect: TRectBSf; Owner: TDocItem = nil): TDocItemRectangle; overload;
    //procedure UpdateInSpaceTree(Item: TDocGraphicItem); override;
    property Canvas: TBCanvas read FCanvas;
    property DocOwner: TCanvasObject read FDocOwner;
    property TextStyleDefault: TTextStyleDefault read GetTextStyleDefault;
  end;

implementation

  uses bs.scene, bs.graphics, SysUtils, bs.utils, bs.thread;

{ TDocItemText }

procedure TDocItemText.Build;
begin
  //FRect.Size := vec2(FTxtProcessor.Width, FTxtProcessor.Height);
  if FTextObject <> nil then
    begin
    //FTextObject.Build;
    //FTextObject.Position2d := FRect.Position + vec2(FTextObject.SceneTextData.OffsetX, FTextObject.SceneTextData.OffsetY);
    //FRect.Position := FTextObject.Position2d;
    end;
  inherited;
end;

constructor TDocItemText.Create(ADoc: TBlackSharkCustomDoc; Parent: TDocItem);
begin
  inherited;
  //FTextObject := TGraphicObjectText.Create();
  FTxtProcessor := TTextProcessor.Create(SelectorKey, SelectorAverageWidth);
  FText.Create;
end;

destructor TDocItemText.Destroy;
begin
  //FTextObject.Free;
  FTxtProcessor.Free;
  FText.Free;
  inherited;
end;

procedure TDocItemText.CheckStyle;
begin
  if FStyle = nil then
    begin
    FStyle := TCustomTextStyle(ParentClass(TCustomTextStyle));
    if FStyle = nil then
      FStyle := TDocViewer(FDoc).TextStyleDefault;
    FTxtProcessor.BeginFill;
    try
      FTxtProcessor.LineHeight := FStyle.Font.SizeInPixels + round(FStyle.Font.SizeInPixels * 0.15);
    finally
      FTxtProcessor.EndFill;
    end;
    end;
end;

function TDocItemText.Show(const ViewPort: TRectBSf): Pointer;
begin
  inherited;
  CheckStyle;
  FTextObject := TCanvasText.Create(TDocViewer(FDoc).FCanvas, TDocViewer(FDoc).FDocOwner);
  Result := FTextObject;
  FTextObject.SceneTextData.TxtProcessor := FTxtProcessor;
  FTextObject.SceneTextData.Font := FStyle.Font;
  FTextObject.SceneTextData.DiscardBlanks := FDiscardBlanks;
  FTextObject.SceneTextData.TagPtr := Self;
  FTextObject.SceneTextData.StencilTest := true;
  //FTextObject.Layer2d := 1;
  { sets a text data at the end }
  FTextObject.SceneTextData.TextData := @FText;
  ShowRect(ViewPort, true);
end;

procedure TDocItemText.Hide;
begin
  HitAll := false;
  FreeAndNil(FTextObject);
end;

function TDocItemText.SelectorAverageWidth(Index: int32): BSFloat;
begin
  Result := FStyle.Font.AverageWidth;
end;

procedure TDocItemText.UpdatePosition(const ViewPort: TRectBSf);
begin
  if FTextObject = nil then
    exit;
  if Visible then
    ShowRect(ViewPort, false);
end;

function TDocItemText.GetText: string;
begin
  Result := FText;
end;

function TDocItemText.SelectorKey(Index: int32; out Code: int32): PKeyInfo;
begin
  Code := int32(FText.CharsW(Index));
  Result := FStyle.Font.Key[Code];
end;

procedure TDocItemText.SetDiscardBlanks(const Value: boolean);
begin
  if FDiscardBlanks = Value then
    exit;
  FDiscardBlanks := Value;
  Build;
end;

procedure TDocItemText.SetText(const Value: string);
begin
  FText := Value;
  FTxtProcessor.BeginFill;
  try
    CheckStyle;
    FTxtProcessor.CountChars := FText.Len;
    FTxtProcessor.SetOutRect(0, FDoc.DocSize.Width);
    Size := vec2(FTxtProcessor.Width, FTxtProcessor.Height);
  finally
    FTxtProcessor.EndFill;
  end;
  //Build;
end;

procedure TDocItemText.ShowRect(const R: TRectBSf; Force: boolean);
var
  ovrl: TRectBSf;
begin
  ovrl := RectOverlap(R, FRect);
  ovrl.Position := ovrl.Position - FRect.Position;

  if (ovrl.Width = 0) or (ovrl.Height = 0) then
    exit;

  if (ovrl.Width = FRect.Width) and (ovrl.Height = FRect.Height) then
    begin
    if HitAll and not Force then
      exit;
    HitAll := true;
    end else
    HitAll := false;

  FTextObject.SceneTextData.BeginChangeProp;
  try
    FTextObject.SceneTextData.OffsetX := ovrl.X;
    FTextObject.SceneTextData.OffsetY := ovrl.Y;
    FTextObject.SceneTextData.OutToWidth := ovrl.Width;
    FTextObject.SceneTextData.OutToHeight := ovrl.Height;
  finally
    FTextObject.SceneTextData.EndChangeProp;
  end;
  FTextObject.Position2d := FRect.Position; //vec2(ovrl.X, ovrl.Y);
end;

{ TDocItemPicture }

procedure TDocItemPicture.SetArea(AValue: PTextureArea);
begin
  if FArea = AValue then
    exit;
  FArea := AValue;
end;

procedure TDocItemPicture.SetFileName(const AValue: string);
begin
  FFileName := ExtractRelativepath(AppPath, AValue);
end;

destructor TDocItemPicture.Destroy;
begin
  inherited Destroy;
end;

function TDocItemPicture.Show(const ViewPort: TRectBSf): Pointer;
begin
  Result := nil;
  (*if Atlas = nil then
  	FindAtlas;
  if Raw = nil then
  	OpenPicture;
  if (Raw <> nil) then
    begin
    if ((FResManager.Selected = self) or (not FInsertedToAtlas)) then
      begin
      { set higher a service layer on atlas as parent }
      if Raw.Parent = nil then
        Raw.Parent := TResourceAtlasVis(Atlas).Body;
      Raw.Data.Hide := false;
      end else
      Raw.Data.Hide := true;
    end;
  if FInsertedToAtlas then
    begin
    if FArea = nil then
      begin
      Area := Atlas.AtlasTexture.GenFrameUV(RectArea);
      end;
      //CreateEmptyRect;
    if RectAfterInsert.Parent = nil then
      RectAfterInsert.Parent := TResourceAtlasVis(Atlas).Body;
    RectAfterInsert.Data.SetHideRecursive(false);
    end; *)
end;

procedure TDocItemPicture.Hide;
begin
  inherited;

end;

procedure TDocItemPicture.Load(const FromStream: TStream; const SizeData: int32
  );
var
  l: int16;
  ws: WideString;
begin
  inherited Load(FromStream, SizeData);
  l := 0;
  FromStream.Read(l, 2);
  if l > 0 then
    begin
    SetLength(ws, l div 2);
    FromStream.Read(ws[1], l);
    FFileName := WideToString(ws);
  	end;
end;

procedure TDocItemPicture.Save(const ToStream: TStream);
var
  l: int16;
  ws: WideString;
begin
  inherited Save(ToStream);
  ws := StringToWide(FFileName);
  l := length(ws)*2;
  ToStream.Write(l, 2);
  if l > 0 then
    ToStream.Write(ws[1], l);
end;

{ TDocItemRectangle }

procedure TDocItemRectangle.Build;
begin
  inherited;
  //if FRect.Size <>  then

end;

function TDocItemRectangle.Show(const ViewPort: TRectBSf): Pointer;
var
  r: TCanvasObject;
begin
  r := TDocViewer(FDoc).GetRectangle(FRect.Size, FRect.Position);
  Result := r;
  r.Data.TagPtr := Self;
end;

procedure TDocItemRectangle.Hide;
var
  co: TCanvasObject;
begin
  co := _VisualData;
  TDocViewer(FDoc).FreeRectangle(TRectangle(co));
end;

procedure TDocItemRectangle.UpdatePosition(const ViewPort: TRectBSf);
begin

end;

{ TDocViewer }

function TDocViewer.AddRect(X: BSFloat; Y: BSFloat; Width: BSFloat; Height: BSFloat; Owner: TDocItem): TDocItemRectangle;
begin
  Result := TDocItemRectangle(CreateDocItem(Owner, TDocItemRectangle, nil));
  Result.Rect := RectBS(X, Y, Width, Height);
end;

function TDocViewer.AddText(const Text: string; Owner: TDocItem): TDocItemText;
begin
  Result := TDocItemText(CreateDocItem(Owner, TDocItemText, nil));
  Result.Text := Text;
end;

function TDocViewer.AddText(const Text: string; X, Y: BSFloat; Owner: TDocItem): TDocItemText;
begin
  Result := TDocItemText(CreateDocItem(Owner, TDocItemText, nil));
  Result.Text := Text;
  Result.Rect := RectBS(X, Y, Result.FTxtProcessor.Width, Result.FTxtProcessor.Height);
end;

procedure TDocViewer.OnDropRectangle(const Value: BDragDropData);
var
  data: TDocItemRectangle;
begin
  data := PGraphicInstance(Value.BaseHeader.Instance).Owner.TagPtr;
  data.FRect.Position := TCanvasObject(data._VisualData).Position2d;
  FSpaceTree.UpdatePosition(data.FNodeInSpaceTree, Box3(vec3d(data.FRect.X, data.FRect.Y, 0.0),
    vec3d((data.FRect.X + data.FRect.Width), (data.FRect.Y + data.FRect.Height), 0.0)));
end;

procedure TDocViewer.SetDocSize(const Value: TVec2f);
begin
  inherited;

end;

{procedure TDocViewer.OnDropStyle(Style: TCustomTextStyle);
var
  data: TDocItemText;
begin
  data := Style.TextManager.TagPtr;
  data.FRect.Position := Style.Renderer.Position2d;
  data.Build;
  FSpaceTree.UpdatePosition(data.FNodeInSpaceTree, Box3(vec3(data.FRect.X, data.FRect.Y, 0.0),
    vec3((data.FRect.X + data.FRect.Width), (data.FRect.Y + data.FRect.Height), 0.0)));
end;  }

function TDocViewer.GetRectangle(const Size: TVec2f; const Position: TVec2f): TRectangle;
begin
  if CacheRectangles.Count > 0 then
  begin
    Result := TRectangle(CacheRectangles.Pop);
    Result.Data.Hidden := false;
  end else
  begin
    Result := TRectangle.Create(FCanvas, FDocOwner);
    Result.Fill := true;
    Result.Data.StaticObject := false;
    Result.Data.StencilTest := true;
  end;
  Result.Size := Size;
  Result.Position2d := Position;
  Result.Build;
end;

function TDocViewer.GetTextStyleDefault: TTextStyleDefault;
begin
  if FTextStyleDefault = nil then
    FTextStyleDefault := TTextStyleDefault.Create(Self, nil);
  Result := FTextStyleDefault;
end;

procedure TDocViewer.FreeRectangle(Rectangle: TRectangle);
begin
  CacheRectangles.Add(Rectangle);
  Rectangle.Data.Hidden := true;
end;

constructor TDocViewer.Create(ASpaceTree: TBlackSharkSpaceTree; ACanvas: TBCanvas; ADocOwner: TCanvasObject);
begin
  inherited Create(ASpaceTree);
  FCanvas := ACanvas;
  FDocOwner := ADocOwner;
  ObsrvDropRect := FDocOwner.Data.EventDropChildren.CreateObserver(GUIThread, OnDropRectangle);
  if not Assigned(FDocOwner) then
  begin
    SelfDocOwner := true;
    FDocOwner := FCanvas.CreateEmptyCanvasObject;
    FDocOwner.Position2d := vec2(0.0, 0.0);
  end;
  CacheRectangles := TListVecCanvasObjects.Create;
end;

destructor TDocViewer.Destroy;
begin

  if SelfDocOwner then
    FreeAndNil(FDocOwner);
  ObsrvDropRect := nil;

  CacheRectangles.Free;
  FTextStyleDefault.Free;

  inherited;
end;

function TDocViewer.AddRect(const Rect: TRectBSf; Owner: TDocItem): TDocItemRectangle;
begin
  Result := TDocItemRectangle(CreateDocItem(Owner, TDocItemRectangle, nil));
  Result.Rect := Rect;
end;

{ TTextStyleDefault }

constructor TTextStyleDefault.Create(ADoc: TBlackSharkCustomDoc;
  Parent: TDocItem);
begin
  inherited;
  Font := TDocViewer(FDoc).Canvas.Font;
end;

destructor TTextStyleDefault.Destroy;
begin
  Font := nil;
  inherited;
end;

procedure TTextStyleDefault.UpdatePosition(const ViewPort: TRectBSf);
begin

end;

{ TCustomTextStyle }

procedure TCustomTextStyle.SetFont(const Value: IBlackSharkFont);
begin
  if FFont = Value then
    exit;
  FFont := Value;
end;

destructor TCustomTextStyle.Destroy;
begin
  FFont := nil;
  inherited Destroy;
end;

end.
