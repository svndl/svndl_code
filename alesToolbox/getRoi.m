function [roi] = getRoi(subjId,roiName)


anatDir = getpref('mrCurrent','AnatomyFolder');


subjRoiDir=fullfile(anatDir,subjId,'Standard','meshes','ROIs');

roiFilename = fullfile(subjRoiDir,[ roiName '.mat']);

if ~exist(roiFilename,'file')
    error(['Cannot find ROI: ' roiName ' in: ' subjRoiDir]);
end


load(roiFilename);

roi = ROI;

