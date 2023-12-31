% Fun��o que realiza a s�ntese de fala tendo como fonte uma matriz com
% os formantes F1,F2,F3 e F4 e o Pitch F0. As larguras de banda s�o 
%constantes. O sinal de sa�da � armazenado num ficheiro .wav.

close all
clear all

Fs=11025;
%jmax=max(size(vecFOR));
jmax=75;
janela=256;
f0=134;
DF=1/Fs*janela;			% Dura��o de uma frame.
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

% Vari�veis para controle da entona��o
f0_variation = 10; % Varia��o na frequ�ncia fundamental

% Define the provided data
f0s_a = [130.652902 129.792837 127.617600 128.032236 128.031624 ...
    125.818815 126.719102 128.855329 132.072028 140.950202 153.492546 ...
    164.356671 174.122222 185.068774 196.797003 208.729564 213.546964 215.945243 ...
    210.628151];

f0s_e = [161.162044 150.266963 144.445977 138.865170 136.402374 135.310008 ...
    134.235979 133.308250 132.885811 134.417178 137.259519 140.203362 146.427843 ...
    167.493606 172.909759 189.124775 188.843317 190.262729 197.973217];

f0s_i = [162.431440 152.019370 144.102354 139.998581 137.333663 ...
    135.267789 133.562315 132.444873 131.643708 131.306798 132.286085 136.099728 ...
    143.343532 157.460723 177.639666 197.278338 201.492484 205.350839 209.517199];

f0s_o = [f0 f0 f0 f0 f0 f0 146.474488 140.617081 137.899491 136.109887 ...
    135.084352 134.161891 132.970896 132.442424 133.204652 135.480687 140.078137 ...
    146.614253 153.681792];

f0s_u = [358.516837 337.485500 282.342173 251.035518 231.423290 210.495196 ...
    200.893304 204.985032 206.284673 204.102074 198.904664 192.627239 ...
    186.040405 177.752489 170.559534 161.702249 140.390297 130.304218 67.166573];

fprintf("a: %d | e: %d | i: %d | o: %d | u: %d\n", length(f0s_a), length(f0s_e),length(f0s_i), length(f0s_o), length(f0s_u));

f0s_a = interp1(1:length(f0s_a), f0s_a, 1:1/jmax:length(f0s_a));
f0s_e = interp1(1:length(f0s_e), f0s_e, 1:1/jmax:length(f0s_e));
f0s_i = interp1(1:length(f0s_i), f0s_i, 1:1/jmax:length(f0s_i));
f0s_o = interp1(1:length(f0s_o), f0s_o, 1:1/jmax:length(f0s_o));
f0s_u = interp1(1:length(f0s_u), f0s_u, 1:1/jmax:length(f0s_u));

f0s_vector = [f0s_a; f0s_e; f0s_i; f0s_o; f0s_o];
%figure(3); plot(x, f0s, '-o', 1:1/jmax:length(f0s), f0s_inter, '.'); 
jitter_strength = 0.5;

% Ver modelo Fujisaki


for index_vogal=1:5
    f0s_inter = f0s_vector(index_vogal,:);

    % Introduce pitch jitter
    jitter = jitter_strength * randn(size(f0s_inter));
    f0s_inter_jittered = f0s_inter + jitter;

    figure(3); subplot(5,1, index_vogal); plot(f0s_inter, '.'); title("fundamental frequencies");


    F0 = f0s_inter_jittered;
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
    shimmer_signal = 2*sin(0.001 * (1:length(voz)) + shimmer_phase);
    
    % Modulate the audio signal with the shimmer signal
    voz = voz .* (1 + shimmer_depth * shimmer_signal);
    
    
    
    voz=[voz awgn(sinal, 60)];
    
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

% Nova determina�ao do espectro
% [B,F,T]=specgram(voz,512,Fs,hanning(janela),janela/2);
% figure(3);
% set(gcf,'Color',[1 1 1]);
% imagesc(T,F,20*log10(abs(B)));
% axis xy;
% colormap(1.-gray(256));
% title('Espectrograma');ylabel('Hz');xlabel('seg');
% 

% fim de nova determina�ao do espectro


% salvar=input('Deseja salvar o sinal de sa�da (s ou S para sim)? ','s');
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
audiowrite('excitRowdenV2.wav', voz_final, Fs, 'BitsPerSample', 16);

soundsc(voz_final,Fs);
% end;