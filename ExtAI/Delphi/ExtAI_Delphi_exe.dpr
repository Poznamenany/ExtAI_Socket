program ExtAI_Delphi_exe;

uses
  Vcl.Forms,
  ExtAIForm in 'ExtAIForm.pas' {ExtAI},
  ExtAILog in 'src\ExtAILog.pas',
  ExtAIDelphi in 'src\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'src\ExtAIBaseDelphi.pas',
  ExtAIActions in 'src\interface\ExtAIActions.pas',
  ExtAIEvents in 'src\interface\ExtAIEvents.pas',
  ExtAIStates in 'src\interface\ExtAIStates.pas',
  ExtAIMsgActions in 'src\interface\ExtAIMsgActions.pas',
  ExtAIMsgEvents in 'src\interface\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'src\interface\ExtAIMsgStates.pas',
  ExtAIStatesTerrain in 'src\interface\ExtAIStatesTerrain.pas',
  ExtAISharedInterface in 'src\interface\ExtAISharedInterface.pas',
  ExtAICommonClasses in 'src\net\ExtAICommonClasses.pas',
  ExtAINetClient in 'src\net\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'src\net\ExtAISharedNetworkTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExtAI, ExtAI);
  Application.Run;
end.
