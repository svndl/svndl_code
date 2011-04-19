function VecInd  = findclosest(VecGuess, VecRef);
%FINDCLOSEST - Find entries of closest elements between two vectors 
% function VecInd  = findclosest(VecGuess, VecRef);
% Find entries of closest elements between two vectors 
% VecGuess is a vector for which one wants to find the closest entries in vector VecRef
% VecInd is the vector of indices pointing atr the entries in vector VecRef that are the closest to VecWin
% VecInd is of the length of VecGuess
% 
% In other words, VecRef(VecInd(i)) is the element of VecRef closest to VecGuess(j)
% 
% VecRef and VecGuess do not need to be the same length

%<autobegin> ---------------------- 27-Jun-2005 10:44:18 -----------------------
% ------ Automatically Generated Comments Block Using AUTO_COMMENTS_PRE7 -------
%
% CATEGORY: Utility - Numeric
%
% At Check-in: $Author: cottereau $  $Revision: 1.1 $  $Date: 2009/06/10 00:28:36 $
%
% This software is part of BrainStorm Toolbox Version 27-June-2005  
% 
% Principal Investigators and Developers:
% ** Richard M. Leahy, PhD, Signal & Image Processing Institute,
%    University of Southern California, Los Angeles, CA
% ** John C. Mosher, PhD, Biophysics Group,
%    Los Alamos National Laboratory, Los Alamos, NM
% ** Sylvain Baillet, PhD, Cognitive Neuroscience & Brain Imaging Laboratory,
%    CNRS, Hopital de la Salpetriere, Paris, France
% 
% See BrainStorm website at http://neuroimage.usc.edu for further information.
% 
% Copyright (c) 2005 BrainStorm by the University of Southern California
% This software distributed  under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html .
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%<autoend> ------------------------ 27-Jun-2005 10:44:18 -----------------------

if size(VecRef,1) == 1
    VecRef = VecRef';
end


tmp = repmat(VecRef,1,length(VecGuess));
[minn VecInd] = min(abs(repmat(VecGuess,length(VecRef),1) - tmp));

return
