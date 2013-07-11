function [resultsBySubj] = mrcPrepareL1(mrCurrProjDir,headmodelDir,options)

%function [] = mrcPrepareL1(mrCurrProjDir,options)

anatDir = getpref('mrCurrent','AnatomyFolder');

dirList = dir(mrCurrProjDir)

% These lines pull out only the directories in the current directory
dirList = dirList(3:end); %excludes . ..
dirList = dirList([dirList.isdir]); %excludes random files

subjList = dirList.name


for iDir = 1:length(dirList)
    
    subjName = dirList(iDir).name; 
    subjAnatDir = fullfile(anatDir,subjName);
    subjHeadmodelDir = fullfile(headmodelDir,subjName);
    
    mrCurrSubjDir = fullfile(mrCurrProjDir,subjName);

    
    %load forward solution
    fwdFile = fullfile(subjHeadmodelDir,'skeri_cortex-fwd.fif');
    
    if exist(fwdFile,'file'),

        fwd = mne_read_forward_solution(fwdFile);
        %Constrain the forward solution to the surface normals
        idx = 1;
        A=zeros(fwd.nchan,fwd.src.np);
        for iX = 1:3:fwd.sol.ncol,

            iVert = fwd.src.vertno(idx);
            A(:,iVert) = fwd.sol.data(:,iX:iX+2)*fwd.src.nn(iVert,:)';
            A(:,iVert) = A(:,iVert) - mean(A(:,iVert)); %ave Ref forward.
            idx = idx+1;
        end


    else
        fwdFile = fullfile(subjHeadmodelDir,'skeri_cortex.fwd');
        
        if ~exist(fwdFile,'file'),
            disp(['NO FORWARD FILE FOUND FOR SUBJECT: ' subjName ' QUITTING']);
            results = [];
            return;
        end
        
        fwd = emseReadForward(fwdFile);
        A = fwd.matrix(1:128,:);
    end
    


    
    %load cortex
    ctxFile = fullfile(subjAnatDir,'Standard','meshes','defaultCortex');
    load(ctxFile);
    ctx.vertices = msh.data.vertices';
    ctx.faces = [msh.data.triangles+1]';
    
    
    %% Make a geometrically chunking matrix of the cortex

    nTiles = 1600;
  
    if (options.funcRoi==true)
        [geomChunker list] = createChunkerFromMeshRoi(fullfile(subjAnatDir,'Standard','meshes','ROIs'),length(ctx.vertices));
        if (isfield(options,'funcList'))
            if (~isempty(options.funcList))
                thisSubjFuncRoi = options.funcList{iDir};
                geomChunker = geomChunker(:,thisSubjFuncRoi);
                results.roiNames = {list(thisSubjFuncRoi).name}
            end
        end
    else
        geomChunker = geometryChunk(ctx,nTiles);
        geomChunker = geomChunker(:,1:3:end);
    end
    
    
    nTiles = size(geomChunker,2);
    
   
    %Make the chunked/ and normalized forward model
    Ageom = A*geomChunker;  
    
        
    [chunkNorms Ageom] = colnorm(Ageom);
    
%     for i=1:nTiles,
%        chunkNorms(i) = norm(Ageom(:,i));
%        Ageom(:,i) = Ageom(:,i)/norm(Ageom(:,i));
%     end

    results.A = Ageom;
    results.chunker = geomChunker;
    
    
    expDir = dir(fullfile(mrCurrSubjDir,'Exp*'));
    if length(expDir) >1,
        disp('error, more then 1 export in mrCurr subj dir, I cannot handle this, bye');
           return
    end
    
    condFileDir = fullfile(mrCurrSubjDir,expDir(1).name);
    dataFileList = dir(fullfile(condFileDir,'Axx*'));
    
    for iCond = 1:length(dataFileList),
        
        
        thisData = load(fullfile(condFileDir,dataFileList(iCond).name));
        
        results.data{iCond} = thisData;
        l1Results = invokeCVX(Ageom,thisData,options);

        results.sources{iCond} = l1Results;
        % keyboard
    end

    resultsBySubj{iDir} = results;
end

   
%{    
%This function takes the forward model and invokes CVX to solve the l1 optim problem   
function [results] = invokeCVX(Achunk,thisData),

n = size(Achunk,2);


cplxData = complex(thisData.Cos,thisData.Sin);

nFreqs = thisData.nFr;

f1Harm = thisData.i1F1:thisData.i1F1:thisData.i1F1*5,

if thisData.i1F2 ~= 0,
    
    f2Harm = thisData.i1F2:thisData.i1F2:nFreqs,
end


freqList = unique(sort([f1Harm f2Harm]));

nHarmonics = length(freqList);

fData = cplxData(freqList,:)';


lamMax = norm(2*(Achunk'*fData),inf);

lambda =.01*lamMax;



cvx_begin
  variable x(n,nHarmonics) complex
  cvx_precision default
  minimize( norm(Achunk*x-fData,'fro')+lambda*norm(x,1));
  %+mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
  %minimize(norm(x,1))
  %subject to
  %     abs(x)<=1.2
  %      norm(Achunk*x-data,'fro')<=1.2
  %      norm(Achunk*x-data,'fro')>=1.13
  %      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
  %      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end

results = x;






%}