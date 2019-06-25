unit HandAI_Ext;
interface
uses
  Windows, System.SysUtils,
  Consts, ExtAIMsgEvents;

type
  // Main AI class in the hands
  TKMHandAI = class
  protected
    fHandIndex: TKMHandIndex;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    property HandIndex: TKMHandIndex read fHandIndex;
  end;

  // Special class for ExtAI in the hands
  THandAI_Ext = class(TKMHandAI)
  private
    fEvents: TExtAIMsgEvents;
  public
    constructor Create(aHandIndex: TKMHandIndex);
    destructor Destroy(); override;

    property Events: TExtAIMsgEvents read fEvents write fEvents;
  end;


implementation
uses
  Log;

{ TKMHandAI }
constructor TKMHandAI.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;
end;


{ THandAI_Ext }
constructor THandAI_Ext.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create(aHandIndex);

  fEvents := nil;
  gLog.Log('THandAIExt-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THandAI_Ext.Destroy();
begin
  fEvents := nil;
  gLog.Log('THandAIExt-Destroy: HandIndex = ' + IntToStr(fHandIndex));
  inherited;
end;


end.
