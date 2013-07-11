%%
%mrcProjDir = '/Volumes/Denali_4D2/4D2/RBOatten/ButtonLockAnalysis/withRespData'
%mrcProjDir = '/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj'
mrcProjDir = '/Volumes/Denali_4D2/4D2/Disparity/Disparity_decision_making/Decision_making/ready_to_go_jma'
anatDir = getpref('mrCurrent','AnatomyFolder');

subjList = dir([ mrcProjDir filesep 'skeri*']);

%Skeri0060 has no LOC defined.
validSubj = ~strcmp('skeri0060',{subjList.name});
subjList = subjList(validSubj);
%Should I save figure files?
writeOutput = true;

%Using silly cell of cells structure because I'm lazy,

%ROIs = {'V1-L.mat' 'V1-R.mat'};
%ROIs = {'V3V-L.mat' 'V3V-R.mat' 'V3D-L.mat' 'V3D-R.mat'};
roiList = {...
    {'V1-L.mat' 'V1-R.mat'} ...
    {'V2V-L.mat' 'V2V-R.mat' 'V2D-L.mat' 'V2D-R.mat'} ...
    {'V3V-L.mat' 'V3V-R.mat' 'V3D-L.mat' 'V3D-R.mat'} ...
    {'V3A-L.mat' 'V3A-R.mat'} ...
    {'V4-L.mat' 'V4-R.mat'} ...
    {'LOC-L.mat' 'LOC-R.mat'} ...
    {'MT-L.mat' 'MT-R.mat'} ...
    {'temporalpole-L.mat' 'temporalpole-R.mat'} ...    
    };

roiList = {...
    {'frontalpole-L.mat' 'frontalpole-R.mat'} ...    
    };


%This loop is going in the slow way. Should do all ROI's per subject. But
%again. Lazy.
for iRoi = 1:length(roiList),
    ROIs = roiList{iRoi};
    meanDat = zeros(128,1);

for iSubj = 1:length(subjList),
    
    subjID = subjList(iSubj).name
    

    thisFwd = mrC_getFwdMatrix(fullfile(mrcProjDir,subjID,'_MNE_',[subjID,'-fwd.fif']),subjID);
    
    thisDat = zeros(128,1);
    for iRoi = 1:length(ROIs),
        
    roi = load( fullfile(anatDir,subjID,'Standard','meshes','ROIs',ROIs{iRoi}) );
    S = zeros(20484,1);
    S(roi.ROI.meshIndices) = 1;
    thisDat = thisFwd*S+thisDat;
    end

    meanDat = meanDat+thisDat;
end

meanDat = meanDat/length(subjList);
meanDat = meanDat/1000; %Arbitrary scale fo nice numbers

figure(501);
clf;
plotOnEgi(meanDat)
caxis([-max(abs(meanDat)) max(abs(meanDat))]);
colorbar;
titleText = [ROIs{1}(1:end-4)];
for i = 2:length(ROIs),
   titleText= [titleText ' + ' ROIs{i}(1:end-4)];
end
title(titleText);


if writeOutput == true
    filename = ['flatTopo_' ROIs{1}(1:end-6)];
    saveas(gcf,filename,'fig');
    saveas(gcf,filename,'psc2');
end

end

