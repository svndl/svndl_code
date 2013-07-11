function makeFreesurferMidgraySurface(FSsubjid)
% loads freesurfer white & pial surfaces & makes new surface from midpoint
%
% SYNTAX: makeFreesurferMidgraySurface(FSsubjid)

% get freesurfer subject directory
subDir = getpref('freesurfer','SUBJECTS_DIR')

if ~exist('FSsubjid','var') || isempty(FSsubjid)
        
    FSdir = uigetdir(subDir,'Freesurfer subject folder');
% 	if ispc
% 		FSdir = uigetdir('X:\anatomy\FREESURFER_SUBS','Freesurfer subject folder');
% 	else
% 		FSdir = uigetdir('/raid/MRI/anatomy/FREESURFER_SUBS','Freesurfer subject folder');
%	end
if isnumeric(FSdir)
    return
end
[junk,FSsubjid] = fileparts(FSdir);		% in case you want to use FSsubjid later
else
    
    FSdir = fullfile(subDir,FSsubjid);
    
    %         if ispc
    %             FSdir = fullfile('X:\anatomy\FREESURFER_SUBS',FSsubjid);
    %         else
    %             FSdir = fullfile('/raid/MRI/anatomy/FREESURFER_SUBS',FSsubjid);
    %         end
    
    
    if ~exist(FSdir,'dir')
        error('Directory %s does not exist',FSdir)
    end
end

% check for req'd functions
if ~exist('freesurfer_write_surf','file') &&	~exist('write_surf','file')		% no write_surf.m in MGH matlab toolbox
	if ispc
		path2add = 'X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox';
	else
		path2add = '/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox';
	end
	disp(['adding to path ',path2add])
	addpath(path2add,0)
end

% make mid-layer surface
fWhite2Pial = 0.5;	% layer1 ~ 0.3, layer3 ~ 1
for hemi = 'lr';
	 Vwhite     = freesurfer_read_surf(fullfile(FSdir,'surf',[hemi,'h.white']));
	[Vmid,Fmid] = freesurfer_read_surf(fullfile(FSdir,'surf',[hemi,'h.pial']));
	 Vmid = (1-fWhite2Pial)*Vwhite + fWhite2Pial*Vmid;
    if exist('freesurfer_write_surf','file')
        freesurfer_write_surf(fullfile(FSdir,'surf',[hemi,'h.midgray']),Vmid,Fmid)
    elseif exist('write_surf','file')
        write_surf(fullfile(FSdir,'surf',[hemi,'h.midgray']),Vmid,Fmid)
    end
end

disp(' ')
