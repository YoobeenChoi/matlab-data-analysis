% Load the Excel data
data = readtable('id100817_output.xlsx');

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
