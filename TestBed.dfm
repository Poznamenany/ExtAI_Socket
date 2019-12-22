object ExtAI_TestBed: TExtAI_TestBed
  Left = 0
  Top = 0
  Caption = 'ExtAI_TestBed'
  ClientHeight = 671
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gbKP: TGroupBox
    Left = 8
    Top = 8
    Width = 636
    Height = 662
    Caption = 'KP'
    TabOrder = 0
    object gbLobby: TGroupBox
      Left = 3
      Top = 280
      Width = 280
      Height = 314
      Caption = 'Lobby'
      TabOrder = 0
      object labLoc01: TLabel
        Left = 17
        Top = 67
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '1.'
      end
      object labLoc02: TLabel
        Left = 17
        Top = 87
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '2.'
      end
      object labLoc03: TLabel
        Left = 17
        Top = 107
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '3.'
      end
      object labLoc04: TLabel
        Left = 17
        Top = 137
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '4.'
      end
      object labLoc05: TLabel
        Left = 17
        Top = 157
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '5.'
      end
      object labLoc06: TLabel
        Left = 17
        Top = 177
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '6.'
      end
      object labLoc07: TLabel
        Left = 17
        Top = 197
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '7.'
      end
      object labLoc08: TLabel
        Left = 17
        Top = 227
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '8.'
      end
      object labLoc09: TLabel
        Left = 17
        Top = 247
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '9.'
      end
      object labLoc10: TLabel
        Left = 11
        Top = 267
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Caption = '10.'
      end
      object labLoc11: TLabel
        Left = 11
        Top = 287
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Caption = '11.'
      end
      object labLoc00: TLabel
        Left = 17
        Top = 47
        Width = 10
        Height = 13
        Alignment = taRightJustify
        Caption = '0.'
      end
      object cbLoc00: TComboBox
        Left = 30
        Top = 44
        Width = 130
        Height = 21
        TabOrder = 0
        OnChange = cbOnChange
        OnDropDown = cbOnChange
      end
      object cbLoc01: TComboBox
        Left = 30
        Top = 64
        Width = 130
        Height = 21
        TabOrder = 1
        OnChange = cbOnChange
        OnDropDown = cbOnChange
      end
      object cbLoc02: TComboBox
        Left = 31
        Top = 84
        Width = 130
        Height = 21
        TabOrder = 2
        OnChange = cbOnChange
        OnDropDown = cbOnChange
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
        Left = 205
        Top = 24
        Width = 61
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
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
        OnDropDown = cbOnChange
      end
      object stExtAIName: TStaticText
        Left = 32
        Top = 24
        Width = 82
        Height = 17
        Alignment = taCenter
        Caption = 'Loc of the ExtAI'
        Color = clBackground
        ParentColor = False
        TabOrder = 25
      end
      object stPing: TStaticText
        Left = 166
        Top = 24
        Width = 24
        Height = 17
        Alignment = taCenter
        Caption = 'Ping'
        Color = clBackground
        ParentColor = False
        TabOrder = 26
      end
    end
    object gbServer: TGroupBox
      Left = 3
      Top = 208
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
      Left = 3
      Top = 600
      Width = 280
      Height = 59
      Caption = 'Simulation'
      TabOrder = 2
      object btnServerStartMap: TButton
        Left = 3
        Top = 20
        Width = 90
        Height = 25
        Caption = 'Start Map'
        Enabled = False
        TabOrder = 0
        OnClick = btnServerStartMapClick
      end
      object btnSendEvent: TButton
        Left = 95
        Top = 20
        Width = 90
        Height = 25
        Caption = 'Send Event'
        Enabled = False
        TabOrder = 1
        OnClick = btnServerSendEventClick
      end
      object btnSendState: TButton
        Left = 187
        Top = 20
        Width = 90
        Height = 25
        Caption = 'Send State'
        Enabled = False
        TabOrder = 2
        OnClick = btnServerSendEventClick
      end
    end
    object mTutorial: TMemo
      Left = 288
      Top = 18
      Width = 345
      Height = 73
      Enabled = False
      Lines.Strings = (
        '1. Select paths to DLL(s)'
        '2. Start the server'
        '3. Create new AI'
        '4. Select the AI in lobby list'
        '5. Start the map')
      ReadOnly = True
      TabOrder = 3
    end
    object gbDLLs: TGroupBox
      Left = 3
      Top = 16
      Width = 280
      Height = 186
      Caption = 'DLLs'
      TabOrder = 4
      object lbDLLs: TListBox
        Left = 10
        Top = 120
        Width = 257
        Height = 57
        ItemHeight = 13
        TabOrder = 0
      end
      object lbPaths: TListBox
        Left = 12
        Top = 39
        Width = 210
        Height = 56
        ItemHeight = 13
        Items.Strings = (
          'ExtAI\'
          '..\ExtAI\')
        TabOrder = 1
      end
      object stPathsDLL: TStaticText
        Left = 10
        Top = 20
        Width = 179
        Height = 17
        Caption = 'Search paths (relative and absolute)'
        TabOrder = 2
      end
      object btnAddPath: TButton
        Left = 220
        Top = 40
        Width = 46
        Height = 25
        Caption = 'Add'
        TabOrder = 3
        OnClick = btnAddPathClick
      end
      object btnRemove: TButton
        Left = 220
        Top = 71
        Width = 46
        Height = 25
        Caption = 'Remove'
        TabOrder = 4
        OnClick = btnRemoveClick
      end
      object stDLLs: TStaticText
        Left = 12
        Top = 101
        Width = 98
        Height = 17
        Caption = 'Detected valid DLLs'
        Color = clBackground
        ParentColor = False
        TabOrder = 5
      end
    end
    object reLog: TRichEdit
      Left = 289
      Top = 97
      Width = 344
      Height = 562
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideScrollBars = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 5
      Zoom = 100
    end
  end
  object gbExtAIsExe: TGroupBox
    Left = 647
    Top = 8
    Width = 322
    Height = 365
    Caption = 'ExtAIs (executable emulation)'
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
    object pcLogExtAIExe: TPageControl
      Left = 3
      Top = 126
      Width = 316
      Height = 236
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
  object gbExtAIsDLL: TGroupBox
    Left = 650
    Top = 376
    Width = 321
    Height = 292
    Caption = 'ExtAIs (DLL)'
    TabOrder = 2
    object pcLogExtAIDLL: TPageControl
      Left = 3
      Top = 16
      Width = 315
      Height = 273
      TabOrder = 0
    end
  end
end
