clear all
% 1. Análise
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
fs = fs_new;

% Parâmetros LPC
p = 12;
seg_duration = 0.03; % 30 ms
overlap = 2/3;

% Janela de Hamming
window = hamming(round(seg_duration * fs));
step = round((1 - overlap) * length(window));

% Pré-ênfase
alpha = 0.98;
y_preemph = filter([1, -alpha], 1, y);

% Inicialização de variáveis
num_frames = floor((length(y_preemph) - length(window)) / step);
lpc_coeffs = zeros(p+1, num_frames);
residuals = zeros(size(y_preemph));
r = zeros(length(window), num_frames);

% Análise LPC deslizante
for i = 1:num_frames
    frame = y_preemph((i-1)*step + 1 : (i-1)*step + length(window)) .* window;
    %[lpc_coeffs(:, i), residuals((i-1)*step + 1 : i*step)] = LPC_analysis(frame, p);
    [lpc_coeffs(:, i), r(:,i)] = LPC_analysis(frame, p);
    
    residuals((i-1)*step + 1 : (i-1)*step + length(window)) = r(:,i);
end

% 1.2 Apreciação do sinal de erro

% Create a new figure window
figHandle = figure();

% Create a subplot in the figure window
subplot(2,1,1);
plot(y_preemph, 'b'); title('Original Signal');

% Create another subplot in the same figure window
subplot(2,1,2);
plot(residuals(:), 'r'); title('Error Signal');


% 2. Re-Síntese
% 2.1 Re-síntese do sinal original com o sinal de erro original
y_synthesized = LPC_synthesis(lpc_coeffs, residuals,step,window,y_preemph,num_frames);

% 2.2 Re-síntese com combinação de tom fundamental monótono e ruído branco


% Comparação de formas de onda
figure;
subplot(2,1,1);
plot(y_preemph, 'b'); title('Original Signal');
subplot(2,1,2);
plot(y_synthesized, 'r'); title('Synthesized Signal');




  

function y_synthesized = LPC_synthesis(lpc_coeffs, residuals,step, window, y_preemph, num_frames)
    
    y_synthesized = zeros(size(window));

    for i = 1:num_frames
        frame_synthesized = filter(1, lpc_coeffs(:, i), residuals(:, i));
        y_synthesized((i-1)*step + 1 : (i-1)*step + length(window)) = frame_synthesized(:,i);
    end
end




