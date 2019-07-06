import datetime
import tkinter as tk
from src.ExtAIPython import ExtAI


class ExtAIFrame(tk.Frame):
    def __init__(self, parent, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent

        # Define Widgets
        # Main frame
        self.frmExtAI = tk.LabelFrame(self, text="ExtAI Python (Tkinter GUI)", padx=5, pady=5)
        self.frmExtAI.pack(padx=10, pady=10)
        # Control Frame
        self.frmControl = tk.Frame(self.frmExtAI)
        self.frmControl.pack(side=tk.LEFT)
        # Port label
        self.labPort = tk.Label(self.frmControl, text="Port:")
        self.labPort.grid(row=0)
        # Port number
        self.entPort = tk.Entry(self.frmControl)
        self.entPort.grid(row=0, column=1)
        # Connect / Disconnect client
        self.btnNetClient = tk.Button(self.frmControl, text="Connect Client", command=self.connectDisconnectClient)
        self.btnNetClient.grid(row=1)
        # Log Frame
        self.frmLog = tk.Frame(self.frmExtAI)
        self.frmLog.pack(side=tk.RIGHT)
        # Log text
        self.txtLog = tk.Text(self.frmLog)
        self.txtLog.pack()

        # Create thread with ExtAI
        self.ExtAI = ExtAI(self.log)


    def connectDisconnectClient(self):
        print('ok')
        self.btnNetClient.configure(text="Disconnect Client")
        self.log('ok')

    def log(self, text):
        self.txtLog.config(state=tk.NORMAL)
        self.txtLog.insert(tk.END, str(datetime.datetime.now().time()) + ": " + text + "\n")
        self.txtLog.config(state=tk.DISABLED)


if __name__ == "__main__":
    root = tk.Tk()
    ExtAIFrame(root).pack(side="top", fill="both", expand=True)
    root.geometry("500x500")
    root.mainloop()