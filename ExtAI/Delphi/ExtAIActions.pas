unit ExtAIActions;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAINetClient, ExtAISharedNetworkTypes;


// Actions of the ExtAI
type
  TExtAIActions = class
  private
    fStream: TKExtAIMsgStream;
    fClient: TExtAINetClient;
    procedure InitMsg(aActType: TExtAIMsgTypeAction);
    procedure FinishMsg();
    procedure SendAction();
  public
    constructor Create(aClient: TExtAINetClient);
    destructor Destroy(); override;

    property Client: TExtAINetClient write fClient;

    procedure GroupOrderAttackUnit(aGroupID: Integer; aUnitID: Integer);
    procedure GroupOrderWalk(aGroupID: Integer; aX: Integer; aY: Integer; aDir: Integer);
    procedure Log(aLog: UnicodeString);
  end;


implementation
uses
  Log;


constructor TExtAIActions.Create(aClient: TExtAINetClient);
begin
  Inherited Create;
  fStream := TKExtAIMsgStream.Create();
  fStream.Clear;
  fClient := aClient;
end;


destructor TExtAIActions.Destroy();
begin
  fStream.Free;
  fClient := nil;
  Inherited;
end;


procedure TExtAIActions.InitMsg(aActType: TExtAIMsgTypeAction);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkAction, Cardinal(aActType), TExtAIMsgLengthData(0));
end;


procedure TExtAIActions.FinishMsg();
var
  MsgLenght: TExtAIMsgLengthData;
begin
  // Replace 0 length with correct number
  MsgLenght := fStream.Size - SizeOf(TExtAIMsgKind) - SizeOf(TExtAIMsgTypeAction) - SizeOf(TExtAIMsgLengthData);
  fStream.Position := SizeOf(TExtAIMsgKind) + SizeOf(TExtAIMsgTypeAction);
  fStream.Write(MsgLenght, SizeOf(MsgLenght));
  // Send Action
  SendAction();
end;


procedure TExtAIActions.SendAction();
begin
  Assert(fClient <> nil, 'Action cannot be send because client = nil');
  // Send message
  fClient.SendMessage(fStream.Memory, fStream.Size);
end;


procedure TExtAIActions.GroupOrderAttackUnit(aGroupID: Integer; aUnitID: Integer);
begin
  InitMsg(taGroupOrderAttackUnit);
  fStream.Write(aGroupID);
  fStream.Write(aUnitID);
  FinishMsg();
end;


procedure TExtAIActions.GroupOrderWalk(aGroupID: Integer; aX: Integer; aY: Integer; aDir: Integer);
begin
  InitMsg(taGroupOrderWalk);
  fStream.Write(aGroupID);
  fStream.Write(aX);
  fStream.Write(aY);
  fStream.Write(aDir);
  FinishMsg();
end;


procedure TExtAIActions.Log(aLog: UnicodeString);
begin
  InitMsg(taLog);
  fStream.WriteW(aLog);
  FinishMsg();
end;




end.
