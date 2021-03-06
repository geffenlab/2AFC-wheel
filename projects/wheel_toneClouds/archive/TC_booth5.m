

% stimulus info stuff
stimInfo.stimFunction    = 'toneCloudGen'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 1;                % total duration of each tone cloud
stimInfo.cloudRange      = [5000 10000; 20000 40000];               % range of tones within the cloud
stimInfo.trialPC = [50,50]; % per cent presentation of each trial type (should add to 100%)
stimInfo.timeouts = [1,1]; % which trials will have timeouts
stimInfo.rewardContingency = [1,2]; % which side will be rewarded for each rate
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.005;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 70;               % levels of tones in dB
stimInfo.fs              = 192e3;

% stimgen stuff
params.stimFunc = 'toneCloudGen(stimInfo);';

% booth specific parameters
params.boothID = 'booth5';
params.com = 'COM4';
params.rewardDuration = 15;
params.rotaryDebounce = 5;
params.device = 'Lynx E44';
params.channel = [1 2];
params.fs = 192e3;
params.filtFile = 'booth5-170727-wdsfilter-192kHz';
params.ampF = 10/11;

% filter
params.filtdir = 'D:\GitHub\filters';
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile]);
params.filt = FILT;

% task parameters
params.holdDuration       = 350;
params.timeoutDuration    = 5000;

