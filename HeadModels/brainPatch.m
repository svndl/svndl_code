function H = brainPatch(V,F)
% Handle = brainPatch(Vertices,Faces)

[nV,cV] = size(V);
if cV~=3
	[nV,cV] = deal(cV,nV);
	if cV~=3
		error('vertex matrix must be Nx3 or 3xN')
	end
	disp('transposing vertices')
	V = V';
end
[nF,cF] = size(F);
if cF > nF
	disp('transposing faces')
	F = F';
end
if min(F(:))==0
	disp('adding 1 to faces')
	F = F + 1;
end
P = patch('vertices',V,'faces',F,'facevertexcdata',repmat([0.75 0.75 0.75],nV,1),'facecolor','interp','facelighting','gouraud','edgecolor','none',...
	'AmbientStrength',0.1,'DiffuseStrength',0.8,'SpecularStrength',0.15,'SpecularExponent',10,'SpecularColorReflectance',0.5);
xmin = min(V(:,1));
xmax = max(V(:,1));
dx = 2*(xmax-xmin);
myz = median(V(:,2:3));
light('position',[xmin-dx myz],'style','infinite')
light('position',[xmax+dx myz],'style','infinite')
set(gca,'view',[0 0],'dataaspectratio',[1 1 1])
xlabel('X'),ylabel('Y'),zlabel('Z')

if nargout
	H = P;
end
