unit bs.test.auto.edit;

interface

uses
    bs.test
  , bs.renderer
  , bs.gui.edit
  ;

type
  { TBSAutoTestEdit }

  TBSAutoTestEdit = class(TBSTest)
  private
    const
      TEXT_TEST = '1234567890';
  private
    Edit: TBEdit;
  public
    constructor Create(ARenderer: TBlackSharkRenderer); override;
    destructor Destroy; override;
    function Run: boolean; override;
    class function TestName: string; override;
  end;

implementation

uses
    bs.basetypes
  , bs.events
  , bs.scene
  , bs.canvas
  ;

{ TBSAutoTestEdit }

constructor TBSAutoTestEdit.Create(ARenderer: TBlackSharkRenderer);
begin
  inherited;
  Edit := TBEdit.Create(ARenderer);
end;

destructor TBSAutoTestEdit.Destroy;
begin

  Edit.Free;
  inherited;
end;

function TBSAutoTestEdit.Run: boolean;
var
  selector: TGraphicObject;
begin

  Edit.Text := TEXT_TEST;
  EventRepaintRequest.Send(Self);
  EventMuseDownRequest.Send(Self, round(Edit.Position2d.x + Edit.Width * 0.5),
    round(Edit.Position2d.y + Edit.Height * 0.5), 0, [TBSMouseButton.mbBsLeft], []);
  Result := Edit.Focused;
  if not Result then
    exit;

  Result := vec2(Edit.Width, Edit.Height) = Edit.DefaultSize;
  if not Result then
    exit;

  Edit.SelectAll;
  Result := Edit.CountSelected = length(TEXT_TEST);

  if not Result then
    exit;

  selector := Edit.MainBody.Data.FindObject('selector', false);
  if not Assigned(selector) then
    exit(false);

  Result := (TCanvasObject(selector.Owner).Height < Edit.Height) and (TCanvasObject(selector.Owner).Width < Edit.Width) and
    (TCanvasObject(selector.Owner).Height > Edit.Height*0.5);

  if not Result then
    exit;

  Result := TCanvasObject(selector.Owner).Width >= Edit.TextView.Width;

  if not Result then
    exit;

  Result := true;
end;

class function TBSAutoTestEdit.TestName: string;
begin
  Result := 'TBSAutoTestEdit';
end;

end.
