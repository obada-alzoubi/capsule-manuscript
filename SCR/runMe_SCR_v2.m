%% df
addpath('/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/scritps/ledalab-349')

addpath('/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/scritps')
df = importfile('/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/sub_files/Start_Block.csv');

nSubjs = size(df,1);

ind_timing = '/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/sub_files/IndividualTiming';

data_loc = '/media/cephfs/labs/skhalsa/Data/Capsule';

data_ph1 = '/media/cephfs/labs/jbodurka/Obada/Projects/Capsule/data/SCR_NatureComm/';
mkdir(data_ph1)
% important parmaters 
Fs       = 1000; %Hz
pre      = 30;%min
SCR_wind = 3 ; % secd
thr      = 0.01;

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
    timing_mat{iSubj, 4} =st;

   
    
end
%%
k        = 60;% events 
Wind     = 3*Fs; % 3 sec window 
offest_  = 2*60*Fs;
spacing  = 25;
for i=1:k
    baseline_events(i) = offest_+i*(spacing)*Fs;
end
baseline_events_pre = baseline_events - Wind;
%%

HR_MAt       = cell(nSubjs, 5);% First subject, pre Normal, post Normal, pre Enh and pot Enh
for iSubj=1:nSubjs %
    
    subj            = timing_mat{iSubj, 3};
    output_file     = sprintf('%s/%s_SCR.mat', data_ph1,subj );
    if (isfile(output_file)==1)
        fprintf("Subject %s is already processed \n", subj)
        continue;
    end

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
    SCR = data(:,5);
    SCR           = detrend(SCR);

    % Cut data
    % Baseline evenets 
    st = timing_mat{iSubj, 4} ;   
    
    % Nromal Block 
    normal_events        = timing_mat{iSubj, 1};
    normal_events_pre    = timing_mat{iSubj, 1} -Wind;
    % Enhanced
    enh_events       = timing_mat{iSubj, 2};
    enh_events_pre   = timing_mat{iSubj, 2}-Wind;
    
    % Fill template
    data          = [];
    % Load Template
    load('ivn07_16_matlab.mat')
    
    % Create data object for ledakab
    data.conductance = SCR';
    t                = (1:length(SCR))/Fs;
    data.time        = t;
    events           = data.event;
    offset           = 0;
    
    % Add events .. first Normal
    for iEven=1:length(normal_events)
        events(iEven).time     = normal_events(iEven)/Fs;
        events(iEven).nid      = 1;
        events(iEven).name     = 'N';
        events(iEven).userdata = [];
        offset                 = offset+1; 

    end
    
    % Pre Normal 
    offset2                 = length(events);

    for iEven=1:length(normal_events_pre)
        events(iEven+offset2).time     = normal_events_pre(iEven)/Fs;
        events(iEven+offset2).nid      = 2;
        events(iEven+offset2).name     = 'N_pre';
        events(iEven+offset2).userdata = [];

    end
    
    % Enhanced 
    offset3                 = length(events);
   
    for iEven=1:length(enh_events)
        events(iEven+offset3).time     = enh_events(iEven)/Fs;
        events(iEven+offset3).nid      = 3;
        events(iEven+offset3).name     = 'E';
        events(iEven+offset3).userdata = [];
    end
    
    offset4                 = length(events);
   
    for iEven=1:length(enh_events_pre)
        events(iEven+offset4).time     = enh_events_pre(iEven)/Fs;
        events(iEven+offset4).nid      = 4;
        events(iEven+offset4).name     = 'E_pre';
        events(iEven+offset4).userdata = [];
    end
    
    
    offset5                 = length(events);

    % baseline 
    for iEven=1:length(baseline_events)
        events(iEven+offset5).time     = baseline_events(iEven)/Fs;
        events(iEven+offset5).nid      = 5;
        events(iEven+offset5).name     = 'B';
        events(iEven+offset5).userdata = [];


    end
    
    offset6                 = length(events);

    % pre baseline 
    for iEven=1:length(baseline_events_pre)
        events(iEven+offset6).time     = baseline_events_pre(iEven)/Fs;
        events(iEven+offset6).nid      = 6;
        events(iEven+offset6).name     = 'B_pre';
        events(iEven+offset6).userdata = [];


    end
    data.event = events;
    save(output_file, 'data');
    data = []; 

end
%% RunToolbox Here 
Ledalab(data_ph1, 'open', 'mat','mean', 200, 'downsample', 50, ...
    'analyze','CDA', 'optimize',5, 'export_era', [0 SCR_wind thr 1])



