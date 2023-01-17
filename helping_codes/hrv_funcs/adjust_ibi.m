%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    function ibi=adjust_ibi(tmpData)
        %check ibi dimentions
        [rows cols] = size(tmpData);                
        if rows==1 %all data in 1st row
            tmpData=tmpData';
            ibi=zeros(cols,2);
            tmp=cumsum(tmpData);
            ibi(2:end,1)=tmp(1:end-1);
            ibi(:,2)=tmpData;
        elseif cols==1 %all data in 1st col
            ibi=zeros(rows,2);
            tmp=cumsum(tmpData);
            ibi(2:end,1)=tmp(1:end-1);
            ibi(:,2)=tmpData;
        elseif rows<cols %need to transpose
            ibi=tmpData';
        else
            ibi=tmpData; %ok
        end                                      
        clear tmpData      
    end