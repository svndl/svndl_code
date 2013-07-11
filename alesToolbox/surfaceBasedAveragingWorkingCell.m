%% Read stuff in
toSub = 'skeri0055_fs4'
fromSub = 'skeri0044_fs4'
freesurfDir = getpref('freesurfer','SUBJECTS_DIR');


[lm,rm] = mne_read_morph_map(fromSub,toSub,freesurfDir);

toSubSrcSpaceFile = fullfile(freesurfDir,toSub,'bem',[ toSub '-ico-5p-src.fif']);
fromSubSrcSpaceFile = fullfile(freesurfDir,fromSub,'bem',[ fromSub '-ico-5p-src.fif']);


toSubSrc = mne_read_source_spaces(toSubSrcSpaceFile,true);
fromSubSrc = mne_read_source_spaces(fromSubSrcSpaceFile,true);


toCtx = readDefaultCortex(toSub(1:9));
fromCtx = readDefaultCortex(fromSub(1:9));


%% Make lowrez transfer matrix
idxFrom = nearpoints(fromSubSrc(1).rr',fromSubSrc(1).rr(fromSubSrc(1).vertno,:)');
idxTo = nearpoints(toSubSrc(1).rr',toSubSrc(1).rr(toSubSrc(1).vertno,:)');

fromLo2Hi = sparse(double(1:fromSubSrc(1).np),idxFrom,ones(size(idxFrom)));
toLo2Hi = sparse(double(1:toSubSrc(1).np),idxTo,ones(size(idxTo)));

nLo = double(toSubSrc(1).nuse);
nHi = double(toSubSrc(1).np);
toHi2Lo = sparse(1:nLo,double(toSubSrc(1).vertno),ones(nLo,1),nLo,nHi);

totalTrans = toHi2Lo*(lm*fromLo2Hi);



%% plot stuff on MNE ctx

figure(50)
clf;
ctxToL = patch('vertices',toSubSrc(1).rr,'faces',toSubSrc(1).use_tris)
set(ctxToL,'linestyle','none')
set(ctxToL,'faceVertexCData',hi2hi{1}*fromSubSrc(1).rr(:,1))
set(ctxToL,'facecolor','interp')


figure(51)
clf;
ctxFromL = patch('vertices',fromSubSrc(1).rr,'faces',fromSubSrc(1).use_tris)
set(ctxFromL,'linestyle','none')
set(ctxFromL,'faceVertexCData',fromSubSrc(1).rr(:,1))
set(ctxFromL,'facecolor','interp')


%%
tstFromColor = zeros(fromSubSrc(1).np,1);
tstToColor = zeros(toSubSrc(1).np,1);

tstFromColor(fromSubSrc(1).vertno) = fromSubSrc(1).rr(fromSubSrc(1).vertno,1);
tstToColor(toSubSrc(1).vertno) = fromSubSrc(1).rr(fromSubSrc(1).vertno,1);



%% Do things on decimated ctx

fromFull = zeros(fromSubSrc(1).np,1)*NaN;

fromFull(fromSubSrc(1).vertno) = fromCtx.vertices(1:10242,1);

fromDefault = fromCtx.vertices(1:10242,1);

fromDefault = [fromDefault; fromDefault];



toDefault = totalTrans*fromDefault(1:10242);


%toDefault = (lm*fromSubSrc(1).rr(:,1));
%toDefault = toDefault(toSubSrc(1).vertno);

toDefault = [toDefault; toDefault];


%%
%origValues = get(mshHandle,'faceVertexCData');
origValues = fromFull;

validInd = find(~isnan(origValues));
origValues(isnan(origValues))=0;

idx = nearpoints(fromSubSrc(1).rr',fromSubSrc(1).rr(fromSubSrc(1).vertno,:)');



% mesh.uniqueVertices = get(mshHandle,'vertices');
% mesh.uniqueFaceIndexList = get(mshHandle,'faces');

% conMat = findConnectionMatrix(mesh);

% smoother = connectionBasedSmudge(conmat,origValues);
% smoothVals = smoother*origValues;



% 
% for i=1:100,
%     smoothVals = smoother*smoothVals;
%     smoother = smoother.*connectionBasedSmudge(conmat,smoothVals);
%     
%     %smoothedVals(validInd) = origValues(validInd);
%     
% %    set(mshHandle,'faceVertexCData',smoothedVals)
% %    drawnow;
%     disp(i)
% end
% 

%set(mshHandle,'facecolor','interp','linestyle','none','faceVertexCData',smoothedVals)
%set(mshHandle,'faceVertexCData',smoothedVals)




%% plot on default cortex

%toCtx = readDefaultCortex(toSub(1:9));
%thisCol = fromCtx.vertices(:,2);
toCol = zeros(size( fromCtx.vertices(:,2)));
toCol([roiInfo(3:4).meshIndices])=1;
allRoi2One(idx,iRoi,:)
figure(61)
clf;
dCtxFromL = patch('vertices',fromCtx.vertices,'faces',fromCtx.faces)
set(dCtxFromL,'faceVertexCData',toCol)
set(dCtxFromL,'linestyle','none')
set(dCtxFromL,'facecolor','interp')


figure(60)
clf;
dCtxToL = patch('vertices',toCtx.vertices,'faces',toCtx.faces)
set(dCtxToL,'linestyle','none')
set(dCtxToL,'faceVertexCData',mapMtx*toCol)
set(dCtxToL,'facecolor','interp')




%% bring many subjects onto one


tst = dir('/Volumes/MRI/anatomy/FREESURFER_SUBS/skeri0*_fs4');
nameL = {tst.name};
%nameL = {nameL{[1:16 18:end]}};


% fromSubjList = { 'skeri0004' 'skeri0044' 'skeri0055'};
% toSubj = {'skeri0001'};

fromSubjList = nameL;
%toSubj = {nameL{1}(1:9)}
toSubj = 'skeri0055';

%roi2Get = {'MT-L' 'MT-R'};

%roi2Get = {'V1D-L' 'V1V-L' 'V1D-R' 'V1V-R' };
roi2Get = { ...
'V1-L' ...
'V1-R' ...
'V1D-L' ...
'V1D-R' ...
'V1V-L' ...
'V1V-R' ...
'V2D-L' ...
'V2D-R' ...
'V2V-L' ...
'V2V-R' ...
'MT-L' ...
'MT-R' ...
'LOC-L' ...
'LOC-R' ...
'V3A-L' ...
'V3A-R' ...
'V3D-L' ...
'V3D-R' ...
'V3V-L' ...
'V3V-R' ...
'V4-L' ...
'V4-R' ...
'IPS-L' ...
'IPS-R' ...
};


anatDir = '/Volumes/MRI/anatomy/';

toSubjMean = zeros(size(toCtx.vertices(:,1)));
idx = 0;
for iFrom = 1:length(fromSubjList);

    subjName = fromSubjList{iFrom}(1:9);
    roiDir = fullfile(anatDir,subjName,'Standard/meshes/ROIs');
    
    [subjName]
    
    try 
        [roiInfo] = getRoisByType(roiDir,'func');
    catch
        disp('Unable to load rois')
        continue;
    end

    idx = idx+1;
    goodSubjList{idx} = subjName;
    mapMtx = makeDefaultCortexMorphMap(subjName,toSubj);
        

    for iRoi = 1:length(roi2Get)


        %    roiIdx = strcmp( {roiInfo.name}, roi2Get{1} ) | strcmp( {roiInfo.name}, roi2Get{2} );
        roiIdx = strcmp( {roiInfo.name}, roi2Get{iRoi});

        if sum(roiIdx) == 0;
            disp(['Skipping: ' subjName ' does not have roi ' num2str(iRoi) ': ' roi2Get{iRoi}]);
            allRoi2One(idx,iRoi,:) = NaN;
            continue
        end

%        [subjName ' ' roiInfo(roiIdx).name]
        roiIndices = [roiInfo(roiIdx).meshIndices];

        fromActive = zeros(size( fromCtx.vertices(:,2)));
        fromActive(roiIndices) = 1;

        %    toSubjAll(:,idx) = mapMtx*fromActive;
        allRoi2One(idx,iRoi,:) = mapMtx*fromActive;
    end

end

%toSubjMean = mean(toSubjAll,2);



%%
toCol = squeeze(allRoi2One(1,3,:));

figure(60)
clf;
dCtxToL = patch('vertices',toCtx.vertices,'faces',toCtx.faces(:,[3 2 1]))
set(dCtxToL,'linestyle','none')
set(dCtxToL,'faceVertexCData',toCol)
set(dCtxToL,'facecolor','interp')
material dull
lighting flat







%%
for iPlot=1:size(allRoi2One,2),
    
%    iPlot = 14;
%    toCol = squeeze(allRoi2One(36,3,:));
    toCol = squeeze(nanmean(allRoi2One(21,iPlot,:),1));
    set(dCtxToL,'faceVertexCData',toCol)
    tH = title(roi2Get{iPlot})
    set(tH,'fontsize',32)
    colormap(jmaColors('usc',.01))
    caxis([0 1])
    filename = ['skeri0055_posterior_roi_' roi2Get{iPlot} '.png']
    saveas(gcf,filename)
end

    