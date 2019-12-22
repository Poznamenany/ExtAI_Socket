unit ExtAILogDLL;
interface
uses
  Classes, SysUtils,
  ExtAILog;

type
  // DLL logger
  TLogDLL = class
  private
    fFileS: TFileStream;
    fLogs: TStringList;
  public
    fLog: TExtAILog;
    constructor Create();
    destructor Destroy; override;

    property GetTLog: TExtAILog read fLog write fLog;

    procedure Log(const aText: String);
    function RemoveFirstLog(var aText: String): Boolean;
  end;

implementation


const
  LOG_TO_FILE = True;
  LOG_FILE_NAME = 'LOG_ExtAI_Delphi_DLL.txt';


{ TLogDLL }
constructor TLogDLL.Create();
begin
  Inherited Create;
  fLogs := TStringList.Create;
  fFileS := nil;
  if LOG_TO_FILE then
    fFileS := TFileStream.Create(LOG_FILE_NAME, fmCreate OR fmOpenWrite);
  Log('TLogDLL-Create');
  fLog := TExtAILog.Create(Log,False);
end;


destructor TLogDLL.Destroy();
begin
  fLog.Free;
  Log('TLogDLL-Destroy');
  fLogs.Free;
  fFileS.Free;
  Inherited;
end;


procedure TLogDLL.Log(const aText: String);
const
  NEW_LINE: String = #13#10;
begin
  if (Self = nil) then
    Exit;

  fLogs.Add(aText);
  if (fFileS <> nil) then
  begin
    fFileS.Write(aText[1], Length(aText) * SizeOf(aText[1]));
    fFileS.Write(NEW_LINE[1], Length(NEW_LINE) * SizeOf(NEW_LINE[1]));
  end;
end;


function TLogDLL.RemoveFirstLog(var aText: String): Boolean;
begin
  Result := (fLogs.Count > 0);
  if Result then
  begin
    aText := fLogs[0];
    fLogs.Delete(0);
  end;
end;

end.
