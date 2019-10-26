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
constructor TExtAIInfo.Create(aID: Word = 0; aServerClient: TExtAIServerClient = nil);
begin
  inherited Create;

  fID := aID;
  fHandIdx := -1;
  fServerClient := aServerClient;
  fAuthor := '';
  fName := '';
  fDescription := '';
  fVersion := 0;
  ChangeServerClient(aServerClient);
end;


destructor TExtAIInfo.Destroy();
begin
  fServerClient := nil;
  inherited;
end;


function TExtAIInfo.GetName(): String;
begin
  if (fServerClient = nil) then
    Result := format('%s',[fName])
  else
    Result := format('%s %d',[fName,fServerClient.Handle]);
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
        gLog.Log('ExtAIInfo ID: ' + IntToStr(fID));
      end;
      caAuthor:
      begin
        M.ReadW(fAuthor);
        gLog.Log('ExtAIInfo author: ' + fAuthor);
      end;
      caName:
      begin
        M.ReadW(fName);
        gLog.Log('ExtAIInfo name: ' + fName);
      end;
      caDescription:
      begin
        M.ReadW(fDescription);
        gLog.Log('ExtAIInfo description: ' + fDescription);
      end;
      caVersion:
      begin
        M.Read(fVersion);
        gLog.Log('ExtAIInfo version = ' + IntToStr(fVersion));
      end;
      else
        gLog.Log('ExtAIInfo Unknown configuration');
    end;
  finally
    M.Free;
  end;
  if not CfgFull AND ReadyForGame() AND Assigned(fOnAIConfigured) then
    fOnAIConfigured(self);
end;


function TExtAIInfo.ReadyForGame(): Boolean;
begin
  Result := (AnsiCompareText(fName,'') <> 0) AND (ID > 0) AND (ServerClient <> nil);
end;


end.
