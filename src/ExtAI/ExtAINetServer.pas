unit ExtAINetServer;
interface
uses
  Windows, NetServerOverbyte,
  Classes, SysUtils, Math, Generics.Collections,
  ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAINetworkTypes;


type
  TExtAIServerClient = class;
  TNewMsgEvent = procedure (aData: Pointer; aLength: Cardinal) of object;
  TNewDataEvent = procedure (aData: Pointer; aDataType, aLength: Cardinal) of object;
  TServerClientEvent = procedure (aServerClient: TExtAIServerClient) of object;

  TExtAIServerClient = class
  private
    fHandle: TExtAINetHandleIndex;
    //Each client must have their own receive buffer, so partial messages don't get mixed
    fBuffer: TKExtAIMsgStream;
    fScheduledMsg: TKExtAIMsgStream;
    fOnCfg: TNewDataEvent;
    fOnAction: TNewDataEvent;
    fOnState: TNewDataEvent;
    procedure NillEvents();
    procedure Cfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
    procedure Action(aData: Pointer; aTypeAction, aLength: Cardinal);
    procedure State(aData: Pointer; aTypeState, aLength: Cardinal);
  public
    constructor Create(aHandle: TExtAINetHandleIndex);
    destructor Destroy(); override;

    property OnCfg: TNewDataEvent write fOnCfg;
    property OnAction: TNewDataEvent write fOnAction;
    property OnState: TNewDataEvent write fOnState;
    property Handle: TExtAINetHandleIndex read fHandle;
    property Buffer: TKExtAIMsgStream read fBuffer;
    property ScheduledMsg: TKExtAIMsgStream read fScheduledMsg;

    procedure AddScheduledMsg(aData: Pointer; aLength: Cardinal);
  end;


  TExtAINetServer = class
  private
    fServer: TNetServerOverbyte;
    fClients: TList<TExtAIServerClient>;

    fListening: Boolean;

    fServerName: AnsiString;
    fRoomCount: Integer;

    fOnStatusMessage: TGetStrProc;
    fOnClientConnect: TServerClientEvent;
    fOnClientDisconnect: TServerClientEvent;
    procedure Status(const S: string);
    procedure SendServerCfg(aHandle: TExtAINetHandleIndex);
    // Events from server
    procedure ClientConnect(aHandle: TExtAINetHandleIndex);
    procedure ClientDisconnect(aHandle: TExtAINetHandleIndex);
    procedure DataAvailable(aHandle: TExtAINetHandleIndex; aData: Pointer; aLength: Cardinal);
    procedure Error(const S: string);
    procedure NillEvents();
    // Pack and send message
    procedure ScheduleSendData(aRecipient: TExtAINetHandleIndex; aData: Pointer; aLength: Cardinal; aFlushQueue: Boolean = False);
    procedure SendScheduledData(aClient: TExtAIServerClient);
    // Unpack and process input messages
    procedure ProcessReceivedMessages(aClient: TExtAIServerClient);
  public
    constructor Create();
    destructor Destroy(); override;

    property OnStatusMessage: TGetStrProc write fOnStatusMessage;
    property OnClientConnect: TServerClientEvent write fOnClientConnect;
    property OnClientDisconnect: TServerClientEvent write fOnClientDisconnect;
    property Listening: boolean read fListening;
    property Clients: TList<TExtAIServerClient> read fClients;

    procedure StartListening(aPort: Word; const aServerName: AnsiString);
    procedure StopListening();
    procedure UpdateState();

    function GetClientByHandle(aHandle: TExtAINetHandleIndex): TExtAIServerClient;
  end;


implementation

const
  SERVER_VERSION: Cardinal = 20190622;


{ TExtAIServerClient }
constructor TExtAIServerClient.Create(aHandle: TExtAINetHandleIndex);
begin
  inherited Create;
  fHandle := aHandle;
  fBuffer := TKExtAIMsgStream.Create();
  fScheduledMsg := TKExtAIMsgStream.Create();
  NillEvents();
end;


destructor TExtAIServerClient.Destroy();
begin
  NillEvents();
  fBuffer.Free;
  fScheduledMsg.Free();
  inherited;
end;


procedure TExtAIServerClient.NillEvents();
begin
  fOnCfg := nil;
  fOnAction := nil;
  fOnState := nil;
end;


procedure TExtAIServerClient.Cfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
begin
  if Assigned(fOnCfg) then
    fOnCfg(aData, aTypeCfg, aLength);
end;


procedure TExtAIServerClient.Action(aData: Pointer; aTypeAction, aLength: Cardinal);
begin
  if Assigned(fOnAction) then
    fOnAction(aData, aTypeAction, aLength);
end;


procedure TExtAIServerClient.State(aData: Pointer; aTypeState, aLength: Cardinal);
begin
  if Assigned(fOnState) then
    fOnState(aData, aTypeState, aLength);
end;


procedure TExtAIServerClient.AddScheduledMsg(aData: Pointer; aLength: Cardinal);
begin
  fScheduledMsg.Write(aData^, aLength);
end;


{ TExtAINetServer }
constructor TExtAINetServer.Create();
begin
  inherited Create;

  fClients := TList<TExtAIServerClient>.Create();
  fServer := TNetServerOverbyte.Create();
  fListening := False;
  fRoomCount := 0;
  NillEvents();
end;


destructor TExtAINetServer.Destroy();
var
  K: Integer;
begin
  NillEvents();
  StopListening;
  for K := 0 to fClients.Count-1 do
    fClients[K].Free;
  fServer.Free;
  fClients.Free;

  inherited;
end;


procedure TExtAINetServer.NillEvents();
begin
  fOnStatusMessage := nil;
  fOnClientConnect := nil;
  fOnClientDisconnect := nil;
end;


function TExtAINetServer.GetClientByHandle(aHandle: TExtAINetHandleIndex): TExtAIServerClient;
var
  K: Integer;
begin
  Result := nil;
  for K := 0 to fClients.Count-1 do
    if (fClients[K].Handle = aHandle) then
      Exit(fClients[K]);
end;


procedure TExtAINetServer.StartListening(aPort: Word; const aServerName: AnsiString);
begin
  fRoomCount := 0;

  fServerName := aServerName;
  fServer.OnError := Error;
  fServer.OnClientConnect := ClientConnect;
  fServer.OnClientDisconnect := ClientDisconnect;
  fServer.OnDataAvailable := DataAvailable;
  fServer.StartListening(aPort);
  Status('Listening on port ' + IntToStr(aPort));
  fListening := true;
end;


procedure TExtAINetServer.StopListening();
begin
  fServer.StopListening;
  fListening := false;
  fRoomCount := 0;
  Status('Stop listening');
end;


procedure TExtAINetServer.Error(const S: string);
begin
  Status(S);
end;


procedure TExtAINetServer.Status(const S: string);
begin
  if Assigned(fOnStatusMessage) then
    fOnStatusMessage('Server status: ' + S);
end;


// Send configuration of the server
procedure TExtAINetServer.SendServerCfg(aHandle: TExtAINetHandleIndex);
const
  NAME: UnicodeString = 'Testing AI';
  VERSION: Cardinal = 20190629;
var
  M: TKExtAIMsgStream;
begin
  M := TKExtAIMsgStream.Create;
  try
    // Add version
    M.WriteMsgType(mkServerCfg, Cardinal(csVersion), SizeOf(VERSION));
    M.Write(VERSION, SizeOf(VERSION));
    // Add name
    M.WriteMsgType(mkServerCfg, Cardinal(csName), SizeOf(Word) + SizeOf(WideChar) * Length(NAME));
    M.WriteW(NAME);
    // Add client ID
    M.WriteMsgType(mkServerCfg, Cardinal(csClientHandle), SizeOf(aHandle));
    M.Write(aHandle, SizeOf(aHandle));
    // Send message
    ScheduleSendData(aHandle, M.Memory, M.Size, True);
  finally
    M.Free;
  end;
end;


// Someone has connected
procedure TExtAINetServer.ClientConnect(aHandle: TExtAINetHandleIndex);
var
  Client: TExtAIServerClient;
begin
  // Add new client
  Status('New client: ' + IntToStr(aHandle));
  Client := TExtAIServerClient.Create(aHandle);
  fClients.Add(Client);

  if Assigned(fOnClientConnect) then
    fOnClientConnect(Client);

  // Send server configuration
  SendServerCfg(aHandle);
end;


//Someone has disconnected
procedure TExtAINetServer.ClientDisconnect(aHandle: TExtAINetHandleIndex);
var
  K: Integer;
  Client: TExtAIServerClient;
begin
  Client := GetClientByHandle(aHandle);
  if (Client = nil) then
  begin
    Status('Warning: Client ' + IntToStr(aHandle)+' was already disconnected');
    Exit;
  end;

  if Assigned(fOnClientDisconnect) then
    fOnClientDisconnect(Client);

  Status('Client '+IntToStr(aHandle)+' has disconnected');
  for K := 0 to fClients.Count-1 do
    if (fClients[K].Handle = aHandle) then
    begin
      fClients[K].Free;
      fClients.Delete(K);
      Exit;
    end;
end;


procedure TExtAINetServer.ScheduleSendData(aRecipient: TExtAINetHandleIndex; aData: Pointer; aLength: Cardinal; aFlushQueue: Boolean = False);
var
  Client: TExtAIServerClient;
begin
  // Check if client is connected
  Client := GetClientByHandle(aRecipient);
  if (Client = nil) then
    Exit;
  // If the size of final message is too big, send the actual schedule
  if (Client.ScheduledMsg.Size + aLength > ExtAI_MSG_MAX_CUMULATIVE_PACKET_SIZE) then
    SendScheduledData(Client);

  Client.AddScheduledMsg(aData, aLength);
  // Force to send the message immediately
  if aFlushQueue then
    SendScheduledData(Client);
end;


procedure TExtAINetServer.SendScheduledData(aClient: TExtAIServerClient);
var
  Msg: TKExtAIMsgStream;
begin
  if (aClient.ScheduledMsg.Position > 0) then
  begin
    Msg := TKExtAIMsgStream.Create();
    try
      // Create head
      Msg.WriteHead(aClient.Handle, ExtAI_MSG_ADDRESS_SERVER, aClient.ScheduledMsg.Position);
      // Copy data field
      Msg.Write(aClient.ScheduledMsg.Memory^, aClient.ScheduledMsg.Position);
      // Send data
      //Msg.Position := 0;
      fServer.SendData(aClient.Handle, Msg.Memory, Msg.Size);
      aClient.ScheduledMsg.Clear;
    finally
      Msg.Free;
    end;
  end;
end;


//Someone has send us something
procedure TExtAINetServer.DataAvailable(aHandle: TExtAINetHandleIndex; aData: Pointer; aLength: Cardinal);
var
  Client: TExtAIServerClient;
begin
  Client := GetClientByHandle(aHandle);
  if (Client = nil) then
  begin
    Status('Warning: Data Available from an unassigned client');
    Exit;
  end;

  // Append new data to buffer
  Client.Buffer.Write(aData^, aLength);

  Status('Data available');
end;


procedure TExtAINetServer.UpdateState();
var
  K: Integer;
begin
  for K := 0 to fClients.Count - 1 do
  begin
    ProcessReceivedMessages(fClients[K]);
    SendScheduledData(fClients[K]);
  end;
end;


procedure TExtAINetServer.ProcessReceivedMessages(aClient: TExtAIServerClient);
var
  MaxPos, DataType, DataLenIdx: Cardinal;
  pData: Pointer;
  pCopyFrom, pCopyTo: PChar;
  Recipient: TExtAIMsgRecipient;
  Sender: TExtAIMsgSender;
  Kind: TExtAIMsgKind;
  LengthMsg: TExtAIMsgLengthMsg;
  LengthData: TExtAIMsgLengthData;
  Buff: TKExtAIMsgStream;
begin
  Buff := aClient.Buffer;
  // Save size of the buffer
  MaxPos := Buff.Position;
  // Try to read new messages
  Buff.Position := 0;
  while (MaxPos - Buff.Position >= ExtAI_MSG_HEAD_SIZE) do
  begin
    // Read head (move Buff.Position from first byte of head to first byte of data)
    Buff.ReadHead(Recipient, Sender, LengthMsg);
    DataLenIdx := Buff.Position + LengthMsg;
    // Check if the message is complete
    if (DataLenIdx <= MaxPos) then
    begin
      // Get data from the message
      while (Buff.Position < DataLenIdx) do
      begin
        // Read type of the data - type is Cardinal so it can change its size in dependence on the Kind in the message
        Buff.ReadMsgType(Kind, DataType, LengthData);
        if (Buff.Position + LengthData <= MaxPos) then
        begin
          // Get pointer to data (pointer to memory of stream + idx to actual position)
          pData := Pointer(NativeUInt(Buff.Memory) + Buff.Position);
          // Process message
          case Kind of
            mkServerCfg: begin end;
            mkGameCfg:   begin end;
            mkExtAICfg:  aClient.Cfg(pData, DataType, LengthData);
            mkAction:    aClient.Action(pData, DataType, LengthData);
            mkEvent:     begin end;
            mkState:     aClient.State(pData, DataType, LengthData);
          end;
          // Move position to next Head or Data
          Buff.Position := Buff.Position + LengthData;
        end
        else
          Error('Length of the data does not match the length of the message');
      end;
    end
    else
      break;
  end;
  // Copy the rest at the start of the buffer
  MaxPos := MaxPos - Buff.Position;
  if (Buff.Position > 0) AND (MaxPos > 0) then
  begin
    // Copy the rest of the stream at the start
    pCopyFrom := Pointer(NativeUInt(Buff.Memory) + Buff.Position);
    pCopyTo := Buff.Memory;
    Move(pCopyFrom^, pCopyTo^, MaxPos);
  end;
  // Move position at the end
  Buff.Position := MaxPos;
end;


end.
