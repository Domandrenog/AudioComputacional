% Script que segmenta o sinal em segmentos vocalizados, 
% noise e silencio baseado na energia e taxa de passagem 
% por zero do sinal de fala segundo o livro 
% "Digital Processing of Speech Signal" de Rabiner e Schafer.
% Detalhado em Teixeira, J. P., Análise e Síntese de Fala – Modelização
% Paramétrica de Sinais Para Sistemas TTS. Editorial Académica Española
% ISBN: 978-3-659-06206-3, 2013. pág. 96 e 209.
clear all
close all

%color for plots
dark_green = 1/255 * [0, 100, 0];
dark_blue = 1/255 * [3, 37, 126];

% Load the audio file
fprintf("Start of the Program.\n")
inputFileName = 'ASRF24.wav';
[x, fs] = audioread(inputFileName); %fs = 44100Hz, we need 16000Hz

%Apply downsampling
newFs = 16000; % Target sampling rate
y = resample(x, newFs, fs);

espacamento = 10;

% Calculate time in seconds
t_y = (0:length(y) - 1) / newFs; % Time for the downsample signal

% Define analysis parameters
frameduration = 0.03;                              % 30ms  -> good for audio
framestep = 0.01;                                  % 10 ms -> 1/3 of the window, to be uniform
frameSize = frameduration * newFs;                 % Size of analysis frame in samples
overlap = (frameduration - framestep) * newFs;     % Overlap between frames in samples
window = hamming(frameSize);                       % Windowing function - in this case Hamming, can be rectangular
% Initialize variables to store short-term characteristics
numFrames = floor((length(y) - overlap) / (frameSize - overlap)); %Know number of frames

energy = zeros(numFrames, 1); %put everything at zero
zeroCrossingRate = zeros(numFrames, 1); %put everything at zero
f0 = zeros(numFrames, 1); %put everything at zero
f0_pitch = zeros(numFrames, 1); %put everything at zero
%frame = zeros(numFrames, 1); %put everything at zero
number_frame = 0;

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

m = fmedia(energy, 5, 1);
energia = fmedia(m, 3, 1); % Alisamento
LSES = max(energia(1:100));


der = fderivad(y);
zero = fzeros2(der, 50, espacamento); % Taxa de passagem por zero da derivada
m = fmedia(zero, 5, 1);
zero = fmedia(m, 3, 1); % Alisamento
LIZ = min(zero(3:70)); % Limite Inferior da Taxa de Passagem por Zero

car = zeros(round(length(y) / (espacamento * 10)), 2);
s = zeros(round(length(y) / (espacamento * 10)), 1);
decisao = zeros(round(length(y) / (espacamento * 10)), 1);

for i = 0:10:length(energia) - 10
    z = 0;
    e = 0;
    for j = 1:10
        if zero(i + j) > LIZ, z = z + 1; end
        if energia(i + j) < LSES, e = e + 1; end
    end
    car(i / 10 + 1, 1) = e; % Energia
    car(i / 10 + 1, 2) = z; % Taxa de Passsagem por zero
end
s = sum(car, 2);

% Matriz de decisão com 3 classes
% Decisao = 0 -> nao definido; 1 -> silencio; 3 -> excitado por ruido (noise); 4 -> vocalizado;

for i = 1:length(decisao)
    if s(i) >= 14, decisao(i) = 1;
    elseif s(i) < 6, decisao(i) = 4;
    elseif (car(i, 1) < 3 && car(i, 2) > 5), decisao(i) = 3;
    end
end
for i = 3:length(decisao)
    if decisao(i - 2) == decisao(i)
        decisao(i - 1) = decisao(i);
    end
end

figure;
plot(t_y, y / max(y) * 4, 'y', 100 * (1:length(decisao)) / newFs, decisao, '.'); xlim([0, 21]);
title('Classificação: 0 - Indefinido, 1 - Silêncio, 3 - Ruido e 4 - Voz');

figure; plot(t_y, y/max(y)*4, 'y', 100*(1:length(decisao)) / newFs, decisao, '.'); xlim([15, 16]);
title('Classificação: 0 - Indefinido, 1 - Silêncio, 3 - Ruido e 4 - Voz');

binEdges = 0:0.5:5; x = 0.3:1:4.3; novo_rotulo_x = {'Indefinido', 'Silêncio', '', 'Ruido', 'Voz'}; % Rotulos
figure(7); histogram(decisao, binEdges, 'FaceColor', dark_blue); ylabel('Total de ocorrências'); xticks(x); xticklabels(novo_rotulo_x);
title('Número de ocorrências de Indefinido, Silêncio, Ruido e Voz');




% Matriz de decisão com 5 classes
% Decisao= 0->Não dedinido; 1-> silencio; 2-> excitado por ruido (noise);
% 2,5-> Excitação noise/mista 3-> mista; 4-> vocalizado

for i=1:length(decisao)
   if (s(i)>=12 && (car(i,1)>8 || car(i,2)>8)), decisao(i)=1; end
   if (car(i,1)<=8 && car(i,2)<=3), decisao(i)=4; end
   if (car(i,1)<3 && car(i,2)>3), decisao(i)=2; end
   if (car(i,1)<=6 && car(i,1)>=3 && car(i,2)>3 && car(i,2)<=8), decisao(i)=3; end
   if (car(i,1)<3 && car(i,2)>3 && car(i,2)<=8), decisao(i)=2.5; end
end
for i=3:length(decisao) 
     if decisao(i-2)==decisao(i) 
         decisao(i-1)=decisao(i); 
     end
end
figure;plot(t_y,y/max(y)*4,'y',100*(1:length(decisao)) / newFs,decisao,'.'); xlim([0, 21]);
title('Classificação: 0-Indef. 1-Silê. 2-Ruído 2.5-Comum; 3-Mix 4-Voz');

figure; plot(t_y, y/max(y)*4, 'y', 100*(1:length(decisao)) / newFs, decisao, '.');xlim([15, 16]);
title('Classificação: 0-Indef. 1-Silê. 2-Ruído 2.5-Comum; 3-Mix 4-Voz');

binEdges = 0:0.5:5; x = [0.3, 1.3, 2.3, 2.81, 3.3, 4.3]; novo_rotulo_x = {'Indefinido', 'Silêncio', 'Ruido', 'Normal', 'Mix', 'Voz'};
figure(8); histogram(decisao, binEdges, 'FaceColor', dark_blue); ylabel('Total de ocorrências'); xticks(x); xticklabels(novo_rotulo_x);
title('Número de ocorrências de Indefinido, Silêncio, Ruido, Comum, Mix e Voz');


% figure;plot(zero);title('zeros');
% figure;plot(energia);title('energia');
% figure;plot((1:length(y)),sinal/max(y)*4,'y',100*(1:length(decisao)),decisao,'r',100*(1:length(decisao)),car(:,1)/2.5,'g',100*(1:length(decisao)),car(:,2)/2.5,'b');

