library ExtAI_Delphi_dll;
{$DEFINE ExtAI_Delphi_dll}

uses
  System.SysUtils,
  System.Classes,
  Generics.Collections,
  ExtAILog in 'src\ExtAILog.pas',
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
  //gLogFile: TextFile;


// Log
procedure Log(aStr: UnicodeString);
begin
  //if ALLOW_LOG then
  //  Writeln(gLogFile, aStr);
end;


// Initialize DLL and get info about ExtAI
procedure InitDLL(var aConfig: TDLLpConfig); StdCall;
var
  infoExtAI: TExtAIDelphi;
begin
  // Init DLL
  gExtAI := TObjectList<TExtAIDelphi>.Create;
  // Get info about ExtAI in this DLL
  infoExtAI := TExtAIDelphi.Create(nil,0);
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
    infoExtAI.Free;
  end;
end;


// Terminate DLL
procedure TerminDLL(); StdCall;
var
  K: Integer;
begin
  // Clean ExtAIs
  for K := gExtAI.Count - 1 downto 0 do
    gExtAI[K].Free;
  FreeAndNil(gExtAI);
  //FreeAndNil(gLogFile);
end;


// Create new ExtAI
function CreateNewExtAI(aID: Word): Boolean; StdCall;
var
  K: Integer;
begin
  if (gExtAI = nil) then
    Exit(False);

  for K := 0 to gExtAI.Count - 1 do
    if (gExtAI[K].ID = aID) then
      Exit(False);

  gExtAI.Add(TExtAIDelphi.Create(nil,aID));
  Result := True;
end;


// Connect ExtAI to server
function ConnectExtAI(aID, aPort: Word; apIP: PWideChar; aLen: Cardinal): Boolean; StdCall;
var
  K: Integer;
  IP: UnicodeString;
begin
  Result := False;
  // Get IP from string (or we can send IP in Cardinal in future)
  SetLength(IP, aLen);
  Move(apIP^, IP[1], aLen * SizeOf(IP[1]));
  // Connect ExtAI to server
  for K := 0 to gExtAI.Count - 1 do
    if (gExtAI[K].ID = aID) then
    begin
      gExtAI[K].Client.ConnectTo(IP, aPort);
      Result := gExtAI[K].Client.Connected;
    end;
end;


// Exports
exports
  InitDLL,
  TerminDLL,
  CreateNewExtAI,
  ConnectExtAI;


begin

end.
