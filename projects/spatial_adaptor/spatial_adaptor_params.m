
stimInfo.seed           = now;
rng(stimInfo.seed)

% stimInfo parameters
stimInfo.fs             = 192e3;            % sample rates
stimInfo.adaptor_ILD    = -10;              % ILD of the adaptor in dB
stimInfo.adaptor_dur    = 0.5;              % adaptor duration in s
stimInfo.adaptor_level  = 60;               % mean level dB
stimInfo.adaptor_bandwidth = [5 60];        % adaptor bandwidth in kHz
stimInfo.target_dur     = 0.2;              % target duration in s
stimInfo.target_level   = 60;               % mean level dB
stimInfo.target_ILDs     = -10:2:10;        % ILD of target
stimInfo.target_bandwidth = [20 40];        % target bandwidth in kHz
stimInfo.envDur         = 0.005;            % duration of envelope in s
stimInfo.repeats        = 10;
stimInfo.stimFunction    = 'spatialAdaptorGen'; % stimulus function

% task specific stuff
params.stimFunc = 'spatialAdaptorGen(stimInfo);';
params.taskType = 'training';
% % calculate trial index?
% n_tarILDs = length(stimInfo.target_ILDs);
% stimInfo.nTrials        = n_tarILDs*stimInfo.repeats;
% stimInfo.trial_index    = zeros(length(stimInfo.nTrials),1);
% for ii = 1:stimInfo.repeats
%     stimInfo.trial_index((ii-1)*n_tarILDs+1:n_tarILDs*ii) = randperm(n_tarILDs,n_tarILDs);
% end

% booth specific parameters
params.boothID = 'booth1';
params.com = 'COM4';
params.rewardDuration = 64;
params.rotaryDebounce = 10;
params.device = 'Lynx E44';
params.channel = [1 2 3 4];
params.fs = 192e3;
params.filtFile = 'booth1-170727-wdsfilter-192kHz';
params.ampF = 10/11;

% filter
params.filtdir = [params.githubPath '\filters'];
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile]);
params.filt = FILT;

% task parameters
params.holdDuration       = 1.5;
params.respDuration       = 1;
params.timeoutDuration    = 7000;
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [1 1];

% fix some other things
stimInfo.FILT = params.filt;
stimInfo.respDuration = params.respDuration;

% save('SA_params.mat','stimInfo');