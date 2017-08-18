function [status, cmdOut] = loadArduinoSketch(comport,sketchPath)

cmdIn = sprintf('%s%s%s%s:i"','cmd /C ""C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude.exe" -C"C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketchPath);
[status,cmdOut] = dos(cmdIn);

end