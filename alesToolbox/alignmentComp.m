
% subj = 'skeri0001';
% elpFile = 'X:\data\4D2\MOCOattenNewNet\ready\skeri0001\Polhemus\ARWMOCOatten2082406.elp';
% 
% FSdir = 'X:\anatomy\FREESURFER_SUBS';
% alesBox = 'X:\toolbox\matlab_toolboxes\alesToolbox';
% speroBox = 'X:\toolbox\SperoToolbox\HeadModels';
% 

 subj = 'skeri0001';
% elpFile = '/Volumes/MRI/data/4D2/MOCOattenNewNet/ready/skeri0001/Polhemus/ARWMOCOatten2082406.elp';
elpFile = '/Volumes/MRI/data/4D2/LOC_localizer/test_reg/skeri0001/Polhemus/ARW_LOCloco_20080908_2.elp';
 FSdir = '/Volumes/MRI/anatomy/FREESURFER_SUBS';
% alesBox = 'X:\toolbox\matlab_toolboxes\alesToolbox';
% speroBox = 'X:\toolbox\SperoToolbox\HeadModels';
 
% ===============================================================

if ~exist('alignFiducials.m','file')
	addpath(alesBox,0)
end
if ~exist('regElp2Head.m','file')
	addpath(speroBox,0)
end



[pos,name,type,fiducials] = readELPfile(elpFile);


	% get rid of reference electrode (name = '400' or 'Cz' or 'REF'; type = '1C00' or '1c00')
	k = strcmp(type,'400');
	n = sum(k);
	fprintf('removing %d type~=''400'' electrode(s), %d remaining.\n',sum(~k),n)
	pos  = pos(k,:);
	name = name(k);
	type = type(k);
	% get rid of leading 'E'.  somewhere once i must've found one of these.
	if name{1}(1) == 'E'
		name = strrep(name,'E','');
	end
	% sort.  assuming sensor names are strings of the sensor #
	[junk,k] = sort(cellfun(@eval,name));
	pos  = pos(k,:);
	name = name(k);
	type = type(k);
	% transform ALS to RAS w/ LA on -X, RA on +X, & NZ on +Y axis
	% assuming fiducials are [NZ;LA;RA]
	r = hypot( fiducials(2,1), fiducials(2,2) );
	cosa = -fiducials(2,1) / r;		% -sin(a-pi/2)
	sina =  fiducials(2,2) / r;		%  cos(a-pi/2)
	pos(:,1:2)       = [      pos(:,1)*cosa -       pos(:,2)*sina - fiducials(1,1)*cosa,       pos(:,1)*sina +       pos(:,2)*cosa ];
	fiducials(:,1:2) = [fiducials(:,1)*cosa - fiducials(:,2)*sina - fiducials(1,1)*cosa, fiducials(:,1)*sina + fiducials(:,2)*cosa ];	
	
	
% FIDUCIAL ALIGNMENT --------------------------------------------
mri = load(fullfile(FSdir,[subj,'_fs4'],'bem',[subj,'_fiducials.txt'])) / 1000;
[trans,rot] = alignFiducials(fiducials([2 3 1],:),mri);
xfm1 = [rot, trans(:)];
	
% SENSOR ALIGNMENT ----------------------------------------------
head = mne_read_bem_surfaces(fullfile(FSdir,[subj,'_fs4'],'bem',[subj,'_fs4-head.fif']));		% high-res
% head = mne_read_bem_surfaces(fullfile(FSdir,[subj,'_fs4'],'bem',[subj,'_fs4-bem.fif']));		% low-res	
x = zeros(6,1);		% initial [ dx; dy; dz; rx; ry; rz]
if true	% start from zero rotation
	x(1:3) = ( median(head(1).rr) - median(pos) )';
else		% Use fiducial alignment as initial conditions
	x(1:3) = trans(:);
	x(5) = asin(-rot(1,3));						% rotation about AP-y axis
	x(6) = asin(-rot(1,2)/cos(a(5)));		% rotation about SI-z axis 
	x(4) = asin(-rot(2,3)/cos(a(5)));		% rotation about RL-x axis
end
xfm2 = regElp2Head(pos,head(1),x,0.15);
	
pos1 = ( xfm1 * [pos';ones(1,n)] )';
pos2 = ( xfm2 * [pos';ones(1,n)] )';

%% PLOT ---------------------------------------------------------
figure
set(gca,'view',[90 0],'dataaspectratio',[1 1 1])
L = light('position',[0 0 2],'color',[1 1 1],'style','infinite');
S = patch('vertices',head(1).rr,'faces',head(1).tris(:,[3 2 1]),'facecolor',[1 0.7 0.7],'edgecolor','none',...
	'facelighting','gouraud','backfacelighting','unlit','facealpha',0.85,...
	'ambientstrength',0.3,'diffusestrength',0.8,'specularstrength',0.3,'specularexponent',15,'specularcolorreflectance',0.5);
E = line(pos2(:,1),pos2(:,2),pos2(:,3),'linestyle','none','marker','.','color','b','markersize',20);

return

%% fiducial align
set(E,'xdata',pos1(:,1),'ydata',pos1(:,2),'zdata',pos1(:,3))

%% sensor align
set(E,'xdata',pos2(:,1),'ydata',pos2(:,2),'zdata',pos2(:,3))



