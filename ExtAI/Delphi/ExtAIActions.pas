unit ExtAIActions;
interface
uses
  Classes, SysUtils,
  ExtAIMsgActions, ExtAINetClient, ExtAISharedInterface;


// Actions of the ExtAI
type
  TExtAIActions = class
  private
    fActions: TExtAIMsgActions;
    fClient: TExtAINetClient;
    // Triggers
    fOnGroupOrderAttackUnit: TGroupOrderAttackUnit;
    fOnGroupOrderWalk: TGroupOrderWalk;
    fOnLog: TLog;
    // Send action via client
    procedure SendAction(aData: Pointer; aLength: Cardinal);
  public
    constructor Create(aClient: TExtAINetClient);
    destructor Destroy(); override;

    // Actions
    property Msg: TExtAIMsgActions read fActions;
    property GroupOrderAttackUnit: TGroupOrderAttackUnit read fOnGroupOrderAttackUnit;
    property GroupOrderWalk: TGroupOrderWalk read fOnGroupOrderWalk;
    property Log: TLog read fOnLog;
  end;


implementation
uses
  Log;


{ TExtAIActions }
constructor TExtAIActions.Create(aClient: TExtAINetClient);
begin
  Inherited Create;
  fClient := aClient;
  fActions := TExtAIMsgActions.Create();
  // Connect callbacks
  fActions.OnSendAction := SendAction;
  // Connect properties
  fOnGroupOrderAttackUnit := fActions.GroupOrderAttackUnit;
  fOnGroupOrderWalk       := fActions.GroupOrderWalk;
  fOnLog                  := fActions.Log;
end;


destructor TExtAIActions.Destroy();
begin
  fOnGroupOrderAttackUnit := nil;
  fOnGroupOrderWalk       := nil;
  fOnLog                  := nil;
  fActions.Free;
  Inherited;
end;


procedure TExtAIActions.SendAction(aData: Pointer; aLength: Cardinal);
begin
  Assert(fClient <> nil, 'Action cannot be send because client = nil');
  fClient.SendMessage(aData, aLength);
end;


end.
