% 1. Load the audio file (replace 'input_audio.wav' with your audio file's name)
inputFileName = 'ASRF24.wav';
[x, fs] = audioread(inputFileName);

% 2. Apply downsampling
newFs = 16000; % Target sampling rate
y = resample(x, newFs, fs);

% 3. Save the downsampled audio to a new file (optional)
outputFileName = 'downsampled_audio.wav'; % Replace with your desired output file name
audiowrite(outputFileName, y, newFs);

% Optionally, you can also play the downsampled audio
sound(y, newFs);

% Display information about the original and downsampled audio
fprintf('Original Sampling Rate: %d Hz\n', fs);
fprintf('New Sampling Rate: %d Hz\n', newFs);

