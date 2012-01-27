function pdRTseg2GLM(projectInfo,optns)
% pdRTseg2GLM(projectInfo,optns) - Parses a project directory to create an event file
% 
% Call this function from loopOverSubjs
%
% loopOverSubjects(@pdRTseg2GLM);
%
%Outputs files named e.g.: RTSeg_s001_c001.txt
%
%These files contain event timing structured depending on output format:
%
%Format: fsl:
%3 columns: [Event Start] [Event Duration] [Event Value]

outputDir = projectInfo.powerDivaExportDir;


%
%allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));
allRTSeg = dir(fullfile(projectInfo.powerDivaExportDir,'RTSeg_*.mat'));

%Note tricky use of [] to turn struct into 1 long string;
if isempty([allRTSeg.name])
    error(['Cannot find RT Segments exports (e.g. RTSeg_s001.mat), for subject: ' projectInfo.subjId])
end

%Validate input:
%if ~isfield(optns,'fieldName') || isempty(optns.fieldName)

if nargin<2;
    optns = struct;
    
end

if ~isfield(optns,'outputFormat') || isempty(optns.outputFormat)

    optns.outputFormat = 'fsl';
end

nSegs = length(allRTSeg);
     
     
 for iSeg = 1:nSegs,
     allRTSeg(iSeg).name
     
     thisRTSegFilename = fullfile(outputDir,allRTSeg(iSeg).name);
     RTSeg{iSeg} = load(thisRTSegFilename);
 
     if isempty(RTSeg{iSeg}.CndTiming) || isempty(RTSeg{iSeg}.TimeLine)
         disp(['SKIPPING RTSegment: ' num2str(iSeg) ' because it is EMPTY.']);
         continue;
     else
         disp(['Processing RTSegment: ' num2str(iSeg)]);
  
     end
     
     if isfield(optns,'nmbDummyScans') && ~isempty(optns.nmbDummyScans)
         dummyTimeOffset = optns.nmbDummyScans*RTSeg{iSeg}.SegmentInfo.TRSec;
           
         if strcmp(optns.outputFormat,'fsl')
             disp(['Correcting Scan start time to account for dummy scans: ' ...
                 num2str(optns.nmbDummyScans) ' TRs, for ' num2str(dummyTimeOffset) ' seconds']);
             
             RTSeg{iSeg}.SegmentInfo.startScanSec=RTSeg{iSeg}.SegmentInfo.startScanSec+dummyTimeOffset;
         end
         
         
     end
     
     conditionList =   [RTSeg{iSeg}.CndTiming.cndNmb]
     
     nUniqueConditions = length(unique(conditionList));
     
     
    
     allConditionTiming = [];
         for iCond = 1:nUniqueConditions,
             %Define PowerDiva Condition Number
             thisCondNmb = conditionList(iCond);
             %Define MATLAB index lookup for this PD condition number
             thisCondIdx = find(thisCondNmb==conditionList,1);
             
             
             
             %Calculate condition durations.
             %This requires some logic to figure out because of prelude/postlude possibilities
             %If prelude is BLANK:  Total trial duration = nmbOfSteps*Step Duration
             %If prelude is NOT Blank: total trial Duration needs to include prelude/postlude
             thisCondDuration = ...
                 RTSeg{iSeg}.CndTiming(thisCondIdx).nmbTrialSteps*RTSeg{iSeg}.CndTiming(thisCondIdx).stepDurSec;
             
             %if prelude is not BLANK add prelude/postlude to event duration
             if  RTSeg{iSeg}.CndTiming(thisCondIdx).preludeNotBlank
                 thisCondDuration = thisCondDuration ...
                     + RTSeg{iSeg}.CndTiming(thisCondIdx).preludeDurSec ...
                     + RTSeg{iSeg}.CndTiming(thisCondIdx).postludeDurSec;
             end
             
            
             
             conditionTimelineIdx =find([RTSeg{iSeg}.TimeLine.cndNmb]==thisCondNmb)
             
             nEvents = length(conditionTimelineIdx);
             eventTiming = zeros(nEvents,3);
             
             %Create condition onset list
             eventTiming(:,1) = [RTSeg{iSeg}.TimeLine(conditionTimelineIdx).segTimeSec]';
             
             
             %Adjust onset for difference between PD time base, and fMRI starting time
             eventTiming(:,1)=  eventTiming(:,1) - RTSeg{iSeg}.SegmentInfo.startScanSec;
             %if prelude BLANK add prelude duration to event START time
             %but need double negative because preludeNotBlank is FALSE when prelude is BLANK
             if  ~RTSeg{iSeg}.CndTiming(thisCondIdx).preludeNotBlank
                 eventTiming(:,1) = eventTiming(:,1) + RTSeg{iSeg}.CndTiming(thisCondIdx).preludeDurSec;
             end
             
             
             eventTiming(:,2) = thisCondDuration;
             %Code condition number in event
             eventTiming(:,3) = thisCondNmb;
             
             if strcmp(optns.outputFormat,'fsl')
                 %single value for FSL events for now
                 eventTiming(:,3) = 1;
                 outputFilename = sprintf('RTSegTime_s%.3d_c%.3d.txt',iSeg,thisCondNmb);
                 fullOutputFile = fullfile(outputDir,outputFilename);
                 save(fullOutputFile,'-ascii','eventTiming');                              
             end
         
             allConditionTiming = [allConditionTiming ;eventTiming];
             
         end
         
 
         if strcmp(optns.outputFormat,'freesurfer')
             outputFilename = sprintf('RTSegTime_s%.3d.par',iSeg);
             fullOutputFile = fullfile(outputDir,outputFilename);
             
             fsOutput = zeros(size(allConditionTiming));
             
             fsOutput(:,1) = allConditionTiming(:,1);
             fsOutput(:,2) = allConditionTiming(:,3);
             fsOutput(:,3) = allConditionTiming(:,2);
             fsOutput(:,4) = 1;
      
             save(fullOutputFile,'-ascii','fsOutput');
         end
         
     
 end
 
 
 

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
