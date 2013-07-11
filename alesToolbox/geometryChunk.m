function [geomChunker vertSubsetIndices allPatchAreas] = geometryChunk(mesh,finalSize);
%function [geomChunker vertSubsetIndices allPatchAreas] = geometryChunk(mesh,finalSize);
% This function tries to do a geodesic tiling of a cortex
% mesh = Matlab mesh.face mesh.vertices style mesh
% finalSize = number of sources to keep
%
% geomChunker is a matrix that maps the chunks
% vertSubsetIndices 
% allPatchAreas are the patchAreas

nVert = length(mesh.faces)/2+2;
%length(mesh.vertices);

reductionFactor = finalSize/nVert;

[nf nv] = reducepatch(mesh,reductionFactor);

[vertList] = nearpoints(nv',mesh.vertices');

vertSubsetIndices = vertList;

surfArea = mesh_face_area(mesh);


totalArea = sum(surfArea)
patchArea = .5*(totalArea/finalSize)

%if ~isfield(mesh,'edge'),
%    mesh.edge = mesh_edges(mesh);
%end
geomChunker = zeros(nVert,length(nv));

for iVert = 1:length(vertList),
% [   iVert length(vertList)]

    thisVert = vertList(iVert);

    patchVertList = thisVert;
    thisPatchArea = 0;
    while thisPatchArea<patchArea,
        lastFoundList = patchVertList;
        
        %for iPv = lastFoundList',
        %    [ni]= mesh_vertex_neighbours(mesh,iPv);
        %    patchVertList = unique([patchVertList; ni]);
        %end
        
        [fi j ] = find(ismember(mesh.faces,patchVertList));
        uf = unique(fi);
        
        theseFaceVerts = mesh.faces(uf,:);
        patchVertList = unique(theseFaceVerts(:));
        
        thisPatchArea = sum(surfArea(uf));
        
    end


   thisCol = zeros(nVert,1);
   thisCol(patchVertList) = 1;
   geomChunker(:,iVert) = thisCol;
   allPatchAreas(iVert) = thisPatchArea;
   
end

