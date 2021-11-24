stimInfo.fs             = 100e3;            % sample rates
stimInfo.adaptor_ILD    = -10;              % ILD of the adaptor in dB
stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
stimInfo.adaptor_level  = 60;               % mean level dB
stimInfo.adaptor_bandwidth = [3 10];        % adaptor bandwidth in kHz
stimInfo.target_dur     = 0.2;              % target duration in s
stimInfo.target_level   = 70;               % mean level dB
stimInfo.target_ILDs     = -10:2:10;       % ILD of target
stimInfo.target_bandwidth = [3 5];          % target bandwidth in kHz
stimInfo.envDur         = 0.005;            % duration of envelope in s
stimInfo.repeats        = 10;
stimInfo.seed           = now;
rng(stimInfo.seed)

n_tarILDs = length(stimInfo.target_ILDs);
stimInfo.nTrials        = n_tarILDs*stimInfo.repeats;
stimInfo.trial_index    = zeros(length(stimInfo.nTrials),1);
for ii = 1:stimInfo.repeats
    stimInfo.trial_index((ii-1)*n_tarILDs+1:n_tarILDs*ii) = randperm(n_tarILDs,n_tarILDs);
end

save('spatial_adpator_params.mat','stimInfo');