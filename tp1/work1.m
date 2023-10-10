dq = daq("directsound");
addinput(dq,"Audio1",1,"Audio");

hf = figure;
hp = plot(zeros(1000,1));
T = title('Discrete FFT Plot'); %The magnitude tells you the strength of the frequency components relative to other components
xlabel('Frequency (Hz)')
xlim([0 4000]) %Ser mais fácil para ouvir a voz humana
ylabel('|Y(f)|') 
grid on;


dq.ScansAvailableFcn = @(src, evt) continuousFFT(src, hp);



start(dq,"Duration",seconds(10));
figure(hf);


function continuousFFT(daqHandle, plotHandle)
% Calculate FFT(data) and update plot with it.
data = read(daqHandle, daqHandle.ScansAvailableFcnCount, "OutputFormat", "Matrix");
Fs = daqHandle.Rate;

lengthOfData = length(data);
% next closest power of 2 to the length
nextPowerOfTwo = 2 ^ nextpow2(lengthOfData);

plotScaleFactor = 4;
% plot is symmetric about n/2
plotRange = nextPowerOfTwo / 2; 
plotRange = floor(plotRange / plotScaleFactor);

yDFT = fft(data, nextPowerOfTwo); 

h = yDFT(1:plotRange);
abs_h = abs(h);

% Frequency range
freqRange = (0:nextPowerOfTwo-1) * (Fs / nextPowerOfTwo);
% Only plot up to n/2 (as other half is the mirror image)
gfreq = freqRange(1:plotRange);  


% Update the plot
set(plotHandle, 'ydata', abs_h, 'xdata', gfreq);
drawnow
end