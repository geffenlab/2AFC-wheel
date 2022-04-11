
stimInfo.seed           = now;
rng(stimInfo.seed)

% stimInfo parameters
stimInfo.fs                 = 192e3;            % sample rates
stimInfo.adaptor_ILDs       = 0;              % ILD of the adaptor in dB
stimInfo.adaptor_SDs        = 10;               % standard deviation of adaptor
stimInfo.adaptor_dur        = 0.5;              % adaptor duration in s
stimInfo.adaptor_pip_dur    = 0.005;           % duration of individual adaptor pips
stimInfo.adaptor_level      = 60;               % mean level dB
stimInfo.adaptor_bandwidth  = [5 60];        % adaptor bandwidth in kHz
stimInfo.target_dur         = 0.5;              % target duration in s
stimInfo.target_level       = 60;               % mean level dB
stimInfo.target_ILDs        = [-30,30];        % ILD of target
stimInfo.target_bandwidth   = [5 10];        % target bandwidth in kHz
stimInfo.envDur             = 0.005;            % duration of envelope in s
stimInfo.stimFunction       = 'spatialAdaptorGen'; % stimulus function

% task specific stuff
params.stimFunc = 'spatialAdaptorGen(stimInfo,params);';
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
params.com = 'COM7';
params.rewardDuration = 205;
params.rotaryDebounce = 10;
params.holdTimeMin = 1000;
params.holdTimeMax = 1500;
% params.holdDuration       = 1;
% params.respDuration       = 1;
params.timeoutDuration    = 2000;
params.device = 'Lynx E44';
params.channel = [1 2 3 4];
params.fs = 192e3;
params.filtFile_left = '220210_2afc_LEFTspk_LynxE44_5k-60k_fs192k_FLATNOISE';
params.filtFile_right = '220210_2afc_RIGHTspk_LynxE44_5k-60k_fs192k_FLATNOISE';
params.ampF = 10/11;
params.leftspk_adaptor_offset = -1.1;
params.rightspk_adaptor_offset = -1;
params.leftspk_target_offset = 5;
params.rightspk_target_offset = 5;

% filter
params.filtdir = [params.githubPath '\filters'];
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile_left]);
params.filt_left = FILT;
load([params.filtdir filesep params.filtFile_right]);
params.filt_right = FILT;

% task parameters
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [1 1];

% fix some other things
stimInfo.FILT_left = params.filt_left;
stimInfo.FILT_right = params.filt_right;
% stimInfo.respDuration = params.respDuration;

% save('C:\Users\Maria\Documents\MATLAB\Calibration\20211206_2afcwheel_calibration\SA_params.mat','stimInfo');