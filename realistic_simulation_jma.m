 function [] = realistic_simulation( cluster_nb , cluster_size , noise_level , simu_nb , savefile_name )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of the variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addpath('E:\Smith-Kettlewell\Matlab\MEEG_data_analysis\MEEG_simulation_toolbox');
% addpath('E:\Smith-Kettlewell\Matlab\Test_regu');
addpath(genpath('/Volumes/MRI/toolbox/matlab_toolboxes/Benoit_toolbox/'));
% load EEGfwd_tess_s48.mat             % Matfile containing the tesselation and forward matrix.

load ROIs_correlation.mat            % Matfile containing the ROIs and the associated correlation matrices



mrcDir = '/Volumes/MRI/data/4D2/fusSup/mrC';
subjId = 'skeri0048';


anatDir = getpref('mrCurrent','AnatomyFolder');
roiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');
fsDir = getpref('freesurfer','SUBJECTS_DIR');
fwdFile = fullfile(mrcDir,subjId,'_MNE_',[subjId '-fwd.fif']);

fwd = mne_read_forward_solution(fwdFile);

% srcFile = fullfile(fsDir,[subjId '_fs4'],'bem',[subjId '_fs4-ico-5p-src.fif']);
% src = mne_read_source_spaces(srcFile);

src = readDefaultSourceSpace(subjId);

[EEG_fwd Afree] = makeForwardMatrixFromMne(fwd,src);

A = EEG_fwd;

Anrm = zeros(size(A));

for i=1:length(A);
    
    Anrm(:,i) = A(:,i)./norm(A(:,i));
end


mesh = readDefaultCortex(subjId);
mesh.uniqueVertices = mesh.vertices;
mesh.uniqueFaceIndexList = mesh.faces;
[mesh.connectionMatrix] = findConnectionMatrix(mesh);

VertConn = cell(size(mesh.connectionMatrix,1),1);

tic
for i=1:size(mesh.connectionMatrix,1),   
    edgeList = find(mesh.connectionMatrix(:,i)); %<-- col indexes x10 faster find
    VertConn{i} = edgeList;
end
toc

Visual_areas = zeros(1,length(VertConn));
ROIcor = zeros(length(VertConn),length(ROIs.ndx));
for ndx = 1 : length(ROIs.ndx)
    Visual_areas( ROIs.ndx{ndx} ) = ndx;
    ROIcor(ROIs.ndx{ndx},ndx) = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the activated sources time courses
freq = 2;       % Signal frequency
fe = 120;       % Sampling frequency
x = 0 : 1 / fe :  1 - 1 / fe ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the different AUC
AUC_MN = [];
error_MN = [];
AUC_variance = [];
error_variance = [];
AUC_correlation = [];
error_correlation = [];
AUC_var_corr = [];
error_var_corr = [];
AUC_full_correlation = [];
error_full_correlation = [];

for ndx_simu = 1 : simu_nb

        tmp = randperm( 18 );
        ndx_areas = tmp( 1 : cluster_nb );
        activated_sources = zeros( 1 , length(VertConn) );

        % Boucle on all the activated clusters
        for k  = 1 : length(ndx_areas)

            ROI = ROIs.ndx{ ndx_areas(k) };
            tmp = randperm(length(ROI));
            
            growing_seed = zeros(1,length(VertConn));
            growing_seed( ROI(tmp(1)) ) = 1;
            activated_sources_tmp = [];
            while (length( activated_sources_tmp ) < cluster_size / 100 * length(ROI) )
                growing_seed = dilatation( growing_seed , VertConn , 1 );
                activated_sources_tmp = intersect( ROI , find(growing_seed) );
            end
            if ( length( activated_sources_tmp ) > round( cluster_size / 100 * length(ROI) ) )
                activated_sources_tmp = activated_sources_tmp( 1 : round( cluster_size / 100 * length(ROI) ) );
            end
        activated_sources( activated_sources_tmp ) = k;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Definition of the signal
%    data_amp = zeros(20484,1);
    nFreqs = 4;
    data = complex(zeros(20484,nFreqs));
%     figure
%     hold on
    for ndx_area = 1 : cluster_nb
        
        for iFreq=1:nFreqs,
%             
%             tmp = round(rand*4);
%             ROI_amp( ndx_area,: ) = 1 + tmp;              % Amplitude of the area
%             tmp = 360*rand;
%             ROI_phase( ndx_area,: ) = 180 - tmp;                     % Phase of the area (in degres)
% 
%         
%             ROI_amp = 
%             
            ROI_cplx(ndx_area,iFreq) = complex(4*randn,4*randn);

            tmp = find( activated_sources == ndx_area );
            data(tmp,iFreq) =data(tmp,iFreq)+ROI_cplx(ndx_area,iFreq);
        %             data( tmp , : ) = repmat( y , length(tmp) , 1 );
        
        %         %ROI_power( ndx_area ) = ROI_amp( ndx_area ) .^2 / 4;
        %
        %         for iFreq = 1:nFreqs,
        %             thisFreq = freq*iFreq
        %             y = ROI_amp( ndx_area,iFreq )' * cos( 2 * pi * thisFreq * x - ROI_phase( ndx_area,iFreq ) / 360 * 2 * pi );
        %             data_amp( tmp,iFreq ) = (ROI_amp( ndx_area,iFreq ) * ones( size(tmp) ))';
        %         end
        %
        % %         h = plot( x , y );
        % %         set( h , 'Color' , [1/ndx_area 0 (1 - 1/ndx_area)] )
        % %         Fourier_trans = fft( y , length(y) ) / length(y);
        % %         f = psdfreqvec( length(y) , fe );
        % %         f_ndx = find( f == freq );
        % %         ROI_power( ndx_area ) = abs(Fourier_trans(f_ndx)) * 2;
        end
    end
%     
%     ROI_amp = ROI_amp / sum( ROI_amp );
%     tmp = rand( size(ROI_amp) );
%     Amp_test = tmp / sum( tmp );
%     error_amp_test( ndx_simu ) = norm( ROI_amp - Amp_test ) / norm( ROI_amp );
%     
    y_stim = EEG_fwd * data;

    
    addNoise = complex(randn(size(y_stim)),randn(size(y_stim)));
    
    addNoise = addNoise*(noise_level*max(abs(y_stim(:))))/100;
    
    fourier_coeff = y_stim+addNoise;
    
%     [noisy_data,noise_var] = add_noise_with_SNR( y_stim , noise_level );
%     y_post = y_stim + noisy_data;
%     f = psdfreqvec( length(y) , fe );
%     f_ndx = find( f == freq );
    
%     for ndx_sens = 1 : size( y_post , 1 )
%         tmp = fft( y_post(ndx_sens,:) , size(y_post,1) ) / size(y_post,1);
%         fourier_coeff( ndx_sens , : ) = [ real( tmp( f_ndx ) ) , imag( tmp( f_ndx ) ) ];
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimation of the sources time courses and computation of the AUC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Minimum-norm
    G = EEG_fwd;
    %De-complexify
    componentData = [real(fourier_coeff) imag(fourier_coeff) ];
    
    [ J_MN ] = minimum_norm( G , componentData );

    %Re-complexify
    J_MN = complex(J_MN(:,1:end/2),J_MN(:,(end/2+1):end));
    for iFreq=1:nFreqs,
        
        AUC_MN(ndx_simu,iFreq) = rocArea( abs(J_MN(:,iFreq)),activated_sources>0);
        
    end
    
    AUC_MNs(ndx_simu) = rocArea( sum(abs(J_MN),2),activated_sources>0);
    
%     for ndx_area = 1 : cluster_nb
%         tmp = find(activated_sources == ndx_area);
%         Amp_ac_MN(ndx_area) = 2 * norm( mean( J_MN(tmp,:) , 1 ) );
%         Phas_ac_MN(ndx_area) = (-1/pi) * 180 * angle( mean( J_MN(tmp,1) + J_MN(tmp,2) * i ) );
%     end
%     Amp_ac_MN = Amp_ac_MN / sum(Amp_ac_MN);
%     
%     error_amp_MN( ndx_simu ) = norm( ROI_amp - Amp_ac_MN ) / norm( ROI_amp );
%     error_phase_MN( ndx_simu ) = mean(min([360 * ones(size(ROI_phase)) - abs(ROI_phase - mod(Phas_ac_MN,360)); abs(ROI_phase - mod(Phas_ac_MN,360))]));

%     J_MN = complex(J_MN(:,1),J_MN(:,2));
    
%     [ AUC_MN( ndx_simu ) , c , d ] = ROC( abs( J_MN ) ./ max( abs(J_MN) ) , find(activated_sources) , VertConn , 0 );
%     error_MN( ndx_simu ) = norm( J_real - J_MN ) / norm( J_real );


%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Minimum-norm with higher variance for the sources inside the
%     % pre-defined visual areas
%     G = EEG_fwd;
%     G( : , find(Visual_areas) ) = G( : , find(Visual_areas) ) * sqrt(4);
%     [ J_variance ] = minimum_norm( G , fourier_coeff );
%     J_variance( find(Visual_areas) ) = sqrt(4) * J_variance( find(Visual_areas) );
%     
%     for ndx_area = 1 : cluster_nb
%         tmp = find(activated_sources == ndx_area);
%         Amp_ac_variance(ndx_area) = 2 * norm( mean( J_variance(tmp,:) , 1 ) );
%         Phas_ac_variance(ndx_area) = (-1/pi) * 180 * angle( mean( J_variance(tmp,1) + J_variance(tmp,2) * i ) );
%     end
%     Amp_ac_variance = Amp_ac_variance / sum(Amp_ac_variance);
%     
%     error_amp_variance( ndx_simu ) = norm( ROI_amp - Amp_ac_variance ) / norm( ROI_amp );
%     error_phase_variance( ndx_simu ) = mean(min([360 * ones(size(ROI_phase)) - abs(ROI_phase - mod(Phas_ac_variance,360)); abs(ROI_phase - mod(Phas_ac_variance,360))]));
% %     [ AUC_variance( ndx_simu ) , c , d ] = ROC( abs( J_variance ) ./ max( J_variance ) , activated_sources , VertConn , 0 );
% %     error_variance( ndx_simu ) = norm( J_real - J_variance ) / norm( J_real );
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Minimum-norm with variance and decreasing correlation
%     G = EEG_fwd;
%     for k = 1 : length( ROIs.name )
%         G( : , ROIs.ndx{ k } ) =  G( : , ROIs.ndx{ k } ) * chol( ROIs.corr{ k } )';
%     end
%    [ J_var_corr ] = minimum_norm( G , fourier_coeff );
%    for k = 1 : length( ROIs.name )
%        J_var_corr( ROIs.ndx{ k } , : ) =  chol( ROIs.corr{ k } )' * J_var_corr( ROIs.ndx{ k } , : );
%    end
%    
%    for ndx_area = 1 : cluster_nb
%        tmp = find(activated_sources == ndx_area);
%        Amp_ac_var_corr(ndx_area) = 2 * norm( mean( J_var_corr(tmp,:) , 1 ) );
%        Phas_ac_var_corr(ndx_area) = (-1/pi) * 180 * angle( mean( J_var_corr(tmp,1) + J_var_corr(tmp,2) * i ) );
%    end
%    Amp_ac_var_corr = Amp_ac_var_corr / sum(Amp_ac_var_corr);
%    
%    error_amp_var_corr( ndx_simu ) = norm( ROI_amp - Amp_ac_var_corr ) / norm( ROI_amp );
%    error_phase_var_corr( ndx_simu ) = mean(min([360 * ones(size(ROI_phase)) - abs(ROI_phase - mod(Phas_ac_var_corr,360)); abs(ROI_phase - mod(Phas_ac_var_corr,360))]));
% %     [ AUC_var_corr( ndx_simu ) , c , d ] = ROC( abs( J_var_corr ) ./ max( J_var_corr ) , activated_sources , VertConn , 0 );
% %     error_var_corr( ndx_simu ) = norm( J_real - J_var_corr ) / norm( J_real );


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Beamformer with free orientation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    G = Afree;
    
    C = componentData*componentData';
    C =  C+eye(size(C))*(noise_level/100)*max(diag(C));
    
    [ t_bf l_bf ] = lcmvBeamform( G , C );
    
    %[filt filt2] = lcmvBeamformFilt(EEG_fwd,C,ROIcor);
    
    
    AUC_tBF(ndx_simu) = rocArea( t_bf,activated_sources>0);
    AUC_lBF(ndx_simu) = rocArea( l_bf,activated_sources>0);

%     for ndx_area = 1 : cluster_nb
%         tmp = find(activated_sources == ndx_area);
%         Amp_ac_MN(ndx_area) = 2 * norm( mean( J_MN(tmp,:) , 1 ) );
%         Phas_ac_MN(ndx_area) = (-1/pi) * 180 * angle( mean( J_MN(tmp,1) + J_MN(tmp,2) * i ) );
%         
%         Amp_ac_MN(ndx_area) = 2 * norm( mean( J_MN(tmp,:) , 1 ) );
%         Phas_ac_MN(ndx_area) = (-1/pi) * 180 * angle( mean( J_MN(tmp,1) + J_MN(tmp,2) * i ) );
% 
%     end

%     Amp_ac_MN = Amp_ac_MN / sum(Amp_ac_MN);
%     
%     error_amp_MN( ndx_simu ) = norm( ROI_amp - Amp_ac_MN ) / norm( ROI_amp );
%     error_phase_MN( ndx_simu ) = mean(min([360 * ones(size(ROI_phase)) - abs(ROI_phase - mod(Phas_ac_MN,360)); abs(ROI_phase - mod(Phas_ac_MN,360))]));

%     [ AUC_lBF( ndx_simu ) , c , d ] = ROC( l_bf ./ max(l_bf), find(activated_sources) , VertConn , 0 );
%     [ AUC_tBF( ndx_simu ) , c , d ] = ROC( t_bf ./ max(t_bf), find(activated_sources) , VertConn , 0 );

    %     error_MN( ndx_simu ) = norm( J_real - J_MN ) / norm( J_real );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Minimum-norm with full correlation
%     G = EEG_fwd;
%     G = create_GR_corr( G , visual_areas , 2 , visual_areas_corr );
%     
%     [ J_full_correlation ] = minimum_norm( G , y_post(:,24) );
%     J_full_correlation = create_RJ_corr( J_full_correlation , visual_areas, 2 , visual_areas_corr );
%         
%     [ AUC_full_correlation( ndx_simu ) , c , d ] = ROC( abs( J_full_correlation ) ./ max( J_full_correlation ) , activated_sources , VertConn , 0 );
%     error_full_correlation( ndx_simu ) = norm( J_real - J_full_correlation ) / norm( J_real );
%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ndx_simu
%   
save( savefile_name, 'AUC_MN','AUC_MNs','AUC_tBF','AUC_lBF' , 'cluster_nb' , 'cluster_size' , 'noise_level');
    
end

%keyboard




