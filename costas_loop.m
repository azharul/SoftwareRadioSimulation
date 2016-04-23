%% This is a conentional costas loop
function f = costas_loop(r_if_filt,fs,fi,B);
fN = fs/2;
td = (1:1:length(r_if_filt))/fs;
y_c = r_if_filt.*cos(2*pi*fi*td);
y_s = r_if_filt.*sin(2*pi*fi*td);
LPF = remez(40,[0 B 3*B/2 fN]/fN,[1 1 0 0]);
x_c = filter(LPF,1,y_c);
x_s = filter(LPF,1,y_s);
theta=zeros(1,length(x_c));
v1=zeros(1,length(x_c));
v2=zeros(1,length(x_s));
mphi = 0:pi/8:2*pi;
guess = 2;
theta(1)=mphi(guess)+2*pi;
mu1=0.3;
for k=1:length(x_c)
     v1(k)=x_c(k)*cos(theta(k))+x_s(k)*sin(theta(k));
     v2(k)=x_c(k)*sin(theta(k))-x_s(k)*cos(theta(k));
     theta(k+1)=theta(k)-mu1*v1(k)*v2(k);    
end     
f= -theta(2:end);