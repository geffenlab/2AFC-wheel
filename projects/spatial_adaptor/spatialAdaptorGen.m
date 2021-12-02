function [stim, events] = spatialAdaptorGen(stimInfo)


%% set variables - provided by the input
% stimInfo.fs             = 100e3;            % sample rates
% stimInfo.adaptor_ILD    = -10;               % ILD of the adaptor in dB
% stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
% stimInfo.adaptor_level  = 60;               % mean level dB
% stimInfo.adaptor_bandwidth = [3 10];        % adaptor bandwidth in kHz
% stimInfo.target_ILD     = -30:10:30;        % ILD of target
% stimInfo.target_dur     = 0.2;              % target duration in s
% stimInfo.target_level   = 70;               % mean level dB
% stimInfo.target_bandwidth = [3 5];        % target bandwidth in kHz
% stimInfo.envDur         = 0.005;            % duration of envelope in s
si = stimInfo;

%% choose the adaptor_ILD
if length(si.adaptor_ILDs)==1
    si.adaptor_ILD = si.adaptor_ILDs(1);
    si.adaptor_SD = si.adaptor_SDs(1);
end

%% Choose the target_trial_ILD
si.target_trial_ILD = si.target_ILDs(si.trialType);


%% Make the adaptor
n_pips = si.adaptor_dur/si.adaptor_pip_dur;
pip_ILDs = si.adaptor_ILD + si.adaptor_SD.*randn(n_pips,1);
t = rand(si.adaptor_dur*si.fs,1);                           % create noise
[b,a] = butter(7,si.adaptor_bandwidth*1000/(si.fs/2));      % create filter
t = filtfilt(b,a,t);                                        % filter
tL = t;
tR = t;
if si.adaptor_ILD<0                                         % change ILD
    tL = tL.*10^(abs(si.adaptor_ILD)/20);     
elseif si.adaptor_ILD>0
    tR = tR*10^(abs(si.adaptor_ILD)/20);   
end
tL = envelopeKCW(tL,si.envDur*1000,si.fs);
tR = envelopeKCW(tR,si.envDur*1000,si.fs);
adaptor = [tL,tR];
% sound(adaptor/100,si.fs)

%% Make the target
target_ild = si.target_trial_ILD;
t = rand(si.target_dur*si.fs,1);                           % create noise
[b,a] = butter(7,si.target_bandwidth*1000/(si.fs/2));      % create filter
t = filtfilt(b,a,t);                                        % filter
tL = t;
tR = t;
if target_ild<0                                         % change ILD
    tL = tL.*10^(abs(target_ild)/20);                            
elseif si.adaptor_ILD>0
    tR = tR*10^(abs(target_ild)/20); 
end
tL = envelopeKCW(tL,si.envDur*1000,si.fs);
tR = envelopeKCW(tR,si.envDur*1000,si.fs);
target = [tL,tR];
% sound([adaptor;target]/100,si.fs)

stim = ([adaptor;target]);
stim(:,1) = conv(stim(:,1),stimInfo.FILT,'same');
stim(:,2) = conv(stim(:,2),stimInfo.FILT,'same');

%% make events
event_dur = .005 * stimInfo.fs; % 5 ms events for onset and offset
% pad to add ending event
stim = [stim; zeros(event_dur-1,2)];
events = zeros(length(stim),1);
events(1:event_dur) = 0.5;
events(length(stim)-event_dur+1:length(stim)) = 0.5;

stim = stim/10;
stim = stim';
events = events';

% spectrogram(stim(:,1),256,200,256,si.fs,'yaxis');

function output_signal = envelopeKCW(signal,rampDur,fs)
% This function tries to remove the transients in the signal by enveloping the first and last period. Ramp duration is defined by rampDur in **ms** envelope(signal,rampDuration,samplerate)
samples=round((rampDur/1000)*fs);
x = -pi:pi/samples:0;
y = 0:pi/samples:pi;
output_signal = signal;

