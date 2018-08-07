function out = serialReadOctave(s)
  [char_out,int_out] = ReadToTermination(s);
  
  while all(int_out == 1)
    [char_out,int_out] = ReadToTermination(s);
  
  end
  out = char_out;


endfunction