% a = logspace(log10(5000),log10(40000),8); % tone clouds
% a = log2space(5000, 32000,8); % tone clouds

% stimulus info stuff
stimInfo.stimFunction    = 'toneCloudGen'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 1;                % total duration of each tone cloud
stimInfo.cloudRange      = [5000 10000; 15000 30000; 20000 40000]; % range of tones within the cloud
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.005;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 66;               % levels of tones in dB
stimInfo.fs              = 192e3;

% task specific stuff
params.stimFunc = 'toneCloudGen_CA(stimInfo);';
params.taskType = 'TC_highGenTraining';


% booth specific parameters
params.boothID = 'booth3';
params.com = 'COM4';
params.rewardDuration = 35;
params.rotaryDebounce = 10;
params.device = 'Lynx E44';
params.channel = [1 2];
params.fs = 192e3;
params.filtFile = 'booth3-170727-wdsfilter-192kHz';
params.ampF = 10/11;

% filter
params.filtdir = 'D:\GitHub\filters';
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile]);
params.filt = FILT;

% task parameters
params.holdDuration       = 1.5;
params.respDuration       = 1.2;
params.timeoutDuration    = 5000;
params.trialTypeRatios    = [50 25 25];
params.rewardContingency  = [1 2 2];
params.timeOutContingency = [1 1 1];

% fix some other things
stimInfo.FILT = params.filt;
stimInfo.respDuration = .5;


