unit ExtAINetClientOverbyte;
interface
uses
  Classes, SysUtils, OverbyteIcsWSocket, WinSock;


// TCP client
type
  TNotifyDataEvent = procedure(aData: pointer; aLength: cardinal) of object;

  TNetClientOverbyte = class
  private
    fSocket: TWSocket;
    fOnError: TGetStrProc;
    fOnConnectSucceed: TNotifyEvent;
    fOnConnectFailed: TGetStrProc;
    fOnSessionDisconnected: TNotifyEvent;
    fOnRecieveData: TNotifyDataEvent;
    procedure NilEvents();
    procedure Connected(Sender: TObject; Error: Word);
    procedure Disconnected(Sender: TObject; Error: Word);
    procedure DataAvailable(Sender: TObject; Error: Word);
    procedure LogError(const aText: string; const aArgs: array of const);
  public
    constructor Create();
    destructor Destroy(); override;

    property OnError: TGetStrProc write fOnError;
    property OnConnectSucceed: TNotifyEvent write fOnConnectSucceed;
    property OnConnectFailed: TGetStrProc write fOnConnectFailed;
    property OnSessionDisconnected: TNotifyEvent write fOnSessionDisconnected;
    property OnRecieveData: TNotifyDataEvent write fOnRecieveData;

    function MyIPString(): String;
    function SendBufferEmpty(): Boolean;
    procedure ConnectTo(const aAddress: String; const aPort: Word);
    procedure Disconnect();
    procedure SendData(aData: pointer; aLength: Cardinal);
  end;


implementation


constructor TNetClientOverbyte.Create();
var
  wsaData: TWSAData;
begin
  Inherited Create;
  fSocket := nil;
  NilEvents();
  Assert(WSAStartup($101, wsaData) = 0, 'Error in Network');
end;


destructor TNetClientOverbyte.Destroy();
begin
  NilEvents(); // Disable callbacks before destroying socket (the app is terminating, callbacks do not have to work anymore)
  fSocket.Free;
  Inherited;
end;


procedure TNetClientOverbyte.NilEvents();
begin
  fOnError := nil;
  fOnConnectSucceed := nil;
  fOnConnectFailed := nil;
  fOnSessionDisconnected := nil;
  fOnRecieveData := nil;
end;


function TNetClientOverbyte.MyIPString(): String;
begin
  Result := '';
  if (LocalIPList.Count >= 1) then
    Result := LocalIPList[0]; // First address should be ours
end;


procedure TNetClientOverbyte.ConnectTo(const aAddress: String; const aPort: Word);
begin
  FreeAndNil(fSocket);
  fSocket := TWSocket.Create(nil);
  fSocket.ComponentOptions := [wsoTcpNoDelay]; // Send packets ASAP (disables Nagle's algorithm)
  fSocket.Proto := 'tcp';
  fSocket.Addr  := aAddress;
  fSocket.Port  := IntToStr(aPort);
  fSocket.OnSessionClosed := Disconnected;
  fSocket.OnSessionConnected := Connected;
  fSocket.OnDataAvailable := DataAvailable;
  try
    fSocket.Connect;
  except
    on E: Exception do
    begin
      // Trap the exception and tell the user. Note: While debugging, Delphi will still stop execution for the exception, but normally the dialouge won't show.
      if Assigned(fOnConnectFailed) then
        fOnConnectFailed(E.Message);
    end;
  end;
end;


procedure TNetClientOverbyte.Disconnect();
begin
  if (fSocket <> nil) then
  begin
    fOnRecieveData := nil;
    // ShutDown(1) Works better, then Close or CloseDelayed
    // With Close or CloseDelayed some data, that were sent just before disconnection could not be delivered to server.
    // F.e. mkDisconnect packet
    // But we can't send data into ShutDown'ed socket (we could try into Closed one, since it will have State wsClosed)
    fSocket.ShutDown(1);
  end;
end;


procedure TNetClientOverbyte.LogError(const aText: string; const aArgs: array of const);
begin
  if Assigned(fOnError) then
    fOnError(Format(aText,aArgs));
end;


procedure TNetClientOverbyte.SendData(aData: pointer; aLength: Cardinal);
begin
  if (fSocket <> nil) AND (fSocket.State = wsConnected) then // Sometimes this occurs just before disconnect/reconnect
    fSocket.Send(aData, aLength);
end;


function TNetClientOverbyte.SendBufferEmpty(): Boolean;
begin
  Result := True;
  if (fSocket <> nil) AND (fSocket.State = wsConnected) then
    Result := fSocket.AllSent;
end;


procedure TNetClientOverbyte.Connected(Sender: TObject; Error: Word);
begin
  if (Error <> 0) then
    LogError('Error: %s (#%d)',[WSocketErrorDesc(Error), Error])
  else
  begin
    if Assigned(fOnConnectSucceed) then
      fOnConnectSucceed(Self);
    fSocket.SetTcpNoDelayOption; // Send packets ASAP (disables Nagle's algorithm)
    fSocket.SocketSndBufSize := 65535; // WinSock buffer should be bigger than internal buffer
    fSocket.BufSize := 32768;
  end;
end;


procedure TNetClientOverbyte.Disconnected(Sender: TObject; Error: Word);
begin
  // Do not exit on error, because when a disconnect error occurs, the client has still disconnected
  if (Error <> 0) then
    LogError('Client: Disconnection error: %s (#%d)',[WSocketErrorDesc(Error), Error]);
  if Assigned(fOnSessionDisconnected) then
    fOnSessionDisconnected(Self);
end;


procedure TNetClientOverbyte.DataAvailable(Sender: TObject; Error: Word);
const
  BufferSize = 10240; // 10kb
var
  P: Pointer;
  L: Integer;
begin
  if (Error <> 0) then
    LogError('DataAvailable. Error %s (#%d)',[WSocketErrorDesc(Error), Error])
  else
  begin
    GetMem(P, BufferSize+1); //+1 to avoid RangeCheckError when L = BufferSize
    L := TWSocket(Sender).Receive(P, BufferSize);
    // L could be -1 when no data is available
    if (L > 0) AND Assigned(fOnRecieveData) then
      fOnRecieveData(P, Cardinal(L)) // The pointer is stored in ExtAINetClient and the memory will be freed later
    else
      FreeMem(P); // The pointer is NOT used and must be freed
  end;
end;


end.
