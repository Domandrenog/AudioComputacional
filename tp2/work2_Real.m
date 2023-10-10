close all
clear all
clc

%color for plots
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];


% Load the audio file
fprintf("Start of the Program.\n")
inputFileName = 'ASRF24.wav';
[x, fs] = audioread(inputFileName); %fs = 44100Hz, we need 16000Hz
fprintf("Length of the audio: %d\n", length(x));
fprintf("Duration of the audio: %.2f\n", length(x)/fs);
% Play the audio-> sound(x, fs); %(audio,frequency) 

%Apply downsampling
newFs = 16000; % Target sampling rate
y = resample(x, newFs, fs);
% Time in the signal
t_x = (0:length(x) - 1) / fs; % Time for original signal
t_y = (0:length(y) - 1) / newFs; % Time for the 


figure(1); 
subplot(2, 1, 1); plot(t_x, x, 'color', dark_green); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Original'); xlim([0 21]);
subplot(2, 1, 2); plot(t_y, y, 'color', dark_green); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Após o Downsampling'); xlim([0 21]);
% Define analysis parameters
frameduration = 0.03;                              % 30ms  -> good for audio
framestep = 0.01;                                  % 10 ms -> 1/3 of the window, to be uniform like this ---------, if not can be like this /---\
frameSize = frameduration * newFs;                 % Size of analysis frame in samples
overlap = (frameduration - framestep) * newFs;     % Overlap between frames in samples - in this case 20 ms overlap -> 2/3 of the window
window = hamming(frameSize);                       % Windowing function - in this case Hamming, can be rectangular

% Initialize variables to store short-term characteristics
numFrames = floor((length(y) - overlap) / (frameSize - overlap)); %Know number of frames

energy = zeros(numFrames, 1); %put everything at zero
zeroCrossingRate = zeros(numFrames, 1); %put everything at zero
f0 = zeros(numFrames, 1); %put everything at zero
%frame = zeros(numFrames, 1); %put everything at zero


% Perform sliding analysis
for i = 1:numFrames
    startIdx = floor((i - 1) * (frameSize - overlap) + 1); %Define where the variable starts to save, so needs to be in this case 10 in 10, so the first index is 1 then 11,21,31
    endIdx = floor(startIdx + frameSize - 1); %Define the end point of duration so 10,20,30...
    frame = y(startIdx:endIdx); %Frame is the size of the frameSize-Overlap and between the spaces
    if i==231
        % Analise de um frame específico (231 tem muitos zero crossing)
        %figure(7); plot(frame); title("Frame 231 - 0.65"); grid on;
    end
    % Apply windowing function to the frame
    frame = frame .* window;
    
    % Calculate short-term characteristics for the frame
    energy(i) = sum(frame.^2); %In the slides
    zeroCrossingRate(i) = sum(abs(diff(frame > 0.0))) / (frameSize); %In the slides, everything the same besides "diff(frame > 0.0)", this puts 1 when its above 0 and 0 when below 0, so the difference is 1 when change the signal, thats what we want
    %Not 2*framesize because in this case dont give as 2, but instead 1
    
end
figure(2); plot(10*log(energy),'color', dark_green); xlabel("Frame"); ylabel('Energia (dB)'); grid on; title("Energia por Frame"); drawnow;
figure(3); plot(zeroCrossingRate, 'color', dark_green); xlabel("Frame"); ylabel('Crossing Rate'); grid on; title("Crossing Rate por Frame"); drawnow;

fprintf("End of the program.\n")
