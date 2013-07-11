function [XFM,d] = regElp2Head(pos,BEM,xInit,Tmax)
% rigid rotation optimization for minimal variance of electrode to scalp distance
%
% XFM = optRegELP(pos,BEM,xInit,Tmax)
% pos = channelsx3 matrix of sensor locations [x;y;z]
% BEM  = Scalp structure from mne_read_bem_surfaces
% xInit = initial values of [ dx; dy; dz; Rx; Ry; Rz ]
% Tmax  = maximum translation
%
% requires vistasoft's nearpoints
% expecting position units in (m)



% get outward unit normals @ scalp vertices
fig = figure;
N = get(patch('vertices',BEM.rr,'faces',BEM.tris(:,[3 2 1])),'vertexnormals')';
close(fig)
N = N ./ repmat(sqrt(sum(N.^2)),3,1);

% transpose matrices for nearpoints
pos = [ pos'; ones(1,size(pos,1)) ];
BEM.rr = BEM.rr';

opts = optimset('Display','iter','TolX',min(1e-3*pi/180,1e-6),'TolFun',5e-6^2);		% MaxFunEvals
X = fmincon(@objFcn,xInit,[],[],[],[],-[Tmax Tmax Tmax pi pi pi],[Tmax Tmax Tmax pi pi pi],'',opts);
XFM = xfmFcn(X);

if nargout == 2
	xp = XFM*pos;
	k = nearpoints(xp,BEM.rr);
	d = dot( xp - BEM.rr(:,k), N(:,k) );
end

return

	function v = objFcn(x)
		xpos = xfmFcn(x)*pos;
		i = nearpoints(xpos,BEM.rr);
		v = var( dot( xpos - BEM.rr(:,i), N(:,i) ) );
	end

	function xfm = xfmFcn(x)
		% [ dx; dy; dz; Rx; Ry; Rz ] to 3x4 rigid transformation matrix
		c1 = cos(x(4));
		s1 = sin(x(4));
		c2 = cos(x(5));
		s2 = sin(x(5));
		c3 = cos(x(6));
		s3 = sin(x(6));
		xfm = [ c2*c3, -c2*s3, -s2, x(1); -s1*s2*c3+c1*s3,  s1*s2*s3+c1*c3, -s1*c2, x(2); c1*s2*c3+s1*s3, -c1*s2*s3+s1*c3,  c1*c2, x(3) ];
	end

end