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


{
  The unit contains an implementation an unusual grid; see possibilities in
  TBSTestGrid
}

{$ifdef fpc}
  {$WARN 5024 off : Parameter "$1" not used}
{$endif}

{$I BlackSharkCfg.inc}

unit bs.gui.grid;

{$M+}

interface

uses
    SysUtils
  , bs.basetypes
  , bs.align
  , bs.events
  , bs.scene
  , bs.thread
  , bs.collections
  , bs.gui.base
  , bs.gui.forms
  , bs.gui.themes
  , bs.canvas
  , bs.texture
  , bs.font
  , bs.instancing
  , bs.geometry
  ;

type

  TPosition2d = TVec2d;

  TBGrid = class;


  { TIntervalReader

    reader of bits with step IntervalSize }

  TIntervalReader = class
  private
    FIntervalSize: int32;
    Position: int32;
    Data: pByte;
    SizeData: int32;
    SizeDataBits: int32;
    FIntervalSizeInBytes: int32;
    FOffsetBegin: int8;
    FResultRead: array of byte;
    SizeArr: int32;
    FSizeReaded: int32;
    FSizeReadedBytes: int32;
    procedure SetIntervalSize(const Value: int32);
    function GetIntervalSizeInBytes: int32;
  public
    ResultRead: pByte;
  public
    constructor Create;
    { <summary>setter data for read with intervals</summary>
        <param name="pData"> is an input buffer for read</param>
        <param name="LenData"> is length buffer, bits</param>
        <param name="ABeginOffset" is offset from begin for read </param> }
    procedure SetData(pData: pByte; LenData: int32; ABeginOffset: int8);
    { <summary>reads one interval; result is placed into ResultRead</summary> }
    function ReadNext: boolean;
    { <summary>size of interval, bits</summary> }
    property IntervalSize: int32 read FIntervalSize write SetIntervalSize;
    { <summary>offset from begin of data, bits, must be in range 0..6</summary> }
    property OffsetBegin: int8 read FOffsetBegin write FOffsetBegin;
    { <summary>iterval size, bytes<summary/> }
    property IntervalSizeInBytes: int32 read GetIntervalSizeInBytes;
    { <summary>data readed size, bits<summary/> }
    property SizeReaded: int32 read FSizeReaded;
    { <summary>data readed size, bytes<summary/> }
    property SizeReadedBytes: int32 read FSizeReadedBytes;
  end;

  TCommonGUIProperties = class(TGUIProperties)
  private
    function GetColorUnit: TGuiColor;
    procedure SetColorUnit(const Value: TGuiColor);
  protected
    procedure SetColor(const Value: TColor4f); virtual; abstract;
    function GetColor: TColor4f; virtual; abstract;
  public
    { character color }
    property Color: TColor4f read GetColor write SetColor;
  published
    property ColorUnit: TGuiColor read GetColorUnit write SetColorUnit;
  end;

  TGridDataPresentationClass = class of TGridDataPresentation;

  { TGridDataPresentation

    Translator input data to a visual presentation

   }

  TGridDataPresentation = class abstract(TCommonGUIProperties)
  private
    const
      MAX_SPEED = 5;
      MAX_HEALTH = 5;
    type
      TEasterEgg = class
      type
        PPart = ^TPart;
        TPart = record
          Health: int32;
          Velosity: BSFloat;
          Direction: TVec2f;
        end;
        PBomb = ^TBomb;
        TBomb = record
          BurstBombTime: TTimeCounter;
          Area: TBox3d;
          PosBomb: TVec2f;
          Power: int32;
          MaxTimeLive: int32;
        end;
      private
        EmptyTask: IBEmptyTask;
        EmptyTaskObsrv: IBEmptyTaskObserver;
        Particles: TListVec<PPart>;
        LastTime: TTimeCounter;
        FDataSrc: TGridDataPresentation;
        //Selector: TBlackSharkRTree;
        //Bombs: TListVec<PBomb>;
        PositionParticles: TVec2f;
        procedure OnUpdateValue(const Value: byte);
        function AddPart(Velos: BSFloat; const Dir: TVec2f): PPart;
        //procedure ProcessBomb;
      public
        constructor Create(ADataSrc: TGridDataPresentation);
        destructor Destroy; override;
        //procedure DropBomb(Power: int32; const Pos: TVec2f);
        procedure Run;
        procedure Stop;
        procedure Update;
      end;

  private
    FColorBackground: TColor4f;
    EasterEgg: TEasterEgg;
    procedure SetColorBackground(const Value: TGuiColor);
    function GetColorBackground: TGuiColor;
  protected
    Instances: TParticlesMultiUV;
    FCountInstanses: int32;
    { canvas-wrapper arround Instances (TBlackSharkParticles) }
    CanvasObjectMap: TRectangle;
    FGrid: TBGrid;
  protected
    FIntervalReader: TIntervalReader;
    { a descendant must defines these variables;
      !!! MANDATORY for init. every descendant !!! }
    FCharacters: int8;              // count characters into interval
    FWidthCharacter: int32;         // width character, pixels
    FHeightRow: int32;              // height row, pixels
    FWidthCol: int32;               // width interval, pixels
    FWidthColOnlyData: int32;       // width without gap b/w intervals, pixels
    { true if an every character is multiple of FIntervalReader.IntervalSize }
    FCharacterMultiplyOfBit: boolean;
    FBitsInCharacter: int32;        // actual only if FCharacterMultiplyOfBit = true
    ///////////////////////////////////////////////////////////////////////////

    FRect: TRectBSd;
    procedure BeginPresent; virtual;
    { It presetns a data from the Grid.IntervalReader - draws one row
        - Position is drawing number of row and column row (line) relative
        Viewport, that is first row has number 0;
        return width a drawed area }
    function Present(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; virtual;
    procedure EndPresent; virtual;
    procedure Clear; virtual;
    function CreateParticlesContainer: TParticlesMultiUV; virtual; abstract;
    function GetSize: int32; virtual; abstract;
    procedure SetSize(const Value: int32); virtual; abstract;
    function GetOwner: TGUIProperties; override;
    function GetColorBackgrnd: TColor4f; virtual;
    procedure SetColorBackgrnd(const Value: TColor4f); virtual;
  public
    constructor Create(AGrid: TBGrid); virtual;
    destructor Destroy; override;
    procedure Hide; virtual;
    procedure Show; virtual;
    procedure EasterEggRun;
    procedure IncSize; virtual; abstract;
    procedure DecSize; virtual; abstract;
    procedure SetMaxSize; virtual; abstract;
    procedure SetMinSize; virtual; abstract;
    procedure SetDefaultSize; virtual; abstract;
    class function GetMinSize: int32; virtual; abstract;
    class function GetDefaultSize: int32; virtual; abstract;
    class function NamePresentation: string; virtual; abstract;
    function EasterEggRunning: boolean;
    procedure EasterEggStop;
    { init individual paramerers of cell for every presentation (descendant) }
    procedure SetDefaultSizeCell; virtual;
    { owner this presentation }
    property Grid: TBGrid read FGrid;
    { count symbols placed into interval }
    property Characters: int8 read FCharacters;
    { one character width }
    property WidthCharacter: int32 read FWidthCharacter;
    { column width, pixels }
    property WidthCol: int32 read FWidthCol;
    { interval width without gap, pixels }
    property WidthColOnlyData: int32 read FWidthColOnlyData;
    { row height, pixels }
    property HeightRow: int32 read FHeightRow;
    property Rect: TRectBSd read FRect;
    { count of characters have been shown }
    property CountInstanses: int32 read FCountInstanses;
    { defines multiple of whether interval (column) size (count bits) number of
      bits used for every Character; for example, the property is true for
      hex-notation if interval multiple of 4, it allows to select data with
      tetrades, otherwise whole interval only }
    property CharacterMultiplyOfBit: boolean read FCharacterMultiplyOfBit;
    { count bits in character actual only if FCharacterMultiplyOfBit = true }
    property BitsInCharacter: int32 read FBitsInCharacter;
    property ColorBackgrnd: TColor4f read GetColorBackgrnd write SetColorBackgrnd;
  published
    property Size: int32 read GetSize write SetSize;
    property ColorBackground: TGuiColor read GetColorBackground write SetColorBackground;
  end;

  TGridTextDataPresentation = class(TGridDataPresentation)
  private
    ObsrvReplaceFont: IBEmptyEventObserver;
    ObsrvChangeFont: IBEmptyEventObserver;
    FSize: int32;
    procedure OnReplaceFont(const Value: BEmpty);
    procedure OnChangeFont(const Value: BEmpty);
    procedure SelectTexture;
  protected
    function CreateParticlesContainer: TParticlesMultiUV; override;
    procedure BeginPresent; override;
    procedure EndPresent; override;
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    function GetSize: int32; override;
    procedure SetSize(const Value: int32); override;
  public
    constructor Create(AGrid: TBGrid); override;
    procedure IncSize; override;
    procedure DecSize; override;
    procedure SetMaxSize; override;
    procedure SetMinSize; override;
    procedure SetDefaultSize; override;
    class function GetDefaultSize: int32; override;
    class function GetMinSize: int32; override;
  end;

  TGridHexDataPresentation = class;

  { TGridAnsiDataPresentation }

  TGridAnsiDataPresentation = class(TGridTextDataPresentation)
  private
    FPresentInvisibleSymbols: boolean;
    HexDataPresentation: TGridHexDataPresentation; // for out Invisible symbols
    procedure SetPresentInvisibleSymbols(const Value: boolean);
  protected
    function Present(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; override;
  public
    constructor Create(AGrid: TBGrid); override;
    destructor Destroy; override;
    procedure SetDefaultSizeCell; override;
    class function NamePresentation: string; override;
    property PresentInvisibleSymbols: boolean read FPresentInvisibleSymbols write SetPresentInvisibleSymbols;
  end;

  { TGridHexDataPresentation }

  TGridHexDataPresentation = class(TGridTextDataPresentation)
  private
    FTurnover: boolean;
  protected
    function Present(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; override;
  public
    constructor Create(AGrid: TBGrid); override;
    procedure SetDefaultSizeCell; override;
    class function NamePresentation: string; override;
    // flip bytes
    property Turnover: boolean read FTurnover write FTurnover;
  end;

  { TBitsDataPresentation }

  TBitsDataPresentation = class(TGridDataPresentation)
  public
    const
      // bit max size is imaged by circle, pixels, that is range 6x6-12x12
      MAX_SIZE_BIT = 12;
      // bit max size is imaged by square 5x5, that is range 1x1-5x5
      MAX_SIZE_BIT_IN_PIXELS = 5;
  private
    FSizeBit: int32;
    TexturesZero: array[0..MAX_SIZE_BIT] of TTextureRect;
    TexturesOne: array[0..MAX_SIZE_BIT] of TTextureRect;
    // for point bits
    BitMapUV: array[1..5, 0..255] of TTextureRect;
    BitmapTexture: IBlackSharkTexture;
    FColor0: TColor4f;
    FColor1: TColor4f;
    FColorBackMinBits: TColor4f;
    FDirPictures: string;
    procedure SetSizeBit(const Value: int32);
    procedure LoadTextures;
    function DoPresentByPoints(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; inline;
    function DoPresentByTextures(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; inline;
    procedure SetColor1(const Value: TColor4f);
    function GetColorOne: TGuiColor;
    procedure SetColorOne(const Value: TGuiColor);
    function GetColorBackMinBits: TGuiColor;
    procedure SetColorBackMinBits(const Value: TGuiColor);
    procedure CheckColorBackground;
    procedure SetDirPictures(const Value: string);
  protected
    function CreateParticlesContainer: TParticlesMultiUV; override;
    function Present(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat; override;
    procedure SetColor(const Value: TColor4f); override;
    function GetColor: TColor4f; override;
    function GetSize: int32; override;
    procedure SetSize(const Value: int32); override;
    function GetColorBackgrnd: TColor4f; override;
  public
    constructor Create(AGrid: TBGrid); override;
    destructor Destroy; override;
    procedure SetDefaultSizeCell; override;
    class function NamePresentation: string; override;
    procedure IncSize; override;
    procedure DecSize; override;
    procedure SetMaxSize; override;
    procedure SetMinSize; override;
    procedure SetDefaultSize; override;
    class function GetDefaultSize: int32; override;
    class function GetMinSize: int32; override;
    { it is a size displyed bits, pixels }
    property SizeBit: int32 read FSizeBit write SetSizeBit;
    { color bit for drawing one; color bit for drawing zero takes from Color
      property the base class }
    property Color1: TColor4f read FColor1 write SetColor1;
  published
    { property wripper over Color1 }
    property ColorOne: TGuiColor read GetColorOne write SetColorOne;
    property ColorBackMinBits: TGuiColor read GetColorBackMinBits write SetColorBackMinBits;
    property DirPictures: string read FDirPictures write SetDirPictures;
  end;

  TOnBlackSharkGridMouseDownNotify = procedure (const Position: TPosition2d; Button: TBSMouseButton;
      Instance: PGraphicInstance) of object;

  //TOnChangePositionNotify = procedure (const Position: TPosition2d) of object;

  TSelectMode = (smRows, smCols, smUnits);

  { The grid for out of some data; It can scroll Double size 2d area; property
    Position defines Viewport (property ClipObject) a place over data mesured
    in (№ Column, № Row) }

  TBGrid = class(TBScrolledWindow)
  public
    type
      PSelArea = ^TSelArea;
      TSelArea = record
        Node: PNodeSpaceTree;
        Rectangle: TRectangle;
        Color: TColor4f;
      end;
  private
    FCurrentPresent: TGridDataPresentation;
    //ResizeEventHandle: TSubscribeHandle;
    CountTryPres: int32;
    StartPosPresent: TVec2d;
    Selector: TCanvasRect;
    StartSelectPos: TVec2f;
    FAreaMarker: TAreaMarker;
    CancelSelected: boolean;
    FSelectMode: TSelectMode;
    SelectingArea: PSelArea;
    ListSelArea: TListVec<PSelArea>;
    SpaceTreeForMarker: TBlackSharkRTree;
    FShowCursor: boolean;
    Cursor: TRectangle;
    FCursorPosition: TPosition2d;
    FSizeGrid: TVec2i64;
    procedure SetPositionFirstCell(const Value: TVec2d);
    procedure SetCurrentPresent(const Value: TGridDataPresentation);
    function GetPositionFirstCell: TVec2d;
    function GetPositionX: int64;
    function GetPositionY: int64;
    procedure SetPositionX(const Value: int64);
    procedure SetPositionY(const Value: int64);
    function GetIntervalSize: int32;
    procedure SetIntervalSize(const Value: int32);
    procedure SelectPosition;
    { shows selected areas hited into viewport }
    procedure OnShowData(Node: PNodeSpaceTree);
    procedure OnHideData(Node: PNodeSpaceTree);
    procedure OnUpdatePositionUserData(Node: PNodeSpaceTree);
    procedure OnDeleteData(Node: PNodeSpaceTree);
    procedure SetAreaMarker(const Value: TAreaMarker);
    procedure BuildAreaMarked(Node: PNodeSpaceTree);
    function CreateArea: PSelArea;
    function GetCurrentSelectedArea: TRectBSd;
    procedure ProcessSelection(UnionAreas: boolean);
    procedure SetShowCursor(const Value: boolean);

    procedure CreateSelector;

    procedure CursorCreate;
    procedure CursorFree;

    procedure SetCursorPosition(const Value: TPosition2d);
    procedure SetSelectMode(const Value: TSelectMode);
    function GetPageSize: TVec2f;

    function GUIPosXToData(const X: double; AlignOnInterval: boolean; AlignToRight: boolean): double; inline;
    function GUIPosYToData(const Y: double; AlignToRight: boolean): double; inline;
    function GUIWidthToData(const Value, StartPos: double; AlignOnInterval: boolean): double; inline;
    function GUIHeightToData(const Value, StartPos: double): double; inline;
    function DataPositionToGUI(const Value: TPosition2d): TPosition2d; inline;
    function DataPositionXToGUI(const Value: double): double; inline;
    function DataWidthToGUI(const Value, StartPos: double): double; inline;
    function DataHeightToGUI(const Value: double): double; inline;
    procedure UpdateCursor;
  protected
    //procedure SetFont(AValue: TBlackSharkCustomFont); override;
    procedure OnChangeCanvasFont(const AData: BData); override;
    procedure DoChangePos; override;
    procedure SetAnchor(Index: TAnchor; const Value: boolean); override;
    procedure MouseDown(const Data: BMouseData); override;
    procedure MouseMove(const Data: BMouseData); override;
    procedure MouseUp(const Data: BMouseData); override;

    class var KindPresentaions: TListVec<TGridDataPresentationClass>;
    class constructor Create;
    class destructor Destroy;
  public
    constructor Create(ACanvas: TBCanvas); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure LoadProperties; override;

    class procedure RegisterPresentation(Presentation: TGridDataPresentationClass);
    class function FindPresentation(const Name: string): TGridDataPresentationClass;
    class function CountKindPresentations: int32;
    class function GetPresentation(Index: int32): TGridDataPresentationClass;

    { Data presentaion methods }
    procedure BeginPresent; virtual;

    { It draws a data as row in CurrentPresent; can invoke many times;
        Parametrs:
        - Position - start position (row, col) in grid;
        - pData - the data for draw;
        - LenData - length data, measured in bits;
        - BeginOffset - is a shift from begin pData to start reading, in bits
         }
    procedure Present(const Position: TVec2i64; pData: pByte; LenData: int32; BeginOffset: int8); virtual;
    procedure EndPresent; virtual;
    procedure Clear;

    { methods selection of data }
    function AddSelectedArea(const Area: TRectBSd; UnionAreas: boolean): TBGrid.PSelArea;
    procedure CancelSelectedArea(const Area: TRectBSd); //: TBGrid.PSelArea;
    procedure SelectionClear;
    procedure SelectionInv;
    procedure SelectionReload;
    { methods cursor controling }
    procedure CursorInc(OverInterval: boolean);
    procedure CursorDec(OverInterval: boolean);
    procedure CursorDecUp;
    procedure CursorIncDown;
    procedure CursorReBuild;
    { select data under cursor }
    procedure CursorSelect(WholeInterval: boolean);
    { check if hit cursor into viewport (ClipObject) }
    function CursorInViewport: boolean;
    { methods of looking through }
    procedure SlidePageDown;
    procedure SlidePageUp;
    procedure SlidePageRight;
    procedure SlidePageLeft;
    procedure SlideDown;
    procedure SlideUp;
    procedure SlideRight;
    procedure SlideLeft;
    { return cell coordinates under point on viewport }
    function GetCell(ViewPortPointX, ViewPortPointY: int32): TVec2d;
    { changes window size }
    procedure Resize(AWidth, AHeight: BSFloat); override;
    { by depend on the size cell CurrentPresent setting property TBlackSharkScrollBar.PixelsInUnit }
    procedure UpdateScrollbarMetrics;
    { defines a scrolled area }
    procedure SetSizeGrid(const CountCol, CountRow: int64); overload;
    procedure SetSizeGrid(const Size: TVec2i64); overload;
    { auto defines a scrolled area is fiting occupated by data }
    procedure SetSizeGrid; overload;
    { Viewport position over grid, (№ column, № row); aligned on interval }
    property PositionFirstCell: TVec2d read GetPositionFirstCell write SetPositionFirstCell;
    { Viewport X-position over grid aligned on interval }
    property PositionX: int64 read GetPositionX write SetPositionX;
    { Viewport Y-position over grid aligned on interval }
    property PositionY: int64 read GetPositionY write SetPositionY;
    { grid size, coulumns, rows }
    property SizeGrid: TVec2i64 read FSizeGrid write SetSizeGrid;
    { current controller for shaping an image; you can implement own controller
      and to assign it }
    property CurrentPresent: TGridDataPresentation read FCurrentPresent write SetCurrentPresent;
    { a size of interval, bits; wrapper property over CurrentPresent.IntervalReader.IntervalSize }
    property IntervalSize: int32 read GetIntervalSize write SetIntervalSize;
    { area marker; allows to select data }
    property AreaMarker: TAreaMarker read FAreaMarker write SetAreaMarker;
    { data showed mode of select: rows, columns, cells }
    property SelectMode: TSelectMode read FSelectMode write SetSelectMode;
    { cursor position over data (!not GUI) (№ coulumn, № row), an fraction part
      in x (column) specify number of bit }
    property CursorPosition: TPosition2d read FCursorPosition write SetCursorPosition;
    { viewed page size, (columns, rows) }
    property PageSize: TVec2f read GetPageSize;
    { define if show cursor; depend on SelectMode cursor has an apropriate shape }
    property ShowCursor: boolean read FShowCursor write SetShowCursor;
  end;

const
  MASK_BIT: array[0..7] of byte = (1, 2, 4, 8, 16, 32, 64, 128);
  MASK_BYTE_PART: array[0..8] of byte = (0, 1, 3, 7, 15, 31, 63, 127, 255);

implementation

uses
    math
  , Classes
  , bs.config
  , bs.math
  , bs.utils
  , bs.graphics
  ;

const
  RWT: array[0..255] of byte = (
     0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240,8,136,72,200,
     40,168,104,232,24,152,88,216,56,184,120,248,4,132,68,196,36,164,100,228,
     20,148,84,212,52,180,116,244,12,140,76,204,44,172,108,236,28,156,92,220,
     60,188,124,252,2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242,
     10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250,6,134,70,198,
     38,166,102,230,22,150,86,214,54,182,118,246,14,142,78,206,46,174,110,238,
     30,158,94,222,62,190,126,254,1,129,65,193,33,161,97,225,17,145,81,209,
     49,177,113,241,9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249,
     5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245,13,141,77,205,
     45,173,109,237,29,157,93,221,61,189,125,253,3,131,67,195,35,163,99,227,
     19,147,83,211,51,179,115,243,11,139,75,203,43,171,107,235,27,155,91,219,
     59,187,123,251,7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247,
     15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255);

{ TBGrid }

function TBGrid.AddSelectedArea(const Area: TRectBSd; UnionAreas: boolean): TBGrid.PSelArea;
begin
  Result := CreateArea;
  //ar.RectData := Area;
  //DataAdd(ar, RectBS(Area.Left*FCurrentPresent.FWidthCol, Area.Top*FCurrentPresent.FHeightRow,
  //  Area.Width*FCurrentPresent.FWidthCol, Area.Height*FCurrentPresent.FHeightRow), ar.Node);

  Result.Node := FAreaMarker.AddArea(Area, Result, UnionAreas, false);
  //FAreaMarker.AddArea(Area.X*FCurrentPresent.FWidthCol, Area.Y*FCurrentPresent.FHeightRow,
  //  Area.Width*FCurrentPresent.FWidthCol, Area.Height*FCurrentPresent.FHeightRow, ar);
end;

procedure TBGrid.AfterConstruction;
begin
  inherited;
  FCanvas.Font := BSFontManager.CreateDefaultFont;
  AllowDragWindowOverData := true;
end;

procedure TBGrid.BeginPresent;
begin
  if CountTryPres = 0 then
    begin
    FCurrentPresent.BeginPresent;
    StartPosPresent := Position;
    end;
  inc(CountTryPres);
end;

procedure TBGrid.BuildAreaMarked(Node: PNodeSpaceTree);
var
  sa: PSelArea;
  area: TRectBSd;
begin
  sa := Node.BB.TagPtr;
  if sa = nil then
    exit;

  area.Position := DataPositionToGUI(vec2d(Node.BB.x_min, Node.BB.y_min)) -
    vec2d(ScrollBarHor.Position, ScrollBarVert.Position);

  area.Size := vec2d(DataWidthToGUI(Node.BB.x_max - Node.BB.x_min, Node.BB.x_min),
    DataHeightToGUI(Node.BB.y_max - Node.BB.y_min));

  if area.Position.x < 0.0 then
  begin
    area.Size := vec2(area.Size.x + area.Position.x, area.Size.y);
    area.Position.x := 0.0;
  end;

  if area.Position.y < 0.0 then
  begin
    area.Size := vec2(area.Size.x, area.Size.y + area.Position.y);
    area.Position.y := 0.0;
  end;
  if area.Size.x + area.Position.x > Width then
    area.Size.x := Width - area.Position.x;
  if area.Size.y + area.Position.y > Height then
    area.Size.y := Height - area.Position.y;
  sa.Rectangle.Size := area.Size;
  sa.Rectangle.Build;
  sa.Rectangle.Position2d := area.Position;
end;

procedure TBGrid.LoadProperties;
begin
  inherited;
  if Selector = nil then
    CreateSelector;
  if AreaMarker = nil then
    AreaMarker := TAreaMarker.Create(SpaceTreeForMarker);
end;

procedure TBGrid.CancelSelectedArea(const Area: TRectBSd); //: TBGrid.PSelArea;
begin
  FAreaMarker.AddArea(Area, nil, true, true);
  //Result := nil;
  //Result.Node := FAreaMarker.AddArea(Area, Result, false, true);
end;

procedure TBGrid.Clear;
begin
  //FreeAndNil(Selector);
  if FCurrentPresent <> nil then
    begin
    FCurrentPresent.Clear;
    AreaMarker.Clear;
    end;
end;

class function TBGrid.CountKindPresentations: int32;
begin
  Result := KindPresentaions.Count;
end;

procedure TBGrid.SelectionClear;
begin
  AreaMarker.Clear;
end;

constructor TBGrid.Create(ACanvas: TBCanvas);
begin
  inherited;
  ListSelArea := TListVec<PSelArea>.Create;
  FCanvas.Font.Size := 12;
  FCanvas.Font.CodePage := cpCyrillic;
  SpaceTreeForMarker := TBlackSharkRTree.Create;
  SpaceTreeForMarker.OnShowUserData := OnShowData;
  SpaceTreeForMarker.OnHideUserData := OnHideData;
  SpaceTreeForMarker.OnUpdatePositionUserData := OnUpdatePositionUserData;
  SpaceTreeForMarker.OnDeleteUserData := OnDeleteData;
end;

class constructor TBGrid.Create;
begin
  KindPresentaions := TListVec<TGridDataPresentationClass>.Create;
end;

function TBGrid.CreateArea: PSelArea;
begin
  new(Result);
  Result.Rectangle := nil;
end;

procedure TBGrid.CreateSelector;
begin
  Selector := TCanvasRect.Create(FCanvas, ClipObject);
end;

procedure TBGrid.CursorReBuild;
begin
  case FSelectMode of
    smRows: Cursor.Size := vec2(ClipObject.Width + FCurrentPresent.WidthCharacter, FCurrentPresent.HeightRow);
    smCols: Cursor.Size := vec2(FCurrentPresent.WidthCharacter, ClipObject.Height + FCurrentPresent.HeightRow);
    smUnits: Cursor.Size := vec2(FCurrentPresent.WidthCharacter, FCurrentPresent.HeightRow);
  end;
  Cursor.Build;
end;

procedure TBGrid.CursorCreate;
begin
  Cursor := TRectangle.Create(FCanvas, ClipObject);
  Cursor.Color := BS_CL_YELLOW;
  Cursor.Data.Opacity := 0.3;
  Cursor.Data.Interactive := false;
  Cursor.Fill := true;
  Cursor.Layer2d := Cursor.Layer2d + 3;
  CursorReBuild;
  SelectPosition;
end;

procedure TBGrid.CursorDec(OverInterval: boolean);
begin
  if not FShowCursor or (FSelectMode = TSelectMode.smRows) then
    exit;
  if OverInterval or not FCurrentPresent.CharacterMultiplyOfBit then
  begin
    FCursorPosition.x := FCursorPosition.x - 1.0;
    if FCursorPosition.x < 0 then
      FCursorPosition.x := 0;
  end else
  begin
    FCursorPosition.x := FCursorPosition.x - 1/FCurrentPresent.FIntervalReader.FIntervalSize*
      FCurrentPresent.FBitsInCharacter;
    { check boundary }
    if (FCursorPosition.x < 0) then
      FCursorPosition.x := 0;
  end;
  SelectPosition;
  if not CursorInViewport then
    SlideLeft;
end;

procedure TBGrid.CursorIncDown;
begin
  if not FShowCursor or (FSelectMode = TSelectMode.smCols) then
    exit;
  FCursorPosition.y := FCursorPosition.y + 1;
  if FCursorPosition.y >= ScrollBarVert.Size / ScrollBarVert.Step then
    FCursorPosition.y := FCursorPosition.y - 1;
  SelectPosition;
  if not CursorInViewport then
    SlideDown;
end;

function TBGrid.CursorInViewport: boolean;
var
  r, r2: TRectBSd;
begin
  r.Position.x := FCursorPosition.x * FCurrentPresent.WidthCol;
  r.Position.y := FCursorPosition.y * FCurrentPresent.HeightRow;
  r.Size := Cursor.Size;
  r2 := RectBSd(ScrollBarHor.Position, ScrollBarVert.Position, ClipObject.Width, ClipObject.Height);
  if ScrollBarHor.Visible then
    r2.Height := r2.Height - ScrollBarHor.Width;
  if ScrollBarVert.Visible then
    r2.Width := r2.Width - ScrollBarVert.Width;
  r := RectOverlap(r, r2);
  Result := (r.Width > 0) and (r.Height > 0);
  //Result := RectIntersect(r, RectBSd(ScrollBarHor.Position, ScrollBarVert.Position, ClipObject.Width, ClipObject.Height));
end;

procedure TBGrid.CursorSelect(WholeInterval: boolean);
var
  r: TRectBSd;
  cancel: boolean;
  ln: TListNodes;
  //rem: BSFloat;
begin
  if not FShowCursor then
    exit;
  ln := nil;
  if (FSelectMode = TSelectMode.smRows) then
    begin

    r.X := 0;
    r.Width := round(ScrollBarHor.Size / ScrollBarHor.Step);
    r.Y := FCursorPosition.y;
    r.Height := 1.0;

    FAreaMarker.SpaceTree.SelectData(r.x+0.001, r.y+0.001, 0.00001, 0.00001, ln);

    cancel := (ln <> nil) and (ln.Count > 0);

    if cancel then
      CancelSelectedArea(r) else
      AddSelectedArea(r, true);

    CursorIncDown;

    end else
    begin

    r.X := FCursorPosition.x;
    if not WholeInterval and FCurrentPresent.CharacterMultiplyOfBit then
      begin
      //rem := r.X - trunc(r.X);
      r.Width := 1/FCurrentPresent.FIntervalReader.FIntervalSize * FCurrentPresent.FBitsInCharacter;
      { is on boundary of interval }
      {if (rem + r.Width) >= r.Width * FCurrentPresent.FCharacters  then
        r.Width := 1.0 - rem; }
      end else
      begin
      r.Width := 1.0;
      r.X := trunc(r.X);
      end;

    if (FSelectMode = TSelectMode.smCols) then
      begin
      r.Height := round(ScrollBarVert.Size / ScrollBarVert.Step);
      r.Y := 0;
      end else
      begin
      r.Height := 1.0;
      r.Y := FCursorPosition.y;
      end;

    FAreaMarker.SpaceTree.SelectData(r.x+0.001, r.y+0.001, 0.00001, 0.00001, ln);

    cancel := (ln <> nil) and (ln.Count > 0);

    if cancel then
      CancelSelectedArea(r) else
      AddSelectedArea(r, true);

    CursorInc(WholeInterval);
    end;
end;

procedure TBGrid.CursorFree;
begin
  FreeAndNil(Cursor);
end;

procedure TBGrid.CursorInc(OverInterval: boolean);
var
  i: int64;
begin
  if not FShowCursor or (FSelectMode = TSelectMode.smRows) then
    exit;

  if OverInterval or not FCurrentPresent.CharacterMultiplyOfBit then
    begin
    FCursorPosition.x := FCursorPosition.x + 1;
    if FCursorPosition.x >= ScrollBarHor.Size / ScrollBarHor.Step then
      FCursorPosition.x := FCursorPosition.x - 1;
    end else
    begin
    FCursorPosition.x := FCursorPosition.x + 1/FCurrentPresent.FIntervalReader.FIntervalSize*
      FCurrentPresent.FBitsInCharacter;
    i := trunc(FCursorPosition.x);
    { check boundary }
    if (FCursorPosition.x - i)*FCurrentPresent.FWidthCol + i*FCurrentPresent.FWidthCol >= ScrollBarHor.Size then
      FCursorPosition.x := FCursorPosition.x - 1/FCurrentPresent.FIntervalReader.FIntervalSize*
        FCurrentPresent.FBitsInCharacter;
    //FCurrentPresent.AlignOnCharacter(FCursorPosition, false);
    end;

  SelectPosition;

  if not CursorInViewport then
    SlideRight;
end;

procedure TBGrid.CursorDecUp;
begin
  if not FShowCursor or (FSelectMode = TSelectMode.smCols) then
    exit;
  FCursorPosition.y := FCursorPosition.y - 1;
  if FCursorPosition.y < 0  then
    FCursorPosition.y := 0;
  SelectPosition;
  if not CursorInViewport then
    SlideUp;
end;

function TBGrid.DataHeightToGUI(const Value: double): double;
begin
  Result := Value*FCurrentPresent.FHeightRow;
end;

function TBGrid.DataPositionToGUI(const Value: TPosition2d): TPosition2d;
begin
  Result.x := DataPositionXToGUI(Value.x);
  Result.y := DataHeightToGUI(Value.y);
end;

function TBGrid.DataPositionXToGUI(const Value: double): double;
var
  i: int64;
begin
  { count int }
  i := round(Value);
  if abs(Value - i) > EPSILON then
    i := trunc(Value);
  Result := i*FCurrentPresent.FWidthCol + (Value-i)*FCurrentPresent.FWidthColOnlyData;
end;

function TBGrid.DataWidthToGUI(const Value, StartPos: double): double;
begin
  if StartPos > 0 then
    begin
    Result := DataPositionXToGUI(Value + StartPos);
    Result := Result - DataPositionXToGUI(StartPos);
    end else
    Result := DataPositionXToGUI(Value);
end;

class destructor TBGrid.Destroy;
begin
  KindPresentaions.Free;
end;

destructor TBGrid.Destroy;
begin
  FCurrentPresent := nil;
  //FreeAndNil(Selector);
  FreeAndNil(FAreaMarker);
  FreeAndNil(ListSelArea);
  FreeAndNil(SpaceTreeForMarker);
  CursorFree;
  inherited;
end;

procedure TBGrid.DoChangePos;
var
  p: TPosition2d;
begin
  if UpdateCounter > 0 then
    exit;
  inherited;
  { sets position of cursor }
  SelectPosition;
  { draw marked areas }
  if (AreaMarker <> nil) and (FCurrentPresent <> nil) then
  begin
    p.x := ScrollBarHor.Position div ScrollBarHor.Step;
    p.y := ScrollBarVert.Position div ScrollBarVert.Step;
    AreaMarker.SpaceTree.ViewPort(p.x, p.y, ClipObject.Width / FCurrentPresent.FWidthCol,
      ClipObject.Height / FCurrentPresent.FHeightRow);
  end;
end;

procedure TBGrid.EndPresent;
begin
  dec(CountTryPres);
  if CountTryPres = 0 then
    begin
    FCurrentPresent.EndPresent;
    SelectPosition;
    end;
end;

function TBGrid.GUIHeightToData(const Value, StartPos: double): double;
begin
  Result := GUIPosYToData(StartPos + Value, true) - GUIPosYToData(StartPos, false);
end;

function TBGrid.GUIPosXToData(const X: double; AlignOnInterval: boolean;
  AlignToRight: boolean): double;
var
  i: int64;
  rem: double;
begin
  if FCurrentPresent = nil then
    exit(0.0);
  Result := X / FCurrentPresent.FWidthCol;
  if AlignOnInterval then
    begin
    if AlignToRight then
      Result := ceil(Result) else
      Result := trunc(Result);
    end else
    begin
    i := trunc(Result);
    rem := X - i*FCurrentPresent.FWidthCol;
    if rem > FCurrentPresent.FWidthColOnlyData then
      Result := i + 1.0 else
        begin
        if AlignToRight then
          Result := i + 1/FCurrentPresent.FIntervalReader.FIntervalSize *
            ceil(rem/FCurrentPresent.WidthCharacter) * FCurrentPresent.FBitsInCharacter else
          Result := i + 1/FCurrentPresent.FIntervalReader.FIntervalSize *
            trunc(rem/FCurrentPresent.WidthCharacter) * FCurrentPresent.FBitsInCharacter;
        end;
    end;
end;

function TBGrid.GUIPosYToData(const Y: double; AlignToRight: boolean): double;
begin
  if FCurrentPresent = nil then
    exit(0.0);
  if AlignToRight then
    Result := ceil (Y / FCurrentPresent.FHeightRow) else
    Result := trunc(Y / FCurrentPresent.FHeightRow);
end;

function TBGrid.GUIWidthToData(const Value, StartPos: double; AlignOnInterval: boolean): double;
begin
  Result := GUIPosXToData(StartPos + Value, AlignOnInterval, true) - GUIPosXToData(StartPos, AlignOnInterval, false);
  if (Result = 0) then
    begin
    if AlignOnInterval or not FCurrentPresent.FCharacterMultiplyOfBit then
      Result := 1.0 else
      Result := 1/FCurrentPresent.FIntervalReader.FIntervalSize * FCurrentPresent.FBitsInCharacter;
    end;
end;

procedure TBGrid.SelectionInv;
begin
  AreaMarker.Invert(0, 0, ScrollBarHor.Size / ScrollBarHor.Step, ScrollBarVert.Size / ScrollBarVert.Step);
end;

procedure TBGrid.SelectionReload;
begin
  AreaMarker.StateFix;
  AreaMarker.Clear;
  AreaMarker.StateRecovery;
end;

procedure TBGrid.MouseDown(const Data: BMouseData);
var
  ln: TListNodes;
  r: TRectBSd;
begin
  inherited;
  if FCurrentPresent = nil then
    exit;

  StartSelectPos := vec2(Data.X, Data.Y) - MainBody.AbsolutePosition2d;

  r.x := GUIPosXToData(ScrollBarHor.Position + StartSelectPos.x, false, false);
  r.y := GUIPosYToData(ScrollBarVert.Position + StartSelectPos.y, false);

  Selector.Size := vec2(2.0, 2.0);
  Selector.Position2d := StartSelectPos;

  if (TBSMouseButton.mbBsLeft in Data.Button) and FShowCursor then
  begin
    FCursorPosition := r.Position;
    SelectPosition;
  end;

  if not (TBSMouseButton.mbBsRight in Data.Button) then
    exit;

  r := GetCurrentSelectedArea;
  ln := nil;
  FAreaMarker.SpaceTree.SelectData(r.x+0.0001, r.y+0.0001, 0.00001, 0.00001, ln);

  CancelSelected := (ln <> nil) and (ln.Count > 0);
  Selector.Build;
  Selector.Show;
  FAreaMarker.StateFix;

  //ProcessSelection(false);
  if CancelSelected then
  begin
    CancelSelectedArea(r);
  end else
  begin
    SelectingArea := AddSelectedArea(r, false);
  end;
end;

procedure TBGrid.MouseMove(const Data: BMouseData);
var
  d, s, abs_pos, pos: TVec2f;
  change_pos: boolean;
begin
  inherited;
  if Selector.Data.Hidden then
    exit;

  abs_pos := MainBody.AbsolutePosition2d;

	d := vec2(Data.X - abs_pos.x - StartSelectPos.x, Data.Y - abs_pos.y - StartSelectPos.y);

  if (d.x = 0.0) and (d.y = 0.0) then
    exit;

  if d.x = 0 then
    s.x := 1 else
    s.x := abs(d.x);

  if d.y = 0 then
    s.y := 1 else
    s.y := abs(d.y);

  pos := Selector.Position2d;
 	Selector.Size := s;
  Selector.Build;

  change_pos := false;

  if (d.x < 0) then
    begin
    change_pos := true;
    pos.x := StartSelectPos.x + d.x;
  	end;

  if (d.y < 0) then
    begin
    pos.y := StartSelectPos.y + d.y;
    change_pos := true;
    end;

  if change_pos then
    Selector.Position2d := pos else
    Selector.Position2d := StartSelectPos;

  ProcessSelection(false);

end;

procedure TBGrid.MouseUp(const Data: BMouseData);
begin
  inherited;
  if not Selector.Data.Hidden then
  begin
    if SelectingArea <> nil then
    begin
      ProcessSelection(true);
      //FAreaMarker.UpdateArea(Box3(GetCurrentSelectedArea), SelectingArea.Node, true);
      //SelectingArea := AddSelectedArea(ar);
    end;
    Selector.Hide;
  end;
end;

procedure TBGrid.OnDeleteData(Node: PNodeSpaceTree);
var
  ar: PSelArea;
begin
  ar := Node.BB.TagPtr;
  if Assigned(ar) then
  begin
    ar.Rectangle.Free;
    dispose(ar);
  end;
end;

procedure TBGrid.OnHideData(Node: PNodeSpaceTree);
var
  sa: PSelArea;
begin
  sa := Node.BB.TagPtr;
  FreeAndNil(sa.Rectangle);
end;

procedure TBGrid.OnShowData(Node: PNodeSpaceTree);
var
  sa: PSelArea;
begin
  sa := Node.BB.TagPtr;
  if sa = nil then
  begin
    sa := CreateArea;
    Node.BB.TagPtr := sa;
  end;
  sa.Rectangle := TRectangle.Create(FCanvas, ClipObject);
  sa.Rectangle.Fill := true;
  sa.Rectangle.Data.StaticObject := false;
  sa.Rectangle.Data.Opacity := 0.5;
  sa.Rectangle.Data.Interactive := false;
  sa.Rectangle.Layer2d := 15;
  //sa.Rectangle.Data.DrawAsTransparent := true;
  sa.Rectangle.Color := BS_CL_SILVER2; // Selector.Color;
  BuildAreaMarked(Node);
  //Result.Present.Color := ForMe.Color;
end;

procedure TBGrid.OnUpdatePositionUserData(Node: PNodeSpaceTree);
begin
  BuildAreaMarked(Node);
end;

function TBGrid.GetCell(ViewPortPointX, ViewPortPointY: int32): TVec2d;
var
  v: TVec2f;
begin
  v := vec2(ViewPortPointX, ViewPortPointY) - MainBody.AbsolutePosition2d;
  Result.x := GUIPosXToData(ScrollBarHor.Position + v.x, false, false);
  Result.y := GUIPosYToData(ScrollBarVert.Position + v.y, false);
end;

function TBGrid.GetCurrentSelectedArea: TRectBSd;
begin
  case FSelectMode of
    smRows: begin
      Result.x      := 0;
      Result.y      := (ScrollBarVert.Position + Selector.Position2d.y);// / FCurrentPresent.FHeightRow;
      Result.Width  := (ScrollBarHor.Size); // / FCurrentPresent.FWidthCol
      Result.Height := (Selector.Size.y);   // / FCurrentPresent.FHeightRow
    end;
    smCols: begin
      Result.x      := ScrollBarHor.Position + Selector.Position2d.x;// / FCurrentPresent.FWidthCol;
      Result.y      := 0;
      Result.Width  := Selector.Size.x;   // / FCurrentPresent.FWidthCol
      Result.Height := ScrollBarVert.Size;//  / FCurrentPresent.FHeightRow;
    end else
    begin
      Result.x      := (ScrollBarHor.Position + Selector.Position2d.x);// / FCurrentPresent.FWidthCol;
      Result.y      := (ScrollBarVert.Position + Selector.Position2d.y);// / FCurrentPresent.FHeightRow;
      Result.Width  := Selector.Size.x;//  / FCurrentPresent.FWidthCol;
      Result.Height := Selector.Size.y;//  / FCurrentPresent.FHeightRow;
    end;
  end;

  if (ssCtrl in FCanvas.Renderer.ShiftState) and (FCurrentPresent.FCharacterMultiplyOfBit) then  //
  begin
    Result.Width := GUIWidthToData(Result.Width, Result.x, false);
    Result.Height := GUIHeightToData(Result.Height, Result.y);
    Result.x := GUIPosXToData(Result.x, false, false);
    Result.y := GUIPosYToData(Result.y, false);
  end else
  begin
    if Result.Width > 100 then
      Result.Width := Result.Width;
    Result.Width := GUIWidthToData(Result.Width, trunc(Result.x), true);
    Result.x := GUIPosXToData(Result.x, true, false);
    Result.Height := GUIHeightToData(Result.Height, Result.y);
    Result.y := GUIPosYToData(Result.y, false);
  end;
end;

function TBGrid.GetIntervalSize: int32;
begin
  if FCurrentPresent = nil then
    exit(0);
  Result := FCurrentPresent.FIntervalReader.FIntervalSize;
end;

function TBGrid.GetPageSize: TVec2f;
begin

  if ScrollBarVert.Visible then
    Result.x := round((ClipObject.Width - ScrollBarVert.Width) / CurrentPresent.WidthCol)
  else
    Result.x := round(ClipObject.Width / CurrentPresent.WidthCol);

  if ScrollBarHor.Visible then
    Result.y := round((ClipObject.Height - ScrollBarHor.Width) / CurrentPresent.HeightRow)
  else
    Result.y := round(ClipObject.Height / CurrentPresent.HeightRow);

end;

function TBGrid.GetPositionFirstCell: TVec2d;
begin
  Result.x := ScrollBarHor.Position / ScrollBarHor.Step;
  Result.y := ScrollBarVert.Position / ScrollBarVert.Step;
end;

function TBGrid.GetPositionX: int64;
begin
  Result := ScrollBarHor.Position div ScrollBarHor.Step; // FIntervalReader.IntervalSize;
end;

function TBGrid.GetPositionY: int64;
begin
  Result := ScrollBarVert.Position div ScrollBarVert.Step;
end;

class function TBGrid.FindPresentation(const Name: string): TGridDataPresentationClass;
var
  i: int32;
begin
  for i := 0 to KindPresentaions.Count - 1 do
    if KindPresentaions.Items[i].NamePresentation = Name then
      exit(KindPresentaions.Items[i]);
  Result := nil;
end;

class function TBGrid.GetPresentation(Index: int32): TGridDataPresentationClass;
begin
  Result := KindPresentaions.Items[Index];
end;

procedure TBGrid.Present(const Position: TVec2i64; pData: pByte; LenData: int32; BeginOffset: int8);
var
  w: BSFloat;
  pos: TVec2i;
begin
  if FCurrentPresent = nil then
    raise Exception.Create('CurrentPresent do not assigned!');
  pos := vec2(Position.x - Self.PositionX, Position.y - Self.PositionY);
  w := FCurrentPresent.Present(pos, pData, LenData, BeginOffset);
  if pos.x + w > FCurrentPresent.FRect.X + FCurrentPresent.FRect.Width then
    FCurrentPresent.FRect.Width := pos.x + w - FCurrentPresent.FRect.X;
end;

procedure TBGrid.ProcessSelection(UnionAreas: boolean);
begin
  FAreaMarker.StateRecovery;
  if CancelSelected then
    CancelSelectedArea(GetCurrentSelectedArea)
  else
    AddSelectedArea(GetCurrentSelectedArea, UnionAreas);
end;

class procedure TBGrid.RegisterPresentation(Presentation: TGridDataPresentationClass);
begin
  KindPresentaions.Add(Presentation);
end;

procedure TBGrid.Resize(AWidth, AHeight: BSFloat);
begin
  inherited;
  if (FCurrentPresent <> nil) then
    FCurrentPresent.CanvasObjectMap.Position2d :=
      -vec2(FCurrentPresent.CanvasObjectMap.Width*0.5, FCurrentPresent.CanvasObjectMap.Height*0.5);
  if FShowCursor then
    CursorReBuild;
end;

procedure TBGrid.SetCurrentPresent(const Value: TGridDataPresentation);
begin
  if FCurrentPresent <> nil then
    FCurrentPresent.Hide;

  FCurrentPresent := Value;

  if FCurrentPresent <> nil then
  begin
    //FCurrentPresent.Instances.DefaultColor := FColor;
    UpdateScrollbarMetrics;
    Color := ColorFloatToByte(FCurrentPresent.ColorBackgrnd).value;
    FCurrentPresent.Show;
  end;

  SelectionReload;
  if FShowCursor then
    begin
    CursorReBuild;
    SelectPosition;
    end;
end;

procedure TBGrid.SetCursorPosition(const Value: TPosition2d);
var
  v: TVec3d;
begin
  FCursorPosition := Value;
  if not FShowCursor then
    exit;
  v := vec3d(FCursorPosition.x, FCursorPosition.y, 0.0);
  if not Box3PointIn(FAreaMarker.SpaceTree.CurrentViewPort, v) then
    Position := FCursorPosition;
end;

procedure TBGrid.SelectPosition;
var
  pos: TVec2f;
begin
  if FCurrentPresent = nil then
    exit;
  if FShowCursor then
  begin
    pos := DataPositionToGUI(FCursorPosition) - vec2d(ScrollBarHor.Position, ScrollBarVert.Position);
    case FSelectMode of
      smRows:
        begin
        pos.x := 0;
        end;
      smCols:
        begin
        pos.y := 0;
        end;
    end;
    Cursor.Position2d := pos;
  end;
end;

procedure TBGrid.SetAnchor(Index: TAnchor; const Value: boolean);
begin
  inherited;
  {if CountAnchors > 0 then
    begin
    if ResizeEventHandle = nil then
      ResizeEventHandle := FCanvas.Scene.EventResize.Subscribe(ResizeViewPortEvent, Self);
    end else
    begin
    if ResizeEventHandle <> nil then
      FCanvas.Scene.EventResize.UnSubscribe(ResizeEventHandle);
    end;   }
end;

procedure TBGrid.SetAreaMarker(const Value: TAreaMarker);
begin
  if FAreaMarker = Value then
    exit;
  FAreaMarker := Value;
end;


procedure TBGrid.OnChangeCanvasFont(const AData: BData);
begin
  if TBCanvas(AData.Instance).Font.IsVectoral or not (TBCanvas(AData.Instance).Font is TTrueTypeRasterFont) then
    raise Exception.Create('Can not use a vectoral font!');
  if FShowCursor then
    UpdateCursor;
  inherited;
end;


procedure TBGrid.SetIntervalSize(const Value: int32);
begin
  if FCurrentPresent = nil then
    exit;
  FCurrentPresent.SetDefaultSizeCell;
  FCurrentPresent.FIntervalReader.FIntervalSize := Value;
  UpdateScrollbarMetrics;
end;

procedure TBGrid.SetPositionFirstCell(const Value: TVec2d);
begin
  ScrollTo(round(Value.x)*ScrollBarHor.Step, round(Value.y)*ScrollBarVert.Step);
end;

procedure TBGrid.SetPositionX(const Value: int64);
begin
  ScrollBarHor.Position := ScrollBarHor.Step * Value;
end;

procedure TBGrid.SetPositionY(const Value: int64);
begin
  ScrollBarVert.Position := ScrollBarVert.Step * Value;
end;

procedure TBGrid.SetSelectMode(const Value: TSelectMode);
begin
  if FSelectMode = Value then
    exit;
  FSelectMode := Value;
  if FShowCursor then
    UpdateCursor;
end;

procedure TBGrid.SetShowCursor(const Value: boolean);
begin
  if Value = FShowCursor then
    exit;
  FShowCursor := Value;
  if FShowCursor then
    CursorCreate else
    CursorFree;
end;

procedure TBGrid.SetSizeGrid;
begin
  if FCurrentPresent <> nil then
    SetSizeGrid(Round(FCurrentPresent.FRect.X + FCurrentPresent.FRect.Width),
      Round(FCurrentPresent.FRect.Y + FCurrentPresent.FRect.Height));
end;

procedure TBGrid.SlideDown;
begin
  Position := vec2d(ScrollBarHor.Position / ScrollBarHor.Step, PositionY + 1);
end;

procedure TBGrid.SlideLeft;
begin
  Position := vec2d(ScrollBarHor.Position / ScrollBarHor.Step - 1, PositionY);
end;

procedure TBGrid.SlidePageDown;
var
  page_size: TVec2f;
begin
  page_size := PageSize;
  Position := vec2d(PositionX, PositionY + page_size.y);
end;

procedure TBGrid.SlidePageLeft;
var
  page_size: TVec2f;
begin
  page_size := PageSize;
  Position := vec2d(PositionX - page_size.x, PositionY);
end;

procedure TBGrid.SlidePageRight;
var
  page_size: TVec2f;
begin
  page_size := PageSize;
  Position := vec2d(PositionX + page_size.x, PositionY);
end;

procedure TBGrid.SlidePageUp;
var
  page_size: TVec2f;
begin
  page_size := PageSize;
  Position := vec2d(PositionX, PositionY - page_size.y);
end;

procedure TBGrid.SlideRight;
begin
  Position := vec2d(ScrollBarHor.Position / ScrollBarHor.Step + 1, PositionY);
end;

procedure TBGrid.SlideUp;
begin
  Position := vec2d(ScrollBarHor.Position / ScrollBarHor.Step, PositionY - 1);
end;

procedure TBGrid.SetSizeGrid(const Size: TVec2i64);
begin
  SetSizeGrid(Size.x, Size.y);
end;

procedure TBGrid.SetSizeGrid(const CountCol, CountRow: int64);
begin
  FSizeGrid := vec2(CountCol, CountRow);
  ScrolledArea := vec2d(CountCol*ScrollBarHor.Step, CountRow*ScrollBarVert.Step);
end;

procedure TBGrid.UpdateCursor;
begin
  CursorReBuild;
  SelectPosition;
end;

procedure TBGrid.UpdateScrollbarMetrics;
var
  pos: TVec2d;
begin
  if FCurrentPresent <> nil then
    begin
    pos := Position;
    FCurrentPresent.SetDefaultSizeCell;
    BeginUpdate;
    try
      ScrollBarHor.Step := FCurrentPresent.WidthCol;
      ScrollBarVert.Step := FCurrentPresent.HeightRow;
      ScrolledArea := vec2d(FSizeGrid.x*ScrollBarHor.Step, FSizeGrid.y*ScrollBarVert.Step);
      AreaMarker.SpaceTree.ViewPort(pos.x, pos.y, FSizeGrid.x, FSizeGrid.y);
    finally
      EndUpdate;
    end;
    Position := pos;
    end;
end;

{ TGridDataPresentation }

procedure TGridDataPresentation.BeginPresent;
begin
  FCountInstanses := 0;
  //Instances.CountParticle := 0;
  FRect.U := MaxSingle;
  FRect.V := MaxSingle;
  FRect.Size := vec2(0.0, 0.0);
  // for optimal load a texture to GPU (not for every symbvol)
  if (Instances.Texture <> nil) then
    Instances.Texture.Texture.BeginUpdate;
end;

procedure TGridDataPresentation.Clear;
begin
  if EasterEggRunning then
    EasterEggStop;
  Instances.Clear;
end;

constructor TGridDataPresentation.Create(AGrid: TBGrid);
begin
  inherited Create;
  FGrid := AGrid;
  FIntervalReader := TIntervalReader.Create;
  FColorBackground := BS_CL_MSVS_BORDER;

  CanvasObjectMap := TRectangle.Create(FGrid.Canvas, FGrid.ClipObject);
  CanvasObjectMap.Size := FGrid.ClipObject.Size;
  CanvasObjectMap.Fill := true;
  CanvasObjectMap.Build;
  { again assigns parent, so otherwise he return to FGrid.InstancesOwner, see
    TBlackSharkScrollingWindow.OnCreateCanvasObject }
  CanvasObjectMap.Parent := FGrid.ClipObject;
  CanvasObjectMap.Data.StencilTest := true;
  CanvasObjectMap.Position2d := vec2(0.0, 0.0);
  //CanvasObjectMap.Layer2d := 10;
  Instances := CreateParticlesContainer;
end;

destructor TGridDataPresentation.Destroy;
begin
  Clear;
  FIntervalReader.Free;
  Instances.Texture := nil;
  Instances.Free;
  inherited;
end;

procedure TGridDataPresentation.EndPresent;
var
  m: TVec2f;
begin
  if Assigned(Instances.Texture) then
  begin
    Instances.Texture.Texture.EndUpdate(true);
  end;

  if CountInstanses < Instances.CountParticle then
    Instances.CountParticle := CountInstanses;

  if Instances.CountParticle > 0 then
  begin
    CanvasObjectMap.Size := FGrid.ClipObject.Size;
    CanvasObjectMap.Build;
    m.x := FGrid.ScrollBarHor.Position mod FGrid.ScrollBarHor.Step;
    m.y := FGrid.ScrollBarVert.Position mod FGrid.ScrollBarVert.Step;
    CanvasObjectMap.Position2d := -CanvasObjectMap.Size * 0.5 - m;
  end;

  if EasterEgg <> nil then
    EasterEgg.Update;
end;

function TGridDataPresentation.GetColorBackgrnd: TColor4f;
begin
  Result := FColorBackground;
end;

function TGridDataPresentation.GetColorBackground: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBackground).value;
end;

function TGridDataPresentation.GetOwner: TGUIProperties;
begin
  Result := FGrid;
end;

procedure TGridDataPresentation.Hide;
begin
  if EasterEggRunning then
    EasterEggStop;
  CanvasObjectMap.Data.SetHiddenRecursive(true);
end;

function TGridDataPresentation.Present(const Position: TVec2i;
  pData: pByte; LenData: int32; BeginOffset: int8): BSFloat;
begin

  if Position.x < FRect.X then
    FRect.X := Position.x;

  if Position.y < FRect.Y then
    FRect.Y := Position.y;

  if Position.y + 1 > FRect.Y + FRect.Height then
    FRect.Height := Position.y + 1 - FRect.Y;

  FIntervalReader.SetData(pData, LenData, BeginOffset);
  Result := 0.0;

end;

procedure TGridDataPresentation.EasterEggRun;
begin
  if EasterEgg <> nil then
    exit;
  EasterEgg := TEasterEgg.Create(Self);
  EasterEgg.Run;
end;

function TGridDataPresentation.EasterEggRunning: boolean;
begin
  Result := EasterEgg <> nil;
end;

procedure TGridDataPresentation.SetColorBackgrnd(const Value: TColor4f);
begin
  FColorBackground := Value;
end;

procedure TGridDataPresentation.SetColorBackground(const Value: TGuiColor);
begin
  FColorBackground := ColorByteToFloat(Value);
  FColorBackground.a := 1.0;
  if FGrid.CurrentPresent = Self then
    FGrid.Color := ColorFloatToByte(FColorBackground).value;
end;

procedure TGridDataPresentation.SetDefaultSizeCell;
begin
  FWidthColOnlyData := FWidthCol;
end;

procedure TGridDataPresentation.Show;
begin
  CanvasObjectMap.Data.SetHiddenRecursive(false);
  //CanvasObjectMap.Position2d := vec2(-CanvasObjectMap.Width * 0.5, -CanvasObjectMap.Height * 0.5);
end;

procedure TGridDataPresentation.EasterEggStop;
begin
  if EasterEgg = nil then
    exit;
  EasterEgg.Stop;
  FreeAndNil(EasterEgg);
end;

{ TGridTextDataPresentation }

procedure TGridTextDataPresentation.BeginPresent;
begin
  if (Instances.Texture = nil) or (FGrid.Canvas.Font.Texture = nil) or
    (Instances.Texture^.Texture <> FGrid.Canvas.Font.Texture.Texture) then
  begin
    SelectTexture;
  end;

  if FGrid.Canvas.Font.SizeInPixels <> FSize then
    FGrid.Canvas.Font.SizeInPixels := FSize;

  FGrid.Canvas.Font.BeginSelectChars;
  inherited;
end;

constructor TGridTextDataPresentation.Create(AGrid: TBGrid);
begin
  inherited Create(AGrid);
  FSize := GetDefaultSize;
  ObsrvReplaceFont := FGrid.FCanvas.OnReplaceFont.CreateObserver(GUIThread, OnReplaceFont);
  ObsrvChangeFont := FGrid.FCanvas.Font.OnChangeEvent.CreateObserver(GUIThread, OnChangeFont);
end;

function TGridTextDataPresentation.CreateParticlesContainer: TParticlesMultiUV;
begin
  { wrap paticles to Canvas (FGrid) }
  Result := TParticlesMultiUVSingleColor.Create(FGrid.Canvas.Renderer, CanvasObjectMap.Data);
  Result.Capacity := 1000;
  TParticlesMultiUVSingleColor(Result).Color := BS_CL_GREEN;
end;

procedure TGridTextDataPresentation.DecSize;
begin
  if FSize > GetMinSize then
  begin
    dec(FSize);
    FGrid.Canvas.Font.SizeInPixels := FSize;
  end;
end;

procedure TGridTextDataPresentation.EndPresent;
begin
  if FGrid.Canvas.Font.IsVectoral then
    raise Exception.Create('Can not use a vectoral font!');
  FGrid.Canvas.Font.EndSelectChars;
  // enforce generate texture
  {if FGrid.Font.Texture = nil then
    begin
    FGrid.Font.CreateTexture;
    Instances.Texture := FGrid.Font.Texture.Texture.SelfArea;
    end;}
  if Instances.Texture <> FGrid.Canvas.Font.Texture.Texture.SelfArea then
    raise Exception.Create('Error Message');
  {if Instances.Texture <> FGrid.Font.Texture.Texture.SelfArea then
    Instances.Texture := FGrid.Font.Texture.Texture.SelfArea; }
  //Instances.Texture.Texture.Picture.Save('d:\texture_font.bmp');
  inherited EndPresent;
  //CanvasObjectMap.Layer2d := -4;
  //CanvasObjectMap.Position2d := vec2(0.0, 0.0);
  //CanvasObjectMap.Position2d := vec2(298.0, 298.0);
  //CanvasObjectMap.Data.AbsolutePosition := vec3(0.0, 0.0, -0.0009994);
end;

function TGridTextDataPresentation.GetColor: TColor4f;
begin
  Result := TParticlesMultiUVReplaceSingleColor(Instances).Color;
end;

class function TGridTextDataPresentation.GetDefaultSize: int32;
begin
  Result := 12;
end;

class function TGridTextDataPresentation.GetMinSize: int32;
begin
  Result := 8;
end;

function TGridTextDataPresentation.GetSize: int32;
begin
  Result := FSize;
  //if FGrid.Canvas.Font.SizeInPixels <> FSize then
  //  FGrid.Canvas.Font.SizeInPixels := FSize;
end;

procedure TGridTextDataPresentation.IncSize;
begin
  if FSize + 1 <= (FGrid.Canvas.Font as TTrueTypeRasterFont).MaxRasterSize then
    begin
    inc(FSize);
    FGrid.Canvas.Font.SizeInPixels := FSize;
    end;
end;

procedure TGridTextDataPresentation.OnChangeFont(const Value: BEmpty);
begin
  SelectTexture;
end;

procedure TGridTextDataPresentation.OnReplaceFont(const Value: BEmpty);
begin
  SelectTexture;
end;

procedure TGridTextDataPresentation.SelectTexture;
begin
  { check exists the texture; force create texture if not }
  if FGrid.Canvas.Font.Texture = nil then
  begin
    FGrid.Canvas.Font.KeyByWideChar['A'];
    if FGrid.Canvas.Font.Texture = nil then
      raise Exception.Create('TGridDataPresentation.BeginPresent: a source font does not have texture!');
  end;

  if FGrid.Canvas.Font.IsVectoral then
    raise Exception.Create('TGridAnsiDataPresentation.BeginPresent: can not out vectoral text!');
  Instances.Texture := FGrid.Canvas.Font.Texture.Texture.SelfArea;
end;

procedure TGridTextDataPresentation.SetColor(const Value: TColor4f);
begin
  TParticlesMultiUVSingleColor(Instances).Color := Value;
end;

procedure TGridTextDataPresentation.SetDefaultSize;
begin
  FSize := GetDefaultSize;
  FGrid.Canvas.Font.SizeInPixels := FSize;
end;

procedure TGridTextDataPresentation.SetMaxSize;
begin
  FSize := TTrueTypeRasterFont(FGrid.Canvas.Font as TTrueTypeRasterFont).MaxRasterSize;
  FGrid.Canvas.Font.SizeInPixels := FSize;
end;

procedure TGridTextDataPresentation.SetMinSize;
begin
  FSize := GetMinSize;
  FGrid.Canvas.Font.SizeInPixels := FSize;
end;

procedure TGridTextDataPresentation.SetSize(const Value: int32);
begin
  if (Value <= TTrueTypeRasterFont(FGrid.Canvas.Font as TTrueTypeRasterFont).MaxRasterSize) and (Value >= GetMinSize) then
    begin
    FSize := Value;
    FGrid.Canvas.Font.SizeInPixels := Value;
    end;
end;

{ TGridAnsiDataPresentation }

procedure TGridAnsiDataPresentation.SetDefaultSizeCell;
begin
  FCharacters := FIntervalReader.IntervalSize div 8;
  if FIntervalReader.IntervalSize mod 8 > 0 then
    inc(FCharacters);
  FWidthCharacter := FGrid.Canvas.Font.SizeInPixels + 1;
  FWidthCol := FWidthCharacter * Characters;
  FWidthColOnlyData := FWidthCol;
  FHeightRow := FGrid.Canvas.Font.SizeInPixels + 5;
  inherited;
  FCharacterMultiplyOfBit := FIntervalReader.IntervalSize mod 8 = 0;
  FBitsInCharacter := 8;
end;

constructor TGridAnsiDataPresentation.Create(AGrid: TBGrid);
begin
  inherited Create(AGrid);
  FCharacterMultiplyOfBit := true;
  Color := BS_CL_GREEN;
end;

destructor TGridAnsiDataPresentation.Destroy;
begin
  if HexDataPresentation <> nil then
    HexDataPresentation.Free;
  inherited;
end;

class function TGridAnsiDataPresentation.NamePresentation: string;
begin
  Result := 'Ansi';
end;

function TGridAnsiDataPresentation.Present(const Position: TVec2i; pData: pByte;
      LenData: int32; BeginOffset: int8): BSFloat;
var
  //proto: TBCanvasObject;
  key: PKeyInfo;
  i, symbs, rem_, count: int32;
  p: TVec3f;
  y: BSFloat;
  half_size: TVec2f;
begin
  inherited;

  count := 0;

  half_size.x := WidthCharacter * 0.5;
  half_size.y := FHeightRow * 0.5;
  y := -Position.y * FHeightRow - half_size.y;

  while FIntervalReader.ReadNext do
  begin
    symbs := FIntervalReader.SizeReaded shr 3;
    rem_ := FIntervalReader.SizeReaded mod 8;
    if rem_ > 0 then
      inc(symbs);
    for i := 0 to symbs - 1 do
    begin
      Key := FGrid.Canvas.Font.Key[FIntervalReader.ResultRead[i]];
      if Key = nil then
        continue;
      p := vec3((Position.x + count) * FWidthCol + i*WidthCharacter + half_size.x,
        y + (Key^.Rect.Height - FHeightRow) * 0.5 + Key^.Glyph^.yMin, 0.0);  //
      Instances.Change(CountInstanses, p, Key^.TextureRect);
      inc(FCountInstanses);
    end;
    inc(count);
  end;

  Result := count;

end;

procedure TGridAnsiDataPresentation.SetPresentInvisibleSymbols(const Value: boolean);
begin
  FPresentInvisibleSymbols := Value;
  if FPresentInvisibleSymbols then
  begin
    if HexDataPresentation = nil then
      HexDataPresentation := TGridHexDataPresentation.Create(FGrid);
  end;
end;

{ TGridHexDataPresentation }

{
function TGridHexDataPresentation.GetProto(Key: uint32;
  out Glyph: PKeyInfo): TBCanvasObject;
const
  DEC_TO_HEX: array[0..15] of byte =
    ($30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46);
begin
  if Prototypes.Find(key, Result) then
    exit;
  Result := FGrid.CreateEmptyCanvasObject(TBCanvasObject, TBlackSharkShape.Create, FGrid.FOwnerInstances);
  InitPrototype(Result);
  Glyph := FGrid.Font.Key[DEC_TO_HEX[(Key and $F)]];
  AddKeyToShape(FGrid.Scene, Glyph, Result.Data.Shape, vec2(0.0, 0.0), FGrid.Font.IsVectoral);
  Prototypes.Add(Key, Result);
  Result.Data.Shape.DrawingPrimitive := GL_TRIANGLES;
  Result.Data.Shape.CalcBoundingBox(true);
  Result.Data.ChangeShape;
  Result.Data.AddBeforDrawMethod(BeforDraw);
  Result.Data.DrawInstance := Draw;
  Result.Data.FBaseInstance.Hide := true;
end;
}

constructor TGridHexDataPresentation.Create(AGrid: TBGrid);
begin
  inherited;
  FCharacterMultiplyOfBit := true;
  Color := vec4($93/255, $f7/255, $54/255, 1.0);
end;

class function TGridHexDataPresentation.NamePresentation: string;
begin
  Result := 'Hexadecimal';
end;

function TGridHexDataPresentation.Present(const Position: TVec2i;
  pData: pByte; LenData: int32; BeginOffset: int8): BSFloat;
var
  //proto: TBCanvasObject;
  key: PKeyInfo;
  i, count: int32;
  code, digits, msk_rem, rem_, prev_rem: byte;
  first: boolean;
  p: TVec3f;
  half_size: BSFloat;
  y: BSFloat;
const
  DEC_TO_HEX: array[0..15] of byte =
    ($30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46);
begin
  inherited;
  count := 0;
  prev_rem := $FF;
  msk_rem := $F;
  half_size := WidthCharacter * 0.5;
  y := -Position.y * FHeightRow - FHeightRow * 0.5; //
  while FIntervalReader.ReadNext do
  begin
    digits := FIntervalReader.SizeReaded shr 2;
    rem_ := FIntervalReader.SizeReaded mod 4;
    if prev_rem <> rem_ then
    begin
      if rem_ > 0 then
      begin
        msk_rem := round(Power(2, rem_)) - 1;
        inc(digits);
      end else
        msk_rem := $F;
      prev_rem := rem_;
    end else
    if rem_ > 0 then
      inc(digits);

    first := true;
    for i := digits - 1 downto 0 do
    begin
      if FTurnover then
        code := RWT[FIntervalReader.ResultRead[FIntervalReader.IntervalSizeInBytes - 1 - i shr 1]]
      else
        code := FIntervalReader.ResultRead[i shr 1];
      if i mod 2 > 0 then
      begin
        if first then
          Code := (Code shr 4) and msk_rem
        else
          Code := Code shr 4;
      end else
      begin
        if first then
          Code := Code and msk_rem
        else
          Code := Code and $F;
      end;
      first := false;
      Key := FGrid.Canvas.Font.Key[DEC_TO_HEX[(code and $F)]];
      if Key = nil then
        continue;
      p := vec3((Position.x + count) * FWidthCol + (digits - i - 1) * WidthCharacter + half_size,
        y + BSConfig.VoxelSize*(Key^.Rect.Height - FHeightRow) * 0.5 +
          BSConfig.VoxelSize*(Key^.Glyph^.yMin), 0.0);  //
      Instances.Change(CountInstanses, p, Key^.TextureRect);
      inc(FCountInstanses);
      {proto := GetProto(code, Key);
      if proto = nil then
        continue;
      ClipInstance(proto, Position.x + count, Position.y, (digits - i - 1) * FWidthCharacter);}
    end;
    inc(count);
  end;
  Result := count;
end;

procedure TGridHexDataPresentation.SetDefaultSizeCell;
begin
  FCharacters := FIntervalReader.IntervalSize div 4;
  if FIntervalReader.IntervalSize mod 4 > 0 then
    inc(FCharacters);

  FWidthCharacter := FGrid.Canvas.Font.SizeInPixels + 1;
  FWidthCol := FWidthCharacter * Characters + 5;
  FHeightRow := FGrid.Canvas.Font.SizeInPixels + 3;
  inherited;
  FWidthColOnlyData := FWidthCharacter * Characters;
  { false, because Big Endian order present }
  FCharacterMultiplyOfBit := false; //FIntervalReader.IntervalSize mod 4 = 0;
  FBitsInCharacter := 4;
end;

{ TBitsDataPresentation }

procedure TBitsDataPresentation.CheckColorBackground;
begin
  if FSizeBit > MAX_SIZE_BIT_IN_PIXELS then
  begin
    if not (FGrid.MainBody.Color = FColorBackground) then
      FGrid.MainBody.Color := FColorBackground;
  end else
  begin
    if not (FGrid.MainBody.Color = FColorBackMinBits) then
      FGrid.MainBody.Color := FColorBackMinBits;
  end;
end;

constructor TBitsDataPresentation.Create(AGrid: TBGrid);
begin
  inherited;
  FCharacterMultiplyOfBit := true;
  Instances.Capacity := 100000;
  FColor0 := BS_CL_BLACK; //vec4(BS_CL_GRAY.x, BS_CL_GRAY.y, BS_CL_GRAY.z, 0.3);
  //FColor0 := BS_CL_MED_GRAY;
  FColor1 := BS_CL_ORANGE;
  FColorBackMinBits := FColorBackground;
  FDirPictures := 'Pictures/bits/';
  SizeBit := 1;
  LoadTextures;
end;

procedure TBitsDataPresentation.LoadTextures;
const
  SIZE_MAP = 512;
var
  pic_one, pic_zero, map: TBlackSharkPicture;
  fn_on, fn_off, num: string;
  x, y: int32;
  j, w, k, i: uint8;
  cl0, cl1: TVec4b;
  r: TRectBSi;
  txt_name: string;
  ta: PTextureArea;
begin
  txt_name := 'map_bits'+IntToHex(NativeInt(Self), SizeOf(NativeInt) shr 1);
  ta := BSTextureManager.FindTexture(txt_name);
  if Assigned(ta) then
  begin
    BitmapTexture := ta.Texture;
    Instances.Texture := BitmapTexture.SelfArea;
    exit;
  end;

  map := TBlackSharkBitMap.Create;
  map.SetSize(SIZE_MAP, SIZE_MAP);
  BitmapTexture := nil;
  pic_one := TBlackSharkBitMap.Create;
  pic_zero := TBlackSharkBitMap.Create;
  cl0 := ColorFloatToByte(FColor0);
  cl1 := ColorFloatToByte(FColor1);
  x := 0;
  y := 0;
  r.X := 0;
  r.Y := 0;
  for j := 1 to 5 do
  begin
    pic_one.SetSize(j, j);
    pic_zero.SetSize(j, j);
    pic_one.Canvas.Fill(cl1);
    pic_zero.Canvas.Fill(cl0);
    r.Width := j;
    r.Height := j;
    w := j * 8 + 1;
    for i := 0 to 255 do
    begin
      if w + x > SIZE_MAP then
      begin
        inc(y, j + 1);
        x := 0;
      end;

      for k := 0 to 7 do
        if i and MASK_BIT[k] <> 0 then
          map.Canvas.CopyRect(pic_one.Canvas, vec2(int32(x + int32(k*j)), y), r)
        else
          map.Canvas.CopyRect(pic_zero.Canvas, vec2(int32(x + int32(k*j)), y), r);
      BitMapUV[j, i].Rect := RectBS(x, y, w - 1, j);
      BitMapUV[j, i].UV := RectToUV(SIZE_MAP, SIZE_MAP, BitMapUV[j, i].Rect);
      inc(x, w);
    end;
  end;
  //map.Free;
  pic_one.Free;
  pic_zero.Free;
  //cl1 := vec4(168, 0, 0, 255);
  for i := MAX_SIZE_BIT downto 6 do
  begin
    num := IntToStr(i);
    fn_on := GetFilePath(FDirPictures + 'bit_on' + num + 'x' + num +'.png');
    if not FileExists(fn_on) then
      continue;
    pic_one := TPicCodecManager.Open(fn_on);
    pic_one.Canvas.ReplaceColor(cl1);

    //pic_one.Save(GetFilePath(FDirPictures + 'bit_off'+ num + 'x' + num +'_.png'));
    //ResetAlpha(pic_one);
    //pic_one.Canvas.SamplerFilter.InterpolationMode := TInterpolationMode.imLinear;
    fn_off := GetFilePath(FDirPictures + 'bit_off'+ num + 'x' + num +'.png');
    pic_zero := TPicCodecManager.Open(fn_off);
    pic_zero.Canvas.ReplaceColor(cl0);
    //ResetAlpha(pic_zero);
    r.Width := pic_one.Width;
    r.Height := pic_one.Height;
    if r.Width + x > SIZE_MAP then
    begin
      inc(y, r.Height + 1);
      x := 0;
    end;
    map.Canvas.CopyRect(pic_one.Canvas, vec2(x, y), r);
    TexturesOne[i].Rect := RectBS(x, y, r.Width, r.Height);
    TexturesOne[i].UV := RectToUV(SIZE_MAP, SIZE_MAP, TexturesOne[i].Rect);
    inc(x, r.Width);
    r.Width := pic_zero.Width;
    r.Height := pic_zero.Height;
    if r.Width + x > SIZE_MAP then
    begin
      inc(y, r.Height + 1);
      x := 0;
    end;
    map.Canvas.CopyRect(pic_zero.Canvas, vec2(x, y), r);
    TexturesZero[i].Rect := RectBS(x, y, r.Width, r.Height);
    TexturesZero[i].UV := RectToUV(SIZE_MAP, SIZE_MAP, TexturesZero[i].Rect);
    inc(x, r.Width);
    //TexturesOne[i] := FGrid.Scene.TextureManager.LoadTexture(pic_one, 'bit_on_'+num, true, false);
    //TexturesZero[i] := FGrid.Scene.TextureManager.LoadTexture(pic_zero, 'bit_off_'+num, true, false);
    pic_one.Free;
    pic_zero.Free;
  end;

  BitmapTexture := BSTextureManager.LoadTexture(map, txt_name, false, false).Texture;
  Instances.Texture := BitmapTexture.SelfArea;

  //map.Save('D:\map_bits.bmp');
  //map.Free;
end;

class function TBitsDataPresentation.NamePresentation: string;
begin
  Result := 'Bits';
end;

function TBitsDataPresentation.CreateParticlesContainer: TParticlesMultiUV;
begin
  Result := TParticlesMultiUV.Create(FGrid.Canvas.Renderer, CanvasObjectMap.Data);
  FColor1 := BS_CL_ORANGE;
end;

procedure TBitsDataPresentation.DecSize;
begin
  SizeBit := SizeBit - 1;
end;

destructor TBitsDataPresentation.Destroy;
begin
  BitmapTexture := nil;
  Instances.Texture := nil;
  inherited;
end;

function TBitsDataPresentation.DoPresentByPoints(const Position: TVec2i;
  pData: pByte; LenData: int32; BeginOffset: int8): BSFloat;
var
  i, count: int32;
  p: TVec3f;
  y, x: BSFLoat;
  d, m: word;
  add: BSFloat;
  half_size: BSFLoat;
  tr: TTextureRect;
begin
  half_size := FWidthCol * 0.5;
  count := 0;
  y := -Position.y * FHeightRow - FHeightRow * 0.5;
  x := Position.x * FWidthCol;
  while FIntervalReader.ReadNext do
  begin
    d := 0; m := 0;
    DivMod(FIntervalReader.SizeReaded, 8, d, m);
    for i := 0 to d - 1 do
    begin
      p := vec3( x + half_size, y, 0.0 );
      Instances.Change(CountInstanses, p, BitMapUV[FSizeBit, FIntervalReader.ResultRead[i]]);
      inc(FCountInstanses);
      x := x + FWidthCol;
    end;

    if m > 0 then
    begin
      add := m * FWidthCharacter * BSConfig.VoxelSize;
      p := vec3( x + add * 0.5, y, 0.0 );
      tr := BitMapUV[FSizeBit, FIntervalReader.ResultRead[d]];
      tr.Rect.Width := tr.Rect.Width - (8 - m) * FWidthCharacter;
      tr.UV := RectToUV(BitmapTexture.Picture.Width, BitmapTexture.Picture.Height, tr.Rect);
      Instances.Change(CountInstanses, p, tr);
      x := x + add;
      inc(FCountInstanses);
    end;

    inc(count);
  end;
  Result := count;
end;

function TBitsDataPresentation.DoPresentByTextures(const Position: TVec2i; pData: pByte; LenData: int32; BeginOffset: int8): BSFloat;
var
  i, symbs, count, bits: int32;
  half_size: BSFLoat;
  p: TVec3f;
  y: BSFloat;
begin
  half_size := WidthCharacter * 0.5;
  count := 0;
  y := -Position.y * FHeightRow - half_size;
  while FIntervalReader.ReadNext do
  begin
    symbs := 0;
    bits := 0;
    for i := 0 to FIntervalReader.SizeReaded - 1 do
    begin
      p := vec3(
              (Position.x + count) * FWidthCol + WidthCharacter*i + half_size,
              y,
              0.0
              );
      if (MASK_BIT[bits] and FIntervalReader.ResultRead[symbs] > 0) then
      begin
        Instances.Change(CountInstanses, p, TexturesOne[FSizeBit]);
      end else
      begin
        Instances.Change(CountInstanses, p, TexturesZero[FSizeBit]);
      end;

      inc(FCountInstanses);

      inc(bits);
      if bits = 8 then
      begin
        bits := 0;
        inc(symbs);
      end;

    end;
    inc(count);
  end;
  Result := count;
end;

function TBitsDataPresentation.GetColor: TColor4f;
begin
  Result := FColor0;
end;

function TBitsDataPresentation.GetColorBackgrnd: TColor4f;
begin
  if FSizeBit > MAX_SIZE_BIT_IN_PIXELS then
  begin
    Result := FColorBackground;
  end else
  begin
    Result := FColorBackMinBits;
  end;
end;

function TBitsDataPresentation.GetColorBackMinBits: TGuiColor;
begin
  Result := ColorFloatToByte(FColorBackMinBits).value;
end;

function TBitsDataPresentation.GetColorOne: TGuiColor;
begin
  Result := ColorFloatToByte(Color1).value;
end;

class function TBitsDataPresentation.GetDefaultSize: int32;
begin
  Result := 10;
end;

class function TBitsDataPresentation.GetMinSize: int32;
begin
  Result := 1;
end;

function TBitsDataPresentation.GetSize: int32;
begin
  Result := FSizeBit;
end;

procedure TBitsDataPresentation.IncSize;
begin
  SizeBit := SizeBit + 1;
end;

function TBitsDataPresentation.Present(const Position: TVec2i; pData: pByte; LenData: int32; BeginOffset: int8): BSFloat;
begin
  inherited;
  if FSizeBit > MAX_SIZE_BIT_IN_PIXELS then
    Result := DoPresentByTextures(Position, pData, LenData, BeginOffset)
  else
    Result := DoPresentByPoints(Position, pData, LenData, BeginOffset);
end;

procedure TBitsDataPresentation.SetColor(const Value: TColor4f);
begin
  FColor0 := Value;
  LoadTextures;
end;

procedure TBitsDataPresentation.SetColor1(const Value: TColor4f);
begin
  FColor1 := Value;
  LoadTextures;
end;

procedure TBitsDataPresentation.SetColorBackMinBits(const Value: TGuiColor);
var
  cl: TColor4f;
begin
  cl := ColorByteToFloat(Value);
  cl.a := 1.0;
  FColorBackMinBits := cl;
end;

procedure TBitsDataPresentation.SetColorOne(const Value: TGuiColor);
var
  cl: TColor4f;
begin
  cl := ColorByteToFloat(Value);
  cl.a := 1.0;
  Color1 := cl;
end;

procedure TBitsDataPresentation.SetDefaultSize;
begin
  SizeBit := GetDefaultSize;
end;

procedure TBitsDataPresentation.SetDefaultSizeCell;
var
  w: int32;
begin
  if FIntervalReader.IntervalSize > 0 then
    FCharacters := FIntervalReader.IntervalSize
  else
    FCharacters := 8;
  FWidthCharacter := FSizeBit;
  if FSizeBit < 6 then
  begin
    FWidthCol := FWidthCharacter * Characters;
    FHeightRow := FSizeBit;
    w := FWidthCol;
  end else
  begin
    FHeightRow := FSizeBit+1;
    if FIntervalReader.IntervalSize > 0 then
    begin
      w := FWidthCharacter * Characters;
      FWidthCol := w + FWidthCharacter;
    end else
    begin
      FWidthCol := FWidthCharacter * Characters;
      w := FWidthCol;
    end;
  end;
  inherited;
  FWidthColOnlyData := w;
  FBitsInCharacter := 1;
end;

procedure TBitsDataPresentation.SetDirPictures(const Value: string);
var
  path: string;
begin
  if FDirPictures = Value then
    exit;
  path := IncludeTrailingPathDelimiter(Value);
  if not FileExists(AppPath + path + 'bit_off8x8.png') then
    exit;
  FDirPictures := path;
  LoadTextures;
end;

procedure TBitsDataPresentation.SetMaxSize;
begin
  SizeBit := MAX_SIZE_BIT;
end;

procedure TBitsDataPresentation.SetMinSize;
begin
  SizeBit := 1;
end;

procedure TBitsDataPresentation.SetSize(const Value: int32);
begin
  SizeBit := Value;
end;

procedure TBitsDataPresentation.SetSizeBit(const Value: int32);
begin
  FSizeBit := Clamp(MAX_SIZE_BIT, 1, Value);
  FGrid.UpdateScrollbarMetrics;
  CheckColorBackground;
  //SetDefaultSizeCell;
end;

procedure ShiftToLeft(SizeData: int64; pM: PByte; SizeShift: int32);
var
  mask_left: uint8;
  mask_right: uint8;
  size_bytes: int32;
  mod_bits, mod_bits_8, count_mod: uint8;
  i, count_i: int32;
  pInt32, prev: PInteger;
begin
  size_bytes := SizeShift shr 3;
  mod_bits := SizeShift mod 8;
  if mod_bits = 0 then
  begin
    for i := size_bytes to SizeData - 1 do
      pM[i-size_bytes] := pM[i];
  end else
  begin
    mod_bits_8 := 8 - mod_bits;
    pInt32 := PInteger(pM + size_bytes);
    prev := PInteger(pM);
    mask_right := MASK_BYTE_PART[mod_bits]; // (round(power(2, mod_bits)) - 1);
    mask_left := not (mask_right shl mod_bits_8);
    count_i := (SizeData shr 2);
    count_mod := (SizeData mod 4);
    for i := size_bytes to count_i - 2 do
    begin
      prev^ := pInt32^ shr mod_bits;
      (pByte(prev) + 3)^ := ((pByte(prev) + 3)^ and mask_left) + ((pByte(pInt32) + 4)^ and mask_right) shl mod_bits_8;
      inc(prev); inc(pInt32);
    end;
    { последний int }
    if count_i > 0 then
    begin
      prev^ := pInt32^ shr mod_bits;
      if count_mod > 0 then
        (pByte(prev) + 3)^ := ((pByte(prev) + 3)^ and mask_left) + ((pByte(pInt32) + 4)^ and mask_right) shl mod_bits_8;
      inc(prev); inc(pInt32);
    end;
    { остаток от int }
    for i := 0 to count_mod - 2 do
    begin
      (pByte(prev))^ := (pByte(pInt32)^ shr mod_bits) + ((pByte(pInt32) + 1)^ and mask_right) shl mod_bits_8;
      inc(pByte(prev)); inc(pByte(pInt32));
    end;
    if count_mod > 0 then
      (pByte(prev))^ := (pByte(pInt32)^ shr mod_bits);
  end;
end;

{ TIntervalReader }

constructor TIntervalReader.Create;
begin
  inherited;
  IntervalSize := 8;
  //IntervalSize := 31;
end;

function TIntervalReader.GetIntervalSizeInBytes: int32;
begin
  if FIntervalSize = 0 then
    Result := SizeData
  else
    Result := FIntervalSizeInBytes;
end;

function TIntervalReader.ReadNext: boolean;
var
  pos, pos_mod, bytes_read: int32;
begin
  if Position >= SizeDataBits then
    exit(false);
  pos := Position shr 3;
  pos_mod := Position mod 8;
  Result := true;
  {if FIntervalSize = 0 then
    begin
    FSizeReaded := SizeDataBits - Position;
    FSizeReadedBytes := FSizeReaded div 8;
    if (FSizeReaded mod 8 > 0) then
      inc(FSizeReadedBytes);
    bytes_read := (FSizeReaded + pos_mod) div 8;
    if (FSizeReaded + pos_mod) mod 8 > 0 then
      inc(bytes_read);
    if pos + bytes_read > SizeData then
      bytes_read := SizeData - pos;
    // (from begin ?) or (align on byte ?)
    if (Position = 0) or (pos_mod = 0) then
      begin
      ResultRead := @Data[pos];
      end else
      begin // offset on bits
      move(Data[pos], FResultRead[0], bytes_read);
      ShiftToLeft(bytes_read, @FResultRead[0], pos_mod);
      ResultRead := @Data[pos];
      end;
    end else }
  begin
    FSizeReaded := FIntervalSize;
    if Position + FIntervalSize > SizeDataBits then
      FSizeReaded := SizeDataBits - Position;
    FSizeReadedBytes := FSizeReaded shr 3;
    if (FSizeReaded mod 8 > 0) then
      inc(FSizeReadedBytes);
    bytes_read := (FSizeReaded + pos_mod) shr 3;
    if (FSizeReaded  + pos_mod) mod 8 > 0 then
      inc(bytes_read);
    if pos + bytes_read > SizeData then
      bytes_read := SizeData - pos;
    // (from begin ?) or (align on byte ?)
    if (Position = 0) or (Position mod 8 = 0) then
    begin
      ResultRead := @Data[pos];
    end else
    begin // offset on bits
      move(Data[pos], FResultRead[0], bytes_read);
      ShiftToLeft(bytes_read, @FResultRead[0], pos_mod);
      ResultRead := @FResultRead[0];
    end;
  end;
  inc(Position, FSizeReaded);
end;

procedure TIntervalReader.SetData(pData: pByte; LenData: int32; ABeginOffset: int8);
begin
  Data := pData;
  SizeData := LenData shr 3;
  if LenData mod 8 > 0 then
    inc(SizeData);
  SizeDataBits := LenData;
  FOffsetBegin := ABeginOffset;
  Position := ABeginOffset;
  if (FIntervalSizeInBytes = 0) or (SizeData + 2 > SizeArr) then
  begin
    SizeArr := SizeData + 2;
    SetLength(FResultRead, SizeArr);
  end;
end;

procedure TIntervalReader.SetIntervalSize(const Value: int32);
begin
  FIntervalSize := Value;
  if FIntervalSize <= 0 then
    FIntervalSize := 8;
  FIntervalSizeInBytes := FIntervalSize div 8;
  if (FIntervalSize mod 8 > 0) then
    inc(FIntervalSizeInBytes);
  SizeArr := FIntervalSizeInBytes + 2;
  SetLength(FResultRead, SizeArr);
end;

{ TGridDataPresentation.TEasterEgg }

function TGridDataPresentation.TEasterEgg.AddPart(Velos: BSFloat;
  const Dir: TVec2f): PPart;
begin
  new(Result);
  Result.Health := MAX_HEALTH;
  Result.Velosity := BSConfig.VoxelSize*Velos;
  Result.Direction := dir;
  //Result.NodeSt := nil;
end;

constructor TGridDataPresentation.TEasterEgg.Create(ADataSrc: TGridDataPresentation);
begin
  FDataSrc := ADataSrc;
  TBTimer.UpdateTimer(LastTime);
  Particles := TListVec<PPart>.Create;
  //Bombs := TListVec<PBomb>.Create(@PtrCmp);
  //Directions := TListVec<TVec2f>.Create;
  //Velosity := TListVec<BSFloat>.Create;
  //Selector := TBlackSharkRTree.Create;
  EmptyTask := CreateEmptyTask(GUIThread);
  EmptyTaskObsrv := CreateEmptyTaskObserver(EmptyTask, OnUpdateValue, GUIThread);
end;

destructor TGridDataPresentation.TEasterEgg.Destroy;
var
  i: int32;
begin
  EmptyTaskObsrv := nil;
  EmptyTask := nil;
  //Velosity.Free;
  //Directions.Free;
  for i := 0 to Particles.Count - 1 do
    dispose(Particles.Items[i]);
  {for i := 0 to Bombs.Count - 1 do
    dispose(Bombs.Items[i]);
  Bombs.Free;}
  Particles.Free;
  //Selector.Free;
  inherited;
end;

{procedure TGridDataPresentation.TEasterEgg.DropBomb(Power: int32; const Pos: TVec2f);
var
  b: PBomb;
  pw: BSFloat;
begin
  pw := FDataSrc.Grid.Canvas.BSConfig.VoxelSize * Power * 8;
  new(b);
  b.BurstBombTime := TThreadTimer.CurrentTime;
  b.PosBomb := Pos;
  b.Area.Middle := vec3(Pos.x * FDataSrc.CanvasObjectMap.Canvas.BSConfig.VoxelSize,
    -Pos.y * FDataSrc.CanvasObjectMap.Canvas.BSConfig.VoxelSize, 0.0);
  b.Area.Max := b.Area.Middle + vec3(pw, pw, 0);
  b.Area.Min := b.Area.Middle - vec3(pw, pw, 0);
  b.Power := clamp(MAX_POWER, 1, Power);
  b.MaxTimeLive := b.Power * 500;
  Bombs.Add(b);
end; }

procedure TGridDataPresentation.TEasterEgg.OnUpdateValue(const Value: byte);
var
  i: int32;
  pos: TVec3f;
  size_screen_half: TVec2f;
  part: PPart;
begin
  if LastTime.Counter - TBTimer.CurrentTime.Counter < 16 then
    exit;

  size_screen_half := vec2(FDataSrc.CanvasObjectMap.Width*0.5, FDataSrc.CanvasObjectMap.Height*0.5) * BSConfig.VoxelSize;

  LastTime := TBTimer.CurrentTime;

  //if Bombs.Count > 0 then
  //  ProcessBomb;

  for i := 0 to FDataSrc.Instances.CountParticle - 1 do
  begin
    pos := FDataSrc.Instances.Position[i];
    part := Particles.Items[i];

    pos := vec3(pos.x + (part.Velosity * part.Direction.x),
      pos.y + (part.Velosity * part.Direction.y), 0.0);
    if (abs(pos.x - size_screen_half.x) > size_screen_half.x) or (abs(pos.y + size_screen_half.y) > size_screen_half.y) then
    begin

      if part.Health = 0 then
        continue;

      if (abs(pos.x - size_screen_half.x) > size_screen_half.x) then
      begin
        part.Direction.x := -part.Direction.x;
        if pos.x < 0 then
          pos.x := 0.0
        else
          pos.x := size_screen_half.x*2;
      end else
      begin
        part.Direction.y := -part.Direction.y;
        if pos.y < 0 then
          pos.y := -size_screen_half.y*2
        else
          pos.y := 0.0;
      end;

    end;
    FDataSrc.Instances.Position[i] := pos;
  end;
end;

{procedure TGridDataPresentation.TEasterEgg.ProcessBomb;
var
  i, max_time_live: int32;
  fluct: TVec2f;
  time: TTimeCounter;
  b: PBomb;
  ln: TListVec<PNodeSpaceTree>;
  j: int32;
  part: PPart;
begin
  fluct := vec2(0.0, 0.0);
  for i := Bombs.Count - 1 downto 0 do
    begin
    b := Bombs.Items[i];
    time.Counter := LastTime.Counter - b.BurstBombTime.Counter;
    max_time_live := b.Power * 500;
    if time.Counter > max_time_live then
      begin
      Bombs.Remove(b);
      dispose(b);
      continue;
      end;

    fluct.x := fluct.x + Random(b.Power)*(1-time.Counter/max_time_live);
    fluct.y := fluct.y + Random(b.Power)*(1-time.Counter/max_time_live);

    ln := nil;

    Selector.SelectData(b.Area, ln);

    if ln <> nil then
      for j := 0 to ln.Count - 1 do
        begin
        part := (ln.Items[j].BB.TagPtr);
        if part.Health > 0 then
          begin
          if part.Health = MAX_HEALTH then
            begin
            part.Direction := VecNormalize(TVec2f(part.NodeSt.BB.Middle - b.Area.Middle));
            end;
          dec(part.Health);
          part.Velosity := part.Velosity + FDataSrc.Grid.Canvas.BSConfig.VoxelSize;
          //if part.Velosity > 0 then
          //if part.Health = 0 then
          //  begin
            //part.Direction := vec2(0.0, -1.0);
          //  end;
          end;
        end;
    end;
  //FDataSrc.CanvasObjectMap.Position2d := PositionParticles + fluct;
end;  }

procedure TGridDataPresentation.TEasterEgg.Run;
begin
  Randomize;
  PositionParticles := FDataSrc.CanvasObjectMap.Position2d;
  Update;
  if not EmptyTask.IsRun then
    EmptyTask.Run;
end;

procedure TGridDataPresentation.TEasterEgg.Stop;
var
  i: int32;
begin
  if EmptyTask.IsRun then
    EmptyTask.Stop;
  for i := 0 to Particles.Count - 1 do
    dispose(Particles.Items[i]);
  Particles.Count := 0;
  //Selector.Clear;
end;

procedure TGridDataPresentation.TEasterEgg.Update;
var
  i: int32;
  vec: TVec2f;
  vel: BSFloat;
  part: PPart;
  //pos: TVec3d;
begin
  if Particles.Count < FDataSrc.Instances.CountParticle then
    begin
    for i := Particles.Count to FDataSrc.Instances.CountParticle - 1 do
      begin
      vec := VecNormalize(vec2((Random(1000)/1000 - 0.5)*2.0, (Random(1000)/1000 - 0.5)*2.0));
      vel := 0;
      while vel = 0 do
        vel := Random(MAX_SPEED);
      part := AddPart(vel, vec);
      Particles.Add(part);
      //pos := FDataSrc.Instances.Position[i];
      //Selector.Add(Pointer(part), vec2d(pos.x, pos.y), vec2d(FDataSrc.WidthCharacterInScene,
      //  FDataSrc.FHeightRowInScene), part.NodeSt);
      end;
    end else
    begin
    for i := Particles.Count - 1 downto FDataSrc.Instances.CountParticle do
      begin
      //Selector.Remove(Particles.Items[i].NodeSt);
      dispose(Particles.Items[i]);
      end;
    Particles.Count := FDataSrc.Instances.CountParticle;
    end;
end;

{ TCommonGUIProperties }

function TCommonGUIProperties.GetColorUnit: TGuiColor;
begin
  Result := ColorFloatToByte(Color).value;
end;

procedure TCommonGUIProperties.SetColorUnit(const Value: TGuiColor);
var
  cl: TColor4f;
begin
  cl := ColorByteToFloat(Value);
  cl.a := 1.0;
  Color := cl;
end;

initialization
  TBControl.ControlRegister('GUI', TBGrid);
  TBGrid.RegisterPresentation(TGridAnsiDataPresentation);
  TBGrid.RegisterPresentation(TGridHexDataPresentation);
  TBGrid.RegisterPresentation(TBitsDataPresentation);


end.
