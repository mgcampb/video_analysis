function trial_types_reorder = reorder_trial_types(trial_types,exp_params)

    laser_target = {'VS','DMS','DLS'};
    trial_types_reorder = trial_types;
    for i = 1:3
        targ_idx = find(strcmp(exp_params.laser_target,laser_target{i}));
        trial_types_reorder(trial_types == targ_idx) = i;
    end
end