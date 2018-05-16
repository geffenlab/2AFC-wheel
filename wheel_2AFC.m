function wheel_2AFC(mouse,baseDir,project,parameterFile)

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
params.hexFile = [params.basePath filesep 'hexFiles' filesep 'wheel_interrupter_test3.ino.hex'];
params.dataPath = [params.projPath filesep mouse];
params.sessID = datestr(now,'YYMMDD');

% load parameters
if contains(parameterFile,'.txt')
    % load text file
    [params fs] = loadParameters(params.paramFile);
elseif contains(parameterFile,'.mat')
    % load mat file
    load(params.paramFile);
elseif contains(parameterFile,'.m')
    % run script
    run(params.paramFile);
end

% open a file to write to
params.fn = [mouse '_' params.sessID '_' params.taskType];
fn = [params.dataPath filesep params.fn '.txt'];
fid = fopen(fn,'w');
fprintf(fid,'trial trialType response stillTime stimOnset stimOffset respTime correctionTrial correct\n');

% load arduino sketch
[~, cmdOut] = loadArduinoSketch(params.com,params.hexFile);
cmdOut

% setup serial port
p = setupSerial(params.com);

% send variables to the arduino
fprintf(p,'%i %i %i ',[params.rewardDuration params.timeoutDuration ...
    params.rotaryDebounce]);
WaitSecs(.5);
disp(serialRead(p));

% initialize soundcard/whatever
[s,fs] = setupSoundOutput(params.fs,params.device,params.channel);

%% Start the task
% setup the trial order
tr = params.trialTypeRatios;
trialType = [];
for i = 1:length(tr)
    trialType = [trialType,ones(1,tr(i))*i];
end
trialType = trialType(randperm(length(trialType)));

% make a noise burst for punishments
noiseBurst = rand(1,0.3*fs)/10;
noiseBurst = envelope_CA(noiseBurst,.005,fs);
noiseBurstL = conv(noiseBurst,params.filt,'same');

% make a click for rewards
[b,a] = butter(5,[5000/fs 50000/fs]);
click = rand(1,0.025*fs)/30;
click = envelope_CA(click, 0.005,fs);
click = conv(click,params.filt,'same');


% initialize some counts
trialNumber = 0;
newTrial = 1;
ttCounter = 1;
ctCounter = 0; % correction trial counter
flag = false;

while ~flag
    out = serialRead(p);
    
    if strcmp(out,'start')
        % at the trial start:
        
        % check for correction trial
        if newTrial==1 % make a new stimulus
            correctionTrial=0;
            tt = trialType(ttCounter);
            cd(params.projPath);
            if exist('stimInfo','var')
                stimInfo.trialType = tt;
            end
            [stim events] = eval(params.stimFunc);
            cd(params.basePath);
            rewardType =  params.rewardContingency(tt);
            giveTO = params.timeOutContingency(tt); % give time out?
            if rewardType==0
                rewardType = 99; % arduino randomly rewards
            end
            ttCounter = ttCounter+1;
        elseif newTrial== 0  %   continue with same sound if not had too many correction trials
            correctionTrial=1;
        end
        
        % reshuffle trial type if all trials are presented
        if ttCounter > length(trialType)
            trialType = trialType(randperm(length(trialType)));
            ttCounter = 1;
        end
        
        % add audio to buffer
        sound = [stim; events]' .* params.ampF;
        queueOutput(s,sound,params.device);
        
        % increment trial counter
        trialNumber = trialNumber + 1;
        fprintf('Trial %03d - %02d\n',trialNumber,tt);
        
        % send trial info to arduino and check that it was received
        fprintf(p,'%i\n%i',[rewardType,giveTO]);
        ttr = serialRead(p);
        
    elseif strcmp(out,'mouseStill')
        % once the mouse stopped moving the wheel:
        
        % wait for arduino to send data
        mouseStillTime = serialRead(p);
        fprintf('\tMouse still for 1.5s: %i\n',str2double(mouseStillTime));
        
        % present the audio
        startOutput(s,params.device);
        
        % wait for the sound onset
        soundOnset = serialRead(p);
        fprintf('\tOnset event: %i\n',str2double(soundOnset));
        
        % wait for the 2nd event
        soundOffset = serialRead(p);
        fprintf('\tOffset event: %i\n',str2double(soundOffset));
        
    elseif strcmp(out,'waitForResp')
        % wait for the mouse response, determine RT and correct
        responseTime = serialRead(p);
        wheelDirection = serialRead(p);
        wheelDirection = str2double(wheelDirection)<0;
        responseOutcome = serialRead(p);
        
        fprintf('\tTrial correct: %g\n',responseOutcome);
        fprintf('\tRT: %g\n', ...
            (str2double(responseTime)-str2double(soundOffset))/1e6);
        
%         pause(.25)
                
      
        
        % determine next trialType
        if str2double(responseOutcome)==1 || giveTO==0 % if correct or trialType requires no timeout
            newTrial = 1;
            ctCounter = 0;
             if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
                if s.IsRunning
                    wait(s);
                end
            end
            queueOutput(s,[click; click]'.*params.ampF,params.device);
            startOutput(s,params.device);
        elseif str2double(responseOutcome)==99
            newTrial = 1;
            ctCounter = 0;
        else
            newTrial = 0;
            ctCounter=ctCounter+1;
            nb3 = zeros(1,length(noiseBurstL));
            if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
                if s.IsRunning
                    wait(s);
                end
            end
            queueOutput(s,[noiseBurstL; noiseBurstL]'.*params.ampF,params.device);
            startOutput(s,params.device);
            WaitSecs(.3);
            if ctCounter>3
                newTrial = 1;
            end
        end
        
          % plot here
        smoothing = 30;
        resp(trialNumber) = str2double(responseOutcome);
        respTime(trialNumber) = (str2double(responseTime)-str2double(soundOffset))/1e6;
        updateGraph(trialNumber, resp, respTime, smoothing);
        
        % log the trial info
        %fprintf(fid,'trial trialType response stillTime stimOnset stimOffset respTime correctionTrial correct\n');
        
        fprintf(fid,'%03d %i %i %g %g %g %g %i %i\n',trialNumber, tt, wheelDirection, ...
            str2double(mouseStillTime),str2double(soundOnset), str2double(soundOffset), ...
            str2double(responseTime),correctionTrial,str2double(responseOutcome));
        
        % save trial type to a vector
%         TrialType(trialNumber) = tt;
        
        % make sure we're ready for the next trial
        if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
            if s.IsRunning
                wait(s);
            end
        end
        
        
        % Exit statement
        [~,~,keyCode] = KbCheck;
        if sum(keyCode) == 1
            if strcmp(KbName(keyCode),'ESCAPE')
                flag = true;
            end
        end
    end
end

fprintf('\n\nPercent correct: %02.2f\n',mean(resp(resp~=99)));
delete(instrfindall)
fclose(fid)
%behSessionInfo(fn);
if strcmp(params.device,'NIDAQ')
    stop(s);
end
clear all









function y = envelope_CA(s,t,fs)

ns = round(t*fs);
r = sin(linspace(0,pi/2,ns));
r = [r ones(1,length(s) - (ns*2)) fliplr(r)];

y = s .* r;