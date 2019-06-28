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
    fOnSendAction: TExtAINewMsgEvent;
    fOnGroupOrderAttackUnit: TGroupOrderAttackUnit;
    fOnGroupOrderWalk: TGroupOrderWalk;
    fOnLog: TLog;
    // Send Actions
    procedure InitMsg(aActType: TExtAIMsgTypeAction);
    procedure FinishMsg();
    procedure SendAction();
    // Unpack Actions
    procedure GroupOrderAttackUnit(); overload;
    procedure GroupOrderWalk(); overload;
    procedure Log(); overload;
    // Others
    procedure NillEvents();
  public
    constructor Create();
    destructor Destroy(); override;

    // Connection to callbacks
    property OnSendAction: TExtAINewMsgEvent write fOnSendAction;
    property OnGroupOrderAttackUnit: TGroupOrderAttackUnit write fOnGroupOrderAttackUnit;
    property OnGroupOrderWalk: TGroupOrderWalk write fOnGroupOrderWalk;
    property OnLog: TLog write fOnLog;

    // Pack actions
    procedure GroupOrderAttackUnit(aGroupID, aUnitID: Integer); overload;
    procedure GroupOrderWalk(aGroupID, aX, aY, aDir: Integer); overload;
    procedure Log(aLog: UnicodeString); overload;

    procedure ReceiveAction(aData: Pointer; aTypeAction, aLength: Cardinal);
  end;


implementation
uses
  Log;


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


procedure TExtAIMsgActions.InitMsg(aActType: TExtAIMsgTypeAction);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkAction, Cardinal(aActType), TExtAIMsgLengthData(0));
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


procedure TExtAIMsgActions.ReceiveAction(aData: Pointer; aTypeAction, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^, aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeAction(aTypeAction) of
    taGroupOrderAttackUnit: GroupOrderAttackUnit();
    taGroupOrderWalk:       GroupOrderWalk();
    taLog:                  Log();
    else                    begin end;
  end;
end;


// Actions


procedure TExtAIMsgActions.GroupOrderAttackUnit(aGroupID, aUnitID: Integer);
begin
  InitMsg(taGroupOrderAttackUnit);
  fStream.Write(aGroupID);
  fStream.Write(aUnitID);
  FinishMsg();
end;
procedure TExtAIMsgActions.GroupOrderAttackUnit();
var
  GroupID, UnitID: Integer;
begin
  fStream.Read(GroupID);
  fStream.Read(UnitID);
  if Assigned(fOnGroupOrderAttackUnit) then
    fOnGroupOrderAttackUnit(GroupID, UnitID);
end;


procedure TExtAIMsgActions.GroupOrderWalk(aGroupID, aX, aY, aDir: Integer);
begin
  InitMsg(taGroupOrderWalk);
  fStream.Write(aGroupID);
  fStream.Write(aX);
  fStream.Write(aY);
  fStream.Write(aDir);
  FinishMsg();
end;
procedure TExtAIMsgActions.GroupOrderWalk();
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


procedure TExtAIMsgActions.Log(aLog: UnicodeString);
begin
  InitMsg(taLog);
  fStream.WriteW(aLog);
  FinishMsg();
end;
procedure TExtAIMsgActions.Log();
var
  Txt: UnicodeString;
begin
  fStream.ReadW(Txt);
  if Assigned(fOnLog) then
    fOnLog(Txt);
end;


end.
