function mrGrayWM2mgz(subjid)
% convert mrGray white matter segmentation into a nifti format volume
% that can be converted to mgz & loaded back into freesurfer
%
% >> mrGrayWM2mgz(subjid)
% writes /raid/MRI/anatomy/subjid/nifti/subjid_mrGray_wm.nii
% 
% $ mri_convert subjid_mrGray_wm.nii /raid/MRI/anatomy/FREESURFER_SUBS/subjid_fs4/mri/wm.mgz
% $ recon-all -autorecon2-wm -subjid subjid_fs4
% $ recon-all -autorecon3 -subjid subjid_fs4
% you might want to make a copy of the default wm.mgz somewhere first, as it'll get overwritten

if ispc
	anatDir = 'X:\anatomy';
else
	anatDir = '/raid/MRI/anatomy';
end

% mrGray Class-files: uint8 PIR orientation (right-handed)
classL = readClassFile(fullfile(anatDir,subjid,'left','left.Class'),false,false);
classR = readClassFile(fullfile(anatDir,subjid,'right','right.Class'),false,false);

% combine hemispheres, set white matter value
wmVal = 110;
classL.data( classL.data ~= classL.type.white ) = 0;
classL.data( classL.data == classL.type.white ) = wmVal;
classL.data( classR.data == classR.type.white ) = wmVal;

% convert to LIA (left-handed)
classL.data = permute(classL.data,[3 2 1]);		% RIP
classL.data = flipdim(classL.data,1);				% LIP
classL.data = flipdim(classL.data,3);				% LIA

% get xfm from existing file
niiDir = fullfile(anatDir,subjid,'nifti');
N = readFileNifti(fullfile(niiDir,[subjid,'_FS4_brain.nii.gz']));
if ~true
	xfm = N.sto_xyz;
	xfm(2:3,2:3) = [0 1;-1 0];
	xfm(3,4) = xfm(3,4) + 257;
	scode = 1;
	qcode = 0;
else
	xfm = N.qto_xyz;
	xfm(2:3,2:3) = [0 1;-1 0];
	xfm(3,4) = xfm(3,4) + 255;
	scode = 0;
	qcode = 1;
end
clear N

sclSlope = 0;		% 0 in converted wm.mgz, 1 makes more sense?
description = 'mrGray segmentation';
% intentName = '';
% intentCode = 0;	%?
N = niftiGetStruct(classL.data,xfm,sclSlope,description); %,intentName,intentCode)
N.fname = strcat(subjid,'_mrGray_wm.nii');
N.qform_code = qcode;
N.sform_code = scode;

wd = pwd;
try
	cd(niiDir)
	disp(['writing ',fullfile(niiDir,N.fname)])
	writeFileNifti(N)
	disp('done.')
	cd(wd)
catch
	cd(wd)
end





