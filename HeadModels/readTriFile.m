function [V,F]=readTriFile(triFile)
% reads either 3 or 4 column tri-files, unlike freesurfer_read_tri.m
%
% [vertices,faces] = readTriFile(filename)

[fid,msg] = fopen(triFile,'r');
if fid == -1
	error(msg)
end
disp(['reading ',triFile])
% check 1st char for comment line
c1 = fscanf(fid,'%c',1);
status = fseek(fid,0,-1);
if strcmp(c1,'#')
	disp(fgetl(fid))
end
% read # vertices
nV = fscanf(fid,'%d',1);
fprintf('%d vertices\n',nV)
% check # columns
fpos = ftell(fid);
fgetl(fid);		% skip past nV line termination
nCol = numel(sscanf(fgetl(fid),'%f'));
status = fseek(fid,fpos,-1);
% read vertices
V = fscanf(fid,'%f',[nCol,nV])';
% read faces
nF = fscanf(fid,'%d',1);
fprintf('%d faces\n',nF)
F = fscanf(fid,'%d',[nCol,nF])';
status = fclose(fid);

% trim index column
if nCol == 4
	vi = V(:,1);
	V = V(:,2:4);
	F = F(:,2:4);
	for i=1:numel(F)
		F(i) = find(vi==F(i));
	end
end
