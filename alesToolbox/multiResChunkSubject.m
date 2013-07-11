function [geomChunker vertSubsetIndices allPatchAreas] = gaussianBasisChunk(subjId,basisRadii);
%function [geomChunker vertSubsetIndices allPatchAreas] = geometryChunk(mesh,nSources);
% This function tries to do a mutliresoltion gausiian tiling of a cortex
% mesh = Matlab mesh.face mesh.vertices style mesh
% nSources = number of sources to keep
% basisRadii = distance to grow the basis set to.
%
% geomChunker is a matrix that maps the chunks
% vertSubsetIndices 
% allPatchAreas are the patchAreas


mesh = readDefaultCortex(subjId);
fullSourceSpace = readDefaultSourceSpace(subjId);
decSourceSpace = readDefaultSourceSpace(subjId,'ico-3');

for i=1:2,

    %This finds the indexing into the full source space.
    [tf,decIndex{i}] = ismember(decSourceSpace(i).vertno,fullSourceSpace(i).vertno);
end


nv = [decIndex{1} decIndex{2}+double(fullSourceSpace(1).nuse)];
vertList = nv;

%nVert = length(mesh.faces)/2+2;
nVert = length(mesh.vertices);

%reductionFactor = nSources/nVert;

% [nf nv] = reducepatch(mesh,reductionFactor);
% 
% [vertList] = nearpoints(nv',mesh.vertices');
% 
% vertSubsetIndices = vertList;

% surfArea = mesh_face_area(mesh);
% totalArea = sum(surfArea)
% patchArea = .5*(totalArea/nSources)


mesh.uniqueVertices = mesh.vertices;
mesh.uniqueFaceIndexList = mesh.faces;
[mesh.connectionMatrix] = findConnectionMatrix(mesh);
neighbourDist = find3DNeighbourDists(mesh);
neighbourDist = sqrt(neighbourDist);
%if ~isfield(mesh,'edge'),
%    mesh.edge = mesh_edges(mesh);
%end
%geomChunker = zeros(nVert,length(nv)*length(basisRadii));

nCol = length(nv)*length(basisRadii);
geomChunker = spalloc(nVert,nCol,ceil(2.1*sum(basisRadii)*nCol));

idx = 1;
for iBasis = 1:length(basisRadii),
    

    
    sigma = .3*basisRadii(iBasis);
    
    for iVert = 1:length(vertList),
        % [   iVert length(vertList)]

        
    %    iVert
        
         thisVert = vertList(iVert);
         distFromThisVert = dijkstra2(neighbourDist,thisVert);
         distFromThisVert(thisVert) = 0;
         
         patchVertList = distFromThisVert<=basisRadii(iBasis);
         
         

        thisCol = zeros(nVert,1);
        thisCol(patchVertList) = exp(-(distFromThisVert(patchVertList)./(2*sigma)).^2);
        geomChunker(:,idx) = thisCol;
        idx = idx+1;

    end
end

