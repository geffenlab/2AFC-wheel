function [amps db] = makeChordAmplitudes(rs,cs,n,params,distribution)

% generates noise patterns of different contrasts, drawn from
% two uniform distributions

amps = [];
db = [];
for j = 1:n
    % make some dB and amplitude values per frequency
    MU = params.mu;
    SD = params.sd(mod(j-1,2)+1);
    if strcmp(distribution,'uniform')
        dBs = unifrnd(MU-SD,MU+SD,params.nTones,params.blockDuration/ ...
                      params.chordDuration);
    elseif strcmp(distribution,'normal')
        dBs = MU + SD * randn(params.nTones,params.blockDuration/ ...
                      params.chordDuration);
    end
    db = [db dBs];
    a = params.baseAmplitude .* 10 .^ ((dBs-70)./20);
    amps = [amps a];
end
