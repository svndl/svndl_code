function [] = interactiveTopoPlot(data,x)
%function [] = interactiveTopoPlot(data,x)
%
% helpful help here
%



%Do some sanity checks here
%if wrong
%dosomething
%end
iElec = 75;
figure
topoAx = subplot(10,1,1:8);
topoH = plotOnEgi(squeeze(data(1,:)));
axis off;
elecVerts = get(topoH,'Vertices');


freqs = x;

%sigFreqs = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
specAx = subplot(10,1,9:10);
drawSpec();


set(topoH,'ButtonDownFcn',@clickedTopo)
set(topoAx,'ButtonDownFcn',@clickedTopo)




%set(topoAx,'ButtonDownFcn',@specUpdate)

    function drawSpec()
        
        axes(specAx)
        [barH sigH] = pdSpecPlot(freqs,data(:,iElec),[]);
        
        %Set up the function to call when the plots are clicked on
        set(barH,'ButtonDownFcn',@clickedSpec)
        set(sigH,'ButtonDownFcn',@clickedSpec)
        set(specAx,'ButtonDownFcn',@clickedSpec)
        
    end


    function clickedSpec(varargin)
        
       tCurPoint = get(specAx,'CurrentPoint');
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        %Get the x location of the lick and find the nearest index
        [distance iFr] = min(abs(x-tCurPoint(1,1)));
        
        if iFr>=1 && iFr<=x(end)

            set(topoH,'facevertexCData',data(iFr,:)')

        else
            disp('clicked out of bounds')
        end
    end

    function clickedTopo(varargin)
        
        tCurPoint = get(topoAx,'CurrentPoint')
        
        dist = bsxfun(@minus,tCurPoint(1,:),elecVerts);
        
        dist = sqrt(sum(dist.^2,2));
        
        %Get the index to the nearest clicked electrode
        [distance iE] = min(dist)
        
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        if iE>=1 && iE<=size(elecVerts,1),
            
            iElec = iE;
            drawSpec;

        end
        
    end
        
end
