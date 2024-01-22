class MusicNote:
    def __init__(self, pitch, rhythm, frequency, duration):
        self.pitch = pitch # Note number
        self.rhythm = rhythm
        self.frequency = frequency
        self.duration = duration

    def getPitch(self):
        return self.pitch
    
    def getRhythm(self):
        return self.rhythm

    def getFrequency(self):
        return self.frequency

    def getDuration(self):
        return self.duration
    

