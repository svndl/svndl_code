#!/bin/csh
# Convert raw 3D & 4D .dcm series to .nii.gz using mri_convert
# works with dicom format from the NIC (*.dcm extension, 1 folder per scan)

# to do:
# figure out how to stop this after intermediate FSL crashes - it keeps going with the next command
# only write slice order file once

@ FSLmc = 1		# Flag for FSL motion compensation
@ cleanup = 1	# Flag for removing intermediate files when done

echo ""

# --------------------------------------------------------------------------------------------
# CHECK PREREQUISITES: FREESURFER & FSL
if ( ! $?FREESURFER_HOME ) then
	echo "ERROR: Freesurfer required for dcm2nii.sh"; echo ""
	exit 1
endif
if ( $?FSLDIR ) then
	if ( $FSLOUTPUTTYPE != NIFTI_GZ ) then
		echo "ERROR: Change FSLOUTPUTTYPE to NIFTI_GZ"; echo ""
		exit 1
	endif
else
	echo "ERROR: FSL required for dcm2nii.sh"; echo ""
	exit 1
endif


# --------------------------------------------------------------------------------------------
# CHECK USAGE
if ( $#argv < 2 ) then
	echo "Usage: dcm2nii.sh DICOMdirectory NIfTIdirectory [nVol=0] [startFrame=0] [numFrames=0] [fmriDirPrefix] [anatomyDirPrefix]"
	echo "  e.g. dcm2nii.sh RawDicom nifti 126 6 120 ep2d t1_se_tra"
	echo ""
	echo "INPUTS"
	echo "nVol: if nVol!=0, only process series with nVol volumes per scan."
	echo "      if nVol==0, include all scans that match fmriDirPrefix"
	echo "startFrame,numFrames: extract subset of volumes from 4-D file (see fslroi)."
	echo "                      startFrame uses 0-based indexing."
	echo "                      if numFrames==0, all volumes are kept and startFrame is irrelevant."
	echo "fmriDirPrefix: defaults to ep2d_"
	echo "anatomyDirPrefix: defaults to t1_se_tra_"
	echo ""
	exit 1
endif
set dcmDir = $1
set niiDir = $2


# --------------------------------------------------------------------------------------------
# CHECK IF DIRECTORIES EXIST
if ( ! -d $dcmDir ) then
	echo ERROR: DICOM directory $dcmDir does not exist.; echo ""
	exit 1
endif
if ( ! -d $niiDir ) then
	echo ERROR: NIfTI directory $niiDir does not exist.; echo ""
	exit 1
endif
# CHECK & TRIM TRAILING "/"
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


# --------------------------------------------------------------------------------------------
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


# --------------------------------------------------------------------------------------------
# COUNT DICOM DIRECTORIES i.e. SCANS
set anatDcmDirs = `ls -d $dcmDir/$anatSearch*`
set fmriDcmDirs = `ls -d $dcmDir/$fmriSearch*`
@ nAnat = `echo $anatDcmDirs | wc -w`
@ nFmri = `echo $fmriDcmDirs | wc -w`
if ( $nFmri == 0 ) then 
	echo "ERROR: No fMRI scans found."; echo ""
	exit 1
endif
if ( $nAnat == 0 ) then
	echo "WARNING: No anatomical inplane scan found."; echo ""
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

# --------------------------------------------------------------------------------------------
# FLAG for FSL slicetime compensation
printf "Do slice time correction? (y or n): "
set choice = `echo $< | cut -c 1`
if (( $choice == "y" ) || ( $choice == "Y" )) then
	@ FSLtc = 1
else
	@ FSLtc = 0
endif
echo ""

# FLAG for aligning reference functional mean to T1 inplanes
printf "Align BOLD mean to Inplanes? (y or n): "
set choice = `echo $< | cut -c 1`
if (( $choice == "y" ) || ( $choice == "Y" )) then
	@ BOLDtoT1 = 1
else
	@ BOLDtoT1 = 0
endif
echo ""


# --------------------------------------------------------------------------------------------
# CHOOSE ONE, IF MULTIPLE INPLANES
if ( $nAnat == 1 ) then
	@ iAnat = 1
else if ( $nAnat > 1 ) then
	echo "WARNING: Multiple anatomical inplane scans found."
	echo functional series = [ $fmriSort ]
	echo anatomical series = [ $anatSort ]
	printf "ENTER an anatomical series: "
	set choice = $<
	@ i = 1
	while ( ($i < $nAnat ) && ( $anatSeries[$i] != $choice ) )
		@ i ++
	end
	if ( $anatSeries[$i] == $choice ) then
		@ iAnat = $i
	else
		echo "ERROR: choice is not one of options."; echo ""
		exit 1
	endif
	echo ""
endif

# CHOOSE REFERENCE FUNCTIONAL, IF DOING MOTION COMPENSATION
if ( ( $FSLmc != 0 ) || ( $nAnat == 0 ) ) then
	if ( $nFmri == 1 ) then
		@ iFmri = 1
	else
		@ iFmri = 0
		if ( $nAnat == 0 ) then
			echo "anatomical series = []"
		else
			if ( $anatSeries[$iAnat] < $fmriSort[1] ) then
				@ iFmri = $fmriIndex[1]
			else if ( $anatSeries[$iAnat] > $fmriSort[$nFmri] ) then
				@ iFmri = $fmriIndex[$nFmri]
			else
				echo anatomical series = [ $anatSeries[$iAnat] ]
			endif
		endif		
		if ( $iFmri == 0 ) then
			echo functional series = [ $fmriSort ]
			if ( $FSLmc == 0 ) then
				printf "ENTER functional series to use for high-res alignment: "
			else
				printf "ENTER functional series to use as reference for between-scans motion compensation: "
			endif
			set choice = $<
			@ i = 1
			while ( ($i < $nFmri ) && ( $fmriSeries[$i] != $choice ) )
				@ i ++
			end
			if ( $fmriSeries[$i] == $choice ) then
				@ iFmri = $i
			else
				echo "ERROR: choice is not one of options."; echo ""
				exit 1
			endif
		endif
		echo ""
	endif
endif

# --------------------------------------------------------------------------------------------
@ tic = `date +%s`

# CONVERT TO NIfTI

# Anatomy
if ( $nAnat != 0 ) then
	set anatNii = `echo $anatSeries`
	@ j = $iAnat
#	@ i = 1
#	while ( $i <= $nAnat )
#		@ j = $anatIndex[$i]

		@ slash = `expr $anatDcmDirs[$j] : '.*/'`
		@ slash ++
		@ under = `expr $anatDcmDirs[$j] : '.*_'`
		set prefix  = `echo $anatDcmDirs[$j] | cut -c $slash-$under`
		set anatNii[$j] = `printf "%s/%s%02d" $niiDir $prefix $anatSeries[$j]`
		# go ahead & re-convert this since it's fast & its orientation has likely been changed.
		if ( -e $anatNii[$j].nii.gz ) then
			echo $anatNii[$j].nii.gz exists, replacing.
		endif
#		else
			mri_convert $anatDcm1[$j] $anatNii[$j].nii.gz
			if ( $FSLmc == 0 ) then
				fslswapdim $anatNii[$j] y x z $anatNii[$j]
				fslorient -swaporient $anatNii[$j]
			else
				fslorient -swaporient $anatNii[$j]
				fslswapdim $anatNii[$j] x -y z $anatNii[$j]
			endif
			echo ""
#		endif
		
#		@ i ++
#	end
endif

# Functionals
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
			if ( -e $fmriNii[$j]_TC.nii.gz ) then
				echo $fmriNii[$j]_TC.nii.gz exists
			else
				# SLICETIME COMPENSATION
				echo "Performing slice time compensation..."
				@ nSlice = `fslval $fmriNii[$j] dim3`
				set TR   = `fslval $fmriNii[$j] pixdim4`
				# source /raid/MRI/toolbox/SperoToolbox/HeadModels/SiemensSliceOrder.sh $nSlice $niiDir
				set sliceFile = `printf "%s/sliceOrder%d.txt" $niiDir $nSlice`
				if ( -e $sliceFile ) then
					echo $sliceFile exists, replacing.
					rm $sliceFile
				endif
				@ oddFlag = $nSlice % 2
				if ( $oddFlag != 0 ) then
					@ iSlice = 1
					while ( $iSlice <= $nSlice )
						echo $iSlice >> $sliceFile
						@ iSlice += 2
					end
					@ iSlice = 2
					while ( $iSlice <= $nSlice )
						echo $iSlice >> $sliceFile
						@ iSlice += 2
					end
				else
					@ iSlice = 2
					while ( $iSlice <= $nSlice )
						echo $iSlice >> $sliceFile
						@ iSlice += 2
					end
					@ iSlice = 1
					while ( $iSlice <= $nSlice )
						echo $iSlice >> $sliceFile
						@ iSlice += 2
					end
				endif
				# slicetimer has no output data_type option, yields FLOAT32
				# I'm assuming units of TR input are sec???, but slicetimer output doesn't depend on this input anyway.
				slicetimer -i $fmriNii[$j] -o $fmriNii[$j]_TC -r $TR -d 3 --ocustom=$sliceFile
			endif
			set fmriFile = $fmriNii[$j]_TC
		else
			set fmriFile = $fmriNii[$j]
		endif
		if ( $FSLmc != 0 ) then
			if ( -e $fmriNii[$j]_MCw.nii.gz ) then
				echo $fmriNii[$j]_MCw.nii.gz exists
			else
				fslorient -swaporient $fmriFile
				fslswapdim $fmriFile x -y z $fmriFile
				# WITHIN-SCAN MOTION COMPENSATION
				echo "Performing within-scan motion compensation..."
				mcflirt -in $fmriFile -stages 4 -out $fmriNii[$j]_MCw
				if ( $nFmri > 1 ) then
					fslmaths $fmriNii[$j]_MCw -Tmean $niiDir/Tmean_MCw_$series
				endif
			endif
		else
			fslswapdim $fmriFile y x z $fmriFile
			fslorient -swaporient $fmriFile
		endif
		echo ""
	endif
	@ i ++
end

# --------------------------------------------------------------------------------------------
# BETWEEN-SCAN MOTION COMPENSATION
if ( $FSLmc != 0 ) then
	if ( $nFmri > 1) then
		echo ""
		echo "Computing between-scan transforms..."
		set refSeries = `printf "%02d" $fmriSeries[$iFmri]`
		set flirtOpts = "-cost mutualinfo -searchcost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -coarsesearch 4 -finesearch 0.5"
		# compute transform of refscan mean to T1 inplanes
		if ( ( $BOLDtoT1 != 0 ) && ( $nAnat != 0 ) ) then
			set bold2T1 = $niiDir/ep2T1.txt
			flirt $flirtOpts -dof 6 -ref $anatNii[$iAnat] -in $niiDir/Tmean_MCw_$refSeries -omat $bold2T1
#			flirt $flirtOpts -dof 12 -ref $anatNii[$iAnat] -in $niiDir/Tmean_MCw_$refSeries -init $bold2T1 -omat $bold2T1
			echo ""
			echo $bold2T1
			cat $bold2T1
			flirt -ref $fmriNii[$iFmri]_MCw -in $fmriNii[$iFmri]_MCw -applyxfm -init $bold2T1 -out $fmriNii[$iFmri]_MCb$refSeries
		else
#			set bold2T1 = $niiDir/identity.txt
#			echo 1  0  0  0 > $bold2T1
#			echo 0  1  0  0 >> $bold2T1
#			echo 0  0  1  0 >> $bold2T1
#			echo 0  0  0  1 >> $bold2T1
			echo "Copying ref scan"
			cp $fmriNii[$iFmri]_MCw.nii.gz $fmriNii[$iFmri]_MCb$refSeries.nii.gz
		endif
		@ i = 1
		while ( $i <= $nFmri )
			@ j = $fmriIndex[$i]
			if ( $j != $iFmri ) then
				set series = `printf "%02d" $fmriSeries[$j]`
				set MCbXfm = $niiDir/MCb_xfm_$series.txt
				flirt $flirtOpts -dof 6 -ref $niiDir/Tmean_MCw_$refSeries -in $niiDir/Tmean_MCw_$series -omat $MCbXfm
				if ( ( $BOLDtoT1 != 0 ) && ( $nAnat != 0 ) ) then
					convert_xfm -omat $MCbXfm -concat $bold2T1 $MCbXfm
				endif
				echo ""
				echo $MCbXfm
				cat $MCbXfm
				flirt -ref $fmriNii[$iFmri]_MCb$refSeries -in $fmriNii[$j]_MCw -applyxfm -init $MCbXfm -out $fmriNii[$j]_MCb$refSeries
			endif
			fslcpgeom $fmriNii[$iFmri]_MCw $fmriNii[$j]_MCb$refSeries		# restore pixdim4 i.e. TR.  flirt resets it to 1.
			# revert to VistaSoft orientation
			fslswapdim $fmriNii[$j]_MCb$refSeries -y x z $fmriNii[$j]_MCb$refSeries
			@ i ++
		end
	else
		fslswapdim $fmriNii[1]_MCw -y x z $fmriNii[1]_MCw
	endif
	if ( $nAnat != 0 ) then
		fslswapdim $anatNii[$iAnat] -y x z $anatNii[$iAnat]
	endif
endif
echo ""

if ( $nAnat == 0 ) then
	if ( $FSLmc == 0 ) then
		# compute mean of refscan to use in place of inplanes
		if ( FSLtc != 0 ) then
			fslmaths $fmriNii[$iFmri]_TC -Tmean $fmriNii[$iFmri]_TC_Tmean
		else
			fslmaths $fmriNii[$iFmri] -Tmean $fmriNii[$iFmri]_Tmean
		endif
	else
		echo use Tmean_MCw_$refSeries for Inplanes
	endif
	echo ""
endif

# --------------------------------------------------------------------------------------------
# CLEANUP
if ( $cleanup != 0 ) then
	echo "Cleaning up..."
	@ i = 1
	while ( $i <= $nFmri )
		@ j = $fmriIndex[$i]
		if ( $FSLmc != 0 ) then
			rm $fmriNii[$j].nii.gz
			if ( $FSLtc != 0 ) then
				rm $fmriNii[$j]_TC.nii.gz
			endif
			rm $fmriNii[$j]_MCw.nii.gz
			if ( ( $nAnat != 0 ) || ( $j != $iFmri ) ) then
				rm `printf "%s/Tmean_MCw_%02d.nii.gz" $niiDir $fmriSeries[$j]`
			endif
		else if ( $FSLtc != 0 ) then
			rm $fmriNii[$j].nii.gz
		endif
		@ i ++
	end
endif

@ toc = `date +%s`
@ sec = $toc - $tic
@ hr  = $sec / 3600
@ sec = $sec - 3600 * $hr
@ min = $sec / 60
@ sec = $sec - 60 * $min
echo --- Elapsed time = $hr hours $min minutes $sec seconds ---
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


