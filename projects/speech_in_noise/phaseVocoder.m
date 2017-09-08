function s = phaseVocoder(si,factor,n)

e = pvoc(si,1/factor);
s = resample(e,1,factor);