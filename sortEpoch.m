function [dat condInfo] = sortEpoch(dataDir,optns,condition)
%function [dat respTime condInfo] = sortOddStep(dataDir,optns)


if nargin<=1 || isempty(optns)
    optns.lowpass = false;
end

if nargin<=2 || isempty(condition)
    cList = dir(fullfile(dataDir,'Raw_c*_t001.mat'));
    
    condAndTrialNum = sscanf([cList.name],'Raw_c%d_t%d.mat');

    %Finds unique condition numbers in the export directory.
    condList =  unique(condAndTrialNum(1:2:end))';
else
    condList = condition;

end


condIdx = 1;
for iCnd=condList,


    [condData] = loadPowerDivaRaw(dataDir,iCnd);
    idx = 1;
    nOdd = 0;
    

    clear fullData;
    idx =1;

    for iTrial = 1:length(condData),


        nEpochs = condData{iTrial}.NmbEpochs; % # epochs to extract
        nEeg    = condData{iTrial}.NmbChanEEG;% # of eeg channels to read
        nPrelude = condData{iTrial}.NmbPreludeEpochs;


%         %Need to put in dummy info for pre and postlude steps in case
%         %pre/post odd step bins overlap with pre/postlude.
%         %
%         padding = repmat([0 0 0],nPrelude,1);
%         paddedOddStepData = [padding; condData{iTrial}.OddStepData; padding];
%         oddStepBin = paddedOddStepData(:,1);
%         oddStepTiming = paddedOddStepData(:,3);
% 
%         thisTrialResponseLabel = zeros(size(paddedOddStepData,1),1);
% 
%         % label trials according to hits/misses/false alarms/correct
%         % rejects
%         hitTrials  = paddedOddStepData(:,1) & paddedOddStepData(:,2);
%         missTrials = paddedOddStepData(:,1) & ~paddedOddStepData(:,2);
%         faTrials   = ~paddedOddStepData(:,1) & paddedOddStepData(:,2);
%         
%         crTrials   = ~paddedOddStepData(:,1) & ~paddedOddStepData(:,2);
% 
%         %discard prelude and postlude bins from counting for CR
%         crTrials([1:nPrelude (end-nPrelude+1:end)]) = false;
%        
%         % 1 == hits
%         % 2 == miss
%         % 3 == False alarm
%         % 4 == Correct reject
%         
%         thisTrialResponseLabel(hitTrials)  = 1;
%         thisTrialResponseLabel(missTrials) = 2;
%         thisTrialResponseLabel(faTrials)   = 3;
%         thisTrialResponseLabel(crTrials)   = 4;


        
        %Get this trials EEG data
        thisTrialEEG = condData{iTrial}.EEG(:,1:nEeg);
        
        

        if isfield(optns,'lowpass') && ~isempty(optns.lowpass) && optns.lowpass>0;
           display(['Lowpass filtering with cutoff freq: ' num2str(optns.lowpass)]);
            tst = preproc_lowpassfilter(thisTrialEEG',condData{1}.FreqHz,optns.lowpass);
            thisTrialEEG = tst';
        end
        
        if isfield(optns,'highpass') && ~isempty(optns.highpass) && optns.highpass ~=0,            
            tst = preproc_highpassfilter(thisTrialEEG',condData{1}.FreqHz,optns.highpass);
            thisTrialEEG = tst';
        end
        

        if iTrial == 1
%            nTotalEpochs = (nEpochs-2*nPrelude)*length(condData);
            nTotalEpochs = (optns.cyclesPerEpoch*nEpochs*nPrelude)*length(condData);
            nTime = size(thisTrialEEG,1)/(nEpochs*optns.cyclesPerEpoch);
            fullData = zeros(nTime,nTotalEpochs,nEeg);
            size(fullData)
            allTrialLabels = zeros(nTotalEpochs,1);  %Holds pre/odd/post label
            allTrialTiming = zeros(nTotalEpochs,1);  %Holds response time
            allTrialResponseLabel = zeros(nTotalEpochs,1);  %Holds label for subject response: hit/miss
            
            goodEpochLabel = zeros(nTotalEpochs,nEeg);
           % dat{iCnd} = zeros(3*nTime,nOdd,nEeg)
           CycleLen = size(condData{iTrial}.RawTrial,1)./(condData{iTrial}.NmbEpochs*optns.cyclesPerEpoch)
           
           optns.cyclesPerEpoch
            condInfo{condIdx} = rmfield(condData{iTrial},'RawTrial');
            condInfo{condIdx}.CycleLen = CycleLen;
        end



        %Cut the raw trial into a set of epochs, making a 3d matrix

        thisTrialByEpoch = reshape(thisTrialEEG,[],nEpochs*optns.cyclesPerEpoch,nEeg);

        %Choose Epochs that are NOT either the prelude or the postlude
        %validEpochs = (nPrelude+1):(nEpochs-nPrelude);
        %prelude Bins can be PRE bins for the odd step,
        %postlude bins can be post bins for the odd step. 
        %Therefore I don't cut out postlude or prelude. 
       
        validEpochs = optns.validEpochs;%1:nEpochs;

        thisTrialByEpoch =      thisTrialByEpoch(:,validEpochs,:);



%         oddStepEpochs = find(oddStepBin);
%         postOddStepEpochs = oddStepEpochs +1;
%         preOddStepEpochs = oddStepEpochs(oddStepEpochs>1) - 1;
% 

%         thisTrialEpochLabels = zeros(size(oddStepBin,1),1);


        %This order of labeling makes overwrites pre epochs if they are also a
%         %post epoch.
%         thisTrialEpochLabels(preOddStepEpochs) = 1;
%         thisTrialEpochLabels(postOddStepEpochs) = 3;
%         thisTrialEpochLabels(oddStepEpochs) = 2;
% 
% %        idx:idx+length(validEpochs)-1

        fullData(:,idx:idx+length(validEpochs)-1,:) = thisTrialByEpoch;

        epochList = (ceil(validEpochs/optns.cyclesPerEpoch));
        
        goodEpochLabel(idx:idx+length(validEpochs)-1,:) = condData{iTrial}.IsEpochOK(epochList,:)>0;

%         allTrialLabels(idx:idx+length(validEpochs)-1) = thisTrialEpochLabels;
%         allTrialTiming(idx:idx+length(validEpochs)-1) = oddStepTiming;
%         allTrialResponseLabel(idx:idx+length(validEpochs)-1) = thisTrialResponseLabel;
%         

        idx = idx+length(validEpochs);
    end
    clear condData;

%     allOddTrials = find(allTrialLabels==2);
%     allPostTrials = find(allTrialLabels==3);
%     oddTiming = allTrialTiming(allTrialLabels==2);
%     [y i] = sort(oddTiming);

%     preOddPostTrials = [allOddTrials-1, allOddTrials, allOddTrials+1]';


  
    
%     if isfield(optns,'selectByResponse') && ~isempty(optns.selectByResponse)
% 
% 
%         %Choose which trials to return.
% 
%         switch lower(optns.selectByResponse)
% 
%             case {'none','odd'}
%                 trialsToReturn = allOddTrials;
%                 usePreOddPost = true;
%             case {'all','nosort'}
%                 trialsToReturn = 1:length(allTrialLabels);
%                 usePreOddPost = false;
%             case {'notodd'}
%                 trialsToReturn = find(allTrialLabels~=2);
%                 usePreOddPost = false;
%             case {'hit','hits'}
%                 trialsToReturn = find(allTrialResponseLabel==1);
%                 usePreOddPost = true;
% 
%             case {'miss','misses'}
%                 trialsToReturn = find(allTrialResponseLabel==2);
%                 usePreOddPost = true;
% 
%             case {'fa','false alarm', 'false alarms'}
%                 trialsToReturn = find(allTrialResponseLabel==3);
%                 usePreOddPost = true;
% 
%                 disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%                 warning('FALSE ALARMS ARE DANGEROUS. PROGRAM LOGIC FOR RESPONSE TIMES IS QUESTIONABLE')
%                 disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% 
%             case {'cr', 'correct reject', 'correct rejects'}
%                 trialsToReturn = find(allTrialResponseLabel==4);
%                 usePreOddPost = true;
% 
%         end
% 
% 
% 
% 
%     else % All oddstep trials unsorted by subject response.
% 
%         trialsToReturn = allOddTrials;
%         usePreOddPost = true;
% 
%     end



    fullData = single(fullData);
    
    try
        dat{condIdx} = zeros(size(fullData,1),size(fullData,2),nEeg,'single');
    catch
        keyboard;
    end
    
    trialsToReturn=1:size(fullData,2);
    
    dat{condIdx} = fullData;
    


    condInfo{condIdx}.goodTrialLabel = goodEpochLabel(trialsToReturn,:);
%     condInfo{condIdx}.responseLabels = allTrialResponseLabel(trialsToReturn);
%     
   

    %    dat{iCnd} = preOddPostData;
    
%     respTime{condIdx} = allTrialTiming(trialsToReturn);
%     
     condIdx = condIdx+1;


    
    
end