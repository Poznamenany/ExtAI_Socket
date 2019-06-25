unit ExtAIMaster;
interface
uses
  Classes, Windows, System.SysUtils, Generics.Collections,
  ExtAINetServer, ExtAIInfo;

type
  // Manages external AI (list of available AIs and communication)
  TExtAIMaster = class
  private
    fNetServer: TExtAINetServer;
    fExtAIs: TList<TExtAIInfo>;

    procedure ConnectExtAI(aServerClient: TExtAIServerClient);
    procedure DisconnectExtAI(aServerClient: TExtAIServerClient);
    procedure ReleaseExtAIs();
    function GetExtAI(aServerClient: TExtAIServerClient): TExtAIInfo;
  public
    constructor Create();
    destructor Destroy; override;

    property Net: TExtAINetServer read fNetServer;
    property AIs: TList<TExtAIInfo> read fExtAIs;

    procedure UpdateState();
  end;


implementation
uses
  Log;


{ TExtAIMaster }
constructor TExtAIMaster.Create();
begin
  inherited;

  fNetServer := TExtAINetServer.Create();
  fExtAIs := TList<TExtAIInfo>.Create();
  fNetServer.OnStatusMessage := gLog.Log;
  fNetServer.OnClientConnect := ConnectExtAI;
  fNetServer.OnClientDisconnect := DisconnectExtAI;
end;


destructor TExtAIMaster.Destroy();
begin
  fNetServer.Free();
  ReleaseExtAIs();
  FreeAndNil(fExtAIs);
  inherited;
end;


procedure TExtAIMaster.ConnectExtAI(aServerClient: TExtAIServerClient);
var
  ExtAI: TExtAIInfo;
begin
  ExtAI := GetExtAI(aServerClient);
  if (ExtAI = nil) then
  begin
    ExtAI := TExtAIInfo.Create(aServerClient);
    fExtAIs.Add(ExtAI);
  end;
end;


procedure TExtAIMaster.DisconnectExtAI(aServerClient: TExtAIServerClient);
var
  ExtAI: TExtAIInfo;
begin
  ExtAI := GetExtAI(aServerClient);
  if (ExtAI <> nil) then
    fExtAIs.Remove(ExtAI);
  ExtAI.Free;
end;


procedure TExtAIMaster.ReleaseExtAIs();
var
  K: Integer;
begin
  for K := 0 to fExtAIs.Count-1 do
    fExtAIs[K].Free;
  fExtAIs.Clear;
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

end.
