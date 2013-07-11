function prepareInversesForMrc( projectDir )
%function prepareProjectForMne( [projectDir])

if ispref('freesurfer','SUBJECTS_DIR'),

    freesurfDir = getpref('freesurfer','SUBJECTS_DIR');
else
    disp('');
    disp('PREFERENCE SETTING FOR YOUR FREESURFER SUBJECT DIRECTORY NOT FOUND!');
    disp('PLEASE SET YOUR FREESURFER SUBJECTS DIRECTORY');
    disp('');
    disp('The preceeding message was brought to you in all caps to ensure that you would read it.');
    disp('...');
    disp('You probably didn''t read it anyway. Well don''t blame me when this script does not work.');
    disp('If you want to avoid this message in the future use the following:');
    disp('setpref(''freesurfer'',''SUBJECTS_DIR'',''/path/to/FREESURFER_SUBS/'')')
    
    freesurfDir = uigetdir('PICK FREESURFER SUBJECTS DIRECTORY');
end


if nargin ~= 1,
    projectDir = uigetdir('.','Pick your project directory')
end


matlabScriptDir =  which('prepareInversesForMrc.m');
[matlabScriptDir] = fileparts(matlabScriptDir);


subjectList = dir(projectDir);



for iSubj = 3:length(subjectList),
    
    if subjectList(iSubj).isdir==false;
        continue;
    end
    
    
    subjId = subjectList(iSubj).name;
    
    if strcmp(subjId,'skeri9999')
        display('Skipping skeri9999')
        continue;
    end
    
    
    if strncmp(subjId,'.',1)
        display(['skipping folder: ' subjId])
        continue;
    end
    
    logFile = fullfile(projectDir,subjId,'_dev_',['prepInvMrc_log_' datestr(now,'yyyymmdd_HHMM_FFF') '.txt']);
    diary(logFile)
    
    disp(['Processing Subject: ' subjId ])

    mneCovFileList = dir(fullfile(projectDir,subjId,'_MNE_','*-cov.fif'))
    
    
    if isempty(mneCovFileList)
        error('\n Cannot find MNE files, please run prepareProjectForMne');
    end

    mneCovFile = fullfile(projectDir,subjId,'_MNE_',mneCovFileList(1).name);
    mneDataFileName = [mneCovFileList(1).name(1:end-8) '.fif' ]
        
    mneDataFile = fullfile(projectDir,subjId,'_MNE_',mneDataFileName)
    if ~exist(mneCovFile,'file')
        error(['Cannot find an MNE covariance file' ]);
    end

    if ~exist(mneDataFile,'file'),
        error(['Cannot find find measurement file: ' mneDataFile]);
    end

    str2num(subjId(end-3:end))
    subjNum = str2num(subjId(end-3:end))
    
    SUBJECT=[subjId '_fs4'];

    srcSpaceFile = fullfile(freesurfDir,SUBJECT,'bem',[ SUBJECT '-ico-5p-src.fif']);
    if ~exist(srcSpaceFile,'file'),
        error(['Cannot find find source space file: ' srcSpaceFile]);
    end
    
    srcSpace = mne_read_source_spaces(srcSpaceFile);
    

    REG=fullfile(projectDir,subjId,'_MNE_','elp2mri.tran');
    ELEC=mneDataFile;
    COV=mneCovFile;
    
    outputDir = fullfile(projectDir,subjId,'_MNE_');
    
    FWDOUT=fullfile(outputDir,[subjId '-fwd.fif']);
    INVOUT=fullfile(outputDir,[subjId '-inv.fif']);

    shellCmdString = ['!' matlabScriptDir filesep 'skeriMNE ' SUBJECT ' ' REG ' ' ELEC ' ' COV ' ' FWDOUT ' ' INVOUT ];
    
    disp(['Executing shell command:'])
    disp(shellCmdString);
    eval(shellCmdString);

    SNR = 100; %Power SNR
    lambda2 = 1/SNR;
    
    [sol] = jmaMakeInv(FWDOUT,lambda2,srcSpace,[]);
    %[sol] = mneInv2EMSE(INVOUT,lambda2,false,srcSpace);
    
    mrcInvOutFile = fullfile(projectDir,subjId,'Inverses',['mneInv_bem_nonorm_jma_snr_' num2str(SNR) '.inv']);
      
    
    emseWriteInverse(sol,mrcInvOutFile);
    diary off

end