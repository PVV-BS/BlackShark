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
unit bs.scene.skeleton;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.collections
  , bs.scene
  , bs.scene.objects
  , bs.shader
  , bs.texture
  , bs.renderer
  , bs.mesh
  , bs.math
  , bs.animation
  ;

type

  TBone = class;
  TSkeleton = class;
  TSkeletonAnimation = class;
  TBoneClass = class of TBone;

  TVertexBind = record
    VertexIndex: int32;
    Weight: BSFloat;
    class function VertexBind(AVertexIndex: int32; AWeight: BSFloat): TVertexBind; static;
  end;

  PBoneKeyFrame = ^TBoneKeyFrame;
  TBoneKeyFrame = record
    Position: TVec3f;
    Rotation: TVec4f;
    // TODO:
    Scale: TVec3f;
    Interpolation: TInterpolateSpline;
  end;

  TListBones = TListVec<TBone>;
  TTableBones = THashTable<string, TBone>;
  TListBoundVertexes = TListVec<TVertexBind>;

  TBone = class
  private
    FChildren: TListBones;
    FBoundVertexes: TListBoundVertexes;
    FIndex: uint8;
    FTransform: TMatrix4f;
    FStackTransform: TMatrix4f;
    FCurrentTransform: TMatrix4f;
    FCurrentStackTransform: TMatrix4f;
    FStackTransformInv: TMatrix4f;
    FTip: TVec3f;
    FGraphicObject: TGraphicObject;
    FSkeleton: TSkeleton;
    FParent: TBone;
    FCaption: string;
    FChildConnected: TBone;
    FCountAnimations: int32;
    procedure SetTransform(const Value: TMatrix4f);
    procedure UpdateTransform;
    procedure UpdateStackTransform;
    procedure UpdateCurrentTransform;
    procedure UpdateCurrentStackTransform;
    procedure UpdateViewPosition; inline;
    procedure SetTip(const Value: TVec3f);
    procedure AddChild(AChild: TBone);
    procedure RemoveChild(AChild: TBone);
    function GetChildrenCount: int32;
    function GetChildren(Index: int32): TBone;
    procedure SetCurrentTransform(const Value: TMatrix4f);
  public
    constructor Create(ASkeleton: TSkeleton; AParent: TBone);
    destructor Destroy; override;
    procedure DeleteChildren;
    { create a graphic object of the bone }
    procedure BuildView;
    procedure HideView;
    function HasAnimatedParent: boolean;
    procedure BindVertex(AVertexIndex: int32; AWeight: BSFloat);
    property BoundVertexes: TListBoundVertexes read FBoundVertexes;
    property CountAnimations: int32 read FCountAnimations write FCountAnimations;
    property Transform: TMatrix4f read FTransform write SetTransform;
    property StackTransform: TMatrix4f read FStackTransform;
    property StackTransformInv: TMatrix4f read FStackTransformInv;
    property CurrentTransform: TMatrix4f read FCurrentTransform write SetCurrentTransform;
    property CurrentStackTransform: TMatrix4f read FCurrentStackTransform;
    property Tip: TVec3f read FTip write SetTip;
    property ChildConnected: TBone read FChildConnected write FChildConnected;
    property GraphicObject: TGraphicObject read FGraphicObject;
    property Parent: TBone read FParent;
    property Caption: string read FCaption write FCaption;
    property Skeleton: TSkeleton read FSkeleton;
    property ChildrenCount: int32 read GetChildrenCount;
    property Children[Index: int32]: TBone read GetChildren;
    property Index: uint8 read FIndex write FIndex;
  end;

  PSkeletonFrame = ^TSkeletonFrame;
  TSkeletonFrame = record
    Time: uint32;
    FrameBones: array of PBoneKeyFrame;
  end;

  TListFrames = TListVec<PSkeletonFrame>;
  TTableAnimations = THashTable<string, TSkeletonAnimation>;
  TListBoneMatrixes = TListVec<TMatrix4f>;

  TSkeletonAnimation = class
  private
    FName: string;
    FFrames: TListFrames;
    FDuration: uint32;
    FBones: TListBones;
    FOwner: TSkeleton;
    procedure Clear;
  public
    constructor Create(const AName: string; AOwner: TSkeleton);
    destructor Destroy; override;
    function CreateKeyFrame(ABone: TBone; ATime: uint32; const AMatrix: TMatrix4f; AInterpolation: TInterpolateSpline): int32;
    function HasBone(ABone: TBone): boolean;
    property Name: string read FName;
    property Frames: TListFrames read FFrames;
    property Duration: uint32 read FDuration;
    property Bones: TListBones read FBones;
  end;

  {
    TSkeleton
    Consists of bones and linked Skin;
  }

  TSkeleton = class
  private
    FRenderer: TBlackSharkRenderer;
    FBones: TTableBones;
    FAnimations: TTableAnimations;
    FAnimation: string;
    FCurrentAnimation: TSkeletonAnimation;
    FSkin: TGraphicObject;
    FSkinShaderAnim: TBlackSharkShader;
    FSkinIsStaticObject: boolean;
    FSkinDrawInstanceMethod: TDrawInstanceMethod;
    FSkinMeshCopy: TMesh;
    FSkinMesh: TMesh;
    FCurrentFrame: int32;
    FStartTime: uint32;
    FCalculateOnGPU: boolean;
    FPauseAnimation: boolean;
    FSkinCenterOffset: TVec3f;
    FShowBones: boolean;
    FOwner: TObject;
    FCaption: string;
    FPosition: TVec3f;
    Roots: TListBones;
    FCurrentTrasforms: TListBoneMatrixes;
    CurrentTransformsUniform: PShaderParametr;
    FParentTransforms: TMatrix4f;
    FAniUpdater: IBAnimationLinearFloat;
    FAniUpdaterObserver: IBAnimationLinearFloatObsrv;
    procedure SetAnimation(const Value: string);
    procedure FindRoots;
    procedure DoStartAnimation;
    procedure DoStopAnimation;
    procedure SetSkin(const Value: TGraphicObject);
    procedure BeforeDrawObject({%H-}Item: TGraphicObject);
    procedure LinkBonesToVertexes;
    procedure DoRecalcAnimation; inline;
    procedure RecalcAnimation; inline;
    procedure SetPauseAnimation(const Value: boolean);
    procedure UpdateLinkedVertexes(ABone: TBone);
    procedure UpdateBoneTransform(ABone: TBone);
    procedure CheckAnimation;
    procedure SetShowBones(const Value: boolean);
    procedure DoShowBones;
    procedure DoHideBones;
    procedure SetPosition(const Value: TVec3f);
    procedure UpdateBonesTransform;
    procedure SetParentTransforms(const Value: TMatrix4f);
    procedure OnUpdate(const {%H-}AValue: BSFloat);
  public
    constructor Create(AOwner: TObject; ARenderer: TBlackSharkRenderer);
    destructor Destroy; override;
    function CreateBone(const AName, ASID: string; AParent: TBone): TBone; overload;
    function CreateBone(const AName, ASID: string; AParent: TBone; ABoneClass: TBoneClass): TBone; overload;
    function CreateAnimation(const AName: string): TSkeletonAnimation;

    property Renderer: TBlackSharkRenderer read FRenderer;
    property Animation: string read FAnimation write SetAnimation;
    property Animations: TTableAnimations read FAnimations;
    property CurrentAnimation: TSkeletonAnimation read FCurrentAnimation;
    property PauseAnimation: boolean read FPauseAnimation write SetPauseAnimation;
    property Bones: TTableBones read FBones;
    property ShowBones: boolean read FShowBones write SetShowBones;
    property Skin: TGraphicObject read FSkin write SetSkin;
    property SkinCenterOffset: TVec3f read FSkinCenterOffset;
    property SkinMeshCopy: TMesh read FSkinMeshCopy;
    property CalculateOnGPU: boolean read FCalculateOnGPU write FCalculateOnGPU;
    property Caption: string read FCaption write FCaption;
    property Position: TVec3f read FPosition write SetPosition;
    property ParentTransforms: TMatrix4f read FParentTransforms write SetParentTransforms;
  end;

implementation

uses
  {$ifndef fpc}
    System.Classes,
  {$endif}
  {$ifdef DEBUG_BS}
    bs.utils,
  {$endif}
    SysUtils
  , math
  , bs.config
  , bs.gl.es
  , bs.graphics
  , bs.obj
  , bs.mesh.primitives
  , bs.thread
  , bs.exceptions
  ;

{ TSkeleton }

procedure TSkeleton.LinkBonesToVertexes;
var
  i, j: int32;
  bs: TVec3f;
  ws: TVec3f;
  bones: TListVec<TVec3f>;
  weights: TListVec<TVec3f>;
  v_bind: TVertexBind;
  bone: TBone;
begin
  bones := TListVec<TVec3f>.Create;
  bones.DefaultValue := vec3(TBlackSharkSkeletonShader.MAX_COUNT_BONES, 255.0, 255.0);
  bones.Count := FSkin.Mesh.CountVertex;
  weights := TListVec<TVec3f>.Create;
  weights.DefaultValue := vec3(0.0, 0.0, 0.0);
  weights.Count := FSkin.Mesh.CountVertex;
  FSkin.Mesh.AddComponent(vcBones, COMPONENTS_SIZE_OF[vcBones], COMPONENTS_VARS[vcBones]);
  FSkin.Mesh.AddComponent(vcWeights, COMPONENTS_SIZE_OF[vcWeights], COMPONENTS_VARS[vcWeights]);
  for j := 0 to FCurrentAnimation.Bones.Count - 1 do
  begin
    bone := FCurrentAnimation.Bones.Items[j];
    for i := 0 to bone.BoundVertexes.Count - 1 do
    begin
      v_bind := bone.BoundVertexes.Items[i];
      if v_bind.Weight < 0.1 then
        continue;
      bs := bones.Items[v_bind.VertexIndex];
      ws := weights.Items[v_bind.VertexIndex];
      if bs.x < TBlackSharkSkeletonShader.MAX_COUNT_BONES then
      begin
        if bs.y < TBlackSharkSkeletonShader.MAX_COUNT_BONES then
        begin
          bs.z := bone.Index;
          ws.z := v_bind.Weight;
          if ws.z > ws.y then
          begin
            swap(ws.z, ws.y);
            swap(bs.z, bs.y);
            if ws.y > ws.x then
            begin
              swap(ws.x, ws.y);
              swap(bs.x, bs.y);
            end;
          end;
        end else
        begin
          bs.y := bone.Index;
          ws.y := v_bind.Weight;
          if ws.y > ws.x then
          begin
            swap(ws.x, ws.y);
            swap(bs.x, bs.y);
          end;
        end;
      end else
      begin
        bs.x := bone.Index;
        ws.x := v_bind.Weight;
      end;
      bones.Items[v_bind.VertexIndex] := bs;
      weights.Items[v_bind.VertexIndex] := ws;
    end;
  end;

  for i := 0 to FSkin.Mesh.CountVertex - 1 do
  begin
    bs := bones.Items[i];
    //if bs.x >= TBlackSharkSkeletonShader.MAX_COUNT_BONES then
    //  raise EBlackShark.Create(Format('The vertex %d has not been linked!', [i]));
    FSkin.Mesh.Write(i, TVertexComponent.vcBones, bs);
    FSkin.Mesh.Write(i, TVertexComponent.vcWeights, VecNormalize(weights.Items[i]));
  end;

  FSkin.ChangedMesh;
  bones.Free;
  weights.Free;
end;

procedure TSkeleton.RecalcAnimation;
begin
  if FPauseAnimation then
    exit;
  DoRecalcAnimation;
end;

procedure TSkeleton.BeforeDrawObject(Item: TGraphicObject);
var
  duration: BSFloat;
  frame: PSkeletonFrame;
  i: int32;
begin
  duration := TBTimer.CurrentTime.Low - FStartTime;
  if duration < FCurrentAnimation.Duration then
  begin
    for i := FCurrentFrame + 1 to FCurrentAnimation.Frames.Count - 1 do
    begin
      frame := FCurrentAnimation.Frames.Items[i];
      if (frame.Time > duration) then
        break;
      inc(FCurrentFrame);
    end;
  end else
  begin
    FStartTime := TBTimer.CurrentTime.Low;
    FCurrentFrame := 0;
  end;

  RecalcAnimation;
  if FCalculateOnGPU and Assigned(CurrentTransformsUniform) then
    glUniformMatrix4fv(CurrentTransformsUniform.Location, FCurrentTrasforms.Count, GL_FALSE, FCurrentTrasforms.ShiftData[0]);
  { enforce to update the timer in order to off an application idle }
  if not BSConfig.MaxFps then
     TBTimer.UpdateTimer(TTimeProcessEvent.TimeProcessEvent);
end;

procedure TSkeleton.CheckAnimation;
begin
  if (FAnimation = '') or (FPauseAnimation) then
    DoStopAnimation
  else
    DoStartAnimation;
end;

constructor TSkeleton.Create(AOwner: TObject; ARenderer: TBlackSharkRenderer);
begin
  FOwner := AOwner;
  FRenderer := ARenderer;
  FPauseAnimation := true;
  FBones := TTableBones.Create(@GetHashBlackSharkS, @StrCmpBool);
  FAnimations := TTableAnimations.Create(@GetHashBlackSharkS, @StrCmpBool);
  Roots := TListBones.Create;
  FCurrentTrasforms := TListBoneMatrixes.Create;
  FParentTransforms := IDENTITY_MAT;
end;

function TSkeleton.CreateAnimation(const AName: string): TSkeletonAnimation;
begin
  if FAnimations.Find(AName, Result) then
    exit;

  Result := TSkeletonAnimation.Create(AName, Self);
  FAnimations.Items[AName] := Result;
end;

function TSkeleton.CreateBone(const AName, ASID: string; AParent: TBone; ABoneClass: TBoneClass): TBone;
begin
  //if FBones.Count = TBlackSharkSkeletonShader.MAX_COUNT_BONES then
  //  raise ELimitReached.Create(Format('Count bones are limited by %d', [TBlackSharkSkeletonShader.MAX_COUNT_BONES]));

  Result := ABoneClass.Create(Self, AParent);

  Result.Caption := AName;
  Result.Index := FBones.Count;

  FBones.Items[ASID] := Result;
end;

function TSkeleton.CreateBone(const AName, ASID: string; AParent: TBone): TBone;
begin
  Result := CreateBone(AName, ASID, AParent, TBone);
end;

destructor TSkeleton.Destroy;
var
  bucket: TTableAnimations.TBucket;
  bone_backet: TTableBones.TBucket;
begin
  if FAnimation <> '' then
    DoStopAnimation;

  if FBones.GetFirst(bone_backet) then
  repeat
    if not Assigned(bone_backet.Value.Parent) then
      bone_backet.Value.Free;
  until not FBones.GetNext(bone_backet);

  if FAnimations.GetFirst(bucket) then
  repeat
    bucket.Value.Free;
  until not FAnimations.GetNext(bucket);

  Roots.Free;
  FAnimations.Free;
  FBones.Free;
  FCurrentTrasforms.Free;
  inherited;
end;

procedure TSkeleton.DoStartAnimation;
begin
  if not FAnimations.Find(FAnimation, FCurrentAnimation) then
    exit;

  if FBones.Count >= TBlackSharkSkeletonShader.MAX_COUNT_BONES then
    FCalculateOnGPU := false;

  FCurrentFrame := 0;
  FindRoots;
  FSkin.AddBeforeDrawMethod(BeforeDrawObject);
  if FCalculateOnGPU then
  begin
    FSkinShaderAnim := FSkin.Shader;
    FSkinShaderAnim._AddRef;
    if FSkin.Mesh.HasComponent(TVertexComponent.vcTexture1) then
    begin
      FSkin.Shader := BSShaderManager.Load('', TBlackSharkSkeletonTexturedShader, true)
    end else
      FSkin.Shader := BSShaderManager.Load('', TBlackSharkSingleColorAniShader, true);

    {$ifdef DEBUG_BS}
    CheckErrorGL('TSkeleton.DoAnimation', TTypeCheckError.tcProgramm, FSkin.Shader.ProgramID);
    {$endif}
    CurrentTransformsUniform := FSkin.Shader.Uniform['CurrentTransforms'];
    LinkBonesToVertexes;
  end else
  begin
    FSkinIsStaticObject := FSkin.StaticObject;
    FSkin.StaticObject := false;
    FSkinMeshCopy := FSkin.Mesh.Copy;
    FSkinMesh := FSkin.Mesh;
    FSkin.Mesh := FSkinMeshCopy;
  end;

  FStartTime := TBTimer.CurrentTime.Low;
  if not BSConfig.MaxFps then
  begin
    // the animation need only as task in order to indicate that need to redraw with max FPS
    FAniUpdater := CreateAniFloatLinear;
    FAniUpdater.IntervalUpdate := 1000;
    FAniUpdater.Duration := 1000;
    FAniUpdater.Loop := true;
    FAniUpdaterObserver := FAniUpdater.CreateObserver(OnUpdate);
    FAniUpdater.Run;
  end else
    TBTimer.UpdateTimer(TTimeProcessEvent.TimeProcessEvent);
end;

procedure TSkeleton.DoHideBones;
var
  bucket: TTableBones.TBucket;
begin
  if FBones.GetFirst(bucket) then
  repeat
    bucket.Value.HideView;
  until not FBones.GetNext(bucket);
end;

procedure TSkeleton.DoRecalcAnimation;
var
  i: int32;
  frame: PSkeletonFrame;
  frame_next: PSkeletonFrame;
  frameBone: PBoneKeyFrame;
  frameBoneNext: PBoneKeyFrame;
  m: TMatrix4f;
  norm_time: BSFloat;
  delta_pos: TVec3f;
  delta_rot: TVec4f;
  duration: uint32;
  bone: TBone;
begin
  frame := FCurrentAnimation.Frames.Items[FCurrentFrame];
  frame_next := FCurrentAnimation.Frames.Items[FCurrentFrame+1];

  duration := TBTimer.CurrentTime.Low - FStartTime;
  if duration < frame.Time then
    duration := frame.Time;

  norm_time := bs.math.Clamp(1.0, 0.0, (duration - frame.Time) / (frame_next.Time - frame.Time));

  if not FCalculateOnGPU then
    FSkinMeshCopy.Fill(vec3(0.0, 0.0, 0.0));

  for i := 0 to length(frame.FrameBones) - 1 do
  begin
    frameBone := frame.FrameBones[i];
    frameBoneNext := frame_next.FrameBones[i];
    if Assigned(frameBone) then
    begin

      if Assigned(frameBoneNext) then
      begin
        delta_pos := frameBone.Position + TVec3f(frameBoneNext.Position - frameBone.Position)*norm_time;
        delta_rot := QuaternionNLERP(frameBone.Rotation, frameBoneNext.Rotation, norm_time);
      end else
      begin
        delta_pos := TVec3f(frameBone.Position);
        delta_rot := frameBone.Rotation;
      end;

      bone := FCurrentAnimation.Bones.Items[i];
      QuaternionToMatrix(m{%H-}, delta_rot);

      if Assigned(bone.Parent) then
      begin
        m.M3 := vec4(delta_pos, 1.0);
      end else
      begin
        m.M3 := vec4(delta_pos - SkinCenterOffset, 1.0);
      end;

      bone.CurrentTransform := m;
    end;
  end;

  for i := 0 to Roots.Count - 1 do
  begin
    if FCalculateOnGPU then
      UpdateBoneTransform(Roots.Items[i])
    else
      UpdateLinkedVertexes(Roots.Items[i]);
  end;

end;

procedure TSkeleton.DoShowBones;
var
  bucket: TTableBones.TBucket;
begin
  if FBones.GetFirst(bucket) then
  repeat
    if not Assigned(bucket.Value.Parent) then
      bucket.Value.BuildView;
  until not FBones.GetNext(bucket);
end;

procedure TSkeleton.DoStopAnimation;
begin
  if FCalculateOnGPU then
  begin
    if not FSkin.Mesh.HasComponent(vcBones) or not Assigned(FSkinShaderAnim) then
      exit;
    FSkin.DrawInstance := FSkinDrawInstanceMethod;
    FSkin.DelBeforeDrawMethod(BeforeDrawObject);
    FSkin.Shader := FSkinShaderAnim;
    BSShaderManager.FreeShader(FSkinShaderAnim);
    FSkinShaderAnim := nil;
    FSkin.Mesh.DeleteComponent(vcBones);
    FSkin.Mesh.DeleteComponent(vcWeights);
    FSkin.ChangedMesh;
  end else
  begin
    if not Assigned(FSkinMeshCopy) then
      exit;
    FSkin.StaticObject := FSkinIsStaticObject;
    if Assigned(FSkinMesh) then
      FSkin.Mesh := FSkinMesh;
    FreeAndNil(FSkinMeshCopy);
  end;
  UpdateBonesTransform;

  if Assigned(FAniUpdater) then
    FAniUpdater.Stop;

  FAniUpdaterObserver := nil;
  FAniUpdater := nil;

end;

procedure TSkeleton.FindRoots;
var
  bone_bucket: TTableBones.TBucket;
begin
  Roots.Count := 0;
  if FBones.GetFirst(bone_bucket) then
  repeat
    if not Assigned(bone_bucket.Value.Parent) then
      Roots.Add(bone_bucket.Value);
  until not FBones.GetNext(bone_bucket);
end;

procedure TSkeleton.SetParentTransforms(const Value: TMatrix4f);
begin
  FParentTransforms := Value;
  // this is center of the skeleton
  Position := TVec3f(ParentTransforms.M3);
end;

procedure TSkeleton.OnUpdate(const AValue: BSFloat);
begin
  //RecalcAnimation;
end;

procedure TSkeleton.SetPauseAnimation(const Value: boolean);
begin
  if FPauseAnimation = Value then
    exit;

  FPauseAnimation := Value;

  CheckAnimation;
end;

procedure TSkeleton.SetPosition(const Value: TVec3f);
begin
  FPosition := Value;
  if Assigned(FSkin) then
    FSkin.Position := Value + FSkinCenterOffset;
  UpdateBonesTransform;
end;

procedure TSkeleton.SetAnimation(const Value: string);
begin
  if FAnimation = Value then
    exit;

  FAnimation := Value;

  CheckAnimation;
end;

procedure TSkeleton.SetShowBones(const Value: boolean);
begin
  if FShowBones = Value then
    exit;
  FShowBones := Value;
  if FShowBones then
    DoShowBones
  else
    DoHideBones;
end;

procedure TSkeleton.SetSkin(const Value: TGraphicObject);
begin
  if FSkin = Value then
    exit;

  if Assigned(FCurrentAnimation) then
    DoStopAnimation;

  FSkin := Value;
  if Assigned(FSkin) then
  begin
    FSkinDrawInstanceMethod := FSkin.DrawInstance;
    FSkinCenterOffset := FSkin.Position;
    FSkin.Position := FPosition;
    FSkin.Owner := Self;
  end else
  begin
    FSkinCenterOffset := vec3(0.0, 0.0, 0.0);
  end;

  UpdateBonesTransform;
end;

procedure TSkeleton.UpdateBonesTransform;
var
  bucket: TTableBones.TBucket;
begin
  if FBones.GetFirst(bucket) then
  repeat
    if not Assigned(bucket.Value.Parent) then
      bucket.Value.UpdateTransform;
  until not FBones.GetNext(bucket);
end;

procedure TSkeleton.UpdateBoneTransform(ABone: TBone);
var
  j: int32;
begin
  FCurrentTrasforms.Items[ABone.Index] := ABone.StackTransformInv*ABone.CurrentStackTransform;
  for j := 0 to ABone.ChildrenCount - 1 do
  begin
    UpdateBoneTransform(ABone.Children[j]);
  end;
end;

procedure TSkeleton.UpdateLinkedVertexes(ABone: TBone);
var
  j: int32;
  v, v_orig: TVec3f;
  bindedVertex: TVertexBind;
  m: TMatrix4f;
begin
  m := ABone.StackTransformInv*ABone.CurrentStackTransform;

  for j := 0 to ABone.BoundVertexes.Count - 1 do
  begin
    bindedVertex := ABone.BoundVertexes.Items[j];
    v_orig := FSkinMesh.ReadPoint(bindedVertex.VertexIndex);
    v := FSkinMeshCopy.ReadPoint(bindedVertex.VertexIndex);
    v := v + (m*v_orig)*bindedVertex.Weight;
    FSkinMeshCopy.WritePoint(bindedVertex.VertexIndex, v);
  end;

  for j := 0 to ABone.ChildrenCount - 1 do
  begin
    UpdateLinkedVertexes( ABone.Children[j]);
  end;
end;

{ TBone }

procedure TBone.AddChild(AChild: TBone);
begin
  FChildren.Add(AChild);
end;

procedure TBone.BindVertex(AVertexIndex: int32; AWeight: BSFloat);
begin
  FBoundVertexes.Add(TVertexBind.VertexBind(AVertexIndex, AWeight));
end;

procedure TBone.BuildView;
var
  len, wide_half: BSFloat;
  bevel: BSFloat;
  i: int32;
begin
  if Assigned(FGraphicObject) then
    exit;
  len := VecLen(FTip);
  wide_half := len*0.14*0.5;
  bevel := len*0.1;

  if Assigned(Parent) then
  begin
    FGraphicObject := TColoredVertexes.Create(Self, Parent.GraphicObject, Skeleton.Renderer.Scene)
  end else
  begin
    FGraphicObject := TColoredVertexes.Create(Self, nil, Skeleton.Renderer.Scene);
  end;

  FGraphicObject.DrawAsTransparent := true;

  // vertexes
  FGraphicObject.Mesh.AddVertex(vec3(0.0, len, 0.0)); // top             0
  FGraphicObject.Mesh.AddVertex(vec3(0.0, 0.0, 0.0)); // bottom          1

  // vertexes bevel level
  FGraphicObject.Mesh.AddVertex(vec3( wide_half, bevel,  wide_half)); // 2
  FGraphicObject.Mesh.AddVertex(vec3(-wide_half, bevel,  wide_half)); // 3
  FGraphicObject.Mesh.AddVertex(vec3(-wide_half, bevel, -wide_half)); // 4
  FGraphicObject.Mesh.AddVertex(vec3( wide_half, bevel, -wide_half)); // 5

  // indexes triangles Top
  FGraphicObject.Mesh.Indexes.Add(0);
  FGraphicObject.Mesh.Indexes.Add(2);
  FGraphicObject.Mesh.Indexes.Add(3);

  FGraphicObject.Mesh.Indexes.Add(0);
  FGraphicObject.Mesh.Indexes.Add(3);
  FGraphicObject.Mesh.Indexes.Add(4);

  FGraphicObject.Mesh.Indexes.Add(0);
  FGraphicObject.Mesh.Indexes.Add(4);
  FGraphicObject.Mesh.Indexes.Add(5);

  FGraphicObject.Mesh.Indexes.Add(0);
  FGraphicObject.Mesh.Indexes.Add(5);
  FGraphicObject.Mesh.Indexes.Add(2);

  // indexes triangles Bottom/bevel
  FGraphicObject.Mesh.Indexes.Add(1);
  FGraphicObject.Mesh.Indexes.Add(2);
  FGraphicObject.Mesh.Indexes.Add(3);

  FGraphicObject.Mesh.Indexes.Add(1);
  FGraphicObject.Mesh.Indexes.Add(3);
  FGraphicObject.Mesh.Indexes.Add(4);

  FGraphicObject.Mesh.Indexes.Add(1);
  FGraphicObject.Mesh.Indexes.Add(4);
  FGraphicObject.Mesh.Indexes.Add(5);

  FGraphicObject.Mesh.Indexes.Add(1);
  FGraphicObject.Mesh.Indexes.Add(5);
  FGraphicObject.Mesh.Indexes.Add(2);


  FGraphicObject.Mesh.CalcBoundingBox(true);

  if Assigned(Parent) then
    FGraphicObject.Color := BS_CL_GREEN
  else
    FGraphicObject.Color := BS_CL_ORANGE;

  FGraphicObject.DragResolve := not Assigned(Parent);
  FGraphicObject.ChangedMesh;

  UpdateViewPosition;
  for i := 0 to ChildrenCount - 1 do
    Children[i].BuildView;
end;

constructor TBone.Create(ASkeleton: TSkeleton; AParent: TBone);
begin
  FChildren := TListBones.Create(@PtrCmp);
  FBoundVertexes := TListBoundVertexes.Create;
  FTransform := IDENTITY_MAT;
  FStackTransform := IDENTITY_MAT;
  FStackTransformInv := IDENTITY_MAT;
  FCurrentTransform := IDENTITY_MAT;
  FCurrentStackTransform := IDENTITY_MAT;
  FSkeleton := ASkeleton;
  FParent := AParent;
  if Assigned(FParent) then
    FParent.AddChild(Self);
end;

procedure TBone.DeleteChildren;
var
  i: int32;
begin
  for i := FChildren.Count - 1 downto 0 do
    FChildren.Items[i].Free;
end;

destructor TBone.Destroy;
begin
  DeleteChildren;
  HideView;
  if Assigned(FParent) then
    FParent.RemoveChild(Self);
  FChildren.Free;
  FBoundVertexes.Free;
  inherited;
end;

function TBone.GetChildren(Index: int32): TBone;
begin
  Result := FChildren.Items[Index];
end;

function TBone.GetChildrenCount: int32;
begin
  Result := FChildren.Count;
end;

function TBone.HasAnimatedParent: boolean;
var
  p: TBone;
begin
  p := Parent;
  while Assigned(p) do
  begin
    if FSkeleton.CurrentAnimation.HasBone(p) then
      exit(true);
    p := p.Parent;
  end;
  Result := false;
end;

procedure TBone.HideView;
begin
  if not Assigned(Parent) then
    FreeAndNil(FGraphicObject)
  else
    FGraphicObject := nil;
end;

procedure TBone.RemoveChild(AChild: TBone);
begin
  FChildren.Remove(AChild, otFromEnd);
end;

procedure TBone.SetCurrentTransform(const Value: TMatrix4f);
begin
  FCurrentTransform := Value;
  UpdateCurrentTransform;
  UpdateViewPosition;
end;

procedure TBone.SetTip(const Value: TVec3f);
begin
  FTip := Value;
  if Skeleton.ShowBones then
    BuildView;
end;

procedure TBone.SetTransform(const Value: TMatrix4f);
begin
  FTransform := Value;
  UpdateTransform;
end;

procedure TBone.UpdateTransform;
var
  i: int32;
begin
  FCurrentTransform := FTransform;
  if not Assigned(Parent) then
    FCurrentTransform.M3 := vec4(TVec3f(FTransform.M3) - Skeleton.SkinCenterOffset, 1.0);

  UpdateStackTransform;

  for i := 0 to ChildrenCount - 1 do
  begin
    Children[i].UpdateTransform;
  end;

  UpdateViewPosition;
end;

procedure TBone.UpdateViewPosition;
var
  m: TMatrix4f;
begin
  if not Assigned(FGraphicObject) then
    exit;

  m := FCurrentTransform;
  if Assigned(Parent) then
    m.M3 := vec4(FCurrentTransform*vec3(0.0, FGraphicObject.Mesh.FBoundingBox.Max.y, 0.0) - vec3(0.0, Parent.GraphicObject.Mesh.FBoundingBox.Max.y, 0.0), 1.0)
  else
    m.M3 := vec4(FCurrentTransform*vec3(0.0, FGraphicObject.Mesh.FBoundingBox.Max.y, 0.0) + Skeleton.Position + Skeleton.SkinCenterOffset, 1.0);

  FGraphicObject.LocalTransform := m;
  {FGraphicObject.BeginUpdateTransformations;

  if Assigned(Parent) then
    FGraphicObject.Position := FCurrentTransform*vec3(0.0, FGraphicObject.Mesh.FBoundingBox.Max.y, 0.0) - vec3(0.0, Parent.GraphicObject.Mesh.FBoundingBox.Max.y, 0.0)
  else
    FGraphicObject.Position := FCurrentTransform*vec3(0.0, FGraphicObject.Mesh.FBoundingBox.Max.y, 0.0) + Skeleton.Position + Skeleton.SkinCenterOffset;

  FGraphicObject.Quaternion := bs.basetypes.Quaternion(FCurrentTransform);
  //FGraphicObject.Scale := vec3(FCurrentTransform.M0.x, FCurrentTransform.M1.y, FCurrentTransform.M2.z);

  FGraphicObject.EndUpdateTransformations; }
end;

procedure TBone.UpdateCurrentStackTransform;
begin
  if Assigned(FParent) then
    FCurrentStackTransform := FCurrentTransform*FParent.CurrentStackTransform
  else
    FCurrentStackTransform := FCurrentTransform;

  UpdateViewPosition;
end;

procedure TBone.UpdateCurrentTransform;
var
  i: int32;
begin
  UpdateCurrentStackTransform;
  for i := 0 to ChildrenCount - 1 do
  begin
    Children[i].UpdateCurrentTransform;
  end;
end;

procedure TBone.UpdateStackTransform;
begin
  if Assigned(Parent) then
    FStackTransform := FTransform*Parent.StackTransform
  else
  begin
    FStackTransform := FTransform;
    FStackTransform.M3 := vec4(TVec3f(FStackTransform.M3) - Skeleton.SkinCenterOffset, 1.0);
  end;

  FStackTransformInv := FStackTransform;
  MatrixInvert(FStackTransformInv);
  UpdateCurrentStackTransform;
end;

{ TVertexBind }

class function TVertexBind.VertexBind(AVertexIndex: int32; AWeight: BSFloat): TVertexBind;
begin
  Result.VertexIndex := AVertexIndex;
  Result.Weight := AWeight;
end;

{ TSkeletonAnimation }

procedure TSkeletonAnimation.Clear;
var
  i, j: int32;
  frame: PSkeletonFrame;
begin
  for i := 0 to FFrames.Count - 1 do
  begin
    frame := FFrames.Items[i];
    for j := 0 to Length(frame.FrameBones)-1 do
      Dispose(frame.FrameBones[j]);
    dispose(frame);
  end;
  FFrames.Clear;
  FBones.Clear;
end;

constructor TSkeletonAnimation.Create(const AName: string; AOwner: TSkeleton);
begin
  FFrames := TListFrames.Create;
  FBones := TListBones.Create(@PtrCmp);
  FOwner := AOwner;
end;

function TSkeletonAnimation.CreateKeyFrame(ABone: TBone; ATime: uint32;
  const AMatrix: TMatrix4f; AInterpolation: TInterpolateSpline): int32;
var
  keyFrame: PBoneKeyFrame;
  i: int32;
  frame: PSkeletonFrame;
  frame_index: int32;
  bone_index: int32;
begin

  bone_index := FBones.IndexOf(ABone);
  if bone_index < 0 then
  begin
    bone_index := FBones.Count;
    FBones.Add(ABone);
    ABone.CountAnimations := ABone.CountAnimations + 1;
    for i := 0 to FFrames.Count - 1 do
    begin
      frame := FFrames.Items[i];
      SetLength(frame.FrameBones, FBones.Count);
    end;
  end;

  frame := nil;
  frame_index := FFrames.Count;
  for i := FFrames.Count - 1 downto 0 do
  begin
    frame := FFrames.Items[i];
    if (frame.Time = ATime) or (frame.Time < ATime) then
    begin
      if (frame.Time < ATime) then
      begin
        frame_index := i + 1;
        frame := nil;
      end else
      begin
        frame_index := i;
      end;
      break;
    end;
  end;

  if not Assigned(frame) then
  begin
    New(frame);
    frame.Time := ATime;
    SetLength(frame.FrameBones, FBones.Count);
    if frame_index < FFrames.Count then
      for i := FFrames.Count downto frame_index + 1 do
        FFrames.Items[i] := FFrames.Items[i-1];
    FFrames.Items[frame_index] := frame;
  end;

  Result := frame_index;
  new(keyFrame);
  keyFrame.Interpolation := AInterpolation;

  if Assigned(frame.FrameBones[bone_index]) then
    raise EComponentAlreadyExists.Create('WTF');

  frame.FrameBones[bone_index] := keyFrame;

  if ATime > FDuration then
    FDuration := ATime;

  keyFrame.Position := TVec3f(AMatrix.M3);
  keyFrame.Rotation := Quaternion(AMatrix);
end;

destructor TSkeletonAnimation.Destroy;
begin
  Clear;
  FFrames.Free;
  FBones.Free;
  inherited;
end;

function TSkeletonAnimation.HasBone(ABone: TBone): boolean;
begin
  Result := FBones.IndexOf(ABone) >= 0;
end;

end.
