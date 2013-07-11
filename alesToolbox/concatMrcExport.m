function [outWave outSpec outList] = concatMrcExport(gD,sbjList,condList,gSbjROIFiles,roiList,inverseName)
%function [outWave outSpec] = concatMrcExport(gD,sbjList,condList,[gSbjROIFiles],[roiList],[inverseName])
%
%This function creates 1 big matrix out of mrCurrent exported data
%structures.
%
%If called with the first 3 arguments it will return sensor space data,
%use all input arguments to return ROI space data.
%
%Example For sensor space output:
%
%[sensW sensS] = concatMrcExport(gD,gChartFs.Sbjs.Items,gChartFs.Cnds.Items);
%
% senseW = nSubjects x nConditions x nTimeSamples x nElectrodes
% senseS = nSubjects x nConditions x nFrequencies x nElectrodes
%
%Example for ROI space output:
%
%[roiW roiS] = concatMrcExport(gD,gChartFs.Sbjs.Items,gChartFs.Cnds.Items,gSbjROIFiles,gChartFs.ROIs.Items(1:10),inverseName);
%
% roiW = nSubjects x nConditions x nRois x hemiIndex x nTimeSamples 
% roiS = nSubjects x nConditions x nRois x hemiIndex x nFrequencies 
%
%hemiIndex: 1 = left hemisphere
%           2 = right hemisphere
%           3 = bilat combination


nSbj = length(sbjList);
nCon = length(condList);

nHem = 3;
[nT nE] = size(gD.(sbjList{1}).(condList{1}).Exp_MATL_HCN_128_Avg.Wave.none);
[nF nE] = size(gD.(sbjList{1}).(condList{1}).Exp_MATL_HCN_128_Avg.Spec);

waveData = zeros(nSbj,nCon,nT,nE);
specData = zeros(nSbj,nCon,nF,nE);

for iN = 1:length(sbjList);
    for iC = 1:length(condList),
        waveData(iN,iC,:,:) = gD.(sbjList{iN}).(condList{iC}).Exp_MATL_HCN_128_Avg.Wave.none;
        specData(iN,iC,:,:) = gD.(sbjList{iN}).(condList{iC}).Exp_MATL_HCN_128_Avg.Spec;
    end
end

if nargin < 4,
    outWave = waveData;
    outSpec = specData;

else
    nRoi = length(roiList);
    
    
    outWave = zeros(nSbj,nCon,nRoi,nHem,nT);
    outSpec = zeros(nSbj,nCon,nRoi,nHem,nF);
    for iN = 1:length(sbjList),
        for iC = 1:length(condList),
            for iR = 1:length(roiList),
                for iH =1:3,

                   % [(sbjList{iN}) ' ' (condList{iC}) ' ' roiList{iR}]
                    roiName = roiList{iR};
                    roiIdx = strcmp( gSbjROIFiles.(sbjList{iN}).Name, roiName );
                    
                    outList{iN,iR} = roiName;
                    invM = squeeze(gD.(sbjList{iN}).ROI.(inverseName).Mean(:,roiIdx,iH));

                    outWave(iN,iC,iR,iH,:) = squeeze(waveData(iN,iC,:,:))*invM;

                    outSpec(iN,iC,iR,iH,:) = squeeze(specData(iN,iC,:,:))*invM;
                   % pause
                    %  outWave(iN,iC,iR,:,:) = gD.(sbjList{iN}).(condList{iC}).ROI.(inverseName).Wave.none.Bilat.(roiList{iR});
                    %  outSpec(iN,iC,iR,:,:) = gD.(sbjList{iN}).(condList{iC}).ROI.(inverseName).Spec.Bilat.(roiList{iR});
                end
            end
        end
    end


end
