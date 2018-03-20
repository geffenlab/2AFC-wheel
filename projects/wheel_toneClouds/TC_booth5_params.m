% a = logspace(log10(5000),log10(40000),8); % tone clouds
a = 4000 * (2 .^ (([0:8-1])/2)); % tone clouds

% stimulus info stuff
stimInfo.stimFunction    = 'toneCloudGen'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 1;                % total duration of each tone cloud
stimInfo.cloudRange      = [a(1) a(2); a(end-1) a(end)]; % range of tones within the cloud
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.005;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 70;               % levels of tones in dB
stimInfo.fs              = 192e3;

% task specific stuff
params.stimFunc = 'toneCloudGen_CA(stimInfo);';
params.taskType = 'TCtrain';


% booth specific parameters
params.boothID = 'booth5';
params.com = 'COM3';
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
params.holdDuration       = 1.5;
params.respDuration       = 1.2;
params.timeoutDuration    = 5000;
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [1 1];

% fix some other things
stimInfo.FILT = params.filt;
stimInfo.respDuration = .5;


