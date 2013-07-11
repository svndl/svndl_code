%% 
nTrials = 1000;
nDprimes = 8;
nNumbers = 10;

dPrimes = linspace(.2,.99,nDprimes);

multNoise = [1 linspace(1,1.5,nNumbers-1)]';

[xGrid yGrid]=meshgrid(dPrimes,multNoise-1);

%noise = multNoise*dPrimes;
%noise = xGrid+yGrid;
noise = yGrid;
signalMeans = repmat([0:9]',1,nDprimes);

contData = zeros(10,nDprimes,nTrials);

% 
% for iDprime=1:nDprimes,
% 
%     for iNumber = 1:10,
%         number = iNumber-1;
% 
%         for iTrial=1:nTrials,
%             thisNoise = noise(iNumber,iDprime);
%             uniRand = rand-.5;
%             randomDraw = 2*sign(uniRand)*log(1-2*abs(uniRand));
%  %           randomDraw = poissrnd(1);
%           thisTrialSignal = thisNoise*randomDraw+number;
%             % thisTrialSignal =;
%             contData(iNumber,iDprime,iTrial) =  thisTrialSignal;   
%         end
% 
%     end
% end

lowB = -.0;
hiB = .0;

for iTrial=1:nTrials,
    normNoise = random('normal',0,noise);
    binoNoise = random('bino',signalMeans,repmat(dPrimes,nNumbers,1));
    uniNoise = random('uniform',lowB,hiB,size(noise));
%    contData(:,:,iTrial) = 0uniNoise+normNoise+signalMeans;
    contData(:,:,iTrial) = binoNoise+normNoise;
end

discreteData = round(contData);

simulatedResponses = zeros(10,nDprimes,10);
percentCorrect = zeros(10,nDprimes);
for iNumber=1:10,
    simulatedResponses(:,:,iNumber) = sum(discreteData==iNumber-1,3);
    percentCorrect(iNumber,:)=simulatedResponses(iNumber,:,iNumber)./nTrials;
end





%%

figure(1)

plot(log([1:9]),log(std(contData(2:end,:,:),[],3)./ mean(contData(2:end,:,:),3)))

figure(2)
hold off;
plot([0:9],percentCorrect)
axis([0 10 0 1.2])

figure(3)
plot(mean(contData(2:end,:,:),3))

%plot(std(contData(2:end,:,:),[],3))


