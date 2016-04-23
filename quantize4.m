function f = quantize4(v)

N = length(v);
f = zeros(1,N);

for i = 1:N
   
   vi = v(i);
   
   if (vi >= 2),
      f(i) = 3;
   elseif (vi < 2) & (vi >= 0),
      f(i) = 1;
   elseif (vi < 0) & (vi >=-2),
      f(i) = -1;
   else
      f(i) = -3;
   end
      
end
