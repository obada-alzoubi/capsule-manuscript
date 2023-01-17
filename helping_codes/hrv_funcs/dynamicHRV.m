%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [ hrv ] = dynamicHRV( ploc, sf, ef, w, slide )
% Input  w: is the windows size for calculating HRV ( usually 5 mim)
%        slide: is the slding value for thr window 
L = ef -sf; % number of time points from the ECG 
nWindows = length(1: w: L); % number of windows
hrv = NaN(4, nWindows); % four metrics
limit = 200;
for iW=1:nWindows
    st = (iW-1)*w + sf;% start point in the window
    ed = st + w; % end point in the window
    if ed >ef
        ed = ef;
        duration = (ed -st)/(1000*60) ;
        limit = duration*40;
    end
    ploc_w_ind  = find(ploc > st & ploc < ed );
    if length(ploc_w_ind) > limit
        ploc_w = ploc(ploc_w_ind);
        ibi_w = ploc_w(2: end) - ploc_w(1: end -1);
        subplot(6,3,iW+2)
       [ ~, ibi_w ] = correctOuliers( ibi_w);
        title_w = sprintf('Window %d : %d to %d min', iW, (iW-1)*5, iW*5);
        title(title_w)

        hrv_w  = AA_HRV_MetricV3( ibi_w, [], 'no');
        hrv(1, iW) = hrv_w.SDNN(2);
        hrv(2, iW) = hrv_w.RMSSD(2);
        hrv(3, iW) = hrv_w.aHF;
        hrv(4, iW) = hrv_w.nHF;
    else
        fprintf('Number of time poits is less than 195 ... thus skipping \n')
        hrv(1, iW) = nan;
        hrv(2, iW) = nan;
        hrv(3, iW) = nan;
        hrv(4, iW) = nan;

end 


end

