from PyQt5.QtWidgets import QMainWindow, QPushButton
from PyQt5 import uic
from main import resource_path, perfectPitch
from main import perfectPitch

class Ui_downloadWindow(QMainWindow):
    def __init__(self):
        super(Ui_downloadWindow, self).__init__()

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("./guiPagesLightMode/downloadPopUp.ui"), self)
        else:
            uic.loadUi(resource_path("./guiPagesDarkMode/downloadPopUp.ui"), self)
            
        # Define Widgets
        self.finishButton = self.findChild(QPushButton, "finishButton")

        # Define Functions
        self.finishButton.clicked.connect(self.finishButtonPressed)
        
        # Show Window
        self.show()

        # Actions
        perfectPitch.processingManager.musicSheetManager.downloadSheetTxt()
        
    def finishButtonPressed(self):
        self.close()