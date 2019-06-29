unit ExtAIInfo;
interface
uses
  Classes, Windows, System.SysUtils,
  KM_Consts, ExtAISharedNetworkTypes, ExtAINetServer, ExtAICommonClasses,
  ExtAIMsgActions, ExtAIMsgEvents, ExtAIMsgStates;

type
  TExtAIInfo = class;
  TExtAIStatusEvent = procedure (aServerClient: TExtAIInfo) of object;

  // Contain basic informations about ExtAI and communication interface (maybe exists better name...)
  TExtAIInfo = class
  private
    // Identifiers
    fHandIdx: TKMHandIndex;
    fServerClient: TExtAIServerClient;
    // Actions, Events, States
    fActions: TExtAIMsgActions;
    fEvents: TExtAIMsgEvents;
    fStates: TExtAIMsgStates;
    // ExtAI configuration
    fConfigured: Boolean;
    fAuthor: UnicodeString;
    fName: UnicodeString;
    fDescription: UnicodeString;
    fVersion: Cardinal;
    // Callbacks
    fOnAIConfigured: TExtAIStatusEvent;

    procedure NewCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);

    procedure Log(aLog: UnicodeString);
  public
    constructor Create(aServerClient: TExtAIServerClient);
    destructor Destroy; override;

    // Callbacks
    property OnAIConfigured: TExtAIStatusEvent write fOnAIConfigured;
    // Identifiers
    property HandIdx: TKMHandIndex read fHandIdx write fHandIdx;
    property ServerClient: TExtAIServerClient read fServerClient;
    // Actions, Events, States
    property Actions: TExtAIMsgActions read fActions;
    property Events: TExtAIMsgEvents read fEvents;
    property States: TExtAIMsgStates read fStates;
    // Client cfg
    property Configured: Boolean read fConfigured;
    property Author: UnicodeString read fAuthor;
    property Name: UnicodeString read fName;
    property Description: UnicodeString read fDescription;
    property Version: Cardinal read fVersion;
  end;


implementation
uses
  Log;


{ TExtAIInfo }
constructor TExtAIInfo.Create(aServerClient: TExtAIServerClient);
begin
  inherited Create;
  fActions := TExtAIMsgActions.Create();
  fEvents := TExtAIMsgEvents.Create();
  fStates := TExtAIMsgStates.Create();

  fHandIdx := -1;
  fServerClient := aServerClient;
  fConfigured := False;
  fAuthor := '';
  fName := '';
  fDescription := '';
  fVersion := 0;
  fServerClient.OnCfg := NewCfg;
  fServerClient.OnAction := fActions.ReceiveAction;
  fServerClient.OnState := fStates.NewState;

  fEvents.OnSendEvent := fServerClient.AddScheduledMsg;
  fActions.OnLog := Log;
end;


destructor TExtAIInfo.Destroy();
begin
  fActions.Free;
  fEvents.Free;
  fStates.Free;
  inherited;
end;


procedure TExtAIInfo.NewCfg(aData: Pointer; aTypeCfg, aLength: Cardinal);
var
  M: TKExtAIMsgStream;
begin
  M := TKExtAIMsgStream.Create();
  try
    M.Write(aData^, aLength);
    M.Position := 0;
    case TExtAIMsgTypeCfgAI(aTypeCfg) of
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
    if (Length(fName) <> 0) AND Assigned(fOnAIConfigured) then
    begin
      fConfigured := True;
      fOnAIConfigured(self);
    end;
  finally
    M.Free;
  end;
end;


// Temporary location for logs from actions
procedure TExtAIInfo.Log(aLog: UnicodeString);
begin
  gLog.Log(aLog);
end;


end.
