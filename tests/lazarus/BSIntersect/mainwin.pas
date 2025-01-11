unit MainWin;

{$mode Delphi}

interface

uses
{$IFDEF UNIX}
 cthreads, cmem,
{$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls,

  bs.basetypes,
  bs.viewport,
  bs.gl.context,
  bs.canvas,
  bs.gui.buttons,
  bs.thread,
  bs.events,
  bs.scene,
  Types;

type

  { TMainW }

  TMainW = class(TForm)
   CreateBtn: TButton;
   AutoBtn: TButton;
   RepaintTimer: TTimer;
   StatusBar1: TStatusBar;
   ZPlusBtn: TButton;
   ZMinusBtn: TButton;
   XPlusBtn: TButton;
   XMinusBtn: TButton;
   YPlusBtn: TButton;
   YMinusBtn: TButton;
   PanelScreen: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure AutoBtnClick(Sender: TObject);
    procedure CreateClick(Sender: TObject);
    procedure RepaintTimerTimer(Sender: TObject);

    procedure ZPlusBtnClick(Sender: TObject);
    procedure ZMinusBtnClick(Sender: TObject);
    procedure XPlusBtnClick(Sender: TObject);
    procedure XMinusBtnClick(Sender: TObject);
    procedure YPlusBtnClick(Sender: TObject);
    procedure YMinusBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
   fNeedRepaint:boolean;
   fViewPort:TBlackSharkViewPort;
   fBCanvas:TBCanvas;
   fDraftHolder: TRectangle;
   fLayoutCurve :TPath;

   MouseStartPos: TVec2i;
   FrustumStartPos: TVec3f;
   FrustumStartAngle: TVec3f;
   QuaternionStart: TQuaternion;

   FStartFrustumPosition: TVec3f;
   FPositionDelta: TVec3f;

   ObsrvMouseWeel: IBMouseEventObserver;
   ObsrvMouseDown: IBMouseEventObserver;
   ObsrvMouseMove: IBMouseEventObserver;
   ObsrvMouseUp: IBMouseEventObserver;

   procedure OnRendererMouseWeel(const AData: BMouseData);
   procedure OnRendererMouseDown(const AData: BMouseData);
   procedure OnRendererMouseMove(const AData: BMouseData);
   procedure OnRendererMouseUp(const AData: BMouseData);
   procedure OnRendererFrustumMove(const AValue: BSFloat);

   procedure CurveSetColors(IndexFrom, IndexTo: int32; aValue: TColor4f);
   procedure InitCanvasStage2(Sender: TObject);
  end;

var
  MainW: TMainW;

implementation

uses
  bs.config,
  bs.math;

{$R *.lfm}

{ TMainW }

procedure TMainW.FormCreate(Sender: TObject);
begin
 fNeedRepaint:=false;
 //GraphManager:=TGraphManager.Create;
 BSConfig.MultiSampling := false;
 BSConfig.MaxFps := false;

 //GraphManager.InitCanvasStage1(PanelScreen);
 PanelScreen.OnMouseMove:=nil;
 PanelScreen.OnEnter:=nil;
 PanelScreen.OnExit:=nil;
 fViewPort := TBlackSharkViewPort.Create(PanelScreen);
 fViewPort.OnMouseMove:=nil;
 fViewPort.OnMouseDown:=nil;
 fViewPort.OnMouseUp:=nil;
 fViewPort.OnEnter:=nil;
 fViewPort.OnExit:=nil;

 fViewPort.Align := alClient;

 fViewPort.OnAfterCreateContext:=InitCanvasStage2;
end;

procedure TMainW.InitCanvasStage2(Sender: TObject);
begin
 assert(assigned(fViewPort),'ViewPort not assigned');
 assert(assigned(fViewPort.Renderer),'ViewPort.Renderer not assigned');
 if not assigned(fViewPort) or
    not assigned(fViewPort.Renderer) then exit;

 fViewPort.Renderer.Color := BS_CL_BLACK;
 fViewPort.Renderer.Frustum.OrthogonalProjection:=false;
 //fViewPort.Renderer.Frustum.DistanceNearPlane:=0.001;
// fViewPort.Renderer.Frustum.Position:=vec3(0.0, 0.0, 4.0);

 ObsrvMouseWeel := fViewPort.Renderer.EventMouseWeel.CreateObserver(OnRendererMouseWeel);
 ObsrvMouseDown := fViewPort.Renderer.EventMouseDown.CreateObserver(OnRendererMouseDown);
 ObsrvMouseMove := fViewPort.Renderer.EventMouseMove.CreateObserver(OnRendererMouseMove);
 ObsrvMouseUp := fViewPort.Renderer.EventMouseUp.CreateObserver(OnRendererMouseUp);

 fBCanvas := TBCanvas.Create(fViewPort.Renderer, nil);
 fBCanvas.CreateEmptyCanvasObject.Position2d := vec2(0.0, 0.0);
 fBCanvas.StickOnScreen := false;

 fDraftHolder := TRectangle.Create(fBCanvas, nil);
 fDraftHolder.Size := vec2(fViewPort.Renderer.WindowWidth, fViewPort.Renderer.WindowHeight);
 fDraftHolder.Fill := true;

 //fDraftHolder.Data.Opacity := 0.2;
 //fDraftHolder.Data.Interactive := false;
 fDraftHolder.Build;

 fLayoutCurve:=TPath.Create(fBCanvas,fDraftHolder);

 fNeedRepaint:=true;

 RepaintTimer.Interval:=50;
 RepaintTimer.Enabled:=true;
end;

procedure TMainW.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 if assigned(fLayoutCurve) then
  fLayoutCurve.Clear;
 FreeAndNil(fLayoutCurve);
 FreeAndNil(fDraftHolder);
 FreeAndNil(fBCanvas);
 FreeAndNil(fViewPort);
end;

procedure TMainW.CurveSetColors(IndexFrom, IndexTo: int32; aValue: TColor4f);
var
 i:integer;
 c:TColor4f;
 IndexFrom2:int32;
begin
 IndexFrom2:=IndexTo+1;

 for i := IndexFrom to IndexTo do
   fLayoutCurve.WriteColorToPoint(i,aValue);

  for i := IndexFrom2+3 to IndexTo do
   fLayoutCurve.WriteColorToPoint(i,aValue);
end;

procedure TMainW.CreateClick(Sender: TObject);
var
 i:dword;
begin
 //fViewPort.Renderer.Frustum.DistanceNearPlane:=0.001;
 //fViewPort.Renderer.Frustum.Position:=vec3(0.0, 0.0, 4.0);

 fLayoutCurve.AddPoint(vec2(0.00, 100.00), BS_CL_RED);
 fLayoutCurve.AddPoint(vec2(100.00, 100.00), BS_CL_RED);
 fLayoutCurve.AddPoint(vec2(100.00, 0.00), BS_CL_RED);
 fLayoutCurve.AddPoint(vec2(0.00, 0.00), BS_CL_RED);

 fLayoutCurve.Data.SceneSpaceTreeClient := true;
 fLayoutCurve.Build;
 fLayoutCurve.Data.BaseInstance.Interactive:=false;

 fDraftHolder.Size := vec2(fLayoutCurve.Width, fLayoutCurve.Height);
// fDraftHolder.Angle:=vec3(0.0, 0.0, 0.0);
 fDraftHolder.Build;
 fLayoutCurve.Position2d := vec2(0.0, 0.0);

 //костыль, правильная перерисовка цвета
 for i:=1 to  fLayoutCurve.CountPoints-1 do
   CurveSetColors(i, i+1, BS_CL_RED);
 fLayoutCurve.Data.ChangedMesh;

 fViewPort.Draw;
 //AutoBtnClick(nil);
end;

procedure TMainW.RepaintTimerTimer(Sender: TObject);
begin
 if Application.Terminated then exit;
 if not fNeedRepaint then exit;

 fViewPort.Draw;
 fNeedRepaint:=false;
end;

procedure TMainW.AutoBtnClick(Sender: TObject);
var
  kx, ky, k, d, z: BSFloat;
  i: int32;
  FUnionBB:TBox3f;
  FStopPosition: TVec3f;
begin
  FUnionBB := fDraftHolder.Data.BaseInstance^.BoundingBox;
  with FUnionBB do
   Middle := (Max + Min) * 0.5;

  kx := (FUnionBB.x_max - FUnionBB.x_min)/fViewPort.Renderer.Frustum.NearPlaneWidth;
  ky := (FUnionBB.y_max - FUnionBB.y_min)/fViewPort.Renderer.Frustum.NearPlaneHeight;
  if kx > ky then
  begin
    k := fViewPort.Renderer.Frustum.DistanceNearPlane/(fViewPort.Renderer.Frustum.NearPlaneWidth*0.5);
    z := (FUnionBB.x_max - FUnionBB.x_min)*0.5*k;
  end else
  begin
    k := fViewPort.Renderer.Frustum.DistanceNearPlane/(fViewPort.Renderer.Frustum.NearPlaneHeight*0.5);
    z := (FUnionBB.y_max - FUnionBB.y_min)*0.5*k;
  end;

  FStopPosition :=
   PlanePointProjection(Plane(vec3(0.0, 0.0, -1.0),
                              vec3(0.0, 0.0, fViewPort.Renderer.Frustum.DistanceNearPlane)),
                        FUnionBB.Middle, d);
  FStopPosition.z := z + fViewPort.Renderer.Frustum.DISTANCE_2D_SCREEN;
  FStopPosition.z := FStopPosition.z*1.03;
  fViewPort.Renderer.Frustum.Position:=FStopPosition;

  fNeedRepaint:=true;
end;

procedure TMainW.ZPlusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.z:=p.z/1.1;
 fViewPort.Renderer.Frustum.Position:=p;
//MyInvalidate;
 fViewPort.Draw;
end;

procedure TMainW.ZMinusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.z:=p.z*1.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.XPlusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.x:=p.x+0.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.XMinusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.x:=p.x-0.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.YPlusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.y:=p.y+0.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.YMinusBtnClick(Sender: TObject);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 p.y:=p.y-0.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.OnRendererMouseWeel(const AData: BMouseData);
var
 p:TVec3f;
begin
 p:=fViewPort.Renderer.Frustum.Position;
 if AData.DeltaWeel>0 then
  p.z:=p.z/1.1
 else
  p.z:=p.z*1.1;
 fViewPort.Renderer.Frustum.Position:=p;
 fNeedRepaint:=true;
end;

procedure TMainW.OnRendererMouseDown(const AData: BMouseData);
begin
 FrustumStartPos := fViewPort.Renderer.Frustum.Position;
 FrustumStartAngle := fViewPort.Renderer.Frustum.Angle;
 QuaternionStart := fViewPort.Renderer.Frustum.Quaternion;
 MouseStartPos := vec2(AData.X, AData.Y);
end;

procedure TMainW.OnRendererMouseMove(const AData: BMouseData);
var
 delta: TVec3f;
begin
  if fViewPort.Renderer.MouseIsDown then
  begin
    if fViewPort.Renderer.MouseButtonKeep = TBSMouseButton.mbBsLeft then
     begin
      with fViewPort.Renderer do
       delta := Frustum.RotateMatrixInv*ScreenSizeToScene(MouseNowPos - MouseStartPos);
      delta.x:=-delta.x*FrustumStartPos.z;
      delta.y:=delta.y*FrustumStartPos.z;
      fViewPort.Renderer.Frustum.Position := FrustumStartPos + delta;
     end;
  end;
end;

procedure TMainW.OnRendererMouseUp(const AData: BMouseData);
var
 IntersectPoint: TVec2f;
 //Intersect: boolean;
 //Distance: BSFloat;
 //thePlane: TVec4f;
 //Ray:TRay3f;
begin
// StatusBar1.SimpleText:='X='+IntToStr(AData.X)+
//                        ' Y='+IntToStr(AData.Y);
 if MouseStartPos=vec2(AData.X, AData.Y) then
  begin
   //thePlane:=plane(vec3(0.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0));
   //thePlane:=Plane(vec3(0.0, 0.0, -1.0),
   //                vec3(0.0, 0.0, 0.0));
   //Ray:=fViewPort.Renderer.MakeRay(aData.X, aData.Y);
   //
   //IntersectPoint:=
   // PlaneCrossProduct(thePlane,
   // fViewPort.Renderer.Frustum.Position,
   // Ray.Direction,
   // Intersect, Distance)/BSConfig.VoxelSize;//*1.06;

   IntersectPoint := fDraftHolder.Get2dPositionInsideSelf(aData.X, aData.Y);

   StatusBar1.SimpleText:='X='+Format('%01.2f',[IntersectPoint.x])+
                         ' Y='+Format('%01.2f',[IntersectPoint.y]);
//   if Intersect then

   end
end;

procedure TMainW.OnRendererFrustumMove(const AValue: BSFloat);
begin
  fViewPort.Renderer.Frustum.Position := FStartFrustumPosition + FPositionDelta*AValue;
  fViewPort.Draw;
  if AValue = 1.0 then
    BSConfig.MaxFps := false;
end;

end.

