unit NetServerOverbyte;
interface
uses
  Classes, SysUtils, OverbyteIcsWSocket, OverbyteIcsWSocketS, WinSock;

// Tagging starts with some number away from -2 -1 0 used as sender/recipient constants
// and off from usual players indexes 1..8, so we could not confuse them by mistake
const FIRST_TAG = 15;

type
  THandleEvent = procedure (aHandle: SmallInt) of object;
  TNotifyDataEvent = procedure (aHandle: SmallInt; aData: pointer; aLength: Cardinal) of object;

  TNetServerOverbyte = class
  private
    fSocketServer: TWSocketServer;
    fLastTag: SmallInt;
    fOnError: TGetStrProc;
    fOnClientConnect: THandleEvent;
    fOnClientDisconnect: THandleEvent;
    fOnDataAvailable: TNotifyDataEvent;
    procedure NilEvents();
    procedure Error(const aText: String);
    procedure ClientConnect(aSender: TObject; aClient: TWSocketClient; aError: Word);
    procedure ClientDisconnect(aSender: TObject; aClient: TWSocketClient; aError: Word);
    procedure DataAvailable(aSender: TObject; aError: Word);
  public
    constructor Create();
    destructor Destroy(); override;

    property OnError: TGetStrProc write fOnError;
    property OnClientConnect: THandleEvent write fOnClientConnect;
    property OnClientDisconnect: THandleEvent write fOnClientDisconnect;
    property OnDataAvailable: TNotifyDataEvent write fOnDataAvailable;
    property Socket: TWSocketServer read fSocketServer;

    procedure StartListening(aPort: Word);
    procedure StopListening;
    procedure SendData(aHandle: SmallInt; aData: Pointer; aLength: Cardinal);
    procedure Kick(aHandle: SmallInt);
    function GetIP(aHandle: SmallInt): String;
    function GetMaxHandle: SmallInt;
  end;


implementation


constructor TNetServerOverbyte.Create();
var
  wsaData: TWSAData;
begin
  Inherited Create;
  fSocketServer := nil;
  NilEvents();
  fLastTag := FIRST_TAG - 1; // First client will be fLastTag+1
  if (WSAStartup($101, wsaData) <> 0) then
    Error('Error in Network');
end;


destructor TNetServerOverbyte.Destroy();
begin
  NilEvents(); // Disable callbacks before destroying socket (the app is terminating, callbacks do not have to work anymore)
  fSocketServer.Free;
  Inherited;
end;


procedure TNetServerOverbyte.NilEvents();
begin
  fOnError := nil;
  fOnClientConnect := nil;
  fOnClientDisconnect := nil;
  fOnDataAvailable := nil;
end;


procedure TNetServerOverbyte.Error(const aText: String);
begin
  if Assigned(fOnError) then
    fOnError(aText);
end;


procedure TNetServerOverbyte.StartListening(aPort: Word);
begin
  FreeAndNil(fSocketServer);
  fSocketServer := TWSocketServer.Create(nil);
  fSocketServer.ComponentOptions := [wsoTcpNoDelay]; // Send packets ASAP (disables Nagle's algorithm)
  fSocketServer.Proto  := 'tcp';
  fSocketServer.Addr   := '127.0.0.1'; // Listen to local adress
  fSocketServer.Port   := IntToStr(aPort);
  fSocketServer.Banner := '';
  fSocketServer.OnClientConnect := ClientConnect;
  fSocketServer.OnClientDisconnect := ClientDisconnect;
  fSocketServer.OnDataAvailable := DataAvailable;
  fSocketServer.Listen;
  fSocketServer.SetTcpNoDelayOption; // Send packets ASAP (disables Nagle's algorithm)
end;


procedure TNetServerOverbyte.StopListening();
begin
  if (fSocketServer <> nil) then
    fSocketServer.ShutDown(1);
  FreeAndNil(fSocketServer);
  fLastTag := FIRST_TAG-1;
end;


// Someone has connected to us
procedure TNetServerOverbyte.ClientConnect(aSender: TObject; aClient: TWSocketClient; aError: Word);
begin
  if (aError <> 0) then
  begin
    Error(Format('ClientConnect. Error: %s (#%d)', [WSocketErrorDesc(aError), aError]));
    Exit;
  end;

  // Identify index of the Client, so we can address it
  if (fLastTag = GetMaxHandle) then
    fLastTag := FIRST_TAG - 1;
  Inc(fLastTag);
  aClient.Tag := fLastTag;

  aClient.OnDataAvailable := DataAvailable;
  aClient.ComponentOptions := [wsoTcpNoDelay]; //Send packets ASAP (disables Nagle's algorithm)
  aClient.SetTcpNoDelayOption;
  if Assigned(fOnClientConnect) then
    fOnClientConnect(aClient.Tag);
end;


procedure TNetServerOverbyte.ClientDisconnect(aSender: TObject; aClient: TWSocketClient; aError: Word);
begin
  if (aError <> 0) then
  begin
    Error(Format('ClientDisconnect. Error: %s (#%d)', [WSocketErrorDesc(aError), aError]));
    // Do not exit because the client has to disconnect
  end;

  if Assigned(fOnClientDisconnect) then
    fOnClientDisconnect(aClient.Tag);
end;


// We recieved data from someone
procedure TNetServerOverbyte.DataAvailable(aSender: TObject; aError: Word);
const
  BufferSize = 10240; // 10kb
var
  P: Pointer;
  L: Integer; // L could be -1 when no data is available
begin
  if (aError <> 0) then
  begin
    Error(Format('DataAvailable. Error: %s (#%d)', [WSocketErrorDesc(aError), aError]));
    Exit;
  end;

  GetMem(P, BufferSize + 1); // +1 to avoid RangeCheckError when L = BufferSize
  L := TWSocket(aSender).Receive(P, BufferSize);

  if (L > 0) AND Assigned(fOnDataAvailable) then
    fOnDataAvailable(TWSocket(aSender).Tag, P, L) // The pointer is stored in ExtAINetServer and the memory will be freed later
  else
    FreeMem(P); // The pointer is NOT used and must be freed
end;


// Make sure we send data to specified client
procedure TNetServerOverbyte.SendData(aHandle: SmallInt; aData: Pointer; aLength: Cardinal);
var
  K: Integer;
begin
  for K := 0 to fSocketServer.ClientCount - 1 do
    if (fSocketServer.Client[K].Tag = aHandle) then
      if (fSocketServer.Client[K].State <> wsClosed) then // Sometimes this occurs just before ClientDisconnect
        if (Cardinal(fSocketServer.Client[K].Send(aData, aLength)) <> aLength) then
          Error(Format('Overbyte Server: Failed to send packet to client %d', [aHandle]));
end;


function TNetServerOverbyte.GetMaxHandle(): SmallInt;
begin
  Result := 32767;
end;


procedure TNetServerOverbyte.Kick(aHandle: SmallInt);
var
  K: Integer;
begin
  for K := 0 to fSocketServer.ClientCount - 1 do
    if (fSocketServer.Client[K].Tag = aHandle) then
    begin
      if (fSocketServer.Client[K].State <> wsClosed) then // Sometimes this occurs just before ClientDisconnect
        fSocketServer.Client[K].Close;
      Exit; // Only one client should have this handle
    end;
end;


function TNetServerOverbyte.GetIP(aHandle: SmallInt): String;
var
  K: Integer;
begin
  Result := '';
  for K := 0 to fSocketServer.ClientCount-1 do
    if (fSocketServer.Client[K].Tag = aHandle) then
    begin
      if (fSocketServer.Client[K].State <> wsClosed) then // Sometimes this occurs just before ClientDisconnect
        Result := fSocketServer.Client[K].GetPeerAddr;
      Exit; // Only one client should have this handle
    end;
end;


end.
