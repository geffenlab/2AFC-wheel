function [stim, events] = spatialAdaptorGen(stimInfo,params)


%% set variables - provided by the input
% stimInfo.fs                 = 192e3;            % sample rates
% stimInfo.adaptor_ILDs       = 0;              % ILD of the adaptor in dB
% stimInfo.adaptor_SDs        = 10;               % standard deviation of adaptor
% stimInfo.adaptor_dur        = 0.5;              % adaptor duration in s
% stimInfo.adaptor_pip_dur    = 0.005;           % duration of individual adaptor pips
% stimInfo.adaptor_level      = 60;               % mean level dB
% stimInfo.adaptor_bandwidth  = [5 60];        % adaptor bandwidth in kHz
% stimInfo.target_dur         = 0.5;              % target duration in s
% stimInfo.target_level       = 60;               % mean level dB
% stimInfo.target_ILDs        = [-30,30];        % ILD of target
% stimInfo.target_bandwidth   = [10 40];        % target bandwidth in kHz
% stimInfo.envDur             = 0.005;            % duration of envelope in s
% stimInfo.stimFunction       = 'spatialAdaptorGen'; % stimulus function
si = stimInfo;
%% choose the adaptor_ILD
if length(si.adaptor_ILDs)==1
    si.adaptor_ILD = si.adaptor_ILDs(1);
    si.adaptor_SD = si.adaptor_SDs(1);
end

%% Choose the target_trial_ILD
si.target_trial_ILD = si.target_ILDs(si.trialType);


%% Make the adaptor
if si.adaptor_dur > 0
    n_pips = si.adaptor_dur/si.adaptor_pip_dur;
    pip_ILDs = si.adaptor_ILD + si.adaptor_SD.*randn(n_pips,1);
    t = rand(si.adaptor_dur*si.fs,1);                           % create noise
    [b,a] = butter(7,si.adaptor_bandwidth*1000/(si.fs/2));      % create filter
    t = filtfilt(b,a,t);                                        % filter

    % apply speaker filter
    tL = conv(t,si.FILT_left,'same');
    tR = conv(t,si.FILT_right,'same');

    % Attenuate to baseline level (70 dB) and then adaptor level
    left_att = si.adaptor_level - 70 + params.leftspk_adaptor_offset;
    right_att = si.adaptor_level - 70 + params.rightspk_adaptor_offset;
    tL = tL.*10.^(left_att/20);
    tR = tR.*10.^(right_att/20);

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

    tL = tL.*10.^(-ramp_env/20);
    tR = tR.*10.^(ramp_env/20);




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

else
    adaptor = [];
end

%% Make the target
target_ild = si.target_trial_ILD;
t = rand(si.target_dur*si.fs,1);                           % create noise
[b,a] = butter(7,si.target_bandwidth*1000/(si.fs/2));      % create filter
t = filtfilt(b,a,t);                                        % filter

% apply speaker filter
tL = conv(t,si.FILT_left,'same');
tR = conv(t,si.FILT_right,'same');

% Attenuate to baseline level (70 dB) and to adaptor level and then target
% offsets
left_att = si.adaptor_level - 70 + params.leftspk_adaptor_offset + params.leftspk_target_offset;
right_att = si.adaptor_level - 70 + params.rightspk_adaptor_offset + params.rightspk_target_offset;
tL = tL.*10.^(left_att/20);
tR = tR.*10.^(right_att/20);

% Change target ILD
tL = tL.*10^(-(target_ild/2)/20);
tR = tR.*10^((target_ild/2)/20);
tL = envelopeKCW(tL,si.envDur*1000,si.fs);
tR = envelopeKCW(tR,si.envDur*1000,si.fs);
target = [tL,tR];
% sound([adaptor;target]/100,si.fs)

stim = ([adaptor;target]);


%% make events
% event_dur = .01 * stimInfo.fs; % 5 ms events for onset and offset
% pad to add ending event
% stim = [stim; zeros(event_dur-1,2)];
events = ones(length(stim),1);
% events(1:event_dur) = 1;
% events(length(stim)-event_dur+1:length(stim)) = 1;

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


