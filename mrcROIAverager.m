%%
%mrcProjDir = '/Volumes/Denali_4D2/4D2/RBOatten/ButtonLockAnalysis/withRespData'
%mrcProjDir = '/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj'
mrcProjDir = '/Volumes/Denali_4D2/4D2/Disparity/Disparity_decision_making/Decision_making/ready_to_go_jma'
anatDir = getpref('mrCurrent','AnatomyFolder');

subjList = dir([ mrcProjDir filesep 'skeri*']);

ROIs = {'V1-L.mat' 'V1-R.mat'};
%ROIs = {'V3V-L.mat' 'V3V-R.mat' 'V3D-L.mat' 'V3D-R.mat'};
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

meanDat = meanDat/length(subjList)