function Fig = renderBrain(subjid,surf,hemi,xfmFlag)
% renderBrain(FS4subjid,surface,hemisphere)

switch nargin
case 3
	xfmFlag = true;
case 2
	hemi = '';
	xfmFlag = true;
case 1
	surf = 'pial';
	hemi = '';
	xfmFlag = true;
case 0
	help renderBrain
	error('not enough input arguments.')
end

if ~exist('read_surf','file')
	error('add freesurfer matlab toolbox to path')
% 	X:\toolbox\MGH\fs4\matlab
end
if ispc
	fsDir = fullfile('X:\anatomy\FREESURFER_SUBS',subjid);
else
	fsDir = fullfile('/raid/MRI/anatomy/FREESURFER_SUBS',subjid);
end

if xfmFlag
	XFM = xfm_read(fullfile(fsDir,'mri','transforms','talairach.xfm'))';
	scale = norm(XFM(1:3,1:3));
	x = XFM(1:3,1:3) / scale;			% unscaled transform w/o translations
	% rotation matrix
	R = @(r) [1 0 0;0 cos(r(1)) sin(r(1));0 -sin(r(1)) cos(r(1))] * [cos(r(2)) 0 sin(r(2));0 1 0;-sin(r(2)) 0 cos(r(2))] * [cos(r(3)) sin(r(3)) 0;-sin(r(3)) cos(r(3)) 0;0 0 1];
	% rotations that best approximate x
	r = fminsearch( @(r) norm(R(r)-x), zeros(3,1), optimset('tolx',1e-3*pi/180,'tolfun',1e-6,'display','final') );
	M = R(r);
end

fig = figure('color',[0 0 0]);

A = axes('dataaspectratio',[1 1 1],'view',[90 0],'visible','off',...
	'units','normalized','position',[0 0 1 1]);

L = [ light('position',[256 0 128]), light('position',[-256 0 128]) ];
% L = [...
% 	light('position',[-256  128  128],'color','y')...
% 	light('position',[ 256  128  128],'color','b')...
% 	light('position',[ 128 -256  128],'color','r')...
% 	light('position',[ 128  256  128],'color','c')...
% 	light('position',[ 128  128 -256],'color','m')...
% 	light('position',[ 128  128  256],'color','g')...
% 	];

Vmin =  256;
Vmax = -256;
P = [];
if ~any(strcmpi(hemi,{'R','RH','right'}))
	[V,F] = read_surf(fullfile(fsDir,'surf',['lh.',surf]));
	if xfmFlag
		V = V*M;
	end
	Vmin = min(Vmin,min(V));
	Vmax = max(Vmax,max(V));
	P = [P, patch('vertices',V,'faces',F(:,[3 2 1])+1) ];
end
if ~any(strcmpi(hemi,{'L','LH','left'}))
	[V,F] = read_surf(fullfile(fsDir,'surf',['rh.',surf]));
	if xfmFlag
		V = V*M;
	end
	Vmin = min(Vmin,min(V));
	Vmax = max(Vmax,max(V));
	P = [P, patch('vertices',V,'faces',F(:,[3 2 1])+1) ];
end

set(A,'xlim',[Vmin(1),Vmax(1)]+[-0.05 0.05]*(Vmax(2)-Vmin(2)),...
		'ylim',[Vmin(2),Vmax(2)]+[-0.05 0.05]*(Vmax(2)-Vmin(2)),...
		'zlim',[Vmin(3),Vmax(3)]+[-0.05 0.05]*(Vmax(2)-Vmin(2))	)
	
% set(P,'facecolor',[1 0.8 0.5],...
% 	'ambientstrength',0.3,...
% 	'diffusestrength',0.4,...
% 	'specularcolorreflectance',1,...
% 	'specularexponent',4,...
% 	'specularstrength',0.8,...
% 	'facealpha',1,...
% 	'edgecolor','none',...
% 	'facelighting','gouraud',...
% 	'edgelighting','none',...
% 	'backfacelighting','unlit')

set(P,'facecolor',[0.9 0.7 0.5],'ambientStrength',0.1,'diffuseStrength',0.8,'specularColorReflectance',0.5,'specularExponent',10,'specularStrength',0.15,...
	'facealpha',1,'edgecolor','none','facelighting','gouraud','edgelighting','none','backfacelighting','unlit')


% set(L,'color',[1 1 0.4])
set(L,'color',[1 1 1])
set(L,'style','infinite')

if nargout
	Fig = fig;
end

return

%% e.g.
% for subjNum = [1 3 4 5 8 9 17 35:39 44 47:69 71:84 87 93:105 108:110 112 116 121 122 125 127:131 133:145 147:148 151]
jpgDir = fullfile(SKERIanatDir,'jpegs');
for subjNum = [148 151]
	subjid = sprintf('skeri%04d',subjNum);
	H = renderBrain([subjid,'_fs4'],'pial','RH',true);
	
	set(H,'position',[200 300 900 600])
	F = getframe(H);
	fname = fullfile(jpgDir,'RHlateral',[subjid,'_RHlateral.jpg']);
	fprintf('writing %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)

	set(findobj(H,'type','axes'),'view',[-90 0])
	F = getframe(H);
	fname = fullfile(jpgDir,'RHmedial',[subjid,'_RHmedial.jpg']);
	fprintf('\nwriting %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)
	
	fprintf('\ndone\n')
	close(H)
end


