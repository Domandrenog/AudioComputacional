close all
clear all
clc

%color for plots
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];

% Define parameters
sampling_rate = 16000; % Sampling rate in Hz
duration = 1; % Duration of the signal in seconds
period = 0.01; % 10 ms period between peaks (0s and 1s)

% Calculate the number of samples
num_samples = round(sampling_rate * duration);

% Create the signal
signal = zeros(1, num_samples);

% Define the period in samples
period_samples = round(sampling_rate * period);

% Fill the signal with alternating 0s and 1s
for i = 1:period_samples:num_samples
    signal(i) = 1;
end

% Plot the signal
time = (0:num_samples-1) / sampling_rate;
figure(7);
plot(time, signal);
xlabel('Time (s)');
ylabel('Amplitude');
title('Signal with Alternating 0s and 1s');
grid on;


%Apply downsampling
newFs = 16000; % Target sampling rate




% Define analysis parameters
frameduration = 0.01;                              % 30ms  -> good for audio
framestep = 0.0033;                                  % 10 ms -> 1/3 of the window, to be uniform like this ---------, if not can be like this /---\
frameSize = frameduration * newFs;                 % Size of analysis frame in samples
overlap = (frameduration - framestep) * newFs;     % Overlap between frames in samples - in this case 20 ms overlap -> 2/3 of the window
window = hamming(frameSize);                       % Windowing function - in this case Hamming, can be rectangular

% Initialize variables to store short-term characteristics
numFrames = floor((length(signal) - overlap) / (frameSize - overlap)); % Number of frames to analyze

energy = zeros(numFrames, 1); % Initialize energy array for frames
zeroCrossingRate = zeros(numFrames, 1); % Initialize zero-crossing rate array for frames
f0 = zeros(numFrames, 1); % Initialize F0 array for frames



% Perform sliding analysis
for i = 1:numFrames
    startIdx = floor((i - 1) * (frameSize - overlap) + 1); % Define where the variable starts to save, so needs to be in this case 10 in 10, so the first index is 1 then 11,21,31
    endIdx = floor(startIdx + frameSize - 1); % Define the end point of duration so 10,20,30...
    frame = signal(startIdx:endIdx); % Frame is the size of the frameSize-Overlap and between the spaces

    % Apply windowing function to the frame
    frame = frame .* window;

    % Verificar o tamanho das variáveis envolvidas
    fprintf('Tamanho de "energy": %d\n', numel(energy));
    fprintf('Tamanho de "frame": %d\n', numel(frame));

    % Calculate short-term characteristics for the frame
    %energy(i) = sum(frame.^2); % In the slides
    %zeroCrossingRate(i) = sum(abs(diff(frame > 0.0))) / (frameSize); % In the slides, everything the same besides "diff(frame > 0.0)", this puts 1 when it's above 0 and 0 when below 0, so the difference is 1 when changing the signal, that's what we want

    % Calculate fundamental frequency using autocorrelation
    f0(i) = calculateF0Autocorrelation(frame, newFs);
end


%figure(2); plot(10*log(energy),'color', dark_green); xlabel("Frame"); ylabel('Energia (dB)'); grid on; title("Energia por Frame"); drawnow;
%figure(3); plot(zeroCrossingRate, 'color', dark_green); xlabel("Frame"); ylabel('Crossing Rate'); grid on; title("Crossing Rate por Frame"); drawnow;
figure(4); plot(f0, 'color', dark_green); xlabel("Frame"); ylabel('Frequency'); grid on; title("Fundamental frequency (f0)"); drawnow;

fprintf("End of the program.\n")

% Define a function to calculate F0 using autocorrelation
function f0 = calculateF0Autocorrelation(frame, fs)
% We need to search the second peak, because the first peak is always 0 
% The voice of man is between 70 and 250 Hz, so we need to find the peak in this interval

   fo_min = 70; %Hz
   fo_max = 250; %Hz

%   fo_test = floor((1/fo_min)*fs);
%   fo_test2 = floor((1/fo_max)*fs);
%   length_frame = length(frame);
%   fprintf("Tamanho %f Minimo %f Máximo %f \n", length_frame, fo_test, fo_test2);

    % Calculate autocorrelation
    autocorr = xcorr(frame);

    autocorr1 = autocorr((length(frame) + floor((1/fo_max)*fs)):(length(frame) + floor((1/fo_min)*fs)));
    
    % Find the index of the maximum peak in the autocorrelation function
    [~, maxIdx] = max(autocorr1);
    %fprintf("Indice %f \n", maxIdx);

    % Calculate F0 using the index
    f0 = fs / maxIdx;
    
end


