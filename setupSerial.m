function s = setupSerial(comPort)
% Initialise serial prot connection between matlab and arduino and chech
% the connection


s=serial(comPort);
set(s,'BaudRate', 9600);
%set(s,'DataBits', 8);
set(s,'ByteSize',8);
set(s,'StopBits', 1);
%set(s,'Parity','none');
set(s,'Parity','N');
set(s,'TimeOut',10);
%fopen(s);

a = 'b';
tries = 10;
while ~strcmp(a,'a') && tries > 0;
   %a=fread(s,1,'uchar');
   a = ReadToTermination(s);
   disp(a)
   pause(0.05);
   tries = tries - 1;
end

if strcmp(a,"a")
    disp('Serial connection read')
end

srl_write(s,'a') % send the a back to the arduino
disp('Serial connection established'); %uiwait(mbox);
% % % fscanf(s,'%u');
% ind=1; readings=[];
% x=s.bytesAvailable;
% 
% while x>0
%   fscanf(s,'%s');
%     x=s.bytesAvailable;
% end
