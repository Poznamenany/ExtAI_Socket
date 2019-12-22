unit ExtAILog;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes;

type
  TLogEvent = procedure (const aText: string) of object;
  TLogIDEvent = procedure (const aText: string; const aID: Byte) of object;

  // Global logger
  TExtAILog = class
  private
    fSynchronize: Boolean;
    fID: Byte;
    fOnLog: TLogEvent;
    fOnIDLog: TLogIDEvent;
  public
    constructor Create(aOnLog: TLogEvent; aSynchronize: Boolean = True); overload;
    constructor Create(aOnLogID: TLogIDEvent; aID: Byte; aSynchronize: Boolean = True); overload;
    destructor Destroy(); override;
    procedure Log(const aText: string); overload;
    procedure Log(const aText: string; const aArgs: array of const); overload;
  end;

var
  gLog: TExtAILog;

implementation


{ TLog }
constructor TExtAILog.Create(aOnLog: TLogEvent; aSynchronize: Boolean = True);
begin
  Inherited Create;

  fSynchronize := aSynchronize;
  fID := 0;
  fOnLog := aOnLog;
  fOnIDLog := nil;
  Log('TExtAILog-Create');
end;

constructor TExtAILog.Create(aOnLogID: TLogIDEvent; aID: Byte; aSynchronize: Boolean = True);
begin
  Inherited Create;

  fSynchronize := aSynchronize;
  fID := aID;
  fOnLog := nil;
  fOnIDLog := aOnLogID;
  Log('TExtAILog-Create');
end;


destructor TExtAILog.Destroy();
begin
  Log('TExtAILog-Destroy');

  Inherited;
end;


procedure TExtAILog.Log(const aText: string);
begin
  if (Self = nil) then
    Exit;

  if Assigned(fOnLog) then
  begin
    // Logs in DLLs do not need to synchronize because they are stored to buffer
    if not fSynchronize then
      fOnLog(aText)
    else
    // Logs in threads need to synchronize because they are stored to GUI in a different thread
      TThread.Synchronize(nil,
        procedure
        begin
          fOnLog(aText);
        end
      )
  end
  else if Assigned(fOnIDLog) then
  begin
    if not fSynchronize then
      fOnIDLog(aText, fID)
    else
      TThread.Synchronize(nil,
        procedure
        begin
          fOnIDLog(aText, fID);
        end
      );
  end;
end;


procedure TExtAILog.Log(const aText: string; const aArgs: array of const);
begin
  if (Self = nil) then
    Exit;

  Log(Format(aText, aArgs));
end;


end.
