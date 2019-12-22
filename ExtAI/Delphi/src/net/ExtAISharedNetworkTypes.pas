unit ExtAISharedNetworkTypes;
interface
uses
  Math;


// Here are all shared network types with creators of the new ExtAI

// Structure of the data stream
//  ____________Head of the Message_____________ _Message_
// | Recipient | Sender | Length of the Message |   ...   |
//  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯
// Message may contain multiple data sets, size of Type may differ based on Kind
//  ____________________Message____________________
// | Kind | Type | Length of the Data | Data | ... |
//  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

type
// General types
  TExtAINetHandleIndex = SmallInt; // Index of client
// Data types of main parts
  TExtAIMsgRecipient   = ShortInt;
  TExtAIMsgSender      = ShortInt;
  TExtAIMsgLengthMsg   = Cardinal;
  TExtAIMsgLengthData  = Cardinal;
  {$Z1} // Use 1 Byte to store enumeration
  TExtAIMsgKind = (
    mkServerCfg   =  0,
    mkGameCfg     =  1,
    mkExtAICfg    =  2,
    mkPerformance =  3,
    mkAction      =  4,
    mkEvent       =  5,
    mkState       =  6
  );

const
  ExtAI_MSG_MAX_SIZE        = 255*255*255; // Maximum length of message
  ExtAI_MSG_ADDRESS_SERVER  = -1;
  ExtAI_MSG_HEAD_SIZE       = SizeOf(TExtAIMsgRecipient) + SizeOf(TExtAIMsgSender) + SizeOf(TExtAIMsgLengthMsg);

type
  // Configurations
  {$Z1} // Use 1 Byte to store enumeration
  TExtAIMsgTypeCfgServer = (
    csName                 =   0,
    csVersion              =   1,
    csClientHandle         =   2,
    csExtAIID              =   3
  );
  {$Z1} // Use 1 Byte to store enumeration
  TExtAIMsgTypeCfgGame = (
    cgLoc                  =   0,
    cgMap                  =   1,
    cgGameSpeed            =   2,
    cgFoWActive            =   3
  );
  {$Z1} // Use 1 Byte to store enumeration
  TExtAIMsgTypeCfgAI = (
    caID                   =   0,
    caAuthor               =   1,
    caName                 =   2,
    caDescription          =   3,
    caVersion              =   4
  );
  {$Z1} // Use 1 Byte to store enumeration
  TExtAIMsgTypePerformance = (
    prPing                 =   0, // Ping request from server
    prPong                 =   1, // Pong response of client to Ping request
    prTick                 =   2  // Duration of Tick
  );
  // Actions, Events, States
  {$Z2} // Use 2 Bytes to store enumeration
  TExtAIMsgTypeAction = (
    taGroupOrderAttackUnit =   0,
    taGroupOrderWalk       =   1,
    taLog                  =   2
  );
  {$Z2} // Use 2 Bytes to store enumeration
  TExtAIMsgTypeEvent = (
    teOnMissionStart       =   0,
    teOnMissionEnd         =   1,
    teOnTick               =   2,
    teOnPlayerDefeated     =   3,
    teOnPlayerVictory      =   4
  );
  {$Z2} // Use 2 Bytes to store enumeration
  TExtAIMsgTypeState = (
    tsTerrainSize          =   0,
    tsTerrainPassability   =   1,
    tsTerrainFertility     =   2,
    tsPlayerGroups         =   3,
    tsPlayerUnits          =   4
  );


const
  MSG_KIND2TYPE_SIZE: array[TExtAIMsgKind] of Byte = (
    SizeOf(TExtAIMsgTypeCfgServer),
    SizeOf(TExtAIMsgTypeCfgGame),
    SizeOf(TExtAIMsgTypeCfgAI),
    SizeOf(TExtAIMsgTypePerformance),
    SizeOf(TExtAIMsgTypeAction),
    SizeOf(TExtAIMsgTypeEvent),
    SizeOf(TExtAIMsgTypeState)
  );

type
  TExtAIEventNewMsg = procedure (aData: Pointer; aLength: Cardinal) of object;

  pExtAINewData = ^TExtAINewData;
  TExtAINewData = record
    Ptr: Pointer;
    Length: Cardinal;
    Next: pExtAINewData;
  end;

implementation


end.

