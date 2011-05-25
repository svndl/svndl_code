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
rotate3d off
set(gcf,'KeyPressFcn',@keyInput)
set(gcf,'toolbar','figure')

%topoH = plotOnEgi(squeeze(data(1,:)));

 
ctxH = drawAnatomySurface(subjId,'cortex','facealpha',1);
    
set(ctxH,'facevertexCdata',invData(:,iT),'facecolor','interp')
%set(ctxH,'facecolor',[.5 .5 .5])

if any(invData(:)<0)
    caxis(cortexAx,[-max(abs(invData(:))) max(abs(invData(:)))])
   colormap(jmaColors('coolHotCortex'))
else
    caxis(cortexAx,[0 max(abs(invData(:)))])
    colormap(jmaColors('hotCortex'))
end

axis off;
hold on;
colorbar('peer',cortexAx)

foldedVertices = get(ctxH,'Vertices');
try 
    inflatedCtx = readInflatedCortex(subjId);
    inflatedVertices  = inflatedCtx.vertices;
catch
    warning(['Cannot find inflated cortex for subject: ' subjId]);
end

ctxVerts = foldedVertices;

markH = plot3(ctxVerts(iVert,1),ctxVerts(iVert,2),ctxVerts(iVert,3),'ko','markersize',10,'linewidth',2);

%sigFreqs = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
waveAx = subplot(10,1,9:10);
timeLine1 = [];
timeLine2 = [];

selectedLineH = [];
windowSize = 0

drawWave();
% 
[axLim] = axis(waveAx);
yLo = axLim(3);
yHi = axLim(4);

set(ctxH,'ButtonDownFcn',@clickedCtx)
set(cortexAx,'ButtonDownFcn',@clickedCtx)

inflateButH = uicontrol('style','togglebutton','string','folded','units','normalized','position',[0 .9 .1 .05], ...
    'Callback',@toggleInflation );


averageingWindowInputH = uicontrol('style','edit','string','0','units','normalized','position',[0 .8 .1 .05], ...
    'Callback',@setAveragingWindowSize );

%set(cortexAx,'ButtonDownFcn',@specUpdate)

    function drawWave()

        %cla(waveAx)
     
 %       axes(waveAx)
%        butterflyH = plot(waveAx,x,data,'-','color',[.5 .5 .5]);
%        delete(selectedLineH);
        selectedLineH = plot(waveAx,x,invData(iVert,:),'k','linewidth',2);  
 
        [axLim] = axis(waveAx);
      
        yLo = axLim(3);
        yHi = axLim(4);
        
        if ishandle(timeLine1)
         delete(timeLine1);
        end
        
        if ishandle(timeLine2)
         delete(timeLine2);
        end

        timeLine1 = line([x(iT) x(iT)],[yLo yHi], ...
            'linestyle','-.','color','k','linewidth',2,'parent',waveAx,'buttondownFcn',@clickedWave);
        timeLine2 = line([x(iT-windowSize) x(iT-windowSize)],[yLo yHi], ...
            'linestyle','-.','color','k','linewidth',2,'parent',waveAx,'buttondownFcn',@clickedWave);
      
        %Set up the function to call when the plots are clicked on
        set(waveAx,'ButtonDownFcn',@clickedWave)
        set(selectedLineH,'ButtonDownFcn',@clickedWave)
        %axes(cortexAx)
        title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
    end


    function clickedWave(varargin)
        
       tCurPoint = get(waveAx,'CurrentPoint');
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        %Get the x location of the lick and find the nearest index
        [distance iT] = min(abs(x-tCurPoint(1,1)));
        
        [axLim] = axis(waveAx);
        yLo = axLim(3);
        yHi = axLim(4);
        
    %    axes(waveAx);
        if iT>=1 && iT<=x(end)

            window = (iT-windowSize):iT;
            meanAct = mean(invData(:,window),2);
            set(ctxH,'facevertexCdata',meanAct)
            
          %  caxis(cortexAx,[-max(abs(invData(:,iT))) max(abs(invData(:,iT)))])
          
          set(timeLine1,'XData',[x(iT) x(iT)]','YData',[yLo yHi]')
          set(timeLine2,'XData',[x(iT-windowSize) x(iT-windowSize)]','YData',[yLo yHi]')
            
            title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
            
        else
            disp('clicked out of bounds')
        end
     %   axes(cortexAx)
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
       % axes(cortexAx)
        
    end

    function keyInput(src,evnt)
        
        switch(lower(evnt.Key))
            case 'leftarrow'
                iT = max(iT-1,1);
            case 'rightarrow'
                iT = min(iT+1,length(x));
                
                
        end
        
        set(ctxH,'facevertexCData',invData(:,iT))
       % caxis(cortexAx,[-max(abs(invData(:,iT))) max(abs(invData(:,iT)))])
        
        set(timeLine1,'XData',[x(iT) x(iT) ],'YData',[yLo yHi]);
        
        set(timeLine2,'XData',[x(iT-windowSize) x(iT-windowSize)],'YData',[yLo yHi]);
        
        title(waveAx,['Time: ' num2str(x(iT),4) ' ms'])
        %axes(cortexAx)
    end

    function toggleInflation(hObject,varargin)
        button_state = get(hObject,'Value');
        
        if button_state == get(hObject,'Max')
            % Toggle button is pressed, take appropriate action
            set(ctxH,'Vertices',inflatedVertices);
            ctxVerts = inflatedVertices;
            set(hObject,'string','inflated')
  
        elseif button_state == get(hObject,'Min')
        % Toggle button is not pressed, take appropriate action
            set(ctxH,'Vertices',foldedVertices);
            ctxVerts = foldedVertices;
            set(hObject,'string','folded')
        
        end
        
        delete(markH);
        markH = plot3(cortexAx,ctxVerts(iVert,1),ctxVerts(iVert,2),ctxVerts(iVert,3),'ko','markersize',10,'linewidth',2);
 
        axis(cortexAx,'tight');
    end

    function setAveragingWindowSize(hObject,varargin)
        
        inputValue = get(hObject,'string');
        
        windowSizeMs = str2double(inputValue);
        
        windowSize = round(windowSizeMs/(x(end)-x(end-1)))-1;
       
        if isnan(windowSize)
            windowSize = 0;
            set(hObject,'String','1');
        end
        
        
        
        
    end

        
end
