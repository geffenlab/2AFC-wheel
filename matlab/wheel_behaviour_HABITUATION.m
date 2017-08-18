% Behaviour task with wheel response
function wheel_behaviour_HABITUATION
% run wheel_interruptor_test
clear all %#ok<CLALL>
delete(instrfindall)
close all
% figure;
commandwindow
cd('C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask')

%Load corresponding Arduino sketch
hexPath = ['C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\hexFiles\' 'wheel_habituation.ino.hex'];
[~, cmdOut] = loadArduinoSketch('COM5',hexPath);
disp(cmdOut);

InitializePsychSound(1);
fs=192000;
sc = PsychPortAudio('Open', [], 1, 3, fs, 3); %'Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels]
% Channel 1 is left speaker, 2 is right speaker and 3 is events
status = PsychPortAudio('GetStatus', sc);
fs = status.SampleRate; % check sample rate
s=setupSerial('COM5'); % windows

% Load filters
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170109_upperBoothLeftSpkrInvFilt_3k-80k_fs192k.mat')
load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170109_upperBoothRightSpkrInvFilt_3k-80k_fs192k.mat')

turnGood = tone(8000,3/2*pi,0.1,fs);
turnGood = envelopeKCW(turnGood,5,fs);
turnGood = conv(turnGood,FILT_RIGHT,'same');
turnGood = turnGood/11;

% Initialise variables:
trialNumber = 0;
KbName('UnifyKeyNames');

% saveLoc = 'C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\data\';
% filename = [saveLoc mouse '_' datestr(now,'yyyy_mm_dd') '.txt'];
% fid = fopen(filename,'a+');
% ctCounter = 0; % correction trial counter
% smoothing=30; % 30 is what it is in the behavioural analysis function

%% RUN LOOP

tt = [];
cnt = 0;
flag = 0;
out='blah';
while ~strcmp(out,'start')
    out = serialRead(s);
end
while ~flag
    
    % Wait for arduino to send data
    wheelTurn = serialRead(s);
    disp(['wheel turn time: ' num2str(wheelTurn)])
    rotPos = serialRead(s);
    disp(['rotary position: ' num2str(rotPos)])
    trialNo = serialRead(s);
    disp(['trial number: ' num2str(trialNo)])
    
    % PRESENT THE SOUND AND RECEIVE SOUND OFFSET
    
    % PRESENT SOUND HERE
    leftSpeaker = zeros(size(turnGood));
    outputSignal1 = leftSpeaker;
    outputSignal2 = turnGood;
    outputSignal3 = leftSpeaker;
    
    PsychPortAudio('FillBuffer', sc, [outputSignal1;outputSignal2;outputSignal3]);    
    
    % Start presentation
    t1 = PsychPortAudio('Start', sc, 1); % 'Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0]
       
    % Exit statement
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE') || cnt > 10
            flag = 1;
        end
    end
end




