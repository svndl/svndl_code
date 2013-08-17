%computes gcv error based on formula found in 'Degrees of freedom in
%shrinkage estimation' (Kato 2007)
%the betas are estimates at a single value of lambda, i.e. they are vectors

function [gcvError, df] = compute_gcv(rss, beta, betaOls, grpsizes, n)

p = numel(grpsizes);
range = [0, cumsum(grpsizes)];

%compute group norms for each solution
betaNorms = zeros(1, p);
betaOlsNorms = zeros(1, p);
for i = 1:p
    betaNorms(i) = norm(beta(range(i)+1:range(i+1), :), 'fro');
    betaOlsNorms(i) = norm(betaOls(range(i)+1:range(i+1), :), 'fro');
end

%compute df
df = size(beta, 2); %constant terms
for i = 1:p
    df = df + (betaNorms(i)>0) + (size(beta, 2)*grpsizes(i)-1)*betaNorms(i)/betaOlsNorms(i);
end

%compute gcv error
gcvError = rss / (1-df/n)^2;