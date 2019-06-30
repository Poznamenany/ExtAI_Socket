unit ExtAIStates;
interface
uses
  Classes, SysUtils,
  ExtAIMsgStates, ExtAINetClient, ExtAISharedInterface;


// States of the ExtAI
type
  TExtAIStates = class
  private
    fStates: TExtAIMsgStates;
    fClient: TExtAINetClient;
    // Game variables
    //fTerrain: TExtAITerrain;
    //fHands: TExtAIHands;
    // Triggers
    //fOnGroupOrderAttackUnit: TGroupOrderAttackUnit;
    // Send state via client
    procedure SendState(aData: Pointer; aLength: Cardinal);
  public
    constructor Create(aClient: TExtAINetClient);
    destructor Destroy(); override;

    // Connect Msg directly with creator of ExtAI so he can type Actions.XY instead of Actions.Msg.XY
    property Msg: TExtAIMsgStates read fStates;

    // States from perspective of the ExtAI
    {
    function MapHeight(): Word;
    function MapWidth(): Word;
    TTerrainSize          = procedure(aX, aY: Word);
    TTerrainPassability   = procedure(aPassability: array of Boolean);
    TTerrainFertility     = procedure(aFertility: array of Boolean);
    TPlayerGroups         = procedure(aHandIndex: SmallInt; aGroups: array of Integer);
    TPlayerUnits          = procedure(aHandIndex: SmallInt; aUnits: array of Integer);
    }
    //property GroupOrderAttackUnit: TGroupOrderAttackUnit read fOnGroupOrderAttackUnit;
  end;


implementation
uses
  Log;


{ TExtAIStates }
constructor TExtAIStates.Create(aClient: TExtAINetClient);
begin
  Inherited Create;
  fClient := aClient;
  fStates := TExtAIMsgStates.Create();
  // Connect callbacks
  fStates.OnSendState := SendState;
  // Connect properties
  //fOnGroupOrderAttackUnit := fActions.GroupOrderAttackUnitW;
end;


destructor TExtAIStates.Destroy();
begin
  //fOnGroupOrderAttackUnit := nil;
  fStates.Free;
  fClient := nil;
  Inherited;
end;


procedure TExtAIStates.SendState(aData: Pointer; aLength: Cardinal);
begin
  Assert(fClient <> nil, 'State cannot be send because client = nil');
  fClient.SendMessage(aData, aLength);
end;


end.
