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
unit bs.linux;

{$I BlackSharkCfg.inc}

interface

{$IFDEF FPC}
  {$PACKRECORDS C}
{$else}
  {.$ALIGN 16}
  {.$A8}
{$ENDIF}


type

{$region C_Types}
  cint8                  = shortint;           pcint8                 = ^cint8;
  cuint8                 = byte;               pcuint8                = ^cuint8;
  cchar                  = cint8;              pcchar                 = ^cchar;
  cschar                 = cint8;              pcschar                = ^cschar;
  cuchar                 = cuint8;             pcuchar                = ^cuchar;

  cint16                 = smallint;           pcint16                = ^cint16;
  cuint16                = word;               pcuint16               = ^cuint16;
  cshort                 = cint16;             pcshort                = ^cshort;
  csshort                = cint16;             pcsshort               = ^csshort;
  cushort                = cuint16;            pcushort               = ^cushort;

  cint32                 = integer;            pcint32                = ^cint32;
  cuint32                = uint32;             pcuint32               = ^cuint32;
  cint                   = cint32;             pcint                  = ^cint;              { minimum range is: 32-bit    }
                                               ppcint                 = ^pcint;
  csint                  = cint32;             pcsint                 = ^csint;             { minimum range is: 32-bit    }
  cuint                  = cuint32;            pcuint                 = ^cuint;             { minimum range is: 32-bit    }
  csigned                = cint;               pcsigned               = ^csigned;
  cunsigned              = cuint;              pcunsigned             = ^cunsigned;

  cint64                 = int64;              pcint64                = ^cint64;
  cuint64                = uint64;             pcuint64               = ^cuint64;
  clonglong              = cint64;             pclonglong             = ^clonglong;
  cslonglong             = cint64;             pcslonglong            = ^cslonglong;
  culonglong             = cuint64;            pculonglong            = ^culonglong;

  cbool                  = longbool;           pcbool                 = ^cbool;

{$ifdef CPU32}
  clong                  = integer;            pclong                 = ^clong;
  cslong                 = integer;            pcslong                = ^cslong;
  culong                 = cardinal;           pculong                = ^culong;
{$else}
  clong                  = int64;              pclong                 = ^clong;
  cslong                 = int64;              pcslong                = ^cslong;
  culong                 = uint64;             pculong                = ^culong;
{$endif}

{$ifndef FPUNONE}
  cfloat                 = single;             pcfloat                = ^cfloat;
  cdouble                = double;             pcdouble               = ^cdouble;
  clongdouble            = extended;           pclongdouble           = ^clongdouble;
{$endif}
{$endregion C_Types}

{$region x}

  PXID = ^TXID;
  TXID = culong;

  PXIC = ^TXIC;
  TXIC = record
  end;

  PXIM = ^TXIM;
  TXIM = record
  end;

  PMask = ^TMask;
  TMask = culong;

  PPAtom = ^PAtom;
  PAtom = ^TAtom;
  TAtom = culong;

  PVisualID = ^TVisualID;
  TVisualID = culong;

  PPWindow = ^PWindow;
  PWindow = ^TWindow;
  TWindow = TXID;

  PPixmap = ^TPixmap;
  TPixmap = TXID;

  PCursor = ^TCursor;
  TCursor = TXID;

  PColormap = ^TColormap;
  TColormap = TXID;

  PGContext = ^TGContext;
  TGContext = TXID;

  PKeySym = ^TKeySym;
  TKeySym = TXID;

  PKeyCode = ^TKeyCode;
  TKeyCode = cuchar;

  PDrawable = ^TDrawable;
  TDrawable = TXID;

  PXClassHint = ^TXClassHint;
  TXClassHint = record
    res_name: PAnsichar;
    res_class: PAnsiChar;
  end;

const
   None = 0;
   ParentRelative = 1;
   CopyFromParent = 0;
   PointerWindow = 0;
   InputFocus = 1;
   PointerRoot = 1;
   AnyPropertyType = 0;
   AnyKey = 0;
   AnyButton = 0;
   AllTemporary = 0;
   CurrentTime = 0;
   NoSymbol = 0;
   NoEventMask = 0;
   KeyPressMask = 1 shl 0;
   KeyReleaseMask = 1 shl 1;
   ButtonPressMask = 1 shl 2;
   ButtonReleaseMask = 1 shl 3;
   EnterWindowMask = 1 shl 4;
   LeaveWindowMask = 1 shl 5;
   PointerMotionMask = 1 shl 6;
   PointerMotionHintMask = 1 shl 7;
   Button1MotionMask = 1 shl 8;
   Button2MotionMask = 1 shl 9;
   Button3MotionMask = 1 shl 10;
   Button4MotionMask = 1 shl 11;
   Button5MotionMask = 1 shl 12;
   ButtonMotionMask = 1 shl 13;
   KeymapStateMask = 1 shl 14;
   ExposureMask = 1 shl 15;
   VisibilityChangeMask = 1 shl 16;
   StructureNotifyMask = 1 shl 17;
   ResizeRedirectMask = 1 shl 18;
   SubstructureNotifyMask = 1 shl 19;
   SubstructureRedirectMask = 1 shl 20;
   FocusChangeMask = 1 shl 21;
   PropertyChangeMask = 1 shl 22;
   ColormapChangeMask = 1 shl 23;
   OwnerGrabButtonMask = 1 shl 24;
   KeyPress = 2;
   KeyRelease = 3;
   ButtonPress = 4;
   ButtonRelease = 5;
   MotionNotify = 6;
   EnterNotify = 7;
   LeaveNotify = 8;
   FocusIn = 9;
   FocusOut = 10;
   KeymapNotify = 11;
   Expose = 12;
   GraphicsExpose = 13;
   NoExpose = 14;
   VisibilityNotify = 15;
   CreateNotify = 16;
   DestroyNotify = 17;
   UnmapNotify = 18;
   MapNotify = 19;
   MapRequest = 20;
   ReparentNotify = 21;
   ConfigureNotify = 22;
   ConfigureRequest = 23;
   GravityNotify = 24;
   ResizeRequest = 25;
   CirculateNotify = 26;
   CirculateRequest = 27;
   PropertyNotify = 28;
   SelectionClear = 29;
   SelectionRequest = 30;
   SelectionNotify = 31;
   ColormapNotify = 32;
   ClientMessage = 33;
   MappingNotify = 34;
   GenericEvent = 35;
   LASTEvent = 36;
   ShiftMask = 1 shl 0;
   LockMask = 1 shl 1;
   ControlMask = 1 shl 2;
   Mod1Mask = 1 shl 3;
   Mod2Mask = 1 shl 4;
   Mod3Mask = 1 shl 5;
   Mod4Mask = 1 shl 6;
   Mod5Mask = 1 shl 7;
   ShiftMapIndex = 0;
   LockMapIndex = 1;
   ControlMapIndex = 2;
   Mod1MapIndex = 3;
   Mod2MapIndex = 4;
   Mod3MapIndex = 5;
   Mod4MapIndex = 6;
   Mod5MapIndex = 7;
   Button1Mask = 1 shl 8;
   Button2Mask = 1 shl 9;
   Button3Mask = 1 shl 10;
   Button4Mask = 1 shl 11;
   Button5Mask = 1 shl 12;
   AnyModifier = 1 shl 15;
   Button1 = 1;
   Button2 = 2;
   Button3 = 3;
   Button4 = 4;
   Button5 = 5;
   NotifyNormal = 0;
   NotifyGrab = 1;
   NotifyUngrab = 2;
   NotifyWhileGrabbed = 3;
   NotifyHint = 1;
   NotifyAncestor = 0;
   NotifyVirtual = 1;
   NotifyInferior = 2;
   NotifyNonlinear = 3;
   NotifyNonlinearVirtual = 4;
   NotifyPointer = 5;
   NotifyPointerRoot = 6;
   NotifyDetailNone = 7;
   VisibilityUnobscured = 0;
   VisibilityPartiallyObscured = 1;
   VisibilityFullyObscured = 2;
   PlaceOnTop = 0;
   PlaceOnBottom = 1;
   FamilyInternet = 0;
   FamilyDECnet = 1;
   FamilyChaos = 2;
   FamilyInternet6 = 6;
   FamilyServerInterpreted = 5;
   PropertyNewValue = 0;
   PropertyDelete = 1;
   ColormapUninstalled = 0;
   ColormapInstalled = 1;
   GrabModeSync = 0;
   GrabModeAsync = 1;
   GrabSuccess = 0;
   AlreadyGrabbed = 1;
   GrabInvalidTime = 2;
   GrabNotViewable = 3;
   GrabFrozen = 4;
   AsyncPointer = 0;
   SyncPointer = 1;
   ReplayPointer = 2;
   AsyncKeyboard = 3;
   SyncKeyboard = 4;
   ReplayKeyboard = 5;
   AsyncBoth = 6;
   SyncBoth = 7;
   RevertToNone = None;
   RevertToPointerRoot = PointerRoot;
   RevertToParent = 2;
   Success = 0;
   BadRequest = 1;
   BadValue = 2;
   BadWindow = 3;
   BadPixmap = 4;
   BadAtom = 5;
   BadCursor = 6;
   BadFont = 7;
   BadMatch = 8;
   BadDrawable = 9;
   BadAccess = 10;
   BadAlloc = 11;
   BadColor = 12;
   BadGC = 13;
   BadIDChoice = 14;
   BadName = 15;
   BadLength = 16;
   BadImplementation = 17;
   FirstExtensionError = 128;
   LastExtensionError = 255;
   InputOutput = 1;
   InputOnly = 2;
   CWBackPixmap = 1 shl 0;
   CWBackPixel = 1 shl 1;
   CWBorderPixmap = 1 shl 2;
   CWBorderPixel = 1 shl 3;
   CWBitGravity = 1 shl 4;
   CWWinGravity = 1 shl 5;
   CWBackingStore = 1 shl 6;
   CWBackingPlanes = 1 shl 7;
   CWBackingPixel = 1 shl 8;
   CWOverrideRedirect = 1 shl 9;
   CWSaveUnder = 1 shl 10;
   CWEventMask = 1 shl 11;
   CWDontPropagate = 1 shl 12;
   CWColormap = 1 shl 13;
   CWCursor = 1 shl 14;
   CWX = 1 shl 0;
   CWY = 1 shl 1;
   CWWidth = 1 shl 2;
   CWHeight = 1 shl 3;
   CWBorderWidth = 1 shl 4;
   CWSibling = 1 shl 5;
   CWStackMode = 1 shl 6;
   ForgetGravity = 0;
   NorthWestGravity = 1;
   NorthGravity = 2;
   NorthEastGravity = 3;
   WestGravity = 4;
   CenterGravity = 5;
   EastGravity = 6;
   SouthWestGravity = 7;
   SouthGravity = 8;
   SouthEastGravity = 9;
   StaticGravity = 10;
   UnmapGravity = 0;
   NotUseful = 0;
   WhenMapped = 1;
   Always = 2;
   IsUnmapped = 0;
   IsUnviewable = 1;
   IsViewable = 2;
   SetModeInsert = 0;
   SetModeDelete = 1;
   DestroyAll = 0;
   RetainPermanent = 1;
   RetainTemporary = 2;
   Above = 0;
   Below = 1;
   TopIf = 2;
   BottomIf = 3;
   Opposite = 4;
   RaiseLowest = 0;
   LowerHighest = 1;
   PropModeReplace = 0;
   PropModePrepend = 1;
   PropModeAppend = 2;
   GXclear = $0;
   GXand = $1;
   GXandReverse = $2;
   GXcopy = $3;
   GXandInverted = $4;
   GXnoop = $5;
   GXxor = $6;
   GXor = $7;
   GXnor = $8;
   GXequiv = $9;
   GXinvert = $a;
   GXorReverse = $b;
   GXcopyInverted = $c;
   GXorInverted = $d;
   GXnand = $e;
   GXset = $f;
   LineSolid = 0;
   LineOnOffDash = 1;
   LineDoubleDash = 2;
   CapNotLast = 0;
   CapButt = 1;
   CapRound = 2;
   CapProjecting = 3;
   JoinMiter = 0;
   JoinRound = 1;
   JoinBevel = 2;
   FillSolid = 0;
   FillTiled = 1;
   FillStippled = 2;
   FillOpaqueStippled = 3;
   EvenOddRule = 0;
   WindingRule = 1;
   ClipByChildren = 0;
   IncludeInferiors = 1;
   Unsorted = 0;
   YSorted = 1;
   YXSorted = 2;
   YXBanded = 3;
   CoordModeOrigin = 0;
   CoordModePrevious = 1;
   Complex = 0;
   Nonconvex = 1;
   Convex = 2;
   ArcChord = 0;
   ArcPieSlice = 1;
   GCFunction = 1 shl 0;
   GCPlaneMask = 1 shl 1;
   GCForeground = 1 shl 2;
   GCBackground = 1 shl 3;
   GCLineWidth = 1 shl 4;
   GCLineStyle = 1 shl 5;
   GCCapStyle = 1 shl 6;
   GCJoinStyle = 1 shl 7;
   GCFillStyle = 1 shl 8;
   GCFillRule = 1 shl 9;
   GCTile = 1 shl 10;
   GCStipple = 1 shl 11;
   GCTileStipXOrigin = 1 shl 12;
   GCTileStipYOrigin = 1 shl 13;
   GCFont = 1 shl 14;
   GCSubwindowMode = 1 shl 15;
   GCGraphicsExposures = 1 shl 16;
   GCClipXOrigin = 1 shl 17;
   GCClipYOrigin = 1 shl 18;
   GCClipMask = 1 shl 19;
   GCDashOffset = 1 shl 20;
   GCDashList = 1 shl 21;
   GCArcMode = 1 shl 22;
   GCLastBit = 22;
   FontLeftToRight = 0;
   FontRightToLeft = 1;
   FontChange = 255;
   XYBitmap = 0;
   XYPixmap = 1;
   ZPixmap = 2;
   AllocNone = 0;
   AllocAll = 1;
   DoRed = 1 shl 0;
   DoGreen = 1 shl 1;
   DoBlue = 1 shl 2;
   CursorShape = 0;
   TileShape = 1;
   StippleShape = 2;
   AutoRepeatModeOff = 0;
   AutoRepeatModeOn = 1;
   AutoRepeatModeDefault = 2;
   LedModeOff = 0;
   LedModeOn = 1;
   KBKeyClickPercent = 1 shl 0;
   KBBellPercent = 1 shl 1;
   KBBellPitch = 1 shl 2;
   KBBellDuration = 1 shl 3;
   KBLed = 1 shl 4;
   KBLedMode = 1 shl 5;
   KBKey = 1 shl 6;
   KBAutoRepeatMode = 1 shl 7;
   MappingSuccess = 0;
   MappingBusy = 1;
   MappingFailed = 2;
   MappingModifier = 0;
   MappingKeyboard = 1;
   MappingPointer = 2;
   DontPreferBlanking = 0;
   PreferBlanking = 1;
   DefaultBlanking = 2;
   DisableScreenSaver = 0;
   DisableScreenInterval = 0;
   DontAllowExposures = 0;
   AllowExposures = 1;
   DefaultExposures = 2;
   ScreenSaverReset = 0;
   ScreenSaverActive = 1;
   HostInsert = 0;
   HostDelete = 1;
   EnableAccess = 1;
   DisableAccess = 0;
   StaticGray = 0;
   GrayScale = 1;
   StaticColor = 2;
   PseudoColor = 3;
   TrueColor = 4;
   DirectColor = 5;
   LSBFirst = 0;
   MSBFirst = 1;

{$endregion x}

type

{$region x11}
  PXRRScreenSize = ^TXRRScreenSize;
  TXRRScreenSize = record
    width, height: cint;
    mwidth, mheight: cint;
  end;
{$endregion x11}

{$region xlib}

const
  XIMPreeditArea = $0001;
  XIMPreeditCallbacks = $0002;
  XIMPreeditPosition = $0004;
  XIMPreeditNothing = $0008;
  XIMPreeditNone = $0010;
  XIMStatusArea = $0100;
  XIMStatusCallbacks = $0200;
  XIMStatusNothing = $0400;
  XIMStatusNone = $0800;
  XNInputStyle: AnsiString = 'inputStyle';

type
  TBool = cint;
  TBoolResult = longbool;
  PStatus = ^TStatus;
  TStatus = cint;
  PPcuchar = ^Pcuchar;

  PXPointer = ^TXPointer;
  TXPointer = ^char;

  PPXExtData = ^PXExtData;
  PXExtData = ^TXExtData;
  TXExtData = record
    number: cint;
    next: PXExtData;
    free_private: function (extension:PXExtData):cint;cdecl;
    private_data: TXPointer;
  end;

  PVisual = ^TVisual;
  TVisual = record
    ext_data: PXExtData;
    visualid: TVisualID;
    c_class: cint;
    red_mask, green_mask, blue_mask: culong;
    bits_per_rgb: cint;
    map_entries: cint;
  end;

  PXDisplay = ^TXDisplay;
  TXDisplay = record
  end;
  PDisplay = ^TDisplay;
  TDisplay = TXDisplay;

  PXGC = ^TXGC;
  TXGC = record
  end;
  TGC = PXGC;
  PGC = ^TGC;

  PDepth = ^TDepth;
  TDepth = record
    depth: cint;
    nvisuals: cint;
    visuals: PVisual;
  end;

  PScreen = ^TScreen;
  TScreen = record
    ext_data: PXExtData;
    display: PXDisplay;
    root: TWindow;
    width, height: cint;
    mwidth, mheight: cint;
    ndepths: cint;
    depths: PDepth;
    root_depth: cint;
    root_visual: PVisual;
    default_gc: TGC;
    cmap: TColormap;
    white_pixel: culong;
    black_pixel: culong;
    max_maps, min_maps: cint;
    backing_store: cint;
    save_unders: TBool;
    root_input_mask: clong;
  end;

  PXSetWindowAttributes = ^TXSetWindowAttributes;
  TXSetWindowAttributes = record
    background_pixmap: TPixmap;
    background_pixel: culong;
    border_pixmap: TPixmap;
    border_pixel: culong;
    bit_gravity: cint;
    win_gravity: cint;
    backing_store: cint;
    backing_planes: culong;
    backing_pixel: culong;
    save_under: TBool;
    event_mask: clong;
    do_not_propagate_mask: clong;
    override_redirect: TBool;
    colormap: TColormap;
    cursor: TCursor;
  end;

  PXTextProperty = ^TXTextProperty;
  TXTextProperty = record
    value: pcuchar;
    encoding: TAtom;
    format: cint;
    nitems: culong;
  end;

  PXVisualInfo = ^TXVisualInfo;
  TXVisualInfo = record
    visual: PVisual;
    visualid: TVisualID;
    screen: cint;
    depth: cint;
    _class: cint;
    red_mask: culong;
    green_mask: culong;
    blue_mask: culong;
    colormap_size: cint;
    bits_per_rgb: cint;
  end;

  PXSizeHints = ^TXSizeHints;
  TXSizeHints = record
    flags: clong;
    x, y: cint;
    width, height: cint;
    min_width, min_height: cint;
    max_width, max_height: cint;
    width_inc, height_inc: cint;

    min_aspect, max_aspect: record
      x: cint;
      y: cint;
    end;

    base_width, base_height: cint;
    win_gravity: cint;
  end;

  PXWMHints = ^TXWMHints;
  TXWMHints = record
    flags: clong;
    input: TBool;
    initial_state: cint;
    icon_pixmap: TPixmap;
    icon_window: TWindow;
    icon_x, icon_y: cint;
    icon_mask: TPixmap;
    window_group: TXID;
  end;

  PXPrivate = ^TXPrivate;
  TXPrivate = record
  end;

  PScreenFormat = ^TScreenFormat;
  TScreenFormat = record
    ext_data: PXExtData;
    depth: cint;
    bits_per_pixel: cint;
    scanline_pad: cint;
  end;

  PXrmHashBucketRec = ^TXrmHashBucketRec;
  TXrmHashBucketRec = record
  end;

  PXPrivDisplay = ^TXPrivDisplay;
  TXPrivDisplay = record
    ext_data: PXExtData;
    private1: PXPrivate;
    fd: cint;
    private2: cint;
    proto_major_version: cint;
    proto_minor_version: cint;
    vendor: PAnsiChar;
    private3: TXID;
    private4: TXID;
    private5: TXID;
    private6: cint;
    resource_alloc: function (para1:PXDisplay):TXID;cdecl;
    byte_order: cint;
    bitmap_unit: cint;
    bitmap_pad: cint;
    bitmap_bit_order: cint;
    nformats: cint;
    pixmap_format: PScreenFormat;
    private8: cint;
    release: cint;
    private9, private10: PXPrivate;
    qlen: cint;
    last_request_read: culong;
    request: culong;
    private11: TXPointer;
    private12: TXPointer;
    private13: TXPointer;
    private14: TXPointer;
    max_request_size: cunsigned;
    db: PXrmHashBucketRec;
    private15: function (para1:PXDisplay):cint; cdecl;
    display_name: PAnsiChar;
    default_screen: cint;
    nscreens: cint;
    screens: PScreen;
    motion_buffer: culong;
    private16: culong;
    min_keycode: cint;
    max_keycode: cint;
    private17: TXPointer;
    private18: TXPointer;
    private19: cint;
    xdefaults: PAnsiChar;
  end;

  PXWindowChanges = ^TXWindowChanges;
  TXWindowChanges = record
    x, y: cint;
    width, height: cint;
    border_width: cint;
    sibling: TWindow;
    stack_mode: cint;
  end;

  PXKeyEvent = ^TXKeyEvent;
  TXKeyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    keycode: cuint;
    same_screen: TBool;
  end;

  PXKeyPressedEvent = ^TXKeyPressedEvent;
  TXKeyPressedEvent = TXKeyEvent;

  PXKeyReleasedEvent = ^TXKeyReleasedEvent;
  TXKeyReleasedEvent = TXKeyEvent;

  PXButtonEvent = ^TXButtonEvent;
  TXButtonEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: uint64;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    button: cuint;
    same_screen: TBool;
  end;

  PXButtonPressedEvent = ^TXButtonPressedEvent;
  TXButtonPressedEvent = TXButtonEvent;

  PXButtonReleasedEvent = ^TXButtonReleasedEvent;
  TXButtonReleasedEvent = TXButtonEvent;

  PXMotionEvent = ^TXMotionEvent;
  TXMotionEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    state: cuint;
    is_hint: cchar;
    same_screen: TBool;
  end;

  PXPointerMovedEvent = ^TXPointerMovedEvent;
  TXPointerMovedEvent = TXMotionEvent;

  PXCrossingEvent = ^TXCrossingEvent;
  TXCrossingEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    subwindow: TWindow;
    time: TTime;
    x, y: cint;
    x_root, y_root: cint;
    mode: cint;
    detail: cint;
    same_screen: TBool;
    focus: TBool;
    state: cuint;
  end;

  PXEnterWindowEvent = ^TXEnterWindowEvent;
  TXEnterWindowEvent = TXCrossingEvent;

  PXLeaveWindowEvent = ^TXLeaveWindowEvent;
  TXLeaveWindowEvent = TXCrossingEvent;

  PXFocusChangeEvent = ^TXFocusChangeEvent;
  TXFocusChangeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    mode: cint;
    detail: cint;
  end;

  PXFocusInEvent = ^TXFocusInEvent;
  TXFocusInEvent = TXFocusChangeEvent;

  PXFocusOutEvent = ^TXFocusOutEvent;
  TXFocusOutEvent = TXFocusChangeEvent;

  PXKeymapEvent = ^TXKeymapEvent;
  TXKeymapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    key_vector: array[0..31] of cchar;
  end;

  PXExposeEvent = ^TXExposeEvent;
  TXExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    x, y: cint;
    width, height: cint;
    count: cint;
  end;

  PXGraphicsExposeEvent = ^TXGraphicsExposeEvent;
  TXGraphicsExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    drawable: TDrawable;
    x, y: cint;
    width, height: cint;
    count: cint;
    major_code: cint;
    minor_code: cint;
  end;

  PXNoExposeEvent = ^TXNoExposeEvent;
  TXNoExposeEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    drawable: TDrawable;
    major_code: cint;
    minor_code: cint;
  end;

  PXVisibilityEvent = ^TXVisibilityEvent;
  TXVisibilityEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    state: cint;
  end;

  PXCreateWindowEvent = ^TXCreateWindowEvent;
  TXCreateWindowEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    x, y: cint;
    width, height: cint;
    border_width: cint;
    override_redirect: TBool;
  end;

  PXDestroyWindowEvent = ^TXDestroyWindowEvent;
  TXDestroyWindowEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
  end;

  PXUnmapEvent = ^TXUnmapEvent;
  TXUnmapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    from_configure: TBool;
  end;

  PXMapEvent = ^TXMapEvent;
  TXMapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    override_redirect: TBool;
  end;

  PXMapRequestEvent = ^TXMapRequestEvent;
  TXMapRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
  end;

  PXReparentEvent = ^TXReparentEvent;
  TXReparentEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    parent: TWindow;
    x, y: cint;
    override_redirect: TBool;
  end;

  PXConfigureEvent = ^TXConfigureEvent;
  TXConfigureEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    x, y: cint;
    width, height: cint;
    border_width: cint;
    above: TWindow;
    override_redirect: TBool;
  end;

  PXGravityEvent = ^TXGravityEvent;
  TXGravityEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    x, y: cint;
  end;

  PXResizeRequestEvent = ^TXResizeRequestEvent;
  TXResizeRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    width, height: cint;
  end;

  PXConfigureRequestEvent = ^TXConfigureRequestEvent;
  TXConfigureRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    x, y: cint;
    width, height: cint;
    border_width: cint;
    above: TWindow;
    detail: cint;
    value_mask: culong;
  end;

  PXCirculateEvent = ^TXCirculateEvent;
  TXCirculateEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    event: TWindow;
    window: TWindow;
    place: cint;
  end;

  PXCirculateRequestEvent = ^TXCirculateRequestEvent;
  TXCirculateRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    parent: TWindow;
    window: TWindow;
    place: cint;
  end;

  PXPropertyEvent = ^TXPropertyEvent;
  TXPropertyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    atom: TAtom;
    time: TTime;
    state: cint;
  end;

  PXSelectionClearEvent = ^TXSelectionClearEvent;
  TXSelectionClearEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    selection: TAtom;
    time: TTime;
  end;

  PXSelectionRequestEvent = ^TXSelectionRequestEvent;
  TXSelectionRequestEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    owner: TWindow;
    requestor: TWindow;
    selection: TAtom;
    target: TAtom;
    _property: TAtom;
    time: TTime;
  end;

  PXSelectionEvent = ^TXSelectionEvent;
  TXSelectionEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    requestor: TWindow;
    selection: TAtom;
    target: TAtom;
    _property: TAtom;
    time: TTime;
  end;

  PXColormapEvent = ^TXColormapEvent;
  TXColormapEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    colormap: TColormap;
    c_new: TBool;
    state: cint;
  end;

  PXClientMessageEvent = ^TXClientMessageEvent;
  TXClientMessageEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    message_type: TAtom;
    format: cint;
    data: record
        case integer of
           0: ( b: array[0..19] of cchar );
           1: ( s: array[0..9] of cshort );
           2: ( l: array[0..4] of clong );
        end;
  end;

  PXMappingEvent = ^TXMappingEvent;
  TXMappingEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    request: cint;
    first_keycode: cint;
    count: cint;
  end;

  PXErrorEvent = ^TXErrorEvent;
  TXErrorEvent = record
    _type: cint;
    display: PDisplay;
    resourceid: TXID;
    serial: culong;
    error_code: cuchar;
    request_code: cuchar;
    minor_code: cuchar;
  end;

  PXAnyEvent = ^TXAnyEvent;
  TXAnyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
  end;

  (***************************************************************
  *
  * GenericEvent.  This event is the standard event for all newer extensions.
  *)

  PXGenericEvent = ^TXGenericEvent;
  TXGenericEvent = record
    _type: cint;                 { of event. Always GenericEvent }
    serial: culong;              { # of last request processed }
    send_event: TBool;           { true if from SendEvent request }
    display: PDisplay;           { Display the event was read from }
    extension: cint;             { major opcode of extension that caused the event }
    evtype: cint;                { actual event type. }
  end;

  PXGenericEventCookie = ^TXGenericEventCookie;
  TXGenericEventCookie = record
    _type: cint;                 { of event. Always GenericEvent }
    serial: culong;              { # of last request processed }
    send_event: TBool;           { true if from SendEvent request }
    display: PDisplay;           { Display the event was read from }
    extension: cint;             { major opcode of extension that caused the event }
    evtype: cint;                { actual event type. }
    cookie: cuint;
    data: pointer;
  end;

  PXEvent = ^TXEvent;
  TXEvent = record
  case int32 of
    0: ( _type: cint );
    1: ( xany: TXAnyEvent );
    2: ( xkey: TXKeyEvent );
    3: ( xbutton: TXButtonEvent );
    4: ( xmotion: TXMotionEvent );
    5: ( xcrossing: TXCrossingEvent );
    6: ( xfocus: TXFocusChangeEvent );
    7: ( xexpose: TXExposeEvent );
    8: ( xgraphicsexpose: TXGraphicsExposeEvent );
    9: ( xnoexpose: TXNoExposeEvent );
    10: ( xvisibility: TXVisibilityEvent );
    11: ( xcreatewindow: TXCreateWindowEvent );
    12: ( xdestroywindow: TXDestroyWindowEvent );
    13: ( xunmap: TXUnmapEvent );
    14: ( xmap: TXMapEvent );
    15: ( xmaprequest: TXMapRequestEvent );
    16: ( xreparent: TXReparentEvent );
    17: ( xconfigure: TXConfigureEvent );
    18: ( xgravity: TXGravityEvent );
    19: ( xresizerequest: TXResizeRequestEvent );
    20: ( xconfigurerequest: TXConfigureRequestEvent );
    21: ( xcirculate: TXCirculateEvent );
    22: ( xcirculaterequest: TXCirculateRequestEvent );
    23: ( xproperty: TXPropertyEvent );
    24: ( xselectionclear: TXSelectionClearEvent );
    25: ( xselectionrequest: TXSelectionRequestEvent );
    26: ( xselection: TXSelectionEvent );
    27: ( xcolormap: TXColormapEvent );
    28: ( xclient: TXClientMessageEvent );
    29: ( xmapping: TXMappingEvent );
    30: ( xerror: TXErrorEvent );
    31: ( xkeymap: TXKeymapEvent );
    32: ( xgeneric: TXGenericEvent );
    33: ( xcookie: TXGenericEventCookie );
    34: ( pad: array[0..23] of clong );
  end;

  PMotifWmHints = ^TMotifWmHints;
  TMotifWmHints = packed record
    Flags, Functions, Decorations: LongWord;
    InputMode: int32;
    Status: LongWord;
  end;

const
   InputHint = 1 shl 0;
   StateHint = 1 shl 1;
   IconPixmapHint = 1 shl 2;
   IconWindowHint = 1 shl 3;
   IconPositionHint = 1 shl 4;
   IconMaskHint = 1 shl 5;
   WindowGroupHint = 1 shl 6;
   AllHints = InputHint or StateHint or IconPixmapHint or IconWindowHint or IconPositionHint or IconMaskHint or WindowGroupHint;
   XUrgencyHint = 1 shl 8;
   WithdrawnState = 0;
   NormalState = 1;
   IconicState = 3;
   DontCareState = 0;
   ZoomState = 2;
   InactiveState = 4;

const
   USPosition = 1 shl 0;
   USSize = 1 shl 1;
   PPosition = 1 shl 2;
   PSize = 1 shl 3;
   PMinSize = 1 shl 4;
   PMaxSize = 1 shl 5;
   PResizeInc = 1 shl 6;
   PAspect = 1 shl 7;
   PBaseSize = 1 shl 8;
   PWinGravity = 1 shl 9;
   PAllHints = PPosition or PSize or PMinSize or PMaxSize or PResizeInc or PAspect;

   XBufferOverflow = -(1);
   XLookupNone = 1;
   XLookupChars = 2;
   XLookupKeySymVal = 3;
   XLookupBoth = 4;

   _NET_WM_STATE_REMOVE = 0;    // remove/unset property
   _NET_WM_STATE_ADD    = 1;    // add/set property
   _NET_WM_STATE_TOGGLE = 2;    // toggle property

type
  TXConnectionWatchProc = procedure (para1:PDisplay; para2:TXPointer; para3:cint; para4:TBool; para5:PXPointer);cdecl;
  funcDisp = function(display: PDisplay): cint;cdecl;
  funcIfEvent = function(display: PDisplay; event: PXEvent; p: TXPointer):TBoolResult; cdecl;

  TXICCEncodingStyle = (XStringStyle, XCompoundTextStyle, XTextStyle, XStdICCTextStyle, XUTF8StringStyle);

var
  XDisplayName: function(para1:PAnsiChar):PAnsiChar; cdecl;
  XOpenDisplay: function(para1:PAnsiChar):PDisplay;cdecl;
  XCloseDisplay: function(para1:PDisplay):cint;cdecl;
  XDisplayHeight: function(para1: PDisplay; para2: cint):cint; cdecl;
  XDisplayHeightMM: function(para1:PDisplay; para2:cint):cint;cdecl;
  XDisplayKeycodes: function(para1:PDisplay; para2:Pcint; para3:Pcint):cint;cdecl;
  XDisplayPlanes: function (para1:PDisplay; para2:cint):cint;cdecl;
  XDisplayWidth: function (para1:PDisplay; para2:cint):cint;cdecl;
  XDisplayWidthMM: function (para1:PDisplay; para2:cint):cint;cdecl;
  XCreateColormap: function(para1: PDisplay; para2: TWindow; para3: PVisual; para4: cint): TColormap; cdecl;
  XDefaultColormap: function(para1: PDisplay; para2:cint): TColormap; cdecl;
  XDefaultScreen: function(para1: PDisplay):cint; cdecl;
  XDefaultRootWindow: function(ADisplay: PDisplay):TWindow; cdecl;
  XDefaultVisual: function(para1: PDisplay; para2: cint):PVisual;cdecl;
  XDefaultDepth: function(para1:PDisplay; para2:cint):cint;cdecl;
  XDefaultDepthOfScreen: function(para1:PScreen):cint;cdecl;

  XCreateWindow: function(ADisplay:PDisplay; AParent:TWindow; AX:cint; AY:cint; AWidth:cuint;
           AHeight:cuint; ABorderWidth:cuint; ADepth:cint; AClass:cuint; AVisual:PVisual;
           AValueMask:culong; AAttributes:PXSetWindowAttributes):TWindow;cdecl;
  XCreateSimpleWindow: function(ADisplay:PDisplay; AParent:TWindow; AX:cint; AY:cint; AWidth:cuint;
           AHeight:cuint; ABorderWidth:cuint; ABorder:culong; ABackground:culong):TWindow;cdecl;
  XMapRaised: function(ADisplay:PDisplay; AWindow:TWindow):cint;cdecl;
  XMapWindow: function(ADisplay:PDisplay; AWindow:TWindow):cint;cdecl;
  XUnmapWindow: function(ADisplay:PDisplay; AWindow:TWindow):cint;cdecl;
  XClearWindow: function(para1:PDisplay; para2:TWindow):cint;cdecl;
  XDestroyWindow: function (ADisplay:PDisplay; AWindow:TWindow):cint;cdecl;
  XGetWindowProperty: function(para1:PDisplay; para2:TWindow; para3:TAtom; para4:clong; para5:clong;
           para6:TBool; para7:TAtom; para8:PAtom; para9:Pcint; para10:Pculong;
           para11:Pculong; para12:PPcuchar):cint;cdecl;
  XMoveWindow: function(ADisplay:PDisplay; AWindow:TWindow; AX:cint; AY:cint):cint;cdecl;
  XConfigureWindow: function(para1:PDisplay; para2:TWindow; para3:cuint; para4:PXWindowChanges):cint;cdecl;

  XSelectInput: function(ADisplay:PDisplay; AWindow:TWindow; AEventMask:clong):cint; cdecl;
  XSetStandardProperties: function(para1:PDisplay; para2:TWindow; para3:PAnsiChar; para4:PAnsiChar; para5:TPixmap;
           para6:PPAnsiChar; para7:cint; para8:PXSizeHints):cint;cdecl;
  XInternAtom: function(para1:PDisplay; para2:PAnsiChar; para3:TBool):TAtom; cdecl;
  XSetClassHint: function(para1: PDisplay; para2: TWindow; para3: PXClassHint):cint;cdecl;
  XAllocClassHint: function:PXClassHint;cdecl;
  XFree: function(para1:pointer):cint;cdecl;

  XSetWMProperties: procedure(ADisplay:PDisplay; AWindow:TWindow; AWindowName:PXTextProperty; AIconName:PXTextProperty; AArgv:PPAnsiChar;
            AArgc:cint; ANormalHints:PXSizeHints; AWMHints:PXWMHints; AClassHints:PXClassHint);cdecl;
  XSetWMProtocols: function(para1:PDisplay; para2:TWindow; para3:PAtom; para4:cint):TStatus; cdecl;
  XSetWMNormalHints: procedure(ADisplay:PDisplay; AWindow:TWindow; AHints:PXSizeHints);cdecl;
  XSetWMHints: function(para1:PDisplay; para2:TWindow; para3:PXWMHints):cint; cdecl;
  XGetWMNormalHints: function(para1:PDisplay; para2:TWindow; para3:PXSizeHints; para4:Pclong):TStatus;cdecl;
  XGetWMSizeHints: function (para1:PDisplay; para2:TWindow; para3:PXSizeHints; para4:Pclong; para5:TAtom):TStatus;cdecl;
  XSetWMIconName: procedure (para1:PDisplay; para2:TWindow; para3:PXTextProperty);cdecl;
  XSetWMName: procedure(para1:PDisplay; para2:TWindow; para3:PXTextProperty);cdecl;
  XSetTransientForHint: function(ADisplay:PDisplay; AWindow:TWindow; APropWindow:TWindow):cint;cdecl;

  XInternalConnectionNumbers: function(para1:PDisplay; para2:PPcint; para3:Pcint):TStatus;cdecl;
  XProcessInternalConnection: procedure(para1:PDisplay; para2:cint);cdecl;
  XAddConnectionWatch: function(para1:PDisplay; para2:TXConnectionWatchProc; para3:TXPointer):TStatus;cdecl;
  XRemoveConnectionWatch: procedure (para1:PDisplay; para2:TXConnectionWatchProc; para3:TXPointer);cdecl;
  XSetAuthorization: procedure(para1:PAnsiChar; para2:cint; para3:PAnsiChar; para4:cint);cdecl;

  XOpenIM: function(para1: PDisplay; para2: PXrmHashBucketRec; para3: PAnsichar; para4: PAnsiChar): PXIM; cdecl;
  //XCreateIC: function(para1: PXIM; const para2: array of const): PXIC; cdecl;
  // method was adobted for need fix count attributes from C syntaxis: XIC XCreateIC(XIM im, ...);
  XCreateIC: function(para1: PXIM; para2: pAnsiChar; param3: cint; param4: cint): PXIC; cdecl;
  XDestroyIC: procedure(ic: PXIC); cdecl;
  XCloseIM: function(im: PXIM): TStatus; cdecl;
  XPeekEvent: function(ADisplay:PDisplay; AEvent:PXEvent):cint;cdecl;
  XPeekIfEvent: function(para1:PDisplay; para2:PXEvent; para3: funcIfEvent; para4:TXPointer):cint;cdecl;
  XPending: function(para1:PDisplay):cint;cdecl;
  XNextEvent: function (ADisplay:PDisplay; AEvent:PXEvent):cint;cdecl;
  XSendEvent: function(para1: PDisplay; para2: TWindow; para3: TBool; para4: clong; para5: PXEvent):TStatus;cdecl;
  XLookupKeysym: function (para1: PXKeyEvent; para2: cint):TKeySym;cdecl;
  XQueryPointer: function(para1:PDisplay; para2:TWindow; para3:PWindow; para4:PWindow; para5:Pcint;
           para6:Pcint; para7:Pcint; para8:Pcint; para9:Pcuint):TBoolResult;cdecl;
  XCheckTypedEvent: function(para1:PDisplay; para2:cint; para3:PXEvent):TBoolResult;cdecl;
  XCheckTypedWindowEvent: function(para1:PDisplay; para2:TWindow; para3:cint; para4:PXEvent):TBoolResult;cdecl;
  XCheckWindowEvent: function(para1:PDisplay; para2:TWindow; para3:clong; para4:PXEvent):TBoolResult;cdecl;
  XChangeProperty: function(para1:PDisplay; para2:TWindow; para3:TAtom; para4:TAtom; para5:cint;
           para6:cint; para7:Pcuchar; para8:cint):cint;cdecl;
  XStringListToTextProperty: function(para1:PPchar; para2:cint; para3:PXTextProperty):TStatus;cdecl;
  XBlackPixel: function(ADisplay:PDisplay; AScreenNumber:cint):culong;cdecl;
  XWhitePixel: function(ADisplay:PDisplay; AScreenNumber:cint):culong;cdecl;
  XSync: function(para1:PDisplay; para2:TBool):cint;cdecl;

  Xutf8LookupString: function(para1: PXIC; para2: PXKeyPressedEvent; para3: PAnsichar; para4: cint; para5: PKeySym; para6: PStatus):cint; cdecl;
  Xutf8TextListToTextProperty: function(para1:PDisplay; para2:PPchar; para3:cint; para4:TXICCEncodingStyle; para5:PXTextProperty):cint;cdecl;

  XFlush: function(para1:PDisplay):cint;cdecl;
//function XAllPlanes:culong;cdecl;external 'libX11.so';

function DefaultScreen(Display: PDisplay): cint;
function DefaultRootWindow(Display: PDisplay): TWindow;
function ScreenOfDisplay(Display: PDisplay; Screen: cint): PScreen;
function XKeyToBSKey(AX11Key: TKeySym; KeyCode: uint32): Word;

{$endregion xlib}

{$region pango}

type
  PPangoFontDescription = ^TPangoFontDescription;
  TPangoFontDescription = pointer;

  PPangoAttrList = ^TPangoAttrList;
  TPangoAttrList = pointer;

  PPangoAttrIterator = ^TPangoAttrIterator;
  TPangoAttrIterator = pointer;

  PPangoLayout = ^TPangoLayout;
  TPangoLayout = pointer;

  PPangoLayoutClass = ^TPangoLayoutClass;
  TPangoLayoutClass = pointer;

  PPangoLayoutIter = ^TPangoLayoutIter;
  TPangoLayoutIter = pointer;

  PPangoContext = ^TPangoContext;
  TPangoContext = pointer;

  PPangoContextClass = ^TPangoContextClass;
  TPangoContextClass = pointer;

  PPangoFontsetSimple = ^TPangoFontsetSimple;
  TPangoFontsetSimple = pointer;

  PPangoTabArray = ^TPangoTabArray;
  TPangoTabArray = pointer;

{$endregion pango}

{$region Xrandr}

const

  { used in XRRSelectInput }
  RRScreenChangeNotifyMask = 1;
  RRScreenChangeNotify     = 0;

type

  { internal representation is private to the library }
  PXRRScreenConfiguration = ^TXRRScreenConfiguration;
  TXRRScreenConfiguration = record end;

  PRotation      = ^TRotation;
  TRotation      = cushort;
  PSizeID        = ^TSizeID;
  TSizeID        = cushort;
  PSubpixelOrder = ^TSubpixelOrder;
  TSubpixelOrder = cushort;

var
  XRRScreenConfig: function(dpy: PDisplay; screen: cint): PXRRScreenConfiguration; cdecl;
  XRRConfig: function(screen: PScreen): PXRRScreenConfiguration; cdecl;
  XRRSelectInput: procedure(dpy: PDisplay; window: TWindow; mask: cint); cdecl;
  XRRQueryExtension: function(dpy: PDisplay; event_basep, error_basep: Pcint): TBoolResult; cdecl;
  XRRRotations: function(dpy: PDisplay; screen: cint; current_rotation: PRotation): TRotation; cdecl;
  XRRSizes: function(dpy: PDisplay; screen: cint; nsizes: Pcint): PXRRScreenSize; cdecl;
  XRRRootToScreen: function(dpy: PDisplay; root: TWindow): cint; cdecl;
  XRRGetScreenInfo: function(dpy: PDisplay; draw: TDrawable): PXRRScreenConfiguration; cdecl;
  XRRFreeScreenConfigInfo: procedure(config: PXRRScreenConfiguration); cdecl;
  XRRConfigCurrentConfiguration: function(config: PXRRScreenConfiguration; rotation: PRotation): TSizeID; cdecl;

{$endregion Xrandr}

implementation

uses
    SysUtils
  {$ifdef FPC}
  , cwstring // include the unit otherwise get excepion on LoadLibrary(X11)
  , math
  {$endif}
  , bs.events.keyboard
  ;

function DefaultScreen(Display: PDisplay): cint;
begin
  Result := PXPrivDisplay(Display).default_screen;
end;

function ScreenOfDisplay(Display: PDisplay; Screen: cint): PScreen;
//var
//  PrivDisplay: PXPrivDisplay;
begin
  Result := PScreen(PByte(PXPrivDisplay(Display)^.screens)+Screen*SizeOf(Pointer));
  //PrivDisplay := PXPrivDisplay(Display);
  //Result := PScreen(PrivDisplay^.screens);
end;

function DefaultRootWindow(Display: PDisplay): TWindow;
begin
  Result := ScreenOfDisplay(Display, DefaultScreen(Display))^.root;
end;

function XKeyToBSKey(AX11Key: TKeySym; KeyCode: uint32): Word;
begin
  case AX11Key of
    $20: Result := VK_BS_SPACE;
  {0x0021   U0021   .   # exclam
   0x0022   U0022   .   # quotedbl
   0x0023   U0023   .   # numbersign
   0x0024   U0024   .   # dollar
   0x0025   U0025   .   # percent
   0x0026   U0026   .   # ampersand
   0x0027   U0027   .   # apostrophe
   0x0028   U0028   .   # parenleft
   0x0029   U0029   .   # parenright
   0x002a   U002a   .   # asterisk
   0x002b   U002b   .   # plus
   0x002c   U002c   .   # comma
   0x002d   U002d   .   # minus
   0x002e   U002e   .   # period
   0x002f   U002f   .   # slash}
    $0030: Result := VK_BS_0;
    $0031: Result := VK_BS_1;
    $0032: Result := VK_BS_2;
    $0033: Result := VK_BS_3;
    $0034: Result := VK_BS_4;
    $0035: Result := VK_BS_5;
    $0036: Result := VK_BS_6;
    $0037: Result := VK_BS_7;
    $0038: Result := VK_BS_8;
    $0039: Result := VK_BS_9;
{ 0x003a   U003a   .   # colon
 0x003b   U003b   .   # semicolon
 0x003c   U003c   .   # less
 0x003d   U003d   .   # equal
 0x003e   U003e   .   # greater
 0x003f   U003f   .   # question
 0x0040   U0040   .   # at      }
    $41: Result := VK_BS_A;
    $42: Result := VK_BS_B;
    $43: Result := VK_BS_C;
    $44: Result := VK_BS_D;
    $45: Result := VK_BS_E;
    $46: Result := VK_BS_F;
    $47: Result := VK_BS_G;
    $48: Result := VK_BS_H;
    $49: Result := VK_BS_I;
    $4A: Result := VK_BS_J;
    $4B: Result := VK_BS_K;
    $4C: Result := VK_BS_L;
    $4D: Result := VK_BS_M;
    $4E: Result := VK_BS_N;
    $4F: Result := VK_BS_O;
    $50: Result := VK_BS_P;
    $51: Result := VK_BS_Q;
    $52: Result := VK_BS_R;
    $53: Result := VK_BS_S;
    $54: Result := VK_BS_T;
    $55: Result := VK_BS_U;
    $56: Result := VK_BS_V;
    $57: Result := VK_BS_W;
    $58: Result := VK_BS_X;
    $59: Result := VK_BS_Y;
    $5A: Result := VK_BS_Z;
{ 0x005b   U005b   .   # bracketleft
 0x005c   U005c   .   # backslash
 0x005d   U005d   .   # bracketright
 0x005e   U005e   .   # asciicircum
 0x005f   U005f   .   # underscore
 0x0060   U0060   .   # grave
 0x0060   U0060   .   # quoteleft	/* deprecated */ }
    $61: Result := VK_BS_A;
    $62: Result := VK_BS_B;
    $63: Result := VK_BS_C;
    $64: Result := VK_BS_D;
    $65: Result := VK_BS_E;
    $66: Result := VK_BS_F;
    $67: Result := VK_BS_G;
    $68: Result := VK_BS_H;
    $69: Result := VK_BS_I;
    $6A: Result := VK_BS_J;
    $6B: Result := VK_BS_K;
    $6C: Result := VK_BS_L;
    $6D: Result := VK_BS_M;
    $6E: Result := VK_BS_N;
    $6F: Result := VK_BS_O;
    $70: Result := VK_BS_P;
    $71: Result := VK_BS_Q;
    $72: Result := VK_BS_R;
    $73: Result := VK_BS_S;
    $74: Result := VK_BS_T;
    $75: Result := VK_BS_U;
    $76: Result := VK_BS_V;
    $77: Result := VK_BS_W;
    $78: Result := VK_BS_X;
    $79: Result := VK_BS_Y;
    $7A: Result := VK_BS_Z;
{    0x007b   U007b   .   # braceleft
    0x007c   U007c   .   # bar
    0x007d   U007d   .   # braceright
    0x007e   U007e   .   # asciitilde
    0x00a0   U00a0   .   # nobreakspace
    0x00a1   U00a1   .   # exclamdown
    0x00a2   U00a2   .   # cent
    0x00a3   U00a3   .   # sterling
    0x00a4   U00a4   .   # currency
    0x00a5   U00a5   .   # yen
    0x00a6   U00a6   .   # brokenbar
    0x00a7   U00a7   .   # section
    0x00a8   U00a8   .   # diaeresis
    0x00a9   U00a9   .   # copyright
    0x00aa   U00aa   .   # ordfeminine
    0x00ab   U00ab   .   # guillemotleft	/* left angle quotation mark */
    0x00ac   U00ac   .   # notsign
    0x00ad   U00ad   .   # hyphen
    0x00ae   U00ae   .   # registered
    0x00af   U00af   .   # macron
    0x00b0   U00b0   .   # degree
    0x00b1   U00b1   .   # plusminus
    0x00b2   U00b2   .   # twosuperior
    0x00b3   U00b3   .   # threesuperior
    0x00b4   U00b4   .   # acute
    0x00b5   U00b5   .   # mu
    0x00b6   U00b6   .   # paragraph
    0x00b7   U00b7   .   # periodcentered
    0x00b8   U00b8   .   # cedilla
    0x00b9   U00b9   .   # onesuperior
    0x00ba   U00ba   .   # masculine
    0x00bb   U00bb   .   # guillemotright	/* right angle quotation mark */
    0x00bc   U00bc   .   # onequarter
    0x00bd   U00bd   .   # onehalf
    0x00be   U00be   .   # threequarters
    0x00bf   U00bf   .   # questiondown
    0x00c0   U00c0   .   # Agrave
    0x00c1   U00c1   .   # Aacute
    0x00c2   U00c2   .   # Acircumflex
    0x00c3   U00c3   .   # Atilde
    0x00c4   U00c4   .   # Adiaeresis
    0x00c5   U00c5   .   # Aring
    0x00c6   U00c6   .   # AE
    0x00c7   U00c7   .   # Ccedilla
    0x00c8   U00c8   .   # Egrave
    0x00c9   U00c9   .   # Eacute
    0x00ca   U00ca   .   # Ecircumflex
    0x00cb   U00cb   .   # Ediaeresis
    0x00cc   U00cc   .   # Igrave
    0x00cd   U00cd   .   # Iacute
    0x00ce   U00ce   .   # Icircumflex
    0x00cf   U00cf   .   # Idiaeresis
    0x00d0   U00d0   .   # ETH
    0x00d0   U00d0   .   # Eth	/* deprecated */
    0x00d1   U00d1   .   # Ntilde
    0x00d2   U00d2   .   # Ograve
    0x00d3   U00d3   .   # Oacute
    0x00d4   U00d4   .   # Ocircumflex
    0x00d5   U00d5   .   # Otilde
    0x00d6   U00d6   .   # Odiaeresis
    0x00d7   U00d7   .   # multiply
    0x00d8   U00d8   .   # Ooblique
    0x00d9   U00d9   .   # Ugrave
    0x00da   U00da   .   # Uacute
    0x00db   U00db   .   # Ucircumflex
    0x00dc   U00dc   .   # Udiaeresis
    0x00dd   U00dd   .   # Yacute
    0x00de   U00de   .   # THORN
    0x00de   U00de   .   # Thorn	/* deprecated */
    0x00df   U00df   .   # ssharp
    0x00e0   U00e0   .   # agrave
    0x00e1   U00e1   .   # aacute
    0x00e2   U00e2   .   # acircumflex
    0x00e3   U00e3   .   # atilde
    0x00e4   U00e4   .   # adiaeresis
    0x00e5   U00e5   .   # aring
    0x00e6   U00e6   .   # ae
    0x00e7   U00e7   .   # ccedilla
    0x00e8   U00e8   .   # egrave
    0x00e9   U00e9   .   # eacute
    0x00ea   U00ea   .   # ecircumflex
    0x00eb   U00eb   .   # ediaeresis
    0x00ec   U00ec   .   # igrave
    0x00ed   U00ed   .   # iacute
    0x00ee   U00ee   .   # icircumflex
    0x00ef   U00ef   .   # idiaeresis
    0x00f0   U00f0   .   # eth
    0x00f1   U00f1   .   # ntilde
    0x00f2   U00f2   .   # ograve
    0x00f3   U00f3   .   # oacute
    0x00f4   U00f4   .   # ocircumflex
    0x00f5   U00f5   .   # otilde
    0x00f6   U00f6   .   # odiaeresis
    0x00f7   U00f7   .   # division
    0x00f8   U00f8   .   # oslash
    0x00f9   U00f9   .   # ugrave
    0x00fa   U00fa   .   # uacute
    0x00fb   U00fb   .   # ucircumflex
    0x00fc   U00fc   .   # udiaeresis
    0x00fd   U00fd   .   # yacute
    0x00fe   U00fe   .   # thorn
    0x00ff   U00ff   .   # ydiaeresis
    0x01a1   U0104   .   # Aogonek
    0x01a2   U02d8   .   # breve
    0x01a3   U0141   .   # Lstroke
    0x01a5   U013d   .   # Lcaron
    0x01a6   U015a   .   # Sacute
    0x01a9   U0160   .   # Scaron
    0x01aa   U015e   .   # Scedilla
    0x01ab   U0164   .   # Tcaron
    0x01ac   U0179   .   # Zacute
    0x01ae   U017d   .   # Zcaron
    0x01af   U017b   .   # Zabovedot
    0x01b1   U0105   .   # aogonek
    0x01b2   U02db   .   # ogonek
    0x01b3   U0142   .   # lstroke
    0x01b5   U013e   .   # lcaron
    0x01b6   U015b   .   # sacute
    0x01b7   U02c7   .   # caron
    0x01b9   U0161   .   # scaron
    0x01ba   U015f   .   # scedilla
    0x01bb   U0165   .   # tcaron
    0x01bc   U017a   .   # zacute
    0x01bd   U02dd   .   # doubleacute
    0x01be   U017e   .   # zcaron
    0x01bf   U017c   .   # zabovedot
    0x01c0   U0154   .   # Racute
    0x01c3   U0102   .   # Abreve
    0x01c5   U0139   .   # Lacute
    0x01c6   U0106   .   # Cacute
    0x01c8   U010c   .   # Ccaron
    0x01ca   U0118   .   # Eogonek
    0x01cc   U011a   .   # Ecaron
    0x01cf   U010e   .   # Dcaron
    0x01d0   U0110   .   # Dstroke
    0x01d1   U0143   .   # Nacute
    0x01d2   U0147   .   # Ncaron
    0x01d5   U0150   .   # Odoubleacute
    0x01d8   U0158   .   # Rcaron
    0x01d9   U016e   .   # Uring
    0x01db   U0170   .   # Udoubleacute
    0x01de   U0162   .   # Tcedilla
    0x01e0   U0155   .   # racute
    0x01e3   U0103   .   # abreve
    0x01e5   U013a   .   # lacute
    0x01e6   U0107   .   # cacute
    0x01e8   U010d   .   # ccaron
    0x01ea   U0119   .   # eogonek
    0x01ec   U011b   .   # ecaron
    0x01ef   U010f   .   # dcaron
    0x01f0   U0111   .   # dstroke
    0x01f1   U0144   .   # nacute
    0x01f2   U0148   .   # ncaron
    0x01f5   U0151   .   # odoubleacute
    0x01f8   U0159   .   # rcaron
    0x01f9   U016f   .   # uring
    0x01fb   U0171   .   # udoubleacute
    0x01fe   U0163   .   # tcedilla
    0x01ff   U02d9   .   # abovedot
    0x02a1   U0126   .   # Hstroke
    0x02a6   U0124   .   # Hcircumflex
    0x02a9   U0130   .   # Iabovedot
    0x02ab   U011e   .   # Gbreve
    0x02ac   U0134   .   # Jcircumflex
    0x02b1   U0127   .   # hstroke
    0x02b6   U0125   .   # hcircumflex
    0x02b9   U0131   .   # idotless
    0x02bb   U011f   .   # gbreve
    0x02bc   U0135   .   # jcircumflex
    0x02c5   U010a   .   # Cabovedot
    0x02c6   U0108   .   # Ccircumflex
    0x02d5   U0120   .   # Gabovedot
    0x02d8   U011c   .   # Gcircumflex
    0x02dd   U016c   .   # Ubreve
    0x02de   U015c   .   # Scircumflex
    0x02e5   U010b   .   # cabovedot
    0x02e6   U0109   .   # ccircumflex
    0x02f5   U0121   .   # gabovedot
    0x02f8   U011d   .   # gcircumflex
    0x02fd   U016d   .   # ubreve
    0x02fe   U015d   .   # scircumflex
    0x03a2   U0138   .   # kra
    0x03a3   U0156   .   # Rcedilla
    0x03a5   U0128   .   # Itilde
    0x03a6   U013b   .   # Lcedilla
    0x03aa   U0112   .   # Emacron
    0x03ab   U0122   .   # Gcedilla
    0x03ac   U0166   .   # Tslash
    0x03b3   U0157   .   # rcedilla
    0x03b5   U0129   .   # itilde
    0x03b6   U013c   .   # lcedilla
    0x03ba   U0113   .   # emacron
    0x03bb   U0123   .   # gcedilla
    0x03bc   U0167   .   # tslash
    0x03bd   U014a   .   # ENG
    0x03bf   U014b   .   # eng
    0x03c0   U0100   .   # Amacron
    0x03c7   U012e   .   # Iogonek
    0x03cc   U0116   .   # Eabovedot
    0x03cf   U012a   .   # Imacron
    0x03d1   U0145   .   # Ncedilla
    0x03d2   U014c   .   # Omacron
    0x03d3   U0136   .   # Kcedilla
    0x03d9   U0172   .   # Uogonek
    0x03dd   U0168   .   # Utilde
    0x03de   U016a   .   # Umacron
    0x03e0   U0101   .   # amacron
    0x03e7   U012f   .   # iogonek
    0x03ec   U0117   .   # eabovedot
    0x03ef   U012b   .   # imacron
    0x03f1   U0146   .   # ncedilla
    0x03f2   U014d   .   # omacron
    0x03f3   U0137   .   # kcedilla
    0x03f9   U0173   .   # uogonek
    0x03fd   U0169   .   # utilde
    0x03fe   U016b   .   # umacron
    0x047e   U203e   .   # overline
    0x04a1   U3002   .   # kana_fullstop
    0x04a2   U300c   .   # kana_openingbracket
    0x04a3   U300d   .   # kana_closingbracket
    0x04a4   U3001   .   # kana_comma
    0x04a5   U30fb   .   # kana_conjunctive
    0x04a6   U30f2   .   # kana_WO
    0x04a7   U30a1   .   # kana_a
    0x04a8   U30a3   .   # kana_i
    0x04a9   U30a5   .   # kana_u
    0x04aa   U30a7   .   # kana_e
    0x04ab   U30a9   .   # kana_o
    0x04ac   U30e3   .   # kana_ya
    0x04ad   U30e5   .   # kana_yu
    0x04ae   U30e7   .   # kana_yo
    0x04af   U30c3   .   # kana_tsu
    0x04b0   U30fc   .   # prolongedsound
    0x04b1   U30a2   .   # kana_A
    0x04b2   U30a4   .   # kana_I
    0x04b3   U30a6   .   # kana_U
    0x04b4   U30a8   .   # kana_E
    0x04b5   U30aa   .   # kana_O
    0x04b6   U30ab   .   # kana_KA
    0x04b7   U30ad   .   # kana_KI
    0x04b8   U30af   .   # kana_KU
    0x04b9   U30b1   .   # kana_KE
    0x04ba   U30b3   .   # kana_KO
    0x04bb   U30b5   .   # kana_SA
    0x04bc   U30b7   .   # kana_SHI
    0x04bd   U30b9   .   # kana_SU
    0x04be   U30bb   .   # kana_SE
    0x04bf   U30bd   .   # kana_SO
    0x04c0   U30bf   .   # kana_TA
    0x04c1   U30c1   .   # kana_CHI
    0x04c2   U30c4   .   # kana_TSU
    0x04c3   U30c6   .   # kana_TE
    0x04c4   U30c8   .   # kana_TO
    0x04c5   U30ca   .   # kana_NA
    0x04c6   U30cb   .   # kana_NI
    0x04c7   U30cc   .   # kana_NU
    0x04c8   U30cd   .   # kana_NE
    0x04c9   U30ce   .   # kana_NO
    0x04ca   U30cf   .   # kana_HA
    0x04cb   U30d2   .   # kana_HI
    0x04cc   U30d5   .   # kana_FU
    0x04cd   U30d8   .   # kana_HE
    0x04ce   U30db   .   # kana_HO
    0x04cf   U30de   .   # kana_MA
    0x04d0   U30df   .   # kana_MI
    0x04d1   U30e0   .   # kana_MU
    0x04d2   U30e1   .   # kana_ME
    0x04d3   U30e2   .   # kana_MO
    0x04d4   U30e4   .   # kana_YA
    0x04d5   U30e6   .   # kana_YU
    0x04d6   U30e8   .   # kana_YO
    0x04d7   U30e9   .   # kana_RA
    0x04d8   U30ea   .   # kana_RI
    0x04d9   U30eb   .   # kana_RU
    0x04da   U30ec   .   # kana_RE
    0x04db   U30ed   .   # kana_RO
    0x04dc   U30ef   .   # kana_WA
    0x04dd   U30f3   .   # kana_N
    0x04de   U309b   .   # voicedsound
    0x04df   U309c   .   # semivoicedsound
    0x05ac   U060c   .   # Arabic_comma
    0x05bb   U061b   .   # Arabic_semicolon
    0x05bf   U061f   .   # Arabic_question_mark
    0x05c1   U0621   .   # Arabic_hamza
    0x05c2   U0622   .   # Arabic_maddaonalef
    0x05c3   U0623   .   # Arabic_hamzaonalef
    0x05c4   U0624   .   # Arabic_hamzaonwaw
    0x05c5   U0625   .   # Arabic_hamzaunderalef
    0x05c6   U0626   .   # Arabic_hamzaonyeh
    0x05c7   U0627   .   # Arabic_alef
    0x05c8   U0628   .   # Arabic_beh
    0x05c9   U0629   .   # Arabic_tehmarbuta
    0x05ca   U062a   .   # Arabic_teh
    0x05cb   U062b   .   # Arabic_theh
    0x05cc   U062c   .   # Arabic_jeem
    0x05cd   U062d   .   # Arabic_hah
    0x05ce   U062e   .   # Arabic_khah
    0x05cf   U062f   .   # Arabic_dal
    0x05d0   U0630   .   # Arabic_thal
    0x05d1   U0631   .   # Arabic_ra
    0x05d2   U0632   .   # Arabic_zain
    0x05d3   U0633   .   # Arabic_seen
    0x05d4   U0634   .   # Arabic_sheen
    0x05d5   U0635   .   # Arabic_sad
    0x05d6   U0636   .   # Arabic_dad
    0x05d7   U0637   .   # Arabic_tah
    0x05d8   U0638   .   # Arabic_zah
    0x05d9   U0639   .   # Arabic_ain
    0x05da   U063a   .   # Arabic_ghain
    0x05e0   U0640   .   # Arabic_tatweel
    0x05e1   U0641   .   # Arabic_feh
    0x05e2   U0642   .   # Arabic_qaf
    0x05e3   U0643   .   # Arabic_kaf
    0x05e4   U0644   .   # Arabic_lam
    0x05e5   U0645   .   # Arabic_meem
    0x05e6   U0646   .   # Arabic_noon
    0x05e7   U0647   .   # Arabic_ha
    0x05e8   U0648   .   # Arabic_waw
    0x05e9   U0649   .   # Arabic_alefmaksura
    0x05ea   U064a   .   # Arabic_yeh
    0x05eb   U064b   .   # Arabic_fathatan
    0x05ec   U064c   .   # Arabic_dammatan
    0x05ed   U064d   .   # Arabic_kasratan
    0x05ee   U064e   .   # Arabic_fatha
    0x05ef   U064f   .   # Arabic_damma
    0x05f0   U0650   .   # Arabic_kasra
    0x05f1   U0651   .   # Arabic_shadda
    0x05f2   U0652   .   # Arabic_sukun
    0x06a1   U0452   .   # Serbian_dje
    0x06a2   U0453   .   # Macedonia_gje
    0x06a3   U0451   .   # Cyrillic_io
    0x06a4   U0454   .   # Ukrainian_ie
    0x06a5   U0455   .   # Macedonia_dse
    0x06a6   U0456   .   # Ukrainian_i
    0x06a7   U0457   .   # Ukrainian_yi
    0x06a8   U0458   .   # Cyrillic_je
    0x06a9   U0459   .   # Cyrillic_lje
    0x06aa   U045a   .   # Cyrillic_nje
    0x06ab   U045b   .   # Serbian_tshe
    0x06ac   U045c   .   # Macedonia_kje
    0x06ae   U045e   .   # Byelorussian_shortu
    0x06af   U045f   .   # Cyrillic_dzhe
    0x06b0   U2116   .   # numerosign
    0x06b1   U0402   .   # Serbian_DJE
    0x06b2   U0403   .   # Macedonia_GJE
    0x06b3   U0401   .   # Cyrillic_IO
    0x06b4   U0404   .   # Ukrainian_IE
    0x06b5   U0405   .   # Macedonia_DSE
    0x06b6   U0406   .   # Ukrainian_I
    0x06b7   U0407   .   # Ukrainian_YI
    0x06b8   U0408   .   # Cyrillic_JE
    0x06b9   U0409   .   # Cyrillic_LJE
    0x06ba   U040a   .   # Cyrillic_NJE
    0x06bb   U040b   .   # Serbian_TSHE
    0x06bc   U040c   .   # Macedonia_KJE
    0x06be   U040e   .   # Byelorussian_SHORTU
    0x06bf   U040f   .   # Cyrillic_DZHE
    0x06c0   U044e   .   # Cyrillic_yu
    0x06c1   U0430   .   # Cyrillic_a
    0x06c2   U0431   .   # Cyrillic_be
    0x06c3   U0446   .   # Cyrillic_tse
    0x06c4   U0434   .   # Cyrillic_de
    0x06c5   U0435   .   # Cyrillic_ie
    0x06c6   U0444   .   # Cyrillic_ef
    0x06c7   U0433   .   # Cyrillic_ghe
    0x06c8   U0445   .   # Cyrillic_ha
    0x06c9   U0438   .   # Cyrillic_i
    0x06ca   U0439   .   # Cyrillic_shorti
    0x06cb   U043a   .   # Cyrillic_ka
    0x06cc   U043b   .   # Cyrillic_el
    0x06cd   U043c   .   # Cyrillic_em
    0x06ce   U043d   .   # Cyrillic_en
    0x06cf   U043e   .   # Cyrillic_o
    0x06d0   U043f   .   # Cyrillic_pe
    0x06d1   U044f   .   # Cyrillic_ya
    0x06d2   U0440   .   # Cyrillic_er
    0x06d3   U0441   .   # Cyrillic_es
    0x06d4   U0442   .   # Cyrillic_te
    0x06d5   U0443   .   # Cyrillic_u
    0x06d6   U0436   .   # Cyrillic_zhe
    0x06d7   U0432   .   # Cyrillic_ve
    0x06d8   U044c   .   # Cyrillic_softsign
    0x06d9   U044b   .   # Cyrillic_yeru
    0x06da   U0437   .   # Cyrillic_ze
    0x06db   U0448   .   # Cyrillic_sha
    0x06dc   U044d   .   # Cyrillic_e
    0x06dd   U0449   .   # Cyrillic_shcha
    0x06de   U0447   .   # Cyrillic_che
    0x06df   U044a   .   # Cyrillic_hardsign
    0x06e0   U042e   .   # Cyrillic_YU
    0x06e1   U0410   .   # Cyrillic_A
    0x06e2   U0411   .   # Cyrillic_BE
    0x06e3   U0426   .   # Cyrillic_TSE
    0x06e4   U0414   .   # Cyrillic_DE
    0x06e5   U0415   .   # Cyrillic_IE
    0x06e6   U0424   .   # Cyrillic_EF
    0x06e7   U0413   .   # Cyrillic_GHE
    0x06e8   U0425   .   # Cyrillic_HA
    0x06e9   U0418   .   # Cyrillic_I
    0x06ea   U0419   .   # Cyrillic_SHORTI
    0x06eb   U041a   .   # Cyrillic_KA
    0x06ec   U041b   .   # Cyrillic_EL
    0x06ed   U041c   .   # Cyrillic_EM
    0x06ee   U041d   .   # Cyrillic_EN
    0x06ef   U041e   .   # Cyrillic_O
    0x06f0   U041f   .   # Cyrillic_PE
    0x06f1   U042f   .   # Cyrillic_YA
    0x06f2   U0420   .   # Cyrillic_ER
    0x06f3   U0421   .   # Cyrillic_ES
    0x06f4   U0422   .   # Cyrillic_TE
    0x06f5   U0423   .   # Cyrillic_U
    0x06f6   U0416   .   # Cyrillic_ZHE
    0x06f7   U0412   .   # Cyrillic_VE
    0x06f8   U042c   .   # Cyrillic_SOFTSIGN
    0x06f9   U042b   .   # Cyrillic_YERU
    0x06fa   U0417   .   # Cyrillic_ZE
    0x06fb   U0428   .   # Cyrillic_SHA
    0x06fc   U042d   .   # Cyrillic_E
    0x06fd   U0429   .   # Cyrillic_SHCHA
    0x06fe   U0427   .   # Cyrillic_CHE
    0x06ff   U042a   .   # Cyrillic_HARDSIGN
    0x07a1   U0386   .   # Greek_ALPHAaccent
    0x07a2   U0388   .   # Greek_EPSILONaccent
    0x07a3   U0389   .   # Greek_ETAaccent
    0x07a4   U038a   .   # Greek_IOTAaccent
    0x07a5   U03aa   .   # Greek_IOTAdiaeresis
    0x07a7   U038c   .   # Greek_OMICRONaccent
    0x07a8   U038e   .   # Greek_UPSILONaccent
    0x07a9   U03ab   .   # Greek_UPSILONdieresis
    0x07ab   U038f   .   # Greek_OMEGAaccent
    0x07ae   U0385   .   # Greek_accentdieresis
    0x07af   U2015   .   # Greek_horizbar
    0x07b1   U03ac   .   # Greek_alphaaccent
    0x07b2   U03ad   .   # Greek_epsilonaccent
    0x07b3   U03ae   .   # Greek_etaaccent
    0x07b4   U03af   .   # Greek_iotaaccent
    0x07b5   U03ca   .   # Greek_iotadieresis
    0x07b6   U0390   .   # Greek_iotaaccentdieresis
    0x07b7   U03cc   .   # Greek_omicronaccent
    0x07b8   U03cd   .   # Greek_upsilonaccent
    0x07b9   U03cb   .   # Greek_upsilondieresis
    0x07ba   U03b0   .   # Greek_upsilonaccentdieresis
    0x07bb   U03ce   .   # Greek_omegaaccent
    0x07c1   U0391   .   # Greek_ALPHA
    0x07c2   U0392   .   # Greek_BETA
    0x07c3   U0393   .   # Greek_GAMMA
    0x07c4   U0394   .   # Greek_DELTA
    0x07c5   U0395   .   # Greek_EPSILON
    0x07c6   U0396   .   # Greek_ZETA
    0x07c7   U0397   .   # Greek_ETA
    0x07c8   U0398   .   # Greek_THETA
    0x07c9   U0399   .   # Greek_IOTA
    0x07ca   U039a   .   # Greek_KAPPA
    0x07cb   U039b   .   # Greek_LAMBDA
    0x07cb   U039b   .   # Greek_LAMDA
    0x07cc   U039c   .   # Greek_MU
    0x07cd   U039d   .   # Greek_NU
    0x07ce   U039e   .   # Greek_XI
    0x07cf   U039f   .   # Greek_OMICRON
    0x07d0   U03a0   .   # Greek_PI
    0x07d1   U03a1   .   # Greek_RHO
    0x07d2   U03a3   .   # Greek_SIGMA
    0x07d4   U03a4   .   # Greek_TAU
    0x07d5   U03a5   .   # Greek_UPSILON
    0x07d6   U03a6   .   # Greek_PHI
    0x07d7   U03a7   .   # Greek_CHI
    0x07d8   U03a8   .   # Greek_PSI
    0x07d9   U03a9   .   # Greek_OMEGA
    0x07e1   U03b1   .   # Greek_alpha
    0x07e2   U03b2   .   # Greek_beta
    0x07e3   U03b3   .   # Greek_gamma
    0x07e4   U03b4   .   # Greek_delta
    0x07e5   U03b5   .   # Greek_epsilon
    0x07e6   U03b6   .   # Greek_zeta
    0x07e7   U03b7   .   # Greek_eta
    0x07e8   U03b8   .   # Greek_theta
    0x07e9   U03b9   .   # Greek_iota
    0x07ea   U03ba   .   # Greek_kappa
    0x07eb   U03bb   .   # Greek_lambda
    0x07ec   U03bc   .   # Greek_mu
    0x07ed   U03bd   .   # Greek_nu
    0x07ee   U03be   .   # Greek_xi
    0x07ef   U03bf   .   # Greek_omicron
    0x07f0   U03c0   .   # Greek_pi
    0x07f1   U03c1   .   # Greek_rho
    0x07f2   U03c3   .   # Greek_sigma
    0x07f3   U03c2   .   # Greek_finalsmallsigma
    0x07f4   U03c4   .   # Greek_tau
    0x07f5   U03c5   .   # Greek_upsilon
    0x07f6   U03c6   .   # Greek_phi
    0x07f7   U03c7   .   # Greek_chi
    0x07f8   U03c8   .   # Greek_psi
    0x07f9   U03c9   .   # Greek_omega
    0x08a1   U23b7   .   # leftradical
    0x08a2   U250c   d   # topleftradical
    0x08a3   U2500   d   # horizconnector
    0x08a4   U2320   .   # topintegral
    0x08a5   U2321   .   # botintegral
    0x08a6   U2502   d   # vertconnector
    0x08a7   U23a1   .   # topleftsqbracket
    0x08a8   U23a3   .   # botleftsqbracket
    0x08a9   U23a4   .   # toprightsqbracket
    0x08aa   U23a6   .   # botrightsqbracket
    0x08ab   U239b   .   # topleftparens
    0x08ac   U239d   .   # botleftparens
    0x08ad   U239e   .   # toprightparens
    0x08ae   U23a0   .   # botrightparens
    0x08af   U23a8   .   # leftmiddlecurlybrace
    0x08b0   U23ac   .   # rightmiddlecurlybrace
    0x08b1   U0000   o   # topleftsummation
    0x08b2   U0000   o   # botleftsummation
    0x08b3   U0000   o   # topvertsummationconnector
    0x08b4   U0000   o   # botvertsummationconnector
    0x08b5   U0000   o   # toprightsummation
    0x08b6   U0000   o   # botrightsummation
    0x08b7   U0000   o   # rightmiddlesummation
    0x08bc   U2264   .   # lessthanequal
    0x08bd   U2260   .   # notequal
    0x08be   U2265   .   # greaterthanequal
    0x08bf   U222b   .   # integral
    0x08c0   U2234   .   # therefore
    0x08c1   U221d   .   # variation
    0x08c2   U221e   .   # infinity
    0x08c5   U2207   .   # nabla
    0x08c8   U223c   .   # approximate
    0x08c9   U2243   .   # similarequal
    0x08cd   U21d4   .   # ifonlyif
    0x08ce   U21d2   .   # implies
    0x08cf   U2261   .   # identical
    0x08d6   U221a   .   # radical
    0x08da   U2282   .   # includedin
    0x08db   U2283   .   # includes
    0x08dc   U2229   .   # intersection
    0x08dd   U222a   .   # union
    0x08de   U2227   .   # logicaland
    0x08df   U2228   .   # logicalor
    0x08ef   U2202   .   # partialderivative
    0x08f6   U0192   .   # function
    0x08fb   U2190   .   # leftarrow
    0x08fc   U2191   .   # uparrow
    0x08fd   U2192   .   # rightarrow
    0x08fe   U2193   .   # downarrow
    0x09df   U0000   o   # blank
    0x09e0   U25c6   .   # soliddiamond
    0x09e1   U2592   .   # checkerboard
    0x09e2   U2409   .   # ht
    0x09e3   U240c   .   # ff
    0x09e4   U240d   .   # cr
    0x09e5   U240a   .   # lf
    0x09e8   U2424   .   # nl
    0x09e9   U240b   .   # vt
    0x09ea   U2518   .   # lowrightcorner
    0x09eb   U2510   .   # uprightcorner
    0x09ec   U250c   .   # upleftcorner
    0x09ed   U2514   .   # lowleftcorner
    0x09ee   U253c   .   # crossinglines
    0x09ef   U23ba   .   # horizlinescan1
    0x09f0   U23bb   .   # horizlinescan3
    0x09f1   U2500   .   # horizlinescan5
    0x09f2   U23bc   .   # horizlinescan7
    0x09f3   U23bd   .   # horizlinescan9
    0x09f4   U251c   .   # leftt
    0x09f5   U2524   .   # rightt
    0x09f6   U2534   .   # bott
    0x09f7   U252c   .   # topt
    0x09f8   U2502   .   # vertbar
    0x0aa1   U2003   .   # emspace
    0x0aa2   U2002   .   # enspace
    0x0aa3   U2004   .   # em3space
    0x0aa4   U2005   .   # em4space
    0x0aa5   U2007   .   # digitspace
    0x0aa6   U2008   .   # punctspace
    0x0aa7   U2009   .   # thinspace
    0x0aa8   U200a   .   # hairspace
    0x0aa9   U2014   .   # emdash
    0x0aaa   U2013   .   # endash
    0x0aac   U2423   o   # signifblank
    0x0aae   U2026   .   # ellipsis
    0x0aaf   U2025   .   # doubbaselinedot
    0x0ab0   U2153   .   # onethird
    0x0ab1   U2154   .   # twothirds
    0x0ab2   U2155   .   # onefifth
    0x0ab3   U2156   .   # twofifths
    0x0ab4   U2157   .   # threefifths
    0x0ab5   U2158   .   # fourfifths
    0x0ab6   U2159   .   # onesixth
    0x0ab7   U215a   .   # fivesixths
    0x0ab8   U2105   .   # careof
    0x0abb   U2012   .   # figdash
    0x0abc   U27e8   o   # leftanglebracket
    0x0abd   U002e   o   # decimalpoint
    0x0abe   U27e9   o   # rightanglebracket
    0x0abf   U0000   o   # marker
    0x0ac3   U215b   .   # oneeighth
    0x0ac4   U215c   .   # threeeighths
    0x0ac5   U215d   .   # fiveeighths
    0x0ac6   U215e   .   # seveneighths
    0x0ac9   U2122   .   # trademark
    0x0aca   U2613   o   # signaturemark
    0x0acb   U0000   o   # trademarkincircle
    0x0acc   U25c1   o   # leftopentriangle
    0x0acd   U25b7   o   # rightopentriangle
    0x0ace   U25cb   o   # emopencircle
    0x0acf   U25af   o   # emopenrectangle
    0x0ad0   U2018   .   # leftsinglequotemark
    0x0ad1   U2019   .   # rightsinglequotemark
    0x0ad2   U201c   .   # leftdoublequotemark
    0x0ad3   U201d   .   # rightdoublequotemark
    0x0ad4   U211e   .   # prescription
    0x0ad6   U2032   .   # minutes
    0x0ad7   U2033   .   # seconds
    0x0ad9   U271d   .   # latincross
    0x0ada   U0000   o   # hexagram
    0x0adb   U25ac   o   # filledrectbullet
    0x0adc   U25c0   o   # filledlefttribullet
    0x0add   U25b6   o   # filledrighttribullet
    0x0ade   U25cf   o   # emfilledcircle
    0x0adf   U25ae   o   # emfilledrect
    0x0ae0   U25e6   o   # enopencircbullet
    0x0ae1   U25ab   o   # enopensquarebullet
    0x0ae2   U25ad   o   # openrectbullet
    0x0ae3   U25b3   o   # opentribulletup
    0x0ae4   U25bd   o   # opentribulletdown
    0x0ae5   U2606   o   # openstar
    0x0ae6   U2022   o   # enfilledcircbullet
    0x0ae7   U25aa   o   # enfilledsqbullet
    0x0ae8   U25b2   o   # filledtribulletup
    0x0ae9   U25bc   o   # filledtribulletdown
    0x0aea   U261c   o   # leftpointer
    0x0aeb   U261e   o   # rightpointer
    0x0aec   U2663   .   # club
    0x0aed   U2666   .   # diamond
    0x0aee   U2665   .   # heart
    0x0af0   U2720   .   # maltesecross
    0x0af1   U2020   .   # dagger
    0x0af2   U2021   .   # doubledagger
    0x0af3   U2713   .   # checkmark
    0x0af4   U2717   .   # ballotcross
    0x0af5   U266f   .   # musicalsharp
    0x0af6   U266d   .   # musicalflat
    0x0af7   U2642   .   # malesymbol
    0x0af8   U2640   .   # femalesymbol
    0x0af9   U260e   .   # telephone
    0x0afa   U2315   .   # telephonerecorder
    0x0afb   U2117   .   # phonographcopyright
    0x0afc   U2038   .   # caret
    0x0afd   U201a   .   # singlelowquotemark
    0x0afe   U201e   .   # doublelowquotemark
    0x0aff   U0000   o   # cursor
    0x0ba3   U003c   d   # leftcaret
    0x0ba6   U003e   d   # rightcaret
    0x0ba8   U2228   d   # downcaret
    0x0ba9   U2227   d   # upcaret
    0x0bc0   U00af   d   # overbar
    0x0bc2   U22a5   .   # downtack
    0x0bc3   U2229   d   # upshoe
    0x0bc4   U230a   .   # downstile
    0x0bc6   U005f   d   # underbar
    0x0bca   U2218   .   # jot
    0x0bcc   U2395   .   # quad
    0x0bce   U22a4   .   # uptack
    0x0bcf   U25cb   .   # circle
    0x0bd3   U2308   .   # upstile
    0x0bd6   U222a   d   # downshoe
    0x0bd8   U2283   d   # rightshoe
    0x0bda   U2282   d   # leftshoe
    0x0bdc   U22a2   .   # lefttack
    0x0bfc   U22a3   .   # righttack
    0x0cdf   U2017   .   # hebrew_doublelowline
    0x0ce0   U05d0   .   # hebrew_aleph
    0x0ce1   U05d1   .   # hebrew_bet
    0x0ce1   U05d1   .   # hebrew_beth  /* deprecated */
    0x0ce2   U05d2   .   # hebrew_gimel
    0x0ce2   U05d2   .   # hebrew_gimmel  /* deprecated */
    0x0ce3   U05d3   .   # hebrew_dalet
    0x0ce3   U05d3   .   # hebrew_daleth  /* deprecated */
    0x0ce4   U05d4   .   # hebrew_he
    0x0ce5   U05d5   .   # hebrew_waw
    0x0ce6   U05d6   .   # hebrew_zain
    0x0ce6   U05d6   .   # hebrew_zayin  /* deprecated */
    0x0ce7   U05d7   .   # hebrew_chet
    0x0ce7   U05d7   .   # hebrew_het  /* deprecated */
    0x0ce8   U05d8   .   # hebrew_tet
    0x0ce8   U05d8   .   # hebrew_teth  /* deprecated */
    0x0ce9   U05d9   .   # hebrew_yod
    0x0cea   U05da   .   # hebrew_finalkaph
    0x0ceb   U05db   .   # hebrew_kaph
    0x0cec   U05dc   .   # hebrew_lamed
    0x0ced   U05dd   .   # hebrew_finalmem
    0x0cee   U05de   .   # hebrew_mem
    0x0cef   U05df   .   # hebrew_finalnun
    0x0cf0   U05e0   .   # hebrew_nun
    0x0cf1   U05e1   .   # hebrew_samech
    0x0cf1   U05e1   .   # hebrew_samekh  /* deprecated */
    0x0cf2   U05e2   .   # hebrew_ayin
    0x0cf3   U05e3   .   # hebrew_finalpe
    0x0cf4   U05e4   .   # hebrew_pe
    0x0cf5   U05e5   .   # hebrew_finalzade
    0x0cf5   U05e5   .   # hebrew_finalzadi  /* deprecated */
    0x0cf6   U05e6   .   # hebrew_zade
    0x0cf6   U05e6   .   # hebrew_zadi  /* deprecated */
    0x0cf7   U05e7   .   # hebrew_kuf  /* deprecated */
    0x0cf7   U05e7   .   # hebrew_qoph
    0x0cf8   U05e8   .   # hebrew_resh
    0x0cf9   U05e9   .   # hebrew_shin
    0x0cfa   U05ea   .   # hebrew_taf  /* deprecated */
    0x0cfa   U05ea   .   # hebrew_taw
    0x0da1   U0e01   .   # Thai_kokai
    0x0da2   U0e02   .   # Thai_khokhai
    0x0da3   U0e03   .   # Thai_khokhuat
    0x0da4   U0e04   .   # Thai_khokhwai
    0x0da5   U0e05   .   # Thai_khokhon
    0x0da6   U0e06   .   # Thai_khorakhang
    0x0da7   U0e07   .   # Thai_ngongu
    0x0da8   U0e08   .   # Thai_chochan
    0x0da9   U0e09   .   # Thai_choching
    0x0daa   U0e0a   .   # Thai_chochang
    0x0dab   U0e0b   .   # Thai_soso
    0x0dac   U0e0c   .   # Thai_chochoe
    0x0dad   U0e0d   .   # Thai_yoying
    0x0dae   U0e0e   .   # Thai_dochada
    0x0daf   U0e0f   .   # Thai_topatak
    0x0db0   U0e10   .   # Thai_thothan
    0x0db1   U0e11   .   # Thai_thonangmontho
    0x0db2   U0e12   .   # Thai_thophuthao
    0x0db3   U0e13   .   # Thai_nonen
    0x0db4   U0e14   .   # Thai_dodek
    0x0db5   U0e15   .   # Thai_totao
    0x0db6   U0e16   .   # Thai_thothung
    0x0db7   U0e17   .   # Thai_thothahan
    0x0db8   U0e18   .   # Thai_thothong
    0x0db9   U0e19   .   # Thai_nonu
    0x0dba   U0e1a   .   # Thai_bobaimai
    0x0dbb   U0e1b   .   # Thai_popla
    0x0dbc   U0e1c   .   # Thai_phophung
    0x0dbd   U0e1d   .   # Thai_fofa
    0x0dbe   U0e1e   .   # Thai_phophan
    0x0dbf   U0e1f   .   # Thai_fofan
    0x0dc0   U0e20   .   # Thai_phosamphao
    0x0dc1   U0e21   .   # Thai_moma
    0x0dc2   U0e22   .   # Thai_yoyak
    0x0dc3   U0e23   .   # Thai_rorua
    0x0dc4   U0e24   .   # Thai_ru
    0x0dc5   U0e25   .   # Thai_loling
    0x0dc6   U0e26   .   # Thai_lu
    0x0dc7   U0e27   .   # Thai_wowaen
    0x0dc8   U0e28   .   # Thai_sosala
    0x0dc9   U0e29   .   # Thai_sorusi
    0x0dca   U0e2a   .   # Thai_sosua
    0x0dcb   U0e2b   .   # Thai_hohip
    0x0dcc   U0e2c   .   # Thai_lochula
    0x0dcd   U0e2d   .   # Thai_oang
    0x0dce   U0e2e   .   # Thai_honokhuk
    0x0dcf   U0e2f   .   # Thai_paiyannoi
    0x0dd0   U0e30   .   # Thai_saraa
    0x0dd1   U0e31   .   # Thai_maihanakat
    0x0dd2   U0e32   .   # Thai_saraaa
    0x0dd3   U0e33   .   # Thai_saraam
    0x0dd4   U0e34   .   # Thai_sarai
    0x0dd5   U0e35   .   # Thai_saraii
    0x0dd6   U0e36   .   # Thai_saraue
    0x0dd7   U0e37   .   # Thai_sarauee
    0x0dd8   U0e38   .   # Thai_sarau
    0x0dd9   U0e39   .   # Thai_sarauu
    0x0dda   U0e3a   .   # Thai_phinthu
    0x0dde   U0000   o   # Thai_maihanakat_maitho
    0x0ddf   U0e3f   .   # Thai_baht
    0x0de0   U0e40   .   # Thai_sarae
    0x0de1   U0e41   .   # Thai_saraae
    0x0de2   U0e42   .   # Thai_sarao
    0x0de3   U0e43   .   # Thai_saraaimaimuan
    0x0de4   U0e44   .   # Thai_saraaimaimalai
    0x0de5   U0e45   .   # Thai_lakkhangyao
    0x0de6   U0e46   .   # Thai_maiyamok
    0x0de7   U0e47   .   # Thai_maitaikhu
    0x0de8   U0e48   .   # Thai_maiek
    0x0de9   U0e49   .   # Thai_maitho
    0x0dea   U0e4a   .   # Thai_maitri
    0x0deb   U0e4b   .   # Thai_maichattawa
    0x0dec   U0e4c   .   # Thai_thanthakhat
    0x0ded   U0e4d   .   # Thai_nikhahit
    0x0df0   U0e50   .   # Thai_leksun
    0x0df1   U0e51   .   # Thai_leknung
    0x0df2   U0e52   .   # Thai_leksong
    0x0df3   U0e53   .   # Thai_leksam
    0x0df4   U0e54   .   # Thai_leksi
    0x0df5   U0e55   .   # Thai_lekha
    0x0df6   U0e56   .   # Thai_lekhok
    0x0df7   U0e57   .   # Thai_lekchet
    0x0df8   U0e58   .   # Thai_lekpaet
    0x0df9   U0e59   .   # Thai_lekkao
    0x0ea1   U3131   f   # Hangul_Kiyeog
    0x0ea2   U3132   f   # Hangul_SsangKiyeog
    0x0ea3   U3133   f   # Hangul_KiyeogSios
    0x0ea4   U3134   f   # Hangul_Nieun
    0x0ea5   U3135   f   # Hangul_NieunJieuj
    0x0ea6   U3136   f   # Hangul_NieunHieuh
    0x0ea7   U3137   f   # Hangul_Dikeud
    0x0ea8   U3138   f   # Hangul_SsangDikeud
    0x0ea9   U3139   f   # Hangul_Rieul
    0x0eaa   U313a   f   # Hangul_RieulKiyeog
    0x0eab   U313b   f   # Hangul_RieulMieum
    0x0eac   U313c   f   # Hangul_RieulPieub
    0x0ead   U313d   f   # Hangul_RieulSios
    0x0eae   U313e   f   # Hangul_RieulTieut
    0x0eaf   U313f   f   # Hangul_RieulPhieuf
    0x0eb0   U3140   f   # Hangul_RieulHieuh
    0x0eb1   U3141   f   # Hangul_Mieum
    0x0eb2   U3142   f   # Hangul_Pieub
    0x0eb3   U3143   f   # Hangul_SsangPieub
    0x0eb4   U3144   f   # Hangul_PieubSios
    0x0eb5   U3145   f   # Hangul_Sios
    0x0eb6   U3146   f   # Hangul_SsangSios
    0x0eb7   U3147   f   # Hangul_Ieung
    0x0eb8   U3148   f   # Hangul_Jieuj
    0x0eb9   U3149   f   # Hangul_SsangJieuj
    0x0eba   U314a   f   # Hangul_Cieuc
    0x0ebb   U314b   f   # Hangul_Khieuq
    0x0ebc   U314c   f   # Hangul_Tieut
    0x0ebd   U314d   f   # Hangul_Phieuf
    0x0ebe   U314e   f   # Hangul_Hieuh
    0x0ebf   U314f   f   # Hangul_A
    0x0ec0   U3150   f   # Hangul_AE
    0x0ec1   U3151   f   # Hangul_YA
    0x0ec2   U3152   f   # Hangul_YAE
    0x0ec3   U3153   f   # Hangul_EO
    0x0ec4   U3154   f   # Hangul_E
    0x0ec5   U3155   f   # Hangul_YEO
    0x0ec6   U3156   f   # Hangul_YE
    0x0ec7   U3157   f   # Hangul_O
    0x0ec8   U3158   f   # Hangul_WA
    0x0ec9   U3159   f   # Hangul_WAE
    0x0eca   U315a   f   # Hangul_OE
    0x0ecb   U315b   f   # Hangul_YO
    0x0ecc   U315c   f   # Hangul_U
    0x0ecd   U315d   f   # Hangul_WEO
    0x0ece   U315e   f   # Hangul_WE
    0x0ecf   U315f   f   # Hangul_WI
    0x0ed0   U3160   f   # Hangul_YU
    0x0ed1   U3161   f   # Hangul_EU
    0x0ed2   U3162   f   # Hangul_YI
    0x0ed3   U3163   f   # Hangul_I
    0x0ed4   U11a8   f   # Hangul_J_Kiyeog
    0x0ed5   U11a9   f   # Hangul_J_SsangKiyeog
    0x0ed6   U11aa   f   # Hangul_J_KiyeogSios
    0x0ed7   U11ab   f   # Hangul_J_Nieun
    0x0ed8   U11ac   f   # Hangul_J_NieunJieuj
    0x0ed9   U11ad   f   # Hangul_J_NieunHieuh
    0x0eda   U11ae   f   # Hangul_J_Dikeud
    0x0edb   U11af   f   # Hangul_J_Rieul
    0x0edc   U11b0   f   # Hangul_J_RieulKiyeog
    0x0edd   U11b1   f   # Hangul_J_RieulMieum
    0x0ede   U11b2   f   # Hangul_J_RieulPieub
    0x0edf   U11b3   f   # Hangul_J_RieulSios
    0x0ee0   U11b4   f   # Hangul_J_RieulTieut
    0x0ee1   U11b5   f   # Hangul_J_RieulPhieuf
    0x0ee2   U11b6   f   # Hangul_J_RieulHieuh
    0x0ee3   U11b7   f   # Hangul_J_Mieum
    0x0ee4   U11b8   f   # Hangul_J_Pieub
    0x0ee5   U11b9   f   # Hangul_J_PieubSios
    0x0ee6   U11ba   f   # Hangul_J_Sios
    0x0ee7   U11bb   f   # Hangul_J_SsangSios
    0x0ee8   U11bc   f   # Hangul_J_Ieung
    0x0ee9   U11bd   f   # Hangul_J_Jieuj
    0x0eea   U11be   f   # Hangul_J_Cieuc
    0x0eeb   U11bf   f   # Hangul_J_Khieuq
    0x0eec   U11c0   f   # Hangul_J_Tieut
    0x0eed   U11c1   f   # Hangul_J_Phieuf
    0x0eee   U11c2   f   # Hangul_J_Hieuh
    0x0eef   U316d   f   # Hangul_RieulYeorinHieuh
    0x0ef0   U3171   f   # Hangul_SunkyeongeumMieum
    0x0ef1   U3178   f   # Hangul_SunkyeongeumPieub
    0x0ef2   U317f   f   # Hangul_PanSios
    0x0ef3   U3181   f   # Hangul_KkogjiDalrinIeung
    0x0ef4   U3184   f   # Hangul_SunkyeongeumPhieuf
    0x0ef5   U3186   f   # Hangul_YeorinHieuh
    0x0ef6   U318d   f   # Hangul_AraeA
    0x0ef7   U318e   f   # Hangul_AraeAE
    0x0ef8   U11eb   f   # Hangul_J_PanSios
    0x0ef9   U11f0   f   # Hangul_J_KkogjiDalrinIeung
    0x0efa   U11f9   f   # Hangul_J_YeorinHieuh
    0x0eff   U20a9   o   # Korean_Won
    0x13bc   U0152   .   # OE
    0x13bd   U0153   .   # oe
    0x13be   U0178   .   # Ydiaeresis
    0x20a0   U20a0   u   # EcuSign
    0x20a1   U20a1   u   # ColonSign
    0x20a2   U20a2   u   # CruzeiroSign
    0x20a3   U20a3   u   # FFrancSign
    0x20a4   U20a4   u   # LiraSign
    0x20a5   U20a5   u   # MillSign
    0x20a6   U20a6   u   # NairaSign
    0x20a7   U20a7   u   # PesetaSign
    0x20a8   U20a8   u   # RupeeSign
    0x20a9   U20a9   u   # WonSign
    0x20aa   U20aa   u   # NewSheqelSign
    0x20ab   U20ab   u   # DongSign
    0x20ac   U20ac   .   # EuroSign
    0xfd01   U0000   f   # 3270_Duplicate
    0xfd02   U0000   f   # 3270_FieldMark
    0xfd03   U0000   f   # 3270_Right2
    0xfd04   U0000   f   # 3270_Left2
    0xfd05   U0000   f   # 3270_BackTab
    0xfd06   U0000   f   # 3270_EraseEOF
    0xfd07   U0000   f   # 3270_EraseInput
    0xfd08   U0000   f   # 3270_Reset
    0xfd09   U0000   f   # 3270_Quit
    0xfd0a   U0000   f   # 3270_PA1
    0xfd0b   U0000   f   # 3270_PA2
    0xfd0c   U0000   f   # 3270_PA3
    0xfd0d   U0000   f   # 3270_Test
    0xfd0e   U0000   f   # 3270_Attn
    0xfd0f   U0000   f   # 3270_CursorBlink
    0xfd10   U0000   f   # 3270_AltCursor
    0xfd11   U0000   f   # 3270_KeyClick
    0xfd12   U0000   f   # 3270_Jump
    0xfd13   U0000   f   # 3270_Ident
    0xfd14   U0000   f   # 3270_Rule
    0xfd15   U0000   f   # 3270_Copy
    0xfd16   U0000   f   # 3270_Play
    0xfd17   U0000   f   # 3270_Setup
    0xfd18   U0000   f   # 3270_Record
    0xfd19   U0000   f   # 3270_ChangeScreen
    0xfd1a   U0000   f   # 3270_DeleteWord
    0xfd1b   U0000   f   # 3270_ExSelect
    0xfd1c   U0000   f   # 3270_CursorSelect
    0xfd1d   U0000   f   # 3270_PrintScreen
    0xfd1e   U0000   f   # 3270_Enter
    0xfe01   U0000   f   # ISO_Lock
    0xfe02   U0000   f   # ISO_Level2_Latch}
    $FE03: Result := VK_BS_RMENU; // ISO_Level3_Shift
    {0xfe04   U0000   f   # ISO_Level3_Latch
    0xfe05   U0000   f   # ISO_Level3_Lock
    0xfe06   U0000   f   # ISO_Group_Latch
    0xfe07   U0000   f   # ISO_Group_Lock
    0xfe08   U0000   f   # ISO_Next_Group
    0xfe09   U0000   f   # ISO_Next_Group_Lock
    0xfe0a   U0000   f   # ISO_Prev_Group
    0xfe0b   U0000   f   # ISO_Prev_Group_Lock
    0xfe0c   U0000   f   # ISO_First_Group
    0xfe0d   U0000   f   # ISO_First_Group_Lock
    0xfe0e   U0000   f   # ISO_Last_Group
    0xfe0f   U0000   f   # ISO_Last_Group_Lock
    0xfe20   U0000   f   # ISO_Left_Tab
    0xfe21   U0000   f   # ISO_Move_Line_Up
    0xfe22   U0000   f   # ISO_Move_Line_Down
    0xfe23   U0000   f   # ISO_Partial_Line_Up
    0xfe24   U0000   f   # ISO_Partial_Line_Down
    0xfe25   U0000   f   # ISO_Partial_Space_Left
    0xfe26   U0000   f   # ISO_Partial_Space_Right
    0xfe27   U0000   f   # ISO_Set_Margin_Left
    0xfe28   U0000   f   # ISO_Set_Margin_Right
    0xfe29   U0000   f   # ISO_Release_Margin_Left
    0xfe2a   U0000   f   # ISO_Release_Margin_Right
    0xfe2b   U0000   f   # ISO_Release_Both_Margins
    0xfe2c   U0000   f   # ISO_Fast_Cursor_Left
    0xfe2d   U0000   f   # ISO_Fast_Cursor_Right
    0xfe2e   U0000   f   # ISO_Fast_Cursor_Up
    0xfe2f   U0000   f   # ISO_Fast_Cursor_Down
    0xfe30   U0000   f   # ISO_Continuous_Underline
    0xfe31   U0000   f   # ISO_Discontinuous_Underline
    0xfe32   U0000   f   # ISO_Emphasize
    0xfe33   U0000   f   # ISO_Center_Object
    0xfe34   U0000   f   # ISO_Enter
    0xfe50   U0300   f   # dead_grave
    0xfe51   U0301   f   # dead_acute
    0xfe52   U0302   f   # dead_circumflex
    0xfe53   U0303   f   # dead_tilde
    0xfe54   U0304   f   # dead_macron
    0xfe55   U0306   f   # dead_breve
    0xfe56   U0307   f   # dead_abovedot
    0xfe57   U0308   f   # dead_diaeresis
    0xfe58   U030a   f   # dead_abovering
    0xfe59   U030b   f   # dead_doubleacute
    0xfe5a   U030c   f   # dead_caron
    0xfe5b   U0327   f   # dead_cedilla
    0xfe5c   U0328   f   # dead_ogonek
    0xfe5d   U0345   f   # dead_iota
    0xfe5e   U3099   f   # dead_voiced_sound
    0xfe5f   U309a   f   # dead_semivoiced_sound
    0xfe70   U0000   f   # AccessX_Enable
    0xfe71   U0000   f   # AccessX_Feedback_Enable
    0xfe72   U0000   f   # RepeatKeys_Enable
    0xfe73   U0000   f   # SlowKeys_Enable
    0xfe74   U0000   f   # BounceKeys_Enable
    0xfe75   U0000   f   # StickyKeys_Enable
    0xfe76   U0000   f   # MouseKeys_Enable
    0xfe77   U0000   f   # MouseKeys_Accel_Enable
    0xfe78   U0000   f   # Overlay1_Enable
    0xfe79   U0000   f   # Overlay2_Enable
    0xfe7a   U0000   f   # AudibleBell_Enable
    0xfed0   U0000   f   # First_Virtual_Screen
    0xfed1   U0000   f   # Prev_Virtual_Screen
    0xfed2   U0000   f   # Next_Virtual_Screen
    0xfed4   U0000   f   # Last_Virtual_Screen
    0xfed5   U0000   f   # Terminate_Server
    0xfee0   U0000   f   # Pointer_Left
    0xfee1   U0000   f   # Pointer_Right
    0xfee2   U0000   f   # Pointer_Up
    0xfee3   U0000   f   # Pointer_Down
    0xfee4   U0000   f   # Pointer_UpLeft
    0xfee5   U0000   f   # Pointer_UpRight
    0xfee6   U0000   f   # Pointer_DownLeft
    0xfee7   U0000   f   # Pointer_DownRight
    0xfee8   U0000   f   # Pointer_Button_Dflt
    0xfee9   U0000   f   # Pointer_Button1
    0xfeea   U0000   f   # Pointer_Button2
    0xfeeb   U0000   f   # Pointer_Button3
    0xfeec   U0000   f   # Pointer_Button4
    0xfeed   U0000   f   # Pointer_Button5
    0xfeee   U0000   f   # Pointer_DblClick_Dflt
    0xfeef   U0000   f   # Pointer_DblClick1
    0xfef0   U0000   f   # Pointer_DblClick2
    0xfef1   U0000   f   # Pointer_DblClick3
    0xfef2   U0000   f   # Pointer_DblClick4
    0xfef3   U0000   f   # Pointer_DblClick5
    0xfef4   U0000   f   # Pointer_Drag_Dflt
    0xfef5   U0000   f   # Pointer_Drag1
    0xfef6   U0000   f   # Pointer_Drag2
    0xfef7   U0000   f   # Pointer_Drag3
    0xfef8   U0000   f   # Pointer_Drag4
    0xfef9   U0000   f   # Pointer_EnableKeys
    0xfefa   U0000   f   # Pointer_Accelerate
    0xfefb   U0000   f   # Pointer_DfltBtnNext
    0xfefc   U0000   f   # Pointer_DfltBtnPrev
    0xfefd   U0000   f   # Pointer_Drag5}
    $FF08: Result := VK_BS_BACK; // BackSpace	/* back space, back char */
    $FF09: Result := VK_BS_TAB;
//    0xff0a   U000a   f   # Linefeed	/* Linefeed, LF */
    $FF0B: Result := VK_BS_CLEAR;
    $FF0D: Result := VK_BS_RETURN; // Return, enter */
{    0xff13   U0013   f   # Pause	/* Pause, hold */
    0xff14   U0014   f   # Scroll_Lock
    0xff15   U0015   f   # Sys_Req}
    $FF1B: Result := VK_BS_ESCAPE;
{    0xff20   U0000   f   # Multi_key
    0xff21   U0000   f   # Kanji
    0xff22   U0000   f   # Muhenkan
    0xff23   U0000   f   # Henkan_Mode
    0xff24   U0000   f   # Romaji
    0xff25   U0000   f   # Hiragana
    0xff26   U0000   f   # Katakana
    0xff27   U0000   f   # Hiragana_Katakana
    0xff28   U0000   f   # Zenkaku
    0xff29   U0000   f   # Hankaku
    0xff2a   U0000   f   # Zenkaku_Hankaku
    0xff2b   U0000   f   # Touroku
    0xff2c   U0000   f   # Massyo
    0xff2d   U0000   f   # Kana_Lock
    0xff2e   U0000   f   # Kana_Shift
    0xff2f   U0000   f   # Eisu_Shift
    0xff30   U0000   f   # Eisu_toggle
    0xff31   U0000   f   # Hangul
    0xff32   U0000   f   # Hangul_Start
    0xff33   U0000   f   # Hangul_End
    0xff34   U0000   f   # Hangul_Hanja
    0xff35   U0000   f   # Hangul_Jamo
    0xff36   U0000   f   # Hangul_Romaja
    0xff37   U0000   f   # Codeinput
    0xff38   U0000   f   # Hangul_Jeonja
    0xff39   U0000   f   # Hangul_Banja
    0xff3a   U0000   f   # Hangul_PreHanja
    0xff3b   U0000   f   # Hangul_PostHanja
    0xff3c   U0000   f   # SingleCandidate
    0xff3d   U0000   f   # MultipleCandidate
    0xff3e   U0000   f   # PreviousCandidate
    0xff3f   U0000   f   # Hangul_Special}
    $FF50: Result := VK_BS_HOME;
    $FF51: Result := VK_BS_LEFT;
    $FF52: Result := VK_BS_UP;
    $FF53: Result := VK_BS_RIGHT;
    $FF54: Result := VK_BS_DOWN;
    $FF55: Result := VK_BS_PRIOR;
    $FF56: Result := VK_BS_NEXT;
    $ff57: Result := VK_BS_END;
{    0xff58   U0000   f   # Begin
    0xff60   U0000   f   # Select
    0xff61   U0000   f   # Print
    0xff62   U0000   f   # Execute
    0xff63   U0000   f   # Insert
    0xff65   U0000   f   # Undo
    0xff66   U0000   f   # Redo
    0xff67   U0000   f   # Menu
    0xff68   U0000   f   # Find
    0xff69   U0000   f   # Cancel
    0xff6a   U0000   f   # Help
    0xff6b   U0000   f   # Break
    0xff7e   U0000   f   # Mode_switch}
    $FF7F: Result := VK_BS_NUMLOCK;
//    0xff7f   U0000   f   # Num_Lock
    $FF80: Result := VK_BS_SPACE;
    $FF89: Result := VK_BS_TAB;
    $FF8D: Result := VK_BS_RETURN; // KP_Enter	/* enter */
{    0xff91   U0000   f   # KP_F1
    0xff92   U0000   f   # KP_F2
    0xff93   U0000   f   # KP_F3
    0xff94   U0000   f   # KP_F4
    0xff95   U0000   f   # KP_Home
    0xff96   U0000   f   # KP_Left
    0xff97   U0000   f   # KP_Up
    0xff98   U0000   f   # KP_Right
    0xff99   U0000   f   # KP_Down
    0xff9a   U0000   f   # KP_Prior
    0xff9b   U0000   f   # KP_Next
    0xff9c   U0000   f   # KP_End
    0xff9d   U0000   f   # KP_Begin
    0xff9e   U0000   f   # KP_Insert
    0xff9f   U0000   f   # KP_Delete
    0xffaa   U002a   f   # KP_Multiply
    0xffab   U002b   f   # KP_Add
    0xffac   U002c   f   # KP_Separator	/* separator, often comma */
    0xffad   U002d   f   # KP_Subtract
    0xffae   U002e   f   # KP_Decimal
    0xffaf   U002f   f   # KP_Divide
    0xffb0   U0030   f   # KP_0
    0xffb1   U0031   f   # KP_1
    0xffb2   U0032   f   # KP_2
    0xffb3   U0033   f   # KP_3
    0xffb4   U0034   f   # KP_4
    0xffb5   U0035   f   # KP_5
    0xffb6   U0036   f   # KP_6
    0xffb7   U0037   f   # KP_7
    0xffb8   U0038   f   # KP_8
    0xffb9   U0039   f   # KP_9
    0xffbd   U003d   f   # KP_Equal	/* equals */}
    $FFBE: Result := VK_BS_F1;
    $FFBF: Result := VK_BS_F2;
    $FFC0: Result := VK_BS_F3;
    $FFC1: Result := VK_BS_F4;
    $FFC2: Result := VK_BS_F5;
    $FFC3: Result := VK_BS_F6;
    $FFC4: Result := VK_BS_F7;
    $FFC5: Result := VK_BS_F8;
    $FFC6: Result := VK_BS_F9;
    $FFC7: Result := VK_BS_F10;
    $FFC8: Result := VK_BS_F11;
    $FFC9: Result := VK_BS_F12;
{    0xffca   U0000   f   # F13
    0xffcb   U0000   f   # F14
    0xffcc   U0000   f   # F15
    0xffcd   U0000   f   # F16
    0xffce   U0000   f   # F17
    0xffcf   U0000   f   # F18
    0xffd0   U0000   f   # F19
    0xffd1   U0000   f   # F20
    0xffd2   U0000   f   # F21
    0xffd3   U0000   f   # F22
    0xffd4   U0000   f   # F23
    0xffd5   U0000   f   # F24
    0xffd6   U0000   f   # F25
    0xffd7   U0000   f   # F26
    0xffd8   U0000   f   # F27
    0xffd9   U0000   f   # F28
    0xffda   U0000   f   # F29
    0xffdb   U0000   f   # F30
    0xffdc   U0000   f   # F31
    0xffdd   U0000   f   # F32
    0xffde   U0000   f   # F33
    0xffdf   U0000   f   # F34
    0xffe0   U0000   f   # F35}
    $FFE1: Result := VK_BS_LSHIFT;
    $FFE2: Result := VK_BS_RSHIFT;
    $FFE3: Result := VK_BS_LCONTROL;
    $FFE4: Result := VK_BS_RCONTROL;
{    0xffe5   U0000   f   # Caps_Lock
    0xffe6   U0000   f   # Shift_Lock
    0xffe7   U0000   f   # Meta_L
    0xffe8   U0000   f   # Meta_R}
    $FFE9: Result := VK_BS_LMENU;
    {0xffea   U0000   f   # Alt_R
    0xffeb   U0000   f   # Super_L
    0xffec   U0000   f   # Super_R
    0xffed   U0000   f   # Hyper_L
    0xffee   U0000   f   # Hyper_R
    0xffff   U0000   f   # Delete }
    $FFFF: Result := VK_BS_DELETE;
{    0xffffff U0000   f   # VoidSymbol

    # Various XFree86 extensions since X11R6.4
    # http://cvsweb.xfree86.org/cvsweb/xc/include/keysymdef.h

    # KOI8-U support (Aleksey Novodvorsky, 1999-05-30)
    # http://cvsweb.xfree86.org/cvsweb/xc/include/keysymdef.h.diff?r1=1.4&r2=1.5
    # Used in XFree86's /usr/lib/X11/xkb/symbols/ua mappings

    0x06ad   U0491   .   # Ukrainian_ghe_with_upturn
    0x06bd   U0490   .   # Ukrainian_GHE_WITH_UPTURN

    # Support for armscii-8, ibm-cp1133, mulelao-1, viscii1.1-1,
    # tcvn-5712, georgian-academy, georgian-ps
    # (#2843, Pablo Saratxaga <pablo@mandrakesoft.com>, 1999-06-06)
    # http://cvsweb.xfree86.org/cvsweb/xc/include/keysymdef.h.diff?r1=1.6&r2=1.7

    # Armenian
    # (not used in any XFree86 4.4 kbd layouts, where /usr/lib/X11/xkb/symbols/am
    # uses directly Unicode-mapped hexadecimal values instead)
    0x14a1   U0000   r   # Armenian_eternity
    0x14a2   U0587   u   # Armenian_ligature_ew
    0x14a3   U0589   u   # Armenian_verjaket
    0x14a4   U0029   r   # Armenian_parenright
    0x14a5   U0028   r   # Armenian_parenleft
    0x14a6   U00bb   r   # Armenian_guillemotright
    0x14a7   U00ab   r   # Armenian_guillemotleft
    0x14a8   U2014   r   # Armenian_em_dash
    0x14a9   U002e   r   # Armenian_mijaket
    0x14aa   U055d   u   # Armenian_but
    0x14ab   U002c   r   # Armenian_comma
    0x14ac   U2013   r   # Armenian_en_dash
    0x14ad   U058a   u   # Armenian_yentamna
    0x14ae   U2026   r   # Armenian_ellipsis
    0x14af   U055c   u   # Armenian_amanak
    0x14b0   U055b   u   # Armenian_shesht
    0x14b1   U055e   u   # Armenian_paruyk
    0x14b2   U0531   u   # Armenian_AYB
    0x14b3   U0561   u   # Armenian_ayb
    0x14b4   U0532   u   # Armenian_BEN
    0x14b5   U0562   u   # Armenian_ben
    0x14b6   U0533   u   # Armenian_GIM
    0x14b7   U0563   u   # Armenian_gim
    0x14b8   U0534   u   # Armenian_DA
    0x14b9   U0564   u   # Armenian_da
    0x14ba   U0535   u   # Armenian_YECH
    0x14bb   U0565   u   # Armenian_yech
    0x14bc   U0536   u   # Armenian_ZA
    0x14bd   U0566   u   # Armenian_za
    0x14be   U0537   u   # Armenian_E
    0x14bf   U0567   u   # Armenian_e
    0x14c0   U0538   u   # Armenian_AT
    0x14c1   U0568   u   # Armenian_at
    0x14c2   U0539   u   # Armenian_TO
    0x14c3   U0569   u   # Armenian_to
    0x14c4   U053a   u   # Armenian_ZHE
    0x14c5   U056a   u   # Armenian_zhe
    0x14c6   U053b   u   # Armenian_INI
    0x14c7   U056b   u   # Armenian_ini
    0x14c8   U053c   u   # Armenian_LYUN
    0x14c9   U056c   u   # Armenian_lyun
    0x14ca   U053d   u   # Armenian_KHE
    0x14cb   U056d   u   # Armenian_khe
    0x14cc   U053e   u   # Armenian_TSA
    0x14cd   U056e   u   # Armenian_tsa
    0x14ce   U053f   u   # Armenian_KEN
    0x14cf   U056f   u   # Armenian_ken
    0x14d0   U0540   u   # Armenian_HO
    0x14d1   U0570   u   # Armenian_ho
    0x14d2   U0541   u   # Armenian_DZA
    0x14d3   U0571   u   # Armenian_dza
    0x14d4   U0542   u   # Armenian_GHAT
    0x14d5   U0572   u   # Armenian_ghat
    0x14d6   U0543   u   # Armenian_TCHE
    0x14d7   U0573   u   # Armenian_tche
    0x14d8   U0544   u   # Armenian_MEN
    0x14d9   U0574   u   # Armenian_men
    0x14da   U0545   u   # Armenian_HI
    0x14db   U0575   u   # Armenian_hi
    0x14dc   U0546   u   # Armenian_NU
    0x14dd   U0576   u   # Armenian_nu
    0x14de   U0547   u   # Armenian_SHA
    0x14df   U0577   u   # Armenian_sha
    0x14e0   U0548   u   # Armenian_VO
    0x14e1   U0578   u   # Armenian_vo
    0x14e2   U0549   u   # Armenian_CHA
    0x14e3   U0579   u   # Armenian_cha
    0x14e4   U054a   u   # Armenian_PE
    0x14e5   U057a   u   # Armenian_pe
    0x14e6   U054b   u   # Armenian_JE
    0x14e7   U057b   u   # Armenian_je
    0x14e8   U054c   u   # Armenian_RA
    0x14e9   U057c   u   # Armenian_ra
    0x14ea   U054d   u   # Armenian_SE
    0x14eb   U057d   u   # Armenian_se
    0x14ec   U054e   u   # Armenian_VEV
    0x14ed   U057e   u   # Armenian_vev
    0x14ee   U054f   u   # Armenian_TYUN
    0x14ef   U057f   u   # Armenian_tyun
    0x14f0   U0550   u   # Armenian_RE
    0x14f1   U0580   u   # Armenian_re
    0x14f2   U0551   u   # Armenian_TSO
    0x14f3   U0581   u   # Armenian_tso
    0x14f4   U0552   u   # Armenian_VYUN
    0x14f5   U0582   u   # Armenian_vyun
    0x14f6   U0553   u   # Armenian_PYUR
    0x14f7   U0583   u   # Armenian_pyur
    0x14f8   U0554   u   # Armenian_KE
    0x14f9   U0584   u   # Armenian_ke
    0x14fa   U0555   u   # Armenian_O
    0x14fb   U0585   u   # Armenian_o
    0x14fc   U0556   u   # Armenian_FE
    0x14fd   U0586   u   # Armenian_fe
    0x14fe   U055a   u   # Armenian_apostrophe
    0x14ff   U00a7   r   # Armenian_section_sign

    # Gregorian
    # (not used in any XFree86 4.4 kbd layouts, were /usr/lib/X11/xkb/symbols/ge_*
    # uses directly Unicode-mapped hexadecimal values instead)
    0x15d0   U10d0   u   # Georgian_an
    0x15d1   U10d1   u   # Georgian_ban
    0x15d2   U10d2   u   # Georgian_gan
    0x15d3   U10d3   u   # Georgian_don
    0x15d4   U10d4   u   # Georgian_en
    0x15d5   U10d5   u   # Georgian_vin
    0x15d6   U10d6   u   # Georgian_zen
    0x15d7   U10d7   u   # Georgian_tan
    0x15d8   U10d8   u   # Georgian_in
    0x15d9   U10d9   u   # Georgian_kan
    0x15da   U10da   u   # Georgian_las
    0x15db   U10db   u   # Georgian_man
    0x15dc   U10dc   u   # Georgian_nar
    0x15dd   U10dd   u   # Georgian_on
    0x15de   U10de   u   # Georgian_par
    0x15df   U10df   u   # Georgian_zhar
    0x15e0   U10e0   u   # Georgian_rae
    0x15e1   U10e1   u   # Georgian_san
    0x15e2   U10e2   u   # Georgian_tar
    0x15e3   U10e3   u   # Georgian_un
    0x15e4   U10e4   u   # Georgian_phar
    0x15e5   U10e5   u   # Georgian_khar
    0x15e6   U10e6   u   # Georgian_ghan
    0x15e7   U10e7   u   # Georgian_qar
    0x15e8   U10e8   u   # Georgian_shin
    0x15e9   U10e9   u   # Georgian_chin
    0x15ea   U10ea   u   # Georgian_can
    0x15eb   U10eb   u   # Georgian_jil
    0x15ec   U10ec   u   # Georgian_cil
    0x15ed   U10ed   u   # Georgian_char
    0x15ee   U10ee   u   # Georgian_xan
    0x15ef   U10ef   u   # Georgian_jhan
    0x15f0   U10f0   u   # Georgian_hae
    0x15f1   U10f1   u   # Georgian_he
    0x15f2   U10f2   u   # Georgian_hie
    0x15f3   U10f3   u   # Georgian_we
    0x15f4   U10f4   u   # Georgian_har
    0x15f5   U10f5   u   # Georgian_hoe
    0x15f6   U10f6   u   # Georgian_fi

    # Pablo Saratxaga's i18n updates for XFree86 that are used in Mandrake 7.2.
    # (#4195, Pablo Saratxaga <pablo@mandrakesoft.com>, 2000-10-27)
    # http://cvsweb.xfree86.org/cvsweb/xc/include/keysymdef.h.diff?r1=1.9&r2=1.10

    # Latin-8
    # (the *abovedot keysyms are used in /usr/lib/X11/xkb/symbols/ie)
    0x12a1   U1e02   u   # Babovedot
    0x12a2   U1e03   u   # babovedot
    0x12a6   U1e0a   u   # Dabovedot
    0x12a8   U1e80   u   # Wgrave
    0x12aa   U1e82   u   # Wacute
    0x12ab   U1e0b   u   # dabovedot
    0x12ac   U1ef2   u   # Ygrave
    0x12b0   U1e1e   u   # Fabovedot
    0x12b1   U1e1f   u   # fabovedot
    0x12b4   U1e40   u   # Mabovedot
    0x12b5   U1e41   u   # mabovedot
    0x12b7   U1e56   u   # Pabovedot
    0x12b8   U1e81   u   # wgrave
    0x12b9   U1e57   u   # pabovedot
    0x12ba   U1e83   u   # wacute
    0x12bb   U1e60   u   # Sabovedot
    0x12bc   U1ef3   u   # ygrave
    0x12bd   U1e84   u   # Wdiaeresis
    0x12be   U1e85   u   # wdiaeresis
    0x12bf   U1e61   u   # sabovedot
    0x12d0   U0174   u   # Wcircumflex
    0x12d7   U1e6a   u   # Tabovedot
    0x12de   U0176   u   # Ycircumflex
    0x12f0   U0175   u   # wcircumflex
    0x12f7   U1e6b   u   # tabovedot
    0x12fe   U0177   u   # ycircumflex

    # Arabic
    # (of these, in XFree86 4.4 only Arabic_superscript_alef, Arabic_madda_above,
    # Arabic_hamza_* are actually used, e.g. in /usr/lib/X11/xkb/symbols/syr)
    0x0590   U06f0   u   # Farsi_0
    0x0591   U06f1   u   # Farsi_1
    0x0592   U06f2   u   # Farsi_2
    0x0593   U06f3   u   # Farsi_3
    0x0594   U06f4   u   # Farsi_4
    0x0595   U06f5   u   # Farsi_5
    0x0596   U06f6   u   # Farsi_6
    0x0597   U06f7   u   # Farsi_7
    0x0598   U06f8   u   # Farsi_8
    0x0599   U06f9   u   # Farsi_9
    0x05a5   U066a   u   # Arabic_percent
    0x05a6   U0670   u   # Arabic_superscript_alef
    0x05a7   U0679   u   # Arabic_tteh
    0x05a8   U067e   u   # Arabic_peh
    0x05a9   U0686   u   # Arabic_tcheh
    0x05aa   U0688   u   # Arabic_ddal
    0x05ab   U0691   u   # Arabic_rreh
    0x05ae   U06d4   u   # Arabic_fullstop
    0x05b0   U0660   u   # Arabic_0
    0x05b1   U0661   u   # Arabic_1
    0x05b2   U0662   u   # Arabic_2
    0x05b3   U0663   u   # Arabic_3
    0x05b4   U0664   u   # Arabic_4
    0x05b5   U0665   u   # Arabic_5
    0x05b6   U0666   u   # Arabic_6
    0x05b7   U0667   u   # Arabic_7
    0x05b8   U0668   u   # Arabic_8
    0x05b9   U0669   u   # Arabic_9
    0x05f3   U0653   u   # Arabic_madda_above
    0x05f4   U0654   u   # Arabic_hamza_above
    0x05f5   U0655   u   # Arabic_hamza_below
    0x05f6   U0698   u   # Arabic_jeh
    0x05f7   U06a4   u   # Arabic_veh
    0x05f8   U06a9   u   # Arabic_keheh
    0x05f9   U06af   u   # Arabic_gaf
    0x05fa   U06ba   u   # Arabic_noon_ghunna
    0x05fb   U06be   u   # Arabic_heh_doachashmee
    0x05fc   U06cc   u   # Farsi_yeh
    0x05fd   U06d2   u   # Arabic_yeh_baree
    0x05fe   U06c1   u   # Arabic_heh_goal

    # Cyrillic
    # (none of these are actually used in any XFree86 4.4 kbd layouts)
    0x0680   U0492   u   # Cyrillic_GHE_bar
    0x0681   U0496   u   # Cyrillic_ZHE_descender
    0x0682   U049a   u   # Cyrillic_KA_descender
    0x0683   U049c   u   # Cyrillic_KA_vertstroke
    0x0684   U04a2   u   # Cyrillic_EN_descender
    0x0685   U04ae   u   # Cyrillic_U_straight
    0x0686   U04b0   u   # Cyrillic_U_straight_bar
    0x0687   U04b2   u   # Cyrillic_HA_descender
    0x0688   U04b6   u   # Cyrillic_CHE_descender
    0x0689   U04b8   u   # Cyrillic_CHE_vertstroke
    0x068a   U04ba   u   # Cyrillic_SHHA
    0x068c   U04d8   u   # Cyrillic_SCHWA
    0x068d   U04e2   u   # Cyrillic_I_macron
    0x068e   U04e8   u   # Cyrillic_O_bar
    0x068f   U04ee   u   # Cyrillic_U_macron
    0x0690   U0493   u   # Cyrillic_ghe_bar
    0x0691   U0497   u   # Cyrillic_zhe_descender
    0x0692   U049b   u   # Cyrillic_ka_descender
    0x0693   U049d   u   # Cyrillic_ka_vertstroke
    0x0694   U04a3   u   # Cyrillic_en_descender
    0x0695   U04af   u   # Cyrillic_u_straight
    0x0696   U04b1   u   # Cyrillic_u_straight_bar
    0x0697   U04b3   u   # Cyrillic_ha_descender
    0x0698   U04b7   u   # Cyrillic_che_descender
    0x0699   U04b9   u   # Cyrillic_che_vertstroke
    0x069a   U04bb   u   # Cyrillic_shha
    0x069c   U04d9   u   # Cyrillic_schwa
    0x069d   U04e3   u   # Cyrillic_i_macron
    0x069e   U04e9   u   # Cyrillic_o_bar
    0x069f   U04ef   u   # Cyrillic_u_macron

    # Caucasus
    # (of these, in XFree86 4.4 only Gcaron, gcaron are actually used,
    # e.g. in /usr/lib/X11/xkb/symbols/sapmi; the lack of Unicode
    # equivalents for the others suggests that they are bogus)
    0x16a2   U0000   r   # Ccedillaabovedot
    0x16a3   U1e8a   u   # Xabovedot
    0x16a5   U0000   r   # Qabovedot
    0x16a6   U012c   u   # Ibreve
    0x16a7   U0000   r   # IE
    0x16a8   U0000   r   # UO
    0x16a9   U01b5   u   # Zstroke
    0x16aa   U01e6   u   # Gcaron
    0x16af   U019f   u   # Obarred
    0x16b2   U0000   r   # ccedillaabovedot
    0x16b3   U1e8b   u   # xabovedot
    0x16b4   U0000   r   # Ocaron
    0x16b5   U0000   r   # qabovedot
    0x16b6   U012d   u   # ibreve
    0x16b7   U0000   r   # ie
    0x16b8   U0000   r   # uo
    0x16b9   U01b6   u   # zstroke
    0x16ba   U01e7   u   # gcaron
    0x16bd   U01d2   u   # ocaron
    0x16bf   U0275   u   # obarred
    0x16c6   U018f   u   # SCHWA
    0x16f6   U0259   u   # schwa

    # Inupiak, Guarani
    # (none of these are actually used in any XFree86 4.4 kbd layouts,
    # and the lack of Unicode equivalents suggests that they are bogus)
    0x16d1   U1e36   u   # Lbelowdot
    0x16d2   U0000   r   # Lstrokebelowdot
    0x16d3   U0000   r   # Gtilde
    0x16e1   U1e37   u   # lbelowdot
    0x16e2   U0000   r   # lstrokebelowdot
    0x16e3   U0000   r   # gtilde

    # Vietnamese
    # (none of these are actually used in any XFree86 4.4 kbd layouts; they are
    # also pointless, as Vietnamese input methods use dead accent keys + ASCII keys)
    0x1ea0   U1ea0   u   # Abelowdot
    0x1ea1   U1ea1   u   # abelowdot
    0x1ea2   U1ea2   u   # Ahook
    0x1ea3   U1ea3   u   # ahook
    0x1ea4   U1ea4   u   # Acircumflexacute
    0x1ea5   U1ea5   u   # acircumflexacute
    0x1ea6   U1ea6   u   # Acircumflexgrave
    0x1ea7   U1ea7   u   # acircumflexgrave
    0x1ea8   U1ea8   u   # Acircumflexhook
    0x1ea9   U1ea9   u   # acircumflexhook
    0x1eaa   U1eaa   u   # Acircumflextilde
    0x1eab   U1eab   u   # acircumflextilde
    0x1eac   U1eac   u   # Acircumflexbelowdot
    0x1ead   U1ead   u   # acircumflexbelowdot
    0x1eae   U1eae   u   # Abreveacute
    0x1eaf   U1eaf   u   # abreveacute
    0x1eb0   U1eb0   u   # Abrevegrave
    0x1eb1   U1eb1   u   # abrevegrave
    0x1eb2   U1eb2   u   # Abrevehook
    0x1eb3   U1eb3   u   # abrevehook
    0x1eb4   U1eb4   u   # Abrevetilde
    0x1eb5   U1eb5   u   # abrevetilde
    0x1eb6   U1eb6   u   # Abrevebelowdot
    0x1eb7   U1eb7   u   # abrevebelowdot
    0x1eb8   U1eb8   u   # Ebelowdot
    0x1eb9   U1eb9   u   # ebelowdot
    0x1eba   U1eba   u   # Ehook
    0x1ebb   U1ebb   u   # ehook
    0x1ebc   U1ebc   u   # Etilde
    0x1ebd   U1ebd   u   # etilde
    0x1ebe   U1ebe   u   # Ecircumflexacute
    0x1ebf   U1ebf   u   # ecircumflexacute
    0x1ec0   U1ec0   u   # Ecircumflexgrave
    0x1ec1   U1ec1   u   # ecircumflexgrave
    0x1ec2   U1ec2   u   # Ecircumflexhook
    0x1ec3   U1ec3   u   # ecircumflexhook
    0x1ec4   U1ec4   u   # Ecircumflextilde
    0x1ec5   U1ec5   u   # ecircumflextilde
    0x1ec6   U1ec6   u   # Ecircumflexbelowdot
    0x1ec7   U1ec7   u   # ecircumflexbelowdot
    0x1ec8   U1ec8   u   # Ihook
    0x1ec9   U1ec9   u   # ihook
    0x1eca   U1eca   u   # Ibelowdot
    0x1ecb   U1ecb   u   # ibelowdot
    0x1ecc   U1ecc   u   # Obelowdot
    0x1ecd   U1ecd   u   # obelowdot
    0x1ece   U1ece   u   # Ohook
    0x1ecf   U1ecf   u   # ohook
    0x1ed0   U1ed0   u   # Ocircumflexacute
    0x1ed1   U1ed1   u   # ocircumflexacute
    0x1ed2   U1ed2   u   # Ocircumflexgrave
    0x1ed3   U1ed3   u   # ocircumflexgrave
    0x1ed4   U1ed4   u   # Ocircumflexhook
    0x1ed5   U1ed5   u   # ocircumflexhook
    0x1ed6   U1ed6   u   # Ocircumflextilde
    0x1ed7   U1ed7   u   # ocircumflextilde
    0x1ed8   U1ed8   u   # Ocircumflexbelowdot
    0x1ed9   U1ed9   u   # ocircumflexbelowdot
    0x1eda   U1eda   u   # Ohornacute
    0x1edb   U1edb   u   # ohornacute
    0x1edc   U1edc   u   # Ohorngrave
    0x1edd   U1edd   u   # ohorngrave
    0x1ede   U1ede   u   # Ohornhook
    0x1edf   U1edf   u   # ohornhook
    0x1ee0   U1ee0   u   # Ohorntilde
    0x1ee1   U1ee1   u   # ohorntilde
    0x1ee2   U1ee2   u   # Ohornbelowdot
    0x1ee3   U1ee3   u   # ohornbelowdot
    0x1ee4   U1ee4   u   # Ubelowdot
    0x1ee5   U1ee5   u   # ubelowdot
    0x1ee6   U1ee6   u   # Uhook
    0x1ee7   U1ee7   u   # uhook
    0x1ee8   U1ee8   u   # Uhornacute
    0x1ee9   U1ee9   u   # uhornacute
    0x1eea   U1eea   u   # Uhorngrave
    0x1eeb   U1eeb   u   # uhorngrave
    0x1eec   U1eec   u   # Uhornhook
    0x1eed   U1eed   u   # uhornhook
    0x1eee   U1eee   u   # Uhorntilde
    0x1eef   U1eef   u   # uhorntilde
    0x1ef0   U1ef0   u   # Uhornbelowdot
    0x1ef1   U1ef1   u   # uhornbelowdot
    0x1ef4   U1ef4   u   # Ybelowdot
    0x1ef5   U1ef5   u   # ybelowdot
    0x1ef6   U1ef6   u   # Yhook
    0x1ef7   U1ef7   u   # yhook
    0x1ef8   U1ef8   u   # Ytilde
    0x1ef9   U1ef9   u   # ytilde

    0x1efa   U01a0   u   # Ohorn
    0x1efb   U01a1   u   # ohorn
    0x1efc   U01af   u   # Uhorn
    0x1efd   U01b0   u   # uhorn

    # (Unicode combining characters have no direct equivalence with
    # keysyms, where dead keys are defined instead)
    0x1e9f   U0303   r   # combining_tilde
    0x1ef2   U0300   r   # combining_grave
    0x1ef3   U0301   r   # combining_acute
    0x1efe   U0309   r   # combining_hook
    0x1eff   U0323   r   # combining_belowdot

    # These probably should be added to the X11 standard properly,
    # as they could be of use for Vietnamese input methods.
    0xfe60   U0323   f   # dead_belowdot
    0xfe61   U0309   f   # dead_hook
    0xfe62   U031b   f   # dead_horn}
  else
    Result := Keycode;
  end;
end;


procedure Init;
const
  libX11: String = 'libX11.so';
  //libXrandr = 'libXrandr.so.2';

var
  {$ifdef FPC}
  libX11handle: TLibHandle;
  {$else}
  libX11handle: THandle;
  {$endif}
begin
  {$IFDEF FPC}
    { according to bug 7570, this is necessary on all x86 platforms,
      maybe we've to fix the sse control word as well }
    { Yes, at least for darwin/x86_64 (JM) }
    {$IF DEFINED(cpui386) or DEFINED(cpux86_64)}
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
    {$IFEND}
  {$ENDIF}

  libX11handle := LoadLibrary(PChar(libX11));
  if libX11handle = 0 then
    raise Exception.Create(format('Could not load library: %s',[libX11]));

  XDisplayName := GetProcAddress(libX11handle, 'XDisplayName');
  XOpenDisplay := GetProcAddress(libX11handle, 'XOpenDisplay');
  XCloseDisplay := GetProcAddress(libX11handle, 'XCloseDisplay');
  XDisplayHeight := GetProcAddress(libX11handle, 'XDisplayHeight');
  XDisplayHeightMM := GetProcAddress(libX11handle, 'XDisplayHeightMM');
  XDisplayKeycodes := GetProcAddress(libX11handle, 'XDisplayKeycodes');
  XDisplayPlanes := GetProcAddress(libX11handle, 'XDisplayPlanes');
  XDisplayWidth := GetProcAddress(libX11handle, 'XDisplayWidth');
  XDisplayWidthMM := GetProcAddress(libX11handle, 'XDisplayWidthMM');
  XCreateColormap := GetProcAddress(libX11handle, 'XCreateColormap');
  XDefaultColormap := GetProcAddress(libX11handle, 'XDefaultColormap');
  XDefaultScreen := GetProcAddress(libX11handle, 'XDefaultScreen');
  XDefaultRootWindow := GetProcAddress(libX11handle, 'XDefaultRootWindow');
  XDefaultVisual := GetProcAddress(libX11handle, 'XDefaultVisual');
  XDefaultDepth := GetProcAddress(libX11handle, 'XDefaultDepth');
  XDefaultDepthOfScreen := GetProcAddress(libX11handle, 'XDefaultDepthOfScreen');

  XCreateWindow := GetProcAddress(libX11handle, 'XCreateWindow');
  XDestroyWindow := GetProcAddress(libX11handle, 'XDestroyWindow');
  XGetWindowProperty := GetProcAddress(libX11handle, 'XGetWindowProperty');
  XChangeProperty := GetProcAddress(libX11handle, 'XChangeProperty');
  XMapRaised := GetProcAddress(libX11handle, 'XMapRaised');
  XMapWindow := GetProcAddress(libX11handle, 'XMapWindow');
  XUnmapWindow := GetProcAddress(libX11handle, 'XUnmapWindow');
  XMoveWindow := GetProcAddress(libX11handle, 'XMoveWindow');
  XClearWindow := GetProcAddress(libX11handle, 'XClearWindow');
  XConfigureWindow := GetProcAddress(libX11handle, 'XConfigureWindow');
  XSetTransientForHint := GetProcAddress(libX11handle, 'XSetTransientForHint');

  XSelectInput := GetProcAddress(libX11handle, 'XSelectInput');
  XSetStandardProperties := GetProcAddress(libX11handle, 'XSetStandardProperties');
  XInternAtom := GetProcAddress(libX11handle, 'XInternAtom');
  XSetClassHint := GetProcAddress(libX11handle, 'XSetClassHint');
  XCreateSimpleWindow := GetProcAddress(libX11handle, 'XCreateSimpleWindow');
  XAllocClassHint := GetProcAddress(libX11handle, 'XAllocClassHint');
  XFree := GetProcAddress(libX11handle, 'XFree');

  XSetWMProtocols := GetProcAddress(libX11handle, 'XSetWMProtocols');
  XSetWMNormalHints := GetProcAddress(libX11handle, 'XSetWMNormalHints');
  XSetWMHints := GetProcAddress(libX11handle, 'XSetWMNormalHints');
  XGetWMNormalHints := GetProcAddress(libX11handle, 'XGetWMNormalHints');
  XGetWMSizeHints := GetProcAddress(libX11handle, 'XGetWMSizeHints');
  XSetWMProperties := GetProcAddress(libX11handle, 'XSetWMProperties');
  XSetWMIconName := GetProcAddress(libX11handle, 'XSetWMIconName');
  XSetWMName := GetProcAddress(libX11handle, 'XSetWMName');

  XInternalConnectionNumbers := GetProcAddress(libX11handle, 'XInternalConnectionNumbers');
  XProcessInternalConnection := GetProcAddress(libX11handle, 'XProcessInternalConnection');
  XAddConnectionWatch := GetProcAddress(libX11handle, 'XAddConnectionWatch');
  XRemoveConnectionWatch := GetProcAddress(libX11handle, 'XRemoveConnectionWatch');
  XSetAuthorization := GetProcAddress(libX11handle, 'XSetAuthorization');

  XOpenIM := GetProcAddress(libX11handle, 'XOpenIM');
  XCloseIM := GetProcAddress(libX11handle, 'XCloseIM');
  XCreateIC := GetProcAddress(libX11handle, 'XCreateIC');
  XDestroyIC := GetProcAddress(libX11handle, 'XDestroyIC');

  XPeekEvent := GetProcAddress(libX11handle, 'XPeekEvent');
  XPeekIfEvent := GetProcAddress(libX11handle, 'XPeekIfEvent');
  XPending := GetProcAddress(libX11handle, 'XPending');
  XNextEvent := GetProcAddress(libX11handle, 'XNextEvent');
  XSendEvent := GetProcAddress(libX11handle, 'XSendEvent');

  XCheckTypedEvent := GetProcAddress(libX11handle, 'XCheckTypedEvent');
  XCheckTypedWindowEvent := GetProcAddress(libX11handle, 'XCheckTypedWindowEvent');
  XCheckWindowEvent := GetProcAddress(libX11handle, 'XCheckWindowEvent');

  XLookupKeysym := GetProcAddress(libX11handle, 'XLookupKeysym');
  XQueryPointer := GetProcAddress(libX11handle, 'XQueryPointer');
  XStringListToTextProperty := GetProcAddress(libX11handle, 'XStringListToTextProperty');
  Xutf8LookupString := GetProcAddress(libX11handle, 'Xutf8LookupString');
  Xutf8TextListToTextProperty := GetProcAddress(libX11handle, 'Xutf8TextListToTextProperty');

  XBlackPixel := GetProcAddress(libX11handle, 'XBlackPixel');
  XWhitePixel := GetProcAddress(libX11handle, 'XWhitePixel');
  XSync := GetProcAddress(libX11handle, 'XSync');
  XFlush := GetProcAddress(libX11handle, 'XFlush');
  {libXrandrhandle := LoadLibrary(PChar(libXrandr));
  if libXrandrhandle = 0 then
    raise Exception.Create(format('Could not load library: %s',[libXrandr]));

  XRRScreenConfig := GetProcAddress(libX11handle, 'XRRScreenConfig');
  XRRConfig := GetProcAddress(libX11handle, 'XRRConfig');
  XRRSelectInput := GetProcAddress(libX11handle, 'XRRSelectInput');
  XRRQueryExtension := GetProcAddress(libX11handle, 'XRRQueryExtension');
  XRRRotations := GetProcAddress(libX11handle, 'XRRRotations');
  XRRSizes := GetProcAddress(libX11handle, 'XRRSizes');
  XRRRootToScreen := GetProcAddress(libX11handle, 'XRRRootToScreen');
  XRRGetScreenInfo := GetProcAddress(libX11handle, 'XRRGetScreenInfo');
  XRRFreeScreenConfigInfo := GetProcAddress(libX11handle, 'XRRFreeScreenConfigInfo');
  XRRConfigCurrentConfiguration := GetProcAddress(libX11handle, 'XRRConfigCurrentConfiguration');}
//  libGdkhandle := LoadLibrary(PChar(gdklib));
//  if libGdkhandle = 0 then
//    raise Exception.Create(format('Could not load library: %s',[gdklib]));
//
//  gdk_window_xwindow := GetProcAddress(libGdkhandle, 'gdk_x11_drawable_get_xid'); ;

end;

initialization
  Init;

end.
