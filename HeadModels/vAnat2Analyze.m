function vAnat2Analyze
% convert a vAnatomy.dat file back to Analyze format
% expecting readVolAnat.m to return volume in IPR orientation
% re-orients to LAS for FSL compatibility

[vAnatFile,vAnatPath] = uigetfile('*.dat','pick vAnatomy');
if isnumeric(vAnatFile)
	return
end

% img output is IPR oriented
[img,mmPerVox,volSize,fileName] = readVolAnat([vAnatPath,vAnatFile]);

x = [min(img(:)),max(img(:))];
if x(1)>=0 && x(2)<=255 && all(rem(img(:),1)==0)
	disp('converting to uint8')
	img = uint8(img);
else
	disp('expecting uint8 image')
	disp(x)
	return
end

% re-orient to LAS (FSL-convention)
img = flipdim(img,1);	% SPR
img = flipdim(img,2);	% SAR
img = flipdim(img,3);	% SAL
img = permute(img,[3 2 1]);	% LAS
mmPerVox = mmPerVox([3 2 1]);

[imgFile,imgPath] = uiputfile('*.hdr','save analyze file');
if isnumeric(imgFile)
	return
end
[imgPath,imgFile] = fileparts([imgPath,imgFile]);

hdr = analyzeWrite(img,fullfile(imgPath,imgFile),mmPerVox);