from src.ExtAIBasePython import ExtAIBase


class ExtAI(ExtAIBase):
    def __init__(self, GUILog):
        ExtAIBase.__init__(self, GUILog)
        self.GUILog('Main ExtAI Class')
