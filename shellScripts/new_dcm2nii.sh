#!/bin/csh
# Convert raw 3D & 4D .dcm series to .nii.gz using mri_convert
# then preprocess with FSL and orient for importing to mrVista.
# Works with dicom format from the NIC (*.dcm extensions, 1 folder per scan, 1 file per volume)

# this version has better existence checks for picking up from where you left off?

# to do:
# 1. figure out how to stop this after intermediate FSL crashes - it keeps going with the next command
# 2. only write slice order file once


@ dog = 0
@ FSLmc = $dog != 0
set fileName = t1_se_tra_05.nii.gz
@ check1 = (   $FSLmc && ! -e $fileName )
@ check2 = ( ! $FSLmc && ! -e $fileName )
@ check3 = -e $fileName
echo $check1 $check2 $check3

exit 0 		# figure out rest of _mrV & _LAS extension stuff?

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

@ badSyntax = 0
if ( $#argv < 2 ) then
	@ badSyntax = 1
else
	set dcmDir = $1
	shift
	set niiDir = $1
	shift
endif


# SET OPTTION DEFAULTS, CHECK INPUTS
@ nVol = 0						# when nVol!=0, only recons scans with nVol volumes
@ startFrame = 0				# 0-based indexing
@ nFrames = 0					# when nFrames!=0, extracts nFrames from time series starting @ startFrame
set fmriSearch = ep2d_			# search prefix for folders of functional scans 
set anatSearch = t1_se_tra_		# search prefix for folders of inplane anatomy scans
@ FSLtc = 0						# FLAG for slicetime compensation
@ FSLmc = 1						# FLAG for rigid within- and between-scan motion compensation
@ cleanup = 1					# FLAG for removing intermediate files when done
while ( $#argv >= 2 )
	set opt = $1
	shift
	switch ( $opt )
	case -vT:
		@ nVol = $1
		breaksw
	case -v0:
		@ startFrame = $1
		breaksw
	case -vN:
		@ nFrames = $1
		breaksw
	case -fSearch:
		set fmriSearch = $1
		breaksw
	case -aSearch:
		set anatSearch = $1
		breaksw
	case -tc:
		@ FSLtc = $1 != 0
		breaksw
	case -mc:
		@ FSLmc = $1 != 0
		breaksw
	case -c:
		@ cleanup = $1 != 0
		breaksw
	default:
		echo Unknown option $opt
		@ badSyntax = 1
		break
		breaksw
	endsw
	shift
end
if ( ( $#argv > 0 ) && ! $badSyntax ) then
	echo No value for option $1
	@ badSyntax = 1
endif

if ( $badSyntax ) then
	echo ""
	echo "USAGE"
	echo ""
	echo "   dcm2nii.sh <DICOMdirectory> <NIfTIdirectory> [options]"
	echo ""
	echo "OPTIONS"
	echo ""
	echo "             -vT <#>:  If not 0, limit analysis to dicom series with # total volumes per scan (default = 0)"
	echo ""
	echo "             -vN <#>:  If not 0, only keep # volumes starting from -v0, otherwise include all (default = 0)"
	echo ""
	echo "             -v0 <#>:  First volume to keep using zero-based indexing, only relevant when -vN is not zero (default = 0)"
	echo ""
	echo "   -fSearch <string>:  Leading string to identify functional dicom directories (default = ep2d_)"
	echo ""
	echo "   -aSearch <string>:  Leading string to identify anatomical dicom directories (default = t1_se_tra_)"
	echo ""
	echo "          -tc <flag>:  If flag != 0, do slice time correction (default = 1)"
	echo ""
	echo "          -mc <flag>:  If flag != 0, do rigid within- and between-scan motion compensation (default = 1)"
	echo ""
	echo "         -xT1 <flag>:  If flag != 0, align mean of reference functional to T1 (default = 1)"
	echo ""
	echo "           -c <flag>:  If flag != 0, cleanup temporary files (default = 1)"
	echo ""
	echo ""
	echo "e.g."
	echo ""
	echo "   dcm2nii.sh RawDicom/ nifti/ -vT 126 -v0 6 -vN 120 -fSearch bas_ -xT1 0"
	echo ""
	exit 1
endif


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


echo  functional directories = $dcmDir/$fmriSearch"*"
echo  anatomical directories = $dcmDir/$anatSearch"*"
echo "               options =" -vT $nVol -v0 $startFrame -vN $nFrames -tc $FSLtc -mc $FSLmc -c $cleanup
echo ""

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
if ( $FSLmc || ( $nAnat == 0 ) ) then
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
			if ( $FSLmc ) then
				printf "ENTER functional series to use as reference for between-scans motion compensation: "
			else
				# mean over time of this scan will be computed for use as Inplanes
				printf "ENTER functional series to use for high-res alignment: "
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

		@ check1 = (   $FSLmc && ! -e $anatNii[$j]_LAS.nii.gz )
		@ check2 = ( ! $FSLmc && ! -e $anatNii[$j].nii.gz )
		if ( ( $check1 || $check2 ) && ! -e $anatNii[$j]_raw.nii.gz ) then
			mri_convert $anatDcm1[$j] $anatNii[$j]_raw.nii.gz
		endif
		if ( $check1 ) then
			cp $anatNii[$j]_raw.nii.gz $anatNii[$j]_tmp.nii.gz
			fslorient -swaporient $anatNii[$j]_tmp
			fslswapdim $anatNii[$j]_tmp x -y z $anatNii[$j]_LAS
			rm $anatNii[$j]_tmp.nii.gz
		else if ( $check2 ) then
			fslswapdim $anatNii[$j]_raw y x z $anatNii[$j]_tmp
			fslorient -swaporient $anatNii[$j]_tmp
			cp $anatNii[$j]_tmp.nii.gz $anatNii[$j].nii.gz
			rm $anatNii[$j]_tmp.nii.gz
		endif
		
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

#	@ check1 = (   $FSLmc && ! -e $anatNii[$j]_LAS.nii.gz )
#	@ check2 = ( ! $FSLmc && ! -e $anatNii[$j].nii.gz )
	
	@ existTC = -e $fmriNii[$j]_TC.nii.gz
	@ existMC = -e $fmriNii[$j]_MCw.nii.gz
	@ checkTC = ( ( $FSLtc && ! $existTC ) || ( ! $FSLtc ) )		# might need input file
	@ checkMC = ( ( $FSLmc && ! $existMC ) || ( ! $FSLmc ) )
	# CONVERT RAW DICOMS
	if ( $checkTC && $checkMC ) then
		if ( -e $fmriNii[$j].nii.gz ) then
			echo $fmriNii[$j].nii.gz exists
		else
			mri_convert $fmriDcm1[$j] $fmriNii[$j].nii.gz
			if ( $nFrames != 0 ) then
				fslroi $fmriNii[$j] $fmriNii[$j] $startFrame $nFrames
			endif
		endif
	endif
	 
	# SLICETIME COMPENSATION
	if ( $FSLtc && $checkMC ) then
		if ( $existTC ) then
			echo $fmriNii[$j]_TC.nii.gz exists
		else
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
	endif
	
	if ( $FSLtc ) then
		set inputMC = $fmriNii[$j]_TC
	else
		set inputMC = $fmriNii[$j]
	endif
	if ( $FSLmc ) then
		if ( $existMC ) then
			echo $fmriNii[$j]_MCw.nii.gz exists
		else
			if ( -e {$inputMC}_LAS.nii.gz ) then
				{$inputMC}_LAS.nii.gz exists
			else
				cp $inputMC.nii.gz {$inputMC}_LAS.nii.gz
			endif
			set inputMC = {$inputMC}_LAS
			fslorient -swaporient $inputMC
			fslswapdim $inputMC x -y z $inputMC
			# WITHIN-SCAN MOTION COMPENSATION
			echo "Performing within-scan motion compensation..."
			mcflirt -in $inputMC -dof 6 -stages 4 -out $fmriNii[$j]_MCw
			if ( $nFmri > 1 ) then
				fslmaths $fmriNii[$j]_MCw -Tmean $niiDir/Tmean_MCw_$series
			endif
		endif
	else
		if ( -e {$inputMC}_mrV.nii.gz ) then
			echo {$inputMC}_mrV.nii.gz exists
		else
			fslswapdim $inputMC y x z {$inputMC}_mrV
			set inputMC = {$inputMC}_mrV
			fslorient -swaporient $inputMC
		endif
	endif
	echo ""
	@ i ++
end

# --------------------------------------------------------------------------------------------
# BETWEEN-SCAN MOTION COMPENSATION
if ( $FSLmc ) then
	set refSeries = `printf "%02d" $fmriSeries[$iFmri]`
	if ( $nFmri > 1) then
		echo ""
		echo "Copying ref scan"
		cp $fmriNii[$iFmri]_MCw.nii.gz $fmriNii[$iFmri]_MCb$refSeries.nii.gz
		echo "Computing between-scan transforms..."
		set flirtOpts = "-cost mutualinfo -searchcost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -coarsesearch 4 -finesearch 0.5"
		@ i = 1
		while ( $i <= $nFmri )
			@ j = $fmriIndex[$i]
			if ( $j != $iFmri ) then
				set series = `printf "%02d" $fmriSeries[$j]`
				set MCbXfm = $niiDir/MCb_xfm_$series.txt
				flirt $flirtOpts -dof 6 -ref $niiDir/Tmean_MCw_$refSeries -in $niiDir/Tmean_MCw_$series -omat $MCbXfm
				echo ""
				echo $MCbXfm
				cat $MCbXfm
				flirt -ref $fmriNii[$iFmri]_MCb$refSeries -in $fmriNii[$j]_MCw -applyxfm -init $MCbXfm -out $fmriNii[$j]_MCb$refSeries
			endif
			fslcpgeom $fmriNii[$iFmri]_MCw $fmriNii[$j]_MCb$refSeries -d		# restore pixdim4 i.e. TR.  flirt resets it to 1.
			# revert to VistaSoft orientation
			fslswapdim $fmriNii[$j]_MCb$refSeries -y x z $fmriNii[$j]_mrV$refSeries
			@ i ++
		end
	else
		fslswapdim $fmriNii[1]_MCw -y x z $fmriNii[1]_mrV
	endif
	
	# align Inplanes to mean of ref functional, & re-orient to mrVista orientation
	if ( $nAnat != 0 ) then
		if ( ! -e $anatNii[$iAnat]_BOLD.nii.gz ) then
			set T1toBOLD = $niiDir/T1-to-Series$refSeries.txt
			flirt $flirtOpts -dof 6  -in $anatNii[$iAnat]_LAS -ref $niiDir/Tmean_MCw_$refSeries -omat $T1toBOLD
#			flirt $flirtOpts -dof 12 -in $anatNii[$iAnat]_LAS -ref $niiDir/Tmean_MCw_$refSeries -init $T1toBOLD -omat $T1toBOLD
			echo ""
			echo $T1toBOLD
			cat $T1toBOLD
			flirt -in $anatNii[$iAnat]_LAS -ref $niiDir/Tmean_MCw_$refSeries -applyxfm -init $T1toBOLD -out $anatNii[$iAnat]_BOLD
		endif
		if ( ! -e $anatNii[$iAnat].nii.gz ) then
			fslswapdim $anatNii[$iAnat]_LAS  -y x z $anatNii[$iAnat]
		endif
		if ( ! -e $anatNii[$iAnat]_align.nii.gz ) then
			fslswapdim $anatNii[$iAnat]_BOLD -y x z $anatNii[$iAnat]_align
		endif
	endif
endif


echo ""

if ( $nAnat == 0 ) then
	if ( $FSLmc ) then
		echo use Tmean_MCw_$refSeries for Inplanes
	else
		# compute mean of refscan to use in place of inplanes
		if ( $FSLtc ) then
			fslmaths $fmriNii[$iFmri]_TC -Tmean $fmriNii[$iFmri]_TC_Tmean
		else
			fslmaths $fmriNii[$iFmri] -Tmean $fmriNii[$iFmri]_Tmean
		endif
	endif
	echo ""
endif

# --------------------------------------------------------------------------------------------
# CLEANUP
if ( $cleanup ) then
	echo "Cleaning up..."
	if ( -e $anatNii[$iAnat]_raw.nii.gz ) then
		rm $anatNii[$iAnat]_raw.nii.gz
	endif
	if ( -e $anatNii[$iAnat]_LAS.nii.gz ) then
		rm $anatNii[$iAnat]_LAS.nii.gz
	endif
	if ( -e $anatNii[$iAnat]_BOLD.nii.gz ) then
		rm $anatNii[$iAnat]_BOLD.nii.gz
	endif
	@ i = 1
	while ( $i <= $nFmri )
		@ j = $fmriIndex[$i]
		if ( $FSLmc ) then
			rm $fmriNii[$j].nii.gz
			if ( $FSLtc ) then
				rm $fmriNii[$j]_TC.nii.gz
			endif
			rm $fmriNii[$j]_MCw.nii.gz
			if ( ( $nAnat != 0 ) || ( $j != $iFmri ) ) then
				rm `printf "%s/Tmean_MCw_%02d.nii.gz" $niiDir $fmriSeries[$j]`
			endif
		else if ( $FSLtc ) then
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


