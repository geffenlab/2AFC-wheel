function freeMoving_2AFC_stage_03(mouse,baseDir,project,parameterFile)

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

% load parameters
run(params.paramFile);

% more paths
params.hexPath = [params.basePath filesep 'hexFiles' filesep params.hexFile];
params.dataPath = [params.basePath filesep 'mice' filesep mouse];
git = strfind(params.basePath,'GitHub');
params.githubPath = params.basePath(1:git+5);
params.sessID = datestr(now,'yyyymmdd_HHMM');

% load filters
[params, stimInfo] = loadFilters(params, stimInfo); %#ok<NODEF>

% open a file to write to
params.fn = [mouse '_' params.sessID '_' params.taskType];
fn = [params.dataPath filesep params.fn '.txt'];
fid = fopen(fn,'w');

% load arduino sketch
[~, cmdOut] = loadArduinoSketch(params.com,params.hexPath);
disp(cmdOut)

% setup serial port
p = setupSerial(params.com);
serialRead(p);

% send variables to the arduino
fprintf(p,'%f %f %f %d %f %f %f',[params.rewardDuration_L, params.rewardDuration_R, params.rewardDuration_C, params.timeoutDuration, ...
     params.holdTimeMin, params.holdTimeMax, params.centerDebounce]);
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
noiseBurst = randn(1,0.3*fs)/10;
noiseBurst = envelope_KCW(noiseBurst,1,fs);

% filter noise bursts and clicks
if isfield(params,'filt')
    noiseBurstL = conv(noiseBurst,params.filt,'same');
    noiseBurstR = noiseBurstL;
else
    noiseBurstL = conv(noiseBurst,params.filt_left,'same');
    noiseBurstR = conv(noiseBurst,params.filt_right,'same');
end

% initialize some counts
trialNumber = 0;
newTrial = 1;
ttCounter = 1; % trialType counter
ctCounter = 0; % correction trial counter
correctionTrial = 0;

% beh tracking
respTime_track = zeros(1000,1);
outcome_track = zeros(1000,1);
figure
hold all

% trial loop
tt = [];
cnt = 1;

while cnt < 2000
    out = serialRead(p);
    
    % write to file and to command window
    fprintf('%s\n',out);
    fprintf(fid,'\n%s',out);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(out,'TRIALON')
        % at the trial start:
        trialNumber = trialNumber + 1;
        % check for correction trial
        if newTrial==1 && correctionTrial==0                % make a new stimulus
            correctionTrial = 0;
            tt = trialType(ttCounter);
            cd(params.projPath);
            if exist('stimInfo','var')
                stimInfo.trialType = tt; 
            end
            [stim, events] = eval(params.stimFunc);         % Make the stimulus
            cd(params.basePath);
            rewardType = params.rewardContingency(tt);
            giveTO = params.timeOutContingency(tt);         % give time out?
            if rewardType==0
                rewardType = 99;                            % arduino randomly rewards
            end
            ttCounter = ttCounter+1;                        % increase trial type counter
            fprintf(fid,'\n%s',sprintf('%04dCORRECTIONTRIAL%d',trialNumber,0));
            fprintf('\n%s',sprintf('\n%04dCORRECTIONTRIAL%d\n',trialNumber,0));

        elseif newTrial== 0                                 % continue with same sound if not had too many correction trials
            correctionTrial = 1;
            fprintf(fid,'\n%s',sprintf('%04dCORRECTIONTRIAL%d',trialNumber,1));
            fprintf('\n%s',sprintf('%04dCORRECTIONTRIAL%d\n',trialNumber,1));
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
        
        % work out audio duration
%         audio_dur = (size(audio,1)/fs*1000);
       % audio_dur = stimInfo.adaptor_dur*1000;
        
        % Add zeros to the stim to loop it
        audio = [audio; zeros(fs*1,size(audio,2))];
        PsychPortAudio('FillBuffer',s,audio');

        % increment trial counter
        fprintf('Trial %03d - %02d\n',trialNumber,tt);

        % send trial info to arduino
         fprintf(p,'%i %i %i',[rewardType, giveTO, params.waitTime]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif contains(out,'ENDHOLDTIME')
        % present the audio
        reps = 0; % plays the buffer on repeat
        PsychPortAudio('Start',s,reps);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif contains(out,'STIMOFF')
        d = regexp(out,'\d');
        d = d(5:end);
        stimOff = str2double(out(d));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    elseif contains(out,'RESPTIME')
        d = regexp(out,'\d');
        d = d(5:end);
        respTime = str2double(out(d));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    elseif contains(out,'TRIALOUTCOME')
         PsychPortAudio('Stop',s,2); % the 2 means stop asap (http://psychtoolbox.org/docs/PsychPortAudio-Stop)
        
        % extract outcome
        d = regexp(out,'\d');
        d = d(5:end);
        responseOutcome = str2double(out(d));
        
        outcome_track(trialNumber) = responseOutcome;
%         respTime_track(trialNumber) = (respTime-stimOff)/1000000;
        updateGraph(trialNumber,correctionTrial,outcome_track,respTime_track(trialNumber),15)

        % determine next trialType
        if responseOutcome==1  % if correct or trialType requires no timeout
            newTrial = 1;
            ctCounter = 0;

            status = PsychPortAudio('GetStatus', s);
            while status.Active==1
                status = PsychPortAudio('GetStatus', s);
            end
            correctionTrial = 0;
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
                status = PsychPortAudio('GetStatus', s);
                while status.Active==1
                    status = PsychPortAudio('GetStatus', s);
                end
                PsychPortAudio('FillBuffer',s,[noiseBurstL; noiseBurstR;ones(size(noiseBurstL));ones(size(noiseBurstL))].*params.ampF);
                PsychPortAudio('Start',s,1);
            end
        end
        if ctCounter>3
            newTrial = 1;
            ctCounter = 0;
            correctionTrial = 0;
        end
        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end
        %         end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    elseif any(contains(out,{'NOAUDIOONEVENT','NOAUDIOOFFEVENT'}))

        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end

        newTrial = 0;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   elseif contains(out,'EARLYDEP')
        PsychPortAudio('Stop',s,2); % the 2 means stop asap (http://psychtoolbox.org/docs/PsychPortAudio-Stop)
        newTrial = 0;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   elseif contains(out,'USEREXIT')
        delete(p)
        PsychPortAudio('Close', s);
        blank_hex = [params.basePath filesep 'hexFiles' filesep 'blank.ino.hex'];
        [~, cmdOut] = loadArduinoSketch(params.com,blank_hex);
        disp(cmdOut)
        delete(instrfindall)
        fclose(fid);
        cnt = 9999;
    end
end

if strcmp(params.device,'NIDAQ')
    stop(s);
end
print_beh_session_stats(fn)
clear all %#ok<CLALL>
disp('Done');
fclose('all');



function y = envelope_KCW(s,t,fs)

if size(s,1)==1
    s = s';
end

ns = round(t/1000*fs);
r = (sin(linspace(-pi/2,pi/2,ns))/2)+0.5;
r = [r ones(1,length(s) - (ns*2)) fliplr(r)]';
y = s .* r;