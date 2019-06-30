unit Game;
interface
uses
  Windows, Classes, Generics.Collections,
  System.Threading, System.Diagnostics, System.SysUtils,
  Hand, ExtAIMaster;

const
  SLEEP_EVERY_TICK = 500;

type
  TSimulationState = (ssCreated, ssInit, ssInProgress, ssTerminated);
  TGameState = (gsLobby,gsPlaying);
  TUpdateSimStatEvent = procedure of object;

  // The main thread of application (= KP, it contain access to ExtAI Interface and also Hands)
  TGame = class(TThread)
  private
    fExtAIMaster: TExtAIMaster;
    fHands: TObjectList<THand>; // ExtAI hand entry point
    // Game properties (kind of testbed)
    fGameState: TGameState;
    fTick: Cardinal;

    // Purely testbed things
    fSimState: TSimulationState;
    fOnUpdateSimStatus: TUpdateSimStatEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(aOnUpdateSimStatus: TUpdateSimStatEvent); reintroduce;
    destructor Destroy(); override;

    // Game properties
    property Tick: Cardinal read fTick;

    // Game controls
    property GameState: TGameState read fGameState;
    property ExtAIMaster: TExtAIMaster read fExtAIMaster;
    property SimulationState: TSimulationState read fSimState;
    property Hands: TObjectList<THand> read fHands;
    procedure StartEndGame(AIs: array of String);
    procedure TerminateSimulation();
  end;

implementation
uses
  Log;


{ TGame }
constructor TGame.Create(aOnUpdateSimStatus: TUpdateSimStatEvent);
begin
  inherited Create(False);
  gLog.Log('TGame-Create');
  FreeOnTerminate := False;
  Priority := tpHigher;

  fGameState := gsLobby;
  fSimState := ssInProgress;
  fOnUpdateSimStatus := aOnUpdateSimStatus;
  fExtAIMaster := TExtAIMaster.Create();
  fHands := nil;
end;


destructor TGame.Destroy();
begin
  gLog.Log('TGame-Destroy');
  FreeAndNil(fHands);
  fExtAIMaster.Free();
  inherited;
end;


procedure TGame.StartEndGame(AIs: array of String);
var
  K, L: Integer;
begin
  fTick := 0;
  if not ExtAIMaster.Net.Listening then
    Exit;
  // Clean hands before game start / end
  FreeAndNil(fHands);
  if (fGameState = gsLobby) then
  begin
    gLog.Log('TGame-StartMap');
    fGameState := gsPlaying;
    // Use all ExtAI in every game for now
    fHands := TObjectList<THand>.Create();
    for K := 0 to ExtAIMaster.AIs.Count - 1 do
      for L := Low(AIs) to High(AIs) do
        if (AIs[L] = ExtAIMaster.AIs[K].Name) then
        begin
          fHands.Add(THand.Create(K));
          // Set hand to ExtAI
          fHands[ fHands.Count-1 ].SetAIType();
          // Connect the interface
          fHands[ fHands.Count-1 ].AIExt.ConnectCallbacks( ExtAIMaster.AIs[K].ServerClient );
          break;
        end;
  end
  else if (fGameState = gsPlaying) then
  begin
    gLog.Log('TGame-EndMap');
    fGameState := gsLobby;
  end;
end;


procedure TGame.Execute;
var
  K: Integer;
begin
  gLog.Log('TGame-Execute: Start');
  fSimState := ssInProgress;

  while (fSimState <> ssTerminated) do
  begin
    // Update ExtAIMaster every tick (update of ExtAI server)
    fExtAIMaster.UpdateState();

    // Check if game is played (we moved from lobby to map)
    if (fGameState = gsPlaying) then
    begin
      //fGame.ExtAIMaster.Net.SendString(TestText);
      gLog.Log('TGame-Execute: Tick = ' + IntToStr(fTick));
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
  gLog.Log('TGame-Execute: End');
end;


procedure TGame.TerminateSimulation();
begin
  gLog.Log('TGame-TerminateSimulation');
  fSimState := ssTerminated;
end;


end.
