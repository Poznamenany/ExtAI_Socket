unit ExtAIStates;
interface
uses
  Classes, SysUtils,
  ExtAICommonClasses, ExtAINetClient, ExtAISharedInterface, ExtAISharedNetworkTypes;


// States of the ExtAI
type
  TExtAIStates = class
  private
    fStream: TKMemoryStream;
    fClient: TExtAINetClient;
  public
    constructor Create(aClient: TExtAINetClient);
    destructor Destroy(); override;

    property Client: TExtAINetClient write fClient;

    procedure NewState(aData: Pointer; aStateType, aLength: Cardinal);
  end;


implementation
uses
  Log;


constructor TExtAIStates.Create(aClient: TExtAINetClient);
begin
  Inherited Create;
  fClient := aClient;
  fStream := TKMemoryStream.Create();
end;


destructor TExtAIStates.Destroy();
begin
  fClient := nil;
  fStream.Free;
  Inherited;
end;


procedure TExtAIStates.NewState(aData: Pointer; aStateType, aLength: Cardinal);
begin
  fStream.Clear();
  fStream.Write(aData^,aLength);
  fStream.Position := 0;
  case TExtAIMsgTypeState(aStateType) of
    tsTerrainSize         : begin end;
    tsTerrainPassability  : begin end;
    tsTerrainFertility    : begin end;
    tsPlayerGroups        : begin end;
    tsPlayerUnits         : begin end;
    else
    begin
      // The event was not implemented or is invalid
    end;
  end;
end;


end.
