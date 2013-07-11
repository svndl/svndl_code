function check_VSanatomy(p0,p1)
% compare 2 anatomy directories
% checks vAnatomy.dat, left & right .Class files, left & right .Gray files
% 
% e.g. check_VSanatomy('jones','skeri9999')

if ispc
	anatDir = 'X:\anatomy';
else
	anatDir = '/raid/MRI/anatomy';
end

file = 'vAnatomy.dat';
[a0,v0] = readVolAnat(fullfile(anatDir,p0,file));
[a1,v1] = readVolAnat(fullfile(anatDir,p1,file));
if all(v0==v1) && all(a0(:)==a1(:))
	disp([file,' files match'])
else
	disp([file,' file mismatch'])
end

% left.Class
file = 'left.Class';
c0 = readClassFile(fullfile(anatDir,p0,'left',file),false,false);
c1 = readClassFile(fullfile(anatDir,p1,'left',file),false,false);
if all(c0.data(:)==c1.data(:))
	disp([file,' files match'])
else
	disp([file,' file mismatch'])
end
% right.Class
file = 'right.Class';
c0 = readClassFile(fullfile(anatDir,p0,'right',file),false,false);
c1 = readClassFile(fullfile(anatDir,p1,'right',file),false,false);
if all(c0.data(:)==c1.data(:))
	disp([file,' files match'])
else
	disp([file,' file mismatch'])
end
% left.Gray
file = 'left.Gray';
[n0,e0,v0] = readGrayGraph(fullfile(anatDir,p0,'left',file));
[n1,e1,v1] = readGrayGraph(fullfile(anatDir,p1,'left',file));
try
	if all(v0==v1) && all(n0(:)==n1(:)) && all(e0==e1)
		disp([file,' files match'])
	else
		disp([file,' file mismatch'])
	end
catch
	disp([file,' file mismatch'])
end
% right.Gray
file = 'right.Gray';
[n0,e0,v0] = readGrayGraph(fullfile(anatDir,p0,'right',file));
[n1,e1,v1] = readGrayGraph(fullfile(anatDir,p1,'right',file));
try
	if all(v0==v1) && all(n0(:)==n1(:)) && all(e0==e1)
		disp([file,' files match'])
	else
		disp([file,' file mismatch'])
	end
catch
	disp([file,' file mismatch'])
end


