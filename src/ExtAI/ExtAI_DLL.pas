unit ExtAI_DLL;
interface
uses
  Classes, Windows, System.SysUtils,
  ExtAISharedInterface;

type
  TInitializeDLL = procedure(var aConfig: TDLLpConfig); StdCall;
  TTerminateDLL = procedure(); StdCall;
  TCreateExtAI = function(aID, aPort: Word; apIP: PWideChar; aLen: Cardinal): boolean; StdCall;
  TTerminateExtAI = function(aID: Word): Boolean; StdCall;
  TGetFirstLog = function(var aLog: PWideChar; var aLength: Cardinal): Boolean; StdCall;

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
    fDLLProc_InitDLL: TInitializeDLL;
    fDLLProc_TerminateDLL: TTerminateDLL;
    fDLLProc_CreateExtAI: TCreateExtAI;
    fDLLProc_TerminateExtAI: TTerminateExtAI;
    fDLLProc_GetFirstLog: TGetFirstLog;

    function LinkDLL(aDLLPath: String): Boolean;
    function GetName(): String;
  public
    constructor Create(aDLLPath: String);
    destructor Destroy; override;

    property Config: TDLLMainCfg read fDLLConfig;
    property Name: String read GetName;

    function CreateNewExtAI(aID, aPort: Word; aIP: UnicodeString): Boolean;
    function TerminateExtAI(aID: Word): Boolean;
    function GetAILog(var aLog: String): Boolean;
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

  if Assigned(fDLLProc_TerminateDLL) then
    fDLLProc_TerminateDLL();

  FreeLibrary(fLibHandle);

  Inherited;
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
    fDLLProc_InitDLL := GetProcAddress(fLibHandle, 'InitializeDLL');
    fDLLProc_TerminateDLL := GetProcAddress(fLibHandle, 'TerminateDLL');
    fDLLProc_CreateExtAI := GetProcAddress(fLibHandle, 'CreateExtAI');
    fDLLProc_TerminateExtAI := GetProcAddress(fLibHandle, 'TerminateExtAI');
    fDLLProc_GetFirstLog := GetProcAddress(fLibHandle, 'GetFirstLog');

    // Check if procedures are assigned
    if not Assigned(fDLLProc_InitDLL)
    or not Assigned(fDLLProc_TerminateDLL)
    or not Assigned(fDLLProc_CreateExtAI)
    or not Assigned(fDLLProc_TerminateExtAI)
    or not Assigned(fDLLProc_GetFirstLog) then
    begin
      gLog.Log('TExtAI_DLL-LinkDLL: Exported methods not found');
      Exit;
    end;

    // Get DLL info
    fDLLConfig.Path := aDLLPath;
    fDLLProc_InitDLL(Cfg);
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


function TExtAI_DLL.CreateNewExtAI(aID, aPort: Word; aIP: UnicodeString): Boolean;
begin
  if not Assigned(fDLLProc_CreateExtAI) then
    Exit(False);

  // Connect ExtAI from the main thread - this call creates Overbyte client (new thread)
  // If Synchronize or critical section is not used then the connection will not be initialized
  TThread.Synchronize(nil,
    procedure
    begin
      fDLLProc_CreateExtAI(aID, aPort, Addr(aIP[1]), Length(aIP));
    end
  );
  Result := True;
  gLog.Log('TExtAI_DLL-CreateNewExtAI: ID = %d', [aID]);
end;


function TExtAI_DLL.TerminateExtAI(aID: Word): Boolean;
begin
  if not Assigned(fDLLProc_TerminateExtAI) then
    Exit(False);

  // Connect ExtAI from the main thread - this call creates Overbyte client (new thread)
  // If Synchronize or critical section is not used then the connection will not be initialized
  TThread.Synchronize(nil,
    procedure
    begin
      fDLLProc_TerminateExtAI(aID);
    end
  );
  Result := True;
  gLog.Log('TExtAI_DLL-TerminateExtAI: ID = %d', [aID]);
end;


function TExtAI_DLL.GetName(): String;
begin
  Result := Format('DLL: %s',[Config.ExtAIName]);
end;


function TExtAI_DLL.GetAILog(var aLog: String): Boolean;
var
  Length: Cardinal;
  pLog: PWideChar;
begin
  Result := False;
  if not Assigned(fDLLProc_GetFirstLog) then
    Exit(False);

  if fDLLProc_GetFirstLog(pLog, Length) AND (Length > 0) then
  begin
    SetLength(aLog, Length);
    Move(pLog^, aLog[1], Length * SizeOf(aLog[1]));
    Result := True;
  end;
end;


end.
