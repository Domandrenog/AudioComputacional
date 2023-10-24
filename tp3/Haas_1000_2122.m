clear all
close all
clc

% determinação da direcção aparente de uma fonte sonora na região de 1000 Hz
% efeito de Haas
% gerar um som de ruído branco numa banda de 1 oitava
% 1- reproduzir esse som com idênticos níveis de pressão sonora 
% através de dois sonodifusores, colocados face ao observador ouvinte nos 
% vértices de um triângulo equilátero
% o canal 2 estará inicialmente avançado no tempo em ~0,4 ms e irá, de 
% segundo a segundo, em passos de 1/fs, reduzir o avanço até ficar atrasado 
% em ~0,4 ms.
% Durante este processo deverá em cada passo registar-se a direcção aparente 
% de proveniência do som.
% 
% 2- na 2a fase, agora começando com o sinal do canal 2 atrasado em 10 ms, o seu nível
% será aumentado de uma quantidade que variará de 0 a 15 dB, em passos 
% de 0,5 dB. 
% Deverá confirmar-se um efeito de re-aparecimento do som do 
% canal 2 segundo o efeito de Haas, passando a direcção da fonte sonora a 
% ser a do canal 2 quando no início da fase 2 era a do canal 1.

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
% cálculo do sinal a reproduzir
sinal=randn(.5*fs,1);

subplot(2,2,1), plot(sinal)
sinalfiltrado=filter(B,A,sinal);
sinalfiltrado=sinalfiltrado/max(abs(sinalfiltrado));
% janelar para reduzir os transitórios
sinalfiltrado=sinalfiltrado.*hann(length(sinalfiltrado));
pause(5)

subplot(2,2,2), plot(sinalfiltrado)
% pause
% definicao do sinal em cada 1 dos 2 canais
% atrasos em ms

% 1ª fase
% atrasoinicial=0;
% atrasofinal=0;

atrasoinicial=-0.4*1e-3;
atrasofinal=0.4*1e-3;
% numero de amostras de variação do atraso
natrasoinicial=floor(atrasoinicial*fs);
natrasofinal=floor(atrasofinal*fs);
% introdução de um segmento inicial e de um segmento final no sinal 
% de referência (sinal 1)
n1inicial=(min([natrasoinicial natrasofinal 0]));
n1final=(max([natrasoinicial natrasofinal 0]));
sinal1=[zeros(-n1inicial,1);sinalfiltrado;zeros(n1final,1)];

subplot(2,2,3), plot(sinal1)
% iteração para sinal 2 desde atrasoinicial até atrasofinal
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

% 2ª fase

atrasoinicial=10*1e-3;
atrasofinal=10*1e-3;
% numero de amostras de variação do atraso
natrasoinicial=atrasoinicial*fs;
natrasofinal=atrasofinal*fs;
% introdução de um segmento inicial e de um segmento final no sinal 
% de referência (sinal 1)
n1inicial=floor(min([natrasoinicial natrasofinal 0]));
n1final=floor(max([natrasoinicial natrasofinal 0]));
sinal1=[zeros(-n1inicial,1);sinalfiltrado/6;zeros(n1final,1)];
subplot(2,2,4), 
plot(sinal1)
% iteração para sinal 2 desde atrasoinicial até atrasofinal
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


