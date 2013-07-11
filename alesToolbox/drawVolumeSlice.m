function [volObj,h] = drawVolumeSlice(varargin)
%function [handle] = drawVolume(x,y,z,v,varargin)
%
%Calling syntax:
%
%[volObj] = drawVolumeSlice('skeri0001')
%
%


if nargin==0
    help drawAnatomySurface
end


if isstruct(varargin{1})
    volObj = varargin{1};
elseif ischar(varargin{1})   
    
    argList = {'subjId',varargin{1}};
    volObj = setupVolumeSliceObject(argList{:});
        
else
    
    
    %     if nargin==2
    %         argList = {'subjId',varargin{1},'surfName',varargin{2}};
    %     elseif nargin>2
    %         argList = {'subjId',varargin{1},'surfName',varargin{2},'patchOptions',{varargin{3:end}}}
    %     end
    
    volObj = setupVolumeSliceObject(argList{:});
       
end

hIdx = 1;
nP = 10;

%scale v to index directly into colormap 
%v = (v-min(v(:)))/range(v(:)); %scaled from 0-1
%v = fix(255*v+1); %1-256
%v = uint8(v);

% cmap = jmaColors('arizona',[],256);
% colormap(cmap);
% 
% colormap('gray')
%h = findobj(ax,'type','surface','tag','volslice');



% 
% if isempty(p)
%     p.handles() = surface(thisX,thisY,thisZ,'Parent',volObj.parent)
% end

% 'FaceColor','texturemap', ...
% 'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
% 'AlphaDataMapping','none','CDataMapping','direct');

dataMin = min(volObj.volData(:));
dataMax = max(volObj.volData(:));
dataRange = dataMax-dataMin;



for iX = 1:length(volObj.xIndices),
    
    
    xSliceIdx = volObj.xIndices(iX);
    
    
    %texture map data for surface
    slice = squeeze(volObj.volData(xSliceIdx,:,:));
    sliceAlpha = (slice-dataMin)/dataRange;
    % sliceAlpha(slice==1) = 0;
%        sliceAlpha(:) = 0;
%        sliceAlpha(slice(:)>60) = 1;
    % Position of surface
    thisX = squeeze(volObj.x(xSliceIdx,:,:));
    thisY = squeeze( volObj.y(iX,:,:));
    thisZ = squeeze( volObj.z(iX,:,:));
%     
% %     
% %     tX = [min(thisX(:)) max(thisX(:))];
% %     tY = [min(thisY(:)) max(thisY(:))];
% %     tZ = [min(thisZ(:)) max(thisZ(:))];
% % 
    thisX = [min(thisX(:)) min(thisX(:)); min(thisX(:)) min(thisX(:))];
    thisY = [min(thisY(:)) min(thisY(:)); max(thisY(:)) max(thisY(:))];
    thisZ = [min(thisZ(:)) max(thisZ(:)); min(thisZ(:)) max(thisZ(:))];


%     tX = [thisX(1,1) thisX(end,end)];
%     tY = [thisY(1,1) thisY(end,end)];
%     tZ = [thisZ(1,1) thisZ(end,end)];

%     thisX = squeeze(x(iX,1,1))*ones(nP);
% %     thisY = squeeze(y(iX,1,1))*ones(nP);
% %     thisZ = squeeze(z(iX,1,1))*ones(nP);
%     
%     thisX = linspace(x(iX,1,1), x(iX,end,end),nP);
%     thisY = linspace(y(iX,1,1), y(iX,end,end),nP);
%     thisZ = linspace(z(iX,1,1), z(iX,end,end),nP);
% 
%     [thisX tmp thisZ] = ndgrid(thisX,thisY,thisZ);
%     
%     thisZ = squeeze(thisZ(:,:,1))
    
    
%     h(hIdx) = surface(x,y,z,'Parent',ax);   
%     set(h(hIdx),'cdatamapping','scaled','facecolor','texture','cdata',slice,...
%         'edgealpha',0,'alphadata',double(slice),'facealpha','texturemap');


    % Display Surface
    h(hIdx) = surface(thisX,thisY,thisZ, slice,'FaceColor','texturemap', ...
        'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
        'AlphaDataMapping','none','CDataMapping','direct');
    
    hIdx = hIdx+1;
    
end



for iY = 1:length(volObj.yIndices),
    
    
    ySliceIdx = volObj.yIndices(iY);
    
    
    %texture map data for surface
    slice = squeeze(volObj.volData(:,ySliceIdx,:));
    sliceAlpha = (slice-dataMin)/dataRange;
    % sliceAlpha(slice==1) = 0;
%        sliceAlpha(:) = 0;
%        sliceAlpha(slice(:)>60) = 1;
    % Position of surface
    thisX = squeeze( volObj.x(:,iY,:));
    thisY = squeeze(volObj.y(:,ySliceIdx,:));
    thisZ = squeeze( volObj.z(:,iY,:));
%     
% %     
% %     tX = [min(thisX(:)) max(thisX(:))];
% %     tY = [min(thisY(:)) max(thisY(:))];
% %     tZ = [min(thisZ(:)) max(thisZ(:))];
% % 
%     thisX = [min(thisX(:)) min(thisX(:)); min(thisX(:)) min(thisX(:))];
%     thisY = [min(thisY(:)) min(thisY(:)); max(thisY(:)) max(thisY(:))];
%     thisZ = [min(thisZ(:)) max(thisZ(:)); min(thisZ(:)) max(thisZ(:))];

    thisX = [min(thisX(:)) min(thisX(:)); max(thisX(:)) max(thisX(:))];
    thisY = [min(thisY(:)) min(thisY(:)); min(thisY(:)) min(thisY(:))];
    thisZ = [min(thisZ(:)) max(thisZ(:)); min(thisZ(:)) max(thisZ(:))];


%     tX = [thisX(1,1) thisX(end,end)];
%     tY = [thisY(1,1) thisY(end,end)];
%     tZ = [thisZ(1,1) thisZ(end,end)];

%     thisX = squeeze(x(iX,1,1))*ones(nP);
% %     thisY = squeeze(y(iX,1,1))*ones(nP);
% %     thisZ = squeeze(z(iX,1,1))*ones(nP);
%     
%     thisX = linspace(x(iX,1,1), x(iX,end,end),nP);
%     thisY = linspace(y(iX,1,1), y(iX,end,end),nP);
%     thisZ = linspace(z(iX,1,1), z(iX,end,end),nP);
% 
%     [thisX tmp thisZ] = ndgrid(thisX,thisY,thisZ);
%     
%     thisZ = squeeze(thisZ(:,:,1))
    
    
%     h(hIdx) = surface(x,y,z,'Parent',ax);   
%     set(h(hIdx),'cdatamapping','scaled','facecolor','texture','cdata',slice,...
%         'edgealpha',0,'alphadata',double(slice),'facealpha','texturemap');


    % Display Surface
    h(hIdx) = surface(thisX,thisY,thisZ, slice,'FaceColor','texturemap', ...
        'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
        'AlphaDataMapping','none','CDataMapping','direct');
    
    hIdx = hIdx+1;
    
end

for iZ = 1:length(volObj.zIndices),
    
    
    zSliceIdx = volObj.zIndices(iZ);
    
    
    %texture map data for surface
    slice = squeeze(volObj.volData(:,:,zSliceIdx));
    sliceAlpha = (slice-dataMin)/dataRange;
    % sliceAlpha(slice==1) = 0;
%     sliceAlpha(:) = 0;
%        sliceAlpha(slice(:)>60) = 1;
       
    % Position of surface
    thisX = squeeze( volObj.x(:,:,iZ));
    thisY = squeeze( volObj.y(:,:,iZ));
    thisZ = squeeze(volObj.z(:,:,zSliceIdx));
      
% %     
% %     tX = [min(thisX(:)) max(thisX(:))];
% %     tY = [min(thisY(:)) max(thisY(:))];
% %     tZ = [min(thisZ(:)) max(thisZ(:))];
% % 
%     thisX = [min(thisX(:)) min(thisX(:)); min(thisX(:)) min(thisX(:))];
%     thisY = [min(thisY(:)) min(thisY(:)); max(thisY(:)) max(thisY(:))];
%     thisZ = [min(thisZ(:)) max(thisZ(:)); min(thisZ(:)) max(thisZ(:))];

    thisX = [min(thisX(:)) min(thisX(:)); max(thisX(:)) max(thisX(:))];
    thisY = [min(thisY(:)) max(thisY(:)); min(thisY(:)) max(thisY(:))];
    thisZ = [min(thisZ(:)) min(thisZ(:)); min(thisZ(:)) min(thisZ(:))];


%     tX = [thisX(1,1) thisX(end,end)];
%     tY = [thisY(1,1) thisY(end,end)];
%     tZ = [thisZ(1,1) thisZ(end,end)];

%     thisX = squeeze(x(iX,1,1))*ones(nP);
% %     thisY = squeeze(y(iX,1,1))*ones(nP);
% %     thisZ = squeeze(z(iX,1,1))*ones(nP);
%     
%     thisX = linspace(x(iX,1,1), x(iX,end,end),nP);
%     thisY = linspace(y(iX,1,1), y(iX,end,end),nP);
%     thisZ = linspace(z(iX,1,1), z(iX,end,end),nP);
% 
%     [thisX tmp thisZ] = ndgrid(thisX,thisY,thisZ);
%     
%     thisZ = squeeze(thisZ(:,:,1))
    
    
%     h(hIdx) = surface(x,y,z,'Parent',ax);   
%     set(h(hIdx),'cdatamapping','scaled','facecolor','texture','cdata',slice,...
%         'edgealpha',0,'alphadata',double(slice),'facealpha','texturemap');


    % Display Surface
    h(hIdx) = surface(thisX,thisY,thisZ, slice,'FaceColor','texturemap', ...
        'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
        'AlphaDataMapping','none','CDataMapping','direct');
    
    hIdx = hIdx+1;
    
end

% for iY = 1:size(v,2),
%     
%     
%     %texture map data for surface
%     slice = squeeze(v(:,iY,:));
%     sliceAlpha = (slice-1)/255;
% 
% %     % Position of surface
%     thisX = squeeze( x(:,iY,:));
%     thisY = squeeze( y(:,iY,:));
%     thisZ = squeeze( z(:,iY,:));
%     
% % %     tX = [min(thisX(:)) max(thisX(:))];
% % %     tY = [min(thisY(:)) max(thisY(:))];
% % %     tZ = [min(thisZ(:)) max(thisZ(:))];
% % 
% %     tX = [thisX(1,1) thisX(end,end)];
% %     tY = [thisY(1,1) thisY(end,end)];
% %     tZ = [thisZ(1,1) thisZ(end,end)];
% % 
% %     
% %     [thisX thisY thisZ] = meshgrid(tX,tY,tZ);
% 
% %     
% %     thisX = linspace(x(1,iY,1), x(end,iY,end),nP);
% %     thisY = squeeze(y(1,iY,1))*ones(nP);
% %     thisY = linspace(z(1,iY,1,1), z(end,iY,end),nP);
% 
%     
% %     h(hIdx) = surface(x,y,z,'Parent',ax);   
% %     set(h(hIdx),'cdatamapping','scaled','facecolor','texture','cdata',slice,...
% %         'edgealpha',0,'alphadata',double(slice),'facealpha','texturemap');
% 
% 
%     % Display Surface
%     h(hIdx) = surface(thisX,thisY,thisZ, slice,'FaceColor','texturemap', ...
%         'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
%         'AlphaDataMapping','none','CDataMapping','direct');
%     
%     hIdx = hIdx+1;
%     
% end
% 
% for iZ = 1:size(v,3),
%     
%     
%     %texture map data for surface
%     slice = squeeze(v(:,:,iZ));
%     sliceAlpha = (slice-1)/255;
% 
%     % Position of surface
%     thisX = squeeze( x(:,:,iZ));
%     thisY = squeeze( y(:,:,iZ));
%     thisZ = squeeze( z(:,:,iZ));
% %     
% % %     tX = [min(thisX(:)) max(thisX(:))];
% % %     tY = [min(thisY(:)) max(thisY(:))];
% % %     tZ = [min(thisZ(:)) max(thisZ(:))];
% % 
% %     tX = [thisX(1,1) thisX(end,end)];
% %     tY = [thisY(1,1) thisY(end,end)];
% %     tZ = [thisZ(1,1) thisZ(end,end)];
% % 
% %     [thisX thisY thisZ] = meshgrid(tX,tY,tZ);
% % 
% %     thisX = linspace(x(1,1,iZ), x(end,end,iZ),nP);
% %     thisY = linspace(y(1,1,iY), y(end,end,iZ),nP);
% %     thisZ = squeeze(z(1,1,iZ))*ones(nP);
%     
% %     h(hIdx) = surface(x,y,z,'Parent',ax);   
% %     set(h(hIdx),'cdatamapping','scaled','facecolor','texture','cdata',slice,...
% %         'edgealpha',0,'alphadata',double(slice),'facealpha','texturemap');
% 
% 
%     % Display Surface
%     h(hIdx) = surface(thisX,thisY,thisZ, slice,'FaceColor','texturemap', ...
%         'FaceAlpha','texturemap','EdgeColor','none', 'AlphaData',sliceAlpha, ...
%         'AlphaDataMapping','none','CDataMapping','direct');
%     
%     hIdx = hIdx+1;
%     
% end
% 





% function obj = setupVolumeSliceObject(varargin)
% %This function sets and parses options for drawing functions
% % pass in key value pairs to set options.
% %
% % key, default value, description
% %'subjId', [], subject id to draw ex. 'skeri0001'
% %'surfName','inner skull', which surface to draw
% %'surfReflectance',[0 1 0], surface reflectane values for patch
% %'surfAlpha',.4);
% %'surfColor',[]);
% %'patchOptions',[]);
% % 
% 
% p = inputParser;
% 
% %p.KeepUnmatched = true;
% 
% p.addParamValue('subjId', [], @ischar);
% 
% p.addParamValue('volName','vAnataomy.dat');
% p.addParamValue('reflectance',[0 1 0]);
% p.addParamValue('alpha',1);
% p.addParamValue('options',[]);
% 
% p.addParamValue('xIndices',128);
% p.addParamValue('yIndices',128);
% p.addParamValue('zIndices',128);
% 
% 
% p.parse(varargin{:});
% 
% optns = p.Results;
% 
% if isempty(optns.subjId)
%     error('Subject ID not set correctly!')
% end
% 
% obj = optns;
% 
% [obj.volData,obj.x,obj.y,obj.z] = readDefaultMri(p.Results.subjId);




