from PyQt5.QtWidgets import QMainWindow
from PyQt5 import uic
from main import resource_path, perfectPitch

class Ui_aboutWindow(QMainWindow):
    def __init__(self):
        super(Ui_aboutWindow, self).__init__()

        # Load .ui file
        if perfectPitch.mode == "light":
            uic.loadUi(resource_path("./guiPagesLightMode/aboutPopUp.ui"), self)
        else:
            uic.loadUi(resource_path("./guiPagesDarkMode/aboutPopUp.ui"), self)

        # Show Window
        self.show()

