function y = envelope_CA(s,t,fs)

ns = round(t*fs);
r = sin(linspace(0,pi/2,ns));
r = [r ones(1,length(s) - (ns*2)) fliplr(r)];

y = s .* r;
