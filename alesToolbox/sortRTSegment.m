function [fullData] = sortRTSegment(dataDir,optns,segmentList)


if nargin<=1 || isempty(optns)
optns = struct;
end

if nargin<=2 || isempty(segmentList)
    
    rtSegFileList = dir(fullfile(dataDir,'RTSeg_s*.mat'));

    error('Reading all segments not supported yet. Please specify which segment to read');
    return
%     condAndTrialNum = sscanf([cList.name],'Raw_c%d_t%d.mat');
%     %Finds unique condition numbers in the export directory.
%     condList =  unique(condAndTrialNum(1:2:end))';
end


rtSegIdx = 1;



for iSegment = segmentList,
    
    
    thisRtSegFilename = fullfile(dataDir,sprintf('RTSeg_s%.3d.mat',iSegment));
    
    if ~exist( thisRtSegFilename,'file');
        warning(['Cannot find RT segment file: ' thisRtSegFilename])
            
        continue;
    end
    
    
    rtSeg = load(thisRtSegFilename);
    
    
    if isempty(rtSeg.TimeLine)
        warning(['RT Segment: ' thisRtSegFilename ' contains 0 events']);
        continue;
    end
  
    
    
    nTrials = size(rtSeg.TimeLine,1);
    
    for iTrial = 1:nTrials,
                        
        rtSeg.TimeLine(iTrial).cndNmb;
        
        thisFile = fullfile(dataDir,sprintf('Raw_c%.3d_t%.3d.mat', rtSeg.TimeLine(iTrial).cndNmb, rtSeg.TimeLine(iTrial).trlNmb));
        
        tmp = load(thisFile);
        
        thisRaw =   double(tmp.RawTrial);
        thisShift = repmat(tmp.Shift',size(thisRaw,1),1);
        thisAmpl = repmat(tmp.Ampl',size(thisRaw,1),1);
        
        tmp.EEG = ( thisRaw + thisShift) .* thisAmpl;
        tmp.trialNumber = iTrial;
        tmp.origCndNmb = rtSeg.TimeLine(iTrial).cndNmb;
        tmp.origTrlNmb = rtSeg.TimeLine(iTrial).trlNmb;
        tmp.trialNumber = iTrial;
             
        fullData(iTrial) =tmp;
                
        
    end
end


