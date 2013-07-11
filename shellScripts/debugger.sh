#!/bin/csh

@ tic = `date +%s`
#@ toc = `date +%s`
@ toc = `expr $tic + 8888`
@ sec = $toc - $tic
@ hr  = $sec / 3600
@ sec = $sec - 3600 * $hr
@ min = $sec / 60
@ sec = $sec - 60 * $min
echo Elapsed time = $hr hours $min minutes $sec seconds

exit 0

printf "Do slice time correction: "
set choice = `echo $< | cut -c 1`
if (( $choice == "y" ) || ( $choice == "Y" )) then
	@ FSLtc = 1
else
	@ FSLtc = 0
endif
echo $FSLtc;

