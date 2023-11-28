import numpy as np
import threading
import pyaudio
from scipy.signal import find_peaks


def calculateF0(audioData, fs):
    f0_min = 20; #Hz
    f0_max = 10000; #Hz

    # Calculate the autocorrelation of the signal
    correlation = np.correlate(audioData, audioData, mode='full')
    correlation = correlation[int(np.floor(correlation.size/2 + fs/f0_max)):]

    # Find the peaks in the autocorrelation
    peaks, _ = find_peaks(correlation)

    # Find the index of the highest peak
    highest_peak_index = np.argmax(peaks)

    # Calculate the fundamental frequency
    f0 = fs / (highest_peak_index + 1)

    return f0



def get_audio_data():
    # Set up PyAudio
    p = pyaudio.PyAudio()

    # Open stream
    stream = p.open(format=pyaudio.paInt16, channels=1, rate=44100, input=True, frames_per_buffer=1024)

    # Read from the stream
    audio_data = np.fromstring(stream.read(1024), dtype=np.int16)

    # Close the stream
    stream.stop_stream()
    stream.close()
    p.terminate()

    return audio_data

# Main function
if __name__ == "__main__":
    fs = 44100 #Hz

    while True:
        # Get audio data from microphone
        audioData = get_audio_data()

        # Calculate the fundamental frequency
        note = calculateF0(audioData, fs)
        
        print(note)




