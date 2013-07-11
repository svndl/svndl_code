function []= wfr2tri(wfrFile);
%function []= wfr2tri(wfrFile);
%
%This function takes an emse wfr file and writes out a .tri file and a .dec
%file that are compatible with MNESuite

[vertex face] = emse_read_wfr(wfrFile);

vertices = [vertex.z; vertex.y; vertex.x]';
vertices = vertices -128;
vertices(:,2) = -vertices(:,2);

faces    = [face.vertex3; face.vertex2; face.vertex1]';


[path,name,ext] = fileparts(wfrFile);

thisSurfName = [name '.tri']

[fid,msg] = fopen(thisSurfName,'w');

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


thisDecName = [name '.dec'];

[fid,msg] = fopen(thisDecName,'wb','b');

fwrite(fid,[0],'uint8');
fwrite(fid,length(vertices),'uint32');
fwrite(fid,ones(length(vertices),1),'uint8');







