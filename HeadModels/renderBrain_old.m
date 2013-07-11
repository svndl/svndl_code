function Fig = renderBrain(subjid,surf,hemi)
% renderBrain(FS4subjid,surface,hemisphere)

switch nargin
case 2
	hemi = '';
case 1
	surf = 'pial';
	hemi = '';
case 0
	help renderBrain
	error('not enough input arguments.')
end

if ~exist('read_surf','file')
	error('add freesurfer matlab toolbox to path')
% 	Z:\toolbox\MGH\fs4\matlab
end
if ispc
	fsDir = fullfile('Z:\anatomy\FREESURFER_SUBS',subjid,'surf');
else
	fsDir = fullfile('/raid/MRI/anatomy/FREESURFER_SUBS',subjid,'surf');
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
	[V,F] = read_surf(fullfile(fsDir,['lh.',surf]));
	Vmin = min(Vmin,min(V));
	Vmax = max(Vmax,max(V));
	P = [P, patch('vertices',V,'faces',F(:,[3 2 1])+1) ];
end
if ~any(strcmpi(hemi,{'L','LH','left'}))
	[V,F] = read_surf(fullfile(fsDir,['rh.',surf]));
	Vmin = min(Vmin,min(V));
	Vmax = max(Vmax,max(V));
	P = [P, patch('vertices',V,'faces',F(:,[3 2 1])+1) ];
end

set(A,'xlim',[Vmin(1),Vmax(1)]+[-0.05 0.05]*(Vmax(2)-Vmin(2)),...
		'ylim',[Vmin(2),Vmax(2)]+[-0.05 0.05]*(Vmax(2)-Vmin(2)),...
		'zlim',[Vmin(3),Vmax(3)]+[-0.05 0.05]*(Vmax(2)-Vmin(2))	)
	
set(P,'facecolor',[1 0.8 0.5],...
	'ambientstrength',0.3,...
	'diffusestrength',0.4,...
	'specularcolorreflectance',1,...
	'specularexponent',4,...
	'specularstrength',0.8,...
	'facealpha',1,...
	'edgecolor','none',...
	'facelighting','gouraud',...
	'edgelighting','none',...
	'backfacelighting','unlit')

set(L,'color',[1 1 0.4])
set(L,'style','infinite')

if nargout
	Fig = fig;
end

return

%% e.g.
% for subjNum = [1 3 4 5 8 9 17 35:39 44 47:69 71:84 87 93]
for subjNum = 94:96
	subjid = sprintf('skeri%04d',subjNum);
	H = renderBrain([subjid,'_fs4'],'pial','RH');
	set(H,'position',[200 300 900 600])
	F = getframe(H);
% 	fname = fullfile('Z:\anatomy',subjid,[subjid,'_RH.jpg']);
	fname = fullfile('Z:\anatomy\jpegs',[subjid,'_RH.jpg']);
	fprintf('writing %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)
	fprintf('done\n')
	close(H)
end


