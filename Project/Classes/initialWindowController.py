from PyQt5.QtWidgets import QMainWindow, QPushButton
from PyQt5 import uic
from main import resource_path, perfectPitch


class Ui_initialWindow(QMainWindow):
    def __init__(self):
        super(Ui_initialWindow, self).__init__()

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("guiPagesLightMode/initialWindow.ui"), self)
        else:
            uic.loadUi(resource_path("guiPagesDarkMode/initialWindow.ui"), self)

        # Define Widgets
        self.startButton = self.findChild(QPushButton, "startButton")
        self.startListening = self.findChild(QPushButton, "startButton_2")
        self.aboutButton = self.findChild(QPushButton, "aboutButton")
        self.modeButton = self.findChild(QPushButton, "modeButton")

        # Define Functions
        self.startButton.clicked.connect(self.startButtonClicked)
        self.startListening.clicked.connect(self.startListeningClicked)
        self.aboutButton.clicked.connect(self.aboutButtonClicked)
        self.modeButton.clicked.connect(self.modeButtonClicked)
    
        # Show Window
        self.show()
    
    def startButtonClicked(self):
        from mainWindowController import Ui_MainWindow
        # Opens the main window
        self.mainWindow = Ui_MainWindow(self)
        self.close()
        
    def startListeningClicked(self):
        from importPopUpController import Ui_ImportWindow
        self.importWindow = Ui_ImportWindow(self)


    def aboutButtonClicked(self):
        from aboutPopUpController import Ui_aboutWindow

        # Opens the about window
        self.aboutWindow = Ui_aboutWindow()

    def modeButtonClicked(self):
        #global mode
        perfectPitch.mode = "dark" if perfectPitch.mode == "light" else "light"
        self.close()
        self.__init__()
        self.show()