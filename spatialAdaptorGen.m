function stim = spatialAdaptorGen(stimInfo)

% set variables - provided by the input
stimInfo.fs             = 192e3;            % sample rates
stimInfo.adaptor_ILD    = 10;               % ILD of the adaptor
stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
stimInfo.adaptor_level  = 60;               % mean level dB
stimInfo.target_ILD     = -30:10:30;        % ILD of target
stimInfo.target_dur     = 0.2;              % target duration in s
stimInfo.target_level   = 70;               % mean level dB
stimInfo.envDur         = 0.005;            % duration of envelope in s


