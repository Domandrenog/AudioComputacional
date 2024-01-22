%color for plots
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];
dark_orange = 1/255 * [255, 165, 0];
darl_purple = 1/255 * [153, 51, 153];

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

% Plot the Original Signal and Downsampled one
figure(1); 
subplot(2, 1, 1); plot(t_x, x, 'color', dark_blue); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Original'); xlim([0 21]);
subplot(2, 1, 2); plot(t_y, y, 'color', dark_green); xlabel('Tempo (s)'); ylabel('Amplitude'); grid on; title('Sinal Após o Downsampling'); xlim([0 21]);

% Define analysis parameters
frameduration = 0.03;                              % 30ms  -> good for audio
framestep = 0.01;                                  % 10 ms -> 1/3 of the window, to be uniform
frameSize = frameduration * newFs;                 % Size of analysis frame in samples
overlap = (frameduration - framestep) * newFs;     % Overlap between frames in samples
window = hamming(frameSize);                       % Windowing function - in this case Hamming, can be rectangular
numFrames = floor((length(y) - overlap) / (frameSize - overlap)); % Know number of frames

% Initialize variables to store short-term characteristics
energy = zeros(numFrames, 1); 
zeroCrossingRate = zeros(numFrames, 1); 
f0 = zeros(numFrames, 1); 
f0_pitch = zeros(numFrames, 1); 
speech = zeros(numFrames, 1); 
non_speech = zeros(numFrames, 1); 
vozeada = zeros(numFrames, 1); 
nao_vozeada = zeros(numFrames, 1); 
mix_vozeada = zeros(numFrames, 1);

% Speech detection 
energy_threshold = 0.2;
tp0_threshold = 0.15;
mix_threshold = 0.1;

% Statistic variables
count = zeros(5, 1);
number_frame = 0;

% Perform sliding analysis
for i = 1:numFrames
    startIdx = floor((i - 1) * (frameSize - overlap) + 1); % Define where the variable starts to save, so needs to be in this case 10 in 10, so the first index is 1 then 11,21,31
    endIdx = floor(startIdx + frameSize - 1); % Define the end point of duration so 10,20,30...
    frame = y(startIdx:endIdx); % Frame is the size of the frameSize-Overlap and between the spaces

    % Analyse a specific frame
    if i==231
        %figure(11); plot(frame); title("Frame 231 - 0.65"); grid on;
    end

    % Apply windowing function to the frame
    frame = frame .* window;
    
    %% Calculate short-term characteristics for the frame (enerfy, ZCr, F0
    energy(i) = sum(frame.^2); 
    zeroCrossingRate(i) = sum(abs(diff(frame > 0.0))) / (frameSize); %In the slides, everything the same besides "diff(frame > 0.0)", this puts 1 when its above 0 and 0 when below 0, so the difference is 1 when change the signal, thats what we want
    [f0(i), number_frame] = calculateF0Autocorrelation(frame, newFs, number_frame);
    
    %% Speech characterization
    if energy(i) < energy_threshold % Case of silence
        non_speech(i) = 0.6;
        speech(i) = NaN;
        vozeada(i) = NaN;
        nao_vozeada(i) = NaN;
        mix_vozeada(i) = NaN;
        count(1) = count(1) + 1;
    
    else % Case of speech
        speech(i) = 1;
        non_speech(i) = NaN;
        count(5) = count(5) +1;
        if (zeroCrossingRate(i) < mix_threshold) % voiced speech
            nao_vozeada(i) = NaN;
            mix_vozeada(i) = NaN;
            vozeada(i) = 0.9;
            count(2) = count(2) + 1;
        elseif (zeroCrossingRate(i) > mix_threshold) && (zeroCrossingRate(i) < tp0_threshold) % Mix speech
            mix_vozeada(i) = 0.8;
            nao_vozeada(i) = NaN;
            vozeada(i) = NaN;
            count(3) = count(3) + 1;
        else % non voiced speech
            nao_vozeada(i) = 0.7;
            vozeada(i) = NaN;
            mix_vozeada(i) = NaN;
            count(4) = count(4) + 1;
        end
    end
end

%% Plots Results
% Convert from frame to time
aux = (1:length(energy)) .* framestep;

% Energy plot
figure(2); plot(aux, 10*log(energy),'color', dark_green); xlabel("Tempo (s)"); ylabel('Energia (dB)'); grid on; title("Energia por Frame"); xlim([0 21]); drawnow;
fprintf("Valor médio Energia: %.2f\n", mean(10*log10(abs(energy))));

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
fprintf("Valor médio f0: %.2f\n", mean(f0( (f0<150) & (f0>70))));

% Fundamental Freq. histogram
binEdges = 50:10:400;
figure(7); histogram(f0, binEdges, 'FaceColor', dark_blue); xlabel('Frequência Fundamental'); ylabel('Occorência em Janelas'); title('Ocurrência de valores de F0');

% Speech plot
figure(7); 
plot(t_y, y, 'color', dark_blue); xlabel("Tempo (s)"); ylabel('Amplitude'); grid on; xlim([0 21]);
hold on;
plot(aux, speech, '.', 'color', dark_green); xlabel("Tempo (s)"); ylabel('Presença de fala'); grid on; title("Deteção de momentos de fala");
hold on;
plot(aux, non_speech, '.', 'color', 'r'); xlabel("Tempo (s)"); ylabel('Presença de fala'); grid on; title("Deteção de momentos de fala"); 
hold on;
plot(aux, vozeada, '.', 'color', dark_orange); xlabel("Tempo (s)"); ylabel('Presença de fala'); grid on; title("Deteção de momentos de fala");
hold on;
plot(aux, nao_vozeada, '.', 'color', darl_purple); xlabel("Tempo (s)"); ylabel('Presença de fala'); grid on; title("Deteção de momentos de fala"); 
hold on;
plot(aux, mix_vozeada, '.', 'color', 'r'); xlabel("Tempo (s)"); ylabel('Presença de fala'); grid on; title("Deteção de momentos de fala"); xlim([12 14]); ylim([-1 1.1]);
legend('Sinal', 'Presença de voz', 'vozeada', 'não vozeada', 'mix',  'Location', 'SouthEast');
drawnow;

% Speech Histogram - Não funciona nos PCs só no MATLAB online
%soma = count(5) + count(1);
%categories = ["voz total" "vozeado" "mix" "não vozeado" "silencio"];
%values = [count(5)/soma count(2)/soma count(3)/soma count(4)/soma count(1)/soma];
%figure(8);
%bar(categories, values);
%ylabel("Total de Ocurrências (%)");
%title("Ocurrência do tipo de voz e do silêncio");

fprintf("End of the program.\n")

%% Define a function to calculate F0 using autocorrelation
function [f0, number_frame] = calculateF0Autocorrelation(frame, fs, number_frame)
    autocorr = xcorr(frame);
    
    dark_blue = 1/255 * [3,37,126];
    dark_green = 1/255 * [0,100,0];


    % We need to search the second peak, because the first peak is always 0 
    % The voice of man is between 70 and 250 Hz, so we need to find the peak in this interval
    fo_min = 50; %Hz
    fo_max = 400; %Hz

    
    % Calculate autocorrelation
    autocorr2 = autocorr(length(frame) + floor(fs/fo_max) : end);

    % Find the index of the maximum peak in the autocorrelation function
    [~, maxIdx] = max(autocorr2);
    % Calculate F0 using the index
    
    f0 = fs / (maxIdx + floor(fs/fo_max));
    number_frame = number_frame + 1;
    if(number_frame==1281)
        figure(10); 
        subplot(2,1,1); plot(autocorr, 'color', dark_blue, 'LineWidth', 1.5); xlabel("Indice"); ylabel("Magnitude"); title("Corr. frame 1281"); grid on;
        subplot(2,1,2); plot((length(frame) + floor(fs/fo_max) : length(autocorr)) ,autocorr(length(frame) + floor(fs/fo_max) : length(autocorr)), 'color', dark_green, 'LineWidth', 1.5); xlabel("Indice"); ylabel("Magnitude"); title("Corr. frame 1281 cortada"); grid on;
    end
end


