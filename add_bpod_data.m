%% adds bpod data to synced camera data
% MGC 4/2/2022

% 11/4/2022 changed for new batch of data
% (just add SessionData to the saved file)

% turned into a function 11/5/2022 MGC

function [] = add_bpod_data(paths)

paths.cam_data = fullfile(paths.mot_energy,'synced');

opt = struct;
opt.bpod_protocol = 'OdorLaser_FreeWater';

%%
files_cam = dir(fullfile(paths.cam_data,'*.mat'));
files_cam = {files_cam.name}';

%%

for i = 1:numel(files_cam)

    fprintf(sprintf('file %d/%d: %s\n',i,numel(files_cam),files_cam{i}));

    dat = load(fullfile(paths.cam_data,files_cam{i}));

    session = dat.session;
    mouse = strsplit(session,'_');
    date = mouse{2};
    mouse = mouse{1};

    paths.bpod_data_full = fullfile(paths.bpod_data,mouse,opt.bpod_protocol,'Session Data');
    files_bpod = dir(fullfile(paths.bpod_data_full,'*.mat'));
    files_bpod = {files_bpod.name}';
    
    bpod_file = files_bpod(contains(files_bpod,date));
    if strcmp(session,'MC84_20221031')
        SessionData = load(fullfile(paths.bpod_data_full,bpod_file{2}));
        dat.trial_idx = dat.trial_idx(46:end);
    else
        assert(numel(bpod_file)==1);
        SessionData = load(fullfile(paths.bpod_data_full,bpod_file{1}));
    end
    cam_ts = dat.camt(dat.trial_idx);
    SessionData = SessionData.SessionData;
    bpod_ts = SessionData.TrialStartTimestamp';
    
    % for these sessions the first sync pulse was dropped
    if strcmp(session,'MC87_20221111') || strcmp(session,'MC84_20221118') || ...
            strcmp(session,'MC89_20221129') || strcmp(session,'MC89_20221130') || ...
            strcmp(session,'MC89_20221202')
        t_add = dat.camt(dat.trial_idx(1))-(bpod_ts(2)-bpod_ts(1));
        [~,t_idx_add] = min(abs(dat.camt-t_add)); 
        dat.trial_idx = [t_idx_add; dat.trial_idx];
        cam_ts = dat.camt(dat.trial_idx);
    elseif strcmp(session,'MC84_20221128') % first two pulses were dropped
        t_add = dat.camt(dat.trial_idx(1))-(bpod_ts(3)-bpod_ts(2));
        [~,t_idx_add] = min(abs(dat.camt-t_add)); 
        dat.trial_idx = [t_idx_add; dat.trial_idx];
        t_add = dat.camt(dat.trial_idx(1))-(bpod_ts(2)-bpod_ts(1));
        [~,t_idx_add] = min(abs(dat.camt-t_add)); 
        dat.trial_idx = [t_idx_add; dat.trial_idx];
        cam_ts = dat.camt(dat.trial_idx);
    elseif strcmp(session,'MC85_20221202') || strcmp(session,'MC86_20221202')
        continue;
    end
    
    assert(corr(diff(cam_ts),diff(bpod_ts))>0.95); % make sure time stamps match
    
    % make CamData struct
    CamData = dat;

    % save data
    if numel(dat.trial_idx) == numel(SessionData.TrialStartTimestamp)
        save(fullfile(paths.save,files_cam{i}),'SessionData','CamData');
    end

end