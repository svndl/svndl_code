function [] = interactiveTopoWavePlot(data,timeIndices)
%function [] = interactiveTopoPlot(data,x)
%
% helpful help here
%


%Do some sanity checks here
%if wrong
%dosomething
%end
if nargin <2
    x = 1:size(data,1);
else
    x = timeIndices;
end



iElec = 75;
iT = 1;
clf;
topoAx = subplot(10,1,1:8);
set(gcf,'KeyPressFcn',@keyInput)
topoH = plotOnEgi(squeeze(data(1,:)));
axis off;
hold on;
elecVerts = get(topoH,'Vertices');
markH = plot(elecVerts(iElec,1),elecVerts(iElec,2),'ko','markersize',10,'linewidth',2);
elecNumH = text(-.05,1.35,num2str(iElec));


freqs = x;

%sigFreqs = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
waveAx = subplot(10,1,9:10);
timeLine = [];
butterflyH = [];
selectedLineH = [];
drawWave();

[axLim] = axis(waveAx);
yLo = axLim(3);
yHi = axLim(4);

set(topoH,'ButtonDownFcn',@clickedTopo)
set(topoAx,'ButtonDownFcn',@clickedTopo)


%set(topoAx,'ButtonDownFcn',@specUpdate)

    function drawWave()

        %cla(waveAx)
     
        axes(waveAx)
        butterflyH = plot(waveAx,x,data,'-','color',[.5 .5 .5]);
        hold on;       
        delete(selectedLineH);
        selectedLineH = plot(waveAx,x,data(:,iElec),'k','linewidth',2);  
 
        [axLim] = axis(waveAx);
        yLo = axLim(3);
        yHi = axLim(4);
        delete(timeLine);
        timeLine = line([x(iT) x(iT)],[yLo yHi],'linewidth',2,'buttondownFcn',@clickedWave);
        
        %Set up the function to call when the plots are clicked on
        set(waveAx,'ButtonDownFcn',@clickedWave)
       % set(selectedLineH,'ButtonDownFcn',@clickedWave)
        set(butterflyH,'ButtonDownFcn',@clickedWave)
        
        
    end


    function clickedWave(varargin)
        
       tCurPoint = get(waveAx,'CurrentPoint');
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        %Get the x location of the lick and find the nearest index
        [distance iT] = min(abs(x-tCurPoint(1,1)));
        
        [axLim] = axis(waveAx);
        yLo = axLim(3);
        yHi = axLim(4);
        
        axes(waveAx);
        if iT>=1 && iT<=x(end)

            set(topoH,'facevertexCData',data(iT,:)')
 %           caxis(topoAx,[-max(abs(data(iT,:))) max(abs(data(iT,:)))])
            
            caxis(topoAx,[-max(abs(data(:))) max(abs(data(:)))])
            
            set(timeLine,'XData',[x(iT) x(iT)],'YData',[yLo yHi])
            title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
            
        else
            disp('clicked out of bounds')
        end
    end

    function clickedTopo(varargin)
        
        tCurPoint = get(topoAx,'CurrentPoint');
        
        dist = bsxfun(@minus,tCurPoint(1,:),elecVerts);
        
        dist = sqrt(sum(dist.^2,2));
        
        %Get the index to the nearest clicked electrode
        [distance iE] = min(dist);
        
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        if iE>=1 && iE<=size(elecVerts,1),
            
            iElec = iE;
            delete(markH);
            markH = plot(elecVerts(iElec,1),elecVerts(iElec,2),'ko','markersize',10,'linewidth',2);
            set(elecNumH,'String',num2str(iElec));
            drawWave();

            
        end
        
    end

    function keyInput(src,evnt)
        
        switch(lower(evnt.Key))
            case 'leftarrow'
                iT = max(iT-1,1);
            case 'rightarrow'
                iT = min(iT+1,length(x));
                
                
        end
        
        set(topoH,'facevertexCData',data(iT,:)')
        caxis(topoAx,[-max(abs(data(iT,:))) max(abs(data(iT,:)))])
        
        set(timeLine,'XData',[x(iT) x(iT)],'YData',[yLo yHi])
        title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
        
    end

        
end
