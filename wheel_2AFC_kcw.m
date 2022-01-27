function wheel_2AFC_kcw(mouse,baseDir,project,parameterFile)

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
params.hexFile = [params.basePath filesep 'hexFiles' filesep 'wheel_interrupter_bit_noStimDetect.ino.hex'];
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
% fprintf(fid,'trial trialType response stillTime stimOnset stimOffset respTime correctionTrial correct\n');

% load arduino sketch
[~, cmdOut] = loadArduinoSketch(params.com,params.hexFile);
disp(cmdOut)

% setup serial port
p = setupSerial(params.com);
out = serialRead(p);

% send variables to the arduino
fprintf(p,'%f %f %f %f %f ',[params.rewardDuration params.timeoutDuration ...
    params.rotaryDebounce params.holdTimeMin params.holdTimeMax]);
WaitSecs(.5);
disp('parameters sent');

% initialize soundcard/whatever
[s,fs] = setupSoundOutput_ptb(params.fs,params.device,params.channel);

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

% serialRead(p);

% initialize some counts
trialNumber = 0;
newTrial = 1;
ttCounter = 1; % trialType counter
ctCounter = 0; % correction trial counter
flag = false;
resp = [];

% trial loop
abort = false;
abortFlag = false;
tt = [];
cnt = 1;
runningAverage = 20;
correctionTrial = 0;
while cnt < 2000
    out = serialRead(p);
    fprintf('%s\n',out);
    % write to file and to command window
    fprintf(fid,'\n%s',out);


    %     flag = check_keyboard;
    %     if flag
    %         out = 'USEREXIT';
    %     end
    %     %     x = p.BytesAvailable;
    %     %     if x
    %     out = serialRead(p)

    if contains(out,'TRIALON')
        % at the trial start:
        fprintf('CORRECTION TRIAL? %d\n', correctionTrial)
        % check for correction trial
        if newTrial==1 && correctionTrial==0 % make a new stimulus
            correctionTrial = 0;
            tt = trialType(ttCounter);
            cd(params.projPath);
            if exist('stimInfo','var')
                stimInfo.trialType = tt; %#ok<STRNU>
            end
            [stim, events] = eval(params.stimFunc); % Make the stimulus
            cd(params.basePath);
            rewardType = params.rewardContingency(tt);
            giveTO = params.timeOutContingency(tt);      % give time out?
            if rewardType==0
                rewardType = 99; % arduino randomly rewards
            end
            ttCounter = ttCounter+1; % increase trial type counter
        elseif newTrial== 0  % continue with same sound if not had too many correction trials
            correctionTrial = 1;
        end

        % reshuffle trial type if all trials are presented
        if ttCounter > length(trialType)
            trialType = trialType(randperm(length(trialType)));
            ttCounter = 1;
        end

        % add audio to buffer
        audio = [stim; events]' .* params.ampF;
        if size(audio,2)==2
            audio(:,3:4) = zeros(length(audio),2);
        elseif size(audio,2)==3
            audio(:,4) = zeros(length(audio),1);
        end
        %         queueOutput(s,audio,params.device);
        PsychPortAudio('FillBuffer',s,audio');

        % increment trial counter
        trialNumber = trialNumber + 1;
        fprintf('Trial %03d - %02d\n',trialNumber,tt);

        % work out audio duration
        audio_dur = (size(audio,1)/fs*1000);

        % send trial info to arduino and check that it was received
        fprintf(p,'%i %i %i',[rewardType, giveTO, audio_dur]);

    elseif contains(out,'WHEELSTILL')
        % present the audio
        %         startOutput(s,params.device);
        PsychPortAudio('Start',s,1);
%         disp('presenting audio')
%         plot(audio); drawnow;
        %         out = 'nothing';
        %         % wait for the sound onset
        %         soundOnset = serialRead(p);
        %         fprintf('\tOnset event: %i\n',str2double(soundOnset));
        %
        %         % wait for the 2nd event
        %         soundOffset = serialRead(p);
        %         fprintf('\tOffset event: %i\n',str2double(soundOffset));

    elseif contains(out,'TRIALOUTCOME')

        d = regexp(out,'\d');
        d = d(5:end);
        responseOutcome = str2double(out(d));

        %         x = p.BytesAvailable;
        %         if x
        %         % wait for the mouse response, determine RT and correct
        %         responseTime = serialRead(p);
        %         wheelDirection = serialRead(p);
        %         wheelDirection = str2double(wheelDirection)<0;
        %         responseOutcome = serialRead(p);
        %
        %         fprintf('\tTrial correct: %s\n',responseOutcome);
        %         fprintf('\tResponse time: %g\n', (str2double(responseTime)-str2double(soundOffset))/1e6);

        %         pause(.25)



        % determine next trialType
        if responseOutcome==1  % if correct or trialType requires no timeout
            newTrial = 1;
            ctCounter = 0;

            status = PsychPortAudio('GetStatus', s);
            while status.Active==1
                status = PsychPortAudio('GetStatus', s);
            end

            %             if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
            %                 if s.IsRunning
            %                     wait(s);
            %                 end
            %             end
            correctionTrial = 0;
            %             queueOutput(s,[click; click;click;click]'.*params.ampF,params.device);
            %             startOutput(s,params.device);
        elseif responseOutcome==99
            newTrial = 1;
            ctCounter = 0;
            correctionTrial = 0;
        elseif responseOutcome==0
            newTrial = 1;
            %             ctCounter = 0;
            correctionTrial = 0;
            if giveTO==1
                correctionTrial = 1;
                newTrial = 0;
                ctCounter = ctCounter + 1;
                %             nb3 = zeros(1,length(noiseBurstL));
                %                 if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')

                %                     if s.IsRunning
                %                         stop(s);
                %                     end
                %                 end
                %                 queueOutput(s,[noiseBurstL; noiseBurstR;ones(size(noiseBurstL));ones(size(noiseBurstL))]'.*params.ampF,params.device);
                %                 startOutput(s,params.device);
                status = PsychPortAudio('GetStatus', s);
                while status.Active==1
                    status = PsychPortAudio('GetStatus', s);
                end
                PsychPortAudio('FillBuffer',s,[noiseBurstL; noiseBurstR;ones(size(noiseBurstL));ones(size(noiseBurstL))].*params.ampF);
                PsychPortAudio('Start',s,1);
                %             if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
                %                 if s.IsRunning
                %                     wait(s);
                %                 end
                %             end

            end
        end
        if ctCounter>3
            newTrial = 1;
            ctCounter = 0;
            correctionTrial = 0;
        end
        % make sure we're ready for the next trial
        %         if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
        %             if s.IsRunning
        %                 stop(s);
        %             end
        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end
        %         end

    elseif contains(out,'NOAUDIOEVENT')

        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end

        newTrial = 0;


    elseif contains(out,'USEREXIT')
        delete(p)
        PsychPortAudio('Close', s);
        blank_hex = [params.basePath filesep 'hexFiles' filesep 'blank.ino.hex'];
        [~, cmdOut] = loadArduinoSketch(params.com,blank_hex);
        disp(cmdOut)
        %         disp(['Total trials: ' num2str(trialNumber)])
        %         fprintf('Percent correct: %02.2f\n',mean(resp(resp~=99)));
        delete(instrfindall)
        fclose(fid);
        cnt = 9999;
        


        %         % plot here
        %         smoothing = 30;
        %         resp(trialNumber) = str2double(responseOutcome);
        %         respTime(trialNumber) = (str2double(responseTime)-str2double(soundOffset))/1e6;
        %         if resp==99
        %             pl_resp(trialNumber) = NaN;
        %         else
        %             pl_resp(trialNumber) = resp(trialNumber);
        %         end
        %         updateGraph(trialNumber, pl_resp, respTime, smoothing);
        %
        %         % log the trial info
        %         %fprintf(fid,'trial trialType response stillTime stimOnset stimOffset respTime correctionTrial correct\n');
        %
        %         fprintf(fid,'%03d %i %i %g %g %g %g %i %i\n',trialNumber, tt, wheelDirection, ...
        %             str2double(mouseStillTime),str2double(soundOnset), str2double(soundOffset), ...
        %             str2double(responseTime),correctionTrial,str2double(responseOutcome));
        %
        %         % save trial type to a vector
        %         %         TrialType(trialNumber) = tt;
        %
        %         % make sure we're ready for the next trial
        %         if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
        %             if s.IsRunning
        %                 wait(s);
        %             end
        %         end
        %         end
    end
    %     end

    %     if flag
    %         delete(p)
    %         blank_hex = [params.basePath filesep 'hexFiles' filesep 'blank.ino.hex'];
    %         [~, cmdOut] = loadArduinoSketch(params.com,blank_hex);
    %         disp(cmdOut)
    %         disp(['Total trials: ' num2str(trialNumber)])
    %         fprintf('Percent correct: %02.2f\n',mean(resp(resp~=99)));
    %         delete(instrfindall)
    %         fclose(fid);
    %         delete(p);
    %
    %     end
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