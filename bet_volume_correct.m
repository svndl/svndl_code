function [iskullVol oskullVol scalpVol] = bet_volume_correct(iskullFile, oskullFile, scalpFile,tol);


skullTol = tol(1);

iskullVol = load_nii(iskullFile);
iskullVol = iskullVol.img;

oskullVol = load_nii(oskullFile);
oskullVol = oskullVol.img;


scalpVol = load_nii(scalpFile);
scalpVol = scalpVol.img;


%calculate distance between iskull distance field
%each voxel contains the distance to the nearest skull voxel
%iskullDist = bwdist(iskullVol);


%justSkull = oskullVol & ~iskullVol;

%Skull = ~oskullVol;


%calculate the distance to the inner skull
%toInSkull = iskullDist.*(~oskullVol);

%min(toInSkull(:))



%calculate the euclidean distance to the outer skull boundary
%dist2OutSkull = bwdist(~oskullVol);


%mask the previous volume with voxels just inside the inner skull boundary
%inskullDist = dist2OutSkull.*inskullVol;

%Find the minimum distance from the inner skull boundary to the outer skull
%boundary

%minSkullThickness = min(inskullDist(:))
[x y z] = meshgrid(1:256,1:256,1:256);
volCoords = [x(:) y(:) z(:)];

insideSkullCoords = find(iskullVol);

oskullGrown = oskullVol;
for i=1:1,

%Find the coordinates of all voxels outside the skull, but still in the head
outsideSkull = ~oskullGrown&scalpVol;
outsideSkullCoords = find(outsideSkull(:));

%Calculate the distance from the inner skull voxels to the voxels outside
%the skull
%this step takes a while, could speed it up by pruning voxels we don't care
%about, we really just care about the boundary voxels
[ind, sqdist] = nearpoints(volCoords(insideSkullCoords,:)',volCoords(outsideSkullCoords,:)');

%Get the smallest distance to an outside skull voxel
minSkullThickness = min(sqdist)

if minSkullThickness < skullTol

    myBall = strel('ball',2,2)
    iskullDilated = imdilate(iskullVol,myBall);
end

%grow the outer skull in places that the skull thickness is to small
%this is slightly tricky
%First dilate the inner skull, then add that volume to the outer skull volume
%If the inner skull grows outisde the outer skull that will increase the
%thickness of the outer skull,
%This doesn't effect the skull volume in places where the skull thickness
%is large enough.

oskullGrown = iskullDilated|oskull;


end
