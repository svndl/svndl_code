function [] = pdPhasePlot(phasorData,noiseEst)
%function [] = pdPhasePlot(phasorData,noiseEst)

cax = gca;

colorList = {[0 0 1], [.2 .5 .2],  [1 0 0],[0.01 0.01 0.01],[.5 .2 .5] };

numColorsDefined = length(colorList);

numColors = length(phasorData);

colorVec = mod([1:numColors]-1,numColorsDefined)+1;

colorList = colorList(colorVec); 


if (noiseEst<0)
    warning('Noise estimate can not be negative, using abs(noiseEst)')
    noiseEst = abs(noiseEst);
end

for iDat = 1:length(phasorData),
    
    thisCol = colorList{iDat};

    lH = line([0 real(phasorData(iDat))],[0 imag(phasorData(iDat))],'color',thisCol);


%    [cH fH] = circle(real(phasorData(iDat)),imag(phasorData(iDat)),noiseEst(iDat),thisCol,thisCol);

%    set(fH,'facealpha',.25)
%    set(cH,'linewidth',2);
    set(lH,'linewidth',3);

    %patch( tXE, tYE, tColorOrderMat( iCmp, : ), 'facealpha', .25, 'edgecolor', tColorOrderMat( iCmp, : ), 'linewidth', 2 );

end


%maxComp = max(max(real(phasorData),imag(phasorData)));



axis equal;

%This finds how big the axis is.
maxComp = max(abs(axis));

rmax = maxComp*1.1;
rmax = ceil(10*rmax)/10;
rmin = 0;
rticks = 3;
tc = 'k';
ls = '--';
% define a circle
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
% % plot background if necessary
%     if ~ischar(get(cax,'color')),
%        patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
%              'edgecolor',tc,'facecolor',get(cax,'color'),...
%              'handlevisibility','off','parent',cax);
%     end

% draw radial circles
    c82 = cos(78*pi/180);
    s82 = sin(78*pi/180);
    rinc = (rmax-rmin)/rticks;
    for i=(rmin+rinc):rinc:rmax
        hhh = line(xunit*i,yunit*i,'linestyle',ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off','parent',cax);
        text((i+rinc/30)*c82,(i+rinc/30)*s82, ...
            ['  ' num2str(i,1)],'verticalalignment','bottom',...
            'handlevisibility','off','parent',cax)
    end
    set(hhh,'linestyle','-') % Make outer circle solid

% plot spokes
    th = [0 1.5 3 4.5]*pi/6;
    cst = cos(th); snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    line(rmax*cs,rmax*sn,'linestyle',ls,'color',tc,'linewidth',1,...
         'handlevisibility','off','parent',cax)

% annotate spokes in degrees
    rt = 1.1*rmax;
    for i = 1:length(th)
        if i == length(th)
            loc = int2str(0);
        else
            loc = int2str(180+i*30);
        end

        text(-rt*cst(i),-rt*snt(i),num2str(th(i)*180/pi +180),...
             'horizontalalignment','center',...
             'handlevisibility','off','parent',cax);

        loc = num2str(th(i)*180/pi);
        text(rt*cst(i),rt*snt(i),loc,'horizontalalignment','center',...
             'handlevisibility','off','parent',cax)
    end



%axH = line([-maxComp maxComp; 0 0]',[0 0; -maxComp maxComp]','color','k');

%set(axH,'linewidth',1);
for iDat = 1:length(phasorData),
    
    thisCol = colorList{iDat};

    lH = line([0 real(phasorData(iDat))],[0 imag(phasorData(iDat))],'color',thisCol);


%     [cH fH] = circle(real(phasorData(iDat)),imag(phasorData(iDat)),noiseEst(iDat),thisCol,thisCol);
% 
%     set(fH,'facealpha',.25)
%     set(cH,'linewidth',2);
    set(lH,'linewidth',2);

    %patch( tXE, tYE, tColorOrderMat( iCmp, : ), 'facealpha', .25, 'edgecolor', tColorOrderMat( iCmp, : ), 'linewidth', 2 );

end

axis tight
axis off
