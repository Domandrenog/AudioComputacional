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
t_y = (0:length(y) - 1) / newFs; % Time for the downsample signal


figure(1); 
subplot(2, 1, 1); plot(t_x, x, 'color', dark_blue); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Original'); xlim([0 21]);
subplot(2, 1, 2); plot(t_y, y, 'color', dark_green); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Após o Downsampling'); xlim([0 21]);


% Define analysis parameters
frameduration = 0.03;                              % 30ms  -> good for audio
framestep = 0.01;                                  % 10 ms -> 1/3 of the window, to be uniform
frameSize = frameduration * newFs;                 % Size of analysis frame in samples
overlap = (frameduration - framestep) * newFs;     % Overlap between frames in samples
window = hamming(frameSize);                       % Windowing function - in this case Hamming, can be rectangular
fprintf("Fsize: %d, overlap: %f, ", frameSize, overlap);
% Initialize variables to store short-term characteristics
numFrames = floor((length(y) - overlap) / (frameSize - overlap)); %Know number of frames

energy = zeros(numFrames, 1); %put everything at zero
zeroCrossingRate = zeros(numFrames, 1); %put everything at zero
f0 = zeros(numFrames, 1); %put everything at zero
<<<<<<< HEAD:tp2/work2_Real_v2.m

=======
f0_pitch = zeros(numFrames, 1); %put everything at zero

%frame = zeros(numFrames, 1); %put everything at zero
number_frame = 0;
>>>>>>> addd55fae1096c9a07cb1c4c8c539826c2ea6cea:tp2/work2_Real.asv
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

    % Calculate fundamental frequency using autocorrelation
    [f0(i), number_frame] = calculateF0Autocorrelation(frame, newFs, number_frame);
    % f0_pitch(i) = pitch(frame,newFs);
    
end
<<<<<<< HEAD:tp2/work2_Real_v2.m

figure(2); plot(10*log(energy),'color', dark_green); xlabel("Frame"); ylabel('Energia (dB)'); grid on; title("Energia por Frame"); drawnow;
figure(3); plot(zeroCrossingRate, 'color', dark_green); xlabel("Frame"); ylabel('Crossing Rate'); grid on; title("Crossing Rate por Frame"); drawnow;
figure(4); plot(f0, 'color', dark_green); xlabel("Frame"); ylabel('Frequency'); grid on; title("Fundamental frequency (f0)"); drawnow;
=======
aux = (1:length(energy)) .* framestep;

% Energy plot
figure(2); plot(aux, 10*log(energy),'color', dark_green); xlabel("Tempo (s)"); ylabel('Energia (dB)'); grid on; title("Energia por Frame"); xlim([0 21]); drawnow;

% Zero crossing plot
figure(3); plot(aux, zeroCrossingRate, '.', 'color', dark_green); xlabel("Tempo (s)"); ylabel('Taxa de passagem'); grid on; title("Taxa de passagem por zero em cada janela"); xlim([0 21]); drawnow;
zeroCrossingRate_filtered = medfilt1(zeroCrossingRate, 5);
figure(4); plot(aux, zeroCrossingRate_filtered, '.', 'color', dark_blue); xlabel("Tempo (s)"); ylabel('Taxa de passagem'); grid on; title("Taxa de passagem por zero em cada janela após filtro mediana"); xlim([0 21]); drawnow;


% Fundamental Freq. Plot
figure(5); plot(aux, f0, '.', 'color', dark_blue); xlabel("Frame"); ylabel('Frequency'); grid on; title("Frequência Fundamental por janela"); xlim([0 21]); drawnow;
f0_filterd = medfilt1(f0, 20);
absDiff = abs(f0 - f0_filterd);
f0_filterd(absDiff > 50) = NaN;
figure(6); plot(aux, f0_filterd, '.', 'color', dark_green); xlabel("Frame"); ylabel('Frequency'); grid on; title("Frequência Fundamental por janela após filtro"); xlim([0 21]); drawnow;
fprintf("\nValor médio f0: %.2f\n", mean(f0( (f0<150) & (f0>70))));

binEdges = 50:10:400;
figure(7); histogram(f0, binEdges, 'FaceColor', dark_blue); xlabel('Frequência Fundamental'); ylabel('Occorência em Janelas'); title('Ocurrência de valores de F0');
>>>>>>> addd55fae1096c9a07cb1c4c8c539826c2ea6cea:tp2/work2_Real.asv

fprintf("End of the program.\n")


% Define a function to calculate F0 using autocorrelation
<<<<<<< HEAD:tp2/work2_Real_v2.m
function f0 = calculateF0Autocorrelation(frame, fs)
% We need to search the second peak, because the first peak is always 0 
% The voice of man is between 70 and 250 Hz, so we need to find the peak in this interval

   fo_min = 70; %Hz
   fo_max = 1000; %Hz


    % Calculate autocorrelation
    autocorr = xcorr(frame);

    %Cut the negative length and only focus in the voice specter
    autocorr1 = autocorr((length(frame) + floor((1/fo_max)*fs)):(length(frame) + floor((1/fo_min)*fs)));
=======
function [f0, number_frame] = calculateF0Autocorrelation(frame, fs, number_frame)
    autocorr = xcorr(frame);
>>>>>>> addd55fae1096c9a07cb1c4c8c539826c2ea6cea:tp2/work2_Real.asv
    
    dark_blue = 1/255 * [3,37,126];
    dark_green = 1/255 * [0,100,0];


    % We need to search the second peak, because the first peak is always 0 
    % The voice of man is between 70 and 250 Hz, so we need to find the peak in this interval
    fo_min = 50; %Hz
    fo_max = 400; %Hz

    
    % Calculate autocorrelation
    autocorr2 = autocorr(length(frame) + floor(fs/fo_max) : end);


    % Find the index of the maximum peak in the autocorrelation function
<<<<<<< HEAD:tp2/work2_Real_v2.m
    [~, maxIdx] = max(autocorr1);
 
    % Calculate F0 using the index
    f0 = fs / (maxIdx + floor((1/fo_max)*fs)); %Somar estes pois foram cortados do index, logo ainda são necessarios para ter o index correto
    
    %if f0 > 245 || f0 < 71
        %f0 = 150;
    %end
=======
    [~, maxIdx] = max(autocorr2);
    % Calculate F0 using the index
    f0 = fs / (maxIdx + floor(fs/fo_max));
    number_frame = number_frame + 1;
    if(number_frame==1281)
        figure(10); 
        subplot(2,1,1); plot(autocorr, 'color', dark_blue, 'LineWidth', 1.5); xlabel("Indice"); ylabel("Magnitude"); title("Corr. frame 1281"); grid on;
        subplot(2,1,2); plot((length(frame) + floor(fs/fo_max) : length(autocorr)) ,autocorr(length(frame) + floor(fs/fo_max) : length(autocorr)), 'color', dark_green, 'LineWidth', 1.5); xlabel("Indice"); ylabel("Magnitude"); title("Corr. frame 1281 cortada"); grid on;
    end


>>>>>>> addd55fae1096c9a07cb1c4c8c539826c2ea6cea:tp2/work2_Real.asv

end


