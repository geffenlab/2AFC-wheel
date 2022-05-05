
stimInfo.seed           = now;
rng(stimInfo.seed)

%% stimulus parameters
stimInfo.fs                 = 192e3;                % sample rates
stimInfo.adaptor_ILDs       = 0;                    % ILD of the adaptor in dB
stimInfo.adaptor_SDs        = 10;                   % standard deviation of adaptor
stimInfo.adaptor_dur        = 0.5;                  % adaptor duration in s
stimInfo.adaptor_pip_dur    = 0.005;                % duration of individual adaptor pips
stimInfo.adaptor_level      = 60;                   % mean level dB
stimInfo.adaptor_bandwidth  = [5 60];               % adaptor bandwidth in kHz
stimInfo.target_dur         = 0.5;                  % target duration in s
stimInfo.target_level       = 60;                   % mean level dB
stimInfo.target_ILDs        = [-30,30];             % ILD of target
stimInfo.target_bandwidth   = [10 40];              % target bandwidth in kHz
stimInfo.envDur             = 0.005;                % duration of envelope in s
stimInfo.stimFunction       = 'spatialAdaptorGen';  % stimulus function

%% TASK PARAMETERS
% task specific stuff
params.stimFunc = 'spatialAdaptorGen(stimInfo,params);';
params.taskType = 'training_01';
params.beh_func = 'freeMoving_2AFC_stage_01_02';
params.hexFile = 'freeMoving_2AFC_stage_01.ino.hex';
params.com = 'COM5';
params.device = 'Lynx E44';
params.channel = [1 2 3 4];
params.fs = 192e3;

% specific task parameters
params.rewardDuration_L = 250;
params.rewardDuration_R = 250;
params.rewardDuration_C = 250;
params.rewardInterval = 5000; % seconds
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [0 0];

% filter parameters
params.filtFile_left = '220210_2afc_LEFTspk_LynxE44_5k-60k_fs192k_FLATNOISE';
params.filtFile_right = '220210_2afc_RIGHTspk_LynxE44_5k-60k_fs192k_FLATNOISE';
params.ampF = 10/11;
params.leftspk_adaptor_offset = -1.1;
params.rightspk_adaptor_offset = -1;
params.leftspk_target_offset = 2;
params.rightspk_target_offset = 2;



% save('C:\Users\Maria\Documents\MATLAB\Calibration\20211206_2afcwheel_calibration\SA_params.mat','stimInfo');