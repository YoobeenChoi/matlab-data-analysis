% Load the Excel data
data = readtable('id100817_output.xlsx');

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
