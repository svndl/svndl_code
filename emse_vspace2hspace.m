function [vspace hspace omat meshtype] = emse_vspace2hspace(vspaceFileList,regFile)
%function [vspace hspace omat meshtype] = emse_vspace2hspace(vspaceFileList,regFile)


if ~iscell(vspaceFileList)
	vspaceFileList = {vspaceFileList};
end;


nVspaceFiles = length(vspaceFileList);

reg = emse_read_reg(regFile);
omat = reg.mri2elec;

for iFile = 1:nVspaceFiles,
	
	thisFile = vspaceFileList{iFile};
	[vertex face edge meshtype] =	emse_read_wfr(thisFile);
	
	vspace.vertices = [vertex.x; vertex.y; vertex.z;]';		
	vspace.faces = [face.vertex3; face.vertex2; face.vertex1]';
		
	hspace = emse_mri2elec(vspace,reg)

	
	[pathstr name ext] = fileparts(thisFile);
	outName = [name '_hspace' ext];
	emse_write_wfr(outName,hspace.vertices,hspace.faces,meshtype,'hspace')
	
end

	