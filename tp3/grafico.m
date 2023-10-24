close all
clear all
clc

dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];
dark_orange = 1/255 * [255, 165, 0];
darl_purple = 1/255 * [153, 51, 153];


x = [-4.08e-4, -3.62e-4, -3.17e-4, -2.72e-4, -2.27e-4, -1.81e-4, -1.36e-4, -9.07e-5, -4.54e-5, 0, 4.54e-5, 9.07e-5, 1.36e-4, 1.81e-4, 2.27e-4, 2.72e-4, 3.17e-4, 3.62e-4];
y1 = [348, 330, 312, 310, 301, 294, 292, 287, 283, 277, 267, 249, 234, 219, 207, 195, 183, 176] - 280 ;
y2 = [380, 370, 358, 341, 326, 306, 297, 288, 280, 274, 242, 228, 213, 203, 193, 187, 183, 179]-270;


figure(1); plot(x * 10^3, y1, 'o-', 'color', dark_green); hold on; plot (x * 10^3, y2, '-o', 'color', dark_orange); hold off;

xlabel('Valores de atraso do sinal (ms)');
ylabel('Valores de ângulo em graus');
title('Gráfico de atraso vs ângulo');
legend('membro 1', 'membro 2');
grid on;

figure(2); plot(x*10^3, (y1+y2)/2, '-o', 'Color', dark_blue); grid on; 

xlabel('Valores de atraso do sinal (ms)');
ylabel('Valores de ângulo em graus');
title('Gráfico de atraso vs ângulo, média dos sinais');

