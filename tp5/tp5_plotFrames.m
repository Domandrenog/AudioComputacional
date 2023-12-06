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
num_frames = floor((length(y_preemph) - length(window)) / step);
lpc_coeffs = zeros(num_frames, p+1);
residuals = zeros(size(y_preemph));
r = zeros(num_frames, length(window));
frame_matrix = zeros(num_frames, length(window));

reconstructed_signal = zeros(size(y_preemph));

figure;
% Gets coeficients and residuals for each frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    frame_matrix(i+1,:) = frame;
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');
    
    %figure; 
    %subplot(4,1,1); plot(y_preemph(1:i*step + length(window))); title("Original signal")
    %subplot(4,1,2); plot(reconstructed_signal(1 : i*step + length(window))); title("Reconstructed signal")
    %subplot(4,1,3); plot(frame); title("Original frame")
    current_title = sprintf('Reconstructed Signal, Frame %d (%.3f) s', i+1, (i*step + 1)/fs + 17.30);
    subplot(num_frames+1,1,i+1); plot(x(i*step + 1 : i*step + length(window)),reconstructed_frame'); title(current_title); ax1 = gca; ax1.YAxis.Visible = 'off';
end



figure; subplot(2,1,1); plot(x, y_preemph, 'color', dark_blue); title("Original Signal"); xlabel("time (s)");
subplot(2,1,2); plot(x, reconstructed_signal, 'Color', dark_green); title("Reconstructed Signal"); xlabel("time (s)");

