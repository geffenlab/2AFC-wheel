% Behaviour task with wheel response
function switchWheel_behaviour
global wb
% fclose(s)


switch wb.taskState
    
    case 1
%         wb.s=setupSerial('/dev/tty.usbmodem1431'); % MAC
        wb.s=setupSerial('COM4'); % windows
        wb.taskState = 2;
        
    case 2 % LOAD SOUND STIMULI AND TELL ARDUINO TRIAL TYPE
        
        if wb.newTrial==1
            %   send new stimulus to sound card
            wb.correctionTrial=0;
            wb.trialType = 1;
        else
            %   continue with same sound
            wb.correctionTrial=1;
            wb.trialType = 1;
        end

         % Increase trial number
         wb.trialNumber=wb.trialNumber+1;
         disp(['Trial: ' num2str(wb.trialNumber)]);
         
         % Wait for start
          arduinoChat=fscanf(wb.s,'%s');
        while ~strcmp(arduinoChat,'start')
            arduinoChat=fscanf(wb.s,'%s');                  
        end
        
        % send trial type to arduino
        fprintf(wb.s,'%s',wb.trialType); % 1=left 2=right
        
        % Check it was received
          arduinoChat=wb.s.bytesAvailable;
        while arduinoChat==0
            arduinoChat=wb.s.bytesAvailable;                   
        end
        
%         fscanf(wb.s,'%s')
        disp(['Trial type received: ' fscanf(wb.s,'%s')])
        
        wb.taskState = 3;
        
    case 3 % WAIT FOR MOUSE TO STOP MOVING WHEEL
        % wait for one second for the mouse to keep the wheel still...
      
        % Wait for arduino to send data
        arduinoChat=wb.s.bytesAvailable;
        while arduinoChat==0
            arduinoChat=wb.s.bytesAvailable;                   
        end
        wb.mouseStillTime = fscanf(wb.s,'%f');
        disp(['mouse still for 1 second: ' num2str(wb.mouseStillTime)])
        
        
        wb.taskState = 4; % move to sound presentation
        
    case 4 % PRESENT THE SOUND AND RECEIVE SOUND OFFSET
        
        
        % PRESENT SOUND HERE
        outputSignal1 = [rand(wb.fs*5,1)/10; zeros(50,1)];
        outputSignal2 = [ones(wb.fs*5,1)*3; zeros(50,1)];
        queueOutputData(wb.nidaq,[outputSignal1 outputSignal2]);
        % Start presentation
        [data, time] = startForeground(wb.nidaq);
        
        % Wait for arduino to send info
        arduinoChat=wb.s.bytesAvailable;
        while arduinoChat==0
            arduinoChat=wb.s.bytesAvailable;                   
        end
        wb.soundOnset = fscanf(wb.s,'%f');
        disp(['sound onset received: ' num2str(wb.soundOnset)])
        
        
        arduinoChat=wb.s.bytesAvailable;
        while arduinoChat==0
            arduinoChat=wb.s.bytesAvailable;                   
        end
        wb.soundOffset = fscanf(wb.s,'%f');
        disp(['sound offset received: ' num2str(wb.soundOffset)])
        
%         fscanf(wb.s,'%s')
        
        wb.taskState = 5;
        
    case 5 % RECEIVE INPUT FROM ARDUINO WITH RESPONSE TIME AND IF TRIAL CORRECT OR NOT
        
        
        arduinoChat=wb.s.bytesAvailable;
        while arduinoChat==0
            arduinoChat=wb.s.bytesAvailable;                   
        end
       % disp('received response time and outcome')
        wb.responseTime = fscanf(wb.s,'%f');
        wb.responseOutcome = fscanf(wb.s,'%f');
        disp(['Response time = ' num2str(wb.responseTime)]);
        disp(['Correct? ' num2str(wb.responseOutcome)]);
        
        if wb.responseOutcome==1
            wb.newTrial = 1;
        else
            wb.newTrial = 0;
        end
        
        logWheelTrial
        
        wb.taskState = 2;      
        
end
