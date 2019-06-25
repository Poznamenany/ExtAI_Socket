unit ExtAIEvents;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAINetClient, ExtAISharedNetworkTypes, ExtAISharedInterface;


// Events of the ExtAI
type
  // Event processing
  TExtAIEvents = class
  private
    fStream: TKMemoryStream;
    fClient: TExtAINetClient;
    // Game Events in variables
    fOnMissionStart    : TMissionStartEvent;
    fOnTick            : TTickEvent;
    fOnPlayerDefeated  : TPlayerDefeatedEvent;
    fOnPlayerVictory   : TPlayerVictoryEvent;
    // Methods
    procedure MissionStart();
    procedure Tick();
    procedure PlayerDefeated();
    procedure PlayerVictory();
    procedure NillEvents();
  public
    constructor Create();
    destructor Destroy(); override;

    property OnMissionStart    : TMissionStartEvent     write fOnMissionStart;
    property OnTick            : TTickEvent             write fOnTick;
    property OnPlayerDefeated  : TPlayerDefeatedEvent   write fOnPlayerDefeated;
    property OnPlayerVictory   : TPlayerVictoryEvent    write fOnPlayerVictory;

    procedure NewEvent(aData: Pointer; aEventType, aLength: Cardinal);
  end;


implementation
uses
  Log;


constructor TExtAIEvents.Create();
begin
  Inherited Create;
  fStream := TKMemoryStream.Create();
  fClient := nil;
  NillEvents();
end;


destructor TExtAIEvents.Destroy();
begin
  fStream.Free;
  fClient := nil;
  NillEvents();
  Inherited;
end;


procedure TExtAIEvents.NillEvents();
begin
  fOnMissionStart    := nil;
  fOnTick            := nil;
  fOnPlayerDefeated  := nil;
  fOnPlayerVictory   := nil;
end;


procedure TExtAIEvents.NewEvent(aData: Pointer; aEventType, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^,aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeEvent(aEventType) of
    teOnMissionStart     : MissionStart();
    teOnTick             : Tick();
    teOnPlayerDefeated   : PlayerDefeated();
    teOnPlayerVictory    : PlayerVictory();
    else gClientLog.Log('TExtAIEvents Unknown event type');
  end;
end;


procedure TExtAIEvents.MissionStart();
begin
  if Assigned(fOnMissionStart) then
    fOnMissionStart();
end;


procedure TExtAIEvents.Tick();
var
  Tick: Cardinal;
begin
  fStream.Read( Tick, SizeOf(Tick) );
  if Assigned(fOnTick) then
    fOnTick(Tick);
end;


procedure TExtAIEvents.PlayerDefeated();
var
  HandIndex: SmallInt;
begin
  fStream.Read( HandIndex, SizeOf(HandIndex) );
  if Assigned(fOnPlayerDefeated) then
    fOnPlayerDefeated(HandIndex);
end;


procedure TExtAIEvents.PlayerVictory();
var
  HandIndex: SmallInt;
begin
  fStream.Read( HandIndex, SizeOf(HandIndex) );
  if Assigned(fOnPlayerVictory) then
    fOnPlayerVictory(HandIndex);
end;


end.
