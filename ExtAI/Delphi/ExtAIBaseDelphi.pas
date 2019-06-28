unit ExtAIBaseDelphi;
interface
uses
  Windows, Classes, Generics.Collections,
  System.Threading, System.Diagnostics, System.SysUtils,
  ExtAINetClient, ExtAIActions, ExtAIEvents, ExtAIStates;

type
  // The main thread of ExtAI, communication interface and parent of every ExtAI
  TExtAIBaseDelphi = class(TThread)
  private
    // Thread variables
    fActive: Boolean;
    fClient: TExtAINetClient;
  protected
    fActions: TExtAIActions;
    fEvents: TExtAIEvents;
    fStates: TExtAIStates;
    // Thread loop
    procedure Execute(); override;
    // Game Events
    procedure OnMissionStart();                        virtual;
    procedure OnTick(aTick: Cardinal);                 virtual;
    procedure OnPlayerVictory(aHandIndex: SmallInt);   virtual;
    procedure OnPlayerDefeated(aHandIndex: SmallInt);  virtual;
  public
    constructor Create(const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
    destructor Destroy(); override;

    property Actions: TExtAIActions read fActions;
    property States: TExtAIStates read fStates;
    property Client: TExtAINetClient read fClient;

    procedure TerminateSimulation();
  end;

implementation
uses
  Log;


{ TExtAIBaseDelphi }
constructor TExtAIBaseDelphi.Create(const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  Priority := tpLower;

  fActive := True;
  fClient := TExtAINetClient.Create(aAuthor, aName, aDescription, aVersion);

  fActions := TExtAIActions.Create(fClient);
  fEvents := TExtAIEvents.Create();
  fStates := TExtAIStates.Create(fClient);
  fClient.OnNewEvent := fEvents.Msg.ReceiveEvent;
  fClient.OnNewState := fStates.NewState;

  fEvents.Msg.OnMissionStart := OnMissionStart;
  fEvents.Msg.OnTick := OnTick;
  fEvents.Msg.OnPlayerVictory := OnPlayerVictory;
  fEvents.Msg.OnPlayerDefeated := OnPlayerDefeated;

  gClientLog.Log('Create TExtAIBaseDelphi');
end;


destructor TExtAIBaseDelphi.Destroy();
begin
  if Client.Connected then
    Client.Disconnect();
  gClientLog.Log('Destroy TExtAIBaseDelphi');
  fClient.Free;
  fActions.Free;
  fEvents.Free;
  fStates.Free;
  inherited;
end;


procedure TExtAIBaseDelphi.Execute();
begin
  gClientLog.Log('Execute: Start');
  while fActive do
  begin
    fClient.ProcessReceivedMessages();
    Sleep(10);
  end;
  gClientLog.Log('Execute: End');
end;


procedure TExtAIBaseDelphi.TerminateSimulation();
begin
  fActive := False;
end;

// Dummy Events so user does not have to define the methods in child class and can choose just the necessary
procedure TExtAIBaseDelphi.OnMissionStart(); begin end;
procedure TExtAIBaseDelphi.OnTick(aTick: Cardinal); begin end;
procedure TExtAIBaseDelphi.OnPlayerVictory(aHandIndex: SmallInt); begin end;
procedure TExtAIBaseDelphi.OnPlayerDefeated(aHandIndex: SmallInt); begin end;

end.
