object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Conversor de Imagens'
  ClientHeight = 560
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnAdd: TButton
      Left = 8
      Top = 6
      Width = 140
      Height = 29
      Caption = 'Adicionar Imagens'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnClear: TButton
      Left = 154
      Top = 6
      Width = 100
      Height = 29
      Caption = 'Limpar Lista'
      TabOrder = 1
      OnClick = btnClearClick
    end
  end
  object lvFiles: TListView
    Left = 0
    Top = 41
    Width = 700
    Height = 300
    Align = alClient
    Columns = <>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 341
    Width = 700
    Height = 219
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblFormat: TLabel
      Left = 8
      Top = 12
      Width = 106
      Height = 15
      Caption = 'Converter para:'
    end
    object lblQuality: TLabel
      Left = 8
      Top = 52
      Width = 55
      Height = 15
      Caption = 'Qualidade:'
    end
    object lblQualityValue: TLabel
      Left = 480
      Top = 52
      Width = 24
      Height = 15
      Caption = '90'
    end
    object lblDestFolder: TLabel
      Left = 8
      Top = 96
      Width = 89
      Height = 15
      Caption = 'Pasta destino:'
    end
    object lblStatus: TLabel
      Left = 8
      Top = 188
      Width = 3
      Height = 15
    end
    object cbFormat: TComboBox
      Left = 120
      Top = 8
      Width = 130
      Height = 23
      TabOrder = 0
    end
    object tbQuality: TTrackBar
      Left = 120
      Top = 44
      Width = 350
      Height = 32
      Max = 100
      Min = 1
      Position = 90
      TabOrder = 1
      OnChange = tbQualityChange
    end
    object edtDestFolder: TEdit
      Left = 120
      Top = 92
      Width = 400
      Height = 23
      TabOrder = 2
    end
    object btnBrowseDest: TButton
      Left = 526
      Top = 91
      Width = 33
      Height = 25
      Caption = '...'
      TabOrder = 3
      OnClick = btnBrowseDestClick
    end
    object chkSameFolder: TCheckBox
      Left = 120
      Top = 122
      Width = 250
      Height = 17
      Caption = 'Salvar na mesma pasta de origem'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chkSameFolderClick
    end
    object btnConvert: TButton
      Left = 8
      Top = 150
      Width = 150
      Height = 32
      Caption = 'Converter'
      TabOrder = 5
      OnClick = btnConvertClick
    end
    object pbProgress: TProgressBar
      Left = 170
      Top = 155
      Width = 522
      Height = 20
      TabOrder = 6
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 616
    Top = 8
  end
end
