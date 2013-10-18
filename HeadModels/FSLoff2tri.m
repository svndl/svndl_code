function FSLoff2tri(FSLbase,FSsubjid)
% FSLoff2tri(FSLbase,FSsubjid)
% e.g. FSLoff2tri('betsurf','skeri0123_fs4')


if ~exist('geomview_read_off','file')
	if ispc
		addpath('X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox',0)
	elseif isunix && ~ismac
		addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	elseif ismac
		addpath('/Volumes/Denali_MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	end
end

% LAS, columns, outward normals, 1-indexing faces, origin @ RPI volume corner
FSLdir = fileparts([FSLbase,'_inskull_mesh.off']);
if isempty(FSLdir)
	disp(['reading off-files from ',pwd])
else
	disp(['reading off-files from ',FSLdir])
end
[V1,F1] = geomview_read_off([FSLbase,'_inskull_mesh.off']);
[V2,F2] = geomview_read_off([FSLbase,'_outskull_mesh.off']);
[V3,F3] = geomview_read_off([FSLbase,'_outskin_mesh.off']);

	% zero @ volume center, flip LR, (zero-index faces)
	V1 = V1 - 128;			V1(:,1) = -V1(:,1);			% F1 = F1 - 1;
	V2 = V2 - 128;			V2(:,1) = -V2(:,1);			% F2 = F2 - 1;
	V3 = V3 - 128;			V3(:,1) = -V3(:,1);			% F3 = F3 - 1;


% PLOT
figure
	P = [ ...
			patch(struct('vertices',V1,'faces',F1),'FaceVertexCData',[0 0 1],'facecolor','flat','edgecolor','none'),...
			patch(struct('vertices',V2,'faces',F2),'FaceVertexCData',[1 1 0],'facecolor','flat','edgecolor','none','facealpha',0.5),...
			patch(struct('vertices',V3,'faces',F3),'FaceVertexCData',[1 0 0],'facecolor','flat','edgecolor','none','facealpha',0.25)...
		];
	light('position',[0 0 256],'color',[1 1 1],'style','infinite');
	set(gca,'xlim',[-128 128],'xtick',-128:32:128,'xgrid','on',...
		'ylim',[-128 128],'ytick',-128:32:128,'ygrid','on',...
		'zlim',[-128 128],'ztick',-128:32:128,'zgrid','on',...
		'view',[90 0],'dataaspectratio',[1 1 1])
	set(P,'facelighting','gouraud')
	xlabel('+right'),ylabel('+anterior'),zlabel('+superior')
drawnow

% SAVE

subDir = getpref('freesurfer','SUBJECTS_DIR');

triDir = fullfile(subDir,FSsubjid,'bem');
% if ispc
% 	triDir = fullfile('X:\anatomy\FREESURFER_SUBS',FSsubjid,'bem');
% else
% 	triDir = fullfile('/raid/MRI/anatomy/FREESURFER_SUBS',FSsubjid,'bem');
% end


writeTriFile(V1,F1,fullfile(triDir,'inner_skull.tri'))	%,'betsurf mesh')
writeTriFile(V2,F2,fullfile(triDir,'outer_skull.tri'))	%,'betsurf mesh')
writeTriFile(V3,F3,fullfile(triDir,'outer_skin.tri'))	%,'betsurf mesh')




if false
	% PIR, rows, inward normals, 0-indexing faces, origin @ ASL volume corner
	% FS4 to mrM conversion only involves *(-1) & (+128)
	[mrmFile,mrmPath] = uigetfile(fullfile(FSLdir,'*.mat'),'cortex mesh mat-file');
	if isnumeric(mrmFile)
		return
	end
	disp(['loading ',mrmPath,mrmFile])
	cortex = load([mrmPath,mrmFile]);

		V0 = cortex.msh.data.vertices([3 1 2],:)' - 128;
		V0(:,2:3) = -V0(:,2:3);
		F0 = cortex.msh.data.triangles' + 1;

	writeTriFile(V0,F0,fullfile(triDir,'cortex.tri'))	%,'decimeated Freesurfer mesh')

	decFile = fullfile(triDir,'cortex.dec');
	nV = size(V0,1);
	[fid,msg] = fopen(decFile,'wb','b');
	fwrite(fid,[0],'uint8');
	fwrite(fid,nV,'uint32');
	fwrite(fid,ones(nV,1),'uint8');
	fclose(fid);
end
