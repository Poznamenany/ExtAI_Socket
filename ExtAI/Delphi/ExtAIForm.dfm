object ExtAI: TExtAI
  Left = 0
  Top = 0
  Caption = 'ExtAI'
  ClientHeight = 268
  ClientWidth = 374
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
  object gbExtAI: TGroupBox
    Left = 8
    Top = 8
    Width = 358
    Height = 252
    Caption = 'Ext AI Delphi'
    TabOrder = 0
    object labPort: TLabel
      Left = 9
      Top = 21
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object btnConnectClient: TButton
      Left = 3
      Top = 45
      Width = 97
      Height = 25
      Caption = 'Connect Client'
      TabOrder = 0
      OnClick = btnConnectClientClick
    end
    object btnSendAction: TButton
      Left = 3
      Top = 87
      Width = 97
      Height = 25
      Caption = 'Send Action'
      Enabled = False
      TabOrder = 1
      OnClick = btnSendActionClick
    end
    object btnSendState: TButton
      Left = 3
      Top = 118
      Width = 97
      Height = 25
      Caption = 'Send State'
      Enabled = False
      TabOrder = 2
    end
    object edPort: TEdit
      Left = 39
      Top = 18
      Width = 44
      Height = 21
      NumbersOnly = True
      TabOrder = 3
      Text = '1234'
    end
    object mLog: TMemo
      Left = 106
      Top = 18
      Width = 249
      Height = 231
      Lines.Strings = (
        'mLog')
      ScrollBars = ssVertical
      TabOrder = 4
    end
  end
end
