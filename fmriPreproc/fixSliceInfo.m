function [ output_args ] = fixSliceInfo( validFile, fileToFix )
%fixSliceInfo Quick hack file to fix FSL mangling of nifti header
% Replaces the following fields in "fileToFix" with the values from "validFile"
%     'freq_dim'
%     'phase_dim'
%     'slice_dim'
%     'slice_code'
%     'slice_code_name'
%     'slice_start'
%     'slice_end'
%     'slice_duration'};

fieldsToFix = { ...
    'freq_dim'
    'phase_dim'
    'slice_dim'
    'slice_code'
    'slice_code_name'
    'slice_start'
    'slice_end'
    'slice_duration'};

[pathName0,fileName0] = filepartsgz( validFile);
[pathName1,fileName1] = filepartsgz( fileToFix);

file0 = fullfile(pathName0,fileName0);
file1 = fullfile(pathName1,fileName1);

fileTxt = fullfile(pathName1,'temp-hdr.txt');


verbose = 1;
         
hdValid = getFSLhdStruct(validFile);
hdToFix = getFSLhdStruct(fileToFix);

runSystemCmd( sprintf('fslhd -x %s > %s',file1,fileTxt));

wasMissing = false;
wasDifferent = false;

for iField = 1:length(fieldsToFix)
    parName = fieldsToFix{iField};
    
    if ~isfield(hdValid,parName)
        disp(['Skipping field because valid file does not contain field name: ' parName ]);
        
        continue;
    end
    
    parVal = hdValid.(parName);

%    [parName ' = ' parVal]
    

    if isempty(strfind(runSystemCmd( sprintf('cat %s',fileTxt) ),[parName,' = ']))		% strfind or regexp work

%        display([parName ' is not a header element, adding to file'])   
        addXmlHeaderElement(fileTxt,parName,parVal);
        wasMissing = true;
        
    elseif ~strcmp(hdValid.(parName),hdToFix.(parName))
        runSystemCmd( sprintf('cat %s | sed "s/%s = .*/%s = \\''%s\\''/" > %s',fileTxt,parName,parName,parVal,fileTxt), verbose )
        wasDifferent = true;
    end

    
end

if wasDifferent || wasMissing
    disp('Found mangled header, fixing')
    runSystemCmd( sprintf('fslcreatehd %s %s',fileTxt,file1), verbose )
    runSystemCmd( sprintf('rm %s',fileTxt), verbose )
else
    disp(['Not fixing because header info in file: ' fileToFix ' matches file: ' validFile])
end



end

