 
%function simulate()

stimRates = [100 50 25 20 10 5 4 2 1];
%stimRates = [100 25 1];
stimRates = [25];
colorlist = { 'r' 'g' 'b' 'm' 'k' 'c' 'y' 'r' 'k'}
for iStim = 1:length(stimRates)
    
recordTime =70; %Approx desired recording time in seconds
tauOut = 100;%tauIn;%100; %response sampling rate in Hz

noiseLevel = .2;

nmbSmples = recordTime*tauOut;

%tauIn = 10; 
tauIn = stimRates(iStim);
mseqStepSize = 1/tauIn;

memory = round(.2*tauOut);%.1*tauOut;%memory length of the gain control in output samples
nonlin = false;

numStim = recordTime*(tauIn);%/mseqStepSize)%tauIn;

order = round(log2(numStim))


%order = 14;
seeds = findmseqseed(order);
seed  = seeds(end-1);

%data = linear(input,tauIn,tauOut);




upSampleFactor = tauOut/tauIn;%ceil(length(out)/(2^order-1))

tmp = zeros(1,length(input)*upSampleFactor);
input = double(genmseq(order,seed,1,1));
tmp = zeros(1,length(input)*upSampleFactor);

tmp(1:upSampleFactor:end) = input;
input = tmp;

%subfunction to simulate a linear system, tauIn is the input Sampling rate
% tauOut is the response sampling rate
%function out = linear(input,tauIn,tauOut)

tIn = (0:length(input)-1)/tauIn;
%tOut = (0:(length(input)-1)*tauOut/tauIn)/tauOut;

%tOut = (0:(length(input)-1))/tauOut;
tOut = [0:(length(ffm)-1)]/tauOut;
respLength = round(.2*tauOut); %response length in samples of tOut;
respLength = round(.5*tauOut); %response length in samples of tOut;



size(tIn)
size(tOut)
size(input)

nlIn = interp1(tIn,input,tOut,'nearest');
upIn = zeros(size(nlIn));

if (nonlin)
	for i =1:length(upIn),
		start = i-memory;

		if( start<1),
		previous = 1;
		average = 1;
		else

		previous = nlIn(start:i);
		average = mean(previous)+eps;
		end
		
		average = mean(previous)+eps;
		
		upIn(i) = nlIn(i)/average;
	end
else
upIn = nlIn;
end



figure(41)
hold on;
% %impulse = cos((tOut((1:respLength))-.1)*40).*exp(-(tOut((1:respLength))-.1).^2.*600);
impulse = exp(-(tOut((1:respLength))-.1).^2.*300);

%impulse = exp(-(tOut((1:respLength))-.25).^2.*90);

impulse(end/2:end) = -1*impulse(end/2:end) ;
impulse = impulse - mean(impulse);

plot(tOut(1:respLength),impulse,'r');

out = cconv(impulse,input,length(input));
out = out + noiseLevel*randn(size(out));
out = [zeros(1,upSampleFactor) out];

size(input)
% %out = conv(upIn,impulse);
% out = upIn;
% 
% out = out(1:length(tOut));
% noise = randn(size(out));
% out = out+0*noise;
% 
% 
% upSampleFactor = ceil(length(out)/(2^order-1))
% 
% out = simpleresample(out, (2^order - 1) * upSampleFactor);%65535*17);
% out = [zeros(1,upSampleFactor) out(1:((2^order-1)*upSampleFactor))'];
%figure

%plot(out)
%%
%out = [0 input];



fm = fastm(order,seed,out);
[mfm ffm] = fixfastm(order,fm);
%tm = linspace(1,2^order - 1, length(ffm));
tm = [0:(length(ffm)-1)]/tauOut;

figure(42)
subplot(2,1,1)
hold on;
plot(tm,ffm)
subplot(2,1,2)
hold on;
plot(tm,out(upSampleFactor+1:end),colorlist{iStim})


figure(43)
hold on;
plot(tm(1:101),ffm(end-100:end)*2^(order/2)+order,colorlist{iStim})
title(num2str(tauIn));

% rms(ffm(1:20))
% rms(ffm(30:end))
% 
% snr = rms(ffm(1:20))/rms(ffm(30:end))

 norm(ffm(1:20),2)
 norm(ffm(30:end),2)
 
% snr = norm(ffm(1:20),2)/norm(ffm(30:end),2)
snr(iStim) = (norm(ffm(end-50:end),2)/norm(ffm(1:51),2) -1)/tm(end);
noiseVar(iStim) = var(ffm(1:end-length(impulse)))/tm(end);
thisOrd(iStim) = order;

end
%system with luminance gain control


% %%
% 
% %Make sequences
% seeds10 = findmseqseed(10);
% seeds11 = findmseqseed(11);
% 
% 
% seq1 = double(genmseq(10,seeds10(1),2));
% seq2 = double(genmseq(11,seeds11(1),2));
% 
% numTrials = 2;
% noiseLevel = .1;
% stepLevel = 100;
% %Run trials
% for iTrial = 1:numTrials,
%     
%     %added gaussian noise to msequnce bits
%     data1 = seq1.*(randn(size(seq1))*noiseLevel+1); 
%     data1rep = seq1.*(randn(size(seq1))*noiseLevel+1);
%     data2 = seq2.*(randn(size(seq2))*noiseLevel+1);
%     
%     %data1(1) = data1(1)+stepLevel;
%     %data2(1) = data2(1)+stepLevel;
%     
%     %Do fast walsh transform
%     fm1 = fastm(10,seeds10(1),[0 data1]);
%     fm1rep = fastm(10,seeds10(1),[0 data1rep]);
%     fm2 = fastm(11,seeds11(1),[0 data2]);
%     
%     
%     %since the data is just the msequence the value we're interested in
%     %is the hight of the impulse in bin 2, (this is H1)
%     % bin 1 contains H0
%     shortSeqOnce(iTrial) = fm1(2);
%     shortSeqTwice(iTrial) = (fm1(2) + fm1rep(2))/2;
%     longSeq(iTrial) = fm2(2);
%     
%     
% end
% 
% 
% % Now comes the funny bussiness
% %these scaling factors make the impulses after the fastm come out to be the
% %same height
% %inside fastm.m we apply the scaling factor that makes the transform
% %invertable: 2^(order/2)
% 
% disp('Longer Sequence Mean')
% mean(longSeq*2^(-11/2))
% 
% disp('Short Sequence repeated Once mean')
% mean(shortSeqOnce*2^(-10/2))
% 
% disp('Short Sequence repeated twice mean')
% mean(shortSeqTwice*2^(-10/2))
% 
% disp('Variance for Longer sequence')
% var(longSeq*2^(-11/2))
% 
% 
% disp('Variance for shorter sequence repeated once')
% var(shortSeqOnce*2^(-10/2))
% 
% disp('Variance for shorter sequence repeated twice')
% var(shortSeqTwice*2^(-10/2))
% 
% 
% 
% 
% 
