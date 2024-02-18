close all
clear all
clc

disp('Program stared!');

% Define recording parameters
fs = 44100;        
duration = 5;     

% Create an audiorecorder object
recorder = audiorecorder(fs, 16, 1);

% Create a figure for real-time plotting
figure(3);
h = plot(0, 0);  % Initialize an empty plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Real-Time Audio Plot');
axis([0, duration, -1, 1]);  

% Define an event handler function to update the plot
recorder.TimerFcn = @(src, event) updatePlot(src, event, h, fs);

% Start recording
disp('Recording...');
record(recorder);

% Wait for recording to complete
pause(duration);

% Stop and release the recorder
stop(recorder);

disp('Recording completed.');

% Event handler function to update the plot
function updatePlot(src, ~, plotHandle, sampleRate)

    audioData = getaudiodata(src);
    time = (1:length(audioData)) / sampleRate;

    set(plotHandle, 'XData', time, 'YData', audioData); drawnow;
    %audiowrite("Acustic_piano_batimento_record_MacOS.wav", audioData, sampleRate); % Descomentar para gravar o audio
    plot_spectrogram(audioData, sampleRate)
    plot_fft(audioData, sampleRate)

end

function plot_fft(data, fs)
    dark_green = 1/255 * [0,100,0];
    dark_blue = 1/255 * [3,37,126];

    N = length(data);
    Y = fft(data);
    
    f = (0:N-1) * fs / N;

    C_notes = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25];
    % Plot the waveform
    figure(1); plot(f,10*log(abs(Y)), 'color', dark_blue); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('FFT of C sclae with sine waves'); set(gca, 'XScale', 'log'); xlim([10, 10^3]);
    text(C_notes(1), 20*log(5000), 'C', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(2), 20*log(5000), 'D', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(3), 20*log(5000), 'E', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(4), 20*log(5000), 'F', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(5), 20*log(5000), 'G', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(6), 20*log(5000), 'A', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(7), 20*log(5000), 'B', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(8), 20*log(5000), 'C', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

function plot_spectrogram(data, fs, window_size, overlap, nfft)
    % Para parametros opcionais
    if ~exist('window_size', 'var') window_size = 1024; end
    if ~exist('overlap', 'var') overlap = 512; end
    if ~exist('nfft', 'var') nfft = 1024; end
    y = reshape(data, [], 1);
    [S, f, t] = spectrogram(y, window_size, overlap, nfft, fs);
    figure(2); imagesc(t, f, 10*log10(abs(S))); axis xy; colormap(jet); colorbar; xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('Spectrogram of C scale'); ylim([10^2, 10^3]);

    
end

