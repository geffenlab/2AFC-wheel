% Generate a frequency modulated tone of average freq (carrierFreq, Hz), with modulation rate (fModRate, Hz) and modulation depth of (fModDepth, Hz) of specified duration (sec). If want amplitude modulation, enter a modulation rate (aModRate, Hz).
function wave = FM_stimGen_v2(stimInfo)

% nVarargs = length(varargin);
% clear
% Variables to set
% sampleRate = 192000; % sample rate (don't need to change this)
% stimInfo.carrierFreq = 48000; % Carrier Frequency
 phi = 3*pi/2; % phase of the carrier frequency in radians, can change this to vary phase that the stimulus starts from
% stimInfo.fModRate = 20; % modulation rate
% stimInfo.duration =0.1; % in seconds
% stimInfo.fModDepth = 5000; % depth of the modulation in Hz
% AM = 0; % change to 1 if you also want AM moduation
mr = stimInfo.modRates(stimInfo.trialType);
atten = 70-stimInfo.level; % convert tone level to attenuation from 70 dB (filter is set to make sounds at 70 dB)

% make time vector
t = 1/stimInfo.fs:1/stimInfo.fs:stimInfo.stimDur;  % time

% use Isacc's code
freq = sin(2*pi*mr*t'+phi)*stimInfo.modDepth+stimInfo.carrierFreq;
fa = ones(1,length(freq));
% fa = linspace(fd,-fd,length(freq)); % to add a upward or downward sweep
freq2 = freq+fa';
amp = ones(1,length(freq));
wave = vary_pure_tone( amp, freq2'/stimInfo.fs )';
wave  = wave.*10^(-atten/20); % attenuate   
wave = conv(wave,stimInfo.FILT,'same');



