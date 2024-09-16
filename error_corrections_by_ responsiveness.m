% Load the data file
filename = 'event_table_MR.xlsx'; 
sheets = sheetnames(filename);

% Array to store the number of feedback-based corrected errors
corrected_errors = zeros(38, 1);  

for subj = 1:38  
    sheetname = sheets{subj};  
    data = readtable(filename, 'Sheet', sheetname);  
    
    % Extract accuracy and feedback information
    lap_data = data{:, 1};  % Lap data
    obj_data = data{:, 10};  % Object ID data
    accuracy_data = data{:, 15};  % Accuracy data (1 = correct, 0 = incorrect)
    
    % Initialize variable to count the number of corrected errors
    corrected_error_count = 0;
    
    % Measure corrected errors by comparing trials
    for lap = 2:8  % Start from the second lap (compare with the first lap)
        % Find the incorrect selections in the previous trial (accuracy_data == 0) and check if they were corrected
        previous_lap_indices = lap_data == (lap - 1);  % Indices for the previous lap
        current_lap_indices = lap_data == lap;  % Indices for the current lap
        
        previous_obj = obj_data(previous_lap_indices);  % Object ID in the previous lap
        current_obj = obj_data(current_lap_indices);  % Object ID in the current lap
        
        previous_accuracy = accuracy_data(previous_lap_indices);  % Accuracy in the previous lap
        current_accuracy = accuracy_data(current_lap_indices);  % Accuracy in the current lap
        
        % Find incorrect answers (0) in the previous trial and check if they were corrected in the current trial
        for i = 1:length(previous_accuracy)
            if previous_accuracy(i) == 0  % If an incorrect answer was made in the previous trial
                % Check if the same object was presented in the current trial and if it was corrected
                matching_obj = current_obj == previous_obj(i);
                if any(current_accuracy(matching_obj) == 1)  % If it was corrected
                    corrected_error_count = corrected_error_count + 1;  % Increment the corrected error count
                end
            end
        end
    end
    
    % Store the number of corrected errors
    corrected_errors(subj) = corrected_error_count;
end

% Display the result
disp('Number of feedback-based corrected errors:');
disp(corrected_errors);

% Split participants into groups based on feedback responsiveness (using the median)
median_correction = median(corrected_errors);  % Use the median to divide responsiveness
high_responsiveness = corrected_errors > median_correction;
low_responsiveness = corrected_errors <= median_correction;

% Calculate the mean and standard error for each group
high_resp_errors = corrected_errors(high_responsiveness);  
low_resp_errors = corrected_errors(low_responsiveness); 

% Calculate the mean and standard error for both groups
mean_high = mean(high_resp_errors);
mean_low = mean(low_resp_errors);
sem_high = std(high_resp_errors) / sqrt(length(high_resp_errors));  
sem_low = std(low_resp_errors) / sqrt(length(low_resp_errors));     

% bar chart
figure;
hold on;
bar(1, mean_high, 'FaceColor', [0.2, 0.6, 0.4]);  
bar(2, mean_low, 'FaceColor', [0.6, 0.4, 0.8]); 

% error bars
errorbar(1, mean_high, sem_high, 'k', 'LineWidth', 2);  
errorbar(2, mean_low, sem_low, 'k', 'LineWidth', 2);    

% plot
set(gca, 'XTick', [1, 2], 'XTickLabel', {'High Responsiveness', 'Low Responsiveness'});
ylabel('Mean Corrected Errors');
title('Feedback-Based Error Corrections by Responsiveness Group');
ylim([0 max([mean_high, mean_low]) + 5]);  % Set the Y-axis scale
grid on;
hold off;

% independent sample t-test between the two groups
[h, p_value, ci, stats] = ttest2(high_resp_errors, low_resp_errors);  % Compare the two groups
disp(['t-test p-value: ', num2str(p_value)]);
disp(['T-statistic: ', num2str(stats.tstat)]);
disp(['Degrees of freedom: ', num2str(stats.df)]);
disp(['Confidence interval: [', num2str(ci(1)), ', ', num2str(ci(2)), ']']);

% boxplot
figure;
hold on;
boxplot([high_resp_errors; low_resp_errors], ...
    [ones(length(high_resp_errors), 1); 2 * ones(length(low_resp_errors), 1)], ...
    'Labels', {'High Responsiveness', 'Low Responsiveness'}, 'Widths', 0.5);

ylabel('Number of Corrected Errors');
title('Feedback-Based Error Corrections by Responsiveness Group');
grid on;
hold off;
