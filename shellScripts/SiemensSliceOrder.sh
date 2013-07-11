#!/bin/csh
# Write slice order text files for FSL's slicetimer
# Assuming Siemen's interleaving:
# 1,3,5,...2,4,6,... for  odd #slices
# 2,4,6,...1,3,5,... for even #slices

if ( $#argv < 1 ) then
	echo "Usage: SiemensSliceOrder.sh numberOfSlices [outputDirectory]"
	echo ""
	exit 1
endif

@ nSlice = $1
@ odd = $nSlice % 2

if ( $#argv >= 2 ) then
	set outDir = $2
	if ( ! -d $outDir ) then
		echo $outDir does not exist.
		exit 1
	endif
	@ nChar = `expr length $outDir`
	if ( `echo $outDir | cut -c $nChar` != "/" ) then
		set outDir = {$outDir}/
	endif
else
	set outDir = "./"
endif
set sliceFile = `printf "%ssliceOrder%d.txt" $outDir $nSlice`

if ( -e $sliceFile ) then
	echo $sliceFile exists
	echo "replace? (y or n):"
	set choice = $<
	if ( $choice != y ) then
		exit 0
	endif
	rm $sliceFile
endif

if ( $odd != 0 ) then
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

exit 0