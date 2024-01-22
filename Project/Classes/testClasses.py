## Script to test classes .py
import numpy as np

from ProcessingManager import ProcessingManager
from MusicSheetManager import MusicSheetManager
from Microphone import Microphone

processingManager = ProcessingManager()
musicSheetManager = MusicSheetManager(processingManager)



if __name__ == "__main__":
    
    while True:
        sound = processingManager.microphone.acquireAudio()
        processingManager.processSegment(sound)
