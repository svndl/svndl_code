function [ y ] = phaseErrorPdf(x,A,sigma,phase )
%phaseErrorPdf Calculates the PDF of phase error for a vector with noise
%[ y ] = phaseErrorPdf(x,A,sigma,phase )
%
%This function calculates the pdf of the phase error for a 2d vector 
%length A with additive uncorrelated noise with standard deviation sigma
%
% x: (vector/scalar) Phase to evalate pdf. Should be in radians.
% A: (Scalar) Signal vector length. 
% sigma: (Scalar) Noise standard deviation
% phase(optional): (Scalar) Phase of the signal in radians. Zero phase is
%                  assumed if none specified. You can always shift the 
%                  output x yourself (i.e. true_x = x-phase);.
%
%
%NOTE:
%Ideally A should NOT be signal+noise. It should be an estimate of signal only 
%amplitude. For a noise only A should be 0. For real data this is not a
%trivial problem. This function estimates a with the formula:
%A'=sqrt(A.^2-2*sigma.^2);
%if A<0, A=0;end
%
%This formula is a biased estimate of A. The bias results in an underestimate
%of A resulting in a larger estimated phase variance. 
%Meaning this should make the phaseError estimate conservative.
%The bias is largest for signals near the noise floor: SNR < 3-4  
% 
%
%Output:
% y: (size(x)) PDF evaluated at x
%
% Formula adapted from:
% Bennett, W.R.; , "Methods of Solving Noise Problems," Proceedings of the IRE , vol.44, no.5, pp.609-638, May 1956
% doi: 10.1109/JRPROC.1956.275124
% URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4052065&isnumber=4052059


A=real(sqrt(A.^2-2*sigma.^2));

if A<0,
    A=0;
end


if nargin==4,
    x = x-phase;
end

%Equation 253 of Bennet.  There is a typographical error in the paper. The
%denominator of the error function (ERF) argument should be
%(1/sqrt(2)*sigma) NOT: 1/(sqrt(2*sigma)
%This is ugly. I verified this formula by Monte-Carlo simulations
%That's how I found the typo. -JMA
offset = (1/(2*pi) )* exp( -(A.^2/(2*sigma.^2)));
y =  offset + ...
    ((A*cos(x))./(2*sigma*sqrt(2*pi))).*...
    exp(-(((A.^2).*(sin(x).^2))./(2*sigma.^2))).*...
    (1+erf((A*cos(x))./(sqrt(2)*sigma)));

end

