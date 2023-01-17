%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [ M ] = ecg2mov( ecg, ploc,r, param, name )
% Generate a movie out of ecg. 
% Input:
%       - ecg: a clean for of the ECG signals.
%       - ploc: a  locations of the peaks.
%       - r: values of dtw distances.
%       - param: a set of parameters.
%       - name: output video name 
%         
% Ouput :
%       - M: a movie matrix ( viewed by movie(M) command)
thr = param.thr;
dtwThreshold = param.dtw_threshold;
clear M;
close all;
count=1;
N = length(ecg);
frm = 10000;
scrsz = get(groot,'ScreenSize');
figure('Position',[0.5 scrsz(4)/2.5 scrsz(3) scrsz(4)/2])
nFrames = floor(N /frm) ;
t = 1:N;
% generate video if name is not empty 
if ~isempty(name)
    v = VideoWriter(name);
    open(v);
end
for i=1:nFrames
    % Get start and end points of the frame. 
    pS = (i-1)*frm + 1;% start point
    pE = i*frm;% end point
    %set axes 
    axis([pS, pE, -1, 1])
    y=ecg(pS: pE);
    x = t(pS:pE);
    % get location of peaks in the current frame
    % 
    ploc_s = ploc.s;
    ploc_t = ploc.t;
    ploc_r = ploc.r;
    pL_s = ploc_s(ploc_s>pS&ploc_s<pE);
    pL_t = ploc_t(ploc_t>pS&ploc_t<pE);
    pL_r = ploc_r(ploc_r>pS&ploc_r<pE);
    % Get Peaks values 
    pp_s = ecg(pL_s);
    pp_t = ecg(pL_t);
    pp_r = ecg(pL_r);
    plot(x, y);
    hold on 
    % get dtw distances within current frame
    %dtw_val = r(pS:pE);
    %mask = zeros(frm,1);
    %mask(dtw_val > thr ) =1;
    % Hilight ECG singals with high dtw 
    %x_mask = x;
    %y_mask = y;
    %x_mask(mask==0) =NaN;
    %y_mask(mask ==0) =NaN;
    %plot(x_mask, y_mask,'--r')
    %ind = find(mask ==1);
    %if ~isempty(ind) && dtwThreshold 
    %    S1=sprintf('*DTW = %0.2f', dtw_val(ind(1)));
    %    text(pS + 5000, 0.5, S1)
    %end
    %view time in frame
   S2=sprintf('Time = %d (secs)',(pS + 5000)/1000);
    text(pS + 1000, 0.75, S2)
    xlabel('Time in ms');
    ylabel('mV');
    %S1=sprintf('y(t)=sin(%.2f t)',freqrps);
    plot(pL_s, pp_s,'rv','MarkerFaceColor','y')
    plot(pL_t, pp_t,'rv','MarkerFaceColor','r')
    plot(pL_r, pp_r,'rv','MarkerFaceColor','g')

    hold off
    [p1mins, p1secs] =  sec2hms(pS);
    [p2mins, p2secs ] = sec2hms(pE);
    tit = sprintf('R- Peak Detection. From %d mins %d secs to %d mins %d secs',...
        p1mins, p1secs, p2mins, p2secs);
    title(tit);
    M(count)=getframe(gcf);
    if ~isempty(name)
        writeVideo(v, M(count));
    end
    count=count+1;
end
if ~isempty(name)
    close(v) 
end
end

