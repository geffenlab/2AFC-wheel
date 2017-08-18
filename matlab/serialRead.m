function out = serialRead(s)

x = s.BytesAvailable;

while x==0
    x=s.BytesAvailable;
end
out = fscanf(s,'%s');