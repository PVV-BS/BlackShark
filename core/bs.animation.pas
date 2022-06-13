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
    function GetCurrentNormalizedTime: BSFloat;

    property Duration: int32 read GetDuration write SetDuration;
    property Loop: boolean read GetLoop write SetLoop;
    property LoopInverse: boolean read GetLoopInverse write SetLoopInverse;

    property StartValue: T read GetStartValue write SetStartValue;
    property StopValue: T read GetStopValue write SetStopValue;
    property CurrentValue: T read GetCurrentValue;
    { any user pointer }
    property CurrentSender: Pointer read GetCurrentSender write SetCurrentSender;
    property CurrentNormalizedTime: BSFloat read GetCurrentNormalizedTime;
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
    FCurrentNormalizedTime: BSFloat;
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
    procedure Update; override;

  public
    constructor Create(ThreadContext: TBThread);
    { Run calculate value in depend on time }
    procedure Run; override;
    procedure Stop; override;
    function GetCurrentNormalizedTime: BSFloat;
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

  IBAnimationPath3d = interface(IBAnimation<TVec3f>)
    procedure AddPoint(const AValue: TVec3f);
    function GetInterpolateSpline: TInterpolateSpline;
    procedure SetInterpolateSpline(AValue: TInterpolateSpline);
    function GetInterpolateFactor: BSFloat;
    procedure SetInterpolateFactor(AValue: BSFloat);
    function GetOrigins: TListVec<TVec3f>;
    function GetPointsInterpolated: TListVec<TVec3f>;
    property InterpolateSpline: TInterpolateSpline read GetInterpolateSpline write SetInterpolateSpline;
    property InterpolateFactor: BSFloat read GetInterpolateFactor write SetInterpolateFactor;
    property Origins: TListVec<TVec3f> read GetOrigins;
    property PointsInterpolated: TListVec<TVec3f> read GetPointsInterpolated;
  end;
  IBAnimationPath3dObsrv = IBObserver<TVec3f>;

  function CreateAniFloatLinear(ThreadContext: TBThread): IBAnimationLinearFloat; overload;
  function CreateAniFloatLinear: IBAnimationLinearFloat; overload;
  function CreateAniFloatLivearObsrv(const Animation: IBAnimationLinearFloat;
    OnRsvProc: TGenericRecieveProc<BSFloat>;
    ThreadContext: TBThread = nil): IBAnimationLinearFloatObsrv;

  function CreateAniElipse(ThreadContext: TBThread): IBAnimationElipse;

  function CreateAniPath3d(ThreadContext: TBThread): IBAnimationPath3d; overload;
  function CreateAniPath3d: IBAnimationPath3d; overload;


implementation

uses
    math
  ,	bs.mesh.primitives
  , bs.math
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

  { TAniPath3d }

  TAniPath3d = class(TAniValueLawBase<TVec3f>, IBAnimationPath3d)
  private type
    TVec3fItemQ = TItemQueue<TVec3f>;
    TVec3fDataQ = TQueueTemplate<TVec3fItemQ>;
    TIntrpFunc = procedure of object;
  private
    FuncIntrp: array [TInterpolateSpline] of TIntrpFunc;
    FOrigins: TListVec<TVec3f>;
    FPointsInterpolated: TListVec<TVec3f>;
    FInterpolateSpline: TInterpolateSpline;
    FInterpolateFactor: BSFloat;
    FIsBackPass: boolean;
    FCurrentIndexValue: int32;
    FCurrentDelta: TVec3f;
    FCurrentSnippetTimeStart: uint32;
    FCurrentPoint: TVec3f;
    FDurationSnippet: uint32;
    procedure SplineInterpolateBezier;
    procedure SplineInterpolateNone;
    procedure SplineInterpolateCubic;
    // https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Cardinal_spline
    procedure SplineInterpolateCubicHermite;
    procedure BuildPath;
  protected
    procedure Reverse; override;
    procedure Update; override;
    class function GetQueueClass: TQueueWrapperClass; override;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure Run; override;
    procedure AddPoint(const AValue: TVec3f);
    procedure Clear;

    function GetInterpolateSpline: TInterpolateSpline;
    procedure SetInterpolateSpline(AValue: TInterpolateSpline);
    function GetInterpolateFactor: BSFloat;
    procedure SetInterpolateFactor(AValue: BSFloat);
    function GetOrigins: TListVec<TVec3f>;
    function GetPointsInterpolated: TListVec<TVec3f>;

    property InterpolateSpline: TInterpolateSpline read GetInterpolateSpline write SetInterpolateSpline;
    property InterpolateFactor: BSFloat read GetInterpolateFactor write SetInterpolateFactor;
    property Origins: TListVec<TVec3f> read GetOrigins;
    property PointsInterpolated: TListVec<TVec3f> read GetPointsInterpolated;
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

function TAniValueLawBase<T>.GetCurrentNormalizedTime: BSFloat;
begin
  Result := FCurrentNormalizedTime;
end;

procedure TAniValueLawBase<T>.SetCurrentSender(Value: Pointer);
begin
  FCurrentSender := Value;
end;

procedure TAniValueLawBase<T>.Update;
begin
  CurrentDeltaTime := TBTimer.CurrentTime.Counter - TimeStart;
  FCurrentNormalizedTime := CurrentDeltaTime / FDuration;
  if FCurrentNormalizedTime > 1.0 then
    FCurrentNormalizedTime := 1.0;
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
var
  t: uint64;
begin
  t := TBTimer.CurrentTime.Counter;
  if (not IsRun) or (FIntervalUpdate > t - LastTime) then
  	exit;
  LastTime := t;
  { Send new event-value all subscribers }
  if (CurrentDeltaTime > FDuration) then
  begin // end animation
    FCurrentValue := FStopValue;
    FCurrentNormalizedTime := 1.0;
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
begin
  if not IsRun then
    exit;
  inherited;
  SendEvent(FStartValue + FCurrentNormalizedTime * FDelta);
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
begin
  if not IsRun then
    exit;
  inherited;
  SendEvent(FStartValue + Round(FDelta * FCurrentNormalizedTime));
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
begin
  if not IsRun then
    exit;
  inherited;
  SendEvent(FStartValue + FDelta * FCurrentNormalizedTime);
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
begin
  if not IsRun then
    exit;
  inherited;
  SendEvent(FStartValue + FDelta * FCurrentNormalizedTime);
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
  v: TVec2f;
begin
  if not IsRun then
    exit;
  inherited;
  FAngle := FCurrentNormalizedTime * 360.0;
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

{ TAniPath3d }

procedure TAniPath3d.AddPoint(const AValue: TVec3f);
begin
  FOrigins.Add(AValue);
end;

procedure TAniPath3d.AfterConstruction;
begin
  inherited;
  FOrigins := TListVec<TVec3f>.Create;
  FInterpolateSpline := isCubicHermite;
  FInterpolateFactor := 0.02;
  FuncIntrp[isNone        ] := SplineInterpolateNone;
  FuncIntrp[isBezier      ] := SplineInterpolateBezier;
  FuncIntrp[isCubic       ] := SplineInterpolateCubic;
  FuncIntrp[isCubicHermite] := SplineInterpolateCubicHermite;
  FPointsInterpolated := TListVec<TVec3f>.Create;
end;

procedure TAniPath3d.BuildPath;
begin
  FPointsInterpolated.Clear;
  if (FOrigins.Count > 1) then
    FuncIntrp[FInterpolateSpline]();
end;

procedure TAniPath3d.Clear;
begin
  FOrigins.Clear;
end;

destructor TAniPath3d.Destroy;
begin
  FOrigins.Free;
  FPointsInterpolated.Free;
  inherited;
end;

function TAniPath3d.GetInterpolateFactor: BSFloat;
begin
  Result := FInterpolateFactor;
end;

function TAniPath3d.GetInterpolateSpline: TInterpolateSpline;
begin
  Result := FInterpolateSpline;
end;

class function TAniPath3d.GetQueueClass: TQueueWrapperClass;
begin
  Result := TVec3fDataQ;
end;

procedure TAniPath3d.Reverse;
begin
  inherited;
  FIsBackPass := not FIsBackPass;
end;

procedure TAniPath3d.Run;
begin
  BuildPath;
  if FPointsInterpolated.Count = 0 then
  	exit;

  if GetLoopInverse then
  begin
    FCurrentIndexValue := FPointsInterpolated.Count-1;
    FCurrentPoint := FOrigins.Items[FCurrentIndexValue];
  	FCurrentDelta := FPointsInterpolated.Items[FPointsInterpolated.Count-2] - FCurrentPoint;
  end else
  begin
    FCurrentIndexValue := 0;
    FCurrentPoint := FOrigins.Items[FCurrentIndexValue];
    FCurrentDelta := FPointsInterpolated.Items[1] - FCurrentPoint;
  end;

  FDurationSnippet := round(GetDuration/FPointsInterpolated.Count);
  FCurrentSnippetTimeStart := TBTimer.CurrentTime.Counter;
  inherited;
end;

procedure TAniPath3d.SetInterpolateFactor(AValue: BSFloat);
begin
  FInterpolateFactor := clamp(1.0, 0.0001, AValue);
end;

function TAniPath3d.GetOrigins: TListVec<TVec3f>;
begin
  Result := FOrigins;
end;

function TAniPath3d.GetPointsInterpolated: TListVec<TVec3f>;
begin
	Result := FPointsInterpolated;
end;

procedure TAniPath3d.SetInterpolateSpline(AValue: TInterpolateSpline);
begin
  FInterpolateSpline := AValue;
end;

procedure TAniPath3d.SplineInterpolateBezier;
begin
  GenerateBezierSpline(PArrayVec3f(FOrigins.ShiftData[0]), FOrigins.Count, FPointsInterpolated, FInterpolateFactor);
end;

procedure TAniPath3d.SplineInterpolateCubic;
begin
  { GenerateCubicSpline is wrong for 3d, therefor uses GenerateCubicHermiteSpline instead }
  //GenerateCubicSpline(PArrayVec3f(FOrigins.ShiftData[0]), FOrigins.Count, FPointsInterpolated, FInterpolateFactor);
  GenerateCubicHermiteSpline(PArrayVec3f(FOrigins.ShiftData[0]), FOrigins.Count, FPointsInterpolated, FInterpolateFactor, false);
end;

procedure TAniPath3d.SplineInterpolateCubicHermite;
begin
  GenerateCubicHermiteSpline(PArrayVec3f(FOrigins.ShiftData[0]), FOrigins.Count, FPointsInterpolated, FInterpolateFactor, false);
end;

procedure TAniPath3d.SplineInterpolateNone;
begin
  FPointsInterpolated.Add(FOrigins.ShiftData[0], FOrigins.Count);
end;

procedure TAniPath3d.Update;
var
	v: TVec3f;
  currentSnippetDeltaTime: uint32;
  norm_time: BSFloat;
  currTime: uint32;
  newIndex: int32;
begin
  if not IsRun then
    exit;
	inherited;
  currTime := TBTimer.CurrentTime.Counter;

  newIndex := trunc(FCurrentNormalizedTime*(FPointsInterpolated.Count-1));
  if FIsBackPass then
  	newIndex := FPointsInterpolated.Count - 1 - newIndex;

  //if newIndex >= 10 then
  //	newIndex := newIndex;

  if newIndex <> FCurrentIndexValue then
  begin
    FCurrentIndexValue := newIndex;
    if FIsBackPass then
    begin
      if FCurrentIndexValue < 2 then
      begin
        CurrentDeltaTime := GetDuration+1;
  		  SendEvent(FPointsInterpolated.Items[0]);
        exit;
      end;
      FCurrentPoint := FPointsInterpolated.Items[FCurrentIndexValue];
      FCurrentDelta := FPointsInterpolated.Items[FCurrentIndexValue-1]-FCurrentPoint;
    end else
    begin
      if FCurrentIndexValue > FPointsInterpolated.Count - 2 then
      begin
        CurrentDeltaTime := GetDuration+1;
			  SendEvent(FPointsInterpolated.Items[FPointsInterpolated.Count-1]);
    	  exit;
  	  end;
      FCurrentPoint := FPointsInterpolated.Items[FCurrentIndexValue];
      FCurrentDelta := FPointsInterpolated.Items[FCurrentIndexValue+1]-FCurrentPoint;
    end;
    FCurrentSnippetTimeStart := currTime;
  end;

  currentSnippetDeltaTime := currTime - FCurrentSnippetTimeStart;
  norm_time := currentSnippetDeltaTime / FDurationSnippet;
  if norm_time > 1.0 then
    norm_time := 1.0;
  v := FCurrentPoint + FCurrentDelta * norm_time;
  SendEvent(v);

end;

function CreateAniPath3d(ThreadContext: TBThread): IBAnimationPath3d;
begin
	Result := TAniPath3d.Create(ThreadContext);
end;

function CreateAniPath3d: IBAnimationPath3d;
begin
  Result := TAniPath3d.Create(GUIThread);
end;

end.

