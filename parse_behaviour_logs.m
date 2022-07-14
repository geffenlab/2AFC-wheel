clear
date_ = '20220714';

dataLoc = 'D:\behavior\mice\';
mice = {'K203','K204','K206','K207','K208'};
figure('position',[293         191        1320         787])

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
        
        
        %% Just split C into 3 columns, tiral number, event string and time/number
        
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
        
        %% Plot response direction relative to sound location
        
        [utt,~,it]  = unique(data_array(:,3));
        resp = zeros(length(utt),2); % percentage of responses left and right for each stimulus
        for ii = 1:length(utt)
            resp(ii,1) = mean(data_array(it==utt(ii) & data_array(:,2)==0,8)==1)*100;
            resp(ii,2) = mean(data_array(it==utt(ii) & data_array(:,2)==0,8)==2)*100;
        end
        subplot(221)
        bar(resp)
        set(gca,'TickDir','out','FontSize',14,'XTickLabel',{'Left','Right'},'Box','off')
        xlabel('Sound location')
        ylabel('response direction (%)')
        legend('Left response','Right response')
        title(mouse)
        
        %% Plot response times
        
        % stimDur = (stimInfo.adaptor_dur + stimInfo.target_dur) * 1e6;
        
        
        [utt,~,it]  = unique(data_array(:,3));
        resp = zeros(length(utt),1); % percentage of responses left and right for each stimulus
        for ii = 1:length(utt)
            resp(ii,1) = median(data_array(it==utt(ii) & data_array(:,2)==0,7)-data_array(it==utt(ii) & data_array(:,2)==0,11));
        end
        subplot(222)
        bar(resp/1e6)
        set(gca,'TickDir','out','FontSize',14,'XTickLabel',{'Left','Right'},'Box','off')
        xlabel('Sound location')
        ylabel('Response time (s)')
        
        
        %% Plot % correct
        [utt,~,it]  = unique(data_array(:,3));
        resp = zeros(length(utt),1); % percentage of responses left and right for each stimulus
        sem = resp;
        for ii = 1:length(utt)
            resp(ii,1) = mean(data_array(it==utt(ii) & data_array(:,2)==0,9))*100;
            sem(ii) = std(data_array(it==utt(ii) & data_array(:,2)==0,9))*100/sqrt(sum(it==utt(ii)));
        end
        subplot(223)
        bar(resp)
        hold on
        errorbar([1:length(resp)],resp,sem,'k','Capsize',0,'LineWidth',2,'LineStyle','none')
        set(gca,'TickDir','out','FontSize',14,'XTickLabel',{'Left','Right'},'Box','off')
        xlabel('Sound location')
        ylabel('Percent correct')
        
        %% Plot P(R) for left and right trials over the expt
        % 1) trial no, 2) correction trial?, 3) trial type,...
        % 4) giveTO?, 5) totalWait, 6) stimon, 7) resptime, 8) respdir, 9) outcome,
        % 10) reward time, 11) center reward?
        
        [utt,~,it]  = unique(data_array(:,3));
        resp = cell(2,1); % percentage of responses left and right for each stimulus
        running_av = 20; % window for running average
        PR = resp;
        for ii = 1:length(utt)
            resp{ii} = data_array(it==utt(ii),8)-1;
            PR{ii} = smooth(resp{ii},running_av);
        end
        subplot(224)
        plot(find(it==utt(1)),PR{1},'b-','LineWidth',2)
        hold on
        if ~isempty(PR{2})
            plot(find(it==utt(2)),PR{2},'r-','LineWidth',2)
        end
        plot(smooth(data_array(:,9),running_av),'k-','LineWidth',2)
        set(gca,'TickDir','out','FontSize',14,'Box','off')
        xlabel('Trial number')
        ylabel('P(R)')
        axis tight
        ylim([0 1])
        legend('left trials','right trials','proportion correct')
        pause()
        print([dataLoc mouse filesep uFiles{ff} '.png'],'-dpng')
        clf
    end
end
