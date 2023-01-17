%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Obada Al Zoubi, Electrical and Computer Engineering Dept., University of Oklahoma.
% Email: obada.alzoubi@ou.edu
% Supervisor: Prof. Hazem Refai. 
% Copyright 2017, Obada Al Zoubi. 
% This code is not allowd to be distributed or used under any case without the permission from the author. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

l = 10000;
ecg = ECG{37};
N = length(ecg);
N_l= floor(N/l);
ploc_T= [];
ploc_S= [];
ploc_R =[];
stO = subjectData.Pool_3.BioPatch.st;
etO = stO + 90*60;
hr = subjectData.Pool_3.BioPatch.data(stO:etO, 1);
con = subjectData.Pool_3.BioPatch.data(stO:etO, 14);
for i=1:N_l
    % Divide the data into 10 seconds segments 
    st = (i - 1)*l +1;
    ed = i*l;
    st_hr = floor(st/10000)+1;
    ed_hr = st_hr+10;
    % filter out any data point with zero heart rate( low confidence)
    tmp_hr = hr(st_hr:ed_hr);
    tmp_hr(tmp_hr == 0)=NaN;
    tmp_hr(con(st_hr:ed_hr) <20)=NaN;
    % Get the average heart rate in the 10s segement to fine tuning peak
    % detection parameters.
    tmp_hr = mean(tmp_hr,'omitnan');
    % Set minimum distance between peaks to help peak detection algorithm. 
    min_peak_dist =  60*1000/tmp_hr - 250;
    if min_peak_dist > 3000 || min_peak_dist < 450
        min_peak_dist = 450;
    end
    % detect R, S and T peak for more accurate comparison
    tmp_ecg = ecg(st :ed);
        [~,tmp_ploc_S] = findpeaks(-tmp_ecg,'MinPeakHeight',0,...
                    'MinPeakDistance',min_peak_dist,'MinPeakProminence',...
                    0.1);
    [~,tmp_ploc_T] = findpeaks(tmp_ecg,'MinPeakHeight',0.35,...
    'MinPeakDistance',min_peak_dist,'MinPeakProminence',0.35,'MinPeakWidth',80);

    [~,tmp_ploc_R] = findpeaks(tmp_ecg,...
    'MinPeakDistance',min_peak_dist,'MinPeakProminence',0.1,'MaxPeakWidth',80);

    ploc_S = [ploc_S  (tmp_ploc_S+st)];
    ploc_T = [ploc_T  (tmp_ploc_T+st)];
    ploc_R = [ploc_R (tmp_ploc_R +st)];
    plot(tmp_ecg)
    
    hold on 
    plot(tmp_ploc_T, tmp_ecg(tmp_ploc_T), 'rv','MarkerFaceColor','r')
    plot(tmp_ploc_S, tmp_ecg(tmp_ploc_S), 'rv','MarkerFaceColor','y')
    plot(tmp_ploc_R, tmp_ecg(tmp_ploc_R), 'rv','MarkerFaceColor','g')
   
    hold off
end
% diff
[~,ploc_S] = findpeaks(-ecg,'MinPeakHeight',0,...
            'MinPeakDistance',min_peak_dist,'MinPeakProminence', 0.1);
[~,ploc_T] = findpeaks(ecg,'MinPeakHeight',0.35,...
'MinPeakDistance',min_peak_dist,'MinPeakProminence',0.35,'MinPeakWidth',80);

[~,ploc_R] = findpeaks(ecg,...
'MinPeakDistance',min_peak_dist,'MinPeakProminence',0.1,'MaxPeakWidth',80);
diff_S = ploc_S(2:end) - ploc_S(1:end-1);
diff_T = ploc_T(2:end) - ploc_T(1:end-1);
diff_R = ploc_R(2:end) - ploc_R(1:end-1);
fprintf('avg. S-to-S interval: %0.2f ms\n', mean(diff_S,'omitnan'))
fprintf('avg. T-to-T interval: %0.2f ms\n', mean(diff_T,'omitnan'))
fprintf('avg. R-to-R interval: %0.2f ms\n', mean(diff_R,'omitnan'))

