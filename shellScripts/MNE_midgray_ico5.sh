#!/bin/sh
if [ $# -ne 1 ]; then
	echo ""
	echo "Usage: MNE_midgray_ico5 FS4subjid"
	echo ""
	exit 1
fi

mne_setup_source_space --subject $1 --surface midgray --ico 5 --cps
