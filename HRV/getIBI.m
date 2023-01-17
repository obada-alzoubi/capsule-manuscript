function IBI = getIBI(ECG, time, win, Fs)

c=1;

for (iT = time)
    if (win>0)
        ECG_w = ECG(iT+1:iT+win);
    else
        ECG_w = ECG(iT+win+1:iT);
    end
    ECG_w  = detrend(ECG_w);
    [~, ECG_peaks] = findpeaks(ECG_w,Fs,'MinPeakDistance',0.5,...
    'MinPeakHeight',0.15, 'MinPeakProminence',0.3);  
    IBI = diff(ECG_peaks);
    
    c = c+1;
end

end

