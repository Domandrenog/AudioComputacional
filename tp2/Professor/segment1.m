% Script que segmenta o sinal em segmentos vocalizados, 
% noise e silencio baseado na energia e taxa de passagem 
% por zero do sinal de fala segundo o livro 
% "Digital Processing of Speech Signal" de Rabiner e Schafer.
% Detalhado em Teixeira, J. P., An�lise e S�ntese de Fala � Modeliza��o
% Param�trica de Sinais Para Sistemas TTS. Editorial Acad�mica Espa�ola
% ISBN: 978-3-659-06206-3, 2013. p�g. 96 e 209.
clear all
close all

%color for plots
dark_green = 1/255 * [0,100,0];
dark_blue = 1/255 * [3,37,126];

filename=input('Nome do Ficheiro .wav? ','s');
filename1=[filename,'.wav'];
[sinal,Fa]=audioread(filename1);

% A Frequencia de Amostragem deve ser 22050 ou 44100 Hz
if Fa==44100
    sinal=decimate(sinal,2);
end
sinal=detrend(sinal);
espacamento=10;
energia=fenerg2(sinal,espacamento); % Energia do sinal
m=fmedia(energia,5,1);energia=fmedia(m,3,1); % Alisamento
LSES=max(energia(1:100));
der=fderivad(sinal);
zero=fzeros2(der,50,espacamento); % Taxa de passagem por zero da derivada
m=fmedia(zero,5,1);zero=fmedia(m,3,1);  % Alisamento
LIZ=min(zero(3:70)); % Limite Inferior da Taxa de Passagem por Zero

car=zeros(round(length(sinal)/(espacamento*10)),2);
s=zeros(round(length(sinal)/(espacamento*10)),1);
decisao=zeros(round(length(sinal)/(espacamento*10)),1); 

for i=0:10:length(zero)-10
  z=0;e=0;
  for j=1:10  
    if zero(i+j)>LIZ, z=z+1; end
    if energia(i+j)<LSES, e=e+1; end
  end
  car(i/10+1,1)=e;   % Energia
  car(i/10+1,2)=z;   % Taxa de Passsagem por zero
end
s=sum(car,2);
% Matriz de decis�o com 3 classes
% Decisao= 0->nao definido; 1-> silencio; 3-> excitado por ruido (noise); 4-> vocalizado;

for i=1:length(decisao) 
 if s(i)>=14, decisao(i)=1;
   elseif s(i)<6, decisao(i)=4;
     elseif (car(i,1)<3 && car(i,2)>5), decisao(i)=3;
 end
end
for i=3:length(decisao) 
    if decisao(i-2)==decisao(i) 
        decisao(i-1)=decisao(i); 
    end
end
figure;plot((1:length(sinal)),sinal/max(sinal)*4,'y',100*(1:length(decisao)),decisao, '.');
title('Classifica��o: 0 - Indefinido, 1 - Sil�ncio, 3 - Ruido e 4 - Voz');
binEdges = 0:0.5:5;
% Crie alguns dados de exemplo
x = 0.3:1:4.3;
% Defina os r�tulos personalizados para o eixo x
novo_rotulo_x = {'Indefinido', 'Sil�ncio', '', 'Ruido', 'Voz'};


figure(7); histogram(decisao, binEdges, 'FaceColor', dark_blue); ylabel('Total de ocorr�ncias'); xticks(x); xticklabels(novo_rotulo_x);
title('N�mero de ocorr�ncias de Indefinido, Sil�ncio, Ruido e Voz');




% Matriz de decis�o com 5 classes
% Decisao= 0->N�o dedinido; 1-> silencio; 2-> excitado por ruido (noise);
% 2,5-> Excita��o noise/mista 3-> mista; 4-> vocalizado

for i=1:length(decisao)
   if (s(i)>=12 && (car(i,1)>8 || car(i,2)>8)), decisao(i)=1; end
   if (car(i,1)<=8 && car(i,2)<=3), decisao(i)=4; end
   if (car(i,1)<3 && car(i,2)>3), decisao(i)=2; end
   if (car(i,1)<=6 && car(i,1)>=3 && car(i,2)>3 && car(i,2)<=8), decisao(i)=3; end
   if (car(i,1)<3 && car(i,2)>3 && car(i,2)<=8), decisao(i)=2.5; end
end
for i=3:length(decisao) 
     if decisao(i-2)==decisao(i) 
         decisao(i-1)=decisao(i); 
     end
end
figure;plot((1:length(sinal)),sinal/max(sinal)*4,'y',100*(1:length(decisao)),decisao,'.');
title('Classifica��o: 0-Indef. 1-Sil�. 2-Ru�do 2.5-Comum; 3-Mix 4-Voz');

binEdges = 0:0.5:5;
% Crie alguns dados de exemplo
x = 0.3:1:4.3;
% Defina os r�tulos personalizados para o eixo x
novo_rotulo_x = {'Indefinido', 'Sil�ncio', 'Ruido', 'Mix', 'Voz'};
figure(8); histogram(decisao, binEdges, 'FaceColor', dark_blue); ylabel('Total de ocorr�ncias'); xticks(x); xticklabels(novo_rotulo_x);
title('N�mero de ocorr�ncias de Indefinido, Sil�ncio, Ruido, Comum, Mix e Voz');

% figure;plot(zero);title('zeros');
% figure;plot(energia);title('energia');
% figure;plot((1:length(sinal)),sinal/max(sinal)*4,'y',100*(1:length(decisao)),decisao,'r',100*(1:length(decisao)),car(:,1)/2.5,'g',100*(1:length(decisao)),car(:,2)/2.5,'b');

