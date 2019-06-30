program WebSocketTest;

uses
  Vcl.Forms,
  Form in 'Form.pas' {ExtAI_TestBed},
  Game in 'src\Game.pas',
  KM_Consts in 'src\KM_Consts.pas',
  ExtAINetServer in 'src\ExtAI\ExtAINetServer.pas',
  ExtAINetworkTypes in 'src\ExtAI\ExtAINetworkTypes.pas',
  ExtAIMaster in 'src\ExtAI\ExtAIMaster.pas',
  ExtAIInfo in 'src\ExtAI\ExtAIInfo.pas',
  Hand in 'src\Hand.pas',
  HandAI_Ext in 'src\HandAI_Ext.pas',
  NetServerOverbyte in 'src\ExtAI\NetServerOverbyte.pas',
  ExtAILog in 'ExtAI\Delphi\src\ExtAILog.pas',
  ExtAIActions in 'ExtAI\Delphi\src\ExtAIActions.pas',
  ExtAIEvents in 'ExtAI\Delphi\src\ExtAIEvents.pas',
  ExtAIStates in 'ExtAI\Delphi\src\ExtAIStates.pas',
  ExtAIMsgActions in 'ExtAI\Delphi\src\ExtAIMsgActions.pas',
  ExtAIMsgEvents in 'ExtAI\Delphi\src\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'ExtAI\Delphi\src\ExtAIMsgStates.pas',
  ExtAIDelphi in 'ExtAI\Delphi\src\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'ExtAI\Delphi\src\ExtAIBaseDelphi.pas',
  ExtAINetClient in 'ExtAI\Delphi\src\net\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'ExtAI\Delphi\src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'ExtAI\Delphi\src\net\ExtAISharedNetworkTypes.pas',
  ExtAICommonClasses in 'ExtAI\Delphi\src\net\ExtAICommonClasses.pas',
  ExtAISharedInterface in 'ExtAI\Delphi\src\net\ExtAISharedInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExtAI_TestBed, ExtAI_TestBed);
  Application.Run;
end.
