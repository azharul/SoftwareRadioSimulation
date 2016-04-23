% NFSPEC plots the magnitude spectrum of the input vector
%
% NFSPEC is useful when used in tandem with a call to FFT like 
% fft_vector = FFT(sampled_fcn)
%
% usage: nfspec(fft_vector, sample_rate)
%
% fft_vector  - the result returned by the FFT function
% sample_rate - the distance in time between the entries in sampled_fcn


function fcn = nfspec(vector, sample_rate)

fft_vector = fft(vector);

bin_number = length(fft_vector);

P = fft_vector.*conj(fft_vector) / bin_number;

P = abs(fft_vector);

if mod(bin_number,2) == 0,
   f_pos = sample_rate*(0:floor(bin_number/2)-1)/bin_number;
   f_neg = -fliplr(f_pos) - 1/bin_number;
   plot([f_neg f_pos],sqrt([P(bin_number/2 + 1:length(P)) P(1:bin_number/2)]));
else 
   f_pos = sample_rate*(0:floor(bin_number/2))/bin_number;
   f_neg = sample_rate*(-floor(bin_number/2)-1:-1)/bin_number;
   plot([f_neg f_pos],sqrt([P(floor(bin_number/2):length(P)) P(1:floor(bin_number/2))]));
end
axis([f_neg(1) f_pos(end) 0 1.2*max(sqrt(P))]);