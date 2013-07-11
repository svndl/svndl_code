#!/bin/csh

# must have at least  1 argument
if ($#argv < 1) then
   echo ""
   echo "Usage: preprocT2.sh T2_volume T1_brain [betThreshold]"
   echo "default betThreshold = 0.3, smaller values yield larger brains, (0->1)
   echo ""
   exit 1
endif

# betLevel = [0,1].  Smaller values yield larger brains
if ($#argv > 2) then
   set betLevel = $3
else
   set betLevel = 0.3
endif


echo $FSLDIR

set date = (`date "+%Y%m%d_%I%M%p"`)
set stripvolume = FSL_T2_${date}_brain
set multvolume = FSL_T2_${date}_bias
set outRegBrain = FSL_T2_{$date}_align
#set refBrainName = "/raid/MRI/toolbox/FSL/REFImages/meanhumanBrainRef.nii"
set refBrainName = ${2}

# Note: This is the FSL4 BET routine. 
# brain extraction (with the -B) option is already bias corrected.
# We use the -B to take care of hard skull stripping tasks around the neck
# but do the fast step in order to compute the real bias field.
echo "Skullstripping" $1
echo " "
bet ${1} ${stripvolume} -B -f ${betLevel} 

# replace the original skull stripped brain with the non-bias corrected one.
echo "Masking original volume"
echo " "
fslmaths ${1} -mas ${stripvolume}_mask.nii.gz ${stripvolume}
 
echo "Running Fast"
echo " "
fast -t 2 -n 4 -b ${stripvolume}
echo "Done"
echo " "

# Apply the bias correction
fslmaths -dt float ${1} -mul ${stripvolume}_bias ${multvolume}

# Do the registration to a reference brain . 6 DOF only

echo "Computing registration of T2 brain to T1 brain" ${refBrainName}
# Note the -usesqform flag here. Very important.
flirt -usesqform -dof 6 -in ${stripvolume}.nii.gz -ref ${refBrainName} -omat  ${outRegBrain}.txt

# Apply that registration to the original (bias corrrected) volume
echo "Applying xform to bias-corrected data"
flirt -in ${multvolume}.nii.gz -ref ${refBrainName} -applyxfm -init ${outRegBrain}.txt -out FSL_T2_${date}_FINAL -interp sinc 


