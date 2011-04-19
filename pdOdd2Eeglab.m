function pdOdd2Eeglab(projectInfo)
%function pdOdd2Eeglab(projectInfo)
%
%Function to take powerdiva raw data and read it into EEGlab.
%
%

  
outputDir = fullfile(projectInfo.projectDir,projectInfo.subjId,'_dev_');


%
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;
condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');

%Finds unique condition numbers in the export directory.
condNum = unique(condAndTrialNum(1:2:end))';

  

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
    
   
    
%    [data info] = loadPDraw(rawFiles,0);
    optns.lowpass = false;

    [dat respTime condInfo] = sortOddStep(projectInfo.powerDivaExportDir,optns,iCond);
  
    %Hacky multiplier, fix this ---JMA
    data = 1e6*shiftdim(dat{1},2);
    data = data(:,:);
    epch = 1000*(respTime{1}+1); %Response time in ms;
  
    EEG = pop_importdata( 'dataformat', 'array', 'data', data, 'srate',condInfo{1}.FreqHz,...
        'pnts',condInfo{1}.CycleLen, 'xmin',0, 'nbchan',0);
    
    EEG.setname=[projectInfo.subjId '_odd_c' num2str(iCond,'%0.3d')];
    
    EEG = eeg_checkset( EEG );
    EEG = pop_importepoch( EEG, epch, { 'RT'}, 'timeunit',0.001, 'headerlines',0, 'clearevents', 'off');
    EEG = eeg_checkset( EEG );
    
    EEG = pop_saveset( EEG, 'filepath',outputDir,'filename',[EEG.setname '.set'], 'savemode', 'onefile');

end


