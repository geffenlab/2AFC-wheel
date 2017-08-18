% Behaviour task with wheel response
function wheel_behaviour_TESTINGgui(mouse,project,parameterFile)
% run wheel_interruptor_test
% clear all %#ok<CLALL>
delete(instrfindall)
close all
figure;
commandwindow
cd('C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask')
% mouse = input('enter mouse number: ','s');
% mouse = 'test';
% load mouse's stim info
load(['E:\Data\projects\' project '\' parameterFile])

% add folder paths
addpath 'C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\'

%Load corresponding Arduino sketch
hexPath = ['C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\hexFiles\' 'wheel_interrupter_test.ino.hex'];
[~, cmdOut] = loadArduinoSketch('COM5',hexPath);
cmdOut

% Initialise psychtoolbox
InitializePsychSound(1);
fs=192000;
sc = PsychPortAudio('Open', [], 1, 3, fs, 3); %'Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels]
% Channel 1 is left speaker, 2 is right speaker and 3 is events
status = PsychPortAudio('GetStatus', sc);
fs = status.SampleRate; % check sample rate
stimInfo.fs = fs;
s=setupSerial('COM5'); % windows

% Load filters
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170109_upperBoothLeftSpkrInvFilt_3k-80k_fs192k.mat')
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170509_upperBoothRightSpkrInvFilt_3k-80k_fs192k.mat')
stimInfo.FILT = FILT_RIGHT; % add filter to stimInfo

% Make stimuli
trialTypeSelector = [];
tpc = stimInfo.trialPC;
tt = [];
for ii = 1:length(tpc)
    tt = [tt,ones(1,tpc(ii))*ii]; %#ok<AGROW>
end
tt = tt(randperm(length(tt)));
ttCounter = 1;


% Make 'incorrect' noise burst
noiseBurst = rand(1,0.3*fs);
noiseBurst = envelopeKCW(noiseBurst,5,fs);
noiseBurstL = conv(noiseBurst,FILT_LEFT,'same');
noiseBurstL = noiseBurstL/11;
noiseBurstR = conv(noiseBurst,FILT_RIGHT,'same');
noiseBurstR = noiseBurstR/11;

% Initialise variables:
trialNumber = 0;
newTrial = 1;
KbName('UnifyKeyNames');

saveLoc = ['E:\Data\' mouse '\'];
filename = [saveLoc mouse '_' datestr(now,'yyyy_mm_dd') '_' parameterFile(1:end-4) '.txt'];
fid = fopen(filename,'a+');
ctCounter = 0; % correction trial counter
seed = datenum(datestr(now,'yyyy_mm_dd'),'yyyy_mm_dd');
rng(seed);
smoothing=30; % 30 is what it is in the behavioural analysis function

%% RUN LOOP

cnt = 0;
flag = 0;
while ~flag
    out = serialRead(s);
       
    if strcmp(out,'start')
              
        if newTrial==1 %   send new stimulus to sound card
            correctionTrial=0;
            stimInfo.trialType = tt(ttCounter);
            rightSpeaker = toneCloudGen(stimInfo)/11;
            rewardType =  stimInfo.rewardContingency(tt(ttCounter));
            giveTO = stimInfo.timeouts(tt(ttCounter)); % give time out?
            if rewardType==0
                rewardType = 99; % arduino randomly rewards
            end
            ttCounter = ttCounter+1;
        elseif newTrial== 0  %   continue with same sound if not had too many correction trials
            correctionTrial=1;
        end
        
        % Reshuffle if all trials presented
        if ttCounter>length(tt)
            tt = tt(randperm(length(tt)));
            ttCounter=1;
        end
        
        % Increase trial number
        trialNumber=trialNumber+1;
        disp(['Trial: ' num2str(trialNumber)]);
        
        % send trial type to arduino
        fprintf(s,'%i\n%i',[rewardType,giveTO]); % 1=left 2=right
        
        % Check it was received
        ttr = serialRead(s)
        
        %         fscanf(s,'%s')
        disp(['Trial type: ' num2str(stimInfo.trialType)])
        
    elseif strcmp(out,'mouseStill')
        % WAIT FOR MOUSE TO STOP MOVING WHEEL
        % wait for one second for the mouse to keep the wheel still...
        
        % Wait for arduino to send data
        mouseStillTime = serialRead(s);
        disp(['mouse still for 1.5 seconds: ' num2str(mouseStillTime)])
        
        % PRESENT THE SOUND AND RECEIVE SOUND OFFSET
        
        % PRESENT SOUND HERE       
%         leftSpeaker = zeros(size(rightSpeaker));
%         outputSignal1 = [leftSpeaker(trialModRate==stimInfo.modRates,:), zeros(1,50)];      % left speaker 
        outputSignal2 = [rightSpeaker; zeros(50,1)]'; % right speaker
        outputSignal1 = zeros(size(outputSignal2));
        outputSignal3 = [ones(50,1)*3; zeros(length(outputSignal1)-100,1); ones(50,1)*3]'; % events to arduino

        PsychPortAudio('FillBuffer', sc, [outputSignal1;outputSignal2;outputSignal3]);
        
        
        % Start presentation
        t1 = PsychPortAudio('Start', sc, 1); % 'Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0]
        
        % Wait for arduino to send info
        soundOnset = serialRead(s);
        disp(['sound onset received: ' num2str(soundOnset)])
        
        soundOffset = serialRead(s);
        disp(['sound offset received: ' num2str(soundOffset)])
%         disp(['Difference: ' num2str(soundOffset-soundOnset)])
        %         fscanf(s,'%s')
        
        % RECEIVE INPUT FROM ARDUINO WITH RESPONSE TIME AND IF TRIAL CORRECT OR NOT
    elseif strcmp(out,'waitForResp')
        responseTime = serialRead(s);
        wheelDirection = serialRead(s);
        wheelDirection = str2double(wheelDirection)<0;
        responseOutcome = serialRead(s);
        disp(['Response time = ' num2str((str2double(responseTime)-str2double(soundOffset))/1e6) ' s']);
        disp(['Correct? ' num2str(responseOutcome)]);
        
        % plot progress
        resp(trialNumber)=str2double(responseOutcome);
        respTime(trialNumber) = (str2double(responseTime)-str2double(soundOffset))/1e6;
        updateGraph(trialNumber, resp, respTime, smoothing);
        
         % Determine next trial type
        if str2double(responseOutcome)==1 || giveTO==0 % if correct or trialType requires no timeout
            newTrial = 1;
            ctCounter = 0; 
        elseif str2double(responseOutcome)==99
            newTrial = 1;
            ctCounter = 0; 
        else
            newTrial = 0;
            ctCounter=ctCounter+1;
            nb3 = zeros(1,length(noiseBurstL));
            PsychPortAudio('FillBuffer', sc, [noiseBurstL;noiseBurstR;nb3]);
            t1 = PsychPortAudio('Start', sc, 1);
            if ctCounter>3
                newTrial = 1;
            end
        end
        
%         resp(trialNumber)
        
        switch stimInfo.stimFunction
            case 'FM_stimGen.m'
                logWheelTrial_WL(fid,trialNumber, correctionTrial, stimInfo.modRates(trialType), str2double(mouseStillTime),...
                    str2double(soundOnset),str2double(soundOffset),str2double(responseTime),str2double(responseOutcome),wheelDirection)
            case 'toneCloudGen.m'
                
                 logWheelTrial_WL(fid,trialNumber, correctionTrial, stimInfo.trialType, str2double(mouseStillTime),...
                    str2double(soundOnset),str2double(soundOffset),str2double(responseTime),str2double(responseOutcome),wheelDirection)
                
        end
    end
    
    % Exit statement
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE') || cnt > 10
            flag = 1;
        end
    end
end

delete(instrfindall)
fclose(fid)
behSessionInfo(filename);

clear all



