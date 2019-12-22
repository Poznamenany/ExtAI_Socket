library ExtAI_Delphi_dll;
{$DEFINE ExtAI_Delphi_dll}

uses
  System.SysUtils,
  System.Classes,
  Generics.Collections,
  ExtAILog in 'src\ExtAILog.pas',
  ExtAILogDLL in 'src\ExtAILogDLL.pas',
  ExtAIDelphi in 'src\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'src\ExtAIBaseDelphi.pas',
  ExtAIActions in 'src\interface\ExtAIActions.pas',
  ExtAIEvents in 'src\interface\ExtAIEvents.pas',
  ExtAIStates in 'src\interface\ExtAIStates.pas',
  ExtAIMsgActions in 'src\interface\ExtAIMsgActions.pas',
  ExtAIMsgEvents in 'src\interface\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'src\interface\ExtAIMsgStates.pas',
  ExtAIStatesTerrain in 'src\interface\ExtAIStatesTerrain.pas',
  ExtAISharedInterface in 'src\interface\ExtAISharedInterface.pas',
  ExtAICommonClasses in 'src\net\ExtAICommonClasses.pas',
  ExtAINetClient in 'src\net\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'src\net\ExtAISharedNetworkTypes.pas';

{$R *.res}

var
  gExtAI: TObjectList<TExtAIDelphi>;
  gLogDLL: TLogDLL;


// Initialize DLL and get info about ExtAI
procedure InitializeDLL(var aConfig: TDLLpConfig); StdCall;
var
  infoExtAI: TExtAIDelphi;
begin
  // Init DLL Log
  gLogDLL := TLogDLL.Create();
  // Init DLL
  gExtAI := TObjectList<TExtAIDelphi>.Create;
  // Get info about ExtAI in this DLL
  infoExtAI := TExtAIDelphi.Create(gLogDLL.GetTLog,0);
  try
    with infoExtAI.Client do
    begin
      aConfig.Author := Addr(Author[1]);
      aConfig.AuthorLen := Length(Author);
      aConfig.Description := Addr(Description[1]);
      aConfig.DescriptionLen := Length(Description);
      aConfig.ExtAIName := Addr(ClientName[1]);
      aConfig.ExtAINameLen := Length(ClientName);
      aConfig.Version := AIVersion;
    end;
  finally
    infoExtAI.TerminateSimulation;
    infoExtAI.WaitFor;
    infoExtAI.Free;
  end;
end;


// Terminate DLL
procedure TerminateDLL(); StdCall;
var
  K: Integer;
begin
  // Terminate ExtAI threads
  for K := 0 to gExtAI.Count - 1 do
    gExtAI[K].TerminateSimulation;
  // Wait for threads to finish
  for K := 0 to gExtAI.Count - 1 do
    gExtAI[K].WaitFor;
  //Sleep(1000);
  gExtAI.Free;
  gLogDLL.Free;
end;


// Create new ExtAI
function CreateExtAI(aID, aPort: Word; apIP: PWideChar; aLen: Cardinal): Boolean; StdCall;
var
  K: Integer;
  ExtAI: TExtAIDelphi;
  IP: UnicodeString;
begin
  if (gExtAI = nil) then
    Exit(False);

  for K := 0 to gExtAI.Count - 1 do
    if (gExtAI[K].ID = aID) then
      Exit(False);

  // Get IP from string (or we can send IP in Cardinal in future)
  SetLength(IP, aLen);
  Move(apIP^, IP[1], aLen * SizeOf(IP[1]));

  // Create new ExtAI
  ExtAI := TExtAIDelphi.Create(gLogDLL.GetTLog,aID);
  // Wait for initialization of thread (just to be sure)
  Sleep(100);
  // Connect Client to server
  ExtAI.Client.ConnectTo(IP, aPort);
  // Add ExtAI to list
  gExtAI.Add(ExtAI);

  Result := True;
end;


function TerminateExtAI(aID: Word): Boolean; StdCall;
var
  K: Integer;
begin
  Result := False;
  // Remove ExtAI
  for K := 0 to gExtAI.Count - 1 do
    if (gExtAI[K].ID = aID) then
    begin
      gExtAI[K].TerminateSimulation;
      gExtAI[K].WaitFor;
      gExtAI.Delete(K);
      Exit(True);
    end;
end;


function GetFirstLog(var aLog: PWideChar; var aLength: Cardinal): Boolean; StdCall;
var
  Log: String;
begin
  Result := False;
  if gLogDLL.RemoveFirstLog(Log) then
  begin
    aLength := Length(Log);
    aLog := Addr(Log[1]);
    Result := (Length(Log) > 0);
  end;
end;


// Exports
exports
  InitializeDLL,
  TerminateDLL,
  CreateExtAI,
  TerminateExtAI,
  GetFirstLog;


begin

end.
