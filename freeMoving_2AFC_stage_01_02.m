function freeMoving_2AFC_stage_01_02(mouse,baseDir,project,parameterFile)

delete(instrfindall)
close all
KbName('UnifyKeyNames');
commandwindow

%% SETUP

% load parameters
run(params.paramFile);

% paths
cd(baseDir);
params.basePath = pwd;
params.projPath = [params.basePath filesep 'projects' filesep project];
params.paramFile = [params.projPath filesep parameterFile];
params.hexPath = [params.basePath filesep 'hexFiles' filesep params.hexFile]; %%%%%% CHANGE THIS
params.dataPath = [params.basePath filesep 'mice' filesep mouse];
git = strfind(params.basePath,'GitHub');
params.githubPath = params.basePath(1:git+5);
params.sessID = datestr(now,'yyyymmdd_HHMM');

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
fprintf(p,'%f %f %f %f',[params.rewardDuration_L, params.rewardDuration_R,...
    params.rewardDuration_C, params.rewardInterval]);
WaitSecs(.5);
disp('parameters sent');

% initialize soundcard/midaq
[s,~] = setupSoundOutput_ptb(params.fs,params.device,params.channel);

%% Start the task
% trial loop

cnt = 1;

while cnt < 2000
    out = serialRead(p);
    fprintf('%s\n',out);
    % write to file and to command window
    fprintf(fid,'\n%s',out);

    if contains(out,'USEREXIT')
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


function y = envelope_KCW(s,t,fs)

if size(s,1)==1
    s = s';
end

ns = round(t*fs);
r = (sin(linspace(-pi/2,pi/2,ns))/2)+0.5;
r = [r ones(1,length(s) - (ns*2)) fliplr(r)]';
y = s .* r;