%% vozeado e não vozeado teste


fs = 44100;  % Sample rate in Hz (adjust as needed)
bitsPerSample = 16;  % 16 bits per sample (adjust as needed)
recorder = audiorecorder(fs, bitsPerSample, 1);  % Mono audio



record(recorder);
disp('Recording... Press any key to stop.');
pause;

stop(recorder);
disp('Recording stopped.');

audioData = getaudiodata(recorder);

audioFileName = 'teste_vozeado.wav';  % Specify the desired file name and format
audiowrite(audioFileName, audioData, fs);
