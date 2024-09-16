% Load the data
filename = 'event_table_MR.xlsx';
sheets = sheetnames(filename); 

num_subjects = 38;
num_laps = 8;

% an array to store accuracies for each subject and lap
all_accuracies = zeros(num_subjects, num_laps);

% plot learning curves for each subject
for subj = 1:num_subjects
    sheetname = sheets{subj};
    data = readtable(filename, 'Sheet', sheetname);  % Read data from each subject's sheet
    
    lap_data = data{:, 1};  % Lap data (column 1)
    accuracy_data = data{:, 15};  % Accuracy data (column 15: 1 = correct, 0 = incorrect)
    
    for lap = 1:num_laps
        lap_indices = lap_data == lap;  % indices for the current lap
        lap_accuracy = accuracy_data(lap_indices);  % accuracy for the current lap
        
        % mean accuracy for the current lap
        accuracy = mean(lap_accuracy) * 100;
        all_accuracies(subj, lap) = accuracy;  % Store accuracy in the array
    end
end

% the slope (learning rate) for each subject using linear regression
slopes = zeros(num_subjects, 1); 
for subj = 1:num_subjects
    p = polyfit(1:num_laps, all_accuracies(subj, :), 1);  % linear regression on accuracy across laps
    slopes(subj) = p(1);  % Store the slope (p(1) is the slope)
end

% median slope
median_slope = median(slopes);

% Classify subjects into high responsiveness group (slope > median)
high_responsiveness_group = slopes > median_slope;

% Classify subjects into low responsiveness group (slope <= median)
low_responsiveness_group = slopes <= median_slope;

% average slope for each group
mean_slope_high = mean(slopes(high_responsiveness_group));
mean_slope_low = mean(slopes(low_responsiveness_group));

% average learning curve for the high responsiveness group
mean_accuracy_high = mean(all_accuracies(high_responsiveness_group, :), 1);

% average learning curve for the low responsiveness group
mean_accuracy_low = mean(all_accuracies(low_responsiveness_group, :), 1);

% learning curves for both groups
figure;
hold on;

% Plot the average learning curve for the high responsiveness group
plot(1:num_laps, mean_accuracy_high, '-o', 'Color', [0.2, 0.6, 0.4], 'LineWidth', 2, 'MarkerFaceColor', [0.2, 0.6, 0.4]);

% Plot the average learning curve for the low responsiveness group
plot(1:num_laps, mean_accuracy_low, '-s', 'Color', [0.6, 0.4, 0.8], 'LineWidth', 2, 'MarkerFaceColor', [0.6, 0.4, 0.8]);

% Plot customization
xlabel('Lap Number', 'FontSize', 14);
ylabel('Mean Accuracy (%)', 'FontSize', 14);
title('Mean Learning Curves by Responsiveness Group', 'FontSize', 16);
legend({'High Responsiveness', 'Low Responsiveness'}, 'Location', 'eastoutside', 'FontSize', 12);
set(gca, 'FontSize', 12);
ylim([40 110]); 
xlim([1 num_laps]);  
grid on;
hold off;

% t-test to compare the slopes between the two groups
[h, p_value, ci, stats] = ttest2(slopes(high_responsiveness_group), slopes(low_responsiveness_group));

% Display the results
disp(['t-test p-value: ', num2str(p_value)]);
disp(['Mean slope (High Responsiveness Group): ', num2str(mean_slope_high)]);
disp(['Mean slope (Low Responsiveness Group): ', num2str(mean_slope_low)]);
