function logWheelTrial_WL(fid,trialNumber, correctionTrial, trialType, mouseStillTime,...
    soundOnset,soundOffset,responseTime,responseOutcome,wheelDirection,varargin)

% switch nargin
%     case 9
        trialData = [trialNumber, correctionTrial, trialType, mouseStillTime,...
            soundOnset,soundOffset,responseTime,responseOutcome,wheelDirection];
        
        headers ={'trialNo', 'corrTrial?', 'trialType','stillTime','stimOnset', 'stimOffset',...
            'respTime' , 'correct?','wheel direction'};
        
        data(trialNumber,:)=trialData;
        data=data;
        
        
        fprintf(fid,'\n%03d\t%i\t%i\t%g\t%g\t%g\t%g\t%i\t%i',trialData);
%     case 10
%         trialData = [trialNumber, correctionTrial, trialType.tt, mouseStillTime,...
%             soundOnset,soundOffset,responseTime,responseOutcome,wheelDirection];
%         
%         headers ={'trialNo', 'corrTrial?','trialType', 'trialType','stillTime','stimOnset', 'stimOffset',...
%             'respTime' , 'correct?','wheel direction'};
%         
%         data(trialNumber,:)=trialData;
%         data=data;
%         
%         
%         fprintf(fid,'\n%03d\t%i\t%i\t%g\t%g\t%g\t%g\t%i\t%i\t%i',trialData);
% end

%  save('data.mat','headers','data','-append');
