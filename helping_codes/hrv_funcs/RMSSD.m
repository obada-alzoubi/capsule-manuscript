%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function output = RMSSD(ibi)
%RMSSD: root mean square of successive RR differences
   differences=abs(diff(ibi)); %successive ibi diffs 
   output=sqrt(sum(differences.^2)/length(differences));
end