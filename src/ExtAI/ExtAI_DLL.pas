unit ExtAI_DLL;
interface
uses
  Classes, Windows, System.SysUtils,
  ExtAISharedInterface;

type
  TInitDLL = procedure(var aConfig: TDLLpConfig); StdCall;
  TTerminDLL = procedure(); StdCall;
  TCreateNewExtAI = function(aID: Word): boolean; StdCall;
  TConnectExtAI = function(aID, aPort: Word; apIP: PWideChar; aLen: Cardinal): Boolean; StdCall;


  TDLLMainCfg = record
    Author, Description, ExtAIName, Path: UnicodeString;
    Version: Cardinal;
  end;

  // Communication with 1 physical DLL with using exported methods.
  // Main targets: initialization of 1 physical DLL, creation of ExtAIs and termination of ExtAIs and DLL
  TExtAI_DLL = class
  private
    fDLLConfig: TDLLMainCfg;
    fLibHandle: THandle;

    // DLL Procedures
    fDLLProc_Init: TInitDLL;
    fDLLProc_Terminate: TTerminDLL;
    fDLLProc_CreateNewExtAI: TCreateNewExtAI;
    fDLLProc_ConnectExtAI: TConnectExtAI;

    function LinkDLL(aDLLPath: String): Boolean;
    function GetName(): String;
  public
    constructor Create(aDLLPath: String);
    destructor Destroy; override;

    property Config: TDLLMainCfg read fDLLConfig;
    property Name: String read GetName;

    function ConnectNewExtAI(aID, aPort: Word; aIP: UnicodeString): Boolean;
  end;


implementation
uses
  ExtAILog;


{ TExtAI_DLL }
constructor TExtAI_DLL.Create(aDLLPath: String);
begin
  LinkDLL(aDLLPath);
  gLog.Log('TExtAI_DLL-Create: DLLPath = %s', [aDLLPath]);
end;


destructor TExtAI_DLL.Destroy;
begin
  gLog.Log('TExtAI_DLL-Destroy: ExtAI name = %s', [fDLLConfig.ExtAIName]);

  if Assigned(fDLLProc_Terminate) then
    fDLLProc_Terminate();

  FreeLibrary(fLibHandle);

  inherited;
end;


function TExtAI_DLL.LinkDLL(aDLLPath: String): Boolean;
var
  Err: Integer;
  Cfg: TDLLpConfig;
begin
  Result := False;
  try
    // Check if DLL exits
    if not FileExists(aDLLPath) then
    begin
      gLog.Log('TExtAI_DLL-LinkDLL: DLL file was NOT found');
      Exit;
    end;

    // Load without displaying any pop up error messages
    fLibHandle := SafeLoadLibrary(aDLLPath, $FFFF);
    if fLibHandle = 0 then
    begin
      gLog.Log('TExtAI_DLL-LinkDLL: library was NOT loaded, error: %d', [GetLastError]);
      Exit;
    end;

    // Check error messages
    Err := GetLastError();
    if Err <> 0 then
    begin
      gLog.Log('TExtAI_DLL-LinkDLL: ERROR in the DLL file detected = %d', [Err]);
      Exit;
    end;

    // Connect shared procedures
    fDLLProc_Init := GetProcAddress(fLibHandle, 'InitDLL');
    fDLLProc_Terminate := GetProcAddress(fLibHandle, 'TerminDLL');
    fDLLProc_CreateNewExtAI := GetProcAddress(fLibHandle, 'CreateNewExtAI');
    fDLLProc_ConnectExtAI := GetProcAddress(fLibHandle, 'ConnectExtAI');

    // Check if procedures are assigned
    if not Assigned(fDLLProc_Init)
    or not Assigned(fDLLProc_Terminate)
    or not Assigned(fDLLProc_CreateNewExtAI)
    or not Assigned(fDLLProc_ConnectExtAI) then
    begin
      gLog.Log('TExtAI_DLL-LinkDLL: Exported methods not found');
      Exit;
    end;

    // Get DLL info
    fDLLConfig.Path := aDLLPath;
    fDLLProc_Init(Cfg);
    fDLLConfig.Version := Cfg.Version;
    SetLength(fDLLConfig.Author, Cfg.AuthorLen);
    SetLength(fDLLConfig.Description, Cfg.DescriptionLen);
    SetLength(fDLLConfig.ExtAIName, Cfg.ExtAINameLen);
    Move(Cfg.Author^, fDLLConfig.Author[1], Cfg.AuthorLen * SizeOf(fDLLConfig.Author[1]));
    Move(Cfg.Description^, fDLLConfig.Description[1], Cfg.DescriptionLen * SizeOf(fDLLConfig.Description[1]));
    Move(Cfg.ExtAIName^, fDLLConfig.ExtAIName[1], Cfg.ExtAINameLen * SizeOf(fDLLConfig.ExtAIName[1]));
    gLog.Log('TExtAI_DLL-LinkDLL: DLL detected, Name: %s; Version: %d', [fDLLConfig.ExtAIName, fDLLConfig.Version]);
    Result := True;
  except
    // We failed for whatever unknown reason
    on E: Exception do
    begin
      Result := False;

      // We are not really interested in the Exception message in runtime. Just log it
      gLog.Log('TExtAI_DLL-LinkDLL: Failed with exception "%s"', [E.Message]);
    end;
  end;
end;


function TExtAI_DLL.ConnectNewExtAI(aID, aPort: Word; aIP: UnicodeString): Boolean;
begin
  Result := fDLLProc_CreateNewExtAI(aID) AND fDLLProc_ConnectExtAI(aID, aPort, Addr(aIP[1]), Length(aIP));
  gLog.Log('TExtAI_DLL-CreateNewExtAI: ID = %d', [aID]);
end;


function TExtAI_DLL.GetName(): String;
begin
  Result := Format('DLL: %s',[Config.ExtAIName]);
end;


end.
