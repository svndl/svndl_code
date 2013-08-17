function [betahat, gcvError, rsquared, lambdaGrid, lambdaHat] = estimate_source(Y, fwdMatrix, rois, nLambda)

%Inputs
%Y: combined observation vector across subjects nElectrodes x nTime
%fwdMatrix: 1 x numSubjects cell of forward matrices from each subject from
% 'forwardAndRois-skeri...'
% Each fwdMatrix is nElectrodes x nSources
%rois: 1 x numSubjects cell of rois from each subject from 'ROI_correlation_subj...'
%      rois{iSubject}.ndx = Cell array with strings naming each visual area
%      rois{iSubject}.idx = 1 x nRoi Cell array with indices into nSources for each ROI
   
%nLambda: number of values of the regularization parameter lambda

%Outputs
%betahat: estimated source in original unsmoothed space
%gcvError: gcv error curve from fitting
%rsquared: sequence of rsquared values along the grid of fits
% lambdaGrid: the actual lambda sequence used for fitting
% lambdaHat: best lambda chosen by gcv

%define algorithm-specific parameters
numComponents = 5; %number of principal components in derived forward matrices
numCols = 2; %number of right singular vectors of Y to use in temporal smoothing
alpha = 1.0817e4; %ridge parameter
maxIter = 1e6;

%get number of subjects and number of visual areas
numSubjects = numel(fwdMatrix);
numVisualAreas = numel(rois{1}.ndx);

%Xlist is the list of derived forward matrices, each of dimension (n x
%numComponents). Vlist contains the matrices used to reverse the PCA
%transformation. grpSizes is the size of each visual area in the derived
%forwards
[Xlist, Vlist, grpSizes] = get_X_list(fwdMatrix, rois, numComponents);


%generate X and V. X is the blocked derived forward matrix from all the
%subjects
X = [];
V = [];
for g = 1:numVisualAreas
    tempX = [];
    tempV = [];
    for i = 1:numSubjects
        tempX = blkdiag(tempX, Xlist{i}{g});
        tempV = blkdiag(tempV, Vlist{i}{g});
    end
    X = [X, tempX];
    V = blkdiag(V, tempV);
end
indices = get_indices(grpSizes);
penalties = get_group_penalties(X, indices);

%center Y and X
X = scal(X, mean(X));
Y = scal(Y, mean(Y));
n = numel(Y);
ssTotal = norm(Y, 'fro')^2 / n;

%use right singular vectors of Y as time basis
[~, ~, v] = svd(Y);
v = v(:, 1:numCols);

%transformed problem
Ytrans = Y * v;
Ytrans = scal(Ytrans, mean(Ytrans));

%sequence of lambda values
lambdaMax = 0;
for i = 1:G
    lambdaMax = max(lambdaMax, norm(X(:,indices{i})'*Ytrans, 'fro')/penalties(i));
end
lambdaMax = lambdaMax + 1e-4;
lambdaGrid = lambdaMax * (0.001.^(0:1/(nLambda-1):1));
tol = min(penalties) * lambdaGrid(end) * 1e-5;
if alpha > 0
    tol = min([tol, 2*alpha*1e-5]);
end

%get the total size of each visual area across all subjects
roiSizes = zeros(1, numVisualAreas);
for j = 1:numVisualAreas
    for i = 1:numSubjects
        roiSizes(j) = roiSizes(j) + numel(rois{i}.ndx{j});
    end
end

%ols fit for df calculation
betaOls = (X'*X + alpha*eye(size(X,2))) \ (X'*Ytrans);

%fitting
fprintf('Estimating source activity for %d subjects\n', numSubjects);
betaInit = zeros(size(X, 2), numCols);
betahat = cell(1, nLambda);
objValues = cell(1, nLambda);
gcvError = zeros(1, nLambda);
df = zeros(1, nLambda);
rss = zeros(1, nLambda);
rsquared = zeros(1, nLambda);
converged = zeros(1, nLambda);
indexer = [];
for i = 1:numSubjects
    indexer = [indexer, return_index(roiSizes, rois, i)];
end
fprintf('i\tlambda\tobj      \tniter\tgcvError\tdf\tconverged\n');
fprintf('--------------------------------------------------------------------------------\n');
for i = 1:nLambda
    [betahat{i}, objValues{i}, res] = get_solution_frobenius(X, Ytrans, betaInit, lambdaGrid(i), alpha, tol, maxIter, penalties, indices);
    converged(i) = check_solution(X, betahat{i}, res, indices, penalties, lambdaGrid(i), alpha, tol);
    betaInit = betahat{i};
    betahat{i} = V * betahat{i} * v'; %transform back to original space (permuted forward matrices)
    betahat{i} = betahat{i}(indexer, :); %now corresponds to subject1, subject2, subject3, ...
    rss(i) = norm(Y-stackedForwards*betahat{i}, 'fro')^2 / n;
    rsquared(i) = 1 - rss(i) / ssTotal;
    [gcvError(i), df(i)] = compute_gcv(rss(i), betaInit, betaOls, grpSizes, n);
    fprintf('%d\t%2g\t%2g\t%d\t%2g\t%2g\t%5d\n', i, lambdaGrid(i), objValues{i}(end), numel(objValues{i}), gcvError(i), df(i), converged(i));
end
[~, bestIndex] = min(gcvError);
lambdaHat = lambdaGrid(bestIndex);
