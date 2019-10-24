unit KP_Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  KM_Game, KM_CommonTypes, KM_Consts, ExtAILog, ExtAIInfo,
  // Detection of IP address
  Winsock;

type
  TGame_form = class(TForm)
    btnAutoFill: TButton;
    btnSendEvent: TButton;
    btnSendState: TButton;
    btnServerStartMap: TButton;
    btnStartServer: TButton;
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
    labLoc00: TLabel;
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
    edPingLoc08: TEdit;
    edPingLoc09: TEdit;
    edPingLoc07: TEdit;
    edPingLoc10: TEdit;
    edPingLoc11: TEdit;
    edServerPort: TEdit;
    gbLobby: TGroupBox;
    gbServer: TGroupBox;
    gbSimulation: TGroupBox;
    mTutorial: TMemo;
    mServerLog: TMemo;
    labPortNumber: TLabel;
    prgServer: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnServerSendEventClick(Sender: TObject);
    procedure btnServerStartMapClick(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
    procedure cbOnChange(Sender: TObject);
  private
    // Game class
    fGame: TKMGame;
    // Pure GUI of the game and some methods to maintain lobby list, etc.
    fcbLoc: array[0..MAX_HANDS_COUNT-1] of TComboBox;
    fedPingLoc: array[0..MAX_HANDS_COUNT-1] of TEdit;
    procedure RefreshComboBoxes(aServerClient: TExtAIInfo);
    procedure UpdateSimStatus();
  public
    procedure Log(const aText: String);
  end;

const
  TAB_NAME = 'tsExtAI';
  CLOSED_LOC = 'Closed';

var
  Game_form: TGame_form;

implementation

{$R *.dfm}

procedure TGame_form.FormCreate(Sender: TObject);
begin
  // Game log (log every input from Socket)
  gLog := TLog.Create(Log);
  gLog.Log('Initialization');
  // Game class
  fGame := TKMGame.Create(UpdateSimStatus);
  // Game events
  fGame.ExtAIMaster.OnAIConfigured := RefreshComboBoxes;
  fGame.ExtAIMaster.OnAIDisconnect := RefreshComboBoxes;

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
  RefreshComboBoxes(nil);
end;


procedure TGame_form.FormDestroy(Sender: TObject);
begin
  fGame.TerminateSimulation();
  fGame.Free;
  gLog.Free;
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
    btnStartServer.Caption := 'Start Server';
    btnServerStartMap.Enabled := False;
    btnSendEvent.Enabled := False;
    btnSendState.Enabled := False;
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
      btnStartServer.Caption := 'Stop Server';
      btnServerStartMap.Enabled := True;
      //btnSendEvent.Enabled := True;
      //btnSendState.Enabled := True;
    end;
  end;
end;


//------------------------------------------------------------------------------
// Lobby
//------------------------------------------------------------------------------

// Generic callback for combo boxes
procedure TGame_form.cbOnChange(Sender: TObject);
begin
  RefreshComboBoxes(nil);
end;


// Refresh list of available ExtAIs in the combo boxes so player can select just 1 instance of the AI for 1 slot
procedure TGame_form.RefreshComboBoxes(aServerClient: TExtAIInfo);
var
  ItemFound: Boolean;
  K,L,Cnt: Integer;
  AvailableAIs: TStringArray;
  SelectedAIs: array[0..MAX_HANDS_COUNT-1] of String;
begin
  // Get available AI players
  AvailableAIs := fGame.ExtAIMaster.GetExtAILobbyNames();

  // Filter already selected AI players
  Cnt := Length(AvailableAIs);
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    // Get actual selection (String, name of the ExtAI)
    SelectedAIs[K] := fcbLoc[K].Items[ fcbLoc[K].ItemIndex ];
    // Try to find selection in list of new names
    ItemFound := False;
    for L := 0 to Cnt - 1 do
      if (AvailableAIs[L] = SelectedAIs[K]) then
      begin
        // Confirm selection and remove AI from list of possible names
        ItemFound := True;
        Cnt := Cnt - 1;
        AvailableAIs[L] := AvailableAIs[Cnt];
        Break;
      end;
    // Remove selection
    if not ItemFound then
      SelectedAIs[K] := '';
  end;

  // Refresh combo boxes
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
  end;
end;


// Auto fill available ExtAIs in the lobby
procedure TGame_form.btnAutoFillClick(Sender: TObject);
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

      // Refresh GUI
      RefreshComboBoxes(nil);
    end;
end;


//------------------------------------------------------------------------------
// Simulation
//------------------------------------------------------------------------------

// Start the map (simulation of the game)
procedure TGame_form.btnServerStartMapClick(Sender: TObject);
var
  K: Integer;
  AIs: TStringArray;
begin
  // Get AI players in the lobby
  SetLength(AIs,MAX_HANDS_COUNT);
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    // Get actual selection
    AIs[K] := fcbLoc[K].Items[ fcbLoc[K].ItemIndex ];
    if (Length(AIs[K]) > 0) AND (AIs[K] = CLOSED_LOC) then
      AIs[K] := ''; // Closed loc
  end;
  // Start / stop the simulation with specific AI players
  fGame.StartEndGame(AIs);
  if (fGame.GameState = gsLobby) then
    btnServerStartMap.Caption := 'Start Map'
  else
    btnServerStartMap.Caption := 'Stop Map';
end;


// Test event
procedure TGame_form.btnServerSendEventClick(Sender: TObject);
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
  AvailableAIs := fGame.ExtAIMaster.GetExtAILobbyNames();
  // Update ping
  for K := Low(fcbLoc) to High(fcbLoc) do
  begin
    fedPingLoc[K].Text := '0';
    for L := Low(AvailableAIs) to High(AvailableAIs) do
      if AvailableAIs[L] = fcbLoc[K].Items[ fcbLoc[K].ItemIndex ] then
        fedPingLoc[K].Text := IntToStr(fGame.ExtAIMaster.AIs[L].ServerClient.NetPing);
  end;
end;


// Log to console
procedure TGame_form.Log(const aText: String);
begin
  mServerLog.Lines.Append(aText);
end;


end.
