function[peak_f,P1,f,y3] = findPeak2(X)
    %X = smoothdata(X,'movmean', 10000);
    y1= lowpass(X,20,1000);
    %y2 = downsample(y1,20); 
    y3 = y1-mean(y1);
    Y = fft(y3);
    L= length(Y);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    f = 1000*(0:(L/2))/L; % 50 hz is the new smapling ratres   
    %[pxx,f] = pwelch(y3,[],[],[],20);
    [val,ind] = max(P1);
    peak_f= f(ind);
    
end
