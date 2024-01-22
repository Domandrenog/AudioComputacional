from PyQt5.QtWidgets import QMainWindow, QPushButton, QTextEdit, QSlider
from PyQt5 import uic, QtGui, QtCore
from main import resource_path, perfectPitch
import numpy as np

class Ui_DefWindow(QMainWindow):
    def __init__(self):
        super(Ui_DefWindow, self).__init__()

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("./guiPagesLightMode/definitionPopUp.ui"), self)
        else:
            uic.loadUi(resource_path("./guiPagesDarkMode/definitionPopUp.ui"), self)

        # Define Widgets
        self.saveButton = self.findChild(QPushButton, "saveButton")
        self.cancelButton = self.findChild(QPushButton, "cancelButton")
        self.sampleFreqText = self.findChild(QTextEdit, "sampleFreqText")
        self.windowSizeText = self.findChild(QTextEdit, "windowSizeText")
        self.minfreq_slider = self.findChild(QSlider, "minfreq_slider")
        self.maxfreq_slider = self.findChild(QSlider, "maxfreq_slider")

        # Set default values
        _translate = QtCore.QCoreApplication.translate
        self.sampleFreqText.setHtml(_translate("SettingsPopUp", str(perfectPitch.processingManager.getSampleFrequency())+ " Hz"))
        self.windowSizeText.setHtml(_translate("SettingsPopUp", str(perfectPitch.processingManager.getWindowSize())+ " s"))
        self.minfreq_slider.setMinimum(self.toLogScale(40))
        self.minfreq_slider.setMaximum(self.toLogScale(10000))
        self.maxfreq_slider.setMinimum(self.toLogScale(40))
        self.maxfreq_slider.setMaximum(self.toLogScale(10000))
        self.minfreq_slider.setTickInterval(1)
        self.minfreq_slider.setValue(self.toLogScale(perfectPitch.processingManager.getMinF0()))
        self.maxfreq_slider.setValue(self.toLogScale(perfectPitch.processingManager.getMaxF0()))

        # Define Functions
        self.saveButton.clicked.connect(self.saveButtonPressed)
        self.cancelButton.clicked.connect(self.cancelButtonPressed)
        


        # Show window
        self.show()

    def toLogScale(self, value):
        # converts values octave scale
        # As Qslice only accepts int, it multiplies by 100 to store 2 decimal places
        return int(np.floor(np.log2(value)*100))
        
    def fromLogScale(self, value):
        # converts values octave scale
        # As Qslice only accepts int, it divide by 100 to get 2 decimal places
        return int(np.floor(2**(value/100)))

    def saveButtonPressed(self):
        perfectPitch.processingManager.setSampleFrequency(float(self.sampleFreqText.toPlainText().replace(' Hz', '')))
        perfectPitch.processingManager.setWindowSize(float(self.windowSizeText.toPlainText().replace(' s', '')))
        perfectPitch.processingManager.setMinF0(self.fromLogScale(self.minfreq_slider.value()))
        perfectPitch.processingManager.setMaxF0(self.fromLogScale(self.maxfreq_slider.value()))
        self.close()

    def cancelButtonPressed(self):
        # Closes definition window
        self.close()
        
