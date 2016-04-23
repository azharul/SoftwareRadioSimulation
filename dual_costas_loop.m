% convention here is that you add theta back into your demod time vector

function f = dual_costas_loop(r_if_filt,fs,fi,B);


fN = fs/2;      %fs=2000

td = (1:1:length(r_if_filt))/fs;

y_c = r_if_filt.*cos(2*pi*fi*td);       %fi=500
y_s = r_if_filt.*sin(2*pi*fi*td);

LPF = remez(100,[0 B 3*B/2 fN]/fN,[1 1 0 0]);

x_c = filter(LPF,1,y_c);
x_s = filter(LPF,1,y_s);

% Costas loop

theta=zeros(1,length(x_c));
v1=zeros(1,length(x_c));
v2=zeros(1,length(x_s));

theta2=zeros(size(theta));
w1 = zeros(size(v1));
w2 = zeros(size(v2));

mphi = 0:pi/8:2*pi;

guess = 2;

theta(1)=mphi(guess)+2*pi;

theta2(1)=theta(1);

mu1=0.03;
mu2=0.01;
mu2=0.003;

for k=1:length(x_c)
     v1(k)=x_c(k)*cos(theta(k))+x_s(k)*sin(theta(k));
     v2(k)=x_c(k)*sin(theta(k))-x_s(k)*cos(theta(k));
     theta(k+1)=theta(k)-mu1*v1(k)*v2(k);
     
     w1(k)=x_c(k)*cos(theta(k)+theta2(k))+x_s(k)*sin(theta(k)+theta2(k));
     w2(k)=x_c(k)*sin(theta(k)+theta2(k))-x_s(k)*cos(theta(k)+theta2(k));
     theta2(k+1)=theta2(k)-mu2*w1(k)*w2(k);     
end     


figure(11);
subplot(2,1,1),plot(theta); ylabel('theta1');
subplot(2,1,2),plot(theta2); ylabel('theta2');
xlabel('iteration');
f = -(theta(2:end)+theta2(2:end));

