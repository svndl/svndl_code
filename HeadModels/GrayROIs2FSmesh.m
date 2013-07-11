function [kOut,color] = GrayROIs2FSmesh(subjid,hemi,ROIname,forcePlot)
% Convert mrVista Gray ROI to Freesurfer mesh indices.
%
% USAGE:     kFS = GrayROIs2FSmesh(subjid,hemi,ROIname)
%
% where:     subjid = SKERI subject ID string, no '_fs4' tail
%              hemi = 'lh' or 'rh'
%           ROIname = base ROI name, hemisphere is implied by hemi argument
%               kFS = indices of ROI in Freesurfer surfaces (logical column vector)
% e.g.
% k = GrayROIs2FSmesh('skeri0100','rh','V2V')

msgstring = nargchk(3,4,nargin,'string');
if ~isempty(msgstring)
	help(mfilename)
	error(msgstring)
end
if nargin<4
	forcePlot = false;
end

anatDir = SKERIanatDir;


filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'),'surf',strcat(hemi,'.midgray'));
V = freesurfer_read_surf(filename);

% Vistasoft has IPR coords, PIR nodes
ROIfile = strcat(ROIname,'-',upper(hemi(1)),'.mat');
filename = fullfile(anatDir,subjid,'Standard','Gray','ROIs',ROIfile);
Sr = load(filename);
Sr.ROI.coords = [ Sr.ROI.coords(3,:)-128; 128-Sr.ROI.coords([2 1],:) ];		% RAS
color = Sr.ROI.color;

d2thresh = gaminv(0.75,6,0.175)^2;		% pial edge spacing distribution on a small # of test subjects roughly = gampdf(x,6,0.175)
[kNear,d2] = nearpoints(V',double(Sr.ROI.coords));
kFS = d2 <= d2thresh;

fprintf('\n%d Freesurfer vertices in Gray ROI %s\n\n',sum(kFS),ROIfile)

noOutput = nargout==0;
if ~noOutput
	kOut = kFS(:);
end
if ~(forcePlot || noOutput)
	return
end

filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'),'surf',strcat(hemi,'.inflated'));
[V,F] = freesurfer_read_surf(filename);

C = ones(size(V));
C(kFS,:) = repmat([1 0 1],sum(kFS),1);

clf
P = patch('Vertices',V,'Faces',F,'FaceVertexCData',C,'FaceColor','interp');	%,'FaceColor','w','FaceAlpha',0.85);
set(gca,'DataAspectRatio',[1 1 1],'View',[0 0])
title(sprintf('%s, %s-%s',subjid,ROIname,upper(hemi(1))))

% zoom in
if true
	[th,ph] = cart2sph(-V(kFS,2),V(kFS,1),V(kFS,3));
	Vmin = min(V(kFS,:));
	Vmax = max(V(kFS,:));
	d = max(Vmax-Vmin)*0.1 * [-1 1];		% axis padding
	set(gca,'View',[mean(th),mean(ph)]*180/pi)
	set(gca,'XLim',[Vmin(1),Vmax(1)]+d,'ylim',[Vmin(2),Vmax(2)]+d,'zlim',[Vmin(3),Vmax(3)]+d)
end

return		% ======================================================================================


%% plot all ROIs
clear
subj = 'skeri0112';
hemi = 'lh';
ROIs = {'V1','V2D','V2V','V3D','V3V','MT','LOC'};

anatDir = 'X:\anatomy';
% surf = 'inflated';
% surf = 'sphere';
surf = 'sphere.reg';
filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subj,'_fs4'),'surf',strcat(hemi,'.',surf));
[V,F] = freesurfer_read_surf(filename);

nV = size(V,1);
C = ones(nV,3);
ku = false(nV,1);
for iROI = numel(ROIs):-1:1
	[k,c] = GrayROIs2FSmesh(subj,hemi,ROIs{iROI});
% 	C(k,:) = repmat(color2rgb(c),sum(k),1);
	C(~ku & k,:) = repmat(color2rgb(c),sum(~ku & k),1);
	C( ku & k,:) = ( C(ku & k,:) + repmat(color2rgb(c),sum(ku & k),1) )/2;
	ku(k) = true;
end


S = read_curv(fullfile(anatDir,'FREESURFER_SUBS',strcat(subj,'_fs4'),'surf',strcat(hemi,'.sulc')));
% f = 0.9;		C = C .* repmat(   0.5 - f/2/max(abs(S)) * S, 1, 3 );
% f = 0.9;		C = C .* repmat( 1-f/2 - f/2/max(abs(S)) * S, 1, 3 );
f = 0.25;
% C = C .* repmat( (1-f)/2 + f./(1+exp(10/max(abs(S))*S)), 1, 3 );
C( ku,:) = C( ku,:) .* repmat(  1-f    + f./(1+exp(10/max(abs(S))*S( ku))), 1, 3 );
C(~ku,:) = C(~ku,:) .* repmat( (1-f)/2 + f./(1+exp(10/max(abs(S))*S(~ku))), 1, 3 );

clf
P = patch('Vertices',V,'Faces',F(:,[3 2 1]),'FaceVertexCData',C,'FaceColor','interp','EdgeColor','none',...
	'FaceLighting','gouraud','BackFaceLighting','unlit',...
	'AmbientStrength',0,'DiffuseStrength',0.9,'SpecularStrength',0.1,'SpecularExponent',20,'SpecularColorReflectance',1);
set(gca,'DataAspectRatio',[1 1 1],'View',[0 0])
title(subj)

light('Position',[-1000 -1000  1000],'Style','Infinite','Color',[1 1 1]);
light('Position',[ 1000 -1000 -1000],'Style','Infinite','Color',[1 1 1]);

%% swap surface
surf = 'inflated';
% surf = 'sphere';
surf = 'sphere.reg';
filename = fullfile(anatDir,'FREESURFER_SUBS',strcat(subj,'_fs4'),'surf',strcat(hemi,'.',surf));
V = freesurfer_read_surf(filename);
set(P,'Vertices',V)


%% change lights
delete(findobj(gca,'Type','light'))
% light('Position',[0 -1000 0],'Style','Infinite','Color',[1 1 1]);
light('Position',[-1000 -1000  1000],'Style','Infinite','Color',[1 1 1]);
light('Position',[ 1000 -1000 -1000],'Style','Infinite','Color',[1 1 1]);

