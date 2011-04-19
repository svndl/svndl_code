%%

flankerData = importdata('~/Downloads/Flanker_Deadline_Data_06_15_10.txt');


%Function handle for a logistic curve
psiLogistic = @(mu,t)(mu(3) + (1-mu(3))*(1./(1+exp(-mu(1).*((t/1000)-mu(2))))));

subjectList = unique(flankerData.data(:,1))
figure(43)


colorList = get(gca,'ColorOrder');

colorList = [ 0 0 0; ... 
              0 0 0; ...
              0 0 0; ...
              0 0 0; ...
              .7 .7 0; ...
              .7 .7 0; ...
              .7 .7 0; ...
              .7 .7 0;];
              
for iSubj=1:length(subjectList),
    
    selection = (flankerData.data(:,1)==subjectList(iSubj))&(flankerData.data(:,2)==2);
    
    %Deadline plus RT = total time to button
    totalTime = flankerData.data(selection,4)+flankerData.data(selection,5);
    
    isHit = flankerData.data(selection,6);
    
    beta(iSubj,:) = nlinfit(totalTime,isHit,psiLogistic,[1e-3 500]);
    
    xVals = linspace(0, 1500,1500);


    yhat = psiLogistic(beta(iSubj,:),xVals);
 %   plot(xVals,yhat,'color',colorList(iSubj,:))
    plot(xVals,yhat,'color','r')
    hold on;
%plot(totalTime,isHit,'k.')
end


%%
    
clear bFE PSI1 stats1 bRE;

for iEye = 1:3,
    for iTrial = 1:2,
       [iEye iTrial]
       
       eyeCode = iEye-1;
       trialCode = iTrial-1;
       
       selection = (flankerData.data(:,2)==eyeCode)&(flankerData.data(:,3)==trialCode);
       totalTime = flankerData.data(selection,4)+flankerData.data(selection,5);
       isHit = flankerData.data(selection,6);
       
       [bFE{iEye,iTrial},PSI1{iEye,iTrial},stats1{iEye,iTrial},bRE{iEye,iTrial}] = nlmefit(totalTime,isHit,flankerData.data(selection,1),...
           [],psiLogistic,[1 .5 .5])
    end
end


bFE_totaltime = bFE 
PSI1_totaltime = PSI1; 
stats1_totaltime = stats1; 
bRE_totaltime = bRE;

bFE = bFE_totaltime; 
PSI1 = PSI1_totaltime; 
stats1 = stats1_totaltime; 
bRE = bRE_totaltime;




%% Fit binned by deadline


for iEye = 1:3,
    for iTrial = 1:2,
       [iEye iTrial]
       
       eyeCode = iEye-1;
       trialCode = iTrial-1;
       
       selection = (flankerData.data(:,2)==eyeCode)&(flankerData.data(:,3)==trialCode);
       totalTime = flankerData.data(selection,4);
       isHit = flankerData.data(selection,6);
       
       [bFE_deadline{iEye,iTrial},PSI1_deadline{iEye,iTrial},stats1_deadline{iEye,iTrial},bRE_deadline{iEye,iTrial}] = nlmefit(totalTime,isHit,flankerData.data(selection,1),...
           [],psiLogistic,[1 .5 .5])
    end
end

bFE = bFE_deadline;
PSI1 = PSI1_deadline; 
stats1 = stats1_deadline;
bRE = bRE_deadline;


%% plot fits
figure(43)

iTrial = 1;
deadlines = unique(flankerData.data(:,4));

colorList = [0 0 0; 1 0 0; 0 0 1];
for iEye = 1:3,
    
    eyeCode = iEye-1;
    trialCode = iTrial-1;
    selection = (flankerData.data(:,2)==eyeCode)&(flankerData.data(:,3)==trialCode);
    totalTime = flankerData.data(selection,4)+flankerData.data(selection,5);
    isHit = flankerData.data(selection,6);
    

    deadlineReactMean = grpstats(flankerData.data(selection,5),flankerData.data(selection,4));
    hitRateMean = grpstats(isHit,flankerData.data(selection,4));
    hitRateCI = grpstats(isHit,flankerData.data(selection,4),'meanci');
    hitRateCI = hitRateMean-hitRateCI(:,1);
    
    yhat = psiLogistic(bFE{iEye,iTrial},xVals);

   % errorbar(deadlines+deadlineReactMean,hitRateMean,hitRateCI,'x','color',colorList(iEye,:))
    hold on;
    plot(xVals,yhat,'-','color',colorList(iEye,:))

end

    

%%  plot fits by subject
figure(47)
clf

deadlines = unique(flankerData.data(:,4));

colorList = [0 0 0; 1 0 0; 0 0 1;.7 .7 0;1 0 1; 0 1 1];
for iEye  = 2,
       
    eyeCode = iEye-1;
    selection = (flankerData.data(:,2)==eyeCode);
    
    subjList = unique(flankerData.data(selection,1));


    for iSubj = 1:length(subjList),

        selection = (flankerData.data(:,1)==subjList(iSubj))&(flankerData.data(:,2)==eyeCode);

        totalTime = flankerData.data(selection,4)+flankerData.data(selection,5);
        isHit = flankerData.data(selection,6);
    
        deadlineReactMean = grpstats(totalTime,flankerData.data(selection,4));
        hitRateMean = grpstats(isHit,flankerData.data(selection,4));
        hitRateCI = grpstats(isHit,flankerData.data(selection,4),'sem');
       % hitRateCI = hitRateMean-hitRateCI(:,1);
    
        yhat = psiLogistic(bFE{iEye}+bRE{iEye}(:,iSubj),xVals);

        errorbar(deadlineReactMean,hitRateMean,hitRateCI,'o-','color',colorList(iSubj,:))
        hold on;
        plot(xVals,yhat,'-','color',colorList(iSubj,:))
    end
    
end
    
%%  plot fits by subject
figure(51)
clf
deadlines = unique(flankerData.data(:,4));
iTrial =2;
trialCode = iTrial-1;

colorList = [0 0 0; 1 0 0; 0 0 1;.7 .7 0;1 0 1; 0 1 1];
for iEye  = 3,
       
    eyeCode = iEye-1;
    selection = (flankerData.data(:,2)==eyeCode)&(flankerData.data(:,3)==trialCode);
    
    subjList = unique(flankerData.data(selection,1));


    for iSubj = 1:length(subjList),

        selection = (flankerData.data(:,1)==subjList(iSubj))&(flankerData.data(:,2)==eyeCode)&(flankerData.data(:,3)==trialCode);

        totalTime = flankerData.data(selection,4)+flankerData.data(selection,5);
        isHit = flankerData.data(selection,6);
    
        deadlineReactMean = grpstats(totalTime,flankerData.data(selection,4));
        hitRateMean = grpstats(isHit,flankerData.data(selection,4));
        hitRateCI = grpstats(isHit,flankerData.data(selection,4),'sem');
       % hitRateCI = hitRateMean-hitRateCI(:,1);
    
        yhat = psiLogistic(bFE{iEye,iTrial}+bRE{iEye,iTrial}(:,iSubj),xVals);

        errorbar(deadlineReactMean,hitRateMean,hitRateCI,'o-','color',colorList(iSubj,:))
        hold on;
        plot(xVals,yhat,'--','color',colorList(iSubj,:))
    end
    
end
    

