function [Aroi_all Ainv_all Actx roiNames] = computeInwardRoi( projectDir,params )
%function computeInwardRoi( projectDir,params )
%
% params is a structure some fields:
% params.SNR = estimated power SNR



% params.orientContstraint = something future
% params.areaExp = area weighting exponent.
% params.includeNullSpace = a bool specifying whether or not to calculate the ROI
%                           nullspace
% localization to fuctiona ROIs

SNR = params.SNR; %Power SNR
lambda2 = 1/SNR;
params.extendedSources = true;
params.useROIs = true;





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

    if params.useROIs ==true
        subjRoiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');
        [roiList leftVerts rightVerts leftSizes rightSizes] = getRoisByType(subjRoiDir,'anat');
        totalDx = [leftVerts rightVerts];

    end

%    logFile = fullfile(projectDir,subjId,'_dev_',['compInvMrc_log_' datestr(now,'yyyymmdd_HHMM_FFF')  '.txt']);
%    diary(logFile)

    
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

    mneInvFileName = [subjId '-inv.fif' ];
    mneInvFile = fullfile(projectDir,subjId,'_MNE_',mneInvFileName);

    mneFwdFileName = [subjId '-fwd.fif' ];
    mneFwdFile = fullfile(projectDir,subjId,'_MNE_',mneFwdFileName);

    if ~exist(mneInvFile,'file')
        error(['Cannot find an MNE inverse, please run prepateProjectForMrc' ]);
    end
    
    if ~exist(mneFwdFile,'file')
        error(['Cannot find an MNE Forward, please run prepateProjectForMrc' ]);
    end
 
    


    srcSize = sum([srcSpace.nuse]); % <- Note tricky use of grouping to get the sum of the components of a structure
    %[srcSpace.nuse] -> [nuse nuse]
    %sum of that gives the total # of
    %vertices in the source space

    fwd = mne_read_forward_solution(mneFwdFile);
    
    srcCov = sparse(srcSize,srcSize);

    %Calculating transformations to the total src space stored in default
    %Brute force non optimal search, easiest to conceptualize. It's not too slow, but
    %could be a lot better.
    %full srcspace: srcSpace
    %"Valid" src space after BEM model: fwd
    
    newDx = [];
    idx=1;
    for iHi=fwd.src(1).vertno,
        newDx(idx) = find(srcSpace(1).vertno == iHi);
        idx=idx+1;
    end

    newDxLeft =newDx;

    newDx = [];
    idx=1;
    for iHi=fwd.src(2).vertno,
        newDx(idx) = find(srcSpace(2).vertno == iHi);
        
        idx=idx+1;
    end

    newDxRight =newDx;

    idxFwd2Src = [newDxLeft (newDxRight+double(srcSpace(1).nuse))];
    whichSrcSpace = [ones(size(newDxLeft)) 2*ones(size(newDxRight))];
    
    fullIdx = 1:srcSize; % A vector that is the simple full index into srcSpace
    
    invalidSrcIdx = setdiff(fullIdx, idxFwd2Src); % This should give us the indices that were removed to make fwd.

    validSrcIdx = intersect(fullIdx, idxFwd2Src); % This should give us the indices that are left in fwd.
    
    idxSrc2Fwd = zeros(srcSize,1);
    idxSrc2Fwd(validSrcIdx) = 1:length(validSrcIdx); % This should map from src space numbers to fwd numbers, with 0's where there's no mapping.

    
    %idxFwd2Src should be the same length as the number of sources in fwd
    %It's content should be the mapping that transforms the fwd idxs to srcSpace
    %

    Aroi = zeros(fwd.sol.nrow,length(roiList));
    aveRefFwd = fwd.sol.data - repmat(mean(fwd.sol.data,1),128,1);
    aveRefFwdOutsideRoi = aveRefFwd;
    %This is the concatenation of the forward model src space orientations;
    %nValidSources x 3 orientations
    srcOri = [fwd.src(1).nn(fwd.src(1).vertno,:);fwd.src(2).nn(fwd.src(2).vertno,:)];
    
    %Find the cortically orientation constrained forward.    
    G = zeros(size(aveRefFwd,1),size(aveRefFwd,2)/3);
    idx=1;
    for i=1:3:length(aveRefFwd);

        G(:,idx) = aveRefFwd(:,i:i+2)*srcOri(idx,:)';
        
        idx=idx+1;
    end

    
    A2Orig = zeros(length(roiList),srcSize);
    
    for iRoi = 1:length(roiList),

        srcIdx = roiList(iRoi).meshIndices; % From the full src space file
        
        A2Orig(iRoi,srcIdx) = 1;%/length(srcIdx);
        %Next we need to translate this into the quality assurance space
        

        roiFwdIdx = idxSrc2Fwd(srcIdx); %Go to the fwd indexing
        roiFwdIdx = roiFwdIdx(roiFwdIdx~=0); %remove 0 mappings.
        
        
        
        thisRoiFwd = zeros(fwd.sol.nrow,1);
        %Let's loop through and get all the valid sources in this roi
        for i=1:length(roiFwdIdx),
            
            oriIdx = 3*roiFwdIdx(i)-2;
            
            
            thisVertFwd      = aveRefFwd(:,oriIdx:oriIdx+2); %3 oriented dipoles at this location.
            aveRefFwdOutsideRoi(:,oriIdx:oriIdx+2) = 0; %0 out roi sources.
            
%             %Convert each moment to average reference. 
%             thisVertFwd(:,1) = thisVertFwd(:,1) - mean(thisVertFwd(:,1));
%             thisVertFwd(:,2) = thisVertFwd(:,2) - mean(thisVertFwd(:,2));
%             thisVertFwd(:,3) = thisVertFwd(:,3) - mean(thisVertFwd(:,3));
            
            thisVertOri = srcOri(roiFwdIdx(i),:); %Should be the cortical orientation at this location
            
            thisRoiFwd = thisRoiFwd + thisVertFwd*thisVertOri'; %This should be the orientation constrained forward for this vertex;
            
            
        end
        
            
        Aroi(:,iRoi) = thisRoiFwd;%/length(roiFwdIdx); %This should now be the forward model for this ROI.
        

    end
    
    dimLeft = size(Aroi,1) - size(Aroi,2);  % How many colomns we have left.
    
    
    

    %             totalSizes = [leftSizes rightSizes];
    %
    %             srcVec(totalDx) = totalSizes.^-1; % <- Scale power with the inverse area
    %
    %             srcCov = srcVec*srcVec';
    
    if params.extendedSources
        
        for iHemi = 1:2,
            
            src2subset = zeros(size(srcSpace(iHemi).inuse));
            src2subset(srcSpace(iHemi).vertno) = 1:10242;

            renumberedFaces = srcSpace(iHemi).use_tris;
            renumberedFaces(:) = src2subset(srcSpace(iHemi).use_tris(:));
            mesh.faces = renumberedFaces;
            mesh.vertices = srcSpace(iHemi).rr( srcSpace(iHemi).vertno,:);
    
            [A{iHemi}] = geometryChunk(mesh,100);
        end
       
        %The following is a trick for mapping subset rois back to the full
        %CTX
        Ageom = [A{1}      zeros(size(A{1})); ...
                 zeros(size(A{2}))       A{2}];
        srcCov = Ageom;
        optionString = [optionString 'extendedSources_'];
        
    end
   

    %Another tricky matrix thing.Look at the vertices that belong to roi's
    %then find the columns that have non zero entries, these overlap with
    %the geometry chunked sources.
    
    roiOverlap = Ageom(totalDx,:);
    nonValid = find(sum(roiOverlap));
    
    nGeom = size(Ageom,2);
    valid =setdiff(1:nGeom,nonValid);

    %THIS is the valid non roi chunks, plus the valid cortical forward
    %locations
    AgeomSub = Ageom(idxFwd2Src,valid);
    
    Ggeom = G*AgeomSub;
    
    %    [sol] = mneInv2EMSE(mneInvFile,lambda2,false,srcSpace,srcCov);
    
    %This part finds the part of the forward solution that is from other
    %non roi sources
%     if params.includeNullSpace==true,
%         [u1 s1 v1] = svd(aveRefFwdOutsideRoi,'econ');
% %         A = orth(Aroi);
% %         B = u1;
% %         for k=1:size(A,2)
% %             B = B - A(:,k)*(A(:,k)'*B);
% %         end
%         
% %         Bleft = orth(B*s1);
%         
% %         sc = min(colnorm(Aroi)); %scaling to bring it inline with others
%         Aother = u1(:,1:dimLeft)*s1(1:dimLeft,1:dimLeft)*v1(:,1:dimLeft)';
%         %         Aroi = [Aroi sc*Bleft];
%         Aroi = [Aroi Aother];
%     end
% 
     
 
    geoms2pick = unique(round(linspace(1,length(valid),dimLeft)));
    if length(geoms2pick)~=dimLeft,
        nNeeded = dimLeft-length(geoms2pick);
        extraBits = setdiff(1:nGeom,geoms2pick);
        
        geoms2pick = [geoms2pick extraBits(1:nNeeded)];
    end
    
        
        
    Aroi =  [Aroi Ggeom(:,geoms2pick)];
  %  [non Aroi] = colnorm(Aroi);
        
    
    [u,w,v] = svd(Aroi,'econ');

    w = diag( w);	% Extract diagonal, always real, non-negative.
    maxW = max( w);
    varianceAccountedFor = cumsum(w.^2)/sum(w.^2);
    
    comps2keep =1;
    
    for i=1:length(varianceAccountedFor),
        
        if (varianceAccountedFor(i) > (1-lambda2)  )
            break;
        end
        
        comps2keep = comps2keep+1;
        
    end
        
  
    wInv = 1 ./ w;
    wInv(comps2keep+1:end) = 0;

    wInv = diag( wInv);	% Re-embed diagonal in a full zeros matrix.
    % swi= size( wInv)

    aInv = v * wInv * u';

    aInv = aInv(1:length(roiList),:);
    
    inv = 1e-6*[aInv'*A2Orig]';
      
    optionString = [optionString 'eigenValuesKept_' num2str(comps2keep) '_'];

    mrcInvOutFile = fullfile(projectDir,subjId,'Inverses',['richInv_' optionString '.inv']);

    emseWriteInverse(inv,mrcInvOutFile);

    
   

    Aroi_all{iSubj} = Aroi;
    Ainv_all{iSubj} = aInv;
    Actx{iSubj} =   [ A2Orig' Ageom(:,valid(geoms2pick))]; 
        
    roiNames{iSubj} = roiList;
    %optionString =  [optionString 'snr_' num2str(SNR)];



    %  mrcInvOutFile = fullfile(projectDir,subjId,'Inverses',['mneInv_' optionString '.inv']);

    %  emseWriteInverse(sol,mrcInvOutFile);

    % diary off

end

