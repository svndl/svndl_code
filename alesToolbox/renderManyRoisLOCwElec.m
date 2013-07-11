%names = dir('/Volumes/Denali_MRI/anatomy/skeri*');
names = dir('/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj/skeri*');
mrcProjDir = '/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj/';
outputDir = '/Volumes/Denali_4D2/4D2/JMA_PROJECTS/LOCRender';
for i=1:length(names)
    subjList{i} = names(i).name;
end



%subjList = {'skeri0009'}

roiList = {'LOC'}
hemiName = {'-L' '-R'};
hemiLongName = {'left' 'right'};
% hemiName = {'-R'};
% hemiLongName = { 'right'};

cp(1,:)=[-0.8   -0.27   -0.02];
cp(2,:)=[ 0.8   -0.27   -0.02];

cp(1,:)=[-1.8   -0.05   0.07];
cp(2,:)=[ 1.8   -0.05   0.07];

ct=[0   -0.06    0.04];

roiColor=[1 0.5716 0.0918];

elecList = {59 91};
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
      colormap( [.8 .8 .8;roiColor]);
      material([.3 .5 0 .2]);
%    light('position',[0 .707 .707],'style','infinite')
%    light('position',[0 -.707 .707],'style','infinite')
    light('position',[0 0 1],'style','local')
    lighting phong
    set(gcf,'color','w')
%    camproj('orthographic');grid minor;
    camproj('perspective')
    axis off;
  %  th=text(roiMean(1),roiMean(2),roiMean(3)-.03,[subjList{iSubj} ' ' hemiLongName{iHemi} ' hemisphere']);
  %  set(th,'fontsize',20);
    set(gcf,'position',[54 179 900 747]);
    ylabel('Distance in Meters')
    
    elecLocs = getRegisteredElectrodeLocations(subjList{iSubj}, mrcProjDir )
    hold on;
    elecLocs = elecLocs/1000;
    eh=scatter3(elecLocs(elecList{iHemi},1),elecLocs(elecList{iHemi},2),elecLocs(elecList{iHemi},3),800,'kx');
    set(eh,'linewidth',4);
    sh=drawAnatomySurface(subjList{iSubj},'scalp-hires')
      filename = ['withGrid_' subjList{iSubj} '_' roiList{iRoi} hemiName{iHemi} '.png'];
      filename = fullfile(outputDir,filename);
      saveas(gcf,filename);

    end
end

%     if ~exist(roiFile,'file')
%             continue;
%     end
%     pause;

end
