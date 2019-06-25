unit ExtAISharedInterface;
interface
//uses
//  Classes, SysUtils;


// States of the ExtAI
type
  // Definition of actions
    TGroupOrderAttackUnit = procedure(aGroupID: Integer; aUnitID: Integer);
    TGroupOrderWalk       = procedure(aGroupID: Integer; aX: Integer; aY: Integer; aDir: Integer);
    TLog                  = procedure(aLog: string);
  // Definition of states
     {
     TUnitAt = function (aX: Integer; aY: Integer): Integer;
     TMapTerrain = function(aID: ui8; var aFirstElem: pui32; var aLength: Integer): b;
     TTerrainSize = procedure(var aX: ui16; var aY: ui16);
     TTerrainPassability = procedure(var aPassability: pb);

     TGetGroupCount = function(aHandIndex: ui8): ui32;
     TGetGroups = procedure(aHandIndex: ui8; aFirst: PGroupInfo; aCount: ui32);
     TUnitIsAlive = function(aUnitUID: ui32): b;
     TGetUnitCount = function(aHandIndex: ui8): ui32;
     TGetUnits = procedure(aHandIndex: ui8; aFirst: PUnitInfo; aCount: ui32);
     }
  // Definition of events
    TMissionStartEvent    = procedure() of object;
    TTickEvent            = procedure(aTick: Cardinal) of object;
    TPlayerDefeatedEvent  = procedure(aHandIndex: SmallInt) of object;
    TPlayerVictoryEvent   = procedure(aHandIndex: SmallInt) of object;

implementation


end.
