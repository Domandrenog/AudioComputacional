% Função que realiza a síntese de fala tendo como fonte uma matriz com
% os formantes F1,F2,F3 e F4 e o Pitch F0. As larguras de banda são 
%constantes. O sinal de saída é armazenado num ficheiro .wav.

close all
clear all

Fs=11025;
%jmax=max(size(vecFOR));
jmax=75;
janela=256;
f0=134;
DF=1/Fs*janela;			% Duração de uma frame.
Av=ones(1,jmax)*1;
attack=2*round(0.2*Fs/256/2); 
decay=2*round(0.3*Fs/256/2);
e1=hanning(attack)';
e2=hanning(decay)';
envolvente=[e1(1:length(e1)/2) ones(1,jmax-length(e1)/2-length(e2)/2) e2(length(e2)/2+1:length(e2))];
Av=Av.*envolvente;
F0_base=ones(1,jmax);
F1_base=ones(1,jmax); % formantes da vogal i
F2_base=ones(1,jmax);
F3_base=ones(1,jmax);
F4_base=ones(1,jmax);


vogal_a = [f0 717 1089 2500 3500];
vogal_e = [f0 554 1761 2500 3500];
vogal_i = [f0 282 2238 2500 3500];
vogal_o = [f0 470 1020 2500 3500];
vogal_u = [f0 311 875 2500 3500];


vogais = [vogal_a; vogal_e; vogal_i; vogal_o; vogal_u];

% Variáveis para controle da entonação
f0_variation = 10; % Variação na frequência fundamental

f0s_a = [130.6 130.6 130.1 127.8 127.2 127.2 127.9 128 126.9 125.8 126.7 126.7 128.9 128.9 132.6 141.6 151.7 164.7 174.5 184.7 195.1 206.6 213.6 215.8 211.9];
f0s_e = [153.623129 153.623129 146.960870 140.370521 140.370521 136.926368 135.752539 134.685646 133.521685 133.521685 132.988386 133.540377 136.205226 136.205226 139.121941 143.130324 158.526358 170.676249 185.919617 185.919617 189.431869 188.229844 197.370804 273.771325 272.211748];
f0s_i = [165.529679 155.489195 145.367643 141.330724 137.888851 135.840278 134.044437 132.627044 131.869613 131.298118 131.849950 134.701826 141.169847 151.575120 172.566818 194.334489 200.867166 203.117766 209.134577 68.061238 68.154549 66.219352 66.022771 68.058856 67.912860];
f0s_o = [141.190756 141.190756 138.193705 138.193705 136.325163 135.213312 134.288883 134.288883 133.148211 132.447730 132.447730 133.000017 135.060893 135.060893 139.212278 139.212278 139.212278 145.688063 145.688063 152.736116 267.074243 267.074243 263.961065 263.961065 272.654246];
f0s_u = [346.439840 301.632439 301.632439 256.882958 238.775835 215.549578 215.549578 202.685922 200.277844 203.763479 203.763479 206.344648 205.098748 200.765585 194.598817 188.032307 188.032307 180.826264 171.752779 171.752779 167.261050 145.230905 145.230905 131.465033 130.868267];

fprintf("a: %d | e: %d | i: %d | o: %d | u: %d\n", length(f0s_a), length(f0s_e),length(f0s_i), length(f0s_o), length(f0s_u));

f0s_a = interp1(1:length(f0s_a), f0s_a, 1:1/jmax:length(f0s_a));
f0s_e = interp1(1:length(f0s_e), f0s_e, 1:1/jmax:length(f0s_e));
f0s_i = interp1(1:length(f0s_i), f0s_i, 1:1/jmax:length(f0s_i));
f0s_o = interp1(1:length(f0s_o), f0s_o, 1:1/jmax:length(f0s_o));
f0s_u = interp1(1:length(f0s_u), f0s_u, 1:1/jmax:length(f0s_u));

f0s_vector = [f0s_a; f0s_e; f0s_i; f0s_o; f0s_u];
%figure(3); plot(x, f0s, '-o', 1:1/jmax:length(f0s), f0s_inter, '.'); 


% Ver modelo Fujisaki


for index_vogal=1:5
    f0s_inter = f0s_vector(index_vogal,:);
    
    figure(3); subplot(5,1, index_vogal); plot(f0s_inter, '.'); title("fundamental frequencies");


    F0 = f0s_inter; %* vogais(index_vogal, 1) ;%.* intonation_pattern' + randn(1, jmax) * f0_variation;
    F1 = F1_base * vogais(index_vogal, 2);
    F2 = F2_base * vogais(index_vogal, 3);
    F3 = F3_base * vogais(index_vogal, 4);
    F4 = F4_base * vogais(index_vogal, 5);
    

Ts=1/Fs;
% Bandwidth
B1=ones(1,jmax)*50*6.25;
B2=ones(1,jmax)*75*6.25;
B3=ones(1,jmax)*100*6.25;
B4=ones(1,jmax)*300*6.25;


e=zeros(1,janela);
aant=400*pi;
bant=5000*pi;
Tant=1/10000;
a=aant*Tant/Ts;
b=bant*Tant/Ts;	% Dependem do falante
		% db=-amplitude em db do equalizador para f=0 hz
%B22=(1+exp(-b*T)-exp(-a*T)-exp(-T*(a+b)));	%/(10^(-db/20));
%A2=[1 exp(-b*T)-exp(-a*T) -exp(-T*(a+b))];


db=10;
tau1=1e-3;	% 1 ms.
deltatau=2e-3;	% 2 ms.

saida=zeros(1,(jmax+1)*janela/2);

indmax=round(4500*janela/Fs);
vecSPE=zeros(jmax,indmax);
H=hanning(janela);
%sinal=sinal*Av;
ind=1;
resto=[];
zi=zeros(8,1);
% zi=zeros(2,1);
voz=[];excit=[];
%aglotal=0.9;			% Define a forma do impulso glotal
%Bglotal=[0 -aglotal*exp(1)*log(aglotal)];
%Aglotal=[1 -2*aglotal aglotal^2];
for j=1:jmax
 % j
  [sinalglotal,resto]=fgerimp(Fs,F0(j),janela,resto);
 % plot(sinal)
   
  
 % pause
  sinal=sinalglotal*Av(j);
  excit=[excit sinal];
  BBB=[1];
  A=[1];
  for i=1:4,
%   for i=3:3,
    if i==1, Form=F1(j);LB=B1(j); end;
    if i==2, Form=F2(j);LB=B2(j); end;
    if i==3, Form=F3(j);LB=B3(j); end;
    if i==4, Form=F4(j);LB=B4(j); end;
      BB=1-2*exp(-LB/2*Ts)*cos(2*pi*Form*Ts)+exp(-LB/2*Ts)^2;
      AA=[1 -2*exp(-LB/2*Ts)*cos(2*pi*Form*Ts) exp(-LB/2*Ts)^2];
     BBB=conv(BB,BBB);
     A=conv(A,AA);
  end;
  
%     AR=[1.0000    0.1584];
%     BR=[0.4208   -0.4208];
%     BBB=conv(BBB,BR)*1e-3;
%     A=conv(A,AR); A=A/A(1);

    [sinal,zf]=filter(BBB,A,sinal,zi);
    zi=zf;


    % Calculate the shimmer modulation depth
    shimmer_depth = 0.01;  % Shimmer modulation depth as a percentage of the signal amplitude
    
    % Generate a random shimmer phase
    shimmer_phase = rand * 2 * pi;
    
    % Generate the shimmer modulation signal
    shimmer_signal = log(0.001 * (1:length(voz)) + shimmer_phase);
    
    % Modulate the audio signal with the shimmer signal
    voz = voz .* (1 + shimmer_depth * shimmer_signal);

     
    voz=[voz sinal];
    
end;


   
    
%     figure(1)
%     subplot(1,2,1); plot(excit(1:256));
%     subplot(1,2,2); plot(voz(1:256));pause
    voz=voz/abs(max(voz));
    voz=detrend(voz);
    excit=detrend(excit/abs(max(excit)));
    %wavwrite(excit,Fs,16,'excitRowden.wav')
    
    % NOSSO
    %fade = 0:ceil(length(voz)/10);
    %fader = sin(2*pi*10/(4*length(voz)).*fade);
    %voz(1:ceil(length(voz)/10)+1) = voz(1:ceil(length(voz)/10)+1).*fader;
    %voz(end-ceil(length(voz)/10):end)=voz(end-ceil(length(voz)/10):end).*fader(end:-1:1);

    figure(1); plot(voz); title('voz');
    if index_vogal == 1 voz_final = voz;
        
    else 
        voz_final = horzcat(1,voz_final,voz);
    end
    %soundsc(voz,Fs);
    %pause(2)
end
eixtemp=(0:jmax-1)*DF*1000/2;
figure;
% x=fft(voz(length(voz)/2:length(voz)/2+*Fs/f0-1));
%x=fft([voz(2980:3090) zeros(1,9*110 )]);
%plot(20*log10(abs(x(1:10*Fs/f0/2))));pause
% x=fft([voz(2209:2318) zeros(1,9*110)]);
% plot(20*log10(abs(x(1:round(10*Fs/f0/2)))));pause
% xx=fft(saidaaleatoria);

xx=abs(fft(zeros(1,11025)));
for i=1:1000
    sinalaleatorio=randn(1,11025);
    saidaaleatoria=detrend(filter(BBB,A,sinalaleatorio));
    xx=xx+abs(fft(saidaaleatoria));

end

figure(2); plot(20*log10((xx(2:round(length(xx)/2)))),'r');grid

% % plot(eixtemp,F1(1:jmax),'bo',eixtemp,F2(1:jmax),'ro',eixtemp,F3(1:jmax),'go',eixtemp,F4(1:jmax),'ko');
% % title('Formantes');ylabel('Hz');xlabel('mseg');
% V=axis;
% V(4)=11025/2;
% axis(V);

% Nova determinaçao do espectro
% [B,F,T]=specgram(voz,512,Fs,hanning(janela),janela/2);
% figure(3);
% set(gcf,'Color',[1 1 1]);
% imagesc(T,F,20*log10(abs(B)));
% axis xy;
% colormap(1.-gray(256));
% title('Espectrograma');ylabel('Hz');xlabel('seg');
% 

% fim de nova determinaçao do espectro


% salvar=input('Deseja salvar o sinal de saída (s ou S para sim)? ','s');
% if ((salvar=='s') | (salvar=='S')),
%   filename=input('Nome do sinal a guardar (incluir .wav?) ','s');
%   wavwrite(voz,Fs,16,filename);
% end;

% tocar=input('Deseja ouvir o sinal de entrada (s ou S para sim)? ','s');
% if ((tocar=='s') | (tocar=='S')),
%   soundsc(excit,Fs);
% end;
% tocar=input('Deseja ouvir o sinal de saida (s ou S para sim)? ','s');
% if ((tocar=='s') | (tocar=='S')),
%audiowrite('excitRowden.wav', voz_final, Fs, 'BitsPerSample', 16);

  soundsc(voz_final,Fs);
% end;