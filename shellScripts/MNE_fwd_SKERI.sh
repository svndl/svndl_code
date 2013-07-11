#!/bin/sh
if [ $# -ne 1 ]; then
	echo ""
	echo "Usage: MNE_fwd_SKERI FS4subjid"
	echo ""
	exit 1
fi

#mne_setup_forward_model --subject $1 --scalpc 0.33 --skullc 0.025 --brainc 0.33 --noswap

#mv ${1}-5120-5120-5120-bem.fif     ${1}-bem.fif
#mv ${1}-5120-5120-5120-bem-sol.fif ${1}-bem-sol.fif

mne_setup_forward_model --subject $1 --scalpc 0.33 --skullc 0.025 --brainc 0.33 --noswap --model $1
