clear all
close all
clc

fprintf("Programa começou!\n\n")
dq = daq("directsound");
addinput(dq,"Audio1",1,"Audio");



hf = figure;
hp = plot(zeros(1000,1));
T = title('Discrete FFT Plot'); %The magnitude tells you the strength of the frequency components relative to other components
xlabel('Frequency (Hz*10^2)')
xlim([0.5 4])
ylim([-70 70])
ylabel('dB') 
grid on;


dq.ScansAvailableFcn = @(src, evt) continuousFFT(src, hp);


fprintf("Inicio da Gravação\n")

start(dq,"Duration",seconds(10));
figure(hf);


aux = read(dq);
fprintf("tamanho final: %d\n", length(dq));

function continuousFFT(daqHandle, plotHandle)
global accquiredData
% Calculate FFT(data) and update plot with it.
data = read(daqHandle, daqHandle.ScansAvailableFcnCount, "OutputFormat", "Matrix");

Fs = daqHandle.Rate;
lengthOfData = length(data);
lenghOfData_full = length(accquiredData);

% next closest power of 2 to the length
nextPowerOfTwo = 2 ^ nextpow2(lengthOfData);
nextPowerOfTwo_full = 2 ^ nextpow2(lenghOfData_full);

fprintf("tamanha da variavel global: %d\n", length(accquiredData))
accquiredData = [accquiredData;data];
%audiowrite("./test_sound.mp3", accquiredData, Fs);

plotScaleFactor = 4;
% plot is symmetric about n/2
plotRange = nextPowerOfTwo / 2; 
plotRange = floor(plotRange / plotScaleFactor);

plotRange_full = nextPowerOfTwo_full / 2;
plotRange_full = floor(plotRange_full / plotScaleFactor);

yDFT = fft(data, nextPowerOfTwo); 
yDFT_full = fft(accquiredData, nextPowerOfTwo_full); 

espetro = spectrogram(accquiredData);
spectrogram(espetro, "yaxis")

h = yDFT(1:plotRange);
abs_h = abs(h);

h_full = yDFT_full(1:plotRange_full);
abs_h_full = abs(h_full);

% Frequency range
freqRange = (0:nextPowerOfTwo-1) * (Fs / nextPowerOfTwo);
freqRange = (0:nextPowerOfTwo_full-1) * (Fs / nextPowerOfTwo_full);
% Only plot up to n/2 (as other half is the mirror image)
gfreq = freqRange(1:plotRange);  
gfreq_full = freqRange(1:plotRange_full);  


% Take the logarithm of both x and y data
log_xdata = log10(gfreq);
log_ydata = 20* log10(abs_h);%to put in dB

log_xdata_full = log10(gfreq_full);
log_ydata_full = 20* log10(abs_h_full);%to put in dB

% Update the plot
set(plotHandle, 'ydata', abs_h, 'xdata', gfreq);
set(plotHandle, 'ydata', log_ydata, 'xdata', log_xdata);
drawnow
end