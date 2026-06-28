object AVLTreeViewer: TAVLTreeViewer
  Left = 0
  Top = 0
  Caption = 'AVLTreeViewer'
  ClientHeight = 553
  ClientWidth = 661
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object TreeView: TTreeView
    Left = 0
    Top = 81
    Width = 661
    Height = 399
    Align = alClient
    HideSelection = False
    Indent = 19
    MultiSelect = True
    MultiSelectStyle = []
    PopupMenu = PopupMenu
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    OnClick = TreeViewClick
    ExplicitHeight = 472
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 661
    Height = 81
    Align = alTop
    TabOrder = 1
    ExplicitTop = -6
    object btnFillSamples: TBitBtn
      Left = 5
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Fill samples'
      TabOrder = 0
      OnClick = btnFillSamplesClick
    end
    object btnDelNode: TBitBtn
      Left = 171
      Top = 13
      Width = 72
      Height = 25
      Caption = 'Delete'
      TabOrder = 1
      OnClick = btnDelNodeClick
    end
    object btnInsKey35: TBitBtn
      Left = 254
      Top = 13
      Width = 68
      Height = 25
      Caption = 'Insert'
      TabOrder = 2
      OnClick = btnInsKey35Click
    end
    object btnDelRoot: TBitBtn
      Left = 468
      Top = 13
      Width = 62
      Height = 25
      Caption = 'DelRoot'
      TabOrder = 3
      OnClick = btnDelRootClick
    end
    object btnClear: TBitBtn
      Left = 536
      Top = 13
      Width = 62
      Height = 25
      Caption = 'Clear'
      TabOrder = 4
      OnClick = btnClearClick
    end
    object DelEdit: TEdit
      Left = 171
      Top = 47
      Width = 72
      Height = 21
      TabOrder = 5
      Text = '0'
      OnChange = DelEditChange
    end
    object IncertEdit: TEdit
      Left = 254
      Top = 47
      Width = 68
      Height = 21
      TabOrder = 6
      Text = '0'
      OnKeyPress = IncertEditKeyPress
    end
    object btnSelect: TBitBtn
      Left = 400
      Top = 13
      Width = 62
      Height = 25
      Caption = 'Select'
      TabOrder = 7
      OnClick = btnSelectClick
    end
    object BitFind: TBitBtn
      Left = 331
      Top = 13
      Width = 62
      Height = 25
      Caption = 'Find'
      TabOrder = 8
      OnClick = BitFindClick
    end
    object edtFindValue: TEdit
      Left = 331
      Top = 47
      Width = 68
      Height = 21
      TabOrder = 9
      Text = '0'
      OnKeyPress = IncertEditKeyPress
    end
    object btnFillSeries: TBitBtn
      Left = 86
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Fill series'
      TabOrder = 10
      OnClick = btnFillSeriesClick
    end
  end
  object log: TMemo
    Left = 0
    Top = 480
    Width = 661
    Height = 73
    Align = alBottom
    TabOrder = 2
    ExplicitWidth = 471
  end
  object PopupMenu: TPopupMenu
    Left = 240
    Top = 240
    object TMenuItem
    end
    object FullExpand: TMenuItem
      Caption = 'FullExpand'
      OnClick = FullExpandClick
    end
    object FullCollapse: TMenuItem
      Caption = 'FullCollapse'
      OnClick = FullCollapseClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExpandNode: TMenuItem
      Caption = 'ExpandNode'
      OnClick = ExpandNodeClick
    end
    object CollapseNode1: TMenuItem
      Caption = 'CollapseNode'
      OnClick = CollapseNode1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object StayOnTop: TMenuItem
      Caption = 'StayOnTop'
      OnClick = StayOnTopClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Save: TMenuItem
      Caption = 'Save'
      OnClick = SaveClick
    end
  end
end
