function [index samplingDistance] = sampleMesh(conMat,nPoints,seedList),

%function [index] = sampleMesh(conMat,nPoints),
%
%
%

index = [];
d = dijkstra(conMat,seedList(1));
    
spacing = 1.1*max(d(~isinf(d)))/sqrt(nPoints)
   
hemiConMat{1} = conMat(1:10242,1:10242);
hemiConMat{2} = conMat(10243:end,10243:end);

%This indexes vertices before we delete them.

origConMat = conMat;

for iSeed = 1:length(seedList),
    
 
    conMat = origConMat;
    %    conMat = hemiConMat{iSeed};
    d = dijkstra(conMat,seedList(iSeed));
 
    removeThese = isinf(d);
    
    vertIdx = 1:length(conMat);

    vertIdx = vertIdx(~removeThese);
    
    conMat = conMat(~removeThese,~removeThese);

    nextVert = find(vertIdx == seedList(iSeed) )
    index = [index vertIdx(nextVert)];
    
    for i=1:nPoints,
%        while i<=nPoints,

%            if 

        d = dijkstra(conMat,nextVert);


        removeThese = [(d<spacing)];
        

        %Next step is closest point to the current step.
        thisVert = nextVert;
%        [minLeft nextVert]  = min(    d(~removeThese & d>spacing) );
        %nextVert = find(d==minLeft);

        
%         %If we become disconnected 
%         if any(~isinf(d(d>2e-15)))
% 
%             %Next step is farthest point to the current step.
            nextVert = find(d(~removeThese)==max(d(~removeThese)));
% 
%             
%         end
        

%         if isempty(nextVert)
%             removeThese = thisVert;
%             conMat = conMat(~removeThese,~removeThese);
%             continue;
%         end
%         

         nextVert = nextVert(1);
%         if minLeft<spacing,
%             keyboard;
%         end


%        if d(nextVert) < .5*spacing,
            
        %    conMat(~removeThese,~removeThese) = Inf;
        conMat = conMat(~removeThese,~removeThese);
        index = [index vertIdx(nextVert)];
        vertIdx = vertIdx(~removeThese);
        
        

    end
end

    

samplingDistance = inf(length(index));

for i=1:length(index)
    
    d = dijkstra(origConMat,index(i));
    
    samplingDistance(i,:) = d(index);
    samplingDistance(i,i) = inf;
    
end

    
    
     
    
%initialSamp = unique(round(linspace(1,length(conMat),nPoints)));



function pd = pairwiseDist(conMat,initialSamp)

dist



