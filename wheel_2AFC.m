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
params.dataPath = [params.basePath filesep 'mice' filesep mouse];
git = strfind(params.basePath,'GitHub');
params.githubPath = params.basePath(1:git+5);
params.sessID = datestr(now,'yyyymmdd_HHMM');

% load parameters
if contains(parameterFile,'.txt')
    % load text file
    [params, ~] = loadParameters(params.paramFile);
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
disp(cmdOut)

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
    trialType = [trialType,ones(1,tr(i))*i]; %#ok<*AGROW>
end
trialType = trialType(randperm(length(trialType)));

% make a noise burst for punishments
noiseBurst = rand(1,0.3*fs)/10;
noiseBurst = envelope_CA(noiseBurst,.005,fs);

% make a click for rewards
% [b,a] = butter(5,[5000/fs 50000/fs]);
% click = rand(1,0.025*fs)/30;
% click = envelope_CA(click, 0.005,fs);

% filter noise bursts and clicks
if isfield(params,'filt')
    noiseBurstL = conv(noiseBurst,params.filt,'same');
    noiseBurstR = noiseBurstL;
    %     click = conv(click,params.filt,'same');
else
    noiseBurstL = conv(noiseBurst,params.filt_left,'same');
    noiseBurstR = conv(noiseBurst,params.filt_right,'same');
    %     click = conv(click,params.filt_left,'same');
end

% initialize some counts
trialNumber = 0;
newTrial = 1;
ttCounter = 1;
ctCounter = 0; % correction trial counter
flag = false;
resp = [];

while ~flag

    flag = check_keyboard;
    %     x = p.BytesAvailable;
    %     if x
    out = serialRead(p)
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
            [stim, events] = eval(params.stimFunc);
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
        if size(sound,2)==2
            sound(:,3:4) = zeros(length(sound),2);
        elseif size(sound,2)==3
            sound(:,4) = zeros(length(sound),1);
        end
        queueOutput(s,sound,params.device);

        % increment trial counter
        trialNumber = trialNumber + 1;
        fprintf('Trial %03d - %02d\n',trialNumber,tt);

        % send trial info to arduino and check that it was received
        fprintf(p,'%i\n%i',[rewardType,giveTO]);
        ttr = serialRead(p);
        out = 'nothing';
%         fprintf('ttr %s',ttr)

    elseif strcmp(out,'mouseStill')
        % once the mouse stopped moving the wheel:

        % wait for arduino to send data
        mouseStillTime = serialRead(p);
        fprintf('\tMouse still for 1.5s: %i\n',str2double(mouseStillTime));
        pause(0.1)

        % present the audio
        startOutput(s,params.device);
        pause(0.1)

        % wait for the sound onset
        soundOnset = serialRead(p);
        fprintf('\tOnset event: %i\n',str2double(soundOnset));

        % wait for the 2nd event
        soundOffset = serialRead(p);
        fprintf('\tOffset event: %i\n',str2double(soundOffset));

    elseif strcmp(out,'waitForResp')
        
%         x = p.BytesAvailable;
%         if x
        % wait for the mouse response, determine RT and correct
        responseTime = serialRead(p);
        wheelDirection = serialRead(p);
        wheelDirection = str2double(wheelDirection)<0;
        responseOutcome = serialRead(p);

        fprintf('\tTrial correct: %s\n',responseOutcome);
        fprintf('\tResponse time: %g\n', (str2double(responseTime)-str2double(soundOffset))/1e6);

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
            %             queueOutput(s,[click; click;click;click]'.*params.ampF,params.device);
            %             startOutput(s,params.device);
        elseif str2double(responseOutcome)==99
            newTrial = 1;
            ctCounter = 0;
        else
            newTrial = 0;
            ctCounter=ctCounter+1;
            %             nb3 = zeros(1,length(noiseBurstL));
            if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
                if s.IsRunning
                    wait(s);
                end
            end
            queueOutput(s,[noiseBurstL; noiseBurstR;zeros(size(noiseBurstL));zeros(size(noiseBurstL))]'.*params.ampF,params.device);
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
        if resp==99
            pl_resp(trialNumber) = NaN;
        else
            pl_resp(trialNumber) = resp(trialNumber);
        end
        updateGraph(trialNumber, pl_resp, respTime, smoothing);

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
        %         end
    end
    %     end

    if flag
        delete(p)
        blank_hex = [params.basePath filesep 'hexFiles' filesep 'blank.ino.hex'];
        [~, cmdOut] = loadArduinoSketch(params.com,blank_hex);
        disp(cmdOut)
        disp(['Total trials: ' num2str(trialNumber)])
        fprintf('Percent correct: %02.2f\n',mean(resp(resp~=99)));
        delete(instrfindall)
        fclose(fid);
        delete(p);

    end
end

if strcmp(params.device,'NIDAQ')
    stop(s);
end
clear all %#ok<CLALL>
disp('Done');


function flag = check_keyboard
% Exit statement
[~,~,keyCode] = KbCheck;
flag = false;
if sum(keyCode) == 1
    if strcmp(KbName(keyCode),'ESCAPE')
        flag = true;
    end
else
    flag = false;
end


function y = envelope_CA(s,t,fs)

ns = round(t*fs);
r = sin(linspace(0,pi/2,ns));
r = [r ones(1,length(s) - (ns*2)) fliplr(r)];

y = s .* r;