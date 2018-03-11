function [stim, events, seed] = toneCloudGen_CA(stimInfo) % fs,tonePipDur,totalDur,cloudRange,nLogSteps,envDur,tonePipRate,toneLevel,FILT

% set variables
% stimInfo.fs              = 4e5;              % sample rate
% stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
% stimInfo.totalDur        = 1;                % total duration of each tone cloud
% stimInfo.cloudRange      = [5000 10000];     % range of tones within the cloud
% stimInfo.nLogSteps       = 10;               % number of tones in the range
% stimInfo.envDur          = 0.005;            % duration of tone pip envelope
% stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
% stimInfo.toneLevel       = 70;               % levels of tones in dB

stimInfo.range      = stimInfo.cloudRange(stimInfo.trialType,:);


% determine further variables
stimInfo.index = round(logspace(log10(stimInfo.range(1)),log10(stimInfo.range(2)),stimInfo.nLogSteps)); % frequency range
% stimInfo.index = round(exp(linspace(log(stimInfo.range(1)),log(stimInfo.range(2)),stimInfo.nLogSteps))); % frequency range
stimInfo.nTones = stimInfo.totalDur*stimInfo.tonePipRate; % number of tones in stimulus
atten = 70-stimInfo.toneLevel; % convert tone level to attenuation from 70 dB (filter is set to make sounds at 70 dB)

% make matrix of tones
toneMat = zeros(length(stimInfo.index),stimInfo.tonePipDur*stimInfo.fs); % preallocate tone matrix
for ii=1:length(stimInfo.index)
    t = tone(stimInfo.index(ii),3/2*pi,stimInfo.tonePipDur,stimInfo.fs); % make tone 
    toneMat(ii,:)  = envelopeKCW(t,stimInfo.envDur*1000,stimInfo.fs); % envelope it
%     toneMat(ii,:) = t.*10^(-atten/20); % attenuate    
%     toneMat(ii,:) =  conv(t,stimInfo.FILT,'same');% filter it
end

% make stim
seed = round(rand(1,1)*1000);
rng(seed);
r = randi(length(stimInfo.index),stimInfo.nTones,1); % randomly select tones from the range
% stimInfo.order = r; % save order of tones ?
tonePipOnsets = 1:round(stimInfo.totalDur*stimInfo.fs)/stimInfo.tonePipRate:round(stimInfo.totalDur*stimInfo.fs); % tone pip onsets
stim = zeros(tonePipOnsets(end)+(stimInfo.tonePipDur*stimInfo.fs),1); % preallocate stim 
for ii=1:stimInfo.nTones
    stim(tonePipOnsets(ii):tonePipOnsets(ii)+(stimInfo.tonePipDur*stimInfo.fs)-1,1)...
        = stim(tonePipOnsets(ii):tonePipOnsets(ii)+(stimInfo.tonePipDur*stimInfo.fs)-1,1)+toneMat(r(ii),:)';
end
% stim(1:round(0.1*stimInfo.fs),2) = ones(round(0.1*stimInfo.fs),1)*5; % event time
stim  = stim.*10^(-atten/20); % attenuate  
stim = conv(stim,stimInfo.FILT,'same');
% check stim
% spectrogram(stim(:,1), 1000, 0, 10000, stimInfo.fs,'yaxis');
stim = stim' / 10;

% make the events
pulseLength = .005 * stimInfo.fs;
% pad to add ending event
stim = [stim zeros(1,pulseLength-1)];
events = zeros(1,length(stim));
events(1:pulseLength) = .5;
events(length(stim)-pulseLength+1:length(stim)) = .5;

%spectrogram(stim,512,128,linspace(1,50e3,100),stimInfo.fs,'yaxis')

%% save stim
% chunk_size = []; nbits = 16;
% fn = [filename '.wav'];
% stim = (stim/10);
% wavwrite_append(stim, fn, chunk_size, fs, nbits)
% save([filename '_stimInfo.mat'],'stimInfo')









function x=tone(f,ph,dur,sf)
% x=tone(f,ph,dur,sf); returns a sine tone of freq f Hz, phase ph rad, duration dur sec at sample rate sf Hz

npts=dur*sf;
inc=2*pi*f/sf;
x=(0:npts-1)*inc+ph;
x=cos(x);





function output_signal = envelopeKCW(signal,rampDur,fs)
% This function tries to remove the transients in the signal by enveloping the first and last period. Ramp duration is defined by rampDur in **ms** envelope(signal,rampDuration,samplerate)

samples=round((rampDur/1000)*fs);
x = -pi:pi/samples:0;
y = 0:pi/samples:pi;
output_signal = signal;


% prepare the envelope functions
envelope_function(1:samples) = cos(x(1:samples))/2+0.5;

% fade in
for i = 1 : samples
    output_signal(i) = signal(i) * envelope_function(i);
end

% fade out
for i = 0 : (samples-1)
    current_position = length(signal) - i;
    output_signal(current_position) = signal(current_position) * envelope_function(i+1);
end



    
    