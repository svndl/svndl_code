%------------ FreeSurfer -----------------------------%
setenv('FREESURFER_HOME', '/Applications/freesurfer');
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
if (exist(fsmatlab) == 7)
    path(path,fsmatlab);
end
path1 = getenv('PATH');
path1 = [path1 ':/Applications/freesurfer/bin'];
setenv('PATH', path1);
clear fshome fsmatlab;
%-----------------------------------------------------%

%------------ FreeSurfer FAST ------------------------%
fsfasthome = getenv('FSFAST_HOME');
fsfasttoolbox = sprintf('%s/toolbox',fsfasthome);
if (exist(fsfasttoolbox) == 7)
    path(fsfasttoolbox,path);
end
clear fsfasthome fsfasttoolbox;
%-----------------------------------------------------%
path1 = getenv('PATH');
path1 = [path1 ':/usr/local/fsl/bin'];
setenv('PATH', path1);
!echo $PATH
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
setenv( 'FSLDIR', '/usr/local/fsl' );

fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;
