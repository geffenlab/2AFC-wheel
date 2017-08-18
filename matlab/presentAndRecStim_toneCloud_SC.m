close all
clear all
clc
cd('C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\')
% set up the psychtoolbox
io.fs = 192e3;
fs = io.fs;
io.ref_Pa=20e-6;
io.VperPa=0.316;
InitializePsychSound(1);pause(1);
io.h = PsychPortAudio('Open', [], 3, 3, io.fs, [1 1]);

% make the stimulus
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170509_upperBoothRightSpkrInvFilt_3k-80k_fs192k.mat')
load('C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\recordedStimuli\testToneCloud_stimInfo.mat');
stimInfo.FILT = FILT_RIGHT;
stimInfo.fs = fs;


for ii=1:size(stimInfo.cloudRange,1)
    %%
    stimInfo.cloudType=ii;
    
    rightSpeaker = toneCloudGen(stimInfo);
    rightSpeaker = rightSpeaker/11; % sound card offset
    figure; spectrogram(rightSpeaker,200,20,1000,fs,'yaxis');
    stim = rightSpeaker;
    
    % Filter for removing low frequency noise
    [fb, fa] = butter(5, 2*300 / fs, 'high');
    
    % RECORD SOME BACKGROUND NOISE
    % preallocate recording buffer
    PsychPortAudio('GetAudioData', io.h, 3);
    disp('Acquiring 3s of background noise:');
    silence = zeros(1,3*io.fs);
    PsychPortAudio('FillBuffer', io.h, silence); % fill buffer
    t.play = PsychPortAudio('Start', io.h, 1);
    pause(5);
    [data, ~, ~, t.rec] = PsychPortAudio('GetAudioData', io.h); % get data from buffer
    data = data*11;
    b = filter(fb, fa, data) / io.ref_Pa / io.VperPa; % convert from Voltage to pressure
    b = b - mean(b);
    noise_ms = mean(b.^2);
    
    
    % RECORD THE STIMULUS
    % preallocate recording buffer
    PsychPortAudio('GetAudioData', io.h, (length(stim)/fs)+1); % set buffer length
    PsychPortAudio('FillBuffer', io.h, stim'); % fill buffer
    t.play = PsychPortAudio('Start', io.h, 1);
    % Grab the data in the buffer at the end
    pause(5);
    [data, ~, ~, t.rec] = PsychPortAudio('GetAudioData', io.h);
    data = data*11;
    data = data-mean(data);
    b = filter(fb, fa, data);
    
%     rms = sqrt(mean((b / io.ref_Pa / io.VperPa).^2)- noise_ms);
%     toneDB = real(20*log10(rms));
    
    [P,f] = pwelch((b/ io.ref_Pa / io.VperPa), 1024, 120, [], fs, 'onesided');
    dB = 10*log10(P);
%     plot(f,dB,'r');
    disp(['Total volume ' num2str(10*log10(mean(P)*(f(end)-f(1))))]);
    
    figure; spectrogram(b,200,20,1000,fs,'yaxis');
    title([num2str(10*log10(mean(P)*(f(end)-f(1)))) ' dB'])
   savefig(['C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\recordedStimuli\20170509_toneCloud_' num2str(stimInfo.cloudRange(ii,1)) '-' num2str(stimInfo.cloudRange(ii,2)) 'Hz.fig'])
end