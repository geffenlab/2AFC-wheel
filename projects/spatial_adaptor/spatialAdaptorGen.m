function [stim, events] = spatialAdaptorGen(stimInfo)


%% set variables - provided by the input
% stimInfo.fs             = 100e3;            % sample rates
% stimInfo.adaptor_ILD    = -10;               % ILD of the adaptor in dB
% stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
% stimInfo.adaptor_level  = 60;               % mean level dB
% stimInfo.adaptor_bandwidth = [3 10];        % adaptor bandwidth in kHz
% stimInfo.target_ILDs     = -30:10:30;        % ILD of target
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

% Make ramp and apply
si.ramp_dur = 0.001; % ramp duration in s
ramp_samp = si.ramp_dur*si.fs;
ramp_env = zeros(length(t),1);
for ii = 1:length(pip_ILDs)
    range = (ii-1)*(si.adaptor_pip_dur*si.fs)+1:ii*(si.adaptor_pip_dur*si.fs);
    ramp_env(range) = pip_ILDs(ii)/2;
end
for ii = 1:length(pip_ILDs)-1
    range = ii*(si.adaptor_pip_dur*si.fs)-(ramp_samp/2)+1:ii*(si.adaptor_pip_dur*si.fs)+(ramp_samp/2);
    ramp_env(range) = interp1([1 2],[pip_ILDs(ii)/2 pip_ILDs(ii+1)/2],linspace(1,2,ramp_samp));
end
ramp_env(1:ramp_samp/2) = interp1([1 2],[0 pip_ILDs(1)/2],linspace(1,2,ramp_samp/2));
ramp_env(end-ramp_samp/2+1:end) = interp1([1 2],[pip_ILDs(end)/2 0],linspace(1,2,ramp_samp/2));

tL = t.*10.^(-ramp_env/20);
tR = t.*10.^(ramp_env/20);

% ADD IN HERE ATTENUATION TO MAKE SOUND 60 dB IN BOTH SPEAKERS (AFTER
% CALIBRATION)


% tL = t;
% tR = t;
% for ii = 1:length(pip_ILDs)
%     range = (ii-1)*(si.adaptor_pip_dur*si.fs)+1:ii*(si.adaptor_pip_dur*si.fs);
%     tL(range) = tL(range).*10^(-(pip_ILDs(ii)/2)/20);
%     tR(range) = tR(range).*10^((pip_ILDs(ii)/2)/20);
% end
%                                      % change ILD
%  
% tL = envelopeKCW(tL,si.envDur*1000,si.fs);
% tR = envelopeKCW(tR,si.envDur*1000,si.fs);
adaptor = [tL,tR];
%  sound(adaptor/100,si.fs)

%% Make the target
target_ild = si.target_trial_ILD;
t = rand(si.target_dur*si.fs,1);                           % create noise
[b,a] = butter(7,si.target_bandwidth*1000/(si.fs/2));      % create filter
t = filtfilt(b,a,t);                                        % filter
tL = t;
tR = t;
% Change target ILD
tL = tL.*10^(-(target_ild/2)/20);
tR = tR.*10^((target_ild/2)/20);
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
% y = 0:pi/samples:pi;
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


