function startOutput(s,device)

isNIDAQ = strcmp(device,'NIDAQ');
isLYNX = contains(device,'Lynx E44');
isASIO = strcmp(device,'ASIO Lynx');

if isASIO
    % start soundcard
    PsychPortAudio('Start', s, 1)
else
    % start NIDAQ
    startBackground(s);
end