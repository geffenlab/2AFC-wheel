function [stim amps dbs] = makeContrastBlocks(params,n,distribution,method)

% number of samples in ramps and chords
rs = floor(params.rampDuration * params.fs);
cs = floor((params.chordDuration - params.rampDuration) * params.fs);
params.totalDuration = n * params.blockDuration;

[amps dbs] = makeChordAmplitudes(rs,cs,n,params,distribution);

% make a waveform
t1 = tic;
stim = zeros(1,params.totalDuration * params.fs);
t = 0:1/params.fs:params.totalDuration-(1/params.fs);
% for each frequency
for i = 1:length(params.freqs)
    %fprintf('FREQ = %g\n',params.freqs(i));
    % make a waveform
    f = sin(params.freqs(i)*t*pi*2);
    
    if strcmp(method,'spline')
        % splined amplitude envelope
        ampEnv = interp1(1:length(amps),amps(i,:),...
                         linspace(1,length(amps),length(amps) * ...
                                  (params.chordDuration*params.fs)),'spline');
    end
    
    if strcmp(method,'linear')
        % linear amplitude envelope
        ampEnv = zeros(size(stim));
        for j = 0:size(amps,2)-1
            ind = (j:j+1)*(rs+cs) + [1 0];

            % for the very first and last, don't ramp
            if j == 0 | j == size(amps,2)-1
                tmp = ones(1,rs+cs) * amps(i,j+1);
                ampEnv(ind(1):ind(2)) = tmp;
            else
                tmp = ones(1,cs) * amps(i,j+1);
                %ramp = interp1([0 1],[amps(i,j)
                %amps(i,j+1)],linspace(0,1,rs));
                ramp = interp1([0 1],[amps(i,j) amps(i,j+1)], ...
                               linspace(0,1,rs));
                ampEnv(ind(1):ind(2)) = [ramp tmp];
            end
            
            if ~mod(j,1000)
                %fprintf('\tchord %d/%d\n',j,length(amps));
            end
        end
    end
    stim = stim + (f .* ampEnv);
end

% cosine ramp the start and end
ramp = make_ramp(params.rampDuration*params.fs);
ramp = [ramp ones(1,length(stim) - (2*length(ramp))) fliplr(ramp)];
stim = stim .* ramp;
toc(t1)



function ramp = make_ramp(ramp_length)

ramp = linspace(0,1,ramp_length);                  % linear ramp
scale = 1 ./ sqrt(ramp.^2 + (1-ramp).^2);   % account for change in variance as noise is added

ramp = ramp .* scale;