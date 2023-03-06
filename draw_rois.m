%% script to manually draw ROIs for each video and same them for later
% MGC 4/1/2022
% turned into a function MGC 11/5/2022

function [] = draw_rois(paths)

paths.save = paths.roi;

opt = struct;
% opt.roi_names = {'WhiskerPad','Nose','Tongue','Eye'};

%%
video_file = dir(fullfile(paths.video,'*.avi'));
video_file = {video_file.name}';

%%
hfig = figure;
for vIdx = 1:numel(video_file)

    fprintf(sprintf('Draw ROIs for video %d/%d: %s\n',vIdx,numel(video_file),video_file{vIdx}));
    
    if contains(video_file{vIdx},'cam1')
        opt.roi_names = {'WhiskerPad','Nose','Tongue','Eye'};
    elseif contains(video_file{vIdx},'cam2')
        opt.roi_names = {'WholeFrame'};
    end

    vid_r = VideoReader(fullfile(paths.video,video_file{vIdx}));

    session = strsplit(video_file{vIdx},'_');
    session = [session{1} '_' session{2}];
    video_root = strsplit(video_file{vIdx},'.');
    video_root = video_root{1};

    fr = read(vid_r,1);

    imshow(fr);

    numROIs = numel(opt.roi_names);
    roi = cell(numROIs,1);
    plot_col = lines(numROIs);
    for i = 1:numROIs
        title(sprintf('Draw ROI for %s:',opt.roi_names{i}));
        roi{i} = drawrectangle('Color',plot_col(i,:));
        roi{i}.Label = opt.roi_names{i};
    end

    save(fullfile(paths.save,video_root),'roi','session');

end