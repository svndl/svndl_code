function [msh] = fs_inflated2defaultcortex(freesurferSubjectDir,outputName)
%function [msh] = emse_wfr2defaultcortex(wfrFilename,outputName)
%
%A non elegant solution to create a mesh file that works with mrCurrent
%
%It uses the mrMesh format, but doesn't set anything that mrMesh might need
%It just puts things where mrCurrent looks for them.

nVertices = 0;
vertices = [];
faces = [];
hemiOffset = [-55 55];
idx = 1;
for hemi = [ 'l' 'r'],
%for hemi = [ 'l'],
        
    %construct the fs filename
    fsMeshFilename = fullfile(freesurferSubjectDir, 'surf', [hemi 'h.inflated']);

%    [fsVertex,fsFace]=freesurfer_read_surf(fsMeshFilename);

    

    % Emse to FS coordinate systems are driving me bonkers -jma
    % the following code recreates the transforms that happen when writing
    % out an emse .wfr file, these transformations seem to span a few files:
    % fs_writeEMSEMeshfromFreesurfer does the first one
    % mesh_write_emse does the last 3,
    % I'm  fairly befuddled as to where/how/why this transformations occur
    % but this seems to work
    [fsVertex,fsFace]=freesurfer_read_surf(fsMeshFilename);

   % fsVertex = fsVertex(:,[2 3 1]);

   % fsVertex = rz(fsVertex,-90,'degrees'); % default -90 **** LGA
   % fsVertex(:,3)=-fsVertex(:,3);
    fsVertex(:,1)=fsVertex(:,1)+hemiOffset(idx);
   
  %  fsVertex = fsVertex+128;
%    vertex.(hemi) = fsVertex;

%vertex.both = [vertex.r;vertex.l];
%fsVertexList.r = 1:length(vertex.r);
%fsVertexList.l = [1:length(vertex.l)]+length(vertex.r);




vertices=[vertices;fsVertex];
faces=[faces;fsFace+nVertices];

nVertices = length(fsVertex);
nFaces = length(fsFace);

idx = idx+1;
end





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