unit ExtAIEvents;
interface
uses
  Classes, SysUtils,
  ExtAIMsgEvents, ExtAINetClient, ExtAISharedInterface;


// Events of the ExtAI
type
  TExtAIEvents = class
  private
    fEvents: TExtAIMsgEvents;
  public
    constructor Create();
    destructor Destroy(); override;

    property Msg: TExtAIMsgEvents read fEvents;
  end;


implementation


{ TExtAIEvents }
constructor TExtAIEvents.Create();
begin
  Inherited Create;
  fEvents := TExtAIMsgEvents.Create();
end;


destructor TExtAIEvents.Destroy();
begin
  fEvents.Free;
  Inherited;
end;


end.
