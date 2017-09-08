function logWheelTrial

global wb

trialData = [wb.trialNumber, wb.correctionTrial, wb.trialType, wb.mouseStillTime,...
    wb.soundOnset,wb.soundOffset,wb.responseTime,wb.responseOutcome];

 headers ={'trialNo', 'corrTrial?', 'trialType','stillTime','stimOnset', 'stimOffset',...
     'respTime' , 'correct?'};
 
 wb.data(wb.trialNumber,:)=trialData;
 data=wb.data;
 
 save('data.mat','headers','data');
