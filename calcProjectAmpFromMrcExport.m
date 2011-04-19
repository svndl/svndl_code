function [projAmp] = calcProjectAmpFromMrcExport(Y,Ydim)
%function [projAmp] = calcProjectAmpFromMrcExport(Y,Ydim);


nHarm = size(Y,1);
nRoi  = size(Y,2);
nSbj  = size(Y,3);
nCnd  = size(Y,4);
nInv  = size(Y,5);
nType = size(Y,6);
nHemi = size(Y,7);

projAmp = zeros(size(Y));

%Nested loop from hell.
for iHarm = 1:nHarm,
    for iRoi = 1:nRoi,
        for iCnd = 1:nCnd,
            for iInv = 1:nInv,
                for iType = 1:nType,
                    for iHemi = 1:nHemi,
                        
                        thisData = squeeze(Y(iHarm,iRoi,:,iCnd,iInv,iType,iHemi));

                        
                        
                        %Find the mean vector
                        baseVector(1) = real(mean(thisData));
                        baseVector(2) = imag(mean(thisData));
                        
                        %make this unit norm
                        baseVector = baseVector/norm(baseVector);
                        

% Plotting for Debug                        
%                          plot([0 baseVector(1)],[0 baseVector(2)],'-x')
%                          hold on;


                        for iSbj = 1:nSbj,
                            
                            %Individual subject vector.
                            sbjData(1) = real(squeeze(Y(iHarm,iRoi,iSbj,iCnd,iInv,iType,iHemi)));
                            sbjData(2) = imag(squeeze(Y(iHarm,iRoi,iSbj,iCnd,iInv,iType,iHemi)));
                           
                            %Project onto the cross subject mean basis
                            %vector
                            p = (sbjData*baseVector')*baseVector';
%Plotting for Debug                            
%                             plot([p(1) sbjData(1)],[p(2) sbjData(2)],'-xk')
%                             axis equal;
                            %Project this data onto the mean vector, find the length and keep the sign;
                            projAmp(iHarm,iRoi,iSbj,iCnd,iInv,iType,iHemi) = p'*baseVector';
                        
                        end
                        
                        
                        
                        
                    end
                end
            end
        end
    end
end

                        
                        