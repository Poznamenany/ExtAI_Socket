unit ExtAIDelphi;
interface
uses
  System.SysUtils,
  ExtAILog, ExtAIBaseDelphi;

type
  // Here will be the main algorithm of the ExtAI
  // It works just like dynamic scripts (it reacts to Events with Actions and States)
  TExtAIDelphi = class(TExtAIBaseDelphi)
  private
    // Game variables and methods
    procedure HuntUnit();
  protected
    // Game Events (only events which are used)
    procedure OnMissionStart(); override;
    procedure OnMissionEnd(); override;
    procedure OnTick(aTick: Cardinal); override;
    procedure OnPlayerVictory(aHandIndex: SmallInt); override;
  public
    constructor Create(aLog: TExtAILog = nil; aID: Word = 0);
    destructor Destroy(); override;
  end;

implementation


{ TExtAIDelphi }
constructor TExtAIDelphi.Create(aLog: TExtAILog = nil; aID: Word = 0);
const
  AUTHOR: UnicodeString = 'Martin';
  DESCRIPTION: UnicodeString = 'Testing ExtAI with WebSocket';
  NAME: UnicodeString = 'Skynet';
  VERSION: Cardinal = 20190625;
begin
  Inherited Create(aLog, aID, AUTHOR, NAME, DESCRIPTION, VERSION);

end;


destructor TExtAIDelphi.Destroy();
begin
  Inherited;
end;

procedure TExtAIDelphi.OnMissionStart();
begin
  Log('TExtAIDelphi OnMissionStart');
end;


procedure TExtAIDelphi.OnMissionEnd();
begin
  Log('TExtAIDelphi OnMissionEnd');
end;


procedure TExtAIDelphi.OnTick(aTick: Cardinal);
begin
  Log('TExtAIDelphi Tick: %d', [aTick]);
  //Actions.Log('This is message from ExtAI');
  //Actions.GroupOrderWalk(11,5,5,22);
  if (aTick = 1) AND (States.MapWidth > 0) then
    Log('TExtAIDelphi Terrain was loaded');
  HuntUnit();
end;


procedure TExtAIDelphi.OnPlayerVictory(aHandIndex: SmallInt);
begin
  Log('TExtAIDelphi OnPlayerVictory');
end;


// Hello world of the ExtAI and KP
procedure TExtAIDelphi.HuntUnit();
{
var
  Group: Integer;
  HostileUnit: Integer;
}
begin
{
  HostileUnit := States.GetUnit();
  Group := States.GetGroup();
  if (HostileUnit > 0) and (Group > 0) then
    Actions.GroupOrderAttackUnit(Group,HostileUnit);
}
end;

end.
