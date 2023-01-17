%%

df = importfile('../../sub_files/Start_Block.csv');

nSubjs = size(df,1);

ind_timing = '../../sub_files/IndividualTiming';

data_loc = '/media/cephfs/labs/skhalsa/Data/Capsule';

Fs =1000; %Hz

pre=30;%min

%%
timing_mat = zeros(nSubjs, 4);
for iSubj=1:nSubjs
    %
    subj = df.ID(iSubj);
    enh  = df.Enhanced_Block(iSubj);
    st   = df.Start(iSubj); 
    ind_sub_time = sprintf('%s/Corrected_Timing_%s.csv',ind_timing, subj);
    timing   = csvread(ind_sub_time);
    if enh==2
        % Normal is from 1 to 60 time stmaps
        % Enhanced is after 
        st_n_ind   = 1;
        st_enh_ind = 61;
        ed_n_ind   = 60;
        ed_enh_ind = size(timing,1);
    elseif enh==1
        % Normal is from 61 to 117
        % Enhanced is from 1 to 60
        st_n_ind   = 61;
        st_enh_ind = 1;
        ed_n_ind   = size(timing,1);
        ed_enh_ind = 60;        
    else
        fprintf('Not valid block number\n')
    end
    normal_block_st = timing(st_n_ind,1) +st;
    enh_block_st    = timing(st_enh_ind,1) +st;
    normal_block_ed = timing(ed_n_ind,1) +st;
    ehn_block_ed    = timing(ed_enh_ind,1) +st;
    timing_mat(iSubj, :) = [normal_block_st normal_block_ed enh_block_st ehn_block_ed];
    fprintf('time for normal is %0.2f min and %0.2f \n' ,...
        ((normal_block_ed - normal_block_st))/(Fs*60), ((ehn_block_ed - enh_block_st))/(Fs*60))
    
end
%%
df_res        = [];
normogasteria = [2.5, 3.5]/60; %Hz
tachygasteria = [3.75, 9.75]/60; %Hz
bradygasteria = [0.5, 2.25]/60; %Hz
totalgasteria = [0.5, 11]/60;%Hz
pre_ts        = [];
N_ts          = [];
Ehn           = [];

for iSubj=1:nSubjs %
    subj = df.ID(iSubj);
	fprintf("processing subject: %s \n", subj)
    %enh  = df.Enhanced_Block(iSubj);
    fixed_time = timing_mat(iSubj, :)  ;
    subj_data_loc = sprintf('%s/%s/*.mat', data_loc, subj);
    mat_fliel =dir(subj_data_loc)    ;
    if (length(mat_fliel)==1)
        mat_file = fullfile(mat_fliel(1).folder, mat_fliel(1).name);
        load(mat_file)
    else
        fprintf('no data for %s \n', subj);
    end
    EGG = data(:,2);
    EEG_N = EGG(fixed_time(1):fixed_time(2)-1, 1);
    EEG_Ehn = EGG(fixed_time(3):fixed_time(4)-1, 1);
    Pre_time  = max([1, (fixed_time(1)-Fs*pre*60 -Fs*3*60)]);
    if Pre_time==1
       fprintf('short pre for %s \n', subj);

    end
    EEG_Pre = EGG(Pre_time:fixed_time(1)-Fs*3*60-1, 1);
    fprintf('time for pre is %0.2f \n', (length(EEG_Pre)/(60*Fs)));
    %
    [f_pre,pxx1,f,y] = findPeak(EEG_Pre); 
    [f_Ehn,pxx2,f,y] = findPeak(EEG_Ehn); 
    [f_N,pxx3,f,y]   = findPeak(EEG_N);
    % Pre
    p_1_Pre         = power_band(EEG_Pre, normogasteria);
    p_2_Pre         = power_band(EEG_Pre, tachygasteria);
    p_3_Pre         = power_band(EEG_Pre, bradygasteria);
    p_4_Pre         = power_band(EEG_Pre, totalgasteria);
    % Normal
    p_1_N           = power_band(EEG_N, normogasteria);
    p_2_N           = power_band(EEG_N, tachygasteria);
    p_3_N           = power_band(EEG_N, bradygasteria);
    p_4_N           = power_band(EEG_N, totalgasteria);
    % Enhanced
    p_1_Ehn         = power_band(EEG_Ehn, normogasteria);
    p_2_Ehn         = power_band(EEG_Ehn, tachygasteria);
    p_3_Ehn         = power_band(EEG_Ehn, bradygasteria);
    p_4_Ehn         = power_band(EEG_Ehn, totalgasteria);
    
    % Ts
    pxx1_          =zeros(25*30*60+1,1); 
    pxx2_          =zeros(25*15*60+1,1); 
    pxx3_          =zeros(25*15*60+1,1); 
    
    pxx1_ = interp1(linspace(0,1,length(pxx1)), pxx1, (linspace(0,1,25*30*60)));
    pxx2_ = interp1(linspace(0,1,length(pxx2)), pxx2, (linspace(0,1,25*15*60)));
    pxx3_ = interp1(linspace(0,1,length(pxx3)), pxx3, (linspace(0,1,25*15*60)));
    
    %pxx1_(1:length(pxx1))=pxx1;
    %pxx2_(1:length(pxx2))=pxx2;    
    %pxx3_(1:length(pxx3))=pxx3;
    pre_ts         = [pre_ts,pxx1_'];
    N_ts         = [N_ts,pxx2_'];
    Ehn         = [Ehn,pxx3_'];
    
    
    df_res        = [df_res; [f_pre,f_N ,f_Ehn, p_1_Pre, p_2_Pre,p_3_Pre,...
        p_4_Pre, p_1_N, p_2_N,p_3_N,p_4_N, p_1_Ehn,p_2_Ehn,p_3_Ehn,p_4_Ehn, subj]];
end
%%
df_res = array2table(df_res);
writetable(df_res,'../../data/EGG_Results_reviewercomments_022722.csv')

function[peak_f,P1,f,y3] = findPeak(X)
    X = smoothdata(X,'movmean', 10000);
    y1= lowpass(X,20,1000);
    y2 = downsample(y1,20); 
    y3 = y2-mean(y2);
    Y = fft(y3);
    L= length(Y);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    f = 50*(0:(L/2))/L; % 50 hz is the new smapling ratres   
    %[pxx,f] = pwelch(y3,[],[],[],20);
    [val,ind] = max(P1);
    peak_f= f(ind);
    
end

function[pow_totla] = power_band(X, band)
    [peak_f,P1,F,y3] = findPeak(X);
    pow = P1.*conj(P1);
    pow_totla  = sum(pow((F>=band(1)) & (F<=band(2))));
end
