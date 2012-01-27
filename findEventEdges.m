function [ eventIndices eventDurations eventValues] = findEventEdges( x )
%findEventEdges This function finds transitions, and returns their location, duration and value
%
%  function [ eventIndices eventDurations eventValues] = findEventEdges( x )
%
%Input: 
%x: A vector of labeled values
%
%Outputs are column vectors (nEdges x 1):
%eventIndices: Index into x of first sample after transition
%
%eventDurations: Number of samples until next transition
%
%eventValues: Value of first sample of transition



if ~isvector(x)
    error('This function currntly only works for vectors');
end

%convert to column vector
if size(x,1)>size(x,2)
    x = x';
end

%Finds the first sample after a transition
eventIndices = [0 find(x(1:end-1) ~= x(2:end))  ]+1;

if isempty(eventIndices)
    eventDurations = [];
    eventValues = [];
    return;
end

eventDurations = diff([ eventIndices length(x)]);

eventValues = x(eventIndices);


end

