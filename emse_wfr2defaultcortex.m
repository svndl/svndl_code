function [msh] = emse_wfr2defaultcortex(wfrFilename,outputName)
%function [msh] = emse_wfr2defaultcortex(wfrFilename,outputName)
%
%A non elegant solution to create a mesh file that works with mrCurrent
%
%It uses the mrMesh format, but doesn't set anything that mrMesh might need
%It just puts things where mrCurrent looks for them.

[vertex face edge meshtype] =	emse_read_wfr(wfrFilename);

vertices = [vertex.y; vertex.x;  vertex.z;];		
vertices(2,:)=-vertices(2,:);

faces = [face.vertex1; face.vertex2; face.vertex3];

nVertices = length(vertices);
nFaces = length(faces);


%The important bits of the structure
msh.data.vertices = vertices;
msh.data.triangles = faces-1;


%These are probably wrong.
msh.data.camera_space = 0;

msh.data.origin = [];
msh.data.normals = [];


%These are probably right, but I don't think get used:
msh.data.colors = repmat([160 160 160 255]',1,nVertices);
msh.data.rotation = eye(3);

save(outputName,'msh')