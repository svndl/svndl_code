function [data header] = importRlsTxt(filename)

%List of fields to read.
fieldList = {'Sr','Si','N1r', 'N1i', 'N2r','N2i',...
    'Signal','Phase','Noise','StdErr','PVal'}


  %iSess	iCond	iTrial	iCh	iFr	AF	xF1	xF2	Harm	FK_Cond	iBin
    %SweepVal	Sr	Si	N1r	N1i	N2r	N2i	Signal	Phase	Noise	StdErr	PVal
  
hdrFields = {
   'iSess'          '%*s\t'
    'iCond'         '%f\t'
    'iTrial'        '%f\t'
    'iCh'           '%*s\t'
    'iFr'           '%f\t'
    'AF'            '%f\t'
    'xF1'           '%f\t'
    'xF2'           '%f\t'
    'Harm'          '%*s\t'
    'FK_Cond'       '%f\t'
    'iBin'          '%f\t'
    'SweepVal'      '%f\t'
    'Sr'            '%f\t'
    'Si'            '%f\t'
    'N1r'           '%f\t'
    'N1i'           '%f\t'
    'N2r'           '%f\t'
    'N2i'           '%f\t'
    'Signal'        '%f\t'
    'Phase'         '%f\t'
    'Noise'         '%f\t'
    'StdErr'        '%f\t'
    'PVal'          '%f\t'
    'SNR'           '%*f\t'
    'LSB'           '%*f\t'
    'RSB'           '%*f\t'
    'UserSc'        '%*s\t'
    'Thresh'        '%*f\t'
    'ThrBin'        '%*f\t'
    'Slope'         '%*f\t'
    'ThrInRange'    '%*s\t'  
    'MaxSNR'        '%*f\t'  };

fid = fopen(filename);

if isempty(fid)
    error(['Cannot open file: ' filename]);
end


tline = fgetl(fid);
header = textscan(tline,'%s','Delimiter','\t');

fmtString = [];
numericIdx = 0;
for iHdr = 1:length(header{1}),
    hdrIdx = strcmp(hdrFields(:,1),header{1}{iHdr});
    hdrFmt = hdrFields{hdrIdx,2};
    fmtString =[fmtString hdrFmt];
    
    if ~strcmp(hdrFmt,'%*s\t') && ~strcmp(hdrFmt,'%*f\t');
        numericIdx = numericIdx+1;
        numericField{numericIdx} = header{1}{iHdr};
       % iField = find(strcmp(fieldList,header{1}{iHdr}))
%         if ~isempty(iField)        
%             fieldStrIdx{iField} = numericIdx;
%         end
    end
end
% fmtString
% numericField
% for iField=1:length(fieldList),
%             fieldStrIdx{iField} =  find(strcmp(header{1},fieldList{iField}));
% end



tline = fgetl(fid);
lineCount = 1;
freqList = [];

nCh = 1;
nTrial = 1;
nBin = 1;

% while ischar(tline)
% %while lineCount < 128*101, %debug purposes
%     
%     textCell = textscan(tline,'%s','Delimiter','\t');
% %    iTrial = localGetNumericField('iTrial')+1;
%     iTrial= str2double(textCell{1}{strcmp(header{1},'iTrial')})+1;
% 
%     nTrial = max(iTrial,nTrial);
%     
%     %iBin = localGetNumericField('iBin')+1;
%     iBin = str2double(textCell{1}{strcmp(header{1},'iBin')})+1;    
%     nBin = max(iBin,nBin);
%     
%     iCh = textCell{1}{strcmp(header{1},'iCh')};
%     iCh = sscanf(iCh,'hc%d-Avg');
%     nCh = max(iCh,nCh);
% 
%     thisFreq = str2double(textCell{1}{strcmp(header{1},'AF')});
%     if ~any(thisFreq==freqList)
%         freqList = [freqList thisFreq];
%     end
%     
%     find(freqList == thisFreq);
%     
% end
% 
% nFr = length(freqList);
% 
for iField=1:length(fieldList),    
     data.(fieldList{iField}) = [];%zeros(16,21,1,128);
    % dataCell{iField} = zeros(16,21,4,128);
     fieldIdxTable(iField) = find(strcmp(numericField,(fieldList{iField})));
end
% 
%dataMat = zeros(16,21,4,128);
%     
% frewind(fid)
% tline = fgetl(fid);

while ischar(tline)
%while lineCount < 128*101, %debug purposes
    
    textCell = textscan(tline,'%s','Delimiter','\t');
    numericData = textscan(tline,fmtString,'delimiter','\t');
    numericData = [numericData{:}];
%    numericData = sscanf(tline,fmtString);
    
    %iSess	iCond	iTrial	iCh	iFr	AF	xF1	xF2	Harm	FK_Cond	iBin
    %SweepVal	Sr	Si	N1r	N1i	N2r	N2i	Signal	Phase	Noise	StdErr	PVal
    
    %Add 1 to go from 0 indexing ala PowerDive, to matlab indexing
    %0th value corresponds to averages
    %iTrial = localGetNumericField('iTrial')+1;
    fieldIdx = strcmp(numericField,'iTrial');
    iTrial = numericData(fieldIdx)+1;
    
    fieldIdx = strcmp(numericField,'iBin');
    iBin = numericData(fieldIdx)+1;
%    iBin = localGetNumericField('iBin')+1;
    
%     if iBin ==1 || iBin==2
%         tline
%         numericData
%         [iBin size(numericData)]
%     end
%     
    
%    iCh = textCell{1}{strcmp(header{1},'iCh')};
    iCh = textCell{1}{strcmp(header{1},'iCh')};
    iCh = sscanf(iCh,'hc%d-Avg');
    
    %iFr = str2double(textCell{1}{strcmp(header{1},'iFr')});
    %thisFreq = str2double(textCell{1}{strcmp(header{1},'AF')});
    fieldIdx = strcmp(numericField,'AF');
    thisFreq = numericData(fieldIdx);

    
    iFr = find(freqList == thisFreq);
    
    if ~any(thisFreq==freqList)
        freqList = [freqList thisFreq];
    end
    
%    fieldSelector = zeros(size(header{1}));
    for iField=1:length(fieldList),
%         data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = ...
%             localGetNumericField(fieldList{iField});
%       data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = ...
%             str2double(textCell{1}{strcmp(header{1},fieldList{iField})});
% data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = ...
%     str2doubleq(textCell{1}{strcmp(header{1},fieldList{iField})});
         
% data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = ...
%     sscanf(textCell{1}{strcmp(header{1},fieldList{iField})},'%f',1);
%     data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = ...
%         sscanf(textCell{1}{fieldStrIdx{iField}},'%f',1);

%    find(fieldIdx)
%    val = str2double(textCell{1}{fieldIdx});
value = numericData(fieldIdxTable(iField));

%value = localGetNumericField((fieldList{iField}));
data.(fieldList{iField})(iTrial,iBin,iFr,iCh)     = value;
 %        dataCell{iField}(iTrial,iBin,iFr,iCh) = value;
 %        dataMat(iTrial,iBin,iFr,iCh) = value;
    
%    str2doubleq(textCell{1}{fieldStrIdx{iField}});
%    sscanf(textCell{1}{fieldStrIdx{iField}},'%f',1);
%    sscanf(textCell{1}{strcmp(header{1},fieldList{iField})},'%f',1);
%         sscanf(s,'%f',1)
%        fieldSelector = fieldSelector | strcmp(header{1},fieldList{iField});
    end

    
    %Going off the rails to try and squeeze some speed out of this code
    
    
    
    tline = fgetl(fid);
    lineCount = lineCount+1;
end

data.freqList =freqList;

fclose(fid);
lineCount

%
function val = localGetNumericField(fieldName)
   
    thisFieldIdx = strcmp(numericField,fieldName);
%    find(fieldIdx)
%    val = str2double(textCell{1}{fieldIdx});
val = numericData(thisFieldIdx);

end

end
