{.$define DEBUG_BS}

{$ifdef ANDROID}
  {$ifdef DEBUG_BS}
    {$define DBG_IO}
  {$endif}
  {$define SingleWinOnly}
{$endif}

{$ifdef ultibo}
  {$ifdef DEBUG_BS}
    {$define DBG_IO}
  {$endif}
  {$define SingleWinOnly}
{$endif}

{$INLINE ON}

{$ifdef FPC}
  {$mode delphi}
  {.$FPUTYPE SSE}
{$else}
  {$if declared(FireMonkeyVersion)}
    {$define FMX}
  {$endif}
{$endif FPC}

{$ifdef LINUX}
  { undefine X for other Linux windowmanagers }
  {$define X}
  {$define UseCThreads}
{$endif LINUX}

{$ifdef FMX}
   { it define is a try to adapt TBlackSharkViewPort for FMXLinux, but not yet }
   {$ifdef X}
     {$define FMXX}
   {$endif}
   {$ifdef ANDROID}
     {$define FMXX}
   {$endif}
{$endif}

//{$define GLES}
//
//{$define GLES20}  // basic
//{.$define GLES30} // advanced
