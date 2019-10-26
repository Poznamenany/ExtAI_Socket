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
  public
    constructor Create(aDLLPaths: TArray<string>);

    procedure RefreshList(aPaths: TArray<string>);
    function DLLExists(const aDLLPath: WideString): Boolean;
  end;


implementation
uses
  ExtAILog;


{ TExtAIDLLs }
constructor TExtAIDLLs.Create(aDLLPaths: TArray<string>);
begin
  inherited Create;

  RefreshList(aDLLPaths); // Find available DLL (public method for possibility to reload DLLs)
end;


procedure TExtAIDLLs.RefreshList(aPaths: TArray<string>);
var
  I: Integer;
  subFolder, fileDLL: string;
begin
  Clear();
  fileDLL := GetCurrentDir;
  for I := Low(aPaths) to High(aPaths) do
    if DirectoryExists(aPaths[I]) then
      for subFolder in TDirectory.GetDirectories(aPaths[I]) do
        for fileDLL in TDirectory.GetFiles(subFolder) do
          if ExtractFileExt(fileDLL) = '.dll' then
          begin
            gLog.Log('TExtAIDLLs: New DLL - ' + fileDLL);
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