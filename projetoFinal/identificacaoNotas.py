import numpy as np
import sounddevice as sd
from scipy.signal import find_peaks

def calculateF0(audioData, fs):
    f0_min = 20  # Hz
    f0_max = 10000  # Hz

    # Calculate the autocorrelation of the signal
    correlation = np.correlate(audioData, audioData, mode='full')
    correlation = correlation[int(np.floor(correlation.size/2 + fs/f0_max)):]

    # Find the peaks in the autocorrelation
    peaks, _ = find_peaks(correlation)

    # Find the index of the highest peak
    highest_peak_index = peaks[np.argmax(correlation[peaks])]

    # Calculate the fundamental frequency
    f0 = fs / (highest_peak_index + 1)

    return f0

def get_audio_data(fs):
    seconds = 1  # Duration of recording

    audio_data = sd.rec(int(seconds * fs), samplerate=fs, channels=1)
    sd.wait()  # Wait for the recording to finish

    if audio_data.ndim > 1:
        audio_data = np.mean(audio_data, axis=1)

    return np.array(audio_data)

# Main function
if __name__ == "__main__":
    fs = 44100  # Hz

    while True:
        # Get audio data from microphone
        audioData = get_audio_data(fs)

        # Calculate the fundamental frequency
        note = calculateF0(audioData, fs)

        print(note)