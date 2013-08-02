function fsRibbon2NiftiClass(ribbonFile,classFile)
%fsRibbon2NiftiClass changes numbers in ribbon file for vista class
%
%fsRibbon2NiftiClass(ribbonFile,classFile)

% assumes the following was done first:
% mri_convert /raid/MRI/anatomy/FREESURFER_SUBS/subjid/mri/ribbon.mgz /raid/MRI/anatomy/subject/nifti/xxx.nii.gz


if ~(nargin==2)
    disp('USAGE: fsRibbon2NiftiClass(ribbonFileName,classFileName)');
    return;
end
 
if ~exist(ribbonFile,'file')
    error([ribbonFile,' doesn''t exist'])
end
[segPath,segFile,ext] = fileparts(ribbonFile);
segFile = [segFile,ext];
    % else
% 	[segFile,segPath]= uigetfile({'*.nii;*.nii.gz','nifti files'},'Freesurfer ribbon file');
% 	if isnumeric(segFile)
% 		return
%	end


%% LOAD NIFTI FILE
try
    NII = readFileNifti(fullfile(segPath,segFile));
catch
    NII = readFileNifti_stable(fullfile(segPath,segFile));
end
classInfo = [0 0; 2 16; 41 16; 3 32; 42 32];
classInfoL = [0 0; 2 16; 41 0; 3 32; 42 0];
classInfoR = [0 0; 2 0; 41 16; 3 0; 42 32];

%% WRITE CLASS FILE
% PIR oriented - note: writeClassFileFromRaw transposes slices
% 0 = unknown, 16 = white matter, 32 = gray, 48 = CSF

    
% map the replacement values
invals  = [3 2 41 42];
outvals = [5 3  4  6];
labels  = {'L Gray', 'L White', 'R White', 'R Gray'};

fprintf('\n\n****************\nConverting voxels....\n\n');
for ii = 1:4;
    inds = NII.data == invals(ii);
    NII.data(inds) = outvals(ii);
    fprintf('Number of %s voxels \t= %d\n', labels{ii}, sum(inds(:)));
end

NII.fname = classFile;
    
writeFileNifti(NII)
    
 

return
