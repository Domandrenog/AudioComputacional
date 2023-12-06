%% Analise por frame


clear all
close all

% color for plot
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];



% 1. Análise
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
x = (1:length(y))/fs_new;
fs = fs_new;

% Segmentação
% "Que os homens" -> "Cuzomens"
seconds_a = floor(17.30*fs); 
seconds_b = floor(17.85*fs);
y = y(seconds_a:seconds_b);
x = x(seconds_a:seconds_b);

% Parâmetros LPC
p = 12;
seg_duration = 0.1; % 30 ms was 0.03
overlap = 2/3;

% Janela de Hamming
window = hamming(round(seg_duration * fs));
step = round((1 - overlap) * length(window));

% Pré-ênfase
alpha = 0.98;
y_preemph = filter([1, -alpha], 1, y);
y_preemph = y;

% Inicialização de variáveis
num_frames = floor((length(y_preemph) - length(window)) / step); % Nº de frames
lpc_coeffs = zeros(num_frames, p+1); 
r = zeros(num_frames, length(window));
frame_matrix = zeros(num_frames, length(window));
reconstructed_signal = zeros(size(y_preemph));
len_window = length(window);

% Parametros Ruido
noiseMean = 0.1;
noiseStd = 0.1;



%% Controi frames
i = 0;

% -----------------   
% Frame #1 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 103.46;
    res = generatePeriodicVector(length(frame), f0, fs);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
    
    i = i +1;

% -----------------   
% Frame #2 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 100.78;
    res = generatePeriodicVector(length(frame), f0, fs);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #3 - Mix
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 99.72;
    res = awgn(generatePeriodicVector(length(frame), f0, fs), 30);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #4 - Mix
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 101.46;
    res = awgn(generatePeriodicVector(length(frame), f0, fs), 30);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;    

% -----------------   
% Frame #5 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 102.69;
    res = generatePeriodicVector(length(frame), f0, fs);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i + 1;    

% -----------------   
% Frame #6 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 100.00;
    res = generatePeriodicVector(length(frame), f0, fs);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #7 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 96.00;
    res = generatePeriodicVector(length(frame), f0, fs)*0.6;

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #8 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 93.28;
    res = generatePeriodicVector(length(frame), f0, fs)*0.6;

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;  

% -----------------   
% Frame #9 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 91.58;
    res = generatePeriodicVector(length(frame), f0, fs)*0.6;

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #10 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 90.73;
    res = generatePeriodicVector(length(frame), f0, fs)*0.6;

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #11 - Voiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    f0 = 89.90;
    res = generatePeriodicVector(length(frame), f0, fs)*0.6;

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;

% -----------------   
% Frame #12 - Unvoiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    res = awgn(ones(length(frame), 1), 5);
    res = res/(max(res)*15);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
  
    i = i +1;    

% -----------------   
% Frame #13 - Unvoiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    res = awgn(ones(length(frame), 1), 5);
    res = res/(max(res)*15);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
    
    i = i + 1;

% -----------------   
% Frame #13 - Unvoiced
    frame = y_preemph(i*step+1:len_window + step*i) .* window;
    [lpc_coeffs, ~] = lpc(frame, p); % Apenas os coeficientes
    res = awgn(ones(length(frame), 1), 5);
    res = res/(max(res)*15);

    % Recontrução
    compressed_frame = filter(1, lpc_coeffs, res);
    reconstructed_signal(i*step + 1 : i*step + len_window) = (reconstructed_signal(i*step + 1 : i*step + len_window) + compressed_frame);
    



figure; 
subplot(2,1,1); plot((1:length(y_preemph))/fs + 17.30, y_preemph, 'Color', dark_green); title("Reconstructed compressed signal"); xlabel("time (s)")
subplot(2,1,2); plot((1:length(reconstructed_signal))/fs + 17.30, reconstructed_signal, 'Color', dark_blue); title("Original Signal"); xlabel("time (s)")

% Nome do arquivo de áudio para salvar
nome_arquivo = 'Sinal_Re_sintetizado_com_Ruído_Sintético.wav';
% Salvando o sinal de áudio
audiowrite(nome_arquivo, reconstructed_signal, fs);

% Nome do arquivo de áudio para salvar
nome_arquivo = 'Sinal_Original_para_comparar_com_Ruído_Sintético.wav';
% Salvando o sinal de áudio
audiowrite(nome_arquivo, y_preemph, fs);

function periodicVector = generatePeriodicVector(len, F0, Fs)

    periodicVector = zeros(len, 1);

    % Periodicidade dos impulsos relativamente ao numero de samples
    periodSamples = floor(Fs / F0);
    
    for n = 1:len
        if mod(n, periodSamples) == 0
            periodicVector(n) = 1;
        end
    end
end
