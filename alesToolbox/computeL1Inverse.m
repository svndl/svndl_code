function computeL1Inverse( projectDir,params )
%function computeMrcInverses( projectDir,params )
%


me='JMA:computeL1Inverse';
FIFF=fiff_define_constants;

if ~exist('params')
    
    error('Please set the params')
end

if ~isfield(params,'useROIs')
    params.useROIs = false;
end

if ~isfield(params,'areaExp')
    params.areaExp = 1;
end

if ~isfield(params,'jmaStyle')
    params.jmaStyle = 0;
end

if ~isfield(params,'extendedSources')
    params.extendedSources = true;
end


%if nargin ~= 1,
%    projectDir = uigetdir('.','Pick your project directory')
%end


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


if ~exist(projectDir,'dir')
    msg = sprintf('Project directory not found: %s\n Thank You, Please Play Again.\n',projectDir);
    error(msg);
end

if params.useROIs ==true
    
    if ispref('mrCurrent','AnatomyFolder'),

        anatDir = getpref('mrCurrent','AnatomyFolder');
    else
        disp('');
        disp('Cannot find mrCurrent anatomy folder!!');
        disp('Attempting to guess');
        disp('Good luck with that');

        n = regexp(freesurfDir(1:end-1),[filesep '*' ],'start')

        anatDir = freesurfDit(1:n(end));

        disp('My guess is: %s', anatDir);

    end
end

    
    
% matlabScriptDir =  which('prepareInversesForMrc.m');
% [matlabScriptDir] = fileparts(matlabScriptDir);


subjectList = dir(projectDir);

for iSubj = 3:length(subjectList),

optionString = '';

    if subjectList(iSubj).isdir==false;
        continue;
    end
    
    
    subjId = subjectList(iSubj).name;
    
    if strcmp(subjId,'skeri9999')
        display('Skipping skeri9999')
        continue;
    end
    
%     logFile = fullfile(projectDir,subjId,'_dev_',['compInvMrc_log_' datestr(now,'yyyymmdd_HHMM_FFF')  '.txt']);
%     diary(logFile)

    
    disp(['Processing subject: ' subjId ])

    str2num(subjId(end-3:end))
    subjNum = str2num(subjId(end-3:end))
    
    SUBJECT=[subjId '_fs4'];

    srcSpaceFile = fullfile(freesurfDir,SUBJECT,'bem',[ SUBJECT '-ico-5p-src.fif']);
    if ~exist(srcSpaceFile,'file'),
        error(['Cannot find find source space file: ' srcSpaceFile]);
    end
    
    srcSpace = mne_read_source_spaces(srcSpaceFile);
    

%     REG=fullfile(projectDir,subjId,'_MNE_','elp2mri.tran');
%     ELEC=mneDataFile;
%     COV=mneCovFile;
%     
%     outputDir = fullfile(projectDir,subjId,'_MNE_');
%     
%     FWDOUT=fullfile(outputDir,[subjId '-fwd.fif']);
%     INVOUT=fullfile(outputDir,[subjId '-inv.fif']);
% 
%     shellCmdString = ['!' matlabScriptDir filesep 'skeriMNE ' SUBJECT ' ' REG ' ' ELEC ' ' COV ' ' FWDOUT ' ' INVOUT ];
%     
%     disp(['Executing shell command:']);
%     disp(shellCmdString);
%     eval(shellCmdString);

%     mneInvFileName = [subjId '-inv.fif' ];
%     mneInvFile = fullfile(projectDir,subjId,'_MNE_',mneInvFileName);
%     
%     if ~exist(mneInvFile,'file')
%         error(['Cannot find an MNE inverse, please run prepateProjectForMrc' ]);
%     end

    srcCov = [];
    
    if params.useROIs ==true
        subjRoiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');
        [roiList leftVerts rightVerts leftSizes rightSizes] = getRoisByType(subjRoiDir,'func');                  
        totalDx = [leftVerts rightVerts];
       
        
        srcSize = sum([srcSpace.nuse]); % <- Note tricky use of grouping
                                       %[srcSpace.nuse] -> [nuse nuse]
                                       %sum of that gives the total # of
                                       %vertices in the source space
          
                                       
        srcCov = sparse(srcSize,srcSize);
                                       
        for iRoi = 1:length(roiList),
             
            srcIdx = roiList(iRoi).meshIndices;
            srcVec = sparse(srcSize,1);
            srcVec(srcIdx) = 1;
            roiWeight = length(srcIdx).^-params.areaExp %Inverse area weighting
%            srcVec(srcIdx) = length(srcIdx).^-2; %Inverse area weighting

            srcCov = srcCov+roiWeight*(srcVec*srcVec');
            
        end
        
%             totalSizes = [leftSizes rightSizes];
%             
%             srcVec(totalDx) = totalSizes.^-1; % <- Scale power with the inverse area
%             
%             srcCov = srcVec*srcVec';
       optionString = [optionString 'useROIs_areaExp_' num2str(params.areaExp) '_'];
       
       if params.indRoiVert
           inRoiVert = (double(diag(srcCov)>0));
           tst = speye(size(srcCov));
           srcCov = tst(:,inRoiVert>0);
           clear tst
       end
       
    end
    
    if params.sphereModel
        mneFwdFileName = [subjId '-sph-fwd.fif' ];
    else
        mneFwdFileName = [subjId '-fwd.fif' ];
    end
        
        mneFwdFile = fullfile(projectDir,subjId,'_MNE_',mneFwdFileName);
     
        fwd = mne_read_forward_solution(mneFwdFile);
        fwdMatrix = makeForwardMatrixFromMne(fwd,srcSpace);
        
    if params.extendedSources
        
        for iHemi = 1:2,
            
            src2subset = zeros(size(srcSpace(iHemi).inuse));
            src2subset(srcSpace(iHemi).vertno) = 1:10242;

            renumberedFaces = srcSpace(iHemi).use_tris;
            renumberedFaces(:) = src2subset(srcSpace(iHemi).use_tris(:));
            mesh.faces = renumberedFaces;
            mesh.vertices = srcSpace(iHemi).rr( srcSpace(iHemi).vertno,:);
    
            [A{iHemi}] = geometryChunk(mesh,400);
        end
        
        Ageom = [A{1}      zeros(size(A{1})); ...
                 zeros(size(A{2}))       A{2}];
        srcCov = Ageom;
        optionString = [optionString 'extendedSources_'];
        
    end
    
    
    
%    fwdChunk = fwdMatrix*Ageom;
    fwdChunk = fwdMatrix*srcCov;




    expDir = dir(fullfile(projectDir,subjId,'Exp*'));

    if length(expDir) >1,
        disp('error, more then 1 export in mrCurr subj dir, I cannot handle this, bye');
        return
    end

    condFileDir = fullfile(projectDir,subjId,expDir(1).name);
    dataFileList = dir(fullfile(condFileDir,'Axx*'));

    for iCond = 1:length(dataFileList),

        thisData = load(fullfile(condFileDir,dataFileList(iCond).name));

        results.data{iCond} = thisData;
        % !!!! need some harmonic choosing logic.
        options.harmList1f1 =[  ];
        options.harmList1f2 =[ 2 4 ];
        [l1Results inverse] = invokeCVX(fwdChunk,thisData,options);

        results.sources{iCond} = l1Results;


        results.inverse{iCond} = inverse;



        % keyboard
    end

%     resultsBySubj{iSubj}.results = results;
%     resultsBySubj{iSubj}.srcCov = srcCov;
%     resultsBySubj{iSubj}.fwdMatrix = fwdMatrix;


     resultsBySubj.results = results;
     resultsBySubj.srcCov = srcCov;
     resultsBySubj.fwdMatrix = fwdMatrix;

    %        [sol] = jmaDoL1(fwdMatrix);



save(fullfile(projectDir,subjId,'_dev_',['l1Results' optionString '.mat']),'resultsBySubj');


    %         diary off

end



