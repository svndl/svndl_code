function writeTriFile(V,F,triFile,comment)
% writes 3 column tri-files
%
% writeTriFile(vertices,faces,filename,comment)
% vertices = vertex matrix [ +right, +anterior, +superior ] origin @ volume center
% faces = triangular face matrix [ inward normals ] ???zero-indexed???

[fid,msg] = fopen(triFile,'w');
if fid == -1
	error(msg)
end
disp(['writing ',triFile])

[mV,nV] = size(V);
if nV == 3				% colums
	nV = mV;
	V = V';
	nF = size(F,1);
	F = F';
elseif mV == 3			% rows
	nF = size(F,2);
else
	error('vertex dimensions must be either Nx3 or 3xN')
end
% write data
if exist('comment','var') && ~isempty(comment) && ischar(comment)
	if ~strcmp(comment(1),'#')
		fprintf(fid,'%s','# ');
	end
	fprintf(fid,'%s\n',comment);
end
fprintf(fid,'%g\n',nV);
fprintf(fid,'%g %g %g\n',V);
fprintf(fid,'%g\n',nF);
fprintf(fid,'%g %g %g\n',F);
status = fclose(fid);




% thisDecName = [name '.dec'];
% [fid,msg] = fopen(thisDecName,'wb','b');
% fwrite(fid,[0],'uint8');
% fwrite(fid,length(vertices),'uint32');
% fwrite(fid,ones(length(vertices),1),'uint8');
