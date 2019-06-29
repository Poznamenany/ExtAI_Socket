unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Game, ExtAIDelphi, Log,
  // Detection of IP address
  Winsock, Vcl.ComCtrls;

type
  TExtAIAndGUI = record
    ID: Word;
    AI: TExtAIDelphi;
    Log: TLog;
    tsTab: TTabSheet;
    mLog: TMemo;
  end;
  TExtAIAndGUIArr = record
    Count: Word;
    Number: Word;
    Arr: array of TExtAIAndGUI;
  end;
  TExtAI_TestBed = class(TForm)
    btnAutoFill: TButton;
    btnClientConnect: TButton;
    btnClientSendAction: TButton;
    btnClientSendState: TButton;
    btnSendEvent: TButton;
    btnServerStartMap: TButton;
    btnStartServer: TButton;
    cbLoc0: TComboBox;
    cbLoc1: TComboBox;
    cbLoc2: TComboBox;
    cbLoc3: TComboBox;
    cbLoc4: TComboBox;
    cbLoc5: TComboBox;
    cbLoc6: TComboBox;
    cbLoc8: TComboBox;
    cbLoc9: TComboBox;
    cbLoc7: TComboBox;
    cbLoc10: TComboBox;
    cbLoc11: TComboBox;
    edLoc0: TEdit;
    edLoc1: TEdit;
    edLoc2: TEdit;
    edLoc3: TEdit;
    edLoc4: TEdit;
    edLoc5: TEdit;
    edLoc6: TEdit;
    edLoc7: TEdit;
    edLoc8: TEdit;
    edLoc9: TEdit;
    edLoc10: TEdit;
    edLoc11: TEdit;
    gbAIControlInterface: TGroupBox;
    ExtAIs: TGroupBox;
    gbKP: TGroupBox;
    gbLobby: TGroupBox;
    gbServer: TGroupBox;
    gbSimulation: TGroupBox;
    labLoc0: TLabel;
    labLoc1: TLabel;
    labLoc2: TLabel;
    labLoc3: TLabel;
    labLoc4: TLabel;
    labLoc5: TLabel;
    labLoc6: TLabel;
    labLoc7: TLabel;
    labLoc8: TLabel;
    labLoc9: TLabel;
    labLoc10: TLabel;
    labLoc11: TLabel;
    mServerLog: TMemo;
    prgServer: TProgressBar;

    btnCreateExtAI: TButton;
    btnTerminateExtAIs: TButton;
    pcLogExtAI: TPageControl;
    chbControlAll: TCheckBox;
    btnTerminateAI: TButton;
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
  private
    fGame: TGame;
    fExtAIAndGUIArr: TExtAIAndGUIArr;
    procedure ConnectClient(aIdx: Word);
    procedure DisconnectClient(aIdx: Integer);
    procedure RefreshAIGUI(Sender: TObject);
    function GetIdxByID(var aIdx: Integer; aID: Byte): boolean;
    function GetSelectedClient(var aIdx: Integer): boolean;
  public
    { Public declarations }
    procedure Log(const aText: String);
    procedure LogID(const aText: String; const aID: Byte);

    property AI: TExtAIAndGUIArr read fExtAIAndGUIArr write fExtAIAndGUIArr;
  end;

const
  PORT = 1235;
  TAB_NAME = 'tsExtAI';
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
  fGame := TGame.Create(nil);

  fExtAIAndGUIArr.Count := 0;
  fExtAIAndGUIArr.Number := 0;
  InitializeCriticalSection(csCriticalSection);
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
  if (fGame.ExtAIMaster.Net.Listening) then
  begin
    fGame.ExtAIMaster.Net.StopListening();
    prgServer.Style := pbstNormal;
    btnStartServer.Caption := 'Start Server';
    btnServerStartMap.Enabled := False;
    btnSendEvent.Enabled := False;
  end
  else
  begin
    fGame.ExtAIMaster.Net.StartListening(PORT,'Testing server');
    if (fGame.ExtAIMaster.Net.Listening) then
    begin
      prgServer.Style := pbstMarquee;
      btnStartServer.Caption := 'Stop Server';
      btnServerStartMap.Enabled := True;
      btnSendEvent.Enabled := True;
    end;
  end;
end;


procedure TExtAI_TestBed.pcOnChangeTab(Sender: TObject);
begin
  RefreshAIGUI(nil);
end;


procedure TExtAI_TestBed.btnServerStartMapClick(Sender: TObject);
begin
  fGame.StartEndGame();
end;


procedure TExtAI_TestBed.btnServerSendEventClick(Sender: TObject);
var
  K: Integer;
begin
  if (fGame.Hands <> nil) then
    for K := 0 to fGame.Hands.Count - 1 do
      fGame.Hands[K].AIExt.Events.PlayerVictoryW(0);
end;

procedure TExtAI_TestBed.btnClientConnectClick(Sender: TObject);
var
  Conn: Boolean;
  K, Idx: Integer;
begin
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
    ID := fExtAIAndGUIArr.Number;
    // Increase number
    Inc(fExtAIAndGUIArr.Number);
    // Create GUI
    tsTab := TTabSheet.Create(pcLogExtAI);
    tsTab.Caption := 'Log AI ' + IntToStr(ID);
    tsTab.Name := TAB_NAME + IntToStr(ID);
    tsTab.PageControl := pcLogExtAI;
    mLog := TMemo.Create(tsTab);
    mLog.Parent := tsTab;
    mLog.Align := alClient;
    // Create new ExtAI
    Log := TLog.Create(LogID, ID);
    AI := TExtAIDelphi.Create( Log, ID );
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
    Number := 0;
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
  IP: String;
begin
  if GetIP(IP) then
      fExtAIAndGUIArr.Arr[aIdx].AI.Client.ConnectTo(IP, PORT);
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


end.
