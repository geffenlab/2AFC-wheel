clear

run('D:\GitHub\2AFC-wheel\projects\wheel_toneClouds\TC_booth3_initialPsychometric_params.mat')

[FILENAME, PATHNAME] = uigetfile('D:\GitHub\2AFC-wheel\projects\wheel_toneClouds\*.txt','MultiSelect','on');
if ~iscell(FILENAME); FILENAME = cellstr(FILENAME); end
data = [];
for ii=1:length(FILENAME)
    d = importdata([PATHNAME FILENAME{ii}]);
    if size(d,2)==10
        uS = unique(d(:,[3,4]),'rows');
        for jj=1:size(uS,1)
            rows = find(d(:,3)==uS(jj,1) & d(:,4)==uS(jj,2));
            d(rows,3)=jj;
        end
        d(:,4)=[];
    end
    data = [data;d.data]; %#ok<AGROW>
end
% get rid of correction trials
data(data(:,8)==1,:)=[];



uS = unique(data(:,2),'rows');
uStim = stimInfo.cloudRange(uS,:);
pr = zeros(1,length(uS)); pr_std = pr;
for ii=1:size(uS,1) % probability of turning wheel/responding right
    rows = find(data(:,2)==uS(ii,1));
    pr(ii) = mean(data(rows,3));
    pr_std(ii) = std(data(rows,3));
end


figure
plot(uStim(:,1)+((uStim(:,2)-uStim(:,1))/2),pr,'ro-', 'LineWidth',1.5);
title ('Psychometric Curve');
set(gca,'XScale','log')
axis tight

xlabel('toneCloud middle of octave freq (Hz)')
ylabel('P(right)')
ylim([0 1])
box off
axis tight
set(gca,'TickDir','out','FontSize',14)
ylim([0 1])

