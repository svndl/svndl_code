function [h] = drawVolume(x,y,z,v,varargin)
%function [handle] = drawVolume(x,y,z,v,varargin)
%
%Calling syntax:
%

hIdx = 1;
nP = 10;

%scale v to index directly into colormap 
v = (v-min(v(:)))/range(v(:)); %scaled from 0-1
v = fix(255*v+1); %1-256
%v = uint8(v);

cmap = jmaColors('arizona',[],256);
colormap(cmap);


for iX = 1:size(v,1),
    
    
    %texture map data for surface
    slice = squeeze(v(iX,:,:));
    sliceAlpha = (slice-1)/255;
%    sliceAlpha(slice==1) = 0;
    
    % Position of surface
    thisX = squeeze( x(iX,:,:));
    thisY = squeeze( y(iX,:,:));
    thisZ = squeeze( z(iX,:,:));
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
% 
% 
% 
% 
