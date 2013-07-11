function [smoothingMtx] = surfaceBasedSmooth(mesh,sigma);

%nVert = length(mesh.faces)/2+2;
nVert = length(mesh.vertices);

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

%idx = 1;
% colIdx = zeros(nVerts*10);
% rowIdx = [];
% smoothingVal = [];

smoothingMtx = spalloc(nVert,nVert,10*nVert);

tic    
for iVert = 1:nVert,
    % [   iVert length(vertList)]
    
    
    %    iVert
    
    thisVert = iVert;
    
%     list = nthOrderNeighbors(mesh.connectionMatrix,thisVert,2);
%       [tmp list] = find(mesh.connectionMatrix(thisVert,:));
%       list = [thisVert list];

      
      list = mesh.connectionMatrix(thisVert,:);
      list(iVert) = 1;
      
      
%      list = 1:20484;
%     seedVert=find(list==thisVert);
      seedVert = 1;
    distFromThisVert = dijkstra(neighbourDist(list,list),seedVert);
%    distFromThisVert(thisVert) = 0;
    
%    patchVertList = distFromThisVert<=basisRadii(iBasis);
    patchVertList = list;
    
    
    
    thisCol = zeros(1,nVert);
    thisCol(patchVertList) = exp(-(distFromThisVert./(2*sigma)).^2);

%     colIdx(end+1:end+length(list)) = list;
%     rowIdx(end+1:end+length(list)) = thisVert;
%     smoothingVal(end+1:end+length(list)) = thisCol(list)./sum(thisCol(list));
%    
   
    smoothingMtx(thisVert,list) = thisCol(list)./sum(thisCol(list));
 %   idx = idx+1;

 if mod(iVert,1000)==0
 toc
 tic;
 end
 


end

smoothingMtx = sparse(nVert,nVert,rowIdx,colIdx,smoothingVal);

end



function neighborList = nthOrderNeighbors(connectionMatrix,startIdx,n)

neighborList=startIdx;

 for iOrder = 1:n,
     
     [i,j]=find(connectionMatrix(neighborList,:));
     neighborList = unique(j);
 end
end
