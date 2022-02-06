unit bs.test.vectorastront;

{$I BlackSharkCfg.inc}

interface

uses
  bs.bsobject,
  bs.scene,
  bs.test,
  bs.canvas,
  bs.font,
  bs.gui.buttons;

type

  TBSTestVecToRastFont = class(TBSTest)
  private
    Font: TTrueTypeFont;
    Canvas: TBlackSharkCanvas;
    ButtonScaleIn: TBlackSharkButton;
    ButtonScaleOut: TBlackSharkButton;
    VecToRasterText: TCanvasText;
    procedure OnMouseUpScaleIn({%H-}Data: PEventBaseRec);
    procedure OnMouseUpScaleOut({%H-}Data: PEventBaseRec);
  public
    constructor Create(AScene: TBlackSharkScene); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
    //class function TestClass: TBSTestClass; override;
  end;

implementation

  uses bs.basetypes, bs.events;

{ TBSTestVecToRastFont }

constructor TBSTestVecToRastFont.Create(AScene: TBlackSharkScene);
{var
  pic: TBlackSharkPicture;  }
begin
  inherited;

  {pic := TPicCodecManager.Open('g:\picture.png');
  //pic.Canvas.SaveToFile('g:\resample_befor.bmp');
  pic.Canvas.Resample(vec2(pic.Width div 6, pic.Height div 6), 0);
  pic.Canvas.SaveToFile('g:\resample.bmp');
  pic.Free;  }


  ButtonScaleIn := TBlackSharkButton.Create(AScene, 120, 35);
  ButtonScaleIn.Text.Data.Color := BS_CL_BLACK;
  ButtonScaleIn.Caption := 'Zoom text in';
  ButtonScaleIn.Position2d := vec2(350.0, 45.0);
  ButtonScaleIn.Root.Data.EventMouseUp.Subscribe(OnMouseUpScaleIn, ButtonScaleIn);
  {ButtonScaleIn.ButtonBody.Canvas.Pen.Color1 := BS_CL_ORANGE_2;
  ButtonScaleIn.ButtonBody.Canvas.Pen.Color2 := BS_CL_ORANGE_LIGHT;
  ButtonScaleIn.ButtonBody.Canvas.Pen.GradientType := gtVerical;
  ButtonScaleIn.TexOnMouseDown := ButtonScaleIn.TexOnMouseEnter; }
  ButtonScaleOut := TBlackSharkButton.Create(AScene, 120, 35);
  ButtonScaleOut.Text.Data.Color := BS_CL_BLACK;
  ButtonScaleOut.Caption := 'Zoom text out';
  ButtonScaleOut.Position2d := vec2(350.0, 95.0);
  ButtonScaleOut.Root.Data.EventMouseUp.Subscribe(OnMouseUpScaleOut, ButtonScaleIn);

  Font := TTrueTypeFont(AScene.FontManager.GetFont('DejaVuSans.ttf', TTrueTypeRasterFont));  //times   cour
  //Font.Load(GetFilePath('DejaVuSans.ttf', 'Fonts'));
  Canvas := TBlackSharkCanvas.Create(Scene, false);
  Canvas.Font := Font;
  VecToRasterText := TCanvasText.Create(Canvas, nil);
  VecToRasterText.Text := 'Nicely Rasterized True Type Font!!! Im do it! Im happy!!! :)';
  VecToRasterText.Position2d := vec2(100, 250);
  Canvas.Font.Size := 14;
  //VecToRasterText.Data.Color := BS_CL_RED;
  //Font.Texture.Picture.Canvas.SaveToFile('g:\map.bmp');
end;

destructor TBSTestVecToRastFont.Destroy;
begin
  ButtonScaleIn.Free;
  ButtonScaleOut.Free;
  Canvas.Free;
  inherited;
end;

procedure TBSTestVecToRastFont.OnMouseUpScaleIn(Data: PEventBaseRec);
begin
  if (Font <> nil) and (VecToRasterText <> nil) then
    begin
    Font.Size := Font.Size + 3;
    //VecToRasterText.GraphicText.Build;
    end;
end;

procedure TBSTestVecToRastFont.OnMouseUpScaleOut(Data: PEventBaseRec);
begin
  if (Font <> nil) and (VecToRasterText <> nil) then
    begin
    Font.Size := Font.Size - 3;
    //VecToRasterText.Build;
    end;
end;

function TBSTestVecToRastFont.Run: boolean;
begin
  Result := true;
end;

class function TBSTestVecToRastFont.TestName: string;
begin
  Result := 'Test vector Font convrted to raster';
end;


end.
