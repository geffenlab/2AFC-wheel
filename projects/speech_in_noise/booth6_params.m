% task
params.taskType = 'SPINtrain';

% booth parameters
params.boothID = 'booth6';
params.com = 'COM5';
params.rewardDuration = 15;
params.rotaryDebounce = 1000;
params.device = '2- Lynx E44';
params.channel = [1 2];
params.fs = 192e3;
params.filtFile = 'booth6-170727-wdsfilter-192kHz';
params.ampF = 10/11;

% stimulus parameters
params.filtdir = 'D:\GitHub\filters';
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile]);
params.filt = FILT;
params.nTones = 34;
params.fRange = [1e3 50e3];
params.freqs = logspace(log10(1000),log10(50e3),params.nTones);
params.mu = 50;
params.sd = [7.5];
params.rampDuration = .001;
params.chordDuration = .005;
params.blockDuration = 3;
params.baseAmplitude = .1;
params.speechOffset = 1;
params.jitter = .5;
params.gain = 3;
params.stimPath = 'D:\stimuli\speech_in_noise';
params.stimFunc = 'makeSpeechInNoise(params,tt);';
params.noiseFile = [params.stimPath filesep params.boothID ...
    '-' num2str(params.sd) 'filteredNoise.wav'];
params.speechFile = [params.stimPath filesep params.boothID ...
    '-filteredSpeech.mat'];

% task parameters
params.holdDuration       = 1.5;
params.respDuration       = 1.2;
params.timeoutDuration    = 5000;
params.trialTypeRatios    = [50 50];
params.rewardContingency  = [1 2];
params.timeOutContingency = [1 1];

% check to make sure the noise and filtered speech sounds exist
tt = 1;
eval(params.stimFunc);
    

