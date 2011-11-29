function pdRTseg2GLM(projectInfo,optns)
%function pdOdd2Eeglab(projectInfo)
%
%Function to take powerdiva raw data and read it into EEGlab.
%
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


%
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

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


 if ~isfield(optns,'cndNum2Sort') && isempty(optns.cndNum2Sort)
     
     
     condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');
     
     %Finds unique condition numbers in the export directory.
     condNum = unique(condAndTrialNum(1:2:end))';
 else
     condNum = optns.cndNum2Sort;
 end
 
     
     
 for
 
     
     
     
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
