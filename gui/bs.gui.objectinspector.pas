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

unit bs.gui.objectinspector;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  {$ifdef FPC}
  {$else}
  , Types
  {$endif}
  , typinfo

  , bs.basetypes
  , bs.scene
  , bs.gui.themes
  , bs.gui.base
  , bs.gui.scrollbar
  , bs.collections
  , bs.events
  , bs.canvas
  ;

type

  TPropEditorClass = class of TPropEditor;
  TObjectInspector = class;
  TObjectPropGroup = class;

  { TPropEditor }

  TPropEditor = class
  private
    class constructor Create;
    class destructor Destroy;
  protected
    FControl: TBControl;
    FText: TCanvasText;
    FEditedData: TObjectPropGroup;
    { rect for out values of properties }
    FDrawedRect: TRect;
    FValueChaned: Boolean;
    { it is container for editors of different types; access by name of type;
      this container is used as usual binary tree without calculate suffixes
      because do not find words in buffer, but we find if exists key }
    class var RegistredEditors: TAhoCorasickFSA<TPropEditorClass>;
    procedure BeforChangeValueInStyle;
    procedure AfterChangeValueInStyle;
    procedure CreateControl; virtual; abstract;
    procedure SetPosCtrls; virtual;
    procedure UpdateValue; virtual; abstract;
    //procedure ChangeValueInStyle(const Value); virtual; abstract;
  public
    constructor Create(AEditedData: TObjectPropGroup); virtual;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    class procedure RegisterEditor(const TypeName: string; EditorClass: TPropEditorClass);
    class function FindEditor(const TypeName: string): TPropEditorClass;
    procedure Draw(var DrawRect: TRect); virtual;
    property Control: TBControl read FControl;
    property ValueChaned: boolean read FValueChaned write FValueChaned;
  end;

  TPropEditorTempl<T> = class(TPropEditor)
  protected
    procedure ChangeValueInStyle(const Value: T);
  end;

  { TPropStringEditor }

  TPropStringEditor = class (TPropEditorTempl<string>)
  private
    ObsrvOnKeyPress: IBKeyEventObserver;
    ObsrvOnKeyDown: IBKeyEventObserver;
    procedure OnKeyPress(const Data: BKeyData);
    procedure OnKeyDown(const Data: BKeyData);
  protected
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropBooleanEditor }

  TPropBooleanEditor = class (TPropEditorTempl<Boolean>)
  private
    procedure OnChangeEdit(Sender: TObject);
  protected
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropColorEditor }

  TPropColorEditor = class (TPropEditorTempl<TGuiColor>)
  private
    ColorRect: TRectangle;
    procedure OnChangeEdit(Sender: TObject);
  protected
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    constructor Create(AEditedData: TObjectPropGroup); override;
    destructor Destroy; override;
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropIntEditor<T> }

  TPropIntEditor<T> = class (TPropEditorTempl<T>)
  private
    ObsrvOnKeyPress: IBKeyEventObserver;
    ObsrvOnKeyDown: IBKeyEventObserver;
    procedure OnKeyPress(const Data: BKeyData);
  protected
    procedure OnKeyDown(const Data: BKeyData); virtual;
    procedure CreateControl; override;
  public
    destructor Destroy; override;
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropEditorInt32 }

  TPropEditorInt32 = class(TPropIntEditor<int32>)
  protected
    procedure OnKeyDown(const Data: BKeyData); override;
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropEditorInt8 }

  TPropEditorInt8 = class(TPropIntEditor<int8>)
  protected
    procedure OnKeyDown(const Data: BKeyData); override;
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  TPropEditorInteger = TPropEditorInt32;
  TPropEditorLargeInt = TPropEditorInt32;

  { TPropEditorInt64 }

  TPropEditorInt64 = class(TPropIntEditor<int64>)
  protected
    procedure OnKeyDown(const Data: BKeyData); override;
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropEditorFloatTemplate }

  TPropEditorFloatTemplate<T> = class(TPropEditorTempl<T>)
  private
    ObsrvOnKeyPress: IBKeyEventObserver;
    ObsrvOnKeyDown: IBKeyEventObserver;
    procedure OnKeyPress(const Data: BKeyData);
  protected
    procedure OnKeyDown(const Data: BKeyData); virtual;
    procedure CreateControl; override;
  end;

  { TPropEditorFloat }

  TPropEditorFloat = class(TPropEditorFloatTemplate<BSFloat>)
  protected
    procedure OnKeyDown(const Data: BKeyData); override;
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TPropEditorDouble }

  TPropEditorDouble = class(TPropEditorFloatTemplate<Double>)
  protected
    procedure OnKeyDown(const Data: BKeyData); override;
    procedure CreateControl; override;
    procedure UpdateValue; override;
  public
    procedure Draw(var DrawRect: TRect); override;
  end;

  { TObjectPropGroup }

  TObjectPropGroup = class
  private
    FExpanded: boolean;
    FHasChildren: boolean;
    FSelected: boolean;
    Props: PPropList;
    Inspector: TObjectInspector;
    FCanvas: TBCanvas;
    { the object is the property (Prop) owner }
    FOwner: TObject;
    { property is described the class; is nil for root object }
    Prop: PPropInfo;
    PropStyleItem: TStyleItem;
    FLevel: int32;
    ListGroups: TListVec<TObjectPropGroup>;
    PropEditor: TPropEditor;
    FCaption: TCanvasText;
    FValue: TCanvasText;
    FValueRect: TRectangle;

    Name: TRectangle;
    FFoldUnfoldRect: TRoundRect;
    PlusMinusFoldUnfold: TLines;

    procedure LoadProps;
    procedure AddProp(Prop: PPropInfo; StyleItem: TStyleItem);
    procedure SetExpanded(AValue: boolean);
    procedure SetSelected(AValue: boolean);
    function CheckHasChild: boolean;
    class function CompareProp(const Prop1, Prop2: TObjectPropGroup): int8; static;
    procedure DrawLowerCorners(LeftX, LeftY, Width: BSFloat);
  protected
    { if Prop is class then it is its value  }
    IamObject: TObject;
  public
    constructor Create(AInspector: TObjectInspector; AOwner: TObject;
      AProp: PPropInfo;  APropStyleItem: TStyleItem; ALevel: int32); virtual;
    destructor Destroy; override;
    procedure ClearSubprops;
    function Draw(var Index: int32; const RectInspector: TRect;
      SplitterPos: int32): boolean;
    { RectOut - area for out value; RectOut offsets to next area if value drawed
      successful }
    procedure DrawValue(var RectOut: TRect);
    //procedure EnterSelectedValue;
    property Expanded: boolean read FExpanded write SetExpanded;
    property HasChildren: boolean read FHasChildren;
    property Selected: boolean read FSelected write SetSelected;
    property Owner: TObject read FOwner;
    property Level: int32 read FLevel;
    property Canvas: TBCanvas read FCanvas;
  end;

  TOnChangePropNotify = procedure (Group: TObjectPropGroup; Editor: TPropEditor) of object;

  { TObjectInspector }

  TObjectInspector = class(TBControl)
  strict private
    {$region own body}
      //FBody: TRectangle;
      FBorderLine: TPath;
      FBorderShape: TFreeShape;
      FBorderRect: TRectangle;
      Splitter: TLine;
      SplitterBack: TLine;
      EventSceneMouseWeel: IBMouseWeelEventObserver;

      EventBodyMouseDown: IBMouseWeelEventObserver;
      EventBodyMouseMove: IBMouseMoveEventObserver;
      EventBodyMouseDblClick: IBMouseMoveEventObserver;

      EventSplitterMouseDown: IBMouseMoveEventObserver;
      EventSplitterMouseUp: IBMouseDownEventObserver;
      //Cursor: TCursor;
    {$endregion own body}
  private
    FRowHeight: int32;
    FThemeManager: TBTheme;
    MousePos: TPoint;
    MouseIsDownOnSplitter: boolean;
    SplitterPos: Int32;
    FInspectedObject: TObject;
    FVertScrollBar: TBScrollBar;
    Root: TObjectPropGroup;
    FColorLeftBorder: TGuiColor;
    FDrawedProps: TListVec<TObjectPropGroup>;
    IndexSelected: int32;
    FColorValues: TGuiColor;
    FColorPropsName: TGuiColor;
    FColorBrushPropsName: TGuiColor;
    CountPainting: int32;

    FOnChangePropBefor: TOnChangePropNotify;
    FOnChangePropAfter: TOnChangePropNotify;
    procedure SetInspectedObject(AValue: TObject);
    procedure SetRowHeight(AValue: int32);
    procedure UpdateScrollBar;
    procedure SetDrawedProp(Prop: TObjectPropGroup);
    procedure SetColorValues(const Value: TGuiColor);
    procedure SetColorLeftBorder(const Value: TGuiColor);
    procedure SetColorPropsName(const Value: TGuiColor);
    procedure SetColorBrushPropsName(const Value: TGuiColor);
    procedure OnScrollVert(ScrollBar: TBScrollBar);
    procedure OnScroll(const Event : BMouseData);
    procedure MouseDownSplitter(const Event: BMouseData);
    procedure MouseUpSplitter(const Event: BMouseData);

    procedure MouseDownBody(const Event: BMouseData);
    procedure MouseMoveBody(const Event: BMouseData);
    procedure DblClick(const Event: BMouseData);

    procedure LoadDefaultLightScheme;
    //procedure LoadDefaultDarkScheme;
    procedure DrawClipArea(Instance: PRendererGraphicInstance);
  protected
    procedure ChangePropBefor(Group: TObjectPropGroup; Editor: TPropEditor); virtual;
    procedure ChangePropAfter(Group: TObjectPropGroup; Editor: TPropEditor); virtual;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function DefaultSize: TVec2f; override;
    procedure NextValue;
    procedure PrevValue;
    procedure BeginDraw;
    procedure EndDraw;
    property InspectedObject: TObject read FInspectedObject write SetInspectedObject;
    property BorderLine: TPath read FBorderLine;
    property BorderShape: TFreeShape read FBorderShape;
    property ThemeManager: TBTheme read FThemeManager write FThemeManager;
    property DrawedProps: TListVec<TObjectPropGroup> read FDrawedProps;
    property OnChangePropBefor: TOnChangePropNotify read FOnChangePropBefor write FOnChangePropBefor;
    property OnChangePropAfter: TOnChangePropNotify read FOnChangePropAfter write FOnChangePropAfter;
  published
    property ColorLeftBorder: TGuiColor read FColorLeftBorder write SetColorLeftBorder;
    property ColorPropsName: TGuiColor read FColorPropsName write SetColorPropsName;
    property ColorBrushPropsName: TGuiColor read FColorBrushPropsName write SetColorBrushPropsName;
    property ColorValues: TGuiColor read FColorValues write SetColorValues;
    property RowHeight: int32 read FRowHeight write SetRowHeight;
    property Color;
  end;

const
  BORDER_SIZE_LEFT = 12.0;
  INDENT_CAPTION = 3.0;
  ROW_SIZE = 21.0;
  UNFOLD_RECT_SIZE = BORDER_SIZE_LEFT - 3.0;
  UNFOLD_RECT_SIZE_PLUS = UNFOLD_RECT_SIZE - 4.0;
  UNFOLD_RECT_PLUS_POS = UNFOLD_RECT_SIZE * 0.5;
  UNFOLD_RECT_POS_LEFT = (BORDER_SIZE_LEFT - UNFOLD_RECT_SIZE) * 0.5 + 1.0;
  UNFOLD_RECT_POS_TOP = (ROW_SIZE - UNFOLD_RECT_SIZE) * 0.5 + 1.0;

implementation

uses
    bs.strings
  , bs.graphics
  , bs.gl.es
  , bs.align
  , bs.scene.objects
  , bs.gui.edit
  , bs.gui.combobox
  , bs.gui.colorbox
  , bs.thread
  , bs.mesh.primitives
  ;

var
  EDITORS_PROP: array[TypInfo.TTypeKind] of TPropEditorClass;

{ TPropEditorInt8 }

procedure TPropEditorInt8.UpdateValue;
var
  i: int8;
begin
  i := TBSpinEdit(FControl).Value;
  { Save property value in style }
  ChangeValueInStyle(i);
  TPropValueAccessProvider<int8>.SetPropValue(FEditedData.Owner, FEditedData.Prop, i);
end;

procedure TPropEditorInt8.CreateControl;
begin
  inherited CreateControl;
  { draw real value of property }
  TBSpinEdit(FControl).Value := TPropValueAccessProvider<int8>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
  TBSpinEdit(FControl).SelectAll;
  if FEditedData.Inspector.Visible then
    TBSpinEdit(FControl).Focused := true;
end;

procedure TPropEditorInt8.Draw(var DrawRect: TRect);
begin
  inherited Draw(DrawRect);
  if not FEditedData.Selected then
  begin
    { draw real value of property }
    FText.Text := IntToStr(TPropValueAccessProvider<int8>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  end;
end;

procedure TPropEditorInt8.OnKeyDown(const Data: BKeyData);
begin
  inherited;
  if Data.Key = 27 then
    TBSpinEdit(FControl).Value := TPropValueAccessProvider<Int8>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
end;

{ TPropEditor }

procedure TPropEditor.AfterChangeValueInStyle;
begin
  FEditedData.Inspector.ChangePropAfter(FEditedData, Self);
end;

procedure TPropEditor.SetPosCtrls;
begin
  FControl.Width := FDrawedRect.Width;
  FControl.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
end;

procedure TPropEditor.BeforChangeValueInStyle;
begin
  FEditedData.Inspector.ChangePropBefor(FEditedData, Self);
end;

procedure TPropEditor.BeforeDestruction;
begin
  inherited;
end;

constructor TPropEditor.Create(AEditedData: TObjectPropGroup);
begin
  FEditedData := AEditedData;
end;

class constructor TPropEditor.Create;
begin
  RegistredEditors := TAhoCorasickFSA<TPropEditorClass>.Create;
end;

destructor TPropEditor.Destroy;
begin
  FreeAndNil(FControl);
  FreeAndNil(FText);
  inherited Destroy;
end;

class destructor TPropEditor.Destroy;
begin
  RegistredEditors.Free;
end;

procedure TPropEditor.Draw(var DrawRect: TRect);
begin
  FDrawedRect := DrawRect;
  if FEditedData.Selected then
  begin
    FreeAndNil(FText);
    if FControl = nil then
      CreateControl;
    SetPosCtrls;
  end else
  begin
    FreeAndNil(FControl);
    if not Assigned(FText) then
    begin
      FText := TCanvasText.Create(FEditedData.Canvas, FEditedData.Inspector.MainBody);
      FText.Color := ColorByteToFloat(FEditedData.Inspector.ColorValues);
    end;
    { draw real value of property }
    FText.SceneTextData.OutToWidth := DrawRect.Width - FText.Font.AverageWidth - INDENT_CAPTION;
    FText.Position2d := vec2(DrawRect.Left + INDENT_CAPTION, DrawRect.Top + (DrawRect.Height - FText.Font.AverageHeight)*0.5);
  end;
end;

class procedure TPropEditor.RegisterEditor(const TypeName: string; EditorClass: TPropEditorClass);
begin
  RegistredEditors.Add(StringToAnsi(AnsiUpperCase(TypeName)), EditorClass);
end;

class function TPropEditor.FindEditor(const TypeName: string): TPropEditorClass;
begin
  RegistredEditors.WordExists(StringToAnsi(AnsiUpperCase(TypeName)), Result);
end;

{ TObjectPropGroup }

procedure TObjectPropGroup.LoadProps;
var
  i: int32;
  style_type: TStyleItemClass;
  Style: TStyleGroup;
  it: TStyleItem;
  as_prop: AnsiString;
begin

  if IamObject is TGUIProperties then
    Style := Inspector.ThemeManager.FindOrCreateStyleGroup(TGUIProperties(IamObject).GetPath)
  else
  if IamObject is TPersistent then
    Style := Inspector.ThemeManager.FindOrCreateStyleGroup(StringToAnsi((TPersistent(IamObject).GetNamePath)))
  else
    Style := Inspector.ThemeManager.FindOrCreateStyleGroup(StringToAnsi(IamObject.ClassName));

  if Assigned(Props) then
    FreeMem(Props);

  Props := nil;
  i := GetPropList(IamObject, Props);
  while i > 0 do
  begin
    dec(i);
    as_prop := StringToAnsi(string(Props[i].Name));
    style_type := Inspector.ThemeManager.FindStyleItemByTypeName(StringToAnsi(string(Props[i].PropType^.Name)));
    if not Assigned(style_type) then
    begin
      if props[i].PropType^.Kind = tkClass then
        AddProp(props[i], nil);
      continue;
    end;

    it := Style.FindStyleItem(as_prop);
    if it = nil then
    begin
      it := Style.AddStyleItem(style_type, as_prop);
      it.ReadFromProperty(Props[i], IamObject);
    end{ else
      it.WriteToProperty(Props[i], IamObject)};

    AddProp(props[i], it);
    {
    if props[i].PropType^.Kind = tkClass then
      begin
      AddProp(props[i], it);
      end else
      begin
      AddProp(props[i], it);
      style_type := Inspector.Inspector.ThemeManager.FindStyleItemByTypeName(
        StringToAnsi(string(Props[i].PropType^.Name)));
      if Assigned(style_type) then
        begin
        style_type.WriteToProperty(Style, Props[i], IamObject);
        AddProp(props[i], it);
        end;
      end;  }
  end;
  ListGroups.Sort;
end;

procedure TObjectPropGroup.AddProp(Prop: PPropInfo; StyleItem: TStyleItem);
var
  Group: TObjectPropGroup;
begin
  Group := TObjectPropGroup.Create(Inspector, IamObject, Prop, StyleItem, FLevel+1);
  ListGroups.Add(Group);
end;

procedure TObjectPropGroup.SetExpanded(AValue: boolean);
begin
  if (FExpanded = AValue) or not FHasChildren then
    exit;
  FExpanded := AValue;
  if AValue then
  begin
    if FHasChildren then
      LoadProps;
  end else
    ClearSubprops;
end;

procedure TObjectPropGroup.SetSelected(AValue: boolean);
begin
  if FSelected = AValue then
    exit;
  if not AValue and Assigned(PropEditor) and (PropEditor.ValueChaned) then
    PropEditor.UpdateValue;
  FSelected := AValue;
end;

constructor TObjectPropGroup.Create(AInspector: TObjectInspector;
  AOwner: TObject; AProp: PPropInfo; APropStyleItem: TStyleItem; ALevel: int32);
var
  ed: TPropEditorClass;
begin
  ListGroups := TListVec<TObjectPropGroup>.Create(CompareProp);
  FLevel := ALevel;
  Inspector := AInspector;
  FCanvas := Inspector.Canvas;
  Prop := AProp;
  PropStyleItem := APropStyleItem;
  FOwner := AOwner;

  if (FLevel > 0) then
  begin

    Name := TRectangle.Create(FCanvas, Inspector.MainBody);
    Name.Data.Interactive := false;
    Name.Fill := true;
    Name.Color := ColorByteToFloat(Inspector.ColorBrushPropsName, true);

    FCaption := TCanvasText.Create(FCanvas, Name);
    FCaption.Data.Interactive := false;
    FCaption.Color := ColorByteToFloat(Inspector.ColorPropsName, true);

    if Assigned(PropStyleItem) then
      FCaption.Text := AnsiToString(PropStyleItem.Caption)
    else
    if Assigned(Prop) then
      FCaption.Text := string(Prop.Name)
    else
      FCaption.Text := FOwner.ClassName;

    if Assigned(Prop) then
    begin
      if (Prop^.PropType^.Kind in [tkClass]) then
      begin
        { check if assigned class to property }
        IamObject := TPropValueAccessProvider<TObject>.GetPropValue(FOwner, Prop);
        FHasChildren := CheckHasChild;
      end;
    end;
    { find property editor }
    if Assigned(PropStyleItem) then
    begin
      ed := TPropEditor.FindEditor(AnsiToString(PropStyleItem.TypeName));
      if Assigned(ed) then
        PropEditor := ed.Create(Self)
      else
      if Assigned(EDITORS_PROP[Prop^.PropType^.Kind]) then
      begin
        PropEditor := EDITORS_PROP[Prop^.PropType^.Kind].Create(Self);
      end;
    end;
  end else
  begin // Level = 0
    FHasChildren := true;
    IamObject := Inspector.FInspectedObject;
    LoadProps;
  end;

  if FHasChildren and (FLevel > 0) and not Assigned(FFoldUnfoldRect) then
  begin
    // set parent Inspector.MainBody because left border (FBorderShape, above which it hovers)
    // builds late of the object
    FFoldUnfoldRect := TRoundRect.Create(FCanvas, Inspector.MainBody);
    FFoldUnfoldRect.RadiusRound := 1;
    FFoldUnfoldRect.Fill := false;
    FFoldUnfoldRect.Color := BS_CL_GRAY; // todo: color to property
    FFoldUnfoldRect.Size := vec2(UNFOLD_RECT_SIZE, UNFOLD_RECT_SIZE);
    FFoldUnfoldRect.Data.Interactive := false;
    // adjust above FBorderShape, otherwise they will be on the same layer and
    // can occure draw collisions
    FFoldUnfoldRect.Layer2d := Inspector.BorderShape.Layer2d + 1;
    FFoldUnfoldRect.Build;
    PlusMinusFoldUnfold := TLines.Create(FCanvas, FFoldUnfoldRect);
    PlusMinusFoldUnfold.LinesWidth := 1;
    PlusMinusFoldUnfold.Color := FFoldUnfoldRect.Color;
    PlusMinusFoldUnfold.Data.Interactive := false;
    PlusMinusFoldUnfold.DrawByTriangleOnly := true;
  end;

end;

destructor TObjectPropGroup.Destroy;
begin
  ClearSubprops;
  FreeAndNil(FFoldUnfoldRect);
  FreeAndNil(PropEditor);
  FreeAndNil(ListGroups);
  Name.Free;
  FValue.Free;
  FValueRect.Free;

  inherited Destroy;
end;

function TObjectPropGroup.CheckHasChild: boolean;
var
  pr_list: PPropList;
begin
  if (IamObject = nil) then
    exit(false);
  pr_list := nil;
  Result := GetPropList(IamObject, pr_list) > 0;
  if pr_list <> nil then
    FreeMem(pr_list);
end;

procedure TObjectPropGroup.ClearSubprops;
var
  i: int32;
begin
  for i := 0 to ListGroups.Count - 1 do
    ListGroups.Items[i].Free;
  ListGroups.Count := 0;
  if Assigned(Props) then
  begin
    dispose(Props);
    Props := nil;
  end;
end;

class function TObjectPropGroup.CompareProp(const Prop1, Prop2: TObjectPropGroup): int8;
begin
  Result := StrCmp(Prop2.FCaption.Text, Prop1.FCaption.Text);
end;

function TObjectPropGroup.Draw(var Index: int32; const RectInspector: TRect; SplitterPos: int32): boolean;
var
  i, j: int32;
  r: TRect;
begin
  Result := true;
  j := Index;
  if (Prop <> nil) and ((Prop.PropType^.Kind <> tkClass) or FHasChildren) then
  begin
    Inspector.SetDrawedProp(Self);
    r.Top := RectInspector.Top;
    r.Bottom := RectInspector.Bottom;
    r.Right := SplitterPos - 1;
    r.Left := round(FLevel*BORDER_SIZE_LEFT);

    Name.Size := vec2(r.Width, r.Height);
    Name.Build;
    Name.Data.Hidden := not FSelected;
    Name.Position2d := vec2(r.Left, r.Top);

    { draw property name  }

    FCaption.SceneTextData.OutToWidth := r.Width - FCaption.Font.AverageWidth - INDENT_CAPTION;
    FCaption.Position2d := vec2(INDENT_CAPTION, (Name.Size.y - FCaption.Font.AverageHeight)*0.5);

    if (Index > 0) then
    begin
      { draw border }
      if (Inspector.DrawedProps.Items[Index - 1].Level < FLevel) then
      begin
        Inspector.BorderLine.AddPoint(vec2(r.Left - BORDER_SIZE_LEFT + 2.0, r.Top));
        Inspector.BorderShape.AddPoint(vec2(r.Left - BORDER_SIZE_LEFT + 2.0, r.Top));
        Inspector.BorderLine.AddPoint(vec2(r.Left - 2.0, r.Top));
        Inspector.BorderShape.AddPoint(vec2(r.Left - 2.0, r.Top));
        Inspector.BorderLine.AddPoint(vec2(r.Left, r.Top + 2.0));
        Inspector.BorderShape.AddPoint(vec2(r.Left, r.Top + 2.0));
      end else
      if (Inspector.DrawedProps.Items[Index - 1].Level = FLevel) and (FLevel > 1) then
      begin
        Inspector.BorderLine.AddPoint(vec2(r.Left, r.Top - 2.0));
        Inspector.BorderShape.AddPoint(vec2(r.Left, r.Top - 2.0));
      end else
      if (Inspector.DrawedProps.Items[Index - 1].Level > FLevel) then
      begin
        DrawLowerCorners(r.Left, r.Top, (Inspector.DrawedProps.Items[Index - 1].Level - FLevel)*BORDER_SIZE_LEFT);
      end;
    end;

    Inspector.BorderLine.AddPoint(vec2(r.Left, r.Top + Inspector.RowHeight - 2.0));
    Inspector.BorderShape.AddPoint(vec2(r.Left, r.Top + Inspector.RowHeight - 2.0));
    Inspector.BorderShape.AddPoint(vec2(r.Left, r.Top + Inspector.RowHeight - 2.0));

    if FHasChildren then
    begin
      FFoldUnfoldRect.Position2d := vec2(r.Left - BORDER_SIZE_LEFT + UNFOLD_RECT_POS_LEFT, RectInspector.Top + UNFOLD_RECT_POS_TOP);
      PlusMinusFoldUnfold.Clear;
      PlusMinusFoldUnfold.BeginUpdate;
      { draw plus if collapsed, else minus }
      if ListGroups.Count > 0 then
        PlusMinusFoldUnfold.AddLine(2.0, UNFOLD_RECT_SIZE * 0.5 + 0.5, UNFOLD_RECT_SIZE - 2.0, UNFOLD_RECT_SIZE * 0.5 + 0.5)
      else begin
        PlusMinusFoldUnfold.AddLine(0.0, UNFOLD_RECT_SIZE * 0.5 - 2.0, UNFOLD_RECT_SIZE - 4.0, UNFOLD_RECT_SIZE * 0.5 - 2.0);
        PlusMinusFoldUnfold.AddLine(UNFOLD_RECT_SIZE * 0.5 - 2.0 + 0.5, 0.0, UNFOLD_RECT_SIZE * 0.5 - 2.0 + 0.5, UNFOLD_RECT_SIZE - 4.0);
      end;
      PlusMinusFoldUnfold.EndUpdate;
      PlusMinusFoldUnfold.ToParentCenter;
    end;

    { is need draw chevron? }
    if (FSelected) and ((not FHasChildren) or (FLevel > 1)) then
    begin

    end;

    { draw value }
    r := Rect(SplitterPos + 2, RectInspector.Top, RectInspector.Right - 2, RectInspector.Top + Inspector.RowHeight);

    DrawValue(r);

    { shift to next rect }
    r := Rect(RectInspector.Left, round(RectInspector.Top + ROW_SIZE), RectInspector.Right, RectInspector.Bottom + Inspector.RowHeight);

    inc(Index);

  end;

  for i := 0 to ListGroups.Count - 1 do
  begin
    r := Rect(RectInspector.Left, RectInspector.Top + (Index - j)*Inspector.RowHeight,
      RectInspector.Right, RectInspector.Bottom + (Index - j)*Inspector.RowHeight);
    ListGroups.Items[i].Draw(Index, r, SplitterPos);
  end;

end;

procedure TObjectPropGroup.DrawLowerCorners(LeftX, LeftY, Width: BSFloat);
begin
  Inspector.BorderLine.AddPoint(vec2(LeftX + Width - 2.0, LeftY));
  Inspector.BorderShape.AddPoint(vec2(LeftX + Width - 2.0, LeftY));
  Inspector.BorderLine.AddPoint(vec2(LeftX + 2.0, LeftY));
  Inspector.BorderShape.AddPoint(vec2(LeftX + 2.0, LeftY));
  Inspector.BorderLine.AddPoint(vec2(LeftX, LeftY + 2.0));
  Inspector.BorderShape.AddPoint(vec2(LeftX, LeftY + 2.0));
end;

procedure TObjectPropGroup.DrawValue(var RectOut: TRect);
begin
  { draw property value }

  if (PropEditor <> nil) then
  begin
    FreeAndNil(FValue);
    FreeAndNil(FValueRect);
    PropEditor.Draw(RectOut);
  end else
  begin
    { draw frame arround value }
    if FSelected then
    begin
      if not Assigned(FValueRect) then
      begin
        FValueRect := TRectangle.Create(FCanvas, Inspector.MainBody);
        FValueRect.Data.Interactive := false;
        FValueRect.Fill := false;
        FValueRect.WidthLine := 1;
        FValueRect.Color := ColorByteToFloat(Inspector.ColorBrushPropsName, true);
      end;
      FValueRect.Size := vec2(RectOut.Width, RectOut.Height - 1.0);
      FValueRect.Build;
      FValueRect.Position2d := vec2(RectOut.Left, RectOut.Top + 1.0);
    end else
      FreeAndNil(FValueRect);

    if not Assigned(FValue) then
    begin
      FValue := TCanvasText.Create(FCanvas, Inspector.MainBody);
      FValue.Color := ColorByteToFloat(Inspector.ColorValues, true);
      FValue.Data.Interactive := false;
    end;

    FValue.SceneTextData.OutToWidth := RectOut.Width - 2.0;
    FValue.Text := '(' + string(Prop.PropType^.Name) + ')';
    FValue.Position2d := vec2(RectOut.Left, RectOut.Top + (RectOut.Height - FCaption.Font.AverageHeight)*0.5);

  end;
end;

{ TPropStringEditor }

procedure TPropStringEditor.CreateControl;
var
  Edit: TBEdit;
begin
  Edit := TBEdit.Create(FEditedData.Canvas);
  FControl := Edit;
  FEditedData.Inspector.DropControl(Edit);
  { draw real value of property }
  Edit.Text := TPropValueAccessProvider<string>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
  Edit.ColorText := FEditedData.Inspector.ColorValues;
  Edit.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
  Edit.Resize(FDrawedRect.Width, FEditedData.Inspector.RowHeight);
  Edit.ParentColor := true;
  Edit.SelectAll;
  Edit.Focused := true;
  ObsrvOnKeyPress := CreateKeyObserver(Edit.EventKeyPress, OnKeyPress);
  ObsrvOnKeyDown := CreateKeyObserver(Edit.EventKeyDown, OnKeyDown);
end;

procedure TPropStringEditor.Draw(var DrawRect: TRect);
begin
  inherited Draw(DrawRect);
  if not FEditedData.Selected then
    FText.Text := TPropValueAccessProvider<string>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
end;

procedure TPropStringEditor.OnKeyDown(const Data: BKeyData);
begin
 if Data.Key = 13 then
    UpdateValue
  else
  if Data.Key = 27 then
    TBEdit(FControl).Text := TPropValueAccessProvider<string>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
end;

procedure TPropStringEditor.OnKeyPress(const Data: BKeyData);
begin
  if Data.Key > 0 then
    FValueChaned := true;
end;

procedure TPropStringEditor.UpdateValue;
begin
  inherited;
  ChangeValueInStyle(TBEdit(FControl).Text);
  TPropValueAccessProvider<string>.SetPropValue(FEditedData.Owner, FEditedData.Prop, TBEdit(FControl).Text);
  FValueChaned := false;
end;

{ TObjectInspector }

procedure TObjectInspector.SetDrawedProp(Prop: TObjectPropGroup);
begin
  FDrawedProps.Items[FDrawedProps.Count] := Prop;
end;

procedure TObjectInspector.SetInspectedObject(AValue: TObject);
begin
  //if FInspectedObject = AValue then
  //  exit;
  FreeAndNil(Root);
  FInspectedObject := AValue;
  if AValue <> nil then
    Root := TObjectPropGroup.Create(Self, FInspectedObject, nil, nil, 0);
  BeginDraw;
  try
    BuildView;
  finally
    EndDraw;
  end;
end;

procedure TObjectInspector.SetRowHeight(AValue: int32);
begin
  if FRowHeight = AValue then
    exit;
  FRowHeight := AValue;
end;

procedure TObjectInspector.SetColorBrushPropsName(const Value: TGuiColor);
begin
  FColorBrushPropsName := Value;
  BuildView;
end;

procedure TObjectInspector.SetColorLeftBorder(const Value: TGuiColor);
begin
  FColorLeftBorder := Value;
  BuildView;
end;

procedure TObjectInspector.SetColorPropsName(const Value: TGuiColor);
begin
  FColorPropsName := Value;
  BuildView;
end;

procedure TObjectInspector.SetColorValues(const Value: TGuiColor);
begin
  FColorValues := Value;
  BuildView;
end;

procedure TObjectInspector.UpdateScrollBar;
begin
  if FDrawedProps.Count * RowHeight > Height then
  begin
    if Height <> FVertScrollBar.Size then
      FVertScrollBar.Size := round(Height);
    if not FVertScrollBar.Visible then
      FVertScrollBar.Visible := true;
  end else
  if FVertScrollBar.Visible then
    FVertScrollBar.Visible := false;
end;

procedure TObjectInspector.PrevValue;
begin
  if (IndexSelected > 0) and (IndexSelected < FDrawedProps.Count) and (FDrawedProps.Items[IndexSelected].Selected) then
  begin
    FDrawedProps.Items[IndexSelected].Selected := false;
    dec(IndexSelected);
    FDrawedProps.Items[IndexSelected].Selected := true;
    if IndexSelected * RowHeight < FVertScrollBar.Position then
      FVertScrollBar.Position := FVertScrollBar.Position - RowHeight;
    BeginDraw;
    try
      BuildView;
    finally
      EndDraw;
    end;
  end;
end;

procedure TObjectInspector.BeginDraw;
begin
  inc(CountPainting);
end;

procedure TObjectInspector.EndDraw;
begin
  dec(CountPainting);
  if CountPainting = 0 then
    BuildView;
end;

{procedure TObjectInspector.LoadDefaultDarkScheme;
begin
  FColorLeftBorder := TGuiColors.Cream;
  FColorValues := $FFE0BF13;
  FColorPropsName := TGuiColors.White;
  FColorBrushPropsName := TGuiColor($FFE0E0E0);
end; }

procedure TObjectInspector.LoadDefaultLightScheme;
begin
  FColorLeftBorder := TGuiColors.Cream;
  FColorValues := TGuiColors.Blue;
  FColorPropsName := TGuiColors.Black;
  FColorBrushPropsName := TGuiColor($FFE0E0E0);
end;

procedure TObjectInspector.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  //FBody.Size := Vec2(AWidth, AHeight);
  FBorderRect.Size := vec2(AWidth, AHeight);
  FBorderRect.Build;
  if SplitterPos = 0 then
    SplitterPos := round(Width * 0.5);
  UpdateScrollBar;
  BeginDraw;
  try
    BuildView;
  finally
    EndDraw;
  end;
end;

procedure TObjectInspector.ChangePropAfter(Group: TObjectPropGroup; Editor: TPropEditor);
begin
  if Assigned(FOnChangePropAfter) then
    FOnChangePropAfter(Group, Editor);
end;

procedure TObjectInspector.ChangePropBefor(Group: TObjectPropGroup; Editor: TPropEditor);
begin
  if Assigned(FOnChangePropBefor) then
    FOnChangePropBefor(Group, Editor);
end;

constructor TObjectInspector.Create(ACanvas: TBCanvas);
begin
  inherited;
  FColor := Cardinal($fffffa);
  FThemeManager := bs.gui.themes.TBTheme.Create;
  LoadDefaultLightScheme;
  SplitterPos := round(Width * 0.5);
  FDrawedProps := TListVec<TObjectPropGroup>.Create;
  FRowHeight := round(ROW_SIZE);

  FMainBody := TRectangle.Create(FCanvas, nil);
  TRectangle(FMainBody).Size := DefaultSize;
  TRectangle(FMainBody).Fill := true;
  FMainBody.Data.AsStencil := true;
  FMainBody.Data.DrawInstance := DrawClipArea;
  FMainBody.Color := ColorByteToFloat(FColor, true);
  FMainBody.Data.DragResolve := false;

  FBorderShape := TFreeShape.Create(FCanvas, FMainBody);
  FBorderShape.Color := ColorByteToFloat(FColorLeftBorder, true);
  FBorderShape.Data.Interactive := false;
  // for overlap property names
  FBorderShape.Layer2d := 2;

  FBorderLine := TPath.Create(FCanvas, FBorderShape);
  FBorderLine.Closed := true;
  FBorderLine.Color := ColorByteToFloat(TGuiColors.Gray, true);
  FBorderLine.InterpolateSpline := TInterpolateSpline.isNone;
  FBorderLine.Data.Interactive := false;

  FBorderRect := TRectangle.Create(FCanvas, FMainBody);
  FBorderRect.Fill := false;
  FBorderRect.Layer2d := 3;
  FBorderRect.Color := ColorByteToFloat(Cardinal(TGuiColors.Gray), true);
  FBorderRect.Align := TObjectAlign.oaClient;

  Splitter := TLine.Create(FCanvas, FMainBody);
  Splitter.Layer2d := 4;
  Splitter.Color := ColorByteToFloat(Cardinal(TGuiColors.Gray), true);
  Splitter.Data.Interactive := false;

  SplitterBack := TLine.Create(FCanvas, Splitter);
  SplitterBack.Data.DragResolve := false;
  SplitterBack.Data.Opacity := 0.0;
  SplitterBack.WidthLine := 5;
  SplitterBack.Position2d := vec2(-2, 0);

  EventSplitterMouseDown := SplitterBack.Data.EventMouseDown.CreateObserver(GUIThread, MouseDownSplitter);
  EventSplitterMouseUp := SplitterBack.Data.EventMouseUp.CreateObserver(GUIThread, MouseUpSplitter);

  EventSceneMouseWeel := FCanvas.Renderer.EventMouseWeel.CreateObserver(GUIThread, OnScroll);

  EventBodyMouseDown := FMainBody.Data.EventMouseDown.CreateObserver(GUIThread, MouseDownBody);
  EventBodyMouseMove := FMainBody.Data.EventMouseMove.CreateObserver(GUIThread, MouseMoveBody);
  EventBodyMouseDblClick := FMainBody.Data.EventMouseDblClick.CreateObserver(GUIThread, DblClick);

  FVertScrollbar := TBScrollBar.Create(FCanvas);
  FVertScrollbar.ParentControl := Self;
  FVertScrollBar.Horizontal := false;
  FVertScrollBar.Align := TObjectAlign.oaRight;
  FVertScrollBar.Visible := false;
  FVertScrollBar.OnChangePosition := OnScrollVert;
  Canvas.Font.SizeInPixels := TBCustomEdit.FONT_SIZE_IN_PIXELS_DEFAULT;
end;

procedure TObjectInspector.BuildView;
var
  index: int32;
  gr: TObjectPropGroup;
  r: TRect;
  i: Integer;
begin
  inherited;
  if CountPainting > 0 then
    exit;
  FBorderShape.Clear;
  FBorderShape.BeginContour;
  FBorderLine.Clear;
  CountPainting := 1;
  try
    FDrawedProps.Count := 0;
    FMainBody.Build;
    FBorderShape.AddPoint(vec2(0.0, 0.0));
    FBorderShape.AddPoint(vec2(BORDER_SIZE_LEFT, 0.0));
    FBorderLine.AddPoint(vec2(0.0, 0.0));
    FBorderLine.AddPoint(vec2(BORDER_SIZE_LEFT, 0.0));
    index := 0;

    r.Left := 0;
    r.Top := -FVertScrollBar.Position;
    if Assigned(Root) then
    begin
      if not FVertScrollBar.Visible then
        r.Width := round(Width)
      else
        r.Width := round(Width - FVertScrollBar.Width);
      r.Height := FRowHeight;
      Root.Draw(index, r, SplitterPos);
      if (FDrawedProps.Count > 0) then
      begin
        gr := FDrawedProps.Items[FDrawedProps.Count - 1];
        if (gr.Level > 1) then
          gr.DrawLowerCorners((gr.Level-1)*BORDER_SIZE_LEFT, FDrawedProps.Count*FRowHeight-FVertScrollBar.Position, (gr.Level-1)*BORDER_SIZE_LEFT);
      end;
    end;

    Splitter.A := vec2(SplitterPos, 0);
    Splitter.B := vec2(SplitterPos, Height);
    Splitter.Length := Height;
    Splitter.Build;
    Splitter.Position2d := vec2(SplitterPos, 0);
    SplitterBack.A := Splitter.A;
    SplitterBack.B := Splitter.B;
    SplitterBack.Build;
    SplitterBack.Position2d := vec2(-2.0, 0.0);
  finally
    CountPainting := 0;
  end;

  if r.Bottom <> Height then
  begin
    FBorderShape.AddPoint(vec2(BORDER_SIZE_LEFT, Height));
    FBorderLine.AddPoint(vec2(BORDER_SIZE_LEFT, Height-1));
  end;
  FBorderShape.AddPoint(vec2(0.0, Height));
  for i := FDrawedProps.Count - 1 downto 0 do
    FBorderShape.AddPoint(vec2(0.0, i*FRowHeight));
  FBorderShape.EndContour;
  FBorderShape.Build;
  FBorderShape.Position2d := vec2(0.0, 0.0);
  FBorderLine.AddPoint(vec2(0.0, Height-1));
  FBorderLine.Build;
end;

procedure TObjectInspector.DblClick(const Event: BMouseData);
var
  gr: TObjectPropGroup;
  pos: TVec2f;
begin
  inherited;
  if (FDrawedProps.Count > 0) and (IndexSelected < FDrawedProps.Count) then
  begin
    pos := vec2(Event.X, Event.Y) - MainBody.AbsolutePosition2d;
    gr := FDrawedProps.Items[IndexSelected];
    if (gr.Level * FRowHeight < pos.X) and (pos.X < SplitterPos) then
      gr.Expanded := not gr.Expanded;
    BuildView;
  end;
end;

function TObjectInspector.DefaultSize: TVec2f;
begin
  Result := vec2(220, 420);
end;

destructor TObjectInspector.Destroy;
begin
  InspectedObject := nil;
  EventSceneMouseWeel := nil;
  EventSplitterMouseDown := nil;
  EventSplitterMouseUp := nil;
  EventBodyMouseDown := nil;
  EventBodyMouseMove := nil;
  EventBodyMouseDblClick := nil;
  FreeAndNil(Root);
  FDrawedProps.Free;
  FThemeManager.Free;
  inherited Destroy;
end;

procedure TObjectInspector.DrawClipArea(Instance: PRendererGraphicInstance);
begin
  { fill shape FClipObject as the stencil for ban draw outside him }
  glClear ( GL_STENCIL_BUFFER_BIT );
  glClearStencil ( 0 );
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
end;

procedure TObjectInspector.MouseDownBody(const Event: BMouseData);
var
  i: int32;
  _y: int32;
  r: TRect;
  gr: TObjectPropGroup;
  rect: TRectBSf;
begin
  rect.Position := FMainBody.AbsolutePosition2d;
  rect.Size := vec2(FMainBody.Width, FMainBody.Height);
  if RectContains(rect, vec2(Event.X, Event.Y)) then
  begin
      _y := round(Event.Y - rect.Position.y - FVertScrollBar.Position);
      if not FVertScrollBar.Visible then
        i := (Event.Y - round(rect.Position.y)) div FRowHeight
      else
        i := _y div FRowHeight;

      if i <> IndexSelected then
      begin
        if (IndexSelected < FDrawedProps.Count) then
        begin
          FDrawedProps.Items[IndexSelected].SetSelected(false);
        end;
        IndexSelected := i;
      end;

      if IndexSelected < FDrawedProps.Count then
      begin
        BeginDraw;
        try
          gr := FDrawedProps.Items[IndexSelected];
          gr.SetSelected(true);
          if gr.HasChildren then
          begin
            r.Left := round((gr.Level - 1) * BORDER_SIZE_LEFT + UNFOLD_RECT_POS_LEFT);
            r.Top := round(i*FRowHeight + UNFOLD_RECT_POS_TOP);
            r.Width := round(UNFOLD_RECT_SIZE);
            r.Height := round(UNFOLD_RECT_SIZE);
            if r.Contains(Point(round(Event.X - rect.Position.x), _y)) then
            begin
              gr.Expanded := not gr.Expanded;
            end;
          end;
        finally
          EndDraw;
        end;
      end;
  end;
end;

procedure TObjectInspector.MouseDownSplitter(const Event: BMouseData);
var
  pos: TVec2f;
begin
  MouseIsDownOnSplitter := true;
  pos := MainBody.AbsolutePosition2d;
  MousePos := Point(Event.X-round(pos.x), Event.Y-round(pos.y));
end;

procedure TObjectInspector.MouseMoveBody(const Event: BMouseData);
var
  pos: TVec2f;
begin
  inherited;
  pos := MainBody.AbsolutePosition2d;
  MousePos := Point(Event.X-round(pos.x), Event.Y-round(pos.y));
  if MouseIsDownOnSplitter then
  begin
    if (MousePos.x > BORDER_SIZE_LEFT * 2.0) and (MousePos.x < Width - BORDER_SIZE_LEFT) and (SplitterPos <> MousePos.x) then
    begin
      SplitterPos := MousePos.x;
      BuildView;
    end;
  end;
end;

procedure TObjectInspector.MouseUpSplitter(const Event: BMouseData);
var
  pos: TVec2f;
begin
  inherited;
  pos := MainBody.AbsolutePosition2d;
  MousePos := Point(Event.X-round(pos.x), Event.Y-round(pos.y));
  MouseIsDownOnSplitter := false;
end;

procedure TObjectInspector.NextValue;
begin
  if (IndexSelected >= 0) and (IndexSelected < FDrawedProps.Count - 1) and (FDrawedProps.Items[IndexSelected].Selected) then
  begin
    FDrawedProps.Items[IndexSelected].Selected := false;
    inc(IndexSelected);
    FDrawedProps.Items[IndexSelected].Selected := true;
    if (IndexSelected + 1) * FRowHeight + FVertScrollBar.Position > Height then
      FVertScrollBar.Position := FVertScrollBar.Position + FRowHeight;
    BeginDraw;
    try
      BuildView;
    finally
      EndDraw;
    end;
  end;
end;

procedure TObjectInspector.OnScroll(const Event: BMouseData);
begin
  if FVertScrollBar.Visible then
  begin
    FVertScrollBar.Position := FVertScrollBar.Position - Event.DeltaWeel;
    BeginDraw;
    try
      BuildView;
    finally
      EndDraw;
    end;
  end;
end;

procedure TObjectInspector.OnScrollVert(ScrollBar: TBScrollBar);
begin
  BeginDraw;
  try
    BuildView;
  finally
    EndDraw;
  end;
end;

{ TPropColorEditor }

constructor TPropColorEditor.Create(AEditedData: TObjectPropGroup);
begin
  inherited;

end;

procedure TPropColorEditor.CreateControl;
var
  cl: TGuiColor;
  ColorEdit: TBColorBox;
begin
  ColorEdit := TBColorBox.Create(FEditedData.Canvas);
  FControl := ColorEdit;
  ColorEdit.ParentControl := FEditedData.Inspector;
  // makes a little above other objects, because stencil test can hide other objects
  // if they appeared on the same layer of combobox list
  ColorEdit.MainBody.Layer2d := 10;
  { draw real value of property }
  cl := TPropValueAccessProvider<TGuiColor>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
  ColorEdit.SelectedColor := cl and $FFFFFF;
  ColorEdit.OnChange := OnChangeEdit;
  ColorEdit.Resize(FDrawedRect.Width, FDrawedRect.Height);
  ColorEdit.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
  ColorEdit.ParentColor := true;
  ColorEdit.ColorText := FEditedData.Inspector.ColorValues;
  if FEditedData.Selected then
    ColorEdit.Focused := true;
end;

destructor TPropColorEditor.Destroy;
begin
  ColorRect.Free;
  inherited;
end;

procedure TPropColorEditor.Draw(var DrawRect: TRect);
var
  cl: TGuiColor;
begin
  inherited Draw(DrawRect);
  if not FEditedData.Selected then
  begin
    if not Assigned(ColorRect) then
    begin
      ColorRect := TRectangle.Create(FEditedData.Canvas, FEditedData.Inspector.MainBody);
      ColorRect.Data.Interactive := false;
      ColorRect.Size := vec2(FEditedData.Inspector.RowHeight - 4.0, FEditedData.Inspector.RowHeight - 4.0);
      ColorRect.Fill := true;
    end;
    { draw real value of property }
    ColorRect.Build;
    cl := TPropValueAccessProvider<uint32>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
    ColorRect.Color := ColorByteToFloat(cl, true);
    ColorRect.Position2d := vec2(DrawRect.Left + 2.0, DrawRect.Top + 2.0);
    FText.Text := AnsiToString(ColorToString(cl and $FFFFFF));
    //FText.Text := IntToStr(TPropValueAccessProvider<int32>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
    FText.Position2d := vec2(ColorRect.Position2d.left + ColorRect.Width + 2.0, DrawRect.Top + (DrawRect.Height - FText.Font.AverageHeight)*0.5);
  end else
    FreeAndNil(ColorRect);
end;

procedure TPropColorEditor.OnChangeEdit(Sender: TObject);
begin
  UpdateValue;
end;

procedure TPropColorEditor.UpdateValue;
var
  cl: TGuiColor;
begin
  inherited;
  cl := TBColorBox(FControl).SelectedColor;
  { Save property value in style }
  ChangeValueInStyle(cl);
  TPropValueAccessProvider<TGuiColor>.SetPropValue(FEditedData.Owner, FEditedData.Prop, cl);
end;

{ TPropIntEditor }

procedure TPropIntEditor<T>.CreateControl;
var
  IntEdit: TBSpinEdit;
begin
  IntEdit := TBSpinEdit.Create(FEditedData.Canvas);
  FControl := IntEdit;
  IntEdit.ParentControl := FEditedData.Inspector;
  IntEdit.ColorText := FEditedData.Inspector.ColorValues;
  IntEdit.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
  IntEdit.Resize(FDrawedRect.Width, FDrawedRect.Height);
  ObsrvOnKeyPress := CreateKeyObserver(IntEdit.EventKeyPress, OnKeyPress);
  ObsrvOnKeyDown := CreateKeyObserver(IntEdit.EventKeyDown, OnKeyDown);
  IntEdit.ParentColor := true;
  if FEditedData.Selected then
    IntEdit.Focused := true;
end;

destructor TPropIntEditor<T>.Destroy;
begin
  inherited;
end;

procedure TPropIntEditor<T>.Draw(var DrawRect: TRect);
var
  ch_pos: boolean;
begin
  ch_pos := (DrawRect.Left <> FDrawedRect.Left) or (DrawRect.Top <> FDrawedRect.Top) or
    (DrawRect.Width <> FDrawedRect.Width) or (DrawRect.Height <> FDrawedRect.Height);
  inherited;
  if FEditedData.Selected then
  begin
    if Assigned(FText) then
      FreeAndNil(FText);
    if FControl = nil then
      CreateControl;
    if ch_pos then
      SetPosCtrls;
  end else
  begin
    if FControl <> nil then
      FreeAndNil(FControl);
  end;
end;

procedure TPropIntEditor<T>.OnKeyDown(const Data: BKeyData);
begin
  if Data.Key = 13 then
    UpdateValue;
end;

procedure TPropIntEditor<T>.OnKeyPress(const Data: BKeyData);
begin
  if Data.Key > 0 then
    FValueChaned := true;
end;

{ TPropEditorTempl<T> }

procedure TPropEditorTempl<T>.ChangeValueInStyle(const Value: T);
begin
  BeforChangeValueInStyle;
  { Change property value }
  FEditedData.PropStyleItem.SetValue(Value);
  AfterChangeValueInStyle;
end;

{ TPropEditorFloatTemplate<T> }

procedure TPropEditorFloatTemplate<T>.CreateControl;
var
  Edit: TBEdit;
begin
  Edit := TBEdit.Create(FEditedData.Canvas);
  FControl := Edit;
  Edit.ParentControl := FEditedData.Inspector;
  Edit.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
  Edit.Resize(FDrawedRect.Width, FDrawedRect.Height);
  Edit.ParentColor := true;
  Edit.ColorText := FEditedData.Inspector.ColorValues;
  ObsrvOnKeyPress := CreateKeyObserver(Edit.EventKeyPress, OnKeyPress);
  ObsrvOnKeyDown := CreateKeyObserver(Edit.EventKeyDown, OnKeyDown);
  if FEditedData.Selected then
    Edit.Focused := true;
end;

procedure TPropEditorFloatTemplate<T>.OnKeyDown(const Data: BKeyData);
begin
  if Data.Key = 13 then
    UpdateValue;
end;

procedure TPropEditorFloatTemplate<T>.OnKeyPress(const Data: BKeyData);
begin
  if Data.Key > 0 then
    FValueChaned := true;
end;

{ TPropEditorInt32 }

procedure TPropEditorInt32.CreateControl;
begin
  inherited CreateControl;
  { draw real value of property }
  TBSpinEdit(FControl).Value := TPropValueAccessProvider<int32>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
  TBSpinEdit(FControl).SelectAll;
  if FEditedData.Selected then
    TBSpinEdit(FControl).Focused := true;
end;

procedure TPropEditorInt32.Draw(var DrawRect: TRect);
begin
  inherited Draw(DrawRect);
  if not FEditedData.Selected then
  begin
    { draw real value of property }
    FText.Text := IntToStr(TPropValueAccessProvider<int32>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  end;
end;

procedure TPropEditorInt32.OnKeyDown(const Data: BKeyData);
begin
  inherited;
  if Data.Key = 27 then
    TBSpinEdit(FControl).Value := TPropValueAccessProvider<int32>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
end;

procedure TPropEditorInt32.UpdateValue;
var
  i: int32;
begin
  i := TBSpinEdit(FControl).Value;
  { Save property value in style }
  ChangeValueInStyle(i);
  TPropValueAccessProvider<int32>.SetPropValue(FEditedData.Owner, FEditedData.Prop, i);
end;

{ TPropEditorFloat }

procedure TPropEditorFloat.CreateControl;
begin
  inherited CreateControl;
  TBEdit(FControl).FilterChars := '0123456789,.';
  { draw real value of property }
  TBEdit(FControl).Text := FloatToStr(TPropValueAccessProvider<BSFloat>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  TBEdit(FControl).SelectAll;
end;

procedure TPropEditorFloat.Draw(var DrawRect: TRect);
begin
  inherited Draw(DrawRect);
  if not FEditedData.Selected then
  begin
    { draw real value of property }
    FText.Text := FloatToStr(TPropValueAccessProvider<BSFloat>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  end;
end;

procedure TPropEditorFloat.OnKeyDown(const Data: BKeyData);
begin
  inherited;
  if Data.Key = 27 then
    TBEdit(FControl).Text := FloatToStr(TPropValueAccessProvider<BSFloat>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
end;

procedure TPropEditorFloat.UpdateValue;
var
  val: BSFloat;
begin
  val := 0.0;
  if not TryStrToFloat(TBEdit(FControl).Text, val) then
    exit;

  ChangeValueInStyle(val);
  TPropValueAccessProvider<BSFLoat>.SetPropValue(FEditedData.Owner, FEditedData.Prop, val);
end;

{ TPropEditorDouble }

procedure TPropEditorDouble.CreateControl;
begin
  inherited;
  TBEdit(FControl).FilterChars := '0123456789,.';
  { draw real value of property }
  TBEdit(FControl).Text := FloatToStr(TPropValueAccessProvider<Double>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  TBEdit(FControl).SelectAll;
end;

procedure TPropEditorDouble.Draw(var DrawRect: TRect);
begin
  inherited;
  if not FEditedData.Selected then
  begin
    { draw real value of property }
    FText.Text := FloatToStr(TPropValueAccessProvider<Double>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  end;
end;

procedure TPropEditorDouble.OnKeyDown(const Data: BKeyData);
begin
  inherited;
  if Data.Key = 27 then
    TBEdit(FControl).Text := FloatToStr(TPropValueAccessProvider<Double>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
end;

procedure TPropEditorDouble.UpdateValue;
var
  val: double;
begin
  val := 0.0;
  if not TryStrToFloat(TBEdit(FControl).Text, val) then
    exit;
  ChangeValueInStyle(val);
  TPropValueAccessProvider<double>.SetPropValue(FEditedData.Owner, FEditedData.Prop, val);
end;

{ TPropEditorInt64 }

procedure TPropEditorInt64.CreateControl;
var
  i: int64;
begin
  inherited CreateControl;
  { draw real value of property }
  i := TPropValueAccessProvider<int64>.GetPropValue(FEditedData.Owner,
    FEditedData.Prop);
  TBSpinEdit(FControl).Value := i;
  TBSpinEdit(FControl).SelectAll;
  if FEditedData.Inspector.Visible then
    TBSpinEdit(FControl).Focused := true;
end;

procedure TPropEditorInt64.Draw(var DrawRect: TRect);
begin
  inherited;
  if not FEditedData.Selected then
  begin
    { draw real value of property }
    FText.Text := IntToStr(TPropValueAccessProvider<Int64>.GetPropValue(FEditedData.Owner, FEditedData.Prop));
  end;
end;

procedure TPropEditorInt64.OnKeyDown(const Data: BKeyData);
begin
  inherited;
  if Data.Key = 27 then
    TBSpinEdit(FControl).Value := TPropValueAccessProvider<int64>.GetPropValue(FEditedData.Owner, FEditedData.Prop);
end;

procedure TPropEditorInt64.UpdateValue;
var
  i: int64;
begin
  i := TBSpinEdit(FControl).Value;
  { Save property value in style }
  ChangeValueInStyle(i);
  TPropValueAccessProvider<int64>.SetPropValue(FEditedData.Owner, FEditedData.Prop, i);
end;

{ TPropBooleanEditor }

procedure TPropBooleanEditor.CreateControl;
var
  ComboBox: TBComboBox;
begin
  inherited;
  ComboBox := TBComboBox.Create(FEditedData.Canvas);
  ComboBox.AddItem('False');
  ComboBox.AddItem('True');
  FControl := ComboBox;
  FEditedData.Inspector.DropControl(ComboBox);
  { draw real value of property }
  if TPropValueAccessProvider<boolean>.GetPropValue(FEditedData.Owner, FEditedData.Prop) then
    ComboBox.SelectedIndex := 1
  else
    ComboBox.SelectedIndex := 0;
  ComboBox.OnChange := OnChangeEdit;
  ComboBox.ColorText := FEditedData.Inspector.ColorValues;
  ComboBox.Position2d := vec2(FDrawedRect.Left, FDrawedRect.Top);
  ComboBox.Resize(FDrawedRect.Width, FEditedData.Inspector.RowHeight);
  ComboBox.ParentColor := true;
  ComboBox.ReadOnly := true;
  ComboBox.ShowCursor := false;
  if FEditedData.Selected then
    ComboBox.Focused := true;
end;

procedure TPropBooleanEditor.Draw(var DrawRect: TRect);
begin
  inherited;
  if Assigned(FText) and not FEditedData.Selected then
  begin
    if TPropValueAccessProvider<boolean>.GetPropValue(FEditedData.Owner, FEditedData.Prop) then
      FText.Text := 'True'
    else
      FText.Text := 'False';
  end;
end;

procedure TPropBooleanEditor.OnChangeEdit(Sender: TObject);
begin
  UpdateValue;
end;

procedure TPropBooleanEditor.UpdateValue;
begin
  inherited;
  if Assigned(FControl) then
  begin
    ChangeValueInStyle(TBComboBox(FControl).SelectedIndex = 1);
    TPropValueAccessProvider<boolean>.SetPropValue(FEditedData.Owner, FEditedData.Prop, TBComboBox(FControl).SelectedIndex = 1);
  end;
end;

initialization

  {$ifdef FPC}
  EDITORS_PROP[TypInfo.TTypeKind.tkAString] := TPropStringEditor;
  {$else}
  EDITORS_PROP[TypInfo.TTypeKind.tkString] := TPropStringEditor;
  {$endif}
  EDITORS_PROP[TypInfo.TTypeKind.tkUString] := TPropStringEditor;
  EDITORS_PROP[TypInfo.TTypeKind.tkLString] := TPropStringEditor;
  EDITORS_PROP[TypInfo.TTypeKind.tkWString] := TPropStringEditor;
  EDITORS_PROP[TypInfo.TTypeKind.tkInteger] := TPropEditorInteger;
  EDITORS_PROP[TypInfo.TTypeKind.tkInt64] := TPropEditorInt64;
  EDITORS_PROP[TypInfo.TTypeKind.tkFloat] := TPropEditorFloat;

  TPropEditor.RegisterEditor(string(PTypeInfo(TypeInfo(TGuiColor)).Name), TPropColorEditor);
  TPropEditor.RegisterEditor(string(PTypeInfo(TypeInfo(int8)).Name), TPropEditorInt8);
  TPropEditor.RegisterEditor(string(PTypeInfo(TypeInfo(int32)).Name), TPropEditorInt32);
  TPropEditor.RegisterEditor(string(PTypeInfo(TypeInfo(int64)).Name), TPropEditorInt64);
  TPropEditor.RegisterEditor(string(PTypeInfo(TypeInfo(boolean)).Name), TPropBooleanEditor);

end.

