function [results] = freqDomainCVX(Achunk,thisData,options),
% function [results] = invokeCVX(Achunk,thisData),
% This function takes the forward model and invokes CVX to solve the l1 optim problem   

n = size(Achunk,2);


cplxData = complex(thisData.Cos,thisData.Sin);

nFreqs = thisData.nFr;


f1Harm = options.harmList1f1*thisData.i1F1;
f2Harm = options.harmList1f2*thisData.i1F2;

freqList = unique(sort([f1Harm f2Harm]+1))

%freqList = freqList([1 2]);



nHarmonics = length(freqList);

fData = cplxData(freqList,:)';


lamMax = norm(2*(Achunk'*fData),inf);

lambda =.005*lamMax;



cvx_begin
  variable x(n,nHarmonics) complex
  cvx_precision default
  minimize( norm(Achunk*x-fData,'fro')+lambda*norm(x,1));
  %+mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
  %minimize(norm(x,1))
  %subject to
  %     abs(x)<=1.2
  %      norm(Achunk*x-data,'fro')<=1.2
  %      norm(Achunk*x-data,'fro')>=1.13
  %      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
  %      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end

norm(Achunk*x-fData,2)
norm(Achunk*x-fData,'fro')

results = x;


