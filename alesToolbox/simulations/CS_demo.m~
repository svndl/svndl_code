%% cs test
nSamps = 1000;

t = linspace(0,2*pi,nSamps)';
k=1;
iS =15;

%Theoretical number of measurements required
fComps = 2:51;
nM = ceil(k*log(length(fComps)));


randCol = randperm(nSamps);
randCol = randCol(1:nM);

%fourierBasis = dftmtx(size(t,1));

%fourierBasis = [ real(fourierBasis(:,fComps)) imag(fourierBasis(:,fComps))];

ift = 2*conj(fourierBasis)/nSamps;


%sensingMatrix = [round(abs(sprand(size(t,1),nM,.5,.5))) [ones(size(t,1)/2,1); zeros(size(t,1)/2,1)]];
%sensingMatrix = [round(abs(sprand(size(t,1),nM,.5,.5)))];
%sensingMatrix = eye(size(t,1),nM);

%sensingMatrix = round(rand(size(t,1)));

fullD =1*((fourierBasis(:,iS))) + 0*((fourierBasis(:,50+iS)));

A = (sensingMatrix'*(fourierBasis));
%A = fourierBasis(:,1:nM)';

%D = A*fourierBasis(:,1:50)'*fullD;
D = sensingMatrix'*fullD;

n=size(A,2);

cvx_begin
    variable x(n);    
    minimize(norm(A*x-D,2)+norm(x,1) );
cvx_end

cvx_begin
    variable xl2(n);    
    minimize(norm(A*xl2-D,2)+norm(xl2,2) );
cvx_end

figure(52)
clf

%subplot(2,1,1)
plot(real(fullD),'--r','linewidth',5);
hold on

% plot(real(ift(:,1:50)*x),'k','linewidth',2);
% plot(real(ift(:,1:50)*xl2),'g','linewidth',2);

plot(real(fourierBasis(:,:)*x),'k','linewidth',2);
plot(real(fourierBasis(:,:)*xl2),'g','linewidth',2);

%plot(real(ift(:,1:50)*(pinv(A)*D)),'b')

[sI y] = find(sensingMatrix);
line([sI sI]', [ones(1,size(sI,1)); -ones(1,size(sI,1))],'linestyle','-.','color','k','linewidth',4)


subplot(2,1,2)
cla
plot(abs(x),'k')
hold on;
plot(2*abs(fourierBasis(:,:)'*fullD)/length(fullD))


