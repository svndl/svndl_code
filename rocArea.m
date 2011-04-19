function [auc se] = rocArea(x_hat,x_true)
%rocArea Fast calculation of the area under the ROC curve
%
%function [auc] = rocArea(x_hat,x_true) 
%
%Input:
%
% x_hat  = Vector containing responses 
% x_true = Vector containing ground truth labeling for each response in x_hat
%
%Output:
%
% auc = Area under the ROC curve.

% se = standard error of the auc estimate

%This is an implementation of the method described in:
% 
%     Journal Title  - Machine Learning
%     Article Title  - A Simple Generalisation of the Area Under the ROC Curve for Multiple Class Classification Problems
%     Volume  - Volume 45
%     Issue  - 2
%     First Page  - 171
%     Last Page  - 186
%     Issue Cover Date  - 2001-11-01
%     
%     Author  - David J. Hand
%     Author  - Robert J. Till
%     DOI  - 10.1023/A:1010920819831
%     Link  - http://www.springerlink.com/content/nn141j42838n7u21
%     

trueV = unique(x_true);

if trueV(1) ~= 0 || trueV(2) ~= 1,
    error('Error: x_true values should only have two values: 0 and 1 (True or False for target present)');
end


%sort everything by response estimate.
[x_hat,I] = sort(x_hat);
x_true = x_true(I);


%Numbers of positive and negative examples
Nn = sum(x_true==0);
Np = sum(x_true==1);


%Rank of every positive examplar, sorted by x_hat
r = find(x_true==1);

%Sum of the rank value of each positive.
S0 = sum(r);

%Formula 3 of Hand and Till
%
auc = (S0 - ( Np*(Np+1)/2))/(Np*Nn);


%Calculations for the standard error, if requested
%Formula 6 of Hand and Till doesn't seem correct so using:
%Table 2 in Hanley and Mcneil 1982  
if nargout >= 2

    %     Th = S0/(Np*Nn);
    %
    %     Q1 = sum((r-1).^2);
    %     Q0 = (((2*Nn+2*Np+1)*(Nn+Np+1)*(Nn+Np))/6) - Q1;
    %
    %     %Numerator in equation 6
    %     num = Th*(1-Th)+(Np-1)*(Q0-Th.^2)+(Nn-1)*(Q1-Th.^2);
    %     %Denominator in equation 6
    %     den = Np*Nn;
    %
    %     se = sqrt(num/den);

    
    %For notational equivalence, with Hanley, Number Abnormal = Na = Np = Number Positives;
    Na = Np;

    %Th is the area under the ROC curve;
    Th = auc;
    
    Q1 = Th / (2 - Th);
    Q2 = 2*Th*Th / (1 + Th);

    num = Th*(1-Th)+(Na-1)*(Q1-Th.^2)+(Nn-1)*(Q2-Th.^2);
    den = Np*Nn;
    se = sqrt(num/den);

    
    
end

