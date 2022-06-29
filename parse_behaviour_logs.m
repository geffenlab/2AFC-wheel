clear
fid = fopen('D:\behavior\mice\K208\K208_20220628_1506_training_04.txt');
C = textscan(fid,'%s');
fclose(fid);

d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));
out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);

%% Just split C into 3 columns, tiral number, event string and time/number

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
data_array = zeros(nTrials,9); % 1) trial no, 2) correction trial?, 3) trial type,...
% 4) giveTO?, 5) totalWait, 6) stimon, 7) resptime, 8) respdir, 9) outcome,
% 10) reward time, 11) center reward?

for ii = 1:nTrials
    data_array(ii,1) = ii;
    data_array(ii,2) = data.output(data.trialNo==ii & contains(data.stringEvent,'CORRECTIONTRIAL'));
    data_array(ii,3) = data.output(data.trialNo==ii & contains(data.stringEvent,'TRIALTYPE'));
    data_array(ii,4) = data.output(data.trialNo==ii & contains(data.stringEvent,'GIVETO'));
    data_array(ii,5) = data.output(data.trialNo==ii & contains(data.stringEvent,'TOTALWAITTIME'));
    data_array(ii,6) = data.output(find(data.trialNo==ii & contains(data.stringEvent,'STIMON'),1,'last'));
    data_array(ii,7) = data.output(data.trialNo==ii & contains(data.stringEvent,'RESPTIME'));
    data_array(ii,8) = data.output(data.trialNo==ii & contains(data.stringEvent,'RESPDIR'));
    data_array(ii,9) = data.output(data.trialNo==ii & contains(data.stringEvent,'OUTCOME'));
    if data_array(ii,9)==1
        data_array(ii,10) = data.output(data.trialNo==ii & contains(data.stringEvent,'REWON'));
    else
        data_array(ii,10) = NaN;
    end
end

%% Plot response direction relative to sound location

[utt,~,it]  = unique(data_array(:,3));
resp = zeros(length(utt),2); % percentage of responses left and right for each stimulus
for ii = 1:length(utt)
    resp(ii,1) = mean(data_array(it==utt(ii),8)==1)*100;
    resp(ii,2) = mean(data_array(it==utt(ii),8)==2)*100;
end

bar(resp)
set(gca,'TickDir','out','FontSize',14,'XTickLabel',{'Left','Right'},'Box','off')
xlabel('Sound location')
ylabel('response direction (%)')
legend('Left response','Right response','Location','northeastoutside')
    
%% Plot response times

[utt,~,it]  = unique(data_array(:,3));
resp = zeros(length(utt),1); % percentage of responses left and right for each stimulus
for ii = 1:length(utt)
    resp(ii,1) = mean(data_array(it==utt(ii),7)-data_array(it==utt(ii),6));
end

bar(resp/1e6)
set(gca,'TickDir','out','FontSize',14,'XTickLabel',{'Left','Right'},'Box','off')
xlabel('Sound location')
ylabel('Response time (s)')





