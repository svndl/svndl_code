function [geomChunker vertSubsetIndices] = gaussianBasisChunk(mesh,nSources,basisRadii);
%function [geomChunker vertSubsetIndices allPatchAreas] = geometryChunk(mesh,nSources);
% This function tries to do a mutliresoltion gausiian tiling of a cortex
% mesh = Matlab mesh.face mesh.vertices style mesh
% nSources = number of sources to keep
% basisRadii = distance to grow the basis set to.
%
% geomChunker is a matrix that maps the chunks
% vertSubsetIndices 
% allPatchAreas are the patchAreas

%nVert = length(mesh.faces)/2+2;
nVert = length(mesh.vertices);

reductionFactor = nSources/nVert;

[nf nv] = reducepatch(mesh,reductionFactor);

[vertList] = nearpoints(nv',mesh.vertices');

vertSubsetIndices = vertList;

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
geomChunker = zeros(nVert,length(nv)*length(basisRadii));


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

