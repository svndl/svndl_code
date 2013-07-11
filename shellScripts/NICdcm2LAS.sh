#!/bin/csh

if ($#argv < 2) then
	echo ""
	echo "Usage: NICdcm2LAS.sh DicomDirectory NiftiFileName"
	echo ""
 	echo "Converts structural volume from NIC to *.nii.gz format w/ LAS orientation"
	exit 1
endif


# look for dicoms
if ( ! -d $1 ) then
	echo $1 "is not a directory."
	exit 1
endif
set dcmFiles = `ls $1/*.dcm`
@ ndcm = `echo $dcmFiles | wc -w`
if ( $ndcm == 0 ) then
	echo "No *.dcm files found in" $1
	exit 1
endif

# trim extension from 2nd input if needed
set outFile = $2
@ dot = `expr $outFile : '.*\.'`
while ( $dot != 0 )
	@ dot --
	set outFile = `echo $outFile | cut -c 1-$dot`
	@ dot = `expr $outFile : '.*\.'`
end

# convert to nii.gz
mri_convert $dcmFiles[1] $outFile.nii.gz

# reorient to LAS
fslswapdim $outFile z -x -y $outFile

exit 0

