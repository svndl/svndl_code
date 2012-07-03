function [data] = readRlsTxt(projectInfo,optns)


outputDir = projectInfo.powerDivaExportDir;

%
allRls = dir(fullfile(projectInfo.powerDivaExportDir,'RLS_*.txt'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;

if isempty([allRls.name])
    error(['Cannot find RLS text exports, for subject: ' projectInfo.subjId])
end

%Validate input:

if  ~isfield(optns,'shuffleReactionTime') || isempty(optns.shuffleReactionTime)
       
end

%optns.lock2reaction == false ||

%optns.cndNumOffset


 if ~isfield(optns,'cndNum2Sort') || isempty(optns.cndNum2Sort)
     
     
     condNum = sscanf([allRls.name],'RLS_c%d.txt');
     
     %Finds unique condition numbers in the export directory.
     condNum = unique(condNum)';
 else
     condNum = optns.cndNum2Sort;
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

  

for iCond = condNum,


 disp( ['Loading condition: ' num2str(iCond) ' from file: ' allRls(iCond).name]);
        
thisFilename = fullfile(projectInfo.powerDivaExportDir,allRls(iCond).name);
[data(iCond) header1] = importRlsTxt(thisFilename);





end



