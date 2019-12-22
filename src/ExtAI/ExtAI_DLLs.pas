unit ExtAI_DLLs;
interface
uses
  IOUtils, Classes, System.SysUtils, Generics.Collections,
  ExtAI_DLL, ExtAISharedInterface;

  // Expected folder structure:
  // - ExtAI
  //   - dll_delphi
  //     - dll_delphi.dll
  //   - dll_c
  //     - dll_c.dll

type
  // List available DLLs
  // Check presence of all valid DLLs (in future it can also check CRC, save info etc.)
  TExtAIDLLs = class(TObjectList<TExtAI_DLL>)
  private
    fPaths: TStringList;
  public
    constructor Create(aDLLPaths: TStringList);
    destructor Destroy(); override;

    property Paths: TStringList read fPaths;

    procedure RefreshList(aPaths: TStringList = nil);
    function DLLExists(const aDLLPath: WideString): Boolean;
  end;


implementation
uses
  ExtAILog;


const
// Default paths for searching ExtAIs in DLL
  DEFAULT_PATHS: TArray<string> = ['ExtAI\','..\..\..\ExtAI\','..\..\..\ExtAI\Delphi\Win32','..\..\ExtAI\Delphi\Win32'];


{ TExtAIDLLs }
constructor TExtAIDLLs.Create(aDLLPaths: TStringList);
var
  Path: String;
begin
  Inherited Create;

  fPaths := TStringList.Create();
  for Path in DEFAULT_PATHS do // Copy from generic to standard class
    fPaths.Add(Path);

  RefreshList(aDLLPaths); // Find available DLL (public method for possibility to reload DLLs)
end;

destructor TExtAIDLLs.Destroy();
begin
  fPaths.Free;
  Inherited;
end;


procedure TExtAIDLLs.RefreshList(aPaths: TStringList = nil);
var
  K: Integer;
  subFolder, fileDLL: string;
begin
  Clear();
  if (aPaths <> nil) then
  begin
    fPaths.Clear();
    fPaths.Capacity := aPaths.Count;
    for K := 0 to aPaths.Count - 1 do
      fPaths.Add(aPaths[K]);
  end;

  fileDLL := GetCurrentDir;
  for K := 0 to fPaths.Count - 1 do
    if DirectoryExists(fPaths[K]) then
      for subFolder in TDirectory.GetDirectories(fPaths[K]) do
        for fileDLL in TDirectory.GetFiles(subFolder) do
          if ExtractFileExt(fileDLL) = '.dll' then
          begin
            gLog.Log('TExtAIDLLs: New DLL - %s', [fileDLL]);
            Add(TExtAI_DLL.Create(fileDLL));
          end;
end;


function TExtAIDLLs.DLLExists(const aDLLPath: WideString): Boolean;
var
  K: Integer;
begin
  Result := False;
  for K := 0 to Count-1 do
    if CompareStr(Items[K].Config.Path, aDLLPath) = 0 then
      Exit(True);
end;


end.