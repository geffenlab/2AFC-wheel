% Look at data
function data = behSessionInfo(filename)
% filename = 'K050_01-Feb-2017.txt';
% fileLoc = 'C:\Users\geffen-behaviour2\Documents\GitHub\Kath\behaviour\2AFC_wheel\matlab\wheelBehaviouralTask\';
data = importdata(filename);

data(data(:,8)==99,8)=NaN;
nRew = nansum(data(:,8));
disp(['Number of rewards: ' num2str(nRew)])

pc = round(nanmean(data(data(:,2)==0,8))*100);
disp([num2str(pc) ' % correct excluding correction trials'])
figure
pcOverTime = smooth(data(:,8),30);
subplot(1,2,1)
plot(pcOverTime,'-k','LineWidth',2)
xlabel('trial number')
ylabel('P(correct)')
axis tight
ylim([0 1])
hold on
plot([1 length(data)], [0.5 0.5],'r--')


data(:,10) = (data(:,7)-data(:,6))/1e6;
maxUSlong =  4210410672105;
if any(data(:,10)<0)
    r = find(data(:,10)<0);
    for ii = 1:length(r)
        c = find(diff(data(r(ii),4:7))<0==1)+4;
        data(r(ii),c) = data(r(ii),c)+maxUSlong;
        data(r(ii)+1:end,4:7) = data(r(ii)+1:end,4:7)+maxUSlong;
    end
end


subplot(1,2,2)
plot(smooth(data(:,10),30),'.')
hold on
plot(pcOverTime,'-k','LineWidth',2)
set(gcf,'Position',[273 558 1067 420])

stdResp = std(data(data(:,2)==0,10));
mResp = median(data(data(:,2)==0,10));
pc = nanmean(data(data(:,10)<(mResp+stdResp*1) & data(:,2)==0,8));
pc = round(pc*100,1);
disp([num2str(pc) ' % correct on trials where response time was within 1 st dev of the median'])




    

