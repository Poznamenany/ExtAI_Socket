unit ExtAIBaseDelphi;
interface
uses
  Windows, Classes, Generics.Collections,
  System.SysUtils,
  ExtAILog, ExtAINetClient, ExtAIActions, ExtAIEvents, ExtAIStates;

type
  // The main thread of ExtAI, communication interface and parent of every ExtAI
  TExtAIBaseDelphi = class(TThread)
  private
    // Thread variables
    fID: Word;
    fActive: Boolean;
    fClient: TExtAINetClient;
    fLog: TExtAILog;
    procedure ClientStatusMessage(const aMsg: String);
  protected
    fActions: TExtAIActions;
    fEvents: TExtAIEvents;
    fStates: TExtAIStates;
    // Thread loop
    procedure Execute(); override;
    // Game Events
    procedure OnMissionStart();                        virtual;
    procedure OnMissionEnd();                          virtual;
    procedure OnTick(aTick: Cardinal);                 virtual;
    procedure OnPlayerVictory(aHandIndex: SmallInt);   virtual;
    procedure OnPlayerDefeated(aHandIndex: SmallInt);  virtual;
    // Log
    procedure Log(const aText: String; const aArgs: array of const); overload;
    procedure Log(const aText: String); overload;
  public
    constructor Create(aLog: TExtAILog; const aID: Word; const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
    destructor Destroy(); override;

    property ID: Word read fID;
    property Actions: TExtAIActions read fActions;
    property States: TExtAIStates read fStates;
    property Client: TExtAINetClient read fClient;

    procedure TerminateSimulation();
  end;

implementation


{ TExtAIBaseDelphi }
constructor TExtAIBaseDelphi.Create(aLog: TExtAILog; const aID: Word; const aAuthor, aName, aDescription: UnicodeString; const aVersion: Cardinal);
begin
  Inherited Create(False); // Create thread and start Execution
  FreeOnTerminate := False;
  Priority := tpLower;

  fActive := True;
  fID := aID;
  fClient := TExtAINetClient.Create(aID, aAuthor, aName, aDescription, aVersion);
  fLog := aLog;

  fActions := TExtAIActions.Create(fClient);
  fEvents := TExtAIEvents.Create();
  fStates := TExtAIStates.Create(fClient);
  fClient.OnNewEvent := fEvents.Msg.ReceiveEvent;
  fClient.OnNewState := fStates.Msg.ReceiveState;
  fClient.OnStatusMessage := ClientStatusMessage;

  fEvents.Msg.OnMissionStart := OnMissionStart;
  fEvents.Msg.OnMissionEnd := OnMissionEnd;
  fEvents.Msg.OnTick := OnTick;
  fEvents.Msg.OnPlayerVictory := OnPlayerVictory;
  fEvents.Msg.OnPlayerDefeated := OnPlayerDefeated;

  Log('TExtAIBaseDelphi-Create ID = %d', [fID]);
end;


destructor TExtAIBaseDelphi.Destroy();
begin
  if Client.Connected then
    Client.Disconnect();
  Log('TExtAIBaseDelphi-Destroy ID = %d', [fID]);
  fClient.Free;
  fActions.Free;
  fEvents.Free;
  fStates.Free;
  Inherited;
end;


procedure TExtAIBaseDelphi.Execute();
begin
  Log('TExtAIBaseDelphi-Execute: Start');
  while fActive do
  begin
    fClient.ProcessReceivedMessages();
    Sleep(10);
  end;
  Log('TExtAIBaseDelphi-Execute: End');
end;


procedure TExtAIBaseDelphi.TerminateSimulation();
begin
  fActive := False;
end;


procedure TExtAIBaseDelphi.ClientStatusMessage(const aMsg: String);
begin
  Log(aMsg);
end;


procedure TExtAIBaseDelphi.Log(const aText: String; const aArgs: array of const);
begin
  Log(Format(aText,aArgs));
end;

procedure TExtAIBaseDelphi.Log(const aText: String);
begin
  if Assigned(fLog) then
    fLog.Log(aText);
end;



// Dummy Events so user does not have to define the methods in child class and can choose just the necessary
procedure TExtAIBaseDelphi.OnMissionStart(); begin end;
procedure TExtAIBaseDelphi.OnMissionEnd(); begin end;
procedure TExtAIBaseDelphi.OnTick(aTick: Cardinal); begin end;
procedure TExtAIBaseDelphi.OnPlayerVictory(aHandIndex: SmallInt); begin end;
procedure TExtAIBaseDelphi.OnPlayerDefeated(aHandIndex: SmallInt); begin end;

end.
