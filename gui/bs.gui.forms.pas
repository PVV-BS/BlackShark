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

unit bs.gui.forms;

{$ifdef FPC}
  {$WARN 5024 off : Parameter "$1" not used}
{$endif}

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.scene
  , bs.canvas
  , bs.graphics
  , bs.gui.base
  , bs.gui.themes
  , bs.gui.themes.primitives
  , bs.scene.objects
  , bs.gui.scrollbar
  , bs.geometry
  , bs.animation
  , bs.align
  ;

type

  TBScrolledWindowCustom = class;

  TOnChangePositionNotify = procedure (Sender: TBScrolledWindowCustom; const NewPosition: TVec2d) of object;

  { TBScrolledWindowCustom
    It is contaiter for scrolling graphical items in 2d spaces (see examples in
    bs.mesh.presents) and out to a property ClipObject; scrolled an area defined
    by a property ScrolledArea; for simple situation you can create primitives
    or drop controls by a DropControl; but, if you want draw many an objects on
    the wide space then you need to implement MVC template, when a data model
    stored in a spatial tree; for example,
    see test bs.test.spacetree.TBSTestScrollBoxSpaceTree;
   }

  TBScrolledWindowCustom = class(TBControl)
  private
      class var CurrentLayer: int32;
      class function GetNextLayer: int32;
  private
    const
      DEFAULT_WIDTH   = 200.0;
      DEFAULT_HEIGHT  = 200.0;
  private
    ObsrvMouseEnter: IBMouseDownEventObserver;
    ObsrvMouseLeave: IBMouseDownEventObserver;
    ObsrvMouseDown: IBMouseDownEventObserver;
    ObsrvMouseMove: IBMouseDownEventObserver;
    ObsrvMouseUp: IBMouseDownEventObserver;
    ObsrvMouseScroll: IBMouseWeelEventObserver;
    ObsrvDropInst: IBDragDropEventObserver;

    //FColorBackground: TColor4f;
    FScrollBarHor: TBScrollBar;
    FScrollBarVert: TBScrollBar;
    FClipObject: TRectangle;
    FBorder: TRectangle;
    //FPaddingRectangle: TRectangle;
    //FPaddingArea: TRectBSF;
    FOwnerInstances: TCanvasObject;
    FPosition: TVec2i64;
    FSpaceTreeClass: TBlackSharkSpaceTreeClass;
    FOnChangePosition: TOnChangePositionNotify;
    FShowBorder: boolean;
    StateInteractive: boolean;
    FUseSpaceTree: boolean;
    MouseDownPos: TVec2f;
    PosMouseDown: TVec2d;
    ButtonMouseDown: TBSMouseButtons;
    FOpacity: int32;
    ObsrvOnKeyDown: IBKeyEventObserver;
    ObsrvOnKeyUp: IBKeyEventObserver;
    ObsrvOnKeyPress: IBKeyEventObserver;
    FIsMouseDown: boolean;
    WidthScrollBars: BSFloat;
    function GetScrolledArea: TVec2i64;
    procedure SetAutoResizeScrollingArea(AValue: boolean);
    procedure SetPosition(const Value: TVec2i64);
    procedure ChangeScrollHor({%H-}ScrollBar: TBScrollBar);
    procedure ChangeScrollVer({%H-}ScrollBar: TBScrollBar);
    procedure OnDropInstance({%H-}const Data: BDragDropData);
    //procedure DropScrollBar(ScrollBar: TBScrollBar);
    procedure SetSpaceTreeClass(const Value: TBlackSharkSpaceTreeClass);
    procedure SetShowBorder(const Value: boolean);
    procedure BorderCreate;
    procedure CheckScrollingAreaByTree;
    procedure CheckScrollingAreaByList;
    procedure SetUseSpaceTree(const Value: boolean);
    procedure CreateSpaceTree;
    procedure SetOpacity(const Value: int32);
    function GetColorBorder: TGuiColor;
    procedure SetColorBorder(const Value: TGuiColor);
    procedure SetScrollBarsPaddingBottom(const Value: BSFloat);
    procedure SetScrollBarsPaddingLeft(const Value: BSFloat);
    procedure SetScrollBarsPaddingRight(const Value: BSFloat);
    procedure SetScrollBarsPaddingTop(const Value: BSFloat);
    procedure CheckSizeScrollBars;
    procedure UpdateScrolledSpaceSize;
  protected
    // paddings in FClipObject for scrolbars
    FScrollBarsPaddingLeft: BSFloat;
    FScrollBarsPaddingTop: BSFloat;
    FScrollBarsPaddingRight: BSFloat;
    FScrollBarsPaddingBottom: BSFloat;
    FAutoResizeScrollingArea: boolean;
    FAllowDragWindowOverData: boolean;
    UpdateCounter: int32;
    { the space tree is created by descendants }
    FSpaceTree: TBlackSharkSpaceTree;
    procedure OnCreateCanvasObject(const AData: BData); override;
    { method invoked when changes position a "viewport" (ClipObject) }
    procedure DoChangePos; virtual;
    procedure SetVisible(const Value: boolean); override;
    procedure ReloadSpaceTree; virtual;
    procedure SetScrolledArea(const AValue: TVec2i64); virtual;
    procedure SetEnabled(const Value: boolean); override;
    procedure MouseDown({%H-}const Data: BMouseData); virtual;
    procedure MouseEnter({%H-}const Data: BMouseData); virtual;
    procedure MouseLeave({%H-}const Data: BMouseData); virtual;
    procedure MouseMove({%H-}const Data: BMouseData); virtual;
    procedure MouseUp({%H-}const Data: BMouseData); virtual;
    procedure KeyDown({%H-}const Data: BKeyData); virtual;
    procedure KeyUp({%H-}const Data: BKeyData); virtual;
    procedure KeyPress({%H-}const Data: BKeyData); virtual;
    procedure MouseScroll({%H-}const Data: BMouseData); virtual;
    procedure SetScalable(const Value: boolean); override;
    procedure SetFocused(Value: boolean); override;
    procedure DoAfterScale; override;
    procedure SetAlign(const Value: TObjectAlign); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    function DefaultSize: TVec2f; override;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    procedure BuildView; override;
    procedure DrawClipArea(Instance: PRendererGraphicInstance);
    { seting a position under data, pixels  }
    procedure ScrollTo(X, Y: Int64);
    procedure Resize(AWidth, AHeight: BSFloat); override;
    procedure DropControl(Control: TBControl; {%H-}Parent: TCanvasObject); overload; override;
    { check size of scrolled area by content and change if need }
    procedure CheckScrollingArea; virtual;
    { wrapper for a SpaceTree.Add; only for a managed data through a "controller" linked
      to SpaceTree.OnShowUserData/OnHideUserData/OnUpdatePositionUserData; }
    procedure DataAdd(Data: Pointer; const Rect: TRectBSf; out Node: PNodeSpaceTree);
    { space tree (property SpaceTree) nothing doesn't know about changing a position data,
      therefor, in that case you should to invoke this method for defining hitting into
      current viewport the space tree }
    procedure DataUpdateRect(Position: PNodeSpaceTree; const NewRect: TRectBSf);
    { Position of viewport (ClipObject) over data (scrolled area), pixels }
    property Position: TVec2i64 read FPosition write SetPosition;
    { a scrollable area }
    property ScrolledArea: TVec2i64 read GetScrolledArea write SetScrolledArea;
    { color of background }
    //property ColorBackground: TColor4f read FColorBackground write SetColorBackground;
    { background root window - "viewport" for out containing visible data }
    property ClipObject: TRectangle read FClipObject;
    property Border: TRectangle read FBorder;
    { parent object for all droped controls and simple canvas objects }
    property OwnerInstances: TCanvasObject read FOwnerInstances;
    property AutoResizeScrollingArea: boolean read FAutoResizeScrollingArea write SetAutoResizeScrollingArea;
    { the property allows to implement MVC template; memorize, in SaceTree stores
      only a data model; for this you can to add self data to SpaceTree and visualize
      only those which visible; visibility defines through events
      TBlackSharkSpaceTree.OnHide.../OnShow; note, a size viweport for this class
      (TBScrolledWindowCustom) translates from 2d to 3d (scene), that is why
      in time add self data you must to translate in scene size (Position and  Rect);
      the SpaceTree initializes in BuildGui, in order to befor you can assign
      in you own a descendant own kind of a space tree }
    property SpaceTree: TBlackSharkSpaceTree read FSpaceTree;
    { if to change tne property then SpaceTree will recreated and invoked
      ReloadSpaceTree;  }
    property SpaceTreeClass: TBlackSharkSpaceTreeClass read FSpaceTreeClass write SetSpaceTreeClass;
    property OnChangePosition: TOnChangePositionNotify read FOnChangePosition write FOnChangePosition;
    property ShowBorder: boolean read FShowBorder write SetShowBorder;
    { default true; if false and (AutoResizeScrollingArea = true) then scrolled
      area defined through list graphics objects, otherwise you have to use
      DataAdd and DataUpdateRect methods (see test: bs.test.TBSTestScrollBoxSpaceTree)  }
    property UseSpaceTree: boolean read FUseSpaceTree write SetUseSpaceTree;
    property AllowDragWindowOverData: boolean read FAllowDragWindowOverData write FAllowDragWindowOverData;
    property IsMouseDown: boolean read FIsMouseDown;
    property ScrollBarHor: TBScrollBar read FScrollBarHor;
    property ScrollBarVert: TBScrollBar read FScrollBarVert;
    property Opacity: int32 read FOpacity write SetOpacity;
    { color for the border; the color is applyed if ShowBorder is true }
    property ColorBorder: TGuiColor read GetColorBorder write SetColorBorder;
    { paddings in FClipObject for scrolbars; it allow to reserve area for custom visual data }
    property ScrollBarsPaddingLeft: BSFloat read FScrollBarsPaddingLeft write SetScrollBarsPaddingLeft;
    property ScrollBarsPaddingTop: BSFloat read FScrollBarsPaddingTop write SetScrollBarsPaddingTop;
    property ScrollBarsPaddingRight: BSFloat read FScrollBarsPaddingRight write SetScrollBarsPaddingRight;
    property ScrollBarsPaddingBottom: BSFloat read FScrollBarsPaddingBottom write SetScrollBarsPaddingBottom;
  end;

  TBScrolledWindow = class(TBScrolledWindowCustom)
  published
    property ScrollBarHor;
    property ScrollBarVert;
    property Opacity;
    { color for the border; the color is applyed if ShowBorder is true }
    property ColorBorder;
    { paddings in FClipObject for scrolbars; it allow to reserve area for custom visual data }
    property ScrollBarsPaddingLeft;
    property ScrollBarsPaddingTop;
    property ScrollBarsPaddingRight;
    property ScrollBarsPaddingBottom;
  end;

  { TBFormCustom
  }

  TBFormCustom = class(TBScrolledWindowCustom)
  private
    const
      DEF_CAPTION_HEADER_PLANE_HEIGHT = 18;
  private
    FObsrvClickSrceen: IBMouseDownEventObserver;
    FObsrvDownCaptionHeader: IBMouseDownEventObserver;
    FObsrvMoveCaptionHeader: IBMouseMoveEventObserver;
    FObsrvUpCaptionHeader: IBMouseUpEventObserver;
    FObsrvBtnCloseEnter: IBMouseEnterEventObserver;
    FObsrvBtnCloseDown: IBMouseDownEventObserver;
    FObsrvBtnCloseUp: IBMouseDownEventObserver;
    FObsrvBtnCloseLeave: IBMouseLeaveEventObserver;
    AniLawBtnOpacity: IBAnimationLinearFloat;
    ObsrvAniLawBtnOpacity: IBAnimationLinearFloatObsrv;
    FFormHeader: TRectangle;
    FButtonOnHeader: TRectangle;
    FCloseCross: TLines;
    FCaptionHeader: TCanvasText;
    FCaptionHeaderText: string;
    FShowHeader: boolean;
    FOnClose: TBControlNotify;
    FOnShow: TBControlNotify;
    PosMouseDownCaptionHeader: TVec2i;
    PositionWhenMouseDownCaptionHeader: TVec2f;
    FColorHeader: TGuiColor;
    FColorCaptionHeader: TGuiColor;
    FShowCloseButtonOnHeader: boolean;
    FShowResult: int32;
    FHeaderHeight: BSFloat;
    FOnDrag: TBControlNotify;
    FOnBeginDrag: TBControlNotify;
    procedure CreateCaptionHeader;
    procedure BuildCaptionHeader;
    procedure FreeCaptionHeader;
    procedure CreateButtonOnHeader;
    procedure BuildButtonOnHeader;
    procedure FreeButtonHeader;
    procedure SetCaptionHeader(const AValue: string);
    procedure OnMouseClickOnScreen({%H}const Data: BMouseData);
    procedure OnMouseDownCaptionHeader({%H}const Data: BMouseData);
    procedure OnMouseMoveCaptionHeader({%H}const Data: BMouseData);
    procedure OnMouseUpCaptionHeader({%H}const Data: BMouseData);
    procedure OnMouseEnterButtonHeader({%H}const Data: BMouseData);
    procedure OnMouseDownButtonHeader({%H}const Data: BMouseData);
    procedure OnMouseUpButtonHeader({%H}const Data: BMouseData);
    procedure OnMouseLeaveButtonHeader({%H}const Data: BMouseData);
    procedure AniChangeBtnOpacity({%H}const Data: BSFloat);
    procedure SetShowCloseButtonOnHeader(const Value: boolean);
    procedure SeTGuiColorCaptionHeader(const Value: TGuiColor);
    procedure SeTGuiColorHeader(const Value: TGuiColor);
    procedure SetShowHeader(const Value: boolean);
    procedure SetHeaderHeight(const Value: BSFloat);
  protected
    ModalMode: boolean;
    procedure SetScalable(const Value: boolean); override;
    procedure SetVisible(const Value: boolean); override;
    procedure KeyPress({%H-}const Data: BKeyData); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BuildView; override;
    { ShowModal with locked all graphical items under form, but return control immediately;
      event on form close will send through OnClose property where you can assign self
      handler }
    procedure ShowModal; virtual;
    { Show without locked all graphical items under form }
    procedure Show; virtual;
    procedure Close; virtual;
  public
    property CaptionHeader: string read FCaptionHeaderText write SetCaptionHeader;
    property ShowHeader: boolean read FShowHeader write SetShowHeader;
    property ShowCloseButton: boolean read FShowCloseButtonOnHeader write SetShowCloseButtonOnHeader;
    property ColorHeader: TGuiColor read FColorHeader write SeTGuiColorHeader;
    property ColorCaptionHeader: TGuiColor read FColorCaptionHeader write SeTGuiColorCaptionHeader;
    property HeaderHeight: BSFloat read FHeaderHeight write SetHeaderHeight;
    property OnClose: TBControlNotify read FOnClose write FOnClose;
    property OnShow: TBControlNotify read FOnShow write FOnShow;
    property ShowResult: int32 read FShowResult write FShowResult;
    property OnBeginDrag: TBControlNotify read FOnBeginDrag write FOnBeginDrag;
    property OnDrag: TBControlNotify read FOnDrag write FOnDrag;
  end;

  TBForm = class(TBFormCustom)
  published
    property ScrollBarHor;
    property ScrollBarVert;
    property Opacity;
    property ColorBorder;
    property ScrollBarsPaddingLeft;
    property ScrollBarsPaddingTop;
    property ScrollBarsPaddingRight;
    property ScrollBarsPaddingBottom;
  end;

implementation

uses
    SysUtils
  , Classes
  , bs.config
  {$ifdef ultibo}
  , gles20
  {$else}
  , bs.gl.es
  {$endif}
  , bs.frustum
  , bs.thread
  , bs.events.keyboard
  , bs.window
  ;

{ TBlackSharkScrollBox }

constructor TBScrolledWindowCustom.Create(ACanvas: TBCanvas);
begin
  inherited;
  FColor := $808080;
  FSpaceTreeClass := TBlackSharkRTree;
  FOpacity := 100;
  FShowBorder := true;
  FSpaceTree := FSpaceTreeClass.Create;
  FSpaceTree.Dimensions := [AxleX, AxleY];
  FUseSpaceTree := true;
  FCanvas.ModalLevel := GetNextLayer;
  // create root rectangle - viewport for out of visual data
  FClipObject := TRectangle.Create(FCanvas, nil);
  FMainBody := FClipObject;
  FClipObject.Fill := true;
  { enforce to register events }
  FClipObject.Data.EventKeyDown;
  FClipObject.Data.EventKeyUp;
  FClipObject.Data.EventKeyPress;
  FClipObject.Data.DrawInstance := DrawClipArea;
  FClipObject.Data.AsStencil := true;
  FClipObject.Color := TColor4f(FColor);
  FClipObject.Position2d := vec2(0.0, 0.0);
  FClipObject.Data.DragResolve := false;
  FClipObject.Data.SelectResolve := false;
  FClipObject.Data.Opacity := FOpacity/100;
  FClipObject.Size := DefaultSize;
  ObsrvMouseEnter := CreateMouseObserver(FClipObject.Data.EventMouseEnter, MouseEnter);
  ObsrvMouseDown := CreateMouseObserver(FClipObject.Data.EventMouseDown, MouseDown);
  ObsrvMouseMove := CreateMouseObserver(FClipObject.Data.EventMouseMove, MouseMove);
  ObsrvMouseUp := CreateMouseObserver(FClipObject.Data.EventMouseUp, MouseUp);
  ObsrvMouseLeave := CreateMouseObserver(FClipObject.Data.EventMouseLeave, MouseLeave);
  ObsrvDropInst := FClipObject.Data.EventDropChildren.CreateObserver(GUIThread, OnDropInstance);
  // set root 2d position to left-up screen angle
  FOwnerInstances := FCanvas.CreateEmptyCanvasObject(FClipObject);
  FOwnerInstances.Position2d := vec2(0.0, 0.0);
  FScrollBarHor := TBScrollBar.Create(Canvas);
  //DropScrollBar(FScrollBarHor);
  FScrollBarHor.Horizontal := true;
  FScrollBarHor.MainBody.Data.DragResolve := false;
  // be careful, because if TBScrolledWindowCustom will have parent with high Layer2d
  // then ScrollBar can be hided or one of its parts
  FScrollBarHor.MainBody.Layer2d := Round(TBlackSharkFrustum.MAX_COUNT_LAYERS - 5);
  FScrollBarHor.OnChangePosition := ChangeScrollHor;
  FScrollBarHor.MainBody.Parent := FClipObject;

  FScrollBarVert := TBScrollBar.Create(Canvas);
  //DropScrollBar(FScrollBarVert);
  FScrollBarVert.MainBody.Data.DragResolve := false;
  FScrollBarVert.MainBody.Layer2d := FScrollBarHor.MainBody.Layer2d;
  FScrollBarVert.OnChangePosition := ChangeScrollVer;
  FScrollBarVert.MainBody.Parent := FClipObject;
  if FShowBorder then
    BorderCreate;
end;

procedure TBScrolledWindowCustom.CreateSpaceTree;
var
  need_reload: boolean;
  dim: TAxisSet;
begin
  if FSpaceTree <> nil then
  begin
    need_reload := true;
    dim := FSpaceTree.Dimensions;
    FSpaceTree.Free;
  end else
  begin
    need_reload := false;
    dim := [AxleX, AxleY];
  end;
  FSpaceTree := FSpaceTreeClass.Create;
  FSpaceTree.Dimensions := dim;
  if need_reload then
    ReloadSpaceTree;
end;

function TBScrolledWindowCustom.DefaultSize: TVec2f;
begin
  Result := vec2(round(DEFAULT_WIDTH*ToHiDpiScale), round(DEFAULT_HEIGHT*ToHiDpiScale));
end;

destructor TBScrolledWindowCustom.Destroy;
begin
  FScrollBarHor.Free;
  FScrollBarVert.Free;
  FSpaceTree.Free;
  inherited Destroy;
end;

procedure TBScrolledWindowCustom.DataAdd(Data: Pointer; const Rect: TRectBSf; out Node: PNodeSpaceTree);
begin
  FSpaceTree.Add(Data, Box3(vec3d(Rect.X, Rect.Y, 0.0), vec3d((Rect.X + Rect.Width), (Rect.Y + Rect.Height), 0.0)), Node);
  if AutoResizeScrollingArea then
    CheckScrollingAreaByTree;
end;

procedure TBScrolledWindowCustom.DataUpdateRect(Position: PNodeSpaceTree; const NewRect: TRectBSf);
begin
  //FSpaceTree.UpdatePosition(Position,
  //  Box3(ClipObject.Get3dPositionInsideSelf(NewRect.X, NewRect.Y  + NewRect.Height),
  //  ClipObject.Get3dPositionInsideSelf(NewRect.X + NewRect.Width, NewRect.Y)));
  FSpaceTree.UpdatePosition(Position, Box3(vec3d(NewRect.X, NewRect.Y, 0.0),
    vec3d((NewRect.X + NewRect.Width), (NewRect.Y + NewRect.Height), 0.0)));
end;

procedure TBScrolledWindowCustom.BuildView;
begin
  if UpdateCounter <> 0 then
    exit;
  inherited;
  //FClipObject.Size := vec2(FClipObject.Width, FClipObject.Height);
  FClipObject.Build;

  WidthScrollBars := FScrollBarVert.Width;
  CheckSizeScrollBars;
  if Assigned(Border) then
  begin
    FBorder.Size := vec2(FClipObject.Width, FClipObject.Height) + FBorder.WidthLine*2;
    FBorder.Build;
    FBorder.Position2d := vec2(-round(FBorder.WidthLine), -round(FBorder.WidthLine));
  end;

  if not FAllowDragWindowOverData then
  begin
    { align the view of window to zero position if the bars of scroll is hide }
    if (not FScrollBarHor.Visible) and (FPosition.x > 0) then
    begin
      FPosition.x := 0;
      FScrollBarHor.OnChangePosition := nil;
      try
        FScrollBarHor.Position := 0;
      finally
        FScrollBarHor.OnChangePosition := ChangeScrollHor;
      end;
    end;

    if (not FScrollBarVert.Visible) and (FPosition.y > 0) then
    begin
      FPosition.y := 0;
      FScrollBarVert.OnChangePosition := nil;
      try
        FScrollBarVert.Position := 0;
      finally
        FScrollBarVert.OnChangePosition := ChangeScrollVer;
      end;
    end;
  end;

  DoChangePos;
end;

procedure TBScrolledWindowCustom.ReloadSpaceTree;
begin
  if Assigned(FSpaceTree) then
    FSpaceTree.ViewPort(FPosition.x, FPosition.y, Width, Height);
end;

procedure TBScrolledWindowCustom.Resize(AWidth, AHeight: BSFloat);
begin

  if FClipObject.Align = TObjectAlign.oaNone then
    FClipObject.Size := vec2(AWidth, AHeight);

  UpdateScrolledSpaceSize;
  inherited;
end;

procedure TBScrolledWindowCustom.SetPosition(const Value: TVec2i64);
begin
  ScrollTo(Value.x, Value.y);
end;

procedure TBScrolledWindowCustom.SetEnabled(const Value: boolean);
begin
  if (FClipObject <> nil) then
    StateInteractive := FClipObject.Data.Interactive;
  inherited;
  { the behavior is expected? }
  if (FClipObject <> nil) and (StateInteractive = FClipObject.Data.Interactive) then
  begin
    if FClipObject.Data.Interactive <> Value then
      FClipObject.Data.Interactive := Value;
  end;
end;

procedure TBScrolledWindowCustom.SetFocused(Value: boolean);
begin
  inherited;
  if Focused then
  begin
    ObsrvMouseScroll := CreateMouseObserver(Canvas.Renderer.EventMouseWeel, MouseScroll);
    ObsrvOnKeyDown := CreateKeyObserver(Canvas.Renderer.EventKeyDown, KeyDown);
    ObsrvOnKeyUp := CreateKeyObserver(Canvas.Renderer.EventKeyUp, KeyUp);
    ObsrvOnKeyPress := CreateKeyObserver(Canvas.Renderer.EventKeyPress, KeyPress);
  end else
  begin
    ObsrvOnKeyDown := nil;
    ObsrvOnKeyUp := nil;
    ObsrvOnKeyPress := nil;
    ObsrvMouseScroll := nil;
  end;
end;

function TBScrolledWindowCustom.GetScrolledArea: TVec2i64;
begin
  Result.x := FScrollBarHor.Size;
  Result.y := FScrollBarVert.Size;
end;

procedure TBScrolledWindowCustom.KeyDown(const Data: BKeyData);
begin

end;

procedure TBScrolledWindowCustom.KeyPress(const Data: BKeyData);
begin

end;

procedure TBScrolledWindowCustom.KeyUp(const Data: BKeyData);
begin

end;

procedure TBScrolledWindowCustom.ScrollTo(X, Y: Int64);
begin
  if (X < 0) then
    X := 0;
  if (Y < 0) then
    Y := 0;

  if (FScrollBarHor.Position = X) then
    FScrollBarVert.Position := Y
  else
  if (FScrollBarVert.Position = Y) then
    FScrollBarHor.Position := X
  else
  begin
    { prevent twice update event }
    BeginUpdate;
    try
      FScrollBarHor.Position := X;
    finally
      EndUpdate;
    end;
    FScrollBarVert.Position := Y;
  end;
end;

procedure TBScrolledWindowCustom.SetAlign(const Value: TObjectAlign);
begin
  inherited;
  UpdateScrolledSpaceSize;
  CheckSizeScrollBars;
end;

procedure TBScrolledWindowCustom.SetAutoResizeScrollingArea(AValue: boolean
  );
begin
  if FAutoResizeScrollingArea = AValue then
    exit;
  FAutoResizeScrollingArea := AValue;
  CheckScrollingArea;
end;

procedure TBScrolledWindowCustom.SetColorBorder(const Value: TGuiColor);
begin
  if Assigned(Border) then
    Border.Color := ColorByteToFloat(Value, true);
end;

procedure TBScrolledWindowCustom.DoChangePos;
begin
  FOwnerInstances.Position2d := vec2(-FScrollBarHor.Position, -FScrollBarVert.Position);

  if Assigned(FSpaceTree) then
  begin
    FSpaceTree.ViewPort(
      FPosition.x/FOwnerInstances.Data.Scale.x,
      FPosition.y/FOwnerInstances.Data.Scale.x,
      Width/FOwnerInstances.Data.Scale.x,
      Height/FOwnerInstances.Data.Scale.x
    );
  end;

  if Assigned(FOnChangePosition) then
    FOnChangePosition(Self, vec2d(FScrollBarHor.Position, FScrollBarVert.Position));
end;

procedure TBScrolledWindowCustom.DoAfterScale;
begin
  inherited DoAfterScale;
  if Assigned(Border) then
  begin
    Border.Size := vec2(FClipObject.Width+FBorder.WidthLine*2, FClipObject.Height+FBorder.WidthLine*2);
    Border.Build;
    FBorder.Position2d := vec2(-round(FBorder.WidthLine*0.5), -round(FBorder.WidthLine*0.5));
  end;
  //FScrollBarHor.DoScaling;
  //FScrollBarVert.DoScaling;
  CheckSizeScrollBars;
  if Assigned(FSpaceTree) then
  begin
    FSpaceTree.ViewPort(
      FPosition.x/FOwnerInstances.Data.Scale.x,
      FPosition.y/FOwnerInstances.Data.Scale.x,
      Width/FOwnerInstances.Data.Scale.x,
      Height/FOwnerInstances.Data.Scale.x
    );
  end;
end;

procedure TBScrolledWindowCustom.SetVisible(const Value: boolean);
begin
  inherited;
  FClipObject.Data.Interactive := Value;
  if Assigned(FBorder) then
    FBorder.Data.Hidden := not Value;

  if Value then
  begin
    if FScrollBarHor.SliderIsHide then
      FScrollBarHor.Visible := false;
    if FScrollBarVert.SliderIsHide then
      FScrollBarVert.Visible := false;
  end else
  begin
    FScrollBarHor.Visible := false;
    FScrollBarVert.Visible := false;
  end;
end;

procedure TBScrolledWindowCustom.UpdateScrolledSpaceSize;
begin
  if Assigned(FSpaceTree) then
  begin
    FSpaceTree.ViewPort(FPosition.x/FOwnerInstances.Data.Scale.x, FPosition.y/FOwnerInstances.Data.Scale.x,
      Width/FOwnerInstances.Data.Scale.x, Height/FOwnerInstances.Data.Scale.x);
  end;
end;

procedure TBScrolledWindowCustom.SetOpacity(const Value: int32);
begin
  FOpacity := Value;
  if FClipObject <> nil then
    FClipObject.Data.Opacity := FOpacity*0.01;
end;

function TBScrolledWindowCustom.GetColorBorder: TGuiColor;
begin
  if Assigned(Border) then
    Result := ColorFloatToByte(Border.Color).value
  else
    Result := ColorFloatToByte(BS_CL_MED_GRAY).value;
end;

class function TBScrolledWindowCustom.GetNextLayer: int32;
begin
  Result := CurrentLayer;
  inc(CurrentLayer);
  CurrentLayer := CurrentLayer mod round(TBlackSharkFrustum.MAX_COUNT_LAYERS);
end;

procedure TBScrolledWindowCustom.AfterConstruction;
begin
  inherited;
  inherited DropControl(FScrollBarVert, FClipObject);
  inherited DropControl(FScrollBarHor, FClipObject);
end;

procedure TBScrolledWindowCustom.BeforeDestruction;
begin
  ObsrvMouseDown := nil;
  ObsrvMouseMove := nil;
  ObsrvMouseUp := nil;
  ObsrvMouseScroll := nil;
  ObsrvDropInst := nil;
  inherited BeforeDestruction;
end;

procedure TBScrolledWindowCustom.BeginUpdate;
begin
  inc(UpdateCounter);
end;

procedure TBScrolledWindowCustom.BorderCreate;
begin
  if Border = nil then
  begin
    FBorder := TRectangle.Create(FCanvas, FClipObject);
    FBorder.Position2d := vec2(-1.0, -1.0);
    FBorder.Color := BS_CL_MED_GRAY;
    FBorder.Data.Interactive := false;
    FBorder.WidthLine := round(1.0*ToHiDpiScale);
    //FBorder.FixedWidthLine := true;
    FBorder.BanScalableMode := true;
    FBorder.Layer2d := FScrollBarHor.MainBody.Layer2d + 1;
    //FBorder.Align := TObjectAlign.oaClient;
  end;
end;

procedure TBScrolledWindowCustom.DrawClipArea(Instance: PRendererGraphicInstance);
begin
  { fill shape FClipObject as the stencil for ban draw outside him }
  glClear ( GL_STENCIL_BUFFER_BIT );
  glClearStencil ( 0 );
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  //glColorMask(0,0,0,0);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
  //glColorMask(1,1,1,1);
  //glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
end;

procedure TBScrolledWindowCustom.DropControl(Control: TBControl; Parent: TCanvasObject);

  procedure SetStencil(Item: TGraphicObject);
  var
    i: int32;
  begin
    Item.StencilTest := true;
    for i := 0 to Item.ChildrenCount - 1 do
      Item.Child[i].StencilTest := true;
  end;

begin
  inherited DropControl(Control, Parent);
  if Control.Canvas <> Control.Canvas then
    SetStencil(Control.MainBody.Data);
  if AutoResizeScrollingArea then
    CheckScrollingArea;
end;

{procedure TBScrolledWindowCustom.DropScrollBar(ScrollBar: TBScrollBar);
begin
  inherited DropControl(ScrollBar, FClipObject);
end; }

procedure TBScrolledWindowCustom.EndUpdate;
begin
  dec(UpdateCounter);
end;

procedure TBScrolledWindowCustom.CheckScrollingArea;
begin
  if Assigned(FSpaceTree) and (FUseSpaceTree) then
    CheckScrollingAreaByTree
  else
    CheckScrollingAreaByList;
end;

procedure TBScrolledWindowCustom.CheckScrollingAreaByList;

var
  sa: TVec2i64;

  procedure CheckObj(co: TCanvasObject);
  var
    ar: TVec2i64;
    obj: TGraphicObject;
    i: int32;
  begin
    ar := TVec2i64(co.Position2d + vec2(co.Width, co.Height));
    if ar.x > sa.x then
      sa.x := ar.x;
    if ar.y > sa.y then
      sa.y := ar.y;
    for i := 0 to co.Data.ChildrenCount - 1 do
    begin
      obj := co.Data.Child[i];
      if (obj.TagInt = ckGUI) or (obj.Hidden) or not (obj.Owner is TCanvasObject) then
        continue;
      CheckObj(TCanvasObject(obj.Owner));
    end;
  end;

var
  obj: TGraphicObject;
  i, j: int32;
  cntrl: TBControl;
begin
  sa := vec2(Int64(0), Int64(0));
  for i := 0 to MainBody.Data.ChildrenCount - 1 do
  begin
    obj := MainBody.Data.Child[i];
    if (obj.TagInt = ckGUI) or (obj.Hidden) or not (obj.Owner is TCanvasObject) then
      continue;
    CheckObj(TCanvasObject(obj.Owner));
  end;

  for i := 0 to ControlsCount - 1 do
  begin
    cntrl := Control[i];
    if (cntrl = FScrollBarHor) or (cntrl = FScrollBarVert) or (cntrl.Canvas = Canvas) then
      continue;
    for j := 0 to cntrl.Canvas.RootObject.ChildrenCount - 1 do
    begin
      obj := cntrl.Canvas.RootObject.Child[j];
      if (obj.Hidden) or not (obj.Owner is TCanvasObject) then
        continue;
      CheckObj(TCanvasObject(obj.Owner));
    end;
  end;
  ScrolledArea := sa;
end;

procedure TBScrolledWindowCustom.CheckScrollingAreaByTree;
begin
  inherited;
  ScrolledArea := TVec2i64(vec2d(FSpaceTree.Root.BB.x_max, FSpaceTree.Root.BB.y_max));
end;

procedure TBScrolledWindowCustom.CheckSizeScrollBars;
var
  hh, wv: BSFloat;
  work_area_height: BSFloat;
  work_area_width: BSFloat;
begin
  work_area_height := FClipObject.Height - FScrollBarsPaddingTop - FScrollBarsPaddingBottom;
  work_area_width := FClipObject.Width - FScrollBarsPaddingLeft - FScrollBarsPaddingRight;
  if Canvas.Scalable then
  begin
    hh := WidthScrollBars;
    wv := hh;
    work_area_height := work_area_height*Canvas.ScaleInv;
    work_area_width := work_area_width*Canvas.ScaleInv;
  end else
  begin
    hh := FScrollBarHor.Height;
    wv := FScrollBarVert.Width;
  end;

  FScrollBarHor.Resize(hh, work_area_width);

  if FScrollBarHor.SliderIsHide then
  begin
    if FScrollBarHor.Visible then
      FScrollBarHor.Visible := false;
  end else
  if not FScrollBarHor.Visible then
    FScrollBarHor.Visible := true;

  FScrollBarVert.Resize(wv, work_area_height);

  if FScrollBarVert.SliderIsHide then
  begin
    if FScrollBarVert.Visible then
      FScrollBarVert.Visible := false;
    FScrollBarHor.Resize(hh, work_area_width);
    if FScrollBarHor.SliderIsHide then
      FScrollBarHor.Visible := false;
  end else
  begin
    if not FScrollBarVert.Visible then
      FScrollBarVert.Visible := true;

    if FScrollBarHor.Visible then
    begin
      FScrollBarHor.Resize(hh, work_area_width - wv);
      FScrollBarVert.Resize(wv, work_area_height - hh);
    end;
  end;

  FScrollBarVert.Position2d := vec2(FClipObject.Width - FScrollBarVert.Width - FScrollBarsPaddingRight, FScrollBarsPaddingTop);
  FScrollBarHor.Position2d := vec2(FScrollBarsPaddingLeft, FClipObject.Height - FScrollBarsPaddingBottom - FScrollBarHor.Height);
end;

procedure TBScrolledWindowCustom.ChangeScrollHor(ScrollBar: TBScrollBar);
begin
  FPosition := vec2d(FScrollBarHor.Position, FScrollBarVert.Position);
  DoChangePos;
end;

procedure TBScrolledWindowCustom.ChangeScrollVer(ScrollBar: TBScrollBar);
begin
  FPosition := vec2d(FScrollBarHor.Position, FScrollBarVert.Position);
  DoChangePos;
end;

procedure TBScrolledWindowCustom.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
  FScrollBarHor.Scalable := Value;
  FScrollBarVert.Scalable := Value;
end;

procedure TBScrolledWindowCustom.SetScrollBarsPaddingBottom(const Value: BSFloat);
begin
  FScrollBarsPaddingBottom := Value;
  BuildView;
end;

procedure TBScrolledWindowCustom.SetScrollBarsPaddingLeft(const Value: BSFloat);
begin
  FScrollBarsPaddingLeft := Value;
  BuildView;
end;

procedure TBScrolledWindowCustom.SetScrollBarsPaddingRight(const Value: BSFloat);
begin
  FScrollBarsPaddingRight := Value;
  BuildView;
end;

procedure TBScrolledWindowCustom.SetScrollBarsPaddingTop(const Value: BSFloat);
begin
  FScrollBarsPaddingTop := Value;
  BuildView;
end;

procedure TBScrolledWindowCustom.SetScrolledArea(const AValue: TVec2i64);
begin
  if (FScrollBarHor.Size = AValue.x) and (FScrollBarVert.Size = AValue.y) or (AValue.y < 0) or (AValue.x < 0) then
    exit;

  FScrollBarHor.Size := AValue.x;
  FScrollBarVert.Size := AValue.y;
  FPosition := vec2d(FScrollBarHor.Position, FScrollBarVert.Position);

  CheckSizeScrollBars;
  //BuildView;
end;

procedure TBScrolledWindowCustom.SetShowBorder(const Value: boolean);
begin
  if FShowBorder = Value then
    exit;
  FShowBorder := Value;
  if FShowBorder then
    BorderCreate
  else
    FreeAndNil(FBorder);
end;

procedure TBScrolledWindowCustom.SetSpaceTreeClass(const Value: TBlackSharkSpaceTreeClass);
begin
  if FSpaceTreeClass = Value then
    exit;
  FSpaceTreeClass := Value;
  CreateSpaceTree;
end;

procedure TBScrolledWindowCustom.SetUseSpaceTree(const Value: boolean);
begin
  if FUseSpaceTree = Value then
    exit;
  FUseSpaceTree := Value;
  if FUseSpaceTree then
    CreateSpaceTree
  else
  if FSpaceTree <> nil then
    FreeAndNil(FSpaceTree);
end;

procedure TBScrolledWindowCustom.OnDropInstance(const Data: BDragDropData);
begin
  if FAutoResizeScrollingArea and (PGraphicInstance(Data.BaseHeader.Instance).Owner.TagInt <> ckGUI) then
    CheckScrollingArea;
end;

procedure TBScrolledWindowCustom.MouseDown(const Data: BMouseData);
begin
  FIsMouseDown := true;
  MouseDownPos := vec2(Data.X, Data.Y);
  ButtonMouseDown := Data.Button;
  PosMouseDown := Position;
  if not Focused then
    Focused := true;
end;

procedure TBScrolledWindowCustom.MouseEnter(const Data: BMouseData);
begin
end;

procedure TBScrolledWindowCustom.MouseLeave(const Data: BMouseData);
begin
end;

procedure TBScrolledWindowCustom.MouseMove(const Data: BMouseData);
var
  delta: TVec2d;
begin
  if FAllowDragWindowOverData and FIsMouseDown and (TBSMouseButton.mbBsLeft in ButtonMouseDown) then
  begin
    delta.x := Data.X;
    delta.y := Data.Y;
    delta := delta - MouseDownPos;
    if (delta.x <> 0.0) or (delta.y <> 0.0) then
      Position := PosMouseDown + delta;//*2.0;
  end;
end;

procedure TBScrolledWindowCustom.MouseScroll(const Data: BMouseData);
var
  delta: TVec2d;
  d: BSFloat;
begin
  if FCanvas.Renderer.HitTestInstance(Data.X, Data.Y, FClipObject.Data.BaseInstance, d) then
  begin
    if ssCtrl in Data.ShiftState then
      delta := vec2(-Data.DeltaWeel, 0.0)
    else
      delta := vec2(0.0, -Data.DeltaWeel);
    if ((delta.x <> 0.0) and (ScrollBarHor.Visible)) or ((delta.y <> 0.0) and (FScrollBarVert.Visible)) then
      Position := FPosition + delta;
  end;
end;

procedure TBScrolledWindowCustom.MouseUp(const Data: BMouseData);
begin
  FIsMouseDown := false;
end;

procedure TBScrolledWindowCustom.OnCreateCanvasObject(const AData: BData);
begin
  if not (csInitializing in FControlState) then
  begin
    if TCanvasObject(AData.Instance).HasAncestor(FClipObject) then
      TCanvasObject(AData.Instance).Data.StencilTest := true;
    if FAutoResizeScrollingArea then
      CheckScrollingArea;
  end;
end;

{ TBFormCustom }

procedure TBFormCustom.OnMouseClickOnScreen(const Data: BMouseData);
var
  level: int32;
begin
  level := 0;
  if ModalMode then
  begin
    { a top-level form? }
    if FClipObject.Data.ModalLevel = level then
    begin
      { a user miss - run animation: I'm here! }

    end;
  end else
  if Assigned(Data.BaseHeader.Instance) then
  begin
    level := high(int32) - FCanvas.Renderer.ModalLevel;
    { the mouse clicked on the form or him a child component? }
    if PGraphicInstance(Data.BaseHeader.Instance).Owner.IsAncestor(FClipObject.Data, true) then
    begin
      if FClipObject.Data.ModalLevel <> level then
      begin
        FClipObject.Layer2d := FClipObject.Layer2d + 1;
        FClipObject.Data.ModalLevel := level;
      end;
    end else
    if FClipObject.Data.ModalLevel = level then
    begin
      if FClipObject.Layer2d > 0 then
        FClipObject.Layer2d := FClipObject.Layer2d - 1;
      FClipObject.Data.ModalLevel := level - 1;
    end;
  end;
end;

procedure TBFormCustom.OnMouseDownCaptionHeader(const Data: BMouseData);
begin
  FObsrvMoveCaptionHeader := Canvas.Renderer.EventMouseMove.CreateObserver(GUIThread, OnMouseMoveCaptionHeader);
  PosMouseDownCaptionHeader := vec2(Data.X, Data.Y);
  PositionWhenMouseDownCaptionHeader := Position2d;
  Focused := true;
  if Assigned(FOnBeginDrag) then
    FOnBeginDrag(Self);
end;

procedure TBFormCustom.OnMouseEnterButtonHeader(const Data: BMouseData);
begin
  AniLawBtnOpacity.StartValue := 0.0;
  AniLawBtnOpacity.StopValue := 0.8;
  AniLawBtnOpacity.Run;
end;

procedure TBFormCustom.OnMouseLeaveButtonHeader(const Data: BMouseData);
begin
  AniLawBtnOpacity.Stop;
  AniLawBtnOpacity.StartValue := FButtonOnHeader.Data.Opacity;
  AniLawBtnOpacity.StopValue := 0.0;
  AniLawBtnOpacity.Run;
end;

procedure TBFormCustom.OnMouseMoveCaptionHeader(const Data: BMouseData);
var
  delta: TVec2f;
begin
  delta := (vec2(Data.X, Data.Y) - PosMouseDownCaptionHeader);
  Position2d := PositionWhenMouseDownCaptionHeader + delta;
  if Assigned(FOnDrag) then
    FOnDrag(Self);
end;

procedure TBFormCustom.OnMouseDownButtonHeader(const Data: BMouseData);
begin
  FButtonOnHeader.Data.Opacity := 1.0;
end;

procedure TBFormCustom.OnMouseUpButtonHeader(const Data: BMouseData);
begin
  Close;
end;

procedure TBFormCustom.OnMouseUpCaptionHeader(const Data: BMouseData);
begin
  FObsrvMoveCaptionHeader := nil;
end;

procedure TBFormCustom.SetCaptionHeader(const AValue: string);
begin
  FCaptionHeaderText := AValue;
  if Assigned(FCaptionHeader) then
  begin
	  FCaptionHeader.Text := AValue;
    FCaptionHeader.Position2d := vec2((Width - FCaptionHeader.Width)*0.5 - 1.0, (FHeaderHeight - FCaptionHeader.Height)*0.5);
  end;
end;

procedure TBFormCustom.SeTGuiColorCaptionHeader(const Value: TGuiColor);
begin
  FColorCaptionHeader := Value;
  if Assigned(FFormHeader) then
    FCaptionHeader.Color := ColorByteToFloat(FColorCaptionHeader);
end;

procedure TBFormCustom.SetGuiColorHeader(const Value: TGuiColor);
begin
  FColorHeader := Value;
  if Assigned(FFormHeader) then
    FFormHeader.Color := ColorByteToFloat(FColorHeader);
end;

procedure TBFormCustom.SetHeaderHeight(const Value: BSFloat);
begin
  if HeaderHeight = Value then
    exit;
  FHeaderHeight := Value;
  FScrollBarsPaddingTop := FHeaderHeight;
  BuildCaptionHeader;
  BuildButtonOnHeader;
end;

procedure TBFormCustom.SetVisible(const Value: boolean);
begin
  inherited SetVisible(Value);
  if Assigned(FFormHeader) then
  begin
    FFormHeader.Data.Hidden := not Value;
    FFormHeader.Data.Interactive := Value;
    FCaptionHeader.Data.Hidden := not Value;
    if Assigned(FButtonOnHeader) then
    begin
      FButtonOnHeader.Data.Hidden := not Value;
      FButtonOnHeader.Data.Interactive := Value;
      FCloseCross.Data.Hidden := not Value;
    end;
  end;
  if Value then
  begin
    FObsrvClickSrceen := FCanvas.Renderer.EventMouseDown.CreateObserver(GUIThread, OnMouseClickOnScreen);
    if ModalMode then
      FCanvas.Renderer.ModalLevelInc
    else
      FClipObject.Data.ModalLevel := high(int32) - FCanvas.Renderer.ModalLevel;
    FClipObject.Layer2d := FCanvas.Renderer.ModalLevel;
    if Assigned(FOnShow) then
      FOnShow(Self);
  end else
  begin
    FObsrvClickSrceen := nil;
    if ModalMode then
      FCanvas.Renderer.ModalLevelDec;
    if Assigned(FOnClose) then
      FOnClose(Self);
  end;
end;

procedure TBFormCustom.SetScalable(const Value: boolean);
begin
  inherited;
end;

procedure TBFormCustom.SetShowCloseButtonOnHeader(const Value: boolean);
begin
  if FShowCloseButtonOnHeader = Value then
    exit;
  FShowCloseButtonOnHeader := Value;
  if FShowCloseButtonOnHeader then
  begin
    if FShowHeader then
    begin
      CreateButtonOnHeader;
      BuildButtonOnHeader;
    end;
  end else
    FreeButtonHeader;
end;

procedure TBFormCustom.SetShowHeader(const Value: boolean);
begin
  if FShowHeader = Value then
    exit;
  FShowHeader := Value;
  if Value then
  begin
    CreateCaptionHeader;
    BuildCaptionHeader;
    if FShowCloseButtonOnHeader then
    begin
      CreateButtonOnHeader;
      FButtonOnHeader.Build;
    end;
  end else
    FreeCaptionHeader;
end;

procedure TBFormCustom.AniChangeBtnOpacity(const Data: BSFloat);
begin
  FButtonOnHeader.Data.Opacity := Data;
end;

procedure TBFormCustom.BuildButtonOnHeader;
var
  scaledFour: BSFloat;
begin
  scaledFour := round(4*ToHiDpiScale);
  FButtonOnHeader.Size := vec2(FFormHeader.Size.Height, FFormHeader.Size.Height);
  FButtonOnHeader.Build;
  FCloseCross.Clear;
  FCloseCross.AddLine(scaledFour, scaledFour, FButtonOnHeader.Size.x - scaledFour, FButtonOnHeader.Size.y - scaledFour);
  FCloseCross.AddLine(FButtonOnHeader.Size.x - scaledFour, scaledFour, scaledFour, FButtonOnHeader.Size.y - scaledFour);
  FCloseCross.Build;
  FCloseCross.Position2d := vec2(scaledFour, scaledFour);
end;

procedure TBFormCustom.BuildCaptionHeader;
begin
  FFormHeader.Size := vec2(Width, FHeaderHeight); // - 2
  FFormHeader.Build;
  FFormHeader.Position2d := vec2(0.0, 0.0);
  FCaptionHeader.Position2d := vec2((Width - FCaptionHeader.Width) * 0.5 - round(1.0*ToHiDpiScale), (FHeaderHeight - FCaptionHeader.Height) * 0.5);
end;

procedure TBFormCustom.BuildView;
begin
  inherited;
  if FShowHeader then
  begin
    BuildCaptionHeader;
    if FShowCloseButtonOnHeader then
      BuildButtonOnHeader;
  end;
end;

procedure TBFormCustom.Close;
begin
  Visible := false;
end;

constructor TBFormCustom.Create(ACanvas: TBCanvas);
begin
  inherited;
  FHeaderHeight := round(DEF_CAPTION_HEADER_PLANE_HEIGHT*ToHiDpiScale);
  FColorHeader := TGuiColor($FF8E6535);
  FColorCaptionHeader := TGuiColor($FFFFFFFF);
  Canvas.Font.SizeInPixels := round(9*ToHiDpiScale);
  FShowHeader := true;
  FShowCloseButtonOnHeader := true;
  if FShowHeader then
  begin
    CreateCaptionHeader;
    if FShowCloseButtonOnHeader then
      CreateButtonOnHeader;
  end;
end;

procedure TBFormCustom.CreateButtonOnHeader;
begin
  FButtonOnHeader := TRectangle.Create(Canvas, FFormHeader);
  FButtonOnHeader.Fill := true;
  FButtonOnHeader.Align := TObjectAlign.oaRight;
  FButtonOnHeader.Data.Opacity := 0.0;
  FButtonOnHeader.Color := BS_CL_RED;
  FButtonOnHeader.AnchorsReset;
  FButtonOnHeader.Anchors[TAnchor.aLeft] := false;
  FButtonOnHeader.Anchors[TAnchor.aRight] := true;
  FButtonOnHeader.Anchors[TAnchor.aTop] := true;
  FButtonOnHeader.Anchors[TAnchor.aBottom] := false;
  FObsrvBtnCloseEnter := CreateMouseObserver(FButtonOnHeader.Data.EventMouseEnter, OnMouseEnterButtonHeader);
  FObsrvBtnCloseDown := CreateMouseObserver(FButtonOnHeader.Data.EventMouseDown, OnMouseDownButtonHeader);
  FObsrvBtnCloseUp := CreateMouseObserver(FButtonOnHeader.Data.EventMouseUp, OnMouseUpButtonHeader);
  FObsrvBtnCloseLeave := CreateMouseObserver(FButtonOnHeader.Data.EventMouseLeave, OnMouseLeaveButtonHeader);
  AniLawBtnOpacity := CreateAniFloatLinear(GUIThread);
  AniLawBtnOpacity.Duration := 300;
  ObsrvAniLawBtnOpacity := CreateAniFloatLivearObsrv(AniLawBtnOpacity, AniChangeBtnOpacity, GUIThread);
  FCloseCross := TLines.Create(Canvas, FButtonOnHeader);
  FCloseCross.Data.Interactive := false;
  FCloseCross.Color := BS_CL_WHITE;
  FCloseCross.LinesWidth := round(1*ToHiDpiScale);
  //FCloseCross.Color2 := BS_CL_GRAY;
end;

procedure TBFormCustom.CreateCaptionHeader;
begin
  FFormHeader := TRectangle.Create(Canvas, MainBody);
  FFormHeader.Fill := true;
  FFormHeader.Data.DragResolve := false;
  FFormHeader.Color := ColorByteToFloat(FColorHeader);
  FFormHeader.Layer2d := ScrollBarHor.MainBody.Layer2d;
  //FFormHeader.Align := TObjectAlign.oaTop;

  FCaptionHeader :=  TCanvasText.Create(FCanvas, FFormHeader);
  FCaptionHeader.Text := 'Form';
  FCaptionHeader.Color := ColorByteToFloat(FColorCaptionHeader);
  FCaptionHeader.Align := TObjectAlign.oaCenter;

  FCaptionHeader.Data.Interactive := false;
  FScrollBarsPaddingTop := FHeaderHeight;
  FObsrvDownCaptionHeader := FFormHeader.Data.EventMouseDown.CreateObserver(GUIThread, OnMouseDownCaptionHeader);
  FObsrvUpCaptionHeader := FFormHeader.Data.EventMouseUp.CreateObserver(GUIThread, OnMouseUpCaptionHeader);
end;

destructor TBFormCustom.Destroy;
begin
  FreeButtonHeader;
  FreeCaptionHeader;
  FObsrvDownCaptionHeader := nil;
  FObsrvUpCaptionHeader := nil;
  FObsrvClickSrceen := nil;
  inherited Destroy;
end;

procedure TBFormCustom.FreeButtonHeader;
begin
  FObsrvBtnCloseEnter := nil;
  FObsrvBtnCloseLeave := nil;
  AniLawBtnOpacity := nil;
  ObsrvAniLawBtnOpacity := nil;
  FObsrvBtnCloseDown := nil;
  FObsrvBtnCloseUp := nil;
  FreeAndNil(FCloseCross);
  FreeAndNil(FButtonOnHeader);
end;

procedure TBFormCustom.FreeCaptionHeader;
begin
  FreeButtonHeader;
  FObsrvDownCaptionHeader := nil;
  FObsrvUpCaptionHeader := nil;
  FreeAndNil(FButtonOnHeader);
  FreeAndNil(FCaptionHeader);
  FreeAndNil(FFormHeader);
  FScrollBarsPaddingTop := 0;
end;

procedure TBFormCustom.KeyPress(const Data: BKeyData);
begin
  inherited;
  if (Data.Key = VK_BS_F4) and (ssCtrl in Data.Shift) then
    Close;
end;

procedure TBFormCustom.ShowModal;
begin
  if Visible then
    exit;
  ModalMode := true;
  Visible := true;
end;

procedure TBFormCustom.Show;
begin
  if Visible then
    exit;
  ModalMode := false;
  Visible := true;
end;

initialization
  TBScrolledWindowCustom.CurrentLayer := 1;
  TBControl.ControlRegister('GUI', TBScrolledWindow);
  TBControl.ControlRegister('GUI', TBForm);

end.

