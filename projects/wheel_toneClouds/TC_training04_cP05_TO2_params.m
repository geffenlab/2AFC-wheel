
stimInfo.seed           = now;
rng(stimInfo.seed)

%% stimulus info stuff
stimInfo.stimFunction    = 'toneCloudGen_KCW'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 0.5;                % total duration of each tone cloud
stimInfo.cloudRange      = [5000 10000; 20000 40000]; % range of tones within the cloud
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.001;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 60;               % levels of tones in dB
stimInfo.fs              = 192e3;


%% TASK PARAMETERS
% task specific stuff
params.stimFunc = 'toneCloudGen_KCW(stimInfo);';
params.taskType = 'toneCloud_training04';
params.beh_func = 'freeMoving_2AFC_stage_04';
params.hexFile = '2afc_freeMoving_stage04.ino.hex';
params.com = 'COM5';
params.device = 'Lynx E44';
params.channel = [1 2 3 4];
params.fs = 192e3;

% specific task parameters
params.rewardDuration_L = 129;
params.rewardDuration_R = 125;
params.rewardDuration_C = 100;
params.holdTimeMin = 0;
params.holdTimeMax = 10;
params.timeoutDuration    = 10000; % ms
params.centerDebounce = 100;
params.centerRewardProb = 0.025;
params.waitTime = 500; % how much does the mouse wait after stim onset
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [1 1];

% filter parameters
params.filtFile_left = '220601_2afc_LEFTspk_LynxE44_5k-60k_fs192k';
params.filtFile_right = '220601_2afc_RIGHTspk_LynxE44_5k-60k_fs192k';
params.ampF = 10/11;
params.leftspk_adaptor_offset = 0;
params.rightspk_adaptor_offset = 0;
params.leftspk_target_offset = 0;
params.rightspk_target_offset = 0;