function inverseStruct=emseWriteInverse(inverseMatrix,filename)
%function inverseStruct=emseWriteInverse(inverseMatrix,filename)
% Writes an EMSE inverse file


% $Log: emseWriteInverse.m,v $
% Revision 1.3  2008/06/18 17:35:06  ales
% Experimented with log tags
%


% if (ieNotDefined('filename')) %ieNotDefined is a quick function that checks for a variabel being empty or non-defined.
%                               % You can comment out the entire 'if'
%                               % statement if you like.
%     [filename, pathname, filterindex] = uigetfile('*.inv', 'Pick an EMSE inverse');
%     filename=fullfile(pathname,filename);
% end

fid=fopen(filename,'wb','ieee-le');

if (~fid)
    error('Could not open file');
end

[nSources nElectrodes] = size(inverseMatrix);

header = ['454d5345\t4\t1\t5\n200000\t1000\t20020042\n1\t127\n' num2str(nSources) '\t' num2str(nElectrodes) '\n'];
disp(header)
sprintf(header)

%Write the header
fprintf(fid,header);



%Write the data, doing explicit row wise writes, matlab default to coloumn wise.
%
for iRow=1:nSources,
       fwrite(fid,inverseMatrix(iRow,:),'float64'); % Note, this also works with 'inf' bytes so we know that we are in the correct location in the file (since we can read to the end)
end


%New Emse has XMLie stuff at the end, 

xmlString = ['<JMAtst>''\n''<WhoMade>MatlabMade</WhoMade>''\n''</JMAtst>'];
fprintf(fid,xmlString);

fclose(fid);

inverseStruct = [];

return;

