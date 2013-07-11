function elp2png

[elpFile,elpPath] = uigetfile('*.elp','Pick a Polhemus elp-file');
if isnumeric(elpFile)
	return
end

% expecting REF electrode (name='400' or 'Cz', type='1C00') 1st, then 1-128 (name='#', type='400')
%           fiducials are [NZ;LA;RA]
[pos,name,type,fiducials] = readELPfile([elpPath,elpFile]);

% sort (put ref @ end)
[junk,k] = sort(cellfun(@eval,name));
pos  = pos(k,:);
% name = name(k);
% type = type(k);

	% transform ALS to RAS w/ LA on -X, RA on +X, & NZ on +Y axis
	r = hypot( fiducials(2,1), fiducials(2,2) );
	cosa = -fiducials(2,1) / r;		% -sin(a-pi/2)
	sina =  fiducials(2,2) / r;		%  cos(a-pi/2)
	pos = [pos(:,1)*cosa-pos(:,2)*sina-fiducials(1,1)*cosa, pos(:,1)*sina+pos(:,2)*cosa, pos(:,3) ];
% 	fiducials = [fiducials(:,1)*cosa-fiducials(:,2)*sina-fiducials(1,1)*cosa, fiducials(:,1)*sina+fiducials(:,2)*cosa, fiducials(:,3) ];

x = zeros(129,3);
x(:,1:2) = flattenZ(pos);
xMin = min(x(:,1:2));
xMax = max(x(:,1:2));

WH = 800;
fig = figure('units','pixels','position',[50 100 WH+[20 20]],'color','w','menubar','none');
ax = axes('units','pixels','position',[10 10 WH WH],'dataaspectratio',[1 1 1],'visible','off','xtick',[],'ytick',[],'ztick',[],...
			'xlim',xMin(1)+(xMax(1)-xMin(1))*[-0.05 1.05],'ylim',xMin(2)+(xMax(2)-xMin(2))*[-0.05 1.05]);
% if true
	patch('vertices',x,'faces',EGInetFaces(true),'facecolor','w','edgecolor',[0 0 0]+0.75,'linewidth',1)
% else
	c = [1 0.75 0];
	w = 2;
	k = 1:7;			line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 8:13;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 14:16;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 17:20;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 21:24;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 25:31;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 32:37;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 38:42;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 43:47;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 48:55;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 56:62;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 63:67;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 68:72;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 73:80;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 81:87;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 88:93;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 94:98;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 99:106;		line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 107:112;	line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 113:118;	line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 119:124;	line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 125:126;	line(x(k,1),x(k,2),'linewidth',w,'color',c)
	k = 127:128;	line(x(k,1),x(k,2),'linewidth',w,'color',c)
% end
T = zeros(1,128);
for i = 1:numel(T)
	T(i) = text(x(i,1),x(i,2),int2str(i));
end
set(T,'horizontalalignment','center','verticalalignment','middle',...
	'fontname','Arial','fontsize',12,'fontweight','bold','color',[0 0 0])

F = getframe(ax);
close(fig)

[pngPath,pngFile] = fileparts([elpPath,elpFile]);
imwrite(F.cdata,fullfile(pngPath,[pngFile,'.png']),'png')



