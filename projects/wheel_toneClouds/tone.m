function x=tone(f,ph,dur,sf)
% x=tone(f,ph,dur,sf); returns a sine tone of freq f Hz, phase ph rad, duration dur sec at sample rate sf Hz

npts=dur*sf;
inc=2*pi*f/sf;
x=(0:npts-1)*inc+ph;
x=cos(x);