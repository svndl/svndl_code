function [snr] = pdSpec2SNR(spec,harms)

nFreqs = length(spec);


amps = abs(spec);

noiseList = setdiff(2:nFreqs,harms);

idx = 1;
for iNoise = noiseList,

    if ismember(iNoise,harms) || ismember(iNoise+1,harms)
        continue;
    end

    if iNoise==1
        noiseLevelMean(idx) = mean(amps(iNoise:iNoise+1));
    elseif iNoise == nFreqs
        noiseLevelMean(idx) = mean(amps(iNoise-1:iNoise));
    else
        noiseLevelMean(idx) = mean( amps([iNoise iNoise+1]) );
    end
    idx = idx+1
end


resampIdx = round(linspace(1,length(noiseLevelMean),nFreqs));

amps = amps./noiseLevelMean(resampIdx);