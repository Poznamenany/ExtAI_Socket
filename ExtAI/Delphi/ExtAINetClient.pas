unit ExtAINetClient;
interface
uses
  Classes, SysUtils, Math,
  ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAINetClientOverbyte;

type

  TNewDataEvent = procedure (aData: Pointer; aDataType, aLength: Cardinal) of object;
  TExtAINetClientImplementation = TNetClientOverbyte;


  TExtAINetClient = class
  private
    // Client
    fClient: TExtAINetClientImplementation;
    fClientID: TExtAINetHandleIndex;
    fConnected: Boolean;
    // Buffer
    fBuff: TKExtAIMsgStream;
    // ExtAI properties
    fAuthor: UnicodeString;
    fName: UnicodeString;
    fDescription: UnicodeString;
    fAIVersion: Cardinal;
    // Events
    fOnConnectSucceed: TNotifyEvent;
    fOnConnectFailed: TGetStrProc;
    fOnForcedDisconnect: TNotifyEvent;
    fOnStatusMessage: TGetStrProc;
    fOnNewEvent: TNewDataEvent;
    fOnNewState: TNewDataEvent;
    procedure NillEvents();
    procedure Error(const S: String);
    procedure ConnectSucceed(Sender: TObject);
    procedure ConnectFailed(const S: String);
    procedure ForcedDisconnect(Sender: TObject);
    procedure RecieveData(aData: Pointer; aLength: Cardinal);
    procedure GameCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
    procedure Event(aData: Pointer; aTypeEvent, aLength: Cardinal);
    procedure State(aData: Pointer; aTypeState, aLength: Cardinal);
    procedure Status(const S: String);
    procedure ServerCfg(DataType: Cardinal);
    procedure SendExtAICfg();

  public
    constructor Create(const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
    destructor Destroy; override;

    property Client: TExtAINetClientImplementation read fClient;
    property ClientHandle: TExtAINetHandleIndex read fClientID;
    property Connected: Boolean read fConnected;
    property OnConnectSucceed: TNotifyEvent write fOnConnectSucceed;
    property OnConnectFailed: TGetStrProc write fOnConnectFailed;
    property OnForcedDisconnect: TNotifyEvent write fOnForcedDisconnect;
    property OnStatusMessage: TGetStrProc write fOnStatusMessage;
    property OnNewEvent: TNewDataEvent write fOnNewEvent;
    property OnNewState: TNewDataEvent write fOnNewState;

    property Author: UnicodeString read fAuthor;
    property ClientName: UnicodeString read fName;
    property Description: UnicodeString read fDescription;
    property AIVersion: Cardinal read fAIVersion;

    procedure ConnectTo(const aAddress: String; const aPort: Word); //Try to connect to server
    procedure Disconnect(); //Disconnect from server
    //procedure SendData(aData: Pointer; aLength: Cardinal);
    procedure SendMessage(aMsg: Pointer; aLengthMsg: TExtAIMsgLengthMsg);
    procedure ProcessReceivedMessages();
  end;


implementation


const
  CLIENT_VERSION: Cardinal = 20190629;


{ TExtAINetClient }
constructor TExtAINetClient.Create(const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
begin
  inherited Create;

  fAuthor := aAuthor;
  fName := aName;
  fDescription := aDescription;
  fAIVersion := aVersion;

  NillEvents();
  fConnected := False;
  fClient := TExtAINetClientImplementation.Create();
  fBuff := TKExtAIMsgStream.Create();
end;


destructor TExtAINetClient.Destroy();
begin
  NillEvents();
  if Connected then
    Disconnect();
  fClient.Free;
  fBuff.Free;
  inherited;
end;


procedure TExtAINetClient.NillEvents();
begin
  fOnConnectSucceed := nil;
  fOnConnectFailed := nil;
  fOnForcedDisconnect := nil;
  fOnStatusMessage := nil;
  fOnNewEvent := nil;
  fOnNewState := nil;
end;


procedure TExtAINetClient.Error(const S: String);
begin
  Status('NetClient Error: ' + S);
end;


procedure TExtAINetClient.Status(const S: String);
begin
  if Assigned(fOnStatusMessage) then
    fOnStatusMessage('NetClient: ' + S);
end;


procedure TExtAINetClient.ConnectTo(const aAddress: String; const aPort: Word);
begin
  fBuff.Clear;
  fClient.OnError := Error;
  fClient.OnConnectSucceed := ConnectSucceed;
  fClient.OnConnectFailed := ConnectFailed;
  fClient.OnSessionDisconnected := ForcedDisconnect;
  fClient.OnRecieveData := RecieveData;
  fClient.ConnectTo(aAddress, aPort);
  Status('Connecting to: ' + aAddress + '; Port: ' + IntToStr(aPort));
end;


procedure TExtAINetClient.ConnectSucceed(Sender: TObject);
begin
  fConnected := True;
  if Assigned(fOnConnectSucceed) then
    fOnConnectSucceed(Self);
  Status('Connect succeed - IP: ' + Client.MyIPString());
end;


procedure TExtAINetClient.ConnectFailed(const S: String);
begin
  fConnected := False;
  if Assigned(fOnConnectFailed) then
    fOnConnectFailed(S);
  Status('Connection failed. ' + S);
end;


procedure TExtAINetClient.Disconnect();
begin
  fConnected := False;
  fClient.Disconnect;
  Status('Disconnected');
end;


// Connection failed / deliberately disconnection / server disconnect
procedure TExtAINetClient.ForcedDisconnect(Sender: TObject);
begin
  if fConnected then
  begin
    Status('Forced disconnect');
    if Assigned(fOnForcedDisconnect) then
      fOnForcedDisconnect(Self);
  end;
  fConnected := false;
end;


// Create message and send it immediately via protocol
procedure TExtAINetClient.SendMessage(aMsg: Pointer; aLengthMsg: TExtAIMsgLengthMsg);
var
  Msg: TKExtAIMsgStream;
begin
  Assert(aLengthMsg <= ExtAI_MSG_MAX_SIZE, 'Message over size limit');
  if not fConnected then
  begin
    Error('The client is not connected to the server');
    Exit;
  end;
  // Allocate memory
  Msg := TKExtAIMsgStream.Create();
  try
    // Create head
    Msg.WriteHead(ExtAI_MSG_ADDRESS_SERVER, fClientID, aLengthMsg);
    // Copy data field
    Msg.Write(aMsg^, aLengthMsg);
    // Send data
    Msg.Position := 0;
    fClient.SendData(Msg.Memory, Msg.Size);
  finally
    Msg.Free;
  end;
end;


procedure TExtAINetClient.ServerCfg(DataType: Cardinal);
var
  ServerVersion, BackupPosition: Cardinal;
  Str: UnicodeString;
begin
  BackupPosition := fBuff.Position;
  case TExtAIMsgTypeCfgServer(DataType) of
    csName:
    begin
      fBuff.ReadW(Str);
      Status('Server name: ' + Str);
    end;
    csVersion:
    begin
      fBuff.Read(ServerVersion);
      Status('Server version = ' + IntToStr( ServerVersion ));
      Status('Client version = ' + IntToStr( CLIENT_VERSION ));
      if (ServerVersion = CLIENT_VERSION) then
        SendExtAICfg();
    end;
    csClientHandle:
    begin
      fBuff.Read(fClientID, SizeOf(fClientID));
      Status('Client handle: ' + IntToStr(fClientID));
    end;
    else Status('Unknown server cfg message');
  end;
  fBuff.Position := BackupPosition;
end;


procedure TExtAINetClient.GameCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
begin
  //SendMessage(aData, aLength);
end;


// Send ExtAI configuration
procedure TExtAINetClient.SendExtAICfg();
var
  M: TKExtAIMsgStream;
begin
  M := TKExtAIMsgStream.Create;
  try
    // Add author
    M.WriteMsgType(mkExtAICfg, Cardinal(caAuthor), SizeOf(Word) + SizeOf(WideChar) * Length(fAuthor));
    M.WriteW(fAuthor);
    // Add name
    M.WriteMsgType(mkExtAICfg, Cardinal(caName), SizeOf(Word) + SizeOf(WideChar) * Length(fName));
    M.WriteW(fName);
    // Add description
    M.WriteMsgType(mkExtAICfg, Cardinal(caDescription), SizeOf(Word) + SizeOf(WideChar) * Length(fDescription));
    M.WriteW(fDescription);
    // Add ExtAI version
    M.WriteMsgType(mkExtAICfg, Cardinal(caVersion), SizeOf(fAIVersion));
    M.Write(fAIVersion);
    //M.Position := 0;
    SendMessage(M.Memory, M.Size);
  finally
    M.Free;
  end;
end;


// Receive Event
procedure TExtAINetClient.Event(aData: Pointer; aTypeEvent, aLength: Cardinal);
begin
  if Assigned(fOnNewEvent) then
    fOnNewEvent(aData, aTypeEvent, aLength);
end;


// Requested State
procedure TExtAINetClient.State(aData: Pointer; aTypeState, aLength: Cardinal);
begin
  if Assigned(fOnNewState) then
    fOnNewState(aData, aTypeState, aLength);
end;


procedure TExtAINetClient.ProcessReceivedMessages();
var
  MaxPos, DataType, DataLenIdx: Cardinal;
  pData: Pointer;
  pCopyFrom, pCopyTo: PChar;
  Recipient: TExtAIMsgRecipient;
  Sender: TExtAIMsgSender;
  Kind: TExtAIMsgKind;
  LengthMsg: TExtAIMsgLengthMsg;
  LengthData: TExtAIMsgLengthData;
begin
  // Save size of the buffer
  MaxPos := fBuff.Position;
  // Try to read new messages
  fBuff.Position := 0;
  while (MaxPos - fBuff.Position >= ExtAI_MSG_HEAD_SIZE) do
  begin
    // Read head (move fBuff.Position from first byte of head to first byte of data)
    fBuff.ReadHead(Recipient, Sender, LengthMsg);
    DataLenIdx := fBuff.Position + LengthMsg;
    // Check if the message is complete
    if (fBuff.Position + LengthMsg <= MaxPos) then
    begin
      // Get data from the message
      while (fBuff.Position < DataLenIdx) do
      begin
        // Read type of the data - type is Cardinal so it can change its size in dependence on the Kind in the message
        fBuff.ReadMsgType(Kind, DataType, LengthData);
        if (fBuff.Position + LengthData <= MaxPos) then
        begin
          // Get pointer to data (pointer to memory of stream + idx to actual position)
          pData := Pointer(NativeUInt(fBuff.Memory) + fBuff.Position);
          // Process message
          case Kind of
            mkServerCfg: ServerCfg(DataType);
            mkGameCfg:   GameCfg(pData, DataType, LengthData);
            mkExtAICfg:  begin end;
            mkAction:    begin end;
            mkEvent:     Event(pData, DataType, LengthData);
            mkState:     State(pData, DataType, LengthData);
            else         begin end;
          end;
          // Move position to next Head or Data
          fBuff.Position := fBuff.Position + LengthData;
        end
        else
          Error('Length of the data does not match the length of the message');
      end;
    end
    else
      break;
  end;
  // Copy the rest at the start of the buffer
  MaxPos := MaxPos - fBuff.Position;
  if (fBuff.Position > 0) AND (MaxPos > 0) then
  begin
    // Copy the rest of the stream at the start
    pCopyFrom := Pointer(NativeUInt(fBuff.Memory) + fBuff.Position);
    pCopyTo := fBuff.Memory;
    Move(pCopyFrom^, pCopyTo^, MaxPos);
  end;
  // Move position at the end
  fBuff.Position := MaxPos;
end;


// Merge recieved data into stream
procedure TExtAINetClient.RecieveData(aData: Pointer; aLength: Cardinal);
begin
  fBuff.Write(aData^, aLength);

  Status('New message');
end;


end.
