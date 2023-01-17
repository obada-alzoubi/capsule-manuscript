%% df
df = importfile('../../sub_files/Start_Block.csv');

nSubjs = size(df,1);

ind_timing = '../../sub_files/IndividualTiming';

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
    timing_mat{iSubj, 1} =normal_events;
    timing_mat{iSubj, 2} =enh_events;
    timing_mat{iSubj, 3} =subj;

   
    
end
%%
W= 3*Fs;
HR_MAt       = cell(nSubjs, 7);% First subject, pre Normal, post Normal, pre Enh and pot Enh

k             = 60;
offest_ = 2*Fs*60;
spacing = 25;
for i=1:k
    baseline_events(i)=offest_+i*(spacing)*Fs;
end
%%

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

    HR_MAt{iSubj,2} = getHR(ECG, normal_events, W, Fs);
    HR_MAt{iSubj,3} = getHR(ECG, normal_events, -W, Fs);
    
    % Enhanced Block 
    enh_events       = timing_mat{iSubj, 2};

    HR_MAt{iSubj,4} = getHR(ECG, enh_events, W, Fs);
    HR_MAt{iSubj,5} = getHR(ECG, enh_events, -W, Fs);
    
    HR_MAt{iSubj,6} = getHR(ECG, baseline_events, W, Fs);
    HR_MAt{iSubj,7} = getHR(ECG, baseline_events, -W, Fs);
    
    % 
    clear  ECG ;
    

end
%%
df_res = []; 
names_cond  = {'Post'; 'Pre'; 'Post'; 'Pre';'Post'; 'Pre'};
names_block = {'Normal', 'Normal', 'Enhanced', 'Enhanced','Baseline', 'Baseline'};
for iSubj=1:nSubjs %

    subj    =  HR_MAt{iSubj,1} ;
    for(i= 1:6)
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
writetable(df_res,'../../data/ECG_Wind_Results_120121.csv')

