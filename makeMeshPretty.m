function makeMeshPretty(mshHandle,data);


%origValues = get(mshHandle,'faceVertexCData');
origValues = data;

validInd = find(~isnan(origValues));
origValues(isnan(origValues))=0;

mesh.uniqueVertices = get(mshHandle,'vertices');
mesh.uniqueFaceIndexList = get(mshHandle,'faces');

conMat = findConnectionMatrix(mesh);

smoothedVals = connectionBasedSmooth(conMat,origValues);

for i=1:100,
    smoothedVals = connectionBasedSmooth(conMat,smoothedVals);
    smoothedVals(validInd) = origValues(validInd)*100;
    
    set(mshHandle,'faceVertexCData',smoothedVals)
    drawnow;
    disp(i)
end


%set(mshHandle,'facecolor','interp','linestyle','none','faceVertexCData',smoothedVals)
set(mshHandle,'faceVertexCData',smoothedVals)

