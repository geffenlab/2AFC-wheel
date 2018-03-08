% Behaviour task with wheel response
function wheel_2AFC_habituation(mouse,baseDir,project,parameterFile)
delete(instrfindall)
close all
KbName('UnifyKeyNames');
commandwindow

%% SETUP
% paths
cd(baseDir);
params.basePath = pwd;
params.projPath = [params.basePath filesep 'projects' filesep project];
params.paramFile = [params.projPath filesep parameterFile];
params.hexFile = [params.basePath filesep 'hexFiles' filesep 'wheel_habituation3.ino.hex'];
params.dataPath = [params.projPath filesep mouse];
params.sessID = datestr(now,'YYMMDD');

% load parameters
if contains(parameterFile,'.txt')
    % load text file
    [params fs] = loadParameters(paramFile);
elseif contains(parameterFile,'.mat')
    % load mat file
    load(paramFile);
elseif contains(parameterFile,'.m')
    % run script
    run(params.paramFile);
end

% load arduino sketch
[~, cmdOut] = loadArduinoSketch(params.com,params.hexFile);
cmdOut

% setup serial port
p = setupSerial(params.com);

% send variables to the arduino
fprintf(p,'%i %i %i ',[params.rewardDuration params.holdDuration ...
    params.rotaryDebounce]);
WaitSecs(.5);
disp(serialRead(p));

% initialize soundcard/whatever
[s,fs] = setupSoundOutput(params.fs,params.device,params.channel);

turnGood = tone(8000,3/2*pi,0.1,params.fs)/10;
turnGood = envelope_CA(turnGood,.005,params.fs);
turnGood = conv(turnGood,params.filt,'same');
turnGood = [turnGood; turnGood];
turnGood = zeros(size(turnGood));

% initialize audio buffer
queueOutput(s,turnGood'.*params.ampF,params.device);

% Initialise variables:
trialNumber = 0;
KbName('UnifyKeyNames');

%% RUN LOOP

tt = [];
cnt = 0;
flag = 0;
out='blah';
while ~strcmp(out,'start')
    out = serialRead(p);
end
while ~flag
    disp('Waiting for wheel turn...');
    
    % Wait for arduino to send data
    wheelTurn = serialRead(p);
    disp(['wheel turn time: ' num2str(wheelTurn)])
    rotPos = serialRead(p);
    disp(['rotary position: ' num2str(rotPos)])
    trialNo = serialRead(p);
    disp(['trial number: ' num2str(trialNo)])
    
    % queue and present sound
    tic
    startOutput(s,params.device);
    toc
    
    % make sure we're ready for the next trial
    if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
        WaitSecs(.2);
        if s.IsRunning
            stop(s);
        end
    end
    
    % queue output for next trial
    queueOutput(s,turnGood'.*params.ampF,params.device);
    
    % Exit statement
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE')
            flag = 1;
        end
    end
end

delete(instrfindall)
delete(p);
disp('Done');




function y = envelope_CA(s,t,fs)

ns = round(t*fs);
r = sin(linspace(0,pi/2,ns));
r = [r ones(1,length(s) - (ns*2)) fliplr(r)];

y = s .* r;


function x=tone(f,ph,dur,sf)
% x=tone(f,ph,dur,sf); returns a sine tone of freq f Hz, phase ph rad, duration dur sec at sample rate sf Hz

npts=dur*sf;
inc=2*pi*f/sf;
x=(0:npts-1)*inc+ph;
x=cos(x);