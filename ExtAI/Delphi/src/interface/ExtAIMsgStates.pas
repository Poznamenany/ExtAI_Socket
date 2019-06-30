unit ExtAIMsgStates;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAISharedNetworkTypes, ExtAISharedInterface;


// Packing and unpacking of States in the message
type
  TExtAIMsgStates = class
  private
    // Main variables
    fStream: TKExtAIMsgStream;
    // Triggers
    fOnSendState           : TExtAIEventNewMsg;
    fOnTerrainSize         : TTerrainSize;
    fOnTerrainPassability  : TTerrainPassability;
    fOnTerrainFertility    : TTerrainFertility;
    fOnPlayerGroups        : TPlayerGroups;
    fOnPlayerUnits         : TPlayerUnits;

    // Send States
    procedure InitMsg(aTypeState: TExtAIMsgTypeState);
    procedure FinishMsg();
    procedure SendState();
    // Unpack States
    procedure TerrainSizeR();
    procedure TerrainPassabilityR(aLength: Cardinal);
    procedure TerrainFertilityR(aLength: Cardinal);
    procedure PlayerGroupsR();
    procedure PlayerUnitsR();
    // Others
    procedure NillEvents();
  public
    constructor Create();
    destructor Destroy(); override;

    // Connection to callbacks
    property OnSendState          : TExtAIEventNewMsg    write fOnSendState;
    property OnTerrainSize        : TTerrainSize         write fOnTerrainSize;
    property OnTerrainPassability : TTerrainPassability  write fOnTerrainPassability;
    property OnTerrainFertility   : TTerrainFertility    write fOnTerrainFertility;
    property OnPlayerGroups       : TPlayerGroups        write fOnPlayerGroups;
    property OnPlayerUnits        : TPlayerUnits         write fOnPlayerUnits;

    // Pack States
    procedure TerrainSizeW(aX, aY: Word);
    procedure TerrainPassabilityW(aPassability: TBoolArr);
    procedure TerrainFertilityW(aFertility: TBoolArr);
    procedure PlayerGroupsW(aHandIndex: SmallInt; aGroups: array of Integer);
    procedure PlayerUnitsW(aHandIndex: SmallInt; aUnits: array of Integer);

    procedure ReceiveState(aData: Pointer; aTypeState, aLength: Cardinal);
  end;


implementation


{ TExtAIMsgStates }
constructor TExtAIMsgStates.Create();
begin
  Inherited Create;
  fStream := TKExtAIMsgStream.Create();
  NillEvents();
end;


destructor TExtAIMsgStates.Destroy();
begin
  fStream.Free;
  NillEvents();
  Inherited;
end;


procedure TExtAIMsgStates.NillEvents();
begin
  fOnTerrainSize         := nil;
  fOnTerrainPassability  := nil;
  fOnTerrainFertility    := nil;
  fOnPlayerGroups        := nil;
  fOnPlayerUnits         := nil;
end;


procedure TExtAIMsgStates.InitMsg(aTypeState: TExtAIMsgTypeState);
begin
  // Clear stream and create head with predefined 0 length
  fStream.Clear;
  fStream.WriteMsgType(mkState, Cardinal(aTypeState), TExtAIMsgLengthData(0));
end;


procedure TExtAIMsgStates.FinishMsg();
var
  MsgLenght: TExtAIMsgLengthData;
begin
  // Replace 0 length with correct number
  MsgLenght := fStream.Size - SizeOf(TExtAIMsgKind) - SizeOf(TExtAIMsgTypeEvent) - SizeOf(TExtAIMsgLengthData);
  fStream.Position := SizeOf(TExtAIMsgKind) + SizeOf(TExtAIMsgTypeEvent);
  fStream.Write(MsgLenght, SizeOf(MsgLenght));
  // Send Event
  SendState();
end;


procedure TExtAIMsgStates.SendState();
begin
  // Send message
  if Assigned(fOnSendState) then
    fOnSendState(fStream.Memory, fStream.Size);
end;


procedure TExtAIMsgStates.ReceiveState(aData: Pointer; aTypeState, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^,aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeState(aTypeState) of
    tsTerrainSize         : TerrainSizeR();
    tsTerrainPassability  : TerrainPassabilityR(aLength);
    tsTerrainFertility    : TerrainFertilityR(aLength);
    tsPlayerGroups        : PlayerGroupsR();
    tsPlayerUnits         : PlayerUnitsR();
    else begin end;
  end;
end;


// States


procedure TExtAIMsgStates.TerrainSizeW(aX, aY: Word);
begin
  InitMsg(tsTerrainSize);
  fStream.Write(aX);
  fStream.Write(aY);
  FinishMsg();
end;
procedure TExtAIMsgStates.TerrainSizeR();
var
  X,Y: Word;
begin
  fStream.Read(X);
  fStream.Read(Y);
  if Assigned(fOnTerrainSize) then
    fOnTerrainSize(X,Y);
end;


procedure TExtAIMsgStates.TerrainPassabilityW(aPassability: TBoolArr);
begin
  InitMsg(tsTerrainPassability);
  fStream.Write(aPassability[0], SizeOf(aPassability[0]) * Length(aPassability));
  FinishMsg();
end;
procedure TExtAIMsgStates.TerrainPassabilityR(aLength: Cardinal);
var
  Passability: TBoolArr;
begin
  SetLength(Passability, aLength);
  fStream.Read(Passability[0], SizeOf(Passability[0]) * Length(Passability));
  if Assigned(fOnTerrainPassability) then
    fOnTerrainPassability(Passability);
end;


procedure TExtAIMsgStates.TerrainFertilityW(aFertility: TBoolArr);
begin
  InitMsg(tsTerrainFertility);
  fStream.Write(aFertility[0], SizeOf(aFertility[0]) * Length(aFertility));
  FinishMsg();
end;
procedure TExtAIMsgStates.TerrainFertilityR(aLength: Cardinal);
var
  Fertility: TBoolArr;
begin
  SetLength(Fertility, aLength);
  fStream.Read(Fertility[0], SizeOf(Fertility[0]) * Length(Fertility));
  if Assigned(fOnTerrainFertility) then
    fOnTerrainFertility(Fertility);
end;


procedure TExtAIMsgStates.PlayerGroupsW(aHandIndex: SmallInt; aGroups: array of Integer);
var
  Len: Cardinal;
begin
  InitMsg(tsPlayerGroups);
  fStream.Write(aHandIndex);
  Len := Length(aGroups);
  fStream.Write(Len, SizeOf(Len));
  fStream.Write(aGroups[0], SizeOf(aGroups[0]) * Length(aGroups));
  FinishMsg();
end;
procedure TExtAIMsgStates.PlayerGroupsR();
var
  HandIndex: SmallInt;
  Count: Cardinal;
  Groups: array of Integer;
begin
  fStream.Read(HandIndex);
  fStream.Read(Count);
  SetLength(Groups,Count);
  fStream.Read(Groups[0], SizeOf(Groups[0]) * Length(Groups));
  if Assigned(fOnPlayerGroups) then
    fOnPlayerGroups(HandIndex, Groups);
end;


procedure TExtAIMsgStates.PlayerUnitsW(aHandIndex: SmallInt; aUnits: array of Integer);
var
  Len: Cardinal;
begin
  InitMsg(tsPlayerUnits);
  fStream.Write(aHandIndex);
  Len := Length(aUnits);
  fStream.Write(Len, SizeOf(Len));
  fStream.Write(aUnits[0], SizeOf(aUnits[0]) * Length(aUnits));
  FinishMsg();
end;
procedure TExtAIMsgStates.PlayerUnitsR();
var
  HandIndex: SmallInt;
  Count: Cardinal;
  Units: array of Integer;
begin
  fStream.Read(HandIndex);
  fStream.Read(Count);
  SetLength(Units,Count);
  fStream.Read(Units[0], SizeOf(Units[0]) * Length(Units));
  if Assigned(fOnPlayerGroups) then
    fOnPlayerUnits(HandIndex, Units);
end;


end.
