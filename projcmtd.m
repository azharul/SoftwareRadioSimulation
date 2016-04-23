% projcmtd.m
clc
clear all
close all
% This parameter is used
% to simulate the frequency shifts
% e.g., due to a Doppler, i.e., relative movement
% it is quite close to 1 in this project.
freq_mult = 1/.994;

% This is the sampling frequency after downsampling 
% by 6 block just before the carrier recovery
% The block diagram is simulating the analog part
% which is then sampled. This corresponds to the output
% of the downsample by 6 block. From that point
% the processing is digital and its sampling frequency
% is defined below. This corresponds to 1/(T_symbol/4).

fs = 2000*freq_mult;

% This is the carrier frequency which should be 
% compensated by the carrier recovery algorithm
% the shifted frequency, e.g., due to a Doppler
fc = 500*freq_mult;

% This the carrier frequency which should be 
% compensated by the carrier recovery algorithm
% the non-shifted version
fc_prime = 500;

% This the ansolute bandwidth of the 
% raised cosine filter
B = 400;

% This the value of the frequency error
% before the carrier recovery
freq_off = fc - fc_prime;

% This is the sampling frequency T_symbol/24 
% which is used to simulate the analog signal
fsH = 6*fs;

% This is the carrier frequency at which 
% the signal is modulated and sent through
% the channel
fcH = 5/12*fsH;

% This is the intermediate frequency
% to which the initially modulated
% signal should be downconverted after
% the first bandpass filter BPF1
fiH = 2.5/12*fsH;


% A scaling factor is used in filter specifications
% to define frequency edges
fscal = .9;

% Half the sampling frequency of the signal
% transmitted through the channel
fNH = fsH/2;

% A phase offset which is used to define
% the possible shift in phase due to arrival
% delays
phase_offsetH = 1.2;

% 
fi_prime = 500;

% Sampling interval before time recovery
% after downsampling by 6 block
Ts = 1/fs;

% Sampling interval of the transmitted signal
TsH = 1/fsH;

% half of the number of symbols spanned by the
% transmit and receive filters
L = 4;

% oversampling factor in receiver algorithms
% 
M = 4;

% oversampling factor data-to-transmit data
MH = 24;

% parameter of the raised cosine
alpha = .1;

% 
t_offset = .3;
t_offsetH = 3*pi/2;

% one way of composing a message
msg = letters_to_pam4('asdlf asd;flk jasdkdfl;kdfl;kasdf;kasdfk;asdfka sbd;fkj d;kfj asdkfj a;dkfj a;dkj a;sldkj asl;dfk a;dkfj a;dkfj ;akldj a;sdkfj asl;dkja d;fkj s;fkFour score and seven years ago could not hit the broad side of a barn ECE hell bent for leather. yeah, down with Microsoft© ECE4953 the project is long! stuff... what you might not like even more is that homework 4 will be worse...');

% another way of composing a message
% by defining components
% and combining them. Note that training is used
% for the equalization and header is used to find the 
% message edges
header = letters_to_pam4('ECE4953 header sequence');
training = letters_to_pam4('ECE4953 training signal ECE4953 training signal ECE4953 training signal sdlkfjasdfkljas;fkljaslalk m,,mn,cvior,mnilg,knfviln,dkfvkl,ndkfglkdfgdfg,mnfdfg,khdgd;kjsd;kalsd;as;ld The quick brown fox jumped over the lazy dog.');
% english_text = ' down with Microsoft© ECE4953 header signal the project is hard! stuff...';
english_text = 'S M Azharul';
projmsg = letters_to_pam4(english_text);
randmsg1 = pam4(12000);
randmsg2 = pam4(1000);
randmsg3 = pam4(1000);

msg = [randmsg1 training randmsg2 header projmsg randmsg3];
orig = msg;

data_symbols = length(projmsg);

% This filter is used to simulate distortions in a channel
% normally it should be used after the upconversion 
% but here we may skip many zeros and still get a simulation
% of an intersymbol interference ISI
b = [.5 1 -.6];
%b = [.2 1 -.3];

% Apply the channel ISI distortions directly to our message
msg_prime= filter(b,1,msg);

% This pulse is generated to be used as a received filter
pulse = SRRC(L,alpha,M,t_offset);

% This pulse is generated to be used as a transmit filter
% its the same as "pulse" only sampling is different as they operate
% at different sampling frequencies. The important thing
% is that they span 8 symbol periods
pulseH = SRRC(L,alpha,MH,t_offsetH);
matched = pulse;
matchedH = pulseH;

% Pulse shaping for transmitted signal. Its implemented
% at highest sampling rate with period T_symbol/24
upsampled_msgH = zeros(1,MH*length(msg_prime));
upsampled_msgH(1:MH:end) = msg_prime;
pulse_shapedH = filter(pulseH,1,upsampled_msgH) * max(pulse)/max(pulseH);
figure;
subplot(3,2,1),nfspec(pulse_shapedH,fsH);
title('pulse-shaped signal (T/24)');

% The modulation of the pulse shaped signal
% simply multiply to a sinusoid at a carrier frequency
% Add phase offset distortion by the channel
t = TsH*[1:length(pulse_shapedH)];
upconverterH = cos(2*pi*fcH*t + phase_offsetH);
modulatedH = 2*pulse_shapedH.*upconverterH;
subplot(3,2,2),nfspec(modulatedH,fsH);
title('modulated signal (T/24)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% From this point we work with the receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Bandpass filter 1 is used to filter out undesired signals at frequencies
% other than expected. BPF1 only retains the band of the expected signal
% One can see that the bandwidth of size "fcH-B fcH+B" is retained
% it is slightly expanded by the factor fscal to accomodate
% possible imperfections of the designed filters
bpf1 = remez(100,[0 fcH-2*B fcH-B*fscal fcH+B*fscal fcH+2*B fNH]/fNH,[0 0 1 1 0 0]);
figure;
nfspec(bpf1,fsH);
title('BPF1'); xlabel('frequency');

% This line applies the BPF1 to the signal
bandpassedH = filter(bpf1,1,modulatedH);

% Here we downconvert the signal to intermediate
% frequency fiH
% For this purpose we first multiply to a 
% proper sinusoid and then filter by a bandpass
% filter BPF2
IFconverterH = cos(2*pi*(fcH-fiH)*t);
IFconvertedH = 2*bandpassedH.*IFconverterH;

% This filter is filtering out images other than those
% located around required intermediate frequency 2500Hz
bpf2 = remez(100,[0 fiH-2*B fiH-B*fscal fiH+B*fscal fiH+2*B fNH]/fNH,[0 0 1 1 0 0]);
figure;
nfspec(bpf2,fsH);
title('BPF2');

% Applying designed BPF2
IFbandpassedH = filter(bpf2,1,IFconvertedH);
figure(1);
subplot(3,2,3),nfspec(IFbandpassedH,fsH);
title('IF bandpassed signal (T/24)');

% Downsample the signal to process
% by carrier recovery algorithm
% Here the signal spaced around (+/-) 2500Hz
% IF frequency will be replicated and
% spaced at (+/-)500Hz 

for k = 2:6
    IFbandpassedH(k:MH/M:end) = 0;
end
subplot(3,2,4),nfspec(IFbandpassedH,fsH);
title('IF downsampled but undecimated signal (T/24)');

IFsampledH = IFbandpassedH(1:MH/M:end);
subplot(3,2,5),nfspec(IFsampledH,fs);
title('IF sampled signal (T/4)');


%%% The following lines before "save" are used
%%% to save a signal which can be used by digital
%%% processing part of the receiver, starting from the
%%% carrier recovery. Until this place
%%% we had a simulation of the analog signal (T_symbol/24 spacing) which was
%%% then sampled at T_symbol/4 spacing (using downsampling by 6 block)

modulated = IFsampledH;

rolloff_factor = alpha;
bandwidth = B;
training_signal = training;

%save test01.mat modulated fs fc_prime bandwidth rolloff_factor training_signal header msg data_symbols english_text;


% This is an implementation of a carrier recovery algorithm
% it is the analog of the one used in your HW but using Costas
% loops instead of PLL
% The next three lines find the corrected carrier
% The correction is obtained in "theta"
t = Ts*[1:length(modulated)];
theta = dual_costas_loop(modulated,fs,fc_prime,B);
downconverter = cos(2*pi*fc_prime*t + theta);

% Using a carrier found at the carrier recovery stage
% demodulate the signal. First multiply to the found sinusoid
% then filter out images. Note here that the sampling rate is
% 2000Hz and 1 corresponds to 1000Hz.
demodulated = modulated.*downconverter;
LPF = remez(50,[0 .25 .7 1],[1 1 0 0]);
reconstructed = filter(LPF,1,demodulated);

figure;
subplot(3,2,6),nfspec(reconstructed,fs);
title('reconstructed signal (T/4)');

% TODO:
% Apply time-recovery algorithm combined with the receive filter, i.e.
% Apply matched filter to signal "reconstructed" using "matched" array.
% Apply time recovery algorithm similar to the textbook version, e.g. it
% may look like this:
% match_filtered = trecvry(previous_step_array,L,alpha,M);

% TODO: comment the following line which is a combined matched filter and
% time recovery which is not studied by us.
match_filtered = opm(reconstructed,L,alpha,M);

% Apply equalizer to compensate the ISI distortion
% In LMS equalizer the training message location is found
% and the adaptation procedure is performed by comparing
% distorted training message with the known training
% message. The equalizer filter coefficients are found
% and the filter is applied to get equalized output
[equalized feq] = lmseq(match_filtered,training);

%quantized_msg = quantize4(match_filtered);
quantized_msg = quantize4(equalized);
figure;
plot(equalized,'.'); title('equalizer output level diagram');

% After finding the symbols the next task is to read
% the message by finding its beginning. This is achieved
% by correlating the signal with the known header
% Find the index which defines the start of the message

% this is how I have replaced xcorr with conv
xc = xcorr(quantized_msg,header);
xc2 = xcorr(msg,header);
[dummy,index] = max(abs(xc));
index
if xc(index) < 0
    xc = -xc;
    quantized_msg = -quantized_msg;
end
offset = length(quantized_msg) - length(header);
offset
figure; 
subplot(2,1,1),plot(1:length(xc(offset:end)),xc(offset:end)); ylabel('xcorr(received,header)');
subplot(2,1,2),plot(1:length(xc2(offset:end)),xc2(offset:end)); ylabel('xcorr(original,header)');

figure;
stem(conv(b,feq));
title('combined channel-equalizer response');

% Read the message from the identified "start of the message" index
decoded_msg = pam4_to_letters(quantized_msg(index-offset+1:index-offset+data_symbols))
