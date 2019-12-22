unit KM_Hand;
interface
uses
  Windows, System.SysUtils,
  KM_Consts, KM_HandAI_Ext, ExtAIInfo;

type
  // Game class for Hand. It hides the ExtAI inside of it
  TKMHand = class
  private
    fHandIndex: TKMHandIndex;
    fAIExt: THandAI_Ext;
  public
    constructor Create(aHandIndex: TKMHandIndex); reintroduce;
    destructor Destroy; override;

    property AIExt: THandAI_Ext read fAIExt;
    property HandIndex: TKMHandIndex read fHandIndex;

    // KP sets AI type after init
    procedure SetAIType(aExtAI: TExtAIInfo);

    procedure UpdateState(aTick: Cardinal);
  end;


implementation
uses
  ExtAILog;


{ TKMHand }
constructor TKMHand.Create(aHandIndex: TKMHandIndex);
begin
  Inherited Create;

  fHandIndex := aHandIndex;
  fAIExt := nil;

  gLog.Log('THand-Create: HandIndex = %d', [fHandIndex]);
end;


destructor TKMHand.Destroy;
begin
  FreeAndNil(fAIExt);
  gLog.Log('THand-Destroy: HandIndex = %d', [fHandIndex]);

  Inherited;
end;


procedure TKMHand.SetAIType(aExtAI: TExtAIInfo);
begin
  fAIExt := THandAI_Ext.Create(fHandIndex, aExtAI);
end;


procedure TKMHand.UpdateState(aTick: Cardinal);
begin
  if (fAIExt <> nil) then
    fAIExt.UpdateState(aTick);
end;


end.
