%% m-seq test

%Setup m-sequence 
order = 8;
nSampsPerStep = 4;
validSeeds = findmseqseed(order)
seed = validSeeds(1)
seqType = 2; %seqType = 2 is for -1/1 coding, seqType 1 is of 0/1
seq = genmseq(order,seed,seqType,1);
seq = double(seq);

if nSampsPerStep >1,
    extraSamps = zeros(nSampsPerStep-1,size(seq,2));
    seq = [seq;extraSamps];
    seq = seq(:);
end



%Setup a gabor impulse response
respLength = 100;
respOmega = 4;
respSigma =1;
respPhi =  2*pi/6;
respT = linspace(-pi,pi,respLength);
impResp = cos(respOmega*respT+respPhi).*exp(-(respT./respSigma).^2);
%impResp = exp(-(respT./respSigma).^2);

figure(42)
clf
subplot(2,1,1);
plot(impResp)


%Fake circular convolution by using a padded input sequence
% padSeq = double([seq seq seq]);
% output = conv(padSeq,impResp,'same');

%Better way is to do a circular convolution.
output = circonv(seq,impResp,length(seq));

validStart = length(seq)+1;
validEnd   = validStart + length(seq)-1;
%output = output(validStart:validEnd);


output = [zeros(1,nSampsPerStep) output];

%Fast M transform
fm = fastm(order,seed,output);

%Fix the output of the fastm to be interpretable like the impulse response.
[mfm ffm] = fixfastm(order,fm);
ffm = -ffm;

%For padded convolution
%shiftFFM = rotatevector(ffm,-fix(length(impResp)/2));

shiftFFM = rotatevector(ffm,-length(impResp));

plot(impResp,'k','linewidth',4)

hold on;
scaleFactor = (order);
plot(flipud(scaleFactor*shiftFFM(1:length(impResp))),'r--','linewidth',2)
legend('Impulse response', 'First order kernel from fast-M transform')
subplot(2,1,2);
plot(ffm)
legend('Full FastM transform response')



%% 
