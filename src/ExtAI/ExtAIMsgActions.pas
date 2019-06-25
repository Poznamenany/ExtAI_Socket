unit ExtAIMsgActions;
interface
uses
  Classes, Windows, System.SysUtils,
  Consts, ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAINetServer;

type
  TExtAIMsgActions = class
  private
    fStream: TKExtAIMsgStream;
    procedure GroupOrderAttackUnit();
    procedure GroupOrderWalk();
    procedure Log();
  public
    constructor Create();
    destructor Destroy; override;

    procedure NewAction(aData: Pointer; aTypeAction, aLength: Cardinal);
  end;


implementation
uses
  Log;


{ TExtAIMsgActions }
constructor TExtAIMsgActions.Create();
begin
  inherited Create;
  fStream := TKExtAIMsgStream.Create();
end;


destructor TExtAIMsgActions.Destroy();
begin
  fStream.Free;
  inherited;
end;


procedure TExtAIMsgActions.NewAction(aData: Pointer; aTypeAction, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^, aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeAction(aTypeAction) of
    taGroupOrderAttackUnit: GroupOrderAttackUnit();
    taGroupOrderWalk:       GroupOrderWalk();
    taLog:                  Log();
    else                    begin end;
  end;
end;


procedure TExtAIMsgActions.GroupOrderAttackUnit();
var
  GroupID, UnitID: Integer;
begin
  fStream.Read(GroupID);
  fStream.Read(UnitID);
  gLog.Log('TExtAIMsgActions GroupOrderAttackUnit: GropID = ' + IntToStr(GroupID) + ' UnitID = ' + IntToStr(UnitID));
end;


procedure TExtAIMsgActions.GroupOrderWalk();
var
  GroupID, X, Y, Dir: Integer;
begin
  fStream.Read(GroupID);
  fStream.Read(X);
  fStream.Read(Y);
  fStream.Read(Dir);
  gLog.Log('TExtAIMsgActions GroupOrderWalk: GropID = ' + IntToStr(GroupID));
end;


procedure TExtAIMsgActions.Log();
var
  Txt: UnicodeString;
begin
  fStream.ReadW(Txt);
  gLog.Log('TExtAIMsgActions Log: ' + Txt);
end;

end.
