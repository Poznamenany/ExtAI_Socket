unit KM_Game;
interface
uses
  Classes, Generics.Collections, System.SysUtils,
  KM_Hand, KM_Terrain, KM_CommonTypes, ExtAIMaster,
  ExtAILog;

const
  SLEEP_EVERY_TICK = 500;

type
  // Simulation state
  TSimulationState = (
    ssCreated, // Initialization of TKMGame
    ssInProgress, // Main loop of TKMGame thread
    ssTerminated // Termination of TKMGame (command from GUI)
  );
  // Game state
  TKMGameState = (
    gsLobby, // Lobby, wait for ExtAIs to join
    gsLoad, // Load process, create ExtAIs in DLL, connect ExtAIs
    gsPlay, // Send events and states, receive actions
    gsEnd // Finish game, return to lobby in this testing version
  );
  // Callback for GUI
  TSimStatEvent = procedure (const aLog: String) of object;

  // The main thread of application (= KP, it contain access to ExtAI Interface and also Hands)
  TKMGame = class(TThread)
  private
    fExtAIMaster: TExtAIMaster; // Connection to ExtAI
    fHands: TObjectList<TKMHand>; // ExtAI hand entry point
    // Game properties (kind of testbed)
    fGameState: TKMGameState;
    fTick: Cardinal;
    fExtAIInitialized: Boolean;
    fExtAIsID: TKMWordArray; // ID of ExtAI in the lobby list
    fExtAIsNames: TStringArray; // Name of ExtAI in the lobby list

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TSimStatEvent; // Callback for GUI to update its content (for example when new AI connect)

    function CheckGameConditions(): Boolean;
    procedure InitExtAI();
    procedure LoadGame();
    procedure ProcessTick();
    procedure FinishGame();
    procedure UpdateSimulationStatus(const aLog: String = '');
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

    procedure StartGame(aNamesExtAI: TStringArray);
    procedure EndGame();
    procedure TerminateSimulation();

    procedure SendEvent();
  end;


implementation


{ TKMGame }
constructor TKMGame.Create(aOnUpdateSimStatus: TSimStatEvent);
begin
  Inherited Create(False);

  gLog.Log('TKMGame-Create'); // gLog is created in the FormCreate so it can be connected to GUI and log before TKMGame is initialized
  FreeOnTerminate := False;
  Priority := tpHigher;

  fGameState := gsLobby;
  fSimState := ssCreated;
  fHands := nil;
  fOnUpdateSimStatus := aOnUpdateSimStatus;
  fExtAIInitialized := False;
  SetLength(fExtAIsID,0);
  SetLength(fExtAIsNames,0);
  fExtAIMaster := TExtAIMaster.Create();
  gTerrain := TKMTerrain.Create();
end;


destructor TKMGame.Destroy();
begin
  gLog.Log('TKMGame-Destroy');
  gTerrain.Free;
  fHands.Free;
  fExtAIMaster.Free;

  Inherited;
end;


// Test conditions for game with ExtAI
function TKMGame.CheckGameConditions(): Boolean;
begin
  // Check if server works
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


// Init ExtAI (event before loading screen when starting new map), declare and connect AI players in DLLs
procedure TKMGame.InitExtAI();
var
  ClientExists: Boolean;
  K,L: Integer;
begin
  gLog.Log('TKMGame-InitExtAI');
  SetLength(fExtAIsID, Length(fExtAIsNames));

  // Try to find the AI in the ExtAIMaster (AI could be disconnected / lost in the meantime)
  for K := Low(fExtAIsNames) to High(fExtAIsNames) do
  begin
    ClientExists := False;
    // Find AI in the list of directly connected AIs
    for L := 0 to fExtAIMaster.AIs.Count - 1 do
      if (AnsiCompareText(fExtAIsNames[K],fExtAIMaster.AIs[L].Name) = 0) then
      begin
        ClientExists := True;
        fExtAIsID[K] := fExtAIMaster.AIs[L].ID;
        break;
      end;
    // Find DLL players in lobby and call DLL to initialize new ExtAIs
    if not ClientExists then
      for L := 0 to fExtAIMaster.DLLs.Count - 1 do
        if (AnsiCompareText(fExtAIsNames[K],fExtAIMaster.DLLs[L].Name) = 0) then
          fExtAIsID[K] := fExtAIMaster.ConnectNewExtAI(L);
  end;

  // Update game state (loading screen)
  gLog.Log('TKMGame-InitExtAI: waiting for ExtAI to connect...');
  fExtAIInitialized := True;
end;


// Start the simulation
procedure TKMGame.LoadGame();
var
  AIDetected: Boolean;
  K, L: Integer;
begin
  // Check if ExtAIs have been created (if they are part of DLL)
  if not fExtAIInitialized then
    InitExtAI();

  // Check game conditions
  if not CheckGameConditions() then
  begin
    fGameState := gsLobby;
    Exit;
  end;

  // Check if ExtAIs are initialized and connected
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
  gLog.Log('TKMGame-LoadGame');
  fTick := 0;
  FreeAndNil(fHands);
  fHands := TObjectList<TKMHand>.Create;
  for K := 0 to fExtAIMaster.AIs.Count - 1 do
    for L := Low(fExtAIsID) to High(fExtAIsID) do
      if (fExtAIsID[L] = fExtAIMaster.AIs[K].ID) then
      begin
        fHands.Add(TKMHand.Create(K));
        // Set hand to ExtAI
        fHands[fHands.Count-1].SetAIType(fExtAIMaster.AIs[K]);
        Break;
      end;

  // Start the game
  gLog.Log('TKMGame-StartMap');
  fGameState := gsPlay;
  // Call event (or check tick = 0 in hands and call it there)
  for K := 0 to fHands.Count - 1 do
    if (fHands[K].AIExt <> nil) then
      fHands[K].AIExt.MissionStart();
end;


procedure TKMGame.ProcessTick();
var
  K: Integer;
begin
  gLog.Log('TKMGame-Execute: Tick = %d', [fTick]);
  // Send game tick to ExtAI
  for K := 0 to fHands.Count - 1 do
    if (fHands[K] <> nil) AND (fHands[K].AIExt <> nil) AND (fHands[K].AIExt.Events <> nil) then
      fHands[K].UpdateState(fTick);
  Inc(fTick);

  // Do something else (update map logic, units, houses, etc.)
  // ...
end;


procedure TKMGame.FinishGame();
var
  K: Integer;
begin
  gLog.Log('TKMGame-EndMap');
  fGameState := gsEnd;
  // Call event
  if (fHands <> nil) then
    for K := 0 to fHands.Count - 1 do
      if (fHands[K].AIExt <> nil) then
        fHands[K].AIExt.MissionEnd();
  // Give some time to send the last message
  Sleep(100);
  // Terminate ExtAIs in DLLs
  fExtAIMaster.DLLs.RefreshList(nil);

  FreeAndNil(fHands);
  // Release AI created from DLL
  for K := fExtAIMaster.AIs.Count - 1 downto 0 do
    if fExtAIMaster.AIs[K].SourceIsDLL then
      fExtAIMaster.AIs.Delete(K);
  // Reset game settings
  fExtAIInitialized := False;
  fGameState := gsLobby;
end;


procedure TKMGame.UpdateSimulationStatus(const aLog: String = '');
begin
  // Log status in GUI
  Synchronize(
    procedure
    begin
      if Assigned(fOnUpdateSimStatus) then
        fOnUpdateSimStatus(aLog);
    end);
end;


// Here is the game loop (loop of the executable)
procedure TKMGame.Execute;
var
  K : Integer;
  Log: String;
begin
  gLog.Log('TKMGame-Execute: Start');
  fSimState := ssInProgress;
  while (fSimState <> ssTerminated) do
  begin
    // Update ExtAIMaster every tick (update of ExtAI server)
    fExtAIMaster.UpdateState();

    // Do specific action in dependence on state of the game
    case fGameState of
      gsLobby: begin end; // Do something in lobby / game menu
      gsLoad:  LoadGame(); // Load map, connect ExtAI with game (create classes in Hand)
      gsPlay:  ProcessTick(); // Send events and states and receive actions
      gsEnd:   FinishGame(); // Properly finish the game
    end;

    // Update GUI
    UpdateSimulationStatus();

    // Do something else (update render, GUI, etc.)
    // ...
    Sleep(SLEEP_EVERY_TICK);

    // Get logs from ExtAI in DLL
    for K := fExtAIMaster.DLLs.Count - 1 downto 0 do
      while fExtAIMaster.DLLs[K].GetAILog(Log) do
        UpdateSimulationStatus(Log);
  end;

  // If game has been terminated, then make sure that simulation is properly finished and ExtAIs are disconnected
  if (fGameState in [gsPlay,gsLoad]) then
    FinishGame();

  // Update GUI
  UpdateSimulationStatus();

  // Finish thread
  fSimState := ssTerminated;
  gLog.Log('TKMGame-Execute: End');
end;




//------------------------------------------------------------------------------
// Methods that are called by GUI (GUI thread, the goal is to change game state)
//------------------------------------------------------------------------------


// Command to start game
procedure TKMGame.StartGame(aNamesExtAI: TStringArray);
begin
  if (fGameState <> gsLobby) then
    Exit;
  gLog.Log('TKMGame-StartGame');
  // Copy list of used ExtAIs
  SetLength(fExtAIsNames, Length(aNamesExtAI));
  fExtAIsNames := Copy(aNamesExtAI, Low(aNamesExtAI), Length(aNamesExtAI));
  // Update game state (loading screen)
  fExtAIInitialized := False;
  fGameState := gsLoad;
end;


// Command to finish game
procedure TKMGame.EndGame();
begin
  if not (fGameState in [gsLoad, gsPlay]) then
    Exit;
  gLog.Log('TKMGame-EndGame');
  fGameState := gsEnd;
end;


// Terminate simulation
procedure TKMGame.TerminateSimulation();
begin
  gLog.Log('TKMGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


// Debug method for sending event
procedure TKMGame.SendEvent();
var
  K: Integer;
begin
  if fHands <> nil then
    for K := 0 to fHands.Count - 1 do
      if (fHands[K].AIExt <> nil) AND (fHands[K].AIExt.Events <> nil) then
        fHands[K].AIExt.Events.PlayerVictoryW(0);
end;


end.
