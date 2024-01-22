import numpy as np
import sounddevice as sd
from scipy import signal as sig


class Reproducer():
    def __init__(self, perfectPitch):

        self.state = "initial"
        self.perfectPitch = perfectPitch
        self.sampleFrequency = perfectPitch.processingManager.getSampleFrequency()
        self.referenceFrequency = perfectPitch.processingManager.getReferenceFrequency()
        self.referenceNoteNumber = perfectPitch.processingManager.getReferenceNoteNumber()

    def sawtoothWave(self, frequency, duration):
        # Create a sawtooth wave
        x = np.linspace(0, duration, int(duration * self.sampleFrequency))
        signal = sig.sawtooth(2 * np.pi * frequency * x, 0.5)

        #fade in / fade out
        percentageFactor = 0.1
        fade = np.arange(0, np.ceil(duration * self.sampleFrequency * percentageFactor))
        fader = np.sin(2 * np.pi * 10 / (4 * duration * self.sampleFrequency) * fade)
        signal[:int(np.ceil(duration * self.sampleFrequency * percentageFactor))] *= fader
        signal[-int(np.ceil(duration * self.sampleFrequency * percentageFactor)):] *= fader[::-1]

        return signal

    def playNote(self, note):
        # Create a sawtooth wave
        pitchList = self.perfectPitch.processingManager.musicSheetManager.pitchList
        if pitchList[note.getPitch()].find("#") > 0:
            pitch = note.getPitch() - 1
        else:
            pitch = note.getPitch()
            
        frequency = 440 * (2 ** ((pitch - 69) / 12))
        signal = self.sawtoothWave(frequency, note.getDuration())

        # Play the wave
        sd.play(signal, self.sampleFrequency)
        sd.wait()

