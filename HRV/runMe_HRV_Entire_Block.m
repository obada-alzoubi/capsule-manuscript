clc;clear all; close all; 
%% General Config. 
addpath('/media/cephfs/labs/jfeinstein/Obada/Code/AA2_ECG_Phase2_V2/Scripts/helping_funcs')
addpath('/media/cephfs/labs/jfeinstein/Obada/Code/AA2_ECG_Phase2_V2/Scripts/hrv_funcs')
addpath('/media/cephfs/labs/jfeinstein/Obada/Code/AA2_ECG_Phase2_V2/Scripts/peak_detection_funcs')
addpath('/media/cephfs/labs/jfeinstein/Obada/Code/My Package')

%[ ~, ibi_pre ] = correctOuliers( ibi_pre);
%[ hrv_pre ] = AA_HRV_MetricV3( ibi_pre, [], 'no');
%dynamicHRV_V2( loc, sf, ef, 5*60*1000, 2.5*60*1000, corrected_file );
%rightWindowECG( ibi.ecg, sf, ef, 5*60*1000, 2.5*60*1000, subjFolder );

%% df

df = importfile('/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/sub_files/Start_Block.csv');

nSubjs = size(df,1);

ind_timing = '/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/sub_files/IndividualTiming';

data_loc = '/media/cephfs/labs/skhalsa/Data/Capsule';

Fs =1000; %Hz

pre=30;%min

%%
timing_mat = cell(nSubjs, 3);% first col is for normal, second for enhanced
% Third for subject ID
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
    % Get ind of each event 
    normal_events  = []; 
    c              = 1;
    for (ind = st_n_ind:ed_n_ind)
        normal_events(c) = timing(ind,1) +st;
        c = c+1;
    end
    
    enh_events  = []; 
    c              = 1;
    for (ind = st_enh_ind:ed_enh_ind)
        enh_events(c) = timing(ind,1) +st;
        c = c+1;
    end    
    timing_mat{iSubj, 1} = normal_events;
    timing_mat{iSubj, 2} = enh_events;
    timing_mat{iSubj, 3} = subj;
    timing_mat{iSubj, 4} = st;

   
    
end
%%

HR_MAt       = cell(nSubjs, 34);% First subject, pre Normal, post Normal, pre Enh and pot Enh
W            = 60*Fs; % Window of 60 sec 
for iSubj=1:nSubjs %

    subj            = timing_mat{iSubj, 3};
    HR_MAt{iSubj,1} = subj;
    subj_data_loc   = sprintf('%s/%s/*.mat', data_loc, subj);
    mat_fliel       = dir(subj_data_loc)    ;
    
    if (length(mat_fliel)>=1)
        ind=length(mat_fliel);
        mat_file = fullfile(mat_fliel(ind).folder, mat_fliel(ind).name);
        load(mat_file)
    else
        fprintf('no data for %s \n', subj);
        continue;
    end
    
    %ECG Data
    ECG = data(:,1);
    
    % Nromal Block 
    normal_events       = timing_mat{iSubj, 1};
    % normal_events
    W                   = normal_events(end)-normal_events(1);

   IBI_Normal         = getIBI(ECG, normal_events(1), W, Fs); 
   [ ~, IBI_Normal ]  = correctOuliers( IBI_Normal*1000);
   IBI_Normal(isnan(IBI_Normal))=[];

   [ HRV_Normal ]     = AA_HRV_MetricV3( IBI_Normal, [], 'no');
    HR_MAt{iSubj,2}   = HRV_Normal.RMSSD(2);
    HR_MAt{iSubj,3}   = HRV_Normal.SDNN(2);
    HR_MAt{iSubj,4}   = HRV_Normal.aHF;
    HR_MAt{iSubj,5}   = HRV_Normal.aLF;
    HR_MAt{iSubj,6}   = HRV_Normal.aVLF;
    HR_MAt{iSubj,7}   = HRV_Normal.aTotal;
    HR_MAt{iSubj,8}   = HRV_Normal.nHF;
    HR_MAt{iSubj,9}   = HRV_Normal.nLF;
    HR_MAt{iSubj,10}   = HRV_Normal.pHF;
    HR_MAt{iSubj,11}   = HRV_Normal.pVLF;
    HR_MAt{iSubj,12}   = HRV_Normal.pLF;

    
    % Enhanced Block 
    
    enh_events     = timing_mat{iSubj, 2};
    %  
    W              = enh_events(end)-enh_events(1);
    IBI_Enh        = getIBI(ECG, enh_events(1), W, Fs); 
    [ ~, IBI_Enh ] = correctOuliers( IBI_Enh*1000);
    IBI_Enh(isnan(IBI_Enh))=[];

    HRV_Enh        = []; 
   [ HRV_Enh ]     = AA_HRV_MetricV3( IBI_Enh, [], 'no');
   
    HR_MAt{iSubj,13} = HRV_Enh.RMSSD(2);
    HR_MAt{iSubj,14} = HRV_Enh.SDNN(2);
    HR_MAt{iSubj,15}   = HRV_Enh.aHF;
    HR_MAt{iSubj,16}   = HRV_Enh.aLF;
    HR_MAt{iSubj,17}   = HRV_Enh.aVLF;
    HR_MAt{iSubj,18}   = HRV_Enh.aTotal;
    HR_MAt{iSubj,19}   = HRV_Enh.nHF;
    HR_MAt{iSubj,20}   = HRV_Enh.nLF;
    HR_MAt{iSubj,21}   = HRV_Enh.pHF;
    HR_MAt{iSubj,22}   = HRV_Enh.pVLF;   
    HR_MAt{iSubj,23}   = HRV_Enh.pLF;    
 
    % Add base line
    st                  = 2*Fs*60; % Add ofset
    ed                  = 30*Fs*60;
    W                   = ed -st; 
    IBI_baseline        = []; 
    IBI_baseline        = getIBI(ECG, st,W, Fs); 
    [ ~, IBI_baseline ] = correctOuliers( IBI_baseline*1000);
    IBI_baseline(isnan(IBI_baseline))=[];
    [ HRV_Baseline]     = AA_HRV_MetricV3( IBI_baseline, [], 'no');

    HR_MAt{iSubj,24} = HRV_Baseline.RMSSD(2);
    HR_MAt{iSubj,25} = HRV_Baseline.SDNN(2);
    HR_MAt{iSubj,26}   = HRV_Baseline.aHF;
    HR_MAt{iSubj,27}   = HRV_Baseline.aLF;
    HR_MAt{iSubj,28}   = HRV_Baseline.aVLF;
    HR_MAt{iSubj,29}   = HRV_Baseline.aTotal;
    HR_MAt{iSubj,30}   = HRV_Baseline.nHF;
    HR_MAt{iSubj,31}   = HRV_Baseline.nLF;
    HR_MAt{iSubj,32}   = HRV_Baseline.pHF;
    HR_MAt{iSubj,33}   = HRV_Baseline.pVLF;   
    HR_MAt{iSubj,34}   = HRV_Baseline.pLF;   
    
    %
    clear enh_events normal_events ECG HRV_Baseline HRV_Enh HRV_Normal W;

end
%%
df_res = []; 
names_cond  = { 'SDNN'; 'RMSSD';'aHF';'aLF';'aVLF';'aTotal';'nHF';'nLF'; 'pHF';'pVLF';'pLF'; ...
                'SDNN'; 'RMSSD';'aHF';'aLF';'aVLF';'aTotal';'nHF';'nLF'; 'pHF';'pVLF';'pLF'; ...
               'SDNN'; 'RMSSD';'aHF';'aLF';'aVLF';'aTotal';'nHF';'nLF'; 'pHF';'pVLF';'pLF' };
names_block = {'Normal', 'Normal','Normal', 'Normal', 'Normal', 'Normal','Normal', 'Normal','Normal', 'Normal','Normal', ...
               'Enhanced', 'Enhanced', 'Enhanced', 'Enhanced',  'Enhanced', 'Enhanced', 'Enhanced', 'Enhanced', 'Enhanced',  'Enhanced','Enhanced', ...
               'Baseline', 'Baseline',  'Baseline', 'Baseline', 'Baseline', 'Baseline',  'Baseline', 'Baseline',  'Baseline', 'Baseline','Baseline' };
for iSubj=1:nSubjs %

    subj    =  HR_MAt{iSubj,1} ;
    for(i= 1:33)
        HRs = HR_MAt{iSubj, i+1};
        cond = names_cond{i};
        block= names_block{i};
            
        for j= HRs
            df_res  = [df_res; [subj, block, cond, j]];
        end
        
    end

end
%%

df_res = array2table(df_res);
writetable(df_res,'/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/data/HRV_Results_120121_improved.csv')