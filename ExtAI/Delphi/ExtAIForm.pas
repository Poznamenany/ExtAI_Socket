unit ExtAIForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ExtAILog, ExtAIDelphi,
  // Detection of IP address
  Winsock, Vcl.ComCtrls;

type
  TExtAI = class(TForm)
    btnConnectClient: TButton;
    btnSendAction: TButton;
    btnSendState: TButton;
    edPort: TEdit;
    gbExtAI: TGroupBox;
    labPort: TLabel;
    mLog: TMemo;
    procedure btnConnectClientClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSendActionClick(Sender: TObject);
  private
    { Private declarations }
    fExtAI: TExtAIDelphi;
    fLog: TLog;
    procedure RefreshAIGUI(Sender: TObject);
    procedure Log(const aText: String);
  public
    { Public declarations }
  end;

var
  ExtAI: TExtAI;

implementation

{$R *.dfm}


procedure TExtAI.FormCreate(Sender: TObject);
begin
  fLog := TLog.Create(Log);
  fExtAI := TExtAIDelphi.Create(fLog,1);
  fExtAI.Client.OnConnectSucceed := RefreshAIGUI;
  fExtAI.Client.OnForcedDisconnect := RefreshAIGUI;
end;


procedure TExtAI.FormDestroy(Sender: TObject);
begin
  fExtAI.TerminateSimulation();
  Sleep(100);
  fExtAI.Free;
  fLog.Free;
end;


procedure TExtAI.btnConnectClientClick(Sender: TObject);
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
  IP, Port: String;
begin
  if fExtAI.Client.Connected then
  begin
    fExtAI.Client.Disconnect;
    btnConnectClient.Caption := 'Connect Client';
    btnSendAction.Enabled := False;
    btnSendState.Enabled := False;
  end
  else if GetIP(IP) then
  begin
    try
      Port := edPort.Text;
      //fExtAI.Client.ConnectTo(IP, StrToInt(Port));
      fExtAI.Client.ConnectTo('127.0.0.1', StrToInt(Port));
    except
      Log('Invalid port number');
    end;
  end
  else
    Log('IP address was not detected')
end;


procedure TExtAI.btnSendActionClick(Sender: TObject);
begin
  fExtAI.Actions.Log('This is debug message (Action.Log) from ExtAI');
end;


procedure TExtAI.RefreshAIGUI(Sender: TObject);
begin
  if fExtAI.Client.Connected then
  begin
    btnConnectClient.Caption := 'Disconnect Client';
    btnSendAction.Enabled := True;
    //btnSendState.Enabled := True;
  end
  else
  begin
    btnConnectClient.Caption := 'Connect Client';
    btnSendAction.Enabled := False;
    btnSendState.Enabled := False;
  end;
end;


procedure TExtAI.Log(const aText: String);
begin
  mLog.Lines.Append(aText);
end;

end.
