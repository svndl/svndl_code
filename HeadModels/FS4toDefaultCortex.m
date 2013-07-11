function FS4toDefaultCortex(FSsubjid,useMNEdec)
% FS4toDefaultCortex(FS4subjid,true)	- uses MNE's ico 5 decimation
% FS4toDefaultCortex(FS4subjid,false)  - uses Matlab's reducepatch

if ~ispc
	if strcmp(questdlg('Warning: MrMesh crashing on wocket.  Continue?','FS4toDefaultCortex.m','Yes','No','No'),'No')
		return
	end
end

if ~exist('useMNEdec','var') || isempty(useMNEdec)
	useMNEdec = true;
end


%% get freesurfer subject directory
if ~exist('FSsubjid','var') || isempty(FSsubjid)
	FSdir = uigetdir(fullfile(SKERIanatDir,'FREESURFER_SUBS'),'Freesurfer subject folder');
	if isnumeric(FSdir)
		return
	end
	[junk,FSsubjid] = fileparts(FSdir);
else
	FSdir = fullfile(SKERIanatDir,'FREESURFER_SUBS',FSsubjid);
	if ~exist(FSdir,'dir')
		error('Directory %s does not exist',FSdir)
	end
end

%% check for req'd functions
if exist('freesurfer_read_surf','file')
	path2add = '';
else
% 	if ~strcmp(questdlg('Add EEG toolbox to path?','EEG Toolbox Required','Yes','Cancel','Yes'),'Yes')
% 		disp('exiting FS4toDefaultCortex.m')
% 		return
% 	end
	if ispc
		path2add = 'X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox';
	else
		path2add = '/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox';
	end
% 	disp(['adding to path ',path2add])
	addpath(path2add,0)
end



if useMNEdec
	if exist('mne_read_source_spaces','file')
		MNEpath = '';
	else
		if ispc
			MNEpath = 'X:\toolbox\MNESuite\mne\matlab\toolbox';
		else
			MNEpath = '/raid/MRI/toolbox/MNESuite/mne/matlab/toolbox';
		end
		addpath(MNEpath,0)
	end

	surfName = 'pial';	% assumes pial input to mne_setup_source_space, no way to verify???

	if strcmp(FSdir(end),filesep)
		[junk,code] = fileparts(FSdir(1:end-1));
	else
		[junk,code] = fileparts(FSdir);
	end

	surf1 = 'white';
	surf2 = 'pial';
% 	surf1 = 'smoothwm';			% for average brains
% 	surf2 = 'smoothpial';

	src = mne_read_source_spaces(fullfile(FSdir,'bem',[code,'-ico-5-src.fif']));
	src(1).inuse = double(src(1).inuse);
	src(1).inuse(src(1).vertno) = 1:src(1).nuse;
% 	V2L = [ -src(1).rr(src(1).vertno,2:3), src(1).rr(src(1).vertno,1) ]*1e3 + 128;
	F2L = src(1).inuse(src(1).use_tris);
	V1L = freesurfer_read_surf(fullfile(FSdir,'surf',['lh.',surf1]));
	V1L = [ -V1L(src(1).vertno,2:3), V1L(src(1).vertno,1) ] + 128;
	V2L = freesurfer_read_surf(fullfile(FSdir,'surf',['lh.',surf2]));
	V2L = [ -V2L(src(1).vertno,2:3), V2L(src(1).vertno,1) ] + 128;
	
	src(2).inuse = double(src(2).inuse);
	src(2).inuse(src(2).vertno) = 1:src(2).nuse;
% 	V2R = [ -src(2).rr(src(2).vertno,2:3), src(2).rr(src(2).vertno,1) ]*1e3 + 128;
	F2R = src(2).inuse(src(2).use_tris);
	V1R = freesurfer_read_surf(fullfile(FSdir,'surf',['rh.',surf1]));
	V1R = [ -V1R(src(2).vertno,2:3), V1R(src(2).vertno,1) ] + 128;
	V2R = freesurfer_read_surf(fullfile(FSdir,'surf',['rh.',surf2]));
	V2R = [ -V2R(src(2).vertno,2:3), V2R(src(2).vertno,1) ] + 128;
	
	clear junk code src surf1 surf2
	if ~isempty(MNEpath)
		rmpath(MNEpath)
	end
else
	%% FS4 surfaces are RAS, inward normals, origin at center.  Convert to PIR
	surf1 = 'white';		% orig, white, or smoothwm (white is best match to layer1 gray nodes in vistasoft)
	surf2 = 'pial';
	patchReduction = 0.1;
	disp('Loading and decimating freesurfer meshes: this can take some time...')
	% left hemi
	[VfullMesh,FfullMesh] = freesurfer_read_surf(fullfile(FSdir,'surf',['lh.',surf2]));			% do reduction on smoother pial surface
	[F2L,V2L] = reducepatch(FfullMesh,VfullMesh,patchReduction);
	[q,k] = ismember(V2L,VfullMesh,'rows');															% get indices of patch reduction
	V2L = [ -V2L(:,2:3), V2L(:,1) ] + 128;
	VfullMesh = freesurfer_read_surf(fullfile(FSdir,'surf',['lh.',surf1]));
	V1L = [ -VfullMesh(k,2:3), VfullMesh(k,1) ] + 128;
		n = size(VfullMesh,1);
		iDec = zeros(n,1);
		iDec(k) = 1;
		fid = fopen(fullfile(FSdir,'bem','LHpial.dec'),'wb','b');
		fwrite(fid,0,'uint8');
		fwrite(fid,n,'uint32');
		fwrite(fid,iDec,'uint8');
		fclose(fid);
	% right hemi
	[VfullMesh,FfullMesh] = freesurfer_read_surf(fullfile(FSdir,'surf',['rh.',surf2]));
	[F2R,V2R] = reducepatch(FfullMesh,VfullMesh,patchReduction);
	[q,k] = ismember(V2R,VfullMesh,'rows');
	V2R = [ -V2R(:,2:3), V2R(:,1) ] + 128;
	VfullMesh = freesurfer_read_surf(fullfile(FSdir,'surf',['rh.',surf1]));
	V1R = [ -VfullMesh(k,2:3), VfullMesh(k,1) ] + 128;
		n = size(VfullMesh,1);
		iDec = zeros(n,1);
		iDec(k) = 1;
		fid = fopen(fullfile(FSdir,'bem','RHpial.dec'),'wb','b');
		fwrite(fid,0,'uint8');
		fwrite(fid,n,'uint32');
		fwrite(fid,iDec,'uint8');
		fclose(fid);
	% cleanup
	surfName = surf2;
	clear VfullMesh FfullMesh surf1 surf2 patchReduction q k n iDec fid msg
end

if ~isempty(path2add)
	rmpath(path2add)
end
nVertexLR = [ size(V2L,1), size(V2R,1) ];


%% allocate msh structure
host = 'localhost';
windowID = 1;
mmPerVox = [1 1 1];
relaxIter = 0;
meshName = '';
queryFlag = false;		% GUI query for mesh options?

msh = meshDefault(host,windowID,mmPerVox,relaxIter,meshName,1);		% The last number is the decimate amount.
if queryFlag
	msh = meshQuery(msh,1);								% meshQuery(msh,1) -> short list, meshQuery(msh,0) -> long list
else
	msh = meshSet(msh,'smoothiterations',0);		%	msh.smooth_iterations = 0;		% default = 50
end


%% initialize host window
% if the windowID is already open & server running, nothing happens
% 'Error connecting to server' dumped to command window, don't sweat it
msh = mrmInitHostWindow(msh)
% add actor, data, lights, ...
% Changing background color to ID FS4 meshes
msh = mrmInitMesh(msh,[0 0.3 0]);


%% we already have host & windowID, need this for error checking???
host = meshGet(msh,'host');
windowID = meshGet(msh,'windowid');
if isempty(host), host = 'localhost'; end
if isempty(windowID), error('Mesh must specify a window'); end


%%
% old pipeline smoothing
% 		tmpMsh = struct('uniqueVertices',V2L,'uniqueFaceIndexList',F2L);
% 		tmpMsh.conMat = findConnectionMatrix(tmpMsh);
% 		tmpMsh = smoothMeshVertices(tmpMsh);
% 		V2L = tmpMsh.uniqueVertices';
p = struct('vertices',[V2L',V2R'],'triangles',[F2L'-1,F2R'+(nVertexLR(1)-1)],...
	'class','mesh','scale',meshGet(msh,'mmPerVox'),...
	'do_smooth',0,'do_smooth_pre',0,'do_decimate',0,...
	'actor',meshGet(msh,'actor'),'colors',repmat(255,4,sum(nVertexLR)),...
	'normals',[]);
if queryFlag
	if meshGet(msh,'smoothiterations') ~= 0
		p.do_smooth = 1;
		p.smooth_iterations = meshGet(msh,'smoothiterations');
		p.smooth_relaxation = meshGet(msh,'smoothrelaxation');
		p.smooth_sinc_method = meshGet(msh,'smoothmethod');
		p.do_smooth_pre = meshGet(msh,'smooth_pre');
	end
	if meshGet(msh,'decimatereduction') ~= 1
		p.do_decimate = 1;
		p.decimate_reduction = meshGet(msh,'decimatereduction');
		p.decimate_iterations = meshGet(msh,'decimateiterations');
	end
end

%% add mesh
mrMesh(host,windowID,'set_mesh',p);

msh.grayLayers = 3;												% was zero
msh.initVertices = [V1L',V1R'];								% was empty
mrmSet(msh,'origin',-mean(msh.initVertices,2)');		% ??? why negative ???

% old pipeline gray maps
% 		disp('Finding vertex to gray map')		% You have to do this before smoothing...
% 		view = getSelectedVolume;
% 		msh.vertexGrayMap =  mrmMapVerticesToGray(vertices,view.nodes,[1 1 1],view.edges,6);		% original field
% 		msh.grayToVertexMap = mrmMapGrayToVertices(view.nodes,vertices, [1 1 1]);						% added by ARW


% Attach curvature data to the mesh
msh = mrmSet(msh,'curvature');			% msh.data fields still empty
% msh.data.colors takes values here, other fields still empty
msh = mrmSet(msh,'colors',uint8( round( (double(msh.curvature>0)*256-128)*meshGet(msh,'curvatureModDepth') + 127.5 ) ));

msh = meshSet(msh,'data',mrmGet(msh,'data'));		% msh.data fields set here
msh = meshSet(msh,'connectionMatrix',1);				% msh.conMat was empty, now = nVertices x nVertices logical

msh.surface = surfName;
msh.nVertexLR = nVertexLR;

defDir = fullfile(SKERIanatDir,strtok(FSsubjid,'_'));
if isdir(defDir)
	if useMNEdec
		if isdir(fullfile(defDir,'Standard'))
			if isdir(fullfile(defDir,'Standard','meshes'))
				defDir = fullfile(defDir,'Standard','meshes');
			else
				defDir = fullfile(defDir,'Standard');
			end
		end
	end
else
	defDir = '';
end
if useMNEdec
% 	[mshFile,mshPath] = uiputfile('*.mat','Save cortical mesh',fullfile(defDir,['cortex_MNEdec_',datestr(now,'mmddyy'),'.mat']));
	[mshFile,mshPath] = uiputfile('*.mat','Save cortical mesh',fullfile(defDir,'defaultCortex.mat'));
else
	[mshFile,mshPath] = uiputfile('*.mat','Save cortical mesh',fullfile(defDir,['cortex_decp1_pial_',datestr(now,'mmddyy'),'.mat']));
end
if ~isnumeric(mshFile)
	save([mshPath,mshFile],'msh')
end

% questdlg('Close mesh window','FS4toDefaultCortex.m','OK','OK');
mrmCloseWindow(windowID,host);

return


