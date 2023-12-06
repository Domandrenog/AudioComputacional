import numpy as np
import sounddevice as sd
from scipy.signal import find_peaks
import threading
import queue
from music21 import stream, note, midi
import pygame


# Global variable to store acquired audio data
audioData = []

# Identify if the audio data is noise or not
def identifyNoise(audioData, fs):
    energy_threshold = 10e-5

    energy = np.sum(audioData ** 2) / len(audioData)
    if energy < energy_threshold:
        return True  # Noise
    else:
        return False  # Not noise

# Determines the fundamental frequency of the audio data
def calculateF0(audioData, fs):
    f0_min = 20  # Hz
    f0_max = 10000  # Hz

    # Calculate the autocorrelation of the signal
    correlation = np.correlate(audioData, audioData, mode='full')
    correlation = correlation[int(np.floor(correlation.size / 2 + fs / f0_max)):]

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

# Process audio data and display notes using MIDI playback
def process_audio_data(fs, audio_queue, event):
    while True:
        # Create a new part for each iteration
        part = stream.Part()

        audio_data = audio_queue.get()
        if identifyNoise(audio_data, fs):  # If the audio data is noise, ignore it
            continue

        note_freq = calculateF0(audio_data, fs)
        print("Fundamental frequency: {:.2f} Hz".format(note_freq))

        print("DEBUG 1")
        # Convert frequency to MIDI note number
        midi_note = int(round(12 * np.log2(note_freq / 440) + 69))
        n = note.Note(midi=midi_note, quarterLength=0.5)  # Adjust quarterLength as needed
        part.append(n)
        print("DEBUG 2")

        # Display the musical notation graphically
        score = stream.Score()
        score.append(part)
        print("DEBUG 3")
        # Play the MIDI in real-time
        player = midi.realtime.StreamPlayer(score)
        print("DEBUG 4")
        player.play()
        
        event.clear()
        print("DEBUG 5")


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
    
    
