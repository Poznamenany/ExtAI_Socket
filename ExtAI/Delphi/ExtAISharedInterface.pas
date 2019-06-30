unit ExtAISharedInterface;
interface
//uses
//  Classes, SysUtils;


// States of the ExtAI
type
  // Definition of actions
    TGroupOrderAttackUnit = procedure(aGroupID, aUnitID: Integer) of object;
    TGroupOrderWalk       = procedure(aGroupID, aX, aY, aDir: Integer) of object;
    TLog                  = procedure(aLog: string) of object;
  // Definition of states between ExtAI Client and KP Server
    TTerrainSize          = procedure(aX, aY: Word);
    TTerrainPassability   = procedure(aPassability: array of Boolean);
    TTerrainFertility     = procedure(aFertility: array of Boolean);
    TPlayerGroups         = procedure(aHandIndex: SmallInt; aGroups: array of Integer);
    TPlayerUnits          = procedure(aHandIndex: SmallInt; aUnits: array of Integer);
  // Definition of events
    TMissionStartEvent    = procedure() of object;
    TTickEvent            = procedure(aTick: Cardinal) of object;
    TPlayerDefeatedEvent  = procedure(aHandIndex: SmallInt) of object;
    TPlayerVictoryEvent   = procedure(aHandIndex: SmallInt) of object;

implementation


end.
