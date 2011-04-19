 
%function simulate()

recordTime = 600; %Recording time in seconds
tauIn = 25; %stimlus sampling rate in Hz
tauOut = 100;%tauIn;%100; %response sampling rate in Hz

memory = round(.2*tauOut);%.1*tauOut;%memory length of the gain control in output samples
nonlin = false;


numStim = recordTime*tauIn;

order = round(log2(numStim))


%order = 14;
seeds = findmseqseed(order);
seed  = seeds(end-1);

input = double(genmseq(order,seed,1));

%data = linear(input,tauIn,tauOut);







%subfunction to simulate a linear system, tauIn is the input Sampling rate
% tauOut is the response sampling rate
%function out = linear(input,tauIn,tauOut)

tIn = (0:length(input)-1)/tauIn;
tOut = (0:(length(input)-1)*tauOut/tauIn)/tauOut;
respLength = round(.2*tauOut); %response length in samples of tOut;



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




%impulse = cos((tOut((1:respLength))-.1)*40).*exp(-(tOut((1:respLength))-.1).^2.*600);
%impulse = exp(-(tOut((1:respLength))-.1).^2.*300);
%out = conv(upIn,impulse);
out = upIn;

out = out(1:length(tOut));
noise = randn(size(out));
out = out+0*noise;


upSampleFactor = ceil(length(out)/(2^order-1))

out = simpleresample(out, (2^order - 1) * upSampleFactor);%65535*17);
out = [zeros(1,upSampleFactor) out(1:((2^order-1)*upSampleFactor))'];
%figure

%plot(out)

figure

fm = fastm(order,seed,out);
[mfm ffm] = fixfastm(order,fm);
tm = linspace(1,2^order - 1, length(ffm));
plot(tm,ffm)

title(num2str(tauIn));

% rms(ffm(1:20))
% rms(ffm(30:end))
% 
% snr = rms(ffm(1:20))/rms(ffm(30:end))

 norm(ffm(1:20),2)
 norm(ffm(30:end),2)
 
 snr = norm(ffm(1:20),2)/norm(ffm(30:end),2)




%system with luminance gain control



