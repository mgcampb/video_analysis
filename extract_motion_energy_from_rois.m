%% script to extract motion energy from previously drawn ROIs
% MGC 4/1/2022

function [] = extract_motion_energy_from_rois(paths)

paths.save = paths.mot_energy;

opt = struct;
opt.make_figs = false;

%%
video_list = dir(fullfile(paths.video,'*.avi'));
video_list = {video_list.name}';

%%
if opt.make_figs
    figure;
end
parfor vIdx = 1:numel(video_list)

    video_file = video_list{vIdx};
    fprintf('Processing video %d/%d: %s\n',vIdx,numel(video_list),video_file);

    vid_r = VideoReader(fullfile(paths.video,video_file));

    first_frame = read(vid_r,1);

    session = strsplit(video_file,'_');
    session = [session{1} '_' session{2}];
    video_root = strsplit(video_file,'.');
    video_root = video_root{1};

    roi = load(fullfile(paths.roi,video_root));

    numROIs = numel(roi.roi);

    mot_energy = nan(vid_r.NumFrames,numROIs);
    fr_crop_prev = cell(numROIs,1);
    
    if opt.make_figs
        sgtitle(video_file,'Interpreter','none');
    end

    for i = 1:vid_r.NumFrames

        if mod(i,5000)==0
            fprintf(sprintf('\tVideo %d/%d: %s \t Frame %d/%d\n',...
                vIdx,numel(video_list),video_file,i,vid_r.NumFrames));
        end

        fr = read(vid_r,i);

        for j = 1:numROIs
            fr_crop = imcrop(fr,roi.roi{j}.Position);
            if i==1
                fr_diff = zeros(size(fr_crop));
            else
                fr_diff = fr_crop - fr_crop_prev{j};
            end
            fr_crop_prev{j} = fr_crop;
            mot_energy(i,j) = sum(sum(sum(abs(fr_diff))));
            if opt.make_figs && i<1000
                subplot(2,numROIs,j);
                imshow(fr_crop);
                subplot(2,numROIs,j+numROIs);
                imshow(fr_diff);
                drawnow;
            end
            if mot_energy(i,j)==0 && i>1
                mot_energy(i,j) = mot_energy(i-1,j);
            end
        end
    end

    parsave(fullfile(paths.save,video_root), mot_energy, roi, session, video_file, first_frame);

end

end

function parsave(fname, mot_energy, roi, session, video_file, first_frame)
    save(fname, 'mot_energy', 'roi', 'session', 'video_file', 'first_frame');
end