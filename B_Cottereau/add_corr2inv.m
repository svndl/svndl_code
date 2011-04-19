function [ sol ] = add_corr2inv( sol , subjId , freesurfDir );

anatDir = getpref('mrCurrent','AnatomyFolder');
tmp = fullfile(anatDir,subjId,'Standard','meshes','ROIs_correlation.mat');

load(tmp);

for k = 1 : length( ROIs.name )

    sol( ROIs.ndx{ k } , : ) =  chol( ROIs.corr{ k } )' * sol( ROIs.ndx{ k } , : );

end
