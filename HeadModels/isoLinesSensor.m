% function checkELPfile(elpFile)
% checkELPfile(elpFile)
clear

elpFile = 'Y:\data\4D2\MocoDgls_Attn\ready2go\skeri0001\Polhemus\AW_MOCOandGLASS_113006.elp';
data = load('Y:\projects\nicholas\mrCurrent\MNEstyle\skeri0048\Exp_MATL_HCN_128_Avg\Axx_c003.mat');
emap = data.Wave(89,:)';		% 89,299
emin = min(emap);
emax = max(emap);
nv = 8;								% # contour values

nE = 128;
useRef = false;

[p,name,type,fiducials] = readELPfile(elpFile);
n = nE + useRef;

% just in case not in order?
k = zeros(1,n);
for i = 1:nE
	k(i) = find(strcmp(name,int2str(i)));
end
if useRef
	k(n) = find(strcmp(name,'400'));	% type = 1c00 or 1C00
end
p = [-p(k,2),p(k,[1 3])]*1e3;		% convert to RAS (mm)
fiducials = [-fiducials(:,2),fiducials(:,[1 3])]*1e3;

% new origin
o = sphereFit(p);
p = p - repmat(o,n,1);
fiducials = fiducials - repmat(o,size(fiducials,1),1);

% spherical coords
[theta,phi,radius] = cart2sph(p(:,1),p(:,2),p(:,3));

% flat transform
qFlat = 0.6;
[xFlat,yFlat] = pol2cart(theta,(1-sin(phi)).^qFlat);

xyGrid = -1.5:0.01:1.5;
[Xgrid,Ygrid] = meshgrid(xyGrid);
Zgrid = griddata(xFlat,yFlat,emap,Xgrid,Ygrid,'cubic');						% linear,cubic,nearest,v4
% Zgrid(hypot(Xgrid,Ygrid)>max(hypot(xFlat,yFlat))) = NaN;

dv = (emax-emin)/(nv+1);
C = contourc(xyGrid,xyGrid,Zgrid,linspace(emin+dv,emax-dv,nv));
% C = contourc(xyGrid,xyGrid,Zgrid,emin+[0.1 0.2 0.8 0.9]*(emax-emin));

cmap = [ 1 1 1; jet(255) ];	% 1st row for NaNs in Zgrid

thetaInterp = linspace(-pi,pi,30);
phiInterp   = linspace(-pi/2,pi/2,20);
[ThetaGrid,PhiGrid] = meshgrid(thetaInterp,phiInterp);
RadiusGrid = griddata(theta,phi,radius,ThetaGrid,PhiGrid,'v4');

indexFcn = @(x) round(254/(emax-emin)*(x-emin))+2;

c2D = struct('x',[],'y',[]);
c3D = struct('x',[],'y',[],'z',[],'color',[]);
k = 0;
nc = 0;		% # contour lines
while k < size(C,2)
	k = k + 1;
	nc = nc + 1;
	c2D(nc).x = C(1,(k+1):(k+C(2,k)));
	c2D(nc).y = C(2,(k+1):(k+C(2,k)));
	c3D(nc).color = cmap(indexFcn(C(1,k)),:);
	k = k + C(2,k);

	cPhi   = asin(1-hypot(c2D(nc).x,c2D(nc).y).^(1/qFlat));
	cTheta = atan2(c2D(nc).y,c2D(nc).x);
	cRad   = interp2(ThetaGrid,PhiGrid,RadiusGrid,cTheta,cPhi,'cubic');		% nearest,linear,spline,cubic
	[ c3D(nc).x, c3D(nc).y, c3D(nc).z ] = sph2cart(cTheta,cPhi,cRad);
end


clf
% colormap(cmap)
subplot(121)
% 	image(xyGrid,xyGrid,indexFcn(Zgrid))
	a = linspace(0,2*pi,100);
	line(cos(a),sin(a),'color','k')
	set(gca,'ydir','normal','dataaspectratio',[1 1 1])
	for k = 1:nc
		line(c2D(k).x,c2D(k).y,'color',c3D(k).color,'linewidth',2) %'m')
	end
	line(xFlat,yFlat,'linestyle','none','color','k','marker','o')
subplot(122)
% 	plot3(p(:,1),p(:,2),p(:,3),'.k')
	for k = 1:nc
		line(c3D(k).x,c3D(k).y,c3D(k).z,'color',c3D(k).color,'linewidth',2)
	end
	set(gca,'dataaspectratio',[1 1 1],'view',[60 30])

disp('--done--')

