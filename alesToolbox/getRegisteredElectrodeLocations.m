function [ elecLocs] = getRegisteredElectrodeLocations(subjId, mrcProjDir )
%function [ elecLocs] = getRegisteredElectrodeLocations(subjId, mrcProjDir )

h = 10;		% estimated sensor height (mm)
d2 = 30^2;	% distance threshold (mm^2)


%TODO: ADD ERROR CHECKING.

fsDir = getpref('freesurfer','SUBJECTS_DIR')
scalpFile = fullfile(fsDir, [subjId '_fs4'],'bem',[ subjId '_fs4-head.fif']);

%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/AW_crf2_20090519.elp'];
%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/JA_ATTCont_20090225.elp'];

ELPname = dir(fullfile(mrcProjDir,subjId,'Polhemus','*Edited.elp'));

validNames = ~strncmp({ELPname(:).name},'.',1);
ELPname=ELPname(validNames);

if isempty(ELPname),
    
    ELPname = dir(fullfile(mrcProjDir,subjId,'Polhemus','*.elp'));
    
    validNames = ~strncmp({ELPname(:).name},'.',1);
    ELPname=ELPname(validNames);
    
    if isempty(ELPname),
        error(['\n Subject: ' subjId ' does not have Polhemus file']);
    else
        display(['Using file: ' ELPname(1).name]);
    end
    
else
    display(['Found edited ELP file, using file: ' ELPname(1).name ]);
end
    
elpFile = fullfile(mrcProjDir, subjId, 'Polhemus',ELPname(1).name);
regFile = fullfile(mrcProjDir, subjId, '_MNE_','elp2mri.tran');


S = mne_read_bem_surfaces(scalpFile);
S.rr = S.rr*1e3;					% convert to mm
S.tris = flipdim(S.tris,2);	% outward normals of matlab patch
S.np = double(S.np);

e = mrC_readELPfile(elpFile,true,true,[-2 1 3]);
xfm = load('-ascii',regFile);
elecLocs = [e(1:128,:)*1e3,ones(128,1)]*(xfm(1:3,:)');