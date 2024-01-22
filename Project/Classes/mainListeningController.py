from PyQt5.QtWidgets import QMainWindow, QPushButton, QLabel, QFileDialog
from PyQt5 import uic, QtGui, QtCore
from main import resource_path, perfectPitch
import threading
import numpy as np
import time
import copy
from Reproducer import Reproducer


class Ui_MainListening(QMainWindow):
    def __init__(self, initialWindow):
        super(Ui_MainListening, self).__init__()

        # Define Variables
        self.yStartNote = 230 # y coordinate when note is on C line
        self.yStep = 7
        self.xStartNote = 100 # x coordinate of the 1st note
        self.xStep = 50
        self.notesDisplay = [] # Contains notas as a lable from the gui
        perfectPitch.processingManager.musicSheetManager.clearSheet()
        self.reproducer = Reproducer(perfectPitch)
        
        perfectPitch.reproducer.state = "initial"
        
    

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("guiPagesLightMode/mainListening.ui"), self)
        else:
            uic.loadUi(resource_path("guiPagesDarkMode/mainListening.ui"), self)

        # Define Widgets
        self.stopButton = self.findChild(QPushButton, "stopButton")
        self.logoButton = self.findChild(QPushButton, "logoButton")
        self.pauseButton = self.findChild(QPushButton, "pauseButton")
        self.continueButton = self.findChild(QPushButton, "continueButton")
        self.backButtonMainWindow = self.findChild(QPushButton, "backButtonMainWindow")

        # Define Functions
        self.logoButton.clicked.connect(lambda: self.logoButtonPressed(initialWindow))
        self.pauseButton.clicked.connect(self.pauseButtonPressed)
        self.continueButton.clicked.connect(self.continueButtonPressed)
        self.stopButton.clicked.connect(self.stopButtonPressed)
        self.backButtonMainWindow.clicked.connect(self.backButtonMainWindowPressed)
    
        # Define Timer
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(lambda: self.updateSheet())

        self.show()




    def logoButtonPressed(self, initialWindow):
        perfectPitch.processingManager.musicSheetManager.clearSheet()
        initialWindow.show()
     
        self.close()



    def pauseButtonPressed(self):
        if perfectPitch.reproducer.state == "play": 
            perfectPitch.reproducer.state = "pause"
            self.timer.stop()
            
        else: 
            return 
        
    def stopButtonPressed(self):
        if perfectPitch.reproducer.state != "initial":
            self.timer.stop()  
            perfectPitch.reproducer.state = "initial"
            perfectPitch.processingManager.musicSheetManager.clearSheet()
            self.clearGUI()
            
            perfectPitch.processingManager.musicSheetManager.notesToPlot = copy.deepcopy(perfectPitch.processingManager.musicSheetManager.notesOfFile)

        else: 
            return 
    
    def continueButtonPressed(self):
        if perfectPitch.reproducer.state == "pause" or perfectPitch.reproducer.state == "initial":
            perfectPitch.reproducer.state = "play" 
            self.timer.start(int(np.floor(perfectPitch.processingManager.musicSheetManager.getUpdateFrequency()*1000 + 10)))
        else: 
            return 

    def backButtonMainWindowPressed(self):
        from initialWindowController import Ui_initialWindow
        perfectPitch.processingManager.musicSheetManager.clearSheet()
        # Opens the initial window
        self.initialWindow = Ui_initialWindow()
        self.close()
        
        
    def clearGUI(self):
        musicSheet = perfectPitch.processingManager.musicSheetManager.sheet
            
        for note in self.notesDisplay:
            note.hide()

        self.notesDisplay = []

        for i, note in enumerate(musicSheet.getNotes()):
                
            newNote = self.noteOnGui(note, i)
            self.notesDisplay.append(newNote)
            self.notesDisplay[i].show()
                
        

    def updateSheet(self):
        if len(perfectPitch.processingManager.musicSheetManager.notesToPlot) == 0:
            self.timer.stop()
            return
        
        note1 = perfectPitch.processingManager.musicSheetManager.notesToPlot.pop(0)
        self.reproducer.playNote(note1)
        
        
        perfectPitch.processingManager.musicSheetManager.addMusicNote(note1)

        musicSheet = perfectPitch.processingManager.musicSheetManager.sheet
            
        for note in self.notesDisplay:
            note.hide()

        self.notesDisplay = []

        for i, note in enumerate(musicSheet.getNotes()):
                
            newNote = self.noteOnGui(note, i)
            self.notesDisplay.append(newNote)
            self.notesDisplay[i].show()
                

                
            
    def noteOnGui(self, note, i):
        yCor = self.fromNoteToCoordinates(note.getPitch())
        xCor = self.xStartNote + i*self.xStep
        note = QLabel(self.mainWindowFrame)
        note.setGeometry(QtCore.QRect(xCor, yCor, 70, 137))
        note.setText("")
        note.setPixmap(QtGui.QPixmap(resource_path("images/seminima.png")))
        note.setScaledContents(True)
        note.setObjectName("note1")
        note.setStyleSheet("background: none;")
        note.lower()

        return note
        


    def fromNoteToCoordinates(self, noteNumber):
        name = perfectPitch.processingManager.musicSheetManager.pitchList[noteNumber][0:2]
        # swich case
        if name == "dó":
            y = 7
        elif name == "ré":
            y = 1
        elif name == "mi":
            y = 2
        elif name == "fá":
            y = 3
        elif name == "so":
            y = 4
        elif name == "lá":
            y = 5
        elif name == "si":
            y = 6
        else:
            y = None
        
        
        return self.yStartNote - y*self.yStep