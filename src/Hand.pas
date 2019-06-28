unit Hand;
interface
uses
  Windows, System.SysUtils,
  Consts, HandAI_Ext;

type
  // Game class for Hand. It hides the ExtAI inside of it
  THand = class
  private
    fHandIndex: TKMHandIndex;
    fAIExt: THandAI_Ext;
  public
    constructor Create(aHandIndex: TKMHandIndex); reintroduce;
    destructor Destroy; override;

    property AIExt: THandAI_Ext read fAIExt;
    property HandIndex: TKMHandIndex read fHandIndex;

    // KP sets AI type after init
    procedure SetAIType;

    procedure UpdateState(aTick: Cardinal);
  end;

implementation
uses
  Log;


{ THand }
constructor THand.Create(aHandIndex: TKMHandIndex);
begin
  inherited Create;

  fHandIndex := aHandIndex;

  fAIExt := nil;

  gLog.Log('  THand-Create: HandIndex = ' + IntToStr(fHandIndex));
end;


destructor THand.Destroy();
begin
  FreeAndNil(fAIExt);
  gLog.Log('  THand-Destroy: HandIndex = ' + IntToStr(fHandIndex));

  inherited;
end;


procedure THand.SetAIType();
begin
  fAIExt := THandAI_Ext.Create(fHandIndex);
end;


procedure THand.UpdateState(aTick: Cardinal);
begin
  if (aTick = FIRST_TICK) then
    fAIExt.Events.MissionStartW();

  fAIExt.Events.TickW(aTick);
end;


end.
