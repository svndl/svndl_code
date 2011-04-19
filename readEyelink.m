function [data evntSamples]= readEyelink(filename);

fid = fopen(filename);
[c1] = textscan(fid,'%s %*[^\n]');
c1 = c1{1};

% number of lines:
nLine = length(c1)
frewind(fid)

data = NaN*zeros(nLine,7);
evntSamples = [];

lineNum = 1;
while 1

    dataLine = fgetl(fid);
    
    %Break at EOF
    if dataLine == -1
        break
    end
    
    stringParse = strread(dataLine,'%s\t');
    
    %Check for events/header lines)
    if isempty(stringParse)
        continue;
    elseif isnan(str2double(stringParse{1}))
        
        if strcmp(stringParse{1},'BUTTON')
            evntSamples(end+1,1) =  str2double(stringParse{2});
            evntSamples(end,2) =  str2double(stringParse{3});
            evntSamples(end,3) =  str2double(stringParse{4});
        end
        
        %BUTTON	377123	2	1
        continue;
    end
    
    data(lineNum,1) = str2double(stringParse{1});
    if dataLine(end-3)~='C'
        data(lineNum,2) = str2double(stringParse{2});
        data(lineNum,3) = str2double(stringParse{3});
        data(lineNum,4) = str2double(stringParse{4});
    end
    
    if dataLine(end-1)~='C'
        data(lineNum,5) = str2double(stringParse{5});
        data(lineNum,6) = str2double(stringParse{6});
        data(lineNum,7) = str2double(stringParse{7});
    end
        
    if mod(lineNum,1000)==0
        disp([num2str(lineNum) ' Percent Complete: ' round(num2str(lineNum/nLine))]);
    end
    
    lineNum = lineNum+1;
end

        
