function params = skeriDefaultSimParameters()
% function params = skeriDefaultSimParameters()
% 
%The following are the default paramaters along with a description
%
% params.activeRoiList = {'V1-L'  'V1-R'  'LOC-L'  'LOC-R'};
% activeRoiList is a cell array of the names of the ROIs to simulate
% the ROI must exist in the subjects directory.
% 
% params.roiHarm = {[1]  [0 0 + 1.0000i]  [0 0 1]  [0 0 0 1]};
% roiHarm is a slightly tricky one. It is a cell array containing vectors
% of complex values that index into harmonics. The value is the current
% source density put in the roi
% e.g. [1]      -> 1 at 1f1 @ 0 phase angle
%      [1i]     -> 1 at 1f1 @ 90 phase angle
%      [ 0 1]   -> 1 at 2f1 @ 0 phase angle
%      [ 0 0 1i] -> 1 at 3f1 @ 90 phase angle
%
%
% params.condNumber = 901;
% condNumber is the name given to the axx file: Axx_c901.mat
%
%
% params.stepTimeByRoi = true;
% stepTimeByRoi makes a synthetic time function.
% If it is false the time domain data is constructed from the chosen
% harmonics
% if it is true the time domain is just uniform activation of each roi in
% order. 
%
% params.roiTime is not set by default
% Please read the following and be carefull with this parameter.
% if params.stepTimeByRoi is false, and this is non empty the simulator
% will use the waveforms in this cell array to simulate data
% This one is tricky. No error checking is done for the correct number of
% time points. So you must choose those carefully, and they
% MUST be consistent with the other Axx_ datasets!
%
% params.sphereModel = false;
% sphereModel chooses which forward model to use.
% sphereModel = false means use a BEM model
% sphereModel = true means use a spherical head model
% caution: check for the file skeri????/_MNE_/skeri????-sph-fwd.fif
% to ensure spherical model calculations have been done.
% if not run: prepareInversesForMrc again
% 
%
%
% params.noise.type = 'white' 
% noise.type can be either 'white' or 'colored';
% white uses an identity covariance matrix
% colored uses the covariance estimate from powerDiva
%
% params.noise.level = 0;
% noise.level is calculated as a percentage the mean activation in time
% e.g. noise = noise.level*mean(abs(wave(:)))*randn(nT,nElec)
%
% 

params.activeRoiList = {'V1-L'  'V1-R'  'LOC-L'  'LOC-R'};
params.roiHarm = {[1e-4]  [0 complex(0,1e-4)]  [0 0 1e-4]  [0 0 0 [1e-4]]};
params.condNumber = 901;
params.stepTimeByRoi = true;
params.sphereModel = false;

params.noise.type = 'white';
params.noise.level = 0;

