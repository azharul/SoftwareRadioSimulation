% letters_to_pam4.m

function f = letters_to_pam4(str);

N = length(str);
str = double(str);

f = zeros(1,4*N);

for k = 0:N-1
    f(4*k+1:4*k+4) = 2*double(dec2base(str(k+1),4,4)) - 99;
end
