function condInfo=pdRaw2Eeglab(projectInfo,optns)
%function pdRaw2Eeglab(projectInfo)
%
%Function to take pdRaw data and read it into EEGlab.
%
%

rejectBadEpochs = false; %Defaults to returning ALL epochs;

  
outputDir = fullfile(projectInfo.projectDir,projectInfo.subjId,'_dev_');


%
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;
condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');

%Finds unique condition numbers in the export directory.
condNum = unique(condAndTrialNum(1:2:end))';

condInfo = {};  

for iCond = condNum,

    condFilename = sprintf('Raw_c%0.3d_t*.mat',iCond);
    rawList = dir(fullfile(projectInfo.powerDivaExportDir,condFilename));

    
    for iRaw = 1:length(rawList),
        
        rawFiles{iRaw} = fullfile(projectInfo.powerDivaExportDir,rawList(iRaw).name);
    end

    
   
    
    [data info] = loadPDraw(rawFiles,rejectBadEpochs);
    %Hacky multiplier, fix this ---JMA
    data = 1e6*data;
    
	condInfo{iCond} = info;
    

    
    EEG = pop_importdata( 'dataformat', 'array', 'data', data, 'srate',info.FreqHz,...
        'pnts',info.CycleLen, 'xmin',0, 'nbchan',0);
    
    EEG.setname=[projectInfo.subjId '_c' num2str(iCond,'%0.3d')];
    EEG = eeg_checkset( EEG );
	
	if ~exist(outputDir,'dir')
		[success, msg] = mkdir(outputDir);
	
		if ~success
			disp(msg)
			error('Error making output dir');
		end
		
	end
	
		
    EEG = pop_saveset( EEG, 'filepath',outputDir,'filename',[EEG.setname '.set'], 'savemode', 'onefile');

end


