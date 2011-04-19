function computeManyMrcInverses( projectDir,params )
%function computeMrcInverses( projectDir,params )
%
% params is a structure some fields:
% params.SNR = estimated power SNR
% params.useROIs = boolean specifying whether to constrain
% params.areaExp = area weighting exponent.
% localization to fuctiona ROIs

SNR = params.SNR; %Power SNR
lambda2 = 1/(SNR+1);


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

if ~isfield(params,'gcvStyle')
    params.gcvStyle = 0;
end

if ~isfield(params,'extendedSources')
    params.extendedSources = false;
end

if ~isfield(params,'Quadrants')
    params.Quadrants = [ 1 2 3 4 ];
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

        anatDir = freesurfDir(1:n(end));

        disp('My guess is: %s', anatDir);

    end
end

    
    
% matlabScriptDir =  which('prepareInversesForMrc.m');
% [matlabScriptDir] = fileparts(matlabScriptDir);


subjectList = dir(projectDir);
subj_ndx = 1;

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
    
    if strncmp(subjId,'.',1)
        display(['skipping folder: ' subjId])
        continue;
    end
    
    logFile = fullfile(projectDir,subjId,'_dev_',['compInvMrc_log_' datestr(now,'yyyymmdd_HHMM_FFF')  '.txt']);
    diary(logFile)

    
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
  
    end
    
    
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
    
    if params.sphereModel ==true
        mneFwdFileName = [subjId '-sph-fwd.fif' ];
        optionString = [optionString 'sphere_'];
    else
        mneFwdFileName = [subjId '-fwd.fif' ];
        optionString = [optionString 'bem_'];
    end
    mneFwdFile = fullfile(projectDir,subjId,'_MNE_',mneFwdFileName);
    
    if params.jmaStyle == true,
       

        if params.saveFullForward        
            [u s v] = jmaMakeInv(mneFwdFile,lambda2,srcSpace,srcCov);            
        else
            [sol] = jmaMakeInv(mneFwdFile,lambda2,srcSpace,srcCov);
            optionString = [optionString 'nonorm_jma_'];
        end
        
    elseif params.gcvStyle == true  %
        
         PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));

         if isempty(PDname)
             error('\n Cannot find EMSE Export, please add data');
         end

         powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name);

         if ~exist(powerDivaExportDir,'dir'),
             error(['Cannot find EMSE Export directory' ]);
         end
         exportFileList = dir(fullfile(powerDivaExportDir,'Axx_c*.mat'));

         if isempty(exportFileList)
             msg = sprintf('No .mat diva exports found in: %s\n Thank You, Please Play Again.\n',powerDivaExportDir);
             error(msg);
         end
         
         idx = 1;
         for iFile = 1:length(exportFileList),

             condNmbr = str2num(exportFileList(iFile).name(5:7));
             
             if condNmbr>900
                 continue;
             end
                 
             dataFile = fullfile(powerDivaExportDir,exportFileList(iFile).name);
             msg = sprintf('Processing file: %s\n',dataFile);         
             disp(msg);
             
             Axx(idx) = load(dataFile);
             idx = idx+1;
         end
         
         mneFwd = mne_read_forward_solution(mneFwdFile);
         [fwd] = makeForwardMatrixFromMne(mneFwd,srcSpace);
         if params.ROIs_correlation
             [ fwd ] = add_corr2fwd( fwd , subjId , freesurfDir );
         end         
         
         if subj_ndx == 1
             [ gcv_params ] = get_gcv_params( find(Axx(1).i1F2) );
             subj_ndx = subj_ndx + 1;
         end
         if length( params.Quadrants ) == 4
             activated_sources = [ 1 : length(fwd) ];
         else
            [ activated_sources ] = define_activated_source_space( params.Quadrants , length(fwd) , subjId );
         end
         sol = zeros( size( fwd' ) );
         [ sol_tmp , inverse_name ] = gcv_regularized_Inverse( fwd( : , find( activated_sources ) ) , Axx , gcv_params );
         sol( find( activated_sources ) , : ) = sol_tmp;
 
         if params.ROIs_correlation
             [ sol ] = add_corr2inv( sol , subjId , freesurfDir );
             inverse_name = strcat('ROIs_corr_' , inverse_name );
         end
         if find( setdiff( [ 1 2 3 4 ] , params.Quadrants ) )
             inverse_name = strcat( '_' , inverse_name );
             for ndx = 1 : length( params.Quadrants )
                 inverse_name = strcat( num2str( params.Quadrants( ndx ) ) , inverse_name );
             end
             inverse_name = strcat( 'Quads_' , inverse_name );
         end
         
    else
        mneInvFileName = [subjId '-inv.fif' ];
        mneInvFile = fullfile(projectDir,subjId,'_MNE_',mneInvFileName);
        
        if ~exist(mneInvFile,'file')
            error(['Cannot find an MNE inverse, please run prepareProjectForMrc' ]);
        end
        [sol] = mneInv2EMSE(mneInvFile,lambda2,false,srcSpace,srcCov);
        
    end        
   
        
    if params.saveFullForward
        mrcInvOutFile = fullfile(projectDir,subjId,'Inverses',[optionString 'fwd' '.mat']);
        save(mrcInvOutFile, 'subjId','u','s','v');
    else
        if params.gcvStyle == true
            optionString =  [optionString inverse_name ];
        else
            optionString =  [optionString 'snr_' num2str(SNR)];
        end
        mrcInvOutFile = fullfile(projectDir,subjId,'Inverses',['mneInv_' optionString '.inv']);
        emseWriteInverse(sol,mrcInvOutFile);
    end
    
    diary off

end

