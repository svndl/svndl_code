names = dir('/Volumes/Denali_MRI/anatomy/skeri*');
for i=1:length(names)
    subjList{i} = names(i).name;
end

subjList = {'skeri0009'}

roiList = {'V1'}
hemiName = {'-L' '-R'};
hemiLongName = {'left' 'right'};
cp(1,:)=[0.8   -0.27   -0.02];
cp(2,:)=[ -0.8   -0.27   -0.02];

ct=[0   -0.06    0.04];

for iSubj = 1:length(subjList),
for iRoi = 1:length(roiList),
    
    roiDir = fullfile(getpref('mrCurrent','AnatomyFolder'),subjList{iSubj},'Standard','meshes','ROIs');
   
    for iHemi = 1:2,
        figure(100+iHemi)
        clf;
        roiFile = fullfile(roiDir,[roiList{iRoi} hemiName{iHemi} '.mat']);
        
        if ~exist(roiFile,'file')
            continue;
        end
        load(roiFile);
        
        roiLabel = ones(20484,1);
        roiLabel(ROI.meshIndices,:) = 2;
        
        isRight=(1-(iHemi-1));
        thisHemiAlpha = [ isRight*ones(10242,1); (1-isRight)*ones(10242,1)];
        cH = drawAnatomySurface(subjList{iSubj},'cortex');
        vertices = get(cH,'vertices');
        roiMean = mean(vertices(ROI.meshIndices,:),1);
      %  set(gca,'view',[-(2*iHemi-3)*90 0])
      cp(iHemi,2:3) = roiMean(2:3);
      campos(cp(iHemi,:));
      camtarget(roiMean);%camtarget(ct);
      
      set(cH,'faceVertexAlphaData',thisHemiAlpha,'facealpha','interp', ...
          'facevertexCData',roiLabel,'CDataMapping','direct','facecolor','interp');
      colormap( [.8 .8 .8;1 0 0]);
      material([.3 .5 0 .2]);
%    light('position',[0 .707 .707],'style','infinite')
%    light('position',[0 -.707 .707],'style','infinite')
    light('position',[0 0 1],'style','local')
    lighting phong
    set(gcf,'color','w')
    camproj('orthographic');grid minor;
    th=text(roiMean(1),roiMean(2),roiMean(3)-.03,[subjList{iSubj} ' ' hemiLongName{iHemi} ' hemisphere']);
    set(th,'fontsize',20);
    set(gcf,'position',[54 179 900 747]);
    ylabel('Distance in Meters')
%      filename = ['withGrid_' subjList{iSubj} '_' roiList{iRoi} hemiName{iHemi} '.png'];
%      saveas(gcf,filename);

    end
end

%     if ~exist(roiFile,'file')
%             continue;
%     end
%     pause;

end
