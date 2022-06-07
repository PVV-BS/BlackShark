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

unit bs.constants;

{$I BlackSharkCfg.inc}

interface

const
  TIMEOUT_MAX_FPS = 3000;

type

  ModalResults = record
  const
    mrCancel = 0;
    mrOk     = 1;
  end;

  Lang = record
    const
      BUTTON = 'Button';
      ACCEPT = 'Accept';
      CANCEL = 'Cancel';
      DLG_COLOR_SELECTION_CAPTION = 'DlgColorSelectionCaption';
      CUSTOM_COLOR_ITEM = 'CustomColor';
  end;

implementation

end.
