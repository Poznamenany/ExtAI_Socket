unit ExtAISharedInterface;
interface
//uses
//  Classes, SysUtils;


// States of the ExtAI
type
  // Predefined data types
    TBoolArr = array of Boolean;
  // Definition of actions
    TGroupOrderAttackUnit = procedure(aGroupID, aUnitID: Integer)                          of object;
    TGroupOrderWalk       = procedure(aGroupID, aX, aY, aDir: Integer)                     of object;
    TLog                  = procedure(aLog: string)                                        of object;
  // Definition of states between ExtAI Client and KP Server
    TTerrainSize          = procedure(aX, aY: Word)                                        of object;
    TTerrainPassability   = procedure(aPassability: TBoolArr)                              of object;
    TTerrainFertility     = procedure(aFertility: TBoolArr)                                of object;
    TPlayerGroups         = procedure(aHandIndex: SmallInt; aGroups: array of Integer)     of object;
    TPlayerUnits          = procedure(aHandIndex: SmallInt; aUnits: array of Integer)      of object;
  // Definition of events
    TMissionStartEvent    = procedure()                                                    of object;
    TMissionEndEvent      = procedure()                                                    of object;
    TTickEvent            = procedure(aTick: Cardinal)                                     of object;
    TPlayerDefeatedEvent  = procedure(aHandIndex: SmallInt)                                of object;
    TPlayerVictoryEvent   = procedure(aHandIndex: SmallInt)                                of object;

  // DLL interface
  TDLLpConfig = record
    Author, Description, ExtAIName: PWideChar;
    AuthorLen, DescriptionLen, ExtAINameLen, Version: Cardinal;
  end;
  
implementation


{
Actions
  Group
    GroupOrderAttackHouse
    GroupOrderAttackUnit
    GroupOrderFood
    GroupOrderHalt
    GroupOrderLink
    GroupOrderSplit
    GroupOrderStorm
    GroupOrderWalk
    GroupSetFormation
  House
    HouseAllow
    HouseDestroy
    HouseRepairEnable
    HouseTrainQueueAdd
    HouseTrainQueueRemove
    HouseWareInBlock
    HouseWeaponsOrderSet
    HouseWoodcutterChopOnly
  Plan
    PlanAddHouse
    PlanAddRoad
    PlanAddField
    PlanAddOrchard
    PlanRemove
  Message
    PlayerMessage
    PlayerMessageFormatted
    PlayerMessageGoto
    PlayerMessageGotoFormatted
  City Setting
    PlayerWareDistribution
  Unit
    UnitOrderWalk
  Debug
    Log(Text)
    Disp(Text, Duration)
    Quad(X, Y, Color, ID, Duration);
    LineOnTerrain(X1,Y1, X2,Y2, Width, Color, ID, Duration)
    Line(X1,Y1, X2,Y2, width, Color, ID, Duration)
    Triangle(X1,Y1, X2,Y2, X3,Y3, Color, ID, Duration)

Events
  House
    OnHouseBuilt
    OnHouseDamaged
    OnHouseDestroyed
    OnHousePlanPlaced
  Game
    OnMissionStart
    OnPlayerDefeated
    OnPlayerVictory
    OnTick
  Unit
    OnUnitDied
    OnUnitTrained
    OnUnitWoundedByHouse
    OnUnitWoundedByUnit
    OnWarriorEquipped


States
  Game
    GameTime
    PeaceTime
  Group
    GroupAt
    GroupColumnCount
    GroupDead
    GroupIsIdle
    GroupMember
    GroupMemberCount
    GroupOwner
  House
    HouseAt
    HouseDamage
    HouseDeliveryBlocked
    HouseDestroyed
    HouseHasOccupant
    HouseHasWorker
    HouseIsComplete
    HouseOwner
    HousePositionX
    HousePositionY
    HouseRepair
    HouseTrainQueuePeek
    HouseType
    HouseWareBlock
    HouseWareInside
    HouseWeaponsOrdered
    HouseWoodcutterChopOnly
  Fields
    IsFieldAt
    IsOrchardAt
    IsRoadAt
  Player
    PlayerAllianceCheck
    PlayerDefeated
    PlayerEnabled
    PlayerGetAllGroups
    PlayerGetAllHouses
    PlayerGetAllUnits
    PlayerHouseCanBuild
    PlayerName
    PlayerVictorious
    PlayerWareDistribution
  Stat
    StatArmyCount
    StatCitizenCount
    StatHouseTypeCount
    StatPlayerCount
    StatUnitCount
    StatUnitKilledCount
    StatUnitLostCount
    StatUnitTypeCount
    StatWaresBalance
    StatWaresProduced
  Unit
    UnitAt
    UnitCarryCount
    UnitCarryType
    UnitDead
    UnitDirection
    UnitGroup
    UnitHunger
    UnitHungerLow
    UnitHungerMax
    UnitOwner
    UnitPositionX
    UnitPositionY
    UnitType

}

end.
