function [trialData oriSequence] = readPowerDivaLog(filename)


fid = fopen(filename,'r');

if isempty(fid)
    error(['Error opening file'])
end

%Get end of file
fseek(fid,0,1);
eofLoc = ftell(fid);
fseek(fid,0,-1);

idx = 1;
while (ftell(fid)<eofLoc)
    
    [oriList c] = fscanf(fid,'o %f o %f\n');
    [response c] = fscanf(fid,'%d\t%c\t%f\n');
    
    
    trialData(idx,:) = response;
    oriSequence(idx,:) = oriList;
    idx = idx+1;
end

fclose(fid);