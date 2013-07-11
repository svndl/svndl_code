function [ctx] = readInflatedCortex(subjId)
%[ctx] = readDefaultCortex(subjId)


anatDir = getpref('mrCurrent','AnatomyFolder');

ctxFilename=fullfile(anatDir,subjId,'Standard','meshes','inflatedCortex');

load(ctxFilename);

ctx.faces = faces;

ctx.vertices = vertices;

