%%
figure(100);
clf
bestFitElec = rigidRotate(X,electrodes);

scatter3(bestFitElec(:,1),bestFitElec(:,2),bestFitElec(:,3));
hold on;

elec2plot = [17 75];
scatter3(bestFitElec(elec2plot,1),bestFitElec(elec2plot,2),bestFitElec(elec2plot,3),20,'filled','o');

for i=1:size(tst,1),
    
    thisRes(i) = sum(rotcostfunclsq(tst(i,:),stationaryPoints,electrodes,headshape,N).^2);
    
    if thisRes(i)>2*RESNORM && thisRes(i) > 1.5*RESNORM,
        i
        continue;
    end

    movedElec = rigidRotate(tst(i,:),electrodes);


    scatter3(movedElec(elec2plot,1),movedElec(elec2plot,2),movedElec(elec2plot,3),3,'k.');
    drawnow;
end





%%

figure(101)
clf
bestFitElec = rigidRotate(X,electrodes);

scatter3(bestFitElec(:,1),bestFitElec(:,2),bestFitElec(:,3));
hold on;

elec2plot = [17 75];
scatter3(bestFitElec(elec2plot,1),bestFitElec(elec2plot,2),bestFitElec(elec2plot,3),20,'filled','o');


CI = nlparci(X,RESIDUAL,'jacobian',.5*JACOBIAN)
nP=10;
idx = 1;
for iPar =1:length(CI),
    
    thisParLo = CI(iPar,1);
    thisParHi = CI(iPar,2);
    %    parSamp(iPar,:) = linspace(CI(iPar,1),CI(iPar,2),nP);

    
    thisXLo = X;
    thisXHi = X;

    thisXLo(iPar) = thisParLo;
    thisXHi(iPar) = thisParHi;

    movedElecLo = rigidRotate(thisXLo,electrodes);
    movedElecHi = rigidRotate(thisXHi,electrodes);

    dist(iPar) = max(sqrt(sum((movedElecLo(:,:)-movedElecHi(:,:)).^2,2)))
    
    
    
    for iElec = elec2plot,
        
        line2plot = [ movedElecLo(iElec,:); ...
            movedElecHi(iElec,:)];
    
       
        line(line2plot(:,1),line2plot(:,2),line2plot(:,3));
    end
%    allResid(iPar,iPar2,iSamp,iSamp2) = sum(rotcostfunclsq(thisX,stationaryPoints,electrodes,headshape,N).^2);
  
    drawnow;
end






%%

figure(101)
clf
bestFitElec = rigidRotate(X,electrodes);

scatter3(bestFitElec(:,1),bestFitElec(:,2),bestFitElec(:,3));
hold on;

elec2plot = [17 75];
scatter3(bestFitElec(elec2plot,1),bestFitElec(elec2plot,2),bestFitElec(elec2plot,3),20,'filled','o');


CI = nlparci(X,RESIDUAL,'jacobian',JACOBIAN)
nP=10;
idx = 1;
for iPar =1:length(CI),
    
    thisPar = linspace(CI(iPar,1),CI(iPar,2),nP);
    %    parSamp(iPar,:) = linspace(CI(iPar,1),CI(iPar,2),nP);

    for iPar2 = setdiff([1:length(CI)],iPar),
    thisPar2 = linspace(CI(iPar2,1),CI(iPar2,2),nP);
  
    iPar2
    for iSamp = 1:length(thisPar),
        iSamp
        for iSamp2 = 1:length(thisPar2),
            thisX = X;
            thisX(iPar) = thisPar(iSamp);
            thisX(iPar2) = thisPar2(iSamp2);

            movedElec = rigidRotate(thisX,electrodes);


            scatter3(movedElec(elec2plot,1),movedElec(elec2plot,2),movedElec(elec2plot,3),3,'filled','ko');
         
            allResid(iPar,iPar2,iSamp,iSamp2) = sum(rotcostfunclsq(thisX,stationaryPoints,electrodes,headshape,N).^2);
  
            drawnow;
        end
    end

    end
end








%% Stan way
data =electrodes;
chisqLSQ=sum(zLSQ.^2);      %the chi square of the fit (Goodness of fit parameter)
disp(['zdata= ' num2str(zLSQ) ',  chisquare= ' num2str(chisqLSQ)])

j=full(j);	 %The 'full' command converts sparse matrices (whatever that is) into regular matrices
covar=inv(j'*j);  %see Num Recipes and simulations to clarify covariance matrix
seLSQ=sqrt(diag(covar))';   %Standard error
correl=covar./(seLSQ'*seLSQ); %parameter correlations
nParams=length(params);
DegFreedom=length(data)-nParams;
FFactor=sqrt(chisqLSQ/DegFreedom); %Fudge factor (or F value)
disp(['DegFreedom= ' num2str(DegFreedom) ',  Fudge factor = ' num2str(FFactor)])
z =params./seLSQ;            %z-score
t=z./FFactor;                %deviations if SE is estimated from data
disp(' params        SE   SE with Fudge    z-score	t')


for i=1:nParams
    disp([num2str(params(i)) ' +- ' num2str(seLSQ(i)) ' or +- ' ...
        num2str([seLSQ(i)*FFactor z(i) t(i)])])
end


if DegFreedom>0,probChiGamma=1-gammainc(chisqLSQ/2,DegFreedom/2),end %prob that the model fits the data
probz=(1-erf(z/sqrt(2)))/2   %probability that parameter is zero
Ftest=t.^2                  %F value
if DegFreedom>0,probF= 1-betainc(1 ./(1+Ftest/DegFreedom),DegFreedom/2,1/2 ),end

