unit KP_Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  FileCtrl, StrUtils,
  KM_Game, KM_CommonTypes, KM_Consts, ExtAILog, ExtAIInfo,
  // Detection of IP address
  Winsock;

type
  //@Krom: This is the main class with GUI for KP, it contains just all necessary functions and connections
  // GUI of the game (server, lobby, basic interface)
  TGame_form = class(TForm)
    btnAddPath: TButton;
    btnAutoFill: TButton;
    btnRemove: TButton;
    btnSendEvent: TButton;
    btnSendState: TButton;
    btnServerStartMap: TButton;
    btnStartServer: TButton;
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
    gbDLLs: TGroupBox;
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
    prgServer: TProgressBar;
    reLog: TRichEdit;
    stDLLs: TStaticText;
    stExtAIName: TStaticText;
    stPathsDLL: TStaticText;
    stPing: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnServerStartMapClick(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
    procedure cbOnChange(Sender: TObject);
    procedure btnSendEventClick(Sender: TObject);
    procedure btnAddPathClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    // Game class
    fGame: TKMGame;
    // Pure GUI of the game and some methods to maintain lobby list, etc.
    fcbLoc: array[0..MAX_HANDS_COUNT-1] of TComboBox;
    fedPingLoc: array[0..MAX_HANDS_COUNT-1] of TEdit;
    procedure RefreshDLLs();
    procedure EnableLobbyGUI(aEnable: Boolean);
    procedure EnableSimulationGUI(aEnable: Boolean);
    procedure RefreshComboBoxes(aServerClient: TExtAIInfo = nil);
    procedure UpdateSimStatus();
  public
    procedure Log(const aText: String);
  end;

const
  CLOSED_LOC = 'Closed';

var
  Game_form: TGame_form;

implementation

{$R *.dfm}

procedure TGame_form.FormCreate(Sender: TObject);
begin
  // Game log (log every input from Socket)
  gLog := TExtAILog.Create(Log);
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
  EnableLobbyGUI(False);
  EnableSimulationGUI(False);
end;


procedure TGame_form.FormDestroy(Sender: TObject);
begin
  gLog.Log('TExtAI_TestBed-Destroy');
  fGame.TerminateSimulation(); // Tell thread to properly finish the simulation
  fGame.WaitFor; // Wait for server to close (this method is called by main thread)
  fGame.Free;
  gLog.Free;
end;




//------------------------------------------------------------------------------
// DLLs
//------------------------------------------------------------------------------


// Add new path for scanning DLLs (in game just 1 path with ExtAI folder)
procedure TGame_form.btnAddPathClick(Sender: TObject);
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


// Remove selected path from DLL list
procedure TGame_form.btnRemoveClick(Sender: TObject);
begin
  if (lbPaths.ItemIndex >= 0) then
    lbPaths.Items.Delete(lbPaths.ItemIndex);
  RefreshDLLs();
end;


// Refresh DLL
procedure TGame_form.RefreshDLLs();
var
  K: Integer;
  Paths: TStringList;
begin
  if (fGame = nil) then
    Exit;
  // Get paths
  Paths := TStringList.Create();
  try
    for K := 0 to lbPaths.Items.Count - 1 do
      Paths.Add(lbPaths.Items[K]);
    // Refresh DLLs
    fGame.ExtAIMaster.DLLs.RefreshList(Paths);
  finally
    Paths.Free;
  end;
  // Update GUI
  RefreshComboBoxes();
  //lbPaths.Clear;
  //for K := 0 to fGame.ExtAIMaster.DLLs.Paths.Count - 1 do
  //  lbPaths.Items.Add(fGame.ExtAIMaster.DLLs.Paths[K]);
  lbDLLs.Clear;
  for K := 0 to fGame.ExtAIMaster.DLLs.Count - 1 do
    lbDLLs.Items.Add(fGame.ExtAIMaster.DLLs[K].Name);
end;




//------------------------------------------------------------------------------
// Server
//------------------------------------------------------------------------------


// Start / stop game server via button
procedure TGame_form.btnStartServerClick(Sender: TObject);
begin
  // Server is listening => stop listening
  if fGame.ExtAIMaster.Net.Listening then
  begin
    if fGame.GameState <> gsLobby then
      btnServerStartMapClick(Sender);

    fGame.ExtAIMaster.Net.StopListening();
    prgServer.Style := pbstNormal;
    EnableLobbyGUI(False);
    EnableSimulationGUI(False);
  end
  // Start server
  else
  begin
    try
      fGame.ExtAIMaster.Net.StartListening(StrToInt(edServerPort.Text), 'Testing server');
    except
      Log('Invalid port');
      Exit;
    end;
    // Check if server listen
    if fGame.ExtAIMaster.Net.Listening then
    begin
      prgServer.Style := pbstMarquee;
      EnableLobbyGUI(True);
      EnableSimulationGUI(True);
    end;
  end;
end;




//------------------------------------------------------------------------------
// Lobby
//------------------------------------------------------------------------------


// Enable lobby GUI
procedure TGame_form.EnableLobbyGUI(aEnable: Boolean);
var
  K: Integer;
begin
  btnAutoFill.Enabled := aEnable;
  for K := Low(fcbLoc) to High(fcbLoc) do
    fcbLoc[K].Enabled := aEnable;
end;


// Generic callback for combo boxes
procedure TGame_form.cbOnChange(Sender: TObject);
begin
  RefreshComboBoxes();
end;


// Refresh list of available ExtAIs in the combo boxes so player can select just 1 instance of the AI for 1 slot
procedure TGame_form.RefreshComboBoxes(aServerClient: TExtAIInfo);
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


// Auto fill available ExtAIs in the lobby
procedure TGame_form.btnAutoFillClick(Sender: TObject);
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


// Enable simulation GUI
procedure TGame_form.EnableSimulationGUI(aEnable: Boolean);
begin
  btnStartServer.Caption := 'Start Server';
  if aEnable then
    btnStartServer.Caption := 'Stop Server';
  btnServerStartMap.Enabled := aEnable;
  btnSendEvent.Enabled := aEnable;
  btnSendState.Enabled := aEnable;
end;


// Start the map (simulation of the game)
procedure TGame_form.btnServerStartMapClick(Sender: TObject);
var
  K, Cnt: Integer;
  AIs: TStringArray;
begin
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
    fGame.StartGame(AIs);
    btnServerStartMap.Caption := 'Stop Map';
  end
  else if (fGame.GameState = gsPlay) then
  begin
    btnServerStartMap.Caption := 'Start Map';
    fGame.EndGame();
  end
  else
  begin
    btnServerStartMap.Caption := 'Start Map';
  end
end;


// Test event
procedure TGame_form.btnSendEventClick(Sender: TObject);
begin
  fGame.SendEvent;
end;


// Update simulation status (ping, etc.)
procedure TGame_form.UpdateSimStatus();
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
  // Update Start simulation button
  case fGame.GameState of
    gsLobby, gsEnd: btnServerStartMap.Caption := 'Start Map';
    gsLoad, gsPlay: btnServerStartMap.Caption := 'Stop Map';
    else begin end;
  end;
end;




//------------------------------------------------------------------------------
// Logs
//------------------------------------------------------------------------------


// Log to console
procedure TGame_form.Log(const aText: String);
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


end.
