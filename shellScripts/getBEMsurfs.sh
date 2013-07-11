#!/bin/bash
umask 12

# to do: get center coords for bet from standard brain through inverse of registration?

#source ~/.cshrc
if [ "$#" -ne 5 ] 
then
   echo "Must have 5 arguments"
   echo ""
   echo "Usage: getBEMsurfs T1volume T2volume x_center y_center z_center"
   echo "assumes T1 and T2 volumes are already aligned."
   echo ""
   exit 1
fi

base=headmodel
baseHiRes=${base}P1
brain=${base}_T2brain
xfm=${base}_T1ref

#echo $baseHiRes

# date=(`date "+%Y%m%d%I%M"`)

# extract a brain mask to using the T2 for use as the inner skull mesh
# I find the T2 brain mask makes a good innerskull boundary.

# -e generates brain surface mesh in vtk format
# -m generates mask
echo " "
echo "Extracting brain from T2"
bet2 $2 $brain -e -m -c $3 $4 $5

# register T1 to standard space
# output registered volume so you'll have something to debug?
echo "Aligning T1 with standard space"
flirt -usesqform -ref $FSLDIR/data/standard/MNI152_T1_1mm -in $1 -omat $xfm.txt -out $xfm

# find other surfaces
echo "extracting inner skull, outer skull, and scalp surfaces/volumes"
#betsurf -m -s -p 1 $1 ${2} ${base}_T2brain_mesh.off ${base}_T1ref.txt betsurf
betsurf -m -s $1 $2 ${brain}_mesh.vtk $xfm.txt $base
betsurf -m -s -p 1 $1 $2 ${brain}_mesh.vtk $xfm.txt $baseHiRes

# replace the skull surfaces with the high res versions.

echo $baseHiRes $base
mv $baseHiRes_inskull_mesh.off $base_inskull_mesh.off
mv $baseHiRes_inskull_mask.nii.gz $base_inskull_mask.nii.gz
mv $baseHiRes_outskull_mesh.off $base_outskull_mesh.off
mv $baseHiRes_outskull_mask.nii.gz $base_outskull_mask.nii.gz
mv $baseHiRes_skull_mask.nii.gz $base_skull_mask.nii.gz

rm $baseHiRes*


echo " "
exit 0







