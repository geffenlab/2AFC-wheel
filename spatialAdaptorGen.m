function stim = spatialAdaptorGen(stimInfo)


%% set variables - provided by the input
stimInfo.fs             = 20e3;            % sample rates
stimInfo.adaptor_ILD    = -10;               % ILD of the adaptor in dB
stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
stimInfo.adaptor_level  = 60;               % mean level dB
stimInfo.adaptor_bandwidth = [1 8];        % adaptor bandwidth in kHz
stimInfo.target_ILD     = -30:10:30;        % ILD of target
stimInfo.target_dur     = 0.2;              % target duration in s
stimInfo.target_level   = 70;               % mean level dB
stimInfo.target_bandwidth = [1 3];        % target bandwidth in kHz
stimInfo.envDur         = 0.005;            % duration of envelope in s
si = stimInfo;

%% Make the adaptor
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
sound(adaptor/100,si.fs)

%% Make the target
target_ild = randsample(si.target_ILD,1);
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
sound([adaptor;target]/100,si.fs)

stim = [adaptor;target];

% spectrogram(stim(:,1),256,200,256,si.fs,'yaxis');



