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

unit bs.gui.chart;

{ unint contains an implementation templates and some their defined instances
  various diagrams }

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , bs.basetypes
  , bs.obj
  , bs.events
  , bs.scene
  , bs.canvas
  , bs.collections
  , bs.graphics
  , bs.gui.base
  , bs.mesh
  , bs.font
  , bs.animation
  , bs.gui.hint
  ;

const
  LAYER_RECT = 1;
  LAYER_GRID = LAYER_RECT + 1;
  LAYER_AXIS = LAYER_GRID + 1;
  LAYER_CHART = LAYER_AXIS + 1;


type

  { the container a pair arguments }
  TDataContainer<TX, TY> = class
  public
    type
      { grouped values TY by TX }
      PGroupValues = ^TGroupValues;
      TTreeValues = TBinTreeTemplate<TX, PGroupValues>;
      TGroupValues = record
        ValueX: TX;
        ValuesSum: TY;
        { count grouped value TY by TX }
        Count: int32;
        { contains a part group (ValuesSum) form all sum (TDataContainer<TX, TY>.IntegralY),
          or max value TY (in a bar diagram) }
        Percent: BSFloat;
        { vars for radial chart }
        AngleStart: BSFloat;
        ForcePosition: TVec2f;
        AnimatePos: boolean;
        { contains self presentation for every a diagram, for example, on curves contain points
          on radial diagram - directly pie }
        GraphIntegral: TCanvasObject;
        { for radial diagram Hint used for to contain path (lines) to hint
          (footnote) from pie; for curves and other diagrams hint don't used,
          so you can used at your discretion }
        Hint: TCanvasObject;
        { Text also as Hint used only into radial diagram (for out digits in pie);
          that is why you can used also at its descretion in self discendants from
          all diagram in except TBChartCircular<TX, TY> }
        Text: TCanvasText;
        Color: TColor4f;
        IndexInList: int32;
        { need for sort PGroupValues by ValueX }
        Comparator: TComparatorFunc<TX>;
        { need for sort PGroupValues by ValueY }
        ComparatorY: TComparatorFunc<TY>;
      end;
      { added arg TY }
      PArgValue = ^TArgValue;
      TArgValue = record
        ValueY: TY;
        GraphArg: TCanvasObject;
        Group: PGroupValues;
      end;
  private
    FMaxX: TX;
    FMaxY: TY;
    FMinX: TX;
    FMinY: TY;
    FName: string;
    FUniteArgX: boolean;
    FUniteArgYAsSum: boolean;
    class function CompGroupValues(const Value1, Value2: PGroupValues): int8; static;
    class function CompGroupValuesByY(const Value1, Value2: PGroupValues): int8; static;
    function GetValue(index: int32): TArgValue;
    function GetColor: TColor4f;
    procedure SetColor(const Value: TColor4f);
    { method invoke befor draw in case UniteArgX set on;  }
    procedure CheckTYLimits;
  protected
    FIndex: int32;
    IntegralY: TY;
    OpX: TOperators<TX>;
    OpY: TOperators<TY>;
    { now used only for out curve; so, in other diagrams you can used at its
      discretion }
    FPath: TPath;
    { also used only for curve }
    FContour: TPath;
    { list all added values TY with save order add }
    FValues: TListVec<TArgValue>;
    { grouped values by TX }
    FTreeValues: TTreeValues;
    { list grouped values by TY with save order add groups }
    FListValues: TListVec<PGroupValues>;
    { in result sort groups will reorderd from low to high TY }
    procedure SortByY;
    { in result sort groups will reorderd from high to low TY }
    procedure SortByYInv;
  public
    constructor Create(APath: TPath; const AOperatorsX: TOperators<TX>; const AOperatorsY: TOperators<TY>);
    destructor Destroy; override;
    procedure Clear;
    function AddPair(const X: TX; const Y: TY): PGroupValues; overload;
    function AddPair(const X: TX; const Y: TY; const Color: TColor4f): PGroupValues; overload;
    property Values[index: int32]: TArgValue read GetValue;
    property Color: TColor4f read GetColor write SetColor;
    property MaxX: TX read FMaxX;
    property MaxY: TY read FMaxY;
    property MinX: TX read FMinX;
    property MinY: TY read FMinY;
    property Index: int32 read FIndex write FIndex;
    property Name: string read FName write FName;
    { unites equal arguments to single point }
    property UniteArgX: boolean read FUniteArgX write FUniteArgX;
    { if UniteArgX equal true, then UniteArgYAsSum for define of method calculate
      TY to one point: summ if UniteArgYAsSum equal true, otherwise - average
       }
    property UniteArgYAsSum: boolean read FUniteArgYAsSum write FUniteArgYAsSum;
  end;

  { the template for presentation a chart }

  { TBChart }

  TBChart<TX, TY> = class abstract(TBControl)
  private
    type
      TGetPosXMethod = function (const Argument: TX): BSFloat of object;
      TGetPosYMethod = function (const FuncResult: TY): BSFloat of object;
  public
    type
      TDataContainerPairXY = TDataContainer<TX, TY>;
      TLegend = record
        Text: TCanvasText;
        Rect: TRectangle;
        { linked group to legend; need only for radial chart (see below for a
          description of the radial Chart); in other cases a legend linked to
          TDataContainer<TX, TY>  }
        LinkedGroup: TDataContainerPairXY.PGroupValues;
        { for common case legend linked to one chart }
        LinkedChart: TDataContainerPairXY;
      end;
      {
      !!! Strange behavior under dcc32 - if used a record below, happenes error
        in place System.SysUtils.FreeSyncObj(..) in time free chart
      TPairXY = record
        X: TX;
        Y: TY;
      end;}
  strict private
    UpdateCounter: int32;
    //BackGrad: TBlackSharkCanvasObject;
    procedure CalcPositionAxes;
    procedure CalcGridStep;
    procedure DrawAxis;
  private
    FCurves: TListVec<TDataContainerPairXY>;
    { exact a boundary arguments and a function results }
    FMaxX: TX;
    FMaxY: TY;
    FMinX: TX;
    FMinY: TY;
    FShowAxisName: boolean;
    FInterpolateLines: boolean;
    FShowContour: boolean;
    CurrentColor: TColor4f;
    //CurrentIndexColor: int8;
    CurrentIndexSets: TBSColors;
    FShowGrid: boolean;
    FAxisColor: TColor4f;
    FAxisWidth: int8;
    FAxisColor2: TColor4f;
    FShowAxisY: boolean;
    FShowAxisX: boolean;
    LegendPlane: TRoundRect;
    LegendBorder: TRoundRect;
    LegendFont: IBlackSharkFont;
    FAxisXTextColor: TColor4f;
    FAxisYTextColor: TColor4f;
    procedure SetNameAxisX(const Value: string);
    procedure SetNameAxisY(const Value: string);
    procedure CalcLimits;
    function GetNameAxisX: string;
    function GetNameAxisY: string;
    procedure SetShowAxisName(const Value: boolean);
    procedure SetInterpolateLines(const Value: boolean);
    procedure SetShowContour(const Value: boolean);
    procedure CreateContour(Chart: TDataContainer<TX, TY>);
    procedure DrawContour(Chart: TDataContainer<TX, TY>);
    procedure SetShowGrid(const Value: boolean);
    procedure DrawGrid;
    procedure SetAxisXSize(const Value: int32);
    procedure SetAxisYSize(const Value: int32);
    procedure SetGridStepX(const Value: BSFloat);
    procedure SetGridStepY(const Value: BSFloat);
    procedure SetAxisColor(const Value: TColor4f);
    procedure SetAxisWidth(const Value: int8);
    procedure SetAxisColor2(const Value: TColor4f);
    procedure SetShowAxisX(const Value: boolean);
    procedure SetShowAxisY(const Value: boolean);
    procedure RecreateAxisX;
    procedure RecreateAxisY;
    procedure SetShowLegend(const Value: boolean);
    procedure DrawLegends;
    { methods accepts arguments in depend of (WidthX = DefaultX) and (FMaxX = DefaultX):
        - GetArg11 - (WidthX <> DefaultX) and (FMaxX <> DefaultX)
        - GetArg01 - (WidthX  = DefaultX) and (FMaxX <> DefaultX)
        - GetArg00 - (WidthX  = DefaultX) and (FMaxX  = DefaultX)
        - GetArg10 - (WidthX <> DefaultX) and (FMaxX  = DefaultX) calculate like on GetArg11
       }
    function GetArg11(const Argument: TX): BSFloat;
    function GetArg01(const Argument: TX): BSFloat;
    function GetArg00(const Argument: TX): BSFloat;
    //function GetArg10(const Argument: TX): BSFloat;
    { the same calculate for function result }
    function GetFuncPos11(const FuncResult: TY): BSFloat;
    function GetFuncPos01(const FuncResult: TY): BSFloat;
    function GetFuncPos00(const FuncResult: TY): BSFloat;
    procedure SetAxisXTextColor(const Value: TColor4f);
    procedure SetAxisYTextColor(const Value: TColor4f);
  protected
    DefaultY: TY;
    DefaultX: TX;
    // background rect - root object for chart drag
    Rect: TRectangleTextured;
    // parent level for out chart, text and axis; parent - Rect
    LevelAxis: TCanvasObject;
    // background grid, parent - Rect
    Grid: TGrid;
    FNameAxisX: TCanvasText;
    FNameAxisY: TCanvasText;
    { a condition positions axes }
    CondX: TX;
    CondY: TY;
    CondXLeft: BSFloat;
    CondYTop: BSFloat;
    { adjusted limits; border arguments and function results; might be not exact;
      exact a boundary describe variables FMaxX...FMinY; sign AdjustMaxX
      even FMaxX or CondX, sign AdjustMinX - FMinX or CondX, sign AdjustMaxY -
      FMaxY or CondY, and so on... }
    {AdjustMaxX: TX;
    AdjustMaxY: TY;
    AdjustMinX: TX;
    AdjustMinY: TY; }
    { border width argument (TX) and function result height (TY) }
    WidthX: TX;
    HeightY: TY;
    WidthXIsZero: boolean;
    WidthYIsZero: boolean;
    MaxXIsZero: boolean;
    MaxYIsZero: boolean;
    { an area included axes and limits argument and function }
    ValidAreaMaxX: TX;
    ValidAreaMaxY: TY;
    ValidAreaMinX: TX;
    ValidAreaMinY: TY;

    { so Delphi not support templates, therefor math operations define methods;
      descendants MUST to assign methods }
    OpX: TOperators<TX>;
    OpY: TOperators<TY>;
    AxisText: TListVec<TCanvasText>;
    FGridStepX: BSFloat;
    FGridStepY: BSFloat;
    FAxisXSize: int32;
    FAxisYSize: int32;
    AxisXSizeAligned: BSFloat;
    AxisYSizeAligned: BSFloat;
    AxisX: TArrow;
    AxisY: TArrow;
    // values for align axis on grid
    AxisXAlign: BSFloat;
    AxisYAlign: BSFloat;
    PositionAxis: TVec2f;
    MaxCountValues: uint32;
    FShowLegend: boolean;
    FLegends: TListVec<TLegend>;
    FShowZeroPoint: boolean;
    GetArgX: array[boolean, boolean] of TGetPosXMethod;
    GetArgY: array[boolean, boolean] of TGetPosYMethod;
    LegendsOffset: BSFloat;
    procedure IncColor;
    function CompareBackgroundColor: boolean;
    function GetNextColor: TColor4f;
    procedure CalcSizeAlignedAxisX;
    procedure CalcSizeAlignedAxisY;
    function GetGranularX: TX; virtual;
    function GetGranularY: TY; virtual;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure BuildView; override;
    function DefaultSize: TVec2f; override;
    { add legend linked to a chart or group TY by TX }
    procedure AddLegend(const Name: string; const Color: TColor4f;
      ToLinkedChart: TDataContainerPairXY = nil;
      ToLinkedGroup: TDataContainerPairXY.PGroupValues = nil);
    procedure DeleteLegend(const Name: string);
    procedure Resize(AWidth, AHeight: BSFloat); override;
    function CreateChart: TDataContainer<TX, TY>; virtual;
    procedure DeleteChart(Chart: TDataContainer<TX, TY>); virtual;
    procedure DrawChart(Chart: TDataContainer<TX, TY>); virtual; abstract;
    { remove curve without destroying  }
    procedure RemoveChart(Chart: TDataContainer<TX, TY>); virtual;
    procedure ClearTextAxis;
    procedure Clear;
    property NameAxisX: string read GetNameAxisX write SetNameAxisX;
    property NameAxisY: string read GetNameAxisY write SetNameAxisY;
    property ShowAxisName: boolean read FShowAxisName write SetShowAxisName;
    property ShowContour: boolean read FShowContour write SetShowContour;
    property InterpolateLines: boolean read FInterpolateLines write SetInterpolateLines;
    property ShowGrid: boolean read FShowGrid write SetShowGrid;
    property MaxX: TX read FMaxX;
    property MaxY: TY read FMaxY;
    property MinX: TX read FMinX;
    property MinY: TY read FMinY;
    property GridStepX: BSFloat read FGridStepX write SetGridStepX;
    property GridStepY: BSFloat read FGridStepY write SetGridStepY;
    property AxisXSize: int32 read FAxisXSize write SetAxisXSize;
    property AxisYSize: int32 read FAxisYSize write SetAxisYSize;
    property AxisColor: TColor4f read FAxisColor write SetAxisColor;
    property AxisColor2: TColor4f read FAxisColor2 write SetAxisColor2;
    property AxisXTextColor: TColor4f read FAxisXTextColor write SetAxisXTextColor;
    property AxisYTextColor: TColor4f read FAxisYTextColor write SetAxisYTextColor;
    property AxisWidth: int8 read FAxisWidth write SetAxisWidth;
    property ShowAxisX: boolean read FShowAxisX write SetShowAxisX;
    property ShowAxisY: boolean read FShowAxisY write SetShowAxisY;
    property ShowLegend: boolean read FShowLegend write SetShowLegend;
    property ShowSeroPoint: boolean read FShowZeroPoint write FShowZeroPoint;
  end;

  { the template for presentation curves; attention! if you want present in chart
    integer numbers, its out on the grid might aligned with errors of round,
    especially if TY range is small and size grid to make big }

  TBChartCurves<TX, TY> = class(TBChart<TX, TY>)
  private
    FInterpolateSpline: TInterpolateSpline;
    PointHint: TRoundRectTextured;
    HintText: TCanvasText;
    FShowPoints: boolean;
    GroupMouseEnter: BObserversGroup<BMouseData>;
    GroupMouseLeave: BObserversGroup<BMouseData>;
    procedure SetShowPoints(const Value: boolean);
    procedure CreateHint(const Text: string);
    procedure OnPointMouseEnter({%H-}const Data: BMouseData);
    procedure OnPointMouseLeave({%H-}const Data: BMouseData);
  protected
    procedure SetInterpolateSpline(const Value: TInterpolateSpline); virtual;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure LoadProperties; override;
    function CreateChart: TDataContainer<TX, TY>; override;
    procedure BuildView; override;
    procedure DrawChart(Chart: TDataContainer<TX, TY>); override;
    property InterpolateSpline: TInterpolateSpline read FInterpolateSpline write SetInterpolateSpline;
    property ShowPoints: boolean read FShowPoints write SetShowPoints;
  end;

  { the template for presentation circular diagram, where x - legend, y - quantity;
    might contain only one chart; I guess it was necessary every a pie present as
    one chart; but what is done is done - all pie contains in one chart, that is
    why legend linked to group values TX }

  TBChartCircular<TX, TY> = class(TBChart<TX, TY>)
  private
    const
      BASE_FOR_HINT = 30;
      PUSH_SEGMENT_DISTANCE = 10;
  public
    type
      TDataContainerPairXY = TDataContainer<TX, TY>;
  private
    type
      //PArcAttrib = ^TArcAttrib;
      TArcAttrib = record
        S, C: BSfloat;
        SignSin, SignCos: int8;
        Group: TDataContainerPairXY.PGroupValues;
        Len: BSFloat;
        Angle: BSFloat;
        NumQuad: int8;
        //Level: int8;
      end;
  private
    FRadius: int32;
    UnitedHintRect: TRectBSf;
    Center: TVec2f;
    Height_hint_text: BSFloat;
    AniLawScale: IBAnimationLinearFloat;
    ObsrvScale: IBAnimationLinearFloatObsrv;
    AnimatingGroup: TDataContainerPairXY.PGroupValues;
    Stack: TListVec<TArcAttrib>;
    CurrentIntegral: TY;
    HintText: TBlackSharkHint;
    FSortOnGrowY: boolean;

    GroupMouseEnter: BObserversGroup<BMouseData>;
    GroupMouseMove: BObserversGroup<BMouseData>;
    GroupMouseLeave: BObserversGroup<BMouseData>;

    procedure AdjustRadius(AWidth, AHeight: BSFloat);
    procedure ReturnBeginParam(Group: TDataContainerPairXY.PGroupValues);
    procedure SetRadius(const Value: int32);
    procedure OnMouseEnter({%H-}const Data: BMouseData);
    procedure OnMouseMove({%H-}const Data: BMouseData);
    procedure OnMouseLeave({%H-}const Data: BMouseData);
    procedure OnUpdateValueScale(const Value: BSFloat);
    procedure CalcArcAttrib(var ArcAttrib: TArcAttrib);
    function SelectSecondPointForLegHint(const Arc: TArcAttrib; const LegFirst: TVec2f; out Rect: TRectBSf): TVec2f;
    procedure DrawHint(const Arc: TArcAttrib);
  protected
    FChart: TDataContainer<TX, TY>;
    Quad_spread_smal_arc: array [1..4] of int32;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure LoadProperties; override;
    function CreateChart: TDataContainer<TX, TY>; override; final;
    procedure BuildView; override;
    procedure DrawChart(Chart: TDataContainer<TX, TY>); override;
    { Pair auxiliary methods SetIntegralY allow easy build chart; befor first invoke
      AddQantity need call SetIntegralY for set full quantity all values TY;
      further for on every invoke AddQantity automaticaly calculate added a value
      TY }
    procedure SetIntegralY(const IntegralY: TY);
    { PartTY within [0..1] }
    function AddPart(const Legend: TX; PartTY: BSFloat; const Color: TColor4f): TDataContainerPairXY.PGroupValues;
    procedure Resize(AWidth, AHeight: BSFloat); override;
    property Radius: int32 read FRadius write SetRadius;
    property SortOnGrowY: boolean read FSortOnGrowY write FSortOnGrowY;
  end;

  { the template for presentation bar diagram }

  TBChartBar<TX, TY> = class(TBChart<TX, TY>)
  protected
  public
    constructor Create(ACanvas: TBCanvas); override;
    procedure BuildView; override;
    procedure DrawChart(Chart: TDataContainer<TX, TY>); override;
  end;

  TBChartCurvesQuantityInt = class(TBChartCurves<int32, int32>)
  protected
    function GetGranularX: int32; override;
    function GetGranularY: int32; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
  end;

  { curves show dynamic quantity in date; format argumet axis X define method
    ToStringDate with class variable DateFormate; warning! DateFormate not thread
    save, and also global }
  TCurvesQuantityInDate = class(TBChartCurves<TDate, int32>)
  private
    class function Comparator(const Value1, Value2: TDate): int8; static;
    class function Add(const Value1, Value2: TDate): TDate; static;
    class function Subtract(const Value1, Value2: TDate): TDate; static;
    class function Multiply(const Value1, Value2: TDate): TDate; static;
    class function MultiplyInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function MultiplyFloat(const Value1: TDate; const Value2: BSFloat): TDate; static;
    class function Divide(const Value1, Value2: TDate): TDate; static;
    class function Divide_float(const Value1, Value2: TDate): BSFloat; static;
    class function DivideInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function High: TDate; static;
    class function Low: TDate; static;
    class function ToStringDate(const Value: TDate): string; static;
  protected
    function GetGranularX: TDate; override;
    function GetGranularY: int32; override;
  public
    class var DateFormat: TFormatSettings;
  public
    constructor Create(ACanvas: TBCanvas); override;
    { additions date in DateFormat }
    procedure AddDate(Chart: TDataContainer<TDate, int32>; const Date: TDate; Y: int32);
  end;

  { similarly to the TCurvesQuantityInDate, of except function result (Quantity) have
    float type }

  TCurvesQuantityFloatInDate = class(TBChartCurves<TDate, BSFloat>)
  private
    class function ToStringDate(const Value: TDate): string; static;
    {class function Add(const Value1, Value2: TDate): TDate; static;
    class function Comparator(const Value1, Value2: TDate): int8; static;
    class function Divide(const Value1, Value2: TDate): TDate; static;
    class function Divide_float(const Value1, Value2: TDate): BSFloat; static;
    class function DivideInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function High: TDate; static;
    class function Low: TDate; static;
    class function Multiply(const Value1, Value2: TDate): TDate; static;
    class function MultiplyFloat(const Value1: TDate;
      const Value2: BSFloat): TDate; static;
    class function MultiplyInt(const Value1: TDate; const Value2: int32): TDate; static;
    class function Subtract(const Value1, Value2: TDate): TDate; static;  }
  protected
    function GetGranularX: TDate; override;
    function GetGranularY: BSFloat; override;
  public
    class var DateFormat: TFormatSettings;
  public
    constructor Create(ACanvas: TBCanvas); override;
    { additions date in DateFormat }
    procedure AddDate(Chart: TDataContainer<TDate, BSFloat>; const Date: TDate; Y: BSFloat);
  end;

 TBChartCircularInt = class(TBChartCircular<int32, int32>)
  protected
    function GetGranularX: int32; override;
    function GetGranularY: int32; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
  end;

  { Circular chart with the string legends; direct defining a template
    TBChartCircular<string, BSFloat> impossible becouse need define
    math operators for the string type; }

  TBChartCircularStr = class(TBChartCircular<int32, BSFloat>)
  public
    type
      TDataContainer = TBChartCircular<int32, BSFloat>.TDataContainerPairXY;
      TTreeStringGroups = TBinTreeTemplate<string, TDataContainer.PGroupValues>;
  private
    TreeGroups: TTreeStringGroups;
    FactoryID: int32;
    ColorEnum: TColorEnumerator;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    { add to legend ValueX quantity Count; for one legend can invoke many time }
    procedure AddPair(const ValueX: string; Count: int32); overload;
    { befor call this method need invoke SetIntegralY; for one legend must invoke
      only one time; in fact the metod defines size chart a pie for legend ValueX }
    procedure AddPair(const ValueX: string; PartTY: BSFloat); overload;
    procedure DeleteChart(Chart: TDataContainer); override;
  end;

  TBChartCurvesFloat = class(TBChartCurves<BSFloat, BSFloat>)
  protected
    function GetGranularX: BSFloat; override;
    function GetGranularY: BSFloat; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
  end;

  TBChartCurvesInt = class(TBChartCurves<int32, int32>)
  protected
    function GetGranularX: int32; override;
    function GetGranularY: int32; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
  end;

  TBChartBarInt = class(TBChartBar<int32, int32>)
  protected
    function GetGranularX: int32; override;
    function GetGranularY: int32; override;
  public
    constructor Create(ACanvas: TBCanvas); override;
  end;

  TBChartBarDateInt = class(TBChartBar<TDate, int32>)
  protected
    //function GetGranularX: TDate; override;
    function GetGranularY: int32; override;
  public
    DateFormat: TFormatSettings;
    constructor Create(ACanvas: TBCanvas); override;
    { additions date in DateFormat }
    procedure AddDate(Chart: TDataContainer<TDate, int32>; const Date: string; Y: int32); overload;
    procedure AddDate(Chart: TDataContainer<TDate, int32>; const Date: TDate; Y: int32); overload;
    procedure AddDate(Chart: TDataContainer<TDate, int32>; Day, Month, Year: int32; Y: int32); overload;
  end;

  TBChartBarDateFloat = class(TBChartBar<TDate, BSFloat>)
  protected
    //function GetGranularX: TDate; override;
    function GetGranularY: BSFloat; override;
  public
    DateFormat: TFormatSettings;
    constructor Create(ACanvas: TBCanvas); override;
    { additions date in DateFormat }
    procedure AddDate(Chart: TDataContainer<TDate, BSFloat>; const Date: TDate; Y: BSFloat);
  end;

const
  DEFAULT_SIZE_TIP_AXIS: int8 = 8;
  DEFAULT_SIZE_GRID_CELL: int8 = 15;


implementation

uses
  {$ifdef FPC}
    DateUtils
  {$else}
    System.DateUtils
  {$endif}
  , bs.exceptions
  , bs.math
  , bs.texture
  ;

{$region 'TDataContainer<TX, TY>'}

{ TBChart }

function TDataContainer<TX, TY>.AddPair(const X: TX; const Y: TY): PGroupValues;
begin
  Result := AddPair(X, Y, Color);
end;

function TDataContainer<TX, TY>.AddPair(const X: TX; const Y: TY; const Color: TColor4f): PGroupValues;
var
  res: int8;
  par: TArgValue;
  new_arg: boolean;
begin
  res := OpX.Comparator(X, FMaxX);
  if res > 0 then
    FMaxX := X;
  res := OpX.Comparator(X, FMinX);
  if res < 0 then
    FMinX := X;
  if FTreeValues.Find(X, Result) then
  begin
    inc(Result^.Count);
    Result^.ValuesSum := OpY.Add(Result^.ValuesSum, Y);
    if not FUniteArgYAsSum then
    begin
      if Result^.Count > 1 then
        Result^.ValuesSum := OpY.DivideInt(Result^.ValuesSum, 2);
    end;
    new_arg := not FUniteArgX;
  end else
  begin
    new_arg := true;
    new(Result);
    FillChar(Result^, SizeOf(TGroupValues), 0);
    Result^.ValueX := X;
    Result^.Color := Color;
    Result^.ValuesSum := Y;
    Result^.Count := 1;
    Result^.IndexInList := FListValues.Count;
    Result^.Comparator := OpX.Comparator;
    Result^.ComparatorY := OpY.Comparator;
    FTreeValues.Add(X, Result);
    FListValues.Add(Result);
  end;

  if new_arg then
  begin
    res := OpY.Comparator(Y, FMaxY);
    if res > 0 then
      FMaxY := Y;
    res := OpY.Comparator(Y, FMinY);
    if res < 0 then
      FMinY := Y;
    par.Group := Result;
    par.ValueY := Y;
    par.GraphArg := nil;
    FValues.Add(par);
  end else
  begin
    FValues.Data^[Result^.IndexInList].ValueY := Result^.ValuesSum;
  end;

  IntegralY := OpY.Add(IntegralY, Y);
end;

procedure TDataContainer<TX, TY>.CheckTYLimits;
var
  res: int8;
  i: int32;
  gr: PGroupValues;
  t_y: TY;
  values: array of TArgValue;
begin
  if FValues.Count = 0 then
    exit;
  { this method invoke in case on a property UniteArgX; all speaked below this is
    reason on the UniteArgX;
    again looking for TY new limits; simultaneously reordered FValues according
    FListValues, so we united by argument TY all a function results and we not
    important order addition pairs TX and TY; }
  FMaxY := OpY.Low;
  FMinY := OpY.High;
  { comparator assigned not through constructor, else will sort automatically, we
    want sort manually when that honestly need }
  FListValues.Comparator := CompGroupValues;
  FListValues.Sort;
  values := nil;
  SetLength(values, FValues.Count);
  move(FValues.Data^[0], values[0], FValues.Count*SizeOf(TArgValue));
  for i := 0 to FListValues.Count - 1 do
  begin
    gr := FListValues.Items[i];
    FValues.Items[i] := values[gr.IndexInList];
    gr.IndexInList := i;
    t_y := FListValues.Items[i].ValuesSum;
    res := OpY.Comparator(t_y, FMaxY);
    if res > 0 then
      FMaxY := t_y;
    res := OpY.Comparator(t_y, FMinY);
    if res < 0 then
      FMinY := t_y;
  end;
end;

procedure TDataContainer<TX, TY>.SortByY;
var
  i: int32;
  gr: PGroupValues;
  //values: array of TArgValue;
begin
  { comparator assigned not through constructor, else will sort automatically, we
    want sort manually when that honestly need }
  FListValues.Comparator := CompGroupValuesByY;
  FListValues.Sort;
  //SetLength(values, FValues.Count);
  //move(FValues.Data^[0], values[0], FValues.Count*SizeOf(TArgValue));
  for i := 0 to FListValues.Count - 1 do
  begin
    gr := FListValues.Items[i];
    //FValues.Items[i] := values[gr.IndexInList];
    gr.IndexInList := i;
  end;
end;

procedure TDataContainer<TX, TY>.SortByYInv;
var
  i, ind: int32;
  gr1, gr2: PGroupValues;
  h: int32;
  //values: array of TArgValue;
begin
  { comparator assigned not through constructor, else will sort automatically, we
    want sort manually when that honestly need }
  FListValues.Comparator := CompGroupValuesByY;
  FListValues.Sort;
  //SetLength(values, FValues.Count);
  //move(FValues.Data^[0], values[0], FValues.Count*SizeOf(TArgValue));
  h := FListValues.Count div 2;
  for i := h to FListValues.Count - 1 do
  begin
    gr1 := FListValues.Items[i];
    ind := FListValues.Count - i - 1;
    gr2 := FListValues.Items[ind];
    //FValues.Items[i] := values[gr.IndexInList];
    gr2.IndexInList := i;
    gr1.IndexInList := ind;
    FListValues.Items[i] := gr2;
    FListValues.Items[ind] := gr1;
  end;
end;

procedure TDataContainer<TX, TY>.Clear;
var
  value: PGroupValues;
  i: Integer;
begin
  FMaxX := OpX.Low;
  FMaxY := OpY.Low;
  FMinX := OpX.High;
  FMinY := OpY.High;
  FTreeValues.Iterator.SetToBegin(value);
  while Assigned(value) do
  begin
    if Assigned(value^.GraphIntegral) then
      value^.GraphIntegral.Free;
    Dispose(value);
    FTreeValues.Iterator.Next(value);
  end;

  for i := 0 to FValues.Count - 1 do
    if Assigned(FValues.Items[i].GraphArg) then
      FValues.Items[i].GraphArg.Free;
  FValues.Count := 0;
  FTreeValues.Clear;
  FListValues.Count := 0;
end;

class function TDataContainer<TX, TY>.CompGroupValues(const Value1,
  Value2: PGroupValues): int8;
begin
  Result := Value1.Comparator(Value1.ValueX, Value2.ValueX);
end;

class function TDataContainer<TX, TY>.CompGroupValuesByY(const Value1,
  Value2: PGroupValues): int8;
begin
  Result := Value1.ComparatorY(Value1.ValuesSum, Value2.ValuesSum);
end;

constructor TDataContainer<TX, TY>.Create(APath: TPath; const AOperatorsX: TOperators<TX>;
  const AOperatorsY: TOperators<TY>);
begin
  FTreeValues := TTreeValues.Create(TKeyComparator<TX>(@AOperatorsX.Comparator)); // TBinTree<PGroupValues>.Create;
  FListValues := TListVec<PGroupValues>.Create;
  FValues := TListVec<TArgValue>.Create;
  FUniteArgYAsSum := true;
  OpX := AOperatorsX;
  OpY := AOperatorsY;
  //FChart := AChart;
  FPath := APath;
  //FContour := AContour;
  FPath.Color := BS_CL_GREEN;
  FMaxX := OpX.Low;
  FMaxY := OpY.Low;
  FMinX := OpX.High;
  FMinY := OpY.High;
end;

destructor TDataContainer<TX, TY>.Destroy;
begin
  Clear;
  if FContour <> nil then
    FContour.Free;
  FPath.Free;
  FListValues.Free;
  FValues.Free;
  FTreeValues.Free;
  inherited;
end;

function TDataContainer<TX, TY>.GetColor: TColor4f;
begin
  Result := FPath.Color;
end;

function TDataContainer<TX, TY>.GetValue(index: int32): TArgValue;
begin
  Result := FValues.Items[index];
end;

procedure TDataContainer<TX, TY>.SetColor(const Value: TColor4f);
begin
  FPath.Color := Value;
end;

{$endregion}


{$region 'TBChart<TX, TY>'}

{ TBChart<TX, TY> }

procedure TBChart<TX, TY>.AddLegend(const Name: string; const Color: TColor4f; ToLinkedChart: TDataContainerPairXY = nil; ToLinkedGroup: TDataContainerPairXY.PGroupValues = nil);
var
  t: TCanvasText;
  l: TLegend;
begin
  if not Assigned(LegendPlane) then
  begin
    FLegends := TListVec<TLegend>.Create;
    LegendPlane := TRoundRect.Create(FCanvas, Grid);
    LegendPlane.Size := vec2(50, 50)*ToHiDpiScale;
    LegendPlane.Fill := true;
    LegendPlane.RadiusRound := 5*ToHiDpiScale;
    LegendPlane.Build;
    LegendPlane.Position2d := vec2(Grid.Width + 10*ToHiDpiScale, 0);
    LegendPlane.Color := BS_CL_MSVS_EDITOR;
    LegendPlane.Data.Opacity := 0.7;
    LegendBorder := TRoundRect.Create(FCanvas, LegendPlane);
    LegendBorder.Size := LegendPlane.Size;
    LegendBorder.RadiusRound := LegendPlane.RadiusRound;
    LegendBorder.WidthLine := 1*ToHiDpiScale;
    LegendBorder.Build;
    LegendBorder.Position2d := vec2(0, 0);
    LegendBorder.Color := vec4(34/255, 118/255, 187/255, 1.0);
    LegendBorder.Data.Interactive := false;

    LegendFont := BSFontManager.CreateDefaultFont;
    if OwnCanvas then
      LegendFont.SizeInPixels := round(12*ToHiDpiScale);
  end;

  t := TCanvasText.Create(FCanvas, LegendPlane);
  t.Color := BS_CL_WHITE;
  t.Data.Interactive := false;
  t.Font := LegendFont;
  t.Text := Name;

  l.Text := t;
  l.Rect := TRectangle.Create(FCanvas, LegendPlane);
  l.Rect.Fill := true;
  l.Rect.Size := vec2(8, 8)*ToHiDpiScale;
  l.Rect.Build;
  l.Rect.Color := Color;
  l.Rect.Data.Interactive := false;
  l.LinkedGroup := ToLinkedGroup;
  l.LinkedChart := ToLinkedChart;
  FLegends.Add(l);
  LegendPlane.Data.SetHiddenRecursive(not FShowLegend);
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.DeleteLegend(const Name: string);
var
  i: int32;
begin
  if FLegends = nil then
    exit;
  for i := 0 to FLegends.Count - 1 do
    if FLegends.Items[i].Text.Text = Name then
    begin
      FLegends.Items[i].Text.Free;
      FLegends.Items[i].Rect.Free;
      FLegends.Delete(i);
      break;
    end;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.BeginUpdate;
begin
  inc(UpdateCounter);
end;

procedure TBChart<TX, TY>.CalcGridStep;
var
  s_x: TX;
  s_y: TY;
begin
  s_x := GetGranularX;
  if OpX.Comparator(s_x, DefaultX) <> 0 then
  begin
    if WidthXIsZero then
      FGridStepX := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale
    else
    begin
      FGridStepX := abs(FAxisXSize / OpX.DivideFloat(WidthX, s_x));
      if FGridStepX > FAxisXSize then
        FGridStepX := abs(FAxisXSize / OpX.DivideFloat(s_x, WidthX));
    end;

    if FGridStepX = 0 then
      FGridStepX := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale;
  end else
    FGridStepX := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale;

  s_y := GetGranularY;
  if OpY.Comparator(s_y, DefaultY) <> 0 then
  begin
    if WidthYIsZero then
      FGridStepY := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale
    else
    begin
      FGridStepY := abs(FAxisYSize / OpY.DivideFloat(HeightY, s_y));
      if FGridStepY > FAxisYSize then
        FGridStepY := abs(FAxisYSize / OpY.DivideFloat(s_y, HeightY));
    end;
    if FGridStepY = 0 then
      FGridStepY := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale;
  end else
    FGridStepY := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale;
end;

procedure TBChart<TX, TY>.CalcLimits;
var
  res_1, res_2: int8;
  //align_on_axis: boolean;
  Chart: TDataContainerPairXY;
  i: int32;
  w: TX;
  h: TY;
begin
  FMaxX := OpX.Low;
  FMaxY := OpY.Low;
  FMinX := OpX.High;
  FMinY := OpY.High;
  MaxCountValues := 0;
  for i := 0 to FCurves.Count - 1 do
    begin
    Chart := FCurves.Items[i];
    { if arguments united then need to recalc TY limits befor draw; in that case
      also reordered on grow groups united arguments, and in fact, a count added
      values (contained in Chart.FValues) always equal count of groups values
      (contained in Chart.FListValues}
    if Chart.UniteArgX then
      Chart.CheckTYLimits;
    if OpX.Comparator(Chart.MaxX, FMaxX) > 0 then
      FMaxX := Chart.MaxX;
    if OpY.Comparator(Chart.MaxY, FMaxY) > 0 then
      FMaxY := Chart.MaxY;
    if OpX.Comparator(Chart.MinX, FMinX) < 0 then
      FMinX := Chart.MinX;
    if OpY.Comparator(Chart.MinY, FMinY) < 0 then
      FMinY := Chart.MinY;
    if Chart.FTreeValues.Count > MaxCountValues then
      MaxCountValues := Chart.FTreeValues.Count;
    end;

  w := OpX.Subtract(FMaxX, FMinX);
  h := OpY.Subtract(FMaxY, FMinY);
  WidthXIsZero := OpX.Comparator(w, DefaultX) = 0;
  WidthYIsZero := OpY.Comparator(h, DefaultY) = 0;
  res_1 := OpX.Comparator(FMinX, DefaultX);
  res_2 := OpX.Comparator(FMaxX, DefaultX);
  MaxXIsZero := res_2 = 0;
  { previously calculate  }
  WidthX  := OpX.Subtract(FMaxX, FMinX);
  HeightY := OpY.Subtract(FMaxY, FMinY);
  { both in right DefaultX }
  if ((res_1 > 0) and (res_2 > 0)) then
  begin
    if WidthXIsZero then
    begin
      if MaxXIsZero or (abs(OpX.DivideFloat(DefaultX, FMaxX)) < 3.0) then
      begin
        CondX := DefaultX;
      end else
      begin
        CondX := OpX.Subtract(FMinX, GetGranularX);
      end;
    end else
    begin
      if (OpX.DivideFloat(FMinX, w) < 3.0) then
      begin
        CondX := DefaultX;
      end else
      begin
        CondX := OpX.Subtract(FMinX, GetGranularX);
      end;
    end;
  end else
  if ((res_1 < 0) and (res_2 < 0)) then
  begin
    if (abs(OpX.DivideFloat(FMaxX, w)) < 3.0) then
    begin
      CondX := DefaultX;
    end else
    begin
      CondX := OpX.Add(FMaxX, GetGranularX);
    end;
  end else
  begin
    CondX := DefaultX;
  end;

  res_1 := OpY.Comparator(FMinY, DefaultY);
  res_2 := OpY.Comparator(FMaxY, DefaultY);
  MaxYIsZero := res_2 = 0;

  { both above DefaultY }
  if ((res_1 > 0) and (res_2 > 0)) then
  begin
    if WidthYIsZero then
    begin
      if MaxYIsZero or (abs(OpY.DivideFloat(DefaultY, FMaxY)) < 3.0) then
      begin
        CondY := DefaultY;
      end else
      begin
        CondY := OpY.Subtract(FMinY, GetGranularY);
      end;
    end else
    begin
      if (OpY.DivideFloat(FMinY, h) < 3.0) then
      begin
        CondY := DefaultY;
      end else
      begin
        CondY := OpY.Subtract(FMinY, GetGranularY);
      end;
    end;
  end else
  if ((res_1 < 0) and (res_2 < 0)) then
  begin
    if (abs(OpY.DivideFloat(FMaxY, h)) < 3.0) then
    begin
      CondY := DefaultY;
    end else
    begin
      CondY := OpY.Add(FMaxY, GetGranularY);
    end;
  end else
  begin
    CondY := DefaultY;
  end;


  if OpX.Comparator(FMinX, CondX) >= 0 then
    ValidAreaMinX := CondX
  else
    ValidAreaMinX := FMinX;

  if OpY.Comparator(FMinY, CondY) >= 0 then
    ValidAreaMinY := CondY
  else
    ValidAreaMinY := FMinY;

  if OpX.Comparator(FMaxX, CondX) <= 0 then
    ValidAreaMaxX := CondX
  else
    ValidAreaMaxX := FMaxX;

  if OpY.Comparator(FMaxY, CondY) <= 0 then
    ValidAreaMaxY := CondY
  else
    ValidAreaMaxY := FMaxY;

  WidthX  := OpX.Subtract(ValidAreaMaxX, ValidAreaMinX);
  HeightY := OpY.Subtract(ValidAreaMaxY, ValidAreaMinY);

end;

constructor TBChart<TX, TY>.Create(ACanvas: TBCanvas);
begin
  inherited;

  { fill methods with inverted position so as we used variables WidthXIsZero,
    MaxXIsZero, and so on.. }
  GetArgX[false, false] := GetArg11;
  GetArgX[true, false] := GetArg01;
  GetArgX[true, true] := GetArg00;
  GetArgX[false, true] := GetArg11;

  GetArgY[false, false] := GetFuncPos11;
  GetArgY[true, false] := GetFuncPos01;
  GetArgY[true, true] := GetFuncPos00;
  GetArgY[false, true] := GetFuncPos11;

  FCurves := TListVec<TDataContainerPairXY>.Create;
  AxisText := TListVec<TCanvasText>.Create;
  if OwnCanvas then
  FCanvas.Font.Size := 9;

  FInterpolateLines := true;
  CurrentColor := TBSColorsSet[bsRed];
  CurrentIndexSets := bsRed;
  FGridStepX := DEFAULT_SIZE_GRID_CELL * 5 * ToHiDpiScale;
  FGridStepY := FGridStepX;
  FAxisColor := BS_CL_GREEN;
  FAxisColor2 := BS_CL_GREEN;
  FAxisXTextColor := BS_CL_WHITE;
  FAxisYTextColor := BS_CL_WHITE;
  FAxisWidth := round(2 * ToHiDpiScale);
  FShowContour := false;
  FShowZeroPoint := true;
  LegendsOffset := 5 * ToHiDpiScale;
  FShowGrid := true;

  Rect := TRectangleTextured(CreateMainBody(TRectangleTextured));
  Rect.Texture := BSTextureManager.GenerateTexture(
      vec4(BS_CL_SILVER2.r, BS_CL_SILVER2.g, BS_CL_SILVER2.b, 1.0),
      vec4(BS_CL_DARK.r, BS_CL_DARK.g, BS_CL_DARK.b, 1.0),
      gtRadialSquare,
      32
    );
  Rect.Size := DefaultSize;
  Rect.Fill := true;
  Rect.Data.Opacity := 0.2;
  Rect.Data.DragResolve := true;
  Rect.Layer2d := LAYER_RECT;
  {$ifdef DEBUG_BS}
    Rect.Data.Caption := 'main body';
  {$endif}

  Rect.Position2d := vec2(200.0 * ToHiDpiScale, 200.0 * ToHiDpiScale);
  LevelAxis := FCanvas.CreateEmptyCanvasObject(Rect);
  LevelAxis.Layer2d := LAYER_AXIS;
  FNameAxisX := TCanvasText.Create(FCanvas, LevelAxis);
  FNameAxisX.Text := 'X';
  FNameAxisY := TCanvasText.Create(FCanvas, LevelAxis);
  FNameAxisY.Text := 'Y';
  Grid := TGrid.Create(FCanvas, Rect);
  Grid.VertLines := true;
  Grid.HorLines := true;
  Grid.Closed := true;
  Grid.Size := Rect.Size;
  Grid.Data.Opacity := 0.1;
  Grid.Color := BS_CL_GREEN;
  Grid.Parent := Rect;
  Grid.Data.Interactive := false;
  Grid.Data.Hidden := not FShowGrid;
  Grid.Layer2d := LAYER_GRID;
  Grid.WidthLines := round(1*ToHiDpiScale);
  FNameAxisX.Parent := LevelAxis;
  FNameAxisY.Parent := LevelAxis;
  FNameAxisY.Data.Hidden := not FShowAxisY;
  FNameAxisX.Data.Hidden := not FShowAxisX;
  FAxisXSize := Round(Grid.Size.Width);
  FAxisYSize := Round(Grid.Size.Height);
end;

destructor TBChart<TX, TY>.Destroy;
begin
  Clear;
  FCurves.Free;
  AxisX.Free;
  AxisY.Free;
  Grid.Free;
  LevelAxis.Free;
  Rect.Free;
  AxisText.Free;
  inherited;
end;

procedure TBChart<TX, TY>.SetGridStepX(const Value: BSFloat);
begin
  FGridStepX := Value;
  BuildView;
end;

procedure TBChart<TX, TY>.SetGridStepY(const Value: BSFloat);
begin
  FGridStepY := Value;
  BuildView;
end;

procedure TBChart<TX, TY>.ClearTextAxis;
var
  i: int32;
begin
  if AxisText = nil then
    exit;
  for i := 0 to AxisText.Count - 1 do
    AxisText.Items[i].Free;
  AxisText.Count := 0;
end;

procedure TBChart<TX, TY>.BuildView;
var
  i: int32;
begin
  if (UpdateCounter > 0) or (FCurves.Count = 0) then
    exit;

  ClearTextAxis;

  { befor draw calculate adjustments; don't change order! }
  CalcLimits;
  CalcGridStep;
  CalcPositionAxes;

  DrawGrid;
  DrawAxis;

  for i := 0 to FCurves.Count - 1 do
    DrawChart(FCurves.Items[i]);

  if FShowLegend then
    DrawLegends;
end;

function TBChart<TX, TY>.DefaultSize: TVec2f;
begin
  Result := vec2(300 * ToHiDpiScale, 300 * ToHiDpiScale);
end;

procedure TBChart<TX, TY>.DrawAxis;
begin
  RecreateAxisX;
  RecreateAxisY;
  if Assigned(AxisY) then
    CondXLeft := AxisY.Position2d.x + AxisY.Width*0.5;
  if Assigned(AxisX) then
    CondYTop := AxisX.Position2d.y + AxisX.Height*0.5;
end;

function TBChart<TX, TY>.GetArg00(const Argument: TX): BSFloat;
begin
  Result := 0.0;
end;

function TBChart<TX, TY>.GetArg01(const Argument: TX): BSFloat;
begin
  Result := OpX.DivideFloat(OpX.Subtract(Argument, ValidAreaMinX), ValidAreaMaxX) * FAxisXSize + (AxisXSizeAligned - FAxisXSize);
end;

function TBChart<TX, TY>.GetArg11(const Argument: TX): BSFloat;
begin
  Result := OpX.DivideFloat(OpX.Subtract( Argument, CondX ), WidthX ) * FAxisXSize + CondXLeft;
end;

function TBChart<TX, TY>.GetFuncPos00(const FuncResult: TY): BSFloat;
begin
  Result := 0.0;
end;

function TBChart<TX, TY>.GetFuncPos01(const FuncResult: TY): BSFloat;
begin
  Result := OpY.DivideFloat(OpY.Subtract(CondY, FuncResult), ValidAreaMaxY) * FAxisYSize + CondYTop;
end;

function TBChart<TX, TY>.GetFuncPos11(const FuncResult: TY): BSFloat;
begin
  Result := OpY.DivideFloat(OpY.Subtract( CondY, FuncResult ), HeightY) * FAxisYSize + CondYTop;
end;

function TBChart<TX, TY>.GetGranularX: TX;
begin
  Result := DefaultX;
end;

function TBChart<TX, TY>.GetGranularY: TY;
begin
  Result := DefaultY;
end;

function TBChart<TX, TY>.GetNameAxisX: string;
begin
  Result := FNameAxisX.Text;
end;

function TBChart<TX, TY>.GetNameAxisY: string;
begin
  Result := FNameAxisY.Text;
end;

function TBChart<TX, TY>.CompareBackgroundColor: boolean;
begin
  Result := (CompareLimit(CurrentColor.r, FCanvas.Renderer.Color.r, 0.25) = 0) and
      (CompareLimit(CurrentColor.g, FCanvas.Renderer.Color.g, 0.25) = 0) and
      (CompareLimit(CurrentColor.b, FCanvas.Renderer.Color.b, 0.25) = 0);
end;

function TBChart<TX, TY>.GetNextColor: TColor4f;
begin
  Result := CurrentColor;
  IncColor;
end;

procedure TBChart<TX, TY>.IncColor;
begin
  inc(CurrentIndexSets);
  if CurrentIndexSets = high(TBSColors) then
    CurrentIndexSets := bsRed;
  CurrentColor := TBSColorsSet[CurrentIndexSets];
  if (CompareBackgroundColor) then
    IncColor;
end;

procedure TBChart<TX, TY>.RemoveChart(Chart: TDataContainer<TX, TY>);
begin
  FCurves.Remove(Chart);
end;

procedure TBChart<TX, TY>.Resize(AWidth, AHeight: BSFloat);
begin
  BeginUpdate;
  try
    //FAxisXSize := round(AWidth);
    //FAxisYSize := round(AHeight);
    { first need to set parent position for correct to get visibility axis in time draw (otherwise
      axis may be not visible at this time) }
    if LevelAxis <> nil then
      LevelAxis.Position2d := LevelAxis.Position2d;
    // now change axis size
    FAxisXSize := 0; // for ban twice redraw
    Rect.Size := vec2(AWidth, AHeight);
    Grid.Size := Rect.Size;
    AxisYSize := round(AHeight);
    AxisXSize := round(AWidth);
  finally
    EndUpdate;
  end;
  inherited;
end;

procedure TBChart<TX, TY>.SetInterpolateLines(const Value: boolean);
begin
  FInterpolateLines := Value;
  BuildView;
end;

procedure TBChart<TX, TY>.SetNameAxisX(const Value: string);
begin
  FNameAxisX.Text := Value;
end;

procedure TBChart<TX, TY>.SetNameAxisY(const Value: string);
begin
  FNameAxisY.Text := Value;
end;

procedure TBChart<TX, TY>.CalcPositionAxes;
begin
  CalcSizeAlignedAxisX;
  CalcSizeAlignedAxisY;
  { check WidthX on "zero" a boundary snippet argument TX; calculate position
    axis relative condition CondX }
  if OpX.Comparator(WidthX, DefaultX) = 0 then
    PositionAxis.x := 0
  else
    PositionAxis.x := OpX.DivideFloat(OpX.Subtract(CondX, FMinX), WidthX) * AxisXSizeAligned;

  { the same for HeightY }
  if OpY.Comparator(HeightY, DefaultY) = 0 then
    PositionAxis.y := 0
  else
    PositionAxis.y := AxisYSizeAligned * (1 - OpY.DivideFloat(OpY.Subtract(CondY, FMinY), HeightY));
  if PositionAxis.x > 0 then
    AxisXAlign := Remainder(PositionAxis.x, FGridStepX) - FGridStepX
  else
    AxisXAlign := 0;
  if PositionAxis.y > 0 then
    AxisYAlign := Remainder(PositionAxis.y, FGridStepY) - FGridStepY
  else
    AxisYAlign := 0;
  if WidthXIsZero or ((OpX.Comparator(WidthX, DefaultX) <> 0) and (OpX.DivideFloat(
    OpX.Subtract(FMaxX, FMinX), WidthX) * AxisXSizeAligned - AxisXAlign > AxisXSizeAligned)) then
      AxisXSizeAligned := AxisXSizeAligned + FGridStepX;
  if WidthYIsZero or ((OpY.Comparator(HeightY, DefaultY) <> 0) and (OpY.DivideFloat(
    OpY.Subtract(FMaxY, FMinY), HeightY) * AxisYSizeAligned - AxisYAlign > AxisYSizeAligned)) then
      AxisYSizeAligned := AxisYSizeAligned + FGridStepY;
end;

procedure TBChart<TX, TY>.SetShowAxisName(const Value: boolean);
begin
  FShowAxisName := Value;
  FNameAxisX.Data.Hidden := FShowAxisName;
  FNameAxisY.Data.Hidden := FShowAxisName;
end;

procedure TBChart<TX, TY>.SetShowAxisX(const Value: boolean);
begin

end;

procedure TBChart<TX, TY>.SetShowAxisY(const Value: boolean);
begin

end;

procedure TBChart<TX, TY>.SetAxisColor(const Value: TColor4f);
begin
  FAxisColor := Value;
end;

procedure TBChart<TX, TY>.SetAxisColor2(const Value: TColor4f);
begin
  FAxisColor2 := Value;
end;

procedure TBChart<TX, TY>.SetAxisWidth(const Value: int8);
begin
  FAxisWidth := Value;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetAxisXSize(const Value: int32);
begin
  FAxisXSize := Value;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetAxisXTextColor(const Value: TColor4f);
begin
  FAxisXTextColor := Value;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetAxisYSize(const Value: int32);
begin
  FAxisYSize := Value;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetAxisYTextColor(const Value: TColor4f);
begin
  FAxisYTextColor := Value;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetShowContour(const Value: boolean);
var
  i: int32;
begin
  if FShowContour = Value then
    exit;
  FShowContour := Value;
  if FShowContour then
  begin
    for i := 0 to FCurves.Count - 1 do
    begin
      with FCurves.Items[i] do
      begin
        FreeAndNil(FContour);
      end;
    end;
  end else
  begin
    for i := 0 to FCurves.Count - 1 do
    begin
      CreateContour(FCurves.Items[i]);
      DrawContour(FCurves.Items[i]);
    end;
  end;
end;

procedure TBChart<TX, TY>.SetShowGrid(const Value: boolean);
begin
  FShowGrid := Value;
  Grid.Data.Hidden := not FShowGrid;
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.SetShowLegend(const Value: boolean);
begin
  if FShowLegend = Value then
    exit;
  FShowLegend := Value;
  if UpdateCounter = 0 then
  begin
    if LegendPlane <> nil then
      LegendPlane.Data.SetHiddenRecursive(not FShowLegend)
    else
      BuildView;
  end;
end;

procedure TBChart<TX, TY>.RecreateAxisX;
begin
  if AxisX <> nil then
    FreeAndNil(AxisX);
  if (FGridStepX = 0) or (FAxisXSize = 0) or (not FShowAxisX) then
    exit;
  AxisX := TArrow.Create(FCanvas, LevelAxis);
  AxisX.A := vec2(0.0, 0.0);
  AxisX.B := vec2(round(Rect.Size.Width) + round(50 * ToHiDpiScale), 0.0);
  AxisX.SizeTip := vec2(DEFAULT_SIZE_TIP_AXIS * ToHiDpiScale, 10 * ToHiDpiScale);
  AxisX.Color := FAxisColor;
  AxisX.LineWidth := 2 * ToHiDpiScale;
  AxisX.Build;
  //AxisX.Data.Interactive := false;
  AxisX.Layer2d := LAYER_AXIS;
  AxisX.Position2d := vec2( 0, PositionAxis.y - AxisYAlign - AxisX.Height*0.5);
  if AxisX.Position2d.y < 0 then
    AxisX.Position2d := vec2(AxisX.Position2d.x, 0.0);
  if AxisX.Position2d.y > Rect.Size.Height then
    AxisX.Position2d := vec2(AxisX.Position2d.x, Rect.Size.Height - AxisX.Height*0.5);
  FNameAxisX.Layer2d := LAYER_AXIS;
  FNameAxisX.Position2d := vec2( AxisX.Position2d.x + AxisX.Width + 5, AxisX.Position2d.y + 10 );
  FNameAxisX.Color := AxisX.Color;
end;

procedure TBChart<TX, TY>.RecreateAxisY;
begin
  if AxisY <> nil then
    FreeAndNil(AxisY);
  if (FGridStepY = 0) or (FAxisYSize = 0) or (not FShowAxisY) then
    exit;

  AxisY := TArrow.Create(FCanvas, LevelAxis);
  AxisY.B := vec2(0.0, 0.0);
  AxisY.A := vec2(0.0, round(Rect.Size.Height + 50 * ToHiDpiScale));
  AxisY.SizeTip := vec2(round(DEFAULT_SIZE_TIP_AXIS * ToHiDpiScale), round(10 * ToHiDpiScale));
  AxisY.Color := FAxisColor2;
  AxisY.LineWidth := 2 * ToHiDpiScale;
  AxisY.Build;

  //AxisY.Data.Interactive := false;
  AxisY.Layer2d := LAYER_AXIS;
  AxisY.Position2d := vec2( PositionAxis.x - AxisXAlign - AxisY.Width * 0.5, Rect.Size.Height - AxisY.Height );
  if AxisY.Position2d.x < 0 then
    AxisY.Position2d := vec2(- AxisY.Width / 2, AxisY.Position2d.y);
  if AxisY.Position2d.x > Rect.Size.Width then
    AxisY.Position2d := vec2(Rect.Size.Width - AxisY.Width / 2, AxisY.Position2d.y);
  AxisY.Color := BS_CL_GREEN;
  FNameAxisY.Position2d := vec2( AxisY.Position2d.x + 10, AxisY.Position2d.y );
  FNameAxisY.Layer2d := LAYER_AXIS;
  FNameAxisY.Color := BS_CL_GREEN;
end;

function TBChart<TX, TY>.CreateChart: TDataContainer<TX, TY>;
var
  path: TPath;
begin
  path := TPath.Create(FCanvas, LevelAxis);
  path.Layer2d := LAYER_CHART;
  Result := TDataContainer<TX, TY>.Create(path, OpX, OpY);
  if FShowContour then
    CreateContour(Result);
  Result.FIndex := FCurves.Count;
  Result.Color := GetNextColor;

  FCurves.Add(Result);
end;

procedure TBChart<TX, TY>.CreateContour(Chart: TDataContainer<TX, TY>);
begin
  if Chart.FContour <> nil then
    exit;
  Chart.FContour := TPath.Create(FCanvas, LevelAxis);
  Chart.FContour.Color := BS_CL_ORANGE_2;
  Chart.FContour.Data.Opacity := 0.7;
end;

procedure TBChart<TX, TY>.DrawContour(Chart: TDataContainer<TX, TY>);
begin
  Chart.FContour.Data.Mesh.Clear;
  //CreateBorder(Chart.FPath.Data.Mesh, Chart.FContour.Data.Mesh, 1.0, true);
  Chart.FContour.Data.ChangedMesh;
  //Chart.FContour.Layer2d := 30;
  Chart.FContour.Position2d := Chart.FPath.Position2d - vec2((Chart.FContour.Width-Chart.FPath.Width)*0.5,
    (Chart.FContour.Height-Chart.FPath.Height)*0.5);
end;

procedure TBChart<TX, TY>.DrawGrid;
var
  s: TVec2f;
begin
  s := vec2(AxisXSizeAligned, AxisYSizeAligned);
  if FShowGrid then
  begin
    Grid.Size := s;
    Grid.StepX := FGridStepX;
    Grid.StepY := FGridStepY;
    Grid.Build;
  end;
  Rect.Size := s;
  Rect.Build;
  Grid.Position2d := vec2(0.0, 0.0);
  LevelAxis.Position2d := vec2(0.0, 0.0);
end;

procedure TBChart<TX, TY>.DrawLegends;
const
  OFFSET_HEIGHT = 5;
var
  fs: int16;
  i: int32;
  s: TVec2f;
begin
  if FLegends = nil then
    exit;
  fs := round(OFFSET_HEIGHT*ToHiDpiScale) + FCanvas.Font.SizeInPixels;
  s.x := 0.0;
  for i := 0 to FLegends.Count - 1 do
    if FLegends.Items[i].Text.Width > s.x then
      s.x := FLegends.Items[i].Text.Width;
  s.x := s.x + round(40 * ToHiDpiScale);
  s.y := round(fs * FLegends.Count + 10*ToHiDpiScale);
  LegendPlane.Size := s;
  LegendPlane.Build;
  LegendBorder.Size := s;
  LegendBorder.Build;
  LegendBorder.Position2d := vec2(0.0, 0.0);
  LegendPlane.Position2d := vec2(Grid.Width + LegendsOffset, 0);
  for i := 0 to FLegends.Count - 1 do
    begin
    FLegends.Items[i].Text.Position2d := vec2(20.0 * ToHiDpiScale, fs*i + 8 * ToHiDpiScale);
    FLegends.Items[i].Rect.Position2d := vec2(8.0 * ToHiDpiScale, FLegends.Items[i].Text.Position2d.y +
      (FLegends.Items[i].Text.Height - FLegends.Items[i].Rect.Size.Height)*0.5);
    end;
end;

procedure TBChart<TX, TY>.EndUpdate;
begin
  dec(UpdateCounter);
  if UpdateCounter = 0 then
    BuildView;
end;

procedure TBChart<TX, TY>.CalcSizeAlignedAxisX;
begin
  AxisXSizeAligned := (FAxisXSize div Round(FGridStepX)) * FGridStepX;
  if FAxisXSize mod Round(FGridStepX) > 0 then
    AxisXSizeAligned := AxisXSizeAligned + FGridStepX;
end;

procedure TBChart<TX, TY>.CalcSizeAlignedAxisY;
begin
  AxisYSizeAligned := (FAxisYSize div Round(FGridStepY)) * FGridStepY;
  if FAxisYSize mod Round(FGridStepY) > 0 then
    AxisYSizeAligned := AxisYSizeAligned + FGridStepY;
end;

procedure TBChart<TX, TY>.Clear;
var
  i: int32;
begin
  ClearTextAxis;
  for i := 0 to FCurves.Count - 1 do
    FCurves.Items[i].Free;
  FCurves.Count := 0;
  if Assigned(FLegends) then
  begin
    for i := 0 to FLegends.Count - 1 do
    begin
      FLegends.Items[i].Text.Free;
      FLegends.Items[i].Rect.Free;
    end;

    if Assigned(LegendFont) then
    begin
      { so as, billboard legends uses self reference font for text (different form canvas),
        thus need free reference through font manager }
      LegendFont := nil;
    end;
    FreeAndNil(FLegends);
    FreeAndNil(LegendPlane);
  end;
end;

procedure TBChart<TX, TY>.DeleteChart(Chart: TDataContainer<TX, TY>);
var
  i: int32;
begin
  FCurves.Remove(Chart);
  for i := 0 to FCurves.Count - 1 do
    FCurves.Items[i].FIndex := i;
  Chart.Free;
end;

{$endregion}

{$region 'TBChartCurves<TX, TY>'}

{ TBChartCurves<TX, TY> }

constructor TBChartCurves<TX, TY>.Create(ACanvas: TBCanvas);
begin
  inherited;
  GroupMouseEnter := BObserversGroup<BMouseData>.Create(OnPointMouseEnter);
  GroupMouseLeave := BObserversGroup<BMouseData>.Create(OnPointMouseLeave);
  FShowPoints := true;
  FShowAxisY := true;
  FShowAxisX := true;
  FShowGrid := true;
  FShowAxisName := true;
end;

function TBChartCurves<TX, TY>.CreateChart: TDataContainer<TX, TY>;
begin
  Result := inherited CreateChart;
  Result.FPath.InterpolateSpline := FInterpolateSpline;
end;

procedure TBChartCurves<TX, TY>.LoadProperties;
begin
  inherited;
  InterpolateSpline := isCubicHermite;
end;

procedure TBChartCurves<TX, TY>.CreateHint(const Text: string);
var
  s: TVec2f;
begin
  if (HintText = nil) then
  begin
    HintText := TCanvasText.Create(FCanvas, PointHint);
    HintText.Color := BS_CL_BLACK;
    //HintText.Align := TObjectAlign.oaCenter;
    HintText.Text := Text;
    PointHint := TRoundRectTextured.Create(FCanvas, LevelAxis);
    PointHint.Size := vec2(HintText.Width + 8, HintText.Height + 8);
    PointHint.Fill := true;
    PointHint.RadiusRound := 4;
    PointHint.Texture := BSTextureManager.GenerateTexture(BS_CL_ORANGE, BS_CL_ORANGE_LIGHT, gtRadialSquareVertical, 32);
    PointHint.Build;
    PointHint.Layer2d := LAYER_CHART + 5;
    HintText.Parent := PointHint;
  end else
  begin
    //HintText.Align := TObjectAlign.oaNone;
    HintText.Text := Text;
    s.x := (HintText.Width + 8);
    s.y := (HintText.Height + 8);
    PointHint.Size := s;
    PointHint.Build;
    //HintText.Align := TObjectAlign.oaCenter;
  end;
  HintText.Position2d := vec2((PointHint.Width - HintText.Width) * 0.5, (PointHint.Height - HintText.Height) * 0.5);
end;

destructor TBChartCurves<TX, TY>.Destroy;
begin
  GroupMouseEnter.Free;
  GroupMouseLeave.Free;
  if (HintText <> nil) then
  begin
    HintText.Free;
    PointHint.Free;
  end;
  inherited;
end;

procedure TBChartCurves<TX, TY>.BuildView;
var
  x, y: BSFloat;
  c: BSFloat;
  pos: TVec2f;
  count: int32;
  txt, prev: TCanvasText;
  s, zero_s, befor_s: string;
begin
  inherited BuildView;
  if (GridStepX = 0) or (GridStepY = 0) then
    exit;

  if (AxisY <> nil) and (FShowAxisX) then
    x := AxisY.Position2d.x + AxisY.Width * 0.5
  else
    x := Rect.Position2d.x;

  if (AxisX <> nil) and (FShowAxisY) then
    y := AxisX.Position2d.y + AxisX.Height * 0.5
  else
    y := Rect.Size.Height;

  zero_s := OpX.ToString(CondX);
  c := AxisXSizeAligned / FGridStepX;
  if c > 0 then
  begin
    pos.x := x - FGridStepX;
    pos.y := y + 4;
    s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x - x) / FAxisXSize)));
    prev := nil;
    // negative X-axis values
    while (pos.x + AxisY.Width >= 0) do
    begin
      if (s <> zero_s) and (s <> '') then
      begin
        befor_s := s;
        count := 1;
        { discards reapeating values }
        while (count < 30) do
        begin
          pos.x := pos.x - FGridStepX;
          s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x - x) / FAxisXSize)));
          if (befor_s = s) then
            inc(count)
          else
            break;
        end;

        txt := TCanvasText.Create(FCanvas, LevelAxis);
        txt.Text := befor_s;
        txt.Layer2d := LAYER_AXIS;
        txt.Data.Interactive := false;
        txt.Color := FAxisYTextColor;
        AxisText.Add(txt);
        if count = 1 then
          txt.Position2d := vec2(pos.x + FGridStepX , pos.y)
        else
        if count and 1 = 0 then
          txt.Position2d := vec2(pos.x + ((count shr 1) * FGridStepX), pos.y)
        else
          txt.Position2d := vec2(pos.x + ((count + 1) shr 1) * FGridStepX, pos.y);

        if (prev <> nil) and (txt.Position2d.x + txt.Width + 3 > prev.Position2d.x) then
        begin
          AxisText.Delete(AxisText.Count - 1);
          txt.Free;
          continue;
        end;
        prev := txt;
      end else
      begin
        pos.x := pos.x - FGridStepX;
        s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x - x) / FAxisXSize)));
      end;
    end;
    pos.x := x;
    // out zero - point of origin
    if Assigned(AxisY) and Canvas.Renderer.IsVisible(AxisY.Data) then
    begin
      if FShowZeroPoint then
      begin
        if zero_s <> '' then
        begin
          txt := TCanvasText.Create(FCanvas, LevelAxis);
          txt.Text := zero_s;
          txt.Position2d := vec2(pos.x + AxisY.Width + 5 * ToHiDpiScale, pos.y);
          txt.Layer2d := LAYER_AXIS;
          txt.Data.Interactive := false;
          txt.Color := FAxisXTextColor;
          AxisText.Add(txt);
        end;
      end;
      pos.x := pos.x + FGridStepX;
    end;

    prev := nil;
    s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x-x)/FAxisXSize)));
    // positive X-axis values
    while pos.x < Rect.Size.Width do
    begin
      if (s <> zero_s) and (s <> '') then
      begin
        befor_s := s;
        count := 1;
        { discards reapeating values }
        while (count < 30) do
        begin
          pos.x := pos.x + FGridStepX;
          s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x - x)/FAxisXSize)));
          if (befor_s = s) then
            inc(count)
          else
            break;
        end;
        txt := TCanvasText.Create(FCanvas, LevelAxis);
        txt.Text := befor_s;
        txt.Layer2d := LAYER_AXIS;
        txt.Data.Interactive := false;
        txt.Color := FAxisYTextColor;
        AxisText.Add(txt);
        if count = 1 then
          txt.Position2d := vec2(pos.x - FGridStepX , pos.y)
        else
        if count and 1 = 0 then
          txt.Position2d := vec2(pos.x - ((count shr 1) * FGridStepX), pos.y)
        else
          txt.Position2d := vec2(pos.x - (((count + 1) shr 1) * FGridStepX), pos.y);
        if Assigned(prev) and (prev.Position2d.x + prev.Width + 3 > txt.Position2d.x) then
        begin
          AxisText.Delete(AxisText.Count - 1);
          txt.Free;
          continue;
        end;
        prev := txt;
      end else
      begin
        pos.x := pos.x + FGridStepX;
        s := OpX.ToString(OpX.Add(CondX, OpX.MultiplyFloat(WidthX, (pos.x - x)/FAxisXSize)));
      end;
    end;
  end;
  c := AxisYSizeAligned / FGridStepY;
  zero_s := OpY.ToString(CondY);
  if c > 0 then
  begin
    pos.y := y + GridStepY;
    if Assigned(AxisY) then
      pos.x := x + FAxisWidth + 5 + AxisY.Width;
    // negative part Y-axis
    s := OpY.ToString(OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize));
    while pos.y <= Rect.Size.Height do
    begin
      if (s <> zero_s) and (s <> '') then
      begin
        befor_s := s;
        count := 1;
        { discards reapeating values }
        while (count < 30) do
        begin
          pos.y := pos.y + FGridStepY;
          s := OpY.ToString(OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize));
          if (befor_s = s) then
            inc(count)
          else
            break;
        end;
        txt := TCanvasText.Create(FCanvas, LevelAxis);
        txt.Text := befor_s;
        txt.Layer2d := LAYER_AXIS;
        txt.Data.Interactive := false;
        txt.Color := FAxisYTextColor;
        AxisText.Add(txt);
        { set position in middle over reapeating values an area }

        if count = 1 then
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale - FGridStepY)
          else
        if count and 1 = 0 then
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale - ((count shr 1) * FGridStepY))
        else
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale - ((count + 1) shr 1) * FGridStepY);
      end else
      begin
        pos.y := pos.y + FGridStepY;
        s := OpY.ToString(OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize));
      end;
    end;
    pos.y := y;
    if Assigned(AxisY) then
      pos.x := x + FAxisWidth + 5 + AxisY.Width
    else
      pos.x := x + FAxisWidth + 5;
    if Assigned(AxisX) and Canvas.Renderer.IsVisible(AxisX.Data) then
    begin
      pos.y := pos.y - FGridStepY;
    end;
    // positive part Y-axis
    s := OpY.ToString(OpY.Add(CondY, OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize)));
    while pos.y >= -FAxisWidth*4 do
    begin
      if (s <> zero_s) and (s <> '') then
      begin
        befor_s := s;
        count := 1;
        { discards reapeating values }
        while (count < 30) do
        begin
          pos.y := pos.y - FGridStepY;
          s := OpY.ToString(OpY.Add(CondY, OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize)));
          if (befor_s = s) then
            inc(count)
          else
            break;
        end;
        txt := TCanvasText.Create(FCanvas, LevelAxis);
        txt.Text := befor_s;
        txt.Layer2d := LAYER_AXIS;
        txt.Data.Interactive := false;
        txt.Color := FAxisYTextColor;
        AxisText.Add(txt);
        if count = 1 then
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale + FGridStepY)
        else
        if count and 1 = 0 then
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale + ((count shr 1) * FGridStepY))
        else
          txt.Position2d := vec2(pos.x , pos.y - FCanvas.Font.SizeInPixels - 2 * ToHiDpiScale + ((count + 1) shr 1) * FGridStepY);
      end else
      begin
        pos.y := pos.y - FGridStepY;
        s := OpY.ToString(OpY.Add(CondY, OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize)));
      end;
    end;
  end;
end;

procedure TBChartCurves<TX, TY>.OnPointMouseEnter(const Data: BMouseData);
var
  pair: TDataContainerPairXY.PArgValue;
  c: TCircle;
begin
  c := TCircle(PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.Owner);
  pair := c.Data.TagPtr;
  CreateHint(OpX.ToString(pair^.Group^.ValueX) + '; ' + OpY.ToString(pair^.ValueY) + ';');
  PointHint.Data.Hidden := false;
  HintText.Data.Hidden := false;
  PointHint.Position2d := vec2(c.Position2d.x + c.Width, c.Position2d.y - PointHint.Height);
end;

procedure TBChartCurves<TX, TY>.OnPointMouseLeave(const Data: BMouseData);
begin
  PointHint.Data.Hidden := true;
  HintText.Data.Hidden := true;
end;

procedure TBChartCurves<TX, TY>.DrawChart(Chart: TDataContainer<TX, TY>);
//const
//  POINT_RADIUS: int8 = 4;
var
  i: int32;
  pair: TDataContainerPairXY.PArgValue;
  v2i: TVec2i;
  p: TCircle;

begin
  if (FAxisXSize = 0) or (FAxisYSize = 0) or (Chart.FValues.Count = 0) then
    exit;
  Chart.FPath.Clear;
  Chart.FPath.ShowPoints := FShowPoints;
  GroupMouseEnter.Clear;
  GroupMouseLeave.Clear;

  if FShowContour then
    Chart.FPath.WidthLine := 1 * ToHiDpiScale
  else
    Chart.FPath.WidthLine := 2 * ToHiDpiScale;

  for i := 0 to Chart.FValues.Count - 1 do
  begin
    pair := Chart.FValues.ShiftData[i];
    v2i.x := round(GetArgX[WidthXIsZero, MaxXIsZero](pair.Group.ValueX));
    v2i.y := round(GetArgY[WidthYIsZero, MaxYIsZero](pair.ValueY));
    p := Chart.FPath.AddPoint(vec2(int32(round(v2i.x)), v2i.y));
    if p <> nil then // FShowPoints
    begin
      p.Data.TagPtr := pair;
      GroupMouseEnter.CreateObserver(p.Data.EventMouseEnter);
      GroupMouseLeave.CreateObserver(p.Data.EventMouseLeave);
    end;
  end;

  Chart.FPath.Build;

  Chart.FPath.Position2d := vec2(
    GetArgX[WidthXIsZero, MaxXIsZero](Chart.FMinX) - Chart.FPath.WidthLine * 0.5,
    GetArgY[WidthYIsZero, MaxYIsZero](Chart.FMaxY) - Chart.FPath.WidthLine * 0.5);

  if FShowContour then
    DrawContour(Chart);
end;

procedure TBChartCurves<TX, TY>.SetInterpolateSpline(
  const Value: TInterpolateSpline);
var
  i: int32;
begin
  if FInterpolateSpline = Value then
    exit;
  FInterpolateSpline := Value;
  for i := 0 to FCurves.Count - 1 do
    FCurves.Items[i].FPath.InterpolateSpline := FInterpolateSpline;
end;

procedure TBChartCurves<TX, TY>.SetShowPoints(const Value: boolean);
begin
  FShowPoints := Value;
  if not FShowPoints and (PointHint <> nil) then
  begin
    PointHint.Data.Hidden := true;
    HintText.Data.Hidden := true;
  end;
  BuildView;
end;

{$endregion}

{$region 'TBChartBar<TX, TY>'}

{ TBChartBar<TX, TY> }

constructor TBChartBar<TX, TY>.Create(ACanvas: TBCanvas);
begin
  inherited;
  FShowAxisY := true;
  FShowAxisX := true;
  FShowAxisName := true;
  FShowGrid := true;
end;

procedure TBChartBar<TX, TY>.BuildView;
var
  x, y: BSFloat;
  c: BSFloat;
  pos: TVec2f;
  txt: TCanvasText;

begin
  inherited;
  if (GridStepX = 0) or (GridStepY = 0) then
    exit;

  if Assigned(AxisY) and (FShowAxisX) then
    x := AxisY.Position2d.x + AxisY.Width * 0.5
  else
    x := Rect.Position2d.x;

  if Assigned(AxisX) and (FShowAxisY) then
    y := AxisX.Position2d.y + AxisX.Height  * 0.5
  else
    y := Rect.Size.Height;

  c := AxisYSizeAligned / FGridStepY;
  if (c > 0) and Assigned(AxisY) and Canvas.Renderer.IsVisible(AxisY.Data) then
  begin
    pos.y := y + GridStepX;
    pos.x := x - FCanvas.Font.AverageWidth*4 - 5 * ToHiDpiScale;
    // negative part Y-axis
    while pos.y < Rect.Size.Height do
    begin
      txt := TCanvasText.Create(FCanvas, LevelAxis);
      txt.Text := OpY.ToString(OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize));
      txt.Layer2d := LAYER_AXIS;
      txt.Position2d := vec2(pos.x, pos.y - FCanvas.Font.SizeInPixels - 3 * ToHiDpiScale);
      txt.Data.Interactive := false;
      txt.Color := FAxisYTextColor;
      AxisText.Add(txt);
      pos.y := pos.y + FGridStepY;
    end;
    pos.y := y;
    //pos.x := x + FAxisWidth + 5;
    // out zero - point of origin
    if Assigned(AxisY) and Canvas.Renderer.IsVisible(AxisY.Data) then
    begin
      txt := TCanvasText.Create(FCanvas, LevelAxis);
      txt.Text := OpY.ToString(DefaultY);
      txt.Position2d := vec2(pos.x, pos.y - FCanvas.Font.SizeInPixels - 3 * ToHiDpiScale);
      txt.Layer2d := LAYER_AXIS;
      txt.Data.Interactive := false;
      txt.Color := FAxisYTextColor;
      AxisText.Add(txt);
    end;
    if Assigned(AxisX) and Canvas.Renderer.IsVisible(AxisX.Data) then
      pos.y := pos.y - FGridStepY;
    // positive part Y-axis
    c := FCanvas.Font.SizeInPixels - 5 * ToHiDpiScale - FAxisWidth*2;
    while pos.y >= c do
    begin
      txt := TCanvasText.Create(FCanvas, LevelAxis);
      txt.Text := OpY.ToString(OpY.MultiplyFloat(HeightY, (y - pos.y)/FAxisYSize));
      txt.Layer2d := LAYER_AXIS;
      txt.Position2d := vec2(pos.x, pos.y - FCanvas.Font.SizeInPixels - 3 * ToHiDpiScale);
      txt.Data.Interactive := false;
      txt.Color := FAxisYTextColor;
      AxisText.Add(txt);
      pos.y := pos.y - FGridStepY;
    end;
  end;
end;

procedure TBChartBar<TX, TY>.DrawChart(Chart: TDataContainer<TX, TY>);
const
  BAR_WIDTH = 20;
var
  i: int32;
  pair: TDataContainerPairXY.PGroupValues;
  x, w, wh, step, steph: int32;
  txt: TCanvasText;
begin
  //Pen.DrawBorder := FShowContour;
  //Pen.BoderColor := BS_CL_ORANGE_2;
  w := FCurves.Count * round((BAR_WIDTH + 2) * ToHiDpiScale);
  wh := w div 2;
  step := FAxisXSize {%H-}div int32(MaxCountValues);
  steph := step div 2;
  for i := 0 to Chart.FListValues.Count - 1 do
  begin
    pair := Chart.FListValues.Items[i];
    if pair.GraphIntegral <> nil then
      pair.GraphIntegral.Free;

    pair.Percent := OpY.DivideFloat(pair.ValuesSum, FMaxY);
    pair.GraphIntegral := TRectangle.Create(FCanvas, LevelAxis);
    TRectangle(pair.GraphIntegral).Size := vec2(BAR_WIDTH * ToHiDpiScale, pair.Percent * FAxisYSize);
    TRectangle(pair.GraphIntegral).Fill := true;
    TRectangle(pair.GraphIntegral).Data.Interactive := false;
    pair.GraphIntegral.Build;
    x := step * (i + 1) - steph;
    pair.GraphIntegral.Position2d := vec2(x - wh + (BAR_WIDTH + 2) * ToHiDpiScale
      * Chart.FIndex, Rect.Size.Height - pair.GraphIntegral.Height - 1);
    pair.GraphIntegral.Color := Chart.Color;
    pair.GraphIntegral.Layer2d := Rect.Layer2d + 2;

    txt := TCanvasText.Create(FCanvas, LevelAxis);
    txt.Text := OpX.ToString(pair.ValueX);
    txt.Position2d := vec2(x - txt.Width * 0.5, Rect.Size.Height + FAxisWidth + FCanvas.Font.SizeInPixels + 5 * ToHiDpiScale);
    txt.Data.Interactive := false;
    txt.Layer2d := LAYER_AXIS;
    txt.Color := FAxisXTextColor;
    AxisText.Add(txt);
  end;
end;

{$endregion}


{$region 'TBChartCircular<TX, TY>'}

{ TBChartCircular<TX, TY> }

function TBChartCircular<TX, TY>.AddPart(const Legend: TX; PartTY: BSFloat; const Color: TColor4f): TDataContainerPairXY.PGroupValues;
begin
  if FChart = nil then
    exit(nil);
  Result := FChart.AddPair(Legend, FChart.OpY.MultiplyFloat(CurrentIntegral, PartTY), Color);
end;

procedure TBChartCircular<TX, TY>.AdjustRadius(AWidth, AHeight: BSFloat);
begin
  if AWidth > AHeight then
    FRadius := round(AHeight * 0.5 - 10*ToHiDpiScale)
  else
    FRadius := round(AWidth * 0.5 - 10*ToHiDpiScale);
end;

procedure TBChartCircular<TX, TY>.CalcArcAttrib(var ArcAttrib: TArcAttrib);
begin
  ArcAttrib.Angle := 360*ArcAttrib.Group^.Percent;
  ArcAttrib.Len := ArcAttrib.Group^.Percent * 2 * BS_PI * FRadius;
  BS_SinCos(ArcAttrib.Group.AngleStart + ArcAttrib.Angle/2, ArcAttrib.s, ArcAttrib.c);
  if ArcAttrib.s < 0 then
    begin
    ArcAttrib.SignSin := -1;
    if ArcAttrib.c < 0 then
      begin
      ArcAttrib.SignCos := -1;
      ArcAttrib.NumQuad := 3;
      end else
      begin
      ArcAttrib.SignCos := 1;
      ArcAttrib.NumQuad := 4;
      end;
    end else
    begin
    ArcAttrib.SignSin := 1;
    if ArcAttrib.c < 0 then
      begin
      ArcAttrib.SignCos := -1;
      ArcAttrib.NumQuad := 2;
      end else
      begin
      ArcAttrib.SignCos := 1;
      ArcAttrib.NumQuad := 1;
      end;
    end;
end;

constructor TBChartCircular<TX, TY>.Create(ACanvas: TBCanvas);
begin
  inherited;
  GroupMouseEnter := BObserversGroup<BMouseData>.Create(OnMouseEnter);
  GroupMouseMove := BObserversGroup<BMouseData>.Create(OnMouseMove);
  GroupMouseLeave := BObserversGroup<BMouseData>.Create(OnMouseLeave);

  if Assigned(FNameAxisX) then
    FNameAxisX.Data.Hidden := true;

  if Assigned(FNameAxisY) then
    FNameAxisY.Data.Hidden := true;

  Stack := TListVec<TArcAttrib>.Create;

  if OwnCanvas then
    FCanvas.Font.SizeInPixels := round(12*ToHiDpiScale);

  FShowAxisY := false;
  FShowAxisX := false;
  FShowAxisName := false;
  FShowGrid := true;
  FSortOnGrowY := true;
end;

function TBChartCircular<TX, TY>.CreateChart: TDataContainer<TX, TY>;
begin
  if FChart <> nil then
    Result := FChart
  else
    begin
    Result := inherited;
    FChart := Result;
    end;
end;

procedure TBChartCircular<TX, TY>.LoadProperties;
begin
  inherited;
  AniLawScale := CreateAniFloatLinear;
  ObsrvScale := AniLawScale.CreateObserver(OnUpdateValueScale);
  AniLawScale.Duration := 150;
  AdjustRadius(Rect.Size.Width, Rect.Size.Height);
end;

destructor TBChartCircular<TX, TY>.Destroy;
begin

  GroupMouseEnter.Free;
  GroupMouseLeave.Free;
  GroupMouseMove.Free;

  ObsrvScale := nil;
  AniLawScale := nil;

  HintText.Free;
  Stack.Free;
  inherited;
end;

procedure TBChartCircular<TX, TY>.BuildView;
var
  i, j: int32;
  gr: TDataContainerPairXY.PGroupValues;
  leg: array of TLegend;
begin
  // half the Rect - a center circel
  Center := vec2(Rect.Size.Width, Rect.Size.Height) * 0.5;
  if (FChart <> nil) and (FLegends.Count > 0) and FSortOnGrowY then
  begin
    FChart.SortByYInv;
    leg := nil;
    SetLength(leg, FLegends.Count);
    move(FLegends.Data^[0], leg[0], FLegends.Count*sizeof(TLegend));
    for i := 0 to FLegends.Count - 1 do
    begin
      gr := leg[i].LinkedGroup;
      if gr = nil then
        continue;
      for j := 0 to FChart.FListValues.Count - 1 do
        if FChart.FListValues.Items[j] = gr then
        begin
          FLegends.Items[j] := leg[i];
          break;
        end;
    end;
  end;
  inherited;
end;

procedure TBChartCircular<TX, TY>.DrawChart(Chart: TDataContainer<TX, TY>);
var
  current_angle: BSFloat;
  pos: TVec2f;
  v: TVec3f;
  A, O, B, Delta: TVec2f;
  i, j: int32;
  group: TDataContainerPairXY.PGroupValues;
  attrib, atrib_calc: TArcAttrib;
  all_arcs: TListVec<TArcAttrib>;
  small_left: TListVec<TArcAttrib>;
  small_right: TListVec<TArcAttrib>;
begin
  if (Chart.FListValues.Count = 0) or (OpY.Comparator(Chart.IntegralY, DefaultY) = 0) or (FRadius <= 0) then
    exit;
  current_angle := 0;
  // circle length even count value groups ?
  if Chart.FListValues.Count > 2 * BS_PI * FRadius then
    raise Exception.Create('Too many value groups!!!');
  { in begin calc attributes all arcs }
  all_arcs := TListVec<TArcAttrib>.Create;
  all_arcs.Count := Chart.FListValues.Count;
  small_left := TListVec<TArcAttrib>.Create;
  small_right := TListVec<TArcAttrib>.Create;
  j := 0;
  for i := 0 to Chart.FListValues.Count - 1 do
  begin
    atrib_calc.Group := Chart.FListValues.Items[i];
    atrib_calc.Group^.Percent := OpY.DivideFloat(atrib_calc.Group.ValuesSum, Chart.IntegralY);
    atrib_calc.Group.AngleStart := current_angle;
    CalcArcAttrib(atrib_calc);
    all_arcs.Items[i] := atrib_calc;
    if atrib_calc.Len <= FCanvas.Font.SizeInPixels * 4 then
    begin
      inc(Quad_spread_smal_arc[atrib_calc.NumQuad]);
      if atrib_calc.NumQuad in [2, 3] then
        small_left.Add(atrib_calc)
      else
      begin
        if atrib_calc.NumQuad = 4 then
        begin
          small_right.Insert(atrib_calc, j);
          inc(j);
        end else
          small_right.Add(atrib_calc);
      end;
    end;
    current_angle := current_angle + atrib_calc.Angle;
  end;

  i := 0;
  Height_hint_text := FCanvas.Font.SizeInPixels + 3*ToHiDpiScale;
  current_angle := 0;
  if (Quad_spread_smal_arc[1] > 0) or (Quad_spread_smal_arc[4] > 0) then
    LegendsOffset := FRadius*0.5
  else //BASE_FOR_HINT + round(Font.AverageWidth * 5.0) else
    LegendsOffset := BASE_FOR_HINT*ToHiDpiScale;
  while i < Chart.FListValues.Count do
  begin
    attrib := all_arcs.Items[i];
    inc(i);
    group := attrib.Group;
    // calc portion segment
    if (group^.GraphIntegral = nil) then
    begin
      group.GraphIntegral := TArc.Create(FCanvas, Grid);
      group.GraphIntegral.Data.TagPtr := group;
      TArc(Group.GraphIntegral).Fill := true;
      group.GraphIntegral.Data.DragResolve := false;
      group.GraphIntegral.Color := group.Color;
      group.GraphIntegral.Layer2d := LAYER_CHART;

      GroupMouseEnter.CreateObserver(group.GraphIntegral.Data.EventMouseEnter);
      GroupMouseMove.CreateObserver(group.GraphIntegral.Data.EventMouseMove);
      GroupMouseLeave.CreateObserver(group.GraphIntegral.Data.EventMouseLeave);

      group.Text := TCanvasText.Create(FCanvas, group.GraphIntegral);
      group.Text.Layer2d := LAYER_CHART + 1;
    end;
    group.Text.Text := Format('%f', [group^.Percent*100]);
    TArc(group^.GraphIntegral).StartAngle := group.AngleStart;
    TArc(group^.GraphIntegral).Radius := FRadius;
    TArc(group^.GraphIntegral).Angle := attrib.Angle;
    group^.GraphIntegral.Build;
    // half shape - his center
    O := vec2(Rect.Data.Mesh.FBoundingBox.x_max, Rect.Data.Mesh.FBoundingBox.y_max);
    // first point - center (becàuse gl_triangle_fan)
    v := group.GraphIntegral.Data.Mesh.ReadPoint(0);
    // calc position arc relative left-up corner Rect
    // point center circle describing arc
    A := vec2(v.x + O.x, O.y - v.y);
    // position bounding box in Rect (left-up angle)
    B := vec2(O.x - group.GraphIntegral.Data.Mesh.FBoundingBox.x_max, O.y - group.GraphIntegral.Data.Mesh.FBoundingBox.y_max);
    Delta := O - A;
    pos := B + Delta;
    // push segment radial
    pos.x := pos.x + PUSH_SEGMENT_DISTANCE * ToHiDpiScale * attrib.C;
    pos.y := pos.y - PUSH_SEGMENT_DISTANCE * ToHiDpiScale * attrib.S;
    group.GraphIntegral.Position2d := pos;
    group.ForcePosition := pos;
    // calc text position
    // the center arc relative left-top corner BB
    O.x := group.GraphIntegral.Data.Mesh.FBoundingBox.x_max + v.x;
    O.y := group.GraphIntegral.Data.Mesh.FBoundingBox.y_max - v.y;
    // position text relative O
    if (attrib.Len > FCanvas.Font.SizeInPixels * 4) then
    begin
      // draw text inside arc
      group.Text.Color := BS_CL_WHITE; //not group.GraphIntegral.Color;// ;
      pos.x := (FRadius*0.75) * attrib.C;
      pos.y := (FRadius*0.75) * attrib.S;
      // position text relative left-top corner BB
      pos.x := O.x + pos.x - group.Text.Data.Mesh.FBoundingBox.x_max;
      pos.y := O.y - pos.y - group.Text.Data.Mesh.FBoundingBox.y_max;
      //pos := FCanvas.Renderer.SceneSizeToScreen(pos);
      group.Text.Data.Interactive := false;
        FreeAndNil(group^.Hint);
      group.Text.Position2d := pos;
    end;
    //break;
  end;
  UnitedHintRect := RectBS(0, - FRadius*1.5 - (4.0*ToHiDpiScale), 0.0, (4.0*ToHiDpiScale + Height_hint_text));
  for i := 0 to small_left.Count - 1 do
    DrawHint(small_left.Items[i]);
  UnitedHintRect := RectBS(0, Center.y + FRadius*1.5, 0.0, (4.0*ToHiDpiScale + Height_hint_text));
  for i := 0 to small_right.Count - 1 do
    DrawHint(small_right.Items[i]);
  all_arcs.Free;
  small_left.Free;
  small_right.Free;
end;

procedure TBChartCircular<TX, TY>.DrawHint(const Arc: TArcAttrib);
var
  v: TVec3f;
  leg_first: TVec2f;
  leg_second: TVec2f;
  pos_connect_to_circ: TVec2f;
  pos_conn_fr_hint: TVec2f;
  new_rect: TRectBSf;
  group: TDataContainerPairXY.PGroupValues;
begin
  group := Arc.Group;
  group.Text.Color := group.GraphIntegral.Color;
  group.Text.Data.Interactive := false;
  { position relative zero (circle) in space a circle }
  leg_first.x := FRadius *  Arc.C;
  leg_first.y := FRadius * -Arc.S;
  leg_second := SelectSecondPointForLegHint(Arc, leg_first, new_rect);
  UnitedHintRect := RectUnion(UnitedHintRect, new_rect);
  // create hint shape
  if group.Hint = nil then
  begin
    group.Hint := TPath.Create(FCanvas, group.GraphIntegral);
    TPath(group.Hint).InterpolateSpline := TInterpolateSpline.isNone;
    TPath(group.Hint).WidthLine := 1*ToHiDpiScale;
    group.Hint.Color := group.GraphIntegral.Color;
    group.Hint.Data.Interactive := false;
  end else
    TPath(group.Hint).Clear;
  // shift path to zero
  TPath(group.Hint).AddPoint(vec2(0.0, 0.0));
  TPath(group.Hint).AddPoint(leg_second);
  TPath(group.Hint).AddPoint(vec2(leg_second.x + group.Text.Width * 1.2 * Arc.SignCos, leg_second.y));
  group.Hint.Build;
  { connect 2d point the pie with the hint in common circle space (!not pie) }
  if leg_first.x > 0 then
    pos_connect_to_circ.x := leg_first.x
  else
    pos_connect_to_circ.x := group.GraphIntegral.Width + leg_first.x;

  if leg_first.y > 0 then
    pos_connect_to_circ.y := leg_first.y
  else
    pos_connect_to_circ.y := group.GraphIntegral.Height + leg_first.y;

  { read first point in local the shape coordinates; the point is beginning leg hint }
  v := group.Hint.Data.Mesh.ReadPoint(0);

  pos_conn_fr_hint := vec2(group.Hint.Data.Mesh.FBoundingBox.x_max + v.x, group.Hint.Data.Mesh.FBoundingBox.y_max - v.y);
  group.GraphIntegral.ConnectChild(pos_connect_to_circ, pos_conn_fr_hint, group.Hint);

  if TPath(group.Hint).WidthLine > 1.0 then
    v := group.Hint.Data.Mesh.ReadPoint(2)
  else
    v := group.Hint.Data.Mesh.ReadPoint(1);

  v.x := group.Hint.Data.Mesh.FBoundingBox.x_max + v.x;
  v.y := group.Hint.Data.Mesh.FBoundingBox.y_max - v.y;

  if Arc.SignCos < 0 then
    leg_second := group.Hint.Position2d + vec2(v.x, v.y) + vec2(1.0*ToHiDpiScale - group.Text.Width, - 3.0*ToHiDpiScale - Height_hint_text)
  else
    leg_second := group.Hint.Position2d + vec2(v.x, v.y) + vec2(5.0*ToHiDpiScale * Arc.SignCos, - 3.0*ToHiDpiScale - Height_hint_text);

  Group.Text.Position2d := leg_second;
end;

procedure TBChartCircular<TX, TY>.OnMouseEnter(const Data: BMouseData);
var
  Group: TDataContainerPairXY.PGroupValues;
  i: int32;
  legend: TCanvasText;
begin
  if AnimatingGroup <> nil then
    ReturnBeginParam(AnimatingGroup);
  Group := PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.TagPtr;
  //HintText.Parent := Group;
  legend := nil;
  for i := 0 to FLegends.Count - 1 do
  begin
    if FLegends.Items[i].LinkedGroup = Group then
    begin
      legend := FLegends.Items[i].Text;
      break;
    end;
  end;

  if Assigned(legend) then
  begin
    if Assigned(HintText) then
    begin
      HintText := TBlackSharkHint.Create(FCanvas.Renderer);
      HintText.MainBody.Layer2d := Group.GraphIntegral.Layer2dAbsolute + 3;
      HintText.MainBody.Data.Interactive := false;
      HintText.MainBody.Data.ModalLevel := MainBody.Data.ModalLevel;
      HintText.Text := legend.Text;
      HintText.Position2d := vec2(int32(Data.X), int32(Data.Y + 20));
      HintText.Visible := true;
    end;
  end;
  AniLawScale.StartValue := 0.0;
  AniLawScale.StopValue := 1.0;
  AnimatingGroup := Group;
  Group.AnimatePos := true;
  AniLawScale.CurrentSender := Group;
  AniLawScale.Run;
  AnimatingGroup := Group;
end;

procedure TBChartCircular<TX, TY>.OnMouseLeave(const Data: BMouseData);
var
  Group: TDataContainerPairXY.PGroupValues;
begin
  if HintText <> nil then
    HintText.Visible := false;
  Group := PRendererGraphicInstance(Data.BaseHeader.Instance).Instance.Owner.TagPtr;
  Group.AnimatePos := false;
  AniLawScale.Stop;
  ReturnBeginParam(Group);
  AnimatingGroup := nil;
end;

procedure TBChartCircular<TX, TY>.OnMouseMove(const Data: BMouseData);
begin
  if HintText <> nil then
    HintText.Position2d := vec2(int32(Data.X), int32(Data.Y + 20));
end;

procedure TBChartCircular<TX, TY>.OnUpdateValueScale(const Value: BSFloat);
var
  Group: TDataContainerPairXY.PGroupValues;
  new_scale: TVec3f;
  pos: TVec2f;
  s, c: BSFloat;
begin
  if not AniLawScale.IsRun or (AniLawScale.CurrentSender = nil) then    //
    exit;

  Group := AniLawScale.CurrentSender;
  if not Group.AnimatePos then
    begin
    ReturnBeginParam(Group);
    if Group <> AnimatingGroup then
      ReturnBeginParam(AnimatingGroup);
    exit;
    end;

  if (Value = 0) then
    exit;

  new_scale := vec3(Value, Value, 1.0);
  BS_SinCos(Group.AngleStart + Group^.Percent * 360 /2, s, c);
  pos.x := new_scale.x * c * 20;
  pos.y := new_scale.y * s * 20;
  pos.x := Group.ForcePosition.x + pos.x;
  pos.y := Group.ForcePosition.y - pos.y;
  Group^.GraphIntegral.Position2d := pos;
end;

procedure TBChartCircular<TX, TY>.ReturnBeginParam(Group: TDataContainerPairXY.PGroupValues);
begin
  if Group = nil then
    exit;
  //Group.GraphArg.Data.ScaleSimple := 1.0;
  Group.GraphIntegral.Position2d := Group.ForcePosition;
end;

procedure TBChartCircular<TX, TY>.Resize(AWidth, AHeight: BSFloat);
begin
  AdjustRadius(AWidth, AHeight);
  inherited;
end;

function TBChartCircular<TX, TY>.SelectSecondPointForLegHint(const Arc: TArcAttrib; const LegFirst: TVec2f; out Rect: TRectBSf): TVec2f;
var
  off: BSFloat;
  overlap: TRectBSf;
begin
  { calculates a middle point a leg for hint relatively conditional a zero
    point is pos_hint }
  Result.x := FRadius *  Arc.C * 0.5;
  Result.y := FRadius * -Arc.S * 0.5;
  Rect.Size := vec2(Arc.Group.Text.Width * 1.2, 5.0*ToHiDpiScale + Height_hint_text);
  { ascertain, intersects whether vertical line offseted at LegendsOffset right/left from Rect }
  off := abs(LegFirst.x) + abs(Result.x) + Rect.Size.x + (PUSH_SEGMENT_DISTANCE + 5)*ToHiDpiScale;
  if (off > LegendsOffset + Center.x) then
    Result.x := Arc.SignCos*(abs(Result.x) - (off - (LegendsOffset + Center.x)));

  if LegFirst.x < 0 then
    Rect.Position := LegFirst + Result - Rect.Size
  else
    Rect.Position := LegFirst + vec2(Result.x, Result.y - Rect.Size.y);

  overlap := RectOverlap(Rect, UnitedHintRect);
  if (overlap.Height > 0) and (overlap.Width > 0) then
    begin
    if (Arc.NumQuad = 3) then
      Result.y := (abs(UnitedHintRect.y + UnitedHintRect.Height + 6.0*ToHiDpiScale + Height_hint_text) - abs(LegFirst.y)) else
    if (Arc.NumQuad = 1) then
      Result.y := (UnitedHintRect.y - LegFirst.y - 3*ToHiDpiScale)
    else
      begin
      if Arc.NumQuad in [2, 3] then
        begin
        Result.x := (UnitedHintRect.x - LegFirst.x);
        end else
        begin
        Result.x := (UnitedHintRect.x + UnitedHintRect.Size.x - LegFirst.x);
        end;
      off := abs(LegFirst.x) + abs(Result.x) + Rect.Size.x + (PUSH_SEGMENT_DISTANCE + 5)*ToHiDpiScale;
      if (off > LegendsOffset + Center.x) then
        begin
        Result.x := Arc.SignCos*(abs(Result.x) - (off - (LegendsOffset + Center.x)));
        Result.y := (UnitedHintRect.y - LegFirst.y - 3*ToHiDpiScale)
        end;
      end;
    if LegFirst.x < 0 then
      Rect.Position := LegFirst + Result - Rect.Size
    else
      Rect.Position := LegFirst + vec2(Result.x, Result.y - Rect.Size.y);
    end;
end;

procedure TBChartCircular<TX, TY>.SetIntegralY(const IntegralY: TY);
begin
  CurrentIntegral := IntegralY;
end;

procedure TBChartCircular<TX, TY>.SetRadius(const Value: int32);
begin
  FRadius := Value;
  BuildView;
end;

{$endregion}

{$region 'TBChartCurvesQuantityInt'}

{ TBChartCurvesQuantityInt }

constructor TBChartCurvesQuantityInt.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsInt.GetOperators(OpX);
  TOperatorsInt.GetOperators(OpY);
end;

{$endregion}


function SelectGranularInt(ArgBoundary: int32; GraphicBoundary: int32): int32;
var
  cou: int32;
begin
  cou := GraphicBoundary div 20;

  if ArgBoundary < 5 then
    Result := 1
  else
  if ArgBoundary < 26 then
    Result := 5
  else
  if ArgBoundary < 99 then
    Result := 10
  else
  if ArgBoundary < 199 then
    Result := 25
  else
  if ArgBoundary < 499 then
    Result := 50
  else
  if ArgBoundary < 999 then
    Result := 100
  else
    Result := ArgBoundary div 10;

  while (Result > 10) and (GraphicBoundary div Result > cou) do
    dec(Result, 10);
end;

function SelectGranularFloat(ArgBoundary: BSFloat; GraphicBoundary: int32): BSFloat;
var
  cou: int32;
begin
  cou := GraphicBoundary div 20;
  if ArgBoundary < 1.0 then
    begin
    Result := ArgBoundary / 5.0;
    end else
  if ArgBoundary < 10.0 then
    Result := 1.0 else
  if ArgBoundary < 26.0 then
    Result := 5.0 else
  if ArgBoundary < 99.0 then
    Result := 10.0 else
  if ArgBoundary < 199.0 then
    Result := 25.0 else
  if ArgBoundary < 499.0 then
    Result := 50.0 else
  if ArgBoundary < 999.0 then
    Result := 100.0 else
    begin
    Result := ArgBoundary / 10.0;
    end;
  while (Result > 10.0) and (GraphicBoundary / Result > cou) do
    Result := Result - 10.0;
end;

function SelectGranularDate(ArgBoundary: TDate; GraphicBoundary: int32): TDate;
const
  DEFAULT_DT: TDate = 0.0;
var
  days, years: int32;
  //d, m, y: word;
  def_d, def_m, def_y: word;
  //dif_d, dif_m, dif_y: word;
begin
  DecodeDate(DEFAULT_DT, def_y, def_m, def_d);
  years := YearsBetween(ArgBoundary, DEFAULT_DT);
  if years = 0 then
    begin
    days := DaysBetween(ArgBoundary, DEFAULT_DT);
    if days < 10 then
      Result := EncodeDate(def_y, def_m, def_d+1) else
    if days < 29 then
      begin
      Result := IncDay(DEFAULT_DT, 5);
      end else
      Result := EncodeDate(def_y, 1, def_d);
    end else
  if years < 11 then
    Result := EncodeDate(def_y + 1, def_m, def_d) else
  if years < 101 then
    Result := EncodeDate(def_y + 10, def_m, def_d) else
  if years < 251 then
    Result := EncodeDate(def_y + 50, def_m, def_d) else
  if years < 1001 then
    Result := EncodeDate(def_y + 100, def_m, def_d) else
    Result := EncodeDate(years div 10, def_m, def_d);
  //DecodeDate(ArgBoundary, y, m, d);
  {dif_d := d - def_d;
  dif_m := m - def_m;
  dif_y := y - def_y;
  if dif_y = 0 then
    begin
    if dif_m = 0 then
      begin
      if dif_d < 10 then
        Result := EncodeDate(0, 0, 1) else
        Result := EncodeDate(0, 0, 5);
      end else
      Result := EncodeDate(0, 1, 0);
    end else
  if dif_y < 11 then
    Result := EncodeDate(1, 0, 0) else
  if dif_y < 29 then
    Result := EncodeDate(5, 0, 0) else
  if dif_y < 49 then
    Result := EncodeDate(10, 0, 0) else
  if dif_y < 99 then
    Result := EncodeDate(25, 0, 0) else
    Result := EncodeDate(dif_y div 10, 0, 0); }
end;

{$region 'TBChartCircularInt'}

function TBChartCurvesQuantityInt.GetGranularX: int32;
begin
  Result := SelectGranularInt(WidthX, FAxisXSize);
end;

function TBChartCurvesQuantityInt.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

{ TBChartCircularInt }

constructor TBChartCircularInt.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsInt.GetOperators(OpX);
  TOperatorsInt.GetOperators(OpY);
end;

{$endregion}

{ TBChartCurvesBloat }

constructor TBChartCurvesFloat.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsFloat.GetOperators(OpX);
  TOperatorsFloat.GetOperators(OpY);
end;

function TBChartCurvesFloat.GetGranularX: BSFloat;
begin
  Result := SelectGranularFloat(HeightY, FAxisYSize);
end;

function TBChartCurvesFloat.GetGranularY: BSFloat;
begin
  Result := SelectGranularFloat(HeightY, FAxisYSize);
end;

function TBChartCircularInt.GetGranularX: int32;
begin
  Result := SelectGranularInt(WidthX, FAxisXSize);
end;

function TBChartCircularInt.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

{ TBChartBarInt }

constructor TBChartBarInt.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsInt.GetOperators(OpX);
  TOperatorsInt.GetOperators(OpY);
end;

{ TBChartBarDataInt }

procedure TBChartBarDateInt.AddDate(Chart: TDataContainer<TDate, int32>;
  const Date: TDate; Y: int32);
var
  year, m, d: word;
  dt: TDate;
begin
  { trim hours, minutes, seconds }
  DecodeDate(Date, year, m, d);
  dt := EncodeDate(year, m, d);
  Chart.AddPair(dt, Y);
end;

procedure TBChartBarDateInt.AddDate(Chart: TDataContainer<TDate, int32>; Day, Month, Year, Y: int32);
var
  dt: TDate;
begin
  dt := EncodeDate(Year, Month, Day);
  Chart.AddPair(dt, Y);
end;

procedure TBChartBarDateInt.AddDate(Chart: TDataContainer<TDate, int32>;
  const Date: string; Y: int32);
begin
  Chart.AddPair(StrToDate(Date, DateFormat), Y);
end;

constructor TBChartBarDateInt.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsDate.GetOperators(OpX);
  TOperatorsInt.GetOperators(OpY);
  DateFormat := FormatSettings;
  DateFormat.DateSeparator := '.';
  DateFormat.ShortDateFormat := 'dd.MM.yyyy';
end;

function TBChartBarDateInt.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

{ TBChartCircularFloatStr }

procedure TBChartCircularStr.AddPair(const ValueX: string; Count: int32);
var
  gr: TDataContainer.PGroupValues;
begin
  if not TreeGroups.Find(ValueX, gr) then
  begin
    gr := FChart.AddPair(FactoryID, Count, ColorEnum.CurrentColor);
    inc(FactoryID);
    TreeGroups.Add(ValueX, gr);
    AddLegend(ValueX, ColorEnum.CurrentColor);
    ColorEnum.GetNextColor;
  end else
    FChart.AddPair(gr.ValueX, Count);
end;

procedure TBChartCircularStr.AddPair(const ValueX: string; PartTY: BSFloat);
var
  pie: TDataContainerPairXY.PGroupValues;
  n: TTreeStringGroups.PBinTreeItem;
begin
  n := TreeGroups.FindNode(ValueX);
  if Assigned(n) then
  begin
    if n.Key <> ValueX then
      raise EComponentAlreadyExists.CreateFmt('Value %s already exists!', [ValueX])
    else
      raise EComponentAlreadyExists.CreateFmt('Similar key %s on Value %s already exists!', [n.Key, ValueX]);
  end;
  pie := AddPart(FactoryID, PartTY, ColorEnum.CurrentColor);
  TreeGroups.Add(ValueX, pie);
  inc(FactoryID);
  AddLegend(ValueX, ColorEnum.CurrentColor, nil, pie);
  ColorEnum.GetNextColor;
end;

constructor TBChartCircularStr.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsInt.GetOperators(OpX);
  TOperatorsFloat.GetOperators(OpY);
  TreeGroups := TTreeStringGroups.Create(StrCmp);
  ColorEnum := TColorEnumerator.Create([]);
  SetIntegralY(100.0);
end;

procedure TBChartCircularStr.DeleteChart(Chart: TDataContainer);
begin
  TreeGroups.Clear;
  inherited;
end;

destructor TBChartCircularStr.Destroy;
begin
  TreeGroups.Free;
  ColorEnum.Free;
  inherited;
end;

function TBChartBarInt.GetGranularX: int32;
begin
  Result := SelectGranularInt(WidthX, FAxisXSize);
end;

function TBChartBarInt.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

{ TCurvesQuantityInDate }

class function TCurvesQuantityInDate.Add(const Value1, Value2: TDate): TDate;
var
  days: uint32;
begin
  days := DaysBetween(Value2, (0.0));
  Result := IncDay(Value1, days);
  //Result := Value1 + Value2;
end;

class function TCurvesQuantityInDate.Comparator(const Value1, Value2: TDate): int8;
begin
  Result := CompareDateTime(Value1, Value2);
end;

class function TCurvesQuantityInDate.Divide(const Value1,
  Value2: TDate): TDate;
begin
  Result := Value1 / Value2;
end;

class function TCurvesQuantityInDate.DivideInt(const Value1: TDate;
  const Value2: int32): TDate;
begin
  Result := Value1 / Value2;
end;

class function TCurvesQuantityInDate.Divide_float(const Value1,
  Value2: TDate): BSFloat;
begin
  Result := Value1 / Value2;
end;

function TCurvesQuantityInDate.GetGranularX: TDate;
begin
  Result := SelectGranularDate(WidthX, FAxisXSize);
end;

function TCurvesQuantityInDate.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

class function TCurvesQuantityInDate.High: TDate;
begin
  Result := MaxDateTime;
end;

class function TCurvesQuantityInDate.Low: TDate;
begin
  Result := MinDateTime;
end;

class function TCurvesQuantityInDate.Multiply(const Value1,
  Value2: TDate): TDate;
begin
  Result := Value1 * Value2;
end;

class function TCurvesQuantityInDate.MultiplyFloat(const Value1: TDate;
  const Value2: BSFloat): TDate;
var
  //y, m, d: uint16;
  days: uint32;
begin
  //DecodeDate(Value2, y, m, d);
  days := DaysBetween(Value1, (0.0));
  Result := IncDay((0.0), round(days * Value2));
  //Result := Value1 * Value2;
end;

class function TCurvesQuantityInDate.MultiplyInt(const Value1: TDate;
  const Value2: int32): TDate;
begin
  Result := Value1 * Value2;
end;

class function TCurvesQuantityInDate.Subtract(const Value1,
  Value2: TDate): TDate;
//var
//  days: uint32;
begin
  //days := DaysBetween(Value1, Value2);
  //Result := IncDay(0.0, days);
  Result := Value1 - Value2;
end;

class function TCurvesQuantityInDate.ToStringDate(const Value: TDate): string;
begin
  Result := DateToStr(Value, DateFormat);
end;

procedure TCurvesQuantityInDate.AddDate(Chart: TDataContainer<TDate, int32>;
  const Date: TDate; Y: int32);
var
  year, m, d: word;
  dt: TDate;
begin
  { trim hours, minutes, seconds }
  DecodeDate(Date, year, m, d);
  dt := EncodeDate(year, m, d);
  Chart.AddPair(dt, Y);
end;

constructor TCurvesQuantityInDate.Create(ACanvas: TBCanvas);
begin
  inherited;
  OpX.Add := Add;
  OpX.Comparator := Comparator;
  OpX.Subtract := Subtract;
  OpX.Multiply := Multiply;
  OpX.MultiplyInt := MultiplyInt;
  OpX.MultiplyFloat := MultiplyFloat;
  OpX.Divide := Divide;
  OpX.DivideInt := DivideInt;
  OpX.DivideFloat := Divide_float;
  OpX.High := High;
  OpX.Low := Low;
  OpX.ToString := ToStringDate;
  TOperatorsInt.GetOperators(OpY);
  {$ifdef FPC}
  DateFormat := DefaultFormatSettings;
  {$else}
  DateFormat := FormatSettings;
  {$endif}
  DateFormat.ShortDateFormat := 'dd.MM.yy';
  FShowZeroPoint := false;
end;

{ TBChartCurvesInt }

constructor TBChartCurvesInt.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsInt.GetOperators(OpX);
  TOperatorsInt.GetOperators(OpY);
end;

function TBChartCurvesInt.GetGranularX: int32;
begin
  Result := SelectGranularInt(WidthX, FAxisXSize);
end;

function TBChartCurvesInt.GetGranularY: int32;
begin
  Result := SelectGranularInt(HeightY, FAxisYSize);
end;

{ TCurvesQuantityFloatInDate }

class function TCurvesQuantityFloatInDate.ToStringDate(
  const Value: TDate): string;
begin
  Result := DateToStr(Value, DateFormat);
end;

procedure TCurvesQuantityFloatInDate.AddDate(
  Chart: TDataContainer<TDate, BSFloat>; const Date: TDate; Y: BSFloat);
var
  year, m, d: word;
  dt: TDate;
begin
  { trim hours, minutes, seconds }
  DecodeDate(Date, year, m, d);
  dt := EncodeDate(year, m, d);
  Chart.AddPair(dt, Y);
end;

constructor TCurvesQuantityFloatInDate.Create(ACanvas: TBCanvas);
begin
  inherited;
  OpX.Add := TCurvesQuantityInDate.Add;
  OpX.Comparator := TCurvesQuantityInDate.Comparator;
  OpX.Subtract := TCurvesQuantityInDate.Subtract;
  OpX.Multiply := TCurvesQuantityInDate.Multiply;
  OpX.MultiplyInt := TCurvesQuantityInDate.MultiplyInt;
  OpX.MultiplyFloat := TCurvesQuantityInDate.MultiplyFloat;
  OpX.Divide := TCurvesQuantityInDate.Divide;
  OpX.DivideInt := TCurvesQuantityInDate.DivideInt;
  OpX.DivideFloat := TCurvesQuantityInDate.Divide_float;
  OpX.High := TCurvesQuantityInDate.High;
  OpX.Low := TCurvesQuantityInDate.Low;
  OpX.ToString := ToStringDate;
  TOperatorsFloat.GetOperators(OpY);
  {$ifdef FPC}
  DateFormat := DefaultFormatSettings;
  {$else}
  DateFormat := FormatSettings;
  {$endif}
  DateFormat.ShortDateFormat := 'dd.MM.yy';
  FShowZeroPoint := false;
end;

function TCurvesQuantityFloatInDate.GetGranularX: TDate;
begin
  Result := SelectGranularDate(WidthX, FAxisXSize);
end;

function TCurvesQuantityFloatInDate.GetGranularY: BSFloat;
begin
  Result := SelectGranularFloat(HeightY, FAxisYSize);
end;

{ TBChartBarDateFloat }

procedure TBChartBarDateFloat.AddDate(
  Chart: TDataContainer<TDate, BSFloat>; const Date: TDate; Y: BSFloat);
var
  year, m, d: word;
  dt: TDate;
begin
  { trim hours, minutes, seconds }
  DecodeDate(Date, year, m, d);
  dt := EncodeDate(year, m, d);
  Chart.AddPair(dt, Y);
end;

constructor TBChartBarDateFloat.Create(ACanvas: TBCanvas);
begin
  inherited;
  TOperatorsDate.GetOperators(OpX);
  TOperatorsFloat.GetOperators(OpY);
end;

{function TBChartBarDateFloat.GetGranularX: TDate;
begin
  Result := SelectGranularDate(WidthX, FAxisXSize);
end;}

function TBChartBarDateFloat.GetGranularY: BSFloat;
begin
  Result := SelectGranularFloat(HeightY, FAxisYSize);
end;

end.



