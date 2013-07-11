#!/bin/csh

# Must have 5 arguments
if ($#argv != 5) then
   echo ""
   echo "Usage: getBEMsurfs T1_volume T2_volume x_center y_center z_center"
   echo "assumes T1 and T2 volumes are already aligned."
   echo ""
   exit 1
endif

# extract a brain mask from the T2-weighted image
# yields better innerskull shell than vtk mesh from T1-weighted image
echo "Extracting brain from T2-weighted image"
bet2 $2 headmodel_T2brain -m -e -c $3 $4 $5

# register T1-weighted image to standard space
echo "Aligning T1-weighted image to standard space"
flirt -usesqform -in $1 -ref $FSLDIR/data/standard/MNI152_T1_1mm -omat headmodel_T1xfm.txt

# get BEM surfaces
echo "Estimating inner skull, outer skull, and scalp surfaces"
betsurf -m $1 $2 headmodel_T2brain_mesh.vtk headmodel_T1xfm.txt headmodel

exit 0







