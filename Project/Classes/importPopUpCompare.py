from PyQt5.QtWidgets import QMainWindow, QPushButton, QFileDialog, QLabel
from PyQt5 import uic
from main import resource_path, perfectPitch




class Ui_ImportWindow(QMainWindow):
    def __init__(self, initialWindow,  performanceWindow):
        super(Ui_ImportWindow, self).__init__()
        self.initialWindow = initialWindow
        self.performanceWindow = performanceWindow

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("guiPagesLightMode/importPopUp.ui"), self)
        else:
            uic.loadUi(resource_path("guiPagesDarkMode/importPopUp.ui"), self)


        self.setAcceptDrops(True)
        # Define Widgets
        self.finishButton = self.findChild(QPushButton, "finishButton")
        self.importButton = self.findChild(QPushButton, "importButton")
        self.wrongLabel = self.findChild(QLabel, "wrongLabel")
        #self.logoButton = self.findChild(QPushButton, "logoButton")

        # Define Functions
        self.finishButton.clicked.connect(self.finishButtonPressed)
        self.importButton.clicked.connect(self.importButtonPressed)
        #self.logoButton.clicked.connect(self.logoButtonPressed)

        self.show()


    def finishButtonPressed(self):
        self.close()

    def importButtonPressed(self):
        # Opens the import pop up
        options = QFileDialog.Options()
        options |= QFileDialog.ReadOnly
        fileName, _ = QFileDialog.getOpenFileName(
            self, 
            "QFileDialog.getOpenFileName()", 
            "", 
            "Text Files (*.txt)", 

            options=options) 
            
        if fileName:
            perfectPitch.importedFile = fileName

            from Reproducer import Reproducer
            good_format = perfectPitch.processingManager.musicSheetManager.notesFromFiles(fileName)
                
            if good_format == 0:
                self.wrongLabel.setText('Drag the file or chose from device WRONG FORMAT, Try Again')
                    
            else:    
                perfectPitch.importedCompare = True
                self.performanceWindow.importDone()
                self.close()

    
    def dragEnterEvent(self, event):
        if event.mimeData().hasUrls():
            event.acceptProposedAction()

    def dropEvent(self, event):
        for url in event.mimeData().urls():
            fileName = url.toLocalFile()      

        if fileName:
            perfectPitch.importedFile = fileName

            from Reproducer import Reproducer
            good_format = perfectPitch.processingManager.musicSheetManager.notesFromFiles(fileName)
                
            if good_format == 0:
                self.wrongLabel.setText('Drag the file or chose from device WRONG FORMAT, Try Again')
                    
            else:    
                perfectPitch.importedCompare = True
                self.performanceWindow.importDone()
                self.close()