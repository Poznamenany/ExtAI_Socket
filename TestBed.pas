unit TestBed;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  FileCtrl, StrUtils,
  KM_Game, KM_CommonTypes, ExtAIDelphi, ExtAILog, KM_Consts, ExtAIInfo,
  // Detection of IP address
  Winsock, Vcl.ComCtrls;

// @Krom: This is my test bed, please ignore this project (WebSocketTest). The main project is called Game.
type
  TExtAIAndGUI = record
    ID: Word;
    AI: TExtAIDelphi;
    Log: TLog;
    tsTab: TTabSheet;
    mLog: TMemo;
  end;

  TExtAIAndGUIArr = record
    Count: Word; // Count of elements in Arr
    ID: Word; // ID of ExtAI (imagine if we start game with 3 AIs and we lose connection with AI 2)
    Arr: array of TExtAIAndGUI;
  end;

  TExtAI_TestBed = class(TForm)
    btnAddPath: TButton;
    btnAutoFill: TButton;
    btnClientConnect: TButton;
    btnClientSendAction: TButton;
    btnClientSendState: TButton;
    btnCreateExtAI: TButton;
    btnRemove: TButton;
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
    cbLoc07: TComboBox;
    cbLoc08: TComboBox;
    cbLoc09: TComboBox;
    cbLoc10: TComboBox;
    cbLoc11: TComboBox;
    chbControlAll: TCheckBox;
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
    gbDLLs: TGroupBox;
    gbExtAIsDLL: TGroupBox;
    gbExtAIsExe: TGroupBox;
    gbKP: TGroupBox;
    gbLobby: TGroupBox;
    gbServer: TGroupBox;
    gbSimulation: TGroupBox;
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
    lbDLLs: TListBox;
    lbPaths: TListBox;
    mTutorial: TMemo;
    pcLogExtAIDLL: TPageControl;
    pcLogExtAIExe: TPageControl;
    prgServer: TProgressBar;
    reLog: TRichEdit;
    stDLLs: TStaticText;
    stExtAIName: TStaticText;
    stPathsDLL: TStaticText;
    stPing: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddPathClick(Sender: TObject);
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
    procedure cbOnChange(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    fGame: TKMGame;
    fExtAIAndGUIArr: TExtAIAndGUIArr;
    fcbLoc: array[0..MAX_HANDS_COUNT-1] of TComboBox;
    fedPingLoc: array[0..MAX_HANDS_COUNT-1] of TEdit;
    procedure RefreshDLLs();
    procedure RefreshComboBoxes(aServerClient: TExtAIInfo = nil);
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
  USE_LOCALHOST_IP = True;
var
  ExtAI_TestBed: TExtAI_TestBed;
  csCriticalSection: TRTLCriticalSection;

implementation
uses
  ExtAINetworkTypes;

{$R *.dfm}

procedure TExtAI_TestBed.FormCreate(Sender: TObject);
begin
  // Game log (log every input from Socket)
  gLog := TLog.Create(Log);
  gLog.Log('TExtAI_TestBed-Create');
  // Game class
  fGame := TKMGame.Create(UpdateSimStatus);
  // Game events for GUI
  fGame.ExtAIMaster.OnAIConfigured := RefreshComboBoxes;
  fGame.ExtAIMaster.OnAIDisconnect := RefreshComboBoxes;
  // Define ComboBoxes
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
  // Init GUI
  RefreshDLLs(); // Includes refresh combo boxes
end;


procedure TExtAI_TestBed.FormDestroy(Sender: TObject);
begin
  gLog.Log('TExtAI_TestBed-Destroy');
  fGame.TerminateSimulation();
  btnTerminateExtAIsClick(nil);
  Sleep(100);
  fGame.Free;
  gLog.Free;
end;




//------------------------------------------------------------------------------
// DLLs
//------------------------------------------------------------------------------


procedure TExtAI_TestBed.btnAddPathClick(Sender: TObject);
var
  K: Integer;
  Path: String;
begin
  Path := ParamStr(0);
  if not FileCtrl.SelectDirectory(Path, [sdAllowCreate, sdPerformCreate, sdPrompt],1000) then
    Exit
  else
    for K := 0 to lbPaths.Items.Count - 1 do
      if (AnsiCompareText(lbPaths.Items[K],Path) = 0) then
        Exit;
  lbPaths.Items.Add(Path);
  RefreshDLLs();
end;


procedure TExtAI_TestBed.btnRemoveClick(Sender: TObject);
begin
  if (lbPaths.ItemIndex >= 0) then
    lbPaths.Items.Delete(lbPaths.ItemIndex);
  RefreshDLLs();
end;


procedure TExtAI_TestBed.RefreshDLLs();
var
  K: Integer;
  Paths: TArray<string>;
begin
  if (fGame = nil) then
    Exit;
  // Get paths
  SetLength(Paths,lbPaths.Items.Count);
  for K := 0 to lbPaths.Items.Count - 1 do
    Paths[K] := lbPaths.Items[K];
  // Refresh DLLs
  fGame.ExtAIMaster.DLLs.RefreshList(Paths);
  // Update GUI
  RefreshComboBoxes();
  lbDLLs.Clear;
  for K := 0 to fGame.ExtAIMaster.DLLs.Count - 1 do
    lbDLLs.Items.Add(fGame.ExtAIMaster.DLLs[K].Name);
end;





//------------------------------------------------------------------------------
// Server
//------------------------------------------------------------------------------


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
      btnSendEvent.Enabled := True;
      //btnSendState.Enabled := True;
    end;
  end;
end;


// Generic callback for combo boxes
procedure TExtAI_TestBed.cbOnChange(Sender: TObject);
begin
  RefreshComboBoxes();
end;



// Refresh list of available ExtAIs in the combo boxes so player can select just 1 instance of the AI for 1 slot
procedure TExtAI_TestBed.RefreshComboBoxes(aServerClient: TExtAIInfo);
var
  ItemFound: Boolean;
  K,L,Cnt: Integer;
  AvailableAIs, AvailableDLLs: TStringArray;
  SelectedAIs: array[0..MAX_HANDS_COUNT-1] of String;
begin
  // Get available ExtAIs and DLLs
  AvailableAIs := fGame.ExtAIMaster.GetExtAIClientNames();
  AvailableDLLs := fGame.ExtAIMaster.GetExtAIDLLNames();

  // Filter already selected AI players
  Cnt := Length(AvailableAIs);
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    // Get actual selection (String, name of the ExtAI)
    SelectedAIs[K] := fcbLoc[K].Items[ fcbLoc[K].ItemIndex ];
    // Try to find selection in list of new names
    ItemFound := False;
    for L := 0 to Cnt - 1 do
      if (AnsiCompareText(AvailableAIs[L],SelectedAIs[K]) = 0) then
      begin
        // Confirm selection and remove AI from list of possible names
        ItemFound := True;
        Cnt := Cnt - 1;
        AvailableAIs[L] := AvailableAIs[Cnt];
        Break;
      end;
    for L := Low(AvailableDLLs) to High(AvailableDLLs) do
      if (AnsiCompareText(AvailableDLLs[L],SelectedAIs[K]) = 0) then
        ItemFound := True;
    // Remove selection
    if not ItemFound then
      SelectedAIs[K] := '';
  end;

  // Refresh combo boxes [Closed, ActualSelection, PossibleSelection1, PossibleSelection2, ...]
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    fcbLoc[K].Items.Clear;
    fcbLoc[K].Items.Add(CLOSED_LOC);
    // Closed by default, first index if there is existing already selected AI
    if (Length(SelectedAIs[K]) > 0) then
      fcbLoc[K].Items.Add(SelectedAIs[K]);
    fcbLoc[K].ItemIndex := fcbLoc[K].Items.Count - 1;
    for L := 0 to Cnt - 1 do
      fcbLoc[K].Items.Add(AvailableAIs[L]);
    for L := Low(AvailableDLLs) to High(AvailableDLLs) do
      if (AnsiCompareText(AvailableDLLs[L],SelectedAIs[K]) <> 0) then
        fcbLoc[K].Items.Add(AvailableDLLs[L]);
  end;
end;


procedure TExtAI_TestBed.pcOnChangeTab(Sender: TObject);
begin
  RefreshAIGUI(nil);
end;


procedure TExtAI_TestBed.btnAutoFillClick(Sender: TObject);
var
  K: Integer;
begin
  for K := Low(fcbLoc) to High(fcbLoc) do
    if (fcbLoc[K].ItemIndex = 0) AND (fcbLoc[K].Items.Count > 1) then // Loc is closed and we have available ExtAI
    begin
      fcbLoc[K].ItemIndex := 1;
      RefreshComboBoxes(); // Refresh GUI
    end;
end;




//------------------------------------------------------------------------------
// Simulation
//------------------------------------------------------------------------------


procedure TExtAI_TestBed.btnServerStartMapClick(Sender: TObject);
var
  K, Cnt: Integer;
  AIs: TStringArray;
begin
  btnServerStartMap.Enabled := True;
  if (fGame.GameState = gsLobby) then
  begin
    // Get AI players in the lobby
    SetLength(AIs,MAX_HANDS_COUNT);
    Cnt := 0;
    for K := Low(fcbLoc) to High(fcbLoc) do
    begin
      // Get actual selection
      AIs[Cnt] := fcbLoc[K].Items[ fcbLoc[K].ItemIndex ];
      Cnt := Cnt + Byte((Length(AIs[Cnt]) > 0) AND (AnsiCompareText(AIs[Cnt],CLOSED_LOC) <> 0));
    end;
    SetLength(AIs,Cnt);
    // Start / stop the simulation with specific AI players
    fGame.InitGame(AIs);
    //btnServerStartMap.Caption := 'Loading...';
    //btnServerStartMap.Enabled := False;
    btnServerStartMap.Caption := 'Stop Map';
    btnServerStartMap.Enabled := True;
  end
  else if (fGame.GameState = gsPlaying) then
  begin
    btnServerStartMap.Caption := 'Stop Map';
    fGame.EndGame();
  end
  else
  begin
    btnServerStartMap.Caption := 'Start Map';
  end
end;


procedure TExtAI_TestBed.btnServerSendEventClick(Sender: TObject);
begin
  fGame.SendEvent;
end;


procedure TExtAI_TestBed.UpdateSimStatus();
var
  K,L: Integer;
  AvailableAIs: TStringArray;
begin
  // Get available AI players
  AvailableAIs := fGame.ExtAIMaster.GetExtAIClientNames();
  // Update ping
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    fedPingLoc[K].Text := '0';
    for L := Low(AvailableAIs) to High(AvailableAIs) do
      if (AnsiCompareText(AvailableAIs[L], fcbLoc[K].Items[ fcbLoc[K].ItemIndex ]) = 0) then
        fedPingLoc[K].Text := IntToStr(fGame.ExtAIMaster.AIs[L].ServerClient.NetPing);
  end;
end;




//------------------------------------------------------------------------------
// ExtAI
//------------------------------------------------------------------------------


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
    tsTab := TTabSheet.Create(pcLogExtAIExe);
    tsTab.Caption := 'Log AI ' + IntToStr(ID);
    //tsTab.Caption := AI.Client.ClientName + ' ' + IntToStr(ID);
    tsTab.Name := TAB_NAME + IntToStr(ID);
    tsTab.PageControl := pcLogExtAIExe;
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
  Idx: Integer;
begin
  if GetSelectedClient(Idx) then
    with fExtAIAndGUIArr do
    begin
      Arr[Idx].AI.TerminateSimulation();
      Sleep(100); // Give some time to shut down the clients
      Arr[Idx].AI.Free;
      Arr[Idx].Log.Free;
      Arr[Idx].tsTab.Free; // Free tab and all GUI stuff in it
      Arr[Idx] := Arr[Count-1];
      Count := Count - 1;
    end;
end;


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
    //ID := 0;
  end;
end;


procedure TExtAI_TestBed.btnClientConnectClick(Sender: TObject);
var
  Conn: Boolean;
  K, Idx: Integer;
begin
  // Send command to all ExtAIs
  if chbControlAll.Checked then
  begin
    Conn := True;
    for K := 0 to fExtAIAndGUIArr.Count - 1 do
      with fExtAIAndGUIArr.Arr[K].AI do
        Conn := Conn AND Client.Connected;
    for Idx := 0 to pcLogExtAIExe.PageCount - 1 do
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


procedure TExtAI_TestBed.chbControlAllClick(Sender: TObject);
begin
  RefreshAIGUI(Sender);
end;


procedure TExtAI_TestBed.btnClientSendActionClick(Sender: TObject);
var
  K,Idx: Integer;
begin
  if chbControlAll.Checked then
  begin
    for K := 0 to fExtAIAndGUIArr.Count - 1 do
      with fExtAIAndGUIArr.Arr[K].AI do
        Actions.Log('This is debug message (Action.Log) from ExtAI ID = ' + IntToStr(ID));
  end
  else if GetSelectedClient(Idx) then
    with fExtAIAndGUIArr.Arr[Idx].AI do
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
  if (pcLogExtAIExe.PageCount > 0) then
  begin
    tsTab := pcLogExtAIExe.ActivePage;
    TabID := tsTab.Name;
    TabID := Copy(TabID, 1 + Length(TAB_NAME), Length(TabID) - Length(TAB_NAME));
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
  if USE_LOCALHOST_IP then
    fExtAIAndGUIArr.Arr[aIdx].AI.Client.ConnectTo('127.0.0.1', Port)
  else if GetIP(IP) then
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




//------------------------------------------------------------------------------
// Logs
//------------------------------------------------------------------------------


procedure TExtAI_TestBed.Log(const aText: String);
begin
  with reLog.SelAttributes do
  begin
    if      ContainsText(aText, 'Create'         ) then Color := clGreen
    else if ContainsText(aText, 'Destroy'        ) then Color := clRed
    else if ContainsText(aText, 'Server Status'  ) then Color := clPurple
    else if ContainsText(aText, 'ExtAIInfo'      ) then Color := clMedGray
    else if ContainsText(aText, 'TKMGame-Execute') then Color := clNavy;
  end;

  reLog.Lines.Add(aText);
  SendMessage(reLog.handle, WM_VSCROLL, SB_BOTTOM, 0);
end;


procedure TExtAI_TestBed.LogID(const aText: String; const aID: Byte);
var
  Idx: Integer;
begin
  if GetIdxByID(Idx, aID) then
    fExtAIAndGUIArr.Arr[Idx].mLog.Lines.Append(aText);
end;


end.
