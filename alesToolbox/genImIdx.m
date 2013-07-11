function [ imIdx ] = genImIdx( i1F1,i1F2,nMax )
%genImIdx Generates IM indexes
%function [ imIdx ] = genImIdx( i1F1,i1F2,nMax )
%
%Given 2 frequencies and a max intermodulation order generates the
%intermodulation products

idxTmp = [];
for n1=1:nMax,
    
    for n2=1:nMax,
        
        idxTmp = [idxTmp n1*i1F1+n2*i1F2 n1*i1F1-n2*i1F2 -n1*i1F1+n2*i1F2];  
    end
end



imIdx = unique(idxTmp);
imIdx = imIdx(imIdx>0);

end

