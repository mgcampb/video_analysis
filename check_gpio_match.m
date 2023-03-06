%% checked match between camera frames and gpio frames
% if match, resamples data to specified sample rate and saves separate file
% MGC 4/2/2022

% changed to a function MGC 11/5/2022

function [] = check_gpio_match(paths)


paths.save = fullfile(paths.mot_energy,'synced');
if ~isfolder(paths.save)
    mkdir(paths.save)
end

opt = struct;

%%
files_gpio = dir(fullfile(paths.gpio,'*.mat'));
files_mot_energy = dir(fullfile(paths.mot_energy,'*.mat'));
files_gpio = {files_gpio.name}';
files_mot_energy = {files_mot_energy.name}';

%%
messed_up = false(numel(files_gpio),1);
for i = 1:numel(files_gpio)
    fprintf('file %d/%d: %s\n',i,numel(files_gpio),files_gpio{i});
    gpio = load(fullfile(paths.gpio,files_gpio{i}));
    dat = load(fullfile(paths.mot_energy,files_mot_energy{i}));
    if size(gpio.camt,1) ~= size(dat.mot_energy,1)
        messed_up(i) = true;
        fprintf('\tMessed up: off by %d\n',size(gpio.camt,1)-size(dat.mot_energy,1));
        if abs(size(gpio.camt,1)-size(dat.mot_energy,1))==1
            fprintf('\t\tOff by one frame, ignore\n');
            n = min(size(gpio.camt,1),size(dat.mot_energy,1));
            gpio.camt = gpio.camt(1:n);
            gpio.sync_pulse = gpio.sync_pulse(1:n);
            dat.mot_energy = dat.mot_energy(1:n,:);
        else
            continue
        end
    end
    camt = gpio.camt;
    sync_pulse = gpio.sync_pulse;
    trial_idx = find(diff(sync_pulse)==1)+1;
    roi = dat.roi.roi;
    first_frame = dat.first_frame;
    video_file = dat.video_file;
    session = dat.session;
    mot_energy = dat.mot_energy;
    save(fullfile(paths.save,files_mot_energy{i}),...
        'mot_energy','roi','first_frame','video_file','session','sync_pulse','camt','trial_idx')
end