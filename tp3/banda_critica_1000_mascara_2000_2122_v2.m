clear all
close all
clc
% This script implements 2 activities: 
% 1- Critical bandwidth measurement; in-band tone by noise masking
% 2- out of band tone by tone masking
% ******
% Activity 1- determination of the critical bandwidth in the region of 1000
% Hz and in-band tone by tone masking

% a) the script will generate a constant rms value white noise signal that 
% gradually increases in bandwidth to allow the subjective detection of the 
% threshold of increase of the perceived loudness indicating a bandwidth 
% value near the critical bandwidth.
%
% Additionally, by adding to the noise signal a sinusoid with a similar rms 
% value and frequency value equal to the centre frequency of the noise 
% bandwidth, the subjective detection of a masking threshold of a sinusoid 
% by noise will also be possible.
%
% The experiment is designed in cycles of increasing noise bandwidth, 
% starting at an initial value of 1/18 th of octave (in the variable FROitava) 
% and varying in uniform steps of 1/24 th of octave until 1,25 octave. 
%
% In each cycle, the shortest bandwidth generated noise signal 
%is played in a rapid sequence 
% at 3 sound pressure levels (x, x+3 dB, x+6 dB), for loudness scale reference, 
% for estimation of the 4th sound loudness

% at the end of each cycle, the 4th sound is produced like the first one but with an 
% iteratively increased bandwidth with a constant sound 
% pressure level then follows, to allow the mentioned subjective detection 
% 
% Finally, a longer interval will precede the next iteration.
% 
% After a number of iterations the loudness of the test signal will appear 
% to increase from iteration to iteration.
%
% take note of the m and FRoitava values; the resulting values of the 
% experiment are the ones of the iteration before the first iteration that 
% appeared to produce a subjectively louder sound.
%
% b) following on the iterations, a sinusoid with the same power as the noise
% is added to enable the determination of the 
% threshold of masking of the embedded sinusoidal tone which will become 
% audible at a subsequent iteration. The subjective detection of the 
% sinusoid presence will be possible when it becomes unmasked.
% The reference will in this phase be changed to the actual sinusoidal 
% signal alone after iteration 20, to help the detection.
%
% take note once again of the m and FRoitava values; the resulting values 
% of this part of the experiment are also the ones of the previous iteration, 
% at which the sinusoid was not yet detectable. Calculate the ratio of rms 
% values of the sinusoid and the in-critical-band noise.

fs=11025;
f0=1000;
FROitava=1/18; FROitavaStep=1/36; FROitavafinal=1.25;
m=1; 
T=0.8; % signal duration
sinal=randn(round(T*fs),1);
N=length(sinal);
fsN=fs/N;
% preparation of a special window function to smooth signal attack and release
N1=round(N/20);
N2=round(N/5);
W=hann(2*N1);
W1=hann(2*N2);
W=[W(1:N1);ones(N-N1-N2,1);W1(N2+1:2*N2)];
% smooth signal attack and release
sinal=sinal.*W;
% signal's Fourier transform
SINAL=fft(sinal)/N;
% produce sinusoidal signal with same rms value
t=0:1/fs:(N-1)/fs;
sinalsinusoidal=1*sqrt(2)*sin(2*pi*f0*t)';
sinalsinusoidal=sinalsinusoidal.*W;
% switch do sinal sinusoidal
S=0;


pause(5)
while FROitava<FROitavafinal
    m
BW=f0*(2^FROitava-1)/2^(FROitava/2);
f1=f0/2^(FROitava/2);
f2=f0*2^(FROitava/2);
wp1=f1/(fs/2);
wp2=f2/(fs/2);
declive=100;
n=ellipord([wp1 wp2], [wp1/(4/3) wp2*(4/3)], 0.1, declive);
[B,A]=ellip(n, 0.1, 100, [wp1 wp2]);

% initial random signals

figure(1)
subplot(2,2,1), plot(sinal); grid on; title('sinal aleatório');

% first filtered signal
sinalfiltrado=filter(B,A,sinal);
% signal's Fourier transform
SINALFILTRADO=fft(sinalfiltrado)/N;
if m==1
    % memorize first random signal
    sinalfiltrado1=sinalfiltrado;
    SF0=sqrt(sinalfiltrado'*sinalfiltrado/N);
    % calibrate the sinusoidal signal to have the same rms value
    sinalsinusoidal=SF0*sinalsinusoidal;
end
SF=sqrt(sinalfiltrado'*sinalfiltrado/N);
sinalfiltrado=sinalfiltrado*SF0/SF;
% calculate rms value
SF=sqrt(sinalfiltrado'*sinalfiltrado/N);
subplot(2,2,2), plot(sinalfiltrado); grid on; title('sinal aleatório iterativamente filtrado');

SINALdB=20*log10(abs(SINAL));
SINALFILTRADOdB=20*log10(abs(SINALFILTRADO));
% plot both random signals spectra
subplot(2,2,3), plot((fsN)*(1:round(N/5)), SINALdB(1:round(N/5)),(fsN)*(1:round(N/5)), SINALFILTRADOdB(1:round(N/5))); grid on; ; title('espectros do sin. al. e do si. al. filtrado');

% calculate rms amplitudes in dB
SINALmaisSINUSOIDALdB=20*log10(abs(fft(sinalfiltrado1+S*sinalsinusoidal)/N));
SINALFILTRADOmaisSINUSOIDALdB=20*log10(abs(fft(sinalfiltrado+S*sinalsinusoidal)/N));

% plot both random noise+sinusoid signals spectra
subplot(2,2,4), plot((fsN)*(1:round(N/5)), SINALmaisSINUSOIDALdB(1:round(N/5)),(fsN)*(1:round(N/5)), SINALFILTRADOmaisSINUSOIDALdB(1:round(N/5))); grid on; title('sin. al. ref.+sinus. e sin. al. iter.+sinus.')
if m==1
    V=axis;
end
axis(V);

% after first phase play reference only with sinusoid
if m>20
    S=1;
    sound(sqrt(2)*[sinalsinusoidal,sinalsinusoidal],fs,16 )
else
    S=0;
%     + 0 dB
    sound([sinalfiltrado1+S*sinalsinusoidal, sinalfiltrado1+S*sinalsinusoidal], fs, 16)
    pause(1.5)
%     + 3 dB
    sound(sqrt(2)*[(sinalfiltrado1+S*sinalsinusoidal),(sinalfiltrado1+S*sinalsinusoidal)],fs,16)
    pause(1.5)
%     + 6 dB
    sound((2)*[(sinalfiltrado1+S*sinalsinusoidal),(sinalfiltrado1+S*sinalsinusoidal)],fs,16)
end

% pause to play next signal in the iteration
pause(2)
% target signal
sound([sinalfiltrado+S*sinalsinusoidal,sinalfiltrado+S*sinalsinusoidal],fs,16)

FROitava=1/18+m*FROitavaStep
m=m+1;
% pause for next iteration
pause(4)
end

% pause to next activity
pause



% Activity 2- determination of out of band tone by tone masking effect for 
% two spot sinusoidal frequencies
% f0=1000Hz, f1=1880Hz

% take note of the m and LdB values at the right iteration (which is it?)

f1=1880;
sinalsinusoidal1=1*SF0*sqrt(2)*sin(2*pi*f0*t)';
SF1=SF0*0.01;

m=1
while SF1<SF0
    m
    sinalsinusoidal2=SF1*sqrt(2)*sin(2*pi*f1*t)';
    sinalsoma=sinalsinusoidal2+sinalsinusoidal1;
    sinalsoma=sinalsoma.*W;
    sound([sinalsoma, sinalsoma],fs,16)
    figure(2)
    
    SINALSOMAdB=20*log10(abs(fft(sinalsoma)/N));

    plot((fsN)*(1:round(N/5)), SINALSOMAdB(1:round(N/5))); grid on; grid minor;
    if m==1
    V=axis;
    end
    axis(V);
    % increase amplitude by 2dB
    SF1=SF1*10^(2/20);
    LdB=20*log10(SF1/SF0)
    m=m+1;
    pause(3) 
end
    

