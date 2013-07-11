function ext = getFSLextension

% FSLOUTPUTTYPE = strtok( runSystemCmd('echo $FSLOUTPUTTYPE') );
FSLOUTPUTTYPE = getenv('FSLOUTPUTTYPE');
switch FSLOUTPUTTYPE
case 'NIFTI'
	ext = '.nii';
case 'NIFTI_GZ'
	ext = '.nii.gz';
case 'NIFTI_PAIR'
	ext = '.img';
case 'NIFTI_PAIR_GZ'
	ext = '.img.gz';
case 'ANALYZE'
	ext = '.img';
case 'ANALYZE_GZ'
	ext = '.img.gz';
otherwise
	error('unknown FSLOUTPUTTYPE %s',FSLOUTPUTTYPE)
end		