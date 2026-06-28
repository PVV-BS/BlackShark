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
  TAVLTreeViewer = class(TForm)
    TreeView: TTreeView;
    Panel1: TPanel;
    btnFillSamples: TBitBtn;
    btnDelNode: TBitBtn;
    btnInsKey35: TBitBtn;
    btnDelRoot: TBitBtn;
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
    btnSelect: TBitBtn;
    BitFind: TBitBtn;
    edtFindValue: TEdit;
    log: TMemo;
    N3: TMenuItem;
    Save: TMenuItem;
    btnFillSeries: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnFillSamplesClick(Sender: TObject);
    procedure btnDelNodeClick(Sender: TObject);
    procedure btnInsKey35Click(Sender: TObject);
    procedure btnDelRootClick(Sender: TObject);
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
  private
    { Private declarations }
    FIntervalsTree: TIntervalsTree;
    FViewSelectList: TListVec<Pointer>;
    FHashIntervals: THashTable<int, TTreeNode>;

    procedure OutToTreeView;
    procedure OnChangeSelection;
  public
    { Public declarations }
  end;

var
  AVLTreeViewer: TAVLTreeViewer;

implementation

{$R *.dfm}

procedure TAVLTreeViewer.BitFindClick(Sender: TObject);
var
  avlNode: int;
  node: TTreeNode;
begin
  avlNode := FIntervalsTree.Find(StrToFloat(edtFindValue.Text));
  if (avlNode >= 0) and FHashIntervals.Find(avlNode, node) then
  begin
    node.Selected := true;
    OnChangeSelection;
  end;
end;

procedure TAVLTreeViewer.btnClearClick(Sender: TObject);
begin
  FIntervalsTree.Clear;
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnDelNodeClick(Sender: TObject);
var
  avlNode: int;
  balance: int8;
  NodeValue: double;
  left, right: int;
  intervals: TIntervals;
  i: Integer;
  min, max: double;
  data: Pointer;
begin
  if TreeView.Selected = nil then
    exit;

  avlNode := int(TreeView.Selected.Data);
  FIntervalsTree.Select(avlNode, left, right, NodeValue, balance, intervals);
  for i := length(intervals) - 1 downto 0 do
  begin
    FIntervalsTree.Select(intervals[i], min, max, data);
    log.Lines.Add(inttostr(trunc(min)));
    log.Lines.Add(inttostr(trunc(max)));
    FIntervalsTree.Delete(intervals[i]);
  end;
  OutToTreeView;
  FullExpandClick(Sender);
end;

procedure TAVLTreeViewer.btnDelRootClick(Sender: TObject);
begin
  //if FIntervalsTree.Root >= 0 then
  //  FIntervalsTree.Delete(FIntervalsTree.Root.Key);
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnFillSamplesClick(Sender: TObject);
begin
  //exit;
  FIntervalsTree.Add(394, 440, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(386, 452, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(397, 447, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(430, 498, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(1, 38, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(58, 113, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(185, 215, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(388, 434, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(154, 175, Pointer(FIntervalsTree.Count));
  FIntervalsTree.Add(34, 47, Pointer(FIntervalsTree.Count));

  OutToTreeView;
end;

procedure TAVLTreeViewer.btnFillSeriesClick(Sender: TObject);
const
  csCount = 1000;
var
  count: Integer;
  timeStart: uint64;
begin
  count := 0;
  FIntervalsTree.Clear;
  timeStart := TThread.GetTickCount64;
  while count < csCount do
  begin
    FIntervalsTree.Add(count, count+1, nil);
    inc(count, 2);
  end;
  log.Lines.Add(IntToStr(TThread.GetTickCount64 - timeStart));
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnInsKey35Click(Sender: TObject);
begin
  OutToTreeView;
end;

procedure TAVLTreeViewer.btnSelectClick(Sender: TObject);
begin
  FViewSelectList.Count := 0;
  FIntervalsTree.Select(454, 654, FViewSelectList);
end;

procedure TAVLTreeViewer.CollapseNode1Click(Sender: TObject);
begin
  if TreeView.Selected = nil then
    exit;
  TreeView.Selected.Collapse(true);
end;

procedure TAVLTreeViewer.DelEditChange(Sender: TObject);
var
  avlNode: int;
  node: TTreeNode;
begin
  avlNode := FIntervalsTree.Find(StrToFloat(DelEdit.Text));
  if (avlNode >= 0) and FHashIntervals.Find(avlNode, node) then
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
  FIntervalsTree := TIntervalsTree.Create(100);
  FViewSelectList := TListVec<Pointer>.Create;
  FHashIntervals := THashTable<int, TTreeNode>.Create(GetHashBlackSharkInt32, Int32CmpBool);
end;

procedure TAVLTreeViewer.FormShow(Sender: TObject);
begin
  Height := Screen.WorkAreaHeight;
  Top := 0;
  btnFillSamplesClick(Sender);
  FullExpandClick(Sender);
  DelEdit.Text := '113';
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

procedure TAVLTreeViewer.OnChangeSelection;
var
  avlNode: int;
  balance: int8;
  NodeValue: double;
  left, right: int;
  intervals: TIntervals;
  i: Integer;
  minIndex, maxIndex: int;
  d: Pointer;
  n: TTreeNode;
  selected: TList;
begin
  if TreeView.Selected <> nil then
  begin
    TreeView.Items.BeginUpdate;
    try
      selected := TList.Create;
      try
        selected.Add(TreeView.Selected);
        avlNode := int(TreeView.Selected.Data);
        FIntervalsTree.Select(avlNode, left, right, NodeValue, balance, intervals);
        DelEdit.Text := IntToStr(trunc(NodeValue));
        for i := 0 to length(intervals) - 1 do
        begin
          FIntervalsTree.Select(intervals[i], minIndex, maxIndex, d);
          if (minIndex <> avlNode) and FHashIntervals.Find(minIndex, n) then
          begin
            selected.Add(n);
            n.MakeVisible;
          end;
          if (maxIndex <> avlNode) and FHashIntervals.Find(maxIndex, n) then
          begin
            selected.Add(n);
            n.MakeVisible;
          end;
        end;
        TreeView.Select(selected);
      finally
        selected.Free;
      end;
    finally
      TreeView.Items.EndUpdate;
    end;
  end;
end;

procedure TAVLTreeViewer.OutToTreeView;

  procedure OutToNode(Parent: TTreeNode; Node: int; LR: string);
  var
    treeNode: TTreeNode;
    balance: int8;
    NodeValue: double;
    left, right: int;
    intervals: TIntervals;
  begin
    FIntervalsTree.Select(Node, left, right, NodeValue, balance, intervals);
    treeNode := TreeView.Items.AddChild(Parent,
      LR + ' = ' + inttostr(trunc(NodeValue)) + '; b=' +
      inttostr(balance){ + '; i=' + inttostr(Node)});
    treeNode.Data := Pointer(Node);
    FHashIntervals.Items[Node] := treeNode;
    if right >= 0 then
      OutToNode(treeNode, right, 'R');
    if left >= 0 then
      OutToNode(treeNode, left, 'L');
  end;

begin
  TreeView.Items.BeginUpdate;
  TreeView.Items.Clear;
  FHashIntervals.Clear();
  if FIntervalsTree.Root >= 0 then
    OutToNode(nil, FIntervalsTree.Root, 'ROOT');
  TreeView.Items.EndUpdate;
  Caption := 'AVLTreeViewer: CountKeys = ' + inttostr(FIntervalsTree.Count);
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

end.
