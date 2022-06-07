object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Tests Delphi'
  ClientHeight = 602
  ClientWidth = 930
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 225
    Top = 0
    Height = 602
    ExplicitLeft = 24
    ExplicitTop = 168
    ExplicitHeight = 100
  end
  object PanelInfo: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 602
    Align = alLeft
    TabOrder = 0
    OnClick = PanelInfoClick
    DesignSize = (
      225
      602)
    object Label1: TLabel
      Left = 16
      Top = 9
      Width = 74
      Height = 13
      Caption = 'Available tests:'
      Color = clBtnFace
      ParentColor = False
    end
    object LblX: TLabel
      Left = 22
      Top = 53
      Width = 13
      Height = 13
      Caption = 'X: '
      Color = clBtnFace
      ParentColor = False
    end
    object LblY: TLabel
      Left = 108
      Top = 53
      Width = 13
      Height = 13
      Caption = 'Y: '
      Color = clBtnFace
      ParentColor = False
    end
    object lblFontTextures: TLabel
      Left = 10
      Top = 388
      Width = 79
      Height = 13
      Caption = 'Font textures: 0'
    end
    object SbScreenShort: TSpeedButton
      Left = 108
      Top = 387
      Width = 104
      Height = 22
      Caption = 'Get screen short'
      OnClick = SbScreenShortClick
    end
    object LblAllTextures: TLabel
      Left = 10
      Top = 404
      Width = 68
      Height = 13
      Caption = 'All textures: 0'
    end
    object LblSizeTextures: TLabel
      Left = 10
      Top = 419
      Width = 156
      Height = 13
      Caption = 'Size textures, reserved bytes: 0'
    end
    object cbAvailableTests: TComboBox
      Left = 14
      Top = 24
      Width = 198
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbAvailableTestsChange
    end
    object cbMaxFPS: TCheckBox
      Left = 14
      Top = 191
      Width = 67
      Height = 17
      Caption = 'Max FPS'
      Checked = True
      State = cbChecked
      TabOrder = 1
      Visible = False
      OnClick = cbMaxFPSClick
    end
    object GroupBox1: TGroupBox
      Left = 10
      Top = 199
      Width = 202
      Height = 123
      Caption = 'Full screen anti-aliasing'
      TabOrder = 2
      object lblKernel: TLabel
        Left = 28
        Top = 90
        Width = 34
        Height = 13
        Caption = 'Kernel:'
        Enabled = False
      end
      object cbFXAA: TCheckBox
        Left = 12
        Top = 14
        Width = 139
        Height = 17
        Caption = 'Fast approXimate (FXAA)'
        Enabled = False
        TabOrder = 0
        OnClick = cbFXAAClick
      end
      object cbMSAA: TCheckBox
        Left = 12
        Top = 31
        Width = 131
        Height = 17
        Caption = 'Multi Sampling (MSAA)'
        TabOrder = 1
        OnClick = cbMSAAClick
      end
      object cbMSAAByKernel: TCheckBox
        Left = 12
        Top = 67
        Width = 165
        Height = 17
        Caption = 'Multi Sampling (MSAA)'
        Enabled = False
        TabOrder = 2
        OnClick = cbMSAAByKernelClick
      end
      object cbKernels: TComboBox
        Left = 67
        Top = 85
        Width = 110
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 3
        OnChange = cbKernelsChange
      end
      object cbPSSAA: TCheckBox
        Left = 12
        Top = 49
        Width = 187
        Height = 17
        Caption = 'Super Sampling 4x (SSAA) (Soft)'
        Enabled = False
        TabOrder = 4
        OnClick = cbPSSAAClick
      end
    end
    object GroupBox2: TGroupBox
      Left = 10
      Top = 68
      Width = 202
      Height = 109
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Instance property'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      object lblSizeInstance: TLabel
        Left = 12
        Top = 18
        Width = 81
        Height = 13
        Caption = 'Size 3d: (0; 0; 0)'
      end
      object lblPos3d: TLabel
        Left = 12
        Top = 48
        Width = 99
        Height = 13
        Caption = 'Position 3d: (0; 0; 0)'
      end
      object lblPos2d: TLabel
        Left = 12
        Top = 62
        Width = 128
        Height = 13
        Caption = 'Position 2d (center): (0; 0)'
      end
      object vblSize2d: TLabel
        Left = 12
        Top = 33
        Width = 81
        Height = 13
        Caption = 'Size 2d: (0; 0; 0)'
      end
      object lblPos2dLU: TLabel
        Left = 12
        Top = 76
        Width = 129
        Height = 13
        Caption = 'Position 2d (left,up): (0; 0)'
      end
      object LblDistance: TLabel
        Left = 12
        Top = 89
        Width = 99
        Height = 13
        Caption = 'Distance to camera: '
      end
    end
    object btnStart: TBitBtn
      Left = 10
      Top = 328
      Width = 202
      Height = 25
      Caption = 'Start Rotate Camera'
      TabOrder = 4
      Visible = False
      OnClick = btnStartClick
    end
    object MemoEvents: TMemo
      Left = 1
      Top = 466
      Width = 223
      Height = 135
      Align = alBottom
      ScrollBars = ssBoth
      TabOrder = 5
    end
    object BtnOutEvents: TBitBtn
      Left = 10
      Top = 357
      Width = 202
      Height = 25
      Caption = 'Out current registered events'
      TabOrder = 6
      Visible = False
      OnClick = BtnOutEventsClick
    end
    object btnCreateNewContext: TButton
      Left = 6
      Top = 438
      Width = 97
      Height = 20
      Caption = 'In new context'
      TabOrder = 7
      OnClick = btnCreateNewContextClick
    end
  end
  object PanelScreen: TPanel
    Left = 228
    Top = 0
    Width = 702
    Height = 602
    Align = alClient
    TabOrder = 1
    OnMouseMove = PanelScreenMouseMove
  end
  object ActionList: TActionList
    Left = 72
    Top = 560
    object ActnEsc: TAction
      Caption = 'ActnEsc'
      ShortCut = 27
      OnExecute = ActnEscExecute
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 24
    OnTimer = TimerTimer
    Left = 56
    Top = 464
  end
  object TimerUpdate: TTimer
    Interval = 24
    OnTimer = TimerUpdateTimer
    Left = 104
    Top = 464
  end
  object SaveAsPic: TSaveDialog
    Filter = 'Bit maps|*.bmp'
    Left = 136
    Top = 192
  end
end
