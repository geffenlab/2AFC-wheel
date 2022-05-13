
stimInfo.seed           = now;
rng(stimInfo.seed)

%% stimInfo parameters
stimInfo.fs                 = 192e3;            % sample rates
stimInfo.adaptor_ILDs       = 0;              % ILD of the adaptor in dB
stimInfo.adaptor_SDs        = 10;               % standard deviation of adaptor
stimInfo.adaptor_dur        = 0.01;              % adaptor duration in s
stimInfo.adaptor_pip_dur    = 0.005;           % duration of individual adaptor pips
stimInfo.adaptor_level      = 60;               % mean level dB
stimInfo.adaptor_bandwidth  = [5 60];        % adaptor bandwidth in kHz
stimInfo.target_dur         = 0.5;              % target duration in s
stimInfo.target_level       = 70;               % mean level dB
stimInfo.target_ILDs        = [-30,30];        % ILD of target
stimInfo.target_bandwidth   = [5 60];        % target bandwidth in kHz
stimInfo.envDur             = 0.005;            % duration of envelope in s
stimInfo.stimFunction       = 'spatialAdaptorGen'; % stimulus function

%% TASK PARAMETERS
% task specific stuff
params.stimFunc = 'spatialAdaptorGen(stimInfo,params);';
params.taskType = 'training_03';
params.beh_func = 'freeMoving_2AFC_stage_03';
params.hexFile = '2afc_freeMoving_stage03.ino.hex';
params.com = 'COM5';
params.device = 'Lynx E44';
params.channel = [1 2 3 4];
params.fs = 192e3;

% specific task parameters
params.rewardDuration_L = 50;
params.rewardDuration_R = 50;
params.rewardDuration_C = 50;
params.holdTimeMin = 0;
params.holdTimeMax = 0;
params.timeoutDuration    = 0;
params.centerDebounce = 20;
params.waitTime = 250; % how much does the mouse wait after stim onset
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [0 0];

% filter parameters
params.filtFile_left = '220503_2afc_LEFTspk_LynxE44_5k-60k_fs192k';
params.filtFile_right = '220503_2afc_RIGHTspk_LynxE44_5k-60k_fs192k';
params.ampF = 10/11;
params.leftspk_adaptor_offset = 0;
params.rightspk_adaptor_offset = 0;
params.leftspk_target_offset = 0;
params.rightspk_target_offset = 0;




% save('C:\Users\Maria\Documents\MATLAB\Calibration\20211206_2afcwheel_calibration\SA_params.mat','stimInfo');