function [oriConFwd] = mneFwdFixedOrient(fwd)
%function [fwd] = mneFwdFixedOrient(fwd)


me='JMA:mneFwdFixedOrient';
FIFF=fiff_define_constants;


idx = 1;
oriConFwd = zeros(fwd.nchan,fwd.src.np);

for iX = 1:3: size(fwd.sol.data,2),
    
    iVert = fwd.src.vertno(idx);
    oriConFwd(:,iVert) = fwd.sol.data(:,iX:iX+2)*fwd.src.nn(iVert,:)';
    idx = idx+1;
end


