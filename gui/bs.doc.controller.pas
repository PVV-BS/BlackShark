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

unit bs.doc.controller;

{$I BlackSharkCfg.inc}

interface

uses
  bs.basetypes,
  bs.doc.model,
  bs.strings,
  bs.collections,
  bs.geometry,
  bs.canvas,
  bs.textprocessor
  //bs.mesh.presents
  ;


type

  { TCastomController }

  TCastomController = class
  private
  protected
    FDoc: TBlackSharkCustomDoc;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc); virtual;
    destructor Destroy; override;

  end;

  { TControllerText }

  {TControllerText = class(TCastomController)
  private
    //Cache: TListVec<TBlackSharkCanvasText>;
    Renderer: TTextManager;
    //procedure Draw(Text: THierarchyText; const ViewPort: TRectBSf);
  public
    constructor Create(ADoc: TBlackSharkCustomDoc); override;
    destructor Destroy; override;
  end;     }

  { TControllerRect }

  {TControllerRect = class(TControllerDoc)
  private
    Cache: TListVecCanvasObjects;
  public
    constructor Create(ADoc: TBlackSharkCustomDoc); override;
    destructor Destroy; override;
  end;   }

implementation

{ TCastomController }

constructor TCastomController.Create(ADoc: TBlackSharkCustomDoc);
begin

end;

destructor TCastomController.Destroy;
begin
  inherited Destroy;
end;

{ TControllerText }

{procedure TControllerText.Draw(Text: THierarchyText; const ViewPort: TRectBSf);
begin
  //Renderer.Clear;
  Text.ShowRect(Renderer, ViewPort);
end;

constructor TControllerText.Create(ADoc: TBlackSharkCustomDoc);
begin
  inherited;
  //Cache := TListVec<TBlackSharkCanvasText>.Create;
  Renderer := TTextManager.Create(FDoc.Viewer.Scene, ADoc.DocOwner.Data);
end;

destructor TControllerText.Destroy;
begin
  Renderer.Free;
  //Cache.Free;
  inherited;
end;

procedure TControllerText.HideHierarchyData(HierarchyData: THierarchyVisual);
begin
  Renderer.Clear;
end;

function TControllerText.ShowHierarchyData(HierarchyData: THierarchyVisual;
  const ViewPort: TRectBSf): Pointer;
begin
  Draw(THierarchyText(HierarchyData), ViewPort);
  Result := nil;
end;

procedure TControllerText.UpdatePostion(HierarchyData: THierarchyVisual;
  const ViewPort: TRectBSf);
begin
  Draw(THierarchyText(HierarchyData), ViewPort);
end;      }

{ TControllerRect }

{constructor TControllerRect.Create(ADoc: TBlackSharkCustomDoc);
begin
  inherited;
  Cache := TListVecCanvasObjects.Create;
end;

destructor TControllerRect.Destroy;
begin
  Cache.Free;
  inherited;
end;

procedure TControllerRect.HideHierarchyData(HierarchyData: THierarchyVisual);
var
  co: TBlackSharkCanvasObject;
begin
  co := HierarchyData._ViewerData;
  co.Data.Hide := true;
  Cache.Add(co);
end;

function TControllerRect.ShowHierarchyData(HierarchyData: THierarchyVisual;
  const ViewPort: TRectBSf): Pointer;
var
  res: TBlackSharkCanvasObject;
begin
  if Cache.Count > 0 then
    begin
    res := Cache.Pop;
    res.Position2d := HierarchyData.Rect.Position - ViewPort.Position;
    res.Resize(THierarchyRectangle(HierarchyData).Rect.Width, HierarchyData.Rect.Height);
    end else
    begin
    res := FDoc.Viewer.Factory.Rectangle(FDoc.Viewer, HierarchyData.Rect.Size,
      HierarchyData.Rect.Position - ViewPort.Position, true);
    res.Parent := FDoc.DocOwner;
    res.Data.StaticObject := false;
    res.Data.StencilTest := true;
    end;
  Result := res;
end;

procedure TControllerRect.UpdatePostion(HierarchyData: THierarchyVisual;
  const ViewPort: TRectBSf);
var
  co: TBlackSharkCanvasObject;
begin
  exit;
  co := HierarchyData._ViewerData;
  co.Position2d := HierarchyData.Rect.Position;
end;}

end.
