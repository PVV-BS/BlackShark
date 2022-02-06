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


{ the unit contains:
    - supports fonts TrueType loaded from files *.ttf, appropriately you can
    load any contours TrueType, for example, smiles (emoji);
    - it has own loader of TrueType fonts with accomplish of triangulation and
    rasterization (without the use of external tools);
    - characters output only by a mesh (allows to get good quality of big symbols);
    - characters output from a texture (allows to get relative good quality of
    small symbols) beforehand prepared by the rasterizator; the texture consists
    only of alpha (GL_ALPHA), that is why a font can reserve very large textures;
    - supports mixed mode (with the use a special class TTrueTypeRasterFont)
    allowing automaticaly for a size of font a smaller threshold to display from
    a texture and if the size more threshold to display from meshes;
    - for sharing between consumers and managing the lifetime fonts have automatic
    reference counting;

    For out a text exists special wrappers, for example TGraphicObjectText - out 2d
  a text in 3d dimensions, or TCanvasText, in this case TCanvasText
  is also a wrapper over the TGraphicObjectText.

    Font displayed wrong (for small sizes a size of some chars can swim) if size
    in pixels is odd;


  TODO:

    Currently it uses for resample from a big to a small glyph a linear algorithm
  (see below TTrueTypeRasterFont.Triangulate(...) FRasterizator.Canvas.Resample),
  but it do not gives a desirable quality, that is why the challenge remains
  opened. Any ideas? (I hear about a hinting and Free Type library, but I want a
  silver bulet, at least, a little time and a little profit) :)

    Add an option adjusting of contrast.

    It need to process of a table 'kern' in True type specification, appropriately
  need to add a kerning.

 }

unit bs.font;

{$I BlackSharkCfg.inc}

{$ifdef DEBUG}
  {.$define DEBUG_FONT}
{$endif}

interface

uses
    Classes
  , SysUtils
  , bs.basetypes
  , bs.events
  , bs.collections
  , bs.texture
  , bs.shader
  , bs.tesselator
  , bs.graphics
  ;

const
  { digital standart for a size one point = 1/72 english inch (25.4 mm),
    that is 0.352777 equal one point in mm }
  TYPOGRAPHY_POINT_EURO = 0.352777;

type

  TTableSymbols = (
  {  Macintosh 'cmap' Table.
    PlatformID = 1 and EncodingID = 0 (Macintosh), the  platformSpecificID is
    a QuickDraw script code. Note that the use of the Macintosh  platformID
    is currently discouraged. Subtables with a Macintosh platformID are
    only required for backwards compatibility with QuickDraw and will be
    synthesized from Unicode-based subtables if ever needed }
    tsMacintoshDefault,
    tsUnicodeCS2,
    tsUnicodeCS4
  );

  TCodePage = (
    cpUnicode,
    cpLatin1,                // 1252
    cpLatin2,                // Eastern Europe 1250
    cpCyrillic,              // 1251
    cpGreek,                 // 1253
    cpTurkish,               // 1254
    cpHebrew,                // 1255
    cpArabic,                // 1256
    cpWindowsBaltic,         // 1257
    cpVietnamese,            // 1258
    cpThai,                  // 874
    cpJapan,                 // 932
    cpChineseSingapore,      // 936
    cpKoreanWansung,         // 949
    cpChineseTaiwanHongKong, // 950
    cpKoreanJohab,           // 1361
    cpIBMGreek,              // 869
    cpMSDOSRussian,          // 866
    cpMSDOSNordic,           // 865
    cpArabicOEM,             // 864
    cpMSDOSCanadianFrench,   // 863
    cpHebrewOEM,             // 862
    cpMSDOSIcelandic,        // 861
    cpMSDOSPortuguese,       // 860
    cpIBMTurkish,            // 857
    cpIBMCyrillic,           // 855
    cpLatin2OEM,             // 852
    cpMSDOSBaltic,           // 775
    cpGreekOEM,              // 737
    cpArabicASMO_708,        // 708
    cpLatin1OEM,             // 850
    cpUS                     // 437
  );

  TUnicodeRange = (
    urBasicLatin_0000_007F,            // 0
    urLatin_1_Supplement_0080_00FF,    // 1
    urLatinExtended_A_0100_017F,       // 2
    urLatinExtended_B_0180_024F,       // 3
    urIPAExtensions_0250_02AF,         // 4
   	urPhoneticExtensions_1D00_1D7F,
   	urPhoneticExtensions_Supplement_1D80_1DBF,
    urSpacing_Modifier_Letters_02B0_02FF, // 5
   	urModifier_Tone_Letters_A700_A71F,
    urCombining_Diacritical_Marks_0300_036F, // 6
   	urCombining_Diacritical_Marks_Supplement_1DC0_1DFF,
    urGreek_and_Coptic_0370_03FF,            // 7
    urCoptic_2C80_2CFF,                 // 8
    urCyrillic_0400_04FF,               // 9
   	urCyrillic_Supplement_0500_052F,
   	urCyrillic_Extended_A_2DE0_2DFF,
   	urCyrillic_Extended_B_A640_A69F,
    urArmenian_0530_058F,               // 10
    urHebrew_0590_05FF,                 // 11
    urVai_A500_A63F,                    // 12
    urArabic_0600_06FF,                 // 13
   	urArabic_Supplement_0750_077F,
    urNKo_07C0_07FF,                    // 14
    urDevanagari_0900_097F,             // 15
    urBengali_0980_09FF,                // 16
    urGurmukhi_0A00_0A7F,               // 17
    urGujarati_0A80_0AFF,               // 18
    urOriya_0B00_0B7F,                  // 19
    urTamil_0B80_0BFF,                  // 20
    urTelugu_0C00_0C7F,                 // 21
    urKannada_0C80_0CFF,                // 22
    urMalayalam_0D00_0D7F,              // 23
    urThai_0E00_0E7F,                   // 24
    urLao_0E80_0EFF,                    // 25
    urGeorgian_10A0_10FF,               // 26
   	urGeorgian_Supplement_2D00_2D2F,    // 26
    urBalinese_1B00_1B7F,               // 27
    urHangul_Jamo_1100_11FF,            // 28
    urLatin_Extended_Additional_1E00_1EFF, // 29
   	urLatin_Extended_C_2C60_2C7F,      // 29
   	urLatin_Extended_D_A720_A7FF,      // 29
    urGreek_Extended_1F00_1FFF,        // 30
    urGeneral_Punctuation_2000_206F,   // 31
   	urSupplemental_Punctuation_2E00_2E7F, // 31
    urSuperscripts_And_Subscripts_2070_209F, // 32
    urCurrency_Symbols_20A0_20CF,      // 33
    urCombining_Diacritical_Marks_For_Symbols_20D0_20FF, // 34
    urLetterlike_Symbols_2100_214F,    // 35
    urNumber_Forms_2150_218F,          // 36
    urArrows_2190_21FF,                // 37
   	urSupplemental_Arrows_A_27F0_27FF, // 37
   	urSupplemental_Arrows_B_2900_297F, // 37
   	urMiscellaneous_Symbols_and_Arrows_2B00_2BFF, // 37
    urMathematical_Operators_2200_22FF,// 38
   	urSupplemental_Mathematical_Operators_2A00_2AFF, // 38
   	urMiscellaneous_Mathematical_Symbols_A_27C0_27EF, // 38
   	urMiscellaneous_Mathematical_Symbols_B_2980_29FF, // 38
    urMiscellaneous_Technical_2300_23FF, // 39
    urControl_Pictures_2400_243F, // 40
    urOptical_Character_Recognition_2440_245F, // 41
    urEnclosed_Alphanumerics_2460_24FF, // 42
    urBox_Drawing_2500_257F, // 43
    urBlock_Elements_2580_259F, // 44
    urGeometric_Shapes_25A0_25FF, // 45
    urMiscellaneous_Symbols_2600_26FF, // 46
    urDingbats_2700_27BF, // 47
    urCJK_Symbols_And_Punctuation_3000_303F, // 47
    urHiragana_3040_309F, // 49
    urKatakana_30A0_30FF, // 50
   	urKatakana_Phonetic_Extensions_31F0_31FF, // 50
    urBopomofo_3100_312F, // 51
   	urBopomofo_Extended_31A0_31BF, // 51
    urHangul_Compatibility_Jamo_3130_318F, // 52
    urPhags_pa_A840_A87F, // 53
    urEnclosed_CJK_Letters_And_Months_3200_32FF, // 54
    urCJK_Compatibility_3300_33FF, // 55
    urHangul_Syllables_AC00_D7AF, // 56
    urNon_Plane_0_D800_DFFF,  // 57
    urPhoenician_10900_1091F, // 58
    urCJK_Unified_Ideographs_4E00_9FFF, // 59
   	urCJK_Radicals_Supplement_2E80_2EFF, // 59
   	urKangxi_Radicals_2F00_2FDF, // 59
   	urIdeographic_Description_Characters_2FF0_2FFF, // 59
   	urCJK_Unified_Ideographs_Extension_A_3400_4DBF, // 59
   	urCJK_Unified_Ideographs_Extension_B_20000_2A6DF, // 59
   	urKanbun_3190_319F, // 59
    urPrivate_Use_Area_plane_0_E000_F8FF, // 60
    urCJK_Strokes_31C0_31EF, // 61
   	urCJK_Compatibility_Ideographs_F900_FAFF, //61
   	urCJK_Compatibility_Ideographs_Supplement_2F800_2FA1F, // 61
    urAlphabetic_Presentation_Forms_FB00_FB4F, // 62
    urArabic_Presentation_Forms_A_FB50_FDFF, // 63
    urCombining_Half_Marks_FE20_FE2F, // 64
    urVertical_Forms_FE10_FE1F,   // 65
   	urCJK_Compatibility_Forms_FE30_FE4F, // 65
    urSmall_Form_Variants_FE50_FE6F, // 66
    urArabic_Presentation_Forms_B_FE70_FEFF, // 67
    urHalfwidth_And_Fullwidth_Forms_FF00_FFEF, // 68
    urSpecials_FFF0_FFFF, // 69
    urTibetan_0F00_0FFF, // 70
    urSyriac_0700_074F, // 71
    urThaana_0780_07BF, // 72
    urSinhala_0D80_0DFF, // 73
    urMyanmar_1000_109F, // 74
    urEthiopic_1200_137F, // 75
   	urEthiopic_Supplement_1380_139F, // 75
   	urEthiopic_Extended_2D80_2DDF, // 75
    urCherokee_13A0_13FF, // 76
    urUnified_Canadian_Aboriginal_Syllabics_1400_167F, // 77
    urOgham_1680_169F, // 78
    urRunic_16A0_16FF, // 79
    urKhmer_1780_17FF, // 80
   	urKhmer_Symbols_19E0_19FF, // 80
    urMongolian_1800_18AF, // 81
    urBraille_Patterns_2800_28FF, // 82
    urYi_Syllables_A000_A48F, // 83
   	urYi_Radicals_A490_A4CF, // 83
    urTagalog_1700_171F, // 84
   	urHanunoo_1720_173F, // 84
   	urBuhid_1740_175F,  // 84
   	urTagbanwa_1760_177F, // 84
    urOld_Italic_10300_1032F, // 85
    urGothic_10330_1034F, // 86
    urDeseret_10400_1044F, // 87
    urByzantine_Musical_Symbols_1D000_1D0FF, // 88
   	urMusical_Symbols_1D100_1D1FF, // 88
   	urAncient_Greek_Musical_Notation_1D200_1D24F, // 88
    urMathematical_Alphanumeric_Symbols_1D400_1D7FF, // 89
    urPrivate_Use_plane_15_FF000_FFFFD, // 90
   	urPrivate_Use_plane_16_100000_10FFFD, // 90
    urVariation_Selectors_FE00_FE0F, // 91
   	urVariation_Selectors_Supplement_E0100_E01EF, // 91
    urTags_E0000_E007F, // 92
    urLimbu_1900_194F, // 93
    urTai_Le_1950_197F, // 94
    urNew_Tai_Lue_1980_19DF, // 95
    urBuginese_1A00_1A1F, // 96
    urGlagolitic_2C00_2C5F, // 97
    urTifinagh_2D30_2D7F, // 98
    urYijing_Hexagram_Symbols_4DC0_4DFF, // 99
    urSyloti_Nagri_A800_A82F, // 100
    urLinear_B_Syllabary_10000_1007F, // 101
   	urLinear_B_Ideograms_10080_100FF, // 101
   	urAegean_Numbers_10100_1013F, // 101
    urAncient_Greek_Numbers_10140_1018F, // 102
    urUgaritic_10380_1039F, // 103
    urOld_Persian_103A0_103DF, // 104
    urShavian_10450_1047F,  // 105
    urOsmanya_10480_104AF, // 106
    urCypriotSyllabary_10800_1083F, // 107
    urKharoshthi_10A00_10A5F, // 108
    urTai_Xuan_Jing_Symbols_1D300_1D35F, // 109
    urCuneiform_12000_123FF, //110
   	urCuneiform_Numbers_and_Punctuation_12400_1247F, // 110
    urCounting_Rod_Numerals_1D360_1D37F, // 111
    urSundanese_1B80_1BBF, // 112
    urLepcha_1C00_1C4F, // 113
    urOl_Chiki_1C50_1C7F, // 114
    urSaurashtra_A880_A8DF, // 115
    urKayah_Li_A900_A92F, // 116
    urRejang_A930_A95F, // 117
    urCham_AA00_AA5F, // 118
    urAncient_Symbols_10190_101CF, // 119
    urPhaistos_Disc_101D0_101FF, // 120
    urCarian_102A0_102DF, // 121
   	urLycian_10280_1029F, // 121
   	urLydian_10920_1093F, // 121
    urDomino_Tiles_1F030_1F09F, // 122
   	urMahjong_Tiles_1F000_1F02F // 122
  );

  { The record is saving a property key in raster Black Shark font file }

  TBaseKeyInfo = packed record
    CodeUTF16: uint16;
    Rect: TRectBSi;
  end;

  PGlyph = ^TGlyph;
  TGlyph = record
    xMin, yMin, xMax, yMax: BSFloat;
    Points: TBlackSharkTesselator.TListPoints.TSingleListHead;
    Contours: TBlackSharkTesselator.TListContours.TSingleListHead;
  end;

  PKeyInfo = ^TKeyInfo;
  TKeyInfo = packed record
    Glyph: PGlyph;
    GlyphIndex: int32;
    Code: uint32;
    { indexes triangles }
    Indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
    case byte of
    0: (
      // rect glyph on texture for raster fonts
      Rect: TRectBSf;
      // texture coordinates
      UV: TRectBSf);
    1: (TextureRect: TTextureRect);
  end;

  TListGlyphs = TListVec<PGlyph>;

  IFontTexture = interface
    function GetTexture: IBlackSharkTexture; stdcall;
    function GetRect(Code: int32; Table: TTableSymbols; out Rect: TTextureRect): boolean; stdcall;
    procedure AddRect(Code: uint32; const Rect: TTextureRect; Table: TTableSymbols); stdcall;
    function GetOnChangeEvent: IBEmptyEvent; stdcall;
    procedure BeginUpdate; stdcall;
    function EndUpdate(FontSizeInPixels: int32; Reload: boolean): boolean; stdcall;
    property Texture: IBlackSharkTexture read GetTexture;
    property OnChangeEvent: IBEmptyEvent read GetOnChangeEvent;
  end;

  { TFontTexture }

  TFontTexture = class(TObject, IFontTexture)
  private
    type
      PFontRect = ^TFontRect;
      TFontRect = record
        Code: uint32;
        TextureRect: TTextureRect;
      end;
  private
    FTexture: IBlackSharkTexture;
    FRects: array[TTableSymbols] of TListVec<PFontRect>;
    FCountRef: int32;
    LastFontSize: int32;
    CountUpdate: int32;
    FOnChangeEvent: IBEmptyEvent;
  protected
    {$ifdef FPC}
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} iid : tguid;out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    {$else}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    {$endif}
    function GetTexture: IBlackSharkTexture; stdcall;
    function GetOnChangeEvent: IBEmptyEvent; stdcall;
    procedure BeginUpdate; stdcall;
    function EndUpdate(FontSizeInPixels: int32; Reload: boolean): boolean; stdcall;
  public
    constructor Create(AWidth: int32; AHeight: int32; TrilinearFilter: boolean; const Name: string);
    destructor Destroy; override;
    function GetRect(Code: int32; Table: TTableSymbols; out Rect: TTextureRect): boolean; stdcall;
    procedure AddRect(Code: uint32; const Rect: TTextureRect; Table: TTableSymbols); stdcall;
    property Texture: IBlackSharkTexture read GetTexture;
    property CountRef: int32 read FCountRef;
    property OnChangeEvent: IBEmptyEvent read GetOnChangeEvent;
  end;

  { TODO: TBSFontStyle }
  TBSFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);

  TBSFontStyleSet = set of TBSFontStyle;

  { IBlackSharkFont }

  IBlackSharkFont = interface
    function GetKey(CodeUTF16: uint16): PKeyInfo; stdcall;
    function GetKeyWideChar(CodeUTF16: WideChar): PKeyInfo; stdcall;
    function GetAverageWidth: BSFloat; stdcall;
    function GetAverageHeight: BSFloat; stdcall;
    function GetOnChangeEvent: IBEmptyEvent; stdcall;
    function GetIsVectoral: boolean; stdcall;
    function GetSizeInPixels: int16; stdcall;
    procedure SetSizeInPixels(const Value: int16); stdcall;
    function GetTexture: IFontTexture; stdcall;
    procedure SetTexture(AValue: IFontTexture); stdcall;
    procedure BeginSelectChars; stdcall;
    function EndSelectChars: boolean; stdcall;
    function GetSize: BSFloat; stdcall;
    procedure SetSize(const Value: BSFloat); stdcall;
    function GetCountKeys: int32; stdcall;
    procedure GetTextSize(const Text: string; out CountChars: int32;
      out TextWidth: BSFloat; out TextHeight: BSFloat;
      out MaxLenWordInChars: int32; out MaxLenWordInPixels: BSFloat;
      DistanceBWChars: BSFloat); stdcall;
    { raw data (do not triangulated) from font file }
    function GetRawKey(CodeUTF16: uint16): PKeyInfo; stdcall;
    function GetCodePage: TCodePage; stdcall;
    procedure SetCodePage(const Value: TCodePage); stdcall;
    function GetName: string; stdcall;
    property AverageWidth: BSFloat read GetAverageWidth;
    property AverageHeight: BSFloat read GetAverageHeight;
    property OnChangeEvent: IBEmptyEvent read GetOnChangeEvent;
    property IsVectoral: boolean read GetIsVectoral;
    property SizeInPixels: int16 read GetSizeInPixels write SetSizeInPixels;
    property Texture: IFontTexture read GetTexture write SetTexture;
    property Key[CodeUTF16: uint16]: PKeyInfo read GetKey;
    property KeyByWideChar[CodeUTF16: WideChar]: PKeyInfo read GetKeyWideChar;
    property Size: BSFloat read GetSize write SetSize;
    property CountKeys: int32 read GetCountKeys;
    property CodePage: TCodePage read GetCodePage write SetCodePage;
    property Name: string read GetName;
  end;

  TClassFont = class of TBlackSharkCustomFont;

  { TBlackSharkCustomFont }

  TBlackSharkCustomFont = class(TObject, IBlackSharkFont)
  public
    const
      { the parameters of rasterization by default }
      SIZE_DESTINATION_CANVAS_DEFAULT = 12;
      SIZE_SOURCE_CANVAS_DEFAULT = 256;
      SIZE_BORDER = 1;
  private
    FFileName: string;
    FShortName: string;
    FCodePage: TCodePage;
    FRefCount: int32;
    FPixelsPerInch: BSFloat;
    FFontStyle: TBSFontStyleSet;
    FID: uint32;
    //CalculatingCountours: boolean;
    FUsers: int32;
    procedure SetPixelsPerInch(const Value: BSFloat);
    procedure DoCreateTexture(FontSize: int32);
  protected
    RawDataFont: TBlackSharkCustomFont;
    FTexture: IFontTexture;
    Map: TBlackSharkTextureMap;
    // glyph data
    FGlyphs: TListGlyphs;
    FKeys: array[TTableSymbols] of TListVec<PKeyInfo>;
    FAverageWidth: BSFloat;
    FAverageHeight: BSFloat;
    FScale: BSFloat;
    FSize: BSFloat;
    FSizeInPixels: int16;
    FIsVectoral: boolean;
    FOnChangeEvent: IBEmptyEvent;
    WasTriangulated: boolean;
    Selecting: boolean;
    FCountGlyphs: int32;
    { for convert from raw font }
    ToSelfScale: BSFloat;
    ObserverChangeTexture: IBEmptyEventObserver;
    {$ifdef DEBUG_FONT}
    CountTimeTriangulate: uint32;
    CountCalcContours: uint32;
    {$endif}
    // the top of capital letters
    //FTopCapital: BSFloat;
    // the top of small letters
    //FTopSmall: BSFloat;
    // the bottom of capital letters
    //FBottomCapital: BSFloat;
    // the bottom of small letters
    //FBottomSmall: BSFloat;
    // the bottom of "legged" small letters like "p", "q", "g", "j" & "y"
    //FBottomLegged: BSFloat;
    function AddPair(TableSymbols: TTableSymbols; Code: uint32; IndexToGlyph: int32): PKeyInfo;
    function AddGlyph(Index: int32): PGlyph;
    procedure CheckBoundary(Glyph: PGlyph); inline;
    procedure Change;
    procedure SetIsVectoral(AValue: boolean);
    procedure CalcScale;
    { create texture for the font }
    procedure CreateTexture;
    { it calculate all contours; if the font textured then generated glyphs }
    procedure CalcContours; virtual;
    {$ifdef FPC}
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} iid : tguid;out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    {$else}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    {$endif}
    function GetKey(CodeUTF16: uint16): PKeyInfo; stdcall;
    function GetKeyWideChar(CodeUTF16: WideChar): PKeyInfo; stdcall;
    function GetAverageWidth: BSFloat; stdcall;
    function GetAverageHeight: BSFloat; stdcall;
    function GetOnChangeEvent: IBEmptyEvent; stdcall;
    function GetIsVectoral: boolean; stdcall;
    function GetSizeInPixels: int16; stdcall;
    procedure SetSizeInPixels(const Value: int16); stdcall;
    function GetTexture: IFontTexture; stdcall;
    procedure SetTexture(AValue: IFontTexture); stdcall;
    function GetSize: BSFloat; stdcall;
    procedure SetSize(const Value: BSFloat); virtual; stdcall;
    function GetCountKeys: int32; stdcall;
    function GetRawKey(CodeUTF16: uint16): PKeyInfo; stdcall;
    function GetCodePage: TCodePage; stdcall;
    procedure SetCodePage(const Value: TCodePage); stdcall;
    function GetName: string; stdcall;
    procedure OnChangeTexture(const {%H-}Value: BData); virtual;
  public
    constructor Create(const AName: string); virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Assign(Font: TBlackSharkCustomFont); virtual;
    { is a load of font from a file }
    function Load(const FileName: string): boolean; virtual;
    function Save(const FileName: string): boolean; virtual;
    procedure Triangulate({%H-}Key: PKeyInfo); virtual;
    procedure Clear; virtual;
    procedure BeginSelectChars; virtual; stdcall;
    function EndSelectChars: boolean; virtual; stdcall;
    { return size text in pixels where empty symbols (for example the blank)
      accounted for as AverageWidth;
        - DistanceBWChars - count missed pixels between chars used in a text
      processor in a time build words; this number take into account when
      calculeted TextWidth; }
    procedure GetTextSize(const Text: string; out CountChars: int32; out TextWidth: BSFloat;
      out TextHeight: BSFloat; out MaxLenWordInChars: int32;
      out MaxLenWordInPixels: BSFloat; DistanceBWChars: BSFloat); stdcall;
    { Recalculate for evry Key relative texture Width and Height UV coordinates }
    procedure UpdateUV;
    property Key[CodeUTF16: uint16]: PKeyInfo read GetKey;
    property KeyByWideChar[CodeUTF16: WideChar]: PKeyInfo read GetKeyWideChar;
    property Glyphs: TListGlyphs read FGlyphs;
    property CountKeys: int32 read GetCountKeys;
    { Texture }
    property Texture: IFontTexture read GetTexture write SetTexture;
    property FileName: string read FFileName;
    property ShortName: string read FShortName;
    { size font in points }
    property Size: BSFloat read GetSize write SetSize;
    { size font in pixels }
    property SizeInPixels: int16 read GetSizeInPixels write SetSizeInPixels;
    property PixelsPerInch: BSFloat read FPixelsPerInch write SetPixelsPerInch;
    property CodePage: TCodePage read FCodePage write SetCodePage;
    property IsVectoral: boolean read GetIsVectoral;
    property ID: uint32 read FID;
    { TODO: FontStyle }
    property FontStyle: TBSFontStyleSet read FFontStyle write FFontStyle;
    property Users: int32 read FUsers;
    { for debug only }
    property RawData: TBlackSharkCustomFont read RawDataFont;
    property OnChangeEvent: IBEmptyEvent read GetOnChangeEvent;
    property AverageWidth: BSFloat read GetAverageWidth;
    property AverageHeight: BSFloat read GetAverageHeight;
    property RefCount: int32 read FRefCount;
  end;

  { TTrueTypeFont
    The class presents only a vectoral text }

  TTrueTypeFont = class(TBlackSharkCustomFont)
  private
    type
      TFileIndexesHeader = packed record
        Version: byte;
        CountGlyphs: int32;
      end;
      TKeyHeader = packed record
        Code: int32;
        CountIndexes: int32;
      end;
    const
      VER_FILE_IND: uint8 = 1;
  private
    FSaveIndexes: boolean;
    procedure ClearRaw;
    procedure SaveInd;
    procedure LoadInd;
    function GetFileInd: string;
  protected
    {FMaxHeight: int16;
    FMaxWidth: int16;
    FMinHeight: int16;
    FMinWidth: int16; }
    FQuality: BSFloat;
    ChangingQuality: boolean;
    FTriangulatedKeys: int32;
    procedure SetQuality(AValue: BSFloat); virtual;
    procedure CalculateContour(Key: PKeyInfo);
    function GetRawGlyph(Index: int32): PGlyph;
    procedure CheckKeyRect(Key: PKeyInfo);
  public
    // raw glyph data containig loaded point contours
    RawGlyphs: TListGlyphs;
  public
    constructor Create(const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Font: TBlackSharkCustomFont); override;
    { Load "True Type" Font }
    function Load(const FileName: string): boolean; override;
    procedure CalcContours; override;
    { Fill contour by triangles }
    procedure Triangulate(Key: PKeyInfo); override;
    { Quality smooth contours }
    property Quality: BSFloat read FQuality write SetQuality;
    { Save to file near with font file indexes triangles triangulated contours for
      more quick load font in next time }
    property SaveIndexes: boolean read FSaveIndexes write FSaveIndexes;
  end;

  { TTrueTypeRasterFont }

  { The class presents a vectoral or raster text; a threshold representation
    the vector text or raster defined by a value of property MaxRasterSize;

    TODO:
      - save texture to file for repeated usage or save as TBlackSharkRasterFont

    }

  TTrueTypeRasterFont = class(TTrueTypeFont)
  private
    type
      TEdgeType = (etStem, etSerif, etPivot, etDead);
      PEdge = ^TEdge;
      TEdge = record
        Point: TVec2i;
        {$ifdef DEBUG_FONT}
        OriginalPoint: TVec2f;
        {$endif}
        EdgeType: TEdgeType;
        Tang: BSFloat;
        Next: PEdge;
        //Opposite: PEdge;
        //OppositeDistance: BSFloat;
        Clockwise: boolean;
        //IsOppositeCount: int32;
        //Contour: int32;
        //Drawn: boolean;
      end;
      TEdges = TListVec<PEdge>;
  public
    const
      MAX_RASTER_SIZE_DEFAULT = 32;
  private
    FRasterizator: TBlackSharkBitMap;
    FRastCont: TBlackSharkBitMap;
    FMaxRasterSize: int16;
    Edges: TEdges;
    Points: TListVec<TVec2i>;
    procedure SetMaxRasterSize(const Value: int16);
  protected
    procedure SetSize(const Value: BSFloat); override;
  public
    constructor Create(const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Font: TBlackSharkCustomFont); override;
    procedure CalcContours; override;
    { Save as TBlackSharkRasterFont; circle closed :); that is, you can
      prepare for self from True Type font simple raster font, which give smaler
      overhead }
    function Save(const FileName: string): boolean; override;
    procedure BeginSelectChars; override;
    function EndSelectChars: boolean; override;
    procedure Triangulate(Key: PKeyInfo); override;
    property Rasterizator: TBlackSharkBitMap read FRasterizator;
    { Threshold size for translate vector font to raster and back }
    property MaxRasterSize: int16 read FMaxRasterSize write SetMaxRasterSize;
  end;

  { Black Shark font header }
  TFontMainHeader = packed record
    Signature: array[0..3] of AnsiChar;
    Version: byte;
  end;

  { Black Shark main info font header }
  TMainInfoFontHeader = packed record
    MainHeader: TFontMainHeader;
    CountChars: int32;
    SizeTexture: int32;
  end;

  { TBlackSharkRasterFont }

  { It allows to present internal Black Shark Engine font format }

  TBlackSharkRasterFont = class(TBlackSharkCustomFont)
  private
    function LoadBSFont0(Stream: TStream): boolean;
  protected
    //procedure SetSize(const Value: int16); override;
  public
    procedure Assign(Font: TBlackSharkCustomFont); override;
    function AddSymbol(CodeUTF16: uint16; const Rect: TRectBSi): PKeyInfo;
    { Load Black Shark Font }
    function Load(const FileName: string): boolean; override;
    { TODO: save texture }
    function Save(const FileName: string): boolean; override;
    procedure Triangulate(Key: PKeyInfo); override;
  end;

  TChangeFontNotify = procedure (Font: TBlackSharkCustomFont) of object;

  { BSFontManager }

  { The manager of fonts allows to manage resources of fonts, that is vectors,
    textures and by the fonts, for repeated usage; a font has mechanism
    references counter; notwithstanding, you can create a font directly }

  BSFontManager = class
  public
    const
      DEFAULT_FONT = 'NotoSerif-Regular.ttf';
  private
    type
      TConvertTable = array[128..255] of int32;
      PConvertTable = ^TConvertTable;
  private
    class var ConvertTables: array[TCodePage] of PConvertTable;
    class procedure ClearConvertTables;
    class procedure InitConvertTables;
  private
    class var FDefaultFont: IBlackSharkFont;
    { here containers without counting of references on objects because contain
      classes, not interfaces }
    class var FontNames: TBinTree<TBlackSharkCustomFont>;
    class var Textures: TBinTree<TFontTexture>;
    class var RawFonts: TBinTree<TBlackSharkCustomFont>;
    class var AllFonts: TListVec<TBlackSharkCustomFont>;
    class var FFonts: TListVec<string>;

    class function GetRawFontData(const Name: string): TBlackSharkCustomFont;
    class procedure OnUpdateFont(const OldShortName: string; const Font: TBlackSharkCustomFont);
    class procedure OnCreateFont(const Font: TBlackSharkCustomFont);
    class procedure OnDestroyFont(const Font: TBlackSharkCustomFont);
    class function GetDefaultFont: IBlackSharkFont; static;
    class function GetTexture(const Name: string; FontSize: int32; CountRects: uint32): IFontTexture;
    class procedure FreeTexture(const Texture: TFontTexture);
    class function GetCountFontTextures: int32; static;
    class function GetFonts: TListVec<string>; static;
    class constructor Create;
    class destructor Destroy;
  public
    class function AnsiToUTF16(Code: uint8; CodePage: TCodePage): int32;
    { create new font; font vecotrs (raw data) and texture find in already loaded
      by name or load and link to new loaded font; in any case incremented a count
      references on the font }
    class function GetFont(const Name: string): IBlackSharkFont; overload; static;
    class function GetFont(const FileName: string; ClassFont: TClassFont): IBlackSharkFont; overload; static;
    class function AddFont(const FileName: string): IBlackSharkFont; overload;
    { create default font equally AddFont }
    class function CreateDefaultFont: IBlackSharkFont; virtual;
    { getting a font by name with incremets count refecence }
    class property Font[const Name: string]: IBlackSharkFont read GetFont;
    class property Fonts: TListVec<string> read GetFonts;
    { accept reference on default a font; !!! remember, this property add count
      reference on accepting the font (see above description to AddFont); }
    class property DefaultFont: IBlackSharkFont read GetDefaultFont;
    class property CountFontTextures: int32 read GetCountFontTextures;
  end;


const
  FONT_MAIN_HEADER: TFontMainHeader = (
    Signature: 'BSFT';
    Version: 0;
  );

  {RANGE_START: array[TUnicodeRange] of int32 = (
    0, 1, 2, 3, 4, 5, 6, 7, 8,
    $0400, //urCyrillic_0400_04FF
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
    110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
    120, 121, 122
  );

  CODE_PAGE_OFSETS_IN_UNICODE: array[TCodePage] of int32 = (
    0,
    0, // cpLatin1,                // 1252
    0, // cpLatin2,                // Eastern Europe 1250
    $0400, //cpCyrillic - 1251
    0, // cpGreek,                 // 1253
    0, // cpTurkish,               // 1254
    0, // cpHebrew,                // 1255
    0, // cpArabic,                // 1256
    0, // cpWindowsBaltic,         // 1257
    0, // cpVietnamese,            // 1258
    0, // cpThai,                  // 874
    0, // cpJapan,                 // 932
    0, // cpChineseSingapore,      // 936
    0, // cpKoreanWansung,         // 949
    0, // cpChineseTaiwanHongKong, // 950
    0, // cpKoreanJohab,           // 1361
    0, // cpIBMGreek,              // 869
    0, // cpMSDOSRussian,          // 866
    0, // cpMSDOSNordic,           // 865
    0, // cpArabicOEM,             // 864
    0, // cpMSDOSCanadianFrench,   // 863
    0, // cpHebrewOEM,             // 862
    0, // cpMSDOSIcelandic,        // 861
    0, // cpMSDOSPortuguese,       // 860
    0, // cpIBMTurkish,            // 857
    0, // cpIBMCyrillic,           // 855
    0, // cpLatin2OEM,             // 852
    0, // cpMSDOSBaltic,           // 775
    0, // cpGreekOEM,              // 737
    0, // cpArabicASMO_708,        // 708
    0, // cpLatin1OEM,             // 850
    0 // cpUS                     // 437
  ); }

  CODE_PAGE_NAMES: array[TCodePage] of string = (
    'cpUnicode',
    'cpLatin1',                // 1252
    'cpLatin2',                // Eastern Europe 1250
    'cpCyrillic',              // 1251
    'cpGreek',                 // 1253
    'cpTurkish',               // 1254
    'cpHebrew',                // 1255
    'cpArabic',                // 1256
    'cpWindowsBaltic',         // 1257
    'cpVietnamese',            // 1258
    'cpThai',                  // 874
    'cpJapan',                 // 932
    'cpChineseSingapore',      // 936
    'cpKoreanWansung',         // 949
    'cpChineseTaiwanHongKong', // 950
    'cpKoreanJohab',           // 1361
    'cpIBMGreek',              // 869
    'cpMSDOSRussian',          // 866
    'cpMSDOSNordic',           // 865
    'cpArabicOEM',             // 864
    'cpMSDOSCanadianFrench',   // 863
    'cpHebrewOEM',             // 862
    'cpMSDOSIcelandic',        // 861
    'cpMSDOSPortuguese',       // 860
    'cpIBMTurkish',            // 857
    'cpIBMCyrillic',           // 855
    'cpLatin2OEM',             // 852
    'cpMSDOSBaltic',           // 775
    'cpGreekOEM',              // 737
    'cpArabicASMO_708',        // 708
    'cpLatin1OEM',             // 850
    'cpUS'                     // 437
    );


implementation

uses
{$ifdef FMX}
    FMX.Graphics,
    FMX.Types,
{$endif}

{$ifdef FPC}
    LazUTF8,
{$endif}

{$ifdef DEBUG_FONT}
    bs.thread,
    bs.log,
{$endif}

    bs.utils
  , bs.strings
  , bs.stream
  , bs.math
  , math
  ;

{$region 'FontParser'}

type

  { TFontParser }

  TFontParser = class
  private
  type
      PTCHeader = ^TTCHeader;
      TTCHeader = packed record
        Version: uint32;
        NumTables: uint16;
        SearchRange: uint16;
        EntrySelector: uint16;
        RangeShift: uint16;
      end;
      PTableRec = ^TTableRec;
      TTableRec = record
        Signs: uint32;
        CheckSum: uint32;
        Offset: uint32;
        Length: uint32;
      end;
      PTable_cmap_HDR0 = ^TTable_cmap_HDR0;
      TTable_cmap_HDR0 = packed record
        Format: uint16;
        Length: uint16;
        Language: uint16;
        //GlyphIdArray: array[0..255] of byte;
      end;
      TMetodParse = procedure(hdr: PTableRec) of object;
      PProcParse = ^TProcParse;
      TProcParse = record
        MetodParse: TMetodParse;
        Offset: uint32;
        Length: uint32;
        TableRec: PTableRec;
      end;
  private
    Signs: TBinTree<PProcParse>;
    pData: pByte;
    size_f: uint32;
    FDestFont: TTrueTypeFont;
    IndexToLoc: uint16;
    CountGlyphs: uint16;
    GlyphOffsets: TListVec<int32>;
    //Points: TListGlyphPoints.TSingleListHead;
    // pointer to table vectors (points)
    GlyphPointsTable: pByte;
    // all loaded to FDestFont glyphs; access by Code
    // Symblols: TListVec<PKeyInfo>;
    flags: TListVec<uint8>;


    procedure LoadTable(const Name: AnsiString);

{$region 'handlers automat conditions'}
    // Layout Common Table Formats
    //procedure Proc_CommonTable({%H-}PtrBegin: Pointer);
    // Digital Signature Table
    procedure Proc_DSIG({%H-}hdr: PTableRec);
    // The Glyph Definition Table
    procedure Proc_GDEF(hdr: PTableRec);
    procedure Proc_cmap(hdr: PTableRec);
    procedure Proc_cmap_Format4(Table: TTableSymbols; cmap_Format4: Pointer);
    procedure Proc_head(hdr: PTableRec);
    procedure Proc_hhea({%H-}hdr: PTableRec);
    procedure Proc_hmtx({%H-}hdr: PTableRec);
    procedure Proc_maxp(hdr: PTableRec);
    procedure Proc_name({%H-}hdr: PTableRec);
    procedure Proc_OS2({%H-}hdr: PTableRec);
    procedure Proc_post({%H-}hdr: PTableRec);
    procedure Proc_cvt({%H-}hdr: PTableRec);
    procedure Proc_fpgm({%H-}hdr: PTableRec);
    procedure Proc_glyf(hdr: PTableRec);
    procedure Proc_loca(hdr: PTableRec);
    procedure Proc_prep({%H-}hdr: PTableRec);
    procedure Proc_gasp({%H-}hdr: PTableRec);
    procedure Proc_CFF({%H-}hdr: PTableRec);
    procedure Proc_VORG({%H-}hdr: PTableRec);
    procedure Proc_SVG({%H-}hdr: PTableRec);
    procedure Proc_BASE({%H-}hdr: PTableRec);
    procedure Proc_GPOS({%H-}hdr: PTableRec);
    procedure Proc_GSUB({%H-}hdr: PTableRec);
    procedure Proc_JSTF({%H-}hdr: PTableRec);
    procedure Proc_MATH({%H-}hdr: PTableRec);
    procedure Proc_hdmx({%H-}hdr: PTableRec);
    procedure Proc_kern({%H-}hdr: PTableRec);
    procedure Proc_LTSH({%H-}hdr: PTableRec);
    procedure Proc_PCLT({%H-}hdr: PTableRec);
    procedure Proc_VDMX({%H-}hdr: PTableRec);
    procedure Proc_vhea({%H-}hdr: PTableRec);
    procedure Proc_vmtx({%H-}hdr: PTableRec);
    procedure Proc_COLR({%H-}hdr: PTableRec);
    procedure Proc_CPAL({%H-}hdr: PTableRec);
{$endregion}
  public
    function LoadTTFont(const FileName: string; DestFont: TTrueTypeFont): boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  var
    FontParser: TFontParser;

function CreateGlyph: PGlyph; inline;
begin
  new(Result);
  Result^.xMin :=  MaxInt;
  Result^.yMin :=  MaxInt;
  Result^.xMax := -MaxInt;
  Result^.yMax := -MaxInt;
  TBlackSharkTesselator.TListContours.Create(Result^.Contours);
  TBlackSharkTesselator.TListPoints.Create(Result^.Points);
end;

procedure FreeGlyph(Glyph: PGlyph); inline;
begin
  TBlackSharkTesselator.TListContours.Free(Glyph^.Contours);
  TBlackSharkTesselator.TListPoints.Free(Glyph^.Points);
  dispose(Glyph);
end;

procedure CheckGlyphBoundary(Glyph: PGlyph; const v: TVec3f); inline;
begin
  if Glyph.xMin > v.x then
    Glyph.xMin := v.x;
  if Glyph.xMax < v.x then
    Glyph.xMax := v.x;
  if Glyph.yMin > v.y then
    Glyph.yMin := v.y;
  if Glyph.yMax < v.y then
    Glyph.yMax := v.y;
end;

{ TTrueTypeRasterFont }

procedure TTrueTypeRasterFont.CalcContours;
begin
  CalcScale;
  FIsVectoral := FSizeInPixels > FMaxRasterSize;
  if not FIsVectoral then
    CreateTexture;
  inherited CalcContours;
end;

constructor TTrueTypeRasterFont.Create(const AName: string);
begin
  inherited;
  FMaxRasterSize := MAX_RASTER_SIZE_DEFAULT;
  FIsVectoral := FSizeInPixels > FMaxRasterSize;
  Edges := TEdges.Create(@PtrCmp);
  Points := TListVec<TVec2i>.Create;
end;

destructor TTrueTypeRasterFont.Destroy;
begin
  FRasterizator.Free;
  FRastCont.Free;
  Edges.Free;
  Points.Free;
  inherited;
end;

function TTrueTypeRasterFont.Save(const FileName: string): boolean;
var
  f: TBlackSharkRasterFont;
begin
  f := TBlackSharkRasterFont.Create(ExtractFileName(FileName));
  try
    f.Assign(Self);
    f.Save(FileName);
  finally
    f.Free;
  end;
  Result := true;
end;

procedure TTrueTypeRasterFont.Assign(Font: TBlackSharkCustomFont);
begin
  inherited;
  FIsVectoral := FSizeInPixels > FMaxRasterSize;
  //FIsVectoral := Font.FIsVectoral;
end;

procedure TTrueTypeRasterFont.BeginSelectChars;
begin
  inherited BeginSelectChars;
end;

function TTrueTypeRasterFont.EndSelectChars: boolean;
begin
  if (Map <> nil) then
    Map.Picture.Canvas.Changed := WasTriangulated;
  Result := inherited;
  //if not Result and WasTriangulated then
  //  Change;
end;

procedure TTrueTypeRasterFont.SetMaxRasterSize(const Value: int16);
var
  is_vec: boolean;
begin
  FMaxRasterSize := Value;
  is_vec := FSizeInPixels > FMaxRasterSize;
  if (is_vec <> FIsVectoral) then
    CalcContours;
end;

procedure TTrueTypeRasterFont.SetSize(const Value: BSFloat);
begin
  if FSize = Value then
    exit;
  if Assigned(FTexture) then
  begin
    //ObserverChangeTexture := nil;
    FTexture := nil;
    Map := nil;
  end;
  FIsVectoral := FSizeInPixels > FMaxRasterSize;
  inherited SetSize(Value);
  // FTexture.Texture.TrilinearFilter := FSize > 9;
end;

procedure TTrueTypeRasterFont.Triangulate(Key: PKeyInfo);
const
  SUBBPIXELS = 8;
  PRECISION = 1/SUBBPIXELS;
  //SUBPIXELS_IN_PIXEL_SRC = SUBBPIXELS * SUBBPIXELS;

  SUBPIXELS_IN_PIXEL_DST = 256;
  SUBPIXEL_DST = SUBPIXELS_IN_PIXEL_DST div (SUBBPIXELS * SUBBPIXELS);
var
  ed: PEdge;
  new_size: TVec2i;
  v0, v1, v2: TVec2f;
  v0f, v1f, v2f: TVec2f;
  i, j: int32;
  area: PTextureArea;
  rendered_data: PKeyInfo;
  raw_src: PKeyInfo;


  procedure CreateEdges;
  var
    befor: PEdge;
    first: PEdge;
    i, j: int32;

    function ToSubpixels(Pixels: BSFloat): int32;
    begin
      Result := round((Pixels * FScale) * SUBBPIXELS);
    end;

  begin

    for i := 0 to rendered_data.Glyph.Contours.Count - 1 do
    begin
      new(befor);
      v0 := TVec2f(rendered_data.Glyph.Points.Items[rendered_data.Glyph.Contours.Items[i].PointIndexBegin + rendered_data.Glyph.Contours.Items[i].CountPoints - 1]);
      //befor.Point.x := (v0.x - rendered_data^.Glyph^.xMin)*FScale;
      //befor.Point.y := FRasterizator.Height - ((v0.y - rendered_data^.Glyph^.yMin)*FScale + SIZE_BORDER*2);
      befor.Point.x := ToSubpixels(v0.x - rendered_data^.Glyph^.xMin);
      befor.Point.y := ToSubpixels(rendered_data^.Rect.Height - (v0.y - rendered_data^.Glyph^.yMin));
      {$ifdef DEBUG_FONT}
      befor.OriginalPoint := v0;
      {$endif}
      befor.Clockwise := rendered_data.Glyph.Contours.Items[i].AsClockArr;
      befor.EdgeType := etStem;
      //befor.Contour := i;
      first := befor;
      ed := befor;
      Edges.Add(ed);
      for j := rendered_data.Glyph.Contours.Items[i].PointIndexBegin to
        rendered_data.Glyph.Contours.Items[i].PointIndexBegin + rendered_data.Glyph.Contours.Items[i].CountPoints - 1 do
      begin
        v1 := TVec2f(rendered_data.Glyph.Points.Items[j]);
        if (abs(v1.x - befor.point.x) < EPSILON) and (abs(v1.y - befor.point.y) < EPSILON) then
          continue;
        new(ed);
        ed.Point.x := ToSubpixels(v1.x - rendered_data^.Glyph^.xMin);
        ed.Point.y := ToSubpixels(rendered_data^.Rect.Height - (v1.y - rendered_data^.Glyph^.yMin));
        {$ifdef DEBUG_FONT}
        ed.OriginalPoint := v1;
        {$endif}
        ed.EdgeType := etStem;
        //ed.Contour := i;
        befor.Next := ed;
        befor.Tang := 0; //arctan2(ed.Point.y - befor.Point.y, ed.Point.x - befor.Point.x);
        ed.Clockwise := rendered_data.Glyph.Contours.Items[i].AsClockArr;
        Edges.Add(ed);
        befor := ed;
        v0f := v1f;
      end;
      if (abs(ed.Point.x - befor.point.x) < EPSILON) and (abs(ed.Point.y - befor.point.y) < EPSILON) then
      begin
        Edges.Remove(ed, otFromEnd);
        befor := Edges.Items[Edges.Count - 1];
        befor.Next := first;
        befor.Tang := 0; //arctan2(first.Point.y - befor.Point.y, first.Point.x - befor.Point.x);
        dispose(ed);
      end else
      begin
        befor.Next := ed;
        ed.Next := first;
        ed.Tang := arctan2(first.Point.y - ed.Point.y, first.Point.x - ed.Point.x);
      end;
    end;
  end;

  procedure DropRepeats;
  var
    i: int32;
  begin
    // removes repeats and calc tang
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed.EdgeType = etDead) then
        continue;

      while ed.Point = ed.Next.Point do
      begin
        ed.Next.EdgeType := etDead;
        ed.Next := ed.Next.Next;
      end;
      ed.Tang := arctan2(ed.Next.Point.y - ed.Point.y, ed.Next.Point.x - ed.Point.x);
    end;
  end;

  {procedure FindEdge(ForEdge: PEdge);
  var
    i: int32;
    a: BSFloat;
    v_orig: TVec2f;
    v_end: TVec2f;
    d: BSFloat;
    intersect: TVec2f;
  begin
    a := VecDecision(vec2(ForEdge.Next.Point.x - ForEdge.Point.x, ForEdge.Point.y - ForEdge.Next.Point.y)) + 270;
    v_orig := vec2((ForEdge.Next.Point.x + ForEdge.Point.x)*0.5, (ForEdge.Next.Point.y + ForEdge.Point.y)*0.5);
    v_end := v_orig + vec2(BS_Cos(a)*16, -BS_Sin(a)*16);
    ForEdge.OppositeDistance := MaxSingle;
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed = ForEdge) then // or (ed.Next = ForEdge) or (ed = ForEdge.Next) or (sign(ed.Tang) = sign(ForEdge.Tang))
        continue;
      if LinesIntersect(v_orig, v_end, ed.Point, ed.Next.Point, intersect) then
      begin
        d := VecLenSqr(v_orig - intersect);
        if d < ForEdge.OppositeDistance then
        begin
          ForEdge.Opposite := ed;
          ForEdge.OppositeDistance := d;
          //break;
        end;
      end;
    end;
  end;

  procedure FindOpposite;
  var
    i: int32;
  begin
    for i := 0 to Edges.Count - 1 do
    begin
      FoundEdge(Edges.Items[i]);
      if Edges.Items[i].Opposite = nil then
        raise Exception.Create('Error Message') else
        inc(Edges.Items[i].Opposite.IsOppositeCount);
    end;
  end;   }

  procedure Fitting;
  const
    EPS = 0.001;
  var
    i: int32;
    prev: PEdge;
    //prev_tilt: boolean;
    //count: int32;
    //tang: BSFloat;
  begin
    rendered_data.Glyph.xMin := round(round(rendered_data.Glyph.xMin*FScale)/FScale);
    rendered_data.Glyph.yMin := round(round(rendered_data.Glyph.yMin*FScale)/FScale);
    rendered_data.Glyph.xMax := round(round(rendered_data.Glyph.xMax*FScale)/FScale);
    rendered_data.Glyph.yMax := round(round(rendered_data.Glyph.yMax*FScale)/FScale);
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      ed.Point.x := round(ed.Point.x);
      ed.Point.y := round(ed.Point.y);
    end;

    // removes repeats and calc tang
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed.EdgeType = etDead) then
        continue;

      {if (ed <> ed.Opposite.Opposite) and (ed.Next.Opposite.Opposite <> ed) and (ed <> ed.Opposite.Next.Opposite) and (ed <> ed.Opposite.Opposite.Next) then
        begin
        if Pi - abs(ed.Opposite.Tang - ed.Tang) > 0.1 then
          ed.EdgeType := etSerif;
        end; }

      while ed.Point = ed.Next.Point do
      begin
        ed.Next.EdgeType := etDead;
        ed.Next := ed.Next.Next;
      end;
      ed.Tang := arctan2(ed.Next.Point.y - ed.Point.y, ed.Next.Point.x - ed.Point.x);
    end;

    //prev_tilt := false;
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed.EdgeType = etDead) then
        continue;

      // stair
      if ((abs(ed.Tang) < EPS) or (Pi - abs(ed.Tang) < EPS) or (abs(Pi*0.5 - abs(ed.Tang)) < EPS))
        and (abs(ed.Tang - ed.Next.Next.Tang) < EPS)
        and ((abs(ed.Point.x - ed.Next.Next.Point.x) <= 1) and (abs(ed.Point.y - ed.Next.Next.Point.y) <= 1)) then
      begin
        // make stright
        ed.Next.EdgeType := etDead;
        ed.Next := ed.Next.Next;
        ed.Tang := arctan2(round(ed.Next.Point.y) - (ed.Point.y), round(ed.Next.Point.x) - (ed.Point.x));
      end;

      prev := ed;
      ed := ed.Next;
      // removes the chain the same direction
      while (abs(prev.Tang - ed.Tang) < EPS) or (abs(Pi - abs(prev.Tang - ed.Tang)) < EPS) do
      begin
        ed.EdgeType := etDead;
        prev.Next := ed.Next;
        ed := ed.Next;
      end;
    end;

    // find pivots
    {for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed.EdgeType = etDead) then
        continue;

      if (not ed.Clockwise and ed.Opposite.Clockwise) then
      begin
        ed.EdgeType := etDead;
        continue;
      end;

      // pivot on 180
      if (abs(Pi - abs(ed.Tang - ed.Next.Next.Tang)) < EPS) and (ed.OppositeDistance < 3) then
      begin
        // because of ed.Next need for draw the edge don't change ed.Next on ed.Next.Next
        ed.Next.EdgeType := etPivot;
      end;
    end;  }

    // find a prev edge for a first edge needed in the next stage
    {ed := Edges.Items[0];
    count := 0;
    // skip dead
    while (ed.EdgeType = etDead) and (count < Edges.Count) do
    begin
      ed := ed.Next;
      inc(count);
    end;
    prev := ed.Next;
    while prev.Next <> ed do
      prev := prev.Next;

    // drop opposits and aling on center of pixel
    for i := 0 to Edges.Count - 1 do
    begin
      ed := Edges.Items[i];
      if (ed.EdgeType = etDead) then
        continue;  }

      {if (ed.EdgeType <> etSerif) and (ed.EdgeType <> etPivot) then
      begin
        if (ed = ed.Opposite.Opposite) then
        begin
          //ed.Point := vec2(ed.Point.x + BS_Sin(ed.Tang * BS_RAD2DEG) * 0.5, ed.Point.y + BS_Cos(ed.Tang * BS_RAD2DEG) * 0.5);
          //ed.Point := (ed.Point + ed.Opposite.Next.Point)*0.5;
          if (ed.EdgeType <> etDead) and (ed.OppositeDistance < 5) then
            ed.Opposite.EdgeType := etDead;
        end else
        if (ed = ed.Next.Opposite.Opposite) then
        begin
          //ed.Point := (ed.Point + ed.Next.Opposite.Next.Next.Point)*0.5;
          //ed.Point := vec2(ed.Point.x + BS_Sin(ed.Tang * BS_RAD2DEG) * 0.5, ed.Point.y + BS_Cos(ed.Tang * BS_RAD2DEG) * 0.5);
          //ed.Point := vec2(ed.Point.x + 0.5, ed.Point.y - 0.5);
          if (ed.EdgeType <> etDead) and (ed.OppositeDistance < 5) then
            ed.Next.Opposite.Next.EdgeType := etDead;
        end;
      end;}

      // if the edge is pivot then align position as previosly
      {if ed.EdgeType = etPivot then
        tang := prev.Tang
      else
        tang := ed.Tang;

      if prev_tilt then
      begin
        prev_tilt := (abs(Pi*0.5 - abs(tang)) < EPS) and (abs(Pi - abs(tang)) < EPS);
        ed.Point := vec2(ed.Point.x + 0.5, ed.Point.y - 0.5);
      end else
      if abs(Pi*0.5 - abs(tang)) < EPS then
        ed.Point.x := ed.Point.x + 0.5
      else
      if abs(Pi - abs(tang)) < EPS then
        ed.Point.y := ed.Point.y - 0.5
      else
      begin
        ed.Point := vec2(ed.Point.x + 0.5, ed.Point.y - 0.5);
        prev_tilt := true;
      end;

      prev := ed;
    end;     }
  end;

  {$ifdef DEBUG_FONT}
  procedure SaveDebug;
  var
    i, step: int32;
    bmp: TBlackSharkBitMap;
    colors: TColorEnumerator;
    s: BSFloat;
    sl: TStringList;
  begin
    //exit;
    if rendered_data.Rect.Width > rendered_data.Rect.Height then
      s := new_size.x / SIZE_SOURCE_CANVAS_DEFAULT
    else
      s := new_size.y / SIZE_SOURCE_CANVAS_DEFAULT;

    if s > 1.0 then
      s := 1/s;

    colors := TColorEnumerator.Create([bsWhite]);
    bmp := TBlackSharkBitMap.Create;
    try
      step := round(1/s);
      bmp.SetSize((new_size.x + SIZE_BORDER*2)*step, (new_size.y + SIZE_BORDER*2)*step);
      TBlackSharkRasterizatorRGBA(bmp.Canvas).Color := ColorFloatToByte(BS_CL_GREEN);
      if rendered_data.Rect.Width > rendered_data.Rect.Height then
        s := (bmp.Width - SIZE_BORDER*2*step) / rendered_data.Rect.Width
      else
        s := (bmp.Height - SIZE_BORDER*2*step) / rendered_data.Rect.Height;

      // draw grid
      for i := 0 to new_size.y - 1 + SIZE_BORDER * 2 do
        bmp.Canvas.DrawLine(0, step * i, bmp.Width, step * i);

      for i := 0 to new_size.x - 1 + SIZE_BORDER * 2 do
        bmp.Canvas.DrawLine(step * i, 0, step * i, bmp.Height);

      sl := TStringList.Create;
      // draw edges
      for i := 0 to Edges.Count - 1 do
      begin
        ed := Edges.Items[i];
        if (ed.EdgeType = etDead) then // or (ed.EdgeType = etPivot)
          continue;
        if ed.Clockwise then
          TBlackSharkRasterizatorRGBA(bmp.Canvas).Color := ColorFloatToByte(colors.GetNextColor)    // BS_CL_RED
        else
          TBlackSharkRasterizatorRGBA(bmp.Canvas).Color := ColorFloatToByte(BS_CL_BLUE);  //FRastCont.Height -
        sl.Add(IntToStr(round(ed.Point.x)) + #9 + IntToStr(round(ed.Point.y)) + #9 + IntToStr(i));
        v0f := vec2((ed.OriginalPoint.x - rendered_data.Glyph.xMin)*s, bmp.Height - step - (ed.OriginalPoint.y - rendered_data.Glyph.yMin)*s);
        v1f := vec2((ed.Next.OriginalPoint.x - rendered_data.Glyph.xMin)*s, bmp.Height - step - (ed.Next.OriginalPoint.y - rendered_data.Glyph.yMin)*s);
        bmp.Canvas.DrawLine(int32(round(SIZE_BORDER*step + v0f.x)), int32(round(v0f.y)), int32(round(SIZE_BORDER*step + v1f.x)), int32(round(v1f.y)));
      end;
      bmp.Save('d:\result_renderer.bmp');
      sl.SaveToFile('d:\points.txt');
      sl.Free;
    finally
      colors.Free;
      bmp.Free;
    end;
  end;
  {$endif}

var
  sx, sy: BSFloat;
  cl, cl_dest: PByte;
  point: TVec2i;
  pixel: Byte;
begin

  inherited Triangulate(Key); // triangulate TrueType contours to carrent size

  if RawDataFont = nil then
    exit;

  rendered_data := RawDataFont.Key[ Key^.Code ];
  raw_src := rendered_data;

  if rendered_data.Indexes.Count < 3 then
    exit;

  if FSizeInPixels > FMaxRasterSize then
  begin
    if not FIsVectoral then
      SetIsVectoral(true);
  end else
  begin

    sx := (rendered_data.Glyph.xMax - rendered_data.Glyph.xMin)*FScale;
    if sx - trunc(sx) >= PRECISION then
      new_size.x := trunc(sx + 1);

    sy := round((rendered_data.Glyph.yMax - rendered_data.Glyph.yMin)*FScale);
    //if sy - trunc(sy) >= PRECISION then
    //  sy := trunc(sy + 1);

    new_size := vec2(sx, sy);

    if FTexture = nil then
      CreateTexture;

    if not FTexture.GetRect(Key.Code, tsUnicodeCS2, Key.TextureRect) then
    begin
      FTexture.BeginUpdate;

      if FRasterizator = nil then
      begin
        FRasterizator := TBlackSharkBitMap.Create;
        FRasterizator.PixelFormat := TBSPixelFormat.pf8bit;
        FRasterizator.Canvas.SamplerFilter.InterpolationMode := imLinear;
        //Rasterizator.Canvas.SamplerFilter.WindowSize := 1;
      end;


      if FSizeInPixels < 10 then
      begin

        if FRastCont = nil then
        begin
          FRastCont := TBlackSharkBitMap.Create;
          FRastCont.PixelFormat := TBSPixelFormat.pf8bit;
        end;

        CreateEdges;
        DropRepeats;

        // draw edges
        FRastCont.SetSize((new_size.x + 1) * SUBBPIXELS, (new_size.y + 1) * SUBBPIXELS);
        FRastCont.Canvas.Clear;

        for i := 0 to Edges.Count - 1 do
        begin
          ed := Edges.Items[i];
          if ed.EdgeType = etDead then
            continue;
          FRastCont.Canvas.DrawLine(ed.Point, ed.Next.Point);
        end;

        {$ifdef DEBUG_FONT}
          // save draft
          //SaveDebug;
          //FRastCont.Save('d:\rast_src_without_control_points.bmp');
        {$endif}

        // now set control points for fill
        for i := 0 to Edges.Count - 1 do
        begin
          ed := Edges.Items[i];
          if (ed.EdgeType <> etDead) and ed.Clockwise then
          begin
            point := vec2(((ed.Point.x + ed.Next.Point.x) shr 1), ((ed.Point.y + ed.Next.Point.y) shr 1));
            if ((abs(ed.Point.x - ed.Next.Point.x) > 1) or (abs(ed.Point.y - ed.Next.Point.y) > 1)) and FRastCont.Canvas.GetPixel(point.x, point.y, pixel) and (pixel > 0) then
            begin
              point := vec2(point.x - round(BS_Sin(ed.Tang * BS_RAD2DEG)), point.y + round(BS_Cos(ed.Tang * BS_RAD2DEG)));
              if FRastCont.Canvas.GetPixel(point.x, point.y, pixel) and (pixel = 0) then
              begin
                Points.Add(point);
                FRastCont.Canvas.DrawPixel(point.x, point.y);
              end;
            end;
          end;
          dispose(ed);
        end;

        Edges.Count := 0;
        //FRastCont.Save('d:\rast_src_with_control_points.bmp');

        // fill pixels by pints
        while Points.Count > 0 do
        begin
          point := Points.Pop;

          if FRastCont.Canvas.GetPixel(point.x + 1, point.y, pixel) and (pixel = 0) then
          begin
            Points.Add(vec2(point.x + 1, point.y));
            FRastCont.Canvas.DrawPixel(point.x + 1, point.y);
          end;

          if FRastCont.Canvas.GetPixel(point.x - 1, point.y, pixel) and (pixel = 0) then
          begin
            Points.Add(vec2(point.x - 1, point.y));
            FRastCont.Canvas.DrawPixel(point.x - 1, point.y);
          end;

          if FRastCont.Canvas.GetPixel(point.x, point.y + 1, pixel) and (pixel = 0) then
          begin
            Points.Add(vec2(point.x, point.y + 1));
            FRastCont.Canvas.DrawPixel(point.x, point.y + 1);
          end;

          if FRastCont.Canvas.GetPixel(point.x, point.y - 1, pixel) and (pixel = 0) then
          begin
            Points.Add(vec2(point.x, point.y - 1));
            FRastCont.Canvas.DrawPixel(point.x, point.y - 1);
          end;
        end;

        //FRastCont.Save('d:\filled_rast.bmp');

        FRasterizator.SetSize(new_size.x + SIZE_BORDER*2, new_size.y + SIZE_BORDER*2);
        FRasterizator.Canvas.Clear;

        for i := 0 to new_size.y * SUBBPIXELS do
        begin
          j := 0;
          cl := FRastCont.Canvas.PtrOnColor(0, i);
          cl_dest := FRasterizator.Canvas.PtrOnColor(SIZE_BORDER, (new_size.y - (i div SUBBPIXELS)));
          while j < new_size.x * SUBBPIXELS do
          begin
            if cl^ > 0 then
            begin
              if cl_dest^ <= 255 - SUBPIXEL_DST then
                inc(cl_dest^, SUBPIXEL_DST);
            end;

            inc(j);
            inc(cl);

            if j mod SUBBPIXELS = 0 then
              inc(cl_dest);
          end;
        end;

        //FRasterizator.Save('d:\filled_rast_result.bmp');

      end else
      begin
        sx := new_size.x * 16 / rendered_data.Rect.Width;
        sy := new_size.y * 32 / rendered_data.Rect.Height;
        FRasterizator.SetSize((16 * new_size.x), (32 * new_size.y));
        FRasterizator.Canvas.Clear;
        for i := 0 to raw_src.Indexes.Count div 3 - 1 do
        begin
          v0 := TVec2f(rendered_data^.Glyph^.Points.Items[raw_src.Indexes.Items[i*3  ]]);
          v1 := TVec2f(rendered_data^.Glyph^.Points.Items[raw_src.Indexes.Items[i*3+1]]);
          v2 := TVec2f(rendered_data^.Glyph^.Points.Items[raw_src.Indexes.Items[i*3+2]]);
          v0f := vec2((v0.x - rendered_data^.Glyph^.xMin)*sx, sy*(v0.y - rendered_data^.Glyph^.yMin));
          v1f := vec2((v1.x - rendered_data^.Glyph^.xMin)*sx, sy*(v1.y - rendered_data^.Glyph^.yMin));
          v2f := vec2((v2.x - rendered_data^.Glyph^.xMin)*sx, sy*(v2.y - rendered_data^.Glyph^.yMin));
          FRasterizator.Canvas.DrawTriangle(v0f, v1f, v2f, true);
        end;


        //FRasterizator.Save('d:\glyph_src3.bmp');
        FRasterizator.Canvas.Resample(new_size, SIZE_BORDER);
      end;
      area := Map.InsertToMap(FRasterizator.Canvas, RectBS(0.0, 0.0, FRasterizator.Width, FRasterizator.Height));
      Key^.Rect := RectBS(area.Rect.Left + SIZE_BORDER, area.Rect.Top, area.Rect.Width - SIZE_BORDER, area.Rect.Height); // - SIZE_BORDER*2
      Key^.UV := RectToUV(Map.Picture.Width, Map.Picture.Height, Key^.Rect);
      FTexture.AddRect(Key.Code, Key.TextureRect, tsUnicodeCS2);
    end;

    Key^.Glyph^.yMin := round(raw_src^.Glyph^.yMin * ToSelfScale);

    { reset leading (distance bw left side and first pixel) if more 0 for reduce distance bw symbols
    }
    Key^.Glyph^.xMin := 0;
    if raw_src^.Glyph^.xMin >= 0 then
      Key^.Glyph^.xMin := 0
    else
      Key^.Glyph^.xMin := round(raw_src^.Glyph^.xMin * ToSelfScale);
    Key^.Glyph^.yMax := Key^.Glyph^.yMin + Key^.Rect.Height;
    Key^.Glyph^.xMax := Key^.Glyph^.xMin + Key^.Rect.Width;

    // draw quad
    Key^.Glyph^.Points.Count := 0;

    TBlackSharkTesselator.TListPoints.Add(Key^.Glyph^.Points, vec3(Key^.Glyph^.xMin, Key^.Glyph^.yMin, 0.0));
    TBlackSharkTesselator.TListPoints.Add(Key^.Glyph^.Points, vec3(Key^.Glyph^.xMin, Key^.Glyph^.yMax, 0.0));
    TBlackSharkTesselator.TListPoints.Add(Key^.Glyph^.Points, vec3(Key^.Glyph^.xMax, Key^.Glyph^.yMax, 0.0));
    TBlackSharkTesselator.TListPoints.Add(Key^.Glyph^.Points, vec3(Key^.Glyph^.xMax, Key^.Glyph^.yMin, 0.0));

    Key^.Indexes.Count := 0;
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 0);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 1);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 2);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 2);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 0);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 3);
    FTexture.EndUpdate(FSizeInPixels, true);
    if FIsVectoral then
      SetIsVectoral(false);
  end;
end;

  { TFontParser }

procedure TFontParser.Proc_cmap(hdr: PTableRec);
type
  PMainHDR = ^TMainHDR;
  TMainHDR = packed record
    Version: uint16;
    NumTables: uint16;
  end;
  PTableHDR = ^TTableHDR;
  TTableHDR = packed record
    PlatformID: uint16;
    EncodingID: uint16;
    Offset: uint32;
  end;
  {PTableHDR2 = ^TTableHDR2;
  TTableHDR2 = packed record
    TableHDR0: TTable_cmap_HDR0;
    // below:
    //  - subHeaders[ ] -	Variable-length array of subHeader structures.
    //  - glyphIndexArray[ ]	Variable-length array containing subarrays used for mapping the low byte of 2-byte characters.
  end; }

var
  MainHDR: PMainHDR;
  TableHDR: PTableHDR;
  TableHDR0: PTable_cmap_HDR0;
  i,j: int32;
  n_tables: uint16;
  ts: TTableSymbols;
  PlatformID, EncodingID: uint16;
begin
  MainHDR := PMainHDR(pData + htonl(hdr^.Offset));
  n_tables := htons(MainHDR^.NumTables);
  for i := 0 to n_tables - 1 do
  begin
    TableHDR := PTableHDR(pByte(MainHDR) + SizeOf(TMainHDR) + SizeOf(TTableHDR)*i);
    TableHDR0 := PTable_cmap_HDR0(pByte(MainHDR) + htonl(TableHDR^.Offset));
    { while not solved todo below set default table symbols UCS-2 }
    ts := tsUnicodeCS2;
    { PlatformID = 3 - Macintosh 'cmap' Table.
      Note that the use of the Macintosh  platformID is currently discouraged.
      Subtables with a Macintosh platformID are only required for backwards
      compatibility with QuickDraw and will be synthesized
      from Unicode-based subtables if ever needed. }
    PlatformID := htons(TableHDR.PlatformID);
    EncodingID := htons(TableHDR.EncodingID);

    case PlatformID of
    0: begin  // Unicode - Indicates Unicode version
      case EncodingID of
        0: ts := tsUnicodeCS2;  // Default semantics
        1: ;  // Version 1.1 semantics
        2: ;  // ISO 10646 1993 semantics (deprecated)
        3: ts := tsUnicodeCS2;  // Unicode 2.0 or later semantics (BMP only)
        4: ts := tsUnicodeCS2;  // Unicode 2.0 or later semantics (non-BMP characters allowed)
        5: ;  // Unicode Variation Sequences
        6: ;  // Full Unicode coverage (used with type 13.0 cmaps by OpenType)
      end;
      end;
    1: begin  // Macintosh - Script Manager code
      ts := tsMacintoshDefault;
      end;
    2: ;       // reserved
    3: begin  // Microsoft - Microsoft encoding
      case EncodingID of
        0:;  // Symbol
        1: ts := tsUnicodeCS2;  // Unicode BMP-only (UCS-2)
        2:;  // Shift-JIS
        3:;  // PRC
        4:;  // BigFive
        5:;  // Johab
        10: ts := tsUnicodeCS4; // Unicode UCS-4
      end;
      end;
    end;
    {
    if (PlatformID = 1) and (EncodingID = 0) then
       else
    if (PlatformID = 3) and (EncodingID = 1) then
      ts := tsUnicodeCS2;   }


    case htons(TableHDR0^.Format) of
      0: begin  // Format 0: Byte encoding table
        for j := 0 to 255 do
          FDestFont.AddPair(ts, j, (pByte(TableHDR0) + SizeOf(TTable_cmap_HDR0) + j)^);
        end;
      2: begin
      end;
      4: Proc_cmap_Format4(ts, TableHDR0);
    end;
  end;
end;

procedure TFontParser.Proc_cmap_Format4(Table: TTableSymbols; cmap_Format4: Pointer);
type
  PTableHDR4 = ^TTableHDR4;
  TTableHDR4 = packed record
    TableHDR0: TTable_cmap_HDR0;
    SegCountX2: uint16;   // 2 x segCount
    SearchRange: uint16;  // 2 x (2**floor(log2(segCount)))
    EntrySelector: uint16; // log2(searchRange/2)
    RangeShift: uint16;   // 2 x segCount - searchRange
    // below:
    // USHORT	endCount[segCount] -	End characterCode for each segment, last=0xFFFF.
    // USHORT	reservedPad -	Set to 0.
    // USHORT	startCount[segCount] -	Start character code for each segment.
    // SHORT	idDelta[segCount] -	Delta for all character codes in segment.
    // USHORT	idRangeOffset[segCount] -	Offsets into glyphIdArray or 0
    // USHORT	glyphIdArray[ ] -	Glyph index array (arbitrary length)
  end;
var
  TableHDR4: PTableHDR4;
  n_seg_count: uint16;
  end_count, start_count, id_range_offset, CodeSymbol: uint16;
  glyph_id: int32;
  id_delta: int32;
  i: int32;
  id_range_offset_ptr: pByte;
begin
  TableHDR4 := PTableHDR4(cmap_Format4);
  n_seg_count := htons(TableHDR4^.SegCountX2) div 2;
  for i := 0 to n_seg_count - 1 do
  begin
    end_count := htons(PWord(pByte(TableHDR4) + SizeOf(TTableHDR4) + i*2)^);
    start_count := htons(PWord(pByte(TableHDR4) + SizeOf(TTableHDR4) + 2 + i*2 + n_seg_count * 2)^);
    id_delta := int16(htons(PWord(pByte(TableHDR4) + SizeOf(TTableHDR4) + 2 + i*2 + n_seg_count * 4)^));
    id_range_offset_ptr := pByte(TableHDR4) + SizeOf(TTableHDR4) + 2 + i*2 + n_seg_count * 6;
    id_range_offset := htons(PWord(id_range_offset_ptr)^);
    for CodeSymbol := start_count to end_count do
    begin
      if id_range_offset = 0 then
        glyph_id := uint16(CodeSymbol + id_delta)
      else
        glyph_id := htons(PWord(id_range_offset_ptr + id_range_offset + 2*(CodeSymbol - start_count))^);
      FDestFont.AddPair(Table, CodeSymbol, glyph_id);
    end;
  end;
end;

procedure TFontParser.Proc_head(hdr: PTableRec);
type
  PTrueTypeHead = ^TTrueTypeHead;
  TTrueTypeHead = packed record
    Version: int32;
    FontRevision: int32;
    CheckSumAdjustment: int32;
    MagicNumber: int32;
    Flags: int16;
    UnitsPerEm: int16;
    Created: int64;
    Modified: int64;
    xMin: int16;
    yMin: int16;
    xMax: int16;
    yMax: int16;
    MacStyle: uint16;
    LowestRecPPEM: uint16;
    FontDirectionHint: uint16;
    IndexToLoc: uint16;
    GlyphDataFormat: uint16;
  end;
var
  h: PTrueTypeHead;
begin
  h := PTrueTypeHead(pData + htonl(hdr^.Offset));
  IndexToLoc := htons(h^.IndexToLoc);

  {FDestFont.FMaxHeight := int16(htons(h^.xMax));
  FDestFont.FMaxWidth := int16(htons(h^.yMax));
  FDestFont.FMinHeight := int16(htons(h^.xMin));
  FDestFont.FMinWidth := int16(htons(h^.yMin)); }

end;

procedure TFontParser.Proc_hhea(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_hmtx(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_maxp(hdr: PTableRec);
type
  PMaxp = ^TMaxp;
  TMaxp = packed record
    Version: int32;
    CountGlyphs: uint16;
    MaxPoints: uint16;
    MaxContours: uint16;
    MaxComponentPoints: uint16;
    MaxComponentContours: uint16;
    MaxZones: uint16;
    MaxTwilightPoints: uint16;
    MaxStorage: uint16;
    MaxFunctionDefs: uint16;
    MaxInstructionDefs: uint16;
    MaxStackElements: uint16;
    MaxSizeOfInstructions: uint16;
    MaxComponentElements: uint16;
    MaxComponentDepth: uint16;
  end;
var
  h: PMaxp;
begin
  h := PMaxp(pData + htonl(hdr^.Offset));
  CountGlyphs := htons(h^.CountGlyphs);
end;

procedure TFontParser.Proc_name(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_OS2(hdr: PTableRec);
type
  POS2Header = ^TOS2Header;
  TOS2Header = packed record
    version: uint16;		//0x0005
    xAvgCharWidth: uint16;
    usWeightClass: uint16;
    usWidthClass: uint16;
    fsType: uint16;
    ySubscriptXSize: int16;
    ySubscriptYSize: int16;
    ySubscriptXOffset: int16;
    ySubscriptYOffset: int16;
    ySuperscriptXSize: int16;
    ySuperscriptYSize: int16;
    ySuperscriptXOffset: int16;
    ySuperscriptYOffset: int16;
    yStrikeoutSize: int16;
    yStrikeoutPosition: int16;
    sFamilyClass: int16;
    panose: array[0..9] of byte;
    ulUnicodeRange1: uint32;		// Bits 0-31
    ulUnicodeRange2: uint32;    // Bits 32-63
    ulUnicodeRange3: uint32;		// Bits 64-95
    ulUnicodeRange4: uint32;		// Bits 96-127
    achVendID: array[0..3] of AnsiChar;
    fsSelection: uint16;
    usFirstCharIndex: uint16;
    usLastCharIndex: uint16;
    sTypoAscender: int16;
    sTypoDescender: int16;
    sTypoLineGap: int16;
    usWinAscent: uint16;
    usWinDescent: uint16;
    ulCodePageRange1: uint32; //	Bits 0-31
    ulCodePageRange2: uint32;	//	Bits 32-63
    sxHeight: int16;
    sCapHeight: uint16;
    usDefaultChar: uint16;
    usBreakChar: uint16;
    usMaxContext: uint16;
    usLowerOpticalPointSize: uint16;
    usUpperOpticalPointSize: uint16;
  end;
var
  h: POS2Header;
begin
  h := POS2Header(pData + htonl(hdr^.Offset));
  FDestFont.FAverageWidth := htons(h^.xAvgCharWidth);
  FDestFont.FSizeInPixels := htons(h^.sCapHeight);
  FDestFont.FSize := round(FDestFont.FSizeInPixels*72/FDestFont.FPixelsPerInch);
end;

procedure TFontParser.Proc_post(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_cvt(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_fpgm(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_glyf(hdr: PTableRec);
const
  ARG_1_AND_2_ARE_WORDS     = $01;    // If this is set, the arguments are words; otherwise, they are bytes.
  ARGS_ARE_XY_VALUES        = $02;    // If this is set, the arguments are xy values; otherwise, they are points.
  ROUND_XY_TO_GRID          = $04;    // For the xy values if the preceding is true.
  WE_HAVE_A_SCALE           = $08;    // This indicates that there is a simple scale for the component. Otherwise, scale = 1.0.
  WE_HAVE_INSTRUCTIONS      = $100;
  (* reserved               $10 *)
  MORE_COMPONENTS           = $20;    // Indicates at least one more glyph after this one
  WE_HAVE_AN_X_AND_Y_SCALE  = $40;    // The x direction will use a different scale from the y direction.
  WE_HAVE_A_TWO_BY_TWO      = $80;    // There is a 2 by 2 transformation that will be used to scale the component.
type
  TVecShi = record
    x: int32;
    y: int32;
  end;
var
  arg16: uint16;
  g: PGlyph;
  // If the number of contours is negative, this is a composite glyph.
  numberOfContours: int32;
  v: TVec3f;
  m: TMatrix2f;
  off_vec: TVecShi;
  scale: boolean;
  group_cont: int8;

  function LoadCommonGlyphArg(Pos: int32): int32;
  var
    c_pos: int32;
    {%H-}max_arg, {%H-}min_arg: TVec2f;
  begin
  c_pos := pos;
  numberOfContours := int16(ReadUInt16(GlyphPointsTable, c_pos, true));
  // calculate sign limits for glyph
  // Minimum x for coordinate data.
  min_arg.x := ReadUInt16(GlyphPointsTable, c_pos, true);
  //if g^.xMin > arg16 then
  //  g^.xMin := arg16;
  // Minimum y for coordinate data.
  min_arg.y := ReadUInt16(GlyphPointsTable, c_pos, true);
  //if g^.yMin > arg16 then
  //  g^.yMin := arg16;
  // Maximum x for coordinate data.
  max_arg.x := ReadUInt16(GlyphPointsTable, c_pos, true);
  //if g^.xMax < arg16 then
  //  g^.xMax := arg16;
  // Maximum y for coordinate data.
  max_arg.y := ReadUInt16(GlyphPointsTable, c_pos, true);
  //if g^.yMax < arg16 then
  //  g^.yMax := arg16;
  Result := c_pos - Pos;
  end;

  procedure ReturnContour(start, stop: int32);
  var
    i: int32;
    rv: TVec3f;
  begin
    for i := start to (stop div 2) - 1 do
    begin
      rv := g.Points.items[i];
      g.Points.items[i] := g.Points.items[stop - 1 - i];
      g.Points.items[stop - 1 - i] := rv;
    end;
  end;

  function LoadContours(Pos: int32): int32;
  const
    FLAG_ON_CURVE: uint8  = 1;
    FLAG_X_BYTE: uint8    = 2;
    FLAG_Y_BYTE: uint8    = 4;
    FLAG_REPEAT: uint8    = 8;
    FLAG_X_TYPE: uint8    = 16;
    FLAG_Y_TYPE: uint8    = 32;

    procedure SumAngles(var a_sum: double; const a_befor, a: double; const v_befor, v: TVec2f);
    var
      cross: TVec3f;
    begin
      cross := VecCross(v_befor, v);
      a_sum := a_sum + sign(cross.z) * abs((abs(a) - abs(a_befor)));
    end;

    function CalcAngle(var a_sum: double; a_befor: double; const v_befor, v: TVec2f): double;
    begin
      Result := arctan2(v.y, v.x);
      SumAngles(a_sum, a_befor, Result, v_befor, v);
    end;

  var
    Contour: TContour;
    c_pos: int32;
    cp_all: int32;
    cp, cp_start: int32;
    i, index_cont, end_point, begin_point: int32;
    flag: uint8;
    coord: int32;
    v_befor: TVec2f;
    v_befor_trans: TVec2f;
    v_befor_befor: TVec2f;
    v_befor_befor_trans: TVec2f;
    v_trans: TVec3f;
    v_first: TVec2f;
    angle_old_befor, angle_new_befor: double;
    angle_old, angle_new: double;
    angle_old_sum, angle_new_sum: double;
  begin
    c_pos := pos;
    cp := 0;
    flags.Count := 0;
    cp_all := g.Points.Count;
    cp_start := cp_all;
    //Points.Count := 0;
    index_cont := g.Contours.Count;
    for i := 0 to numberOfContours - 1 do
    begin
      Contour.PointIndexBegin := cp_all;
      Contour.NeedScale := scale;
      Contour.ScaleTransformations := m;
      Contour.TranslateX := off_vec.x;
      Contour.TranslateY := off_vec.y;
      Contour.Group := group_cont;
      arg16 := ReadUInt16(GlyphPointsTable, c_pos, true);
      if i > 0 then
        Contour.CountPoints := arg16 - cp
      else
        Contour.CountPoints := arg16 + 1;
      TBlackSharkTesselator.TListContours.Add(g.Contours, Contour);
      cp := arg16;
      inc(cp_all, Contour.CountPoints);
    end;
    // skip instructions
    inc(c_pos, ReadUInt16(GlyphPointsTable, c_pos, true));
    i := cp_start;
    // read all flags
    while i < cp_all do
    begin
      flag := ReadUInt8(GlyphPointsTable, c_pos);
      flags.Add(flag);
      inc(i);
      // flag repeat ???
      if (flag and FLAG_REPEAT <> 0) then
      begin
        // count repeat
        cp := ReadUInt8(GlyphPointsTable, c_pos);
        while cp > 0 do
        begin
          flags.Add(flag);
          dec(cp);
          inc(i);
        end;
      end;
    end;
    coord := 0;
    // read all x coordinates
    for i := 0 to flags.Count - 1 do
    begin
      flag := flags.Items[i];
      // read coordinate
      if (flag and FLAG_X_BYTE <> 0) then
      begin
        if (flag and FLAG_X_TYPE <> 0) then
          inc(coord, ReadUInt8(GlyphPointsTable, c_pos))
        else
          dec(coord, ReadUInt8(GlyphPointsTable, c_pos));
      end else
      if (flag and FLAG_X_TYPE = 0) then
        inc(coord, ReadInt16(GlyphPointsTable, c_pos, true));// else
        //dec(coord, ReadInt16(GlyphPointsTable, c_pos, true));
      v.x := coord;
      v.z := 0.0;
      TBlackSharkTesselator.TListPoints.Add(g.Points, v);
    end;
    coord := 0;
    begin_point := g.Contours.Items[index_cont].PointIndexBegin;
    end_point := begin_point + g.Contours.Items[index_cont].CountPoints;
    angle_old := 0;
    angle_new := 0;
    angle_old_sum := 0;
    angle_new_sum := 0;
    angle_old_befor := 0;
    angle_new_befor := 0;
    v_befor := vec2(0.0, 0.0);
    v_befor_befor := v_befor;
    v_befor_trans := vec2(0.0, 0.0);
    v_befor_befor_trans := v_befor_trans;
    v_first := vec2(0.0, 0.0);
    // read all y coordinates
    for i := 0 to flags.Count - 1 do
    begin
      flag := flags.Items[i];

      // read y coordinate
      if (flag and FLAG_Y_BYTE <> 0) then
      begin
        if (flag and FLAG_Y_TYPE <> 0) then
          inc(coord, ReadUInt8(GlyphPointsTable, c_pos))
        else
          dec(coord, ReadUInt8(GlyphPointsTable, c_pos));
      end else
      if (flag and FLAG_Y_TYPE = 0) then
        inc(coord, ReadInt16(GlyphPointsTable, c_pos, true));// else
        //dec(coord, ReadInt16(GlyphPointsTable, c_pos, true));

      v := g.Points.items[cp_start+i];
      v.y := coord;
      v.z := 0.0;

      if scale then
        v_trans := m*v
      else
        v_trans := v;

      v_trans.x := v_trans.x + off_vec.x;
      v_trans.y := v_trans.y + off_vec.y;

      if i + cp_start > begin_point then
      begin
        v_befor_trans := TVec2f(v_trans) - v_befor_trans;
        angle_new := arctan2(v_befor_trans.y, v_befor_trans.x);
        v_befor := TVec2f(v) - v_befor;
        angle_old := arctan2(v_befor.y, v_befor.x);

        if i - cp_start > 1 then
        begin
          // current contour vector
          SumAngles(angle_old_sum, angle_old_befor, angle_old, v_befor_befor, v_befor);
          // Transformed contour vector
          SumAngles(angle_new_sum, angle_new_befor, angle_new, v_befor_befor_trans, v_befor_trans);
        end else
        begin
          //angle_old_sum := angle_old;
          //angle_new_sum := angle_new;
        end;

        if i + cp_start = end_point then
        begin // new contour
          CalcAngle(angle_old_sum, angle_old, v_befor_befor, v_first - TVec2f(v));
          CalcAngle(angle_new_sum, angle_new, TVec2f(g.Points.items[end_point - 1]) - TVec2f(g.Points.items[cp_start + i - 2]), TVec2f(g.Points.items[begin_point]) - TVec2f(g.Points.items[end_point - 1]));
          g.Contours.Items[index_cont].AsClockArr := angle_new_sum < 0;
          inc(index_cont);
          // check reflection contour
          if scale and (((angle_old > 0) and (angle_new < 0)) or ((angle_old < 0) and (angle_new > 0))) then
          begin
            ReturnContour(begin_point, end_point);
            g.Contours.Items[index_cont].AsClockArr := not g.Contours.Items[index_cont].AsClockArr;
          end;
          begin_point := g.Contours.Items[index_cont].PointIndexBegin;
          end_point := begin_point + g.Contours.Items[index_cont].CountPoints;
          angle_old := 0;
          angle_new := 0;
          angle_old_sum := 0;
          angle_new_sum := 0;
        end;
      end else
      begin
        v_first := TVec2f(v);
      end;

      angle_old_befor := angle_old;
      angle_new_befor := angle_new;
      v_befor_befor := v_befor;
      v_befor_befor_trans := v_befor_trans;
      v_befor_trans := TVec2f(v_trans);
      v_befor := TVec2f(v);
      v_trans.z := flag and FLAG_ON_CURVE;
      g.Points.items[cp_start+i] := v_trans;
      CheckGlyphBoundary(g, v_trans);
    end;
    // calc angle of last vector of last contour; for a real, we need yet
    // to calc here angle b/w last and first vectors, but don't do, because collected
    // values enough to know clockwise or not, points of the contour placed
    CalcAngle(angle_old_sum, angle_old, v_befor_befor, v_first - TVec2f(v));
    CalcAngle(angle_new_sum, angle_new, v_befor_befor_trans, TVec2f(g.Points.items[begin_point]) - TVec2f(v_trans));
    g.Contours.Items[index_cont].AsClockArr := angle_new_sum < 0;
    // check reflection contour
    if scale and (((angle_old > 0) and (angle_new < 0)) or ((angle_old < 0) and (angle_new > 0))) then
    begin
      ReturnContour(begin_point, end_point);
      g.Contours.Items[index_cont].AsClockArr := not g.Contours.Items[index_cont].AsClockArr;
    end;
    Result := c_pos - Pos;
  end;

  procedure LoadComposite(Pos: int32);
  var
    off, off_: int32;
    comp_index: int32;
    comp_flags, arg1, arg2: uint16;
  begin
    off := Pos;
    repeat
      off_vec.x := 0;
      off_vec.y := 0;
      m := IDENTITY_MAT2F;
      scale := false;
      comp_flags := ReadUInt16(GlyphPointsTable, off, true);
      comp_index := ReadUInt16(GlyphPointsTable, off, true);

      // further read arguments in dependence from compflags
      if (comp_flags and ARG_1_AND_2_ARE_WORDS <> 0) then
      begin // words
        arg1 := ReadUInt16(GlyphPointsTable, off, true);
        arg2 := ReadUInt16(GlyphPointsTable, off, true);
      end else
      begin // bytes
        arg1 := ReadUInt8(GlyphPointsTable, off);
        arg2 := ReadUInt8(GlyphPointsTable, off);
      end;

      if (comp_flags and ARGS_ARE_XY_VALUES <> 0) then
      begin
        if (comp_flags and ROUND_XY_TO_GRID <> 0) then
        begin
          off_vec.x := (arg1 shr 5) shl 5 + 32;
          off_vec.y := (arg2 shr 5) shl 5 + 32;
        end else
        begin
          off_vec.x := arg1;
          off_vec.y := arg2;
        end;
      end else
      begin
        off_vec.x := 0;
        off_vec.y := 0;
      end;


      if (comp_flags and WE_HAVE_A_SCALE <> 0) then
      begin
        m.M[0, 0] := Read2Dot14(GlyphPointsTable, off, true);
        m.M[1, 1] := m.M[0, 0];
        scale := true;
      end;

      if (comp_flags and WE_HAVE_AN_X_AND_Y_SCALE <> 0) then
      begin
        m.M[0, 0] := Read2Dot14(GlyphPointsTable, off, true);
        m.M[1, 1] := Read2Dot14(GlyphPointsTable, off, true);
        scale := true;
      end;

      if (comp_flags and WE_HAVE_A_TWO_BY_TWO <> 0) then
      begin
        m.M[0, 0] := Read2Dot14(GlyphPointsTable, off, true);
        m.M[0, 1] := Read2Dot14(GlyphPointsTable, off, true);
        m.M[1, 0] := Read2Dot14(GlyphPointsTable, off, true);
        m.M[1, 1] := Read2Dot14(GlyphPointsTable, off, true);
        scale := true;
      end;

      if comp_flags and WE_HAVE_INSTRUCTIONS <> 0 then
      begin
        arg1 := ReadUInt16(GlyphPointsTable, off, true);
        inc(off, arg1);
      end;

      off_ := GlyphOffsets.Items[comp_index] {%H-}+ LoadCommonGlyphArg(GlyphOffsets.Items[comp_index]);

      {if (comp_flags and ARGS_ARE_XY_VALUES <> 0) then
      //if (min_arg.x < 0) and (max_arg.x > 0) and (min_arg.x/max_arg.x < -0.7) then
        begin
        off_vec.x := off_vec.x - min_arg.x;
        off_vec.y := off_vec.y + min_arg.y;
        end;   }

      if numberOfContours < 0 then
        LoadComposite(off_)
      else
        LoadContours(off_);

      inc(group_cont);

    until (comp_flags and MORE_COMPONENTS = 0);
  end;

var
  index: int32;
  offset: int32;
  off, len: uint32;
begin
  off := htonl(hdr^.Offset);
  len := htonl(hdr^.Length);
  GlyphPointsTable := pByte(pData + off);
  flags.Count := 0;
  for index := 0 to CountGlyphs - 1 do
  begin
    offset := GlyphOffsets.Items[index];
    if (uint32(offset) >= len) or (off + uint32(offset) >= size_f) then
      break;
    g := FDestFont.GetRawGlyph(index);
    { "... The missing character is commonly represented by a blank box or a space.
      If the font does not contain an outline for the missing character, then
      the first and second offsets should have the same value. This also applies
      to any other characters without an outline, such as the space character.
      If a glyph has no outline, then loca[n] = loca [n+1] ... "
      © 2008 Microsoft Corporation }
    if (offset = int32(GlyphOffsets.Items[index + 1])) then
      continue;
    inc(offset, LoadCommonGlyphArg(offset));
    group_cont := 0;
    // simple glyph ???
    if (numberOfContours >= 0) then
    begin
      off_vec.x := 0;
      off_vec.y := 0;
      m := IDENTITY_MAT2F;
      scale := false;
      LoadContours(offset);
    end else
    begin
      LoadComposite(offset);
    end;
    FDestFont.CheckBoundary(g);
  end;
end;

procedure TFontParser.Proc_loca(hdr: PTableRec);
var
  p: Pointer;
  i: int32;
begin
  GlyphOffsets.Count := 0;
  p := pByte(pData + htonl(hdr^.Offset));
  if IndexToLoc = 0 then
    for i := 0 to CountGlyphs - 1 do
      GlyphOffsets.Add(htons(pWord(pByte(p) + i*SizeOf(Word))^)*2) else
    for i := 0 to CountGlyphs - 1 do
      GlyphOffsets.Add(htonl(PCardinal(pByte(p) + i*SizeOf(Cardinal))^));
end;

procedure TFontParser.Proc_prep(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_gasp(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_CFF(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_VORG(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_SVG(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_BASE(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_GDEF(hdr: PTableRec);
type
  PGDEFHeader10 = ^TGDEFHeader10;
  TGDEFHeader10 = packed record
    Version: uint32;
    GlyphClassDef: uint16; //	Offset to class definition table for glyph type-from beginning of GDEF header (may be NULL)
    AttachList: uint16; //	Offset to list of glyphs with attachment points-from beginning of GDEF header (may be NULL)
    LigCaretList: uint16; //	Offset to list of positioning points for ligature carets-from beginning of GDEF header (may be NULL)
    MarkAttachClassDef: uint16; //	Offset to class definition table for mark attachment type-from beginning of GDEF header (may be NULL)  end;
  end;
  {PGDEFHeader12 = ^TGDEFHeader12;
  TGDEFHeader12 = packed record
    Header10: TGDEFHeader10;
    MarkGlyphSetsDef: uint32;	// Offset to the table of mark set definitions - from beginning of GDEF header (may be NULL)
  end;}
  PClassDefFormat2 = ^TClassDefFormat2;
  TClassDefFormat2 = packed record
    ClassFormat: uint16;
    ClassRangeCount: uint16;
  end;

var
  hdr10: PGDEFHeader10;
  frm_tbl2: PClassDefFormat2;
  offset: uint32;
  i, count: int32;
begin
  hdr10 := PGDEFHeader10(pData + htonl(hdr^.Offset));
  if hdr10^.GlyphClassDef <> 0 then
  begin
    offset := htons(hdr10^.GlyphClassDef);
    frm_tbl2 := PClassDefFormat2(pByte(hdr10) + offset);
    count := htons(frm_tbl2^.ClassRangeCount);
    // not need to do this ??? FreeType is not doing
    for i := 0 to count - 1 do
    begin

      end;
    end;
end;

procedure TFontParser.Proc_GPOS(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_GSUB(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_JSTF(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_MATH(hdr: PTableRec);
begin

end;

procedure TFontParser.LoadTable(const Name: AnsiString);
var
  Proc: PProcParse;
begin
  Signs.Find(Name, Proc);
  if Proc = nil then
    raise Exception.Create('Can not find "' + AnsiToString(Name) + '" table!');
  Proc^.MetodParse(Proc^.TableRec);
end;

{
procedure TFontParser.Proc_CommonTable(PtrBegin: Pointer);
begin

end;
}

procedure TFontParser.Proc_DSIG(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_hdmx(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_kern(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_LTSH(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_PCLT(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_VDMX(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_vhea(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_vmtx(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_COLR(hdr: PTableRec);
begin

end;

procedure TFontParser.Proc_CPAL(hdr: PTableRec);
begin

end;

function TFontParser.LoadTTFont(const FileName: string; DestFont: TTrueTypeFont): boolean;
var
  TCHeader: PTCHeader;
  TableRec: PTableRec;
  pos_r: uint32;
  i: int32;
  s: TMemoryStream;
  fn_new: string;
  Proc: PProcParse;
  CountTables: int16;
begin
  Result := true;
  //Symblols.Count := 0;
  fn_new := GetFileExistsPath(FileName, 'Fonts');
  FDestFont := DestFont;
  s := TMemoryStream.Create;
  try
    s.LoadFromFile(fn_new);
    pData := s.Memory;
    TCHeader := PTCHeader(pData);
    size_f := s.Size;
    pos_r := SizeOf(TTCHeader);
    CountTables := htons(TCHeader^.NumTables);
    // in begin load information about all tables
    for i := 0 to CountTables - 1 do
    begin
      TableRec := PTableRec(pData + pos_r);
      inc(pos_r, SizeOf(TTableRec));
      if Signs.Find(int32(TableRec^.Signs), Proc) then
      begin
        //Proc^.MetodParse(TableRec);
        Proc^.Length := TableRec^.Length;
        Proc^.Offset := TableRec^.Offset;
        Proc^.TableRec := TableRec;
      end;
    end;
    // now:
    // 1. load global information about the font
    LoadTable('head');
    // 2. OS/2 and Windows Metrics
    LoadTable('OS/2');
    // 2. load limits for the font
    LoadTable('maxp');
    // 3. load offsets of glyphs
    LoadTable('loca');
    // 4. load points of symbvols
    LoadTable('glyf');
    // 5. load table conversion glyph code to index
    LoadTable('cmap');
    // 6. TODO - load
    LoadTable('kern');
    LoadTable('GPOS');
  finally
    s.Free;
  end;
end;

constructor TFontParser.Create;

  function CreateMP(MetodParse: TMetodParse): PProcParse;
  begin
  new(Result);
  Result^.MetodParse := MetodParse;
  Result^.Length := 0;
  Result^.Offset := 0;
  Result^.TableRec := nil;
  end;

begin
  (*
  Required Tables

  Tag	Name
  cmap	Character to glyph mapping
  head	Font header
  hhea	Horizontal header
  hmtx	Horizontal metrics
  maxp	Maximum profile
  name	Naming table
  OS/2	OS/2 and Windows specific metrics
  post	PostScript information

  For OpenType fonts based on TrueType outlines, the following tables are used:
  Tables Related to TrueType Outlines

  Tag	Name
  cvt	Control Value Table
  fpgm	Font program
  glyf	Glyph data
  loca	Index to location
  prep	CVT Program
  gasp	Grid-fitting/Scan-conversion (optional table)

  The PostScript font extensions define a new set of tables containing data specific to PostScript fonts that are used instead of the tables listed above.
  Tables Related to PostScript Outlines

  Tag	Name
  CFF	PostScript font program (compact font format)
  VORG	Vertical Origin (optional table)

  It is strongly recommended that CFF OpenType fonts that are used for vertical writing include a Vertical Origin ('VORG') table. Multiple Master support in OpenType, has been discontinued as of version 1.3 of the specification. The 'fvar', 'MMSD', 'MMFX' tables have hence been removed.
  Table related to SVG outlines

  Tag	Name
  SVG	The SVG (Scalable Vector Graphics) table

  Tables Related to Bitmap Glyphs

  Tag	Name
  EBDT	Embedded bitmap data
  EBLC	Embedded bitmap location data
  EBSC	Embedded bitmap scaling data
  CBDT	Color bitmap data
  CBLC	Color bitmap location data
  OpenType fonts may also contain bitmaps of glyphs, in addition to outlines. Hand-tuned bitmaps are especially useful in OpenType fonts for representing complex glyphs at very small sizes. If a bitmap for a particular size is provided in a font, it will be used by the system instead of the outline when rendering the glyph. (Note: ATM does not currently support hinted bitmaps in OpenType fonts.)
  There are also several optional tables that support vertical layout as well as other advanced typographic functions:
  Advanced Typographic Tables

  Tag	Name
  BASE	Baseline data
  GDEF	Glyph definition data
  GPOS	Glyph positioning data
  GSUB	Glyph substitution data
  JSTF	Justification data
  MATH	Math layout data
  For information on common table formats, please see OpenType Layout Common Table Formats .
  Other OpenType Tables

  Tag	Name
  DSIG	Digital signature
  hdmx	Horizontal device metrics
  kern	Kerning
  LTSH	Linear threshold data
  PCLT	PCL 5 data
  VDMX	Vertical device metrics
  vhea	Vertical Metrics header
  vmtx	Vertical Metrics
  COLR	Color table
  CPAL	Color palette table
  *)
  Signs := TBinTree<PProcParse>.Create;
  Signs.Add(AnsiString('DSIG'), CreateMP(Proc_DSIG)); //
  Signs.Add(AnsiString('GDEF'), CreateMP(Proc_GDEF));
  Signs.Add(AnsiString('cmap'), CreateMP(Proc_cmap));
  Signs.Add(AnsiString('BASE'), CreateMP(Proc_BASE));
  Signs.Add(AnsiString('CFF '), CreateMP(Proc_CFF));
  Signs.Add(AnsiString('COLR'), CreateMP(Proc_COLR));
  Signs.Add(AnsiString('CPAL'), CreateMP(Proc_CPAL));
  Signs.Add(AnsiString('cvt '), CreateMP(Proc_cvt));
  Signs.Add(AnsiString('fpgm'), CreateMP(Proc_fpgm));
  Signs.Add(AnsiString('gasp'), CreateMP(Proc_gasp));
  Signs.Add(AnsiString('glyf'), CreateMP(Proc_glyf));
  Signs.Add(AnsiString('GPOS'), CreateMP(Proc_GPOS));
  Signs.Add(AnsiString('GSUB'), CreateMP(Proc_GSUB));
  Signs.Add(AnsiString('hdmx'), CreateMP(Proc_hdmx));
  Signs.Add(AnsiString('head'), CreateMP(Proc_head));
  Signs.Add(AnsiString('hhea'), CreateMP(Proc_hhea));
  Signs.Add(AnsiString('hmtx'), CreateMP(Proc_hmtx));
  Signs.Add(AnsiString('JSTF'), CreateMP(Proc_JSTF));
  Signs.Add(AnsiString('kern'), CreateMP(Proc_kern));
  Signs.Add(AnsiString('loca'), CreateMP(Proc_loca));
  Signs.Add(AnsiString('LTSH'), CreateMP(Proc_LTSH));
  Signs.Add(AnsiString('MATH'), CreateMP(Proc_MATH));
  Signs.Add(AnsiString('maxp'), CreateMP(Proc_maxp));
  Signs.Add(AnsiString('name'), CreateMP(Proc_name));
  Signs.Add(AnsiString('OS/2'), CreateMP(Proc_OS2));
  Signs.Add(AnsiString('PCLT'), CreateMP(Proc_PCLT));
  Signs.Add(AnsiString('post'), CreateMP(Proc_post));
  Signs.Add(AnsiString('prep'), CreateMP(Proc_prep));
  Signs.Add(AnsiString('SVG '), CreateMP(Proc_SVG));
  Signs.Add(AnsiString('VDMX'), CreateMP(Proc_VDMX));
  Signs.Add(AnsiString('vhea'), CreateMP(Proc_vhea));
  Signs.Add(AnsiString('vmtx'), CreateMP(Proc_vmtx));
  Signs.Add(AnsiString('VORG'), CreateMP(Proc_VORG));
  GlyphOffsets := TListVec<int32>.Create;
  flags := TListVec<uint8>.Create;
end;

destructor TFontParser.Destroy;
var
  proc: PProcParse;
begin
  Signs.Iterator.SetToBegin(proc);
  while proc <> nil do
    begin
    dispose(proc);
    Signs.Iterator.Next(proc);
    end;
  Signs.Free;
  GlyphOffsets.Free;
  //Symblols.Free;
  flags.free;
  //TListGlyphPoints.UnInit(@Points);
  inherited;
end;

{$endregion}

{ BSFontManager }

class function BSFontManager.GetFont(const FileName: string; ClassFont: TClassFont): IBlackSharkFont;
var
  sn: string;
  src: TBlackSharkCustomFont;
  res: TBlackSharkCustomFont;
begin
  // found raw data font
  sn := ChangeFileExt(ExtractFileName(FileName), '');
  res := GetRawFontData(sn);
  if (res = nil) then
  begin
    // create prototype
    res := ClassFont.Create(sn);
    if not res.Load(GetFilePath(FileName, 'Fonts')) then
    begin
      FreeAndNil(res);
      exit;
    end;
  end;
  src := res;
  { inc references on raw data font (so we store as class, not as interface) }
  res._AddRef;
  res := ClassFont.Create(sn);
  // copy raw data
  res.Assign(src);
  res.Size := 10;
  Result := res;
end;

class function BSFontManager.GetFonts: TListVec<string>;
var
  res: int32;
  sr: TSearchRec;
begin
  if FFonts = nil then
    FFonts := TListVec<string>.Create;
  FFonts.Count := 0;
  res := FindFirst(AppPath + 'Fonts\*.ttf', $01, sr);
  while res = 0 do
  begin
    if (sr.name <> '.') and (sr.name <> '..') then
    begin
      if ((sr.Attr and faDirectory) = 0) then
        FFonts.Add(ChangeFileExt(sr.Name, ''));
    end;
    res := FindNext(sr);
  end;
  FindClose(sr);
  Result := FFonts;
end;

class function BSFontManager.GetCountFontTextures: int32;
begin
  Result := Textures.Count;
end;

class function BSFontManager.GetDefaultFont: IBlackSharkFont;
begin
  CreateDefaultFont;
  Result := FDefaultFont;
end;

class function BSFontManager.GetFont(const Name: string): IBlackSharkFont;
var
  f: string;
  res: TBlackSharkCustomFont;
begin
  FontNames.Find(AnsiUpperCase(Name), res);
  if res = nil then
  begin
    if ExtractFileExt(Name) = '' then
      f := GetFilePath(Name + '.ttf', 'Fonts')
    else
      f := GetFilePath(Name, 'Fonts');
    if FileExists(f) then
      Result := GetFont(f, TTrueTypeRasterFont); 
  end else
    Result := res;
end;

class function BSFontManager.GetRawFontData(const Name: string): TBlackSharkCustomFont;
begin
  RawFonts.Find(AnsiUpperCase(Name), Result);
end;

class function BSFontManager.GetTexture(const Name: string; FontSize: int32; CountRects: uint32): IFontTexture;
var
  edge: int32;
  res: TFontTexture;
begin
  if not Textures.Find(Name, res) then
  begin
    edge := Ceil(Sqrt(CountRects)) * FontSize;
    res := TFontTexture.Create(edge, edge, FontSize > 9, Name);
    Textures.Add(res.Texture.Name, res);
    Result := res;
  end else
    Result := res;
end;

class procedure BSFontManager.OnUpdateFont(const OldShortName: string; const Font: TBlackSharkCustomFont);
var
  f: TBlackSharkCustomFont;
begin
  if (OldShortName <> '') then
    FontNames.Remove(AnsiUpperCase(OldShortName));
  if FontNames.Find(AnsiUpperCase(Font.ShortName), f) then
    raise Exception.Create('The font already exists!');
  FontNames.Add(AnsiUpperCase(Font.ShortName), Font);
end;

class procedure BSFontManager.OnCreateFont(const Font: TBlackSharkCustomFont);
var
  res: TBlackSharkCustomFont;
begin
  AllFonts.Add(Font);
  if Font.RawDataFont = nil then
    RawFonts.Add(AnsiUpperCase(Font.ShortName), Font)
  else
  if not FontNames.Find(AnsiUpperCase(Font.ShortName), res) then
    FontNames.Add(AnsiUpperCase(Font.ShortName), Font);
end;

class procedure BSFontManager.OnDestroyFont(const Font: TBlackSharkCustomFont);
begin

  AllFonts.Remove(Font, otFromEnd);

  if (Font.RawDataFont <> nil) then
  begin
    if (Font.RawDataFont.RefCount = 1) then
      RawFonts.Remove(AnsiUpperCase(Font.ShortName));
    Font.RawDataFont._Release;
  end;
  FontNames.Remove(AnsiUpperCase(Font.ShortName));

end;

class function BSFontManager.AddFont(const FileName: string): IBlackSharkFont;
var
  ext: string;
begin
  ext := AnsiUpperCase(ExtractFileExt(FileName));
  if ext = '.BSF' then
    Result := GetFont(FileName, TBlackSharkRasterFont)
  else
  if ext = '.TTF' then
    Result := GetFont(FileName, TTrueTypeRasterFont)
  else
    raise Exception.Create('Uncknown font type!');
end;

class function BSFontManager.AnsiToUTF16(Code: uint8;
  CodePage: TCodePage): int32;
var
  sl: TStringList;
  fn: string;
  tbl: PConvertTable;
  i: int32;
begin
  if ConvertTables[CodePage] = nil then
  begin
    fn := GetFileExistsPath(CODE_PAGE_NAMES[CodePage]+'ToUTF16.txt', 'Fonts');
    if not FileExists(fn) then
      raise Exception.Create('Do not found file containing convertion table - "' + fn +'". You may create file for convertion independently with use example "cpCyrillicToUTF16.txt"');

    sl := TStringList.Create;
    try
      sl.LoadFromFile(fn);
      new(tbl);
      ConvertTables[CodePage] := tbl;
      for i := 128 to 255 do
      begin
        if sl.Strings[i-128] <> '' then
        begin
          if TryStrToInt('$' + sl.Strings[i-128], Result) then // HexStringToBuf(sl.Strings[i-128], SizeOf(Result), @Result) > 0
            tbl^[i] := Result else
            tbl^[i] := -1;
        end else
          tbl^[i] := -1;
      end;

    finally
      sl.Free;
    end;
  end;
  if Code < $80 then
    Result := Code
  else
    Result := ConvertTables[CodePage]^[Code];
end;

class procedure BSFontManager.ClearConvertTables;
var
  cp: TCodePage;
begin
  for cp := Low(TCodePage) to High(TCodePage) do
    if ConvertTables[cp] <> nil then
      dispose(ConvertTables[cp]);
end;

class procedure BSFontManager.InitConvertTables;
var
  cp: TCodePage;
begin
  for cp := Low(TCodePage) to High(TCodePage) do
    ConvertTables[cp] := nil;
end;

class constructor BSFontManager.Create;
begin
  FontNames := TBinTree<TBlackSharkCustomFont>.Create;
  RawFonts := TBinTree<TBlackSharkCustomFont>.Create;
  AllFonts := TListVec<TBlackSharkCustomFont>.Create(@PtrCmp);
  Textures := TBinTree<TFontTexture>.Create;
  InitConvertTables;
end;

class destructor BSFontManager.Destroy;
begin

  FFonts.Free;
  FDefaultFont := nil;

  if AllFonts.Count > 0 then
    raise Exception.Create('Not all fonts were released! It means that some objects which use fonts didn''t release');

  AllFonts.Free;
  FontNames.Free;
  RawFonts.Free;
  Textures.Free;
  ClearConvertTables;
end;

class procedure BSFontManager.FreeTexture(const Texture: TFontTexture);
begin
  if Texture = nil then
    exit;
  Textures.Remove(Texture.Texture.Name);
end;

class function BSFontManager.CreateDefaultFont: IBlackSharkFont;
begin
  //Result := GetFont('Base.bsf', TBlackSharkRasterFont);   // DejaVuSans.ttf TTrueTypeRasterFont
  Result := GetFont(DEFAULT_FONT, TTrueTypeRasterFont);
  if FDefaultFont = nil then
    FDefaultFont := Result;
  //Result := GetFont('DejaVuSans.ttf', TTrueTypeRasterFont); // times
  //TTrueTypeRasterFont(FDefaultFont).Rasterizator.SamplerFilter.InterpolationMode := imLanczos;
end;

{ TBlackSharkCustomFont }

constructor TBlackSharkCustomFont.Create(const AName: string);
begin
  inherited Create;
  //FKeys := TListVec<PKeyInfo>.Create;
  FUsers := 0;
  FGlyphs := TListGlyphs.Create;
  FShortName := AName;
  FScale := 1.0;
  //FSize := SIZE_DESTINATION_CANVAS_DEFAULT;
  FSize := 10;
  //FPixelsPerInch := 96;
  FPixelsPerInch := GetPixelsPerInch;
  FSizeInPixels := round(FSize*FPixelsPerInch/72);
  FCodePage := TCodePage.cpCyrillic;
  if FShortName <> '' then
    FID := GetHashBlackSharkS(FShortName)
  else
    FID := high(uint32);
  FOnChangeEvent := CreateEmptyEvent;
  RawDataFont := BSFontManager.GetRawFontData(AName);
  BSFontManager.OnCreateFont(Self);
end;

procedure TBlackSharkCustomFont.DoCreateTexture(FontSize: int32);
var
  s: string;
  sqwr: int32;
  edge: int32;
begin
  s := IntToStr(FontSize) + FFileName;
  if Assigned(FTexture) then
  begin
    if FTexture.Texture.Name = s then
    begin
      sqwr := FTexture.Texture.Picture.Canvas.Square;
      edge := Ceil(Sqrt(RawDataFont.FCountGlyphs + 10)) * FontSize + 2 + SIZE_BORDER*2;
      if edge*edge > sqwr then
      begin
        ObserverChangeTexture := nil;
        FTexture := nil;
      end else
        exit;
    end;
  end;

  if Assigned(RawDataFont) then
    FTexture := BSFontManager.GetTexture(s, FontSize + 2 + SIZE_BORDER*2, RawDataFont.FCountGlyphs + 10)
  else
    FTexture := BSFontManager.GetTexture(s, FontSize + 2 + SIZE_BORDER*2, FCountGlyphs);

  Map := FTexture.Texture as TBlackSharkTextureMap;
  Map.BorderWidth := 0;
  FTexture.Texture.TrilinearFilter := false;
  ObserverChangeTexture := CreateEmptyObserver(FTexture.OnChangeEvent, OnChangeTexture);
end;

procedure TBlackSharkCustomFont.CreateTexture;
begin
  DoCreateTexture(FSizeInPixels);
end;

function TBlackSharkCustomFont.AddPair(TableSymbols: TTableSymbols; Code: uint32; IndexToGlyph: int32): PKeyInfo;
begin
  if FKeys[TableSymbols] = nil then
    FKeys[TableSymbols] := TListVec<PKeyInfo>.Create;
  if (FKeys[TableSymbols].Items[Code] <> nil) then
    dispose(FKeys[TableSymbols].Items[Code]);
  new(Result);
  FillChar(Result^, SizeOf(TKeyInfo), 0);
  Result^.Code := Code;
  Result^.Glyph := nil;
  Result^.GlyphIndex := IndexToGlyph;
  TBlackSharkTesselator.TListIndexes.Create(Result^.Indexes);
  FKeys[TableSymbols].Items[Code] := Result;
end;

procedure TBlackSharkCustomFont.AfterConstruction;
begin
  inherited;
  CalcScale;
end;

procedure TBlackSharkCustomFont.Assign(Font: TBlackSharkCustomFont);
var
  i: int32;
  ts: TTableSymbols;
  ki: PKeyInfo;
  //s: BSFloat;
begin
  for ts := low(TTableSymbols) to high(TTableSymbols) do
  begin
    if Font.FKeys[ts] = nil then
      continue;
    for i := 0 to Font.FKeys[ts].Count - 1 do
      if Font.FKeys[ts].Items[i] <> nil then
      begin
        ki := AddPair(ts, Font.FKeys[ts].Items[i].Code, Font.FKeys[ts].Items[i].GlyphIndex);
        ki^.Rect := Font.FKeys[ts].Items[i].Rect;
        ki^.UV := Font.FKeys[ts].Items[i].UV;
      end;
  end;
  //s := FSize / Font.Size;
  {FMaxHeight := Font.FScale * Font.FMaxHeight;
  FMaxWidth := Font.FScale * Font.FMaxWidth;
  FMinHeight := Font.FScale * Font.FMinHeight;
  FMinWidth := Font.FScale * Font.FMinWidth;  }
  FScale := Font.FScale;
  FAverageWidth := round(Font.FScale * Font.FAverageWidth);
  FAverageHeight := round(Font.FScale * Font.FAverageHeight);
  //FIsVectoral := Font.FIsVectoral;
  FSize := Font.FSize;
  FSizeInPixels := Font.FSizeInPixels;
  FFileName := Font.FFileName;
  FShortName := Font.FShortName;
  //CalcContours;
end;

function TBlackSharkCustomFont.AddGlyph(Index: int32): PGlyph;
begin
  if FGlyphs.Items[Index] <> nil then
    exit(FGlyphs.Items[Index]);
  Result := CreateGlyph;
  FGlyphs.Items[Index] := Result;
  inc(FCountGlyphs);
end;

function TBlackSharkCustomFont.GetAverageHeight: BSFloat;
begin
  Result := FAverageHeight;
end;

function TBlackSharkCustomFont.GetAverageWidth: BSFloat;
begin
  Result := FAverageWidth;
end;

function TBlackSharkCustomFont.GetCodePage: TCodePage;
begin
  Result := FCodePage;
end;

function TBlackSharkCustomFont.GetCountKeys: int32;
begin
  Result := FKeys[tsUnicodeCS2].Count;
end;

function TBlackSharkCustomFont.GetIsVectoral: boolean;
begin
  Result := FIsVectoral;
end;

function TBlackSharkCustomFont.GetKey(CodeUTF16: uint16): PKeyInfo;
var
  code: int32;
begin
  if FKeys[tsUnicodeCS2] <> nil then
  begin
    if FCodePage = cpUnicode then
    begin
      Result := FKeys[tsUnicodeCS2].Items[CodeUTF16];
    end else
    begin
      if CodeUTF16 > 255 then
        raise Exception.Create('Too many symbol code !!!');
      { TODO: tables translate for all code pages }
      code := BSFontManager.AnsiToUTF16(CodeUTF16, FCodePage);
      if (code >= 0) then
        Result := FKeys[tsUnicodeCS2].Items[code]
      else
        Result := nil;
    end;

    if Assigned(Result) and (((Result.Glyph = nil) or (Result.Glyph.Points.Count = 0)) or (Result.Indexes.Count = 0)) then
      Triangulate(Result);

  end else
    Result := nil;
end;

function TBlackSharkCustomFont.GetKeyWideChar(CodeUTF16: WideChar): PKeyInfo;
begin
  if FKeys[tsUnicodeCS2] <> nil then
    Result := FKeys[tsUnicodeCS2].Items[int32(CodeUTF16)]
  else
    Result := nil;

  if (Result <> nil) and ((Result.Glyph = nil) or (Result.Glyph.Points.Count = 0)) then
    Triangulate(Result);
end;

function TBlackSharkCustomFont.GetName: string;
begin
  Result := FShortName;
end;

function TBlackSharkCustomFont.GetOnChangeEvent: IBEmptyEvent;
begin
  Result := FOnChangeEvent;
end;

function TBlackSharkCustomFont.GetRawKey(CodeUTF16: uint16): PKeyInfo;
begin
  if RawDataFont <> nil then
    Result := RawDataFont.Key[CodeUTF16] else
    Result := nil;
end;

function TBlackSharkCustomFont.GetSize: BSFloat;
begin
  Result := FSize;
end;

function TBlackSharkCustomFont.GetSizeInPixels: int16;
begin
  Result := FSizeInPixels;
end;

procedure TBlackSharkCustomFont.GetTextSize(const Text: string; out CountChars: int32;
  out TextWidth, TextHeight: BSFloat; out MaxLenWordInChars: int32;
  out MaxLenWordInPixels: BSFloat;
  DistanceBWChars: BSFloat);
var
  ch: WideChar;
  KeyInfo: PKeyInfo;
  {$ifdef FPC}
  ch_a: string;
  u: WideString;
  len_ch: int8;
  {$endif}
  ptr_str: PChar;
  len_str: int32;
  avw: BSFloat;
  l_word: int32;
  l_word_pix: BSFloat;
begin
  TextWidth := 0;
  TextHeight := 0;
  MaxLenWordInChars := 0;
  MaxLenWordInPixels := 0;
  CountChars := 0;
  len_str := length(Text);
  if len_str = 0 then
    exit;
  //avh := FAverageHeight;
  avw := FAverageWidth + DistanceBWChars;
  BeginSelectChars;
  try
    ptr_str := @Text[1];
    l_word := 0;
    l_word_pix := 0;
    while len_str > 0 do
    begin
      {$ifdef FPC}
      len_ch := UTF8CodepointSize(ptr_str);
      //len_ch := UTF8CharacterLength(ptr_str);
      SetLength(ch_a, len_ch);
      move(ptr_str^, ch_a[1], len_ch);
      inc(ptr_str, len_ch);
      dec(len_str, len_ch);
      if (ch_a = '') then
        continue;
      u := UTF8Decode(ch_a);
      ch := u[1];
      {$else}
      ch := ptr_str^;
      dec(len_str);
      inc(ptr_str);
      {$endif}
      inc(CountChars);
      if (ch < #$21) or (ch = #$A0) then
      begin
        TextWidth := TextWidth + avw;
        if l_word > MaxLenWordInChars then
          MaxLenWordInChars := l_word;
        if l_word_pix > MaxLenWordInPixels then
          MaxLenWordInPixels := l_word_pix;
        l_word := 0;
        l_word_pix := 0;
      end else
      begin
        KeyInfo := KeyByWideChar[ch];
        if KeyInfo <> nil then
        begin
          inc(l_word);
          l_word_pix := l_word_pix + KeyInfo^.Rect.Width + DistanceBWChars;
          TextWidth := TextWidth + KeyInfo^.Rect.Width + DistanceBWChars;
          if TextHeight < KeyInfo^.Rect.Height then
            TextHeight := KeyInfo^.Rect.Height;
        end else
        begin
          TextWidth := TextWidth + avw;
        end;
      end;
    end;
    if l_word > MaxLenWordInChars then
      MaxLenWordInChars := l_word;
    if l_word_pix > MaxLenWordInPixels then
      MaxLenWordInPixels := l_word_pix;
  finally
    EndSelectChars;
  end;
end;

function TBlackSharkCustomFont.GetTexture: IFontTexture;
begin
  if not FIsVectoral and not Assigned(FTexture) then
    CreateTexture;
  Result := FTexture;
end;

procedure TBlackSharkCustomFont.CalcContours;
var
  i: int32;
  k: PKeyInfo;
  s: TTableSymbols;
begin
  if Selecting then
    exit;
  BeginSelectChars;
  //CalculatingCountours := true;
  try
    for s := low(s) to high(s) do
      if FKeys[s] <> nil then
        for i := 0 to FKeys[s].Count - 1 do
        begin
          k := FKeys[s].Items[i];
          if (k <> nil) and (k^.Glyph <> nil) and (k^.Glyph^.Points.Count > 0) then
          //if (k <> nil) and ((k^.Glyph = nil) or (k^.Glyph^.Points.Count > 0)) then
          begin
            if k^.Glyph <> nil then
              k^.Glyph^.Points.Count := 0;
            k^.Indexes.Count := 0;
            Triangulate(k);
          end;
        end;
    FAverageWidth := round(FAverageWidth);
    FAverageHeight := round(FAverageHeight);
  finally
    { if event about change font was not sended (from texture), then send by change }
    if not EndSelectChars then
      Change;
  end;

end;

procedure TBlackSharkCustomFont.CalcScale;
var
  a: PKeyInfo;
  ga: PGlyph;
begin
  ga := nil;
  if Assigned(RawDataFont) then
  begin
    a := RawDataFont.FKeys[tsUnicodeCS2].Items[int32('A')];
    if Assigned(a) then
      ga := RawDataFont.FGlyphs.Items[a.GlyphIndex];

    if Assigned(ga) then
      FScale := FSizeInPixels / (ga.yMax)
    else
      FScale := FSizeInPixels / RawDataFont.AverageHeight;

    ToSelfScale := FScale/RawDataFont.FScale;
    FAverageWidth := round(FScale * RawDataFont.FAverageWidth);
    FAverageHeight := round(FScale * RawDataFont.FAverageHeight);
  end else
  begin
    FScale := 1.0;
    ToSelfScale := 1.0;
  end;
end;

procedure TBlackSharkCustomFont.Change;
begin
  {if not FIsVectoral and (FTexture <> nil) then
    FTexture.OnChangeEvent.Send(Self)
  else }
    OnChangeEvent.Send(Self);
end;

procedure TBlackSharkCustomFont.CheckBoundary(Glyph: PGlyph);
begin
  if Glyph.xMax > 0 then
  begin
    if FAverageWidth = 0 then
      FAverageWidth := Glyph.xMax
    else
      FAverageWidth := (FAverageWidth + Glyph.xMax) * 0.5;
  end;

  if Glyph.yMax > 0 then
  begin
    if FAverageHeight = 0 then
      FAverageHeight := Glyph.yMax
    else
      FAverageHeight := (FAverageHeight + Glyph.yMax) * 0.5;
  end;
end;

procedure TBlackSharkCustomFont.SetTexture(AValue: IFontTexture);
begin
  if FTexture = AValue then
    exit;
  FTexture := AValue;
  UpdateUV;
  Change;
end;

procedure TBlackSharkCustomFont.SetCodePage(const Value: TCodePage);
begin
  FCodePage := Value;
end;

procedure TBlackSharkCustomFont.SetIsVectoral(AValue: boolean);
begin
  FIsVectoral := AValue;
  //Change;
end;

procedure TBlackSharkCustomFont.SetPixelsPerInch(const Value: BSFloat);
begin
  if FPixelsPerInch = Value then
    exit;
  FPixelsPerInch := Value;
  if FPixelsPerInch < 72 then
    FPixelsPerInch := 72;
  FSizeInPixels := round(FSize*FPixelsPerInch/72);
  CalcScale;
  CalcContours;
end;

function TBlackSharkCustomFont._AddRef: int32;
begin
  {$ifdef FPC}
  Result := InterLockedIncrement(FRefCount);
  {$else}
  Result := AtomicIncrement(FRefCount);
  {$endif}
end;

function TBlackSharkCustomFont._Release: int32;
begin
  {$ifdef FPC}
  Result := InterLockedDecrement(FRefCount);
  {$else}
  Result := AtomicDecrement(FRefCount);
  {$endif}
  if FRefCount <= 0 then
    Destroy;
end;

procedure TBlackSharkCustomFont.BeginSelectChars;
begin
  WasTriangulated := false;
  Selecting := true;
  if (FTexture <> nil) and not FIsVectoral then
    FTexture.BeginUpdate;
end;

function TBlackSharkCustomFont.EndSelectChars: boolean;
begin
  Selecting := false;
  if (FTexture <> nil) and not FIsVectoral then
    Result := FTexture.EndUpdate(FSizeInPixels, true)
  else
    Result := false;
end;

procedure TBlackSharkCustomFont.SetSize(const Value: BSFloat);
begin
  if FSize = Value then
    exit;
  FSize := Value;
  if FSize < 6 then
    FSize := 6;
  FSizeInPixels := round(FSize*FPixelsPerInch/72);
  CalcScale;
  CalcContours;
end;

procedure TBlackSharkCustomFont.SetSizeInPixels(const Value: int16);
begin
  if FSizeInPixels = Value then
    exit;
  FSizeInPixels := Value;
  if FSizeInPixels < 6 then
    FSizeInPixels := 6;
  Size := FSizeInPixels*72/FPixelsPerInch;
end;

procedure TBlackSharkCustomFont.Clear;
var
  i: int32;
  ts: TTableSymbols;
  key: PKeyInfo;
begin
  if Assigned(FTexture) then
  begin
    //ObserverChangeTexture := nil;
    FTexture := nil;
  end;
  {FMinHeight :=  MaxInt;
  FMinWidth  :=  MaxInt;
  FMaxHeight := -MaxInt;
  FMaxWidth  := -MaxInt;  }
  for ts := low(TTableSymbols) to high(TTableSymbols) do
  begin
    if FKeys[ts] = nil then
      continue;
    for i := 0 to FKeys[ts].Count - 1 do
    begin
      key := FKeys[ts].Items[i];
      if key = nil then
        continue;
      {if key^.Glyph <> nil then
        FreeGlyph(key^.Glyph);}
      Dispose(key);
    end;
    FKeys[ts].Free;
    FKeys[ts] := nil;
  end;
  for i := 0 to FGlyphs.Count - 1 do
    if FGlyphs.Items[i] <> nil then
      FreeGlyph(FGlyphs.Items[i]);
  FGlyphs.Count := 0;
end;

destructor TBlackSharkCustomFont.Destroy;
begin
  Clear;
  BSFontManager.OnDestroyFont(Self);
  FGlyphs.Free;
  inherited;
end;

function TBlackSharkCustomFont.Load(const FileName: string): boolean;
var
  new_sn: string;
begin
  Result := true;
  new_sn := ChangeFileExt(ExtractFileName(FileName), '');
  if ExtractFileExt(FileName) = '' then
    FFileName := GetFileExistsPath(FileName + '.ttf', 'Fonts')
  else
    FFileName := GetFileExistsPath(FileName, 'Fonts');
  if not FileExists(FFileName) then
    raise Exception.Create('Font file "'+ FileName +'" not found!');
  //FShortName := ChangeFileExt(ExtractFileName(FFileName), '');
  if new_sn <> FShortName then
  begin
    BSFontManager.OnUpdateFont(new_sn, Self);
    FShortName := new_sn;
  end;
  {FMinHeight :=  MaxInt;
  FMinWidth  :=  MaxInt;
  FMaxHeight := -MaxInt;
  FMaxWidth  := -MaxInt; }
  FAverageWidth := 0;
  FAverageHeight := 0;
end;

procedure TBlackSharkCustomFont.OnChangeTexture(const Value: BData);
begin
  FOnChangeEvent.Send(Self);
end;

{$ifdef FPC}
function TBlackSharkCustomFont.QueryInterface(
  {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID : TGuid; out Obj):
    longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
{$else}
function TBlackSharkCustomFont.QueryInterface(const IID: TGuid; out Obj) : HResult;
{$endif}
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TBlackSharkCustomFont.Save(const FileName: string): boolean;
begin
  if (FTexture = nil) then
    raise Exception.Create('Can not save font - not assign Texture!');
  FFileName := FileName;
  FShortName := ChangeFileExt(ExtractFileName(FFileName), '');
  Result := true;
end;

procedure TBlackSharkCustomFont.Triangulate(Key: PKeyInfo);
begin
  WasTriangulated := true;
end;

procedure TBlackSharkCustomFont.UpdateUV;
var
  i: int32;
  key: PKeyInfo;
  s: TTableSymbols;
begin
  if (FTexture = nil) or (FTexture.Texture.Picture.Width = 0) or (FTexture.Texture.Picture.Height = 0) then
    exit;
  for s := low(s) to high(s) do
    if FKeys[s] <> nil then
      for i := 0 to FKeys[s].Count - 1 do
        begin
        key := FKeys[s].Items[i];
        if key <> nil then
          key^.UV := RectToUV(FTexture.Texture.Picture.Width, FTexture.Texture.Picture.Height, key^.Rect);
        end;
end;

{ TTrueTypeFont }

procedure TTrueTypeFont.Assign(Font: TBlackSharkCustomFont);
begin
  inherited;
  FIsVectoral := true;//Font.FIsVectoral;
end;

procedure TTrueTypeFont.CalcContours;
begin
  //FAverageWidth := 0;
  //FAverageHeight := 0;
  {$ifdef DEBUG_FONT}
    CountTimeTriangulate := 0;
    CountCalcContours := 0;
  {$endif}
  inherited CalcContours;
  {$ifdef DEBUG_FONT}
    BSWriteMsg('TTrueTypeFont.CalcContours', 'TimeTriangulate: ' + IntToStr(CountTimeTriangulate) +  '; Time Calc Contours: ' + IntToStr(CountCalcContours));
  {$endif}
end;

constructor TTrueTypeFont.Create(const AName: string);
begin
  FIsVectoral := true;
  inherited Create(AName);
  FCodePage := TCodePage.cpUnicode;
  RawGlyphs := TListGlyphs.Create;
  FQuality := 0.5;
  FSaveIndexes := true;
  if RawDataFont <> nil then
    ToSelfScale := (FScale/RawDataFont.FScale)
  else
    ToSelfScale := 1.0;
end;

destructor TTrueTypeFont.Destroy;
begin
  if FSaveIndexes and (RawDataFont = nil) then
    SaveInd;
  ClearRaw;
  RawGlyphs.Free;
  inherited Destroy;
end;

function TTrueTypeFont.GetFileInd: string;
var
  f: TFormatSettings;
begin
  f.DecimalSeparator := '.';
  //Result := FFileName + '_' + Format('%f%.2', [FQuality], f) + '.ind';
  Result := FFileName + '_' + Format('%f', [FQuality], f) + '.ind';
end;

function TTrueTypeFont.GetRawGlyph(Index: int32): PGlyph;
begin
  if RawGlyphs.Items[Index] <> nil then
    exit(RawGlyphs.Items[Index]);
  Result := CreateGlyph;
  RawGlyphs.Items[Index] := Result;
  inc(FCountGlyphs);
end;

procedure TTrueTypeFont.SaveInd;
var
  f: TFileStream;
  h: TFileIndexesHeader;
  kh: TKeyHeader;
  i: int32;
  k: PKeyInfo;
  s: string;
begin
  s := GetFileInd;
  if FileExists(s) then
    begin
    f := TFileStream.Create(s, fmOpenRead);
    f.Read({%H-}h, sizeof(h));
    f.Free;
    if h.CountGlyphs >= FTriangulatedKeys then
      exit;
    end;
  f := TFileStream.Create(s, fmCreate);
  try
    h.Version := VER_FILE_IND;
    h.CountGlyphs := 0;
    f.Write(h, sizeof(h));
    for i := 0 to FKeys[TTableSymbols.tsUnicodeCS2].Count - 1 do
      begin
      k := FKeys[TTableSymbols.tsUnicodeCS2].Items[i];
      if (k = nil) or (k.Indexes.Count = 0) then
        continue;
      inc(h.CountGlyphs);
      kh.Code := k.Code;
      kh.CountIndexes := k.Indexes.Count;
      f.Write(kh, sizeof(kh));
      f.Write(k.Indexes.Items[0], SizeOf(BSShort)*k.Indexes.Count);
      end;
    f.Position := 0;
    f.Write(h, sizeof(h));
  finally
    f.Free;
  end;

end;

procedure TTrueTypeFont.LoadInd;
var
  f: TMemoryStream;
  s: string;
  h: TFileIndexesHeader;
  kh: TKeyHeader;
  i: int32;
  k: PKeyInfo;
begin
  s := GetFileInd;
  if not FileExists(s) then
    exit;
  f := TMemoryStream.Create;
  try
    f.LoadFromFile(s);
    f.Position := 0;
    f.Read(h{%H-}, sizeof(h));
    if h.Version <> VER_FILE_IND then
      exit;
    for i := 0 to h.CountGlyphs - 1 do
    begin
      f.Read({%H-}kh, sizeof(kh));
      k := FKeys[TTableSymbols.tsUnicodeCS2].Items[kh.Code];
      if k = nil then
      begin
        f.Position := f.Position + int64(kh.CountIndexes)*int64(SizeOf(BSShort));
        continue;
      end;
      if k.Glyph = nil then
        CalculateContour(k);
      CheckKeyRect(k);
      TBlackSharkTesselator.TListIndexes.SetCapacity(k.Indexes, kh.CountIndexes);
      k.Indexes.Count := kh.CountIndexes;
      f.Read(k^.Indexes.Items[0], kh.CountIndexes*SizeOf(BSShort));
      inc(FTriangulatedKeys);
    end;
  finally
    f.Free;
  end;
end;

procedure TTrueTypeFont.SetQuality(AValue: BSFloat);
begin
  if FQuality = AValue then
    exit;

  FQuality := Clamp(1.0, 0.2, AValue);

  if (RawDataFont <> nil) and (RawDataFont is TTrueTypeFont) then
    TTrueTypeFont(RawDataFont).Quality := FQuality;

  LoadInd;
  ChangingQuality := true;
  try
    CalcContours;
  finally
    ChangingQuality := false;
  end;
end;

procedure TTrueTypeFont.CalculateContour(Key: PKeyInfo);
const
  TRIGGERS: array[1..3] of byte = (1, 2, 4);
var
  i, j, k: int32;
  cp_all: int32;
  c_curve, trig: int8;
  cntr: TContour;
  indexes: array[0..2] of int32;
  p0p1p2: array[0..2] of TVec3f;
  glyph_raw: PGlyph;
  glyph_dst: PGlyph;

  procedure CalcQuadCurve;
  var
    t, t1: BSFloat;
  begin
    // quadratic curve:
    // B(t) = (1-t)^2*P0 + 2t(1-t)*P1 + t^2*P2
    t := FQuality;
    TBlackSharkTesselator.TListPoints.Add(glyph_dst.Points, p0p1p2[0]*FScale);
    CheckGlyphBoundary(glyph_dst, glyph_dst.Points.Items[glyph_dst.Points.Count - 1]);
    while t < 1 do
    begin
      t1 := 1 - t;
      TBlackSharkTesselator.TListPoints.Add(glyph_dst.Points,
        (p0p1p2[0] * t1 * t1 +
        p0p1p2[1] * 2 * t * t1 +
        p0p1p2[2] * t * t)*FScale);
      t := t + FQuality;
      CheckGlyphBoundary(glyph_dst, glyph_dst.Points.Items[glyph_dst.Points.Count - 1]);
    end;
  end;

begin
  if Key^.Glyph = nil then
    Key^.Glyph := AddGlyph(Key^.GlyphIndex);
  glyph_dst := Key^.Glyph;
  glyph_raw := GetRawGlyph(Key^.GlyphIndex);
  glyph_dst^.Contours.Count := 0;
  glyph_dst^.Points.Count := 0;
  glyph_dst^.xMin := glyph_raw^.xMin*FScale;
  glyph_dst^.xMax := glyph_raw^.xMax*FScale;
  glyph_dst^.yMin := glyph_raw^.yMin*FScale;
  glyph_dst^.yMax := glyph_raw^.yMax*FScale;
  // calculate curves and collect all points for all contours
  for j := 0 to glyph_raw^.Contours.Count - 1 do
  begin
    cp_all := glyph_dst^.Points.Count;
    // count collected curve point (max = 3)
    c_curve := 0;
    trig := 0;
    for k := 0 to glyph_raw.Contours.items[j].CountPoints + 1 do
    begin
      i := glyph_raw.Contours.items[j].PointIndexBegin + k mod glyph_raw.Contours.items[j].CountPoints;
      indexes[c_curve] := i;
      inc(c_curve);
      if (glyph_raw.Points.items[i].z <> 0) then
        inc(trig, TRIGGERS[c_curve]);
      if c_curve < 3 then
        continue;
      case trig of
        0: begin // 000 - all off the curve
          p0p1p2[0] := (glyph_raw.Points.items[indexes[0]] + glyph_raw.Points.items[indexes[1]]) * 0.5;
          p0p1p2[1] := glyph_raw.Points.items[indexes[1]];
          p0p1p2[2] := (glyph_raw.Points.items[indexes[1]] + glyph_raw.Points.items[indexes[2]]) * 0.5;
        end;
        1: begin // 100 - 0 point - on the curve, 1,2 points - off curve
          p0p1p2[0] := glyph_raw.Points.items[indexes[0]];
          p0p1p2[1] := glyph_raw.Points.items[indexes[1]];
          p0p1p2[2] := (p0p1p2[1] + glyph_raw.Points.items[indexes[2]]) * 0.5;
        end;
        3: begin // 110 - 0, 1 points - on the curve - direct line, not used for calculate curve
          TBlackSharkTesselator.TListPoints.Add(glyph_dst.Points, glyph_raw.Points.items[indexes[0]]*FScale);
          trig := trig shr 1;
          c_curve := 2;
          indexes[0] := indexes[1];
          indexes[1] := indexes[2];
          continue;
        end;
        4: begin // 001 - 0,1 points - off curve, 2 - on
          p0p1p2[0] := (glyph_raw.Points.items[indexes[0]] + glyph_raw.Points.items[indexes[1]]) * 0.5;
          p0p1p2[1] := glyph_raw.Points.items[indexes[1]];
          p0p1p2[2] := glyph_raw.Points.items[indexes[2]];
        end;
        5: begin // 101 - middle point - off curve
          p0p1p2[0] := glyph_raw.Points.items[indexes[0]];
          p0p1p2[1] := glyph_raw.Points.items[indexes[1]];
          p0p1p2[2] := glyph_raw.Points.items[indexes[2]];
        end;
        7: begin // 111 0, 1, 2 - on the curve - two direct line, not used for calculate curve
          TBlackSharkTesselator.TListPoints.Add(glyph_dst.Points, glyph_raw.Points.items[indexes[0]]*FScale);
          TBlackSharkTesselator.TListPoints.Add(glyph_dst.Points, glyph_raw.Points.items[indexes[1]]*FScale);
          trig := trig shr 2;
          c_curve := 1;
          indexes[0] := indexes[2];
          continue;
        end else
        begin
          //raise Exception.Create('Uncknown trigger!!!');
          trig := trig shr 1;
          c_curve := 2;
          indexes[0] := indexes[1];
          indexes[1] := indexes[2];
          continue;
        end;
      end;

      trig := trig shr 1;
      c_curve := 2;
      indexes[0] := indexes[1];
      indexes[1] := indexes[2];
      CalcQuadCurve;
    end;

    cntr := TBlackSharkTesselator.Contour(cp_all, glyph_dst^.Points.Count - cp_all);
    cntr.Group := glyph_raw.Contours.items[j].Group;
    cntr.AsClockArr := glyph_raw.Contours.items[j].AsClockArr;
    TBlackSharkTesselator.TListContours.Add(glyph_dst.Contours, cntr);
  end;
end;

procedure TTrueTypeFont.CheckKeyRect(Key: PKeyInfo);
begin
  if (Key.Glyph^.xMax = 0) or (Key.Glyph^.yMax = 0) then
  begin
    // blank or empty glyph
    Key.Glyph^.xMin := 0;
    Key.Glyph^.yMin := 0;
    if RawDataFont <> nil then
    begin
      Key.Glyph^.xMax := round(RawDataFont.FAverageWidth*0.5*FScale);
      Key.Glyph^.yMax := round(RawDataFont.FAverageHeight*0.5*FScale);
    end else
    begin
      Key.Glyph^.xMax := round(FAverageWidth*0.5*FScale);
      Key.Glyph^.yMax := round(FAverageHeight*0.5*FScale);
    end;
    Key^.Rect.Width := (Key.Glyph^.xMax);
    Key^.Rect.Height := (Key.Glyph^.yMax);
  end;
  Key^.Rect.Width := (Key.Glyph^.xMax - Key.Glyph^.xMin);
  Key^.Rect.Height := (Key.Glyph^.yMax - Key.Glyph^.yMin);
  Key^.Rect.Left := 0;
  Key^.Rect.Top := 0;
end;

procedure TTrueTypeFont.ClearRaw;
var
  i: int32;
begin
  for i := 0 to RawGlyphs.Count - 1 do
    if Assigned(RawGlyphs.Items[i]) then
      FreeGlyph(RawGlyphs.Items[i]);
  RawGlyphs.Count := 0;
end;

function TTrueTypeFont.Load(const FileName: string): boolean;
begin
  inherited;
  Result := FontParser.LoadTTFont(FFileName, Self);
  if Result then
  begin
    CalcScale;
    LoadInd;
  end;
end;

procedure TTrueTypeFont.Triangulate(Key: PKeyInfo);
var
  MAX_INT: BSFloat;
  raw_k: PKeyInfo;
  i: int32;
  {$ifdef DEBUG_FONT}
  t: uint32;
  {$endif}
begin
  WasTriangulated := true;
  if Key^.Glyph = nil then
    Key^.Glyph := AddGlyph(Key^.GlyphIndex);

  if ChangingQuality and (Key^.Indexes.Count > 0) then
  begin
    Key^.Indexes.Count := 0;
    dec(FTriangulatedKeys);
  end;

  // calculate contours only for raw font is sourses of data
  if (RawDataFont = nil) and (Key^.Glyph^.Points.Count = 0) then
  begin
    {$ifdef DEBUG_FONT}
    t := TThreadTimer.CurrentTime.Low;
    {$endif}
    CalculateContour(Key);
    {$ifdef DEBUG_FONT}
    inc(CountCalcContours, TThreadTimer.CurrentTime.Low - t);
    {$endif}
  end;

  // triangulate
  if (Key^.Indexes.Count = 0) and (Key^.Glyph^.Points.Count > 3) then
  begin
    {$ifdef DEBUG_FONT}
    t := TThreadTimer.CurrentTime.Low;
    {$endif}
    Tesselator.Triangulate(Key^.Glyph^.Points, Key^.Glyph^.Contours, Key^.Indexes);
    if (Key^.Indexes.Count > 3) then
      inc(FTriangulatedKeys);
    {$ifdef DEBUG_FONT}
    inc(CountTimeTriangulate, TThreadTimer.CurrentTime.Low - t);
    {$endif}
  end;

  if RawDataFont <> nil then
    raw_k := RawDataFont.Key[Key.Code]
  else
    raw_k := nil;

  if (raw_k <> nil) and (raw_k.Glyph <> nil) then
  begin
    if (Key^.Glyph^.Points.Count = 0) then
    begin
      TBlackSharkTesselator.TListIndexes.CheckCapacity(Key^.Indexes, raw_k.Indexes.Count);
      TBlackSharkTesselator.TListPoints.CheckCapacity(Key^.Glyph^.Points, raw_k.Glyph.Points.Count);
      Key.Indexes.Count := raw_k.Indexes.Count;
      Key^.Glyph^.Points.Count := raw_k.Glyph.Points.Count;
      for i := 0 to raw_k.Glyph.Points.Count - 1 do
        Key^.Glyph.Points.Items[i] := raw_k.Glyph.Points.Items[i] * ToSelfScale;
      move(raw_k.Indexes.Items[0], Key^.Indexes.Items[0], raw_k.Indexes.Count*SizeOf(BSShort));
      Key^.Glyph^.xMax := round(raw_k^.Glyph^.xMax * ToSelfScale);
      Key^.Glyph^.xMin := round(raw_k^.Glyph^.xMin * ToSelfScale);
      Key^.Glyph^.yMax := round(raw_k^.Glyph^.yMax * ToSelfScale);
      Key^.Glyph^.yMin := round(raw_k^.Glyph^.yMin * ToSelfScale);
    end else
    begin
      Key^.Glyph^.xMax := raw_k^.Glyph^.xMax;
      Key^.Glyph^.xMin := raw_k^.Glyph^.xMin;
      Key^.Glyph^.yMax := raw_k^.Glyph^.yMax;
      Key^.Glyph^.yMin := raw_k^.Glyph^.yMin;
    end;
  end else
  begin
    MAX_INT := MaxInt; // copy to float, otherwise no correct compare if take integer value
    if Key^.Glyph^.xMax = -MAX_INT then
      Key^.Glyph^.xMax := round(FAverageWidth * 0.5 * FScale);
    if Key^.Glyph^.xMin = MAX_INT then
      Key^.Glyph^.xMin := 0;
    if Key^.Glyph^.yMax = -MAX_INT then
      Key^.Glyph^.yMax := round(FAverageHeight * 0.5 * FScale);
    if Key^.Glyph^.yMin = MAX_INT then
      Key^.Glyph^.yMin := 0;
  end;

  CheckKeyRect(Key);
end;

{ TBlackSharkRasterFont }

function TBlackSharkRasterFont.Save(const FileName: string): boolean;
var
  s: TFileStream;
  //fn: WideString;
  hdr: TMainInfoFontHeader;
  bh: TBMPInfoHeader;
  fh: TBMPFileHdr;
  i, count_chars: int32;
  k: PKeyInfo;
  BaseKeyInfo: TBaseKeyInfo;
begin
  inherited;
  if (FKeys[tsUnicodeCS2] = nil) then
    exit(false);
  s := TFileStream.Create(FFileName, fmCreate);
  count_chars := 0;
  try
    FillChar({%H-}fh, SizeOf(fh), 0);
    FillChar({%H-}bh, SizeOf(bh), 0);
    fh.bfSize := FTexture.Texture.Picture.Width * FTexture.Texture.Picture.Height * 4 + SizeOf(fh) + SizeOf(bh);
    fh.bfOffBits := SizeOf(fh) + SizeOf(bh);
    fh.bfType := $4d42;
    bh.biSize := SizeOf(bh);
    bh.biWidth := FTexture.Texture.Picture.Width;
    bh.biHeight := FTexture.Texture.Picture.Height; // request top down
    bh.biPlanes := 1;
    bh.biBitCount := 32;
    bh.biClrImportant := 0;
    bh.biSizeImage := FTexture.Texture.Picture.Width * FTexture.Texture.Picture.Height * 4;
    //bh.biXPelsPerMeter := ;
    hdr.MainHeader := FONT_MAIN_HEADER;
    hdr.SizeTexture := fh.bfSize;
    s.Write(hdr, SizeOf(TMainInfoFontHeader));
    s.Write(fh, SizeOf(fh));
    s.Write(bh, SizeOf(bh));

    for i := FTexture.Texture.Picture.Height - 1 downto 0 do
    begin
      s.Write((pByte(FTexture.Texture.Picture.Canvas.Raw.Memory) + i * FTexture.Texture.Picture.Width * 4)^,
        FTexture.Texture.Picture.Width * 4);
    end;

    for i := 0 to FKeys[tsUnicodeCS2].Count - 1 do
    begin
      k := FKeys[tsUnicodeCS2].Items[i];
      if (k = nil) then
        continue;
      inc(count_chars);
      BaseKeyInfo.CodeUTF16 := i;
      BaseKeyInfo.Rect := k^.Rect;
      s.Write(BaseKeyInfo, SizeOf(TBaseKeyInfo));
    end;

    s.Position := 0;
    hdr.CountChars := count_chars;
    s.Write(hdr, SizeOf(TMainInfoFontHeader));
  finally
    s.Free;
  end;
  Result := true;
end;

{procedure TBlackSharkRasterFont.SetSize(const Value: int16);
begin
  inherited SetSize;

end;
}

procedure TBlackSharkRasterFont.Triangulate(Key: PKeyInfo);
var
  size: TVec2f;
  glyph, raw_glyph: PGlyph;
begin
  if Key^.Glyph = nil then
    Key^.Glyph := AddGlyph(Key^.GlyphIndex);
  glyph := Key^.Glyph;
  if glyph.Points.Count > 0 then
    exit;

  if RawDataFont <> nil then
    begin
    { take from raw font }
    raw_glyph := RawDataFont.FGlyphs.Items[Key.GlyphIndex];

    size.x := (raw_glyph^.xMax - raw_glyph^.xMin)*FScale;
    size.y := (raw_glyph^.yMax - raw_glyph^.yMin)*FScale;

    glyph^.xMin := (raw_glyph^.xMin)*FScale;
    glyph^.xMax := (raw_glyph^.xMax)*FScale;
    glyph^.yMin := (raw_glyph^.yMin)*FScale;
    glyph^.yMax := (raw_glyph^.yMax)*FScale;

    end else
    begin
    size.x := (Key^.Glyph^.xMax - Key^.Glyph^.xMin)*FScale;
    size.y := (Key^.Glyph^.yMax - Key^.Glyph^.yMin)*FScale;
    end;

  TBlackSharkTesselator.TListPoints.Add(glyph.Points,
    Vec3(0.0, 0, 0));
  TBlackSharkTesselator.TListPoints.Add(glyph.Points,
    Vec3(0, size.y, 0));
  TBlackSharkTesselator.TListPoints.Add(glyph.Points,
    Vec3(size.x, size.y, 0));
  TBlackSharkTesselator.TListPoints.Add(glyph.Points,
    Vec3(size.x, 0, 0));

  if Key^.Indexes.Count = 0 then
    begin
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 0);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 1);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 2);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 2);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 0);
    TBlackSharkTesselator.TListIndexes.Add(Key^.Indexes, 3);
    end;

  CheckBoundary(Glyph);
end;

function TBlackSharkRasterFont.AddSymbol(CodeUTF16: uint16; const Rect: TRectBSi): PKeyInfo;
var
  r: TTextureRect;
begin
  Result := AddPair(tsUnicodeCS2, CodeUTF16, CodeUTF16);
  Result^.Glyph := AddGlyph(CodeUTF16);
  Result^.Glyph^.yMin := 0;
  Result^.Glyph^.xMin := 0;
  Result^.Glyph^.yMax := Rect.Height;
  Result^.Glyph^.xMax := Rect.Width;
  Result^.Rect := Rect;
  if FSizeInPixels < Rect.Height then
  begin
    FSizeInPixels := Rect.Height;
    FSize := round(FSizeInPixels/(FPixelsPerInch/72));
  end;
  //KeyInfo^.IndexToGlyph := IndexToGlyph;
  if (FTexture <> nil) then
  begin
    if not FTexture.GetRect(CodeUTF16, tsUnicodeCS2, r) then
    begin
      r.Rect := Rect;
      r.UV := RectToUV(FTexture.Texture.Picture.Width, FTexture.Texture.Picture.Height, Rect);
      FTexture.AddRect(CodeUTF16, r, tsUnicodeCS2);
    end;
    Result^.UV := r.UV;
  end;
  //CheckBoundary(Result^.Glyph);
end;

function TBlackSharkRasterFont.LoadBSFont0(Stream: TStream): boolean;
var
  buf: TWidenBuffer;
  i: int32;
  hdr: TMainInfoFontHeader;
  KeyInfo: TBaseKeyInfo;
begin
  Stream.Position := 0;
  Stream.Read(hdr{%H-}, SizeOf(TMainInfoFontHeader));
  if not CompareMem(@hdr.MainHeader, @FONT_MAIN_HEADER, SizeOf(TFontMainHeader)) then
    exit(false);
  Result := true;
  buf := TWidenBuffer.Create(hdr.SizeTexture);
  buf.Size := hdr.SizeTexture;
  Stream.Read(pByte(buf.Memory)^, hdr.SizeTexture);
  if FTexture = nil then
    FTexture := BSFontManager.GetTexture(FShortName, FSizeInPixels, hdr.CountChars);
  //pt := BSFontManager.TextManager.LoadTexture(buf, FShortName, TBlackSharkTextureMap, false, false, true);
  //FTexture := TFontTexture(pt.Texture);
  //FTexture.TrilinearFilter := true;
  buf.Free;
  for i := 0 to hdr.CountChars - 1 do
    begin
    Stream.Read(KeyInfo{%H-}, SizeOf(TBaseKeyInfo));
    AddSymbol(KeyInfo.CodeUTF16, KeyInfo.Rect);
    end;
  //UpdateUV;
end;

procedure TBlackSharkRasterFont.Assign(Font: TBlackSharkCustomFont);
begin
  inherited;
  FTexture := Font.FTexture;
end;

function TBlackSharkRasterFont.Load(const FileName: string): boolean;
var
  s: TFileStream;
  fn: string;
  MainHeader: TFontMainHeader;
begin
  inherited;
  FSize := 0;
  FSizeInPixels := 0;
  fn := GetFileExistsPath(FileName, 'Fonts');
  if (fn = '') then
    exit(false);
  s := TFileStream.Create(fn, fmOpenRead);
  try
    s.Read(MainHeader{%H-}, SizeOf(TFontMainHeader));
    case MainHeader.Version of
    0: Result := LoadBSFont0(s) else
       raise Exception.Create('Unknown version font file: ' + FileName);
    end;
  finally
    s.Free;
  end;
end;

{ TFontTexture }

procedure TFontTexture.AddRect(Code: uint32; const Rect: TTextureRect; Table: TTableSymbols);
var
  r: PFontRect;
begin
  if FRects[Table] = nil then
    FRects[Table] := TListVec<PFontRect>.Create;
  if FRects[Table].Items[Code] <> nil then
    exit;
  new(r);
  r.Code := Code;
  r.TextureRect := Rect;
  FRects[Table].Items[Code] := r;
end;

procedure TFontTexture.BeginUpdate;
begin
  inc(CountUpdate);
  FTexture.BeginUpdate;
end;

constructor TFontTexture.Create(AWidth, AHeight: int32; TrilinearFilter: boolean; const Name: string);
var
  Picture: TBlackSharkBitMap;
begin
  inherited Create;
  FOnChangeEvent := CreateEmptyEvent;
  FTexture := BSTextureManager.CreateTexture(Name, TBlackSharkTextureMap, 0, 0);
  FTexture.BeginUpdate;
  try
    FTexture.TrilinearFilter := TrilinearFilter;
    //FTexture.MipMap := true;
    Picture := TBlackSharkBitMap.Create;
    { set texture as GL_ALPHA }
    Picture.PixelFormat := TBSPixelFormat.pf8bit;
    Picture.SetSize(AWidth, AHeight);
    FTexture.Picture := Picture;
  finally
    FTexture.EndUpdate(true);
  end;
end;

destructor TFontTexture.Destroy;
var
  ts: TTableSymbols;
  i: int32;
  fr: PFontRect;
begin
  BSFontManager.FreeTexture(Self);
  for ts := low(TTableSymbols) to high(TTableSymbols) do
  begin
    if FRects[ts] = nil then
      continue;
    for i := 0 to FRects[ts].Count - 1 do
    begin
      fr := FRects[ts].Items[i];
      if fr = nil then
        continue;
      Dispose(fr);
    end;
    FRects[ts].Free;
  end;
  FTexture.ClearAreas;
  FTexture := nil;
  FOnChangeEvent := nil;
  inherited;
end;

function TFontTexture.EndUpdate(FontSizeInPixels: int32; Reload: boolean): boolean;
begin
  dec(CountUpdate);
  if CountUpdate < 0 then
    CountUpdate := 0;
  Result := false;
  FTexture.EndUpdate(Reload);
  if CountUpdate = 0 then
  begin
    if LastFontSize <> FontSizeInPixels then
    begin
      LastFontSize := FontSizeInPixels;
      Result := true;
      { event about change }
      FOnChangeEvent.Send(Self);
    end;
  end;
end;

function TFontTexture.GetOnChangeEvent: IBEmptyEvent;
begin
  Result := FOnChangeEvent;
end;

function TFontTexture.GetRect(Code: int32; Table: TTableSymbols; out Rect: TTextureRect): boolean;
var
  p: PFontRect;
begin
  if (FRects[Table] = nil) then
    exit(false);
  p := FRects[Table].Items[Code];
  if p = nil then
    exit(false);
  Rect := p.TextureRect;
  Result := true;
end;

function TFontTexture.GetTexture: IBlackSharkTexture;
begin
  Result := FTexture;
end;

{$ifdef FPC}
function TFontTexture.QueryInterface(
  {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID : TGuid; out Obj):
    longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
{$else}
function TFontTexture.QueryInterface(const IID: TGuid; out Obj) : HResult;
{$endif}
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TFontTexture._AddRef: int32;
begin
  {$ifdef FPC}
  Result := InterLockedIncrement(FCountRef);
  {$else}
  Result := AtomicIncrement(FCountRef);
  {$endif}
end;

function TFontTexture._Release: int32;
begin
  {$ifdef FPC}
  Result := InterLockedDecrement(FCountRef);
  {$else}
  Result := AtomicDecrement(FCountRef);
  {$endif}
  if FCountRef <= 0 then
    Destroy;
end;

initialization
  FontParser := TFontParser.Create;

finalization
  FontParser.Free;

end.

