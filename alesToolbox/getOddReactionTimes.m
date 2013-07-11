function [reactionData] = getOddReactionTimes(projectInfo,optns)
%function pdOdd2Eeglab(projectInfo)
%
%Function to read powerdiva raw data and extract odd step reaction times.
%
%
%optns


%
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;

if isempty([allRaw.name])
    error(['Cannot find RAW, single trial exports, for subject: ' projectInfo.subjId])
end

condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');

%Finds unique condition numbers in the export directory.
condNum = unique(condAndTrialNum(1:2:end))';


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

  

for iCond = condNum,

%     condFilename = sprintf('Raw_c%0.3d_t*.mat',iCond);
%   
%     rawList = dir(fullfile(projectInfo.powerDivaExportDir,condFilename));
%     
%     for iRaw = 1:length(rawList),
%         
%         rawFiles{iRaw} = fullfile(projectInfo.powerDivaExportDir,rawList(iRaw).name);
%     end
% 
    
   
    iCond
%    [data info] = loadPDraw(rawFiles,0);
    clear dat paddedDat shiftedDat;

    [dat respTime condInfo] = sortOddStep(projectInfo.powerDivaExportDir,optns,iCond);
  
    reactionData.respTime{iCond} = respTime{1};
    reactionData.condInfo{iCond} = condInfo{1};
    

end


