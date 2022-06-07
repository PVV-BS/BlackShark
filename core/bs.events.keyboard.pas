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
unit bs.events.keyboard;

{$I BlackSharkCfg.inc}

interface

const

  { virtual keys }

  VK_BS_LButton          = $01;  {   1 }
  VK_BS_RButton          = $02;  {   2 }
  VK_BS_Cancel           = $03;  {   3 }
  VK_BS_MButton          = $04;  {   4 }
  VK_BS_XButton1         = $05;  {   5 }
  VK_BS_XButton2         = $06;  {   6 }
  VK_BS_Back             = $08;  {   8 }
  VK_BS_Tab              = $09;  {   9 }
  VK_BS_LineFeed         = $0A;  {  10 }
  VK_BS_Clear            = $0C;  {  12 }
  VK_BS_Return           = $0D;  {  13 }
  VK_BS_Shift            = $10;  {  16 }
  VK_BS_Control          = $11;  {  17 }
  VK_BS_Menu             = $12;  {  18 }
  VK_BS_Pause            = $13;  {  19 }
  VK_BS_Capital          = $14;  {  20 }
  VK_BS_Kana             = $15;  {  21 }
  VK_BS_Hangul           = $15;  {  21 }
  VK_BS_Junja            = $17;  {  23 }
  VK_BS_Final            = $18;  {  24 }
  VK_BS_Hanja            = $19;  {  25 }
  VK_BS_Kanji            = $19;  {  25 }
  VK_BS_Convert          = $1C;  {  28 }
  VK_BS_NonConvert       = $1D;  {  29 }
  VK_BS_Accept           = $1E;  {  30 }
  VK_BS_ModeChange       = $1F;  {  31 }
  VK_BS_Escape           = $1B;  {  27 }
  VK_BS_Space            = $20;  {  32 }
  VK_BS_Prior            = $21;  {  33 }
  VK_BS_Next             = $22;  {  34 }
  VK_BS_End              = $23;  {  35 }
  VK_BS_Home             = $24;  {  36 }
  VK_BS_Left             = $25;  {  37 }
  VK_BS_Up               = $26;  {  38 }
  VK_BS_Right            = $27;  {  39 }
  VK_BS_Down             = $28;  {  40 }
  VK_BS_Select           = $29;  {  41 }
  VK_BS_Print            = $2A;  {  42 }
  VK_BS_Execute          = $2B;  {  43 }
  VK_BS_Snapshot         = $2C;  {  44 }
  VK_BS_Insert           = $2D;  {  45 }
  VK_BS_Delete           = $2E;  {  46 }
  VK_BS_Help             = $2F;  {  47 }

  VK_BS_0                = $30;  {  48 }
  VK_BS_1                = $31;  {  49 }
  VK_BS_2                = $32;  {  50 }
  VK_BS_3                = $33;  {  51 }
  VK_BS_4                = $34;  {  52 }
  VK_BS_5                = $35;  {  53 }
  VK_BS_6                = $36;  {  54 }
  VK_BS_7                = $37;  {  55 }
  VK_BS_8                = $38;  {  56 }
  VK_BS_9                = $39;  {  57 }

  VK_BS_A                = $41;  {  65 }
  VK_BS_B                = $42;  {  66 }
  VK_BS_C                = $43;  {  67 }
  VK_BS_D                = $44;  {  68 }
  VK_BS_E                = $45;  {  69 }
  VK_BS_F                = $46;  {  70 }
  VK_BS_G                = $47;  {  71 }
  VK_BS_H                = $48;  {  72 }
  VK_BS_I                = $49;  {  73 }
  VK_BS_J                = $4A;  {  74 }
  VK_BS_K                = $4B;  {  75 }
  VK_BS_L                = $4C;  {  76 }
  VK_BS_M                = $4D;  {  77 }
  VK_BS_N                = $4E;  {  78 }
  VK_BS_O                = $4F;  {  79 }
  VK_BS_P                = $50;  {  80 }
  VK_BS_Q                = $51;  {  81 }
  VK_BS_R                = $52;  {  82 }
  VK_BS_S                = $53;  {  83 }
  VK_BS_T                = $54;  {  84 }
  VK_BS_U                = $55;  {  85 }
  VK_BS_V                = $56;  {  86 }
  VK_BS_W                = $57;  {  87 }
  VK_BS_X                = $58;  {  88 }
  VK_BS_Y                = $59;  {  89 }
  VK_BS_Z                = $5A;  {  90 }
  VK_BS_LWin             = $5B;  {  91 }
  VK_BS_RWin             = $5C;  {  92 }
  VK_BS_Apps             = $5D;  {  93 }
  VK_BS_Sleep            = $5F;  {  95 }
  VK_BS_Numpad0          = $60;  {  96 }
  VK_BS_Numpad1          = $61;  {  97 }
  VK_BS_Numpad2          = $62;  {  98 }
  VK_BS_Numpad3          = $63;  {  99 }
  VK_BS_Numpad4          = $64;  { 100 }
  VK_BS_Numpad5          = $65;  { 101 }
  VK_BS_Numpad6          = $66;  { 102 }
  VK_BS_Numpad7          = $67;  { 103 }
  VK_BS_Numpad8          = $68;  { 104 }
  VK_BS_Numpad9          = $69;  { 105 }
  VK_BS_Multiply         = $6A;  { 106 }
  VK_BS_Add              = $6B;  { 107 }
  VK_BS_Separator        = $6C;  { 108 }
  VK_BS_Subtract         = $6D;  { 109 }
  VK_BS_Decimal          = $6E;  { 110 }
  VK_BS_Divide           = $6F;  { 111 }
  VK_BS_F1               = $70;  { 112 }
  VK_BS_F2               = $71;  { 113 }
  VK_BS_F3               = $72;  { 114 }
  VK_BS_F4               = $73;  { 115 }
  VK_BS_F5               = $74;  { 116 }
  VK_BS_F6               = $75;  { 117 }
  VK_BS_F7               = $76;  { 118 }
  VK_BS_F8               = $77;  { 119 }
  VK_BS_F9               = $78;  { 120 }
  VK_BS_F10              = $79;  { 121 }
  VK_BS_F11              = $7A;  { 122 }
  VK_BS_F12              = $7B;  { 123 }
  VK_BS_F13              = $7C;  { 124 }
  VK_BS_F14              = $7D;  { 125 }
  VK_BS_F15              = $7E;  { 126 }
  VK_BS_F16              = $7F;  { 127 }
  VK_BS_F17              = $80;  { 128 }
  VK_BS_F18              = $81;  { 129 }
  VK_BS_F19              = $82;  { 130 }
  VK_BS_F20              = $83;  { 131 }
  VK_BS_F21              = $84;  { 132 }
  VK_BS_F22              = $85;  { 133 }
  VK_BS_F23              = $86;  { 134 }
  VK_BS_F24              = $87;  { 135 }

  VK_BS_Camera           = $88;  { 136 }
  VK_BS_HardwareBack     = $89;  { 137 }

  VK_BS_NumLock          = $90;  { 144 }
  VK_BS_Scroll           = $91;  { 145 }
  VK_BS_LShift           = $A0;  { 160 }
  VK_BS_RShift           = $A1;  { 161 }
  VK_BS_LControl         = $A2;  { 162 }
  VK_BS_RControl         = $A3;  { 163 }
  VK_BS_LMenu            = $A4;  { 164 }
  VK_BS_RMenu            = $A5;  { 165 }

  VK_BS_BrowserBack      = $A6;  { 166 }
  VK_BS_BrowserForward   = $A7;  { 167 }
  VK_BS_BrowserRefresh   = $A8;  { 168 }
  VK_BS_BrowserStop      = $A9;  { 169 }
  VK_BS_BrowserSearch    = $AA;  { 170 }
  VK_BS_BrowserFavorites = $AB;  { 171 }
  VK_BS_BrowserHome      = $AC;  { 172 }
  VK_BS_VolumeMute       = $AD;  { 173 }
  VK_BS_VolumeDown       = $AE;  { 174 }
  VK_BS_VolumeUp         = $AF;  { 175 }
  VK_BS_MediaNextTrack   = $B0;  { 176 }
  VK_BS_MediaPrevTrack   = $B1;  { 177 }
  VK_BS_MediaStop        = $B2;  { 178 }
  VK_BS_MediaPlayPause   = $B3;  { 179 }
  VK_BS_LaunchMail       = $B4;  { 180 }
  VK_BS_LaunchMediaSelect= $B5;  { 181 }
  VK_BS_LaunchApp1       = $B6;  { 182 }
  VK_BS_LaunchApp2       = $B7;  { 183 }

  VK_BS_Semicolon        = $BA;  { 186 }
  VK_BS_Equal            = $BB;  { 187 }
  VK_BS_Comma            = $BC;  { 188 }
  VK_BS_Minus            = $BD;  { 189 }
  VK_BS_Period           = $BE;  { 190 }
  VK_BS_Slash            = $BF;  { 191 }
  VK_BS_Tilde            = $C0;  { 192 }
  VK_BS_LeftBracket      = $DB;  { 219 }
  VK_BS_Backslash        = $DC;  { 220 }
  VK_BS_RightBracket     = $DD;  { 221 }
  VK_BS_Quote            = $DE;  { 222 }
  VK_BS_Para             = $DF;  { 223 }

  VK_BS_Oem102           = $E2;  { 226 }
  VK_BS_IcoHelp          = $E3;  { 227 }
  VK_BS_Ico00            = $E4;  { 228 }
  VK_BS_ProcessKey       = $E5;  { 229 }
  VK_BS_IcoClear         = $E6;  { 230 }
  VK_BS_Packet           = $E7;  { 231 }
  VK_BS_Attn             = $F6;  { 246 }
  VK_BS_Crsel            = $F7;  { 247 }
  VK_BS_Exsel            = $F8;  { 248 }
  VK_BS_ErEof            = $F9;  { 249 }
  VK_BS_Play             = $FA;  { 250 }
  VK_BS_Zoom             = $FB;  { 251 }
  VK_BS_Noname           = $FC;  { 252 }
  VK_BS_PA1              = $FD;  { 253 }
  VK_BS_OemClear         = $FE;  { 254 }
  VK_BS_None             = $FF;  { 255 }

implementation

end.
