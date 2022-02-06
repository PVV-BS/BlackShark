unit bs.test.ray;

{$I BlackSharkCfg.inc}

interface

uses
  bs.basetypes, bs.scene, bs.test,
  bs.shader, //BlackSharkCanvas, BlackSharkButtons, BlackSharkEvents,
  bs.mesh.primitives, bs.gles, bs.mesh.presents;

type

{ TBSTestRay }

TBSTestRay = class(TBSTest)
private
  //Canvas: TBlackSharkCanvas;
  Mesh: TBlackSharkShape;
  Obj: TTexturedVertexes;
  //VectorialText: TBlackSharkText;
  //procedure OnMouseUpScaleOut({%H-}Data: PEventBaseRec);
public
  constructor Create(AScene: TBlackSharkScene); override;
  destructor Destroy; override;
  function Run: boolean; override;
  class function TestName: string; override;
  //class function TestClass: TBSTestClass; override;
end;

implementation

{ TBSTestRay }

constructor TBSTestRay.Create(AScene: TBlackSharkScene);
//const
//  TRIANGLE: array[0..2] of TVec3f;
begin
  inherited Create(AScene);
  Mesh := TBlackSharkShape.Create;
  Mesh.Write(Mesh.AddVertex(vec3(-0.5, -0.5, 0.0)), vcTexture1, vec2(0.0, 0.0));
  Mesh.Write(Mesh.AddVertex(vec3(0.0, 0.5, 0.0)), vcTexture1, vec2(0.0, 0.0));
  Mesh.Write(Mesh.AddVertex(vec3(0.5, -0.5, 0.0)), vcTexture1, vec2(0.0, 0.0));
  Mesh.Indexes.Add([0, 1, 2, 0]);
  Mesh.DrawingPrimitive := GL_TRIANGLE_STRIP;
  Mesh.CalcBoundingBox(true);
  Obj := TTexturedVertexes.Create(nil, Scene, Mesh);
  Obj.Texture := Scene.TextureManager.UV(BS_CL_LIME);
  Obj.Shader := TBlackSharkTextureOutShader(Scene.ShaderManager.Load('SimpleTexture', TBlackSharkTextureOutShader));
  Obj.DragResolve := true;
  Obj.Position := vec3(0.0, 0.0, -2);
end;

destructor TBSTestRay.Destroy;
begin
  inherited Destroy;
end;

function TBSTestRay.Run: boolean;
begin
  Result := true;
end;

class function TBSTestRay.TestName: string;
begin
  Result := 'Test Ray';
end;

initialization

  //RegisterTest(TBSTestRay);

end.

