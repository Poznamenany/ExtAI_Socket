program ExtAI_Delphi;

uses
  Vcl.Forms,
  ExtAIForm in 'ExtAIForm.pas' {ExtAI},
  ExtAIActions in 'src\ExtAIActions.pas',
  ExtAIEvents in 'src\ExtAIEvents.pas',
  ExtAIStates in 'src\ExtAIStates.pas',
  ExtAIMsgActions in 'src\ExtAIMsgActions.pas',
  ExtAIMsgEvents in 'src\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'src\ExtAIMsgStates.pas',
  ExtAIDelphi in 'src\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'src\ExtAIBaseDelphi.pas',
  ExtAICommonClasses in 'src\net\ExtAICommonClasses.pas',
  ExtAINetClient in 'src\net\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'src\net\ExtAISharedNetworkTypes.pas',
  ExtAISharedInterface in 'src\net\ExtAISharedInterface.pas',
  ExtAILog in 'src\ExtAILog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExtAI, ExtAI);
  Application.Run;
end.
