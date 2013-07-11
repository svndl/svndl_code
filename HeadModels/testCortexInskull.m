function testCortexInskull(anatDir,fWhite2Pial)
% plots Standard cortex & FSL inskull mesh to check for crossings
%
% SYNTAX: testCortexInskull(anatomyDir,fractionWhite2Pial)
% anatomyDir = subject's root anatomy directory e.g. /raid/MRI/anatomy/skeri0001
%              this m-file will attempt to load $anatomyDir/Standard/meshes/defaultCortex.mat
%                                           and $anatomyDir/nifti/betsurf_inskull_mesh.off
% fractionWhite2Pial = where to plot cortical surface.  0=white, 1=pial [defaults to 0.5]

if ~exist('fWhite2Pial','var') || isempty(fWhite2Pial)
	fWhite2Pial = 0.5;	% layer1 ~ 0.3, layer3 ~ 1
end

% PIR, rows, inward normals, 0-indexing faces, origin @ ASL volume corner
cortex = load(fullfile(anatDir,'Standard','meshes','defaultCortex.mat'));
F0 = cortex.msh.data.triangles' + 1;
if fWhite2Pial == 0
	V0 = cortex.msh.initVertices([3 1 2],:)' - 128;
elseif fWhite2Pial == 1
	V0 = cortex.msh.data.vertices([3 1 2],:)' - 128;
else
	V0 = (1-fWhite2Pial)*cortex.msh.initVertices([3 1 2],:)' + fWhite2Pial*cortex.msh.data.vertices([3 1 2],:)' - 128;
end
V0(:,2:3) = -V0(:,2:3); 

if ~exist('geomview_read_off','file')
	if ispc
		addpath('X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox',0)
	else
		addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	end
end

% LAS, columns, outward normals, 1-indexing faces, origin @ RPI volume corner
try
	[anatBase,subjid] = fileparts( anatDir(1:numel(anatDir)-(anatDir(end)==filesep)) );
	[V1,F1] = readTriFile(fullfile(anatBase,'FREESURFER_SUBS',[subjid,'_fs4'],'bem','inner_skull.tri'));
catch
	try
		[V1,F1] = geomview_read_off(fullfile(anatDir,'nifti','headmodel_inskull_mesh.off'));
	catch
		[V1,F1] = geomview_read_off(fullfile(anatDir,'nifti','betsurf_inskull_mesh.off'));
	end
	V1 = V1 - 128;
	V1(:,1) = -V1(:,1);
end

clf
P0 = brainPatch(V0,F0);
set(P0,'facecolor','g')
P1 = patch('vertices',V1,'faces',F1,'edgecolor','none','facecolor','g','facelighting','gouraud','facealpha',0.75,'facecolor',[1 0.5 0.5]);
xlabel('+Right')
ylabel('+Anterior')
zlabel('+Superior')

set(gca,'view',[45 30])

if isempty(findobj(gcf,'label','ChangeView'))
	UIm = uimenu('label','ChangeView');
	uimenu(UIm,'label','anterior','callback','set(gca,''view'',[180 0])')
	uimenu(UIm,'label','posterior','callback','set(gca,''view'',[0 0])')
	uimenu(UIm,'label','left','callback','set(gca,''view'',[-90 0])')
	uimenu(UIm,'label','right','callback','set(gca,''view'',[90 0])')
	uimenu(UIm,'label','dorsal','callback','set(gca,''view'',[0 90])')
	uimenu(UIm,'label','ventral','callback','set(gca,''view'',[0 -90])')
end

