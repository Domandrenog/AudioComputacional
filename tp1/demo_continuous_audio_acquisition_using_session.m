%% Acquire Continuous Audio Data
% This example shows how to set up a continuous audio acquisition. This 
% example uses a two-channel microphone.
%
%    Copyright 2013 The MathWorks, Inc.

%%
% In this example you generate data using the sound card on your computer
% using a 5.1 channel speaker setup. Before you begin, verify that your
% environment is set up so that you can generate data with your sound card.
% For more information refer to "Troubleshooting in Data Acquisition 
% Toolbox".

%% View available audio devices

d = daq.getDevices

%% 
% This example uses a microphone with device ID 'Audio1'.

dev = d(2)

%% Create an audio session
% Create a session with |directsound| as the vendor and add an audio input
% channel to it.

s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1:1);

%% 
% Prepare session for continuous operation.

s.IsContinuous = true

%% 
% Set up the plot for an FFT of the live input.

hf = figure;  
hp = plot(zeros(1000,1));  
T = title('Discrete FFT Plot');
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on;

%%
type helper_continuous_fft.m

%% Add |DataAvailable| listener
% Listener updates the figure with the FFT of the live input signal.

plotFFT = @(src, event) helper_continuous_fft(event.Data, src.Rate, hp);
hl = addlistener(s, 'DataAvailable', plotFFT);

%% Start acquisition
% Observe that the figure updates as you use the microphone.

startBackground(s);
figure(hf);

%%%
% Wait for 10 seconds while continuing to acquire data via the microphone.

pause(10);

%%%
% Stop the session.

stop(s);
s.IsContinuous = false;
delete(hl);
