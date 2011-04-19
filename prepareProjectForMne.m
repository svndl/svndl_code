function prepareProjectForMne( projectDir )
%function prepareProjectForMne( [projectDir])


if nargin ~= 1,
    projectDir = uigetdir('.','Pick your project directory');
end

if projectDir == false,
    
    error('Canceled by user!')
end

subjectList = dir(projectDir);

if exist('nearpoints') ~= 3,
    disp('-----------------------------------------------')
    disp('Please run:')
    disp('addVISTASOFT_DEVEL')
    disp('-----------------------------------------------')
    error('NEARPOINTS MEX NOT FOUND, SEE ABOVE MESSAGE')
end



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

    disp(['Processing subject: ' subjId ])

    PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));

    
    ELPname = dir(fullfile(projectDir,subjId,'Polhemus','*Edited.elp'));
    
    validNames = ~strncmp({ELPname(:).name},'.',1);
    ELPname=ELPname(validNames);
    
    if isempty(ELPname),
        
        ELPname = dir(fullfile(projectDir,subjId,'Polhemus','*.elp'));

        validNames = ~strncmp({ELPname(:).name},'.',1);
        ELPname=ELPname(validNames);
    
        if isempty(ELPname),
            error(['\n Subject: ' subjId ' does not have Polhemus file']);           
        else 
            display(['Using file: ' ELPname(1).name]);
        end
        
    else
        display(['Found edited ELP file, using file: ' ELPname(1).name ]);
    end
        
    elpFile = fullfile(projectDir,subjId,'Polhemus',ELPname(1).name);

    
    if isempty(PDname)
        error('\n Cannot find EMSE Export, please add data');
    end      


    powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name);
    
    
    outputDir = fullfile(projectDir,subjId,'_MNE_');

    if ~exist(powerDivaExportDir,'dir'),
        error(['Cannot find EMSE Export, please add data: ' PDname ]);
    end

    if ~exist(elpFile,'file'),
        error(['Cannot find Polhemus file, please add elp file']);
    end

    if ~exist(outputDir,'dir'),
        error(['Cannot find output directory, please create: ' outputDir ]);
    end

    str2num(subjId(end-3:end))
    subjNum = str2num(subjId(end-3:end))
    fig = figure(iSubj);
    clf;
    hold on;
    
    preparePowerDivaForMne( subjId, powerDivaExportDir, elpFile,outputDir)
       

end


display('Done importing data into MNE')
display('Ready to make inverses')








