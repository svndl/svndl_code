function decCortex2EMSEwfr(mrmFile,wfrFile,fWhite2Pial)
% MrM-format mat-file to EMSE wfr
%
% decCortex2EMSEwfr(mrmFile,wfrFile,fWhite2Pial)
% e.g.
% decCortex2EMSEwfr('','',0)   -> white
% decCortex2EMSEwfr('','',0.5) -> midgray
% decCortex2EMSEwfr('','',1)   -> pial

if ~exist('mrmFile','var') || isempty(mrmFile)
	[mrmFile,mrmPath] = uigetfile('defaultCortex.mat','cortex mesh file');
	if isnumeric(mrmFile)
		return
	end
	mrmFile = [mrmPath,mrmFile];
end

if ~exist('fWhite2Pial','var') || isempty(fWhite2Pial)
	fWhite2Pial = 1;
end

if ~exist('wfrFile','var') || isempty(wfrFile)
	switch fWhite2Pial
	case 1
		surf = 'pial';
	case 0
		surf = 'white';
	case 0.5
		surf = 'midgray';
	otherwise
		surf = strrep(sprintf('f%0.3g',fWhite2Pial),'.','');
	end
% 	[wfrFile,wfrPath] = uiputfile(['decp1_pial_',datestr(now,'mmddyy'),'.wfr'],'EMSE wireframe (note: "_cortex" gets appended)');
	if strfind(mrmFile,'MNE')
		[wfrFile,wfrPath] = uiputfile(fullfile(fileparts(mrmFile),['vSpace_MNEdec_',surf,'.wfr']),'EMSE wireframe (note: "_cortex" gets appended)');
	else
		[wfrFile,wfrPath] = uiputfile(fullfile(fileparts(mrmFile),['vSpace_dec01_',surf,'.wfr']),'EMSE wireframe (note: "_cortex" gets appended)');
	end
	if isnumeric(wfrFile)
		return
	end
else
	[wfrPath,wfrFile,wfrExt] = fileparts(wfrFile);
	wfrFile = [wfrFile,wfrExt];
end

cortex = load(mrmFile);
if fWhite2Pial == 1
elseif fWhite2Pial == 0
	cortex.msh.data.vertices = cortex.msh.initVertices;
else
	cortex.msh.data.vertices = (1-fWhite2Pial)*cortex.msh.initVertices + fWhite2Pial*cortex.msh.data.vertices;
end
cortex.msh.data.vertices = cortex.msh.data.vertices - 128;
cortex.msh.data.vertices(1:2,:) = -cortex.msh.data.vertices(1:2,:);
cortex.msh.data.triangles(:) = cortex.msh.data.triangles([3 2 1],:) + 1;

p = struct('mesh',struct(	'path',wfrPath,...
									'file',wfrFile,...
									'data',struct(	'meshtype',{{'cortex'}},...
														'vertices',{{cortex.msh.data.vertices'}},...
														'faces',{{cortex.msh.data.triangles'}}	)	));

if exist('mesh_write_emse','file')
	path2add = '';
else
	if ispc
		path2add = 'X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox';
	else
		path2add = '/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox';
	end
	addpath(path2add,0)
end

wfrFile = mesh_write_emse(p);		% now [wfrPath,wfrFile,'_cortex']

if ~isempty(path2add)
	rmpath(path2add)
end
