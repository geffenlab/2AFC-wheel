function print_beh_session_stats(fn)

fid = fopen(fn);
C = textscan(fid,'%s');
fclose(fid);

d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));
trial_No = cellfun(@(c,idx) c(1:4),C{1}(1:end-1), 'UniformOutput', false);
out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);

ind = contains(C{1},'NOAUDIOEVENT');
na = str2double(trial_No(ind));

ind = contains(C{1},'CORRECTIONTRIAL');
ct = str2double(trial_No(ind))+1;
[~,i] = intersect(ct,na);
ct(i) = [];

ind = contains(C{1},'TRIALOUTCOME');
to = str2double(out(ind));
% if length(ct)-1==length(to)
%     ct = ct(1:end-1);
%     cti = false(length(ct),1); cti(ct) = true;
%     nctpc = mean(to(~cti))*100;
% end

ind = contains(C{1},'REWON');
n_rew = sum(ind);
ind = contains(C{1},'CENTERREWARD');
n_rew = n_rew+sum(ind);

fprintf('Number of rewards: %d\n',n_rew);
fprintf('Total trials: %d\n',length(to));
fprintf('%% Correct: %0.0f%%\n', mean(to)*100);
% fprintf('%% Correct (non-correction trials): %0.0f%%\n',nctpc);

