function [s,realFS] = setupSoundOutput(fs,device,ch)

isNIDAQ = strcmp(device,'NIDAQ');
isLYNX = contains(device,'Lynx E44');
isASIO = strcmp(device,'ASIO Lynx');

if isASIO
    % setup ASIO soundcard
    InitializePsychSound(1);
        
    % find the device
    d = PsychPortAudio('GetDevices',3);
    ind = find(strcmp({d.DeviceName}, device));
    id = d(ind).DeviceIndex;
    
    % open and determine real framerate
    s = PsychPortAudio('Open', id, 1, 3, fs, length(ch), [], [], ch);
    status = PsychPortAudio('GetStatus', s);
    realFS = status.SampleRate;
elseif isNIDAQ
    % setup NIDAQ
    daqreset;
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,'dev1',ch,'Voltage');
    s.Rate = fs;
    realFS = s.Rate;
elseif isLYNX
    % setup non-ASIO LYNX card
    d = daq.getDevices;
    description = sprintf('DirectSound Speakers (%s)',device);
    ind = find(strcmp({d.Description},description));
    dev = d(ind);
    s = daq.createSession('directsound');
    ch = addAudioOutputChannel(s,dev.ID,ch);
    s.Rate = fs;
    realFS = s.Rate;
end
    