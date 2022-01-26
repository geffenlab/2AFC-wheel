fid = fopen('D:\behavior\mice\_test\_test_20220126_1729_training.txt');
C = textscan(fid,'%s');
fclose(fid);


tt = contains(C{1},'TRIALTYPE');
d = cellfun(@(x) regexp(x,'\d'), C, 'UniformOutput', false);
late_d = cell2mat(cellfun(@(x) x(find(x>4,1,'first')), d{1}, 'UniformOutput', false));

V = late_d;
out = cellfun(@(c,idx)c(idx:end),C{1}(1:end-1),num2cell(V), 'UniformOutput', false);
tt_d = str2double(out(tt));