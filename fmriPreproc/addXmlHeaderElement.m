function addXmlHeaderElement(inFileName,parName,valStr)
% Adds an element to a nifti xml header file 
%
% USAGE: addXmlHeaderElement(inFileName,parName,valStr)
% use xml-style parameter names
% inFileName should be the results from running fslhd -x nifti_file
%

fid = fopen(inFileName,'r+');

if isempty(fid)
    error(['Error opening: %s' inFileName])
end
    
%     
% if isempty(strfind(runSystemCmd( sprintf('fslhd -x %s',file0) ),[parName,' = ']))		% strfind or regexp work
% 	error('%s in not a fslhd -x header element',parName)
% end

lineCount=0;
tline = fgetl(fid);
while ischar(tline)
    lineCount = lineCount+1;
    prevPos = ftell(fid);
    tline =fgetl(fid);
    if strcmp(tline,'/>')
        %disp('found xml close')
        break;
    end
    
end


fseek(fid,prevPos,'bof');

fprintf(fid,'  %s = ''%s''\n',parName,valStr);
fprintf(fid,'/>\n\n');

fclose(fid);
% 
% runSystemCmd( sprintf('fslhd -x %s | sed "s/%s = .*/%s = \\''%s\\''/" > %s',file0,parName,parName,valStr,fileTxt), verbose )
% runSystemCmd( sprintf('fslcreatehd %s %s',fileTxt,file1), verbose )
% runSystemCmd( sprintf('rm %s',fileTxt), verbose )