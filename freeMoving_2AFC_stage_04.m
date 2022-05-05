function freeMoving_2AFC_stage_04(mouse,baseDir,project,parameterFile)

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
params.hexFile = [params.basePath filesep 'hexFiles' filesep '2afc_freeMoving_photoDetectors.ino.hex'];
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
serialRead(p);

% send variables to the arduino
fprintf(p,'%f %d %f %f',[params.rewardDuration params.timeoutDuration ...
     params.holdTimeMin params.holdTimeMax]);
WaitSecs(.5);
disp('parameters sent');

% initialize soundcard/whatever
[s,fs] = setupSoundOutput_ptb(params.fs,params.device,params.channel);

%% Start the task
% setup the trial order
tr = params.trialTypeRatios;
trialType = [];
for i = 1:length(tr)
    trialType = [trialType,ones(1,tr(i))*i];                %#ok<*AGROW>
end
trialType = trialType(randperm(length(trialType)));

% make a noise burst for punishments
noiseBurst = rand(1,0.3*fs)/10;
noiseBurst = envelope_KCW(noiseBurst,.005,fs);


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
ttCounter = 1;                                              % trialType counter
ctCounter = 0;                                              % correction trial counter

% beh tracking
respTime_track = zeros(1000,1);
outcome_track = zeros(1000,1);
figure
hold all

% trial loop
tt = [];
cnt = 1;
correctionTrial = 0;

while cnt < 2000
    out = serialRead(p);
    fprintf('%s\n',out);
    % write to file and to command window
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
                stimInfo.trialType = tt;                    %#ok<STRNU>
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
        PsychPortAudio('FillBuffer',s,audio');

        % increment trial counter
        fprintf('Trial %03d - %02d\n',trialNumber,tt);

        % work out audio duration
        audio_dur = (size(audio,1)/fs*1000);

        % send trial info to arduino and check that it was received
        fprintf(p,'%i %i %i',[rewardType, giveTO, audio_dur]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif contains(out,'ENDHOLDTIME')
        % present the audio
        PsychPortAudio('Start',s,1);
    
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

        d = regexp(out,'\d');
        d = d(5:end);
        responseOutcome = str2double(out(d));

        outcome_track(trialNumber) = responseOutcome;
        respTime_track(trialNumber) = (respTime-stimOff)/1000000;
        updateGraph(trialNumber,correctionTrial,outcome_track,respTime_track(trialNumber),15)

        % determine next trialType
        if responseOutcome==1                               % if correct or trialType requires no timeout
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
        % make sure we're ready for the next trial
        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif any(contains(out,{'NOAUDIOONEVENT','NOAUDIOOFFEVENT'}))

        status = PsychPortAudio('GetStatus', s);
        while status.Active==1
            status = PsychPortAudio('GetStatus', s);
        end

        newTrial = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

ns = round(t*fs);
r = (sin(linspace(-pi/2,pi/2,ns))/2)+0.5;
r = [r ones(1,length(s) - (ns*2)) fliplr(r)]';
y = s .* r;