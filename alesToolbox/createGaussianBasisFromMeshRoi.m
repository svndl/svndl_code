function [chunker roiList] = createChunkerFromMeshRoi(roiDir,nTotalVert)
%function [chunker] = createChunkerFromMeshRoi(roiDir,nTotalVert)
%The chunker matrix maps the full(~128 x nTotalVert) forward/inverse matrix
%onto onto a chunked 128xnMeshRois
%
%Inputs:
%roiDir is the director that contains the mesh ROI files.
%nTotalVert is the size of the forward/inverse matrix
%
%Outputs:
%chunker is a matrix nTotalVert x nMeshRois that maps
%
%Example:
%[chunker] = createChunkerFromMeshRoi('/raid/anatomy/ales/Standard/mesh/ROIs/',length(A))
%
%Achunk = A*chunker;
%
%
%WARNING: NO NORMALIZATION IS DONE
%You should normalize to whichever makes most sense to you, chunk area or
%chunk projecton power.
%

% $Log: createGaussianBasisFromMeshRoi.m,v $
% Revision 1.1  2010/08/31 22:03:47  SKI+ales
% Added all my random .m files
%
% Revision 1.4  2008/06/12 19:41:05  ales
% Added wfr2tri.m
% this function converts an emse wfr cortex into a source space file readable
% by mne
%
% Revision 1.3  2008/05/27 16:52:08  ales
% *** empty log message ***
%
% Revision 1.2  2008/05/05 19:19:10  ales
% fixed bug with not reading intput directory
%
% Revision 1.1  2008/05/05 17:26:24  ales
% Added new createChunkerFromMeshROI().
%


%AroiDir = '/Volumes/MRI-1/anatomy/ales/Standard/meshes/ROIs/';

roiList = dir(fullFile(roiDir, '*.mat'));

%areas2Lump = {V1R V1L V2DR V2VR V2DL V2VL V3AR V3AL V4R V4L MTR MTL LOCR LOCL};

nAreas = length(roiList);
%length(areas2Lump);

%The chunker matrix maps the full A on 128x20k to 128xnAreas
chunker = zeros(nTotalVert,nAreas);

for iArea=1:nAreas,
    thisROI = load(fullfile(roiDir,roiList(iArea).name));

    thisROIvertices = thisROI.ROI.meshIndices(find(thisROI.ROI.meshIndices>0));
    thisArea = thisROIvertices;
    
    ctxList = sparse(zeros(nTotalVert,1));
    ctxList(thisArea) = 1;
    
    chunker(:,iArea) = ctxList;
end
