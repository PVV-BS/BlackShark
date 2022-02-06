{.$define DEBUG_BS}

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

{ It is defines GLES for use a DirectX in Windows OS by LibGLESv2.dll,
  else uses a purely descktop OpenGL (within GLES API version >= 2.0).
  For the desktop OpenGL (when GLES not defined) uses Mesa 3D
  Graphics Library. If the OpenGL context failed to create (for example,
  on Virtual Machine, or Remoute Descktop), then try create
  a software renderer  }

{$define GLES}

{ It is used OpenGL API; do not set simultaneously! }
  {$define GLES20}  // basic
  {.$define GLES30} // advanced


{$ifdef GLES20}
  {$ifdef GLES30}
    {$Message error 'Do not use GLES20 and GLES30 simultaneously'}
  {$endif}
{$else}
{$ifdef GLES30}


{$else}
    {$Message error 'Uncknown OpenGL version'}

{$endif}
{$endif}

