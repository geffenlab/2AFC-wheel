% Create nidaq session
nidaq = daq.createSession('ni');
addAnalogOutputChannel(nidaq,'Dev1',0,'Voltage');
addAnalogOutputChannel(nidaq,'Dev1',1,'Voltage');
fs=250000;
nidaq.Rate = fs;
% s.DurationInSeconds = 10;

s=setupSerial('COM4'); % windows



outputSignal1 = [rand(fs*5,1)/10; zeros(50,1)];
outputSignal2 = [repmat([zeros(25000,1);ones(25000,1)*3],25,1);zeros(50,1)];
queueOutputData(nidaq,[outputSignal1 outputSignal2]);
% Start presentation
[data, time] = startForeground(nidaq);

% fscanf(s,'%f')

for ii=1:25
up1(ii) = fscanf(s,'%f');
down1(ii) = fscanf(s,'%f');

end

arduinoChat=s.bytesAvailable

fclose(s);
stop(nidaq);
nidaq.release();
delete(nidaq);
disp('Session ended');