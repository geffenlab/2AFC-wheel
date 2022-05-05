function [params, stimInfo] = loadFilters(params, stimInfo)

params.filtdir = [params.githubPath '\filters'];
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end
load([params.filtdir filesep params.filtFile_left],'FILT');
params.filt_left = FILT;
load([params.filtdir filesep params.filtFile_right],'FILT');
params.filt_right = FILT;
stimInfo.FILT_left = params.filt_left;
stimInfo.FILT_right = params.filt_right;