unit ExtAIMsgEvents;
interface
uses
  Classes, Windows, System.SysUtils,
  Consts, ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAINetServer;

type
  TExtAIMsgEvents = class
  private
    fStream: TKExtAIMsgStream;
    fNewMsgEvent: TNewMsgEvent;
    procedure InitMsg(aEventType: TExtAIMsgTypeEvent);
    procedure FinishMsg();
    procedure SendEvent();
  public
    constructor Create();
    destructor Destroy; override;
    // New message event
    property OnNewMsg: TNewMsgEvent write fNewMsgEvent;
    // Events
    procedure OnMissionStart();
    procedure OnTick(aTick: Cardinal);
    procedure OnPlayerDefeated(aHandIndex: SmallInt);
    procedure OnPlayerVictory(aHandIndex: SmallInt);
  end;


implementation
uses
  Log;


{ TExtAIMsgEvents }
constructor TExtAIMsgEvents.Create();
begin
  inherited Create;
  fNewMsgEvent := nil;
  fStream := TKExtAIMsgStream.Create();
end;


destructor TExtAIMsgEvents.Destroy();
begin
  fNewMsgEvent := nil;
  fStream.Free;
  inherited;
end;


procedure TExtAIMsgEvents.InitMsg(aEventType: TExtAIMsgTypeEvent);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkEvent, Cardinal(aEventType), TExtAIMsgLengthData(0));
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
  fStream.Position := 0;
  if Assigned(fNewMsgEvent) then
    fNewMsgEvent(fStream.Memory, fStream.Size);
end;


procedure TExtAIMsgEvents.OnMissionStart();
begin
  InitMsg(teOnMissionStart);
  FinishMsg();
end;


procedure TExtAIMsgEvents.OnTick(aTick: Cardinal);
begin
  InitMsg(teOnTick);
  fStream.Write(aTick);
  FinishMsg();
end;


procedure TExtAIMsgEvents.OnPlayerDefeated(aHandIndex: SmallInt);
begin
  InitMsg(teOnPlayerDefeated);
  fStream.Write(aHandIndex);
  FinishMsg();
end;


procedure TExtAIMsgEvents.OnPlayerVictory(aHandIndex: SmallInt);
begin
  InitMsg(teOnPlayerVictory);
  fStream.Write(aHandIndex);
  FinishMsg();
end;


end.
