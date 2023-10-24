x = [-4.08e-4, -3.62e-4, -3.17e-4, -2.72e-4, -2.27e-4, -1.81e-4, -1.36e-4, -9.07e-5, -4.54e-5, 0, 4.54e-5, 9.07e-5, 1.36e-4, 1.81e-4, 2.27e-4, 2.72e-4, 3.17e-4, 3.62e-4];
y = [1, 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];

plot(x, y, 'o-'); % 'o-' plota os pontos como marcadores circulares interligados
xlabel('Valores de atraso do sinal');
ylabel('Valores de ângulo');
title('Gráfico de atraso vs ângulo');
grid on;
