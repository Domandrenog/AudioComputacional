clear all
close all
clc

% determina��o da direc��o aparente de uma fonte sonora na regi�o de 1000 Hz
% efeito de Haas
% gerar um som de ru�do branco numa banda de 1 oitava
% 1- reproduzir esse som com id�nticos n�veis de press�o sonora 
% atrav�s de dois sonodifusores, colocados face ao observador ouvinte nos 
% v�rtices de um tri�ngulo equil�tero
% o canal 2 estar� inicialmente avan�ado no tempo em ~0,4 ms e ir�, de 
% segundo a segundo, em passos de 1/fs, reduzir o avan�o at� ficar atrasado 
% em ~0,4 ms.
% Durante este processo dever� em cada passo registar-se a direc��o aparente 
% de proveni�ncia do som.
% 
% 2- na 2a fase, agora come�ando com o sinal do canal 2 atrasado em 10 ms, o seu n�vel
% ser� aumentado de uma quantidade que variar� de 0 a 15 dB, em passos 
% de 0,5 dB. 
% Dever� confirmar-se um efeito de re-aparecimento do som do 
% canal 2 segundo o efeito de Haas, passando a direc��o da fonte sonora a 
% ser a do canal 2 quando no in�cio da fase 2 era a do canal 1.

fs=22050;
f0=1000;
FROitava=1/2;
% desenho do filtro de oitava
BW=f0*(2^FROitava-1)/2^(FROitava/2);
f1=f0/2^(FROitava/2);
f2=f0*2^(FROitava/2);
wp1=f1/(fs/2);
wp2=f2/(fs/2);
declive=100;
n=ellipord([wp1 wp2], [wp1/2 wp2*2], 0.1, declive);
[B,A]=ellip(n, 0.1, 100, [wp1 wp2]);
% c�lculo do sinal a reproduzir
sinal=randn(.5*fs,1);

subplot(2,2,1), plot(sinal)
sinalfiltrado=filter(B,A,sinal);
sinalfiltrado=sinalfiltrado/max(abs(sinalfiltrado));
% janelar para reduzir os transit�rios
sinalfiltrado=sinalfiltrado.*hann(length(sinalfiltrado));
pause(5)

subplot(2,2,2), plot(sinalfiltrado)
% pause
% definicao do sinal em cada 1 dos 2 canais
% atrasos em ms

% 1� fase
% atrasoinicial=0;
% atrasofinal=0;

atrasoinicial=-0.4*1e-3;
atrasofinal=0.4*1e-3;
% numero de amostras de varia��o do atraso
natrasoinicial=floor(atrasoinicial*fs);
natrasofinal=floor(atrasofinal*fs);
% introdu��o de um segmento inicial e de um segmento final no sinal 
% de refer�ncia (sinal 1)
n1inicial=(min([natrasoinicial natrasofinal 0]));
n1final=(max([natrasoinicial natrasofinal 0]));
sinal1=[zeros(-n1inicial,1);sinalfiltrado;zeros(n1final,1)];

subplot(2,2,3), plot(sinal1)
% itera��o para sinal 2 desde atrasoinicial at� atrasofinal
% pause
m=n1inicial;
iteracao=1;
while m<=n1final
    iteracao
    atraso=m/fs

% sinal a deslizar (sinal 2)
sinal2=[zeros((m-n1inicial),1);sinalfiltrado;zeros((n1final-m),1)];
subplot(2,2,3)
t=0:1/fs:(length(sinal1)-1)/fs;
plot(t, sinal1,'b',t, sinal2,'r')
sound([sinal1 sinal2],fs,16)
pause(6)
m=m+1 
iteracao=iteracao+1;
end
 
% close all

pause

% 2� fase

atrasoinicial=10*1e-3;
atrasofinal=10*1e-3;
% numero de amostras de varia��o do atraso
natrasoinicial=atrasoinicial*fs;
natrasofinal=atrasofinal*fs;
% introdu��o de um segmento inicial e de um segmento final no sinal 
% de refer�ncia (sinal 1)
n1inicial=floor(min([natrasoinicial natrasofinal 0]));
n1final=floor(max([natrasoinicial natrasofinal 0]));
sinal1=[zeros(-n1inicial,1);sinalfiltrado/6;zeros(n1final,1)];
subplot(2,2,4), 
plot(sinal1)
% itera��o para sinal 2 desde atrasoinicial at� atrasofinal
% pause
m=n1final;
    atraso=m/fs

% sinal a deslizar (sinal 2)
sinal2=[zeros(floor(m-n1inicial),1);sinalfiltrado;zeros(floor(n1final-m),1)];

mdB=0;
iteracao2=1;
while mdB<=15
k=10^(mdB/20);
iteracao2
    mdB
    % sinal a amplificar (sinal 2)
sinal2=[zeros(floor(m-n1inicial),1);sinalfiltrado/6*k;zeros(floor(n1final-m),1)];
subplot(2,2,3), 
t=0:1/fs:(length(sinal1)-1)/fs;
plot(t, sinal2,'r')
sound([sinal1 sinal2],fs,16)
pause
mdB=mdB+0.5;
iteracao2=iteracao2+1;
end


