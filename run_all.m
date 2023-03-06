% Runs all motion energy extraction scripts
% MGC 11/5/2022

tic;

paths = struct;
paths.video = 'D:\video\';
paths.save = 'D:\video\CamData_combined\';
paths.gpio = 'D:\video\gpio\';
paths.roi = 'D:\video\roi\';
paths.mot_energy = 'D:\video\mot_energy\';
paths.bpod_data = 'D:\Bpod_Data';

mkdir(paths.gpio);
mkdir(paths.roi);
mkdir(paths.mot_energy);

draw_rois(paths);
extract_motion_energy_from_rois(paths);
extract_gpio_all(paths);
check_gpio_match(paths);
add_bpod_data(paths);

rmdir(paths.gpio,'s');
rmdir(paths.roi,'s');
rmdir(paths.mot_energy,'s');

delete(fullfile(paths.video,'*.avi'));
delete(fullfile(paths.video,'*.csv'));

close all;
fprintf('\nFinished\n');
toc;