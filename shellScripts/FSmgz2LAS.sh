#!/bin/csh

if ($#argv < 3) then
	echo ""
 	echo "Converts a Freesurfer *.mgz volume to *.nii.gz format w/ LAS orientation"
	echo ""
	echo "Usage: FSmgz2LAS.sh FreesurferSubjectID Volume niigzFile"
	echo "  e.g. FSmgz2LAS.sh skeri9999_fs4 nu skeri9999_FS4_nu"
	exit 1
endif

# add .mgz extension to 2nd input (if needed)
set mgzFile = $2
@ dot = `expr $mgzFile : '.*\.'`
if ( $dot == 0 ) then
	set mgzFile = $mgzFile.mgz
endif
set mgzFile = $SUBJECTS_DIR/$1/mri/$mgzFile

# check for .mgz file
if ( ! -e $mgzFile ) then
	echo $mgzFile "does not exist."
	exit 1
endif

# trim extension(s) from 3rd input (if needed)
set niiFile = $3
@ dot = `expr $niiFile : '.*\.'`
while ( $dot != 0 )
	@ dot --
	set niiFile = `echo $niiFile | cut -c 1-$dot`
	@ dot = `expr $niiFile : '.*\.'`
end

# check for .nii.gz file
if ( -e $niiFile.nii.gz ) then
	printf "\n%s.nii.gz already exists, replace? (y/n): " $niiFile
	set resp = $<
	if ( `echo $resp | cut -c 1` != "y" ) then
		exit 1
	endif
endif

# convert to nii.gz
mri_convert $mgzFile $niiFile.nii.gz

# reorient to LAS
fslswapdim $niiFile x z -y $niiFile

exit 0

