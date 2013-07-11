function dataset = concatPowerDivaRaw(fullDataCell,rejectBadEpochs);
%function dataset = concatPowerDivaRaw(fullDataCell,rejectBadEpochs);


nTrials = length(fullDataCell);


dataset = [];



sampsPerEpoch = size(fullDataCell{1}.RawTrial,1)/fullDataCell{1}.NmbEpochs;




for i=1:nTrials,
    tmp= fullDataCell{i};

    goodSampleList = 1:size(tmp.EEG,1);
  
    if(rejectBadEpochs)
        goodEpochList = prod(double(tmp.IsEpochOK'));
        
        isGoodSample = repmat(goodEpochList,sampsPerEpoch,1);
        goodSampleList = find(isGoodSample(:));
    end
    
    goodData = tmp.EEG(goodSampleList,:);
    
    dataset=[dataset;goodData];
    
    disp(num2str(i))
    
end

totalEpochNum = size(dataset,1)/sampsPerEpoch;


dataset = reshape(dataset',size(dataset,2),sampsPerEpoch,totalEpochNum);



