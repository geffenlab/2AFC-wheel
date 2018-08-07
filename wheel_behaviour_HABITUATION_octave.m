% Behaviour task with wheel response
function wheel_behaviour_HABITUATION_octave
% run wheel_interruptor_test
pkg load instrument-control
clear all %#ok<CLALL>
% delete(instrfindall)
close all
% figure;
% commandwindow
cd('C:\Users\behaviour7\Documents\GitHub\2AFC-wheel')

InitializePsychSound(1);
fs=192000;
sc = PsychPortAudio('Open', [], 1, 3, fs, 3); %'Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels]
% Channel 1 is left speaker, 2 is right speaker and 3 is events
status = PsychPortAudio('GetStatus', sc);
fs = status.SampleRate; % check sample rate

% Load filters
load('C:\Users\behaviour7\Documents\GitHub\filters\170615_booth1_3k-80k_fs192k.mat')
load('C:\Users\behaviour7\Documents\GitHub\filters\170615_booth1_3k-80k_fs192k.mat')

turnGood = tone(8000,3/2*pi,0.1,fs);
% turnGood = envelopeKCW(turnGood,5,fs);
turnGood = conv(turnGood,FILT,'same');
turnGood = turnGood/11;

% Initialise variables:
trialNumber = 0;
KbName('UnifyKeyNames');

% saveLoc = 'C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\data\';
% filename = [saveLoc mouse '_' datestr(now,'yyyy_mm_dd') '.txt'];
% fid = fopen(filename,'a+');
% ctCounter = 0; % correction trial counter
% smoothing=30; % 30 is what it is in the behavioural analysis function

%% Load corresponding Arduino sketch
hexPath = ['C:\Users\behaviour7\Documents\GitHub\2AFC-wheel\hexFiles\' 'wheel_habituation.ino.hex'];
[~, cmdOut] = loadArduinoSketch('COM3',hexPath);
disp(cmdOut);
serialPort = 'COM3';
s = serial(serialPort,9600);
set(s,'TimeOut',10);

a = 'b';
%while ~strcmp(a,'arduino')
a = ReadToTermination(s);
disp(a)
%end

srl_write(s,'a');

% pause(3);
% disp(ReadToTermination(s1))
%% RUN LOOP

tt = [];
cnt = 0;
flag = 0;
out='blah';
pause(1);
%while ~strcmp(out,'start')
    out = ReadToTermination(s);
    disp(out)
%end

while ~flag
    
    % Wait for arduino to send data
    wheelTurn = ReadToTermination(s);
    disp(['wheel turn time: ' (wheelTurn)])
    rotPos = ReadToTermination(s);
    disp(['rotary position: ' (rotPos)])
    trialNo = ReadToTermination(s);
    disp(['trial number: ' (trialNo)])
%    flag = true;
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
    keyCode = kbhit(1);
    if keyCode == 'x'
      flag = 1;
    end
    
end

