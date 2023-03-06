% quick script for plotting motion energy aligned to odors in 
% OdorLaser_FreeWater task
% MGC 11/5/2022

paths = struct;
paths.data = 'D:\video\CamData_combined\';

opt = struct;
opt.session = 'MC97_20230306';
opt.cam = 'cam1';
opt.roi = 2;

%%

mat_files = get_mat_files(paths.data);
mat_files = mat_files(contains(mat_files,opt.session) & contains(mat_files,opt.cam));

load(fullfile(paths.data,mat_files{1}));

%%
trialt = CamData.camt(CamData.trial_idx)+0.5;
trig = round(trialt*1000);
trig = trig(21:180);

grp = SessionData.TrialTypes';

% resample to 1000 Hz
t = 0:0.001:max(CamData.camt);
y = interp1(CamData.camt,CamData.mot_energy(:,opt.roi),t); % nose
plot_timecourse('stream',y,trig,trig-1000,trig+3000,grp,'base_sub_win',[-1000 0]);