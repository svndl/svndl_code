function pdRaw2FreqTag2GLM(projectInfo,optns)
%function pdRaw2FreqTag2GLM(projectInfo,optns)
%
%This function analyzes a 2 frequency tagged experiment and creates an 
%event structure suitable for GLM analysis of fMRI
%
%
%Specify tage frequencies in optns:
%  optns.freq1f1
%  optns.freq1f2
%
%optns.lowpass
%optns.highpass
%optns.lock2reaction
%optns.cndNumOffset


% Axx fields to fake:
% 
%          cndNmb: 2
%            nTrl: 25
%             nCh: 128
%              nT: 432
%             nFr: 108
%            dTms: 2.3125
%            dFHz: 0.5000
%            i1F1: 2
%            i1F2: 72
%     DataUnitStr: 'microVolts'
%            Wave: [432x128 double]
%             Cos: [108x128 double]
%             Sin: [108x128 double]
%             Amp: [108x128 double]
%             Cov: [128x128 double]

%outputDir = fullfile(projectInfo.projectDir,projectInfo.subjId,'_dev_');
outputDir = projectInfo.powerDivaExportDir;

%If no optns specified on call, initialize optns struct to empty
if nargin<2;
    optns = struct;   
end
%Find Raw data files and RT segment definitions
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));
allRTSeg = dir(fullfile(projectInfo.powerDivaExportDir,'RTSeg_*.mat'));

%Note tricky use of [] to turn struct into 1 long string;
if isempty([allRTSeg.name])
    error(['Cannot find RT Segments exports (e.g. RTSeg_s001.mat), for subject: ' projectInfo.subjId])
end

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;

if isempty([allRaw.name])
    error(['Cannot find RAW, single trial exports, for subject: ' projectInfo.subjId])
end

%Validate input:
if ~isfield(optns,'lock2reaction') || isempty(optns.lock2reaction)
    disp('Warning: optns.lock2reaction is not set. Defaulting to STIMULUS locked');
    optns.lock2reaction = false;
end

if  ~isfield(optns,'shuffleReactionTime') || isempty(optns.shuffleReactionTime)
    disp('Warning: optns.shuffleReactionTime is not set. Defaulting to REAL (correct) locked');
    optns.shuffleReactionTime = false;
       
end

%optns.lock2reaction == false ||

%optns.cndNumOffset

condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');

%Finds unique condition numbers in the export directory.
condNum = unique(condAndTrialNum(1:2:end))';

if nargin<2;
    optns = struct;
    
end

if ~isfield(optns,'outputFormat') || isempty(optns.outputFormat)

    optns.outputFormat = 'fsl';
end
optns.outputFormat = lower(optns.outputFormat);


nSegs = length(allRTSeg);
     
     
 for iSeg = 1:nSegs,
 
     
     
     thisRTSegFilename = fullfile(outputDir,allRTSeg(iSeg).name);
     RTSeg{iSeg} = load(thisRTSegFilename);
 
     if isempty(RTSeg{iSeg}.CndTiming) || isempty(RTSeg{iSeg}.TimeLine)
         disp(['SKIPPING RTSegment: ' num2str(iSeg) ' because it is EMPTY.']);
         continue;
     else
         disp(['Processing RTSegment: ' num2str(iSeg)]);
  
     end
     
     if isfield(optns,'newTRSec') && ~isempty(optns.newTRSec)
     dips(['Correcting TR value from: ' num2str(RTSeg{iSeg}.SegmentInfo.TRSec) ' to: ' num2str(optns.trueTRSec)]);
     RTSeg{iSeg}.SegmentInfo.TRSec = optns.trueTRSec;
     
     end


     if isfield(optns,'nmbDummyScans') && ~isempty(optns.nmbDummyScans)
         dummyTimeOffset = optns.nmbDummyScans*RTSeg{iSeg}.SegmentInfo.TRSec;
         
         if strcmp(optns.outputFormat,'fsl')
             disp(['Correcting Scan start time to account for dummy scans: ' ...
                 num2str(optns.nmbDummyScans) ' TRs, for ' num2str(dummyTimeOffset) ' seconds']);
         
             RTSeg{iSeg}.SegmentInfo.startScanSec=RTSeg{iSeg}.SegmentInfo.startScanSec+dummyTimeOffset;
         end
         
     end
     
     
%      conditionList =   [RTSeg{iSeg}.CndTiming.cndNmb]
%      
%      nUniqueConditions = length(unique(conditionList));
%      
%      for iCond = 1:nUniqueConditions,
%          %Define PowerDiva Condition Number
%          thisCondNmb = conditionList(iCond);
%          %Define MATLAB index lookup for this PD condition number
%          thisCondIdx = find(thisCondNmb==conditionList,1);
% 
% 
%          
%          %Calculate condition durations.  
%          %This requires some logic to figure out because of prelude/postlude possibilities
%          %If prelude is BLANK:  Total trial duration = nmbOfSteps*Step Duration 
%          %If prelude is NOT Blank: total trial Duration needs to include prelude/postlude
%          thisCondDuration = ...         
%              RTSeg{iSeg}.CndTiming(thisCondIdx).nmbTrialSteps*RTSeg{iSeg}.CndTiming(thisCondIdx).stepDurSec;
%          
%          %if prelude is not BLANK add prelude/postlude to event duration
%          if  RTSeg{iSeg}.CndTiming(thisCondIdx).preludeNotBlank
%              thisCondDuration = thisCondDuration ...
%                  + RTSeg{iSeg}.CndTiming(thisCondIdx).preludeDurSec ...
%                  + RTSeg{iSeg}.CndTiming(thisCondIdx).postludeDurSec;
%          end
%          
%          outputFilename = sprintf('RTSegTime_s%.3d_c%.3d.txt',iSeg,thisCondNmb);       
%          fullOutputFile = fullfile(outputDir,outputFilename);
%          
%          conditionTimelineIdx =find([RTSeg{iSeg}.TimeLine.cndNmb]==thisCondNmb)
%          
%          nEvents = length(conditionTimelineIdx);
%          eventTiming = zeros(nEvents,3);
%          
%         
%          eventTiming(:,1) = [RTSeg{iSeg}.TimeLine(conditionTimelineIdx).segTimeSec]';
%          
%          %if prelude BLANK add prelude duration to event START time
%          %but need double negative because preludeNotBlank is FALSE when prelude is BLANK
%          if  ~RTSeg{iSeg}.CndTiming(thisCondIdx).preludeNotBlank
%                  eventTiming(:,1) = eventTiming(:,1) + RTSeg{iSeg}.CndTiming(thisCondIdx).preludeDurSec;                
%          end
%      
%          
%          eventTiming(:,2) = thisCondDuration;
%          %single value for event for now
%          eventTiming(:,3) = 1;
%          
%         save(fullOutputFile,'-ascii','eventTiming');
         
 %    end
     
     
     [fullData] = sortRTSegment(projectInfo.powerDivaExportDir,optns,iSeg);
     nTrials = length(fullData);
     
     buttonTiming = [];
     for iTrial = 1:nTrials,
     
         %Adjust events for this trials start time adjusted for difference between fMRI start and PowerDiva start
         thisTrialStartTime=RTSeg{iSeg}.TimeLine(iTrial).segTimeSec - RTSeg{iSeg}.SegmentInfo.startScanSec;
         
         %Placeholder for button logic
         if true

             buttonData = fullData(iTrial).EEG(:,end);
             
             [ eventIndices eventDurationSamp eventValues] = findEventEdges( buttonData );
             
             %Event times in seconds from start of RT segment.
             eventTimes = (eventIndices-1)/fullData(iTrial).FreqHz + thisTrialStartTime;
             %Event durations in seconds
             eventDurationsSec = eventDurationSamp/fullData(iTrial).FreqHz;
             %Renumber Events do be the same of PowerDiva's DIN numbering
             eventMinus = eventValues<0;
             eventPlus  = eventValues>0;
             eventValues(eventMinus) = 1;
             eventValues(eventPlus) = 2;
             
             %Construct table of button timings/durations/values from segment start;
             buttonTiming = [buttonTiming; ...
                 eventTimes' eventDurationsSec' eventValues'];
             

         end
        
  
         
     end
     
 
     
     %placeholder for EEG logic 
     if true
     
     data = cat(1,fullData(:).EEG);
     
     windowSize = size(fullData(1).EEG,1)/fullData(1).NmbEpochs;
       
     projData = zeros(fullData(1).NmbChanEEG,windowSize/2+1,size(data,1)/windowSize);
       
     for iElec = 1:fullData(1).NmbChanEEG,
         
         [S F T] = spectrogram(data(:,iElec),rectwin(windowSize),0,windowSize,fullData(1).FreqHz);
         

         for iFr=1:size(S,1),
             meanPh(iFr) = mean(S(iFr,:))/abs(mean(S(iFr,:)));
             projData(iElec,iFr,:) = real(S(iFr,:)*meanPh(iFr)');
         end
         
         
     end
     
     %optns.sigFreq

     snr = squeeze(mean(mean(projData(:,[optns.i1f1 optns.i1f2],:),3),2)./mean(mean(projData(:,[optns.i1f1-1 optns.i1f2+1],:),3),2));
     
%     [~, maxElec] = max(snr)

maxElec = optns.elec2Use;

     T = T+RTSeg{iSeg}.TimeLine(1).segTimeSec;
     eegDuration = mean(diff(T))*ones(size(T));
     
     if strcmp(optns.outputFormat,'freesurfer')

         fsOutput = zeros(length(T),4);

         fsOutput(:,1) = T;
         fsOutput(:,2) = 1;
         fsOutput(:,3) = eegDuration;
         fsOutput(:,4) = 1e3*projData(maxElec,optns.i1f1,:);
         
      
         outputFilename = sprintf('RTSegTime_s%.3d_i1f1.par',iSeg);
         fullOutputFile = fullfile(outputDir,outputFilename);
         save(fullOutputFile,'-ascii','fsOutput');
         
         
         
         fsOutput = zeros(length(T),4);

         fsOutput(:,1) = T;
         fsOutput(:,2) = 1;
         fsOutput(:,3) = eegDuration;
         fsOutput(:,4) = 1e3*projData(maxElec,optns.i1f2,:);
         
      
         outputFilename = sprintf('RTSegTime_s%.3d_i1f2.par',iSeg);
         fullOutputFile = fullfile(outputDir,outputFilename);
         save(fullOutputFile,'-ascii','fsOutput');
         
         
         fsOutput = zeros(length(T),4);

         fsOutput(:,1) = T;
         fsOutput(:,2) = 1;
         fsOutput(:,3) = eegDuration;
         fsOutput(:,4) = 1e3*(projData(maxElec,optns.i1f1,:)-projData(maxElec,optns.i1f2,:));
         
      
         outputFilename = sprintf('RTSegTime_s%.3d_2FDiff.par',iSeg);
         fullOutputFile = fullfile(outputDir,outputFilename);
         save(fullOutputFile,'-ascii','fsOutput');
 
                 fsOutput = zeros(length(T),4);

         fsOutput(:,1) = T;
         fsOutput(:,2) = 1;
         fsOutput(:,3) = eegDuration;
         fsOutput(:,4) = 1e3*(projData(maxElec,optns.i1f1,:)+projData(maxElec,optns.i1f2,:));
         
      
         outputFilename = sprintf('RTSegTime_s%.3d_2FSum.par',iSeg);
         fullOutputFile = fullfile(outputDir,outputFilename);
         save(fullOutputFile,'-ascii','fsOutput');
         
 
         
     end
     
     end
 
     
     uniqueBtnCodes = unique(buttonTiming(:,3));

  
     
  if strcmp(optns.outputFormat,'fsl')
     for iCode = 1:length(uniqueBtnCodes),
         btnVal = uniqueBtnCodes(iCode);
         if btnVal ==0
             continue;
         end
         
         btnIdx = buttonTiming(:,3)==btnVal;
         
         thisBtnValTiming = buttonTiming(btnIdx,:);
         outputFilename = sprintf('RTSegTime_s%.3d_btnVal%.3d.txt',iSeg,btnVal);
         fullOutputFile = fullfile(outputDir,outputFilename);
         save(fullOutputFile,'-ascii','thisBtnValTiming');
         
     end
  elseif strcmp(optns.outputFormat,'freesurfer')
      
      outputFilename = sprintf('RTSegTime_s%.3d_button.par',iSeg);
      fullOutputFile = fullfile(outputDir,outputFilename);
      
      
      fsOutput = zeros(size(buttonTiming));
      
      fsOutput(:,1) = buttonTiming(:,1);
      fsOutput(:,2) = buttonTiming(:,3);
      fsOutput(:,3) = buttonTiming(:,2);
      fsOutput(:,4) = 1;
      
      save(fullOutputFile,'-ascii','fsOutput');
  end
  
     
end



