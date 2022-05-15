unit bs.test.switcher;

interface

uses
    bs.test
  ;

implementation

uses
    bs.test.canvas
  , bs.test.canvas.map
  , bs.test.canvas.primitives
  , bs.test.font
  , bs.test.tesselator
  , bs.test.mesh
  , bs.test.mesh.skeleton
  , bs.test.camera
  , bs.test.gui
  , bs.test.windows
  , bs.test.spacetree
  , bs.test.instancing
  , bs.test.scheme
  ;

initialization
  { uncomment a need class test for available select in combobox }

  //RegisterTest(TBSTestResample);

  { Instansing tests }
  RegisterTest(TBSTestParticles);
  RegisterTest(TBSTestInstancing);
  RegisterTest(TBSTestInstancing2d);
  RegisterTest(TBSTestFog);

  { Chart tests }
  RegisterTest(TBSTestFloatChart);
  RegisterTest(TBSTestDateChart);
  RegisterTest(TBSTestChart);
  RegisterTest(TBSTestChartCircular);
  RegisterTest(TBSTestChartBar);
  RegisterTest(TBSTestChartBarDate);
  RegisterTest(TBSTestBadDateChart);

  { GUI tests }

  RegisterTest(TBSTestButton);
  RegisterTest(TBSTestCheckBox);
  RegisterTest(TBSTestEdit);
  RegisterTest(TBSTestScrollBar);
  RegisterTest(TBSTestScrollBox);
  RegisterTest(TBSTestForm);
  RegisterTest(TBSTestGrid);
  RegisterTest(TBSTestTable);
  RegisterTest(TBSTestComboBox);
  RegisterTest(TBSTestTrackBar);
  RegisterTest(TBSTestColorDialog);
  RegisterTest(TBSTestColorBox);
  RegisterTest(TBSTestSelector);
  RegisterTest(TBSTestRotor);
  RegisterTest(TBSTestHint);
  //RegisterTest(TBSTestMemo);
  RegisterTest(TBSTestObjectInspector);
  RegisterTest(TBSTestWindows);

    { Canvas tests }
    RegisterTest(TBSTestSimple);
    //RegisterTest(TBSTestVecToRastFont);
    RegisterTest(TBSTestCanvas);
    RegisterTest(TBSTestCanvasFonts);
    RegisterTest(TBSTestCanvasAlign);
    RegisterTest(TBSTestCanvasPrimitives);
    RegisterTest(TBSTestCanvasImages);
    RegisterTest(TBSTestTrueTypeFont);
    //RegisterTest(TBSTestTrueTypeSmiles);
    RegisterTest(TBSTestCanvasMap);
    RegisterTest(TBSTestCanvasLines);

  { Animation }
  RegisterTest(TBSTestSimpleAnimation);
  RegisterTest(TBSTestAnimationByAnimator);
  RegisterTest(TBSTestAnimationFlame);

  { 3d tests }
  RegisterTest(TBSTestMesh);
  RegisterTest(TBSTestMeshCylinder);
  RegisterTest(TBSTestEarth);
  RegisterTest(TBSTestCollada);

  { Tesselator tests }
  RegisterTest(TBSTestTesselatorOctagon);
  RegisterTest(TBSTestTesselatorQuad);
  RegisterTest(TBSTestTesselatorCircle);
  RegisterTest(TBSTestTesselatorSymbol_i);
  RegisterTest(TBSTestTesselatorSymbol_A);
  RegisterTest(TBSTestTesselatorSymbol_c);
  RegisterTest(TBSTestTesselatorSymbol_W);
  RegisterTest(TBSTestTesselatorSymbol_0631);
  RegisterTest(TBSTestTesselatorSymbol_1563);

  { Test of scheme }

  RegisterTest(TBSTestScheme);

end.
