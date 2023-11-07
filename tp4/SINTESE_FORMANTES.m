% Função que realiza a síntese de fala tendo como fonte uma matriz com
% os formantes F1,F2,F3 e F4 e o Pitch F0. As larguras de banda são 
%constantes. O sinal de saída é armazenado num ficheiro .wav.

close all
clear all

Fs=11025;
%jmax=max(size(vecFOR));
jmax=75;
janela=256;
f0=75;
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


vogais = [vogal_u; vogal_a; vogal_u; vogal_a; vogal_u];



for index_vogal=1:5

    F0 = F0_base * vogais(index_vogal, 1);
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
    voz=[voz sinal];
    
end;


   
    
%     figure(1)
%     subplot(1,2,1); plot(excit(1:256));
%     subplot(1,2,2); plot(voz(1:256));pause
    voz=voz/abs(max(voz));
    voz=detrend(voz);
    excit=detrend(excit/abs(max(excit)));
    audiowrite('excitRowden.wav', excit, Fs, 'BitsPerSample', 16);
    %wavwrite(excit,Fs,16,'excitRowden.wav')
    
    % NOSSO
    if index_vogal == 1
        voz_final = voz;
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
plot(20*log10((xx(2:round(length(xx)/2)))),'r');grid

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
  soundsc(voz_final,Fs);
% end;