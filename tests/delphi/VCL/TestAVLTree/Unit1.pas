unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  bs.geometry.kdtree,
  bs.collections;

type

  TAvlTree = TAvlTree<Int32, TTreeNode>;
  TAVLTreeViewer = class(TForm)
    TreeView: TTreeView;
    Panel1: TPanel;
    btnFillSamples: TBitBtn;
    btnDelNode: TBitBtn;
    btnInsKey35: TBitBtn;
    btnDelRandom: TBitBtn;
    PopupMenu: TPopupMenu;
    FullExpand: TMenuItem;
    FullCollapse: TMenuItem;
    N1: TMenuItem;
    ExpandNode: TMenuItem;
    CollapseNode1: TMenuItem;
    N2: TMenuItem;
    StayOnTop: TMenuItem;
    btnClear: TBitBtn;
    DelEdit: TEdit;
    IncertEdit: TEdit;
    BitFind: TBitBtn;
    edtFindValue: TEdit;
    log: TMemo;
    N3: TMenuItem;
    Save: TMenuItem;
    btnFillSeries: TBitBtn;
    StatusBar: TStatusBar;
    edtRandomCount: TEdit;
    N4: TMenuItem;
    miDeleteMemoSet: TMenuItem;
    edtSeriesSize: TEdit;
    addFromMemoSet: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnFillSamplesClick(Sender: TObject);
    procedure btnDelNodeClick(Sender: TObject);
    procedure btnInsKey35Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FullExpandClick(Sender: TObject);
    procedure FullCollapseClick(Sender: TObject);
    procedure ExpandNodeClick(Sender: TObject);
    procedure CollapseNode1Click(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure IncertEditKeyPress(Sender: TObject; var Key: Char);
    procedure btnSelectClick(Sender: TObject);
    procedure BitFindClick(Sender: TObject);
    procedure TreeViewClick(Sender: TObject);
    procedure DelEditChange(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure btnFillSeriesClick(Sender: TObject);
    procedure btnDelRandomClick(Sender: TObject);
    procedure miDeleteMemoSetClick(Sender: TObject);
    procedure addFromMemoSetClick(Sender: TObject);
  private
    { Private declarations }
    FAvlTree: TAvlTree;
    FViewSelectList: TListVec<Pointer>;
    FHashIntervals: THashTable<int32, TTreeNode>;

    procedure OutToTreeView;
    procedure OnChangeSelection;
    procedure UpdateStatusBar;
  public
    { Public declarations }
  end;

var
  AVLTreeViewer: TAVLTreeViewer;

implementation

{$R *.dfm}

procedure TAVLTreeViewer.addFromMemoSetClick(Sender: TObject);
var
  i: Integer;
  val: int32;
begin
  for i := 0 to log.Lines.Count - 1 do
  begin

    if TryStrToInt(log.Lines.Strings[i], val) then
    begin
      FAvlTree.Add(val, nil);
    end;

  end;
  OutToTreeView;
  FullExpandClick(Sender);
  SaveClick(Sender);
end;

procedure TAVLTreeViewer.BitFindClick(Sender: TObject);
var
  node: TTreeNode;
begin
  if FAvlTree.Find(StrToInt(edtFindValue.Text), node) then
  begin
    node.Selected := true;
    OnChangeSelection;
  end;
end;

procedure TAVLTreeViewer.btnClearClick(Sender: TObject);
begin
  FAvlTree.Clear;
  log.Clear;
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnDelNodeClick(Sender: TObject);
var
  balance: int8;
  Key: int32;
  left, right: Pointer;
  n: TTreeNode;
begin
  if TreeView.Selected <> nil then
  begin
    FAvlTree.Select(TreeView.Selected.Data, left, right, Key, n, balance);
    FAvlTree.Delete(Key);
    OutToTreeView;
    FullExpandClick(Sender);
    log.Lines.Add(IntToStr(Key));
    UpdateStatusBar;
  end;

end;

procedure TAVLTreeViewer.btnDelRandomClick(Sender: TObject);
var
  count: Integer;
  delta: Integer;
  i: Integer;
  key: Integer;
  keys: TArray<Integer>;
  ind: Integer;
  keysDeleted: THashTable<int32, int32>;
begin
  delta := FAvlTree.Count - 1;
  keys := FAvlTree.Keys;
  count := StrToInt(edtRandomCount.Text);
  if count > FAvlTree.Count then
    count := FAvlTree.Count;

  log.Lines.Clear;
  keysDeleted := THashTable<int32, int32>.Create;
  for i := 0 to count - 1 do
  begin
    repeat
      ind := Random(delta);
    until not keysDeleted.Exists(keys[ind]);
    keysDeleted.Items[keys[ind]] := ind;
    key := keys[ind];
    FAvlTree.Delete(key);
    log.Lines.Add(IntToStr(key));
  end;
  keysDeleted.Free;
  OutToTreeView;
  FullExpandClick(Sender);
  UpdateStatusBar;
  SaveClick(Sender);
  //log.SelectAll;
  //log.CopyToClipboard;
end;

procedure TAVLTreeViewer.btnFillSamplesClick(Sender: TObject);
begin
  //btnFillSeriesClick(Sender);
  //btnDelRandomClick(Sender);
  //miDeleteMemoSetClick(Sender);
  //DelEdit.Text := '85';
  exit;
  FAvlTree.Add(394, nil);
  FAvlTree.Add(440, nil);
  FAvlTree.Add(386, nil);
  FAvlTree.Add(452, nil);
  FAvlTree.Add(397, nil);
  FAvlTree.Add(447, nil);
  FAvlTree.Add(430, nil); FAvlTree.Add(498, nil);
  FAvlTree.Add(1, nil); FAvlTree.Add(38, nil);
  FAvlTree.Add(58, nil);
  FAvlTree.Add(113, nil);
  FAvlTree.Add(185, nil); FAvlTree.Add(215, nil);
  FAvlTree.Add(388, nil); FAvlTree.Add(434, nil);
  FAvlTree.Add(154, nil); FAvlTree.Add(175, nil);
  FAvlTree.Add(34, nil); FAvlTree.Add(47, nil);

  FAvlTree.Delete(113);
  FAvlTree.Delete(394);
  FAvlTree.Delete(58);
  //FAvlTree.Delete(386);

  OutToTreeView;
end;

procedure TAVLTreeViewer.btnFillSeriesClick(Sender: TObject);
var
  i, k, count: Integer;
  timeStart: uint64;
begin
  FAvlTree.Clear;
  timeStart := TThread.GetTickCount64;

  count := StrToInt(edtSeriesSize.Text);
  i := 0;
  while i < count do
  begin
    k := random(1000000);
    if FAvlTree.Exists(k) then
      continue;
    inc(i);
    FAvlTree.Add(k, nil);
    log.Lines.Add(IntToStr(k));
  end;
  //log.Lines.Add(IntToStr(TThread.GetTickCount64 - timeStart));
  OutToTreeView;
  FullExpandClick(Sender);
  SaveClick(Sender);
end;

procedure TAVLTreeViewer.btnInsKey35Click(Sender: TObject);
begin
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnSelectClick(Sender: TObject);
begin
  FViewSelectList.Count := 0;
  //FIntervalsTree.Select(454, 654, FViewSelectList);
end;

procedure TAVLTreeViewer.CollapseNode1Click(Sender: TObject);
begin
  if TreeView.Selected = nil then
    exit;
  TreeView.Selected.Collapse(true);
end;

procedure TAVLTreeViewer.DelEditChange(Sender: TObject);
var
  node: TTreeNode;
begin
  if FHashIntervals.Find(StrToInt(DelEdit.Text), node) then
  begin
    node.Selected := true;
    OnChangeSelection;
  end;
  //btnDelNode.Caption := 'Del key ' + DelEdit.text;
end;

procedure TAVLTreeViewer.ExpandNodeClick(Sender: TObject);
begin
  if TreeView.Selected = nil then
    exit;
  TreeView.Selected.Expand(true);
end;

procedure TAVLTreeViewer.FormCreate(Sender: TObject);
begin
  FAvlTree := TAvlTree.Create;
  FViewSelectList := TListVec<Pointer>.Create;
  FHashIntervals := THashTable<int32, TTreeNode>.Create; //(GetHashBlackSharkInt32, Int32CmpBool)
  Randomize;
end;

procedure TAVLTreeViewer.FormShow(Sender: TObject);
begin
  Height := Screen.WorkAreaHeight;
  Top := 0;
  btnFillSamplesClick(Sender);
  FullExpandClick(Sender);
end;

procedure TAVLTreeViewer.FullCollapseClick(Sender: TObject);
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.FullCollapse;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TAVLTreeViewer.FullExpandClick(Sender: TObject);
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.FullExpand;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TAVLTreeViewer.IncertEditKeyPress(Sender: TObject; var Key: Char);
begin
  btnInsKey35.Caption := 'Ins key ' + IncertEdit.text;
end;

procedure TAVLTreeViewer.miDeleteMemoSetClick(Sender: TObject);
var
  i: Integer;
  val: int32;
begin
  for i := 0 to log.Lines.Count - 1 do
  begin

    if TryStrToInt(log.Lines.Strings[i], val) then
    begin
      FAvlTree.Delete(val);
    end;

  end;
  OutToTreeView;
  SaveClick(Sender);
end;

procedure TAVLTreeViewer.OnChangeSelection;
var
  balance: int8;
  Key: int32;
  left, right: Pointer;
  n: TTreeNode;
begin
  if TreeView.Selected <> nil then
  begin
    FAvlTree.Select(TreeView.Selected.Data, left, right, Key, n, balance);
    DelEdit.Text := IntToStr(Key);
  end;
end;

procedure TAVLTreeViewer.OutToTreeView;

  procedure OutToNode(Parent: TTreeNode; Node: Pointer; LR: string);
  var
    treeNode: TTreeNode;
    balance: int8;
    key: integer;
    value: TTreeNode;
    left, right: Pointer;
  begin
    FAvlTree.Select(Node, left, right, key, value, balance);
    treeNode := TreeView.Items.AddChild(Parent,
      LR + ' = ' + inttostr(key) + '; b = ' +
      inttostr(balance){ + '; i=' + inttostr(Node)});
    treeNode.Data := Pointer(Node);
    FHashIntervals.Items[key] := treeNode;
    if Assigned(right) then
      OutToNode(treeNode, right, 'R');
    if Assigned(left) then
      OutToNode(treeNode, left, 'L');
  end;

begin
  TreeView.Items.BeginUpdate;
  TreeView.Items.Clear;
  FHashIntervals.Clear();
  if Assigned(FAvlTree.Root) then
    OutToNode(nil, FAvlTree.Root, 'ROOT');
  TreeView.Items.EndUpdate;
  Caption := 'AVLTreeViewer: CountKeys = ' + inttostr(FAvlTree.Count);
  UpdateStatusBar;
end;

procedure TAVLTreeViewer.SaveClick(Sender: TObject);
begin
  TreeView.SaveToFile('AvlTreeTest.txt');
end;

procedure TAVLTreeViewer.StayOnTopClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TAVLTreeViewer.TreeViewClick(Sender: TObject);
begin
  OnChangeSelection;
end;

procedure TAVLTreeViewer.UpdateStatusBar;
begin
  StatusBar.Panels.Items[0].Text := 'Count = ' + IntToStr(FAvlTree.Count);
end;

end.
