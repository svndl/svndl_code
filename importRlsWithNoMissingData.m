function [data header] = importRlsWithNoMissingData(filename)
%function [data header] = importRlsWithNoMissingData(filename)


hdrFields = {
   'iSess'          '%*s\t'
    'iCond'         '%f\t'
    'iTrial'        '%f\t'
    'iCh'           '%s\t'
    'iFr'           '%f\t'
    'AF'            '%f\t'
    'xF1'           '%f\t'
    'xF2'           '%f\t'
    'Harm'          '%s\t'
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
validHeader = ~strncmp(hdrFields(:,2),'%*',2);
header = hdrFields(validHeader,1)';

format = [hdrFields{:,2}];

data = textscan(fid,format);


fclose(fid);



