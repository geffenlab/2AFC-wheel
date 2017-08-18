%% save mouse info for FM stimuli TRAINING

clear
stimInfo.mouse  = 'test';
stimInfo.stimFunction = 'FM_stimGen_v2.m'; % stimulus function
stimInfo.modRates = [10,50]; % FM modulation rates
stimInfo.carrierFreq = 12000; % Hz
stimInfo.modDepth = 5000; % modulation depth in Hz
stimInfo.stimDur = 0.3; % in seconds
stimInfo.level = 70; % in dB
save(['E:\Data\' stimInfo.mouse '\' stimInfo.mouse '_TRAINING_stimInfo.mat']);

%% save mouse info for FM stimuli TESTING

clear
stimInfo.mouse  = 'SR002';
stimInfo.stimFunction = 'FM_stimGen.m'; % stimulus function
stimInfo.modRates = [10,17,24,30,36,43,50]; % FM modulation rates
stimInfo.trialPC = [37.5,5,5,5,5,5,37.5]; % per cent presentation of each trial type (should add to 100%)
stimInfo.timeouts = [1,0,0,0,0,0,1]; % which trials will have timeouts
stimInfo.rewardContingency = [1,1,1,0,2,2,2]; % which side will be rewarded for each rate
stimInfo.carrierFreq = 12000; % Hz
stimInfo.modDepth = 5000; % modulation depth in Hz
stimInfo.stimDur = 0.3; % in seconds
save(['E:\Data\' stimInfo.mouse '\' stimInfo.mouse '_TESTING_stimInfo.mat']);

%% save mouse info for tone cloud stimuli

clear
stimInfo.stimFunction    = 'toneCloudGen.m'; % stimulus function
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


save(['E:\Data\projects\wheel_toneClouds\' 'training_initial.mat']);

%% save mouse info for tone cloud stimuli TESTING!

clear
% stimInfo.mouse           = 'SR002';          % mouse
stimInfo.stimFunction    = 'toneCloudGen.m'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 1;                % total duration of each tone cloud
stimInfo.cloudRange      = [1000 2000;...
                            2000 3000;...
                            3000 4000;...
                            4000 5000;...
                            5000 6000];               % range of tones within the cloud
stimInfo.trialPC = [20,20,20,20,20]; % per cent presentation of each trial type (should add to 100%)
stimInfo.timeouts = [1,0,0,0,1]; % which trials will have timeouts
stimInfo.rewardContingency = [1,0,0,0,2]; % which side will be rewarded for each rate
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.005;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 70;               % levels of tones in dB


save(['E:\Data\projects\wheel_toneClouds\testing_test.mat']);

%% save mouse info for tone cloud stimuli GENERALISATION TRAINING!

clear
% stimInfo.mouse           = 'WR001';          % mouse
stimInfo.stimFunction    = 'toneCloudGen.m'; % stimulus function
stimInfo.tonePipDur      = 0.030;            % duration of each tone pip in cloud
stimInfo.totalDur        = 1;                % total duration of each tone cloud
stimInfo.cloudRange      = [15000 30000;...
                            20000 40000];               % range of tones within the cloud
stimInfo.trialPC = [50,50]; % proportion presentation of each trial type
stimInfo.timeouts = [1,1]; % which trials will have timeouts
stimInfo.rewardContingency = [1,2]; % which side will be rewarded for each rate
stimInfo.nLogSteps       = 10;               % number of tones in the range
stimInfo.envDur          = 0.005;            % duration of tone pip envelope
stimInfo.tonePipRate     = 100;              % presentation rate in Hz (determines tone overlap)
stimInfo.toneLevel       = 70;               % levels of tones in dB


save(['E:\Data\projects\wheel_toneClouds\training_fineHigh.mat']);
