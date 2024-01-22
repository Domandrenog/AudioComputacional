import numpy as np
import sounddevice as sd
from scipy.signal import find_peaks
import threading
import queue
import time  

# Global variable to store aquired audio data
#audioData = []

# Identify if the audio data is noise or not
# TODO : Add ZCR threshold
def identifyNoise(audioData, fs):
    energy_threshold = 10e-5

    energy = np.sum(audioData ** 2) / len(audioData)
    if energy < energy_threshold:
        return True # Noise
    else:
        return False # Not noise

# Determins the fundamental frequency of the audio data
def calculateF0(audioData, fs, f0_min=100, f0_max=900):


    # Calculate the autocorrelation of the signal
    correlation = np.correlate(audioData, audioData, mode='full')
    correlation = correlation[int(np.floor(correlation.size/2 + fs/f0_min)):]

    # Find the peaks in the autocorrelation
    peaks, _ = find_peaks(correlation)

    # Find the index of the highest peak
    highest_peak_index = peaks[np.argmax(correlation[peaks])]

    # Calculate the fundamental frequency
    f0 = fs / (highest_peak_index + 1)

    return f0
    
# Get audio data from the microphone
def get_audio_data(fs, audio_queue, event):
    while True:
        seconds = 1  # Duration of recording
        audio_data = sd.rec(int(seconds * fs), samplerate=fs, channels=1)
        sd.wait()  # Wait for the recording to finish

        if audio_data.ndim > 1:
            audio_data = np.mean(audio_data, axis=1)

        audio_queue.put(np.array(audio_data))
        event.set()  # Signal that audio data is ready

# Process audio data
def process_audio_data(fs, audio_queue, event):
    f0_min = 100  # Hz - Bellow A2
    f0_max = 900  # Hz - Highrt than A5
    while True:
        # Wait for audio data
        audio_data = audio_queue.get()

        # Filters by noise
        if identifyNoise(audio_data, fs): # If the audio data is noise, ignore it
            continue
        
        # Calculates the fundamental frequency
        note = calculateF0(audio_data, fs, f0_min, f0_max)

        # Filters by the fundamental frequency
        if note < f0_min or note > f0_max:
            continue
        
        # Display the fundamental frequency
        print(" Fundamental frequency: {:.2f}".format(note))

        # Wait for new audio data
        event.clear()

# Main function
if __name__ == "__main__":
    print("\n\nProgram started. Press Ctrl+C to stop.")
    fs = 44100  # Hz
    audio_queue = queue.Queue()
    event = threading.Event()
    
    audio_thread = threading.Thread(target=get_audio_data, args=(fs, audio_queue, event))
    processing_thread = threading.Thread(target=process_audio_data, args=(fs, audio_queue, event))

    audio_thread.start()
    processing_thread.start()

    audio_thread.join()
    processing_thread.join()
