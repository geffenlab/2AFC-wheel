% plot % correct over sessions
clear
dataLoc = 'D:\behavior\mice\';
mice = {'K203','K204','K206','K207','K208'};
figure('position',[293         191        1320         787])

for mm = 1:length(mice)
    
    mouse = mice{mm};
    files = dir([dataLoc mouse filesep mouse '_*_*']);
    files = {files.name}';
    files = files(contains(files,'training_04'));
    [uFiles,~,iuf] = unique(cellfun(@(x) x(1:13),files,'UniformOutput',false));
    pc = zeros(1,length(uFiles));
    for ff = 1:length(uFiles)
        ffiles = files(iuf==ff);
        if length(ffiles)>1
            matFile = ffiles(contains(ffiles,'.mat'));
        else
            matFile = [];
        end
        txtFile = ffiles(contains(ffiles,'.txt'));
        
        % load behavioural data
        C = [];
        for ii = 1:length(txtFile)
            fid = fopen([dataLoc mouse filesep txtFile{ii}]);
            c = textscan(fid,'%s');
            fclose(fid);
            C = [C; c{1}];  
        end
        
        % load parameters file
%         if isfile([dataLoc mouse filesep matFile])
%             load([dataLoc mouse filesep matFile])
%         end
        C(contains(C,'USEREXIT')) = []; %#ok<*SAGROW>
        
        %% Just split C into 3 columns, tiral number, event string and time/number
        
        d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
        V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d, 'UniformOutput', false));
        out = cellfun(@(c,idx)c(idx:end),C,num2cell(V), 'UniformOutput', false);
        
        % FIRST FIND THE TRIALONS AND CHANGE THEM
        ind = find(contains(C,'TRIALON'));
        ton = out(ind);
        dd = cellfun(@(x) regexp(x,'TRIALON','split'), ton, 'UniformOutput', false);
        for ii = 1:length(ind)
            C{ind(ii)} = [sprintf('%04d',str2double(dd{ii}{2})), 'TRIALON', dd{ii}{1}];
        end
        
        % NOW SPLIT THE STRINGS INTO TRIAL NUMBER AND OUTPUT
        dd = cellfun(@(x) regexp(x,'[A-Z]+','split'), C, 'UniformOutput', false);
        tn = [str2double(cellfun(@(x)x(1),dd));NaN];
        % reset trial numbers
        new_blocks = find(isnan(tn));
        nbi = new_blocks((diff(new_blocks)>1));
        for ii = 2:length(nbi)
            lastTrialNo = tn(find(~isnan(tn(1:nbi(ii))),1,'last'));
            end_block = nbi(ii) + find(isnan(tn(nbi(ii)+1:end)),1,'first') - 1;
            tn(nbi(ii)+1:end_block) = tn(nbi(ii)+1:end_block) + lastTrialNo;
        end
        tn = tn(1:end-1);
        t = str2double(cellfun(@(x)x(end),dd));
        
        % NOW GET THE STRING EVENTS
        dd = cellfun(@(x) regexp(x,'[A-Z]+','match'), C, 'UniformOutput', false);
        se = cellfun(@(x)x(1),dd);
        
        % MAKE A TABLE
        data = table(tn,se,t,'VariableNames',{'trialNo','stringEvent','output'});
        
        
        %% Make an array of key points for each trial
        nTrials = max(data.trialNo(contains(data.stringEvent,'TRIALEND')));
        data_array = NaN(nTrials,11); % 1) trial no, 2) correction trial?, 3) trial type,...
        % 4) giveTO?, 5) totalWait, 6) stimon, 7) resptime, 8) respdir, 9) outcome,
        % 10) reward time, 11) center reward?
        
        nt = 1;
        for ii = 1:nTrials
            if ~isempty(find(data.trialNo==ii & contains(data.stringEvent,'STIMON'),1,'last'))
                data_array(nt,1) = ii;
                data_array(nt,2) = data.output(data.trialNo==ii & contains(data.stringEvent,'CORRECTIONTRIAL'));
                data_array(nt,3) = data.output(data.trialNo==ii & contains(data.stringEvent,'TRIALTYPE'));
                data_array(nt,4) = data.output(data.trialNo==ii & contains(data.stringEvent,'GIVETO'));
                if sum(data.trialNo==ii & contains(data.stringEvent,'TOTALWAITTIME'))==0
                    data_array(nt,5) = NaN;
                else
                    data_array(nt,5) = data.output(data.trialNo==ii & contains(data.stringEvent,'TOTALWAITTIME'));
                end
                if isempty(find(data.trialNo==ii & contains(data.stringEvent,'STIMON'),1,'last'))
                    data_array(nt,6) = NaN;
                else
                    data_array(nt,6) = data.output(find(data.trialNo==ii & contains(data.stringEvent,'STIMON'),1,'last'));
                end
                if sum(data.trialNo==ii & contains(data.stringEvent,'RESPTIME'))==0
                    data_array(nt,7) = NaN;
                else
                    data_array(nt,7) = data.output(data.trialNo==ii & contains(data.stringEvent,'RESPTIME'));
                end
                if sum(data.trialNo==ii & contains(data.stringEvent,'RESPDIR'))==0
                    data_array(nt,8) = NaN;
                else
                    data_array(nt,8) = data.output(data.trialNo==ii & contains(data.stringEvent,'RESPDIR'));
                end
                if sum(data.trialNo==ii & contains(data.stringEvent,'OUTCOME'))==0
                    data_array(nt,9) = NaN;
                else
                    data_array(nt,9) = data.output(data.trialNo==ii & contains(data.stringEvent,'OUTCOME'));
                end
                if data_array(nt,9)==1
                    data_array(nt,10) = data.output(data.trialNo==ii & contains(data.stringEvent,'REWON'));
                else
                    data_array(nt,10) = NaN;
                end
                if isempty(find(data.trialNo==ii & contains(data.stringEvent,'ENDHOLDTIME'),1,'last'))
                    data_array(nt,11) = NaN;
                else
                    data_array(nt,11) = data.output(find(data.trialNo==ii & contains(data.stringEvent,'ENDHOLDTIME'),1,'last'));
                end
                nt = nt+1;
            end
        end
        data_array(isnan(data_array(:,1)),:) = [];
        
        if size(data_array,1)<20
            continue
        end
        
        pc(ff) = mean(data_array(data_array(:,2)==0,9),'omitnan');
    end
    plot(pc*100,'-','LineWidth',4)
    drawnow
    hold on
end
%%
set(gca,'TickDir','out','Box','off','FontSize',14)
xlabel('session #')
ylabel('percent correct')
hold on
plot([1 15],[50 50],'k--','Linewidth',2)
xlim([1 15])
mice{6} = 'chance';
legend(mice);