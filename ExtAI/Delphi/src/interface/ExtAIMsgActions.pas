unit ExtAIMsgActions;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAISharedInterface;


// Packing and unpacking of Actions in the message
type
  TExtAIMsgActions = class
  private
    // Main variables
    fStream: TKExtAIMsgStream;
    // Triggers
    fOnSendAction            : TExtAIEventNewMsg;
    fOnGroupOrderAttackUnit  : TGroupOrderAttackUnit;
    fOnGroupOrderWalk        : TGroupOrderWalk;
    fOnLog                   : TLog;
    // Send Actions
    procedure InitMsg(aTypeAction: TExtAIMsgTypeAction);
    procedure FinishMsg();
    procedure SendAction();
    // Unpack Actions
    procedure GroupOrderAttackUnitR();
    procedure GroupOrderWalkR();
    procedure LogR();
    // Others
    procedure NillEvents();
  public
    constructor Create();
    destructor Destroy(); override;

    // Connection to callbacks
    property OnSendAction           : TExtAIEventNewMsg     write fOnSendAction;
    property OnGroupOrderAttackUnit : TGroupOrderAttackUnit write fOnGroupOrderAttackUnit;
    property OnGroupOrderWalk       : TGroupOrderWalk       write fOnGroupOrderWalk;
    property OnLog                  : TLog                  write fOnLog;

    // Pack actions
    procedure GroupOrderAttackUnitW(aGroupID, aUnitID: Integer);
    procedure GroupOrderWalkW(aGroupID, aX, aY, aDir: Integer);
    procedure LogW(aLog: UnicodeString);

    procedure ReceiveAction(aData: Pointer; aActionType, aLength: Cardinal);
  end;


implementation
uses
  ExtAILog;


{ TExtAIMsgActions }
constructor TExtAIMsgActions.Create();
begin
  Inherited Create;
  fStream := TKExtAIMsgStream.Create();
  fStream.Clear;
  NillEvents();
end;


destructor TExtAIMsgActions.Destroy();
begin
  NillEvents();
  fStream.Free;
  Inherited;
end;


procedure TExtAIMsgActions.NillEvents();
begin
  fOnGroupOrderAttackUnit := nil;
  fOnGroupOrderWalk       := nil;
  fOnLog                  := nil;
end;


procedure TExtAIMsgActions.InitMsg(aTypeAction: TExtAIMsgTypeAction);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkAction, Cardinal(aTypeAction), TExtAIMsgLengthData(0));
end;


procedure TExtAIMsgActions.FinishMsg();
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


procedure TExtAIMsgActions.SendAction();
begin
  // Send message
  if Assigned(fOnSendAction) then
    fOnSendAction(fStream.Memory, fStream.Size);
end;


procedure TExtAIMsgActions.ReceiveAction(aData: Pointer; aActionType, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^, aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeAction(aActionType) of
    taGroupOrderAttackUnit: GroupOrderAttackUnitR();
    taGroupOrderWalk:       GroupOrderWalkR();
    taLog:                  LogR();
    else                    begin end;
  end;
end;


// Actions


procedure TExtAIMsgActions.GroupOrderAttackUnitW(aGroupID, aUnitID: Integer);
begin
  InitMsg(taGroupOrderAttackUnit);
  fStream.Write(aGroupID);
  fStream.Write(aUnitID);
  FinishMsg();
end;
procedure TExtAIMsgActions.GroupOrderAttackUnitR();
var
  GroupID, UnitID: Integer;
begin
  fStream.Read(GroupID);
  fStream.Read(UnitID);
  if Assigned(fOnGroupOrderAttackUnit) then
    fOnGroupOrderAttackUnit(GroupID, UnitID);
end;


procedure TExtAIMsgActions.GroupOrderWalkW(aGroupID, aX, aY, aDir: Integer);
begin
  InitMsg(taGroupOrderWalk);
  fStream.Write(aGroupID);
  fStream.Write(aX);
  fStream.Write(aY);
  fStream.Write(aDir);
  FinishMsg();
end;
procedure TExtAIMsgActions.GroupOrderWalkR();
var
  GroupID, X, Y, Dir: Integer;
begin
  fStream.Read(GroupID);
  fStream.Read(X);
  fStream.Read(Y);
  fStream.Read(Dir);
  if Assigned(fOnGroupOrderWalk) then
    fOnGroupOrderWalk(GroupID, X, Y, Dir);
end;


procedure TExtAIMsgActions.LogW(aLog: UnicodeString);
begin
  InitMsg(taLog);
  fStream.WriteW(aLog);
  FinishMsg();
end;
procedure TExtAIMsgActions.LogR();
var
  Txt: UnicodeString;
begin
  fStream.ReadW(Txt);
  if Assigned(fOnLog) then
    fOnLog(Txt);
end;


end.
