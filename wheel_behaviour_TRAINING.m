% Behaviour task with wheel response
function wheel_behaviour_TRAINING
% run wheel_interruptor_test
clear all %#ok<CLALL>
delete(instrfindall)
close all
figure;
commandwindow
cd('C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask')
mouse = input('enter mouse number: ','s');

% load mouse's stim info
load(['E:\Data\' mouse '\' mouse '_TRAINING_stimInfo.mat'])

%Load corresponding Arduino sketch
hexPath = ['C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\hexFiles\' 'wheel_interrupter_training.ino.hex'];
[~, cmdOut] = loadArduinoSketch('COM5',hexPath);
disp(cmdOut);

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
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170109_upperBoothRightSpkrInvFilt_3k-80k_fs192k.mat')
stimInfo.FILT = FILT_RIGHT; % add filter to stimInfo


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
filename = [saveLoc mouse '_' datestr(now,'yyyy_mm_dd') '.txt'];
fid = fopen(filename,'a+');
ctCounter = 0; % correction trial counter
smoothing=30; % 30 is what it is in the behavioural analysis function

%% RUN LOOP

tt = [];
cnt = 0;
flag = 0;
while ~flag
    out = serialRead(s);
    
    if strcmp(out,'start')
        
        if newTrial==1 %   send new stimulus to sound card
            correctionTrial=0;
            trialType = randperm(2,1);    
            stimInfo.trialType = trialType;
            eval(sprintf('rightSpeaker = %s(%s)/11;',stimInfo.stimFunction(1:end-2),'stimInfo')); % make stim
        elseif newTrial== 0  %   continue with same sound if not had too many correction trials
            correctionTrial=1;
%         else
%             correctionTrial=0;
%             trialType = randperm(2,1); 
%             stimInfo.trialType = trialType;
%             eval(sprintf('rightSpeaker = %s(%s)/11;',stimInfo.stimFunction(1:end-2),'stimInfo')); % make stim
        end
        
        % Increase trial number
        trialNumber=trialNumber+1;
        disp(['Trial: ' num2str(trialNumber)]);
        
        % send trial type to arduino
        fprintf(s,'%s',trialType); % 1=left 2=right
        
        % Check it was received
        ttr = serialRead(s);
        
        %         fscanf(s,'%s')
        disp(['Trial type received: ' ttr])
        
    elseif strcmp(out,'mouseStill')
        % WAIT FOR MOUSE TO STOP MOVING WHEEL
        % wait for one second for the mouse to keep the wheel still...
        
        % Wait for arduino to send data
        mouseStillTime = serialRead(s);
        disp(['mouse still for 1.5 seconds: ' num2str(mouseStillTime)])
        
        % PRESENT THE SOUND AND RECEIVE SOUND OFFSET
        
        % PRESENT SOUND HERE
        %         leftSpeaker = zeros(size(rightSpeaker));
        
        outputSignal2 = [rightSpeaker', zeros(1,50)];
        outputSignal1 = zeros(size(outputSignal2));
        outputSignal3 = [ones(50,1)*3; zeros(length(outputSignal1)-100,1); ones(50,1)*3]';
        
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
        if trialNumber>smoothing+1
            %             figure(fh)
            subplot(1,2,1)
            plot([trialNumber-1 trialNumber],...
                [mean(resp(trialNumber-smoothing-1:trialNumber-1)) mean(resp(trialNumber-smoothing:trialNumber))],'.k-')
            xlabel('trial number')
            ylabel('P(correct)')
            hold on
            subplot(1,2,2)
            plot([trialNumber-1 trialNumber],...
                [mean(resp(trialNumber-smoothing-1:trialNumber-1)) mean(resp(trialNumber-smoothing:trialNumber))],'.k-')
            hold on
            plot([trialNumber-1 trialNumber],...
                [mean(respTime(trialNumber-smoothing-1:trialNumber-1)) mean(respTime(trialNumber-smoothing:trialNumber))],'.b')
            xlabel('trial number')
            ylabel('Response Time')
            
            drawnow
        end
        
        % Determine next trial type
        if str2double(responseOutcome)==1
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
        
        switch stimInfo.stimFunction
            case 'FM_stimGen.m'
                logWheelTrial_WL(fid,trialNumber, correctionTrial, stimInfo.modRates(trialType), str2double(mouseStillTime),...
                    str2double(soundOnset),str2double(soundOffset),str2double(responseTime),str2double(responseOutcome),wheelDirection)
            case 'toneCloudGen.m'
%                 tlog.tt = stimInfo.cloudRange(trialType,:);
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



