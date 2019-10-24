program WebSocketTest;
uses
  Vcl.Forms,
  TestBed in 'TestBed.pas' {ExtAI_TestBed},
  KM_Game in 'src\KM_Game.pas',
  KM_CommonTypes in 'src\KM_CommonTypes.pas',
  KM_CommonUtils in 'src\KM_CommonUtils.pas',
  KM_Consts in 'src\KM_Consts.pas',
  KM_Hand in 'src\KM_Hand.pas',
  KM_HandAI_Ext in 'src\KM_HandAI_Ext.pas',
  KM_Terrain in 'src\KM_Terrain.pas',
  ExtAINetServer in 'src\ExtAI\ExtAINetServer.pas',
  ExtAINetworkTypes in 'src\ExtAI\ExtAINetworkTypes.pas',
  ExtAIMaster in 'src\ExtAI\ExtAIMaster.pas',
  ExtAIInfo in 'src\ExtAI\ExtAIInfo.pas',
  NetServerOverbyte in 'src\ExtAI\NetServerOverbyte.pas',
  ExtAILog in 'ExtAI\Delphi\src\ExtAILog.pas',
  ExtAIDelphi in 'ExtAI\Delphi\src\ExtAIDelphi.pas',
  ExtAIBaseDelphi in 'ExtAI\Delphi\src\ExtAIBaseDelphi.pas',
  ExtAIActions in 'ExtAI\Delphi\src\interface\ExtAIActions.pas',
  ExtAIEvents in 'ExtAI\Delphi\src\interface\ExtAIEvents.pas',
  ExtAIStates in 'ExtAI\Delphi\src\interface\ExtAIStates.pas',
  ExtAIMsgActions in 'ExtAI\Delphi\src\interface\ExtAIMsgActions.pas',
  ExtAIMsgEvents in 'ExtAI\Delphi\src\interface\ExtAIMsgEvents.pas',
  ExtAIMsgStates in 'ExtAI\Delphi\src\interface\ExtAIMsgStates.pas',
  ExtAIStatesTerrain in 'ExtAI\Delphi\src\interface\ExtAIStatesTerrain.pas',
  ExtAISharedInterface in 'ExtAI\Delphi\src\interface\ExtAISharedInterface.pas',
  ExtAINetClient in 'ExtAI\Delphi\src\net\ExtAINetClient.pas',
  ExtAINetClientOverbyte in 'ExtAI\Delphi\src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in 'ExtAI\Delphi\src\net\ExtAISharedNetworkTypes.pas',
  ExtAICommonClasses in 'ExtAI\Delphi\src\net\ExtAICommonClasses.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TExtAI_TestBed, ExtAI_TestBed);
  Application.Run;
end.
