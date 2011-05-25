function sliceViewer(anatObj,funcObj)
% Create text file of [LA;RA;NZ] fiducials in RAS voxel coords from vAnatomy.dat
%
% SYNTAX:   vAnatomyFiducials
%           vAnatomyFiducials(vAnatomyPath)

% if ~exist('vAnatomyPath','var')
% 	[vAnatFile,vAnatPath] = uigetfile('vAnatomy.dat','Choose vAnatomy.dat file');
% 	if isnumeric(vAnatFile)
% 		return
% 	end
% 	vAnatomyPath = [vAnatPath,vAnatFile];
% end
% 
% 
% [V,mmVox] = readVolAnat(vAnatomyPath);		% V is IPR
% if ~all(mmVox == [1 1 1])
% 	error('Voxel dimensions not 1x1x1mm')
% end
% if ~all(size(V) == [256 256 256])
% 	error('Volume not 256 voxel cube')
% end
% V(:) = permute(V,[3 2 1]);		% RPI
% V(:) = flipdim(V,2);				% RAI
% V(:) = flipdim(V,3);				% RAS


BGcolor = [0 0.1 0.2];
FGcolor = 'w';
Rcolor = 'r';
Acolor = 'g';
Scolor = 'c';
alphaMax = .5;
alphaCutoff = 256;
depthGamma = 1;
depthLimit = inf;
doSnrWeight = false;
freezeColormap = false;
funcObj.depthWeight = funcObj.initDepthWeight;
 

boxColor = [0.5 0.5 0.5];

dataMin = min(funcObj.volData(:));
dataMax = max(funcObj.volData(:));
origInverse = funcObj.inverse;

i = [128 128 128];

if funcObj.dataSeries.dataType == 'spec'
iFr = funcObj.dataSeries.sigFreqs(1);
else
iFr = 1;
end
iT = 1;
wavePlotH = [];
timelineH = [];
ax = zeros(1,3);
lineR = zeros(1,2);
lineA = zeros(1,2);
lineS = zeros(1,2);
fVoxVal = [NaN NaN NaN];	% values in V of [LA RA NZ] selections

% V = 0-255, colormap = 1-256, 0&1 map to black, 256 is reserved for tagging fiducial voxels
dataFigH = figure('Color',BGcolor,'Colormap',[gray(255); jet(255)],'defaultuicontrolunits','normalized',...
		'name',anatObj.subjId,'tag','sliceViewerDataPanel','CloseRequestFcn',@askToClose);

    
    dataPos = get(dataFigH,'position');
    dataPos(1) = 0;
%    controlPos = dataPos;
    %Place controls to the right of the data figure
    controlPos = [dataPos(1)+dataPos(3) dataPos(2) dataPos(3) 200];
 
    set(dataFigH,'position',dataPos);
    
controlFigH = figure('Color',BGcolor,'defaultuicontrolunits','normalized','name',anatObj.subjId, ...
    'tag','sliceViewerControlPanel','position',controlPos,'menubar','none');
set(controlFigH,'CloseRequestFcn',@askToClose);

figure(dataFigH);

ax(1) = axes('Position',[0.10 0.50 0.4 0.4]);
	imgA = image(squeeze(anatObj.volData(:,i(2),:))');
    hold on;
        %overlay functional
    sliceAlpha = squeeze(alphaMax*(funcObj.volData(:,i(2),:)>alphaCutoff))';
    imgAFunc = image(squeeze(funcObj.volData(:,i(2),:))','alphadata',sliceAlpha);
    hold off;
    
	lineR(1) = line(i([1 1]),[0 256],'color',Rcolor);
	lineS(1) = line([0 256],i([3 3]),'color',Scolor);
	xlabel('R \rightarrow','color',Rcolor)
	ylabel('S \rightarrow','color',Scolor)
    

	
    
ax(2) = axes('Position',[0.55 0.50 0.4 0.4]);
	imgR = image(squeeze(anatObj.volData(i(1),:,:))');
    
    hold on;
    %overlay functional
    sliceAlpha = squeeze(alphaMax*(funcObj.volData(i(1),:,:)>alphaCutoff))';
    imgRFunc = image(squeeze(funcObj.volData(i(1),:,:))','alphadata',sliceAlpha);
    hold off;
    
	lineA(1) = line(i([2 2]),[0 256],'color',Acolor);
	lineS(2) = line([0 256],i([3 3]),'color',Scolor);
	xlabel('A \rightarrow','color',Acolor)
ax(3) = axes('Position',[0.10 0.05 0.4 0.4]);
	imgS = image(anatObj.volData(:,:,i(3))');
    hold on;
    %overlay functional
    sliceAlpha = squeeze(alphaMax*(funcObj.volData(:,:,i(3))>alphaCutoff))';
    imgSFunc = image(squeeze(funcObj.volData(:,:,i(3)))','alphadata',sliceAlpha);
    hold off;

	lineR(2) = line(i([1 1]),[0 256],'color',Rcolor);
	lineA(2) = line([0 256],i([2 2]),'color',Acolor);
	ylabel('A \rightarrow','color',Acolor)

    
    if isfield(funcObj,'dataSeries') & ~isempty(funcObj.dataSeries);
        
        seriesAx = axes('Position',[0.55 0.05 0.4 0.4]);
        plotDataSeries(seriesAx)
    end
    
        
% 	imgS = image(anatObj.volData(:,:,i(3))');
%     hold on;
%     %overlay functional
%     sliceAlpha = squeeze(alphaMax*(funcObj.volData(:,:,i(3))>alphaCutoff))';
%     imgSFunc = image(squeeze(funcObj.volData(:,:,i(3)))','alphadata',sliceAlpha);
%     hold off;
% 
% 	lineR(2) = line(i([1 1]),[0 256],'color',Rcolor);
% 	lineA(2) = line([0 256],i([2 2]),'color',Acolor);
% 	ylabel('A \rightarrow','color',Acolor)

    
set(ax,'YDir','normal','XAxisLocation','top','XTick',[],'YTick',[],...
	'XColor',boxColor,'YColor',boxColor,'Box','on','DataAspectRatio',[1 1 1])
set([imgA,imgR,imgS],'ButtonDownFcn',@moveCrosshairs)
set([imgAFunc,imgRFunc,imgSFunc],'ButtonDownFcn',@moveCrosshairs)

set([lineR,lineA,lineS],'HitTest','off')

% SLICE CONTROLS
uicontrol(controlFigH,'position',[0.01 0.88 0.05 0.1],'style','text','string','R','foregroundcolor',Rcolor,'backgroundcolor',BGcolor)
uicontrol(controlFigH,'position',[0.01 0.78 0.05 0.1],'style','text','string','A','foregroundcolor',Acolor,'backgroundcolor',BGcolor)
uicontrol(controlFigH,'position',[0.01 0.68 0.05 0.1],'style','text','string','S','foregroundcolor',Scolor,'backgroundcolor',BGcolor)
UIslice = [ ...
uicontrol(controlFigH,'position',[0.15 0.88 0.30 0.1],'style','slider','min',1,'max',256,'value',i(1),'sliderstep',[1 10]/255,'tag','sliderR','callback',@setSlice),...
uicontrol(controlFigH,'position',[0.15 0.78 0.30 0.1],'style','slider','min',1,'max',256,'value',i(2),'sliderstep',[1 10]/255,'tag','sliderA','callback',@setSlice),...
uicontrol(controlFigH,'position',[0.15 0.68 0.30 0.1],'style','slider','min',1,'max',256,'value',i(3),'sliderstep',[1 10]/255,'tag','sliderS','callback',@setSlice),...
uicontrol(controlFigH,'position',[0.46 0.89 0.08 0.12],'style','edit','string',i(1),'tag','editR','callback',@setSlice,'foregroundcolor',Rcolor,'backgroundcolor',BGcolor),...
uicontrol(controlFigH,'position',[0.46 0.79 0.08 0.12],'style','edit','string',i(2),'tag','editA','callback',@setSlice,'foregroundcolor',Acolor,'backgroundcolor',BGcolor),...
uicontrol(controlFigH,'position',[0.46 0.69 0.08 0.121],'style','edit','string',i(3),'tag','editS','callback',@setSlice,'foregroundcolor',Scolor,'backgroundcolor',BGcolor),...
];


% % FUNCTIONAL OVERLAY OPTIONS

%Set overal transparency level
uicontrol(controlFigH,'position',[0.01 0.05 0.15 0.1],'style','text','string','Alpha Max','foregroundcolor','w','backgroundcolor',BGcolor);
alphaMaxSliderH = uicontrol(controlFigH,'position',[0.15 0.05 0.30 0.1],'style','slider','min',0,'max',1,'value',alphaMax,'tag','sliderAlphaMax','callback',@setAlphaMax);
alphaMaxEditH   = uicontrol(controlFigH,'position',[0.46 0.06 0.08 0.12],'style','edit','string',alphaMax,'tag','editAlphaMax',...
    'callback',@setAlphaMax,'foregroundcolor','w','backgroundcolor',BGcolor);


% uicontrol('position',[0.55 0.15 0.05 0.05],'style','text','string','Alpha Cutoff','foregroundcolor','w','backgroundcolor',BGcolor)
% uicontrol('position',[0.60 0.15 0.30 0.05],'style','slider','min',dataMin,'max',dataMax,'value',dataMin,'sliderstep',[1 10]/255,'tag','sliderAlphaCutoff','callback',@setAlphaCutoff)

%Set transparency cut off level
uicontrol(controlFigH,'position',[0.01 0.15 0.15 0.1],'style','text','string','Alpha Cutoff','foregroundcolor','w','backgroundcolor',BGcolor)

alphaCutoffSliderH = uicontrol(controlFigH,'position',[0.15 0.15 0.30 0.1],'style','slider','min',256,'max',512,'value',256,...
    'sliderstep',[.01 .10],'tag','sliderAlphaCutoff','callback',@setAlphaCutoff);

alphaCutoffEditH   = uicontrol(controlFigH,'position',[0.46 0.16 0.1 0.121],'style','edit','string',alphaCutoff,'tag','editAlphaCutoff',...
    'callback',@setAlphaCutoff,'foregroundcolor','w','backgroundcolor',BGcolor);

uicontrol(controlFigH,'position',[0.46 0.3 0.3 0.121],'style','text','string','cutoff index:',...
    'HorizontalAlignment','left','foregroundcolor','w','backgroundcolor',BGcolor);

alphaRealValueH   = uicontrol(controlFigH,'position',[0.6 0.16 0.3 0.121],'style','text','string',0,'tag','alphaRealValue',...
    'foregroundcolor','w','backgroundcolor',BGcolor);

uicontrol(controlFigH,'position',[0.6 0.3 0.3 0.121],'style','text','string','cutoff value:',...
    'foregroundcolor','w','backgroundcolor',BGcolor);


% % % Inverse options
depthWeightCheckboxH = uicontrol(controlFigH,'position',[0.56 0.88 0.2 0.1],'style','checkbox', ...
    'string','Apply Depth Weighting','callback',@depthCheckbox,'foregroundcolor','w');
    
uicontrol(controlFigH,'position',[0.76 0.88 0.08 0.13],'style','text',...
    'string','Depth Exponent','foregroundcolor','w','backgroundcolor',BGcolor);

depthWeightEditH = uicontrol(controlFigH,'position',[0.85 0.89 0.08 0.12], ...
    'style','edit','string',1,'tag','editR','callback',@setDepthGamma,'foregroundcolor','w','backgroundcolor',BGcolor);


snrCheckboxH = uicontrol(controlFigH,'position',[0.56 0.78 0.2 0.1],'style','checkbox', ...
    'string','Show SNR','callback',@snrCheckbox,'foregroundcolor','w');

colormapCheckboxH = uicontrol(controlFigH,'position',[0.56 0.65 0.2 0.12],'style','checkbox', ...
    'string','Freeze Colormap','callback',@colormapCheckbox,'foregroundcolor','w');

% % FIDUCIAL CONTROLS
% uicontrol('position',[0.55 0.20 0.05 0.05],'style','text','string','LA','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
% uicontrol('position',[0.55 0.15 0.05 0.05],'style','text','string','RA','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
% uicontrol('position',[0.55 0.10 0.05 0.05],'style','text','string','NZ','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
% UIfiducial = [ ...
% uicontrol('position',[0.60 0.20 0.17 0.05],'style','edit','enable','off','value',[]),...
% uicontrol('position',[0.60 0.15 0.17 0.05],'style','edit','enable','off','value',[]),...
% uicontrol('position',[0.60 0.10 0.17 0.05],'style','edit','enable','off','value',[]),...
% ];
% uicontrol('position',[0.77 0.20 0.06
% 0.05],'style','pushbutton','string','click','tag','LA','callback',@clickPoint)
% uicontrol('position',[0.77 0.15 0.06 0.05],'style','pushbutton','string','click','tag','RA','callback',@clickPoint)
% uicontrol('position',[0.77 0.10 0.06 0.05],'style','pushbutton','string','click','tag','NZ','callback',@clickPoint)
% uicontrol('position',[0.83 0.20 0.06 0.05],'style','pushbutton','string','set','tag','LA','callback',@setPoint)
% uicontrol('position',[0.83 0.15 0.06 0.05],'style','pushbutton','string','set','tag','RA','callback',@setPoint)
% uicontrol('position',[0.83 0.10 0.06 0.05],'style','pushbutton','string','set','tag','NZ','callback',@setPoint)
% uicontrol('position',[0.89 0.20 0.06 0.05],'style','pushbutton','string','goto','tag','LA','callback',@gotoPoint)
% uicontrol('position',[0.89 0.15 0.06 0.05],'style','pushbutton','string','goto','tag','RA','callback',@gotoPoint)
% uicontrol('position',[0.89 0.10 0.06 0.05],'style','pushbutton','string','goto','tag','NZ','callback',@gotoPoint)
% 
% % LOAD,SAVE
% uicontrol('position',[0.60 0.05 0.17 0.05],'style','pushbutton','string','LOAD','callback',@loadFiducials) %,'backgroundcolor',[0 0.4 0.8],'foregroundcolor','k')
% uicontrol('position',[0.77 0.05 0.18 0.05],'style','pushbutton','string','SAVE','callback',@saveFiducials) %,'backgroundcolor',[0 0.4 0.8],'foregroundcolor','k')

return


	function setSlice(H,varargin)
		switch get(H,'tag')
		case 'sliderR'
			updateSlice(get(H,'value'),1)
		case 'sliderA'
			updateSlice(get(H,'value'),2)
		case 'sliderS'
			updateSlice(get(H,'value'),3)
		case 'editR'
			updateSlice(eval(get(H,'string')),1)
		case 'editA'
			updateSlice(eval(get(H,'string')),2)
		case 'editS'
			updateSlice(eval(get(H,'string')),3)
        end
        
        plotDataSeries(seriesAx);
    end

	function updateSlice(val,dim)
		val = round(min(max(val,1),256));
        
			i(dim) = val;
			switch dim
			case 1
				set(lineR,'XData',i([1 1]))
				set(UIslice(1),'value',i(1))
				set(UIslice(4),'string',i(1))
				set(imgR,'CData',squeeze(anatObj.volData(i(1),:,:))')
                
                set(imgRFunc,'CData',squeeze(funcObj.volData(i(1),:,:))')
                set(imgRFunc,'alphadata',squeeze(alphaMax*(funcObj.volData(i(1),:,:)>alphaCutoff))')
			case 2
				set(lineA(1),'XData',i([2 2]))
				set(lineA(2),'YData',i([2 2]))
				set(UIslice(2),'value',i(2))
				set(UIslice(5),'string',i(2))
				set(imgA,'CData',squeeze(anatObj.volData(:,i(2),:))')
                %update functional overlay
                set(imgAFunc,'CData',squeeze(funcObj.volData(:,i(2),:))')
                set(imgAFunc,'alphadata',squeeze(alphaMax*(funcObj.volData(:,i(2),:)>alphaCutoff))')

			case 3
				set(lineS,'YData',i([3 3]))
				set(UIslice(3),'value',i(3))
				set(UIslice(6),'string',i(3))
				set(imgS,'CData',anatObj.volData(:,:,i(3))')
                %update functional overlay
                set(imgSFunc,'CData',squeeze(funcObj.volData(:,:,i(3)))')
                set(imgSFunc,'alphadata',squeeze(alphaMax*(funcObj.volData(:,:,i(3))>alphaCutoff))')

			end
	%	end
	end

	function moveCrosshairs(varargin)
		k = gca == ax;
		xyz = get(ax(k),'currentpoint');
		if k(1)
			updateSlice(xyz(1,1),1)
			updateSlice(xyz(1,2),3)
		elseif k(2)
			updateSlice(xyz(1,1),2)
			updateSlice(xyz(1,2),3)
		else
			updateSlice(xyz(1,1),1)
			updateSlice(xyz(1,2),2)
        end
        plotDataSeries(seriesAx);
	end

	function clickPoint(H,varargin)
		ginput(1);
		moveCrosshairs

		setPoint(H)
	end

	function setPoint(H,varargin)
		f = strcmp({'LA','RA','NZ'},get(H,'tag'));
		old = get(UIfiducial(f),'value');
		if ~isempty(old)
			anatObj.volData(old(1),old(2),old(3)) = fVoxVal(f);
		end
		fVoxVal(f) = anatObj.volData(i(1),i(2),i(3));
		anatObj.volData(i(1),i(2),i(3)) = 256;
		set(UIfiducial(f),'string',sprintf('%g, %g, %g',i),'value',i)
		set(imgR,'CData',squeeze(anatObj.volData(i(1),:,:))')		% color voxel under crosshair
		set(imgA,'CData',squeeze(anatObj.volData(:,i(2),:))')
		set(imgS,'CData',anatObj.volData(:,:,i(3))')
	end

	function gotoPoint(H,varargin)
		i2 = get(UIfiducial(strcmp({'LA','RA','NZ'},get(H,'tag'))),'value');
		for dim = 1:3
			updateSlice(i2(dim),dim)
        end
    end

    % FUNCTIONAL OVERLAY CONTROL CALLBACKS
    
    function setAlphaMax(H,varargin)

        switch get(H,'tag')
            case 'editAlphaMax'
                alphaMax = str2num(get(H,'string'));
                set(alphaMaxSliderH,'value',alphaMax);
            case 'sliderAlphaMax';        
                alphaMax = get(H,'value');
                set(alphaMaxEditH,'string',num2str(alphaMax));
        end
        
        
        updateSlice(i(1),1)
        updateSlice(i(2),2)
        updateSlice(i(3),3)
        
    end

    function setAlphaCutoff(H,varargin)

        switch get(H,'tag')
            case 'editAlphaCutoff'
                alphaCutoff = str2num(get(H,'string'));
                set(alphaCutoffSliderH,'value',alphaCutoff);
            case 'sliderAlphaCutoff';        
                alphaCutoff = get(H,'value');
                set(alphaCutoffEditH,'string',num2str(alphaCutoff));

        end
        
        updateSlice(i(1),1)
        updateSlice(i(2),2)
        updateSlice(i(3),3)
        
        alphaRealValue = funcObj.alphaIdx2Real(round(alphaCutoff));
        set(alphaRealValueH,'string',num2str(alphaRealValue));
        
    end


    function depthCheckbox(H,varargin)
        
        doDepthWeight = get(H,'value');
        
        if doDepthWeight
            funcObj.depthWeight = funcObj.initDepthWeight.^depthGamma;
            wMin = min(funcObj.depthWeight);
            funcObj.depthWeight = funcObj.depthWeight./wMin;
            threshold = depthLimit;% * wMin;
            funcObj.depthWeight(funcObj.depthWeight>threshold) = threshold;
            funcObj.depthWeight=1e12*funcObj.depthWeight;
            
        else
            funcObj.depthWeight = 1e12*funcObj.initDepthWeight.^0;
        end

        updateInverse;
        
    end

    function setDepthGamma(H,varargin)
        
        
        depthGamma = str2num(get(H,'string'));
        
    end


    function snrCheckbox(H,varargin)
        
        doSnrWeight = get(H,'value');
        updateInverse;
        
%         if doSnrWeight
%             
%             
%         else
%             
%         end
% 
%         updateInverse;
        
    end

    function colormapCheckbox(H,varargin)
        
        freezeColormap = get(H,'value');
        
        if ~freezeColormap
            updateInverse;
        end
        
    end

    function updateInverse()
        
        funcObj.inverse = bsxfun(@times,funcObj.depthWeight,origInverse);
        volSize = size(funcObj.volData);
        
        switch lower(funcObj.dataSeries.dataType)
            case 'spec'
           

                if doSnrWeight
                    noiseFr = max(1,[iFr-1 iFr+1]);
                    noiseFr = min(size(funcObj.dataSeries.allCondSpec,2),noiseFr);
                    noiseData = funcObj.dataSeries.allCondSpec(:,noiseFr,:);
                    noiseData = shiftdim(noiseData,2);
      
                    noiseNormal = funcObj.inverse*noiseData(:,:);
                    noiseNormal = abs(noiseNormal);
                    noiseNormal = 1./mean(noiseNormal,2);
                    noiseNormal(isinf(noiseNormal)) = 0;
                    noiseNormal = combineTriplet(noiseNormal)';
                    noiseNormal = repmat(noiseNormal,3,1);
                    noiseNormal = noiseNormal(:);
      
%                    sourceData = noiseNormal.*sourceData;
                    funcObj.inverse = bsxfun(@times,noiseNormal,funcObj.inverse);
                end
                
                sourceData = combineTriplet(abs(funcObj.inverse*funcObj.dataSeries.spec(iFr,:)'));
                funcObj.volData = reshape(funcObj.interpMtx*sourceData, volSize(1),volSize(2),volSize(3));
                
            case 'wave'
                funcObj.volData = reshape(funcObj.interpMtx*combineTriplet(abs(funcObj.inverse*funcObj.dataSeries.wave(iT,:)')), ...
                    volSize(1),volSize(2),volSize(3));
        end
        
        
        plotDataSeries(seriesAx)
        %rerange source data for colormap
        
        if ~freezeColormap
            dataMin = min(funcObj.volData(:));
            dataMax = max(funcObj.volData(:));
        end
        
        dataRange = dataMax-dataMin;
        
        funcObj.volData = (255*(funcObj.volData-dataMin)./dataRange)+256;
        funcObj.alphaIdx2Real = [zeros(1,255) ((0:255)*dataRange/255)+dataMin];
        
        alphaRealValue = funcObj.alphaIdx2Real(round(alphaCutoff));
        set(alphaRealValueH,'string',num2str(alphaRealValue));
        
        updateSlice(i(1),1)
        updateSlice(i(2),2)
        updateSlice(i(3),3)
    end



% % Funtional Data Plotting

    function plotDataSeries(ax)
        axes(ax)
        
        
        
        switch lower(funcObj.dataSeries.dataType)
            case 'wave'
                
                dataIdx = sub2ind(size(funcObj.volData),i(1),i(2),i(3));
                
                %These are the source locations that will be used for
                %interpolation
                srcLocs = find(funcObj.interpMtx(dataIdx,:));
                
                srcLocsTriple = [srcLocs*3-2 srcLocs*3-1 srcLocs*3];
                sourceData = funcObj.interpMtx(dataIdx,srcLocs)*combineTriplet(abs(funcObj.inverse(srcLocsTriple,:)*funcObj.dataSeries.wave(:,:)'));
                
                delete(wavePlotH);
                wavePlotH = plot(funcObj.dataSeries.xTms, sourceData,'k','linewidth',2);
                  title(seriesAx,['Time: ' num2str(funcObj.dataSeries.xTms(iT)) ' (ms)'],'color','w','fontsize',22)

                  %ylim([0 260])
                  
                  [axLim] = axis(seriesAx);
                  yLo = axLim(3);
                  yHi = axLim(4);
  
                timelineH = line([funcObj.dataSeries.xTms(iT) funcObj.dataSeries.xTms(iT)],[yLo yHi],'linewidth',2,'buttondownFcn',@clickedWave);
                
                %Set up the function to call when the plots are clicked on
                set(seriesAx,'ButtonDownFcn',@clickedWave)
                set(wavePlotH,'ButtonDownFcn',@clickedWave)
                set(timelineH,'ButtonDownFcn',@clickedWave)
                
            case 'spec'
                
                dataIdx = sub2ind(size(funcObj.volData),i(1),i(2),i(3));
                
                %These are the source locations that will be used for
                %interpolation
                srcLocs = find(funcObj.interpMtx(dataIdx,:));
                
                srcLocsTriple = [srcLocs*3-2 srcLocs*3-1 srcLocs*3];
                sourceData = funcObj.interpMtx(dataIdx,srcLocs)*combineTriplet(abs(funcObj.inverse(srcLocsTriple,:)*funcObj.dataSeries.spec(:,:)'));
                
                [barH sigH] = pdSpecPlot(funcObj.dataSeries.xFrqs,sourceData,funcObj.dataSeries.sigFreqs);
                xlim([0 50]);
                title(seriesAx,['Frequency: ' num2str(funcObj.dataSeries.xFrqs(iFr)) ' Hz'],'color','w','fontsize',22)
                
                set(barH,'ButtonDownFcn',   @clickedSpec)
                set(sigH,'ButtonDownFcn',   @clickedSpec)
                set(seriesAx,'ButtonDownFcn', @clickedSpec)
                
        end
        
        set(seriesAx,'YCOLOR','w','XCOLOR','w')
        
    end

    function clickedSpec(varargin)
        
       tCurPoint = get(seriesAx,'CurrentPoint');
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        %Get the x location of the lick and find the nearest index
        [distance iFr] = min(abs(funcObj.dataSeries.xFrqs-tCurPoint(1,1)));
        
        if iFr>=1 && iFr<=length(funcObj.dataSeries.xFrqs)

            title(seriesAx,['Frequency: ' num2str(funcObj.dataSeries.xFrqs(iFr)) ' Hz'],'color','w','fontsize',22)
            updateInverse();
            

        else
            disp('clicked out of bounds')
        end
    end

    function clickedWave(varargin)
        
       tCurPoint = get(seriesAx,'CurrentPoint');
        %set( tHline, 'XData', tCurPoint(1,[1 1]) )
        
        %Get the x location of the lick and find the nearest index
        
        [distance iT] = min(abs(funcObj.dataSeries.xTms-tCurPoint(1,1)));
        
        [axLim] = axis(seriesAx);
        yLo = axLim(3);
        yHi = axLim(4);
        
        if iFr>=1 && iFr<=length(funcObj.dataSeries.xTms)

            title(seriesAx,['Time: ' num2str(funcObj.dataSeries.xTms(iT)) ' (ms)'],'color','w','fontsize',22)

            
            set(timelineH,'XData',[funcObj.dataSeries.xTms(iT) funcObj.dataSeries.xTms(iT)],'YData',[yLo yHi])
            
            volSize = size(funcObj.volData);
            funcObj.volData = reshape(funcObj.interpMtx*combineTriplet(abs(funcObj.inverse*funcObj.dataSeries.wave(iT,:)')), ...
                volSize(1),volSize(2),volSize(3));
            
            
            %rerange source data for colormap
            if ~freezeColormap
                dataMin = min(funcObj.volData(:));
                dataMax = max(funcObj.volData(:));
            end
            
            dataRange = dataMax-dataMin;
            
            funcObj.volData = (255*(funcObj.volData-dataMin)/dataRange)+256;

            
            funcObj.alphaIdx2Real = [zeros(1,255) (0:255)*dataRange/255+dataMin];

            updateSlice(i(1),1)
            updateSlice(i(2),2)
            updateSlice(i(3),3)
        else
            disp('clicked out of bounds')
        end
    end


%Close all windows together
    function askToClose(src,event)
%         src
%         event
        
        choice = questdlg('Close sliceViewer?','Close sliceViewer','Yes','No','Yes');
        
        switch choice
            case 'Yes'
                delete(controlFigH);
                delete(dataFigH);
                
            case 'No'
                return;
        end
    end

        
        
% 	function loadFiducials(varargin)
% 		[filename,pathname] = uigetfile('*.txt','Fiducial text file');
% 		if isnumeric(filename)
% 			return
% 		end
% 		P = load('-ascii',[pathname,filename]);
% 		if ~all(size(P)==[3 3])
% % 			error('%s doesn''t contain a 3x3 ascii matrix',[pathname,filename])
% 			uiwait(errordlg({filename;'doesn''t contain 3x3 ascii matrix'},'Invalid file')),return
% 		end
% 		P = P + 128;
% 		for f = 1:3
% 			set(UIfiducial(f),'string',sprintf('%d, %d, %d',P(f,:)),'value',P(f,:))
% 		end
% 	end
% 
% 	function saveFiducials(varargin)
% 		P = [ get(UIfiducial(1),'value'); get(UIfiducial(2),'value'); get(UIfiducial(3),'value') ];
% 		if ~all(size(P)==[3 3])
% % 			error('must set all 3 fiducials before saving')
% 			uiwait(errordlg({'Set LA, RA, and NZ';'Not saving'},'Incomplete fiducials')),return
% 		end
% 		if P(2,1) < P(1,1)
% 			uiwait(errordlg({'RA is left of LA';'Not saving'},'Implausible fiducials')),return
% 		end
% 		P = P - 128;
% 		[vAnatPath,vAnatFile] = fileparts(vAnatomyPath);
% 		[junk,subjid] = fileparts(vAnatPath);
% % 		[filename,pathname] = uiputfile('*.txt','Fiducial text file',fullfile(vAnatPath,[subjid,'_fiducials.txt']));
% 		[filename,pathname] = uiputfile('*.txt','Fiducial text file',[subjid,'_fiducials.txt']);
% 		if isnumeric(filename)
% 			return
% 		end
% 		save([pathname,filename],'P','-ascii','-tabs')
% 	end

end

% fv = isosurface(V,25);		% takes forever
% H = patch(fv,'facecolor','y','edgecolor','none','facelighting','gouraud');
% isonormals(V,H)