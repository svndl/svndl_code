function []= fsl2tri(fslFile);
%function []= fsl2tri(fslFile);


[vertices faces] = geomview_read_off(fslFile);


vertices = vertices - 128;
vertices(:,1) = -vertices(:,1);

[path,name,ext] = fileparts(fslFile);

thisSurfName = [name '.tri']

[fid,msg] = fopen(thisSurfName,'w')

nVertices = length(vertices);
nFaces = length(faces);

fprintf(fid,'%i\n',nVertices);

for i=1:nVertices,
    fprintf(fid,'%d %d %d\n',vertices(i,:));
end

fprintf(fid,'%i\n',nFaces);

for i=1:nFaces,
    fprintf(fid,'%i %i %i\n',faces(i,:));
end


