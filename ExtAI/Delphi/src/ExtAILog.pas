unit ExtAILog;
interface
uses
  Classes, SysUtils;

type
  TLogEvent = procedure (const aText: string) of object;
  TLogIDEvent = procedure (const aText: string; const aID: Byte) of object;

  // Global logger
  TLog = class
  private
    fID: Byte;
    fOnLog: TLogEvent;
    fOnIDLog: TLogIDEvent;
  public
    constructor Create(aOnLog: TLogEvent); overload;
    constructor Create(aOnLogID: TLogIDEvent; aID: Byte); overload;
    destructor Destroy(); override;
    procedure Log(const aText: string); overload;
    procedure Log(const aText: string; aArgs: array of const); overload;
  end;

var
  gLog: TLog;

implementation


{ TLog }
constructor TLog.Create(aOnLog: TLogEvent);
begin
  inherited Create;

  fID := 0;
  fOnLog := aOnLog;
  fOnIDLog := nil;
  Log('TLog-Create');
end;

constructor TLog.Create(aOnLogID: TLogIDEvent; aID: Byte);
begin
  inherited Create;

  fID := aID;
  fOnLog := nil;
  fOnIDLog := aOnLogID;
  Log('TLog-Create');
end;


destructor TLog.Destroy();
begin
  Log('TLog-Destroy');

  inherited;
end;


procedure TLog.Log(const aText: string);
begin
  if Self = nil then Exit;

  if Assigned(fOnLog) then
    TThread.Synchronize(nil,
      procedure
      begin
        fOnLog(aText);
      end
    )
  else if Assigned(fOnIDLog) then
    TThread.Synchronize(nil,
      procedure
      begin
        fOnIDLog(aText, fID);
      end
    );
end;


procedure TLog.Log(const aText: string; aArgs: array of const);
begin
  Log(Format(aText, aArgs));
end;


end.
