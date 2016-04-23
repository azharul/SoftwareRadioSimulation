function f = opm(r,L,alpha,M)

r = r*sqrt(M);

mu = .01;

N = length(r);

tnow=L*M+1; tau=0; delta=0.01;                  % initialize variables
tausave=zeros(1,N); tausave(1)=tau; 
tsave=zeros(1,N); tsave(1)=tnow;
r_samp=zeros(1,round(N/4));


figure;

i=0;
while tnow<length(r)-2*L*M                        % implements algorithm
  i=i+1;
  h_tau=SRRC(L,alpha,M,tau)/sqrt(M);                % sample received signal
  h_delta=SRRC(L,alpha,M,tau+delta)/sqrt(M);        % sample at +/- delta
  r_temp=conv(r(tnow-L*M:tnow+L*M),h_tau);
  r_delta=conv(r(tnow-L*M:tnow+L*M),h_delta);
  r_samp(i)=r_temp(2*L*M+1);
  dr=r_delta(2*L*M+1)-r_temp(2*L*M+1);          % calculate derivative
  update=dr*r_samp(i).^3;                        % calculate update
  taunew=tau-mu*update;                         % algorithm step
  tnow=tnow+M; tsave(i)=tnow;                   % save for plotting
  tau=taunew; tausave(i)=taunew;
end
subplot(2,1,1), plot(r_samp(1:i-2),'b.')         % plot eye diagram
title('level diagram');
subplot(2,1,2), plot(tausave(1:i-2))             % plot trajectory of tau
title('offset estimates')
xlabel('iterations')

f = r_samp;