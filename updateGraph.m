function updateGraph(trialNumber, correctionTrial, outcome, respTime, smoothing)

if resp==99
    resp = NaN;
end

outcome_smth = smooth(outcome,smoothing);

%             figure(fh)
subplot(1,2,1)
symb = {'ok','ok','^m','^m'};
mkfill = {'none','k','none','m'};
if ~correctionTrial(trialNumber) && outcome(trialNumber)
    plot(trialNumber, outcome_smth(trialNumber), symb{1},'MarkerFaceColor',mkfill{1},'LineWidth',2)
elseif ~correctionTrial(trialNumber) && ~outcome(trialNumber)
    plot(trialNumber, outcome_smth(trialNumber), symb{2},'MarkerFaceColor',mkfill{2},'LineWidth',2)
elseif correctionTrial(trialNumber) && outcome(trialNumber)
    plot(trialNumber, outcome_smth(trialNumber), symb{3},'MarkerFaceColor',mkfill{3},'LineWidth',2)
elseif correctionTrial(trialNumber) && ~outcome(trialNumber)
    plot(trialNumber, outcome_smth(trialNumber), symb{4},'MarkerFaceColor',mkfill{4},'LineWidth',2)
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
subplot(1,2,2)
if ~correctionTrial(trialNumber) && outcome(trialNumber)
    plot(trialNumber, respTime(trialNumber), symb{1},'MarkerFaceColor',mkfill{1},'LineWidth',2)
elseif ~correctionTrial(trialNumber) && ~outcome(trialNumber)
    plot(trialNumber, respTime(trialNumber), symb{2},'MarkerFaceColor',mkfill{2},'LineWidth',2)
elseif correctionTrial(trialNumber) && outcome(trialNumber)
    plot(trialNumber, respTime(trialNumber), symb{3},'MarkerFaceColor',mkfill{3},'LineWidth',2)
elseif correctionTrial(trialNumber) && ~outcome(trialNumber)
    plot(trialNumber, respTime(trialNumber), symb{4},'MarkerFaceColor',mkfill{4},'LineWidth',2)
end
set(gca,'box','off','TickDir','out','YScale','log')
xlabel('trial number')
ylabel('Response Time')

drawnow
