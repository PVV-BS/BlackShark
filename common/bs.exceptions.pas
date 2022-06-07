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

unit bs.exceptions;

interface

{$I BlackSharkCfg.inc}

uses
    SysUtils
  ;

type
  EBlackShark = class(Exception)
  end;

  ETODO = class(EBlackShark)
  end;

  EInvalidParameters = class(EBlackShark)
  end;

  EDeviceContextLost = class(EBlackShark)
  end;

  EDifferentThreadContext = class(EBlackShark)
  end;

  EComponentAlreadyExists = class(EBlackShark)
  end;

  ELimitReached = class(EBlackShark)
  end;

  EComponentIsNotValid = class(EBlackShark)
  end;

  {$ifdef DEBUG_BS}
  ERendererDebugError = class(EBlackShark)
  end;
  {$endif}

implementation

end.
