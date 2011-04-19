%%

chosenOnes = [];
count=1;
conMatNew = conMat;
conMatHop = conMatSpaced;
index = 1:length(conMat);

thisChoice = 1;
chosenOnes = thisChoice;
chomping = true;
while chomping    
%  count
%     figure(100+count)
%     imagesc(conMatNew(1:10,1:10))
%     figure(200+count)
%     imagesc(conMatHop(1:10,1:10))
%      pause
%      
    % hopsAway = conMatHop(i,:);
     
     
     lastChoice = max(1,length(chosenOnes));
%      chomped(chosenOnes(lastChoice)) = 1;
     conMatNew(chosenOnes(lastChoice),chosenOnes(lastChoice)) =0; 
     conMatHop(chosenOnes(lastChoice),chosenOnes(lastChoice)) =0; 

    thisChomp = conMatNew(thisChoice,:);
    thisChoice = find(conMatHop(thisChoice,:) & ~thisChomp);
     


     chomped = thisChomp;
     
    
     chomped
     thisChoice
     thisChoice = thisChoice(end)
     
 
     conMatNew(chomped,:) = 0;
     conMatNew(:,chomped) = 0;

     conMatHop(chomped,:) = 0;
     conMatHop(:,chomped) = 0;
     
%      index = index(~removeThese);     
%      chosenOnes = [chosenOnes index(thisChoice)] ;
     chosenOnes = [chosenOnes thisChoice] ;
     

     
     if nnz(conMat)<6
         chomping = false;
     end
    
     count = count+1;
end
