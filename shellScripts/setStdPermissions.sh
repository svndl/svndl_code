#!/bin/csh

if ($#argv < 1) then
	echo ""
	echo "Usage: setStdPermissions.sh 555"
	echo ""
	exit 1
endif

set perm = $1
# set subj = (1 3 4 5 8 9 17 35 36 37 38 39 44 47 48 49 50 ...)

chmod -R $perm /raid/MRI/anatomy/skeri0001/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0003/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0004/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0005/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0008/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0009/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0017/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0035/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0036/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0037/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0038/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0039/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0044/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0047/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0048/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0049/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0050/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0051/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0052/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0053/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0054/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0055/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0056/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0057/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0058/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0059/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0060/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0061/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0062/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0063/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0064/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0065/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0066/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0067/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0068/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0069/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0071/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0072/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0073/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0074/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0075/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0076/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0077/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0078/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0079/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0080/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0081/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0082/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0083/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0084/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0085/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0086/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0087/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0088/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0089/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0090/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0091/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0093/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0094/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0095/Standard/
chmod -R $perm /raid/MRI/anatomy/skeri0096/Standard/

