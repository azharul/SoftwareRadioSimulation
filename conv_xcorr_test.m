clc
clear all
close all

a=randn(1,10);
b=randn(1,5);

c=xcorr(b,a)
d=conv(b,fliplr(a))
[M,I] = max(abs(c))
[M,I] = max(abs(d))

% d=fliplr(conv(fliplr(conj(a)),b))