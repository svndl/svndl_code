function FSLoff2EMSEwfr(r,offFileBase,wfrFileBase)
% Convert non-cortical off-file meshes from FSL's betsurf to EMSE wfr format
% requires geomview_read_off.m & mesh_write_emse.m from EEG_MEG_Toolbox/eeg_toolbox
%
% SYNTAX:	FSLoff2EMSEwfr(reduction,offFileBase,wfrBase)
%           reduction = input to Matlab's reducepatch.  2048 is standard number of EMSE mesh faces
%           offFileBase = base filename of off-files to load
%           wfrFileBase = base filename for wireframes to write
%
% e.g.      FSLoff2EMSEwfr(2048,'betsurf','/raid/MRI/anatomy/subject/EMSE/VolSpace_wireframes/vSpace_FSL.wfr')
% 
% Call with 0 or 1 input(s) brings up dialogs to choose files
% Default reduction is none

if exist('offFileBase','var')
	offPath = fileparts(offFileBase);
else
	[offFile,offPath] = uigetfile('*_inskull_mesh.off','Choose head mesh off-file');
	if isnumeric(offFile)
		return
	end
	offFileBase = [offPath,offFile(1:(strfind(offFile,'_inskull')-1))];
end

if ~exist('geomview_read_off','file') || ~exist('mesh_write_emse','file')
	if ~strcmp(questdlg('Add EEG toolbox to path?','EEG Toolbox required','Yes','Cancel','Yes'),'Yes')
		disp('exiting FSLoff2EMSEwfr.m')
		return
	end
	if ispc
		addpath('X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox',0)
	else
		addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	end
end

[V1,F1] = geomview_read_off([offFileBase,'_inskull_mesh.off']);
[V2,F2] = geomview_read_off([offFileBase,'_outskull_mesh.off']);
[V3,F3] = geomview_read_off([offFileBase,'_outskin_mesh.off']);

% Do some checks?
% Probably overkill, looks like betsurf enforces all this (enabling for the moment)
if ~false
	if (size(V2,1)~=size(V1,1)) || (size(V3,1)~=size(V1,1))
		error('Meshes have different # vertices')
	end
	% check that face matrices are equal for 3 meshes - implies vertex agreement
	if any(size(F2)~=size(F1)) || any(size(F3)~=size(F1)) || ~all(F2(:)==F1(:)) || ~all(F3(:)==F1(:))
		error('Mesh faces don''t agree')
	end
end

% Re-order faces for outward normals
F1 = F1(:,[1 3 2]);
clear F2 F3

% FSL's off-files have LAS vertices, convert to RAS
V1(:,1) = 256 - V1(:,1);		% 257???
V2(:,1) = 256 - V2(:,1);
V3(:,1) = 256 - V3(:,1);

% get distances between meshes
d12 = sqrt(sum((V2-V1).^2,2));
d23 = sqrt(sum((V3-V2).^2,2));
dH = 0.5:1:127.5;		% histogram bin centers
dLim = [0 30];			% axes xlim

% reduce meshes
if exist('r','var')
	nV = [ size(V1,1), 0 ];
	nF = [ size(F1,1), 0 ];
	[F1r,V1r] = reducepatch(F1,V1,r);
	[q,kr] = ismember(V1r,V1,'rows');		% get indices of patch reduction
	V1 = V1r;
	V2 = V2(kr,:);
	V3 = V3(kr,:);
	F1 = F1r;
	clear V1r F1r q kr
	nV(2) = size(V1,1);
	nF(2) = size(F1,1);
	fprintf('\nReduced meshes\nVertices: %d => %d\n   Faces: %d => %d\n',nV,nF)
end

% PLOT
ss = get(0,'screensize');
figure('position',ss([3 4 3 4]).*[0.3 0.15 0.4 0.7])
axes('position',[0.10 0.75 0.40 0.2])
	hist(d12,dH)
	xlim(dLim)
	title('Skull Thickness')
axes('position',[0.55 0.75 0.40 0.2])
	hist(d23,dH)
	xlim(dLim)
	title('Skin Thickness')
axes('position',[0.10 0.10 0.85 0.6])
	P = [ ...
			patch(struct('vertices',V1,'faces',F1),'FaceVertexCData',[0 0 1],'facecolor','flat','edgecolor','none'),...
			patch(struct('vertices',V2,'faces',F1),'FaceVertexCData',[1 1 0],'facecolor','flat','edgecolor','none','facealpha',0.5),...
			patch(struct('vertices',V3,'faces',F1),'FaceVertexCData',[1 0 0],'facecolor','flat','edgecolor','none','facealpha',0.25)...
		];
	light('position',[128 128 256],'color',[1 1 1],'style','infinite');
	set(gca,'xlim',[0 256],'xtick',0:32:256,'xgrid','on',...
		'ylim',[0 256],'ytick',0:32:256,'ygrid','on',...
		'zlim',[0 256],'ztick',0:32:256,'zgrid','on',...
		'view',[90 0])
	set(P,'facelighting','gouraud')
	xlabel('+right'),ylabel('+anterior'),zlabel('+superior')
drawnow


% Save wireframes
if ~exist('wfrFileBase','var')
	[wfrFile,wfrPath] = uiputfile(fullfile(offPath,'*.wfr'),'EMSE wireframes (note: "_meshtype" gets appended)','volspace');
	if isnumeric(wfrFile)
		warning('Wireframes not saved!')
		return
	end
	wfrFileBase = [wfrPath,wfrFile];
end
[wfrPath,wfrFile,wfrExt] = fileparts(wfrFileBase);
wfrFileBase = [wfrFile,'.wfr'];

% use ASR vertices
% mesh_write_emse appends meshtype to filename
mesh_write_emse( struct(	'mesh',struct(	'path',wfrPath,...
														'file',wfrFileBase,...
														'data',struct(	'meshtype',{{'inner_skull'}},...
																			'vertices',{{V1(:,[2 3 1])-128}},...
																			'faces',{{F1}}	)	)	) );
mesh_write_emse( struct(	'mesh',struct(	'path',wfrPath,...
														'file',wfrFileBase,...
														'data',struct(	'meshtype',{{'outer_skull'}},...
																			'vertices',{{V2(:,[2 3 1])-128}},...
																			'faces',{{F1}}	)	)	) );
mesh_write_emse( struct(	'mesh',struct(	'path',wfrPath,...
														'file',wfrFileBase,...
														'data',struct(	'meshtype',{{'scalp'}},...
																			'vertices',{{V3(:,[2 3 1])-128}},...
																			'faces',{{F1}}	)	)	) );
	
	
