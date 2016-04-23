% pam4_to_letters.m

function f = pam4_to_letters(seq)

S = length(seq);
off = mod(S,4);

if off ~= 0
    sprintf('dropping first %i PAM symbols',off)
    seq = seq(off+1:end);
end

N = length(seq)/4;

for k = 0:N-1
    f(k+1) = base2dec(char((seq(4*k+1:4*k+4)+99)/2),4); 
end

f = char(f);