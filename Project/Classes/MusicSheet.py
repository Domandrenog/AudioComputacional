class MusicSheet:
    def __init__(self, bpm):
        self.length = 0
        self.notesOnDisplay = [] # List of MusicNote objects
        self.maxDisplayLength = 8
        self.duration = 0.0
        self.initTime = None
        self.endTime = None
        self.allNotes = []
        self.tempo = 0
        self.bpm = bpm

    def getMaxDisplayLength(self):
        return self.maxDisplayLength

    def setMaxDisplayLength(self, newLength):
        self.maxDisplayLength = newLength

    def getDuration(self):
        return self.duration

    def getNotes(self):
        return self.notesOnDisplay

    def getAllNotes(self):
        return self.allNotes

    def getTempo(self):
        return self.tempo

    def shiftDisplay(self):
        self.notesOnDisplay.pop(0)
