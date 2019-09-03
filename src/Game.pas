unit Game;
interface
uses
  Windows, Classes, Generics.Collections, System.SysUtils,
  KM_Hand, KM_Terrain, ExtAIMaster;

const
  SLEEP_EVERY_TICK = 500;

type
  TSimulationState = (ssCreated, ssInit, ssInProgress, ssTerminated);
  TKMGameState = (gsLobby, gsPlaying);
  TSimStatEvent = procedure of object;

  // The main thread of application (= KP, it contain access to ExtAI Interface and also Hands)
  TKMGame = class(TThread)
  private
    fExtAIMaster: TExtAIMaster;
    fHands: TObjectList<TKMHand>; // ExtAI hand entry point
    // Game properties (kind of testbed)
    fGameState: TKMGameState;
    fTick: Cardinal;

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TSimStatEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(aOnUpdateSimStatus: TSimStatEvent); reintroduce;
    destructor Destroy(); override;

    // Game properties
    property Tick: Cardinal read fTick;

    // Game controls
    property GameState: TKMGameState read fGameState;
    property ExtAIMaster: TExtAIMaster read fExtAIMaster;
    property SimulationState: TSimulationState read fSimState;
    property Hands: TObjectList<TKMHand> read fHands;

    procedure StartEndGame(AIs: array of String);
    procedure TerminateSimulation();
  end;

implementation
uses
  ExtAILog;


{ TKMGame }
constructor TKMGame.Create(aOnUpdateSimStatus: TSimStatEvent);
begin
  inherited Create(False);
  gLog.Log('TKMGame-Create');
  gTerrain := TKMTerrain.Create;
  FreeOnTerminate := False;
  Priority := tpHigher;

  fGameState := gsLobby;
  fSimState := ssInProgress;
  fOnUpdateSimStatus := aOnUpdateSimStatus;
  fExtAIMaster := TExtAIMaster.Create();
  fHands := nil;
end;


destructor TKMGame.Destroy();
begin
  gLog.Log('TKMGame-Destroy');
  gTerrain.Free;
  FreeAndNil(fHands);
  fExtAIMaster.Free;
  inherited;
end;


procedure TKMGame.StartEndGame(AIs: array of String);
var
  K, L: Integer;
begin
  fTick := 0;
  if not ExtAIMaster.Net.Listening then
    Exit;

  // Clean hands before game start / end
  FreeAndNil(fHands);

  case fGameState of
    gsLobby:  begin
                gLog.Log('TKMGame-StartMap');
                fGameState := gsPlaying;
                // Use all ExtAI in every game for now
                fHands := TObjectList<TKMHand>.Create;
                for K := 0 to ExtAIMaster.AIs.Count - 1 do
                  for L := Low(AIs) to High(AIs) do
                    if (AIs[L] = ExtAIMaster.AIs[K].Name) then
                    begin
                      fHands.Add(TKMHand.Create(K));
                      // Set hand to ExtAI
                      fHands[fHands.Count-1].SetAIType;
                      // Connect the interface
                      fHands[fHands.Count-1].AIExt.ConnectCallbacks(ExtAIMaster.AIs[K].ServerClient);
                      Break;
                    end;
              end;
    gsPlaying:begin
                gLog.Log('TKMGame-EndMap');
                fGameState := gsLobby;
              end;
  end;
end;


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

    // Check if game is played (we moved from lobby to map)
    if (fGameState = gsPlaying) then
    begin
      //fGame.ExtAIMaster.Net.SendString(TestText);
      gLog.Log('TKMGame-Execute: Tick = ' + IntToStr(fTick));
      for K := 0 to fHands.Count - 1 do
        if (fHands[K] <> nil) AND (fHands[K].AIExt <> nil) AND (fHands[K].AIExt.Events <> nil) then
          fHands[K].UpdateState(fTick);
      Inc(fTick);
    end;

    // Log status
    Synchronize(
      procedure
      begin
        if Assigned(fOnUpdateSimStatus) then
          fOnUpdateSimStatus;
      end);

    // Do something else (update game logic)
    Sleep(SLEEP_EVERY_TICK);
  end;

  fSimState := ssTerminated;
  fTick := 0;
  fOnUpdateSimStatus();
  gLog.Log('TKMGame-Execute: End');
end;


procedure TKMGame.TerminateSimulation();
begin
  gLog.Log('TKMGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


end.
