function [ y ] = phaseDifferencePdf(x,A,sigma )
%phaseErrorPdf Calculates the PDF of phase error for a vector with noise
%[ y ] = phaseErrorPdf(x,A,sigma )%    
%
%This function calculates the pdf of the phase error for a 2d vector 
%length A with additive uncorrelated noise with standard deviation sigma
%
% x: (vector/scalar) Phase to evalate pdf. Should be in radians.
% A: (Scalar) Signal vector length. 
% sigma: (Scalar) Noise standard deviation
%
%NOTE:
%Ideally A should NOT be signal+noise. It should be an estimate of signal only 
%amplitude. For a noise only A should be 0. For real data this is not a
%trivial problem. This function estimates a with the formula:
%A'=sqrt(A.^2-2*sigma.^2);
%if A<0, A=0;end
%
%This formula is a biased estimate of A. The bias results in an underestimate. 
%Meaning this should make the phaseError estimate conservative.
%It matter for signals near the noise floor: SNR < 3-4  
% 
%
%Output:
% y: (size(x)) PDF evaluated at x
%
% Formula adapted from:
% Bennett, W.R.; , "Methods of Solving Noise Problems," Proceedings of the IRE , vol.44, no.5, pp.609-638, May 1956
% doi: 10.1109/JRPROC.1956.275124
% URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4052065&isnumber=4052059


%A=sqrt(A.^2-2*sigma.^2);

if A<0,
    A=0;
end

for i=1:2,
rho(i)=(A(i).^2)./(sigma(i).^2);
end

%dphi = -x;

rho
U = mean(rho)
V = (rho(2)-rho(1))/2
W = sqrt(prod(rho))
y= zeros(size(x));
for iX = 1:length(x),
    dphi = -x(iX);
    
    y(iX) = quadl(@(t) myfun(t,dphi),-pi/2,pi/2,1e-7);
    y(iX) = y(iX).*(W*sin(dphi))./40*pi;

end

y = y -y(1) + .5*(1+sign(x));
myfun(eps,eps)

quad(@(t) myfun(t,0),-pi/2,pi/2)

    function y = myfun(t,dphi)
        num = exp(-( U-V*sin(t)-W*cos(dphi)*cos(t)));
        denom = U-V*sin(t)-W*cos(dphi)*cos(t);
        y=num./denom;
        
    end




end
