function FS4parc2cortex(FSsubjid,mrmFile,atlas)
% generate ROI files for use with mrCURRENT
%
% FS4parc2cortex(FS4subjid,mrmFile,atlas)
% FS4subjid = Freesurfer4 subject ID string
% mrmFile   = cortex mesh mat-file
% atlas     = 'aparc' or 'aparc.a2005s' 
%             aparc is the Desikan et al. 2007 atlas
%             aparc.a2005s is the Fischl et al. atlas


if ~exist('FSsubjid','var') || isempty(FSsubjid)
	if ispc
		FSdir = uigetdir('X:\anatomy\FREESURFER_SUBS','Freesurfer subject folder');
	else
		FSdir = uigetdir('/raid/MRI/anatomy/FREESURFER_SUBS','Freesurfer subject folder');
	end
	if isnumeric(FSdir)
		return
	end
	[junk,FSsubjid] = fileparts(FSdir);
else
	if ispc
		FSdir = fullfile('X:\anatomy\FREESURFER_SUBS',FSsubjid);
	else
		FSdir = fullfile('/raid/MRI/anatomy/FREESURFER_SUBS',FSsubjid);
	end
	if ~exist(FSdir,'dir')
		error('Directory %s does not exist',FSdir)
	end
end
if ~exist('mrmFile','var') || isempty(mrmFile)
	[mrmFile,mrmPath] = uigetfile('*.mat','cortex mesh mat-file');
	if isnumeric(mrmFile)
		return
	end
	mrmFile = [mrmPath,mrmFile];
end
if ~exist('atlas','var') || isempty(atlas)
	switch questdlg('Choose atlas','FS4parc2ortex.m','Desikan','Fischl','Desikan');
	case 'Desikan'
		atlas = 'aparc';
	case 'Fischl'
		atlas = 'aparc.a2005s';
	otherwise
		return
	end
end

% check for req'd toolboxes
if ~exist('nearpoints','file')
	if ispc
		addpath(genpath('X:\toolbox\VISTASOFT_DEVEL'),0)
	else
		addpath(genpath('/raid/MRI/toolbox/VISTASOFT_DEVEL'),0)
	end
end
if ~exist('freesurfer_read_surf','file')
	if ispc
		addpath('X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox',0)
	else
		addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	end
end
if ~exist('read_annotation','file')
% 	disp('adding Freesurfer 4.0.1 matlab toolbox')
	if ispc
		addpath('X:\toolbox\MGH\fs4\matlab',0)
	else
		addpath('/raid/MRI/toolbox/MGH/fs4/matlab',0)
	end
end


% load mrMesh file
Mdec = load(mrmFile);
Mdec.msh.nVertex = sum(Mdec.msh.nVertexLR);
% sanity check
if any( [ size(Mdec.msh.data.vertices,2), size(Mdec.msh.initVertices,2) ] ~= Mdec.msh.nVertex )
	error('vertex disagreement within %s',mrmFile)
end
% get has before doing any transforms
meshHash = hashOld(Mdec.msh.data.vertices(:),'md5');
% undo FS4 to mrMesh xForms (go from PIR back to RAS)
% pial
Mdec.msh.data.vertices = Mdec.msh.data.vertices' - 128;					% origin @ volume center
Mdec.msh.data.vertices(:,1:2) = -Mdec.msh.data.vertices(:,1:2);		% ASR
Mdec.msh.data.vertices = Mdec.msh.data.vertices(:,[3 1 2]);				% RAS
Mdec.msh.data.triangles = Mdec.msh.data.triangles';
% 			% white
% 			Mdec.msh.initVertices = Mdec.msh.initVertices' - 128;
% 			Mdec.msh.initVertices(:,1:2) = -Mdec.msh.initVertices(:,1:2);
% 			Mdec.msh.initVertices = Mdec.msh.initVertices(:,[3 1 2]);
% get left & right hemisphere vertex indices
kL = 1:Mdec.msh.nVertexLR(1);
kR = (Mdec.msh.nVertexLR(1)+1):Mdec.msh.nVertex;



% read freesurfer files
FSv = freesurfer_read_surf(fullfile(FSdir,'surf','lh.pial'));
[iL,e2L] = nearpoints(Mdec.msh.data.vertices(kL,:)',FSv');				% nearpoints(src,dst), indices can have duplicate entries
FSv = freesurfer_read_surf(fullfile(FSdir,'surf','rh.pial'));
[iR,e2R] = nearpoints(Mdec.msh.data.vertices(kR,:)',FSv');
if any( [e2L,e2R] > (0.001^2) )
	error('chosen mrmFile doesn''t align with Freesurfer surfaces')
end


iROI = 0;
ROIs = struct('name','','coords',[],'color',[],'ViewType','','meshIndices',[],'meshHash','','date','','comment','');
creationTime = datestr(now,0);

% LEFT HEMI
% [ vertex index, numeric vertex label, parcellation structure ]
[iV,label,parc] = read_annotation(fullfile(FSdir,'label',['lh.',atlas,'.annot']));
for iLabel = 1:parc.numEntries
	iROI = iROI + 1;
% 	ROIs(iROI).name = parc.struct_names{iLabel};
	ROIs(iROI).name = [parc.struct_names{iLabel},'-L'];
	ROIs(iROI).coords = [];
	ROIs(iROI).color = parc.table(iLabel,1:3)/255;		% nx5, 1st 3 cols = rgb, 4th = 0, 5th = ID
	ROIs(iROI).ViewType = 'Gray';
	ROIs(iROI).meshIndices = kL(label(iL)==parc.table(iLabel,5));
	ROIs(iROI).meshHash = meshHash;
	ROIs(iROI).date = creationTime;
	ROIs(iROI).comment = 'Freesurfer anatomical labeling made by FS4parc2cortex.m';
end
nROI = [ iROI, 0 ];
% RIGHT HEMI
[iV,label,parc] = read_annotation(fullfile(FSdir,'label',['rh.',atlas,'.annot']));
for iLabel = 1:parc.numEntries
	iROI = iROI + 1;
% 	ROIs(iROI).name = parc.struct_names{iLabel};
	ROIs(iROI).name = [parc.struct_names{iLabel},'-R'];
	ROIs(iROI).coords = [];
	ROIs(iROI).color = parc.table(iLabel,1:3)/255;
	ROIs(iROI).ViewType = 'Gray';
	ROIs(iROI).meshIndices = kR(label(iR)==parc.table(iLabel,5));
	ROIs(iROI).meshHash = meshHash;
	ROIs(iROI).date = creationTime;
	ROIs(iROI).comment = 'Freesurfer anatomical labeling made by FS4parc2cortex.m';
end
nROI(2) = iROI - nROI(1);

cdata = zeros(Mdec.msh.nVertex,3);
used = zeros(Mdec.msh.nVertex,1);

hemi = 'LR';
for iROI = 1:sum(nROI)
	if any( used(ROIs(iROI).meshIndices) ~= 0 )
% 		fprintf('Warning: ROI %s-%s overlap\n',ROIs(iROI).name,hemi(1+(iROI>nROI(1))))
		fprintf('Warning: ROI %s overlap\n',ROIs(iROI).name)
	end
	used(ROIs(iROI).meshIndices) = iROI;
	cdata(ROIs(iROI).meshIndices,:) = repmat(ROIs(iROI).color,numel(ROIs(iROI).meshIndices),1);
end

kFr = find(Mdec.msh.data.triangles(:,1) > (Mdec.msh.nVertexLR(1)-1),1,'first');		% 1st RH face index

switch atlas
case 'aparc'
	atlasName = 'Desikan';
case 'aparc.a2005s'
	atlasName = 'Fischl';
otherwise
	atlasName = '?';
end
figure('name',atlasName)
subplot(121)
	patch(struct('vertices',Mdec.msh.data.vertices(kL,:),'faces',Mdec.msh.data.triangles(1:(kFr-1),:)+1),...
		'facevertexcdata',cdata(kL,:),'facecolor','interp','facelighting','gouraud','edgecolor','none')
	light('position',[0 0  256])
	light('position',[0 0 -256])
	light('position',[ 256 0 0])
	light('position',[-256 0 0])
	xlabel('+Right'),ylabel('+Anterior'),zlabel('+Superior'),title('LEFT')
	set(gca,'dataaspectratio',[1 1 1],'view',[0 90],'xlim',[-100 25],'ylim',[-150 100],'zlim',[-100 150])
subplot(122)
	patch(struct('vertices',Mdec.msh.data.vertices(kR,:),'faces',Mdec.msh.data.triangles(kFr:end,:)+(1-Mdec.msh.nVertexLR(1))),...
		'facevertexcdata',cdata(kR,:),'facecolor','interp','facelighting','gouraud','edgecolor','none')
	light('position',[0 0  256])
	light('position',[0 0 -256])
	light('position',[ 256 0 0])
	light('position',[-256 0 0])
	xlabel('+Right'),ylabel('+Anterior'),zlabel('+Superior'),title('RIGHT')
	set(gca,'dataaspectratio',[1 1 1],'view',[0 90],'xlim',[-25 100],'ylim',[-150 100],'zlim',[-100 150])

UIm = uimenu('label','HemiViews');
uimenu(UIm,'label','dorsal','callback','set([subplot(121),subplot(122)],''view'',[0 90])')
uimenu(UIm,'label','ventral','callback','set([subplot(121),subplot(122)],''view'',[0 -90])')
uimenu(UIm,'label','medial','callback','set(subplot(121),''view'',[90 0]),set(subplot(122),''view'',[-90 0])')
uimenu(UIm,'label','lateral','callback','set(subplot(121),''view'',[-90 0]),set(subplot(122),''view'',[90 0])')
uimenu(UIm,'label','anterior','callback','set([subplot(121),subplot(122)],''view'',[180 0])')
uimenu(UIm,'label','posterior','callback','set([subplot(121),subplot(122)],''view'',[0 0])')
uimenu(UIm,'label','SAVE ROIs','separator','on','callback',@saveAnatROIs)

% disp(fileparts(mrmFile))

function saveAnatROIs(varargin)
	ROIdir = uigetdir(fileparts(mrmFile),'ROI output directory');
	if ~isnumeric(ROIdir)
		for i = 1:sum(nROI)
			ROI = ROIs(i);
% 			ROIfile = fullfile(ROIdir,[ROI.name,'-',hemi(1+(i>nROI(1))),'.mat']);
			ROIfile = fullfile(ROIdir,[ROI.name,'.mat']);
			disp(['writing ',ROIfile])
			save(ROIfile,'ROI')
		end
		set(gcbo,'visible','off')
		disp(['wrote ',int2str(i),' mesh ROI files.'])
	end
end

end

