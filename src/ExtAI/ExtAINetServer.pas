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
  TClientNewIDEvent = procedure (aServerClient: TExtAIServerClient; aID: Word) of object;

  TExtAIServerClient = class
  private
    fHandle: TExtAINetHandleIndex;
    // Each client must have their own receive buffer, so partial messages don't get mixed
    fpStartData: pExtAINewData;
    fpEndData: pExtAINewData;
    fBuffer: TKExtAIMsgStream;
    fScheduledMsg: TKExtAIMsgStream;
    fPerformance: record
      NetPingIdx,NetPingMsgIdx: Word;
      TickPingIdx,TickPingMsgIdx: Word;
      NetPingArr: array [0..ExtAI_MSG_MAX_NET_PING_CNT-1] of Cardinal;
      TickPingArr: array [0..ExtAI_MSG_MAX_TICK_PING_CNT-1] of Cardinal;
    end;
    fOnCfg: TNewDataEvent;
    fOnAction: TNewDataEvent;
    fOnState: TNewDataEvent;
    procedure NillEvents();
    procedure Cfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
    procedure Performance(aData: Pointer);
    procedure Action(aData: Pointer; aTypeAction, aLength: Cardinal);
    procedure State(aData: Pointer; aTypeState, aLength: Cardinal);
    function GetNetPing(): Cardinal;
    function GetTickPing(): Cardinal;
  public
    constructor Create(aHandle: TExtAINetHandleIndex);
    destructor Destroy(); override;

    property OnCfg: TNewDataEvent write fOnCfg;
    property OnAction: TNewDataEvent write fOnAction;
    property OnState: TNewDataEvent write fOnState;
    property Handle: TExtAINetHandleIndex read fHandle;
    property Buffer: TKExtAIMsgStream read fBuffer;
    property ScheduledMsg: TKExtAIMsgStream read fScheduledMsg;
    property NetPing: Cardinal read GetNetPing;
    property TickPing: Cardinal read GetTickPing;

    procedure AddScheduledMsg(aData: Pointer; aLength: Cardinal);
  end;


  TExtAINetServer = class
  private
    fServer: TNetServerOverbyte;
    fClients: TObjectList<TExtAIServerClient>;

    fListening: Boolean;
    fNetPingLastMsg: Cardinal;
    fTickPingLastMsg: Cardinal;

    fServerName: AnsiString;
    fRoomCount: Integer;

    fOnStatusMessage: TGetStrProc;
    fOnClientConnect: TServerClientEvent;
    fOnClientNewID: TClientNewIDEvent;
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
    // Ping
    procedure SendNetPingRequest(aClient: TExtAIServerClient);
    procedure SendTickPingRequest(aClient: TExtAIServerClient); // In future time to process 1 tick by ExtAI
  public
    constructor Create();
    destructor Destroy(); override;

    property OnStatusMessage: TGetStrProc write fOnStatusMessage;
    property OnClientConnect: TServerClientEvent write fOnClientConnect;
    property OnClientNewID: TClientNewIDEvent write fOnClientNewID;
    property OnClientDisconnect: TServerClientEvent write fOnClientDisconnect;
    property Listening: Boolean read fListening;
    property Clients: TObjectList<TExtAIServerClient> read fClients;
    property Server: TNetServerOverbyte read fServer;

    procedure StartListening(aPort: Word; const aServerName: AnsiString);
    procedure StopListening();
    procedure UpdateState();

    function GetClientByHandle(aHandle: TExtAINetHandleIndex): TExtAIServerClient;
  end;


implementation
uses
  KM_CommonUtils;

const
  SERVER_VERSION: Cardinal = 20190622;


{ TExtAIServerClient }
constructor TExtAIServerClient.Create(aHandle: TExtAINetHandleIndex);
begin
  Inherited Create;
  fHandle := aHandle;
  fBuffer := TKExtAIMsgStream.Create();
  fScheduledMsg := TKExtAIMsgStream.Create();
  fpStartData := new(pExtAINewData);
  fpStartData^.Ptr := nil;
  fpStartData^.Next := nil;
  fpEndData := fpStartData;
  with fPerformance do
  begin
    NetPingIdx := 0;
    NetPingMsgIdx := 0;
    TickPingIdx := 0;
    TickPingMsgIdx := 0;
    FillChar(NetPingArr[0], SizeOf(NetPingArr[0]) * Length(NetPingArr), #0);
    FillChar(TickPingArr[0], SizeOf(TickPingArr[0]) * Length(TickPingArr), #0);
  end;
  NillEvents();
end;


destructor TExtAIServerClient.Destroy();
begin
  NillEvents();
  fBuffer.Free;
  fScheduledMsg.Free();
  repeat
    fpEndData := fpStartData;
    fpStartData := fpStartData.Next;
    if (fpEndData^.Ptr <> nil) then
      FreeMem(fpEndData^.Ptr, fpEndData^.Length);
    Dispose(fpEndData);
  until (fpStartData = nil);
  Inherited;
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


procedure TExtAIServerClient.Performance(aData: Pointer);
var
  //length: Cardinal;
  pData: Pointer;
  typePerf: TExtAIMsgTypePerformance;
begin
  // Check the type of message
  if (mkPerformance <> TExtAIMsgKind(aData^)) then
    Exit;
  // Get type of message
  pData := Pointer( NativeUInt(aData) + SizeOf(TExtAIMsgKind) );
  typePerf := TExtAIMsgTypePerformance(pData^);
  // Get length
  pData := Pointer( NativeUInt(pData) + SizeOf(TExtAIMsgTypePerformance) );
  //length := Cardinal( TExtAIMsgLengthData(pData^) );
  // Get pointer to data
  pData := Pointer( NativeUInt(pData) + SizeOf(TExtAIMsgLengthData) );
  // Process message
  with fPerformance do
    case typePerf of
      // Read poing ID and save time
      prPing : begin end;
      prPong:
        begin
          NetPingIdx := Word( pData^ );
          if (NetPingIdx < Length(NetPingArr)) then
            NetPingArr[NetPingIdx] := Max(0, TimeGet() - NetPingArr[NetPingIdx] )
          else
            NetPingIdx := 0;
        end;
      prTick:
        begin

        end;
    end;
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


function TExtAIServerClient.GetNetPing(): Cardinal;
begin
  with fPerformance do
    Result := NetPingArr[NetPingIdx];
end;


function TExtAIServerClient.GetTickPing(): Cardinal;
begin
  with fPerformance do
    Result := TickPingArr[TickPingIdx];
end;




{ TExtAINetServer }
constructor TExtAINetServer.Create();
begin
  Inherited Create;

  fClients := TObjectList<TExtAIServerClient>.Create();
  fServer := TNetServerOverbyte.Create();
  fListening := False;
  fRoomCount := 0;
  fNetPingLastMsg := 0;
  fTickPingLastMsg := 0;
  NillEvents();
end;


destructor TExtAINetServer.Destroy();
begin
  NillEvents();
  StopListening;
  fClients.Free; // Clients are freed in TObjectList
  fServer.Free;

  Inherited;
end;


procedure TExtAINetServer.NillEvents();
begin
  fOnStatusMessage := nil;
  fOnClientConnect := nil;
  fOnClientNewID := nil;
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
  Status(Format('Listening on port %d',[aPort]));
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
    fOnStatusMessage(Format('Server status: %s',[S]));
end;


// Send configuration of the server
procedure TExtAINetServer.SendServerCfg(aHandle: TExtAINetHandleIndex);
const
  NAME: UnicodeString = 'Testing AI';
  VERSION: Cardinal = 20191026;
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
    // Add ExtAI ID
    M.WriteMsgType(mkServerCfg, Cardinal(csExtAIID), SizeOf(aHandle));
    M.Write(aHandle, SizeOf(aHandle));
    // Send message
    ScheduleSendData(aHandle, M.Memory, M.Size, True);
  finally
    M.Free;
  end;
end;


procedure TExtAINetServer.SendNetPingRequest(aClient: TExtAIServerClient);
var
  M: TKExtAIMsgStream;
begin
  M := TKExtAIMsgStream.Create;
  try
    with aClient.fPerformance do
    begin
      // Save time
      NetPingMsgIdx := (NetPingMsgIdx + 1) mod ExtAI_MSG_MAX_NET_PING_CNT;
      NetPingArr[NetPingMsgIdx] := TimeGet();
      // Add version
      M.WriteMsgType(mkPerformance, Cardinal(prPing), SizeOf(NetPingMsgIdx));
      M.Write(NetPingMsgIdx, SizeOf(NetPingMsgIdx));
    end;
    // Send message
    ScheduleSendData(aClient.Handle, M.Memory, M.Size, True);
  finally
    M.Free;
  end;
end;


procedure TExtAINetServer.SendTickPingRequest(aClient: TExtAIServerClient);
var
  M: TKExtAIMsgStream;
begin
  M := TKExtAIMsgStream.Create;
  try
    with aClient.fPerformance do
    begin
      // Save time
      TickPingMsgIdx := (TickPingMsgIdx + 1) mod ExtAI_MSG_MAX_TICK_PING_CNT;
      TickPingArr[TickPingMsgIdx] := TimeGet();
      // Add version
      M.WriteMsgType(mkPerformance, Cardinal(prTick), SizeOf(TickPingMsgIdx));
      M.Write(TickPingMsgIdx, SizeOf(TickPingMsgIdx));
    end;
    // Send message
    ScheduleSendData(aClient.Handle, M.Memory, M.Size, True);
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
  Status(Format('New client: %d',[aHandle]));
  Client := TExtAIServerClient.Create(aHandle);
  fClients.Add(Client);

  if Assigned(fOnClientConnect) then
    fOnClientConnect(Client);

  // Send server configuration
  SendServerCfg(aHandle);
end;


// Someone has disconnected
procedure TExtAINetServer.ClientDisconnect(aHandle: TExtAINetHandleIndex);
var
  Client: TExtAIServerClient;
begin
  Client := GetClientByHandle(aHandle);
  if (Client = nil) then
  begin
    Status(Format('Warning: Client %d has already been disconnected',[aHandle]));
    Exit;
  end;

  if Assigned(fOnClientDisconnect) then
    fOnClientDisconnect(Client);

  fClients.Remove(Client); // TObjectList remove and free
  Status(Format('Client %d has been disconnected',[aHandle]));
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
  if aFlushQueue OR (Client.ScheduledMsg.Size + aLength > ExtAI_MSG_MAX_CUMULATIVE_PACKET_SIZE) then
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


procedure TExtAINetServer.UpdateState();
var
  K: Integer;
begin
  for K := 0 to fClients.Count - 1 do
  begin
    // Process new messages
    ProcessReceivedMessages(fClients[K]);
    // Check ping
    if (GetTimeSince(fNetPingLastMsg) >= ExtAI_MSG_TIME_INTERVAL_NET_PING) then
      SendNetPingRequest(fClients[K]);
    //if (GetTimeSince(fTickPingLastMsg) >= ExtAI_MSG_TIME_INTERVAL_TICK_PING) then
    //  SendTickPingRequest(fClients[K]);
    // Send outcoming messages
    SendScheduledData(fClients[K]);
  end;
  if (GetTimeSince(fNetPingLastMsg) >= ExtAI_MSG_TIME_INTERVAL_NET_PING) then
    fNetPingLastMsg := TimeGet();
  //if (GetTimeSince(fTickPingLastMsg) >= ExtAI_MSG_TIME_INTERVAL_TICK_PING) then
  //  fTickPingLastMsg := TimeGet();
end;


//Someone has send us something
procedure TExtAINetServer.DataAvailable(aHandle: TExtAINetHandleIndex; aData: Pointer; aLength: Cardinal);
var
  pNewData: pExtAINewData;
  Client: TExtAIServerClient;
begin
  //Status('Data available');

  Client := GetClientByHandle(aHandle);
  if (Client = nil) then
  begin
    Status('Warning: Data Available from an unassigned client');
    Exit;
  end;

  // Append new data to buffer
  with Client do
  begin
    New(pNewData);
    pNewData^.Ptr := nil;
    pNewData^.Next := nil;
    fpEndData^.Ptr := aData;
    fpEndData^.Length := aLength;
    AtomicExchange(fpEndData^.Next, pNewData);
    fpEndData := pNewData;
  end;
  // Check if new data are top prio (top prio data have its own message and are processed by NET thread)
  Client.Performance(  Pointer( NativeUInt(aData) + ExtAI_MSG_HEAD_SIZE )  );
end;


// Process received messages in 2 priorities:
// The first prio is for direct communication of client and server
// The second prio is for everything else so KP is master of its time
procedure TExtAINetServer.ProcessReceivedMessages(aClient: TExtAIServerClient);
var
  MaxPos, DataType, DataLenIdx: Cardinal;
  pData: Pointer;
  pOldData: pExtAINewData;
  pCopyFrom, pCopyTo: PChar;
  Recipient: TExtAIMsgRecipient;
  Sender: TExtAIMsgSender;
  Kind: TExtAIMsgKind;
  LengthMsg: TExtAIMsgLengthMsg;
  LengthData: TExtAIMsgLengthData;
  Buff: TKExtAIMsgStream;
begin
  // Merge incoming data into memory stream (Thread safe)
  with aClient do
    while (fpStartData^.Next <> nil) do
    begin
      pOldData := fpStartData;
      AtomicExchange(fpStartData, fpStartData^.Next);
      Buffer.Write(pOldData^.Ptr^, pOldData^.Length);
      FreeMem(pOldData^.Ptr, pOldData^.Length);
      Dispose(pOldData);
    end;
  Buff := aClient.Buffer;
  // Save size of the buffer
  MaxPos := Buff.Position;
  // Set actual index
  Buff.Position := 0;
  // Try to read new messages
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
            mkServerCfg:   begin end;
            mkGameCfg:     begin end;
            mkExtAICfg:
              begin
                // Check if ID was received / changed
                if (TExtAIMsgTypeCfgAI(DataType) = caID) AND Assigned(fOnClientNewID) then
                  fOnClientNewID(aClient, Word(pData^));
                aClient.Cfg(pData, DataType, LengthData);
              end;
            mkPerformance: begin end;
            mkAction:      aClient.Action(pData, DataType, LengthData);
            mkEvent:       begin end;
            mkState:       aClient.State(pData, DataType, LengthData);
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
