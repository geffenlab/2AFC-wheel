clear
clc
pR = 0.5;
target = zeros(1000,1);
outcome = target;
for ii = 1:1000
    disp(['Trial number: ' num2str(ii)])
    target(ii) = adaptive_trials(outcome(1:ii),target(1:ii));
    disp(['Target: ' num2str(target(ii))])
    resp = input('Press 0 for left and 1 for right: ');
    fprintf('\n')
    outcome(ii) = (target(ii)-1)==resp;
end