function updateGraph(trialNumber, correctionTrial, outcome, respTime, smoothing)
hold on
% if resp==99
%     resp = NaN;
% end

% <<<<<<< Updated upstream
% if resp==99
%     resp = NaN;
% end

% outcome_smth = smooth(outcome(1:trialNumber),smoothing);
% =======
% outcome_smth = smooth(outcome,smoothing);
% outcome_smth = zeros(trialNumber,1);
outcome_smth(trialNumber) = mean(outcome(1:trialNumber));
% >>>>>>> Stashed changes

%             figure(fh)
% subplot(1,1,1)
hold all
symb = {'ok','ok','^m','^m'};
mkfill = {'none','k','none','m'};
if correctionTrial==0 && outcome(trialNumber)==1
    plot(trialNumber, outcome_smth(trialNumber), symb{1},'MarkerFaceColor',mkfill{1},'LineWidth',1)
elseif correctionTrial==0 && outcome(trialNumber)==0
    plot(trialNumber, outcome_smth(trialNumber), symb{2},'MarkerFaceColor',mkfill{2},'LineWidth',1)
elseif correctionTrial==1 && outcome(trialNumber)==1
    plot(trialNumber, outcome_smth(trialNumber), symb{3},'MarkerFaceColor',mkfill{3},'LineWidth',1)
elseif correctionTrial==1 && outcome(trialNumber)==0
    plot(trialNumber, outcome_smth(trialNumber), symb{4},'MarkerFaceColor',mkfill{4},'LineWidth',1)
end
set(gca,'box','off','TickDir','out')
xlabel('trial number')
ylabel('P(correct)')
% plot([trialNumber-1 trialNumber],...
%     [nanmean(resp(trialNumber-smoothing-1:trialNumber-1)) nanmean(resp(trialNumber-smoothing:trialNumber))],'.k-')
% xlabel('trial number')
% ylabel('P(correct)')
% ylim([0 1])
% hold on
% subplot(1,2,2)
% hold on
% if correctionTrial==0 && outcome(trialNumber)==1
%     plot(trialNumber, respTime, symb{1},'MarkerFaceColor',mkfill{1},'LineWidth',1)
% elseif correctionTrial==0 && outcome(trialNumber)==0
%     plot(trialNumber, respTime, symb{2},'MarkerFaceColor',mkfill{2},'LineWidth',1)
% elseif correctionTrial==1 && outcome(trialNumber)==1
%     plot(trialNumber, respTime, symb{3},'MarkerFaceColor',mkfill{3},'LineWidth',1)
% elseif correctionTrial==1 && outcome(trialNumber)==0
%     plot(trialNumber, respTime, symb{4},'MarkerFaceColor',mkfill{4},'LineWidth',1)
% end
% set(gca,'box','off','TickDir','out','YScale','log')
% xlabel('trial number')
% ylabel('Response Time (s)')

drawnow
