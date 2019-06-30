program WebSocketTest;

uses
  Vcl.Forms,
  Form in 'Form.pas' {ExtAI_TestBed},
  Log in 'src\Log.pas',
  Game in 'src\Game.pas',
  KM_Consts in 'src\KM_Consts.pas',
  ExtAINetServer in 'src\ExtAI\ExtAINetServer.pas',
  ExtAINetworkTypes in 'src\ExtAI\ExtAINetworkTypes.pas',
  ExtAIMaster in 'src\ExtAI\ExtAIMaster.pas',
  ExtAIInfo in 'src\ExtAI\ExtAIInfo.pas',
  ExtAIMsgEvents in 'ExtAI\Delphi\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'ExtAI\Delphi\ExtAIMsgStates.pas',
  Hand in 'src\Hand.pas',
  HandAI_Ext in 'src\HandAI_Ext.pas',
  NetServerOverbyte in 'src\ExtAI\NetServerOverbyte.pas',
  ExtAICommonClasses in 'ExtAI\Delphi\ExtAICommonClasses.pas',
  ExtAIDelphi in 'ExtAI\Delphi\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'ExtAI\Delphi\ExtAIBaseDelphi.pas',
  ExtAINetClient in 'ExtAI\Delphi\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'ExtAI\Delphi\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'ExtAI\Delphi\ExtAISharedNetworkTypes.pas',
  ExtAIActions in 'ExtAI\Delphi\ExtAIActions.pas',
  ExtAIMsgActions in 'ExtAI\Delphi\ExtAIMsgActions.pas',
  ExtAIEvents in 'ExtAI\Delphi\ExtAIEvents.pas',
  ExtAIStates in 'ExtAI\Delphi\ExtAIStates.pas',
  ExtAISharedInterface in 'ExtAI\Delphi\ExtAISharedInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExtAI_TestBed, ExtAI_TestBed);
  Application.Run;
end.
