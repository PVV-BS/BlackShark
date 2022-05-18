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

unit bs.gui.edit;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.events
  , bs.events.keyboard
  , bs.canvas
  , bs.scene
  , bs.gui.base
  , bs.gui.themes
  , bs.gui.themes.primitives
  , bs.animation
  , bs.strings
  , bs.font
  ;

type

  {$M+}

  { TBCustomEdit }

  TBCustomEdit = class(TBControl)
  public
    const
      LEFT_MARGIN_DEFAULT: int8 = 4;
      CURSOR_TOP_ALIGN: int8 = 3;
      FONT_SIZE_IN_PIXELS_DEFAULT: int8 = 9;

      DEFAULT_WIDTH = 60;
      DEFAULT_HEIGHT = 21;

  private
    FColorFrame: TGuiColor;
    FColorCursor: TGuiColor;
    FColorText: TGuiColor;
    FTextView: TCanvasText;
    Cursor: TLine;
    Selector: TRectangle;
    CursorAnimator: IBAnimationLinearFloat;
    { offset view in symbols }
    TextOffsetSymbols: int32;
    { position of cursor in symbols, begin from 1 }
    FPosCursorSymbols: int32;
    { absolut position of cursor relatively first symbol }
    PosCursorPixels: int32;
    { position of selector's rect }
    StartSelectedPixels: int32;
    { width of selector's rect }
    WidthSelectedPixels: int32;
    FCountSelected: int32;
    FStartSelected: int32;
    FText: TString;
    ObsrvOnMouseDown: IBMouseEventObserver;
    ObsrvOnMouseUp: IBMouseEventObserver;
    ObsrvOnMouseMove: IBMouseEventObserver;
    ObsrvOnMouseDblClick: IBMouseEventObserver;

    ObsrvOnKeyPress: IBKeyEventObserver;
    ObsrvOnKeyDown: IBKeyEventObserver;
    ObsrvAnimation: IBAnimationLinearFloatObsrv;
    FOnChange: TBControlNotify;
    FShowCursor: Boolean;
    FReadOnly: Boolean;
    FLeftMargin: BSFloat;
    FFilterChars: string;

    procedure CreateCursor;
    procedure FreeCursor;
    function GetCursorPosFromX(X: int32; out Pixels: int32): int32;
    procedure OnMouseMove(const Data: BMouseData);
    procedure OnMouseDblClick(const Data: BMouseData);
    procedure OnAnimate(const Data: BSFloat);
    procedure IncCursor;
    procedure DecCursor;
    procedure InsertSymbol(Symbol: WideChar);
    function GetText: string;
    procedure DrawBack(Instance: PRendererGraphicInstance);
    function GetVertPosText: BSFloat;
    procedure SetTextViewPosition;
    { remove all selected symbols or in the left from the cursor position }
    procedure DeleteSymbol;
    procedure SetNewCursorPos(IndexSymbol: int32; InPixels: int32);
    procedure DrawSelector;
    procedure SetCursorPosition(const Value: int32);
    procedure AdjustViewport;
    procedure SetTexoutWidth(const AValue: BSFloat);
    procedure SetColorCursor(const Value: TGuiColor);
    procedure SetColorFrame(const Value: TGuiColor);
    procedure SetShowCursor(const Value: Boolean);
    procedure SetLeftMargin(const Value: BSFloat);
    procedure UpdateCursorPos;
    procedure UpdateTextOutRect;
    function GetEventKeyPress: IBKeyPressEvent;
    function GetEventKeyDown: IBKeyPressEvent;
  protected
    Back: TRectangle;
    Frame: TRectangle;
    TextRect: TRectangle;
    FTextoutWidth: BSFloat;
    procedure SetFocused(Value: boolean); override;
    { return in pixels offset of a symbol in Index position }
    function FindOffsetOfSymbol(Index: int32; Start: int32 = 1): int32;
    { create entities are needed for the visual represent of a control }
    procedure DoKeyPress(const Data: BKeyData); virtual;
    procedure DoKeyDown(const Data: BKeyData); virtual;
    procedure SetText(const AValue: string); virtual;
    procedure OnKeyPress(const Data: BKeyData);
    procedure OnKeyDown(const Data: BKeyData);
    procedure SetScalable(const Value: boolean); override;
    procedure OnMouseDown(const Data: BMouseData); virtual;
    procedure OnMouseUp(const Data: BMouseData); virtual;
    procedure SetVisible(const AValue: boolean); override;
    procedure DoAfterScale; override;
    procedure SetColorText(const Value: TGuiColor); virtual;
    procedure SetColor(const Value: TGuiColor); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure BeforeDestruction; override;
    { the construction of the control of the entities created earlier with
      current properties }
    procedure BuildView; override;
    function DefaultSize: TVec2f; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    procedure SelectAll;
    { select Count symbols about StartSelected; if Count < 0 then selected to the
      left, otherwise to the right }
    procedure Select(Count: int32);
    procedure ClearSelection;
    property Text: string read GetText write SetText;
    property TextView: TCanvasText read FTextView;
    property CursorPosition: int32 read FPosCursorSymbols write SetCursorPosition;
    property CountSelected: int32 read FCountSelected;
    property StartSelected: int32 read FStartSelected write FStartSelected;
    { enforce to out text to TextoutWidth strip only, pixels }
    property TextoutWidth: BSFloat read FTextoutWidth write SetTexoutWidth;
    property LeftMargin: BSFloat read FLeftMargin write SetLeftMargin;
    property ShowCursor: Boolean read FShowCursor write SetShowCursor;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property ColorText: TGuiColor read FColorText write SetColorText;
    property ColorCursor: TGuiColor read FColorCursor write SetColorCursor;
    property ColorFrame: TGuiColor read FColorFrame write SetColorFrame;
    property OnChange: TBControlNotify read FOnChange write FOnChange;
    property FilterChars: string read FFilterChars write FFilterChars;
    property EventKeyPress: IBKeyPressEvent read GetEventKeyPress;
    property EventKeyDown: IBKeyPressEvent read GetEventKeyDown;
  end;

  TBCustomSpinEdit = class(TBCustomEdit)
  private
    const
      BTN_WIDTH = 11.0;
  private
    BtnUp: TRectangle;
    BtnDown: TRectangle;
    TriUp: TTriangle;
    TriDown: TTriangle;
    FMinValue: int64;
    FMaxValue: int64;
    ObsrvOnMouseDownBtnUp: IBMouseEventObserver;
    ObsrvOnMouseUpBtnUp: IBMouseEventObserver;
    ObsrvOnMouseDownBtnDown: IBMouseEventObserver;
    ObsrvOnMouseUpBtnDown: IBMouseEventObserver;
    ObsrvOnKeyPressBtnUp: IBKeyEventObserver;
    ObsrvOnKeyDownBtnUp: IBKeyEventObserver;
    ObsrvOnKeyPressBtnDown: IBKeyEventObserver;
    ObsrvOnKeyDownBtnDown: IBKeyEventObserver;
    TimeDown: uint32;
    WaitTimer: IBAnimationLinearFloat;
    WaitTimerObsrv: IBAnimationLinearFloatObsrv;
    WaitTimerUp: boolean;
    function GetValue: int64;
    procedure SetValue(const AValue: int64);
    procedure SetMaxValue(const AValue: int64);
    procedure SetMinValue(const AValue: int64);
    procedure CheckValue;
    procedure OnMouseDownBtnUp(const Data: BMouseData);
    procedure OnMouseDownBtnDown(const Data: BMouseData);
    procedure OnMouseUpBtnUp(const Data: BMouseData);
    procedure OnMouseUpBtnDown(const Data: BMouseData);
    procedure OnWaitTime(const AValue: BSFloat);
  protected
    procedure DoKeyPress(const Data: BKeyData); override;
    procedure DoKeyDown(const Data: BKeyData); override;
    procedure SetText(const AValue: string); override;
    procedure SetFocused(Value: boolean); override;
    procedure SetVisible(const AValue: boolean); override;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BuildView; override;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property Value: int64 read GetValue write SetValue;
    property MinValue: int64 read FMinValue write SetMinValue;
    property MaxValue: int64 read FMaxValue write SetMaxValue;
  end;

  TBEdit = class(TBCustomEdit)
  published
    property Text;
    property FontName;
    property Color;
    property ParentColor;
    property ColorText;
    property ColorCursor;
    property ColorFrame;
  end;

  TBSpinEdit = class(TBCustomSpinEdit)
  published
    property Value;
    property MinValue;
    property MaxValue;
    property FontName;
    property Color;
    property ParentColor;
    property ColorText;
    property ColorCursor;
    property ColorFrame;
  end;


implementation

uses
    Classes
  , SysUtils
  , bs.thread
  , bs.graphics
  , bs.scene.objects
  , bs.gl.es
  , bs.math
  , bs.config
  , bs.align
  ;

{ TBCustomEdit }

procedure TBCustomEdit.AdjustViewport;
var
  ch_pos: boolean;
begin
  ch_pos := false;

  while PosCursorPixels - FTextView.SceneTextData.OffsetX > FTextView.SceneTextData.OutToWidth do
  begin
    FTextView.SceneTextData.OffsetX := FTextView.SceneTextData.OffsetX +
      FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(TextOffsetSymbols)].Rect.Width +
      FTextView.SceneTextData.TxtProcessor.Delta;
    inc(TextOffsetSymbols);
    ch_pos := true;
  end;

  while (PosCursorPixels <= FTextView.SceneTextData.OffsetX) and (TextOffsetSymbols > 1) do
  begin
    dec(TextOffsetSymbols);
    FTextView.SceneTextData.OffsetX := FTextView.SceneTextData.OffsetX -
      FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(TextOffsetSymbols)].Rect.Width -
      FTextView.SceneTextData.TxtProcessor.Delta;
    ch_pos := true;
  end;

  if ch_pos then
    SetTextViewPosition;
end;

constructor TBCustomEdit.Create(ACanvas: TBCanvas);
begin
  inherited;
  FText := 'Edit';
  FColor := ColorFloatToByte(BS_CL_MSVS_EDITOR).value;
  FColorFrame := TGuiColors.Gray;
  FColorCursor := TGuiColors.Skyblue;
  FColorText := TGuiColors.White;
  if OwnCanvas then
    FCanvas.Font.SizeInPixels := round(FONT_SIZE_IN_PIXELS_DEFAULT*ToHiDpiScale);
  TextOffsetSymbols := 1;
  FShowCursor := true;
  FTextoutWidth := -1;
  //OnChangeFontSbscr := CreateEmptyObserver(Canvas.Font.OnChangeEvent, OnChangeFontEvent);
  //ReplaceObsrv := CreateEmptyObserver(FCanvas.EventReplaceFont, OnReplaceFont);
  TextRect := TRectangle(CreateMainBody(TRectangle));
  TextRect.Fill := true;
  TextRect.Color := BS_CL_MSVS_EDITOR;
  TextRect.Data.DragResolve := false;

  Back := TRectangle.Create(FCanvas, TextRect);
  Back.Fill := true;
  Back.Data.DrawInstance := DrawBack;
  Back.Data.Interactive := false;
  Back.Data.Opacity := 0.0;
  Back.Data.AsStencil := true;
  ObsrvOnMouseDown := CreateMouseObserver(TextRect.Data.EventMouseDown, OnMouseDown);
  ObsrvOnMouseUp := CreateMouseObserver(TextRect.Data.EventMouseUp, OnMouseUp);
  ObsrvOnMouseDblClick := CreateMouseObserver(TextRect.Data.EventMouseDblClick, OnMouseDblClick);
  Frame := TRectangle.Create(FCanvas, TextRect);
  Frame.Fill := false;
  Frame.Color := ColorByteToFloat(FColorFrame, true);
  Frame.Data.Interactive := false;
  Frame.Layer2d := 5;
  Frame.WidthLine := round(1*ToHiDpiScale);
  FTextView := TCanvasText.Create(FCanvas, Back);
  FTextView.Anchors[TAnchor.aRight] := false;
  FTextView.Anchors[TAnchor.aTop] := false;
  FTextView.Anchors[TAnchor.aLeft] := false;
  FTextView.Anchors[TAnchor.aBottom] := false;
  FTextView.Data.Interactive := false;
  FTextView.Text := FText;
  FTextView.Data.StencilTest := true;
  FTextView.Layer2d := 2;
  FTextView.Color := TColor4f(FColorText);
  Back.Size := DefaultSize;
  TextRect.Size := Back.Size;
  Frame.Size := Back.Size;
  FLeftMargin := LEFT_MARGIN_DEFAULT;
end;

procedure TBCustomEdit.BeforeDestruction;
begin
  FreeCursor;
  ObsrvOnMouseDown := nil;
  ObsrvOnMouseUp := nil;
  ObsrvOnMouseMove := nil;
  ObsrvOnMouseDblClick := nil;

  ObsrvOnKeyPress := nil;
  ObsrvOnKeyDown := nil;
  inherited;
end;

procedure TBCustomEdit.BuildView;
begin
  TextRect.Build;
  Back.Build;
  Back.Position2d := vec2(0.0, 0.0);
  Frame.Build;
  Frame.Position2d := vec2(0.0, 0.0);

  UpdateTextOutRect;

  PosCursorPixels := FindOffsetOfSymbol(FPosCursorSymbols);

  if FCountSelected <> 0 then
    Select(FCountSelected)
  else
    AdjustViewport;

  //SetNewCursorPos(GetCursorPosFromX(Data.X, StartSelectedPixels), StartSelectedPixels);
  if Assigned(Cursor) then
  begin
    Cursor.Build;
    UpdateCursorPos;
  end;

  SetTextViewPosition;
end;

procedure TBCustomEdit.ClearSelection;
begin
  FCountSelected := 0;
  WidthSelectedPixels := 0;
  FreeAndNil(Selector);
end;

procedure TBCustomEdit.CreateCursor;
begin
  if (not FShowCursor) or Assigned(Cursor) then
    exit;
  Cursor := TLine.Create(FCanvas, Back);
  Cursor.Length := Back.Height - (CURSOR_TOP_ALIGN shl 1);
  Cursor.WidthLine := round(2*ToHiDpiScale);
  Cursor.Data.Interactive := false;
  Cursor.Color := TColor4f(FColorCursor);
  Cursor.Data.Caption := 'cursor';
  Cursor.Build;
  Cursor.Position2d := vec2(FTextView.MarginLeft, CURSOR_TOP_ALIGN);
  Cursor.Data.StencilTest := true;
  CursorAnimator := CreateAniFloatLinear(GUIThread);
  ObsrvAnimation := CreateAniFloatLivearObsrv(CursorAnimator, OnAnimate, GUIThread);
  CursorAnimator.Duration := 600;
  CursorAnimator.Loop := true;
  CursorAnimator.LoopInverse := true;
  CursorAnimator.StartValue := 0.2;
  CursorAnimator.StopValue := 1.0;

  CursorAnimator.Run;
end;

procedure TBCustomEdit.DecCursor;
var
  pk: PKeyInfo;
  d: int32;
begin
  if FPosCursorSymbols > 1 then
  begin
    dec(FPosCursorSymbols);
    pk := FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(FPosCursorSymbols)];
    if pk <> nil then
    begin
      d := FTextView.SceneTextData.TxtProcessor.GetCharWidth(pk);
      dec(PosCursorPixels, d);
      AdjustViewport;
      UpdateCursorPos;
    end else
      raise Exception.Create('The glyph have not found!');
  end;
end;

function TBCustomEdit.DefaultSize: TVec2f;
begin
  Result.x := round(DEFAULT_WIDTH*ToHiDpiScale);
  Result.y := round(DEFAULT_HEIGHT*ToHiDpiScale);
  if Result.y + 2 < Canvas.Font.SizeInPixels then
    Result.y := round(Canvas.Font.SizeInPixels);
  if Result.x + 2 + FLeftMargin <= FTextView.Width then
    Result.x := FTextView.Width + 2 + FLeftMargin;
end;

procedure TBCustomEdit.DeleteSymbol;
begin
  if Assigned(Selector) and (FCountSelected <> 0) then
  begin
    { if FCountSelected < 0 then the cursor remains in itself place }
    if FCountSelected < 0 then
      FText.Delete(FStartSelected + FCountSelected, abs(FCountSelected))
    else
    begin
      CursorPosition := FStartSelected;
      FText.Delete(FStartSelected, FCountSelected);
    end;
    ClearSelection;
    FTextView.Text := FText;
    SetTextViewPosition;
  end else
  if FPosCursorSymbols > 1 then
  begin
    DecCursor;
    FText.Delete(FPosCursorSymbols);
    FTextView.Text := FText;
    SetTextViewPosition;
  end;
end;

procedure TBCustomEdit.DoKeyDown(const Data: BKeyData);
begin
  if Data.Key = VK_BS_LEFT then
  begin
    DecCursor;
    if (ssShift in Data.Shift) and (FPosCursorSymbols <> FStartSelected) then
      Select(FPosCursorSymbols - FStartSelected)
    else
    if FCountSelected <> 0 then
      ClearSelection;
  end else
  if Data.Key = VK_BS_RIGHT then
  begin
    IncCursor;
    if (ssShift in Data.Shift) and (FPosCursorSymbols <> FStartSelected) then
      Select(FPosCursorSymbols - FStartSelected)
    else
    if FCountSelected <> 0 then
      ClearSelection;
  end else
  if Data.Key = VK_BS_BACK then
    DeleteSymbol else
  if Data.Key = VK_BS_DELETE then
  begin
    if FPosCursorSymbols <= FText.Len + 1 then
    begin
      if FCountSelected = 0 then
      begin
        if (FPosCursorSymbols <= FText.Len) and (FText.Len > 0) then
        begin
          { inc step to the right }
          IncCursor;
          DeleteSymbol;
        end;
      end else
        DeleteSymbol; // delete all selected
    end;
  end else
  if Data.Key = VK_BS_SHIFT then
  begin
    if FCountSelected = 0 then
      FStartSelected := FPosCursorSymbols;
  end;
end;

procedure TBCustomEdit.DoKeyPress(const Data: BKeyData);
begin
  if (Data.Key = 13) or
     ((Canvas.Renderer.Keyboard[VK_BS_A]) and (ssCtrl in Canvas.Renderer.ShiftState))  then  // Enter or Ctrl+A
  begin
    SelectAll;
    exit;
  end;

  if FReadOnly or (Data.Key = 0) then
    exit;

  if (length(FFilterChars) > 0) and (pos(WideChar(Data.Key), FFilterChars) <= 0) then
    exit;

  if FCountSelected <> 0 then
    DeleteSymbol;

  InsertSymbol(WideChar(Data.Key));

  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCustomEdit.DoAfterScale;
begin
  inherited DoAfterScale;
  UpdateTextOutRect;
  SetTextViewPosition;
  PosCursorPixels := FindOffsetOfSymbol(FPosCursorSymbols);
  UpdateCursorPos;
  if FCountSelected <> 0 then
    DrawSelector;
end;

procedure TBCustomEdit.DrawBack(Instance: PRendererGraphicInstance);
begin
  { fill the shape Back as the stencil for ban draw outside him }
  //glClear ( GL_STENCIL_BUFFER_BIT );
  glClearStencil ( 0 );
  glStencilFunc(GL_ALWAYS, 1, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
  glStencilFunc(GL_EQUAL, 1, $FF);
  TObjectVertexes(Instance.Instance.Owner).DrawVertexs(Instance);
end;

procedure TBCustomEdit.DrawSelector;
var
  pos, w: BSFloat;
begin
  if Selector = nil then
  begin
    Selector := TRectangle.Create(FCanvas, Back);
    //Selector.Data.StencilTest := true;
    Selector.Fill := true;
    Selector.Color := ColorByteToFloat($FFFF9033);
    Selector.Data.Opacity := 0.8;
    Selector.Data.Interactive := false;
    Selector.BanScalableMode := true;
    Selector.Data.Caption := 'selector';
  end;
  StartSelectedPixels := FindOffsetOfSymbol(StartSelected);
  WidthSelectedPixels := abs(FindOffsetOfSymbol(StartSelected+FCountSelected) - StartSelectedPixels);
  pos := (min(StartSelectedPixels, PosCursorPixels) - FTextView.SceneTextData.OffsetX) + LeftMargin;

  if pos < LeftMargin then
    pos := LeftMargin;

  if FTextView.SceneTextData.OffsetX > StartSelectedPixels then
    w := (WidthSelectedPixels - FTextView.SceneTextData.OffsetX + StartSelectedPixels)
  else
    w := WidthSelectedPixels;

  if pos - LeftMargin + w > FTextView.Width then
    w := FTextView.Width - (pos - LeftMargin);

  if pos + w > Width then
    w := Width - pos;

  Selector.Size := vec2(w, Height - (CURSOR_TOP_ALIGN shl 1));

  Selector.Build;
  Selector.Position2d := vec2(pos, CURSOR_TOP_ALIGN);
end;

function TBCustomEdit.FindOffsetOfSymbol(Index: int32; Start: int32 = 1): int32;
var
  i: int32;
  res: BSFloat;
  k: PKeyInfo;
begin
  if (Index > FText.Len + 1) or (Start > FText.Len) then
    exit(0);
  res := 0.0;
  for i := Start to Index - 1 do
  begin
    k := FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(i)];
    if k = nil then
      continue;
    res := res + FTextView.SceneTextData.TxtProcessor.GetCharWidth(k);
  end;
  //Result := int32(round(res)) + (Index - Start) * FTextView.SceneTextData.TxtProcessor.Delta;
  Result := int32(round(res));
end;

procedure TBCustomEdit.FreeCursor;
begin
  if not Assigned(Cursor) then
    exit;
  CursorAnimator.Stop;
  ObsrvAnimation := nil;
  CursorAnimator := nil;
  FreeAndNil(Cursor);
end;

function TBCustomEdit.GetText: string;
begin
  Result := FText;
end;

function TBCustomEdit.GetVertPosText: BSFloat;
begin
  Result := (Height - FTextView.Font.SizeInPixels) * 0.5 - 2;
end;

procedure TBCustomEdit.IncCursor;
var
  pk: PKeyInfo;
  d: int32;
begin
  if FText.Len >= FPosCursorSymbols then
  begin
    pk := FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(FPosCursorSymbols)];
    inc(FPosCursorSymbols);
    if pk <> nil then
    begin
      d := FTextView.SceneTextData.TxtProcessor.GetCharWidth(pk);
      inc(PosCursorPixels, d);
      AdjustViewport;
      if Assigned(Cursor) then
        UpdateCursorPos;
    end else
      raise Exception.Create('The glyph have not found!');
  end;
end;

procedure TBCustomEdit.InsertSymbol(Symbol: WideChar);
var
  pk: PKeyInfo;
begin
  pk := FCanvas.Font.KeyByWideChar[Symbol];
  if pk <> nil then
  begin
    FText.Insert(FPosCursorSymbols, WideToString(WideString(Symbol)));
    if Assigned(FTextView) then
      FTextView.Text := FText;
    IncCursor;
    SetTextViewPosition;
  end;
end;

procedure TBCustomEdit.OnMouseDblClick(const Data: BMouseData);
begin
  SelectAll;
end;

procedure TBCustomEdit.OnMouseDown(const Data: BMouseData);
begin
  if not Focused then
    Focused := true;
  ObsrvOnMouseMove := CreateMouseObserver(FCanvas.Renderer.EventMouseMove, OnMouseMove);
  if FCountSelected <> 0 then
    ClearSelection;
  SetNewCursorPos(GetCursorPosFromX(Data.X, StartSelectedPixels), StartSelectedPixels);
  FStartSelected := FPosCursorSymbols;
end;

procedure TBCustomEdit.OnMouseMove(const Data: BMouseData);
var
  index: int32;
  pixels: int32;
begin
  index := GetCursorPosFromX(Data.X, pixels);
  if index <> FStartSelected then
    Select(index - FStartSelected);
end;

procedure TBCustomEdit.OnMouseUp(const Data: BMouseData);
begin
  ObsrvOnMouseMove := nil;
end;

{procedure TBCustomEdit.OnReplaceFont(const Value: BEmpty);
begin
  OnChangeFontSbscr := CreateEmptyObserver(Canvas.Font.OnChangeEvent, OnChangeFontEvent);
  FTextView.Build;
  SetTextViewPosition;
  if FCountSelected > 0 then
    DrawSelector;
end;}

procedure TBCustomEdit.OnAnimate(const Data: BSFloat);
begin
  if Assigned(Cursor) then
    Cursor.Data.Opacity := Data;
end;

{procedure TBCustomEdit.OnChangeCanvasFont(Source: TBCanvas);
begin
  inherited;
  if ScalingFont then
    exit;
  SizeFontInPoints := BSConfig.PointsInVoxel * Canvas.Font.SizeInPixels;
end;

procedure TBCustomEdit.OnChangeFontEvent(const Value: BEmpty);
begin
  // build will invoke in automate, but we are doing it for calculate a right position of the text
  FTextView.Build;
  SetTextViewPosition;
  if FCountSelected > 0 then
    DrawSelector;
end; }

procedure TBCustomEdit.OnKeyDown(const Data: BKeyData);
begin
  DoKeyDown(Data);
end;

procedure TBCustomEdit.OnKeyPress(const Data: BKeyData);
begin
  DoKeyPress(Data);
end;

procedure TBCustomEdit.Resize(AWidth, AHeight: BSFloat);
begin
  // new size align on odd
  if round(AHeight) mod 2 = 0 then
    Back.Size := vec2(AWidth, round(AHeight)+1.0)
  else
    Back.Size := vec2(AWidth, round(AHeight));

  Frame.Size := Back.Size;

  TextRect.Size := Back.Size;
  if Assigned(Cursor) then
    Cursor.Length := Back.Height - (CURSOR_TOP_ALIGN shl 1);
  inherited;
end;

function TBCustomEdit.GetCursorPosFromX(X: int32; out Pixels: int32): int32;
var
  delta: int32;
  pk: PKeyInfo;
  i, w: int32;
begin
  Pixels := round(FTextView.SceneTextData.OffsetX);

  delta := X - round(Back.AbsolutePosition2d.x + LeftMargin);

  Result := TextOffsetSymbols;
  if delta <= 0 then
    exit;

  for i := TextOffsetSymbols to FText.Len do
  begin
    pk := FCanvas.Font.KeyByWideChar[FText.CharsUnsafeW(i)];
    if pk = nil then
      continue;
    w := FTextView.SceneTextData.TxtProcessor.GetCharWidth(pk);
    inc(Result);
    inc(Pixels, w);
    dec(delta, w);
    if delta <= 0 then
    begin
      if abs(delta) >= w shr 1 then
      begin
        dec(Result);
        dec(Pixels, w);
      end;
      break;
    end;
  end;
end;

function TBCustomEdit.GetEventKeyDown: IBKeyPressEvent;
begin
  Result := TextRect.Data.EventKeyDown;
end;

function TBCustomEdit.GetEventKeyPress: IBKeyPressEvent;
begin
  Result := TextRect.Data.EventKeyPress;
end;

procedure TBCustomEdit.Select(Count: int32);
begin

  if Count = 0 then
    exit;

  if Count + FStartSelected > FText.Len + 1 then
  begin
    Count := FText.Len - FStartSelected + 1;
    if Count = 0 then
      exit;
  end else
  if FStartSelected + Count < 0 then
    Count := FStartSelected;

  FCountSelected := Count;

  if Count < 0 then
  begin
    StartSelectedPixels := FindOffsetOfSymbol(FStartSelected + Count);
    WidthSelectedPixels := FindOffsetOfSymbol(FStartSelected, FStartSelected + Count);
    SetNewCursorPos(FStartSelected + Count, StartSelectedPixels);
  end else
  begin
    StartSelectedPixels := FindOffsetOfSymbol(FStartSelected);
    WidthSelectedPixels := FindOffsetOfSymbol(FStartSelected + Count, FStartSelected);
    SetNewCursorPos(FStartSelected + Count, StartSelectedPixels + WidthSelectedPixels);
  end;

  DrawSelector;

end;

procedure TBCustomEdit.SelectAll;
begin
  FStartSelected := 1;
  Select(FText.Len);
end;

procedure TBCustomEdit.SetColor(const Value: TGuiColor);
var
  cl: TColor4f;
begin
  inherited;
  TextRect.Color := TColor4f(FColor);
  cl := TextRect.Color;
  if (cl.a > 0.5) and (cl.r + cl.g + cl.b > 0.5) then
    ColorText := TGuiColors.Black
  else
    ColorText := TGuiColors.White;
end;

procedure TBCustomEdit.SetColorCursor(const Value: TGuiColor);
begin
  FColorCursor := Value;
  if Assigned(Cursor) then
    Cursor.Color := ColorByteToFloat(Value);
end;

procedure TBCustomEdit.SetColorFrame(const Value: TGuiColor);
begin
  FColorFrame := Value;
  Frame.Color := ColorByteToFloat(Value, true);
end;

procedure TBCustomEdit.SetColorText(const Value: TGuiColor);
begin
  FColorText := Value;
  FTextView.Color := ColorByteToFloat(Value);
end;

procedure TBCustomEdit.SetCursorPosition(const Value: int32);
var
  i: int32;
begin
  if Value > FText.Len + 1 then
    i := FText.Len + 1
  else
    i := Value;
  if i = FPosCursorSymbols then
    exit;
  SetNewCursorPos(i, FindOffsetOfSymbol(i));
end;

procedure TBCustomEdit.SetFocused(Value: boolean);
begin
  inherited;
  if Focused then
  begin
    ObsrvOnKeyPress := CreateKeyObserver(TextRect.Data.EventKeyPress, OnKeyPress);
    ObsrvOnKeyDown := CreateKeyObserver(TextRect.Data.EventKeyDown, OnKeyDown);
    Frame.Color := BS_CL_SKY_BLUE;
    CreateCursor;
    if FCountSelected <> 0 then
      Select(FCountSelected)
    else
      PosCursorPixels := FindOffsetOfSymbol(FStartSelected);
    UpdateCursorPos;
    // for accept key events
    Canvas.Renderer.Scene.InstanceSetSelected(TextRect.Data.BaseInstance, true);
    {$ifdef ANDROID}
    if not ReadOnly then
       ControlEvents.Send(TextRect.Data.BaseInstance, GUI_SHOW_KEYBOARD);
    {$endif}
  end else
  begin
    Frame.Color := ColorByteToFloat(ColorFrame, true);
    ObsrvOnKeyPress := nil;
    ObsrvOnKeyDown := nil;
    FreeCursor;
    Canvas.Renderer.Scene.InstanceSetSelected(TextRect.Data.BaseInstance, false);
    {$ifdef ANDROID}
    ControlEvents.Send(TextRect.Data.BaseInstance, GUI_HIDE_KEYBOARD);
    {$endif}
  end;
end;

procedure TBCustomEdit.SetLeftMargin(const Value: BSFloat);
begin
  FLeftMargin := Value;
  SetTextViewPosition;
  //BuildView;
end;

procedure TBCustomEdit.SetNewCursorPos(IndexSymbol, InPixels: int32);
begin
  FPosCursorSymbols := IndexSymbol;
  PosCursorPixels := InPixels;
  AdjustViewport;
  if Assigned(Cursor) then
    UpdateCursorPos;
end;

procedure TBCustomEdit.SetScalable(const Value: boolean);
begin
  if OwnCanvas then
    inherited;
end;

procedure TBCustomEdit.SetShowCursor(const Value: Boolean);
begin
  if FShowCursor = Value then
    exit;
  FShowCursor := Value;
  if FShowCursor then
  begin
    if Focused then
      CreateCursor;
  end else
    FreeCursor;
end;

procedure TBCustomEdit.SetTexoutWidth(const AValue: BSFloat);
begin
  FTextoutWidth := AValue;
  if (AValue < Width) and Assigned(FTextView) then
    FTextView.SceneTextData.OutToWidth := AValue;
  SetTextViewPosition;
end;

procedure TBCustomEdit.SetText(const AValue: string);
begin
  FText := AValue;
  FPosCursorSymbols := 1;
  PosCursorPixels := 0;
  TextOffsetSymbols := 1;
  ClearSelection;

  UpdateCursorPos;

  if Assigned(FTextView) then
  begin
    FTextView.Text := AValue;
    FTextView.SceneTextData.OffsetX := 0;
    SetTextViewPosition;
  end;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCustomEdit.SetTextViewPosition;
begin
  FTextView.Position2d := vec2(LeftMargin, GetVertPosText);
end;

procedure TBCustomEdit.SetVisible(const AValue: boolean);
begin
  inherited SetVisible(AValue);
  Back.Data.Hidden := not AValue;
  TextRect.Data.Interactive := AValue;
  FTextView.Data.Hidden := not AValue;
  Frame.Data.Hidden := not AValue;
  if Assigned(Cursor) then
    FreeCursor;
end;

procedure TBCustomEdit.UpdateCursorPos;
begin
  if Assigned(Cursor) then
  begin
    Cursor.Position2d := vec2(LeftMargin + PosCursorPixels - FTextView.SceneTextData.OffsetX - FTextView.SceneTextData.TxtProcessor.Delta,
      (Height - Cursor.Height) * 0.5 );
  end;
end;

procedure TBCustomEdit.UpdateTextOutRect;
var
  txt_out: BSFloat;
begin
  FTextView.SceneTextData.BeginChangeProp;
  try

    txt_out := Back.Width - LeftMargin - 1;

    if (FTextoutWidth > 0) and (txt_out > FTextoutWidth) then
      txt_out := FTextoutWidth;

    FTextView.SceneTextData.OutToWidth := txt_out;
    FTextView.SceneTextData.OffsetX := FindOffsetOfSymbol(TextOffsetSymbols);

  finally
    FTextView.SceneTextData.EndChangeProp;
  end;
end;

{ TBSpinEdit }

procedure TBCustomSpinEdit.BuildView;
var
  scaledFour: BSFloat;
begin
  inherited BuildView;
  // new size with align on size of pixel
  BtnUp.Size := vec2(round(BTN_WIDTH*ToHiDpiScale), round((TextRect.Size.Height - Frame.WidthLine) * 0.5) - Frame.WidthLine*2);
  BtnUp.Build;
  BtnUp.Position2d := vec2(TextRect.Width - BtnUp.Width - Frame.WidthLine*2, Frame.WidthLine*2);
  BtnDown.Size := BtnUp.Size;
  BtnDown.Build;
  BtnDown.Position2d := vec2(TextRect.Width - BtnUp.Width - Frame.WidthLine*2, BtnUp.Position2d.y + BtnUp.Height + Frame.WidthLine);

  scaledFour := 4.0*ToHiDpiScale;
  TriUp.A :=   vec2(0.0, scaledFour);
  TriUp.B :=   vec2(scaledFour, 0.0);
  TriUp.C :=   vec2(scaledFour*2.0, scaledFour);

  TriDown.A := vec2(0.0, 0.0);
  TriDown.B := vec2(scaledFour*2.0, 0.0);
  TriDown.C := vec2(scaledFour, scaledFour);
  TriUp.Build;
  TriUp.ToParentCenter;
  TriDown.Build;
  TriDown.ToParentCenter;
end;

procedure TBCustomSpinEdit.CheckValue;
begin
  if Value < FMinValue then
    Value := FMinValue
  else
  if Value > FMaxValue then
    Value := FMaxValue
  else
  if (Length(Text) > 0) and (Text[1] = '0') then
    Value := StrToInt(Text); // cut 0 in begining
end;

constructor TBCustomSpinEdit.Create(ACanvas: TBCanvas);
begin
  inherited;
  FMaxValue := high(Int64);
  FMinValue := low(Int64);
  FText := '0';
  FTextView.Text := FText;
  BtnUp := TRectangle.Create(FCanvas, FMainBody);
  BtnUp.Fill := true;
  BtnUp.Data.DragResolve := false;
  BtnUp.Color := BS_CL_GRAY;
  BtnUp.Layer2d := 3;
  TriUp := TTriangle.Create(FCanvas, BtnUp);
  TriUp.Fill := true;
  TriUp.Data.Interactive := false;
  TriUp.Color := BS_CL_CREAM;
  ObsrvOnMouseDownBtnUp := CreateMouseObserver(BtnUp.Data.EventMouseDown, OnMouseDownBtnUp);
  ObsrvOnMouseUpBtnUp := CreateMouseObserver(BtnUp.Data.EventMouseUp, OnMouseUpBtnUp);

  BtnDown := TRectangle.Create(FCanvas, FMainBody);
  BtnDown.Fill := true;
  BtnDown.Data.DragResolve := false;
  BtnDown.Color := BtnUp.Color;
  BtnDown.Layer2d := 3;
  TriDown := TTriangle.Create(FCanvas, BtnDown);
  TriDown.Fill := true;
  TriDown.Data.Interactive := false;
  TriDown.Color := BS_CL_CREAM;
  ObsrvOnMouseDownBtnDown := CreateMouseObserver(BtnDown.Data.EventMouseDown, OnMouseDownBtnDown);
  ObsrvOnMouseUpBtnDown := CreateMouseObserver(BtnDown.Data.EventMouseUp, OnMouseUpBtnDown);
  FTextoutWidth := TextRect.Size.Width - BTN_WIDTH*ToHiDpiScale - Frame.WidthLine*2;
  WaitTimer := CreateAniFloatLinear(GUIThread);
  WaitTimer.Duration := 10000;
  WaitTimer.IntervalUpdate := 50;
  WaitTimer.Loop := true;
  WaitTimerObsrv := CreateAniFloatLivearObsrv(WaitTimer, OnWaitTime);
end;

function TBCustomSpinEdit.GetValue: int64;
begin
  if not TryStrToInt64(Text, Result) then
  begin
    Result := FMaxValue;
  end;
end;

destructor TBCustomSpinEdit.Destroy;
begin
  WaitTimerObsrv := nil;
  WaitTimer.Stop;
  WaitTimer := nil;
  inherited;
end;

procedure TBCustomSpinEdit.DoKeyDown(const Data: BKeyData);
var
  val: int64;
  e: TBControlNotify;
begin
  val := Value;
  e := FOnChange;
  FOnChange := nil;
  inherited DoKeyDown(Data);
  CheckValue;
  //if (CursorPosition = 1) and (Data.Key <> {$ifdef FPC} VK_LEFT {$else} vkLeft {$endif}) then
  //  CursorPosition := 2;
  if Assigned(e) then
  begin
    FOnChange := e;
    if (val <> Value) then
      FOnChange(Self);
  end;
end;

procedure TBCustomSpinEdit.DoKeyPress(const Data: BKeyData);
var
  e: TBControlNotify;
  val: Int64;
begin
  if not (Data.Key in [ VK_BS_0 .. VK_BS_9 ]) then
    exit;
  val := Value;
  e := FOnChange;
  FOnChange := nil;
  try
    inherited DoKeyPress(Data);
    CheckValue;
    CursorPosition := CursorPosition + 1;
  finally
    if Assigned(e) then
    begin
      FOnChange := e;
      if (val <> Value) then
        FOnChange(Self);
    end;
  end;
end;

procedure TBCustomSpinEdit.OnMouseDownBtnDown(const Data: BMouseData);
begin
  if not Focused then
    Focused := true;
  if Value > FMinValue then
  begin
    TriDown.Color := TextRect.Color;
    Value := Value - 1;
    WaitTimerUp := false;
    WaitTimer.Run;
    TimeDown := TBTimer.CurrentTime.Low;
  end;
end;

procedure TBCustomSpinEdit.OnMouseDownBtnUp(const Data: BMouseData);
begin
  if not Focused then
    Focused := true;
  if Value < FMaxValue then
  begin
    TriUp.Color := TextRect.Color;
    Value := Value + 1;
    WaitTimerUp := true;
    WaitTimer.Run;
    TimeDown := TBTimer.CurrentTime.Low;
  end;
end;

procedure TBCustomSpinEdit.OnMouseUpBtnDown(const Data: BMouseData);
begin
  TriDown.Color := TriUp.Color;
  WaitTimer.Stop;
end;

procedure TBCustomSpinEdit.OnMouseUpBtnUp(const Data: BMouseData);
begin
  TriUp.Color := TriDown.Color;
  WaitTimer.Stop;
end;

procedure TBCustomSpinEdit.OnWaitTime(const AValue: BSFloat);
begin
  if TBTimer.CurrentTime.Low - TimeDown < 1000 then
    exit;
  if WaitTimerUp then
  begin
    if Value < FMaxValue then
      Value := Value + 1
    else
      WaitTimer.Stop;
  end else
  begin
    if Value > FMinValue then
      Value := Value - 1
    else
      WaitTimer.Stop;
  end;
end;

procedure TBCustomSpinEdit.Resize(AWidth, AHeight: BSFloat);
begin
  FTextoutWidth := AWidth - BTN_WIDTH*ToHiDpiScale - Frame.WidthLine - LeftMargin;
  inherited;
end;

procedure TBCustomSpinEdit.SetFocused(Value: boolean);
begin
  inherited;
  if Focused then
  begin
    ObsrvOnKeyPressBtnUp := CreateKeyObserver(BtnUp.Data.EventKeyPress, OnKeyPress);
    ObsrvOnKeyDownBtnUp := CreateKeyObserver(BtnUp.Data.EventKeyDown, OnKeyDown);
    ObsrvOnKeyPressBtnDown := CreateKeyObserver(BtnDown.Data.EventKeyPress, OnKeyPress);
    ObsrvOnKeyDownBtnDown := CreateKeyObserver(BtnDown.Data.EventKeyDown, OnKeyDown);
  end else
  begin
    ObsrvOnKeyPressBtnUp := nil;
    ObsrvOnKeyDownBtnUp := nil;
    ObsrvOnKeyPressBtnDown := nil;
    ObsrvOnKeyDownBtnDown := nil;
  end;
end;

procedure TBCustomSpinEdit.SetMaxValue(const AValue: int64);
begin
  FMaxValue := AValue;
  CheckValue;
end;

procedure TBCustomSpinEdit.SetMinValue(const AValue: int64);
begin
  FMinValue := AValue;
  CheckValue;
end;

procedure TBCustomSpinEdit.SetText(const AValue: string);
var
  val: int64;
begin
  if (AValue = '') or not TryStrToInt64(AValue, val) then
    inherited SetText('0')
  else
    inherited SetText(AValue);
end;

procedure TBCustomSpinEdit.SetValue(const AValue: int64);
begin
  if AValue = Value then
    exit;
  Text := IntToStr(AValue);
  CursorPosition := Length(Text) + 1;
end;

procedure TBCustomSpinEdit.SetVisible(const AValue: boolean);
begin
  inherited;
  BtnUp.Data.Interactive := AValue;
  BtnDown.Data.Interactive := AValue;
  BtnUp.Data.Hidden := not AValue;
  BtnDown.Data.Hidden := not AValue;
  TriUp.Data.Hidden := not AValue;
  TriDown.Data.Hidden := not AValue;
end;

end.
