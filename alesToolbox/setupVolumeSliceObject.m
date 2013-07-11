
function obj = setupVolumeSliceObject(varargin)
%This function sets and parses options for drawing functions
% pass in key value pairs to set options.
%
% key, default value, description
%'subjId', [], subject id to draw ex. 'skeri0001'
%'surfName','inner skull', which surface to draw
%'surfReflectance',[0 1 0], surface reflectane values for patch
%'surfAlpha',.4);
%'surfColor',[]);
%'patchOptions',[]);
% 

p = inputParser;

%p.KeepUnmatched = true;

p.addParamValue('subjId', [], @ischar);

p.addParamValue('volName','vAnataomy.dat');
p.addParamValue('reflectance',[0 1 0]);
p.addParamValue('alpha',1);
p.addParamValue('options',[]);

p.addParamValue('xIndices',128);
p.addParamValue('yIndices',128);
p.addParamValue('zIndices',128);


p.parse(varargin{:});

optns = p.Results;

if isempty(optns.subjId)
    error('Subject ID not set correctly!')
end

obj = optns;

[obj.volData,obj.x,obj.y,obj.z] = readDefaultMri(p.Results.subjId);