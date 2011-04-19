function [labeledVertexIndices values] = fsLabel2mneLabel(subjId,labelName)



freesurfDir = getpref('freesurfer','SUBJECTS_DIR');

if ~strncmp(subjId(end-3:end),'fs4',3)
    subjDir=[subjId '_fs4'];
else
    subjDir = subjId;
end


srcSpaceFile = fullfile(freesurfDir,subjDir,'bem',[ subjDir '-ico-5p-src.fif']);

if ~exist(srcSpaceFile,'file'),
    error(['Cannot find find source space file: ' srcSpaceFile]);
end
 
src = mne_read_source_spaces(srcSpaceFile);
hemis = { 'lh', 'rh'};  

values = [];

for iHemi =1:2,
        
    
    hemiName = hemis{iHemi};
    labelFilename = fullfile(freesurfDir,subjDir,'label',[ hemiName '.' labelName '.label']);

    thisLabel = read_label([],labelFilename);

    fs2MneIdx = zeros(size(src(iHemi).inuse));
    fs2MneIdx( src(iHemi).vertno) = 1:10242;
    
    theseVerts = fs2MneIdx(thisLabel(:,1)+1);
    theseVerts = theseVerts(theseVerts~=0);
    
    theseVals = thisLabel(:,5);
    theseVals = theseVals(theseVerts~=0);
    
    labeledVertices{iHemi} = theseVerts;
    
    values = [values; theseVals];
    
end


labeledVertexIndices = [labeledVertices{1} labeledVertices{2}+double(src(1).nuse)]; 





% newDx = [];
% oriLeft = [];
% idx=1;
% for iHi=fwd.src(1).vertno,
%     newDx(idx) = find(srcSpace(1).vertno == iHi);
%     oriLeft(idx,:) = fwd.src(1).nn(iHi,:);
%     idx=idx+1;
%     
% end
% 
% newDxLeft =newDx;
% 
% newDx = [];
% idx=1;
% for iHi=fwd.src(2).vertno,
%     newDx(idx) = find(srcSpace(2).vertno == iHi);
%     oriRight(idx,:) = fwd.src(2).nn(iHi,:);
%     idx=idx+1;
%     
% end
% 
% newDxRight =newDx;
% 
% totalDx = [newDxLeft (newDxRight+double(srcSpace(1).nuse))];