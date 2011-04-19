function [] = animatedTopoPlot(data,x,plotNames)
%function [] = animatedTopoPlot(data,x,plotNames)
%
%helpful help here
%

clf;
dataDims = size(data);

if length(dataDims)==3
    nPlots = dataDims(1);
    nTimes = dataDims(2);
    nElec = dataDims(3);
elseif length(dataDims)==2    
    nPlots = 1;
    
    nTimes = dataDims(1);
    nElec = dataDims(2);
    
    %make data 3d to fit with the rest of the expected code
    data=shiftdim(data,-1);
else
    error('data must by either 2 or 3 dimensional');
end

if ~exist('x','var') || isempty(x) 
    disp('no x values, displaying index numbers');
    
    x=1:nTimes;
end

if ~exist('plotNames','var') || isempty(plotNames) 
    plotNames = cellstr(num2str([1:nTimes]'));
end

if nElec~= 128;
    error('Only works for 128 channel data')
end




%Make a squarish matrix of topos
nCol = ceil(sqrt(nPlots));
nRows = ceil(nPlots/nCol);

% 
%tst for direct colormapping speed.
% data(:) = 63*((data(:)-min(data(:)))./range(data(:)))+1;
% ca = [1 max(abs(data(:)))];

ca = [-max(abs(data(:))) max(abs(data(:)))];

for iPlot = 1:nPlots,
    
    subplot(nRows,nCol,iPlot);        
    topoH(iPlot) = plotOnEgi(squeeze(data(iPlot,1,:)));
    caxis(ca)
    axis tight
    axis off
    th(iPlot) = title(plotNames{iPlot});
    set(th(iPlot),'Position', [-0.0113687 -1.7 1.00011],'interpreter','none');
    %test of various patch properties for speed.
%    set(topoH(iPlot),'EraseMode','none');
%    set(topoH(iPlot),'CDataMapping','direct')

    
end
set(gcf,'KeyPressFcn',@keyInput)
animateH = uicontrol('Style', 'pushbutton', 'String', 'ANIMATE',...
    'units','normalized','Position',[0 .95 .1 0.05], 'Callback', @runAnimation);

stopDrawing = false;
startT = 1;

stopH = uicontrol('Style', 'pushbutton', 'String', 'STOP',...
    'units','normalized','Position',[.9 .95 .1 0.05], 'Callback',@stop);

%sliderH = uicontrol('Style', 'slider', 'Min',x(1), 'Max', x(end), ... 
sliderH = uicontrol('Style', 'slider', 'units','normalized', ...
    'Position',[.1 0 .8 0.05],'callback',@sliderCallback);

set(sliderH,'min',1,'max',length(x),'value',1)

    
timeTxtH = uicontrol('Style', 'text','String', ['Time: ' num2str(x(1),3) ] , ...
     'units','normalized','Position',[.45 .95 .3 0.05],'fontsize',14, ...
    'HorizontalAlignment',  'left',  'backgroundcolor',get(gcf,'color') );

ch = colorbar('position',[.93 .2 .02 0.6]);

    function [] = runAnimation(varargin)
        stopDrawing = false;
        for iT = startT:nTimes,
            
            if stopDrawing
                stopDrawing = false;
                startT = iT;
                break;
            end
            
            for iPlot = 1:nPlots,
                set(topoH(iPlot),'faceVertexCData',squeeze(data(iPlot,iT,:)))
            end
            
            %             if mod(iT,10)==0,
            %                 drawnow;
            %             else
            %             drawnow expose
            %             end
            
            
            %             title(
            set(timeTxtH,'string',['Time: ' num2str(x(iT),3)]);
            set(sliderH,'Value',iT)
            drawnow;
        end
        
        if(iT ==nTimes),
            startT = 1;
        end
        
        
    
    end


    function [] = stop(varargin)
        
        stopDrawing = true;
    end


    function [] = sliderCallback(varargin)

        iT = round(get(sliderH,'Value'));
        startT = iT;
        
        for iPlot = 1:nPlots,
            set(topoH(iPlot),'faceVertexCData',squeeze(data(iPlot,iT,:)))
        end
        
        set(timeTxtH,'string',['Time: ' num2str(x(iT),3)]);
        drawnow;
        
    end

    function keyInput(src,evnt)
        
        iT = startT;
        
        switch(lower(evnt.Key))
            case 'leftarrow'
                iT = max(iT-1,1);
            case 'rightarrow'
                iT = min(iT+1,length(x));
                      
        end
        
        for iPlot = 1:nPlots,
            set(topoH(iPlot),'faceVertexCData',squeeze(data(iPlot,iT,:)))
        end
        
        set(timeTxtH,'string',['Time: ' num2str(x(iT),3)]);
        startT = iT;
        set(sliderH,'Value',iT)
        drawnow;
        
    end

        
end
















