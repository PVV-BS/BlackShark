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

unit bs.config;

interface

type

  BSConfig = class
  private
    class var FResolutionWidth: int32;
    class var FResolutionHeight: int32;
    class procedure CalculateVoxelSize;
    class constructor Create;
    class procedure SetResolutionHeight(const Value: int32); static;
    class procedure SetResolutionWidth(const Value: int32); static;
  public
    class procedure Save;
    class procedure Load;
    class property ResolutionWidth: int32 read FResolutionWidth write SetResolutionWidth;
    class property ResolutionHeight: int32 read FResolutionHeight write SetResolutionHeight;
    class var VoxelSize: single;
    class var VoxelSizeInv: single;
    class var MultiSampling: boolean;
    class var MultiSamplingSamples: int32;
    class var VerticalSynchronization: boolean;
    { switch off if only state of your scene depends on input devices events (keyboard, mouse...) }
    class var MaxFps: boolean;
    { it allows contain pool of threads for execute any task of TTemplateBTask<T>;
      otherwise all tasks accomplish in gui thread; for to get an executer your any task you
      can use method bs.thread.NextExecutor; how use it see an example bs.test.gui.TBSTestSimpleAnimation }
    class var UseTaskExecutersSet: boolean;
  end;

implementation

{ BSConfig }

class procedure BSConfig.CalculateVoxelSize;
begin
  VoxelSize := 2.0 / (FResolutionWidth + FResolutionHeight);
  VoxelSizeInv := 1 / VoxelSize;
end;

class constructor BSConfig.Create;
begin
  FResolutionWidth := 600;
  FResolutionHeight := 600;
  MultiSampling := true;
  MultiSamplingSamples := 4;
  VerticalSynchronization := true;
  MaxFps := false;
  UseTaskExecutersSet := false;
  CalculateVoxelSize;
end;

class procedure BSConfig.Load;
begin

  CalculateVoxelSize;
end;

class procedure BSConfig.Save;
begin

end;

class procedure BSConfig.SetResolutionHeight(const Value: int32);
begin
  FResolutionHeight := Value;
  CalculateVoxelSize;
end;

class procedure BSConfig.SetResolutionWidth(const Value: int32);
begin
  FResolutionWidth := Value;
  CalculateVoxelSize;
end;

end.
