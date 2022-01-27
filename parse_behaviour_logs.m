fid = fopen('D:\behavior\mice\_test\_test_20220126_1729_training.txt');
C = textscan(fid,'%s');
fclose(fid);



d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
V = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));
out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);

ind = contains(C{1},'TRIALTYPE');
tt = str2double(out(ind));

ind = contains(C{1},'TRIALOUTCOME');
to = str2double(out(ind));
