function [s] = setupSerial(comPort)
% Initialise serial prot connection between matlab and arduino and chech
% the connection


s=serial(comPort);
set(s,'BaudRate', 9600);
set(s,'DataBits', 8);
set(s,'StopBits', 1);
set(s,'Parity','none');
fopen(s);

a = 'b';

while a ~= 'a'
    a=fread(s,1,'uchar');
end

if a=='a'
    disp('Serial connection read')
end

fprintf(s,'%c','a') % send the a back to the arduino
disp('Serial connection established'); %uiwait(mbox);
% % % fscanf(s,'%u');
% ind=1; readings=[];
% x=s.bytesAvailable;
% 
% while x>0
%   fscanf(s,'%s');
%     x=s.bytesAvailable;
% end
