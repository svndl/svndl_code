function inverseStruct=emseReadInverse(filename)
% inverseStruct=emseReadInverse(filename)
% Reads in an EMSE inverse file and returns it along with some other
% information in a structure
% ARW 01/25/06 : Wrote it
% edited LGA 3-14-06
% $date$



% if (ieNotDefined('filename')) %ieNotDefined is a quick function that checks for a variabel being empty or non-defined.
%                               % You can comment out the entire 'if'
%                               % statement if you like.
%     [filename, pathname, filterindex] = uigetfile('*.inv', 'Pick an EMSE inverse');
%     filename=fullfile(pathname,filename);
% end

fid=fopen(filename,'rb','ieee-le');

if (~fid)
    error('Could not open file');
end

% Get the magic number
magicNum=fscanf(fid,'%c',8);

if (~strcmp(upper(magicNum),'454D5345'))
    disp(a);
    error('This inverse file has a bad magic number - Is it from EMSE 5.0?');
end

% Next read in the major and minor revs

header=fscanf(fid,'%d\n');

% For now, we will check a few things and then jump straight to the data...
% Not parsing stuff like tangentSpaceDim
header

nRows=header(6)
nCols=header(7)

% We know that nRows and nCols are correct. Now do an fseek from the end of
% the file to make sure we are in the correct position.
%status=fseek(fid,-(nRows*nCols*8),'eof');
% disp(status);


% These two things are correct so we know we are at the end of the header.

[inverseMat,counter]=fread(fid,nCols*nRows,'float64',0,'ieee-le'); % Note, this also works with 'inf' bytes so we know that we are in the correct location in the file (since we can read to the end)
% fprintf('\nMax inverse val is %d',max(inverseMat(:)));

inverseMat=reshape(inverseMat,nCols,nRows); % Reshape to a rectangular matrix. 
inverseMat=inverseMat';
inverseStruct.matrix=inverseMat;
inverseStruct.nRows=nRows;
inverseStruct.nCols=nCols;
inverseStruct.magicNumber=magicNum;

fclose(fid);

return;

