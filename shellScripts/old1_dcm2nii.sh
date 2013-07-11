#!/bin/csh
# Convert raw 3D & 4D .dcm series to .nii.gz using mri_convert
# works with dicom format from the NIC (*.dcm extension, 1 folder per scan)


@ FSLtc = 0	# Flag for FSL slicetime compensation
@ FSLmc = 1	# Flag for FSL motion compensation
echo ""


# CHECK FOR FREESURFER & FSL
if ( ! $?FREESURFER_HOME ) then
	echo ERROR: Freesurfer required for dcm2nii.sh; echo ""
	exit 1
endif
if ( $?FSLDIR ) then
	if ( $FSLOUTPUTTYPE != NIFTI_GZ ) then
		echo ERROR: Change FSLOUTPUTTYPE to NIFTI_GZ; echo ""
		exit 1
	endif
else
	echo ERROR: FSL required for dcm2nii.sh; echo ""
	exit 1
endif


# CHECK USAGE
if ( $#argv < 2 ) then
	echo "Usage: dcm2nii.sh DICOMdirectory NIfTIdirectory [nVol] [startFrame] [numFrames] [fmriDirPrefix] [anatomyDirPrefix]"
	echo "  e.g. dcm2nii.sh RawDicom nifti 123 ep2d t1_se_tra"
	echo ""
	exit 1
endif
set dcmDir = $1
set niiDir = $2


# CHECK IF DIRECTORIES EXIST, CHECK & TRIM TRAILING "/"
if ( ! -d $dcmDir ) then
	echo ERROR: DICOM directory $dcmDir does not exist.; echo ""
	exit 1
endif
if ( ! -d $niiDir ) then
	echo ERROR: NIfTI directory $niiDir does not exist.; echo ""
	exit 1
endif
@ nChar = `expr length $dcmDir`
if ( `echo $dcmDir | cut -c $nChar` == "/" ) then
	@ nChar --
	set dcmDir = `echo $dcmDir | cut -c 1-$nChar`
endif
@ nChar = `expr length $niiDir`
if ( `echo $niiDir | cut -c $nChar` == "/" ) then
	@ nChar --
	set niiDir = `echo $niiDir | cut -c 1-$nChar`
endif


# SET DEFAULTS, CHECK OPTIONAL INPUTS
@ nVol = 0			# when nVol!=0, only recons scans with nVol volumes
@ startFrame = 0		# 0-based indexing
@ nFrames = 0			# when nFrames!=0, extracts nFrames from time series starting @ startFrame
set fmriSearch = ep2d_		# search prefix for folders of functional scans 
set anatSearch = t1_se_tra_	# search prefix for folders of inplane anatomy scans
if ( $#argv >= 3 ) then
	@ nVol = $3
endif
if ( $#argv >= 4 ) then
	@ startFrame = $4
endif
if ( $#argv >= 5 ) then
	@ nFrames = $5
endif
if ( $#argv >= 6 ) then
	set fmriSearch = $6
endif
if ( $#argv >= 7 ) then
	set anatSearch = $7
endif


# COUNT DICOM DIRECTORIES i.e. SCANS
set anatDcmDirs = `ls -d $dcmDir/$anatSearch*`
set fmriDcmDirs = `ls -d $dcmDir/$fmriSearch*`
@ nAnat = `echo $anatDcmDirs | wc -w`
@ nFmri = `echo $fmriDcmDirs | wc -w`
if ( $nFmri == 0 ) then 
	echo ERROR: No fMRI scans found.; echo ""
	exit 1
endif
if ( $nAnat == 0 ) then
	echo WARNING: No anatomical inplane scan found.; echo ""
endif


# GET 1ST DICOM FILE IN INPLANE SERIES
@ i = 1
set anatDcm1 = ()
set anatSeries = ()
while ( $i <= $nAnat )
	set dcmFiles = `ls $anatDcmDirs[$i]/*.dcm`
	set anatDcm1 = ( $anatDcm1 $dcmFiles[1] )			# 1-indexing
	set anatSeries = ( $anatSeries `echo $anatDcmDirs[$i] | sed 's/_/ /g' | awk '{ print $NF }'` )
	@ i ++
end

# GET 1ST DICOM FILE IN FUNCTIONAL SERIES
@ nDcm = 0
@ i = 1
set fmriDcm1 = ()
set fmriSeries = ()
#set fmriNvols = ()
while ( $i <= $nFmri )
	set dcmFiles = `ls $fmriDcmDirs[$i]/*.dcm`
	if ( $nVol != 0 ) then
		@ nDcm = `echo $dcmFiles | wc -w`
	endif
	if ( $nDcm == $nVol ) then
		set fmriDcm1 = ( $fmriDcm1 $dcmFiles[1] )
		set fmriSeries = ( $fmriSeries `echo $fmriDcmDirs[$i] | sed 's/_/ /g' | awk '{ print $NF }'` )
		@ i ++
	else
		echo $fmriDcmDirs[$i] has $nDcm volumes, not $nVol
		@ im1 = $i - 1
		@ ip1 = $i + 1
		set fmriDcmDirs = ( $fmriDcmDirs[1-$im1] $fmriDcmDirs[$ip1-] )
		@ nFmri --
	endif
end
echo ""
if ( $nFmri == 0 ) then
	# already checked for nFmri=0 prior to nVol filter
	echo ERROR: No fMRI dicom directories with $nVol images.; echo ""
	exit 1
endif

# SORT SERIES NUMBERS
set anatSort = `echo $anatSeries | sed 's/ /\n/g' | sort -n`
@ i = 1
set anatIndex = ()
while ( $i <= $nAnat )
	@ j = 1
	while ( $anatSeries[$j] != $anatSort[$i] )
		@ j ++
	end
	set anatIndex = ( $anatIndex $j )
	@ i ++
end
set fmriSort = `echo $fmriSeries | sed 's/ /\n/g' | sort -n`
@ i = 1
set fmriIndex = ()
while ( $i <= $nFmri )
	@ j = 1
	while ( $fmriSeries[$j] != $fmriSort[$i] )
		@ j ++
	end
	set fmriIndex = ( $fmriIndex $j )
	@ i ++
end

# CHOOSE ONE, IF MULTIPLE INPLANES
if ( $nAnat == 1 ) then
	@ iAnat = 1
else if ( $nAnat > 1 ) then
	echo WARNING: Multiple anatomical inplane scans found.
	echo functional series = [ $fmriSort ]
	echo anatomical series = [ $anatSort ]
	echo ENTER an anatomical series:
	set choice = $<
	@ i = 1
	while ( ($i < $nAnat ) && ( $anatSeries[$i] != $choice ) )
		@ i ++
	end
	if ( $anatSeries[$i] == $choice ) then
		@ iAnat = $i
	else
		echo ERROR: choice is not one of options.; echo ""
		exit 1
	endif
	echo ""
endif


# CHOOSE REFERENCE FUNCTIONAL, IF DOING MOTION COMPENSATION
if ( $FSLmc != 0 ) then
	if ( $nFmri == 1 ) then
		@ iFmri = 1
	else
		if ( $nAnat == 0 ) then
			echo anatomical series = []
		else
			echo anatomical series = [ $anatSeries[$iAnat] ]
		endif
		echo functional series = [ $fmriSort ]
		echo ENTER functional series to use as reference for between-scans motion compensation:
		set choice = $<
		@ i = 1
		while ( ($i < $nFmri ) && ( $fmriSeries[$i] != $choice ) )
			@ i ++
		end
		if ( $fmriSeries[$i] == $choice ) then
			@ iFmri = $i
		else
			echo ERROR: choice is not one of options.; echo ""
			exit 1
		endif
		echo ""
	endif
endif


# CONVERT TO NIfTI
if ( $nAnat != 0 ) then
	@ j = $iAnat
#	@ i = 1
#	while ( $i <= $nAnat )
#		@ j = $anatIndex[$i]
		@ slash = `expr $anatDcmDirs[$j] : '.*/'`
		@ slash ++
		@ under = `expr $anatDcmDirs[$j] : '.*_'`
		set prefix  = `echo $anatDcmDirs[$j] | cut -c $slash-$under`
		set fileName = `printf "%s/%s%02d" $niiDir $prefix $anatSeries[$j]`
		if ( -e $fileName.nii.gz ) then
			echo $fileName.nii.gz exists
		else
			mri_convert $anatDcm1[$j] $fileName.nii.gz
			fslswapdim $fileName y x z $fileName
			fslorient -swaporient $fileName
		endif
		echo ""
#		@ i ++
#	end
endif

@ i = 1
set fmriNii = `echo $fmriSeries`
while ( $i <= $nFmri )
	@ j = $fmriIndex[$i]
	@ slash = `expr $fmriDcmDirs[$j] : '.*/'`
	@ slash ++
	@ under = `expr $fmriDcmDirs[$j] : '.*_'`
	set prefix = `echo $fmriDcmDirs[$j] | cut -c $slash-$under`
	set series = `printf "%02d" $fmriSeries[$j]`
	set fmriNii[$j] = $niiDir/$prefix$series
	if ( -e $fmriNii[$j].nii.gz ) then
		echo $fmriNii[$j].nii.gz exists
	else
		mri_convert $fmriDcm1[$j] $fmriNii[$j].nii.gz
		if ( $nFrames != 0 ) then
			fslroi $fmriNii[$j] $fmriNii[$j] $startFrame $nFrames
		endif
		if ( $FSLtc != 0 ) then
			# SLICETIME COMPENSATION
			echo WARNING: slicetimer not built into dcm2nii.sh yet.
		endif
		if ( $FSLmc == 0 ) then
			fslswapdim $fmriNii[$j] y x z $fmriNii[$j]
			fslorient -swaporient $fmriNii[$j]
		else
			fslorient -swaporient $fmriNii[$j]
			fslswapdim $fmriNii[$j] x -y z $fmriNii[$j]
			# WITHIN-SCAN MOTION COMPENSATION
			mcflirt -in $fmriNii[$j] -stages 4 -out {$fmriNii[$j]}_MCw
			if ( $nFmri > 1 ) then
				fslmaths {$fmriNii[$j]}_MCw -Tmean $niiDir/Tmean_MCw_$series
			endif
		endif
	endif
	echo ""
	@ i ++
end

if ( $FSLmc != 0 ) then
	if ( $nFmri > 1) then
		# BETWEEN-SCAN MOTION COMPENSATION
		set refSeries = `printf "%02d" $fmriSeries[$iFmri]`
		set flirtOpts = "-cost mutualinfo -searchcost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -coarsesearch 4 -finesearch 0.5 -dof 6"
		@ i = 1
		while ( $i <= $nFmri )
			@ j = $fmriIndex[$i]
			if ( $j == $iFmri ) then
				cp $fmriNii[$iFmri]_MCw.nii.gz $fmriNii[$iFmri]_MCb$refSeries.nii.gz
			else
				set series = `printf "%02d" $fmriSeries[$j]`
				flirt $flirtOpts -ref $niiDir/Tmean_MCw_$refSeries -in $niiDir/Tmean_MCw_$series -omat $niiDir/MCb_xfm_$series.txt
				flirt -ref $fmriNii[$iFmri]_MCw -in $fmriNii[$j]_MCw -applyxfm -init $niiDir/MCb_xfm_$series.txt -out $fmriNii[$j]_MCb$refSeries
				fslcpgeom $fmriNii[$iFmri]_MCw $fmriNii[$j]_MCb$refSeries	# restore pixdim4 i.e. TR.  flirt resets it to 1.
			endif
			# revert to VistaSoft orientation
			fslswapdim $fmriNii[$j]_MCb$refSeries -y x z $fmriNii[$j]_MCb$refSeries
			echo ""
			@ i ++
		end
	else
		fslswapdim $fmriNii[1]_MCw -y x z $fmriNii[1]_MCw
		echo ""
	endif
endif
echo ""

if ( $nAnat == 0 ) then
	if ( $FSLmc == 0 ) then
		echo anatomical series = []
		echo functional series = [ $fmriSort ]
		echo ENTER functional series to use for high-res alignment
		set choice = $<
		@ i = 1
		while ( ($i < $nFmri ) && ( $fmriSeries[$i] != $choice ) )
			@ i ++
		end
		if ( $fmriSeries[$i] == $choice ) then
			@ iFmri = $i
		else
			echo ERROR: choice is not one of options.; echo ""
			exit 1
		endif
		fslmaths $fmriNii[$iFmri] -Tmean $fmriNii[$iFmri]_Tmean
	else
		echo use Tmean_MCw_$refSeries for Inplanes
	endif
	echo ""
endif


echo --- done ---
echo ""
echo ""

exit 0


# Standard SKERI prescriptions yield LPS NEUROLOGICAL orientations from mri_convert
# note: occipital Rx is LPS if more slices horizontal than vertical, otherwise LIP
#       recon the same either way?
#
# To convert to LAS RADIOLOGICAL for any FSL processing use:
#    fslorient -swaporient filename
#    fslswapdim filename x -y z filename
# Then to re-orient for importing to VistaSoft (PLS RADIOLOGICAL) use:
#    fslswapdim filename -y x z filename
#
# To go from LPS NEURO to VistaSoft orientation w/o any FSL processing use:
#    fslswapdim filename y x z filename
#    fslorient -swaporient filename
#
# LPS NEURO ==[swaporient]==> RPS RADIO (with LR flip) ==[x-yz]==> LAS RADIO ==[-yxz]==> PLS RADIO
# LPS NEURO     ==[yxz]==>    ALS NEURO (with AP flip)          ==[swaporient]==>        PLS RADIO


# LIP NEURO ==[swaporient]==> RIP RADIO (with LR flip) ==[x-yz]==> LSP RADIO ==[-yxz]==> ILP RADIO
#               ==[yxz]==>    SLP NEURO (with IS flip)          ==[swaporient]==>        ILP RADIO


