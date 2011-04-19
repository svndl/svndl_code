function [data fiducials] = readhsp( filename ); 
%function [data fiducials] = readhsp( filename ); 
%
% Remind JMA to put useful instructions here.
 
if nargin < 1
	help readhsp;
	return;
end;

% open file
% ---------
fid = fopen(filename, 'r');
if fid == -1
  disp('Cannot open file'); return;
end;

%discard first few lines
for index=1:9,
    fgetl(fid); 
end;

%Get the fiducial locations
for index = 1:3,
    tmpstr = fgetl(fid);
    
     sscanf(tmpstr,'%%F %f %f %f');
    fiducials(index,:) = sscanf(tmpstr,'%%F %f %f %f');
end
%fiducials

%fiducials = fiducials(:,2:4);

% scan file
% ---------
fgetl(fid); %throw ;away another line
tmpstr = fgetl(fid) %this should be reading the number of data points
tmp = sscanf(tmpstr,'%d %d');
%str2double(tmpstr);

nDim = tmp(2);
nPoints = tmp(1);

data = fscanf(fid,'%f',[nDim nPoints]);

data = data';

