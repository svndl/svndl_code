function optns = setDrawOptions(varargin)
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

p.addParamValue('surfName','inner skull');
p.addParamValue('surfReflectance',[0 1 0]);
p.addParamValue('surfAlpha',.4);
p.addParamValue('surfColor',[]);
p.addParamValue('patchOptions',[]);




p.parse(varargin{:});

optns = p.Results;

if isempty(optns.subjId)
    error('Subject ID not set correctly!')
end
