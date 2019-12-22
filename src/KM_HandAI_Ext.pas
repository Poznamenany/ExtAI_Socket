unit KM_HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  KM_Consts, KM_Terrain,
  ExtAIInfo, ExtAINetServer, ExtAIMsgActions, ExtAIMsgEvents, ExtAIMsgStates;

type
  // Main AI class in the hands
  TKMHandAI = class
  protected
    fHandIndex: TKMHandIndex;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    property HandIndex: TKMHandIndex read fHandIndex;
  end;

  // Special class for ExtAI in the hands
  THandAI_Ext = class(TKMHandAI)
  private
    // Actions, Events, States
    fActions: TExtAIMsgActions;
    fEvents: TExtAIMsgEvents;
    fStates: TExtAIMsgStates;
    // ExtAI info, IDs, client server etc.
    fExtAI: TExtAIInfo;
    // Process actions
    procedure GroupOrderAttackUnit(aGroupID, aUnitID: Integer);
    procedure GroupOrderWalk(aGroupID, aX, aY, aDir: Integer);
    procedure Log(aLog: UnicodeString);
    // Process requests for states

    {

    TGroupOrderAttackUnit = procedure(aGroupID, aUnitID: Integer)                          of object;
    TGroupOrderWalk       = procedure(aGroupID, aX, aY, aDir: Integer)                     of object;
    TLog                  = procedure(aLog: string)                                        of object;
  // Definition of states between ExtAI Client and KP Server
    TTerrainSize          = procedure(aX, aY: Word)                                        of object;
    TTerrainPassability   = procedure(aPassability: TBoolArr)                              of object;
    TTerrainFertility     = procedure(aFertility: TBoolArr)                                of object;
    }
  public
    constructor Create(aHandIndex: TKMHandIndex; aExtAI: TExtAIInfo);
    destructor Destroy(); override;

    // Actions, Events, States
    property Actions: TExtAIMsgActions read fActions;
    property Events: TExtAIMsgEvents read fEvents;
    property States: TExtAIMsgStates read fStates;

    procedure ConnectCallbacks(aExtAI: TExtAIInfo = nil);
    procedure DisconnectCallbacks();

    procedure MissionStart();
    procedure MissionEnd();
    procedure UpdateState(aTick: Cardinal);
  end;


implementation
uses
  ExtAILog;


{ TKMHandAI }
constructor TKMHandAI.Create(aHandIndex: TKMHandIndex);
begin
  Inherited Create;

  fHandIndex := aHandIndex;
end;


{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex; aExtAI: TExtAIInfo);
begin
  Inherited Create(aHandIndex);
  // Declare main classes of Actions, Events and States
  fActions := TExtAIMsgActions.Create();
  fEvents := TExtAIMsgEvents.Create();
  fStates := TExtAIMsgStates.Create();
  // Prepare callbacks for actions
  fActions.OnGroupOrderAttackUnit := GroupOrderAttackUnit;
  fActions.OnGroupOrderWalk := GroupOrderWalk;
  fActions.OnLog := Log;
  // Connect callbacks
  ConnectCallbacks(aExtAI);

  gLog.Log('THandAIExt-Create: HandIndex = %d', [fHandIndex]);
end;


destructor THandAI_Ext.Destroy();
begin
  DisconnectCallbacks();
  fActions.Free;
  fEvents.Free;
  fStates.Free;
  gLog.Log('THandAIExt-Destroy: HandIndex = %d', [fHandIndex]);
  Inherited;
end;


procedure THandAI_Ext.ConnectCallbacks(aExtAI: TExtAIInfo = nil);
begin
  if (aExtAI <> nil) then
  begin
    fExtAI := aExtAI;
    fExtAI.HandIdx := fHandIndex;
  end;
  if (fExtAI <> nil) AND (fExtAI.ServerClient <> nil) then
  begin
    fExtAI.ServerClient.OnAction := fActions.ReceiveAction;
    fExtAI.ServerClient.OnState := fStates.ReceiveState;
    fStates.OnSendState := fExtAI.ServerClient.AddScheduledMsg;
    fEvents.OnSendEvent := fExtAI.ServerClient.AddScheduledMsg;
  end;
end;


procedure THandAI_Ext.DisconnectCallbacks();
begin
  if (fExtAI <> nil) AND (fExtAI.ServerClient <> nil) then
  begin
    fExtAI.ServerClient.OnAction := nil;
    fExtAI.ServerClient.OnState := nil;
    fStates.OnSendState := nil;
    fEvents.OnSendEvent := nil;
  end;
end;


// Process actions (Check if the parameters are correct and create new GIP command)

procedure THandAI_Ext.GroupOrderAttackUnit(aGroupID, aUnitID: Integer);
begin
  // Check if the parameters are correct
  // Process the action
  gLog.Log('THandAIExt-GroupOrderAttackUnit');
end;



procedure THandAI_Ext.GroupOrderWalk(aGroupID, aX, aY, aDir: Integer);
begin
  // Check if the parameters are correct
  // Process the action
  gLog.Log('THandAIExt-GroupOrderWalk');
end;


procedure THandAI_Ext.Log(aLog: UnicodeString);
begin
  gLog.Log(aLog);
end;



// Process events (or call directly for example HandAI_ext.Events.TickW(...))


procedure THandAI_Ext.MissionStart();
begin
  Events.MissionStartW();
end;


procedure THandAI_Ext.MissionEnd();
begin
  Events.MissionEndW();
end;


procedure THandAI_Ext.UpdateState(aTick: Cardinal);
begin
  if (fExtAI = nil) OR (fExtAI.ServerClient = nil) then
  begin
    DisconnectCallbacks();
    Exit;
  end;

  if (aTick = FIRST_TICK) then
    States.TerrainSizeW(gTerrain.MapX, gTerrain.MapY); // Send terrain in the first tick (just for testing)

  Events.TickW(aTick);
end;


// Process states (or call directly for example HandAI_ext.States.TerrainSizeW(...))

end.
