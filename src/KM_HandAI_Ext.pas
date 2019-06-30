unit KM_HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  KM_Consts, KM_Terrain,
  ExtAINetServer, ExtAIMsgActions, ExtAIMsgEvents, ExtAIMsgStates;

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
    // Client
    fServerClient: TExtAIServerClient;
    procedure Log(aLog: UnicodeString);
  public
    constructor Create(aHandIndex: TKMHandIndex);
    destructor Destroy(); override;

    // Actions, Events, States
    property Actions: TExtAIMsgActions read fActions;
    property Events: TExtAIMsgEvents read fEvents;
    property States: TExtAIMsgStates read fStates;

    procedure UpdateState(aTick: Cardinal);
    procedure ConnectCallbacks(aServerClient: TExtAIServerClient);
  end;


implementation
uses
  ExtAILog;


{ TKMHandAI }
constructor TKMHandAI.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;
end;


{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create(aHandIndex);

  fActions := TExtAIMsgActions.Create();
  fEvents := TExtAIMsgEvents.Create();
  fStates := TExtAIMsgStates.Create();

  fServerClient := nil;
  fActions.OnLog := Log;

  gLog.Log('THandAIExt-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THandAI_Ext.Destroy();
begin
  fActions.Free;
  fEvents.Free;
  fStates.Free;
  if (fServerClient <> nil) then
  begin
    fServerClient.OnAction := nil;
    fServerClient.OnState := nil;
  end;
  fServerClient := nil;
  gLog.Log('THandAIExt-Destroy: HandIndex = ' + IntToStr(fHandIndex));
  inherited;
end;


procedure THandAI_Ext.UpdateState(aTick: Cardinal);
begin
  if (aTick = FIRST_TICK) then
  begin
    Events.MissionStartW();
    States.TerrainSizeW(gTerrain.MapX, gTerrain.MapY);
    //States.TerrainPassabilityW(gTerrain.Passability);
    //States.TerrainFertilityW(gTerrain.Fertility);
  end;

  Events.TickW(aTick);
end;


procedure THandAI_Ext.ConnectCallbacks(aServerClient: TExtAIServerClient);
begin
  fServerClient := aServerClient;
  fServerClient.OnAction := fActions.ReceiveAction;
  fServerClient.OnState := fStates.ReceiveState;
  fStates.OnSendState := fServerClient.AddScheduledMsg;
  fEvents.OnSendEvent := fServerClient.AddScheduledMsg;
end;


// Temporary location for logs from actions
procedure THandAI_Ext.Log(aLog: UnicodeString);
begin
  gLog.Log(aLog);
end;


end.
