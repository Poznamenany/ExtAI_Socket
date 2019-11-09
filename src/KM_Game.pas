unit KM_Game;
interface
uses
  Classes, Generics.Collections, System.SysUtils,
  KM_Hand, KM_Terrain, KM_CommonTypes, ExtAIMaster;

const
  SLEEP_EVERY_TICK = 500;

type
  // Debug types for GUI (Simulation status etc.)
  TSimulationState = (ssCreated, ssInit, ssInProgress, ssTerminated);
  TKMGameState = (gsLobby, gsLoading, gsPlaying);
  TSimStatEvent = procedure of object;

  // The main thread of application (= KP, it contain access to ExtAI Interface and also Hands)
  TKMGame = class(TThread)
  private
    fExtAIMaster: TExtAIMaster;
    fHands: TObjectList<TKMHand>; // ExtAI hand entry point
    // Game properties (kind of testbed)
    fGameState: TKMGameState;
    fTick: Cardinal;
    fExtAIsID: TKMWordArray;

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TSimStatEvent;

    function CheckGameConditions(): Boolean;
    procedure LoadGame();
  protected
    procedure Execute; override;
  public
    constructor Create(aOnUpdateSimStatus: TSimStatEvent);
    destructor Destroy(); override;

    // Game properties
    property Tick: Cardinal read fTick;

    // Game controls
    property GameState: TKMGameState read fGameState;
    property ExtAIMaster: TExtAIMaster read fExtAIMaster;
    property SimulationState: TSimulationState read fSimState;

    procedure InitGame(aNamesExtAI: TStringArray);
    procedure EndGame();
    procedure TerminateSimulation();

    procedure SendEvent;
  end;


implementation
uses
  ExtAILog;


{ TKMGame }
constructor TKMGame.Create(aOnUpdateSimStatus: TSimStatEvent);
begin
  inherited Create(False);

  gLog.Log('TKMGame-Create');
  FreeOnTerminate := False;
  Priority := tpHigher;

  fGameState := gsLobby;
  fSimState := ssInProgress;
  fOnUpdateSimStatus := aOnUpdateSimStatus;
  fExtAIMaster := TExtAIMaster.Create(['ExtAI\','..\..\..\ExtAI\','..\..\..\ExtAI\Delphi\Win32','..\..\ExtAI\Delphi\Win32']);
  fHands := nil;
  gTerrain := TKMTerrain.Create();
end;


destructor TKMGame.Destroy();
begin
  gLog.Log('TKMGame-Destroy');
  gTerrain.Free;
  fHands.Free;
  fExtAIMaster.Free;

  inherited;
end;


// Test conditions for game with ExtAI
function TKMGame.CheckGameConditions(): Boolean;
begin
  // Check if server work
  if not fExtAIMaster.Net.Listening then
  begin
    gLog.Log('TKMGame-Server is NOT running');
    Exit(False);
  end
  // Check selection of players in lobby
  else if (Length(fExtAIsID) <= 0) then
  begin
    gLog.Log('TKMGame-AI is NOT selected / valid');
    Exit(False);
  end;
  Result := True;
end;


// Init game, declare and connect AI players in DLLs
procedure TKMGame.InitGame(aNamesExtAI: TStringArray);
var
  ClientExists: Boolean;
  K,L: Integer;
begin
  gLog.Log('TKMGame-InitGame');
  SetLength(fExtAIsID, Length(aNamesExtAI));
  if not CheckGameConditions() then
    Exit;

  // Try to find the AI in the ExtAIMaster (AI could be disconnected / lost in the meantime)
  for K := Low(aNamesExtAI) to High(aNamesExtAI) do
  begin
    ClientExists := False;
    // Find AI in the list of directly connected AIs
    for L := 0 to fExtAIMaster.AIs.Count - 1 do
      if (AnsiCompareText(aNamesExtAI[K],fExtAIMaster.AIs[L].Name) = 0) then
      begin
        ClientExists := True;
        fExtAIsID[K] := fExtAIMaster.AIs[L].ID;
        break;
      end;
    // Find DLL players in lobby and call DLL to initialize new ExtAIs
    if not ClientExists then
      for L := 0 to fExtAIMaster.DLLs.Count - 1 do
        if (AnsiCompareText(aNamesExtAI[K],fExtAIMaster.DLLs[L].Name) = 0) then
          fExtAIsID[K] := fExtAIMaster.ConnectNewExtAI(L);
  end;

  // Update game state (loading screen)
  fGameState := gsLoading;
end;


// Start the simulation
procedure TKMGame.LoadGame();
var
  AIDetected: Boolean;
  K, L: Integer;
begin
  if not CheckGameConditions() then
    Exit;

  for K := Low(fExtAIsID) to High(fExtAIsID) do
  begin
    AIDetected := False;
    for L := 0 to fExtAIMaster.AIs.Count - 1 do
      if (fExtAIsID[K] = fExtAIMaster.AIs[L].ID) then
        AIDetected := fExtAIMaster.AIs[L].ReadyForGame;
    if not AIDetected then
      Exit;
  end;

  // Clean vars before game start
  fTick := 0;
  FreeAndNil(fHands);
  fHands := TObjectList<TKMHand>.Create;

  // Start the game
  fGameState := gsPlaying;

  gLog.Log('TKMGame-LoadGame');
  for K := 0 to fExtAIMaster.AIs.Count - 1 do
    for L := Low(fExtAIsID) to High(fExtAIsID) do
      if (fExtAIsID[L] = fExtAIMaster.AIs[K].ID) then
      begin
        fHands.Add(TKMHand.Create(K));
        // Set hand to ExtAI
        fHands[fHands.Count-1].SetAIType;
        // Connect the interface
        fHands[fHands.Count-1].AIExt.ConnectCallbacks(fExtAIMaster.AIs[K].ServerClient);
        Break;
      end;
  gLog.Log('TKMGame-StartMap');
end;


procedure TKMGame.EndGame();
var
  K: Integer;
begin
  fGameState := gsLobby;
  FreeAndNil(fHands);
  // Free AI created from DLL
  for K := fExtAIMaster.AIs.Count - 1 downto 0 do
    if fExtAIMaster.AIs[K].SourceIsDLL then
      fExtAIMaster.AIs.Delete(K);
  gLog.Log('TKMGame-EndMap');
end;


// Here is the game loop (loop of the executable)
procedure TKMGame.Execute;
var
  K: Integer;
begin
  gLog.Log('TKMGame-Execute: Start');
  fSimState := ssInProgress;
  while (fSimState <> ssTerminated) do
  begin
    // Update ExtAIMaster every tick (update of ExtAI server)
    fExtAIMaster.UpdateState();

    // Try to start game when loading is finished (ExtAIs are connected)
    if (fGameState = gsLoading) then
       LoadGame()
    // Update map loop (ticks during game)
    else if (fGameState = gsPlaying) then
    begin
      //fGame.ExtAIMaster.Net.SendString(TestText);
      gLog.Log('TKMGame-Execute: Tick = %d', [fTick]);
      for K := 0 to fHands.Count - 1 do
        if (fHands[K] <> nil) AND (fHands[K].AIExt <> nil) AND (fHands[K].AIExt.Events <> nil) then
          fHands[K].UpdateState(fTick);
      Inc(fTick);

      // Do something else (update map logic, units, houses, etc.)
      // ...
    end;

    // Log status
    Synchronize(
      procedure
      begin
        if Assigned(fOnUpdateSimStatus) then
          fOnUpdateSimStatus;
      end);

    // Do something else (update game logic, GUI, etc.)
    Sleep(SLEEP_EVERY_TICK);
  end;

  fSimState := ssTerminated;
  fTick := 0;
  fOnUpdateSimStatus();
  gLog.Log('TKMGame-Execute: End');
end;


// Terminate simulation
procedure TKMGame.TerminateSimulation();
begin
  gLog.Log('TKMGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


// Debug method for sending event
procedure TKMGame.SendEvent;
var
  K: Integer;
begin
  if fHands <> nil then
    for K := 0 to fHands.Count - 1 do
      if (fHands[K].AIExt <> nil) AND (fHands[K].AIExt.Events <> nil) then
        fHands[K].AIExt.Events.PlayerVictoryW(0);
end;


end.
