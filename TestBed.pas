unit TestBed;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  KM_Game, ExtAIDelphi, ExtAILog, KM_Consts, ExtAIInfo,
  // Detection of IP address
  Winsock, Vcl.ComCtrls;

type
  TExtAIAndGUI = record
    ID: Word;
    AI: TExtAIDelphi;
    Log: TLog;
    //@Martin: Why do we need separate logs for ExtAIs created by the host app/Game?
    //@Krom: The logs are not created by Game but by GUI of the ExtAI. They are used
    //       for logging connection and problems with client. For communication with
    //       the game you can use Actions.Log()
    tsTab: TTabSheet;
    mLog: TMemo;
  end;

  //@Martin: wouldn't it be simpler to use TList<TExtAIAndGUI> which already has the Count/Capacity and auto-growth?
  //@Krom: the Number must be fixed in case that ExtAI lost connection and connects back it can be TList of record if you wish
  //@Martin: Please comment on the purpose of these fields and see if you can give them more meaningful names. Atm I'm puzzled as to what they mean and do
  TExtAIAndGUIArr = record
    Count: Word; // Count of elements in Arr
    ID: Word; // ID of ExtAI (imagine if we start game with 3 AIs and we lose connection with AI 2)
    Arr: array of TExtAIAndGUI;
  end;

  TExtAI_TestBed = class(TForm)
    btnAutoFill: TButton;
    btnClientConnect: TButton;
    btnClientSendAction: TButton;
    btnClientSendState: TButton;
    btnCreateExtAI: TButton;
    btnSendEvent: TButton;
    btnSendState: TButton;
    btnServerStartMap: TButton;
    btnStartServer: TButton;
    btnTerminateAI: TButton;
    btnTerminateExtAIs: TButton;
    cbLoc00: TComboBox;
    cbLoc01: TComboBox;
    cbLoc02: TComboBox;
    cbLoc03: TComboBox;
    cbLoc04: TComboBox;
    cbLoc05: TComboBox;
    cbLoc06: TComboBox;
    cbLoc08: TComboBox;
    cbLoc09: TComboBox;
    cbLoc07: TComboBox;
    cbLoc10: TComboBox;
    cbLoc11: TComboBox;
    edPingLoc00: TEdit;
    edPingLoc01: TEdit;
    edPingLoc02: TEdit;
    edPingLoc03: TEdit;
    edPingLoc04: TEdit;
    edPingLoc05: TEdit;
    edPingLoc06: TEdit;
    edPingLoc07: TEdit;
    edPingLoc08: TEdit;
    edPingLoc09: TEdit;
    edPingLoc10: TEdit;
    edPingLoc11: TEdit;
    edServerPort: TEdit;
    gbAIControlInterface: TGroupBox;
    gbExtAIs: TGroupBox;
    gbKP: TGroupBox;
    gbLobby: TGroupBox;
    gbServer: TGroupBox;
    gbSimulation: TGroupBox;
    chbControlAll: TCheckBox;
    labLoc00: TLabel;
    labLoc01: TLabel;
    labLoc02: TLabel;
    labLoc03: TLabel;
    labLoc04: TLabel;
    labLoc05: TLabel;
    labLoc06: TLabel;
    labLoc07: TLabel;
    labLoc08: TLabel;
    labLoc09: TLabel;
    labLoc10: TLabel;
    labLoc11: TLabel;
    labPortNumber: TLabel;
    mServerLog: TMemo;
    pcLogExtAI: TPageControl;
    prgServer: TProgressBar;
    mTutorial: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnClientConnectClick(Sender: TObject);
    procedure btnClientSendActionClick(Sender: TObject);
    procedure btnServerSendEventClick(Sender: TObject);
    procedure btnClientSendStateClick(Sender: TObject);
    procedure btnServerStartMapClick(Sender: TObject);
    procedure btnCreateExtAIClick(Sender: TObject);
    procedure btnTerminateExtAIClick(Sender: TObject);
    procedure btnTerminateExtAIsClick(Sender: TObject);
    procedure pcOnChangeTab(Sender: TObject);
    procedure chbControlAllClick(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
    procedure mTutorialChange(Sender: TObject);
  private
    fGame: TKMGame;
    fExtAIAndGUIArr: TExtAIAndGUIArr;
    fcbLoc: array[0..MAX_HANDS_COUNT-1] of TComboBox;
    fedPingLoc: array[0..MAX_HANDS_COUNT-1] of TEdit;
    procedure RefreshExtAIs(aAIInfo: TExtAIInfo);
    procedure ConnectClient(aIdx: Word);
    procedure DisconnectClient(aIdx: Integer);
    procedure RefreshAIGUI(Sender: TObject);
    function GetIdxByID(var aIdx: Integer; aID: Byte): boolean;
    function GetSelectedClient(var aIdx: Integer): boolean;
    procedure UpdateSimStatus();
  public
    procedure Log(const aText: String);
    procedure LogID(const aText: String; const aID: Byte);

    property AI: TExtAIAndGUIArr read fExtAIAndGUIArr write fExtAIAndGUIArr;
  end;

const
  TAB_NAME = 'tsExtAI';
  CLOSED_LOC = 'Closed';
var
  ExtAI_TestBed: TExtAI_TestBed;
  csCriticalSection: TRTLCriticalSection;

implementation
uses
  ExtAINetworkTypes;

{$R *.dfm}

procedure TExtAI_TestBed.FormCreate(Sender: TObject);
begin
  gLog := TLog.Create(Log);
  gLog.Log('Initialization');
  fGame := TKMGame.Create(UpdateSimStatus);
  fGame.ExtAIMaster.OnAIConfigured := RefreshExtAIs;
  fGame.ExtAIMaster.OnAIDisconnect := RefreshExtAIs;

  fExtAIAndGUIArr.Count := 0;
  fExtAIAndGUIArr.ID := 0;
  InitializeCriticalSection(csCriticalSection);

  fedPingLoc[0]  := edPingLoc00;  fcbLoc[0]  := cbLoc00;
  fedPingLoc[1]  := edPingLoc01;  fcbLoc[1]  := cbLoc01;
  fedPingLoc[2]  := edPingLoc02;  fcbLoc[2]  := cbLoc02;
  fedPingLoc[3]  := edPingLoc03;  fcbLoc[3]  := cbLoc03;
  fedPingLoc[4]  := edPingLoc04;  fcbLoc[4]  := cbLoc04;
  fedPingLoc[5]  := edPingLoc05;  fcbLoc[5]  := cbLoc05;
  fedPingLoc[6]  := edPingLoc06;  fcbLoc[6]  := cbLoc06;
  fedPingLoc[7]  := edPingLoc07;  fcbLoc[7]  := cbLoc07;
  fedPingLoc[8]  := edPingLoc08;  fcbLoc[8]  := cbLoc08;
  fedPingLoc[9]  := edPingLoc09;  fcbLoc[9]  := cbLoc09;
  fedPingLoc[10] := edPingLoc10;  fcbLoc[10] := cbLoc10;
  fedPingLoc[11] := edPingLoc11;  fcbLoc[11] := cbLoc11;
  RefreshExtAIs(nil);
end;


procedure TExtAI_TestBed.FormDestroy(Sender: TObject);
begin
  fGame.TerminateSimulation();
  btnTerminateExtAIsClick(nil);
  Sleep(100);
  fGame.Free;
  gLog.Free;
end;


procedure TExtAI_TestBed.btnStartServerClick(Sender: TObject);
begin
  if fGame.ExtAIMaster.Net.Listening then
  begin
    if fGame.GameState <> gsLobby then
      btnServerStartMapClick(Sender);

    fGame.ExtAIMaster.Net.StopListening();
    prgServer.Style := pbstNormal;
    btnStartServer.Caption := 'Start Server';
    btnServerStartMap.Enabled := False;
    btnSendEvent.Enabled := False;
    btnSendState.Enabled := False;
  end
  else
  begin
    try
      fGame.ExtAIMaster.Net.StartListening(StrToInt(edServerPort.Text), 'Testing server');
    except
      Log('Invalid port');
      Exit;
    end;

    if fGame.ExtAIMaster.Net.Listening then
    begin
      prgServer.Style := pbstMarquee;
      btnStartServer.Caption := 'Stop Server';
      btnServerStartMap.Enabled := True;
      //btnSendEvent.Enabled := True;
      //btnSendState.Enabled := True;
    end;
  end;
end;


procedure TExtAI_TestBed.RefreshExtAIs(aAIInfo: TExtAIInfo);
var
  ItemFound: Boolean;
  K,L,Cnt: Integer;
  NewNames: array of String;
  SelectedNames: array[0..MAX_HANDS_COUNT-1] of String;
begin
  // Get available AI players
  Cnt := 0;
  SetLength(NewNames, fGame.ExtAIMaster.AIs.Count);
  for K := 0 to fGame.ExtAIMaster.AIs.Count-1 do
    if fGame.ExtAIMaster.AIs[K].Configured then
    begin
      NewNames[Cnt] := fGame.ExtAIMaster.AIs[K].Name + ' ' + IntToStr(fGame.ExtAIMaster.AIs[K].ServerClient.Handle);
      Cnt := Cnt + 1;
    end;

  // Filter already selected AI players
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    // Get actual selection
    L := fcbLoc[K].ItemIndex;
    SelectedNames[K] := fcbLoc[K].Items[L];
    // Try to find selection in list of new names
    ItemFound := False;
    if (Length(SelectedNames[K]) > 0) then
      for L := 0 to Cnt - 1 do
        if (NewNames[L] = SelectedNames[K]) then
        begin
          // Confirm selection and remove AI from list of possible names
          ItemFound := True;
          Cnt := Cnt - 1;
          NewNames[L] := NewNames[Cnt];
          Break;
        end;
    // Remove selection
    if not ItemFound then
      SelectedNames[K] := '';
  end;

  // Refresh combo boxes
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    fcbLoc[K].Items.Clear;
    fcbLoc[K].Items.Add(CLOSED_LOC);
    // Closed by default, first index if there is existing already selected AI
    if (Length(SelectedNames[K]) > 0) then
      fcbLoc[K].Items.Add(SelectedNames[K]);
    fcbLoc[K].ItemIndex := fcbLoc[K].Items.Count - 1;
    for L := 0 to Cnt - 1 do
      fcbLoc[K].Items.Add(NewNames[L]);
  end;
end;


procedure TExtAI_TestBed.pcOnChangeTab(Sender: TObject);
begin
  RefreshAIGUI(nil);
end;


procedure TExtAI_TestBed.btnServerStartMapClick(Sender: TObject);
var
  K, Cnt: Integer;
  AIs: array of String;
begin
  // Get available AI players
  Cnt := 0;
  SetLength(AIs,MAX_HANDS_COUNT);
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    // Get actual selection
    AIs[Cnt] := fcbLoc[K].Items[ fcbLoc[K].ItemIndex ];
    if (Length(AIs[Cnt]) > 0) AND (AIs[Cnt] <> CLOSED_LOC) then
    begin
      AIs[Cnt] := AIs[Cnt].SubString(0, Pos(' ',AIs[Cnt]) - 1);
      Cnt := Cnt + 1;
    end;
  end;
  SetLength(AIs,Cnt);
  fGame.StartEndGame(AIs);
  if (fGame.GameState = gsLobby) then
    btnServerStartMap.Caption := 'Start Map'
  else
    btnServerStartMap.Caption := 'Stop Map';
end;


procedure TExtAI_TestBed.btnServerSendEventClick(Sender: TObject);
begin
  fGame.SendEvent;
end;


procedure TExtAI_TestBed.btnAutoFillClick(Sender: TObject);
var
  K: Integer;
begin
  for K := Low(fcbLoc) to High(fcbLoc) do
    if fcbLoc[K].ItemIndex = 0 then // Loc is closed
    begin
      if fcbLoc[K].Items.Count > 1 then
        fcbLoc[K].ItemIndex := 1
      else
        Break;

      //@Martin: Do we need this once per loop or once after the loop will be enough?
      //@Krom: RefreshExtAIs creates also list of available AIs (they are not selected in lobby list)
      //       so I can always pick up the first index from available AIs and then refresh the list
      //       it is not so effecient but we have just 12 locs
      //@Martin: Please look into restructuring this:
      // Game should init the ExtAIMaster.
      // ExtAIMaster should scan for available ExtAIs and provide a list to select from.
      // TestBed should set up a lobby by reading from that list.

      // Refresh AIs
      RefreshExtAIs(nil);
    end;
end;


procedure TExtAI_TestBed.btnClientConnectClick(Sender: TObject);
var
  Conn: Boolean;
  K, Idx: Integer;
begin
  // Send commant to all ExtAIs
  if chbControlAll.Checked then
  begin
    Conn := True;
    for K := 0 to fExtAIAndGUIArr.Count - 1 do
      with fExtAIAndGUIArr.Arr[K].AI do
        Conn := Conn AND Client.Connected;
    for Idx := 0 to pcLogExtAI.PageCount - 1 do
      if Conn then
        DisconnectClient(Idx)
      else
        ConnectClient(Idx);
  end
  // Send command only to selected AI
  else if GetSelectedClient(Idx) then
  begin
    if fExtAIAndGUIArr.Arr[Idx].AI.Client.Connected then
      DisconnectClient(Idx)
    else
      ConnectClient(Idx);
  end;
end;


procedure TExtAI_TestBed.btnCreateExtAIClick(Sender: TObject);
var
  Cnt: Integer;
begin
  // Set Length
  Cnt := fExtAIAndGUIArr.Count;
  if (Length(fExtAIAndGUIArr.Arr) <= Cnt) then
    SetLength(fExtAIAndGUIArr.Arr, Cnt + 12);

  // Increase cnt
  Inc(fExtAIAndGUIArr.Count);
  with fExtAIAndGUIArr.Arr[Cnt] do
  begin
    ID := fExtAIAndGUIArr.ID;
    // Increase number
    Inc(fExtAIAndGUIArr.ID);
    // Create GUI
    tsTab := TTabSheet.Create(pcLogExtAI);
    tsTab.Caption := 'Log AI ' + IntToStr(ID);
    //tsTab.Caption := AI.Client.ClientName + ' ' + IntToStr(ID);
    tsTab.Name := TAB_NAME + IntToStr(ID);
    tsTab.PageControl := pcLogExtAI;
    mLog := TMemo.Create(tsTab);
    mLog.Parent := tsTab;
    mLog.Align := alClient;
    // Create new ExtAI
    Log := TLog.Create(LogID, ID);
    AI := TExtAIDelphi.Create(Log, ID);
    AI.Client.OnConnectSucceed := RefreshAIGUI;
    AI.Client.OnForcedDisconnect := RefreshAIGUI;
  end;

  // Try to connect to server
  ConnectClient(Cnt);
end;


procedure TExtAI_TestBed.btnTerminateExtAIClick(Sender: TObject);
var
  ID: Integer;
begin
  if GetSelectedClient(ID) then
    with fExtAIAndGUIArr do
    begin
      Arr[ID].AI.TerminateSimulation();
      Sleep(100); // Give some time to shut down the clients
      Arr[ID].AI.Free;
      Arr[ID].Log.Free;
      Arr[ID].tsTab.Free; // Free tab and all GUI stuff in it
      Arr[ID] := Arr[Count-1];
      Count := Count - 1;
    end;
end;


//@Martin: What is the purpose of this method? I'd think it should be inside the Game.GameEnd or alike
procedure TExtAI_TestBed.btnTerminateExtAIsClick(Sender: TObject);
var
  K: Integer;
begin
  with fExtAIAndGUIArr do
  begin
    for K := Count - 1 downto 0 do
      Arr[K].AI.TerminateSimulation();
    Sleep(100); // Give some time to shut down the clients
    for K := Count - 1 downto 0 do
    begin
      Arr[K].AI.Free;
      Arr[K].Log.Free;
      Arr[K].tsTab.Free; // Free tab and all GUI stuff in it
    end;
    Count := 0;
    ID := 0;
  end;
end;


procedure TExtAI_TestBed.chbControlAllClick(Sender: TObject);
begin
  RefreshAIGUI(Sender);
end;


procedure TExtAI_TestBed.btnClientSendActionClick(Sender: TObject);
var
  K,ID: Integer;
begin
  if chbControlAll.Checked then
  begin
    for K := 0 to fExtAIAndGUIArr.Count - 1 do
      with fExtAIAndGUIArr.Arr[K].AI do
        Actions.Log('This is debug message (Action.Log) from ExtAI ID = ' + IntToStr(ID));
  end
  else if GetSelectedClient(ID) then
    with fExtAIAndGUIArr.Arr[ID].AI do
    begin
      Actions.Log('This is debug message (Action.Log) from ExtAI ID = ' + IntToStr(ID));
      //Actions.GroupOrderWalk(1,2,3,4);
    end;
end;


procedure TExtAI_TestBed.btnClientSendStateClick(Sender: TObject);
begin
  //fExtAIDelphi.State.Log('This is debug message (States) from ExtAI in Delphi');
  Log('States are not implemented');
end;


function TExtAI_TestBed.GetIdxByID(var aIdx: Integer; aID: Byte): boolean;
var
  K: Integer;
begin
  Result := False;
  for K := 0 to fExtAIAndGUIArr.Count - 1 do
    if (fExtAIAndGUIArr.Arr[K].ID = aID) then
    begin
      aIdx := K;
      Exit(True);
    end;
end;


function TExtAI_TestBed.GetSelectedClient(var aIdx: Integer): boolean;
var
  tsTab: TTabSheet;
  TabID: String;
  ID: Byte;
begin
  Result := False;
  if (pcLogExtAI.PageCount > 0) then
  begin
    tsTab := pcLogExtAI.ActivePage;
    TabID := tsTab.Name;
    TabID :=  Copy(TabID, 1 + Length(TAB_NAME), Length(TabID) - Length(TAB_NAME));
    try
      ID := StrToInt(TabID);
      if GetIdxByID(aIdx, ID) then
        Exit(True);
    except
      Log('Cannot extract ID from name of the tab');
    end;
  end;
end;


procedure TExtAI_TestBed.ConnectClient(aIdx: Word);
  // Simple function for detection of actual IP address
  function GetIP(var aIPAddress: String): Boolean;
  type
    pu_long = ^u_long;
  var
    TWSA: TWSAData;
    phe: PHostEnt;
    Addr: TInAddr;
    Buffer: array[0..255] of AnsiChar;
  begin
    Result := False;
    aIPAddress := '';
    if (WSAStartup($101,TWSA) = 0) AND (GetHostName(Buffer, SizeOf(Buffer)) = 0) then
    begin
      phe := GetHostByName(Buffer);
      if (phe = nil) then
        Exit;
      Addr.S_addr := u_long(pu_long(phe^.h_addr_list^)^);
      aIPAddress := String(inet_ntoa(Addr));
      Result := True;
    end;
    WSACleanUp;
  end;
var
  Port: Integer;
  IP: String;
begin
  try
    Port := StrToInt(edServerPort.Text);
  except
    Log('Invalid port');
    Exit;
  end;
  if GetIP(IP) then
      fExtAIAndGUIArr.Arr[aIdx].AI.Client.ConnectTo(IP, Port);
end;


procedure TExtAI_TestBed.DisconnectClient(aIdx: Integer);
begin
  with fExtAIAndGUIArr.Arr[aIdx].AI.Client do
  if Connected then
    Disconnect;
  btnClientConnect.Caption := 'Connect client';
  btnClientSendAction.Enabled := False;
  btnClientSendState.Enabled := False;
end;


procedure TExtAI_TestBed.RefreshAIGUI(Sender: TObject);
var
  Conn: Boolean;
  K, ID: Integer;
begin
  EnterCriticalSection(csCriticalSection);
  try
    if GetSelectedClient(ID) then
    begin
      // Check selected client
      Conn := fExtAIAndGUIArr.Arr[ID].AI.Client.Connected;
      // Check if all clients are connected
      if Conn AND chbControlAll.Checked then
        for K := 0 to fExtAIAndGUIArr.Count - 1 do
          with fExtAIAndGUIArr.Arr[K].AI do
            Conn := Conn AND Client.Connected;
      // Update buttons
      if Conn then
      begin
        btnClientConnect.Caption := 'Disconnect client';
        btnClientSendAction.Enabled := True;
        //btnClientSendState.Enabled := True;
      end
      else
      begin
        btnClientConnect.Caption := 'Connect client';
        btnClientSendAction.Enabled := False;
        btnClientSendState.Enabled := False;
      end;
    end;
  finally
     LeaveCriticalSection(csCriticalSection);
  end;
end;


procedure TExtAI_TestBed.UpdateSimStatus();
var
  K,L: Integer;
  AIName: string;
begin
  for K := 0 to fGame.ExtAIMaster.AIs.Count-1 do
  begin
    AIName := fGame.ExtAIMaster.AIs[K].Name + ' ' + IntToStr(fGame.ExtAIMaster.AIs[K].ServerClient.Handle);
    for L := Low(fcbLoc) to High(fcbLoc) do
      if AIName = fcbLoc[L].Items[fcbLoc[L].ItemIndex] then
      begin
        fedPingLoc[L].Text := IntToStr(fGame.ExtAIMaster.AIs[K].ServerClient.NetPing);
        Break;
      end;
  end;
end;


procedure TExtAI_TestBed.Log(const aText: String);
begin
  mServerLog.Lines.Append(aText);
end;


procedure TExtAI_TestBed.LogID(const aText: String; const aID: Byte);
var
  Idx: Integer;
begin
  if GetIdxByID(Idx, aID) then
    fExtAIAndGUIArr.Arr[Idx].mLog.Lines.Append(aText);
end;


procedure TExtAI_TestBed.mTutorialChange(Sender: TObject);
begin
  //@Martin: The app needs to be restructured a bit:
  // 1. Start the server
  // 2. Configure the AI types in the lobby list
  // 3. Create AIs
  // 4. Start the gameplay (map)
  //@Krom: we already discussed it - the game does not know about ExtAI unless it connects to the game
  //       so points 2 and 3 cannot be swapped
  //@Martin: Okay, so we add step 1b inbetween 1 and 2, where ExtAI scans and makes up a list of available ExtAIs
end;


end.
