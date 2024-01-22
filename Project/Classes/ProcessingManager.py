import math
import numpy as np
from scipy.signal import correlate, fftconvolve
from MusicNote import MusicNote
from Microphone import Microphone
from MusicSheetManager import MusicSheetManager


class ProcessingManager:
    def __init__(self):
        self.windowSize = 0.030 # seconds
        self.minF0 = 110.0 # A2
        self.maxF0 = 880.0 # A5
        self.sampleFrequency = 44100.0 # Hz
        self.referenceFrequency = 440.0 # Hz
        self.referenceNoteNumber = 69 # A4
        self.audioSize = 0.5 # seconds
        self.microphone = Microphone(self.sampleFrequency, self.audioSize)
        self.musicSheetManager = MusicSheetManager(self)
        self.musicSheetManagerReplay = MusicSheetManager(self)

    def getMicrophone(self):
        return self.microphone

    def getWindowSize(self):
        return self.windowSize

    def getMinF0(self):
        return self.minF0

    def getMaxF0(self):
        return self.maxF0

    def getSampleFrequency(self):
        return self.sampleFrequency
    
    def getReferenceFrequency(self):
        return self.referenceFrequency

    def getReferenceNoteNumber(self):
        return self.referenceNoteNumber

    def getAudioSize(self):
        return self.audioSize

    def setWindowSize(self, newWindowSize):
        self.windowSize = newWindowSize

    def setSampleFrequency(self, newSampleFrequency):
        self.sampleFrequency = newSampleFrequency
        
    def setMinF0(self, newMinF0):
        self.minF0 = newMinF0

    def setMaxF0(self, newMaxF0):
        self.maxF0 = newMaxF0

    def searchForMicrophone(self):
        # TODO: Implement this method
        pass
    
    def calculateF0(self, signal):
        corr = correlate(signal, signal, mode='full')
        corr = corr[int(np.floor(len(corr)/2)) :]
        if len(corr) < 4:
            return None

        d = np.diff(corr)

        try: 
            start = np.nonzero(d > 0)[0][0]
        except IndexError:
            return None

        peak = np.argmax(corr[start:]) + start
        px, py = self.parabolic(corr, peak)

        if self.sampleFrequency / px > self.minF0 and self.sampleFrequency / px < self.maxF0:
            return self.sampleFrequency / px
        else:
            return None
    

    def parabolic(self, f, x):
        xv = 1/2. * (f[x-1] - f[x+1]) / (f[x-1] - 2 * f[x] + f[x+1]) + x
        yv = f[x] - 1/4. * (f[x-1] - f[x+1]) * (xv - x)
        return (xv, yv)


    def calculateZeroCrossingRate(self, signal):
        zero_threshold= 0.000
        num_crossings = 0
        is_zero = 0
        for i in range(len(signal) - 1):
            if signal[i]== 0:
                is_zero += 1
            elif signal[i] * signal[i + 1] <= zero_threshold:
                num_crossings += 1
        return num_crossings / (len(signal))


    def calculateEnergy(self, signal):
        return np.sum(signal**2) / len(signal)

    def filterNoise(self, zcr, energy):
        energy_threshold = 10e-5
        if energy < energy_threshold:
            return True # Noise
        else:
            return False # Not noise
        
    def processSegment(self, audio_queue, event, stop_threads):
        while not stop_threads.is_set():
            event.wait() # Wait for audio data
            
            numWindows = int(self.audioSize // self.windowSize)
            sum = 0
            total = 0
            audiData = audio_queue.get()
            
            for i in range(numWindows):
                start = int(np.floor((i * self.windowSize)*self.sampleFrequency + 1))
                end = int(np.floor((start + self.windowSize)*self.sampleFrequency))
                if start >= end: 
                    break
                window = audiData[start:end]
                

                f0 = self.calculateF0(window)
                zcr = self.calculateZeroCrossingRate(window)
                energy = self.calculateEnergy(window)

                # Average of f0 that are not noise of the segments 
                if not self.filterNoise(zcr, energy) and f0 is not None: 
                    sum += f0
                    total += 1

            if total != 0: # If it is a musical sound, creates a music note
                print("Note: ", self.calculatePitch(sum/total)) # DEBUG

                note = self.createMusicNote(
                    self.calculatePitch(sum/total), # Pitch
                    'nan', # Rythm
                    sum/total, # Frequency
                    self.audioSize # Duration
                )


                self.musicSheetManager.addMusicNote(note)
                
            else:
                event.clear()
                #return None


    def calculateRythm(self, signal, zcr, energy):
        # TODO: Implement this method
        pass

    def calculatePitch(self, f0):
        # Calculate pitch from frequency
        return round(12 * math.log2(f0 / self.referenceFrequency) + self.referenceNoteNumber)
 

    def createMusicNote(self, pitch, rhythm, frequency, duration):
        # Create a MusicNote object
        
        return MusicNote(
            pitch, # pitch number
            rhythm, # rhythm
            frequency,
            duration # duration
        )       