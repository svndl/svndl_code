function [responseData]=getOddResponseData(projectInfo,optns)
%function pdOdd2Eeglab(projectInfo)
%
outputDir = projectInfo.powerDivaExportDir;

allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;

if isempty([allRaw.name])
    error(['Cannot find RAW, single trial exports, for subject: ' projectInfo.subjId])
end

condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');

%Finds unique condition numbers in the export directory.
condNum = unique(condAndTrialNum(1:2:end))';
  

%responseData = cell(length(condNum),1);
responseData = struct([]);

for iCond = condNum,
   
    iCond
    
    %[dat respTime condInfo] = sortOddStep(projectInfo.powerDivaExportDir,optns,iCond);

    
    searchString = sprintf('Raw_c%.3i*',iCond);
    
    fileList = dir(fullfile(outputDir,searchString));
    
    if length(fileList)==0,
        
        error(['No files found for condition: ' num2str(iCond) ] )
    end
    
    responseData(iCond).cndNmb = iCond;
    responseData(iCond).OddStepData = [];
    
    for iTrial=1:length(fileList),
        
        thisFile = fullfile(outputDir,fileList(iTrial).name);
        
        tmp = load(thisFile,'OddStepData');
       
        responseData(iCond).OddStepData = [responseData(iCond).OddStepData; tmp.OddStepData];
        
        
    end
    
end


