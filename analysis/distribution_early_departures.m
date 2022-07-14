clear
date_ = '20220705';
dataLoc = 'D:\behavior\mice\';
mice = {'K203','K204','K206','K207','K208'};
% figure('position',[293         191        1320         787])

for mm = 1:length(mice)
    clf
    mouse = mice{mm};
    files = dir([dataLoc mouse filesep mouse '_' date_ '_*']);
    files = {files.name}';
    files(contains(files,'png')) = [];
    [uFiles,~,iuf] = unique(cellfun(@(x) x(1:18),files,'UniformOutput',false));
    
    for ff = 1:length(uFiles)
        ffiles = files(iuf==ff);
        matFile = ffiles{contains(ffiles,'.mat')};
        txtFile = ffiles{contains(ffiles,'.txt')};
        
        % load behavioural data
        fid = fopen([dataLoc mouse filesep txtFile]);
        C = textscan(fid,'%s');
        fclose(fid);
        
        % load parameters file
        if isfile([dataLoc mouse filesep matFile])
            load([dataLoc mouse filesep matFile])
        end
        
        
        %% Just split C into 3 columns, trial number, event string and time/number
        
        d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
        V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));
        out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);
        
        % FIRST FIND THE TRIALONS AND CHANGE THEM
        ind = find(contains(C{1},'TRIALON'));
        ton = out(ind);
        dd = cellfun(@(x) regexp(x,'TRIALON','split'), ton, 'UniformOutput', false);
        for ii = 1:length(ind)
            C{1}{ind(ii)} = [sprintf('%04d',str2double(dd{ii}{2})), 'TRIALON', dd{ii}{1}];
        end
        
        % NOW SPLIT THE STRINGS INTO TRIAL NUMBER AND OUTPUT
        dd = cellfun(@(x) regexp(x,'[A-Z]+','split'), C{1}, 'UniformOutput', false);
        tn = str2double(cellfun(@(x)x(1),dd));
        t = str2double(cellfun(@(x)x(end),dd));
        
        % NOW GET THE STRING EVENTS
        dd = cellfun(@(x) regexp(x,'[A-Z]+','match'), C{1}, 'UniformOutput', false);
        se = cellfun(@(x)x(1),dd);
        
        % MAKE A TABLE
        data = table(tn,se,t,'VariableNames',{'trialNo','stringEvent','output'});
        %% find all the early departures
        eds = find(contains(data.stringEvent,'EARLYDEP'));
        t = zeros(length(eds),2);
        for ii = 1:length(eds)
            edt = data.output(eds(ii));
            rows = eds(ii)-2:eds(ii);
            eht = data.output(rows(contains(data.stringEvent(rows),'ENDHOLDTIME')));
            if isempty(eht)
                t(ii,:) = NaN; 
            else
                t(ii,1) = data.trialNo(eds(ii));
                t(ii,2) = edt-eht;
            end
        end
            
        tSorted = sort(t(:,2)/1e6);
        plot(tSorted)
        title(mouse)
        pause()
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
end
