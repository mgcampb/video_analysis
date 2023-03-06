%% script to extract gpio signal for each video
% MGC 4/2/2022
% changed to a function 11/5/2022 MGC

function [] = extract_gpio_all(paths)

paths.save = paths.gpio;
if ~isfolder(paths.save)
    mkdir(paths.save);
end

opt = struct;

%%
gpio_list = dir(fullfile(paths.video,'*.csv'));
gpio_list = {gpio_list.name}';

%%
for gIdx = 1:numel(gpio_list)

    gpio_file = gpio_list{gIdx};
    fprintf('File %d/%d: %s\n',gIdx,numel(gpio_list),gpio_file);

    session = strsplit(gpio_file,'_');
    session = [session{1} '_' session{2}];

    [sync_pulse,camt] = extract_gpio(fullfile(paths.video,gpio_file));

    if strcmp(session,'MC22_20210830') % gpio signal got messed up in this session; fix it here
        [~,start_idx] = max(diff(camt));
        sync_pulse = sync_pulse(start_idx:end);
        camt = camt(start_idx:end)-camt(start_idx);
    end

    save(fullfile(paths.save,gpio_file(1:end-4)),'sync_pulse','camt')
end