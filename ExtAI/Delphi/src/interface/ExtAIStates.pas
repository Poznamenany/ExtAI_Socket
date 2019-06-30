unit ExtAIStates;
interface
uses
  Classes, SysUtils,
  ExtAIMsgStates, ExtAIStatesTerrain, ExtAINetClient, ExtAISharedInterface;


// States of the ExtAI
type
  TExtAIStates = class
  private
    fMsg: TExtAIMsgStates;
    fClient: TExtAINetClient;
    // Game variables
    fTerrain: TExtAIStatesTerrain;
    // Send state via client
    procedure SendState(aData: Pointer; aLength: Cardinal);
  public
    constructor Create(aClient: TExtAINetClient);
    destructor Destroy(); override;

    // Connect Msg directly with creator of ExtAI so he can type Actions.XY instead of Actions.Msg.XY
    property Msg: TExtAIMsgStates read fMsg;
    property Terrain: TExtAIStatesTerrain read fTerrain;

    // States from perspective of the ExtAI
    function MapHeight(): Word;
    function MapWidth(): Word;
    function TileIsPassable(aHeight,aWidth: Word): boolean;
    function Passability(): TBoolArr;
    function TileIsFertile(aHeight,aWidth: Word): boolean;
    function Fertility(): TBoolArr;
  end;


implementation


{ TExtAIStates }
constructor TExtAIStates.Create(aClient: TExtAINetClient);
begin
  Inherited Create;
  fClient := aClient;
  fMsg := TExtAIMsgStates.Create();
  fTerrain := TExtAIStatesTerrain.Create(fMsg);
  // Connect callbacks
  fMsg.OnSendState := SendState;
end;


destructor TExtAIStates.Destroy();
begin
  fMsg.Free;
  fTerrain.Free;
  fClient := nil;
  Inherited;
end;


procedure TExtAIStates.SendState(aData: Pointer; aLength: Cardinal);
begin
  Assert(fClient <> nil, 'State cannot be send because client = nil');
  fClient.SendMessage(aData, aLength);
end;


function TExtAIStates.MapHeight(): Word;
begin
  Result := Terrain.MapHeight;
end;


function TExtAIStates.MapWidth(): Word;
begin
  Result := Terrain.MapWidth;
end;


function TExtAIStates.TileIsPassable(aHeight,aWidth: Word): boolean;
begin
  Result := False;
  if (aHeight > 0) AND (aHeight <= Terrain.MapHeight) AND
     (aWidth  > 0) AND (aWidth  <= Terrain.MapWidth) AND
     (Length(Terrain.Passability) > aWidth * aHeight + aWidth) then
    Result := Terrain.Passability[Terrain.MapWidth * aHeight + aWidth];
end;


function TExtAIStates.Passability(): TBoolArr;
begin
  Result := Terrain.Passability;
end;


function TExtAIStates.TileIsFertile(aHeight,aWidth: Word): boolean;
begin
  Result := False;
  if (aHeight > 0) AND (aHeight <= Terrain.MapHeight) AND
     (aWidth  > 0) AND (aWidth  <= Terrain.MapWidth) AND
     (Length(Terrain.Fertility) > aWidth * aHeight + aWidth) then
    Result := Terrain.Fertility[Terrain.MapWidth * aHeight + aWidth];
end;


function TExtAIStates.Fertility(): TBoolArr;
begin
  Result := Terrain.Fertility;
end;



end.
