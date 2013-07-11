function kOut = upsampleMeshROIs(subjid,hemi,ROIname,forcePlot)
% upsample mrCurrent mesh ROIs to full freesurfer meshes.
%
% this is working reasonably well, but what about starting from 
% Gray ROIs instead of decimated mesh ROIs? -> see GrayROIs2FSmesh.m
%
% USAGE:     kFS = upsampleMeshROIs(subjid,hemi,ROIname)
%
% where:     subjid = SKERI subject ID string, no '_fs4' tail
%              hemi = 'lh' or 'rh'
%           ROIname = base ROI name, hemisphere is implied by hemi argument
%               kFS = indices of ROI in Freesurfer surfaces (logical column vector)
% e.g.
% k = upsampleMeshROIs('skeri0100','rh','V2V')

% To do:
% why am i getting decimation from ismember instead of loading it from src.fif?


msgstring = nargchk(3,4,nargin,'string');
if ~isempty(msgstring)
	help(mfilename)
	error(msgstring)
end
if nargin<4
	forcePlot = false;
end

if ispref('mrCurrent','AnatomyFolder')
	anatDir = getpref('mrCurrent','AnatomyFolder');
elseif ispref('VISTA','defaultAnatomyPath')
	anatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),'anatomy');
elseif ispc
	anatDir = 'X:\anatomy';
elseif isunix
	anatDir = '/raid/MRI/anatomy';
else
	error('mac')
end

%% load freesurfer surfaces
% white for mapping default cortex
filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'),'surf',strcat(hemi,'.white'));
Vw = freesurfer_read_surf(filename);
Vw = [ -Vw(:,2:3), Vw(:,1) ] + 128;
% sphere for interpolating
filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'),'surf',strcat(hemi,'.sphere'));
V = freesurfer_read_surf(filename);


%% load mrCurrent mesh
filename = fullfile(anatDir,subjid,'Standard','meshes','defaultCortex.mat');
Sm = load(filename);
% indices of decimated mesh vertices in full mesh
if strcmp(hemi,'lh')
	kDec = find( ismember(Vw,Sm.msh.initVertices(:,1:Sm.msh.nVertexLR(1))','rows') );
else
	kDec = find( ismember(Vw,Sm.msh.initVertices(:,(Sm.msh.nVertexLR(1)+1):sum(Sm.msh.nVertexLR))','rows') );
end


%% load mesh ROI
ROIfile = strcat(ROIname,'-',upper(hemi(1)),'.mat');
filename = fullfile(anatDir,subjid,'Standard','meshes','ROIs',ROIfile);
Sr = load(filename);
if strcmp(hemi,'rh')
	Sr.ROI.meshIndices = Sr.ROI.meshIndices - Sm.msh.nVertexLR(1);
end
% indices of decimated ROI vertices in full mesh
kROI = kDec(Sr.ROI.meshIndices);

%% interpolate ROI membership over relevant patch in spherical coords
[th,ph] = cart2sph(-V(:,2),V(:,1),V(:,3));	% th=ph=0 @ posterior pole (sphere)
d = 2*pi/180;			% angle padding (rad)
thMin = floor(min(th(kROI))*180/pi) * pi/180 - d;
thMax =  ceil(max(th(kROI))*180/pi) * pi/180 + d;
phMin = floor(min(ph(kROI))*180/pi) * pi/180 - d;
phMax =  ceil(max(ph(kROI))*180/pi) * pi/180 + d;
nTh = 1e2;
nPh = 1e2;
[TH,PH] = meshgrid(linspace(thMin,thMax,nTh),linspace(phMin,phMax,nPh));
method = 'v4';			% [linear],cubic,nearest,v4
M = griddata([th(kROI);thMin;thMin;thMax;thMax],[ph(kROI);phMin;phMax;phMin;phMax],[ones(numel(kROI),1);zeros(4,1)],TH,PH,method);
Mthresh = 0.995;		% logical conversion
kFS = interp2(TH,PH,M,th,ph,'linear',NaN) > Mthresh;	% logical index, unlike kDec & kROI

noOutput = nargout==0;
if ~noOutput
	kOut = kFS;
end
if ~(forcePlot || noOutput)
	return
end

% now get whatever surface you want for viewing
surf = 'pial';
filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'),'surf',strcat(hemi,'.',surf));
[V,F] = freesurfer_read_surf(filename);

% plot
ax = zeros(1,2);
clf
colormap([0 0 0;jet(255)])
ax(1) = subplot(121);
P = patch('Vertices',V,'Faces',F,'FaceColor','w','FaceAlpha',1,'EdgeColor',[0 0 0]+0.75);
if false		% dot vertices
	line(V(kFS,1),V(kFS,2),V(kFS,3),'LineStyle','none','Marker','.','Color','b')
else			% color faces
	C = ones(size(V));
	C(kFS,:) = repmat([0 1 1],sum(kFS),1);
	set(P,'FaceVertexCData',C,'FaceColor','interp')
end
line(V(kROI,1),V(kROI,2),V(kROI,3),'LineStyle','none','Marker','.','Color','r')
set(ax(1),'DataAspectRatio',[1 1 1],'View',[0 0])
title(sprintf('%s, %s-%s',subjid,ROIname,upper(hemi(1))))

ax(2) = subplot(122);
imagesc(TH(1,:)*180/pi,PH(:,1)*180/pi,M)
line(th(kFS)*180/pi,ph(kFS)*180/pi,'LineStyle','none','Marker','.','Color','k')
line(th(kROI)*180/pi,ph(kROI)*180/pi,'LineStyle','none','Marker','.','Color','m')
line([thMin;thMin;thMax;thMax]*180/pi,[phMin;phMax;phMin;phMax]*180/pi,'LineStyle','none','Marker','o','Color','w')
colorbar

if ~true		% zoom in
	Vmin = min(V(kFS,:));
	Vmax = max(V(kFS,:));
	d = max(Vmax-Vmin)*0.1 * [-1 1];		% axis padding
	set(ax(1),'View',[mean(th(kFS)),mean(ph(kFS))]*180/pi)
	set(ax(1),'XLim',[Vmin(1),Vmax(1)]+d,'ylim',[Vmin(2),Vmax(2)]+d,'zlim',[Vmin(3),Vmax(3)]+d)
else
	set(ax(1),'View',[0 0])
end

return

