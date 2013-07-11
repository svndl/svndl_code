#!/bin/csh

# average 2 anatomical volumes
# replacement for averageAnalyze.m which used SPM
# FSL yields better results

if ($#argv < 3) then
	echo ""
	echo "Usage: avg2anats.sh inputVolume1 inputVolume2 outputVolume [searchAngle] [costFcn]"
	echo "       average outputVolume is registered to inputVolume2."
	echo ""
	exit 1
endif


if ($#argv > 3) then
	set searchAngle = $4
else
	set searchAngle = 15
endif

# COST OPTIONS:
# mutualinfo,corratio,normcorr,normmi,leastsq (flirt default = corratio)
# mutualinfo & normmi seem ~same & better than the others
if ($#argv > 4) then
	set costFcn = $5
else
	set costFcn = mutualinfo
endif


set dot = `expr index $1 .`
if ($dot == 0) then
	set baseFile1 = $1
else
	set dot = `expr $dot - 1`
	set baseFile1 = `expr substr $1 1 $dot`
endif
set dot = `expr index $2 .`
if ($dot == 0) then
	set baseFile2 = $2
else
	set dot = `expr $dot - 1`
	set baseFile2 = `expr substr $2 1 $dot`
endif
set tmpFile = {$baseFile1}_align
set xfmFile = {$baseFile1}_to_{$baseFile2}.txt

# ALIGN
# option -displayinit asks for argument???
flirt -cost $costFcn -searchcost $costFcn -usesqform -interp sinc -dof 6 -searchrx -$searchAngle $searchAngle -searchry -$searchAngle $searchAngle -searchrz -$searchAngle $searchAngle -coarsesearch 4 -finesearch 0.5 -in $1 -ref $2 -out $tmpFile -omat $xfmFile -v

# COMBINE
fslmaths $2 -add $tmpFile -mul 0.5 $3

# CLEANUP - assuming FSLOUTPUTTYPE = NIFTI-GZ
rm $tmpFile.nii.gz
cat $xfmFile

echo "done"
exit 0

