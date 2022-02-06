unit bs.autotest.switcher;

interface

uses
    bs.test
  ;

implementation

uses
    bs.test.canvas
  , bs.test.auto.edit
  ;

initialization

  RegisterTest(TBSTestCanvasScalableMode);
  RegisterTest(TBSAutoTestEdit);


end.
