function loadInEeglab( projectInfo,varargin )
%function prepareProjectForMne( [projectDir])
%optns.nComps



projectDir = projectInfo.projectDir;
subjId = projectInfo.subjId;

PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));
powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name);       
  
datadir = fullfile(projectDir,subjId,'_dev_');
    
filename = varargin{1}{1};
filename = [subjId filename];



%I really hate these evalin lines.....

%evalin('base','[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);');

evalin('base',[ 'EEG = pop_loadset( ''filename'', ''' filename ''' , ''filepath'', ''' datadir ''' );']);

evalin('base','EEG = eeg_checkset( EEG );');

evalin('base','[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);');
