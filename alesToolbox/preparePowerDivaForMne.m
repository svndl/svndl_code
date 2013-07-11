function preparePowerDivaForMne( subjId, powerDivaExportDir, elpFile, outputDir )
%function preparePowerDivaForMne( subjId, powerDivaExportDir, elpFile, outputDir )


if ~exist('outputDir','var')

    outputDir = '.';
end


chooseDirPopup = true;

if ispref('freesurfer','SUBJECTS_DIR'),
    freesurfDir = getpref('freesurfer','SUBJECTS_DIR');

    if ~exist(freesurfDir,'dir')
        chooseDirPopup = true;
    else
        chooseDirPopup = false;
    end
    
end


if chooseDirPopup
%     disp('');
%     disp('PREFERENCE SETTING FOR YOUR FREESURFER SUBJECT DIRECTORY NOT FOUND!');
%     disp('PLEASE SET YOUR FREESURFER SUBJECTS DIRECTORY');
%     disp('');
%     disp('The preceeding message was brought to you in all caps to ensure that you would read it.');
%     disp('...');
%     disp('You probably didn''t read it anyway. Well don''t blame me when this script does not work.');
    
 
    msgStr = ['PREFERENCE SETTING FOR YOUR FREESURFER SUBJECT DIRECTORY NOT FOUND!\n' ...
        'PLEASE SET YOUR FREESURFER SUBJECTS DIRECTORY\n\n' ...
        'The preceeding message was brought to you in all caps to ensure that you would read it.\n' ...
        'You probably didn''t read it anyway. Well don''t blame me when this script does not work.'];

    H = warndlg(sprintf(msgStr));
    waitfor(H);
    
    freesurfDir = uigetdir('PICK FREESURFER SUBJECTS DIRECTORY');
    
    if freesurfDir == false,
        error('Analysis cancelled by user!');

    end
    
    disp('If you want to avoid that message in the future use the following:'); 
%    disp('setpref(''freesurfer'',''SUBJECTS_DIR'',%s)',freesurfDir)

    
end


subjDir = fullfile(freesurfDir,[subjId '_fs4']);


if ~exist(subjDir,'dir')
    msg = sprintf('Subject: %s not found in directory: %s\n Thank You, Please Play Again.\n',subjId,freesurfDir);
    error(msg);
end

if ~exist(powerDivaExportDir,'dir')
    msg = sprintf('Cannot find Export directory: %s\n Thank You, Please Play Again.\n',powerDivaExportDir);
    error(msg);
end

exportFileList = dir(fullfile(powerDivaExportDir,'Axx_*.mat'));

if isempty(exportFileList)
    msg = sprintf('No .mat diva exports found in: %s\n Thank You, Please Play Again.\n',powerDivaExportDir);
    error(msg);
end
  

fiducialFile = fullfile(subjDir,'bem',[subjId '_fiducials.txt']);

if ~exist(fiducialFile,'file')
    msg = sprintf('Cannot find fiducial location file: %s\n Skipping subject: %s\n',fiducialFile, subjId);
    warning(msg);
    clf
    colordef(gcf,'none')
    whitebg(gcf,[.75 0 0 ])
    set(gcf,'name',subjId)
    text(0, .1,msg,'fontsize',24)
    axis off;
    return;
end

headSurfFile = fullfile(subjDir,'bem',[subjId '_fs4-head.fif']);
if ~exist(headSurfFile,'file')
    msg = sprintf('Cannot find hi-res scalp surface: %s\n Not ploting subject scalp, or using hi res registration\n',fiducialFile);
    display(msg);

    
   plotHiResScalp = false;
else
    plotHiResScalp = true;

end


if ~exist(elpFile,'file')
    msg = sprintf('Cannot find electrode location file: %s\n Thank You, Please Play Again.\n',elpFile);
    error(msg);
end





for iFile = 1:length(exportFileList),
    
    dataFile = fullfile(powerDivaExportDir,exportFileList(iFile).name);

    msg = sprintf('Processing file: %s\n',dataFile);
    disp(msg);
    
    %%We should make this more elegant, but this works
    %%basically we only want to register electrodes once. But the place
    %%where everything is read in correctly is buried inside
    %%powerDivaExp2Mne, and I've been too lazy to extract the registration
    %%code and place it somewhere else.
    %%JMA
    
    if iFile == 1,
        doreg = true;
    else
        doreg = false;
    end
    
    if (plotHiResScalp == true) && doreg, 
        
        surf =  mne_read_bem_surfaces(headSurfFile);
        patch('faces',surf.tris,'vertices',surf.rr,'linestyle','none','facecolor',[.8 .7 .6]);
        material dull;
        lightangle(240, 30)
        lightangle(120, 30)
        lightangle(0, 0)
%        view([120, 30])
        axis normal
        axis equal
        axis vis3d
        axis tight;
        axis off
        campos([    0.7712    1.6339    0.7370]);
        camva(7);
        set(gcf,'name',subjId)
        
        
    end
        
    powerDivaExp2Mne( elpFile, dataFile,fiducialFile,outputDir,doreg)

        
end


