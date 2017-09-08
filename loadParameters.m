function [params fs] = loadParameters(paramFile)

[fid,err] = fopen(paramFile,'r');
a = textscan(fid,'%s %s %f %d %s %s %d %s %s %s',...
    'Delimiter',',','HeaderLines',1);
fclose(fid);
params.boothID = cell2mat(a{1});
params.com = cell2mat(a{2});
params.rewardDuration = double(a{3});
params.debounceTime = double(a{4});
params.device = cell2mat(a{5});
params.channel = eval(cell2mat(a{6}));
fs = double(a{7});
params.filtFile = cell2mat(a{8});
params.ampF = eval(cell2mat(a{9}));
params.genFunc = cell2mat(a{10});
