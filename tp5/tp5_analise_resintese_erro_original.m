%clear all
close all

% color for plot
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];

%%%%
%%%%
% Análise sem Pré-Enfase
%%%%
%%%%

%Ficheiro de Áudio
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
x = (1:length(y))/fs_new;
fs = fs_new;

% Parâmetros LPC
p = 12;
seg_duration = 0.03; % 30 ms
overlap = 2/3;

% Janela de Hamming
window = hamming(round(seg_duration * fs));
step = round((1 - overlap) * length(window));

%Sem Pré-Enfase, logo não há alterações ao y
y_preemph = y;

% Inicialização de variáveis
num_frames = floor((length(y_preemph) - length(window)) / step);
lpc_coeffs = zeros(num_frames, p+1);
r = zeros(num_frames, length(window));
reconstructed_signal_np = zeros(size(y_preemph));

% Gets coeficients and residuals for each frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal_np(i*step + 1 : i*step + length(window)) = (reconstructed_signal_np(i*step + 1 : i*step + length(window)) + reconstructed_frame');
    
end

figure; subplot(2,1,1); plot(x, y_preemph, 'color', dark_blue); title("Sinal Original"); xlabel("time (s)");
subplot(2,1,2); plot(x, reconstructed_signal_np, 'Color', dark_green); title("Sinal Re-sintetizado"); xlabel("time (s)");
sgtitle("Sinal Original vs Sinal Re-sintetizado sem Pré-Enfase");

figure;
plot(x(0.1*fs:19.1*fs), r(0.1*fs:19.1*fs), 'LineWidth', 1.5, 'color', dark_blue);
xlim([0.1 19.1]); title("Sinal Erro"); xlabel('Tempo (s)'); ylabel('Amplitude');


% Nome do arquivo de áudio para salvar
nome_arquivo = 'Sinal_Re_sintetizado_sem_Pré_Enfase.wav';
% Salvando o sinal de áudio
audiowrite(nome_arquivo, reconstructed_signal_np, fs);

% Nome do arquivo de áudio para salvar
nome_arquivo = 'Sinal_Erro.wav';
% Salvando o sinal de áudio
audiowrite(nome_arquivo, r(0.1*fs:19.1*fs), fs);

%%%%
%%%%
% Análise Com Pré-Enfase
%%%%
%%%%


% 1. Análise
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
x = (1:length(y))/fs_new;
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
r = zeros(num_frames, length(window));
reconstructed_signal = zeros(size(y_preemph));

% Gets coeficients and residuals for each frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');
    
end

figure; subplot(2,1,1); plot(x, y, 'color', dark_blue); title("Sinal Original"); xlabel("time (s)");
subplot(2,1,2); plot(x, reconstructed_signal, 'Color', dark_green); title("Sinal Re-sintetizado"); xlabel("time (s)");
sgtitle("Sinal Original vs Sinal Re-sintetizado com Pré-Enfase");

% Nome do arquivo de áudio para salvar
nome_arquivo = 'Sinal_Re_sintetizado_com_Pré_Enfase.wav';
% Salvando o sinal de áudio
audiowrite(nome_arquivo, reconstructed_signal_np, fs);


%%Comparação entre Pré-Enfase e sem Pré-Enfase
figure; subplot(2,1,1); plot(x, reconstructed_signal_np, 'color', dark_blue); title("Sinal Re-sintetizado sem Pré-Enfase"); xlabel("time (s)");
subplot(2,1,2); plot(x, reconstructed_signal, 'Color', dark_green); title("Sinal Re-sintetizado com Pré-Enfase"); xlabel("time (s)");
sgtitle("Sinal Re-sintetizado sem Pré-Enfase vs com Pré-Enfase");


%%%%
%%%%
% Mudança de p - Voiced Segmented
%%%%
%%%%


% 1. Análise
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
x = (1:length(y))/fs_new;
fs = fs_new;

% Parâmetros LPC
%p = 5; %%Mudança aqui
seg_duration = 0.03; % 30 ms
overlap = 2/3;

% Janela de Hamming
window = hamming(round(seg_duration * fs));
step = round((1 - overlap) * length(window));

% Pré-ênfase
alpha = 0.98;
y_preemph = filter([1, -alpha], 1, y);



% Define os valores de p desejados
valores_de_p = [4, 8, 12, 16, 20, 24];

% Inicializa a figura
figure;

% Loop através de diferentes valores de p
for j = 1:length(valores_de_p)
    p_atual = valores_de_p(j);

    % Inicialização de variáveis
    num_frames = floor((length(y_preemph) - length(window)) / step);
    lpc_coeffs = zeros(num_frames, p_atual+1);
    r = zeros(num_frames, length(window));
    reconstructed_signal = zeros(size(y_preemph));

% Loop para cada frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p_atual); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');

end

    % Plot do sinal reconstruído para o valor atual de p
    %subplot((length(valores_de_p)+1)/2, 2, j);
    %plot(x(17.30*fs:17.75*fs), reconstructed_signal(17.30*fs:17.75*fs), 'LineWidth', 1.5);
    %xlim([17.30 17.75]);
    %title(['Reconstrução para p = ' num2str(p_atual)]);
    %xlabel('Tempo (s)');
    %ylabel('Amplitude');

    % Plot do residuals para o valor atual de p
    subplot((length(valores_de_p))/2, 2, j);
    plot(x(17.30*fs:17.733*fs), r(17.30*fs:17.733*fs), 'LineWidth', 1.5, 'color', dark_blue);
    xlim([17.30 17.733]);
    title(['Sinal erro para p = ' num2str(p_atual)]);
    xlabel('Tempo (s)');
    ylabel('Amplitude');
    % Limpa o sinal reconstruído para a próxima iteração
    reconstructed_signal = zeros(size(y_preemph));
end

sgtitle('Comparação de Residuals para Diferentes Valores de p - Voiced'); %p sound

% Loop através de diferentes valores de p verificar energia
valores_de_p = 1:1:24;
sinais_erro_celula_vo = cell(1, length(valores_de_p));
for j = 1:length(valores_de_p)
    p_atual = valores_de_p(j);

    % Inicialização de variáveis
    num_frames = floor((length(y_preemph) - length(window)) / step);
    lpc_coeffs = zeros(num_frames, p_atual+1);
    r = zeros(num_frames, length(window));
    reconstructed_signal = zeros(size(y_preemph));

% Loop para cada frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p_atual); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');

end
    %disp(rms(r(17.30*fs:17.733*fs)));
    sinais_erro_celula_vo{j} = r(17.30*fs:17.733*fs);

    % Limpa o sinal reconstruído para a próxima iteração
    reconstructed_signal = zeros(size(y_preemph));
end


%%%%
%%%%
% Mudança de p - Unvoiced Segmented
%%%%
%%%%


% 1. Análise
filename = 'ASRF20.wav';
[y, fs] = audioread(filename);

% Reamostragem
fs_new = 16000;
y = resample(y, fs_new, fs);
x = (1:length(y))/fs_new;
fs = fs_new;

% Parâmetros LPC
%p = 5; %%Mudança aqui
seg_duration = 0.03; % 30 ms
overlap = 2/3;

% Janela de Hamming
window = hamming(round(seg_duration * fs));
step = round((1 - overlap) * length(window));

% Pré-ênfase
alpha = 0.98;
y_preemph = filter([1, -alpha], 1, y);



% Define os valores de p desejados
valores_de_p = [4, 8, 12, 16, 20, 24];
% Inicializa a figura
figure;

% Loop através de diferentes valores de p
for j = 1:length(valores_de_p)
    p_atual = valores_de_p(j);

    % Inicialização de variáveis
    num_frames = floor((length(y_preemph) - length(window)) / step);
    lpc_coeffs = zeros(num_frames, p_atual+1);
    r = zeros(num_frames, length(window));
    reconstructed_signal = zeros(size(y_preemph));

% Loop para cada frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p_atual); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');

end

    % Plot do residuals para o valor atual de p
    subplot((length(valores_de_p))/2, 2, j);
    plot(x(17.72*fs:17.74*fs), r(17.72*fs:17.74*fs), 'LineWidth', 1.5, 'color', dark_blue);
    xlim([17.72 17.74]);
    title(['Sinal erro para p = ' num2str(p_atual)]);
    xlabel('Tempo (s)');
    ylabel('Amplitude');

    % Limpa o sinal reconstruído para a próxima iteração
    reconstructed_signal = zeros(size(y_preemph));
end

sgtitle('Comparação de Residuals para Diferentes Valores de p - Unvoiced'); %as sound

% Loop através de diferentes valores de p verificar energia
valores_de_p = 1:1:24;
sinais_erro_celula_un = cell(1, length(valores_de_p));
for j = 1:length(valores_de_p)
    p_atual = valores_de_p(j);

    % Inicialização de variáveis
    num_frames = floor((length(y_preemph) - length(window)) / step);
    lpc_coeffs = zeros(num_frames, p_atual+1);
    r = zeros(num_frames, length(window));
    reconstructed_signal = zeros(size(y_preemph));

% Loop para cada frame
for i = 0:num_frames

    frame = y_preemph(i*step + 1 : i*step + length(window)) .* window; % define frame
    [lpc_coeffs(i+1, :), ~] = lpc(frame, p_atual); % get coef and residual
    r(i+1,:) = filter(lpc_coeffs(i+1, :), 1, frame);
    reconstructed_frame = filter(1, lpc_coeffs(i+1, :), r(i+1,:));
    reconstructed_signal(i*step + 1 : i*step + length(window)) = (reconstructed_signal(i*step + 1 : i*step + length(window)) + reconstructed_frame');

end
    %disp(rms(r(17.666*fs:17.833*fs)));
    sinais_erro_celula_un{j} = r(17.72*fs:17.74*fs);

    % Limpa o sinal reconstruído para a próxima iteração
    reconstructed_signal = zeros(size(y_preemph));
end

% Inicializa matrizes para armazenar as energias RMS
energias_un = zeros(1, length(valores_de_p));
energias_vo = zeros(1, length(valores_de_p));

% Loop através de diferentes valores de p verificar energia para Não-Vozeado
for j = 1:length(valores_de_p)
    energias_un(j) = rms(sinais_erro_celula_un{j}, 'all');
end

% Loop através de diferentes valores de p verificar energia para Vozeado
for j = 1:length(valores_de_p)
    energias_vo(j) = rms(sinais_erro_celula_vo{j}, 'all');
end

% Cria uma figura
figure;

% Plot para Não-Vozeado
plot(valores_de_p, energias_un, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'Não-Vozeado');
hold on;

% Plot para Vozeado
plot(valores_de_p, energias_vo, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'Vozeado');

hold off;

title('Comparação de Energia dos Sinais de Erro para Vozeado e Não-Vozeado');
xlabel('Número de p');
ylabel('Energia (RMS)');
legend('show');



