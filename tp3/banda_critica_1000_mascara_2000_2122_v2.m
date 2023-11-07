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

fs = 11025;              % Sampling frequency (Hz)
f0 = 1000;               % Fundamental frequency of the sinusoidal signal (Hz)
FROitava = 1/18;         % Octave factor for the starting frequency
FROitavaStep = 1/36;     % Step size for increasing the octave factor
FROitavafinal = 1.25;    % Final desired octave factor
m = 1;                   % Iteration counter
T = 0.8;                 % Signal duration (seconds)
sinal = randn(round(T * fs), 1);  % Generate random noise signal
N = length(sinal);       % Length of the signal
fsN = fs / N;           % Frequency spacing

% Preparation of a special window function to smooth signal attack and release
N1 = round(N / 20);
N2 = round(N / 5);
W = hann(2 * N1);        % Hann window for smoothing attack
W1 = hann(2 * N2);       % Hann window for smoothing release
W = [W(1:N1); ones(N - N1 - N2, 1); W1(N2 + 1:2 * N2)];  % Combine the windows


sinal = sinal .* W; % Smooth the signal's attack and release

SINAL = fft(sinal) / N; % Calculate the signal's Fourier transform

% Produce a sinusoidal signal with the same RMS value
t = 0:1 / fs:(N - 1) / fs;
sinalsinusoidal = 1 * sqrt(2) * sin(2 * pi * f0 * t)';  % Generate a sinusoidal signal
sinalsinusoidal = sinalsinusoidal .* W;  % Apply the smoothing window

S = 0; % Initialize a switch variable
pause(5) % Pause for 5 seconds


pause(5)
while FROitava<FROitavafinal
    m

% Calculate the bandwidth and frequencies for the elliptic filter design
BW=f0*(2^FROitava-1)/2^(FROitava/2);
f1=f0/2^(FROitava/2);
f2=f0*2^(FROitava/2);
wp1=f1/(fs/2);
wp2=f2/(fs/2);
declive=100;

% Design an elliptic filter
n=ellipord([wp1 wp2], [wp1/(4/3) wp2*(4/3)], 0.1, declive);
[B,A]=ellip(n, 0.1, 100, [wp1 wp2]);

% Initial random signals
figure(1)

% Plot the original random signal
subplot(2,2,1), plot(sinal); grid on; title('sinal aleatório');

% Filter the signal using the elliptic filter
sinalfiltrado=filter(B,A,sinal);

% Calculate the Fourier transform of the filtered signal
SINALFILTRADO=fft(sinalfiltrado)/N;

if m==1
    % Memorize the first filtered random signal and its RMS value
    sinalfiltrado1=sinalfiltrado;
    SF0=sqrt(sinalfiltrado'*sinalfiltrado/N);
    % Calibrate the sinusoidal signal to have the same RMS value
    sinalsinusoidal=SF0*sinalsinusoidal;
end

% Calculate the RMS value of the filtered signal
SF=sqrt(sinalfiltrado'*sinalfiltrado/N);

% Normalize the filtered signal to match the original RMS value
sinalfiltrado=sinalfiltrado*SF0/SF;

% Calculate the RMS amplitude of the filtered signal
SF=sqrt(sinalfiltrado'*sinalfiltrado/N);

% Plot the filtered random signal
subplot(2,2,2), plot(sinalfiltrado); grid on; title('sinal aleatório iterativamente filtrado');

% Calculate and plot the spectra of the original and filtered signals
SINALdB=20*log10(abs(SINAL));
SINALFILTRADOdB=20*log10(abs(SINALFILTRADO));
subplot(2,2,3), plot((fsN)*(1:round(N/5)), SINALdB(1:round(N/5)),(fsN)*(1:round(N/5)), SINALFILTRADOdB(1:round(N/5))); grid on; ; title('espectros do sin. al. e do si. al. filtrado');

% Calculate and plot the spectra of the signals with added sinusoidal component
SINALmaisSINUSOIDALdB=20*log10(abs(fft(sinalfiltrado1+S*sinalsinusoidal)/N));
SINALFILTRADOmaisSINUSOIDALdB=20*log10(abs(fft(sinalfiltrado+S*sinalsinusoidal)/N));
subplot(2,2,4), plot((fsN)*(1:round(N/5)), SINALmaisSINUSOIDALdB(1:round(N/5)),(fsN)*(1:round(N/5)), SINALFILTRADOmaisSINUSOIDALdB(1:round(N/5))); grid on; title('sin. al. ref.+sinus. e sin. al. iter.+sinus.')



if m==1
    V=axis;
end
axis(V);

% After the first phase, play the reference signal with only the sinusoid
if m>20
    S=1;
    sound(sqrt(2)*[sinalsinusoidal,sinalsinusoidal],fs,16 )
else
    S=0;
    % Play the filtered signal with sinusoidal component at different amplitudes
%     + 0 dB
    sound([sinalfiltrado1+S*sinalsinusoidal, sinalfiltrado1+S*sinalsinusoidal], fs, 16)
    pause(1.5)
%     + 3 dB
    sound(sqrt(2)*[(sinalfiltrado1+S*sinalsinusoidal),(sinalfiltrado1+S*sinalsinusoidal)],fs,16)
    pause(1.5)
%     + 6 dB
    sound((2)*[(sinalfiltrado1+S*sinalsinusoidal),(sinalfiltrado1+S*sinalsinusoidal)],fs,16)
end

% Pause for 2 seconds before playing the target signal in the iteration
pause(2)

% Play the target signal, which is a combination of the filtered signal and
% a sinusoidal component scaled by 'S'.
sound([sinalfiltrado+S*sinalsinusoidal,sinalfiltrado+S*sinalsinusoidal],fs,16)

% Update the value of 'FROitava' for the next iteration, increasing it by
% 'FROitavaStep'.
FROitava=1/18+m*FROitavaStep

% Increment the iteration counter 'm'.
m=m+1;

% Pause for 4 seconds before starting the next iteration
%pause(4)
break
end

% Pause for an unspecified amount of time, likely to indicate the end of
% this activity.
pause



% Activity 2- determination of out of band tone by tone masking effect for 
% two spot sinusoidal frequencies
% f0=1000Hz, f1=1880Hz

% take note of the m and LdB values at the right iteration (which is it?)

f1=1880; % Frequency of the second sinusoidal signal (Hz)
sinalsinusoidal1=1*SF0*sqrt(2)*sin(2*pi*f0*t)'; % Generate the first sinusoidal signal
SF1=SF0*0.01; % Initialize the amplitude of the second sinusoidal signal

m=1 % Initialize the iteration counter

% Initialize the amplitude of the second sinusoidal signal
while SF1<SF0
    m
    % Generate the second sinusoidal signal with the current amplitude (SF1)
    sinalsinusoidal2=SF1*sqrt(2)*sin(2*pi*f1*t)';
    
    % Combine the first and second sinusoidal signals
    sinalsoma=sinalsinusoidal2+sinalsinusoidal1;

    % Apply the smoothing window
    sinalsoma=sinalsoma.*W;

    % Play the combined signal twice
    sound([sinalsoma, sinalsoma],fs,16)
    figure(2)
    
    % Calculate the Fourier transform of the combined signal and convert it to dB
    SINALSOMAdB=20*log10(abs(fft(sinalsoma)/N));
    
    % Plot the spectrum of the combined signal for a portion of the data
    plot((fsN)*(1:round(N/5)), SINALSOMAdB(1:round(N/5))); grid on; grid minor;
    
    if m==1
    V=axis; % Plot the spectrum of the combined signal for a portion of the data
    end
    axis(V);

    % Increase the amplitude of the second sinusoidal signal by 2 dB
    SF1=SF1*10^(2/20);
    LdB=20*log10(SF1/SF0) % Calculate the increase in dB
    
    m=m+1; % Increment the iteration counter

    % Pause for 3 seconds before the next iteration
    pause(3) 
end
    

