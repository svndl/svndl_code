function makeWhite2PialEMSEmesh(FSsubjid,wfrFile,MLRdir,patchReduction)
% * Loads Freesurfer white and pial surfaces for both hemispheres
% * Reduces them to either a  relative or absolute number of faces (see reducepatch.m)
% * Interactively interpolates a new surface between them
% * Saves to EMSE wfr-format, and mrMesh if a mrLoadRet gray view is open
%
% Requires EEG_MEG_Toolbox/eeg_toolbox
%
% SYNTAX:
% makeWhite2PialEMSEmesh(FSsubjid,wfrFile,MLRdir,patchReduction)
% FSsubjid       - Freesurfer subjid, you'll get prompted if not supplied
% wfrFile        - EMSE wireframe to save, you'll get prompted if not supplied
% MLRdir         - mrLoadRet directory for the same subject, default = current directory
% patchReduction - fraction of original surface face, default = 0.1
%
% SCN 2/7/08


if ~exist('freesurfer_read_surf','file')
% 	error('add EEG toolbox')
	if ~strcmp(questdlg('Add EEG toolbox to path?','EEG Toolbox Required','Yes','Cancel','Yes'),'Yes')
		disp('exiting makeWhite2PialEMSEmesh')
		return
	end
	if ispc
		addpath('X:\toolbox\matlab_toolboxes\EEG_MEG_Toolbox\eeg_toolbox',0)
	else
		addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
	end
	pause(0.1)	% or you don't ever see the uigetdir dialog???
end

if ieNotDefined('FSsubjid')
	if ispc
		FSdir = uigetdir('X:\anatomy\FREESURFER_SUBS','Pick a freesurfer subject folder');
	else
		FSdir = uigetdir('/raid/MRI/anatomy/FREESURFER_SUBS','Pick a freesurfer subject folder');
	end
	if isnumeric(FSdir)
		return
	end
	[junk,FSsubjid] = fileparts(FSdir);		% uigetdir doesn't add trailing filesep, otherwise you'd have to trim it 1st
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
FSdir = fullfile(FSdir,'surf');

mrGlobals
if ieNotDefined('MLRdir')
% 	MLRdir = pwd;
	MLRdir = HOMEDIR;
end
grayCoords = false;
if iscell(VOLUME)
	if ~isempty(selectedVOLUME) && strcmp(VOLUME{selectedVOLUME}.viewType,'Gray')
		grayCoords = true;
	else
		disp('selectedVOLUME not Gray, looking...')
		i = 0;
		selectedVOLUME = [];
		while i < numel(VOLUME)
			i = i + 1;
			if isstruct(VOLUME{i}) && strcmp(VOLUME{i}.viewType,'Gray')
				grayCoords = true;
				selectedVOLUME = i;
				disp(['using VOLUME{',int2str(i),'} gray nodes'])
				break
			end
		end
		if isempty(selectedVOLUME)
			disp('No open Gray VOLUME found, looking in Gray dir for coords')
		end
	end
end
if ~grayCoords
	grayCoords = fullfile(MLRdir,'Gray','coords.mat');
	if ~exist(grayCoords,'file')
		error('No Gray coords.mat file in %s',MLRdir)
	end
end

if ieNotDefined('patchReduction')
	patchReduction = 0.1;
	fprintf('Reducing by %g as a default\n',patchReduction)
end


% Load pial surfaces, decimate, load white surfaces & extract corresponding vertices
surf1 = 'white';		% orig, white, or smoothwm (white is best match to layer1 gray nodes in vistasoft)
surf2 = 'pial';
disp('Loading and decimating freesurfer meshes: this can take some time...')

hemi2 = exist(fullfile(FSdir,['lh.',surf2]),'file') == 2;
if hemi2
	[VfullMesh,FfullMesh] = freesurfer_read_surf(fullfile(FSdir,['lh.',surf2]));
	[FpialL,VpialL] = reducepatch(FfullMesh(:,[3 2 1]),VfullMesh(:,[2 3 1]),patchReduction);
	[q,k] = ismember(VpialL(:,[3 1 2]),VfullMesh,'rows');					% get indices of patch reduction
	VfullMesh = freesurfer_read_surf(fullfile(FSdir,['lh.',surf1]));
	VwhiteL = VfullMesh(k,[2 3 1]);
else		% whole brain in right hemi
	VpialL = [];
	FpialL = [];
	VwhiteL = [];
	VL = [];
end

[VfullMesh,FfullMesh] = freesurfer_read_surf(fullfile(FSdir,['rh.',surf2]));
[FpialR,VpialR] = reducepatch(FfullMesh(:,[3 2 1]),VfullMesh(:,[2 3 1]),patchReduction);
[q,k] = ismember(VpialR(:,[3 1 2]),VfullMesh,'rows');					% get indices of patch reduction
VfullMesh = freesurfer_read_surf(fullfile(FSdir,['rh.',surf1]));
VwhiteR = VfullMesh(k,[2 3 1]);

clear VfullMesh FfullMesh

if hemi2
	dL = sqrt(sum((VpialL-VwhiteL).^2,2));
end
dR = sqrt(sum((VpialR-VwhiteR).^2,2));

% build intermetiate vertex matrices for matching w/ gray nodes
fWhite2Pial = 0.2;
dWhite = 0.5;
dPial = 3;
interpMode = 1;		% 1,2,or 3
switch interpMode
case 1			% fraction between
	if hemi2
		VL = (1-fWhite2Pial)*VwhiteL + fWhite2Pial*VpialL;
	end
	VR = (1-fWhite2Pial)*VwhiteR + fWhite2Pial*VpialR;
case 2			% expand from white
	if hemi2
		f = repmat(min(dWhite./dL,1),1,3);
		VL = (1-f).*VwhiteL + f.*VpialL;
	end
	f = min(dWhite./dR,1);
	VR = (1-f).*VwhiteR + f.*VpialR;
otherwise		% contract from pial
	interpMode = 3;
	if hemi2
		f = repmat(min(dPial./dL,1),1,3);
		VL = f.*VwhiteL + (1-f).*VpialL;
	end
	f = repmat(min(dPial./dR,1),1,3);
	VR = f.*VwhiteR + (1-f).*VpialR;
end

if islogical(grayCoords)
	gray = struct('allLeftNodes',VOLUME{selectedVOLUME}.allLeftNodes,'allRightNodes',VOLUME{selectedVOLUME}.allRightNodes);
else
	gray = load(grayCoords,'allLeftNodes','allRightNodes');		% IPR coords, PIR nodes w/ layer in row#6
end
layerL = unique(gray.allLeftNodes(6,:));
layerR = unique(gray.allRightNodes(6,:));
nlayerL = numel(layerL);
nlayerR = numel(layerR);
xlayer = max([layerL,layerR]);
clayer=[zeros(xlayer,1),linspace(1,0,xlayer)',ones(xlayer,1)];

% axial slice
cslice = 100;			% slice center
dslice = 2;				% slice thickness
slice = cslice + [-0.5 0.5]*dslice;
kL = gray.allLeftNodes(2,:) >slice(1) & gray.allLeftNodes(2,:) <slice(2);
kR = gray.allRightNodes(2,:)>slice(1) & gray.allRightNodes(2,:)<slice(2);

figsize = get(0,'screensize');
figsize = figsize([3 4 3 4]).*[0.2 0.2 0.6 0.6];
if any(strcmpi(get(0,'units'),{'pixels','points','characters'}))
	figsize = round(figsize);
end
fig = colordef('new','black');
set(fig,'position',figsize,'visible','on')
axes('units','normalized','position',[0.3 0.1 0.65 0.8])

% plot gray layers
H = zeros(1,2+nlayerL+nlayerR);
for i = 1:nlayerL
	k = kL & gray.allLeftNodes(6,:)==layerL(i);
	H(2+i) = line(gray.allLeftNodes(3,k),gray.allLeftNodes(1,k),'linestyle','none','marker','.','color',clayer(layerL(i),:));
end
for i = 1:nlayerR
	k = kR & gray.allRightNodes(6,:)==layerR(i);
	H(2+nlayerL+i) = line(gray.allRightNodes(3,k),gray.allRightNodes(1,k),'linestyle','none','marker','.','color',clayer(layerR(i),:));
end
xL = [min(gray.allLeftNodes(3,kL)),max(gray.allRightNodes(3,kR))];
yL = [min(gray.allLeftNodes(1,kL)),max(gray.allLeftNodes(1,kL))];
xL = xL + 0.1*diff(xL)*[-1 1];
yL = yL + 0.1*diff(yL)*[-1 1];
set(gca,'xlim',xL,'ylim',yL,'ydir','reverse','xtick',[],'ytick',[],'box','on')

% add Freesurfer surfaces
% ASR oriented w/ zero @ center of volume, i.e. to match Gray nodes
% P = 256 - ( V(:,1)' + 128 ) = 128 - V(:,1)'
% I = 256 - ( V(:,2)' + 128 ) = 128 - V(:,2)'
% R =         V(:,3)' + 128
%
% 1 pixel or mm offset in IS (or slice?) dimension
% I = 256 - ( V(:,2)' + 127 ) = 257 - ( V(:,2)' + 128 ) = 129 - V(:,2)'
dz = 1;		% slice(1)< 128 - V(:,2) + dz < slice(2)
if hemi2
	k = VL(:,2)<(128+dz-slice(1)) & VL(:,2)>(128+dz-slice(2));
	H(1) = line(VL(k,3)+128,128-VL(k,1),'linestyle','none','marker','.','color','y');
end
k = VR(:,2)<(128+dz-slice(1)) & VR(:,2)>(128+dz-slice(2));
H(2) = line(VR(k,3)+128,128-VR(k,1),'linestyle','none','marker','.','color','r');
set(H((2-hemi2):2),'markersize',16)
title(sprintf('%s: reduction = %g',strrep(FSsubjid,'_','\_'),patchReduction))

uicontrol(fig,'units','normalized','position',[0.05 0.85 0.15 0.05],'style','text','string','slice pos.')
uicontrol(fig,'units','normalized','position',[0.05 0.80 0.15 0.05],'style','text','string','thickness')
UIb = [...
	uicontrol(fig,'units','normalized','position',[0.05 0.70 0.15 0.05],'style','radiobutton','value',0,'string',[surf1,' -> ',surf2]),...
	uicontrol(fig,'units','normalized','position',[0.05 0.65 0.15 0.05],'style','radiobutton','value',0,'string',[surf1,' +']),...
	uicontrol(fig,'units','normalized','position',[0.05 0.60 0.15 0.05],'style','radiobutton','value',0,'string',[surf2,' -'])		];
set(UIb(interpMode),'value',1)
UI = [...
	uicontrol(fig,'units','normalized','position',[0.2 0.85 0.05 0.05],'style','edit','string',cslice),...
	uicontrol(fig,'units','normalized','position',[0.2 0.80 0.05 0.05],'style','edit','string',dslice),...
	uicontrol(fig,'units','normalized','position',[0.2 0.70 0.05 0.05],'style','edit','enable','on','string',fWhite2Pial),...
	uicontrol(fig,'units','normalized','position',[0.2 0.65 0.05 0.05],'style','edit','enable','off','string',dWhite),...
	uicontrol(fig,'units','normalized','position',[0.2 0.60 0.05 0.05],'style','edit','enable','off','string',dPial),...
	uicontrol(fig,'units','normalized','position',[0.05 0.5 0.2 0.05],'style','pushbutton','string','done')		];
set([UIb,UI],'userdata',false,'callback','set(gcbo,''userdata'',true),uiresume')

while true
	uiwait
	if ~ishandle(fig) || get(UI(6),'userdata')
		break
	elseif get(UIb(1),'userdata')
		interpMode = 1;
		set(UIb(1),'value',1)
		set(UIb(2:3),'value',0)
		set(UI(3),'enable','on','userdata',true)
		set(UI(4:5),'enable','off')
	elseif get(UIb(2),'userdata')
		interpMode = 2;
		set(UIb(2),'value',1)
		set(UIb([1 3]),'value',0)
		set(UI(4),'enable','on','userdata',true)
		set(UI([3 5]),'enable','off')
	elseif get(UIb(3),'userdata')
		interpMode = 3;
		set(UIb(3),'value',1)
		set(UIb(1:2),'value',0)
		set(UI(5),'enable','on','userdata',true)
		set(UI(3:4),'enable','off')
	end
	update = 0;
	if get(UI(1),'userdata')					% update slice center
		try
			tmp = eval(get(UI(1),'string'));
			if isscalar(tmp) && (tmp ~= cslice) && (tmp>1) && (tmp<255)
				cslice = tmp;
				slice = cslice + [-0.5 0.5]*dslice;
				kL = gray.allLeftNodes(2,:) >slice(1) & gray.allLeftNodes(2,:) <slice(2);
				kR = gray.allRightNodes(2,:)>slice(1) & gray.allRightNodes(2,:)<slice(2);
				update = 2;
			end
		catch
			set(UI(1),'string',cslice)
		end
	elseif get(UI(2),'userdata')				% update slice thickness
		try
			tmp = eval(get(UI(2),'string'));
			if isscalar(tmp) && (tmp ~= dslice) && (tmp>0)
				dslice = tmp;
				slice = cslice + [-0.5 0.5]*dslice;
				kL = gray.allLeftNodes(2,:) >slice(1) & gray.allLeftNodes(2,:) <slice(2);
				kR = gray.allRightNodes(2,:)>slice(1) & gray.allRightNodes(2,:)<slice(2);
				update = 2;
			end
		catch
			set(UI(2),'string',dslice)
		end
	elseif get(UI(3),'userdata')				% update fWhite2Pial
		try
			tmp = eval(get(UI(3),'string'));
			if isscalar(tmp) % && (tmp ~= fWhite2Pial) % && (tmp>=0) && (tmp<=1)
				fWhite2Pial = tmp;
				if hemi2
					VL = (1-fWhite2Pial)*VwhiteL + fWhite2Pial*VpialL;
				end
				VR = (1-fWhite2Pial)*VwhiteR + fWhite2Pial*VpialR;
				update = 1;
			end
		catch
			set(UI(3),'string',fWhite2Pial)
		end
	elseif get(UI(4),'userdata')				% update dWhite
		try
			tmp = eval(get(UI(4),'string'));
			if isscalar(tmp) % && (tmp ~= dWhite) % && (tmp>=0)
				dWhite = tmp;
				if hemi2
					f = repmat(min(dWhite./dL,1),1,3);
					VL = (1-f).*VwhiteL + f.*VpialL;
				end
				f = repmat(min(dWhite./dR,1),1,3);
				VR = (1-f).*VwhiteR + f.*VpialR;
				update = 1;
			end
		catch
			set(UI(4),'string',dWhite)
		end
	elseif get(UI(5),'userdata')				% update dPial
		try
			tmp = eval(get(UI(5),'string'));
			if isscalar(tmp) % && (tmp ~= dPial) % && (tmp>=0)
				dPial = tmp;
				if hemi2
					f = repmat(min(dPial./dL,1),1,3);
					VL = f.*VwhiteL + (1-f).*VpialL;
				end
				f = repmat(min(dPial./dR,1),1,3);
				VR = f.*VwhiteR + (1-f).*VpialR;
				update = 1;
			end
		catch
			set(UI(5),'string',dPial)
		end
	end	
	set([UIb,UI(1:5)],'userdata',false)
	if update==2
		for i = 1:nlayerL
			k = kL & gray.allLeftNodes(6,:)==layerL(i);
			set(H(2+i),'xdata',gray.allLeftNodes(3,k),'ydata',gray.allLeftNodes(1,k))
		end
		for i = 1:nlayerR
			k = kR & gray.allRightNodes(6,:)==layerR(i);
			set(H(2+nlayerL+i),'xdata',gray.allRightNodes(3,k),'ydata',gray.allRightNodes(1,k))
		end
		xL = [min(gray.allLeftNodes(3,kL)),max(gray.allRightNodes(3,kR))];
		yL = [min(gray.allLeftNodes(1,kL)),max(gray.allLeftNodes(1,kL))];
		xL = xL + 0.1*diff(xL)*[-1 1];
		yL = yL + 0.1*diff(yL)*[-1 1];
		set(gca,'xlim',xL,'ylim',yL)
	end
	if update~=0
		if hemi2
			k = VL(:,2)<(128+dz-slice(1)) & VL(:,2)>(128+dz-slice(2));
			set(H(1),'xdata',VL(k,3)+128,'ydata',128-VL(k,1))
		end
		k = VR(:,2)<(128+dz-slice(1)) & VR(:,2)>(128+dz-slice(2));
		set(H(2),'xdata',VR(k,3)+128,'ydata',128-VR(k,1))
	end
end

% lab = cell(1,2+nlayerL);
% lab{1} = 'left cortex';
% lab{2} = 'right cortex';
% for i = 1:nlayerL
% 	lab{i} = ['layer ',int2str(i)];
% end
% legend(H(1:(2+nlayerL)),lab,'location','southeast')

% combine hemispheres & save EMSE wireframe - ASR vertices
if ieNotDefined('wfrFile')
	[wfrFile,wfrPath] = uiputfile('*.wfr','EMSE wireframe (note: "_cortex" gets appended)');
	if isnumeric(wfrFile)
		% store this info just in case
		set(fig,'userdata',struct('subjid',FSsubjid,...
										'patchReduction',patchReduction,...
										'interpMethod',interpMode,...
										'fWhite2Pial',fWhite2Pial,...
										'dWhite',dWhite,...
										'dPial',dPial,...
										'vertices',[VL;VR],...
										'faces',[FpialL;FpialR+size(VL,1)]))
		disp('Wireframe not saved!')
		return
	end
else
	[wfrPath,wfrFile,wfrExt] = fileparts(wfrFile);
	wfrFile = [wfrFile,wfrExt];
end
p = struct('mesh',struct(	'path',wfrPath,...
									'file',wfrFile,...
									'data',struct(	'meshtype',{{'cortex'}},...
														'vertices',{{[ VL; VR ]}},...
														'faces',{{[ FpialL; FpialR+size(VL,1) ]}}	)	));
wfrFile = mesh_write_emse(p);		% now [wfrPath,wfrFile,'_cortex']


%-------------------------mrMesh-------------------------

if islogical(grayCoords)	% valid VOLUME window open
	disp('Now converting the mrMesh data');

	% In theory we should be able to just write this out straight to disk as a
	% .mat file since the p structure contains more or less all the important
	% stuff. However, we go through mrMesh for the convenience - and also so
	% that it can compute things like the surface normals for us.

	disp('Calling emseConvertEMSEMesh....');
	disp(wfrFile)

	[msh,lights,tenseMsh] = emseConvertEMSEMesh(wfrFile,[],'localhost'); %#ok<NASGU> % Only use this on any subjects with a  1x1x1 voxel size
	msh.surface = [surf1,'2',surf2];

	% Now write it out (prompting you for a filename)
	[msh,mrmeshFilePath] = mrmWriteMeshFile(msh);
else
	disp('mrMesh needs open gray view.  Mesh not generated.')
end
