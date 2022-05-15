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


{$ifdef fpc}
  {$WARN 5024 off : Parameter "$1" not used}
{$endif}

{$I BlackSharkCfg.inc}

unit bs.gui.base;

interface

uses
    SysUtils
  , bs.basetypes
  , bs.obj
  , bs.events
  , bs.collections
  , bs.align
  , bs.renderer
  , bs.scene
  , bs.canvas
  , bs.texture
  , bs.gui.themes
  ;

type

  TKindCanvasObject = int32;

const
  ckUncknown: TKindCanvasObject = 0;
  ckGUI: TKindCanvasObject      = 1;

type

  TBControl          = class;
  TBControlClass     = class of TBControl;
  TBiDirListControls = TListDual<TBControl>;

  TBControlNotify    = procedure(ASender: TObject) of object;
  TMouseEventNotify  = procedure(ASender: TObject; const AMouseData: BMouseData) of object;
  TKeyEventNotify    = procedure(ASender: TObject; const AKeyData: BKeyData) of object;

  TControlBehavior = class
  protected
    FCanvasObject: TCanvasObject;
    procedure SetCanvasObject(const Value: TCanvasObject); virtual;
  public
    constructor Create(ACanvasObject: TCanvasObject);
    property CanvasObject: TCanvasObject read FCanvasObject write SetCanvasObject;
  end;

  { TGroupControls }

  TGroupControls = class
  private
    FControls: TListVec<TBControlClass>;
    FName: string;
    function GetControl(Index: int32): TBControlClass;
    function GetCount: int32;
   public
    constructor Create(const AName: string);
    destructor Destroy; override;
    procedure Add(ControlClass: TBControlClass);
    property Name: string read FName;
    property Control[Index: int32]: TBControlClass read GetControl;
    property Count: int32 read GetCount;
  end;

  { like TPersistent }

  {$M+}

  TGUIProperties = class
  private
  protected
    function GetOwner: TGUIProperties; dynamic;
  public
    procedure AfterConstruction; override;
    { load of default published properties from current Theme of application (ThemeManager) }
    procedure LoadProperties; overload; virtual;
    procedure LoadProperties(FromTheme: TBTheme); overload;
    { properties from its group of a style }
    procedure LoadProperties(Properties: TStyleGroup); overload; virtual;
    procedure SaveProperties(CreateStyleIfNotExists: boolean); overload;
    function SaveProperties(const URL: AnsiString; ToTheme: TBTheme; CreateStyleIfNotExists: boolean): TStyleGroup; overload;
    procedure SaveProperties(Properties: TStyleGroup); overload; virtual;
    procedure Copy(Source: TGUIProperties);
    function GetPath: AnsiString; dynamic;
  end;

  {TGUIPropertiesClass = class of TGUIProperties;

  TFactoryOfGUI = class abstract
  private
    function GetCountGUI: int32;
    function GetGUIClasses(Index: int32): TGUIPropertiesClass;
  protected
    FGUIClasses: TListVec<TGUIPropertiesClass>;
  public
    constructor Create;
    destructor Destroy; override;
    class function FactoryName: string; virtual; abstract;
    procedure RegisterGUI(GUIClass: TGUIPropertiesClass);
    function CreateGUI(Index: int32; Scene: TBScene): TGUIProperties; virtual; abstract;
    property CountGIU: int32 read GetCountGUI;
    property GUIClasses[Index: int32]: TGUIPropertiesClass read GetGUIClasses;
  end;

  TFactoriesManager = class
  private
    class var FFactories: TListVec<TFactoryOfGUI>;
    class function GetCountFactories: int32; static;
    class function GetFactories(Index: int32): TFactoryOfGUI; static;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure RegisterFactory(Factory: TFactoryOfGUI);
    class property CountFactories: int32 read GetCountFactories;
    class property Factories[Index: int32]: TFactoryOfGUI read GetFactories;
  end;

  TFactoryOfControls = class(TFactoryOfGUI)
  private
    class var Instance: TFactoryOfControls;
  public
    class function NewInstance: TObject; override;
    class function FactoryName: string; override;
    function CreateGUI(Index: int32; Scene: TBScene): TGUIProperties; override;
  end;}

  TControlState = (csInitializing, csReleasing);

  TControlStates = set of TControlState;

  {$M+}

  { TBControl }

  TBControl = class (TGUIProperties)
  private
    class var FEventFocusChanged: IBFocusEvent;
    { all registred controls }
    class var RegistredControls: TListVec<TGroupControls>;
    class constructor Create;
    class destructor Destroy;
  private

    FControls: TBiDirListControls;
    FEnabled: boolean;
    FFocused: boolean;
    FParentControl: TBControl;
    _Position: TBiDirListControls.PListItem;
    FTagInt: NativeInt;
    FTagPtr: Pointer;
    FHint: string;
    FParentColor: boolean;
    FVisible: boolean;


    ObsrvAfterScale: TCanvasEventObserver;
    ObsrvFocus: IBFocusEventObserver;
    ObsrvCreateCanvasObject: TCanvasEventObserver;
    ObsrvFreeCanvasObject: TCanvasEventObserver;
    ObsrvChangeCanvasFont: TCanvasEventObserver;

    FOwnCanvas: boolean;
    FEventFocusLeaveEnter: IBFocusEvent;
    function GetControlsCount: int32;
    function GetControl(index: int32): TBControl;
    procedure SetParentControl(AValue: TBControl);
    function GetAnchor(Index: TAnchor): boolean;
    function GetCountAnchors: int8;
    function GetPosition2d: TVec2f;
    function GetFontName: string;
    procedure SetFontName(const Value: string);
    procedure OnCaptureFocusByOtherControl(const Data: BFocusEventData);
    procedure SetHeight(const Value: BSFloat);
    procedure SetWidth(const Value: BSFloat);
    procedure SetParentColor(const Value: boolean);
    function GetScalable: boolean;
    function GetLeft: BSFloat;
    procedure SetLeft(const Value: BSFloat);
    function GetTop: BSFloat;
    procedure SetTop(const Value: BSFloat);
    procedure OnAfterScale({%H-}const Data: BEmpty); virtual;
    function GetAlign: TObjectAlign;
  protected
    FCanvas: TBCanvas;
    FControlState: TControlStates;
    FMainBody: TCanvasObject;
    FColor: TGuiColor;
    function GetHeight: BSFloat; virtual;
    function GetWidth: BSFloat; virtual;
    procedure SetEnabled(const Value: boolean); virtual;
    procedure SetVisible(const Value: boolean); virtual;
    procedure SetHint(const Value: string); virtual;
    procedure SetAnchor(Index: TAnchor; const Value: boolean); virtual;
    procedure OnCreateCanvasObject(const AData: BData); virtual;
    procedure OnFreeCanvasObject(const AData: BData); virtual;
    procedure OnChangeCanvasFont(const AData: BData); virtual;
    function GetOwner: TGUIProperties; override;
    procedure SetFocused(Value: boolean); virtual;
    procedure SetColor(const AValue: TGuiColor); virtual;
    procedure SetScalable(const AValue: boolean); virtual;

    procedure DropControl(Control: TBControl); overload;
    procedure DropControl(Control: TBControl; Parent: TCanvasObject); overload; virtual;
    procedure RemoveControl(Control: TBControl);
    procedure DeleteControl(Control: TBControl);
    procedure SetPosition2d(const Value: TVec2f); virtual;
    function CreateMainBody(AClass: TCanvasObjectClass): TCanvasObject;
    procedure DoAfterScale; virtual;
    procedure SetAlign(const Value: TObjectAlign); virtual;
  public
    class var ControlEvents: IBOpCodeEvent;
    class procedure ControlRegister(const Group: string; ControlClass: TBControlClass);
    class function ControlGroupsRegistred: int32;
    class function ControlGroupGet(i: int32): TGroupControls;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); overload; virtual;
    constructor Create(ACanvas: TBCanvas); overload; virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    { the construction of the control of the entities (a view) created earlier with
      current properties }
    procedure BuildView; virtual; abstract;
    procedure Resize(AWidth, AHeight: BSFloat); virtual;
    { return default size }
    function DefaultSize: TVec2f; virtual;
    procedure ClearControls(FreeControls: boolean); virtual;
    property Canvas: TBCanvas read FCanvas;
    property MainBody: TCanvasObject read FMainBody;
    { position on parent }
    property Position2d: TVec2f read GetPosition2d write SetPosition2d;
    property Focused: boolean read FFocused write SetFocused;
    { TODO or not TODO? }
    property Enabled: boolean read FEnabled write SetEnabled;
    property Visible: boolean read FVisible write SetVisible;
    property Hint: string read FHint write SetHint;
    property ControlsCount: int32 read GetControlsCount;
    property Control[index: int32]: TBControl read GetControl;
    property ParentControl: TBControl read FParentControl write SetParentControl;
    { size of the control when read taken from a root object of the canvas,
      that is why you must redefine getters if your control size defined
      not a root object }
    property Width: BSFloat read GetWidth write SetWidth;
    property Height: BSFloat read GetHeight write SetHeight;
    property Anchors[Index: TAnchor]: boolean read GetAnchor write SetAnchor;
    property CountAnchors: int8 read GetCountAnchors;
    property ControlState: TControlStates read FControlState write FControlState;
    property OwnCanvas: boolean read FOwnCanvas;
    { for external use }
    property TagInt: NativeInt read FTagInt write FTagInt;
    property TagPtr: Pointer read FTagPtr write FTagPtr;

    property Scalable: boolean read GetScalable write SetScalable;
    property FontName: string read GetFontName write SetFontName;
    property Color: TGuiColor read FColor write SetColor;
    property ParentColor: boolean read FParentColor write SetParentColor;
    property Align: TObjectAlign read GetAlign write SetAlign;
    property Left: BSFloat read GetLeft write SetLeft;
    property Top: BSFloat read GetTop write SetTop;
    property EventFocusLeaveEnter: IBFocusEvent read FEventFocusLeaveEnter;
    // a common event for all controls
    class property EventFocusChanged: IBFocusEvent read FEventFocusChanged;
  end;

  TOnMouseColorExchanger = class(TControlBehavior)
  private
    ObsrvMouseEnter: IBMouseEnterEventObserver;
    ObsrvMouseLeave: IBMouseLeaveEventObserver;
    FIsMouseOver: boolean;
    procedure MouseEnter({%H-}const Data: BMouseData);
    procedure MouseLeave({%H-}const Data: BMouseData);
    procedure SetColor(const Value: TColor4f);
  protected
    FColorMouseEnter: TColor4f;
    FColor: TColor4f;
    procedure SetCanvasObject(const Value: TCanvasObject); override;
  public
    constructor Create(ACanvasObject: TCanvasObject);
    destructor Destroy; override;
    property Color: TColor4f read FColor write SetColor;
    property ColorMouseEnter: TColor4f read FColorMouseEnter write FColorMouseEnter;
    property IsMouseOver: boolean read FIsMouseOver;
  end;

  TOnMouseMoveAndClickColorExchanger = class(TOnMouseColorExchanger)
  private
    FColorMouseDown: TColor4f;
    ObsrvMouseDown: IBMouseDownEventObserver;
    ObsrvMouseUp: IBMouseUpEventObserver;
    procedure MouseDown({%H-}const Data: BMouseData);
    procedure MouseUp({%H-}const Data: BMouseData);
  protected
    procedure SetCanvasObject(const Value: TCanvasObject); override;
  public
    constructor Create(ACanvasObject: TCanvasObject);
    destructor Destroy; override;
    property ColorMouseDown: TColor4f read FColorMouseDown write FColorMouseDown;
  end;

  TOnMouseMoveAndClickTextureExchanger = class(TControlBehavior)
  private
    FTexture: PTextureArea;
    FTextureMouseDown: PTextureArea;
    FTextureMouseEnter: PTextureArea;
    FIsMouseDown: boolean;
    FIsMouseOver: boolean;
    ObsrvMouseEnter: IBMouseEnterEventObserver;
    ObsrvMouseLeave: IBMouseLeaveEventObserver;
    ObsrvMouseDown: IBMouseDownEventObserver;
    ObsrvMouseUp: IBMouseUpEventObserver;
    procedure MouseEnter({%H-}const Data: BMouseData);
    procedure MouseLeave({%H-}const Data: BMouseData);
    procedure MouseDown({%H-}const Data: BMouseData);
    procedure MouseUp({%H-}const Data: BMouseData);
    procedure SetTexture(const Value: PTextureArea);
  protected
    procedure SetCanvasObject(const Value: TCanvasObject); override;
  public
    constructor Create(ACanvasObject: TCanvasObject);
    destructor Destroy; override;
    property Texture: PTextureArea read FTexture write SetTexture;
    property TextureMouseEnter: PTextureArea read FTextureMouseEnter write FTextureMouseEnter;
    property TextureMouseDown: PTextureArea read FTextureMouseDown write FTextureMouseDown;
    property IsMouseDown: boolean read FIsMouseDown;
    property IsMouseOver: boolean read FIsMouseOver;
  end;

implementation

uses
    TypInfo
  , bs.scene.objects
  , bs.strings
  , bs.font
  , bs.thread
  ;

function GetHashCanvasObject(const Item: TCanvasObject): uint32; inline;
begin
  Result := GetHashBlackShark(PByte(Item), SizeOf(Item));
end;

function CanvasObjectComparator(const Item1, Item2: TCanvasObject): boolean; inline;
begin
  Result := Item1 = Item2;
end;

{ TGroupControls }

function TGroupControls.GetControl(Index: int32): TBControlClass;
begin
  Result := FControls.Items[Index];
end;

function TGroupControls.GetCount: int32;
begin
  Result := FControls.Count;
end;

constructor TGroupControls.Create(const AName: string);
begin
  FControls := TListVec<TBControlClass>.Create;
  FName := AName;
end;

destructor TGroupControls.Destroy;
begin
  FControls.Free;
  inherited Destroy;
end;

procedure TGroupControls.Add(ControlClass: TBControlClass);
begin
  FControls.Add(ControlClass);
end;

{ TBControl }

procedure TBControl.SetAlign(const Value: TObjectAlign);
begin
  if Assigned(FMainBody) then
    FMainBody.Align := Value;
end;

procedure TBControl.SetAnchor(Index: TAnchor; const Value: boolean);
begin
  if Assigned(FMainBody) then
    FMainBody.Anchors[Index] := Value;
end;

procedure TBControl.SetColor(const AValue: TGuiColor);
var
  i: int32;
begin
  FColor := AValue;

  if Assigned(FMainBody) then
    FMainBody.Color := TColor4f(AValue);

  for i := 0 to ControlsCount - 1 do
    if Control[i].ParentColor then
      Control[i].Color := AValue;
end;

procedure TBControl.SetEnabled(const Value: boolean);
var
  i: int32;
begin
  if FEnabled = Value then
    exit;
  FEnabled := Value;
  for i := 0 to ControlsCount - 1 do
    Control[i].Enabled := FEnabled;
end;

procedure TBControl.SetFocused(Value: boolean);
begin
  if FFocused = Value then
    exit;

  if not FVisible and Value then
    exit;

  FFocused := Value;
  if Assigned(FMainBody) then
    FEventFocusChanged.Send(FMainBody.Data.BaseInstance, Self, FFocused, FCanvas.ModalLevel);
  if FFocused then
  begin
    ObsrvFocus := CreateFocusObserver(FEventFocusChanged, OnCaptureFocusByOtherControl);
  end else
  begin
    ObsrvFocus := nil;
  end;
  FEventFocusLeaveEnter.Send(FMainBody.Data.BaseInstance, Self, FFocused, FCanvas.ModalLevel);
end;

procedure TBControl.SetFontName(const Value: string);
var
  f: IBlackSharkFont;
begin
  if Value = FCanvas.Font.Name then
    exit;
  f := BSFontManager.Font[Value];
  if not Assigned(f) then
    exit;
  FCanvas.Font := f;
end;

procedure TBControl.SetHeight(const Value: BSFloat);
begin
  Resize(Width, Value);
end;

procedure TBControl.SetVisible(const Value: boolean);
var
  i: int32;
begin
  FVisible := Value;

  if Assigned(FMainBody) then
    FMainBody.Data.Hidden := not Value;

  for i := 0 to ControlsCount - 1 do
  begin
    Control[i].Visible := Value;
  end;
  if not Value and Focused then
    Focused := false;
end;

procedure TBControl.SetHint(const Value: string);
begin
  FHint := Value;
end;

procedure TBControl.SetLeft(const Value: BSFloat);
begin
  if Assigned(MainBody) then
  begin
    MainBody.Position2d := vec2(Value, MainBody.Position2d.y);
  end;
end;

constructor TBControl.Create(ARenderer: TBlackSharkRenderer);
begin
  FControlState := [csInitializing];
  FOwnCanvas := true;
  Create(TBCanvas.Create(ARenderer, Self));
  ObsrvCreateCanvasObject := CreateCanvasEventObserver(Canvas.OnCreateObject, OnCreateCanvasObject);
  ObsrvFreeCanvasObject := CreateCanvasEventObserver(Canvas.OnFreeObject, OnFreeCanvasObject);
  ObsrvChangeCanvasFont := CreateCanvasEventObserver(Canvas.OnChangeFont, OnChangeCanvasFont);
end;

procedure TBControl.AfterConstruction;
begin
  try
    { load published properties }
    inherited AfterConstruction;
    { now we ready to form of a need shape }
    BuildView;
  finally
    FControlState := FControlState - [csInitializing];
  end;
end;

procedure TBControl.BeforeDestruction;
begin
  inherited;
  FControlState := FControlState + [csReleasing];
end;

procedure TBControl.ClearControls(FreeControls: boolean);
var
  it: TBiDirListControls.PListItem;
  cntrl: TBControl;
begin
  if FControls = nil then
    exit;
  it := FControls.ItemListFirst;
  while it <> nil do
  begin
    cntrl := it.Item;
    it := it.Next;
    cntrl.ParentControl := nil;
    if FreeControls then
      cntrl.Free;
  end;
  FControls.Clear;
end;

class procedure TBControl.ControlRegister(const Group: string; ControlClass: TBControlClass);
var
  i: int32;
  gr: TGroupControls;
begin
  gr := nil;
  for i := 0 to RegistredControls.Count - 1 do
    if RegistredControls.Items[i].Name = Group then
    begin
      gr := RegistredControls.Items[i];
      break;
    end;

  if gr = nil then
  begin
    gr := TGroupControls.Create(Group);
    RegistredControls.Add(gr);
  end;

  gr.Add(ControlClass);
end;

constructor TBControl.Create(ACanvas: TBCanvas);
begin
  FVisible := true;
  FEnabled := true;
  FCanvas := ACanvas;
  FEventFocusLeaveEnter := CreateFocusEvent;
  if FCanvas.Scalable then
    ObsrvAfterScale := CreateEmptyObserver(FCanvas.OnAfterScale, OnAfterScale);
end;

function TBControl.CreateMainBody(AClass: TCanvasObjectClass): TCanvasObject;
begin
  FMainBody := AClass.Create(Canvas, nil);
  Result := FMainBody;
end;

class function TBControl.ControlGroupsRegistred: int32;
begin
  Result := RegistredControls.Count;
end;

class constructor TBControl.Create;
begin
  RegistredControls := TListVec<TGroupControls>.Create;
  FEventFocusChanged := CreateFocusEvent;
  ControlEvents := CreateOpCodeEvent;
end;

class function TBControl.ControlGroupGet(i: int32): TGroupControls;
begin
  Result := RegistredControls.Items[i];
end;

function TBControl.DefaultSize: TVec2f;
begin
  Result := vec2(0.0, 0.0);
end;

procedure TBControl.DeleteControl(Control: TBControl);
begin
  if FControls = nil then
    exit;
  if Assigned(Control.MainBody) then
    FMainBody.Parent := nil;
  FControls.Remove(Control._Position);
  Control._Position := nil;
  Control.Free;
end;

class destructor TBControl.Destroy;
var
  i: int32;
begin
  FEventFocusChanged := nil;
  ControlEvents := nil;
  for i := 0 to RegistredControls.Count - 1 do
    RegistredControls.Items[i].Free;
  RegistredControls.Free;
end;

destructor TBControl.Destroy;
begin
  ObsrvCreateCanvasObject := nil;
  ObsrvFreeCanvasObject := nil;
  ObsrvAfterScale := nil;
  ObsrvChangeCanvasFont := nil;
  if Focused then
    Focused := false;

  if Assigned(FParentControl) then
    FParentControl.RemoveControl(Self);
  ClearControls(true);
  FControls.Free;
  if OwnCanvas then
    FCanvas.Free
  else
  if Assigned(FMainBody) then
    FreeAndNil(FMainBody);
  FEventFocusLeaveEnter := nil;
  inherited;
end;

procedure TBControl.DoAfterScale;
begin

end;

procedure TBControl.DropControl(Control: TBControl; Parent: TCanvasObject);
var
  p: TCanvasObject;
begin
  if Control.ParentControl = Self then
    exit;

  if Assigned(Control.ParentControl) then
    Control.ParentControl.RemoveControl(Control);

  Control.FParentControl := Self;

  if FControls = nil then
    FControls := TBiDirListControls.Create;

  Control._Position := FControls.PushToEnd(Control);

  if Assigned(Parent) then
    p := Parent
  else
    p := MainBody;

  if Assigned(Control.MainBody) then
    Control.MainBody.Parent := p;

  Control.Scalable := Scalable;

  if (p.Data.AsStencil or p.Data.HasStencilParent) and Assigned(Control.MainBody) then
    Control.MainBody.Data.SetStensilTestRecursive(true);
end;

procedure TBControl.DropControl(Control: TBControl);
begin
  DropControl(Control, MainBody)
end;

procedure TBControl.RemoveControl(Control: TBControl);
begin
  if FControls = nil then
    exit;
  if Assigned(Control.MainBody) then
    Control.MainBody.Parent := nil;
  FControls.Remove(Control._Position);
  Control._Position := nil;
  Control.FParentControl := nil;
end;

procedure TBControl.Resize(AWidth, AHeight: BSFloat);
begin
  BuildView;
end;

function TBControl.GetAlign: TObjectAlign;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.Align
  else
    Result := TObjectAlign.oaNone;
end;

function TBControl.GetAnchor(Index: TAnchor): boolean;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.Anchors[Index]
  else
    Result := false;
end;

function TBControl.GetControl(index: int32): TBControl;
begin
  if FControls = nil then
    exit(nil);
  FControls.Cursor := index;
  Result := FControls.UnderCursorItem.Item;
end;

function TBControl.GetControlsCount: int32;
begin
  if FControls <> nil then
    Result := FControls.Count
  else
    Result := 0;
end;

function TBControl.GetCountAnchors: int8;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.CountAnchors
  else
    Result := 0;
end;

function TBControl.GetFontName: string;
begin
  if Assigned(FCanvas.Font) then
    Result := FCanvas.Font.Name
  else
    Result := '';
end;

function TBControl.GetHeight: BSFloat;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.Height
  else
    Result := 0.0;
end;

function TBControl.GetLeft: BSFloat;
begin
  if Assigned(MainBody) then
    Result := MainBody.Position2d.x
  else
    Result := 0.0;
end;

function TBControl.GetOwner: TGUIProperties;
begin
  Result := FParentControl;
end;

function TBControl.GetPosition2d: TVec2f;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.Position2d
  else
    Result := vec2(0.0, 0.0);
end;

function TBControl.GetScalable: boolean;
begin
  Result := FCanvas.Scalable;
end;

function TBControl.GetTop: BSFloat;
begin
  if Assigned(MainBody) then
    Result := MainBody.Position2d.y
  else
    Result := 0.0;
end;

function TBControl.GetWidth: BSFloat;
begin
  if Assigned(FMainBody) then
    Result := FMainBody.Width
  else
    Result := DefaultSize.Width;
end;

procedure TBControl.OnCaptureFocusByOtherControl(const Data: BFocusEventData);
begin
  if FFocused then
  begin
    if (FCanvas.ModalLevel = Data.ControlLevel) then
    begin
      Focused := false;
    end;
  end;
end;

procedure TBControl.OnChangeCanvasFont(const AData: BData);
begin

end;

procedure TBControl.OnCreateCanvasObject(const AData: BData);
begin
  if csInitializing in FControlState then
  begin
    TCanvasObject(AData.Instance).Data.TagInt := ckGUI;
  end else
  if TCanvasObject(AData.Instance).Data.HasStencilParent then // Assigned(FParentControl) and (FParentControl.FMainBody.Data.AsStencil)
    TCanvasObject(AData.Instance).Data.StencilTest := true;
end;

procedure TBControl.OnFreeCanvasObject(const AData: BData);
begin
end;

procedure TBControl.OnAfterScale(const Data: BEmpty);
begin
  if FCanvas.Scalable then
    DoAfterScale;
end;

procedure TBControl.SetParentColor(const Value: boolean);
begin
  if FParentColor = Value then
    exit;
  FParentColor := Value;
  if FParentColor and Assigned(ParentControl) then
    Color := ParentControl.Color;
end;

procedure TBControl.SetParentControl(AValue: TBControl);
begin
  if FParentControl = AValue then
  	exit;
  if Assigned(AValue) then
    AValue.DropControl(Self)
  else
  if Assigned(FParentControl) then
    FParentControl.RemoveControl(Self);
end;

procedure TBControl.SetPosition2d(const Value: TVec2f);
begin
  if Assigned(FMainBody) then
    FMainBody.Position2d := Value;
end;

procedure TBControl.SetScalable(const AValue: boolean);
var
  i: int32;
begin
  FCanvas.Scalable := AValue;
  for i := 0 to ControlsCount - 1 do
    Control[i].Scalable := AValue;
  if AValue then
    ObsrvAfterScale := CreateEmptyObserver(FCanvas.OnAfterScale, OnAfterScale)
  else
    ObsrvAfterScale := nil;
end;

procedure TBControl.SetTop(const Value: BSFloat);
begin
  if Assigned(MainBody) then
  begin
    MainBody.Position2d := vec2(MainBody.Position2d.x, Value);
  end;
end;

procedure TBControl.SetWidth(const Value: BSFloat);
begin
  Resize(Value, Height);
end;

{ TControlBehavior }

constructor TControlBehavior.Create(ACanvasObject: TCanvasObject);
begin
  CanvasObject := ACanvasObject;
end;

procedure TControlBehavior.SetCanvasObject(const Value: TCanvasObject);
begin
  FCanvasObject := Value;
end;

{ TOnMouseColorExchanger }

constructor TOnMouseColorExchanger.Create(
  ACanvasObject: TCanvasObject);
begin
  inherited;
  FColor := BS_CL_RED;
  FColorMouseEnter := BS_CL_GRAY;
end;

destructor TOnMouseColorExchanger.Destroy;
begin
  ObsrvMouseEnter := nil;
  ObsrvMouseLeave := nil;
  inherited;
end;

procedure TOnMouseColorExchanger.MouseEnter(const Data: BMouseData);
begin
  FIsMouseOver := true;
  FCanvasObject.Data.Color := FColorMouseEnter;
end;

procedure TOnMouseColorExchanger.MouseLeave(const Data: BMouseData);
begin
  FIsMouseOver := false;
  FCanvasObject.Data.Color := FColor;
end;

procedure TOnMouseColorExchanger.SetCanvasObject(const Value: TCanvasObject);
begin
  inherited;
  if FCanvasObject <> nil then
  begin
    ObsrvMouseEnter := CreateMouseObserver(FCanvasObject.Data.EventMouseEnter, MouseEnter);
    ObsrvMouseLeave := CreateMouseObserver(FCanvasObject.Data.EventMouseLeave, MouseLeave);
  end;
end;

procedure TOnMouseColorExchanger.SetColor(const Value: TColor4f);
begin
  FColor := Value;
  FCanvasObject.Data.Color := FColor;
end;

{ TOnMouseMoveAndClickColorExchanger }

constructor TOnMouseMoveAndClickColorExchanger.Create(ACanvasObject: TCanvasObject);
begin
  inherited;
  FColor := BS_CL_RED;
  FColorMouseDown := BS_CL_GRAY;
end;

destructor TOnMouseMoveAndClickColorExchanger.Destroy;
begin
  ObsrvMouseDown := nil;
  ObsrvMouseUp := nil;
  inherited;
end;

procedure TOnMouseMoveAndClickColorExchanger.MouseDown(const Data: BMouseData);
begin
  FCanvasObject.Data.Color := FColorMouseDown;
end;

procedure TOnMouseMoveAndClickColorExchanger.MouseUp(const Data: BMouseData);
begin
  if IsMouseOver then
    FCanvasObject.Data.Color := FColorMouseEnter
  else
    FCanvasObject.Data.Color := FColor;
end;

procedure TOnMouseMoveAndClickColorExchanger.SetCanvasObject(const Value: TCanvasObject);
begin
  inherited;
  if Assigned(FCanvasObject) then
  begin
    ObsrvMouseDown := CreateMouseObserver(FCanvasObject.Data.EventMouseDown, MouseDown);
    ObsrvMouseUp := CreateMouseObserver(FCanvasObject.Data.EventMouseUp, MouseUp);
  end;
end;

{ TOnMouseMoveAndClickTextureExchanger }

constructor TOnMouseMoveAndClickTextureExchanger.Create(ACanvasObject: TCanvasObject);
begin
  inherited;
  if not (ACanvasObject.Data is TTexturedVertexes) then
    raise Exception.Create('Property TCanvasObject.Data MUST BE TTexturedVertexes or him descendant!');
end;

destructor TOnMouseMoveAndClickTextureExchanger.Destroy;
begin
  ObsrvMouseEnter := nil;
  ObsrvMouseLeave := nil;
  ObsrvMouseDown := nil;
  ObsrvMouseUp := nil;
  inherited;
end;

procedure TOnMouseMoveAndClickTextureExchanger.MouseDown(const Data: BMouseData);
begin
  FIsMouseDown := true;
  TTexturedVertexes(FCanvasObject.Data).Texture := FTextureMouseDown;
end;

procedure TOnMouseMoveAndClickTextureExchanger.MouseEnter(const Data: BMouseData);
begin
  FIsMouseOver := true;
  TTexturedVertexes(FCanvasObject.Data).Texture := FTextureMouseEnter;
end;

procedure TOnMouseMoveAndClickTextureExchanger.MouseLeave(const Data: BMouseData);
begin
  FIsMouseOver := false;
  if not IsMouseDown then
    TTexturedVertexes(FCanvasObject.Data).Texture := FTexture;
end;

procedure TOnMouseMoveAndClickTextureExchanger.MouseUp(const Data: BMouseData);
begin
  FIsMouseDown := false;
  if IsMouseOver then
    TTexturedVertexes(FCanvasObject.Data).Texture := FTextureMouseEnter
  else
    TTexturedVertexes(FCanvasObject.Data).Texture := FTexture;
end;

procedure TOnMouseMoveAndClickTextureExchanger.SetCanvasObject(
  const Value: TCanvasObject);
begin
  inherited;
  if Assigned(FCanvasObject) then
  begin
    ObsrvMouseEnter := CreateMouseObserver(FCanvasObject.Data.EventMouseEnter, MouseEnter);
    ObsrvMouseLeave := CreateMouseObserver(FCanvasObject.Data.EventMouseLeave, MouseLeave);
    ObsrvMouseDown := CreateMouseObserver(FCanvasObject.Data.EventMouseDown, MouseDown);
    ObsrvMouseUp := CreateMouseObserver(FCanvasObject.Data.EventMouseUp, MouseUp);
  end;
end;

procedure TOnMouseMoveAndClickTextureExchanger.SetTexture(const Value: PTextureArea);
begin
  FTexture := Value;
  TTexturedVertexes(FCanvasObject.Data).Texture := FTexture;
end;

{ TGUIProperties }

procedure TGUIProperties.AfterConstruction;
begin
  inherited;
  LoadProperties;
end;

procedure TGUIProperties.Copy(Source: TGUIProperties);
var
  theme: TBTheme;
  group: TStyleGroup;
begin
  theme := TBTheme.Create;
  try
    group := Source.SaveProperties(StringToAnsi(Source.ClassName), theme, true);
    LoadProperties(group);
  finally
    theme.Free;
  end;
end;

function TGUIProperties.GetOwner: TGUIProperties;
begin
  Result := nil;
end;

function TGUIProperties.GetPath: AnsiString;
var
  owner: TGUIProperties;
  s: AnsiString;
begin
  Result := StringToAnsi(ClassName);
  owner := GetOwner;
  if Assigned(owner) then
  begin
    s := owner.GetPath;
    if Length(s) > 0 then
      Result := s + GROUP_DELIMETER + Result;
  end;
end;

procedure TGUIProperties.LoadProperties(FromTheme: TBTheme);
begin
  LoadProperties(FromTheme.FindStyleGroup(GetPath));
end;

procedure TGUIProperties.LoadProperties;
begin
  LoadProperties(ThemeManager);
end;

procedure TGUIProperties.LoadProperties(Properties: TStyleGroup);
var
  props: PPropList;
  i: int32;
  style_prop: TStyleItem;
begin
  if Properties = nil then
    exit;
  props := nil;
  i := GetPropList(Self, props);
  try
    while i > 0 do
    begin
      dec(i);
      if IsPublishedProp(Self, string(props[i].Name)) then
      begin
        style_prop := Properties.FindStyleItem(StringToAnsi(string(props[i].Name)));
        if Assigned(style_prop) then
          style_prop.WriteToProperty(props[i], Self);
      end;
    end;
  finally
    if props <> nil then
      FreeMem(props);
  end;
end;

procedure TGUIProperties.SaveProperties(Properties: TStyleGroup);
var
  props: PPropList;
  i: int32;
  style_prop: TStyleItem;
  style_type: TStyleItemClass;
  prop_astr: AnsiString;
begin
  { TODO: mechanism of remove dead properties }
  props := nil;
  i := GetPropList(Self, props);
  try
    while i > 0 do
    begin
      dec(i);
      if IsPublishedProp(Self, string(props[i].Name)) then
      begin
        prop_astr := StringToAnsi(string(props[i].Name));
        { has the porperty in the group of style }
        style_prop := Properties.FindStyleItem(prop_astr);
        if not Assigned(style_prop) then
        begin
          { find a registered type for the property }
          style_type := TBTheme.FindStyleItemByTypeName(props[i].PropType^.Name);
          if Assigned(style_type) then
            style_prop := Properties.AddStyleItem(style_type, prop_astr);
        end;
        if Assigned(style_prop) then
          { read value from property to style }
          style_prop.ReadFromProperty(props[i], Self);
      end;
    end;
  finally
    if props <> nil then
      FreeMem(props);
  end;
end;

function TGUIProperties.SaveProperties(const URL: AnsiString; ToTheme: TBTheme;
  CreateStyleIfNotExists: boolean): TStyleGroup;
begin
  Result := ToTheme.FindStyleGroup(URL);
  if (Result = nil) then
  begin
    if CreateStyleIfNotExists then
      Result := ToTheme.CreateStyleGroup(URL, Self, false)
    else
      exit;
  end;
  SaveProperties(Result);
end;

procedure TGUIProperties.SaveProperties(CreateStyleIfNotExists: boolean);
begin
  SaveProperties(GetPath, ThemeManager, CreateStyleIfNotExists);
end;

{ TFactoryOfGUI }

{constructor TFactoryOfGUI.Create;
begin
  FGUIClasses := TListVec<TGUIPropertiesClass>.Create;
end;

destructor TFactoryOfGUI.Destroy;
begin
  FGUIClasses.Free;
  inherited;
end;

function TFactoryOfGUI.GetCountGUI: int32;
begin
  Result := FGUIClasses.Count;
end;

function TFactoryOfGUI.GetGUIClasses(Index: int32): TGUIPropertiesClass;
begin
  Result := FGUIClasses.Items[Index];
end;

procedure TFactoryOfGUI.RegisterGUI(GUIClass: TGUIPropertiesClass);
begin
  FGUIClasses.Add(GUIClass);
end; }

{ TFactoriesManager }

{class constructor TFactoriesManager.Create;
begin
  FFactories := TListVec<TFactoryOfGUI>.Create;
end;

class destructor TFactoriesManager.Destroy;
var
  i: int32;
begin
  for i := 0 to FFactories.Count - 1 do
    FFactories.Items[i].Free;
  FFactories.Free;
end;

class function TFactoriesManager.GetCountFactories: int32;
begin
  Result := FFactories.Count;
end;

class function TFactoriesManager.GetFactories(Index: int32): TFactoryOfGUI;
begin
  Result := FFactories.Items[Index];
end;

class procedure TFactoriesManager.RegisterFactory(Factory: TFactoryOfGUI);
begin
  FFactories.Add(Factory);
end;   }

{ TFactoryOfControls }

{function TFactoryOfControls.CreateGUI(Index: int32; Scene: TBScene): TGUIProperties;
begin
  Result := TBControlClass(FGUIClasses.Items[Index]).Create(Scene, false);
end;

class function TFactoryOfControls.FactoryName: string;
begin
  Result := 'Controls';
end;

class function TFactoryOfControls.NewInstance: TObject;
begin
  if Assigned(Instance) then
    raise Exception.Create('TFactoryOfControls has already been created!') else
    Instance := TFactoryOfControls(inherited NewInstance);
  Result := Instance;
end;  }

end.
