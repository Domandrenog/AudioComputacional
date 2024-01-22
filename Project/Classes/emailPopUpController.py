from PyQt5.QtWidgets import QMainWindow, QTextEdit
from PyQt5 import uic
from main import resource_path, perfectPitch

class Ui_emailWindow(QMainWindow):
    def __init__(self):
        super(Ui_emailWindow, self).__init__()

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("./guiPagesLightMode/emailPopUp.ui"), self)
        else:
                uic.loadUi(resource_path("./guiPagesDarkMode/emailPopUp.ui"), self)

        # Show Window
        self.show()
        
        ##Define widgets
        
        self.emailText = self.findChild(QTextEdit, "emailText")
        
        self.sendButton.clicked.connect(self.sendButtonPressed)
        
    def sendButtonPressed(self):
        email = self.emailText.toPlainText()
        self.close()
        perfectPitch.processingManager.musicSheetManager.sendEmail(email)
        
        
        