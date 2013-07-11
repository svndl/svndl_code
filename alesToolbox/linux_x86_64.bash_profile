export FREESURFER_HOME=/raid/MRI/toolbox/MGH/fs4
export SUBJECTS_DIR=/raid/MRI/anatomy/FREESURFER_SUBS/
export FSLDIR=/raid/MRI/toolbox/FSL/fsl4_centos5/fsl/
export FSLOUTPUTTYPE NIFTI_GZ
source $FREESURFER_HOME/FreeSurferEnv.sh

# DO MNE STUFF

export MNE_ROOT=/raid/MRI/toolbox/MNESuite/mne_linux_x86_64

source $FREESURFER_HOME/SetUpFreeSurfer.sh

source /raid/MRI/toolbox/MNESuite/mne_linux_x86_64/bin/mne_setup_sh


