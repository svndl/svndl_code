#!/bin/csh

# rigid alignment of 2 anatomical volumes w/ flirt

if ($#argv < 3) then
	echo ""
	echo "Usage: align2anats.sh inputVolume referenceVolume outputVolume [searchAngle] [costFcn]"
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

# ALIGN
flirt -cost $costFcn -searchcost $costFcn -usesqform -interp sinc -dof 6 -searchrx -$searchAngle $searchAngle -searchry -$searchAngle $searchAngle -searchrz -$searchAngle $searchAngle -coarsesearch 5 -finesearch 1 -in $1 -ref $2 -out $3



