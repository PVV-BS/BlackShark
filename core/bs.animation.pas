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

unit bs.animation;

{$I BlackSharkCfg.inc}

interface

uses
    Classes
  , SysUtils
  , bs.obj
  , bs.basetypes
  , bs.events
  , bs.collections
  , bs.thread
  ;

type

  { the interface responsable for calculating the interpolated value }

  IBAnimation<T> = interface(IBTask)
    function GetDuration: int32;
    procedure SetDuration(Value: int32);
    function GetLoop: boolean;
    procedure SetLoop(Value: boolean);
    function GetLoopInverse: boolean;
    procedure SetLoopInverse(Value: boolean);
    function GetStartValue: T;
    procedure SetStartValue(const Value: T);
    function GetStopValue: T;
    procedure SetStopValue(const Value: T);
    function GetCurrentValue: T;
    function GetCurrentSender: Pointer;
    procedure SetCurrentSender(Value: Pointer);
    { create a simple observer and connect its to the event }
    function  CreateObserver(ThreadCntx: TBThread; OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;
    function  CreateObserver(OnRsvProc: TGenericRecieveProc<T>): IBObserver<T>; overload;

    property Duration: int32 read GetDuration write SetDuration;
    property Loop: boolean read GetLoop write SetLoop;
    property LoopInverse: boolean read GetLoopInverse write SetLoopInverse;

    property StartValue: T read GetStartValue write SetStartValue;
    property StopValue: T read GetStopValue write SetStopValue;
    property CurrentValue: T read GetCurrentValue;
    { any user pointer }
    property CurrentSender: Pointer read GetCurrentSender write SetCurrentSender;
  end;

  { TAniValueLawBase<T>

    implementation IBAnimation<T>

  }

  TAniValueLawBase<T> = class abstract (TTemplateBTask<T>, IBAnimation<T>)
  public
  type
    TAniValueT = TAniValueLawBase<T>;
  private
    FLoop: boolean;
    FLoopInverse: boolean;

  protected
    FCurrentSender: Pointer;
    FDuration: int32;
    TimeStart: uint64;
    LastTime: uint64;
    CurrentDeltaTime: int32;
    { if TAniValueLawBase<T>.Loop even false this method call automaticaly from
      thread context TBlackSharkAnimator }
    FDelta: T;
    FStartValue: T;
    FStopValue: T;
    FCurrentValue: T;
    { Turn back current value from StopValue to StartValue; call automaticaly
      from thread context TBlackSharkAnimator if TAniValueLawBase<T>.Loop even true }
    procedure Reverse; virtual;
    procedure Reset;
    procedure SendEvent(const Value: T);

    function GetDuration: int32;
    procedure SetDuration(Value: int32);
    function GetLoop: boolean;
    procedure SetLoop(Value: boolean);
    function GetLoopInverse: boolean;
    procedure SetLoopInverse(Value: boolean);
    function GetStartValue: T;
    procedure SetStartValue(const AValue: T);
    function GetStopValue: T;
    procedure SetStopValue(const AValue: T);
    function GetCurrentValue: T;
    function GetCurrentSender: Pointer;
    procedure SetCurrentSender(Value: Pointer);

  public
    constructor Create(ThreadContext: TBThread);
    { Run calculate value in depend on time }
    procedure Run; override;
    procedure Stop; override;
  end;

  IBAnimationLinearFloat = IBAnimation<BSFloat>;
  IBAnimationLinearFloatObsrv = IBObserver<BSFloat>;

  IBAnimationElipse = interface(IBAnimation<TVec2f>)
    function GetC: BSFloat;
    procedure SetC(const Value: BSFloat);
    function GetAngle: BSFloat;
    { Focal distance }
    property C: BSFloat read GetC write SetC;
    property Angle: BSFloat read GetAngle;
  end;

  IBAnimationElipseObsrv = IBObserver<TVec2f>;

  function CreateAniFloatLinear(ThreadContext: TBThread): IBAnimationLinearFloat; overload;
  function CreateAniFloatLinear: IBAnimationLinearFloat; overload;
  function CreateAniFloatLivearObsrv(const Animation: IBAnimationLinearFloat;
    OnRsvProc: TGenericRecieveProc<BSFloat>;
    ThreadContext: TBThread = nil): IBAnimationLinearFloatObsrv;

  function CreateAniElipse(ThreadContext: TBThread): IBAnimationElipse;


implementation

uses
  {$ifndef FPC}
    math,
  {$endif}
    bs.math
  ;

type

  { dcc32 compiler don't allow to use a common template class (issue an error
    for any mathematic operations (+,-,/,* ): E2015 Operator not applicable to
    this operand type), therefore define for every type self implementation }

  { TAniValueLawFloat }

  TAniValueLawFloat = class(TAniValueLawBase<BSFloat>)
  private
    type
      TBSFloatItemQ = TItemQueue<BSFloat>;
      TBSFloatDataQ = TQueueTemplate<TBSFloatItemQ>;
  protected
    procedure Reverse; override;
    //function GetLawMethod: TAniValueLawBase<BSFloat>.TLawMethodAniRef; override;
    procedure Update; override;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Run; override;
  end;

  { TAniValueLawFloat }

  TAniValueLawElipse = class(TAniValueLawBase<TVec2f>, IBAnimationElipse)
  private
    type
      TVec2fItemQ = TItemQueue<TVec2f>;
      TVec2fDataQ = TQueueTemplate<TVec2fItemQ>;
  private
    Fc: BSFloat;
    Fa: BSFloat;
    Fb: BSFloat;
    FAngle: BSFloat;
  protected
    procedure Reverse; override;
    procedure Update; override;
    procedure SetC(const Value: BSFloat);
    function GetC: BSFloat;
    function GetAngle: BSFloat;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Run; override;
    { Focal distance }
    property c: BSFloat read Fc write SetC;
    property a: BSFloat read Fa;
    property b: BSFloat read Fb;
    property Angle: BSFloat read FAngle;
  end;

  { TAniValueLawsInt }

  { TAniValueLawsInt32 }

  TAniValueLawsInt32 = class(TAniValueLawBase<int32>)
  private
    type
      TInt32ItemQ = TItemQueue<int32>;
      TInt32DataQ = TQueueTemplate<TInt32ItemQ>;
  protected
    procedure Reverse; override;
    procedure Update; override;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Run; override;
  end;

  { TAniValueLawsVec2f }

  TAniValueLawsVec2f = class(TAniValueLawBase<TVec2f>)
  private
    type
      TVec2fItemQ = TItemQueue<TVec2f>;
      TVec2fDataQ = TQueueTemplate<TVec2fItemQ>;
  protected
    procedure Reverse; override;
    procedure Update; override;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Run; override;
  end;

  { TAniValueLawsVec3f }

  TAniValueLawsVec3f = class(TAniValueLawBase<TVec3f>)
  private
    type
      TVec3fItemQ = TItemQueue<TVec3f>;
      TVec3fDataQ = TQueueTemplate<TVec3fItemQ>;
  protected
    procedure Reverse; override;
    procedure Update; override;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure Run; override;
  end;


{$region 'TAniValueLawBase<T>'}

{ TAniValueLawBase<T> }

constructor TAniValueLawBase<T>.Create(ThreadContext: TBThread);
begin
  inherited;
  FIntervalUpdate := 17;
  Reset;
end;

function TAniValueLawBase<T>.GetCurrentSender: Pointer;
begin
  Result := FCurrentSender;
end;

function TAniValueLawBase<T>.GetCurrentValue: T;
begin
  Result := FCurrentValue;
end;

function TAniValueLawBase<T>.GetDuration: int32;
begin
  Result := FDuration;
end;

function TAniValueLawBase<T>.GetLoop: boolean;
begin
  Result := FLoop;
end;

function TAniValueLawBase<T>.GetLoopInverse: boolean;
begin
  Result := FLoopInverse;
end;

function TAniValueLawBase<T>.GetStartValue: T;
begin
  Result := FStartValue;
end;

function TAniValueLawBase<T>.GetStopValue: T;
begin
  Result := FStopValue;
end;

procedure TAniValueLawBase<T>.Reset;
begin
  FLoop := false;
  FLoopInverse := false;
  TimeStart := 0;
  CurrentDeltaTime := 0;
  FCurrentSender := nil;
  LastTime := 0;
  //NodeList := nil;
end;

procedure TAniValueLawBase<T>.Run;
begin
  inherited Run;
  CurrentDeltaTime := 0;
  TimeStart := TBTimer.CurrentTime.Counter;
end;

procedure TAniValueLawBase<T>.Stop;
begin
  inherited;
end;

procedure TAniValueLawBase<T>.SetCurrentSender(Value: Pointer);
begin
  FCurrentSender := Value;
end;

procedure TAniValueLawBase<T>.SetDuration(Value: int32);
begin
  FDuration := Value;
end;

procedure TAniValueLawBase<T>.SetLoop(Value: boolean);
begin
  FLoop := Value;
end;

procedure TAniValueLawBase<T>.SetLoopInverse(Value: boolean);
begin
  FLoopInverse := Value;
end;

procedure TAniValueLawBase<T>.SetStartValue(const AValue: T);
begin
  FStartValue := AValue;
end;

procedure TAniValueLawBase<T>.SetStopValue(const AValue: T);
begin
  FStopValue := AValue;
end;

procedure TAniValueLawBase<T>.Reverse;
var
  v: T;
begin
  if FLoopInverse then
  begin
    v := FStartValue;
    FStartValue := FStopValue;
    FStopValue := v;
  end;
  TimeStart := TBTimer.CurrentTime.Counter;
  CurrentDeltaTime := 0;
end;

procedure TAniValueLawBase<T>.SendEvent(const Value: T);
begin
  if (not IsRun) or (FIntervalUpdate > TBTimer.CurrentTime.Counter - LastTime) then
    exit;
  LastTime := TBTimer.CurrentTime.Counter;
  { Send new event-value all subscribers }
  if (CurrentDeltaTime > FDuration) then
  begin // end animation
    FCurrentValue := FStopValue;
    inherited;
    if (FLoop) then
    begin
      { reverse animation }
      if FLoopInverse then
      begin
        //FStopValue := FStopValue;
      end;
      Reverse;
    end else
    begin
      AutoStop;
    end;
  end else
  begin
    FCurrentValue := Value;
    inherited;
  end;
end;

{$endregion}

{$region 'TAniValueLawFloat'}

{ TAniValueLawFloat }

procedure TAniValueLawFloat.Update;
var
  norm_time: BSFloat;
begin
  if not IsRun then
    exit;
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  norm_time := CurrentDeltaTime / FDuration;
  if norm_time > 1.0 then
    norm_time := 1.0;
  SendEvent(FStartValue + norm_time * FDelta);
end;

class function TAniValueLawFloat.GetQueueClass: TQueueWrapperClass;
begin
  Result := TBSFloatDataQ;
end;

procedure TAniValueLawFloat.Reverse;
begin
  inherited;
  if FLoopInverse then
    FDelta := -FDelta;
end;

procedure TAniValueLawFloat.Run;
begin
  inherited Run;
  FDelta := FStopValue - FStartValue;
end;

{$endregion}

{$region 'TAniValueLawsInt32'}

{ TAniValueLawsInt32 }

procedure TAniValueLawsInt32.Update;
var
  norm_time: BSFloat;
begin
  if not IsRun then
    exit;
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  norm_time := CurrentDeltaTime / FDuration;
  if norm_time > 1.0 then
    norm_time := 1.0;
  SendEvent(FStartValue + Round(FDelta * norm_time));
end;

class function TAniValueLawsInt32.GetQueueClass: TQueueWrapperClass;
begin
  Result := TInt32DataQ;
end;

procedure TAniValueLawsInt32.Reverse;
begin
  inherited;
  if FLoopInverse then
    FDelta := -FDelta;
end;

procedure TAniValueLawsInt32.Run;
begin
  inherited;
  FDelta := FStopValue - FStartValue;
end;
{$endregion}

{$region 'TAniValueLawsVec2f'}
{ TAniValueLawsVec2f }

procedure TAniValueLawsVec2f.Update;
var
  norm_time: BSFloat;
begin
  if not IsRun then
    exit;
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  norm_time := CurrentDeltaTime / FDuration;
  if norm_time > 1.0 then
    norm_time := 1.0;
  SendEvent(FStartValue + FDelta * norm_time);
end;

class function TAniValueLawsVec2f.GetQueueClass: TQueueWrapperClass;
begin
  Result := TVec2fDataQ;
end;

procedure TAniValueLawsVec2f.Reverse;
begin
  inherited;
  if FLoopInverse then
    FDelta := -FDelta;
end;

procedure TAniValueLawsVec2f.Run;
begin
  inherited;
  FDelta := FStopValue - FStartValue;
end;

{$endregion}

{$region 'TAniValueLawsVec3f'}
{ TAniValueLawsVec3f }

procedure TAniValueLawsVec3f.Update;
var
  norm_time: BSFloat;
begin
  if not IsRun then
    exit;
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  norm_time := CurrentDeltaTime / FDuration;
  SendEvent(FStartValue + FDelta * norm_time);
end;

class function TAniValueLawsVec3f.GetQueueClass: TQueueWrapperClass;
begin
  Result := TVec3fDataQ;
end;

procedure TAniValueLawsVec3f.Reverse;
begin
  inherited;
  if FLoopInverse then
    FDelta := -FDelta;
end;

procedure TAniValueLawsVec3f.Run;
begin
  inherited;
  FDelta := FStopValue - FStartValue;
end;
{$endregion}

{ TAniValueLawElipse }

procedure TAniValueLawElipse.Update;
var
  norm_time: BSFloat;
  v: TVec2f;
begin
  if not IsRun then
    exit;
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  norm_time := CurrentDeltaTime / FDuration;
  if norm_time > 1.0 then
    norm_time := 1.0;
  FAngle := norm_time * 360.0;
  v.x := Fa * BS_Cos(FAngle);
  v.y := Fb * BS_Sin(FAngle);
  SendEvent(v);
end;

function TAniValueLawElipse.GetAngle: BSFloat;
begin
  Result := FAngle;
end;

function TAniValueLawElipse.GetC: BSFloat;
begin
  Result := FC;
end;

class function TAniValueLawElipse.GetQueueClass: TQueueWrapperClass;
begin
  Result := TVec2fDataQ;
end;

procedure TAniValueLawElipse.Reverse;
begin
  inherited;
  if FLoopInverse then
    FDelta := -FDelta;
end;

procedure TAniValueLawElipse.Run;
begin
  inherited;
  FDelta := FStopValue - FStartValue;
end;

procedure TAniValueLawElipse.SetC(const Value: BSFloat);
begin
  Fc := Value;
  Fb := Fc / 2;
  Fa := (Fc / sqrt(2));
end;

function CreateAniFloatLinear(ThreadContext: TBThread): IBAnimationLinearFloat;
begin
  Result := TAniValueLawFloat.Create(ThreadContext);
end;

function CreateAniFloatLinear: IBAnimationLinearFloat;
begin
  Result := CreateAniFloatLinear(GUIThread);
end;


function CreateAniFloatLivearObsrv(const Animation: IBAnimationLinearFloat; OnRsvProc: TGenericRecieveProc<BSFloat>;
  ThreadContext: TBThread = nil): IBAnimationLinearFloatObsrv;
begin
  Result := BObserver<BSFloat>.Create(Animation as IBEvent<BSFloat>, ThreadContext);
  Result.OnRecieveData := OnRsvProc;
end;

function CreateAniElipse(ThreadContext: TBThread): IBAnimationElipse;
begin
  Result := TAniValueLawElipse.Create(ThreadContext);
end;

end.

