#!/bin/csh

# this isn't working with FSL4.1's fast syntax - figure out how to detect.

# must have at least  1 argument
if ($#argv < 1) then
   echo ""
   echo "Usage: preprocT2.sh T2-WholeHead T1-Brain [betLevel]"
   echo ""
   exit 1
endif

@ tic = `date +%s`

#set refBrainName = "/raid/MRI/toolbox/FSL/REFImages/meanhumanBrainRef.nii"
set refBrainName = $2

# betLevel = [0,1]
# smaller betLevels lead to larger brain outline estimates
set betLevel = 0.3;
if ($#argv > 2) then
   set betLevel = $3
endif

echo " "
which fsl	# Just to check, in case you have many versions lying around
echo " "

set dateStr = (`date "+%Y%m%d_%I%M%p"`)
set brainVol = T2_{$dateStr}_brain		# brain extracted
set biasVol = T2_{$dateStr}_unbias		# bias corrected
set refXFM = T2_{$dateStr}_align		# transorm to reference
set regVol = T2_{$dateStr}_FINAL		# aligned

# Note: This is the FSL4 BET routine. 
# brain extraction (with the -B) option is already bias corrected.
# We use the -B to take care of hard skull stripping tasks around the neck
# but do the fast step in order to compute the real bias field.
echo "Extracting brain from" $1
echo " "
bet $1 $brainVol -B -f $betLevel
# replace the original skull stripped brain with the non-bias corrected one.
fslmaths $1 -mas {$brainVol}_mask $brainVol
 
echo "Correcting bias"
echo " "
#fast -t2 -c 4 -l 100 -i 8 -oba 100 $brainVol	# FSL 4.0
fast -t 2 -n 4 -l 15 -b --nopve $brainVol		# FSL414 no dilation iteration option on output bias field.  try --nopve?
#rm {$brainVol}_abias.nii.gz
rm {$brainVol}_seg.nii.gz
#fslmaths -dt float $1 -mul {$brainVol}_bias $biasVol		# FSL 4.0
fslmaths -dt float $1 -div {$brainVol}_bias $biasVol		# FSL 4.14

echo "Registering T2 brain to" $refBrainName
echo " "
# Note the -usesqform flag here.
flirt -in $brainVol -ref $refBrainName -dof 6 -usesqform -omat  $refXFM.txt
flirt -in $biasVol -ref $refBrainName -out $regVol -applyxfm -init $refXFM.txt -interp sinc 

@ toc = `date +%s`
@ sec = $toc - $tic
@ hr  = $sec / 3600
@ sec = $sec - 3600 * $hr
@ min = $sec / 60
@ sec = $sec - 60 * $min
echo Done.  Elapsed time = $hr hours $min minutes $sec seconds
echo ""

exit 0
