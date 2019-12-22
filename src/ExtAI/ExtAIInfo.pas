unit ExtAIInfo;
interface
uses
  Classes, Windows, System.SysUtils,
  KM_Consts, ExtAISharedNetworkTypes, ExtAINetServer, ExtAICommonClasses;

type
  TExtAIInfo = class;
  TExtAIStatusEvent = procedure (aExtAIInfo: TExtAIInfo) of object;

  // Contain basic informations about ExtAI and communication interface (maybe exists better name...)
  TExtAIInfo = class
  private
    // Identifiers
    fID: Word; // The main identifier of the ExtAI (hands are not available or the client disconnects and connects)
    fHandIdx: TKMHandIndex; // Game identifier (after hands are created)
    fServerClient: TExtAIServerClient; // Websocket identifier (when connection is established)
    fSourceIsDLL: Boolean; // ExtAI is called from DLL
    // ExtAI configuration
    fAuthor: UnicodeString;
    fName: UnicodeString;
    fDescription: UnicodeString;
    fVersion: Cardinal;
    // Callbacks
    fOnAIConfigured: TExtAIStatusEvent;

    function GetName(): String;
    procedure ChangeServerClient(aServerClient: TExtAIServerClient);
    procedure NewCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
  public
    constructor Create(aID: Word = 0; aServerClient: TExtAIServerClient = nil);
    destructor Destroy; override;

    // Identifiers
    property ID: Word read fID;
    property HandIdx: TKMHandIndex read fHandIdx write fHandIdx;
    property ServerClient: TExtAIServerClient read fServerClient write ChangeServerClient;
    property SourceIsDLL: Boolean read fSourceIsDLL;
    // Client cfg
    property Author: UnicodeString read fAuthor;
    property Name: UnicodeString read GetName;
    property Description: UnicodeString read fDescription;
    property Version: Cardinal read fVersion;
    // Callbacks
    property OnAIConfigured: TExtAIStatusEvent write fOnAIConfigured;
    // Functions
    function ReadyForGame(): Boolean;
  end;


implementation
uses
  ExtAILog;


{ TExtAIInfo }
// Constructor have 2 options:
// 1. AI is created in DLL => TExtAIInfo is created before client then the client is connected and synchronization is required
// 2. AI is compiled to exe => TExtAIInfo after connection of the ExtAI so TExtAIServerClient is already available
constructor TExtAIInfo.Create(aID: Word = 0; aServerClient: TExtAIServerClient = nil);
begin
  Inherited Create;

  fID := aID;
  fHandIdx := -1;
  fServerClient := aServerClient;
  fAuthor := '';
  fName := '';
  fDescription := '';
  fVersion := 0;
  fSourceIsDLL := (aServerClient = nil);
  ChangeServerClient(aServerClient);
  gLog.Log('ExtAIInfo-Create, ID = %d', [ID]);
end;


destructor TExtAIInfo.Destroy();
begin
  fServerClient := nil;
  gLog.Log('ExtAIInfo-Destroy, ID = %d', [ID]);
  Inherited;
end;


function TExtAIInfo.GetName(): String;
begin
  if (fServerClient = nil) then
    Result := Format('%s',[fName])
  else
    Result := Format('%s %d',[fName,fServerClient.Handle]);
end;


procedure TExtAIInfo.ChangeServerClient(aServerClient: TExtAIServerClient);
begin
  fServerClient := aServerClient;
  if (fServerClient <> nil) then
    fServerClient.OnCfg := NewCfg;
end;


procedure TExtAIInfo.NewCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
var
  CfgFull: Boolean;
  M: TKExtAIMsgStream;
begin
  CfgFull := ReadyForGame();
  M := TKExtAIMsgStream.Create();
  try
    M.Write(aData^, aLength);
    M.Position := 0;
    case TExtAIMsgTypeCfgAI(aTypeCfg) of
      caID:
      begin
        M.Read(fID);
        gLog.Log('ExtAIInfo ID: %d',[fID]);
      end;
      caAuthor:
      begin
        M.ReadW(fAuthor);
        gLog.Log('ExtAIInfo author: %s',[fAuthor]);
      end;
      caName:
      begin
        M.ReadW(fName);
        gLog.Log('ExtAIInfo name: %s',[fName]);
      end;
      caDescription:
      begin
        M.ReadW(fDescription);
        gLog.Log('ExtAIInfo description: %s',[fDescription]);
      end;
      caVersion:
      begin
        M.Read(fVersion);
        gLog.Log('ExtAIInfo version = %d',[fVersion]);
      end;
      else
        gLog.Log('ExtAIInfo Unknown configuration');
    end;
  finally
    M.Free;
  end;
  // If config was fullfilled in this step, then use callback
  if not CfgFull AND ReadyForGame() AND Assigned(fOnAIConfigured) then
    fOnAIConfigured(self);
end;


function TExtAIInfo.ReadyForGame(): Boolean;
begin
  Result := (AnsiCompareText(fName,'') <> 0) AND (ID > 0) AND (ServerClient <> nil);
end;


end.
