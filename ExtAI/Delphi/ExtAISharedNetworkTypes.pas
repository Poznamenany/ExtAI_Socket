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
    mkServerCfg =  0,
    mkGameCfg   =  1,
    mkExtAICfg  =  2,
    mkAction    =  3,
    mkEvent     =  4,
    mkState     =  5
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
    csVersion              =   1
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
    caAuthor               =   0,
    caName                 =   1,
    caDescription          =   2,
    caVersion              =   3
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
    teOnTick               =   1,
    teOnPlayerDefeated     =   2,
    teOnPlayerVictory      =   3
  );
  {$Z2} // Use 2 Bytes to store enumeration
  TExtAIMsgTypeState = (
    tsUnitAt               =   0,
    tsGetGroupCount        =   1,
    tsGetGroups            =   2,
    tsUnitIsAlive          =   3,
    tsGetUnitCount         =   4,
    tsGetUnits             =   5
  );

const
  MSG_KIND2TYPE_SIZE: array[TExtAIMsgKind] of Byte = (
    SizeOf(TExtAIMsgTypeCfgServer),
    SizeOf(TExtAIMsgTypeCfgGame),
    SizeOf(TExtAIMsgTypeCfgAI),
    SizeOf(TExtAIMsgTypeAction),
    SizeOf(TExtAIMsgTypeEvent),
    SizeOf(TExtAIMsgTypeState)
  );

implementation


end.

