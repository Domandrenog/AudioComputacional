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
lpc_coeffs = zeros(num_frames, p+1);
residuals = zeros(size(y_preemph));
r = zeros(num_frames, length(window));
frame_matrix = zeros(num_frames, length(window));

% Gets coeficients and residuals for each frame
for i = 1:num_frames
    frame = y_preemph((i-1)*step + 1 : (i-1)*step + length(window)) .* window; % define frame
    frame_matrix(i,:) = frame;
    [lpc_coeffs(i, :), ~] = lpc(frame, p); % get coef and residual
    r(i,:) = filter(1, lpc_coeffs(i, :), frame);
end

reconstructed_signal = zeros(size(y));
for i=1:num_frames
    new_frame = zeros(length(window),1);
    for j=1:p
        if i-j <= 0; break; end
        new_frame = new_frame + frame_matrix(i-j,:)' * lpc_coeffs(i, j);
    end
    new_frame = filter(1, lpc_coeffs(i, :), frame_matrix(i,:)');
    reconstructed_signal((i-1)*step+1:(i-1)*step+length(window),:) = reconstructed_signal((i-1)*step+1:(i-1)*step+length(window),:) + new_frame;
end

figure; subplot(2,1,1); plot(y);
subplot(2,1,2); plot(reconstructed_signal);
