function HR_w = getBR(ECG, time, win, fs)
c =1; 
for (iT = time)
    if (win>0)
        ECG_w = ECG(iT+1:iT+win);
    else
        ECG_w = ECG(iT+win+1:iT);
    end
    ECG_w  = detrend(ECG_w);
    [~, ECG_peaks] = findpeaks(ECG_w,'MinPeakDistance',500,...
    'MinPeakHeight',0.15, 'MinPeakProminence',0.3);
    
if (length(ECG_peaks)>0) 
            R_win= ECG_peaks';
            HR_w(c)= 60./ECG_calcRespRate(ECG_w, fs, [zeros(size(R_win)); R_win; zeros(size(R_win))], 'HRV', 'auto_corr');
    
else
        fprintf('flipping \n');

        [~, ECG_peaks] = findpeaks(-ECG_w,'MinPeakDistance',500,...
    'MinPeakHeight',0.2, 'MinPeakProminence',0.4);
        
if (length(ECG_peaks)>0) 
            R_win= ECG_peaks';
            HR_w(c)= 60./ECG_calcRespRate(ECG_w, fs, [zeros(size(R_win)); R_win; zeros(size(R_win))], 'HRV', 'auto_corr');
        
else
            fprintf('No peaks even with flipping \n');

end


end

if mean(diff(ECG_peaks))*60<40
        fprintf('value erro \n');    
    
end
    c = c+1;
end

end


