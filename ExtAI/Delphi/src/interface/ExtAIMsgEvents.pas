unit ExtAIMsgEvents;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAISharedInterface;


// Packing and unpacking of Events in the message
type
  TExtAIMsgEvents = class
  private
    // Main variables
    fStream: TKExtAIMsgStream;
    // Triggers
    fOnSendEvent       : TExtAIEventNewMsg;
    fOnMissionStart    : TMissionStartEvent;
    fOnTick            : TTickEvent;
    fOnPlayerDefeated  : TPlayerDefeatedEvent;
    fOnPlayerVictory   : TPlayerVictoryEvent;
    // Send Events
    procedure InitMsg(aTypeEvent: TExtAIMsgTypeEvent);
    procedure FinishMsg();
    procedure SendEvent();
    // Unpack Events
    procedure MissionStartR();
    procedure TickR();
    procedure PlayerDefeatedR();
    procedure PlayerVictoryR();
    // Others
    procedure NillEvents();
  public
    constructor Create();
    destructor Destroy(); override;

    // Connection to callbacks
    property OnSendEvent       : TExtAIEventNewMsg      write fOnSendEvent;
    property OnMissionStart    : TMissionStartEvent     write fOnMissionStart;
    property OnTick            : TTickEvent             write fOnTick;
    property OnPlayerDefeated  : TPlayerDefeatedEvent   write fOnPlayerDefeated;
    property OnPlayerVictory   : TPlayerVictoryEvent    write fOnPlayerVictory;

    // Pack events
    procedure MissionStartW();
    procedure TickW(aTick: Cardinal);
    procedure PlayerDefeatedW(aHandIndex: SmallInt);
    procedure PlayerVictoryW(aHandIndex: SmallInt);

    procedure ReceiveEvent(aData: Pointer; aEventType, aLength: Cardinal);
  end;


implementation


{ TExtAIMsgEvents }
constructor TExtAIMsgEvents.Create();
begin
  Inherited Create;
  fStream := TKExtAIMsgStream.Create();
  NillEvents();
end;


destructor TExtAIMsgEvents.Destroy();
begin
  fStream.Free;
  NillEvents();
  Inherited;
end;


procedure TExtAIMsgEvents.NillEvents();
begin
  fOnMissionStart    := nil;
  fOnTick            := nil;
  fOnPlayerDefeated  := nil;
  fOnPlayerVictory   := nil;
end;


procedure TExtAIMsgEvents.InitMsg(aTypeEvent: TExtAIMsgTypeEvent);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkEvent, Cardinal(aTypeEvent), TExtAIMsgLengthData(0));
end;


procedure TExtAIMsgEvents.FinishMsg();
var
  MsgLenght: TExtAIMsgLengthData;
begin
  // Replace 0 length with correct number
  MsgLenght := fStream.Size - SizeOf(TExtAIMsgKind) - SizeOf(TExtAIMsgTypeEvent) - SizeOf(TExtAIMsgLengthData);
  fStream.Position := SizeOf(TExtAIMsgKind) + SizeOf(TExtAIMsgTypeEvent);
  fStream.Write(MsgLenght, SizeOf(MsgLenght));
  // Send Event
  SendEvent();
end;


procedure TExtAIMsgEvents.SendEvent();
begin
  // Send message
  if Assigned(fOnSendEvent) then
    fOnSendEvent(fStream.Memory, fStream.Size);
end;


procedure TExtAIMsgEvents.ReceiveEvent(aData: Pointer; aEventType, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^,aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeEvent(aEventType) of
    teOnMissionStart     : MissionStartR();
    teOnTick             : TickR();
    teOnPlayerDefeated   : PlayerDefeatedR();
    teOnPlayerVictory    : PlayerVictoryR();
    else begin end;
  end;
end;


// Events


procedure TExtAIMsgEvents.MissionStartW();
begin
  InitMsg(teOnMissionStart);
  FinishMsg();
end;
procedure TExtAIMsgEvents.MissionStartR();
begin
  if Assigned(fOnMissionStart) then
    fOnMissionStart();
end;


procedure TExtAIMsgEvents.TickW(aTick: Cardinal);
begin
  InitMsg(teOnTick);
  fStream.Write(aTick);
  FinishMsg();
end;
procedure TExtAIMsgEvents.TickR();
var
  Tick: Cardinal;
begin
  fStream.Read( Tick, SizeOf(Tick) );
  if Assigned(fOnTick) then
    fOnTick(Tick);
end;


procedure TExtAIMsgEvents.PlayerDefeatedW(aHandIndex: SmallInt);
begin
  InitMsg(teOnPlayerDefeated);
  fStream.Write(aHandIndex);
  FinishMsg();
end;
procedure TExtAIMsgEvents.PlayerDefeatedR();
var
  HandIndex: SmallInt;
begin
  fStream.Read( HandIndex, SizeOf(HandIndex) );
  if Assigned(fOnPlayerDefeated) then
    fOnPlayerDefeated(HandIndex);
end;


procedure TExtAIMsgEvents.PlayerVictoryW(aHandIndex: SmallInt);
begin
  InitMsg(teOnPlayerVictory);
  fStream.Write(aHandIndex);
  FinishMsg();
end;
procedure TExtAIMsgEvents.PlayerVictoryR();
var
  HandIndex: SmallInt;
begin
  fStream.Read( HandIndex, SizeOf(HandIndex) );
  if Assigned(fOnPlayerVictory) then
    fOnPlayerVictory(HandIndex);
end;






end.
