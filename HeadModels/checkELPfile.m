function checkELPfile(elpFile)
% checkELPfile(elpFile)

if nargin == 0
	[elpFile,elpPath] = uigetfile('*.elp','Choose Polhemus elp-file');
	if isnumeric(elpFile)
		return
	end
	elpFile = [elpPath,elpFile];
end

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

if true
	% new origin
	o = sphereFit(p);
	p = p - repmat(o,n,1);
	fiducials = fiducials - repmat(o,size(fiducials,1),1);
	q = 0.6;
else
	q = 0.4;
end

[theta,phi,radius] = cart2sph(p(:,1),p(:,2),p(:,3));
[x,y]=pol2cart(theta,(1-sin(phi)).^q);

i = [17 15 16 11 6 55 62 72 75 81];		% midline electrodes
thetaNose = sum((theta(i)+pi*(theta(i)<0)).*radius(i))/sum(radius(i));

F = EGInetFaces(useRef);

axColor = repmat(2/3,1,3);
patchFaceColor = 'w';
patchEdgeColor = 'b';
patchMarkerSize = 20;
patchAlpha = 0.5;
anatColor = [0 0.75 0];
textColor = 'r';

ax = zeros(1,2);
P = zeros(1,2);
T = zeros(nE,2);
clf
ax(1) = axes('position',[0.1 0.15 0.4 0.8]);

	line(fiducials(:,1),fiducials(:,2),fiducials(:,3),'linestyle','none','marker','.','markersize',patchMarkerSize+10,'color',anatColor);

	P(1) = patch('vertices',p,'faces',F);

	N = get(P(1),'vertexnormals');
	N = - N ./ repmat(sqrt(sum(N.^2,2)),1,3);
	dT = 2;	% move text labels out so not obscured by patch
	for i = 1:nE
		if isnan(N(i,1))
			T(i,1) = text(p(i,1),p(i,2),p(i,3),int2str(i));
		else
			T(i,1) = text(p(i,1)+dT*N(i,1),p(i,2)+dT*N(i,2),p(i,3)+dT*N(i,3),int2str(i));
		end
	end
	
	grid
	xlabel('+Right')
	ylabel('+Anterior')
	zlabel('+Superior')
	[pathstr,filestr,ext] = fileparts(elpFile);
	title([strrep(filestr,'_','\_'),ext])

ax(2) =  axes('position',[0.55 0.15 0.4 0.8]);

	dthetaNose = 8*pi/180;
	drNose = 0.2;
	nHead = 100;
	aHead = [0,linspace(dthetaNose,2*pi-dthetaNose,nHead-2),0]+thetaNose;
	rHead = [1+drNose,ones(1,nHead-2),1+drNose];
% 	line(rHead.*cos(aHead),rHead.*sin(aHead),zeros(100,1),'color',anatColor,'linewidth',2)
	patch(rHead.*cos(aHead),rHead.*sin(aHead),zeros(100,1),anatColor.^0.25,'edgecolor',anatColor,'linewidth',1.5)
	
	P(2) = patch('vertices',[x y zeros(n,1)],'faces',F);
	
	for i = 1:1:nE
		T(i,2) = text(x(i),y(i),0,int2str(i));
	end

	set(ax(2),'xtick',[],'ytick',[])%,grid	
% 	set(ax(2),'view',[thetaNose*180/pi-90 90])
% 	xlabel('+Right')
% 	ylabel('+Anterior')
	
set(ax,'color',axColor,'dataaspectratio',[1 1 1],'view',[0 90])
set(P,'facecolor',patchFaceColor,'edgecolor',patchEdgeColor,'facealpha',patchAlpha,'marker','.','markersize',patchMarkerSize)
set(T,'fontsize',9,'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color',textColor,'visible','off')

uicontrol('units','normalized','position',[0.55 0.05 0.1 0.04],'style','text','string','alpha')
uicontrol('units','normalized','position',[0.65 0.05 0.3 0.04],'style','slider','min',0,'max',1,'sliderstep',[0.01 0.1],'value',patchAlpha,'callback',@setAlpha)

UI = uimenu('label','OPTIONS');
uimenu(UI,'label','labels','checked','off','callback',@toggleLabels)
Hview = [...
uimenu(UI,'label','top','callback',@changeView,'separator','on','checked','on')...
uimenu(UI,'label','bottom','callback',@changeView)...
uimenu(UI,'label','left','callback',@changeView)...
uimenu(UI,'label','right','callback',@changeView)...
uimenu(UI,'label','front','callback',@changeView)...
uimenu(UI,'label','back','callback',@changeView)];

return

	function toggleLabels(obj,varargin)
		if strcmp(get(T(1,1),'visible'),'on')
			set(T,'visible','off')
			set(obj,'checked','off')
		else
			set(T,'visible','on')
			set(obj,'checked','on')
		end
	end

	function changeView(obj,varargin)
		switch get(obj,'label')
		case 'left'
			set(ax(1),'view',[-90 0])
		case 'right'
			set(ax(1),'view',[90 0])
		case 'front'
			set(ax(1),'view',[180 0])
		case 'back'
			set(ax(1),'view',[0 0])
		case 'top'
			set(ax(1),'view',[0 90])
		case 'bottom'
			set(ax(1),'view',[0 -90])
		end
		set(Hview,'checked','off')
		set(obj,'checked','on')
	end

	function setAlpha(obj,varargin)
		set(P,'facealpha',get(obj,'value'))
	end

end

