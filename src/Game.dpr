program Game;
uses
  Vcl.Forms,
  KM_Game in 'KM_Game.pas',
  KM_CommonTypes in 'KM_CommonTypes.pas',
  KM_CommonUtils in 'KM_CommonUtils.pas',
  KM_Consts in 'KM_Consts.pas',
  KM_Hand in 'KM_Hand.pas',
  KM_HandAI_Ext in 'KM_HandAI_Ext.pas',
  KM_Terrain in 'KM_Terrain.pas',
  ExtAINetServer in 'ExtAI\ExtAINetServer.pas',
  ExtAINetworkTypes in 'ExtAI\ExtAINetworkTypes.pas',
  ExtAIMaster in 'ExtAI\ExtAIMaster.pas',
  ExtAIInfo in 'ExtAI\ExtAIInfo.pas',
  ExtAI_DLL in 'ExtAI\ExtAI_DLL.pas',
  ExtAI_DLLs in 'ExtAI\ExtAI_DLLs.pas',
  NetServerOverbyte in 'ExtAI\NetServerOverbyte.pas',
  ExtAILog in '..\ExtAI\Delphi\src\ExtAILog.pas',
  //ExtAIDelphi in '..\ExtAI\Delphi\src\ExtAIDelphi.pas',
  //ExtAIBaseDelphi in '..\ExtAI\Delphi\src\ExtAIBaseDelphi.pas',
  //ExtAIActions in '..\ExtAI\Delphi\src\interface\ExtAIActions.pas',
  //ExtAIEvents in '..\ExtAI\Delphi\src\interface\ExtAIEvents.pas',
  //ExtAIStates in '..\ExtAI\Delphi\src\interface\ExtAIStates.pas',
  ExtAIMsgActions in '..\ExtAI\Delphi\src\interface\ExtAIMsgActions.pas',
  ExtAIMsgEvents in '..\ExtAI\Delphi\src\interface\ExtAIMsgEvents.pas',
  ExtAIMsgStates in '..\ExtAI\Delphi\src\interface\ExtAIMsgStates.pas',
  //ExtAIStatesTerrain in '..\ExtAI\Delphi\src\interface\ExtAIStatesTerrain.pas',
  ExtAISharedInterface in '..\ExtAI\Delphi\src\interface\ExtAISharedInterface.pas',
  //ExtAINetClient in '..\ExtAI\Delphi\src\net\ExtAINetClient.pas',
  //ExtAINetClientOverbyte in '..\ExtAI\Delphi\src\net\ExtAINetClientOverbyte.pas',
  ExtAISharedNetworkTypes in '..\ExtAI\Delphi\src\net\ExtAISharedNetworkTypes.pas',
  ExtAICommonClasses in '..\ExtAI\Delphi\src\net\ExtAICommonClasses.pas',
  KP_Form in 'KP_Form.pas' {Game_form};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGame_form, Game_form);
  Application.Run;
end.
