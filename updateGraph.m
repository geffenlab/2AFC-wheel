function updateGraph(trialNumber, resp, respTime, smoothing)

if resp==99
    resp = NaN;
end

if trialNumber>smoothing+1
    %             figure(fh)
    subplot(1,2,1)
    plot([trialNumber-1 trialNumber],...
        [nanmean(resp(trialNumber-smoothing-1:trialNumber-1)) nanmean(resp(trialNumber-smoothing:trialNumber))],'.k-')
    xlabel('trial number')
    ylabel('P(correct)')
    ylim([0 1])
    hold on
    subplot(1,2,2)
    plot([trialNumber-1 trialNumber],...
        [nanmean(resp(trialNumber-smoothing-1:trialNumber-1)) nanmean(resp(trialNumber-smoothing:trialNumber))],'.k-')
    hold on
    plot([trialNumber-1 trialNumber],...
        [mean(respTime(trialNumber-smoothing-1:trialNumber-1)) mean(respTime(trialNumber-smoothing:trialNumber))],'.b')
    xlabel('trial number')
    ylabel('Response Time')
    
    drawnow
end