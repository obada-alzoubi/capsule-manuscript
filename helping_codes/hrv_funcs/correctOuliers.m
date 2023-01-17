%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [ loc, ploc ] = correctOuliers( org_ploc)
%org_ploc = org_loc(2:end) -org_loc(1:end-1);
outliers_1 = locateOutliers([], org_ploc, 'percent', 20);  
[y2,t2] = replaceOutliers([], org_ploc,outliers_1, 'median',20);
outliers_2 = locateOutliers([],y2, 'percent', 20);  
[y3,t3] = replaceOutliers(t2,y2,outliers_2, 'mean',20);
outliers_3 = locateOutliers([],y3, 'percent', 20); 
t3 = cumsum(y3);
[y4,t4] = replaceOutliers(t3,y3,outliers_3, 'remove');
%figure
%plot(org_ploc)
%hold on
%plot(find(outliers_1),org_ploc(outliers_1), '*');
%plot(y2)
%plot(find(outliers_2),org_ploc(outliers_2), '*');
hold  on
plot(y4)
hold off 
%title(sprintf(' %s - %s', subName, sesName));
ploc =y4;
loc = cumsum(t4);
end

