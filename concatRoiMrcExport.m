function [outWave outSpec] = concatMrcExport(gD,sbjList,condList)
%function [outWave outSpec] = concatMrcExport(gD,sbjList,condList)



for iN = 1:length(sbjList);
    for iC = 1:length(condList),      
        outWave(iN,iC,:,:) = gD.(sbjList{iN}).(condList{iC}).Exp_MATL_HCN_128_Avg.Wave.none;
        outSpec(iN,iC,:,:) = gD.(sbjList{iN}).(condList{iC}).Exp_MATL_HCN_128_Avg.Spec;               
    end
end
