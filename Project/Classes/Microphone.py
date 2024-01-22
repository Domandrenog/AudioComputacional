import sounddevice as sd
import numpy as np

class Microphone:
    def __init__(self, sampleFrequency, audioSize):
        self.state = 'OFF'
        self.sampleFrequency = sampleFrequency
        self.systemID = 0
        self.audioSize = audioSize

    def getSampleFrequency(self):
        return self.sampleFrequency

    def getSystemID(self):
        return self.systemID

    def setSampleFrequency(self, newFs):
        self.sampleFrequency = newFs

    def acquireAudio(self, audio_queue, event, stop_threads):
        while not stop_threads.is_set():
            recording = sd.rec(int(self.sampleFrequency * self.audioSize), samplerate=self.sampleFrequency, channels=1)
            sd.wait()  # Wait for the recording to finish
            if recording.ndim > 1: #Se houver mais que um canal
                recording = np.mean(recording, axis=1)

            audio_queue.put(np.array(recording))
            event.set()  # Signal that audio data is ready
        
