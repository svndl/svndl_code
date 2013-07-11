function [] = writeForR(filename,data,labels,headings)
%function [] = writeForR(filename,data,labels,headings)
%
%THIS IS FUNKY!
%I need to come up with a better mechanism. JMA

fid = fopen(filename,'w')

if fid ==-1
    error(['Cannot open file: ' filename])
    return;
end


nLabels = length(labels);

dataSize = size(data);
dataDims = ndims(data);

%headString = ['Amp\t'];

headString = [];

for iHead = 1:length(headings)
    headString = [headString headings{iHead} '\t'];
end
headString = [headString '\n'];
    
fprintf(fid,headString);
%sprintf(headString);



for i=1:size(data(:),1)   
        
    
    thisDat = data(i);
    fprintf(fid,'%f',thisDat);
%    sprintf('%f',thisDat);
    

    labelIdx = cell( 1, dataDims );
    
    [labelIdx{:}] = ind2sub(dataSize,i);
    
    for iLabel=1:nLabels,

        thisLabel = labels{iLabel}{labelIdx{iLabel}};
        fprintf(fid,'\t%s',thisLabel);
       % sprintf('\t%s',thisLabel);
                
    end
    
   fprintf(fid,'\n');
   % sprintf('\n');
    
    
%    fprintf(fid,'%f\t%s\t%s\t%s\t%s\n',thisMag,labelData{i,2},labelData{i,3},labelData{i,4},labelData{i,5});
    
end
fclose(fid);
