unit ExtAIDelphi;
interface
uses
  System.SysUtils, ExtAIBaseDelphi;

type
  // Here will be the main algorithm of the ExtAI
  // It works similar to dynamics scripts (it reacts to Events with Actions and States)
  TExtAIDelphi = class(TExtAIBaseDelphi)
  private
    // Game variables and methods
    procedure HuntUnit();
  protected
    // Game Events (only events which are used)
    procedure OnTick(aTick: Cardinal); override;
    procedure OnPlayerVictory(aHandIndex: SmallInt); override;
  public
    constructor Create();
    destructor Destroy(); override;
  end;

implementation
uses
  Log;


{ TExtAIDelphi }
constructor TExtAIDelphi.Create();
const
  AUTHOR: UnicodeString = 'Martin';
  DESCRIPTION: UnicodeString = 'Testing ExtAI with WebSocket';
  NAME: UnicodeString = 'Skynet';
  VERSION: Cardinal = 20190625;
begin
  inherited Create(AUTHOR, NAME, DESCRIPTION, VERSION);

end;


destructor TExtAIDelphi.Destroy();
begin
  inherited;
end;


procedure TExtAIDelphi.OnTick(aTick: Cardinal);
begin
  gClientLog.Log('TExtAIDelphi Tick: ' + IntToStr(aTick));
  //Actions.Log('This is message from ExtAI');
  //Actions.GroupOrderWalk(11,5,5,22);
  HuntUnit();
end;


procedure TExtAIDelphi.OnPlayerVictory(aHandIndex: SmallInt);
begin
  gClientLog.Log('TExtAIDelphi OnPlayerVicotry');
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
