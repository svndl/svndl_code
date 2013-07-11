function params = skeriDefaultInverseParameters()
% function params = skeriDefaultInverseParameters()
% 
% params.SNR = 100;
% params.jmaStyle = true;
% params.useROIs = false;
% params.areaExp = 1;
% params.extendedSources = false;
% params.sphereModel = false;

params.SNR = 100;
params.jmaStyle = false;
params.gcvStyle = true;
params.ROIs_correlation = false;
params.Quadrants = [1 2 3 4];
params.sphereModel = false;
params.useROIs = false;
params.areaExp = 1;
params.extendedSources = false;
params.saveFullForward = false;


