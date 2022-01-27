function print_beh_session_stats(fn)

fid = fopen(fn);
C = textscan(fid,'%s');
fclose(fid);

d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));
out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);

% ind = contains(C{1},'TRIALTYPE');
% tt = str2double(out(ind));

ind = contains(C{1},'TRIALOUTCOME');
to = str2double(out(ind));

ind = contains(C{1},'REWON');
n_rew = sum(ind);

fprintf('Number of rewards: %d\n',n_rew);
fprintf('Total trials: %d\n',length(to));
fprintf('%% Correct: %0.1f%%\n', mean(to)*100);

