% Load the Excel data
data = readtable('id100817_output.xlsx');

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
