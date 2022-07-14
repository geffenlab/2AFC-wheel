function trial_type = adaptive_trials(outcomes,targets)

incorrectResponses = double(~logical(targets(outcomes==0)-1));
if length(incorrectResponses)<10
    pR = 0.5;
else         
    pR = 1-mean(incorrectResponses(end-9:end));
end
if pR > 0.85
    pR = 0.85;
elseif pR < 0.15
    pR = 0.15;
end
    
trial_type = binornd(1,pR)+1;
fprintf('pR = %0.3f\n',pR)




% % From Pinto et al. 2018    
% % First, if performance fell below 55% correct, animals were automatically
% % transferred to a block of trials in an easier maze, with towers shown
% % only on the rewarded side, but with no visual guide. This block had a
% % fixed length of 10 trials, after which the mouse returned to the main
% % maze regardless of performance. The other purpose of the 40-trial window
% % was to assess and attempt to correct side bias. This was achieved by
% % changing the underlying probability of drawing a left or a right trial
% % according to a balanced method described in detail elsewhere (Hu et al.,
% % 2009). 
% 
% % percent_correct = mean(outcomes)*100;
% 
% % In brief, the probability of drawing a right trial, pR, is given
% % by: pR = √eR (√eR + √eL). Where eR (eL) is the weighted average of the
% % fraction of errors the mouse has made in the past 40 right (left) trials.
% % The weighting for this average is given by a half-Gaussian with σ = 20
% % trials in the past, which ensures that most recent trials have larger
% % weight on the debiasing algorithm. To discourage the generation of
% % sequences of all-right (or all-left) trials, we capped √eR and √eL to be
% % within the range [0.15, 0.85].
% 
% % find the past targets
% pastWindow = 20;
% targetsL = find(targets==1);
% if length(targetsL)>pastWindow
%     targetsL = targetsL(end-(pastWindow-1):end);
% end
% targetsR = find(targets==2);
% if length(targetsR)>pastWindow
%     targetsR = targetsR(end-(pastWindow-1):end);
% end
% 
% % weight the outcomes
% outcomesE = double(~logical(outcomes)); % makes it a 1 for error and 0 for correct
% weighting = normpdf(-pastWindow+1:1,0,(pastWindow/2));
% weighting = weighting/max(weighting);
% 
% outcomesL = outcomesE(targetsL);
% outcomesR = outcomesE(targetsR);
% 
% if size(outcomesL,1)>1
%     outcomesL = outcomesL';
% end
% if size(outcomesR,1)>1
%     outcomesR = outcomesR';
% end
% 
% weightedL = outcomesL.*weighting(end-(length(outcomesL)-1):end);
% weightedR = outcomesR.*weighting(end-(length(outcomesR)-1):end);
% 
% eL = mean(weightedL); % sum incorrect on left trials
% eR = mean(weightedR); % sum incorrect on right trials
% 
% pR = sqrt(eR)/sum(sqrt(eR) + sqrt(eL));
% 
% % In addition, a pseudo-random drawing
% % prescription was applied to ensure that the empirical fraction of right
% % trials as calculated using a σ = 60 trials half-Gaussian weighting window
% % is as close to pR as possible, i.e., more so than obtained by a purely
% % random strategy. Specifically, if this empirical fraction is above pR,
% % right trials are drawn with probability 0.5 pR, whereas if this fraction
% % is below pR, right trials are drawn with probability 0.5 (1 + pR).
% % empiricalSigma = 60;
% % if length(targets)>pastWindow
% %     targetsE = targets(end-(pastWindow-1):end);
% % else
% %     targetsE = targets;
% % end
% % if size(targetsE,1)>1
% %     targetsE = targetsE';
% % end
% % 
% % weighting = normpdf(-pastWindow+1:0,0,empiricalSigma);
% % weighting = weighting/max(weighting);
% % empiricalWeighted = mean((targetsE-1).*weighting(end-(length(targetsE)-1):end));
% % if empiricalWeighted>pR
% %     pR = pR*0.5;
% % elseif empiricalWeighted<pR
% %     pR = 0.5*(1 + pR);  
% % end
% 
% if pR>0.85
%     pR = 0.85;
% elseif pR<0.15
%     pR = 0.15;
% end
% 
% if isnan(pR)
%     pR = 0.5;
% end