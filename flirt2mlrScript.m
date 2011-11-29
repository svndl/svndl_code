% Tmp script to transform FLIRT alignment to VISTA.

%flirt = "LOAD FLIRT TRANSFORM"

volDims = rx.volDims;
%Voxel shift matrix, transform matlab 1 indexing, to 0 indexing for FLIRT
VS = [1 0 0 -1;0 1 0 -1;0 0 1 -1; 0 0 0 1]
%Inplane Dimension matrix.  Transform voxel coordinates to world cordinates for FLIRT
Dinplane = diag([rx.rxVoxelSize 1]);
%Vanat dimension matrix
Dvol = diag([rx.volVoxelSize 1]);




%Matrix to permute dimensions to match
%This is the most difficult one to decide on;
permuteMtx = [ ...
     0     1     0     0;...
     0     0     1     0;...
     1     0     0     0;...
     0     0     0     1;];
 
flipMtx = [...
    -1     0     0   0*volDims(1);
     0    -1     0   volDims(2);
     0     0    -1   volDims(3);
     0     0     0     1];



xform=permuteMtx*flipMtx*flirt*Dinplane*VS;


%shift = [eye(3) [256 256 -32]'; 0 0 0 1]
shift = [eye(3) -rx.rxDims([2 1 3])'./2; 0 0 0 1];
xform = shift*xform/shift;
