function mshHandle = drawPrettyScalp(vertices,faces,values,valueInd);
%function mshHandle = drawPrettyScalp(vertices,faces,values,valueInd);
%
%

origValues = zeros(length(vertices),1);
origValues(valueInd) = values;

mesh.uniqueVertices = vertices';
mesh.uniqueFaceIndexList = faces;

conMat = findConnectionMatrix(mesh);

smoothedVals = connectionBasedSmooth(conMat,origValues);

for i=1:10,
    smoothedVals = connectionBasedSmooth(conMat,smoothedVals);
    smoothedVals(valueInd) = values;
end


mshHandle = patch('faces',faces,'vertices',vertices','facecolor','interp','linestyle','-','CData',smoothedVals)