object Game_form: TGame_form
  Left = 0
  Top = 0
  Caption = 'KP_Form'
  ClientHeight = 518
  ClientWidth = 523
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
  object gbLobby: TGroupBox
    Left = 8
    Top = 79
    Width = 280
    Height = 314
    Caption = 'Lobby'
    TabOrder = 0
    object labLoc01: TLabel
      Left = 15
      Top = 67
      Width = 10
      Height = 13
      Caption = '1.'
    end
    object labLoc02: TLabel
      Left = 15
      Top = 87
      Width = 10
      Height = 13
      Caption = '2.'
    end
    object labLoc03: TLabel
      Left = 15
      Top = 107
      Width = 10
      Height = 13
      Caption = '3.'
    end
    object labLoc04: TLabel
      Left = 15
      Top = 137
      Width = 10
      Height = 13
      Caption = '4.'
    end
    object labLoc05: TLabel
      Left = 15
      Top = 157
      Width = 10
      Height = 13
      Caption = '5.'
    end
    object labLoc06: TLabel
      Left = 15
      Top = 177
      Width = 10
      Height = 13
      Caption = '6.'
    end
    object labLoc07: TLabel
      Left = 15
      Top = 197
      Width = 10
      Height = 13
      Caption = '7.'
    end
    object labLoc08: TLabel
      Left = 15
      Top = 227
      Width = 10
      Height = 13
      Caption = '8.'
    end
    object labLoc09: TLabel
      Left = 15
      Top = 247
      Width = 10
      Height = 13
      Caption = '9.'
    end
    object labLoc10: TLabel
      Left = 10
      Top = 267
      Width = 16
      Height = 13
      Caption = '10.'
    end
    object labLoc11: TLabel
      Left = 10
      Top = 287
      Width = 16
      Height = 13
      Caption = '11.'
    end
    object labLoc00: TLabel
      Left = 15
      Top = 47
      Width = 10
      Height = 13
      Caption = '0.'
    end
    object cbLoc00: TComboBox
      Left = 30
      Top = 44
      Width = 130
      Height = 21
      TabOrder = 0
      OnChange = cbOnChange
    end
    object cbLoc01: TComboBox
      Left = 30
      Top = 64
      Width = 130
      Height = 21
      TabOrder = 1
      OnChange = cbOnChange
    end
    object cbLoc02: TComboBox
      Left = 31
      Top = 84
      Width = 130
      Height = 21
      TabOrder = 2
      OnChange = cbOnChange
    end
    object edPingLoc00: TEdit
      Left = 166
      Top = 44
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 3
    end
    object edPingLoc01: TEdit
      Left = 166
      Top = 64
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 4
    end
    object edPingLoc02: TEdit
      Left = 166
      Top = 84
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 5
    end
    object btnAutoFill: TButton
      Left = 72
      Top = 13
      Width = 153
      Height = 25
      Caption = 'Auto Fill'
      TabOrder = 6
      OnClick = btnAutoFillClick
    end
    object cbLoc03: TComboBox
      Left = 31
      Top = 104
      Width = 130
      Height = 21
      TabOrder = 7
      OnChange = cbOnChange
    end
    object edPingLoc03: TEdit
      Left = 166
      Top = 104
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 8
    end
    object cbLoc04: TComboBox
      Left = 31
      Top = 134
      Width = 130
      Height = 21
      TabOrder = 9
      OnChange = cbOnChange
    end
    object edPingLoc04: TEdit
      Left = 166
      Top = 134
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 10
    end
    object cbLoc05: TComboBox
      Left = 31
      Top = 154
      Width = 130
      Height = 21
      TabOrder = 11
      OnChange = cbOnChange
    end
    object edPingLoc05: TEdit
      Left = 166
      Top = 154
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 12
    end
    object cbLoc06: TComboBox
      Left = 31
      Top = 174
      Width = 130
      Height = 21
      TabOrder = 13
      OnChange = cbOnChange
    end
    object edPingLoc06: TEdit
      Left = 166
      Top = 174
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 14
    end
    object cbLoc08: TComboBox
      Left = 31
      Top = 224
      Width = 130
      Height = 21
      TabOrder = 15
      OnChange = cbOnChange
    end
    object edPingLoc08: TEdit
      Left = 166
      Top = 224
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 16
    end
    object cbLoc09: TComboBox
      Left = 31
      Top = 244
      Width = 130
      Height = 21
      TabOrder = 17
      OnChange = cbOnChange
    end
    object edPingLoc09: TEdit
      Left = 166
      Top = 244
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 18
    end
    object edPingLoc07: TEdit
      Left = 166
      Top = 194
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 19
    end
    object cbLoc07: TComboBox
      Left = 31
      Top = 194
      Width = 130
      Height = 21
      TabOrder = 20
      OnChange = cbOnChange
    end
    object edPingLoc10: TEdit
      Left = 166
      Top = 264
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 21
    end
    object cbLoc10: TComboBox
      Left = 32
      Top = 264
      Width = 130
      Height = 21
      TabOrder = 22
      OnChange = cbOnChange
    end
    object edPingLoc11: TEdit
      Left = 166
      Top = 284
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 23
    end
    object cbLoc11: TComboBox
      Left = 32
      Top = 284
      Width = 130
      Height = 21
      TabOrder = 24
      OnChange = cbOnChange
    end
  end
  object gbServer: TGroupBox
    Left = 8
    Top = 7
    Width = 280
    Height = 66
    Caption = 'Server'
    TabOrder = 1
    object labPortNumber: TLabel
      Left = 162
      Top = 19
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object btnStartServer: TButton
      Left = 11
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Start Server'
      TabOrder = 0
      OnClick = btnStartServerClick
    end
    object prgServer: TProgressBar
      Left = 12
      Top = 47
      Width = 255
      Height = 11
      TabOrder = 1
    end
    object edServerPort: TEdit
      Left = 192
      Top = 16
      Width = 74
      Height = 21
      NumbersOnly = True
      TabOrder = 2
      Text = '1234'
    end
  end
  object gbSimulation: TGroupBox
    Left = 8
    Top = 399
    Width = 280
    Height = 111
    Caption = 'Simulation'
    TabOrder = 2
    object btnServerStartMap: TButton
      Left = 3
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Start Map'
      Enabled = False
      TabOrder = 0
    end
    object btnSendEvent: TButton
      Left = 3
      Top = 47
      Width = 89
      Height = 25
      Caption = 'Send Event'
      Enabled = False
      TabOrder = 1
    end
    object btnSendState: TButton
      Left = 3
      Top = 78
      Width = 89
      Height = 25
      Caption = 'Send State'
      Enabled = False
      TabOrder = 2
    end
  end
  object mTutorial: TMemo
    Left = 293
    Top = 8
    Width = 222
    Height = 73
    Enabled = False
    Lines.Strings = (
      '1. Start the server'
      '2. Create new AI '
      '3. Select the AI in lobby list'
      '4. Start the map')
    ReadOnly = True
    TabOrder = 3
  end
  object mServerLog: TMemo
    Left = 294
    Top = 88
    Width = 221
    Height = 422
    TabOrder = 4
  end
end
