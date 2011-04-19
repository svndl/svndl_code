function [] = interactiveCortexWavePlot(data,sol,subjId,timeIndices)
%function [] = interactiveCortexWavePlot(data,sol,subjId,timeIndices)
%
% helpful help here
%


%Do some sanity checks here
%if wrong
%dosomething
%end
if nargin <2
    error('Must include data and inverse')
end

if nargin <4
    subjId = 'mni0001';
end


if nargin <4
    x = 1:size(data,1);
else
    x = timeIndices;
end

invData = sol*data';


iVert = 1;
iT = 1;
cortexAx = subplot(10,1,1:8);
set(gcf,'KeyPressFcn',@keyInput)

%topoH = plotOnEgi(squeeze(data(1,:)));

 
ctxH = drawAnatomySurface(subjId,'cortex','facealpha',1);
    
set(ctxH,'facevertexCdata',invData(:,iT),'facecolor','interp')
%set(ctxH,'facecolor',[.5 .5 .5])
 
axis off;
hold on;
ctxVerts = get(ctxH,'Vertices');

markH = plot3(ctxVerts(iVert,1),ctxVerts(iVert,2),ctxVerts(iVert,3),'ko','markersize',10,'linewidth',2);

%sigFreqs = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
waveAx = subplot(10,1,9:10);
timeLine = [];
selectedLineH = [];
drawWave();

[axLim] = axis(waveAx);
yLo = axLim(3);
yHi = axLim(4);

set(ctxH,'ButtonDownFcn',@clickedCtx)
set(cortexAx,'ButtonDownFcn',@clickedCtx)


%set(cortexAx,'ButtonDownFcn',@specUpdate)

    function drawWave()

        %cla(waveAx)
     
        axes(waveAx)
%        butterflyH = plot(waveAx,x,data,'-','color',[.5 .5 .5]);
        delete(selectedLineH);
        selectedLineH = plot(waveAx,x,invData(iVert,:),'k','linewidth',2);  
 
        [axLim] = axis(waveAx);
        yLo = axLim(3);
        yHi = axLim(4);
%        delete(timeLine);
 %       timeLine = line([x(iT) x(iT)],[yLo yHi],'linewidth',2,'buttondownFcn',@clickedWave);
        
        %Set up the function to call when the plots are clicked on
        set(waveAx,'ButtonDownFcn',@clickedWave)
        set(selectedLineH,'ButtonDownFcn',@clickedWave)
        
        
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

            set(ctxH,'facevertexCdata',invData(:,iT))
          %  caxis(cortexAx,[-max(abs(invData(:,iT))) max(abs(invData(:,iT)))])

            
            set(timeLine,'XData',[x(iT) x(iT)],'YData',[yLo yHi])
            title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
            
        else
            disp('clicked out of bounds')
        end
    end

    function clickedCtx(varargin)
        
%         tCurPoint = get(cortexAx,'CurrentPoint')
%         
%         vertexVectors = bsxfun(@minus,tCurPoint(1,:),ctxVerts);
% 
%         for i=1:length(ctxVerts),
%             
%             vertexVectors(i,:) = vertexVectors(i,:)./norm(vertexVectors(i,:));
%         end
%         
%         
%         backVector = tCurPoint(1,:)-tCurPoint(2,:);
%         backVector = backVector./norm(backVector);
%         backVector = repmat(backVector,size(ctxVerts,1),1);
%                
%         clickAngle = 1-dot(vertexVectors',backVector');    
%         
%    
% %        dist = dot(ctxVerts',backVector');
%         
%         dist = bsxfun(@minus,tCurPoint(1,:),ctxVerts);
%         dist = sqrt(sum(dist.^2,2));
%         min(clickAngle)
%         dist(clickAngle>min(clickAngle)*100) = inf;
%         
%         %Get the index to the nearest clicked electrode
%         [distance iV] = min(dist);
%         
%         
%         clickAngle(iV)
%         %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        [p v vi] = select3d;
        iV = vi;
        if iV>=1 && iV<=size(ctxVerts,1),
            
            iVert = iV;
            delete(markH);
            markH = plot3(ctxVerts(iVert,1),ctxVerts(iVert,2),ctxVerts(iVert,3),'ko','markersize',10,'linewidth',2);
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
        
        set(ctxH,'facevertexCData',invData(:,iT))
        caxis(cortexAx,[-max(abs(invData(:,iT))) max(abs(invData(:,iT)))])
        
        set(timeLine,'XData',[x(iT) x(iT)],'YData',[yLo yHi])
        title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
        
    end

        
end
