function data = emse_read_bin(filename)
% based on emseReadInverse, plus patch for reading binary
% inverse files...
% JMA - Pulled this out of mrCurrent 
fid=fopen(filename,'rb','ieee-le');
if (~fid)
	error('Could not open file');
end
% Get the magic number
magicNum=fscanf(fid,'%c',8);

if (strcmp(upper(magicNum),'454D5345')) % Magic number is OK, we're reading a real inverse file
	% Next read in the major and minor revs
	header=fscanf(fid,'%d\n');
	% For now, we will check a few things and then jump straight to the data...
	% Not parsing stuff like tangentSpaceDim
	nRows=header(9);
	nCols=header(10);
	% We know that nRows and nCols are correct. Now do an fseek from the end of
	% the file to make sure we are in the correct position.
	status=fseek(fid,-(nRows*nCols*8),'eof');
	% These two things are correct so we know we are at the end of the header.
	% 				[tInv,counter]=fread(fid,nCols*nRows,'float64',0,'ieee-le'); % Note, this also works with 'inf' bytes so we know that we are in the correct location in the file (since we can read to the end)
	% 				tInv=reshape(tInv,nCols,nRows)';
	data = reshape( fread( fid, nCols*nRows, 'float64', 0, 'ieee-le' ), nCols, nRows )';
	% insert some kind of test here for new mangled inverses
	fclose(fid);
else % if magic number is mangled, we must be reading a binary copy of invervse file, so start over
	fclose(fid);
	fid = fopen(filename,'rb');
	[sz1,sz2] = strread(fgets(fid),'%d %d');
	data = reshape(fread(fid,sz1*sz2,'float64'),sz2,sz1)';
	fclose(fid);
end
end
