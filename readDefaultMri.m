function [V,vX,vY,vZ] = readDefaultMri(subjId)
%[ctx] = readDefaultCortex(subjId)


anatDir = getpref('mrCurrent','AnatomyFolder');

vAnatFilename=fullfile(anatDir,subjId,'vAnatomy.dat');

if ~exist(vAnatFilename,'file')
    error(['Cannot find anatomy file: ' vAnatFilename]);
end


[V mmPer volSize] = readVolAnat(vAnatFilename);

V = uint8(V);


%loop over dimensions and calculate the voxel coordinates.

for iD = 1:3,
    
    startVal = (mmPer(iD)/2 - 128)/1000;
    endVal   = (volSize(iD)-mmPer(iD)/2 - 127.5)/1000;
    coord{iD} = linspace(startVal,endVal,volSize(iD));
        

end

if nargout >1
%[vX vY vZ] = ndgrid(coord{3},coord{2}, coord{1});
vX = coord{3};
vY = coord{2};
vZ = coord{1};

end

% V = permute(V,[2 3 1]);		% RPI
% V = flipdim(V,3);				% RPS
% V = flipdim(V,1);				% RAS


V(:) = permute(V,[3 2 1]);		% RPI
V(:) = flipdim(V,2);				% RAI
V(:) = flipdim(V,3);				% RAS


% 
% vX = coord{3}; %R
% vY = coord{2}; %A
% vZ = coord{1}; %S

%%%% Add loding registration file
