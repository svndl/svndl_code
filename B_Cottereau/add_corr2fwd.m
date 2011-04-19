function [ fwd ] = add_corr2fwd( fwd , subjId , freesurfDir )

anatDir = getpref('mrCurrent','AnatomyFolder');
tmp = fullfile(anatDir,subjId,'Standard','meshes','ROIs_correlation.mat');

load(tmp);

for k = 1 : length( ROIs.name )

    fwd( : , ROIs.ndx{ k } ) =  fwd( : , ROIs.ndx{ k } ) * chol( ROIs.corr{ k } )';

end

