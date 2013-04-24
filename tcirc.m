function [pVal stdErr pT2 pChi] = tcirc(complexVector)


if isreal(complexVector)
	error('Vector Not Complex!')
end

vectorLength = length(complexVector);
M=vectorLength;

realPart = real(complexVector);
imagPart = imag(complexVector);

realVar = var(realPart);
imagVar = var(imagPart);

%Equivalent to equation 1 in Victor and Mast
Vindiv =(realVar+imagVar)/2;

%Equation 2 of Victor and Mast
%length of mean vector squared
Vgroup = (M/2)*abs(mean(complexVector)).^2;

T2Circ = (Vgroup/Vindiv);

pVal = 1-fcdf(T2Circ,2,2*M-2);

stdErr = sqrt(Vindiv);



% realMatrix = [real(complexVector) imag(complexVector)];
% 
% [n,p]=size(realMatrix);
% 
% m=mean(realMatrix,1); %Mean vector from data matrix X.
% %S=cov(realMatrix);  %Covariance matrix from data matrix X.
% S=eye(p)*Vindiv;
% T2=n*(m)*inv(S)*(m)'; %Hotelling's T-Squared statistic.
% F=(n-p)/((n-1)*p)*T2;
% v1=p;  %Numerator degrees of freedom.
% 
% v2=n-p;  %Denominator degrees of freedom.
% pT2=1-fcdf(F,v1,v2);  %Probability that null Ho: is true.
% 
% 
% v=p; %Degrees of freedom.
% pChi=1-chi2cdf(T2,v);
% % 
% % [T2Circ F]
% % [2*M-2 v2]