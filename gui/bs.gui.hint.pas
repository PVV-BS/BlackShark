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

unit bs.gui.hint;

{ contain an implementation class-hint consists of vectoral shapes and text;
  for show hint used TBlackSharkHint.Hide := false; for positioning used
  TBlackSharkHint.Position2d or TBlackSharkHint.Root.Data.Position in 3d }

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.scene
  , bs.canvas
  , bs.gui.themes
  , bs.gui.base
  , bs.shader
  , bs.scene.objects
  , bs.align
  ;

type

  { TBlackSharkHint }

  TBlackSharkHint = class(TBControl)
  private
    const
      RADIUS_BOUND = 4;
      //NUM_SLICES = 4;
  private
    //TObject
    FRect: TRoundRect;
    FBorder: TRoundRect;
    FText: TCanvasText;
    FHintData: TGraphicObjectText;
    FAllowBreakWords: boolean;
    function GetText: string;
    procedure AlignTextPosition;
    procedure SetText(const Value: string);
    function GetTextAlign: TTextAlign;
    procedure SetTextAlign(const Value: TTextAlign);
    procedure SetAllowBreakWords(const Value: boolean);
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure BuildView; override;
    function DefaultSize: TVec2f; override;
    property Text: string read GetText write SetText;
    property AlignHintText: TTextAlign read GetTextAlign write SetTextAlign;
    property AllowBreakWords: boolean read FAllowBreakWords write SetAllowBreakWords;
  end;

implementation

uses
   bs.font
  ;

{ TBlackSharkHint }

procedure TBlackSharkHint.AfterConstruction;
begin
  inherited;
  FHintData.Align := TTextAlign.taCenter;
end;

procedure TBlackSharkHint.AlignTextPosition;
begin
  case FHintData.Align of
    TTextAlign.taCenter: FText.ToParentCenter;
    TTextAlign.taRight: FText.Position2d := vec2(FRect.Width - TGraphicObjectText(FText.Data).TxtProcessor.Interligne - FText.Width, TGraphicObjectText(FText.Data).TxtProcessor.Interligne);
    //oaBottom: FText.Position2d := vec2(TGraphicObjectText(FText.Data).TxtProcessor.Interligne, FRect.Height - FText.Height)
     else
      FText.Position2d := vec2(TGraphicObjectText(FText.Data).TxtProcessor.Interligne, TGraphicObjectText(FText.Data).TxtProcessor.Interligne);
  end;
end;

procedure TBlackSharkHint.BuildView;
begin
  FRect.Size := vec2(FText.Width + 6, FText.Height + 4);
  FRect.Build;
  FBorder.Size := FRect.Size;
  FBorder.Build;
  FBorder.Position2d := vec2(0.0, 0.0);
  AlignTextPosition;
end;

constructor TBlackSharkHint.Create(ACanvas: TBCanvas);
begin
  inherited;
  FCanvas.Font.Size := 8;
  FRect := TRoundRect.Create(FCanvas, nil);
  FRect.Size := DefaultSize;
  FRect.Fill := true;
  FRect.RadiusRound := RADIUS_BOUND;
  FRect.Color := BS_CL_SKY_BLUE;
  FMainBody := FRect;
  FBorder := TRoundRect.Create(FCanvas, FRect);
  FBorder.Size := FRect.Size;
  FBorder.RadiusRound := RADIUS_BOUND;
  FBorder.Fill := false;
  FBorder.Color := BS_CL_SILVER2;
  //FBorder.Data.Opacity := 0.3;
  FText := TCanvasText.Create(FCanvas, FRect);
  FText.Color := BS_CL_BLACK;
  FRect.Position2d := vec2(100, 100.0);
  FHintData := TGraphicObjectText(FText.Data);
  FHintData.Interactive := false;
end;

function TBlackSharkHint.DefaultSize: TVec2f;
begin
  Result := vec2(200, 50);
end;

destructor TBlackSharkHint.Destroy;
begin

  inherited;
end;

function TBlackSharkHint.GetText: string;
begin
  Result := FText.Text;
end;

function TBlackSharkHint.GetTextAlign: TTextAlign;
begin
  Result := FHintData.Align;
end;

procedure TBlackSharkHint.SetAllowBreakWords(const Value: boolean);
begin
  FAllowBreakWords := Value;
  FHintData.TxtProcessor.AllowBreakWords := FAllowBreakWords;
end;

procedure TBlackSharkHint.SetText(const Value: string);
begin
  if FText.Text = Value then
    exit;
  FText.Text := Value;
  BuildView;
end;

procedure TBlackSharkHint.SetTextAlign(const Value: TTextAlign);
begin
  FHintData.Align := Value;
  AlignTextPosition;
end;

end.
