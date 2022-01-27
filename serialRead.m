function out = serialRead(s)

x = s.BytesAvailable;

while x==0
    x = s.BytesAvailable;
    flag = check_keyboard;
    if flag
        x = 'exit';
    else
    end
end

if strcmp(x,'exit')
    out = 'USEREXIT';
else
    out = fscanf(s,'%s');
end

flag = check_keyboard;
if flag
    out = 'USEREXIT';
end


function flag = check_keyboard
% Exit statement
[~,~,keyCode] = KbCheck;
flag = false;
if sum(keyCode) == 1
    if strcmp(KbName(keyCode),'ESCAPE')
        flag = true;
    end
else
    flag = false;
end

