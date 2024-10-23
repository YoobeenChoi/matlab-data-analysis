folder_path = '/Users/yoobeenchoi/Downloads/backup';  
file_list = dir(fullfile(folder_path, '*.set'));
results = struct();

for i = 1:length(file_list)
    file_name = file_list(i).name;
    EEG = pop_loadset('filename', file_name, 'filepath', folder_path);
    
    % epoching for M8 (navi start) with -2 to 4 sec
    epoch_duration_pre = [-2 0]; 
    epoch_duration_post = [0 4]; 

    EEG_pre_M8 = pop_epoch(EEG, {'M  8'}, epoch_duration_pre, 'newname', [file_name, '_M8_PreEpoch'], 'epochinfo', 'yes');
    EEG_post_M8 = pop_epoch(EEG, {'M  8'}, epoch_duration_post, 'newname', [file_name, '_M8_PostEpoch'], 'epochinfo', 'yes');

    pop_saveset(EEG_pre_M8, 'filename', [file_name, '_M8_PreEpoch.set'], 'filepath', folder_path);
    pop_saveset(EEG_post_M8, 'filename', [file_name, '_M8_PostEpoch.set'], 'filepath', folder_path);
    
    % pwelch for each epoch (across all channels and epochs)
    num_channels = size(EEG_pre_M8.data, 1);
    num_epochs_pre = size(EEG_pre_M8.data, 3);
    num_epochs_post = size(EEG_post_M8.data, 3);

    alpha_power_pre = zeros(num_channels, num_epochs_pre);
    theta_power_pre = zeros(num_channels, num_epochs_pre);
    alpha_power_post = zeros(num_channels, num_epochs_post);
    theta_power_post = zeros(num_channels, num_epochs_post);
    
    for ch = 1:num_channels
        for ep = 1:num_epochs_pre
            epoch_data = EEG_pre_M8.data(ch, :, ep);
            [pxx_pre, f] = pwelch(epoch_data, [], [], [], EEG.srate);
            alpha_power_pre(ch, ep) = mean(pxx_pre(f > 8 & f < 12));  
            theta_power_pre(ch, ep) = mean(pxx_pre(f > 4 & f < 8)); 
        end
        
        for ep = 1:num_epochs_post
            epoch_data = EEG_post_M8.data(ch, :, ep);
            [pxx_post, f] = pwelch(epoch_data, [], [], [], EEG.srate);
            alpha_power_post(ch, ep) = mean(pxx_post(f > 8 & f < 12)); 
            theta_power_post(ch, ep) = mean(pxx_post(f > 4 & f < 8));
        end
    end
    
    % epoching 4 sec after object on 
    epoch_duration_object = [0 4]; 
    object_markers = {'M 14', 'M 15', 'M 16', 'M 17'};

    EEG_object_epoch = pop_epoch(EEG, object_markers, epoch_duration_object, 'newname', [file_name, '_ObjectEpoch'], 'epochinfo', 'yes');
    pop_saveset(EEG_object_epoch, 'filename', [file_name, '_ObjectEpoch.set'], 'filepath', folder_path);

    num_epochs_object = size(EEG_object_epoch.data, 3);
    alpha_power_object = zeros(num_channels, num_epochs_object);
    theta_power_object = zeros(num_channels, num_epochs_object);
    
    for ch = 1:num_channels
        for ep = 1:num_epochs_object
            epoch_data = EEG_object_epoch.data(ch, :, ep);
            [pxx_object, f] = pwelch(epoch_data, [], [], [], EEG.srate);
            alpha_power_object(ch, ep) = mean(pxx_object(f > 8 & f < 12));
            theta_power_object(ch, ep) = mean(pxx_object(f > 4 & f < 8)); 
        end
    end
    
    % results
    results(i).subject = file_name;
    results(i).alpha_power_pre = alpha_power_pre;
    results(i).theta_power_pre = theta_power_pre;
    results(i).alpha_power_post = alpha_power_post;
    results(i).theta_power_post = theta_power_post;
    results(i).alpha_power_object = alpha_power_object;
    results(i).theta_power_object = theta_power_object;
end

% outlier removal
for i = 1:length(results)
    % Alpha power -2 sec
    alpha_pre = results(i).alpha_power_pre;
    alpha_pre(isoutlier(alpha_pre)) = NaN;  
    results(i).alpha_power_pre = alpha_pre; 
    
    % Theta power navi -2 sec
    theta_pre = results(i).theta_power_pre;
    theta_pre(isoutlier(theta_pre)) = NaN;
    results(i).theta_power_pre = theta_pre;
    
    % Alpha power navi + 4 sec
    alpha_post = results(i).alpha_power_post;
    alpha_post(isoutlier(alpha_post)) = NaN;
    results(i).alpha_power_post = alpha_post;
    
    % Theta power navi + 4 sec
    theta_post = results(i).theta_power_post;
    theta_post(isoutlier(theta_post)) = NaN;
    results(i).theta_power_post = theta_post;
    
    % Alpha power objecton
    alpha_object = results(i).alpha_power_object;
    alpha_object(isoutlier(alpha_object)) = NaN;
    results(i).alpha_power_object = alpha_object;
    
    % Theta power objecton
    theta_object = results(i).theta_power_object;
    theta_object(isoutlier(theta_object)) = NaN;
    results(i).theta_power_object = theta_object;
end

disp(num2str(results(3).alpha_power_pre));

save(fullfile(folder_path, 'power_results.mat'), 'results');