#!/bin/csh

if ($#argv < 2) then
	echo ""
	echo "Usage: FS4anat subjid base"
	echo ""
	exit 1
endif

set vols = ( orig nu brain ribbon)

@ n = `echo $vols | wc -w`
@ i = 1
while ( $i <= $n )
#Change from absolute path to work with OSX
#	/raid/MRI/toolbox/SperoToolbox/HeadModels/FSmgz2LAS.sh $1 $vols[$i] {$2}_FS4_$vols[$i]
	FSmgz2LAS.sh $1 $vols[$i] {$2}_FS4_$vols[$i]

	@ i ++ 


end

set vol3 = ribbon
set vol4 = wm

echo RUNING:
echo 
echo fslmaths {$2}_FS4_$vol3.nii.gz -thr 2 -uthr 2 tmpWhiteL
echo fslmaths {$2}_FS4_$vol3.nii.gz -thr 41 -uthr 41 tmpWhiteR
echo fslmaths tmpWhiteL.nii.gz -add tmpWhiteR.nii.gz -bin {$2}_FS4_$vol4.nii.gz

fslmaths {$2}_FS4_$vol3.nii.gz -thr 2 -uthr 2 tmpWhiteL
fslmaths {$2}_FS4_$vol3.nii.gz -thr 41 -uthr 41 tmpWhiteR
fslmaths tmpWhiteL.nii.gz -add tmpWhiteR.nii.gz -bin {$2}_FS4_$vol4.nii.gz

rm tmpWhiteL.nii.gz
rm tmpWhiteR.nii.gz


if( ! -e $SUBJECTS_DIR/$1/mri/T2.mgz ) then


else
mri_convert $SUBJECTS_DIR/$1/mri/T2.mgz {$2}_FS4_T2.nii.gz
fslswapdim {$2}_FS4_T2.nii.gz x z -y {$2}_FS4_T2.nii.gz

echo "T2 taken from FreeSurfer."
endif

echo "done converting Freesurfer volumes."
echo "now run preprocT2.sh T2LASvolume " {$2}_FS4_$vols[3].nii.gz " [betLevel]"






exit 0



set vol0 = orig
set vol1 = nu
set vol2 = brain

# CONVERT TO NIFTI (RAS orientation)
# mri_convert $SUBJECTS_DIR/$1/mri/$vol0.mgz /raid/MRI/anatomy/$2/Standard/EMSE/${2}_FS4_$vol0.img
mri_convert $SUBJECTS_DIR/$1/mri/$vol0.mgz {$2}_FS4_$vol0.nii.gz
mri_convert $SUBJECTS_DIR/$1/mri/$vol1.mgz {$2}_FS4_$vol1.nii.gz
mri_convert $SUBJECTS_DIR/$1/mri/$vol2.mgz {$2}_FS4_$vol2.nii.gz
mri_convert $SUBJECTS_DIR/$1/mri/$vol3.mgz {$2}_FS4_$vol3.nii.gz

# REORIENT FOR FSL (LAS)
fslswapdim {$2}_FS4_$vol0.nii.gz x z -y {$2}_FS4_$vol0.nii.gz
fslswapdim {$2}_FS4_$vol1.nii.gz x z -y {$2}_FS4_$vol1.nii.gz
fslswapdim {$2}_FS4_$vol2.nii.gz x z -y {$2}_FS4_$vol2.nii.gz
fslswapdim {$2}_FS4_$vol3.nii.gz x z -y {$2}_FS4_$vol3.nii.gz

# MAKE WM MASK FROM RIBBON
# fslmaths {$2}_{$vol3}_LAS.nii.gz -min 1 {$2}_ribbonMask_LAS.nii.gz





