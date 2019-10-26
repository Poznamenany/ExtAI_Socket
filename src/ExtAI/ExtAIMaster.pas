unit ExtAIMaster;
interface
uses
  Classes, Windows, Math, System.SysUtils, Generics.Collections,
  ExtAI_DLLs, ExtAINetServer, ExtAIInfo, KM_CommonTypes;

type
  // Manages external AI (list of available AIs and communication)
  TExtAIMaster = class
  private
    fNetServer: TExtAINetServer;
    fExtAIs: TList<TExtAIInfo>;
    fDLLs: TExtAIDLLs;
    fIDCounter: Word;

    // Callbacks
    fOnAIConnect: TExtAIStatusEvent;
    fOnAIConfigured: TExtAIStatusEvent;
    fOnAIDisconnect: TExtAIStatusEvent;
    procedure ConnectExtAIWithID(aServerClient: TExtAIServerClient; aID: Word);
    procedure DisconnectClient(aServerClient: TExtAIServerClient);
    function CreateNewExtAI(aID: Word; aServerClient: TExtAIServerClient): TExtAIInfo;
    procedure ReleaseExtAIs();
    procedure ConfiguredExtAI(aExtAIInfo: TExtAIInfo);
    function GetExtAI(aID: Word): TExtAIInfo; overload;
    function GetExtAI(aServerClient: TExtAIServerClient): TExtAIInfo; overload;
  public
    constructor Create(aDLLPaths: TArray<string>);
    destructor Destroy; override;

    property OnAIConnect: TExtAIStatusEvent write fOnAIConnect;
    property OnAIConfigured: TExtAIStatusEvent write fOnAIConfigured;
    property OnAIDisconnect: TExtAIStatusEvent write fOnAIDisconnect;
    property Net: TExtAINetServer read fNetServer;
    property AIs: TList<TExtAIInfo> read fExtAIs;
    property DLLs: TExtAIDLLs read fDLLs;

    procedure UpdateState();
    function GetExtAIClientNames(): TStringArray;
    function GetExtAIDLLNames(): TStringArray;
    function GetNewID(): Word;
    function ConnectNewExtAI(aIdxDLL: Word): Word;
  end;


implementation
uses
  ExtAILog;


{ TExtAIMaster }
// aDLLPaths should be like 'ExeDir\ExtAI\'.
// We will scan 1 folder deep, since it'a handy to have each ExtAI DLL in it's own folder
constructor TExtAIMaster.Create(aDLLPaths: TArray<string>);
begin
  fIDCounter := 0;
  fNetServer := TExtAINetServer.Create();
  fExtAIs := TList<TExtAIInfo>.Create();
  fDLLs := TExtAIDLLs.Create(aDLLPaths);
  fNetServer.OnStatusMessage := gLog.Log;
  fNetServer.OnClientConnect := nil; // Ignore incoming client till the moment when we receive config
  fNetServer.OnClientNewID := ConnectExtAIWithID;
  fNetServer.OnClientDisconnect := DisconnectClient;
end;


destructor TExtAIMaster.Destroy();
begin
  fDLLs.Free();
  fNetServer.Free();
  ReleaseExtAIs();
  FreeAndNil(fExtAIs);
  inherited;
end;


function TExtAIMaster.GetNewID(): Word;
begin
  Inc(fIDCounter);
  Result := fIDCounter;
end;


procedure TExtAIMaster.ConnectExtAIWithID(aServerClient: TExtAIServerClient; aID: Word);
var
  ExtAI: TExtAIInfo;
begin
  // Try to find AI according to ID (DLL creates class of ExtAI before the AI is connected)
  ExtAI := GetExtAI(aID);
  if (ExtAI <> nil) then
      ExtAI.ServerClient := aServerClient
  // Try to find AI according to pointer to client class
  else
  begin
    ExtAI := GetExtAI(aServerClient);
    // AI was not found -> create new TExtAIInfo class
    if (ExtAI = nil) then
      CreateNewExtAI(aID, aServerClient);
  end;
  if Assigned(fOnAIConnect) then
    fOnAIConnect(ExtAI);
end;


procedure TExtAIMaster.ConfiguredExtAI(aExtAIInfo: TExtAIInfo);
begin
  if Assigned(fOnAIConfigured) then
    fOnAIConfigured(aExtAIInfo);
  fIDCounter := Max(fIDCounter+1,aExtAIInfo.ID);
end;


function TExtAIMaster.ConnectNewExtAI(aIdxDLL: Word): Word;
begin
  Result := GetNewID();
  CreateNewExtAI(Result, nil);
  DLLs[aIdxDLL].ConnectNewExtAI(Result, Net.Server.Socket.PortNum, '127.0.0.1');// DLLs use localhost
end;


procedure TExtAIMaster.DisconnectClient(aServerClient: TExtAIServerClient);
var
  ExtAI: TExtAIInfo;
begin
  //{
  ExtAI := GetExtAI(aServerClient);
  if (ExtAI <> nil) then
    ExtAI.ServerClient := nil;
    //fExtAIs.Remove(ExtAI);
  if Assigned(fOnAIDisconnect) then
    fOnAIDisconnect(ExtAI);
  //ExtAI.Free;
  //}
end;


function TExtAIMaster.CreateNewExtAI(aID: Word; aServerClient: TExtAIServerClient): TExtAIInfo;
begin
  Result := TExtAIInfo.Create(aID, aServerClient);
  Result.OnAIConfigured := ConfiguredExtAI;
  fExtAIs.Add(Result);
end;


procedure TExtAIMaster.ReleaseExtAIs();
var
  K: Integer;
begin
  for K := 0 to fExtAIs.Count-1 do
    fExtAIs[K].Free;
  fExtAIs.Clear;
end;


function TExtAIMaster.GetExtAI(aID: Word): TExtAIInfo;
var
  K: Integer;
begin
  Result := nil;
  for K := 0 to fExtAIs.Count - 1 do
    if (fExtAIs[K].ID = aID) then
      Exit(fExtAIs[K]);
end;


function TExtAIMaster.GetExtAI(aServerClient: TExtAIServerClient): TExtAIInfo;
var
  K: Integer;
begin
  Result := nil;
  for K := 0 to fExtAIs.Count-1 do
    if (fExtAIs[K].ServerClient = aServerClient) then
      Exit(fExtAIs[K]);
end;


procedure TExtAIMaster.UpdateState();
begin
  if (fNetServer <> nil) AND (fNetServer.Listening) then
    fNetServer.UpdateState();
end;


// Get names of connected clients
function TExtAIMaster.GetExtAIClientNames(): TStringArray;
var
  K, Cnt: Integer;
begin
  Cnt := 0;
  SetLength(Result, fExtAIs.Count);
  for K := 0 to fExtAIs.Count-1 do
    if AIs[K].ReadyForGame then
    begin
      Result[Cnt] := AIs[K].Name;
      Cnt := Cnt + 1;
    end;
  SetLength(Result, Cnt);
end;


// Get name of available DLLs (DLL can generate infinite amount of ExtAIs)
function TExtAIMaster.GetExtAIDLLNames(): TStringArray;
var
  K: Integer;
begin
  SetLength(Result, fDLLs.Count);
  for K := 0 to fDLLs.Count-1 do
    Result[K] := fDLLs[K].Name;
end;


end.

