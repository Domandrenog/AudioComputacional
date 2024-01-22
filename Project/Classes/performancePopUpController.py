from PyQt5.QtWidgets import QMainWindow, QPushButton, QLabel
from PyQt5 import uic, QtGui
from PyQt5.QtGui import QMovie
from main import resource_path, perfectPitch

class Ui_performanceWindow(QMainWindow):
    def __init__(self, initialWindow, mainWindow):
        super(Ui_performanceWindow, self).__init__()
        self.initialWindow = initialWindow
        self.mainWindow = mainWindow
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("./guiPagesLightMode/performancePopUp.ui"), self)
        else:
            uic.loadUi(resource_path("./guiPagesDarkMode/performancePopUp.ui"), self)
        
        # Show Window
        self.show()

        #Define Widgets
        self.recordAgainButton = self.findChild(QPushButton, "recordAgainButton")
        self.exportButton = self.findChild(QPushButton, "exportButton")
        self.importButton = self.findChild(QPushButton, "importButton")
        self.performanceLabel = self.findChild(QLabel, "performanceLabel")

        #Define functions
        self.recordAgainButton.clicked.connect(self.recordAgainButtonPressed)
        self.exportButton.clicked.connect(self.exportButtonPressed)
        self.importButton.clicked.connect(self.importButtonPressed)
        #self.exportButton.clicked.connect(lambda: self.exportButtonPressed(initialWindow))

        self.performancePercentage(18,20) 

    def recordAgainButtonPressed(self):
        perfectPitch.importedCompare == False
        self.close()

    def exportButtonPressed(self):
        from endingWindowController import Ui_endingWindow
        # Opens the ending window
        perfectPitch.importedCompare == False
        self.endWindow = Ui_endingWindow(self.initialWindow, self.mainWindow)
        self.mainWindow.close()
        self.close()

    def importDone(self):
        if perfectPitch.importedCompare == True:
            print("finish")
            
            #[print("Atual", note.getPitch()) for note in perfectPitch.processingManager.musicSheetManager.sheet.getAllNotes()]
            #[print("Comparar", notes.getPitch()) for notes in perfectPitch.processingManager.musicSheetManager.notesToPlot]
            
            # Obtenha as listas de notas
            notes1 = perfectPitch.processingManager.musicSheetManager.sheet.getAllNotes()
            notes2 = perfectPitch.processingManager.musicSheetManager.notesToPlot

            lengthmax = max(len(notes1), len(notes2))
            lengthmin = min(len(notes1), len(notes2))
            notasiguais = 0
                

            for note1, note2 in zip(notes1, notes2):
                print("Atual", note1.getPitch())
                print("Comparar", note2.getPitch())
                if note1.getPitch() == note2.getPitch():
                    print("As notas são iguais")
                    notasiguais += 1
                else:
                    print("As notas são diferentes")

            # Continue com o restante do seu código
            self.performancePercentage(notasiguais,lengthmax) #test values

    def importButtonPressed(self):
        from importPopUpCompare import Ui_ImportWindow
        self.importWindow = Ui_ImportWindow(self.initialWindow, self)
        


        
    
    def performancePercentage(self, rightNotes, allNotes):

        if perfectPitch.importedCompare == True:
            self.performanceLabel.setText(f"You got {rightNotes}/{allNotes} notes correct!")
            percentage = rightNotes / allNotes
            emoji = "thebestemoji.png" if percentage > 0.8 else ("goodemoji.png" if percentage > 0.5 else "sademoji.png")
            icon = QtGui.QIcon()
            icon.addPixmap(QtGui.QPixmap(resource_path(f"images/{emoji}")), QtGui.QIcon.Normal, QtGui.QIcon.Off)
            self.emoji.setIcon(icon)

        else:
            self.performanceLabel.setText(f"Insert a file to compare!")
            

    
   