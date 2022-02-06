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

unit bs.align;

interface

uses
    bs.basetypes
  ;


type

  TAnchor = (aLeft, aRight, aTop, aBottom);
  TObjectAlign = (oaNone, oaLeft, oaCenter, oaRight, oaClient, oaTop, oaBottom);

  TPattenAlign = class
  private
    FAnchorLeft: boolean;
    FAnchorRight: boolean;
    FMarginLeft: BSFloat;
    FMarginRight: BSFloat;
    FMinSize: BSFloat;
    FHoldParentSize: boolean;

  protected
    procedure DoAlign(var APosition, ASize: BSFloat; const AParentWidth: BSFloat; var AParentPadding: TVec2f); virtual;
  public
    constructor Create;
    procedure Assign(ASource: TPattenAlign); virtual;
    procedure Align(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
    property AnchorLeft: boolean read FAnchorLeft write FAnchorLeft;
    property AnchorRight: boolean read FAnchorRight write FAnchorRight;
    property MarginLeft: BSFloat read FMarginLeft write FMarginLeft;
    property MarginRight: BSFloat read FMarginRight write FMarginRight;
    property MinSize: BSFloat read FMinSize write FMinSize;
    property HoldParentSize: boolean read FHoldParentSize write FHoldParentSize;
  end;

  TPattenAlignRight = class(TPattenAlign)
  protected
    procedure DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f); override;
  end;

  TPattenAlignLeft = class(TPattenAlign)
  protected
    procedure DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f); override;
  end;

  TPattenAlignClient = class(TPattenAlign)
  protected
    procedure DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f); override;
  end;

  TPattenAlignCentre = class(TPattenAlign)
  protected
    procedure DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f); override;
  end;

  function GetPatternAlign(AObjectAlign: TObjectAlign; AHorizontalPattern: Boolean): TPattenAlign; overload;

implementation

function GetPatternAlign(AObjectAlign: TObjectAlign; AHorizontalPattern: Boolean): TPattenAlign;
begin
  case AObjectAlign of
    oaTop: begin
      if AHorizontalPattern then
      begin
        Result := TPattenAlignClient.Create;
        Result.HoldParentSize := true;
      end else
        Result := TPattenAlignLeft.Create;
    end;
    oaLeft: begin
      if AHorizontalPattern then
        Result := TPattenAlignLeft.Create
      else
      begin
        Result := TPattenAlignClient.Create;
        Result.HoldParentSize := true;
      end;
    end;
    oaCenter: begin
      Result := TPattenAlignCentre.Create;
    end;
    oaRight: begin
      if AHorizontalPattern then
        Result := TPattenAlignRight.Create
      else
      begin
        Result := TPattenAlignClient.Create;
        Result.HoldParentSize := true;
      end;
    end;
    oaBottom: begin
      if AHorizontalPattern then
      begin
        Result := TPattenAlignClient.Create;
        Result.HoldParentSize := true;
      end else
        Result := TPattenAlignRight.Create;
    end;
    oaClient: begin
      Result := TPattenAlignClient.Create;
    end else
    begin
      Result := TPattenAlign.Create;
      Result.HoldParentSize := true;
    end;
  end;
end;

{ TPattenAlign }

procedure TPattenAlign.Align(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
begin
  DoAlign(APosition, ASize, AParentSize, AParentPadding);
end;

procedure TPattenAlign.Assign(ASource: TPattenAlign);
begin
  FAnchorLeft := ASource.AnchorLeft;
  FAnchorRight := ASource.AnchorRight;
  FMarginLeft := ASource.MarginLeft;
  FMarginRight := ASource.MarginRight;
  FMinSize := ASource.MinSize;
end;

constructor TPattenAlign.Create;
begin
  FMinSize := 1.0;
end;

procedure TPattenAlign.DoAlign(var APosition, ASize: BSFloat; const AParentWidth: BSFloat; var AParentPadding: TVec2f);
begin
  if FAnchorLeft then
  begin
    if FAnchorRight then
    begin
      ASize := ASize + (APosition - FMarginLeft);
      APosition := FMarginLeft;
    end else
    begin
      APosition := FMarginLeft;
    end;
  end else
  if FAnchorRight then
    //ASize := AParentWidth - FMarginRight - APosition;
    APosition := AParentWidth - ASize - AParentPadding.right - FMarginRight;
end;

{ TPattenAlignLeft }

procedure TPattenAlignLeft.DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
var
  pos: BSFloat;
begin
  pos := APosition;

  APosition := AParentPadding.Left + MarginLeft;
  AParentPadding.Left := APosition + ASize + MarginRight;

  if FAnchorRight then
    ASize := ASize + pos - APosition;
end;

{ TPattenAlignRight }

procedure TPattenAlignRight.DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
begin
  if FAnchorLeft then
    ASize := AParentSize - AParentPadding.Right - MarginRight - APosition
  else
    APosition := AParentSize - AParentPadding.Right - ASize - MarginRight;

  AParentPadding.Right := AParentPadding.Right + ASize + MarginLeft + MarginRight;

end;

{ TPattenAlignCentre }

procedure TPattenAlignCentre.DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
begin
  APosition := (AParentSize - ASize) * 0.5;
end;

{ TPattenAlignClient }

procedure TPattenAlignClient.DoAlign(var APosition, ASize: BSFloat; const AParentSize: BSFloat; var AParentPadding: TVec2f);
begin
  APosition := AParentPadding.Left + MarginLeft;

  ASize := AParentSize - AParentPadding.Right - AParentPadding.Left - MarginLeft - MarginRight;

  if ASize <= 0 then
    ASize := 1;

  if not FHoldParentSize then
    AParentPadding.Left := APosition + ASize + MarginRight;
end;

end.
