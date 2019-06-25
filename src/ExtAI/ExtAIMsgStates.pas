unit ExtAIMsgStates;
interface
uses
  Classes, Windows, System.SysUtils,
  Consts, ExtAISharedNetworkTypes, ExtAINetServer;

type
  TExtAIMsgStates = class
  private

  public
    constructor Create();
    destructor Destroy; override;

    procedure NewState(aData: Pointer; aTypeState, aLength: Cardinal);
  end;


implementation
uses
  Log;


{ TExtAIMsgStates }
constructor TExtAIMsgStates.Create();
begin
  inherited Create;

end;


destructor TExtAIMsgStates.Destroy();
begin

  inherited;
end;


procedure TExtAIMsgStates.NewState(aData: Pointer; aTypeState, aLength: Cardinal);
begin

end;



end.
