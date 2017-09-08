function [stim events ind] = makeSpeechInNoise(params,tt)


%% make the noise if it doesnt exist
if ~exist(params.noiseFile,'file')
    params.blockDuration = 100;
    fprintf('Making noise background...\n');
    [noise] = makeContrastBlocks(params,1,'uniform','spline');
    fprintf('Filtering noise...');
    tic
    noise = conv(noise,params.filt,'same');
    toc
    fprintf('Saving noise...');
    tic
    audiowrite(params.noiseFile,noise,params.fs);
    toc
end

%% make the filtered tokens if they don't exist
if ~exist(params.speechFile,'file')
    % load tokens
    load([params.stimPath filesep 'speech_tokens_1s.mat']);
    fsin = fs;
    fs = params.fs;
    
    % make a bandpass filter
    fw = params.fRange + [0 -10e3]; % adjusted to minimize the amount of
    % signal outside of the noise spectra
    [fb,fa] = butter(8,fw/(fs/2),'bandpass');
    
    % pad the waveforms to be exactly the same length
    nsamps = [tokens.voicedDuration] * fsin;
    msamps = max(nsamps);
    
    clear wave env target pv speech
    for i = 1:length(tokens)
        % pad the waveforms
        w = tokens(i).waveform(tokens(i).voicedBounds(1): ...
            tokens(i).voicedBounds(1)+msamps-1);
        
        % phase vocoded speech
        n = 2048*2;
        factor = 10;
        pv = filter(fb,fa,phaseVocoder(w,factor,n));
        
        % filter and envelope
        speech(i,:) = envelope_CA(conv(pv,params.filt,'same')',.005,fs);
        
        %subplot(4,2,1+(i-1))
        %spectrogram(w,2048,512,linspace(0,5000,1000),fsin,'yaxis');
        %subplot(4,2,3+(i-1))
        %spectrogram(pv(i,:),256,64,linspace(0,50000,1000),fsin,'yaxis');
    end
    
    % write to file
    fprintf('Saving speech file...\n');
    save(params.speechFile,'speech');
else
    load(params.speechFile);
end

if ~exist('noise','var')
    fs = params.fs;
    
    % determine the stimulus offset
    trialOffset = unifrnd(params.speechOffset-params.jitter,...
        params.speechOffset+params.jitter,1,1);
    trialOffset = ceil(trialOffset * fs);
    
    % make the events
    pulseLength = .005 * fs;
    events = zeros(1,params.blockDuration*fs);
    events(trialOffset:trialOffset+pulseLength) = .5;
    events(1:pulseLength) = .5;
    
    % sample some noise
    info = audioinfo(params.noiseFile);
    ind = randi(info.TotalSamples - (params.blockDuration*fs),1,1);
    ind = [ind ind+(params.blockDuration*fs)-1];
    noise = audioread(params.noiseFile,ind);
    noise = envelope_CA(noise',.005,fs);
    
    % make noise only or speech in noise stimulus
    stim = noise;
    if tt ~= 0
        stim(trialOffset:trialOffset+length(speech)-1) = stim(trialOffset:trialOffset+length(speech)-1) + params.gain .* speech(tt,:);
    end
else
    stim = [];
    events = [];
    ind = [];
end


