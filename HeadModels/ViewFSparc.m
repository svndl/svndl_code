%% high-res version for FS4 parcellations
% addpath('X:\toolbox\MGH\fs4\matlab',0)
FSdir = 'X:\anatomy\FREESURFER_SUBS\skeri0048_fs4';
hemi = 'lh';
surf = 'pial'
atlas = 'aparc';		% aparc or aparc.a2005s

% 	FSdir = 'X:\anatomy\FREESURFER_SUBS\skeri0103_fs4';
% 	hemi = 'rh';
% 	atlas = 'aparc.a2005s';

% [V,F] = freesurfer_read_surf(fullfile(FSdir,'surf',[hemi,'.',surf]));
[V,F] = read_surf(fullfile(FSdir,'surf',[hemi,'.',surf]));		F = F + 1;
[junk,label,colortable] = read_annotation(fullfile(FSdir,'label',[hemi,'.',atlas,'.annot']));

clf  % 900x675
H = brainPatch(V,F(:,[1 3 2]));
set(H,'AmbientStrength',0.3,'DiffuseStrength',0.8,'SpecularStrength',0.3)
switch hemi
case 'lh'
	set(gca,'view',[-90 0])
case 'rh'
	set(gca,'view',[ 90 0])
end
c = get(H,'facevertexcdata');

%% 
R = hypot(V(:,2),V(:,3));
Theta = atan2(V(:,3),V(:,2));

for i = 1:colortable.numEntries;
	k = label == colortable.table(i,5);
	if any(k)
%		c(:) = 0.75;
		c(k,:) = repmat(colortable.table(i,1:3)/255,sum(k),1);
%		set(H,'facevertexcdata',c)
%		title(strrep(colortable.struct_names{i},'_','\_'))
%		pause

		theta = atan2(mean(V(k,3)),mean(V(k,2)));
		dTheta = abs( Theta - theta );
		k = dTheta>pi;
		dTheta(k) = 2*pi - dTheta(k);
		r = 1.2 * max(R( dTheta < pi/12 ));
		text(0,r*cos(theta),r*sin(theta),colortable.struct_names{i},'horizontalalignment','center','verticalalignment','middle','color',colortable.table(i,1:3)/255,...
			'fontsize',10,'fontname','Arial','fontweight','bold','interpreter','none')
	end
end
	set(H,'facevertexcdata',c)
