close all
clear all
clc


% audio_name = './Acustic_piano_record_MacOS.wav';
audio_name = '/Users/andbrarata/Downloads/tp1/audios/c_major_sine.wav';

% Read an MP3 file
[y, fs] = audioread(audio_name);

% Play the audio
sound(y, fs);


plot_fft(y, fs)
plot_spectrogram(y, fs)


function plot_fft(data, fs)
    dark_green = 1/255 * [0,100,0];
    dark_blue = 1/255 * [3,37,126];

    N = length(data);
    Y = fft(data);
    
    f = (0:N-1) * fs / N;

    C_notes = [261.63, 293.66, 329.63, 349.23, 392, 440, 493.88, 523.25];
    G = 392*2;

    % Plot the waveform
    figure(1); plot(f,10*log(abs(Y)), 'color', dark_blue); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('C note on Piano - FFT'); set(gca, 'XScale', 'log'); xlim([10^2, 10^3]);
    text(C_notes(1), 10*log(5000), 'C', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(2), 10*log(5000), 'D', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(3), 10*log(5000), 'E', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(4), 10*log(5000), 'F', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(6), 10*log(5000), 'A', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(5), 10*log(5000), 'G', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(7), 10*log(5000), 'B', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(C_notes(8), 10*log(5000), 'C', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    %text(G, 10*log(5000), 'G', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end


function plot_spectrogram(data, fs, window_size, overlap, nfft)
    % Para parametros opcionais
    if ~exist('window_size', 'var') window_size = 1024; end
    if ~exist('overlap', 'var') overlap = 512; end
    if ~exist('nfft', 'var') nfft = 1024; end
    y = reshape(data, [], 1);
    [S, f, t] = spectrogram(y, window_size, overlap, nfft, fs);
    figure(2); imagesc(t, f, 10*log10(abs(S))); axis xy; colormap(jet); colorbar; xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('C note on Piano'); ylim([10, 10^3]);


end
