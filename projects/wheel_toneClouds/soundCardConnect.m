InitializePsychSound(0)

devices = PsychPortAudio('GetDevices')

d = devices(30).DeviceIndex;

mode = 1; % 1 = playback only, 2 = audio capture, 3 = simultaneous playback and capture
fs =384000;
latA = 1; % latency aggression 1 = lowest possible without quality loss
channels = 2;
buffersize = 1; % 1 second, the higher this is the slower it will run


h = PsychPortAudio('Open',d,mode,latA,fs,channels,buffersize,[],[],[]);

sound = rand(2,fs*5)/10;

streamingRefill = 0; % set this to 1 to re-fill the buffer once all has been presented
startIndex = 'Append';

PsychPortAudio('FillBuffer', h, sound, streamingRefill, startIndex);

% PsychPortAudio('RefillBuffer', pahandle [, bufferhandle=0], bufferdata [, startIndex=0]);
repetitions = 1;
when = 0; % i.e. now
resume = 0; % if set to 1 playback starts at last location, otherwise at beginning
startTime = PsychPortAudio('Start',h,repetitions,when,0,inf,resume);


PsychPortAudio('Close',h);



