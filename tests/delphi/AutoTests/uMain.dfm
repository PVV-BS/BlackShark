object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 570
  ClientWidth = 851
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Log: TListView
    Left = 0
    Top = 504
    Width = 851
    Height = 66
    Align = alBottom
    Columns = <
      item
        AutoSize = True
        Caption = 'Message'
      end>
    SmallImages = ImageList
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ImageList: TImageList
    ColorDepth = cd32Bit
    Left = 608
    Top = 464
    Bitmap = {
      494C010103000800040010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000040101011B0606063E0B0B0B540B0B0B5406060641010101200000
      0007000000000000000000000000000000000000000000000000000000000000
      000200000004000000070000000A0000000C0000000E0000000E0000000E0000
      001B0000012C0000012E00000002000000000000000000000000000000010000
      0005000000090000000E000000160000002F0000003000000018000000100000
      000B000000060000000200000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00141D1D1D8C656565E8919191FDA5A5A5FEABABABFE9F9F9FFD666666EF2E2E
      2EAB0303032E0000000000000000000000000001032A0004084700060B5F010C
      16760315258C052139A1073051B40A4270C60E5792D81674BDEA2B97EBFB3EA9
      F8FF20A1FBFF0775DDFC0000002A0000000000000000000000020000000B0000
      0016010103540E0E40BD2222A1F73131B9FF2828B3FF212198F80C0C3AC10000
      035B0000001A0000000F00000005000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000B2121
      21A2969696FDCCCCCCFFE4E4E4FFEAEAEAFFE3E3E3FFD6D6D6FFB8B8B8FFB2B2
      B2FE5D5D5DCA000000200000000000000000032140895DB9F9FF90CDF7FFA0D4
      F7FFB0DBF8FFC0E2F9FFC6DFEFFFE2F1FCFFF2F9FDFFFDFDFDFFFEFEFEFFD0EB
      FDFF269CF6FF002754C100000024000000020000000000000000000000030606
      22900E0EB2FE4E4EC8FF9D9DDDFFA3A4DFFF8F8FDBFF2B2BC0FF1313B8FF2A2A
      A2FE00001E990000000500000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000083B3B3BBEC0C0
      C0FFF6F5F5FFD6C6B3FFC39B6AFFBF8848FFC08645FFBD8F5BFFB6A089FFBBBA
      B9FFC9C9C9FF8C8C8CE10000001F00000000000000144597D9F2F0F2F2FFF2F4
      F4FFF4F5F5FFE6E6E6FF383630FFCDCDCCFFFCFCFCFFFDFDFDFFFEFEFEFF76C6
      FCFF0978E2FC0001034F0000001C00000003000000000000000007072F912021
      BCFFC1C2E5FFF2F3F3FFF4F5F5FFF6F7F7FFF7F8F8FFF4F5F6FF8687D8FF0707
      B6FF2F2FAAFF00002C9B00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000013131382D4D4D4FFEAE5
      DCFFBA8E47FFC78416FFD58E1CFFC19657FFC3934CFFE5991EFFE59A1EFFC78F
      34FFC4BAA9FFDEDEDEFF535353BD000000010000000006213B84C2E0F4FFF1F2
      F2FFF3F4F4FFF4F5F5FFADADABFFF3F4F4FFFAFBFBFFFCFDFDFFD7EEFDFF2A9E
      F7FF00224AA40000000A000000070000000000000000010108441414B3FECCCE
      E6FFAEAEACFFD8D9D8FFF6F7F7FFF9FAFAFFE9E9E8FF757470FFE8E8E8FF8383
      D6FF1313B9FF1C1C9AFF00000A4D000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000D979797F0EDE9E2FFB588
      2BFFC99112FFDDA217FFD5B360FFE3E3E3FFD5BC77FFF1BA29FFFABD1EFFF6BA
      1EFFDBA724FFDBD3BFFFE2E2E2FE0303033C000000000000001163A2D6F0F1F2
      F3FFF1F3F3FFF3F4F4FF92918EFFF7F8F8FFF9FAFAFFFBFBFBFF75C5FCFF0A79
      E3FA0001032300000000000000000000000000000000090953BC7C7DD2FFC0C1
      BFFF37352FFF504E49FFDFDFDEFFEFF0EFFF62605CFF393832FF8A8986FFF1F2
      F4FF2525BEFF2C2CB3FF00004EC6000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000505054DEEEEEEFFBD9D5CFFBD88
      0DFFCF9A11FFE4AE16FFE3C772FFE1E1E1FFCCC4ABFFF8C31CFFFDC81CFFFCC6
      1CFFF3BD1AFFCCA438FFF6F5F4FF2222228300000000000000000B213880CEE7
      F7FFF3F4F4FFF2F4F4FF5D5B57FFF6F7F7FFF8F8F8FFDCEEFAFF289DF9FF0025
      519A000000000000000000000000000000000000000E0A0AA5FBD5D7E8FFEBED
      EDFF888784FF575551FF696763FF7A7874FF575551FF7A7875FFEFF0F0FFF4F5
      F5FF7C7DD4FF2B2BBEFF00008DFE000000160000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001414146DEDE9E4FFAA750DFFBB85
      0CFFCC950FFFE0A813FFEBBA34FFECECEBFFE8E8E8FFDEB53DFFFAC019FFF8BE
      19FFEEB517FFD9A214FFDACEB6FF484848A200000000000000000000000F6CA3
      D3EEF4F5F5FFF5F6F6FF5E5C57FFF1F2F2FFF6F7F7FF82C9FAFF0C78E3F80001
      021E00000000000000000000000000000000000003322020BBFFF0F1F1FFF1F2
      F2FFF0F1F1FF93928FFF65635FFF65635FFF807E7AFFEEEFEEFFF7F8F8FFF5F6
      F6FFB5B6E4FF1B1BBCFF12129EFF0000053C0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000020202078DED5C7FFB6852AFFB57B
      09FFC3880CFFD4970FFFE4A512FFE5D5B1FFEAEAEAFFD5BB7DFFF0B015FFECAC
      14FFE2A312FFD1940FFFCCB385FF5C5C5CB00000000000000000000000000B1E
      337BD4EAF8FFF4F5F5FF797874FFEEEFEEFFE7F2F8FF49ABFAFF00234B940000
      000000000000000000000000000000000000000003363D3DC4FFF1F3F3FFF1F3
      F3FFEFF0F0FF989794FF72716CFF72716CFF878683FFECECECFFF6F7F7FFF4F5
      F5FFC5C6E9FF3434C4FF1515A2FF000006400000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001C1C1C6FDFD6CAFFC7A26CFFBA88
      32FFB77708FFC3820AFFCF8C0DFFD2AA5EFFEAEAEAFFD6BD90FFDF970FFFD993
      0EFFCE8A0CFFC1800AFFC7AB7DFF585858AB0000000000000000000000000000
      000D72A4CDEBF4F5F6FF898885FFEFF0EFFFB0DCFAFF1579DFF60000011A0000
      000000000000000000000000000000000000000000163E3EBCFEEBECF2FFEFF0
      F0FFA0A09DFF807E7AFF8F8F8BFF9C9C99FF807E7AFF969592FFEDEEEEFFF4F5
      F5FFB4B4E5FF5656CDFF01019BFF0000011F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000008080843E5E2DFFFCDAF88FFCEAD
      81FFC59959FFB97817FFBC7407FFC39E67FFE1C7A3FFCA8926FFC87B08FFC378
      08FFBB7306FFB16D05FFCAB89FFF272727770000000000000000000000000000
      00000D1D3077D9ECF9FFECECECFFEDF3F7FF63B6FAFF001F448D000000000000
      00000000000000000000000000000000000000000000232370CEC2C3E9FFD3D3
      D2FF8E8D89FF9B9A98FFE8E9E9FFF0F1F1FFA4A3A1FF8E8D89FFBBBAB8FFF4F5
      F5FF9090DDFF4949C4FF000067D8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000006B3B3B3E8D7C5B1FFD5BA
      9AFFD4B694FFD3B18BFFC99A60FFBE802FFFB6813BFFB59364FFAF6608FFB065
      03FFAC6303FFA16516FFD3D1CFFC020202230000000000000000000000000000
      00000000000B79A3CAE9F5F7F8FFC8E6FBFF1A78DAF300000115000000000000
      000000000000000000000000000000000000000000000303125F8585DAFFEFF0
      F5FFD0D0CEFFEBECEBFFF5F6F6FFF5F6F6FFEFF0F0FFBDBDBBFFF0F1F1FFD1D2
      EDFF6E6ED5FF2626B2FF00001569000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000001C1C1C68E3E0DDFFDBC8
      B3FFDBC4ABFFD9C0A5FFD8BC9FFFD6B898FFECE1D6FFFEFEFEFFC9A986FFC08F
      56FFBB8C54FFD0C1AFFF4A4A4A99000000000000000000000000000000000000
      0000000000000C1B2C72DBEEFBFF7BBFFAFF001C3D8600000000000000000000
      0000000000000000000000000000000000000000000000000001202057B8A8A8
      E4FFF0F0F6FFF6F7F7FFF6F7F7FFF6F7F7FFF6F7F7FFF6F7F7FFDDDEF1FF8989
      DCFF4747C2FF00004FC000000003000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000464646A1E7E4
      E0FFE1D2C3FFE1CDBAFFDFCAB5FFDDC6AFFFDEC8B2FFE7D7C7FFD6BBA0FFD1B5
      9AFFDDD2C8FF838383C70000000B000000000000000000000000000000000000
      000000000000000000097BA1C5E61E76D3F00000001200000000000000000000
      00000000000000000000000000000000000000000000000000000000000D2727
      5FBC9F9FE2FFD1D1EFFFE7E8F4FFECEDF6FFE1E1F3FFC3C3ECFF8686DBFF4646
      C2FF020253C20000001100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000012D2D
      2D7EDEDDDCF8EEE8E1FFE7DBCFFFE2D3C3FFE0CFBEFFE1D1C2FFE5DBD0FFE7E5
      E3FE5252529F0000000B00000000000000000000000000000000000000000000
      00000000000000000000030A134D000B19570000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000308081B6C4F4F95E19090DCFF9595E0FF8A8ADCFF5858C8FF1D1D83E40000
      1972000000040000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000202021E383838818D8D8DC5C4C4C4E6C9C9C9E8989898CC4242428F0505
      052F000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000010000032E01010B5200000B5200000330000000020000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 352
    Top = 136
  end
end