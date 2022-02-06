unit bs.test.tesselator;

{$I BlackSharkCfg.inc}

interface

uses
    bs.basetypes
  , bs.renderer
  , bs.scene
  , bs.test
  , bs.tesselator
  , bs.canvas
  ;

type

  { TBSTestTesselator }

  TBSTestTesselator = class(TBSTest)
  protected
    Canvas: TBCanvas;
    Holder: TCanvasObject;
    Points: TBlackSharkTesselator.TListPoints.TSingleListHead;
    Contours: TBlackSharkTesselator.TListContours.TSingleListHead;
    Indexes: TBlackSharkTesselator.TListIndexes.TSingleListHead;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
  end;

  { TBSTestTesselatorQuad }

  TBSTestTesselatorQuad = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorOctagon }

  TBSTestTesselatorOctagon = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorCircle }

  TBSTestTesselatorCircle = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_i }

  TBSTestTesselatorSymbol_i = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_A }

  TBSTestTesselatorSymbol_A = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_c }

  TBSTestTesselatorSymbol_c = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_W }

  TBSTestTesselatorSymbol_W = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_0631 }

  TBSTestTesselatorSymbol_0631 = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;

  { TBSTestTesselatorSymbol_1563 }

  TBSTestTesselatorSymbol_1563 = class(TBSTestTesselator)
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    class function TestName: string; override;
  end;


implementation

  uses bs.math;

{ TBSTestTesselatorSymbol_1563 }

constructor TBSTestTesselatorSymbol_1563.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.110000134, 9.68999958, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.050800323, 9.665000916, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.993200779, 9.638001442, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.937199593, 9.609000206, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.882800102, 9.578000069, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.829999924, 9.545000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.779200554, 9.5102005, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.730800152, 9.473800659, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.684799671, 9.435800552, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.641200066, 9.39620018, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.599999905, 9.354999542, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.561600208, 9.312800407, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.526400089, 9.270199776, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.494400024, 9.227199554, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.465600014, 9.183799744, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.440000057, 9.140000343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.418400288, 9.096000671, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.401600361, 9.052000999, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.3895998, 9.008000374, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.382400036, 8.964000702, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.380000114, 8.920000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.567199707, 8.83080101, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.712800503, 8.70720005, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.816800117, 8.549200058, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.879199982, 8.356800079, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.900000095, 8.130000114, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.889800549, 7.986600399, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.859200478, 7.852400303, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.808199883, 7.727399826, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.736799717, 7.611600399, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.644999981, 7.505000114, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.53880024, 7.413200855, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.424200535, 7.34180069, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.301199913, 7.290800095, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.169799805, 7.260200024, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.03000021, 7.25, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.868200302, 7.261799812, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.718800545, 7.297200203, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.581799984, 7.356199741, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.457200527, 7.438799858, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.34499979, 7.545000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.24960041, 7.66960001, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.175400257, 7.807400703, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.122399807, 7.958399773, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.090599537, 8.122600555, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.079999924, 8.300000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.084400177, 8.429200172, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.09760046, 8.560800552, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.119600296, 8.694799423, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.150399685, 8.831199646, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.190000057, 8.970000267, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.238399982, 9.11000061, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.295600414, 9.250000954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.361600399, 9.390000343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.436399937, 9.530000687, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.519999981, 9.670000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.612400055, 9.809201241, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.713600636, 9.946800232, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.823600292, 10.08279991, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.942399979, 10.21719933, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.070000172, 10.35000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.206000328, 10.47999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.349999905, 10.60599995, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.502000332, 10.72800064, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.661999702, 10.84599972, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.829999924, 10.96000004, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.841199875, 10.55079937, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.874800205, 10.21920013, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.930799961, 9.965199471, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.009199619, 9.78880024, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.900000095, 5.440000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.897200108, 5.368599892, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.888800144, 5.298400879, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.874799728, 5.229400158, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.855199814, 5.161600113, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.829999924, 5.09499979, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.799799919, 5.030800343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.765200138, 4.970200062, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.726200104, 4.913199902, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.682800293, 4.859800339, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.635000229, 4.809999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.583600521, 4.763800144, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.529399872, 4.721200466, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.472399712, 4.682200432, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.41260004, 4.646800041, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.349999905, 4.614999771, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.285199642, 4.588000298, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.218800068, 4.567000389, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.150800228, 4.552000046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.081200123, 4.543000221, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.010000229, 4.539999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.938600063, 4.543000221, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.868400097, 4.552000523, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.799399853, 4.566999912, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.731599808, 4.588000298, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.664999962, 4.614999771, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.600600243, 4.646800041, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.539400101, 4.682200432, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.481400013, 4.721199989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.426599503, 4.763800144, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.375, 4.809999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.327000141, 4.859800339, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.282999992, 4.913199902, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.243000031, 4.970200062, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.207000256, 5.030800343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.175000191, 5.09499979, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.14800024, 5.161600113, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.127000332, 5.229400158, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.111999989, 5.298400402, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.102999687, 5.368599892, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.099999905, 5.440000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.102999687, 5.511400223, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.111999989, 5.581600189, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.127000332, 5.650599957, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.147999763, 5.718400478, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.175000191, 5.784999847, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.206800461, 5.849200249, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.242200851, 5.909800529, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.281199932, 5.966799736, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.323800087, 6.020200253, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.369999886, 6.070000172, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.419800282, 6.11619997, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.473200321, 6.158800125, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.530200005, 6.197800159, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.590800285, 6.233200073, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.65500021, 6.264999866, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.721600533, 6.292000294, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.789400101, 6.313000679, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.858399868, 6.328000546, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.928599834, 6.336999893, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5, 6.340000153, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.071400166, 6.336999893, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.141600132, 6.328000546, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.210599899, 6.313000679, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.278400421, 6.292000294, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.34499979, 6.264999866, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.409399986, 6.23320055, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.470600605, 6.197800159, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.528599739, 6.158800125, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.583399773, 6.11619997, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.635000229, 6.070000172, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.682800293, 6.020200253, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.726200104, 5.96680069, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.765199661, 5.909799576, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.799799919, 5.849200249, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.829999924, 5.784999847, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.855199814, 5.718400478, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.874800205, 5.650599957, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.888800144, 5.581599712, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.897199631, 5.511400223, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorSymbol_1563.TestName: string;
begin
  Result := 'Triangulation Symbol 1563';
end;

{ TBSTestTesselatorSymbol_0631 }

constructor TBSTestTesselatorSymbol_0631.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.979999542, 6.039999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.770000458, 5.150000095, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.692400932, 4.930399895, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.579601288, 4.759600163, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.431599617, 4.637599945, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.248400688, 4.564400196, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.029999733, 4.539999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.940000057, 4.539999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.760000229, 5.320000172, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.756200314, 5.334000111, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.744800568, 5.360000134, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.725800037, 5.398000717, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.699200153, 5.447999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.664999962, 5.510000229, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.626200676, 5.581000328, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.585800648, 5.658000469, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.543799877, 5.740999699, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.500199795, 5.829999924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.454999924, 5.925000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.409800053, 6.024800301, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.366200447, 6.128200054, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.324200153, 6.235200405, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.283800125, 6.345799446, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.244999886, 6.460000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.210800648, 6.574800014, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.184200287, 6.687199593, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.165200233, 6.797199726, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.153800011, 6.904799938, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.150000095, 7.010000229, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.218800545, 7.424399853, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.425200462, 7.827600002, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.769199848, 8.219599724, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.250800133, 8.600399971, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.869999886, 8.970000267, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.004200459, 9.044199944, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.134800434, 9.122799873, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.261799812, 9.205800056, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.385200024, 9.293200493, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.505000114, 9.385000229, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.621600151, 9.480199814, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.735401154, 9.577801704, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.846400261, 9.677799225, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.95459938, 9.780200005, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.059999943, 9.885000229, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.163600445, 9.99200058, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.266400814, 10.10100079, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.36839962, 10.21199989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.469600677, 10.32499981, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.570000172, 10.43999958, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.67000103, 10.55599976, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.770000458, 10.67200089, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.869999886, 10.78800011, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.96999979, 10.90400028, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.069999695, 11.02000046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.069999695, 8.779999733, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.069400787, 8.722400665, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.06760025, 8.669600487, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.064599991, 8.621600151, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.060400009, 8.578399658, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.055000305, 8.539999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.046800613, 8.504799843, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.034200668, 8.471200943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.017199516, 8.439200401, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.995800972, 8.408800125, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.96999979, 8.380000114, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.939001083, 8.352399826, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.90199995, 8.325600624, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.859000206, 8.299599648, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.809999943, 8.274399757, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.755000114, 8.25, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.692400455, 8.225200653, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.620599747, 8.198801041, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.539599419, 8.170800209, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.449399471, 8.141200066, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.349999905, 8.109999657, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.289999962, 7.769999981, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.176400661, 7.727200508, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.075600147, 7.678800583, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.987600327, 7.624799728, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.912399769, 7.565200329, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.849999905, 7.5, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.799600124, 7.430399895, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.760400295, 7.357600689, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.73239994, 7.281599522, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.715600491, 7.202399731, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.710000038, 7.119999886, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.712800503, 7.058400154, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.721199989, 6.993599892, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.735200405, 6.925600052, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.754799843, 6.854400158, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.78000021, 6.78000021, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.809999943, 6.705000401, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.84400034, 6.631999969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.881999493, 6.561000347, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.924000263, 6.492000103, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.96999979, 6.425000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.019200325, 6.361199856, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.070800304, 6.301800728, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.124800205, 6.246799946, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.181200027, 6.196199894, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.239999771, 6.150000095, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.300000191, 6.110399723, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.36000061, 6.079600334, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.420000076, 6.057600021, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.480000019, 6.044400215, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.539999962, 6.039999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.979999542, 6.039999962, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorSymbol_0631.TestName: string;
begin
  Result := 'Triangulation Symbol 0631';
end;

{ TBSTestTesselatorSymbol_W }

constructor TBSTestTesselatorSymbol_W.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(19.82999992, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(19.39360046, 13.48240089, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(18.95640182, 13.14560032, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(18.51840019, 12.58959961, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(18.07960129, 11.81440067, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(17.63999939, 10.81999969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.64000034, 0.8199999928, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.03999996, 0.8199999928, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.14000034, 9.270000458, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.763199806, 8.579200745, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.416801453, 7.906800747, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.100800514, 7.252799511, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.815199852, 6.617199898, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.56000042, 6, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.519999981, 0.8199999928, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.940000057, 0.8199999928, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.569999933, 10.76000023, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.303600073, 11.49760056, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.040400028, 12.11840057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.780399919, 12.62240028, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.523599863, 13.00959969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.269999981, 13.27999973, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.129600048, 13.38560104, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.9884000421, 13.47040081, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.8464000225, 13.53440094, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.7035999894, 13.57760048, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5600000024, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5600000024, 14.07999992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.050000191, 14.07999992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.050000191, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.916800261, 13.58360004, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.813199997, 13.54240131, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.739199877, 13.47640038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.6947999, 13.38559914, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.680000067, 13.27000046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.681600094, 13.2364006, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.686399937, 13.19960117, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.694400072, 13.1595993, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.705600023, 13.11639977, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.720000029, 13.06999969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.889999866, 3.690000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.56000042, 7.889999866, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.822799683, 8.618801117, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.027200699, 9.333200455, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.173200607, 10.03320026, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.260799408, 10.71879959, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.289999962, 11.39000034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.222799301, 12.15680027, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.02120018, 12.76119995, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.685199738, 13.20320034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.214799881, 13.48280048, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.610000134, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.610000134, 14.07999992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(11.14999962, 14.07999992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(11.14999962, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.99520016, 13.58400059, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.87480068, 13.54400158, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.78880024, 13.47999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.73719978, 13.39200115, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.72000027, 13.27999973, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.72160053, 13.24280167, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.72640133, 13.20320034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.7343998, 13.16119957, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.7456007, 13.11679935, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.76000023, 13.06999969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.97000027, 3.690000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.01000023, 8.859999657, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.34840012, 9.757199287, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.61160088, 10.5447998, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.7996006, 11.22280025, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.91239929, 11.79119968, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.95000076, 12.25, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.93320084, 12.54959965, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.88280106, 12.80840111, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.79879951, 13.02640057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.68120003, 13.20360088, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.53000069, 13.34000015, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.37319946, 13.42720127, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(16.17480278, 13.49680042, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(15.93480015, 13.54880142, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(15.6532011, 13.58320045, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(15.32999992, 13.60000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(15.32999992, 14.07999992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(19.82999992, 14.07999992, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorSymbol_W.TestName: string;
begin
  Result := 'Triangulation W';
end;

{ TBSTestTesselatorSymbol_i }

constructor TBSTestTesselatorSymbol_i.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.839999914, 13.93000031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.828799963, 13.77499962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.795199871, 13.63000107, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.739199877, 13.49499989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.660800219, 13.36999989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.559999943, 13.25500011, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.443200111, 13.15600109, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.316799879, 13.07900143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.180799961, 13.02400017, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.035199881, 12.99100018, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.880000114, 12.97999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.725000381, 12.99100113, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.580000401, 13.02400017, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.444999933, 13.07900047, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.319999933, 13.15600014, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.204999924, 13.25500011, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.106000185, 13.36999989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.029000282, 13.49500084, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.973999977, 13.63000011, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.941000104, 13.77499962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.929999948, 13.93000031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.94080019, 14.08180046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.973200083, 14.22520161, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.027199984, 14.36019993, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.102799892, 14.48679924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.200000048, 14.60499954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.312799931, 14.70760155, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.435200214, 14.7874012, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.567199945, 14.84439945, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.708800077, 14.87860107, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.859999895, 14.89000034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.019000292, 14.87900162, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.168000221, 14.84600067, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.30700016, 14.79099941, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.436000109, 14.7140007, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.555000067, 14.61499977, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.657600164, 14.49960041, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.737400293, 14.37340069, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.794399977, 14.2364006, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.82859993, 14.08860111, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.170000076, 1.289999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5899999738, 1.289999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5899999738, 1.769999981, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.9062000513, 1.791199923, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.182800055, 1.838800073, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.419800162, 1.912799954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.617200017, 2.013200045, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.774999976, 2.140000105, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.899199963, 2.299600124, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.995800138, 2.498400211, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.064800024, 2.736400127, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.10619998, 3.013599873, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.119999886, 3.329999924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.119999886, 8.800000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.091200352, 9.026800156, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.004800081, 9.20320034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.860799909, 9.329200745, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.659199834, 9.404799461, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.399999976, 9.430000305, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.294000149, 9.424800873, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.184000134, 9.409200668, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.070000052, 9.383200645, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.9519999623, 9.34679985, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.8299999833, 9.300000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.7660000324, 9.274001122, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.7100000978, 9.252000809, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.6619999409, 9.234000206, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.621999979, 9.220000267, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5899999738, 9.210000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5899999738, 9.720000267, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.150000095, 10.72999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.640000105, 10.72999954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.640000105, 3.329999924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.653800011, 3.013599873, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.695200205, 2.736400127, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.764199734, 2.498399973, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.860800266, 2.299599886, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.984999895, 2.140000105, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.142800331, 2.013200045, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.340200424, 1.912800193, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.577199936, 1.838800073, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.85379982, 1.791199923, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.170000076, 1.769999981, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.170000076, 1.289999962, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorSymbol_i.TestName: string;
begin
  Result := 'Triangulation symbol i';
end;

{ TBSTestTesselatorCircle }

constructor TBSTestTesselatorCircle.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.970000029, 2.190000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.959399939, 2.049600124, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.927600384, 1.916400313, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.874599934, 1.790399909, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.800400019, 1.671599984, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.704999924, 1.559999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.595200300, 1.462800145, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.477799892, 1.387200117, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.352799892, 1.333200097, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.220200062, 1.300799966, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.079999924, 1.289999962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.936000109, 1.300800204, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.799999952, 1.333200097, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.672000170, 1.387199998, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.551999927, 1.462800026, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.440000057, 1.559999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.342800021, 1.671599984, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.267199993, 1.790400028, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.213199973, 1.916400194, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.180799961, 2.049600124, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.169999957, 2.190000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.180799961, 2.330399990, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.213199973, 2.463600159, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.267199993, 2.589599848, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.342800021, 2.708400249, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.440000057, 2.819999933, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.551599979, 2.917200089, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.670400143, 2.992800236, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.796399951, 3.046799898, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.929600120, 3.079199791, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.069999933, 3.089999914, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.213800192, 3.079199791, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.349200249, 3.046800137, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.476199865, 2.992799997, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.594799995, 2.917200089, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.704999924, 2.819999933, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.800400019, 2.708400249, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.874600172, 2.589600325, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.927600145, 2.463599920, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.959399939, 2.330399990, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorCircle.TestName: string;
begin
  Result := 'Triangulation Circle';
end;

{ TBSTestTesselatorQuad }

constructor TBSTestTesselatorQuad.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 0, 0, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 0, 6, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 6, 6, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 6, 0, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorQuad.TestName: string;
begin
  Result := 'Triangulation Quad';
end;

{ TBSTestTesselatorOctagon }

constructor TBSTestTesselatorOctagon.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 0, 3, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 0, 6, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 3, 9, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 6, 9, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 9, 6, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 9, 3, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 6, 0, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3( 3, 0, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
  //TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(Points.Count div 2, Points.Count));
end;

class function TBSTestTesselatorOctagon.TestName: string;
begin
  Result := 'Triangulation Octagon';
end;

{ TBSTestTesselator }

constructor TBSTestTesselator.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited Create(ARenderer);
  TBlackSharkTesselator.TListContours.Create(Contours);
  TBlackSharkTesselator.TListPoints.Create(Points);
  TBlackSharkTesselator.TListIndexes.Create(Indexes);
  Canvas := TBCanvas.Create(Renderer, nil);
end;

destructor TBSTestTesselator.Destroy;
begin
  TBlackSharkTesselator.TListContours.Free(Contours);
  TBlackSharkTesselator.TListPoints.Free(Points);
  TBlackSharkTesselator.TListIndexes.Free(Indexes);
  Canvas.Free;
  inherited Destroy;
end;

function TBSTestTesselator.Run: boolean;
var
  i: int32;
  v0, v1, v2: TVec3f;
  kx, ky: BSFloat;
  xMax, yMax, xMin, yMin: BSFloat;
begin
  Result := true;
  Tesselator.Triangulate(Points, Contours, Indexes);
  if ((Tesselator.yMax - Tesselator.yMin) = 0) or (Tesselator.xMax - Tesselator.xMin = 0) then
    exit(false);

  xMax := Tesselator.xMax;
  yMax := Tesselator.yMax;
  xMin := Tesselator.xMin;
  yMin := Tesselator.yMin;
  // scale to screen
  ky := Renderer.WindowHeight / (yMax - yMin);
  kx := Renderer.WindowWidth / (xMax - xMin);
  if ky > kx then
    ky := kx
  else
    kx := ky;
  Canvas.Clear;
  // create root object
  Holder := Canvas.CreateEmptyCanvasObject;
  // set position root object
  Holder.Position2d := vec2(0.0, 0.0);
  for i := 0 to Indexes.Count div 3 - 1 do //
  begin
    v0 := Points.items[Indexes.items[i*3  ]];
    v1 := Points.items[Indexes.items[i*3+1]];
    v2 := Points.items[Indexes.items[i*3+2]];
    with TTriangle.Create(Canvas, Holder) do
    begin
      A := vec2((v0.x-xMin)*kx, ky*(yMax-v0.y));
      B := vec2((v1.x-xMin)*kx, ky*(yMax-v1.y));
      C := vec2((v2.x-xMin)*kx, ky*(yMax-v2.y));
      Fill := true;
      Build;
    end;
  end;
end;

{ TBSTestTesselatorSymbol_A }

constructor TBSTestTesselatorSymbol_A.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.139999866, 4.889999866, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.359999895, 2.740000010, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.325600386, 2.644200087, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.294399977, 2.548800230, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.266400099, 2.453799963, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.241600037, 2.359200001, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.220000029, 2.265000105, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.202000141, 2.173600197, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.188000202, 2.087399960, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.177999973, 2.006400108, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.172000170, 1.930599928, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.170000076, 1.860000014, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.183399916, 1.663199902, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.223600149, 1.488800168, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.290600061, 1.336799979, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.384400129, 1.207200050, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.505000114, 1.100000024, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.653200150, 1.013600111, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.829800129, 0.9464000463, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.034800053, 0.8983999491, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.268199921, 0.8696000576, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.530000210, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.000000000, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.000000000, 0.0000000000, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.000000000, 0.0000000000, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.000000000, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.3899999857, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.5063999891, 0.8626000285, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.6156000495, 0.8704000711, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.7176000476, 0.8833999634, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.812400043, 0.9016000628, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.8999999762, 0.9250000119, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(0.9824000597, 0.9556000233, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.061600089, 0.9954000711, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.137600064, 1.044399977, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.210400105, 1.102599978, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.279999971, 1.169999957, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.347400069, 1.247200012, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.413600206, 1.334800124, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.478600025, 1.432799935, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.542400002, 1.541199923, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.605000019, 1.659999967, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.668400168, 1.791200161, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.734600067, 1.936800122, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.803600192, 2.09679985, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.875400066, 2.271199942, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.950000048, 2.460000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.489999771, 14.61999989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.090000153, 14.61999989, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.72000027, 1.950000048, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.76820087, 1.826400042, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.81680202, 1.711600065, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.8657999, 1.605599999, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.91520023, 1.508399963, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(12.96500015, 1.419999957, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.01680183, 1.339400053, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.07220078, 1.265600085, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.13120079, 1.198600054, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.19380093, 1.138399959, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.26000023, 1.085000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.33000088, 1.037999988, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.40400028, 0.9970000386, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.48200035, 0.9619999528, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.56400013, 0.9330000281, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.64999962, 0.9100000262, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.7412014, 0.8920000196, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.83880043, 0.8780000806, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(13.94279861, 0.8680000305, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(14.05319977, 0.8620000482, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(14.17000008, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(14.43999958, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(14.43999958, 0, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.81000042, 0, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.81000042, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.279999733, 0.8600000143, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.722800255, 0.8992000818, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.06720066, 1.016800046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.31320095, 1.212800026, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.46079922, 1.487200022, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.51000023, 1.840000033, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.50820065, 1.90839994, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.50279999, 1.977600098, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.49380016, 2.047600031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.48120022, 2.118399858, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.46500015, 2.190000057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.44560051, 2.263999939, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.42340088, 2.342000246, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.39839935, 2.424000025, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.3706007, 2.50999999, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(10.34000015, 2.599999905, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.520000458, 4.889999866, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.880000114, 9.5, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.754200459, 9.859399796, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.632801056, 10.20960045, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.515799522, 10.55060101, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.40320015, 10.88239956, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.295000076, 11.20499992, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.192800522, 11.52080059, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.098200798, 11.83220005, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.011199951, 12.13919926, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.931799889, 12.44180012, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.860000134, 12.73999977, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.831000328, 12.59300041, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.800000191, 12.44800186, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.767000198, 12.30500031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.732000828, 12.16400051, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.695000172, 12.02499962, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.656400681, 11.88640118, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.61660099, 11.74660015, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.575600624, 11.60560036, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.533399582, 11.46340084, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.489999771, 11.31999969, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.444800377, 11.1746006, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.397201061, 11.02640057, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.347199917, 10.87540054, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.294799805, 10.72160053, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.239999771, 10.56499958, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.18239975, 10.40360069, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.121600151, 10.2354002, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.057600021, 10.06040001, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.990399837, 9.878600121, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.920000076, 9.68999958, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.53000021, 5.920000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.149999619, 5.920000076, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, 91));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(91, 33));
end;

class function TBSTestTesselatorSymbol_A.TestName: string;
begin
  Result := 'Triangulation symbol А';
end;

{ TBSTestTesselatorSymbol_c }

constructor TBSTestTesselatorSymbol_c.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.800000191, -0.200000003, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.820000172, -0.1212500036, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.920000076, 0.1150000021, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.119999886, 0.5212500095, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.440000057, 1.110000014, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.888749957, 1.886250019, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.475000024, 2.855000019, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.216249943, 4.03125, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.129999995, 5.429999828, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.216249943, 6.93625021, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.475000024, 8.175000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(1.887500048, 9.171250343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(2.434999943, 9.949999809, 0.0));   //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.105000019, 10.52250004, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.88499999, 10.89999962, 0.0)); //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.753749847, 11.10999966, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.690000057, 11.18000031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.328750134, 11.14875031, 0.0));    //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.965000153, 11.05500031, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.568749905, 10.89624977, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.109999657, 10.67000008, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.572500229, 10.37625027, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.93999958, 10.01500034, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.180000305, 9.586250305, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.260000229, 9.090000153, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.145000458, 8.484999657, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.800000191, 8.090000153, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.227499962, 7.872499943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.429999828, 7.800000191, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.409999847, 8.267499924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.349999905, 8.710000038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.241250038, 9.113750458, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.074999809, 9.465000153, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.84499979, 9.755000114, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.545000076, 9.975000381, 0.0)); //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.163750172, 10.11375046, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.690000057, 10.15999985, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(5.128749847, 10.10499954, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.625, 9.93999958, 0.0));       //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.183750153, 9.640000343, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.809999943, 9.180000305, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.50999999, 8.547499657, 0.0));   //
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.289999962, 7.730000019, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.154999971, 6.704999924, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.109999895, 5.449999809, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.29124999, 3.547499895, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(3.835000038, 2.200000048, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(4.791250229, 1.397500038, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.210000038, 1.129999995, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.099999905, 1.230000019, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.869999886, 1.529999971, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.489999771, 1.987499952, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.930000305, 2.559999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.067500114, 2.420000076, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.180000305, 2.24000001, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.255000114, 2.019999981, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.279999733, 1.75999999, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.225000381, 1.409999967, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(9.06000042, 1.059999943, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.786250114, 0.7275000215, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(8.404999733, 0.4300000072, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.916250229, 0.1762499958, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(7.320000172, -0.02500000037, 0.0));
  TBlackSharkTesselator.TListPoints.Add(Points, vec3(6.614999771, -0.15625, 0.0));
  TBlackSharkTesselator.TListContours.Add(Contours, TBlackSharkTesselator.Contour(0, Points.Count));
end;

class function TBSTestTesselatorSymbol_c.TestName: string;
begin
  Result := 'Triangulation symbol c';
end;

end.

