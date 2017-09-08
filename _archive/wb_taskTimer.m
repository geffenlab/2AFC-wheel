

%% Run wheel_interrupter on the arduino then run this

%%
global wb 

% Create nidaq session
wb.nidaq = daq.createSession('ni');
addAnalogOutputChannel(wb.nidaq,'Dev1',0,'Voltage');
addAnalogOutputChannel(wb.nidaq,'Dev1',1,'Voltage');
wb.fs=250000;
wb.nidaq.Rate = wb.fs;
% s.DurationInSeconds = 10;


%% Delete session
% stop(wb.nidaq)
% wb.nidaq.release()
% delete(wb.nidaq)

% % Open data file
% wb.fid=fopen('MyFile.txt','w');

% Initialise variables:
wb.taskState=1;
wb.trialNumber = 0;
wb.newTrial = 1;

% start the timer
wb.tasktimer=timer('TimerFcn','switchWheel_behaviour','BusyMode','drop', 'ExecutionMode','fixedRate','Period',0.001);
start(wb.tasktimer);

