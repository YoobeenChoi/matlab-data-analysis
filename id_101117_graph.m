% Load the Excel data
data = readtable('id101117_output.xlsx');

% Filter laps from 1 to 8
filtered_data = data(data.Lap >= 1 & data.Lap <= 8, :);

% Initialize variables
laps = unique(filtered_data.Lap);  % Unique laps from 1 to 8
accuracy = zeros(length(laps), 1);  % Initialize accuracy array

% Calculate accuracy for each lap
for i = 1:length(laps)
    lap_trials = filtered_data(filtered_data.Lap == laps(i), :);  % Trials in this lap
    correct_trials = sum(lap_trials.Correct_Num == 1);  % Count correct trials (Correct_Num == 1)
    total_trials = 4;  % Each lap has 4 trials
    accuracy(i) = (correct_trials / total_trials) * 100;  % Calculate accuracy in percentage
end

% Plot accuracy by lap as a line graph (publication-ready)
figure;
plot(laps, accuracy, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'blue');
xlabel('Lap', 'FontSize', 14);
ylabel('Accuracy (%)', 'FontSize', 14);
title('Accuracy by Lap', 'FontSize', 16);
ylim([0 100]);  % Set y-axis limits to 0-100%
xlim([1 8]);    % Ensure the x-axis covers laps 1 to 8
set(gca, 'FontSize', 12);  % Set axis font size
box off;  % Remove the box around the plot


% Load the Excel data
data = readtable('id101117_output.xlsx');

% Filter laps from 1 to 8
filtered_data = data(data.Lap >= 1 & data.Lap <= 8, :);

% Initialize variables
laps = unique(filtered_data.Lap);  % Unique laps from 1 to 8
reaction_time = zeros(length(laps), 1);  % Initialize reaction time array

% Calculate average reaction time for each lap
for i = 1:length(laps)
    lap_trials = filtered_data(filtered_data.Lap == laps(i), :);  % Trials in this lap
    valid_rt_trials = lap_trials.RT(~isnan(lap_trials.RT));  % Exclude NaN values
    reaction_time(i) = mean(valid_rt_trials);  % Calculate average reaction time
end

% Plot reaction time by lap as a line graph (publication-ready)
figure;
plot(laps, reaction_time, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'red');
xlabel('Lap', 'FontSize', 14);
ylabel('Reaction Time (s)', 'FontSize', 14);
title('Reaction Time by Lap', 'FontSize', 16);
xlim([1 8]);    % Ensure the x-axis covers laps 1 to 8
set(gca, 'FontSize', 12);  % Set axis font size
box off;  % Remove the box around the plot

% Load the Excel data
data = readtable('id101117_output.xlsx');

% Extract reaction times for Lap 0 (pre-ODT) and Lap 9 (post-ODT)
lap_0_rt = data.RT(data.Lap == 0);  % Reaction times for Lap 0 (pre-ODT)
lap_9_rt = data.RT(data.Lap == 9);  % Reaction times for Lap 9 (post-ODT)

% Remove NaN values
lap_0_rt = lap_0_rt(~isnan(lap_0_rt));  % Remove NaN values from Lap 0
lap_9_rt = lap_9_rt(~isnan(lap_9_rt));  % Remove NaN values from Lap 9

% Ensure we have exactly 3 reaction times for both Lap 0 and Lap 9
if length(lap_0_rt) < 3 || length(lap_9_rt) < 3
    error('Insufficient reaction time data for Lap 0 or Lap 9 after NaN removal.');
end

lap_0_rt = lap_0_rt(1:3);  % Get first 3 RTs for Lap 0
lap_9_rt = lap_9_rt(1:3);  % Get first 3 RTs for Lap 9

% Combine data for plotting
rt_data = [lap_0_rt lap_9_rt]';  % Combine into a 2x3 matrix (pre-ODT vs post-ODT)

% Create x-axis labels (target object order)
x_labels = {'1st', '2nd', '3rd'};  % Target object order

% Plot the bar graph
figure;
bar(rt_data', 'grouped');
set(gca, 'XTickLabel', x_labels);  % Set x-axis labels as target object order
xlabel('Target Object Order');
ylabel('Reaction Time (s)');
legend({'Pre-ODT', 'Post-ODT'}, 'Location', 'northwest');
title('Pre-ODT vs Post-ODT Reaction Times by Target Object Order');

% Calculate y-axis limits safely
max_rt = max(rt_data(:));
if isnan(max_rt) || max_rt <= 0
    max_rt = 1;  % Default max if all data is NaN or zero
end
ylim([0 max_rt + 0.5]);  % Set y-axis limit based on the data

set(gca, 'FontSize', 12);  % Set axis font size

% Perform a paired t-test to compare pre-ODT and post-ODT reaction times
[~, p_value, ~, stats] = ttest(lap_0_rt, lap_9_rt);

% Display the results of the t-test
disp('Paired t-test results comparing Pre-ODT vs Post-ODT reaction times:');
disp(['t-statistic: ', num2str(stats.tstat)]);
disp(['p-value: ', num2str(p_value)]);
disp(['Degrees of freedom: ', num2str(stats.df)]);