%% Auxiliar plot for fundamental frequência
close all
clear all
clc

dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];
dark_red = 1/255 * [139, 37, 20];

x = -10:0.1:20;
y = sinc(x-10).*sin(x-10);

f_max = 30;
f_min = 40;


figure(1); 
subplot(2,1,1); plot(x, y, 'color', dark_blue, 'LineWidth', 1.2); xlabel("tempo (s)"); ylabel('Amplitude'); grid off; title("y = sinc(x-10) * sin(x-10)");xlim([0 20]);

y_corr = xcorr(y);
subplot(2,1,2); plot(y_corr, 'color', dark_blue, 'LineWidth', 1.2); xlabel("Frequência (Hz)"); ylabel('Amplitude'); grid off; title("autocorrelção sinc(x)");xlim([0 50]);

xline(f_max,'--r','1 / f_0max', 'color', dark_red, 'LineWidth', 1.5);
xline(f_min,'--r','1 / f_0min', 'color', dark_red, 'LineWidth', 1.5);
