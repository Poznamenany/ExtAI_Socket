from src.net.ExtAINetClient import ExtAIClient


class ExtAIBase:
    def __init__(self, GUILog):
        self.GUILog = GUILog
        self.GUILog('Base ExtAI Class')
        self.Client = ExtAIClient()