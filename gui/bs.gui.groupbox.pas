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


unit bs.gui.groupbox;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.canvas
  , bs.scene
  , bs.gui.base
  , bs.mesh.primitives
  ;

type

  TBGroupBoxCustom = class(TBControl)
  private
    const
      CAPTION_OFFSET = 10;
  private
    FShowBorder: boolean;
    FCaption: TCanvasText;
    FBorder: TPath;
    procedure SetShowBorder(const AValue: boolean);
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    function GetColorBorder: TGuiColor;
    procedure SetColorBorder(const AValue: TGuiColor);
    procedure BuildBorder;
  protected
    function GetHeight: BSFloat; override;
    function GetWidth: BSFloat; override;
    procedure SetScalable(const Value: boolean); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DefaultSize: TVec2f; override;
    property ShowBorder: boolean read FShowBorder write SetShowBorder;
    property Caption: string read GetCaption write SetCaption;
    property ColorBorder: TGuiColor read GetColorBorder write SetColorBorder;
  end;

  TBGroupBox = class(TBGroupBoxCustom)
  published
    property ShowBorder;
    property Caption;
    property ColorBorder;
  end;

implementation

uses
    bs.config
  ;

{ TBGroupBoxCustom }

procedure TBGroupBoxCustom.BuildBorder;
begin
  FBorder.Clear;
  if FCaption.Text <> '' then
    FBorder.AddPoint(vec2((CAPTION_OFFSET-5), 0.0));
  FBorder.AddPoint(vec2(0.0, 0.0));
  FBorder.AddPoint(vec2(0.0, FMainBody.Height));
  FBorder.AddPoint(vec2(FMainBody.Width, FMainBody.Height));
  FBorder.AddPoint(vec2(FMainBody.Width, 0.0));
  if FCaption.Text <> '' then
    FBorder.AddPoint(vec2(FCaption.Position2d.x + FCaption.Width + 5, 0.0))
  else
    FBorder.AddPoint(vec2(0.0, 0.0));
  FBorder.Build;
  FBorder.Position2d := vec2(0.0, 0.0);
end;

procedure TBGroupBoxCustom.BuildView;
begin
  inherited;
  FMainBody.Build;
  FCaption.Position2d := vec2(CAPTION_OFFSET, -FCaption.Height*0.5);
  if FShowBorder then
    BuildBorder
end;

constructor TBGroupBoxCustom.Create(ACanvas: TBCanvas);
var
  body: TRectangle;
begin
  inherited;
  FCanvas.Font.SizeInPixels := 12;
  FShowBorder := true;
  body := TRectangle.Create(FCanvas, nil);
  FMainBody := body;
  body.Data.Opacity := 0.0;
  body.Fill := true;
  //body.Data.DragResolve := false;
  body.Size := DefaultSize;
  FCaption := TCanvasText.Create(FCanvas, FMainBody);
  FCaption.Data.Interactive := false;
  FCaption.Text := 'GroupBox';
  FBorder := TPath.Create(FCanvas, FMainBody);
  FBorder.Data.Interactive := false;
  FBorder.Color := TColor4f($DDDDDD);
  FBorder.InterpolateSpline := isNone;
end;

function TBGroupBoxCustom.DefaultSize: TVec2f;
begin
  if FCanvas.Scalable then
  begin
    Result := vec2(BSConfig.VoxelSize * 150, BSConfig.VoxelSize * 100);
  end else
  begin
    Result := vec2(150, 100);
  end;
end;

function TBGroupBoxCustom.GetCaption: string;
begin
  Result := FCaption.Text;
end;

function TBGroupBoxCustom.GetColorBorder: TGuiColor;
begin
  Result := TGuiColor(FBorder.Color);
end;

function TBGroupBoxCustom.GetHeight: BSFloat;
begin
  Result := TRectangle(FMainBody).Size.Height;
end;

function TBGroupBoxCustom.GetWidth: BSFloat;
begin
  Result := TRectangle(FMainBody).Size.Width;
end;

procedure TBGroupBoxCustom.Resize(AWidth, AHeight: BSFloat);
begin
  TRectangle(FMainBody).Size := vec2(AWidth, AHeight);
  inherited;
end;

procedure TBGroupBoxCustom.SetCaption(const AValue: string);
begin
  FCaption.Text := AValue;
  if FShowBorder then
    BuildBorder;
end;

procedure TBGroupBoxCustom.SetColorBorder(const AValue: TGuiColor);
begin
  FBorder.Color := TColor4f(AValue);
end;

procedure TBGroupBoxCustom.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

procedure TBGroupBoxCustom.SetShowBorder(const AValue: boolean);
begin
  if FShowBorder = AValue then
    exit;
  FShowBorder := AValue;
  if FShowBorder then
    BuildBorder
  else
    FBorder.Clear;
end;

end.
