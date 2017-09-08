% Behaviour task with wheel response
function wheel_behaviour_audioplayer


% Create nidaq session
% nidaq = daq.createSession('ni');
% addAnalogOutputChannel(nidaq,'Dev1',0,'Voltage');
% addAnalogOutputChannel(nidaq,'Dev1',1,'Voltage');
fs=192000;
a = audiodevinfo;
sc.ID = a.output(7).ID;
sc.Rate = fs;
% s.DurationInSeconds = 10;

 s=setupSerial('COM4'); % windows
 taskState = 2;


%% Delete session
% stop(nidaq)
% nidaq.release()
% delete(nidaq)

% % Open data file
% fid=fopen('MyFile.txt','w');

% Initialise variables:
trialNumber = 0;
newTrial = 1;


% fclose(s)
global wb

while wb.run==1
    switch taskState
        
        case 1
            %         s=setupSerial('/dev/tty.usbmodem1431'); % MAC
%             s=setupSerial('COM4'); % windows
%             taskState = 2;
            
        case 2 % LOAD SOUND STIMULI AND TELL ARDUINO TRIAL TYPE
            
            if newTrial==1
                %   send new stimulus to sound card
                correctionTrial=0;
                trialType = 1;
            else
                %   continue with same sound
                correctionTrial=1;
                trialType = 1;
            end
            
            % Increase trial number
            trialNumber=trialNumber+1;
            disp(['Trial: ' num2str(trialNumber)]);
            
            % Wait for start
            arduinoChat=fscanf(s,'%s');
            while ~strcmp(arduinoChat,'start')
                arduinoChat=fscanf(s,'%s');
            end
            
            % send trial type to arduino
            fprintf(s,'%s',trialType); % 1=left 2=right
            
            % Check it was received
            arduinoChat=s.bytesAvailable;
            while arduinoChat==0
                arduinoChat=s.bytesAvailable;
            end
            
            %         fscanf(s,'%s')
            disp(['Trial type received: ' fscanf(s,'%s')])
            
            taskState = 3;
            
        case 3 % WAIT FOR MOUSE TO STOP MOVING WHEEL
            % wait for one second for the mouse to keep the wheel still...
            
            % Wait for arduino to send data
            arduinoChat=s.bytesAvailable;
            while arduinoChat==0
                arduinoChat=s.bytesAvailable;
            end
            mouseStillTime = fscanf(s,'%f');
            disp(['mouse still for 1 second: ' num2str(mouseStillTime)])
            
            
            taskState = 4; % move to sound presentation
            
        case 4 % PRESENT THE SOUND AND RECEIVE SOUND OFFSET
            
            
            % PRESENT SOUND HERE
            outputSignal1 = [tone(20000,1,1,fs)'*10;zeros(50,1)];
            outputSignal2 = [zeros(fs*1,1); zeros(50,1)];
%             outputSignal2 = [ones(fs*1,1)*20; zeros(50,1)];
            b = audioplayer([outputSignal1 outputSignal2],fs,24,sc.ID);
%             queueOutputData(nidaq,[outputSignal1 outputSignal2]);
            % Start presentation
            play(b)
%             [data, time] = startForeground(nidaq);
            
            % Wait for arduino to send info
            arduinoChat=s.bytesAvailable;
            while arduinoChat==0
                arduinoChat=s.bytesAvailable;
            end
            soundOnset = fscanf(s,'%f');
            disp(['sound onset received: ' num2str(soundOnset)])
            
            
            arduinoChat=s.bytesAvailable;
            while arduinoChat==0
                arduinoChat=s.bytesAvailable;
            end
            soundOffset = fscanf(s,'%f');
            disp(['sound offset received: ' num2str(soundOffset)])
            disp(['Difference: ' num2str(soundOffset-soundOnset)])
            %         fscanf(s,'%s')
            
            taskState = 5;
            
        case 5 % RECEIVE INPUT FROM ARDUINO WITH RESPONSE TIME AND IF TRIAL CORRECT OR NOT
            
            
            arduinoChat=s.bytesAvailable;
            while arduinoChat==0
                arduinoChat=s.bytesAvailable;
            end
            % disp('received response time and outcome')
            responseTime = fscanf(s,'%f');
            responseOutcome = fscanf(s,'%f');
            disp(['Response time = ' num2str(responseTime)]);
            disp(['Correct? ' num2str(responseOutcome)]);
            
            if responseOutcome==1
                newTrial = 1;
            else
                newTrial = 0;
            end
            
            logWheelTrial_WL(trialNumber, correctionTrial, trialType, mouseStillTime,...
                soundOnset,soundOffset,responseTime,responseOutcome)
            
            taskState = 2;
            
    end
end

%% Close everything
fclose(s);
stop(nidaq);
nidaq.release();
delete(nidaq);
disp('Session ended');
