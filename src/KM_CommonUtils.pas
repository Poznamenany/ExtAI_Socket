unit KM_CommonUtils;
interface
uses
  MMSystem;

  function TimeGet(): Cardinal;
  function GetTimeSince(aTime: Cardinal): Cardinal;

implementation


function TimeGet(): Cardinal;
begin
  Result := TimeGetTime; // Return milliseconds with ~1ms precision
end;


function GetTimeSince(aTime: Cardinal): Cardinal;
begin
  // TimeGet will loop back to zero after ~49 days since system start
  Result := (Int64(TimeGet()) - Int64(aTime) + Int64(High(Cardinal))) mod Int64(High(Cardinal));
end;


end.