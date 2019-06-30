object ExtAI_TestBed: TExtAI_TestBed
  Left = 0
  Top = 0
  Caption = 'ExtAI_TestBed'
  ClientHeight = 537
  ClientWidth = 855
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
  object gbKP: TGroupBox
    Left = 8
    Top = 8
    Width = 513
    Height = 521
    Caption = 'KP'
    TabOrder = 0
    object gbLobby: TGroupBox
      Left = 3
      Top = 87
      Width = 280
      Height = 314
      Caption = 'Lobby'
      TabOrder = 0
      object labLoc1: TLabel
        Left = 15
        Top = 67
        Width = 10
        Height = 13
        Caption = '1.'
      end
      object labLoc2: TLabel
        Left = 15
        Top = 87
        Width = 10
        Height = 13
        Caption = '2.'
      end
      object labLoc3: TLabel
        Left = 15
        Top = 107
        Width = 10
        Height = 13
        Caption = '3.'
      end
      object labLoc4: TLabel
        Left = 15
        Top = 137
        Width = 10
        Height = 13
        Caption = '4.'
      end
      object labLoc5: TLabel
        Left = 15
        Top = 157
        Width = 10
        Height = 13
        Caption = '5.'
      end
      object labLoc6: TLabel
        Left = 15
        Top = 177
        Width = 10
        Height = 13
        Caption = '6.'
      end
      object labLoc7: TLabel
        Left = 15
        Top = 197
        Width = 10
        Height = 13
        Caption = '7.'
      end
      object labLoc8: TLabel
        Left = 15
        Top = 227
        Width = 10
        Height = 13
        Caption = '8.'
      end
      object labLoc9: TLabel
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
      object labLoc0: TLabel
        Left = 15
        Top = 47
        Width = 10
        Height = 13
        Caption = '0.'
      end
      object cbLoc0: TComboBox
        Left = 30
        Top = 44
        Width = 130
        Height = 21
        TabOrder = 0
        Text = 'cbLoc0'
      end
      object cbLoc1: TComboBox
        Left = 30
        Top = 64
        Width = 130
        Height = 21
        TabOrder = 1
        Text = 'cbLoc1'
      end
      object cbLoc2: TComboBox
        Left = 31
        Top = 84
        Width = 130
        Height = 21
        TabOrder = 2
        Text = 'cbLoc2'
      end
      object edLoc0: TEdit
        Left = 166
        Top = 44
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 3
      end
      object edLoc1: TEdit
        Left = 166
        Top = 64
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 4
      end
      object edLoc2: TEdit
        Left = 166
        Top = 84
        Width = 100
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
      object cbLoc3: TComboBox
        Left = 31
        Top = 104
        Width = 130
        Height = 21
        TabOrder = 7
        Text = 'cbLoc2'
      end
      object edLoc3: TEdit
        Left = 166
        Top = 104
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 8
      end
      object cbLoc4: TComboBox
        Left = 31
        Top = 134
        Width = 130
        Height = 21
        TabOrder = 9
        Text = 'cbLoc2'
      end
      object edLoc4: TEdit
        Left = 166
        Top = 134
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 10
      end
      object cbLoc5: TComboBox
        Left = 31
        Top = 154
        Width = 130
        Height = 21
        TabOrder = 11
        Text = 'cbLoc2'
      end
      object edLoc5: TEdit
        Left = 166
        Top = 154
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 12
      end
      object cbLoc6: TComboBox
        Left = 31
        Top = 174
        Width = 130
        Height = 21
        TabOrder = 13
        Text = 'cbLoc2'
      end
      object edLoc6: TEdit
        Left = 166
        Top = 174
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 14
      end
      object cbLoc8: TComboBox
        Left = 31
        Top = 224
        Width = 130
        Height = 21
        TabOrder = 15
        Text = 'cbLoc2'
      end
      object edLoc8: TEdit
        Left = 166
        Top = 224
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 16
      end
      object cbLoc9: TComboBox
        Left = 31
        Top = 244
        Width = 130
        Height = 21
        TabOrder = 17
        Text = 'cbLoc2'
      end
      object edLoc9: TEdit
        Left = 167
        Top = 244
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 18
      end
      object edLoc7: TEdit
        Left = 166
        Top = 194
        Width = 100
        Height = 21
        Enabled = False
        TabOrder = 19
      end
      object cbLoc7: TComboBox
        Left = 31
        Top = 194
        Width = 130
        Height = 21
        TabOrder = 20
        Text = 'cbLoc2'
      end
      object edLoc10: TEdit
        Left = 167
        Top = 264
        Width = 100
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
        Text = 'cbLoc2'
      end
      object edLoc11: TEdit
        Left = 167
        Top = 284
        Width = 100
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
        Text = 'cbLoc2'
      end
    end
    object gbServer: TGroupBox
      Left = 3
      Top = 15
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
    object mServerLog: TMemo
      Left = 289
      Top = 15
      Width = 221
      Height = 503
      TabOrder = 2
    end
    object gbSimulation: TGroupBox
      Left = 3
      Top = 407
      Width = 280
      Height = 111
      Caption = 'Simulation'
      TabOrder = 3
      object btnServerStartMap: TButton
        Left = 3
        Top = 16
        Width = 89
        Height = 25
        Caption = 'Start Map'
        Enabled = False
        TabOrder = 0
        OnClick = btnServerStartMapClick
      end
      object btnSendEvent: TButton
        Left = 3
        Top = 47
        Width = 89
        Height = 25
        Caption = 'Send Event'
        Enabled = False
        TabOrder = 1
        OnClick = btnServerSendEventClick
      end
      object btnSendState: TButton
        Left = 3
        Top = 78
        Width = 89
        Height = 25
        Caption = 'Send State'
        Enabled = False
        TabOrder = 2
        OnClick = btnServerSendEventClick
      end
    end
  end
  object gbExtAIs: TGroupBox
    Left = 527
    Top = 8
    Width = 322
    Height = 521
    Caption = 'ExtAIs'
    TabOrder = 1
    object gbAIControlInterface: TGroupBox
      Left = 3
      Top = 46
      Width = 316
      Height = 74
      Caption = 'Control interface'
      TabOrder = 0
      object btnClientConnect: TButton
        Left = 11
        Top = 40
        Width = 89
        Height = 25
        Caption = 'Connect client'
        TabOrder = 0
        OnClick = btnClientConnectClick
      end
      object btnClientSendAction: TButton
        Left = 106
        Top = 40
        Width = 89
        Height = 25
        Caption = 'Send action'
        Enabled = False
        TabOrder = 1
        OnClick = btnClientSendActionClick
      end
      object btnClientSendState: TButton
        Left = 201
        Top = 40
        Width = 89
        Height = 25
        Caption = 'Send state'
        Enabled = False
        TabOrder = 2
        OnClick = btnClientSendStateClick
      end
      object chbControlAll: TCheckBox
        Left = 11
        Top = 18
        Width = 134
        Height = 17
        Caption = 'Control all AI at once'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = chbControlAllClick
      end
    end
    object btnCreateExtAI: TButton
      Left = 19
      Top = 15
      Width = 85
      Height = 25
      Caption = 'Create new AI'
      TabOrder = 1
      OnClick = btnCreateExtAIClick
    end
    object btnTerminateExtAIs: TButton
      Left = 206
      Top = 15
      Width = 94
      Height = 25
      Caption = 'Terminate all AIs'
      TabOrder = 2
      OnClick = btnTerminateExtAIsClick
    end
    object pcLogExtAI: TPageControl
      Left = 3
      Top = 126
      Width = 316
      Height = 392
      TabOrder = 3
      OnChange = pcOnChangeTab
    end
    object btnTerminateAI: TButton
      Left = 110
      Top = 15
      Width = 85
      Height = 25
      Caption = 'Terminate AI'
      TabOrder = 4
      OnClick = btnTerminateExtAIClick
    end
  end
end
