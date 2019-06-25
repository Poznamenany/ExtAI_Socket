object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 418
  ClientWidth = 833
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lLogServer: TLabel
    Left = 248
    Top = 8
    Width = 52
    Height = 13
    Caption = 'Log Server'
  end
  object lLogExtAIDelphi: TLabel
    Left = 488
    Top = 8
    Width = 79
    Height = 13
    Caption = 'Log ExtAI Delphi'
  end
  object mServerLog: TMemo
    Left = 248
    Top = 24
    Width = 234
    Height = 385
    TabOrder = 0
  end
  object mClientLog: TMemo
    Left = 488
    Top = 24
    Width = 337
    Height = 385
    TabOrder = 1
  end
  object gbExtAI: TGroupBox
    Left = 8
    Top = 112
    Width = 225
    Height = 298
    Caption = 'ExtAI'
    TabOrder = 2
    object gbDelphi: TGroupBox
      Left = 3
      Top = 24
      Width = 206
      Height = 81
      Caption = 'Delphi'
      TabOrder = 0
      object btnClientConnect: TButton
        Left = 11
        Top = 17
        Width = 89
        Height = 25
        Caption = 'Conect client'
        TabOrder = 0
        OnClick = btnClientConnectClick
      end
      object btnClientSendAction: TButton
        Left = 106
        Top = 16
        Width = 89
        Height = 26
        Caption = 'Send action'
        TabOrder = 1
        OnClick = btnClientSendActionClick
      end
      object btnClientSendState: TButton
        Left = 106
        Top = 48
        Width = 89
        Height = 26
        Caption = 'Send state'
        TabOrder = 2
        OnClick = btnClientSendStateClick
      end
    end
    object gbCpp: TGroupBox
      Left = 16
      Top = 255
      Width = 206
      Height = 49
      Caption = 'C++'
      TabOrder = 1
    end
    object gbPython36: TGroupBox
      Left = 14
      Top = 199
      Width = 206
      Height = 50
      Caption = 'Python 3.6'
      TabOrder = 2
    end
  end
  object gbServer: TGroupBox
    Left = 8
    Top = 8
    Width = 225
    Height = 98
    Caption = 'Server'
    TabOrder = 3
    object btnStartServer: TButton
      Left = 11
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Start Server'
      TabOrder = 0
      OnClick = btnStartServerClick
    end
    object btnServerStartMap: TButton
      Left = 106
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Start Map'
      Enabled = False
      TabOrder = 1
      OnClick = btnServerStartMapClick
    end
    object btnSendEvent: TButton
      Left = 106
      Top = 47
      Width = 89
      Height = 25
      Caption = 'Send Event'
      Enabled = False
      TabOrder = 2
      OnClick = btnServerSendEventClick
    end
    object prgServer: TProgressBar
      Left = 11
      Top = 78
      Width = 184
      Height = 11
      TabOrder = 3
    end
  end
end
