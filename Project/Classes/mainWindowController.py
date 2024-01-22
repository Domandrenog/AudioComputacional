from PyQt5.QtWidgets import QMainWindow, QPushButton, QLabel, QFileDialog
from PyQt5 import uic, QtGui, QtCore
from main import resource_path, perfectPitch
import threading
import numpy as np
import time
from Reproducer import Reproducer
import copy


class Ui_MainWindow(QMainWindow):
    def __init__(self, initialWindow):
        super(Ui_MainWindow, self).__init__()

        # Define Variables
        self.yStartNote = 230 # y coordinate when note is on C line
        self.yStep = 7
        self.xStartNote = 100 # x coordinate of the 1st note
        self.xStep = 50
        self.notesDisplay = [] # Contains notas as a lable from the gui
        self.reproducer = Reproducer(perfectPitch)
        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("guiPagesLightMode/mainWindow.ui"), self)
        else:
            uic.loadUi(resource_path("guiPagesDarkMode/mainWindow.ui"), self)

        # Define Widgets
        self.clearSheetButton = self.findChild(QPushButton, "clearSheetButton")
        self.definitionsButton = self.findChild(QPushButton, "definitionsButton")
        self.exportButton = self.findChild(QPushButton, "exportButton")
        self.logoButton = self.findChild(QPushButton, "logoButton")
        self.microphoneButton = self.findChild(QPushButton, "microphoneButton")
        self.recordingLabel = self.findChild(QLabel, "recordingLabel")
        self.startRecordingLabel = self.findChild(QLabel, "startRecordingLabel")
        self.pauseButton = self.findChild(QPushButton, "pauseButton")
        self.continueButton = self.findChild(QPushButton, "continueButton")
        self.stopButton = self.findChild(QPushButton, "stopButton")
        self.backButtonMainWindow = self.findChild(QPushButton, "backButtonMainWindow")

        # Define Functions
        self.clearSheetButton.clicked.connect(self.clearSheetButtonPressed)
        self.definitionsButton.clicked.connect(self.definitionsButtonPressed)
        self.logoButton.clicked.connect(lambda: self.logoButtonPressed(initialWindow))
        self.microphoneButton.clicked.connect(self.microphoneButtonPressed)
        self.exportButton.clicked.connect(lambda: self.exportButtonPressed(initialWindow))
        self.pauseButton.clicked.connect(self.pauseButtonPressed)
        self.stopButton.clicked.connect(self.stopButtonPressed)
        self.continueButton.clicked.connect(self.continueButtonPressed)
        self.backButtonMainWindow.clicked.connect(self.backButtonMainWindowPressed)
    

        # Define Timer
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(lambda: self.updateSheet())

        # Set the App
        #self.stop_thread = False
        #self.display_thread = threading.Thread(target=self.updateSheet).start()

        self.show()

    def clearGUI(self):
            
        for note in self.notesDisplay:
            note.hide()

    def clearSheetButtonPressed(self):
        if perfectPitch.processingManager.microphone.state == "OFF":
            self.recordingLabel.setText("Status: Not Recording")
            self.startRecordingLabel.setText("Press to start recording")
            perfectPitch.processingManager.musicSheetManager.clearSheet()
            perfectPitch.processingManager.musicSheetManagerReplay.clearSheet()
            self.clearGUI()


    def definitionsButtonPressed(self):
        from definitionPopUpController import Ui_DefWindow
        self.defWindow = Ui_DefWindow()


    def exportButtonPressed(self, initialWindow):
        from performancePopUpController import Ui_performanceWindow
        # Opens the performance pop up
        perfectPitch.importedCompare = False
        self.perfWindow = Ui_performanceWindow(initialWindow, self)
        


    def logoButtonPressed(self, initialWindow):
        perfectPitch.processingManager.musicSheetManager.clearSheet()
        initialWindow.show()
     
        self.close()

    def microphoneButtonPressed(self):
        if perfectPitch.processingManager.microphone.state == "ON": # If recording, stops recording
            perfectPitch.processingManager.microphone.state = "OFF"
            self.recordingLabel.setText("Status: Paused")
            self.startRecordingLabel.setText("Press to continue recording")
            icon1 = QtGui.QIcon()
            icon1.addPixmap(QtGui.QPixmap(resource_path("images/microphoneOff.png")), QtGui.QIcon.Normal, QtGui.QIcon.Off)
            self.microphoneButton.setIcon(icon1)
            self.timer.stop()
            perfectPitch.reproducer.state = "initial" 
            perfectPitch.stopRecording()

        else : # If not recording, star recording
            perfectPitch.processingManager.microphone.state = "ON"
            
            if perfectPitch.reproducer.state != "initial":
                self.clearGUI()
                perfectPitch.processingManager.musicSheetManagerReplay.clearSheet()
            
            self.recordingLabel.setText("Status: Recording")
            self.startRecordingLabel.setText("Press to pause recording")
            icon = QtGui.QIcon()
            icon.addPixmap(QtGui.QPixmap(resource_path("images/microphoneOn.png")), QtGui.QIcon.Normal, QtGui.QIcon.Off)
            self.microphoneButton.setIcon(icon)
            
            self.timer.start(int(np.floor(perfectPitch.processingManager.musicSheetManager.getUpdateFrequency()*1000 +100)))
            perfectPitch.startRecording()


    def pauseButtonPressed(self):
        if perfectPitch.processingManager.microphone.state == "OFF":  
            if perfectPitch.reproducer.state == "play": 
                perfectPitch.reproducer.state = "pause"
                self.timer.stop()
        else: 
            return 

    def stopButtonPressed(self):
        if perfectPitch.reproducer.state != "initial":
            self.timer.stop()  
            perfectPitch.reproducer.state = "initial"
            perfectPitch.processingManager.musicSheetManagerReplay.clearSheet()
            self.clearGUI()
            self.notesToPlot = copy.deepcopy(self.notesOfFile)
        else: 
            return 
    
    def notesRecorded(self):

        self.notesToPlot = []
        self.notesOfFile = []
        
        
        for line in perfectPitch.processingManager.musicSheetManager.sheet.getAllNotes():
            
            self.notesToPlot.append(line)
            self.notesOfFile.append(line)

        
        self.clearGUI()

        [print("Notes to Plot: ", note.getPitch(),  note.getRhythm(), note.getFrequency(), note.getDuration()) for note in  self.notesToPlot]
        #[print("Notes of File: ", note.getPitch(),  note.getRhythm(), note.getFrequency(), note.getDuration()) for note in  self.notesOfFile]


                

    def continueButtonPressed(self):
        if perfectPitch.processingManager.microphone.state == "OFF":  
            if perfectPitch.reproducer.state == "pause" or perfectPitch.reproducer.state == "initial":
                if perfectPitch.reproducer.state == "initial":
                    self.notesRecorded()
                perfectPitch.reproducer.state = "play"
                self.timer.start(int(np.floor(perfectPitch.processingManager.musicSheetManager.getUpdateFrequency()*1000+100)))

        else: 
            return 

    def backButtonMainWindowPressed(self):
        from initialWindowController import Ui_initialWindow
        perfectPitch.processingManager.musicSheetManager.clearSheet()
        # Opens the initial window
        self.initialWindow = Ui_initialWindow()

        #stops thread
        #self.stop_thread = True
        #self.display_thread.join()   

        self.close()

    def updateSheet(self):

        if perfectPitch.processingManager.microphone.state == "OFF":

            if len(self.notesToPlot) == 0:
                self.timer.stop()
                return
        
            note1 = self.notesToPlot.pop(0)
            self.reproducer.playNote(note1)
            perfectPitch.processingManager.musicSheetManagerReplay.addMusicNote(note1)

            #while not self.stop_thread:
            musicplay = perfectPitch.processingManager.musicSheetManagerReplay.sheet
            for note in self.notesDisplay:
                note.hide()

            self.notesDisplay = []

            for i, note in enumerate(musicplay.getNotes()):
                newNote = self.noteOnGui(note, i)
                self.notesDisplay.append(newNote)
                self.notesDisplay[i].show()
        else:
            #while not self.stop_thread:
            musicSheet = perfectPitch.processingManager.musicSheetManager.sheet
            for note in self.notesDisplay:
                note.hide()

            self.notesDisplay = []

            for i, note in enumerate(musicSheet.getNotes()):
                newNote = self.noteOnGui(note, i)
                self.notesDisplay.append(newNote)
                self.notesDisplay[i].show()
                
            #time.sleep(perfectPitch.processingManager.musicSheetManager.getUpdateFrequency())

                
            
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
        #note.raise_()
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