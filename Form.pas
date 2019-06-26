unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Game, ExtAIDelphi, Log,
  // Detection of IP address
  Winsock, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    btnClientConnect: TButton;
    btnClientSendAction: TButton;
    btnClientSendState: TButton;
    btnSendEvent: TButton;
    btnServerStartMap: TButton;
    btnStartServer: TButton;
    gbCpp: TGroupBox;
    gbExtAI: TGroupBox;
    gbDelphi: TGroupBox;
    gbPython36: TGroupBox;
    gbServer: TGroupBox;
    lLogExtAIDelphi: TLabel;
    lLogServer: TLabel;
    prgServer: TProgressBar;
    mClientLog: TMemo;
    mServerLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnClientConnectClick(Sender: TObject);
    procedure btnClientSendActionClick(Sender: TObject);
    procedure btnServerSendEventClick(Sender: TObject);
    procedure btnClientSendStateClick(Sender: TObject);
    procedure btnServerStartMapClick(Sender: TObject);
  private
    fGame: TGame;
    fExtAIDelphi: TExtAIDelphi;
    procedure ClientOnStatusMessage(const aMsg: String);
    procedure ClientOnConnectSucceed(Sender: TObject);
    procedure ClientOnForcedDisconnect(Sender: TObject);
  public
    { Public declarations }
    procedure Log(const aText: String);
    procedure ClientLog(const aText: String);
  end;

const
  PORT = 1235;
var
  Form1: TForm1;

implementation
uses
  ExtAINetworkTypes;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  gLog := TLog.Create(Log);
  gLog.Log('Initialization');
  gClientLog := TLog.Create(ClientLog);
  gClientLog.Log('Initialization');
  fGame := TGame.Create(nil);
  fExtAIDelphi := TExtAIDelphi.Create();
  fExtAIDelphi.Client.OnStatusMessage := ClientOnStatusMessage;
  fExtAIDelphi.Client.OnConnectSucceed := ClientOnConnectSucceed;
  fExtAIDelphi.Client.OnForcedDisconnect := ClientOnForcedDisconnect;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  fGame.TerminateSimulation();
  fExtAIDelphi.TerminateSimulation();
  Sleep(100);
  fGame.Free();
  fExtAIDelphi.Free();
  gLog.Free();
  gClientLog.Free();
end;


procedure TForm1.btnStartServerClick(Sender: TObject);
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


procedure TForm1.btnServerStartMapClick(Sender: TObject);
begin
  fGame.StartEndGame();
end;


procedure TForm1.btnServerSendEventClick(Sender: TObject);
var
  K: Integer;
begin
  if (fGame.Hands <> nil) then
    for K := 0 to fGame.Hands.Count - 1 do
      fGame.Hands[K].AIExt.Events.OnPlayerVictory(0);
end;


procedure TForm1.btnClientConnectClick(Sender: TObject);
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
  if (fExtAIDelphi.Client.Connected) then
  begin
    fExtAIDelphi.Client.Disconnect();
    btnClientConnect.Caption := 'Connect client';
    btnClientSendAction.Enabled := False;
    btnClientSendState.Enabled := False;
  end
  else if GetIP(IP) then
    fExtAIDelphi.Client.ConnectTo(IP, PORT);
end;


procedure TForm1.btnClientSendActionClick(Sender: TObject);
begin
  fExtAIDelphi.Actions.Log('This is debug message (Action.Log) from ExtAI in Delphi');
  fExtAIDelphi.Actions.GroupOrderWalk(1,2,3,4);
end;


procedure TForm1.btnClientSendStateClick(Sender: TObject);
begin
  //fExtAIDelphi.State.Log('This is debug message (States) from ExtAI in Delphi');
  ClientLog('States are not implemented');
end;


procedure TForm1.ClientOnConnectSucceed(Sender: TObject);
begin
  if (fExtAIDelphi.Client.Connected) then
  begin
    btnClientConnect.Caption := 'Disconnect client';
    btnClientSendAction.Enabled := True;
    //btnClientSendState.Enabled := True;
  end;
end;


procedure TForm1.ClientOnForcedDisconnect(Sender: TObject);
begin
  btnClientConnect.Caption := 'Connect client';
  btnClientSendAction.Enabled := False;
  btnClientSendState.Enabled := False;
end;


procedure TForm1.ClientOnStatusMessage(const aMsg: String);
begin
  gClientLog.Log(aMsg);
end;


procedure TForm1.Log(const aText: String);
begin
  mServerLog.Lines.Append(aText);
end;

procedure TForm1.ClientLog(const aText: String);
begin
  mClientLog.Lines.Append(aText);
end;


end.
