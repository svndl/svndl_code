function [dataset info] = loadPDraw(filenameList,rejectBadEpochs);
%function [dataset info] = loadPDraw(filenameList,rejectBadEpochs);


nFiles = length(filenameList);

headerInfo = load(filenameList{1});


dataset = [];



for i=1:nFiles,
    tmp= load(filenameList{i});

    tmp.CycleLen = size(tmp.RawTrial,1)./tmp.NmbEpochs;
    goodSampleList = 1:size(tmp.RawTrial,1);
    if(rejectBadEpochs)
        goodEpochList = sum(double(tmp.IsEpochOK'));
        goodEpochList = goodEpochList>8;
        isGoodSample = repmat(goodEpochList,tmp.CycleLen,1);
        goodSampleList = find(isGoodSample(:));
    end

   
   %For data sets with button even info in channel 131 -- else functions as normal for 128 channel sets 
	if(length(tmp.Ampl)==131)
		if i==1,        
			dataset = zeros(length(tmp.Ampl)-2,size(tmp.RawTrial,1)*nFiles);
			idx = 1:length(goodSampleList);
        
			%info is everything but the rawtrial data
			info = rmfield(tmp,'RawTrial');

		end
		
		goodData = double(tmp.RawTrial(goodSampleList,[1:128 131]));
		thisShift = repmat(tmp.Shift([1:128 131],1)',size(goodData,1),1);
		thisAmpl = repmat(tmp.Ampl([1:128 131],1)',size(goodData,1),1);
		goodData = ( goodData + thisShift) .* thisAmpl;
		dataset(:,idx)=[goodData(:,1:length(tmp.Ampl)-2)'];
	else
		if i==1, 
			
			dataset = zeros(tmp.NmbChanEEG,size(tmp.RawTrial,1)*nFiles);
			idx = 1:length(goodSampleList);
            thisIdx =[1:length(goodSampleList)];

			%info is everything but the rawtrial data
			info = rmfield(tmp,'RawTrial');
            
        else
            thisIdx = lastStop+[1:length(goodSampleList)];
        end
	
		goodData = double(tmp.RawTrial(goodSampleList,:));
	    thisShift = repmat(tmp.Shift',size(goodData,1),1);
		thisAmpl = repmat(tmp.Ampl',size(goodData,1),1);
    	goodData = ( goodData + thisShift) .* thisAmpl;
        
        if ~isempty(goodData),
            dataset(:,thisIdx )=[goodData(:,1:tmp.NmbChanEEG)'];
            lastStop = thisIdx(end);

        end
	end


    
    disp(num2str(i))
    
end

thisIdx(end)

if thisIdx(end) < size(dataset,2),
    dataset = dataset(:,1:(thisIdx(end)));
end


